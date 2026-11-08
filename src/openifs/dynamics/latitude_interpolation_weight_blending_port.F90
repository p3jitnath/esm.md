module md2asm_latitude_interpolation_weight_blending
  !! LASCAW_CLA supplied latitude weights, diffusion and turbulence.
  !! All coordinates, interpolation weights and smoothing rates have no unit.
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: latitude_weight_controls, blend_latitude_interpolation_weights
  type :: latitude_weight_controls
    logical :: diffusion = .false., quadratic = .false., older_linear = .false., turbulence = .false.
    real(real64) :: minimum_blend = 0.0_real64, maximum_blend = 0.0_real64, reference_blend = 0.0_real64
  end type
contains
  subroutine blend_latitude_interpolation_weights(c, pitch, first, last, levels, first_latitude, table_count, &
                                                  latitude_base, cubic_weights, correction_weights, main, correction, &
                                                  filtered, status, &
                                                  latitude_fraction, kappa, turbulent_rate, quadratic_table, diffusion_table, &
                                                  turbulence_table)
    !! Input triples have shape(cell,3,level); outputs use(cell,level,3).
    !! Tables store quadratic(slot,3) and matrices(row,column,slot).
    !! The original slot is base+1-first_latitude, with zero as its origin.
    type(latitude_weight_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels, first_latitude, table_count
    integer(int32), intent(in) :: latitude_base(:, :)
    real(real64), intent(in) :: cubic_weights(:, :, :), correction_weights(:, :, :)
    real(real64), intent(inout) :: main(:, :, :), correction(:, :, :), filtered(:, :, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: latitude_fraction(:, :), kappa(:, :), turbulent_rate(:, :)
    real(real64), intent(in), optional :: quadratic_table(:, :), diffusion_table(:, :, :), turbulence_table(:, :, :)
    real(real64), volatile :: low(3)
    real(real64) :: original(3), candidate(3), new_main(3), new_filtered(3), matrix_value(3)
    real(real64) :: distance, one_minus, quadratic, sign_half, part1, part2, blend_rate, delta, product, twice
    integer(int64) :: slot_wide
    integer :: cell, level, slot, j
    status = 2
    if (c%diffusion .and. .not. c%quadratic .and. .not. c%older_linear) return
    if (pitch < 0 .or. pitch > 1024 .or. levels < 0 .or. levels > 256 .or. table_count < 1 .or. table_count > 4096) return
    if (first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch) return
    status = 0
    if (pitch == 0 .or. levels == 0 .or. first > last) return
    status = 2
    if (size(latitude_base, 1) /= pitch .or. size(latitude_base, 2) < levels) return
    if (.not. valid_input(cubic_weights) .or. .not. valid_input(correction_weights)) return
    if (.not. valid_output(main) .or. .not. valid_output(correction) .or. .not. valid_output(filtered)) return
    if (c%quadratic .or. c%older_linear) then
      if (.not. present(latitude_fraction)) return
      if (.not. valid_scalar(latitude_fraction)) return
    end if
    if (c%quadratic) then
      if (.not. present(quadratic_table)) return
      if (size(quadratic_table, 1) /= table_count .or. size(quadratic_table, 2) /= 3) return
    end if
    if (c%diffusion) then
      if (.not. present(kappa) .or. .not. present(diffusion_table)) return
      if (.not. valid_scalar(kappa)) return
      if (any(shape(diffusion_table) /= [3, 3, table_count])) return
    end if
    if (c%turbulence) then
      if (.not. present(turbulent_rate) .or. .not. present(turbulence_table)) return
      if (.not. valid_scalar(turbulent_rate)) return
      if (any(shape(turbulence_table) /= [3, 3, table_count])) return
    end if
    do level = 1, levels
      do cell = first, last
        slot_wide = int(latitude_base(cell, level), int64) + 2_int64 - int(first_latitude, int64)
        if (slot_wide < 1 .or. slot_wide > table_count) return
      end do
    end do
    status = 0
    do level = 1, levels
      do cell = first, last
        slot = int(int(latitude_base(cell, level), int64) + 2_int64 - int(first_latitude, int64))
        original = cubic_weights(cell, :, level)
        if (c%quadratic) then
          distance = latitude_fraction(cell, level)
          one_minus = 1.0_real64 - distance
          quadratic = distance*one_minus
          product = quadratic*quadratic_table(slot, 1)
          low(1) = product + one_minus
          product = quadratic*quadratic_table(slot, 2)
          low(2) = product + distance
          low(3) = quadratic*quadratic_table(slot, 3)
        else if (c%older_linear) then
          low(2) = latitude_fraction(cell, level)
          low(1) = 1.0_real64 - low(2)
          low(3) = 0.0_real64
        end if
        if (c%diffusion) then
          sign_half = 0.5_real64
          if (btest(transfer(kappa(cell, level), 0_int64), 63)) sign_half = -0.5_real64
          part1 = 0.5_real64 + sign_half
          part1 = part1*c%minimum_blend
          part2 = sign_half - 0.5_real64
          part2 = part2*c%reference_blend
          blend_rate = part1 - part2
          do j = 1, 3
            delta = low(j) - original(j)
            product = blend_rate*delta
            new_main(j) = original(j) + product
            product = c%maximum_blend*delta
            candidate(j) = original(j) + product
          end do
          call matrix_product(diffusion_table(:, :, slot), candidate, matrix_value)
          do j = 1, 3
            delta = matrix_value(j) - new_main(j)
            product = abs(kappa(cell, level))*delta
            new_filtered(j) = new_main(j) + product
          end do
        else if (c%quadratic) then
          do j = 1, 3
            delta = low(j) - original(j)
            product = c%minimum_blend*delta
            new_main(j) = original(j) + product
          end do
          new_filtered = new_main
        else
          new_main = original
          new_filtered = original
        end if
        main(cell, level, :) = new_main
        filtered(cell, level, :) = new_filtered
        correction(cell, level, :) = correction_weights(cell, :, level)
      end do
    end do
    if (.not. c%turbulence) return
    do level = 1, levels
      do cell = first, last
        slot = int(int(latitude_base(cell, level), int64) + 2_int64 - int(first_latitude, int64))
        twice = turbulent_rate(cell, level)*2.0_real64
        original = main(cell, level, :)
        call matrix_product(turbulence_table(:, :, slot), original, matrix_value)
        do j = 1, 3
          delta = matrix_value(j) - original(j)
          product = twice*delta
          new_main(j) = original(j) + product
        end do
        main(cell, level, :) = new_main
        original = filtered(cell, level, :)
        call matrix_product(turbulence_table(:, :, slot), original, matrix_value)
        do j = 1, 3
          delta = matrix_value(j) - original(j)
          product = twice*delta
          new_filtered(j) = original(j) + product
        end do
        filtered(cell, level, :) = new_filtered
      end do
    end do
  contains
    logical function valid_input(a)
      real(real64), intent(in) :: a(:, :, :)
      valid_input = size(a, 1) == pitch .and. size(a, 2) == 3 .and. size(a, 3) >= levels
    end function
    logical function valid_output(a)
      real(real64), intent(in) :: a(:, :, :)
      valid_output = size(a, 1) == pitch .and. size(a, 2) >= levels .and. size(a, 3) == 3
    end function
    logical function valid_scalar(a)
      real(real64), intent(in) :: a(:, :)
      valid_scalar = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
  end subroutine
  subroutine matrix_product(matrix, vector, result)
    real(real64), intent(in) :: matrix(3, 3), vector(3)
    real(real64), intent(out) :: result(3)
    real(real64) :: value, product
    integer :: row
    do row = 1, 3
      value = matrix(row, 1)*vector(1)
      product = matrix(row, 2)*vector(2)
      value = value + product
      product = matrix(row, 3)*vector(3)
      result(row) = value + product
    end do
  end subroutine
end module md2asm_latitude_interpolation_weight_blending
