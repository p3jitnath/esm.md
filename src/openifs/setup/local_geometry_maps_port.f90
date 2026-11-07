!> Replace local longitude, spectral and latitude maps with source halo bounds.
module forecast_local_geometry_maps
  use iso_c_binding, only: c_int,c_int64_t,c_double,c_ptr,c_f_pointer
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  implicit none
  private
  public :: initialize_local_geometry_maps,release_local_geometry_maps
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Copy live global maps into native local owners, preserving unwritten cells.
  !! The three global arrays retain their actual allocated lower bounds.
  !! global_first:global_last is the source global halo range. The separate
  !! local_first:local_last range describes physical rows, while wave_rows
  !! describes wave rows. wave_first_global is NPTRLS(MYSETW); first_offset
  !! is NFRSTLOFF. Angles have units radians; integer maps are counts.
  !! The caller owns the three local allocatable arrays. This routine first
  !! admits all borrowed metadata, then releases old local owners in order.
  !! It writes latitude_first/last before allocation, as the source does.
  !! Return2 is atomic. Return1 clears the local owners after allocation failure.
  integer(c_int) function initialize_local_geometry_maps(nloen,nmen,rlati,latitude_first,latitude_last, &
      global_first,global_last,local_first,local_last,wave_rows,wave_first_global,first_offset, &
      global_nloen,global_nmen,global_latitudes) result(status)
    integer(c_int),allocatable,intent(inout) :: nloen(:),nmen(:)
    real(c_double),allocatable,intent(inout) :: rlati(:)
    integer(c_int),intent(inout) :: latitude_first,latitude_last
    integer(c_int),intent(in) :: global_first,global_last,local_first,local_last
    integer(c_int),intent(in) :: wave_rows,wave_first_global,first_offset
    integer(c_int),allocatable,intent(in) :: global_nloen(:),global_nmen(:)
    real(c_double),allocatable,intent(in) :: global_latitudes(:)
    integer(c_int) :: first,last
    integer :: local_index,global_index,allocation_status
    type(ieee_status_type) :: saved_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    status=2
    if(global_first>1.or.global_first< -1048576)return
    if(global_last<1.or.global_last>1048576)return
    if(local_first<1.or.local_last<local_first.or.local_last>1048576)return
    if(wave_rows<1.or.wave_rows>1048576)return
    if(wave_first_global<1.or.wave_first_global>1048576)return
    if(first_offset<0.or.first_offset>1048576)return
    if(.not.allocated(global_nloen).or..not.allocated(global_nmen))return
    if(.not.allocated(global_latitudes))return
    if(lbound(global_nloen,1)>global_first.or.ubound(global_nloen,1)<global_last)return
    if(lbound(global_nmen,1)>global_first.or.ubound(global_nmen,1)<global_last)return
    if(lbound(global_latitudes,1)>global_first.or.ubound(global_latitudes,1)<global_last)return
    first=max(global_first,local_first+first_offset-48)-first_offset
    last=min(global_last,local_last+first_offset+48)-first_offset
    if(first>last)return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    latitude_first=first
    latitude_last=last
    call release_local_geometry_maps(nloen,nmen,rlati)
    allocate(nloen(1-48:wave_rows+48),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(nmen(1-48:wave_rows+48),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(rlati(first:last),stat=allocation_status)
    if(allocation_status/=0)goto 900
    do local_index=1-48,wave_rows+48
      global_index=wave_first_global+local_index-1
      if(global_index<global_first.or.global_index>global_last)cycle
      nloen(local_index)=global_nloen(global_index)
      nmen(local_index)=global_nmen(global_index)
    end do
    do local_index=first,last
      global_index=local_index+first_offset
      rlati(local_index)=global_latitudes(global_index)
    end do
    status=0
    call ieee_set_status(saved_status)
    error_pointer=saved_errno
    return
900 continue
    call release_local_geometry_maps(nloen,nmen,rlati)
    call ieee_set_status(saved_status)
    error_pointer=saved_errno
    status=1
  end function

  !> Release only the local maps in source order; preserve incoming status.
  subroutine release_local_geometry_maps(nloen,nmen,rlati)
    integer(c_int),allocatable,intent(inout) :: nloen(:),nmen(:)
    real(c_double),allocatable,intent(inout) :: rlati(:)
    type(ieee_status_type) :: saved_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    if(allocated(nloen))deallocate(nloen)
    if(allocated(nmen))deallocate(nmen)
    if(allocated(rlati))deallocate(rlati)
    call ieee_set_status(saved_status)
    error_pointer=saved_errno
  end subroutine
end module forecast_local_geometry_maps
