!> Own the selected saved work and load real selected initial field owners.
module forecast_selected_bootstrap_fields
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_loc
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_loaded_operational_model, only: native_loaded_operational_input_budget
  use forecast_staged_work_storage, only: advance_forecast_work_storage
  use forecast_native_dynamic_storage, only: allocate_saved_departure_points
  use forecast_grid_motion_setup, only: native_grid_motion_controls
  use forecast_distributed_grid_motion_storage, only: allocate_distributed_grid_motion_fields
  use spectral_field_storage_port, only: initialize_serial_spectral_field
  use forecast_complete_initial_spectral_loading, only: load_spectral_initial_state
  use forecast_orography_initialization, only: initialize_selected_orography
  use forecast_owned_surface_state_startup, only: initialize_owned_selected_surface_state
  use grid_field_native_thermal_metadata_port, only: export_grid_field_thermal_constituents, export_native_moist_air_constants
  use gridpoint_field_storage_port, only: initialize_gridpoint_field
  use upper_air_initial_loading_port, only: load_initial_upper_air_state
  use initial_spectral_virtual_temperature_port, only: initialize_spectral_virtual_temperature
  use forecast_initial_fields_storage, only: bind_initial_field_storage_owners
  use forecast_initial_spectral_norm_join, only: compute_initial_input_spectral_norms
  use mpi_f08, only: MPI_Comm
  implicit none
  private
  public :: prepare_selected_saved_work, load_selected_bootstrap_fields
