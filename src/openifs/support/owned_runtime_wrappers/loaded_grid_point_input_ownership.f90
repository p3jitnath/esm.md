!> Retain the loaded input cohort and its native startup/model lifetimes.
module forecast_loaded_grid_point_input_ownership
  use iso_fortran_env, only: int32
  use mpi_f08
  use forecast_initial_geometry_state, only: native_initial_geometry_state, &
                                             initialize_initial_geometry_state, release_initial_geometry_state
  use forecast_source_ordered_operational_input, only: native_initialized_operational_model_state, &
            native_initialized_operational_input_budget, create_initialized_operational_model, release_initialized_operational_model
  use forecast_native_input_memory, only: native_input_memory_policy
  implicit none
  private
  public :: native_loaded_grid_point_inputs, create_loaded_grid_point_inputs, release_loaded_grid_point_inputs
  !> The canonical INITIAL owns startup and geometry once; MODEL borrows it.
 !! This native composition replaces three raw pointer slots and fifteen raw
 !! alias destinations with their actual named model owners and associations.
  type :: native_loaded_grid_point_inputs
    type(native_initial_geometry_state), allocatable :: initial
    type(native_initialized_operational_model_state), allocatable :: model
    integer(int32) :: phase = 0, last_status = 0
  end type
contains
  !> Complete the actual startup/geometry producer before the initialized model.
 !! Paths use1:4095 non-NUL characters. BUDGET gives per-rank byte capacities.
 !! WORLD is the actual public communicator; the qualified source route has4
 !! processes. No private geometry, preloaded model or omitted numerical stage
 !! is supplied by a caller. OUTPUT remains fixed while model aliases are live.
 !! A later failure keeps successfully reached upstream owners for RELEASE.
 !! The canonical initial child retains its own transactional failure policy.
  integer(int32) function create_loaded_grid_point_inputs(world, spectral_path, surface_path, upper_air_path, &
                           namelist_path, budget, memory_policy, resource_prefix, output, child_status, failed_stage) result(status)
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, namelist_path, resource_prefix
    type(native_initialized_operational_input_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    type(native_loaded_grid_point_inputs), allocatable, target, intent(inout) :: output
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: detail
    integer :: allocation_status
    status = 2; child_status = 2; failed_stage = 0
    if (allocated(output)) return
    if (.not. path_admitted(spectral_path) .or. .not. path_admitted(surface_path)) return
    if (.not. path_admitted(upper_air_path) .or. .not. path_admitted(namelist_path)) return
    allocate (output, stat=allocation_status)
    status = 1; child_status = allocation_status
    if (allocation_status /= 0) return
    failed_stage = 1
    status = initialize_initial_geometry_state(output%initial, namelist_path, spectral_path, surface_path, &
                                               4_int32, 1_int32, 0_int32, child_status, detail)
    output%last_status = status
    if (status /= 0) return
    output%phase = 2; failed_stage = 3
    status = create_initialized_operational_model(output%initial, world, spectral_path, surface_path, upper_air_path, &
                                                  budget, memory_policy, resource_prefix, output%model, child_status, detail)
    output%last_status = status
    if (status /= 0) return
    output%phase = 3; failed_stage = 0; child_status = 0
  end function
  !> Retire every model borrower before geometry and startup are released.
 !! Empty release succeeds. A refused child leaves its remaining owner live.
  integer(int32) function release_loaded_grid_point_inputs(output) result(status)
    type(native_loaded_grid_point_inputs), allocatable, target, intent(inout) :: output
    status = 0
    if (.not. allocated(output)) return
    status = release_initialized_operational_model(output%model)
    if (status /= 0) return
    status = release_initial_geometry_state(output%initial)
    if (status /= 0) return
    deallocate (output)
  end function
  logical function path_admitted(path) result(valid)
    character(*), intent(in) :: path
    valid = len(path) >= 1 .and. len(path) <= 4095
    if (valid) valid = index(path, achar(0)) == 0
  end function
end module
