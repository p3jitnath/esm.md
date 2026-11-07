module vertical_interval_coordinate_port
  use iso_c_binding, only : c_double
  implicit none
  private
  public :: interval_coordinate, md2asm_vertical_interval_coordinate_fortran
contains
  function interval_coordinate(lower,upper,coordinate) result(value)
    !! Return the dimensionless interval coordinate for finite, distinct endpoints.
    !! All inputs are FP64 scalars in the same coordinate unit and remain unchanged.
    real(c_double), intent(in) :: lower,upper,coordinate
    real(c_double) :: value,numerator,denominator
    numerator=coordinate-lower
    denominator=upper-lower
    value=numerator/denominator
  end function
  function md2asm_vertical_interval_coordinate_fortran(lower,upper,coordinate) result(value) &
      bind(C,name="md2asm_vertical_interval_coordinate_fortran")
    real(c_double), value :: lower,upper,coordinate
    real(c_double) :: value
    value=interval_coordinate(lower,upper,coordinate)
  end function
end module
