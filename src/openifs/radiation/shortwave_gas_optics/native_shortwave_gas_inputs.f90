!> Native shortwave molecular columns and interpolation inputs.
!! All pointer components are borrowed views of caller-owned arrays. The caller
!! keeps every target alive, supplies disjoint outputs, and admits supported
!! dimensions before numerical entry. No pointer component owns its target.
module native_shortwave_gas_inputs
  use iso_fortran_env, only: real64, int32
  implicit none
  private
  public :: shortwave_layer_inputs
  integer, parameter, public :: water_column = 1, carbon_dioxide_column = 2, ozone_column = 3, methane_column = 4, oxygen_column = 5
  type :: shortwave_layer_inputs
    integer(int32) :: levels = 0
    real(real64), pointer :: fac00(:, :) => null(), fac01(:, :) => null(), fac10(:, :) => null(), fac11(:, :) => null()
integer(int32), pointer :: pressure_index(:, :) => null(), temperature_index(:, :) => null(), next_temperature_index(:, :) => null()
    real(real64), pointer :: mixture_cap(:) => null(), molecules(:, :) => null(), gas(:, :, :) => null()
    integer(int32), pointer :: tropopause(:) => null()
    real(real64), pointer :: self_factor(:, :) => null(), self_fraction(:, :) => null()
    integer(int32), pointer :: self_index(:, :) => null()
    real(real64), pointer :: foreign_factor(:, :) => null(), foreign_fraction(:, :) => null()
    integer(int32), pointer :: foreign_index(:, :) => null()
    real(real64), pointer :: solar_cosine(:) => null()
  end type
end module
