!> Own the hydrostatic terrain arrays with their true final-block extents.
module forecast_orography_storage
  use iso_c_binding, only: c_int,c_int64_t,c_double,c_ptr,c_f_pointer
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  implicit none
  private
  public :: native_orography_block,native_orography_storage
  public :: allocate_orography_storage,release_orography_storage
  !> Terrain geopotential arrays use m**2 s**(-2); derivatives retain source units.
  !! Only orog/orogl/orogm are allocated by this hydrostatic constructor.
  !! Numerical payloads and the three second derivatives remain unwritten.
  type :: native_orography_block
    real(c_double),allocatable :: orog(:),orogl(:),orogm(:)
    real(c_double),allocatable :: orogll(:),oroglm(:),orogmm(:)
  end type
  !> One record per block; each record owns only its actual physical points.
  type :: native_orography_storage
    type(native_orography_block),allocatable :: blocks(:)
  end type
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate outer records then three payloads per block in original order.
  !! block_width/point_count are live positive dimensions and nonhydrostatic
  !! must be canonical zero. No numerical payload value is initialized.
  !! Return2 is atomic; return1 releases every acquired owner.
  integer(c_int) function allocate_orography_storage(state,block_width,point_count,nonhydrostatic) result(status)
    type(native_orography_storage),intent(inout) :: state
    integer(c_int),intent(in) :: block_width,point_count,nonhydrostatic
    integer(c_int64_t) :: block_count
    integer :: block,extent,allocation_status
    type(ieee_status_type) :: saved_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    status=2
    if(allocated(state%blocks))return
    if(nonhydrostatic/=0)return
    if(block_width<1.or.block_width>1048576.or.point_count<1)return
    block_count=(int(point_count,c_int64_t)+block_width-1)/block_width
    if(block_count>huge(0_c_int))return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(state%blocks(int(block_count)),stat=allocation_status)
    if(allocation_status/=0)goto 900
    do block=1,int(block_count)
      extent=min(block_width,point_count-(block-1)*block_width)
      allocate(state%blocks(block)%orog(extent),stat=allocation_status)
      if(allocation_status/=0)goto 900
      allocate(state%blocks(block)%orogl(extent),stat=allocation_status)
      if(allocation_status/=0)goto 900
      allocate(state%blocks(block)%orogm(extent),stat=allocation_status)
      if(allocation_status/=0)goto 900
    end do
    call ieee_set_status(saved_status)
    error_pointer=saved_errno
    status=0
    return
900 continue
    call release_orography_storage(state)
    call ieee_set_status(saved_status)
    error_pointer=saved_errno
    status=1
  end function

  !> Release payloads in increasing block/field order, then outer records.
  !! This hydrostatic owner requires its three second derivatives unallocated.
  !! Release preserves incoming IEEE status and errno.
  subroutine release_orography_storage(state)
    type(native_orography_storage),intent(inout) :: state
    type(ieee_status_type) :: saved_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: block
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    if(allocated(state%blocks))then
      do block=1,size(state%blocks)
        if(allocated(state%blocks(block)%orog))deallocate(state%blocks(block)%orog)
        if(allocated(state%blocks(block)%orogl))deallocate(state%blocks(block)%orogl)
        if(allocated(state%blocks(block)%orogm))deallocate(state%blocks(block)%orogm)
      end do
      deallocate(state%blocks)
    end if
    call ieee_set_status(saved_status)
    error_pointer=saved_errno
  end subroutine
end module forecast_orography_storage
