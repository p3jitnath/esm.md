!> Keep one canonical model/FIELDS cohort for all distributed storage stages.
module forecast_distributed_operational_model_owner
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  use forecast_loaded_operational_model, only: native_loaded_operational_model_state, &
                  release_operational_input_payload, initialize_operational_input_surface, initialize_operational_input_upper_air, &
                                               operational_input_borrowers_are_detached
  use forecast_selected_model_storage, only: create_selected_model_storage, release_selected_model_storage
  use forecast_initial_fields_storage, only: create_initial_fields_storage, release_initial_fields_storage
  use forecast_in_place_model_configuration, only: initialize_operational_model_configuration_in_place
  use forecast_operational_model_configuration, only: associate_operational_model_partition
  use forecast_staged_work_storage, only: create_distributed_forecast_work_storage, &
                                          advance_forecast_work_storage, release_forecast_work_storage
  use forecast_grid_motion_setup, only: native_grid_motion_controls
  use forecast_distributed_grid_motion_storage, only: allocate_distributed_grid_motion_fields
  use owned_distributed_spectral_field_storage_port, only: initialize_owned_distributed_spectral_field
  use forecast_native_initial_field_loading, only: load_native_initial_spectral_fields
  use forecast_runtime_operational_input, only: native_operational_input_budget
  use forecast_native_input_memory, only: native_input_memory_policy
  use partitioned_surface_state_startup_port, only: clear_surface_physics_descriptions
  implicit none
  private
  public :: native_distributed_operational_model_owner
  public :: create_distributed_operational_model_storage, release_distributed_operational_model_storage
  public :: attach_distributed_operational_model_configuration
  public :: begin_distributed_operational_model_work_storage, advance_distributed_operational_model_work_storage
  public :: allocate_distributed_operational_model_grid_motion, initialize_distributed_operational_model_spectral
  public :: load_distributed_operational_model_spectral_state, initialize_distributed_operational_model_surface
  public :: load_distributed_operational_model_upper_air_state
  !> State owns one model and FIELDS. INPUT owns each actual numerical array once.
 !! INITIAL remains borrowed and outlives this record; no native owner is copied.
  type :: native_distributed_operational_model_owner
    type(native_loaded_operational_model_state) :: state
    type(native_initial_geometry_state), pointer :: initial => null()
    type(MPI_Comm) :: world = MPI_COMM_NULL
    logical :: attached = .false., motion_ready = .false., spectral_ready = .false.
    logical :: surface_ready = .false., upper_ready = .false.
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate final-address records, then MODEL and FIELDS, without configuration.
 !! WORLD and INITIAL are genuine produced objects. All alias readers detach
 !! before release. Native aliases are named associations, not writable raw slots.
 !! Pure storage calls preserve incoming IEEE and errno; file stages retain
 !! their natural child status. Return0, allocation1 or atomic admission2.
  integer(int32) function create_distributed_operational_model_storage(initial, world, output) result(status)
    type(native_initial_geometry_state), target, intent(inout) :: initial
    type(MPI_Comm), intent(in) :: world
    type(native_distributed_operational_model_owner), allocatable, target, intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: allocation_status
    integer(int32) :: ignored
    status = 2
    if (allocated(output) .or. .not. initial%ready) return
    if (.not. allocated(initial%geometry)) return
    if (.not. initial%geometry%initialized) return
    call ieee_get_status(saved); call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    allocate (output, stat=allocation_status)
    status = 1
    if (allocation_status /= 0) goto900
    output%initial => initial; output%world = world
    status = create_selected_model_storage(output%state%storage, initial)
    if (status /= 0) goto800
    status = create_initial_fields_storage(output%state%storage%model, output%state%fields)
    if (status /= 0) goto800
    allocate (output%state%input, stat=allocation_status)
    status = 1
    if (allocation_status /= 0) goto800
    output%state%input%model => output%state%storage%model
    output%state%input%field_context => output%state%fields
    output%state%input%world = world
    call clear_surface_physics_descriptions(output%state%input%surface_descriptions)
    output%state%phase = 10; status = 0
    goto900
