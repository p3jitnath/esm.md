!> SCAN2M: preserve the complete grid-scan call order over native owners.
module forecast_native_grid_scan
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_initial_fields_storage, only: native_initial_fields_state
  use forecast_runtime_operational_input, only: native_runtime_operational_input_state
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs, gp_model
  use forecast_native_transport_input_binding, only: refresh_native_transport_scan_controls
  use forecast_native_gp_input_factory, only: refresh_native_gp_visit_controls
  use forecast_native_runtime_physics_control_binding, only: native_public_hook_control, refresh_native_public_hook_control
  use forecast_scan_output_call, only: native_scan_output_context, scan_selected_output_call
  use forecast_grid_native_bridges, only: scan_convert_virtual_temperature
  use md2asm_inactive_grid_derivatives, only: gradient_component_control
  use md2asm_runtime_inactive_grid_derivatives, only: gp_derivatives
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: native_forecast_grid_scan_context, bind_forecast_grid_scan_context
  public :: scan2m, grid_scan_stage_count_get
  !> Borrow one canonical MODEL,FIELDS and input lifetime,plus real GP_MODEL views.
  !! OUTPUT contains genuine optional Fullpos owners;its absence branch reads
  !! neither the active output driver nor a weather payload. No owner is copied.
  !! The counters are diagnostic INT64 source words and have no physical units.
  type native_forecast_grid_scan_context
    type(native_operational_model_configuration), pointer :: model => null()
    type(native_initial_fields_state), pointer :: fields => null()
    type(native_runtime_operational_input_state), pointer :: input => null()
    type(native_forecast_scalar_data), pointer :: scalars => null()
    type(native_forecast_grid_inputs), pointer :: grid => null()
    logical, pointer :: lfindvsep => null()
    type(native_public_hook_control), pointer :: hook_control => null()
    type(native_scan_output_context) :: output
    type(transform_profile_policy) :: profile
    integer(int64) :: stage_calls(0:4) = 0_int64, derivative_calls = 0_int64
  end type
  interface
    subroutine grid_scan_statistics(event, phase) bind(C, name="gstats_")
      import c_int
      integer(c_int), intent(in) :: event, phase
    end subroutine
    function grid_scan_errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains

  !> Bind stable producer-owned targets without a numerical call or new payload.
  !! All targets remain live and fixed through the final SCAN2M call.
  !! The caller binds OUTPUT's real optional owners separately;unassociated
  !! pointers represent the source's actual absence branch. PROFILE is also
  !! caller-owned policy and is never inferred from an original module global.
