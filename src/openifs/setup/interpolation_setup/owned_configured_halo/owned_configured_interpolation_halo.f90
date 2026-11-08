!> Compose native policy, spherical width and distributed interpolation maps.
module forecast_owned_interpolation_halo
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_parallel_interpolation_controls, only: parallel_interpolation_controls
  use forecast_interpolation_geometry_views, only: native_interpolation_map_views, &
                                                   make_native_interpolation_grid_parameters, borrow_native_interpolation_map_views
  use forecast_interpolation_local_maps, only: native_interpolation_grid_parameters
  use forecast_interpolation_buffer_setup, only: initialize_distributed_interpolation_buffer, &
                                                 interpolation_global_halo_capacity
  use forecast_spherical_interpolation_halo, only: initialize_native_spherical_interpolation_halo
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  implicit none
  private
  public :: initialize_owned_distributed_interpolation_halo
  public :: initialize_configured_operational_interpolation_halo
  ! Compile-time rank identities; only the live context prefix is borrowed.
  integer :: rank_literal
  integer(int32), parameter :: maximum_process_count = 65536
  integer(int32), parameter :: identity_process_ids(maximum_process_count) = &
                               [(int(rank_literal, int32), rank_literal=1, maximum_process_count)]
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Bind the one canonical partition and geometry to complete SLCSET/SLRSET.
  !! GEOMETRY is the live stable owner already held by CONFIGURATION%INITIAL.
  !! Every process enters under the same live public communication context.
  !! BUDGET is the admitted private communication limit in bytes; REPORT_UNIT
  !! is the source output unit. This entry does not create or end messages.
  !! Status2 refuses without publishing arrays. The child owns rollback on an
  !! allocation failure1; success0 publishes its complete interpolation maps.
  integer(int32) function initialize_owned_distributed_interpolation_halo(geometry, configuration, &
                                                                 budget, report_unit, child_status, allocator_detail) result(status)
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(inout) :: configuration
    integer(int64), intent(in) :: budget
    integer(int32), intent(in) :: report_unit
    integer(int32), intent(out) :: child_status
    integer(int32), optional, intent(out) :: allocator_detail
    type(native_interpolation_grid_parameters) :: grid
    type(native_interpolation_map_views) :: views
    integer(int32) :: local_status, allocation_status
    integer(int64) :: capacity
    status = 2; child_status = 2
    if (present(allocator_detail)) allocator_detail = 0
    if (.not. geometry%transform_control%message_ready) return
    local_status = 0
    if (.not. same_configuration_geometry(configuration, geometry)) local_status = 2
    if (budget < 1_int64) local_status = 2
    if (geometry%transform_control%nproc < 1 .or. geometry%transform_control%nproc > maximum_process_count) local_status = 2
    if (local_status == 0) local_status = make_native_interpolation_grid_parameters(geometry, grid)
    if (local_status == 0) local_status = borrow_native_interpolation_map_views(geometry, views)
    if (.not. allocated(geometry%transform_control%ngpset2pe)) local_status = 2
    capacity = 0_int64
    if (local_status == 0) then
      capacity = interpolation_global_halo_capacity(views%kloeng, grid%ndglg)
      if (capacity < 1_int64) local_status = 2
    end if
    child_status = agree_control_status(geometry%transform_control, local_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    status = initialize_distributed_interpolation_buffer(configuration%interpolation, grid, &
                                           views%ksta, views%konl, views%kloeng, views%kptrfrstlat, views%kfrstlat, views%klstlat, &
                                               views%kaset, views%kbset, identity_process_ids(1:geometry%transform_control%nproc), &
                                         geometry%transform_control, capacity, budget, report_unit, child_status, allocation_status)
    if (present(allocator_detail)) allocator_detail = allocation_status
  end function

  !> Apply the actual NAMPAR1 policy before width arithmetic and map creation.
  !! The selected source path uses two-time-level spherical transport, source
  !! VMAX1=250 m/s, VMAX2=400 m/s and a450s step. Model configuration and the
  !! small SUSLB maps are complete. Interpolation map owners start absent.
  !! The caller owns POLICY and obtains it from the actual first group.
  !! Failure restores all five scalar fields changed by the width calculation;
  !! the map child releases every newly staged owner before returning.
  integer(int32) function initialize_configured_operational_interpolation_halo(geometry, configuration, policy, &
                                                                 budget, report_unit, child_status, allocator_detail) result(status)
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(inout) :: configuration
    type(parallel_interpolation_controls), intent(in) :: policy
    integer(int64), intent(in) :: budget
    integer(int32), intent(in) :: report_unit
    integer(int32), intent(out) :: child_status
    integer(int32), optional, intent(out) :: allocator_detail
    integer(int32) :: local_status, saved_width
    real(real64) :: saved_vmax1, saved_vmax2
    character(len=2) :: saved_code
    logical :: saved_on_demand
    status = 2; child_status = 2
    if (present(allocator_detail)) allocator_detail = 0
    if (.not. geometry%transform_control%message_ready) return
    local_status = 0
    if (.not. same_configuration_geometry(configuration, geometry)) local_status = 2
    if (local_status == 0) then
      if (configuration%initial%controls%namespace%nconf /= 1) local_status = 2
      if (configuration%initial%controls%namespace%lelam /= 0) local_status = 2
      if (transfer(configuration%dynamics%ltwotl, 0_int32) /= 1) local_status = 2
      if (transfer(configuration%dynamics%lslag, 0_int32) /= 1) local_status = 2
      if (configuration%buffers%first%nfldslb1 < 1) local_status = 2
      if (configuration%buffers%second%nfldslb2 < 1) local_status = 2
      if (.not. allocated(configuration%buffers%first%rparsl1)) local_status = 2
      if (configuration%interpolation%naslb1 /= 0 .or. configuration%interpolation%naslb1_true /= 0) local_status = 2
      if (configuration%interpolation%nslwide /= 0 .or. configuration%interpolation%cver /= 'XX') local_status = 2
      if (.not. fresh_halo_owners(configuration%interpolation)) local_status = 2
      if (transfer(configuration%interpolation_controls%vmax1, 0_int64) /= transfer(250.0_real64, 0_int64)) local_status = 2
      if (transfer(configuration%interpolation_controls%vmax2, 0_int64) /= transfer(400.0_real64, 0_int64)) local_status = 2
      if (transfer(configuration%initial%controls%clock%dt, 0_int64) /= transfer(450.0_real64, 0_int64)) local_status = 2
    end if
    if (.not. policy%ready) local_status = 2
    if (.not. logical_word(policy%lsync_slcom) .or. .not. logical_word(policy%lsldebug)) local_status = 2
    if (.not. logical_word(policy%lslondem) .or. .not. logical_word(policy%lsync_trans)) local_status = 2
    child_status = agree_control_status(geometry%transform_control, local_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    saved_vmax1 = configuration%interpolation_controls%vmax1
    saved_vmax2 = configuration%interpolation_controls%vmax2
    saved_width = configuration%interpolation%nslwide
    saved_code = configuration%interpolation%cver
    saved_on_demand = configuration%interpolation%lslondem
    local_status = initialize_native_spherical_interpolation_halo(geometry, configuration%initial%controls, &
                                    configuration%dynamics, configuration%interpolation_controls, configuration%initial%constants, &
                                                                  policy%lslondem, configuration%interpolation)
    child_status = agree_control_status(geometry%transform_control, local_status)
    if (child_status == 0) then
      status = initialize_owned_distributed_interpolation_halo(geometry, configuration, budget, report_unit, &
                                                               child_status, allocator_detail)
      if (status == 0) return
    else
      status = child_status
    end if
    configuration%interpolation_controls%vmax1 = saved_vmax1
    configuration%interpolation_controls%vmax2 = saved_vmax2
    configuration%interpolation%cver = saved_code
    configuration%interpolation%lslondem = saved_on_demand
    configuration%interpolation%nslwide = saved_width
  end function

  !> Admit the same fifteen absent source owners before width arithmetic.
  logical function fresh_halo_owners(state) result(fresh)
    type(native_interpolation_state), intent(in) :: state
    fresh = .false.
    if (allocated(state%nloeng) .or. allocated(state%nslsta) .or. allocated(state%nslonl)) return
    if (allocated(state%nsloff) .or. allocated(state%nslmap) .or. allocated(state%nslcore)) return
    if (allocated(state%nslext) .or. allocated(state%mask_sl1) .or. allocated(state%mask_sl2)) return
    if (allocated(state%mask_sld) .or. allocated(state%nslsendpos) .or. allocated(state%nslrecvpos)) return
    if (allocated(state%nslsendptr) .or. allocated(state%nslrecvptr) .or. allocated(state%nslcomm)) return
    fresh = .true.
  end function

  !> Confirm the actual owner associations without reading private ABI bytes.
  logical function same_configuration_geometry(configuration, geometry) result(same)
    type(native_operational_model_configuration), target, intent(in) :: configuration
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_geometry_state), pointer :: owned
    same = .false.
    if (.not. configuration%ready .or. .not. associated(configuration%initial)) return
    if (.not. configuration%initial%ready) return
    if (.not. allocated(configuration%initial%geometry)) return
    if (.not. associated(configuration%partition)) return
    owned => configuration%initial%geometry
    if (.not. associated(owned, geometry)) return
    if (.not. associated(configuration%partition, geometry%partition)) return
    same = geometry%initialized .and. geometry%partition%phase == 7
  end function

  !> Preserve numerical flags and errno across an added metadata agreement.
  integer(int32) function agree_control_status(control, local_status) result(status)
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: local_status
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: incoming_errno
    call c_f_pointer(errno_address(), error_number)
    incoming_errno = error_number
    call ieee_get_status(incoming)
    status = agree_distributed_partition_status(control, local_status)
    call ieee_set_status(incoming)
    error_number = incoming_errno
  end function

  pure logical function logical_word(value) result(valid)
    logical, intent(in) :: value
    integer(int32) :: word
    word = transfer(value, 0_int32)
    valid = word == 0 .or. word == 1
  end function
end module forecast_owned_interpolation_halo
