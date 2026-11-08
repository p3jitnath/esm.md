!> Select scalar requests, scan levels and construct spectral/grid request lists.
!! Field codes and indices are dimensionless. Level values keep their input units and bits.
!! All allocations and borrowed level-pointer lifetimes remain with the caller's records.
module forecast_runtime_output_request_selection
  use iso_fortran_env, only: int32, int64, real64
  use forecast_output_request_status
  use forecast_output_request_types
  use forecast_fullpos_state_types
  use forecast_output_request_storage, only: deallocate_output_request, &
                                             allocate_output_io_owners, release_output_io_requests
  implicit none
  private
  public :: select_runtime_scalar_output_request, finalize_runtime_scalar_output_request, scan_runtime_output_metadata
  public :: construct_runtime_output_request_metadata, output_scan_count
contains
  logical function request_storage_ready(request) result(ready)
    type(type_fprqdyn), intent(in) :: request
    integer :: levels
    ready = .false.
    if (.not. allocated(request%nfptrdyn)) return
    if (.not. allocated(request%ll)) return
    if (.not. allocated(request%isf)) return
    if (.not. allocated(request%iskp)) return
    if (.not. allocated(request%iled)) return
    if (.not. allocated(request%ilev)) return
    if (.not. allocated(request%ilvp)) return
    if (.not. allocated(request%idom)) return
    if (.not. allocated(request%idmp)) return
    if (.not. allocated(request%igpx)) return
    if (.not. allocated(request%igt1)) return
    if (.not. allocated(request%iset)) return
    if (.not. allocated(request%iloc)) return
    if (.not. allocated(request%ispd)) return
    if (size(request%nfptrdyn) /= 686 .or. size(request%ll) /= 686 .or. size(request%isf) /= 686) return
    if (size(request%iskp) /= 686 .or. size(request%iled) /= 686 .or. size(request%ilev) /= 686) return
    if (size(request%igpx) /= 686 .or. any(shape(request%igt1) /= [686, 3])) return
    if (lbound(request%igt1, 2) /= 0 .or. ubound(request%igt1, 2) /= 2) return
    levels = size(request%ilvp, 1)
    if (levels < 1 .or. levels > 512 .or. size(request%ilvp, 2) /= 686) return
    if (any(shape(request%idom) /= [levels, 686])) return
    if (any(shape(request%idmp) /= [1, levels, 686])) return
    if (any(shape(request%iset) /= [levels, 686])) return
    if (any(shape(request%iloc) /= [levels, 686])) return
    if (any(shape(request%ispd) /= [levels, 686])) return
    ready = .true.
  end function
  !> Keep surface-before-upper-air source selection and preserve unwritten array cells.
  !> Select all requested scalar dynamics from the actual AFN field table.
  integer(int32) function select_runtime_scalar_output_request(request, upper, surface, fullpos, &
                                                               include_surface, scan_character) result(status)
    type(type_fprqdyn), intent(inout) :: request
    type(trq3fp), intent(in) :: upper
    type(trq2fp), intent(in) :: surface
    type(native_fullpos_state), intent(in) :: fullpos
    logical, intent(in) :: include_surface
    character, intent(in) :: scan_character
    integer :: fit, filter, code, field, level, nlevels, domains
    logical :: enabled
    status = 116
    if (.not. request_storage_ready(request)) return
    request%ll = .false.; request%isf = 0; request%iskp = 0; request%iled = 0; request%ilev = 0
    if (include_surface) then
      if (surface%nppfieldg < 0 .or. surface%nppfieldg > 256) return
      if (surface%nppfieldg > 0) then
        if (.not. allocated(surface%icod) .or. .not. allocated(surface%idom) .or. .not. allocated(surface%idmp)) return
        if (size(surface%icod) < surface%nppfieldg .or. size(surface%idom) < surface%nppfieldg) return
        if (size(surface%idmp, 1) < 1 .or. size(surface%idmp, 2) < surface%nppfieldg) return
      end if
      do field = 1, surface%nppfieldg
        code = surface%icod(field)
        if (code < 1 .or. code > 686) return
        fit = 0
        if (.not. fullpos%yafn%tfp_dynds(code)%llgp) then
          fit = fullpos%yafn%tfp_dynds(code)%isf
          if (fit == 3) fit = 1
        end if
        if (fit < 0 .or. fit > 1) then
          status = 109
          return
        end if
        request%isf(code) = fit
        request%ll(code) = .true.
        request%ilev(code) = 1
        request%ilvp(1, code) = 1
        domains = surface%idom(field)
        if (domains < 0 .or. domains > 1) return
        request%idom(1, code) = domains
        if (domains == 1) request%idmp(1, 1, code) = surface%idmp(1, field)
      end do
    end if
    request%ifit = upper%nfit
    if (upper%nppfieldg < 0 .or. upper%nppfieldg > 256) return
    if (upper%nppfieldg > 0) then
      if (.not. allocated(upper%icod) .or. .not. allocated(upper%npplevg)) return
      if (.not. allocated(upper%ilev) .or. .not. allocated(upper%idom) .or. .not. allocated(upper%idmp)) return
      if (size(upper%icod) < upper%nppfieldg .or. size(upper%npplevg) < upper%nppfieldg) return
    end if
    do field = 1, upper%nppfieldg
      code = upper%icod(field)
      if (code < 1 .or. code > 686) return
      enabled = index(fullpos%yafn%tfp_dynds(code)%clnil, scan_character) == 0
      request%ll(code) = enabled
      fit = 0
      if (.not. fullpos%yafn%tfp_dynds(code)%llgp) then
        if (upper%nfit == 1 .or. upper%nfit == 2) then
          filter = upper%nspfil
          if (filter == 3) filter = 1
          fit = max(fullpos%yafn%tfp_dynds(code)%isf, filter)
          if (fit == 3) fit = 1
        end if
      end if
      if (enabled .and. (fit < 0 .or. fit > 1)) then
        status = 109
        return
      end if
      request%isf(code) = fit
      nlevels = upper%npplevg(field)
      if (nlevels < 0 .or. nlevels > size(request%ilvp, 1)) return
      if (nlevels > size(upper%ilev, 1) .or. field > size(upper%ilev, 2)) return
      request%ilev(code) = nlevels
      do level = 1, nlevels
        request%ilvp(level, code) = upper%ilev(level, field)
        domains = upper%idom(level, field)
        if (domains < 0 .or. domains > 1) return
        request%idom(level, code) = domains
        if (domains == 1) request%idmp(1, level, code) = upper%idmp(1, level, field)
      end do
    end do
    status = finalize_runtime_scalar_output_request(request)
  end function

  !> Form pointers and scalar counts by increasing internal field and level index.
  integer(int32) function finalize_runtime_scalar_output_request(request) result(status)
    type(type_fprqdyn), intent(inout) :: request
    integer :: field, level, nlevels, fit, selected, spectral, grid, t1_pointer, t0_pointer, grid_pointer, source_fit
    status = 116
    if (.not. request_storage_ready(request)) return
    source_fit = request%ifit
    request%iset = 1
    request%iloc = 0
    request%ispd = 0
    request%igpx = 0
    request%igt1 = 0
    request%nfpgt1 = 0
    request%nfpauxb = 0
    request%nfpvec = 0
    request%nfpsca = 0
    request%nfpspd = 0
    request%nfpspb = 0
    request%nfpgt0b = 0
    request%nfpdynb = 0
    request%nfpscag = 0
    request%nfpvecg = 0
    request%nfpivec = 0
    request%nfpisca = 0
    request%nfpivecg = 0
    request%nfpiscag = 0
    request%nfpuvmn = 0
    request%ifit = source_fit
    selected = 0
    spectral = 0
    grid = 0
    t1_pointer = 1
    t0_pointer = 1
    grid_pointer = 1
    do field = 1, 686
      if (.not. request%ll(field)) then
        request%isf(field) = 0
        request%ilev(field) = 0
        cycle
      end if
      selected = selected + 1
      request%nfptrdyn(selected) = field
      request%iskp(field) = 1
      nlevels = request%ilev(field)
      fit = request%isf(field)
      if (nlevels < 0 .or. nlevels > size(request%ispd, 1)) return
      do level = 1, nlevels
        request%ispd(level, field) = 1
        if (fit >= 1) request%iloc(level, field) = spectral + level
      end do
      if (fit >= 1) then
        request%igt1(field, 1) = t1_pointer
        request%igt1(field, 0) = t0_pointer
        t1_pointer = t1_pointer + nlevels
        spectral = spectral + nlevels
        if (source_fit /= 2) t0_pointer = t0_pointer + nlevels
      else
        request%igpx(field) = grid_pointer
        grid_pointer = grid_pointer + nlevels
        grid = grid + nlevels
      end if
    end do
    request%nfposdyn = selected
    request%nfpgt1 = spectral
    request%nfpauxb = grid
    request%nfpsca = spectral
    request%nfpspb = spectral
    if (source_fit /= 2) request%nfpgt0b = spectral
    request%nfpdynb = spectral + grid
    request%nfpscag = spectral
    request%nfpisca = spectral
    request%nfpiscag = spectral
    status = 0
  end function
  !> Select one of seven original scans and return a borrowed pointer to its level owner.
  integer(int32) function scan_runtime_output_metadata(fullpos, dynamic, request, spectral, grid, scan, include_surface, &
                                         level_count, level_values, end_scan, nprtrv, mysetv, filter_flags, counters) result(status)
    type(native_fullpos_state), intent(in) :: fullpos
    type(trqfpdyn), target, intent(in) :: dynamic
    type(type_fprqdyn), intent(inout) :: request
    type(trqfp), intent(inout) :: spectral, grid
    integer(int32), intent(in) :: scan, nprtrv, mysetv
    logical, intent(in) :: include_surface, end_scan, filter_flags(:)
    integer(int32), intent(inout) :: level_count
    real(real64), pointer, intent(inout) :: level_values(:)
    type(native_output_service_counters), intent(inout) :: counters
    type(trq3fp), pointer :: selected
    character(7), parameter :: scan_character = 'BVTHSKF'
    integer :: i
    status = 116
    if (fullpos%yfpcnt%nfpconf /= 0) return
    status = 109
    if (scan < 1 .or. scan > 7) return
    select case (scan)
    case (1)
      selected => dynamic%ypr
    case (2)
      selected => dynamic%ypv
    case (3)
      selected => dynamic%yth
    case (4)
      selected => dynamic%yho
    case (5)
      selected => dynamic%yes
    case (6)
      selected => dynamic%yit
    case (7)
      selected => dynamic%yfl
    end select
    level_count = selected%npxlev
    if (allocated(selected%zpxlev)) then
      level_values => selected%zpxlev
    else
      nullify (level_values)
    end if
    if (end_scan) then
      if (request%nfpdynb > 0) then
        status = release_output_io_requests(spectral, grid, counters)
        if (status /= 0) return
      end if
      status = deallocate_output_request(request, counters)
      if (status /= 0) return
      call increment_output_counter(counters%scan(1))
    else
      status = 116
      if (nprtrv /= 1 .or. mysetv /= 1) return
      status = allocate_runtime_output_request(request, 1_int32, level_count, counters)
      if (status /= 0) return
      status = select_runtime_scalar_output_request(request, selected, dynamic%y2d, fullpos, include_surface, &
                                                    scan_character(scan:scan))
      if (status /= 0) return
      do i = 1, size(filter_flags)
        if (filter_flags(i)) then
          status = 109
          return
        end if
      end do
      call increment_output_counter(counters%scan(0))
    end if
    status = 0
  end function
  !> Build the sixteen-owner I/O lists in field and level order without changing inputs.
  integer(int32) function construct_runtime_output_request_metadata(fullpos, request, spectral, grid, scan, &
                                                                    level_count, levels, counters) result(status)
    type(native_fullpos_state), intent(in) :: fullpos
    type(type_fprqdyn), intent(in) :: request
    type(trqfp), target, intent(inout) :: spectral, grid
    integer(int32), intent(in) :: scan, level_count
    real(real64), intent(in) :: levels(:)
    type(native_output_service_counters), intent(inout) :: counters
    type(trqfp), pointer :: destination
    integer :: field, code, level, nlevels, position, spectral_count, grid_count, level_index, domains
    logical :: fitted, surface
    status = 116
    if (fullpos%yfpcnt%nfpconf /= 0 .or. .not. request_storage_ready(request)) return
    if (level_count < 0 .or. level_count > 512 .or. size(levels) < level_count) return
    if (request%nfpdynb < 0 .or. request%nfpdynb > 65536) return
    if (request%nfpauxb < 0 .or. request%nfpauxb > request%nfpdynb) return
    spectral%nfieldg = request%nfpdynb - request%nfpauxb
    grid%nfieldg = request%nfpauxb
    spectral%nfieldl = request%nfpspb
    status = allocate_output_io_owners(spectral, grid)
    if (status /= 0) return
    status = 116
    spectral_count = 0
    grid_count = 0
    if (request%nfposdyn < 0 .or. request%nfposdyn > 686) return
    do field = 1, request%nfposdyn
      code = request%nfptrdyn(field)
      if (code < 1 .or. code > 686) return
      nlevels = request%ilev(code)
      if (nlevels < 0 .or. nlevels > 512) return
      fitted = request%isf(code) >= 1
      do level = 1, nlevels
        if (fitted) then
          destination => spectral
          position = spectral_count + 1
        else
          destination => grid
          position = grid_count + 1
        end if
        if (position > destination%nfieldg) return
        destination%icod(position) = code
        surface = fullpos%yafn%tfp_dynds(code)%llsrf
        destination%llsurf(position) = surface
        destination%igrib(position) = fullpos%yafn%tfp_dynds(code)%igrib
        destination%clpref(position) = ' '
        if (surface) then
          destination%clpref(position) (1:4) = fullpos%yafn%tfp_dynds(code)%clname(1:4)
          destination%zlev(position) = 0.0_real64
          destination%clname(position) = fullpos%yafn%tfp_dynds(code)%clname(5:16)
        else
          if (scan == 5) then
            destination%clpref(position) (1:1) = 'S'
          else
            destination%clpref(position) (1:1) = 'P'
          end if
          level_index = request%ilvp(level, code)
          if (level_index < 1 .or. level_index > level_count) return
          destination%zlev(position) = levels(level_index)
          destination%clname(position) = fullpos%yafn%tfp_dynds(code)%clname(1:12)
        end if
        if (fitted) then
          spectral%ivsetg(position) = request%iset(level, code)
          spectral%ivlocg(position) = request%iloc(level, code)
          spectral_count = spectral_count + 1
        else
          domains = request%idom(level, code)
          if (domains < 0 .or. domains > 1) return
          grid%idom(position) = domains
          grid%idmp(1, position) = 0
          if (domains == 1) grid%idmp(1, position) = request%idmp(1, level, code)
          grid_count = grid_count + 1
        end if
      end do
    end do
    if (spectral_count /= spectral%nfieldg .or. grid_count /= grid%nfieldg) return
    call increment_output_counter(counters%io_request(0))
    status = 0
  end function
  integer(int64) function output_scan_count(index, counters) result(value)
    integer(int64), intent(in) :: index
    type(native_output_service_counters), intent(in) :: counters
    value = 0
    if (index >= 0 .and. index <= 1) value = counters%scan(index)
  end function
  integer(int32) function allocate_runtime_output_request(request, domains, levels, counters) result(status)
    type(type_fprqdyn), intent(inout) :: request
    integer(int32), intent(in) :: domains, levels
    type(native_output_service_counters), intent(inout) :: counters
    integer :: effective_levels
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    effective_levels = max(1, levels)
    if (domains < 1 .or. domains > 8 .or. effective_levels > 512) return
    if (allocated(request%nfptrdyn)) return
    if (allocated(request%ll)) return
    if (allocated(request%isf)) return
    if (allocated(request%iskp)) return
    if (allocated(request%iled)) return
    if (allocated(request%ilev)) return
    if (allocated(request%ilvp)) return
    if (allocated(request%idom)) return
    if (allocated(request%idmp)) return
    if (allocated(request%igpx)) return
    if (allocated(request%igt1)) return
    if (allocated(request%iset)) return
    if (allocated(request%iloc)) return
    if (allocated(request%ispd)) return
    call save_output_status(saved, error_slot, error_before)
    request%nfposdyn = 0
    allocate (request%nfptrdyn(686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%ll(686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%isf(686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%iskp(686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%iled(686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%ilev(686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%ilvp(effective_levels, 686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idom(effective_levels, 686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idmp(domains, effective_levels, 686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%igpx(686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%igt1(686, 0:2), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%iset(effective_levels, 686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%iloc(effective_levels, 686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%ispd(effective_levels, 686), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    call increment_output_counter(counters%request_allocation(0))
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
end module forecast_runtime_output_request_selection
