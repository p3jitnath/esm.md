!> Structured Fortran port of our runtime spectral packing fit.
!! Input coefficients retain the triangular wave order and field units.
!! Only the two dimensionless packing-fit results are changed.
module forecast_spectral_packing_fit
  use, intrinsic :: iso_fortran_env, only: real64, int32, int64, error_unit
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_arithmetic
  use, intrinsic :: ieee_exceptions
  use forecast_positive_logarithm, only: positive_logarithm
  implicit none
  private
  public :: fit_spectrum, spectral_fit_calls
  integer(c_int64_t), bind(C,name="md2asm_runtime_fitspectrum_direct_calls") :: spectral_fit_calls=0
  interface
    subroutine terminate_process(code) bind(C,name="_Exit")
      import c_int
      integer(c_int), value :: code
    end subroutine terminate_process
  end interface
contains
  !> Report a rejected public interface before process termination.
  subroutine refuse_port(stage)
    integer, intent(in) :: stage
    write(error_unit,'(a,i0)') 'FORTRAN_FIT_REFUSAL_STAGE_',stage
    call terminate_process(116_c_int)
  end subroutine refuse_port

  !> Fit spectral decay, preserving each separate FP64 operation.
  !! n is the largest wave index, in [1,4096]. subset is in [0,n-1].
  !! spectrum contains (n+1)*(n+2) finite input coefficients.
  !! beta1 is stored before beta0; inputs remain unchanged.
  subroutine fit_spectrum(n,subset,spectrum,beta0,beta1)
    integer(int32), intent(in) :: n,subset
    real(real64), intent(in) :: spectrum(:)
    real(real64), intent(out), volatile :: beta0,beta1
    real(real64) :: weight(0:n), envelope(0:n), floor_value, floor_weight
    real(real64) :: sum_x,sum_y,sum_weight,mean_x,mean_y,log_x,log_y
    real(real64) :: numerator,denominator,dx,dy,temporary,slope
    integer(int64) :: index,base,word,expected_count
    integer :: degree,order,component,last_component,k
    type(ieee_round_type) :: rounding
    logical :: gradual
    if(n<1.or.n>4096.or.subset<0.or.subset>=n) call refuse_port(1)
    expected_count=int(n+1,int64)*int(n+2,int64)
    if(size(spectrum,kind=int64)/=expected_count) call refuse_port(2)
    call ieee_get_rounding_mode(rounding)
    ! The compiler may not implement the underflow-control inquiry.
    ! The caller then supplies gradual underflow; the byte driver checks FPCR.
    gradual=.true.
    if(ieee_support_underflow_control(0.0_real64)) call ieee_get_underflow_mode(gradual)
    if(rounding/=ieee_nearest.or..not.gradual) call refuse_port(3)
    do k=1,size(spectrum)
      word=transfer(spectrum(k),word)
      if(iand(word,int(z'7ff0000000000000',int64))==int(z'7ff0000000000000',int64)) &
        call refuse_port(4)
    end do
    spectral_fit_calls=spectral_fit_calls+1_c_int64_t
    do degree=subset+1,n
      weight(degree)=real(n-subset,real64)/real(degree-subset,real64)
      envelope(degree)=0.0_real64
    end do
    do order=0,n
      base=int(order,int64)*int(2*n+3-order,int64)
      last_component=0
      if(order>0) last_component=1
      do component=0,last_component
        do degree=max(order,subset+1),n
          index=base+2_int64*int(degree-order,int64)+int(component,int64)
          envelope(degree)=max(envelope(degree),abs(spectrum(index+1)))
        end do
      end do
    end do
    floor_value=transfer(int(z'3cb0000000000000',int64),floor_value)
    floor_weight=transfer(int(z'3d19000000000000',int64),floor_weight)
    do degree=subset+1,n
      envelope(degree)=max(envelope(degree),floor_value)
      if(envelope(degree)==floor_value) weight(degree)=floor_weight
    end do
    sum_x=0.0_real64
    sum_y=0.0_real64
    sum_weight=0.0_real64
    do degree=subset+1,n
      log_x=positive_logarithm(real(int(degree,int64)*int(degree+1,int64),real64))
      log_y=positive_logarithm(envelope(degree))
      temporary=log_x*weight(degree)
      sum_x=sum_x+temporary
      temporary=log_y*weight(degree)
      sum_y=sum_y+temporary
      sum_weight=sum_weight+weight(degree)
    end do
    mean_x=sum_x/sum_weight
    mean_y=sum_y/sum_weight
    numerator=0.0_real64
    denominator=0.0_real64
    do degree=subset+1,n
      log_x=positive_logarithm(real(int(degree,int64)*int(degree+1,int64),real64))
      log_y=positive_logarithm(envelope(degree))
      dy=log_y-mean_y
      dx=log_x-mean_x
      temporary=weight(degree)*dy
      temporary=temporary*dx
      numerator=numerator+temporary
      temporary=dx*dx
      temporary=weight(degree)*temporary
      denominator=denominator+temporary
    end do
    slope=numerator/denominator
    beta1=slope
    temporary=slope*mean_x
    beta0=mean_y-temporary
  end subroutine fit_spectrum

  !> Preserve the existing six-pointer public C interface.
  !! Integer inputs point to int32 values. FP64 spans have eight-byte alignment.
  !! Outputs are distinct and outside the read-only coefficient span.
  subroutine fit_runtime_c(n_ptr,count_ptr,spectrum_ptr,subset_ptr,beta0_ptr,beta1_ptr) &
      bind(C,name="md2asm_fitspectrum_runtime_rounding")
    type(c_ptr), value :: n_ptr,count_ptr,spectrum_ptr,subset_ptr,beta0_ptr,beta1_ptr
    integer(c_int), pointer :: n,count,subset
    real(c_double), pointer :: spectrum(:),beta0,beta1
    integer(c_intptr_t) :: spectrum_address,first_output,second_output,end_address
    if(.not.c_associated(n_ptr).or..not.c_associated(count_ptr).or..not.c_associated(spectrum_ptr).or. &
       .not.c_associated(subset_ptr).or..not.c_associated(beta0_ptr).or..not.c_associated(beta1_ptr)) &
       call refuse_port(5)
    if(modulo(transfer(n_ptr,0_c_intptr_t),4_c_intptr_t)/=0.or. &
       modulo(transfer(count_ptr,0_c_intptr_t),4_c_intptr_t)/=0.or. &
       modulo(transfer(subset_ptr,0_c_intptr_t),4_c_intptr_t)/=0) call refuse_port(6)
    spectrum_address=transfer(spectrum_ptr,0_c_intptr_t)
    first_output=transfer(beta0_ptr,0_c_intptr_t)
    second_output=transfer(beta1_ptr,0_c_intptr_t)
    if(modulo(spectrum_address,8_c_intptr_t)/=0.or.modulo(first_output,8_c_intptr_t)/=0.or. &
       modulo(second_output,8_c_intptr_t)/=0.or.first_output==second_output) call refuse_port(7)
    call c_f_pointer(n_ptr,n)
    call c_f_pointer(count_ptr,count)
    call c_f_pointer(subset_ptr,subset)
    if(n<1.or.n>4096.or.subset<0.or.subset>=n) call refuse_port(8)
    if(int(count,int64)/=int(n+1,int64)*int(n+2,int64)) call refuse_port(9)
    end_address=spectrum_address+8_c_intptr_t*int(count,c_intptr_t)
    if(end_address<spectrum_address.or.first_output>huge(first_output)-8.or. &
       second_output>huge(second_output)-8) call refuse_port(10)
    if((first_output>=spectrum_address.and.first_output<end_address).or. &
       (second_output>=spectrum_address.and.second_output<end_address)) call refuse_port(11)
    call c_f_pointer(spectrum_ptr,spectrum,[count])
    call c_f_pointer(beta0_ptr,beta0)
    call c_f_pointer(beta1_ptr,beta1)
    call fit_spectrum(int(n,int32),int(subset,int32),spectrum,beta0,beta1)
  end subroutine fit_runtime_c

  !> Retain the alternate public ABI name without a second numerical body.
  subroutine fit_compatibility_c(n,count,spectrum,subset,beta0,beta1) &
      bind(C,name="md2asm_runtime_fitspectrum_interface")
    type(c_ptr), value :: n,count,spectrum,subset,beta0,beta1
    call fit_runtime_c(n,count,spectrum,subset,beta0,beta1)
  end subroutine fit_compatibility_c
end module forecast_spectral_packing_fit
