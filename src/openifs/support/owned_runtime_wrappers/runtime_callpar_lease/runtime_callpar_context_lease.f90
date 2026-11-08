!> Borrow the actual CALLPAR providers after the source-ordered control writes.
!! The compiler owns native record layout. This entry owns no payload or clock.
module forecast_runtime_callpar_context_lease
  use iso_fortran_env, only: int32
  use forecast_physics_provider_targets, only: callpar_provider_targets
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use forecast_native_runtime_physics_control_binding, only: native_public_hook_control
  use forecast_physics_runtime_startup, only: initialize_canonical_physics_runtime
  implicit none
  private
  public :: initialize_runtime_callpar_context_lease
contains
  !> Publish native borrowed provider targets for one source CALLPAR lifetime.
  !! PROVIDERS and INPUTS refer to the same existing provider carrier. STARTUP
  !! owns the single model, scalar record, runtime controls and forecast clock.
  !! HOOK is the caller's stable target, already read from public FIAT LHOOK
  !! and bound into PROVIDERS. Its false value is an admission condition, not
  !! a replacement flag. Existing thermal and stability targets stay borrowed.
  !! CURRENT_STEP is copied on entry and uses the dimensionless model-step unit.
  !! Selected eight-step and live shorter clocks admit steps 0:TOTAL_STEPS,
  !! with TOTAL_STEPS in 1:8. The source late step refusal preserves the earlier
  !! CPL_NEMO_LIM=0 write but leaves provider pointer publication unchanged.
  !! All target owners remain at their final addresses until CALLPAR releases
  !! its views. The caller establishes the qualified round-to-nearest gradual-
  !! underflow environment; this metadata entry performs no FP arithmetic.
  !! Status 0 publishes the lease. Status 2 refuses an unsupported association,
  !! configuration, hook or step. A nonzero runtime child status is propagated.
  integer(int32) function initialize_runtime_callpar_context_lease(providers, startup, inputs, hook, current_step) result(status)
    type(callpar_provider_targets), target, intent(inout) :: providers
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_complete_physics_driver_inputs), target, intent(in) :: inputs
    type(native_public_hook_control), target, intent(inout) :: hook
    integer(int32), value, intent(in) :: current_step
    type(callpar_provider_targets) :: pending
    integer(int32) :: total_steps
    status = 2_int32
    ! Every admission before the coupling child is free of public writes.
    if (.not. allocated(startup%initial)) return
    if (.not. startup%initial%ready) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. startup%loaded%storage%model%ready) return
    if (.not. associated(startup%loaded%fields)) return
    if (.not. associated(startup%loaded%storage%model%initial, startup%initial)) return
    if (.not. associated(startup%loaded%storage%model%partition)) return
    if (.not. associated(startup%loaded%fields%state_model, startup%loaded%storage%model)) return
    if (.not. associated(startup%loaded%fields%geometry, startup%initial%geometry)) return
    if (.not. associated(inputs%records%model, startup%loaded%storage%model)) return
    if (.not. associated(inputs%records%geometry, startup%initial%geometry)) return
    if (.not. associated(inputs%providers, providers)) return
    if (.not. associated(inputs%runtime)) return
    if (.not. associated(providers%thermal)) return
    if (.not. associated(providers%stability)) return
    if (.not. associated(providers%hook_enabled, hook%enabled)) return
    if (hook%enabled) return
    if (startup%loaded%storage%model%partition%phase /= 7_int32) return
    associate (model => startup%loaded%storage%model, geometry => startup%initial%geometry)
      if (geometry%transform_control%nproc < 1_int32) return
      if (geometry%transform_control%nprtrw < 1_int32 .or. geometry%transform_control%nprtrv < 1_int32) return
      if (geometry%transform_control%nprtrw*geometry%transform_control%nprtrv /= geometry%transform_control%nproc) return
   if (geometry%transform_control%myproc < 1_int32 .or. geometry%transform_control%myproc > geometry%transform_control%nproc) return
      if(geometry%transform_control%mysetv/=mod(geometry%transform_control%myproc-1_int32,geometry%transform_control%nprtrv)+1_int32)return
      if (model%climate%cplng_active .or. model%climate%lnemocoup) return
      if (startup%initial%controls%namespace%nconf /= 1_int32 .or. startup%initial%controls%namespace%lecmwf /= 1_int32) return
      if (startup%initial%controls%namespace%larpegef /= 0_int32 .or. startup%initial%controls%namespace%lelam /= 0_int32) return
      if (startup%initial%controls%namespace%lifstraj /= 0_int32 .or. startup%initial%controls%namespace%lifsmin /= 0_int32) return
      if (startup%initial%controls%namespace%lsforc /= 0_int32 .or. inputs%runtime%lusekf_ref) return
    end associate
    ! First source child: only the actual scalar CPL_NEMO_LIM is written.
    startup%scalars%cpl_nemo_lim = 0_int32
    ! Second source child: publish into the one live clock after step admission.
    total_steps = startup%initial%controls%clock%total_steps
    if (total_steps < 1_int32 .or. total_steps > 8_int32) return
    if (current_step < 0_int32 .or. current_step > total_steps) return
    startup%initial%controls%clock%current_step = current_step
    ! Third source child: initialize only the canonical 32-byte native controls.
    status = initialize_canonical_physics_runtime(startup%runtime_controls)
    if (status /= 0_int32) return
    ! Publish pointer metadata last. All other live scientific targets persist.
    pending = providers
    pending%physical => startup%initial%constants
    pending%current_step => startup%initial%controls%clock%current_step
    pending%hook_enabled => hook%enabled
    pending%scmec_enabled => startup%runtime_controls%lscmec
    pending%runtime_scalars => startup%scalars
    providers = pending
    status = 0_int32
  end function initialize_runtime_callpar_context_lease
end module forecast_runtime_callpar_context_lease
