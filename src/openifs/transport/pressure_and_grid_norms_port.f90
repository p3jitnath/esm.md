!> Typed Fortran ports of our distributed grid norm and pressure fixer.
!! Numerical input is pressure in Pa; log_pressure stores log of that value.
!! Public ECTRANS and FIAT keep the existing reduction and broadcast order.
module forecast_pressure_norms
  use, intrinsic :: iso_fortran_env, only: real64, int32, int64
  use, intrinsic :: iso_c_binding, only: c_ptr,c_int,c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use mpi, only: MPI_INTEGER,MPI_MAX,MPI_SUCCESS
  use mpl_broadcast_mod, only: MPL_BROADCAST
  implicit none
  external :: MPI_Allreduce
  private
  public :: grid_point_norm, pack_pressure_pair, apply_pressure_ratio, fix_surface_pressure
  interface
    subroutine gpnorm_trans(field,nfields,nproma,average,minimum,maximum,average_only,transform)
      import real64,int32
      real(real64), intent(in) :: field(:,:,:)
      integer(int32), intent(in) :: nfields,nproma,transform
      real(real64), intent(inout) :: average(:),minimum(:),maximum(:)
      logical, intent(in) :: average_only
    end subroutine gpnorm_trans
    function system_errno_address() result(address) bind(C,name="__errno_location")
      import c_ptr
      type(c_ptr) :: address
    end function system_errno_address
  end interface
