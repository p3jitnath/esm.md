!> Complete source-ordered CALLPAR body; dependency bindings freeze separately.
!! This draft contains direct typed calls only. It is not a compiled milestone
!! until every named child module is resolved and the complete graph is linked.
submodule(forecast_complete_physics_parameterisation_sequence) complete_callpar_body
  use iso_c_binding, only: c_double
  use forecast_physics_state_arithmetic, only: state_update, state_increment, update_fields, qnegat
  use forecast_native_state_copy_binding, only: copy_native_runtime_physics_state
  use forecast_local_physics_work_storage, only: local_physics_options, initialize_fresh_local_chemistry_heads, &
                                                 initialize_runtime_local_physics_work, finish_runtime_local_physics_work
  use forecast_physics_work_types, only: gems_local_type
  use forecast_primitive_physics_layers, only: cloud_cover_surface_columns, visibility_layer
  use forecast_primitive_physics_layers_no_clock, only: cloud_radiation_layer_no_clock
  use forecast_native_record_radiative_flux_layer, only: radiative_flux_model_views, runtime_radiative_flux_layer
  use md2asm_runtime_mountain_wave_layer, only: runtime_mountain_wave_layer
  use md2asm_nonorographic_gravity_wave_launches, only: gwdragwms_layer
  use forecast_native_convection_layer, only: convection_layer_model_views, runtime_owned_convection_layer
  use saturation_humidity_mod, only: satur, numeric_maximum
  use convective_energy_diagnostics_mod, only: cuancape2
  use md2asm_record_cloud_saturation_adjustment, only: cloud_satadj
  use forecast_height_wind_interpolation, only: vdfvint
  use forecast_slow_physics_layer, only: sltend_layer
  use surface_field_configuration_port, only: surface_field_registry
  ! The following bindings name concrete required source stages. Their owners
  ! supply full native bodies; no stub, callback or original external is used.
  use forecast_native_surface_layers, only: callpar_surface_boundary, callpar_snow_initialization, &
                                            callpar_surface_radiation, callpar_surface_time_update
  use forecast_native_turbulence_layer, only: callpar_turbulence_layer => turbulence_layer
  use forecast_native_record_cloud_layer, only: cloud_layer
  use forecast_native_climatological_visibility_layer, only: callpar_climatological_visibility
  use forecast_cloud_weather_diagnostics, only: diag_clouds
  use forecast_native_methane_oxidation, only: methox
  use forecast_ozone_coefficient_copy, only: ozone_coefficient_options, copy_runtime_ozone_chemistry_fields
  use forecast_runtime_ozone_chemistry, only: calculate_runtime_ozone_tendency
  implicit none
  interface
    function scalar_exp(x) bind(c, name='exp') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function scalar_log(x) bind(c, name='log') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function scalar_remainder(x, y) bind(c, name='fmod') result(r)
      import c_double
      real(c_double), value :: x, y
      real(c_double) :: r
    end function
  end interface
