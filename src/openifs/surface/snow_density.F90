module srfsn_rsn_mod
  use iso_fortran_env, only: int32,int64,real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_is_nan
  use yos_soil, only: tsoil
  use yos_cst, only: tcst
  implicit none
  private
  public :: srfsn_rsn
  interface
    function selected_power(base,exponent) bind(c,name="pow") result(value)
      import c_double
      real(c_double), value :: base,exponent
      real(c_double) :: value
    end function selected_power
    function selected_exponential(argument) bind(c,name="exp") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function selected_exponential
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Update snow density in the ordered stages of snow_density.S.
  !!
  !! Density uses kg m^-3; snow and water masses use kg m^-2; PTMST uses seconds.
  !! Temperatures use kelvin and winds use m s^-1. Only active PRSN cells change.
  !! The supplied PDHTSS diagnostic is deliberately unchanged.
  subroutine srfsn_rsn(kidia,kfdia,klon,klevsn,ptmst,llnosnow,prsnm1m,pssnm1m,ptsnm1m,pwsnm1m,pwsn,psnowf,pusrf,pvsrf,ptsrf,ydsoil,ydcst,prsn,pdhtss)
    integer(int32), intent(in) :: kidia,kfdia,klon,klevsn
    real(real64), intent(in) :: ptmst,prsnm1m(:,:),pssnm1m(:,:),ptsnm1m(:,:),pwsnm1m(:,:),pwsn(:,:),psnowf(:),pusrf(:),pvsrf(:),ptsrf(:)
    logical(int32), intent(in) :: llnosnow(:)
    type(tsoil), intent(in) :: ydsoil
    type(tcst), intent(in) :: ydcst
    real(real64), intent(inout) :: prsn(:,:),pdhtss(:,:,:)
    real(real64), parameter :: threshold=transfer(int(z'3d06849b86a12b9c',int64),0.0_real64)
    real(real64) :: inverse_step,wind_square,quarter_wind,wind_base,fresh_density,fresh_mass,top_density,above,wind_integral
    real(real64) :: old_density,mass,working,gamma,depth,overburden,metamorphism,water_rate,wind_rate,temporary,term,value,positive_gamma
    integer(int32) :: column,layer
    if (klon<1 .or. klon>4096 .or. klevsn<1 .or. klevsn>512 .or. kidia<1 .or. kfdia>klon) call reject_contract()
    if (min(size(llnosnow),size(prsnm1m,1),size(pssnm1m,1),size(ptsnm1m,1),size(pwsnm1m,1),size(pwsn,1),size(psnowf),size(pusrf),size(pvsrf),size(ptsrf),size(prsn,1))<klon) call reject_contract()
    if (min(size(prsnm1m,2),size(pssnm1m,2),size(ptsnm1m,2),size(pwsnm1m,2),size(pwsn,2),size(prsn,2))<klevsn) call reject_contract()
    inverse_step=1.0_real64/ptmst
    do column=kidia,kfdia
      if (llnosnow(column)) then
        do layer=1,klevsn
          prsn(column,layer)=ydsoil%rhominsn
        end do
        cycle
      end if
      if (.not.allocated(ydsoil%rsndtdestc_ml)) call reject_contract()
      if (lbound(ydsoil%rsndtdestc_ml,1)>1 .or. ubound(ydsoil%rsndtdestc_ml,1)<klevsn) call reject_contract()
      wind_square=pusrf(column)*pusrf(column)
      temporary=pvsrf(column)*pvsrf(column)
      wind_square=wind_square+temporary
      quarter_wind=selected_power(wind_square,0.25_real64)
      value=sqrt(wind_square)
      temporary=-ydsoil%rsndbw
      value=temporary*value
      value=selected_exponential(value)
      value=maximum(value,threshold)
      value=ydsoil%rsndaw*value
      wind_base=1.0_real64-value
      value=ptsrf(column)-ydcst%rtt
      value=ydsoil%rhominsnb*value
      value=ydsoil%rhominsna+value
      temporary=ydsoil%rhominsnc*quarter_wind
      value=value+temporary
      fresh_density=maximum(value,ydsoil%rhominsnd)
      fresh_mass=ptmst*psnowf(column)
      temporary=pssnm1m(column,1)/prsnm1m(column,1)
      term=fresh_mass/fresh_density
      term=term+temporary
      term=maximum(term,threshold)
      value=pssnm1m(column,1)+fresh_mass
      top_density=value/term
      above=0.0_real64
      wind_integral=0.0_real64
      do layer=1,klevsn
        old_density=prsnm1m(column,layer)
        mass=pssnm1m(column,layer)
        working=old_density
        if (layer==1) working=top_density
        value=old_density-ydsoil%rhominsnd
        value=value/ydsoil%rsndmob
        value=maximum(0.0_real64,value)
        value=1.0_real64-value
        value=ydsoil%rsndamob*value
        gamma=wind_base+value
        temporary=maximum(threshold,old_density)
        depth=mass/temporary
        if (mass>threshold) then
          value=ydcst%rtt-ptsnm1m(column,layer)
          value=ydsoil%rsndtoverb*value
          term=ydsoil%rsndtoverc*old_density
          value=value+term
          value=selected_exponential(value)
          value=ydsoil%rsndtovera*value
          temporary=0.5_real64*mass
          temporary=above+temporary
          temporary=temporary*ydcst%rg
          overburden=temporary/value
          value=ydcst%rtt-ptsnm1m(column,layer)
          temporary=-ydsoil%rsndtdestb
          value=temporary*value
          temporary=old_density-ydsoil%rsndtdestroi
          temporary=maximum(0.0_real64,temporary)
          temporary=ydsoil%rsndtdestc_ml(layer)*temporary
          value=value-temporary
          value=selected_exponential(value)
          metamorphism=ydsoil%rsndtdesta*value
          value=pwsn(column,layer)-pwsnm1m(column,layer)
          value=maximum(0.0_real64,value)
          value=inverse_step*value
          temporary=maximum(threshold,mass)
          water_rate=value/temporary
          positive_gamma=maximum(0.0_real64,gamma)
          temporary=ydsoil%rsndbtauw-gamma
          value=depth*temporary
          wind_integral=wind_integral+value
          value=-ydsoil%rsndatauw
          value=value*wind_integral
          value=selected_exponential(value)
          value=maximum(value,threshold)
          value=positive_gamma*value
          value=maximum(value,threshold)
          value=172800.0_real64/value
          temporary=ydsoil%rsndwcompmax-old_density
          value=temporary/value
          wind_rate=maximum(0.0_real64,value)
          value=overburden+metamorphism
          value=value+water_rate
          value=working*value
          value=value*ptmst
          working=working+value
          value=wind_rate*ptmst
          working=working+value
          working=minimum(500.0_real64,working)
          working=maximum(ydsoil%rhominsnd,working)
          above=above+mass
        end if
        prsn(column,layer)=maximum(ydsoil%rhominsnd,working)
      end do
    end do
  end subroutine srfsn_rsn
  !> Preserve the assembly minimum and maximum at signed zero.
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
end module srfsn_rsn_mod
