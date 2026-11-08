!> Compose operational TEPHY defaults,live namelist and wave consistency.
module forecast_operational_physics_controls
  use iso_fortran_env, only: int32
  use yoephy, only: tephy
  use physics_control_defaults_port, only: default_selected_physics_controls
  use forecast_operational_physics_namelist, only: apply_operational_physics_namelist
  implicit none
  private
  public :: initialize_operational_physics_controls
contains
!> Publish physics,wave controls and five field counts after all checks pass.
!! TEXT is read-only bounded ASCII. OUTPUT is INOUT canonical TEPHY.
!! CONTROLS is read-only INT32(2)=[LSLAG,LUVPOUT],each0or1. COUNTS is INOUT
!! INT32(5)=[NNOGW,NEDRP,NFSD,NUVP,NAEROUT]. WAVES is INOUT INT32(8),ordered
!! LWCOU,LWCOU2W,LWCUR,LWCOURNW,LWCOUHMF,LWSTOKES,LWFLUX,NSTPW.
!! Flags,counts and wave update intervals are dimensionless. The caller
!! establishes global hydrostatic ECMWF configuration1 and the qualified
!! arithmetic mode. Every argument is a complete disjoint native object.
!! Status2 leaves all outputs unchanged;status0 publishes the complete staged
!! source stores while preserving all source-unwritten TEPHY fields.
  integer(int32) function initialize_operational_physics_controls(text, output, controls, counts, waves) result(status)
    character(len=*), intent(in) :: text
    type(tephy), intent(inout) :: output
    integer(int32), intent(in) :: controls(2)
    integer(int32), intent(inout) :: counts(5), waves(8)
    type(tephy) :: staged
    integer(int32) :: staged_counts(5), staged_waves(8)
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (any(controls < 0_int32) .or. any(controls > 1_int32)) return
    staged = output
    status = default_selected_physics_controls(staged, controls(1))
    if (status /= 0) return
    staged_waves = 0_int32
    staged_waves(8) = 2_int32
    status = apply_operational_physics_namelist(text, staged, staged_waves)
    if (status /= 0) return
    status = 2_int32
    if (.not. staged%lephys .or. .not. staged%lepcld) return
    if (staged_waves(8) < 1 .or. staged_waves(8) > 2) return
    if (.not. staged%lephys) then
      staged%lagphy = .false.
      staged%lslphy = .false.
      staged%lepcld = .false.
    end if
    if (controls(1) == 0_int32) staged%lslphy = .false.
    if (.not. staged%lagphy) staged%leradimpl = .false.
    staged%lecond = .false.
    if (staged_waves(1) == 1_int32 .and. staged_waves(2) == 1_int32) then
      if (staged%leocwa .and. staged%leocla) staged_waves(6) = 1_int32
    else
      staged_waves(5) = 0_int32
    end if
    if (staged_waves(6) == 0_int32) staged%leocla = .false.
    staged_counts(1) = merge(2_int32, 0_int32, staged%legwwms)
    staged_counts(2) = merge(2_int32, 0_int32, staged%ldiagturb_ec)
    staged_counts(3) = merge(1_int32, 0_int32, staged%lrad_cloud_inhomog)
    staged_counts(4) = controls(2)
    staged_counts(5) = 0_int32
    output = staged
    waves = staged_waves
    counts = staged_counts
    status = 0_int32
  end function
end module forecast_operational_physics_controls
