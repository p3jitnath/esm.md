!> Obtain a borrowed array element address through compiler-owned descriptors.
!! Ordinary assumed-shape TARGET inputs retain their actual strides. Optional
!! source indices use zero for the first element of that dimension, as in the
!! original helper; explicit origins describe nonunit caller lower bounds.
!! Status0 returns a valid selected address or an unconsumed empty null view;
!! status2 refuses a selected index outside the actual owner. No payload changes.
module forecast_physics_layer_first_address
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_loc, c_null_ptr
  implicit none
  private
  public :: first_array_address
  interface first_array_address
    module procedure first_real1, first_real2, first_real3, first_real4, first_integer1, first_logical1
  end interface
contains
  function first_real1(source, status) result(address)
    real(real64), target, intent(in) :: source(:)
    integer(int32), intent(out) :: status
    type(c_ptr) :: address
    address = c_null_ptr; status = 0_int32
    if (size(source) == 0) return
    address = c_loc(source(1)); status = 0_int32
  end function first_real1
  function first_real2(source, status, second, origin2) result(address)
    real(real64), target, intent(in) :: source(:, :)
    integer(int32), intent(out) :: status
    type(c_ptr) :: address
    integer(int32), optional, intent(in) :: second, origin2
    integer(int64) :: j, lower2
    address = c_null_ptr; status = 0_int32
    if (size(source) == 0) return
    j = 1; lower2 = 1
    if (present(origin2)) lower2 = origin2
    if (present(second)) then
      if (second /= 0) j = second - lower2 + 1
    end if
    status = 2_int32
    if (j < 1 .or. j > size(source, 2)) return
    address = c_loc(source(1, j)); status = 0_int32
  end function first_real2
  function first_real3(source, status, second, origin2, third, origin3) result(address)
    real(real64), target, intent(in) :: source(:, :, :)
    integer(int32), intent(out) :: status
    type(c_ptr) :: address
    integer(int32), optional, intent(in) :: second, origin2
    integer(int64) :: j, lower2
    integer(int32), optional, intent(in) :: third, origin3
    integer(int64) :: k, lower3
    address = c_null_ptr; status = 0_int32
    if (size(source) == 0) return
    j = 1; lower2 = 1
    if (present(origin2)) lower2 = origin2
    if (present(second)) then
      if (second /= 0) j = second - lower2 + 1
    end if
    status = 2_int32
    if (j < 1 .or. j > size(source, 2)) return
    k = 1; lower3 = 1
    if (present(origin3)) lower3 = origin3
    if (present(third)) then
      if (third /= 0) k = third - lower3 + 1
    end if
    status = 2_int32
    if (k < 1 .or. k > size(source, 3)) return
    address = c_loc(source(1, j, k)); status = 0_int32
  end function first_real3
  function first_real4(source, status, second, origin2, third, origin3) result(address)
    real(real64), target, intent(in) :: source(:, :, :, :)
    integer(int32), intent(out) :: status
    type(c_ptr) :: address
    integer(int32), optional, intent(in) :: second, origin2
    integer(int64) :: j, lower2
    integer(int32), optional, intent(in) :: third, origin3
    integer(int64) :: k, lower3
    address = c_null_ptr; status = 0_int32
    if (size(source) == 0) return
    j = 1; lower2 = 1
    if (present(origin2)) lower2 = origin2
    if (present(second)) then
      if (second /= 0) j = second - lower2 + 1
    end if
    status = 2_int32
    if (j < 1 .or. j > size(source, 2)) return
    k = 1; lower3 = 1
    if (present(origin3)) lower3 = origin3
    if (present(third)) then
      if (third /= 0) k = third - lower3 + 1
    end if
    status = 2_int32
    if (k < 1 .or. k > size(source, 3)) return
    address = c_loc(source(1, j, k, 1)); status = 0_int32
  end function first_real4
  function first_integer1(source, status) result(address)
    integer(int32), target, intent(in) :: source(:)
    integer(int32), intent(out) :: status
    type(c_ptr) :: address
    address = c_null_ptr; status = 0_int32
    if (size(source) == 0) return
    address = c_loc(source(1))
  end function first_integer1
  function first_logical1(source, status) result(address)
    logical, target, intent(in) :: source(:)
    integer(int32), intent(out) :: status
    type(c_ptr) :: address
    address = c_null_ptr; status = 0_int32
    if (size(source) == 0) return
    address = c_loc(source(1))
  end function first_logical1
end module forecast_physics_layer_first_address
