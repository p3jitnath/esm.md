!> Keep only observation metadata for one stopped genuine weather boundary.
!! Weather,clock and scientific owners remain borrowed and readonly.
module forecast_native_weather_checkpoint
  use iso_c_binding
  use iso_fortran_env, only: int32, int64
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_weather_capture_views, only: describe_native_weather_state
  use forecast_native_weather_extensions, only: describe_native_weather_extensions
  use forecast_weather_view_protocol, only: weather_view_callback
  implicit none
  private
  integer, parameter :: view_capacity = 8192
  type, bind(C) :: native_weather_view_row
    character(c_char) :: name(512)
    integer(c_int) :: name_bytes, type_code, kind_bytes, rank, presence, role
    integer(c_int64_t) :: lower(7), upper(7), elements
    type(c_ptr) :: base
  end type
  type(native_weather_view_row), save, target, bind(C, name='native_weather_capture_views') :: views(view_capacity)
  integer(c_int), save, target, bind(C, name='native_weather_capture_view_count') :: view_count = 0
  integer(c_int), save, target, bind(C, name='native_weather_capture_reply_status') :: reply_status = 2
  integer(c_int), save, target, bind(C, name='native_weather_capture_index') :: capture_index = -1
  integer(c_int), save, target, bind(C, name='native_weather_capture_rank') :: capture_rank = -1
  integer(c_int), save, target, bind(C, name='native_weather_capture_world') :: capture_world_size = 0
  integer(c_int), save, target, bind(C, name='native_weather_capture_entry_errno') :: capture_errno = 0
  type(native_forecast_execution_state), pointer, save :: owner => null()
  type(MPI_Comm), save :: capture_world = MPI_COMM_NULL
  type(c_funptr), save :: additional_observer = c_null_funptr
  integer(c_int), save :: next_index = 0
  logical, save :: registered = .false.
  public :: register_native_weather_capture, observe_forecast_boundary, unregister_native_weather_capture
  interface
    function capture_errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine native_weather_checkpoint_ready(index, row_base, row_bytes, count, entry_errno, reply_address) bind(C)
      import c_int, c_int64_t, c_ptr
      integer(c_int), value :: index, count, entry_errno
      integer(c_int64_t), value :: row_bytes
      type(c_ptr), value :: row_base, reply_address
    end subroutine
  end interface
contains
  !> Borrow the final execution TARGET and already live MPI world.
 !! Registration is collective on all32 processes. Optional OBSERVER receives
 !! readonly view metadata after the bounded default collector records it.
  subroutine register_native_weather_capture(state, world, status, observer)
    type(native_forecast_execution_state), target, intent(in) :: state
    type(MPI_Comm), intent(in) :: world
    integer(c_int), intent(out) :: status
    type(c_funptr), optional, intent(in) :: observer
    type(ieee_status_type) :: saved_ieee
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: saved_errno, local
    integer :: error, nproc, rank
    logical :: active
    call ieee_get_status(saved_ieee)
    call c_f_pointer(capture_errno_address(), errno_word); saved_errno = errno_word
    status = 2
    call MPI_Initialized(active, error)
    if (error /= MPI_SUCCESS .or. .not. active) goto900
    if (.not. (world == MPI_COMM_WORLD)) goto900
    call MPI_Comm_size(world, nproc, error)
    if (error /= MPI_SUCCESS) goto900
    call MPI_Comm_rank(world, rank, error)
    if (error /= MPI_SUCCESS) goto900
    local = 2
    if (nproc == 32 .and. .not. registered) local = 0
    call agree(world, local, status)
    if (status /= 0) goto900
    owner => state; capture_world = world; registered = .true.; next_index = 0
    capture_rank = rank; capture_world_size = nproc; capture_index = -1
    view_count = 0; reply_status = 2; additional_observer = c_null_funptr
    if (present(observer)) additional_observer = observer
