module vertical_spline_interpolation_port
  use iso_c_binding, only : c_int,c_double,c_int64_t
  use ieee_arithmetic, only : ieee_is_finite
  implicit none
  private
  public :: spline_interpolation_owners,build_vertical_spline_interpolation
  public :: initialize_vertical_spline_interpolation,release_vertical_spline_interpolation
  type :: spline_interpolation_owners
    !! Owned dimensionless tables for vertical cubic interpolation.
    real(c_double), allocatable :: tridiagonal(:,:),constants(:),pieces(:,:,:)
  end type
contains
  recursive integer(c_int) function build_vertical_spline_interpolation(n,eta_full,eta_half,tridiagonal,constants,pieces) &
      result(status) bind(C,name="md2asm_build_vertical_spline_interpolation_fortran")
    !! Fill three complete arrays from dimensionless full and half coordinates.
    !! Full coordinates have bounds 0:n+1 and half coordinates have bounds 0:n.
    !! All arrays are contiguous and disjoint. Inputs remain unchanged.
    !! Return two rejects metadata or coordinates before any output mutation.
    integer(c_int), value :: n
    real(c_double), intent(in) :: eta_full(0:n+1),eta_half(0:n)
    real(c_double), intent(inout) :: tridiagonal(n,-1:1),constants(10),pieces(4,-1:n+2,4)
    real(c_double) :: delta(-3:259),sample(257,257)
    real(c_double) :: d1,d2,d3,d4,q1,q2,q3,q4,a13,a14,a21,a22,a23,a24,a41,a42
    real(c_double) :: b11,b12,b21,b22,rhs1,rhs2,det,c1,c2,c3,c4
    real(c_double) :: aa2,bb2,cc2,aa3,bb3,cc3,t,u,v,height
    integer :: i,k,dim
    status=2
    if(n<2.or.n>255) return
    if(.not.coordinates_admissible(n,eta_full,eta_half)) return
    t=eta_full(1)-eta_half(0)
    delta(0)=2.0_c_double*t
    delta(-3)=delta(0)
    delta(-2)=delta(0)
    delta(-1)=delta(0)
    do i=1,n-1
      delta(i)=eta_full(i+1)-eta_full(i)
    end do
    t=eta_half(n)-eta_full(n)
    delta(n)=2.0_c_double*t
    do i=n+1,n+4
      delta(i)=delta(n)
    end do
    pieces=0.0_c_double
    ! The exact FP64 value is 4/6 rounded once, rather than an integer conversion.
    height=transfer(int(z'3fe5555555555555',kind=c_int64_t),height)
    do k=-1,n+2
      d1=delta(k-2)
      d2=delta(k-1)
      d3=delta(k)
      d4=delta(k+1)
      q3=d3*d3
      a13=q3*d3
      q4=d4*d4
      a14=q4*d4
      t=3.0_c_double*d3
      t=t*q4
      a14=a14+t
      t=3.0_c_double*q3
      t=t*d4
      a14=a14+t
      q1=d1*d1
      t=2.0_c_double*d1
      t=t*d2
      a21=q1+t
      q2=d2*d2
      a22=q2
      a23=q3
      t=2.0_c_double*d3
      t=t*d4
      a24=q4+t
      a41=q1*d1
      t=3.0_c_double*q1
      t=t*d2
      a41=a41+t
      t=3.0_c_double*d1
      t=t*q2
      a41=a41+t
      a42=q2*d2
      t=a21*a42
      t=t/a41
      b11=a22-t
      t=a24*a13
      t=t/a14
      b12=a23-t
      t=d1*a42
      t=t/a41
      b21=d2-t
      t=-d4
      t=t*a13
      t=t/a14
      b22=-d3-t
      t=a21/a41
      u=a24/a14
      t=t+u
      u=-height
      rhs1=u*t
      t=d1/a41
      u=-d4
      u=u/a14
      t=t+u
      u=-height
      rhs2=u*t
      t=b11*b22
      u=b12*b21
      det=t-u
      t=rhs1*b22
      u=rhs2*b12
      t=t-u
      c2=t/det
      t=rhs2*b11
      u=rhs1*b21
      t=t-u
      c3=t/det
      t=a42*c2
      t=height-t
      c1=t/a41
      t=a13*c3
      t=height-t
      c4=t/a14
      t=q1*d1
      aa2=t*c1
      t=3.0_c_double*q1
      bb2=t*c1
      t=3.0_c_double*d1
      cc2=t*c1
      t=q4*d4
      aa3=t*c4
      t=3.0_c_double*q4
      bb3=t*c4
      t=3.0_c_double*d4
      cc3=t*c4
      pieces(1,k,4)=c1
      pieces(2,k,1)=aa2
      pieces(2,k,2)=bb2
      pieces(2,k,3)=cc2
      pieces(2,k,4)=c2
      t=bb3*d3
      t=aa3+t
      u=cc3*q3
      t=t+u
      v=q3*d3
      u=c3*v
      pieces(3,k,1)=t+u
      t=2.0_c_double*cc3
      t=t*d3
      u=-bb3
      u=u-t
      t=3.0_c_double*c3
      t=t*q3
      pieces(3,k,2)=u-t
      t=3.0_c_double*c3
      t=t*d3
      pieces(3,k,3)=cc3+t
      pieces(3,k,4)=-c3
      t=q4*d4
      pieces(4,k,1)=c4*t
      t=-3.0_c_double*c4
      pieces(4,k,2)=t*q4
      t=3.0_c_double*c4
      pieces(4,k,3)=t*d4
      pieces(4,k,4)=-c4
    end do
    sample=0.0_c_double
    dim=n+2
    do i=2,dim-1
      sample(i,i-1)=pieces(4,i-2,1)
      sample(i,i)=pieces(3,i-1,1)
      sample(i,i+1)=pieces(2,i,1)
    end do
    sample(1,1)=2.0_c_double*pieces(4,0,3)
    sample(1,2)=2.0_c_double*pieces(3,1,3)
    sample(1,3)=2.0_c_double*pieces(2,2,3)
    sample(dim,dim-2)=2.0_c_double*pieces(4,n-1,3)
    sample(dim,dim-1)=2.0_c_double*pieces(3,n,3)
    sample(dim,dim)=2.0_c_double*pieces(2,n+1,3)
    tridiagonal=0.0_c_double
    t=sample(2,1)*sample(1,2)
    t=t/sample(1,1)
    tridiagonal(1,0)=sample(2,2)-t
    t=sample(n+1,n+2)*sample(n+2,n+1)
    t=t/sample(n+2,n+2)
    tridiagonal(n,0)=sample(n+1,n+1)-t
    t=sample(n+1,n+2)*sample(n+2,n)
    t=t/sample(n+2,n+2)
    tridiagonal(n,-1)=sample(n+1,n)-t
    t=sample(2,1)*sample(1,3)
    t=t/sample(1,1)
    tridiagonal(1,1)=sample(2,3)-t
    do i=2,n-1
      tridiagonal(i,-1)=sample(i+1,i)
      tridiagonal(i,0)=sample(i+1,i+1)
      tridiagonal(i,1)=sample(i+1,i+2)
    end do
    constants(1)=1.0_c_double/sample(1,1)
    t=-sample(1,2)
    constants(2)=t/sample(1,1)
    t=-sample(1,3)
    constants(3)=t/sample(1,1)
    t=-sample(2,1)
    constants(4)=t/sample(1,1)
    constants(5)=1.0_c_double/sample(n+2,n+2)
    t=-sample(n+2,n)
    constants(6)=t/sample(n+2,n+2)
    t=-sample(n+2,n+1)
    constants(7)=t/sample(n+2,n+2)
    t=-sample(n+1,n+2)
    constants(8)=t/sample(n+2,n+2)
    t=eta_full(2)-eta_full(1)
    constants(9)=1.0_c_double/t
    t=eta_full(n)-eta_full(n-1)
    constants(10)=1.0_c_double/t
    status=0
  end function

  integer(c_int) function initialize_vertical_spline_interpolation(n,eta_full,eta_half,owners) result(status)
    !! Allocate and publish all three tables together after their calculation.
    integer(c_int), intent(in) :: n
    real(c_double), intent(in) :: eta_full(0:n+1),eta_half(0:n)
    type(spline_interpolation_owners), intent(inout) :: owners
    type(spline_interpolation_owners) :: work
    integer :: allocation_status
    status=2
    if(n<2.or.n>255) return
    if(allocated(owners%tridiagonal).or.allocated(owners%constants).or.allocated(owners%pieces)) return
    if(.not.coordinates_admissible(n,eta_full,eta_half)) return
    allocate(work%tridiagonal(n,-1:1),stat=allocation_status)
    if(allocation_status/=0) then
      status=1
      return
    end if
    allocate(work%constants(10),stat=allocation_status)
    if(allocation_status/=0) then
      status=1
      return
    end if
    allocate(work%pieces(4,-1:n+2,4),stat=allocation_status)
    if(allocation_status/=0) then
      status=1
      return
    end if
    status=build_vertical_spline_interpolation(n,eta_full,eta_half,work%tridiagonal,work%constants,work%pieces)
    if(status/=0) return
    call move_alloc(work%tridiagonal,owners%tridiagonal)
    call move_alloc(work%constants,owners%constants)
    call move_alloc(work%pieces,owners%pieces)
  end function

  logical function coordinates_admissible(n,eta_full,eta_half) result(valid)
    integer(c_int), intent(in) :: n
    real(c_double), intent(in) :: eta_full(0:n+1),eta_half(0:n)
    integer :: i
    valid=.false.
    do i=0,n+1
      if(.not.ieee_is_finite(eta_full(i))) return
      if(i>0) then
        if(eta_full(i)<=eta_full(i-1)) return
      end if
    end do
    do i=0,n
      if(.not.ieee_is_finite(eta_half(i))) return
      if(i>0) then
        if(eta_half(i)<=eta_half(i-1)) return
      end if
    end do
    if(eta_full(1)<=eta_half(0).or.eta_half(n)<=eta_full(n)) return
    valid=.true.
  end function

  subroutine release_vertical_spline_interpolation(owners)
    !! Release each complete owned table in reverse construction order.
    type(spline_interpolation_owners), intent(inout) :: owners
    if(allocated(owners%pieces)) deallocate(owners%pieces)
    if(allocated(owners%constants)) deallocate(owners%constants)
    if(allocated(owners%tridiagonal)) deallocate(owners%tridiagonal)
  end subroutine
end module
