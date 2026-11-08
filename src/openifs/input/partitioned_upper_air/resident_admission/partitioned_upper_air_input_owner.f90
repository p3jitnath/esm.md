module partitioned_upper_air_input_owner_port
  !! Own local atmospheric fields while decoding a bounded set of MPI ranks.
  !! The caller keeps the canonical grid, point map, thermal metadata and
  !! world communicator alive until release. This module owns only its fields
  !! and one shared-memory communicator. It creates no second geometry state.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use gridpoint_field_storage_port, only: gridpoint_field_state, gridpoint_field_storage_is_fresh, release_gridpoint_field
  use runtime_gridpoint_field_storage_port, only: initialize_runtime_distributed_gridpoint_field
  use runtime_partitioned_upper_air_placement_port, only: runtime_partitioned_upper_air_shape, &
                                                bind_runtime_partitioned_upper_air_shape, validate_partitioned_upper_air_destination
  use runtime_initial_upper_air_reader_port, only: runtime_initial_grid_metadata
  use runtime_streaming_partitioned_upper_air_loading_port, only: load_runtime_streaming_partitioned_upper_air_state, &
                                                                  runtime_streaming_upper_air_private_bytes
  use md2asm_moist_air_gas_properties, only: thermal_constituent
  use forecast_upper_air_resident_memory_bounds, only: compute_upper_air_resident_bounds
  implicit none
  private
  public :: partitioned_upper_air_input_owner, upper_air_decoder_memory_admission
  public :: initialize_partitioned_upper_air_input_owner, load_next_partitioned_upper_air_batch
  public :: release_partitioned_upper_air_input_owner, stamp_upper_air_decoder_memory_admission
  type :: upper_air_decoder_memory_admission
    !! All sizes are bytes. node_limit is the usable physical/cgroup/domain
    !! limit, and other_live is the observed physical ancestor charge.
    !! Resident destination pages remain in that charge. The active visit
    !! separately bounds possible destination and map faults. available is
    !! a fresh observed free allowance after the logical arrays exist.
    !! reserve covers future shared work; codec_reserve bounds one decoder's
    !! external codec/runtime workspace. No value is inferred from RAM size.
    integer(int64) :: node_limit = 0, other_live = 0, available = 0, reserve = 0, codec_reserve = 0
    integer(int64) :: observed_clock = 0, clock_rate = 0, maximum_age_seconds = 0
  end type
  type :: partitioned_upper_air_input_owner
    type(gridpoint_field_state) :: fields
    type(runtime_partitioned_upper_air_shape) :: partition
    type(MPI_Comm) :: world = MPI_COMM_NULL, node = MPI_COMM_NULL
    integer(int32) :: node_rank = -1, node_size = 0, node_completed = 0, batches_completed = 0
    integer(int32) :: last_local_status = 0, last_global_status = 0, last_decoder_capacity = 0
    integer(int64) :: node_destination_bytes = 0
    logical :: owns_node = .false., ready = .false., local_loaded = .false., complete = .false., failed = .false.
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    function upper_air_page_size() bind(C, name="getpagesize") result(bytes)
      import c_int
      integer(c_int) :: bytes
    end function
  end interface
