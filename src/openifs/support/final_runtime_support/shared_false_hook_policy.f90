!> One owned false hook word with three native readonly borrow names.
module forecast_shared_false_hook_policy
  use iso_c_binding, only: c_int
  implicit none
  private
  integer(c_int), target, save :: false_hook_word = 0_c_int
  public :: borrow_owned_shared_false_hook_policy, borrow_owned_height_wind_hook_policy, borrow_owned_yomhook_policy
contains
  !> Borrow the same four-byte zero word; the caller must not change its target.
 !! This is the native replacement for the canonical historical provider name.
  function borrow_owned_shared_false_hook_policy() result(word)
    integer(c_int), pointer :: word
    word => false_hook_word
  end function
  !> Borrow the height/wind spelling of the same readonly owned word.
  function borrow_owned_height_wind_hook_policy() result(word)
    integer(c_int), pointer :: word
    word => false_hook_word
  end function
  !> Borrow the historical YOMHOOK role without importing an original global.
  function borrow_owned_yomhook_policy() result(word)
    integer(c_int), pointer :: word
    word => false_hook_word
  end function
end module forecast_shared_false_hook_policy
