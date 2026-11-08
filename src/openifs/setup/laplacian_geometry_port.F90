module forecast_laplacian_geometry
  !! Own spectral maps and spherical Laplacian factors.
  !!
  !! This module replaces serial_laplacian_setup.S and
  !! distributed_laplacian_setup.S. Public transform inquiries provide the
  !! distributed maps. The caller keeps the transform and communicator alive.
  use, intrinsic :: iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_public_transform, only: native_transform_resolution
  use mpl_allreduce_mod, only: mpl_allreduce
  use mpl_abort_mod, only: mpl_abort
  implicit none
  private

  public :: native_laplacian_geometry
  public :: initialize_serial_laplacian, initialize_distributed_laplacian
  public :: release_laplacian_geometry

  type :: native_laplacian_geometry
    !! All components own contiguous native Fortran storage.
    !!
    !! NASM0 and NASM0G use one-based real-column addresses. MYMS lists
    !! local wave numbers. NSE0L uses zero-based complex-coefficient offsets.
    integer(c_int), allocatable :: nasn0(:), nasm0(:), nasm0g(:), nvalue(:)
    integer(c_int), allocatable :: myms(:), nspzero(:), nse0l(:)
    real(c_double), allocatable :: rlapdi(:), rlapin(:)
  end type native_laplacian_geometry

#include "trans_inq.h"

