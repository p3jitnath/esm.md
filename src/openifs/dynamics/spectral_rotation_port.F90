module md2asm_spectral_rotation
  !! Port the generated SPCIMPFINIT and SPCIMPFPOST calculations.
  !!
  !! Vorticity and divergence use inverse seconds. Coefficient factors are
  !! dimensionless. Arrays retain native Fortran bounds and strides; the
  !! compiler supplies their calling convention.
  use iso_fortran_env, only: int32,int64,real64
  use ieee_arithmetic, only: ieee_get_rounding_mode,ieee_round_type,ieee_nearest, &
    operator(==),ieee_support_underflow_control,ieee_get_underflow_mode
  implicit none
  private
  public :: prepare_spectral_rotation,correct_spectral_rotation
contains
  subroutine prepare_spectral_rotation(n,m,active_levels,first_column, &
      rotation_coefficient,time_step,rotation_rate,vorticity,auxiliary,status)
    !! Invert the same-degree factor, then build lower and upper neighbours.
    !!
    !! Only active_levels rows and the declared wave's coefficient pairs are
    !! changed. Complete lower passes precede upper passes. KEND is not read
    !! by the generated source and is absent from this typed interface.
    integer(int32), intent(in) :: n,m,active_levels,first_column
    real(real64), intent(in) :: rotation_coefficient,time_step,rotation_rate
    real(real64), intent(inout) :: vorticity(:,:),auxiliary(:,:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: factors(:,:)
    real(real64) :: force,ar,ai,temporary,real_value,imaginary_value,value
    integer :: degree,level,column,allocation_status
    status=2
    if(.not.valid_wave(n,m,active_levels,first_column,vorticity,auxiliary))return
    allocate(factors(0:n+1,5),stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      return
    end if
    force=rotation_coefficient*time_step
    force=2.0_real64*force
    force=force*rotation_rate
    call make_rotation_factors(n,m,force,factors)
    if(active_levels==0)then
      status=0
      return
    end if
    if(m/=0)then
      do degree=m,n
        column=first_column+2*(degree-m)
        do level=1,active_levels
          ar=vorticity(level,column)
          ai=vorticity(level,column+1)
          temporary=factors(degree,1)*ar
          imaginary_value=ai+temporary
          imaginary_value=factors(degree,2)*imaginary_value
          temporary=factors(degree,1)*ai
          real_value=ar-temporary
          real_value=factors(degree,2)*real_value
          vorticity(level,column)=real_value
          vorticity(level,column+1)=imaginary_value
        end do
      end do
    end if
    do degree=m,n
      column=first_column+2*(degree-m)
      do level=1,active_levels
        auxiliary(level,column)=0.0_real64
        auxiliary(level,column+1)=0.0_real64
      end do
    end do
    do degree=m+1,n
      column=first_column+2*(degree-m)
      do level=1,active_levels
        temporary=factors(degree,5)*vorticity(level,column-2)
        value=auxiliary(level,column)+temporary
        auxiliary(level,column)=value
        temporary=factors(degree,5)*vorticity(level,column-1)
        value=auxiliary(level,column+1)+temporary
        auxiliary(level,column+1)=value
      end do
    end do
    do degree=m,n-1
      column=first_column+2*(degree-m)
      do level=1,active_levels
        temporary=factors(degree,4)*vorticity(level,column+2)
        value=auxiliary(level,column)+temporary
        auxiliary(level,column)=value
        temporary=factors(degree,4)*vorticity(level,column+3)
        value=auxiliary(level,column+1)+temporary
        auxiliary(level,column+1)=value
      end do
    end do
    status=0
  end subroutine

  subroutine correct_spectral_rotation(n,m,active_levels,first_column, &
      rotation_coefficient,time_step,rotation_rate,divergence,vorticity,status)
    !! Subtract source-ordered neighbour corrections from vorticity.
    !!
    !! Wave zero updates real components only. Imaginary and inactive words
    !! retain their input bytes. Divergence is read without mutation.
    integer(int32), intent(in) :: n,m,active_levels,first_column
    real(real64), intent(in) :: rotation_coefficient,time_step,rotation_rate
    real(real64), intent(in) :: divergence(:,:)
    real(real64), intent(inout) :: vorticity(:,:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: factors(:,:)
    real(real64) :: force,ar,ai,temporary,value,factor
    integer :: degree,level,column,pass,first,last,neighbour,allocation_status
    status=2
    if(.not.valid_wave(n,m,active_levels,first_column,divergence,vorticity))return
    allocate(factors(0:n+1,5),stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      return
    end if
    force=rotation_coefficient*time_step
    force=2.0_real64*force
    force=force*rotation_rate
    call make_rotation_factors(n,m,force,factors)
    do pass=0,1
      if(pass==0)then
        first=m+1
        if(m==0)first=2
        last=n
        neighbour=-2
      else
        first=m
        if(m==0)first=1
        last=n-1
        neighbour=2
      end if
      do degree=first,last
        if(pass==0)then
          factor=factors(degree,2)*factors(degree,5)
        else
          factor=factors(degree,2)*factors(degree,4)
        end if
        column=first_column+2*(degree-m)
        do level=1,active_levels
          ar=divergence(level,column+neighbour)
          if(m==0)then
            temporary=factor*ar
            value=vorticity(level,column)-temporary
            vorticity(level,column)=value
          else
            ai=divergence(level,column+neighbour+1)
            temporary=factors(degree,1)*ai
            value=ar-temporary
            temporary=factor*value
            value=vorticity(level,column)-temporary
            vorticity(level,column)=value
            temporary=factors(degree,1)*ar
            value=ai+temporary
            temporary=factor*value
            value=vorticity(level,column+1)-temporary
            vorticity(level,column+1)=value
          end if
        end do
      end do
    end do
    status=0
  end subroutine

  subroutine make_rotation_factors(n,m,force,factors)
    !! Preserve every separate factor multiplication, division and square root.
    integer(int32), intent(in) :: n,m
    real(real64), intent(in) :: force
    real(real64), intent(out) :: factors(0:,:)
    real(real64) :: rm,rm_squared,numerator,rn,rnp1,temporary,other,denominator
    integer :: degree
    rm=real(m,real64)
    numerator=force*rm
    rm_squared=rm*rm
    if(m==0)then
      factors(0,1)=0.0_real64
      factors(0,2)=0.0_real64
      factors(0,3)=0.0_real64
      factors(0,4)=0.0_real64
      factors(0,5)=0.0_real64
    end if
    do degree=max(1,m),n
      rn=real(degree,real64)
      rnp1=rn+1.0_real64
      denominator=rn*rnp1
      factors(degree,1)=numerator/denominator
      temporary=factors(degree,1)*factors(degree,1)
      temporary=1.0_real64+temporary
      factors(degree,2)=1.0_real64/temporary
      temporary=rn*rn
      temporary=temporary-rm_squared
      denominator=4.0_real64*rn
      denominator=denominator*rn
      denominator=denominator-1.0_real64
      temporary=temporary/denominator
      factors(degree,3)=sqrt(temporary)
    end do
    factors(n+1,1)=0.0_real64
    factors(n+1,2)=0.0_real64
    do degree=max(1,m),n-1
      rn=real(degree,real64)
      rnp1=rn+1.0_real64
      temporary=force*rn
      temporary=temporary*factors(degree+1,3)
      factors(degree,4)=temporary/rnp1
      temporary=force*rnp1
      temporary=temporary*factors(degree,3)
      factors(degree,5)=temporary/rn
    end do
    factors(n,4)=0.0_real64
    rn=real(n,real64)
    rnp1=rn+1.0_real64
    temporary=force*rnp1
    temporary=temporary*factors(n,3)
    factors(n,5)=temporary/rn
    factors(n+1,4)=0.0_real64
    factors(n+1,5)=0.0_real64
  end subroutine

  logical function valid_wave(n,m,levels,first,a,b) result(ok)
    integer(int32), intent(in) :: n,m,levels,first
    real(real64), intent(in) :: a(:,:),b(:,:)
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal,half_value,subnormal_probe
    ok=.false.
    if(n<1 .or. n>8191 .or. m<0 .or. m>n) return
    if(levels<0 .or. levels>512 .or. first<1)return
    if(size(a,1)<levels .or. size(b,1)<levels)return
    if(first>size(a,2)+1 .or. first>size(b,2)+1)return
    if(2*(n-m+1)>size(a,2)-first+1)return
    if(2*(n-m+1)>size(b,2)-first+1)return
    call ieee_get_rounding_mode(rounding)
    if(.not.(rounding==ieee_nearest))return
    if(ieee_support_underflow_control(0.0_real64))then
      call ieee_get_underflow_mode(gradual)
      if(.not.gradual)return
    else
      minimum_normal=tiny(0.0_real64)
      half_value=0.5_real64
      subnormal_probe=minimum_normal*half_value
      if(transfer(subnormal_probe,0_int64)/=ibset(0_int64,51))return
    end if
    ok=.true.
  end function
end module md2asm_spectral_rotation
