!> Compose the native runtime diagnostic calculations used by actual POS.
module forecast_runtime_pressure_diagnostics
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_standard_atmosphere, only: atmosphere_layers
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_geopotential_and_column_water, only: compute_geopotential
  use md2asm_vertical_continuity, only: compute_vertical_continuity
  use runtime_vertical_output_physics_port, only: relative_humidity_parameters, output_relative_humidity
  use forecast_pressure_level_interpolation, only: ppsta
  use forecast_pressure_humidity_output, only: ppq
  use forecast_runtime_output_wind_interpolation, only: ppuv
  use forecast_runtime_dynamic_output_interpolation, only: pp2dint, ppgeop, ppvvel
  implicit none
  private
  public :: calculate_runtime_pressure_diagnostics
  interface
    function public_log(x) bind(C, name='log') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Compute requested pressure/model diagnostics from actual borrowed arrays.
 !! Pressure is Pa, temperature K, gas constants J/(kg K), geopotential
 !! m**2/s**2, wind m/s, divergence/vorticity1/s and omega Pa/s.
 !! Active rows change in separate output arrays(pitch,targets); inactive rows
 !! retain their input bytes. Input winds/divergence/vorticity already include
 !! source map factors. The caller removes those factors when publishing.
 !! flags select geopotential,RH,omega,winds and scalar DIV/VOR, in that order.
  subroutine calculate_runtime_pressure_diagnostics(constants, reference, lapse, rh_parameters, rh_limits, &
                           rh_percent, constant_wind_top, quadratic_wind_top, finite_elements, tables, integral_bc, derivative_bc, &
                                            metric, eta_half, bfull, delta_b, inv_eta, p, first, last, l, t, kind, targets, flags, &
                                  half_pressure, full_pressure, delta_pressure, inverse_delta, delta_log, alpha, inverse_pressure, &
                                     temperature, humidity, gas, u, v, divergence, vorticity, surface_dx, surface_dy, mass_source, &
                                                terrain, tstar, xp, xpd, kbelow, below_full, below_surface, any_full, any_surface, &
                                               geopotential, rh, omega, wind_u, wind_v, output_divergence, output_vorticity, status)
    type(forecast_physical_constants), intent(in) :: constants
    type(atmosphere_layers), intent(in) :: reference
    type(relative_humidity_parameters), intent(in) :: rh_parameters
    type(vertical_operator_matrices), intent(in) :: tables
    real(real64), intent(in) :: lapse, rh_limits(2), metric(:), eta_half(0:), bfull(:), delta_b(:), inv_eta(:)
    logical, intent(in) :: rh_percent, constant_wind_top, quadratic_wind_top, finite_elements, flags(5)
    integer, intent(in) :: integral_bc, derivative_bc
    integer(int32), intent(in) :: p, first, last, l, t, kind
    real(real64), intent(in) :: targets(:), half_pressure(:, 0:), full_pressure(:, :), delta_pressure(:, :)
    real(real64), intent(in) :: inverse_delta(:, :), delta_log(:, :), alpha(:, :), inverse_pressure(:, :)
    real(real64), intent(in) :: temperature(:, :), humidity(:, :), gas(:, :), u(:, :), v(:, :)
    real(real64), intent(in) :: divergence(:, 0:), vorticity(:, 0:), surface_dx(:), surface_dy(:), mass_source(:, :)
    real(real64), intent(in) :: terrain(:), tstar(:), xp(:, 0:, :), xpd(:, 0:, :)
    integer(int32), intent(in) :: kbelow(:, :, :)
    logical, intent(in) :: below_full(:, :), below_surface(:, :), any_full(:), any_surface(:)
    real(real64), intent(inout) :: geopotential(:, :), rh(:, :), omega(:, :), wind_u(:, :), wind_v(:, :)
    real(real64), intent(inout) :: output_divergence(:, :), output_vorticity(:, :)
    integer(int32), intent(out) :: status
    integer :: i, k
    integer(int64) :: workspace
    status = 2
    if (p < 1 .or. p > 24 .or. l < 3 .or. l > 256 .or. t < 1 .or. t > 4096) return
    if (first < 1 .or. last > p .or. last < first) return
    if (kind /= 1 .and. kind /= 5) return
    if (size(targets) /= t) return
    if (.not. valid_full(full_pressure) .or. .not. valid_full(delta_pressure) .or. .not. valid_full(inverse_delta)) return
    if (.not. valid_full(delta_log) .or. .not. valid_full(alpha) .or. .not. valid_full(inverse_pressure)) return
    if (.not. valid_full(temperature) .or. .not. valid_full(humidity) .or. .not. valid_full(gas)) return
    if (.not. valid_full(u) .or. .not. valid_full(v) .or. .not. valid_full(mass_source)) return
    if (size(half_pressure, 1) /= p .or. size(half_pressure, 2) < l + 1) return
    if (size(divergence, 1) /= p .or. size(divergence, 2) < l + 1) return
    if (size(vorticity, 1) /= p .or. size(vorticity, 2) < l + 1) return
    if (min(size(surface_dx), size(surface_dy), size(terrain), size(tstar)) < p) return
    if (min(size(metric), size(bfull), size(delta_b), size(inv_eta)) < l .or. size(eta_half) < l + 1) return
    if (any(shape(kbelow) /= [p, t, 4]) .or. any(shape(xp) /= [p, l + 1, 4]) .or. any(shape(xpd) /= [p, l + 1, 4])) return
    if (any(shape(below_full) /= [p, t]) .or. any(shape(below_surface) /= [p, t])) return
    if (size(any_full) < t .or. size(any_surface) < t) return
    if (.not. valid_target(geopotential) .or. .not. valid_target(rh) .or. .not. valid_target(omega)) return
    if (.not. valid_target(wind_u) .or. .not. valid_target(wind_v)) return
    if (.not. valid_target(output_divergence) .or. .not. valid_target(output_vorticity)) return
    if (kind == 5) then
      do k = 1, t
        i = int(targets(k))
        if (i < 1 .or. i > l .or. real(i, real64) /= targets(k)) return
      end do
    end if
    workspace = 8_int64*p*(12_int64*(l + 1) + 6_int64*t)
    if (workspace > 33554432_int64) return
    call admitted_diagnostics()
  contains
    logical function valid_full(a)
      real(real64), intent(in) :: a(:, :)
      valid_full = size(a, 1) == p .and. size(a, 2) >= l
    end function
    logical function valid_target(a)
      real(real64), intent(in) :: a(:, :)
      valid_target = size(a, 1) == p .and. size(a, 2) >= t
    end function
    subroutine admitted_diagnostics()
      real(real64) :: half_phi(p, 0:l), full_phi(p, l), continuity(p, 0:l, 5)
      real(real64) :: saturation(p, l), model_rh(p, l)
      real(real64) :: pressure(p, t), log_pressure(p, t), standard_t(p, l + 1), standard_phi(p, l + 1)
      integer :: i, j, k
      do j = 1, t
        do i = first, last
          if (kind == 5) then
            pressure(i, j) = full_pressure(i, int(targets(j)))
          else
            pressure(i, j) = targets(j)
          end if
          ! PPINIT owns the source pressure logarithm at model levels.
          if (kind == 5) then
            log_pressure(i, j) = xp(i, int(targets(j)), 4)
          else
            log_pressure(i, j) = public_log(pressure(i, j))
          end if
        end do
      end do
      if (flags(1)) then
        half_phi(first:last, l) = terrain(first:last)
        call compute_geopotential(p, first, last, l, finite_elements, tables, integral_bc, derivative_bc, &
                                  gas, temperature, delta_log, half_phi, full_phi, status, alpha=alpha, metric=metric)
        if (status /= 0) return
      end if
      if (flags(3)) then
        call compute_vertical_continuity(p, first, last, l, finite_elements, .false., integral_bc, derivative_bc, &
                                tables, bfull, delta_b, inv_eta, u, v, divergence(:, 1:l), delta_pressure, surface_dx, surface_dy, &
                                         inverse_pressure, continuity, status, mass_source=mass_source)
        if (status /= 0) return
      end if
      if (flags(2)) then
        status = output_relative_humidity(first, last, rh_limits, rh_parameters, humidity, temperature, &
                                          full_pressure, saturation, model_rh)
        if (status /= 0) return
      end if
      if (kind == 1) then
        if (flags(4)) then
          call ppuv(p, first, last, l, t, 1, 4, kbelow, below_full, any_full, log_pressure, xp, xpd, &
                    u, v, wind_u, wind_v, constant_wind_top, quadratic_wind_top, status)
          if (status /= 0) return
        end if
        if (flags(1)) then
     call ppsta(constants, reference, 'PPREF', p, first, last, l + 1, 1, xp(:, :, 2), xp(:, :, 4), standard_t, standard_phi, status)
          if (status /= 0) return
          call ppgeop(constants, reference, lapse, .false., finite_elements, tables, integral_bc, derivative_bc, &
                      metric, p, first, last, l, t, 1, 4, kbelow, pressure, log_pressure, below_full, below_surface, any_full, &
                 any_surface, .true., terrain, xp, xpd, tstar, gas, delta_log, alpha, temperature, geopotential, standard_t, status)
          if (status /= 0) return
        end if
        if (flags(2)) then
          call ppq(p, first, last, l, t, 1, 4, kbelow, pressure, below_full, any_full, xp, xpd, model_rh, rh, status=status)
          if (status /= 0) return
        end if
        if (flags(3)) then
          call ppvvel(eta_half, finite_elements, p, first, last, l, t, 1, 4, kbelow, pressure, below_full, any_full, &
                      xp, xpd, inverse_delta, continuity(:, :, 1), continuity(:, 1:l, 2), omega, status, .false.)
          if (status /= 0) return
        end if
        if (flags(5)) then
          call pp2dint(p, first, last, l, 4, t, 1, t, kbelow, 2, below_full, any_full, pressure, xp, xpd, &
                       divergence, output_divergence, status)
          if (status /= 0) return
          call pp2dint(p, first, last, l, 4, t, 1, t, kbelow, 2, below_full, any_full, pressure, xp, xpd, &
                       vorticity, output_vorticity, status)
          if (status /= 0) return
        end if
      else
        do j = 1, t
          k = int(targets(j))
          do i = first, last
            if (flags(1)) geopotential(i, j) = full_phi(i, k)
            if (flags(2)) rh(i, j) = model_rh(i, k)
            if (flags(3)) omega(i, j) = xp(i, k, 2)*continuity(i, k, 2)
            if (flags(4)) then
              wind_u(i, j) = u(i, k); wind_v(i, j) = v(i, k)
            end if
            if (flags(5)) then
              output_divergence(i, j) = divergence(i, k); output_vorticity(i, j) = vorticity(i, k)
            end if
          end do
        end do
      end if
      if (flags(2) .and. rh_percent) then
        do j = 1, t
          do i = first, last
            rh(i, j) = rh(i, j)*100.0_real64
          end do
        end do
      end if
      status = 0
    end subroutine
  end subroutine
end module
