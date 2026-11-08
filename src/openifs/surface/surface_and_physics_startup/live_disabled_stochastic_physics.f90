!> Forward actual model, grid, clock, diffusion and constant owners to SURAND1.
module forecast_live_disabled_stochastic_physics
  use iso_fortran_env, only: int32, int64
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_spectral_diffusion_setup, only: native_spectral_diffusion_state
  use stoph_mix, only: tstoph
  use forecast_disabled_stochastic_physics, only: initialize_disabled_stochastic_physics
  implicit none
  private
  public :: initialize_live_disabled_stochastic_physics
contains
  !> MODEL and GEOMETRY must be the same live initial context. DIFFUSION
  !! is the actual completed SUDYN diffusion producer; this caller provides
  !! no replacement defaults. OUTPUT is the unique STOPH owner. The
  !! source early TSTEP and TDT are the same accepted clock time step.
  integer(int32) function initialize_live_disabled_stochastic_physics(output, model, geometry, diffusion, text) result(status)
    type(tstoph), intent(inout) :: output
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_spectral_diffusion_state), intent(in) :: diffusion
    character(*), intent(in) :: text
    type(native_geometry_state), pointer :: actual_geometry
    status = 2
    if (.not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    actual_geometry => model%initial%geometry
    if (.not. associated(actual_geometry, geometry)) return
    if (model%initial%controls%namespace%nconf /= 1 .or. model%initial%controls%namespace%lecmwf /= 1) return
    if (model%initial%controls%namespace%lelam /= 0) return
    if (transfer(model%initial%controls%clock_input%dt, 0_int64) /= &
        transfer(model%initial%controls%clock%dt, 0_int64)) return
    if (transfer(model%initial%controls%clock%dt, 0_int64) <= 0_int64) return
    if (transfer(model%initial%controls%clock%dt, 0_int64) > int(z'412E848000000000', int64)) return
    status = initialize_disabled_stochastic_physics(output, geometry%dimensions%nsmax, geometry%dimensions%ndglg, &
                           diffusion%lspecvis, diffusion%hdirvor, model%initial%controls%clock%dt, model%initial%constants%ra, text)
  end function
end module
