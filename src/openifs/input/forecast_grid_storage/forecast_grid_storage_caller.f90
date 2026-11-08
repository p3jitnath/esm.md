!> Run the real GP_MODEL child with the one canonical persistent work owner.
module forecast_grid_storage_caller
  use iso_fortran_env, only: int32, int64, real64
  use forecast_grid_work_state, only: native_grid_work_state
  use forecast_grid_storage, only: initialize_forecast_grid_work, forecast_grid_work_sizes
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs, gp_model
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: run_selected_forecast_grid_storage, run_runtime_forecast_grid_storage
  public :: forecast_grid_storage_count_get
contains
  !> Run the retained P24,L19,B86 storage caller and complete native child.
  !! INPUTS borrows actual produced model, field, physics and column-view owners.
  !! WORK stays TARGET and fixed until every input view is closed before release.
  !! The caller establishes nearest-even arithmetic with gradual underflow.
  !! CALL_COUNT is the explicit native counterpart of the source int64 counter.
  !! BYTE_QUOTA covers the four persistent arrays, excluding child private work.
  !! Status0 completes the child. Other values retain its natural boundary and owners.
  integer(int32) function run_selected_forecast_grid_storage(work, inputs, call_count, byte_quota, profile) result(status)
    type(native_grid_work_state), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: inputs
    integer(int64), intent(inout) :: call_count
    integer(int64), intent(in) :: byte_quota
    type(transform_profile_policy), intent(in), optional :: profile
    status = run_grid_storage(work, inputs, call_count, byte_quota, .true., profile)
  end function

  !> Use the same storage and child sequence with live runtime dimensions.
  !! Dimensions come from the same produced model and local partition as INPUTS.
  !! Every numerical child retains its own admitted domain. This extension
  !! changes storage sizing only and adds no separate source counterpart.
  integer(int32) function run_runtime_forecast_grid_storage(work, inputs, call_count, byte_quota, profile) result(status)
    type(native_grid_work_state), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: inputs
    integer(int64), intent(inout) :: call_count
    integer(int64), intent(in) :: byte_quota
    type(transform_profile_policy), intent(in), optional :: profile
    status = run_grid_storage(work, inputs, call_count, byte_quota, .false., profile)
  end function

  integer(int32) function run_grid_storage(work, inputs, call_count, byte_quota, selected, profile) result(status)
    type(native_grid_work_state), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: inputs
    integer(int64), intent(inout) :: call_count
    integer(int64), intent(in) :: byte_quota
    logical, intent(in) :: selected
    type(transform_profile_policy), intent(in), optional :: profile
    integer(int32) :: p, l, b, s, f1, f2
    integer(int64) :: n, spans(4), total
    real(real64) :: hook
    status = 2_int32
    if (.not. associated(inputs%model)) return
    if (.not. inputs%model%ready .or. .not. associated(inputs%model%initial)) return
    if (.not. allocated(inputs%model%initial%geometry)) return
    if (.not. inputs%model%initial%geometry%initialized) return
    p = inputs%model%initial%geometry%dimensions%nproma
    l = inputs%model%initial%geometry%dimensions%nflevg
    b = inputs%model%initial%geometry%partition%ngpblks
    s = inputs%model%linear_full%ndim
    n = int(inputs%model%interpolation%naslb1, int64)
    f1 = inputs%model%buffers%first%nfldslb1
    f2 = inputs%model%buffers%second%nfldslb2
    if (selected) then
      if (any([p, l, b, s, f1, f2] /= [24, 19, 86, 12, 463, 153]) .or. n /= 3101_int64) return
    end if
    status = forecast_grid_work_sizes(p, l, b, s, n, f1, f2, spans, total)
    if (status /= 0_int32) return
    status = 2_int32
    if (byte_quota < total) return
    call transform_profile_event('GP_MODEL_HEAP2', 0_int32, hook, profile)
    status = initialize_forecast_grid_work(work, p, l, b, s, n, f1, f2, byte_quota)
    if (status == 0_int32) then
      ! The data-only factory binds its column views after this same allocation.
      ! Direct whole-array arguments always borrow these actual canonical owners.
      inputs%first_buffer(0:n - 1_int64, 1:f1) => work%zslbuf1
      inputs%second_buffer => work%zslbuf2
      inputs%transport_arrays%parent_index => work%il0
      inputs%transport_arrays%linear_weights => work%zlscaw
      status = gp_model(inputs, profile)
      call increment_source_counter(call_count)
    end if
    call transform_profile_event('GP_MODEL_HEAP2', 1_int32, hook, profile)
  end function

  !> Read the source call counter from its one caller-owned native target.
  integer(int64) function forecast_grid_storage_count_get(call_count) result(value)
    integer(int64), intent(in) :: call_count
    value = call_count
  end function
end module forecast_grid_storage_caller
