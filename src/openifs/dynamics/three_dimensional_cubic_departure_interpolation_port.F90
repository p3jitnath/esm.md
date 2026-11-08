module md2asm_three_dimensional_cubic_departure_interpolation
  !! LAITRI's complete generated32-neighbour body for clipping flags0:3.
  !! The separate original flag-1 conservation correction stays unsupported.
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: interpolate_thirty_two_neighbours
contains
  subroutine interpolate_thirty_two_neighbours(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                               clipping, latitude, latitude_coefficients, longitude, longitude_coefficients, &
                                               indices, vertical_coefficients, &
                                               field, result, status, conservation_weights, conservation_enabled)
    !! All coefficients have no unit. Result retains the field's unit.
    !! Source index planes0:3 retain zero-origin bases. Optional conservation
    !! inputs are deliberately unread for the supported generated branches.
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels, first_plane, last_plane, clipping
    real(real64), intent(in) :: latitude(:, :), latitude_coefficients(:, :, :), longitude(:, :, 0:)
    real(real64), intent(in) :: longitude_coefficients(:, :, :, :), vertical_coefficients(:, :, :), field(:)
    integer(int32), intent(in) :: indices(:, :, 0:)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: conservation_weights(:)
    logical, intent(in), optional :: conservation_enabled
    integer(int64) :: planes, total, k(0:3), base
    integer :: cell, level, s, v, offset, begin_offset, end_offset
    logical :: horizontal_clip, vertical_clip, wide
    real(real64) :: row(0:3, 0:3), z(0:3), value
    status = 2
    if (clipping < 0 .or. clipping > 3) return
    planes = int(last_plane, int64) - int(first_plane, int64) + 1
    if (source_pitch < 0 .or. source_pitch > (huge(0_int32) - 3)/3 .or. pitch < 0 .or. levels < 0) return
    if (pitch == huge(0_int32) .or. levels == huge(0_int32) .or. planes < 1 .or. planes > huge(0_int32)) return
    if (int(pitch, int64)*levels > int(huge(0_int32), int64)/6_int64) return
    total = int(source_pitch, int64)*planes
    if (total > huge(0_int32)) return
    if (first < 1 .or. int(first, int64) > int(pitch, int64) + 1 .or. last < 0 .or. last > pitch) return
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
    if (size(field, kind=int64) /= total .or. size(result, 1) /= pitch .or. size(result, 2) < levels) return
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
    horizontal_clip = clipping == 1 .or. clipping == 2
    vertical_clip = clipping >= 2
    do level = 1, levels
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
              if (horizontal_clip) row(s, v) = clip(row(s, v), field(base), field(base + 1))
            else
              row(s, v) = blend(field(base), field(base + 1), longitude(cell, level, s))
            end if
          end do
        end do
        z(0) = blend(row(1, 0), row(2, 0), latitude(cell, level))
        z(1) = cubic(row(0, 1), row(1, 1), row(2, 1), row(3, 1), latitude_coefficients(cell, level, :))
        if (horizontal_clip) z(1) = clip(z(1), row(1, 1), row(2, 1))
        z(2) = cubic(row(0, 2), row(1, 2), row(2, 2), row(3, 2), latitude_coefficients(cell, level, :))
        if (horizontal_clip) z(2) = clip(z(2), row(1, 2), row(2, 2))
        z(3) = blend(row(1, 3), row(2, 3), latitude(cell, level))
        value = cubic(z(0), z(1), z(2), z(3), vertical_coefficients(cell, level, :))
        if (vertical_clip) value = clip(value, z(1), z(2))
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
end module md2asm_three_dimensional_cubic_departure_interpolation
