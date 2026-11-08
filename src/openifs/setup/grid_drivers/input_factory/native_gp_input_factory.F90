!> Bind actual native forecast owners and strided linear fields.
!! This is the completed base of the GP input factory. Full block-work and
!! physics/radiation setup projection remain pending; READY stays false.
module forecast_native_gp_input_factory
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use forecast_native_gp_factory_types, only: native_gp_factory_work
  use forecast_grid_work_state, only: native_grid_work_state
  use forecast_grid_storage, only: initialize_forecast_grid_work
  use forecast_next_time_field_storage, only: next_time_field_shape, prepare_runtime_next_time_fields
  use mpi_f08, only: MPI_Comm
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs
  use forecast_grid_point_update_strided, only: grid_point_column_views
  use md2asm_lagrangian_grid_update_strided, only: lagrangian_linear_inputs
  use forecast_grid_motion_types, only: native_grid_motion_state
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use forecast_spectral_setup_state, only: native_spectral_calculation_state
  use forecast_native_dynamic_storage, only: native_forecast_dynamic_storage
  use forecast_orography_initialization, only: native_blocked_orography
  use forecast_dynamics_field_maps, only: initialize_dynamics_field_maps

  use forecast_retained_transport_dispatch, only: release_runtime_retained_transport
  use forecast_complete_forecast_grid_driver_strided, only: native_grid_block_inputs
  use md2asm_native_call_sl, only: native_call_sl_arrays
  use md2asm_departure_interpolation_weights, only: departure_weight_geometry
  use md2asm_trajectory_interpolation_parent, only: trajectory_latitude_partition
  use md2asm_departure_coordinate_fields, only: trajectory_field_component
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use forecast_native_field_variable_types, only: native_registry_geometry_inputs, &
                                   native_registry_ecphysics_inputs, native_registry_radiation_inputs, native_registry_extra_aliases
  use forecast_tracer_mass_correction_types, only: tracer_mass_grid
  implicit none
  private
  public :: native_gp_factory_work, bind_native_gp_base_owners, bind_native_gp_linear_inputs
  public :: prepare_native_gp_weather_bindings, bind_native_gp_physics_weather_inputs
  public :: prepare_native_gp_metadata, bind_native_gp_grid_storage, bind_native_gp_column_inputs
  public :: bind_native_gp_source_buffer_maps, refresh_native_gp_visit_controls, release_native_gp_input_factory
  interface
    function factory_errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Prepare the real weather descriptors before final physics/radiation binding.
  !! All targets keep their final addresses through GP and its release. This
  !! stage creates metadata and reuses the canonical GRIDWORK/next-time owners.
  !! It never publishes full readiness or reads the constructor's undefined step.
  subroutine prepare_native_gp_weather_bindings(work, grid, startup, spectral, physics, radiation, storage, &
                                                byte_quota, comm, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_spectral_calculation_state), target, intent(inout) :: spectral
    type(native_complete_physics_driver_inputs), target, intent(inout) :: physics
    type(native_radiation_driver_context), target, intent(inout) :: radiation
    type(native_grid_work_state), target, intent(inout) :: storage
    integer(int64), intent(in) :: byte_quota
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(out) :: status
    status = 2
    if (work%phase /= 0) return
    call bind_native_gp_base_owners(work, grid, startup, physics, radiation, comm, status)
    if (status /= 0) return
    call prepare_native_gp_metadata(work, grid, byte_quota, status)
    if (status /= 0) return
    call bind_native_gp_grid_storage(work, grid, storage, byte_quota, status)
    if (status /= 0) return
    call bind_native_gp_column_inputs(work, grid, spectral, startup%loaded%dynamic, &
                                      startup%loaded%input%terrain, status)
    if (status /= 0) return
    call bind_native_gp_source_buffer_maps(work, grid, status)
    if (status /= 0) return
    call bind_native_gp_physics_weather_inputs(grid, status)
    if (status /= 0) return
    grid%workspace_limit = byte_quota
    work%phase = 3
  end subroutine

  !> Borrow persistent EC arrays and the source PB2 vertical-velocity selector.
  !! The actual GP body creates and binds its five private columns and four
  !! split arrays at their source call positions; no duplicate weather is made.
  !! RADCFG reads PB2 at actual MSLB2VVEL, not a constructor-default plane.
  subroutine bind_native_gp_physics_weather_inputs(grid, status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    integer(int32), intent(out) :: status
    integer(int32) :: slot
    status = 2
    if (.not. associated(grid%physics) .or. .not. associated(grid%model)) return
    if (.not. associated(grid%fields) .or. .not. associated(grid%next)) return
    if (.not. associated(grid%second_buffer)) return
    slot = grid%model%buffers%second%mslb2vvel
    if (slot < 1 .or. slot > size(grid%second_buffer, 2)) return
    grid%physics%vertical_velocity_first = slot
    grid%physics%t1_components = [grid%model%motion%yt1%mu, grid%model%motion%yt1%mv, grid%model%motion%yt1%mt]
    grid%physics%ph9_components = [grid%model%motion%yph9%mu, grid%model%motion%yph9%mv, grid%model%motion%yph9%mt]
    grid%physics%arrays%pgmv => grid%model%motion%gmv
    grid%physics%arrays%pgmvt1 => grid%model%motion%gmvt1
    grid%physics%arrays%gfl => grid%fields%gfl
    grid%physics%arrays%gflslp => grid%fields%gflslp
    grid%physics%arrays%gflt1 => grid%next%gflt1
    grid%physics%arrays%pb2 => grid%second_buffer
    status = 0
  end subroutine

  !> Borrow the actual startup, physics and radiation owners at final addresses.
  !! No numerical field, context work or calculated stage is manufactured.
  !! Status0 completes only this base join; full-factory READY remains false.
  subroutine bind_native_gp_base_owners(work, grid, startup, physics, radiation, comm, status)
    type(native_gp_factory_work), intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_complete_physics_driver_inputs), target, intent(inout) :: physics
    type(native_radiation_driver_context), target, intent(inout) :: radiation
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(out) :: status
    status = 2
    if (work%phase /= 0 .or. work%ready) return
    if (.not. allocated(startup%loaded%storage) .or. .not. allocated(startup%loaded%input)) return
    if (.not. associated(startup%loaded%fields)) return
    if (.not. startup%loaded%storage%model%ready) return
    grid%model => startup%loaded%storage%model
    grid%fields => startup%loaded%input%upper%fields
    grid%next => startup%loaded%next
    grid%registry => startup%loaded%fields%registry
    grid%surface_metadata => startup%loaded%input%surface_metadata
    grid%surface_arrays => startup%loaded%input%surface_arrays
    grid%physics => physics
    grid%radiation => radiation
    grid%communicator = comm
    work%phase = 1; work%base_bound = .true.; status = 0
  end subroutine

  !> Bind current derivatives and actual nonadjacent current/previous winds.
  !! Motion is GMV(P,L,F,B), surface motion is GMVS(P,S,B). U/V use m/s,
  !! thermal derivatives K/m, divergence1/s and Coriolis1/s. Every pointer
  !! borrows its source owner. No packing, allocation or weather copy occurs.
  !! The two-time-level source consumes only current derivative planes.
  subroutine bind_native_gp_linear_inputs(linear, motion, block, coriolis, status)
    type(lagrangian_linear_inputs), intent(inout) :: linear
    type(native_grid_motion_state), target, intent(inout) :: motion
    integer(int32), intent(in) :: block
    real(real64), target, intent(in) :: coriolis(:)
    integer(int32), intent(out) :: status
    integer(int32) :: m(7), q(2), j, du, dv, p
    status = 2
    if (.not. allocated(motion%gmv) .or. .not. allocated(motion%gmvs)) return
    if (block < 1 .or. block > size(motion%gmv, 4) .or. block > size(motion%gmvs, 3)) return
    m = [motion%yt0%mdiv, motion%yt0%mtl, motion%yt0%mtm, motion%yt0%mu, motion%yt9%mu, &
         motion%yt0%mv, motion%yt9%mv]
    q = [motion%yt0%mspl, motion%yt0%mspm]
    if (any(m < 1) .or. any(m > size(motion%gmv, 3))) return
    if (any(q < 1) .or. any(q > size(motion%gmvs, 2))) return
    du = m(5) - m(4); dv = m(7) - m(6)
    if (du == 0 .or. dv == 0) return
    p = size(motion%gmv, 1)
    if (size(motion%gmvs, 1) /= p .or. size(coriolis) < 1 .or. size(coriolis) > p) return
    linear%divergence => motion%gmv(:, :, m(1):m(1), block)
    linear%temperature_l => motion%gmv(:, :, m(2):m(2), block)
    linear%temperature_m => motion%gmv(:, :, m(3):m(3), block)
    linear%surface_l => motion%gmvs(:, q(1):q(1), block)
    linear%surface_m => motion%gmvs(:, q(2):q(2), block)
    linear%wind_u => motion%gmv(:, :, m(4):m(5):du, block)
    linear%wind_v => motion%gmv(:, :, m(6):m(7):dv, block)
    linear%coriolis => coriolis
    status = 0
  end subroutine

  !> Build source field selectors from the one configured GFL metadata owner.
  !! This allocates descriptors and integer counters only. No weather value
  !! is calculated or initialized here. COUNTERS are outputs of LAVENT.
  !! The canonical next-time producer owns any required T1 field allocation.
  subroutine prepare_native_gp_metadata(work, grid, byte_quota, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    integer(int64), intent(in) :: byte_quota
    integer(int32), intent(out) :: status
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved_errno
    integer :: p, l, b, n, j, k, code
    integer(int64) :: need
    type(next_time_field_shape) :: shape
    status = 2
    if (.not. work%base_bound .or. work%maps_bound) return
    if (.not. associated(grid%model) .or. .not. associated(grid%fields) .or. .not. associated(grid%next)) return
    p = grid%model%initial%geometry%dimensions%nproma
    l = grid%model%initial%geometry%dimensions%nflevg
    b = grid%model%initial%geometry%partition%ngpblks
    n = grid%model%fields%registration%numflds
    if (p < 1 .or. p > 256 .or. l < 5 .or. l > 137 .or. b < 1 .or. b > 1000000 .or. n < 0 .or. n > 2163) return
    if (size(grid%model%fields%components) < n) return
    if (.not. allocated(grid%fields%gfl) .or. .not. associated(grid%fields%constituents)) return
    if (allocated(work%columns) .or. allocated(work%work_components) .or. allocated(work%counters)) return
    if (grid%model%initial%constants%initialized == 0) return
    do j = 1, n
      associate (c => grid%model%fields%components(j))
        if (c%ladv /= 0) then
          if (c%mp < 1 .or. c%mp > size(grid%fields%gfl, 3)) return
        end if
      end associate
    end do
    need = int(b, int64)*(int(storage_size(grid_point_column_views())/8, int64) + 4_int64*l)
    need = need + int(n, int64)*(512_int64 + int(b, int64)*160_int64)
    if (need < 0 .or. need > byte_quota) return
    shape = next_time_field_shape(p, l, b, grid%model%fields%registration%ndim1)
    status = prepare_runtime_next_time_fields(grid%model%motion, grid%next, shape, byte_quota)
    if (status /= 0) return
    call c_f_pointer(factory_errno_location(), ep); saved_errno = ep
    allocate (work%columns(b), stat=code)
    if (code /= 0) goto800
    allocate (work%work_components(n), work%tracer_pairs(n), work%physics_components(n), stat=code)
    if (code /= 0) goto800
    allocate (work%transport_components(n, b), work%boundary_components(n), work%destinations(n), stat=code)
    if (code /= 0) goto800
    allocate (work%selectors(n), work%diagnostics(0), work%counters(l, b), stat=code)
    if (code /= 0) goto800
    ep = saved_errno
    associate (c => grid%model%initial%constants)
      work%constants%dry_gas_constant = c%rd
      work%constants%dry_heat_capacity = c%rcpd
      work%constants%vapour_gas_constant = c%rv
      work%constants%vapour_heat_capacity = c%rcpv
      work%constants%liquid_heat_capacity = c%rcw
      work%constants%ice_heat_capacity = c%rcs
    end associate
    do j = 1, n
      associate (c => grid%model%fields%components(j))
        work%work_components(j)%advected = c%ladv /= 0
        work%work_components(j)%active = c%lactive /= 0
        work%work_components(j)%tendency_required = c%lt1 /= 0
        work%work_components(j)%current_field = c%mp
        work%work_components(j)%earlier_field = c%mp9
        work%work_components(j)%new_field = c%mp1
        work%tracer_pairs(j)%source = c%mp
        work%tracer_pairs(j)%destination = c%mp9
        work%tracer_pairs(j)%enabled = c%lt9 /= 0
        work%physics_components(j)%lphy = c%lphy /= 0
        work%physics_components(j)%mpslp = c%mpslp
        work%boundary_components(j)%advected = c%ladv /= 0
        work%boundary_components(j)%external_grid = c%lmgrid /= 0
        work%boundary_components(j)%physics = c%lphy /= 0
        work%boundary_components(j)%diabatic_linear = c%ltdiablin /= 0
        work%boundary_components(j)%source_slot = c%mp_sl1
        work%boundary_components(j)%physics_slot = c%mpslp
        work%boundary_components(j)%name = c%cname
        work%boundary_components(j)%selector = c%cslint
        work%boundary_components(j)%weno_exponent = c%weno_alpha
        work%destinations(j)%slot = c%mp1
        work%destinations(j)%grid_point = c%lgp /= 0
        work%selectors(j) = c%cslint
        do k = 1, b
          work%transport_components(j, k)%advected = c%ladv /= 0
          work%transport_components(j, k)%spline_transform = grid%model%dynamics%lvsplip
          if (c%ladv /= 0) then
            work%transport_components(j, k)%current => grid%fields%gfl(:, :, c%mp, k)
          end if
        end do
      end associate
    end do
    status = initialize_dynamics_field_maps(work%dynamics_maps)
    if (status /= 0) goto800
    grid%blocks%constants => work%constants
    grid%blocks%thermal_components => grid%fields%constituents
    grid%blocks%work_components => work%work_components
    grid%blocks%tracer_pairs => work%tracer_pairs
    grid%blocks%physics_components => work%physics_components
    grid%blocks%transport_components => work%transport_components
    grid%blocks%boundary_components => work%boundary_components
    grid%blocks%columns => work%columns
    grid%blocks%counters => work%counters
    grid%transport_update%components => work%boundary_components
    grid%transport_update%destinations => work%destinations
    grid%trajectory%selectors => work%selectors
    grid%trajectory%diagnostics => work%diagnostics
    grid%retained => work%retained
    work%pitch = p; work%levels = l; work%blocks = b; work%components = n; work%metadata_bytes = need
    work%maps_bound = .true.; work%phase = 2; status = 0
    return
800 continue
    status = 1
    if (allocated(work%counters)) deallocate (work%counters)
    if (allocated(work%diagnostics)) deallocate (work%diagnostics)
    if (allocated(work%selectors)) deallocate (work%selectors)
    if (allocated(work%destinations)) deallocate (work%destinations)
    if (allocated(work%boundary_components)) deallocate (work%boundary_components)
    if (allocated(work%transport_components)) deallocate (work%transport_components)
    if (allocated(work%physics_components)) deallocate (work%physics_components)
    if (allocated(work%tracer_pairs)) deallocate (work%tracer_pairs)
    if (allocated(work%work_components)) deallocate (work%work_components)
    if (allocated(work%columns)) deallocate (work%columns)
  end subroutine

  !> Allocate the one real grid-work owner,then borrow its exact source views.
  !! PB1 keeps zero-based row addresses; all other owners keep source bounds.
  !! New storage remains unwritten until its genuine numerical parent uses it.
  subroutine bind_native_gp_grid_storage(work, grid, storage, byte_quota, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_grid_work_state), target, intent(inout) :: storage
    integer(int64), intent(in) :: byte_quota
    integer(int32), intent(out) :: status
    integer(int64) :: n
    status = 2
    if (.not. work%maps_bound) return
    n = int(grid%model%interpolation%naslb1, int64)
    status = initialize_forecast_grid_work(storage, work%pitch, work%levels, work%blocks, &
                                           grid%model%linear_full%ndim, n, grid%model%buffers%first%nfldslb1, &
                                           grid%model%buffers%second%nfldslb2, byte_quota)
    if (status /= 0) return
    grid%first_buffer(0:n - 1, 1:size(storage%zslbuf1, 2)) => storage%zslbuf1
    grid%second_buffer => storage%zslbuf2
    grid%transport_arrays%parent_index => storage%il0
    grid%transport_arrays%linear_weights => storage%zlscaw
    grid%transport_arrays%second_buffer => storage%zslbuf2
    status = 0
  end subroutine

  !> Bind column inputs to actual geometry,reference and weather owners.
  !! Geometry lengths are metres,angles radians,time seconds and pressure Pa.
  !! This produces descriptors only. CPG owns its private calculated arrays.
  subroutine bind_native_gp_column_inputs(work, grid, spectral, dynamic, terrain, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_spectral_calculation_state), target, intent(inout) :: spectral
    type(native_forecast_dynamic_storage), target, intent(inout) :: dynamic
    type(native_blocked_orography), target, intent(in) :: terrain
    integer(int32), intent(out) :: status
    integer :: ib, p, l, b, i, field
    integer :: mp(12)
    status = 2
    if (.not. work%maps_bound .or. work%columns_bound .or. .not. spectral%ready) return
    if (.not. associated(spectral%model, grid%model)) return
    p = work%pitch; l = work%levels; b = work%blocks
    if (.not. associated(grid%first_buffer) .or. .not. associated(grid%second_buffer)) return
    if (.not. allocated(terrain%orog) .or. .not. allocated(terrain%orogl) .or. .not. allocated(terrain%orogm)) return
    if (any(shape(terrain%orog) /= [p, b]) .or. any(shape(terrain%orogl) /= [p, b]) .or. &
        any(shape(terrain%orogm) /= [p, b])) return
    if (.not. allocated(grid%model%motion%gmvt1) .or. .not. allocated(grid%model%motion%gmvt1s)) return
    if (.not. allocated(grid%next%gflt1)) return
    associate (g => grid%model%initial%geometry, m => grid%model%motion, v => grid%model%initial%geometry%vertical)
      if (.not. v%constructor_ready .or. .not. v%eta_bounds_ready) return
      if (.not. allocated(g%spherical%blocked%rcori) .or. .not. allocated(g%spherical%blocked%gm)) return
      if (size(g%spherical%blocked%rcori, 1) /= p .or. size(g%spherical%blocked%rcori, 2) /= b) return
      mp = [m%yt0%mu, m%yt0%mv, m%yt0%mt, m%yt9%mu, m%yt9%mv, m%yt9%mt, &
            m%yt9%medot, m%yt9%mspnl, m%yt1%mu, m%yt1%mv, m%yt1%mt, m%yt0%mdiv]
      if (any(mp < 1)) return
      if (any(mp(1:8) > size(m%gmv, 3)) .or. mp(12) > size(m%gmv, 3)) return
      if (any(mp(9:11) > size(m%gmvt1, 3))) return
      if (min(m%yt0%msp, m%yt9%msp, m%yt1%msp) < 1) return
      grid%blocks%tables => spectral%context%vertical_matrices
      grid%blocks%coefficients => spectral%context%implicit_coefficients
      grid%blocks%vertical%vah(0:l) => v%vah
      grid%blocks%vertical%vbh(0:l) => v%vbh
      grid%blocks%vertical%vc => v%vc
      grid%blocks%vertical%vaf => v%vaf
      grid%blocks%vertical%vbf => v%vbf
      grid%blocks%vertical%vdela => v%vdela
      grid%blocks%vertical%vdelb => v%vdelb
      grid%blocks%vertical%inverse_coordinate_depth => v%vfe_rdetah
      grid%blocks%vertical%metric => v%vfe_rdetah
      grid%blocks%surface_map%log_pressure = m%yt0%msp
      grid%blocks%surface_map%log_gradient_x = m%yt0%mspl
      grid%blocks%surface_map%log_gradient_y = m%yt0%mspm
      grid%blocks%motion_map%u = m%yt0%mu
      grid%blocks%motion_map%v = m%yt0%mv
      grid%blocks%motion_map%temperature = m%yt0%mt
      grid%blocks%motion_map%temperature_x = m%yt0%mtl
      grid%blocks%motion_map%temperature_y = m%yt0%mtm
      grid%blocks%motion_map%divergence = m%yt0%mdiv
      grid%blocks%motion_map%force_x = m%yt0%msgrtl
      grid%blocks%motion_map%force_y = m%yt0%msgrtm
      grid%blocks%motion_map%previous_force_x = m%yt9%msgrtl
      grid%blocks%motion_map%previous_force_y = m%yt9%msgrtm
      grid%geometry_blocks => g%spherical%blocked%spherical_views
      grid%blocks%core_index => grid%model%interpolation%nslcore
      do ib = 1, b
        associate (c => work%columns(ib))
          c%motion => m%gmv(:, :, :, ib)
          c%surface(1:p, 1:1, 1:size(m%gmvs, 2)) => m%gmvs(:, :, ib)
          c%tracers => grid%fields%gfl(:, :, :, ib)
          c%terrain => terrain%orog(:, ib)
          c%raw_terrain_x => terrain%orogl(:, ib)
          c%raw_terrain_y => terrain%orogm(:, ib)
          c%map_metric => g%spherical%blocked%gm(:, ib)
          c%coriolis => g%spherical%blocked%rcori(:, ib)
          c%gm => g%spherical%blocked%gm(:, ib)
          c%eta(0:l) => v%vetah
          c%sin_latitude => g%spherical%blocked%gemu(:, ib)
          c%cos_latitude => g%spherical%blocked%gsqm2(:, ib)
          c%cos_longitude => g%spherical%blocked%geclo(:, ib)
          c%sin_longitude => g%spherical%blocked%geslo(:, ib)
          c%previous_eta_rate => m%gmv(:, :, m%yt9%medot, ib)
          c%full_level_correction => spectral%reference_temperature%rcordif
          c%half_level_correction(0:l) => spectral%reference_temperature%rcordih
          c%layer_weight => v%vdelb
          c%inverse_eta_thickness => v%vfe_rdetah
          c%global_first_buffer => grid%first_buffer
          c%previous%u%values => m%gmv(:, :, m%yt9%mu, ib)
          c%previous%v%values => m%gmv(:, :, m%yt9%mv, ib)
          c%previous%temperature%values => m%gmv(:, :, m%yt9%mt, ib)
          c%previous%surface_pressure%values(1:p, 1:1) => m%gmvs(:, m%yt9%msp, ib)
          c%work%u%values => m%gmvt1(:, :, m%yt1%mu, ib)
          c%work%v%values => m%gmvt1(:, :, m%yt1%mv, ib)
          c%work%temperature%values => m%gmvt1(:, :, m%yt1%mt, ib)
          c%work%surface_pressure%values(1:p, 1:1) => m%gmvt1s(:, m%yt1%msp, ib)
          c%work%tracers => grid%next%gflt1(:, :, :, ib)
          c%work%bank => grid%second_buffer(:, :, ib)
          if (allocated(dynamic%savtend)) c%saved_tendencies => dynamic%savtend(:, :, :, ib)
          c%tracer_rates => grid%fields%gflslp(:, :, :, ib)
          call bind_native_gp_linear_inputs(c%linear, m, int(ib, int32), g%spherical%blocked%rcori(:, ib), status)
          if (status /= 0) return
          c%transport%wind_u%pxt0%values => m%gmv(:, :, m%yt0%mu, ib)
          c%transport%wind_v%pxt0%values => m%gmv(:, :, m%yt0%mv, ib)
          c%transport%wind_u%pxt9%values => m%gmv(:, :, m%yt9%mu, ib)
          c%transport%wind_v%pxt9%values => m%gmv(:, :, m%yt9%mv, ib)
          if (m%yt9%munl >= 1 .and. m%yt9%munl <= size(m%gmv, 3)) &
            c%transport%wind_u%pxnlt9%values => m%gmv(:, :, m%yt9%munl, ib)
          if (m%yt9%mvnl >= 1 .and. m%yt9%mvnl <= size(m%gmv, 3)) &
            c%transport%wind_v%pxnlt9%values => m%gmv(:, :, m%yt9%mvnl, ib)
          if (m%yt9%mtnl >= 1 .and. m%yt9%mtnl <= size(m%gmv, 3)) &
            c%transport%temperature%pxnlt9%values => m%gmv(:, :, m%yt9%mtnl, ib)
          c%surface_transport%wind_u => m%gmv(:, :, m%yt0%mu, ib)
          c%surface_transport%wind_v => m%gmv(:, :, m%yt0%mv, ib)
          c%surface_transport%log_gradient_l => m%gmvs(:, m%yt0%mspl, ib)
          c%surface_transport%log_gradient_m => m%gmvs(:, m%yt0%mspm, ib)
          c%transport%temperature%pxt0%values => m%gmv(:, :, m%yt0%mt, ib)
          c%transport%temperature%pxt9%values => m%gmv(:, :, m%yt9%mt, ib)
          c%transport%wind_u%pxt1%values => m%gmvt1(:, :, m%yt1%mu, ib)
          c%transport%wind_v%pxt1%values => m%gmvt1(:, :, m%yt1%mv, ib)
          c%transport%temperature%pxt1%values => m%gmvt1(:, :, m%yt1%mt, ib)
          c%surface_transport%current_surface => m%gmvs(:, m%yt0%msp, ib)
          c%surface_transport%saved_surface => m%gmvs(:, m%yt9%msp, ib)
          c%surface_transport%new_surface => m%gmvt1s(:, m%yt1%msp, ib)
          c%surface_transport%residual_history => m%gmv(:, :, m%yt9%mspnl, ib)
        end associate
      end do
      grid%registry_geometry%gm => g%spherical%blocked%gm
      grid%transport_arrays%old_moisture => grid%fields%gfl(:, :, &
                                                            grid%model%fields%components(grid%model%fields%aliases%yq)%mp, :)
      if (allocated(dynamic%rsavedp)) grid%transport_arrays%saved_departure => dynamic%rsavedp
      grid%trajectory%full_eta => v%vetaf
      grid%trajectory%half_eta => v%vetah
      grid%transport_update%layer_weight => v%vdelb
      grid%transport_update%inverse_layer_width => v%vfe_rdetah
      grid%transport_update%tables = spectral%context%vertical_matrices
      grid%transport_update%dry_gas_constant = work%constants%dry_gas_constant
    end associate
    work%columns_bound = .true.; work%phase = 3; status = 0
  end subroutine

  !> Project actual SLBUF1/2 named prefixes into the consumed CPG views.
  !! Source maps are read only. CPG binds private PB1 views during each call;
  !! the persistent PB2 views below remain in the single real gridwork owner.
  subroutine bind_native_gp_source_buffer_maps(work, grid, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    integer(int32), intent(out) :: status
    integer :: ib, l, j, k, starts(7)
    status = 2
    if (.not. work%columns_bound .or. .not. associated(grid%second_buffer)) return
    l = work%levels
    associate (one => grid%model%buffers%first, two => grid%model%buffers%second, &
               c => grid%blocks%controls%column)
      c%source_buffers%trajectory = [one%mslb1ur0, one%mslb1vr0, one%mslb1zr0, one%mslb1wr0]
      c%source_buffers%transported = [one%mslb1u9, one%mslb1v9, one%mslb1t9]
      c%source_buffers%linear = [one%mslb1u0, one%mslb1v0, one%mslb1t0]
      c%source_buffers%forcing = [one%mslb1uf9, one%mslb1vf9, one%mslb1tf9]
      c%source_buffers%diagnostic = [one%mslb1u9_si, one%mslb1v9_si, one%mslb1t9_si]
      c%source_buffers%continuity = one%mslb1c9
      c%source_buffers%surface_pressure = one%mslb1sp9
      c%source_buffers%constituents = one%mslb1gfl9
      c%physics_u = one%mslb1up9; c%physics_v = one%mslb1vp9
      c%physics_t = one%mslb1tp9; c%physics_tracers = one%mslb1gflp9
      grid%blocks%boundary_maps%trajectory = int(c%source_buffers%trajectory, int64)
      grid%blocks%boundary_maps%transported = int(c%source_buffers%transported, int64)
      grid%blocks%boundary_maps%current = int(c%source_buffers%linear, int64)
      grid%blocks%boundary_maps%physics = int([one%mslb1up9, one%mslb1vp9, one%mslb1tp9], int64)
      grid%blocks%boundary_maps%continuity = int(one%mslb1c9, int64)
      grid%blocks%boundary_maps%constituents = int(one%mslb1gfl9, int64)
      grid%blocks%boundary_maps%physics_constituents = int(one%mslb1gflp9, int64)
      starts = [two%mslb2url, two%mslb2vrl, two%mslb2zrl, two%mslb2wrl, &
                two%mslb2usi, two%mslb2vsi, two%mslb2tsi]
      if (any(starts < 1) .or. any(starts > size(grid%second_buffer, 2) - l + 1)) return
      if (two%mslb2spsi < 1 .or. two%mslb2spsi > size(grid%second_buffer, 2)) return
      do ib = 1, work%blocks
        associate (v => work%columns(ib))
          j = two%mslb2url; v%wind%current_x => grid%second_buffer(:, j:j + l - 1, ib)
          j = two%mslb2vrl; v%wind%current_y => grid%second_buffer(:, j:j + l - 1, ib)
          j = two%mslb2zrl; v%wind%current_z => grid%second_buffer(:, j:j + l - 1, ib)
          j = two%mslb2wrl; v%wind%current_eta => grid%second_buffer(:, j:j + l - 1, ib)
          j = two%mslb2usi; v%transport%wind_u%pxsi%values => grid%second_buffer(:, j:j + l - 1, ib)
          j = two%mslb2vsi; v%transport%wind_v%pxsi%values => grid%second_buffer(:, j:j + l - 1, ib)
          j = two%mslb2tsi; v%transport%temperature%pxsi%values => grid%second_buffer(:, j:j + l - 1, ib)
          v%surface_transport%linear_buffer => grid%second_buffer(:, two%mslb2spsi, ib)
        end associate
      end do
    end associate
    status = 0
  end subroutine

  !> Refresh only the real visit-dependent GP controls.
  !! CONFIGURATION and DIGITAL_FILTER_STEP are the actual CNT4/STEPO/SCAN
  !! call arguments. The one clock supplies NSTEP,TSTEP,TDT and produced RTDT.
  !! The constructor's undefined NSTEP is valid during setup; this procedure
  !! is called only after CNT4 has published the actual step before SCAN.
  !! Status2 rejects this source route before changing any control record.
  subroutine refresh_native_gp_visit_controls(grid, configuration, digital_filter_step, lfindvsep, status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    character(len=9), intent(in) :: configuration
    logical, intent(in) :: digital_filter_step, lfindvsep
    integer(int32), intent(out) :: status
    integer(int32) :: step
    real(real64) :: tdt, tstep, rtdt
    logical :: first
    status = 2
    if (.not. associated(grid%model) .or. .not. associated(grid%radiation)) return
    if (.not. associated(grid%model%initial) .or. .not. associated(grid%radiation%setup)) return
    if (.not. grid%model%ready .or. .not. grid%model%initial%ready) return
    if (configuration(4:4) /= 'A' .and. configuration(4:4) /= 'B') return
    if (digital_filter_step) return
    associate (clock => grid%model%initial%controls%clock)
      step = clock%current_step
      if (step < 0) return
      tdt = clock%integration%second_dt
      tstep = clock%integration%first_dt
      rtdt = clock%integration%work(5)
    end associate
    if (tdt <= 0.0_real64 .or. tstep <= 0.0_real64) return
    first = step == grid%model%initial%controls%clock%integration%first_step
    grid%controls%configuration = configuration
    grid%controls%digital_filter_step = digital_filter_step
    grid%lagged%step = step
    grid%lagged%configuration_x = configuration(4:4) == "X"
    grid%controls%step = step
    grid%controls%radiation_frequency = grid%radiation%setup%radiation%nradfr
    grid%controls%implicit_radiation = grid%model%physics%ecmwf_physics%leradimpl
    grid%controls%radiation_enabled = grid%model%physics%ecmwf_physics%leradi
    grid%blocks%controls%configuration = configuration(4:4)
    grid%blocks%controls%step = step
    grid%blocks%controls%model_interval = tdt
    grid%blocks%controls%schedule_time_step = tstep
    grid%blocks%controls%column%time_step = tdt
    grid%blocks%controls%column%model_interval = tdt
    grid%blocks%controls%column%physics_interval = tdt
    grid%blocks%controls%column%first_step = first
    grid%blocks%controls%column%grid%first_step = first
    grid%blocks%controls%column%lagrangian%wind%step = step
    grid%blocks%controls%column%lagrangian%surface%step = step
    grid%blocks%controls%column%lagrangian%transport%term%step = step
    grid%trajectory%fields%find_vertical_separation = lfindvsep
    grid%trajectory%trajectory%step = step
    grid%trajectory%trajectory%time_factor = rtdt
    status = 0
  end subroutine

  !> End GP borrowed views before any source numerical owner is released.
  !! This releases only factory metadata and the existing retained CALL_SL
  !! workspace. It never releases the model, fields, GRIDWORK, physics,
  !! radiation, spectral setup or interpolation coefficient table owners.
  !! A busy retained call refuses2. Otherwise status0 also handles any
  !! acquired prefix of this factory, including an incomplete setup.
  subroutine release_native_gp_input_factory(work, grid, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    integer(int32), intent(out) :: status
    status = 2
    if (work%retained%busy) return
    call release_runtime_retained_transport(work%retained, status)
    if (status /= 0) return
    grid%blocks = native_grid_block_inputs()
    nullify (grid%model, grid%fields, grid%next, grid%registry, grid%surface_metadata, grid%surface_arrays)
    nullify (grid%physics, grid%radiation, grid%geometry_blocks, grid%retained, grid%first_buffer, grid%second_buffer, grid%stress)
    grid%transport_arrays = native_call_sl_arrays()
    grid%trajectory%geometry = departure_weight_geometry()
    grid%trajectory%latitude = trajectory_latitude_partition()
    grid%trajectory%source_fields = trajectory_field_component()
    nullify (grid%trajectory%full_eta, grid%trajectory%half_eta, grid%trajectory%selectors, grid%trajectory%diagnostics)
    nullify (grid%transport_update%components, grid%transport_update%destinations)
    nullify (grid%transport_update%layer_weight, grid%transport_update%inverse_layer_width)
    grid%transport_update%tables = vertical_operator_matrices()
    grid%registry_geometry = native_registry_geometry_inputs()
    grid%registry_physics = native_registry_ecphysics_inputs()
    grid%registry_radiation = native_registry_radiation_inputs()
    grid%registry_aliases = native_registry_extra_aliases()
    grid%mass_grid = tracer_mass_grid()
    if (allocated(work%columns)) deallocate (work%columns)
    if (allocated(work%transport_components)) deallocate (work%transport_components)
    if (allocated(work%work_components)) deallocate (work%work_components)
    if (allocated(work%tracer_pairs)) deallocate (work%tracer_pairs)
    if (allocated(work%physics_components)) deallocate (work%physics_components)
    if (allocated(work%boundary_components)) deallocate (work%boundary_components)
    if (allocated(work%destinations)) deallocate (work%destinations)
    if (allocated(work%selectors)) deallocate (work%selectors)
    if (allocated(work%diagnostics)) deallocate (work%diagnostics)
    if (allocated(work%counters)) deallocate (work%counters)
    work%pitch = 0; work%levels = 0; work%blocks = 0; work%components = 0; work%phase = 0; work%metadata_bytes = 0_int64
    work%registry_ready = .false.
    work%base_bound = .false.; work%columns_bound = .false.; work%maps_bound = .false.
    work%transport_bound = .false.; work%controls_bound = .false.; work%ready = .false.
    status = 0
  end subroutine

end module forecast_native_gp_input_factory
