!> Check the full column-water integral against Fortran and hydrostatic mass.
!! Arrays use 64-bit values in Fortran order. Only active output columns change.
!! Fractions use kg/kg, pressure uses Pa, gravity uses m/s² and water uses kg/m².
program verify_gppwc
  use iso_c_binding, only : c_int64_t,c_double
  use, intrinsic :: ieee_arithmetic, only : ieee_is_finite
  use parkind1, only : jpim,jprb
  use yomcst, only : setup_constants,rg
  use yomdyncore, only : rplradi,rcorioi,lape,rplrg
  use yomlun, only : nulnam,nulout
  use yomhook, only : lhook
  implicit none
  abstract interface
    subroutine kernel(np,ks,kp,nl,w,q,p)
      use parkind1, only : jpim,jprb
      integer(jpim),intent(in) :: np,ks,kp,nl
      real(jprb),intent(out) :: w(np,0:nl)
      real(jprb),intent(in) :: q(np,nl),p(np,0:nl)
    end subroutine
  end interface
  interface
    function openifs_fpcr() bind(c) result(value)
      import c_int64_t
      integer(c_int64_t) :: value
    end function
    subroutine gppwc_guard(assembly,reference) bind(c)
      import c_double
      real(c_double),intent(out) :: assembly(2),reference(2)
    end subroutine
  end interface
  procedure(kernel) :: gppwc,gppwc_assembly
  integer(jpim),parameter :: shapes(4,12)=reshape([1,1,1,0, 1,1,1,1, 1,1,1,19, 7,2,6,5, &
       9,1,9,19, 13,13,13,20, 3,2,1,7, 2,1,2,1, 5,1,5,3, 3,1,3,4, 7,1,7,4, 3,1,3,19],[4,12])
  real(jprb),allocatable,target :: qraw(:),praw(:),araw(:),rraw(:)
  real(jprb),pointer :: q(:,:),p(:,:),a(:,:),r(:,:)
  integer(c_int64_t),allocatable :: q_before(:),p_before(:)
  real(jprb) :: tail_a(2),tail_r(2),expected,tolerance,value
  integer(c_int64_t) :: abits,rbits,fpcr,bytes=0
  integer(jpim) :: c,np,ks,kp,nl,nq,nw,i,j,k,fa,fr,ios
  character(512) :: argument
  lhook=.false.
  rplradi=1.0_jprb
  rcorioi=1.0_jprb
  rplrg=1.0_jprb
  lape=.false.
  nulout=6
  open(unit=nulnam,status='scratch',form='formatted')
  write(nulnam,'(a)') '&NAMSCEN /'
  rewind(nulnam)
  call setup_constants(nulout,0)
  close(nulnam)
  fpcr=openifs_fpcr()
  if(iand(fpcr,int(z'03C80000',c_int64_t))/=0) error stop 'FPCR rounding or underflow'
  call get_command_argument(1,argument)
  open(newunit=fa,file=trim(argument),access='stream',form='unformatted',status='replace',iostat=ios)
  if(ios/=0) error stop 'assembly output open'
  call get_command_argument(2,argument)
  open(newunit=fr,file=trim(argument),access='stream',form='unformatted',status='replace',iostat=ios)
  if(ios/=0) error stop 'reference output open'
  do c=1,12
    np=shapes(1,c)
    ks=shapes(2,c)
    kp=shapes(3,c)
    nl=shapes(4,c)
    nq=np*nl
    nw=np*(nl+1)
    allocate(qraw(nq+2),praw(nw+2),araw(nw+2),rraw(nw+2),q_before(nq+2),p_before(nw+2))
    q(1:np,1:nl)=>qraw(2:nq+1)
    p(1:np,0:nl)=>praw(2:nw+1)
    a(1:np,0:nl)=>araw(2:nw+1)
    r(1:np,0:nl)=>rraw(2:nw+1)
    qraw=-huge(1.0_jprb)
    praw=-huge(1.0_jprb)
    araw=-777.75_jprb
    rraw=-777.75_jprb
    do j=0,nl
      do i=1,np
        p(i,j)=256.0_jprb*j*(j+1)*(1.0_jprb+real(i,jprb)/1024.0_jprb)
        if(c==9) p(i,j)=1024.0_jprb
      end do
    end do
    do j=1,nl
      do i=1,np
        value=real(mod(i*17+j*11,29)+1,jprb)/4096.0_jprb
        if(c<=2) value=0.0_jprb
        if(c==3.or.c==4) value=0.125_jprb
        if(c==8) value=1.0_jprb
        if(c==9) value=-0.0_jprb
        if(c==10) value=transfer(1_c_int64_t,value)
        if(c==11) value=-0.125_jprb
        if(c==12) value=real(mod(i*j,7)-3,jprb)/1024.0_jprb
        q(i,j)=value
      end do
    end do
    q_before=transfer(qraw,q_before)
    p_before=transfer(praw,p_before)
    call gppwc(np,ks,kp,nl,r,q,p)
    call gppwc_assembly(np,ks,kp,nl,a,q,p)
    do k=1,nw+2
      abits=transfer(araw(k),abits)
      rbits=transfer(rraw(k),rbits)
      if(abits/=rbits) then
        write(*,'(a,2(i0,1x),2(z16.16,1x))') 'Mismatch GPPWC case cell ',c,k,abits,rbits
        error stop 'different column-water bytes'
      end if
      if(k==1.or.k==nw+2) then
        if(abits/=transfer(-777.75_jprb,abits)) error stop 'changed output guard'
      else if(mod(k-2,np)+1<ks.or.mod(k-2,np)+1>kp) then
        if(abits/=transfer(-777.75_jprb,abits)) error stop 'changed inactive output'
      end if
    end do
    if(any(transfer(qraw,q_before)/=q_before)) error stop 'changed fraction input'
    if(any(transfer(praw,p_before)/=p_before)) error stop 'changed pressure input'
    do i=ks,kp
      if(transfer(a(i,0),abits)/=0_c_int64_t) error stop 'nonzero top water'
      do j=1,nl
        expected=sum(q(i,1:j)*(p(i,1:j)-p(i,0:j-1)))/rg
        tolerance=64*epsilon(1.0_jprb)*max(1.0_jprb,abs(expected))*j
        if(.not.ieee_is_finite(a(i,j)).or.abs(a(i,j)-expected)>tolerance) error stop 'independent column mass'
        if(q(i,j)>=0.and.a(i,j)<a(i,j-1)) error stop 'negative water increment'
        if(q(i,j)<0.and.a(i,j)>a(i,j-1)) error stop 'positive signed-correction increment'
      end do
    end do
    write(fa) araw
    write(fr) rraw
    bytes=bytes+int((nw+2)*8,c_int64_t)
    deallocate(qraw,praw,araw,rraw,q_before,p_before)
  end do
  call gppwc_guard(tail_a,tail_r)
  expected=0.5_jprb*8192.0_jprb/rg
  if(abs(tail_a(2)-expected)>8*epsilon(1.0_jprb)*abs(expected)) error stop 'protected-tail physical mass'
  write(fa) tail_a
  write(fr) tail_r
  bytes=bytes+16
  if(openifs_fpcr()/=fpcr) error stop 'changed FPCR'
  close(fa)
  close(fr)
  write(*,'(a,i0,a,z16.16,a,z16.16)') 'GPPWC PASS cases=13 bytes=',bytes, &
       ' differing_bytes=0 FPCR=',fpcr,' RG=',transfer(rg,abits)
end program
