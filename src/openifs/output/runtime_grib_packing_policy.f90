module runtime_grib_packing_policy_port
  !! Select the generated packing policy for a borrowed ecCodes handle.
  !! Values retain their field units. Packing changes metadata, not values.
  !! The caller owns the handle and supplies a contiguous complete field.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_associated, c_char, c_null_char, &
                                                                            c_long, c_double, c_int
  use, intrinsic :: ieee_arithmetic
  use forecast_spectral_packing_fit, only: fit_spectrum
  implicit none
  private
  public :: grib_packing_controls, set_runtime_grib_packing

  type :: grib_packing_controls
    integer(int32) :: simulation_index = 0, linearisation_index = 0
    integer(int32) :: log_pressure_bits = 16, expression_bits = -1
    logical :: force_geopotential = .false., force_log_pressure = .false.
  end type grib_packing_controls

  interface
    function codes_set_long(handle, key, value) bind(C, name="codes_set_long") result(status)
      import c_ptr, c_char, c_long, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), value :: value
      integer(c_int) :: status
    end function codes_set_long
    function codes_set_double(handle, key, value) bind(C, name="codes_set_double") result(status)
      import c_ptr, c_char, c_double, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), value :: value
      integer(c_int) :: status
    end function codes_set_double
    function imultio_encode_bitspervalue(bits, parameter_id, level_type, minimum, maximum) result(status)
      import int32, real64
      integer(int32), intent(out) :: bits
      integer(int32), intent(in) :: parameter_id
      character(*), intent(in) :: level_type
      real(real64), intent(in) :: minimum, maximum
      integer(int32) :: status
    end function imultio_encode_bitspervalue
  end interface

contains

  function set_runtime_grib_packing(handle, parameter_id, level_type, spectral, &
                                    gradient, values, truncation, controls) result(status)
    !! Apply spectral or gridpoint packing in the source setter order.
    !!
    !! parameter_id is nonnegative. level_type has 1 to 32 nonzero bytes,
    !! with no final space. Spectral values have (N+1)*(N+2) elements for
    !! truncation N in 1:4096. Grid values have 1:2147483647 finite elements.
    !! The largest finite real64 value marks a missing grid value.
    !! Controls use bit counts 0:64, or -1:64 for expression_bits.
    !! A public-service failure returns its status and retains earlier
    !! metadata changes. An invalid argument returns two before any setter.
    type(c_ptr), intent(in) :: handle
    integer(int32), intent(in) :: parameter_id, truncation
    character(*), intent(in) :: level_type
    logical, intent(in) :: spectral, gradient
    real(real64), contiguous, intent(in) :: values(:)
    type(grib_packing_controls), intent(in) :: controls
    integer(int32) :: status
    integer(int32) :: bits, subset
    integer :: j, length
    real(real64) :: beta0, beta1, operator, minimum, maximum
    real(real64), parameter :: limit = 9.9_real64
    logical :: model_level, gradual, has_missing
    type(ieee_round_type) :: rounding

    status = 2_int32
    call ieee_get_rounding_mode(rounding)
    gradual = .true.
    if (ieee_support_underflow_control(0.0_real64)) call ieee_get_underflow_mode(gradual)
    if (rounding /= ieee_nearest .or. .not. gradual) return
    if (.not. c_associated(handle) .or. parameter_id < 0) return
    length = len(level_type)
    if (length < 1 .or. length > 32) return
    if (index(level_type, c_null_char) /= 0) return
    if (level_type(length:length) == ' ') return
    if (size(values, kind=int64) < 1_int64 .or. size(values, kind=int64) > 2147483647_int64) return
    if (controls%log_pressure_bits < 0 .or. controls%log_pressure_bits > 64) return
    if (controls%expression_bits < (-1) .or. controls%expression_bits > 64) return
    if (spectral) then
      if (truncation < 1 .or. truncation > 4096) return
      if (size(values, kind=int64) /= int(truncation + 1, int64)*int(truncation + 2, int64)) return
    end if
    do j = 1, size(values)
      if (.not. ieee_is_finite(values(j))) return
    end do

    model_level = level_type(1:1) == 'm'
    if (length >= 2) then
      if (level_type(1:2) == 'ML') model_level = .true.
    end if
    status = 0_int32
    if (spectral) then
      bits = 16_int32
      if (parameter_id == 152 .and. model_level) then
        if (controls%simulation_index /= controls%linearisation_index) &
          bits = controls%log_pressure_bits
      end if
      call put_long('numberOfBitsContainingEachPackedValue', int(bits, c_long))
      if (status /= 0) return
      subset = 10_int32
      if (truncation >= 213) subset = 20_int32
      if (subset > truncation) subset = truncation
      if (model_level .and. parameter_id == 129 .and. controls%force_geopotential) then
        operator = 0.5_real64
      else if (model_level .and. parameter_id == 152 .and. .not. gradient .and. &
               controls%force_log_pressure) then
        operator = 0.5_real64
      else if (subset < truncation) then
        call fit_spectrum(truncation, subset, values, beta0, beta1)
        operator = -beta1
        ! FMINNM followed by FMAXNM selects +limit for a NaN fit.
        if (ieee_is_nan(operator)) then
          operator = limit
        else
          if (operator > limit) operator = limit
          if (operator < (-limit)) operator = -limit
        end if
      else
        operator = 0.0_real64
      end if
      call put_double('laplacianOperator', operator)
      call put_long('subSetJ', int(subset, c_long))
      call put_long('subSetK', int(subset, c_long))
      call put_long('subSetM', int(subset, c_long))
    else
      has_missing = .false.
      do j = 1, size(values)
        if (values(j) == huge(0.0_real64)) then
          has_missing = .true.
          exit
        end if
      end do
      if (has_missing) then
        call put_long('bitmapPresent', 1_c_long)
        call put_double('missingValue', huge(0.0_real64))
        if (status /= 0) return
      end if
      bits = controls%expression_bits
      if (.not. (bits > 0 .and. parameter_id >= 80 .and. parameter_id <= 120)) then
        minimum = ieee_value(0.0_real64, ieee_positive_inf)
        do j = 1, size(values)
          if (values(j) < minimum) minimum = values(j)
        end do
        maximum = ieee_value(0.0_real64, ieee_negative_inf)
        do j = 1, size(values)
          if (values(j) > maximum) maximum = values(j)
        end do
        status = imultio_encode_bitspervalue(bits, parameter_id, level_type, minimum, maximum)
        if (status /= 0) return
      end if
      call put_long('numberOfBitsContainingEachPackedValue', int(bits, c_long))
    end if

  contains

    subroutine put_long(key, value)
      character(*), intent(in) :: key
      integer(c_long), intent(in) :: value
      if (status == 0) status = codes_set_long(handle, key//c_null_char, value)
    end subroutine put_long

    subroutine put_double(key, value)
      character(*), intent(in) :: key
      real(c_double), intent(in) :: value
      if (status == 0) status = codes_set_double(handle, key//c_null_char, value)
    end subroutine put_double

  end function set_runtime_grib_packing
end module runtime_grib_packing_policy_port
