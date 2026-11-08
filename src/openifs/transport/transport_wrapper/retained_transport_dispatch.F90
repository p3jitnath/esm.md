!> Dispatch retained CALL_SL work through complete own native calculations.
module forecast_retained_transport_dispatch
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_semi_lagrangian_buffer_types, only: native_semi_lagrangian_buffers, native_interpolation_controls
  use forecast_geometry_block_storage, only: native_spherical_block_view
  use md2asm_internal_interpolation_plane_maps, only: interpolation_plane_controls, linear_weight_plane_map, &
                                                      nonlinear_weight_plane_map, cartesian_coordinate_plane_map
  use md2asm_semi_lagrangian_transport_stage, only: transport_stage_controls, transport_trajectory_inputs, &
                              transport_update_inputs, transport_block_views, transport_stage_counts, advance_semi_lagrangian_stages
  use md2asm_transport_work_storage, only: transport_work_storage, ensure_transport_work_storage, &
                                           record_completed_transport_call, release_transport_work_storage
  use md2asm_transport_source_buffer_views, only: bind_first_transport_buffer_sources
  use md2asm_interpolation_weight_views, only: bind_interpolation_weight_views
  use md2asm_transport_geometry_block_views, only: bind_transport_geometry_block_views
  use md2asm_native_call_sl, only: advance_native_call_sl, native_call_sl_arrays
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: native_retained_transport_context, call_sl_heap2, runtime_retained_transport
  public :: release_runtime_retained_transport, call_sl_heap2_count_get
  integer(int64), save :: legacy_calls = 0_int64
  !> One caller owns this state for the complete transport lifetime.
  !! work is the existing canonical three-array owner,not another payload type.
  !! busy prevents a recursive use of the same native context. All borrowed
  !! work views end before resize,release or operating-system page advice.
  type :: native_retained_transport_context
    type(transport_work_storage) :: work
    logical :: busy = .false.
  end type