900 call ieee_set_status(saved_ieee)
    errno_word = saved_errno
  end subroutine
  !> Describe a true checkpoint,then let the external stopped-state sink read.
 !! INDEX0 is before first STEPO after the CNT4 prologue. INDEX1/2 follow
 !! successful STEPO0/1 returns. A debugger sets only REPLY_STATUS after
 !! a complete frame. Its initial2 makes a missing observer fail closed.
 !! The outer controller bounds every debugger/model process by its deadline.
  subroutine observe_forecast_boundary(index, status)
    integer(c_int), intent(in) :: index
    integer(c_int), intent(out) :: status
    type(ieee_status_type) :: saved_ieee
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: saved_errno, local
    call ieee_get_status(saved_ieee)
    call c_f_pointer(capture_errno_address(), errno_word); saved_errno = errno_word
    status = 0
    if (.not. registered) goto900
    capture_errno = saved_errno; local = 2
    if (associated(owner) .and. index == next_index .and. index >= 0 .and. index <= 2) local = 0
    call agree(capture_world, local, status)
    if (status /= 0) goto900
    capture_index = index; view_count = 0; reply_status = 2
    call describe_native_weather_state(owner, index, c_funloc(collect_weather_view), local)
    if (local == 0) call describe_native_weather_extensions(owner, c_funloc(collect_weather_view), local)
    call agree(capture_world, local, status)
    if (status /= 0) goto900
    ! Restore the natural boundary status before the debugger reads registers.
    call ieee_set_status(saved_ieee); errno_word = saved_errno
    call native_weather_checkpoint_ready(index, c_loc(views), int(c_sizeof(views(1)), c_int64_t), &
                                         view_count, capture_errno, c_loc(reply_status))
    local = 2
    if (reply_status == 0) local = 0
    call agree(capture_world, local, status)
    if (status == 0) next_index = next_index + 1
900 call ieee_set_status(saved_ieee)
    errno_word = saved_errno
  end subroutine
  !> C-only trampoline avoids a CNT4/execution-type module dependency cycle.
  integer(c_int32_t) function observe_boundary_c(index) bind(C, name='md2asm_observe_native_forecast_boundary') result(status)
    integer(c_int32_t), value :: index
    call observe_forecast_boundary(index, status)
  end function
  !> Retire observation borrows only; never finalize MPI or release weather.
  subroutine unregister_native_weather_capture(status)
    integer(c_int), intent(out) :: status
    status = 0
    nullify (owner); registered = .false.; additional_observer = c_null_funptr
    capture_world = MPI_COMM_NULL; view_count = 0; reply_status = 2; next_index = 0
  end subroutine
  subroutine agree(world, local, status)
    type(MPI_Comm), intent(in) :: world
    integer(c_int), intent(in) :: local
    integer(c_int), intent(out) :: status
    integer :: error
    call MPI_Allreduce(local, status, 1, MPI_INTEGER, MPI_MAX, world, error)
    if (error /= MPI_SUCCESS) status = 2
  end subroutine
  subroutine collect_weather_view(name,name_bytes,type_code,kind_bytes,rank,lower,upper,base,elements,presence,role,status)bind(C)
    character(c_char), intent(in) :: name(*)
    integer(c_int), value :: name_bytes, type_code, kind_bytes, rank, presence, role
    integer(c_int64_t), intent(in) :: lower(*), upper(*)
    type(c_ptr), value :: base
    integer(c_int64_t), value :: elements
    integer(c_int), intent(out) :: status
    procedure(weather_view_callback), pointer :: forward
    integer :: i, n
    status = 2
    if (view_count < 0 .or. view_count >= view_capacity) return
    if (name_bytes < 1 .or. name_bytes > 512 .or. rank < 0 .or. rank > 7) return
    if (elements < 0 .or. presence < 0 .or. presence > 1) return
    n = view_count + 1
    views(n)%name = c_null_char
    do i = 1, name_bytes
      views(n)%name(i) = name(i)
    end do
    views(n)%name_bytes = name_bytes; views(n)%type_code = type_code
    views(n)%kind_bytes = kind_bytes; views(n)%rank = rank
    views(n)%presence = presence; views(n)%role = role
    views(n)%lower = 0; views(n)%upper = -1
    do i = 1, rank
      views(n)%lower(i) = lower(i); views(n)%upper(i) = upper(i)
    end do
    views(n)%base = base; views(n)%elements = elements; view_count = n
    status = 0
    if (c_associated(additional_observer)) then
      call c_f_procpointer(additional_observer, forward)
      call forward(name, name_bytes, type_code, kind_bytes, rank, lower, upper, base, elements, presence, role, status)
    end if
  end subroutine
end module
