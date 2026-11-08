!> Initialize one already allocated canonical model at its final address.
!! The owning storage constructor establishes declaration defaults and calls the
!! three named fresh-state producers exactly once before binding its aliases.
!! INITIAL supplies the unique completed constants, clock, controls and geometry.
!! Stages4:17 use the unchanged frozen source body and actual native providers.
!! The caller retains the carrier and all aliases on success and child failure.
module forecast_in_place_model_configuration
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  use forecast_distributed_partition_types, only: native_distributed_partition
  use dynamical_configuration_port, only: initialize_operational_dynamical_configuration
  use forecast_operational_dynamics, only: native_dynamics_upstream, initialize_operational_dynamics_controls
  use forecast_operational_time_integration, only: native_time_integration_upstream, &
                                                   initialize_operational_time_integration_configuration
  use forecast_operational_physics_configuration, only: initialize_operational_physics_configuration
  use native_inactive_startup_controls, only: initialize_operational_inactive_startup_controls
  use physics_field_dimensions_port, only: selected_field_dimension_controls, &
                                           initialize_physics_field_dimensions, initialize_spectral_field_dimensions
  use grid_field_configuration_port, only: initialize_operational_grid_field_configuration
  use forecast_grid_motion_setup, only: initialize_grid_motion_index_maps
  use forecast_semi_lagrangian_buffer_types, only: native_interpolation_platform
  use forecast_model_interpolation_setup, only: initialize_interpolation_record_defaults, &
                                          initialize_operational_interpolation_controls, initialize_selected_sl_velocity_controls, &
                                                initialize_selected_sl_buffer_maps, release_selected_sl_buffer_maps
  use md2asm_internal_interpolation_plane_maps, only: interpolation_plane_controls, &
                                                      initialize_internal_interpolation_plane_maps
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_operational_model_configuration, initialize_operational_model_configuration_in_place
  public :: release_operational_model_configuration_contents
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32)function initialize_operational_model_configuration_in_place(output,initial,child_status,failed_stage)result(status)
  type(native_operational_model_configuration), target, intent(inout) :: output
  type(native_initial_geometry_state), target, intent(inout) :: initial
  integer(int32), intent(out) :: child_status, failed_stage
  type(native_operational_model_configuration), pointer :: pending
  type(native_dynamics_upstream) :: dynamics_upstream
  type(native_time_integration_upstream) :: time_upstream
  type(selected_field_dimension_controls) :: dimension_controls
  type(native_interpolation_platform) :: platform
  type(interpolation_plane_controls) :: plane_controls
  integer(c_int), pointer, volatile :: error_number
  integer(int32) :: stage, child, physics_controls(2), field_controls(9)
  character(len=12) :: selectors(2163)
  integer :: n, j
  status = 2
  child_status = 0
  failed_stage = 0
  ! Caller owns the final record and has run the three named fresh producers once.
  ! Declaration defaults and absent dependent owners remain required entry state.
  if (output%ready) return
  if (.not. associated(output%initial, initial)) return
  if (associated(output%partition)) return
  if (output%nsupersede /= 1) return
  if (.not. dependencies_released(output)) return
  if (allocated(output%buffers%first%rparsl1)) return
  if (allocated(output%buffers%refined%rparsl15)) return
  if (.not. initial%ready) return
  if (.not. allocated(initial%prefix)) return
  if (.not. allocated(initial%geometry)) return
  if (.not. initial%prefix%ready .or. .not. initial%geometry%initialized) return
  if (.not. allocated(initial%prefix%vertical)) return
  if (.not. associated(initial%geometry%vertical)) return
  if (.not. associated(initial%geometry%vertical, initial%prefix%vertical)) return
  n = initial%prefix%configuration_bytes
  if (n < 1 .or. n > 262144) return
  if (initial%constants%initialized /= 1) return
  if (initial%geometry%dimensions%nflevg /= 137) return
  if (initial%prefix%vertical%levels /= 137) return
  if (initial%geometry%dimensions%nsmax < 1 .or. initial%geometry%dimensions%nsmax > 4096) return
  if (initial%geometry%dimensions%nmsmax /= initial%geometry%dimensions%nsmax) return
  if (initial%geometry%dimensions%ndglg < 2 .or. initial%geometry%dimensions%ndglg > 8192) return
  if (initial%geometry%dimensions%ndlon < 1 .or. initial%geometry%dimensions%ndlon > 32768) return
  if (initial%controls%namespace%nconf /= 1 .or. initial%controls%namespace%lecmwf /= 1) return
  if (initial%controls%namespace%l4dvar /= 0) return
  if (initial%controls%clock%total_steps < 1 .or. initial%controls%clock%total_steps > 576) return
  call c_f_pointer(errno_address(), error_number)
  pending => output
  stage = 0
  ! Stages1:3 are the already-completed unique constants, clock and initial controls.
  associate (text => initial%prefix%configuration_text(1:n))
    stage = 4
    child = initialize_operational_dynamical_configuration(text, pending%dynamical_core)
    if (child /= 0) goto900
    stage = 5
    dynamics_upstream%ndlon = initial%geometry%dimensions%ndlon
    dynamics_upstream%ndglg = initial%geometry%dimensions%ndglg
    dynamics_upstream%nsmax = initial%geometry%dimensions%nsmax
    dynamics_upstream%nmsmax = initial%geometry%dimensions%nmsmax
    dynamics_upstream%lvertfe = initial%prefix%vertical%configuration%lvertfe
    dynamics_upstream%ndlnpr = initial%prefix%vertical%configuration%ndlnpr
    dynamics_upstream%lnonhyd_geom = initial%geometry%configuration%values%lnonhyd_geom
    dynamics_upstream%nconf = initial%controls%namespace%nconf
    child = initialize_operational_dynamics_controls(text, dynamics_upstream, pending%dynamics)
    if (child /= 0) goto900
    stage = 6
    time_upstream%nconf = initial%controls%namespace%nconf
    time_upstream%nsupersede = pending%nsupersede
    time_upstream%l4dvar = initial%controls%namespace%l4dvar
    time_upstream%reserved = 0
    child = initialize_operational_time_integration_configuration(initial%controls%clock_input, &
                                                                  initial%controls%clock, time_upstream)
    if (child /= 0) goto900
    stage = 7
    physics_controls = [merge(1_int32, 0_int32, pending%dynamics%lslag), &
                        0_int32]
    child = initialize_operational_physics_configuration(text, pending%physics, physics_controls, &
                                                         pending%physics_counts, pending%output_requests)
    if (child /= 0) goto900
    stage = 8
    child = initialize_operational_inactive_startup_controls(text, pending%nudging, pending%climate, &
                                              pending%trajectory_count, pending%packing_word, pending%physics%arpege_physics%lmse, &
                                                           pending%physics%ecmwf_physics%lesice, initial%controls%namespace%nfrco, &
                                                             initial%controls%namespace%lr2d == 1)
    if (child /= 0) goto900
    stage = 9
    dimension_controls%nconf = initial%controls%namespace%nconf
    dimension_controls%lecmwf = initial%controls%namespace%lecmwf == 1
    dimension_controls%lr3d = initial%controls%namespace%lr3d == 1
    dimension_controls%lr2d = initial%controls%namespace%lr2d == 1
    dimension_controls%lelam = initial%controls%namespace%lelam == 1
    dimension_controls%l_oops = initial%controls%namespace%l_oops == 1
    dimension_controls%ljc = initial%initialization%ljc == 1
    dimension_controls%lmcc01 = pending%climate%lmcc01
    dimension_controls%jpvxp = 20
    dimension_controls%jpcxp = 50
    child = initialize_physics_field_dimensions(text, pending%field_dimensions, pending%physics_dimensions, &
                                                pending%dynamics, pending%physics%ecmwf_physics, pending%physics%phy, &
                                                pending%physics%arpege_physics, dimension_controls)
    if (child /= 0) goto900
    stage = 10
    field_controls = [initial%geometry%dimensions%nflevg, 0_int32, initial%controls%clock%total_steps, 1_int32, &
                      merge(1_int32, 0_int32, pending%dynamics%lsprt), 0_int32, initial%controls%namespace%nconf, &
                      initial%controls%namespace%lecmwf, merge(1_int32, 0_int32, pending%physics%ecmwf_physics%leo3ch)]
    child = initialize_operational_grid_field_configuration(pending%fields, initial%constants, text, &
                                                            field_controls, pending%field_effects)
    if (child /= 0) goto900
    if (any(pending%physics_counts /= [pending%fields%alias_controls%nnogw, pending%fields%alias_controls%nedrp, &
                     pending%fields%settings%nfsd, pending%fields%alias_controls%nuvp, pending%fields%alias_controls%naerout])) then
      child = 2
      goto900
    end if
    stage = 11
    child = initialize_spectral_field_dimensions(pending%field_dimensions, pending%dynamics, &
                                                 pending%fields%registration%numspflds, dimension_controls)
    if (child /= 0) goto900
    stage = 12
    child = initialize_grid_motion_index_maps(pending%motion, pending%field_dimensions, pending%dynamics, &
                                              initial%controls%namespace%nundefld)
    if (child /= 0) goto900
    stage = 13
    child = initialize_interpolation_record_defaults(pending%interpolation)
    if (child /= 0) goto900
    stage = 14
    child = require_empty_physics_group(text, 'NAMDDH')
    if (child /= 0) goto900
    pending%lrsiddh = .false.
    platform%nconf = initial%controls%namespace%nconf
    platform%lecmwf = initial%controls%namespace%lecmwf
    platform%lr2d = initial%controls%namespace%lr2d
    platform%lr3d = initial%controls%namespace%lr3d
    child = initialize_operational_interpolation_controls(text, pending%dynamics, platform, pending%interpolation_controls)
    if (child /= 0) goto900
    stage = 15
    plane_controls%lslag = pending%dynamics%lslag
    plane_controls%nsldimk = pending%interpolation_controls%nsldimk
    plane_controls%lvsplip = pending%dynamics%lvsplip
    plane_controls%lsltvweno = pending%dynamics%lsltvweno
    plane_controls%lrhsvweno = pending%dynamics%lrhsvweno
    plane_controls%lslvf = pending%dynamics%lslvf
    plane_controls%lslhdheat = pending%interpolation_controls%lslhdheat
    plane_controls%lvweno_t = pending%interpolation_controls%lvweno_t
    do j = 1, 2163
      selectors(j) = pending%fields%components(j)%cslint
    end do
    call initialize_internal_interpolation_plane_maps(plane_controls, selectors, pending%linear_full, &
                                    pending%linear_half, pending%nonlinear_full, pending%nonlinear_half, pending%spherical_planes, &
                                                      pending%cartesian_planes, child)
    if (child /= 0) goto900
    stage = 16
    child = initialize_selected_sl_velocity_controls(initial%geometry%dimensions%nflevg, &
                                                     pending%interpolation_controls)
    if (child /= 0) goto900
    stage = 17
    child = initialize_selected_sl_buffer_maps(initial%geometry%dimensions%nflevg, pending%dynamics, &
                                               pending%interpolation_controls, pending%fields, pending%physics%ecmwf_physics, &
                                               pending%field_effects(2) == 1, pending%lrsiddh, pending%buffers)
    if (child /= 0) goto900
  end associate
  pending%surface_controls%nflevg = initial%geometry%dimensions%nflevg
  pending%surface_controls%nundefld = initial%controls%namespace%nundefld
  pending%surface_controls%nstop = initial%controls%clock%integration%total_steps
  pending%surface_controls%lwcou = merge(1_int32, 0_int32, pending%physics%wave_coupling%lwcou)
  pending%surface_controls%lwcou2w = merge(1_int32, 0_int32, pending%physics%wave_coupling%lwcou2w)
  pending%surface_controls%lwcouhmf = merge(1_int32, 0_int32, pending%physics%wave_coupling%lwcouhmf)
  pending%surface_controls%lwcur = merge(1_int32, 0_int32, pending%physics%wave_coupling%lwcur)
  pending%surface_controls%lwstokes = merge(1_int32, 0_int32, pending%physics%wave_coupling%lwstokes)
  pending%surface_controls%lwflux = merge(1_int32, 0_int32, pending%physics%wave_coupling%lwflux)
  pending%surface_controls%laqua = pending%dynamical_core%laqua
  pending%surface_controls%lifstraj = initial%controls%namespace%lifstraj
  pending%surface_controls%lecmwf = initial%controls%namespace%lecmwf
  pending%packing_controls_ready = .false.
  pending%terrain_controls_ready = .false.
  pending%terrain_vertical_index = 0
  pending%terrain_vertical_count = 0
  pending%ready = .true.
  status = 0
  child_status = 0
  failed_stage = 0
  return
