!> Canonical GP_MODEL work owners shared by storage and initialization.
module forecast_grid_work_state
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: native_grid_work_state
  type :: native_grid_work_state
    integer(int32) :: columns = 0, levels = 0, blocks = 0, scalar_fields = 0, first_fields = 0, second_fields = 0
    integer(int64) :: first_extent = 0_int64
    integer(int32), allocatable :: il0(:, :, :, :)
    real(real64), allocatable :: zlscaw(:, :, :, :), zslbuf1(:, :), zslbuf2(:, :, :)
  end type
! The producer owns IL0(P,L,0:3,B), ZLSCAW(P,L,S,B),
! ZSLBUF1(first_extent,F1), and ZSLBUF2(P,F2,B).
! It allocates them in this order and leaves payloads unwritten.
! The compiler owns descriptors, addresses and alignment. All owners must
! remain disjoint and live; their elements retain the source field's units.
end module
