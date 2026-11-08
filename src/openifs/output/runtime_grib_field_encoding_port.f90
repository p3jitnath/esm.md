module runtime_grib_field_encoding_port
  !! Encode one complete weather field with the generated header order.
  !! The ecCodes library owns templates and encoded message memory.
  use, intrinsic :: iso_c_binding
  use runtime_grib_template_port, only: runtime_grib_edition
  use runtime_grib_time_port, only: set_runtime_grib_time
  use runtime_grib_packing_policy_port, only: grib_packing_controls, set_runtime_grib_packing
  implicit none
  private
  public :: grib_field_metadata, encode_runtime_grib_field, runtime_grib_edition

  type :: grib_field_metadata
    !! Counts and identifiers have no units. dt is in seconds.
    type(c_ptr) :: template = c_null_ptr
    integer(c_int) :: parameter_id = 0, level = 0, nstep = 0, truncation = 1, hours_mode = 0
    character :: level_kind = 's'
    logical :: spectral = .false.
    real(c_double) :: dt = 0.0_c_double
    integer(c_int) :: previous(10) = 0, soil_levels(36) = 0
    integer(c_size_t) :: workspace_limit_bytes = 0
    type(grib_packing_controls) :: packing
  end type

  interface
    function codes_clone(template) bind(c, name="codes_handle_clone") result(handle)
      import
      type(c_ptr), value :: template
      type(c_ptr) :: handle
    end function
    function codes_delete(handle) bind(c, name="codes_handle_delete") result(status)
      import
      type(c_ptr), value :: handle
      integer(c_int) :: status
    end function
    function codes_set_long(handle, key, value) bind(c, name="codes_set_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), value :: value
      integer(c_int) :: status
    end function
    function codes_set_string(handle, key, text, length) bind(c, name="codes_set_string") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*), text(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function codes_get_string(handle, key, text, length) bind(c, name="codes_get_string") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      character(c_char), intent(out) :: text(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function codes_set_doubles(handle, key, values, length) bind(c, name="codes_set_double_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), intent(in) :: values(*)
      integer(c_size_t), value :: length
      integer(c_int) :: status
    end function
    function codes_message(handle, message, length) bind(c, name="codes_get_message") result(status)
      import
      type(c_ptr), value :: handle
      type(c_ptr), intent(out) :: message
      integer(c_size_t), intent(out) :: length
      integer(c_int) :: status
    end function
  end interface

contains

  function encode_runtime_grib_field(metadata, values, message, length, owner) result(status)
    !! Read the complete contiguous FP64 field. On success, message and length
    !! describe borrowed bytes that remain valid until the caller deletes owner.
    !! An excluded time window returns a null message, zero length and a live
    !! owner to delete. Failure preserves all three caller output arguments.
    !! The caller supplies disjoint storage and the declared nearest-rounding,
    !! gradual-underflow environment. No private OpenIFS layout is consumed.
    type(grib_field_metadata), intent(in) :: metadata
    real(c_double), contiguous, intent(in) :: values(:)
    type(c_ptr), intent(inout) :: message, owner
    integer(c_size_t), intent(inout) :: length
    integer(c_int) :: status, ignored, valid, parameter_id, top, bottom
    integer(c_int64_t) :: count, bits
    integer(c_size_t) :: required_bytes, local_length, text_length
    integer :: j
    type(c_ptr) :: handle, local_message
    type(grib_packing_controls) :: controls
    character(2) :: packing_level
    character(c_char) :: forecast_type(16)

    status = 2
    if (.not. c_associated(metadata%template)) return
    if (metadata%parameter_id < 0 .or. metadata%nstep < 0) return
    if (metadata%parameter_id == 260510 .or. metadata%parameter_id == 260511) return
    select case (metadata%level_kind)
    case ('m', 'p', 'v', 't')
    case ('s')
      if (metadata%level < 0 .or. metadata%level > 512) return
    case default
      return
    end select
    count = size(values, kind=c_int64_t)
    if (count < 1 .or. count > 2147483647_c_int64_t) return
    if (metadata%truncation < 1 .or. metadata%truncation > 4096) return
    if (metadata%spectral) then
      if (count /= int(metadata%truncation + 1, c_int64_t)*int(metadata%truncation + 2, c_int64_t)) return
    end if
    required_bytes = 1024_c_size_t + 16_c_size_t*int(metadata%truncation + 1, c_size_t)
    if (metadata%workspace_limit_bytes > 68719476736_c_size_t) return
    if (required_bytes > metadata%workspace_limit_bytes) return
    do j = 1, size(values)
      bits = transfer(values(j), bits)
      if (ibits(bits, 52, 11) == 2047) return
    end do
    handle = codes_clone(metadata%template)
    if (.not. c_associated(handle)) then
      status = 1
      return
    end if

    status = 0
    if (metadata%spectral) then
      call put_long('pentagonalResolutionParameterJ', int(metadata%truncation, c_long))
      call put_long('pentagonalResolutionParameterK', int(metadata%truncation, c_long))
      call put_long('pentagonalResolutionParameterM', int(metadata%truncation, c_long))
    end if
    call put_string('type', 'fc')
    if (status /= 0) goto 900
    valid = -1
    status = set_runtime_grib_time(handle, metadata%parameter_id, metadata%nstep, metadata%dt, &
                                   metadata%hours_mode, metadata%previous, valid)
    if (status /= 0) goto 900
    if (valid == 0) then
      message = c_null_ptr
      length = 0_c_size_t
      owner = handle
      return
    end if

    controls = metadata%packing
    controls%simulation_index = 0
    controls%linearisation_index = 999
    select case (metadata%level_kind)
    case ('m')
      packing_level = 'ML'
    case ('p')
      packing_level = 'PL'
    case ('v')
      packing_level = 'PV'
    case ('t')
      packing_level = 'TH'
    case default
      packing_level = 'SF'
    end select
    status = set_runtime_grib_packing(handle, metadata%parameter_id, packing_level, &
                                      metadata%spectral, .false., values, metadata%truncation, controls)
    if (status /= 0) goto 900

    top = -1
    bottom = -1
    select case (metadata%level_kind)
    case ('s')
      call put_string('typeOfLevel', 'surface')
      call put_long('level', 0_c_long)
      if (metadata%level /= 0) then
        select case (metadata%parameter_id)
        case (33, 238, 228141, 228038)
          call put_string('typeOfLevel', 'snowLayer')
          call put_long('typeOfFirstFixedSurface', 114_c_long)
          call put_long('typeOfSecondFixedSurface', 114_c_long)
          call put_long('scaleFactorOfFirstFixedSurface', 0_c_long)
          call put_long('scaledValueOfFirstFixedSurface', int(metadata%level - 1, c_long))
          call put_long('scaleFactorOfSecondFixedSurface', 0_c_long)
          call put_long('scaledValueOfSecondFixedSurface', int(metadata%level, c_long))
          call put_long('level', int(metadata%level, c_long))
        end select
      end if
      do j = 1, 12
        if (metadata%soil_levels(j) /= metadata%parameter_id) cycle
        bottom = metadata%soil_levels(12 + j)
        top = metadata%soil_levels(24 + j)
        if (top < 0 .or. bottom < 0) exit
        call put_string('typeOfLevel', 'depthBelowLandLayer')
        call put_long('level', 0_c_long)
        call put_long('topLevel', int(top, c_long))
        call put_long('bottomLevel', int(bottom, c_long))
        exit
      end do
    case ('m')
      call put_string('typeOfLevel', 'hybrid')
      call put_long('level', int(metadata%level, c_long))
    case ('v')
      call put_string('typeOfLevel', 'potentialVorticity')
      call put_long('level', int(metadata%level, c_long))
    case ('p')
      if (metadata%level >= 100) then
        call put_string('typeOfLevel', 'isobaricInhPa')
        call put_long('level', int(metadata%level/100, c_long))
      else
        call put_string('typeOfLevel', 'isobaricInPa')
        call put_long('level', int(metadata%level, c_long))
      end if
    case ('t')
      call put_string('typeOfLevel', 'theta')
      call put_long('level', int(metadata%level, c_long))
    end select
    if (status /= 0) goto 900

    text_length = 16_c_size_t
    status = codes_get_string(handle, 'type'//c_null_char, forecast_type, text_length)
    if (status /= 0) goto 900
    if (forecast_type(1) /= 'f' .or. forecast_type(2) /= 'c' .or. forecast_type(3) /= c_null_char) then
      status = 2
      goto 900
    end if
    parameter_id = metadata%parameter_id
    if (parameter_id/1000 == 128) parameter_id = modulo(parameter_id, 1000_c_int)
    if (parameter_id /= 128) call put_long('paramId', int(parameter_id, c_long))
    if (status /= 0) goto 900
    status = codes_set_doubles(handle, 'values'//c_null_char, values, int(count, c_size_t))
    if (status /= 0) goto 900
    status = codes_message(handle, local_message, local_length)
    if (status /= 0) goto 900
    message = local_message
    length = local_length
    owner = handle
    return

900 ignored = codes_delete(handle)

  contains
    subroutine put_long(key, value)
      character(*), intent(in) :: key
      integer(c_long), intent(in) :: value
      if (status /= 0) return
      status = codes_set_long(handle, key//c_null_char, value)
    end subroutine
    subroutine put_string(key, value)
      character(*), intent(in) :: key, value
      integer(c_size_t) :: text_size
      if (status /= 0) return
      text_size = int(len(value), c_size_t)
      status = codes_set_string(handle, key//c_null_char, value//c_null_char, text_size)
    end subroutine
  end function
end module