contains
  !> Keep shape reuse,resize,rollback and completion in the complete own child.
  !! Native array/control units,bounds and mutations match advance_native_call_sl.
  !! The explicit context replaces the original private128-byte record and the
  !! selected process-global owner. Runtime physical and model inputs are the
  !! child's real typed controls/arrays,never defaults or an Arm record.
  !! The selected wrapper retains P24/L19/N2048;runtime follows its declared
  !! child domain. Unsupported child controls return their typed status.
  !! Source profiling and legacy completion counters are preserved.
  !! Optional historical completed-page advice is a separate native service;
  !! this default source route retains private pages,as its build defines.
  subroutine advance_retained_transport(selected, &
                                        comm, c, sl, buffers, buffer_controls, plane_controls, linear_map, &
                                   nonlinear_map, nonlinear_half_map, cartesian_map, geometry, buffer, arrays, trajectory, update, &
                                        retained, counts, status, workspace_limit, profile)
    type(MPI_Comm), intent(in) :: comm
    type(transport_stage_controls), intent(in) :: c
    type(native_interpolation_state), target, intent(in) :: sl
    type(native_semi_lagrangian_buffers), intent(in) :: buffers
    type(native_interpolation_controls), intent(in) :: buffer_controls
    type(interpolation_plane_controls), intent(in) :: plane_controls
    type(linear_weight_plane_map), intent(in) :: linear_map
    type(nonlinear_weight_plane_map), intent(in) :: nonlinear_map, nonlinear_half_map
    type(cartesian_coordinate_plane_map), intent(in) :: cartesian_map
    type(native_spherical_block_view), intent(in) :: geometry(:)
    real(real64), contiguous, target, intent(inout) :: buffer(0:, :)
    type(native_call_sl_arrays), intent(inout) :: arrays
    type(transport_trajectory_inputs), intent(in) :: trajectory
    type(transport_update_inputs), intent(in) :: update
    type(native_retained_transport_context), target, intent(inout) :: retained
    type(transport_stage_counts), intent(inout) :: counts
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: workspace_limit
    type(transform_profile_policy), intent(in), optional :: profile
    logical, intent(in) :: selected
    real(real64) :: profile_handle
    status = 2
    if (retained%busy) return
    if (retained%work%completed_calls < 0 .or. retained%work%completed_calls >= 2_int64**60) return
    if (retained%work%allocations < 0 .or. retained%work%allocations >= 2_int64**60) return
    if (retained%work%releases < 0 .or. retained%work%releases >= 2_int64**60) return
    if (selected) then
      if (c%pitch /= 24 .or. c%levels /= 19 .or. c%point_count /= 2048) return
    end if
    retained%busy = .true.
    if (selected) call transform_profile_event("CALL_SL_HEAP2", 0_int32, profile_handle, profile)
    call advance_native_call_sl(comm, c, sl, buffers, buffer_controls, plane_controls, linear_map, &
                                nonlinear_map, nonlinear_half_map, cartesian_map, geometry, buffer, arrays, trajectory, update, &
                                retained%work, counts, status, workspace_limit)
    if (status == 0 .and. selected) call increment_source_counter(legacy_calls)
    retained%busy = .false.
    if (selected) call transform_profile_event("CALL_SL_HEAP2", 1_int32, profile_handle, profile)
  end subroutine

  subroutine call_sl_heap2( &
    comm, c, sl, buffers, buffer_controls, plane_controls, linear_map, &
    nonlinear_map, nonlinear_half_map, cartesian_map, geometry, buffer, arrays, trajectory, update, &
    retained, counts, status, workspace_limit, profile)
    type(MPI_Comm), intent(in) :: comm
    type(transport_stage_controls), intent(in) :: c
    type(native_interpolation_state), target, intent(in) :: sl
    type(native_semi_lagrangian_buffers), intent(in) :: buffers
    type(native_interpolation_controls), intent(in) :: buffer_controls
    type(interpolation_plane_controls), intent(in) :: plane_controls
    type(linear_weight_plane_map), intent(in) :: linear_map
    type(nonlinear_weight_plane_map), intent(in) :: nonlinear_map, nonlinear_half_map
    type(cartesian_coordinate_plane_map), intent(in) :: cartesian_map
    type(native_spherical_block_view), intent(in) :: geometry(:)
    real(real64), contiguous, target, intent(inout) :: buffer(0:, :)
    type(native_call_sl_arrays), intent(inout) :: arrays
    type(transport_trajectory_inputs), intent(in) :: trajectory
    type(transport_update_inputs), intent(in) :: update
    type(native_retained_transport_context), target, intent(inout) :: retained
    type(transport_stage_counts), intent(inout) :: counts
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: workspace_limit
    type(transform_profile_policy), intent(in), optional :: profile
    call advance_retained_transport(.true., &
                                    comm, c, sl, buffers, buffer_controls, plane_controls, linear_map, &
                                   nonlinear_map, nonlinear_half_map, cartesian_map, geometry, buffer, arrays, trajectory, update, &
                                    retained, counts, status, workspace_limit, profile)
  end subroutine

  subroutine runtime_retained_transport( &
    comm, c, sl, buffers, buffer_controls, plane_controls, linear_map, &
    nonlinear_map, nonlinear_half_map, cartesian_map, geometry, buffer, arrays, trajectory, update, &
    retained, counts, status, workspace_limit, profile)
    type(MPI_Comm), intent(in) :: comm
    type(transport_stage_controls), intent(in) :: c
    type(native_interpolation_state), target, intent(in) :: sl
    type(native_semi_lagrangian_buffers), intent(in) :: buffers
    type(native_interpolation_controls), intent(in) :: buffer_controls
    type(interpolation_plane_controls), intent(in) :: plane_controls
    type(linear_weight_plane_map), intent(in) :: linear_map
    type(nonlinear_weight_plane_map), intent(in) :: nonlinear_map, nonlinear_half_map
    type(cartesian_coordinate_plane_map), intent(in) :: cartesian_map
    type(native_spherical_block_view), intent(in) :: geometry(:)
    real(real64), contiguous, target, intent(inout) :: buffer(0:, :)
    type(native_call_sl_arrays), intent(inout) :: arrays
    type(transport_trajectory_inputs), intent(in) :: trajectory
    type(transport_update_inputs), intent(in) :: update
    type(native_retained_transport_context), target, intent(inout) :: retained
    type(transport_stage_counts), intent(inout) :: counts
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: workspace_limit
    type(transform_profile_policy), intent(in), optional :: profile
    call advance_retained_transport(.false., &
                                    comm, c, sl, buffers, buffer_controls, plane_controls, linear_map, &
                                   nonlinear_map, nonlinear_half_map, cartesian_map, geometry, buffer, arrays, trajectory, update, &
                                    retained, counts, status, workspace_limit, profile)
  end subroutine

  !> Release the canonical payloads in coordinates,weights,indices order.
  !! No consumer or borrowed view may be live. Native empty release succeeds.
  subroutine release_runtime_retained_transport(retained, status)
    type(native_retained_transport_context), intent(inout) :: retained
    integer(int32), intent(out) :: status
    status = 2
    if (retained%busy) return
    call release_transport_work_storage(retained%work, status)
    if (status == 0) retained%busy = .false.
  end subroutine
  integer(int64) function call_sl_heap2_count_get() result(calls)
    calls = legacy_calls
  end function
end module forecast_retained_transport_dispatch