contains
  integer(int32) function stamp_upper_air_decoder_memory_admission(output,node_limit,other_live,available,reserve,codec_reserve,maximum_age_seconds) result(status)
    !! Copy a just-observed caller resource admission and attach this process's
    !! monotonic clock. This function does not measure memory. The resource
    !! producer must supply actual bytes and keep its provider record.
    type(upper_air_decoder_memory_admission), intent(inout) :: output
    integer(int64), intent(in) :: node_limit, other_live, available, reserve, codec_reserve, maximum_age_seconds
    type(upper_air_decoder_memory_admission) :: proposed
    integer(int64) :: now, rate
    status = 2
    if (node_limit <= 0 .or. other_live < 0 .or. available < 0 .or. reserve < 0 .or. codec_reserve <= 0) return
    if (other_live > node_limit .or. reserve > node_limit) return
    if (maximum_age_seconds < 1 .or. maximum_age_seconds > 120) return
    call system_clock(now, rate)
    if (now < 0 .or. rate <= 0) return
    proposed=upper_air_decoder_memory_admission(node_limit,other_live,available,reserve,codec_reserve,now,rate,maximum_age_seconds)
    output = proposed
    status = 0
  end function

  integer(int32) function initialize_partitioned_upper_air_input_owner(output,world,pitch,levels,blocks,local_points,global_points,field_counts,headers,global_index,constituents,byte_cap) result(status)
    !! Every world rank calls this entry. It validates the fixed loader's
    !! declared N1280/L137 shape, borrows the live point map, then allocates
    !! its four local destinations with the unchanged native storage child.
    !! No decoder runs here. A returning failure releases every new owner.
    type(partitioned_upper_air_input_owner), intent(inout) :: output
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(in) :: pitch, levels, blocks, local_points, global_points, field_counts(4)
    type(runtime_initial_grid_metadata), intent(in) :: headers
    integer(int32), target, contiguous, intent(in) :: global_index(:)
    type(thermal_constituent), target, intent(in) :: constituents(:)
    integer(int64), intent(in) :: byte_cap
    type(runtime_partitioned_upper_air_shape) :: proposed
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: rank, world_size, node_rank, node_size, error, field, level, column, last_column
    integer(int32) :: local_status, ignored
    integer(int64) :: local_bytes
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    local_status = 2
    if (.not. output%owns_node .and. .not. output%ready .and. .not. output%local_loaded .and. &
        .not. output%complete .and. .not. output%failed .and. gridpoint_field_storage_is_fresh(output%fields)) then
      if (pitch >= 1 .and. pitch <= 1024 .and. levels == 137 .and. global_points == 6599680 .and. field_counts(1) == 9) then
        local_status=bind_runtime_partitioned_upper_air_shape(proposed,pitch,levels,blocks,local_points,global_points,field_counts,headers,global_index)
      end if
    end if
    status = agree(world, local_status)
    if (status /= 0) goto 900
    call MPI_Comm_rank(world, rank, error)
    call require_mpi(world, error)
    call MPI_Comm_size(world, world_size, error)
    call require_mpi(world, error)
    local_status = 0
    if (world_size < 1 .or. world_size > 65536) local_status = 2
    status = agree(world, local_status)
    if (status /= 0) goto 900
    call MPI_Comm_split_type(world, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, output%node, error)
    call require_mpi(world, error)
    output%owns_node = .true.; output%world = world
    call MPI_Comm_rank(output%node, node_rank, error)
    call require_mpi(world, error)
    call MPI_Comm_size(output%node, node_size, error)
    call require_mpi(world, error)
    output%node_rank = node_rank; output%node_size = node_size
    local_status=initialize_runtime_distributed_gridpoint_field(output%fields,pitch,levels,blocks,local_points,global_points,field_counts,constituents,byte_cap)
    status = agree(world, local_status)
    if (status /= 0) then
      ignored = release_partitioned_upper_air_input_owner(output)
      goto 900
    end if
    local_bytes = field_payload_bytes(output%fields)
    local_status = 0
    if (local_bytes > huge(0_int64)/int(world_size, int64)) local_status = 2
    status = agree(world, local_status)
    if (status /= 0) then
      ignored = release_partitioned_upper_air_input_owner(output)
      goto 900
    end if
    call MPI_Allreduce(local_bytes, output%node_destination_bytes, 1, MPI_INTEGER8, MPI_SUM, output%node, error)
    call require_mpi(world, error)
    ! The source container clears only copied-field final-block padding.
    ! Active data and other owners remain uninitialised until their producer.
    last_column = mod(local_points - 1, pitch) + 1
    do field = 1, 7
      do level = 1, levels
        do column = last_column + 1, pitch
          output%fields%gfl(column, level, field, blocks) = 0.0_real64
        end do
      end do
    end do
    output%partition = proposed
    output%ready = .true.
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function load_next_partitioned_upper_air_batch(output, world, path, memory) result(status)
    !! Every world rank calls once for each batch, including finished nodes.
    !! The caller refreshes memory before each call. Capacity uses both the
    !! observed allowance and physical node_limit-other_live, then removes
    !! reserve. Each active decoder also admits its complete destination and map
    !! fault footprint, all private arrays and codec workspace. Logical mappings
    !! remain independently bounded. The node uses its largest rank cost.
    !! Local ranks run in increasing world-rank order within each shared node.
    !! A common returning child failure marks the stage failed; it is not
    !! retried. Previously loaded local destinations stay owned until release.
    type(partitioned_upper_air_input_owner), intent(inout) :: output
    type(MPI_Comm), intent(in) :: world
    character(len=*), intent(in) :: path
    type(upper_air_decoder_memory_admission), intent(in) :: memory
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int64) :: now, rate, headroom, available_on_node, decoder_bytes, decoder_private_bytes
    integer(int64) :: gfl_bytes, map_bytes, page_bytes
    integer :: error, node_capacity, global_done, node_done
    integer(int32) :: local_status
    logical :: active
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    local_status = 2
    if (output%ready .and. output%owns_node .and. .not. output%failed) local_status = 0
    status = agree(world, local_status)
    if (status /= 0) goto 900
    if (output%complete) goto 900
    local_status = 0; headroom = huge(0_int64); decoder_bytes = 1
    decoder_private_bytes = runtime_streaming_upper_air_private_bytes(output%partition)
    if (decoder_private_bytes < 1) local_status = 2
    if (output%node_completed < output%node_size) then
      if (len(path) < 1 .or. len(path) > 4095) local_status = 2
      if (index(path, achar(0)) /= 0) local_status = 2
      if (memory%node_limit <= 0 .or. memory%other_live < 0 .or. memory%available < 0 .or. &
          memory%reserve < 0 .or. memory%codec_reserve <= 0) local_status = 2
