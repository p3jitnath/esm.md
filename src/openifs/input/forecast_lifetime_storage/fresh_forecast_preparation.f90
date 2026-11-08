!> Prepare only the source fresh-start branch and its five dummy forcing arrays.
module forecast_fresh_preparation
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer, c_char, c_null_char
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_native_loop_data, only: native_loop_data
  use forecast_fresh_storage_types
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  implicit none
  private
  public :: prepare_selected_fresh_forecast, prepare_operational_fresh_forecast, release_selected_fresh_forecast
  interface
    function fresh_errno_location() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    function pathname_exists(path, mode) bind(C, name='access') result(code)
      import c_int, c_char
      character(c_char), intent(in) :: path(*)
      integer(c_int), value :: mode
      integer(c_int) :: code
    end function
  end interface
contains
!> Prepare the bounded source stop1:25, starting at step0.
!! MODEL borrows the actual initial context; LOOP and IO are unchanged.
!! PHYSICS is TARGET and stays at the same address until release.
!! Units follow each forcing field; dummy shape is(1,1,1,0:1), pressure(1,1,0:1).
  integer(int32) function prepare_selected_fresh_forecast(state, physics, model, loop, io, lforcenl) result(status)
    type(native_fresh_forecast_state), intent(inout) :: state
    type(native_physics_runtime_data), target, intent(inout) :: physics
    type(native_operational_model_configuration), intent(inout) :: model
    type(native_loop_data), intent(in) :: loop
    type(native_forecast_io_controls), intent(in) :: io
    logical, intent(in) :: lforcenl
    status = prepare_fresh_forecast(state, physics, model, loop, io, lforcenl, .false.)
  end function
!> The operational sibling admits every positive signed stop count.
  integer(int32) function prepare_operational_fresh_forecast(state, physics, model, loop, io, lforcenl) result(status)
    type(native_fresh_forecast_state), intent(inout) :: state
    type(native_physics_runtime_data), target, intent(inout) :: physics
    type(native_operational_model_configuration), intent(inout) :: model
    type(native_loop_data), intent(in) :: loop
    type(native_forecast_io_controls), intent(in) :: io
    logical, intent(in) :: lforcenl
    status = prepare_fresh_forecast(state, physics, model, loop, io, lforcenl, .true.)
  end function
  integer(int32) function prepare_fresh_forecast(state, physics, model, loop, io, lforcenl, operational) result(status)
    type(native_fresh_forecast_state), intent(inout) :: state
    type(native_physics_runtime_data), target, intent(inout) :: physics
    type(native_operational_model_configuration), intent(inout) :: model
    type(native_loop_data), intent(in) :: loop
    type(native_forecast_io_controls), intent(in) :: io
    logical, intent(in) :: lforcenl
    logical, intent(in) :: operational
    real(real64), allocatable :: u(:, :, :, :), v(:, :, :, :), t(:, :, :, :), q(:, :, :, :), sp(:, :, :)
    character(c_char) :: path(121)
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: incoming_errno, query_error, code
    integer :: j, last, allocation_status
    integer(int32) :: first_step, last_step
    status = 2
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. model%initial%ready) return
    if (state%owned_mask /= 0 .or. state%l_cld_deact .or. associated(state%physics)) return
    if (allocated(state%gpforcesp) .or. allocated(physics%gpforceu) .or. allocated(physics%gpforcev) .or. &
        allocated(physics%gpforcet) .or. allocated(physics%gpforceq)) return
    if (model%initial%controls%namespace%nconf /= 1 .or. model%initial%controls%namespace%lelam /= 0 .or. &
        model%initial%controls%namespace%lecmwf /= 1 .or. model%initial%controls%namespace%l_oops /= 0) return
    if (loop%lmoderr) return
    if (.not. model%physics%ecmwf_physics%lephys .or. .not. model%physics%ecmwf_physics%lepcld) return
    if (lforcenl) return
    first_step = model%initial%controls%clock%integration%first_step
    last_step = model%initial%controls%clock%integration%total_steps
    if (first_step /= 0 .or. last_step < 1) return
    if (.not. operational .and. last_step > 25) return
    last = 0
    do j = 1, 120
      if (iachar(io%cfrcf(j:j)) < 32 .or. iachar(io%cfrcf(j:j)) > 126) return
      path(j) = io%cfrcf(j:j)
      if (io%cfrcf(j:j) /= ' ') last = j
    end do
    if (last == 0) return
    path(last + 1) = c_null_char
! POSIX F_OK follows symlinks. Keep its errno effect private, as the old raw query did.
    call c_f_pointer(fresh_errno_location(), error_number)
    incoming_errno = error_number
    do
      code = pathname_exists(path, 0_c_int)
      query_error = error_number
      if (code == 0 .or. query_error /= 4) exit
    end do
    error_number = incoming_errno
    if (code == 0) then
      status = 3; return
    end if
    if (query_error /= 2) then
      status = 4; return
    end if
    allocate (u(1, 1, 1, 0:1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    allocate (v(1, 1, 1, 0:1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    allocate (t(1, 1, 1, 0:1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    allocate (q(1, 1, 1, 0:1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    allocate (sp(1, 1, 0:1), stat=allocation_status)
    if (allocation_status /= 0) goto800
! These80 payload bytes are deliberately unwritten.
    call move_alloc(u, physics%gpforceu)
    call move_alloc(v, physics%gpforcev)
    call move_alloc(t, physics%gpforcet)
    call move_alloc(q, physics%gpforceq)
    call move_alloc(sp, state%gpforcesp)
    state%physics => physics
    model%initial%controls%clock%first_step = first_step
    model%initial%controls%clock%total_steps = last_step
    model%initial%controls%clock%model_number = 1
    model%initial%controls%clock%current_step = -999
    model%initial%controls%namespace%lnf = 1
    state%owned_mask = 31
    status = 0
    return
800 continue
    if (allocated(sp)) deallocate (sp)
    if (allocated(q)) deallocate (q)
    if (allocated(t)) deallocate (t)
    if (allocated(v)) deallocate (v)
    if (allocated(u)) deallocate (u)
    status = 1
  end function
!> Release SP,Q,T,V,U, then clear the mask. Borrowed records outlive this call.
!! The source release retains natural allocator status and does not clear unrelated fields.
  integer(int32) function release_selected_fresh_forecast(state) result(status)
    type(native_fresh_forecast_state), intent(inout) :: state
    status = 0
    if (state%owned_mask == 0) return
    status = 2
    if (state%owned_mask /= 31 .or. .not. associated(state%physics)) return
    if (.not. allocated(state%gpforcesp) .or. .not. allocated(state%physics%gpforceq) .or. &
        .not. allocated(state%physics%gpforcet) .or. .not. allocated(state%physics%gpforcev) .or. &
        .not. allocated(state%physics%gpforceu)) return
    deallocate (state%gpforcesp)
    deallocate (state%physics%gpforceq)
    deallocate (state%physics%gpforcet)
    deallocate (state%physics%gpforcev)
    deallocate (state%physics%gpforceu)
    nullify (state%physics)
    state%owned_mask = 0
    status = 0
  end function
end module
