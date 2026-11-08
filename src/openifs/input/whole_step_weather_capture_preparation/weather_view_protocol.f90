!> Export readonly primitive array views without reading numerical payloads.
!! The observer copies no weather field and owns no model state.
module forecast_weather_view_protocol
  use iso_c_binding
  implicit none
  private
  public :: weather_view_callback, observe_weather_primitive, observe_absent_weather_view
  abstract interface
   subroutine weather_view_callback(name,name_bytes,type_code,kind_bytes,rank,lower,upper,base,elements,presence,role,status)bind(C)
      import c_char, c_int, c_int64_t, c_ptr
      character(c_char), intent(in) :: name(*)
      integer(c_int), value :: name_bytes, type_code, kind_bytes, rank, presence, role
      integer(c_int64_t), intent(in) :: lower(*), upper(*)
      type(c_ptr), value :: base
      integer(c_int64_t), value :: elements
      integer(c_int), intent(out) :: status
    end subroutine
  end interface
contains
  !> Describe one primitive scalar or complete contiguous array.
  !! NAME is its semantic name, not an address. TYPE_CODE is integer1,
  !! real2, logical3 or character4. KIND_BYTES is the element size in bytes.
  !! LOWER and UPPER retain the actual caller bounds. ROLE1 denotes storage,
  !! ROLE2 a borrowed alias and ROLE3 scientific control metadata.
  !! A callback may retain the address only while the stopped TARGET is live.
  !! It must not write through BASE. This routine does not read VALUE.
  subroutine observe_weather_primitive(name, type_code, kind_bytes, lower, upper, value, role, observe, status)
    character(*), intent(in) :: name
    integer(c_int), intent(in) :: type_code, kind_bytes, role
    integer(c_int64_t), intent(in) :: lower(:), upper(:)
    type(*), target, intent(in) :: value(..)
    procedure(weather_view_callback) :: observe
    integer(c_int), intent(out) :: status
    integer(c_int64_t) :: lo(7), hi(7), elements, extent
    integer :: i, r
    type(c_ptr) :: base
    status = 2
    r = rank(value)
    if (r < 0 .or. r > 7 .or. size(lower) /= r .or. size(upper) /= r) return
    if (len(name) < 1 .or. len(name) > 512 .or. kind_bytes < 1) return
    if (.not. is_contiguous(value)) return
    lo = 0; hi = -1; elements = 1
    do i = 1, r
      lo(i) = lower(i); hi(i) = upper(i)
      if (hi(i) < lo(i) - 1) return
      extent = hi(i) - lo(i) + 1
      if (extent > 0) then
        if (elements > huge(elements)/extent) return
      end if
      elements = elements*extent
    end do
    base = c_null_ptr
    if (elements > 0) base = c_loc(value)
    call observe(name, int(len(name), c_int), type_code, kind_bytes, int(r, c_int), lo, hi, base, elements, 1_c_int, role, status)
  end subroutine
  !> Record a source-qualified absent owner without reading unused bounds.
  subroutine observe_absent_weather_view(name, rank, role, observe, status)
    character(*), intent(in) :: name
    integer(c_int), intent(in) :: rank, role
    procedure(weather_view_callback) :: observe
    integer(c_int), intent(out) :: status
    integer(c_int64_t) :: lo(7), hi(7)
    lo = 0; hi = -1
    call observe(name, int(len(name), c_int), 0_c_int, 0_c_int, rank, lo, hi, c_null_ptr, 0_c_int64_t, 0_c_int, role, status)
  end subroutine
end module
