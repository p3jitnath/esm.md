!> Produce the owned reference, modes, diffusion and pressure state for SPCM.
!! This is a setup calculation over the actual configured native model.
!! No matrix, eigenvalue or reference-pressure array is a caller input.
module forecast_spectral_setup_state
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08, only: MPI_Comm, MPI_Initialized, MPI_SUCCESS
  use forecast_operational_model_types, only: native_operational_model_configuration
  use spectral_field_storage_port, only: spectral_field_state
  use forecast_spectral_calculation_driver, only: native_spectral_calculation_context, native_spectral_calculation_fields
  use forecast_implicit_time_weights, only: native_implicit_time_weight_state
  use forecast_runtime_dry_mass_reference, only: native_dry_mass_reference
  use forecast_reference_temperature_children, only: native_reference_temperature_correction, &
    allocate_reference_temperature_correction, initialize_reference_temperature_correction, release_reference_temperature_correction
  use forecast_spectral_diffusion_setup, only: native_spectral_diffusion_state, initialize_spectral_diffusion_controls, &
                  allocate_spectral_diffusion_storage, calculate_spectral_diffusion_coefficients, release_spectral_diffusion_storage
  use forecast_spectral_horizontal_diffusion, only: native_horizontal_diffusion_switches
  use md2asm_owned_reference_pressure_setup, only: reference_pressure_setup_controls, owned_reference_pressure_state, &
                    initialize_owned_reference_atmosphere, allocate_owned_reference_pressure, initialize_owned_reference_pressure, &
                                                   release_owned_reference_pressure, bind_reference_pressure_coefficients
  use md2asm_semi_implicit_mode_storage, only: semi_implicit_mode_state
  use md2asm_semi_implicit_mode_setup, only: semi_implicit_mode_controls
  use md2asm_runtime_semi_implicit_modes, only: allocate_runtime_semi_implicit_modes, &
                                                initialize_runtime_semi_implicit_modes, release_runtime_semi_implicit_modes
  use md2asm_native_geometry_pressure_context, only: initialize_native_geometry_pressure_context
  use md2asm_distributed_pressure_stage, only: spectral_pressure_context
  use md2asm_spectral_transposes, only: agree_spectral_partition_status
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls
  use yomhook, only: lhook
  implicit none
  private
  public :: native_spectral_setup_sources, native_spectral_calculation_state
  public :: initialize_native_spectral_calculation_state, release_native_spectral_calculation_state
  public :: bind_native_spectral_calculation_fields
  public :: initialize_native_spectral_calculation_owners, bind_native_spectral_calculation_sources

  !> Borrow actual source scalar targets and readonly source switches.
  !! Physical scalar values come directly from the actual atmosphere and
  !! dynamical-configuration owners. READY belongs to this readonly flag join.
  !! The diffusion record retains the actual named SPCHOR switches.
  type :: native_spectral_setup_sources
    logical :: limpf, lmascor, lgpmascor
    integer(int32) :: ncurrent_iter, nsiter
    type(native_horizontal_diffusion_switches) :: diffusion_switches
    logical :: ready = .false.
  end type

  !> Own all mathematical setup arrays at one final TARGET address.
  !! Reference arrays use Pa,K,J/kg and their documented inverse units.
  !! Mode eigenvalues use m**2/s**2; mode matrices are dimensionless.
  !! Diffusion rates use1/s; RCORDIT uses K. Pressure owns copied maps/modes.
  !! MODEL,its geometry,the source scalar targets and MASS remain borrowed.
  !! Do not assign,move or reallocate this enclosing object while aliases live.
  !! Release retires aliases before freeing owners;it does not release MODEL,
  !! the public transform/MPI context,the shared MASS or the spectral fields.
  type :: native_spectral_calculation_state
    type(owned_reference_pressure_state) :: reference
    type(semi_implicit_mode_state) :: modes
    type(native_spectral_diffusion_state) :: diffusion
    type(native_reference_temperature_correction) :: reference_temperature
    type(spectral_pressure_context) :: pressure
    type(native_spectral_calculation_context) :: context
    type(native_spectral_calculation_fields) :: fields
    type(native_operational_model_configuration), pointer :: model => null()
    logical :: ready = .false., fields_bound = .false.
  end type
