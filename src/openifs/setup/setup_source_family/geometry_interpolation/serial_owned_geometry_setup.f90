!> Own distributed native grid setup while borrowing the completed vertical state.
!! Original md2asm_complete_owned_distributed_geometry is traced to
!! src/openifs/setup/owned_distributed_geometry_system.S.
module forecast_serial_geometry_setup
  use iso_c_binding, only: c_int, c_int8_t, c_int64_t, c_double, c_ptr, c_f_pointer, c_loc, c_sizeof, c_null_char
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use initial_model_file_headers_port, only: initial_model_header_metadata
  use runtime_initial_upper_air_reader_port, only: runtime_initial_grid_metadata
  use forecast_vertical_coordinate_storage, only: native_vertical_state
  use forecast_grid_dimensions, only: native_grid_dimensions, grid_dimension_setup_values, initialize_grid_dimensions
  use forecast_geometry_configuration_text, only: read_grid_dimension_overrides
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use forecast_spherical_grid_configuration, only: native_spherical_grid_configuration, &
                                 initialize_regular_spherical_grid_configuration, initialize_reduced_spherical_grid_configuration, &
                                                   release_spherical_grid_configuration
  use forecast_global_grid_cutoffs, only: release_global_grid_cutoffs
  use forecast_public_transform, only: native_transform_control, native_transform_resolution, &
                       initialize_public_transform_messages, release_transform_environment_metadata, finish_public_transform_context
  use forecast_distributed_partition, only: create_owned_distributed_geometry_partition, &
                                            release_distributed_partition_arrays, &
                                            release_owned_distributed_transform_partition
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  use forecast_geometry_horizontal_stages, only: initialize_geometry_horizontal_stages, &
                                                 release_geometry_horizontal_owners
  use forecast_geometry_stream, only: release_stream_geometry_values, release_stream_geometry_metadata
  use forecast_latitude_geometry, only: release_latitude_geometry
  use forecast_laplacian_geometry, only: release_laplacian_geometry
  use forecast_standard_atmosphere_setup, only: release_standard_atmosphere
  use forecast_spherical_grid_setup, only: release_spherical_grid
  use forecast_spectral_geometry_maps, only: release_spectral_geometry_maps
  use forecast_spherical_geometry_setup, only: release_spherical_geometry
  use forecast_orography_storage, only: release_orography_storage
  use forecast_serial_partition, only: create_owned_serial_geometry_partition
  use forecast_geometry_setup, only: release_native_geometry
  implicit none
  private
  public :: complete_owned_geometry, complete_owned_operational_geometry
  public :: release_owned_geometry, release_owned_operational_geometry
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Establish an own C-interoperable record through its complete declared size.
  subroutine zero_native_record(address, count)
    type(c_ptr), intent(in) :: address
    integer(c_int64_t), intent(in) :: count
    integer(c_int8_t), pointer :: bytes(:)
    call c_f_pointer(address, bytes, [int(count)])
    bytes = 0_c_int8_t
  end subroutine

  !> Establish the fresh source-zero stream namespace through named members.
  !! This native owner has allocatable arrays, so whole-record byte stores are
  !! inappropriate. No incoming direct-child namespace is changed here.
  subroutine zero_fresh_stream_scalars(state)
    type(native_geometry_state), intent(inout) :: state
    state%stream%nundef = 0
    state%stream%nulerr = 0
    state%stream%nulout = 0
    state%stream%myproc = 0
    state%stream%nproc = 0
    state%stream%imaxgrid = 0_c_int64_t
    state%stream%imaxspec2g = 0_c_int64_t
    state%stream%rpi = 0.0_c_double
    state%stream%sipr = 0.0_c_double
    state%stream%nrealen = 0
    state%stream%nintlen = 0
    state%stream%nbsetsp = 0
    state%stream%nflevg = 0
    state%stream%nsmax = 0
    state%stream%ndglg = 0
    state%stream%nfprgpl = 0
    state%stream%nfprgpg = 0
    state%stream%nfprgplx = 0
    state%stream%lifs_internal = .false.
  end subroutine

  !> Admit the exact regularT21/L19 or reducedT1279/L137 serial route.
  !! Actual header J/K/M, grids and vertical metadata are independent named
  !! producer outputs. Unused values are not inferred from a resolution name.
  integer(c_int) function admit_serial_geometry(vertical, headers, constants, text, operational, grid) result(status)
    type(native_vertical_state), intent(in) :: vertical
    type(initial_model_header_metadata), intent(in) :: headers
    type(runtime_initial_grid_metadata), optional, intent(in) :: grid
    type(forecast_physical_constants), intent(in) :: constants
    character(*), intent(in) :: text
    logical, intent(in) :: operational
    status = 2
    if (len(text) < 1 .or. len(text) > 262144 .or. index(text, c_null_char) /= 0) return
    if (.not. headers%ready .or. .not. vertical%constructor_ready) return
    if (.not. vertical%eta_bounds_ready .or. .not. allocated(vertical%rderb)) return
    if (constants%initialized /= 1) return
    if (headers%spectral%levels /= vertical%levels) return
    if (headers%nusmax /= headers%spectral%truncation_j .or. headers%nucmax /= headers%spectral%truncation_j) return
    if (headers%spectral%truncation_j /= headers%spectral%truncation_k) return
    if (headers%spectral%truncation_j /= headers%spectral%truncation_m) return
    if (headers%nsupersede /= 1 .or. headers%nusttyp /= 1) return
    if (operational) then
      if (.not. present(grid)) return
      if (grid%levels /= vertical%levels) return
      if (headers%nudgl /= grid%row_count .or. headers%nudlon /= grid%maximum_longitudes) return
      if (vertical%levels /= 137 .or. headers%nusmax /= 1279 .or. headers%nudgl /= 2560) return
      if (headers%nudlon /= 5136 .or. headers%nuhtyp /= 2) return
    else
      if (vertical%levels /= 19 .or. headers%nusmax /= 21 .or. headers%nudgl /= 32 .or. headers%nudlon /= 64) return
    end if
    status = 0
  end function
  !> Complete one source serial constructor at the final native owner address.
  !! OUTPUT is fresh ALLOCATABLE TARGET. VERTICAL remains the caller's stable
  !! live TARGET and is borrowed without copying its owners. All horizontal,
  !! atmosphere, stream and transform owners are created by actual children.
  !! Publish only after success; any child failure cleans just new ownership.
  integer(c_int)function complete_owned_geometry(output,vertical,headers,constants,text,child_status,failed_stage)result(status)
  type(native_geometry_state), allocatable, target, intent(inout) :: output
  type(native_vertical_state), target, intent(inout) :: vertical
  type(initial_model_header_metadata), intent(in) :: headers
  type(forecast_physical_constants), intent(in) :: constants
  character(*), intent(in) :: text
  integer(c_int), intent(out) :: child_status
  integer(c_int), optional, intent(out) :: failed_stage
  integer(c_int) :: stage
  status = initialize_serial_geometry(.false., output, vertical, headers, constants, text, child_status, stage)
  if (present(failed_stage)) failed_stage = stage
  end function
  !> Complete one source serial constructor at the final native owner address.
  !! OUTPUT is fresh ALLOCATABLE TARGET. VERTICAL remains the caller's stable
  !! live TARGET and is borrowed without copying its owners. All horizontal,
  !! atmosphere, stream and transform owners are created by actual children.
  !! Publish only after success; any child failure cleans just new ownership.
  integer(c_int)function complete_owned_operational_geometry(output,vertical,headers,grid,constants,text,child_status,failed_stage)result(status)
  type(native_geometry_state), allocatable, target, intent(inout) :: output
  type(native_vertical_state), target, intent(inout) :: vertical
  type(initial_model_header_metadata), intent(in) :: headers
  type(runtime_initial_grid_metadata), intent(in) :: grid
  type(forecast_physical_constants), intent(in) :: constants
  character(*), intent(in) :: text
  integer(c_int), intent(out) :: child_status
  integer(c_int), optional, intent(out) :: failed_stage
  integer(c_int) :: stage
  status = initialize_serial_geometry(.true., output, vertical, headers, constants, text, child_status, stage, grid)
  if (present(failed_stage)) failed_stage = stage
