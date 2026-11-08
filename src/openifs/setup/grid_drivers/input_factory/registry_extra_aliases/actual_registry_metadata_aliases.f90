!> Retain the genuine absent metadata groups of the supported forecast.
!! The original YPHYS pointer starts null. The three surface pointers are
!! written only for positive greenhouse-gas, chemistry or aerosol counts.
!! This projection checks actual produced counts before retaining absence.
module forecast_actual_registry_metadata_aliases
  use iso_fortran_env, only: int32
  use grid_field_configuration_types_port, only: grid_field_configuration
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_native_field_variable_types, only: native_registry_extra_aliases
  implicit none
  private
  public :: bind_actual_registry_extra_aliases
contains
  !> Validate and publish four source-defined null metadata views.
  !! configuration is the readonly actual produced GFL metadata owner;
  !! surface_metadata is its readonly ready surface companion. Their
  !! registration and species counts are dimensionless. output is INOUT
  !! caller-owned view storage. Success0 retains the four null pointers;
  !! refusal2 changes no output. Foreign existing views are refused.
  !! Positive species groups need their genuine metadata producer and are
  !! outside this source route. No physical array is created or copied.
  !! The caller can keep this carrier at its final execution-state address.
  integer(int32) function bind_actual_registry_extra_aliases(configuration, surface_metadata, output) result(status)
    type(grid_field_configuration), intent(in) :: configuration
    type(surface_field_registry), intent(in) :: surface_metadata
    type(native_registry_extra_aliases), intent(inout) :: output
    status = 2_int32
    if (associated(output%phys) .or. associated(output%tcghg)) return
    if (associated(output%tcchem) .or. associated(output%aerodiag)) return
    if (.not. surface_metadata%ready) return
    if (configuration%registration%numflds < 1) return
    if (configuration%registration%last_index < 1) return
    if (configuration%alias_controls%nghg /= 0) return
    if (configuration%settings%nchem_tc /= 0) return
    if (configuration%settings%nactaero /= 0) return
    nullify (output%phys, output%tcghg, output%tcchem, output%aerodiag)
    status = 0_int32
  end function
end module forecast_actual_registry_metadata_aliases
