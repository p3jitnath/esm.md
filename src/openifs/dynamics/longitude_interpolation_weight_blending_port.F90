module md2asm_longitude_interpolation_weight_blending
  !! Complete LASCAW_CLO cubic, lower-order and smoothed longitude weights.
  !! Coordinates, weights and rates are dimensionless.
  use iso_fortran_env,only:int32,int64,real64
  implicit none
  private
  public::longitude_weight_controls,blend_longitude_interpolation_weights
  type::longitude_weight_controls
    logical::diffusion=.false.,quadratic=.false.,older_linear=.false.,turbulence=.false.
    real(real64)::minimum_blend=0.0_real64,maximum_blend=0.0_real64,reference_blend=0.0_real64
    real(real64)::epsilon=0.0_real64
  end type
contains
  subroutine blend_longitude_interpolation_weights(c,pitch,first,last,levels,longitude,correction_longitude, &
      main,correction,filtered,status,kappa,turbulent_rate)
    !! Coordinate arrays use(cell,level); outputs use(cell,level,coefficient).
    !! All three complete output owners are disjoint from inputs and each other.
    type(longitude_weight_controls),intent(in)::c
    integer(int32),intent(in)::pitch,first,last,levels
    real(real64),intent(in)::longitude(:,:),correction_longitude(:,:)
    real(real64),intent(inout)::main(:,:,:),correction(:,:,:),filtered(:,:,:)
    integer(int32),intent(out)::status
    real(real64),intent(in),optional::kappa(:,:),turbulent_rate(:,:)
    real(real64),volatile::epsilon_product,diagonal,low(3)
    real(real64)::original(3),new_main(3),new_filtered(3),candidate(3),smoothed(3),mad(3)
    real(real64)::coordinate,quarter_x,sign_half,part1,part2,rate,delta,product
    integer::cell,level,j
    status=2
    if(c%diffusion.and..not.c%quadratic.and..not.c%older_linear)return
    if(pitch<0.or.pitch>1024.or.levels<0.or.levels>256)return
    if(first<1.or.first>pitch+1.or.last<0.or.last>pitch)return
    epsilon_product=2.0_real64*c%epsilon
    diagonal=1.0_real64-epsilon_product
    status=0
    if(levels==0.or.first>last)return
    status=2
    if(.not.valid_scalar(longitude).or..not.valid_scalar(correction_longitude))return
    if(.not.valid_output(main).or..not.valid_output(correction).or..not.valid_output(filtered))return
    if(c%diffusion)then
      if(.not.present(kappa))return
      if(.not.valid_scalar(kappa))return
    end if
    if(c%turbulence)then
      if(.not.present(turbulent_rate))return
      if(.not.valid_scalar(turbulent_rate))return
    end if
    do level=1,levels
      do cell=first,last
        call cubic_weights(correction_longitude(cell,level),mad)
        correction(cell,level,:)=mad
        coordinate=longitude(cell,level)
        call cubic_weights(coordinate,original)
        if(c%quadratic)then
          quarter_x=0.25_real64*coordinate
          part1=1.0_real64-coordinate
          part2=1.0_real64+quarter_x
          low(1)=part1*part2
          part1=1.25_real64-quarter_x
          low(2)=coordinate*part1
          part1=coordinate-1.0_real64
          low(3)=quarter_x*part1
        else if(c%older_linear)then
          low(2)=coordinate
          low(1)=1.0_real64-low(2)
          low(3)=0.0_real64
        end if
        if(c%diffusion)then
          sign_half=0.5_real64
          if(btest(transfer(kappa(cell,level),0_int64),63))sign_half=-0.5_real64
          part1=0.5_real64+sign_half
          part1=part1*c%minimum_blend
          part2=sign_half-0.5_real64
          part2=part2*c%reference_blend
          rate=part1-part2
          do j=1,3
            delta=low(j)-original(j)
            product=c%maximum_blend*delta
            candidate(j)=original(j)+product
            product=rate*delta
            new_main(j)=original(j)+product
          end do
          product=diagonal*candidate(1)
          part1=c%epsilon*candidate(2)
          smoothed(1)=product+part1
          product=c%epsilon*candidate(1)
          part1=diagonal*candidate(2)
          smoothed(2)=product+part1
          product=c%epsilon*candidate(2)
          smoothed(3)=product+candidate(3)
          do j=1,3
            delta=smoothed(j)-new_main(j)
            product=abs(kappa(cell,level))*delta
            new_filtered(j)=new_main(j)+product
          end do
        else if(c%quadratic)then
          do j=1,3
            delta=low(j)-original(j)
            product=c%minimum_blend*delta
            new_main(j)=original(j)+product
          end do
          new_filtered=new_main
        else
          new_main=original
          new_filtered=original
        end if
        if(c%turbulence)then
          call turbulence_smoothing(new_main,turbulent_rate(cell,level),smoothed)
          new_main=smoothed
          call turbulence_smoothing(new_filtered,turbulent_rate(cell,level),smoothed)
          new_filtered=smoothed
        end if
        main(cell,level,:)=new_main
        filtered(cell,level,:)=new_filtered
      end do
    end do
    status=0
  contains
    logical function valid_scalar(a)
      real(real64),intent(in)::a(:,:)
      valid_scalar=size(a,1)==pitch.and.size(a,2)>=levels
    end function
    logical function valid_output(a)
      real(real64),intent(in)::a(:,:,:)
      valid_output=size(a,1)==pitch.and.size(a,2)>=levels.and.size(a,3)==3
    end function
  end subroutine
  subroutine cubic_weights(x,weights)
    real(real64),intent(in)::x
    real(real64),intent(out)::weights(3)
    real(real64),parameter::one_sixth=transfer(int(z'3fc5555555555555',int64),0.0_real64)
    real(real64)::plus_one,minus_one,minus_two,value
    plus_one=x+1.0_real64
    minus_one=x-1.0_real64
    minus_two=x-2.0_real64
    value=0.5_real64*plus_one
    value=value*minus_one
    weights(1)=value*minus_two
    value=-0.5_real64*plus_one
    value=value*x
    weights(2)=value*minus_two
    value=one_sixth*plus_one
    value=value*x
    weights(3)=value*minus_one
  end subroutine
  subroutine turbulence_smoothing(input,rate,output)
    real(real64),intent(in)::input(3),rate
    real(real64),intent(out)::output(3)
    real(real64)::diagonal,product,other
    product=2.0_real64*rate
    diagonal=1.0_real64-product
    product=diagonal*input(1)
    other=rate*input(2)
    output(1)=product+other
    product=diagonal*input(2)
    other=rate*input(1)
    output(2)=product+other
    product=rate*input(2)
    output(3)=product+input(3)
  end subroutine
end module md2asm_longitude_interpolation_weight_blending
