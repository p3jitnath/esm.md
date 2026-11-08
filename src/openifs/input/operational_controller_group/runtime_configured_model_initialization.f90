module forecast_runtime_configured_model_initialization
  !! Create one configured operational model and its complete initial fields.
  !! Named native owners replace private startup,alias and result byte records.
  use iso_fortran_env, only: int32, int64
  use mpi_f08
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_loaded_operational_model, only: native_loaded_operational_model_state, native_loaded_operational_input_budget, &
                                               create_operational_input_model_storage, agree_input_controller_status
  use forecast_source_ordered_operational_input, only: complete_operational_model_initialization, &
                                                       release_operational_model_initialization_contents
  use forecast_initial_spectral_norm_join, only: native_initial_spectral_norm_state, &
                                                 prepare_initial_input_spectral_norms
  use forecast_native_input_memory, only: native_input_memory_policy
  implicit none
  private
  public :: native_runtime_configured_initialized_model
  public :: create_runtime_configured_initialized_operational_model
  public :: release_runtime_configured_initialized_operational_model, operational_initial_norm_result_bytes
  type :: native_runtime_configured_initialized_model
    !! One final-address selected MODEL owns all aliases and physical records.
    !! INITIAL stays borrowed and live through release. NORM storage precedes
    !! factory stage10,as in the source. All payload owners remain distinct.
    type(native_loaded_operational_model_state) :: state
    type(native_initial_spectral_norm_state) :: norms
    integer(int32) :: phase = 0, last_status = 0
    logical :: ready = .false.
  end type
contains
  integer(int32) function create_runtime_configured_initialized_operational_model(initial, world, &
                             spectral_path, surface_path, upper_air_path, budget, norm_byte_limit, memory_policy, resource_prefix, &
                                                                                  output, child_status, failed_stage) result(status)
    !! All ranks enter together with one actual initialized geometry and clock.
    !! The three paths identify genuine spectral,surface and upper-air files.
    !! BUDGET and NORM_BYTE_LIMIT are capacities in bytes,not measured peaks.
    !! OUTPUT is a fresh allocatable TARGET and is published after stage120.
    !! Each child uses its existing source arithmetic and field placement.
    !! Returning failure releases acquired owners in the source release order.
    !! The caller establishes nearest-even and gradual underflow once.
    type(native_initial_geometry_state), target, intent(inout) :: initial
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, resource_prefix
    type(native_loaded_operational_input_budget), intent(in) :: budget
    integer(int64), intent(in) :: norm_byte_limit
    type(native_input_memory_policy), intent(in) :: memory_policy
    type(native_runtime_configured_initialized_model), allocatable, target, intent(inout) :: output
    integer(int32), intent(out) :: child_status, failed_stage
    type(native_runtime_configured_initialized_model), allocatable, target :: pending
    integer(int32) :: local, ignored
    integer :: allocation_status, error, world_size
    local = 2; child_status = 2; failed_stage = 0
    if (allocated(output)) goto100
    if (.not. initial%ready .or. .not. allocated(initial%geometry)) goto100
    if (.not. allocated(initial%prefix)) goto100
    if (.not. initial%prefix%ready .or. .not. initial%geometry%initialized) goto100
    if (initial%geometry%dimensions%nsmax /= 1279 .or. initial%geometry%dimensions%nflevg /= 137) goto100
    if (initial%geometry%partition%phase /= 7 .or. initial%geometry%partition%ngptotg /= 6599680) goto100
    if (.not. valid_path(spectral_path) .or. .not. valid_path(surface_path) .or. .not. valid_path(upper_air_path)) goto100
    if (norm_byte_limit < operational_initial_norm_result_bytes(initial%geometry)) goto100
    local = 0
100 status = agree_input_controller_status(world, local)
    if (status /= 0) return
    call MPI_Comm_size(world, world_size, error)
    if (error /= MPI_SUCCESS) call MPI_Abort(world, 3, error)
    local = 2
    if (world_size >= 1 .and. world_size <= 32 .and. world_size == initial%geometry%transform_control%nproc) local = 0
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    allocate (pending, stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) then
      if (allocated(pending)) deallocate (pending)
      return
    end if
    status = prepare_initial_input_spectral_norms(world, initial%geometry%dimensions%nflevg, &
                                                  initial%geometry%dimensions%nsmax, norm_byte_limit, pending%norms)
    child_status = status
    if (status /= 0) goto900
    status = create_operational_input_model_storage(initial, world, pending%state, child_status, failed_stage)
    pending%phase = failed_stage
    if (status /= 0) then
      status = status + failed_stage
      goto900
    end if
    status = complete_operational_model_initialization(pending%state, pending%norms, world, &
                             spectral_path, surface_path, upper_air_path, budget, norm_byte_limit, memory_policy, resource_prefix, &
                                                       .true., child_status, failed_stage)
    pending%phase = failed_stage; pending%last_status = child_status
    if (status /= 0) goto900
    pending%phase = 120; pending%ready = .true.; pending%last_status = 0
    failed_stage = 0; child_status = 0
    call move_alloc(pending, output)
    return
900 ignored = release_runtime_configured_initialized_operational_model(pending)
  end function

  integer(int32) function release_runtime_configured_initialized_operational_model(output) result(status)
    !! Weather borrowers finish first. The common finalizer releases norm
    !! storage,terrain,halo,fields and the one selected MODEL in source order.
    type(native_runtime_configured_initialized_model), allocatable, target, intent(inout) :: output
    status = 0
    if (.not. allocated(output)) return
    status = release_operational_model_initialization_contents(output%state, output%norms)
    if (status /= 0) return
    deallocate (output)
  end function

  pure integer(int64) function operational_initial_norm_result_bytes(geometry) result(bytes)
    !! Return the original integer count48+32*L*(N+2),in bytes.
    !! L is the global layer count1:4096. N is truncation0:65534.
    !! Zero refuses invalid dimensions without floating-point work.
    type(native_geometry_state), intent(in) :: geometry
    integer(int64) :: levels, truncation
    bytes = 0
    levels = geometry%dimensions%nflevg; truncation = geometry%dimensions%nsmax
    if (levels < 1 .or. levels > 4096 .or. truncation < 0 .or. truncation > 65534) return
    bytes = 48_int64 + 32_int64*levels*(truncation + 2_int64)
  end function

  pure logical function valid_path(path)
    character(*), intent(in) :: path
    valid_path = .false.
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, achar(0)) /= 0) return
    valid_path = .true.
  end function
end module forecast_runtime_configured_model_initialization
