module yos_thf
  use iso_fortran_env, only: real64
  implicit none
  !> Owned saturation coefficients. Density uses kg m^-3; temperatures use kelvin.
  real(real64), save :: rhoh2o
  real(real64), save :: rvtmp2
  real(real64), save :: r2es
  real(real64), save :: r3les
  real(real64), save :: r3ies
  real(real64), save :: r4les
  real(real64), save :: r4ies
  real(real64), save :: r5les
  real(real64), save :: r5ies
end module yos_thf

module yos_excs
  use iso_fortran_env, only: int32, real64
  implicit none
  integer(int32), parameter :: jpritbl = 101
  !> Owned dimensionless stability table and coefficients.
  real(real64), save :: ritbl(jpritbl)
  real(real64), save :: dritbl
  real(real64), save :: rimax
  real(real64), save :: rchba
  real(real64), save :: rchbb
  real(real64), save :: rchbc
  real(real64), save :: rchbd
  real(real64), save :: rchb23a
  real(real64), save :: rchbbcd
  real(real64), save :: rchbcd
  real(real64), save :: rcheta
  real(real64), save :: rchetb
  real(real64), save :: rchbhdl
  real(real64), save :: rcdhalf
  real(real64), save :: rcdhpi2
  real(real64), save :: rlpbb
  real(real64), save :: rlpcc
  real(real64), save :: rlpdd
end module yos_excs

module suscst_mod
  use iso_fortran_env, only: int64, real64
  use yos_cst, only: tcst
  implicit none
  private
  public :: suscst
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Set the surface physical constants through their frozen ordered operations.
  !!
  !! PRCORIOI scales rotation and is zero, one half, one or two. Either zero
  !! sign selects the fixed 86400 s day and positive-zero rotation. PRPLRG
  !! scales gravity and is one half, one or two. YDCST receives temperatures
  !! in kelvin, times in seconds, rotation in rad s^-1, gravity in m s^-2,
  !! pressure in pascals and the source SI gas, heat and radiation constants.
  subroutine suscst(prcorioi, prplrg, ydcst)
    real(real64), intent(in) :: prcorioi, prplrg
    type(tcst), intent(inout) :: ydcst
    real(real64), volatile :: pi, light, planck, boltzmann, avogadro, day, year, sidereal_day, gas, gas_dry, gas_water
    real(real64), volatile :: first, second, third, fourth
    integer(int64) :: rotation_bits, gravity_bits
    rotation_bits = transfer(prcorioi, 0_int64)
    gravity_bits = transfer(prplrg, 0_int64)
    if (iand(rotation_bits, int(z'7fffffffffffffff', int64)) /= 0_int64 .and. &
        rotation_bits /= int(z'3fe0000000000000', int64) .and. rotation_bits /= int(z'3ff0000000000000', int64) .and. &
        rotation_bits /= int(z'4000000000000000', int64)) call reject_contract()
    if (gravity_bits /= int(z'3fe0000000000000', int64) .and. gravity_bits /= int(z'3ff0000000000000', int64) .and. &
        gravity_bits /= int(z'4000000000000000', int64)) call reject_contract()
    pi = 3.141592653589793_real64
    light = 299792458.0_real64
    planck = 6.6260755e-34_real64
    boltzmann = 1.380658e-23_real64
    avogadro = 6.0221367e23_real64
    ydcst%rpi = pi
    day = 86400.0_real64
    if (prcorioi /= 0.0_real64) day = day*prcorioi
    ydcst%rday = day
    year = 365.25_real64*day
    year = year*2.0_real64
    year = year*pi
    year = year/6.283076_real64
    first = day/year
    first = 1.0_real64 + first
    sidereal_day = day/first
    if (prcorioi /= 0.0_real64) then
      first = 2.0_real64*pi
      ydcst%romega = first/sidereal_day
    else
      ydcst%romega = 0.0_real64
    end if
    ydcst%rg = 9.80665_real64*prplrg
    first = pi*pi
    first = first*first
    first = first*pi
    first = 2.0_real64*first
    second = boltzmann/planck
    third = second*second
    second = third*second
    first = first*second
    first = first*boltzmann
    second = light*light
    second = 15.0_real64*second
    ydcst%rsigma = first/second
    gas = avogadro*boltzmann
    ydcst%r = gas
    first = 1000.0_real64*gas
    gas_dry = first/28.9644_real64
    ydcst%rd = gas_dry
    first = 1000.0_real64*gas
    gas_water = first/18.0153_real64
    ydcst%rv = gas_water
    ydcst%rcpd = 3.5_real64*gas_dry
    ydcst%rcpv = 4.0_real64*gas_water
    first = gas_water/gas_dry
    ydcst%retv = first - 1.0_real64
    ydcst%rtt = 273.16_real64
    ydcst%rlvtt = 2500800.0_real64
    ydcst%rlstt = 2834500.0_real64
    first = 2834500.0_real64
    second = 2500800.0_real64
    ydcst%rlmlt = first - second
    ydcst%ratm = 100000.0_real64
  end subroutine suscst
