!> Construct complete selected common GRIB templates from native metadata.
module forecast_grib_template_initialization
  use iso_c_binding
  use iso_fortran_env, only: int32, int64, real64
  use forecast_selected_grib_metadata, only: selected_grib_output_metadata
  use forecast_eccodes_output_services
  implicit none
  private
  public :: prepare_grib_template, initialize_grib_template
contains
  !> Clone sample, apply the source setters, and publish one C owner.
  !! kind0 is surface spectral,1 model spectral and2 model Gaussian grid.
  !! Metadata is the existing selected512-byte record for T21/L19/32x64.
  !! Angles enter in radians. Hybrid A is Pa; B is dimensionless.
  !! Failure deletes only the private clone and leaves output unchanged.
  integer(int32) function prepare_grib_template(sample, metadata, kind, output) result(status)
    type(c_ptr), intent(in) :: sample
    type(selected_grib_output_metadata), intent(in) :: metadata
    integer(int32), intent(in) :: kind
    type(c_ptr), intent(inout) :: output
    type(c_ptr) :: handle
    integer(c_int) :: ignored
    real(real64) :: factor, value, pv(40)
    character(4) :: experiment
    integer :: j
    status = 2
    if (.not. c_associated(sample) .or. kind < 0 .or. kind > 2) return
    if (metadata%local_definition /= 1 .or. metadata%truncation /= 21 .or. metadata%latitude_rows /= 32 .or. &
        metadata%longitudes /= 64 .or. metadata%levels /= 19 .or. metadata%reserved_word /= 0) return
    if (metadata%spectral_type < 0 .or. metadata%spectral_type > 1) return
    if (transfer(metadata%stretch, 0_int64) /= int(z'3ff0000000000000', int64)) return
    if (any(metadata%forecast_type(1:3) /= ['f', 'c', c_null_char])) return
    if (any(metadata%classification(1:3) /= ['r', 'd', c_null_char])) return
    if (metadata%experiment(5) /= c_null_char) return
    do j = 1, 4
      experiment(j:j) = metadata%experiment(j)
    end do
    handle = codes_clone(sample)
    if (.not. c_associated(handle)) then
      status = 1
      return
    end if
    status = set_grib_long(handle, 'generatingProcessIdentifier', metadata%cycle)
    if (status == 0) status = set_grib_long(handle, 'localDefinitionNumber', metadata%local_definition)
    if (status == 0) status = set_grib_long(handle, 'stream', metadata%stream)
    if (status == 0) status = set_grib_string(handle, 'type', 'fc')
    if (status == 0) status = set_grib_string(handle, 'class', 'rd')
    if (status == 0) status = set_grib_long(handle, 'dataDate', metadata%date)
    if (status == 0) status = set_grib_long(handle, 'time', metadata%time)
    if (status == 0) status = set_grib_string(handle, 'experimentVersionNumber', experiment)
    if (status == 0) status = set_grib_long(handle, 'eps', 0_c_long)
    if (status /= 0) goto 900
    if (kind == 2) then
      status = set_grib_long(handle, 'truncateDegrees', 1_c_long)
      if (status == 0) status = set_grib_long(handle, 'numberOfPointsAlongAMeridian', metadata%latitude_rows)
      if (status /= 0) goto 900
      factor = 2.0_real64*transfer(int(z'3ff921fb54442d18', int64), 0.0_real64)
      factor = 180.0_real64/factor
      value = factor*metadata%first_latitude
      status = set_grib_double(handle, 'latitudeOfFirstGridPointInDegrees', value)
      if (status == 0) status = set_grib_long(handle, 'longitudeOfFirstGridPointInDegrees', 0_c_long)
      if (status /= 0) goto 900
      value = factor*metadata%last_latitude
      status = set_grib_double(handle, 'latitudeOfLastGridPointInDegrees', value)
      if (status /= 0) goto 900
      value = 360.0_real64/real(metadata%longitudes, real64)
      value = 360.0_real64 - value
      status = set_grib_double(handle, 'longitudeOfLastGridPointInDegrees', value)
      if (status == 0) status = set_grib_long(handle, 'numberOfParallelsBetweenAPoleAndTheEquator', &
                                              (metadata%latitude_rows + 1_c_long)/2_c_long)
      if (status == 0) status = set_grib_string(handle, 'gridType', 'regular_gg')
      if (status == 0) status = set_grib_long(handle, 'numberOfPointsAlongAParallel', metadata%longitudes)
      if (status /= 0) goto 900
      value = 360.0_real64/real(metadata%longitudes, real64)
      status = set_grib_double(handle, 'iDirectionIncrementInDegrees', value)
    else
      status = set_grib_string(handle, 'gridType', 'sh')
      if (status == 0) status = set_grib_long(handle, 'pentagonalResolutionParameterJ', metadata%truncation)
      if (status == 0) status = set_grib_long(handle, 'pentagonalResolutionParameterK', metadata%truncation)
      if (status == 0) status = set_grib_long(handle, 'pentagonalResolutionParameterM', metadata%truncation)
    end if
    if (status /= 0) goto 900
    if (kind /= 0) then
      pv(1:20) = metadata%hybrid_a
      pv(21:40) = metadata%hybrid_b
      status = codes_set_double_array(handle, 'pv'//c_null_char, pv, 40_c_size_t)
      if (status /= 0) goto 900
    end if
    output = handle
    return
900 ignored = codes_delete(handle)
  end function

  !> Make an ordinary sample, round-trip its message, then apply metadata.
  !! The original source updates tablesVersion only for model samples.
  !! The caller owns output after status0 and deletes it through ecCodes.
  integer(int32) function initialize_grib_template(metadata, kind, output) result(status)
    type(selected_grib_output_metadata), intent(in) :: metadata
    integer(int32), intent(in) :: kind
    type(c_ptr), intent(inout) :: output
    type(c_ptr) :: sample, copy, message
    integer(c_size_t) :: bytes
    integer(c_long) :: latest
    integer(c_int) :: ignored
    status = 2
    if (kind < 0 .or. kind > 2) return
    select case (kind)
    case (0)
      sample = codes_sample(c_null_ptr, 'sh_sfc'//c_null_char)
    case (1)
      sample = codes_sample(c_null_ptr, 'sh_ml'//c_null_char)
    case (2)
      sample = codes_sample(c_null_ptr, 'gg_ml'//c_null_char)
    end select
    status = 1
    if (.not. c_associated(sample)) return
    status = 0
    if (kind /= 0) then
      status = codes_get_long(sample, 'tablesVersionLatest'//c_null_char, latest)
      if (status == 0) status = set_grib_long(sample, 'tablesVersion', latest)
    end if
    if (status /= 0) goto 900
    status = codes_message(sample, message, bytes)
    if (status /= 0) goto 900
    copy = codes_message_copy(c_null_ptr, message, bytes)
    if (.not. c_associated(copy)) then
      status = 1
      goto 900
    end if
    ignored = codes_delete(sample)
    sample = copy
    status = prepare_grib_template(sample, metadata, kind, output)
900 ignored = codes_delete(sample)
  end function
end module
