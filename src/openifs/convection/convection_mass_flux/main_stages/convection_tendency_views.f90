!> Borrow source-named convection tendency arrays without owning a second state.
module forecast_convection_tendency_views
  use iso_fortran_env, only: real64
  implicit none
  private
  public :: convection_tendency_views
  type :: convection_tendency_views
    real(real64), pointer :: t(:, :) => null(), q(:, :) => null(), u(:, :) => null(), v(:, :) => null()
  end type
end module forecast_convection_tendency_views