end module suscst_mod

module susthf_mod
  use iso_fortran_env, only: real64
  use yos_cst, only: tcst
  use yos_thf, only: rhoh2o, rvtmp2, r2es, r3les, r3ies, r4les, r4ies, r5les, r5ies
  implicit none
  private
  public :: susthf
contains
  !> Derive the owned water and ice saturation-pressure coefficients.
  !!
  !! YDCST supplies pressure in pascals, gas constants in J kg^-1 K^-1 and
  !! triple-point temperature in kelvin. The owned YOS_THF density has units
  !! kg m^-3; R4 and the temperature differences use kelvin.
  subroutine susthf(ydcst)
    type(tcst), intent(in) :: ydcst
    real(real64) :: value
    rvtmp2 = 0.0_real64
    rhoh2o = ydcst%ratm/100.0_real64
    value = 611.21_real64*ydcst%rd
    r2es = value/ydcst%rv
    r3les = 17.502_real64
    r3ies = 22.587_real64
    r4les = 32.19_real64
    r4ies = -0.7_real64
    value = ydcst%rtt - r4les
    r5les = r3les*value
    value = ydcst%rtt - r4ies
    r5ies = r3ies*value
  end subroutine susthf
end module susthf_mod

module suvexcs_mod
  use iso_fortran_env, only: int32, real64
  use yos_excs
  implicit none
  private
  public :: suvexcs
contains
  !> Set the owned surface stability table using the frozen Newton iterations.
  !!
  !! All quantities are dimensionless. Each Richardson-number target starts
  !! from the preceding table result. Targets below one half use five updates;
  !! other targets use three. No spline calculation belongs to this routine.
  subroutine suvexcs()
    real(real64) :: target, guess, delta, above, below, value, denominator, residual_above, residual_below, numerator
    integer(int32) :: point, iteration, iterations
    rimax = 10.0_real64
    dritbl = 0.1_real64
    rcheta = 5.0_real64
    rchetb = 4.0_real64
    rchbhdl = 5.0_real64
    rchba = 1.0_real64
    rchbb = 0.6666666666666666_real64
    rchbc = 5.0_real64
    rchbd = 0.35_real64
    rchb23a = 0.6666666666666666_real64
    rchbbcd = 9.523809523809524_real64
    rchbcd = 14.285714285714286_real64
    rcdhalf = 16.0_real64
    rcdhpi2 = 1.5707963267948966_real64
    ritbl(1) = 0.0_real64
    do point = 1, 100
      target = real(point, real64)*dritbl
      guess = ritbl(point)
      if (target < 0.5_real64) then
        iterations = 5
      else
        iterations = 3
      end if
      do iteration = 1, iterations
        delta = guess + 1.0_real64
        delta = delta*0.001_real64
        above = guess + delta
        below = guess - delta
        value = 4.0_real64*above
        value = 1.0_real64 + value
        value = value*value
        value = above*value
        denominator = 5.0_real64*above
        denominator = 1.0_real64 + denominator
        denominator = denominator*denominator
        value = value/denominator
        residual_above = target - value
        value = 4.0_real64*below
        value = 1.0_real64 + value
        value = value*value
        value = below*value
        denominator = 5.0_real64*below
        denominator = 1.0_real64 + denominator
        denominator = denominator*denominator
        value = value/denominator
        residual_below = target - value
        numerator = residual_above + residual_below
        numerator = delta*numerator
        denominator = residual_above - residual_below
        value = numerator/denominator
        guess = guess - value
      end do
      ritbl(point + 1) = guess
    end do
    rlpbb = 5.0_real64
    rlpcc = 5.0_real64
    rlpdd = 5.0_real64
  end subroutine suvexcs
end module suvexcs_mod

module susflake_mod
  use iso_fortran_env, only: int32, real64
  use yos_flake, only: tflake, ropticpar_medium
  implicit none
  private
  public :: susflake, optical_constructor_preimage
  !> Owned nonphysical preimage for compiler padding in the optical temporary.
  integer(int32), save :: optical_constructor_preimage = 0_int32