contains
  module procedure callpar
  status = execute_callpar(context, inputs, providers, zag, zreco, .true.)
  end procedure
  module procedure callpar_runtime
  status = execute_callpar(context, inputs, providers, zag, zreco, .false.)
  end procedure
  !> One numerical body serves the frozen selected and explicit runtime entries.
  !! The runtime route uses actual grid dimensions and produced parameter values;
  !! its same-input numerical qualification remains separate and pending.
  integer(int32) function execute_callpar(context, inputs, providers, zag, zreco, selected) result(status)
    type(native_complete_physics_context), target, intent(inout) :: context
    type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
    type(callpar_provider_targets), intent(in) :: providers
    real(real64), intent(inout) :: zag(:), zreco(:)
    logical, intent(in) :: selected
    type(gems_local_type) :: local
    type(local_physics_options) :: local_options
    type(cloud_cover_surface_columns) :: cloud_columns
    type(radiative_flux_model_views) :: radiative_views
    type(convection_layer_model_views) :: convection_views
    type(ozone_coefficient_options) :: ozone_options
    real(real64), target :: empty_patterns_storage(0)
    real(real64), pointer :: patterns(:, :)
    integer(int32) :: p, l, first, last, block, step, start, j, k, plane, child_status
    integer(int64) :: time_bits, wave_bits
    integer(int32) :: top, base, accpr, acpr, gust, z0vd, z0vf, lz0hvd, lz0hvf, land, hstd, forest, sigma, &
                      snow_mass, snow_density, water, skin, u100, v100, u200, v200, two_temperature, two_dewpoint
    integer(int32) :: q_index, a_index, l_index, i_index, r_index, s_index, o3_index, tke_index
    real(real64), volatile :: inverse_gravity, inverse_cp, a, b, c, e, clock_seconds
    real(real64) :: timestep
    logical :: local_owned, diagnose, cloud_due, radiation_due
    status = 2; local_owned = .false.
    if (.not. associated(inputs%records%model) .or. .not. associated(inputs%physics)) return
    if (.not. associated(inputs%records%geometry) .or. .not. associated(inputs%records%surface_metadata)) return
    if (.not. associated(providers%physical) .or. .not. associated(providers%thermal)) return
    if (.not. associated(providers%stability) .or. .not. associated(providers%physics3)) return
    if (.not. associated(providers%stochastic_configuration)) return
    if (.not. associated(providers%current_step) .or. .not. associated(providers%initial_step)) return
    if (.not. associated(providers%hook_enabled) .or. .not. associated(providers%scmec_enabled)) return
    if (.not. associated(inputs%providers)) return
    if (.not. associated(inputs%providers%physical, providers%physical)) return
    if (.not. associated(inputs%providers%thermal, providers%thermal)) return
    if (.not. associated(inputs%providers%current_step, providers%current_step)) return
    if (.not. associated(inputs%providers%initial_step, providers%initial_step)) return
    if (inputs%providers%byte_limit /= providers%byte_limit) return
    if (.not. associated(providers%rslwx)) return
    if (.not. associated(providers%chem_light_active)) return
    if (.not. associated(inputs%stochastic_physics)) return
    if (.not. associated(providers%runtime_scalars)) return
    if (.not. associated(inputs%physics%surface) .or. .not. associated(context%surface_variables)) return
    if (providers%hook_enabled) return
    if (.not. context%initialized .or. .not. context%block_open) return
    block = context%last_block
    p = context%dimensions%klon; l = context%dimensions%klev
    first = context%dimensions%kidia; last = context%dimensions%kfdia
    if (p < 1 .or. p > 128 .or. l < 6 .or. l > 137 .or. first /= 1 .or. last < 0 .or. last > p) return
    if (selected .and. (p /= 24 .or. l /= 19)) return
    if (dimension_workspace_too_large(p, l)) return
    if (context%dimensions%kfldx /= 0) return
    if (size(zag) /= p .or. size(zreco) /= p) return
    if (.not. is_contiguous(zag) .or. .not. is_contiguous(zreco)) return
    if (block < 1) return
    if (.not. associated(context%records%state_t0) .or. .not. associated(context%records%tendency_dyn)) return
    if (.not. associated(context%records%tendency_cml) .or. .not. associated(context%records%state_tmp)) return
    if (.not. associated(context%records%tendency_tmp) .or. .not. associated(context%records%tendency_vdf)) return
    if (.not. associated(context%records%tendency_satadj) .or. .not. associated(context%records%tendency_loc)) return
    if (.not. associated(context%records%previous_state)) return
    step = providers%current_step; start = providers%initial_step
    if (step < 0 .or. step > 25) return
    associate (model => inputs%records%model, parameters => inputs%physics, physical => providers%physical, &
               thermal => providers%thermal, d => context%dimensions, aux => context%auxiliary, rad => context%radiation, &
               surface => context%surface, surfl => context%surface_local, auxl => context%auxiliary_local, &
               keys => context%keys, flux => context%flux, diag => context%diagnostics, &
               state0 => context%records%state_t0, cml => context%records%tendency_cml, dyn => context%records%tendency_dyn, &
               tmp => context%records%state_tmp, tendency_tmp => context%records%tendency_tmp, &
               vdf => context%records%tendency_vdf, satadj => context%records%tendency_satadj, loc => context%records%tendency_loc)
      timestep = model%physics_auxiliary%tsphy
      time_bits = transfer(timestep, 0_int64)
      wave_bits = transfer(parameters%nonorographic_gravity_wave%gtphygwwms, 0_int64)
      if (time_bits <= 0_int64 .or. shiftr(time_bits, 52) == 2047_int64) return
      if (wave_bits <= 0_int64 .or. shiftr(wave_bits, 52) == 2047_int64) return
      if (selected .and. wave_bits /= transfer(7200.0_real64, 0_int64)) return
      if (selected .and. transfer(timestep, 0_int64) /= int(z'40ac200000000000', int64)) return
      ! The selected source has full nonlinear physics and no stochastic or active
      ! chemistry/aerosol tracers. These source admissions precede all writes.
      if (model%physics%linear_ecmwf%lphylin .or. model%physics%linear_ecmwf%lphysfclin) return
      if (.not. model%physics%ecmwf_physics%leradi .or. .not. model%physics%ecmwf_physics%lerads) return
      if (.not. model%physics%ecmwf_physics%leradimpl .or. .not. model%physics%ecmwf_physics%lecumf) return
      if (.not. model%physics%ecmwf_physics%levdif .or. .not. model%physics%ecmwf_physics%lesurf) return
      if (.not. model%physics%ecmwf_physics%legwdg .or. .not. model%physics%ecmwf_physics%legwwms) return
      if (.not. model%physics%ecmwf_physics%lepcld .or. .not. model%physics%ecmwf_physics%lemethox) return
      if (.not. model%physics%ecmwf_physics%lslphy) return
      if (model%physics%ecmwf_physics%levdifsl .or. model%physics%ecmwf_physics%lecond) return
      if (model%physics%ecmwf_physics%leclipqt0 .or. model%physics%ecmwf_physics%leclipcldt0) return
      if (model%physics%ecmwf_physics%lbud23 .or. model%physics%ecmwf_physics%lextratend) return
      if (parameters%radiation%radiation%lecsrad .or. model%physics%ecmwf_physics%lerain) return
      if (model%physics%ecmwf_physics%lelight) return
      if (selected .and. model%physics%ecmwf_physics%leo3ch) return
      if (model%physics%ecmwf_physics%ldiagturb_ec .or. model%physics%ecmwf_physics%lductdia) return
      if (model%physics%ecmwf_physics%lemwave) return
      if (.not. model%physics%cloud%lcldbud_timeint) return
      if (parameters%convection_switches%lecumfs) return
      if (providers%stochastic_configuration%lspp .or. providers%stochastic_configuration%sm%nrftotal /= 0) return
      if (providers%chem_light_active) return
      if (model%physics%ecmwf_physics%lbudcycle) return
      if (.not. model%physics%ecmwf_physics%ledcld .or. .not. model%physics%ecmwf_physics%leqngt) return
      if (.not. model%physics%ecmwf_physics%lesnml .or. model%physics%ecmwf_physics%nsnmlws /= 2) return
      if (model%physics%ecmwf_physics%leocml .or. .not. model%physics%ecmwf_physics%leflake) return
      local_options%naero = model%fields%alias_controls%naero
      local_options%nchem = model%fields%alias_controls%nchem
      local_options%nchem_dv = model%fields%settings%nchem_dv
      local_options%nghg = model%fields%alias_controls%nghg
      local_options%ngems = model%fields%ngems
      local_options%nactaero = model%fields%settings%nactaero
      local_options%lstoph_casbs = inputs%stochastic_physics%lstoph_casbs
      local_options%lstoph_spbs = inputs%stochastic_physics%lstoph_spbs
      local_options%leflake = model%physics%ecmwf_physics%leflake
      local_options%leocml = model%physics%ecmwf_physics%leocml
      if (any([model%fields%settings%nactaero, model%fields%alias_controls%naero, &
               model%fields%alias_controls%nchem, model%fields%alias_controls%nghg, model%fields%ngems] /= 0)) return
      if (selected) then
        if (model%fields%registration%ndim /= 17 .or. model%fields%registration%ndim1 /= 15) return
        if (parameters%convection%njkt3 /= 17 .or. parameters%convection%njkt4 /= 15) return
      end if
      if (parameters%convection%njkt3 < 1 .or. parameters%convection%njkt3 > l) return
      if (parameters%convection%njkt4 < 1 .or. parameters%convection%njkt4 > l) return
      if (.not. associated(inputs%arrays%gflt1) .or. .not. associated(inputs%arrays%saved_tendencies)) return
      if (.not. associated(inputs%arrays%gflslp)) return
      if (size(inputs%arrays%gflt1, 4) < block .or. size(inputs%arrays%saved_tendencies, 4) < block) return
      if (size(inputs%arrays%gflslp, 4) < block) return
      top = catalog_index(inputs%records%surface_metadata, 'YSD_VN%YTOP', 1)
      base = catalog_index(inputs%records%surface_metadata, 'YSD_VN%YBAS', 1)
      acpr = catalog_index(inputs%records%surface_metadata, 'YSD_VN%YACPR', 1)
      accpr = catalog_index(inputs%records%surface_metadata, 'YSD_VN%YACCPR', 1)
      gust = catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y10FGCV', 1)
      z0vd = catalog_index(inputs%records%surface_metadata, 'YSD_VD%YZ0F', 1)
      z0vf = catalog_index(inputs%records%surface_metadata, 'YSD_VF%YZ0F', 1)
      lz0hvd = catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLZ0H', 1)
      lz0hvf = catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLZ0H', 1)
      land = catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLSM', 1)
      hstd = catalog_index(inputs%records%surface_metadata, 'YSD_VF%YGETRL', 1)
      forest = catalog_index(inputs%records%surface_metadata, 'YSD_VF%YSDFOR', 1)
      sigma = catalog_index(inputs%records%surface_metadata, 'YSD_VF%YSIG', 1)
      snow_mass = catalog_index(inputs%records%surface_metadata, 'YSP_SG%YF', 3)
      snow_density = catalog_index(inputs%records%surface_metadata, 'YSP_SG%YR', 3)
      water = catalog_index(inputs%records%surface_metadata, 'YSP_RR%YW', 3)
      skin = catalog_index(inputs%records%surface_metadata, 'YSP_RR%YT', 3)
      u100 = catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y100U', 1)
      v100 = catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y100V', 1)
      u200 = catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y200U', 1)
      v200 = catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y200V', 1)
      two_temperature = catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y2T', 1)
      two_dewpoint = catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y2D', 1)
      cloud_columns%ccc = catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCCC', 1)
      cloud_columns%hcc = catalog_index(inputs%records%surface_metadata, 'YSD_VD%YHCC', 1)
      cloud_columns%lcc = catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLCC', 1)
      cloud_columns%mcc = catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMCC', 1)
      cloud_columns%tcc = catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCC', 1)
      if (any([top, base, acpr, accpr, gust, z0vd, z0vf, lz0hvd, lz0hvf, land, hstd, forest, sigma, &
               snow_mass, snow_density, water, skin, u100, v100, u200, v200, two_temperature, two_dewpoint, &
               cloud_columns%ccc, cloud_columns%hcc, cloud_columns%lcc, cloud_columns%mcc, cloud_columns%tcc] < 1)) return
      q_index = model%fields%aliases%yq; a_index = model%fields%aliases%ya
      l_index = model%fields%aliases%yl; i_index = model%fields%aliases%yi
      r_index = model%fields%aliases%yr; s_index = model%fields%aliases%ys
      o3_index = model%fields%aliases%yo3; tke_index = model%fields%aliases%ytke
      if (any([q_index, a_index, l_index, i_index, r_index, s_index, o3_index, tke_index] < 1)) return
      if (any([q_index, a_index, l_index, i_index, r_index, s_index, o3_index, tke_index] > size(model%fields%components))) return
      ! BEGIN exact named translation of all sixty selected source model guards.
      if (parameters%radiation%aerosol_atmosphere%laerdiag1) return
      if (.not. parameters%radiation%radiation%laervisi) return
      if (.not. parameters%radiation%radiation%lapproxlwupdate) return
      if (model%physics%ecmwf_physics%lbud23) return
      if (model%physics%ecmwf_physics%lbudcycle) return
      if (model%physics%ecmwf_physics%leclipcldt0) return
      if (model%physics%ecmwf_physics%leclipqt0) return
      if (model%physics%ecmwf_physics%lecond) return
      if (parameters%radiation%radiation%lecsrad) return
      if (.not. model%physics%ecmwf_physics%lecumf) return
      if (parameters%convection_switches%lecumfs) return
      if (.not. model%physics%ecmwf_physics%ledcld) return
      if (.not. model%physics%ecmwf_physics%legwdg) return
      if (.not. model%physics%ecmwf_physics%legwwms) return
      if (model%physics%ecmwf_physics%lelight) return
      if (.not. model%physics%ecmwf_physics%lemethox) return
      if (model%physics%ecmwf_physics%lemwave) return
      if (selected .and. model%physics%ecmwf_physics%leo3ch) return
      if (.not. model%physics%ecmwf_physics%lepcld) return
      if (.not. model%physics%ecmwf_physics%leqngt) return
      if (.not. model%physics%ecmwf_physics%leradi) return
      if (.not. model%physics%ecmwf_physics%leradimpl) return
      if (.not. model%physics%ecmwf_physics%lerads) return
      if (model%physics%ecmwf_physics%lerain) return
      if (.not. model%physics%ecmwf_physics%lesnml) return
      if (.not. model%physics%ecmwf_physics%lesurf) return
      if (.not. model%physics%ecmwf_physics%levdif) return
      if (model%physics%ecmwf_physics%levdifsl) return
      if (model%physics%ecmwf_physics%lextratend) return
      if (model%climate%lnemolimput) return
      if (model%climate%lnemolimthk) return
      if (model%physics%linear_ecmwf%lphylin) return
      if (model%physics%linear_ecmwf%lphysfclin) return
      if (.not. model%physics%ecmwf_physics%lslphy) return
      if (inputs%stochastic_physics%lstoph_casbs) return
      if (inputs%stochastic_physics%lstoph_spbs) return
      if (inputs%stochastic_physics%lvortcon) return
      if (model%fields%settings%nactaero /= 0_int32) return
      if (model%physics%cloud%naercld /= 0_int32) return
      if (model%fields%alias_controls%naero /= 0_int32) return
      if (model%fields%alias_controls%nchem /= 0_int32) return
      if (model%fields%ngems /= 0_int32) return
      if (model%fields%alias_controls%nghg /= 0_int32) return
      if (parameters%radiation%radiation%nradfr < 1_int32) return
      if (selected .and. parameters%radiation%radiation%nradfr /= 1_int32) return
      if (model%physics%ecmwf_physics%nsnmlws /= 2_int32) return
      if (model%physics_dimensions%nvextrdyn /= 0_int32) return
      if (inputs%lspsdt) return
      if (providers%stochastic_configuration%lspp) return
      if (model%physics%ecmwf_physics%ldiagturb_ec) return
      if (model%physics%ecmwf_physics%lductdia) return
      if (.not. model%physics%cloud%lcldbud_timeint) return
      if (inputs%cellular%active) return
      if (selected) then
        if (parameters%convection%njkt3 /= 17_int32) return
      end if
      if (selected) then
        if (parameters%convection%njkt4 /= 15_int32) return
      end if
      if (providers%chem_light_active) return
      if (parameters%orographic_gravity_wave%ldiag_strato) return
      if (inputs%stochastic_physics%lforcenl) return
      if (parameters%radiation%ultraviolet%luvproc) return
      if (.not. model%dynamics%lslag) return
      if (.not. model%dynamics%ltwotl) return
      ! END exact named selected source model guards.
      ! The actual ozone branch borrows its one monthly owner and model declination.
      if (model%physics%ecmwf_physics%leo3ch) then
        if (.not. associated(providers%ozone_chemistry) .or. .not. associated(providers%solar_declination)) return
        if (.not. allocated(providers%ozone_chemistry%toz2dl)) return
        ozone_options%coefficient_count = model%physics_dimensions%nvclis
        ozone_options%monthly_groups = model%physics_dimensions%ntoz2d
        ozone_options%three_dimensional_groups = model%physics_dimensions%ntoz3d
        if (ozone_options%coefficient_count /= 7 .or. ozone_options%monthly_groups /= 1 .or. &
            ozone_options%three_dimensional_groups /= 0) return
        if (size(providers%ozone_chemistry%toz2dl, 1) /= 7*l .or. &
            size(providers%ozone_chemistry%toz2dl, 2) /= inputs%records%geometry%dimensions%ndglg + 4) return
      end if

      ! Retain both source reciprocal preparations, including the otherwise unused
      ! gravity reciprocal, before the first local-work allocation.
      inverse_gravity = 1.0_real64/physical%rg
      inverse_cp = 1.0_real64/physical%rcpd
      call initialize_fresh_local_chemistry_heads(local)
      child_status = initialize_runtime_local_physics_work(d, local_options, keys, auxl, surfl, local, rad, &
                                                           surface%psd_vn(:, top), surface%psd_vn(:, base), providers%byte_limit)
      if (child_status /= 0) then
        status = child_status; return
      end if
      local_owned = .true.
      if (.not. model%physics%ecmwf_physics%leo3ch) cml%o3 = 0.0_real64
      status = copy_native_runtime_physics_state(d, dyn, cml, .false.); if (status /= 0) goto 900
      if (step == start) then
        do j = first, last
          surface%psd_vn(j, top) = 1.0_real64
        end do
        do j = first, last
          surface%psd_vn(j, base) = 1.0_real64
        end do
        do j = first, last
          surface%psd_vn(j, acpr) = 0.0_real64
        end do
        do j = first, last
          surface%psd_vn(j, accpr) = 0.0_real64
        end do
        do j = first, last
          surface%psd_vd(j, gust) = 0.0_real64
        end do
        do j = first, last
          surface%psd_vd(j, z0vd) = surface%psd_vf(j, z0vf)
        end do
        do j = first, last
          surface%psd_vd(j, lz0hvd) = surface%psd_vf(j, lz0hvf)
        end do
        do j = first, last
          surface%psd_vn(j, acpr) = 0.0_real64
        end do
        do j = first, last
          auxl%ibasc(j) = 1
        end do
        do j = first, last
          auxl%itopc(j) = 1
        end do
      end if
      call state_update(model%physics_auxiliary, d, state0, cml, tmp)
      do k = 1, l
        do j = first, last
          auxl%zlisum(j, k) = 0.0_real64
        end do
      end do
      do k = 1, d%klevsn
        do j = first, last
          surfl%zsnm1m(j, k) = surface%psp_sg(j, k, snow_mass)
        end do
      end do
      do k = 1, d%klevsn
        do j = first, last
          surfl%zrsnm1m(j, k) = surface%psp_sg(j, k, snow_density)
        end do
      end do
      do j = first, last
        local%zaz0m(j) = surface%psd_vd(j, z0vd)/physical%rg
      end do
      do j = first, last
        local%zaz0h(j) = scalar_exp(surface%psd_vd(j, lz0hvd))
      end do
      do j = first, last
        surfl%zwlm1m(j) = surface%psp_rr(j, water)
      end do
      do j = first, last
        if (surface%psd_vf(j, land) > 0.5_real64) then
          surface%phstd(j) = surface%psd_vf(j, hstd)/physical%rg
          surfl%zhsdfor(j) = surface%psd_vf(j, forest)
        else
          surface%phstd(j) = 0.0_real64
          surfl%zhsdfor(j) = 0.0_real64
          surface%psd_vf(j, sigma) = 0.0_real64
        end if
      end do
      call callpar_surface_boundary(inputs, d, aux, keys, surface, surfl, status)
      if (status /= 0) goto 900
      if (step == start .and. d%klevsn > 1) then
        call callpar_snow_initialization(inputs, d, surface, surfl, aux, status)
        if (status /= 0) goto 900
      end if
      diagnose = interval_due(step, start, timestep, physical%rhour)
      call callpar_surface_radiation(inputs, d, aux, tmp, keys, auxl, surface, surfl, status)
      if (status /= 0) goto 900
      status = satur(physical, thermal, first, last, p, d%ktdia, l, .false., aux%paprsf, state0%t, diag%pqsat, 2_int32)
      if (status /= 0) goto 900
      if (selected) then
        cloud_due = .true.; radiation_due = .true.
      else
        cloud_due = cloud_diagnostics_due(step, timestep, physical%rhour, parameters%radiation%radiation%nradfr)
        radiation_due = mod(step, parameters%radiation%radiation%nradfr) == 0
      end if
      if (cloud_due) then
        call cloud_radiation_layer_no_clock(physical, parameters%radiation%ecrad%config, parameters%radiation%radiation, &
                                            parameters%radiation%gases, parameters%cloud, d, aux, tmp, surface, rad, cloud_columns)
      end if
      if (radiation_due) then
        do j = first, last
          rad%pedro(j) = surface%psp_rr(j, skin)
        end do
      else
        do k = 1, l
          do j = first, last
            rad%pneb(j, k) = 0.0_real64
            rad%pqli(j, k) = 0.0_real64
            rad%pqice(j, k) = 0.0_real64
          end do
        end do
        do j = first, last
          flux%pfrsoc(j, 0) = 0.0_real64
          flux%pfrthc(j, 0) = 0.0_real64
          flux%pfrsoc(j, 1) = 0.0_real64
          flux%pfrthc(j, 1) = 0.0_real64
        end do
      end if
      do j = first, last
        auxl%ztskrad(j) = surface%psp_rr(j, skin)
      end do
      radiative_views%radiation => parameters%radiation%radiation
      radiative_views%radiation_diagnostics => parameters%radiation%gases
      radiative_views%physics2 => model%physics_auxiliary
      radiative_views%physics3 => providers%physics3
      radiative_views%physics_options => model%physics%ecmwf_physics
      radiative_views%step => providers%current_step
      radiative_views%hook_enabled => providers%hook_enabled
      call runtime_radiative_flux_layer(skin, radiative_views, providers%stochastic_configuration, d, aux, &
           state0, tmp, surface, surfl, rad, auxl, flux, loc, context%perturbation, physical, model%dynamical_core, thermal, status)
      if (status /= 0) goto 900
      if (diagnose) then
        call callpar_climatological_visibility(physical, thermal, parameters, model, inputs%records%surface_metadata, &
                                               d, aux, state0, tmp, surface, local, providers%byte_limit, status)
        if (status /= 0) goto 900
      end if
      call state_increment(d, cml, pa_t=loc%t)
      status = copy_native_runtime_physics_state(d, cml, tendency_tmp, .false.); if (status /= 0) goto 900
      call runtime_mountain_wave_layer(physical, context%surface_variables, model%physics%linear_ecmwf, &
                                       parameters%orographic_gravity_wave, d, aux, state0, surface, auxl, status)
      if (status /= 0) goto 900
      call callpar_turbulence_layer(physical, thermal, providers%stability, parameters, model, &
                                    context%surface_variables, providers%runtime_scalars, providers%scmec_enabled, &
                                  model%climate%lnemolimthk, parameters%radiation%gases%rcco2, providers%stochastic_configuration, &
                                    model%dynamical_core%rpldare, model%dynamical_core%rplrg, timestep, step, &
                                    d, aux, state0, tendency_tmp, rad, context%perturbation, auxl, &
                      local, surface, surfl, flux, diag, context%perturbation_local, keys, context%surface_diagnostics, loc, status)
      if (status /= 0) goto 900
      call state_increment(d, cml, pa_u=loc%u, pa_v=loc%v, pa_t=loc%t, pa_q=loc%q, pa_a=loc%a, &
                           pa_ql=loc%cld(:, :, 1), pa_qi=loc%cld(:, :, 2), pa_tke=loc%tke)
      status = copy_native_runtime_physics_state(d, loc, vdf, .false.); if (status /= 0) goto 900
      do k = 1, l
        do j = first, last
          auxl%zlcrit_aer(j, k) = 0.0_real64
        end do
      end do
      do k = 1, l
        do j = first, last
          auxl%zicrit_aer(j, k) = 0.0_real64
        end do
      end do
      do k = 1, l
        do j = first, last
          auxl%zre_liq(j, k) = 0.0_real64
        end do
      end do
      do k = 1, l
        do j = first, last
          auxl%zre_ice(j, k) = 0.0_real64
        end do
      end do
      do k = 1, l
        do j = first, last
          auxl%zccn(j, k) = 0.0_real64
        end do
      end do
      do k = 1, l
        do j = first, last
          auxl%znice(j, k) = 0.0_real64
        end do
      end do
      call state_update(model%physics_auxiliary, d, state0, cml, tmp)
      convection_views%physics2 => model%physics_auxiliary
      convection_views%stochastic => providers%stochastic_configuration
      convection_views%active_aerosols => model%fields%settings%nactaero
      convection_views%chem_light_active => providers%chem_light_active
      status = runtime_owned_convection_layer(physical, thermal, model%dynamical_core%rplrg, model%dynamical_core%rpldare, &
             parameters, model%physics, step, inputs%records%surface_metadata, convection_views, d, .true., state0, cml, dyn, aux, &
                                      context%perturbation, keys, diag, auxl, context%perturbation_local, flux, surface, local, loc)
      if (status /= 0) goto 900
      do j = first, last
        surface%psd_vd(j, gust) = 0.0_real64
        if (diag%pcape(j) > 25.0_real64) then
          if (diag%itype(j) == 1) then
            k = parameters%convection%njkt4
            a = tmp%u(j, k)*tmp%u(j, k); b = tmp%v(j, k)*tmp%v(j, k)
            a = a + b; a = sqrt(a)
            k = parameters%convection%njkt3
            c = tmp%u(j, k)*tmp%u(j, k); e = tmp%v(j, k)*tmp%v(j, k)
            c = c + e; c = sqrt(c); a = a - c
            a = numeric_maximum(a, 0.0_real64); a = 0.3_real64*a
            surface%psd_vd(j, gust) = a
            diag%pi10fg(j) = diag%pi10fg(j) + a
          end if
        end if
      end do
      diagnose = interval_due(step, start, timestep, physical%rhour)
      if (diagnose) then
        call cuancape2(physical, thermal, parameters%convection, model%physics%linear_ecmwf, first, last, p, l, &
                       aux%prsf1, aux%prs1, state0%t, state0%q, diag%zcape, diag%pcin, diag%ppdepl)
      else
        diag%pcin = 0.0_real64; diag%zcape = 0.0_real64; diag%ppdepl = 0.0_real64
      end if
      do j = first, last
        surface%psd_vn(j, top) = real(auxl%itopc(j), real64) + 0.01_real64
        surface%psd_vn(j, base) = real(auxl%ibasc(j), real64) + 0.01_real64
      end do
      call state_increment(d, cml, pa_t=loc%t, pa_q=loc%q, pa_u=loc%u, pa_v=loc%v)
      patterns(1:p, 1:0) => empty_patterns_storage
      call cloud_satadj(physical, thermal, model%physics%cloud, model%physics%linear_ecmwf, parameters%convection, &
                        model%physics%ecmwf_physics, providers%stochastic_configuration, first, last, p, l, diag%itype, &
                        timestep, aux%prsf1, aux%prs1, state0%t, state0%q, state0%a, state0%cld(:, :, 1), state0%cld(:, :, 2), &
                        cml%t, cml%q, cml%a, cml%cld(:, :, 1), cml%cld(:, :, 2), rad%phrsw, rad%phrlw, vdf%t, vdf%q, &
                        diag%pmfu, diag%pmfd, diag%zludeli, aux%pvervel, patterns, &
                        loc%t, loc%q, loc%a, loc%cld(:, :, 1), loc%cld(:, :, 2), surface%psd_xa, d%kfldx)
      call state_increment(d, cml, pa_t=loc%t, pa_q=loc%q, pa_a=loc%a, pa_ql=loc%cld(:, :, 1), pa_qi=loc%cld(:, :, 2))
      status = copy_native_runtime_physics_state(d, loc, satadj, .false.); if (status /= 0) goto 900
      status = cloud_layer(physical, thermal, providers%scmec_enabled, providers%hook_enabled, land, &
                           model%physics%cloud, parameters%convection, model%physics%linear_ecmwf, model%physics_auxiliary, &
                           parameters%radiation%radiation, model%physics%ecmwf_physics, parameters%diffusion, &
                           providers%stochastic_configuration, model%fields, d, .true., aux, context%perturbation, &
                           state0, cml, dyn, vdf, rad, surface, keys, auxl, flux, diag, context%variables%fsd, loc)
      if (status /= 0) goto 900
      call state_increment(d, cml, pa_t=loc%t, pa_q=loc%q, pa_a=loc%a, pa_ql=loc%cld(:, :, 1), &
                           pa_qi=loc%cld(:, :, 2), pa_qr=loc%cld(:, :, 3), pa_qs=loc%cld(:, :, 4))
      diagnose = interval_due(step, start, timestep, parameters%nonorographic_gravity_wave%gtphygwwms)
      if (diagnose) then
        call state_update(model%physics_auxiliary, d, state0, cml, tmp)
        call gwdragwms_layer(physical, inputs%records%geometry%atmosphere, parameters%orographic_gravity_wave, &
         parameters%nonorographic_gravity_wave, d, tmp, aux, flux, context%variables%nogw(1)%p, context%variables%nogw(2)%p, status)
        if (status /= 0) goto 900
      end if
      do k = 1, l
        do j = first, last
          a = tmp%u(j, k)*context%variables%nogw(1)%p(j, k)
          b = tmp%v(j, k)*context%variables%nogw(2)%p(j, k)
          a = a + b; a = -a; loc%t(j, k) = a*inverse_cp
          loc%u(j, k) = context%variables%nogw(1)%p(j, k)
          loc%v(j, k) = context%variables%nogw(2)%p(j, k)
        end do
      end do
      call state_increment(d, cml, pa_t=loc%t, pa_u=loc%u, pa_v=loc%v)
      diagnose = interval_due(step, start, timestep, physical%rhour)
      call diag_clouds(physical, thermal, parameters%convection, first, last, p, l, diagnose, &
                       keys%llcum, diag%icbot, diag%ictop, aux%prsf1, aux%prs1, aux%pgeom1, aux%pgeomh, &
                       state0%t, state0%q, state0%cld(:, :, 1), state0%cld(:, :, 2), state0%a, &
                       flux%pfplcl, flux%pfplcn, flux%pfplsl, flux%pfplsn, auxl%zrainfrac_toprfz, &
                       surface%psd_vd(:, two_temperature), surface%psd_vd(:, two_dewpoint), &
                       diag%pcbase, diag%pcbasea, diag%pctopc, diag%p0degl, diag%pm10degl, diag%pconvind, &
                       diag%pprectype, diag%pfzra, diag%pztwetb, diag%ptropotp, status)
      if (status /= 0) goto 900
      call vdfvint(first, last, p, l, state0%u, state0%v, aux%pgeom1, 100.0_real64, &
                   surface%psd_vd(:, u100), surface%psd_vd(:, v100), physical%rg, model%dynamical_core%rplrg, status)
      if (status /= 0) goto 900
      call vdfvint(first, last, p, l, state0%u, state0%v, aux%pgeom1, 200.0_real64, &
                   surface%psd_vd(:, u200), surface%psd_vd(:, v200), physical%rg, model%dynamical_core%rplrg, status)
      if (status /= 0) goto 900
      call state_update(model%physics_auxiliary, d, state0, cml, tmp)
      loc%q = 0.0_real64
      call methox(physical, parameters%methane, first, last, p, l, tmp%q, loc%q, aux%prsf1, status)
      if (status /= 0) goto 900
      call state_increment(d, cml, pa_q=loc%q)
      call state_update(model%physics_auxiliary, d, state0, cml, tmp)
      if (model%physics%ecmwf_physics%leo3ch) then
        status = copy_runtime_ozone_chemistry_fields(p, first, last, l, inputs%records%geometry%dimensions%ndglg, &
                                                     ozone_options, d%kgplat, providers%ozone_chemistry%toz2dl, local%zkozo)
        if (status /= 0) goto 900
      end if
      do j = first, last
        local%zpraers(j) = 0.0_real64
      end do
      call visibility_layer(0_int32, d, local, diag)
      call callpar_surface_time_update(inputs, d, state0, aux, surface, surfl, keys, flux, context%surface_diagnostics, status)
      if (status /= 0) goto 900
      if (model%physics%ecmwf_physics%leo3ch .and. model%fields%components(o3_index)%lgp == 1_int32) then
        status = calculate_runtime_ozone_tendency(model%physics%ecmwf_physics, ozone_options, p, l, first, last, &
                                            physical%rg, physical%rpi, timestep, providers%solar_declination, aux%pgemu, aux%pmu0, &
                                                  aux%prs1, aux%prsf1, local%zkozo, aux%pdelp, tmp%t, tmp%o3, loc%o3)
        if (status /= 0) goto 900
        call state_increment(d, cml, pa_o3=loc%o3)
      end if
      ! The selected uncoupled-ocean source branch is inactive and writes no field.
      call sltend_layer(physical, thermal, step, start, providers%rslwx, model, d, aux, state0, dyn, vdf, satadj, cml, &
                        context%records%previous_state, inputs%arrays%saved_tendencies(:, :, :, block), &
                        inputs%arrays%gflslp(:, :, :, block), surface, loc, status)
      if (status /= 0) goto 900
      call state_increment(d, cml, pa_u=loc%u, pa_v=loc%v, pa_t=loc%t, pa_q=loc%q, pa_a=loc%a, pa_o3=loc%o3, &
                           pa_ql=loc%cld(:, :, 1), pa_qi=loc%cld(:, :, 2), pa_qr=loc%cld(:, :, 3), pa_qs=loc%cld(:, :, 4))
   call qnegat(physical, parameters%condensation, first, last, p, l, timestep, state0%q, loc%q, aux%prs1, flux%pfcqng, pitend=cml%q)
      call state_increment(d, cml, pa_q=loc%q)
      do j = first, last
        surface%psd_vd(j, z0vd) = local%zaz0m(j)*physical%rg
      end do
      do j = first, last
        surface%psd_vd(j, lz0hvd) = scalar_log(local%zaz0h(j))
      end do
      do k = 1, l
        do j = first, last
          surface%pcovptot(j, k) = diag%pcovptot(j, k)
        end do
      end do
      call update_fields(model%physics_auxiliary, 2_int32, first, last, p, l, &
                         pi1=cml%u, po1=dyn%u, pi2=cml%v, po2=dyn%v, pi3=cml%t, po3=dyn%t, pi4=cml%q, po4=dyn%q, &
                         ldv5=model%fields%components(a_index)%lactive == 1, pi5=cml%a, po5=dyn%a, &
                         ldv6=model%fields%components(o3_index)%lactive == 1, pi6=cml%o3, po6=dyn%o3, &
                         ldv7=model%fields%components(l_index)%lactive == 1, pi7=cml%cld(:, :, 1), &
                         po7=inputs%arrays%gflt1(:, :, model%fields%components(l_index)%mp1, block), &
                         ldv8=model%fields%components(i_index)%lactive == 1, pi8=cml%cld(:, :, 2), &
                         po8=inputs%arrays%gflt1(:, :, model%fields%components(i_index)%mp1, block), &
                         ldv9=model%fields%components(r_index)%lactive == 1, pi9=cml%cld(:, :, 3), &
                         po9=inputs%arrays%gflt1(:, :, model%fields%components(r_index)%mp1, block), &
                         ldv10=model%fields%components(s_index)%lactive == 1, pi10=cml%cld(:, :, 4), &
                         po10=inputs%arrays%gflt1(:, :, model%fields%components(s_index)%mp1, block), &
                         ldv11=model%fields%components(tke_index)%lactive == 1, pi11=cml%tke, po11=dyn%tke)
      status = 0
