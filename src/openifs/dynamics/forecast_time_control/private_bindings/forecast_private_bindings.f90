!> Give forecast callers direct native names for the complete owned providers.
!! These names preserve each provider's explicit argument kinds, shapes, intent,
!! optional presence and supported domain. They own no numerical field or copy.
module forecast_private_bindings
  use forecast_selected_spectral_children, only: &
    md2asm_scm_coriolis_prepare => initialize_spectral_coriolis, &
    md2asm_scm_coriolis_correct => finish_spectral_coriolis, &
    md2asm_spcsi_pressure_solve => solve_spectral_coriolis_modes, &
    md2asm_spcsi_sigam => form_spectral_geopotential, &
    md2asm_spcsi_temperature_pressure => form_spectral_temperature_pressure_rates
  use md2asm_surface_pressure_and_spectral_filter, only: &
    md2asm_scm_spectral_filter => filter_spectral_vorticity
  use md2asm_vertical_operators, only: verdisint_assembly => apply_vertical_operator
  use native_greenhouse_timeseries, only: md2asm_owned_greenhouse_lookup => get_ghg_concentrations
  use native_solar_irradiance, only: md2asm_owned_solar_lookup => get_solar_irradiance
  use forecast_aerosol_vertical_profiles, only: md2asm_su_aerv => initialize_aerosol_record_profiles
  use md2asm_hybrid_pressure_and_gradients, only: &
    md2asm_updecaec_private_gphpre => compute_hybrid_pressure
  implicit none
  private
  public :: md2asm_scm_coriolis_prepare, md2asm_scm_coriolis_correct, md2asm_scm_spectral_filter
  public :: md2asm_spcsi_pressure_solve, md2asm_spcsi_sigam, md2asm_spcsi_temperature_pressure
  public :: verdisint_assembly, md2asm_owned_greenhouse_lookup, md2asm_owned_solar_lookup
  public :: md2asm_su_aerv, md2asm_updecaec_private_gphpre
  public :: md2asm_external_transform_guard_terminal_r2
  interface
    subroutine public_abort() bind(C, name='abort')
    end subroutine
  end interface
contains
  !> Preserve the terminal unsupported-transform guard through the public C runtime.
  !! There are no arguments, outputs or numerical operations. This does not return.
  subroutine md2asm_external_transform_guard_terminal_r2()
    call public_abort()
  end subroutine
end module forecast_private_bindings
