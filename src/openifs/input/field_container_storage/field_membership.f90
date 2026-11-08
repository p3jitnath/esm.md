!> Form the ascending list of fields selected by integer maps.
module forecast_field_membership
  use iso_fortran_env, only: int32
  implicit none
contains
  integer(int32) function initialize_field_membership(map, field_count, on, active, field_ids, used) result(status)
    integer(int32), intent(in) :: map(:), field_count
    integer(int32), intent(inout) :: on(:), active(:), field_ids(:), used
    integer :: i, k
    status = 2
    if (field_count < 0 .or. field_count > 4200) return
    if (min(size(map), size(on), size(active)) < field_count) return
    if (any(on(1:field_count) < 0) .or. any(on(1:field_count) > 1)) return
    if (any(active(1:field_count) < 0) .or. any(active(1:field_count) > 1)) return
    if (size(field_ids) < count(on(1:field_count) /= 0 .or. map(1:field_count) /= 0)) return
    k = 0
    do i = 1, field_count
      if (map(i) /= 0) then
        on(i) = 1
        if (map(i) /= -1) active(i) = 1
      end if
      if (on(i) /= 0) then
        k = k + 1
        field_ids(k) = i
      end if
    end do
    used = k
    status = 0
  end function
end module
