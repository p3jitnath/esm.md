! (C) Copyright ECMWF. Licensed under Apache-2.0.
!> Source-ordered column physics over the original selected control route.
!! Pressure is Pa, temperatures K, geopotential m2/s2 and time seconds.
!! Local pressure planes stay alive through CALLPAR and post-physics work.
submodule(forecast_native_column_physics) native_column_physics_body
  use iso_fortran_env, only: int64, real64
  use forecast_complete_physics_context_types, only: native_complete_physics_context, native_complete_physics_driver_inputs
  use forecast_vertical_coordinate_storage, only: native_vertical_state
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use forecast_column_physics_preparations, only: ec_pressure, ec_mixture, ec_geopotential
  use forecast_physics_work_reset, only: physics_surface_zero_columns, initialize_runtime_physics_work, finish_runtime_physics_work
  use forecast_surface_time_state_copy, only: surface_time_state_copy_recorded
  use forecast_complete_physics_parameterisation_sequence, only: callpar_runtime
  use forecast_native_runtime_post_physics, only: postphy_layer => postphy_layer_runtime
  use native_radiation_solar_geometry_from_clock, only: cos_sza_openifs_source_compatibility
  use native_radiation_clock_views, only: radiation_clock_is_ready
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_surface_catalog_lookup, only: catalog_index => surface_catalog_index
  use yomhook, only: lhook, dr_hook
  use iso_c_binding, only: c_double
  implicit none
  interface
    function public_cos(x) bind(C, name="cos") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_sin(x) bind(C, name="sin") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  module procedure ec_phys
  type(native_vertical_state), pointer :: vertical
  type(hybrid_pressure_controls) :: pressure_controls
  type(vertical_operator_matrices) :: operators
  type(physics_surface_zero_columns) :: zero_columns
  real(real64), allocatable, target :: scratch(:)
  real(real64), pointer :: xyb9(:, :, :), xyb1(:, :, :), tenq(:, :), gas_constant(:, :), ag(:), reco(:)
  real(real64), pointer :: incoming_delp(:, :), incoming_delp1(:, :), metric(:)
  real(real64), target :: empty_metric(0)
  integer(int32), parameter :: field_index(7) = [1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32]
  character(len=24), parameter :: bins(9) = [character(len=24) :: &
                                            'YSD_VD%YMX2T6', 'YSD_VD%YMN2T6', 'YSD_VD%Y10FG6', 'YSD_VD%YMXTPR6', 'YSD_VD%YMNTPR6', &
                                             'YSD_VD%YMXCAP6', 'YSD_VD%YMXCAPS6', 'YSD_VD%YLITOTA6', 'YSD_VD%YLICGA6']
  integer(int32) :: p, l, first, last, block, step, bin_length, number_bins, current_bin, previous_bin
  integer(int32) :: j, k, bin, occ, slot, old_slot, mode, allocation_status, child_status, cleanup_status
  integer(int64) :: plane, offset, total_words
  logical :: first_step, mlpp, reset, rs6, pressure_views_bound, work_started
  real(real64) :: hook, value, other, top_value, dewpoint
  real(real64), volatile :: square_root_left, square_root_right
  character(len=1) :: configuration
  status = 2_int32; pressure_views_bound = .false.; work_started = .false.
  if (.not. associated(inputs%providers) .or. .not. associated(inputs%post_controls)) return
  if (.not. associated(inputs%providers%physical) .or. .not. associated(inputs%providers%thermal)) return
  if (.not. associated(inputs%providers%current_step) .or. .not. associated(inputs%providers%initial_step)) return
  if (.not. associated(inputs%post_controls%lrsacc) .or. .not. associated(inputs%post_controls%rmdi)) return
  if (.not. associated(inputs%rcovsr) .or. .not. associated(inputs%rsivsr)) return
  if (.not. radiation_clock_is_ready(inputs%solar_clock)) return
  if (.not. associated(context%records%model) .or. .not. associated(context%records%geometry)) return
  if (.not. associated(context%records%configuration) .or. .not. associated(context%records%surface_metadata)) return
  if (.not. associated(inputs%physics)) return
  if (.not. associated(context%records%model%initial)) return
  if (.not. allocated(context%records%model%initial%geometry)) return
  if (.not. associated(context%records%model%initial%geometry%vertical)) return
  vertical => context%records%model%initial%geometry%vertical
  p = context%dimensions%klon; l = context%dimensions%klev
  first = context%dimensions%kidia; last = context%dimensions%kfdia; block = context%dimensions%kbl
  if (p < 1 .or. p > 128 .or. l < 6 .or. l > 137 .or. first < 1 .or. last > p .or. first > last) return
  if (vertical%levels /= l .or. .not. vertical%constructor_ready) return
  if (.not. context%records%model%dynamics%ltwotl) return
  if (context%records%model%dynamics%lsacc) return
  if (context%records%model%fields%alias_controls%nera40 /= 0) return
  if (context%records%model%physics%ecmwf_physics%legbrad .or. &
      context%records%model%physics%ecmwf_physics%leraingg) return
  if (context%records%model%physics%wave_coupling%lwcou) return
  if (.not. associated(context%variables%sp%ph9) .or. .not. associated(context%variables%sp%t1)) return
  if (.not. associated(context%variables%t%ph9) .or. .not. associated(context%variables%q%t1)) return
  if (.not. allocated(vertical%vah) .or. .not. allocated(vertical%vbh) .or. .not. allocated(vertical%vc)) return
  if (.not. allocated(vertical%vaf) .or. .not. allocated(vertical%vbf)) return
  if (.not. allocated(vertical%vdela) .or. .not. allocated(vertical%vdelb)) return
  pressure_controls%approximate_mode = vertical%configuration%ndlnpr
  pressure_controls%finite_elements = vertical%configuration%lvertfe /= 0
  pressure_controls%arithmetic_full_pressure = vertical%configuration%laprxpk /= 0
  pressure_controls%top_alpha = vertical%configuration%rhydr0
  pressure_controls%top_pressure = vertical%toppres
  pressure_controls%dry_gas_constant = inputs%providers%physical%rd
  pressure_controls%dry_isochoric_heat_capacity = inputs%providers%physical%rcvd
  metric => empty_metric
  if (pressure_controls%finite_elements) then
    if (.not. allocated(vertical%rintbf11) .or. .not. allocated(vertical%vfe_rdetah)) return
    operators%rintbf11 => vertical%rintbf11
    metric => vertical%vfe_rdetah
  end if
  configuration = context%records%configuration
  step = inputs%providers%current_step
  first_step = step <= 0
  mlpp = context%records%model%physics%ecmwf_physics%lfpos_ec_phys
  reset = context%records%model%physics%ecmwf_physics%lfpos_acc_reset
  ! Original SUPTR_TXYB(.TRUE.) supplies seven fixed source plane numbers.
  plane = int(p, int64)*int(l, int64)
  total_words = 16_int64*plane + 2_int64*int(p, int64)
  if (total_words > huge(total_words)/8_int64) return
  if (total_words*8_int64 > inputs%providers%byte_limit) return
  if (.not. bind_zero_columns(context%records%surface_metadata, zero_columns)) return
  if (.not. bins_admitted(context%records%surface_metadata, context%surface%psd_vd)) return
  allocate (scratch(total_words), stat=allocation_status)
  if (allocation_status /= 0) then
    status = 1_int32
    return
  end if
  offset = 0_int64
  xyb9(1:p, 1:l, 1:7) => scratch(offset + 1:offset + 7_int64*plane); offset = offset + 7_int64*plane
  xyb1(1:p, 1:l, 1:7) => scratch(offset + 1:offset + 7_int64*plane); offset = offset + 7_int64*plane
  tenq(1:p, 1:l) => scratch(offset + 1:offset + plane); offset = offset + plane
  gas_constant(1:p, 1:l) => scratch(offset + 1:offset + plane); offset = offset + plane
  ag(1:p) => scratch(offset + 1:offset + p); offset = offset + p
  reco(1:p) => scratch(offset + 1:offset + p)
  incoming_delp => context%auxiliary%pdelp
  incoming_delp1 => context%auxiliary%pdelp1
  if (lhook) call dr_hook('EC_PHYS', 0, hook)
  bin_length = max(3600_int32, int(inputs%solar_clock%tstep, int32))
  number_bins = 21600_int32/bin_length
  if (number_bins < 1) goto 900
  current_bin = mod(int((step*inputs%solar_clock%tstep)/bin_length, int32), number_bins) + 1
  previous_bin = mod(int(((step - 1)*inputs%solar_clock%tstep)/bin_length, int32), number_bins) + 1
  rs6 = current_bin /= previous_bin
  child_status = initialize_runtime_physics_work(context%dimensions, &
                                    context%records%model%physics%ecmwf_physics%lecurr, zero_columns, context%surface_diagnostics, &
                                                 context%diagnostics, context%surface, context%flux)
  if (child_status /= 0) goto 900
  work_started = .true.
  context%auxiliary%pdelp => xyb9(:, :, 1); context%auxiliary%pdelp1 => xyb1(:, :, 1)
  pressure_views_bound = .true.
  mode = 0_int32
  if (configuration == 'A' .or. configuration == 'B') mode = 1_int32
  child_status = surface_time_state_copy_recorded(context%surface, mode)
  if (child_status /= 0) goto 900
  if (first_step) then
    do bin = 1, 6
      do j = 1, 9
        slot = catalog_index(context%records%surface_metadata, bins(j), 1_int32, bin)
        value = 0.0_real64
        if (j == 2 .or. j == 5) value = 999.0_real64
        context%surface%psd_vd(first:last, slot) = value
      end do
      do occ = 1, 12
        slot = catalog_index(context%records%surface_metadata, 'YSD_VD%YPTYPEOCC6', 1_int32, bin, occ)
        context%surface%psd_vd(first:last, slot) = 0.0_real64
      end do
    end do
  elseif (rs6) then
    do bin = 6, 2, -1
      do j = 1, 9
        slot = catalog_index(context%records%surface_metadata, bins(j), 1_int32, bin)
        old_slot = catalog_index(context%records%surface_metadata, bins(j), 1_int32, bin - 1)
        context%surface%psd_vd(first:last, slot) = context%surface%psd_vd(first:last, old_slot)
      end do
      do occ = 1, 12
        slot = catalog_index(context%records%surface_metadata, 'YSD_VD%YPTYPEOCC6', 1_int32, bin, occ)
        old_slot = catalog_index(context%records%surface_metadata, 'YSD_VD%YPTYPEOCC6', 1_int32, bin - 1, occ)
        context%surface%psd_vd(first:last, slot) = context%surface%psd_vd(first:last, old_slot)
      end do
    end do
  end if
  slot = catalog_index(context%records%surface_metadata, 'YSD_VD%YIGPP', 1_int32)
  old_slot = catalog_index(context%records%surface_metadata, 'YSD_VD%YIREC', 1_int32)
  ag(first:last) = context%surface%psd_vd(first:last, slot)
  reco(first:last) = context%surface%psd_vd(first:last, old_slot)
  child_status = ec_pressure(context%dimensions, pressure_controls, vertical%vah, vertical%vbh, vertical%vc, &
                             vertical%vaf, vertical%vbf, vertical%vdela, vertical%vdelb, field_index, context%variables%sp%ph9, &
                             context%auxiliary%paprs, xyb9, context%auxiliary%paprsf)
  if (child_status /= 0) goto 900
  child_status = ec_mixture(context%dimensions, inputs%providers%physical, context%records%model%fields, &
                            context%arrays%gfl(:, :, :, block), gas_constant)
  if (child_status /= 0) goto 900
  child_status = ec_geopotential(context%dimensions, .false., pressure_controls%finite_elements, operators, &
                                 vertical%configuration%nvfe_intbc, vertical%configuration%nvfe_derbc, context%variables%t%ph9, &
                                 gas_constant, xyb9, field_index, metric, context%auxiliary)
  if (child_status /= 0) goto 900
  call cos_sza_openifs_source_compatibility(inputs%providers%physical, inputs%physics%radiation%radiation, &
                                            inputs%solar_clock, inputs%solar_clock, first, last, p, context%auxiliary%pgemu, &
                                            context%auxiliary%pgelam, .false., context%auxiliary%pmu0)
  call cos_sza_openifs_source_compatibility(inputs%providers%physical, inputs%physics%radiation%radiation, &
                                            inputs%solar_clock, inputs%solar_clock, first, last, p, context%auxiliary%pgemu, &
                                            context%auxiliary%pgelam, .true., context%auxiliary%pmu0m)
  do j = first, last
    value = context%auxiliary%pgemu(j)*context%auxiliary%pgemu(j)
    value = 1.0_real64 - value; square_root_left = sqrt(value)
    value = context%auxiliary%pgemu(j)*context%auxiliary%pgemu(j)
    value = 1.0_real64 - value; square_root_right = sqrt(value)
    top_value = inputs%solar_clock%rsidec*context%auxiliary%pgemu(j)
    value = inputs%solar_clock%rcodec*inputs%rcovsr
    value = value*square_root_left; value = value*public_cos(context%auxiliary%pgelam(j))
    top_value = top_value - value
    value = inputs%solar_clock%rcodec*inputs%rsivsr
    value = value*square_root_right; value = value*public_sin(context%auxiliary%pgelam(j))
    context%auxiliary%pmu0t(j) = top_value + value
  end do
  child_status = ec_pressure(context%dimensions, pressure_controls, vertical%vah, vertical%vbh, vertical%vc, &
                             vertical%vaf, vertical%vbf, vertical%vdela, vertical%vdelb, field_index, context%variables%sp%t1, &
                             context%auxiliary%prs1, xyb1, context%auxiliary%prsf1)
  if (child_status /= 0) goto 900
  if (context%variables%l%lactive .and. context%variables%i%lactive) then
    do k = 1, l
      do j = first, last
        value = context%variables%q%t1(j, k) + context%variables%l%t1(j, k)
        value = value + context%variables%i%t1(j, k)
        tenq(j, k) = -1.0_real64*value
      end do
    end do
  else
    do k = 1, l
      do j = first, last
        tenq(j, k) = -1.0_real64*context%variables%q%t1(j, k)
      end do
    end do
  end if
  child_status = callpar_runtime(context, inputs, inputs%providers, ag, reco)
  if (child_status /= 0) goto 900
  context%arrays%convectivity(:, :, block) = 0.0_real64
  do k = 1, l - 1
    do j = first, last
      if (context%diagnostics%itype(j) /= 1) cycle
      value = context%diagnostics%pmfu(j, k) - context%diagnostics%pmfu(j, k + 1)
      other = context%diagnostics%pmfd(j, k) - context%diagnostics%pmfd(j, k + 1)
      other = other*inputs%physics%convection%rmfadvwdd; value = value + other
      value = (-inputs%providers%physical%rg)*value
      value = value*xyb9(j, k, 2)
      context%arrays%convectivity(j, k, block) = value*inputs%physics%convection%rmfadvw
    end do
  end do
  do j = first, last
    if (context%diagnostics%itype(j) /= 1) cycle
    value = context%diagnostics%pmfu(j, l) - 0.0_real64
    other = context%diagnostics%pmfd(j, l) - 0.0_real64
    other = other*inputs%physics%convection%rmfadvwdd; value = value + other
    value = (-inputs%providers%physical%rg)*value; value = value*xyb9(j, l, 2)
    context%arrays%convectivity(j, l, block) = value*inputs%physics%convection%rmfadvw
  end do
  ! Inactive satellite products retain the original complete missing-value stores.
  if (associated(context%arrays%smos_brightness)) context%arrays%smos_brightness = inputs%post_controls%rmdi
  if (associated(context%arrays%smap_brightness)) context%arrays%smap_brightness = inputs%post_controls%rmdi
  child_status = postphy_layer(context, inputs, context%variables%u%ph9, context%variables%v%ph9, &
                               context%variables%t%ph9, context%arrays%gfl(:, :, :, block), tenq, first_step, mlpp, rs6, reset, &
                               inputs%post_controls%lrsacc /= 0)
  if (child_status /= 0) goto 900
  child_status = surface_time_state_copy_recorded(context%surface, 2_int32)
  if (child_status /= 0) goto 900
  child_status = finish_runtime_physics_work(context%dimensions)
  if (child_status /= 0) goto 900
  context%auxiliary%pdelp => incoming_delp; context%auxiliary%pdelp1 => incoming_delp1
  pressure_views_bound = .false.
  if (lhook) call dr_hook('EC_PHYS', 1, hook)
  status = 0_int32
  return
