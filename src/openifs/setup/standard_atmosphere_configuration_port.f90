!> Read the qualified empty atmosphere group and build owned model state.
!! The file is read as bytes. All numerical arrays are calculated by the
!! native atmosphere constructor, with no original model global storage.
module forecast_standard_atmosphere_configuration
  use iso_fortran_env, only: int32, int64, real64, iostat_end
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_all, ieee_get_flag, ieee_set_flag
  use forecast_standard_atmosphere, only: atmosphere_physical_inputs
  use forecast_standard_atmosphere_setup, only: standard_atmosphere_state, &
                                                atmosphere_vertical_coefficients, initialize_standard_atmosphere
  implicit none
  private
  public :: empty_standard_atmosphere_group, initialize_standard_atmosphere_from_file
  public :: atmosphere_file_setup_count
  integer(int64), save :: completed_calls = 0_int64
  interface
    function public_errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Accept the first line-leading NAMSTA group only when its body is empty.
  !! ASCII case is ignored. Spaces, tabs, CR, LF and exclamation comments
  !! are admitted. A missing group, assignment or truncated group returns2.
  integer(int32) function empty_standard_atmosphere_group(text) result(status)
    character(len=*), intent(in) :: text
    character(len=6), parameter :: name = "namsta"
    integer :: i, j, k, n, code
    logical :: matched
    status = 2
    n = len(text)
    i = 1
    do while (i <= n)
      code = iachar(text(i:i))
      if (space(code)) then
        i = i + 1
        cycle
      end if
      if (code == 38) then
        j = i + 1
        matched = .true.
        do k = 1, 6
          if (j > n) then
            return
          end if
          if (ior(iachar(text(j:j)), 32) /= iachar(name(k:k))) then
            matched = .false.
            exit
          end if
          j = j + 1
        end do
        if (matched) then
          if (j > n) return
          code = iachar(text(j:j))
          if (space(code) .or. code == 47 .or. code == 33) then
            i = j
            do while (i <= n)
              code = iachar(text(i:i))
              if (code == 47) then
                status = 0
                return
              end if
              if (code == 33) then
                do
                  i = i + 1
                  if (i > n) return
                  if (iachar(text(i:i)) == 10) exit
                end do
              else if (.not. space(code)) then
                return
              end if
              i = i + 1
            end do
            return
          end if
        end if
      end if
      do
        i = i + 1
        if (i > n) return
        if (iachar(text(i:i)) == 10) exit
      end do
      i = i + 1
    end do
  end function

  !> Read a nonempty file up to262144bytes and initialise the native state.
  !! physical and vertical are caller-owned live configuration inputs.
  !! ecmwf is0 or1. The default extrapolation height is100m or150m.
  !! status0 succeeds and increments the completed-call counter.
  !! status121 reports the original entry's fatal outcome to the new caller.
  !! The caller must handle that status before using the state.
  subroutine initialize_standard_atmosphere_from_file(file_name, state, physical, vertical, ecmwf, status)
    character(len=*), intent(in) :: file_name
    type(standard_atmosphere_state), intent(inout) :: state
    type(atmosphere_physical_inputs), intent(in) :: physical
    type(atmosphere_vertical_coefficients), intent(in) :: vertical
    integer(int32), intent(in) :: ecmwf
    integer(int32), intent(out) :: status
    character(len=:), allocatable :: text
    character :: extra
    integer :: unit, io, close_status, allocation_status, extra_status
    integer(int64) :: byte_count
    logical :: incoming_flags(size(ieee_all)), opened
    integer(c_int), pointer :: error_value
    integer(c_int) :: incoming_error
    integer(int32) :: child_status
    real(real64) :: extrapolation_height
    status = 121
    if (ecmwf < 0 .or. ecmwf > 1) return
    if (len_trim(file_name) < 1 .or. index(file_name, achar(0)) /= 0) return
    call ieee_get_flag(ieee_all, incoming_flags)
    call c_f_pointer(public_errno_location(), error_value)
    incoming_error = error_value
    opened = .false.
    file_input: block
      inquire (file=trim(file_name), size=byte_count, iostat=io)
      if (io /= 0) exit file_input
      if (byte_count < 1_int64 .or. byte_count > 262144_int64) exit file_input
      allocate (character(len=int(byte_count)) :: text, stat=allocation_status)
      if (allocation_status /= 0) exit file_input
      open (newunit=unit, file=trim(file_name), access="stream", form="unformatted", &
            status="old", action="read", iostat=io)
      if (io /= 0) exit file_input
      opened = .true.
      read (unit, iostat=io) text
      if (io /= 0) exit file_input
      read (unit, iostat=extra_status) extra
      if (extra_status /= iostat_end) exit file_input
      close (unit, iostat=close_status)
      opened = .false.
      if (close_status /= 0) exit file_input
      child_status = empty_standard_atmosphere_group(text)
      deallocate (text)
      if (child_status /= 0) exit file_input
      ! File operations do not enter the declared numerical status interval.
      call ieee_set_flag(ieee_all, incoming_flags)
      error_value = 0_c_int
      extrapolation_height = 100.0_real64
      if (ecmwf == 1) extrapolation_height = 150.0_real64
      call initialize_standard_atmosphere(state, physical, vertical, ecmwf, extrapolation_height, child_status)
      if (child_status /= 0) return
      if (completed_calls == huge(completed_calls)) then
        completed_calls = not(huge(completed_calls))
      else
        completed_calls = completed_calls + 1_int64
      end if
      status = 0
      return
    end block file_input
    if (opened) close (unit, iostat=close_status)
    if (allocated(text)) deallocate (text)
    call ieee_set_flag(ieee_all, incoming_flags)
    error_value = incoming_error
  end subroutine

  !> Return the completed serial setup-call count as an unchanged64-bit word.
  integer(int64) function atmosphere_file_setup_count() result(count)
    count = completed_calls
  end function

  logical function space(code)
    integer, intent(in) :: code
    space = code == 32 .or. code == 9 .or. code == 10 .or. code == 13
  end function
end module forecast_standard_atmosphere_configuration
