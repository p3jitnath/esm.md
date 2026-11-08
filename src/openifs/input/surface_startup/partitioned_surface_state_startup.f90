module partitioned_surface_state_startup_port
  !! Own the surface-input call order with native metadata and numerical arrays.
  !! This parent reads the frozen81-record surface schema and publishes local
  !! fields only through the accepted conversion and placement children.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_int, c_ptr, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yoephy, only: tephy
  use physical_constant_setup_port, only: forecast_physical_constants
  use surface_field_configuration_port
  use surface_field_registration_port, only: surface_trajectory_metadata, surface_field_totals, surface_group_metadata
  use surface_field_storage_port
  use surface_default_assignment_port
  use surface_default_metadata_port
  use surface_input_configuration_port
  use partitioned_surface_field_placement_port, only: surface_input_owners
  use partitioned_surface_initial_loading_port
  implicit none
  private
  public :: initialize_runtime_partitioned_operational_surface_state
  public :: initialize_partitioned_operational_surface_state
  public :: release_partitioned_operational_surface_state
  public :: clear_surface_physics_descriptions
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
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function initialize_runtime_partitioned_operational_surface_state(path,constants,physics,controls,rows,blocks,global_index,reset_word,registry,trajectory,descriptions,fields) result(status)
    !! rowsP is1..1024, Q=size(global_index) is1..6599680, and blocksB is
    !! ceil(Q/P). global_index maps local active points to the unchanged
    !! global6599680-point file. controls selects the live137-level schema.
    !! All owners are disjoint and fresh. trajectory has all zero counts.
    !! descriptions is zero or has only the eight declared dimension counts;
    !! clear_surface_physics_descriptions supplies the native zero state.
    !! registry and fields own all published metadata and numerical arrays.
    !! They must outlive every borrowed view. No view escapes this entry.
    !! reset_word changes to zero only after all default assignments succeed.
    !! Status2 rejects entry;101 metadata allocation;201 field allocation;
    !!301 private-plan allocation;401 defaults;501 input configuration;
    !!601 input plan;1000+child input status. Success0 keeps the owned state.
    character(*), intent(in) :: path
    type(forecast_physical_constants), intent(in) :: constants
    type(tephy), intent(in) :: physics
    type(surface_operational_controls), intent(in) :: controls
    integer(int32), intent(in) :: rows, blocks
    integer(int32), contiguous, intent(in) :: global_index(:)
    integer(int32), intent(inout) :: reset_word
    type(surface_field_registry), target, intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(surface_field_state), target, intent(inout) :: fields
    type(surface_startup_workspace), allocatable :: work
    type(ieee_status_type) :: incoming, observed
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno, observed_errno
    integer(int32) :: child, ignored
    integer(int64) :: q
    integer :: allocation_status
    status = 2
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, c_null_char) /= 0) return
    if (rows < 1 .or. rows > 1024 .or. blocks < 1) return
    q = size(global_index, kind=int64)
    if (q < 1 .or. q > 6599680_int64) return
    if (int(blocks, int64) /= (q + rows - 1_int64)/rows) return
    if (controls%levels /= 137 .or. constants%initialized /= 1) return
    if (.not. physics%lesurf .or. .not. physics%levdif) return
    if (trajectory%dynamic_count /= 0 .or. trajectory%constant_count /= 0) return
    if (any(trajectory%parameters /= 0)) return
    if (.not. empty_descriptions(descriptions)) return
    if (.not. fresh_fields(fields)) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    child = construct_operational_surface_configuration(registry, trajectory, descriptions, physics, controls)
    if (child /= 0) then
      status = 101
      if (child == 2) status = 2
      call ieee_set_status(incoming); error_number = saved_errno
      return
    end if
    child = allocate_runtime_distributed_surface_field_owners(rows, blocks, controls%levels, fields)
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
    call bind_default_groups(registry, fields, rows, blocks, work%groups)
    call collect_runtime_partitioned_surface_defaults(work%groups, rows, blocks, work%owners, work%assignments, work%summary)
    status = 401
    if (work%summary%status /= 0) goto900
    if (work%summary%owner_count /= 10 .or. work%summary%assignment_count /= 423) goto900
    if (work%summary%rows /= rows .or. work%summary%blocks /= blocks) goto900
    if (work%summary%owner_bytes /= 4424_int64*rows*blocks) goto900
    child = set_runtime_partitioned_initial_surface_defaults(work%owners(1:10), work%assignments(1:423), rows, blocks, reset_word)
    if (child /= 0) goto900
    child = initialize_surface_input_configuration(constants, 6599680_int64, work%configuration)
    if (child /= 0) then
      status = 501
      goto900
    end if
    child = borrow_surface_input_owners(fields, work%input_views)
    if (child /= 0) then
      status = 601
      goto900
    end if
    child = collect_input_parameters(registry, work%parameters)
    if (child /= 0) then
      status = 601
      goto900
    end if
    child=load_runtime_partitioned_operational_surface_state(path,work%configuration,work%parameters,global_index,work%input_views)
    status = 0
    if (child /= 0) status = 1000 + child
    if (status /= 0) goto900
    call ieee_get_status(observed); observed_errno = error_number
    deallocate (work)
    call ieee_set_status(observed); error_number = observed_errno
    return