contains

  integer(c_int) function initialize_serial_laplacian(state, dimensions, radius) result(status)
    !! Construct all nine owners for one process.
    !!
    !! STATE is changed only after every allocation and calculation succeeds.
    !! DIMENSIONS supplies NSMAX, the largest spherical degree, without units.
    !! RADIUS is the selected physical radius, 6371229 metres.
    !! Supported NSMAX is 0:21 or 1279. Status is 0 for success, 1 for
    !! allocation failure, or 2 for refusal. Every owner must be unallocated.
    type(native_laplacian_geometry), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: dimensions
    real(c_double), intent(in) :: radius
    type(native_laplacian_geometry) :: pending
    integer :: allocation_status, unused_status
    integer(c_int) :: n, m, degree, real_start, complex_start, count, index

    status = 2_c_int
    n = dimensions%nsmax
    if (.not. ((n >= 0_c_int .and. n <= 21_c_int) .or. n == 1279_c_int)) return
    if (.not. selected_radius(radius)) return
    if (.not. fresh_laplacian(state)) return

    allocate (pending%nasn0(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%nasm0(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%nasm0g(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%nvalue(1:(n + 1_c_int)*(n + 2_c_int)), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%myms(1:n + 1), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%nspzero(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%nse0l(1:n + 1), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%rlapdi(-1:n + 2), stat=allocation_status)
    if (allocation_status /= 0) go to 900
    allocate (pending%rlapin(-1:n + 2), stat=allocation_status)
    if (allocation_status /= 0) go to 900

    real_start = 1_c_int
    complex_start = 0_c_int
    do m = 0_c_int, n
      pending%nasn0(m) = m*m + m + 1_c_int
      pending%nasm0(m) = real_start
      pending%nasm0g(m) = real_start
      pending%myms(m + 1) = m
      pending%nspzero(m) = 2_c_int*m + 2_c_int
      pending%nse0l(m + 1) = complex_start
      count = n + 1_c_int - m
      complex_start = complex_start + count
      real_start = real_start + 2_c_int*count
    end do
    index = 1_c_int
    do m = 0_c_int, n
      do degree = m, n
        pending%nvalue(index) = degree
        pending%nvalue(index + 1) = degree
        index = index + 2_c_int
      end do
    end do

    call write_lower_laplacian_zeros(pending%rlapdi, pending%rlapin)
    call fill_positive_eigenvalues(pending, n, radius)
    call publish_laplacian(pending, state)
    status = 0_c_int
    return

900 continue
    unused_status = release_laplacian_geometry(pending)
    status = 1_c_int
  end function initialize_serial_laplacian

  integer(c_int) function initialize_distributed_laplacian(state, dimensions, radius, resolution, &
                                                           nump, numcp, nspec, nspec2, world_size, communicator_selector) &
    result(status)
    !! Construct the spherical decomposition from live public partition counts.
    !!
    !! STATE receives nine native owners only after complete success.
    !! DIMENSIONS supplies NSMAX and NCMAX. RADIUS is in metres.
    !! RESOLUTION borrows the live public transform handle. NUMP and NUMCP
    !! count local wave numbers; NSPEC counts local complex coefficients;
    !! NSPEC2 counts their real and imaginary FP64 columns. All counts are
    !! dimensionless. WORLD_SIZE is1:32. COMMUNICATOR_SELECTOR must be zero:
    !! zero selects the source's omitted KCOMM argument, not an MPI handle.
    !! All processes enter together in that existing FIAT message context.
    !! Return 0 means success, 1 means collective allocation failure with
    !! all acquired storage released, and 2 means collective refusal.
    type(native_laplacian_geometry), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: dimensions
    real(c_double), intent(in) :: radius
    type(native_transform_resolution), intent(in) :: resolution
    integer(c_int), intent(in) :: nump, numcp, nspec, nspec2, world_size, communicator_selector
    type(native_laplacian_geometry) :: pending
    integer :: allocation_status, unused_status
    integer(c_int) :: local_status, n, m, degree, j, prefix, index, real_start

    local_status = 2_c_int
    n = dimensions%nsmax
    if (n == 1279_c_int .and. dimensions%ncmax == 1279_c_int .and. &
        nump >= 0_c_int .and. nump <= 1280_c_int .and. numcp >= 0_c_int .and. numcp <= 1280_c_int .and. &
        nspec >= 0_c_int .and. nspec <= 819840_c_int .and. nspec2 == 2_c_int*nspec .and. &
        world_size >= 1_c_int .and. world_size <= 32_c_int .and. communicator_selector == 0_c_int) then
      if (resolution%resolution > 0_c_int .and. resolution%truncation == 1279_c_int .and. &
          resolution%row_count == 2560_c_int .and. selected_radius(radius) .and. fresh_laplacian(state)) &
        local_status = 0_c_int
    end if
    status = agree_laplacian_status(local_status)
    if (status /= 0_c_int) return

    allocate (pending%myms(1:nump), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    allocate (pending%rlapdi(-1:n + 2), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    allocate (pending%rlapin(-1:n + 2), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    allocate (pending%nasn0(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    allocate (pending%nasm0(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    allocate (pending%nasm0g(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    allocate (pending%nspzero(0:n), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    allocate (pending%nvalue(1:nspec2), stat=allocation_status)
    if (allocation_status /= 0) go to 810
    local_status = 0_c_int
    go to 820
810 continue
    local_status = 1_c_int
820 continue
    status = agree_laplacian_status(local_status)
    if (status /= 0_c_int) go to 900

    call trans_inq(kresol=resolution%resolution, kasm0=pending%nasm0)
    call trans_inq(kresol=resolution%resolution, kmyms=pending%myms)
    do degree = 0_c_int, n
      pending%nasn0(degree) = degree*degree + degree + 1_c_int
    end do

    allocate (pending%nse0l(1:nump), stat=allocation_status)
    local_status = 0_c_int
    if (allocation_status /= 0) local_status = 1_c_int
    status = agree_laplacian_status(local_status)
    if (status /= 0_c_int) go to 900

    prefix = 0_c_int
    do j = 1_c_int, nump
      m = pending%myms(j)
      if (m < 0_c_int .or. m > n) call public_abort()
      pending%nse0l(j) = prefix
      prefix = prefix + n + 1_c_int - m
    end do
    if (prefix /= nspec) call public_abort()

    call fill_positive_eigenvalues(pending, n, radius)
    call write_lower_laplacian_zeros(pending%rlapdi, pending%rlapin)

    index = 1_c_int
    do j = 1_c_int, nump
      do degree = pending%myms(j), n
        pending%nvalue(index) = degree
        pending%nvalue(index + 1) = degree
        index = index + 2_c_int
      end do
    end do
    real_start = 1_c_int
    do m = 0_c_int, n
      pending%nasm0g(m) = real_start
      real_start = real_start + 2_c_int*(n + 1_c_int - m)
    end do
    do degree = 0_c_int, n
      pending%nspzero(degree) = 2_c_int*degree + 2_c_int
    end do

    call publish_laplacian(pending, state)
    status = 0_c_int
    return

900 continue
    unused_status = release_laplacian_geometry(pending)
    status = 1_c_int
  end function initialize_distributed_laplacian

  integer(c_int) function release_laplacian_geometry(state) result(status)
    !! Release every allocated owner in the source descriptor order.
    !!
    !! STATE is changed by deallocation. Repeated release succeeds.
    !! No other geometry, transform or communicator owner is changed.
    type(native_laplacian_geometry), intent(inout) :: state

    if (allocated(state%nasn0)) deallocate (state%nasn0)
    if (allocated(state%nasm0)) deallocate (state%nasm0)
    if (allocated(state%nasm0g)) deallocate (state%nasm0g)
    if (allocated(state%nvalue)) deallocate (state%nvalue)
    if (allocated(state%myms)) deallocate (state%myms)
    if (allocated(state%nspzero)) deallocate (state%nspzero)
    if (allocated(state%nse0l)) deallocate (state%nse0l)
    if (allocated(state%rlapdi)) deallocate (state%rlapdi)
    if (allocated(state%rlapin)) deallocate (state%rlapin)
    status = 0_c_int
  end function release_laplacian_geometry

  logical function fresh_laplacian(state) result(fresh)
    !! Inspect allocation state without reading any array payload.
    type(native_laplacian_geometry), intent(in) :: state

    fresh = .not. (allocated(state%nasn0) .or. allocated(state%nasm0) .or. &
                   allocated(state%nasm0g) .or. allocated(state%nvalue) .or. allocated(state%myms) .or. &
                   allocated(state%nspzero) .or. allocated(state%nse0l) .or. &
                   allocated(state%rlapdi) .or. allocated(state%rlapin))
  end function fresh_laplacian

  logical function selected_radius(radius) result(selected)
    !! Compare the selected physical input as an exact FP64 word.
    real(c_double), intent(in) :: radius

    selected = transfer(radius, 0_c_int64_t) == transfer(6371229.0_c_double, 0_c_int64_t)
  end function selected_radius

  integer(c_int) function agree_laplacian_status(local_status) result(status)
    !! Agree by the exact scalar public MAX operation at each source point.
    integer(c_int), intent(in) :: local_status
    integer(c_int) :: error

    status = local_status
    call mpl_allreduce(status, cdoper='MAX', ldreprod=.false., kerror=error)
    if (error /= 0_c_int) call public_abort()
  end function agree_laplacian_status

  subroutine write_lower_laplacian_zeros(diagonal, inverse)
    !! Preserve all other modes and execute the four source stores in order.
    !! Explicit visibility keeps these meaningful lower-bound writes when the
    !! following partial writer is specialized by the compiler.
    real(c_double), contiguous, volatile, intent(inout) :: diagonal(-1:), inverse(-1:)
    diagonal(-1) = 0.0_c_double
    diagonal(0) = 0.0_c_double
    inverse(-1) = 0.0_c_double
    inverse(0) = 0.0_c_double
  end subroutine write_lower_laplacian_zeros

  subroutine public_abort()
    !! Stop every process after an unrecoverable public provider result.
    call mpl_abort('Native distributed Laplacian provider failed')
    error stop 3
  end subroutine public_abort

  subroutine fill_positive_eigenvalues(state, n, radius)
    !! Fill degrees 1:N+2 with the source's separately rounded operations.
    !!
    !! RLAPDI has units m^-2 and RLAPIN has units m^2. Distinct volatile
    !! radius operands and stored intermediates retain the source order.
    type(native_laplacian_geometry), intent(inout) :: state
    integer(c_int), intent(in) :: n
    real(c_double), intent(in) :: radius
    real(c_double), volatile :: diagonal_radius, inverse_radius
    real(c_double), volatile :: converted_degree, negative_degree, radius_squared
    real(c_double), volatile :: inverse_radius_squared, negative_radius_squared
    real(c_double), volatile :: diagonal_value
    integer(c_int) :: degree, integer_product

    diagonal_radius = radius
    inverse_radius = radius
    do degree = 1_c_int, n + 2_c_int
      integer_product = degree*(degree + 1_c_int)
      converted_degree = real(integer_product, c_double)
      negative_degree = -converted_degree
      radius_squared = diagonal_radius*diagonal_radius
      diagonal_value = negative_degree/radius_squared
      state%rlapdi(degree) = diagonal_value
      inverse_radius_squared = inverse_radius*inverse_radius
      negative_radius_squared = -inverse_radius_squared
      state%rlapin(degree) = negative_radius_squared/converted_degree
    end do
  end subroutine fill_positive_eigenvalues

  subroutine publish_laplacian(pending, state)
    !! Transfer native owners without allocating or copying their payloads.
    type(native_laplacian_geometry), intent(inout) :: pending, state

    call move_alloc(pending%nasn0, state%nasn0)
    call move_alloc(pending%nasm0, state%nasm0)
    call move_alloc(pending%nasm0g, state%nasm0g)
    call move_alloc(pending%nvalue, state%nvalue)
    call move_alloc(pending%myms, state%myms)
    call move_alloc(pending%nspzero, state%nspzero)
    call move_alloc(pending%nse0l, state%nse0l)
    call move_alloc(pending%rlapdi, state%rlapdi)
    call move_alloc(pending%rlapin, state%rlapin)
  end subroutine publish_laplacian

end module forecast_laplacian_geometry
