!> Bind the actual scientific and geometry owners used by RADDRV.
module forecast_native_radiation_context_factory
  use iso_fortran_env, only: int32
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_native_physics_factory_state, only: native_physics_context_factory_state
  use forecast_native_physics_context_bindings, only: bind_native_physics_clock
  use owned_ecmwf_thermal_state_port, only: ecmwf_thermal_state_record
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use yomchem, only: tchem
  use spp_mod, only: tspp_config
  implicit none
  private
  public :: bind_native_radiation_context
contains
  !> Associate real targets without copying weather fields or a model clock.
  !! STARTUP, FACTORY and THERMAL remain TARGET and stationary. The actual
  !! SUPHEC owner must be complete. PHYSICS supplies the already-produced GP
  !! vertical-velocity selector. Source controls are projected by name; this
  !! binding does not force them into a supported scientific branch.
  !! The caller retains all borrowed records and arrays until radiation closes.
  !! Status0 describes completed bindings only, not numerical qualification.
  integer(int32) function bind_native_radiation_context(factory, startup, thermal, chemistry, stochastic, &
                                                        physics, context) result(status)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(ecmwf_thermal_state_record), target, intent(inout) :: thermal
    type(tchem), target, intent(inout) :: chemistry
    type(tspp_config), target, intent(inout) :: stochastic
    type(native_complete_physics_driver_inputs), intent(in) :: physics
    type(native_radiation_driver_context), intent(inout) :: context
    integer(int32) :: q, l, i, a, r, s, o, f, first, last, offset, region
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. startup%loaded%storage%ecmwf%setup_complete) return
    if (.not. associated(startup%loaded%storage%ecmwf%surface)) return
    if (.not. associated(startup%initial%geometry%vertical)) return
    associate (geometry => startup%initial%geometry, model => startup%loaded%storage%model, &
               parameters => startup%loaded%storage%ecmwf, vertical => startup%initial%geometry%vertical)
      if (.not. allocated(vertical%vah) .or. .not. allocated(vertical%vbh)) return
      if (.not. allocated(vertical%vc) .or. .not. allocated(vertical%vaf) .or. .not. allocated(vertical%vbf)) return
      if (.not. allocated(vertical%vdela) .or. .not. allocated(vertical%vdelb)) return
      if (.not. allocated(geometry%spherical%blocked%gemu) .or. .not. allocated(geometry%spherical%blocked%gelam)) return
      if (.not. allocated(geometry%spherical%blocked%geclo) .or. .not. allocated(geometry%spherical%blocked%geslo)) return
      if (.not. allocated(geometry%grid%nstagp) .or. .not. allocated(geometry%partition%nonl)) return
      if (.not. allocated(geometry%terrain%blocks)) return
      q = model%fields%aliases%yq; l = model%fields%aliases%yl; i = model%fields%aliases%yi
      a = model%fields%aliases%ya; r = model%fields%aliases%yr; s = model%fields%aliases%ys
      o = model%fields%aliases%yo3; f = model%fields%aliases%yfsd
      if (min(q, l, i, a, r, s, o) < 1 .or. max(q, l, i, a, r, s, o) > size(model%fields%components)) return
      if (f < 0 .or. f > size(model%fields%components)) return
      first = geometry%partition%ndgsal
      last = geometry%partition%ndgenl
      offset = geometry%partition%nptrfloff
      region = geometry%partition%my_region_ew
      if (first < lbound(geometry%grid%nstagp, 1) .or. last > ubound(geometry%grid%nstagp, 1) .or. last < first) return
      if (offset + first < lbound(geometry%partition%nonl, 1) .or. offset + last > ubound(geometry%partition%nonl, 1)) return
      if (region < lbound(geometry%partition%nonl, 2) .or. region > ubound(geometry%partition%nonl, 2)) return
      factory%pressure%approximate_mode = vertical%configuration%ndlnpr
      factory%pressure%finite_elements = vertical%configuration%lvertfe /= 0
      factory%pressure%arithmetic_full_pressure = vertical%configuration%laprxpk /= 0
      factory%pressure%top_alpha = vertical%configuration%rhydr0
      factory%pressure%top_pressure = vertical%toppres
      factory%pressure%dry_gas_constant = startup%initial%constants%rd
      factory%pressure%dry_isochoric_heat_capacity = startup%initial%constants%rcvd
      context%constants => startup%initial%constants
      context%thermal => thermal%thermal
      context%configuration => model%physics
      context%setup => parameters%radiation
      context%surface => startup%loaded%input%surface_arrays
      context%surface_catalog => startup%loaded%input%surface_metadata
      context%surface_parameters => parameters%surface
      context%legacy_radiation => startup%loaded%storage%meteo_france%legacy_radiation_parameters
      context%physics_dimensions => model%physics_dimensions
      context%cloud_parameters => parameters%cloud
      context%pressure_controls => factory%pressure
      context%latitude_sine => geometry%spherical%blocked%gemu
      context%longitude => geometry%spherical%blocked%gelam
      context%longitude_cosine => geometry%spherical%blocked%geclo
      context%longitude_sine => geometry%spherical%blocked%geslo
      context%terrain => geometry%terrain
      nullify (context%orography)
      context%half_a => vertical%vah
      context%half_b => vertical%vbh
      context%vc => vertical%vc
      context%full_a => vertical%vaf
      context%full_b => vertical%vbf
      context%delta_a => vertical%vdela
      context%delta_b => vertical%vdelb
      context%latitude_first(1:) => geometry%grid%nstagp(first:last)
      context%latitude_points(1:) => geometry%partition%nonl(offset + first:offset + last, region)
      ! The source RADCFG work array uses its seven fixed GPHPRE slots.
      context%pressure_field_indices = [1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32]
      context%water_plane = model%fields%components(q)%mp9_ph
      context%liquid_plane = model%fields%components(l)%mp9_ph
      context%ice_plane = model%fields%components(i)%mp9_ph
      context%cloud_fraction_plane = model%fields%components(a)%mp9_ph
      context%rain_plane = model%fields%components(r)%mp9_ph
      context%snow_plane = model%fields%components(s)%mp9_ph
      context%ozone_plane = model%fields%components(o)%mp9_ph
      context%spread_plane = 0_int32
      if (f > 0) context%spread_plane = model%fields%components(f)%mp9_ph
      context%vertical_velocity_plane = physics%vertical_velocity_first
      context%active_aerosols = model%fields%settings%nactaero
      context%aerosol_species = model%fields%alias_controls%naero
      context%chemistry_species = model%fields%alias_controls%nchem
      context%spread_species = model%fields%settings%nfsd
      context%global_latitude_count = geometry%dimensions%ndglg
      context%no3cmip = startup%forcing%cmip%no3cmip
      context%nimp = startup%scalars%nimp
      context%nout = startup%scalars%nout
      context%local_points = geometry%partition%ngptot
      context%block_columns = geometry%dimensions%nproma
      context%levels = geometry%dimensions%nflevg
      context%planet_area_scale = model%dynamical_core%rpldare
      context%gravity_scale = model%dynamical_core%rplrg
      context%stochastic_enabled = stochastic%lspp
      context%prognostic_ozone = parameters%radiation%radiation%lepo3ra .and. model%fields%components(o)%lgp == 1_int32
      context%chemistry_ozone = parameters%radiation%radiation%lepo3ra .and. &
                                model%fields%alias_controls%nchem > 0 .and. chemistry%lchem_o3rad
      context%two_time_levels = model%dynamics%ltwotl
      context%same_radiation_grid = parameters%radiation%radiation%nmode == 0_int32
      context%sea_ice_albedo_enabled = model%climate%lnemolimalb
    end associate
    status = bind_native_physics_clock(startup, context%clock)
  end function
end module forecast_native_radiation_context_factory
