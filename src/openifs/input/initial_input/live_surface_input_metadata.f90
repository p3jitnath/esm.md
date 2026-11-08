module forecast_live_surface_input_metadata
  !! Named native projections for the five original surface metadata/default
  !! source files. All physical arrays and parameter tables stay caller-owned.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use surface_input_configuration_port, only: surface_input_configuration
  use surface_field_storage_port, only: surface_field_state
  use partitioned_surface_field_placement_port, only: surface_input_owners
  use surface_default_assignment_port, only: surface_default_owner, surface_default_assignment, &
               source_set_initial_surface_defaults => set_initial_surface_defaults, set_runtime_partitioned_initial_surface_defaults
  use surface_default_metadata_port, only: surface_default_group_view, surface_default_plan_summary, &
                                           collect_surface_default_metadata, collect_runtime_partitioned_surface_defaults
  implicit none
  private
  public :: live_surface_conversion_values, selected_surface_owner_context, surface_startup_context
  public :: project_live_surface_configuration, project_selected_surface_owners, project_surface_startup_context
  public :: collect_selected_surface_defaults, collect_operational_surface_defaults
  public :: set_initial_surface_defaults, set_operational_initial_surface_defaults
  type :: live_surface_conversion_values
    !! Source scalar controls use0/1. Temperatures are K,gravity m/s**2 and
    !! density kg/m**3. cover/leaf tables are dimensionless borrowed targets.
    integer(int64) :: points = 0, maximum_vegetation = 0
    integer(int32) :: ecmwf = 0, currents = 0, ocean_coupling = 0, ocean_wave = 0, wave_coupling = 0
    real(real64) :: gravity = 0, freezing_temperature = 0, water_density = 0, water_capacity = 0, ice_minimum = 0
    real(real64), pointer, contiguous :: cover(:) => null(), leaf_area(:) => null()
    logical :: surface_parameters_ready = .false.
  end type
  type :: selected_surface_owner_context
    integer(int32) :: invalid = 1, pitch = 0, points = 0, snow_layers = 0, nconf = 0, lifstraj = 0, l_oops = 0, allocation_flag = 0
    type(surface_input_owners) :: owners
  end type
  type :: surface_startup_context
    integer(int32) :: invalid = 1
    logical :: ready = .false.
  end type
