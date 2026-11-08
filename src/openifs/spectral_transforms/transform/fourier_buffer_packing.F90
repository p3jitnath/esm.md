!> Complete Fourier input/output copies and north/south parity preparation.
module md2asm_fourier_buffer_packing
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_transform_types, only: transform_fourier_layout
  implicit none
  private
  public :: copy_fourier_input, copy_fourier_output, prepare_latitude_parity
contains
!> Check maps for one local latitude without reading inactive map entries.
  logical function packing_ready(l, fields, latitude, columns, buffer_words, output, starts)
    type(transform_fourier_layout), intent(in) :: l
    integer, intent(in) :: fields, latitude, columns
    integer(int64), intent(in) :: buffer_words
    logical, intent(in) :: output
    integer(int64), intent(out) :: starts(0:21)
    integer :: global_latitude, m, process, block, column
    integer(int64) :: offset
    packing_ready = .false.
    if (fields < 1 .or. fields > 136 .or. latitude < 1 .or. latitude > 32 .or. l%process_sets /= 1) return
    if (.not. associated(l%maximum_wave) .or. .not. associated(l%column_offset)) return
    if (.not. associated(l%process_of_wave) .or. .not. associated(l%buffer_block)) return
    if (.not. associated(l%wave_latitude_offset)) return
    if (output) then
      if (.not. associated(l%output_block_offset)) return
    else
      if (.not. associated(l%input_block_offset)) return
    end if
    global_latitude = l%first_latitude + latitude - 1
    if (global_latitude < lbound(l%maximum_wave, 1) .or. global_latitude > ubound(l%maximum_wave, 1)) return
    if (latitude < lbound(l%column_offset, 1) .or. latitude > ubound(l%column_offset, 1)) return
    if (l%maximum_wave(global_latitude) < 0 .or. l%maximum_wave(global_latitude) > 21) return
    if (lbound(l%process_of_wave, 1) > 0 .or. ubound(l%process_of_wave, 1) < l%maximum_wave(global_latitude)) return
    if (lbound(l%wave_latitude_offset, 1) > 0 .or. ubound(l%wave_latitude_offset, 1) < l%maximum_wave(global_latitude)) return
    if (latitude < lbound(l%wave_latitude_offset, 2) .or. latitude > ubound(l%wave_latitude_offset, 2)) return
    do m = 0, l%maximum_wave(global_latitude)
      process = l%process_of_wave(m)
      if (process < lbound(l%buffer_block, 1) .or. process > ubound(l%buffer_block, 1)) return
      block = l%buffer_block(process)
      if (output) then
        if (block < lbound(l%output_block_offset, 1) .or. block > ubound(l%output_block_offset, 1)) return
        offset = int(l%output_block_offset(block), int64) + l%wave_latitude_offset(m, latitude)
      else
        if (block < lbound(l%input_block_offset, 1) .or. block > ubound(l%input_block_offset, 1)) return
        offset = int(l%input_block_offset(block), int64) + l%wave_latitude_offset(m, latitude)
      end if
      starts(m) = 2_int64*fields*offset
      if (starts(m) < 0 .or. starts(m) + 2_int64*fields > buffer_words) return
      column = l%column_offset(latitude) + 2*m + 1
      if (column < 1 .or. column + 1 > columns) return
    end do
    packing_ready = .true.
  end function
!> Copy pairs from immutable buffer(:) into mutable (field,column) owner.
  subroutine copy_fourier_input(l, fields, latitude, buffer, matrix, status)
    type(transform_fourier_layout), intent(in) :: l
    integer(int32), intent(in) :: fields, latitude
    real(real64), intent(in) :: buffer(:)
    real(real64), intent(inout) :: matrix(:, :)
    integer(int32), intent(out) :: status
    integer(int64) :: starts(0:21), at
    integer :: m, f, column, global_latitude
    status = 2
    if (size(matrix, 1) < fields) return
    if (.not. packing_ready(l, fields, latitude, size(matrix, 2), size(buffer, kind=int64), .false., starts)) return
    global_latitude = l%first_latitude + latitude - 1
    do m = 0, l%maximum_wave(global_latitude)
      column = l%column_offset(latitude) + 2*m + 1
      do f = 1, fields
        at = starts(m) + 2_int64*f - 1
        matrix(f, column) = buffer(at)
        matrix(f, column + 1) = buffer(at + 1)
      end do
    end do
    status = 0
  end subroutine
