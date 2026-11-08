!> Interpolate actual forecast diagnostics to requested pressure levels.
!! Pressure is Pa, temperature K and geopotential m**2/s**2. Only active rows
!! and requested target levels change. Caller establishes the floating-point mode.
module forecast_runtime_dynamic_output_interpolation
  use iso_fortran_env, only: int32, int64, real64
  use yomhook, only: lhook, dr_hook
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_standard_atmosphere, only: atmosphere_layers
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_geopotential_and_column_water, only: compute_geopotential
  use forecast_pressure_level_interpolation, only: ppintp, ppsta
  implicit none
  private
  public :: pp2dint, ppvvel, ppgeop
contains
  !> PP2DINT preserves the source top extrapolation and constant bottom value.
  !! Inputs have (pitch,target,4) or (pitch,0:levels,4); output is INOUT.
  subroutine pp2dint(p, first, last, l, methods, t, lo, hi, kbelow, selector, below, anybelow, &
                     target, xp, xpd, input, output, status)
    integer(int32), intent(in) :: p, first, last, l, methods, t, lo, hi, selector
    integer(int32), intent(in) :: kbelow(:, :, :)
    logical, intent(in) :: below(:, :), anybelow(:)
    real(real64), intent(in) :: target(:, :), xp(:, 0:, :), xpd(:, 0:, :), input(:, 0:)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    integer :: i, k, j
    real(real64) :: difference, term, handle
    status = 2
    if (.not. valid_grid(p, first, last, l, t, lo)) return
    if (methods /= 4 .or. selector < 1 .or. selector > 4 .or. hi < lo - 1 .or. hi > t) return
    if (.not. valid_interpolation(p, l, t, kbelow, below, anybelow, target, xp, xpd, output)) return
    if (size(input, 1) /= p .or. size(input, 2) < l + 1) return
    do j = lo, hi
      do i = first, last
        if (anybelow(j)) then
          if (below(i, j)) cycle
        end if
        k = max(2, kbelow(i, j, selector))
        if (k > l) return
      end do
    end do
    if (lhook) call dr_hook('PP2DINT', 0, handle)
    do j = lo, hi
      do i = first, last
        if (anybelow(j)) then
          if (below(i, j)) then
            output(i, j) = input(i, l)
            cycle
          end if
        end if
        k = max(2, kbelow(i, j, selector))
        difference = input(i, k) - input(i, k - 1)
        term = target(i, j) - xp(i, k, selector)
        term = difference*term
        term = term*xpd(i, k - 1, selector)
        output(i, j) = input(i, k) + term
      end do
    end do
    if (lhook) call dr_hook('PP2DINT', 1, handle)
    status = 0
  end subroutine

  !> PPVVEL forms omega in Pa/s, or eta rate in 1/s, before interpolation.
  !! eta_half has bounds0:levels. A private workspace starts after admission.
  subroutine ppvvel(eta_half, finite_elements, p, first, last, l, t, lo, methods, kbelow, &
                    target, below, anybelow, xp, xpd, inverse_delta, eta_flux, omega_ratio, output, status, eta_rate)
    real(real64), intent(in) :: eta_half(0:)
    logical, intent(in) :: finite_elements
    integer(int32), intent(in) :: p, first, last, l, t, lo, methods
    integer(int32), intent(in) :: kbelow(:, :, :)
    real(real64), intent(in) :: target(:, :), xp(:, 0:, :), xpd(:, 0:, :), inverse_delta(:, :)
    real(real64), intent(in) :: eta_flux(:, 0:), omega_ratio(:, :)
    logical, intent(in) :: below(:, :), anybelow(:)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    logical, intent(in), optional :: eta_rate
    logical :: etad
    integer :: i, j
    status = 2
    if (.not. valid_grid(p, first, last, l, t, lo)) return
    if (methods /= 4) return
    if (.not. valid_interpolation(p, l, t, kbelow, below, anybelow, target, xp, xpd, output)) return
    if (size(eta_half) < l + 1 .or. size(inverse_delta, 1) /= p .or. size(inverse_delta, 2) < l) return
    if (size(eta_flux, 1) /= p .or. size(eta_flux, 2) < l + 1) return
    if (size(omega_ratio, 1) /= p .or. size(omega_ratio, 2) < l) return
    do j = lo, t
      do i = first, last
        if (anybelow(j)) then
          if (below(i, j)) cycle
        end if
        if (kbelow(i, j, 2) < 1 .or. kbelow(i, j, 2) > l) return
      end do
    end do
    etad = .false.
    if (present(eta_rate)) etad = eta_rate
    call admitted_vvel()
  contains
    subroutine admitted_vvel()
      real(real64) :: values(p, 0:l), value, depth, handle
      integer :: i, k, j
      if (lhook) call dr_hook('PPVVEL', 0, handle)
      if (etad) then
        if (finite_elements) then
          do k = 1, l
            do i = first, last
              depth = eta_half(k) - eta_half(k - 1)
              value = eta_flux(i, k)*depth
              values(i, k) = value*inverse_delta(i, k)
            end do
          end do
        else
          do k = 1, l
            do i = first, last
              value = eta_flux(i, k) + eta_flux(i, k - 1)
              value = 0.5_real64*value
              depth = eta_half(k) - eta_half(k - 1)
              value = value*depth
              values(i, k) = value*inverse_delta(i, k)
            end do
          end do
        end if
      else
        do k = 1, l
          do i = first, last
            values(i, k) = xp(i, k, 2)*omega_ratio(i, k)
          end do
        end do
      end if
      values(first:last, 0) = 0.0_real64
      call ppintp(p, first, last, l, t, lo, methods, kbelow, 2, below, anybelow, target, xp, xpd, values, output, status)
      if (status /= 0) return
      do j = lo, t
        if (anybelow(j)) then
          do i = first, last
            if (below(i, j)) output(i, j) = values(i, l)
          end do
        end if
      end do
      if (lhook) call dr_hook('PPVVEL', 1, handle)
    end subroutine
  end subroutine

  !> PPGEOP interpolates departures from the produced standard atmosphere.
  !! This runtime route uses the source current formulation, supplied standard
  !! temperatures, and hydrostatic gas constants. Old postprocessing is refused.
  !! The actual vertical operator tables and metric are borrowed without copying.
  subroutine ppgeop(constants, reference, lapse, old_postprocessing, finite_elements, tables, &
                    integral_bc, derivative_bc, metric, p, first, last, l, t, lo, methods, kbelow, &
                    pressure, log_pressure, below_full, below_surface, any_full, any_surface, extrapolate, &
                    terrain, xp, xpd, tstar, gas, delta_log, alpha, temperature, output, standard_temperature, status)
    type(forecast_physical_constants), intent(in) :: constants
    type(atmosphere_layers), intent(in) :: reference
    real(real64), intent(in) :: lapse, metric(:)
    logical, intent(in) :: old_postprocessing, finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc, derivative_bc
    integer(int32), intent(in) :: p, first, last, l, t, lo, methods
    integer(int32), intent(in) :: kbelow(:, :, :)
    real(real64), intent(in) :: pressure(:, :), log_pressure(:, :), terrain(:), xp(:, 0:, :), xpd(:, 0:, :)
    logical, intent(in) :: below_full(:, :), below_surface(:, :), any_full(:), any_surface(:), extrapolate
    real(real64), intent(in) :: tstar(:), gas(:, :), delta_log(:, :), alpha(:, :), temperature(:, :)
    real(real64), intent(in) :: standard_temperature(:, 0:)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    integer :: i, j, k
    integer(int64) :: workspace
    status = 2
    if (old_postprocessing) return
    if (.not. valid_grid(p, first, last, l, t, lo) .or. methods /= 4) return
    if (.not. valid_interpolation(p, l, t, kbelow, below_full, any_full, pressure, xp, xpd, output)) return
    if (size(log_pressure, 1) /= p .or. size(log_pressure, 2) < t) return
    if (size(below_surface, 1) /= p .or. size(below_surface, 2) < t .or. size(any_surface) < t) return
    if (size(terrain) < p .or. size(tstar) < p) return
    if (size(gas, 1) /= p .or. size(gas, 2) < l .or. size(delta_log, 1) /= p .or. size(delta_log, 2) < l) return
    if (size(alpha, 1) /= p .or. size(alpha, 2) < l .or. size(temperature, 1) /= p .or. size(temperature, 2) < l) return
    if (size(standard_temperature, 1) /= p .or. size(standard_temperature, 2) < l + 1) return
    if (finite_elements .and. size(metric) < l) return
    workspace = 8_int64*p*(7_int64*(l + 1) + 2_int64*t + 10_int64)
    if (workspace > 134217728_int64) return
    do j = lo, t
      do i = first, last
        if (any_full(j)) then
          if (below_full(i, j)) cycle
        end if
        k = kbelow(i, j, 4)
        if (k < 1 .or. k > l) return
      end do
    end do
    call admitted_geopotential()
  contains
    subroutine admitted_geopotential()
      real(real64) :: departure(p, 0:l), half_phi(p, 0:l), full_phi(p, l)
      real(real64) :: target_t(p, t), target_phi(p, t), surface_t(p, 1), surface_phi(p, 1)
      real(real64) :: modified_tstar(p), extrapolation_alpha(p), handle
      real(real64) :: xx, gamma, value, term, denominator, coefficient, z0, orog, log_ratio, lapse_gravity
      integer :: i, k, j
      if (lhook) call dr_hook('PPGEOP', 0, handle)
      departure(first:last, 1:l) = standard_temperature(first:last, 1:l)
      do k = 1, l
        do i = first, last
          value = departure(i, k)*constants%rd
          value = value/gas(i, k)
          departure(i, k) = temperature(i, k) - value
        end do
      end do
      half_phi(first:last, l) = 0.0_real64
      call compute_geopotential(p, first, last, l, finite_elements, tables, integral_bc, derivative_bc, &
                                gas, departure(:, 1:l), delta_log, half_phi, full_phi, status, alpha=alpha, metric=metric)
      if (status /= 0) return
      do k = 1, l
        do i = first, last
          departure(i, k) = departure(i, k)*gas(i, k)
        end do
      end do
      departure(first:last, 0) = departure(first:last, 1)
      do j = lo, t
        if (.not. any_full(j)) then
          do i = first, last
            k = kbelow(i, j, 4)
            denominator = xp(i, k, 4) - xp(i, k - 1, 4)
            value = xp(i, k, 4) - log_pressure(i, j)
            xx = value/denominator
            gamma = xp(i, k - 1, 4) + xp(i, k, 4)
            term = 2.0_real64*xp(i, k - 1, 3)
            gamma = gamma - term
            gamma = gamma/denominator
            value = xx - 1.5_real64
            value = gamma*value
            value = 0.5_real64 + value
            value = value*xx
            term = departure(i, k - 1) - departure(i, k)
            term = term*value
            term = departure(i, k) + term
            value = xp(i, k, 4) - log_pressure(i, j)
            term = value*term
            output(i, j) = full_phi(i, k) + term
          end do
        else
          do i = first, last
            if (.not. below_full(i, j)) then
              k = kbelow(i, j, 4)
              denominator = xp(i, k, 4) - xp(i, k - 1, 4)
              value = xp(i, k, 4) - log_pressure(i, j)
              xx = value/denominator
              gamma = xp(i, k - 1, 4) + xp(i, k, 4)
              term = 2.0_real64*xp(i, k - 1, 3)
              gamma = gamma - term
              gamma = gamma/denominator
              value = xx - 1.5_real64
              value = gamma*value
              value = 0.5_real64 + value
              value = value*xx
              term = departure(i, k - 1) - departure(i, k)
              term = term*value
              term = departure(i, k) + term
              value = xp(i, k, 4) - log_pressure(i, j)
              term = value*term
              output(i, j) = full_phi(i, k) + term
            else if (.not. below_surface(i, j)) then
              value = xp(i, l, 3) - log_pressure(i, j)
              denominator = xp(i, l, 3) - xp(i, l, 4)
              xx = value/denominator
              output(i, j) = xx*full_phi(i, l)
            end if
          end do
        end if
      end do
      call ppsta(constants, reference, 'PPREF', p, first, last, t, lo, pressure, log_pressure, target_t, target_phi, status)
      if (status /= 0) return
      call ppsta(constants, reference, 'PPREF', p, first, last, 1, 1, xp(:, l:l, 1), xp(:, l:l, 3), surface_t, surface_phi, status)
      if (status /= 0) return
      do j = lo, t
        do i = first, last
          if (.not. below_surface(i, j)) then
            value = terrain(i) - surface_phi(i, 1)
            value = value + target_phi(i, j)
            output(i, j) = value + output(i, j)
          end if
        end do
      end do
      if (extrapolate) then
        lapse_gravity = -lapse/constants%rg
        do i = first, last
          if (tstar(i) < 255.0_real64) then
            modified_tstar(i) = 0.5_real64*(255.0_real64 + tstar(i))
          else if (tstar(i) < 290.5_real64) then
            modified_tstar(i) = tstar(i)
          else
            modified_tstar(i) = 0.5_real64*(290.5_real64 + tstar(i))
          end if
          value = lapse_gravity*terrain(i)
          z0 = modified_tstar(i) + value
          if (290.5_real64 > modified_tstar(i) .and. z0 > 290.5_real64) then
            z0 = 290.5_real64
          else if (290.5_real64 <= modified_tstar(i) .and. z0 > modified_tstar(i)) then
            z0 = modified_tstar(i)
          end if
          orog = sign(max(1.0_real64, abs(terrain(i))), terrain(i))
          value = z0 - modified_tstar(i)
          value = constants%rd*value
          extrapolation_alpha(i) = value/orog
        end do
        do j = lo, t
          if (any_surface(j)) then
            do i = first, last
              if (below_surface(i, j)) then
                log_ratio = log_pressure(i, j) - xp(i, l, 3)
                coefficient = extrapolation_alpha(i)*log_ratio
                value = coefficient/6.0_real64
                value = 0.5_real64 + value
                value = coefficient*value
                value = 1.0_real64 + value
                term = constants%rd*modified_tstar(i)
                term = term*log_ratio
                term = term*value
                output(i, j) = terrain(i) - term
              end if
            end do
          end if
        end do
      else
        do j = lo, t
          if (any_surface(j)) then
            do i = first, last
              if (below_surface(i, j)) output(i, j) = -999999999999.0_real64
            end do
          end if
        end do
      end if
      if (lhook) call dr_hook('PPGEOP', 1, handle)
      status = 0
    end subroutine
  end subroutine

  logical function valid_grid(p, first, last, l, t, lo)
    integer, intent(in) :: p, first, last, l, t, lo
    valid_grid = p >= 1 .and. p <= 256 .and. l >= 2 .and. l <= 512 .and. t >= 1 .and. t <= 4096
    valid_grid = valid_grid .and. first >= 1 .and. first <= p + 1 .and. last >= 0 .and. last <= p .and. first <= last + 1
    valid_grid = valid_grid .and. lo >= 1 .and. lo <= t + 1
  end function
  logical function valid_interpolation(p, l, t, kbelow, below, anybelow, target, xp, xpd, output)
    integer, intent(in) :: p, l, t
    integer(int32), intent(in) :: kbelow(:, :, :)
    logical, intent(in) :: below(:, :), anybelow(:)
    real(real64), intent(in) :: target(:, :), xp(:, 0:, :), xpd(:, 0:, :), output(:, :)
    valid_interpolation = .false.
    if (size(kbelow, 1) /= p .or. size(kbelow, 2) < t .or. size(kbelow, 3) < 4) return
    if (size(below, 1) /= p .or. size(below, 2) < t .or. size(anybelow) < t) return
    if (size(target, 1) /= p .or. size(target, 2) < t) return
    if (size(xp, 1) /= p .or. size(xp, 2) < l + 1 .or. size(xp, 3) < 4) return
    if (size(xpd, 1) /= p .or. size(xpd, 2) < l + 1 .or. size(xpd, 3) < 4) return
    if (size(output, 1) /= p .or. size(output, 2) < t) return
    valid_interpolation = .true.
  end function
end module