contains
  integer(int32) function project_live_surface_configuration(live, output) result(status)
    !! Port surface_conversion_configuration.S. Clear first and preserve the
    !! source's partially filled metadata on refusal. No physical value is
    !! calculated here: each value comes from its real initialized producer.
    type(live_surface_conversion_values), intent(in) :: live
    type(surface_input_configuration), intent(out) :: output
    integer :: j
    output = surface_input_configuration()
    output%invalid = 1
    status = 1
    if (.not. live%surface_parameters_ready) return
    output%points = live%points; output%maximum_vegetation = live%maximum_vegetation
    output%ecmwf = live%ecmwf /= 0; output%currents = live%currents /= 0
    output%ocean_coupling = live%ocean_coupling /= 0; output%ocean_wave = live%ocean_wave /= 0
    output%wave_coupling = live%wave_coupling /= 0
    output%gravity = live%gravity; output%freezing_temperature = live%freezing_temperature
    output%water_density = live%water_density; output%water_capacity = live%water_capacity; output%ice_minimum = live%ice_minimum
    output%revision = 1
    if (live%maximum_vegetation < 0 .or. live%maximum_vegetation > 127) return
    if (.not. associated(live%cover) .or. .not. associated(live%leaf_area)) return
    output%cover_lower = lbound(live%cover, 1); output%cover_upper = ubound(live%cover, 1)
    output%leaf_lower = lbound(live%leaf_area, 1); output%leaf_upper = ubound(live%leaf_area, 1)
    if (output%cover_lower > 0 .or. output%leaf_lower > 0) return
    if (output%cover_upper < live%maximum_vegetation .or. output%leaf_upper < live%maximum_vegetation) return
    do j = 0, int(live%maximum_vegetation)
      output%cover(j) = live%cover(j)
      output%leaf_area(j) = live%leaf_area(j)
    end do
    output%invalid = 0; status = 0
  end function

  integer(int32) function project_selected_surface_owners(pitch,points,snow_layers,nconf,lifstraj,l_oops,allocation_flag,state,output) result(status)
    !! Port surface_owner_metadata.S. Publish five complete borrowed views only
    !! after every source owner shape passes. state remains a stable TARGET.
    integer(int32), intent(in) :: pitch, points, snow_layers, nconf, lifstraj, l_oops, allocation_flag
    type(surface_field_state), target, intent(inout) :: state
    type(selected_surface_owner_context), intent(out) :: output
    output = selected_surface_owner_context()
    output%pitch = pitch; output%points = points; output%snow_layers = snow_layers
    output%nconf = nconf; output%lifstraj = lifstraj; output%l_oops = l_oops; output%allocation_flag = allocation_flag
    status = 1
    if (pitch /= 24 .or. points /= 2048 .or. snow_layers /= 5) return
    if (.not. allocated(state%sp_sb) .or. .not. allocated(state%sp_sl) .or. .not. allocated(state%sp_sg)) return
    if (.not. allocated(state%sp_rr) .or. .not. allocated(state%sd_vf)) return
    if (any(shape(state%sp_sb) /= [24, 4, 6, 86])) return
    if (any(shape(state%sp_sl) /= [24, 14, 86])) return
    if (any(shape(state%sp_sg) /= [24, 5, 10, 86])) return
    if (any(shape(state%sp_rr) /= [24, 4, 86])) return
    if (any(shape(state%sd_vf) /= [24, 38, 86])) return
    output%owners%sp_sb(1:24, 1:24, 1:86) => state%sp_sb
    output%owners%sp_sl => state%sp_sl
    output%owners%sp_ssn(1:24, 1:50, 1:86) => state%sp_sg
    output%owners%sp_rr => state%sp_rr
    output%owners%sd_vf => state%sd_vf
    output%invalid = 0; status = 0
  end function

  integer(int32) function project_surface_startup_context(ngribfile,n3dini,laqua,pitch,blocks,points,sd_vx_fields,output) result(status)
    !! Port surface_startup_context.S. The three old model-address projections
    !! become explicit named arguments of the native SUGRIDF/SUGRIDG callers;
    !! no byte address or original module is retained by this context.
    integer(int32), intent(in) :: ngribfile, n3dini, laqua, pitch, blocks, points, sd_vx_fields
    type(surface_startup_context), intent(out) :: output
    output = surface_startup_context(); status = 1
    if (ngribfile /= 1 .or. n3dini /= 0 .or. laqua /= 0) return
    if (pitch /= 24 .or. blocks /= 86 .or. points /= 2048 .or. sd_vx_fields /= 0) return
    output%invalid = 0; output%ready = .true.; status = 0
  end function

  subroutine collect_selected_surface_defaults(groups, owners, assignments, summary)
    !! First entry of surface_default_metadata.S;33readonly source groups,
    !!64borrowed owner slots,4096assignment slots and one named summary.
    type(surface_default_group_view), intent(in) :: groups(:)
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(inout) :: assignments(:)
    type(surface_default_plan_summary), intent(inout) :: summary
    call collect_surface_default_metadata(groups, owners, assignments, summary)
  end subroutine

  subroutine collect_operational_surface_defaults(groups, owners, assignments, summary)
    !! The second entry uses the source17rows and388217blocks. The accepted
    !! metadata traversal owns all field/layer order and raw default values.
    type(surface_default_group_view), intent(in) :: groups(:)
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(inout) :: assignments(:)
    type(surface_default_plan_summary), intent(inout) :: summary
    call collect_runtime_partitioned_surface_defaults(groups, 17_int32, 388217_int32, owners, assignments, summary)
  end subroutine

  integer(int32) function set_initial_surface_defaults(owners, assignments) result(status)
    !! Selected entry of initial_surface_default_assignment.S. Copy every
    !! complete allocated plane, including padding; preserve all raw FP64 bits.
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(in) :: assignments(:)
    status = source_set_initial_surface_defaults(owners, assignments)
  end function

  integer(int32) function set_operational_initial_surface_defaults(owners, assignments) result(status)
    !! Operational whole-grid entry; the private reset word has no owner or
    !! observable counterpart in this source interface.
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(in) :: assignments(:)
    integer(int32) :: reset
    reset = 0
    status = set_runtime_partitioned_initial_surface_defaults(owners, assignments, 17_int32, 388217_int32, reset)
  end function
end module forecast_live_surface_input_metadata
