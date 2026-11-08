!> Compare the three active input-climatology field pairs.
!! Pair values and their tolerance use the same caller-defined units.
!! The caller owns all pointed-to arrays and supplies FPCR zero.
module runtime_input_climatology_port
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: climatology_field_pair, check_input_climatology
  type :: climatology_field_pair
    logical :: active = .false.
    real(real64) :: tolerance = 0.0_real64
    real(real64), pointer, contiguous :: left(:) => null(), right(:) => null()
  end type climatology_field_pair
contains
  !> Run CHECKINCLIM's ordered absolute-difference and maximum calculations.
  !! Only the first active_count elements of an active pair are read.
  !! block_width is 1..1024; all pairs are admitted before any FP operation.
  !! budget_bytes covers the 512-byte source frame and aligned FP64 work array.
  !! status is 0 on agreement, 2 on admission refusal, or 3 on inconsistency.
  subroutine check_input_climatology(block_width, active_count, pairs, budget_bytes, status)
    integer(int32), intent(in) :: block_width, active_count
    type(climatology_field_pair), intent(in) :: pairs(3)
    integer(int64), intent(in) :: budget_bytes
    integer(int32), intent(out) :: status
    integer(int64) :: required
    integer :: pair, k, first
    real(real64) :: maximum
    status = 2_int32
    if (block_width < 1 .or. block_width > 1024 .or. active_count < 1 .or. active_count > block_width) return
    required = 512_int64 + 16_int64*((8_int64*block_width + 15_int64)/16_int64)
    if (budget_bytes <= 0_int64 .or. budget_bytes > 68719476736_int64 .or. required > budget_bytes) return
    do pair = 1, 3
      if (.not. pairs(pair)%active) cycle
      if (.not. associated(pairs(pair)%left) .or. .not. associated(pairs(pair)%right)) return
      if (size(pairs(pair)%left) < block_width .or. size(pairs(pair)%right) < block_width) return
    end do
    block
      real(real64) :: difference(block_width)
      do pair = 1, 3
        if (.not. pairs(pair)%active) cycle
        do k = 1, active_count
          difference(k) = abs(pairs(pair)%left(k) - pairs(pair)%right(k))
        end do
        maximum = transfer(int(z'fff0000000000000', int64), maximum)
        first = 0
        do k = 1, active_count
          if (difference(k) >= maximum) then
            first = k
            exit
          end if
        end do
        if (first == 0) cycle
        do k = first, active_count
          if (difference(k) > maximum) maximum = difference(k)
        end do
        if (pairs(pair)%tolerance < maximum) then
          status = 3_int32
          return
        end if
      end do
    end block
    status = 0_int32
  end subroutine check_input_climatology
end module runtime_input_climatology_port
