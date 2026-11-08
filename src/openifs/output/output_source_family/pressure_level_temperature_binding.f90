!> Bind both temperature aliases to the complete owned pressure-level method.
!! The compiler supplies the native Fortran interface. Constants and atmosphere
!! tables are readonly produced owners; pressure uses Pa and temperature K.
!! The imported PPT interface defines all shapes, optional arguments and writes.
module forecast_pressure_level_temperature_binding
  use forecast_pressure_level_interpolation, only: ppt => ppt
  use forecast_pressure_level_interpolation, only: ppt_qualified_original_alias => ppt
  implicit none
  private
  public :: ppt, ppt_qualified_original_alias
end module
