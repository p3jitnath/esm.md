module md2asm_horizontal_cubic_departure_interpolation
  !! Complete LAIDDI: twelve source samples and three optional central clips.
  !! Coefficients have no unit; the result retains the field's physical unit.
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: interpolate_twelve_neighbours
contains
  subroutine interpolate_twelve_neighbours(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                           clipping, latitude_coefficients, longitude, longitude_coefficients, indices, field, &
                                           result, status)
    !! Row index planes0:3 retain source zero-origin bases. Middle rows use
    !! four neighbours; outer rows use two. Only selected result cells change.
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels, first_plane, last_plane
    logical, intent(in) :: clipping
    real(real64), intent(in) :: latitude_coefficients(:, :, :), longitude(:, :, 0:), longitude_coefficients(:, :, :, :)
    integer(int32), intent(in) :: indices(:, :, 0:)
    real(real64), intent(in) :: field(:)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    integer(int64) :: planes, total, k(0:3)
    integer :: cell, level, s, j, offset, begin_offset, end_offset
    real(real64) :: z(0:3), value
    status = 2
    planes = int(last_plane, int64) - int(first_plane, int64) + 1
    if (source_pitch < 0 .or. pitch < 0 .or. levels < 0 .or. planes < 1 .or. planes > huge(0_int32)) return
    if (pitch == huge(0_int32) .or. levels == huge(0_int32)) return
    if (int(pitch, int64)*levels > int(huge(0_int32), int64)/6_int64) return
    total = int(source_pitch, int64)*planes
    if (total > huge(0_int32)) return
    if (first < 1 .or. int(first, int64) > int(pitch, int64) + 1 .or. last < 0 .or. last > pitch) return
    status = 0
    if (levels == 0 .or. first > last) return
    status = 2
    if (size(latitude_coefficients, 1) /= pitch .or. size(latitude_coefficients, 2) < levels .or. &
        size(latitude_coefficients, 3) /= 3) return
    if (size(longitude, 1) /= pitch .or. size(longitude, 2) < levels .or. size(longitude, 3) /= 4) return
    if (size(longitude_coefficients, 1) /= pitch .or. size(longitude_coefficients, 2) < levels .or. &
        size(longitude_coefficients, 3) /= 3 .or. size(longitude_coefficients, 4) /= 2) return
    if (size(indices, 1) /= pitch .or. size(indices, 2) < levels .or. size(indices, 3) /= 4) return
    if (size(field, kind=int64) /= total .or. size(result, 1) /= pitch .or. size(result, 2) < levels) return
    do level = 1, levels
      do cell = first, last
        if (.not. all(finite(latitude_coefficients(cell, level, :)))) return
        if (.not. finite(longitude(cell, level, 0)) .or. .not. finite(longitude(cell, level, 3))) return
        if (.not. all(finite(longitude_coefficients(cell, level, :, :)))) return
        do s = 0, 3
          k(s) = int(indices(cell, level, s), int64)
          begin_offset = 0
          end_offset = 1
          if (s == 1 .or. s == 2) then
            begin_offset = -1
            end_offset = 2
          end if
          if (k(s) + begin_offset < 0 .or. k(s) + end_offset >= total) return
          do offset = begin_offset, end_offset
            if (.not. finite(field(k(s) + offset + 1))) return
          end do
        end do
      end do
    end do
    do level = 1, levels
      do cell = first, last
        k = int(indices(cell, level, :), int64)
        z(0) = blend(field(k(0) + 1), field(k(0) + 2), longitude(cell, level, 0))
        z(1) = cubic(field(k(1)), field(k(1) + 1), field(k(1) + 2), field(k(1) + 3), &
                     longitude_coefficients(cell, level, :, 1))
        if (clipping) z(1) = clip(z(1), field(k(1) + 1), field(k(1) + 2))
        z(2) = cubic(field(k(2)), field(k(2) + 1), field(k(2) + 2), field(k(2) + 3), &
                     longitude_coefficients(cell, level, :, 2))
        if (clipping) z(2) = clip(z(2), field(k(2) + 1), field(k(2) + 2))
        z(3) = blend(field(k(3) + 1), field(k(3) + 2), longitude(cell, level, 3))
        value = cubic(z(0), z(1), z(2), z(3), latitude_coefficients(cell, level, :))
        if (clipping) value = clip(value, z(1), z(2))
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
end module md2asm_horizontal_cubic_departure_interpolation
