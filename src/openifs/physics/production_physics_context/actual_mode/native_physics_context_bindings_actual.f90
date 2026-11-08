!> Bind production physics views to their actual retained owners.
module forecast_native_physics_context_bindings
  use iso_fortran_env, only: int32, int64
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_native_physics_factory_state, only: native_physics_context_factory_state
  use forecast_ecmwf_physics_fields, only: initialize_runtime_ecmwf_physics_fields
  use forecast_native_field_variable_types, only: native_registry_ecphysics_inputs, native_registry_radiation_inputs
  use native_radiation_clock_views, only: native_radiation_clock_view
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record
  use forecast_runtime_output_configuration, only: native_runtime_output_configuration, &
                                                   borrow_runtime_physical_output_requests
  use forecast_slow_physics_parameters, only: initialize_slow_physics_parameters, release_slow_physics_weights
  use owned_ecmwf_thermal_state_port, only: ecmwf_thermal_state_record
  use yomchem, only: tchem
  use forecast_physics_readonly_control_producers, only: initialize_cellular_controls
  use spp_mod, only: tspp_config
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  use yomspsdt, only: tsppt_config
  use stoph_mix, only: tstoph
  implicit none
  private
  public :: prepare_native_radiation_seed, prepare_native_physics_field_storage
  public :: bind_native_registry_science_inputs, bind_native_physics_clock
  public :: bind_native_post_controls, refresh_native_post_flag_encodings
  public :: prepare_native_slow_physics, release_native_slow_physics
  public :: bind_native_physics_providers, bind_native_ec_physics_inputs
  public :: prepare_native_cellular_controls
