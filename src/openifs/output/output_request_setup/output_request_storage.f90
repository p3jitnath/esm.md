!> Own the complete selected output allocation, cleanup and counter children.
!! Canonical named records carry native compiler descriptors and exclusive allocations.
!! Status is 0 on success, 1 on allocation failure and 2 on unsupported admission.
!! Source fatal-only allocation failures return their acquired prefix to the typed caller.
module forecast_output_request_storage
  use iso_fortran_env, only: int32, int64, real64
  use forecast_output_request_types
  use forecast_output_request_status
  implicit none
  private
  public :: allocate_output_request, deallocate_output_request, allocate_dynamic_3d_request
  public :: allocate_dynamic_2d_request, allocate_empty_physical_request, allocate_output_io_owners
  public :: release_output_io_requests, release_fullpos_requests, release_output_header
  public :: output_request_allocation_count, output_request_release_count, output_io_request_count
  public :: empty_physical_request_count, spectral_fit_count, spectral_log_count
contains
  !> Allocate all fourteen request arrays in source order; do not write their payloads.
  integer(int32) function allocate_output_request(request, domains, levels, counters) result(status)
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
    if (domains < 1 .or. domains > 8 .or. effective_levels > 64) return
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
  !> Release all fourteen owned arrays, then reset the sixteen source counters.
  integer(int32) function deallocate_output_request(request, counters) result(status)
    type(type_fprqdyn), intent(inout) :: request
    type(native_output_service_counters), intent(inout) :: counters
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
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
    call save_output_status(saved, error_slot, error_before)
    request%nfposdyn = 0
    if (allocated(request%nfptrdyn)) deallocate (request%nfptrdyn)
    if (allocated(request%ll)) deallocate (request%ll)
    if (allocated(request%isf)) deallocate (request%isf)
    if (allocated(request%iskp)) deallocate (request%iskp)
    if (allocated(request%iled)) deallocate (request%iled)
    if (allocated(request%ilev)) deallocate (request%ilev)
    if (allocated(request%ilvp)) deallocate (request%ilvp)
    if (allocated(request%idom)) deallocate (request%idom)
    if (allocated(request%idmp)) deallocate (request%idmp)
    if (allocated(request%igpx)) deallocate (request%igpx)
    if (allocated(request%igt1)) deallocate (request%igt1)
    if (allocated(request%iset)) deallocate (request%iset)
    if (allocated(request%iloc)) deallocate (request%iloc)
    if (allocated(request%ispd)) deallocate (request%ispd)
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
    request%ifit = 0
    call increment_output_counter(counters%request_allocation(1))
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Allocate one three-dimensional request with one domain and source level indices.
  integer(int32) function allocate_dynamic_3d_request(request, field_count, level_count) result(status)
    type(trq3fp), intent(inout) :: request
    integer(int32), intent(in) :: field_count, level_count
    integer :: field, level
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    if (field_count < 0 .or. field_count > 64 .or. level_count < 0 .or. level_count > 64) return
    if (allocated(request%zpxlev)) return
    if (allocated(request%icod)) return
    if (allocated(request%npplevg)) return
    if (allocated(request%ilev)) return
    if (allocated(request%idom)) return
    if (allocated(request%idmp)) return
    call save_output_status(saved, error_slot, error_before)
    request%nppfieldg = field_count
    request%npxlev = level_count
    request%nfit = 0
    request%nspfil = 1
    allocate (request%zpxlev(level_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%icod(field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%npplevg(field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    request%npplevg = level_count
    allocate (request%ilev(level_count, field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idom(level_count, field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idmp(1, level_count, field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do field = 1, field_count
      do level = 1, level_count
        request%ilev(level, field) = level
        request%idom(level, field) = 1
        request%idmp(1, level, field) = 1
      end do
    end do
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Allocate one surface request and set its single-domain mapping.
  integer(int32) function allocate_dynamic_2d_request(request, field_count) result(status)
    type(trq2fp), intent(inout) :: request
    integer(int32), intent(in) :: field_count
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    if (field_count < 0 .or. field_count > 64) return
    if (allocated(request%icod)) return
    if (allocated(request%idom)) return
    if (allocated(request%idmp)) return
    call save_output_status(saved, error_slot, error_before)
    request%nppfieldg = field_count
    allocate (request%icod(field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idom(field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idmp(1, field_count), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    request%idom = 1
    request%idmp = 1
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Allocate the eight source-owned empty arrays; logical payload size is zero.
  integer(int32) function allocate_empty_physical_request(request, domains, counters) result(status)
    type(trqfp), intent(inout) :: request
    integer(int32), intent(in) :: domains
    type(native_output_service_counters), intent(inout) :: counters
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    if (domains < 1 .or. domains > 8) return
    if (allocated(request%icod)) return
    if (allocated(request%igrib)) return
    if (allocated(request%llsurf)) return
    if (allocated(request%clname)) return
    if (allocated(request%clpref)) return
    if (allocated(request%ivec)) return
    if (allocated(request%idom)) return
    if (allocated(request%idmp)) return
    call save_output_status(saved, error_slot, error_before)
    request%nfieldg = 0
    allocate (request%icod(0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%igrib(0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%llsurf(0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%clname(0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%clpref(0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%ivec(0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idom(0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (request%idmp(domains, 0), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    call increment_output_counter(counters%empty_physical)
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Allocate the sixteen spectral and grid request owners in source order.
  integer(int32) function allocate_output_io_owners(spectral, grid) result(status)
    type(trqfp), intent(inout) :: spectral, grid
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    if (spectral%nfieldg < 0 .or. spectral%nfieldg > 4096 .or. grid%nfieldg < 0 .or. grid%nfieldg > 4096) return
    if (allocated(grid%icod)) return
    if (allocated(grid%llsurf)) return
    if (allocated(grid%zlev)) return
    if (allocated(grid%idom)) return
    if (allocated(grid%idmp)) return
    if (allocated(spectral%icod)) return
    if (allocated(spectral%llsurf)) return
    if (allocated(spectral%zlev)) return
    if (allocated(spectral%ivsetg)) return
    if (allocated(spectral%ivlocg)) return
    if (allocated(spectral%clpref)) return
    if (allocated(spectral%clname)) return
    if (allocated(spectral%igrib)) return
    if (allocated(grid%clpref)) return
    if (allocated(grid%clname)) return
    if (allocated(grid%igrib)) return
    call save_output_status(saved, error_slot, error_before)
    allocate (grid%icod(grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (grid%llsurf(grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (grid%zlev(grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (grid%idom(grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (grid%idmp(1, grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%icod(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%llsurf(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%zlev(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%ivsetg(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%ivlocg(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%clpref(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%clname(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (spectral%igrib(spectral%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (grid%clpref(grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (grid%clname(grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    allocate (grid%igrib(grid%nfieldg), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Release the same sixteen owners while preserving request counts and unused arrays.
  integer(int32) function release_output_io_requests(spectral, grid, counters) result(status)
    type(trqfp), intent(inout) :: spectral, grid
    type(native_output_service_counters), intent(inout) :: counters
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    if (.not. allocated(grid%icod)) return
    if (.not. allocated(grid%llsurf)) return
    if (.not. allocated(grid%zlev)) return
    if (.not. allocated(grid%idom)) return
    if (.not. allocated(grid%idmp)) return
    if (.not. allocated(spectral%icod)) return
    if (.not. allocated(spectral%llsurf)) return
    if (.not. allocated(spectral%zlev)) return
    if (.not. allocated(spectral%ivsetg)) return
    if (.not. allocated(spectral%ivlocg)) return
    if (.not. allocated(spectral%clpref)) return
    if (.not. allocated(spectral%clname)) return
    if (.not. allocated(spectral%igrib)) return
    if (.not. allocated(grid%clpref)) return
    if (.not. allocated(grid%clname)) return
    if (.not. allocated(grid%igrib)) return
    call save_output_status(saved, error_slot, error_before)
    if (allocated(grid%icod)) deallocate (grid%icod)
    if (allocated(grid%llsurf)) deallocate (grid%llsurf)
    if (allocated(grid%zlev)) deallocate (grid%zlev)
    if (allocated(grid%idom)) deallocate (grid%idom)
    if (allocated(grid%idmp)) deallocate (grid%idmp)
    if (allocated(spectral%icod)) deallocate (spectral%icod)
    if (allocated(spectral%llsurf)) deallocate (spectral%llsurf)
    if (allocated(spectral%zlev)) deallocate (spectral%zlev)
    if (allocated(spectral%ivsetg)) deallocate (spectral%ivsetg)
    if (allocated(spectral%ivlocg)) deallocate (spectral%ivlocg)
    if (allocated(spectral%clpref)) deallocate (spectral%clpref)
    if (allocated(spectral%clname)) deallocate (spectral%clname)
    if (allocated(spectral%igrib)) deallocate (spectral%igrib)
    if (allocated(grid%clpref)) deallocate (grid%clpref)
    if (allocated(grid%clname)) deallocate (grid%clname)
    if (allocated(grid%igrib)) deallocate (grid%igrib)
    call increment_output_counter(counters%io_request(1))
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Release physical, dynamic and field owners in the original argument and declaration order.
  integer(int32) function release_fullpos_requests(fields, physical, dynamic, counters) result(status)
    type(tfpfields), intent(inout) :: fields
    type(trqfp), intent(inout) :: physical
    type(trqfpdyn), intent(inout) :: dynamic
    type(native_output_service_counters), intent(inout) :: counters
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    call save_output_status(saved, error_slot, error_before)
    call increment_output_counter(counters%request_release(0))
    if (allocated(physical%icod)) deallocate (physical%icod)
    if (allocated(physical%igrib)) deallocate (physical%igrib)
    if (allocated(physical%llsurf)) deallocate (physical%llsurf)
    if (allocated(physical%ivec)) deallocate (physical%ivec)
    if (allocated(physical%zlev)) deallocate (physical%zlev)
    if (allocated(physical%clname)) deallocate (physical%clname)
    if (allocated(physical%clpref)) deallocate (physical%clpref)
    if (allocated(physical%idom)) deallocate (physical%idom)
    if (allocated(physical%idmp)) deallocate (physical%idmp)
    if (allocated(physical%ivsetg)) deallocate (physical%ivsetg)
    if (allocated(physical%ivlocg)) deallocate (physical%ivlocg)
    physical%nfieldg = 0
    physical%nfieldl = 0
    if (allocated(dynamic%ypr%zpxlev)) deallocate (dynamic%ypr%zpxlev)
    if (allocated(dynamic%ypr%icod)) deallocate (dynamic%ypr%icod)
    if (allocated(dynamic%ypr%npplevg)) deallocate (dynamic%ypr%npplevg)
    if (allocated(dynamic%ypr%ilev)) deallocate (dynamic%ypr%ilev)
    if (allocated(dynamic%ypr%idom)) deallocate (dynamic%ypr%idom)
    if (allocated(dynamic%ypr%idmp)) deallocate (dynamic%ypr%idmp)
    dynamic%ypr%nppfieldg = 0
    dynamic%ypr%npxlev = 0
    dynamic%ypr%nfit = 0
    dynamic%ypr%nspfil = 1
    if (allocated(dynamic%yth%zpxlev)) deallocate (dynamic%yth%zpxlev)
    if (allocated(dynamic%yth%icod)) deallocate (dynamic%yth%icod)
    if (allocated(dynamic%yth%npplevg)) deallocate (dynamic%yth%npplevg)
    if (allocated(dynamic%yth%ilev)) deallocate (dynamic%yth%ilev)
    if (allocated(dynamic%yth%idom)) deallocate (dynamic%yth%idom)
    if (allocated(dynamic%yth%idmp)) deallocate (dynamic%yth%idmp)
    dynamic%yth%nppfieldg = 0
    dynamic%yth%npxlev = 0
    dynamic%yth%nfit = 0
    dynamic%yth%nspfil = 1
    if (allocated(dynamic%ypv%zpxlev)) deallocate (dynamic%ypv%zpxlev)
    if (allocated(dynamic%ypv%icod)) deallocate (dynamic%ypv%icod)
    if (allocated(dynamic%ypv%npplevg)) deallocate (dynamic%ypv%npplevg)
    if (allocated(dynamic%ypv%ilev)) deallocate (dynamic%ypv%ilev)
    if (allocated(dynamic%ypv%idom)) deallocate (dynamic%ypv%idom)
    if (allocated(dynamic%ypv%idmp)) deallocate (dynamic%ypv%idmp)
    dynamic%ypv%nppfieldg = 0
    dynamic%ypv%npxlev = 0
    dynamic%ypv%nfit = 0
    dynamic%ypv%nspfil = 1
    if (allocated(dynamic%yho%zpxlev)) deallocate (dynamic%yho%zpxlev)
    if (allocated(dynamic%yho%icod)) deallocate (dynamic%yho%icod)
    if (allocated(dynamic%yho%npplevg)) deallocate (dynamic%yho%npplevg)
    if (allocated(dynamic%yho%ilev)) deallocate (dynamic%yho%ilev)
    if (allocated(dynamic%yho%idom)) deallocate (dynamic%yho%idom)
    if (allocated(dynamic%yho%idmp)) deallocate (dynamic%yho%idmp)
    dynamic%yho%nppfieldg = 0
    dynamic%yho%npxlev = 0
    dynamic%yho%nfit = 0
    dynamic%yho%nspfil = 1
    if (allocated(dynamic%yes%zpxlev)) deallocate (dynamic%yes%zpxlev)
    if (allocated(dynamic%yes%icod)) deallocate (dynamic%yes%icod)
    if (allocated(dynamic%yes%npplevg)) deallocate (dynamic%yes%npplevg)
    if (allocated(dynamic%yes%ilev)) deallocate (dynamic%yes%ilev)
    if (allocated(dynamic%yes%idom)) deallocate (dynamic%yes%idom)
    if (allocated(dynamic%yes%idmp)) deallocate (dynamic%yes%idmp)
    dynamic%yes%nppfieldg = 0
    dynamic%yes%npxlev = 0
    dynamic%yes%nfit = 0
    dynamic%yes%nspfil = 1
    if (allocated(dynamic%yfl%zpxlev)) deallocate (dynamic%yfl%zpxlev)
    if (allocated(dynamic%yfl%icod)) deallocate (dynamic%yfl%icod)
    if (allocated(dynamic%yfl%npplevg)) deallocate (dynamic%yfl%npplevg)
    if (allocated(dynamic%yfl%ilev)) deallocate (dynamic%yfl%ilev)
    if (allocated(dynamic%yfl%idom)) deallocate (dynamic%yfl%idom)
    if (allocated(dynamic%yfl%idmp)) deallocate (dynamic%yfl%idmp)
    dynamic%yfl%nppfieldg = 0
    dynamic%yfl%npxlev = 0
    dynamic%yfl%nfit = 0
    dynamic%yfl%nspfil = 1
    if (allocated(dynamic%yit%zpxlev)) deallocate (dynamic%yit%zpxlev)
    if (allocated(dynamic%yit%icod)) deallocate (dynamic%yit%icod)
    if (allocated(dynamic%yit%npplevg)) deallocate (dynamic%yit%npplevg)
    if (allocated(dynamic%yit%ilev)) deallocate (dynamic%yit%ilev)
    if (allocated(dynamic%yit%idom)) deallocate (dynamic%yit%idom)
    if (allocated(dynamic%yit%idmp)) deallocate (dynamic%yit%idmp)
    dynamic%yit%nppfieldg = 0
    dynamic%yit%npxlev = 0
    dynamic%yit%nfit = 0
    dynamic%yit%nspfil = 1
    if (allocated(dynamic%y2d%icod)) deallocate (dynamic%y2d%icod)
    if (allocated(dynamic%y2d%idom)) deallocate (dynamic%y2d%idom)
    if (allocated(dynamic%y2d%idmp)) deallocate (dynamic%y2d%idmp)
    dynamic%y2d%nppfieldg = 0
    if (allocated(fields%cfp3df)) deallocate (fields%cfp3df)
    if (allocated(fields%cfp2df)) deallocate (fields%cfp2df)
    if (allocated(fields%cfpphy)) deallocate (fields%cfpphy)
    if (allocated(fields%cfpcfu)) deallocate (fields%cfpcfu)
    if (allocated(fields%cfpxfu)) deallocate (fields%cfpxfu)
    if (allocated(fields%mfp3dfs)) deallocate (fields%mfp3dfs)
    if (allocated(fields%mfp3dfp)) deallocate (fields%mfp3dfp)
    if (allocated(fields%mfp3dfh)) deallocate (fields%mfp3dfh)
    if (allocated(fields%mfp3dft)) deallocate (fields%mfp3dft)
    if (allocated(fields%mfp3dfv)) deallocate (fields%mfp3dfv)
    if (allocated(fields%mfp3dfi)) deallocate (fields%mfp3dfi)
    if (allocated(fields%mfp3dff)) deallocate (fields%mfp3dff)
    if (allocated(fields%mfp2df)) deallocate (fields%mfp2df)
    if (allocated(fields%mfpphy)) deallocate (fields%mfpphy)
    if (allocated(fields%rfp3p)) deallocate (fields%rfp3p)
    if (allocated(fields%rfp3h)) deallocate (fields%rfp3h)
    if (allocated(fields%rfp3th)) deallocate (fields%rfp3th)
    if (allocated(fields%rfp3pv)) deallocate (fields%rfp3pv)
    if (allocated(fields%rfp3i)) deallocate (fields%rfp3i)
    if (allocated(fields%rfp3f)) deallocate (fields%rfp3f)
    if (allocated(fields%nrfp3s)) deallocate (fields%nrfp3s)
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Release eleven physical-request arrays followed by the cached FP64 buffer.
  integer(int32) function release_output_header(header, counters) result(status)
    type(fposbuf), intent(inout) :: header
    type(native_output_service_counters), intent(inout) :: counters
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: ierr
    status = 2
    call save_output_status(saved, error_slot, error_before)
    call increment_output_counter(counters%request_release(1))
    if (allocated(header%yrqphy%icod)) deallocate (header%yrqphy%icod)
    if (allocated(header%yrqphy%igrib)) deallocate (header%yrqphy%igrib)
    if (allocated(header%yrqphy%llsurf)) deallocate (header%yrqphy%llsurf)
    if (allocated(header%yrqphy%ivec)) deallocate (header%yrqphy%ivec)
    if (allocated(header%yrqphy%zlev)) deallocate (header%yrqphy%zlev)
    if (allocated(header%yrqphy%clname)) deallocate (header%yrqphy%clname)
    if (allocated(header%yrqphy%clpref)) deallocate (header%yrqphy%clpref)
    if (allocated(header%yrqphy%idom)) deallocate (header%yrqphy%idom)
    if (allocated(header%yrqphy%idmp)) deallocate (header%yrqphy%idmp)
    if (allocated(header%yrqphy%ivsetg)) deallocate (header%yrqphy%ivsetg)
    if (allocated(header%yrqphy%ivlocg)) deallocate (header%yrqphy%ivlocg)
    if (allocated(header%fpbuf)) deallocate (header%fpbuf)
    header%yrqphy%nfieldg = 0
    header%yrqphy%nfieldl = 0
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Read a caller-owned serial observation; no service or numerical state changes.
  integer(int64) function output_request_allocation_count(counters, index) result(value)
    type(native_output_service_counters), intent(in) :: counters
    integer(int64), intent(in) :: index
    value = 0
    if (index >= 0 .and. index <= 1) value = counters%request_allocation(index)
  end function
  !> Read a caller-owned serial observation; no service or numerical state changes.
  integer(int64) function output_request_release_count(counters, index) result(value)
    type(native_output_service_counters), intent(in) :: counters
    integer(int64), intent(in) :: index
    value = 0
    if (index >= 0 .and. index <= 1) value = counters%request_release(index)
  end function
  !> Read a caller-owned serial observation; no service or numerical state changes.
  integer(int64) function output_io_request_count(counters, index) result(value)
    type(native_output_service_counters), intent(in) :: counters
    integer(int64), intent(in) :: index
    value = 0
    if (index >= 0 .and. index <= 1) value = counters%io_request(index)
  end function
  !> Read a caller-owned serial observation; no service or numerical state changes.
  integer(int64) function empty_physical_request_count(counters) result(value)
    type(native_output_service_counters), intent(in) :: counters
    value = counters%empty_physical
  end function
  !> Read a caller-owned serial observation; no service or numerical state changes.
  integer(int64) function spectral_fit_count(counters) result(value)
    type(native_output_service_counters), intent(in) :: counters
    value = counters%spectral_fit
  end function
  !> Read a caller-owned serial observation; no service or numerical state changes.
  integer(int64) function spectral_log_count(counters) result(value)
    type(native_output_service_counters), intent(in) :: counters
    value = counters%spectral_log
  end function
end module forecast_output_request_storage
