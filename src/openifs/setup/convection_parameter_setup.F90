!> Admit selected convection inputs before either numerical child writes.
module convection_parameter_setup_port
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoecumf, only: tecumf
  use yoecumf2, only: tecumf2
  use yomcumfs, only: tcumfs
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use convection_parameter_fields_mod, only: &
    convection_thermal_parameter_record, initialize_cumulus_convection_fields
  use convection_linearized_parameter_fields_mod, only: initialize_linearized_convection_fields
  implicit none
  private
  public :: initialize_convection_parameters, initialize_runtime_convection_parameters
contains
  !> Initialize the selected 19-level SUCUMF and SUCUMF2 parameter records.
  !! TEXT is readonly namelist text. The first recognized NAMCUMF and
  !! NAMCUMFS groups must both be empty. MAIN, LINEARIZED, SWITCHES and
  !! THERMAL are separate caller-owned output records. Unwritten members
  !! and padding retain their incoming bytes. PRESSURE is readonly in Pa
  !! and must contain at least 19 levels. CONSTANTS supplies RG in m s^-2
  !! and RTT in K. SCALINGS contains dimensionless RPLRG, RPLDARE and
  !! RPLRADI, in that order. TIMESTEP is readonly in seconds. The selected
  !! source disables its limiter but the enclosing parent admits its value.
  !! SPECTRAL_LIMIT is the original selected degree 21. Return 0 after
  !! both children or 2 before any output write on an unsupported input.
  integer(int32) function initialize_convection_parameters( &
    text, main, linearized, switches, thermal, pressure, constants, scalings, timestep, spectral_limit) result(status)
    character(len=*), intent(in), target :: text
    type(tecumf), intent(inout), target :: main
    type(tecumf2), intent(inout), target :: linearized
    type(tcumfs), intent(inout), target :: switches
    type(convection_thermal_parameter_record), intent(inout), target :: thermal
    real(real64), intent(in), target :: pressure(:), scalings(3), timestep
    type(forecast_physical_constants), intent(in), target :: constants
    integer(int32), intent(in), target :: spectral_limit
    integer(int32), target :: levels
    status = 2_int32
    if (spectral_limit /= 21_int32) return
    levels = 19_int32
    status = initialize_selected(text, main, linearized, switches, thermal, pressure, &
                                 levels, constants, scalings, timestep, spectral_limit)
  end function

  !> Admit the same live-level numerical children for 4 through 512 levels.
  !! LEVELS is an explicit int32 count no larger than SIZE(PRESSURE).
  !! Extra pressure cells remain unread and unchanged. SPECTRAL_LIMIT is
  !! a positive upstream degree and does not change the child arithmetic.
  !! All remaining arguments, mutation and return values match the default
  !! entry. This native extension does not read an original model object.
  integer(int32) function initialize_runtime_convection_parameters( &
    text, main, linearized, switches, thermal, pressure, levels, constants, scalings, timestep, spectral_limit) result(status)
    character(len=*), intent(in), target :: text
    type(tecumf), intent(inout), target :: main
    type(tecumf2), intent(inout), target :: linearized
    type(tcumfs), intent(inout), target :: switches
    type(convection_thermal_parameter_record), intent(inout), target :: thermal
    real(real64), intent(in), target :: pressure(:), scalings(3), timestep
    type(forecast_physical_constants), intent(in), target :: constants
    integer(int32), intent(in), target :: levels, spectral_limit
    status = 2_int32
    if (levels < 4_int32 .or. levels > 512_int32) return
    if (spectral_limit < 1_int32) return
    status = initialize_selected(text, main, linearized, switches, thermal, pressure, &
                                 levels, constants, scalings, timestep, spectral_limit)
  end function

  !> Validate native shapes, owners and physical domains before mutation.
  integer(int32) function initialize_selected( &
    text, main, linearized, switches, thermal, pressure, levels, constants, scalings, timestep, spectral_limit) result(status)
    character(len=*), intent(in), target :: text
    type(tecumf), intent(inout), target :: main
    type(tecumf2), intent(inout), target :: linearized
    type(tcumfs), intent(inout), target :: switches
    type(convection_thermal_parameter_record), intent(inout), target :: thermal
    real(real64), intent(in), target :: pressure(:), scalings(3), timestep
    type(forecast_physical_constants), intent(in), target :: constants
    integer(int32), intent(in), target :: levels, spectral_limit
    integer(c_intptr_t) :: addresses(11)
    integer(int64) :: lengths(11), word
    integer :: first, second, level
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (size(pressure) < levels) return
    if (.not. is_contiguous(pressure)) return
    addresses(1) = transfer(c_loc(main), addresses(1))
    addresses(2) = transfer(c_loc(linearized), addresses(2))
    addresses(3) = transfer(c_loc(switches), addresses(3))
    addresses(4) = transfer(c_loc(thermal), addresses(4))
    addresses(5) = transfer(c_loc(text(1:1)), addresses(5))
    addresses(6) = transfer(c_loc(pressure(1)), addresses(6))
    addresses(7) = transfer(c_loc(constants), addresses(7))
    addresses(8) = transfer(c_loc(scalings(1)), addresses(8))
    addresses(9) = transfer(c_loc(timestep), addresses(9))
    addresses(10) = transfer(c_loc(levels), addresses(10))
    addresses(11) = transfer(c_loc(spectral_limit), addresses(11))
    lengths(1) = storage_size(main, kind=int64)/8_int64
    lengths(2) = storage_size(linearized, kind=int64)/8_int64
    lengths(3) = storage_size(switches, kind=int64)/8_int64
    lengths(4) = storage_size(thermal, kind=int64)/8_int64
    lengths(5) = int(len(text), int64)
    lengths(6) = 8_int64*int(levels, int64)
    lengths(7) = storage_size(constants, kind=int64)/8_int64
    lengths(8) = 24_int64
    lengths(9) = 8_int64
    lengths(10) = 4_int64
    lengths(11) = 4_int64
    do first = 1, 4
      do second = first + 1, 11
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    do level = 1, levels
      word = transfer(pressure(level), word)
      if (word <= 0_int64 .or. word >= int(z'7ff0000000000000', int64)) return
    end do
    if (.not. word_in_positive_range(constants%rg, 1.0_real64, 100.0_real64)) return
    if (.not. word_in_positive_range(constants%rtt, 200.0_real64, 350.0_real64)) return
    do level = 1, 3
      if (.not. word_in_positive_range(scalings(level), 0.25_real64, 4.0_real64)) return
    end do
    if (.not. word_in_positive_range(timestep, 1.0_real64, 86400.0_real64)) return
    status = require_empty_physics_group(text, 'NAMCUMF')
    if (status /= 0_int32) return
    status = require_empty_physics_group(text, 'NAMCUMFS')
    if (status /= 0_int32) return
    call initialize_cumulus_convection_fields( &
      main, thermal, pressure(:levels), constants%rg, constants%rtt, scalings(1), scalings(2))
    call initialize_linearized_convection_fields( &
      linearized, switches, pressure(:levels), constants%rg, scalings(1), scalings(3), timestep)
    status = 0_int32
  end function

  !> Compare positive finite binary64 domains without arithmetic on NaNs.
  logical function word_in_positive_range(value, lower, upper) result(valid)
    real(real64), intent(in) :: value, lower, upper
    integer(int64) :: word, lower_word, upper_word
    word = transfer(value, word)
    lower_word = transfer(lower, lower_word)
    upper_word = transfer(upper, upper_word)
    valid = word >= lower_word .and. word <= upper_word
  end function

  !> Check separate native owner spans without a target-specific layout.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Require nearest rounding and preserve flags during an underflow probe.
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