end function
  integer(c_int) function initialize_serial_geometry(operational,output,vertical,headers,constants,text,child_status,failed_stage,grid) result(status)
  type(native_geometry_state), allocatable, target, intent(inout) :: output
  type(native_vertical_state), target, intent(inout) :: vertical
  type(initial_model_header_metadata), intent(in) :: headers
  type(runtime_initial_grid_metadata), optional, intent(in) :: grid
  type(forecast_physical_constants), intent(in) :: constants
  character(*), intent(in) :: text
  logical, intent(in) :: operational
  integer(c_int), intent(out) :: child_status
  integer(c_int), optional, intent(out) :: failed_stage
  type(native_geometry_state), allocatable, target :: pending
  type(native_grid_dimensions) :: dimensions
  type(native_spherical_grid_configuration), target :: configuration
  type(grid_dimension_setup_values) :: settings
  type(native_transform_control) :: early_control
  type(native_transform_resolution) :: no_resolution
  integer(c_int) :: overrides(12), presence, child, stage, ignored, error
  integer :: allocation_status
  logical :: selected
  real(c_double) :: coordinates(3)
  type(ieee_status_type) :: reached
  integer(c_int), pointer, volatile :: error_number
  integer(c_int) :: reached_errno
  stage = 1
  child_status = 2
  status = 2
  if (present(failed_stage)) failed_stage = stage
  if (allocated(output)) return
  selected = .not. operational
  child_status = admit_serial_geometry(vertical, headers, constants, text, operational, grid)
  if (child_status /= 0) goto900
  stage = 2
  child = require_empty_physics_group(text, 'NAMSTA')
  child_status = child
  if (child_status /= 0) goto900
  stage = 3
  child = require_empty_physics_group(text, 'NAM_ATLAS_IFS')
  child_status = child
  if (child_status /= 0) goto900
  stage = 4
  child = read_grid_dimension_overrides(text, overrides, presence)
  child_status = child
  if (child_status /= 0) goto900
  settings = grid_dimension_setup_values(1_c_int, 0_c_int, 1_c_int, merge(0_c_int, 1_c_int, selected), &
                           0_c_int, 1_c_int, headers%nusmax, headers%nudgl, headers%nudlon, headers%nucmax, headers%spectral%levels)
  child = initialize_grid_dimensions(dimensions, settings, overrides, presence)
  child_status = child
  if (child_status /= 0) goto900
  stage = 5
  call zero_native_record(c_loc(configuration%values), int(c_sizeof(configuration%values), c_int64_t))
  coordinates = [headers%umucen, headers%ulocen, headers%ustret]
  if (selected) then
    child = initialize_regular_spherical_grid_configuration(configuration, dimensions, &
                                                            headers%nsupersede, headers%nusttyp, coordinates, text)
  else
    child = initialize_reduced_spherical_grid_configuration(configuration, dimensions, grid, coordinates, text)
  end if
  child_status = child
  if (child_status /= 0) goto900
  stage = 6
  allocate (pending, stat=allocation_status)
  child = 0
  if (allocation_status /= 0) child = 1
  child_status = child
  if (child_status /= 0) goto900
  call zero_fresh_stream_scalars(pending)
  pending%dimensions = dimensions
  call zero_native_record(c_loc(pending%configuration%values), &
                          int(c_sizeof(pending%configuration%values), c_int64_t))
  pending%configuration%values = configuration%values
  call move_alloc(configuration%nloen, pending%configuration%nloen)
  call move_alloc(configuration%nloeng, pending%configuration%nloeng)
  pending%transform_control%ra = constants%ra
  pending%vertical => vertical
  pending%escgmap = 0.0_c_double
  call zero_native_record(c_loc(pending%grid%constants), int(c_sizeof(pending%grid%constants), c_int64_t))
  call zero_native_record(c_loc(pending%atmosphere%reference_tables), &
                          int(c_sizeof(pending%atmosphere%reference_tables), c_int64_t))
  stage = 7
  child_status = create_owned_serial_geometry_partition(pending%partition, pending%dimensions, &
                                         pending%stream, pending%transform_control, pending%transform_resolution, pending%cutoffs, &
                                                     constants, text, pending%configuration%nloeng(1:dimensions%ndglg), operational)
  if (child_status /= 0) goto900
  status = initialize_geometry_horizontal_stages(pending, constants, selected, child_status, stage)
  if (status /= 0) goto900
  pending%initialized = .true.
  call move_alloc(pending, output)
  child_status = 0
  if (present(failed_stage)) failed_stage = 0
  status = 0
  return
900 continue
  status = child_status
  if (present(failed_stage)) failed_stage = stage
  call ieee_get_status(reached)
  call c_f_pointer(errno_address(), error_number)
  reached_errno = error_number
  if (allocated(pending)) ignored = release_native_geometry(pending)
  call release_spherical_grid_configuration(configuration)
  if (early_control%message_ready) ignored = finish_public_transform_context(early_control, no_resolution, error)
  call ieee_set_status(reached)
  error_number = reached_errno
end function

!> Release every new owner in the complete source serial order. The actual
  !! canonical lower release preserves IEEE status/errno and borrowed vertical.
  !! Empty repeated release succeeds; no public message lifetime is duplicated.
integer(c_int) function release_owned_geometry(output) result(status)
  type(native_geometry_state), allocatable, intent(inout) :: output
  status = release_native_geometry(output)
end function
integer(c_int) function release_owned_operational_geometry(output) result(status)
  type(native_geometry_state), allocatable, intent(inout) :: output
  status = release_native_geometry(output)
end function
end module forecast_serial_geometry_setup
