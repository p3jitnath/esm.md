!> Copy requested spectral or grid fields into source-ordered output planes.
!! Field values retain all FP64 bits; level metadata uses the source nearest-away conversion.
module forecast_output_field_packing
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int
  use forecast_output_request_types, only: trqfp
  implicit none
  private
  public :: native_spectral_field_metadata, native_grid_field_metadata
  public :: pack_spectral_output, pack_grid_output
  type, bind(c) :: native_spectral_field_metadata
    integer(c_int) :: parameter, level, distribution_set, local_index
  end type
  type, bind(c) :: native_grid_field_metadata
    integer(c_int) :: parameter, level
  end type
contains
  !> Pack input(first_field:,wave) into output(wave,field), keeping the source order.
  !! spectral_words is positive. selector/=0 changes a surface level from 1 to 100000 Pa.
  !! Status 2 is a shape or selected-code refusal; a constructed prefix remains owned.
  integer(int32) function pack_spectral_output(request, input, first_field, output, metadata, &
                                               spectral_words, selector, packed_count) result(status)
    type(trqfp), intent(in) :: request
    integer(int32), intent(in) :: first_field, spectral_words, selector
    real(real64), intent(in) :: input(first_field:, :)
    real(real64), intent(inout) :: output(:, :)
    type(native_spectral_field_metadata), intent(inout) :: metadata(:)
    integer(int32), intent(out) :: packed_count
    integer :: field, source_field, wave, code, level, n
    status = 2
    packed_count = 0
    n = request%nfieldg
    if (n < 0 .or. n > 39 .or. request%nfieldl /= n .or. spectral_words < 1) return
    if (size(output, 1) < spectral_words .or. size(output, 2) < n .or. size(metadata) < n) return
    if (size(input, 2) < spectral_words) return
    if (.not. allocated(request%icod) .or. .not. allocated(request%llsurf) .or. .not. allocated(request%zlev)) return
    if (.not. allocated(request%ivsetg) .or. .not. allocated(request%ivlocg)) return
    if (min(size(request%icod), size(request%llsurf), size(request%zlev), size(request%ivsetg), size(request%ivlocg)) < n) return
    do field = 1, n
      code = request%icod(field)
      if (code /= 130 .and. code /= 133 .and. code /= 152) return
      if (request%llsurf(field)) then
        level = 1
        if (selector /= 0) level = 100000
      else
        level = nint(request%zlev(field), int32)
      end if
      if (request%ivsetg(field) /= 1) return
      source_field = request%ivlocg(field)
      if (source_field < lbound(input, 1) .or. source_field > ubound(input, 1)) return
      metadata(field)%parameter = code
      metadata(field)%level = level
      metadata(field)%distribution_set = 1
      metadata(field)%local_index = source_field
      do wave = 1, spectral_words
        output(wave, field) = input(source_field, wave)
      end do
      packed_count = packed_count + 1
    end do
    status = 0
  end function
  !> Pack grid input(point,field,block) into output(global-local point,field).
  !! points is the active local point count and width is the stored block width.
  !! selector/=0 omits a surface parameter152, as in the source caller.
  integer(int32) function pack_grid_output(request, input, output, metadata, points, width, selector, packed_count) result(status)
    type(trqfp), intent(in) :: request
    real(real64), intent(in) :: input(:, :, :)
    real(real64), intent(inout) :: output(:, :)
    type(native_grid_field_metadata), intent(inout) :: metadata(:)
    integer(int32), intent(in) :: points, width, selector
    integer(int32), intent(out) :: packed_count
    integer :: field, point, row, block, code, n
    status = 2
    packed_count = 0
    n = request%nfieldg
    if (n < 0 .or. n > 39 .or. points < 1 .or. width < 1) return
    if (size(output, 1) < points .or. size(output, 2) < n .or. size(metadata) < n) return
    if (size(input, 1) < width .or. size(input, 2) < n .or. size(input, 3) < (int(points, 8) + width - 1)/width) return
    if (.not. allocated(request%icod) .or. .not. allocated(request%llsurf) .or. .not. allocated(request%zlev)) return
    if (min(size(request%icod), size(request%llsurf), size(request%zlev)) < n) return
    do field = 1, n
      code = request%icod(field)
      if (code /= 130 .and. code /= 133 .and. code /= 152) return
      if (selector /= 0 .and. request%llsurf(field) .and. code == 152) cycle
      metadata(packed_count + 1)%parameter = code
      metadata(packed_count + 1)%level = nint(request%zlev(field), int32)
      do point = 0, points - 1
        block = point/width + 1
        row = mod(point, width) + 1
        output(point + 1, packed_count + 1) = input(row, field, block)
      end do
      packed_count = packed_count + 1
    end do
    status = 0
  end function
end module forecast_output_field_packing
