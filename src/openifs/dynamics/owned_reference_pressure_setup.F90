!> Own the complete selected reference-pressure controls and seven arrays.
!! The accepted native pressure child retains every hydrostatic calculation.
module md2asm_owned_reference_pressure_setup
  use iso_fortran_env, only: int32, int64, real64
  use forecast_reference_pressure_coefficients, only: reference_atmosphere_values, &
                                                      initialize_reference_atmosphere_values, initialize_reference_pressure_arrays
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use md2asm_semi_implicit_mode_storage, only: semi_implicit_environment_supported
  implicit none
  private
  public :: reference_pressure_setup_controls, owned_reference_pressure_state
  public :: initialize_owned_reference_atmosphere, allocate_owned_reference_pressure
  public :: initialize_owned_reference_pressure, release_owned_reference_pressure
  public :: bind_reference_pressure_coefficients
  type :: reference_pressure_setup_controls
    integer(int32) :: configuration_number = 0, number_steps = 0
    logical :: ecmwf = .false., two_dimensional = .false., three_dimensional = .false.
    logical :: hydrostatic = .false., semi_lagrangian = .false., two_time_levels = .false.
    logical :: limited_area = .false.
  end type
  !> Native names retain their exact source meaning.
  !! SIPR and SITLAH/SITLAF use Pa; SITR/SITRA use K; SIRPRG and SIDPHI
  !! use J/kg. SIRPRN and SIRDEL use1/Pa. SIDELP uses Pa. SIALPH,SILNPR
  !! and VNORM have no unit. All arrays are owned; borrowed aliases must end
  !! before release. source_rd and lifecycle flags describe the native owner.
  type :: owned_reference_pressure_state
    real(real64) :: sipr = 0.0_real64, sitr = 0.0_real64, sitra = 0.0_real64
    real(real64) :: sirprg = 0.0_real64, sirprn = 0.0_real64, vnorm = 0.0_real64
    integer(int32) :: nopt_sitra = 0
    logical :: lsidg = .false., lesidg = .false.
    real(real64), allocatable :: sialph(:), silnpr(:), sidelp(:), sirdel(:)
    real(real64), allocatable :: sitlah(:), sitlaf(:), sidphi(:)
    real(real64) :: source_rd = 0.0_real64
    logical :: controls_initialized = .false., arrays_initialized = .false.
  end type