contains
  !> Return mean, minimum and maximum for each physical field.
  !! field has shape (block_width,field_count,block_count), in field units.
  !! active_count excludes final padding. norms has shape (3,field_count).
  !! The caller owns a matching public transform and initialized FIAT world.
  !! Inputs remain unchanged. status is zero on success or two for bad bounds.
  subroutine grid_point_norm(field,active_count,transform,process_count,norms,status)
    real(real64), intent(in) :: field(:,:,:)
    integer(int32), intent(in) :: active_count,transform,process_count
    real(real64), intent(out) :: norms(:,:)
    integer(int32), intent(out) :: status
    real(real64) :: average(size(field,2)),minimum(size(field,2)),maximum(size(field,2))
    integer(int32) :: nproma,nfields
    integer(int64) :: capacity
    integer :: field_number
    status=2
    nproma=int(size(field,1),int32)
    nfields=int(size(field,2),int32)
    if(nproma<1.or.nproma>4096.or.nfields<1.or.nfields>16.or.size(field,3)<1) return
    capacity=int(nproma,int64)*size(field,3,kind=int64)
    if(active_count<1.or.int(active_count,int64)>capacity.or. &
       int(active_count,int64)<=capacity-nproma.or.process_count<1) return
    if(size(norms,1)/=3.or.size(norms,2)/=nfields) return
    call gpnorm_trans(field,nfields,nproma,average,minimum,maximum,.false.,transform)
    if(process_count>1) then
      call MPL_BROADCAST(average,KTAG=12345,KROOT=1,CDSTRING='GPNORM1-AVE:')
      call MPL_BROADCAST(minimum,KTAG=12445,KROOT=1,CDSTRING='GPNORM1-MIN:')
      call MPL_BROADCAST(maximum,KTAG=12545,KROOT=1,CDSTRING='GPNORM1-MAX:')
    end if
    do field_number=1,nfields
      norms(1,field_number)=average(field_number)
      norms(2,field_number)=minimum(field_number)
      norms(3,field_number)=maximum(field_number)
    end do
    status=0
  end subroutine grid_point_norm

  !> Pack active old and predicted pressures without writing final padding.
  !! old_pressure and new_pressure are read-only, flat arrays in Pa.
  !! packed has shape (block_width,2,block_count), with old before new.
  subroutine pack_pressure_pair(old_pressure,new_pressure,active_count,packed)
    real(real64), intent(in) :: old_pressure(:),new_pressure(:)
    integer(int32), intent(in) :: active_count
    real(real64), intent(inout) :: packed(:,:,:)
    integer :: point,block,cell,width
    width=size(packed,1)
    do point=1,active_count
      block=(point-1)/width+1
      cell=modulo(point-1,width)+1
      packed(cell,1,block)=old_pressure(point)
      packed(cell,2,block)=new_pressure(point)
    end do
  end subroutine pack_pressure_pair

  !> Correct each active pressure using the two already observed means.
  !! Means and pressure are in Pa. The ratio is dimensionless.
  !! Keep the division, each product and each public LOG call separate.
  !! new_pressure and log_pressure change only within 1:active_count.
  subroutine apply_pressure_ratio(old_mean,new_mean,active_count,new_pressure,log_pressure)
    real(real64), intent(in) :: old_mean,new_mean
    integer(int32), intent(in) :: active_count
    real(real64), intent(inout) :: new_pressure(:),log_pressure(:)
    real(real64) :: ratio,value
    integer :: point
    ratio=old_mean/new_mean
    do point=1,active_count
      value=ratio*new_pressure(point)
      new_pressure(point)=value
      log_pressure(point)=log(value)
    end do
  end subroutine apply_pressure_ratio

  !> Agree auxiliary status while preserving numerical status and errno.
  !! communicator is the caller's initialized MPI communicator.
  subroutine agree_auxiliary_status(local_status,communicator,global_status)
    integer(int32), intent(in) :: local_status,communicator
    integer(int32), intent(out) :: global_status
    integer :: error
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_error
    type(ieee_status_type) :: saved_status
    call ieee_get_status(saved_status)
    call c_f_pointer(system_errno_address(),error_number)
    saved_error=error_number
    call MPI_Allreduce(local_status,global_status,1,MPI_INTEGER,MPI_MAX,communicator,error)
    error_number=saved_error
    call ieee_set_status(saved_status)
    if(error/=MPI_SUCCESS) global_status=3
  end subroutine agree_auxiliary_status

  !> Apply the proportional pressure correction from our generated PFIXER.
  !! The three pressure owners have block_width*block_count entries.
  !! old_pressure is read only; the other two owners retain their padding.
  !! The caller supplies disjoint arrays and matching transform/MPI worlds.
  !! This selects the proportional route with extra diagnostics disabled.
  subroutine fix_surface_pressure(block_width,active_count,transform,process_count,communicator, &
                                  old_pressure,new_pressure,log_pressure,status)
    integer(int32), intent(in) :: block_width,active_count,transform,process_count,communicator
    real(real64), intent(in) :: old_pressure(:)
    real(real64), intent(inout) :: new_pressure(:),log_pressure(:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: packed(:,:,:)
    real(real64) :: norms(3,2)
    integer(int32) :: local_status,global_status
    integer :: blocks,allocation_status
    status=2
    if(block_width<1.or.block_width>4096.or.active_count<1) return
    blocks=(active_count-1)/block_width+1
    if(size(old_pressure)/=block_width*blocks.or.size(new_pressure)/=size(old_pressure).or. &
       size(log_pressure)/=size(old_pressure).or.process_count<1) return
    allocate(packed(block_width,2,blocks),stat=allocation_status)
    local_status=0
    if(allocation_status/=0) local_status=1
    call agree_auxiliary_status(local_status,communicator,global_status)
    if(global_status/=0) then
      if(allocated(packed)) deallocate(packed)
      status=global_status
      return
    end if
    call pack_pressure_pair(old_pressure,new_pressure,active_count,packed)
    call grid_point_norm(packed,active_count,transform,process_count,norms,local_status)
    call agree_auxiliary_status(local_status,communicator,global_status)
    if(global_status==0) call apply_pressure_ratio(norms(1,1),norms(1,2),active_count,new_pressure,log_pressure)
    deallocate(packed)
    status=global_status
  end subroutine fix_surface_pressure
end module forecast_pressure_norms
