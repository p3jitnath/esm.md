module surface_field_configuration_port
  !! Own the selected or operational surface metadata and its named aliases.
  !! Registration counts are dimensionless. Default values keep the units of
  !! their named physical field. Native indices replace old byte addresses.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_arithmetic
  use, intrinsic :: ieee_exceptions
  use yoephy, only: tephy
  use surface_field_registration_port
  implicit none
  private
  public :: surface_metadata_group, surface_metadata_alias, surface_field_registry
  public :: surface_operational_controls, surface_physics_descriptions
  public :: construct_selected_surface_configuration, construct_operational_surface_configuration
  public :: release_selected_surface_configuration
  type :: surface_metadata_group
    character(16) :: key = ' '
    type(surface_group_metadata) :: metadata
    type(surface_field_metadata), allocatable :: fields(:)
  end type
  type :: surface_metadata_alias
    character(32) :: name = ' '
    integer(int32) :: group = 0, first_field = 0, rank = 0, extent1 = 0, extent2 = 0
  end type
  type :: surface_field_registry
    type(surface_metadata_group) :: groups(34)
    type(surface_metadata_alias) :: aliases(342)
    type(surface_field_totals) :: totals
    integer(int32) :: albedo_first = 0, albedo_last = 0, dynamic_count = 0, constant_count = 0
    logical :: ready = .false.
  end type
  type :: surface_operational_controls
    integer(int32) :: levels = 0, undefined_index = 0, stop_step = 0
    logical :: wave_coupling = .false., two_way_wave = .false., wave_heat_flux = .false.
    logical :: currents = .false., stokes_drift = .false., wave_flux = .false.
    logical :: aqua = .false., trajectory = .false., ecmwf = .false.
  end type
  type :: surface_physics_descriptions
    integer(int32) :: jpvxp = 20, jpvxp2 = 50, jpcxp = 50, jpvextr = 99, jpvextrdi = 99
    integer(int32) :: jpvxtr2 = 99, jpvprecip = 99, jpvprecip2 = 99
    character(16) :: cextrp(50, 20) = ' ', cxtrp2(50) = ' '
    character(16) :: cvextra(99) = ' ', cvexrad(99) = ' ', cvextrdi(99) = ' '
    character(16) :: cvextr2(99) = ' ', cvprecip(99) = ' ', cvprecip2(99) = ' '
    integer(int32) :: nextrpgb(50, 20) = -999, nxtrp2gb(50) = -999
    integer(int32) :: nvextragb(99) = -999, nvexradgb(99) = -999, nvextr2gb(99) = -999
    integer(int32) :: nvextrdigb(99) = -999, nvprecipgb(99) = -999, nvprecipgb2(99) = -999
    integer(int32) :: nsflux = 0, nsforc = 0
    real(real64) :: extrpdf(50, 20) = 0.0_real64, xtrp2df(50) = 0.0_real64
    real(real64) :: vextradf(99) = 0.0_real64, vexraddf(99) = 0.0_real64
    real(real64) :: vextr2df(99) = 0.0_real64, vextrdi(99) = 0.0_real64
    real(real64) :: vprecip(99) = 0.0_real64, vprecip2(99) = 0.0_real64
    logical :: lreqin_vextrdi = .false., lreqout_vextrdi = .true.
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
  integer(int32), save, target, protected :: literal_1(4) = [139_int32, 170_int32, 183_int32, 236_int32]
  character(16), save, target, protected :: literal_2(4) = [character(16) :: 'LEV1TEMPERATURE ','LEV2TEMPERATURE ','LEV3TEMPERATURE ','LEV4TEMPERATURE ']
  real(real64), save, target, protected :: literal_3(4) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],4)
  integer(int32), save, target, protected :: literal_4(4) = [1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_5(4) = [39_int32, 40_int32, 41_int32, 42_int32]
  character(16), save, target, protected :: literal_6(4) = [character(16) :: 'LEV1RESERV.EAU  ','LEV2RESERV.EAU  ','LEV3RESERV.EAU  ','LEV4RESERV.EAU  ']
  real(real64), save, target, protected :: literal_7(4) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],4)
  integer(int32), save, target, protected :: literal_8(4) = [1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_9(4) = [35_int32, 36_int32, 37_int32, 38_int32]
  character(16), save, target, protected :: literal_10(4) = [character(16) :: 'LEV1ICETEMP     ','LEV2ICETEMP     ','LEV3ICETEMP     ','LEV4ICETEMP     ']
  real(real64), save, target, protected :: literal_11(4) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],4)
  integer(int32), save, target, protected :: literal_12(4) = [1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_13(5) = [228141_int32, 228141_int32, 228141_int32, 228141_int32, 228141_int32]
  character(16), save, target, protected :: literal_14(5) = [character(16) :: 'LEV01SnowMass   ','LEV02SnowMass   ','LEV03SnowMass   ','LEV04SnowMass   ','LEV05SnowMass   ']
  real(real64), save, target, protected :: literal_15(5) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],5)
  integer(int32), save, target, protected :: literal_16(5) = [1_int32, 1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_17(5) = [32_int32, 32_int32, 32_int32, 32_int32, 32_int32]
  character(16), save, target, protected :: literal_18(5) = [character(16) :: 'LEV01SnowAlb    ','LEV02SnowAlb    ','LEV03SnowAlb    ','LEV04SnowAlb    ','LEV05SnowAlb    ']
  real(real64), save, target, protected :: literal_19(5) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],5)
  integer(int32), save, target, protected :: literal_20(5) = [1_int32, 1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_21(5) = [33_int32, 33_int32, 33_int32, 33_int32, 33_int32]
  character(16), save, target, protected :: literal_22(5) = [character(16) :: 'LEV01SnowDens   ','LEV02SnowDens   ','LEV03SnowDens   ','LEV04SnowDens   ','LEV05SnowDens   ']
  real(real64), save, target, protected :: literal_23(5) = transfer([int(z'0000000000000000',int64),int(z'4059000000000000',int64),int(z'4059000000000000',int64),int(z'4059000000000000',int64),int(z'4059000000000000',int64)],[0.0_real64],5)
  integer(int32), save, target, protected :: literal_24(5) = [1_int32, 1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_25(5) = [238_int32, 238_int32, 238_int32, 238_int32, 238_int32]
  character(16), save, target, protected :: literal_26(5) = [character(16) :: 'LEV01SnowTemp   ','LEV02SnowTemp   ','LEV03SnowTemp   ','LEV04SnowTemp   ','LEV05SnowTemp   ']
  real(real64), save, target, protected :: literal_27(5) = transfer([int(z'0000000000000000',int64),int(z'4071128F5C28F5C3',int64),int(z'4071128F5C28F5C3',int64),int(z'4071128F5C28F5C3',int64),int(z'4071128F5C28F5C3',int64)],[0.0_real64],5)
  integer(int32), save, target, protected :: literal_28(5) = [1_int32, 1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_29(5) = [228038_int32, 228038_int32, 228038_int32, 228038_int32, 228038_int32]
  character(16), save, target, protected :: literal_30(5) = [character(16) :: 'LEV01SnowLiqC   ','LEV02SnowLiqC   ','LEV03SnowLiqC   ','LEV04SnowLiqC   ','LEV05SnowLiqC   ']
  real(real64), save, target, protected :: literal_31(5) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],5)
  integer(int32), save, target, protected :: literal_32(5) = [1_int32, 1_int32, 1_int32, 1_int32, 1_int32]
  integer(int32), save, target, protected :: literal_33(19) = [-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32]
  character(16), save, target, protected :: literal_34(19) = [character(16) :: '                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ']
  real(real64), save, target, protected :: literal_35(19) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],19)
  integer(int32), save, target, protected :: literal_36(137) = [-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32,-999_int32]
  character(16), save, target, protected :: literal_37(137) = [character(16) :: '                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ','                ']
  real(real64), save, target, protected :: literal_38(137) = transfer([int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64),int(z'0000000000000000',int64)],[0.0_real64],137)