!> Copy immutable (field,column) pairs into selected mutable buffer(:) intervals.
  subroutine copy_fourier_output(l, fields, latitude, matrix, buffer, status)
    type(transform_fourier_layout), intent(in) :: l
    integer(int32), intent(in) :: fields, latitude
    real(real64), intent(in) :: matrix(:, :)
    real(real64), intent(inout) :: buffer(:)
    integer(int32), intent(out) :: status
    integer(int64) :: starts(0:21), at
    integer :: m, f, column, global_latitude
    status = 2
    if (size(matrix, 1) < fields) return
    if (.not. packing_ready(l, fields, latitude, size(matrix, 2), size(buffer, kind=int64), .true., starts)) return
    global_latitude = l%first_latitude + latitude - 1
    do m = 0, l%maximum_wave(global_latitude)
      column = l%column_offset(latitude) + 2*m + 1
      do f = 1, fields
        at = starts(m) + 2_int64*f - 1
        buffer(at) = matrix(f, column)
        buffer(at + 1) = matrix(f, column + 1)
      end do
    end do
    status = 0
  end subroutine
!> Form north-minus-south and north-plus-south (component,latitude) values.
!! All table lower bounds are native source subscripts. Buffer and maps are read-only.
  subroutine prepare_latitude_parity(l, fields, wave, local_wave, buffer, anti, sym, status)
    type(transform_fourier_layout), intent(in) :: l
    integer(int32), intent(in) :: fields, wave, local_wave
    real(real64), intent(in) :: buffer(:)
    real(real64), intent(inout) :: anti(:, :), sym(:, :)
    integer(int32), intent(out) :: status
    integer :: first, j, south, c, pn, ps
    integer(int64) :: bn, bs
    status = 2
    if (fields < 0 .or. fields > 4096 .or. l%total_latitudes < 1 .or. l%total_latitudes > 4096) return
    if (l%northern_latitudes /= (l%total_latitudes + 1)/2) return
    if (.not. associated(l%active_latitudes)) return
    if (wave < lbound(l%active_latitudes, 1) .or. wave > ubound(l%active_latitudes, 1)) return
    if (l%active_latitudes(wave) < 0 .or. l%active_latitudes(wave) > l%northern_latitudes) return
    first = max(l%northern_latitudes - l%active_latitudes(wave) + 1, 1)
    if (first > l%northern_latitudes .or. fields == 0) then
      status = 0; return
    end if
    if (size(anti, 1) < 2*fields .or. size(sym, 1) < 2*fields) return
    if (size(anti, 2) < l%northern_latitudes .or. size(sym, 2) < l%northern_latitudes) return
    if (.not. associated(l%process_of_latitude) .or. .not. associated(l%output_block_offset)) return
    if (.not. associated(l%inverse_wave_latitude_offset)) return
    if (local_wave < lbound(l%inverse_wave_latitude_offset, 1) .or. local_wave > ubound(l%inverse_wave_latitude_offset, 1)) return
    do j = first, l%northern_latitudes
      south = l%total_latitudes + 1 - j
      if (min(j, south) < lbound(l%process_of_latitude, 1) .or. max(j, south) > ubound(l%process_of_latitude, 1)) return
if (min(j, south) < lbound(l%inverse_wave_latitude_offset, 2) .or. max(j, south) > ubound(l%inverse_wave_latitude_offset, 2)) return
      pn = l%process_of_latitude(j); ps = l%process_of_latitude(south)
      if (min(pn, ps) < lbound(l%output_block_offset, 1) .or. max(pn, ps) > ubound(l%output_block_offset, 1)) return
      bn = 2_int64*fields*(int(l%output_block_offset(pn), int64) + l%inverse_wave_latitude_offset(local_wave, j))
      bs = 2_int64*fields*(int(l%output_block_offset(ps), int64) + l%inverse_wave_latitude_offset(local_wave, south))
      if (min(bn, bs) < 0 .or. max(bn, bs) + 2_int64*fields > size(buffer, kind=int64)) return
    end do
    do j = first, l%northern_latitudes
      south = l%total_latitudes + 1 - j
      pn = l%process_of_latitude(j); ps = l%process_of_latitude(south)
      bn = 2_int64*fields*(int(l%output_block_offset(pn), int64) + l%inverse_wave_latitude_offset(local_wave, j))
      bs = 2_int64*fields*(int(l%output_block_offset(ps), int64) + l%inverse_wave_latitude_offset(local_wave, south))
      do c = 1, 2*fields
        sym(c, j) = buffer(bn + c) + buffer(bs + c)
        anti(c, j) = buffer(bn + c) - buffer(bs + c)
      end do
    end do
    status = 0
  end subroutine
end module
