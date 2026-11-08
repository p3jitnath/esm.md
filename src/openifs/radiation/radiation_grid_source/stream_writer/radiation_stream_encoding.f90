!> Encode canonical radiation output through one fixed byte buffer.
!! The caller owns record selection and metadata. This codec performs no
!! floating-point calculation and never copies a complete array payload.
module forecast_radiation_stream_encoding
  use iso_fortran_env, only: int8, int16, int32, int64, real32, real64
  implicit none
  private
  public :: native_radiation_stream_writer, open_radiation_stream, close_radiation_stream
  public :: put_stream_tag, put_stream_metadata, put_stream_value, set_stream_failure
!> Own one real stream unit and a fixed65536-byte output buffer.
!! STATUS0 is success,1 is I/O failure and2 is invalid codec input.
!! IO_STATUS retains the first nonzero Fortran I/O status. No payload pointer
!! is retained after a PUT call. All internal resource state is private.
  type :: native_radiation_stream_writer
    integer(int32) :: status = 0
    integer :: io_status = 0
    integer, private :: unit = 0, used = 0
    logical, private :: opened = .false.
    integer(int8), private :: buffer(65536)
  end type
contains
!> Record the first semantic error without changing previously emitted bytes.
  subroutine set_stream_failure(writer, status)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer(int32), intent(in) :: status
    if (writer%status == 0 .and. status /= 0) writer%status = status
  end subroutine
!> Retain the first public Fortran I/O failure separately from semantic status.
  subroutine io_failure(writer, ios)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer, intent(in) :: ios
    if (ios == 0) return
    if (writer%io_status == 0) writer%io_status = ios
    if (writer%status == 0) writer%status = 1
  end subroutine
!> Write one already encoded contiguous byte prefix; never retry a failed write.
  subroutine flush_bytes(writer)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer :: ios
    if (writer%used == 0) return
    if (.not. writer%opened) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    write (writer%unit, iostat=ios) writer%buffer(1:writer%used)
    writer%used = 0
    call io_failure(writer, ios)
  end subroutine
!> Open the caller's bounded native filename through standard Fortran I/O.
!! PATH contains1:4095 bytes, no NUL and at least one nonblank byte.
!! A live or failed writer is not reset. No conversion option is applied.
  subroutine open_radiation_stream(writer, path)
    type(native_radiation_stream_writer), intent(inout) :: writer
    character(len=*), intent(in) :: path
    integer :: ios
    if (writer%status /= 0) return
    if (writer%opened .or. len(path) < 1 .or. len(path) > 4095) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    if (len_trim(path) == 0 .or. index(path, achar(0)) /= 0) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    open (newunit=writer%unit, file=path, status='replace', access='stream', form='unformatted', action='write', iostat=ios)
    if (ios /= 0) then
      call io_failure(writer, ios)
      return
    end if
    writer%opened = .true.; writer%used = 0
  end subroutine
!> Flush a semantic-error prefix and close, preserving the first status.
!! A failed write is not retried. CLOSE still releases a live stream unit.
  subroutine close_radiation_stream(writer)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer :: ios
    if (.not. writer%opened) return
    if (writer%io_status == 0) call flush_bytes(writer)
    close (writer%unit, iostat=ios)
    call io_failure(writer, ios)
    writer%opened = .false.; writer%unit = 0; writer%used = 0
  end subroutine
!> Append one signed representation of a canonical byte.
  subroutine append_byte(writer, byte)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer(int8), intent(in) :: byte
    if (writer%status /= 0) return
    if (.not. writer%opened) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    writer%used = writer%used + 1; writer%buffer(writer%used) = byte
    if (writer%used == size(writer%buffer)) call flush_bytes(writer)
  end subroutine
!> Emit low-order integer word bytes in little-endian order.
!! Unsigned byte values128:255 are reduced by256 before int8 conversion.
  subroutine put_word(writer, word, bytes)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer(int64), intent(in) :: word
    integer, intent(in) :: bytes
    integer :: i
    integer(int32) :: byte
    if (writer%status /= 0) return
    do i = 0, bytes - 1
      byte = int(ibits(word, 8*i, 8), int32)
      if (byte >= 128) byte = byte - 256
      call append_byte(writer, int(byte, int8))
      if (writer%status /= 0) return
    end do
  end subroutine