900 continue
  if (pressure_views_bound) then
    context%auxiliary%pdelp => incoming_delp; context%auxiliary%pdelp1 => incoming_delp1
  end if
  if (work_started) cleanup_status = finish_runtime_physics_work(context%dimensions)
  status = 3_int32
  end procedure ec_phys

  logical function bind_zero_columns(catalog, c) result(ok)
    type(surface_field_registry), intent(in) :: catalog
    type(physics_surface_zero_columns), intent(out) :: c
    integer(int32) :: values(16)
    character(len=24), parameter :: names(16) = [character(len=24) :: &
                                   'YSD_VF%YUCUR', 'YSD_VF%YVCUR', 'YSD_VD%YODSS', 'YSD_VD%YODDU', 'YSD_VD%YODOM', 'YSD_VD%YODBC', &
                                                 'YSD_VD%YODSU', 'YSD_VD%YODNI', 'YSD_VD%YODAM', 'YSD_VD%YODVFA', 'YSD_VD%YODVSU', &
                                            'YSD_VD%YAEPM1', 'YSD_VD%YAEPM25', 'YSD_VD%YAEPM10', 'YSD_VD%YUVBED', 'YSD_VD%YUVBEDCS']
    integer :: j
    do j = 1, 16
      values(j) = catalog_index(catalog, names(j), 1_int32)
    end do
    ok = all(values > 0)
    if (.not. ok) return
    c = physics_surface_zero_columns(values(1), values(2), values(3), values(4), values(5), values(6), &
                values(7), values(8), values(9), values(10), values(11), values(12), values(13), values(14), values(15), values(16))
  end function

  logical function bins_admitted(catalog, values) result(ok)
    type(surface_field_registry), intent(in) :: catalog
    real(real64), pointer, intent(in) :: values(:, :)
    character(len=24), parameter :: names(11) = [character(len=24) :: &
                                            'YSD_VD%YMX2T6', 'YSD_VD%YMN2T6', 'YSD_VD%Y10FG6', 'YSD_VD%YMXTPR6', 'YSD_VD%YMNTPR6', &
                                                 'YSD_VD%YMXCAP6', 'YSD_VD%YMXCAPS6', 'YSD_VD%YLITOTA6', 'YSD_VD%YLICGA6', &
                                                 'YSD_VD%YIGPP', 'YSD_VD%YIREC']
    integer :: j, b, o, f
    ok = .false.
    if (.not. associated(values)) return
    do j = 1, 11
      do b = 1, 6
        if (j >= 10 .and. b > 1) cycle
        f = catalog_index(catalog, names(j), 1_int32, merge(b, 1, j < 10))
        if (f < lbound(values, 2) .or. f > ubound(values, 2)) return
      end do
    end do
    do b = 1, 6
      do o = 1, 12
        f = catalog_index(catalog, 'YSD_VD%YPTYPEOCC6', 1_int32, b, o)
        if (f < lbound(values, 2) .or. f > ubound(values, 2)) return
      end do
    end do
    ok = .true.
  end function
end submodule
