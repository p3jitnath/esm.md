!> Native SURFRAD wrapper using the complete owned surface record.
module forecast_layer_private_surface_radiation
  use iso_fortran_env, only: int32, real64
  use yos_surf, only: tsurf
  use forecast_layer_private_radiation_controller, only: surfrad_ctl
  implicit none
  private
  public :: surfrad
contains
  !> Map eight named surface components into the complete native controller.
  !! Original36-argument order is retained, followed by native status.
  !! YDSURF and all inputs stay read-only. Albedos/emissivities are
  !! dimensionless; eight output owners preserve inactive rows and tails.
  !! Temperatures are kelvin, wind m/s, soil moisture m3/m3 and ice depth m.
  !! The caller owns every array and keeps outputs separate from inputs.
  !! The compiler owns descriptors. No handle lookup or registry is needed.
  subroutine surfrad(ydsurf,kdd,kmm,kmon,kseco,kidia,kfdia,klon,ktiles,ksw,klw,ldnh,palbf,palbicef,ptvh,palcoeff,pcurc,pcvh,pasn,pmu0,pts,pwnd,pws1,ksoty,pfrti,phlice,ptlice,palbd,palbp,palb,pspectralemiss,pemit,palbti,pccnl,pccno,lnemolimalb,status)
    type(tsurf), intent(in) :: ydsurf
    integer(int32), intent(in) :: kdd, kmm, kmon(:), kseco, kidia, kfdia, klon, ktiles, ksw, klw, ksoty(:)
    logical(int32), intent(in) :: ldnh(:), lnemolimalb
    real(real64),intent(in) :: palbf(:),palbicef(:),ptvh(:),palcoeff(:,:),pcurc(:),pcvh(:),pasn(:),pmu0(:),pts(:),pwnd(:),pws1(:),pfrti(:,:),phlice(:),ptlice(:)
  real(real64), intent(inout) :: palbd(:, :), palbp(:, :), palb(:), pspectralemiss(:, :), pemit(:), palbti(:, :), pccnl(:), pccno(:)
    integer(int32), intent(out) :: status
    call surfrad_ctl(kdd,kmm,kmon,kseco,kidia,kfdia,klon,ktiles,ksw,klw,ldnh,palbf,palbicef,ptvh,palcoeff,pcurc,pcvh,pasn,pmu0,pts,pwnd,pws1,ksoty,pfrti,phlice,ptlice,ydsurf%ycst,ydsurf%ylw,ydsurf%ysw,ydsurf%yrad,ydsurf%yrdi,ydsurf%ysoil,ydsurf%yflake,ydsurf%yurb,palbd,palbp,palb,pspectralemiss,pemit,palbti,pccnl,pccno,lnemolimalb,status)
  end subroutine
end module
