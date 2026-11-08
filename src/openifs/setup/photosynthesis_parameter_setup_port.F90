!> Ordered one-cell leaf carbon assimilation from the existing generated calculation.
!! Input order is PGC,PCSP,PDS,PDMAX,PIA,PGAMMT,PFZERO,PGMEST,PEPSO,PAMMAX.
!! Concentrations use kg CO2/kg air; conductances use m/s; PIA is the supplied light flux.
!! Output order is net assimilation, gross assimilation, respiration and conductance.
module photosynthesis_parameter_numerics
  use, intrinsic :: iso_fortran_env, only: int64, real64
  use, intrinsic :: iso_c_binding, only: c_double
  implicit none
  private
  public :: carbon_assimilation_one_cell, public_exponential, public_power, public_logarithm, public_cosine
  interface
    function public_exponential(x) bind(C, name="exp") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_power(x, y) bind(C, name="pow") result(value)
      import c_double
      real(c_double), value :: x, y
      real(c_double) :: value
    end function
    function public_logarithm(x) bind(C, name="log") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_cosine(x) bind(C, name="cos") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  subroutine carbon_assimilation_one_cell(input, coefficients, output) bind(C, name="md2asm_one_cell_carbon_assimilation_fortran")
    !! Buffers contain 10,4 and4 FP64 values, are independent, and remain caller-owned.
    !! Inputs obey the finite positive selected COTWO domain in the solver contract.
    real(c_double), intent(in) :: input(10), coefficients(4)
    real(c_double), intent(out) :: output(4)
    real(real64), parameter :: threshold = transfer(int(z'3d19000000000000', int64), 0.0_real64)
    real(real64) :: csp, fmin, drap, fraction, ci, cmin, amin, eps, am, rd, pan, pag
    real(real64) :: gsc, gs, evap, agr, ag, denominator, reciprocal, a, b, c, d, value
    integer :: iteration
    evap = 0.0_real64
    a = input(6) + 1.0e-6_real64
    csp = max(input(2), a)
    a = input(1) + input(8)
    a = input(1)/a
    a = min(a, input(7))
    fmin = max(a, 1.0e-7_real64)
    a = input(3)/input(4)
    drap = min(1.0_real64, a)
    a = 1.0_real64 - drap
    a = input(7)*a
    b = fmin*drap
    fraction = a + b
    a = 1.0_real64 - fraction
    a = a*input(6)
    a = a/csp
    a = fraction + a
    a = csp*a
    a = max(a, input(6))
    ci = min(a, csp)
    a = input(1)*csp
    b = input(8)*input(6)
    a = a + b
    b = input(8) + input(1)
    cmin = a/b
    a = cmin - input(6)
    amin = input(8)*a
    a = ci - input(6)
    a = input(9)*a
    b = 2.0_real64*input(6)
    b = ci + b
    eps = a/b
    a = ci - input(6)
    a = input(8)*a
    a = -a
    a = a/input(10)
    value = public_exponential(a)
    a = 1.0_real64 - value
    a = input(10)*a
    am = max(a, amin)
    rd = am*coefficients(4)
    a = am + rd
    denominator = sign(max(abs(a), threshold), a)
    a = -eps
    a = a*input(5)
    a = a/denominator
    value = public_exponential(a)
    a = 1.0_real64 - value
    b = am + rd
    pag = b*a
    a = pag - rd
    b = -rd
    pan = max(b, a)
    output(1) = pan
    output(2) = pag
    output(3) = rd
    do iteration = 1, 3
      a = pan + rd
      agr = a/denominator
      a = input(3)/input(4)
      drap = min(1.0_real64, a)
      a = amin*drap
      a = a*agr
      a = pan - a
      b = 1.0_real64 - agr
      b = rd*b
      ag = a + b
      a = input(2) - ci
      reciprocal = 1.0_real64/a
      a = ag*reciprocal
      gsc = max(a, coefficients(3))
      a = input(2) + ci
      a = a/2.0_real64
      a = a*reciprocal
      b = coefficients(1)*evap
      a = b*a
      gsc = gsc + a
      gs = coefficients(2)*gsc
      evap = gs*input(3)
    end do
    a = coefficients(2)*gsc
    output(4) = a + input(1)
  end subroutine
end module photosynthesis_parameter_numerics