integer(int32)function bind_forecast_grid_scan_context(context,model,fields,input,scalars,grid,lfindvsep,hook_control)result(status)
  type(native_forecast_grid_scan_context), intent(inout) :: context
  type(native_operational_model_configuration), target, intent(inout) :: model
  type(native_initial_fields_state), target, intent(inout) :: fields
  type(native_runtime_operational_input_state), target, intent(inout) :: input
  type(native_forecast_scalar_data), target, intent(inout) :: scalars
  type(native_forecast_grid_inputs), target, intent(inout) :: grid
  logical, target, intent(in) :: lfindvsep
  type(native_public_hook_control), target, intent(inout) :: hook_control
  status = 2
  if (associated(context%model) .or. associated(context%fields) .or. associated(context%input)) return
  if (associated(context%scalars) .or. associated(context%grid)) return
  if (.not. model%ready .or. .not. associated(model%initial)) return
  if (.not. model%initial%ready .or. .not. allocated(model%initial%geometry)) return
  if (.not. model%initial%geometry%initialized) return
  if (.not. associated(fields%state_model, model)) return
  if (.not. associated(input%model, model) .or. .not. associated(input%field_context, fields)) return
  if (input%world == MPI_COMM_NULL) return
  context%model => model; context%fields => fields; context%input => input
  context%scalars => scalars; context%grid => grid
  context%lfindvsep => lfindvsep; context%hook_control => hook_control
  status = 0
  end function

  !> Run conversion,derivatives,selected output,GP_MODEL and the final tracer copy.
  !! CONFIGURATION contains exactly nine source characters. STEP_GRID_FIELDS
  !! is LD_TST_GPGFL and DIGITAL_FILTER_STEP is LD_DFISTEP. They are source
  !! decisions supplied by STEPO,not new selectors for an omitted calculation.
  !! The live geometry supplies P points per block,L levels,Q local points
  !! and B=ceiling(Q/P) blocks. Current weather arrays and the separate next-time
  !! array retain their concrete owners,physical units and ordered arithmetic.
  !! Only active rows are changed. Padding,unused components and source-unwritten
  !! payloads are untouched. Every child is a concrete native provider.
  !! STATUS0 completes this call;nonzero identifies the failed child/refusal.
  !! FAILED_STAGE is0 admission,1 conversion,2 derivatives,3 output,4 grid
  !! model or5 final copy. A late failure is fatal to the enclosing forecast;
  !! it is not a resumable or independently verified partial time step.
  integer(int32)function scan2m(context,configuration,step_grid_fields,digital_filter_step,remaining_nsiter,failed_stage)result(status)
  type(native_forecast_grid_scan_context), target, intent(inout) :: context
  character(*), intent(in) :: configuration
  logical, intent(in) :: step_grid_fields, digital_filter_step
  integer(int32), intent(in) :: remaining_nsiter
  integer(int32), intent(out) :: failed_stage
  integer(int32) :: local
  real(real64) :: hook_handle
  failed_stage = 0
  status = admit_scan(context, configuration)
  if (.not. associated(context%input)) return
  if (context%input%world == MPI_COMM_NULL) return
  status = agree_scan_status(context%input%world, status)
  if (status /= 0) return
  call transform_profile_event("SCAN2M", 0_int32, hook_handle, context%profile)
  call grid_scan_statistics(8_c_int, 0_c_int)
  call grid_scan_statistics(1033_c_int, 0_c_int)

  if (configuration(3:3) /= '0') then
    failed_stage = 1
    local = convert_scan_temperature(context)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
  end if
  call grid_scan_statistics(1033_c_int, 1_c_int)

  if (configuration(3:3) /= '0') then
    failed_stage = 2
    local = calculate_scan_derivatives(context)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(2))
  end if
  call grid_scan_statistics(8_c_int, 1_c_int)

  failed_stage = 3
  local = admit_output_model_aliases(context)
  status = agree_scan_status(context%input%world, local)
  if (status /= 0) return
  local = scan_selected_output_call(context%output)
  status = agree_scan_status(context%input%world, local)
  if (status /= 0) return

  call grid_scan_statistics(8_c_int, 0_c_int)
  if (configuration(4:4) /= '0') then
    failed_stage = 4
    local = admit_grid_model_aliases(context)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
    ! These are the original two actual call arguments,forwarded as named
    ! native controls. No calculated tendency or pressure comes from STEPO.
    local = refresh_native_public_hook_control(context%hook_control)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
    call refresh_native_gp_visit_controls(context%grid, configuration, digital_filter_step, context%lfindvsep, local)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
    call refresh_native_transport_scan_controls(context%grid, context%input, remaining_nsiter, context%lfindvsep, local)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
    local = gp_model(context%grid, context%profile)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(3))
  end if
  call grid_scan_statistics(8_c_int, 1_c_int)

  if (step_grid_fields) then
    failed_stage = 5
    call grid_scan_statistics(1032_c_int, 0_c_int)
    ! Reload current owners after GP_MODEL. No view saved before its call
    ! supplies the final copy,so a changed native descriptor is observed.
    local = copy_scan_next_time_fields(context)
    status = agree_scan_status(context%input%world, local)
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(4))
    call grid_scan_statistics(1032_c_int, 1_c_int)
  end if
  call increment_source_counter(context%stage_calls(0))
  call transform_profile_event("SCAN2M", 1_int32, hook_handle, context%profile)
  failed_stage = 0; status = 0
end function

!> Read the original source guards from their genuine native producers.
integer(int32) function admit_scan(context, configuration) result(status)
  type(native_forecast_grid_scan_context), intent(in) :: context
  character(*), intent(in) :: configuration
  integer(int32) :: slot
  status = 2
  if (len(configuration) /= 9) return
  if (index('0AB1', configuration(3:3)) == 0) return
  if (configuration(6:6) /= '0') return
  if (.not. associated(context%model) .or. .not. associated(context%fields)) return
  if (.not. associated(context%input) .or. .not. associated(context%scalars)) return
  if (.not. context%model%ready .or. .not. associated(context%model%initial)) return
  if (.not. context%model%initial%ready .or. .not. allocated(context%model%initial%geometry)) return
  if (.not. context%model%initial%geometry%initialized) return
  if (.not. associated(context%fields%state_model, context%model)) return
  if (.not. associated(context%input%model, context%model)) return
  if (.not. associated(context%input%field_context, context%fields)) return
  if (context%input%world == MPI_COMM_NULL) return
  if (.not. associated(context%fields%runtime_physics)) return
  if (context%model%initial%controls%namespace%nconf /= 1) return
  if (context%model%initial%controls%namespace%lelam /= 0) return
  if (context%model%initial%controls%namespace%lifsmin /= 0) return
  if (context%model%initial%controls%namespace%nopt_memory <= 1) return
  if (context%fields%runtime_physics%lforcewr .or. context%fields%runtime_physics%ltestinc) return
  if (context%scalars%ltrajsave) return
  if (.not. context%model%dynamics%lsprt) return
  if (context%model%physics%ecmwf_physics%legbrad) return
  slot = context%model%fields%aliases%yrspec
  if (slot < 1 .or. slot > size(context%model%fields%components)) return
  if (context%model%fields%components(slot)%lgp /= 0) return
  status = 0