contains
  integer(int32) function construct_selected_surface_configuration(registry, trajectory, descriptions, physics) result(status)
    !! registry is a fresh native owner. trajectory and descriptions are
    !! caller-owned outputs, published only after all34 groups succeed.
    !! physics is a readonly canonical data-only TEPHY record. Selected
    !! admission requires albedo scheme1 and the frozen nine physical flags.
    type(surface_field_registry), intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(tephy), intent(in) :: physics
    status = construct_configuration(registry, trajectory, descriptions, physics, .false.)
  end function
  integer(int32) function construct_operational_surface_configuration(registry,trajectory,descriptions,physics,controls) result(status)
    !! Operational metadata uses137 levels, albedo scheme2 and explicit
    !! source controls. stop_step must be positive. No numerical field owner
    !! is allocated here. Return0 on success,1 on allocation failure,2 on
    !! admission refusal. Failure releases all temporary metadata owners.
    type(surface_field_registry), intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(tephy), intent(in) :: physics
    type(surface_operational_controls), intent(in) :: controls
    status = 2
    if (controls%levels /= 137 .or. controls%undefined_index /= -999999 .or. controls%stop_step <= 0) return
    if (.not. controls%wave_coupling .or. .not. controls%two_way_wave .or. .not. controls%stokes_drift) return
    if (controls%wave_heat_flux .or. controls%currents .or. controls%wave_flux) return
    if (controls%aqua .or. controls%trajectory .or. .not. controls%ecmwf) return
    status = construct_configuration(registry, trajectory, descriptions, physics, .true.)
  end function
  integer(int32) function construct_configuration(registry, trajectory, descriptions, physics, operational) result(status)
    type(surface_field_registry), intent(inout) :: registry
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_physics_descriptions), intent(inout) :: descriptions
    type(tephy), intent(in) :: physics
    logical, intent(in) :: operational
    type(surface_trajectory_metadata) :: local_trajectory
    type(surface_group_controls) :: controls
    type(surface_registration_plan) :: plan
    type(surface_field_metadata) :: dummy(1)
    type(ieee_status_type) :: incoming
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    integer :: g, j, n, error
    integer(int32) :: capacity, rank, registered, undefined_index, child
    status = 2
    if (.not. physics%lephys .or. .not. physics%leflake .or. .not. physics%lec4map) return
    if (physics%lecurr .or. physics%lesurftraj .or. physics%leocml .or. physics%locmltke) return
    if (physics%lwetonline .or. physics%lbfasco2) return
    if (physics%nalbedoscheme /= merge(2, 1, operational)) return
    if (.not. fresh_registry(registry)) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    if (.not. floating_environment_ready()) then
      call ieee_set_status(incoming); error_number = saved_errno
      return
    end if
    local_trajectory = surface_trajectory_metadata()
    undefined_index = merge(-999999, -99999, operational)
    do g = 1, 34
      call group_controls(g, operational, controls, capacity, registered)
      rank = controls%rank
      allocate (registry%groups(g)%fields(capacity), stat=error)
      if (error /= 0) then
        status = 1
        goto900
      end if
      call group_key(g, registry%groups(g)%key)
      controls%trajectory_start = local_trajectory%dynamic_count
      controls%constant_start = local_trajectory%constant_count
      if (capacity == 0) then
        controls%field_capacity = 1
        status = initialize_surface_group(controls, registry%groups(g)%metadata, dummy)
      else
        status = initialize_surface_group(controls, registry%groups(g)%metadata, registry%groups(g)%fields)
      end if
      if (status /= 0) goto900
      do j = 1, registered
        call registration_plan(g, j, operational, plan)
        if (rank == 3) then
          status = define_layered_surface_field(registry%groups(g)%metadata, registry%groups(g)%fields(j), local_trajectory, plan)
        else
          status = define_surface_field_2d(registry%groups(g)%metadata, registry%groups(g)%fields(j), local_trajectory, plan)
        end if
        if (status /= 0) goto900
      end do
      registry%groups(g)%metadata%layered = merge(1, 0, rank == 3)
  status = finalize_surface_group(registry%groups(g)%metadata, registry%groups(g)%fields, registry%totals, 1_int32, undefined_index)
      registry%groups(g)%metadata%layered = 0
      if (status /= 0) goto900
    end do
    call bind_aliases(registry, operational)
    registry%albedo_first = merge(31, 27, operational)
    registry%albedo_last = merge(36, 30, operational)
    registry%dynamic_count = local_trajectory%dynamic_count
    registry%constant_count = local_trajectory%constant_count
    trajectory = local_trajectory
    descriptions = surface_physics_descriptions()
    registry%ready = .true.
    status = 0
    goto910
900 child = release_selected_surface_configuration(registry)
    registry%totals = surface_field_totals()
    registry%aliases = surface_metadata_alias()
    registry%albedo_first = 0; registry%albedo_last = 0
    registry%dynamic_count = 0; registry%constant_count = 0
    do g = 1, 34
      registry%groups(g)%key = ' '
      registry%groups(g)%metadata = surface_group_metadata()
    end do