900   continue
      if (local_owned) call finish_runtime_local_physics_work(surfl, local)
    end associate
  end function
  !> Admit the live dimensions within the unchanged convection workspace bound.
  logical function dimension_workspace_too_large(columns, levels) result(rejected)
    integer(int32), intent(in) :: columns, levels
    integer(int64) :: bytes
    bytes = 60_int64*int(columns, int64)*int(levels, int64) + 8_int64*int(columns, int64)
    bytes = iand(bytes + 31_int64, not(15_int64))
    rejected = bytes > 1048576_int64
  end function

  !> Read the source alias index from the one initialized native field catalog.
  integer(int32) function catalog_index(registry, name, slot) result(index)
    type(surface_field_registry), intent(in) :: registry
    character(len=*), intent(in) :: name
    integer, intent(in) :: slot
    integer :: i, g, f
    index = 0
    if (.not. registry%ready .or. slot < 1 .or. slot > 4) return
    do i = 1, size(registry%aliases)
      if (registry%aliases(i)%name /= name) cycle
      g = registry%aliases(i)%group; f = registry%aliases(i)%first_field
      if (g < 1 .or. g > size(registry%groups)) return
      if (.not. allocated(registry%groups(g)%fields)) return
      if (f < 1 .or. f > size(registry%groups(g)%fields)) return
      if (registry%groups(g)%fields(f)%initialized /= 1_int32) return
      index = registry%groups(g)%fields(f)%indices(slot)
      return
    end do
  end function
  !> Preserve the multiply and public remainder call before the initial-step test.
  logical function interval_due(step, initial, timestep, interval) result(due)
    integer(int32), intent(in) :: step, initial
    real(real64), intent(in) :: timestep, interval
    real(real64), volatile :: seconds, remainder
    seconds = real(step, real64)*timestep
    remainder = scalar_remainder(seconds, interval)
    due = remainder == 0.0_real64
    if (step == initial) due = .true.
  end function
  !> Preserve the original real remainder before its radiation-step test.
  logical function cloud_diagnostics_due(step, timestep, hour, frequency) result(due)
    integer(int32), intent(in) :: step, frequency
    real(real64), intent(in) :: timestep, hour
    real(real64), volatile :: seconds, remainder
    seconds = real(step, real64)*timestep
    remainder = scalar_remainder(seconds, hour)
    due = remainder == 0.0_real64 .or. mod(step, frequency) == 0
  end function
end submodule complete_callpar_body
