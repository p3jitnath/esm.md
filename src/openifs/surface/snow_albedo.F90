module srfsn_asn_mod
  use iso_fortran_env, only: int32,int64,real64
  use iso_c_binding, only: c_double,c_int
  use ieee_arithmetic, only: ieee_is_nan
  use yos_soil, only: tsoil
  use yos_cst, only: tcst
  implicit none
  private
  public :: srfsn_asn
  interface
    function selected_exponential(argument) bind(c,name="exp") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function selected_exponential
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Apply snow ageing and fresh-snow mixing in the order of snow_albedo.S.
  !!
  !! PTMST uses seconds; PSNOWF is snowfall in kg m^-2 s^-1; albedo is dimensionless.
  !! KIDIA:KFDIA selects active columns. PTSNM1M is unused and is never accessed.
  !! Ageing constants are computed only when their branch is first needed.
  subroutine srfsn_asn(kidia,kfdia,klon,ptmst,llnosnow,pasnm1m,pmsn,ptsnm1m,psnowf,ydsoil,ydcst,pasn)
    integer(int32), intent(in) :: kidia,kfdia,klon
    real(real64), intent(in) :: ptmst,pasnm1m(:),pmsn(:),ptsnm1m(:,:),psnowf(:)
    logical(int32), intent(in) :: llnosnow(:)
    type(tsoil), intent(in) :: ydsoil
    type(tcst), intent(in) :: ydcst
    real(real64), intent(inout) :: pasn(:)
    real(real64) :: melting_factor,ordinary_decrement,value,difference,weight,temporary
    logical :: melting_ready,ordinary_ready
    integer(int32) :: column
    if (klon<0 .or. klon>4096 .or. kidia<1 .or. kfdia>klon) call reject_contract()
    if (min(size(llnosnow),size(pasnm1m),size(pmsn),size(psnowf),size(pasn))<klon) call reject_contract()
    melting_ready=.false.
    ordinary_ready=.false.
    do column=kidia,kfdia
      if (llnosnow(column)) then
        value=ydsoil%ralfmaxsn
      else
        if (pmsn(column)>0.0_real64) then
          difference=pasnm1m(column)-ydsoil%ralfminsn
          if (.not.melting_ready) then
            temporary=-ydsoil%rtauf
            temporary=temporary*ptmst
            temporary=temporary/ydcst%rday
            melting_factor=selected_exponential(temporary)
            melting_ready=.true.
          end if
          value=difference*melting_factor
          value=value+ydsoil%ralfminsn
        else
          if (.not.ordinary_ready) then
            ordinary_decrement=ydsoil%rtaua*ptmst
            ordinary_decrement=ordinary_decrement/ydcst%rday
            ordinary_ready=.true.
          end if
          value=pasnm1m(column)-ordinary_decrement
          value=maximum(ydsoil%ralfminsn,value)
        end if
        weight=psnowf(column)*ptmst
        weight=maximum(weight,0.0_real64)
        weight=weight/10.0_real64
        weight=minimum(weight,1.0_real64)
        difference=ydsoil%ralfmaxsn-value
        weight=weight*difference
        value=value+weight
        value=maximum(value,ydsoil%ralfminsn)
        value=minimum(ydsoil%ralfmaxsn,value)
      end if
      pasn(column)=value
    end do
  end subroutine srfsn_asn
  !> Preserve minimum and maximum zero signs for finite admitted operands.
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
end module srfsn_asn_mod