contains
  !> Set selected global hydrostatic2TL controls from actual native inputs.
  !! levels is1:255; first_half_a is original VAH(1) in Pa, supplied by the
  !! initialized vertical owner. dry_gas_constant is J/(kg K); stretch has no
  !! unit. The accepted scalar producer owns all arithmetic and thresholds.
  !! Refusal2 preserves state. Success0 writes only named scalar members.
  subroutine initialize_owned_reference_atmosphere(levels, control, first_half_a, finite_elements, &
                                                   stretch, dry_gas_constant, state, status)
    integer(int32), intent(in) :: levels
    type(reference_pressure_setup_controls), intent(in) :: control
    real(real64), intent(in) :: first_half_a, stretch, dry_gas_constant
    logical, intent(in) :: finite_elements
    type(owned_reference_pressure_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    type(reference_atmosphere_values) :: values
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (.not. semi_implicit_environment_supported()) return
    if (control%configuration_number /= 1 .or. control%number_steps <= 0) return
    if (.not. control%ecmwf .or. control%two_dimensional .or. .not. control%three_dimensional) return
    if (.not. control%hydrostatic .or. .not. control%semi_lagrangian .or. .not. control%two_time_levels) return
    if (control%limited_area) return
    call scalar_values_from_state(state, values)
    status = initialize_reference_atmosphere_values(first_half_a, merge(1_int32, 0_int32, finite_elements), &
                                                    stretch, dry_gas_constant, values)
    if (status /= 0) return
    state%sipr = values%pressure
    state%sitr = values%temperature
    state%sitra = values%auxiliary_temperature
    state%sirprg = values%gas_temperature
    state%sirprn = values%inverse_pressure
    state%vnorm = values%normalisation
    state%nopt_sitra = values%temperature_option
    state%lsidg = values%stretched_grid /= 0
    state%lesidg = values%limited_area /= 0
    state%source_rd = dry_gas_constant
    state%controls_initialized = .true.
    state%arrays_initialized = .false.
  end subroutine

  !> Allocate seven arrays in source order without writing payload values.
  !! All incoming owners must be absent. Allocation failure1 frees private
  !! owners in reverse order and leaves state unchanged; invalid input returns2.
  subroutine allocate_owned_reference_pressure(levels, state, status)
    integer(int32), intent(in) :: levels
    type(owned_reference_pressure_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    type(owned_reference_pressure_state) :: pending
    integer :: code
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (.not. semi_implicit_environment_supported()) return
    if (allocated(state%sialph) .or. allocated(state%silnpr) .or. allocated(state%sidelp)) return
    if (allocated(state%sirdel) .or. allocated(state%sitlah) .or. allocated(state%sitlaf)) return
    if (allocated(state%sidphi)) return
    status = 1
    allocate (pending%sialph(levels), stat=code)
    if (code /= 0) return
    allocate (pending%silnpr(levels), stat=code)
    if (code /= 0) then
      call release_owned_reference_pressure(pending)
      return
    end if
    allocate (pending%sidelp(levels), stat=code)
    if (code /= 0) then
      call release_owned_reference_pressure(pending)
      return
    end if
    allocate (pending%sirdel(levels), stat=code)
    if (code /= 0) then
      call release_owned_reference_pressure(pending)
      return
    end if
    allocate (pending%sitlah(0:levels), stat=code)
    if (code /= 0) then
      call release_owned_reference_pressure(pending)
      return
    end if
    allocate (pending%sitlaf(levels), stat=code)
    if (code /= 0) then
      call release_owned_reference_pressure(pending)
      return
    end if
    allocate (pending%sidphi(levels), stat=code)
    if (code /= 0) then
      call release_owned_reference_pressure(pending)
      return
    end if
    call move_alloc(pending%sialph, state%sialph)
    call move_alloc(pending%silnpr, state%silnpr)
    call move_alloc(pending%sidelp, state%sidelp)
    call move_alloc(pending%sirdel, state%sirdel)
    call move_alloc(pending%sitlah, state%sitlah)
    call move_alloc(pending%sitlaf, state%sitlaf)
    call move_alloc(pending%sidphi, state%sidphi)
    state%arrays_initialized = .false.
    status = 0
  end subroutine

  !> Fill SIALPH,SILNPR,SIDELP,SIRDEL,SITLAH,SITLAF,SIDPHI through the accepted child.
  !! half_a/b have bounds0:levels. VC/full/delta inputs have bounds1:levels.
  !! They are borrowed, unchanged native vertical arrays. pressure_controls
  !! must contain the same RD used for the scalar control stage. The child
  !! privately adapts its accepted pressure interface; this caller adds no
  !! numerical method. Successful publication sets arrays_initialized true.
  subroutine initialize_owned_reference_pressure(levels, pressure_controls, half_a, half_b, &
                                                 vc, full_a, full_b, delta_a, delta_b, state, status)
    integer(int32), intent(in) :: levels
    type(hybrid_pressure_controls), intent(in) :: pressure_controls
    real(real64), intent(in) :: half_a(0:), half_b(0:)
    real(real64), intent(in) :: vc(:), full_a(:), full_b(:), delta_a(:), delta_b(:)
    type(owned_reference_pressure_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    type(reference_atmosphere_values) :: values
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (.not. semi_implicit_environment_supported()) return
    if (.not. state%controls_initialized) return
    if (pressure_controls%dry_gas_constant /= state%source_rd) return
    if (.not. reference_arrays_have_shape(state, levels)) return
    if (size(half_a) < levels + 1 .or. size(half_b) < levels + 1) return
    if (size(vc) < levels .or. size(full_a) < levels .or. size(full_b) < levels) return
    if (size(delta_a) < levels .or. size(delta_b) < levels) return
    if (.not. is_contiguous(half_a) .or. .not. is_contiguous(half_b)) return
    if (.not. is_contiguous(vc) .or. .not. is_contiguous(full_a) .or. .not. is_contiguous(full_b)) return
    if (.not. is_contiguous(delta_a) .or. .not. is_contiguous(delta_b)) return
    call scalar_values_from_state(state, values)
    call initialize_reference_pressure_arrays(levels, pressure_controls, values, &
                                             half_a(0:levels), half_b(0:levels), vc(1:levels), full_a(1:levels), full_b(1:levels), &
                                     delta_a(1:levels), delta_b(1:levels), state%sialph, state%silnpr, state%sidelp, state%sirdel, &
                                              state%sitlah, state%sitlaf, state%sidphi, status)
    if (status == 0) state%arrays_initialized = .true.
  end subroutine

  !> Bind initialized reference arrays into the existing native spectral record.
  !! state and vertical_metric are TARGET owners and must outlive all aliases.
  !! vertical_metric is the actual VFE_RDETAH array. kappa is actual RD/CP.
  !! This entry copies scalars and pointers only; it supplies no calculation.
  !! It leaves time factors, stretch, modes and Laplacian members unchanged.
  subroutine bind_reference_pressure_coefficients(state, vertical_metric, kappa, coef, status)
    type(owned_reference_pressure_state), target, intent(inout) :: state
    real(real64), target, intent(in) :: vertical_metric(:)
    real(real64), intent(in) :: kappa
    type(spectral_implicit_coefficients), intent(inout) :: coef
    integer(int32), intent(out) :: status
    integer :: n
    status = 2
    if (.not. state%controls_initialized .or. .not. state%arrays_initialized) return
    if (.not. allocated(state%sialph)) return
    n = size(state%sialph)
    if (.not. reference_arrays_have_shape(state, n)) return
    if (size(vertical_metric) < n .or. .not. is_contiguous(vertical_metric)) return
    coef%rd = state%source_rd
    coef%kappa = kappa
    coef%geopotential_surface = state%sirprg
    coef%thermal_coefficient = state%sitr
    coef%pressure_rate_coefficient = state%sirprn
    coef%alpha => state%sialph
    coef%delta => state%silnpr
    coef%accumulation_weight => state%sidelp
    coef%mean_weight => state%sirdel
    coef%full_level_weight => state%sitlaf
    coef%metric => vertical_metric(1:n)
    status = 0
  end subroutine

  !> Release seven arrays in reverse source order, retaining scalar controls.
  !! Every borrowed alias must be retired first. Repeated release is quiet.
  subroutine release_owned_reference_pressure(state)
    type(owned_reference_pressure_state), intent(inout) :: state
    if (allocated(state%sidphi)) deallocate (state%sidphi)
    if (allocated(state%sitlaf)) deallocate (state%sitlaf)
    if (allocated(state%sitlah)) deallocate (state%sitlah)
    if (allocated(state%sirdel)) deallocate (state%sirdel)
    if (allocated(state%sidelp)) deallocate (state%sidelp)
    if (allocated(state%silnpr)) deallocate (state%silnpr)
    if (allocated(state%sialph)) deallocate (state%sialph)
    state%arrays_initialized = .false.
  end subroutine

  subroutine scalar_values_from_state(state, values)
    type(owned_reference_pressure_state), intent(in) :: state
    type(reference_atmosphere_values), intent(out) :: values
    values%pressure = state%sipr
    values%temperature = state%sitr
    values%auxiliary_temperature = state%sitra
    values%gas_temperature = state%sirprg
    values%inverse_pressure = state%sirprn
    values%normalisation = state%vnorm
    values%temperature_option = state%nopt_sitra
    values%stretched_grid = merge(1_int32, 0_int32, state%lsidg)
    values%limited_area = merge(1_int32, 0_int32, state%lesidg)
  end subroutine

  logical function reference_arrays_have_shape(state, n) result(ok)
    type(owned_reference_pressure_state), intent(in) :: state
    integer, intent(in) :: n
    ok = .false.
    if (n < 1 .or. n > 255) return
    if (.not. allocated(state%sialph) .or. .not. allocated(state%silnpr)) return
    if (.not. allocated(state%sidelp) .or. .not. allocated(state%sirdel)) return
    if (.not. allocated(state%sitlah) .or. .not. allocated(state%sitlaf) .or. .not. allocated(state%sidphi)) return
    if (size(state%sialph) /= n .or. size(state%silnpr) /= n .or. size(state%sidelp) /= n) return
    if (size(state%sirdel) /= n .or. size(state%sitlaf) /= n .or. size(state%sidphi) /= n) return
    if (lbound(state%sitlah, 1) /= 0 .or. ubound(state%sitlah, 1) /= n) return
    ok = .true.
  end function
end module
