!> Bind the existing fifteen canonical model aliases at the final address.
module forecast_native_model_module_aliases
  use iso_fortran_env, only: int32
  use forecast_selected_model_storage, only: native_selected_model_storage, native_model_parameter_aliases
  implicit none
  private
  public :: native_model_parameter_aliases, set_model_component_aliases, unset_model_component_aliases
contains
  !> Associate all fifteen typed destinations in original MODEL_SET order.
 !! OUTPUT is the unique stable storage owner, including its existing aliases.
 !! No scientific value is read or copied. Typed components make every
 !! destination distinct; the compiler owns addresses and pointer descriptors.
  integer(int32) function set_model_component_aliases(output) result(status)
    type(native_selected_model_storage), target, intent(inout) :: output
    output%aliases%yrdphy => output%model%physics_dimensions
    output%aliases%ygfl => output%model%fields
    output%aliases%yrerad => output%ecmwf%radiation%radiation
    output%aliases%yreaeratm => output%ecmwf%radiation%aerosol_atmosphere
    output%aliases%yrephli => output%model%physics%linear_ecmwf
    output%aliases%yreaerlid => output%ecmwf%radiation%aerosol_lidar
    output%aliases%yreaersnk => output%ecmwf%radiation%aerosol_sinks
    output%aliases%yreaersrc => output%ecmwf%radiation%aerosol_sources
    output%aliases%yreaervol => output%ecmwf%radiation%aerosol_volume
    output%aliases%yrephy => output%model%physics%ecmwf_physics
    output%aliases%yrphy => output%model%physics%phy
    output%aliases%yrphy0 => output%meteo_france%atmospheric_parameters
    output%aliases%yrphy1 => output%meteo_france%surface_exchange_parameters
    output%aliases%yrphy2 => output%model%physics_auxiliary
    output%aliases%yrlouis => output%louis
    status = 0
  end function
  !> Retain all aliases, as the source hook-disabled MODEL_UNSET requires.
  subroutine unset_model_component_aliases(output)
    type(native_selected_model_storage), target, intent(inout) :: output
  end subroutine
end module
