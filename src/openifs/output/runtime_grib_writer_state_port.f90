module runtime_grib_writer_state_port
  !! Own output-history metadata for the complete forecast lifetime.
  !! Codes identify fields. Step counts have no units.
  use, intrinsic :: iso_fortran_env, only: int32
  implicit none
  private
  public :: grib_writer_state,initialize_grib_writer_state,release_grib_writer_state
  public :: update_last_physics_output_steps,previous_grib_output_steps

  type :: grib_writer_state
    logical :: initialized=.false.,io_server=.false.
    integer(int32) :: output_type=0_int32
    integer(int32) :: previous_codes(5)=0_int32,last_output_steps(5)=0_int32
  end type grib_writer_state

contains

  function initialize_grib_writer_state(state,time_loop_ready,output_type) result(status)
    !! Initialize a fresh owner after the time-loop producer is ready.
    !! The selected synchronous route uses output_type one and no I/O server.
    type(grib_writer_state), intent(inout) :: state
    logical, intent(in) :: time_loop_ready
    integer(int32), intent(in) :: output_type
    integer(int32) :: status

    status=2_int32
    if(.not.time_loop_ready.or.output_type/=1) return
    if(state%initialized.or.state%io_server.or.state%output_type/=0) return
    if(any(state%previous_codes/=0).or.any(state%last_output_steps/=0)) return
    state%previous_codes=[201_int32,202_int32,49_int32,228226_int32,228227_int32]
    state%last_output_steps=0_int32
    state%io_server=.false.
    state%output_type=output_type
    state%initialized=.true.
    status=0_int32
  end function initialize_grib_writer_state

  function update_last_physics_output_steps(state,step,codes) result(status)
    !! Update the five source history slots after a completed physical write.
    !! step is 0:576. codes has at most 1639 entries in source field order.
    type(grib_writer_state), intent(inout) :: state
    integer(int32), intent(in) :: step,codes(:)
    integer(int32) :: status
    integer :: j,k

    status=2_int32
    if(.not.state%initialized.or.step<0.or.step>576.or.size(codes)>1639) return
    do j=1,size(codes)
      do k=1,5
        if(state%previous_codes(k)==codes(j)) state%last_output_steps(k)=step
      end do
    end do
    status=0_int32
  end function update_last_physics_output_steps

  function previous_grib_output_steps(state) result(previous)
    !! Return the code and step arrays consumed by the typed time encoder.
    type(grib_writer_state), intent(in) :: state
    integer(int32) :: previous(10)
    previous(:5)=state%previous_codes
    previous(6:)=state%last_output_steps
  end function previous_grib_output_steps

  subroutine release_grib_writer_state(state)
    !! Reset this owner after the last output reader.
    type(grib_writer_state), intent(out) :: state
    state%initialized=.false.
    state%io_server=.false.
    state%output_type=0_int32
    state%previous_codes=0_int32
    state%last_output_steps=0_int32
  end subroutine release_grib_writer_state
end module runtime_grib_writer_state_port
