!> Project source controls into the actual grid caller without making weather fields.
module forecast_native_cpg_control_binding
  use iso_fortran_env, only: int32, real64
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_remaining_dynamics_controls, only: native_remaining_dynamics_controls
  use forecast_dynamics_field_maps, only: native_dynamics_field_maps
  use forecast_dynamical_diagnostic_storage, only: native_dynamical_diagnostic_controls
  use forecast_source_time_filter_weights, only: native_time_filter_weights
  use md2asm_two_part_time_filter, only: filter_field_pair, time_filter_maps
 use forecast_global_lateral_boundary_controls,only:native_global_lateral_boundary_controls,initialize_global_lateral_boundary_controls
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use physics_configuration_text_port, only: find_physics_group
  use forecast_native_flux_storage, only: native_forecast_flux_controls
  implicit none
  private
  public :: bind_native_cpg_controls, bind_native_cpg_flux_controls
contains
  !> Copy static, dimensionless controls from the same final-address owners.
 !! GRID and STARTUP borrow the same MODEL and initial geometry. Array payloads,
 !! workspace descriptors, reset scheduling and numerical fields remain intact.
 !! TIME_WEIGHTS is a temporary source-produced scalar record; no pointer escapes.
 !! LNSPONGE is the actual existing sponge producer's result. STATUS0 projects
 !! these controls; it does not certify a numerical child's supported domain.
 !! Time intervals are seconds. The visit refresher supplies current step/TDT.
  subroutine bind_native_cpg_controls(grid, startup, remaining, maps, diagnostics, time_weights, lnsponge, status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_remaining_dynamics_controls), intent(in) :: remaining
    type(native_dynamics_field_maps), intent(in) :: maps
    type(native_dynamical_diagnostic_controls), intent(in) :: diagnostics
    type(native_time_filter_weights), intent(in) :: time_weights
    logical, intent(in) :: lnsponge
    integer(int32), intent(out) :: status
    type(native_global_lateral_boundary_controls) :: lateral
    type(time_filter_maps) :: filter_map
    integer :: n, nf, ncomp, j, water(4), q, rs, source(6), destination(6)
    integer(int32) :: child
    logical :: lsddh, lflexdia, lgpstress, lrfric, lesidg, gwdiags, lsidg, split_constituents
    logical :: llct, llctc, diabatic, split_physics, use_pb1
    status = 2
    if (.not. allocated(startup%initial)) return
    if (.not. startup%initial%ready .or. .not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%initial%prefix)) return
    if (.not. allocated(startup%loaded%storage) .or. .not. allocated(startup%loaded%input)) return
    if (.not. associated(grid%model)) return
    if (.not. associated(grid%model, startup%loaded%storage%model)) return
    if (.not. grid%model%ready .or. .not. associated(grid%model%initial, startup%initial)) return
    if (.not. remaining%ready .or. .not. time_weights%ready) return
    n = startup%initial%prefix%configuration_bytes
    if (n < 1 .or. n > len(startup%initial%prefix%configuration_text)) return
    child = initialize_global_lateral_boundary_controls(lateral, startup%initial%controls%namespace%lelam /= 0)
    if (child /= 0) return
    child = source_missing_switches(startup%initial%prefix%configuration_text(1:n), &
                                    startup%initial%controls%namespace%lecmwf /= 0, startup%initial%geometry%dimensions%nflevg, &
                                    lsddh, lflexdia, lgpstress, lrfric, lesidg, gwdiags)
    if (child /= 0) return
    associate (model => grid%model, initial => startup%initial, g => startup%initial%geometry, &
               lag => startup%loaded%input%lagrangian, dynamic => startup%loaded%dynamic, &
               c => grid%blocks%controls, column => grid%blocks%controls%column)
      if (lag%ncurrent_iter < 0 .or. remaining%nsiter < lag%ncurrent_iter) return
      nf = model%fields%registration%numflds
      if (nf < 1 .or. nf > size(model%fields%components)) return
      water = [model%fields%aliases%yl, model%fields%aliases%yi, model%fields%aliases%yr, model%fields%aliases%ys]
      if (any(water < 1) .or. any(water > nf)) return
      q = model%fields%aliases%yq; rs = model%fields%aliases%yrspec
      if (q < 1 .or. q > nf .or. rs < 1 .or. rs > nf) return
      split_constituents = any(model%fields%components(1:nf)%ltdiablin /= 0)
      lsidg = startup%loaded%input%reference%stretched_grid /= 0 .and. &
              (initial%controls%namespace%nconf < 900 .or. initial%controls%namespace%nconf == 904) .and. &
              initial%controls%clock%integration%total_steps > 0
      llct = model%dynamics%lpc_full .and. lag%ncurrent_iter > 0
      llctc = model%dynamics%lpc_cheap .and. lag%ncurrent_iter > 0
      diabatic = (model%physics%phy%lmphys .or. model%physics%ecmwf_physics%lephys) .and. &
                 .not. model%physics%ecmwf_physics%lagphy .and. lag%ncurrent_iter == 0
      split_physics = model%physics%ecmwf_physics%lslphy .and. model%dynamics%lslag .and. .not. llctc
      use_pb1 = model%dynamics%lslag .and. (lag%ncurrent_iter == 0 .or. (llct .and. .not. llctc))
      c%first_step = initial%controls%clock%integration%first_step
      c%last_step = initial%controls%clock%integration%total_steps
      c%semi_lagrangian = model%dynamics%lslag
      c%ecmwf_physics = model%physics%ecmwf_physics%lephys
      c%lagged_physics = model%physics%ecmwf_physics%lagphy
      c%split_physics = model%physics%ecmwf_physics%lslphy
      c%full_corrector = model%dynamics%lpc_full
      c%cheap_corrector = model%dynamics%lpc_cheap
      c%beta_time = lag%betadt
      c%transport_statistics = lag%lsettlsvf .and. lag%lsetfstat
      c%mixed_extrapolation_statistics = model%dynamics%lmixettls
      column%current_iteration = lag%ncurrent_iter; column%last_iteration = remaining%nsiter
      column%beta_time = lag%betadt
      column%use_first_buffer = use_pb1; column%split_physics = split_physics
      column%full_corrector = model%dynamics%lpc_full
      column%rhs_curvature = lag%lrhs_curv
      column%reuse_pressure = model%dynamics%lpgreuse
      column%diabatic = diabatic; column%limited_area_tendencies = lateral%ltenc
      column%extra_diagnostics = lsddh
      column%trajectory_diagnostics = diagnostics%lrslddh
      column%surface_flux_diagnostics = diagnostics%lrhdddh
      column%saved_indices%u = dynamic%mu_savtend
      column%saved_indices%v = dynamic%mv_savtend
      column%saved_indices%t = dynamic%mt_savtend
      column%dynamics%semi_lagrangian = model%dynamics%lslag
      column%dynamics%ecmwf_physics = model%physics%ecmwf_physics%lephys
      column%dynamics%meteofrance_physics = model%physics%phy%lmphys
      column%dynamics%surface_linear_physics = model%physics%linear_physics%lsphlc
      column%dynamics%trajectory_save = startup%scalars%ltrajsave
      column%dynamics%trajectory_lag = startup%scalars%ltrajslag
      column%diagnostic%lsddh = lsddh; column%diagnostic%lflexdia = lflexdia
      column%diagnostic%lagphy = model%physics%ecmwf_physics%lagphy
      column%diagnostic%lsimph = model%physics%simplified_physics%lsimph
      column%diagnostic%ldirclsmod = model%physics_dimensions%ldirclsmod
      column%finish%lagphy = model%physics%ecmwf_physics%lagphy
      column%finish%ltrajps = model%physics%simplified_physics%ltrajps
      column%finish%lmse = model%physics%arpege_physics%lmse
      column%finish%ngpar = startup%loaded%storage%meteo_france%alternative_parameters%ngpar
      column%finish%rstret = g%configuration%values%rstret
      call make_filter_maps()
      associate (a => column%grid)
        a%filter%two_time_levels = model%dynamics%ltwotl
        a%filter%copy_gradients = model%dynamics%lgradsp
        a%filter%copy_full_state = model%dynamics%lpc_full
        a%filter%nonhydrostatic = model%dynamics%lnhdyn
        a%filter%temperature_fields = model%field_dimensions%nfther
        a%filter%nonhydrostatic_scheme = model%dynamics%nvdvar
        a%filter_maps = filter_map
        a%filter_weights = [time_weights%reps1, time_weights%reps2, time_weights%repsm1, time_weights%repsm2]
        a%stretch = g%configuration%values%rstret
        a%update_factor = 1.0_real64 ! CPG_DRV source ZTE for configuration A/B.
        a%current_iteration = lag%ncurrent_iter; a%water_components = water
        a%semi_lagrangian = model%dynamics%lslag; a%two_time_levels = model%dynamics%ltwotl
        a%boundary_coupling = lateral%ltenc; a%top_sponge = lnsponge
        a%nudging = model%nudging%lnudg; a%large_scale_forcing = initial%controls%namespace%lsforc /= 0
        a%nonhydrostatic = model%dynamics%lnhdyn
        a%nonhydrostatic_euler = model%dynamics%lnhee; a%nonhydrostatic_quasi = model%dynamics%lnhqe
        a%alternative_acceleration = model%dynamics%lsacc
        a%finite_element_ecmwf = g%vertical%configuration%lvfe_ecmwf /= 0
        a%full_corrector = model%dynamics%lpc_full
        a%diabatic = diabatic; a%surface_physics = model%physics%linear_physics%lsphlc
        a%simple_physics = model%physics%simplified_physics%lsimph
        a%extra_diagnostics = diagnostics%lrslddh
        a%model_surface_equations = model%physics%arpege_physics%lmse
        a%linearized_model = model%physics%arpege_physics%lmpa
        a%initialization%semi_lagrangian = model%dynamics%lslag
        a%initialization%two_time_levels = model%dynamics%ltwotl
        a%initialization%nonhydrostatic = model%dynamics%lnhdyn
        a%initialization%extra_nonhydrostatic = model%dynamics%lnhx
        a%initialization%advect_waves = model%dynamics%lgwadv
        a%initialization%finite_elements = g%vertical%configuration%lvertfe /= 0
        a%initialization%finite_element_waves = g%vertical%configuration%lvfe_ecmwf /= 0
        a%initialization%iteration = lag%ncurrent_iter
        a%bank_slots%vertical_velocity = model%buffers%second%mslb2vvel
        a%bank_slots%wave = model%buffers%second%mslb2gwf
        a%bank_slots%wave_divergence = model%buffers%second%mslb2gdw
        a%bank_slots%surface_wave = model%buffers%second%mslb2gws
        associate (h => a%hydrostatic, v => g%vertical)
          h%pressure%approximate_mode = v%configuration%ndlnpr
          h%pressure%finite_elements = v%configuration%lvertfe /= 0
          h%pressure%arithmetic_full_pressure = v%configuration%laprxpk /= 0
          h%pressure%top_pressure = v%toppres
          h%pressure%top_alpha = v%configuration%rhydr0
          h%pressure%dry_gas_constant = initial%constants%rd
          h%pressure%dry_isochoric_heat_capacity = initial%constants%rcvd
          h%pressure_fields = [maps%yytxyb0%m_delp, maps%yytxyb0%m_rdelp, maps%yytxyb0%m_lnpr, &
                               maps%yytxyb0%m_alph, maps%yytxyb0%m_rtgr, maps%yytxyb0%m_rpre, maps%yytxyb0%m_rpp]
          h%integral_bc = v%configuration%nvfe_intbc; h%derivative_bc = v%configuration%nvfe_derbc
          h%gravity_wave = .not. (v%configuration%lvertfe /= 0 .and. v%configuration%lvfe_ecmwf == 0)
          h%horizontal_wave = model%dynamics%lslhd
          h%diabatic = diabatic; h%previous_wave = model%physics%arpege_physics%lmpa
          h%reuse_pressure = model%dynamics%lpgreuse; h%reuse_pressure_force = model%dynamics%lpgfsf
          h%upper_flux = model%dynamics%lrubc; h%nonhydrostatic = model%dynamics%lnhdyn
          h%simple_physics = model%physics%simplified_physics%lsimph
          j = model%fields%aliases%yphycty
          if (j < 1 .or. j > nf) return
          h%mass_source_active = model%fields%components(j)%lactive /= 0
          h%specific_gas_active = model%fields%components(rs)%lgp /= 0
          h%large_scale_forcing = initial%controls%namespace%lsforc /= 0
          h%wave_diagnostics = gwdiags; h%wind_damping = lrfric .and. .not. model%physics%ecmwf_physics%legwwms
          h%moist_temperature = model%dynamics%lsprt; h%dry_virtual_wind = model%dynamics%l_rdry_vd
          h%filter_pressure_force = model%dynamics%lgradsp; h%two_time_levels = model%dynamics%ltwotl
        end associate
      end associate
      associate (a => column%lagrangian)
        a%moist_temperature = model%dynamics%lsprt
        a%implicit_coriolis = lag%l2tlff .and. (model%physics%phy%lmphys .or. &
                                                model%physics%ecmwf_physics%lephys) .and. .not. model%physics%ecmwf_physics%lagphy
        a%finite_elements = g%vertical%configuration%lvertfe /= 0; a%two_time_levels = model%dynamics%ltwotl
        a%nonhydrostatic_euler = model%dynamics%lnhee; a%nonhydrostatic_quasi = model%dynamics%lnhqe
        a%nonhydrostatic = model%dynamics%lnhdyn
        a%mixed_extrapolation = model%dynamics%lmixettls
        a%full_corrector = model%dynamics%lpc_full; a%cheap_corrector = model%dynamics%lpc_cheap
        a%horizontal_diffusion = model%dynamics%lslhd; a%modified_advection = model%dynamics%lcomad
        a%wave_advection = model%dynamics%lgwadv
        a%diagnostic_bottom_boundary = model%dynamics%lrdbbc
        a%extra_linear_term = model%dynamics%lslinl
        a%integral_bc = g%vertical%configuration%nvfe_intbc; a%derivative_bc = g%vertical%configuration%nvfe_derbc
        a%time%implicit_map = lsidg; a%time%extended_map = lesidg
        a%time%two_level_first_force = lag%l2tlff
        a%time%model_physics = model%physics%phy%lmphys; a%time%external_physics = model%physics%ecmwf_physics%lephys
        a%time%lagged_physics = model%physics%ecmwf_physics%lagphy
        a%time%off_centering = lag%vesl; a%time%stretch = g%configuration%values%rstret
        a%wind%filtered_levels = lag%nflevsf; a%wind%first_order_steps = initial%controls%clock%integration%initial_iteration
        a%wind%two_time_levels = model%dynamics%ltwotl; a%wind%predict_horizontal = model%dynamics%lsettlsv .and. .not. model%dynamics%leltra
        a%wind%predict_vertical = model%dynamics%lsettlst .and. .not. model%dynamics%leltra; a%wind%filter_vertical = lag%lsettlsvf
        a%wind%curved_departure = lag%lsldp_curv; a%wind%cartesian = lag%lsldp_xyz
        a%wind%save_history = lag%lsldp_save; a%wind%elegant_trajectory = model%dynamics%leltra
        a%wind%non_extrapolate_horizontal = model%dynamics%lnescv
        a%wind%non_extrapolate_vertical = model%dynamics%lnesct
        a%wind%full_corrector = model%dynamics%lpc_full; a%wind%cheap_corrector = model%dynamics%lpc_cheap
        a%wind%extra_horizontal_filter = lag%lsetfstat; a%wind%extra_vertical_filter = lag%lsettlsvf_diff
        a%wind%vertical_smoothing = lag%lsvtsm; a%wind%extra_vertical_trajectory = lag%lsldp_rk
        a%wind%curved_rhs = lag%lrhs_curv; a%wind%refined_first_step = lag%l2tlff
        a%wind%rayleigh_filter = initial%controls%namespace%larome /= 0 .and. &
                                 startup%loaded%storage%meteo_france%alternative_parameters%lsquall
        a%wind%filter_scale = lag%rscale; a%wind%filter_offset = lag%rscaleoff
        a%transport%two_time_levels = model%dynamics%ltwotl
        a%transport%finite_element = g%vertical%configuration%lvertfe /= 0
        a%transport%nonhydrostatic = model%dynamics%lnhdyn
        a%transport%semi_lagrangian_acceleration = model%dynamics%lsacc
        a%transport%split_constituents = split_constituents; a%transport%curved_rhs = lag%lrhs_curv
        a%transport%advective_forcing = lag%ladvf
        a%transport%full_coriolis_geometry = model%dynamics%lsacc
        a%transport%cartesian_wind = lag%ladvf
        a%transport%moisture_convergence_copy = model%fields%components(model%fields%aliases%ycvgq)%lactive /= 0
        a%transport%stable_extrapolation = model%dynamics%lsettls
        a%transport%wind_transport_points = lag%nwlag; a%transport%temperature_transport_points = lag%ntlag
        a%transport%interpolation_factor = lag%rintopt
        a%transport%dry_gas_constant = initial%constants%rd
        a%transport%reference_temperature = startup%loaded%input%reference%temperature
        a%transport%gravity = initial%constants%rg; a%transport%planet_radius = initial%constants%ra
        a%transport%rotation_rate = initial%constants%romega
        a%transport%orographic_scale = lag%rcmslp0
        a%transport%term%first_order_steps = initial%controls%clock%integration%initial_iteration
        a%transport%term%current_iteration = lag%ncurrent_iter
        a%transport%term%full_predictor_corrector = model%dynamics%lpc_full
        a%transport%term%cheap_corrector = model%dynamics%lpc_cheap
        a%transport%term%escape = model%dynamics%lnesc
        a%transport%term%diagnostics = diagnostics%lrsiddh
        a%transport%term%split_interpolation = split_constituents
        a%transport%term%implicit_time_weight = lag%xidt
        a%surface%two_time_levels = model%dynamics%ltwotl
        a%surface%finite_elements = g%vertical%configuration%lvertfe /= 0
        a%surface%full_corrector = model%dynamics%lpc_full; a%surface%cheap_corrector = model%dynamics%lpc_cheap
        a%surface%stable_extrapolation = model%dynamics%lsettlst; a%surface%escape = model%dynamics%lnesc
        a%surface%continuity_points = lag%nvlag; a%surface%current_iteration = lag%ncurrent_iter
        a%surface%first_order_steps = initial%controls%clock%integration%initial_iteration
        a%surface%integral_bc = g%vertical%configuration%nvfe_intbc
        a%surface%derivative_bc = g%vertical%configuration%nvfe_derbc
        a%surface%time_bias = lag%xidt; a%surface%dry_gas_constant = initial%constants%rd
        a%surface%reference_temperature = startup%loaded%input%reference%temperature
        a%surface%terrain_coefficient = lag%rcmslp0
        a%boundary%refined_winds = lag%l2tlff; a%boundary%lsldp_curv = lag%lsldp_curv
        a%boundary%lrhs_curv = lag%lrhs_curv; a%boundary%lsldp_rk = lag%lsldp_rk
        a%boundary%lsplthoigfl = split_constituents; a%boundary%lnhee = model%dynamics%lnhee
        a%boundary%lnhdyn = model%dynamics%lnhdyn; a%boundary%lslinl = model%dynamics%lslinl
        a%boundary%lslinlc2 = model%dynamics%lslinlc2; a%boundary%split_physics = model%physics%ecmwf_physics%lslphy
        a%boundary%nsplthoi = lag%nsplthoi; a%boundary%nwlag = lag%nwlag
        a%boundary%ntlag = lag%ntlag; a%boundary%nvlag = lag%nvlag
      end associate
      associate (a => grid%lagged)
        a%nonhydrostatic = model%dynamics%lnhdyn; a%nonhydrostatic_euler = model%dynamics%lnhee
        a%nonhydrostatic_quasi = model%dynamics%lnhqe; a%semi_lagrangian = model%dynamics%lslag
        a%diagnostic_accumulation = diagnostics%lrslddh; a%moist_temperature = model%dynamics%lsprt
        a%stress_enabled = lgpstress; a%full_corrector = model%dynamics%lpc_full
        ! No trajectory record is supplied by this native grid caller. The
        ! source trajectory switches below remain the actual produced values.
        a%trajectory_present = .false.
        a%trajectory_save = startup%scalars%ltrajsave; a%trajectory_lag = startup%scalars%ltrajslag
        a%oops_save = startup%scalars%ltrajsave_oops; a%oops_lag = startup%scalars%ltrajslag_oops
        a%current_iteration = lag%ncurrent_iter; a%last_iteration = remaining%nsiter
        a%last_step = initial%controls%clock%integration%total_steps
        a%stretch = g%configuration%values%rstret
        a%filter = column%grid%filter; a%filter_maps = filter_map; a%filter_weights = column%grid%filter_weights
      end associate
    end associate
    status = 0
  contains
    subroutine make_filter_maps()
      associate (m => grid%model%motion)
        filter_map%motion = [filter_field_pair(m%yt0%mu, m%yt9%mu, .true.), &
                             filter_field_pair(m%yt0%mv, m%yt9%mv, .true.), filter_field_pair(m%yt0%mdiv, m%yt9%mdiv, .true.)]
        filter_map%temperature = [filter_field_pair(m%yt0%mt, m%yt9%mt, .true.), &
                                  filter_field_pair(m%yt0%mtl, m%yt9%mtl, .true.), filter_field_pair(m%yt0%mtm, m%yt9%mtm, .true.)]
        filter_map%gradients = [filter_field_pair(m%yt0%msgrtl, m%yt9%msgrtl, .true.), &
                                filter_field_pair(m%yt0%msgrtm, m%yt9%msgrtm, .true.)]
        filter_map%surface = [filter_field_pair(m%yt0%msp, m%yt9%msp, .true.), &
                              filter_field_pair(m%yt0%mspl, m%yt9%mspl, .true.), filter_field_pair(m%yt0%mspm, m%yt9%mspm, .true.)]
        source = [m%yt0%mspd, m%yt0%msvd, m%yt0%mspdl, m%yt0%msvdl, m%yt0%mspdm, m%yt0%msvdm]
        destination = [m%yt9%mspd, m%yt9%msvd, m%yt9%mspdl, m%yt9%msvdl, m%yt9%mspdm, m%yt9%msvdm]
        do j = 1, 6
          filter_map%nonhydro(j) = filter_field_pair(source(j), destination(j), .true.)
        end do
        filter_map%extra = filter_field_pair(m%yt0%mnhx, m%yt9%mnhx, .true.)
        filter_map%air_clear_first = m%yt0%ndim + 1; filter_map%air_clear_last = m%ndimgmv
        filter_map%surface_clear_first = m%yt0%ndims + 1; filter_map%surface_clear_last = m%ndimgmvs
      end associate
    end subroutine
  end subroutine

  !> Borrow the already produced XFU owner and its source reset schedule.
 !! FLUX is the actual final TARGET written at startup phase70. The caller
 !! has completed initialize_native_forecast_flux_controls. No default or
 !! output schedule is regenerated here. Retire GRID before releasing FLUX.
  subroutine bind_native_cpg_flux_controls(grid, flux, status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_flux_controls), target, intent(inout) :: flux
    integer(int32), intent(out) :: status
    status = 2
    if (.not. associated(grid%model)) return
    if (.not. grid%model%ready) return
    if (flux%xfu%nfrraz < 1) return
    grid%blocks%controls%reset_frequency = flux%xfu%nfrraz
    grid%blocks%controls%reset_value = flux%xfu%n1raz
    grid%blocks%controls%gust_reset = flux%xfu%lxxgst .or. flux%xfu%lxxgst2 .or. flux%xfu%lxxdiagh
    grid%blocks%controls%visibility_reset = flux%xfu%lxvisi .or. flux%xfu%lxvisi2
    grid%blocks%controls%precipitation_reset = grid%model%physics%phy%ldprecips .or. grid%model%physics%phy%ldprecips2
    grid%blocks%controls%mean_wind = flux%xfu%lxmwindcls
    grid%blocks%reset_requests => flux%xfu%nrazts
    grid%blocks%flux_reset => flux%xfu%lreset
    status = 0
  end subroutine

  !> Produce the consumed SUNDDH/SUDYN/YOMGWDIAG switch prefix from real text.
 !! The supported SUNDDH branch has empty NAMDDH. NAMDYN accepts only the
 !! admitted numeric weights, NITMP/LMASCOR, and the two consumed stress/friction
 !! switches. Unsupported options refuse before any persistent control changes.
  integer(int32) function source_missing_switches(text, ecmwf, levels, lsddh, lflexdia, &
                                                  stress, friction, extended, gwdiag) result(status)
    character(*), intent(in) :: text
    logical, intent(in) :: ecmwf
    integer, intent(in) :: levels
    logical, intent(out) :: lsddh, lflexdia, stress, friction, extended, gwdiag
    logical :: lhdglb, lhdzon, lhddop, lgpstress, lrfric, lrfricisotr, lmascor
    logical :: lgwdiags_on, lgwdiags_field_out
    real(real64) :: reps1, reps2, repsm1, repsm2, repsp1
    integer :: nitmp, cursor, ios
    namelist /namdyn/ nitmp, lmascor, reps1, reps2, repsm1, repsm2, repsp1, lgpstress, lrfric, lrfricisotr
    namelist /namgwdiag/ lgwdiags_on, lgwdiags_field_out
    status = 2
    if (len(text) < 1 .or. len(text) > 262144 .or. levels < 1 .or. levels > 255) return
    status = require_empty_physics_group(text, 'NAMDDH')
    if (status /= 0) return
    lhdglb = .false.; lhdzon = .false.; lhddop = .false.; lflexdia = .false.
    lsddh = lhdglb .or. lhdzon .or. lhddop
    lgpstress = .false.; lrfric = .false.
    if (ecmwf .and. levels <= 91) lrfric = .true.
    lrfricisotr = .false.; lmascor = .false.; nitmp = 2
    reps1 = 0.0_real64; reps2 = 0.0_real64; repsm1 = 0.0_real64; repsm2 = 0.0_real64; repsp1 = 0.0_real64
    cursor = find_physics_group(text, 'NAMDYN', .false.)
    if (cursor > 0) then
      block
        character(len=len(text) + 10) :: record
        record = '&NAMDYN '//text(cursor:)
        read (record, nml=namdyn, iostat=ios)
      end block
      if (ios /= 0) then
        status = 2; return
      end if
    end if
    lgwdiags_on = .false.; lgwdiags_field_out = .false.
    cursor = find_physics_group(text, 'NAMGWDIAG', .false.)
    if (cursor > 0) then
      block
        character(len=len(text) + 12) :: record
        record = '&NAMGWDIAG '//text(cursor:)
        read (record, nml=namgwdiag, iostat=ios)
      end block
      if (ios /= 0) then
        status = 2; return
      end if
    end if
    ! SUDYN global branch sets LESIDG false before supported configuration reads.
    extended = .false.; stress = lgpstress; friction = lrfric; gwdiag = lgwdiags_on
    status = 0
  end function
end module
