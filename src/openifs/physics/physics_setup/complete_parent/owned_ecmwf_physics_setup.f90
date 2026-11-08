!> Compose the generated ECMWF physics setup with native owned parameters.
module forecast_owned_ecmwf_physics_setup
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_intptr_t, c_ptr, c_f_pointer, c_loc
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_all, ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_ecmwf_surface_setup, only: create_ecmwf_surface_parameters
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
  use forecast_owned_radiation_setup, only: initialize_owned_radiation_setup
  use native_radiation_setup_lifetime, only: release_owned_radiation_setup
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record
  use surface_optimization_parameters_mod, only: initialize_surface_optimization_parameters, &
                                                 release_surface_optimization_parameters, rvr0vt
  use cloud_optical_parameter_setup_mod, only: initialize_runtime_cloud_optical_parameters
  use prognostic_cloud_parameter_setup_mod, only: initialize_runtime_prognostic_cloud_parameters
  use ecmwf_physics_tail_fields_mod, only: physics_tail_upstream_record
  use ecmwf_physics_tail_setup_mod, only: initialize_selected_ecmwf_physics_tail
  use yomrip, only: trip
  use yomsta, only: tsta
  implicit none
  private
  public :: initialize_owned_ecmwf_physics, release_owned_ecmwf_physics
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
  !! namespace. TIME is the shared TRIP. CONSTANTS, CONTROLS, GRID, PARTITION,
  !! VERTICAL, DYNAMICS, ATMOSPHERE, RUNTIME and COUPLING are readonly produced
  !! records. VERTICAL owns half arrays0:levels and layer arrays1:levels.
  !! ATMOSPHERE owns STPRE(1:levels), in Pa, independently of the local SUPHEC
  !! pressure calculation. Its STZ owner remains the radiation input.
  !! TSPHY is the readonly TPHY2 interval in seconds; TIME%TSTEP supplies the
  !! separate original TRIP interval. LEMWAVE is the original readonly wave\n  !! physics switch; its producer remains an explicit integration join. DATA_DIRECTORY and TEXT are readonly
  !! bounded source strings. SEED contains radiation controls not in shared
  !! records. COMPOSITION carries the two source aerosol logicals.
  !! AEROSOL_COUNTS is [NAERO,NACTAERO]. SURFACE_COUNTS is the four source
  !! DDPHY inputs [NCOM,NCSS,NTILES,NCSNEC]; its native producer is a separate
  !! integration requirement. DATE_SECONDS is [NINDAT,NSSSSS]. BYTE_QUOTA
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
  integer(int32) function initialize_owned_ecmwf_physics(state, text, data_directory, constants, controls, grid, partition, &
               configuration, time, atmosphere, vertical, dynamics, thermal, runtime, coupling, lemwave, tsphy, seed, composition, &
                                              aerosol_counts, surface_counts, date_seconds, byte_quota, runtime_grid) result(status)
    type(native_ecmwf_physics_state), intent(inout) :: state
    character(len=*), intent(in) :: text, data_directory
    type(forecast_physical_constants), intent(in) :: constants
    type(native_forecast_control_namespace), intent(in) :: controls
    type(native_grid_dimensions), intent(in) :: grid
    type(native_distributed_partition), intent(in) :: partition
    type(physics_configuration_state), intent(inout) :: configuration
    type(trip), intent(inout) :: time
    type(tsta), intent(in) :: atmosphere
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
    if (configuration%wave_coupling%lwcou .or. configuration%wave_coupling%lwcou2w .or. &
        configuration%wave_coupling%lwcouhmf) return
    if (configuration%nonlinear_physics%leradlw2) return
    if (runtime%lscmec .or. runtime%lvdftraj .or. runtime%lrough) return
    if (state%setup_complete .or. state%cloud_eta_acquired .or. state%optimization_acquired .or. &
        state%radiation_attempted .or. state%surface_acquired .or. associated(state%surface)) return
    if (allocated(state%cloud%ceta) .or. allocated(rvr0vt)) return
    if (configuration%ecmwf_physics%ysurf /= 0_c_intptr_t) return
    if (.not. state%radiation%context_ready .or. .not. state%radiation%storage_ready) return
    if (state%radiation%setup_complete) return
    if (surface_counts(1) < 0 .or. any(surface_counts(2:4) /= [4, 9, 5])) return
    if (any(aerosol_counts /= 0)) return
    if (configuration%ecmwf_physics%leoptsurf .or. .not. configuration%ecmwf_physics%lefarquhar) return
    if (configuration%ecmwf_physics%nalbedoscheme /= 1 .or. configuration%ecmwf_physics%nemissscheme /= 0) return
    if (configuration%ecmwf_physics%nsnmlws < 1 .or. configuration%ecmwf_physics%nsnmlws > 3) return
    ice_word = transfer(configuration%ecmwf_physics%rcimin, ice_word)
    if (iand(ice_word, int(z'7FFFFFFFFFFFFFFF', int64)) > int(z'3FF0000000000000', int64)) return
    if (.not. allocated(atmosphere%stpre) .or. .not. allocated(atmosphere%stz)) return
    if (size(atmosphere%stpre) < levels .or. size(atmosphere%stz) < levels) return
    if (.not. allocated(vertical%vah) .or. .not. allocated(vertical%vbh) .or. .not. allocated(vertical%vc)) return
    if (.not. allocated(vertical%vaf) .or. .not. allocated(vertical%vbf)) return
    if (.not. allocated(vertical%vdela) .or. .not. allocated(vertical%vdelb)) return
    if (lbound(vertical%vah, 1) /= 0 .or. lbound(vertical%vbh, 1) /= 0) return
    if (size(vertical%vah) < levels + 1 .or. size(vertical%vbh) < levels + 1) return
    if (lbound(vertical%vc, 1) /= 1 .or. lbound(vertical%vaf, 1) /= 1 .or. lbound(vertical%vbf, 1) /= 1) return
    if (lbound(vertical%vdela, 1) /= 1 .or. lbound(vertical%vdelb, 1) /= 1) return
    if (min(size(vertical%vc), size(vertical%vaf), size(vertical%vbf), size(vertical%vdela), size(vertical%vdelb)) < levels) return
    if (.not. positive_finite(tsphy) .or. .not. positive_finite(time%tstep)) return
    if (.not. positive_finite(dynamics%rplrg) .or. .not. positive_finite(dynamics%rpldare) .or. &
        .not. positive_finite(dynamics%rplradi)) return
    if (transfer(dynamics%rplrg, 0_int64) /= int(z'3FF0000000000000', int64)) return
    if (.not. supported_floating_mode()) return
    do group_number = 1, size(groups)
      if (require_empty_physics_group(text, groups(group_number) (1:group_lengths(group_number))) /= 0) return
    end do
    status = execute_owned_physics(levels, state, text, data_directory, constants, controls, grid, partition, configuration, &
              time, atmosphere, vertical, dynamics, thermal, runtime, coupling, lemwave, tsphy, seed, composition, aerosol_counts, &
                                   surface_counts, date_seconds, byte_quota, runtime_grid)
  end function

  !> Run the admitted numerical sequence with compiler-owned stack work arrays.
  integer(int32) function execute_owned_physics(levels, state, text, data_directory, constants, controls, grid, partition, &
               configuration, time, atmosphere, vertical, dynamics, thermal, runtime, coupling, lemwave, tsphy, seed, composition, &
                                              aerosol_counts, surface_counts, date_seconds, byte_quota, runtime_grid) result(status)
    integer(int32), intent(in) :: levels
    type(native_ecmwf_physics_state), intent(inout) :: state
    character(len=*), intent(in) :: text, data_directory
    type(forecast_physical_constants), intent(in) :: constants
    type(native_forecast_control_namespace), intent(in) :: controls
    type(native_grid_dimensions), intent(in) :: grid
    type(native_distributed_partition), intent(in) :: partition
    type(physics_configuration_state), intent(inout) :: configuration
    type(trip), intent(inout) :: time
    type(tsta), intent(in) :: atmosphere
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
                               state%convection_switches, state%convection_thermal, atmosphere%stpre(1:levels), levels, constants, &
                                                      convection_scalings, time%tstep, grid%ndglg)
    if (status /= 0) goto900
    call publish_convection_thermal_parameters(thermal%thermal, state%convection_thermal)
    state%last_stage = 6_int32
    call initialize_orographic_gravity_wave_fields(state%orographic_gravity_wave, atmosphere%stpre(1:levels), &
                                vertical%vah(0:levels), vertical%vbh(0:levels), constants%rhour, configuration%ecmwf_physics%lephys)
    call initialize_nonorographic_gravity_wave_fields(state%nonorographic_gravity_wave, &
                                                      atmosphere%stpre(1:levels), constants%rhour, time%tstep)
    state%last_stage = 7_int32
    call initialize_stability_table_fields(thermal%stability)
    status = initialize_operational_diffusion_parameters(text, state%diffusion, dynamics%rplrg)
    if (status /= 0) goto900
    state%last_stage = 8_int32
    state%radiation_attempted = .true.
    status = initialize_owned_radiation_setup(state%radiation, text, data_directory, constants, controls, grid, partition, &
         configuration,time,atmosphere,half_eta,dynamics%rplrg,seed,composition,aerosol_counts,date_seconds,byte_quota,runtime_grid)
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
    status = initialize_runtime_cloud_optical_parameters(state%radiation%radiation, state%radiation%shortwave, &
                           state%radiation%cloud_optical_550, state%radiation%radiation%ntsw, state%radiation%radiation%nsw, levels)
    if (status /= 0) goto900
    state%last_stage = 13_int32
    cloud_scalings = [dynamics%rplrg, dynamics%rplradi]
    status = initialize_runtime_prognostic_cloud_parameters(text, configuration%cloud, atmosphere%stpre(1:levels), &
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
    release_status = release_owned_ecmwf_physics(state, configuration)
  end function

  !> Release the owned surface, optimization, radiation and CETA in source order.
  !! STATE and CONFIGURATION remain live. The native surface handle is cleared
  !! only after its owned object was released. The canonical TEPHY handle is\n  !! an integer address, so ISO_C_BINDING supplies its native integer kind.\n  !! New numerical calls use the typed TSURF pointer directly. Other scalar values
  !! stay unchanged. Preserve incoming exception flags and C errno, including
  !! a failing child allocation's natural value. Repeated release is harmless.
  integer(int32) function release_owned_ecmwf_physics(state, configuration) result(status)
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
      child_status = release_owned_radiation_setup(state%radiation)
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
  logical function supported_floating_mode() result(valid)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: underflow_before, inexact_before
    valid = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, underflow_before)
    call ieee_get_flag(ieee_inexact, inexact_before)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    valid = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, underflow_before)
    call ieee_set_flag(ieee_inexact, inexact_before)
  end function
end module forecast_owned_ecmwf_physics_setup
