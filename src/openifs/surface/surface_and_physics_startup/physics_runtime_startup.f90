!> Keep the canonical SUPHEC control record and initial physics interval.
module forecast_physics_runtime_startup
  use iso_fortran_env, only: int32, real64
  use ecmwf_physics_control_fields_port, only: physics_runtime_inputs, initialize_ecmwf_physics_runtime_inputs
  use yomphy2, only: tphy2
  implicit none
  private
  public :: initialize_canonical_physics_runtime, initialize_initial_physics_interval
contains
  !> OUTPUT is the one caller-owned runtime-input record. The qualified
  !! child defines its five named members; no duplicate module state exists.
  integer(int32) function initialize_canonical_physics_runtime(output) result(status)
    type(physics_runtime_inputs), intent(inout) :: output
    status = initialize_ecmwf_physics_runtime_inputs(output)
  end function
  !> Set only the source TSPHY member to exactly one second.
  integer(int32) function initialize_initial_physics_interval(output) result(status)
    type(tphy2), intent(inout) :: output
    output%tsphy = 1.0_real64
    status = 0
  end function
end module
