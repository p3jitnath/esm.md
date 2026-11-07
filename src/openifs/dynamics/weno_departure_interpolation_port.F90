module md2asm_weno_departure_interpolation
  !! Complete generated56-point WENO reconstruction and local residual clamp.
  !! WENO combines three cubic estimates using variation-dependent weights.
  !! Coordinates, weights, smoothness exponents and residual factors have no unit.
  use iso_fortran_env,only:int32,int64,real64
  use iso_c_binding,only:c_double
  implicit none
  private
  public::weno_interpolation_controls,interpolate_weno_departure
  type::weno_interpolation_controls
    real(real64)::exponent=0.0_real64,upper_exponent=0.0_real64
    integer(int32)::upper_level_count=0,smoothness_choice=1
    logical::boundary_enabled=.false.
  end type
  interface
    function public_scalar_power(base,exponent)bind(C,name='pow')result(value)
      import::c_double
      real(c_double),value::base,exponent
      real(c_double)::value
    end function
  end interface
  real(real64),parameter::cutoff=transfer(int(z'3eb0c6f7a0b5ed8d',int64),0.0_real64)
  real(real64),parameter::magnitude_floor=transfer(int(z'3d19000000000000',int64),0.0_real64)
  real(real64),parameter::smoothness_table(10,3,5)=reshape([ &
    transfer(int(z'3ff5b05b05b05b06',int64),0.0_real64), &
    transfer(int(z'4026111111111111',int64),0.0_real64), &
    transfer(int(z'4026111111111111',int64),0.0_real64), &
    transfer(int(z'3ff5b05b05b05b06',int64),0.0_real64), &
    transfer(int(z'c01c333333333333',int64),0.0_real64), &
    transfer(int(z'4017ddddddddddde',int64),0.0_real64), &
    transfer(int(z'bffa0b60b60b60b6',int64),0.0_real64), &
    transfer(int(z'c034fbbbbbbbbbbc',int64),0.0_real64), &
    transfer(int(z'4017ddddddddddde',int64),0.0_real64), &
    transfer(int(z'c01c333333333333',int64),0.0_real64), &
    transfer(int(z'3ff5b05b05b05b06',int64),0.0_real64), &
    transfer(int(z'4030888888888889',int64),0.0_real64), &
    transfer(int(z'4038088888888889',int64),0.0_real64), &
    transfer(int(z'401216c16c16c16c',int64),0.0_real64), &
    transfer(int(z'c0226eeeeeeeeeef',int64),0.0_real64), &
    transfer(int(z'402499999999999a',int64),0.0_real64), &
    transfer(int(z'c00e5b05b05b05b0',int64),0.0_real64), &
    transfer(int(z'c0433dddddddddde',int64),0.0_real64), &
    transfer(int(z'402d444444444444',int64),0.0_real64), &
    transfer(int(z'c033e22222222222',int64),0.0_real64), &
    transfer(int(z'401216c16c16c16c',int64),0.0_real64), &
    transfer(int(z'4038088888888889',int64),0.0_real64), &
    transfer(int(z'4030888888888889',int64),0.0_real64), &
    transfer(int(z'3ff5b05b05b05b06',int64),0.0_real64), &
    transfer(int(z'c033e22222222222',int64),0.0_real64), &
    transfer(int(z'402d444444444444',int64),0.0_real64), &
    transfer(int(z'c00e5b05b05b05b0',int64),0.0_real64), &
    transfer(int(z'c0433dddddddddde',int64),0.0_real64), &
    transfer(int(z'402499999999999a',int64),0.0_real64), &
    transfer(int(z'c0226eeeeeeeeeef',int64),0.0_real64), &
    transfer(int(z'3ff5555555555555',int64),0.0_real64), &
    transfer(int(z'4024000000000000',int64),0.0_real64), &
    transfer(int(z'4024000000000000',int64),0.0_real64), &
    transfer(int(z'3ff5555555555555',int64),0.0_real64), &
    transfer(int(z'c01c000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'bffaaaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'c033000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'c01c000000000000',int64),0.0_real64), &
    transfer(int(z'3ff5555555555555',int64),0.0_real64), &
    transfer(int(z'4030000000000000',int64),0.0_real64), &
    transfer(int(z'4036000000000000',int64),0.0_real64), &
    transfer(int(z'400aaaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'c022000000000000',int64),0.0_real64), &
    transfer(int(z'4024000000000000',int64),0.0_real64), &
    transfer(int(z'c00d555555555555',int64),0.0_real64), &
    transfer(int(z'c042800000000000',int64),0.0_real64), &
    transfer(int(z'402c000000000000',int64),0.0_real64), &
    transfer(int(z'c031000000000000',int64),0.0_real64), &
    transfer(int(z'400aaaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'4036000000000000',int64),0.0_real64), &
    transfer(int(z'4030000000000000',int64),0.0_real64), &
    transfer(int(z'3ff5555555555555',int64),0.0_real64), &
    transfer(int(z'c031000000000000',int64),0.0_real64), &
    transfer(int(z'402c000000000000',int64),0.0_real64), &
    transfer(int(z'c00d555555555555',int64),0.0_real64), &
    transfer(int(z'c042800000000000',int64),0.0_real64), &
    transfer(int(z'4024000000000000',int64),0.0_real64), &
    transfer(int(z'c022000000000000',int64),0.0_real64), &
    transfer(int(z'3fd5555555555555',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'3fd5555555555555',int64),0.0_real64), &
    transfer(int(z'bff0000000000000',int64),0.0_real64), &
    transfer(int(z'0000000000000000',int64),0.0_real64), &
    transfer(int(z'3fd5555555555555',int64),0.0_real64), &
    transfer(int(z'bff0000000000000',int64),0.0_real64), &
    transfer(int(z'0000000000000000',int64),0.0_real64), &
    transfer(int(z'bff0000000000000',int64),0.0_real64), &
    transfer(int(z'3fd5555555555555',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'402a000000000000',int64),0.0_real64), &
    transfer(int(z'4002aaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'c008000000000000',int64),0.0_real64), &
    transfer(int(z'4010000000000000',int64),0.0_real64), &
    transfer(int(z'bffaaaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'c033000000000000',int64),0.0_real64), &
    transfer(int(z'4020000000000000',int64),0.0_real64), &
    transfer(int(z'c026000000000000',int64),0.0_real64), &
    transfer(int(z'4002aaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'402a000000000000',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'3fd5555555555555',int64),0.0_real64), &
    transfer(int(z'c026000000000000',int64),0.0_real64), &
    transfer(int(z'4020000000000000',int64),0.0_real64), &
    transfer(int(z'bffaaaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'c033000000000000',int64),0.0_real64), &
    transfer(int(z'4010000000000000',int64),0.0_real64), &
    transfer(int(z'c008000000000000',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'4022000000000000',int64),0.0_real64), &
    transfer(int(z'4022000000000000',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'c018000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'c000000000000000',int64),0.0_real64), &
    transfer(int(z'c032000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'c018000000000000',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'4022000000000000',int64),0.0_real64), &
    transfer(int(z'4022000000000000',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'c018000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'c000000000000000',int64),0.0_real64), &
    transfer(int(z'c032000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'c018000000000000',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'4022000000000000',int64),0.0_real64), &
    transfer(int(z'4022000000000000',int64),0.0_real64), &
    transfer(int(z'3ff0000000000000',int64),0.0_real64), &
    transfer(int(z'c018000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'c000000000000000',int64),0.0_real64), &
    transfer(int(z'c032000000000000',int64),0.0_real64), &
    transfer(int(z'4018000000000000',int64),0.0_real64), &
    transfer(int(z'c018000000000000',int64),0.0_real64), &
    transfer(int(z'3ffd555555555555',int64),0.0_real64), &
    transfer(int(z'4028555555555555',int64),0.0_real64), &
    transfer(int(z'4028555555555555',int64),0.0_real64), &
    transfer(int(z'3ffd555555555555',int64),0.0_real64), &
    transfer(int(z'c021555555555555',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'c000000000000000',int64),0.0_real64), &
    transfer(int(z'c036aaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'c021555555555555',int64),0.0_real64), &
    transfer(int(z'3ffd555555555555',int64),0.0_real64), &
    transfer(int(z'4028555555555555',int64),0.0_real64), &
    transfer(int(z'4028555555555555',int64),0.0_real64), &
    transfer(int(z'3ffd555555555555',int64),0.0_real64), &
    transfer(int(z'c021555555555555',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'c000000000000000',int64),0.0_real64), &
    transfer(int(z'c036aaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'c021555555555555',int64),0.0_real64), &
    transfer(int(z'3ffd555555555555',int64),0.0_real64), &
    transfer(int(z'4028555555555555',int64),0.0_real64), &
    transfer(int(z'4028555555555555',int64),0.0_real64), &
    transfer(int(z'3ffd555555555555',int64),0.0_real64), &
    transfer(int(z'c021555555555555',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'c000000000000000',int64),0.0_real64), &
    transfer(int(z'c036aaaaaaaaaaab',int64),0.0_real64), &
    transfer(int(z'401c000000000000',int64),0.0_real64), &
    transfer(int(z'c021555555555555',int64),0.0_real64) ],[10,3,5])
contains
  subroutine interpolate_weno_departure(c,source_pitch,pitch,first,last,levels,first_plane,last_plane,limiter, &
      latitude,latitude_coefficients,longitude,longitude_coefficients,indices,boundary,linear_weights, &
      vertical_weights,field,result,status,exponent,vertical_factor,conservative)
    !! Array owners are separate and keep(cell,level,plane) order. Longitude
    !! coefficient planes use(3,2), and vertical planes use(3,3). The output
    !! is staged privately until every selected point passes its guards.
    !! Public C pow supplies only the declared scalar mathematical operation.
    type(weno_interpolation_controls),intent(in)::c
    integer(int32),intent(in)::source_pitch,pitch,first,last,levels,first_plane,last_plane,limiter
    real(real64),intent(in)::latitude(:,:),latitude_coefficients(:,:,:),longitude(:,:,0:)
    real(real64),intent(in)::longitude_coefficients(:,:,:,:),linear_weights(:,:,:),vertical_weights(:,:,:,:)
    integer(int32),intent(in)::indices(:,:,0:),boundary(:,:)
    real(real64),intent(in)::field(:)
    real(real64),intent(inout)::result(:,:)
    integer(int32),intent(out)::status
    real(real64),intent(in),optional::exponent,vertical_factor(:)
    logical,intent(in),optional::conservative
    real(real64),allocatable,target::workspace(:)
    real(real64),pointer::staged(:,:),residual(:)
    integer(int64)::planes,total,cell_words,k(0:3)
    integer::cell,level,s,v,which,start,flag,j,allocation_status
    logical::failed,carry,horizontal_clip,loaded_lon(0:3),loaded_clo(3,2),loaded_lat,loaded_cla(3)
    real(real64)::lon(0:3),clo(3,2),lat,cla(3),row(0:3,-1:4),z(0:5),candidate(3),alpha(3)
    real(real64)::base_exponent,power_exponent,value,base,powered,denominator,weight,total_weight
    real(real64)::difference0,difference1,product0,product1,lower,upper,old_value,factor,corner
    status=2
    if(source_pitch<4.or.source_pitch>134217728.or.pitch<1.or.pitch>2048.or.levels<1.or.levels>512)return
    if(first<1.or.first>pitch.or.last<0.or.last>pitch.or.limiter< -1.or.limiter>3)return
    planes=int(last_plane,int64)-int(first_plane,int64)+1
    if(planes<1.or.planes>512)return
    total=int(source_pitch,int64)*planes
    if(total>huge(0_int32))return
    base_exponent=c%exponent
    if(present(exponent))base_exponent=exponent
    if(.not.finite(base_exponent).or..not.finite(c%upper_exponent))return
    if(base_exponent<0.0_real64.or.base_exponent>4.0_real64)return
    if(c%upper_exponent<0.0_real64.or.c%upper_exponent>4.0_real64)return
    if(c%upper_level_count<0.or.c%smoothness_choice<1.or.c%smoothness_choice>5)return
    carry=.false.
    if(limiter==-1)then
      if(.not.present(vertical_factor).or..not.present(conservative))return
      if(size(vertical_factor)<levels)return
      carry=conservative
    end if
    status=0
    if(first>last)return
    status=2
    if(size(latitude,1)/=pitch.or.size(latitude,2)<levels)return
    if(size(latitude_coefficients,1)/=pitch.or.size(latitude_coefficients,2)<levels.or. &
      size(latitude_coefficients,3)/=3)return
    if(size(longitude,1)/=pitch.or.size(longitude,2)<levels.or.size(longitude,3)/=4)return
    if(size(longitude_coefficients,1)/=pitch.or.size(longitude_coefficients,2)<levels.or. &
      size(longitude_coefficients,3)/=3.or.size(longitude_coefficients,4)/=2)return
    if(size(indices,1)/=pitch.or.size(indices,2)<levels.or.size(indices,3)/=4)return
    if(size(boundary,1)/=pitch.or.size(boundary,2)<levels)return
    if(size(linear_weights,1)/=pitch.or.size(linear_weights,2)<levels.or.size(linear_weights,3)/=3)return
    if(size(vertical_weights,1)/=pitch.or.size(vertical_weights,2)<levels.or. &
      size(vertical_weights,3)/=3.or.size(vertical_weights,4)/=3)return
    if(size(result,1)/=pitch.or.size(result,2)<levels.or.size(field,kind=int64)/=total)return
    cell_words=int(pitch,int64)*levels
    allocate(workspace(cell_words+pitch),stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      return
    end if
    staged(1:pitch,1:levels)=>workspace(1:cell_words)
    residual(1:pitch)=>workspace(cell_words+1:cell_words+pitch)
    residual=0.0_real64
    horizontal_clip=limiter==1.or.limiter==2
    do level=1,levels
      power_exponent=base_exponent
      if(level<=c%upper_level_count)power_exponent=ordered_maximum(power_exponent,c%upper_exponent)
      do cell=first,last
        flag=boundary(cell,level)
        if(flag< -2.or.flag>2)return
        k=int(indices(cell,level,:),int64)
        failed=.false.
        loaded_lon=.false.;loaded_clo=.false.;loaded_lat=.false.;loaded_cla=.false.
        row(1,-1)=longitude_linear(1,-1,1)
        if(failed)return
        row(2,-1)=longitude_linear(2,-1,1)
        if(failed)return
        do v=0,3
          row(0,v)=longitude_linear(0,v,0)
          if(failed)return
          row(1,v)=longitude_cubic(1,v)
          if(failed)return
          row(2,v)=longitude_cubic(2,v)
          if(failed)return
          row(3,v)=longitude_linear(3,v,0)
          if(failed)return
        end do
        row(1,4)=longitude_linear(1,4,-1)
        if(failed)return
        row(2,4)=longitude_linear(2,4,-1)
        if(failed)return
        z(0)=latitude_linear(row(1,-1),row(2,-1))
        if(failed)return
        do v=0,3
          z(v+1)=latitude_cubic(row(:,v))
          if(failed)return
          if(horizontal_clip.and.(v==1.or.v==2))z(v+1)=clip(z(v+1),row(1,v),row(2,v))
        end do
        z(5)=latitude_linear(row(1,4),row(2,4))
        if(failed)return
        candidate(1)=vertical_cubic(1,1)
        if(failed)return
        if(c%boundary_enabled.or.flag==0)then
          do which=1,3
            if(which==2)then
              start=2+min(0,flag)
              candidate(2)=vertical_cubic(start,2)
              if(failed)return
            else if(which==3)then
              start=max(0,flag)
              candidate(3)=vertical_cubic(start,3)
              if(failed)return
            else
              start=1
            end if
            base=smoothness(z(start:start+3),which)
            base=base+cutoff
            if(.not.finite(base))return
            if(base<=0.0_real64)return
            powered=public_scalar_power(base,power_exponent)
            if(.not.finite(powered))return
            denominator=ordered_maximum(abs(powered),magnitude_floor)
            if(btest(transfer(powered,0_int64),63))denominator=-denominator
            weight=linear_weights(cell,level,which)
            if(.not.finite(weight))return
            if(weight<0.0_real64)return
            alpha(which)=weight/denominator
          end do
          total_weight=alpha(1)+alpha(2)
          total_weight=total_weight+alpha(3)
          if(.not.finite(total_weight))return
          if(total_weight<=0.0_real64)return
          alpha(1)=alpha(1)/total_weight
          alpha(2)=alpha(2)/total_weight
          difference0=candidate(1)-candidate(3)
          difference1=candidate(2)-candidate(3)
          product0=alpha(1)*difference0
          product1=alpha(2)*difference1
          value=product0+product1
          value=value+candidate(3)
        else
          value=candidate(1)
        end if
        if(limiter>1)value=clip(value,z(2),z(3))
        if(limiter==-1)then
          if(carry)value=value+residual(cell)
          old_value=value
          lower=read_field(1,1,1,0)
          if(failed)return
          upper=lower
          do v=1,2
            do s=1,2
              do j=1,2
                if(v==1.and.s==1.and.j==1)cycle
                corner=read_field(s,v,j,0)
                if(failed)return
                if(corner<lower)lower=corner
                if(corner>upper)upper=corner
              end do
            end do
          end do
          value=ordered_minimum(upper,value)
          value=ordered_maximum(lower,value)
          if(carry)then
            difference0=old_value-value
            factor=1.0_real64
            if(level>1)then
              factor=vertical_factor(level)
              if(.not.finite(factor))return
              if(factor<=0.0_real64)return
            end if
            residual(cell)=difference0*factor
            if(.not.finite(residual(cell)))return
          end if
        end if
        if(.not.finite(value))return
        staged(cell,level)=value
      end do
    end do
    do level=1,levels
      do cell=first,last
        result(cell,level)=staged(cell,level)
      end do
    end do
    status=0
  contains
    real(real64)function read_field(side,height,long_index,shift)result(value)
      integer,intent(in)::side,height,long_index,shift
      integer(int64)::offset,height_shift
      value=0.0_real64
      height_shift=0
      if(shift==1)height_shift=max(0,flag)
      if(shift==-1)height_shift=min(0,flag)
      offset=k(side)-1+(int(height,int64)+height_shift)*source_pitch+long_index
      if(offset<0.or.offset>=total)then
        failed=.true.
        return
      end if
      value=field(offset+1)
      if(.not.finite(value))failed=.true.
    end function
    real(real64)function longitude_linear(side,height,shift)result(value)
      integer,intent(in)::side,height,shift
      real(real64)::a,b,difference,product
      value=0.0_real64
      a=read_field(side,height,1,shift)
      if(failed)return
      b=read_field(side,height,2,shift)
      if(failed)return
      if(.not.loaded_lon(side))then
        lon(side)=longitude(cell,level,side)
        if(.not.finite(lon(side)))then
          failed=.true.
          return
        end if
        loaded_lon(side)=.true.
      end if
      difference=b-a
      product=difference*lon(side)
      value=a+product
    end function
    real(real64)function longitude_cubic(side,height)result(value)
      integer,intent(in)::side,height
      real(real64)::a(4),difference
      real(real64),volatile::terms(3)
      integer::n
      value=0.0_real64
      do n=0,3
        a(n+1)=read_field(side,height,n,0)
        if(failed)return
      end do
      do n=1,3
        if(.not.loaded_clo(n,side))then
          clo(n,side)=longitude_coefficients(cell,level,n,side)
          if(.not.finite(clo(n,side)))then
            failed=.true.
            return
          end if
          loaded_clo(n,side)=.true.
        end if
        difference=a(n+1)-a(1)
        terms(n)=difference*clo(n,side)
      end do
      value=a(1)+terms(1)
      value=value+terms(2)
      value=value+terms(3)
      if(horizontal_clip.and.(height==1.or.height==2))value=clip(value,a(2),a(3))
    end function
    real(real64)function latitude_linear(a,b)result(value)
      real(real64),intent(in)::a,b
      real(real64)::difference,product
      value=0.0_real64
      if(.not.loaded_lat)then
        lat=latitude(cell,level)
        if(.not.finite(lat))then
          failed=.true.
          return
        end if
        loaded_lat=.true.
      end if
      difference=b-a
      product=difference*lat
      value=a+product
    end function
    real(real64)function latitude_cubic(a)result(value)
      real(real64),intent(in)::a(0:3)
      real(real64)::difference
      real(real64),volatile::terms(3)
      integer::n
      value=0.0_real64
      do n=1,3
        if(.not.loaded_cla(n))then
          cla(n)=latitude_coefficients(cell,level,n)
          if(.not.finite(cla(n)))then
            failed=.true.
            return
          end if
          loaded_cla(n)=.true.
        end if
        difference=a(n)-a(0)
        terms(n)=difference*cla(n)
      end do
      value=a(0)+terms(1)
      value=value+terms(2)
      value=value+terms(3)
    end function
    real(real64)function vertical_cubic(begin,stencil)result(value)
      integer,intent(in)::begin,stencil
      real(real64)::coefficient,difference,product
      real(real64),volatile::partial
      integer::n
      value=0.0_real64
      partial=z(begin)
      do n=1,3
        coefficient=vertical_weights(cell,level,n,stencil)
        if(.not.finite(coefficient))then
          failed=.true.
          return
        end if
        difference=z(begin+n)-z(begin)
        product=difference*coefficient
        partial=partial+product
      end do
      value=partial
    end function
    real(real64)function smoothness(a,stencil)result(value)
      real(real64),intent(in)::a(4)
      integer,intent(in)::stencil
      integer,parameter::left(10)=[4,3,2,1,4,4,4,3,3,2],right(10)=[4,3,2,1,3,2,1,2,1,1]
      real(real64)::product
      integer::n
      product=smoothness_table(1,stencil,c%smoothness_choice)*a(left(1))
      value=product*a(right(1))
      do n=2,10
        product=smoothness_table(n,stencil,c%smoothness_choice)*a(left(n))
        product=product*a(right(n))
        value=value+product
      end do
    end function
  end subroutine
  elemental logical function finite(value)
    real(real64),intent(in)::value
    finite=ibits(transfer(value,0_int64),52,11)/=2047_int64
  end function
  real(real64) function blend(a,b,fraction) result(value)
    real(real64),intent(in)::a,b,fraction
    real(real64)::difference,product
    difference=b-a
    product=fraction*difference
    value=a+product
  end function
  real(real64) function cubic(a,b,c,d,weights) result(value)
    real(real64),intent(in)::a,b,c,d,weights(3)
    real(real64)::difference,product
    difference=b-a
    product=weights(1)*difference
    value=a+product
    difference=c-a
    product=weights(2)*difference
    value=value+product
    difference=d-a
    product=weights(3)*difference
    value=value+product
  end function
  real(real64) function clip(value,a,b) result(output)
    real(real64),intent(in)::value,a,b
    real(real64)::lower,upper
    lower=ordered_minimum(a,b)
    upper=ordered_maximum(a,b)
    output=ordered_minimum(upper,value)
    output=ordered_maximum(lower,output)
  end function
  real(real64) function ordered_minimum(a,b) result(value)
    real(real64),intent(in)::a,b
    if(a==b)then
      value=a
      if(a==0.0_real64)value=transfer(ior(transfer(a,0_int64),transfer(b,0_int64)),0.0_real64)
    else if(a<b)then
      value=a
    else
      value=b
    end if
  end function
  real(real64) function ordered_maximum(a,b) result(value)
    real(real64),intent(in)::a,b
    if(a==b)then
      value=a
      if(a==0.0_real64)value=transfer(iand(transfer(a,0_int64),transfer(b,0_int64)),0.0_real64)
    else if(a>b)then
      value=a
    else
      value=b
    end if
  end function
end module md2asm_weno_departure_interpolation
