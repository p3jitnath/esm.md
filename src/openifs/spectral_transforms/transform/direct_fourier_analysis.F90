!> Complete selected direct Fourier latitude caller.
module md2asm_direct_fourier_analysis
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_f_pointer
  use md2asm_transform_types, only: transform_fourier_layout, transform_environment_ready
  use md2asm_real_fourier_transform, only: fft992
  implicit none
  private
  public :: analyse_fourier_latitude
contains
!> Analyse one64-longitude row in owned (field,column) storage and zero high waves.
!! Fields is1..136; latitude is1..32. Layout maps and FFT tables remain read-only.
!! The source67-column row includes endpoint and preserved padding columns.
  subroutine analyse_fourier_latitude(l, fields, latitude, matrix, status)
    type(transform_fourier_layout), intent(in) :: l
    integer(int32), intent(in) :: fields, latitude
    real(real64), contiguous, target, intent(inout) :: matrix(:, :)
    integer(int32), intent(out) :: status
    real(real64), pointer :: row_words(:)
    integer :: global_latitude, offset, j, f, zero_first, zero_count
    integer(int64) :: word_count
    status = 2
    if (fields < 1 .or. fields > 136 .or. latitude < 1 .or. latitude > 32) return
    if (l%process_sets /= 1 .or. l%extra_longitudes /= 0) return
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
    if (size(l%trigonometric, 1) < 64 .or. size(l%factors, 1) < 10) return
    if (latitude < lbound(l%trigonometric, 2) .or. latitude > ubound(l%trigonometric, 2)) return
    if (latitude < lbound(l%factors, 2) .or. latitude > ubound(l%factors, 2)) return
    offset = l%column_offset(latitude)
    if (offset < 0 .or. offset + 67 > size(matrix, 2)) return
    if (.not. transform_environment_ready()) return
    word_count = 66_int64*fields
    call c_f_pointer(c_loc(matrix(1, offset + 1)), row_words, [int(word_count)])
   call fft992(row_words, l%trigonometric(:, latitude), l%factors(:, latitude), fields, 1_int32, 64_int32, fields, -1_int32, status)
    if (status /= 0) return
    zero_first = 2*(l%maximum_wave(global_latitude) + 1) + 1
    zero_count = l%longitude_count(global_latitude) + l%extra_longitudes + 3 - zero_first
    do j = 1, zero_count
      do f = 1, fields
        matrix(f, zero_first + offset + j - 1) = 0.0_real64
      end do
    end do
    status = 0
  end subroutine
end module