end function

!> Convert each live block from virtual temperature to temperature in kelvins.
integer(int32) function convert_scan_temperature(context) result(status)
  type(native_forecast_grid_scan_context), target, intent(inout) :: context
  integer(int32) :: p, l, q, b, block, active, temperature_slot
  status = 2
  if (.not. current_fields_shape(context, p, l, q, b)) return
  if (.not. allocated(context%model%motion%gmv)) return
  if (size(context%model%motion%gmv, 1) /= p .or. size(context%model%motion%gmv, 2) /= l) return
  if (size(context%model%motion%gmv, 4) /= b) return
  temperature_slot = context%model%motion%yt0%mt
  if (temperature_slot < 1 .or. temperature_slot > size(context%model%motion%gmv, 3)) return
  do block = 1, b
    active = min(p, q - (block - 1)*p)
    call scan_convert_virtual_temperature(context%input%thermal_constants, p, 1_int32, active, l, &
                                          context%input%constituents, context%fields%grid_fields%gfl(:, :, :, block), &
                                          context%model%motion%gmv(:, :, temperature_slot, block), status)
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(1))
  end do
  status = 0
end function

!> Apply the complete no-requested-gradient child to all live metadata rows.
integer(int32) function calculate_scan_derivatives(context) result(status)
  type(native_forecast_grid_scan_context), intent(inout) :: context
  type(gradient_component_control) :: components(2163)
  integer(int32) :: numflds, j
  status = 2
  numflds = context%model%fields%registration%numflds
  if (numflds < 1 .or. numflds > size(components)) return
  do j = 1, numflds
    if (.not. logical_word(context%model%fields%components(j)%lgp)) return
    if (.not. logical_word(context%model%fields%components(j)%lcders)) return
    components(j)%lgp = context%model%fields%components(j)%lgp /= 0
    components(j)%lcders = context%model%fields%components(j)%lcders /= 0
  end do
  call gp_derivatives(context%fields%runtime_physics%lgradgp, numflds, components(:numflds), &
                      context%derivative_calls, status, context%profile)
end function

!> Active Fullpos output must borrow the same live model and field owners.
  !! The source absence branch reads no active-driver member.
integer(int32) function admit_output_model_aliases(context) result(status)
  type(native_forecast_grid_scan_context), intent(in) :: context
  status = 0
  if (.not. associated(context%output%fields) .or. .not. associated(context%output%buffer)) return
  status = 2
  if (.not. associated(context%output%driver%model, context%model)) return
  if (.not. associated(context%output%driver%model_fields, context%fields)) return
  if (.not. associated(context%output%driver%spectral, context%input%spectral)) return
  if (.not. associated(context%fields%surface_metadata) .or. .not. associated(context%fields%surface_arrays)) return
  if (.not. associated(context%output%driver%surface_metadata, context%fields%surface_metadata)) return
  if (.not. associated(context%output%driver%surface_arrays, context%fields%surface_arrays)) return
  status = 0
end function

!> Confirm that GP_MODEL consumes the same canonical numerical owners.
integer(int32) function admit_grid_model_aliases(context) result(status)
  type(native_forecast_grid_scan_context), intent(in) :: context
  status = 2
  if (.not. associated(context%grid)) return
  if (.not. associated(context%lfindvsep) .or. .not. associated(context%hook_control)) return
  if (.not. associated(context%fields%grid_fields) .or. .not. associated(context%fields%next_time)) return
  if (.not. associated(context%fields%surface_metadata) .or. .not. associated(context%fields%surface_arrays)) return
  if (.not. associated(context%grid%model, context%model)) return
  if (.not. associated(context%grid%fields, context%fields%grid_fields)) return
  if (.not. associated(context%grid%next, context%fields%next_time)) return
  if (.not. associated(context%grid%registry, context%fields%registry)) return
  if (.not. associated(context%grid%surface_metadata, context%fields%surface_metadata)) return
  if (.not. associated(context%grid%surface_arrays, context%fields%surface_arrays)) return
  status = 0
end function

!> Copy current next-time values for LGP and LT1 fields with no coupling.
  !! Visit block,component,level,row in source order. Same-kind FP64 assignment
  !! copies each stored word without arithmetic or a change to padding.
