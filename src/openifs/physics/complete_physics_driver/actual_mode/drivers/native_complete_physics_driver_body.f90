! (C) Copyright ECMWF. Licensed under Apache-2.0.
!> Complete source-ordered block driver, with native temporary storage.
!! The caller supplies actual produced input owners and the floating-point mode.
!! P is columns, L levels and B blocks. Field values retain their source units.
submodule(forecast_complete_physics_driver) native_complete_physics_driver_body
  use iso_fortran_env, only: int64, real64
  use forecast_complete_physics_context_types, only: native_complete_physics_context
  use iso_c_binding, only: c_ptr
  use forecast_native_column_physics, only: ec_phys
  use forecast_physics_context_construction, only: initialize_physics_context, finish_physics_context
  use forecast_physics_context_work_views, only: physics_storage_work_views
  use forecast_physics_context_end_block, only: physics_storage_end_block
  use forecast_native_physics_state_storage, only: bind_physics_state_block
  use physics_context_address_services_mod, only: physics_storage_begin_block
  use physics_context_child_helpers_mod, only: physics_storage_child_table
  use physics_context_tendency_helpers_mod, only: physics_driver_tendency_table
  use md2asm_physics_state_tendency, only: form_physics_state_tendencies
  use md2asm_physics_state_rate_update, only: tracer_state_descriptor, apply_physics_state_rates
  use grid_field_component_types_port, only: field_component_metadata
  use yomphyder, only: model_state_type
  use yomhook, only: lhook, dr_hook
  implicit none
  interface
    subroutine statistics(section, phase) bind(C, name="gstats_")
      import :: int32
      integer(int32), intent(in) :: section, phase
    end subroutine
    subroutine statistics_barrier(section) bind(C, name="gstats_barrier_")
      import :: int32
      integer(int32), intent(in) :: section
    end subroutine
  end interface
