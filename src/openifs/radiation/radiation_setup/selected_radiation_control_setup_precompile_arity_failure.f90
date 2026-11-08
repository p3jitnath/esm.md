!> Compose selected radiation controls with native transactional ownership.
module selected_radiation_control_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yoe_uvrad, only: teuvrad
  use yoelwrad, only: telwrad
  use yoecmip, only: tecmip
  use physical_constant_setup_port, only: forecast_physical_constants
  use selected_radiation_control_fields_mod, only: radiation_scalar_parameter_record, &
                                                   apply_radiation_control_literal_fields, prepare_radiation_visibility_constants, &
                                                complete_selected_radiation_control_fields, commit_selected_radiation_control_fields
  use radiation_climate_selection_port, only: radiation_climate_upstream_record, &
                               radiation_climate_selection_record, select_radiation_climate_files, apply_selected_radiation_namelist
  use spectral_planck_parameter_setup_port, only: create_selected_spectral_planck
  implicit none
  private
  public :: radiation_control_upstream_record
  public :: initialize_selected_radiation_controls, initialize_runtime_radiation_controls
  type :: radiation_control_upstream_record
    logical :: lecmwf, larpegef, lephys, lrayfm, ozone_lgp, lopt_scalar
    logical :: lape, lhlradupd, lray, laeruvp, leradi, leradlw2
    integer(int32) :: nemissscheme, nproma, nsmax, ndglg, ngptot, ngptotmx, nflevg, ngpblks, ndlon
    logical :: leradn2
    real(real64) :: timestep, radgr, radsn
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Apply the original selected nineteen-level,T21 control specialization.
  !! TEXT and DATA_DIRECTORY are readonly bounded character inputs.
  !! UPSTREAM contains live source controls and dimensions. The seven
  !! complete native output records are separate caller-owned INOUT objects.
  !! CONSTANTS is readonly. Preserve every unassigned member and all five
  !! already-live aerosol owners. Planck owners must initially be absent.
  !! Return2 before public writes for unsupported input,1 on Planck resource
  !! failure,or0 after commit. Natural FP flags and quiet errno are retained.
  integer(int32) function initialize_selected_radiation_controls(text, data_directory, upstream, &
                                                 radiation, gases, uv, longwave, cmip, scalars, selection, constants) result(status)
    character(len=*), intent(in), target :: text, data_directory
    type(radiation_control_upstream_record), intent(in), target :: upstream
    type(terad), intent(inout), target :: radiation
    type(terdi), intent(inout), target :: gases
    type(teuvrad), intent(inout), target :: uv
    type(telwrad), intent(inout), target :: longwave
    type(tecmip), intent(inout), target :: cmip
    type(radiation_scalar_parameter_record), intent(inout), target :: scalars
    type(radiation_climate_selection_record), intent(inout), target :: selection
    type(forecast_physical_constants), intent(in), target :: constants
    status = initialize_controls(.false., text, data_directory, upstream, &
                                 radiation, gases, uv, longwave, cmip, scalars, selection, constants)
  end function

  !> Apply the existing live-grid radiation-prefix source branch.
  !! Arguments,ownership and mutation match the selected entry above.
  !! Native dimensions are explicit,with NPROMA1:512 and levels1:256.
  !! This branch preserves incoming selected-only grid and longwave fields,
  !! admits the three source owner switches and requires LSRTMtrue.
  !! Its wider numerical domain needs independent reference qualification.
  integer(int32) function initialize_runtime_radiation_controls(text, data_directory, upstream, &
                                                 radiation, gases, uv, longwave, cmip, scalars, selection, constants) result(status)
    character(len=*), intent(in), target :: text, data_directory
    type(radiation_control_upstream_record), intent(in), target :: upstream
    type(terad), intent(inout), target :: radiation
    type(terdi), intent(inout), target :: gases
    type(teuvrad), intent(inout), target :: uv
    type(telwrad), intent(inout), target :: longwave
    type(tecmip), intent(inout), target :: cmip
    type(radiation_scalar_parameter_record), intent(inout), target :: scalars
    type(radiation_climate_selection_record), intent(inout), target :: selection
    type(forecast_physical_constants), intent(in), target :: constants
    status = initialize_controls(.true., text, data_directory, upstream, &
                                 radiation, gases, uv, longwave, cmip, scalars, selection, constants)
  end function

  integer(int32) function initialize_controls(runtime_prefix, text, data_directory, upstream, &
                                              radiation, gases, uv, longwave, cmip, scalars, selection, constants) result(status)
    logical, intent(in) :: runtime_prefix
    character(len=*), intent(in), target :: text, data_directory
    type(radiation_control_upstream_record), intent(in), target :: upstream
    type(terad), intent(inout), target :: radiation
    type(terdi), intent(inout), target :: gases
    type(teuvrad), intent(inout), target :: uv
    type(telwrad), intent(inout), target :: longwave
    type(tecmip), intent(inout), target :: cmip
    type(radiation_scalar_parameter_record), intent(inout), target :: scalars
    type(radiation_climate_selection_record), intent(inout), target :: selection
    type(forecast_physical_constants), intent(in), target :: constants
    type(terad) :: staged_radiation
    type(terdi) :: staged_gases
    type(radiation_climate_selection_record) :: staged_selection
    type(radiation_climate_upstream_record) :: climate_upstream
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer(c_intptr_t) :: addresses(12)
    integer(int64) :: lengths(12)
    real(real64) :: physical(6)
    integer :: first, second
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144 .or. len(data_directory) > 512) return
    if (.not. upstream%lecmwf .or. upstream%larpegef .or. .not. upstream%lephys) return
    if (upstream%lrayfm .or. .not. upstream%lopt_scalar) return
    if (upstream%lape .or. upstream%lhlradupd .or. upstream%lray .or. upstream%laeruvp) return
    if (.not. upstream%leradi .or. upstream%leradlw2 .or. upstream%nemissscheme /= 0 .or. upstream%leradn2) return
    if (transfer(upstream%radgr, 0_int64) /= 0_int64 .or. transfer(upstream%radsn, 0_int64) /= 0_int64) return
    if (runtime_prefix) then
      if (upstream%nsmax < 1 .or. upstream%nsmax > 8191) return
      if (upstream%nproma < 1 .or. upstream%nproma > 512) return
      if (upstream%nflevg < 1 .or. upstream%nflevg > 256) return
      if (upstream%ndglg < 1 .or. upstream%ngptot < 1 .or. upstream%ngptotmx < upstream%ngptot) return
      if (upstream%ngpblks < 1 .or. upstream%ndlon < 1) return
    else
      if (upstream%nproma /= 24 .or. upstream%nsmax /= 21 .or. upstream%ndglg /= 32) return
      if (upstream%ngptot /= 2048 .or. upstream%ngptotmx /= 2048 .or. upstream%nflevg /= 19) return
      if (upstream%ngpblks /= 86 .or. upstream%ndlon /= 64) return
      select case (transfer(upstream%timestep, 0_int64))
      case (int(z'4082c00000000000', int64), int(z'408c200000000000', int64), &
            int(z'409c200000000000', int64), int(z'40ac200000000000', int64))
      case default
        return
      end select
    end if
    if (allocated(radiation%yspectplanck%planck_lut)) return
    if (allocated(radiation%yspectplanck%wavlen_bound)) return
    if (allocated(radiation%yspectplanck%interval_map)) return
    physical = [constants%rpi, constants%rclum, constants%rhpla, constants%rkbol, constants%rnavo, constants%ri0]
    do first = 1, 6
      if (.not. positive_finite(physical(first))) return
    end do
    addresses = [transfer(c_loc(radiation), 0_c_intptr_t), transfer(c_loc(gases), 0_c_intptr_t), &
                 transfer(c_loc(uv), 0_c_intptr_t), transfer(c_loc(longwave), 0_c_intptr_t), &
                 transfer(c_loc(cmip), 0_c_intptr_t), transfer(c_loc(scalars), 0_c_intptr_t), &
                 transfer(c_loc(selection), 0_c_intptr_t), transfer(c_loc(constants), 0_c_intptr_t), &
                 transfer(c_loc(upstream), 0_c_intptr_t), transfer(c_loc(text), 0_c_intptr_t), &
                 transfer(c_loc(data_directory), 0_c_intptr_t), 0_c_intptr_t]
    lengths = [storage_size(radiation, kind=int64)/8_int64, storage_size(gases, kind=int64)/8_int64, &
               storage_size(uv, kind=int64)/8_int64, storage_size(longwave, kind=int64)/8_int64, &
               storage_size(cmip, kind=int64)/8_int64, storage_size(scalars, kind=int64)/8_int64, &
               storage_size(selection, kind=int64)/8_int64, storage_size(constants, kind=int64)/8_int64, &
               storage_size(upstream, kind=int64)/8_int64, int(len(text), int64), int(len(data_directory), int64), 0_int64]
    do first = 1, 7
      do second = first + 1, 11
        if (lengths(second) == 0_int64) cycle
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    climate_upstream%lephys = upstream%lephys
    climate_upstream%larpegef = upstream%larpegef
    climate_upstream%lrayfm = upstream%lrayfm
    climate_upstream%ozone_lgp = upstream%ozone_lgp
    climate_upstream%lopt_scalar = upstream%lopt_scalar
    status = select_radiation_climate_files(text, data_directory, climate_upstream, staged_selection, runtime_prefix)
    if (status /= 0_int32) then
      errno_value = incoming_errno
      return
    end if
    staged_selection%values%nrproma = -8_int32
    status = apply_selected_radiation_namelist(text, staged_selection, runtime_prefix)
    if (status /= 0_int32) then
      errno_value = incoming_errno
      return
    end if
    if (staged_selection%values%nrproma /= 0 .and. staged_selection%values%nrproma /= -8) then
      status = 2_int32
      errno_value = incoming_errno
      return
    end if
    if (runtime_prefix .and. .not. staged_selection%values%lsrtm) then
      status = 2_int32
      errno_value = incoming_errno
      return
    end if
    staged_selection%values%nrproma = 8_int32
    staged_gases = gases
    call apply_radiation_control_literal_fields(staged_radiation, staged_gases, uv, cmip, scalars, .true., runtime_prefix)
    call prepare_radiation_visibility_constants(staged_radiation, staged_gases, constants)
    errno_value = incoming_errno
    status = create_selected_spectral_planck(staged_radiation%yspectplanck, constants)
    if (status /= 0_int32) return
    call apply_radiation_control_literal_fields(staged_radiation, staged_gases, uv, cmip, scalars, .false., runtime_prefix)
    call complete_selected_radiation_control_fields(staged_radiation, staged_gases, uv, longwave, cmip, scalars, &
                            staged_selection%values, upstream%nproma, upstream%ngptot, upstream%ngptotmx, constants, runtime_prefix)
    call commit_selected_radiation_control_fields(radiation, staged_radiation, runtime_prefix)
    radiation%yspectplanck%nintervals = staged_radiation%yspectplanck%nintervals
    radiation%yspectplanck%ntemps = staged_radiation%yspectplanck%ntemps
    radiation%yspectplanck%temp1 = staged_radiation%yspectplanck%temp1
    radiation%yspectplanck%dtemp = staged_radiation%yspectplanck%dtemp
    call move_alloc(staged_radiation%yspectplanck%wavlen_bound, radiation%yspectplanck%wavlen_bound)
    call move_alloc(staged_radiation%yspectplanck%interval_map, radiation%yspectplanck%interval_map)
    call move_alloc(staged_radiation%yspectplanck%planck_lut, radiation%yspectplanck%planck_lut)
    gases = staged_gases
    selection = staged_selection
    errno_value = incoming_errno
    status = 0_int32
  end function

  logical function positive_finite(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, word)
    valid = word > 0_int64 .and. word < int(z'7ff0000000000000', int64)
  end function

  !> Check native storage without constructing a private target layout.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Require nearest rounding and gradual underflow without changing flags.
  !! The launcher establishes the complete target floating-point contract.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module