800 if (associated(output%state%fields)) ignored = release_initial_fields_storage(output%state%fields)
    if (allocated(output%state%storage)) ignored = release_selected_model_storage(output%state%storage)
    if (allocated(output%state%input)) deallocate (output%state%input)
    deallocate (output)
900 call ieee_set_status(saved); error_number = saved_errno
  end function
  !> Attach actual source configuration, then the same live partition.
 !! No earlier/later producer is inferred from fresh or zero-filled bytes.
  integer(int32) function attach_distributed_operational_model_configuration(owner, child_status, failed_stage) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    integer(int32), intent(out) :: child_status, failed_stage
    status = 2; child_status = 2; failed_stage = 20
    if (.not. base_valid(owner) .or. owner%attached) return
  status = initialize_operational_model_configuration_in_place(owner%state%storage%model, owner%initial, child_status, failed_stage)
    if (status /= 0) return
    status = associate_operational_model_partition(owner%state%storage%model, owner%initial%geometry%partition)
    child_status = status
    if (status == 0) then
      owner%attached = .true.; owner%state%phase = 20; failed_stage = 0
    end if
  end function
  !> Create only the first source work stage. Subsequent advances stay explicit.
  integer(int32) function begin_distributed_operational_model_work_storage(owner, byte_limit) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    integer(int64), intent(in) :: byte_limit
    status = 2
    if (.not. configured_valid(owner)) return
    if (allocated(owner%state%input%work)) return
    status = create_distributed_forecast_work_storage(owner%state%input%work, owner%state%storage%model, &
                                                      owner%state%dynamic, owner%state%next, byte_limit)
  end function
  integer(int32) function advance_distributed_operational_model_work_storage(owner) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    status = 2
    if (.not. configured_valid(owner)) return
    if (.not. allocated(owner%state%input%work)) return
    status = advance_forecast_work_storage(owner%state%input%work)
  end function
  !> Allocate GMV then GMVS through their genuine live dimensions and source maps.
  integer(int32) function allocate_distributed_operational_model_grid_motion(owner) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    type(native_grid_motion_controls) :: controls
    integer(int32) :: p, l, b, q
    status = 2
    if (.not. configured_valid(owner) .or. owner%motion_ready) return
    p = owner%initial%geometry%dimensions%nproma; l = owner%initial%geometry%dimensions%nflevg
    b = owner%initial%geometry%partition%ngpblks; q = owner%initial%geometry%partition%ngptot
    controls%nconf = owner%initial%controls%namespace%nconf
    controls%lecmwf = owner%initial%controls%namespace%lecmwf
    controls%lrshw = owner%initial%controls%namespace%lrshw
    controls%nundefld = owner%initial%controls%namespace%nundefld
    controls%ldtenc = 0; controls%nprintlev = 0
    status = allocate_distributed_grid_motion_fields(owner%state%storage%model%motion, p, l, b, q, &
                                           owner%state%storage%model%field_dimensions, owner%state%storage%model%dynamics, controls)
    if (status == 0) then
      owner%motion_ready = .true.; owner%state%input%owns_motion_spectral = .true.
    end if
  end function
  !> Allocate only spectral fields at the source position after motion storage.
 !! PARAMETER_IDS are the actual five input field identifiers; cap uses bytes.
  integer(int32) function initialize_distributed_operational_model_spectral(owner, parameter_ids, byte_limit) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    integer(int32), intent(in) :: parameter_ids(5)
    integer(int64), intent(in) :: byte_limit
    status = 2
    if (.not. configured_valid(owner) .or. owner%spectral_ready) return
    status = initialize_owned_distributed_spectral_field(owner%state%input%spectral, owner%initial%geometry%dimensions, &
          owner%initial%geometry%transform_control, owner%initial%geometry%transform_resolution, owner%initial%geometry%partition, &
                                                         owner%initial%geometry%laplacian, parameter_ids, byte_limit)
    if (status == 0) owner%spectral_ready = .true.
  end function
  !> Read the actual spectral file into the same live spectral owner.
  integer(int32) function load_distributed_operational_model_spectral_state(owner, path, metadata_byte_limit) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    character(*), intent(in) :: path
    integer(int64), intent(in) :: metadata_byte_limit
    status = 2
    if (.not. configured_valid(owner) .or. .not. owner%spectral_ready) return
    if (owner%state%input%loaded_orography /= 0) return
    status = load_native_initial_spectral_fields(owner%state%input%spectral, owner%world, path, &
                                                 owner%state%input%loaded_orography, metadata_byte_limit)
  end function
  !> Load surface fields only at their explicit source stage.
