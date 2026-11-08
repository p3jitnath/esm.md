!> Own staged forecast-work lifetime while borrowing the real model and field owners.
module forecast_staged_work_storage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_null_ptr, c_loc, c_associated
  use ieee_exceptions, only: ieee_status_type
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_native_dynamic_storage
  use forecast_next_time_field_storage, only: native_next_time_gridpoint_state, next_time_field_shape, &
                        prepare_operational_next_time_fields, prepare_runtime_next_time_fields, release_operational_next_time_fields
  implicit none
  private
  public :: native_forecast_work_storage, create_operational_forecast_work_storage
  public :: create_distributed_forecast_work_storage, advance_forecast_work_storage, release_forecast_work_storage
  type native_forecast_work_storage
    type(native_operational_model_configuration), pointer :: model => null()
    type(native_forecast_dynamic_storage), pointer :: dynamic => null()
    type(native_next_time_gridpoint_state), pointer :: next => null()
    type(c_ptr) :: bases(6) = c_null_ptr
    integer(int32) :: phase = 0, pitch = 0, levels = 0, blocks = 0, points = 0
    integer(int64) :: byte_limit = 0
    logical :: distributed = .false.
  end type
contains
!> Historical operational entry requires P17,L137,B388217.
!! MODEL,DYNAMIC,NEXT are TARGET and remain stable until release.
!! BYTE_LIMIT bounds the aggregate six logical payloads; callers separately admit outer storage.
  integer(int32) function create_operational_forecast_work_storage(output, model, dynamic, next, byte_limit) result(status)
    type(native_forecast_work_storage), allocatable, target, intent(inout) :: output
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_forecast_dynamic_storage), target, intent(inout) :: dynamic
    type(native_next_time_gridpoint_state), target, intent(inout) :: next
    integer(int64), intent(in) :: byte_limit
    status = create_work(output, model, dynamic, next, byte_limit, .false.)
  end function
