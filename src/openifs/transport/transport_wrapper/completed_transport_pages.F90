!> Release completed private transport pages through the public C service.
module forecast_completed_transport_pages
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_null_ptr, c_int, c_size_t, c_intptr_t, c_loc, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use md2asm_transport_work_storage, only: transport_work_storage
  implicit none
  private
  public :: discard_completed_transport_private_pages
  interface
    function pages_errno_location() bind(C, name="__errno_location") result(p)
      import c_ptr
      type(c_ptr) :: p
    end function
    function public_page_size() bind(C, name="getpagesize") result(bytes)
      import c_int
      integer(c_int) :: bytes
    end function
    function public_discard_pages(address, length, advice) bind(C, name="madvise") result(code)
      import c_ptr, c_size_t, c_int
      type(c_ptr), value :: address
      integer(c_size_t), value :: length
      integer(c_int), value :: advice
      integer(c_int) :: code
    end function
  end interface
contains
  !> Preserve the child return word while releasing only complete interior pages.
  !!
  !! owner is the canonical native retained-storage record. Its level_index
  !! and vertical_weights arrays correspond to the first two original scratch
  !! allocations;coordinates are never advised here. The caller has exclusive
  !! ownership,has completed every consumer and has ended all borrowed views.
  !! Future consumers must define the discarded private contents before use.
  !! This service must not be applied to a weather output or shared allocation.
  !!
  !! Each byte range keeps the page containing its first byte and the page
  !! containing its last byte. Linux public madvise with MADV_DONTNEED(4)
  !! supplies the target operating-system service;no target system-call number
  !! or handwritten machine instruction is embedded in the portable caller.
  !! Unsupported/overflowing ranges and unsuccessful advice are skipped,
  !! matching the source best-effort behavior. The returned int64 is exactly
  !! return_word. IEEE status and incoming errno are restored on every route.
  !! Optional discarded_bytes reports only successful advisory range lengths;
  !! it is metadata,not a promise that the operating system reclaimed a page.
  integer(int64) function discard_completed_transport_private_pages(return_word, owner, discarded_bytes) result(value)
    integer(int64), intent(in) :: return_word
    type(transport_work_storage), target, intent(inout) :: owner
    integer(int64), optional, intent(out) :: discarded_bytes
    type(ieee_status_type) :: saved_fp
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved_errno, page_word
    integer(int64) :: page, advised, bytes
    call ieee_get_status(saved_fp)
    call c_f_pointer(pages_errno_location(), ep); saved_errno = ep
    value = return_word; advised = 0_int64
    page_word = public_page_size(); page = int(page_word, int64)
    if (page > 0_int64) then
      if (iand(page, page - 1_int64) == 0_int64) then
        if (allocated(owner%level_index)) then
          if (size(owner%level_index, kind=int64) > 0_int64) then
            bytes = 4_int64*size(owner%level_index, kind=int64)
            call advise(c_loc(owner%level_index(1, 1, 1, 1)), bytes, page, advised)
          end if
        end if
        if (allocated(owner%vertical_weights)) then
          if (size(owner%vertical_weights, kind=int64) > 0_int64) then
            bytes = 8_int64*size(owner%vertical_weights, kind=int64)
            call advise(c_loc(owner%vertical_weights(1, 1, 1, 1)), bytes, page, advised)
          end if
        end if
      end if
    end if
    if (present(discarded_bytes)) discarded_bytes = advised
    ep = saved_errno
    call ieee_set_status(saved_fp)
  end function

  subroutine advise(address, bytes, page, total)
    type(c_ptr), intent(in) :: address
    integer(int64), intent(in) :: bytes, page
    integer(int64), intent(inout) :: total
    integer(c_intptr_t) :: base, first, last, ending, mask
    integer(c_int) :: code
    type(c_ptr) :: start
    base = transfer(address, base)
    if (base <= 0_c_intptr_t .or. bytes <= 0_int64) return
    if (bytes > int(huge(base), int64) - int(base, int64)) return
    ending = base + int(bytes, c_intptr_t)
    mask = int(page - 1_int64, c_intptr_t)
    first = iand(base, not(mask))
    if (first > huge(first) - int(page, c_intptr_t)) return
    first = first + int(page, c_intptr_t)
    last = iand(ending - 1_c_intptr_t, not(mask))
    if (last <= first) return
    start = transfer(first, c_null_ptr)
    code = public_discard_pages(start, int(last - first, c_size_t), 4_c_int)
    if (code == 0_c_int) total = total + int(last - first, int64)
  end subroutine
end module forecast_completed_transport_pages
