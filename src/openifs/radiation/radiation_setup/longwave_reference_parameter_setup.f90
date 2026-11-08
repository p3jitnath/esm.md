!> Admit complete native longwave reference parameters before source writes.
module longwave_reference_parameter_setup_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoerdi, only: terdi
  use physical_constant_setup_port, only: forecast_physical_constants
  use longwave_reference_parameter_fields_mod, only: &
    longwave_reference_parameter_record, initialize_longwave_reference_fields
  implicit none
  private
  public :: initialize_longwave_reference_parameters, longwave_reference_parameter_record
contains
  !> Run SURDI, SURRTAB, SURRTPK and SURRTRF in the generated order.
  !! OUTPUT owns the native longwave reference tables. GASES is a native
  !! TERDI record whose eight input volume fractions are dimensionless.
  !! CONSTANTS is readonly and supplies ten molecular masses in g mol**(-1).
  !! All three complete records must have separate storage. Their sizes and
  !! alignments are compiler properties; no private Arm layout is retained.
  !! Positive finite masses and nonnegative finite fractions are required.
  !! Both signed zeros are admitted for fractions. Untouched TERDI bytes
  !! remain incoming. Return 2 before writes on invalid input, else return 0.
  !! No allocation occurs. Natural FP flags and EXP errno remain visible.
  integer(int32) function initialize_longwave_reference_parameters(output, gases, constants) result(status)
    type(longwave_reference_parameter_record), intent(inout), target :: output
    type(terdi), intent(inout), target :: gases
    type(forecast_physical_constants), intent(in), target :: constants
    real(real64) :: masses(10), fractions(8)
    integer(c_intptr_t) :: addresses(3)
    integer(int64) :: lengths(3)
    integer :: first, second
    status = 2_int32
    masses = [constants%rmd, constants%rmco2, constants%rmch4, constants%rmn2o, constants%rmno2, &
              constants%rmo3, constants%rmcfc11, constants%rmcfc12, constants%rmhcfc22, constants%rmccl4]
    fractions = [gases%rcco2, gases%rcch4, gases%rcn2o, gases%rcno2, &
                 gases%rccfc11, gases%rccfc12, gases%rccfc22, gases%rcccl4]
    do first = 1, 10
      if (.not. positive_finite(masses(first))) return
    end do
    do first = 1, 8
      if (.not. nonnegative_finite(fractions(first))) return
    end do
    addresses = [transfer(c_loc(output), 0_c_intptr_t), transfer(c_loc(gases), 0_c_intptr_t), &
                 transfer(c_loc(constants), 0_c_intptr_t)]
    lengths = [storage_size(output, kind=int64)/8_int64, storage_size(gases, kind=int64)/8_int64, &
               storage_size(constants, kind=int64)/8_int64]
    do first = 1, 2
      do second = first + 1, 3
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    call initialize_longwave_reference_fields(output, gases, constants)
    status = 0_int32
  end function

  !> Inspect finite positive FP64 inputs without changing FP exception flags.
  logical function positive_finite(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, word)
    valid = word > 0_int64 .and. word < int(z'7ff0000000000000', int64)
  end function

  !> Admit both signed zeros and finite nonnegative FP64 fractions.
  logical function nonnegative_finite(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word, magnitude
    word = transfer(value, word)
    magnitude = iand(word, int(z'7fffffffffffffff', int64))
    valid = magnitude == 0_int64 .or. (word > 0_int64 .and. magnitude < int(z'7ff0000000000000', int64))
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
