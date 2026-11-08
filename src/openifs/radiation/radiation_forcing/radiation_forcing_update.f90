!> Update gas mass fractions and solar forcing from explicitly owned inputs.
module native_radiation_forcing
  use iso_fortran_env, only: real64, int32, int64
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, &
                             ieee_get_underflow_mode, operator(/=)
  use yomdyna, only: tdyna
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yomrip, only: trip
  use native_radiation_climate_records, only: radiation_climate_context
  use native_greenhouse_timeseries, only: get_ghg_concentrations
  use native_solar_irradiance, only: get_solar_irradiance
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: radiation_forcing_clock_record, update_owned_radiation_forcing
  public :: radiation_decimal_year, updrgas
  !> Explicit readonly date, restart step and forecast-mode inputs.
  type :: radiation_forcing_clock_record
    integer(int32) :: nindat, nstar2
    logical :: lnf
    integer(int32) :: reserved
  end type
  interface
    subroutine public_abort() bind(C, name='abort')
    end subroutine
  end interface
contains
  !> Retain the generated GET_YEAR calculation with an explicit native clock.
  !! DYNAMICS and TIME are readonly native OpenIFS data records. CLOCK gives
  !! date YYYYMMDD, restart step and the forecast-mode flag. CONSTANTS%RDAY
  !! uses seconds. YEAR is a separate INOUT scalar in calendar years and
  !! changes only on success. The caller supplies a valid calendar date.
  !! Restart integer operations must fit int32. Separate NINT, multiply,
  !! day division and decimal-year operations retain their source order.
  !! Return0 or2; unused restart fields are not evaluated.
  integer(int32) function radiation_decimal_year(dynamics, time, clock, constants, year) result(status)
    type(tdyna), intent(in) :: dynamics
    type(trip), intent(in) :: time
    type(radiation_forcing_clock_record), intent(in) :: clock
    type(forecast_physical_constants), intent(in) :: constants
    real(real64), intent(inout) :: year
    real(real64), parameter :: month_days(12) = [0.0_real64, 31.0_real64, 59.25_real64, &
                                                 90.25_real64, 120.25_real64, 151.25_real64, 181.25_real64, 212.25_real64, &
                                                 243.25_real64, 273.25_real64, 304.25_real64, 334.25_real64]
    integer(int32), volatile :: rounded_timestep
    integer(int32) :: elapsed, seconds, day_seconds, year_integer, month, day
    integer(int64) :: integer_product
    real(real64) :: restart_steps, product, day_value, fraction
    status = 2_int32
    year_integer = clock%nindat/10000_int32
    month = mod(clock%nindat/100_int32, 100_int32)
    day = mod(clock%nindat, 100_int32)
    if (year_integer < 1 .or. month < 1 .or. month > 12 .or. day < 1 .or. day > 31) return
    elapsed = time%nstadd
    if (.not. clock%lnf .and. elapsed == 0) then
      if (.not. finite_value(time%tstep)) return
      if (abs(time%tstep) >= 2147483647.0_real64) return
      if (.not. positive_finite(constants%rday)) return
      if (constants%rday >= 2147483647.0_real64) return
      rounded_timestep = nint(time%tstep, kind=int32)
      if (dynamics%ltwotl) then
        restart_steps = real(clock%nstar2, real64) + 0.5_real64
        product = time%tstep*restart_steps
        if (.not. finite_value(product)) return
        if (abs(product) >= 2147483647.0_real64) return
        seconds = nint(product, kind=int32)
      else
        integer_product = int(rounded_timestep, int64)*int(clock%nstar2, int64)
        if (integer_product < -2147483648_int64 .or. integer_product > 2147483647_int64) return
        seconds = int(integer_product, int32)
      end if
      day_seconds = nint(constants%rday, kind=int32)
      if (day_seconds == 0) return
      elapsed = seconds/day_seconds
    end if
    day_value = real(day, real64) - 1.0_real64
    day_value = day_value + month_days(month)
    day_value = day_value + real(elapsed, real64)
    fraction = day_value/365.25_real64
    year = real(year_integer, real64) + fraction
    status = 0_int32
  end function

  !> Port the source UPDRGAS body without original globals or numerical calls.
  !! The first four arguments retain the original native record order:
  !! DYNAMICS, RADIATION and TIME are readonly; GASES is caller-owned INOUT.
  !! CONSTANTS, CLIMATE and CLOCK are explicit owned inputs kept live for the
  !! call. CLIMATE has450 solar rows and2501 gas rows at logical indices1:N.
  !! Every table is readonly and has its accepted finite increasing dates.
  !! Output GASES is separate from every input record and payload. The eight
  !! source mass fractions use kg/kg of dry air; solar input uses W/m^2.
  !! SOLAR_OVERRIDE is optional readonly positive finite irradiance.
  !! Fixed-year and unused restart/solar branches do not consume their unused
  !! scalar values. All consumed lookup years must be strictly interior.
  !! Nearest rounding and gradual underflow are required. Nine named fields
  !! change on success; every other GASES member remains unchanged. No array
  !! allocation, diagnostic I/O, original method or verification stage runs.
  !! Return0 after the source-ordered update or2 before unsupported mutation.
  integer(int32) function update_owned_radiation_forcing(dynamics, radiation, gases, time, &
                                                         constants, climate, clock, solar_override) result(status)
    type(tdyna), intent(in) :: dynamics
    type(terad), intent(in) :: radiation
    type(terdi), intent(inout) :: gases
    type(trip), intent(in) :: time
    type(forecast_physical_constants), intent(in) :: constants
    type(radiation_climate_context), intent(in) :: climate
    type(radiation_forcing_clock_record), intent(in) :: clock
    real(real64), intent(in), optional :: solar_override
    real(real64), volatile :: ratios(8)
    real(real64) :: year, co2, ch4, n2o, cfc11, cfc12, hcfc22, ccl4, solar
    integer(int32) :: child_status
    type(ieee_round_type) :: rounding
    logical :: gradual
    status = 2_int32
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_underflow_mode(gradual)
    if (.not. gradual) return
    if (climate%solar%ntime /= 450 .or. climate%timeseries%ntime /= 2501) return
    if (.not. allocated(climate%solar%ryear)) return
    if (lbound(climate%solar%ryear, 1) > 1 .or. ubound(climate%solar%ryear, 1) < 450) return
    if (.not. allocated(climate%solar%rtsi)) return
    if (lbound(climate%solar%rtsi, 1) > 1 .or. ubound(climate%solar%rtsi, 1) < 450) return
    if (.not. allocated(climate%timeseries%ryear)) return
    if (lbound(climate%timeseries%ryear, 1) > 1 .or. ubound(climate%timeseries%ryear, 1) < 2501) return
    if (.not. allocated(climate%timeseries%vmr_co2)) return
    if (lbound(climate%timeseries%vmr_co2, 1) > 1 .or. ubound(climate%timeseries%vmr_co2, 1) < 2501) return
    if (.not. allocated(climate%timeseries%vmr_ch4)) return
    if (lbound(climate%timeseries%vmr_ch4, 1) > 1 .or. ubound(climate%timeseries%vmr_ch4, 1) < 2501) return
    if (.not. allocated(climate%timeseries%vmr_n2o)) return
    if (lbound(climate%timeseries%vmr_n2o, 1) > 1 .or. ubound(climate%timeseries%vmr_n2o, 1) < 2501) return
    if (.not. allocated(climate%timeseries%vmr_cfc11)) return
    if (lbound(climate%timeseries%vmr_cfc11, 1) > 1 .or. ubound(climate%timeseries%vmr_cfc11, 1) < 2501) return
    if (.not. allocated(climate%timeseries%vmr_cfc12)) return
    if (lbound(climate%timeseries%vmr_cfc12, 1) > 1 .or. ubound(climate%timeseries%vmr_cfc12, 1) < 2501) return
    if (.not. allocated(climate%timeseries%vmr_hcfc22)) return
    if (lbound(climate%timeseries%vmr_hcfc22, 1) > 1 .or. ubound(climate%timeseries%vmr_hcfc22, 1) < 2501) return
    if (.not. allocated(climate%timeseries%vmr_ccl4)) return
    if (lbound(climate%timeseries%vmr_ccl4, 1) > 1 .or. ubound(climate%timeseries%vmr_ccl4, 1) < 2501) return
    if (.not. positive_finite(constants%rmd)) return
    if (.not. positive_finite(constants%rmco2)) return
    if (.not. positive_finite(constants%rmch4)) return
    if (.not. positive_finite(constants%rmn2o)) return
    if (.not. positive_finite(constants%rmno2)) return
    if (.not. positive_finite(constants%rmcfc11)) return
    if (.not. positive_finite(constants%rmcfc12)) return
    if (.not. positive_finite(constants%rmhcfc22)) return
    if (.not. positive_finite(constants%rmccl4)) return
    if (present(solar_override)) then
      if (.not. positive_finite(solar_override)) return
    end if
    if (time%yrecmip%ncmipfixyr > 0) then
      year = real(time%yrecmip%ncmipfixyr, real64) + 0.5_real64
    else
      child_status = radiation_decimal_year(dynamics, time, clock, constants, year)
      if (child_status /= 0) return
    end if
    if (.not. (year > climate%timeseries%ryear(1) .and. year < climate%timeseries%ryear(2501))) return
    if (.not. present(solar_override)) then
      if (radiation%nhincsol /= 0) then
        if (.not. (year > climate%solar%ryear(1) .and. year < climate%solar%ryear(450))) return
      end if
    end if
    ratios(1) = constants%rmco2/constants%rmd
    ratios(2) = constants%rmch4/constants%rmd
    ratios(3) = constants%rmn2o/constants%rmd
    ratios(4) = constants%rmno2/constants%rmd
    ratios(5) = constants%rmcfc11/constants%rmd
    ratios(6) = constants%rmcfc12/constants%rmd
    ratios(7) = constants%rmhcfc22/constants%rmd
    ratios(8) = constants%rmccl4/constants%rmd
    child_status = get_ghg_concentrations(climate%timeseries, year, co2, ch4, n2o, cfc11, cfc12, hcfc22, ccl4)
    if (child_status /= 0) return
    gases%rcardi = co2*ratios(1)
    gases%rch4 = ch4*ratios(2)
    gases%rn2o = n2o*ratios(3)
    gases%rcfc11 = cfc11*ratios(5)
    gases%rcfc12 = cfc12*ratios(6)
    gases%rcfc22 = hcfc22*ratios(7)
    gases%rccl4 = ccl4*ratios(8)
    gases%rno2 = 5.0e-11_real64*ratios(4)
    if (present(solar_override)) then
      gases%rsolinc = solar_override
    else if (radiation%nhincsol == 0) then
      gases%rsolinc = constants%ri0
    else
      child_status = get_solar_irradiance(climate%solar, year, solar)
      if (child_status /= 0) return
      gases%rsolinc = solar
    end if
    status = 0_int32
  end function

  !> Forward the native forecast caller to its explicit owned forcing inputs.
  !! The first four records follow the original UPDRGAS order. CONSTANTS,
  !! CLIMATE and CLOCK replace hidden module aliases; the optional solar
  !! scalar retains its source meaning. This adapter performs no arithmetic.
  !! An unsupported call reaches the declared public libc abort boundary.
  subroutine updrgas(dynamics, radiation, gases, time, constants, climate, clock, solar_override)
    type(tdyna), intent(in) :: dynamics
    type(terad), intent(in) :: radiation
    type(terdi), intent(inout) :: gases
    type(trip), intent(in) :: time
    type(forecast_physical_constants), intent(in) :: constants
    type(radiation_climate_context), intent(in) :: climate
    type(radiation_forcing_clock_record), intent(in) :: clock
    real(real64), intent(in), optional :: solar_override
    integer(int32) :: status
    status = update_owned_radiation_forcing(dynamics, radiation, gases, time, constants, climate, clock, solar_override)
    if (status /= 0_int32) call public_abort()
  end subroutine

  logical function positive_finite(value)
    real(real64), intent(in) :: value
    integer(int64) :: bits
    bits = transfer(value, 0_int64)
    positive_finite = bits > 0_int64 .and. bits < int(z'7ff0000000000000', int64)
  end function
  logical function finite_value(value)
    real(real64), intent(in) :: value
    integer(int64) :: bits
    bits = iand(transfer(value, 0_int64), int(z'7fffffffffffffff', int64))
    finite_value = bits < int(z'7ff0000000000000', int64)
  end function
end module native_radiation_forcing
