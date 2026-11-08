!> Portable607-value lagged random stream for cloud sampling.
module md2asm_cloud_random_stream
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int32_t, c_double
  implicit none
  private
  public :: cloud_random_stream, initialize_random_numbers, uniform_distribution
  integer(int64), parameter :: mask32 = int(z'FFFFFFFF', int64), mask30 = int(z'3FFFFFFF', int64)
  type, bind(c) :: cloud_random_stream
    integer(c_int32_t) :: used, initialized
    integer(c_int32_t) :: state(607)
    real(c_double) :: scale
  end type
contains
!> Return complete selected samples from stream into caller-owned FP64 output(:).
!! Each sample is dimensionless, lies in[0,1), and is a multiple of2**(-30).
!! Native sections support positive/negative strides. Empty output leaves stream
!! untouched. Status0 succeeds; status2 rejects an invalid complete stream.
  subroutine uniform_distribution(output, stream, status)
    real(real64), intent(inout) :: output(:)
    type(cloud_random_stream), intent(inout) :: stream
    integer(int32), intent(out) :: status
    integer :: i, j, used
    integer(int64) :: sum_value
    status = 0
    if (size(output) == 0) return
    status = 2
    if (stream%used < 0 .or. stream%used > 607 .or. stream%initialized /= 12345678) return
    if (transfer(stream%scale, 0_int64) /= int(z'3E10000000000000', int64)) return
    do i = 1, 607
      if (stream%state(i) < 0 .or. int(stream%state(i), int64) > mask30) return
    end do
    used = stream%used
    do i = 1, size(output)
      if (used == 607) then
        do j = 1, 273
          sum_value = int(stream%state(j), int64) + int(stream%state(j + 334), int64)
          stream%state(j) = int(iand(sum_value, mask30), int32)
        end do
        do j = 274, 607
          sum_value = int(stream%state(j), int64) + int(stream%state(j - 273), int64)
          stream%state(j) = int(iand(sum_value, mask30), int32)
        end do
        used = 0
      end if
      used = used + 1
      output(i) = real(stream%state(used), real64)*stream%scale
    end do
    stream%used = int(used, int32)
    status = 0
  end subroutine
!> Expand every signed32-bit seed through the complete polynomial shift rule.
!! Only named stream fields change; compiler alignment padding is preserved.
!! The999-sample warm-up is owned here and uses the same complete consumer.
  subroutine initialize_random_numbers(seed, stream, status)
    integer(int32), intent(in) :: seed
    type(cloud_random_stream), intent(inout) :: stream
    integer(int32), intent(out) :: status
    integer(int64) :: bits, weight
    integer :: j, bit_number
    real(real64) :: warmup(999)
    bits = ieor(iand(int(seed, int64), mask32), 123459876_int64)
    if (btest(bits, 31)) bits = iand(4294967296_int64 - bits, mask32)
    if (bits == 0_int64) bits = 123459876_int64
    do j = 1, 64
      bits = shift_register(bits)
    end do
    do j = 1, 606
      stream%state(j) = 0_int32
    end do
    stream%state(2) = int(ishft(iand(bits, int(z'1FFFFFFF', int64)), 1), int32)
    stream%state(607) = int(shiftr(bits, 29), int32)
    do bit_number = 1, 29
      weight = ishft(1_int64, bit_number)
      do j = 3, 606
        if (btest(bits, 31)) stream%state(j) = ior(stream%state(j), int(weight, int32))
        bits = shift_register(bits)
      end do
    end do
    stream%state(502) = ior(stream%state(502), 1_int32)
    stream%used = 607_int32
    stream%initialized = 12345678_int32
    stream%scale = transfer(int(z'3E10000000000000', int64), 0.0_real64)
    call uniform_distribution(warmup, stream, status)
  end subroutine
!> Advance an unsigned32-bit word without signed integer overflow.
  pure integer(int64) function shift_register(bits) result(value)
    integer(int64), intent(in) :: bits
    value = iand(ishft(bits, 1), mask32)
    if (btest(bits, 31)) value = ieor(value, 175_int64)
  end function
end module
