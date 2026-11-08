!> Native spectral stretch maps from the source degree recurrence.
module forecast_spectral_geometry_maps
  use iso_c_binding, only: c_double, c_int, c_int32_t, c_int64_t, c_ptr, c_f_pointer
  use forecast_grid_dimensions, only: native_grid_dimensions
  implicit none
  private
  public :: native_spectral_geometry_maps, initialize_spectral_geometry_maps
  public :: initialize_operational_spectral_geometry_maps
  public :: initialize_distributed_spectral_geometry_maps, release_spectral_geometry_maps
  !> Caller-owned dimensionless map arrays, each with one-based native bounds.
  !! GMR has shape (local_complex_count,2); SCGMAP has shape (local_complex_count,3).
  !! No unrelated Geometry member or padding is part of this owner's mutation.
  type :: native_spectral_geometry_maps
    real(c_double), allocatable :: gmr(:, :), scgmap(:, :)
  end type native_spectral_geometry_maps
  interface
    function errno_location() bind(C, name="__errno_location") result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function errno_location
  end interface
contains
  !> Construct the selected serial maps for source truncation 1 through 21.
  !! owner is native_spectral_geometry_maps, intent(inout); both arrays must be
  !! unallocated. grid is read-only native_grid_dimensions; NSMAX gives N and
  !! NSPECG must be (N+1)*(N+2)/2. wavenumbers and starts are contiguous read-only
  !! int32 arrays with at least N+1 elements. Their consumed stored positions
  !! are one-based; their values are m=0:N and zero-based cumulative offsets.
  !! stretch is a finite dimensionless FP64 input in [0.5,2]. Return 0 completes
  !! both arrays, 1 reports clean allocation failure, and 2 rejects before mutation.
  !! The caller supplies FPCR=0. These native interfaces do not read raw FPCR or
  !! reproduce the historical raw-ABI refusal for a nonzero control register.
  integer(c_int) function initialize_spectral_geometry_maps(owner, grid, wavenumbers, starts, stretch) result(status)
    type(native_spectral_geometry_maps), intent(inout) :: owner
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int32_t), contiguous, intent(in) :: wavenumbers(:), starts(:)
    real(c_double), intent(in) :: stretch
    integer :: n
    status = 2_c_int
    n = int(grid%nsmax)
    if (n < 1 .or. n > 21) return
    if (grid%nspecg /= (n + 1)*(n + 2)/2) return
    status = initialize_maps(owner, n, n + 1, int(grid%nspecg), wavenumbers, starts, stretch, 1)
  end function initialize_spectral_geometry_maps

  !> Construct the operational serial maps for N=1279 and unit stretch.
  !! The argument types, intents, ownership and offset conventions match the
  !! selected entry. This route consumes 1280 columns and 819840 complex cells.
  integer(c_int) function initialize_operational_spectral_geometry_maps(owner, grid, wavenumbers, starts, stretch) &
    result(status)
    type(native_spectral_geometry_maps), intent(inout) :: owner
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int32_t), contiguous, intent(in) :: wavenumbers(:), starts(:)
    real(c_double), intent(in) :: stretch
    status = 2_c_int
    if (grid%nsmax /= 1279_c_int32_t .or. grid%nspecg /= 819840_c_int32_t) return
    status = initialize_maps(owner, 1279, 1280, 819840, wavenumbers, starts, stretch, 2)
  end function initialize_operational_spectral_geometry_maps

  !> Construct distributed source maps from the live public partition metadata.
  !! owner, grid and stretch have the same types and intents as the serial entry.
  !! local_spectral_count is read-only int32. Without ACTIVE_COLUMN_COUNT,
  !! the retained route consumes640columns and409920complex cells. With the
  !! optional int32 count, consume that live prefix in0:1280 and validate its
  !! cumulative complex size against LOCAL_SPECTRAL_COUNT in0:819840.
  !! STARTS holds zero-based cumulative sizes1280-m; each wave is in0:1279.
  !! N is 1279 and stretch is exactly one. The caller obtains these vectors from
  !! its live native partition; this child calls no transform or original routine.
  integer(c_int) function initialize_distributed_spectral_geometry_maps(owner, grid, local_spectral_count, &
                                                                        wavenumbers, starts, stretch, active_column_count) &
    result(status)
    type(native_spectral_geometry_maps), intent(inout) :: owner
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int32_t), intent(in) :: local_spectral_count
    integer(c_int32_t), optional, intent(in) :: active_column_count
    integer(c_int32_t), contiguous, intent(in) :: wavenumbers(:), starts(:)
    real(c_double), intent(in) :: stretch
    status = 2_c_int
    if (grid%nsmax /= 1279_c_int32_t) return
    if (present(active_column_count)) then
      if (active_column_count < 0 .or. active_column_count > 1280) return
      if (local_spectral_count < 0 .or. local_spectral_count > 819840) return
      status = initialize_maps(owner, 1279, int(active_column_count), int(local_spectral_count), &
                               wavenumbers, starts, stretch, 3)
    else
      if (local_spectral_count /= 409920_c_int32_t) return
      status = initialize_maps(owner, 1279, 640, 409920, wavenumbers, starts, stretch, 3)
    end if
  end function initialize_distributed_spectral_geometry_maps

  !> Validate the exact source route, acquire private owners, then publish both.
  !! No source-private descriptor or address offset supplies any calculation.
  integer(c_int) function initialize_maps(owner, n, column_count, spectral_count, wavenumbers, starts, stretch, route) &
    result(status)
    type(native_spectral_geometry_maps), intent(inout) :: owner
    integer, intent(in) :: n, column_count, spectral_count, route
    integer(c_int32_t), contiguous, intent(in) :: wavenumbers(:), starts(:)
    real(c_double), intent(in) :: stretch
    real(c_double), allocatable :: gmr(:, :), scgmap(:, :)
    integer(c_int64_t) :: stretch_word
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: saved_errno
    integer :: column, m, expected_start, allocation_status
    status = 2_c_int
    if (allocated(owner%gmr) .or. allocated(owner%scgmap)) return
    if (size(wavenumbers) < column_count .or. size(starts) < column_count) return
    stretch_word = transfer(stretch, stretch_word)
    if (route == 1) then
      if (stretch_word < int(z'3FE0000000000000', c_int64_t)) return
      if (stretch_word > int(z'4000000000000000', c_int64_t)) return
    else
      if (stretch_word /= int(z'3FF0000000000000', c_int64_t)) return
    end if
    expected_start = 0
    do column = 1, column_count
      m = int(wavenumbers(column))
      if (route == 3) then
        if (m < 0 .or. m > n) return
      else
        if (m /= column - 1) return
      end if
      if (starts(column) /= expected_start) return
      expected_start = expected_start + n + 1 - m
    end do
    if (expected_start /= spectral_count) return

    call c_f_pointer(errno_location(), errno_word)
    saved_errno = errno_word
    allocate (gmr(spectral_count, 2), stat=allocation_status)
    if (allocation_status /= 0) then
      errno_word = saved_errno
      status = 1_c_int
      return
    end if
    allocate (scgmap(spectral_count, 3), stat=allocation_status)
    if (allocation_status /= 0) then
      deallocate (gmr)
      errno_word = saved_errno
      status = 1_c_int
      return
    end if
    call calculate_maps(gmr, scgmap, n, wavenumbers(:column_count), starts(:column_count), stretch)
    call move_alloc(gmr, owner%gmr)
    call move_alloc(scgmap, owner%scgmap)
    errno_word = saved_errno
    status = 0_c_int
  end function initialize_maps

  !> Execute SUSPGM, then the separate SUSMAP and SUGMRE arithmetic.
  !! All real arrays and intermediates are FP64 and dimensionless. Each source
  !! multiply, add, subtract, divide and square root has its own rounding point.
  subroutine calculate_maps(gmr, scgmap, n, wavenumbers, starts, stretch)
    real(c_double), contiguous, intent(inout) :: gmr(:, :), scgmap(:, :)
    integer, intent(in) :: n
    integer(c_int32_t), contiguous, intent(in) :: wavenumbers(:), starts(:)
    real(c_double), intent(in) :: stretch
    real(c_double) :: recurrence(0:1281)
    real(c_double), volatile :: reciprocal, combined, a, b, a_squared, b_squared, cross
    real(c_double) :: temporary, second_temporary
    integer :: column, m, degree, position, first, spectral_count
    spectral_count = size(gmr, 1)
    reciprocal = 1.0_c_double/stretch
    combined = stretch + reciprocal
    a = 0.5_c_double*combined
    reciprocal = 1.0_c_double/stretch
    combined = stretch - reciprocal
    b = 0.5_c_double*combined
    do column = 1, size(wavenumbers)
      m = int(wavenumbers(column))
      first = int(starts(column)) + 1
      call calculate_recurrence(recurrence, m, n)
      do degree = m, n
        position = first + degree - m
        gmr(position, 1) = a
      end do
      do degree = m, n - 1
        position = first + degree - m
        temporary = b*recurrence(degree + 1)
        gmr(position, 2) = temporary
      end do
      position = first + n - m
      gmr(position, 2) = 0.0_c_double
    end do

    ! Repeat both source divisions and stretch expressions for the second stage.
    reciprocal = 1.0_c_double/stretch
    combined = stretch + reciprocal
    a = 0.5_c_double*combined
    reciprocal = 1.0_c_double/stretch
    combined = stretch - reciprocal
    b = 0.5_c_double*combined
    a_squared = a*a
    b_squared = b*b
    temporary = 2.0_c_double*a
    cross = temporary*b
    do column = 1, size(wavenumbers)
      m = int(wavenumbers(column))
      first = int(starts(column)) + 1
      call calculate_recurrence(recurrence, m, n)
      do degree = m, n
        temporary = recurrence(degree)*recurrence(degree)
        second_temporary = recurrence(degree + 1)*recurrence(degree + 1)
        temporary = temporary + second_temporary
        temporary = b_squared*temporary
        temporary = a_squared + temporary
        position = first + degree - m
        scgmap(position, 1) = temporary
      end do
      do degree = m, n - 1
        temporary = cross*recurrence(degree + 1)
        position = first + degree - m
        scgmap(position, 2) = temporary
      end do
      position = first + n - m
      scgmap(position, 2) = 0.0_c_double
      do degree = m, n - 2
        temporary = b_squared*recurrence(degree + 1)
        temporary = temporary*recurrence(degree + 2)
        position = first + degree - m
        scgmap(position, 3) = temporary
      end do
      ! The source writes n=N-1 and n=N even for a one-cell m=N column.
      ! At the very first local cell, the preceding word is in plane two.
      position = first + n - 1 - m
      if (position == 0) then
        scgmap(spectral_count, 2) = 0.0_c_double
      else
        scgmap(position, 3) = 0.0_c_double
      end if
      scgmap(position + 1, 3) = 0.0_c_double
    end do
  end subroutine calculate_maps

  !> Calculate e(n)=sqrt(max(0,(n*n-m*m)/(4*n*n-1))) for m through N+2.
  !! Integers are small enough that their squares and FP64 conversions are exact.
  !! The zero comparison chooses positive zero exactly as the source MAXNUM does.
  subroutine calculate_recurrence(recurrence, m, n)
    real(c_double), intent(inout) :: recurrence(0:1281)
    integer, intent(in) :: m, n
    real(c_double) :: squared_m, squared_n, numerator, denominator, ratio
    integer :: degree
    squared_m = real(m*m, c_double)
    do degree = m, n + 2
      squared_n = real(degree*degree, c_double)
      numerator = squared_n - squared_m
      denominator = 4.0_c_double*squared_n
      denominator = denominator - 1.0_c_double
      ratio = numerator/denominator
      if (ratio <= 0.0_c_double) ratio = 0.0_c_double
      recurrence(degree) = sqrt(ratio)
    end do
  end subroutine calculate_recurrence

  !> Release only the two native arrays, preserving all parent-owned state.
  !! owner has intent(inout). Repeated release is supported. Return is int32 zero.
  !! Allocation services do not supply a numerical stage; inherited errno stays.
  integer(c_int) function release_spectral_geometry_maps(owner) result(status)
    type(native_spectral_geometry_maps), intent(inout) :: owner
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: saved_errno
    call c_f_pointer(errno_location(), errno_word)
    saved_errno = errno_word
    if (allocated(owner%gmr)) deallocate (owner%gmr)
    if (allocated(owner%scgmap)) deallocate (owner%scgmap)
    errno_word = saved_errno
    status = 0_c_int
  end function release_spectral_geometry_maps
end module forecast_spectral_geometry_maps
