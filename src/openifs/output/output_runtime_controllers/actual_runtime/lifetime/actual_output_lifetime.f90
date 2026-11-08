!> Release only storage acquired by the actual output path.
!! No source scalar or foreign owner is read. Native allocation descriptors
!! make the same entry valid for fresh and partially acquired execution state.
module forecast_actual_output_lifetime
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer, c_null_ptr
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_output_controller, only: native_fullpos_driver_context
  use forecast_fullpos_state_types, only: native_fullpos_data
  use forecast_output_request_storage, only: release_output_header
  use forecast_actual_output_writer_bridge, only: release_actual_output_writer
  implicit none
  private
  public :: release_actual_output_runtime
  interface
    function error_address() bind(c, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Retire output payloads before the canonical Fullpos factory is released.
  !! context and data keep their native record identity. Borrowed weather,
  !! geometry, physical parameters and root clocks are never released here.
  !! The current no-horizontal, SCI0 route does not acquire DATA%YFPSUW.
  !! The caller retires that distinct factory-owned record through its owner.
  !! Status0 succeeds; floating-point status and errno retain incoming values.
  integer(int32) function release_actual_output_runtime(context, data) result(status)
    type(native_fullpos_driver_context), intent(inout) :: context
    type(native_fullpos_data), intent(inout) :: data
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: incoming_error
    logical :: header_owned
    call ieee_get_status(saved)
    call c_f_pointer(error_address(), error_slot)
    incoming_error = error_slot
    header_owned = allocated(data%yfpclimo%yrqphy%icod) .or. allocated(data%yfpclimo%yrqphy%igrib) .or. &
                   allocated(data%yfpclimo%yrqphy%llsurf) .or. allocated(data%yfpclimo%yrqphy%ivec) .or. &
                   allocated(data%yfpclimo%yrqphy%zlev) .or. allocated(data%yfpclimo%yrqphy%clname) .or. &
                   allocated(data%yfpclimo%yrqphy%clpref) .or. allocated(data%yfpclimo%yrqphy%idom) .or. &
                   allocated(data%yfpclimo%yrqphy%idmp) .or. allocated(data%yfpclimo%yrqphy%ivsetg) .or. &
                   allocated(data%yfpclimo%yrqphy%ivlocg) .or. allocated(data%yfpclimo%fpbuf)
    status = 0
    if (header_owned) status = release_output_header(data%yfpclimo, context%service_counters)
    nullify (data%yfpos)
    if (allocated(context%norm_partition%field_counts)) deallocate (context%norm_partition%field_counts)
    if (allocated(context%norm_partition%field_offsets)) deallocate (context%norm_partition%field_offsets)
    if (allocated(context%norm_partition%point_counts)) deallocate (context%norm_partition%point_counts)
    if (allocated(context%norm_partition%point_indices)) deallocate (context%norm_partition%point_indices)
    call release_actual_output_writer(context%actual_writer)
    context%actual_writer%geometry%latitudes = c_null_ptr
    context%actual_writer%geometry%points_per_row = c_null_ptr
    context%actual_writer%geometry%hybrid_a = c_null_ptr
    context%actual_writer%geometry%hybrid_b = c_null_ptr
    context%actual_writer%field_defaults%template = c_null_ptr
    nullify (context%model, context%model_fields, context%spectral, context%surface_metadata, context%surface_arrays)
    nullify (context%common, context%scalars, context%cloud, context%thermal)
    nullify (context%grid_sources%geometry, context%grid_sources%motion, context%grid_sources%constants)
    nullify (context%grid_sources%constituents)
    error_slot = incoming_error
    call ieee_set_status(saved)
  end function
end module
