!> Implement the complete annual-mean SSPRK2 operation in budyko_sellers.md.
!! Temperatures are Celsius; coeff stores K,W,I and par stores C,dt,delta,A,B,Tf.
module budyko_sellers
  use, intrinsic :: iso_c_binding, only: c_int,c_double
  implicit none
  private
  public :: eb_step,eb_run
contains
  !> Copy the two pole ghosts, preserving the interior and all sign bits.
  subroutine halo(n,q)
    integer, intent(in) :: n
    real(c_double), intent(inout) :: q(0:n+1)
    q(0)=q(1); q(n+1)=q(n)
  end subroutine

  !> Use unique cached faces on small grids and fused evaluations on larger grids.
  subroutine update(n,q,base,out,work,coeff,par,beta,scale,scaled,final)
    integer, intent(in) :: n
    real(c_double), intent(in) :: q(0:n+1),base(0:n+1),coeff(0:n+1,3),par(6)
    real(c_double), intent(out) :: out(0:n+1),work(0:n+1)
    logical, intent(in) :: final
    real(c_double), intent(in) :: beta,scale
    logical, intent(in) :: scaled
    real(c_double) :: forcing,r,ell,e,east,west
    integer :: i
    if(n<512) then
      work(0)=0.0_c_double; work(n)=0.0_c_double
      !$omp simd
      do i=1,n-1
        work(i)=coeff(i,1)*(q(i+1)-q(i))
      end do
      !$omp simd
      do i=1,n
        forcing=coeff(i,2)
        if(q(i)<=par(6)) forcing=coeff(i,3)
        r=forcing-(par(4)+par(5)*q(i))
        if(scaled) then
          ell=r+(work(i)-work(i-1))*scale
        else
          ell=r+(work(i)-work(i-1))/scale
        end if
        e=q(i)+beta*ell
        if(final) then
          out(i)=base(i)*0.5_c_double+e*0.5_c_double
        else
          out(i)=e
        end if
      end do
      return
    end if
    !$omp simd
    do i=1,n
      east=coeff(i,1)*(q(i+1)-q(i))
      west=coeff(i-1,1)*(q(i)-q(i-1))
      forcing=coeff(i,2)
      if(q(i)<=par(6)) forcing=coeff(i,3)
      r=forcing-(par(4)+par(5)*q(i))
      if(scaled) then
        ell=r+(east-west)*scale
      else
        ell=r+(east-west)/scale
      end if
      e=q(i)+beta*ell
      if(final) then
        out(i)=base(i)*0.5_c_double+e*0.5_c_double
      else
        out(i)=e
      end if
    end do
  end subroutine

  !> Return both stages using disjoint contiguous state and scratch buffers.
  !! n is the interior length; input q's interior, coeff, and par remain unchanged.
  subroutine eb_step(n,q,stage,out,work,coeff,par) bind(C,name='eb_step')
    integer(c_int), value :: n
    real(c_double), intent(inout) :: q(0:n+1)
    real(c_double), intent(out) :: stage(0:n+1),out(0:n+1),work(0:n+1)
    real(c_double), intent(in) :: coeff(0:n+1,3),par(6)
    real(c_double) :: beta,scale
    logical :: scaled
    call prepare(par,beta,scale,scaled)
    call complete(n,q,stage,out,work,coeff,par,beta,scale,scaled)
  end subroutine

  !> Reuse identical rounded coefficients while par remains immutable.
  subroutine prepare(par,beta,scale,scaled)
    real(c_double), intent(in) :: par(6)
    real(c_double), intent(out) :: beta,scale
    logical, intent(out) :: scaled
    beta=par(2)/par(1)
    scaled=fraction(par(3))==0.5_c_double .and. par(3)>=tiny(par(3))
    scale=par(3)
    if(scaled) scale=1.0_c_double/par(3)
  end subroutine

  !> Evaluate complete stages using coefficients rounded by prepare.
  subroutine complete(n,q,stage,out,work,coeff,par,beta,scale,scaled)
    integer, intent(in) :: n
    real(c_double), intent(inout) :: q(0:n+1)
    real(c_double), intent(out) :: stage(0:n+1),out(0:n+1),work(0:n+1)
    real(c_double), intent(in) :: coeff(0:n+1,3),par(6),beta,scale
    logical, intent(in) :: scaled
    call halo(n,q)
    call update(n,q,q,stage,work,coeff,par,beta,scale,scaled,.false.)
    call halo(n,stage)
    call update(n,stage,q,out,work,coeff,par,beta,scale,scaled,.true.)
    call halo(n,out)
  end subroutine

  !> Run complete steps, returning an odd-count state in out and an even-count state in q.
  subroutine eb_run(n,q,stage,out,work,coeff,par,nsteps) bind(C,name='eb_run')
    integer(c_int), value :: n,nsteps
    real(c_double), intent(inout) :: q(0:n+1),out(0:n+1)
    real(c_double), intent(out) :: stage(0:n+1),work(0:n+1)
    real(c_double), intent(in) :: coeff(0:n+1,3),par(6)
    integer :: k
    real(c_double) :: beta,scale
    logical :: scaled
    if(nsteps==0) return
    call prepare(par,beta,scale,scaled)
    do k=1,nsteps,2
      call complete(n,q,stage,out,work,coeff,par,beta,scale,scaled)
      if(k<nsteps) call complete(n,out,stage,q,work,coeff,par,beta,scale,scaled)
    end do
  end subroutine
end module
