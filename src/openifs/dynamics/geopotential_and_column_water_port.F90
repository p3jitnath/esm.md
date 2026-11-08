module md2asm_geopotential_and_column_water
  !! Generated GPGEO and GPPWC with typed native arrays.
  !!
  !! Geopotential is gravitational energy per unit mass in m**2 s**(-2).
  !! Pressure is in Pa; cumulative water is in kg m**(-2).
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_vertical_operators, only: vertical_operator_matrices, apply_vertical_operator
  implicit none
  private
  public :: compute_geopotential, integrate_column_water
contains
  subroutine compute_geopotential(pitch, first, last, levels, finite_elements, tables, &
                                  integral_bc, derivative_bc, gas_constant, temperature, delta_log, half_phi, full_phi, &
                                  status, alpha, metric)
    !! Half geopotential has bounds(:,0:levels), with initialized surface
    !! values at levels. Only active columns change. Finite elements use
    !! the ported IBOT/11 operator, then the complete descending half pass.
    integer(int32), intent(in) :: pitch, first, last, levels
    logical, intent(in) :: finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc, derivative_bc
    real(real64), intent(in) :: gas_constant(:, :), temperature(:, :), delta_log(:, :)
    real(real64), intent(inout) :: half_phi(:, 0:), full_phi(:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: alpha(:, :), metric(:)
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: pin(:, :), integral(:, :)
    real(real64) :: value, other
    integer :: level, cell, allocation_status
    integer(int64) :: input_words, total_words
    status = 2
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. last > pitch) return
    if (levels == 0 .or. first > last) then
      status = 0
      return
    end if
    if (.not. valid(gas_constant) .or. .not. valid(temperature) .or. .not. valid(delta_log)) return
    if (size(half_phi, 1) /= pitch .or. ubound(half_phi, 2) < levels) return
    if (.not. valid(full_phi)) return
    if (finite_elements) then
      if (.not. present(metric)) return
      if (size(metric) < levels) return
      input_words = int(pitch, int64)*(levels + 2)
      total_words = int(pitch, int64)*(2_int64*levels + 3)
      allocate (workspace(total_words), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      pin(1:pitch, 0:levels + 1) => workspace(1:input_words)
      integral(1:pitch, 1:levels + 1) => workspace(input_words + 1:total_words)
      pin(first:last, 0) = 0.0_real64
      pin(first:last, levels + 1) = 0.0_real64
      do level = 1, levels
        do cell = first, last
          value = -gas_constant(cell, level)
          value = value*temperature(cell, level)
          value = value*delta_log(cell, level)
          pin(cell, level) = value*metric(level)
        end do
      end do
      call apply_vertical_operator(tables, .true., integral_bc, derivative_bc, 'IBOT', '11', &
                                   int(pitch), int(first), int(last), int(levels), pin, integral, status)
      if (status /= 0) return
      do level = 1, levels
        do cell = first, last
          full_phi(cell, level) = integral(cell, level) + half_phi(cell, levels)
        end do
      end do
    else
      if (.not. present(alpha)) return
      if (.not. valid(alpha)) return
    end if
    do level = levels, 1, -1
      do cell = first, last
        value = gas_constant(cell, level)*temperature(cell, level)
        value = value*delta_log(cell, level)
        half_phi(cell, level - 1) = half_phi(cell, level) + value
        if (.not. finite_elements) then
          other = alpha(cell, level)*gas_constant(cell, level)
          other = other*temperature(cell, level)
          full_phi(cell, level) = half_phi(cell, level) + other
        end if
      end do
    end do
    status = 0
  contains
    logical function valid(a)
      real(real64), intent(in) :: a(:, :)
      valid = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
  end subroutine

  subroutine integrate_column_water(pitch, first, last, levels, gravity, water, pressure, cumulative, status)
    !! Full GPPWC: zero top boundary and four ordered operations per layer.
    integer(int32), intent(in) :: pitch, first, last, levels
    real(real64), intent(in) :: gravity, water(:, :), pressure(:, 0:)
    real(real64), intent(inout) :: cumulative(:, 0:)
    integer(int32), intent(out) :: status
    real(real64), volatile :: inverse_gravity
    real(real64) :: delta, value
    integer :: cell, level
    status = 2
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. last > pitch) return
    inverse_gravity = 1.0_real64/gravity
    if (first > last) then
      status = 0
      return
    end if
    if (size(pressure, 1) /= pitch .or. ubound(pressure, 2) < levels) return
    if (size(cumulative, 1) /= pitch .or. ubound(cumulative, 2) < levels) return
    if (size(water, 1) /= pitch .or. size(water, 2) < levels) return
    cumulative(first:last, 0) = 0.0_real64
    do level = 1, levels
      do cell = first, last
        delta = pressure(cell, level) - pressure(cell, level - 1)
        value = water(cell, level)*delta
        value = value*inverse_gravity
        cumulative(cell, level) = cumulative(cell, level - 1) + value
      end do
    end do
    status = 0
  end subroutine
end module md2asm_geopotential_and_column_water
