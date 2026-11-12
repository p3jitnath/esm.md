!> Initialize the selected gravity-wave parameter records with native types.
!! The caller supplies admitted owners, round-to-nearest arithmetic and gradual
!! underflow. Pressure and boundary A coefficients are in pascals (Pa); boundary
!! B coefficients are dimensionless. All times are in seconds.
!!
!! These calculations retain the generated SUGWD and SUGWWMS operation order in
!! src/openifs/setup/shared_cloud_gravity_wave_parameter_fields.inc.S.
!! The original OpenIFS modules supply type declarations only. The selected
!! numerical contract is cloud_gravity_wave_setup.md and its two runtime
!! gravity-wave parameter contracts under skills/md2fort/references/openifs/setup.
module gravity_wave_parameter_fields_mod
  use iso_fortran_env, only: real64, int32
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
  implicit none
  private
  public :: initialize_orographic_gravity_wave_fields
  public :: initialize_nonorographic_gravity_wave_fields

contains

  !> Set the SUGWD parameters for mountain-generated gravity waves.
  !! OUTPUT is the native TEGWD record and is changed field by field. PRESSURE
  !! has L elements, VAH and VBH have L+1 consumed elements, and L is 2 through
  !! 512. RHOUR is the positive hour length in seconds. LEPHYS selects the
  !! physics limiter. The caller checks domains, bounds and disjoint ownership.
  !! The compiler owns an L-element midpoint workspace; compile this routine
  !! with stack arrays. No original numerical routine or global data is used.
  subroutine initialize_orographic_gravity_wave_fields( &
    output, pressure, vah, vbh, rhour, lephys)
    type(tegwd), intent(inout) :: output
    real(real64), intent(in) :: pressure(:), vah(:), vbh(:), rhour
    logical, intent(in) :: lephys
    real(real64) :: midpoint(size(pressure))
    real(real64) :: boundary_a_sum, boundary_b_sum, reference_b_term
    real(real64) :: boundary_pressure_sum, midpoint_ratio, limiter_pressure
    real(real64), volatile :: tendency
    integer(int32) :: levels, level

    levels = size(pressure, kind=int32)
    output%nktopg = levels
    do level = levels, 1_int32, -1_int32
      boundary_a_sum = vah(level) + vah(level + 1_int32)
      boundary_b_sum = vbh(level) + vbh(level + 1_int32)
      reference_b_term = 80000.0_real64*boundary_b_sum
      boundary_pressure_sum = boundary_a_sum + reference_b_term
      midpoint(level) = 0.5_real64*boundary_pressure_sum
      midpoint_ratio = midpoint(level)/80000.0_real64
      if (midpoint_ratio >= 0.94_real64) output%nktopg = level
    end do

    output%grfplm = 9.9_real64
    output%ngwdtop = 1_int32
    do level = 1_int32, levels
      if (midpoint(level) < 9.9_real64) output%ngwdtop = level
    end do

    output%gkdrag = 0.3_real64
    output%gkwake = 1.0_real64
    output%gkdrag = 0.15_real64
    output%gkwake = 3.0_real64
    output%grcrit = 0.25_real64
    output%gfrcrit = 0.40_real64
    output%gvsec = 0.10_real64
    output%gssec = 1.0e-12_real64
    output%gtsec = 1.0e-7_real64
    output%ngwdlim = 0_int32
    limiter_pressure = 1000.0_real64
    if (levels > 19_int32) limiter_pressure = 5000.0_real64
    do level = levels, 1_int32, -1_int32
      if (pressure(level) >= limiter_pressure) output%ngwdlim = level
    end do
    if (.not. lephys) output%ngwdlim = 0_int32

    ! Retain both rounded divisions, including the overwritten first value.
    tendency = 20.0_real64/rhour
    output%gtenlim = tendency
    tendency = 80.0_real64/rhour
    output%gtenlim = tendency
    output%lrdiff_strato = .false.
    output%ndiff_strato = 5_int32
    output%ldiag_strato = .false.
  end subroutine initialize_orographic_gravity_wave_fields

  !> Set the selected one-launch SUGWWMS wave-spectrum parameters.
  !! OUTPUT is the native TEGWWMS record and is changed field by field.
  !! PRESSURE has L elements in Pa, with L from 2 through 512. RHOUR and
  !! TIMESTEP are positive times in seconds. The caller admits their domains,
  !! bounds and disjoint ownership, configuration 1 and an empty NAMGWWMS.
  !! GMSTAR_L(2:3) and record padding retain their incoming bits. The momentum
  !! flux has units Pa, GMSTAR_L(1) is a length in metres, and the frequency
  !! field is a time interval in seconds. Gaussian widths are in degrees.
  subroutine initialize_nonorographic_gravity_wave_fields( &
    output, pressure, rhour, timestep)
    type(tegwwms), intent(inout) :: output
    real(real64), intent(in) :: pressure(:), rhour, timestep
    real(real64) :: frequency, period_ratio, complete_periods
    integer(int32) :: levels, level, period_count

    levels = size(pressure, kind=int32)
    output%nlaunchlev = 1_int32
    output%gfluxlaun = 0.00375_real64
    output%gfluxlaunl(1) = output%gfluxlaun
    output%gfluxlaunl(2) = 0.0_real64
    output%gfluxlaunl(3) = 0.0_real64
    output%gcstar = 1.0_real64
    output%gmstar_l(1) = 2000.0_real64
    output%nslope = 1_int32
    output%gptwo = 2.0_real64
    output%lozpr = .true.
    output%ngauss = 2_int32
    output%ggaussa = 20.0_real64
    output%ggaussb(1) = -0.25_real64
    output%ggaussb(2) = -0.25_real64
    output%ggaussb(3) = -0.25_real64
    output%gcoeff = 2000.0_real64
    output%lgacalc = .false.
    output%lgsatl = .false.
    output%lgindl = .false.

    frequency = rhour
    if (timestep >= rhour) frequency = 2.0_real64*timestep
    output%gtphygwwms = frequency
    period_ratio = frequency/timestep
    period_count = int(period_ratio, kind=int32)
    complete_periods = real(period_count, kind=real64)
    frequency = complete_periods*timestep
    output%gtphygwwms = frequency
    output%gfluxlaunl(1) = output%gfluxlaun

    output%nlaunchl(1) = levels - 1_int32
    output%nlaunchl(2) = levels - 1_int32
    output%nlaunchl(3) = levels - 1_int32
    do level = levels, 2_int32, -1_int32
      if (pressure(level) > 45000.0_real64) output%nlaunchl(1) = level
      if (pressure(level) > 70000.0_real64) output%nlaunchl(2) = level
      if (pressure(level) > 20000.0_real64) output%nlaunchl(3) = level
    end do
    output%nlaunch = output%nlaunchl(1)
  end subroutine initialize_nonorographic_gravity_wave_fields

end module gravity_wave_parameter_fields_mod