contains
  !> Calculate the genuine setup from the configured model and live grid.
  !! STATE and all borrowed owners stay at their final addresses until release.
  !! IMPLICIT_WEIGHTS is the real SUDYN RBT/RBTS2 producer. BUDGET is bytes.
  !! Current TDT is seconds. Every local child status is agreed before a later
  !! distributed stage. Status0 completes setup;1/2/3 retain child meanings.
  !! Failure releases only this factory's reached owner prefix.
  subroutine initialize_native_spectral_calculation_state(state, model, mass, implicit_weights, sources, comm, budget, status)
    type(native_spectral_calculation_state), target, intent(inout) :: state
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_dry_mass_reference), target, intent(inout) :: mass
    type(native_implicit_time_weight_state), intent(in) :: implicit_weights
    type(native_spectral_setup_sources), intent(in) :: sources
    type(MPI_Comm), intent(in) :: comm
    integer(int64), intent(in) :: budget
    integer(int32), intent(out) :: status
    integer(int32) :: local_status
    integer :: error
    logical :: active
    status = 2_int32
    call MPI_Initialized(active, error)
    if (error /= MPI_SUCCESS .or. .not. active) return
    local_status = 2_int32
    if (sources%ready) then
      if (sources%limpf .and. sources%ncurrent_iter >= 0 .and. sources%nsiter >= sources%ncurrent_iter) local_status = 0_int32
    end if
    call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return
    call initialize_native_spectral_calculation_owners(state, model, mass, implicit_weights, comm, budget, status)
    if (status /= 0) return
    call bind_native_spectral_calculation_sources(state, sources, status)
    if (status /= 0) call release_native_spectral_calculation_state(state)
  end subroutine

  !> Publish produced switches after SUNHD and the real STOPH producer finish.
  !! STATE already owns all numerical setup arrays. SOURCES contains only
  !! actual produced control values. Refusal preserves the existing context.
  !! No numerical calculation or weather field is repeated by this binding.
  subroutine bind_native_spectral_calculation_sources(state, sources, status)
    type(native_spectral_calculation_state), target, intent(inout) :: state
    type(native_spectral_setup_sources), intent(in) :: sources
    integer(int32), intent(out) :: status
    integer(int32) :: local_status
    logical :: call_coriolis
    status = 2_int32
    if (.not. state%ready .or. .not. associated(state%model)) return
    if (state%context%ready) return
    local_status = 2_int32
    admission: block
      if (.not. sources%ready) exit admission
      if (.not. sources%limpf) exit admission
      if (sources%ncurrent_iter < 0 .or. sources%nsiter < sources%ncurrent_iter) exit admission
      if (state%model%lrsiddh .or. state%model%dynamics%lnhdyn .or. state%model%dynamics%lnhx) exit admission
      if (state%model%dynamics%lnhee .or. (state%model%dynamics%lnhqe .and. .not. state%model%dynamics%lnhqe_sihyd)) exit admission
      local_status = 0_int32
    end block admission
    call agree_spectral_partition_status(state%context%communicator, local_status, status)
    if (status /= 0) return
    state%context%ncurrent_iter = sources%ncurrent_iter; state%context%nsiter = sources%nsiter
    state%context%diffusion_switches = sources%diffusion_switches
    state%context%diffusion_switches%lm0damp = state%diffusion%lm0damp
    state%context%limpf = sources%limpf
    state%context%lmascor = sources%lmascor; state%context%lgpmascor = sources%lgpmascor
    call_coriolis = sources%limpf .and. .not. (state%model%dynamics%lnhee .and. .not. state%model%dynamics%lsi_nhee)
    state%context%implicit_control%coupled_rotation = call_coriolis
    state%context%implicit_control%single_wave = .not. call_coriolis
    state%context%ready = .true.
    status = 0_int32
  end subroutine

  !> Build the real arrays before source switches that depend on SUNHD exist.
  !! STATE%READY means that these owned arrays are complete. CONTEXT%READY
  !! remains false until bind_native_spectral_calculation_sources succeeds.
  !! This entry never reads the caller's later STOPH or diffusion switches.
  subroutine initialize_native_spectral_calculation_owners(state, model, mass, implicit_weights, comm, budget, status)
    type(native_spectral_calculation_state), target, intent(inout) :: state
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_dry_mass_reference), target, intent(inout) :: mass
    type(native_implicit_time_weight_state), intent(in) :: implicit_weights
    type(MPI_Comm), intent(in) :: comm
    integer(int64), intent(in) :: budget
    integer(int32), intent(out) :: status
    type(reference_pressure_setup_controls) :: reference_control
    type(hybrid_pressure_controls) :: pressure_control
    type(semi_implicit_mode_controls) :: mode_control
    integer(int32) :: local_status, l, ll, n, rows, longitudes, nspectral, j, ignored, ierr, v
    logical :: initialized, finite_elements, empty_tracer_switches(4)
    real(real64) :: stretch, dt
    status = 2_int32
    call MPI_Initialized(initialized, ierr)
    if (ierr /= MPI_SUCCESS .or. .not. initialized) return
    local_status = 2_int32
    admission: block
      if (state%ready .or. associated(state%model)) exit admission
      if (allocated(state%reference%sialph) .or. allocated(state%modes%eigenvalues)) exit admission
      if (allocated(state%diffusion%rdivor) .or. allocated(state%reference_temperature%rcordit)) exit admission
      if (.not. model%ready .or. .not. associated(model%initial)) exit admission
      if (.not. model%initial%ready .or. .not. allocated(model%initial%geometry)) exit admission
      if (.not. model%initial%geometry%initialized) exit admission
      if (.not. associated(model%initial%geometry%vertical)) exit admission
      if (.not. implicit_weights%ready) exit admission
      if (size(model%initial%geometry%atmosphere%reference_tables) < 1) exit admission
      if (size(model%initial%geometry%atmosphere%reference_tables(1)%gradient) < 1) exit admission
      if (size(model%initial%geometry%atmosphere%reference_tables(1)%temperature) < 2) exit admission
      if (transfer(lhook, 0_int32) /= 0) exit admission
      if (budget < 1_int64 .or. budget > 2_int64**36) exit admission
      l = model%initial%geometry%dimensions%nflevg
      ll = model%initial%geometry%partition%nflevl
      n = model%initial%geometry%dimensions%nsmax
      rows = model%initial%geometry%dimensions%ndglg
      longitudes = model%initial%geometry%dimensions%ndlon
      nspectral = model%fields%registration%numspflds
      if (l < 1 .or. l > 255 .or. ll < 0 .or. ll > l .or. n < 21 .or. n > 4096) exit admission
      if (nspectral /= 0) exit admission
      if (.not. allocated(model%initial%geometry%partition%mylevs)) exit admission
      if (size(model%initial%geometry%partition%mylevs) /= ll) exit admission
      if (.not. allocated(model%initial%geometry%partition%nprocm)) exit admission
      if (lbound(model%initial%geometry%partition%nprocm, 1) > 0) exit admission
      if (ubound(model%initial%geometry%partition%nprocm, 1) < 0) exit admission
      associate (vertical => model%initial%geometry%vertical)
        if (.not. allocated(vertical%vah) .or. .not. allocated(vertical%vbh)) exit admission
        if (.not. allocated(vertical%vc) .or. .not. allocated(vertical%vdelb)) exit admission
        if (.not. allocated(vertical%vaf) .or. .not. allocated(vertical%vbf) .or. .not. allocated(vertical%vdela)) exit admission
        if (.not. allocated(vertical%vfe_rdetah) .or. .not. allocated(vertical%rintbf11)) exit admission
        if (vertical%configuration%lvertfe /= 1 .or. vertical%configuration%nvfe_intbc /= 3) exit admission
        if (size(vertical%vah) /= l + 1 .or. size(vertical%vbh) /= l + 1) exit admission
        if (lbound(vertical%vah, 1) /= 0 .or. lbound(vertical%vbh, 1) /= 0) exit admission
      end associate
      if (model%lrsiddh .or. model%dynamics%lnhdyn .or. model%dynamics%lnhx) exit admission
      if (model%dynamics%lnhee .or. (model%dynamics%lnhqe .and. .not. model%dynamics%lnhqe_sihyd)) exit admission
      local_status = 0_int32
    end block admission
    call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return
    state%model => model
    associate (initial => model%initial, geometry => model%initial%geometry, vertical => model%initial%geometry%vertical)
      stretch = geometry%configuration%values%rstret
      finite_elements = vertical%configuration%lvertfe /= 0
      dt = initial%controls%clock%integration%second_dt
      reference_control%configuration_number = initial%controls%namespace%nconf
      reference_control%number_steps = initial%controls%clock%total_steps
      reference_control%ecmwf = initial%controls%namespace%lecmwf /= 0
      reference_control%two_dimensional = initial%controls%namespace%lr2d /= 0
      reference_control%three_dimensional = initial%controls%namespace%lr3d /= 0
      reference_control%hydrostatic = .not. model%dynamics%lnhdyn
      reference_control%semi_lagrangian = model%dynamics%lslag
      reference_control%two_time_levels = model%dynamics%ltwotl
      reference_control%limited_area = initial%controls%namespace%lelam /= 0
      call initialize_owned_reference_atmosphere(l, reference_control, vertical%vah(1), finite_elements, &
                                                 stretch, initial%constants%rd, state%reference, status)
      call agree_child()
      if (status /= 0) goto900
      call allocate_owned_reference_pressure(l, state%reference, status)
      call agree_child()
      if (status /= 0) goto900
      pressure_control%approximate_mode = vertical%configuration%ndlnpr
      pressure_control%finite_elements = finite_elements
      pressure_control%arithmetic_full_pressure = vertical%configuration%laprxpk /= 0
      pressure_control%top_alpha = vertical%configuration%rhydr0
      pressure_control%top_pressure = vertical%toppres
      pressure_control%dry_gas_constant = initial%constants%rd
      pressure_control%dry_isochoric_heat_capacity = initial%constants%rcvd
      call initialize_owned_reference_pressure(l, pressure_control, vertical%vah, vertical%vbh, vertical%vc, &
                                               vertical%vaf, vertical%vbf, vertical%vdela, vertical%vdelb, state%reference, status)
      call agree_child()
      if (status /= 0) goto900
      call bind_reference_pressure_coefficients(state%reference, vertical%vfe_rdetah, initial%constants%rkappa, &
                                                state%context%implicit_coefficients, status)
      call agree_child()
      if (status /= 0) goto900
      state%context%implicit_coefficients%implicit_coefficient = implicit_weights%rbts2
      state%context%implicit_coefficients%time_coefficient = dt
      state%context%implicit_coefficients%stretch = stretch
      state%context%vertical_matrices%rintbf11 => vertical%rintbf11
      mode_control%finite_elements = finite_elements
      mode_control%integral_bc = vertical%configuration%nvfe_intbc
      mode_control%derivative_bc = vertical%configuration%nvfe_derbc
      mode_control%stability_modification = vertical%configuration%ldyn_analysis_stability /= 0
      mode_control%diagonal_implicit = state%reference%lsidg
      mode_control%extended_diagonal = state%reference%lesidg
      mode_control%reference_pressure = state%reference%sipr
      mode_control%normalization = state%reference%vnorm
      call allocate_runtime_semi_implicit_modes(l, budget, state%modes, status)
      call agree_child()
      if (status /= 0) goto900
      call initialize_runtime_semi_implicit_modes(mode_control, state%context%implicit_coefficients, &
                                           state%context%vertical_matrices, geometry%dimensions%nproma, budget, state%modes, status)
      call agree_child()
      if (status /= 0) goto900
      call initialize_native_geometry_pressure_context(geometry, state%modes, dt, implicit_weights%rbts2, stretch, &
                                                       initial%constants%romega, budget,.not. lhook, state%pressure, status)
      call agree_child()
      if (status /= 0) goto900
      ! NUMSPFLDS=0 proves that all spectral-tracer selector loops are empty.
      ! The four excluded tracer switches therefore describe an empty set.
      do j = 1, 4
        empty_tracer_switches(j) = nspectral > 0
      end do
      status = initialize_spectral_diffusion_controls(state%diffusion, model%dynamics, l, ll, n, rows, longitudes, &
                    geometry%partition%mylevs, vertical%vah, initial%constants%rhour, vertical%vp00, model%dynamical_core%rplradi, &
                                                      nspectral, empty_tracer_switches, runtime=.true.)
      call agree_child()
      if (status /= 0) goto900
      status = allocate_spectral_diffusion_storage(state%diffusion, model%dynamics, l, ll, n, rows, longitudes, &
                     geometry%partition%mylevs, vertical%vah, nspectral, empty_tracer_switches, runtime=.true., half_b=vertical%vbh)
      call agree_child()
      if (status /= 0) goto900
      status = calculate_spectral_diffusion_coefficients(state%diffusion, model%dynamics, l, ll, n, rows, longitudes, &
                    geometry%partition%mylevs, vertical%vah, initial%constants%rhour, vertical%vp00, model%dynamical_core%rplradi, &
                 initial%controls%clock%integration%first_dt, nspectral, empty_tracer_switches, runtime=.true., half_b=vertical%vbh)
      call agree_child()
      if (status /= 0) goto900
      status = allocate_reference_temperature_correction(state%reference_temperature, l)
      call agree_child()
      if (status /= 0) goto900
      status = initialize_reference_temperature_correction(state%reference_temperature, l, initial%constants%rd, &
                                         initial%constants%rg, vertical%vp00, geometry%atmosphere%reference_tables(1)%gradient(1), &
        geometry%atmosphere%reference_tables(1)%temperature(1),geometry%atmosphere%reference_tables(1)%temperature(2),vertical%vah,vertical%vbh)
      call agree_child()
      if (status /= 0) goto900
      state%context%pressure => state%pressure
      state%context%mass => mass
      state%context%diffusion => state%diffusion
      state%context%rcordit => state%reference_temperature%rcordit
      state%context%communicator = comm
      state%context%myms => geometry%laplacian%myms
      state%context%nasm0 => geometry%laplacian%nasm0
      state%context%nvalue => geometry%laplacian%nvalue
      state%context%nptrsv => geometry%partition%nptrsv
      state%context%implicit_coefficients%simi => state%modes%inverse_modes
      state%context%implicit_coefficients%simo => state%modes%modes
      state%context%implicit_coefficients%laplacian(0:n) => geometry%laplacian%rlapdi(0:n)
      v = state%pressure%layout%vertical_index
      state%context%level_offset = state%pressure%layout%level_start(v) - 1
      state%context%zero_wave_horizontal_owner = geometry%partition%nprocm(0)
      state%context%vertical_chunk = geometry%dimensions%nproma
      state%context%temporary_bytes_budget = budget
      state%context%lr3d = reference_control%three_dimensional
      state%context%lsidg = state%reference%lsidg
      state%context%lnhdyn = model%dynamics%lnhdyn; state%context%lnhx = model%dynamics%lnhx
      state%context%lnhee = model%dynamics%lnhee; state%context%lsi_nhee = model%dynamics%lsi_nhee
      state%context%lnhqe = model%dynamics%lnhqe; state%context%lnhqe_sihyd = model%dynamics%lnhqe_sihyd
      state%context%lgradsp = model%dynamics%lgradsp; state%context%lrsiddh = model%lrsiddh
      associate (control => state%context%implicit_control)
        control%global_levels = l; control%local_levels = ll; control%columns = state%pressure%layout%local_columns
        control%full_columns = geometry%partition%nspec2vf
        control%degree = n; control%first_column = 1; control%last_column = control%columns
        control%vertical_set = v; control%partition_phase = geometry%partition%phase
        control%integral_bc = mode_control%integral_bc; control%derivative_bc = mode_control%derivative_bc
        control%temporary_bytes_budget = budget
        control%geometry_matches_partition = geometry%partition%borrowed_resolution == geometry%transform_resolution%resolution
        control%physical_constants_present = initial%constants%initialized /= 0
        control%hydrostatic = .not. model%dynamics%lnhdyn
        control%spectral_diagnostics = model%lrsiddh
        control%stretched = stretch /= 1.0_real64; control%finite_elements = finite_elements
      end associate
      state%context%ready = .false.; state%ready = .true.; status = 0_int32
    end associate
    return
