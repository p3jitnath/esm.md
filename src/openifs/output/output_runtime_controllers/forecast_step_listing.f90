!> Emit the original fixed-width forecast progress line without formatted I/O.
!! The file descriptor belongs to the caller. configuration contains exactly nine bytes.
module forecast_step_listing
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_char, c_loc, c_size_t
  use forecast_output_stream_services, only: write_output_bytes
  implicit none
  private
  public :: write_forecast_step_listing
contains
  !> Preserve inputs and errno; return 0 on success, 1 on write failure or 2 on refusal.
  integer(int32) function write_forecast_step_listing(fd, step, configuration) result(status)
    integer(int32), intent(in) :: fd, step
    character(9), intent(in) :: configuration
    character(kind=c_char, len=33), target :: line
    integer :: value, position, digit
    status = 2
    if (fd < 0 .or. step < 0 .or. step > 24) return
    line = ' NSTEP ='//'      '//' STEPO   '//configuration//achar(10)
    value = step
    position = 14
    do
      digit = mod(value, 10)
      line(position:position) = achar(48 + digit)
      value = value/10
      position = position - 1
      if (value == 0) exit
    end do
    status = write_output_bytes(fd, c_loc(line), 33_c_size_t, .true.)
  end function
end module forecast_step_listing
