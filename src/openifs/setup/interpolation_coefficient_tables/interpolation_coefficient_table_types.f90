!> Keep the three original TSLINT table owners in one native record.
module forecast_interpolation_coefficient_table_types
  use iso_fortran_env, only: int32, real64
  use vertical_spline_interpolation_port, only: spline_interpolation_owners
  use forecast_vertical_interpolation_coefficients, only: native_vertical_interpolation_coefficients
  use forecast_meridional_interpolation, only: native_meridional_interpolation
  implicit none
  private
  public :: native_interpolation_coefficient_tables
  !> Each component is the existing scientific owner, rather than a copied view.
 !! Coefficients use dimensionless eta and latitude in radians. The final owner
 !! remains TARGET and stable while LASCAW or other interpolators borrow arrays.
 !! Publication is source ordered; failed setup may leave completed child owners
 !! for the production release routine. READY is true only after all stages.
  type :: native_interpolation_coefficient_tables
    type(spline_interpolation_owners) :: yrvsplip
    type(native_vertical_interpolation_coefficients) :: yrvsleta
    type(native_meridional_interpolation) :: yrhslmer
    integer(int32) :: levels = 0, first_halo = 0, last_halo = -1
    logical :: ready = .false.
  end type
end module
