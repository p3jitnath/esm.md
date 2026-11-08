!> Apply the complete selected SPCHOR modal diffusion update.
module forecast_spectral_horizontal_diffusion
  use iso_c_binding, only: c_int, c_int64_t, c_double
  implicit none
  private
  public :: native_horizontal_diffusion_switches, apply_spectral_horizontal_diffusion
  public :: apply_runtime_spectral_horizontal_diffusion
  !> Source switches are dimensionless and canonical native logicals.
  type :: native_horizontal_diffusion_switches
    logical :: lstrhd, lm0damp, lnhdyn, lnhx, lslhd_w, lslhd_svd, lrhdddh, lnsponge
    logical :: lstoph_spbs, lstoph_casbs, lvortcon, lspt, lnudg
  end type
contains
  !> Dampen every nonzero order in original wind-then-temperature order.
  !! Fields have dense (local level,spectral column) storage; pressure is
  !! one-dimensional. Rates RDIVOR/RDIDIV use(local level,degree0:), RDITG
  !! uses(global level,degree0:). Rates are in1/s, DT in seconds, temperature
  !! and RCORDIT in K, winds in the source spectral units, and pressure is
  !! the source dimensionless logarithmic surface-pressure coefficient.
  !! All arrays remain caller-owned. Unconsumed carriers and order0 remain
  !! untouched. Status2 refuses atomically instead of the old raw-ABI abort.
  integer(c_int) function apply_spectral_horizontal_diffusion(switches, levels, truncation, level_offset, &
                           orders, first_column, dt, rdivor, rdidiv, rditg, rcordit, pressure, vorticity, divergence, temperature, &
                                                              successful_calls) result(status)
    type(native_horizontal_diffusion_switches), intent(in) :: switches
    integer(c_int), intent(in) :: levels, truncation, level_offset, orders(:), first_column(0:)
    real(c_double), intent(in) :: dt, rdivor(:, 0:), rdidiv(:, 0:), rditg(:, 0:), rcordit(:), pressure(:)
    real(c_double), contiguous, intent(inout) :: vorticity(:, :), divergence(:, :), temperature(:, :)
    integer(c_int64_t), optional, intent(inout) :: successful_calls
    integer(c_int) :: columns
    status = 2
    if (truncation < 0 .or. truncation > 256) return
    columns = (truncation + 1)*(truncation + 2)
    status = apply_diffusion_impl(.false., columns, switches, levels, truncation, level_offset, &
                           orders, first_column, dt, rdivor, rdidiv, rditg, rcordit, pressure, vorticity, divergence, temperature, &
                                  successful_calls)
  end function
  !> Apply the same ordered source update to live distributed field extents.
  !! ACTIVE_COLUMNS is the actual local packed spectral count. ORDERS is
  !! the actual local order prefix; no global-order substitution is made.
  !! This new domain is compiled only and requires independent qualification.
  integer(c_int) function apply_runtime_spectral_horizontal_diffusion(active_columns, switches, levels, truncation, level_offset, &
                           orders, first_column, dt, rdivor, rdidiv, rditg, rcordit, pressure, vorticity, divergence, temperature, &
                                                                      successful_calls) result(status)
    integer(c_int), intent(in) :: active_columns
    type(native_horizontal_diffusion_switches), intent(in) :: switches
    integer(c_int), intent(in) :: levels, truncation, level_offset, orders(:), first_column(0:)
    real(c_double), intent(in) :: dt, rdivor(:, 0:), rdidiv(:, 0:), rditg(:, 0:), rcordit(:), pressure(:)
    real(c_double), contiguous, intent(inout) :: vorticity(:, :), divergence(:, :), temperature(:, :)
    integer(c_int64_t), optional, intent(inout) :: successful_calls
    status = apply_diffusion_impl(.true., active_columns, switches, levels, truncation, level_offset, &
                           orders, first_column, dt, rdivor, rdidiv, rditg, rcordit, pressure, vorticity, divergence, temperature, &
                                  successful_calls)
  end function
  integer(c_int) function apply_diffusion_impl(runtime, active_columns, switches, levels, truncation, level_offset, &
                           orders, first_column, dt, rdivor, rdidiv, rditg, rcordit, pressure, vorticity, divergence, temperature, &
                                               successful_calls) result(status)
    logical, intent(in) :: runtime
    integer(c_int), intent(in) :: active_columns
    type(native_horizontal_diffusion_switches), intent(in) :: switches
    integer(c_int), intent(in) :: levels, truncation, level_offset, orders(:), first_column(0:)
    real(c_double), intent(in) :: dt, rdivor(:, 0:), rdidiv(:, 0:), rditg(:, 0:), rcordit(:), pressure(:)
    real(c_double), contiguous, intent(inout) :: vorticity(:, :), divergence(:, :), temperature(:, :)
    integer(c_int64_t), optional, intent(inout) :: successful_calls
    integer(c_int) :: columns, wave, mode, prior, first, last, prior_first, prior_last, degree, column, level, global_level
    real(c_double) :: interval, product_value, denominator, value, correction
    status = 2
    if (levels < 0 .or. levels > 256 .or. truncation < 0 .or. truncation > 4096) return
    if (.not. runtime) then
      if (levels < 1 .or. truncation > 256) return
      if (size(orders) /= truncation + 1) return
    end if
    if (size(orders) > truncation + 1 .or. active_columns < 0) return
    if (active_columns > (truncation + 1)*(truncation + 2)) return
    if (level_offset < 0 .or. level_offset > 256 - levels) return
    if (size(first_column) < truncation + 1) return
    if (transfer(switches%lstrhd, 0_c_int) /= 0 .or. transfer(switches%lm0damp, 0_c_int) /= 0) return
    if (transfer(switches%lnhdyn, 0_c_int) /= 0 .or. transfer(switches%lnhx, 0_c_int) /= 0) return
    if (transfer(switches%lslhd_w, 0_c_int) /= 0 .or. transfer(switches%lslhd_svd, 0_c_int) /= 0) return
    if (transfer(switches%lrhdddh, 0_c_int) /= 0 .or. transfer(switches%lnsponge, 0_c_int) /= 0) return
    if (transfer(switches%lstoph_spbs, 0_c_int) /= 0 .or. transfer(switches%lstoph_casbs, 0_c_int) /= 0) return
    if (transfer(switches%lvortcon, 0_c_int) /= 0 .or. transfer(switches%lnudg, 0_c_int) /= 0) return
    if (transfer(switches%lspt, 0_c_int) /= 1) return
    if (present(successful_calls)) then
      if (successful_calls < 0_c_int64_t .or. successful_calls == huge(0_c_int64_t)) return
    end if
    columns = active_columns
    if (size(vorticity, 1) < levels .or. size(vorticity, 1) > 256 .or. size(vorticity, 2) < columns) return
    if (size(divergence, 1) < levels .or. size(divergence, 1) > 256 .or. size(divergence, 2) < columns) return
    if (size(temperature, 1) < levels .or. size(temperature, 1) > 256 .or. size(temperature, 2) < columns) return
    if (size(rdivor, 1) < levels .or. size(rdivor, 1) > 256 .or. size(rdivor, 2) < truncation + 1) return
    if (size(rdidiv, 1) < levels .or. size(rdidiv, 1) > 256 .or. size(rdidiv, 2) < truncation + 1) return
    if (size(rditg, 1) < level_offset + levels .or. size(rditg, 1) > 256 .or. size(rditg, 2) < truncation + 1) return
    if (size(rcordit) < level_offset + levels .or. size(pressure) < columns) return
    if (.not. bounded_value(dt, .false.)) return
    do wave = 1, size(orders)
      mode = orders(wave)
      if (mode < 0 .or. mode > truncation) return
      first = first_column(mode)
      if (first < 1 .or. first > columns) return
      last = first + 2*(truncation - mode) + 1
      if (last > columns) return
      do prior = 1, wave - 1
        if (orders(prior) == mode) return
        prior_first = first_column(orders(prior))
        prior_last = prior_first + 2*(truncation - orders(prior)) + 1
        if (last >= prior_first .and. prior_last >= first) return
      end do
      if (mode == 0) cycle
      do degree = mode, truncation
        column = first + 2*(degree - mode)
        do level = 1, levels
          if (.not. bounded_value(vorticity(level, column), .false.)) return
          if (.not. bounded_value(vorticity(level, column + 1), .false.)) return
          if (.not. bounded_value(divergence(level, column), .false.)) return
          if (.not. bounded_value(divergence(level, column + 1), .false.)) return
          if (.not. bounded_value(temperature(level, column), .false.)) return
          if (.not. bounded_value(temperature(level, column + 1), .false.)) return
          if (.not. bounded_value(pressure(column), .false.)) return
          if (.not. bounded_value(pressure(column + 1), .false.)) return
          if (.not. bounded_value(rdivor(level, degree), .true.)) return
          if (.not. bounded_value(rdidiv(level, degree), .true.)) return
          global_level = level_offset + level
          if (.not. bounded_value(rditg(global_level, degree), .true.)) return
          if (.not. bounded_value(rcordit(global_level), .false.)) return
        end do
      end do
    end do
    interval = abs(dt)
    do wave = 1, size(orders)
      mode = orders(wave)
      if (mode == 0) cycle
      do degree = mode, truncation
        column = first_column(mode) + 2*(degree - mode)
        do level = 1, levels
          product_value = interval*rdivor(level, degree)
          denominator = 1.0_c_double + product_value
          vorticity(level, column) = vorticity(level, column)/denominator
          vorticity(level, column + 1) = vorticity(level, column + 1)/denominator
          product_value = interval*rdidiv(level, degree)
          denominator = 1.0_c_double + product_value
          divergence(level, column) = divergence(level, column)/denominator
          divergence(level, column + 1) = divergence(level, column + 1)/denominator
        end do
        do level = 1, levels
          global_level = level_offset + level
          correction = rcordit(global_level)*pressure(column)
          correction = correction*interval
          correction = correction*rditg(global_level, degree)
          value = temperature(level, column) + correction
          product_value = interval*rditg(global_level, degree)
          denominator = 1.0_c_double + product_value
          temperature(level, column) = value/denominator
          correction = rcordit(global_level)*pressure(column + 1)
          correction = correction*interval
          correction = correction*rditg(global_level, degree)
          value = temperature(level, column + 1) + correction
          temperature(level, column + 1) = value/denominator
        end do
      end do
    end do
    if (present(successful_calls)) successful_calls = successful_calls + 1_c_int64_t
    status = 0
  end function
  pure logical function bounded_value(value, rate) result(valid)
    real(c_double), intent(in) :: value
    logical, intent(in) :: rate
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    valid = ibits(bits, 52, 11) < 1151_c_int64_t
    if (rate .and. btest(bits, 63) .and. iand(bits, int(z'7fffffffffffffff', c_int64_t)) /= 0) valid = .false.
  end function
end module forecast_spectral_horizontal_diffusion
