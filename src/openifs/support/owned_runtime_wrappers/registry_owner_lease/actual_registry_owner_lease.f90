!> Keep one actual execution owner alive for its complete field registry.
module forecast_actual_registry_owner_lease
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08, only: MPI_Comm
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_execution_setup, only: native_forecast_execution_budget, release_native_forecast_execution
  use forecast_native_input_memory, only: native_input_memory_policy
  use forecast_native_execution_input_prefix, only: initialize_actual_execution_input_prefix
  use forecast_actual_native_registry_acquisition, only: prepare_actual_native_registry
  implicit none
  private
  public :: native_registry_owner_lease, create_actual_registry_owner_lease
  public :: release_actual_registry_owner_lease, prepare_actual_execution_registry
  !> Observe the lifetime of the one separately owned actual execution target.
  !! This control owns no payload. OWNER borrows the caller's allocatable TARGET.
  !! PHASE110 denotes registry attempt;120 denotes a complete successful graph.
  !! A fatal partial graph remains live until process exit and cannot be released.
  type :: native_registry_owner_lease
    type(native_forecast_execution_state), pointer :: owner => null()
    integer(int32) :: phase = 0_int32, last_status = 0_int32, registry_status = 0_int32, cleanup_status = 0_int32
    logical :: fatal = .false.
  end type
  interface
    function public_errno_location() bind(c, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Construct the registry over the current execution's genuine loaded owners.
  !! No GP work, column, controller or weather calculation is performed here.
  integer(int32) function prepare_actual_execution_registry(execution) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: execution
    status = 2_int32
    if (.not. allocated(execution%startup)) return
    status = prepare_actual_native_registry(execution%grid, execution%startup, execution%gp_work%registry_ready)
  end function

  !> Create one scientific input owner and then its complete actual registry.
  !! OUTPUT starts unallocated and remains the single final TARGET. LEASE starts
  !! empty. WORLD and paths are passed unchanged to the actual input prefix.
  !! BUDGET contains byte ceilings; MEMORY_POLICY contains source input limits.
  !! A child failure returns its status. Registry failure returns120+child and
  !! retains the fatal owners. CHILD_STATUS and FAILED_STAGE identify progress.
  integer(int32) function create_actual_registry_owner_lease(output, lease, world, spectral_path, surface_path, &
       upper_air_path,configuration_path,budget,memory_policy,journal_prefix,data_directory,child_status,failed_stage)result(status)
    type(native_forecast_execution_state), allocatable, target, intent(inout) :: output
    type(native_registry_owner_lease), intent(inout) :: lease
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, configuration_path, journal_prefix, data_directory
    type(native_forecast_execution_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: reached_status, cleanup
    status = 2_int32; child_status = 2_int32; failed_stage = 1_int32
    if (allocated(output) .or. associated(lease%owner)) return
    if (lease%phase /= 0_int32 .or. lease%fatal) return
    status = initialize_actual_execution_input_prefix(output, world, spectral_path, surface_path, upper_air_path, &
                              configuration_path, budget, memory_policy, journal_prefix, data_directory, child_status, failed_stage)
    if (allocated(output)) then
      lease%owner => output
      lease%phase = output%phase
    end if
    if (status /= 0_int32) then
      reached_status = status
      if (allocated(output)) then
        cleanup = release_actual_registry_owner_lease(output, lease)
        if (cleanup /= 0_int32) then
          lease%fatal = .true.
          lease%last_status = reached_status
          lease%cleanup_status = cleanup
        end if
      end if
      status = reached_status
      return
    end if
    lease%phase = 110_int32
    failed_stage = 110_int32
    status = prepare_actual_execution_registry(output)
    child_status = status
    lease%registry_status = status
    if (status /= 0_int32) then
      lease%fatal = .true.
      status = 120_int32 + status
      lease%last_status = status
      return
    end if
    lease%phase = 120_int32
    lease%last_status = 0_int32
    child_status = 0_int32; failed_stage = 0_int32
  end function create_actual_registry_owner_lease

  !> Release actual owners after all readers close, preserving incoming status.
  !! Fatal or mismatched owners refuse before effects. The public release owner
  !! retires borrowed heads and frees payloads in the source order. IEEE status
  !! and actual thread-local errno are restored after cleanup. Empty succeeds.
  integer(int32) function release_actual_registry_owner_lease(output, lease) result(status)
    type(native_forecast_execution_state), allocatable, target, intent(inout) :: output
    type(native_registry_owner_lease), intent(inout) :: lease
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: incoming_errno
    status = 2_int32
    if (lease%fatal) return
    if (.not. ((lease%phase >= 0_int32 .and. lease%phase <= 61_int32) .or. lease%phase == 120_int32)) return
    if (.not. allocated(output)) then
      if (associated(lease%owner) .or. lease%phase /= 0_int32) return
      status = 0_int32
      return
    end if
    if (.not. associated(lease%owner, output)) return
    if (allocated(output%startup)) then
      if (associated(output%startup%loaded%fields)) then
        if (.not. output%gp_work%registry_ready) then
          if (associated(output%startup%loaded%fields%registry%variables)) return
          if (associated(output%startup%loaded%fields%registry%surface)) return
        end if
      end if
    end if
    call c_f_pointer(public_errno_location(), error_pointer)
    incoming_errno = error_pointer
    call ieee_get_status(incoming_status)
    status = release_native_forecast_execution(output)
    if (allocated(output)) then
      if (allocated(output%startup)) then
        if (associated(output%startup%loaded%fields)) then
          if (.not. associated(output%startup%loaded%fields%registry%variables) .and. &
              .not. associated(output%startup%loaded%fields%registry%surface)) output%gp_work%registry_ready = .false.
        end if
      end if
    end if
    if (status == 0_int32) then
      nullify (lease%owner)
      lease%phase = 0_int32; lease%last_status = 0_int32
      lease%registry_status = 0_int32; lease%cleanup_status = 0_int32
    else
      lease%fatal = .true.
      lease%last_status = status
      lease%cleanup_status = status
    end if
    call ieee_set_status(incoming_status)
    error_pointer = incoming_errno
  end function release_actual_registry_owner_lease
end module forecast_actual_registry_owner_lease
