!> Own complete selected and whole operational surface startup.
module forecast_owned_surface_state_startup
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use physical_constant_setup_port, only: forecast_physical_constants
  use yoephy, only: tephy
  use surface_field_configuration_port
  use surface_field_registration_port, only: surface_trajectory_metadata, surface_group_metadata, surface_field_totals
  use surface_field_storage_port
  use surface_default_assignment_port
  use surface_default_metadata_port
  use surface_input_configuration_port
  use partitioned_surface_field_placement_port, only: surface_input_owners
  use forecast_complete_initial_surface_loading, only: load_initial_surface_state, load_operational_initial_surface_state
  implicit none
  private
  public :: initialize_owned_selected_surface_state, initialize_owned_operational_surface_state
  public :: release_owned_surface_state, clear_surface_physics_descriptions
  type :: surface_parameter_route
    integer(int32) :: group, field, layer, parameter
  end type
  type(surface_parameter_route), parameter :: selected_routes(52) = [ &
                                              surface_parameter_route(1, 1, 1, 139), &
                                              surface_parameter_route(1, 1, 2, 170), &
                                              surface_parameter_route(1, 1, 3, 183), &
                                              surface_parameter_route(1, 1, 4, 236), &
                                              surface_parameter_route(1, 2, 1, 39), &
                                              surface_parameter_route(1, 2, 2, 40), &
                                              surface_parameter_route(1, 2, 3, 41), &
                                              surface_parameter_route(1, 2, 4, 42), &
                                              surface_parameter_route(1, 3, 1, 35), &
                                              surface_parameter_route(1, 3, 2, 36), &
                                              surface_parameter_route(1, 3, 3, 37), &
                                              surface_parameter_route(1, 3, 4, 38), &
                                              surface_parameter_route(3, 1, 0, 228008), &
                                              surface_parameter_route(3, 2, 0, 228009), &
                                              surface_parameter_route(3, 3, 0, 228010), &
                                              surface_parameter_route(3, 4, 0, 228011), &
                                              surface_parameter_route(3, 5, 0, 228012), &
                                              surface_parameter_route(3, 6, 0, 228013), &
                                              surface_parameter_route(3, 7, 0, 228014), &
                                              surface_parameter_route(4, 1, 0, 235), &
                                              surface_parameter_route(4, 2, 0, 198), &
                                              surface_parameter_route(10, 1, 0, 173), &
                                              surface_parameter_route(10, 2, 0, 174), &
                                              surface_parameter_route(10, 4, 0, 160), &
                                              surface_parameter_route(10, 5, 0, 172), &
                                              surface_parameter_route(10, 6, 0, 161), &
                                              surface_parameter_route(10, 7, 0, 162), &
                                              surface_parameter_route(10, 8, 0, 163), &
                                              surface_parameter_route(10, 9, 0, 234), &
                                              surface_parameter_route(10, 10, 0, 27), &
                                              surface_parameter_route(10, 11, 0, 129172), &
                                              surface_parameter_route(10, 12, 0, 28), &
                                              surface_parameter_route(10, 13, 0, 200199), &
                                              surface_parameter_route(10, 15, 0, 29), &
                                              surface_parameter_route(10, 16, 0, 30), &
                                              surface_parameter_route(10, 17, 0, 66), &
                                              surface_parameter_route(10, 18, 0, 67), &
                                              surface_parameter_route(10, 19, 0, 43), &
                                              surface_parameter_route(10, 20, 0, 26), &
                                              surface_parameter_route(10, 21, 0, 228007), &
                                              surface_parameter_route(10, 22, 0, 31), &
                                              surface_parameter_route(10, 23, 0, 34), &
                                              surface_parameter_route(10, 26, 0, 74), &
                                              surface_parameter_route(10, 27, 0, 15), &
                                              surface_parameter_route(10, 28, 0, 16), &
                                              surface_parameter_route(10, 29, 0, 17), &
                                              surface_parameter_route(10, 30, 0, 18), &
                                              surface_parameter_route(2, 1, 1, 228141), &
                                              surface_parameter_route(2, 2, 1, 32), &
                                              surface_parameter_route(2, 3, 1, 33), &
                                              surface_parameter_route(2, 4, 1, 238), &
                                              surface_parameter_route(2, 5, 1, 228038)]
  type(surface_parameter_route), parameter :: operational_routes(55) = [ &
                                              surface_parameter_route(1, 1, 1, 139), &
                                              surface_parameter_route(1, 1, 2, 170), &
                                              surface_parameter_route(1, 1, 3, 183), &
                                              surface_parameter_route(1, 1, 4, 236), &
                                              surface_parameter_route(1, 2, 1, 39), &
                                              surface_parameter_route(1, 2, 2, 40), &
                                              surface_parameter_route(1, 2, 3, 41), &
                                              surface_parameter_route(1, 2, 4, 42), &
                                              surface_parameter_route(1, 3, 1, 35), &
                                              surface_parameter_route(1, 3, 2, 36), &
                                              surface_parameter_route(1, 3, 3, 37), &
                                              surface_parameter_route(1, 3, 4, 38), &
                                              surface_parameter_route(3, 1, 0, 228008), &
                                              surface_parameter_route(3, 2, 0, 228009), &
                                              surface_parameter_route(3, 3, 0, 228010), &
                                              surface_parameter_route(3, 4, 0, 228011), &
                                              surface_parameter_route(3, 5, 0, 228012), &
                                              surface_parameter_route(3, 6, 0, 228013), &
                                              surface_parameter_route(3, 7, 0, 228014), &
                                              surface_parameter_route(4, 1, 0, 235), &
                                              surface_parameter_route(4, 2, 0, 198), &
                                              surface_parameter_route(10, 1, 0, 173), &
                                              surface_parameter_route(10, 2, 0, 174), &
                                              surface_parameter_route(10, 4, 0, 160), &
                                              surface_parameter_route(10, 5, 0, 172), &
                                              surface_parameter_route(10, 6, 0, 161), &
                                              surface_parameter_route(10, 7, 0, 162), &
                                              surface_parameter_route(10, 8, 0, 163), &
                                              surface_parameter_route(10, 9, 0, 234), &
                                              surface_parameter_route(10, 10, 0, 27), &
                                              surface_parameter_route(10, 11, 0, 129172), &
                                              surface_parameter_route(10, 12, 0, 28), &
                                              surface_parameter_route(10, 13, 0, 200199), &
                                              surface_parameter_route(10, 15, 0, 29), &
                                              surface_parameter_route(10, 16, 0, 30), &
                                              surface_parameter_route(10, 17, 0, 66), &
                                              surface_parameter_route(10, 18, 0, 67), &
                                              surface_parameter_route(10, 19, 0, 43), &
                                              surface_parameter_route(10, 20, 0, 26), &
                                              surface_parameter_route(10, 21, 0, 228007), &
                                              surface_parameter_route(10, 22, 0, 31), &
                                              surface_parameter_route(10, 23, 0, 34), &
                                              surface_parameter_route(10, 26, 0, 74), &
                                              surface_parameter_route(10, 31, 0, 210186), &
                                              surface_parameter_route(10, 32, 0, 210187), &
                                              surface_parameter_route(10, 33, 0, 210188), &
                                              surface_parameter_route(10, 34, 0, 210189), &
                                              surface_parameter_route(10, 35, 0, 210190), &
                                              surface_parameter_route(10, 36, 0, 210191), &
                                              surface_parameter_route(23, 1, 0, 148), &
                                              surface_parameter_route(2, 1, 1, 228141), &
                                              surface_parameter_route(2, 2, 1, 32), &
                                              surface_parameter_route(2, 3, 1, 33), &
                                              surface_parameter_route(2, 4, 1, 238), &
                                              surface_parameter_route(2, 5, 1, 228038)]
  type :: surface_startup_workspace
    type(surface_default_group_view) :: groups(33)
    type(surface_default_owner) :: owners(64)
    type(surface_default_assignment) :: assignments(4096)
    type(surface_default_plan_summary) :: summary
    type(surface_input_configuration) :: configuration
    type(surface_input_owners) :: input_views
    integer(int32) :: parameters(55) = 0
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Selected N16 input has2048points,P24,B86,L19. All outer records
 !! are caller-owned and fresh; only their actual canonical owners publish.
 !! The optional byte limit bounds private file-loading workspace.
 integer(int32) function initialize_owned_selected_surface_state(path,constants,physics,registry,trajectory,descriptions,fields,workspace_byte_limit)result(status)
    character(*), intent(in) :: path
    type(forecast_physical_constants), intent(in) :: constants
    type(tephy), intent(in) :: physics
    type(surface_field_registry), target, intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(surface_field_state), target, intent(inout) :: fields
    integer(int64), optional, intent(in) :: workspace_byte_limit
    type(surface_operational_controls) :: controls
    integer(int32) :: unused_reset
    integer(int64) :: byte_limit
    byte_limit = huge(byte_limit)
    if (present(workspace_byte_limit)) byte_limit = workspace_byte_limit
    unused_reset = 0
  status=initialize_owned_surface(path,constants,physics,controls,.false.,registry,trajectory,descriptions,fields,unused_reset,byte_limit)
  end function
  !> Whole N1280 input has6599680points,P17,B388217,L137. This retained
 !! complete-matrix route needs memory admission before execution. The
 !! separate current partitioned loader remains unchanged. RESET_WORD is
 !! NPTRSURF and changes only after all default assignments are admitted.
 integer(int32) function initialize_owned_operational_surface_state(path,constants,physics,controls,registry,trajectory,descriptions,fields,reset_word,workspace_byte_limit)result(status)
    character(*), intent(in) :: path
    type(forecast_physical_constants), intent(in) :: constants
    type(tephy), intent(in) :: physics
    type(surface_operational_controls), intent(in) :: controls
    type(surface_field_registry), target, intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(surface_field_state), target, intent(inout) :: fields
    integer(int32), intent(inout) :: reset_word
    integer(int64), optional, intent(in) :: workspace_byte_limit
    integer(int64) :: byte_limit
    byte_limit = huge(byte_limit)
    if (present(workspace_byte_limit)) byte_limit = workspace_byte_limit
  status=initialize_owned_surface(path,constants,physics,controls,.true.,registry,trajectory,descriptions,fields,reset_word,byte_limit)
  end function
 integer(int32) function initialize_owned_surface(path,constants,physics,controls,operational,registry,trajectory,descriptions,fields,reset_word,byte_limit)result(status)
    character(*), intent(in) :: path
    type(forecast_physical_constants), intent(in) :: constants
    type(tephy), intent(in) :: physics
    type(surface_operational_controls), intent(in) :: controls
    logical, intent(in) :: operational
    type(surface_field_registry), target, intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(surface_field_state), target, intent(inout) :: fields
    integer(int32), intent(inout) :: reset_word
    integer(int64), intent(in) :: byte_limit
    type(surface_startup_workspace), allocatable :: work
    type(surface_field_layout) :: layout
    type(ieee_status_type) :: incoming, observed
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno, observed_errno
    integer(int32) :: p, b, child, ignored, assignment_count
    integer(int64) :: points, expected_bytes
    integer :: allocation_status
    status = 2
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, c_null_char) /= 0 .or. byte_limit < 1) return
    if (constants%initialized /= 1) return
    if (.not. physics%leocwa .or. .not. physics%leocco) return
    if (trajectory%dynamic_count /= 0 .or. trajectory%constant_count /= 0 .or. any(trajectory%parameters /= 0)) return
    if (.not. empty_descriptions(descriptions) .or. .not. fresh_fields(fields)) return
    p = 24; b = 86; points = 2048; assignment_count = 306; expected_bytes = 7149696
    if (operational) then
      p = 17; b = 388217; points = 6599680; assignment_count = 423; expected_bytes = 29197024136_int64
    end if
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    if (operational) then
      child = construct_operational_surface_configuration(registry, trajectory, descriptions, physics, controls)
    else
      child = construct_selected_surface_configuration(registry, trajectory, descriptions, physics)
    end if
    if (child /= 0) then
      status = 101
      if (child == 2) then
        status = 2
        call ieee_set_status(incoming); error_number = saved_errno
        return
      end if
      goto900
    end if
    if (operational) then
      child = allocate_runtime_distributed_surface_field_owners(p, b, controls%levels, fields)
    else
      call layout_from_registry(registry, layout)
      child = allocate_surface_field_owners(p, b, layout, fields)
    end if
    if (child /= 0) then
      status = 201
      goto900
    end if
    allocate (work, stat=allocation_status)
    call ieee_set_status(incoming); error_number = saved_errno
    if (allocation_status /= 0) then
      status = 301
      goto900
    end if
    call bind_default_groups(registry, fields, p, b, work%groups)
    if (operational) then
      call collect_runtime_partitioned_surface_defaults(work%groups, p, b, work%owners, work%assignments, work%summary)
    else
      call collect_surface_default_metadata(work%groups, work%owners, work%assignments, work%summary)
    end if
    status = 401
    if (work%summary%status /= 0 .or. work%summary%owner_count /= 10) goto900
    if (work%summary%assignment_count /= assignment_count .or. work%summary%owner_bytes /= expected_bytes) goto900
    if (operational) then
 child = set_runtime_partitioned_initial_surface_defaults(work%owners(1:10), work%assignments(1:assignment_count), p, b, reset_word)
    else
      child = set_initial_surface_defaults(work%owners(1:10), work%assignments(1:assignment_count))
    end if
    if (child /= 0) goto900
    child = initialize_surface_input_configuration(constants, points, work%configuration)
    if (child /= 0) then
      status = 501
      goto900
    end if
    child = borrow_surface_input_owners(fields, work%input_views)
    if (child /= 0) then
      status = 601
      goto900
    end if
    if (operational) then
      child = collect_parameters(registry, operational_routes, work%parameters(1:55))
    else
      child = collect_parameters(registry, selected_routes, work%parameters(1:52))
    end if
    if (child /= 0) then
      status = 601
      goto900
    end if
    if (operational) then
      child = load_operational_initial_surface_state(path, work%configuration, work%input_views, work%parameters(1:55), byte_limit)
    else
      child = load_initial_surface_state(path, work%configuration, work%input_views, work%parameters(1:52), byte_limit)
    end if
    status = 0
    if (child /= 0) then
      status = 1000 + child
      goto900
    end if
    call ieee_get_status(observed); observed_errno = error_number
    deallocate (work)
    call ieee_set_status(observed); error_number = observed_errno
    return
