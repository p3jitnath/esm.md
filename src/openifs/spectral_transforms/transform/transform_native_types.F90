!> Native transform metadata; counts are dimensionless and fields retain their units.
module md2asm_transform_types
  use iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_arithmetic
  implicit none
  private
  public :: transform_latitude_basis, transform_spectral_tables, transform_fourier_layout, transform_environment_ready
  type :: transform_latitude_basis
    real(real64), pointer :: antisymmetric(:, :) => null(), symmetric(:, :) => null()
  end type
  type :: transform_spectral_tables
    integer(int32) :: maximum_degree = 0, total_degree = 0, northern_latitudes = 0, total_latitudes = 0
    logical :: butterfly = .false., latitude_longitude = .false.
    real(real64), pointer :: degree_number(:) => null(), inverse_laplacian(:) => null(), epsilon_coefficients(:) => null()
    integer(int32), pointer :: degree_row(:) => null()
    type(transform_latitude_basis), allocatable :: basis(:)
  end type
  type :: transform_fourier_layout
    integer(int32) :: total_latitudes = 0, northern_latitudes = 0, first_latitude = 1, maximum_order = 0
    integer(int32) :: process_sets = 1, extra_longitudes = 0
    integer(int32), pointer :: maximum_wave(:) => null(), longitude_count(:) => null(), active_latitudes(:) => null()
    integer(int32), pointer :: column_offset(:) => null(), process_of_wave(:) => null(), buffer_block(:) => null()
    integer(int32), pointer :: input_block_offset(:) => null(), output_block_offset(:) => null()
    integer(int32), pointer :: wave_latitude_offset(:, :) => null(), process_of_latitude(:) => null()
    integer(int32), pointer :: inverse_wave_latitude_offset(:, :) => null()
    logical, pointer :: use_fft992(:) => null()
    real(real64), pointer :: trigonometric(:, :) => null()
    integer(int32), pointer :: factors(:, :) => null()
  end type
contains
!> Reuse the qualified nearest-even and exact-subnormal environment check.
  logical function transform_environment_ready()
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    transform_environment_ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    transform_environment_ready = .true.
  end function
end module
