!> Own radiation transform maps while borrowing the one actual radiation grid.
!! All arrays use native Fortran bounds. No historical record offsets are used.
!! The caller retains GRID and ROW_LENGTHS until collective release completes.
module forecast_native_radiation_transform_storage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_null_ptr
  use forecast_public_transform, only: native_transform_resolution
  use forecast_native_radiation_grid, only: native_radiation_grid, native_radiation_point_partition
  implicit none
  private
  public :: native_radiation_transform_storage
  !> NSTA/NONL and three latitude maps are the actual public inquiry owners.
 !! ZMU owns ordinary and reflected Gaussian latitude sines. GRID owns the
 !! other three Gaussian arrays and five point arrays in their original order.
 !! State0 is fresh,1 storage,2 Gaussian,3 points,4 points with ZMU retired.
 !! State5 adds the enclosing halo-owned RLATI/RIPI, released by that parent.
 !! State and saved addresses describe ownership, not physical input values.
  type :: native_radiation_transform_storage
    type(native_radiation_grid), pointer :: grid => null()
    integer(int32), pointer, contiguous :: row_lengths(:) => null()
    type(native_transform_resolution) :: resolution
    integer(int32), allocatable :: nsta(:, :), nonl(:, :)
    integer(int32), allocatable :: nptrfrstlat(:), nfrstlat(:), nlstlat(:)
    real(real64), allocatable :: zmu(:)
    type(native_radiation_point_partition) :: points
    integer(int32) :: nspec2 = 0, nump = 0, ngptotg = 0, ngptotmx = 0, state = 0
    type(c_ptr) :: allocation_address(14) = c_null_ptr
    type(c_ptr) :: halo_address(2) = c_null_ptr
  end type
end module forecast_native_radiation_transform_storage
