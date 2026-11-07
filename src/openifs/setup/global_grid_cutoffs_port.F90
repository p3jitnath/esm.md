!> Obtain source global wave cutoffs through the live public transform.
module forecast_global_grid_cutoffs
  use iso_c_binding, only: c_int,c_int32_t,c_ptr,c_f_pointer
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use forecast_grid_dimensions, only: native_grid_dimensions
  implicit none
  private
  public :: native_global_grid_cutoffs,initialize_global_grid_cutoffs,release_global_grid_cutoffs
  !> Own local/global cutoff arrays and northern-row counts.
  !! nmen/nmeng have the source row/halo bounds. ndglu uses0:nsmax.
  !! nmen stays source-unwritten until its later local producer.
  type :: native_global_grid_cutoffs
    integer(c_int32_t),allocatable :: nmen(:),nmeng(:),ndglu(:)
  end type
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
#include "trans_inq.h"
contains
  !> Allocate in source order, inquire active values, then reflect halo rows.
  !! The caller owns a live public resolution with the exact supplied dimensions.
  !! ecmwf and supersede are the selected canonical controls, both one.
  !! All counts are dimensionless; no floating-point calculation is introduced.
  integer(c_int32_t) function initialize_global_grid_cutoffs(state,d,resolution,ecmwf,supersede) result(status)
    type(native_global_grid_cutoffs),intent(inout) :: state
    type(native_grid_dimensions),intent(in) :: d
    integer(c_int32_t),intent(in) :: resolution,ecmwf,supersede
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: j,allocation_status
    status=2
    if(ecmwf/=1.or.supersede/=1.or.resolution<1)return
    if(d%nsmax<1.or.d%nsmax>8191)return
    if(d%ndglg<2.or.d%ndglg>1048576)return
    if(d%ndgsur<0.or.d%ndgsur>min(48,d%ndglg))return
    if(d%ndgsag/=1-d%ndgsur.or.d%ndgeng/=d%ndglg+d%ndgsur)return
    if(allocated(state%nmen).or.allocated(state%nmeng).or.allocated(state%ndglu))return
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(state%nmen(d%ndgsag:d%ndgeng),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%nmeng(d%ndgsag:d%ndgeng),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%ndglu(0:d%nsmax),stat=allocation_status)
    if(allocation_status/=0)goto 900
    error_pointer=saved_errno
    call trans_inq(kresol=resolution,knmeng=state%nmeng(1:d%ndglg),kdglu=state%ndglu)
    do j=1,d%ndgsur
      state%nmeng(1-j)=state%nmeng(j)
      state%nmeng(d%ndglg+j)=state%nmeng(d%ndglg+1-j)
    end do
    status=0
    return
900 continue
    call release_global_grid_cutoffs(state)
    error_pointer=saved_errno
    status=1
  end function

  !> Release only the three cutoff owners and preserve IEEE state and errno.
  subroutine release_global_grid_cutoffs(state)
    type(native_global_grid_cutoffs),intent(inout) :: state
    type(ieee_status_type) :: saved_fp_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_fp_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    if(allocated(state%nmen))deallocate(state%nmen)
    if(allocated(state%nmeng))deallocate(state%nmeng)
    if(allocated(state%ndglu))deallocate(state%ndglu)
    call ieee_set_status(saved_fp_status)
    error_pointer=saved_errno
  end subroutine
end module forecast_global_grid_cutoffs
