!> Admit three native shortwave auxiliary records before source writes.
module shortwave_auxiliary_parameter_setup_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use shortwave_auxiliary_parameter_fields_mod, only: &
    shortwave_transmission_parameter_record, shortwave_aerosol_parameter_record, &
    shortwave_cloud_parameter_record, initialize_shortwave_auxiliary_fields
  implicit none
  private
  public :: initialize_shortwave_auxiliary_parameters
  public :: shortwave_transmission_parameter_record, shortwave_aerosol_parameter_record, shortwave_cloud_parameter_record
contains
  !> Run SUSRTAB, SUSRTAER and SUSRTCOP in their generated order.
  !! TRANSMISSION owns TRANS(0:10000) and three scalar coefficients.
  !! AEROSOL owns three14by6 dimensionless optical tables. CLOUD owns the
  !! forty-two14-element fit arrays, with the declared source radius units.
  !! These three complete native records are separate caller-owned INOUT
  !! objects. The compiler owns their layout; every member is source-written.
  !! Return 2 before writes on overlap or unsupported FP mode, else return 0.
  !! No allocation occurs. Natural FP flags and EXP errno remain visible.
  integer(int32) function initialize_shortwave_auxiliary_parameters(transmission, aerosol, cloud) result(status)
    type(shortwave_transmission_parameter_record), intent(inout), target :: transmission
    type(shortwave_aerosol_parameter_record), intent(inout), target :: aerosol
    type(shortwave_cloud_parameter_record), intent(inout), target :: cloud
    integer(c_intptr_t) :: addresses(3)
    integer(int64) :: lengths(3)
    integer :: first, second
    status = 2_int32
    addresses = [transfer(c_loc(transmission), 0_c_intptr_t), transfer(c_loc(aerosol), 0_c_intptr_t), &
                 transfer(c_loc(cloud), 0_c_intptr_t)]
    lengths = [storage_size(transmission, kind=int64)/8_int64, storage_size(aerosol, kind=int64)/8_int64, &
               storage_size(cloud, kind=int64)/8_int64]
    do first = 1, 2
      do second = first + 1, 3
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    call initialize_shortwave_auxiliary_fields(transmission, aerosol, cloud)
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
