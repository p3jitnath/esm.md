!> Own selected and public-transform latitude geometry through native arrays.
module forecast_latitude_geometry
  use iso_c_binding, only: c_int,c_int64_t,c_double,c_ptr,c_f_pointer
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use forecast_gaussian_latitude_generation, only: initialize_selected_gaussian_latitudes
  implicit none
  private
  public :: native_latitude_geometry,initialize_selected_latitude_geometry
  public :: initialize_public_latitude_geometry,release_latitude_geometry
  !> Nine SULEGA owners and the separate source-unwritten RLATI owner.
  !! rw has physical rows 1:n. Other produced arrays include halo rows
  !! 1-halo:n+halo. Angles use radians; radius-scaled reciprocals use m**(-1).
  !! Other entries and Gaussian weights are dimensionless.
  type :: native_latitude_geometry
    real(c_double),allocatable :: rw(:)
    real(c_double),allocatable :: rmu(:)
    real(c_double),allocatable :: r1mu2(:)
    real(c_double),allocatable :: r1mui(:)
    real(c_double),allocatable :: r1mua(:)
    real(c_double),allocatable :: rsqm2(:)
    real(c_double),allocatable :: r1qm2(:)
    real(c_double),allocatable :: racthe(:)
    real(c_double),allocatable :: rlatig(:)
    real(c_double),allocatable :: rlati(:)
  end type
  interface
    function public_inverse_sine(x) bind(C,name="asin") result(value)
      import c_double
      real(c_double),value :: x
      real(c_double) :: value
    end function
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
#include "trans_inq.h"
contains
  !> Require fresh produced owners while leaving RLATI outside this stage.
  logical function latitude_owners_fresh(state)
    type(native_latitude_geometry),intent(in) :: state
    latitude_owners_fresh=.false.
    if(allocated(state%rw))return
    if(allocated(state%rmu))return
    if(allocated(state%r1mu2))return
    if(allocated(state%r1mui))return
    if(allocated(state%r1mua))return
    if(allocated(state%rsqm2))return
    if(allocated(state%r1qm2))return
    if(allocated(state%racthe))return
    if(allocated(state%rlatig))return
    latitude_owners_fresh=.true.
  end function

  !> Fill physical latitude values in their separately rounded source order.
  subroutine fill_latitude_rows(state,n,radius,mu,phi,square_root_first)
    type(native_latitude_geometry),intent(inout) :: state
    integer(c_int),intent(in) :: n
    real(c_double),intent(in) :: radius,mu(n)
    real(c_double),intent(inout) :: phi(n)
    logical,intent(in) :: square_root_first
    real(c_double) :: squared_cosine,cosine,temporary,inverse_cosine
    integer :: row
    do row=1,n
      temporary=mu(row)*mu(row)
      squared_cosine=1.0_c_double-temporary
      if(square_root_first)cosine=sqrt(squared_cosine)
      phi(row)=public_inverse_sine(mu(row))
      state%r1mu2(row)=squared_cosine
      state%r1mui(row)=1.0_c_double/squared_cosine
      if(.not.square_root_first)then
        cosine=sqrt(squared_cosine)
        inverse_cosine=1.0_c_double/cosine
      end if
      temporary=radius*squared_cosine
      state%r1mua(row)=1.0_c_double/temporary
      state%rsqm2(row)=cosine
      if(square_root_first)inverse_cosine=1.0_c_double/cosine
      state%r1qm2(row)=inverse_cosine
      temporary=radius*cosine
      state%racthe(row)=1.0_c_double/temporary
      state%rlatig(row)=phi(row)
    end do
  end subroutine

  !> Extend the fields by exact copied values and the source pole angles.
  subroutine fill_latitude_halos(state,n,halo,pi,phi)
    type(native_latitude_geometry),intent(inout) :: state
    integer(c_int),intent(in) :: n,halo
    real(c_double),intent(in) :: pi,phi(n)
    integer :: j
    do j=1,halo
      state%rmu(1-j)=state%rmu(j)
      state%r1mu2(1-j)=state%r1mu2(j)
      state%r1mui(1-j)=state%r1mui(j)
      state%r1mua(1-j)=state%r1mua(j)
      state%rsqm2(1-j)=state%rsqm2(j)
      state%r1qm2(1-j)=state%r1qm2(j)
      state%racthe(1-j)=state%racthe(j)
      state%rlatig(1-j)=pi-phi(j)
    end do
    do j=1,halo
      state%rmu(n+j)=state%rmu(n+1-j)
      state%r1mu2(n+j)=state%r1mu2(n+1-j)
      state%r1mui(n+j)=state%r1mui(n+1-j)
      state%r1mua(n+j)=state%r1mua(n+1-j)
      state%rsqm2(n+j)=state%rsqm2(n+1-j)
      state%r1qm2(n+j)=state%r1qm2(n+1-j)
      state%racthe(n+j)=state%racthe(n+1-j)
      state%rlatig(n+j)=-pi-phi(n+1-j)
    end do
  end subroutine

  !> Construct the selected 32-row path from its own Gaussian calculation.
  !! The fixed source route has two halo rows at each pole and radius
  !! 6371229 metres. RLATI stays unchanged on success, refusal and cleanup.
  integer(c_int) function initialize_selected_latitude_geometry(state,radius) result(status)
    type(native_latitude_geometry),intent(inout) :: state
    real(c_double),intent(in) :: radius
    integer(c_int),parameter :: n=32,halo=2
    real(c_double) :: pi,phi(32)
    integer :: allocation_status
    status=2
    if(.not.latitude_owners_fresh(state))return
    if(transfer(radius,0_c_int64_t)/=int(z'41584de740000000',c_int64_t))return
    allocate(state%rw(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rmu(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1mu2(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1mui(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1mua(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rsqm2(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1qm2(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%racthe(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rlatig(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    status=initialize_selected_gaussian_latitudes(state%rmu(1:n),state%rw)
    if(status/=0)goto 900
    call fill_latitude_rows(state,n,radius,state%rmu(1:n),phi,.true.)
    pi=transfer(int(z'400921fb54442d18',c_int64_t),pi)
    call fill_latitude_halos(state,n,halo,pi,phi)
    status=0
    return
900 continue
    call release_latitude_geometry(state)
    status=1
  end function

  !> Retain the public TRANS_INQ route with its live resolution and row count.
  !! n is even and at least two; halo is between zero and min(n,1024).
  !! Source-qualified operational inputs have n=2560 and halo=2.
  !! The caller owns a live public transform with exactly n Gaussian rows.
  !! The eleven allocations retain source lifetime order, including both
  !! private arrays. All dimensions and owner sizes derive from the live n.
  integer(c_int) function initialize_public_latitude_geometry(state,n,halo,radius,pi,resolution) result(status)
    type(native_latitude_geometry),intent(inout) :: state
    integer(c_int),intent(in) :: n,halo,resolution
    real(c_double),intent(in) :: radius,pi
    real(c_double),allocatable :: mu(:),phi(:)
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: row,allocation_status
    status=2
    if(n<2.or.n>131072.or.mod(n,2)/=0)return
    if(halo<0.or.halo>min(n,1024))return
    if(resolution<1)return
    if(.not.latitude_owners_fresh(state))return
    if(transfer(radius,0_c_int64_t)/=int(z'41584de740000000',c_int64_t))return
    if(transfer(pi,0_c_int64_t)/=int(z'400921fb54442d18',c_int64_t))return
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(state%rw(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(mu(n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(phi(n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rmu(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1mu2(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1mui(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1mua(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rsqm2(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%r1qm2(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%racthe(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rlatig(1-halo:n+halo),stat=allocation_status)
    if(allocation_status/=0)goto 900
    call trans_inq(kresol=resolution,pmu=mu,pgw=state%rw)
    do row=1,n
      state%rmu(row)=mu(row)
    end do
    call fill_latitude_rows(state,n,radius,mu,phi,.false.)
    deallocate(mu)
    call fill_latitude_halos(state,n,halo,pi,phi)
    deallocate(phi)
    error_pointer=saved_errno
    status=0
    return
900 continue
    call release_latitude_geometry(state)
    if(allocated(mu))deallocate(mu)
    if(allocated(phi))deallocate(phi)
    error_pointer=saved_errno
    status=1
  end function

  !> Free only the nine produced owners in source order, leaving RLATI intact.
  !! Release preserves the incoming IEEE floating-point state and errno.
  subroutine release_latitude_geometry(state)
    type(native_latitude_geometry),intent(inout) :: state
    type(ieee_status_type) :: saved_fp_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_fp_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    if(allocated(state%rw))deallocate(state%rw)
    if(allocated(state%rmu))deallocate(state%rmu)
    if(allocated(state%r1mu2))deallocate(state%r1mu2)
    if(allocated(state%r1mui))deallocate(state%r1mui)
    if(allocated(state%r1mua))deallocate(state%r1mua)
    if(allocated(state%rsqm2))deallocate(state%rsqm2)
    if(allocated(state%r1qm2))deallocate(state%r1qm2)
    if(allocated(state%racthe))deallocate(state%racthe)
    if(allocated(state%rlatig))deallocate(state%rlatig)
    call ieee_set_status(saved_fp_status)
    error_pointer=saved_errno
  end subroutine
end module forecast_latitude_geometry
