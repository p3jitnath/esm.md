module md2asm_surface_pressure_and_spectral_filter
  !! Port generated GP_SPV and complete cached/general SPFILT.
  !! Surface pressure is Pa. Vorticity has units s**(-1).
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: previous_surface_pressure_required, convert_surface_pressure, filter_spectral_vorticity
  interface
    function public_exp(x) bind(C, name='exp') result(value)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  logical function previous_surface_pressure_required(linearised_model, simplified_physics, &
                                                      nonhydrostatic, two_time_levels, copy_full_state, current_iteration) &
    result(required)
    logical, intent(in) :: linearised_model, simplified_physics, nonhydrostatic, two_time_levels, copy_full_state
    integer(int32), intent(in) :: current_iteration
    required = (.not. linearised_model .or. simplified_physics .or. nonhydrostatic) .and. &
               (.not. two_time_levels .or. (current_iteration > 0 .and. copy_full_state))
  end function
  subroutine convert_surface_pressure(pitch, first, last, levels, update_previous, log_pressure, &
                                      log_gradient_x, log_gradient_y, pressure, gradient_x, gradient_y, status, &
                                      previous_log, previous_log_x, previous_log_y, previous_pressure, previous_x, previous_y)
    !! Complete current-column pass precedes every previous-column update.
    !! pressure has bounds(:,0:levels); only its bottom row is written.
    integer(int32), intent(in) :: pitch, first, last, levels
    logical, intent(in) :: update_previous
    real(real64), intent(in) :: log_pressure(:), log_gradient_x(:), log_gradient_y(:)
    real(real64), intent(inout) :: pressure(:, 0:), gradient_x(:), gradient_y(:)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: previous_log(:), previous_log_x(:), previous_log_y(:)
    real(real64), intent(inout), optional :: previous_pressure(:, 0:), previous_x(:), previous_y(:)
    real(real64) :: value
    integer :: cell
    status = 2
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. last > pitch) return
    if (first > last) then
      status = 0
      return
    end if
    if (size(log_pressure) < pitch .or. size(log_gradient_x) < pitch .or. size(log_gradient_y) < pitch) return
    if (size(pressure, 1) /= pitch .or. ubound(pressure, 2) < levels) return
    if (size(gradient_x) < pitch .or. size(gradient_y) < pitch) return
    if (update_previous) then
      if (.not. present(previous_log) .or. .not. present(previous_log_x) .or. .not. present(previous_log_y)) return
      if (.not. present(previous_pressure) .or. .not. present(previous_x) .or. .not. present(previous_y)) return
      if (size(previous_log) < pitch .or. size(previous_log_x) < pitch .or. size(previous_log_y) < pitch) return
      if (size(previous_pressure, 1) /= pitch .or. ubound(previous_pressure, 2) < levels) return
      if (size(previous_x) < pitch .or. size(previous_y) < pitch) return
    end if
    do cell = first, last
      value = public_exp(log_pressure(cell))
      pressure(cell, levels) = value
      gradient_x(cell) = log_gradient_x(cell)*value
      gradient_y(cell) = log_gradient_y(cell)*value
    end do
    if (update_previous) then
      do cell = first, last
        value = public_exp(previous_log(cell))
        previous_pressure(cell, levels) = value
        previous_x(cell) = previous_log_x(cell)*value
        previous_y(cell) = previous_log_y(cell)*value
      end do
    end if
    status = 0
  end subroutine

  subroutine filter_spectral_vorticity(maximum_degree, first, last, levels, degrees, vorticity, status)
    !! Complete SPFILT. Degree21 and at least24 selected columns reuse the
    !! exact rounded degree factor after its first ordered calculation.
    !! Native Fortran array sections retain positive or negative strides.
    integer(int32), intent(in) :: maximum_degree, first, last, levels, degrees(:)
    real(real64), intent(inout) :: vorticity(:, :)
    integer(int32), intent(out) :: status
    real(real64) :: cache(0:21), factor, numerator, denominator, temporary
    real(real64), volatile :: setup
    real(real64), parameter :: binary_083 = transfer(int(z'3fea8f5c28f5c28f', int64), 0.0_real64)
    integer :: lower, shift, shifted, column, level, degree
    logical :: cached
    status = 2
    if (maximum_degree < 0 .or. maximum_degree > 4096 .or. levels < 0 .or. levels > 4096) return
    if (first < 1 .or. last > size(degrees) .or. last > size(vorticity, 2)) return
    if (size(vorticity, 1) < levels) return
    setup = real(2*maximum_degree, real64)/3.0_real64
    lower = nint(setup) - 1
    setup = real(maximum_degree, real64)*binary_083
    shift = nint(setup) - lower
    if (first > last) then
      status = 0
      return
    end if
    if (any(degrees(first:last) < 0) .or. any(degrees(first:last) > maximum_degree)) return
    cached = maximum_degree == 21 .and. last - first + 1 >= 24
    if (cached) cache = 0.0_real64
    do column = first, last
      degree = degrees(column)
      if (cached) then
        factor = cache(degree)
      else
        factor = 0.0_real64
      end if
      if (transfer(factor, 0_int64) == 0_int64) then
        shifted = degree + shift
        if (shifted > lower) then
          numerator = real(shifted - maximum_degree, real64)
          denominator = real(shifted - lower, real64)
          numerator = numerator*numerator
          denominator = denominator*denominator
          numerator = numerator*(-0.5_real64)
          temporary = numerator/denominator
          factor = public_exp(temporary)
          factor = factor*32.0_real64
        else
          factor = 0.0_real64
        end if
        factor = factor*factor
        factor = 1.0_real64 + factor
        factor = 1.0_real64/factor
        if (cached) cache(degree) = factor
      end if
      do level = 1, levels
        vorticity(level, column) = vorticity(level, column)*factor
      end do
    end do
    status = 0
  end subroutine
end module md2asm_surface_pressure_and_spectral_filter
