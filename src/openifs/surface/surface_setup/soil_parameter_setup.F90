module sussoil_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_get_rounding_mode, ieee_round_type, ieee_nearest, operator(/=)
  use yos_dim, only: tdim
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use cptave_mod, only: cptave
  implicit none
  private
  public :: sussoil
  interface
    function selected_power(value, power) bind(c, name="md2asm_pow_original_rounding_candidate") result(answer)
      import c_double
      real(c_double), value :: value, power
      real(c_double) :: answer
    end function selected_power
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
  real(real64), parameter :: c_zero = 0.0_real64
  real(real64), parameter :: c_one = 1.0_real64
  real(real64), parameter :: c_two = 2.0_real64
  real(real64), parameter :: c_half = 0.5_real64
  real(real64), parameter :: c_fifteen = 15.0_real64
  real(real64), parameter :: c_ten = 10.0_real64
  real(real64), parameter :: c_hundred = 100.0_real64
  real(real64), parameter :: c_thousand = 1000.0_real64
  real(real64), parameter :: c_grav = 9.8_real64
  real(real64), parameter :: c_minus15 = -15.0_real64
  real(real64), parameter :: c_minus10 = -0.1_real64
  real(real64), parameter :: c_minus33 = -0.33_real64
  real(real64), parameter :: c_maxfac = 0.999_real64
  real(real64), parameter :: c_minfac = 1.001_real64
  real(real64), parameter :: c_one6 = 1.6_real64
  real(real64), parameter :: c_rhosm = 2700.0_real64
  real(real64), parameter :: c_lambdaq = 7.7_real64
  real(real64), parameter :: c_lambdao = 2.0_real64
  real(real64), parameter :: c_q = 0.4_real64
  real(real64), parameter :: c_rcgdry = 1600000.0_real64
  real(real64), parameter :: c_therma = 0.135_real64
  real(real64), parameter :: c_thermb = 64.7_real64
  real(real64), parameter :: c_thermc = 0.947_real64
  real(real64), parameter :: c_thermc_sp = 0.9470000267028809_real64
  real(real64), parameter :: c_rgh2o = 4180000.0_real64
  real(real64), parameter :: c_three = 3.0_real64
  real(real64), parameter :: c_ice_delta = 1.7_real64
  real(real64), parameter :: c_secs = 3600.0_real64
  real(real64), parameter :: c_eps = 2.220446049250313e-14_real64
  real(real64), parameter :: soil_alpha(7) = [ &
                             3.83_real64, &
                             3.14_real64, &
                             0.83_real64, &
                             3.67_real64, &
                             2.65_real64, &
                             1.3_real64, &
                             3.14_real64]
  real(real64), parameter :: soil_ksat(7) = [ &
                             6.94e-06_real64, &
                             1.16e-06_real64, &
                             2.63e-07_real64, &
                             2.87e-06_real64, &
                             1.74e-06_real64, &
                             9.3e-07_real64, &
                             1.16e-06_real64]
  real(real64), parameter :: soil_n(7) = [ &
                             1.3774_real64, &
                             1.1804_real64, &
                             1.2539_real64, &
                             1.1012_real64, &
                             1.1033_real64, &
                             1.2039_real64, &
                             1.1804_real64]
  real(real64), parameter :: soil_lambda(7) = [ &
                             1.25_real64, &
                             -2.3421_real64, &
                             -0.5884_real64, &
                             -1.9772_real64, &
                             2.5_real64, &
                             0.4_real64, &
                             -2.3421_real64]
  real(real64), parameter :: soil_sat(7) = [ &
                             0.403_real64, &
                             0.439_real64, &
                             0.43_real64, &
                             0.52_real64, &
                             0.614_real64, &
                             0.766_real64, &
                             0.439_real64]
  real(real64), parameter :: soil_res(7) = [ &
                             0.025_real64, &
                             0.01_real64, &
                             0.01_real64, &
                             0.01_real64, &
                             0.01_real64, &
                             0.01_real64, &
                             0.01_real64]
  real(real64), parameter :: soil_depth(4) = [ &
                             0.07_real64, &
                             0.21_real64, &
                             0.72_real64, &
                             1.89_real64]
  real(real64), parameter :: soil_snowdest(5) = [ &
                             0.112_real64, &
                             0.152_real64, &
                             0.192_real64, &
                             0.288_real64, &
                             0.488_real64]
  real(real64), parameter :: soil_snowmin(5) = [ &
                             0.075_real64, &
                             0.05_real64, &
                             0.05_real64, &
                             0.05_real64, &
                             0.05_real64]
  real(real64), parameter :: soil_snowmax(5) = [ &
                             0.075_real64, &
                             0.1_real64, &
                             0.2_real64, &
                             -1.0_real64, &
                             0.15_real64]
  real(real64), parameter :: soil_snowmingl(5) = [ &
                             0.5_real64, &
                             0.5_real64, &
                             0.5_real64, &
                             0.5_real64, &
                             0.5_real64]
  real(real64), parameter :: soil_snowmaxgl(5) = [ &
                             0.5_real64, &
                             0.5_real64, &
                             0.5_real64, &
                             0.5_real64, &
                             -1.0_real64]
