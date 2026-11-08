!> Borrow the produced trajectory controls, coefficient tables and weather arrays.
module forecast_native_transport_input_binding
  use iso_fortran_env, only: int32, int64, real64
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_runtime_operational_input, only: native_runtime_operational_input_state
  use forecast_interpolation_coefficient_table_types, only: native_interpolation_coefficient_tables
  use forecast_spectral_setup_state, only: native_spectral_calculation_state
  use forecast_dynamical_diagnostic_storage, only: native_dynamical_diagnostic_storage, native_dynamical_diagnostic_controls
  use forecast_remaining_dynamics_controls, only: native_remaining_dynamics_controls
  use forecast_parallel_interpolation_controls, only: parallel_interpolation_controls
  use md2asm_semi_lagrangian_transport_stage, only: transport_stage_controls, transport_trajectory_inputs, transport_update_inputs
  use md2asm_native_call_sl, only: native_call_sl_arrays
  use md2asm_internal_interpolation_plane_maps, only: interpolation_plane_controls
 use forecast_interpolation_control_children, only: initialize_field_interpolation_controls, initialize_vertical_smoothness_controls
  use forecast_additional_dynamics_controls, only: initialize_departure_point_controls
  use forecast_native_transport_table_binding, only: bind_transport_table_views
  implicit none
  private
  public :: bind_native_transport_inputs, refresh_native_transport_visit_controls, refresh_native_transport_scan_controls
