module physics_configuration_state_port
  !! Own the named configuration records used by the selected physics setup.
  !! Canonical data-only type declarations retain the type identities already
  !! used by the native cloud and surface ports. No original global or method
  !! supplies a value. Each state object and every array component belongs to
  !! its caller; this setup does not allocate or release those array owners.
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use yomphy, only: tphy
  use yommse, only: tmse
  use yomrcoef, only: trcoef
  use yoewcou, only: tewcou
  use yomarphy, only: tarphy
  use yomsimphl, only: tsimphl
  use yophnc, only: tphnc
  use yophlc, only: tphlc
  use yoelwrad, only: telwrad
  use yoephy, only: tephy
  use yoecldp, only: tecldp
  use yomncl, only: tncl
  use yoegwdwms, only: tegwdwms
  use yomsrftlad, only: tsrftlad
  use yoephli, only: tephli
  implicit none
  private
  public :: physics_configuration_state, single_column_configuration, shared_output_configuration
  type :: single_column_configuration
    !! Own the single-column request controls. Angles use radians and the
    !! radius uses metres, following the selected source. Time selections
    !! are integer model-step entries indexed from 0 through 240.
    logical :: lgscm
    integer(int32) :: nfrscm, nscm_space_s, nscm_add_sampl
    real(real64) :: gscm_lon1, gscm_lon2, gscm_lat1, gscm_lat2, gscm_radius
    integer(int32) :: nscmts(0:240)
  end type
  type :: shared_output_configuration
    !! Own output-selection flags and the global missing-value marker.
    logical :: ltracefp, lfppacking
    real(real64) :: rwidom
    logical :: locedelay
  end type
  type :: physics_configuration_state
    type(tphy) :: phy
    type(tmse) :: mse
    type(trcoef) :: radiation_coefficients
    type(tewcou) :: wave_coupling
    type(tarphy) :: arpege_physics
    type(tsimphl) :: simplified_physics
    type(tphnc) :: nonlinear_physics
    type(tphlc) :: linear_physics
    type(telwrad) :: longwave_radiation
    type(tephy) :: ecmwf_physics
    type(tecldp) :: cloud
    type(tncl) :: nonlinear_cloud
    type(tegwdwms) :: gravity_wave_linear
    type(tsrftlad) :: surface_tangent_linear
    type(tephli) :: linear_ecmwf
    type(single_column_configuration) :: single_column
    type(shared_output_configuration) :: shared_output
  end type
end module physics_configuration_state_port