!> Distributed/runtime entry derives B=ceiling(local physical points/P).
!! L remains137; P is1:1024 and B1:388217. No stored global shape replaces the live counts.
  integer(int32) function create_distributed_forecast_work_storage(output, model, dynamic, next, byte_limit) result(status)
    type(native_forecast_work_storage), allocatable, target, intent(inout) :: output
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_forecast_dynamic_storage), target, intent(inout) :: dynamic
    type(native_next_time_gridpoint_state), target, intent(inout) :: next
    integer(int64), intent(in) :: byte_limit
    status = create_work(output, model, dynamic, next, byte_limit, .true.)
  end function
  integer(int32) function create_work(output, model, dynamic, next, byte_limit, distributed) result(status)
    type(native_forecast_work_storage), allocatable, target, intent(inout) :: output
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_forecast_dynamic_storage), target, intent(inout) :: dynamic
    type(native_next_time_gridpoint_state), target, intent(inout) :: next
    integer(int64), intent(in) :: byte_limit
    logical, intent(in) :: distributed
    type(native_forecast_work_storage), allocatable :: pending
    type(ieee_status_type) :: fp
    integer(int32) :: error_number, p, l, b, n
    integer :: allocation_status
    status = 2
    if (allocated(output) .or. byte_limit < 0) return
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    if (.not. model%initial%geometry%initialized) return
    p = model%initial%geometry%dimensions%nproma
    l = model%initial%geometry%dimensions%nflevg
    b = model%initial%geometry%partition%ngpblks
    n = model%initial%geometry%partition%ngptot
    if (l /= 137) return
    if (distributed) then
      if (p < 1 .or. p > 1024 .or. b < 1 .or. b > 388217 .or. n < 1) return
      if ((int(n, int64) + p - 1_int64)/p /= b) return
      if (.not. associated(model%partition, model%initial%geometry%partition)) return
    else
      if (p /= 17 .or. b /= 388217) return
    end if
    if (model%initial%controls%clock%integration%first_step /= 0 .or. &
        model%initial%controls%clock%integration%total_steps < 1) return
    if (.not. model%interpolation_controls%lsldp_xyz .or. .not. model%interpolation_controls%lsldp_save) return
    if (.not. model%physics%ecmwf_physics%lslphy) return
    if (allocated(dynamic%rsavedp) .or. allocated(dynamic%rslwx) .or. allocated(dynamic%savtend)) return
    if (allocated(model%motion%gmvt1) .or. allocated(model%motion%gmvt1s) .or. allocated(next%gflt1)) return
    call save_lifetime_status(fp, error_number)
    allocate (pending, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
    else
      status = allocate_saved_departure_points(dynamic, model, .true., byte_limit)
      if (status == 0) then
        pending%model => model; pending%dynamic => dynamic; pending%next => next
        pending%pitch = p; pending%levels = l; pending%blocks = b; pending%points = n
        pending%phase = 1; pending%byte_limit = byte_limit; pending%distributed = distributed
        pending%bases(1) = c_loc(dynamic%rsavedp(1, 1, 1, 1))
        call move_alloc(pending, output)
      end if
    end if
    call restore_lifetime_status(fp, error_number)
  end function
!> Advance exactly one source storage stage: RSLWX, SAVTEND, then next-time fields.
!! Intervening source setup and initial-field loading belong to the enclosing controller.
  integer(int32) function advance_forecast_work_storage(state) result(status)
    type(native_forecast_work_storage), intent(inout) :: state
    type(ieee_status_type) :: fp
    type(next_time_field_shape) :: shape
    integer(int32) :: error_number
    integer(int64) :: remaining
    status = 2
    if (.not. valid_work(state)) return
    if (state%phase == 4) return
    remaining = state%byte_limit - current_payload_bytes(state)
    call save_lifetime_status(fp, error_number)
    select case (state%phase)
    case (1)
      status = initialize_lagged_tendency_configuration(state%dynamic, state%model, .true., remaining)
      if (status == 0) state%bases(2) = c_loc(state%dynamic%rslwx(1))
    case (2)
      status = allocate_saved_physics_tendencies(state%dynamic, state%model, .true., remaining)
      if (status == 0) state%bases(3) = c_loc(state%dynamic%savtend(1, 1, 1, 1))
    case (3)
      shape%pitch = state%pitch; shape%levels = state%levels; shape%blocks = state%blocks
      shape%constituent_fields = state%model%fields%registration%ndim1
      if (state%distributed) then
        status = prepare_runtime_next_time_fields(state%model%motion, state%next, shape, remaining)
      else
        status = prepare_operational_next_time_fields(state%model%motion, state%next, shape, remaining)
      end if
      if (status == 0) then
        if (size(state%model%motion%gmvt1) > 0) state%bases(4) = c_loc(state%model%motion%gmvt1(1, 1, 1, 1))
        if (size(state%model%motion%gmvt1s) > 0) state%bases(5) = c_loc(state%model%motion%gmvt1s(1, 1, 1))
        if (size(state%next%gflt1) > 0) state%bases(6) = c_loc(state%next%gflt1(1, 1, 1, 1))
      end if
    end select
    if (status == 0) state%phase = state%phase + 1
    call restore_lifetime_status(fp, error_number)
  end function
!> Check pinned shape, phase, associations and exact acquired bases before mutation.
  logical function valid_work(state) result(valid)
    type(native_forecast_work_storage), intent(in) :: state
    valid = .false.
    if (.not. associated(state%model) .or. .not. associated(state%dynamic) .or. .not. associated(state%next)) return
    if (state%phase < 1 .or. state%phase > 4) return
    if (.not. state%model%ready .or. .not. associated(state%model%initial)) return
    if (.not. allocated(state%model%initial%geometry)) return
    if (state%model%initial%geometry%dimensions%nproma /= state%pitch .or. &
        state%model%initial%geometry%dimensions%nflevg /= state%levels .or. &
        state%model%initial%geometry%partition%ngpblks /= state%blocks .or. &
        state%model%initial%geometry%partition%ngptot /= state%points) return
    if (.not. allocated(state%dynamic%rsavedp)) return
    if (.not. c_associated(state%bases(1), c_loc(state%dynamic%rsavedp(1, 1, 1, 1)))) return
    if (state%phase >= 2) then
      if (.not. allocated(state%dynamic%rslwx)) return
      if (.not. c_associated(state%bases(2), c_loc(state%dynamic%rslwx(1)))) return
    else
      if (allocated(state%dynamic%rslwx)) return
    end if
    if (state%phase >= 3) then
      if (.not. allocated(state%dynamic%savtend)) return
      if (.not. c_associated(state%bases(3), c_loc(state%dynamic%savtend(1, 1, 1, 1)))) return
    else
      if (allocated(state%dynamic%savtend)) return
    end if
    if (state%phase == 4) then
      if (.not. allocated(state%model%motion%gmvt1) .or. .not. allocated(state%model%motion%gmvt1s) .or. &
          .not. allocated(state%next%gflt1)) return
      if (size(state%model%motion%gmvt1) > 0) then
        if (.not. c_associated(state%bases(4), c_loc(state%model%motion%gmvt1(1, 1, 1, 1)))) return
      end if
      if (size(state%model%motion%gmvt1s) > 0) then
        if (.not. c_associated(state%bases(5), c_loc(state%model%motion%gmvt1s(1, 1, 1)))) return
      end if
      if (size(state%next%gflt1) > 0) then
        if (.not. c_associated(state%bases(6), c_loc(state%next%gflt1(1, 1, 1, 1)))) return
      end if
    else
      if (allocated(state%model%motion%gmvt1) .or. allocated(state%model%motion%gmvt1s) .or. &
          allocated(state%next%gflt1)) return
    end if
    valid = .true.
  end function
  integer(int64) function current_payload_bytes(state) result(bytes)
    type(native_forecast_work_storage), intent(in) :: state
    bytes = 8_int64*size(state%dynamic%rsavedp, kind=int64)
    if (allocated(state%dynamic%rslwx)) bytes = bytes + 8_int64*size(state%dynamic%rslwx, kind=int64)
    if (allocated(state%dynamic%savtend)) bytes = bytes + 8_int64*size(state%dynamic%savtend, kind=int64)
    if (allocated(state%model%motion%gmvt1)) bytes = bytes + 8_int64*size(state%model%motion%gmvt1, kind=int64)
    if (allocated(state%model%motion%gmvt1s)) bytes = bytes + 8_int64*size(state%model%motion%gmvt1s, kind=int64)
    if (allocated(state%next%gflt1)) bytes = bytes + 8_int64*size(state%next%gflt1, kind=int64)
  end function
!> Release only the six acquired arrays and this small owner; retain every borrowed outer owner.
  integer(int32) function release_forecast_work_storage(output) result(status)
    type(native_forecast_work_storage), allocatable, intent(inout) :: output
    type(ieee_status_type) :: fp
    integer(int32) :: error_number, ignored
    status = 0
    if (.not. allocated(output)) return
    status = 2
    if (.not. valid_work(output)) return
    call save_lifetime_status(fp, error_number)
    if (output%phase == 4) ignored = release_operational_next_time_fields(output%model%motion, output%next)
    ignored = release_forecast_dynamic_storage(output%dynamic)
    deallocate (output)
    status = 0
    call restore_lifetime_status(fp, error_number)
  end function
end module
