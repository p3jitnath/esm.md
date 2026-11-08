!> The caller establishes round-to-nearest, ties-to-even, and gradual underflow before entry.
!> Compose the generated ECMWF physics setup with native owned parameters.
module forecast_owned_ecmwf_physics_setup_native_clock_waves
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_intptr_t, c_ptr, c_f_pointer, c_loc
  use ieee_exceptions, only: ieee_all, ieee_get_flag, ieee_set_flag
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_ecmwf_surface_setup_actual, only: create_ecmwf_surface_parameters
  use forecast_vertical_coordinate_storage, only: native_vertical_state
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use physics_configuration_state_port, only: physics_configuration_state
  use dynamical_configuration_port, only: native_dynamical_configuration
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: ecmwf_thermal_state_record
  use thermal_diffusion_parameter_setup_port, only: initialize_thermal_namespace_fields, initialize_stability_table_fields
  use native_inactive_startup_controls, only: native_climate_coupling_controls
  use ecmwf_physics_control_fields_port, only: physics_runtime_inputs, selected_composition_aerosol_flags, &
                                               initialize_minimum_surface_ice_fraction
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use cloud_pressure_inputs_one_based_port, only: hybrid_pressure_controls, &
                                               initialize_selected_cloud_pressure_controls, initialize_runtime_cloud_pressure_inputs
  use diagnostic_cloud_parameter_fields_mod, only: initialize_diagnostic_cloud_fields
  use cloud_gravity_wave_parameter_setup_mod, only: release_cloud_parameter_eta
  use condensation_parameter_setup_mod, only: initialize_condensation_parameters
  use convection_parameter_setup_port, only: initialize_runtime_convection_parameters
  use convection_thermal_publication_port, only: publish_convection_thermal_parameters
  use gravity_wave_parameter_fields_mod, only: initialize_orographic_gravity_wave_fields, &
                                               initialize_nonorographic_gravity_wave_fields
  use selected_diffusion_parameters_port, only: initialize_operational_diffusion_parameters
  use forecast_owned_radiation_setup_from_native_clock, only: initialize_owned_radiation_setup_from_native_clock, &
                                                              release_owned_actual_radiation_setup
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record
  use surface_optimization_parameters_mod, only: initialize_surface_optimization_parameters, &
                                                 release_surface_optimization_parameters, rvr0vt
  use cloud_optical_parameter_setup_mod, only: initialize_runtime_cloud_optical_parameters
  use prognostic_cloud_parameter_setup_mod, only: initialize_runtime_prognostic_cloud_parameters
  use ecmwf_physics_tail_fields_mod, only: physics_tail_upstream_record
  use ecmwf_physics_tail_setup_mod, only: initialize_selected_ecmwf_physics_tail
  use yoecmip, only: TECMIP
  use yomphy2, only: tphy2
  use yomdphy, only: tdphy
  use forecast_model_clock_port, only: forecast_clock
  implicit none
  private
  public :: initialize_owned_ecmwf_physics_from_native_clock, release_owned_ecmwf_physics_from_native_clock
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Admit and complete the selected SUPHEC calculation in source order.
  !! STATE owns the new parameter records, CETA, radiation and surface owners.
  !! CONFIGURATION is the shared seventeen-record physics carrier. THERMAL
  !! borrows the shared thermal and stability records; it is not a second
  !! namespace. TIME is the sole native forecast clock and CMIP is its separate
  !! actual scientific target. CONSTANTS, CONTROLS, GRID, PARTITION,
  !! VERTICAL, DYNAMICS, RUNTIME and COUPLING are readonly produced
  !! records. VERTICAL owns half arrays0:levels and layer arrays1:levels.
  !! ATMOSPHERE_PRESSURE borrows geometry atmosphere full_pressure(1:levels),
  !! in Pa. ATMOSPHERE_HEIGHT borrows its height(1:levels), in metres. Both
  !! stay independent of the local SUPHEC pressure calculation, and no
  !! second atmosphere owner or constructed TSTA object is introduced.
  !! PHYSICS_TIME borrows the canonical TPHY2 record. Its TSPHY interval is
  !! in seconds and differs from the separate TRIP interval TIME%TSTEP.
  !! FIELD_DIMENSIONS borrows canonical TDPHY counts. CLOCK supplies the
  !! initial date YYYYMMDD and seconds since midnight. The wave-physics
  !! switch is CONFIGURATION%ECMWF_PHYSICS%LEMWAVE. DATA_DIRECTORY and TEXT are readonly
  !! bounded source strings. SEED contains radiation controls not in shared
  !! records. COMPOSITION carries the two source aerosol logicals.
  !! AEROSOL_COUNTS is [NAERO,NACTAERO]. FIELD_DIMENSIONS supplies NCOM,
  !! NCSS, NTILES and NCSNEC without another count record. BYTE_QUOTA
  !! bounds flux allocation in bytes. RUNTIME_GRID selects the existing
  !! runtime radiation entries. This caller supports4:256 live levels.
  !! Early radiation context and aerosol/overlap storage must already exist.
  !! All mutable owners are separate from readonly input owners. The caller
  !! must not copy or alias a live pointer-bearing state. The compiler owns
  !! all type layout, argument passing and scratch arrays.
  !! Return0 after the complete selected route,1 on an owned allocation
  !! failure or2 on unsupported input. A late failure retains scientific
  !! prefix writes and releases only acquired resources. Last_stage and
  !! last_status identify it. No complete-model rollback is claimed.
  integer(int32) function initialize_owned_ecmwf_physics_from_native_clock(state,text,data_directory,constants,controls,grid,partition, &
      configuration,time,cmip,atmosphere_pressure,atmosphere_height,vertical,dynamics,thermal,runtime,coupling,physics_time,field_dimensions,seed,composition, &
                                                                           aerosol_counts, byte_quota, runtime_grid) result(status)
    type(native_ecmwf_physics_state), intent(inout) :: state
    character(len=*), intent(in) :: text, data_directory
    type(forecast_physical_constants), intent(in) :: constants
    type(native_forecast_control_namespace), intent(in) :: controls
    type(native_grid_dimensions), intent(in) :: grid
    type(native_distributed_partition), intent(in) :: partition
    type(physics_configuration_state), intent(inout) :: configuration
    type(forecast_clock), intent(in) :: time
    type(TECMIP), intent(inout) :: cmip
    real(real64), intent(in) :: atmosphere_pressure(:), atmosphere_height(:)
    type(native_vertical_state), intent(in) :: vertical
    type(native_dynamical_configuration), intent(in) :: dynamics
    type(ecmwf_thermal_state_record), intent(inout) :: thermal
    type(physics_runtime_inputs), intent(in) :: runtime
    type(native_climate_coupling_controls), intent(in) :: coupling
    type(tphy2), intent(in) :: physics_time
    type(tdphy), intent(in) :: field_dimensions
    type(radiation_control_upstream_record), intent(in) :: seed
    type(selected_composition_aerosol_flags), intent(in) :: composition
    integer(int32), intent(in) :: aerosol_counts(2)
    integer(int64), intent(in) :: byte_quota
    logical, intent(in) :: runtime_grid
    integer(int32) :: levels, group_number
    integer(int64) :: ice_word
    integer, parameter :: group_lengths(8) = [6, 8, 7, 8, 6, 7, 7, 9]
    character(len=10), parameter :: groups(8) = [character(len=10) :: &
                                           'NAMGWD', 'NAMGWWMS', 'NAMCUMF', 'NAMCUMFS', 'NAMVDF', 'NAMCLDP', 'NAEPHLI', 'NAMMETHOX']
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    levels = grid%nflevg
    if (levels < 4 .or. levels > 256 .or. vertical%levels /= levels) return
    if (.not. vertical%constructor_ready .or. .not. vertical%eta_bounds_ready) return
    if (grid%ndglg < 2 .or. grid%ndglg > 16384 .or. grid%nsmax < 1) return
    if (constants%initialized /= 1) return
    if (controls%lecmwf /= 1 .or. controls%larpegef /= 0 .or. controls%nconf /= 1) return
    if (.not. configuration%ecmwf_physics%lephys) return
    if (configuration%phy%lray .or. configuration%phy%lrayfm15) return
    ! Original SUPHEC calls SUWAM only for LWCOU and NFPOS/=2.
    ! The actual Fullpos2 route forwards these source flags to SUSURF.
    ! Other coupled routes still require the separate SUWAM numerical child.
    if (configuration%wave_coupling%lwcouhmf) return
    if (configuration%wave_coupling%lwcou .or. configuration%wave_coupling%lwcou2w) then
      if (controls%nfpos /= 2) return
      if (.not. configuration%wave_coupling%lwcou .or. .not. configuration%wave_coupling%lwcou2w) return
    end if
    if (configuration%nonlinear_physics%leradlw2) return
    if (runtime%lscmec .or. runtime%lvdftraj .or. runtime%lrough) return
    if (state%setup_complete .or. state%cloud_eta_acquired .or. state%optimization_acquired .or. &
        state%radiation_attempted .or. state%surface_acquired .or. associated(state%surface)) return
    if (allocated(state%cloud%ceta) .or. allocated(rvr0vt)) return
    if (configuration%ecmwf_physics%ysurf /= 0_c_intptr_t) return
    if (.not. state%radiation%context_ready .or. .not. state%radiation%storage_ready) return
    if (state%radiation%setup_complete) return
    if (field_dimensions%ncom < 0 .or. field_dimensions%ncss /= 4 .or. field_dimensions%ntiles /= 9 .or. &
        field_dimensions%ncsnec /= 5) return
    if (any(aerosol_counts /= 0)) return
    if (configuration%ecmwf_physics%leoptsurf .or. .not. configuration%ecmwf_physics%lefarquhar) return
    if ((configuration%ecmwf_physics%nalbedoscheme /= 1 .and. configuration%ecmwf_physics%nalbedoscheme /= 2) .or. &
        configuration%ecmwf_physics%nemissscheme /= 0) return
    if (configuration%ecmwf_physics%nsnmlws < 1 .or. configuration%ecmwf_physics%nsnmlws > 3) return
    ice_word = transfer(configuration%ecmwf_physics%rcimin, ice_word)
    if (iand(ice_word, int(z'7FFFFFFFFFFFFFFF', int64)) > int(z'3FF0000000000000', int64)) return
    if (size(atmosphere_pressure) /= levels .or. size(atmosphere_height) /= levels) return
    if (.not. is_contiguous(atmosphere_pressure) .or. .not. is_contiguous(atmosphere_height)) return
    if (.not. allocated(vertical%vah) .or. .not. allocated(vertical%vbh) .or. .not. allocated(vertical%vc)) return
    if (.not. allocated(vertical%vaf) .or. .not. allocated(vertical%vbf)) return
    if (.not. allocated(vertical%vdela) .or. .not. allocated(vertical%vdelb)) return
    if (lbound(vertical%vah, 1) /= 0 .or. lbound(vertical%vbh, 1) /= 0) return
    if (size(vertical%vah) < levels + 1 .or. size(vertical%vbh) < levels + 1) return
    if (lbound(vertical%vc, 1) /= 1 .or. lbound(vertical%vaf, 1) /= 1 .or. lbound(vertical%vbf, 1) /= 1) return
    if (lbound(vertical%vdela, 1) /= 1 .or. lbound(vertical%vdelb, 1) /= 1) return
    if (min(size(vertical%vc), size(vertical%vaf), size(vertical%vbf), size(vertical%vdela), size(vertical%vdelb)) < levels) return
    if (.not. positive_finite(physics_time%tsphy) .or. .not. positive_finite(time%integration%first_dt)) return
    if (.not. positive_finite(dynamics%rplrg) .or. .not. positive_finite(dynamics%rpldare) .or. &
        .not. positive_finite(dynamics%rplradi)) return
    if (transfer(dynamics%rplrg, 0_int64) /= int(z'3FF0000000000000', int64)) return
    do group_number = 1, size(groups)
      if (require_empty_physics_group(text, groups(group_number) (1:group_lengths(group_number))) /= 0) return
    end do
    status = execute_owned_physics(levels, state, text, data_directory, constants, controls, grid, partition, configuration, &
                               time, cmip, atmosphere_pressure, atmosphere_height, vertical, dynamics, thermal, runtime, coupling, &
                                   configuration%ecmwf_physics%lemwave, physics_time%tsphy, seed, composition, aerosol_counts, &
                                 [field_dimensions%ncom, field_dimensions%ncss, field_dimensions%ntiles, field_dimensions%ncsnec], &
                                   [time%initial_date, time%initial_seconds], byte_quota, runtime_grid)
  end function

  !> Run the admitted numerical sequence with compiler-owned stack work arrays.
  integer(int32) function execute_owned_physics(levels, state, text, data_directory, constants, controls, grid, partition, &
      configuration,time,cmip,atmosphere_pressure,atmosphere_height,vertical,dynamics,thermal,runtime,coupling,lemwave,tsphy,seed,composition, &
                                              aerosol_counts, surface_counts, date_seconds, byte_quota, runtime_grid) result(status)
    integer(int32), intent(in) :: levels
    type(native_ecmwf_physics_state), intent(inout) :: state
    character(len=*), intent(in) :: text, data_directory
    type(forecast_physical_constants), intent(in) :: constants
    type(native_forecast_control_namespace), intent(in) :: controls
    type(native_grid_dimensions), intent(in) :: grid
    type(native_distributed_partition), intent(in) :: partition
    type(physics_configuration_state), intent(inout) :: configuration
    type(forecast_clock), intent(in) :: time
    type(TECMIP), intent(inout) :: cmip
    real(real64), intent(in) :: atmosphere_pressure(:), atmosphere_height(:)
    type(native_vertical_state), intent(in) :: vertical
    type(native_dynamical_configuration), intent(in) :: dynamics
    type(ecmwf_thermal_state_record), intent(inout) :: thermal
    type(physics_runtime_inputs), intent(in) :: runtime
    type(native_climate_coupling_controls), intent(in) :: coupling
    logical, intent(in) :: lemwave
    real(real64), intent(in) :: tsphy
    type(radiation_control_upstream_record), intent(in) :: seed
    type(selected_composition_aerosol_flags), intent(in) :: composition
    integer(int32), intent(in) :: aerosol_counts(2), surface_counts(4), date_seconds(2)
    integer(int64), intent(in) :: byte_quota
    logical, intent(in) :: runtime_grid
    type(hybrid_pressure_controls) :: pressure_controls
    type(physics_tail_upstream_record) :: tail
    real(real64), target :: half_pressure(0:levels), full_pressure(levels), half_eta(0:levels), full_eta(levels)
    real(real64), allocatable :: new_ceta(:)
    real(real64) :: convection_scalings(3), cloud_scalings(2)
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    logical :: saved_flags(size(ieee_all))
    integer :: allocation_status
    integer(int32) :: release_status
    integer(int32) :: allocated_cloud_shortwave_bands, active_cloud_shortwave_bands
    status = 2_int32
    state%last_stage = 1_int32
    call initialize_thermal_namespace_fields(constants, thermal%thermal)
    state%last_stage = 2_int32
    status = initialize_selected_cloud_pressure_controls(vertical%configuration, vertical%toppres, constants, pressure_controls)
    if (status /= 0) goto900
    status = initialize_runtime_cloud_pressure_inputs(pressure_controls, vertical%vp00, vertical%vah, vertical%vbh, &
          vertical%vc, vertical%vaf, vertical%vbf, vertical%vdela, vertical%vdelb, half_pressure, full_pressure, half_eta, full_eta)
    if (status /= 0) goto900
    state%last_stage = 3_int32
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    call ieee_get_flag(ieee_all, saved_flags)
    allocate (new_ceta(levels), stat=allocation_status)
    error_number = saved_errno
    call ieee_set_flag(ieee_all, saved_flags)
    if (allocation_status /= 0) then
      status = 1_int32
      goto900
    end if
    call move_alloc(new_ceta, state%cloud%ceta)
    state%cloud_eta_acquired = .true.
    call initialize_diagnostic_cloud_fields(state%cloud, full_eta)
    state%last_stage = 4_int32
    status = initialize_condensation_parameters(state%condensation)
    if (status /= 0) goto900
    state%last_stage = 5_int32
    convection_scalings = [dynamics%rplrg, dynamics%rpldare, dynamics%rplradi]
    status = initialize_runtime_convection_parameters(text, state%convection, state%linearized_convection, &
                            state%convection_switches, state%convection_thermal, atmosphere_pressure(1:levels), levels, constants, &
                                                      convection_scalings, time%integration%first_dt, grid%ndglg)
    if (status /= 0) goto900
    call publish_convection_thermal_parameters(thermal%thermal, state%convection_thermal)
    state%last_stage = 6_int32
    call initialize_orographic_gravity_wave_fields(state%orographic_gravity_wave, atmosphere_pressure(1:levels), &
                                vertical%vah(0:levels), vertical%vbh(0:levels), constants%rhour, configuration%ecmwf_physics%lephys)
    call initialize_nonorographic_gravity_wave_fields(state%nonorographic_gravity_wave, &
                                                      atmosphere_pressure(1:levels), constants%rhour, time%integration%first_dt)
    state%last_stage = 7_int32
    call initialize_stability_table_fields(thermal%stability)
    status = initialize_operational_diffusion_parameters(text, state%diffusion, dynamics%rplrg)
    if (status /= 0) goto900
    state%last_stage = 8_int32
    state%radiation_attempted = .true.
  status=initialize_owned_radiation_setup_from_native_clock(state%radiation,text,data_directory,constants,controls,grid,partition, &
      configuration,time,cmip,atmosphere_height,half_eta,dynamics%rplrg,seed,composition,aerosol_counts,date_seconds,byte_quota,runtime_grid)
    if (status /= 0) goto900
    if (state%radiation%radiation%naermacc /= 1 .or. state%radiation%radiation%nsw /= 6 .or. &
        state%radiation%radiation%ntsw /= 14) then
      status = 2_int32
      goto900
    end if
    state%last_stage = 9_int32
    status = initialize_minimum_surface_ice_fraction(configuration%ecmwf_physics%rcimin, &
                                                     coupling%lmccdynseaice, coupling%lnemo1way)
    if (status /= 0) goto900
    state%last_stage = 10_int32
    status = initialize_surface_optimization_parameters(configuration%ecmwf_physics%lefarquhar, &
                                                        configuration%ecmwf_physics%leoptsurf)
    if (status /= 0) goto900
    state%optimization_acquired = .true.
    state%last_stage = 11_int32
    status = create_ecmwf_surface_parameters(state%surface, configuration%ecmwf_physics, &
                                             configuration%wave_coupling, state%radiation, dynamics, runtime, &
                                             surface_counts(1), surface_counts(2), surface_counts(3), surface_counts(4))
    if (status /= 0) goto900
    state%surface_acquired = .true.
    configuration%ecmwf_physics%ysurf = transfer(c_loc(state%surface), 0_c_intptr_t)
    state%last_stage = 12_int32
    ! Copy the input counts so they are separate from the output record.
    allocated_cloud_shortwave_bands = state%radiation%radiation%ntsw
    active_cloud_shortwave_bands = state%radiation%radiation%nsw
    status = initialize_runtime_cloud_optical_parameters(state%radiation%radiation, state%radiation%shortwave, &
                           state%radiation%cloud_optical_550, allocated_cloud_shortwave_bands, active_cloud_shortwave_bands, levels)
    if (status /= 0) goto900
    state%last_stage = 13_int32
    cloud_scalings = [dynamics%rplrg, dynamics%rplradi]
    status = initialize_runtime_prognostic_cloud_parameters(text, configuration%cloud, atmosphere_pressure(1:levels), &
                                                          levels, constants%rpi, constants%rg, constants%rtt, cloud_scalings, tsphy)
    if (status /= 0) goto900
    state%last_stage = 14_int32
    tail%nindat = date_seconds(1)
    tail%nsssss = date_seconds(2)
    tail%lemwave = lemwave
    tail%lvdftraj = runtime%lvdftraj
    tail%lrrtm = state%radiation%radiation%lrrtm
    tail%novlp = state%radiation%radiation%novlp
    tail%rtwat = thermal%thermal%rtwat
    tail%rtice = thermal%thermal%rtice
    status = initialize_selected_ecmwf_physics_tail(text, tail, configuration%wave_coupling, &
                       configuration%linear_ecmwf, configuration%nonlinear_physics, configuration%longwave_radiation, state%methane)
    if (status /= 0) goto900
    state%setup_complete = .true.
    state%last_stage = 15_int32
    state%last_status = 0_int32
    status = 0_int32
    return