900 call ieee_get_status(observed); observed_errno = error_number
    ignored = release_partitioned_operational_surface_state(registry, fields)
    registry%totals = surface_field_totals()
    registry%aliases = surface_metadata_alias()
    registry%albedo_first = 0; registry%albedo_last = 0
    registry%dynamic_count = 0; registry%constant_count = 0
    call clear_registry_metadata(registry)
    trajectory = surface_trajectory_metadata()
    call clear_surface_physics_descriptions(descriptions)
    if (allocated(work)) deallocate (work)
    call ieee_set_status(observed); error_number = observed_errno
  end function
  integer(int32) function initialize_partitioned_operational_surface_state(path,constants,physics,controls,global_index,reset_word,registry,trajectory,descriptions,fields) result(status)
    !! Retain the earlier fixed local partition as an explicit specialization:
    !! P17,Q1649920,B97055. The numerical and ownership stages are identical.
    character(*), intent(in) :: path
    type(forecast_physical_constants), intent(in) :: constants
    type(tephy), intent(in) :: physics
    type(surface_operational_controls), intent(in) :: controls
    integer(int32), contiguous, intent(in) :: global_index(:)
    integer(int32), intent(inout) :: reset_word
    type(surface_field_registry), target, intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(surface_field_state), target, intent(inout) :: fields
    status = 2
    if (size(global_index, kind=int64) /= 1649920_int64) return
    status=initialize_runtime_partitioned_operational_surface_state(path,constants,physics,controls,17_int32,97055_int32,global_index,reset_word,registry,trajectory,descriptions,fields)
  end function
  integer(int32) function release_partitioned_operational_surface_state(registry, fields) result(status)
    !! Release numerical owners first and metadata owners second. Scalar
    !! metadata remains for inspection. All old borrowed views then expire.
    type(surface_field_registry), intent(inout) :: registry
    type(surface_field_state), intent(inout) :: fields
    integer(int32) :: ignored
    ignored = release_surface_field_owners(fields)
    ignored = release_selected_surface_configuration(registry)
    status = 0
  end function
  subroutine clear_registry_metadata(registry)
    type(surface_field_registry), intent(inout) :: registry
    integer :: g
    do g = 1, 34
      registry%groups(g)%key = ' '
      registry%groups(g)%metadata = surface_group_metadata()
    end do
    registry%ready = .false.
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
  integer(int32) function collect_input_parameters(registry, parameters) result(status)
    type(surface_field_registry), intent(in) :: registry
    integer(int32), intent(inout) :: parameters(55)
    integer(int32) :: value, source_flag
    status = 2
    if (registry%groups(1)%fields(1)%registration_index /= 1) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(1)%layer_parameters) < 1 .or. size(registry%groups(1)%fields(1)%layer_source_flags) < 1) return
    value = registry%groups(1)%fields(1)%layer_parameters(1); source_flag = registry%groups(1)%fields(1)%layer_source_flags(1)
    if (value /= 139 .or. source_flag /= 1) return
    parameters(1) = value
    if (registry%groups(1)%fields(1)%registration_index /= 1) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(1)%layer_parameters) < 2 .or. size(registry%groups(1)%fields(1)%layer_source_flags) < 2) return
    value = registry%groups(1)%fields(1)%layer_parameters(2); source_flag = registry%groups(1)%fields(1)%layer_source_flags(2)
    if (value /= 170 .or. source_flag /= 1) return
    parameters(2) = value
    if (registry%groups(1)%fields(1)%registration_index /= 1) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(1)%layer_parameters) < 3 .or. size(registry%groups(1)%fields(1)%layer_source_flags) < 3) return
    value = registry%groups(1)%fields(1)%layer_parameters(3); source_flag = registry%groups(1)%fields(1)%layer_source_flags(3)
    if (value /= 183 .or. source_flag /= 1) return
    parameters(3) = value
    if (registry%groups(1)%fields(1)%registration_index /= 1) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(1)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(1)%layer_parameters) < 4 .or. size(registry%groups(1)%fields(1)%layer_source_flags) < 4) return
    value = registry%groups(1)%fields(1)%layer_parameters(4); source_flag = registry%groups(1)%fields(1)%layer_source_flags(4)
    if (value /= 236 .or. source_flag /= 1) return
    parameters(4) = value
    if (registry%groups(1)%fields(2)%registration_index /= 2) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(2)%layer_parameters) < 1 .or. size(registry%groups(1)%fields(2)%layer_source_flags) < 1) return
    value = registry%groups(1)%fields(2)%layer_parameters(1); source_flag = registry%groups(1)%fields(2)%layer_source_flags(1)
    if (value /= 39 .or. source_flag /= 1) return
    parameters(5) = value
    if (registry%groups(1)%fields(2)%registration_index /= 2) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(2)%layer_parameters) < 2 .or. size(registry%groups(1)%fields(2)%layer_source_flags) < 2) return
    value = registry%groups(1)%fields(2)%layer_parameters(2); source_flag = registry%groups(1)%fields(2)%layer_source_flags(2)
    if (value /= 40 .or. source_flag /= 1) return
    parameters(6) = value
    if (registry%groups(1)%fields(2)%registration_index /= 2) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(2)%layer_parameters) < 3 .or. size(registry%groups(1)%fields(2)%layer_source_flags) < 3) return
    value = registry%groups(1)%fields(2)%layer_parameters(3); source_flag = registry%groups(1)%fields(2)%layer_source_flags(3)
    if (value /= 41 .or. source_flag /= 1) return
    parameters(7) = value
    if (registry%groups(1)%fields(2)%registration_index /= 2) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(2)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(2)%layer_parameters) < 4 .or. size(registry%groups(1)%fields(2)%layer_source_flags) < 4) return
    value = registry%groups(1)%fields(2)%layer_parameters(4); source_flag = registry%groups(1)%fields(2)%layer_source_flags(4)
    if (value /= 42 .or. source_flag /= 1) return
    parameters(8) = value
    if (registry%groups(1)%fields(3)%registration_index /= 3) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(3)%layer_parameters) < 1 .or. size(registry%groups(1)%fields(3)%layer_source_flags) < 1) return
    value = registry%groups(1)%fields(3)%layer_parameters(1); source_flag = registry%groups(1)%fields(3)%layer_source_flags(1)
    if (value /= 35 .or. source_flag /= 1) return
    parameters(9) = value
    if (registry%groups(1)%fields(3)%registration_index /= 3) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(3)%layer_parameters) < 2 .or. size(registry%groups(1)%fields(3)%layer_source_flags) < 2) return
    value = registry%groups(1)%fields(3)%layer_parameters(2); source_flag = registry%groups(1)%fields(3)%layer_source_flags(2)
    if (value /= 36 .or. source_flag /= 1) return
    parameters(10) = value
    if (registry%groups(1)%fields(3)%registration_index /= 3) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(3)%layer_parameters) < 3 .or. size(registry%groups(1)%fields(3)%layer_source_flags) < 3) return
    value = registry%groups(1)%fields(3)%layer_parameters(3); source_flag = registry%groups(1)%fields(3)%layer_source_flags(3)
    if (value /= 37 .or. source_flag /= 1) return
    parameters(11) = value
    if (registry%groups(1)%fields(3)%registration_index /= 3) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_parameters)) return
    if (.not. allocated(registry%groups(1)%fields(3)%layer_source_flags)) return
  if (size(registry%groups(1)%fields(3)%layer_parameters) < 4 .or. size(registry%groups(1)%fields(3)%layer_source_flags) < 4) return
    value = registry%groups(1)%fields(3)%layer_parameters(4); source_flag = registry%groups(1)%fields(3)%layer_source_flags(4)
    if (value /= 38 .or. source_flag /= 1) return
    parameters(12) = value
    if (registry%groups(3)%fields(1)%registration_index /= 1) return
    value = registry%groups(3)%fields(1)%parameter; source_flag = registry%groups(3)%fields(1)%source_flag
    if (value /= 228008 .or. source_flag /= 1) return
    parameters(13) = value
    if (registry%groups(3)%fields(2)%registration_index /= 2) return
    value = registry%groups(3)%fields(2)%parameter; source_flag = registry%groups(3)%fields(2)%source_flag
    if (value /= 228009 .or. source_flag /= 1) return
    parameters(14) = value
    if (registry%groups(3)%fields(3)%registration_index /= 3) return
    value = registry%groups(3)%fields(3)%parameter; source_flag = registry%groups(3)%fields(3)%source_flag
    if (value /= 228010 .or. source_flag /= 1) return
    parameters(15) = value
    if (registry%groups(3)%fields(4)%registration_index /= 4) return
    value = registry%groups(3)%fields(4)%parameter; source_flag = registry%groups(3)%fields(4)%source_flag
    if (value /= 228011 .or. source_flag /= 1) return
    parameters(16) = value
    if (registry%groups(3)%fields(5)%registration_index /= 5) return
    value = registry%groups(3)%fields(5)%parameter; source_flag = registry%groups(3)%fields(5)%source_flag
    if (value /= 228012 .or. source_flag /= 1) return
    parameters(17) = value
    if (registry%groups(3)%fields(6)%registration_index /= 6) return
    value = registry%groups(3)%fields(6)%parameter; source_flag = registry%groups(3)%fields(6)%source_flag
    if (value /= 228013 .or. source_flag /= 1) return
    parameters(18) = value
    if (registry%groups(3)%fields(7)%registration_index /= 7) return
    value = registry%groups(3)%fields(7)%parameter; source_flag = registry%groups(3)%fields(7)%source_flag
    if (value /= 228014 .or. source_flag /= 1) return
    parameters(19) = value
    if (registry%groups(4)%fields(1)%registration_index /= 1) return
    value = registry%groups(4)%fields(1)%parameter; source_flag = registry%groups(4)%fields(1)%source_flag
    if (value /= 235 .or. source_flag /= 1) return
    parameters(20) = value
    if (registry%groups(4)%fields(2)%registration_index /= 2) return
    value = registry%groups(4)%fields(2)%parameter; source_flag = registry%groups(4)%fields(2)%source_flag
    if (value /= 198 .or. source_flag /= 1) return
    parameters(21) = value
    if (registry%groups(10)%fields(1)%registration_index /= 1) return
    value = registry%groups(10)%fields(1)%parameter; source_flag = registry%groups(10)%fields(1)%source_flag
    if (value /= 173 .or. source_flag /= 1) return
    parameters(22) = value
    if (registry%groups(10)%fields(2)%registration_index /= 2) return
    value = registry%groups(10)%fields(2)%parameter; source_flag = registry%groups(10)%fields(2)%source_flag
    if (value /= 174 .or. source_flag /= 1) return
    parameters(23) = value
    if (registry%groups(10)%fields(4)%registration_index /= 4) return
    value = registry%groups(10)%fields(4)%parameter; source_flag = registry%groups(10)%fields(4)%source_flag
    if (value /= 160 .or. source_flag /= 1) return
    parameters(24) = value
    if (registry%groups(10)%fields(5)%registration_index /= 5) return
    value = registry%groups(10)%fields(5)%parameter; source_flag = registry%groups(10)%fields(5)%source_flag
    if (value /= 172 .or. source_flag /= 1) return
    parameters(25) = value
    if (registry%groups(10)%fields(6)%registration_index /= 6) return
    value = registry%groups(10)%fields(6)%parameter; source_flag = registry%groups(10)%fields(6)%source_flag
    if (value /= 161 .or. source_flag /= 1) return
    parameters(26) = value
    if (registry%groups(10)%fields(7)%registration_index /= 7) return
    value = registry%groups(10)%fields(7)%parameter; source_flag = registry%groups(10)%fields(7)%source_flag
    if (value /= 162 .or. source_flag /= 1) return
    parameters(27) = value
    if (registry%groups(10)%fields(8)%registration_index /= 8) return
    value = registry%groups(10)%fields(8)%parameter; source_flag = registry%groups(10)%fields(8)%source_flag
    if (value /= 163 .or. source_flag /= 1) return
    parameters(28) = value
    if (registry%groups(10)%fields(9)%registration_index /= 9) return
    value = registry%groups(10)%fields(9)%parameter; source_flag = registry%groups(10)%fields(9)%source_flag
    if (value /= 234 .or. source_flag /= 1) return
    parameters(29) = value
    if (registry%groups(10)%fields(10)%registration_index /= 10) return
    value = registry%groups(10)%fields(10)%parameter; source_flag = registry%groups(10)%fields(10)%source_flag
    if (value /= 27 .or. source_flag /= 1) return
    parameters(30) = value
    if (registry%groups(10)%fields(11)%registration_index /= 11) return
    value = registry%groups(10)%fields(11)%parameter; source_flag = registry%groups(10)%fields(11)%source_flag
    if (value /= 129172 .or. source_flag /= 1) return
    parameters(31) = value
    if (registry%groups(10)%fields(12)%registration_index /= 12) return
    value = registry%groups(10)%fields(12)%parameter; source_flag = registry%groups(10)%fields(12)%source_flag
    if (value /= 28 .or. source_flag /= 1) return
    parameters(32) = value
    if (registry%groups(10)%fields(13)%registration_index /= 13) return
    value = registry%groups(10)%fields(13)%parameter; source_flag = registry%groups(10)%fields(13)%source_flag
    if (value /= 200199 .or. source_flag /= 1) return
    parameters(33) = value
    if (registry%groups(10)%fields(15)%registration_index /= 15) return
    value = registry%groups(10)%fields(15)%parameter; source_flag = registry%groups(10)%fields(15)%source_flag
    if (value /= 29 .or. source_flag /= 1) return
    parameters(34) = value
    if (registry%groups(10)%fields(16)%registration_index /= 16) return
    value = registry%groups(10)%fields(16)%parameter; source_flag = registry%groups(10)%fields(16)%source_flag
    if (value /= 30 .or. source_flag /= 1) return
    parameters(35) = value
    if (registry%groups(10)%fields(17)%registration_index /= 17) return
    value = registry%groups(10)%fields(17)%parameter; source_flag = registry%groups(10)%fields(17)%source_flag
    if (value /= 66 .or. source_flag /= 1) return
    parameters(36) = value
    if (registry%groups(10)%fields(18)%registration_index /= 18) return
    value = registry%groups(10)%fields(18)%parameter; source_flag = registry%groups(10)%fields(18)%source_flag
    if (value /= 67 .or. source_flag /= 1) return
    parameters(37) = value
    if (registry%groups(10)%fields(19)%registration_index /= 19) return
    value = registry%groups(10)%fields(19)%parameter; source_flag = registry%groups(10)%fields(19)%source_flag
    if (value /= 43 .or. source_flag /= 1) return
    parameters(38) = value
    if (registry%groups(10)%fields(20)%registration_index /= 20) return
    value = registry%groups(10)%fields(20)%parameter; source_flag = registry%groups(10)%fields(20)%source_flag
    if (value /= 26 .or. source_flag /= 1) return
    parameters(39) = value
    if (registry%groups(10)%fields(21)%registration_index /= 21) return
    value = registry%groups(10)%fields(21)%parameter; source_flag = registry%groups(10)%fields(21)%source_flag
    if (value /= 228007 .or. source_flag /= 1) return
    parameters(40) = value
    if (registry%groups(10)%fields(22)%registration_index /= 22) return
    value = registry%groups(10)%fields(22)%parameter; source_flag = registry%groups(10)%fields(22)%source_flag
    if (value /= 31 .or. source_flag /= 1) return
    parameters(41) = value
    if (registry%groups(10)%fields(23)%registration_index /= 23) return
    value = registry%groups(10)%fields(23)%parameter; source_flag = registry%groups(10)%fields(23)%source_flag
    if (value /= 34 .or. source_flag /= 1) return
    parameters(42) = value
    if (registry%groups(10)%fields(26)%registration_index /= 26) return
    value = registry%groups(10)%fields(26)%parameter; source_flag = registry%groups(10)%fields(26)%source_flag
    if (value /= 74 .or. source_flag /= 1) return
    parameters(43) = value
    if (registry%groups(10)%fields(31)%registration_index /= 31) return
    value = registry%groups(10)%fields(31)%parameter; source_flag = registry%groups(10)%fields(31)%source_flag
    if (value /= 210186 .or. source_flag /= 1) return
    parameters(44) = value
    if (registry%groups(10)%fields(32)%registration_index /= 32) return
    value = registry%groups(10)%fields(32)%parameter; source_flag = registry%groups(10)%fields(32)%source_flag
    if (value /= 210187 .or. source_flag /= 1) return
    parameters(45) = value
    if (registry%groups(10)%fields(33)%registration_index /= 33) return
    value = registry%groups(10)%fields(33)%parameter; source_flag = registry%groups(10)%fields(33)%source_flag
    if (value /= 210188 .or. source_flag /= 1) return
    parameters(46) = value
    if (registry%groups(10)%fields(34)%registration_index /= 34) return
    value = registry%groups(10)%fields(34)%parameter; source_flag = registry%groups(10)%fields(34)%source_flag
    if (value /= 210189 .or. source_flag /= 1) return
    parameters(47) = value
    if (registry%groups(10)%fields(35)%registration_index /= 35) return
    value = registry%groups(10)%fields(35)%parameter; source_flag = registry%groups(10)%fields(35)%source_flag
    if (value /= 210190 .or. source_flag /= 1) return
    parameters(48) = value
    if (registry%groups(10)%fields(36)%registration_index /= 36) return
    value = registry%groups(10)%fields(36)%parameter; source_flag = registry%groups(10)%fields(36)%source_flag
    if (value /= 210191 .or. source_flag /= 1) return
    parameters(49) = value
    if (registry%groups(23)%fields(1)%registration_index /= 1) return
    value = registry%groups(23)%fields(1)%parameter; source_flag = registry%groups(23)%fields(1)%source_flag
    if (value /= 148 .or. source_flag /= 1) return
    parameters(50) = value
    if (registry%groups(2)%fields(1)%registration_index /= 1) return
    if (.not. allocated(registry%groups(2)%fields(1)%layer_parameters)) return
    if (.not. allocated(registry%groups(2)%fields(1)%layer_source_flags)) return
  if (size(registry%groups(2)%fields(1)%layer_parameters) < 1 .or. size(registry%groups(2)%fields(1)%layer_source_flags) < 1) return
    value = registry%groups(2)%fields(1)%layer_parameters(1); source_flag = registry%groups(2)%fields(1)%layer_source_flags(1)
    if (value /= 228141 .or. source_flag /= 1) return
    parameters(51) = value
    if (registry%groups(2)%fields(2)%registration_index /= 2) return
    if (.not. allocated(registry%groups(2)%fields(2)%layer_parameters)) return
    if (.not. allocated(registry%groups(2)%fields(2)%layer_source_flags)) return
  if (size(registry%groups(2)%fields(2)%layer_parameters) < 1 .or. size(registry%groups(2)%fields(2)%layer_source_flags) < 1) return
    value = registry%groups(2)%fields(2)%layer_parameters(1); source_flag = registry%groups(2)%fields(2)%layer_source_flags(1)
    if (value /= 32 .or. source_flag /= 1) return
    parameters(52) = value
    if (registry%groups(2)%fields(3)%registration_index /= 3) return
    if (.not. allocated(registry%groups(2)%fields(3)%layer_parameters)) return
    if (.not. allocated(registry%groups(2)%fields(3)%layer_source_flags)) return
  if (size(registry%groups(2)%fields(3)%layer_parameters) < 1 .or. size(registry%groups(2)%fields(3)%layer_source_flags) < 1) return
    value = registry%groups(2)%fields(3)%layer_parameters(1); source_flag = registry%groups(2)%fields(3)%layer_source_flags(1)
    if (value /= 33 .or. source_flag /= 1) return
    parameters(53) = value
    if (registry%groups(2)%fields(4)%registration_index /= 4) return
    if (.not. allocated(registry%groups(2)%fields(4)%layer_parameters)) return
    if (.not. allocated(registry%groups(2)%fields(4)%layer_source_flags)) return
  if (size(registry%groups(2)%fields(4)%layer_parameters) < 1 .or. size(registry%groups(2)%fields(4)%layer_source_flags) < 1) return
    value = registry%groups(2)%fields(4)%layer_parameters(1); source_flag = registry%groups(2)%fields(4)%layer_source_flags(1)
    if (value /= 238 .or. source_flag /= 1) return
    parameters(54) = value
    if (registry%groups(2)%fields(5)%registration_index /= 5) return
    if (.not. allocated(registry%groups(2)%fields(5)%layer_parameters)) return
    if (.not. allocated(registry%groups(2)%fields(5)%layer_source_flags)) return
  if (size(registry%groups(2)%fields(5)%layer_parameters) < 1 .or. size(registry%groups(2)%fields(5)%layer_source_flags) < 1) return
    value = registry%groups(2)%fields(5)%layer_parameters(1); source_flag = registry%groups(2)%fields(5)%layer_source_flags(1)
    if (value /= 228038 .or. source_flag /= 1) return
    parameters(55) = value
    status = 0
  end function
end module
