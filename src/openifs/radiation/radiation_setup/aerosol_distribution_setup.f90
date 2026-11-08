!> Check and initialize native aerosol distribution records and profiles.
module aerosol_distribution_setup_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoesw, only: teswrt
  use yoeaerd, only: teaerd
  use yoerad, only: terad
  use aerosol_distribution_parameter_fields_mod, only: initialize_aerosol_distribution_parameter_fields
  implicit none
  private
  public :: initialize_selected_aerosol_distribution, initialize_runtime_aerosol_distribution
contains
  !> Fill the selected nineteen-level aerosol distribution.
  !! ETA has twenty half-level coordinates, in increasing dimensionless order.
  !! SHORTWAVE, AEROSOL and RADIATION are separate caller-owned native records.
  !! The nine CVDAE arrays must already have bounds 1:20. No allocation occurs.
  !! Return 0 after the four numerical children or 2 before mutation.
  integer(int32) function initialize_selected_aerosol_distribution(eta, shortwave, aerosol, radiation) result(status)
    real(real64), intent(in), target :: eta(:)
    type(teswrt), intent(inout), target :: shortwave
    type(teaerd), intent(inout), target :: aerosol
    type(terad), intent(inout), target :: radiation
    status = 2_int32
    if (size(eta) /= 20) return
    status = initialize_runtime_aerosol_distribution(eta, shortwave, aerosol, radiation)
  end function

  !> Fill the same profiles for a live level count from 1 through 512.
  !! ETA has LEVELS+1 contiguous values. Its first value is nonnegative,
  !! including either signed zero; later values increase strictly to one.
  !! All nine allocated profiles have bounds 1:SIZE(ETA), and all thirteen
  !! record, coordinate and payload spans are disjoint and eight-byte aligned.
  !! TRBKG and STBKG are finite nonnegative background optical depths.
  !! The five RAESH scale heights are positive finite lengths in metres.
  !! Only source-written fields and the nine profile payloads change.
  !! Other fields, descriptors and padding stay incoming. No allocation occurs.
  !! The raw children retain source operation order and natural flags/errno.
  !! Return 0 on completion or 2 before mutation for an unsupported input.
  !! Wider level counts need independent numerical qualification.
  integer(int32) function initialize_runtime_aerosol_distribution(eta, shortwave, aerosol, radiation) result(status)
    real(real64), intent(in), target :: eta(:)
    type(teswrt), intent(inout), target :: shortwave
    type(teaerd), intent(inout), target :: aerosol
    type(terad), intent(inout), target :: radiation
    integer(c_intptr_t) :: address(13)
    integer(int64) :: extent(13), bits, previous
    integer :: n, level, first, second
    status = 2_int32
    n = size(eta)
    if (n < 2 .or. n > 513) return
    if (.not. is_contiguous(eta)) return
    previous = 0_int64
    do level = 1, n
      bits = transfer(eta(level), 0_int64)
      if (.not. finite_nonnegative_bits(bits)) return
      bits = iand(bits, int(z'7FFFFFFFFFFFFFFF', int64))
      if (bits > int(z'3FF0000000000000', int64)) return
      if (level > 1) then
        if (bits <= previous) return
      end if
      previous = bits
    end do
    if (bits /= int(z'3FF0000000000000', int64)) return
    if (.not. finite_nonnegative_bits(transfer(radiation%trbkg, 0_int64))) return
    if (.not. finite_nonnegative_bits(transfer(radiation%stbkg, 0_int64))) return
    if (.not. finite_positive_bits(transfer(radiation%raeshss, 0_int64))) return
    if (.not. finite_positive_bits(transfer(radiation%raeshdu, 0_int64))) return
    if (.not. finite_positive_bits(transfer(radiation%raeshom, 0_int64))) return
    if (.not. finite_positive_bits(transfer(radiation%raeshbc, 0_int64))) return
    if (.not. finite_positive_bits(transfer(radiation%raeshsu, 0_int64))) return
    if (.not. allocated(aerosol%cvdaes)) return
    if (lbound(aerosol%cvdaes, 1) /= 1 .or. size(aerosol%cvdaes) /= n) return
    if (.not. allocated(aerosol%cvdael)) return
    if (lbound(aerosol%cvdael, 1) /= 1 .or. size(aerosol%cvdael) /= n) return
    if (.not. allocated(aerosol%cvdaeu)) return
    if (lbound(aerosol%cvdaeu, 1) /= 1 .or. size(aerosol%cvdaeu) /= n) return
    if (.not. allocated(aerosol%cvdaed)) return
    if (lbound(aerosol%cvdaed, 1) /= 1 .or. size(aerosol%cvdaed) /= n) return
    if (.not. allocated(radiation%cvdaess)) return
    if (lbound(radiation%cvdaess, 1) /= 1 .or. size(radiation%cvdaess) /= n) return
    if (.not. allocated(radiation%cvdaedu)) return
    if (lbound(radiation%cvdaedu, 1) /= 1 .or. size(radiation%cvdaedu) /= n) return
    if (.not. allocated(radiation%cvdaeom)) return
    if (lbound(radiation%cvdaeom, 1) /= 1 .or. size(radiation%cvdaeom) /= n) return
    if (.not. allocated(radiation%cvdaebc)) return
    if (lbound(radiation%cvdaebc, 1) /= 1 .or. size(radiation%cvdaebc) /= n) return
    if (.not. allocated(radiation%cvdaesu)) return
    if (lbound(radiation%cvdaesu, 1) /= 1 .or. size(radiation%cvdaesu) /= n) return
    address(1) = transfer(c_loc(eta(1)), 0_c_intptr_t)
    extent(1) = int(n, int64)*8_int64
    address(2) = transfer(c_loc(shortwave), 0_c_intptr_t)
    extent(2) = storage_size(shortwave, kind=int64)/8_int64
    address(3) = transfer(c_loc(aerosol), 0_c_intptr_t)
    extent(3) = storage_size(aerosol, kind=int64)/8_int64
    address(4) = transfer(c_loc(radiation), 0_c_intptr_t)
    extent(4) = storage_size(radiation, kind=int64)/8_int64
    address(5) = transfer(c_loc(aerosol%cvdaes(1)), 0_c_intptr_t)
    extent(5) = int(n, int64)*8_int64
    address(6) = transfer(c_loc(aerosol%cvdael(1)), 0_c_intptr_t)
    extent(6) = int(n, int64)*8_int64
    address(7) = transfer(c_loc(aerosol%cvdaeu(1)), 0_c_intptr_t)
    extent(7) = int(n, int64)*8_int64
    address(8) = transfer(c_loc(aerosol%cvdaed(1)), 0_c_intptr_t)
    extent(8) = int(n, int64)*8_int64
    address(9) = transfer(c_loc(radiation%cvdaess(1)), 0_c_intptr_t)
    extent(9) = int(n, int64)*8_int64
    address(10) = transfer(c_loc(radiation%cvdaedu(1)), 0_c_intptr_t)
    extent(10) = int(n, int64)*8_int64
    address(11) = transfer(c_loc(radiation%cvdaeom(1)), 0_c_intptr_t)
    extent(11) = int(n, int64)*8_int64
    address(12) = transfer(c_loc(radiation%cvdaebc(1)), 0_c_intptr_t)
    extent(12) = int(n, int64)*8_int64
    address(13) = transfer(c_loc(radiation%cvdaesu(1)), 0_c_intptr_t)
    extent(13) = int(n, int64)*8_int64
    do first = 1, 13
      if (address(first) <= 0_c_intptr_t .or. iand(address(first), 7_c_intptr_t) /= 0) return
      if (address(first) > huge(address(first)) - extent(first)) return
      do second = 1, first - 1
        if (address(first) <= address(second)) then
          if (address(second) - address(first) < extent(first)) return
        else
          if (address(first) - address(second) < extent(second)) return
        end if
      end do
    end do
    if (.not. supported_floating_mode()) return
    call initialize_aerosol_distribution_parameter_fields(eta, shortwave, aerosol, radiation)
    status = 0_int32
  end function

  !> Inspect finiteness and sign with integer bits before any FP comparison.
  logical function finite_nonnegative_bits(bits) result(valid)
    integer(int64), intent(in) :: bits
    integer(int64) :: magnitude
    magnitude = iand(bits, int(z'7FFFFFFFFFFFFFFF', int64))
    valid = iand(magnitude, int(z'7FF0000000000000', int64)) /= int(z'7FF0000000000000', int64)
    valid = valid .and. (bits >= 0_int64 .or. magnitude == 0_int64)
  end function

  !> Admit a finite positive scale height, without evaluating unused data.
  logical function finite_positive_bits(bits) result(valid)
    integer(int64), intent(in) :: bits
    valid = bits > 0_int64 .and. bits < int(z'7FF0000000000000', int64)
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
end module aerosol_distribution_setup_mod
