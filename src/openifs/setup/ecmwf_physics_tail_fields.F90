!> Set wave-coupling, linearized-physics and methane startup parameters.
!! These native Fortran leaves retain the ordered selected calculations in
!! src/openifs/setup/ecmwf_physics_tail_fields.S. The caller validates complete
!! disjoint owners, empty NAEPHLI/NAMMETHOX groups, nearest-even rounding and
!! gradual underflow. Original OpenIFS modules supply type declarations only.
module ecmwf_physics_tail_fields_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yoewcou, only: tewcou
  use yoephli, only: tephli
  use yophnc, only: tphnc
  use yoelwrad, only: telwrad
  implicit none
  private
  public :: physics_tail_upstream_record, methane_oxidation_parameter_record
  public :: initialize_wave_coupling_fields
  public :: initialize_linearized_physics_fields
  public :: initialize_methane_oxidation_fields

  !> Read-only startup values supplied by their native upstream owners.
  !! NINDAT is an eight-digit YYYYMMDD date. NSSSSS is 0 through 86399 seconds
  !! after midnight. NOVLP selects cloud overlap. The logical controls retain
  !! their original names. RTWAT and RTICE are temperatures in kelvin (K), with
  !! 0 < RTICE <= RTWAT <= 400. This type contains no model-global state.
  type :: physics_tail_upstream_record
    integer(int32) :: nindat, nsssss
    logical :: lemwave, lvdftraj, lrrtm
    integer(int32) :: novlp
    real(real64) :: rtwat, rtice
  end type physics_tail_upstream_record

  !> Owned methane-oxidation and water-photolysis parameters, all FP64.
  !! RALPHA1/2/3 and RLOGPPH are dimensionless coefficients. RQLIM is the
  !! dimensionless specific-humidity limit. The four pressure limits are in
  !! pascals (Pa). The caller owns this record; the module has no saved copy.
  type :: methane_oxidation_parameter_record
    real(real64) :: ralpha1, ralpha2, rqlim
    real(real64) :: rpbotox, rpbotph, rptopox, rptopph
    real(real64) :: ralpha3, rlogpph
  end type methane_oxidation_parameter_record

  interface
    function selected_public_log(value) bind(C, name="log") result(logarithm)
      import :: c_double
      real(c_double), value, intent(in) :: value
      real(c_double) :: logarithm
    end function selected_public_log
  end interface