contains
  !> Set the lake coefficients and five native optical-band records.
  !!
  !! LD_LEFLAKE selects the lake model. YDFLAKE receives the source material
  !! constants: kelvin, metres, seconds, kilograms and joules form SI units.
  !! Optical fractions are dimensionless and extinction uses m^-1. The whole
  !! native temporary receives an owned representation preimage before every
  !! physical member is set. The compiler determines its layout and padding.
  !! The final caller padding is retained because each named member is stored.
  subroutine susflake(ld_leflake, ydflake)
    logical(int32), intent(in) :: ld_leflake
    type(tflake), intent(inout) :: ydflake
    type(ropticpar_medium), volatile :: optic
    integer(int32) :: representation(storage_size(optic)/storage_size(0_int32))
    representation = optical_constructor_preimage
    optic = transfer(representation, optic)
    ydflake%rc_cbl_1 = 0.17_real64
    ydflake%rc_cbl_2 = 1.0_real64
    ydflake%rc_sbl_zm_n = 0.5_real64
    ydflake%rc_sbl_zm_s = 10.0_real64
    ydflake%rc_sbl_zm_i = 20.0_real64
    ydflake%rc_relax_h = 0.03_real64
    ydflake%rc_relax_c = 0.03_real64
    ydflake%rc_t_min = 0.5_real64
    ydflake%rc_t_max = 0.8_real64
    ydflake%rphi_t_pr0_1 = 13.333333333333334_real64
    ydflake%rphi_t_pr0_2 = 6.666666666666667_real64
    ydflake%rc_tt_1 = 0.6111111111111112_real64
    ydflake%rc_tt_2 = 0.15555555555555556_real64
    ydflake%rc_b1 = 0.6666666666666666_real64
    ydflake%rc_b2 = 0.6_real64
    ydflake%rc_s_lin = 0.5_real64
    ydflake%rphi_s_pr0_lin = 1.0_real64
    ydflake%rc_i_lin = 0.5_real64
    ydflake%rphi_i_pr0_lin = 1.0_real64
    ydflake%rphi_i_pr1_lin = 1.0_real64
    ydflake%rphi_i_ast_mr = 2.0_real64
    ydflake%rc_i_mr = 0.08333333333333333_real64
    ydflake%rh_ice_max = 3.0_real64
    ydflake%rh_snow_min_flk = 1e-05_real64
    ydflake%rh_ice_min_flk = 1e-09_real64
    ydflake%rh_ml_min_flk = 0.01_real64
    ydflake%rh_ml_max_flk = 1000.0_real64
    ydflake%ru_star_min_flk = 1e-06_real64
    ydflake%rc_small_flk = 2.220446049250313e-14_real64
    ydflake%rtpl_grav = 9.81_real64
    ydflake%rtpl_t_r = 277.13_real64
    ydflake%rtpl_t_f = 273.15_real64
    ydflake%rtpl_a_t = 1.6509e-05_real64
    ydflake%rtpl_rho_w_r = 1000.0_real64
    ydflake%rtpl_rho_i = 910.0_real64
    ydflake%rtpl_l_f = 330000.0_real64
    ydflake%rtpl_c_w = 4200.0_real64
    ydflake%rtpl_c_i = 2100.0_real64
    ydflake%rtpl_kappa_w = 0.546_real64
    ydflake%rtpl_kappa_i = 2.29_real64
    ydflake%rtpsf_l_evap = 2501000.0_real64
    optic%nband_optic = 1
    optic%rfrac_optic = [1.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64]
    optic%rextincoef_optic = [3.0_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, &
                              10000000000.0_real64]
    ydflake%ropticpar_water_ref = optic
    optic%nband_optic = 2
    optic%rfrac_optic = [0.1_real64, 0.9_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64]
    optic%rextincoef_optic = [2.0_real64, 0.2_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, &
                              10000000000.0_real64]
    ydflake%ropticpar_water_trans = optic
    optic%nband_optic = 1
    optic%rfrac_optic = [1.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64]
    optic%rextincoef_optic = [17.1_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, &
                              10000000000.0_real64]
    ydflake%ropticpar_whiteice_ref = optic
    optic%nband_optic = 1
    optic%rfrac_optic = [1.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64]
    optic%rextincoef_optic = [8.4_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, &
                              10000000000.0_real64]
    ydflake%ropticpar_blueice_ref = optic
    optic%nband_optic = 1
    optic%rfrac_optic = [1.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64]
    optic%rextincoef_optic = [10000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, 10000000000.0_real64, &
                              10000000000.0_real64, 10000000000.0_real64]
    ydflake%ropticpar_ice_opaque = optic
    ydflake%leflake = ld_leflake
  end subroutine susflake
end module susflake_mod
