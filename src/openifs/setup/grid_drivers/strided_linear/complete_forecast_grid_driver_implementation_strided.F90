!> Preserve the GP_MODEL source call order through complete native children.
submodule(forecast_complete_forecast_grid_driver_strided) forecast_complete_forecast_grid_implementation_strided
  use iso_c_binding, only: c_ptr, c_null_ptr, c_int, c_char, c_null_char, c_associated, c_f_pointer
  use forecast_native_field_registry, only: bind_native_field_registry_model, &
                                            prepare_native_field_registry, prepare_runtime_native_field_registry
  use forecast_next_time_field_storage, only: next_time_field_shape, prepare_next_time_fields, prepare_runtime_next_time_fields
  use forecast_grid_point_block_driver_strided, only: run_grid_point_blocks
  use forecast_lagged_grid_update, only: lagged_grid_field_map, finish_lagged_grid_update, grid_update_environment_supported
  use forecast_retained_transport_dispatch, only: call_sl_heap2, runtime_retained_transport
  use forecast_tracer_mass_correction_dispatch, only: trmfixers_selected, trmfixers_runtime
  use native_radiation_forecast_driver, only: raddrv
  use forecast_complete_physics_driver, only: ec_phys_drv
  use md2asm_transform_profile_policy, only: transform_profile_event, increment_source_counter
  implicit none
  interface
    function public_trace_begin(file, line, title) bind(C, name='new_atlas_Trace') result(handle)
      import c_ptr, c_char, c_int
      character(c_char), intent(in) :: file(*), title(*)
      integer(c_int), value :: line
      type(c_ptr) :: handle
    end function
    subroutine public_trace_end(handle) bind(C, name='delete_atlas_Trace')
      import c_ptr
      type(c_ptr), value :: handle
    end subroutine
    subroutine public_statistics(event, phase) bind(C, name='gstats_')
      import c_int
      integer(c_int), intent(in) :: event, phase
    end subroutine
    function grid_model_errno_location() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  module procedure gp_model
  type(next_time_field_shape) :: next_shape
  type(native_call_sl_arrays) :: transport_arrays
  type(native_complete_physics_driver_inputs) :: physics_inputs
  type(grid_point_block_controls) :: block_controls
  type(lagged_grid_field_map) :: lagged_map
  type(grid_point_column_views), allocatable :: columns(:)
  real(real64), allocatable, target :: zwrl9(:, :, :), zgeo0(:, :, :), zpre0f(:, :, :)
  real(real64), allocatable, target :: zrcp0(:, :, :, :), zcty0(:, :, :, :)
  real(real64), allocatable, target :: pbup9(:, :, :), pbvp9(:, :, :), pbtp9(:, :, :), pbgflp9(:, :, :, :)
  real(real64), allocatable :: zgflt9(:, :, :)
  real(real64), pointer :: gfl(:, :, :, :), gflt1(:, :, :, :), surface_view(:, :, :)
  integer(c_int), pointer, volatile :: errno_target
  integer(c_int) :: allocation_errno
  integer(int32) :: p, l, b, n, ndim1, ndimslp, ngfl, code, child_status, ib, ig, ic, k, j, mp9, mp1, blocks
  integer(int64) :: cells, workspace_bytes
  logical :: opened, restore_required, registry_was_empty, call_radiation
  type(c_ptr) :: trace
  character(len=1), target :: configuration
  real(real64) :: hook
  status = 2_int32; opened = .false.; restore_required = .false.; trace = c_null_ptr
  if (.not. associated(inputs%model) .or. .not. associated(inputs%fields)) return
  if (.not. associated(inputs%next) .or. .not. associated(inputs%registry)) return
  if (.not. associated(inputs%model%initial)) return
  if (.not. inputs%model%ready .or. .not. inputs%model%initial%ready) return
  if (.not. allocated(inputs%model%initial%geometry)) return
  if (.not. inputs%model%initial%geometry%initialized) return
  if (.not. associated(inputs%surface_metadata) .or. .not. associated(inputs%surface_arrays)) return
  if (.not. associated(inputs%physics) .or. .not. associated(inputs%radiation)) return
  if (.not. associated(inputs%retained) .or. .not. associated(inputs%geometry_blocks)) return
  if (.not. associated(inputs%first_buffer) .or. .not. associated(inputs%second_buffer)) return
  if (.not. associated(inputs%blocks%constants) .or. .not. associated(inputs%blocks%tables)) return
  if (.not. associated(inputs%blocks%coefficients) .or. .not. associated(inputs%blocks%columns)) return
  if (.not. associated(inputs%blocks%thermal_components) .or. .not. associated(inputs%blocks%work_components)) return
  if (.not. associated(inputs%blocks%tracer_pairs) .or. .not. associated(inputs%blocks%physics_components)) return
  if (.not. associated(inputs%blocks%transport_components) .or. .not. associated(inputs%blocks%boundary_components)) return
  if (.not. associated(inputs%blocks%core_index) .or. .not. associated(inputs%blocks%counters)) return
  if (.not. associated(inputs%blocks%reset_requests) .or. .not. associated(inputs%blocks%flux_reset)) return
  if (.not. grid_update_environment_supported()) return
  if (inputs%controls%two_dimensional .or. inputs%controls%full_corrector .or. inputs%controls%cheap_corrector) return
  if (inputs%controls%digital_filter_step .or. inputs%controls%grid_stress .or. inputs%controls%extra_mass_diagnostics) return
  if (inputs%controls%chemistry .or. inputs%controls%observation_processing .or. inputs%controls%external_coupling) return
  if (inputs%lagged%stress_enabled) return
  if (.not. inputs%model%dynamics%lslag .or. .not. inputs%model%dynamics%ltwotl) return
  if (inputs%controls%step < 0 .or. inputs%controls%radiation_frequency < 1) return
  if (inputs%controls%configuration(4:4) /= 'A' .and. inputs%controls%configuration(4:4) /= 'B') return
  if (.not. inputs%blocks%controls%ecmwf_physics .or. .not. inputs%blocks%controls%lagged_physics) return
  if (.not. inputs%blocks%controls%semi_lagrangian .or. .not. inputs%blocks%controls%split_physics) return
  p = inputs%model%initial%geometry%dimensions%nproma
  l = inputs%model%initial%geometry%dimensions%nflevg
  n = inputs%model%initial%geometry%partition%ngptot
  b = inputs%model%initial%geometry%partition%ngpblks
  if (p < 1 .or. p > 256 .or. l < 5 .or. l > 137 .or. n < 1 .or. b < 1 .or. b > 1000000) return
  blocks = int((int(n, int64) + p - 1_int64)/p, int32)
  if (b /= blocks) return
  if (.not. inputs%controls%runtime_dimensions) then
    if (p /= 24 .or. l /= 19 .or. n /= 2048 .or. b /= 86) return
  end if
  if (size(inputs%blocks%columns) /= b .or. size(inputs%geometry_blocks) /= b) return
  if (size(inputs%blocks%transport_components, 2) /= b) return
  if (size(inputs%blocks%counters, 1) /= l .or. size(inputs%blocks%counters, 2) /= b) return
  if (.not. allocated(inputs%model%motion%gmv) .or. .not. allocated(inputs%model%motion%gmvs)) return
  if (.not. allocated(inputs%fields%gfl) .or. .not. allocated(inputs%fields%gflslp)) return
  if (size(inputs%model%motion%gmv, 1) /= p .or. size(inputs%model%motion%gmv, 2) /= l) return
  if (size(inputs%model%motion%gmv, 4) /= b .or. size(inputs%model%motion%gmvs, 1) /= p) return
  if (size(inputs%model%motion%gmvs, 3) /= b) return
  if (size(inputs%fields%gfl, 1) /= p .or. size(inputs%fields%gfl, 2) /= l .or. size(inputs%fields%gfl, 4) /= b) return
  ndim1 = inputs%model%fields%registration%ndim1
  ndimslp = inputs%model%fields%registration%ndimslp
  ngfl = inputs%model%fields%registration%numflds
  if (ndim1 < 0 .or. ndim1 > 64 .or. ndimslp < 0 .or. ndimslp > 2163 .or. ngfl < 0 .or. ngfl > 2163) return
  if (size(inputs%first_buffer, 1) /= inputs%model%interpolation%naslb1) return
  if (size(inputs%first_buffer, 2) < inputs%model%buffers%first%nfldslb1) return
  if (size(inputs%second_buffer, 1) /= p .or. size(inputs%second_buffer, 3) /= b) return
  if (size(inputs%second_buffer, 2) < inputs%model%buffers%second%nfldslb2) return
  if (inputs%transport_controls%pitch /= p .or. inputs%transport_controls%levels /= l) return
  if (inputs%transport_controls%point_count /= n .or. inputs%transport_controls%point_capacity /= n) return
  if (inputs%blocks%controls%step /= inputs%controls%step) return
  if (inputs%blocks%controls%model_interval /= inputs%model%initial%controls%clock%integration%second_dt) return
  if (inputs%blocks%controls%schedule_time_step /= inputs%model%initial%controls%clock%integration%first_dt) return
  if (.not. associated(inputs%transport_arrays%parent_index) .or. .not. associated(inputs%transport_arrays%linear_weights)) return
  if (.not. associated(inputs%registry_geometry%gm)) return
  if (inputs%lagged%stress_enabled) then
    if (.not. associated(inputs%stress)) return
    if(size(inputs%stress,1)/=p.or.size(inputs%stress,2)<l.or.size(inputs%stress,3)<2.or.size(inputs%stress,4)/=b)return
  end if
  do j = 1, ngfl
    if (inputs%model%fields%components(j)%lt1 == 0) cycle
    mp9 = inputs%model%fields%components(j)%mp9_ph
    mp1 = inputs%model%fields%components(j)%mp1
    if (mp9 < 1 .or. mp9 > size(inputs%fields%gfl, 3) .or. mp1 < 1 .or. mp1 > ndim1) return
  end do
  cells = int(p, int64)*int(l, int64)*int(b, int64)
  workspace_bytes = 8_int64*(cells*(14_int64 + ndimslp) + 5_int64*p*b + int(n, int64)*l*ngfl)
  if (workspace_bytes < 0 .or. workspace_bytes > inputs%workspace_limit) return
  next_shape = next_time_field_shape(p, l, b, ndim1)
  if (inputs%controls%runtime_dimensions) then
    status = prepare_runtime_next_time_fields(inputs%model%motion, inputs%next, next_shape, inputs%workspace_limit)
  else
    status = prepare_next_time_fields(inputs%model%motion, inputs%next, next_shape, inputs%workspace_limit)
  end if
  if (status /= 0) return
  gfl => inputs%fields%gfl; gflt1 => inputs%next%gflt1
  call transform_profile_event('GP_MODEL', 0_int32, hook, profile)
  opened = .true.
  trace = public_trace_begin('gp_model.F90'//c_null_char, 215_c_int, 'GP_MODEL'//c_null_char)
  call public_statistics(8_c_int, 1_c_int)
  registry_was_empty = .not. associated(inputs%registry%variables)
  if (registry_was_empty) then
    status = bind_native_field_registry_model(inputs%registry, inputs%model)
    if (status /= 0) goto900
  end if
  if (inputs%controls%runtime_dimensions) then
    status = prepare_runtime_native_field_registry(inputs%registry, inputs%model%initial%geometry, inputs%model, &
                                             inputs%registry_geometry, gfl, gflt1, inputs%surface_metadata, inputs%surface_arrays, &
                                                   inputs%registry_physics, inputs%registry_radiation, inputs%registry_aliases)
  else
    status = prepare_native_field_registry(inputs%registry, inputs%model%initial%geometry, inputs%model, &
                                           inputs%registry_geometry, gfl, gflt1, inputs%surface_metadata, inputs%surface_arrays, &
                                           inputs%registry_physics, inputs%registry_radiation, inputs%registry_aliases)
  end if
  if (status /= 0) goto900
  if (registry_was_empty) call increment_source_counter(inputs%stage_calls(7))
  call c_f_pointer(grid_model_errno_location(), errno_target); allocation_errno = errno_target
  allocate (zgeo0(p, l, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (zrcp0(p, l, 3, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (zpre0f(p, l, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (zcty0(p, 0:l, 5, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (zwrl9(p, l, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (columns(b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  columns = inputs%blocks%columns
  if (inputs%controls%padding_control > 0) inputs%first_buffer(:, 1:inputs%model%buffers%first%nfldslb1) = &
    transfer(int(z'7FEFFFFFFFFFFFFF', int64), 0.0_real64)
  inputs%second_buffer(:, 1:inputs%model%buffers%second%nfldslb2, :) = 0.0_real64
  do ib = 1, b
    columns(ib)%motion => inputs%model%motion%gmv(:, :, :, ib)
    columns(ib)%surface(1:p, 1:1, 1:size(inputs%model%motion%gmvs, 2)) => inputs%model%motion%gmvs(:, :, ib)
    columns(ib)%tracers => inputs%fields%gfl(:, :, :, ib)
    columns(ib)%global_first_buffer(1:size(inputs%first_buffer, 1), 1:size(inputs%first_buffer, 2)) => inputs%first_buffer
    columns(ib)%hydro%full_geopotential => zgeo0(:, :, ib)
    columns(ib)%hydro%heat_capacity => zrcp0(:, :, 1, ib)
    columns(ib)%hydro%gas_constant => zrcp0(:, :, 2, ib)
    columns(ib)%hydro%kappa => zrcp0(:, :, 3, ib)
    columns(ib)%hydro%full_pressure => zpre0f(:, :, ib)
    columns(ib)%hydro%continuity(1:p, 0:l, 1:5) => zcty0(:, :, :, ib)
    columns(ib)%wind%history => zwrl9(:, :, ib)
  end do
  block_controls = inputs%blocks%controls
  block_controls%configuration = inputs%controls%configuration(4:4)
  call run_grid_point_blocks(block_controls, p, l, n, inputs%blocks%reset_requests, inputs%blocks%flux_reset, &
                             inputs%blocks%constants, inputs%blocks%thermal_components, inputs%blocks%work_components, &
                             inputs%blocks%tracer_pairs, inputs%blocks%physics_components, inputs%blocks%transport_components, &
                      inputs%blocks%boundary_components, inputs%blocks%tables, inputs%blocks%coefficients, inputs%blocks%vertical, &
                       inputs%blocks%surface_map, inputs%blocks%motion_map, inputs%blocks%boundary_maps, inputs%blocks%core_index, &
                             inputs%model%physics_auxiliary, columns, inputs%blocks%counters, inputs%blocks%diagnostic_calls, &
                             inputs%blocks%end_calls, status, inputs%blocks%reset_minutes, profile)
  if (status /= 0) goto900
  call increment_source_counter(inputs%stage_calls(1))
  allocation_errno = errno_target
  allocate (pbup9(p, l, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (pbvp9(p, l, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (pbtp9(p, l, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  allocate (pbgflp9(p, l, ndimslp, b), stat=code); errno_target = allocation_errno
  if (code /= 0) goto800
  transport_arrays = inputs%transport_arrays
  transport_arrays%second_buffer => inputs%second_buffer
  transport_arrays%previous_eta_rate => zwrl9
  transport_arrays%general_state => inputs%model%motion%gmvt1
  transport_arrays%surface_state => inputs%model%motion%gmvt1s
  transport_arrays%constituent_state => inputs%next%gflt1
  transport_arrays%split_u => pbup9; transport_arrays%split_v => pbvp9
  transport_arrays%split_temperature => pbtp9; transport_arrays%split_constituent => pbgflp9
  if (inputs%controls%runtime_dimensions) then
    call runtime_retained_transport(inputs%communicator, inputs%transport_controls, inputs%model%interpolation, &
                       inputs%model%buffers, inputs%model%interpolation_controls, inputs%plane_controls, inputs%model%linear_full, &
                  inputs%model%nonlinear_full, inputs%model%nonlinear_half, inputs%model%cartesian_planes, inputs%geometry_blocks, &
                               inputs%first_buffer, transport_arrays, inputs%trajectory, inputs%transport_update, inputs%retained, &
                                    inputs%transport_counts, status, inputs%workspace_limit, profile)
  else
    call call_sl_heap2(inputs%communicator, inputs%transport_controls, inputs%model%interpolation, &
                       inputs%model%buffers, inputs%model%interpolation_controls, inputs%plane_controls, inputs%model%linear_full, &
                  inputs%model%nonlinear_full, inputs%model%nonlinear_half, inputs%model%cartesian_planes, inputs%geometry_blocks, &
                       inputs%first_buffer, transport_arrays, inputs%trajectory, inputs%transport_update, inputs%retained, &
                       inputs%transport_counts, status, inputs%workspace_limit, profile)
  end if
  if (status /= 0) goto900
  call increment_source_counter(inputs%stage_calls(2))
  call public_statistics(7_c_int, 0_c_int)
  if (inputs%controls%runtime_dimensions) then
    call trmfixers_runtime(inputs%mass_grid, inputs%mass_layout, inputs%model%fields, .true., &
                    transport_arrays%parent_index, transport_arrays%linear_weights, inputs%first_buffer, inputs%model%motion%gmvs, &
                           inputs%model%motion%gmvt1s, inputs%fields%gfl, inputs%next%gflt1, status)
  else
    call trmfixers_selected(inputs%mass_grid, inputs%mass_layout, inputs%model%fields, .true., &
                    transport_arrays%parent_index, transport_arrays%linear_weights, inputs%first_buffer, inputs%model%motion%gmvs, &
                            inputs%model%motion%gmvt1s, inputs%fields%gfl, inputs%next%gflt1, status, profile)
  end if
  if (status /= 0) goto900
  call increment_source_counter(inputs%stage_calls(3))
  call public_statistics(7_c_int, 1_c_int)
  call public_statistics(8_c_int, 2_c_int)
  call public_statistics(10_c_int, 0_c_int)
  call_radiation = inputs%controls%radiation_enabled .and. mod(inputs%controls%step, inputs%controls%radiation_frequency) == 0
  if (call_radiation) then
    call public_statistics(8_c_int, 2_c_int)
    call public_statistics(13_c_int, 0_c_int)
    if (inputs%controls%implicit_radiation) then
      allocation_errno = errno_target
      allocate (zgflt9(n, l, ngfl), stat=code); errno_target = allocation_errno
      if (code /= 0) goto800
      do ib = 1, b
        ig = (ib - 1)*p + 1; ic = min(p, n - ig + 1)
        do j = 1, ngfl
          if (inputs%model%fields%components(j)%lt1 == 0) cycle
          mp9 = inputs%model%fields%components(j)%mp9_ph; mp1 = inputs%model%fields%components(j)%mp1
          zgflt9(ig:ig + ic - 1, 1:l, j) = inputs%fields%gfl(1:ic, 1:l, mp9, ib)
          inputs%fields%gfl(1:ic, 1:l, mp9, ib) = inputs%next%gflt1(1:ic, 1:l, mp1, ib)
        end do
      end do
      restore_required = .true.
    end if
    status = raddrv(inputs%radiation, inputs%fields, inputs%model%motion, n, inputs%second_buffer)
    if (status == 0) call increment_source_counter(inputs%stage_calls(4))
    call restore_radiation_state()
    if (status /= 0) goto900
    call public_statistics(13_c_int, 1_c_int)
    call public_statistics(8_c_int, 3_c_int)
  end if
  physics_inputs = inputs%physics
  configuration = inputs%controls%configuration(4:4)
  physics_inputs%records%model => inputs%model
  physics_inputs%records%geometry => inputs%model%initial%geometry
  physics_inputs%records%motion => inputs%model%motion
  physics_inputs%records%variables => inputs%registry%variables
  physics_inputs%records%surface_metadata => inputs%surface_metadata
  physics_inputs%records%configuration => configuration
  physics_inputs%surface_variables => inputs%registry%surface
  physics_inputs%arrays%pbup9 => pbup9; physics_inputs%arrays%pbvp9 => pbvp9
  physics_inputs%arrays%pbtp9 => pbtp9; physics_inputs%arrays%pbgflp9 => pbgflp9
  physics_inputs%arrays%pb2 => inputs%second_buffer
  physics_inputs%arrays%pgmv => inputs%model%motion%gmv
  physics_inputs%arrays%pgmvt1 => inputs%model%motion%gmvt1
  physics_inputs%arrays%gfl => inputs%fields%gfl
  physics_inputs%arrays%gflt1 => inputs%next%gflt1
  physics_inputs%arrays%gflslp => inputs%fields%gflslp
  status = ec_phys_drv(physics_inputs)
  if (status /= 0) goto900
  call increment_source_counter(inputs%stage_calls(5))
  call release_source_workspace()
  call public_statistics(1040_c_int, 0_c_int)
  lagged_map%future_air = [inputs%model%motion%yt1%mu, inputs%model%motion%yt1%mv, inputs%model%motion%yt1%mt]
  lagged_map%future_surface = inputs%model%motion%yt1%msp
  lagged_map%buffer_first = [inputs%model%buffers%second%mslb2usi, inputs%model%buffers%second%mslb2vsi, &
                             inputs%model%buffers%second%mslb2tsi]
  lagged_map%buffer_surface = inputs%model%buffers%second%mslb2spsi
  do ib = 1, b
    ig = (ib - 1)*p + 1
    surface_view(1:p, 1:1, 1:size(inputs%model%motion%gmvs, 2)) => inputs%model%motion%gmvs(:, :, ib)
    if (inputs%lagged%stress_enabled) then
      call finish_lagged_grid_update(inputs%lagged, lagged_map, p, l, n, ig, inputs%blocks%tracer_pairs, &
                    inputs%blocks%constants, inputs%blocks%thermal_components, inputs%model%motion%gmv(:, :, :, ib), surface_view, &
                                   inputs%fields%gfl(:, :, :, ib), inputs%second_buffer(:, :, ib), inputs%next%gflt1(:, :, :, ib), &
                                     inputs%model%motion%gmvt1(:, :, :, ib), inputs%model%motion%gmvt1s(:, :, ib), &
                                     inputs%registry_geometry%gm(:, ib), status, inputs%stress(:, :, :, ib))
    else
      call finish_lagged_grid_update(inputs%lagged, lagged_map, p, l, n, ig, inputs%blocks%tracer_pairs, &
                    inputs%blocks%constants, inputs%blocks%thermal_components, inputs%model%motion%gmv(:, :, :, ib), surface_view, &
                                   inputs%fields%gfl(:, :, :, ib), inputs%second_buffer(:, :, ib), inputs%next%gflt1(:, :, :, ib), &
           inputs%model%motion%gmvt1(:, :, :, ib), inputs%model%motion%gmvt1s(:, :, ib), inputs%registry_geometry%gm(:, ib), status)
    end if
    if (status /= 0) goto900
    call increment_source_counter(inputs%stage_calls(6))
  end do
  call public_statistics(1040_c_int, 1_c_int)
  call public_statistics(8_c_int, 3_c_int)
  status = 0_int32
  goto900
800 status = 1_int32
900 continue
  call restore_radiation_state()
  call release_source_workspace()
  if (allocated(zgflt9)) then
    allocation_errno = errno_target
    deallocate (zgflt9)
    errno_target = allocation_errno
  end if
  if (allocated(columns)) then
    allocation_errno = errno_target
    deallocate (columns)
    errno_target = allocation_errno
  end if
  if (c_associated(trace)) call public_trace_end(trace)
  if (status == 0) call increment_source_counter(inputs%stage_calls(0))
  if (opened) call transform_profile_event('GP_MODEL', 1_int32, hook, profile)
contains
  subroutine restore_radiation_state()
    if (.not. restore_required) return
    do ib = 1, b
      ig = (ib - 1)*p + 1; ic = min(p, n - ig + 1)
      do j = 1, ngfl
        if (inputs%model%fields%components(j)%lt1 == 0) cycle
        mp9 = inputs%model%fields%components(j)%mp9_ph
        inputs%fields%gfl(1:ic, 1:l, mp9, ib) = zgflt9(ig:ig + ic - 1, 1:l, j)
      end do
    end do
    restore_required = .false.
  end subroutine
  subroutine release_source_workspace()
    integer :: q
    ! Metadata aliases expire before the corresponding native targets.
    if (allocated(columns)) then
      do q = 1, size(columns)
        nullify (columns(q)%hydro%full_geopotential, columns(q)%hydro%heat_capacity)
        nullify (columns(q)%hydro%gas_constant, columns(q)%hydro%kappa)
        nullify (columns(q)%hydro%full_pressure, columns(q)%hydro%continuity, columns(q)%wind%history)
      end do
    end if
    call c_f_pointer(grid_model_errno_location(), errno_target)
    allocation_errno = errno_target
    if (allocated(pbup9)) deallocate (pbup9)
    if (allocated(pbvp9)) deallocate (pbvp9)
    if (allocated(pbtp9)) deallocate (pbtp9)
    if (allocated(pbgflp9)) deallocate (pbgflp9)
    if (allocated(zwrl9)) deallocate (zwrl9)
    if (allocated(zrcp0)) deallocate (zrcp0)
    if (allocated(zpre0f)) deallocate (zpre0f)
    if (allocated(zcty0)) deallocate (zcty0)
    if (allocated(zgeo0)) deallocate (zgeo0)
    errno_target = allocation_errno
  end subroutine
  end procedure
end submodule forecast_complete_forecast_grid_implementation_strided