if(memory%observed_clock<0.or.memory%clock_rate<=0.or.memory%maximum_age_seconds<1.or.memory%maximum_age_seconds>120) local_status=2
      call system_clock(now, rate)
      if (rate /= memory%clock_rate .or. now < memory%observed_clock) then
        local_status = 2
      else if (memory%clock_rate > 0 .and. memory%maximum_age_seconds > 0) then
        if (memory%clock_rate > huge(0_int64)/memory%maximum_age_seconds) then
          local_status = 2
        else if (now - memory%observed_clock > memory%clock_rate*memory%maximum_age_seconds) then
          local_status = 2
        end if
      end if
      if (local_status == 0) then
        local_status = 2
        if (allocated(output%fields%gfl) .and. associated(output%partition%global_index)) then
          if (size(output%fields%gfl, kind=int64) <= huge(0_int64)/8_int64 .and. &
              size(output%partition%global_index, kind=int64) <= huge(0_int64)/4_int64) then
            gfl_bytes = 8_int64*size(output%fields%gfl, kind=int64)
            map_bytes = 4_int64*size(output%partition%global_index, kind=int64)
            page_bytes = int(upper_air_page_size(), int64)
            local_status = compute_upper_air_resident_bounds(memory%node_limit, memory%other_live, &
                                            memory%available, memory%reserve, memory%codec_reserve, output%partition%local_points, &
                                             output%partition%global_points, output%partition%fields%levels, gfl_bytes, map_bytes, &
                                                             page_bytes, headroom, decoder_bytes)
          end if
        end if
      end if
    end if
    status = agree(world, local_status)
    if (status /= 0) goto 900
    call MPI_Allreduce(headroom, available_on_node, 1, MPI_INTEGER8, MPI_MIN, output%node, error)
    call require_mpi(world, error)
    call MPI_Allreduce(MPI_IN_PLACE, decoder_bytes, 1, MPI_INTEGER8, MPI_MAX, output%node, error)
    call require_mpi(world, error)
    node_capacity = int(min(int(output%node_size - output%node_completed, int64), available_on_node/decoder_bytes))
    local_status = 0
    if (output%node_completed < output%node_size .and. node_capacity < 1) local_status = 3
    status = agree(world, local_status)
    if (status /= 0) goto 900
    output%last_decoder_capacity = node_capacity
    active = output%node_rank >= output%node_completed .and. output%node_rank < output%node_completed + node_capacity
    local_status = 0
    if(active) local_status=load_runtime_streaming_partitioned_upper_air_state(path,output%partition,decoder_private_bytes,output%fields%gfl)
    output%last_local_status = local_status
    status = agree(world, local_status)
    output%last_global_status = status
    if (status /= 0) then
      output%failed = .true.
      goto 900
    end if
    if (active) output%local_loaded = .true.
    output%node_completed = output%node_completed + node_capacity
    output%batches_completed = output%batches_completed + 1
    node_done = 0
    if (output%node_completed == output%node_size) node_done = 1
    call MPI_Allreduce(node_done, global_done, 1, MPI_INTEGER, MPI_MIN, world, error)
    call require_mpi(world, error)
    output%complete = global_done == 1
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function release_partitioned_upper_air_input_owner(output) result(status)
    !! All ranks of every created node communicator call release together.
    !! Borrowed map, thermal metadata and world communicator remain external.
    !! Numerical arrays are released by their accepted native owner child.
    type(partitioned_upper_air_input_owner), intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: error
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = release_gridpoint_field(output%fields)
    if (output%owns_node) then
      call MPI_Comm_free(output%node, error)
      call require_mpi(output%world, error)
    end if
    nullify (output%partition%global_index)
    output%partition%local_points = 0; output%partition%global_points = 0
    output%world = MPI_COMM_NULL; output%node = MPI_COMM_NULL
    output%node_rank = -1; output%node_size = 0; output%node_completed = 0; output%batches_completed = 0
    output%last_local_status = 0; output%last_global_status = 0; output%last_decoder_capacity = 0
    output%node_destination_bytes = 0
    output%owns_node = .false.; output%ready = .false.; output%local_loaded = .false.; output%complete = .false.; output%failed = .false.
    error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int64) function field_payload_bytes(fields) result(bytes)
    type(gridpoint_field_state), intent(in) :: fields
    bytes = 0
    if (allocated(fields%gfl)) bytes = bytes + 8_int64*size(fields%gfl, kind=int64)
    if (allocated(fields%gflslp)) bytes = bytes + 8_int64*size(fields%gflslp, kind=int64)
    if (allocated(fields%gflpt)) bytes = bytes + 8_int64*size(fields%gflpt, kind=int64)
    if (allocated(fields%gflpc)) bytes = bytes + 8_int64*size(fields%gflpc, kind=int64)
  end function
  integer(int32) function agree(world, local_status) result(status)
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(in) :: local_status
    integer :: error
    call MPI_Allreduce(local_status, status, 1, MPI_INTEGER4, MPI_MAX, world, error)
    call require_mpi(world, error)
  end function
  subroutine require_mpi(world, error)
    type(MPI_Comm), intent(in) :: world
    integer, intent(in) :: error
    integer :: ignored
    if (error == MPI_SUCCESS) return
    call MPI_Abort(world, 3, ignored)
    error stop 3
  end subroutine
end module partitioned_upper_air_input_owner_port
