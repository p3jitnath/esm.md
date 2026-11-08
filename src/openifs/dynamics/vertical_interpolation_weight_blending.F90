module md2asm_vertical_interpolation_weight_blending
  !! Complete generated LASCAW_VINTW vertical interpolation and filters.
  !! Coordinates, coefficients, interpolation weights and rates have no unit.
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: vertical_weight_controls, blend_vertical_interpolation_weights
  type :: vertical_weight_controls
    logical :: correct_coordinate = .false., diffusion = .false., quadratic = .false., older_linear = .false.
    logical :: vertical_filter = .false., heat_diffusion = .false.
    real(real64) :: minimum_blend = 0.0_real64, maximum_blend = 0.0_real64, reference_blend = 0.0_real64
  end type
contains
  subroutine blend_vertical_interpolation_weights(c, pitch, first, last, levels, node_index, main, correction, status, &
                                                  diffusion, heat, vertical_filtered, position, distance, correction_distance, &
                                                  correction_scale, kappa, heat_kappa, &
                                                  eta, cubic_coefficients, quadratic_coefficients, diffusion_matrices, &
                                                  vertical_matrices)
    !! node_index and all cell arrays use(cell,level). Output triples use
    !! (cell,level,coefficient). Geometry table levels retain lower bound0.
    !! Unused optional owners are not required or read. Every used owner and
    !! node index is checked before any output cell is changed.
    type(vertical_weight_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels, node_index(:, :)
    real(real64), intent(inout) :: main(:, :, :), correction(:, :, :)
    integer(int32), intent(out) :: status
    real(real64), intent(inout), optional :: diffusion(:, :, :), heat(:, :, :), vertical_filtered(:, :, :)
    real(real64), intent(in), optional :: position(:, :), distance(:, :), correction_distance(:, :), correction_scale(:, :)
    real(real64), intent(in), optional :: kappa(:, :), heat_kappa(:, :), eta(0:)
    real(real64), intent(in), optional :: cubic_coefficients(:, 0:), quadratic_coefficients(:, 0:)
    real(real64), intent(in), optional :: diffusion_matrices(:, :, 0:), vertical_matrices(:, :, 0:)
    logical :: interior, boundary, have_interior, have_boundary
    integer :: cell, level, k, j
    real(real64) :: z(0:3), zm(0:3), hi(3), mad(3), new_main(3), candidate(3), smoothed(3), result(3)
    real(real64), volatile :: low(3)
    real(real64) :: d, one_minus, q, gap, scale, part1, part2, sign_half, rate, delta, product
    status = 2
    if (c%diffusion .and. .not. c%quadratic .and. .not. c%older_linear) return
    if (pitch < 0 .or. pitch > 1024 .or. levels < 0 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch) return
    status = 0
    if (levels == 0 .or. first > last) return
    status = 2
    if (size(node_index, 1) /= pitch .or. size(node_index, 2) < levels) return
    if (.not. valid_output(main) .or. .not. valid_output(correction)) return
    have_interior = .false.
    have_boundary = .false.
    do level = 1, levels
      do cell = first, last
        k = node_index(cell, level)
        if (k < 0 .or. k >= levels) return
        interior = k >= 1 .and. k <= levels - 3
        have_interior = have_interior .or. interior
        have_boundary = have_boundary .or. .not. interior
      end do
    end do
    if (have_interior .or. c%diffusion) then
      if (.not. present(diffusion)) return
      if (.not. valid_output(diffusion)) return
    end if
    if (c%diffusion .and. c%heat_diffusion) then
      if (.not. present(heat)) return
      if (.not. valid_output(heat)) return
    end if
    if (c%vertical_filter) then
      if (.not. present(vertical_filtered)) return
      if (.not. valid_output(vertical_filtered)) return
    end if
    if (have_boundary .or. (have_interior .and. (c%quadratic .or. c%older_linear))) then
      if (.not. present(distance)) return
      if (.not. valid_scalar(distance)) return
    end if
    if (have_boundary) then
      if (.not. present(correction_distance)) return
      if (.not. valid_scalar(correction_distance)) return
    end if
    if (have_interior) then
      if (.not. present(position) .or. .not. present(eta) .or. .not. present(cubic_coefficients)) return
      if (.not. valid_scalar(position)) return
      if (ubound(eta, 1) < levels + 1) return
      if (size(cubic_coefficients, 1) /= 4 .or. ubound(cubic_coefficients, 2) < levels - 1) return
      if (c%correct_coordinate) then
        if (.not. present(correction_scale)) return
        if (.not. valid_scalar(correction_scale)) return
      end if
      if (c%quadratic) then
        if (.not. present(quadratic_coefficients)) return
        if (size(quadratic_coefficients, 1) /= 3 .or. ubound(quadratic_coefficients, 2) < levels - 1) return
      end if
      if (c%diffusion) then
        if (.not. present(kappa) .or. .not. present(diffusion_matrices)) return
        if (.not. valid_scalar(kappa)) return
        if (size(diffusion_matrices, 1) /= 3 .or. size(diffusion_matrices, 2) /= 3 .or. &
            ubound(diffusion_matrices, 3) < levels - 1) return
        if (c%heat_diffusion) then
          if (.not. present(heat_kappa)) return
          if (.not. valid_scalar(heat_kappa)) return
        end if
      end if
      if (c%vertical_filter) then
        if (.not. present(vertical_matrices)) return
        if (size(vertical_matrices, 1) /= 3 .or. size(vertical_matrices, 2) /= 3 .or. &
            ubound(vertical_matrices, 3) < levels - 1) return
      end if
    end if
    status = 0
    do level = 1, levels
      do cell = first, last
        k = node_index(cell, level)
        interior = k >= 1 .and. k <= levels - 3
        if (.not. interior) then
          low(2) = distance(cell, level)
          low(1) = 1.0_real64 - low(2)
          low(3) = 0.0_real64
          main(cell, level, :) = low
          if (c%diffusion) then
            diffusion(cell, level, :) = low
            if (c%heat_diffusion) heat(cell, level, :) = low
          end if
          if (c%vertical_filter) vertical_filtered(cell, level, :) = low
          low(2) = correction_distance(cell, level)
          low(1) = 1.0_real64 - low(2)
          correction(cell, level, :) = low
          cycle
        end if
        z(0) = position(cell, level) - eta(k)
        z(1) = position(cell, level) - eta(k + 1)
        z(2) = position(cell, level) - eta(k + 2)
        z(3) = position(cell, level) - eta(k + 3)
        call cubic_triplet(z, cubic_coefficients(2:4, k), hi)
        if (c%correct_coordinate) then
          zm(0) = z(0) - z(1)
          zm(3) = z(3) - z(2)
          gap = eta(k + 2) - eta(k + 1)
          gap = 0.5_real64*gap
          scale = correction_scale(cell, level)
          part1 = 1.0_real64 - scale
          gap = gap*part1
          zm(1) = z(1)*scale
          zm(1) = zm(1) + gap
          zm(2) = z(2)*scale
          zm(2) = zm(2) - gap
          zm(0) = zm(0) + zm(1)
          zm(3) = zm(3) + zm(2)
          call cubic_triplet(zm, cubic_coefficients(2:4, k), mad)
        else
          mad = hi
        end if
        correction(cell, level, :) = mad
        if (c%quadratic) then
          d = distance(cell, level)
          one_minus = 1.0_real64 - d
          q = d*one_minus
          product = q*quadratic_coefficients(1, k)
          low(1) = product + one_minus
          product = q*quadratic_coefficients(2, k)
          low(2) = product + d
          low(3) = q*quadratic_coefficients(3, k)
        else if (c%older_linear) then
          low(2) = distance(cell, level)
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
          rate = part1 - part2
          do j = 1, 3
            delta = low(j) - hi(j)
            product = rate*delta
            new_main(j) = hi(j) + product
            product = c%maximum_blend*delta
            candidate(j) = hi(j) + product
          end do
          main(cell, level, :) = new_main
          call matrix_product(diffusion_matrices(:, :, k), candidate, smoothed)
          do j = 1, 3
            delta = smoothed(j) - new_main(j)
            product = abs(kappa(cell, level))*delta
            result(j) = new_main(j) + product
          end do
          diffusion(cell, level, :) = result
          if (c%heat_diffusion) then
            do j = 1, 3
              delta = smoothed(j) - new_main(j)
              product = abs(heat_kappa(cell, level))*delta
              result(j) = new_main(j) + product
            end do
            heat(cell, level, :) = result
          end if
        else
          if (c%quadratic) then
            do j = 1, 3
              delta = low(j) - hi(j)
              product = c%minimum_blend*delta
              new_main(j) = hi(j) + product
            end do
          else
            new_main = hi
          end if
          main(cell, level, :) = new_main
          diffusion(cell, level, :) = new_main
        end if
        if (c%vertical_filter) then
          call matrix_product(vertical_matrices(:, :, k), new_main, result)
          vertical_filtered(cell, level, :) = result
        end if
      end do
    end do
  contains
    logical function valid_scalar(a)
      real(real64), intent(in) :: a(:, :)
      valid_scalar = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
    logical function valid_output(a)
      real(real64), intent(in) :: a(:, :, :)
      valid_output = size(a, 1) == pitch .and. size(a, 2) >= levels .and. size(a, 3) == 3
    end function
  end subroutine
  subroutine cubic_triplet(z, coefficients, weights)
    real(real64), intent(in) :: z(0:3), coefficients(3)
    real(real64), intent(out) :: weights(3)
    real(real64) :: product, common
    product = z(0)*z(2)
    product = product*z(3)
    weights(1) = product*coefficients(1)
    common = z(0)*z(1)
    product = common*z(3)
    weights(2) = product*coefficients(2)
    product = common*z(2)
    weights(3) = product*coefficients(3)
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
end module md2asm_vertical_interpolation_weight_blending
