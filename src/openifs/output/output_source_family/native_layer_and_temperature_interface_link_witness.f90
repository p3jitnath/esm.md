!> Compile-only public interface witness; no verifier or numerical call.
module output_family_interface_link_witness
  use forecast_physical_parameter_layer_views
  use forecast_pressure_level_temperature_binding
  implicit none
contains
  subroutine bind_owned_layer_targets(mountain, radiation, convection, cloud, temperature)
    procedure(mountain_wave_layer), pointer, intent(out) :: mountain
    procedure(radiative_flux_layer), pointer, intent(out) :: radiation
    procedure(convection_layer), pointer, intent(out) :: convection
    procedure(cloud_microphysics_layer), pointer, intent(out) :: cloud
    procedure(ppt), pointer, intent(out) :: temperature
    mountain => mountain_wave_layer
    radiation => radiative_flux_layer
    convection => convection_layer
    cloud => cloud_microphysics_layer
    temperature => ppt_qualified_original_alias
  end subroutine
end module
