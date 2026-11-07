module srfwl_mod
  use iso_fortran_env, only: int32,int64,real64
  use ieee_arithmetic, only: ieee_is_nan
  use yos_soil, only: tsoil
  use yos_veg, only: tveg
  implicit none
  private
  public :: srfwl
  interface
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Update canopy storage and throughfall in the order of canopy_water_interception.S.
  !!
  !! KIDIA:KFDIA selects active columns; KTILES is the surface-type count.
  !! PTMST uses seconds; storage uses kg m^-2; exchange and rain use kg m^-2 s^-1.
  !! Only the six returned owners change. PDHIIS may have zero size.
  subroutine srfwl(kidia,kfdia,ktiles,ptmst,pwlm1m,pcvl,pcvh,pwlmx,pfrti,pevapti,prsfc,prsfl,pevapsnw,pwl,pfwel1,ptsfc,ptsfl,peintti,ldland,ydsoil,ydveg,pdhiis)
    integer(int32), intent(in) :: kidia,kfdia,ktiles
    real(real64), intent(in) :: ptmst,pwlm1m(:),pcvl(:),pcvh(:),pwlmx(:),pfrti(:,:),pevapti(:,:),prsfc(:),prsfl(:),pevapsnw(:)
    logical(int32), intent(in) :: ldland(:)
    type(tsoil), intent(in) :: ydsoil
    type(tveg), intent(in) :: ydveg
    real(real64), intent(inout) :: pwl(:),pfwel1(:),ptsfc(:),ptsfl(:),peintti(:,:),pdhiis(:,:)
    integer(int32) :: column,tile
    real(real64) :: inverse_step,inverse_rain,old_water,limit,water,previous,flux,term,amount,value
    real(real64), parameter :: threshold=10.0_real64*tiny(1.0_real64)
    logical :: diagnostics
    if (ktiles<8 .or. ktiles>16 .or. kidia<1 .or. kfdia>4096) call reject_contract()
    if (min(size(pwlm1m),size(pcvl),size(pcvh),size(pwlmx),size(prsfc),size(prsfl),size(pevapsnw),size(ldland),size(pwl),size(pfwel1),size(ptsfc),size(ptsfl))<kfdia) call reject_contract()
    if (min(size(pfrti,1),size(pevapti,1),size(peintti,1))<kfdia) call reject_contract()
    if (min(size(pfrti,2),size(pevapti,2),size(peintti,2))<ktiles) call reject_contract()
    diagnostics=size(pdhiis)>0
    if (diagnostics) then
      if (size(pdhiis,1)<kfdia .or. size(pdhiis,2)<4) call reject_contract()
    end if
    inverse_step=1.0_real64/ptmst
    inverse_rain=1.0_real64/ydsoil%rpsfr
    do column=kidia,kfdia
      do tile=1,ktiles
        peintti(column,tile)=0.0_real64
      end do
      old_water=pwlm1m(column)
      if (ldland(column)) then
        limit=pwlmx(column)-threshold
        water=minimum(limit,old_water)
        water=maximum(water,0.0_real64)
        value=water-old_water
        value=value*inverse_step
        peintti(column,3)=0.0_real64+value
        if (.not.ydsoil%lewbsoilfix) water=old_water
        flux=pevapti(column,3)
        if (flux<0.0_real64) then
          previous=water
          term=ptmst*pfrti(column,3)
          term=term*flux
          water=previous+term
          water=maximum(water,0.0_real64)
          value=water-previous
          value=value*inverse_step
          peintti(column,3)=peintti(column,3)+value
        end if
        do tile=1,ktiles
          if (tile/=3 .and. tile/=4 .and. tile/=6 .and. tile/=7 .and. tile/=8 .and. tile/=10) cycle
          flux=pevapti(column,tile)
          if (tile==7) flux=flux-pevapsnw(column)
          flux=pfrti(column,tile)*flux
          if (flux<=0.0_real64) cycle
          previous=water
          amount=ptmst*flux
          term=limit-previous
          amount=minimum(term,amount)
          water=previous+amount
          value=water-previous
          value=value*inverse_step
          peintti(column,tile)=peintti(column,tile)+value
        end do
        value=water-old_water
        value=value*inverse_step
        pfwel1(column)=pfwel1(column)+value
        flux=prsfl(column)
        if (flux>threshold) then
          term=pcvl(column)+pcvh(column)
          amount=flux*term
          amount=amount*ydveg%rvinter
          amount=ptmst*amount
          term=limit-water
          amount=minimum(term,amount)
          water=water+amount
          amount=amount*inverse_step
          value=flux-amount
        else
          value=0.0_real64
        end if
        ptsfl(column)=value
        flux=prsfc(column)
        if (flux>threshold) then
          amount=flux*ydsoil%rpsfr
          term=pcvl(column)+pcvh(column)
          amount=amount*term
          amount=amount*ydveg%rvinter
          amount=ptmst*amount
          term=limit-water
          amount=minimum(term,amount)
          amount=amount*inverse_rain
          water=water+amount
          amount=amount*inverse_step
          value=flux-amount
        else
          value=0.0_real64
        end if
        ptsfc(column)=value
        pwl(column)=water
      else
        pwl(column)=0.0_real64
        pfwel1(column)=0.0_real64
        ptsfc(column)=prsfc(column)
        ptsfl(column)=prsfl(column)
      end if
      if (diagnostics) then
        pdhiis(column,1)=old_water
        pdhiis(column,2)=prsfl(column)-ptsfl(column)
        pdhiis(column,3)=prsfc(column)-ptsfc(column)
        value=peintti(column,3)+peintti(column,4)
        value=value+peintti(column,6)
        value=value+peintti(column,7)
        value=value+peintti(column,8)
        pdhiis(column,4)=value
      end if
    end do
  end subroutine srfwl
  !> Preserve the assembly minimum, including both signs of zero.
  pure function minimum(a,b) result(value)
    real(real64), intent(in) :: a,b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value=a
    else if (ieee_is_nan(b)) then
      value=b
    else if (a==0.0_real64 .and. b==0.0_real64) then
      value=transfer(ior(transfer(a,0_int64),transfer(b,0_int64)),value)
    else if (a<b) then
      value=a
    else
      value=b
    end if
  end function minimum
  !> Preserve the assembly maximum, including both signs of zero.
  pure function maximum(a,b) result(value)
    real(real64), intent(in) :: a,b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value=a
    else if (ieee_is_nan(b)) then
      value=b
    else if (a==0.0_real64 .and. b==0.0_real64) then
      value=transfer(iand(transfer(a,0_int64),transfer(b,0_int64)),value)
    else if (a>b) then
      value=a
    else
      value=b
    end if
  end function maximum
end module srfwl_mod
