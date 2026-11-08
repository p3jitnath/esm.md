!> Keep the canonical forecast startup targets in one explicit lifetime.
module forecast_native_startup_storage
  use iso_fortran_env, only: int32, int64
  use mpi_f08
  use forecast_initial_geometry_state, only: native_initial_geometry_state, &
                                             initialize_initial_geometry_state, release_initial_geometry_state
  use forecast_loaded_operational_model, only: native_loaded_operational_model_state, &
                                               native_loaded_operational_input_budget, create_operational_input_model_storage, &
                                               create_operational_input_payload, initialize_operational_input_lagrangian, &
                                               release_operational_input_model_contents, agree_input_controller_status
  use forecast_initial_spectral_norm_join, only: native_initial_spectral_norm_state, &
                                                 prepare_initial_input_spectral_norms, release_initial_input_spectral_norms
  use forecast_native_loop_data, only: native_loop_data, release_selected_loop_data
  use forecast_runtime_loop_binding, only: initialize_runtime_loop_data
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  use forecast_runtime_scalar_data, only: initialize_runtime_forecast_scalar_data
  use forecast_model_time_and_forcing, only: native_time_and_forcing_context
  use forecast_time_and_forcing_context_lifetime, only: bind_time_and_forcing_context, release_time_and_forcing_context
  use ecmwf_physics_control_fields_port, only: physics_runtime_inputs
  use forecast_physics_runtime_startup, only: initialize_canonical_physics_runtime
  implicit none
  private
  public :: native_forecast_startup_storage, create_native_forecast_startup_storage
  public :: release_native_forecast_startup_storage
  !> Own each startup record once; all scientific views borrow these targets.
  !! The caller keeps the complete allocation TARGET until every borrower closes.
  !! Initial geometry contains the sole temporal model clock. FORCING contains
  !! the separate source radiation-angle outputs, not a replacement model clock.
  type :: native_forecast_startup_storage
    type(native_initial_geometry_state), allocatable :: initial
    type(native_initial_spectral_norm_state) :: norms
    type(native_loaded_operational_model_state) :: loaded
    type(native_loop_data) :: loop_data
    type(native_forecast_scalar_data) :: scalars
    type(native_time_and_forcing_context) :: forcing
    type(physics_runtime_inputs) :: runtime_controls
  end type
contains
  !> Create actual storage and metadata owners in their source order.
  !! WORLD is the live public MPI_COMM_WORLD with4 or32 processes.
  !! File paths use1:4095 characters; directory text uses1:480 characters.
  !! BUDGET, LOOP_BYTES and NORM_BYTES are readonly per-rank byte ceilings.
  !! OUTPUT starts unallocated and is allocated directly at its final address.
  !! On later failure it retains reached owners; FAILED_STAGE names that stage.
  !! Status and CHILD_STATUS are source child results. Return0 completes this
  !! factory only; physics, field loading, norms and forecast remain unclaimed.
  integer(int32) function create_native_forecast_startup_storage(world, spectral_path, surface_path, upper_air_path, &
              configuration_path, budget, loop_bytes, norm_bytes, data_directory, output, child_status, failed_stage) result(status)
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, configuration_path, data_directory
    type(native_loaded_operational_input_budget), intent(in) :: budget
    integer(int64), intent(in) :: loop_bytes, norm_bytes
    type(native_forecast_startup_storage), allocatable, target, intent(inout) :: output
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local, detail
    integer :: error, world_size, allocation_status, n
    logical :: active
    status = 2; child_status = 2; failed_stage = 1
    call MPI_Initialized(active, error)
    if (error /= MPI_SUCCESS .or. .not. active) return
    if (.not. (world == MPI_COMM_WORLD)) return
    call MPI_Comm_size(world, world_size, error)
    if (error /= MPI_SUCCESS) then
      child_status = error; return
    end if
    local = 2
    if (allocated(output)) goto100
    if (world_size /= 4 .and. world_size /= 32) goto100
    if (loop_bytes < 0_int64 .or. norm_bytes < 0_int64) goto100
    if (.not. valid_startup_path(spectral_path) .or. .not. valid_startup_path(surface_path)) goto100
    if (.not. valid_startup_path(upper_air_path) .or. .not. valid_startup_path(configuration_path)) goto100
    if (len_trim(data_directory) < 1 .or. len_trim(data_directory) > 480) goto100
    if (index(data_directory, achar(0)) /= 0) goto100
    local = 0
100 status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 2
    allocate (output, stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) then
      if (allocated(output)) deallocate (output)
      return
    end if
    failed_stage = 3
    status = initialize_initial_geometry_state(output%initial, configuration_path, spectral_path, surface_path, &
                                               int(world_size, int32), 1_int32, 0_int32, child_status, detail)
    if (status /= 0) return
    failed_stage = 4
    local = prepare_initial_input_spectral_norms(world, output%initial%geometry%dimensions%nflevg, &
                                                 output%initial%geometry%dimensions%nsmax, norm_bytes, output%norms)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 5
    status = create_operational_input_model_storage(output%initial, world, output%loaded, child_status, detail)
    if (status /= 0) return
    failed_stage = 6
    status = create_operational_input_payload(output%loaded%storage%model, output%loaded%fields, world, &
                                              spectral_path, surface_path, upper_air_path, budget, output%loaded%input)
    child_status = status
    if (status /= 0) return
    failed_stage = 7
    local = initialize_operational_input_lagrangian(output%loaded%input)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    output%loaded%input%phase = 25
    output%loaded%phase = 25
    failed_stage = 8
    local = initialize_canonical_physics_runtime(output%runtime_controls)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 9
    local = initialize_runtime_loop_data(output%loop_data, output%loaded%storage%model, loop_bytes)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 10
    n = output%initial%prefix%configuration_bytes
    local = initialize_runtime_forecast_scalar_data(output%initial%prefix%configuration_text(1:n), &
                            output%initial%controls%namespace, output%loop_data, output%loaded%storage%model%climate%cplng_active, &
                                     output%initial%geometry%partition, output%initial%geometry%transform_control, output%scalars, &
                                                    output%loaded%storage%model%dynamics%lgradsp)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 11
    local = bind_time_and_forcing_context(output%forcing, output%loaded%input%surface_arrays, &
                       output%loaded%input%surface_metadata, output%runtime_controls%lscmec, output%loop_data%lrlxg, data_directory)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    child_status = 0; failed_stage = 0
  end function

  !> Close actual child owners after every forecast borrower has detached.
  !! The operation is collective while the initial geometry owns public MPI.
  !! A refused child release retains OUTPUT and reports its source status.
  integer(int32) function release_native_forecast_startup_storage(output) result(status)
    type(native_forecast_startup_storage), allocatable, target, intent(inout) :: output
    status = 0
    if (.not. allocated(output)) return
    status = release_time_and_forcing_context(output%forcing)
    if (status /= 0) return
    status = release_selected_loop_data(output%loop_data)
    if (status /= 0) return
    status = release_initial_input_spectral_norms(output%norms)
    if (status /= 0) return
    status = release_operational_input_model_contents(output%loaded)
    if (status /= 0) return
    status = release_initial_geometry_state(output%initial)
    if (status /= 0) return
    deallocate (output)
  end function

  !> Admit a bounded file path before source child I/O can start.
  logical function valid_startup_path(path) result(valid)
    character(*), intent(in) :: path
    valid = len(path) >= 1 .and. len(path) <= 4095
    if (valid) valid = index(path, achar(0)) == 0
  end function
end module forecast_native_startup_storage