!> Typed photosynthesis setup ported from the existing generated field stages.
!! Named parameters retain every source literal bit, including promoted FP32 inputs.
!! The original surface record modules supply type definitions only.
module sucotwo_mod
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use yos_veg, only: TVEG
  use yos_cst, only: TCST
  use yos_ags, only: TAGS
  use photosynthesis_parameter_numerics
  implicit none
  private
  public :: sucotwo
  real(real64), parameter :: cp_one = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_zero = transfer(int(z'0000000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_two = transfer(int(z'4000000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_half = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_three = transfer(int(z'4008000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_quarter = transfer(int(z'3fd0000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_one_tenth = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
  real(real64), parameter :: cp_three_tenths = transfer(int(z'3fd3333333333333', int64), 0.0_real64)
  real(real64), parameter :: cp_twentyfive = transfer(int(z'4039000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_thousand = transfer(int(z'408f400000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_CO2_massfrac = transfer(int(z'3f3a36e2eb1c432d', int64), 0.0_real64)
  real(real64), parameter :: cp_CO2_molmass = transfer(int(z'4046016872b020c5', int64), 0.0_real64)
  real(real64), parameter :: cp_air_molmass = transfer(int(z'403cf851eb851eb8', int64), 0.0_real64)
  real(real64), parameter :: cp_gauss_tolerance = transfer(int(z'3d20e374a4f8e0b4', int64), 0.0_real64)
  real(real64), parameter :: cp_gauss_threehalf = transfer(int(z'400c000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RMAIR = transfer(int(z'3f9daa4fca42aed1', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RMCO2 = transfer(int(z'3fa6889c1b54195d', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RMC = transfer(int(z'3f889374bc6a7efa', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RDMAX_AGS = transfer(int(z'3fa70a3d70a3d70a', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RPARCF = transfer(int(z'3fdeb851eb851eb8', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RRACCF = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RPCCO2 = transfer(int(z'3fd999999999999a', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RIAOPT = transfer(int(z'407f400000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RDSPOPT = transfer(int(z'0000000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RXGT = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RDIFRACF = transfer(int(z'3fd010624dd2f1aa', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RXBOMEGA = transfer(int(z'3fee3779b421045d', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RRDCF = transfer(int(z'3fbc71c53f39d1b3', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RAMMIN = transfer(int(z'3ddb7cdfd9d7bdbb', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RCONDCTMIN = transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RCONDSTMIN = transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RANFMINIT = transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RAIRTOH2O = transfer(int(z'3ff9b22d0e560419', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RCO2TOH2O = transfer(int(z'3ff999999999999a', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RAW = transfer(int(z'4012cccccccccccd', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RASW = transfer(int(z'4006666666666666', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RBW = transfer(int(z'401c000000000000', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RDMAXN = transfer(int(z'3f9eb851eb851eb8', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RDMAXX = transfer(int(z'3fd3333333333333', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RRESPFACTOR_NIT = transfer(int(z'3e7f237594c664ee', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RCNS_NIT = transfer(int(z'3fe999999999999a', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RCA_1X_CO2_NIT = transfer(int(z'3fd851eb851eb852', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RCA_2X_CO2_NIT = transfer(int(z'3fe0a3d70a3d70a4', int64), 0.0_real64)
  real(real64), parameter :: cp_scalar_RCC_NIT = transfer(int(z'3fe81f81a5870da6', int64), 0.0_real64)
  real(real64), parameter :: table_RVCH4S(3) = [ &
                             transfer(int(z'3f7148fd9fd36f7e', int64), 0.0_real64), &
                             transfer(int(z'3f68a86d71f36263', int64), 0.0_real64), &
                             transfer(int(z'3f6ab4b72c5197a2', int64), 0.0_real64)]
  real(real64), parameter :: table_RVTOPT(21) = [ &
                             transfer(int(z'4041800000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4041800000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4041800000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64), &
                             transfer(int(z'4039000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVFZERO(21) = [ &
                             transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64), &
                             transfer(int(z'3feb333340000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVFZEROST(21) = [ &
                             transfer(int(z'3fe6666666666666', int64), 0.0_real64), &
                             transfer(int(z'3feb333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fe4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fe6666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fed70a3d70a3d71', int64), 0.0_real64), &
                             transfer(int(z'3fe999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3feeb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fe70a3d70a3d70a', int64), 0.0_real64), &
                             transfer(int(z'3feeb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64), &
                             transfer(int(z'3fee666666666666', int64), 0.0_real64)]
  real(real64), parameter :: table_RVEPSO(21) = [ &
                             transfer(int(z'3e490fa680000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e490fa680000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e490fa680000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64), &
                             transfer(int(z'3e4e6e0a40000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVGAMM(21) = [ &
                             transfer(int(z'3ed1e15c80000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3ed1e15c80000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3ed1e15c80000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64), &
                             transfer(int(z'3f11f5a0e0000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVQDGAMM(21) = [ &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff8000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVQDGMES(21) = [ &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVT1GMES(21) = [ &
                             transfer(int(z'402a000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'402a000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'402a000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64), &
                             transfer(int(z'4014000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVT2GMES(21) = [ &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64), &
                             transfer(int(z'4042000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVAMMAX(21) = [ &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ec27476ca61b882', int64), 0.0_real64), &
                             transfer(int(z'3ec92a737110e454', int64), 0.0_real64), &
                             transfer(int(z'3ec27476ca61b882', int64), 0.0_real64), &
                             transfer(int(z'3ec27476ca61b882', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ec92a737110e454', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64), &
                             transfer(int(z'3ec27476ca61b882', int64), 0.0_real64), &
                             transfer(int(z'3ec27476ca61b882', int64), 0.0_real64), &
                             transfer(int(z'3ebec0acd04f859c', int64), 0.0_real64)]
  real(real64), parameter :: table_RVQDAMMAX(21) = [ &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVT1AMMAX(21) = [ &
                             transfer(int(z'402a000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'402a000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'402a000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64), &
                             transfer(int(z'4020000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVT2AMMAX(21) = [ &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64), &
                             transfer(int(z'4043000000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVAH(21) = [ &
                             transfer(int(z'40154ac080000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40154ac080000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40154ac080000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64), &
                             transfer(int(z'40030c49c0000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVBH(21) = [ &
                             transfer(int(z'bfec92a300000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfec92a300000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfec92a300000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64), &
                             transfer(int(z'bfe38793e0000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVBSLAI(21) = [ &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3faeb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fc0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fd0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3faeb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64), &
                             transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fb47ae147ae147b', int64), 0.0_real64)]
  real(real64), parameter :: table_RVLAIMIN(21) = [ &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3ff0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3ff0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3ff0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff0000000000000', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64)]
  real(real64), parameter :: table_RVSEFOLD(21) = [ &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'4076d00000000000', int64), 0.0_real64), &
                             transfer(int(z'406cc00000000000', int64), 0.0_real64), &
                             transfer(int(z'406cc00000000000', int64), 0.0_real64), &
                             transfer(int(z'4076d00000000000', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'4076d00000000000', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                             transfer(int(z'4076d00000000000', int64), 0.0_real64), &
                             transfer(int(z'4076d00000000000', int64), 0.0_real64), &
                             transfer(int(z'4062c00000000000', int64), 0.0_real64)]
  real(real64), parameter :: table_RVGMES(21) = [ &
                             transfer(int(z'3f62d77318fc5048', int64), 0.0_real64), &
                             transfer(int(z'3f554c985f06f694', int64), 0.0_real64), &
                             transfer(int(z'3f554c985f06f694', int64), 0.0_real64), &
                             transfer(int(z'3f4a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f4a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f56f0068db8bac7', int64), 0.0_real64), &
                             transfer(int(z'3f5205bc01a36e2f', int64), 0.0_real64), &
                             transfer(int(z'3f62d77318fc5048', int64), 0.0_real64), &
                             transfer(int(z'3eb0c6f7a0b5ed8d', int64), 0.0_real64), &
                             transfer(int(z'3f60624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3f3a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3eb0c6f7a0b5ed8d', int64), 0.0_real64), &
                             transfer(int(z'3f40624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3eb0c6f7a0b5ed8d', int64), 0.0_real64), &
                             transfer(int(z'3eb0c6f7a0b5ed8d', int64), 0.0_real64), &
                             transfer(int(z'3f4d7dbf487fcb92', int64), 0.0_real64), &
                             transfer(int(z'3f5f212d77318fc5', int64), 0.0_real64), &
                             transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3f4a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64)]
  real(real64), parameter :: table_RVGC(21) = [ &
                             transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f23a92a30553261', int64), 0.0_real64), &
                             transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'3f30624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3e7ad7f29abcaf48', int64), 0.0_real64), &
                             transfer(int(z'3f30624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3f30624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3f30624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'3e7ad7f29abcaf48', int64), 0.0_real64), &
                             transfer(int(z'3f30624dd2f1a9fc', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64), &
                             transfer(int(z'3f23a92a30553261', int64), 0.0_real64), &
                             transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f30624dd2f1a9fc', int64), 0.0_real64)]
  real(real64), parameter :: table_RVDMAX(21) = [ &
                             transfer(int(z'3faa9fbe76c8b439', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3fbfbe76c8b43958', int64), 0.0_real64), &
                             transfer(int(z'3fbfbe76c8b43958', int64), 0.0_real64), &
                             transfer(int(z'3fbbe76c8b439581', int64), 0.0_real64), &
                             transfer(int(z'3fbfbe76c8b43958', int64), 0.0_real64), &
                             transfer(int(z'3faa9fbe76c8b439', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3faa9fbe76c8b439', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                             transfer(int(z'3fbfbe76c8b43958', int64), 0.0_real64), &
                             transfer(int(z'3fbfbe76c8b43958', int64), 0.0_real64), &
                             transfer(int(z'3fa999999999999a', int64), 0.0_real64)]
  real(real64), parameter :: table_RVF2I(21) = [ &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64), &
                             transfer(int(z'3fd3333333333333', int64), 0.0_real64)]
  real(real64), parameter :: table_RVCE(21) = [ &
                             transfer(int(z'401eb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'400e51eb851eb852', int64), 0.0_real64), &
                             transfer(int(z'40163d70a3d70a3d', int64), 0.0_real64), &
                             transfer(int(z'4013666666666666', int64), 0.0_real64), &
                             transfer(int(z'4013666666666666', int64), 0.0_real64), &
                             transfer(int(z'401351eb851eb852', int64), 0.0_real64), &
                             transfer(int(z'401351eb851eb852', int64), 0.0_real64), &
                             transfer(int(z'401eb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'40163d70a3d70a3d', int64), 0.0_real64), &
                             transfer(int(z'400e51eb851eb852', int64), 0.0_real64), &
                             transfer(int(z'40163d70a3d70a3d', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'40163d70a3d70a3d', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64), &
                             transfer(int(z'401eb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'40163d70a3d70a3d', int64), 0.0_real64), &
                             transfer(int(z'4013666666666666', int64), 0.0_real64), &
                             transfer(int(z'4013666666666666', int64), 0.0_real64), &
                             transfer(int(z'40163d70a3d70a3d', int64), 0.0_real64)]
  real(real64), parameter :: table_RVCF(21) = [ &
                             transfer(int(z'c01151eb851eb852', int64), 0.0_real64), &
                             transfer(int(z'4023ae147ae147ae', int64), 0.0_real64), &
                             transfer(int(z'401aeb851eb851ec', int64), 0.0_real64), &
                             transfer(int(z'bfceb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'bfceb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'40043d70a3d70a3d', int64), 0.0_real64), &
                             transfer(int(z'40043d70a3d70a3d', int64), 0.0_real64), &
                             transfer(int(z'c01151eb851eb852', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'401aeb851eb851ec', int64), 0.0_real64), &
                             transfer(int(z'4023ae147ae147ae', int64), 0.0_real64), &
                             transfer(int(z'401aeb851eb851ec', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'401aeb851eb851ec', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'c01151eb851eb852', int64), 0.0_real64), &
                             transfer(int(z'401aeb851eb851ec', int64), 0.0_real64), &
                             transfer(int(z'bfceb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'bfceb851eb851eb8', int64), 0.0_real64), &
                             transfer(int(z'401aeb851eb851ec', int64), 0.0_real64)]
  real(real64), parameter :: table_RVCNA(21) = [ &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'4006666666666666', int64), 0.0_real64), &
                             transfer(int(z'4006666666666666', int64), 0.0_real64), &
                             transfer(int(z'4000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4004000000000000', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64), &
                             transfer(int(z'4006666666666666', int64), 0.0_real64), &
                             transfer(int(z'4006666666666666', int64), 0.0_real64), &
                             transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64)]
  real(real64), parameter :: table_RVCH4QVT(21) = [ &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'4002b22d0e560419', int64), 0.0_real64), &
                             transfer(int(z'0000000000000000', int64), 0.0_real64)]
contains

  !> Initialize the selected twenty-type carbon-assimilation record.
  !! PRVR0VT is a (20,2) respiration table in kg CO2 m**(-2) s**(-1).
  !! Existing correctly bounded owners are reused; three source-unwritten scalars stay unchanged.
  subroutine sucotwo(PRVR0VT, YDVEG, YDCST, YDAGS)
    real(real64), intent(in) :: PRVR0VT(:, :)
    type(TVEG), intent(in) :: YDVEG
    type(TCST), intent(in) :: YDCST
    type(TAGS), intent(inout) :: YDAGS
    integer :: kind, column, j, k, iteration, allocation_status
    real(real64) :: a, b, c, temperature, exponent, gamma, capacity, conductance, fraction
    real(real64) :: first_factor, second_factor, input(10), coefficients(4), output(4)
    real(real64) :: root, old_root, p1, p2, p3, derivative, degree, product, left, right, weight
    if (YDVEG%NVTYPES /= 20 .or. any(shape(PRVR0VT) /= [20, 2])) error stop 'SUCOTWO: unsupported vegetation or table bounds'

    if (.not. allocated(YDAGS%RVTOPT)) then
      allocate (YDAGS%RVTOPT(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVTOPT) /= 21 .or. lbound(YDAGS%RVTOPT, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVFZERO)) then
      allocate (YDAGS%RVFZERO(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVFZERO) /= 21 .or. lbound(YDAGS%RVFZERO, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVFZEROST)) then
      allocate (YDAGS%RVFZEROST(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVFZEROST) /= 21 .or. lbound(YDAGS%RVFZEROST, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVEPSO)) then
      allocate (YDAGS%RVEPSO(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVEPSO) /= 21 .or. lbound(YDAGS%RVEPSO, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVGAMM)) then
      allocate (YDAGS%RVGAMM(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVGAMM) /= 21 .or. lbound(YDAGS%RVGAMM, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVQDGAMM)) then
      allocate (YDAGS%RVQDGAMM(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVQDGAMM) /= 21 .or. lbound(YDAGS%RVQDGAMM, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVQDGMES)) then
      allocate (YDAGS%RVQDGMES(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVQDGMES) /= 21 .or. lbound(YDAGS%RVQDGMES, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVT1GMES)) then
      allocate (YDAGS%RVT1GMES(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVT1GMES) /= 21 .or. lbound(YDAGS%RVT1GMES, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVT2GMES)) then
      allocate (YDAGS%RVT2GMES(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVT2GMES) /= 21 .or. lbound(YDAGS%RVT2GMES, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVAMMAX)) then
      allocate (YDAGS%RVAMMAX(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVAMMAX) /= 21 .or. lbound(YDAGS%RVAMMAX, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVQDAMMAX)) then
      allocate (YDAGS%RVQDAMMAX(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVQDAMMAX) /= 21 .or. lbound(YDAGS%RVQDAMMAX, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVT1AMMAX)) then
      allocate (YDAGS%RVT1AMMAX(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVT1AMMAX) /= 21 .or. lbound(YDAGS%RVT1AMMAX, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVT2AMMAX)) then
      allocate (YDAGS%RVT2AMMAX(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVT2AMMAX) /= 21 .or. lbound(YDAGS%RVT2AMMAX, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVAH)) then
      allocate (YDAGS%RVAH(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVAH) /= 21 .or. lbound(YDAGS%RVAH, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVBH)) then
      allocate (YDAGS%RVBH(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVBH) /= 21 .or. lbound(YDAGS%RVBH, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%LVSTRESS)) then
      allocate (YDAGS%LVSTRESS(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%LVSTRESS) /= 21 .or. lbound(YDAGS%LVSTRESS, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVBSLAI)) then
      allocate (YDAGS%RVBSLAI(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVBSLAI) /= 21 .or. lbound(YDAGS%RVBSLAI, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVLAIMIN)) then
      allocate (YDAGS%RVLAIMIN(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVLAIMIN) /= 21 .or. lbound(YDAGS%RVLAIMIN, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVSEFOLD)) then
      allocate (YDAGS%RVSEFOLD(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVSEFOLD) /= 21 .or. lbound(YDAGS%RVSEFOLD, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVGMES)) then
      allocate (YDAGS%RVGMES(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVGMES) /= 21 .or. lbound(YDAGS%RVGMES, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVGC)) then
      allocate (YDAGS%RVGC(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVGC) /= 21 .or. lbound(YDAGS%RVGC, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVDMAX)) then
      allocate (YDAGS%RVDMAX(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVDMAX) /= 21 .or. lbound(YDAGS%RVDMAX, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVF2I)) then
      allocate (YDAGS%RVF2I(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVF2I) /= 21 .or. lbound(YDAGS%RVF2I, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVCE)) then
      allocate (YDAGS%RVCE(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVCE) /= 21 .or. lbound(YDAGS%RVCE, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVCF)) then
      allocate (YDAGS%RVCF(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVCF) /= 21 .or. lbound(YDAGS%RVCF, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVCNA)) then
      allocate (YDAGS%RVCNA(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVCNA) /= 21 .or. lbound(YDAGS%RVCNA, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVBSLAI_NITRO)) then
      allocate (YDAGS%RVBSLAI_NITRO(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVBSLAI_NITRO) /= 21 .or. lbound(YDAGS%RVBSLAI_NITRO, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RXBOMEGAM)) then
      allocate (YDAGS%RXBOMEGAM(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RXBOMEGAM) /= 21 .or. lbound(YDAGS%RXBOMEGAM, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVR0VT)) then
      allocate (YDAGS%RVR0VT(0:20, 1:2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (any(shape(YDAGS%RVR0VT) /= [21, 2]) .or. any(lbound(YDAGS%RVR0VT) /= [0, 1])) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVCH4QVT)) then
      allocate (YDAGS%RVCH4QVT(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVCH4QVT) /= 21 .or. lbound(YDAGS%RVCH4QVT, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    if (.not. allocated(YDAGS%RVANMAX)) then
      allocate (YDAGS%RVANMAX(0:20), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUCOTWO: parameter allocation failed'
    end if
    if (size(YDAGS%RVANMAX) /= 21 .or. lbound(YDAGS%RVANMAX, 1) /= 0) &
      error stop 'SUCOTWO: existing owner has unsupported bounds'
    YDAGS%RMAIR = cp_scalar_RMAIR
    YDAGS%RMCO2 = cp_scalar_RMCO2
    YDAGS%RMC = cp_scalar_RMC
    YDAGS%RDMAX_AGS = cp_scalar_RDMAX_AGS
    YDAGS%RPARCF = cp_scalar_RPARCF
    YDAGS%RRACCF = cp_scalar_RRACCF
    YDAGS%RPCCO2 = cp_scalar_RPCCO2
    YDAGS%RIAOPT = cp_scalar_RIAOPT
    YDAGS%RDSPOPT = cp_scalar_RDSPOPT
    YDAGS%RXGT = cp_scalar_RXGT
    YDAGS%RDIFRACF = cp_scalar_RDIFRACF
    YDAGS%RXBOMEGA = cp_scalar_RXBOMEGA
    YDAGS%RRDCF = cp_scalar_RRDCF
    YDAGS%RAMMIN = cp_scalar_RAMMIN
    YDAGS%RCONDCTMIN = cp_scalar_RCONDCTMIN
    YDAGS%RCONDSTMIN = cp_scalar_RCONDSTMIN
    YDAGS%RANFMINIT = cp_scalar_RANFMINIT
    YDAGS%RAIRTOH2O = cp_scalar_RAIRTOH2O
    YDAGS%RCO2TOH2O = cp_scalar_RCO2TOH2O
    YDAGS%RAW = cp_scalar_RAW
    YDAGS%RASW = cp_scalar_RASW
    YDAGS%RBW = cp_scalar_RBW
    YDAGS%RDMAXN = cp_scalar_RDMAXN
    YDAGS%RDMAXX = cp_scalar_RDMAXX
    YDAGS%RRESPFACTOR_NIT = cp_scalar_RRESPFACTOR_NIT
    YDAGS%RCNS_NIT = cp_scalar_RCNS_NIT
    YDAGS%RCA_1X_CO2_NIT = cp_scalar_RCA_1X_CO2_NIT
    YDAGS%RCA_2X_CO2_NIT = cp_scalar_RCA_2X_CO2_NIT
    YDAGS%RCC_NIT = cp_scalar_RCC_NIT
    YDAGS%RVTOPT = table_RVTOPT
    YDAGS%RVFZERO = table_RVFZERO
    YDAGS%RVFZEROST = table_RVFZEROST
    YDAGS%RVEPSO = table_RVEPSO
    YDAGS%RVGAMM = table_RVGAMM
    YDAGS%RVQDGAMM = table_RVQDGAMM
    YDAGS%RVQDGMES = table_RVQDGMES
    YDAGS%RVT1GMES = table_RVT1GMES
    YDAGS%RVT2GMES = table_RVT2GMES
    YDAGS%RVAMMAX = table_RVAMMAX
    YDAGS%RVQDAMMAX = table_RVQDAMMAX
    YDAGS%RVT1AMMAX = table_RVT1AMMAX
    YDAGS%RVT2AMMAX = table_RVT2AMMAX
    YDAGS%RVAH = table_RVAH
    YDAGS%RVBH = table_RVBH
    YDAGS%LVSTRESS = .false.
    YDAGS%RVBSLAI = table_RVBSLAI
    YDAGS%RVLAIMIN = table_RVLAIMIN
    YDAGS%RVGMES = table_RVGMES
    YDAGS%RVGC = table_RVGC
    YDAGS%RVDMAX = table_RVDMAX
    YDAGS%RVF2I = table_RVF2I
    YDAGS%RVCE = table_RVCE
    YDAGS%RVCF = table_RVCF
    YDAGS%RVCNA = table_RVCNA
    YDAGS%RVCH4QVT = table_RVCH4QVT

    a = cp_CO2_massfrac*cp_CO2_molmass
    YDAGS%RCO2 = a/cp_air_molmass
    YDAGS%RVCH4S = table_RVCH4S
    do column = 1, 2
      YDAGS%RVR0VT(0, column) = PRVR0VT(7, column)
      do kind = 1, 20
        YDAGS%RVR0VT(kind, column) = PRVR0VT(kind, column)
      end do
    end do
    do kind = 1, 20
      YDAGS%RVSEFOLD(kind) = table_RVSEFOLD(kind + 1)*YDCST%RDAY
    end do
    YDAGS%RVSEFOLD(0) = YDAGS%RVSEFOLD(7)
    do kind = 0, 20
      a = YDAGS%RVCE(kind)*YDAGS%RVCNA(kind)
      a = a + YDAGS%RVCF(kind)
      YDAGS%RVBSLAI_NITRO(kind) = cp_one/a
    end do
    do kind = 0, 20
      a = YDAGS%RXBOMEGA
      if ((kind >= 3 .and. kind <= 6) .or. (kind >= 18 .and. kind <= 19)) a = a*cp_one
      YDAGS%RXBOMEGAM(kind) = a
    end do
    coefficients = [YDAGS%RAIRTOH2O, YDAGS%RCO2TOH2O, YDAGS%RCONDSTMIN, YDAGS%RRDCF]
    do kind = 0, 20
      temperature = YDAGS%RVTOPT(kind)
      exponent = temperature - cp_twentyfive
      exponent = cp_one_tenth*exponent
      a = public_power(YDAGS%RVQDGAMM(kind), exponent)
      gamma = YDAGS%RVGAMM(kind)*a
      a = public_power(YDAGS%RVQDAMMAX(kind), exponent)
      capacity = YDAGS%RVAMMAX(kind)*a
      a = YDAGS%RVT1AMMAX(kind) - temperature
      a = cp_three_tenths*a
      a = public_exponential(a)
      first_factor = cp_one + a
      a = temperature - YDAGS%RVT2AMMAX(kind)
      a = cp_three_tenths*a
      a = public_exponential(a)
      second_factor = cp_one + a
      a = first_factor*second_factor
      capacity = capacity/a
      a = public_power(YDAGS%RVQDGMES(kind), exponent)
      conductance = YDAGS%RVGMES(kind)*a
      a = YDAGS%RVT1GMES(kind) - temperature
      a = cp_three_tenths*a
      a = public_exponential(a)
      first_factor = cp_one + a
      a = temperature - YDAGS%RVT2GMES(kind)
      a = cp_three_tenths*a
      a = public_exponential(a)
      second_factor = cp_one + a
      a = first_factor*second_factor
      conductance = conductance/a
      conductance = conductance*cp_one
      fraction = YDAGS%RVFZEROST(kind)
      if ((kind >= 3 .and. kind <= 6) .or. (kind >= 18 .and. kind <= 19)) then
        a = YDAGS%RVGMES(kind)*cp_thousand
        a = public_logarithm(a)
        a = YDAGS%RAW - a
        fraction = a/YDAGS%RBW
      end if
      input = [YDAGS%RVGC(kind), YDAGS%RCO2, YDAGS%RDSPOPT, YDAGS%RVDMAX(kind), YDAGS%RIAOPT, &
               gamma, fraction, conductance, YDAGS%RVEPSO(kind), capacity]
      call carbon_assimilation_one_cell(input, coefficients, output)
      YDAGS%RVANMAX(kind) = output(1)
    end do
    ! Keep the last Newton derivative at the source's final updated root.
    do j = 1, 2
      a = real(j, real64) - cp_quarter
      a = YDCST%RPI*a
      a = a/cp_gauss_threehalf
      root = public_cosine(a)
      do iteration = 1, 100
        p1 = cp_one
        p2 = cp_zero
        do k = 1, 3
          p3 = p2
          p2 = p1
          degree = real(k, real64)
          a = cp_two*degree
          a = a - cp_one
          a = a*root
          a = a*p2
          b = degree - cp_one
          b = b*p3
          a = a - b
          p1 = a/degree
        end do
        a = root*p1
        a = a - p2
        a = cp_three*a
        b = root*root
        b = b - cp_one
        derivative = a/b
        old_root = root
        a = p1/derivative
        root = old_root - a
        a = abs(root - old_root)
        if (a <= cp_gauss_tolerance) exit
      end do
      a = cp_half*root
      left = cp_half - a
      right = cp_half + a
      YDAGS%RABC(j) = left
      YDAGS%RABC(4 - j) = right
      a = root*root
      a = cp_one - a
      a = a*derivative
      a = a*derivative
      b = cp_two*cp_half
      weight = b/a
      YDAGS%RPOI(j) = weight
      YDAGS%RPOI(4 - j) = weight
    end do
  end subroutine sucotwo
end module sucotwo_mod

module sufarquhar_mod
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use yos_veg, only: TVEG
  use yos_ags, only: TAGS
  use yos_agf, only: TAGF
  implicit none
  private
  public :: sufarquhar
contains
  !> Initialize ten owned (20,2) tables and the source-defined fixed parameters.
  !! Inputs retain their named parameter units and exact payload bits.
  !! NIUNDEF is source-unwritten and is preserved.
  subroutine sufarquhar(PRVCMAX25, PRHUMREL, PRA1, PRB1, PRG0, PRGM25, PRE_VCMAX, PRE_JMAX, YDVEG, YDAGS, YDAGF)
    real(real64), intent(in) :: PRVCMAX25(:, :), PRHUMREL(:, :), PRA1(:, :), PRB1(:, :)
    real(real64), intent(in) :: PRG0(:, :), PRGM25(:, :), PRE_VCMAX(:, :), PRE_JMAX(:, :)
    type(TVEG), intent(in) :: YDVEG
    type(TAGS), intent(in) :: YDAGS
    type(TAGF), intent(inout) :: YDAGF
    integer :: allocation_status

    real(real64), parameter :: literal_RDOWNREGULATION_CO2_COEF(40) = [ &
                               transfer(int(z'3fceb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'3fceb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'3fc999999999999a', int64), 0.0_real64), &
                               transfer(int(z'3fc999999999999a', int64), 0.0_real64), &
                               transfer(int(z'3fd0a3d70a3d70a4', int64), 0.0_real64), &
                               transfer(int(z'3fd0a3d70a3d70a4', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'3fceb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'3fceb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'3f9eb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'3fceb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'3f9eb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'3fceb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'3fd0a3d70a3d70a4', int64), 0.0_real64), &
                               transfer(int(z'3fd0a3d70a3d70a4', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'3f9eb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'3f9eb851eb851eb8', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64)]

    real(real64), parameter :: literal_RSTRUCT_CONST(40) = [ &
                               transfer(int(z'4000000000000000', int64), 0.0_real64), &
                               transfer(int(z'4004000000000000', int64), 0.0_real64), &
                               transfer(int(z'4039000000000000', int64), 0.0_real64), &
                               transfer(int(z'4039000000000000', int64), 0.0_real64), &
                               transfer(int(z'4039000000000000', int64), 0.0_real64), &
                               transfer(int(z'4039000000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'0000000000000000', int64), 0.0_real64), &
                               transfer(int(z'4004000000000000', int64), 0.0_real64), &
                               transfer(int(z'4000000000000000', int64), 0.0_real64), &
                               transfer(int(z'4000000000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'4004000000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'4000000000000000', int64), 0.0_real64), &
                               transfer(int(z'4004000000000000', int64), 0.0_real64), &
                               transfer(int(z'4039000000000000', int64), 0.0_real64), &
                               transfer(int(z'4039000000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'4000000000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'4000000000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64), &
                               transfer(int(z'c0c3878000000000', int64), 0.0_real64)]

    if (YDVEG%NVTYPES /= 20) error stop 'SUFARQUHAR: unsupported vegetation count'
    if (any(shape(PRVCMAX25) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (any(shape(PRHUMREL) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (any(shape(PRA1) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (any(shape(PRB1) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (any(shape(PRG0) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (any(shape(PRGM25) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (any(shape(PRE_VCMAX) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (any(shape(PRE_JMAX) /= [20, 2])) error stop 'SUFARQUHAR: unsupported input table bounds'
    if (.not. allocated(YDAGF%RVCMAX25)) then
      allocate (YDAGF%RVCMAX25(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RVCMAX25) /= [20, 2]) .or. any(lbound(YDAGF%RVCMAX25) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RHUMREL)) then
      allocate (YDAGF%RHUMREL(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RHUMREL) /= [20, 2]) .or. any(lbound(YDAGF%RHUMREL) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RA1)) then
      allocate (YDAGF%RA1(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RA1) /= [20, 2]) .or. any(lbound(YDAGF%RA1) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RB1)) then
      allocate (YDAGF%RB1(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RB1) /= [20, 2]) .or. any(lbound(YDAGF%RB1) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RG0)) then
      allocate (YDAGF%RG0(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RG0) /= [20, 2]) .or. any(lbound(YDAGF%RG0) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RGM25)) then
      allocate (YDAGF%RGM25(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RGM25) /= [20, 2]) .or. any(lbound(YDAGF%RGM25) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RE_VCMAX)) then
      allocate (YDAGF%RE_VCMAX(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RE_VCMAX) /= [20, 2]) .or. any(lbound(YDAGF%RE_VCMAX) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RE_JMAX)) then
      allocate (YDAGF%RE_JMAX(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RE_JMAX) /= [20, 2]) .or. any(lbound(YDAGF%RE_JMAX) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RDOWNREGULATION_CO2_COEF)) then
      allocate (YDAGF%RDOWNREGULATION_CO2_COEF(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RDOWNREGULATION_CO2_COEF) /= [20, 2]) .or. any(lbound(YDAGF%RDOWNREGULATION_CO2_COEF) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    if (.not. allocated(YDAGF%RSTRUCT_CONST)) then
      allocate (YDAGF%RSTRUCT_CONST(20, 2), stat=allocation_status)
      if (allocation_status /= 0) error stop 'SUFARQUHAR: parameter allocation failed'
    end if
    if (any(shape(YDAGF%RSTRUCT_CONST) /= [20, 2]) .or. any(lbound(YDAGF%RSTRUCT_CONST) /= [1, 1])) &
      error stop 'SUFARQUHAR: existing owner has unsupported bounds'
    YDAGF%RVCMAX25 = PRVCMAX25
    YDAGF%RHUMREL = PRHUMREL
    YDAGF%RA1 = PRA1
    YDAGF%RB1 = PRB1
    YDAGF%RG0 = PRG0
    YDAGF%RGM25 = PRGM25
    YDAGF%RE_VCMAX = PRE_VCMAX
    YDAGF%RE_JMAX = PRE_JMAX
    YDAGF%RDOWNREGULATION_CO2_COEF = reshape(literal_RDOWNREGULATION_CO2_COEF, [20, 2])
    YDAGF%RSTRUCT_CONST = reshape(literal_RSTRUCT_CONST, [20, 2])
    YDAGF%NLAI = 20_int32
    YDAGF%NLAI1 = 21_int32
    YDAGF%NPATH = 2_int32
    YDAGF%RDOWNREGULATION_CO2_BASELEVEL = transfer(int(z'4077c00000000000', int64), 0.0_real64)
    YDAGF%RDOWNREGULATION_CO2_MINIMUM = transfer(int(z'4071800000000000', int64), 0.0_real64)
    YDAGF%RUNDEF_SECHIBA = transfer(int(z'4415af1d78b58c40', int64), 0.0_real64)
    YDAGF%RUNDEF = transfer(int(z'c0c3878000000000', int64), 0.0_real64)
    YDAGF%RONE_MONTH = transfer(int(z'4143c68000000000', int64), 0.0_real64)
    YDAGF%RARJV = [transfer(int(z'4004b851eb851eb8', int64), 0.0_real64), transfer(int(z'3ffb70a3d70a3d71', int64), 0.0_real64)]
    YDAGF%RBRJV = [transfer(int(z'bfa1eb851eb851ec', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
    YDAGF%RASJ = [transfer(int(z'40849d999999999a', int64), 0.0_real64), transfer(int(z'4083b00000000000', int64), 0.0_real64)]
    YDAGF%RBSJ = [transfer(int(z'bfe8000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
    YDAGF%RASV = [transfer(int(z'4084e31eb851eb85', int64), 0.0_real64), transfer(int(z'40840d1eb851eb85', int64), 0.0_real64)]
    YDAGF%RBSV = [transfer(int(z'bff11eb851eb851f', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
    YDAGF%RD_VCMAX = [transfer(int(z'41086a0000000000', int64), 0.0_real64), transfer(int(z'4107700000000000', int64), 0.0_real64)]
    YDAGF%RD_JMAX = [transfer(int(z'41086a0000000000', int64), 0.0_real64), transfer(int(z'4107700000000000', int64), 0.0_real64)]
    YDAGF%RE_GAMMA_STAR = transfer(int(z'40e278c000000000', int64), 0.0_real64)
    YDAGF%RE_GM = [transfer(int(z'40e8380000000000', int64), 0.0_real64), transfer(int(z'c0c3878000000000', int64), 0.0_real64)]
    YDAGF%RS_GM = [transfer(int(z'4095e00000000000', int64), 0.0_real64), transfer(int(z'c0c3878000000000', int64), 0.0_real64)]
    YDAGF%RS_JMAX = [transfer(int(z'4084500000000000', int64), 0.0_real64), transfer(int(z'4083b00000000000', int64), 0.0_real64)]
    YDAGF%RD_GM = [transfer(int(z'411ab26000000000', int64), 0.0_real64), transfer(int(z'c0c3878000000000', int64), 0.0_real64)]
    YDAGF%RE_KMC = transfer(int(z'40f3646000000000', int64), 0.0_real64)
    YDAGF%RE_KMO = transfer(int(z'40e1c38000000000', int64), 0.0_real64)
    YDAGF%RE_RD = transfer(int(z'40e6a6c000000000', int64), 0.0_real64)
    YDAGF%RE_SCO = transfer(int(z'c0d7e30000000000', int64), 0.0_real64)
    YDAGF%RGAMMA_STAR25 = transfer(int(z'4045600000000000', int64), 0.0_real64)
    YDAGF%RKMC25 = [transfer(int(z'40794e6666666666', int64), 0.0_real64), transfer(int(z'4084500000000000', int64), 0.0_real64)]
    YDAGF%RKMO25 = [transfer(int(z'4110fe0000000000', int64), 0.0_real64), transfer(int(z'411b774000000000', int64), 0.0_real64)]
    YDAGF%RSCO25 = [transfer(int(z'40a5e00000000000', int64), 0.0_real64), transfer(int(z'40a43c0000000000', int64), 0.0_real64)]
    YDAGF%RSTRESS_GM = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    YDAGF%RSTRESS_GS = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    YDAGF%RSTRESS_VCMAX = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    YDAGF%RTPHOTO_MAX = transfer(int(z'404b800000000000', int64), 0.0_real64)
    YDAGF%RTPHOTO_MIN = transfer(int(z'c010000000000000', int64), 0.0_real64)
    YDAGF%RLAI_LEVEL_DEPTH = transfer(int(z'3fc3333333333333', int64), 0.0_real64)
    YDAGF%RLAIMAX = transfer(int(z'4028000000000000', int64), 0.0_real64)
    YDAGF%REXT_COEFF = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    YDAGF%RGB_REF = transfer(int(z'3fa47ae147ae147b', int64), 0.0_real64)
    YDAGF%RTP_00 = transfer(int(z'4071126666666666', int64), 0.0_real64)
    YDAGF%RPB_STD = transfer(int(z'408fa80000000000', int64), 0.0_real64)
    YDAGF%RRG_TO_PAR = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    YDAGF%RW_TO_MOL = transfer(int(z'4012666666666666', int64), 0.0_real64)
    YDAGF%RALPHA_LL = transfer(int(z'3fd3333333333333', int64), 0.0_real64)
    YDAGF%RTHETA = transfer(int(z'3fe6666666666666', int64), 0.0_real64)
    YDAGF%RFPSIR = transfer(int(z'3fd999999999999a', int64), 0.0_real64)
    YDAGF%RFQ = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    YDAGF%RFPSEUDO = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
    YDAGF%RH_PROTONS = transfer(int(z'4010000000000000', int64), 0.0_real64)
    YDAGF%RGBS = transfer(int(z'3f689374bc6a7efa', int64), 0.0_real64)
    YDAGF%ROI = transfer(int(z'4109a28000000000', int64), 0.0_real64)
    YDAGF%RALPHA = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
    YDAGF%RKP = transfer(int(z'3fe6666666666666', int64), 0.0_real64)
    YDAGF%RTETENS_1 = transfer(int(z'3fe3e76c8b439581', int64), 0.0_real64)
    YDAGF%RTETENS_2 = transfer(int(z'3fd83126e978d4fe', int64), 0.0_real64)
    YDAGF%RREF_TEMP = transfer(int(z'4072a00000000000', int64), 0.0_real64)
    YDAGF%RMOL_TO_M_1 = transfer(int(z'3f98fc5040000000', int64), 0.0_real64)
    YDAGF%RRATIO_H2O_TO_CO2 = transfer(int(z'3ff99999a0000000', int64), 0.0_real64)
    YDAGF%RN_VERT_ATT = transfer(int(z'3fe6666666666666', int64), 0.0_real64)
    YDAGF%RRVEG_PFT = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    YDAGF%RTAU_TEMP_AIR_MONTH = transfer(int(z'413a5e0000000000', int64), 0.0_real64)
  end subroutine sufarquhar
end module sufarquhar_mod
