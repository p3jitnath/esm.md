!> Compose selected radiation controls with native transactional ownership.
module forecast_runtime_radiation_control_prefix
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_ptr, c_int, c_f_pointer
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
                                              radiation_climate_selection_record
  use spectral_planck_parameter_setup_port, only: create_selected_spectral_planck
  use yoephy, only: tephy
  use forecast_runtime_radiation_prefix_types, only: native_runtime_radiation_prefix_context
  use forecast_runtime_radiation_owner_namelist, only: apply_radiation_owner_namelist
  use forecast_runtime_radiation_climate_prefix, only: select_runtime_radiation_prefix_climate
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record
  implicit none
  private
  public :: initialize_runtime_radiation_control_prefix, initialize_runtime_radiation_owner_controls
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Prepare only the two owner-control words from actual TEPHY and two reads.
 !! RADIATION is a separate native INOUT TERAD; PHYSICS and TEXT are readonly.
 !! The caller establishes nearest rounding and gradual underflow once.
 !! Status2 leaves every public member unchanged. Status0 writes only
 !! LAPPROXLWUPDATE and NLWOUT. Other parser choices belong to later stages.
  integer(int32) function initialize_runtime_radiation_owner_controls(radiation, physics, text) result(status)
    type(terad), target, intent(inout) :: radiation
    type(tephy), target, intent(in) :: physics
    character(len=*), target, intent(in) :: text
    type(radiation_climate_selection_record) :: selection
    integer(c_intptr_t) :: r, p, t
    integer(int64) :: rb, pb, tb
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (.not. physics%lephys .or. physics%nemissscheme < 0 .or. physics%nemissscheme > 1) return
    r = transfer(c_loc(radiation), r); rb = storage_size(radiation, kind=int64)/8_int64
    p = transfer(c_loc(physics), p); pb = storage_size(physics, kind=int64)/8_int64
    t = transfer(c_loc(text), t); tb = int(len(text), int64)
    if (.not. disjoint(r, rb, p, pb) .or. .not. disjoint(r, rb, t, tb)) return
    ! The source clears the private parser record before its two first-group reads.
    selection%values%nhincsol = 0; selection%values%nghgrad = 0; selection%values%nscen = 0
    selection%values%nrproma = 0; selection%values%nrcp = 0; selection%values%nghgcmip = 0
    selection%values%lhghg = .false.; selection%values%laer3d = .false.; selection%values%lepo3ra = .false.
    selection%values%lapproxlwupdate = .true.; selection%values%lecompgrid = .false.; selection%values%lsrtm = .true.
    selection%values%cghgclimfile = repeat(achar(0), 256)
    selection%values%cghgtimeseriesfile = repeat(achar(0), 256)
    selection%values%csolarirradiancefile = repeat(achar(0), 256)
    selection%crtabledir = repeat(achar(0), 256)
    selection%paths = repeat(achar(0), 512); selection%path_lengths = 0_int64
    status = apply_radiation_owner_namelist(text, selection); if (status /= 0) return
    status = apply_radiation_owner_namelist(text, selection); if (status /= 0) return
    status = 2_int32
    if (.not. selection%values%lsrtm) return
    radiation%lapproxlwupdate = selection%values%lapproxlwupdate
    radiation%nlwout = 1_int32
    if (physics%nemissscheme == 1 .and. selection%values%lapproxlwupdate) radiation%nlwout = 6_int32
    status = 0_int32
  end function

  !> Complete the original early control prefix through the Planck constructor.
 !! CONTEXT borrows actual canonical records; TEXT is a separate readonly
 !! namelist. Only the named source stores publish. Three new Planck owners
 !! must be absent. Earlier aerosol owners and unused dimensions stay intact.
 !! Status2 refuses before public stores; status1 reports natural allocation
 !! failure after cleanup; status0 commits all early fields and Planck owners.
  integer(int32) function initialize_runtime_radiation_control_prefix(context, text) result(status)
    type(native_runtime_radiation_prefix_context), intent(in) :: context
    character(len=*), target, intent(in) :: text
    status = 2_int32
    if (.not. associated(context%setup) .or. .not. associated(context%upstream)) return
    if (.not. associated(context%constants) .or. .not. associated(context%longwave)) return
    if (.not. associated(context%cmip) .or. .not. associated(context%physics)) return
    if (context%upstream%lephys .neqv. context%physics%lephys) return
    if (context%upstream%nemissscheme /= context%physics%nemissscheme) return
    status = initialize_controls(text, context%upstream, context%setup%radiation, context%setup%gases, &
                        context%setup%ultraviolet, context%longwave, context%cmip, context%setup%scalars, context%setup%selection, &
                                 context%constants, context%physics)
  end function

  integer(int32) function initialize_controls(text, upstream, &
                                        radiation, gases, uv, longwave, cmip, scalars, selection, constants, physics) result(status)
    character(len=*), intent(in), target :: text
    type(radiation_control_upstream_record), intent(in), target :: upstream
    type(terad), intent(inout), target :: radiation
    type(terdi), intent(inout), target :: gases
    type(teuvrad), intent(inout), target :: uv
    type(telwrad), intent(inout), target :: longwave
    type(tecmip), intent(inout), target :: cmip
    type(radiation_scalar_parameter_record), intent(inout), target :: scalars
    type(radiation_climate_selection_record), intent(inout), target :: selection
    type(forecast_physical_constants), intent(in), target :: constants
    type(tephy), intent(in), target :: physics
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
    if (len(text) < 1 .or. len(text) > 262144) return
    if (.not. upstream%lecmwf .or. upstream%larpegef .or. .not. upstream%lephys) return
    if (upstream%lrayfm .or. .not. upstream%lopt_scalar) return
    if (upstream%lape .or. upstream%lhlradupd .or. upstream%lray .or. upstream%laeruvp) return
    if (.not. upstream%leradi .or. upstream%leradlw2 .or. upstream%nemissscheme /= 0 .or. upstream%leradn2) return
    if (transfer(upstream%radgr, 0_int64) /= 0_int64 .or. transfer(upstream%radsn, 0_int64) /= 0_int64) return
    ! Only NSMAX is consumed from the source dimension words.
    if (upstream%nsmax < 1 .or. upstream%nsmax > 8191) return
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
                 transfer(c_loc(physics), 0_c_intptr_t), 0_c_intptr_t]
    lengths = [storage_size(radiation, kind=int64)/8_int64, storage_size(gases, kind=int64)/8_int64, &
               storage_size(uv, kind=int64)/8_int64, storage_size(longwave, kind=int64)/8_int64, &
               storage_size(cmip, kind=int64)/8_int64, storage_size(scalars, kind=int64)/8_int64, &
               storage_size(selection, kind=int64)/8_int64, storage_size(constants, kind=int64)/8_int64, &
              storage_size(upstream, kind=int64)/8_int64, int(len(text), int64), storage_size(physics, kind=int64)/8_int64, 0_int64]
    do first = 1, 7
      do second = first + 1, 11
        if (lengths(second) == 0_int64) cycle
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    climate_upstream%lephys = upstream%lephys
    climate_upstream%larpegef = upstream%larpegef
    climate_upstream%lrayfm = upstream%lrayfm
    climate_upstream%ozone_lgp = upstream%ozone_lgp
    climate_upstream%lopt_scalar = upstream%lopt_scalar
    status = select_runtime_radiation_prefix_climate(text, climate_upstream, staged_selection)
    if (status /= 0_int32) then
      errno_value = incoming_errno
      return
    end if
    staged_selection%values%nrproma = -8_int32
    status = apply_radiation_owner_namelist(text, staged_selection)
    if (status /= 0_int32) then
      errno_value = incoming_errno
      return
    end if
    if (staged_selection%values%nrproma /= 0 .and. staged_selection%values%nrproma /= -8) then
      status = 2_int32
      errno_value = incoming_errno
      return
    end if
    if (.not. staged_selection%values%lsrtm) then
      status = 2_int32
      errno_value = incoming_errno
      return
    end if
    staged_selection%values%nrproma = 8_int32
    staged_gases = gases
    call apply_radiation_control_literal_fields(staged_radiation, staged_gases, uv, cmip, scalars, .true., .true.)
    call prepare_radiation_visibility_constants(staged_radiation, staged_gases, constants)
    errno_value = incoming_errno
    status = create_selected_spectral_planck(staged_radiation%yspectplanck, constants)
    if (status /= 0_int32) return
    call apply_radiation_control_literal_fields(staged_radiation, staged_gases, uv, cmip, scalars, .false., .true.)
    call complete_selected_radiation_control_fields(staged_radiation, staged_gases, uv, longwave, cmip, scalars, &
                                    staged_selection%values, upstream%nproma, upstream%ngptot, upstream%ngptotmx, constants, .true.)
    call commit_selected_radiation_control_fields(radiation, staged_radiation)
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

end module forecast_runtime_radiation_control_prefix
