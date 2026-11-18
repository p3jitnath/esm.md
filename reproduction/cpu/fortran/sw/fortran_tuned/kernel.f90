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
      !$omp simd
      do i=0,nx+1
        q(i,0,a)=q(i,ny,a)
        q(i,ny+1,a)=q(i,1,a)
      end do
    end do
  end subroutine

  !> Evaluate D03 into reusable flux and wave-speed storage.
  subroutine prepare(nx, ny, q, work, g, firstrow, lastrow)
    integer, intent(in) :: nx, ny, firstrow, lastrow
    real(c_double), intent(in) :: q(0:nx+1,0:ny+1,3), g
    real(c_double), intent(inout) :: work(0:nx+1,0:ny+1,5)
    real(c_double) :: h, mx, my, u, v, z, c, p
    integer :: i,j
    do j=firstrow,lastrow
      !$omp simd
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

  !> Evaluate one ordered D04 face using its rounded half speed bound.
  pure real(c_double) function face(ql,qr,fl,fr,halfalpha)
    real(c_double), intent(in) :: ql,qr,fl,fr,halfalpha
    face=(fl+fr)*0.5_c_double-halfalpha*(qr-ql)
  end function

  !> Apply the rounded divergence and time update to cached face values.
  pure real(c_double) function cell(east,west,north,south,qc,base,xscale,yscale,dt,final,scaled)
    real(c_double), intent(in) :: east,west,north,south,qc,base,xscale,yscale,dt
    logical, intent(in) :: final,scaled
    real(c_double) :: dx,dy,ell,e
    if(scaled) then
      dx=(east-west)*xscale; dy=(north-south)*yscale
    else
      dx=(east-west)/xscale; dy=(north-south)/yscale
    end if
    ell=-(dx+dy); e=qc+dt*ell
    if(final) then
      cell=base*0.5_c_double+e*0.5_c_double
    else
      cell=e
    end if
  end function

  !> Cache each D04 face once, using scratch rows and output halos until BC01.
  subroutine update(nx,ny,q,base,out,work,par,final)
    integer, intent(in) :: nx,ny
    real(c_double), intent(in) :: q(0:nx+1,0:ny+1,3),base(0:nx+1,0:ny+1,3),par(4)
    real(c_double), intent(inout) :: work(0:nx+1,0:ny+1,5)
    real(c_double), intent(out) :: out(0:nx+1,0:ny+1,3)
    logical, intent(in) :: final
    real(c_double) :: aw,ae,an,ass,east,north,south,xscale,yscale
    real(c_double) :: h,mx,my,u,v,z,c,p,ax,ay,cross,sxn,syn
    logical :: scaled,first,ring
    integer :: i,j,a,r,rn,rf,rs
    scaled=fraction(par(2))==0.5_c_double .and. fraction(par(3))==0.5_c_double .and. &
           par(2)>=tiny(par(2)) .and. par(3)>=tiny(par(3))
    xscale=par(2); yscale=par(3)
    if(scaled) then
      xscale=1.0_c_double/par(2); yscale=1.0_c_double/par(3)
    end if
    call prepare(nx,ny,q,work,par(1),0,1)
    ring=nx>=128 .and. ny>=3
    do j=1,ny
      if(ring) then
        r=mod(j,3); rn=mod(j+1,3); rf=3+mod(j,2); rs=3+mod(j-1,2)
      else
        r=j; rn=j+1; rf=j-1; rs=j-2
      end if
      first=j==1
      aw=max(work(0,r,4),work(1,r,4))*0.5_c_double
      out(0,ny+1,1)=face(q(0,j,1),q(1,j,1),q(0,j,2),q(1,j,2),aw)
      out(0,ny+1,2)=face(q(0,j,2),q(1,j,2),work(0,r,1),work(1,r,1),aw)
      out(0,ny+1,3)=face(q(0,j,3),q(1,j,3),work(0,r,2),work(1,r,2),aw)
      !$omp simd
      do i=1,nx
        h=q(i,j+1,1); mx=q(i,j+1,2); my=q(i,j+1,3)
        u=mx/h; v=my/h; z=par(1)*h; c=sqrt(z); p=(z*h)*0.5_c_double
        ax=mx*u+p; cross=mx*v; ay=my*v+p
        sxn=abs(u)+c; syn=abs(v)+c
        work(i,rn,1)=ax; work(i,rn,2)=cross; work(i,rn,3)=ay
        work(i,rn,4)=sxn; work(i,rn,5)=syn
        ae=max(work(i,r,4),work(i+1,r,4))*0.5_c_double
        an=max(work(i,r,5),syn)*0.5_c_double
        ass=0.0_c_double
        if(first) ass=max(work(i,0,5),work(i,r,5))*0.5_c_double
        east=face(q(i,j,1),q(i+1,j,1),q(i,j,2),q(i+1,j,2),ae)
        north=face(q(i,j,1),h,q(i,j,3),my,an)
        if(first) out(i,0,1)=face(q(i,j-1,1),q(i,j,1),q(i,j-1,3),q(i,j,3),ass)
        out(i,ny+1,1)=east; work(i,rf,1)=north
        east=face(q(i,j,2),q(i+1,j,2),work(i,r,1),work(i+1,r,1),ae)
        north=face(q(i,j,2),mx,work(i,r,2),cross,an)
        if(first) out(i,0,2)=face(q(i,j-1,2),q(i,j,2),work(i,0,2),work(i,r,2),ass)
        out(i,ny+1,2)=east; work(i,rf,2)=north
        east=face(q(i,j,3),q(i+1,j,3),work(i,r,2),work(i+1,r,2),ae)
        north=face(q(i,j,3),my,work(i,r,3),ay,an)
        if(first) out(i,0,3)=face(q(i,j-1,3),q(i,j,3),work(i,0,3),work(i,r,3),ass)
        out(i,ny+1,3)=east; work(i,rf,3)=north
      end do
      do a=1,3
        !$omp simd
        do i=1,nx
          if(first) then
            south=out(i,0,a)
          else
            south=work(i,rs,a)
          end if
          out(i,j,a)=cell(out(i,ny+1,a),out(i-1,ny+1,a),work(i,rf,a),south, &
                          q(i,j,a),base(i,j,a),xscale,yscale,par(4),final,scaled)
        end do
      end do
      do a=1,5
        work(0,rn,a)=work(nx,rn,a)
        work(nx+1,rn,a)=work(1,rn,a)
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
    call update(nx,ny,q,q,stage,work,par,.false.)
    call halo(nx,ny,stage)
    call update(nx,ny,stage,q,out,work,par,.true.)
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
