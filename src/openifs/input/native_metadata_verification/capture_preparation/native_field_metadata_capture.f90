!> Encode named field metadata without compiler padding or a numerical stage.
!! SOURCE contains the genuinely produced 4200 native field records. Names and
!! comments are fixed ASCII; integer controls are dimensionless. R and RCP use
!! the source gas and heat-capacity units, J/(kg K). ENCODED has shape (184,4200)
!! and stores each named word in the current little-endian target encoding.
!! Both arrays must be contiguous. Refusal2 preserves ENCODED; success0 writes
!! only its complete semantic records. SOURCE remains read-only. The caller
!! owns ENCODED and keeps it alive while the shared capture table refers to it.
module forecast_native_field_metadata_capture
  use iso_c_binding, only: c_int8_t, c_int
  use forecast_main_field_metadata, only: native_main_field_metadata
  implicit none
  private
  public :: capture_native_field_metadata_named
contains
  integer(c_int) function capture_native_field_metadata_named(source, encoded) result(status)
    type(native_main_field_metadata), intent(in) :: source(:)
    integer(c_int8_t), intent(inout) :: encoded(:, :)
    integer :: j, pos
    status = 2
    if (.not. is_contiguous(source) .or. .not. is_contiguous(encoded)) return
    if (size(source) /= 4200 .or. size(encoded, 1) /= 184 .or. size(encoded, 2) /= 4200) return
    do j = 1, 4200
      pos = 1
      encoded(pos:pos + 15, j) = transfer(source(j)%name, encoded(pos:pos + 15, j))
      pos = pos + 16
      encoded(pos:pos + 127, j) = transfer(source(j)%comments, encoded(pos:pos + 127, j))
      pos = pos + 128
      encoded(pos:pos + 3, j) = transfer(source(j)%ndims, encoded(pos:pos + 3, j))
      pos = pos + 4
      encoded(pos:pos + 3, j) = transfer(source(j)%d2type, encoded(pos:pos + 3, j))
      pos = pos + 4
      encoded(pos:pos + 3, j) = transfer(source(j)%d3type, encoded(pos:pos + 3, j))
      pos = pos + 4
      encoded(pos:pos + 3, j) = transfer(source(j)%igribcode, encoded(pos:pos + 3, j))
      pos = pos + 4
      encoded(pos:pos + 7, j) = transfer(source(j)%r, encoded(pos:pos + 7, j))
      pos = pos + 8
      encoded(pos:pos + 7, j) = transfer(source(j)%rcp, encoded(pos:pos + 7, j))
      pos = pos + 8
      encoded(pos:pos + 3, j) = transfer(source(j)%igflgmv, encoded(pos:pos + 3, j))
      pos = pos + 4
      encoded(pos:pos + 3, j) = transfer(source(j)%ldefined, encoded(pos:pos + 3, j))
      pos = pos + 4
    end do
    status = 0
  end function
end module
