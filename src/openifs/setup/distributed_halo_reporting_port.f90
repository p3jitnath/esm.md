!> Write the frozen main interpolation extent through public Fortran I/O.
module forecast_interpolation_reporting
  use iso_fortran_env,only:int32
  use forecast_interpolation_state_types,only:native_interpolation_state
  implicit none
  private
  public :: write_distributed_halo_status
contains
  !> Write CVER and the padded/unpadded point counts with the source format.
  !! STATE and UNIT are read-only; UNIT is an int32 Fortran output unit.
  !! The exact A2/I7/I7 record and its newline are owned by the language
  !! runtime. Return 0 reports successful completion and 1 an I/O error.
  !! Natural floating-point and errno effects remain visible. No owner is
  !! allocated or released, and no original reporting routine is called.
  integer(int32) function write_distributed_halo_status(state,unit) result(status)
    type(native_interpolation_state),intent(in) :: state
    integer(int32),intent(in) :: unit
    integer :: io_status
    write(unit,'(" YDSL%CVER=",A2," YDSL%NASLB1=",I7," YDSL%NASLB1_TRUE=",I7)',iostat=io_status) &
      state%cver,state%naslb1,state%naslb1_true
    status=0_int32
    if(io_status/=0)status=1_int32
  end function
end module forecast_interpolation_reporting
