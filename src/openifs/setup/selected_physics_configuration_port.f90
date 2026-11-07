module selected_physics_configuration_port
  !! Initialise the 17 selected physics records with native typed owners.
  use, intrinsic :: iso_fortran_env, only: int32
  use physics_configuration_state_port, only: physics_configuration_state
  use physics_configuration_defaults_port, only: apply_remaining_physics_configuration
  use physics_output_request_validation_port, only: physics_output_requests,parse_physics_output_requests
  use selected_physics_controls_port, only: initialize_selected_physics_controls
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_selected_physics_configuration
contains
  integer(int32) function initialize_selected_physics_configuration(text,state,controls,counts) result(status)
    !! text contains 1 to 262144 source bytes. controls and counts follow the
    !! selected controls interface. The state owns its records and array owners.
    !! Arguments must be complete and disjoint; existing allocations stay owned
    !! by state. Validation refusals change no state or count. The caller supplies
    !! round-to-nearest, gradual underflow and FPCR zero.
    character(len=*), intent(in) :: text
    type(physics_configuration_state), intent(inout) :: state
    integer(int32), intent(in) :: controls(2)
    integer(int32), intent(inout) :: counts(5)
    character(len=9), parameter :: empty_groups(8)=[character(len=9) :: &
      'NAMPHY','NAMDVISI','NAMARPHY','NAPHLC','NAMTRAJP','NAMSIMPHL','NAMRCOEF','NAMSCM']
    type(physics_output_requests) :: requests
    integer :: group
    status=2_int32
    if(len(text)<1.or.len(text)>262144) return
    if(any(controls<0_int32).or.any(controls>1_int32)) return
    do group=1,8
      status=require_empty_physics_group(text,trim(empty_groups(group)))
      if(status/=0_int32) return
    end do
    status=parse_physics_output_requests(text,requests)
    if(status/=0_int32) return
    status=initialize_selected_physics_controls(text,state%ecmwf_physics,controls,counts)
    if(status/=0_int32) return
    call apply_remaining_physics_configuration(state)
    status=0_int32
  end function
end module selected_physics_configuration_port
