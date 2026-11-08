!> Own the fresh-start I/O strings and the pressure forcing array.
!! Four other forcing arrays belong to the explicitly borrowed canonical physics record.
module forecast_fresh_storage_types
  use iso_fortran_env, only: int32, int64, real64
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  implicit none
  private
  public :: native_forecast_io_controls, native_fresh_forecast_state
  public :: owned_forecast_io_controls, owned_fresh_forecast
  type native_forecast_io_controls
    character(120) :: cfrcf = repeat(achar(0), 120), ciosprf = repeat(achar(0), 120)
    logical :: lrcftime = .false.
  end type
  type native_fresh_forecast_state
    real(real64), allocatable :: gpforcesp(:, :, :)
    type(native_physics_runtime_data), pointer :: physics => null()
    integer(int64) :: owned_mask = 0
    logical :: l_cld_deact = .false.
  end type
  type(native_forecast_io_controls), save, target :: owned_forecast_io_controls
  type(native_fresh_forecast_state), save, target :: owned_fresh_forecast
end module