900 call release_native_spectral_calculation_state(state)
  contains
    subroutine agree_child()
      local_status = status
      call agree_spectral_partition_status(comm, local_status, status)
    end subroutine
  end subroutine

  !> Bind existing named spectral views; no plane numbers or payload copies.
  !! The spectral owner and optional filter owners must outlive STATE.
  !! Padding and genuine local-level extents remain in the original owners.
  subroutine bind_native_spectral_calculation_fields(state, spectral, status, filtered_vorticity, filtered_divergence)
    type(native_spectral_calculation_state), intent(inout) :: state
    type(spectral_field_state), target, intent(inout) :: spectral
    integer(int32), intent(out) :: status
    real(real64), target, optional, intent(inout) :: filtered_vorticity(:, :), filtered_divergence(:, :)
    type(native_spectral_calculation_fields) :: fields
    status = 2_int32
    if (.not. state%ready .or. .not. spectral%ready) return
    if (spectral%nflevg /= state%pressure%layout%global_levels) return
    if (spectral%nflevl /= state%pressure%layout%local_levels) return
    if (spectral%nspec2 /= state%pressure%layout%spectral_coefficients) return
    if (.not. associated(spectral%vor) .or. .not. associated(spectral%div) .or. .not. associated(spectral%t)) return
    if (state%context%lgradsp .and. .not. present(filtered_vorticity)) return
    fields%level%vorticity => spectral%vor; fields%level%divergence => spectral%div
    fields%level%temperature => spectral%t; fields%level%surface_pressure => spectral%sp
    if (present(filtered_vorticity)) fields%filtered_vorticity => filtered_vorticity
    if (present(filtered_divergence)) fields%filtered_divergence => filtered_divergence
    state%fields = fields; state%fields_bound = .true.; status = 0_int32
  end subroutine

  !> Retire every alias before release; shared model,field,mass owners survive.
  subroutine release_native_spectral_calculation_state(state)
    type(native_spectral_calculation_state), intent(inout) :: state
    integer(int32) :: ignored
    state%ready = .false.; state%fields_bound = .false.
    ! The released context has no callable stage; these switches are inert.
    state%context = native_spectral_calculation_context(diffusion_switches= &
                                        native_horizontal_diffusion_switches(.false., .false., .false., .false., .false., .false., &
                                                                     .false., .false., .false., .false., .false., .false., .false.))
    state%fields = native_spectral_calculation_fields()
    nullify (state%model)
    state%pressure = spectral_pressure_context()
    call release_reference_temperature_correction(state%reference_temperature)
    ignored = release_spectral_diffusion_storage(state%diffusion)
    call release_runtime_semi_implicit_modes(state%modes)
    call release_owned_reference_pressure(state%reference)
  end subroutine
end module forecast_spectral_setup_state
