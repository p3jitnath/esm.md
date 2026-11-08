module physical_constant_setup_port
  !! Construct the generated physical constants in owned native storage.
  !! Lengths are metres, times are seconds, and molar masses are grams per
  !! mole. Gas and heat capacities use joules per kilogram per kelvin.
  !! Latent heats use joules per kilogram. The original contract defines
  !! the remaining astronomical, radiative and saturation constants.
  use, intrinsic :: iso_c_binding
  use forecast_positive_logarithm, only: positive_logarithm
  implicit none
  private
  public :: forecast_physical_constants, initialize_physical_constants
  type, bind(c) :: forecast_physical_constants
    real(c_double) :: rpi, rclum, rhpla, rkbol, rnavo
    real(c_double) :: rday, rdayi, rhour, rea, repsm
    real(c_double) :: rsiyea, rsiday, romega, ra, rg
    real(c_double) :: r1sa, deg2rad, rsigma, ri0, r
    real(c_double) :: rmd, rmv, rmo3, rd, rv
    real(c_double) :: rcpd, rcpv, rcvd, rcvv, rkappa
    real(c_double) :: retv, rmco2, rmch4, rmn2o, rmco
    real(c_double) :: rmhcho, rmno2, rmso2, rmso4, rmcfc11
    real(c_double) :: rmcfc12, rmhcfc22, rmccl4, rcw, rcs
    real(c_double) :: ratm, rtt, rlvtt, rlstt, rlvzer
    real(c_double) :: rlszer, rlmlt, rdt, restt, rgamw
    real(c_double) :: rbetw, ralpw, rgams, rbets, ralps
    real(c_double) :: ralpd, rbetd, rgamd, rsnan
    integer(c_int) :: initialized, reserved
  end type
  real(c_double), parameter :: source_rpi = &
                               transfer(int(z'400921fb54442d18', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rclum = &
                               transfer(int(z'41b1de784a000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rhpla = &
                               transfer(int(z'390b860d52d96191', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rkbol = &
                               transfer(int(z'3b30b0edf6c91c1b', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rnavo = &
                               transfer(int(z'44dfe18461be0ec2', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rday = &
                               transfer(int(z'40f5180000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rdayi = &
                               transfer(int(z'40f5180000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rhour = &
                               transfer(int(z'40ac200000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rea = &
                               transfer(int(z'42416a5d2bd80000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_repsm = &
                               transfer(int(z'3fda2e9468017119', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_ra = &
                               transfer(int(z'41584de740000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rg = &
                               transfer(int(z'40239d013a92a305', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_ri0 = &
                               transfer(int(z'4095580000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmd = &
                               transfer(int(z'403cf6e2eb1c432d', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmv = &
                               transfer(int(z'403203eab367a0f9', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmo3 = &
                               transfer(int(z'4047ff41f212d773', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmco2 = &
                               transfer(int(z'404601374bc6a7f0', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmch4 = &
                               transfer(int(z'40300a3d70a3d70a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmn2o = &
                               transfer(int(z'404601a9fbe76c8b', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmco = &
                               transfer(int(z'403c028f5c28f5c3', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmhcho = &
                               transfer(int(z'403e07ae147ae148', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmno2 = &
                               transfer(int(z'40470147ae147ae1', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmso2 = &
                               transfer(int(z'40500395810624dd', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmso4 = &
                               transfer(int(z'40580353f7ced917', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmcfc11 = &
                               transfer(int(z'40612bcb923a29c7', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmcfc12 = &
                               transfer(int(z'405e3a7ef9db22d1', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmhcfc22 = &
                               transfer(int(z'40559e04189374bc', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rmccl4 = &
                               transfer(int(z'40633a5604189375', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rcw = &
                               transfer(int(z'40b07a0000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rcs = &
                               transfer(int(z'40a0740000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rtt = &
                               transfer(int(z'4071128f5c28f5c3', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rdt = &
                               transfer(int(z'4027a3d70a3d70a4', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rlvtt = &
                               transfer(int(z'4143146000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_rlstt = &
                               transfer(int(z'4145a02200000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_ratm = &
                               transfer(int(z'40f86a0000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_restt = &
                               transfer(int(z'4083191eb851eb85', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_one = &
                               transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_two = &
                               transfer(int(z'4000000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_four = &
                               transfer(int(z'4010000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_threehalf = &
                               transfer(int(z'400c000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_thousand = &
                               transfer(int(z'408f400000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_daysyear = &
                               transfer(int(z'4076d40000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_yearangle = &
                               transfer(int(z'401921deacc92147', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_deg = &
                               transfer(int(z'4066800000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: source_fifteen = &
                               transfer(int(z'402e000000000000', c_int64_t), 0.0_c_double)
contains
  function initialize_physical_constants(constants) &
    bind(c, name="md2asm_initialize_physical_constants_fortran") result(status)
    !! Preserve each source multiplication, division and addition.
    !! The caller supplies a complete native object and establishes the
    !! frozen nearest-rounding, gradual-underflow environment. The final
    !! reserved int32 retains its input bytes. The NaN marker is copied
    !! as bits and is never used in a floating-point calculation here.
    type(forecast_physical_constants), intent(inout) :: constants
    integer(c_int) :: status
    real(c_double) :: work0, work1, work2, work3, work4
    work0 = source_rpi
    constants%rpi = work0
    work0 = source_rclum
    constants%rclum = work0
    work0 = source_rhpla
    constants%rhpla = work0
    work0 = source_rkbol
    constants%rkbol = work0
    work0 = source_rnavo
    constants%rnavo = work0
    work0 = source_rdayi
    constants%rdayi = work0
    work0 = source_rday
    constants%rday = work0
    work0 = source_rhour
    constants%rhour = work0
    work0 = source_rea
    constants%rea = work0
    work0 = source_repsm
    constants%repsm = work0
    ! Astronomical time scales, with source left-to-right rounding.
    work0 = source_daysyear
    work1 = constants%rday
    work0 = work0*work1
    work2 = source_two
    work0 = work0*work2
    work3 = constants%rpi
    work0 = work0*work3
    work2 = source_yearangle
    work0 = work0/work2
    constants%rsiyea = work0
    work2 = work1/work0
    work3 = source_one
    work2 = work3 + work2
    work0 = work1/work2
    constants%rsiday = work0
    work1 = constants%rpi
    work2 = source_two
    work1 = work2*work1
    work0 = work1/work0
    constants%romega = work0
    work0 = source_ra
    constants%ra = work0
    work0 = source_rg
    constants%rg = work0
    work0 = source_one
    work1 = constants%ra
    work0 = work0/work1
    constants%r1sa = work0
    work0 = constants%rpi
    work1 = source_deg
    work0 = work0/work1
    constants%deg2rad = work0
    ! Stefan-Boltzmann constant. Integer powers have explicit products.
    work0 = constants%rpi
    work1 = work0*work0
    work1 = work1*work1
    work1 = work1*work0
    work2 = source_two
    work1 = work2*work1
    work2 = constants%rkbol
    work3 = constants%rhpla
    work3 = work2/work3
    work4 = work3*work3
    work3 = work4*work3
    work1 = work1*work3
    work1 = work1*work2
    work2 = constants%rclum
    work2 = work2*work2
    work3 = source_fifteen
    work2 = work3*work2
    work0 = work1/work2
    constants%rsigma = work0
    work0 = source_ri0
    constants%ri0 = work0
    work0 = constants%rnavo
    work1 = constants%rkbol
    work0 = work0*work1
    constants%r = work0
    work0 = source_rmd
    constants%rmd = work0
    work0 = source_rmv
    constants%rmv = work0
    work0 = source_rmo3
    constants%rmo3 = work0
    work0 = source_thousand
    work1 = constants%r
    work0 = work0*work1
    work1 = constants%rmd
    work1 = work0/work1
    constants%rd = work1
    work2 = constants%rmv
    work0 = work0/work2
    constants%rv = work0
    work2 = source_threehalf
    work2 = work2*work1
    constants%rcpd = work2
    work3 = work2 - work1
    constants%rcvd = work3
    work3 = source_four
    work3 = work3*work0
    constants%rcpv = work3
    work4 = work3 - work0
    constants%rcvv = work4
    work4 = work1/work2
    constants%rkappa = work4
    work0 = work0/work1
    work1 = source_one
    work0 = work0 - work1
    constants%retv = work0
    work0 = source_rmco2
    constants%rmco2 = work0
    work0 = source_rmch4
    constants%rmch4 = work0
    work0 = source_rmn2o
    constants%rmn2o = work0
    work0 = source_rmco
    constants%rmco = work0
    work0 = source_rmhcho
    constants%rmhcho = work0
    work0 = source_rmno2
    constants%rmno2 = work0
    work0 = source_rmso2
    constants%rmso2 = work0
    work0 = source_rmso4
    constants%rmso4 = work0
    work0 = source_rmcfc11
    constants%rmcfc11 = work0
    work0 = source_rmcfc12
    constants%rmcfc12 = work0
    work0 = source_rmhcfc22
    constants%rmhcfc22 = work0
    work0 = source_rmccl4
    constants%rmccl4 = work0
    work0 = source_rcw
    constants%rcw = work0
    work0 = source_rcs
    constants%rcs = work0
    work0 = source_rtt
    constants%rtt = work0
    work0 = source_rdt
    constants%rdt = work0
    work0 = source_rlvtt
    constants%rlvtt = work0
    work0 = source_rlstt
    constants%rlstt = work0
    work0 = constants%rcw
    work1 = constants%rcpv
    work0 = work0 - work1
    work2 = constants%rtt
    work0 = work2*work0
    work3 = constants%rlvtt
    work0 = work3 + work0
    constants%rlvzer = work0
    work0 = constants%rcs
    work0 = work0 - work1
    work0 = work2*work0
    work4 = constants%rlstt
    work0 = work4 + work0
    constants%rlszer = work0
    work0 = work4 - work3
    constants%rlmlt = work0
    work0 = source_ratm
    constants%ratm = work0
    work0 = source_restt
    constants%restt = work0
    work0 = constants%rcw
    work1 = constants%rcpv
    work0 = work0 - work1
    work2 = constants%rv
    work0 = work0/work2
    constants%rgamw = work0
    work1 = constants%rlvtt
    work1 = work1/work2
    work2 = constants%rtt
    work0 = work0*work2
    work0 = work1 + work0
    constants%rbetw = work0
    work0 = constants%restt
    work0 = positive_logarithm(work0)
    constants%ralpw = work0
    work1 = constants%rbetw
    work2 = constants%rtt
    work1 = work1/work2
    work0 = work0 + work1
    constants%ralpw = work0
    work0 = constants%rtt
    work0 = positive_logarithm(work0)
    work1 = constants%rgamw
    work0 = work1*work0
    work1 = constants%ralpw
    work0 = work1 + work0
    constants%ralpw = work0
    work0 = constants%rcs
    work1 = constants%rcpv
    work0 = work0 - work1
    work2 = constants%rv
    work0 = work0/work2
    constants%rgams = work0
    work1 = constants%rlstt
    work1 = work1/work2
    work2 = constants%rtt
    work0 = work0*work2
    work0 = work1 + work0
    constants%rbets = work0
    work0 = constants%restt
    work0 = positive_logarithm(work0)
    constants%ralps = work0
    work1 = constants%rbets
    work2 = constants%rtt
    work1 = work1/work2
    work0 = work0 + work1
    constants%ralps = work0
    work0 = constants%rtt
    work0 = positive_logarithm(work0)
    work1 = constants%rgams
    work0 = work1*work0
    work1 = constants%ralps
    work0 = work1 + work0
    constants%ralps = work0
    work0 = constants%rgams
    work1 = constants%rgamw
    work0 = work0 - work1
    constants%rgamd = work0
    work0 = constants%rbets
    work1 = constants%rbetw
    work0 = work0 - work1
    constants%rbetd = work0
    work0 = constants%ralps
    work1 = constants%ralpw
    work0 = work0 - work1
    constants%ralpd = work0
    constants%rsnan = transfer(int(z'7ff4000000000000', c_int64_t), 0.0_c_double)
    constants%initialized = 1
    status = 0
  end function
end module
