!> Copy only the three source-ordered convection thermal updates.
module convection_thermal_publication_port
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_parameter_fields_mod, only: convection_thermal_parameter_record
  implicit none
  private
  public :: publish_convection_thermal_parameters
contains
  !> Publish the convection values after ordinary thermal setup and SUCUMF.
  !! THERMAL is the caller-owned native thermal record. CONVECTION is a
  !! readonly three-field record kept live until this copy finishes.
  !! Water and ice temperatures use K and reciprocal width uses K^-1.
  !! The owners must be separate. Every other thermal member is unchanged.
  !! There is no allocation, retained pointer or numerical calculation.
  subroutine publish_convection_thermal_parameters(thermal,convection)
    type(thermal_parameter_record), intent(inout) :: thermal
    type(convection_thermal_parameter_record), intent(in) :: convection
    thermal%rtwat=convection%rtwat
    thermal%rticecu=convection%rticecu
    thermal%rtwat_rticecu_r=convection%rtwat_rticecu_r
  end subroutine
end module