integer(int32) function initialize_distributed_operational_model_surface(owner, path, memory_policy, resource_prefix) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    character(*), intent(in) :: path, resource_prefix
    type(native_input_memory_policy), intent(in) :: memory_policy
    status = 2
    if (.not. configured_valid(owner) .or. owner%surface_ready) return
    status = initialize_operational_input_surface(owner%state%input, owner%world, path, memory_policy, resource_prefix)
    if (status == 0) owner%surface_ready = .true.
  end function
  !> Allocate and decode upper air through the actual bounded node decoder.
 !! BUDGET is the produced per-rank field capacity. The child owns batch order.
  integer(int32) function load_distributed_operational_model_upper_air_state(owner, path, budget, memory_policy, &
                                                                             resource_prefix, child_status) result(status)
    type(native_distributed_operational_model_owner), target, intent(inout) :: owner
    character(*), intent(in) :: path, resource_prefix
    type(native_operational_input_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    integer(int32), intent(out) :: child_status
    status = 2; child_status = 2
    if (.not. configured_valid(owner) .or. owner%upper_ready) return
 status=initialize_operational_input_upper_air(owner%state%input,owner%world,path,budget,memory_policy,resource_prefix,child_status)
    if (status == 0) owner%upper_ready = .true.
  end function
  !> Release work, motion, surface, spectral, upper air, FIELDS and MODEL.
 !! The canonical release child retires its concrete payloads in source order.
 !! Every borrowed field container must have detached before this entry.
  integer(int32) function release_distributed_operational_model_storage(output) result(status)
    type(native_distributed_operational_model_owner), allocatable, target, intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    status = 0
    if (.not. allocated(output)) return
    status = 2
    if (.not. base_valid(output)) return
    if (.not. operational_input_borrowers_are_detached(output%state%fields)) return
    call ieee_get_status(saved); call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    status = release_operational_input_payload(output%state%input)
    if (status /= 0) goto900
    status = release_initial_fields_storage(output%state%fields)
    if (status /= 0) goto900
    status = release_selected_model_storage(output%state%storage)
    if (status /= 0) goto900
    deallocate (output)
900 call ieee_set_status(saved); error_number = saved_errno
  end function
  logical function base_valid(owner) result(valid)
    type(native_distributed_operational_model_owner), target, intent(in) :: owner
    valid = .false.
    if (.not. associated(owner%initial)) return
    if (.not. allocated(owner%initial%geometry)) return
    if (.not. allocated(owner%state%storage) .or. .not. associated(owner%state%fields)) return
    if (.not. associated(owner%state%storage%model%initial, owner%initial)) return
    if (.not. allocated(owner%state%input)) return
    if (.not. associated(owner%state%input%model, owner%state%storage%model)) return
    if (.not. associated(owner%state%input%field_context, owner%state%fields)) return
    valid = .true.
  end function
  logical function configured_valid(owner) result(valid)
    type(native_distributed_operational_model_owner), target, intent(in) :: owner
    valid = .false.
    if (.not. base_valid(owner)) return
    if (.not. owner%attached .or. .not. owner%state%storage%model%ready) return
    if (.not. associated(owner%state%storage%model%partition, owner%initial%geometry%partition)) return
    valid = .true.
  end function
end module
