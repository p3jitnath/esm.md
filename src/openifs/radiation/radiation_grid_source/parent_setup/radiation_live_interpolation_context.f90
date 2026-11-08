!> Borrow the actual model-grid inputs used by radiation setup.
!! No member owns payload. The caller keeps every TARGET array alive until
!! both interpolation states have been released. Counts and map origins are
!! projected from the initialized model geometry, not selected defaults.
module forecast_radiation_interpolation_context
  use iso_fortran_env, only: int32, int64, real64
  use forecast_interpolation_local_maps, only: native_interpolation_grid_parameters
  implicit none
  private
  public :: native_radiation_main_grid_view
  !> Supply canonical local grid metadata and complete readonly borrowed views.
 !! ROW_LENGTHS has global bounds(-1:N+2); STARTS/COUNTS keep first bound-1.
 !! FIRST_POINT/FIRST_LATITUDE/LAST_LATITUDE are indexed by the north/south
 !! region. PROCESS_IDS is in actual communicator order. LATITUDE/LONGITUDE
 !! have one radian-valued entry per local physical point. Budget is bytes.
 !! REPORT_UNIT is the real open Fortran unit used by the source reports.
  type :: native_radiation_main_grid_view
    type(native_interpolation_grid_parameters) :: grid
    integer(int32), pointer, contiguous :: row_lengths(:) => null(), starts(:, :) => null(), counts(:, :) => null()
    integer(int32), pointer, contiguous :: first_point(:) => null(), first_latitude(:) => null(), last_latitude(:) => null()
    integer(int32), pointer, contiguous :: process_ids(:) => null()
    real(real64), pointer, contiguous :: latitude(:) => null(), longitude(:) => null()
    integer(int64) :: communication_budget = 0_int64
    integer(int32) :: report_unit = 0
  end type
end module
