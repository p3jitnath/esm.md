!> Compute source POS/VPOS fields from live native arrays.
module forecast_actual_output_grid_calculations
  use iso_fortran_env, only: int32, int64, real64
  use forecast_output_grid_calculations, only: native_output_grid_sources
  use grid_field_configuration_types_port, only: grid_field_configuration
  use forecast_fullpos_state_types, only: native_fullpos_state
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  use runtime_vertical_output_physics_port, only: relative_humidity_parameters, output_relative_humidity
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_geopotential_and_column_water, only: compute_geopotential
  use md2asm_vertical_continuity, only: compute_vertical_continuity
  use forecast_runtime_dynamic_output_interpolation, only: ppgeop, ppvvel, pp2dint
  use forecast_runtime_output_wind_interpolation, only: ppuv
  use iso_c_binding, only: c_double, c_f_pointer, c_associated
  use forecast_output_request_types, only: type_fprqdyn, increment_output_counter
  use forecast_output_request_views, only: native_output_field_view, native_output_view_counters, output_field_map
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_grid_motion_types, only: native_grid_motion_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  use md2asm_moist_air_gas_properties, only: moist_air_constants, compute_moist_air_properties
  use forecast_surface_temperature_extrapolation, only: ctstar
  use forecast_pressure_level_interpolation, only: ppinit, ppflev, ppsta, ppt
  use forecast_pressure_humidity_output, only: ppq
  implicit none
  private
  public :: native_output_grid_sources, calculate_actual_output_grid_fields
  !> Borrow actual geometry, motion, constituent storage and constants.
  !! indices name humidity/liquid/ice/rain/snow in the live constituent owner.
  !! water_enabled is the source thermal-activity projection, in that order,
  !! followed by graupel. It supplies metadata, not a calculated field.

  interface
    function output_exp(x) bind(c, name='exp') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function output_log(x) bind(c, name='log') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Validate native shape and workspace bounds before entering numerical work.
  !! fit and auxiliary have (pitch,source field capacity,local blocks).
  !! kind1 uses target pressures in Pa; kind5 uses model-level numbers.
  !! Only active rows change. Every source repeated pressure/math pass remains.
  !! Source-selected P24/L19/2048points is retained separately from compiled
  !! live bounds P1:24,L3:256,target1:4096. No numerical acceptance is claimed.
  integer(int32)function calculate_actual_output_grid_fields(request,inputs,configuration,fullpos,scalars,nlextrap,rh_parameters, &
                                                             targets, kind, fit, auxiliary, view_counters, calls) result(status)
  type(type_fprqdyn), target, intent(in) :: request
  type(native_output_grid_sources), intent(in) :: inputs
  type(grid_field_configuration), intent(in) :: configuration
  type(native_fullpos_state), intent(in) :: fullpos
  type(native_forecast_scalar_data), intent(in) :: scalars
  integer(int32), intent(in) :: nlextrap
  type(relative_humidity_parameters), intent(in) :: rh_parameters

  real(real64), intent(in) :: targets(:)
  integer(int32), intent(in) :: kind
  real(real64), intent(inout) :: fit(:, :, :), auxiliary(:, :, :)
  type(native_output_view_counters), intent(inout) :: view_counters
  integer(int64), intent(inout) :: calls
  integer :: pitch, levels, points, blocks, block, active, targets_count
  integer :: mi(3), si(3), j
  integer(int64) :: workspace
  status = 2
  if (.not. associated(inputs%geometry) .or. .not. associated(inputs%motion) .or. &
      .not. associated(inputs%constants) .or. .not. associated(inputs%constituents)) return
  if (.not. associated(inputs%geometry%vertical)) return
  if (.not. allocated(inputs%motion%gmv) .or. .not. allocated(inputs%motion%gmvs)) return
  if (.not. allocated(inputs%geometry%terrain%blocks) .or. &
      .not. allocated(inputs%geometry%spherical%blocked%gm)) return
  pitch = size(inputs%motion%gmv, 1); levels = size(inputs%motion%gmv, 2)
  blocks = size(inputs%motion%gmv, 4); points = inputs%geometry%partition%ngptot
  targets_count = size(targets)
  if (pitch < 1 .or. pitch > 24 .or. levels < 3 .or. levels > 256 .or. points < 1) return
  if (nlextrap < 1 .or. nlextrap > levels) return
  if (targets_count < 1 .or. targets_count > 4096 .or. (kind /= 1 .and. kind /= 5)) return
  if (int(blocks, int64) /= (int(points, int64) + pitch - 1)/pitch) return
  if (size(inputs%geometry%terrain%blocks) /= blocks) return
  if (any(shape(inputs%geometry%spherical%blocked%gm) /= [pitch, blocks])) return
  if (size(inputs%motion%gmvs, 1) /= pitch .or. size(inputs%motion%gmvs, 3) /= blocks) return
  if (size(inputs%constituents, 1) /= pitch .or. size(inputs%constituents, 2) /= levels .or. &
      size(inputs%constituents, 4) /= blocks) return
  if (.not. is_contiguous(inputs%constituents) .or. .not. is_contiguous(targets) .or. &
      .not. is_contiguous(fit) .or. .not. is_contiguous(auxiliary)) return
  mi = [inputs%motion%yt0%mt, inputs%motion%yt0%mu, inputs%motion%yt0%mv]
  si = [inputs%motion%yt0%msp, inputs%motion%yt0%mspl, inputs%motion%yt0%mspm]
  if (any(mi < 1) .or. any(mi > size(inputs%motion%gmv, 3))) return
  if (any(si < 1) .or. any(si > size(inputs%motion%gmvs, 2))) return
  if (any([configuration%aliases%yq, configuration%aliases%yl, configuration%aliases%yi, configuration%aliases%yr, &
           configuration%aliases%ys, configuration%aliases%yg, configuration%aliases%yh] < 0)) return
  if (any([configuration%aliases%yq, configuration%aliases%yl, configuration%aliases%yi, configuration%aliases%yr, &
           configuration%aliases%ys, configuration%aliases%yg, configuration%aliases%yh] > size(configuration%components))) return
  block
    integer :: a, k, alias_list(8)
    alias_list = [configuration%aliases%yq, configuration%aliases%yl, configuration%aliases%yi, &
                  configuration%aliases%yr, configuration%aliases%ys, configuration%aliases%yg, configuration%aliases%yh, &
                  configuration%aliases%yphycty]
    do a = 1, 8
      k = alias_list(a)
      if (k < 0 .or. k > size(configuration%components)) return
      if (k == 0) cycle
      if (configuration%components(k)%lactive /= 0) then
        if (configuration%components(k)%mp < 1 .or. configuration%components(k)%mp > size(inputs%constituents, 3)) return
      end if
    end do
  end block
  if (.not. allocated(request%nfptrdyn) .or. .not. allocated(request%iskp)) return
  if (request%nfposdyn < 0 .or. request%nfposdyn > 686) return
  do j = 1, request%nfposdyn
    if (request%nfptrdyn(j) < 1 .or. request%nfptrdyn(j) > 686) return
    select case (fullpos%yafn%tfp_dynds(request%nfptrdyn(j))%igrib)
    case (129, 130, 133, 135, 138, 152, 155, 157)
      if (fullpos%yafn%tfp_dynds(request%nfptrdyn(j))%igrib == 135 .or. &
          ((fullpos%yafn%tfp_dynds(request%nfptrdyn(j))%igrib == 155 .or. &
            fullpos%yafn%tfp_dynds(request%nfptrdyn(j))%igrib == 138) .and. request%iskp(request%nfptrdyn(j)) == 1)) then
        if (inputs%motion%yt0%mdiv < 1 .or. inputs%motion%yt0%mdiv > size(inputs%motion%gmv, 3)) return
      end if
      if (fullpos%yafn%tfp_dynds(request%nfptrdyn(j))%igrib == 138 .and. request%iskp(request%nfptrdyn(j)) == 1) then
        if (inputs%motion%yt0%mvor < 1 .or. inputs%motion%yt0%mvor > size(inputs%motion%gmv, 3)) return
      end if
    case default
      return
    end select
  end do
  if (.not. allocated(inputs%geometry%vertical%rintbf11) .or. &
      .not. allocated(inputs%geometry%vertical%vfe_rdetah)) return
  if (inputs%geometry%vertical%configuration%lvertfe /= 1 .or. &
      inputs%geometry%vertical%configuration%nvfe_intbc /= 3) return

  if (size(fit, 1) /= pitch .or. size(auxiliary, 1) /= pitch) return
  if (size(fit, 2) < request%nfpgt1 .or. size(auxiliary, 2) < request%nfpauxb) return
  if (size(fit, 3) /= blocks .or. size(auxiliary, 3) /= blocks) return
  if (.not. allocated(request%ll) .or. .not. allocated(request%ilvp)) return
  if (.not. allocated(inputs%geometry%vertical%valh) .or. .not. allocated(inputs%geometry%vertical%vbh)) return
  if (.not. allocated(inputs%geometry%vertical%vc) .or. .not. allocated(inputs%geometry%vertical%vaf) .or. &
      .not. allocated(inputs%geometry%vertical%vbf) .or. .not. allocated(inputs%geometry%vertical%vdela) .or. &
      .not. allocated(inputs%geometry%vertical%vdelb)) return
  if (size(inputs%geometry%vertical%valh) < levels + 1 .or. size(inputs%geometry%vertical%vbh) < levels + 1) return
  if (min(size(inputs%geometry%vertical%vc), size(inputs%geometry%vertical%vaf), &
          size(inputs%geometry%vertical%vbf), size(inputs%geometry%vertical%vdela), &
          size(inputs%geometry%vertical%vdelb)) < levels) return
  workspace = 8_int64*pitch*(90_int64*levels + 48_int64*targets_count + 64_int64)
  workspace = workspace + 4_int64*pitch*(6_int64*targets_count + 2_int64)
  if (inputs%budget_bytes <= workspace .or. inputs%budget_bytes > 68719476736_int64) return
  if (workspace > 33554432_int64) return
  do block = 1, blocks
    active = min(pitch, points - (block - 1)*pitch)
    if (.not. allocated(inputs%geometry%terrain%blocks(block)%orog) .or. &
        .not. allocated(inputs%geometry%terrain%blocks(block)%orogl) .or. &
        .not. allocated(inputs%geometry%terrain%blocks(block)%orogm)) return
    if (min(size(inputs%geometry%terrain%blocks(block)%orog), size(inputs%geometry%terrain%blocks(block)%orogl), &
            size(inputs%geometry%terrain%blocks(block)%orogm)) < active) return
  end do
  do block = 1, blocks
    active = min(pitch, points - (block - 1)*pitch)
    call calculate_block(request, inputs, configuration, fullpos, scalars, nlextrap, rh_parameters, &
                         targets, kind, pitch, levels, targets_count, block, active, &
                         fit(:, :, block), auxiliary(:, :, block), view_counters, status)
    if (status /= 0) return
  end do
  call increment_output_counter(calls)
  status = 0
  end function

  !> Own compiler-native local work after complete parent admission.
  !! The caller provides at least the declared32MiB stack-workspace bound.
  !! All pressure/temperature arrays preserve source half/full lower bounds.
  subroutine calculate_block(request, inputs, configuration, fullpos, scalars, nlextrap, rh_parameters, &
                             targets, kind, p, l, t, block, active, fit, auxiliary, counters, status)
    type(type_fprqdyn), target, intent(in) :: request
    type(native_output_grid_sources), intent(in) :: inputs
    type(grid_field_configuration), intent(in) :: configuration
    type(native_fullpos_state), intent(in) :: fullpos
    type(native_forecast_scalar_data), intent(in) :: scalars
    integer(int32), intent(in) :: nlextrap
    type(relative_humidity_parameters), intent(in) :: rh_parameters

    real(real64), intent(in) :: targets(:)
    integer(int32), intent(in) :: kind
    integer, intent(in) :: p, l, t, block, active
    real(real64), intent(inout) :: fit(:, :), auxiliary(:, :)
    type(native_output_view_counters), intent(inout) :: counters
    integer(int32), intent(out) :: status
    real(real64) :: half(p, 0:l), full(p, l), coefficients(p, l, 7)
    real(real64), target :: zero(p, l), graupel_hail(p, l)
    real(real64), pointer :: q(:, :), ql(:, :), qi(:, :), qr(:, :), qs(:, :), qg(:, :), qh(:, :), mass_source(:, :)
    integer :: water_alias(7), wa, parameter_code, field_code, vector_destination
    logical :: water_enabled(6), need(5), surface_field, vector_field, scalar_divergence, scalar_vorticity
    real(real64) :: u(p, l), v(p, l), divergence(p, 0:l), vorticity(p, 0:l), map_squared(p)
    real(real64) :: surface_dx(p), surface_dy(p), half_phi(p, 0:l), full_phi(p, l), continuity(p, 0:l, 5)
    real(real64) :: rh_model(p, l), saturation(p, l)
    real(real64) :: geopotential_output(p, t), rh_output(p, t), omega_output(p, t), u_output(p, t), v_output(p, t)
    real(real64) :: div_output(p, t), vor_output(p, t), inverse_pressure(p, l), inverse_delta(p, l)
    type(vertical_operator_matrices) :: tables
    real(real64) :: heat(p, l), gas(p, l), kappa(p, l), surface(p), tstar(p), tzero(p)
    real(real64) :: terrain(p), terrain_l(p), terrain_m(p)
    real(real64) :: xp(p, 0:l, 4), xpd(p, 0:l, 4), target_pressure(p, t), target_log(p, t)
    real(real64) :: standard_temperature(p, l + 1), standard_geopotential(p, l + 1)
    real(real64) :: temperature_output(p, t), humidity_output(p, t), log_surface(p)
    integer(int32) :: level_below(p, t, 4)
    logical :: below_full(p, t), below_half(p, t), any_below_full(t), any_below_half(t)
    type(hybrid_pressure_controls) :: pressure_control
    type(moist_air_constants) :: gas_control
    real(real64), volatile :: discarded, discarded_second, discarded_third
    real(real64) :: lapse
    integer :: i, k, model_level, temperature_index, u_index, v_index
    type(native_output_field_view) :: view
    integer(int32), pointer :: level_indices(:)
    integer :: field, field_level, destination, code, which

    call increment_output_counter(counters%calls(1))
    zero = 0.0_real64
    water_alias = [configuration%aliases%yq, configuration%aliases%yl, configuration%aliases%yi, &
                   configuration%aliases%yr, configuration%aliases%ys, configuration%aliases%yg, configuration%aliases%yh]
    call bind_gfl(water_alias(1), q)
    call bind_gfl(water_alias(2), ql)
    call bind_gfl(water_alias(3), qi)
    call bind_gfl(water_alias(4), qr)
    call bind_gfl(water_alias(5), qs)
    call bind_gfl(water_alias(6), qg)
    call bind_gfl(water_alias(7), qh)
    call bind_gfl(configuration%aliases%yphycty, mass_source)
    do k = 1, l
      do i = 1, active
        graupel_hail(i, k) = qg(i, k) + qh(i, k)
      end do
    end do
    do wa = 1, 5
      water_enabled(wa) = thermal_active(water_alias(wa))
    end do
    water_enabled(6) = thermal_active(water_alias(6)) .or. thermal_active(water_alias(7))
    need = .false.
    scalar_divergence = .false.; scalar_vorticity = .false.
    do field = 1, request%nfposdyn
      field_code = request%nfptrdyn(field)
      parameter_code = fullpos%yafn%tfp_dynds(field_code)%igrib
      if (fullpos%yafn%tfp_dynds(field_code)%llsrf) cycle
      select case (parameter_code)
      case (129)
        need(1) = .true.
      case (157)
        need(2) = .true.
      case (135)
        need(3) = .true.
      case (138, 155)
        if (request%iskp(field_code) == 2) then
          need(4) = .true.
        else
          need(5) = .true.
        end if
      end select
    end do
    tables%rintbf11 => inputs%geometry%vertical%rintbf11

    temperature_index = inputs%motion%yt0%mt
    u_index = inputs%motion%yt0%mu; v_index = inputs%motion%yt0%mv
    pressure_control%approximate_mode = inputs%geometry%vertical%configuration%ndlnpr
    pressure_control%finite_elements = inputs%geometry%vertical%configuration%lvertfe /= 0
    pressure_control%arithmetic_full_pressure = inputs%geometry%vertical%configuration%laprxpk /= 0
    pressure_control%top_pressure = inputs%geometry%vertical%toppres
    pressure_control%top_alpha = inputs%geometry%vertical%configuration%rhydr0
    pressure_control%dry_gas_constant = inputs%constants%rd
    pressure_control%dry_isochoric_heat_capacity = inputs%constants%rcvd
    gas_control%dry_gas_constant = inputs%constants%rd
    gas_control%dry_heat_capacity = inputs%constants%rcpd
    gas_control%vapour_gas_constant = inputs%constants%rv
    gas_control%vapour_heat_capacity = inputs%constants%rcpv
    gas_control%liquid_heat_capacity = inputs%constants%rcw
    gas_control%ice_heat_capacity = inputs%constants%rcs
    lapse = inputs%geometry%atmosphere%reference_tables(1)%gradient(1)
    discarded = lapse/inputs%constants%rg
    do i = 1, active
      terrain(i) = inputs%geometry%terrain%blocks(block)%orog(i)
      terrain_l(i) = inputs%geometry%terrain%blocks(block)%orogl(i)
      terrain_m(i) = inputs%geometry%terrain%blocks(block)%orogm(i)
      surface(i) = output_exp(inputs%motion%gmvs(i, inputs%motion%yt0%msp, block))
    end do
    call pressure_pass()
    if (status /= 0) return
    call ctstar(p, 1, active, inputs%motion%gmv(:, nlextrap, temperature_index, block), surface, full(:, nlextrap), &
                terrain, tstar, tzero, lapse, inputs%constants%rg, inputs%constants%rd, status)
    if (status /= 0) return
    do i = 1, active
      discarded = inputs%geometry%spherical%blocked%gm(i, block)*inputs%geometry%spherical%blocked%gm(i, block)
      discarded_second = terrain_l(i)*inputs%geometry%spherical%blocked%gm(i, block)
      discarded_third = terrain_m(i)*inputs%geometry%spherical%blocked%gm(i, block)
    end do
    do k = 1, l
      do i = 1, active
        discarded = inputs%motion%gmv(i, k, u_index, block)*inputs%geometry%spherical%blocked%gm(i, block)
        discarded = inputs%motion%gmv(i, k, v_index, block)*inputs%geometry%spherical%blocked%gm(i, block)
      end do
    end do
    call compute_moist_air_properties(gas_control, p, 1, active, l, water_enabled, status, &
                                      heat_capacity=heat, gas_constant=gas, kappa=kappa, &
                                      vapour=q, liquid=ql, ice=qi, rain=qr, snow=qs, graupel=graupel_hail)
    if (status /= 0) return
    do i = 1, active
      surface(i) = output_exp(inputs%motion%gmvs(i, inputs%motion%yt0%msp, block))
    end do
    call pressure_pass()
    if (status /= 0) return
    do i = 1, active
      map_squared(i) = inputs%geometry%spherical%blocked%gm(i, block)*inputs%geometry%spherical%blocked%gm(i, block)
      surface_dx(i) = surface(i)*inputs%motion%gmvs(i, inputs%motion%yt0%mspl, block)
      surface_dx(i) = surface_dx(i)*inputs%geometry%spherical%blocked%gm(i, block)
      surface_dy(i) = surface(i)*inputs%motion%gmvs(i, inputs%motion%yt0%mspm, block)
      surface_dy(i) = surface_dy(i)*inputs%geometry%spherical%blocked%gm(i, block)
    end do
    do k = 1, l
      do i = 1, active
        u(i, k) = inputs%motion%gmv(i, k, u_index, block)*inputs%geometry%spherical%blocked%gm(i, block)
        v(i, k) = inputs%motion%gmv(i, k, v_index, block)*inputs%geometry%spherical%blocked%gm(i, block)
        if (need(3) .or. scalar_divergence) divergence(i, k) = inputs%motion%gmv(i, k, inputs%motion%yt0%mdiv, block)*map_squared(i)
        if (scalar_vorticity) vorticity(i, k) = inputs%motion%gmv(i, k, inputs%motion%yt0%mvor, block)*map_squared(i)
        inverse_pressure(i, k) = 1.0_real64/full(i, k)
        inverse_delta(i, k) = coefficients(i, k, 2)
      end do
    end do
    if (need(1)) then
      half_phi(1:active, l) = terrain(1:active)
      call compute_geopotential(p, 1, active, l, .true., tables, &
                                int(inputs%geometry%vertical%configuration%nvfe_intbc), &
                                int(inputs%geometry%vertical%configuration%nvfe_derbc), gas, &
                             inputs%motion%gmv(:, :, temperature_index, block), coefficients(:, :, 3), half_phi, full_phi, status, &
                                alpha=coefficients(:, :, 4), metric=inputs%geometry%vertical%vfe_rdetah)
      if (status /= 0) return
    end if
    if (need(3)) then
      call compute_vertical_continuity(p, 1, active, l, .true., .false., &
                                       int(inputs%geometry%vertical%configuration%nvfe_intbc), &
                                       int(inputs%geometry%vertical%configuration%nvfe_derbc), tables, &
                                inputs%geometry%vertical%vbf, inputs%geometry%vertical%vdelb, inputs%geometry%vertical%vfe_rdetah, &
                                       u, v, divergence(:, 1:l), coefficients(:, :, 1), surface_dx, surface_dy, inverse_pressure, &
                                       continuity, status, mass_source=mass_source)
      if (status /= 0) return
    end if
    if (need(2)) then
      status = output_relative_humidity(1_int32, int(active, int32), &
                                        [fullpos%ynamfpsci%fprhmin, fullpos%ynamfpsci%fprhmax], rh_parameters, q, &
                                        inputs%motion%gmv(:, :, temperature_index, block), full, saturation, rh_model)
      if (status /= 0) return
    end if
    call ctstar(p, 1, active, inputs%motion%gmv(:, nlextrap, temperature_index, block), surface, full(:, nlextrap), &
                terrain, tstar, tzero, lapse, inputs%constants%rg, inputs%constants%rd, status)
    if (status /= 0) return
    do k = 1, t
      if (kind == 5) then
        model_level = int(targets(k))
        if (model_level < 1 .or. model_level > l) then
          status = 2
          return
        end if
      end if
      do i = 1, active
        if (kind == 5) then
          target_pressure(i, k) = full(i, model_level)
        else
          target_pressure(i, k) = targets(k)
        end if
        target_log(i, k) = output_log(target_pressure(i, k))
      end do
    end do
    call ppinit(p, 1, active, l, 4, half, full, xp, xpd, status)
    if (status /= 0) return
    call ppflev(p, 1, active, l, t, 4, target_pressure, half, full, level_below, below_full, below_half, &
                any_below_full, any_below_half, status)
    if (status /= 0) return
    call ppsta(inputs%constants, inputs%geometry%atmosphere%reference_tables(2), 'PPREF', p, 1, active, l + 1, 1, &
               xp(:, :, 2), xp(:, :, 4), standard_temperature, standard_geopotential, status)
    if (status /= 0) return
    if (kind == 1) then
      call ppq(p, 1, active, l, t, 1, 4, level_below, target_pressure, below_full, any_below_full, xp, xpd, q, &
               humidity_output, status=status)
      if (status /= 0) return
      if (need(4)) then
        call ppuv(p, 1, active, l, t, 1, 4, level_below, below_full, any_below_full, target_log, xp, xpd, u, v, &
                  u_output, v_output, scalars%lrppuv_cstext, scalars%lrppuv_callitpq, status)
        if (status /= 0) return
      end if
      call ppt(inputs%constants, inputs%geometry%atmosphere%reference_tables(2), lapse, inputs%old_postprocessing, &
               inputs%no_surface_temperature, p, 1, active, l, t, 1, 4, level_below, target_pressure, target_log, &
               below_full, below_half, any_below_full, any_below_half, .true., terrain, xp, xpd, tstar, tzero, gas, &
               inputs%motion%gmv(:, :, temperature_index, block), temperature_output, psttf=standard_temperature, status=status)
      if (status /= 0) return
      if (need(1)) then
        call ppgeop(inputs%constants, inputs%geometry%atmosphere%reference_tables(2), lapse, inputs%old_postprocessing, &
                    .true., tables, int(inputs%geometry%vertical%configuration%nvfe_intbc), &
                    int(inputs%geometry%vertical%configuration%nvfe_derbc), inputs%geometry%vertical%vfe_rdetah, &
                    p, 1, active, l, t, 1, 4, level_below, target_pressure, target_log, below_full, below_half, &
                    any_below_full, any_below_half, .true., terrain, xp, xpd, tstar, gas, coefficients(:, :, 3), &
                    coefficients(:, :, 4), inputs%motion%gmv(:, :, temperature_index, block), geopotential_output, &
                    standard_temperature, status)
        if (status /= 0) return
      end if
      if (need(2)) then
        call ppq(p, 1, active, l, t, 1, 4, level_below, target_pressure, below_full, any_below_full, xp, xpd, &
                 rh_model, rh_output, status=status)
        if (status /= 0) return
      end if
      if (need(3)) then
        call ppvvel(inputs%geometry%vertical%vetah, .true., p, 1, active, l, t, 1, 4, level_below, target_pressure, &
                    below_full, any_below_full, xp, xpd, inverse_delta, continuity(:, :, 1), continuity(:, 1:l, 2), &
                    omega_output, status, .false.)
        if (status /= 0) return
      end if
      if (scalar_divergence) then
        call pp2dint(p, 1, active, l, 4, t, 1, t, level_below, 2, below_full, any_below_full, target_pressure, &
                     xp, xpd, divergence, div_output, status)
        if (status /= 0) return
      end if
      if (scalar_vorticity) then
        call pp2dint(p, 1, active, l, 4, t, 1, t, level_below, 2, below_full, any_below_full, target_pressure, &
                     xp, xpd, vorticity, vor_output, status)
        if (status /= 0) return
      end if
    else
      do k = 1, t
        model_level = int(targets(k))
        do i = 1, active
          temperature_output(i, k) = inputs%motion%gmv(i, model_level, temperature_index, block)
          humidity_output(i, k) = q(i, model_level)
          if (need(1)) geopotential_output(i, k) = full_phi(i, model_level)
          if (need(2)) rh_output(i, k) = rh_model(i, model_level)
          if (need(3)) omega_output(i, k) = xp(i, model_level, 2)*continuity(i, model_level, 2)
          if (need(4)) then
            u_output(i, k) = u(i, model_level); v_output(i, k) = v(i, model_level)
          end if
          if (scalar_divergence) div_output(i, k) = divergence(i, model_level)
          if (scalar_vorticity) vor_output(i, k) = vorticity(i, model_level)
        end do
      end do
    end if
    if (need(2) .and. fullpos%ynamfpsci%lfprh100) then
      do k = 1, t
        do i = 1, active
          rh_output(i, k) = rh_output(i, k)*100.0_real64
        end do
      end do
    end if
    do which = 1, request%nfposdyn
      code = request%nfptrdyn(which)
      parameter_code = fullpos%yafn%tfp_dynds(code)%igrib
      surface_field = fullpos%yafn%tfp_dynds(code)%llsrf
      vector_field = request%iskp(code) == 2

      status = output_field_map(request, int(code, int32), view, counters)
      if (status /= 0) return
      if (view%level_count == 0) cycle
      if (view%level_count < 0 .or. view%level_count > t .or. .not. c_associated(view%level_indices)) then
        status = 2
        return
      end if
      call c_f_pointer(view%level_indices, level_indices, [int(view%level_count)])
      if (parameter_code == 152) then
        do i = 1, active
          log_surface(i) = output_log(surface(i))
        end do
      end if
      do field = 1, int(view%level_count)
        destination = int(view%index) + field - 1
        field_level = level_indices(field)
        if (.not. surface_field) then
          if (field_level < 1 .or. field_level > t) then
            status = 2
            return
          end if
        end if
        if (view%fit /= 0) then
          if (destination < 1 .or. destination > size(fit, 2)) then
            status = 2
            return
          end if
        else
          if (destination < 1 .or. destination > size(auxiliary, 2)) then
            status = 2
            return
          end if
        end if
        do i = 1, active
          select case (parameter_code)
          case (129)
            if (surface_field) then
              call store_value(terrain(i))
            else
              call store_value(geopotential_output(i, field_level))
            end if
          case (130)
            call store_value(temperature_output(i, field_level))
          case (133)
            call store_value(humidity_output(i, field_level))
          case (135)
            call store_value(omega_output(i, field_level))
          case (138, 155)
            if (vector_field) then
              call store_value(u_output(i, field_level)/inputs%geometry%spherical%blocked%gm(i, block))
              vector_destination = request%igt1(code, 2) + field - 1
              if (view%fit == 0 .or. vector_destination < 1 .or. vector_destination > size(fit, 2)) then
                status = 2
                return
              end if
              fit(i, vector_destination) = v_output(i, field_level)/inputs%geometry%spherical%blocked%gm(i, block)
            else if (parameter_code == 138) then
              call store_value(vor_output(i, field_level)/map_squared(i))
            else
              call store_value(div_output(i, field_level)/map_squared(i))
            end if
          case (152)
            call store_value(log_surface(i))
          case (157)
            call store_value(rh_output(i, field_level))
          end select
        end do
      end do
    end do
    status = 0
  contains
    logical function thermal_active(alias)
      integer, intent(in) :: alias
      thermal_active = .false.
      if (alias < 1 .or. alias > size(configuration%components)) return
      thermal_active = configuration%components(alias)%lthermact /= 0
    end function
    subroutine bind_gfl(alias, values)
      integer, intent(in) :: alias
      real(real64), pointer, intent(out) :: values(:, :)
      values => zero
      if (alias < 1 .or. alias > size(configuration%components)) return
      if (configuration%components(alias)%lactive == 0) return
      values => inputs%constituents(:, :, configuration%components(alias)%mp, block)
    end subroutine
    subroutine pressure_pass()
      half(1:active, l) = surface(1:active)
      call compute_hybrid_pressure_one_based(pressure_control, p, 1, active, l, &
                                             inputs%geometry%vertical%valh, inputs%geometry%vertical%vbh, half, status, &
                                             number_fields=7, field_index=[1, 2, 3, 4, 5, 6, 7], vc=inputs%geometry%vertical%vc, &
                                             full_a=inputs%geometry%vertical%vaf, full_b=inputs%geometry%vertical%vbf, &
                                             delta_a=inputs%geometry%vertical%vdela, delta_b=inputs%geometry%vertical%vdelb, &
                                             coefficients=coefficients, full_pressure=full)
    end subroutine
    subroutine store_value(value)
      real(real64), intent(in) :: value
      if (view%fit /= 0) then
        fit(i, destination) = value
      else
        auxiliary(i, destination) = value
      end if
    end subroutine
  end subroutine
end module
