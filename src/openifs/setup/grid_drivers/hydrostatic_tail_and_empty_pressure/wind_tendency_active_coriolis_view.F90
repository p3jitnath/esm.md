module md2asm_wind_tendency
  !! Port generated GP_TNDLAGADIAB_UV, including every Rayleigh branch.
  !! Wind is in m s**(-1), tendencies in m s**(-2), Coriolis in s**(-1).
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: select_rayleigh_mode, compute_wind_tendencies
contains
  integer function select_rayleigh_mode(enabled, suppressed, isotropic, plane, rotation_kind) result(mode)
    logical, intent(in) :: enabled, suppressed, isotropic, plane
    integer, intent(in) :: rotation_kind
    mode = 0
    if (.not. enabled .or. suppressed) return
    if (isotropic) then
      mode = 1
    else if (.not. plane .and. rotation_kind == 1) then
      mode = 2
    else
      mode = 3
    end if
  end function
  subroutine compute_wind_tendencies(pitch, first, last, levels, mode, u, v, pressure_x, pressure_y, &
                    coriolis, total_u, total_v, without_coriolis_u, without_coriolis_v, status, damping, sin_rotation, cos_rotation)
    !! mode0 disables damping,1 damps both winds,2 damps the first wind,
    !! and3 uses the source's tilted damping tensor. Inactive cells remain.
    integer(int32), intent(in) :: pitch, first, last, levels, mode
    real(real64), intent(in) :: u(:, :), v(:, :), pressure_x(:, :), pressure_y(:, :), coriolis(:)
    real(real64), intent(inout) :: total_u(:, :), total_v(:, :), without_coriolis_u(:, :), without_coriolis_v(:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: damping(:), sin_rotation(:), cos_rotation(:)
    real(real64) :: du, dv, a, b, c, cross, product, coefficient, zero
    integer :: cell, level
    status = 2
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. last > pitch .or. mode < 0 .or. mode > 3) return
    if (levels == 0 .or. first > last) then
      status = 0
      return
    end if
    if (.not. valid(u) .or. .not. valid(v) .or. .not. valid(pressure_x) .or. .not. valid(pressure_y)) return
    if (.not. valid(total_u) .or. .not. valid(total_v)) return
    if (.not. valid(without_coriolis_u) .or. .not. valid(without_coriolis_v)) return
    if (size(coriolis) < last) return
    if (mode /= 0) then
      if (.not. present(damping)) return
      if (size(damping) < levels) return
    end if
    if (mode == 3) then
      if (.not. present(sin_rotation) .or. .not. present(cos_rotation)) return
      if (size(sin_rotation) < pitch .or. size(cos_rotation) < pitch) return
    end if
    zero = 0.0_real64
    do level = 1, levels
      if (mode /= 0) coefficient = damping(level)
      do cell = first, last
        du = 0.0_real64; dv = 0.0_real64
        if (mode == 1 .or. mode == 2) then
          a = -coefficient
          du = a*u(cell, level)
          if (mode == 1) dv = a*v(cell, level)
        else if (mode == 3) then
          a = coefficient*cos_rotation(cell)
          a = a*cos_rotation(cell)
          b = zero*sin_rotation(cell)
          b = b*sin_rotation(cell)
          a = a + b
          a = -a
          du = a*u(cell, level)
          cross = coefficient - zero
          cross = cross*cos_rotation(cell)
          cross = cross*sin_rotation(cell)
          product = cross*v(cell, level)
          du = du + product
          a = coefficient*sin_rotation(cell)
          a = a*sin_rotation(cell)
          b = zero*cos_rotation(cell)
          b = b*cos_rotation(cell)
          a = a + b
          a = a*v(cell, level)
          dv = cross*u(cell, level)
          dv = dv - a
        end if
        a = -pressure_x(cell, level)
        a = a + du
        product = coriolis(cell)*v(cell, level)
        total_u(cell, level) = a + product
        b = -pressure_y(cell, level)
        b = b + dv
        product = coriolis(cell)*u(cell, level)
        total_v(cell, level) = b - product
        without_coriolis_u(cell, level) = a
        without_coriolis_v(cell, level) = b
      end do
    end do
    status = 0
  contains
    logical function valid(a)
      real(real64), intent(in) :: a(:, :)
      valid = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
  end subroutine
end module md2asm_wind_tendency