contains
  !> Project source controls without supplying a fixture or scientific default.
  !! LOPT_SCALAR is the actual produced process control, encoded0 or1.
  !! The Meteo-France radiation scalars retain the genuine fresh model preimage
  !! when that source parent has not run. This entry does not run SUPHMF.
  integer(int32) function prepare_native_radiation_seed(startup, lopt_scalar, seed) result(status)
    type(native_forecast_startup_storage), target, intent(in) :: startup
    integer(int32), intent(in) :: lopt_scalar
    type(radiation_control_upstream_record), intent(inout) :: seed
    integer(int32) :: ozone
    status = 2_int32
    if (lopt_scalar < 0 .or. lopt_scalar > 1) return
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    associate (model => startup%loaded%storage%model, geometry => startup%initial%geometry, &
               radiation => startup%loaded%storage%ecmwf%radiation, controls => startup%initial%controls%namespace)
      ozone = model%fields%aliases%yo3
      if (ozone < 1 .or. ozone > size(model%fields%components)) return
      seed%lecmwf = controls%lecmwf == 1_int32
      seed%larpegef = controls%larpegef == 1_int32
      seed%lephys = model%physics%ecmwf_physics%lephys
      seed%lrayfm = model%physics%phy%lrayfm
      seed%ozone_lgp = model%fields%components(ozone)%lgp == 1_int32
      seed%lopt_scalar = lopt_scalar == 1_int32
      seed%lape = model%dynamical_core%lape /= 0_int32
      seed%lhlradupd = model%physics%phy%lhlradupd
      seed%lray = model%physics%phy%lray
      seed%laeruvp = radiation%aerosol_atmosphere%laeruvp
      seed%leradi = model%physics%ecmwf_physics%leradi
      seed%leradlw2 = model%physics%nonlinear_physics%leradlw2
      seed%nemissscheme = model%physics%ecmwf_physics%nemissscheme
      seed%leradn2 = model%physics%nonlinear_physics%leradn2
      seed%nproma = geometry%dimensions%nproma
      seed%nsmax = geometry%dimensions%nsmax
      seed%ndglg = geometry%dimensions%ndglg
      seed%ngptot = geometry%partition%ngptot
      seed%ngptotmx = geometry%partition%ngptotmx
      seed%nflevg = geometry%dimensions%nflevg
      seed%ngpblks = geometry%partition%ngpblks
      seed%ndlon = geometry%dimensions%ndlon
      seed%timestep = startup%initial%controls%clock%integration%first_dt
      seed%radgr = startup%loaded%storage%meteo_france%alternative_parameters%radgr
      seed%radsn = startup%loaded%storage%meteo_france%alternative_parameters%radsn
    end associate
    status = 0_int32
  end function

  !> Allocate the source five tile fields and microwave field in existing FIELDS.
  !! The actual surface parameter producer supplies NTILES. OWNED_COUNT is
  !! the source caller's mutable count. No second physics-field owner is made.
  integer(int32) function prepare_native_physics_field_storage(startup, owned_count) result(status)
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    integer(int32), intent(inout) :: owned_count
    integer(int32) :: shape(4)
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. associated(startup%loaded%fields)) return
    if (.not. associated(startup%loaded%storage%ecmwf%surface)) return
    if (.not. startup%loaded%storage%ecmwf%setup_complete) return
    shape = [startup%initial%geometry%dimensions%nproma, startup%initial%geometry%dimensions%nflevg, &
             startup%initial%geometry%partition%ngpblks, startup%loaded%storage%ecmwf%surface%ydim%ntiles]
    status = initialize_runtime_ecmwf_physics_fields(startup%loaded%fields%ecphysics, shape, owned_count)
  end function

  !> Produce the one source slow-physics owner from live setup controls.
  !! Levels and NUNDEFLD are dimensionless. RSLWX values come from the frozen
  !! SUSAVTEND/SUDYN producer, not this binding routine.
  integer(int32) function prepare_native_slow_physics(factory, startup) result(status)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), target, intent(in) :: startup
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    status = initialize_slow_physics_parameters(factory%slow, startup%initial%geometry%dimensions%nflevg, &
                             startup%loaded%storage%model%physics%ecmwf_physics%lslphy, startup%initial%controls%namespace%nundefld)
    factory%last_status = status
    if (status == 0_int32) factory%phase = 1_int32
  end function

  !> Release only the one factory-owned slow-weight array after borrowers close.
  subroutine release_native_slow_physics(factory)
    type(native_physics_context_factory_state), intent(inout) :: factory
    call release_slow_physics_weights(factory%slow)
  end subroutine

  !> Borrow both the changing model clock and its distinct radiation outputs.
  !! STARTUP remains TARGET and stationary. No time value or record is copied.
  integer(int32) function bind_native_physics_clock(startup, clock) result(status)
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_radiation_clock_view), intent(inout) :: clock
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    clock%tstep => startup%initial%controls%clock%integration%first_dt
    clock%tdt => startup%initial%controls%clock%integration%second_dt
    clock%rstati => startup%initial%controls%clock%integration%relative_seconds
    clock%rcodec => startup%initial%controls%clock%integration%initial_solar(8)
    clock%rsidec => startup%initial%controls%clock%integration%initial_solar(9)
    clock%rwsovr => startup%initial%controls%clock%integration%initial_solar(6)
    clock%rcodecm => startup%forcing%radiation_clock%rcodecm
    clock%rsidecm => startup%forcing%radiation_clock%rsidecm
    clock%rwsovrm => startup%forcing%radiation_clock%rwsovrm
    clock%nstart => startup%initial%controls%clock%first_step
    clock%step => startup%initial%controls%clock%current_step
    clock%initial_date => startup%initial%controls%clock%initial_date
    clock%initial_seconds => startup%initial%controls%clock%initial_seconds
    status = 0_int32
  end function

  !> Convert the actual logical PPVI controls to the existing int32 interface.
  !! The source scalar owner is authoritative. Refresh after its producer
  !! changes either flag; the retained bridge has a stable target address.
  subroutine refresh_native_post_flag_encodings(factory, startup)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), intent(in) :: startup
    factory%lrppuv_cstext_encoding = merge(1_int32, 0_int32, startup%scalars%lrppuv_cstext)
    factory%lrppuv_callitpq_encoding = merge(1_int32, 0_int32, startup%scalars%lrppuv_callitpq)
  end subroutine

  !> Borrow genuine atmosphere, output-request and SUPP list targets.
  !! NO2DGG and M2DGGP are the produced original SUPP controls, not MFP2DF.
  !! Their actual target bounds remain live; only1:NO2DGG is consumed.
  integer(int32) function bind_native_post_controls(factory, startup, output, no2dgg, m2dggp) result(status)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_runtime_output_configuration), target, intent(inout) :: output
    integer(int32), target, intent(inout) :: no2dgg, m2dggp(:)
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (no2dgg < 0 .or. no2dgg > size(m2dggp)) return
    if (.not. is_contiguous(m2dggp)) return
    status = borrow_runtime_physical_output_requests(output, factory%post_controls%nfpphy, &
                                                     factory%post_controls%mfpphy, factory%post_controls%lrsacc)
    if (status /= 0_int32) return
    factory%post_controls%rdtdz1 => startup%initial%geometry%atmosphere%reference_tables(1)%gradient(1)
    factory%post_controls%rmdi => startup%scalars%rmdi
    factory%post_controls%nlextrap => startup%initial%geometry%atmosphere%extrapolation_level
    factory%post_controls%lecfpos => startup%initial%controls%namespace%lecfpos
    factory%post_controls%no2dgg => no2dgg
    factory%post_controls%m2dggp => m2dggp
    call refresh_native_post_flag_encodings(factory, startup)
    factory%post_controls%lrppuv_cstext => factory%lrppuv_cstext_encoding
    factory%post_controls%lrppuv_callitpq => factory%lrppuv_callitpq_encoding
    status = 0_int32
  end function

  !> Borrow actual tile and radiation flux owners for the common field registry.
  !! This routine has no allocator. Absent optional flux owners stay absent.
  !! All associated targets must remain fixed until the registry releases views.
  integer(int32) function bind_native_registry_science_inputs(startup, ecphysics, radiation) result(status)
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_registry_ecphysics_inputs), intent(inout) :: ecphysics
    type(native_registry_radiation_inputs), intent(inout) :: radiation
    status = 2_int32
    if (.not. associated(startup%loaded%fields)) return
    if (.not. allocated(startup%loaded%storage)) return
    associate (fields => startup%loaded%fields%ecphysics, flux => startup%loaded%storage%ecmwf%radiation%fluxes)
      if (.not. allocated(fields%rustrti) .or. .not. allocated(fields%rvstrti)) return
      if (.not. allocated(fields%rahfsti) .or. .not. allocated(fields%revapti) .or. .not. allocated(fields%rtskti)) return
      ecphysics%ustrti => fields%rustrti
      ecphysics%vstrti => fields%rvstrti
      ecphysics%ahfsti => fields%rahfsti
      ecphysics%evapti => fields%revapti
      ecphysics%tskti => fields%rtskti
      nullify (radiation%emtd)
      if (allocated(flux%emtd)) radiation%emtd => flux%emtd
      nullify (radiation%trsw)
      if (allocated(flux%trsw)) radiation%trsw => flux%trsw
      nullify (radiation%emtc)
      if (allocated(flux%emtc)) radiation%emtc => flux%emtc
      nullify (radiation%trsc)
      if (allocated(flux%trsc)) radiation%trsc => flux%trsc
      nullify (radiation%emtu)
      if (allocated(flux%emtu)) radiation%emtu => flux%emtu
      nullify (radiation%tauaer)
      if (allocated(flux%tauaer)) radiation%tauaer => flux%tauaer
      nullify (radiation%srswd)
      if (allocated(flux%srswd)) radiation%srswd => flux%srswd
      nullify (radiation%srlwdc)
      if (allocated(flux%srlwdc)) radiation%srlwdc => flux%srlwdc
      nullify (radiation%srlwd)
      if (allocated(flux%srlwd)) radiation%srlwd => flux%srlwd
      nullify (radiation%srswdc)
      if (allocated(flux%srswdc)) radiation%srswdc => flux%srswdc
      nullify (radiation%srswdcs)
      if (allocated(flux%srswdcs)) radiation%srswdcs => flux%srswdcs
      nullify (radiation%srlwdcs)
      if (allocated(flux%srlwdcs)) radiation%srlwdcs => flux%srlwdcs
      nullify (radiation%srswdv)
      if (allocated(flux%srswdv)) radiation%srswdv => flux%srswdv
      nullify (radiation%srswduv)
      if (allocated(flux%srswduv)) radiation%srswduv => flux%srswduv
      nullify (radiation%edro)
      if (allocated(flux%edro)) radiation%edro => flux%edro
      nullify (radiation%srswpar)
      if (allocated(flux%srswpar)) radiation%srswpar => flux%srswpar
      nullify (radiation%srswuvb)
      if (allocated(flux%srswuvb)) radiation%srswuvb => flux%srswuvb
      nullify (radiation%srswparc)
      if (allocated(flux%srswparc)) radiation%srswparc => flux%srswparc
      nullify (radiation%srswtinc)
      if (allocated(flux%srswtinc)) radiation%srswtinc => flux%srswtinc
      nullify (radiation%srfdir)
      if (allocated(flux%srfdir)) radiation%srfdir => flux%srfdir
      nullify (radiation%srcdir)
      if (allocated(flux%srcdir)) radiation%srcdir => flux%srcdir
      nullify (radiation%rmoon)
      if (allocated(flux%rmoon)) radiation%rmoon => flux%rmoon
      nullify (radiation%derivativelw)
      if (associated(flux%derivativelw)) radiation%derivativelw => flux%derivativelw
    end associate
    status = 0_int32
  end function
  !> Borrow the actual physical, thermal, stochastic and source-control targets.
  !! All TARGET arguments remain stationary until the provider record closes.
  !! HOOK_ENABLED and SCMEC_ENABLED are actual source controls. BYTE_LIMIT is
  !! the caller's retained resource ceiling in bytes. No value is substituted.
  integer(int32) function bind_native_physics_providers(factory, startup, thermal, stochastic, chemistry, &
                                                        hook_enabled, scmec_enabled, byte_limit) result(status)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(ecmwf_thermal_state_record), target, intent(inout) :: thermal
    type(tspp_config), target, intent(inout) :: stochastic
    type(tchem), target, intent(inout) :: chemistry
    logical, target, intent(inout) :: hook_enabled, scmec_enabled
    integer(int64), intent(in) :: byte_limit
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (byte_limit < 1_int64) return
    if (.not. factory%readonly%cellular_ready) return
    if (startup%loaded%storage%model%physics%ecmwf_physics%lslphy) then
      if (.not. allocated(startup%loaded%dynamic%rslwx)) return
    end if
    factory%providers%physical => startup%initial%constants
    factory%providers%thermal => thermal%thermal
    factory%providers%stability => thermal%stability
    factory%providers%physics3 => startup%loaded%storage%meteo_france%legacy_radiation_parameters
    factory%providers%stochastic_configuration => stochastic
    factory%providers%current_step => startup%initial%controls%clock%current_step
    factory%providers%initial_step => startup%initial%controls%clock%first_step
    factory%providers%hook_enabled => hook_enabled
    factory%providers%scmec_enabled => scmec_enabled
    factory%providers%chem_light_active => chemistry%lchem_light
    nullify (factory%providers%rslwx)
    if (allocated(startup%loaded%dynamic%rslwx)) factory%providers%rslwx => startup%loaded%dynamic%rslwx
    factory%providers%byte_limit = byte_limit
    factory%providers%runtime_scalars => startup%scalars
    factory%providers%ozone_chemistry => startup%forcing%ozone_chemistry
    factory%providers%solar_declination => startup%initial%controls%clock%integration%initial_solar(5)
    status = 0_int32
  end function

  !> Bind EC inputs that have one actual producer in the retained startup.
  !! Weather arrays, previous-state views, soil counts, NRFRAD and component
  !! selectors stay with their actual GP producer. This entry does not infer
  !! those inputs or claim a complete ready physics call.
