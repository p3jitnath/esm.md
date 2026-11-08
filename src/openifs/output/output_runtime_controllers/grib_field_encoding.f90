!> Encode one selected field with exact source setter and fit order.
module forecast_grib_field_encoding
  use iso_c_binding
  use iso_fortran_env, only: int32, int64, real64
  use forecast_eccodes_output_services
  use forecast_spectral_packing_fit, only: fit_spectrum
  use forecast_output_request_types, only: increment_output_counter
  implicit none
  private
  public :: native_grib_field_specification, encode_grib_field
  !> All integers are dimensionless except forecast_seconds, in seconds.
  !! level is a one-based model level or a pressure in Pa.
  !! The borrowed template stays live until this call returns.
  type :: native_grib_field_specification
    type(c_ptr) :: template = c_null_ptr
    integer(int64) :: parameter = 0, level = 0, representation = 0, model_level = 0
    integer(int64) :: forecast_seconds = 0, value_count = 0, force_log_surface_pressure = 0
  end type
contains
  !> Return a message view and its live C handle only after complete encoding.
  !! Values are readonly, contiguous FP64. Selected spectral inputs contain
  !! 506 words at T21 for parameters130/152; grid inputs contain2048 words
  !! for model humidity133. Model levels1:19; forecast times0:24whole hours.
  !! Public ecCodes errors release the clone and retain all three outputs.
  integer(int32) function encode_grib_field(specification, values, message, length, owner, calls) result(status)
    type(native_grib_field_specification), intent(in) :: specification
    real(real64), intent(in) :: values(:)
    type(c_ptr), intent(inout) :: message, owner
    integer(c_size_t), intent(inout) :: length
    integer(int64), intent(inout) :: calls
    type(c_ptr) :: handle, local_message
    integer(c_size_t) :: local_length, text_length
    integer(c_int) :: ignored
    integer(int64) :: bits
    real(real64) :: intercept, slope, operator_value
    real(real64), volatile :: unused_extreme
    character(c_char) :: forecast_type(16)
    integer :: j
    status = 2
    if (.not. c_associated(specification%template)) return
    if (specification%representation < 0 .or. specification%representation > 1 .or. &
        specification%model_level < 0 .or. specification%model_level > 1) return
    if (specification%level <= 0) return
    if (specification%model_level == 1) then
      if (specification%level > 19) return
    else
      if (specification%level < 100) return
    end if
    if (specification%forecast_seconds < 0 .or. specification%forecast_seconds > 86400) return
    if (modulo(specification%forecast_seconds, 3600_int64) /= 0) return
    if (specification%force_log_surface_pressure < 0 .or. specification%force_log_surface_pressure > 1) return
    if (specification%representation == 1) then
      if (specification%value_count /= 506) return
      if (specification%parameter /= 130 .and. specification%parameter /= 152) return
    else
      if (specification%value_count /= 2048 .or. specification%parameter /= 133 .or. specification%model_level /= 1) return
    end if
    if (size(values, kind=int64) /= specification%value_count .or. .not. is_contiguous(values)) return
    do j = 1, size(values)
      bits = transfer(values(j), bits)
      if (iand(bits, int(z'7ff0000000000000', int64)) == int(z'7ff0000000000000', int64)) return
      if (specification%representation == 0 .and. bits == int(z'7fefffffffffffff', int64)) return
    end do
    handle = codes_clone(specification%template)
    if (.not. c_associated(handle)) then
      status = 1
      return
    end if
    status = 0
    if (specification%representation == 1) then
      status = set_grib_long(handle, 'pentagonalResolutionParameterJ', 21_c_long)
      if (status == 0) status = set_grib_long(handle, 'pentagonalResolutionParameterK', 21_c_long)
      if (status == 0) status = set_grib_long(handle, 'pentagonalResolutionParameterM', 21_c_long)
    end if
    if (status == 0) status = set_grib_string(handle, 'type', 'fc')
    if (status == 0) status = set_grib_long(handle, 'timeRangeIndicator', 0_c_long)
    if (status == 0) status = set_grib_string(handle, 'stepType', 'instant')
    if (status == 0) status = set_grib_string(handle, 'stepUnits', 's')
    if (status == 0) status = set_grib_long(handle, 'endStep', specification%forecast_seconds)
    if (status /= 0) goto 900
    if (specification%forecast_seconds == 0) then
      status = set_grib_string(handle, 'stepType', 'instant')
      if (status == 0) status = set_grib_long(handle, 'timeRangeIndicator', 1_c_long)
    else
      status = set_grib_string(handle, 'stepUnits', 'h')
    end if
    if (status /= 0) goto 900
    if (specification%representation == 1) then
      status = set_grib_long(handle, 'numberOfBitsContainingEachPackedValue', 16_c_long)
      if (status /= 0) goto 900
      if (specification%parameter == 152 .and. specification%model_level == 1 .and. &
          specification%force_log_surface_pressure == 1) then
        operator_value = 0.5_real64
      else
        call fit_spectrum(21_int32, 10_int32, values, intercept, slope)
        operator_value = -slope
        operator_value = min(9.9_real64, operator_value)
        operator_value = max(-9.9_real64, operator_value)
      end if
      status = set_grib_double(handle, 'laplacianOperator', operator_value)
      if (status == 0) status = set_grib_long(handle, 'subSetJ', 10_c_long)
      if (status == 0) status = set_grib_long(handle, 'subSetK', 10_c_long)
      if (status == 0) status = set_grib_long(handle, 'subSetM', 10_c_long)
    else
      unused_extreme = values(1)
      do j = 2, size(values)
        unused_extreme = min(unused_extreme, values(j))
      end do
      unused_extreme = values(1)
      do j = 2, size(values)
        unused_extreme = max(unused_extreme, values(j))
      end do
      status = set_grib_long(handle, 'numberOfBitsContainingEachPackedValue', 16_c_long)
    end if
    if (status /= 0) goto 900
    if (specification%model_level == 1) then
      status = set_grib_string(handle, 'typeOfLevel', 'hybrid')
      if (status == 0) status = set_grib_long(handle, 'level', specification%level)
    else
      status = set_grib_string(handle, 'typeOfLevel', 'isobaricInhPa')
      if (status == 0) status = set_grib_long(handle, 'level', specification%level/100_int64)
    end if
    if (status /= 0) goto 900
    text_length = 16
    status = codes_get_string(handle, 'type'//c_null_char, forecast_type, text_length)
    if (status /= 0) goto 900
    if (any(forecast_type(1:3) /= ['f', 'c', c_null_char])) then
      status = 2
      goto 900
    end if
    status = set_grib_long(handle, 'paramId', specification%parameter)
    if (status == 0) status = codes_set_double_array(handle, 'values'//c_null_char, values, specification%value_count)
    if (status == 0) status = codes_message(handle, local_message, local_length)
    if (status /= 0) goto 900
    message = local_message
    length = local_length
    owner = handle
    call increment_output_counter(calls)
    return
900 ignored = codes_delete(handle)
  end function
end module