contains
  !> Prepare rates, visit complete/partial blocks, then close the new states.
  !! The four temporary array owners last until all rate-closing calls finish.
  !! Source child failures retain preceding numerical writes and release owners.
  module procedure ec_phys_drv
  type(native_complete_physics_driver_inputs), target :: local_inputs
  type(native_complete_physics_context), pointer :: context
  type(model_state_type), target :: previous_state
  type(tracer_state_descriptor), allocatable :: components(:)
  type(tracer_state_descriptor) :: water(5), cloud, continuity
  real(real64), allocatable, target :: dynamic_rates(:, :, :, :), convectivity(:, :, :), cgpp(:, :), crec(:, :)
  integer(int32), pointer :: latitude(:)
  type(c_ptr) :: child_arguments(55), tendency_arguments(18)
  integer(int32) :: p, l, b, q, block, global_start, active, nfields, j, allocation_status, child_status, cleanup_status
  integer(int32) :: water_aliases(5), t1(3), ph9(3)
  integer(int64) :: words, bytes
  real(real64) :: time_step, hook, barrier_hook
  logical :: radiation_step, context_live, block_live
  status = 2_int32; nullify (context)
  context_live = .false.; block_live = .false.
  if (.not. associated(inputs%records%geometry) .or. .not. associated(inputs%records%model)) return
  if (.not. associated(inputs%physics) .or. .not. associated(inputs%runtime)) return
  if (.not. associated(inputs%providers) .or. .not. associated(inputs%stochastic_physics)) return
  if (.not. associated(inputs%providers%thermal) .or. .not. associated(inputs%providers%current_step)) return
  if (.not. associated(inputs%providers%stochastic_configuration)) return
  if (.not. associated(inputs%lnodryflx) .or. .not. associated(inputs%latitude)) return
  if (inputs%lspsdt) return
  if (inputs%records%model%dynamical_core%lheldsuarez /= 0) return
  p = inputs%records%geometry%dimensions%nproma
  l = inputs%records%geometry%dimensions%nflevg
  q = inputs%records%geometry%partition%ngptot
  b = inputs%records%geometry%partition%ngpblks
  if (p < 1 .or. p > 128 .or. l < 6 .or. l > 137 .or. q < 1) return
  if (b /= (q - 1)/p + 1) return
  if (size(inputs%latitude) /= q .or. .not. is_contiguous(inputs%latitude)) return
  if (.not. associated(inputs%arrays%pgmv) .or. .not. associated(inputs%arrays%pgmvt1)) return
  if (.not. associated(inputs%arrays%gfl) .or. .not. associated(inputs%arrays%gflt1)) return
  if (size(inputs%arrays%pgmv, 1) /= p .or. size(inputs%arrays%pgmv, 2) /= l .or. size(inputs%arrays%pgmv, 4) /= b) return
  if (size(inputs%arrays%pgmvt1, 1) /= p .or. size(inputs%arrays%pgmvt1, 2) /= l .or. size(inputs%arrays%pgmvt1, 4) /= b) return
  if (size(inputs%arrays%gfl, 1) /= p .or. size(inputs%arrays%gfl, 2) /= l .or. size(inputs%arrays%gfl, 4) /= b) return
  if (size(inputs%arrays%gflt1, 1) /= p .or. size(inputs%arrays%gflt1, 2) /= l .or. size(inputs%arrays%gflt1, 4) /= b) return
  t1 = inputs%t1_components; ph9 = inputs%ph9_components
  if (any(t1 < 1) .or. any(t1 > size(inputs%arrays%pgmvt1, 3))) return
  if (any(ph9 < 1) .or. any(ph9 > size(inputs%arrays%pgmv, 3))) return
  nfields = inputs%records%model%fields%registration%numflds
  if (nfields < 0 .or. nfields > size(inputs%records%model%fields%components)) return
  time_step = inputs%records%model%physics_auxiliary%tsphy
  if (inputs%physics%radiation%radiation%nradfr < 1) return
  words = int(p, int64)*int(l, int64)*int(size(inputs%arrays%gflt1, 3), int64)*int(b, int64)
  words = words + int(p, int64)*int(l, int64)*int(b, int64) + 2_int64*int(p, int64)*int(b, int64)
  if (words > huge(words)/8_int64) return
  bytes = words*8_int64
  if (bytes > inputs%providers%byte_limit) return
  water_aliases = [inputs%records%model%fields%aliases%yq, inputs%records%model%fields%aliases%yl, &
                   inputs%records%model%fields%aliases%yi, inputs%records%model%fields%aliases%yr, &
                   inputs%records%model%fields%aliases%ys]
  if (any(water_aliases < 1) .or. any(water_aliases > size(inputs%records%model%fields%components))) return
  if (inputs%records%model%fields%aliases%ya < 1 .or. inputs%records%model%fields%aliases%ya > 2163) return
  if (inputs%records%model%fields%aliases%yphycty < 1 .or. inputs%records%model%fields%aliases%yphycty > 2163) return
  allocate (components(nfields), dynamic_rates(p, l, size(inputs%arrays%gflt1, 3), b), &
            convectivity(p, l, b), cgpp(p, b), crec(p, b), stat=allocation_status)
  if (allocation_status /= 0) then
    status = 1_int32
    return
  end if
  do j = 1, nfields
    components(j) = project_component(inputs%records%model%fields%components(j))
  end do
  do j = 1, 5
    water(j) = project_component(inputs%records%model%fields%components(water_aliases(j)))
  end do
  cloud = project_component(inputs%records%model%fields%components(inputs%records%model%fields%aliases%ya))
  continuity = project_component(inputs%records%model%fields%components(inputs%records%model%fields%aliases%yphycty))
  local_inputs = inputs
  local_inputs%arrays%zgfl_dyn => dynamic_rates
  local_inputs%arrays%convectivity => convectivity
  local_inputs%arrays%cgpp => cgpp
  local_inputs%arrays%crec => crec
  nullify (previous_state%u, previous_state%v, previous_state%t, previous_state%gfl)
  local_inputs%records%previous_state => previous_state
  if (lhook) call dr_hook('EC_PHYS_DRV', 0, hook)
  radiation_step = mod(inputs%providers%current_step, inputs%physics%radiation%radiation%nradfr) == 0
  call statistics(1063_int32, 0_int32)
  do global_start = 1, q, p
    block = (global_start - 1)/p + 1; active = min(p, q - global_start + 1)
    child_status = physics_driver_tendency_table(local_inputs%records, local_inputs%arrays, block, active, 0_int32, &
                                                 t1, ph9, inputs%records%model%physics%cloud, inputs%lnodryflx, tendency_arguments)
    if (child_status /= 0) goto 900
    call form_physics_state_tendencies(p, 1_int32, active, l, time_step, components, &
                                   local_inputs%arrays%pgmvt1(:, :, t1(1), block), local_inputs%arrays%pgmvt1(:, :, t1(2), block), &
                                       local_inputs%arrays%pgmvt1(:, :, t1(3), block), local_inputs%arrays%gflt1(:, :, :, block), &
                                     local_inputs%arrays%pgmv(:, :, ph9(1), block), local_inputs%arrays%pgmv(:, :, ph9(2), block), &
                                       local_inputs%arrays%pgmv(:, :, ph9(3), block), local_inputs%arrays%gfl(:, :, :, block), &
                                       dynamic_rates(:, :, :, block), child_status)
    if (child_status /= 0) goto 900
  end do
  call statistics(1063_int32, 1_int32)
  if (radiation_step) then
    call statistics(1002_int32, 0_int32)
  else
    call statistics(1001_int32, 0_int32)
  end if
  child_status = initialize_physics_context(context, local_inputs, inputs%physics%radiation%radiation)
  if (child_status /= 0) goto 900
  context_live = .true.
  do global_start = 1, q, p
    block = (global_start - 1)/p + 1; active = min(p, q - global_start + 1)
    child_status = physics_storage_begin_block(context%variables, block)
    if (child_status /= 0) goto 900
    context%private_metadata_owned = .true.
    block_live = .true.
    do j = 1, 8
      child_status = bind_physics_state_block(context%states, j, block)
      if (child_status /= 0) goto 900
    end do
    latitude => inputs%latitude(global_start:global_start + active - 1)
    child_status = physics_storage_work_views(context, inputs%stochastic_physics, inputs%lspsdt, &
             inputs%providers%stochastic_configuration%lspp, inputs%cellular, inputs%runtime, block, active, global_start, latitude)
    if (child_status /= 0) goto 900
    context%perturbation_local%zdissgw = 0.0_real64
    child_status = physics_storage_child_table(context%records, context%arrays, context%surface_variables, &
                   context%records%surface_metadata, block, inputs%vertical_velocity_first, child_arguments, context%fallback_owned)
    if (child_status /= 0) goto 900
    child_status = ec_phys(context, local_inputs)
    if (child_status /= 0) goto 900
    child_status = physics_storage_end_block(context, inputs%stochastic_physics, inputs%lspsdt, &
                                             inputs%providers%stochastic_configuration%lspp)
    if (child_status /= 0) goto 900
    block_live = .false.
  end do
  child_status = finish_physics_context(context)
  if (child_status /= 0) goto 900
  context_live = .false.
  if (radiation_step) then
    call statistics(1002_int32, 1_int32)
  else
    call statistics(1001_int32, 1_int32)
  end if
  if (lhook) call dr_hook('EC_PHYS_DRV_BAR', 0, barrier_hook)
  call statistics_barrier(730_int32)
  if (lhook) call dr_hook('EC_PHYS_DRV_BAR', 1, barrier_hook)
  call statistics(1064_int32, 0_int32)
  do global_start = 1, q, p
    block = (global_start - 1)/p + 1; active = min(p, q - global_start + 1)
    child_status = physics_driver_tendency_table(local_inputs%records, local_inputs%arrays, block, active, 1_int32, &
                                                 t1, ph9, inputs%records%model%physics%cloud, inputs%lnodryflx, tendency_arguments)
    if (child_status /= 0) goto 900
    call apply_physics_state_rates(p, 1_int32, active, l, time_step, &
                                   inputs%records%model%physics%cloud%rlmin, inputs%records%model%physics%cloud%ramin, &
                                   inputs%providers%thermal%ralvdcp, inputs%providers%thermal%ralsdcp, inputs%lnodryflx, &
                                   components, water, cloud, continuity, local_inputs%arrays%pgmv(:, :, ph9(1), block), &
                                   local_inputs%arrays%pgmv(:, :, ph9(2), block), local_inputs%arrays%pgmv(:, :, ph9(3), block), &
                                   local_inputs%arrays%gfl(:, :, :, block), local_inputs%arrays%pgmvt1(:, :, t1(1), block), &
                                   local_inputs%arrays%pgmvt1(:, :, t1(2), block), local_inputs%arrays%pgmvt1(:, :, t1(3), block), &
                  local_inputs%arrays%gflt1(:, :, :, block), child_status, dynamic_rates(:, :, :, block), convectivity(:, :, block))
    if (child_status /= 0) goto 900
  end do
  call statistics(1064_int32, 1_int32)
  if (lhook) call dr_hook('EC_PHYS_DRV', 1, hook)
  status = 0_int32
  return
900 continue
  if (block_live) cleanup_status = physics_storage_end_block(context, inputs%stochastic_physics, inputs%lspsdt, &
                                                             inputs%providers%stochastic_configuration%lspp)
  if (context_live) cleanup_status = finish_physics_context(context)
  status = 3_int32
  end procedure ec_phys_drv

  function project_component(component) result(view)
    type(field_component_metadata), intent(in) :: component
    type(tracer_state_descriptor) :: view
    view%active = component%lactive /= 0
    view%new_state_active = component%lt1 /= 0
    view%earlier_field = component%mp
    view%previous_physics_field = component%mp9_ph
    view%new_field = component%mp1
  end function
end submodule