900 continue
    state%last_status = status
    release_status = release_owned_ecmwf_physics_from_native_clock(state, configuration)
  end function

  !> Release the owned surface, optimization, radiation and CETA in source order.
  !! STATE and CONFIGURATION remain live. The native surface handle is cleared
  !! only after its owned object was released. The canonical TEPHY handle is
  !! an integer address, so ISO_C_BINDING supplies its native integer kind.
  !! New numerical calls use the typed TSURF pointer directly. Other scalar values
  !! stay unchanged. Preserve incoming exception flags and C errno, including
  !! a failing child allocation's natural value. Repeated release is harmless.
  integer(int32) function release_owned_ecmwf_physics_from_native_clock(state, configuration) result(status)
    type(native_ecmwf_physics_state), intent(inout) :: state
    type(physics_configuration_state), intent(inout) :: configuration
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    logical :: saved_flags(size(ieee_all))
    integer :: allocation_status
    integer(int32) :: child_status
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    call ieee_get_flag(ieee_all, saved_flags)
    status = 0_int32
    if (state%surface_acquired) then
      if (associated(state%surface)) then
        deallocate (state%surface, stat=allocation_status)
        if (allocation_status /= 0) status = 1_int32
      end if
      if (status == 0) then
        nullify (state%surface)
        configuration%ecmwf_physics%ysurf = 0_c_intptr_t
        state%surface_acquired = .false.
      end if
    end if
    if (state%optimization_acquired) then
      child_status = release_surface_optimization_parameters()
      if (child_status == 0) then
        state%optimization_acquired = .false.
      else
        status = child_status
      end if
    end if
    if (state%radiation_attempted) then
      child_status = release_owned_actual_radiation_setup(state%radiation)
      if (child_status == 0) then
        state%radiation_attempted = .false.
      else
        status = child_status
      end if
    end if
    if (state%cloud_eta_acquired) then
      child_status = release_cloud_parameter_eta(state%cloud)
      if (child_status == 0) then
        state%cloud_eta_acquired = .false.
      else
        status = child_status
      end if
    end if
    state%setup_complete = .false.
    error_number = saved_errno
    call ieee_set_flag(ieee_all, saved_flags)
  end function

  !> Test positive finite scalar bits without adding floating arithmetic.
  logical function positive_finite(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, word)
    valid = word > 0_int64 .and. word < int(z'7FF0000000000000', int64)
  end function

  !> Require nearest rounding and actual gradual underflow, preserving flags.
end module forecast_owned_ecmwf_physics_setup_native_clock_waves
