module forecast_native_initial_field_loading
  !! Join the existing native owners at their actual input storage stages.
  !! The root controller calls these concrete stages between its terrain,
  !! surface, temperature-conversion and norm calculations in source order.
  !! This module creates no second model, geometry or partition aggregate.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_grid_motion_setup, only: native_grid_motion_controls, release_grid_motion_fields
  use forecast_distributed_grid_motion_storage, only: allocate_distributed_grid_motion_fields
  use spectral_field_storage_port, only: spectral_field_state
  use owned_distributed_spectral_field_storage_port, only: initialize_owned_distributed_spectral_field,release_distributed_spectral_field
  use owned_spectral_initial_loading_port, only: load_owned_streaming_spectral_state
  use gridpoint_field_storage_port, only: gridpoint_field_storage_is_fresh
  use partitioned_upper_air_input_owner_port, only: partitioned_upper_air_input_owner, upper_air_decoder_memory_admission, &
      initialize_partitioned_upper_air_input_owner, load_next_partitioned_upper_air_batch, release_partitioned_upper_air_input_owner
  use grid_field_native_thermal_metadata_port, only: export_grid_field_thermal_constituents, export_native_moist_air_constants
  use md2asm_moist_air_gas_properties, only: thermal_constituent, moist_air_constants
  use forecast_native_input_memory, only: native_input_memory_policy, native_input_memory_sample, &
         observe_native_input_memory, admit_native_input_payload, make_upper_air_memory_admission, record_native_input_memory_sample
  implicit none
  private
  public :: native_initial_field_storage_budget, prepare_native_initial_field_storage
  public :: load_native_initial_spectral_fields, prepare_native_initial_upper_air_storage
  public :: advance_native_initial_upper_air_input

  type :: native_initial_field_storage_budget
    !! Per-rank payload ceilings, in bytes, for the two accepted allocators.
    !! These ceilings are booked node wide before allocation. The children
    !! derive actual shapes from live metadata and refuse an insufficient cap.
    integer(int64) :: gridpoint_bytes = 0, spectral_bytes = 0, spectral_map_bytes = 0
  end type

  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function prepare_native_initial_field_storage(configuration, spectral, world, &
                                                  budget, memory_policy, resource_prefix, child_status, failed_stage) result(status)
    !! The canonical configuration, its initial context and caller-owned TARGET
    !! records retain stable addresses through release.
    !! Geometry's phase7 NGLOBALINDEX is the actual packed global-point map.
    !! Book all three planned field payloads and one decoder before allocating
    !! GMV/GMVS then spectral fields. GFL is reserved here and allocated later
    !! at the source upper-air stage, after actual terrain and surface work.
    !! No field file is decoded here. Return0 publishes motion/spectral owners.
    !! A returning failure releases only owners acquired by this invocation;
    !! canonical geometry and configuration metadata stay intact.
    !! failed_stage is1 admission,2 memory,3 GMV,4 spectral.
    type(native_operational_model_configuration), target, intent(inout) :: configuration
    type(spectral_field_state), target, intent(inout) :: spectral
    type(MPI_Comm), intent(in) :: world
    type(native_initial_field_storage_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    character(len=*), intent(in) :: resource_prefix
    integer(int32), intent(out) :: child_status, failed_stage
    type(native_geometry_state), pointer :: geometry
    type(native_grid_motion_controls) :: motion_controls
    type(native_input_memory_sample) :: sample
    type(MPI_Comm) :: node
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: local_status, ignored, pitch, levels, blocks, points, field_counts(4)
    integer(int64) :: local_payload, node_payload, motion_payload, global_points
    integer :: error, rank, world_size
    logical :: own_node, have_motion, have_spectral

    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    child_status = 0; failed_stage = 1; local_status = 2
    own_node = .false.; have_motion = .false.; have_spectral = .false.
    nullify (geometry)
    if (.not. configuration%ready .or. .not. associated(configuration%initial)) goto 100
    if (.not. configuration%initial%ready .or. .not. allocated(configuration%initial%geometry)) goto 100
    if (.not. allocated(configuration%initial%prefix)) goto 100
    if (.not. configuration%initial%prefix%ready) goto 100
    geometry => configuration%initial%geometry
    if (.not. geometry%initialized .or. geometry%partition%phase /= 7) goto 100
    if (.not. associated(configuration%partition, geometry%partition)) goto 100
    if (.not. allocated(geometry%partition%nglobalindex)) goto 100
    pitch = geometry%dimensions%nproma; levels = geometry%dimensions%nflevg
    blocks = geometry%partition%ngpblks; points = geometry%partition%ngptot
    global_points = geometry%partition%ngptotg
    if (pitch < 1 .or. pitch > 1024 .or. levels /= 137 .or. global_points /= 6599680) goto 100
    if (points < 1 .or. points > global_points) goto 100
    if (int(blocks, int64) /= (int(points, int64) + pitch - 1)/pitch) goto 100
    if (size(geometry%partition%nglobalindex) < points) goto 100
    if (configuration%initial%prefix%grid%levels /= levels) goto 100
    if (spectral%ready) goto 100
    if (configuration%motion%ndimgmv /= 14 .or. configuration%motion%ndimgmvs /= 3) goto 100
    if (allocated(configuration%motion%gmv) .or. allocated(configuration%motion%gmvs)) goto 100
    if (allocated(configuration%motion%gmvt1) .or. allocated(configuration%motion%gmvt1s)) goto 100
    if (allocated(configuration%motion%gmv5) .or. allocated(configuration%motion%gmv5s)) goto 100
    if (allocated(configuration%motion%gmv_depart) .or. allocated(configuration%motion%gmvs_depart)) goto 100
    if (budget%gridpoint_bytes < 1 .or. budget%spectral_bytes < 1 .or. budget%spectral_map_bytes < 1) goto 100
    if (budget%gridpoint_bytes > huge(0_int64) - budget%spectral_bytes) goto 100
    local_payload = budget%gridpoint_bytes + budget%spectral_bytes
    motion_payload = 8_int64*int(pitch, int64)*blocks*(int(levels, int64)*14_int64 + 3_int64)
    if (local_payload > huge(0_int64) - motion_payload) goto 100
    local_payload = local_payload + motion_payload
    field_counts = [configuration%fields%registration%ndim, configuration%fields%registration%ndimslp, &
                    configuration%fields%registration%ndimpt, configuration%fields%registration%ndimpc]
    if (field_counts(1) /= 9) goto 100
    motion_controls%nconf = configuration%initial%controls%namespace%nconf
    motion_controls%lecmwf = configuration%initial%controls%namespace%lecmwf
    motion_controls%lrshw = configuration%initial%controls%namespace%lrshw
    motion_controls%nundefld = configuration%initial%controls%namespace%nundefld
    motion_controls%ldtenc = 0; motion_controls%nprintlev = 0
    local_status = 0
100 status = agree(world, local_status); child_status = status
    if (status /= 0) goto 900
    call MPI_Comm_rank(world, rank, error); call require_mpi(world, error)
    call MPI_Comm_size(world, world_size, error); call require_mpi(world, error)
    local_status = 2
    if (world_size == geometry%transform_control%nproc .and. rank + 1 == geometry%transform_control%myproc) then
      if (local_payload <= huge(0_int64)/max(1, world_size)) local_status = 0
    end if
    status = agree(world, local_status); child_status = status
    if (status /= 0) goto 900
    call MPI_Comm_split_type(world, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, node, error)
    call require_mpi(world, error); own_node = .true.
    call MPI_Allreduce(local_payload, node_payload, 1, MPI_INTEGER8, MPI_SUM, node, error)
    call require_mpi(world, error)
    failed_stage = 2
    local_status = observe_native_input_memory(memory_policy, sample)
    if (local_status == 0) local_status = record_resource(resource_prefix, rank, 0, sample)
    status = agree(world, local_status); child_status = status
    if (status == 0) then
      local_status=admit_native_input_payload(sample,node_payload,planned_decoder_bytes(geometry%partition%ngptot,geometry%dimensions%nflevg,geometry%partition%ngptotg))
      status = agree(world, local_status); child_status = status
    end if
    call MPI_Comm_free(node, error); call require_mpi(world, error); own_node = .false.
    if (status /= 0) goto 900

    failed_stage = 3
    local_status = allocate_distributed_grid_motion_fields(configuration%motion, pitch, levels, blocks, points, &
                                                           configuration%field_dimensions, configuration%dynamics, motion_controls)
    have_motion = local_status == 0
    status = agree(world, local_status); child_status = status
    if (status /= 0) goto 800
    failed_stage = 4
    local_status = initialize_owned_distributed_spectral_field(spectral, geometry%dimensions, &
                                geometry%transform_control, geometry%transform_resolution, geometry%partition, geometry%laplacian, &
                                                     [138_int32, 155_int32, 130_int32, 152_int32, 129_int32], budget%spectral_bytes)
    have_spectral = local_status == 0
    status = agree(world, local_status); child_status = status
    if (status /= 0) goto 800
    failed_stage = 0
    goto 900
800 if (have_spectral) ignored = release_distributed_spectral_field(spectral)
    if (have_motion) ignored = release_grid_motion_fields(configuration%motion)
900 if (own_node) then
      call MPI_Comm_free(node, error); call require_mpi(world, error)
    end if
    error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function load_native_initial_spectral_fields(spectral,world,path,loaded_orography,metadata_byte_cap) result(status)
    !! Call on every rank after storage preparation. The distributed source
    !! already labels levels1..L, so the streaming map origin is exactly1.
    !! No terrain or surface stage is supplied here. Keep the natural child
    !! numerical status and agree only the integer stage return across ranks.
    type(spectral_field_state), intent(inout) :: spectral
    type(MPI_Comm), intent(in) :: world
    character(len=*), intent(in) :: path
    integer(int32), intent(inout) :: loaded_orography
    integer(int64), intent(in) :: metadata_byte_cap
    integer(int32) :: local_status
    local_status = 2
    if (spectral%ready) local_status = 0
    status = agree(world, local_status)
    if (status /= 0) return
    local_status = load_owned_streaming_spectral_state(path, spectral, 1_int32, loaded_orography, metadata_byte_cap)
    status = agree(world, local_status)
  end function

  integer(int32) function prepare_native_initial_upper_air_storage(configuration, spectral, upper, world, &
                 constituents, thermal_constants, budget, memory_policy, resource_prefix, child_status, failed_stage) result(status)
    !! The root calls this concrete stage after terrain and surface loading.
    !! Keep actual GFL allocation at that source position. Re-admit all new
    !! GFL payloads and one decoder while booking existing motion/spectral
    !! owners on the same node. Thermal metadata is produced by the accepted
    !! own GFL projection, then borrowed from the caller's stable nine entries.
    !! Return0 publishes GFL and thermal outputs; refusal preserves caller
    !! thermal outputs and acquires no surviving owner. No decoder runs here.
    type(native_operational_model_configuration), target, intent(inout) :: configuration
    type(spectral_field_state), intent(in) :: spectral
    type(partitioned_upper_air_input_owner), intent(inout) :: upper
    type(MPI_Comm), intent(in) :: world
    type(thermal_constituent), target, contiguous, intent(inout) :: constituents(:)
    type(moist_air_constants), intent(inout) :: thermal_constants
    type(native_initial_field_storage_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    character(len=*), intent(in) :: resource_prefix
    integer(int32), intent(out) :: child_status, failed_stage
    type(native_geometry_state), pointer :: geometry
    type(thermal_constituent), target :: proposed_constituents(9)
    type(moist_air_constants) :: proposed_constants
    type(native_input_memory_sample) :: sample
    type(native_input_memory_policy) :: phase_policy
    type(MPI_Comm) :: node
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: local_status, field_counts(4)
    integer(int64) :: new_node_payload
    integer :: rank, world_size, error
    logical :: own_node
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    own_node = .false.; failed_stage = 1; child_status = 2; local_status = 2
    nullify (geometry)
    if (.not. configuration%ready .or. .not. associated(configuration%initial)) goto 100
    if (.not. configuration%initial%ready .or. .not. allocated(configuration%initial%geometry)) goto 100
    if (.not. allocated(configuration%initial%prefix)) goto 100
    geometry => configuration%initial%geometry
    if (.not. geometry%initialized .or. geometry%partition%phase /= 7 .or. .not. spectral%ready) goto 100
    if (.not. allocated(geometry%partition%nglobalindex)) goto 100
    if (.not. allocated(configuration%motion%gmv) .or. .not. allocated(configuration%motion%gmvs)) goto 100
    if (.not. gridpoint_field_storage_is_fresh(upper%fields) .or. upper%owns_node .or. upper%ready) goto 100
    if (upper%failed .or. upper%complete .or. upper%local_loaded .or. size(constituents) /= 9) goto 100
    if (budget%gridpoint_bytes < 1 .or. budget%spectral_bytes < 1) goto 100
    field_counts = [configuration%fields%registration%ndim, configuration%fields%registration%ndimslp, &
                    configuration%fields%registration%ndimpt, configuration%fields%registration%ndimpc]
    local_status = export_grid_field_thermal_constituents(configuration%fields, proposed_constituents)
    if (local_status == 0) local_status = export_native_moist_air_constants(configuration%initial%constants, proposed_constants)
100 status = agree(world, local_status); child_status = status
    if (status /= 0) goto 900
    call MPI_Comm_rank(world, rank, error); call require_mpi(world, error)
    call MPI_Comm_size(world, world_size, error); call require_mpi(world, error)
    local_status = 2
    if (budget%gridpoint_bytes <= huge(0_int64)/max(1, world_size)) local_status = 0
    status = agree(world, local_status); child_status = status
    if (status /= 0) goto 900
    call MPI_Comm_split_type(world, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, node, error)
    call require_mpi(world, error); own_node = .true.
    call MPI_Allreduce(budget%gridpoint_bytes, new_node_payload, 1, MPI_INTEGER8, MPI_SUM, node, error)
    call require_mpi(world, error)
    failed_stage = 2
    local_status = phase_memory_policy(configuration, spectral, budget, memory_policy, node, world, phase_policy)
    if (local_status == 0) local_status = observe_native_input_memory(phase_policy, sample)
    if (local_status == 0) local_status = record_resource(resource_prefix, rank, -1, sample)
    status = agree(world, local_status); child_status = status
    if (status == 0) then
      local_status=admit_native_input_payload(sample,new_node_payload,planned_decoder_bytes(geometry%partition%ngptot,geometry%dimensions%nflevg,geometry%partition%ngptotg))
      status = agree(world, local_status); child_status = status
    end if
    call MPI_Comm_free(node, error); call require_mpi(world, error); own_node = .false.
    if (status /= 0) goto 900
    failed_stage = 3
    status = initialize_partitioned_upper_air_input_owner(upper, world, geometry%dimensions%nproma, &
                                                geometry%dimensions%nflevg, geometry%partition%ngpblks, geometry%partition%ngptot, &
                                                      geometry%partition%ngptotg, field_counts, configuration%initial%prefix%grid, &
                         geometry%partition%nglobalindex(:geometry%partition%ngptot), proposed_constituents, budget%gridpoint_bytes)
    child_status = status
    if (status /= 0) goto 900
    constituents = proposed_constituents; thermal_constants = proposed_constants
    upper%fields%constituents => constituents
    failed_stage = 0
900 if (own_node) then
      call MPI_Comm_free(node, error); call require_mpi(world, error)
    end if
    error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function advance_native_initial_upper_air_input(configuration,spectral,upper,world,path,budget,memory_policy,resource_prefix) result(status)
    !! The root invokes this stage after actual terrain and surface work.
    !! Every rank participates, including ranks whose node already finished.
    !! Save a fresh real-process memory sample before each bounded decoder
    !! batch. A failed sample/journal/admission performs no decode. A child
    !! failure retains the owned fields for first-failure tracing and release.
    type(native_operational_model_configuration), intent(in) :: configuration
    type(spectral_field_state), intent(in) :: spectral
    type(partitioned_upper_air_input_owner), intent(inout) :: upper
    type(MPI_Comm), intent(in) :: world
    character(len=*), intent(in) :: path, resource_prefix
    type(native_initial_field_storage_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    type(native_input_memory_policy) :: phase_policy
    type(native_input_memory_sample) :: sample
    type(upper_air_decoder_memory_admission) :: admission
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: local_status
    integer :: rank, error
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    local_status = 2
    if (upper%ready .and. upper%owns_node .and. .not. upper%failed) local_status = 0
    status = agree(world, local_status)
    if (status /= 0 .or. upper%complete) goto 900
    call MPI_Comm_rank(world, rank, error); call require_mpi(world, error)
    local_status = phase_memory_policy(configuration, spectral, budget, memory_policy, upper%node, world, phase_policy)
    if (local_status == 0) local_status = observe_native_input_memory(phase_policy, sample)
    if (local_status == 0) local_status = make_upper_air_memory_admission(sample, upper%node_destination_bytes, admission)
    if (local_status == 0) local_status = record_resource(resource_prefix, rank, upper%batches_completed + 1, sample)
    status = agree(world, local_status)
    if (status /= 0) goto 900
    status = load_next_partitioned_upper_air_batch(upper, world, path, admission)
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int64) function planned_decoder_bytes(local_points, levels, global_points) result(bytes)
    !! Complete private local message staging, one decoded global field and
    !! four int64 schema labels per record. Codec memory is reserved separately.
    integer(int32), intent(in) :: local_points, levels, global_points
    bytes = 8_int64*(int(local_points, int64)*7_int64*levels + global_points) + 32_int64*7_int64*levels
  end function

  integer(int32) function phase_memory_policy(configuration, spectral, budget, base, node, world, output) result(status)
    !! base.other_live_bytes excludes this input family's motion/spectral/GFL
    !! fields. Actual resident pages remain in the observer ancestor charge.
    !! Decode and placement touch no old motion, spectral or surface payload;
    !! retain only the declared physical floor without adding logical extents.
    type(native_operational_model_configuration), intent(in) :: configuration
    type(spectral_field_state), intent(in) :: spectral
    type(native_initial_field_storage_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: base
    type(MPI_Comm), intent(in) :: node, world
    type(native_input_memory_policy), intent(inout) :: output
    integer(int64) :: local_live, node_live
    integer(int32) :: local_status
    integer :: error, world_size
    local_status = 2; local_live = 0
    if (.not. spectral%ready .or. budget%spectral_bytes < 1 .or. base%other_live_bytes < 0) goto 100
    if (.not. allocated(configuration%motion%gmv) .or. .not. allocated(configuration%motion%gmvs)) goto 100
    local_live = 8_int64*(size(configuration%motion%gmv, kind=int64) + size(configuration%motion%gmvs, kind=int64))
    if (local_live > huge(0_int64) - budget%spectral_bytes) goto 100
    local_live = local_live + budget%spectral_bytes
    local_status = 0
100 status = agree(world, local_status)
    if (status /= 0) return
    call MPI_Comm_size(world, world_size, error); call require_mpi(world, error)
    local_status = 2
    if (local_live <= huge(0_int64)/max(1, world_size)) local_status = 0
    status = agree(world, local_status)
    if (status /= 0) return
    call MPI_Allreduce(local_live, node_live, 1, MPI_INTEGER8, MPI_SUM, node, error)
    call require_mpi(world, error)
    local_status = 2
    if (base%other_live_bytes <= huge(0_int64) - node_live) local_status = 0
    status = agree(world, local_status)
    if (status /= 0) return
    output = base
    output%other_live_bytes = base%other_live_bytes
  end function

  integer(int32) function record_resource(prefix, rank, batch, sample) result(status)
    character(len=*), intent(in) :: prefix
    integer, intent(in) :: rank, batch
    type(native_input_memory_sample), intent(in) :: sample
    character(len=4096) :: path
    integer :: ios
    status = 2
    if (len_trim(prefix) < 1 .or. len_trim(prefix) > 4000 .or. index(prefix, achar(0)) /= 0) return
    if (batch == -1) then
      write (path, '(a,"_rank_",i0,"_upper_prepare.txt")', iostat=ios) trim(prefix), rank
    else if (batch == 0) then
      write (path, '(a,"_rank_",i0,"_prepare.txt")', iostat=ios) trim(prefix), rank
    else
      write (path, '(a,"_rank_",i0,"_batch_",i0,".txt")', iostat=ios) trim(prefix), rank, batch
    end if
    if (ios /= 0 .or. len_trim(path) > 4095) return
    status = record_native_input_memory_sample(trim(path), sample)
  end function

  integer(int32) function agree(world, local_status) result(status)
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(in) :: local_status
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: error
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    call MPI_Allreduce(local_status, status, 1, MPI_INTEGER4, MPI_MAX, world, error)
    call require_mpi(world, error)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
  subroutine require_mpi(world, error)
    type(MPI_Comm), intent(in) :: world
    integer, intent(in) :: error
    integer :: ignored
    if (error == MPI_SUCCESS) return
    call MPI_Abort(world, 3, ignored)
    error stop 3
  end subroutine
end module forecast_native_initial_field_loading
