!> Describe a borrowed named radiation field without owning a second payload.
module forecast_radiation_namespace_views
  use iso_c_binding, only: c_ptr, c_null_ptr, c_int32_t, c_int64_t
  implicit none
  private
  public :: native_radiation_namespace_field
!> ADDRESS borrows the actual initialized canonical owner. Bounds are elements.
!! The caller retains that TARGET owner; this view owns no allocation.
  type, bind(C) :: native_radiation_namespace_field
    type(c_ptr) :: address = c_null_ptr
    integer(c_int64_t) :: bytes = 0, lower(4) = 0, upper(4) = 0
    integer(c_int32_t) :: rank = 0, element_bytes = 0, type_code = 0
  end type
end module
