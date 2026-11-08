!> Gather output grid fields and retain their source mean and extrema order.
module forecast_fullpos_grid_norm_controller
  use iso_fortran_env, only: int32, int64, real64
  use yomhook, only: dr_hook, jphook
  use forecast_fullpos_result_types, only: native_fullpos_grid_norms
  implicit none
  private
  public :: calculate_output_grid_norms, fpgpnorm
  interface fpgpnorm
    module procedure calculate_output_grid_norms
  end interface
contains
  !> Preserve numeric minimum, including the negative-zero tie.
  real(real64) function source_minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    integer(int64) :: left, right
    left = transfer(a, 0_int64); right = transfer(b, 0_int64)
if(iand(right,int(z'7ff0000000000000',int64))==int(z'7ff0000000000000',int64).and.iand(right,int(z'000fffffffffffff',int64))/=0)then
      value = a; return
    end if
  if(iand(left,int(z'7ff0000000000000',int64))==int(z'7ff0000000000000',int64).and.iand(left,int(z'000fffffffffffff',int64))/=0)then
      value = b; return
    end if
    if (iand(left, int(z'7fffffffffffffff', int64)) == 0 .and. iand(right, int(z'7fffffffffffffff', int64)) == 0) then
      value = transfer(ior(left, right), 0.0_real64)
    else
      value = min(a, b)
    end if
  end function
  !> Preserve numeric maximum, including the positive-zero tie.
  real(real64) function source_maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    integer(int64) :: left, right
    left = transfer(a, 0_int64); right = transfer(b, 0_int64)
if(iand(right,int(z'7ff0000000000000',int64))==int(z'7ff0000000000000',int64).and.iand(right,int(z'000fffffffffffff',int64))/=0)then
      value = a; return
    end if
  if(iand(left,int(z'7ff0000000000000',int64))==int(z'7ff0000000000000',int64).and.iand(left,int(z'000fffffffffffff',int64))/=0)then
      value = b; return
    end if
    if (iand(left, int(z'7fffffffffffffff', int64)) == 0 .and. iand(right, int(z'7fffffffffffffff', int64)) == 0) then
      value = transfer(iand(left, right), 0.0_real64)
    else
      value = max(a, b)
    end if
  end function
  !> Gather active cells by their actual global index, then scan global order.
 !! FIELD(P,F,B) is borrowed, ACTIVE(B) excludes final-block padding and
 !! GLOBAL_POINT(P,B) gives one-based complete serial point indices.
 !! The exact HUGE word is missing; other values follow source arithmetic.
 !! Result units equal input field units; no latitude weighting is introduced.
 integer(int32)function calculate_output_grid_norms(world,verbosity,point_count,active,global_point,field,vertical_sets,resolutions,configuration,hook_enabled,budget,result)result(status)
  integer(int32), intent(in) :: world, verbosity, point_count, active(:), global_point(:, :), vertical_sets(:), resolutions(:, :)
  real(real64), intent(in) :: field(:, :, :)
  character(*), intent(in) :: configuration
  logical, intent(in) :: hook_enabled
  integer(int64), intent(in) :: budget
  type(native_fullpos_grid_norms), intent(inout) :: result
  real(real64), allocatable :: gathered(:, :)
  real(real64) :: sum_value, low, high, value, inverse_count
  real(kind=jphook) :: handle
  integer :: p, fields, blocks, b, f, i, k, n, ierr
  status = 2; p = size(field, 1); fields = size(field, 2); blocks = size(field, 3)
  if (world /= 1 .or. verbosity > 0 .or. point_count < 1) return
  if (p < 1 .or. p > 4096 .or. fields < 1 .or. fields > 39 .or. blocks < 1) return
  if (size(active) /= blocks .or. size(global_point, 1) < p .or. size(global_point, 2) < blocks) return
  if (size(vertical_sets) /= fields .or. size(resolutions, 1) < 1 .or. size(resolutions, 2) < fields) return
  if (any(vertical_sets /= 1) .or. any(resolutions(1, 1:fields) /= 1)) return
  if (len(configuration) < 1) return
  if (configuration(1:1) /= 'P' .and. configuration(1:1) /= 'S') return
  if (any(active < 1) .or. any(active > p)) return
  if (sum(int(active, int64)) /= point_count) return
  do b = 1, blocks
  do i = 1, active(b)
    k = global_point(i, b)
    if (k < 1 .or. k > point_count) return
  end do
  end do
  if (8_int64*point_count*fields > budget) return
  if (hook_enabled) call dr_hook('FPGPNORM', 0, handle)
  allocate (gathered(point_count, fields), stat=ierr)
  if (ierr /= 0) then
    status = 1; goto900
  end if
  do f = 1, fields
  do b = 1, blocks
  do i = 1, active(b)
    gathered(global_point(i, b), f) = field(i, f, b)
  end do
  end do
  end do
  do f = 1, fields
    sum_value = 0.0_real64; low = huge(0.0_real64); high = -huge(0.0_real64); n = 0
    do i = 1, point_count
      value = gathered(i, f)
      if (value == huge(0.0_real64)) cycle
      sum_value = sum_value + value
      low = source_minimum(low, value); high = source_maximum(high, value)
      n = n + 1
    end do
    if (n == 0) then
      deallocate (gathered); status = 2; goto900
    end if
    inverse_count = 1.0_real64/real(n, real64)
    sum_value = sum_value*inverse_count
    result%values(1, f) = sum_value; result%values(2, f) = low; result%values(3, f) = high
    if (.not. (abs(sum_value) >= epsilon(1.0_real64))) sum_value = 0.0_real64
    if (.not. (abs(low) >= epsilon(1.0_real64))) low = 0.0_real64
    if (.not. (abs(high) >= epsilon(1.0_real64))) high = 0.0_real64
    result%display(1, f) = sum_value; result%display(2, f) = low; result%display(3, f) = high
  end do
  result%count = fields
  deallocate (gathered)
  status = 0
900 if (hook_enabled) call dr_hook('FPGPNORM', 1, handle)
  end function
end module
