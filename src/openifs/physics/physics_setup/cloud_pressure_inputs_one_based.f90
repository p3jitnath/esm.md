!> Form the cloud setup pressures from live native vertical coefficients.
module cloud_pressure_inputs_one_based_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_int, c_ptr, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  use vertical_configuration_port, only: native_vertical_configuration
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: initialize_cloud_pressure_inputs, initialize_runtime_cloud_pressure_inputs
  public :: hybrid_pressure_controls, initialize_selected_cloud_pressure_controls
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Form the original nineteen-level pressure and dimensionless eta arrays.
  !! CONTROLS and the seven coefficient arrays are readonly native vertical
  !! metadata. Pressure is in Pa; eta is pressure divided by surface pressure.
  !! HALF_PRESSURE and HALF_ETA have lower bound zero and twenty elements.
  !! FULL_PRESSURE and FULL_ETA have nineteen elements. All four contiguous
  !! outputs are separate caller-owned arrays. The compiler owns their ABI.
  !! The caller supplies previously admitted finite vertical coefficients and
  !! a positive SURFACE_PRESSURE in Pa. Only the count differs at runtime.
  !! Return 2 before mutation on an unsupported shape, overlap or FP mode.
  !! Return 1 if the accepted pressure child cannot allocate its own work.
  !! Such a resource failure can leave pressure outputs partly written;
  !! discard this setup result. Return 0 after both ordered division loops.
  integer(int32) function initialize_cloud_pressure_inputs(controls, surface_pressure, &
                                                           a_half, b_half, vc, full_a, full_b, delta_a, delta_b, &
                                                           half_pressure, full_pressure, half_eta, full_eta) result(status)
    type(hybrid_pressure_controls), intent(in), target :: controls
    real(real64), intent(in), target :: surface_pressure
    real(real64), intent(in), contiguous, target :: a_half(0:), b_half(0:), vc(1:)
    real(real64), intent(in), contiguous, target :: full_a(1:), full_b(1:), delta_a(1:), delta_b(1:)
    real(real64), intent(inout), contiguous, target :: half_pressure(0:), full_pressure(:)
    real(real64), intent(inout), contiguous, target :: half_eta(0:), full_eta(:)
    status = 2_int32
    if (size(full_pressure) /= 19) return
    status = initialize_runtime_cloud_pressure_inputs(controls, surface_pressure, &
                             a_half, b_half, vc, full_a, full_b, delta_a, delta_b, half_pressure, full_pressure, half_eta, full_eta)
  end function

  !> Form pressure and eta for a live vertical count from 2 through 512.
  !! LEVELS is derived from SIZE(FULL_PRESSURE). Half-level arrays have
  !! LEVELS+1 elements, full-level arrays have LEVELS elements. A_HALF and
  !! B_HALF supply at least LEVELS elements with native lower bound zero.
  !! The five layer coefficient arrays have lower bound one and supply at least
  !! LEVELS elements. Their meanings,
  !! units, ownership, mutation and failure rules match the entry above.
  !! The accepted GPHPRE child receives field indices 1 through 7 in order.
  !! Its existing FE or FV branch comes from CONTROLS, without a new default.
  !! Preserve every pressure result before the ascending half-eta loop,
  !! then run the ascending full-eta loop. Keep genuine FP status events
  !! while restoring errno after the child's private allocation lifetime.
  integer(int32) function initialize_runtime_cloud_pressure_inputs(controls, surface_pressure, &
                                                                   a_half, b_half, vc, full_a, full_b, delta_a, delta_b, &
                                                                   half_pressure, full_pressure, half_eta, full_eta) result(status)
    type(hybrid_pressure_controls), intent(in), target :: controls
    real(real64), intent(in), target :: surface_pressure
    real(real64), intent(in), contiguous, target :: a_half(0:), b_half(0:), vc(1:)
    real(real64), intent(in), contiguous, target :: full_a(1:), full_b(1:), delta_a(1:), delta_b(1:)
    real(real64), intent(inout), contiguous, target :: half_pressure(0:), full_pressure(:)
    real(real64), intent(inout), contiguous, target :: half_eta(0:), full_eta(:)
    real(real64), pointer :: half_view(:, :), full_view(:, :)
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer(int32) :: levels, level, child_status
    integer(int32), parameter :: field_index(7) = [1, 2, 3, 4, 5, 6, 7]
    integer(c_intptr_t) :: addresses(13)
    integer(int64) :: lengths(13)
    integer :: first, second
    real(real64) :: bottom
    status = 2_int32
    levels = size(full_pressure)
    if (levels < 2 .or. levels > 512) return
    if (size(half_pressure) /= levels + 1 .or. size(half_eta) /= levels + 1) return
    if (size(full_eta) /= levels) return
    if (size(a_half) < levels .or. size(b_half) < levels) return
    if (size(vc) < levels .or. size(full_a) < levels .or. size(full_b) < levels) return
    if (size(delta_a) < levels .or. size(delta_b) < levels) return
    addresses = [transfer(c_loc(half_pressure), 0_c_intptr_t), transfer(c_loc(full_pressure), 0_c_intptr_t), &
                 transfer(c_loc(half_eta), 0_c_intptr_t), transfer(c_loc(full_eta), 0_c_intptr_t), &
                 transfer(c_loc(controls), 0_c_intptr_t), transfer(c_loc(surface_pressure), 0_c_intptr_t), &
                 transfer(c_loc(a_half), 0_c_intptr_t), transfer(c_loc(b_half), 0_c_intptr_t), transfer(c_loc(vc), 0_c_intptr_t), &
                 transfer(c_loc(full_a), 0_c_intptr_t), transfer(c_loc(full_b), 0_c_intptr_t), &
                 transfer(c_loc(delta_a), 0_c_intptr_t), transfer(c_loc(delta_b), 0_c_intptr_t)]
    lengths = [int(size(half_pressure), int64)*8_int64, int(size(full_pressure), int64)*8_int64, &
               int(size(half_eta), int64)*8_int64, int(size(full_eta), int64)*8_int64, &
               storage_size(controls, kind=int64)/8_int64, 8_int64, &
               int(size(a_half), int64)*8_int64, int(size(b_half), int64)*8_int64, int(size(vc), int64)*8_int64, &
               int(size(full_a), int64)*8_int64, int(size(full_b), int64)*8_int64, &
               int(size(delta_a), int64)*8_int64, int(size(delta_b), int64)*8_int64]
    do first = 1, 4
      do second = first + 1, 13
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    half_view(1:1, 0:levels) => half_pressure
    full_view(1:1, 1:levels) => full_pressure
    half_pressure(levels) = surface_pressure
    call compute_hybrid_pressure_one_based(controls, 1_int32, 1_int32, 1_int32, levels, a_half, b_half, &
                                           half_view, child_status, number_fields=7_int32, field_index=field_index, vc=vc, &
                                           full_a=full_a, full_b=full_b, delta_a=delta_a, delta_b=delta_b, full_pressure=full_view)
    errno_value = incoming_errno
    status = child_status
    if (status /= 0_int32) return
    bottom = half_pressure(levels)
    do level = 0, levels
      half_eta(level) = half_pressure(level)/bottom
    end do
    do level = 1, levels
      full_eta(level) = full_pressure(level)/bottom
    end do
    status = 0_int32
  end function

  !> Map the selected native producer fields into the pressure control type.
  !! VERTICAL is the accepted typed vertical configuration. TOP_PRESSURE is
  !! its complete vertical system's TOPPRES value in Pa. CONSTANTS supplies
  !! dry gas constant RD and heat capacity RCVD in J kg^-1 K^-1.
  !! The selected producer has NDLNPR zero, LVERTFE one and LAPRXPK one.
  !! The mapping follows the retained original GPHPRE bridge directly:
  !! approximation=NDLNPR, finite elements=LVERTFE, arithmetic pressure=LAPRXPK,
  !! top alpha=RHYDR0. No flag is inferred or negated.
  !! Only the seven named output fields change; native padding stays incoming.
  !! Return 0 on completion or 2 before mutation on invalid selected input.
  integer(int32) function initialize_selected_cloud_pressure_controls(vertical, top_pressure, constants, controls) result(status)
    type(native_vertical_configuration), intent(in), target :: vertical
    real(real64), intent(in), target :: top_pressure
    type(forecast_physical_constants), intent(in), target :: constants
    type(hybrid_pressure_controls), intent(inout), target :: controls
    integer(c_intptr_t) :: output_address, input_address(3)
    integer(int64) :: output_length, input_length(3), bits
    integer :: i
    status = 2_int32
    if (vertical%ndlnpr /= 0 .or. vertical%lvertfe /= 1 .or. vertical%laprxpk /= 1) return
    if (constants%initialized /= 1) return
    bits = transfer(top_pressure, 0_int64)
    if (bits < 0 .or. bits >= int(z'7FF0000000000000', int64)) return
    bits = transfer(vertical%rhydr0, 0_int64)
    if (bits <= 0 .or. bits >= int(z'7FF0000000000000', int64)) return
    bits = transfer(constants%rd, 0_int64)
    if (bits <= 0 .or. bits >= int(z'7FF0000000000000', int64)) return
    bits = transfer(constants%rcvd, 0_int64)
    if (bits <= 0 .or. bits >= int(z'7FF0000000000000', int64)) return
    output_address = transfer(c_loc(controls), 0_c_intptr_t)
    output_length = storage_size(controls, kind=int64)/8_int64
    input_address = [transfer(c_loc(vertical), 0_c_intptr_t), transfer(c_loc(top_pressure), 0_c_intptr_t), &
                     transfer(c_loc(constants), 0_c_intptr_t)]
    input_length = [storage_size(vertical, kind=int64)/8_int64, 8_int64, &
                    storage_size(constants, kind=int64)/8_int64]
    do i = 1, 3
      if (.not. disjoint(output_address, output_length, input_address(i), input_length(i))) return
    end do
    controls%approximate_mode = vertical%ndlnpr
    controls%finite_elements = vertical%lvertfe /= 0
    controls%arithmetic_full_pressure = vertical%laprxpk /= 0
    controls%top_alpha = vertical%rhydr0
    controls%top_pressure = top_pressure
    controls%dry_gas_constant = constants%rd
    controls%dry_isochoric_heat_capacity = constants%rcvd
    status = 0_int32
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
