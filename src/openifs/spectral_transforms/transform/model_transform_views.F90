!> Borrowed model transform views; every pointer keeps its producer's lifetime.
module md2asm_model_transform_views
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: transform_call_controls, transform_field_views
  type :: transform_call_controls
    integer(int32) :: resolution = 0, block_rows = 0, processes = 1, split_fields = 0
    logical :: scalar_derivatives = .false., grid_vorticity = .false., grid_divergence = .false.
    logical :: wind_derivatives = .false., latitude_longitude = .false.
  end type
  type :: transform_field_views
    real(real64), pointer :: vorticity(:, :) => null(), divergence(:, :) => null(), scalar(:, :) => null(), scalar2(:, :) => null()
    real(real64), pointer :: scalar3a(:, :, :) => null(), scalar3b(:, :, :) => null()
    real(real64), pointer :: grid(:, :, :) => null(), grid2(:, :, :) => null()
    real(real64), pointer :: grid_wind(:, :, :, :) => null(), grid3a(:, :, :, :) => null(), grid3b(:, :, :, :) => null()
    integer(int32), pointer :: set_wind(:) => null(), set_scalar(:) => null(), set_scalar2(:) => null()
    integer(int32), pointer :: set_scalar3a(:) => null(), set_scalar3b(:) => null()
  end type
end module
