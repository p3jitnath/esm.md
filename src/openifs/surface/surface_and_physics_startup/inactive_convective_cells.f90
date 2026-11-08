!> Initialize the selected inactive cellular convection controls.
module forecast_inactive_convective_cells
  use iso_fortran_env, only: int32, int64, real64
  use yoe_cuconvca, only: tecuconvca
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_inactive_convective_cells
contains
  !> TEXT contains the source NAMCA group. ECMWF must be true and LR2D
  !! false. NIJH is the dimensionless source neighborhood count, set to4.
  !! Only the named scalars and three ten-character selectors change.
  integer(int32) function initialize_inactive_convective_cells(output, text, ecmwf, lr2d, nijh) result(status)
    type(tecuconvca), intent(inout) :: output
    character(*), intent(in) :: text
    logical, intent(in) :: ecmwf, lr2d
    integer(int32), intent(inout) :: nijh
    status = 2
    if (.not. ecmwf .or. lr2d) return
    status = require_empty_physics_group(text, 'NAMCA')
    if (status /= 0) return
    output%lcuconv_ca = .false.
    output%lca_advect = .true.
    nijh = 4
    output%rcadelx = 0.0_real64
    output%lca_global = .false.
    output%lca_smooth = .true.
    output%lca_rantrop = .false.
    output%lca_extract = .false.
    output%rca_seedprob = transfer(int(z'3FEFD70A40000000', int64), 0.0_real64)
    output%nfrcaseed = 1
    output%nlives = 10
    output%nfertyrs = 3
    output%lca_test = .false.
    output%lca_advtest = .false.
    output%ntestproc = 8
    output%ntestgp = 1
    output%ndxunreal = -1
    output%ndyunreal = 0
    output%nspinup = 1000
    output%ca_forc = 'CONV_TQ   '
    output%ca_wind = 'REAL      '
    output%ca_prob = 'WIND      '
    status = 0
  end function
end module
