!> Own the forecast stream's geometry metadata and copied physical values.
module forecast_geometry_stream
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  private
  public :: native_geometry_stream, initialize_stream_geometry_metadata
  public :: copy_stream_half_level_values, copy_stream_latitude_values
  public :: release_stream_geometry_metadata, release_stream_geometry_values
  !> Named stream namespace, with native ownership instead of private layouts.
  !! vah/vbh contain copied half-level values in Pa/dimensionless units.
  !! rlatig contains physical latitude angles in radians. Other source owners
  !! are represented explicitly but remain outside this constructor's scope.
  type :: native_geometry_stream
    integer(c_int) :: nundef, nulerr, nulout, myproc, nproc
    integer(c_int64_t) :: imaxgrid, imaxspec2g
    real(c_double) :: rpi, sipr
    integer(c_int) :: nrealen, nintlen
    integer(c_int), allocatable :: nbsetlev(:)
    integer(c_int) :: nbsetsp, nflevg, nsmax, ndglg
    integer(c_int), allocatable :: nloeng(:)
    real(c_double), allocatable :: vah(:), vbh(:), rlatig(:)
    integer(c_int), allocatable :: numprocfp(:)
    integer(c_int) :: nfprgpl, nfprgpg, nfprgplx
    integer(c_int), allocatable :: nfpmax(:), msatid(:), mseries(:), minst(:), mchan(:)
    real(c_double), allocatable :: rcwn(:)
    logical :: lifs_internal
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate and copy NBSETLEV then physical NLOENG before writing defaults.
  !! rank/processes are explicit live one-based public message values.
  !! levels and row count come from array extents; truncation is file metadata.
  !! Qualified parent routes use one process or a four-process 2-by-2 split.
  !! All unrelated scalar fields and owners remain unchanged.
  !! Return2 is atomic; return1 releases the two newly acquired owners.
  integer(c_int) function initialize_stream_geometry_metadata(state, rank, processes, spectral_sets, &
                                                              truncation, level_sets, physical_longitudes) result(status)
    type(native_geometry_stream), intent(inout) :: state
    integer(c_int), intent(in) :: rank, processes, spectral_sets, truncation
    integer(c_int), intent(in) :: level_sets(:), physical_longitudes(:)
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: allocation_status, j
    status = 2
    if (allocated(state%nbsetlev) .or. allocated(state%nloeng)) return
    if (processes /= 1 .and. processes /= 4) return
    if (rank < 1 .or. rank > processes) return
    if (processes == 1 .and. spectral_sets /= 1) return
    if (processes == 4 .and. spectral_sets /= 2) return
    if (truncation < 0 .or. truncation > 8191) return
    if (size(level_sets) < 1 .or. size(level_sets) > 256) return
    if (size(physical_longitudes) < 1 .or. size(physical_longitudes) > 1048576) return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    allocate (state%nbsetlev(size(level_sets)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    do j = 1, size(level_sets)
      state%nbsetlev(j) = level_sets(j)
    end do
    allocate (state%nloeng(size(physical_longitudes)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    do j = 1, size(physical_longitudes)
      state%nloeng(j) = physical_longitudes(j)
    end do
    state%nundef = -huge(0_c_int)
    state%nulerr = 0
    state%nulout = 6
    state%myproc = rank
    state%nproc = processes
    state%imaxgrid = 52428800_c_int64_t
    state%imaxspec2g = 26214400_c_int64_t
    state%rpi = transfer(int(z'400921fb54442d18', c_int64_t), state%rpi)
    state%sipr = 100000.0_c_double
    state%nrealen = 8
    state%nintlen = 4
    state%nbsetsp = spectral_sets
    state%nflevg = size(level_sets)
    state%nsmax = truncation
    state%ndglg = size(physical_longitudes)
    state%lifs_internal = .false.
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
    status = 0
    return
900 continue
    call release_stream_geometry_metadata(state)
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
    status = 1
  end function

  !> Copy actual half-level A/B values from explicit bounds0:levels.
  !! Stream copies use bounds1:levels+1, as in INI_IOSTREAM assumed-shape input.
  !! A has units Pa and B is dimensionless. Existing stream value owners refuse.
  integer(c_int) function copy_stream_half_level_values(state, a_half, b_half) result(status)
    type(native_geometry_stream), intent(inout) :: state
    real(c_double), intent(in) :: a_half(0:), b_half(0:)
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: allocation_status, j, levels
    status = 2
    if (.not. allocated(state%nbsetlev)) return
    levels = size(state%nbsetlev)
    if (levels < 1 .or. levels > 256) return
    if (size(a_half) /= levels + 1 .or. size(b_half) /= levels + 1) return
    if (allocated(state%vah) .or. allocated(state%vbh)) return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    allocate (state%vah(levels + 1), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    do j = 0, levels
      state%vah(j + 1) = a_half(j)
    end do
    allocate (state%vbh(levels + 1), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    do j = 0, levels
      state%vbh(j + 1) = b_half(j)
    end do
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
    status = 0
    return
900 continue
    if (allocated(state%vah)) deallocate (state%vah)
    if (allocated(state%vbh)) deallocate (state%vbh)
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
    status = 1
  end function

  !> Copy only physical latitude rows1:ndglg, passed as an explicit section.
  !! Angles are in radians. The caller retains all global halo words.
  integer(c_int) function copy_stream_latitude_values(state, physical_latitudes) result(status)
    type(native_geometry_stream), intent(inout) :: state
    real(c_double), intent(in) :: physical_latitudes(:)
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: allocation_status, j, rows
    status = 2
    if (.not. allocated(state%nloeng)) return
    rows = size(state%nloeng)
    if (rows < 1 .or. rows > 1048576) return
    if (size(physical_latitudes) /= rows) return
    if (allocated(state%rlatig)) return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    allocate (state%rlatig(rows), stat=allocation_status)
    if (allocation_status /= 0) then
      call ieee_set_status(saved_status)
      error_pointer = saved_errno
      status = 1
      return
    end if
    do j = 1, rows
      state%rlatig(j) = physical_latitudes(j)
    end do
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
    status = 0
  end function

  !> Free only the two geometry metadata arrays, preserving incoming status.
  subroutine release_stream_geometry_metadata(state)
    type(native_geometry_stream), intent(inout) :: state
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    if (allocated(state%nbsetlev)) deallocate (state%nbsetlev)
    if (allocated(state%nloeng)) deallocate (state%nloeng)
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
  end subroutine

  !> Free only the three copied physical-value arrays in source order.
  subroutine release_stream_geometry_values(state)
    type(native_geometry_stream), intent(inout) :: state
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    if (allocated(state%vah)) deallocate (state%vah)
    if (allocated(state%vbh)) deallocate (state%vbh)
    if (allocated(state%rlatig)) deallocate (state%rlatig)
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
  end subroutine
end module forecast_geometry_stream