900 continue
    call ieee_get_status(observed); observed_errno = error_number
    ignored = release_owned_surface_state(registry, fields)
    call clear_registry(registry)
    trajectory = surface_trajectory_metadata()
    call clear_surface_physics_descriptions(descriptions)
    if (allocated(work)) deallocate (work)
    call ieee_set_status(observed); error_number = observed_errno
  end function
  !> Release all34 numerical owners before their70 metadata owners.
  integer(int32) function release_owned_surface_state(registry, fields) result(status)
    type(surface_field_registry), intent(inout) :: registry
    type(surface_field_state), intent(inout) :: fields
    integer(int32) :: ignored
    ignored = release_surface_field_owners(fields)
    ignored = release_selected_surface_configuration(registry)
    status = 0
  end function
  integer(int32) function collect_parameters(registry, routes, parameters) result(status)
    type(surface_field_registry), intent(in) :: registry
    type(surface_parameter_route), intent(in) :: routes(:)
    integer(int32), intent(inout) :: parameters(:)
    integer :: j, g, f, k
    integer(int32) :: value, source_flag
    status = 2
    if (size(parameters) /= size(routes)) return
    do j = 1, size(routes)
      g = routes(j)%group; f = routes(j)%field; k = routes(j)%layer
      if (.not. allocated(registry%groups(g)%fields)) return
      if (f < 1 .or. f > size(registry%groups(g)%fields)) return
      if (registry%groups(g)%fields(f)%registration_index /= f) return
      if (k == 0) then
        value = registry%groups(g)%fields(f)%parameter
        source_flag = registry%groups(g)%fields(f)%source_flag
      else
        if (.not. allocated(registry%groups(g)%fields(f)%layer_parameters)) return
        if (.not. allocated(registry%groups(g)%fields(f)%layer_source_flags)) return
        if (k > size(registry%groups(g)%fields(f)%layer_parameters)) return
        if (k > size(registry%groups(g)%fields(f)%layer_source_flags)) return
        value = registry%groups(g)%fields(f)%layer_parameters(k)
        source_flag = registry%groups(g)%fields(f)%layer_source_flags(k)
      end if
      if (value /= routes(j)%parameter .or. source_flag /= 1) return
      parameters(j) = value
    end do
    status = 0
  end function
  subroutine clear_registry(registry)
    type(surface_field_registry), intent(inout) :: registry
    integer :: g
    do g = 1, 34
      registry%groups(g)%key = repeat(achar(0), 16)
      registry%groups(g)%metadata = surface_group_metadata()
      registry%groups(g)%metadata%name = repeat(achar(0), 16)
    end do
    do g = 1, 342
      registry%aliases(g) = surface_metadata_alias()
      registry%aliases(g)%name = repeat(achar(0), 32)
    end do
    registry%totals = surface_field_totals()
    registry%albedo_first = 0; registry%albedo_last = 0
    registry%dynamic_count = 0; registry%constant_count = 0; registry%ready = .false.
  end subroutine
  subroutine layout_from_registry(registry, layout)
    type(surface_field_registry), intent(in) :: registry
    type(surface_field_layout), intent(out) :: layout
    layout%sp_sb = [registry%groups(1)%metadata%stored_fields, registry%groups(1)%metadata%layers]
    layout%sp_sg = [registry%groups(2)%metadata%stored_fields, registry%groups(2)%metadata%layers]
    layout%sp_sl = [registry%groups(3)%metadata%stored_fields, registry%groups(3)%metadata%layers]
    layout%sp_rr = [registry%groups(4)%metadata%stored_fields, registry%groups(4)%metadata%layers]
    layout%sp_cl = [registry%groups(5)%metadata%stored_fields, registry%groups(5)%metadata%layers]
    layout%sp_om = [registry%groups(6)%metadata%stored_fields, registry%groups(6)%metadata%layers]
    layout%sp_ep = [registry%groups(7)%metadata%stored_fields, registry%groups(7)%metadata%layers]
    layout%sp_x2 = [registry%groups(8)%metadata%stored_fields, registry%groups(8)%metadata%layers]
    layout%sp_ci = [registry%groups(9)%metadata%stored_fields, registry%groups(9)%metadata%layers]
    layout%sd_vf = [registry%groups(10)%metadata%stored_fields, registry%groups(10)%metadata%layers]
    layout%sd_vp = [registry%groups(11)%metadata%stored_fields, registry%groups(11)%metadata%layers]
    layout%sd_vv = [registry%groups(12)%metadata%stored_fields, registry%groups(12)%metadata%layers]
    layout%sd_vn = [registry%groups(13)%metadata%stored_fields, registry%groups(13)%metadata%layers]
    layout%sd_vh = [registry%groups(14)%metadata%stored_fields, registry%groups(14)%metadata%layers]
    layout%sd_vk = [registry%groups(15)%metadata%stored_fields, registry%groups(15)%metadata%layers]
    layout%sd_va = [registry%groups(16)%metadata%stored_fields, registry%groups(16)%metadata%layers]
    layout%sd_vc = [registry%groups(17)%metadata%stored_fields, registry%groups(17)%metadata%layers]
    layout%sd_v2 = [registry%groups(18)%metadata%stored_fields, registry%groups(18)%metadata%layers]
    layout%sd_v3 = [registry%groups(19)%metadata%stored_fields, registry%groups(19)%metadata%layers]
    layout%sd_vd = [registry%groups(21)%metadata%stored_fields, registry%groups(21)%metadata%layers]
    layout%sd_sm = [registry%groups(22)%metadata%stored_fields, registry%groups(22)%metadata%layers]
    layout%sd_ws = [registry%groups(23)%metadata%stored_fields, registry%groups(23)%metadata%layers]
    layout%sd_ww = [registry%groups(24)%metadata%stored_fields, registry%groups(24)%metadata%layers]
    layout%sd_vx = [registry%groups(25)%metadata%stored_fields, registry%groups(25)%metadata%layers]
    layout%sd_xa = [registry%groups(29)%metadata%stored_fields, registry%groups(29)%metadata%layers]
    layout%sd_xr = [registry%groups(31)%metadata%stored_fields, registry%groups(31)%metadata%layers]
    layout%sd_x2 = [registry%groups(32)%metadata%stored_fields, registry%groups(32)%metadata%layers]
    layout%sd_sfl = [registry%groups(33)%metadata%stored_fields, registry%groups(33)%metadata%layers]
    layout%sd_sfo = [registry%groups(34)%metadata%stored_fields, registry%groups(34)%metadata%layers]
    layout%sd_pf = [registry%groups(30)%metadata%stored_fields, registry%groups(30)%metadata%layers]
    layout%sd_di = [registry%groups(26)%metadata%stored_fields, registry%groups(26)%metadata%layers]
    layout%sd_oc = [registry%groups(20)%metadata%stored_fields, registry%groups(20)%metadata%layers]
    layout%sd_xp = [registry%groups(27)%metadata%stored_fields, registry%groups(27)%metadata%layers]
    layout%sd_xp2 = [registry%groups(28)%metadata%stored_fields, registry%groups(28)%metadata%layers]
  end subroutine
  logical function empty_descriptions(input) result(empty)
    type(surface_physics_descriptions), intent(in) :: input
    integer(int32) :: dimensions(8)
    integer :: row, column
    empty = .false.
    dimensions=[input%jpvxp,input%jpvxp2,input%jpcxp,input%jpvextr,input%jpvextrdi,input%jpvxtr2,input%jpvprecip,input%jpvprecip2]
    if (.not. all(dimensions == 0) .and. .not. all(dimensions == [20, 50, 50, 99, 99, 99, 99, 99])) return
    if (any(input%nextrpgb /= 0)) return
    if (any(input%nxtrp2gb /= 0)) return
    if (any(input%nvextragb /= 0)) return
    if (any(input%nvexradgb /= 0)) return
    if (any(input%nvextr2gb /= 0)) return
    if (any(input%nvextrdigb /= 0)) return
    if (any(input%nvprecipgb /= 0)) return
    if (any(input%nvprecipgb2 /= 0)) return
    if (input%nsflux /= 0) return
    if (input%nsforc /= 0) return
    if (any(input%cextrp /= repeat(achar(0), 16))) return
    if (any(input%cxtrp2 /= repeat(achar(0), 16))) return
    if (any(input%cvextra /= repeat(achar(0), 16))) return
    if (any(input%cvexrad /= repeat(achar(0), 16))) return
    if (any(input%cvextrdi /= repeat(achar(0), 16))) return
    if (any(input%cvextr2 /= repeat(achar(0), 16))) return
    if (any(input%cvprecip /= repeat(achar(0), 16))) return
    if (any(input%cvprecip2 /= repeat(achar(0), 16))) return
    do column = lbound(input%extrpdf, 2), ubound(input%extrpdf, 2)
      do row = lbound(input%extrpdf, 1), ubound(input%extrpdf, 1)
        if (transfer(input%extrpdf(row, column), 0_int64) /= 0_int64) return
      end do
    end do
    do row = lbound(input%xtrp2df, 1), ubound(input%xtrp2df, 1)
      if (transfer(input%xtrp2df(row), 0_int64) /= 0_int64) return
    end do
    do row = lbound(input%vextradf, 1), ubound(input%vextradf, 1)
      if (transfer(input%vextradf(row), 0_int64) /= 0_int64) return
    end do
    do row = lbound(input%vexraddf, 1), ubound(input%vexraddf, 1)
      if (transfer(input%vexraddf(row), 0_int64) /= 0_int64) return
    end do
    do row = lbound(input%vextr2df, 1), ubound(input%vextr2df, 1)
      if (transfer(input%vextr2df(row), 0_int64) /= 0_int64) return
    end do
    do row = lbound(input%vextrdi, 1), ubound(input%vextrdi, 1)
      if (transfer(input%vextrdi(row), 0_int64) /= 0_int64) return
    end do
    do row = lbound(input%vprecip, 1), ubound(input%vprecip, 1)
      if (transfer(input%vprecip(row), 0_int64) /= 0_int64) return
    end do
    do row = lbound(input%vprecip2, 1), ubound(input%vprecip2, 1)
      if (transfer(input%vprecip2(row), 0_int64) /= 0_int64) return
    end do
    if (input%lreqin_vextrdi .or. input%lreqout_vextrdi) return
    empty = .true.
  end function
  logical function fresh_fields(fields) result(fresh)
    type(surface_field_state), intent(in) :: fields
    fresh = .false.
    if (allocated(fields%sp_sb)) return
    if (allocated(fields%sp_sg)) return
    if (allocated(fields%sp_sl)) return
    if (allocated(fields%sp_rr)) return
    if (allocated(fields%sp_cl)) return
    if (allocated(fields%sp_om)) return
    if (allocated(fields%sp_ep)) return
    if (allocated(fields%sp_x2)) return
    if (allocated(fields%sp_ci)) return
    if (allocated(fields%sd_vf)) return
    if (allocated(fields%sd_vp)) return
    if (allocated(fields%sd_vv)) return
    if (allocated(fields%sd_vn)) return
    if (allocated(fields%sd_vh)) return
    if (allocated(fields%sd_vk)) return
    if (allocated(fields%sd_va)) return
    if (allocated(fields%sd_vc)) return
    if (allocated(fields%sd_v2)) return
    if (allocated(fields%sd_v3)) return
    if (allocated(fields%sd_vd)) return
    if (allocated(fields%sd_sm)) return
    if (allocated(fields%sd_ws)) return
    if (allocated(fields%sd_ww)) return
    if (allocated(fields%sd_vx)) return
    if (allocated(fields%sd_xa)) return
    if (allocated(fields%sd_xr)) return
    if (allocated(fields%sd_x2)) return
    if (allocated(fields%sd_sfl)) return
    if (allocated(fields%sd_sfo)) return
    if (allocated(fields%sd_pf)) return
    if (allocated(fields%sd_di)) return
    if (allocated(fields%sd_oc)) return
    if (allocated(fields%sd_xp)) return
    if (allocated(fields%sd_xp2)) return
    fresh = .true.
  end function
  subroutine bind_default_groups(registry, fields, rows, blocks, views)
    type(surface_field_registry), target, intent(in) :: registry
    type(surface_field_state), target, intent(inout) :: fields
    integer(int32), intent(in) :: rows, blocks
    type(surface_default_group_view), intent(out) :: views(33)
    views(1)%metadata = registry%groups(1)%metadata
    views(1)%fields => registry%groups(1)%fields
    views(1)%layered = .true.
    views(1)%owner%values(1:rows, 1:size(fields%sp_sb, 2)*size(fields%sp_sb, 3), 1:blocks) => fields%sp_sb
    views(2)%metadata = registry%groups(2)%metadata
    views(2)%fields => registry%groups(2)%fields
    views(2)%layered = .true.
    views(2)%owner%values(1:rows, 1:size(fields%sp_sg, 2)*size(fields%sp_sg, 3), 1:blocks) => fields%sp_sg
    views(3)%metadata = registry%groups(3)%metadata
    views(3)%fields => registry%groups(3)%fields
    views(3)%layered = .false.
    views(3)%owner%values => fields%sp_sl
    views(4)%metadata = registry%groups(4)%metadata
    views(4)%fields => registry%groups(4)%fields
    views(4)%layered = .false.
    views(4)%owner%values => fields%sp_rr
    views(5)%metadata = registry%groups(5)%metadata
    views(5)%fields => registry%groups(5)%fields
    views(5)%layered = .false.
    views(5)%owner%values => fields%sp_cl
    views(6)%metadata = registry%groups(6)%metadata
    views(6)%fields => registry%groups(6)%fields
    views(6)%layered = .true.
    views(6)%owner%values(1:rows, 1:size(fields%sp_om, 2)*size(fields%sp_om, 3), 1:blocks) => fields%sp_om
    views(7)%metadata = registry%groups(7)%metadata
    views(7)%fields => registry%groups(7)%fields
    views(7)%layered = .true.
    views(7)%owner%values(1:rows, 1:size(fields%sp_ep, 2)*size(fields%sp_ep, 3), 1:blocks) => fields%sp_ep
    views(8)%metadata = registry%groups(8)%metadata
    views(8)%fields => registry%groups(8)%fields
    views(8)%layered = .false.
    views(8)%owner%values => fields%sp_x2
    views(9)%metadata = registry%groups(10)%metadata
    views(9)%fields => registry%groups(10)%fields
    views(9)%layered = .false.
    views(9)%owner%values => fields%sd_vf
    views(10)%metadata = registry%groups(11)%metadata
    views(10)%fields => registry%groups(11)%fields
    views(10)%layered = .false.
    views(10)%owner%values => fields%sd_vp
    views(11)%metadata = registry%groups(12)%metadata
    views(11)%fields => registry%groups(12)%fields
    views(11)%layered = .false.
    views(11)%owner%values => fields%sd_vv
    views(12)%metadata = registry%groups(13)%metadata
    views(12)%fields => registry%groups(13)%fields
    views(12)%layered = .false.
    views(12)%owner%values => fields%sd_vn
    views(13)%metadata = registry%groups(14)%metadata
    views(13)%fields => registry%groups(14)%fields
    views(13)%layered = .false.
    views(13)%owner%values => fields%sd_vh
    views(14)%metadata = registry%groups(15)%metadata
    views(14)%fields => registry%groups(15)%fields
    views(14)%layered = .false.
    views(14)%owner%values => fields%sd_vk
    views(15)%metadata = registry%groups(16)%metadata
    views(15)%fields => registry%groups(16)%fields
    views(15)%layered = .false.
    views(15)%owner%values => fields%sd_va
    views(16)%metadata = registry%groups(17)%metadata
    views(16)%fields => registry%groups(17)%fields
    views(16)%layered = .false.
    views(16)%owner%values => fields%sd_vc
    views(17)%metadata = registry%groups(18)%metadata
    views(17)%fields => registry%groups(18)%fields
    views(17)%layered = .false.
    views(17)%owner%values => fields%sd_v2
    views(18)%metadata = registry%groups(19)%metadata
    views(18)%fields => registry%groups(19)%fields
    views(18)%layered = .true.
    views(18)%owner%values(1:rows, 1:size(fields%sd_v3, 2)*size(fields%sd_v3, 3), 1:blocks) => fields%sd_v3
    views(19)%metadata = registry%groups(20)%metadata
    views(19)%fields => registry%groups(20)%fields
    views(19)%layered = .false.
    views(19)%owner%values => fields%sd_oc
    views(20)%metadata = registry%groups(21)%metadata
    views(20)%fields => registry%groups(21)%fields
    views(20)%layered = .false.
    views(20)%owner%values => fields%sd_vd
    views(21)%metadata = registry%groups(22)%metadata
    views(21)%fields => registry%groups(22)%fields
    views(21)%layered = .true.
    views(21)%owner%values(1:rows, 1:size(fields%sd_sm, 2)*size(fields%sd_sm, 3), 1:blocks) => fields%sd_sm
    views(22)%metadata = registry%groups(23)%metadata
    views(22)%fields => registry%groups(23)%fields
    views(22)%layered = .false.
    views(22)%owner%values => fields%sd_ws
    views(23)%metadata = registry%groups(24)%metadata
    views(23)%fields => registry%groups(24)%fields
    views(23)%layered = .false.
    views(23)%owner%values => fields%sd_ww
    views(24)%metadata = registry%groups(25)%metadata
    views(24)%fields => registry%groups(25)%fields
    views(24)%layered = .false.
    views(24)%owner%values => fields%sd_vx
    views(25)%metadata = registry%groups(29)%metadata
    views(25)%fields => registry%groups(29)%fields
    views(25)%layered = .true.
    views(25)%owner%values(1:rows, 1:size(fields%sd_xa, 2)*size(fields%sd_xa, 3), 1:blocks) => fields%sd_xa
    views(26)%metadata = registry%groups(31)%metadata
    views(26)%fields => registry%groups(31)%fields
    views(26)%layered = .true.
    views(26)%owner%values(1:rows, 1:size(fields%sd_xr, 2)*size(fields%sd_xr, 3), 1:blocks) => fields%sd_xr
    views(27)%metadata = registry%groups(26)%metadata
    views(27)%fields => registry%groups(26)%fields
    views(27)%layered = .true.
    views(27)%owner%values(1:rows, 1:size(fields%sd_di, 2)*size(fields%sd_di, 3), 1:blocks) => fields%sd_di
    views(28)%metadata = registry%groups(32)%metadata
    views(28)%fields => registry%groups(32)%fields
    views(28)%layered = .false.
    views(28)%owner%values => fields%sd_x2
    views(29)%metadata = registry%groups(33)%metadata
    views(29)%fields => registry%groups(33)%fields
    views(29)%layered = .false.
    views(29)%owner%values => fields%sd_sfl
    views(30)%metadata = registry%groups(34)%metadata
    views(30)%fields => registry%groups(34)%fields
    views(30)%layered = .false.
    views(30)%owner%values => fields%sd_sfo
    views(31)%metadata = registry%groups(30)%metadata
    views(31)%fields => registry%groups(30)%fields
    views(31)%layered = .true.
    views(31)%owner%values(1:rows, 1:size(fields%sd_pf, 2)*size(fields%sd_pf, 3), 1:blocks) => fields%sd_pf
    views(32)%metadata = registry%groups(27)%metadata
    views(32)%fields => registry%groups(27)%fields
    views(32)%layered = .true.
    views(32)%owner%values(1:rows, 1:size(fields%sd_xp, 2)*size(fields%sd_xp, 3), 1:blocks) => fields%sd_xp
    views(33)%metadata = registry%groups(28)%metadata
    views(33)%fields => registry%groups(28)%fields
    views(33)%layered = .true.
    views(33)%owner%values(1:rows, 1:size(fields%sd_xp2, 2)*size(fields%sd_xp2, 3), 1:blocks) => fields%sd_xp2
  end subroutine
  subroutine clear_surface_physics_descriptions(output)
    !! Write the source's zero semantic state using native named members.
    !! No descriptor bytes,pointers or compiler padding are touched.
    type(surface_physics_descriptions), intent(inout) :: output
    output%jpvxp = 0
    output%jpvxp2 = 0
    output%jpcxp = 0
    output%jpvextr = 0
    output%jpvextrdi = 0
    output%jpvxtr2 = 0
    output%jpvprecip = 0
    output%jpvprecip2 = 0
    output%nextrpgb = 0
    output%nxtrp2gb = 0
    output%nvextragb = 0
    output%nvexradgb = 0
    output%nvextr2gb = 0
    output%nvextrdigb = 0
    output%nvprecipgb = 0
    output%nvprecipgb2 = 0
    output%nsflux = 0
    output%nsforc = 0
    output%cextrp = repeat(achar(0), 16)
    output%cxtrp2 = repeat(achar(0), 16)
    output%cvextra = repeat(achar(0), 16)
    output%cvexrad = repeat(achar(0), 16)
    output%cvextrdi = repeat(achar(0), 16)
    output%cvextr2 = repeat(achar(0), 16)
    output%cvprecip = repeat(achar(0), 16)
    output%cvprecip2 = repeat(achar(0), 16)
    output%extrpdf = 0.0_real64
    output%xtrp2df = 0.0_real64
    output%vextradf = 0.0_real64
    output%vexraddf = 0.0_real64
    output%vextr2df = 0.0_real64
    output%vextrdi = 0.0_real64
    output%vprecip = 0.0_real64
    output%vprecip2 = 0.0_real64
    output%lreqin_vextrdi = .false.; output%lreqout_vextrdi = .false.
  end subroutine
end module