910 call ieee_set_status(incoming)
    error_number = saved_errno
  end function
  logical function fresh_registry(registry) result(fresh)
    type(surface_field_registry), intent(in) :: registry
    integer :: g
    fresh = .false.
    if (registry%ready) return
    do g = 1, 34
      if (allocated(registry%groups(g)%fields)) return
      associate (m => registry%groups(g)%metadata)
        if (m%registered_fields /= 0 .or. m%stored_fields /= 0 .or. m%layers /= 0 .or. m%next_field /= 0) return
        if (m%unwritten_word /= 0 .or. m%trajectory_fields /= 0 .or. m%trajectory_start /= 0 .or. m%constant_start /= 0) return
        if (m%layered /= 0 .or. m%multiple_state /= 0 .or. m%finalized /= 0) return
        if (m%name /= ' ' .or. registry%groups(g)%key /= ' ') return
      end associate
    end do
    if (registry%totals%registered /= 0 .or. registry%totals%registered_levels /= 0) return
    if (registry%totals%stored /= 0 .or. registry%totals%stored_levels /= 0) return
    if (registry%totals%multiple /= 0 .or. registry%totals%multiple_levels /= 0) return
    if (any(registry%aliases%group /= 0) .or. any(registry%aliases%first_field /= 0)) return
    if (any(registry%aliases%rank /= 0) .or. any(registry%aliases%extent1 /= 0) .or. any(registry%aliases%extent2 /= 0)) return
    if (any(registry%aliases%name /= ' ')) return
    if (registry%albedo_first /= 0 .or. registry%albedo_last /= 0) return
    if (registry%dynamic_count /= 0 .or. registry%constant_count /= 0) return
    fresh = .true.
  end function
  integer(int32) function release_selected_surface_configuration(registry) result(status)
    !! Release each group's layer owners, then its complete field owner, in
    !! source group order. Repeated release returns0. Named alias indices and
    !! scalar metadata remain for inspection; their borrowed fields expire.
    type(surface_field_registry), intent(inout) :: registry
    type(ieee_status_type) :: incoming
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored
    integer :: g, j, n
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    do g = 1, 34
      if (.not. allocated(registry%groups(g)%fields)) cycle
      if (registry%groups(g)%metadata%layers >= 0) then
        n = min(size(registry%groups(g)%fields), max(0, registry%groups(g)%metadata%next_field - 1))
        do j = 1, n
          ignored = release_layered_surface_field(registry%groups(g)%fields(j))
        end do
      end if
      deallocate (registry%groups(g)%fields)
    end do
    registry%ready = .false.
    call ieee_set_status(incoming); error_number = saved_errno
    status = 0
  end function
  subroutine group_controls(g, operational, controls, capacity, registered)
    integer, intent(in) :: g
    logical, intent(in) :: operational
    type(surface_group_controls), intent(out) :: controls
    integer(int32), intent(out) :: capacity, registered
    controls = surface_group_controls()
    select case (g)
    case (1)
      capacity = 694; registered = 3
      controls%rank = 3; controls%layers = 4
      controls%multiple_state = 1
      controls%name = 'SOILB - SP_SB   '
    case (2)
      capacity = 694; registered = 5
      controls%rank = 3; controls%layers = 5
      controls%multiple_state = 1
      controls%name = 'SNOWG - SP_SG   '
    case (3)
      capacity = 694; registered = 7
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 1
      controls%name = 'LAKEG - SP_SL   '
    case (4)
      capacity = 694; registered = 2
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 1
      controls%name = 'RESVR - SP_RR   '
    case (5)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 1
      controls%name = 'CLS   - SP_CL   '
    case (6)
      capacity = 694; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 1
      controls%name = 'OML   - SP_OM   '
    case (7)
      capacity = 694; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 1
      controls%name = 'EXTRP - SP_EP   '
    case (8)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 1
      controls%name = 'XTRP2 - SP_X2   '
    case (9)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 1
      controls%name = 'CANRI - SP_CI   '
    case (10)
      capacity = 694; registered = 38
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VARSF - SD_VF   '
    case (11)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VCLIP - SD_VP   '
    case (12)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VCLIV - SD_VV   '
    case (13)
      capacity = 694; registered = 5
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VCLIN - SD_VN   '
    case (14)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VCLIH - SD_VH   '
    case (15)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VCLIK - SD_VK   '
    case (16)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VCLIA - SD_VA   '
    case (17)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VO3ABC - SD_VC  '
    case (18)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VDIAGO2 - SD_V2 '
    case (19)
      capacity = 694; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 0
      controls%name = 'VDIAGO3 - SD_V3 '
    case (20)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'OCEAN - SD_OC   '
    case (21)
      capacity = 694; registered = 272
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VDIAG - SD_VD   '
    case (22)
      capacity = 694; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 0
      controls%name = 'SATSIM - SD_SM  '
    case (23)
      capacity = 694; registered = 1
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'WAVES - SD_WS   '
      if (operational) registered = 3
    case (24)
      capacity = 694; registered = 6
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'WAVES - SD_WW   '
    case (25)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VCLIX - SD_VX   '
    case (26)
      capacity = 0; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 0
      controls%name = 'VEXTRDI - SD_DI '
    case (27)
      capacity = 0; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 0
      controls%name = 'VPRECIP - SD_XP '
    case (28)
      capacity = 0; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 0
      controls%name = 'VPRECIP2 - SD_XP'
    case (29)
      capacity = 0; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 0
      controls%name = 'VEXTRA - SD_XA  '
    case (30)
      capacity = 1; registered = 1
      controls%rank = 3; controls%layers = 19
      controls%multiple_state = 0
      controls%name = 'precip fraction '
      if (operational) controls%layers = 137
    case (31)
      capacity = 0; registered = 0
      controls%rank = 3; controls%layers = 0
      controls%multiple_state = 0
      controls%name = 'VEXTRAD - SD_XR '
    case (32)
      capacity = 0; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'VEXTR2 - SD_X2  '
    case (33)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'SFLUX - SD_SFL  '
    case (34)
      capacity = 694; registered = 0
      controls%rank = 2; controls%layers = -1
      controls%multiple_state = 0
      controls%name = 'SFORC - SD_SFO  '
    end select
    controls%field_capacity = capacity
    controls%undefined_index = merge(-999999, -99999, operational)
  end subroutine
  subroutine group_key(g, key)
    integer, intent(in) :: g
    character(16), intent(out) :: key
    select case (g)
    case (1)
      key = 'YSP_SBD'
    case (2)
      key = 'YSP_SGD'
    case (3)
      key = 'YSP_SLD'
    case (4)
      key = 'YSP_RRD'
    case (5)
      key = 'YSP_CLD'
    case (6)
      key = 'YSP_OMD'
    case (7)
      key = 'YSP_EPD'
    case (8)
      key = 'YSP_X2D'
    case (9)
      key = 'YSP_CID'
    case (10)
      key = 'YSD_VFD'
    case (11)
      key = 'YSD_VPD'
    case (12)
      key = 'YSD_VVD'
    case (13)
      key = 'YSD_VND'
    case (14)
      key = 'YSD_VHD'
    case (15)
      key = 'YSD_VKD'
    case (16)
      key = 'YSD_VAD'
    case (17)
      key = 'YSD_VCD'
    case (18)
      key = 'YSD_V2D'
    case (19)
      key = 'YSD_V3D'
    case (20)
      key = 'YSD_OCD'
    case (21)
      key = 'YSD_VDD'
    case (22)
      key = 'YSD_SMD'
    case (23)
      key = 'YSD_WSD'
    case (24)
      key = 'YSD_WWD'
    case (25)
      key = 'YSD_VXD'
    case (26)
      key = 'YSD_DID'
    case (27)
      key = 'YSD_XPD'
    case (28)
      key = 'YSD_XP2D'
    case (29)
      key = 'YSD_XAD'
    case (30)
      key = 'YSD_PFD'
    case (31)
      key = 'YSD_XRD'
    case (32)
      key = 'YSD_X2D'
    case (33)
      key = 'YSD_SFLD'
    case (34)
      key = 'YSD_SFOD'
    end select
  end subroutine
  subroutine registration_plan(g, j, operational, plan)
    integer, intent(in) :: g, j
    logical, intent(in) :: operational
    type(surface_registration_plan), intent(out) :: plan
    select case (g)
    case (1)
      select case (j)
      case (1)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%layer_parameters => literal_1
        plan%layer_names => literal_2
        plan%layer_defaults => literal_3
        plan%layer_source_flags => literal_4
      case (2)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%layer_parameters => literal_5
        plan%layer_names => literal_6
        plan%layer_defaults => literal_7
        plan%layer_source_flags => literal_8
      case (3)
        plan = surface_registration_plan()
        plan%presence_mask = 23_int32
        plan%trajectory_kind = 0_int32
        plan%layer_parameters => literal_9
        plan%layer_names => literal_10
        plan%layer_defaults => literal_11
        plan%layer_source_flags => literal_12
      end select
    case (2)
      select case (j)
      case (1)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%layer_parameters => literal_13
        plan%layer_names => literal_14
        plan%layer_defaults => literal_15
        plan%layer_source_flags => literal_16
      case (2)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%layer_parameters => literal_17
        plan%layer_names => literal_18
        plan%layer_defaults => literal_19
        plan%layer_source_flags => literal_20
      case (3)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%layer_parameters => literal_21
        plan%layer_names => literal_22
        plan%layer_defaults => literal_23
        plan%layer_source_flags => literal_24
      case (4)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%layer_parameters => literal_25
        plan%layer_names => literal_26
        plan%layer_defaults => literal_27
        plan%layer_source_flags => literal_28
      case (5)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%layer_parameters => literal_29
        plan%layer_names => literal_30
        plan%layer_defaults => literal_31
        plan%layer_source_flags => literal_32
      end select
    case (3)
      select case (j)
      case (1)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 2_int32
        plan%parameter = 228008_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'Lake mix layer T'
      case (2)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 2_int32
        plan%parameter = 228009_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'Lake mix layer D'
      case (3)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 2_int32
        plan%parameter = 228010_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'Lake bottom lay '
      case (4)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 2_int32
        plan%parameter = 228011_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'Lake total lay T'
      case (5)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 2_int32
        plan%parameter = 228012_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'Lake shape fact.'
      case (6)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 2_int32
        plan%parameter = 228013_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'Lake ice T      '
      case (7)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 2_int32
        plan%parameter = 228014_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'Lake ice depth  '
      end select
    case (4)
      select case (j)
      case (1)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 235_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'SKINTEMPERATURE '
      case (2)
        plan = surface_registration_plan()
        plan%presence_mask = 31_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 198_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 1_int32
        plan%name = 'SKINRESERV.EAU  '
      end select
    case (10)
      if (operational) then
        select case (j)
        case (1)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 173_int32
          plan%default_value = transfer(int(z'3F847AE147AE147B', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFZ0.FOIS.G   '
        case (2)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 174_int32
          plan%default_value = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFALBEDO      '
        case (3)
          plan = surface_registration_plan()
          plan%presence_mask = 30_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 0_int32
          plan%default_value = transfer(int(z'3FEFD70A3D70A3D7', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'SURFEMISSIVITE  '
        case (4)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 160_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFET.GEOPOTENT'
        case (5)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 172_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFIND.TERREMER'
        case (6)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 161_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFVAR.GEOP.ANI'
        case (7)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 162_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFVAR.GEOP.DIR'
        case (8)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 163_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFMEAN SLOPE  '
        case (9)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 234_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFLOGZ0H      '
        case (10)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 27_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LOW VEG. COVER  '
        case (11)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 129172_int32
          plan%default_value = transfer(int(z'4008000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'CO2 PHOTOS. TYPE'
        case (12)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 28_int32
          plan%default_value = transfer(int(z'40226B851EB851EC', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'HIGH VEG. COVER '
        case (13)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 200199_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'URBAN COVER     '
        case (14)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 200026_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'WETLAND FRACTION'
        case (15)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 29_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LOW VEG. TYPE   '
        case (16)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 30_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'HIGH VEG. TYPE  '
        case (17)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 66_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LOW VEG. LAI    '
        case (18)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 67_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'HIGH VEG. LAI   '
        case (19)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 43_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SOIL TYPE       '
        case (20)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 26_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LAKE COVER      '
        case (21)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 228007_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LAKE DEPTH      '
        case (22)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 31_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SEA ICE COVER   '
        case (23)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 34_int32
          plan%default_value = transfer(int(z'4072700000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SEA SURFACE TEMP'
        case (24)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 151131_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'UCOM OCEAN CURRE'
        case (25)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 151132_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'VCOM OCEAN CURRE'
        case (26)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 74_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SD FILTRED OROG '
        case (27)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 15_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.UVis PARAL'
        case (28)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 16_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.UVis DIFFU'
        case (29)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 17_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.N-IR PARAL'
        case (30)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 18_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.N-IR DIFFU'
        case (31)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210186_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.UVisPARALI'
        case (32)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210187_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.UVisPARALV'
        case (33)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210188_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.UVisPARALG'
        case (34)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210189_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.N-IRPARALI'
        case (35)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210190_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.N-IRPARALV'
        case (36)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210191_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.N-IRPARALG'
        case (37)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 228078_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'GPP FLUX ADJ. CO'
        case (38)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 228079_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'REC FLUX ADJ. CO'
        end select
      else
        select case (j)
        case (1)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 173_int32
          plan%default_value = transfer(int(z'3F847AE147AE147B', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFZ0.FOIS.G   '
        case (2)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 174_int32
          plan%default_value = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFALBEDO      '
        case (3)
          plan = surface_registration_plan()
          plan%presence_mask = 30_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 0_int32
          plan%default_value = transfer(int(z'3FEFD70A3D70A3D7', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'SURFEMISSIVITE  '
        case (4)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 160_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFET.GEOPOTENT'
        case (5)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 172_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFIND.TERREMER'
        case (6)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 161_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFVAR.GEOP.ANI'
        case (7)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 162_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFVAR.GEOP.DIR'
        case (8)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 163_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFMEAN SLOPE  '
        case (9)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 234_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SURFLOGZ0H      '
        case (10)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 27_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LOW VEG. COVER  '
        case (11)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 129172_int32
          plan%default_value = transfer(int(z'4008000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'CO2 PHOTOS. TYPE'
        case (12)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 28_int32
          plan%default_value = transfer(int(z'40226B851EB851EC', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'HIGH VEG. COVER '
        case (13)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 200199_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'URBAN COVER     '
        case (14)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 200026_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'WETLAND FRACTION'
        case (15)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 29_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LOW VEG. TYPE   '
        case (16)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 30_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'HIGH VEG. TYPE  '
        case (17)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 66_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LOW VEG. LAI    '
        case (18)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 67_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'HIGH VEG. LAI   '
        case (19)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 43_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SOIL TYPE       '
        case (20)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 26_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LAKE COVER      '
        case (21)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 228007_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'LAKE DEPTH      '
        case (22)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 31_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SEA ICE COVER   '
        case (23)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 34_int32
          plan%default_value = transfer(int(z'4072700000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SEA SURFACE TEMP'
        case (24)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 151131_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'UCOM OCEAN CURRE'
        case (25)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 151132_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'VCOM OCEAN CURRE'
        case (26)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 74_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'SD FILTRED OROG '
        case (27)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 15_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.UVis PARAL'
        case (28)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 16_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.UVis DIFFU'
        case (29)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 17_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.N-IR PARAL'
        case (30)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 18_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'M_ALB.N-IR DIFFU'
        case (31)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210186_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.UVisPARALI'
        case (32)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210187_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.UVisPARALV'
        case (33)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210188_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.UVisPARALG'
        case (34)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210189_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.N-IRPARALI'
        case (35)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210190_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.N-IRPARALV'
        case (36)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 210191_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'M_ALB.N-IRPARALG'
        case (37)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 228078_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'GPP FLUX ADJ. CO'
        case (38)
          plan = surface_registration_plan()
          plan%presence_mask = 27_int32
          plan%trajectory_kind = 2_int32
          plan%parameter = 228079_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'REC FLUX ADJ. CO'
        end select
      end if
    case (13)
      select case (j)
      case (1)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (2)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (3)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (4)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (5)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      end select
    case (21)
      select case (j)
      case (1)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 142_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (2)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 143_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (3)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 144_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (4)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228216_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (5)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 145_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (6)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 146_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (7)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 147_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (8)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228080_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (9)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228081_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (10)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228082_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (11)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 151_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (12)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 134_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (13)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 164_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (14)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 176_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (15)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 177_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (16)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 178_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (17)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 179_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (18)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 180_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (19)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 181_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (20)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 182_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (21)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228251_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (22)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 185_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (23)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 186_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (24)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 187_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (25)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 188_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (26)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 195_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (27)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 196_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (28)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 197_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (29)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 201_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (30)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 202_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (31)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 205_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (32)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 8_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (33)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 9_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (34)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 243_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (35)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 229_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (36)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 230_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (37)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 231_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (38)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 232_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (39)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228083_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (40)
        plan = surface_registration_plan()
        plan%presence_mask = 9_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 228084_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (41)
        plan = surface_registration_plan()
        plan%presence_mask = 9_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 228085_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (42)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228104_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (43)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 239_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (44)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 240_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (45)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228226_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (46)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228227_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (47)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 260048_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (48)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228219_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (49)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228218_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (50)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228221_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (51)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228220_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (52)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 260015_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (53)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228217_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (54)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 244_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = 'FC SURFACE Z0   '
      case (55)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 245_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = 'LOG FC SURF Z0H '
      case (56)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 162071_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (57)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 162072_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (58)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 136_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (59)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 137_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (60)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 78_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (61)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 79_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (62)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228089_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (63)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228090_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (64)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228088_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (65)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 169_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (66)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228129_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (67)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228130_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (68)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 175_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (69)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 159_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (70)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 189_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (71)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 58_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (72)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 57_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (73)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 59_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (74)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228235_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (75)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228231_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (76)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228233_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (77)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228237_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (78)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228044_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (79)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228045_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (80)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 208_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (81)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 209_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (82)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (83)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 211_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (84)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 44_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (85)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 45_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (86)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 49_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (87)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228029_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (88)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (89)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 50_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (90)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 206_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (91)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 213_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (92)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 20_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (93)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 212_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (94)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228021_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (95)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228022_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (96)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 47_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (97)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228023_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (98)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228024_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (99)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228020_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (100)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 3020_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (101)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228001_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (102)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228232_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (103)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228234_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (104)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 260121_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (105)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 260123_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (106)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 260109_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (107)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228046_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (108)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228047_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (109)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228048_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (110)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228246_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (111)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228247_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (112)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228239_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (113)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228240_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (114)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228003_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (115)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 165_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '10M UWIND       '
      case (116)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 166_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '10M VWIND       '
      case (117)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 167_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '2M TEMPERATURE  '
      case (118)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 168_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '2M DEWPOINT     '
      case (119)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 174096_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '2M HUMIDITY     '
      case (120)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 228131_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '10M NEUTRL UWIND'
      case (121)
        plan = surface_registration_plan()
        plan%presence_mask = 27_int32
        plan%trajectory_kind = 1_int32
        plan%parameter = 228132_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '10M NEUTRL VWIND'
      case (122)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228015_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (123)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228016_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (124)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228017_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (125)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228018_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (126)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228019_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (127)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228050_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (128)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228052_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (129)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210208_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (130)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210209_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (131)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210210_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (132)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210211_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (133)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210212_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (134)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210250_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (135)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210251_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (136)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 215226_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (137)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210244_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (138)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210243_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (139)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 215089_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (140)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210072_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (141)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210073_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (142)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210074_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (143)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 214002_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (144)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 214003_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (145)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 141_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (146)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 210207_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (147)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 121_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (148)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 121_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (149)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 121_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (150)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 121_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (151)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 121_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (152)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 121_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (153)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 122_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (154)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 122_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (155)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 122_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (156)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 122_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (157)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 122_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (158)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 122_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (159)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 123_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (160)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 123_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (161)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 123_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (162)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 123_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (163)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 123_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (164)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 123_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (165)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228224_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (166)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228224_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (167)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228224_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (168)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228224_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (169)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228224_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (170)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228224_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (171)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228225_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (172)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228225_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (173)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228225_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (174)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228225_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (175)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228225_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (176)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228225_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (177)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228035_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (178)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228035_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (179)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228035_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (180)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228035_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (181)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228035_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (182)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228035_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (183)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228036_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (184)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228036_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (185)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228036_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (186)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228036_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (187)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228036_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (188)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228036_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (189)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228058_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (190)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228058_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (191)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228058_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (192)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228058_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (193)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228058_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (194)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228058_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (195)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228060_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (196)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228060_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (197)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228060_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (198)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228060_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (199)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228060_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (200)
        plan = surface_registration_plan()
        plan%presence_mask = 1_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 228060_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (201)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (202)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (203)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (204)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (205)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (206)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (207)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (208)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (209)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (210)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (211)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (212)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (213)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (214)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (215)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (216)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (217)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (218)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (219)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (220)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (221)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (222)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (223)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (224)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (225)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (226)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (227)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (228)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (229)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (230)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (231)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (232)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (233)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (234)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (235)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (236)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (237)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (238)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (239)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (240)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (241)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (242)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (243)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (244)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (245)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (246)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (247)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (248)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (249)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (250)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (251)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (252)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (253)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (254)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (255)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (256)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (257)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (258)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (259)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (260)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (261)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (262)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (263)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (264)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (265)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (266)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (267)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (268)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (269)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (270)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (271)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      case (272)
        plan = surface_registration_plan()
        plan%presence_mask = 0_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '                '
      end select
    case (23)
      if (operational) then
        select case (j)
        case (1)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 1_int32
          plan%parameter = 148_int32
          plan%default_value = transfer(int(z'3F926E978D4FDF3B', int64), 0.0_real64)
          plan%source_flag = 1_int32
          plan%name = 'CHARNOCK_PARAM  '
        case (2)
          plan = surface_registration_plan()
          plan%presence_mask = 6_int32
          plan%trajectory_kind = 0_int32
          plan%parameter = 0_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 0_int32
          plan%name = 'U-STOKES_DRIFT  '
        case (3)
          plan = surface_registration_plan()
          plan%presence_mask = 6_int32
          plan%trajectory_kind = 0_int32
          plan%parameter = 0_int32
          plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
          plan%source_flag = 0_int32
          plan%name = 'V-STOKES_DRIFT  '
        end select
      else
        select case (j)
        case (1)
          plan = surface_registration_plan()
          plan%presence_mask = 31_int32
          plan%trajectory_kind = 1_int32
          plan%parameter = 148_int32
          plan%default_value = transfer(int(z'3F926E978D4FDF3B', int64), 0.0_real64)
          plan%source_flag = -1_int32
          plan%name = 'CHARNOCK_PARAM  '
        end select
      end if
    case (24)
      select case (j)
      case (1)
        plan = surface_registration_plan()
        plan%presence_mask = 2_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '10m_NEUTRAL_U   '
      case (2)
        plan = surface_registration_plan()
        plan%presence_mask = 2_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = '10m_NEUTRAL_V   '
      case (3)
        plan = surface_registration_plan()
        plan%presence_mask = 2_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = 'SURFACE_DENSITY '
      case (4)
        plan = surface_registration_plan()
        plan%presence_mask = 2_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = 'w*              '
      case (5)
        plan = surface_registration_plan()
        plan%presence_mask = 2_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = 'SEA_ICE_FRACTION'
      case (6)
        plan = surface_registration_plan()
        plan%presence_mask = 2_int32
        plan%trajectory_kind = 0_int32
        plan%parameter = 0_int32
        plan%default_value = transfer(int(z'0000000000000000', int64), 0.0_real64)
        plan%source_flag = 0_int32
        plan%name = 'LAKE_FRACTION   '
      end select
    case (30)
      if (operational) then
        select case (j)
        case (1)
          plan = surface_registration_plan()
          plan%presence_mask = 7_int32
          plan%trajectory_kind = 0_int32
          plan%layer_parameters => literal_36
          plan%layer_names => literal_37
          plan%layer_defaults => literal_38
        end select
      else
        select case (j)
        case (1)
          plan = surface_registration_plan()
          plan%presence_mask = 7_int32
          plan%trajectory_kind = 0_int32
          plan%layer_parameters => literal_33
          plan%layer_names => literal_34
          plan%layer_defaults => literal_35
        end select
      end if
    end select
  end subroutine
  subroutine bind_aliases(registry, operational)
    type(surface_field_registry), intent(inout) :: registry
    logical, intent(in) :: operational
    registry%aliases(1) = surface_metadata_alias('YSP_SB%YT', 1, 1, 0, 1, 1)
    registry%aliases(2) = surface_metadata_alias('YSP_SB%YQ', 1, 2, 0, 1, 1)
    registry%aliases(3) = surface_metadata_alias('YSP_SB%YTL', 1, 3, 0, 1, 1)
    registry%aliases(4) = surface_metadata_alias('YSP_SG%YF', 2, 1, 0, 1, 1)
    registry%aliases(5) = surface_metadata_alias('YSP_SG%YA', 2, 2, 0, 1, 1)
    registry%aliases(6) = surface_metadata_alias('YSP_SG%YR', 2, 3, 0, 1, 1)
    registry%aliases(7) = surface_metadata_alias('YSP_SG%YT', 2, 4, 0, 1, 1)
    registry%aliases(8) = surface_metadata_alias('YSP_SG%YW', 2, 5, 0, 1, 1)
    registry%aliases(9) = surface_metadata_alias('YSP_SL%YLMLT', 3, 1, 0, 1, 1)
    registry%aliases(10) = surface_metadata_alias('YSP_SL%YLMLD', 3, 2, 0, 1, 1)
    registry%aliases(11) = surface_metadata_alias('YSP_SL%YLBLT', 3, 3, 0, 1, 1)
    registry%aliases(12) = surface_metadata_alias('YSP_SL%YLTLT', 3, 4, 0, 1, 1)
    registry%aliases(13) = surface_metadata_alias('YSP_SL%YLSHF', 3, 5, 0, 1, 1)
    registry%aliases(14) = surface_metadata_alias('YSP_SL%YLICT', 3, 6, 0, 1, 1)
    registry%aliases(15) = surface_metadata_alias('YSP_SL%YLICD', 3, 7, 0, 1, 1)
    registry%aliases(16) = surface_metadata_alias('YSP_RR%YT', 4, 1, 0, 1, 1)
    registry%aliases(17) = surface_metadata_alias('YSP_RR%YW', 4, 2, 0, 1, 1)
    registry%aliases(18) = surface_metadata_alias('YSP_RR%YFC', 4, 694, 0, 1, 1)
    registry%aliases(19) = surface_metadata_alias('YSP_RR%YIC', 4, 694, 0, 1, 1)
    registry%aliases(20) = surface_metadata_alias('YSP_RR%YFP1', 4, 694, 0, 1, 1)
    registry%aliases(21) = surface_metadata_alias('YSP_CL%YTCLS', 5, 694, 0, 1, 1)
    registry%aliases(22) = surface_metadata_alias('YSP_CL%YHUCLS', 5, 694, 0, 1, 1)
    registry%aliases(23) = surface_metadata_alias('YSP_CL%YUCLS', 5, 694, 0, 1, 1)
    registry%aliases(24) = surface_metadata_alias('YSP_CL%YVCLS', 5, 694, 0, 1, 1)
    registry%aliases(25) = surface_metadata_alias('YSP_CL%YNUCLS', 5, 694, 0, 1, 1)
    registry%aliases(26) = surface_metadata_alias('YSP_CL%YNVCLS', 5, 694, 0, 1, 1)
    registry%aliases(27) = surface_metadata_alias('YSP_OM%YTO', 6, 694, 0, 1, 1)
    registry%aliases(28) = surface_metadata_alias('YSP_OM%YSO', 6, 694, 0, 1, 1)
    registry%aliases(29) = surface_metadata_alias('YSP_OM%YUO', 6, 694, 0, 1, 1)
    registry%aliases(30) = surface_metadata_alias('YSP_OM%YVO', 6, 694, 0, 1, 1)
    registry%aliases(31) = surface_metadata_alias('YSD_VF%YZ0F', 10, 1, 0, 1, 1)
    registry%aliases(32) = surface_metadata_alias('YSD_VF%YALBF', 10, 2, 0, 1, 1)
    registry%aliases(33) = surface_metadata_alias('YSD_VF%YEMISF', 10, 3, 0, 1, 1)
    registry%aliases(34) = surface_metadata_alias('YSD_VF%YGETRL', 10, 4, 0, 1, 1)
    registry%aliases(35) = surface_metadata_alias('YSD_VF%YLSM', 10, 5, 0, 1, 1)
    registry%aliases(36) = surface_metadata_alias('YSD_VF%YVEG', 10, 694, 0, 1, 1)
    registry%aliases(37) = surface_metadata_alias('YSD_VF%YVRLAN', 10, 6, 0, 1, 1)
    registry%aliases(38) = surface_metadata_alias('YSD_VF%YVRLDI', 10, 7, 0, 1, 1)
    registry%aliases(39) = surface_metadata_alias('YSD_VF%YSIG', 10, 8, 0, 1, 1)
    registry%aliases(40) = surface_metadata_alias('YSD_VF%YALBSF', 10, 694, 0, 1, 1)
    registry%aliases(41) = surface_metadata_alias('YSD_VF%YLAN', 10, 694, 0, 1, 1)
    registry%aliases(42) = surface_metadata_alias('YSD_VF%YSST', 10, 23, 0, 1, 1)
    registry%aliases(43) = surface_metadata_alias('YSD_VF%YLZ0H', 10, 9, 0, 1, 1)
    registry%aliases(44) = surface_metadata_alias('YSD_VF%YCVL', 10, 10, 0, 1, 1)
    registry%aliases(45) = surface_metadata_alias('YSD_VF%YCO2TYP', 10, 11, 0, 1, 1)
    registry%aliases(46) = surface_metadata_alias('YSD_VF%YCVH', 10, 12, 0, 1, 1)
    registry%aliases(47) = surface_metadata_alias('YSD_VF%YCUR', 10, 13, 0, 1, 1)
    registry%aliases(48) = surface_metadata_alias('YSD_VF%YTVL', 10, 15, 0, 1, 1)
    registry%aliases(49) = surface_metadata_alias('YSD_VF%YTVH', 10, 16, 0, 1, 1)
    registry%aliases(50) = surface_metadata_alias('YSD_VF%YLAIL', 10, 17, 0, 1, 1)
    registry%aliases(51) = surface_metadata_alias('YSD_VF%YLAIH', 10, 18, 0, 1, 1)
    registry%aliases(52) = surface_metadata_alias('YSD_VF%YFWET', 10, 14, 0, 1, 1)
    registry%aliases(53) = surface_metadata_alias('YSD_VF%YSOTY', 10, 19, 0, 1, 1)
    registry%aliases(54) = surface_metadata_alias('YSD_VF%YCLK', 10, 20, 0, 1, 1)
    registry%aliases(55) = surface_metadata_alias('YSD_VF%YDL', 10, 21, 0, 1, 1)
    registry%aliases(56) = surface_metadata_alias('YSD_VF%YCI', 10, 22, 0, 1, 1)
    registry%aliases(57) = surface_metadata_alias('YSD_VF%YUCUR', 10, 24, 0, 1, 1)
    registry%aliases(58) = surface_metadata_alias('YSD_VF%YVCUR', 10, 25, 0, 1, 1)
    registry%aliases(59) = surface_metadata_alias('YSD_VF%YZ0RLF', 10, 694, 0, 1, 1)
    registry%aliases(60) = surface_metadata_alias('YSD_VF%YSDFOR', 10, 26, 0, 1, 1)
    registry%aliases(61) = surface_metadata_alias('YSD_VF%YALUVP', 10, 27, 0, 1, 1)
    registry%aliases(62) = surface_metadata_alias('YSD_VF%YALUVD', 10, 28, 0, 1, 1)
    registry%aliases(63) = surface_metadata_alias('YSD_VF%YALNIP', 10, 29, 0, 1, 1)
    registry%aliases(64) = surface_metadata_alias('YSD_VF%YALNID', 10, 30, 0, 1, 1)
    registry%aliases(65) = surface_metadata_alias('YSD_VF%YALUVI', 10, 31, 0, 1, 1)
    registry%aliases(66) = surface_metadata_alias('YSD_VF%YALUVV', 10, 32, 0, 1, 1)
    registry%aliases(67) = surface_metadata_alias('YSD_VF%YALUVG', 10, 33, 0, 1, 1)
    registry%aliases(68) = surface_metadata_alias('YSD_VF%YALNII', 10, 34, 0, 1, 1)
    registry%aliases(69) = surface_metadata_alias('YSD_VF%YALNIV', 10, 35, 0, 1, 1)
    registry%aliases(70) = surface_metadata_alias('YSD_VF%YALNIG', 10, 36, 0, 1, 1)
    registry%aliases(71) = surface_metadata_alias('YSD_VF%YAERDEP', 10, 694, 0, 1, 1)
    registry%aliases(72) = surface_metadata_alias('YSD_VF%YAERLTS', 10, 694, 0, 1, 1)
    registry%aliases(73) = surface_metadata_alias('YSD_VF%YAERSCC', 10, 694, 0, 1, 1)
    registry%aliases(74) = surface_metadata_alias('YSD_VF%YDSF', 10, 694, 0, 1, 1)
    registry%aliases(75) = surface_metadata_alias('YSD_VF%YDSZ', 10, 694, 0, 1, 1)
    registry%aliases(76) = surface_metadata_alias('YSD_VF%YDMSO', 10, 694, 0, 1, 1)
    registry%aliases(77) = surface_metadata_alias('YSD_VF%YURBF', 10, 694, 0, 1, 1)
    registry%aliases(78) = surface_metadata_alias('YSD_VF%YFCA1', 10, 694, 0, 1, 1)
    registry%aliases(79) = surface_metadata_alias('YSD_VF%YFCA2', 10, 694, 0, 1, 1)
    registry%aliases(80) = surface_metadata_alias('YSD_VF%YSO2DD', 10, 694, 0, 1, 1)
    registry%aliases(81) = surface_metadata_alias('YSD_VF%YCHEMFLXO', 10, 694, 1, 1, 1)
    registry%aliases(82) = surface_metadata_alias('YSD_VF%YCHEMDDFLX', 10, 694, 1, 1, 1)
    registry%aliases(83) = surface_metadata_alias('YSD_VF%YCHEMWDFLX', 10, 694, 1, 1, 1)
    registry%aliases(84) = surface_metadata_alias('YSD_VF%YCHEMDV', 10, 694, 1, 1, 1)
    registry%aliases(85) = surface_metadata_alias('YSD_VF%YEMIS2D', 10, 694, 1, 1, 1)
    registry%aliases(86) = surface_metadata_alias('YSD_VF%YEMIS2DAUX', 10, 694, 1, 1, 1)
    registry%aliases(87) = surface_metadata_alias('YSD_VF%YCGPP', 10, 37, 0, 1, 1)
    registry%aliases(88) = surface_metadata_alias('YSD_VF%YCREC', 10, 38, 0, 1, 1)
    registry%aliases(89) = surface_metadata_alias('YSD_VF%YFP1', 10, 694, 0, 1, 1)
    registry%aliases(90) = surface_metadata_alias('YSD_VF%YNUDM', 10, 694, 0, 1, 1)
    registry%aliases(91) = surface_metadata_alias('YSD_VF%YSSS', 10, 694, 0, 1, 1)
    registry%aliases(92) = surface_metadata_alias('YSD_VP%YTPC', 11, 694, 0, 1, 1)
    registry%aliases(93) = surface_metadata_alias('YSD_VP%YWPC', 11, 694, 0, 1, 1)
    registry%aliases(94) = surface_metadata_alias('YSD_VV%YARG', 12, 694, 0, 1, 1)
    registry%aliases(95) = surface_metadata_alias('YSD_VV%YSAB', 12, 694, 0, 1, 1)
    registry%aliases(96) = surface_metadata_alias('YSD_VV%YD2', 12, 694, 0, 1, 1)
    registry%aliases(97) = surface_metadata_alias('YSD_VV%YIVEG', 12, 694, 0, 1, 1)
    registry%aliases(98) = surface_metadata_alias('YSD_VV%YRSMIN', 12, 694, 0, 1, 1)
    registry%aliases(99) = surface_metadata_alias('YSD_VV%YLAI', 12, 694, 0, 1, 1)
    registry%aliases(100) = surface_metadata_alias('YSD_VV%YHV', 12, 694, 0, 1, 1)
    registry%aliases(101) = surface_metadata_alias('YSD_VV%YZ0H', 12, 694, 0, 1, 1)
    registry%aliases(102) = surface_metadata_alias('YSD_VV%YALS', 12, 694, 0, 1, 1)
    registry%aliases(103) = surface_metadata_alias('YSD_VV%YALV', 12, 694, 0, 1, 1)
    registry%aliases(104) = surface_metadata_alias('YSD_VN%YTOP', 13, 1, 0, 1, 1)
    registry%aliases(105) = surface_metadata_alias('YSD_VN%YBAS', 13, 2, 0, 1, 1)
    registry%aliases(106) = surface_metadata_alias('YSD_VN%YACPR', 13, 3, 0, 1, 1)
    registry%aliases(107) = surface_metadata_alias('YSD_VN%YACCPR', 13, 4, 0, 1, 1)
    registry%aliases(108) = surface_metadata_alias('YSD_VN%YACCPR5', 13, 5, 0, 1, 1)
    registry%aliases(109) = surface_metadata_alias('YSD_VH%YTCCH', 14, 694, 0, 1, 1)
    registry%aliases(110) = surface_metadata_alias('YSD_VH%YSCCH', 14, 694, 0, 1, 1)
    registry%aliases(111) = surface_metadata_alias('YSD_VH%YBCCH', 14, 694, 0, 1, 1)
    registry%aliases(112) = surface_metadata_alias('YSD_VH%YPBLH', 14, 694, 0, 1, 1)
    registry%aliases(113) = surface_metadata_alias('YSD_VH%YSPSH', 14, 694, 0, 1, 1)
    registry%aliases(114) = surface_metadata_alias('YSD_VH%YQSH', 14, 694, 0, 1, 1)
    registry%aliases(115) = surface_metadata_alias('YSD_VK%YUDGRO', 15, 694, 0, 1, 1)
    registry%aliases(116) = surface_metadata_alias('YSD_VA%YSEA', 16, 694, 0, 1, 1)
    registry%aliases(117) = surface_metadata_alias('YSD_VA%YLAN', 16, 694, 0, 1, 1)
    registry%aliases(118) = surface_metadata_alias('YSD_VA%YSOO', 16, 694, 0, 1, 1)
    registry%aliases(119) = surface_metadata_alias('YSD_VA%YDES', 16, 694, 0, 1, 1)
    registry%aliases(120) = surface_metadata_alias('YSD_VA%YSUL', 16, 694, 0, 1, 1)
    registry%aliases(121) = surface_metadata_alias('YSD_VA%YVOL', 16, 694, 0, 1, 1)
    registry%aliases(122) = surface_metadata_alias('YSD_VC%YA', 17, 694, 0, 1, 1)
    registry%aliases(123) = surface_metadata_alias('YSD_VC%YB', 17, 694, 0, 1, 1)
    registry%aliases(124) = surface_metadata_alias('YSD_VC%YC', 17, 694, 0, 1, 1)
    registry%aliases(125) = surface_metadata_alias('YSD_V2%YOCDEP', 18, 694, 0, 1, 1)
    registry%aliases(126) = surface_metadata_alias('YSD_V2%YUSTRC', 18, 694, 0, 1, 1)
    registry%aliases(127) = surface_metadata_alias('YSD_V2%YVSTRC', 18, 694, 0, 1, 1)
    registry%aliases(128) = surface_metadata_alias('YSD_V3%YDIFM', 19, 694, 0, 1, 1)
    registry%aliases(129) = surface_metadata_alias('YSD_V3%YDIFT', 19, 694, 0, 1, 1)
    registry%aliases(130) = surface_metadata_alias('YSD_V3%YDIFS', 19, 694, 0, 1, 1)
    registry%aliases(131) = surface_metadata_alias('YSD_V3%YADVT', 19, 694, 0, 1, 1)
    registry%aliases(132) = surface_metadata_alias('YSD_V3%YADVS', 19, 694, 0, 1, 1)
    registry%aliases(133) = surface_metadata_alias('YSD_V3%YTRI0', 19, 694, 0, 1, 1)
    registry%aliases(134) = surface_metadata_alias('YSD_V3%YTRI1', 19, 694, 0, 1, 1)
    registry%aliases(135) = surface_metadata_alias('YSD_V3%YSWDK', 19, 694, 0, 1, 1)
    registry%aliases(136) = surface_metadata_alias('YSD_V3%YZO', 19, 694, 0, 1, 1)
    registry%aliases(137) = surface_metadata_alias('YSD_V3%YHO', 19, 694, 0, 1, 1)
    registry%aliases(138) = surface_metadata_alias('YSD_V3%YDO', 19, 694, 0, 1, 1)
    registry%aliases(139) = surface_metadata_alias('YSD_V3%YHO_INV', 19, 694, 0, 1, 1)
    registry%aliases(140) = surface_metadata_alias('YSD_V3%YUOC', 19, 694, 0, 1, 1)
    registry%aliases(141) = surface_metadata_alias('YSD_V3%YVOC', 19, 694, 0, 1, 1)
    registry%aliases(142) = surface_metadata_alias('YSD_V3%YOTKE', 19, 694, 0, 1, 1)
    registry%aliases(143) = surface_metadata_alias('YSD_OC%YSSTM', 20, 694, 0, 1, 1)
    registry%aliases(144) = surface_metadata_alias('YSD_OC%YCIM', 20, 694, 0, 1, 1)
    registry%aliases(145) = surface_metadata_alias('YSD_OC%YUCURM', 20, 694, 0, 1, 1)
    registry%aliases(146) = surface_metadata_alias('YSD_OC%YVCURM', 20, 694, 0, 1, 1)
    registry%aliases(147) = surface_metadata_alias('YSD_OC%YICTH', 20, 694, 0, 1, 1)
    registry%aliases(148) = surface_metadata_alias('YSD_OC%Y20D', 20, 694, 0, 1, 1)
    registry%aliases(149) = surface_metadata_alias('YSD_OC%YSSH', 20, 694, 0, 1, 1)
    registry%aliases(150) = surface_metadata_alias('YSD_OC%YMLD', 20, 694, 0, 1, 1)
    registry%aliases(151) = surface_metadata_alias('YSD_OC%YSSS', 20, 694, 0, 1, 1)
    registry%aliases(152) = surface_metadata_alias('YSD_OC%YTEM3', 20, 694, 0, 1, 1)
    registry%aliases(153) = surface_metadata_alias('YSD_OC%YSAL3', 20, 694, 0, 1, 1)
    registry%aliases(154) = surface_metadata_alias('YSD_VD%YLSP', 21, 1, 0, 1, 1)
    registry%aliases(155) = surface_metadata_alias('YSD_VD%YCP', 21, 2, 0, 1, 1)
    registry%aliases(156) = surface_metadata_alias('YSD_VD%YSF', 21, 3, 0, 1, 1)
    registry%aliases(157) = surface_metadata_alias('YSD_VD%YFZRA', 21, 4, 0, 1, 1)
    registry%aliases(158) = surface_metadata_alias('YSD_VD%YBLD', 21, 5, 0, 1, 1)
    registry%aliases(159) = surface_metadata_alias('YSD_VD%YSSHF', 21, 6, 0, 1, 1)
    registry%aliases(160) = surface_metadata_alias('YSD_VD%YSLHF', 21, 7, 0, 1, 1)
    registry%aliases(161) = surface_metadata_alias('YSD_VD%YNEE', 21, 8, 0, 1, 1)
    registry%aliases(162) = surface_metadata_alias('YSD_VD%YGPP', 21, 9, 0, 1, 1)
    registry%aliases(163) = surface_metadata_alias('YSD_VD%YREC', 21, 10, 0, 1, 1)
    registry%aliases(164) = surface_metadata_alias('YSD_VD%YMSL', 21, 11, 0, 1, 1)
    registry%aliases(165) = surface_metadata_alias('YSD_VD%YSP', 21, 12, 0, 1, 1)
    registry%aliases(166) = surface_metadata_alias('YSD_VD%YTCC', 21, 13, 0, 1, 1)
    registry%aliases(167) = surface_metadata_alias('YSD_VD%Y10U', 21, 115, 0, 1, 1)
    registry%aliases(168) = surface_metadata_alias('YSD_VD%Y10V', 21, 116, 0, 1, 1)
    registry%aliases(169) = surface_metadata_alias('YSD_VD%Y2T', 21, 117, 0, 1, 1)
    registry%aliases(170) = surface_metadata_alias('YSD_VD%Y2D', 21, 118, 0, 1, 1)
    registry%aliases(171) = surface_metadata_alias('YSD_VD%Y2SH', 21, 119, 0, 1, 1)
    registry%aliases(172) = surface_metadata_alias('YSD_VD%YSSR', 21, 14, 0, 1, 1)
    registry%aliases(173) = surface_metadata_alias('YSD_VD%YSTR', 21, 15, 0, 1, 1)
    registry%aliases(174) = surface_metadata_alias('YSD_VD%YTSR', 21, 16, 0, 1, 1)
    registry%aliases(175) = surface_metadata_alias('YSD_VD%YTTR', 21, 17, 0, 1, 1)
    registry%aliases(176) = surface_metadata_alias('YSD_VD%YEWSS', 21, 18, 0, 1, 1)
    registry%aliases(177) = surface_metadata_alias('YSD_VD%YNSSS', 21, 19, 0, 1, 1)
    registry%aliases(178) = surface_metadata_alias('YSD_VD%YE', 21, 20, 0, 1, 1)
    registry%aliases(179) = surface_metadata_alias('YSD_VD%YPEV', 21, 21, 0, 1, 1)
    registry%aliases(180) = surface_metadata_alias('YSD_VD%YCCC', 21, 22, 0, 1, 1)
    registry%aliases(181) = surface_metadata_alias('YSD_VD%YLCC', 21, 23, 0, 1, 1)
    registry%aliases(182) = surface_metadata_alias('YSD_VD%YMCC', 21, 24, 0, 1, 1)
    registry%aliases(183) = surface_metadata_alias('YSD_VD%YHCC', 21, 25, 0, 1, 1)
    registry%aliases(184) = surface_metadata_alias('YSD_VD%YLGWS', 21, 26, 0, 1, 1)
    registry%aliases(185) = surface_metadata_alias('YSD_VD%YMGWS', 21, 27, 0, 1, 1)
    registry%aliases(186) = surface_metadata_alias('YSD_VD%YGWD', 21, 28, 0, 1, 1)
    registry%aliases(187) = surface_metadata_alias('YSD_VD%YMX2T', 21, 29, 0, 1, 1)
    registry%aliases(188) = surface_metadata_alias('YSD_VD%YMN2T', 21, 30, 0, 1, 1)
    registry%aliases(189) = surface_metadata_alias('YSD_VD%YMXTPR', 21, 45, 0, 1, 1)
    registry%aliases(190) = surface_metadata_alias('YSD_VD%YMNTPR', 21, 46, 0, 1, 1)
    registry%aliases(191) = surface_metadata_alias('YSD_VD%YRO', 21, 31, 0, 1, 1)
    registry%aliases(192) = surface_metadata_alias('YSD_VD%YSRO', 21, 32, 0, 1, 1)
    registry%aliases(193) = surface_metadata_alias('YSD_VD%YSSRO', 21, 33, 0, 1, 1)
    registry%aliases(194) = surface_metadata_alias('YSD_VD%YALB', 21, 34, 0, 1, 1)
    registry%aliases(195) = surface_metadata_alias('YSD_VD%YIEWSS', 21, 35, 0, 1, 1)
    registry%aliases(196) = surface_metadata_alias('YSD_VD%YINSSS', 21, 36, 0, 1, 1)
    registry%aliases(197) = surface_metadata_alias('YSD_VD%YISSHF', 21, 37, 0, 1, 1)
    registry%aliases(198) = surface_metadata_alias('YSD_VD%YIE', 21, 38, 0, 1, 1)
    registry%aliases(199) = surface_metadata_alias('YSD_VD%YINEE', 21, 39, 0, 1, 1)
    registry%aliases(200) = surface_metadata_alias('YSD_VD%YIGPP', 21, 40, 0, 1, 1)
    registry%aliases(201) = surface_metadata_alias('YSD_VD%YIREC', 21, 41, 0, 1, 1)
    registry%aliases(202) = surface_metadata_alias('YSD_VD%YICH4', 21, 42, 0, 1, 1)
    registry%aliases(203) = surface_metadata_alias('YSD_VD%YCSF', 21, 43, 0, 1, 1)
    registry%aliases(204) = surface_metadata_alias('YSD_VD%YLSSF', 21, 44, 0, 1, 1)
    registry%aliases(205) = surface_metadata_alias('YSD_VD%YTPR', 21, 47, 0, 1, 1)
    registry%aliases(206) = surface_metadata_alias('YSD_VD%YLSRR', 21, 48, 0, 1, 1)
    registry%aliases(207) = surface_metadata_alias('YSD_VD%YCRR', 21, 49, 0, 1, 1)
    registry%aliases(208) = surface_metadata_alias('YSD_VD%YLSSFR', 21, 50, 0, 1, 1)
    registry%aliases(209) = surface_metadata_alias('YSD_VD%YCSFR', 21, 51, 0, 1, 1)
    registry%aliases(210) = surface_metadata_alias('YSD_VD%YPTYPE', 21, 52, 0, 1, 1)
    registry%aliases(211) = surface_metadata_alias('YSD_VD%YILSPF', 21, 53, 0, 1, 1)
    registry%aliases(212) = surface_metadata_alias('YSD_VD%YZ0F', 21, 54, 0, 1, 1)
    registry%aliases(213) = surface_metadata_alias('YSD_VD%YLZ0H', 21, 55, 0, 1, 1)
    registry%aliases(214) = surface_metadata_alias('YSD_VD%YVIWVE', 21, 56, 0, 1, 1)
    registry%aliases(215) = surface_metadata_alias('YSD_VD%YVIWVN', 21, 57, 0, 1, 1)
    registry%aliases(216) = surface_metadata_alias('YSD_VD%YTCW', 21, 58, 0, 1, 1)
    registry%aliases(217) = surface_metadata_alias('YSD_VD%YTCWV', 21, 59, 0, 1, 1)
    registry%aliases(218) = surface_metadata_alias('YSD_VD%YTCLW', 21, 60, 0, 1, 1)
    registry%aliases(219) = surface_metadata_alias('YSD_VD%YTCIW', 21, 61, 0, 1, 1)
    registry%aliases(220) = surface_metadata_alias('YSD_VD%YTCRW', 21, 62, 0, 1, 1)
    registry%aliases(221) = surface_metadata_alias('YSD_VD%YTCSW', 21, 63, 0, 1, 1)
    registry%aliases(222) = surface_metadata_alias('YSD_VD%YTCSLW', 21, 64, 0, 1, 1)
    registry%aliases(223) = surface_metadata_alias('YSD_VD%YSSRD', 21, 65, 0, 1, 1)
    registry%aliases(224) = surface_metadata_alias('YSD_VD%YSTRD', 21, 68, 0, 1, 1)
    registry%aliases(225) = surface_metadata_alias('YSD_VD%YSSRDC', 21, 66, 0, 1, 1)
    registry%aliases(226) = surface_metadata_alias('YSD_VD%YSTRDC', 21, 67, 0, 1, 1)
    registry%aliases(227) = surface_metadata_alias('YSD_VD%YBLH', 21, 69, 0, 1, 1)
    registry%aliases(228) = surface_metadata_alias('YSD_VD%YSUND', 21, 70, 0, 1, 1)
    registry%aliases(229) = surface_metadata_alias('YSD_VD%YSPAR', 21, 71, 0, 1, 1)
    registry%aliases(230) = surface_metadata_alias('YSD_VD%YSUVB', 21, 72, 0, 1, 1)
    registry%aliases(231) = surface_metadata_alias('YSD_VD%YCAPE', 21, 73, 0, 1, 1)
    registry%aliases(232) = surface_metadata_alias('YSD_VD%YMUCAPE', 21, 74, 0, 1, 1)
    registry%aliases(233) = surface_metadata_alias('YSD_VD%YMLCAPE50', 21, 75, 0, 1, 1)
    registry%aliases(234) = surface_metadata_alias('YSD_VD%YMLCAPE100', 21, 76, 0, 1, 1)
    registry%aliases(235) = surface_metadata_alias('YSD_VD%YPDEPL', 21, 77, 0, 1, 1)
    registry%aliases(236) = surface_metadata_alias('YSD_VD%YCAPES', 21, 78, 0, 1, 1)
    registry%aliases(237) = surface_metadata_alias('YSD_VD%YTROPOTP', 21, 79, 0, 1, 1)
    registry%aliases(238) = surface_metadata_alias('YSD_VD%YTSRC', 21, 80, 0, 1, 1)
    registry%aliases(239) = surface_metadata_alias('YSD_VD%YTTRC', 21, 81, 0, 1, 1)
    registry%aliases(240) = surface_metadata_alias('YSD_VD%YSSRC', 21, 82, 0, 1, 1)
    registry%aliases(241) = surface_metadata_alias('YSD_VD%YSTRC', 21, 83, 0, 1, 1)
    registry%aliases(242) = surface_metadata_alias('YSD_VD%YES', 21, 84, 0, 1, 1)
    registry%aliases(243) = surface_metadata_alias('YSD_VD%YSMLT', 21, 85, 0, 1, 1)
    registry%aliases(244) = surface_metadata_alias('YSD_VD%Y10FG', 21, 86, 0, 1, 1)
    registry%aliases(245) = surface_metadata_alias('YSD_VD%YI10FG', 21, 87, 0, 1, 1)
    registry%aliases(246) = surface_metadata_alias('YSD_VD%Y10FGCV', 21, 88, 0, 1, 1)
    registry%aliases(247) = surface_metadata_alias('YSD_VD%YLSPF', 21, 89, 0, 1, 1)
    registry%aliases(248) = surface_metadata_alias('YSD_VD%YTCO3', 21, 90, 0, 1, 1)
    registry%aliases(249) = surface_metadata_alias('YSD_VD%YVIMD', 21, 91, 0, 1, 1)
    registry%aliases(250) = surface_metadata_alias('YSD_VD%YSPARC', 21, 92, 0, 1, 1)
    registry%aliases(251) = surface_metadata_alias('YSD_VD%YSTINC', 21, 93, 0, 1, 1)
    registry%aliases(252) = surface_metadata_alias('YSD_VD%YSFDIR', 21, 94, 0, 1, 1)
    registry%aliases(253) = surface_metadata_alias('YSD_VD%YSCDIR', 21, 95, 0, 1, 1)
    registry%aliases(254) = surface_metadata_alias('YSD_VD%YSDSRP', 21, 96, 0, 1, 1)
    registry%aliases(255) = surface_metadata_alias('YSD_VD%YCBASE', 21, 97, 0, 1, 1)
    registry%aliases(256) = surface_metadata_alias('YSD_VD%Y0DEGL', 21, 98, 0, 1, 1)
    registry%aliases(257) = surface_metadata_alias('YSD_VD%YM10DEGL', 21, 99, 0, 1, 1)
    registry%aliases(258) = surface_metadata_alias('YSD_VD%YVISIH', 21, 100, 0, 1, 1)
    registry%aliases(259) = surface_metadata_alias('YSD_VD%YCIN', 21, 101, 0, 1, 1)
    registry%aliases(260) = surface_metadata_alias('YSD_VD%YMLCIN50', 21, 102, 0, 1, 1)
    registry%aliases(261) = surface_metadata_alias('YSD_VD%YMLCIN100', 21, 103, 0, 1, 1)
    registry%aliases(262) = surface_metadata_alias('YSD_VD%YKINDEX', 21, 104, 0, 1, 1)
    registry%aliases(263) = surface_metadata_alias('YSD_VD%YTTINDEX', 21, 105, 0, 1, 1)
    registry%aliases(264) = surface_metadata_alias('YSD_VD%YCBASEA', 21, 106, 0, 1, 1)
    registry%aliases(265) = surface_metadata_alias('YSD_VD%YCTOPC', 21, 107, 0, 1, 1)
    registry%aliases(266) = surface_metadata_alias('YSD_VD%YZTWETB0', 21, 108, 0, 1, 1)
    registry%aliases(267) = surface_metadata_alias('YSD_VD%YZTWETB1', 21, 109, 0, 1, 1)
    registry%aliases(268) = surface_metadata_alias('YSD_VD%Y100U', 21, 110, 0, 1, 1)
    registry%aliases(269) = surface_metadata_alias('YSD_VD%Y100V', 21, 111, 0, 1, 1)
    registry%aliases(270) = surface_metadata_alias('YSD_VD%Y200U', 21, 112, 0, 1, 1)
    registry%aliases(271) = surface_metadata_alias('YSD_VD%Y200V', 21, 113, 0, 1, 1)
    registry%aliases(272) = surface_metadata_alias('YSD_VD%YZUST', 21, 114, 0, 1, 1)
    registry%aliases(273) = surface_metadata_alias('YSD_VD%Y10NU', 21, 120, 0, 1, 1)
    registry%aliases(274) = surface_metadata_alias('YSD_VD%Y10NV', 21, 121, 0, 1, 1)
    registry%aliases(275) = surface_metadata_alias('YSD_VD%YDNDZN', 21, 122, 0, 1, 1)
    registry%aliases(276) = surface_metadata_alias('YSD_VD%YDNDZA', 21, 123, 0, 1, 1)
    registry%aliases(277) = surface_metadata_alias('YSD_VD%YDCTB', 21, 124, 0, 1, 1)
    registry%aliases(278) = surface_metadata_alias('YSD_VD%YTPLB', 21, 125, 0, 1, 1)
    registry%aliases(279) = surface_metadata_alias('YSD_VD%YTPLT', 21, 126, 0, 1, 1)
    registry%aliases(280) = surface_metadata_alias('YSD_VD%YLITOTI', 21, 127, 0, 1, 1)
    registry%aliases(281) = surface_metadata_alias('YSD_VD%YLICGI', 21, 128, 0, 1, 1)
    registry%aliases(282) = surface_metadata_alias('YSD_VD%YODSS', 21, 129, 0, 1, 1)
    registry%aliases(283) = surface_metadata_alias('YSD_VD%YODDU', 21, 130, 0, 1, 1)
    registry%aliases(284) = surface_metadata_alias('YSD_VD%YODOM', 21, 131, 0, 1, 1)
    registry%aliases(285) = surface_metadata_alias('YSD_VD%YODBC', 21, 132, 0, 1, 1)
    registry%aliases(286) = surface_metadata_alias('YSD_VD%YODSU', 21, 133, 0, 1, 1)
    registry%aliases(287) = surface_metadata_alias('YSD_VD%YODNI', 21, 134, 0, 1, 1)
    registry%aliases(288) = surface_metadata_alias('YSD_VD%YODSOA', 21, 136, 0, 1, 1)
    registry%aliases(289) = surface_metadata_alias('YSD_VD%YODAM', 21, 135, 0, 1, 1)
    registry%aliases(290) = surface_metadata_alias('YSD_VD%YODVFA', 21, 137, 0, 1, 1)
    registry%aliases(291) = surface_metadata_alias('YSD_VD%YODVSU', 21, 138, 0, 1, 1)
    registry%aliases(292) = surface_metadata_alias('YSD_VD%YODTOACC', 21, 139, 0, 1, 1)
    registry%aliases(293) = surface_metadata_alias('YSD_VD%YAEPM1', 21, 140, 0, 1, 1)
    registry%aliases(294) = surface_metadata_alias('YSD_VD%YAEPM25', 21, 141, 0, 1, 1)
    registry%aliases(295) = surface_metadata_alias('YSD_VD%YAEPM10', 21, 142, 0, 1, 1)
    registry%aliases(296) = surface_metadata_alias('YSD_VD%YUVBED', 21, 143, 0, 1, 1)
    registry%aliases(297) = surface_metadata_alias('YSD_VD%YUVBEDCS', 21, 144, 0, 1, 1)
    registry%aliases(298) = surface_metadata_alias('YSD_VD%YSDSL', 21, 145, 0, 1, 1)
    registry%aliases(299) = surface_metadata_alias('YSD_VD%YAERO_WVL_DIAG', 21, 146, 2, 1, 1)
    registry%aliases(300) = surface_metadata_alias('YSD_VD%YMX2T6', 21, 147, 1, 6, 1)
    registry%aliases(301) = surface_metadata_alias('YSD_VD%YMN2T6', 21, 153, 1, 6, 1)
    registry%aliases(302) = surface_metadata_alias('YSD_VD%Y10FG6', 21, 159, 1, 6, 1)
    registry%aliases(303) = surface_metadata_alias('YSD_VD%YMXTPR6', 21, 165, 1, 6, 1)
    registry%aliases(304) = surface_metadata_alias('YSD_VD%YMNTPR6', 21, 171, 1, 6, 1)
    registry%aliases(305) = surface_metadata_alias('YSD_VD%YMXCAP6', 21, 177, 1, 6, 1)
    registry%aliases(306) = surface_metadata_alias('YSD_VD%YMXCAPS6', 21, 183, 1, 6, 1)
    registry%aliases(307) = surface_metadata_alias('YSD_VD%YLITOTA6', 21, 189, 1, 6, 1)
    registry%aliases(308) = surface_metadata_alias('YSD_VD%YLICGA6', 21, 195, 1, 6, 1)
    registry%aliases(309) = surface_metadata_alias('YSD_VD%YPTYPEOCC6', 21, 201, 2, 6, 12)
    registry%aliases(310) = surface_metadata_alias('YSD_SM%YCLBT', 22, 694, 0, 1, 1)
    registry%aliases(311) = surface_metadata_alias('YSD_SM%YCSBT', 22, 694, 0, 1, 1)
    registry%aliases(312) = surface_metadata_alias('YSD_WS%YCHAR', 23, 1, 0, 1, 1)
    registry%aliases(313) = surface_metadata_alias('YSD_WS%YCHARHQ', 23, 694, 0, 1, 1)
    registry%aliases(314) = surface_metadata_alias('YSD_WS%YUSTOKES', 23, 694, 0, 1, 1)
    if (operational) registry%aliases(314)%first_field = 2
    registry%aliases(315) = surface_metadata_alias('YSD_WS%YVSTOKES', 23, 694, 0, 1, 1)
    if (operational) registry%aliases(315)%first_field = 3
    registry%aliases(316) = surface_metadata_alias('YSD_WS%YTAUOCX', 23, 694, 0, 1, 1)
    registry%aliases(317) = surface_metadata_alias('YSD_WS%YTAUOCY', 23, 694, 0, 1, 1)
    registry%aliases(318) = surface_metadata_alias('YSD_WS%YPHIOC', 23, 694, 0, 1, 1)
    registry%aliases(319) = surface_metadata_alias('YSD_WS%YWSEMEAN', 23, 694, 0, 1, 1)
    registry%aliases(320) = surface_metadata_alias('YSD_WS%YWSFMEAN', 23, 694, 0, 1, 1)
    registry%aliases(321) = surface_metadata_alias('YSD_WW%YU10N', 24, 1, 0, 1, 1)
    registry%aliases(322) = surface_metadata_alias('YSD_WW%YV10N', 24, 2, 0, 1, 1)
    registry%aliases(323) = surface_metadata_alias('YSD_WW%YRHO', 24, 3, 0, 1, 1)
    registry%aliases(324) = surface_metadata_alias('YSD_WW%YZIL', 24, 4, 0, 1, 1)
    registry%aliases(325) = surface_metadata_alias('YSD_WW%YCIF', 24, 5, 0, 1, 1)
    registry%aliases(326) = surface_metadata_alias('YSD_WW%YCLK', 24, 6, 0, 1, 1)
    registry%aliases(327) = surface_metadata_alias('YSD_WW%YUCURW', 24, 694, 0, 1, 1)
    registry%aliases(328) = surface_metadata_alias('YSD_WW%YVCURW', 24, 694, 0, 1, 1)
    registry%aliases(329) = surface_metadata_alias('YSD_VX%YORO', 25, 694, 0, 1, 1)
    registry%aliases(330) = surface_metadata_alias('YSD_VX%YTSC', 25, 694, 0, 1, 1)
    registry%aliases(331) = surface_metadata_alias('YSD_VX%YPWS', 25, 694, 0, 1, 1)
    registry%aliases(332) = surface_metadata_alias('YSD_VX%YPWP', 25, 694, 0, 1, 1)
    registry%aliases(333) = surface_metadata_alias('YSD_VX%YSNO', 25, 694, 0, 1, 1)
    registry%aliases(334) = surface_metadata_alias('YSD_VX%YTPC', 25, 694, 0, 1, 1)
    registry%aliases(335) = surface_metadata_alias('YSD_VX%YSAB', 25, 694, 0, 1, 1)
    registry%aliases(336) = surface_metadata_alias('YSD_VX%YXD2', 25, 694, 0, 1, 1)
    registry%aliases(337) = surface_metadata_alias('YSD_VX%YLSM', 25, 694, 0, 1, 1)
    registry%aliases(338) = surface_metadata_alias('YSD_VX%YIVEG', 25, 694, 0, 1, 1)
    registry%aliases(339) = surface_metadata_alias('YSD_VX%YARG', 25, 694, 0, 1, 1)
    registry%aliases(340) = surface_metadata_alias('YSD_VX%YRSMIN', 25, 694, 0, 1, 1)
    registry%aliases(341) = surface_metadata_alias('YSD_VX%YLAI', 25, 694, 0, 1, 1)
    registry%aliases(342) = surface_metadata_alias('YSD_VX%YVEG', 25, 694, 0, 1, 1)
  end subroutine
  logical function floating_environment_ready() result(ready)
    !! Use the supported public inquiry,or the already-qualified exact
    !! tiny*0.5 probe when GNU does not expose underflow control.
    type(ieee_round_type) :: rounding
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    logical :: gradual
    ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    ready = .true.
  end function
end module