integer(int32) function copy_scan_next_time_fields(context) result(status)
  type(native_forecast_grid_scan_context), target, intent(inout) :: context
  integer(int32) :: p, l, q, b, numflds, block, component, level, row, active, destination, source
  status = 2
  if (.not. current_fields_shape(context, p, l, q, b)) return
  if (.not. associated(context%fields%next_time)) return
  if (.not. allocated(context%fields%next_time%gflt1)) return
  if (size(context%fields%next_time%gflt1, 1) /= p .or. size(context%fields%next_time%gflt1, 2) /= l) return
  if (size(context%fields%next_time%gflt1, 4) /= b) return
  numflds = context%model%fields%registration%numflds
  if (numflds < 1 .or. numflds > size(context%model%fields%components)) return
  ! Check every used index before the first destination mutation.
  do component = 1, numflds
    if (.not. logical_word(context%model%fields%components(component)%lgp)) return
    if (.not. logical_word(context%model%fields%components(component)%lt1)) return
    if (context%model%fields%components(component)%lgp == 0 .or. context%model%fields%components(component)%lt1 == 0) cycle
    if (context%model%fields%components(component)%ncoupling /= 0) cycle
    destination = context%model%fields%components(component)%mp
    source = context%model%fields%components(component)%mp1
    if (destination < 1 .or. destination > size(context%fields%grid_fields%gfl, 3)) return
    if (source < 1 .or. source > size(context%fields%next_time%gflt1, 3)) return
  end do
  do block = 1, b
    active = min(p, q - (block - 1)*p)
    do component = 1, numflds
      if (context%model%fields%components(component)%lgp == 0 .or. context%model%fields%components(component)%lt1 == 0) cycle
      if (context%model%fields%components(component)%ncoupling /= 0) cycle
      destination = context%model%fields%components(component)%mp
      source = context%model%fields%components(component)%mp1
      do level = 1, l
        do row = 1, active
          context%fields%grid_fields%gfl(row, level, destination, block) = context%fields%next_time%gflt1(row, level, source, block)
        end do
      end do
    end do
  end do
  status = 0
end function

!> Derive every shape from the live geometry and reload the current GFL owner.
logical function current_fields_shape(context, p, l, q, b) result(valid)
  type(native_forecast_grid_scan_context), intent(in) :: context
  integer(int32), intent(out) :: p, l, q, b
  integer(int64) :: blocks
  valid = .false.; p = 0; l = 0; q = 0; b = 0
  if (.not. associated(context%fields%grid_fields)) return
  if (.not. associated(context%fields%grid_fields, context%input%upper%fields)) return
  if (.not. allocated(context%fields%grid_fields%gfl)) return
  p = context%model%initial%geometry%dimensions%nproma
  l = context%model%initial%geometry%dimensions%nflevg
  q = context%model%initial%geometry%partition%ngptot
  b = context%model%initial%geometry%partition%ngpblks
  if (p < 1 .or. p > 1024 .or. l < 1 .or. l > 4096 .or. q < 1) return
  blocks = (int(q, int64) + p - 1_int64)/p
  if (blocks < 1 .or. blocks > 1000000_int64 .or. blocks /= b) return
  if (size(context%fields%grid_fields%gfl, 1) /= p .or. size(context%fields%grid_fields%gfl, 2) /= l) return
  if (size(context%fields%grid_fields%gfl, 4) /= b) return
  valid = .true.
end function

integer(int64) function grid_scan_stage_count_get(context, index) result(value)
  type(native_forecast_grid_scan_context), intent(in) :: context
  integer(int32), intent(in) :: index
  value = 0_int64
  if (index >= 0 .and. index <= 4) value = context%stage_calls(index)
end function

!> Integer communication added for runtime ranks preserves reached FP/errno.
integer(int32) function agree_scan_status(world, local) result(status)
  type(MPI_Comm), intent(in) :: world
  integer(int32), intent(in) :: local
  type(ieee_status_type) :: saved
  integer(c_int), pointer, volatile :: error_number
  integer(c_int) :: saved_errno
  integer :: error, ignored
  call ieee_get_status(saved); call c_f_pointer(grid_scan_errno_address(), error_number); saved_errno = error_number
  call MPI_Allreduce(local, status, 1, MPI_INTEGER4, MPI_MAX, world, error)
  call ieee_set_status(saved); error_number = saved_errno
  if (error /= MPI_SUCCESS) call MPI_Abort(world, 3, ignored)
end function
pure logical function logical_word(value) result(valid)
  integer(int32), intent(in) :: value
  valid = value == 0 .or. value == 1
end function
end module forecast_native_grid_scan