900 continue
  child_status = child
  failed_stage = stage
  status = 64 + 4*stage + child
  ! Retain reached data and owners for the owning caller's source-ordered cleanup.
  ! Do not invalidate aliases or replace this caller-owned carrier on failure.
  return
  end function

!> Release configuration contents after all dependent owners have closed.
!! The caller retains the outer record and destroys its aliases separately.
  integer(int32) function release_operational_model_configuration_contents(output) result(status)
    type(native_operational_model_configuration), target, intent(inout) :: output
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored
    status = 0
    status = 2
    if (.not. dependencies_released(output)) return
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    call ieee_get_status(incoming)
    ignored = release_selected_sl_buffer_maps(output%buffers)
    nullify (output%partition, output%initial)
    output%ready = .false.
    error_number = saved_errno
    call ieee_set_status(incoming)
    status = 0
  end function

  logical function dependencies_released(output) result(released)
    type(native_operational_model_configuration), intent(in) :: output
    released = .false.
    if (allocated(output%motion%gmv)) return
    if (allocated(output%motion%gmvs)) return
    if (allocated(output%motion%gmvt1)) return
    if (allocated(output%motion%gmvt1s)) return
    if (allocated(output%motion%gmv5)) return
    if (allocated(output%motion%gmv5s)) return
    if (allocated(output%motion%gmv_depart)) return
    if (allocated(output%motion%gmvs_depart)) return
    if (allocated(output%field_dimensions%ngrbsp3)) return
    if (allocated(output%field_dimensions%ngrbsp2)) return
    if (allocated(output%physics%radiation_coefficients%solrad)) return
    if (allocated(output%physics%radiation_coefficients%therrad)) return
    if (allocated(output%physics%radiation_coefficients%trweight)) return
    if (allocated(output%physics%radiation_coefficients%trmatsum)) return
    if (allocated(output%physics%wave_coupling%mask_wave_in)) return
    if (allocated(output%physics%wave_coupling%mask_wave_out)) return
    if (allocated(output%physics%wave_coupling%mwvin_sendcnt)) return
    if (allocated(output%physics%wave_coupling%mwvin_recvcnt)) return
    if (allocated(output%physics%wave_coupling%mwvin_sendoff)) return
    if (allocated(output%physics%wave_coupling%mwvin_recvoff)) return
    if (allocated(output%physics%wave_coupling%mwvin_sendbuf)) return
    if (allocated(output%physics%wave_coupling%mwvin_recvbuf)) return
    if (allocated(output%physics%wave_coupling%mwvin_sendind)) return
    if (allocated(output%physics%wave_coupling%iwv_lon)) return
    if (allocated(output%physics%wave_coupling%iwv_lat)) return
    if (allocated(output%physics%wave_coupling%wv_w2iwght)) return
    if (allocated(output%physics%surface_tangent_linear%gptskin0)) return
    if (allocated(output%physics%surface_tangent_linear%gptskin9)) return
    if (allocated(output%interpolation%nslsta)) return
    if (allocated(output%interpolation%nslonl)) return
    if (allocated(output%interpolation%nsloff)) return
    if (allocated(output%interpolation%nslptswest)) return
    if (allocated(output%interpolation%nslptseast)) return
    if (allocated(output%interpolation%nslext)) return
    if (allocated(output%interpolation%lcomplat)) return
    if (allocated(output%interpolation%nlatglo)) return
    if (allocated(output%interpolation%dist1gp)) return
    if (allocated(output%interpolation%nslsendpos)) return
    if (allocated(output%interpolation%nslrecvpos)) return
    if (allocated(output%interpolation%nslsendptr)) return
    if (allocated(output%interpolation%nslrecvptr)) return
    if (allocated(output%interpolation%nslcomm)) return
    if (allocated(output%interpolation%lslcomm)) return
    if (allocated(output%interpolation%mask_sl1)) return
    if (allocated(output%interpolation%mask_sl2)) return
    if (allocated(output%interpolation%mask_sl2t)) return
    if (allocated(output%interpolation%mask_sld)) return
    if (allocated(output%interpolation%nslmap)) return
    if (allocated(output%interpolation%nslcore)) return
    if (allocated(output%interpolation%lslcore)) return
    if (allocated(output%interpolation%mask_sltot)) return
    if (allocated(output%interpolation%nloeng)) return
    if (allocated(output%climate%ncligc_compo)) return
    if (allocated(output%climate%nysdmp_compo)) return
    if (allocated(output%climate%climrco2)) return
    if (allocated(output%climate%climraer)) return
    if (allocated(output%climate%climrcompo)) return
    if (allocated(output%climate%zlake)) return
    if (allocated(output%climate%oceanbc)) return
    if (allocated(output%climate%climr)) return
    if (allocated(output%climate%rnemolvls)) return
    if (allocated(output%climate%rnemomask)) return
    if (allocated(output%climate%partsst0)) return
    if (allocated(output%climate%partmask)) return
    if (allocated(output%climate%cplng_fld)) return
    released = .true.
  end function
end module forecast_in_place_model_configuration