contains
  !> Allocate the genuine first saved-work owner after selected dynamics setup.
 !! STARTUP is the canonical final TARGET. BYTE_LIMIT bounds six later arrays.
 !! The source RSAVEDP payload stays undefined until its departure producer.
 !! The unchanged staged child then owns RSLWX, SAVTEND and next-time work.
  integer(int32) function prepare_selected_saved_work(startup, byte_limit) result(status)
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    integer(int64), intent(in) :: byte_limit
    integer :: io
    status = 2
    if (.not. allocated(startup%initial) .or. .not. allocated(startup%loaded%storage)) return
    if (.not. allocated(startup%loaded%input)) return
    if (allocated(startup%loaded%input%work) .or. byte_limit < 0) return
    associate (model => startup%loaded%storage%model, input => startup%loaded%input, &
               dynamic => startup%loaded%dynamic, next => startup%loaded%next, geometry => startup%initial%geometry)
      if (.not. model%ready .or. .not. geometry%initialized) return
      if (geometry%dimensions%nproma /= 24 .or. geometry%dimensions%nflevg /= 19) return
      if (geometry%partition%ngpblks /= 86 .or. geometry%partition%ngptot /= 2048) return
      if (geometry%transform_control%nproc /= 1) return
      if (allocated(dynamic%rsavedp) .or. allocated(dynamic%rslwx) .or. allocated(dynamic%savtend)) return
      allocate (input%work, stat=io)
      if (io /= 0) then
        status = 1; return
      end if
      status = allocate_saved_departure_points(dynamic, model, .false., byte_limit)
      if (status /= 0) then
        deallocate (input%work); return
      end if
      input%work%model => model; input%work%dynamic => dynamic; input%work%next => next
      input%work%pitch = geometry%dimensions%nproma; input%work%levels = geometry%dimensions%nflevg
      input%work%blocks = geometry%partition%ngpblks; input%work%points = geometry%partition%ngptot
      input%work%phase = 1; input%work%byte_limit = byte_limit; input%work%distributed = .true.
      input%work%bases(1) = c_loc(dynamic%rsavedp(1, 1, 1, 1))
    end associate
  end function
  !> Load selected spectral, terrain, surface and upper-air fields in source order.
 !! All inputs use the same real MODEL/FIELDS owners prepared by startup and
 !! SUPHEC. Workspace limits are bytes; the selected file reader derives its
 !! own complete sizes and refuses a short limit. No forecast step is run.
 !! Failure retains its reached prefix for the owning release path.
  integer(int32) function load_selected_bootstrap_fields(startup, world, spectral_path, surface_path, upper_path, &
                                             budget, surface_workspace_bytes, norm_bytes, child_status, failed_stage) result(status)
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_path
    type(native_loaded_operational_input_budget), intent(in) :: budget
    integer(int64), intent(in) :: surface_workspace_bytes, norm_bytes
    integer(int32), intent(out) :: child_status, failed_stage
    type(native_grid_motion_controls) :: controls
    integer(int32) :: p, l, b, q, water_slots(3), j
    logical :: spectral_water(3)
    status = 2; child_status = 2; failed_stage = 1
    if (.not. allocated(startup%initial) .or. .not. allocated(startup%loaded%storage)) return
    if (.not. allocated(startup%loaded%input) .or. .not. associated(startup%loaded%fields)) return
    if (.not. startup%loaded%storage%ecmwf%setup_complete) return
    associate (model => startup%loaded%storage%model, input => startup%loaded%input, geometry => startup%initial%geometry)
      if (.not. model%ready .or. input%phase /= 25) return
      p = geometry%dimensions%nproma; l = geometry%dimensions%nflevg
      b = geometry%partition%ngpblks; q = geometry%partition%ngptot
      if (p /= 24 .or. l /= 19 .or. b /= 86 .or. q /= 2048 .or. geometry%transform_control%nproc /= 1) return
      child_status = prepare_selected_saved_work(startup, budget%work_bytes)
      if (child_status /= 0) goto900
      failed_stage = 2
      child_status = advance_forecast_work_storage(input%work)
      if (child_status /= 0) goto900
      failed_stage = 3
      child_status = advance_forecast_work_storage(input%work)
      if (child_status /= 0) goto900
      failed_stage = 4
      controls%nconf = startup%initial%controls%namespace%nconf
      controls%lecmwf = startup%initial%controls%namespace%lecmwf
      controls%lrshw = startup%initial%controls%namespace%lrshw
      controls%nundefld = startup%initial%controls%namespace%nundefld
      controls%ldtenc = 0; controls%nprintlev = 0
  child_status = allocate_distributed_grid_motion_fields(model%motion, p, l, b, q, model%field_dimensions, model%dynamics, controls)
      if (child_status /= 0) goto900
      input%owns_motion_spectral = .true.
      failed_stage = 5
      child_status = initialize_serial_spectral_field(input%spectral, l, geometry%dimensions%nsmax, &
                                        [138_int32, 155_int32, 130_int32, 152_int32, 129_int32], budget%input%fields%spectral_bytes)
      if (child_status /= 0) goto900
      failed_stage = 6
      child_status = load_spectral_initial_state(spectral_path, geometry%transform_resolution%resolution, &
                                          geometry%transform_control%nprtrw, model%field_dimensions, model%fields, input%spectral, &
                                                 input%loaded_orography, budget%input%fields%spectral_map_bytes)
      if (child_status /= 0) goto900
      failed_stage = 7
      child_status = initialize_selected_orography(input%terrain, geometry%terrain, input%spectral%sp2d(:, 2), &
                        geometry%transform_resolution, geometry%laplacian, geometry%dimensions%nsmax, q, p, input%spectral%nspec2, &
                                        input%spectral%nump, geometry%transform_control%mysetv, geometry%transform_control%nprtrv, &
                                                   .false., .false., model%dynamics%lnhdyn)
      if (child_status /= 0) goto900
      failed_stage = 8
      child_status = initialize_owned_selected_surface_state(surface_path, startup%initial%constants, &
                                                    model%physics%ecmwf_physics, input%surface_metadata, input%surface_trajectory, &
                                                          input%surface_descriptions, input%surface_arrays, surface_workspace_bytes)
      if (child_status /= 0) goto900
      failed_stage = 9
      child_status = export_grid_field_thermal_constituents(model%fields, input%constituents(1:8))
      if (child_status /= 0) goto900
      child_status = export_native_moist_air_constants(startup%initial%constants, input%thermal_constants)
      if (child_status /= 0) goto900
      child_status = initialize_gridpoint_field(input%upper%fields, p, l, b, input%constituents(1:8))
      if (child_status /= 0) goto900
      failed_stage = 10
      child_status = load_initial_upper_air_state(upper_path, input%upper%fields%gfl)
      if (child_status /= 0) goto900
      failed_stage = 11
      water_slots = [model%fields%aliases%yq, model%fields%aliases%yl, model%fields%aliases%yi]
      do j = 1, 3
        if (water_slots(j) < 1 .or. water_slots(j) > size(model%fields%components)) then
          child_status = 2; goto900
        end if
        spectral_water(j) = model%fields%components(water_slots(j))%lsp /= 0
      end do
      child_status = initialize_spectral_virtual_temperature(geometry%transform_control, geometry%transform_resolution, &
                                    geometry%partition%nbsetlev, input%thermal_constants, input%constituents(1:8), spectral_water, &
                                                             input%upper%fields%gfl, input%spectral%t)
      if (child_status /= 0) goto900
      failed_stage = 12
      child_status = advance_forecast_work_storage(input%work)
      if (child_status /= 0) goto900
      child_status = bind_initial_field_storage_owners(startup%loaded%fields, geometry, input%upper%fields, &
                                                       input%surface_metadata, input%surface_arrays, startup%loaded%next)
      if (child_status /= 0) goto900
      failed_stage = 13
      child_status = compute_initial_input_spectral_norms(model, input%spectral, world, norm_bytes, startup%norms)
      if (child_status /= 0) goto900
      input%phase = 120; input%ready = .true.; startup%loaded%ready = .true.
      startup%loaded%phase = 120
      status = 0; child_status = 0; failed_stage = 0
      return
900   status = child_status
      input%last_status = child_status
    end associate
  end function
end module forecast_selected_bootstrap_fields
