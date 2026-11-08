!> Latitude coefficients for cubic interpolation and smoothing.
module forecast_meridional_interpolation
  use, intrinsic :: iso_c_binding, only: c_int, c_double
  use, intrinsic :: iso_fortran_env, only: int64
  implicit none
  private
  public :: native_meridional_interpolation
  public :: initialize_meridional_interpolation, release_meridional_interpolation
  !> Four native owners. Rows keep the supplied local lower and upper bounds.
  type :: native_meridional_interpolation
    real(c_double), allocatable :: ripi(:, :), rsld(:, :)
    real(c_double), allocatable :: rsldw(:, :, :), r3dtw(:, :, :)
  end type native_meridional_interpolation
contains
  !> Construct the source irregular-latitude branch, with LRPLANE false.
  !> GLOBAL_ROWS is in2:4096; FIRST_LOCAL:LAST_LOCAL has1:16384 rows.
  !> LATITUDE(LATITUDE_LOWER:) is borrowed, contiguous FP64 in radians.
  !> Only consumed global rows GMIN-1:GMAX+2 must be finite and decreasing.
  !> SMOOTHING is finite and dimensionless. STENCIL_WIDTH must be at least2.
  !> The caller establishes nearest-even rounding and gradual underflow.
  !> Status0 succeeds,1 rolls back an allocation failure,2 refuses input.
  !> All four STATE owners must initially be absent. Unwritten rows retain
  !> their allocation bytes. No numerical source owner is imported or copied.
  integer(c_int) function initialize_meridional_interpolation(state, global_rows, first_local, last_local, &
                                          global_offset, stencil_width, latitude_lower, latitude, smoothing, lrplane) result(status)
    type(native_meridional_interpolation), intent(inout) :: state
    integer(c_int), intent(in) :: global_rows, first_local, last_local, global_offset, stencil_width, latitude_lower
    real(c_double), intent(in) :: latitude(latitude_lower:), smoothing
    logical, intent(in) :: lrplane
    type(native_meridional_interpolation) :: pending
    integer(int64) :: rows, first_global, last_global, gmin, gmax, latitude_count, latitude_upper, index, g, j
    integer :: allocation_status, cleanup_status
    real(c_double) :: previous, current, x0, x1, x2, x3, d1, d2, d3, d4, d5, d6
    real(c_double), volatile :: one, two, numerator, denominator, term_a, term_b, value
    status = 2_c_int
    if (lrplane) return
    if (global_rows < 2_c_int .or. global_rows > 4096_c_int) return
    if (stencil_width < 2_c_int) return
    rows = int(last_local, int64) - int(first_local, int64) + 1_int64
    if (rows < 1_int64 .or. rows > 16384_int64) return
    first_global = int(first_local, int64) + int(global_offset, int64)
    last_global = int(last_local, int64) + int(global_offset, int64)
    if (first_global < int(-huge(0_c_int) - 1_c_int, int64) .or. first_global > int(huge(0_c_int), int64)) return
    if (last_global < int(-huge(0_c_int) - 1_c_int, int64) .or. last_global > int(huge(0_c_int), int64)) return
    gmin = max(first_global, 0_int64)
    gmax = min(last_global, int(global_rows, int64))
    latitude_count = size(latitude, kind=int64)
    if (latitude_count < 1_int64 .or. latitude_count > 8196_int64) return
    if (.not. is_contiguous(latitude)) return
    latitude_upper = int(latitude_lower, int64) + latitude_count - 1_int64
    if (gmin <= gmax) then
      if (int(latitude_lower, int64) > gmin - 1_int64 .or. latitude_upper < gmax + 2_int64) return
      index = gmin - 1_int64
      previous = latitude(index)
      if (.not. finite_word(previous)) return
      do index = gmin, gmax + 2_int64
        current = latitude(index)
        if (.not. finite_word(current)) return
        if (previous <= current) return
        previous = current
      end do
    end if
    if (.not. finite_word(smoothing)) return
    if (allocated(state%ripi) .or. allocated(state%rsld) .or. allocated(state%rsldw) .or. allocated(state%r3dtw)) return
    allocate (pending%ripi(first_local:last_local, 1:3), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (pending%rsld(first_local:last_local, 1:3), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (pending%rsldw(1:3, 1:3, first_local:last_local), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (pending%r3dtw(1:3, 1:3, first_local:last_local), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    call move_alloc(pending%ripi, state%ripi)
    call move_alloc(pending%rsld, state%rsld)
    call move_alloc(pending%rsldw, state%rsldw)
    call move_alloc(pending%r3dtw, state%r3dtw)
    ! Volatile constants and temporaries retain explicit source operations,
    ! including multiplications by one and separate rounded intermediates.
    one = 1.0_c_double
    two = 2.0_c_double
    do j = int(first_local, int64), int(last_local, int64)
      g = int(j, int64) + int(global_offset, int64)
      if (g < 0_int64 .or. g > int(global_rows, int64)) cycle
      x0 = latitude(g - 1_int64)
      x1 = latitude(g)
      x2 = latitude(g + 1_int64)
      x3 = latitude(g + 2_int64)
      d1 = x0 - x1
      d2 = x0 - x2
      d3 = x0 - x3
      d4 = x1 - x2
      d5 = x1 - x3
      d6 = x2 - x3
      denominator = d1*d4
      denominator = denominator*d5
      numerator = -one
      value = numerator/denominator
      state%ripi(j, 1) = value
      denominator = d2*d4
      denominator = denominator*d6
      value = one/denominator
      state%ripi(j, 2) = value
      denominator = d3*d5
      denominator = denominator*d6
      numerator = -one
      value = numerator/denominator
      state%ripi(j, 3) = value

      numerator = d2 - d6
      numerator = numerator*d4
      term_a = d1*d2
      term_b = d5*d6
      denominator = term_a + term_b
      value = numerator/denominator
      state%rsld(j, 1) = value
      numerator = d5 - d1
      numerator = numerator*d4
      term_a = d1*d2
      term_b = d5*d6
      denominator = term_a + term_b
      value = numerator/denominator
      state%rsld(j, 2) = value
      numerator = -d4
      numerator = numerator*d4
      term_a = d1*d2
      term_b = d5*d6
      denominator = term_a + term_b
      value = numerator/denominator
      state%rsld(j, 3) = value

      numerator = two*smoothing
      numerator = numerator*d4
      value = numerator/d1
      value = one - value
      state%rsldw(1, 1, j) = value
      numerator = two*smoothing
      numerator = numerator*d4
      value = numerator/d5
      state%rsldw(1, 2, j) = value
      state%rsldw(1, 3, j) = 0.0_c_double
      numerator = two*smoothing
      numerator = numerator*d4
      value = numerator/d2
      state%rsldw(2, 1, j) = value
      numerator = two*smoothing
      numerator = numerator*d4
      value = numerator/d6
      value = one - value
      state%rsldw(2, 2, j) = value
      state%rsldw(2, 3, j) = 0.0_c_double
      state%rsldw(3, 1, j) = 0.0_c_double
      numerator = two*smoothing
      term_a = d4*d4
      numerator = numerator*term_a
      denominator = d5*d6
      value = numerator/denominator
      state%rsldw(3, 2, j) = value
      state%rsldw(3, 3, j) = one

      numerator = one*d4
      value = numerator/d1
      value = one - value
      state%r3dtw(1, 1, j) = value
      numerator = one*d4
      value = numerator/d5
      state%r3dtw(1, 2, j) = value
      state%r3dtw(1, 3, j) = 0.0_c_double
      numerator = one*d4
      value = numerator/d2
      state%r3dtw(2, 1, j) = value
      numerator = one*d4
      value = numerator/d6
      value = one - value
      state%r3dtw(2, 2, j) = value
      state%r3dtw(2, 3, j) = 0.0_c_double
      state%r3dtw(3, 1, j) = 0.0_c_double
      term_a = d4*d4
      numerator = one*term_a
      denominator = d5*d6
      value = numerator/denominator
      state%r3dtw(3, 2, j) = value
      state%r3dtw(3, 3, j) = one
    end do
    status = 0_c_int
    return
900 continue
    cleanup_status = release_meridional_interpolation(pending)
    status = 1_c_int
  end function initialize_meridional_interpolation

  !> Free these four stage-owned arrays in reverse source order.
  !> Repeated release succeeds. Numerical status and errno remain natural.
  integer(c_int) function release_meridional_interpolation(state) result(status)
    type(native_meridional_interpolation), intent(inout) :: state
    real(c_double), allocatable :: rank2(:, :), rank3(:, :, :)
    if (allocated(state%r3dtw)) then
      call move_alloc(state%r3dtw, rank3)
      deallocate (rank3)
    end if
    if (allocated(state%rsldw)) then
      call move_alloc(state%rsldw, rank3)
      deallocate (rank3)
    end if
    if (allocated(state%rsld)) then
      call move_alloc(state%rsld, rank2)
      deallocate (rank2)
    end if
    if (allocated(state%ripi)) then
      call move_alloc(state%ripi, rank2)
      deallocate (rank2)
    end if
    status = 0_c_int
  end function release_meridional_interpolation

  !> Inspect the FP64 exponent without evaluating a nonfinite coordinate.
  logical function finite_word(value) result(finite)
    real(c_double), intent(in) :: value
    integer(int64) :: bits
    bits = transfer(value, bits)
    finite = iand(shiftr(bits, 52), 2047_int64) /= 2047_int64
  end function finite_word
end module forecast_meridional_interpolation
