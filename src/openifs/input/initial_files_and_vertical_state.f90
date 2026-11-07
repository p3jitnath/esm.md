!> Join accepted file metadata to the owned vertical coordinate calculation.
module forecast_initial_vertical_state
  use iso_c_binding, only: c_int,c_int64_t,c_ptr,c_f_pointer,c_null_char
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use physical_constant_setup_port, only: forecast_physical_constants
  use initial_model_file_headers_port, only: initial_model_header_metadata, &
    read_initial_model_headers,make_runtime_grid_from_initial_headers
  use runtime_initial_upper_air_reader_port, only: runtime_initial_grid_metadata
  use forecast_vertical_coordinate_storage, only: native_vertical_state, &
    create_vertical_startup_state,release_vertical_startup_state
  use forecast_owned_vertical_system, only: initialize_owned_vertical_system
  implicit none
  private
  public :: native_initial_vertical_state,initialize_initial_vertical_state
  public :: release_initial_vertical_state
  integer,parameter :: maximum_configuration_bytes=262144
  !> Native owners for the initial metadata and complete vertical setup.
  !! configuration_text retains the exact file bytes in its active prefix.
  !! The remaining character storage is blank. grid owns its northern row
  !! counts; vertical owns all constructor arrays and the later spline copy.
  !! No initial field payload, transform, physics or time step is supplied here.
  type :: native_initial_vertical_state
    character(maximum_configuration_bytes) :: configuration_text
    integer(c_int) :: configuration_bytes=0
    type(initial_model_header_metadata) :: headers
    type(runtime_initial_grid_metadata) :: grid
    type(native_vertical_state),allocatable :: vertical
    logical :: ready=.false.
  end type
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Require a bounded path before any external file operation.
  logical function valid_path(path) result(valid)
    character(*),intent(in) :: path
    valid=.false.
    if(len(path)<1.or.len(path)>4095)return
    if(index(path,c_null_char)/=0)return
    valid=.true.
  end function

  !> Read configuration and both headers, then complete the owned vertical setup.
  !! output is an unallocated native owner and changes only on complete success.
  !! constants is the already accepted native physical record, read only; its
  !! producer must have run in the frozen nearest-rounding, gradual-underflow
  !! environment. The caller supplies that same environment to this entry.
  !! configuration_path names a nonempty file of at most262144 bytes. All paths
  !! contain1..4095 characters and no NUL. Configuration bytes are retained as
  !! read. Header coefficients use Pa for A and dimensionless B, both0:levels.
  !! The admitted vertical branch has19or137layers and the existing global
  !! hydrostatic ECMWF controls. The constructor produces VP00 in Pa; that
  !! exact value and constants%RPI feed the accepted vertical parent.
  !! Status0 succeeds,1 allocation,2 admission,3 configuration I/O or bounds,
  !! 4 headers,5 grid projection,6 vertical constructor,7 vertical calculation.
  !! child_status retains the failed child or I/O result; it is0 on success.
  !! Earlier successful header publication counts remain valid on later failure.
  !! Failure releases private owners; output remains unallocated. Incoming
  !! errno is preserved. Floating exception flags follow the accepted children;
  !! cleanup preserves the numerical status reached before release.
  integer(c_int) function initialize_initial_vertical_state(output,configuration_path, &
      spectral_path,grid_path,constants,child_status) result(status)
    type(native_initial_vertical_state),allocatable,intent(inout) :: output
    character(*),intent(in) :: configuration_path,spectral_path,grid_path
    type(forecast_physical_constants),intent(in) :: constants
    integer(c_int),intent(out) :: child_status
    type(native_initial_vertical_state),allocatable :: pending
    integer(c_int),pointer,volatile :: error_number
    integer(c_int) :: saved_errno,ignored
    integer(c_int64_t) :: file_bytes
    integer(c_int) :: geometry(4)
    integer :: allocation_status,unit,io,close_status
    logical :: opened
    status=2
    child_status=0
    if(allocated(output))return
    if(.not.valid_path(configuration_path))return
    if(.not.valid_path(spectral_path))return
    if(.not.valid_path(grid_path))return
    if(constants%initialized/=1)return
    if(transfer(constants%rpi,0_c_int64_t)/=int(z'400921fb54442d18',c_int64_t))return
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    opened=.false.
    allocate(pending,stat=allocation_status)
    status=1
    child_status=allocation_status
    if(allocation_status/=0)goto900
    pending%configuration_text=' '
    status=3
    open(newunit=unit,file=configuration_path,status='old',action='read', &
      access='stream',form='unformatted',iostat=io)
    child_status=io
    if(io/=0)goto900
    opened=.true.
    inquire(unit=unit,size=file_bytes,iostat=io)
    child_status=io
    if(io/=0)goto900
    child_status=0
    if(file_bytes<1.or.file_bytes>maximum_configuration_bytes)goto900
    read(unit,iostat=io) pending%configuration_text(1:int(file_bytes))
    child_status=io
    if(io/=0)goto900
    close(unit,iostat=io)
    opened=.false.
    child_status=io
    if(io/=0)goto900
    if(index(pending%configuration_text(1:int(file_bytes)),c_null_char)/=0)goto900
    pending%configuration_bytes=int(file_bytes,c_int)
    status=4
    child_status=read_initial_model_headers(spectral_path,grid_path,pending%headers)
    if(child_status/=0)goto900
    status=5
    child_status=make_runtime_grid_from_initial_headers(pending%headers,pending%grid)
    if(child_status/=0)goto900
    geometry=[pending%grid%levels,1_c_int,0_c_int,0_c_int]
    status=6
    child_status=create_vertical_startup_state(pending%vertical, &
      pending%configuration_text(1:pending%configuration_bytes),geometry, &
      pending%headers%a,pending%headers%b)
    if(child_status/=0)goto900
    status=7
    child_status=initialize_owned_vertical_system(pending%vertical, &
      pending%vertical%vp00,constants%rpi)
    if(child_status/=0)goto900
    pending%ready=.true.
    call move_alloc(pending,output)
    status=0
900 continue
    if(opened)close(unit,iostat=close_status)
    if(allocated(pending))ignored=release_initial_vertical_state(pending)
    error_number=saved_errno
  end function

  !> Release only this prefix's owners; repeated release is permitted.
  !! The complete vertical state is released before the northern row counts.
  !! The caller's floating-point status and errno are preserved on every path.
  integer(c_int) function release_initial_vertical_state(state) result(status)
    type(native_initial_vertical_state),allocatable,intent(inout) :: state
    type(ieee_status_type) :: incoming
    integer(c_int),pointer,volatile :: error_number
    integer(c_int) :: saved_errno,ignored
    status=0
    if(.not.allocated(state))return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    if(allocated(state%vertical))ignored=release_vertical_startup_state(state%vertical)
    if(allocated(state%grid%north_rows))deallocate(state%grid%north_rows)
    state%ready=.false.
    deallocate(state)
    call ieee_set_status(incoming)
    error_number=saved_errno
  end function
end module forecast_initial_vertical_state
