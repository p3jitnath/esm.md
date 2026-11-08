!> Compose the complete selected Meteo-France physics setup in source order.
!! Native records replace the historical MODEL offsets. The caller supplies
!! produced constants, controls, geometry and field metadata, and establishes
!! nearest-even rounding and gradual underflow once before this parent.
module forecast_meteo_france_physics_setup
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_loc, c_f_pointer, c_intptr_t
  use forecast_meteo_france_physics_state, only: owned_meteo_france_physics_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use physics_configuration_state_port, only: physics_configuration_state
  use forecast_vertical_coordinate_storage, only: native_vertical_state
  use forecast_spherical_grid_setup, only: native_spherical_grid_constants
  use grid_field_configuration_types_port, only: grid_field_configuration
  use yomphy2, only: tphy2
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use atmospheric_physics_parameter_setup_port, only: initialize_atmospheric_physics_parameters
  use surface_exchange_parameter_setup_port, only: initialize_surface_exchange_parameters
  use physics_time_control_setup_port, only: initialize_physics_time_controls, initialize_runtime_physics_time_controls
  use legacy_radiation_parameter_setup_port, only: declare_legacy_radiation_parameters, &
                                                   initialize_legacy_radiation_parameters
  use upper_atmosphere_setup_port, only: admit_upper_atmosphere_setup, &
                                         initialize_top_physics_parameters_raw, initialize_nonorographic_wave_parameters_raw, &
                                         initialize_convective_energy_controls_raw
  use land_surface_reference_setup_port, only: initialize_land_surface_reference_parameters
  use alternative_physics_parameter_setup_port, only: selected_alternative_physics_inputs, &
                                                      initialize_alternative_physics_parameters
  implicit none
  private
  public :: initialize_meteo_france_physics, initialize_runtime_meteo_france_physics
  interface
    function errno_address() bind(c, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Apply the complete selected SUPHMF sequence for nineteen model layers.
  !! STATE is the caller-owned INOUT parameter state. PHYSICS_TIME is the
  !! model owner's unique native TPHY2 INOUT record. Other arguments are IN.
  !! TEXT contains 1:262144 characters and all nine first uppercase groups
  !! must be empty. CONSTANTS and CONTROLS are the produced canonical owners.
  !! CONFIGURATION is the shared seventeen-record physics carrier. VERTICAL
  !! supplies contiguous dimensionless VALH/VBH(0:19); GRID_CONSTANTS supplies
  !! RDELXN in metres. STANDARD_PRESSURE is contiguous real64(1:19) in Pa.
  !! FIELDS supplies the checked one-based YH alias and its live hail flag.
  !! Complete output storage is separate from both outputs and all inputs.
  !! No allocation or whole-record copy occurs. Source-unwritten members,
  !! padding and existing profile owners are preserved. TSPHY starts at one
  !! second; the later time-update routine owns its subsequent value.
  !! Return 0 after success or 2 on refusal. All parent admissions precede
  !! stores. A later child refusal retains its source-ordered prefix; the
  !! owner must discard that unsuccessful setup. STATUS and LAST_STAGE
  !! record the attempted child after admission. Natural FP flags remain,
  !! while errno retains its entry value. Fresh initialization is a separate
  !! production stage and is never supplied by this numerical parent.
  integer(int32) function initialize_meteo_france_physics(state, text, constants, controls, configuration, &
                                                   physics_time, vertical, grid_constants, standard_pressure, fields) result(status)
    type(owned_meteo_france_physics_state), intent(inout), target :: state
    character(len=*), intent(in), target :: text
    type(forecast_physical_constants), intent(in), target :: constants
    type(native_forecast_control_namespace), intent(in), target :: controls
    type(physics_configuration_state), intent(in), target :: configuration
    type(tphy2), intent(inout), target :: physics_time
    type(native_vertical_state), intent(in), target :: vertical
    type(native_spherical_grid_constants), intent(in), target :: grid_constants
    real(real64), intent(in), target :: standard_pressure(:)
    type(grid_field_configuration), intent(in), target :: fields
    status = initialize_setup(state, text, constants, controls, configuration, physics_time, vertical, &
                              grid_constants, standard_pressure, fields, .false.)
  end function

  !> Apply the same ordered setup to a separate live-grid extension.
  !! Arguments, units and ownership match the selected entry. VERTICAL
  !! carries 1:256 layers, VALH/VBH(0:levels) and matching standard pressures.
  !! This runtime extension requires a separate same-input reference proof;
  !! acceptance of the nineteen-layer source does not qualify another grid.
  integer(int32) function initialize_runtime_meteo_france_physics(state, text, constants, controls, configuration, &
                                                   physics_time, vertical, grid_constants, standard_pressure, fields) result(status)
    type(owned_meteo_france_physics_state), intent(inout), target :: state
    character(len=*), intent(in), target :: text
    type(forecast_physical_constants), intent(in), target :: constants
    type(native_forecast_control_namespace), intent(in), target :: controls
    type(physics_configuration_state), intent(in), target :: configuration
    type(tphy2), intent(inout), target :: physics_time
    type(native_vertical_state), intent(in), target :: vertical
    type(native_spherical_grid_constants), intent(in), target :: grid_constants
    real(real64), intent(in), target :: standard_pressure(:)
    type(grid_field_configuration), intent(in), target :: fields
    status = initialize_setup(state, text, constants, controls, configuration, physics_time, vertical, &
                              grid_constants, standard_pressure, fields, .true.)
  end function

  integer(int32) function initialize_setup(state, text, constants, controls, configuration, physics_time, &
                                           vertical, grid_constants, standard_pressure, fields, runtime_grid) result(status)
    type(owned_meteo_france_physics_state), intent(inout), target :: state
    character(len=*), intent(in), target :: text
    type(forecast_physical_constants), intent(in), target :: constants
    type(native_forecast_control_namespace), intent(in), target :: controls
    type(physics_configuration_state), intent(in), target :: configuration
    type(tphy2), intent(inout), target :: physics_time
    type(native_vertical_state), intent(in), target :: vertical
    type(native_spherical_grid_constants), intent(in), target :: grid_constants
    real(real64), intent(in), target :: standard_pressure(:)
    type(grid_field_configuration), intent(in), target :: fields
    logical, intent(in) :: runtime_grid
    character(len=9), parameter :: groups(9) = [character(len=9) :: &
                               'NAMPHY0', 'NAMPHY1', 'NAMVDOZ', 'NAMPHY2', 'NAMPHY3', 'NAMTOPH', 'NAMNORGWD', 'NAMCAPE', 'NAMPARAR']
    integer, parameter :: group_lengths(9) = [7, 7, 7, 7, 7, 7, 9, 7, 8]
    type(selected_alternative_physics_inputs) :: alternative_inputs
    integer(c_intptr_t) :: outputs(2), inputs(10)
    integer(int64) :: output_bytes(2), input_bytes(10)
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: entry_errno
    integer(int32) :: levels, hail_index
    integer :: i, j
    logical, target :: lecmwf
    real(real64), pointer, contiguous :: pressure_view(:)
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (controls%lecmwf /= 1_int32) return
    if (controls%lsforcs < 0_int32 .or. controls%lsforcs > 1_int32) return
    if (constants%initialized /= 1_int32) return
    if (transfer(configuration%arpege_physics%lmse, 0_int32) /= 0_int32) return
    if (transfer(configuration%arpege_physics%lmpa, 0_int32) /= 0_int32) return
    if (transfer(configuration%simplified_physics%lsimph, 0_int32) /= 0_int32) return
    if (transfer(configuration%phy%ledkf, 0_int32) /= 0_int32) return
    if (transfer(configuration%phy%lcvppkf, 0_int32) /= 0_int32) return
    if (transfer(configuration%phy%lrrmes, 0_int32) /= 0_int32) return
    if (.not. canonical_logical(configuration%phy%lsolv)) return
    if (configuration%phy%nbiter < 1_int32 .or. configuration%phy%nbiter > 100_int32) return
    if (.not. canonical_logical(configuration%phy%lrayfm)) return
    if (.not. canonical_logical(configuration%phy%lrayfm15)) return
    if (.not. canonical_logical(configuration%ecmwf_physics%lagphy)) return
    levels = vertical%levels
    if (levels < 1_int32 .or. levels > 256_int32) return
    if (.not. runtime_grid .and. levels /= 19_int32) return
    if (.not. allocated(vertical%valh)) return
    if (.not. allocated(vertical%vbh)) return
    if (lbound(vertical%valh, 1) /= 0 .or. ubound(vertical%valh, 1) /= levels) return
    if (lbound(vertical%vbh, 1) /= 0 .or. ubound(vertical%vbh, 1) /= levels) return
    if (.not. is_contiguous(standard_pressure)) return
    if (size(standard_pressure, kind=int64) /= int(levels, int64)) return
    hail_index = fields%aliases%yh
    if (hail_index < 1_int32 .or. hail_index > size(fields%components)) return
    if (fields%components(hail_index)%lactive < 0_int32 .or. fields%components(hail_index)%lactive > 1_int32) return
    outputs = [transfer(c_loc(state), 0_c_intptr_t), transfer(c_loc(physics_time), 0_c_intptr_t)]
    output_bytes = [storage_size(state, kind=int64)/8_int64, storage_size(physics_time, kind=int64)/8_int64]
    inputs = [transfer(c_loc(text), 0_c_intptr_t), transfer(c_loc(constants), 0_c_intptr_t), &
              transfer(c_loc(controls), 0_c_intptr_t), transfer(c_loc(configuration), 0_c_intptr_t), &
              transfer(c_loc(vertical), 0_c_intptr_t), transfer(c_loc(grid_constants), 0_c_intptr_t), &
              transfer(c_loc(standard_pressure), 0_c_intptr_t), transfer(c_loc(fields), 0_c_intptr_t), &
              transfer(c_loc(vertical%valh), 0_c_intptr_t), transfer(c_loc(vertical%vbh), 0_c_intptr_t)]
    input_bytes = [int(len(text), int64), storage_size(constants, kind=int64)/8_int64, &
                   storage_size(controls, kind=int64)/8_int64, storage_size(configuration, kind=int64)/8_int64, &
                   storage_size(vertical, kind=int64)/8_int64, storage_size(grid_constants, kind=int64)/8_int64, &
                   8_int64*int(levels, int64), storage_size(fields, kind=int64)/8_int64, &
                   8_int64*(int(levels, int64) + 1_int64), 8_int64*(int(levels, int64) + 1_int64)]
    if (.not. disjoint(outputs(1), output_bytes(1), outputs(2), output_bytes(2))) return
    do i = 1, 2
      do j = 1, 10
        if (.not. disjoint(outputs(i), output_bytes(i), inputs(j), input_bytes(j))) return
      end do
    end do
    lecmwf = .true.
    status = admit_upper_atmosphere_setup(text, state%top_atmosphere_parameters, &
                                         state%nonorographic_wave_parameters, state%convective_energy_controls, standard_pressure, &
                                          vertical%valh, vertical%vbh, configuration%phy%nbiter, configuration%phy%lrrmes, &
                                          configuration%ecmwf_physics%lagphy, lecmwf)
    if (status /= 0_int32) return
    do i = 1, 9
      status = require_empty_physics_group(text, groups(i) (1:group_lengths(i)))
      if (status /= 0_int32) return
    end do
    alternative_inputs%lmse = configuration%arpege_physics%lmse
    alternative_inputs%lmpa = configuration%arpege_physics%lmpa
    alternative_inputs%lrayfm = configuration%phy%lrayfm
    alternative_inputs%lrayfm15 = configuration%phy%lrayfm15
    alternative_inputs%hail_active = fields%components(hail_index)%lactive == 1_int32
    alternative_inputs%nundefld = controls%nundefld
    alternative_inputs%lsforcs = controls%lsforcs == 1_int32
    ! The checked contiguous view borrows its target without making a copy.
    pressure_view => standard_pressure
    call c_f_pointer(errno_address(), error_number)
    entry_errno = error_number
    state%setup_complete = .false.
    state%last_stage = 0_int32
    status = declare_legacy_radiation_parameters(state%legacy_radiation_parameters)
    if (status == 0_int32) then
      state%last_stage = 1_int32
      status = initialize_atmospheric_physics_parameters(text, state%atmospheric_parameters, &
                                                         configuration%phy, constants%romega, grid_constants%rdelxn, &
                                                         configuration%simplified_physics%lsimph, lecmwf)
    end if
    if (status == 0_int32) then
      state%last_stage = 2_int32
      status = initialize_surface_exchange_parameters(text, constants, state%surface_exchange_parameters, &
                                                      state%ozone_deposition_parameters)
    end if
    if (status == 0_int32) then
      state%last_stage = 3_int32
      if (runtime_grid) then
        status = initialize_runtime_physics_time_controls(text, physics_time, vertical%valh, vertical%vbh, lecmwf)
      else
        status = initialize_physics_time_controls(text, physics_time, vertical%valh, vertical%vbh, lecmwf)
      end if
    end if
    if (status == 0_int32) then
      state%last_stage = 4_int32
      status = initialize_legacy_radiation_parameters(text, state%legacy_radiation_parameters, configuration%phy)
    end if
    if (status == 0_int32) then
      state%last_stage = 5_int32
      call initialize_top_physics_parameters_raw(state%top_atmosphere_parameters, pressure_view)
      state%last_stage = 6_int32
      call initialize_nonorographic_wave_parameters_raw(state%nonorographic_wave_parameters, pressure_view)
      state%last_stage = 7_int32
      status = initialize_land_surface_reference_parameters(state%land_reference_parameters, configuration%phy%lsolv)
    end if
    if (status == 0_int32) then
      state%last_stage = 8_int32
      call initialize_convective_energy_controls_raw(state%convective_energy_controls, &
                                                     vertical%valh, vertical%vbh, configuration%phy%nbiter)
      state%last_stage = 9_int32
      status = initialize_alternative_physics_parameters(text, state%alternative_parameters, alternative_inputs)
    end if
    state%status = status
    state%setup_complete = status == 0_int32
    error_number = entry_errno
  end function

  logical function canonical_logical(value) result(valid)
    logical, intent(in) :: value
    integer(int32) :: word
    word = transfer(value, 0_int32)
    valid = word == 0_int32 .or. word == 1_int32
  end function

  logical function disjoint(left, left_bytes, right, right_bytes) result(valid)
    integer(c_intptr_t), intent(in) :: left, right
    integer(int64), intent(in) :: left_bytes, right_bytes
    valid = .false.
    if (left <= 0_c_intptr_t .or. right <= 0_c_intptr_t) return
    if (left_bytes < 0_int64 .or. right_bytes < 0_int64) return
    if (left > huge(left) - left_bytes .or. right > huge(right) - right_bytes) return
    valid = left + left_bytes <= right .or. right + right_bytes <= left
  end function
end module forecast_meteo_france_physics_setup
