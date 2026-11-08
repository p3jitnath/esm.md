!> Admit native wave, linearized-physics and methane setup as one stage.
module ecmwf_physics_tail_setup_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoewcou, only: tewcou
  use yoephli, only: tephli
  use yophnc, only: tphnc
  use yoelwrad, only: telwrad
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use ecmwf_physics_tail_fields_mod, only: &
    physics_tail_upstream_record, methane_oxidation_parameter_record, &
    initialize_wave_coupling_fields, initialize_linearized_physics_fields, initialize_methane_oxidation_fields
  implicit none
  private
  public :: initialize_selected_ecmwf_physics_tail
  public :: physics_tail_upstream_record, methane_oxidation_parameter_record
contains
  !> Initialize SUWCOU, SUPHLI and SUMETHOX in their selected source order.
  !! TEXT is readonly namelist text whose first recognized NAEPHLI and
  !! NAMMETHOX groups are empty. UPSTREAM contains the live date, seconds
  !! since midnight, named physics controls and water/ice limits in K.
  !! WAVE, LINEARIZED, PHYSICS_CONTROLS, LONGWAVE_CONTROLS and METHANE
  !! are complete separate caller-owned native records. They change only
  !! in the members assigned by their numerical children. Other members,
  !! descriptors and padding retain their incoming bytes.
  !! PHYSICS_CONTROLS%LERADLW2 must be false. This selected route does not
  !! read an atmosphere-height array or introduce allocation or release.
  !! Return 0 after all three children or 2 before any output mutation for
  !! an unsupported input. Public LOG and the compiler runtime are the only
  !! external numerical services. Original formatted logging is omitted.
  integer(int32) function initialize_selected_ecmwf_physics_tail( &
    text, upstream, wave, linearized, physics_controls, longwave_controls, methane) result(status)
    character(len=*), intent(in), target :: text
    type(physics_tail_upstream_record), intent(in), target :: upstream
    type(tewcou), intent(inout), target :: wave
    type(tephli), intent(inout), target :: linearized
    type(tphnc), intent(inout), target :: physics_controls
    type(telwrad), intent(inout), target :: longwave_controls
    type(methane_oxidation_parameter_record), intent(inout), target :: methane
    integer(c_intptr_t) :: addresses(7)
    integer(int64) :: lengths(7), water_word, ice_word
    integer :: first, second
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    addresses(1) = transfer(c_loc(wave), addresses(1))
    addresses(2) = transfer(c_loc(linearized), addresses(2))
    addresses(3) = transfer(c_loc(physics_controls), addresses(3))
    addresses(4) = transfer(c_loc(longwave_controls), addresses(4))
    addresses(5) = transfer(c_loc(methane), addresses(5))
    addresses(6) = transfer(c_loc(upstream), addresses(6))
    addresses(7) = transfer(c_loc(text(1:1)), addresses(7))
    lengths(1) = storage_size(wave, kind=int64)/8_int64
    lengths(2) = storage_size(linearized, kind=int64)/8_int64
    lengths(3) = storage_size(physics_controls, kind=int64)/8_int64
    lengths(4) = storage_size(longwave_controls, kind=int64)/8_int64
    lengths(5) = storage_size(methane, kind=int64)/8_int64
    lengths(6) = storage_size(upstream, kind=int64)/8_int64
    lengths(7) = int(len(text), int64)
    do first = 1, 6
      do second = first + 1, 7
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (upstream%nindat < 10000000_int32 .or. upstream%nindat > 99999999_int32) return
    if (upstream%nsssss < 0_int32 .or. upstream%nsssss > 86399_int32) return
    water_word = transfer(upstream%rtwat, water_word)
    ice_word = transfer(upstream%rtice, ice_word)
    if (water_word <= 0_int64 .or. water_word > transfer(400.0_real64, 0_int64)) return
    if (ice_word <= 0_int64 .or. ice_word > water_word) return
    if (physics_controls%leradlw2) return
    if (.not. supported_floating_mode()) return
    status = require_empty_physics_group(text, 'NAEPHLI')
    if (status /= 0_int32) return
    status = require_empty_physics_group(text, 'NAMMETHOX')
    if (status /= 0_int32) return
    call initialize_wave_coupling_fields(upstream, wave)
    call initialize_linearized_physics_fields(upstream, linearized, physics_controls, longwave_controls)
    call initialize_methane_oxidation_fields(methane)
    status = 0_int32
  end function

  !> Check native owner spans without reproducing a private target layout.
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
  !! The enclosing launcher establishes the complete floating-point contract.
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
