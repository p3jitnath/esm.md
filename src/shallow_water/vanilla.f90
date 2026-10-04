!> Implement the complete periodic SSPRK2 step in the Markdown formulation.
!! Arrays use x-contiguous binary64 storage; q's interior is preserved by
!! sw_step, while its halos may change. Every buffer must have disjoint storage.
module shallow_water
  use, intrinsic :: iso_c_binding, only: c_int, c_double
  implicit none
  private
  public :: sw_step, sw_run
contains
  !> Copy all periodic faces and corners without changing interior values.
  subroutine halo(nx, ny, q)
    integer, intent(in) :: nx, ny
    real(c_double), intent(inout) :: q(0:nx+1,0:ny+1,3)
    integer :: a, i, j
    do a=1,3
      do j=1,ny
        q(0,j,a)=q(nx,j,a)
        q(nx+1,j,a)=q(1,j,a)
      end do
      do i=0,nx+1
        q(i,0,a)=q(i,ny,a)
        q(i,ny+1,a)=q(i,1,a)
      end do
    end do
  end subroutine

  !> Evaluate D03 into reusable flux and wave-speed storage.
  subroutine prepare(nx, ny, q, work, g)
    integer, intent(in) :: nx, ny
    real(c_double), intent(in) :: q(0:nx+1,0:ny+1,3), g
    real(c_double), intent(out) :: work(0:nx+1,0:ny+1,5)
    real(c_double) :: h, mx, my, u, v, z, c, p
    integer :: i,j
    do j=0,ny+1
      do i=0,nx+1
        h=q(i,j,1); mx=q(i,j,2); my=q(i,j,3)
        u=mx/h; v=my/h; z=g*h; c=sqrt(z); p=(z*h)*0.5_c_double
        work(i,j,1)=mx*u+p
        work(i,j,2)=mx*v
        work(i,j,3)=my*v+p
        work(i,j,4)=abs(u)+c
        work(i,j,5)=abs(v)+c
      end do
    end do
  end subroutine

  !> Evaluate one D04 face with contraction and reassociation disabled.
  pure real(c_double) function face(ql,qr,fl,fr,alpha)
    real(c_double), intent(in) :: ql,qr,fl,fr,alpha
    real(c_double) :: central, jump, dissipative
    central=(fl+fr)*0.5_c_double
    jump=qr-ql
    dissipative=(alpha*0.5_c_double)*jump
    face=central-dissipative
  end function

  !> Apply D04 for one state component, preserving every rounding point.
  subroutine component(nx,ny,q,base,out,fx,fy,sx,sy,par,final)
    integer, intent(in) :: nx,ny
    real(c_double), intent(in) :: q(0:nx+1,0:ny+1), base(0:nx+1,0:ny+1)
    real(c_double), intent(in) :: fx(0:nx+1,0:ny+1),fy(0:nx+1,0:ny+1)
    real(c_double), intent(in) :: sx(0:nx+1,0:ny+1),sy(0:nx+1,0:ny+1),par(4)
    real(c_double), intent(out) :: out(0:nx+1,0:ny+1)
    logical, intent(in) :: final
    real(c_double) :: east,west,north,south,dx,dy,ell,e
    integer :: i,j
    do j=1,ny
      do i=1,nx
        east=face(q(i,j),q(i+1,j),fx(i,j),fx(i+1,j),max(sx(i,j),sx(i+1,j)))
        west=face(q(i-1,j),q(i,j),fx(i-1,j),fx(i,j),max(sx(i-1,j),sx(i,j)))
        north=face(q(i,j),q(i,j+1),fy(i,j),fy(i,j+1),max(sy(i,j),sy(i,j+1)))
        south=face(q(i,j-1),q(i,j),fy(i,j-1),fy(i,j),max(sy(i,j-1),sy(i,j)))
        dx=(east-west)/par(2); dy=(north-south)/par(3)
        ell=-(dx+dy); e=q(i,j)+par(4)*ell
        if(final) then
          out(i,j)=base(i,j)*0.5_c_double+e*0.5_c_double
        else
          out(i,j)=e
        end if
      end do
    end do
  end subroutine

  !> Return the first stage and complete step under T01 and BC01.
  !! nx and ny are interior dimensions. q, stage, and out contain 3 fields;
  !! work contains 5 fields. par contains g, dx, dy, dt in SI units.
  subroutine sw_step(nx,ny,q,stage,out,work,par) bind(C,name='sw_step')
    integer(c_int), value :: nx,ny
    real(c_double), intent(inout) :: q(0:nx+1,0:ny+1,3)
    real(c_double), intent(out) :: stage(0:nx+1,0:ny+1,3),out(0:nx+1,0:ny+1,3)
    real(c_double), intent(out) :: work(0:nx+1,0:ny+1,5)
    real(c_double), intent(in) :: par(4)
    call halo(nx,ny,q)
    call prepare(nx,ny,q,work,par(1))
    call component(nx,ny,q(:,:,1),q(:,:,1),stage(:,:,1),q(:,:,2),q(:,:,3), &
                   work(:,:,4),work(:,:,5),par,.false.)
    call component(nx,ny,q(:,:,2),q(:,:,2),stage(:,:,2),work(:,:,1),work(:,:,2), &
                   work(:,:,4),work(:,:,5),par,.false.)
    call component(nx,ny,q(:,:,3),q(:,:,3),stage(:,:,3),work(:,:,2),work(:,:,3), &
                   work(:,:,4),work(:,:,5),par,.false.)
    call halo(nx,ny,stage)
    call prepare(nx,ny,stage,work,par(1))
    call component(nx,ny,stage(:,:,1),q(:,:,1),out(:,:,1),stage(:,:,2),stage(:,:,3), &
                   work(:,:,4),work(:,:,5),par,.true.)
    call component(nx,ny,stage(:,:,2),q(:,:,2),out(:,:,2),work(:,:,1),work(:,:,2), &
                   work(:,:,4),work(:,:,5),par,.true.)
    call component(nx,ny,stage(:,:,3),q(:,:,3),out(:,:,3),work(:,:,2),work(:,:,3), &
                   work(:,:,4),work(:,:,5),par,.true.)
    call halo(nx,ny,out)
  end subroutine

  !> Run nsteps complete updates with alternating state buffers.
  !! The final state is out after an odd count and q after an even count.
  subroutine sw_run(nx,ny,q,stage,out,work,par,nsteps) bind(C,name='sw_run')
    integer(c_int), value :: nx,ny,nsteps
    real(c_double), intent(inout) :: q(0:nx+1,0:ny+1,3),out(0:nx+1,0:ny+1,3)
    real(c_double), intent(out) :: stage(0:nx+1,0:ny+1,3),work(0:nx+1,0:ny+1,5)
    real(c_double), intent(in) :: par(4)
    integer :: n
    do n=1,nsteps,2
      call sw_step(nx,ny,q,stage,out,work,par)
      if(n<nsteps) call sw_step(nx,ny,out,stage,q,work,par)
    end do
  end subroutine
end module
