module physics_control_defaults_port
  !! Set the selected named TEPHY defaults without a model-global lookup.
  use, intrinsic :: iso_fortran_env, only: int32,int64,real64
  use yoephy, only: tephy
  implicit none
  private
  public :: default_selected_physics_controls
contains
  integer(int32) function default_selected_physics_controls(output,lslag) result(status)
    !! LSLAG is the upstream zero-or-one semi-Lagrangian control. Only the
    !! 97 source-assigned members change. Unwritten members stay unchanged.
    type(tephy), intent(inout) :: output
    integer(int32), intent(in) :: lslag
    status=2_int32
    if (lslag<0_int32.or.lslag>1_int32) return
    output%lephys=.true.
    output%lecond=.false.
    output%lecumf=.true.
    output%ledcld=.true.
    output%leevap=.true.
    output%legwdg=.true.
    output%legwwms=.true.
    output%leozoc=.true.
    output%leqngt=.true.
    output%leradi=.true.
    output%leradimpl=.true.
    output%lerads=.true.
    output%lesice=.true.
    output%lesurf=.true.
    output%levdif=.true.
    output%levdifsl=.false.
    output%lagphy=.true.
    output%lepcld=.true.
    output%leo3ch=.false.
    output%lo3ch_safe=.true.
    output%lo3ch_oldver=.false.
    output%lo3ch_bms=.false.
    output%lo3ch_hlo=.true.
    output%co3chem='H1.0'
    output%lneeonline=.true.
    output%lwetonline=.false.
    output%lbud23=.false.
    output%lpptiles=.false.
    output%lbudcycle=.false.
    output%lextratend=.false.
    output%lemethox=.true.
    output%lecurr=.false.
    output%lesurftraj=.false.
    output%lvdftrac=.true.
    output%lvdfnewtrac=.false.
    output%lmftrac=.true.
    output%lmfscav=.true.
    output%lerain=.false.
    output%lemwave=.false.
    output%legbrad=.false.
    output%leraingg=.false.
    output%lesmos=.false.
    output%lesmap=.false.
    output%leocwa=.true.
    output%leocco=.true.
    output%leocsa=.true.
    output%leocla=.true.
    output%levgen=.true.
    output%lessro=.true.
    output%leflake=.true.
    output%leocml=.false.
    output%leobc=.false.
    output%leobcmax=.true.
    output%reobcmax=transfer(int(z'4049000000000000',int64),0.0_real64)
    output%leobcice=.false.
    output%leoclake=.false.
    output%leolakesst=.true.
    output%locmltke=.false.
    output%leclipqt0=.false.
    output%leclipcldt0=.false.
    output%lductdia=.false.
    output%ldiagturb_ec=.false.
    output%ldiagturbgrad_ec=.false.
    output%lslphy=lslag==1_int32
    output%lesn09=.true.
    output%lelaiv=.true.
    output%lectessel=.true.
    output%leags=.false.
    output%lefarquhar=.true.
    output%leoptsurf=.false.
    output%lec4map=.true.
    output%leairco2coup=.false.
    output%lelight=.false.
    output%lvextrdynacc=.false.
    output%rthrfrti=transfer(int(z'0000000000000000',int64),0.0_real64)
    output%rcimin=transfer(int(z'bff0000000000000',int64),0.0_real64)
    output%rlaiint=transfer(int(z'0000000000000000',int64),0.0_real64)
    output%npraccl=21600_int32
    output%nlimode=6_int32
    output%lesnml=.false.
    output%leurban=.false.
    output%nsnmlws=0_int32
    output%lbfasco2=.false.
    output%nco2climyy1=0_int32
    output%nco2climyy2=0_int32
    output%nco2climn1=0_int32
    output%nco2climn2=0_int32
    output%nco2climfrq=0_int32
    output%nalbedoscheme=2_int32
    output%nemissscheme=0_int32
    output%ralfminpsn=transfer(int(z'3fea3d70a3d70a3d',int64),0.0_real64)
    output%rnorthml=transfer(int(z'4044000000000000',int64),0.0_real64)
    output%rsouthml=transfer(int(z'c044000000000000',int64),0.0_real64)
    output%rwestml=transfer(int(z'0000000000000000',int64),0.0_real64)
    output%reastml=transfer(int(z'4076800000000000',int64),0.0_real64)
    output%invml=.false.
    output%lrad_cloud_inhomog=.false.
    status=0_int32
  end function
end module physics_control_defaults_port
