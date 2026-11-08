module md2asm_horizontal_pressure_weight_gradients
  !! Complete GPGRXYB pressure weights and horizontal gradients.
  !! Pressures use Pa; depth, alpha and combined coefficients use 1/Pa.
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: pressure_weight_fields, pressure_gradient_fields, compute_horizontal_pressure_weight_gradients
  type :: pressure_weight_fields
    integer(int32) :: inverse_depth = 0, depth_weight = 0, alpha = 0
    integer(int32) :: thermal_gradient = 0, inverse_lower_pressure = 0, inverse_boundary_product = 0
  end type
  type :: pressure_gradient_fields
    integer(int32) :: depth_x = 0, depth_y = 0, alpha_x = 0, alpha_y = 0, combined_x = 0, combined_y = 0
    integer(int32) :: depth_coefficient = 0, alpha_coefficient = 0, combined_coefficient = 0
  end type
contains
  subroutine compute_horizontal_pressure_weight_gradients(pitch, first, last, levels, finite_elements, &
                                                          pressure_mode, store_coefficients, input_fields, output_fields, &
                                                          surface_gradient_x, surface_gradient_y, &
                                                          weights, gradients, status, delta_b, cross_coefficient, lower_b)
    !! Arrays keep (cell,level,field) order and independent input/output owners.
    !! Unused field indices and unused optional coefficient arrays are not read.
    integer(int32), intent(in) :: pitch, first, last, levels, pressure_mode
    logical, intent(in) :: finite_elements, store_coefficients
    type(pressure_weight_fields), intent(in) :: input_fields
    type(pressure_gradient_fields), intent(in) :: output_fields
    real(real64), intent(in) :: surface_gradient_x(:), surface_gradient_y(:), weights(:, :, :)
    real(real64), intent(inout) :: gradients(:, :, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: delta_b(:), cross_coefficient(:), lower_b(:)
    integer :: inputs(4), outputs(9), ni, no, i, j, cell, level
    real(real64) :: d, a, p, product, coefficient
    status = 2
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    status = 0
    if (levels == 0 .or. first > last) return
    status = 2
    if (size(weights, 1) /= pitch .or. size(weights, 2) < levels) return
    if (size(gradients, 1) /= pitch .or. size(gradients, 2) < levels) return
    if (size(surface_gradient_x) < pitch .or. size(surface_gradient_y) < pitch) return
    ni = 0
    if (finite_elements) then
      if (.not. present(delta_b)) return
      if (size(delta_b) < levels) return
      inputs(:3) = [input_fields%inverse_depth, input_fields%thermal_gradient, input_fields%depth_weight]
      ni = 3
    else
      if (pressure_mode < 0 .or. pressure_mode > 2) return
      if (.not. present(cross_coefficient)) return
      if (size(cross_coefficient) < levels) return
      if (pressure_mode == 0) then
        if (.not. present(lower_b)) return
        if (size(lower_b) < levels) return
        inputs(:3) = [input_fields%inverse_boundary_product, input_fields%thermal_gradient, &
                      input_fields%inverse_lower_pressure]
        ni = 3
      else
        inputs = [input_fields%inverse_boundary_product, input_fields%thermal_gradient, &
                  input_fields%depth_weight, input_fields%alpha]
        ni = 4
      end if
    end if
    if (any(inputs(:ni) < 1) .or. any(inputs(:ni) > size(weights, 3))) return
    outputs(:2) = [output_fields%depth_x, output_fields%depth_y]
    no = 2
    if (.not. finite_elements) then
      outputs(3:6) = [output_fields%alpha_x, output_fields%alpha_y, output_fields%combined_x, output_fields%combined_y]
      no = 6
    end if
    if (store_coefficients) then
      no = no + 1
      outputs(no) = output_fields%depth_coefficient
      if (.not. finite_elements) then
        outputs(no + 1:no + 2) = [output_fields%alpha_coefficient, output_fields%combined_coefficient]
        no = no + 2
      end if
    end if
    if (any(outputs(:no) < 1) .or. any(outputs(:no) > size(gradients, 3))) return
    do i = 1, no
      do j = 1, i - 1
        if (outputs(i) == outputs(j)) return
      end do
    end do
    status = 0
    do level = 1, levels
      if (finite_elements) then
        coefficient = delta_b(level)
      else
        coefficient = -cross_coefficient(level)
      end if
      do cell = first, last
        if (finite_elements) then
          product = coefficient*weights(cell, level, input_fields%inverse_depth)
          product = product - weights(cell, level, input_fields%thermal_gradient)
          d = product*weights(cell, level, input_fields%depth_weight)
        else
          d = coefficient*weights(cell, level, input_fields%inverse_boundary_product)
        end if
        gradients(cell, level, output_fields%depth_x) = d*surface_gradient_x(cell)
        gradients(cell, level, output_fields%depth_y) = d*surface_gradient_y(cell)
        if (store_coefficients) gradients(cell, level, output_fields%depth_coefficient) = d
        if (finite_elements) cycle
        if (pressure_mode == 0) then
          p = lower_b(level)*weights(cell, level, input_fields%inverse_lower_pressure)
          a = p - weights(cell, level, input_fields%thermal_gradient)
        else
          product = d*weights(cell, level, input_fields%alpha)
          a = product/weights(cell, level, input_fields%depth_weight)
          p = a + weights(cell, level, input_fields%thermal_gradient)
        end if
        gradients(cell, level, output_fields%combined_x) = p*surface_gradient_x(cell)
        gradients(cell, level, output_fields%combined_y) = p*surface_gradient_y(cell)
        gradients(cell, level, output_fields%alpha_x) = a*surface_gradient_x(cell)
        gradients(cell, level, output_fields%alpha_y) = a*surface_gradient_y(cell)
        if (store_coefficients) then
          gradients(cell, level, output_fields%alpha_coefficient) = a
          gradients(cell, level, output_fields%combined_coefficient) = p
        end if
      end do
    end do
  end subroutine
end module md2asm_horizontal_pressure_weight_gradients
