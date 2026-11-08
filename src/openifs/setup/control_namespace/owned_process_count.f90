!> Replace the private serial NPROC symbol with one caller-owned native word.
module forecast_native_owned_process_count
  use iso_fortran_env, only: int32
  implicit none
  private
  public :: native_owned_process_count, initialize_owned_process_count
  type :: native_owned_process_count
    integer(int32) :: nproc = 0
  end type
contains
  !> Copy the actual successful Geometry process count into its sole namespace.
 !! LIVE_COUNT is readonly. Output0 is an unready preimage; only live1 is
 !! supported by this selected source entry. Status2 leaves output unchanged.
  integer(int32) function initialize_owned_process_count(live_count, output) result(status)
    integer(int32), intent(in) :: live_count
    type(native_owned_process_count), intent(inout) :: output
    status = 2
    if (live_count /= 1) return
    output%nproc = live_count
    status = 0
  end function
end module