!> Copy scalar character bytes without trimming, padding or encoding changes.
  subroutine put_character_bytes(writer, text)
    type(native_radiation_stream_writer), intent(inout) :: writer
    character(len=*), intent(in) :: text
    integer :: i
    integer(int32) :: byte
    if (writer%status /= 0) return
    do i = 1, len(text)
      byte = iachar(text(i:i), kind=int32)
      if (byte < 0 .or. byte > 255) then
        call set_stream_failure(writer, 2_int32)
        return
      end if
      if (byte >= 128) byte = byte - 256
      call append_byte(writer, int(byte, int8))
      if (writer%status /= 0) return
    end do
  end subroutine
!> Emit int32 tag, int32 byte length and exactly the label bytes.
  subroutine put_stream_tag(writer, tag, label)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer(int32), intent(in) :: tag
    character(len=*), intent(in) :: label
    if (writer%status /= 0) return
    if (len(label, kind=int64) > int(huge(0_int32), int64)) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    call put_word(writer, int(tag, int64), 4)
    call put_word(writer, int(len(label), int64), 4)
    call put_character_bytes(writer, label)
  end subroutine
!> Encode type, element width, declared rank and presence, then actual bounds.
!! Type codes1/2/3/4 mean integer/real/logical/character;5/6 mean record and
!! opaque pointer presence. Absent owners have no bounds even at nonzero rank.
  subroutine put_stream_metadata(writer, type_code, kind_bytes, rank, presence, lower, upper)
    type(native_radiation_stream_writer), intent(inout) :: writer
    integer(int32), intent(in) :: type_code, kind_bytes, rank, presence
    integer(int64), intent(in) :: lower(:), upper(:)
    integer :: i
    logical :: valid
    if (writer%status /= 0) return
    valid = .false.
    if (rank < 0 .or. rank > 7 .or. presence < 0 .or. presence > 1) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    select case (type_code)
    case (1, 3)
      valid = kind_bytes == 1 .or. kind_bytes == 2 .or. kind_bytes == 4 .or. kind_bytes == 8
    case (2)
      valid = kind_bytes == 4 .or. kind_bytes == 8
    case (4)
      valid = kind_bytes >= 0
    case (5, 6)
      valid = kind_bytes == 0
    end select
    if (.not. valid) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    if (presence == 0) then
      valid = size(lower) == 0 .and. size(upper) == 0
    else
      valid = size(lower) == rank .and. size(upper) == rank
    end if
    if (.not. valid) then
      call set_stream_failure(writer, 2_int32)
      return
    end if
    call put_word(writer, int(type_code, int64), 4)
    call put_word(writer, int(kind_bytes, int64), 4)
    call put_word(writer, int(rank, int64), 4)
    call put_word(writer, int(presence, int64), 4)
    if (presence == 1) then
      do i = 1, rank
        call put_word(writer, lower(i), 8)
        call put_word(writer, upper(i), 8)
      end do
    end if
  end subroutine
