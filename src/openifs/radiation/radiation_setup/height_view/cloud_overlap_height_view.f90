!> Evaluate the accepted cloud-overlap profile from a readonly height view.
!! This distinct native entry reuses the accepted ordered SUOVLP arithmetic
!! and guard helpers. It owns no storage and does not change the accepted
!! TSTA entry, its source, its objects or its verification records.
module cloud_overlap_height_view_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoeovlp, only: teovlp
  use yoerad, only: terad
  implicit none
  private
  public :: initialize_cloud_overlap_profile_from_height
contains
  !> Evaluate one rounded product then one addition per height in metres.
  !! HEIGHT is a readonly TARGET FP64 array with SIZE equal to LEVELS. The
  !! caller passes a live height view; noncontiguous views return2 before
  !! payload reads or writes. No CONTIGUOUS dummy attribute creates a copy.
  !! LEVELS is int32 from1through256. OVERLAP is INOUT and owns allocated
  !! dimensionless RA1OVLP(1:LEVELS). RADIATION is readonly native TERAD;
  !! RAOVLP has inverse-metre units and RBOVLP is dimensionless. The four
  !! complete live spans, HEIGHT, OVERLAP, RADIATION and RA1OVLP, are separate.
  !! Every live input is finite. The caller establishes the complete floating
  !! contract; the accepted guard checks nearest rounding and gradual
  !! underflow while preserving incoming exception flags.
  !! Return0 after all values or2 before mutation. No allocation or release
  !! occurs, all readonly bytes remain unchanged, and natural FP flags remain.
  integer(int32) function initialize_cloud_overlap_profile_from_height( &
    height, overlap, radiation, levels) result(status)
    real(real64), intent(in), target :: height(:)
    type(teovlp), intent(inout), target :: overlap
    type(terad), intent(in), target :: radiation
    integer(int32), intent(in) :: levels
    integer(c_intptr_t) :: addresses(4)
    integer(int64) :: lengths(4)
    integer :: first, second, level
    real(real64) :: product
    status = 2_int32
    if (levels < 1 .or. levels > 256) return
    if (size(height) /= levels) return
    if (.not. is_contiguous(height)) return
    if (.not. allocated(overlap%ra1ovlp)) return
    if (lbound(overlap%ra1ovlp, 1) /= 1 .or. size(overlap%ra1ovlp) /= levels) return
    if (.not. finite_value(radiation%raovlp) .or. .not. finite_value(radiation%rbovlp)) return
    do level = 1, levels
      if (.not. finite_value(height(level))) return
    end do
    addresses = [transfer(c_loc(height), 0_c_intptr_t), transfer(c_loc(overlap), 0_c_intptr_t), &
                 transfer(c_loc(radiation), 0_c_intptr_t), transfer(c_loc(overlap%ra1ovlp), 0_c_intptr_t)]
    lengths = [int(levels, int64)*8_int64, storage_size(overlap, kind=int64)/8_int64, &
               storage_size(radiation, kind=int64)/8_int64, int(levels, int64)*8_int64]
    do first = 1, 3
      do second = first + 1, 4
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    do level = 1, levels
      product = radiation%raovlp*height(level)
      overlap%ra1ovlp(level) = product + radiation%rbovlp
    end do
    status = 0_int32
  end function

  logical function finite_value(value) result(finite)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = iand(transfer(value, 0_int64), int(z'7fffffffffffffff', int64))
    finite = word < int(z'7ff0000000000000', int64)
  end function

  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

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
end module cloud_overlap_height_view_setup_port
