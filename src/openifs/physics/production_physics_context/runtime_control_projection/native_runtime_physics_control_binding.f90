!> Project only actual runtime controls into the existing physics input type.
!! This module owns no weather arrays, model records or ready-state producer.
module forecast_native_runtime_physics_control_binding
  use iso_fortran_env, only: int32
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_soil_diagnostic_class_counts, only: native_soil_diagnostic_class_counts
  use forecast_disabled_stochastic_patterns, only: native_sppt_data
  use yomspsdt, only: tsppt_config
  use forecast_output_setup_upstream, only: native_output_setup_upstream
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use forecast_runtime_physics_count_views, only: project_runtime_physics_counts
  use yomhook, only: lhook
  implicit none
  private
  public :: bind_native_runtime_physics_input_controls
  public :: native_public_hook_control, refresh_native_public_hook_control, bind_native_public_hook_control
  !> Retain one actual public LHOOK read at a stable caller-owned address.
 !! ENABLED has no guessed initial value. Bind or refresh before its first use,
 !! and refresh at each source call boundary that can observe a changed LHOOK.
  type :: native_public_hook_control
    logical :: enabled
  end type
contains
  !> Borrow actual startup/scientific records; publish only the named controls.
 !! SOIL supplies fourteen produced SUNDDH counts. Radiation NRADFR comes from
 !! the same actual completed ECMWF setup. The source LSPSDT=false branch does
 !! not read N2D: preserve that unused consumer member without reading the
 !! source-unwritten DATA%N2D. A true branch requires a separately produced,
 !! defined nonnegative N2D; the current disabled SPPT producer admits false.
 !! OUTPUT_UPSTREAM must be ready and remain TARGET while LNODRYFLX is borrowed.
 integer(int32) function bind_native_runtime_physics_input_controls(startup,soil,sppt_data,sppt_config,output_upstream,inputs)result(status)
    type(native_forecast_startup_storage), target, intent(in) :: startup
    type(native_soil_diagnostic_class_counts), intent(in) :: soil
    type(native_sppt_data), target, intent(in) :: sppt_data
    type(tsppt_config), target, intent(in) :: sppt_config
    type(native_output_setup_upstream), target, intent(inout) :: output_upstream
    type(native_complete_physics_driver_inputs), intent(inout) :: inputs
    integer(int32) :: soil_counts(14), radiation_interval, n2d
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. startup%initial%ready) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. startup%loaded%storage%model%ready) return
    if (.not. startup%loaded%storage%ecmwf%setup_complete) return
    if (.not. output_upstream%ready) return
    if (sppt_config%lspsdt) then
      n2d = sppt_data%n2d
      if (n2d < 0_int32) return
    end if
    status = project_runtime_physics_counts(soil, startup%loaded%storage%ecmwf%radiation%radiation, soil_counts, radiation_interval)
    if (status /= 0_int32) return
    inputs%soil_diagnostics = soil_counts
    inputs%nrfrad = radiation_interval
    inputs%lspsdt = sppt_config%lspsdt
    if (sppt_config%lspsdt) inputs%n2d = n2d
    inputs%lnodryflx => output_upstream%lnodryflx
    status = 0_int32
  end function
  !> Read the current public FIAT flag into the caller's one logical target.
 !! No public variable, numerical state, clock, IEEE flag or errno is changed.
  integer(int32) function refresh_native_public_hook_control(control) result(status)
    type(native_public_hook_control), intent(inout) :: control
    control%enabled = lhook
    status = 0_int32
  end function
  !> Refresh before publishing the target into the actual provider carrier.
 !! CONTROL remains TARGET at this address until the provider view closes.
 !! The existing provider owner must already be associated. No target is
 !! published and no bridge is read or changed on that refusal.
  integer(int32) function bind_native_public_hook_control(control, inputs) result(status)
    type(native_public_hook_control), target, intent(inout) :: control
    type(native_complete_physics_driver_inputs), intent(inout) :: inputs
    status = 2_int32
    if (.not. associated(inputs%providers)) return
    status = refresh_native_public_hook_control(control)
    inputs%providers%hook_enabled => control%enabled
  end function
end module
