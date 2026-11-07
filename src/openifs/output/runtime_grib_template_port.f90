module runtime_grib_template_port
  !! Port the generated GRIB template calculation to portable Fortran.
  !! Geometry dimensions are counts. Latitudes are radians and times are seconds.
  !! The ecCodes C interface owns encoded-message storage and template handles.
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_arithmetic
  implicit none
  private
  public :: grib_geometry_metadata, grib_template_metadata
  public :: create_runtime_grib_template, runtime_grib_edition

  type, bind(c) :: grib_geometry_metadata
    integer(c_int) :: nlat, nlon, truncation, nlev, reduced, npoints
    type(c_ptr) :: latitudes, points_per_row, hybrid_a, hybrid_b
  end type

  type, bind(c) :: grib_template_metadata
    integer(c_int) :: cycle, local_definition, stream, data_date, seconds
    character(c_char) :: forecast_type(2), classification(2), experiment(4)
    integer(c_size_t) :: workspace_limit_bytes
  end type

  interface
    function codes_new_sample(context, sample) bind(c,name="codes_handle_new_from_samples") result(handle)
      import
      type(c_ptr), value :: context
      character(c_char), intent(in) :: sample(*)
      type(c_ptr) :: handle
    end function
    function codes_new_copy(context, message, length) bind(c,name="codes_handle_new_from_message_copy") result(handle)
      import
      type(c_ptr), value :: context, message
      integer(c_size_t), value :: length
      type(c_ptr) :: handle
    end function
    function codes_delete(handle) bind(c,name="codes_handle_delete") result(status)
      import
      type(c_ptr), value :: handle
      integer(c_int) :: status
    end function
    function codes_get_long(handle, key, value) bind(c,name="codes_get_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: value
      integer(c_int) :: status
    end function
    function codes_set_long(handle, key, value) bind(c,name="codes_set_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), value :: value
      integer(c_int) :: status
    end function
    function codes_set_double(handle, key, value) bind(c,name="codes_set_double") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), value :: value
      integer(c_int) :: status
    end function
    function codes_set_string(handle, key, text, length) bind(c,name="codes_set_string") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*), text(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function codes_set_longs(handle, key, values, length) bind(c,name="codes_set_long_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(in) :: values(*)
      integer(c_size_t), value :: length
      integer(c_int) :: status
    end function
    function codes_set_doubles(handle, key, values, length) bind(c,name="codes_set_double_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), intent(in) :: values(*)
      integer(c_size_t), value :: length
      integer(c_int) :: status
    end function
    function codes_message(handle, message, length) bind(c,name="codes_get_message") result(status)
      import
      type(c_ptr), value :: handle
      type(c_ptr), intent(out) :: message
      integer(c_size_t), intent(out) :: length
      integer(c_int) :: status
    end function
  end interface

contains

  pure function runtime_grib_edition(parameter_id, level) &
      bind(c,name="md2asm_runtime_grib_edition") result(edition)
    !! Select the same GRIB edition as runtime_grib_field_encoding.S.
    !! Both arguments and the return value are signed 32-bit integers.
    integer(c_int), value :: parameter_id, level
    integer(c_int) :: edition
    integer(c_int), parameter :: exact(23) = [ &
      228035,228036,162071,162072,228050,228051,228057,228058, &
      228052,228053,228059,228060,228235,228231,228233,228232, &
      228234,228237,228045,228104,228141,228038,210170 ]
    integer(c_int), parameter :: lower(11) = [ &
      210252,215212,217057,217222,218057,218221,219057,221057,221221,222001,223001 ]
    integer(c_int), parameter :: width(11) = [1,14,149,10,149,11,175,149,11,255,255]
    integer(c_int64_t) :: difference
    integer :: j
    edition=2
    if(parameter_id>=256000) return
    if(parameter_id==33 .or. parameter_id==238) then
      if(level==0) edition=1
      return
    end if
    do j=1,size(exact)
      if(parameter_id==exact(j)) return
    end do
    do j=1,size(lower)
      difference=int(parameter_id,c_int64_t)-int(lower(j),c_int64_t)
      if(difference>=0 .and. difference<=width(j)) return
    end do
    edition=1
  end function

  function create_runtime_grib_template(geometry, metadata, kind, output_handle) &
      bind(c,name="md2asm_create_grib_template_fortran") result(status)
    !! Follow runtime_grib_template_creation.S with typed metadata.
    !! kind=0: spectral surface; 1: spectral levels; 2: gridpoint surface
    !! in GRIB1; 3: gridpoint levels; 4: gridpoint surface in GRIB2.
    !! The caller supplies nlat FP64 latitudes, nlat int32 row counts and
    !! nlev+1 FP64 entries for each of the two hybrid-coordinate arrays.
    !! output_handle changes only on success. The caller must delete it.
    type(grib_geometry_metadata), intent(in) :: geometry
    type(grib_template_metadata), intent(in) :: metadata
    integer(c_int), value :: kind
    type(c_ptr), intent(inout) :: output_handle
    integer(c_int) :: status, ignored
    type(c_ptr) :: handle, copied, message
    real(c_double), pointer :: latitude(:), a(:), b(:)
    integer(c_int), pointer :: rows(:)
    integer(c_long), allocatable :: pl(:)
    real(c_double), allocatable :: pv(:)
    integer(c_long) :: latest
    integer(c_size_t) :: message_length, required_bytes
    integer(c_int64_t) :: points
    integer :: j, nlat, nlev, allocation_status
    real(c_double) :: first_latitude, last_latitude, last_longitude, longitude_increment
    real(c_double), parameter :: degrees_per_radian = &
      transfer(int(z'404ca5dc1a63c1f8',c_int64_t),0.0_c_double)
    type(ieee_round_type) :: rounding
    logical :: gradual
    character(2) :: forecast_type, classification
    character(4) :: experiment

    status=2
    handle=c_null_ptr
    call ieee_get_rounding_mode(rounding)
    gradual=.true.
    if(ieee_support_underflow_control()) call ieee_get_underflow_mode(gradual)
    if(rounding/=ieee_nearest .or. .not.gradual) return
    if(kind<0 .or. kind>4) return
    nlat=geometry%nlat
    nlev=geometry%nlev
    if(nlat<2 .or. nlat>16384) return
    if(geometry%nlon<1 .or. geometry%nlon>65536) return
    if(geometry%truncation<1 .or. geometry%truncation>4096) return
    if(nlev<1 .or. nlev>512) return
    if(geometry%reduced<0 .or. geometry%reduced>1 .or. geometry%npoints<1) return
    if(metadata%data_date<0 .or. metadata%seconds<0 .or. metadata%seconds>=86400) return
    if(metadata%local_definition/=1 .or. metadata%stream/=1025) return
    forecast_type=metadata%forecast_type(1)//metadata%forecast_type(2)
    classification=metadata%classification(1)//metadata%classification(2)
    experiment=metadata%experiment(1)//metadata%experiment(2)//metadata%experiment(3)//metadata%experiment(4)
    if(forecast_type/='fc' .or. index(classification,c_null_char)/=0) return
    if(.not.c_associated(geometry%latitudes) .or. .not.c_associated(geometry%points_per_row)) return
    if(.not.c_associated(geometry%hybrid_a) .or. .not.c_associated(geometry%hybrid_b)) return
    required_bytes=int(nlat,c_size_t)*8_c_size_t+int(nlev+1,c_size_t)*16_c_size_t
    if(metadata%workspace_limit_bytes>68719476736_c_size_t) return
    if(required_bytes+512_c_size_t>metadata%workspace_limit_bytes) return
    call c_f_pointer(geometry%latitudes,latitude,[nlat])
    call c_f_pointer(geometry%points_per_row,rows,[nlat])
    call c_f_pointer(geometry%hybrid_a,a,[nlev+1])
    call c_f_pointer(geometry%hybrid_b,b,[nlev+1])
    allocate(pl(nlat),pv(2*(nlev+1)),stat=allocation_status)
    if(allocation_status/=0) then
      status=1
      return
    end if
    points=0
    do j=1,nlat
      if(rows(j)<1 .or. rows(j)>geometry%nlon) return
      pl(j)=int(rows(j),c_long)
      points=points+int(rows(j),c_int64_t)
    end do
    if(geometry%reduced==0) points=int(nlat,c_int64_t)*int(geometry%nlon,c_int64_t)
    if(points/=int(geometry%npoints,c_int64_t)) return
    do j=1,nlev+1
      pv(j)=a(j)
      pv(nlev+1+j)=b(j)
    end do
    select case(kind)
    case(0)
      handle=codes_new_sample(c_null_ptr,'sh_sfc'//c_null_char)
    case(1)
      handle=codes_new_sample(c_null_ptr,'sh_ml'//c_null_char)
    case(2)
      handle=codes_new_sample(c_null_ptr,'gg_sfc_grib1'//c_null_char)
    case(3)
      handle=codes_new_sample(c_null_ptr,'gg_ml'//c_null_char)
    case(4)
      handle=codes_new_sample(c_null_ptr,'gg_sfc_grib2'//c_null_char)
    end select
    if(.not.c_associated(handle)) then
      status=1
      return
    end if
    status=0
    if(kind/=0 .and. kind/=2) then
      status=codes_get_long(handle,'tablesVersionLatest'//c_null_char,latest)
      call put_long('tablesVersion',latest)
      if(status/=0) goto 900
    end if
    status=codes_message(handle,message,message_length)
    if(status/=0) goto 900
    copied=codes_new_copy(c_null_ptr,message,message_length)
    if(.not.c_associated(copied)) then
      status=1
      goto 900
    end if
    ignored=codes_delete(handle)
    handle=copied
    call put_long('generatingProcessIdentifier',int(metadata%cycle,c_long))
    call put_long('localDefinitionNumber',int(metadata%local_definition,c_long))
    call put_long('stream',int(metadata%stream,c_long))
    call put_string('type',forecast_type)
    call put_string('class',classification)
    call put_long('dataDate',int(metadata%data_date,c_long))
    call put_long('time',int((metadata%seconds/3600)*100,c_long))
    call put_string('experimentVersionNumber',experiment)
    call put_long('eps',0_c_long)
    if(kind>=2) then
      call put_long('truncateDegrees',1_c_long)
      call put_long('numberOfPointsAlongAMeridian',int(nlat,c_long))
      first_latitude=degrees_per_radian*latitude(1)
      call put_double('latitudeOfFirstGridPointInDegrees',first_latitude)
      call put_long('longitudeOfFirstGridPointInDegrees',0_c_long)
      last_latitude=degrees_per_radian*latitude(nlat)
      call put_double('latitudeOfLastGridPointInDegrees',last_latitude)
      longitude_increment=360.0_c_double/real(geometry%nlon,c_double)
      last_longitude=360.0_c_double-longitude_increment
      call put_double('longitudeOfLastGridPointInDegrees',last_longitude)
      call put_long('numberOfParallelsBetweenAPoleAndTheEquator',int((nlat+1)/2,c_long))
      if(geometry%reduced/=0) then
        call put_string('gridType','reduced_gg')
        if(status==0) status=codes_set_longs(handle,'pl'//c_null_char,pl,int(nlat,c_size_t))
      else
        call put_string('gridType','regular_gg')
        call put_long('numberOfPointsAlongAParallel',int(geometry%nlon,c_long))
        longitude_increment=360.0_c_double/real(geometry%nlon,c_double)
        call put_double('iDirectionIncrementInDegrees',longitude_increment)
      end if
    else
      call put_string('gridType','sh')
      call put_long('pentagonalResolutionParameterJ',int(geometry%truncation,c_long))
      call put_long('pentagonalResolutionParameterK',int(geometry%truncation,c_long))
      call put_long('pentagonalResolutionParameterM',int(geometry%truncation,c_long))
    end if
    if(kind==1 .or. kind==3) then
      if(status==0) status=codes_set_doubles(handle,'pv'//c_null_char,pv,int(size(pv),c_size_t))
    end if
    if(status==0) then
      output_handle=handle
      handle=c_null_ptr
    end if
900 continue
    if(c_associated(handle)) ignored=codes_delete(handle)

  contains

    subroutine put_long(key,value)
      character(*), intent(in) :: key
      integer(c_long), intent(in) :: value
      if(status==0) status=codes_set_long(handle,key//c_null_char,value)
    end subroutine

    subroutine put_double(key,value)
      character(*), intent(in) :: key
      real(c_double), intent(in) :: value
      if(status==0) status=codes_set_double(handle,key//c_null_char,value)
    end subroutine

    subroutine put_string(key,text)
      character(*), intent(in) :: key,text
      integer(c_size_t) :: length
      length=int(len(text),c_size_t)
      if(status==0) status=codes_set_string(handle,key//c_null_char,text//c_null_char,length)
    end subroutine

  end function
end module