!> Emit primitive payload only, in Fortran column-major element order.
!! Each scalar TRANSFER reads its original word. It does not convert real
!! values, normalize logical words, or allocate a whole-array temporary.
  subroutine put_stream_value(writer, value)
    type(native_radiation_stream_writer), intent(inout) :: writer
    class(*), dimension(..), intent(in) :: value
    integer :: i1, i2, i3, i4, i5, i6, i7
    if (writer%status /= 0) return
    select rank (value)
    rank (0)
      select type (value)
      type is (integer(int8))
        call put_word(writer, int(value, int64), 1)
        if (writer%status /= 0) return
      type is (integer(int16))
        call put_word(writer, int(value, int64), 2)
        if (writer%status /= 0) return
      type is (integer(int32))
        call put_word(writer, int(value, int64), 4)
        if (writer%status /= 0) return
      type is (integer(int64))
        call put_word(writer, int(value, int64), 8)
        if (writer%status /= 0) return
      type is (real(real32))
        call put_word(writer, int(transfer(value, 0_int32), int64), 4)
        if (writer%status /= 0) return
      type is (real(real64))
        call put_word(writer, int(transfer(value, 0_int64), int64), 8)
        if (writer%status /= 0) return
      type is (logical(kind=1))
        call put_word(writer, int(transfer(value, 0_int8), int64), 1)
        if (writer%status /= 0) return
      type is (logical(kind=2))
        call put_word(writer, int(transfer(value, 0_int16), int64), 2)
        if (writer%status /= 0) return
      type is (logical(kind=4))
        call put_word(writer, int(transfer(value, 0_int32), int64), 4)
        if (writer%status /= 0) return
      type is (logical(kind=8))
        call put_word(writer, int(transfer(value, 0_int64), int64), 8)
        if (writer%status /= 0) return
      type is (character(len=*, kind=1))
        call put_character_bytes(writer, value)
        if (writer%status /= 0) return
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank (1)
      select type (value)
      type is (integer(int8))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1), int64), 1)
          if (writer%status /= 0) return
        end do
      type is (integer(int16))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1), int64), 2)
          if (writer%status /= 0) return
        end do
      type is (integer(int32))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1), int64), 4)
          if (writer%status /= 0) return
        end do
      type is (integer(int64))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1), int64), 8)
          if (writer%status /= 0) return
        end do
      type is (real(real32))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
      type is (real(real64))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
      type is (logical(kind=1))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1), 0_int8), int64), 1)
          if (writer%status /= 0) return
        end do
      type is (logical(kind=2))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1), 0_int16), int64), 2)
          if (writer%status /= 0) return
        end do
      type is (logical(kind=4))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
      type is (logical(kind=8))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
      type is (character(len=*, kind=1))
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_character_bytes(writer, value(i1))
          if (writer%status /= 0) return
        end do
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank (2)
      select type (value)
      type is (integer(int8))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
      type is (integer(int16))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
      type is (integer(int32))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
      type is (integer(int64))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
      type is (real(real32))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
      type is (real(real64))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
      type is (logical(kind=1))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2), 0_int8), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
      type is (logical(kind=2))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2), 0_int16), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
      type is (logical(kind=4))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
      type is (logical(kind=8))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
      type is (character(len=*, kind=1))
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_character_bytes(writer, value(i1, i2))
          if (writer%status /= 0) return
        end do
        end do
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank (3)
      select type (value)
      type is (integer(int8))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (integer(int16))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (integer(int32))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (integer(int64))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (real(real32))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (real(real64))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (logical(kind=1))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3), 0_int8), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (logical(kind=2))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3), 0_int16), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (logical(kind=4))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (logical(kind=8))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
      type is (character(len=*, kind=1))
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_character_bytes(writer, value(i1, i2, i3))
          if (writer%status /= 0) return
        end do
        end do
        end do
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank (4)
      select type (value)
      type is (integer(int8))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (integer(int16))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (integer(int32))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (integer(int64))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (real(real32))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (real(real64))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (logical(kind=1))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4), 0_int8), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (logical(kind=2))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4), 0_int16), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (logical(kind=4))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (logical(kind=8))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      type is (character(len=*, kind=1))
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_character_bytes(writer, value(i1, i2, i3, i4))
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank (5)
      select type (value)
      type is (integer(int8))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (integer(int16))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (integer(int32))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (integer(int64))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (real(real32))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (real(real64))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=1))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5), 0_int8), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=2))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5), 0_int16), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=4))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=8))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      type is (character(len=*, kind=1))
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_character_bytes(writer, value(i1, i2, i3, i4, i5))
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank (6)
      select type (value)
      type is (integer(int8))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (integer(int16))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (integer(int32))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (integer(int64))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (real(real32))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (real(real64))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=1))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6), 0_int8), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=2))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6), 0_int16), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=4))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=8))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      type is (character(len=*, kind=1))
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_character_bytes(writer, value(i1, i2, i3, i4, i5, i6))
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank (7)
      select type (value)
      type is (integer(int8))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6, i7), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (integer(int16))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6, i7), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (integer(int32))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6, i7), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (integer(int64))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(value(i1, i2, i3, i4, i5, i6, i7), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (real(real32))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6, i7), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (real(real64))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6, i7), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=1))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6, i7), 0_int8), int64), 1)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=2))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6, i7), 0_int16), int64), 2)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=4))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6, i7), 0_int32), int64), 4)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (logical(kind=8))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_word(writer, int(transfer(value(i1, i2, i3, i4, i5, i6, i7), 0_int64), int64), 8)
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      type is (character(len=*, kind=1))
        do i7 = lbound(value, 7), ubound(value, 7)
        do i6 = lbound(value, 6), ubound(value, 6)
        do i5 = lbound(value, 5), ubound(value, 5)
        do i4 = lbound(value, 4), ubound(value, 4)
        do i3 = lbound(value, 3), ubound(value, 3)
        do i2 = lbound(value, 2), ubound(value, 2)
        do i1 = lbound(value, 1), ubound(value, 1)
          call put_character_bytes(writer, value(i1, i2, i3, i4, i5, i6, i7))
          if (writer%status /= 0) return
        end do
        end do
        end do
        end do
        end do
        end do
        end do
      class default
        call set_stream_failure(writer, 2_int32)
      end select
    rank default
      call set_stream_failure(writer, 2_int32)
    end select
  end subroutine
end module forecast_radiation_stream_encoding