contains

  !> Apply SUWCOU defaults and write the native fourteen-character start date.
  !! UPSTREAM is read only. OUTPUT is the native TEWCOU record and is changed
  !! only in RMISSW, NLONW, NLATW, NGRIB_HANDLE_FOR_WAM and CBEGDAT.
  !! CBEGDAT(1:8) reproduces I8 and CBEGDAT(9:14) reproduces I6.6 for the
  !! admitted date and clock domains. All descriptors and other fields retain
  !! their incoming bits. No formatted I/O or TRIP record is required.
  subroutine initialize_wave_coupling_fields(upstream, output)
    type(physics_tail_upstream_record), intent(in) :: upstream
    type(tewcou), intent(inout) :: output
    integer(int32) :: hours, hour_remainder, minutes, seconds, clock
    integer(int32) :: date_digits, time_digits, quotient, digit, position
    real(real64) :: minute_ratio

    output%rmissw = -999.0_real64
    output%nlonw = 1_int32
    output%nlatw = 1_int32
    output%ngrib_handle_for_wam = -99_int32
    hours = upstream%nsssss/3600_int32
    hour_remainder = upstream%nsssss - hours*3600_int32
    minute_ratio = real(hour_remainder, real64)/60.0_real64
    minutes = int(minute_ratio, kind=int32)
    seconds = hour_remainder - minutes*60_int32
    clock = hours*10000_int32 + minutes*100_int32
    clock = clock + seconds

    date_digits = upstream%nindat
    do position = 8_int32, 1_int32, -1_int32
      quotient = date_digits/10_int32
      digit = date_digits - quotient*10_int32
      output%cbegdat(position:position) = achar(48_int32 + digit)
      date_digits = quotient
    end do
    time_digits = clock
    do position = 14_int32, 9_int32, -1_int32
      quotient = time_digits/10_int32
      digit = time_digits - quotient*10_int32
      output%cbegdat(position:position) = achar(48_int32 + digit)
      time_digits = quotient
    end do
  end subroutine initialize_wave_coupling_fields

  !> Set selected SUPHLI defaults and related native radiation switches.
  !! UPSTREAM is read only. OUTPUT, PHYSICS_CONTROLS and LONGWAVE_CONTROLS are
  !! native TEPHLI, TPHNC and TELWRAD records with intent INOUT. The caller
  !! admits PHYSICS_CONTROLS%LERADLW2 false, so no atmosphere-height array is
  !! consumed. Live LERADI2 is read and preserved. LENOPERT, padding and every
  !! field outside the selected stores retain their incoming bits. RLPTRC is
  !! in kelvin, RLPMIXL is in metres and RLPP00 is in pascals.
  subroutine initialize_linearized_physics_fields( &
    upstream, output, physics_controls, longwave_controls)
    type(physics_tail_upstream_record), intent(in) :: upstream
    type(tephli), intent(inout) :: output
    type(tphnc), intent(inout) :: physics_controls
    type(telwrad), intent(inout) :: longwave_controls
    real(real64) :: temperature_difference, scaled_difference

    output%ltlevol = .false.
    output%lphylin = .false.
    output%lphysfclin = .false.
    output%lopptwins = .false.
    output%leppcfls = upstream%lemwave .or. upstream%lvdftraj
    temperature_difference = upstream%rtwat - upstream%rtice
    scaled_difference = temperature_difference/1.4142135623730951_real64
    output%rlptrc = upstream%rtice + scaled_difference
    output%rlpal1 = 0.15_real64
    output%rlpal2 = 20.0_real64
    output%rlpbb = 5.0_real64
    output%rlpcc = 5.0_real64
    output%rlpdd = 5.0_real64
    output%rlpmixl = 4000.0_real64
    output%rlpbeta = 0.2_real64
    output%rlpdrag = 0.0_real64
    output%rlpevap = 0.0_real64
    output%rlpp00 = 30000.0_real64
    output%lraisanen = upstream%lrrtm .and. upstream%novlp == 1_int32
    physics_controls%lh2oco2 = physics_controls%leradi2
    physics_controls%lwlopt = physics_controls%leradi2
    physics_controls%lwsopt = physics_controls%leradi2
    longwave_controls%nlevlwc = 5_int32
  end subroutine initialize_linearized_physics_fields

  !> Set all nine owned SUMETHOX parameters with the frozen literal bits.
  !! OUTPUT is changed field by field. The eight literal-expression words
  !! come from methane_source_constants.inc.S; the fourth power in RALPHA1
  !! has its original single constant-expression rounding. The RALPHA3 add
  !! and half multiply remain separate, followed by pressure division and the
  !! public C LOG service. Volatile operands retain these runtime operations.
  !! Link LOG to the accepted strict-math/libpressure-math.so provider and
  !! verify its actual binding in the independent enclosing comparison.
  subroutine initialize_methane_oxidation_fields(output)
    type(methane_oxidation_parameter_record), intent(inout) :: output
    real(real64), volatile :: alpha_reference, alpha_sum
    real(real64), volatile :: top_pressure, bottom_pressure
    real(real64) :: pressure_ratio

    output%ralpha1 = transfer(int(z'3fe161de809d4f32', int64), 0.0_real64)
    output%ralpha2 = transfer(int(z'bff11ad7d41e07b1', int64), 0.0_real64)
    output%rqlim = transfer(int(z'3ed42cb2bb7e9bbc', int64), 0.0_real64)
    output%rpbotox = transfer(int(z'40c3880000000000', int64), 0.0_real64)
    output%rpbotph = transfer(int(z'4034000000000000', int64), 0.0_real64)
    output%rptopox = transfer(int(z'4049000000000000', int64), 0.0_real64)
    output%rptopph = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
    alpha_reference = transfer(int(z'40126bb1bbb55516', int64), 0.0_real64)
    alpha_sum = alpha_reference + output%ralpha2
    output%ralpha3 = 0.5_real64*alpha_sum
    top_pressure = output%rptopph
    bottom_pressure = output%rpbotph
    pressure_ratio = top_pressure/bottom_pressure
    output%rlogpph = selected_public_log(pressure_ratio)
  end subroutine initialize_methane_oxidation_fields

end module ecmwf_physics_tail_fields_mod
