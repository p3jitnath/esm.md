!> Continue real field loading after the canonical physics setup.
module forecast_loaded_field_continuation
  use iso_fortran_env, only: int32, int64
  use mpi_f08, only: MPI_Comm
  use forecast_loaded_operational_model, only: native_loaded_operational_model_state, native_loaded_operational_input_budget, &
                         prepare_operational_input_work, prepare_operational_input_spectral, initialize_operational_input_surface, &
                          initialize_operational_input_upper_air, prepare_operational_input_next_time, agree_input_controller_status
  use forecast_native_input_memory, only: native_input_memory_policy
  use forecast_initial_spectral_norm_join, only: native_initial_spectral_norm_state, compute_initial_input_spectral_norms
  implicit none
  private
  public :: load_actual_forecast_fields_after_physics_setup
contains
  !> Consume the same final-address model, fields, input and norm owners.
  !! The caller has completed actual physics setup and the source Lagrangian
  !! producer. This function creates no replacement model or parameter owner.
  !! NORM was allocated before model stage10. Paths name the genuine spectral,
  !! surface and upper-air files. BUDGET and NORM_BYTES are admitted byte
  !! capacities. Each allocating loader samples its current process memory.
  !! All ranks enter together. Every reached child result is agreed before
  !! the next stage. No failed child is hidden by a readiness assignment.
  !! Success completes stages30:120. Failure keeps the actual reached prefix;
  !! the enclosing owner must release that prefix before closing geometry.
integer(int32) function load_actual_forecast_fields_after_physics_setup(state, world, spectral_path, surface_path, upper_air_path, &
                                budget, memory_policy, journal_prefix, norm_bytes, norms, child_status, failed_stage) result(status)
    type(native_loaded_operational_model_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, journal_prefix
    type(native_loaded_operational_input_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    integer(int64), intent(in) :: norm_bytes
    type(native_initial_spectral_norm_state), target, intent(inout) :: norms
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local
    local = 2; failed_stage = 0; child_status = 2
    admission: block
      if (state%ready .or. .not. allocated(state%storage) .or. .not. allocated(state%input)) exit admission
      if (.not. associated(state%fields)) exit admission
      if (.not. state%storage%model%ready .or. .not. associated(state%storage%model%initial)) exit admission
      if (.not. associated(state%input%model, state%storage%model)) exit admission
      if (.not. associated(state%input%field_context, state%fields)) exit admission
      if (.not. state%storage%ecmwf%setup_complete) exit admission
      if (state%input%phase /= 25) exit admission
      if (.not. allocated(norms%values) .or. norms%ready) exit admission
      if (norm_bytes < 1_int64 .or. norm_bytes > 2_int64**36) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    local = prepare_operational_input_work(state%input, state%dynamic, state%next, world, budget%work_bytes, failed_stage)
    state%phase = failed_stage
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    local = prepare_operational_input_spectral(state%input, world, spectral_path, budget%input, memory_policy, &
                                               journal_prefix, failed_stage, child_status)
    state%phase = failed_stage
    status = agree_input_controller_status(world, local)
    if (status /= 0) return
    failed_stage = 90; state%phase = 90
    local = initialize_operational_input_surface(state%input, world, surface_path, memory_policy, journal_prefix)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 100; state%phase = 100
    local=initialize_operational_input_upper_air(state%input,world,upper_air_path,budget%input,memory_policy,journal_prefix,child_status)
    status = agree_input_controller_status(world, local)
    if (status /= 0) return
    failed_stage = 110; state%phase = 110
    local = prepare_operational_input_next_time(state%input)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 120; state%phase = 120
    local = compute_initial_input_spectral_norms(state%storage%model, state%input%spectral, world, norm_bytes, norms)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%input%phase = 120; state%input%ready = .true.
    state%ready = .true.; failed_stage = 0; child_status = 0; status = 0
  end function
end module forecast_loaded_field_continuation
