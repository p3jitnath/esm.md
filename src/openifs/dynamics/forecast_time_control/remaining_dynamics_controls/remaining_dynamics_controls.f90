!> Complete the remaining SUDYN controls after admitted trajectory setup.
module forecast_remaining_dynamics_controls
  use iso_c_binding, only: c_int, c_int64_t
  use forecast_reference_pressure_coefficients, only: reference_atmosphere_values
  implicit none
  private
  public :: native_remaining_dynamics_controls, complete_admitted_dynamics_controls
  !> Own source control words that have no other live producer.
 !! NSITER and NGPMASCOR are dimensionless counts. Logical fields are switches.
  type :: native_remaining_dynamics_controls
    integer(c_int) :: nsiter, ngpmascor
    logical :: lmasdry, lgpmascor, lstrhd
    logical :: ready = .false.
  end type
contains
  !> Finish the actual global ECMWF branch from produced setup records.
 !! UPSTREAM_READY means the real operational trajectory initializer succeeded.
 !! Its admitted NAMDYN grammar contains only NITMP and LMASCOR, so it cannot
 !! override these NSITER, LMASDRY, LGPMASCOR and NGPMASCOR source defaults.
 !! NCONF is the model configuration and NSTOP is its total step count.
 !! REFERENCE is the same produced reference-atmosphere record. Its geometry
 !! classification already follows the ordered stretch calculation in SUDYN.
 !! OUTPUT stays at the caller's final TARGET address. Status2 preserves it;
 !! status0 writes every named source field and then publishes readiness.
  integer(c_int) function complete_admitted_dynamics_controls(upstream_ready, nconf, nstop, reference, output) result(status)
    logical, intent(in) :: upstream_ready
    integer(c_int), intent(in) :: nconf, nstop
    type(reference_atmosphere_values), intent(in) :: reference
    type(native_remaining_dynamics_controls), intent(inout) :: output
    status = 2_c_int
    if (.not. upstream_ready) return
    if (nconf /= 1_c_int .or. nstop < 1_c_int .or. nstop > 576_c_int) return
    if (reference%limited_area /= 0_c_int) return
    if (reference%stretched_grid < 0_c_int .or. reference%stretched_grid > 1_c_int) return
    output%nsiter = 0_c_int
    output%lmasdry = .false.
    output%lgpmascor = .false.
    output%ngpmascor = 0_c_int
    output%lstrhd = reference%stretched_grid /= 0_c_int
    output%ready = .true.
    status = 0_c_int
  end function
end module forecast_remaining_dynamics_controls
