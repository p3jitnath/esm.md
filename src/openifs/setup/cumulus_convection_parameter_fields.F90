!> Set the selected cumulus-convection coefficients in native records.
!! Convection carries heat and moisture through rising and sinking air.
!! This source ports the ordered numerical body of the generated SUCUMF
!! fields. It uses the original record declaration and no original routine.
module convection_parameter_fields_mod
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  use yoecumf, only: tecumf
  implicit none
  private
  public :: convection_thermal_parameter_record, initialize_cumulus_convection_fields
  !> Three thermal values produced after the ordinary thermal initializer.
  type, bind(c) :: convection_thermal_parameter_record
    real(c_double) :: rtwat
    real(c_double) :: rticecu
    real(c_double) :: rtwat_rticecu_r
  end type
contains
  !> Assign the selected SUCUMF defaults and live pressure-index bounds.
  !! OUTPUT is a native TECUMF record whose source-unwritten fields and
  !! padding remain incoming. THERMAL receives water and ice limits in K
  !! and the reciprocal transition width in K^-1. PRESSURE contains the
  !! live levels in Pa and is readonly. Its admitted size is 4 through 512.
  !! RG is gravity in m s^-2 and RTT is reference temperature in K.
  !! RPLRG and RPLDARE are positive dimensionless dynamical scale factors.
  !! The caller admits all bounds, finite values and separate owners.
  !! This raw child allocates no storage and retains no input address.
  subroutine initialize_cumulus_convection_fields(output, thermal, pressure, rg, rtt, rplrg, rpldare)
    type(tecumf), intent(inout) :: output
    type(convection_thermal_parameter_record), intent(inout) :: thermal
    real(real64), intent(in) :: pressure(:), rg, rtt, rplrg, rpldare
    real(real64), volatile :: scaled_product, melting_quotient, transition_width
    integer(int32) :: level, levels
    levels = int(size(pressure), int32)
    output%entshalp = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%entstpc1 = transfer(int(z'3fe999999999999a', int64), 0.0_real64)
    output%entstpc2 = transfer(int(z'3f2a36e2eb1c432d', int64), 0.0_real64)
    output%entstpc3 = transfer(int(z'4008000000000000', int64), 0.0_real64)
    output%rmfcmin = transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64)
    output%rmfdeps = transfer(int(z'3fd3333333333333', int64), 0.0_real64)
    output%rdepths = transfer(int(z'40d3880000000000', int64), 0.0_real64)
    output%rcucov = transfer(int(z'3fa999999999999a', int64), 0.0_real64)
    output%rhebc = transfer(int(z'3fed70a3d70a3d71', int64), 0.0_real64)
    output%rtaua = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%lmfpen = .true.
    output%lmfscv = .true.
    output%lmfmid = .true.
    output%lmfdd = .true.
    output%lmfdudv = .true.
    output%lmfdsnow = .true.
    output%lmfwetb = .true.
    output%lmfglac = .true.
    output%lscvliq = .true.
    output%lmfuvdis = .true.
    output%lmfenthcons = .false.
    output%lmfcuca = .false.
    output%lmfprofp = .false.
    output%rmfsoluv = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%rmfsoltq = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%rmfsolct = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%rmfsolrhs = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rmfadvw = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rmfadvwdd = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%lmfsmooth = .false.
    output%lmfwstar = .false.
    output%rcapdcycl = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%rcapqadv = transfer(int(z'3fe999999999999a', int64), 0.0_real64)
    output%rmincape = transfer(int(z'3fa999999999999a', int64), 0.0_real64)
    output%ruvper = transfer(int(z'3fd3333333333333', int64), 0.0_real64)
    output%rbase0 = transfer(int(z'40d86a0000000000', int64), 0.0_real64)
    output%rmincin = transfer(int(z'c08f400000000000', int64), 0.0_real64)
    output%detrpen = 0.75e-4_real64*rplrg
    output%entrorg = 1.75e-3_real64*rplrg
    output%entrdd = 3.0e-4_real64*rplrg
    output%rprcon = 1.4e-3_real64*rplrg
    output%rcpecons = 5.44e-4_real64/rg
    output%rcvrfactor = 5.09e-3_real64/rplrg
    scaled_product = rplrg*rpldare
    melting_quotient = 18000.0_real64/scaled_product
    output%rtaumel = melting_quotient*0.66_real64
    output%rmflia = 2.0_real64*rpldare
    output%rmfcfl = 3.0_real64
    thermal%rtwat = rtt
    thermal%rticecu = rtt - 38.0_real64
    transition_width = rtt - thermal%rticecu
    thermal%rtwat_rticecu_r = 1.0_real64/transition_width
    output%njkt1 = 2_int32
    output%njkt2 = 2_int32
    output%njkt8 = 2_int32
    output%njkt3 = levels - 2_int32
    do level = levels, 2, -1
      if (pressure(level) > 35000.0_real64) output%njkt1 = level
      if (pressure(level) > 6000.0_real64) output%njkt2 = level
      if (pressure(level) > 95000.0_real64) output%njkt3 = level
      if (pressure(level) > 85000.0_real64) output%njkt4 = level
      if (pressure(level) > 50000.0_real64) output%njkt5 = level
      if (pressure(level) > 70000.0_real64) output%njkt6 = level
      if (pressure(level) > 10000.0_real64) output%njkt7 = level
      if (pressure(level) > 100.0_real64) output%njkt8 = level
    end do
    output%njkt3 = min(output%njkt3, levels - 2_int32)
  end subroutine
end module
