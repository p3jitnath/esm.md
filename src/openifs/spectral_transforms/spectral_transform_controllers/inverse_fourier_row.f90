!> Complete selected inverse Fourier row with source high-wave zeroing.
module forecast_native_inverse_fourier_row
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_f_pointer
  use md2asm_transform_types, only: transform_fourier_layout
  use md2asm_real_fourier_transform, only: fft992
  use iso_c_binding, only: c_int64_t
  implicit none
  private
  public :: ftinv
  integer(c_int64_t), bind(C, name="md2asm_ftinv_7358525_calls") :: inverse_row_calls = 0
contains
!> Synthesize one 64-longitude row after zeroing its high-wave tail.
!! Fields is1..136; latitude is1..32. Layout maps and FFT tables remain read-only.
!! The source67-column row includes endpoint and preserved padding columns.
  subroutine ftinv(l, fields, latitude, matrix, status)
    type(transform_fourier_layout), intent(in) :: l
    integer(int32), intent(in) :: fields, latitude
    real(real64), target, intent(inout) :: matrix(:, :)
    integer(int32), intent(out) :: status
    real(real64), pointer :: row_words(:)
    integer :: global_latitude, offset, j, f, zero_first, zero_count
    integer(int64) :: word_count
    integer(int64), parameter :: canonical_trigs(64) = [ &
                                 int(z'3ff0000000000000', int64), &
                                 int(z'0000000000000000', int64), &
                                 int(z'3fefd88da3d12526', int64), &
                                 int(z'3fb917a6bc29b42c', int64), &
                                 int(z'3fef6297cff75cb0', int64), &
                                 int(z'3fc8f8b83c69a60a', int64), &
                                 int(z'3fee9f4156c62dda', int64), &
                                 int(z'3fd294062ed59f05', int64), &
                                 int(z'3fed906bcf328d46', int64), &
                                 int(z'3fd87de2a6aea963', int64), &
                                 int(z'3fec38b2f180bdb1', int64), &
                                 int(z'3fde2b5d3806f63b', int64), &
                                 int(z'3fea9b66290ea1a3', int64), &
                                 int(z'3fe1c73b39ae68c8', int64), &
                                 int(z'3fe8bc806b151741', int64), &
                                 int(z'3fe44cf325091dd6', int64), &
                                 int(z'3fe6a09e667f3bcd', int64), &
                                 int(z'3fe6a09e667f3bcc', int64), &
                                 int(z'3fe44cf325091dd6', int64), &
                                 int(z'3fe8bc806b151741', int64), &
                                 int(z'3fe1c73b39ae68c9', int64), &
                                 int(z'3fea9b66290ea1a3', int64), &
                                 int(z'3fde2b5d3806f63e', int64), &
                                 int(z'3fec38b2f180bdb0', int64), &
                                 int(z'3fd87de2a6aea964', int64), &
                                 int(z'3fed906bcf328d46', int64), &
                                 int(z'3fd294062ed59f05', int64), &
                                 int(z'3fee9f4156c62ddb', int64), &
                                 int(z'3fc8f8b83c69a60d', int64), &
                                 int(z'3fef6297cff75cb0', int64), &
                                 int(z'3fb917a6bc29b438', int64), &
                                 int(z'3fefd88da3d12525', int64), &
                                 int(z'3c91a62633145c07', int64), &
                                 int(z'3ff0000000000000', int64), &
                                 int(z'bfb917a6bc29b42f', int64), &
                                 int(z'3fefd88da3d12526', int64), &
                                 int(z'bfc8f8b83c69a608', int64), &
                                 int(z'3fef6297cff75cb0', int64), &
                                 int(z'bfd294062ed59f02', int64), &
                                 int(z'3fee9f4156c62ddb', int64), &
                                 int(z'bfd87de2a6aea962', int64), &
                                 int(z'3fed906bcf328d46', int64), &
                                 int(z'bfde2b5d3806f63c', int64), &
                                 int(z'3fec38b2f180bdb1', int64), &
                                 int(z'bfe1c73b39ae68c6', int64), &
                                 int(z'3fea9b66290ea1a5', int64), &
                                 int(z'bfe44cf325091dd5', int64), &
                                 int(z'3fe8bc806b151742', int64), &
                                 int(z'bfe6a09e667f3bcc', int64), &
                                 int(z'3fe6a09e667f3bcd', int64), &
                                 int(z'bfe8bc806b151741', int64), &
                                 int(z'3fe44cf325091dd6', int64), &
                                 int(z'bfea9b66290ea1a4', int64), &
                                 int(z'3fe1c73b39ae68c8', int64), &
                                 int(z'bfec38b2f180bdb0', int64), &
                                 int(z'3fde2b5d3806f63f', int64), &
                                 int(z'bfed906bcf328d46', int64), &
                                 int(z'3fd87de2a6aea965', int64), &
                                 int(z'bfee9f4156c62dda', int64), &
                                 int(z'3fd294062ed59f06', int64), &
                                 int(z'bfef6297cff75cb0', int64), &
                                 int(z'3fc8f8b83c69a617', int64), &
                                 int(z'bfefd88da3d12525', int64), &
                                 int(z'3fb917a6bc29b43c', int64)]

    status = 2
    if (fields < 1 .or. fields > 136 .or. latitude < 1 .or. latitude > 32) return
    if (l%process_sets /= 1 .or. l%extra_longitudes /= 0 .or. l%first_latitude /= 1) return
    if (.not. is_contiguous(matrix)) return
    if (size(matrix, 1) /= fields .or. size(matrix, 2) /= 2144) return
    if (.not. associated(l%longitude_count) .or. .not. associated(l%maximum_wave)) return
    if (.not. associated(l%column_offset) .or. .not. associated(l%use_fft992)) return
    if (.not. associated(l%trigonometric) .or. .not. associated(l%factors)) return
    global_latitude = l%first_latitude + latitude - 1
    if (global_latitude < lbound(l%longitude_count, 1) .or. global_latitude > ubound(l%longitude_count, 1)) return
    if (global_latitude < lbound(l%maximum_wave, 1) .or. global_latitude > ubound(l%maximum_wave, 1)) return
    if (latitude < lbound(l%column_offset, 1) .or. latitude > ubound(l%column_offset, 1)) return
    if (latitude < lbound(l%use_fft992, 1) .or. latitude > ubound(l%use_fft992, 1)) return
    if (l%longitude_count(global_latitude) /= 64 .or. l%maximum_wave(global_latitude) /= 21) return
    if (.not. l%use_fft992(latitude)) return
    if (size(l%trigonometric, 1) /= 64 .or. size(l%factors, 1) /= 19) return
    if (size(l%trigonometric, 2) /= 32 .or. size(l%factors, 2) /= 32) return
    if (latitude < lbound(l%trigonometric, 2) .or. latitude > ubound(l%trigonometric, 2)) return
    if (latitude < lbound(l%factors, 2) .or. latitude > ubound(l%factors, 2)) return
    if (any(l%factors(1:4, latitude) /= [3, 2, 4, 8])) return
    do j = 1, 64
      if (transfer(l%trigonometric(j, latitude), 0_int64) /= canonical_trigs(j)) return
    end do
    offset = l%column_offset(latitude)
    if (offset /= 67*(latitude - 1)) return
    if (offset < 0 .or. offset + 67 > size(matrix, 2)) return
    inverse_row_calls = inverse_row_calls + 1
    zero_first = 2*(l%maximum_wave(global_latitude) + 1) + 1
    zero_count = l%longitude_count(global_latitude) + l%extra_longitudes + 3 - zero_first
    do j = 1, zero_count
      do f = 1, fields
        matrix(f, zero_first + offset + j - 1) = 0.0_real64
      end do
    end do
    word_count = 66_int64*fields
    call c_f_pointer(c_loc(matrix(1, offset + 1)), row_words, [int(word_count)])
    call fft992(row_words, l%trigonometric(:, latitude), l%factors(:, latitude), fields, 1_int32, 64_int32, fields, 1_int32, status)
    if (status /= 0) return
    status = 0
  end subroutine
end module
