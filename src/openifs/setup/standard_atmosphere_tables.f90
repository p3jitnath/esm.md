!> Calculate the standard and post-processing reference atmospheres.
!! Heights are in m, gradients in K/m, temperatures in K and pressures in Pa.
!! Each scalar assignment preserves one source FP64 rounding boundary.
!! The caller supplies nearest-even rounding and gradual underflow.
module forecast_standard_atmosphere
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use forecast_positive_logarithm, only: positive_logarithm
  use forecast_public_scalar_math, only: power_original_rounding
  implicit none
  private
  public :: atmosphere_layers, atmosphere_physical_inputs
  public :: initialize_atmosphere_layers, calculate_atmosphere_profile
  public :: adjust_postprocessing_atmosphere, copy_atmosphere_reference_tables
  type, bind(C) :: atmosphere_layers
    real(real64) :: height(9), gradient(9), temperature(9), pressure(9)
  end type
  type, bind(C) :: atmosphere_physical_inputs
    real(real64) :: gravity, dry_gas_constant, planet_scale, surface_pressure
  end type
  interface
    function public_exp(x) bind(C, name="exp") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Build all nine layer boundaries without importing a reference atmosphere.
  !! result is completely written on success and unchanged on refusal.
  !! physical contains gravity in m/s**2, gas constant in J/(kg K),
  !! dimensionless planet scale and surface pressure in Pa.
  integer(int32) function initialize_atmosphere_layers(result, physical, ecmwf) result(status)
    type(atmosphere_layers), intent(inout) :: result
    type(atmosphere_physical_inputs), intent(in) :: physical
    integer(int32), intent(in) :: ecmwf
    integer :: k
    real(real64) :: inputs(4), height_difference, change, base, exponent, factor
    integer(int64) :: bits(4)
    integer(int64), parameter :: low(4) = [int(z'4022000000000000', int64), &
                                  int(z'4070e00000000000', int64), int(z'3fe0000000000000', int64), int(z'40f5f90000000000', int64)]
    integer(int64), parameter :: high(4) = [int(z'4024000000000000', int64), &
                                  int(z'4073600000000000', int64), int(z'4000000000000000', int64), int(z'40fadb0000000000', int64)]
    status = 2
    if (ecmwf < 0 .or. ecmwf > 1) return
    inputs = [physical%gravity, physical%dry_gas_constant, physical%planet_scale, physical%surface_pressure]
    bits = transfer(inputs, bits)
    if (any(bits < low) .or. any(bits > high)) return
    result%height = [0.0_real64, 11000.0_real64, 20000.0_real64, 32100.0_real64, &
                     47400.0_real64, 51400.0_real64, 71700.0_real64, 85700.0_real64, 100000.0_real64]
    if (ecmwf == 1) then
      result%gradient = [-0.0065_real64, 0.0_real64, 0.0_real64, 0.0_real64, &
                         0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64, 0.0_real64]
    else
      result%gradient = [-0.0065_real64, 0.0_real64, 0.001_real64, 0.00275_real64, &
                         0.0_real64, -0.00275_real64, -0.00197_real64, 0.0_real64, 0.0_real64]
    end if
    result%temperature(1) = 288.15_real64
    result%pressure(1) = physical%surface_pressure
    do k = 1, 8
      height_difference = result%height(k + 1) - result%height(k)
      if (result%gradient(k) /= 0.0_real64) then
        change = result%gradient(k)*height_difference
        result%temperature(k + 1) = result%temperature(k) + change
        base = change/result%temperature(k)
        base = 1.0_real64 + base
        exponent = -physical%gravity
        exponent = exponent/physical%planet_scale
        exponent = exponent/physical%dry_gas_constant
        exponent = exponent/result%gradient(k)
        factor = power_original_rounding(base, exponent)
      else
        result%temperature(k + 1) = result%temperature(k)
        exponent = -physical%gravity
        exponent = exponent/physical%planet_scale
        exponent = exponent/physical%dry_gas_constant
        exponent = exponent/result%temperature(k)
        exponent = exponent*height_difference
        factor = public_exp(exponent)
      end if
      result%pressure(k + 1) = result%pressure(k)*factor
    end do
    status = 0
  end function

  !> Calculate model-level temperature and geopotential from full pressure.
  !! pressure, temperature and geopotential have the same length from1 to256.
  !! Geopotential has units m**2/s**2. Refused inputs leave outputs unchanged.
  integer(int32) function calculate_atmosphere_profile(temperature, geopotential, pressure, &
                                                       layers, physical) result(status)
    real(real64), contiguous, intent(inout) :: temperature(:), geopotential(:)
    real(real64), contiguous, intent(in) :: pressure(:)
    type(atmosphere_layers), intent(in) :: layers
    type(atmosphere_physical_inputs), intent(in) :: physical
    real(real64) :: input_log(256), layer_log(9), inverse_pressure(9), inverse_gradient(9)
    real(real64) :: ratio, base, exponent, height, change, term, value
    integer :: levels, j, k
    integer(int64) :: bits
    status = 2
    levels = size(pressure)
    if (levels < 1 .or. levels > 256) return
    if (size(temperature) /= levels .or. size(geopotential) /= levels) return
    do j = 1, levels
      bits = transfer(pressure(j), bits)
      if (bits < int(z'3cb0000000000000', int64) .or. bits >= int(z'7ff0000000000000', int64)) return
    end do
    do j = 1, levels
      input_log(j) = positive_logarithm(pressure(j))
    end do
    do k = 1, 9
      layer_log(k) = positive_logarithm(layers%pressure(k))
      inverse_pressure(k) = 1.0_real64/layers%pressure(k)
      inverse_gradient(k) = 0.0_real64
      if (layers%gradient(k) /= 0.0_real64) inverse_gradient(k) = 1.0_real64/layers%gradient(k)
    end do
    ratio = physical%dry_gas_constant/physical%gravity
    do j = 1, levels
      k = 1
      do while (k < 9)
        if (pressure(j) >= layers%pressure(k + 1)) exit
        k = k + 1
      end do
      if (layers%gradient(k) /= 0.0_real64) then
        base = pressure(j)*inverse_pressure(k)
        exponent = -layers%gradient(k)
        exponent = exponent*ratio
        change = power_original_rounding(base, exponent)
        change = change - 1.0_real64
        term = layers%temperature(k)*inverse_gradient(k)
        term = term*change
        height = layers%height(k) + term
        value = height - layers%height(k)
        value = layers%gradient(k)*value
        value = layers%temperature(k) + value
      else
        term = input_log(j) - layer_log(k)
        change = layers%temperature(k)*ratio
        change = change*term
        height = layers%height(k) - change
        value = layers%temperature(k)
      end if
      temperature(j) = value
      geopotential(j) = physical%gravity*height
    end do
    status = 0
  end function

  !> Move the lowest boundary to its nearest admitted model pressure.
  !! A distance tie selects the later level. Beyond5000Pa the copied table
  !! remains unchanged. All layer arrays and pressure are read-only.
  integer(int32) function adjust_postprocessing_atmosphere(result, layers, pressure, physical) result(status)
    type(atmosphere_layers), intent(inout) :: result
    type(atmosphere_layers), intent(in) :: layers
    real(real64), contiguous, intent(in) :: pressure(:)
    type(atmosphere_physical_inputs), intent(in) :: physical
    integer :: levels, j, k, nearest
    integer(int64) :: bits
    real(real64) :: distance, best, base, exponent, term, height, temperature, step, factor, zero
    status = 2
    levels = size(pressure)
    if (levels < 1 .or. levels > 256) return
    do j = 1, levels
      bits = transfer(pressure(j), bits)
      if (bits <= 0_int64 .or. bits >= int(z'7ff0000000000000', int64)) return
    end do
    result = layers
    term = pressure(1) - layers%pressure(2)
    best = abs(term)
    nearest = 1
    do j = 2, levels
      term = pressure(j) - layers%pressure(2)
      distance = abs(term)
      if (distance > best) cycle
      best = distance
      nearest = j
    end do
    status = 0
    if (best > 5000.0_real64) return
    result%pressure(2) = pressure(nearest)
    base = pressure(nearest)/physical%surface_pressure
    exponent = -result%gradient(1)
    exponent = exponent*physical%dry_gas_constant
    exponent = exponent/physical%gravity
    term = power_original_rounding(base, exponent)
    term = term - 1.0_real64
    factor = result%temperature(1)/result%gradient(1)
    term = factor*term
    zero = 0.0_real64
    height = zero + term
    result%height(2) = height
    term = height - zero
    term = result%gradient(1)*term
    temperature = result%temperature(1) + term
    result%temperature(2) = temperature
    term = layers%temperature(3) - temperature
    step = layers%height(3) - height
    result%gradient(2) = term/step
    do k = 2, 8
      step = result%height(k + 1) - result%height(k)
      exponent = -physical%gravity
      exponent = exponent/physical%dry_gas_constant
      if (result%gradient(k) /= 0.0_real64) then
        term = result%gradient(k)*step
        temperature = result%temperature(k) + term
        base = term/result%temperature(k)
        base = 1.0_real64 + base
        exponent = exponent/result%gradient(k)
        factor = power_original_rounding(base, exponent)
      else
        temperature = result%temperature(k)
        term = exponent/result%temperature(k)
        term = term*step
        factor = public_exp(term)
      end if
      result%pressure(k + 1) = result%pressure(k)*factor
      result%temperature(k + 1) = temperature
    end do
  end function

  !> Publish both complete tables into a distinct caller-owned native array.
  !! The first table is standard and the second is for post-processing.
  subroutine copy_atmosphere_reference_tables(source, destination)
    type(atmosphere_layers), intent(in) :: source(2)
    type(atmosphere_layers), intent(out) :: destination(2)
    destination = source
  end subroutine
end module forecast_standard_atmosphere
