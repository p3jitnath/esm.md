!> Construct selected thermal-radiation band integrals with native owners.
module spectral_planck_parameter_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_ptr, c_int, c_f_pointer, c_double
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_all, ieee_underflow, ieee_inexact
  use yoe_spectral_planck, only: tspectralplanck
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: create_selected_spectral_planck, fill_selected_spectral_planck_table, release_selected_spectral_planck
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
    function selected_public_exp(value) bind(C, name='exp') result(exponential)
      import :: c_double
      real(c_double), value :: value
      real(c_double) :: exponential
    end function
  end interface
contains
  !> Own the selected two-band table from150through350K in one-kelvin steps.
  !! OUTPUT is a caller-owned native TSPECTRALPLANCK with three unallocated
  !! arrays. CONSTANTS is readonly, from the accepted own physical producer.
  !! Allocate wavelength boundaries(2), interval map(3), then table(2,201).
  !! Boundaries8and13micrometres and map1,2,1 define the selected bands.
  !! The complete record spans must be separate, and the four consumed
  !! physical constants must be positive finite FP64 values. Return2 before
  !! writes on invalid input,1 after cleanup on allocation failure, else0.
  !! Scalar writes completed before a resource failure remain observable.
  !! No original constructor, global constant or numerical body is called.
  integer(int32) function create_selected_spectral_planck(output, constants) result(status)
    type(tspectralplanck), intent(inout), target :: output
    type(forecast_physical_constants), intent(in), target :: constants
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno, failure_errno
    integer(int32) :: release_result
    integer :: allocation_status, index
    integer(c_intptr_t) :: first, second
    real(real64) :: physical(4)
    logical :: incoming_flags(size(ieee_all))
    status = 2_int32
    if (allocated(output%planck_lut)) return
    if (allocated(output%wavlen_bound)) return
    if (allocated(output%interval_map)) return
    physical = [constants%rpi, constants%rclum, constants%rhpla, constants%rkbol]
    do index = 1, 4
      if (.not. positive_finite(physical(index))) return
    end do
    first = transfer(c_loc(output), first)
    second = transfer(c_loc(constants), second)
    if (.not. disjoint(first, storage_size(output, kind=int64)/8_int64, &
                       second, storage_size(constants, kind=int64)/8_int64)) return
    if (.not. supported_floating_mode()) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    allocate (output%wavlen_bound(2), stat=allocation_status)
    if (allocation_status /= 0) goto100
    output%wavlen_bound = [8.0e-6_real64, 13.0e-6_real64]
    allocate (output%interval_map(3), stat=allocation_status)
    if (allocation_status /= 0) goto100
    output%interval_map = [1_int32, 2_int32, 1_int32]
    output%nintervals = 2_int32
    output%ntemps = 201_int32
    output%temp1 = 150.0_real64
    output%dtemp = 1.0_real64
    allocate (output%planck_lut(2, 201), stat=allocation_status)
    if (allocation_status /= 0) goto100
    output%planck_lut = 0.0_real64
    call ieee_set_flag(ieee_all, incoming_flags)
    call fill_selected_spectral_planck_table(output, constants)
    errno_value = incoming_errno
    status = 0_int32
    return
100 continue
    failure_errno = errno_value
    release_result = release_selected_spectral_planck(output)
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = failure_errno
    status = 1_int32
  end function

  !> Integrate the Planck law in temperature,range,wavelength source order.
  !! OUTPUT owns a zeroed PLANCK_LUT(2,201), boundaries(2) in metres and
  !! map(3) with values1,2,1. It has TEMP1=150K and DTEMP=1K.
  !! CONSTANTS supplies pi,light speed,Planck constant and Boltzmann constant.
  !! Each range uses100Simpson subintervals with endpoint weights1and
  !! interior weights4,2 in alternating order. One cell receives two ranges.
  !! Every named intermediate keeps the separate generated FP64 operation.
  !! The table stores integrated thermal irradiance in Wm**(-2). The caller
  !! admits bounds and selected metadata; this raw child allocates nothing.
  subroutine fill_selected_spectral_planck_table(output, constants)
    type(tspectralplanck), intent(inout) :: output
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32) :: temperature_index, range_index, node, weight, interval
    real(real64) :: scale, exponent_scale, temperature, lower, upper, step, total
    real(real64) :: wavelength, squared, argument, exponential, denominator, term, integral
    scale = 2.0_real64*constants%rpi
    scale = scale*constants%rhpla
    scale = scale*constants%rclum
    scale = scale*constants%rclum
    exponent_scale = constants%rhpla*constants%rclum
    exponent_scale = exponent_scale/constants%rkbol
    do temperature_index = 0, 200
      temperature = real(temperature_index, real64)*output%dtemp
      temperature = output%temp1 + temperature
      do range_index = 1, 3
        select case (range_index)
        case (1)
          upper = output%wavlen_bound(1)
          lower = 0.8_real64*upper
          lower = min(1.0e-6_real64, lower)
        case (2)
          lower = output%wavlen_bound(1)
          upper = output%wavlen_bound(2)
        case (3)
          lower = output%wavlen_bound(2)
          upper = lower + 20.0e-6_real64
          upper = max(200.0e-6_real64, upper)
        end select
        step = upper - lower
        step = step/100.0_real64
        total = 0.0_real64
        do node = 0, 100
          weight = 1_int32
          if (node /= 0 .and. node /= 100) weight = 2_int32 + 2_int32*iand(node, 1_int32)
          wavelength = step*real(node, real64)
          wavelength = lower + wavelength
          squared = wavelength*wavelength
          argument = wavelength*temperature
          argument = exponent_scale/argument
          exponential = selected_public_exp(argument)
          exponential = exponential - 1.0_real64
          denominator = squared*squared
          denominator = denominator*wavelength
          denominator = denominator*exponential
          term = real(weight, real64)/denominator
          total = total + term
        end do
        integral = scale*total
        integral = integral*step
        integral = integral/3.0_real64
        interval = output%interval_map(range_index)
        output%planck_lut(interval, temperature_index + 1) = output%planck_lut(interval, temperature_index + 1) + integral
      end do
    end do
  end subroutine

  !> Release the table,bounds,map owners in that generated order.
  !! OUTPUT remains caller-owned. Only its three native associations change.
  !! Repeated release succeeds. Incoming errno and FP flags remain intact.
  !! Return0 after release or1 if a native deallocation reports failure.
  integer(int32) function release_selected_spectral_planck(output) result(status)
    type(tspectralplanck), intent(inout) :: output
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer :: release_status
    logical :: incoming_flags(size(ieee_all))
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    status = 0_int32
    if (allocated(output%planck_lut)) then
      deallocate (output%planck_lut, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%wavlen_bound)) then
      deallocate (output%wavlen_bound, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%interval_map)) then
      deallocate (output%interval_map, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = incoming_errno
  end function

  !> Check positive finite bits without changing floating exception flags.
  logical function positive_finite(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, word)
    valid = word > 0_int64 .and. word < int(z'7ff0000000000000', int64)
  end function

  !> Check native storage without constructing a private target layout.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Require nearest rounding and gradual underflow without changing flags.
  !! The launcher establishes the complete target floating-point contract.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module
