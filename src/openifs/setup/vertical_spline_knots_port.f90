module vertical_spline_knots_port
  use iso_c_binding, only : c_int,c_double
  use ieee_arithmetic, only : ieee_is_finite
  implicit none
  private
  public :: build_spline_knots
contains
  integer(c_int) function build_spline_knots(order,basis_count,level_count,eta,knots) result(status) &
      bind(C,name="md2asm_vertical_spline_knots_fortran")
    !! Build dimensionless fixed-order spline knots with the retained percentile rule.
    !! Inputs are unchanged. The contiguous output has basis_count+order FP64 words.
    !! Return two leaves the output unchanged. The caller owns disjoint full arrays.
    integer(c_int), intent(in) :: order,basis_count,level_count
    real(c_double), intent(in) :: eta(level_count)
    real(c_double), intent(inout) :: knots(basis_count+order)
    integer :: i,j,interior,total
    real(c_double) :: stretch,denominator,index_value,weight,left,right,part
    status=2
    if(order<2.or.order>4.or.basis_count<order.or.level_count<order) return
    if(basis_count<=24) then
      if(level_count>24) return
    else
      if(order/=4.or.level_count/=139.or.(basis_count/=139.and.basis_count/=140)) return
    end if
    interior=basis_count-order
    if(interior>level_count) return
    do i=1,level_count
      if(.not.ieee_is_finite(eta(i))) return
      if(eta(i)<0.0_c_double.or.eta(i)>1.0_c_double) return
      if(i==1) then
        if(eta(i)/=0.0_c_double) return
      else
        if(eta(i)<=eta(i-1)) return
      end if
    end do
    if(eta(level_count)/=1.0_c_double) return
    total=basis_count+order
    do i=1,order
      knots(i)=0.0_c_double
      knots(total-i+1)=1.0_c_double
    end do
    if(interior==0) then
      status=0
      return
    end if
    stretch=real(level_count,c_double)-2.0_c_double
    stretch=stretch-real(interior,c_double)
    stretch=0.5_c_double*stretch
    denominator=2.0_c_double*stretch
    denominator=real(interior+1,c_double)+denominator
    do i=1,interior
      index_value=real(i,c_double)+stretch
      index_value=index_value/denominator
      index_value=index_value*real(level_count-1,c_double)
      index_value=index_value+1.0_c_double
      j=int(index_value)
      if(eta(j)==0.0_c_double) then
        knots(order+i)=eta(j+1)
      else if(eta(j)==1.0_c_double) then
        knots(order+i)=eta(j-1)
      else
        weight=index_value-real(j,c_double)
        part=1.0_c_double-weight
        left=part*eta(j)
        right=weight*eta(j+1)
        knots(order+i)=left+right
      end if
    end do
    status=0
  end function
end module
