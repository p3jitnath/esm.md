module selected_physics_controls_port
  !! Own the selected TEPHY defaults, namelist changes and derived counts.
  use, intrinsic :: iso_fortran_env, only: int32
  use yoephy, only: tephy
  use physics_control_defaults_port, only: default_selected_physics_controls
  use physics_control_namelist_port, only: apply_selected_physics_namelist
  implicit none
  private
  public :: initialize_selected_physics_controls
contains
  integer(int32) function initialize_selected_physics_controls(text, output, controls, counts) result(status)
    !! controls are dimensionless integer flags [LSLAG,LUVPOUT], each 0 or 1.
    !! counts returns [NNOGW,NEDRP,NFSD,NUVP,NAEROUT]. Every argument is a
    !! complete disjoint native owner. Refusals leave output and counts unchanged.
    !! The caller supplies round-to-nearest, gradual underflow and FPCR zero.
    character(len=*), intent(in) :: text
    type(tephy), intent(inout) :: output
    integer(int32), intent(in) :: controls(2)
    integer(int32), intent(inout) :: counts(5)
    type(tephy) :: staged
    integer(int32) :: staged_counts(5)
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (any(controls < 0_int32) .or. any(controls > 1_int32)) return
    staged = output
    status = default_selected_physics_controls(staged, controls(1))
    if (status /= 0_int32) return
    status = apply_selected_physics_namelist(text, staged)
    if (status /= 0_int32) return
    if (.not. staged%lephys) then
      staged%lagphy = .false.; staged%lslphy = .false.; staged%lepcld = .false.
    end if
    if (controls(1) == 0_int32) staged%lslphy = .false.
    if (.not. staged%lagphy) staged%leradimpl = .false.
    staged%leocla = .false.
    staged_counts(1) = merge(2_int32, 0_int32, staged%legwwms)
    staged_counts(2) = merge(2_int32, 0_int32, staged%ldiagturb_ec)
    staged_counts(3) = merge(1_int32, 0_int32, staged%lrad_cloud_inhomog)
    staged_counts(4) = controls(2)
    staged_counts(5) = 0_int32
    output = staged; counts = staged_counts
    status = 0_int32
  end function
end module selected_physics_controls_port
