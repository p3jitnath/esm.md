module md2asm_bounded_three_dimensional_transport
  !! Complete generated LAITRIQM3D parcel interpolation and local limiting.
  !! Fractions have no unit. The result retains the source field's unit.
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: interpolate_bounded_thirty_two_neighbours
contains
  subroutine interpolate_bounded_thirty_two_neighbours(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                                       limiter, vertical_conservation, latitude, latitude_coefficients, longitude, &
                                                       longitude_coefficients, &
                                                       indices, vertical_coefficients, field, result, status, vertical_fraction, &
                                                       half_level_coordinate)
    !! lim0 keeps cubic values;lim1 uses a linear fallback outside eight
    !! central corners;lim2 clamps them. Its optional conservation mode
    !! carries the source's local vertical surplus, with no global claim.
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels, first_plane, last_plane, limiter
    logical, intent(in) :: vertical_conservation
    real(real64), intent(in) :: latitude(:, :), latitude_coefficients(:, :, :), longitude(:, :, 0:)
    real(real64), intent(in) :: longitude_coefficients(:, :, :, :), vertical_coefficients(:, :, :), field(:)
    integer(int32), intent(in) :: indices(:, :, 0:)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: vertical_fraction(:, :), half_level_coordinate(0:)
    real(real64), allocatable :: surplus(:)
    integer(int64) :: planes, total, k(0:3), base
    integer :: cell, level, s, v, offset, begin_offset, end_offset, j, allocation_status
    logical :: wide, carry
    real(real64) :: row(0:3, 0:3), z(0:3), corners(8), linear_row(4), value, lower, upper
    real(real64) :: ratio, depth, previous_depth, upper_excess, lower_excess, excess, clamped
    status = 2
    if (limiter < 0 .or. limiter > 2) return
    if (pitch < 1 .or. pitch > 4096 .or. levels < 0 .or. levels > 512 .or. source_pitch < 0) return
    if (first < 1 .or. first > pitch .or. last < first - 1 .or. last > pitch) return
    planes = int(last_plane, int64) - int(first_plane, int64) + 1
    if (planes < 1 .or. planes > huge(0_int32)) return
    total = int(source_pitch, int64)*planes
    if (total > huge(0_int32)) return
    status = 0
    if (levels == 0 .or. first > last) return
    status = 2
    if (size(latitude, 1) /= pitch .or. size(latitude, 2) < levels) return
    if (size(latitude_coefficients, 1) /= pitch .or. size(latitude_coefficients, 2) < levels .or. &
        size(latitude_coefficients, 3) /= 3) return
    if (size(longitude, 1) /= pitch .or. size(longitude, 2) < levels .or. size(longitude, 3) /= 4) return
    if (size(longitude_coefficients, 1) /= pitch .or. size(longitude_coefficients, 2) < levels .or. &
        size(longitude_coefficients, 3) /= 3 .or. size(longitude_coefficients, 4) /= 2) return
    if (size(indices, 1) /= pitch .or. size(indices, 2) < levels .or. size(indices, 3) /= 4) return
    if (size(vertical_coefficients, 1) /= pitch .or. size(vertical_coefficients, 2) < levels .or. &
        size(vertical_coefficients, 3) /= 3) return
    if (size(result, 1) /= pitch .or. size(result, 2) < levels .or. size(field, kind=int64) /= total) return
    if (limiter == 1) then
      if (.not. present(vertical_fraction)) return
      if (size(vertical_fraction, 1) /= pitch .or. size(vertical_fraction, 2) < levels) return
    end if
    carry = limiter == 2 .and. vertical_conservation
    if (carry) then
      if (.not. present(half_level_coordinate)) return
      if (ubound(half_level_coordinate, 1) < levels) return
      do level = 0, levels
        if (.not. finite(half_level_coordinate(level))) return
        if (level > 0) then
          if (half_level_coordinate(level) <= half_level_coordinate(level - 1)) return
        end if
      end do
    end if
    do level = 1, levels
      do cell = first, last
        if (.not. finite(latitude(cell, level))) return
        if (.not. all(finite(latitude_coefficients(cell, level, :)))) return
        if (.not. all(finite(longitude(cell, level, :)))) return
        if (.not. all(finite(longitude_coefficients(cell, level, :, :)))) return
        if (.not. all(finite(vertical_coefficients(cell, level, :)))) return
        k = int(indices(cell, level, :), int64)
        do v = 0, 3
          do s = 0, 3
            if ((v == 0 .or. v == 3) .and. (s == 0 .or. s == 3)) cycle
            wide = (v == 1 .or. v == 2) .and. (s == 1 .or. s == 2)
            begin_offset = 0
            end_offset = 1
            if (wide) then
              begin_offset = -1
              end_offset = 2
            end if
            base = k(s) + int(v, int64)*source_pitch
            if (base + begin_offset < 0 .or. base + end_offset >= total) return
            do offset = begin_offset, end_offset
              if (.not. finite(field(base + offset + 1))) return
            end do
          end do
        end do
      end do
    end do
    if (carry) then
      allocate (surplus(pitch), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      surplus = 0.0_real64
    end if
    do level = 1, levels
      if (carry) then
        ratio = 1.0_real64
        if (level > 1) then
          depth = half_level_coordinate(level) - half_level_coordinate(level - 1)
          previous_depth = half_level_coordinate(level - 1) - half_level_coordinate(level - 2)
          ratio = depth/previous_depth
        end if
      end if
      do cell = first, last
        k = int(indices(cell, level, :), int64)
        do v = 0, 3
          do s = 0, 3
            if ((v == 0 .or. v == 3) .and. (s == 0 .or. s == 3)) cycle
            base = k(s) + int(v, int64)*source_pitch + 1
            wide = (v == 1 .or. v == 2) .and. (s == 1 .or. s == 2)
            if (wide) then
              row(s, v) = cubic(field(base - 1), field(base), field(base + 1), field(base + 2), &
                                longitude_coefficients(cell, level, :, s))
            else
              row(s, v) = blend(field(base), field(base + 1), longitude(cell, level, s))
            end if
          end do
        end do
        z(0) = blend(row(1, 0), row(2, 0), latitude(cell, level))
        z(1) = cubic(row(0, 1), row(1, 1), row(2, 1), row(3, 1), latitude_coefficients(cell, level, :))
        z(2) = cubic(row(0, 2), row(1, 2), row(2, 2), row(3, 2), latitude_coefficients(cell, level, :))
        z(3) = blend(row(1, 3), row(2, 3), latitude(cell, level))
        value = cubic(z(0), z(1), z(2), z(3), vertical_coefficients(cell, level, :))
        if (limiter /= 0) then
          base = k(1) + source_pitch + 1
          corners(:2) = [field(base), field(base + 1)]
          base = k(2) + source_pitch + 1
          corners(3:4) = [field(base), field(base + 1)]
          base = k(1) + 2_int64*source_pitch + 1
          corners(5:6) = [field(base), field(base + 1)]
          base = k(2) + 2_int64*source_pitch + 1
          corners(7:8) = [field(base), field(base + 1)]
          lower = corners(1)
          upper = corners(1)
          do j = 2, 8
            lower = ordered_minimum(lower, corners(j))
            upper = ordered_maximum(upper, corners(j))
          end do
          if (limiter == 1) then
            if (value < lower .or. value > upper) then
              linear_row(1) = blend(corners(1), corners(2), longitude(cell, level, 1))
              linear_row(2) = blend(corners(3), corners(4), longitude(cell, level, 2))
              linear_row(3) = blend(corners(5), corners(6), longitude(cell, level, 1))
              linear_row(4) = blend(corners(7), corners(8), longitude(cell, level, 2))
              z(0) = blend(linear_row(1), linear_row(2), latitude(cell, level))
              z(1) = blend(linear_row(3), linear_row(4), latitude(cell, level))
              value = blend(z(0), z(1), vertical_fraction(cell, level))
            end if
          else if (carry) then
            value = value + surplus(cell)
            clamped = ordered_minimum(upper, value)
            clamped = ordered_maximum(lower, clamped)
            upper_excess = ordered_maximum(value, upper)
            upper_excess = upper_excess - upper
            lower_excess = ordered_minimum(value, lower)
            lower_excess = lower_excess - lower
            if (abs(upper_excess) >= abs(lower_excess)) then
              excess = upper_excess
            else
              excess = lower_excess
            end if
            surplus(cell) = excess*ratio
            value = clamped
          else
            value = ordered_minimum(upper, value)
            value = ordered_maximum(lower, value)
          end if
        end if
        result(cell, level) = value
      end do
    end do
    status = 0
  end subroutine
  elemental logical function finite(value)
    real(real64), intent(in) :: value
    finite = ibits(transfer(value, 0_int64), 52, 11) /= 2047_int64
  end function
  real(real64) function blend(a, b, fraction) result(value)
    real(real64), intent(in) :: a, b, fraction
    real(real64) :: difference, product
    difference = b - a
    product = fraction*difference
    value = a + product
  end function
  real(real64) function cubic(a, b, c, d, weights) result(value)
    real(real64), intent(in) :: a, b, c, d, weights(3)
    real(real64) :: difference, product
    difference = b - a
    product = weights(1)*difference
    value = a + product
    difference = c - a
    product = weights(2)*difference
    value = value + product
    difference = d - a
    product = weights(3)*difference
    value = value + product
  end function
  real(real64) function clip(value, a, b) result(output)
    real(real64), intent(in) :: value, a, b
    real(real64) :: lower, upper
    lower = ordered_minimum(a, b)
    upper = ordered_maximum(a, b)
    output = ordered_minimum(upper, value)
    output = ordered_maximum(lower, output)
  end function
  real(real64) function ordered_minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    if (a == b) then
      value = a
      if (a == 0.0_real64) value = transfer(ior(transfer(a, 0_int64), transfer(b, 0_int64)), 0.0_real64)
    else if (a < b) then
      value = a
    else
      value = b
    end if
  end function
  real(real64) function ordered_maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    if (a == b) then
      value = a
      if (a == 0.0_real64) value = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), 0.0_real64)
    else if (a > b) then
      value = a
    else
      value = b
    end if
  end function
end module md2asm_bounded_three_dimensional_transport
