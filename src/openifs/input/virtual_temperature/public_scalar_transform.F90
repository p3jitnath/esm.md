module public_scalar_transform_port
  !! Typed scalar calls to the existing public ECTRANS transform service.
  !! The caller owns the ready public context,field-owner map and arrays.
  !! This adapter supplies no transform calculation and owns no model state.
  use iso_fortran_env, only: int32, int64, real64
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  implicit none
  private
  public :: inverse_scalar_transform, forward_scalar_transform
#include "inv_trans.h"
#include "dir_trans.h"
contains
integer(int32) function inverse_scalar_transform(control, resolution, field_owner, local_points, spectral, gridpoint) result(status)
    !! spectral(local_fields,coefficient_capacity) is readonly. gridpoint
    !! has shape(P,global_fields,B),B=ceil(local_points/P),P1..1024.
    !! field_owner(global_fields) gives one-based public vertical owners.
    !! All arrays are contiguous and disjoint. Public transform effects on
    !! IEEE flags and errno remain observable. Return2 before the public call
    !! for invalid metadata,otherwise0 after its normal return.
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), contiguous, intent(in) :: field_owner(:)
    integer(int64), intent(in) :: local_points
    real(real64), contiguous, intent(in) :: spectral(:, :)
    real(real64), contiguous, intent(inout) :: gridpoint(:, :, :)
    integer(int32) :: rows
    status = 2
    if (.not. valid_scalar_views(control, resolution, field_owner, local_points, spectral, gridpoint)) return
    rows = size(gridpoint, 1)
    call inv_trans(pspscalar=spectral, kproma=rows, kvsetsc=field_owner, kresol=resolution%resolution, pgp=gridpoint)
    status = 0
  end function
integer(int32) function forward_scalar_transform(control, resolution, field_owner, local_points, gridpoint, spectral) result(status)
    !! Reverse the same map and scalar layout. Only the public spectral
    !! destination changes. Every optional public argument not shown in the
    !! source scalar call remains absent;no derivative or wind is requested.
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), contiguous, intent(in) :: field_owner(:)
    integer(int64), intent(in) :: local_points
    real(real64), contiguous, intent(in) :: gridpoint(:, :, :)
    real(real64), contiguous, intent(inout) :: spectral(:, :)
    integer(int32) :: rows
    status = 2
    if (.not. valid_scalar_views(control, resolution, field_owner, local_points, spectral, gridpoint)) return
    rows = size(gridpoint, 1)
    call dir_trans(pspscalar=spectral, kproma=rows, kvsetsc=field_owner, kresol=resolution%resolution, pgp=gridpoint)
    status = 0
  end function
  logical function valid_scalar_views(control, resolution, field_owner, local_points, spectral, gridpoint) result(valid)
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), intent(in) :: field_owner(:)
    integer(int64), intent(in) :: local_points
    real(real64), intent(in) :: spectral(:, :), gridpoint(:, :, :)
    integer(int64) :: coefficient_bound
    integer :: rows
    valid = .false.
    if (.not. control%message_ready .or. .not. control%environment_ready) return
    if (control%nproc < 1 .or. control%nproc > 32 .or. control%myproc < 1 .or. control%myproc > control%nproc) return
    if (control%nprtrv < 1 .or. control%nprtrv > control%nproc) return
    if (control%mysetv < 1 .or. control%mysetv > control%nprtrv) return
    if (resolution%resolution < 1 .or. resolution%truncation < 0 .or. resolution%truncation > 4096) return
    if (size(field_owner) < 1 .or. size(field_owner) > 4096) return
    if (any(field_owner < 1) .or. any(field_owner > control%nprtrv)) return
    if (count(field_owner == control%mysetv) /= size(spectral, 1)) return
    rows = size(gridpoint, 1)
    if (rows < 1 .or. rows > 1024 .or. size(gridpoint, 2) /= size(field_owner)) return
    if (local_points < 1 .or. local_points > 2147483647_int64) return
    if (int(size(gridpoint, 3), int64) /= (local_points + rows - 1)/rows) return
    coefficient_bound = int(resolution%truncation + 1, int64)*(resolution%truncation + 2) + 2
    if (size(spectral, 2) < 1 .or. mod(size(spectral, 2), 2) /= 0) return
    if (size(spectral, 2, kind=int64) > coefficient_bound) return
    valid = .true.
  end function
end module
