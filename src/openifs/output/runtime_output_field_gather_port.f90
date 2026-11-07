module runtime_output_field_gather_port
  !! Gather one source-ordered field through the public ECTRANS interface.
  use, intrinsic :: iso_fortran_env, only: int32,real64,int64
  use, intrinsic :: iso_c_binding, only: c_ptr,c_int,c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use mpi_f08, only: MPI_Comm,MPI_COMM_WORLD,MPI_Allreduce,MPI_INTEGER4,MPI_MAX,MPI_SUCCESS
  implicit none
  private
  public :: output_distribution,gather_runtime_output_field,agree_output_status
  type :: output_distribution
    type(MPI_Comm) :: communicator=MPI_COMM_WORLD
    integer(int32) :: world=0,process_one_based=0,vertical_groups=0,vertical_group=0
    integer(int32) :: local_grid_points=0,global_grid_points=0,resolution=0
    logical :: maps_ready=.false.
  end type output_distribution

  interface
    subroutine gath_grid(global,block_width,field_count,destination,resolution,local)
      import int32,real64
      real(real64), optional, intent(out) :: global(:,:)
      integer(int32), optional, intent(in) :: block_width,resolution
      integer(int32), intent(in) :: field_count,destination(:)
      real(real64), intent(in) :: local(:,:,:)
    end subroutine gath_grid
    subroutine gath_spec(global,field_count,destination,vertical_set,resolution, &
        local,field_first,truncation,zero_a0_imaginary)
      import int32,real64
      real(real64), optional, intent(out) :: global(:,:)
      integer(int32), intent(in) :: field_count,destination(:)
      integer(int32), optional, intent(in) :: vertical_set(:),resolution,truncation
      real(real64), optional, intent(in) :: local(:,:)
      logical, optional, intent(in) :: field_first,zero_a0_imaginary
    end subroutine gath_spec
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function errno_address
  end interface

contains

  subroutine agree_output_status(distribution,local_status,status)
    !! Agree integer status without adding numerical floating-point events.
    type(output_distribution), intent(in) :: distribution
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: status
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    integer :: error
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    call MPI_Allreduce(local_status,status,1,MPI_INTEGER4,MPI_MAX, &
      distribution%communicator,error)
    error_number=saved_errno
    call ieee_set_status(saved_status)
    if(error/=MPI_SUCCESS) status=3_int32
  end subroutine agree_output_status

  subroutine gather_runtime_output_field(distribution,spectral,vertical_set, &
      truncation,local_count,global_count,global_values,status,local_values)
    !! Gather to process one. Other processes retain a one-value token.
    !! Grid values are a flat contiguous physical-point vector. Spectral
    !! values are present only on the selected vertical process group.
    !! Counts are complete real64 elements, including real/imaginary pairs.
    type(output_distribution), intent(in) :: distribution
    logical, intent(in) :: spectral
    integer(int32), intent(in) :: vertical_set,truncation,local_count,global_count
    real(real64), contiguous, target, intent(inout) :: global_values(:)
    integer(int32), intent(out) :: status
    real(real64), contiguous, target, optional, intent(in) :: local_values(:)
    real(real64), pointer, contiguous :: global_matrix(:,:),local_matrix(:,:),local_grid(:,:,:)
    integer(int32) :: local_status
    integer(int32) :: destinations(1),vertical_sets(1)
    logical :: local_required

    local_status=2_int32
    local_required=.not.spectral.or.vertical_set==distribution%vertical_group
    if(distribution%maps_ready.and.distribution%world>=1.and. &
        distribution%process_one_based>=1.and. &
        distribution%process_one_based<=distribution%world.and. &
        distribution%vertical_groups>=1.and. &
        distribution%vertical_group>=1.and. &
        distribution%vertical_group<=distribution%vertical_groups.and. &
        local_count>=1.and.global_count>=1) then
      local_status=0_int32
      if(spectral) then
        if(vertical_set<1.or.vertical_set>distribution%vertical_groups) local_status=2
        if(truncation<0.or.truncation>32766) local_status=2
        if(int(global_count,int64)/=int(truncation+1,int64)*int(truncation+2,int64)) local_status=2
      else
        if(local_count/=distribution%local_grid_points) local_status=2
        if(global_count/=distribution%global_grid_points) local_status=2
      end if
      if(local_required) then
        if(.not.present(local_values)) then
          local_status=2
        else
          if(size(local_values)/=local_count) local_status=2
        end if
      end if
      if(distribution%process_one_based==1) then
        if(size(global_values)/=global_count) local_status=2
      else
        if(size(global_values)/=1) local_status=2
      end if
    end if
    call agree_output_status(distribution,local_status,status)
    if(status/=0) return
    destinations=1_int32
    vertical_sets=vertical_set
    global_matrix(1:size(global_values),1:1)=>global_values
    if(spectral) then
      if(local_required) then
        local_matrix(1:local_count,1:1)=>local_values
        call gath_spec(global_matrix,1_int32,destinations,vertical_sets, &
          distribution%resolution,local_matrix,.false.,truncation)
      else
        call gath_spec(global=global_matrix,field_count=1_int32, &
          destination=destinations,vertical_set=vertical_sets, &
          resolution=distribution%resolution,field_first=.false.,truncation=truncation)
      end if
    else
      local_grid(1:local_count,1:1,1:1)=>local_values
      call gath_grid(global_matrix,local_count,1_int32,destinations, &
        distribution%resolution,local_grid)
    end if
    call agree_output_status(distribution,0_int32,status)
  end subroutine gather_runtime_output_field
end module runtime_output_field_gather_port