contains
  !> Set soil water, heat and snow parameters in a native TSOIL value.
  !!
  !! PTHRFRTI and PRALFMINPSN are fractions from zero to one. The four logical
  !! controls select the declared soil and snow options; PNSNMLWS is 1, 2 or 3.
  !! YDDIM selects four soil layers and five snow layers. YDCST supplies RTT
  !! in kelvin and the dimensionless value RPI. Optional PRCIMIN is ice depth
  !! in metres. Its absent value is the frozen 0.02 m source default.
  !! YDSOIL owns all 25 allocatable tables. Fresh tables receive their declared
  !! bounds. Matching allocated tables are reused when the private result is
  !! committed. Source-unwritten switches retain their incoming values.
  subroutine sussoil(pthrfrti, ld_levgen, ld_lessro, ld_lesn09, ld_lesnml, pnsnmlws, &
                     yddim, ydcst, ydsoil, pralfminpsn, prcimin)
    real(real64), intent(in) :: pthrfrti, pralfminpsn
    logical(int32), intent(in) :: ld_levgen, ld_lessro, ld_lesn09, ld_lesnml
    integer(int32), intent(in) :: pnsnmlws
    type(tdim), intent(in) :: yddim
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(inout) :: ydsoil
    real(real64), intent(in), optional :: prcimin
    type(tsoil) :: work
 real(real64) :: texture_sat(3), texture_cap(3), texture_wilt(3), texture_conductivity(3), texture_potential(3), texture_exponent(3)
    real(real64) :: pressure_factor,field_pressure,wilting_pressure,alpha,conductivity,n,lambda,saturation,residual,m,gap,signed_gap
    real(real64) :: value, term, power_value, effective, solid_conductivity, solid_fraction, density, numerator, denominator
    real(real64), volatile :: smallest, subnormal
    integer(int32) :: texture
    type(ieee_round_type) :: rounding
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    smallest = tiny(1.0_real64)
    subnormal = smallest*0.5_real64
    if (subnormal == 0.0_real64) call reject_contract()
    if (yddim%ncss /= 4 .or. yddim%ncsnec /= 5) call reject_contract()
    if (pnsnmlws < 1 .or. pnsnmlws > 3) call reject_contract()
    if (.not. in_range(pthrfrti, c_zero, c_one) .or. .not. in_range(pralfminpsn, c_zero, c_one)) call reject_contract()
  if (.not.in_range(ydcst%rtt,200.0_real64,350.0_real64) .or. .not.in_range(ydcst%rpi,3.0_real64,4.0_real64)) call reject_contract()
    if (present(prcimin)) then
      if (.not. in_range(prcimin, c_zero, c_one)) call reject_contract()
    end if
    work = ydsoil
    call ensure_array(work%rcwpsism, 0, 7)
    call ensure_array(work%rmvgalpha, 0, 7)
    call ensure_array(work%rwconsm, 0, 7)
    call ensure_array(work%rmfacm, 0, 7)
    call ensure_array(work%rnfacm, 0, 7)
    call ensure_array(work%rlambdam, 0, 7)
    call ensure_array(work%rwsatm, 0, 7)
    call ensure_array(work%rwcapm, 0, 7)
    call ensure_array(work%rwpwpm, 0, 7)
    call ensure_array(work%rwrestm, 0, 7)
    call ensure_array(work%rdmaxm, 0, 7)
    call ensure_array(work%rdminm, 0, 7)
    call ensure_array(work%rqwevapm, 0, 7)
    call ensure_array(work%rqwsbcrm, 0, 7)
    call ensure_array(work%rlambdadrym, 1, 7)
    call ensure_array(work%rlamsat1m, 1, 7)
    call ensure_array(work%rrcsoilm, 1, 7)
    call ensure_array(work%rdat, 1, 4)
    call ensure_array(work%rdaw, 1, 4)
    call ensure_array(work%rdai, 1, 4)
    call ensure_array(work%rsndtdestc_ml, 1, 5)
    call ensure_array(work%rlevsnmin, 1, 5)
    call ensure_array(work%rlevsnmax, 1, 5)
    call ensure_array(work%rlevsnmin_gl, 1, 5)
    call ensure_array(work%rlevsnmax_gl, 1, 5)
    work%rlice = 0.3_real64
    work%rgh2o = 4180000.0_real64
    work%rwlmax = 0.2_real64
    work%rpsfr = 2.0_real64
    work%rlambdaice = 2.2_real64
    work%rlambdawat = 0.57_real64
    work%rkerst1 = 0.1_real64
    work%rkerst2 = 1.0_real64
    work%rkerst3 = 1.0_real64
    work%rsimp = 1.0_real64
    work%rdarsice = 1.5_real64
    work%rdansice = 1.5_real64
    work%rrcsice = 1884000.0_real64
    work%rcondsice = 2.03_real64
    work%rcimin = 0.02_real64
    work%rsrdep = 0.5_real64
    work%rsigormin = 100.0_real64
    work%rsigormax = 1000.0_real64
    work%rhoice = 920.0_real64
    work%rlamice = 2.22_real64
    work%rhoci = 2050000.0_real64
    work%ralfminsn = 0.5_real64
    work%ralfmaxsn = 0.85_real64
    work%rhomaxsn_new = 500.0_real64
    work%rhomaxsn = 300.0_real64
    work%rsnper = 1000.0_real64
    work%rhominsn = 100.0_real64
    work%rtauf = 0.24_real64
    work%rtaua = 0.008_real64
    work%rfrtiny = 1e-07_real64
    work%ralamsn = 1.88_real64
    work%rdsnmax = 1.0_real64
    work%rlwcswea = 200.0_real64
    work%rlwcsweb = 0.03_real64
    work%rlwcswec = 0.1_real64
    work%rtempamp = 4.0_real64
    work%rhominsna = 109.0_real64
    work%rhominsnb = 6.0_real64
    work%rhominsnc = 26.0_real64
    work%rhominsnd = 50.0_real64
    work%rsndtovera = 37000000.0_real64
    work%rsndtoverb = 0.081_real64
    work%rsndtoverc = 0.018_real64
    work%rsndamob = 1.25_real64
    work%rsndmob = 295.0_real64
    work%rsndaw = 2.868_real64
    work%rsndbw = 0.085_real64
    work%rsndkv = 1.25_real64
    work%rsndatauw = 10.0_real64
    work%rsndbtauw = 3.25_real64
    work%rsndwcompmax = 350.0_real64
    work%rsndtdesta = 2.8e-06_real64
    work%rsndtdestb = 0.042_real64
    work%rsndtdestc = 460.0_real64
    work%rsndtdestroi = 150.0_real64
    work%ssag1 = 0.00016_real64
    work%ssag2 = 0.0_real64
    work%ssag3 = 1.1e-13_real64
    work%ssagsnsmax = 0.00279600010253489_real64
    work%ssasnextmin = 5.0_real64
    work%ssasnextmax = 50.0_real64
    work%ssasnextcnst = 0.0038_real64
    work%snhcondav = -0.06023_real64
    work%snhcondbv = 2.5425_real64
    work%snhcondcv = 289.99_real64
    work%levgen = ld_levgen
    work%lessro = ld_lessro
    work%lesn09 = ld_lesn09
    work%lesnml = ld_lesnml
    work%nsnmlws = pnsnmlws
    work%nsoty = 7
    work%nlevsn = 5
    value = c_fifteen
    if (ld_lesn09) value = c_ten
    work%rqsncr = c_one/value
    call cptave(texture_sat, texture_cap, texture_wilt, texture_conductivity, texture_potential, texture_exponent)
    work%rdat = soil_depth
    work%rdaw = soil_depth
    work%rdai = soil_depth
    work%rcwpsism(0) = c_zero
    work%rmvgalpha(0) = c_zero
    work%rwconsm(0) = c_zero
    work%rmfacm(0) = c_zero
    work%rnfacm(0) = c_zero
    work%rlambdam(0) = c_zero
    work%rwsatm(0) = c_zero
    work%rwcapm(0) = c_zero
    work%rwpwpm(0) = c_zero
    work%rwrestm(0) = c_zero
    work%rdmaxm(0) = c_zero
    work%rdminm(0) = c_zero
    work%rqwevapm(0) = c_zero
    work%rqwsbcrm(0) = c_zero
    pressure_factor = c_hundred/c_grav
    wilting_pressure = c_minus15*pressure_factor
    field_pressure = c_minus10
    if (.not. ld_levgen) field_pressure = c_minus33
    field_pressure = field_pressure*pressure_factor
    do texture = 1, 7
      alpha = soil_alpha(texture)
      conductivity = soil_ksat(texture)
      n = soil_n(texture)
      lambda = soil_lambda(texture)
      saturation = soil_sat(texture)
      residual = soil_res(texture)
      work%rmvgalpha(texture) = alpha
      work%rwconsm(texture) = conductivity
      work%rnfacm(texture) = n
      work%rlambdam(texture) = lambda
      work%rwsatm(texture) = saturation
      work%rwrestm(texture) = residual
      work%rcwpsism(texture) = c_one/alpha
      value = c_one/n
      m = c_one - value
      work%rmfacm(texture) = m
      gap = saturation - residual
      value = alpha*field_pressure
      value = abs(value)
      value = selected_power(value, n)
      value = c_one + value
      value = c_one/value
      value = selected_power(value, m)
      value = gap*value
      work%rwcapm(texture) = residual + value
      value = alpha*wilting_pressure
      value = abs(value)
      value = selected_power(value, n)
      value = c_one + value
      value = c_one/value
      value = selected_power(value, m)
      value = gap*value
      work%rwpwpm(texture) = residual + value
      signed_gap = sign(max(abs(gap), c_eps), gap)
      value = c_maxfac*saturation
      value = value - residual
      effective = value/signed_gap
      work%rdmaxm(texture) = soil_diffusivity(effective, m, lambda, alpha, conductivity, signed_gap)
      value = c_minfac*residual
      value = value - residual
      effective = value/signed_gap
      work%rdminm(texture) = soil_diffusivity(effective, m, lambda, alpha, conductivity, signed_gap)
      value = work%rwcapm(texture) - work%rwpwpm(texture)
      work%rqwevapm(texture) = c_one/value
      value = c_one6*work%rwcapm(texture)
      work%rqwsbcrm(texture) = ydcst%rpi/value
    end do
    work%rwb = texture_exponent(2)
    work%rwcons = texture_conductivity(2)
    work%rcwpsis = texture_potential(2)
    work%rwsat = texture_sat(2)
    work%rwcap = texture_cap(2)
    work%rwpwp = texture_wilt(2)
    value = work%rwcap - work%rwpwp
    work%rqwevap = c_one/value
    value = work%rwcap*c_one6
    work%rqwsbcr = ydcst%rpi/value
    solid_conductivity = selected_power(c_lambdaq, c_q)
    value = c_one - c_q
    term = selected_power(c_lambdao, value)
    solid_conductivity = solid_conductivity*term
    do texture = 1, 7
      solid_fraction = c_one - work%rwsatm(texture)
      density = solid_fraction*c_rhosm
      value = c_therma*density
      numerator = value + c_thermb
      value = c_thermc_sp*density
      denominator = c_rhosm - value
      work%rlambdadrym(texture) = numerator/denominator
      work%rlamsat1m(texture) = selected_power(solid_conductivity, solid_fraction)
      value = solid_fraction*c_rcgdry
      term = work%rwcapm(texture)*c_rgh2o
      work%rrcsoilm(texture) = value + term
    end do
    solid_fraction = c_one - work%rwsat
    density = solid_fraction*c_rhosm
    value = c_therma*density
    numerator = value + c_thermb
    value = c_thermc*density
    denominator = c_rhosm - value
    work%rlambdadry = numerator/denominator
    work%rlamsat1 = selected_power(solid_conductivity, solid_fraction)
    value = solid_fraction*c_rcgdry
    term = work%rwcap*c_rgh2o
    work%rrcsoil = value + term
    work%rtf1 = ydcst%rtt + c_one
    work%rtf2 = ydcst%rtt - c_three
    value = work%rtf1 + work%rtf2
    work%rtf3 = c_half*value
    value = work%rtf1 - work%rtf2
    work%rtf4 = ydcst%rpi/value
    work%rtfreezsice = ydcst%rtt - c_ice_delta
    work%rtmeltsice = ydcst%rtt
    work%rdfsice = work%rcondsice/work%rrcsice
    if (present(prcimin)) work%rcimin = prcimin
    work%ralfminpsn = pralfminpsn
    work%rsfresh = c_one/c_secs
    work%rfrsmall = c_ten*work%rfrtiny
    work%snhcondpov = c_thousand*c_hundred
    work%rthrfrti = pthrfrti
    work%rsndtdestc_ml = soil_snowdest
    work%rlevsnmin = soil_snowmin
    work%rlevsnmax = soil_snowmax
    work%rlevsnmin_gl = soil_snowmingl
    work%rlevsnmax_gl = soil_snowmaxgl
    work%leskti5 = .false.
    work%leskti8 = .false.
    work%lesoilcond = .true.
    work%lerolake = .false.
    work%lewbsoilfix = .true.
    work%lewbcheck = .false.
    work%lewbcheckabort = .false.
    work%lesncheck = .false.
    work%lesncheckabort = .false.
    work%lesnwbcon = .false.
    ydsoil = work
  end subroutine sussoil
  !> Evaluate the frozen water diffusivity formula in square metres per second.
  real(real64) function soil_diffusivity(effective, m, lambda, alpha, conductivity, gap) result(answer)
    real(real64), intent(in) :: effective, m, lambda, alpha, conductivity, gap
    real(real64) :: inverse, exponent, first_power, complement, positive_power, negative_power, value, numerator, denominator
    inverse = c_one/m
    exponent = lambda - inverse
    first_power = selected_power(effective, exponent)
    complement = selected_power(effective, inverse)
    complement = c_one - complement
    positive_power = selected_power(complement, m)
    negative_power = selected_power(complement, -m)
    value = positive_power + negative_power
    value = value - c_two
    value = first_power*value
    numerator = c_one - m
    numerator = numerator*conductivity
    denominator = alpha*m
    denominator = denominator*gap
    numerator = numerator/denominator
    answer = numerator*value
  end function soil_diffusivity
  !> Allocate one table with its source bounds, or check an existing table.
  subroutine ensure_array(array, lower, upper)
    real(real64), allocatable, intent(inout) :: array(:)
    integer, intent(in) :: lower, upper
    integer :: status
    if (allocated(array)) then
      if (lbound(array, 1) /= lower .or. ubound(array, 1) /= upper) call reject_contract()
    else
      allocate (array(lower:upper), stat=status)
      if (status /= 0) call reject_contract()
    end if
  end subroutine ensure_array
  !> Check a physical interval without comparing a nonfinite value.
  elemental pure logical function in_range(value, low, high)
    real(real64), intent(in) :: value, low, high
    integer(int64) :: bits
    bits = transfer(value, 0_int64)
    if (iand(shiftr(bits, 52), 2047_int64) == 2047_int64) then
      in_range = .false.
    else
      in_range = value >= low .and. value <= high
    end if
  end function in_range
end module sussoil_mod