contains
  !> Bind one source-admitted hydrostatic transport visit without calculating weather.
 !! GRID and STARTUP are stable TARGET owners already joined by the GP factory.
 !! TABLES is the produced SUINTERPOLATOR owner. SPECTRAL supplies live KLSPONGE.
 !! DIAGNOSTICS owns the actual inactive one-by-one arrays; their write controls
 !! remain false. REMAINING and POLICY are the same parsed execution controls.
 !! The final logical is the produced LCUCONV_CA.AND.LCA_ADVECT source branch.
 !! It is refused while the retained transport child lacks that active branch.
 !! Arrays retain their native units and bounds. This entry allocates nothing,
 !! copies no array payload and leaves all GRID inputs unchanged on refusal2.
 !! A later visit refresh supplies the genuine CNT4 LFINDVSEP, NSTEP and RTDT.
 !! Status0 binds metadata only and does not establish numerical acceptance.
  subroutine bind_native_transport_inputs(grid, startup, tables, spectral, diagnostics, remaining, diagnostic_controls, &
                                          policy, convective_departure_copy, status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_interpolation_coefficient_tables), target, intent(in) :: tables
    type(native_spectral_calculation_state), target, intent(in) :: spectral
    type(native_dynamical_diagnostic_storage), target, intent(inout) :: diagnostics
    type(native_remaining_dynamics_controls), intent(in) :: remaining
    type(native_dynamical_diagnostic_controls), intent(in) :: diagnostic_controls
    type(parallel_interpolation_controls), intent(in) :: policy
    logical, intent(in) :: convective_departure_copy
    integer(int32), intent(out) :: status
    type(transport_stage_controls) :: c
    type(transport_trajectory_inputs) :: t
    type(transport_update_inputs) :: u
    type(native_call_sl_arrays) :: a
    type(interpolation_plane_controls) :: plane
    integer(int32) :: p, l, b, n, child, nitmp, nqmhoislt, yq, ycvgq, j
    logical :: lqmw, lqmhw, lqmt, lqmht, lqmp, lqmhp, lqmpd, lqmhpd, lqmvd, lqmhvd
    logical :: rhs_curvature, find_vertical_separation
    real(real64) :: eta_on, eta_ox
    status = 2
    if (.not. associated(grid%model) .or. .not. associated(grid%fields) .or. .not. associated(grid%next)) return
    if (.not. allocated(startup%loaded%storage) .or. .not. allocated(startup%loaded%input)) return
    if (.not. associated(grid%model, startup%loaded%storage%model)) return
    if (.not. associated(grid%model%initial)) return
    if (.not. grid%model%ready .or. .not. grid%model%initial%ready) return
    if (.not. allocated(grid%model%initial%geometry)) return
    if (.not. remaining%ready .or. .not. policy%ready .or. .not. tables%ready .or. .not. spectral%ready) return
    if (.not. associated(spectral%model, grid%model)) return
    if (convective_departure_copy .or. policy%lslondem .or. policy%lsldebug) return
    if (diagnostic_controls%lrddhdyn .or. diagnostic_controls%lrslddh .or. &
        diagnostic_controls%lrsiddh .or. diagnostic_controls%lrhdddh) return
    if (.not. associated(grid%trajectory%selectors) .or. .not. associated(grid%trajectory%diagnostics)) return
    if (.not. associated(grid%transport_update%components) .or. .not. associated(grid%transport_update%destinations)) return
    if (.not. allocated(diagnostics%gmvtndsi_ddh) .or. .not. allocated(diagnostics%gmvtndsl_ddh) .or. &
        .not. allocated(diagnostics%gfltndsl_ddh)) return
    associate (model => grid%model, g => grid%model%initial%geometry, m => grid%model%motion, &
               dyn => grid%model%dynamics, sl => grid%model%interpolation, ic => grid%model%interpolation_controls, &
               lag => startup%loaded%input%lagrangian, clock => grid%model%initial%controls%clock, &
               platform => grid%model%initial%controls%namespace)
      if (.not. associated(g%vertical)) return
      if (.not. allocated(m%gmv) .or. .not. allocated(m%gmvt1) .or. .not. allocated(m%gmvt1s)) return
      if (.not. allocated(grid%next%gflt1) .or. .not. allocated(grid%fields%gfl)) return
      if (.not. allocated(startup%loaded%dynamic%rsavedp)) return
      if (.not. allocated(sl%nloeng) .or. .not. allocated(sl%nsloff)) return
      if (.not. sl%lslt_arrays_init .or. sl%lslondem .or. sl%lslondem_active) return
      if (platform%lrplane /= 0 .or. lag%lsldp_rk .or. .not. lag%lsldp_xyz .or. lag%lsvtsm) return
      if (dyn%lsldia .or. dyn%lslhd_static) return
      p = g%dimensions%nproma; l = g%dimensions%nflevg; b = g%partition%ngpblks
      if (p < 1 .or. p > 1024 .or. l < 5 .or. l > 255 .or. b < 1) return
      if (size(m%gmv, 1) /= p .or. size(m%gmv, 2) < l .or. size(m%gmv, 4) /= b) return
      if (m%yt9%medot < 1 .or. m%yt9%medot > size(m%gmv, 3)) return
      if (any([m%ygp%mu, m%ygp%mv, m%ygp%mt] < 1)) return
      if (any([m%ygp%mu, m%ygp%mv, m%ygp%mt] > m%ygp%ndim)) return
      if (any([m%yt1%mu, m%yt1%mv, m%yt1%mt] < 1)) return
      if (any([m%yt1%mu, m%yt1%mv, m%yt1%mt] > size(m%gmvt1, 3))) return
      if (m%yt1%msp < 1 .or. m%yt1%msp > size(m%gmvt1s, 2)) return
      if (size(diagnostics%gmvtndsi_ddh, 4) /= b .or. size(diagnostics%gmvtndsl_ddh, 4) /= b .or. &
          size(diagnostics%gfltndsl_ddh, 4) /= b) return
      if (size(diagnostics%gmvtndsi_ddh, 1) /= 1 .or. size(diagnostics%gmvtndsi_ddh, 2) /= 1) return
      c = grid%transport_controls; t = grid%trajectory; u = grid%transport_update; a = grid%transport_arrays; plane = grid%plane_controls
      child = initialize_field_interpolation_controls(platform%nconf, platform%lecmwf /= 0, dyn%lslag, &
                                                      lqmw, lqmhw, lqmt, lqmht, lqmp, lqmhp, lqmpd, lqmhpd, lqmvd, lqmhvd)
      if (child /= 0) return
      nitmp = lag%nitmp; rhs_curvature = lag%lrhs_curv
      child = initialize_departure_point_controls(platform%nconf, platform%lecmwf /= 0, platform%lr2d /= 0, &
                     platform%lr3d /= 0, dyn%lsettlst, dyn%lsettlsv, nitmp, eta_on, eta_ox, rhs_curvature, find_vertical_separation)
      if (child /= 0) return
      child = initialize_vertical_smoothness_controls(spectral%diffusion%klsponge, u%weno%exponent, u%weno%upper_exponent, &
                                             u%weno%upper_level_count, u%weno%smoothness_choice, u%weno%boundary_enabled, nqmhoislt)
      if (child /= 0) return
      c%pitch = p; c%levels = l; c%point_count = g%partition%ngptot; c%point_capacity = c%point_count
      c%field_count = model%buffers%first%nfldslb1
      c%plane = platform%lrplane /= 0
      c%synchronise_exchange = policy%lsync_slcom; c%debug_exchange = policy%lsldebug
      c%convective_departure_copy = convective_departure_copy
      c%predictor_storage_count = 0
      ! SLEXTPOL consumes the produced SUDIM stencil width, separate from halo reach.
      c%stencil_width = g%dimensions%nstencilwide
      plane%lslag = dyn%lslag; plane%lvsplip = dyn%lvsplip
      plane%lsltvweno = dyn%lsltvweno; plane%lrhsvweno = dyn%lrhsvweno
      plane%lslvf = dyn%lslvf; plane%lslhdheat = ic%lslhdheat
      plane%lvweno_t = ic%lvweno_t; plane%nsldimk = ic%nsldimk
      t%controls%plane = c%plane; t%controls%runge_kutta = lag%lsldp_rk; t%controls%nonhydrostatic = dyn%lnhdyn
      t%controls%final_predictor_iteration = remaining%nsiter
      t%controls%diagnostic_first = 1; t%controls%diagnostic_last = size(t%diagnostics)
      t%latitude%halo_first = sl%ndgsah; t%latitude%halo_last = sl%ndgenh
      t%latitude%global_first = sl%ndgsag; t%latitude%global_last = sl%ndgeng
      t%latitude%local_first = sl%ndgsal; t%latitude%local_last = sl%ndgenl
      t%latitude%first_offset = sl%nfrstloff; t%latitude%halo_width = sl%nslwide
      t%latitude%count_first = lbound(sl%nloeng, 1); t%latitude%buffer_first = lbound(sl%nsloff, 1)
      t%latitude%point_count => sl%nloeng; t%latitude%buffer_offset => sl%nsloff
      t%trajectory%iterations = lag%nitmp; t%trajectory%step = clock%current_step
      t%trajectory%predictor_iteration = lag%ncurrent_iter
      t%trajectory%spherical = platform%lrplane == 0; t%trajectory%cartesian = lag%lsldp_xyz
      t%trajectory%curved_departure = lag%lsldp_curv; t%trajectory%rhs_curvature = lag%lrhs_curv
      t%trajectory%save_departure = lag%lsldp_save; t%trajectory%diagnostic_wind = dyn%lsldia
      t%trajectory%full_predictor = dyn%lpc_full; t%trajectory%cheap_predictor = dyn%lpc_cheap
      t%trajectory%report_crossings = dyn%lrprsltrj
      t%trajectory%time_factor = clock%integration%work(5); t%trajectory%pi = model%initial%constants%rpi
      t%trajectory%eta_top_blend = eta_on; t%trajectory%eta_bottom_blend = eta_ox
      t%trajectory%soft_wind_limit = ic%vmax1; t%trajectory%hard_wind_limit = ic%vmax2
      t%fields%stage = 1; t%fields%hermite_width = 0; t%fields%limiter = 0
      t%fields%first_input_level = g%dimensions%nflsa
      t%fields%last_input_level = g%dimensions%nflsa + g%dimensions%nflen - 1
      t%fields%spherical = platform%lrplane == 0; t%fields%cartesian = lag%lsldp_xyz
      t%fields%curvature = lag%lsldp_curv; t%fields%plane = c%plane; t%fields%interpolate_fields = .true.
      t%fields%find_vertical_separation = find_vertical_separation
      t%fields%vertical_smoothing = lag%lsvtsm; t%fields%spline_origin = dyn%lvsplip; t%fields%rhs_weno = dyn%lrhsvweno
      t%fields%pi = model%initial%constants%rpi; t%fields%stretch = g%configuration%values%rstret
      call bind_weight_controls(t%trajectory_weights)
      t%final_weights = t%trajectory_weights
      child = 2
      call bind_transport_table_views(g, sl, tables, t%geometry, child)
      if (child /= 0) return
      t%full_eta => g%vertical%vetaf; t%half_eta => g%vertical%vetah
      u%controls%lnhee = dyn%lnhee; u%controls%lnhdyn = dyn%lnhdyn
      u%controls%lgwadv = dyn%lgwadv; u%controls%lrdbbc = dyn%lrdbbc; u%controls%lsldia = dyn%lsldia
      u%controls%lslinlc2 = dyn%lslinlc2; u%controls%lslinl = dyn%lslinl; u%controls%lpc_cheap = dyn%lpc_cheap
      u%controls%lrhs_curv = lag%lrhs_curv; u%controls%ladvf = lag%ladvf; u%controls%l2tlff = lag%l2tlff
      u%controls%lrplane = c%plane; u%controls%l_rdry_vd = dyn%l_rdry_vd
      u%controls%finite_elements = g%vertical%configuration%lvertfe == 1
      u%controls%nvlag = lag%nvlag; u%controls%nwlag = lag%nwlag; u%controls%ntlag = lag%ntlag
      u%controls%integral_boundary_condition = g%vertical%configuration%nvfe_intbc
      u%controls%derivative_boundary_condition = g%vertical%configuration%nvfe_derbc
      u%controls%main_field_count = m%ygp%ndim
      u%state_map%general = [m%yt1%mu, m%yt1%mv, m%yt1%mt]; u%state_map%surface_pressure = m%yt1%msp
      yq = model%fields%aliases%yq; ycvgq = model%fields%aliases%ycvgq
      if (min(yq, ycvgq) < 1 .or. max(yq, ycvgq) > size(model%fields%components)) return
      u%state_map%spectral_moisture_copy = model%fields%components(ycvgq)%lsp /= 0
      u%state_map%moisture_source = model%fields%components(yq)%mp1
      u%state_map%moisture_target = model%fields%components(ycvgq)%mp1
      u%transport%first_input_level = t%fields%first_input_level
      u%transport%last_input_level = t%fields%last_input_level
      u%transport%split_physics = model%physics%ecmwf_physics%lslphy .and. &
                 (model%physics%phy%lmphys .or. model%physics%ecmwf_physics%lephys) .and. model%physics%ecmwf_physics%lagphy .and. &
                                  ((dyn%lpc_full .and. lag%ncurrent_iter == remaining%nsiter) .or. .not. dyn%lpc_full)
      u%transport%refined_saved_winds = lag%l2tlff
      u%transport%diffusion_diagnostic = diagnostic_controls%lrslddh
      u%transport%linear_diagnostic = diagnostic_controls%lrsiddh
      u%transport%separate_heat_coefficients = ic%lslhdheat
      u%transport%vertical_conservation = lag%lmascor; u%transport%modified_pressure = dyn%lcomad_sp
      u%transport%clip_pressure = lqmp
      u%transport%wind%linear = .false.; u%transport%wind%modified_advection = dyn%lcomad_w
      u%transport%wind%horizontal_diffusion = dyn%lslhd_w
      ! These literal SUDYN stores precede the admitted NAMDYN(NITMP,LMASCOR).
      u%transport%wind%vertical_weno = .false.; u%transport%wind%weno_exponent = 2.0_real64
      u%transport%wind%momentum = .true.; u%transport%wind%weight_set = 1
      u%transport%wind%limiter_three_dimensional = lqmw; u%transport%wind%limiter_horizontal = lqmhw
      u%transport%wind%alternative_heat_vertical = .false.
      u%transport%thermal%linear = .false.; u%transport%thermal%modified_advection = dyn%lcomad_t
      u%transport%thermal%horizontal_diffusion = dyn%lslhd_t
      u%transport%thermal%vertical_weno = platform%lecmwf /= 0 .and. dyn%lrhsvweno
      u%transport%thermal%weno_exponent = 0.0_real64
      u%transport%thermal%momentum = .not. ic%lslhdheat; u%transport%thermal%weight_set = 1
      u%transport%thermal%limiter_three_dimensional = lqmt; u%transport%thermal%limiter_horizontal = lqmht
      u%transport%thermal%alternative_heat_vertical = ic%lslhdheat
      u%maps(1)%result_slot = m%ygp%mu; u%maps(2)%result_slot = m%ygp%mv; u%maps(3)%result_slot = m%ygp%mt
      a%previous_eta_rate => m%gmv(:, :, m%yt9%medot, :)
      a%saved_departure => startup%loaded%dynamic%rsavedp
      a%general_state => m%gmvt1; a%surface_state => m%gmvt1s; a%constituent_state => grid%next%gflt1
      a%linear_general => diagnostics%gmvtndsi_ddh
      a%diffusion_general => diagnostics%gmvtndsl_ddh; a%diffusion_constituent => diagnostics%gfltndsl_ddh
      grid%transport_controls = c; grid%plane_controls = plane; grid%trajectory = t; grid%transport_update = u; grid%transport_arrays = a
      status = 0
    end associate
  contains
    subroutine bind_weight_controls(w)
      use md2asm_departure_interpolation_weights, only: departure_weight_controls
      type(departure_weight_controls), intent(inout) :: w
      associate (dyn => grid%model%dynamics, g => grid%model%initial%geometry, ic => grid%model%interpolation_controls)
        w%slots = ic%nsldimk; w%process_count = g%transform_control%nproc
        w%local_halo_ready = grid%model%interpolation%lslt_arrays_init
        w%on_demand_communication = policy%lslondem
        w%diffusion = dyn%lslhd; w%quadratic = dyn%lslhdquad; w%older_linear = dyn%lslhd_old
        w%heat_diffusion = ic%lslhdheat; w%turbulence = dyn%l3dturb
        w%coordinate_correction = dyn%lcomad; w%horizontal_correction = dyn%lcomadh; w%vertical_correction = dyn%lcomadv
        w%static_physics_weights = dyn%lslhd_static
        w%high_order_trajectories = dyn%lhoislt; w%trajectory_weno = dyn%lsltvweno; w%vertical_filter = dyn%lslvf
        w%regular_vertical_grid = g%vertical%configuration%lregeta == 1
        w%minimum_blend = dyn%slhdkmin; w%maximum_blend = dyn%slhdkmax; w%reference_blend = dyn%slhdkref
        w%high_order_horizontal = dyn%hoislth; w%high_order_vertical = dyn%hoisltv
        w%longitude_smoothing_epsilon = dyn%slhdepsh
      end associate
    end subroutine
  end subroutine

  !> Refresh source transport metadata through the existing startup interface.
 !! This wrapper forwards the same actual input record and NSITER scalar.
  subroutine refresh_native_transport_visit_controls(grid, startup, remaining, lfindvsep, status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(in) :: startup
    type(native_remaining_dynamics_controls), intent(in) :: remaining
    logical, intent(in) :: lfindvsep
    integer(int32), intent(out) :: status
    status = 2
    if (.not. associated(grid%model)) return
    if (.not. allocated(startup%loaded%storage) .or. .not. allocated(startup%loaded%input)) return
    if (.not. associated(grid%model, startup%loaded%storage%model) .or. .not. remaining%ready) return
    call refresh_native_transport_scan_controls(grid, startup%loaded%input, remaining%nsiter, lfindvsep, status)
  end subroutine

  !> Refresh only source visit-dependent transport metadata after CNT4.
 !! INPUT is the real input owner already borrowed by SCAN. NSITER comes
 !! from the single ready execution%remaining record. LFINDVSEP is the actual
 !! CNT4-produced loop member. Status2 changes nothing; success0 copies named
 !! scalars and calculates no weather. Time uses seconds; indices have no unit.
  subroutine refresh_native_transport_scan_controls(grid, input, remaining_nsiter, lfindvsep, status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_runtime_operational_input_state), target, intent(in) :: input
    integer(int32), intent(in) :: remaining_nsiter
    logical, intent(in) :: lfindvsep
    integer(int32), intent(out) :: status
    logical :: split
    status = 2
    if (.not. associated(grid%model) .or. .not. associated(grid%fields)) return
    if (.not. associated(grid%model%initial)) return
    if (.not. associated(grid%fields, input%upper%fields)) return
    if (.not. grid%model%ready .or. .not. grid%model%initial%ready) return
    associate (model => grid%model, lag => input%lagrangian, clock => grid%model%initial%controls%clock)
      if (clock%current_step < 0 .or. lag%ncurrent_iter < 0 .or. remaining_nsiter < 0) return
      split = model%physics%ecmwf_physics%lslphy .and. &
              (model%physics%phy%lmphys .or. model%physics%ecmwf_physics%lephys) .and. model%physics%ecmwf_physics%lagphy .and. &
              ((model%dynamics%lpc_full .and. lag%ncurrent_iter == remaining_nsiter) .or. .not. model%dynamics%lpc_full)
      grid%trajectory%trajectory%step = clock%current_step
      grid%trajectory%trajectory%time_factor = clock%integration%work(5)
      grid%trajectory%trajectory%predictor_iteration = lag%ncurrent_iter
      grid%trajectory%controls%final_predictor_iteration = remaining_nsiter
      grid%trajectory%fields%find_vertical_separation = lfindvsep
      grid%transport_update%transport%split_physics = split
      status = 0
    end associate
  end subroutine
end module
