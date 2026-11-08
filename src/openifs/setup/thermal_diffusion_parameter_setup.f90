module thermal_diffusion_parameter_setup_port
  !! Build the atmospheric thermal coefficients and stability spline table.
  !! This is the ordered native port of the generated SUPHEC/SUVDFS children.
  use, intrinsic :: iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record, stability_parameter_record
  implicit none
  private
  public :: initialize_thermal_diffusion_parameters
  public :: initialize_thermal_namespace_fields, initialize_stability_table_fields
contains
  function initialize_thermal_diffusion_parameters(constants, thermal, stability) &
    bind(c, name="md2asm_initialize_thermal_diffusion_parameters_fortran") result(status)
    !! Initialize both complete native parameter records.
    !!
    !! CONSTANTS is read-only, with gas and heat capacities in J kg^-1 K^-1,
    !! temperature in kelvin and latent heats in J kg^-1. THERMAL and STABILITY
    !! are disjoint complete output records, also disjoint from CONSTANTS.
    !! The compiler supplies their layout and alignment. The caller establishes
    !! nearest rounding, gradual underflow, no traps and the frozen FPCR 0.
    !! Return 2 without output mutation for an unsupported scalar bit pattern.
    !! Return 0 after all fields are written. Preserve natural numerical flags.
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(inout) :: thermal
    type(stability_parameter_record), intent(inout) :: stability
    integer(c_int) :: status
    integer(c_int64_t), parameter :: one_bits = int(z'3ff0000000000000', c_int64_t)
    integer(c_int64_t), parameter :: ten_thousand_bits = int(z'40c3880000000000', c_int64_t)
    integer(c_int64_t), parameter :: two_hundred_bits = int(z'4069000000000000', c_int64_t)
    integer(c_int64_t), parameter :: three_fifty_bits = int(z'4075e00000000000', c_int64_t)
    integer(c_int64_t), parameter :: hundred_million_bits = int(z'4197d78400000000', c_int64_t)
    status = 2_c_int
    if (.not. scalar_bits_in_range(constants%rd, one_bits, ten_thousand_bits)) return
    if (.not. scalar_bits_in_range(constants%rv, one_bits, ten_thousand_bits)) return
    if (.not. scalar_bits_in_range(constants%rcpd, one_bits, ten_thousand_bits)) return
    if (.not. scalar_bits_in_range(constants%rtt, two_hundred_bits, three_fifty_bits)) return
    if (.not. scalar_bits_in_range(constants%rlvtt, one_bits, hundred_million_bits)) return
    if (.not. scalar_bits_in_range(constants%rlstt, one_bits, hundred_million_bits)) return
    if (.not. scalar_bits_in_range(constants%rlmlt, one_bits, hundred_million_bits)) return
    call initialize_thermal_namespace_fields(constants, thermal)
    call initialize_stability_table_fields(stability)
    status = 0_c_int
  end function

  pure function scalar_bits_in_range(value, lower, upper) result(admitted)
    !! Check positive finite source bounds without floating-point comparison.
    real(c_double), intent(in) :: value
    integer(c_int64_t), intent(in) :: lower, upper
    logical :: admitted
    integer(c_int64_t) :: bits
    bits = transfer(value, 0_c_int64_t)
    admitted = bits >= lower .and. bits <= upper
  end function

  subroutine initialize_thermal_namespace_fields(constants, thermal)
    !! Set all 23 atmospheric thermal coefficients in source order.
    !! Temperature shifts use kelvin, density uses kg m^-3, and saturation
    !! pressure coefficients use pascals. Heat ratios retain source units.
    !! Initial convective ice limits use RTT minus 23 K; the later convection
    !! stage owns any subsequent selected RTT minus 38 K change.
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(inout) :: thermal
    real(c_double), volatile :: a, b, c, d, e, f
    a = 611.21_c_double
    b = constants%rd
    a = a*b
    b = constants%rv
    a = a/b
    thermal%r2es = a
    a = 17.502_c_double
    b = 22.587_c_double
    thermal%r3les = a
    thermal%r3ies = b
    c = 32.19_c_double
    d = -0.7_c_double
    thermal%r4les = c
    thermal%r4ies = d
    e = constants%rtt
    f = e - c
    f = a*f
    thermal%r5les = f
    c = e - d
    c = b*c
    thermal%r5ies = c
    thermal%rvtmp2 = 0.0_c_double
    thermal%rhoh2o = 0.0_c_double
    thermal%rhoh2o = 1000.0_c_double
    a = constants%rlvtt
    b = constants%rlstt
    d = constants%rcpd
    f = f*a
    f = f/d
    thermal%r5alvcp = f
    f = c*b
    f = f/d
    thermal%r5alscp = f
    a = a/d
    b = b/d
    thermal%ralvdcp = a
    thermal%ralsdcp = b
    a = constants%rlmlt
    a = a/d
    thermal%ralfdcp = a
    thermal%rtwat = e
    a = 5.0_c_double
    a = e - a
    thermal%rtber = a
    thermal%rtbercu = a
    a = 23.0_c_double
    a = e - a
    thermal%rtice = a
    thermal%rticecu = a
    a = e - a
    b = 1.0_c_double
    a = b/a
    thermal%rtwat_rtice_r = a
    thermal%rtwat_rticecu_r = a
    thermal%rkoop1 = 2.583_c_double
    thermal%rkoop2 = 0.0048116_c_double
  end subroutine

  subroutine initialize_stability_table_fields(stability)
    !! Set the 101-point dimensionless stability table and spline curvatures.
    !! RITBL uses the preceding result as each Newton starting value. Preserve
    !! five updates below Richardson number 0.5 and three updates elsewhere.
    !! ARITBL receives the original clamped cubic-spline second derivatives.
    type(stability_parameter_record), intent(inout) :: stability
    real(c_double) :: zu(101)
    real(c_double), volatile :: target, guess, delta, above, below, value, denominator
    real(c_double), volatile :: residual_above, residual_below, numerator, second, pivot, secant
    integer :: point, iteration, iterations
    stability%rchba = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    stability%rchbb = transfer(int(z'3fe5555555555555', c_int64_t), 0.0_c_double)
    stability%rchbc = transfer(int(z'4014000000000000', c_int64_t), 0.0_c_double)
    stability%rchbd = transfer(int(z'3fd6666666666666', c_int64_t), 0.0_c_double)
    stability%rchb23a = transfer(int(z'3fe5555555555555', c_int64_t), 0.0_c_double)
    stability%rchbbcd = transfer(int(z'40230c30c30c30c3', c_int64_t), 0.0_c_double)
    stability%rchbcd = transfer(int(z'402c924924924925', c_int64_t), 0.0_c_double)
    stability%rcheta = transfer(int(z'4014000000000000', c_int64_t), 0.0_c_double)
    stability%rchetb = transfer(int(z'4010000000000000', c_int64_t), 0.0_c_double)
    stability%rchbhdl = transfer(int(z'4014000000000000', c_int64_t), 0.0_c_double)
    stability%rcdhalf = transfer(int(z'4030000000000000', c_int64_t), 0.0_c_double)
    stability%rcdhpi2 = transfer(int(z'3ff921fb54442d18', c_int64_t), 0.0_c_double)
    stability%rimax = transfer(int(z'4024000000000000', c_int64_t), 0.0_c_double)
    stability%dritbl = transfer(int(z'3fb999999999999a', c_int64_t), 0.0_c_double)
    stability%dri26 = transfer(int(z'3f5b4e81b4e81b50', c_int64_t), 0.0_c_double)
    stability%ritbl(1) = 0.0_c_double
    do point = 1, 100
      target = real(point, c_double)
      target = target*stability%dritbl
      guess = stability%ritbl(point)
      if (target < 0.5_c_double) then
        iterations = 5
      else
        iterations = 3
      end if
      do iteration = 1, iterations
        delta = guess + 1.0_c_double
        delta = delta*0.001_c_double
        above = guess + delta
        below = guess - delta
        value = 4.0_c_double*above
        value = 1.0_c_double + value
        value = value*value
        value = above*value
        denominator = 5.0_c_double*above
        denominator = 1.0_c_double + denominator
        denominator = denominator*denominator
        value = value/denominator
        residual_above = target - value
        value = 4.0_c_double*below
        value = 1.0_c_double + value
        value = value*value
        value = below*value
        denominator = 5.0_c_double*below
        denominator = 1.0_c_double + denominator
        denominator = denominator*denominator
        value = value/denominator
        residual_below = target - value
        numerator = residual_above + residual_below
        numerator = delta*numerator
        denominator = residual_above - residual_below
        value = numerator/denominator
        guess = guess - value
      end do
      stability%ritbl(point + 1) = guess
    end do
    stability%aritbl(1) = -0.5_c_double
    value = stability%ritbl(2) - stability%ritbl(1)
    value = value/stability%dritbl
    value = value - 1.0_c_double
    second = 3.0_c_double/stability%dritbl
    value = second*value
    zu(1) = value
    do point = 1, 99
      pivot = 0.5_c_double*stability%aritbl(point)
      pivot = pivot + 2.0_c_double
      value = -0.5_c_double
      value = value/pivot
      stability%aritbl(point + 1) = value
      value = stability%ritbl(point + 2) - stability%ritbl(point + 1)
      value = value/stability%dritbl
      second = stability%ritbl(point + 1) - stability%ritbl(point)
      second = second/stability%dritbl
      value = value - second
      value = 6.0_c_double*value
      second = 2.0_c_double*stability%dritbl
      value = value/second
      second = 0.5_c_double*zu(point)
      value = value - second
      value = value/pivot
      zu(point + 1) = value
    end do
    value = stability%ritbl(101)
    second = stability%ritbl(100)
    secant = value - second
    secant = secant/stability%dritbl
    value = value - second
    value = value/stability%dritbl
    value = secant - value
    second = 3.0_c_double/stability%dritbl
    value = second*value
    second = 0.5_c_double*zu(100)
    value = value - second
    second = 0.5_c_double*stability%aritbl(100)
    second = second + 1.0_c_double
    value = value/second
    stability%aritbl(101) = value
    do point = 100, 1, -1
      value = stability%aritbl(point)*stability%aritbl(point + 1)
      second = zu(point)
      value = value + second
      stability%aritbl(point) = value
    end do
  end subroutine
end module thermal_diffusion_parameter_setup_port
