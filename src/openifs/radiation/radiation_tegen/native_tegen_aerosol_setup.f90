module native_tegen_aerosol_setup
  !! Own the serial shared monthly aerosol cache and its canonical record views.
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer
  use yoeaerc, only: TEAERC_TEGEN
  use native_tegen_literal_readers
  use native_tegen_volcanic_values, only: initialize_tegen_volcanic_values
  implicit none
  private
  public :: tegen_shared_cache, initialize_tegen_record_defaults
  public :: initialize_tegen_aerosol_climatology, release_tegen_aerosol_climatology
  type :: tegen_shared_cache
    !! Seven owned pointer targets. Calls are serial; keep this cache live until the last release.
    real(c_double), pointer, contiguous :: RAERBC(:, :, :) => null(), RAEROR(:, :, :) => null()
    real(c_double), pointer, contiguous :: RAERSD(:, :, :) => null(), RAERSS(:, :, :) => null(), RAERSU(:, :, :) => null()
    real(c_double), pointer, contiguous :: RAERV(:, :, :) => null(), RLATV(:) => null()
    integer(c_int) :: reference_count = 0_c_int
    logical :: volcanic_file_pending = .true.
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  function initialize_tegen_record_defaults(record) result(status)
    !! Fresh canonical records retain all source-unwritten inline arrays and descriptor metadata.
    type(TEAERC_TEGEN), intent(inout) :: record
    integer(c_int) :: status
    status = 2_c_int
    if (record%IS_INITIALISED) return
    if (record_has_view(record)) return
    record%REPAER = transfer(int(z'ffefffffffffffff', c_int64_t), 0.0_c_double)
    nullify (record%RAERBC, record%RAEROR, record%RAERSD, record%RAERSS, record%RAERSU, record%RAERV, record%RLATV)
    record%ISYEAR = 2100_c_int
    record%IEYEAR = 1850_c_int
    record%IS_INITIALISED = .false.
    status = 0_c_int
  end function
  function initialize_tegen_aerosol_climatology(record, cache, volcanic_filename, call_suecaec) result(status)
    !! Optical thickness is dimensionless. Monthly axes are longitude, latitude and month.
    !! First setup owns the seven allocations; later records borrow the same complete targets.
    type(TEAERC_TEGEN), intent(inout) :: record
    type(tegen_shared_cache), intent(inout) :: cache
    character(*), intent(in) :: volcanic_filename
    logical, intent(in) :: call_suecaec
    integer(c_int) :: status, child, saved_errno, failure_errno
    integer(c_int), pointer :: error_number
    type(tegen_shared_cache) :: private
    real(c_double) :: security
    integer :: allocation_status, i
    status = 2_c_int
    if (.not. call_suecaec .or. len(volcanic_filename) /= 260) return
    do i = 1, 260
      if (volcanic_filename(i:i) /= ' ') return
    end do
    if (record%IS_INITIALISED .or. record_has_view(record)) return
    if (cache%reference_count < 0 .or. cache%reference_count == huge(cache%reference_count)) return
    if (cache%reference_count == 0) then
      if (cache_has_owner(cache)) return
    else
      if (.not. cache_is_complete(cache)) return
    end if
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (cache%reference_count > 0) then
      cache%reference_count = cache%reference_count + 1
      call associate_record(record, cache)
      record%IS_INITIALISED = .true.
      error_number = saved_errno
      status = 0_c_int
      return
    end if
    status = 1_c_int
    allocate (private%RAERBC(72, 46, 12), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private%RAEROR(72, 46, 12), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private%RAERSD(72, 46, 12), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private%RAERSS(72, 46, 12), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private%RAERSU(72, 46, 12), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private%RAERV(24, 1850:2100, 12), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private%RLATV(24), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    status = 2_c_int
    child = read_tegen_black_carbon(private%RAERBC)
    if (child /= 0) goto 900
    child = read_tegen_organic_aerosol(private%RAEROR)
    if (child /= 0) goto 900
    child = read_tegen_soil_dust(private%RAERSD)
    if (child /= 0) goto 900
    child = read_tegen_sea_salt(private%RAERSS)
    if (child /= 0) goto 900
    child = read_tegen_sulfate(private%RAERSU)
    if (child /= 0) goto 900
    child = initialize_tegen_volcanic_values(private%RAERV, private%RLATV, security)
    if (child /= 0) goto 900
    cache%RAERBC => private%RAERBC
    cache%RAEROR => private%RAEROR
    cache%RAERSD => private%RAERSD
    cache%RAERSS => private%RAERSS
    cache%RAERSU => private%RAERSU
    cache%RAERV => private%RAERV
    cache%RLATV => private%RLATV
    nullify (private%RAERBC, private%RAEROR, private%RAERSD, private%RAERSS, private%RAERSU, private%RAERV, private%RLATV)
    record%REPAER = security
    cache%reference_count = 1_c_int
    cache%volcanic_file_pending = .false.
    call associate_record(record, cache)
    record%IS_INITIALISED = .true.
    error_number = saved_errno
    status = 0_c_int
    return
900 continue
    failure_errno = error_number
    call free_cache_owners(private)
    error_number = failure_errno
  end function
  function release_tegen_aerosol_climatology(record, cache) result(status)
    !! Release one borrower. The last release frees the seven shared owners in source order.
    !! Other inline arrays, years, REPAER and the cache's volcanic-file flag remain unchanged.
    type(TEAERC_TEGEN), intent(inout) :: record
    type(tegen_shared_cache), intent(inout) :: cache
    integer(c_int) :: status, saved_errno
    integer(c_int), pointer :: error_number
    status = 0_c_int
    if (.not. record%IS_INITIALISED) return
    status = 2_c_int
    if (cache%reference_count < 1) return
    if (.not. cache_is_complete(cache)) return
    if (.not. associated(record%RAERBC, cache%RAERBC)) return
    if (.not. associated(record%RAEROR, cache%RAEROR)) return
    if (.not. associated(record%RAERSD, cache%RAERSD)) return
    if (.not. associated(record%RAERSS, cache%RAERSS)) return
    if (.not. associated(record%RAERSU, cache%RAERSU)) return
    if (.not. associated(record%RAERV, cache%RAERV)) return
    if (.not. associated(record%RLATV, cache%RLATV)) return
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (cache%reference_count == 1) call free_cache_owners(cache)
    cache%reference_count = cache%reference_count - 1
    nullify (record%RAERBC, record%RAEROR, record%RAERSD, record%RAERSS, record%RAERSU, record%RAERV, record%RLATV)
    record%IS_INITIALISED = .false.
    error_number = saved_errno
    status = 0_c_int
  end function
  subroutine associate_record(record, cache)
    type(TEAERC_TEGEN), intent(inout) :: record
    type(tegen_shared_cache), intent(in) :: cache
    record%RAERBC => cache%RAERBC
    record%RAEROR => cache%RAEROR
    record%RAERSD => cache%RAERSD
    record%RAERSS => cache%RAERSS
    record%RAERSU => cache%RAERSU
    record%RAERV => cache%RAERV
    record%RLATV => cache%RLATV
  end subroutine
  subroutine free_cache_owners(cache)
    type(tegen_shared_cache), intent(inout) :: cache
    if (associated(cache%RAERBC)) deallocate (cache%RAERBC)
    if (associated(cache%RAEROR)) deallocate (cache%RAEROR)
    if (associated(cache%RAERSD)) deallocate (cache%RAERSD)
    if (associated(cache%RAERSS)) deallocate (cache%RAERSS)
    if (associated(cache%RAERSU)) deallocate (cache%RAERSU)
    if (associated(cache%RAERV)) deallocate (cache%RAERV)
    if (associated(cache%RLATV)) deallocate (cache%RLATV)
    nullify (cache%RAERBC, cache%RAEROR, cache%RAERSD, cache%RAERSS, cache%RAERSU, cache%RAERV, cache%RLATV)
  end subroutine
  function record_has_view(record) result(has_view)
    type(TEAERC_TEGEN), intent(in) :: record
    logical :: has_view
    has_view = associated(record%RAERBC) .or. associated(record%RAEROR) .or. associated(record%RAERSD) .or. &
               associated(record%RAERSS) .or. associated(record%RAERSU) .or. associated(record%RAERV) .or. associated(record%RLATV)
  end function
  function cache_has_owner(cache) result(has_owner)
    type(tegen_shared_cache), intent(in) :: cache
    logical :: has_owner
    has_owner = associated(cache%RAERBC) .or. associated(cache%RAEROR) .or. associated(cache%RAERSD) .or. &
                associated(cache%RAERSS) .or. associated(cache%RAERSU) .or. associated(cache%RAERV) .or. associated(cache%RLATV)
  end function
  function cache_is_complete(cache) result(complete)
    type(tegen_shared_cache), intent(in) :: cache
    logical :: complete
    complete = .false.
    if (.not. associated(cache%RAERBC) .or. .not. associated(cache%RAEROR) .or. .not. associated(cache%RAERSD)) return
    if (.not. associated(cache%RAERSS) .or. .not. associated(cache%RAERSU) .or. .not. associated(cache%RAERV)) return
    if (.not. associated(cache%RLATV)) return
    if (any(shape(cache%RAERBC) /= [72, 46, 12]) .or. any(lbound(cache%RAERBC) /= [1, 1, 1])) return
    if (any(shape(cache%RAEROR) /= [72, 46, 12]) .or. any(lbound(cache%RAEROR) /= [1, 1, 1])) return
    if (any(shape(cache%RAERSD) /= [72, 46, 12]) .or. any(lbound(cache%RAERSD) /= [1, 1, 1])) return
    if (any(shape(cache%RAERSS) /= [72, 46, 12]) .or. any(lbound(cache%RAERSS) /= [1, 1, 1])) return
    if (any(shape(cache%RAERSU) /= [72, 46, 12]) .or. any(lbound(cache%RAERSU) /= [1, 1, 1])) return
    if (any(shape(cache%RAERV) /= [24, 251, 12]) .or. any(lbound(cache%RAERV) /= [1, 1850, 1])) return
    if (size(cache%RLATV) /= 24 .or. lbound(cache%RLATV, 1) /= 1) return
    if (.not. is_contiguous(cache%RAERBC) .or. .not. is_contiguous(cache%RAEROR)) return
    if (.not. is_contiguous(cache%RAERSD) .or. .not. is_contiguous(cache%RAERSS)) return
    if (.not. is_contiguous(cache%RAERSU) .or. .not. is_contiguous(cache%RAERV) .or. .not. is_contiguous(cache%RLATV)) return
    complete = .true.
  end function
end module native_tegen_aerosol_setup
