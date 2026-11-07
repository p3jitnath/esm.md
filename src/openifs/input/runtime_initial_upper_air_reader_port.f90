module runtime_initial_upper_air_reader_port
  !! Decode upper-air initial fields with dimensions from the live grid.
  !! Integer identifiers and counts have no units. Date is YYYYMMDD,
  !! seconds is time within the day, and field values retain encoded units.
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema,read_initial_fields
  implicit none
  private
  public :: runtime_initial_grid_metadata,make_runtime_upper_air_schema
  public :: read_runtime_initial_upper_air_fields

  type :: runtime_initial_grid_metadata
    integer(c_int) :: levels=0,gaussian_order=0,row_count=0,maximum_longitudes=0
    integer(c_int) :: date=0,seconds=0
    integer(c_int), allocatable :: north_rows(:)
  end type
  interface
    function errno_address() bind(c,name="__errno_location") result(address)
      import
      type(c_ptr) :: address
    end function
  end interface
contains

  subroutine make_runtime_upper_air_schema(grid,schema,status)
    !! Port the runtime header admission and seven-field record order.
    !! Northern row counts describe half of the symmetric Gaussian grid.
    !! The schema changes only after every bound and allocation succeeds.
    type(runtime_initial_grid_metadata), intent(in) :: grid
    type(initial_field_schema), intent(inout) :: schema
    integer(c_int), intent(out) :: status
    integer(c_int64_t), allocatable :: labels(:,:)
    integer(c_long), allocatable :: north(:)
    integer(c_int64_t) :: points
    integer(c_int), parameter :: cloud_ids(5)=[75,76,246,247,248]
    integer :: level,j,record,allocation_status,time_minutes,time_hour,time
    status=1
    if(grid%levels<1 .or. grid%levels>256) return
    if(grid%gaussian_order<1 .or. grid%gaussian_order>1280) return
    if(grid%row_count/=2*grid%gaussian_order) return
    if(.not.allocated(grid%north_rows)) return
    if(size(grid%north_rows)/=grid%gaussian_order) return
    points=0
    do j=1,size(grid%north_rows)
      if(grid%north_rows(j)<1) return
      points=points+int(grid%north_rows(j),c_int64_t)
    end do
    if(maxval(grid%north_rows)/=grid%maximum_longitudes) return
    points=2*points
    if(points>2147483647_c_int64_t) return
    if(grid%date<1 .or. grid%date>99991231) return
    if(grid%seconds<0 .or. grid%seconds>86340) return
    if(mod(grid%seconds,60_c_int)/=0) return
    time_minutes=grid%seconds/60
    time_hour=time_minutes/60
    time=time_hour*100+mod(time_minutes,60)
    allocate(labels(4,7*grid%levels),north(grid%gaussian_order),stat=allocation_status)
    if(allocation_status/=0) return
    record=0
    do level=1,grid%levels
      record=record+1
      labels(:,record)=[133_c_int64_t,int(level,c_int64_t),int(grid%date,c_int64_t),int(time,c_int64_t)]
      record=record+1
      labels(:,record)=[203_c_int64_t,int(level,c_int64_t),int(grid%date,c_int64_t),int(time,c_int64_t)]
    end do
    do level=1,grid%levels
      do j=1,5
        record=record+1
        labels(:,record)=[int(cloud_ids(j),c_int64_t),int(level,c_int64_t), &
          int(grid%date,c_int64_t),int(time,c_int64_t)]
      end do
    end do
    north=int(grid%north_rows,c_long)
    call move_alloc(labels,schema%labels)
    call move_alloc(north,schema%north_rows)
    schema%value_count=points
    schema%metadata_words=5
    schema%gaussian_order=grid%gaussian_order
    schema%maximum_longitudes=grid%maximum_longitudes
    schema%runtime_grid=.true.
    status=0
  end subroutine

  function read_runtime_initial_upper_air_fields(path,grid,values,metadata,messages_read) result(status)
    !! Match the shared reader's commit and cleanup rules for the live schema.
    !! values has shape(global_points,at least 7*levels), and metadata
    !! has shape(5,at least 7*levels). The caller owns disjoint arrays.
    character(*), intent(in) :: path
    type(runtime_initial_grid_metadata), intent(in) :: grid
    real(c_double), contiguous, intent(inout) :: values(:,:)
    integer(c_int64_t), contiguous, intent(inout) :: metadata(:,:)
    integer(c_int64_t), intent(inout) :: messages_read
    integer(c_int) :: status,saved_errno
    integer(c_int), pointer :: error_number
    type(ieee_status_type) :: saved_status
    type(initial_field_schema) :: schema
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    call make_runtime_upper_air_schema(grid,schema,status)
    if(status==0) status=read_initial_fields(path,schema,values,metadata,messages_read)
    if(allocated(schema%labels)) deallocate(schema%labels)
    if(allocated(schema%north_rows)) deallocate(schema%north_rows)
    error_number=saved_errno
    call ieee_set_status(saved_status)
  end function
end module
