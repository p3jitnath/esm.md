!> Native source prefix for the global lateral-boundary setup.
module forecast_global_lateral_boundary_controls
  use iso_c_binding, only: c_int
  implicit none
  private
  public :: native_global_lateral_boundary_controls, initialize_global_lateral_boundary_controls
  !> Own exactly the22 source-assigned named members, all dimensionless.
  !! NLSGTS has its actual0:20 bound. The separate original LUNBC and tail
  !! remain outside this source prefix; source's local LUNBC aliases LSPTENC.
  type :: native_global_lateral_boundary_controls
    logical :: ltenc, lalltc, lrfirst
    integer(c_int) :: nbicou, nbicot, nbicpd, nbicvd, nbicnhx, nbicop, necripl
    logical :: lqcpl, lccpl
    integer(c_int) :: necotl, necoad
    logical :: le0cota, lereadini
    integer(c_int) :: n1lsg, nfrlsg, nlsgts(0:20)
    logical :: lrdlsg, lespcpl, lsptenc
  end type
contains
  !> Apply the complete global SUELBC_INIT prefix without a regional branch.
  integer(c_int) function initialize_global_lateral_boundary_controls(state, lelam) result(status)
    type(native_global_lateral_boundary_controls), intent(inout) :: state
    logical, intent(in) :: lelam
    status = 2
    if (transfer(lelam, 0_c_int) /= 0) return
    state%ltenc = .false.; state%lalltc = .false.; state%lrfirst = .true.
    state%nbicou = 0; state%nbicot = 0; state%nbicpd = 0; state%nbicvd = 0; state%nbicnhx = 0; state%nbicop = 0
    state%necripl = 1; state%lqcpl = .false.; state%lccpl = .false.; state%necotl = 0; state%necoad = 0
    state%le0cota = .false.; state%lereadini = .false.; state%n1lsg = 0; state%nfrlsg = 1
    state%nlsgts = 0; state%lrdlsg = .false.; state%lespcpl = .false.; state%lsptenc = .false.
    status = 0
  end function
end module forecast_global_lateral_boundary_controls