integer(int32) function bind_native_ec_physics_inputs(factory, startup, runtime, sppt, stochastic, lnodryflx, inputs) result(status)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_physics_runtime_data), target, intent(inout) :: runtime
    type(tsppt_config), target, intent(inout) :: sppt
    type(tstoph), target, intent(inout) :: stochastic
    logical, target, intent(inout) :: lnodryflx
    type(native_complete_physics_driver_inputs), intent(inout) :: inputs
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. associated(startup%loaded%fields)) return
    if (.not. allocated(startup%initial%geometry%spherical%spherical%ngplat)) return
    inputs%physics => startup%loaded%storage%ecmwf
    inputs%runtime => runtime
    inputs%records%model => startup%loaded%storage%model
    inputs%records%geometry => startup%initial%geometry
    inputs%records%motion => startup%loaded%storage%model%motion
    inputs%records%variables => startup%loaded%fields%registry%variables
    inputs%records%surface_metadata => startup%loaded%input%surface_metadata
    inputs%surface_variables => startup%loaded%fields%registry%surface
    inputs%providers => factory%providers
    inputs%post_controls => factory%post_controls
    inputs%stochastic_physics => stochastic
    inputs%lspsdt = sppt%lspsdt
    inputs%nvtend = startup%loaded%dynamic%nvtend
    if (allocated(startup%loaded%dynamic%savtend)) inputs%arrays%saved_tendencies => startup%loaded%dynamic%savtend
    inputs%cellular%active = factory%readonly%cellular%lcuconv_ca
    inputs%lnodryflx => lnodryflx
    inputs%latitude => startup%initial%geometry%spherical%spherical%ngplat
    inputs%rcovsr => startup%initial%controls%clock%integration%initial_solar(10)
    inputs%rsivsr => startup%initial%controls%clock%integration%initial_solar(11)
    status = bind_native_physics_clock(startup, inputs%solar_clock)
  end function
  !> Run the actual selected NAMCA producer on its fresh source preimage.
  !! Records contain the genuine NAMCA input text. The source model constructor
  !! zero-born preimage establishes LCA_NBDEBUG, which NAMCA otherwise leaves
  !! unwritten. This is not a namelist default or a forced active-mode control.
  !! The actual LSLAG rule and requested active flag come from the real child.
  integer(int32) function prepare_native_cellular_controls(factory, startup, namca_records) result(status)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), target, intent(in) :: startup
    character(len=*), intent(in) :: namca_records(:)
    status = 2_int32
    if (factory%readonly%cellular_ready) return
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    factory%readonly%cellular%lca_nbdebug = .false.
    status = initialize_cellular_controls(factory%readonly, namca_records, &
                                      startup%initial%controls%namespace%lecmwf == 1_int32, startup%loaded%storage%model%dynamics, &
                                          startup%initial%geometry%spherical%resolution_length)
    factory%last_status = status
  end function
end module forecast_native_physics_context_bindings
