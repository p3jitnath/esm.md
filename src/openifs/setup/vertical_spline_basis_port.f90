module vertical_spline_basis_port
  use iso_c_binding, only : c_int,c_double
  use ieee_arithmetic, only : ieee_is_finite
  implicit none
  private
  public :: evaluate_spline_basis
contains
  integer(c_int) function evaluate_spline_basis(order,value,basis_count,knots,weights) result(status) &
      bind(C,name="md2asm_vertical_spline_basis_fortran")
    !! Evaluate dimensionless spline weights with increasing-index recurrence.
    !! The caller owns disjoint contiguous FP64 knot and output arrays.
    !! Inputs remain unchanged and return two leaves every output word unchanged.
    integer(c_int), intent(in) :: order,basis_count
    real(c_double), intent(in) :: value,knots(basis_count+order)
    real(c_double), intent(inout) :: weights(basis_count)
    real(c_double) :: work(143),left,right,numerator,denominator,part,endpoint
    integer :: i,j,total,run
    status=2
    if(order<2.or.order>4.or.basis_count<order) return
    if(basis_count>24) then
      if(order/=4.or.(basis_count/=139.and.basis_count/=140)) return
    end if
    if(.not.ieee_is_finite(value)) return
    total=basis_count+order
    run=0
    do i=1,total
      if(.not.ieee_is_finite(knots(i))) return
      if(knots(i)<0.0_c_double.or.knots(i)>1.0_c_double) return
      if(i<=order.and.knots(i)/=0.0_c_double) return
      if(i>basis_count.and.knots(i)/=1.0_c_double) return
      if(i==1) then
        run=1
      else
        if(knots(i)<knots(i-1)) return
        if(knots(i)==knots(i-1)) then
          run=run+1
          if(run>order) return
        else
          run=1
        end if
      end if
    end do
    do i=1,total-1
      work(i)=0.0_c_double
      if(value>=knots(i).and.value<knots(i+1)) work(i)=1.0_c_double
    end do
    do j=2,order
      do i=1,total-j
        left=0.0_c_double
        if(work(i)/=0.0_c_double) then
          numerator=value-knots(i)
          numerator=numerator*work(i)
          denominator=knots(i+j-1)-knots(i)
          left=numerator/denominator
        end if
        right=0.0_c_double
        if(work(i+1)/=0.0_c_double) then
          numerator=knots(i+j)-value
          numerator=numerator*work(i+1)
          denominator=knots(i+j)-knots(i+1)
          right=numerator/denominator
        end if
        work(i)=left+right
      end do
    end do
    endpoint=value-1.0_c_double
    endpoint=abs(endpoint)
    if(endpoint<tiny(1.0_c_double)) then
      do i=1,basis_count-1
        weights(i)=0.0_c_double
      end do
      weights(basis_count)=1.0_c_double
    else
      do i=1,basis_count
        weights(i)=work(i)
      end do
    end if
    status=0
  end function
end module
