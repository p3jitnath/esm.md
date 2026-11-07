module srfsn_webal_mod
  use iso_fortran_env, only: int32,real64
  implicit none
  private
  public :: trisolver
  interface
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Solve a snow heat column with the operation order of snow_trisolver.S.
  !!
  !! KSNLAC is the active layer count, from one to 4096. ZA, ZB and ZC are
  !! lower, central and upper matrix coefficients; ZF is the heat input.
  !! Each assumed-shape vector keeps its own stride. Only active ZTSTAR cells change.
  !! The caller supplies finite coefficients and nonzero finite elimination pivots.
  subroutine trisolver(ksnlac,za,zb,zc,zf,ztstar)
    integer(int32), intent(in) :: ksnlac
    real(real64), intent(in) :: za(:),zb(:),zc(:),zf(:)
    real(real64), intent(inout) :: ztstar(:)
    real(real64) :: gamma(4096),pivot,returned,coefficient,temporary,ratio
    integer(int32) :: layer
    if (ksnlac<1 .or. ksnlac>4096) call reject_contract()
    if (min(size(za),size(zb),size(zf),size(ztstar))<ksnlac) call reject_contract()
    if (size(zc)<ksnlac-1) call reject_contract()
    pivot=zb(1)
    returned=zf(1)/pivot
    ztstar(1)=returned
    do layer=2,ksnlac
      ratio=zc(layer-1)/pivot
      gamma(layer)=ratio
      coefficient=za(layer)
      temporary=coefficient*ratio
      pivot=zb(layer)-temporary
      temporary=coefficient*returned
      returned=zf(layer)-temporary
      returned=returned/pivot
      ztstar(layer)=returned
    end do
    do layer=ksnlac-1,1,-1
      temporary=gamma(layer+1)*returned
      returned=ztstar(layer)-temporary
      ztstar(layer)=returned
    end do
  end subroutine trisolver
end module srfsn_webal_mod
