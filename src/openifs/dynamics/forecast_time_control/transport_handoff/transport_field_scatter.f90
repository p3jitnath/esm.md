!> Copy the live local transport tile through the actual point map.
!! This integer-bit transport preserves every real64 bit and adds no FP arithmetic.
module forecast_transport_field_scatter
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int32_t, c_int64_t, c_intptr_t, c_loc, c_sizeof
  implicit none
  private
  public :: transport_scatter_layout, admit_transport_field_block, scatter_transport_field_block
  public :: native_address_span, native_buffer_span, checked_address_span, spans_disjoint
  !> Live native metadata; no private historical record offset is exposed.
  type, bind(C) :: transport_scatter_layout
    integer(c_int32_t) :: pitch, field_count, target_points, first, last
    integer(c_int64_t) :: global_first, map_lower, map_upper
  end type
  !> A private-owner address interval used only for concrete alias guards.
  type :: native_address_span
    integer(c_intptr_t) :: first = 0, after = 0
  end type
  interface native_buffer_span
    module procedure buffer_span_real1, buffer_span_real2, buffer_span_real3, buffer_span_integer1
  end interface
contains
  !> Check every owner and active point before a possible store.
  !! Map element one names map_lower. Source and destination use strides P and N.
  !! A valid empty interval has first=last+1. Return 2 leaves every owner intact.
  integer(int32) function admit_transport_field_block(layout, map, source, destination) result(status)
    type(transport_scatter_layout), target, intent(in) :: layout
    integer(int32), target, intent(in) :: map(:)
    real(real64), target, intent(in) :: source(:, :), destination(:, :)
    type(native_address_span) :: source_span, destination_span, map_span, layout_span
    integer(int64) :: first_global, last_global, row, index, extent
    status = 2
    if (layout%pitch < 1 .or. layout%pitch > 1024) return
    if (layout%field_count < 1 .or. layout%field_count > 4096 .or. layout%target_points < 1) return
    if (layout%first < 1 .or. layout%first > layout%pitch + 1) return
    if (layout%last < layout%first - 1 .or. layout%last > layout%pitch) return
    if (layout%global_first < 1 .or. layout%global_first > int(huge(1_int32), int64)) return
    if (layout%map_lower < 1 .or. layout%map_upper < layout%map_lower) return
    if (layout%map_upper > int(huge(1_int32), int64)) return
    if (.not. is_contiguous(map) .or. .not. is_contiguous(source) .or. .not. is_contiguous(destination)) return
    if (size(source, 1, kind=int64) /= int(layout%pitch, int64)) return
    if (size(source, 2, kind=int64) < int(layout%field_count, int64)) return
    if (size(destination, 1, kind=int64) /= int(layout%target_points, int64)) return
    if (size(destination, 2, kind=int64) < int(layout%field_count, int64)) return
    extent = layout%map_upper - layout%map_lower + 1
    if (size(map, kind=int64) < extent) return
    if (.not. native_buffer_span(source, source_span)) return
    if (.not. native_buffer_span(destination, destination_span)) return
    if (.not. native_buffer_span(map, map_span)) return
    if (.not. checked_address_span(transfer(c_loc(layout), 0_c_intptr_t), 1_int64, &
                                   int(c_sizeof(layout), int64), layout_span)) return
    if (.not. spans_disjoint(destination_span, source_span)) return
    if (.not. spans_disjoint(destination_span, map_span)) return
    if (.not. spans_disjoint(destination_span, layout_span)) return
    if (layout%first <= layout%last) then
      if (layout%global_first > huge(first_global) - int(layout%last, int64) + 1_int64) return
      first_global = layout%global_first + int(layout%first, int64) - 1
      last_global = layout%global_first + int(layout%last, int64) - 1
      if (first_global < layout%map_lower .or. last_global > layout%map_upper) return
      do row = int(layout%first, int64), int(layout%last, int64)
        index = layout%global_first + row - 1 - layout%map_lower + 1
        if (map(index) < 1 .or. map(index) > layout%target_points) return
      end do
    end if
    status = 0
  end function

  !> Visit fields first and rows second; repeated mapped rows keep the last write.
  !! Only active selected cells change. All unused cells and raw FP bits survive.
  integer(int32) function scatter_transport_field_block(layout, map, source, destination) result(status)
    type(transport_scatter_layout), target, intent(in) :: layout
    integer(int32), target, intent(in) :: map(:)
    real(real64), target, intent(in) :: source(:, :)
    real(real64), target, intent(inout) :: destination(:, :)
    integer(int64) :: field, row, index, target_row
    integer(int64), volatile :: bits
    status = admit_transport_field_block(layout, map, source, destination)
    if (status /= 0) return
    do field = 1_int64, int(layout%field_count, int64)
      do row = int(layout%first, int64), int(layout%last, int64)
        index = layout%global_first + row - 1 - layout%map_lower + 1
        target_row = int(map(index), int64)
        bits = transfer(source(row, field), 0_int64)
        destination(target_row, field) = transfer(bits, 0.0_real64)
      end do
    end do
  end function

  !> Check native mapped-address arithmetic without probing memory or doing FP work.
  logical function checked_address_span(address, count, width, span) result(valid)
    integer(c_intptr_t), intent(in) :: address
    integer(int64), intent(in) :: count, width
    type(native_address_span), intent(out) :: span
    integer(int64) :: bytes
    valid = .false.
    span%first = 0
    span%after = 0
    if (count < 0 .or. width < 1) return
    if (count == 0) then
      valid = .true.
      return
    end if
    if (address <= 0) return
    if (count > huge(bytes)/width) return
    bytes = count*width
    if (bytes > int(huge(address) - address, int64)) return
    span%first = address
    span%after = address + int(bytes, c_intptr_t)
    valid = .true.
  end function

  logical function spans_disjoint(a, b) result(disjoint)
    type(native_address_span), intent(in) :: a, b
    disjoint = .true.
    if (a%first == a%after .or. b%first == b%after) return
    disjoint = a%after <= b%first .or. b%after <= a%first
  end function

  logical function buffer_span_real1(field, span) result(valid)
    real(real64), target, intent(in) :: field(:)
    type(native_address_span), intent(out) :: span
    integer(int64) :: n1, i1
    integer(c_intptr_t) :: address, lowest, highest
    integer :: corner
    span%first = 0
    span%after = 0
    valid = .true.
    n1 = size(field, 1, kind=int64)
    if (n1 == 0) return
    lowest = huge(lowest)
    highest = 0
    do corner = 0, 1
      i1 = 1
      if (btest(corner, 0)) i1 = n1
      address = transfer(c_loc(field(i1)), 0_c_intptr_t)
      if (address <= 0) then
        valid = .false.
        return
      end if
      lowest = min(lowest, address)
      highest = max(highest, address)
    end do
    valid = .false.
    if (highest > huge(highest) - 8_c_intptr_t) return
    span%first = lowest
    span%after = highest + 8_c_intptr_t
    valid = .true.
  end function

  logical function buffer_span_real2(field, span) result(valid)
    real(real64), target, intent(in) :: field(:, :)
    type(native_address_span), intent(out) :: span
    integer(int64) :: n1, n2, i1, i2
    integer(c_intptr_t) :: address, lowest, highest
    integer :: corner
    span%first = 0
    span%after = 0
    valid = .true.
    n1 = size(field, 1, kind=int64)
    n2 = size(field, 2, kind=int64)
    if (n1 == 0 .or. n2 == 0) return
    lowest = huge(lowest)
    highest = 0
    do corner = 0, 3
      i1 = 1
      if (btest(corner, 0)) i1 = n1
      i2 = 1
      if (btest(corner, 1)) i2 = n2
      address = transfer(c_loc(field(i1, i2)), 0_c_intptr_t)
      if (address <= 0) then
        valid = .false.
        return
      end if
      lowest = min(lowest, address)
      highest = max(highest, address)
    end do
    valid = .false.
    if (highest > huge(highest) - 8_c_intptr_t) return
    span%first = lowest
    span%after = highest + 8_c_intptr_t
    valid = .true.
  end function

  logical function buffer_span_real3(field, span) result(valid)
    real(real64), target, intent(in) :: field(:, :, :)
    type(native_address_span), intent(out) :: span
    integer(int64) :: n1, n2, n3, i1, i2, i3
    integer(c_intptr_t) :: address, lowest, highest
    integer :: corner
    span%first = 0
    span%after = 0
    valid = .true.
    n1 = size(field, 1, kind=int64)
    n2 = size(field, 2, kind=int64)
    n3 = size(field, 3, kind=int64)
    if (n1 == 0 .or. n2 == 0 .or. n3 == 0) return
    lowest = huge(lowest)
    highest = 0
    do corner = 0, 7
      i1 = 1
      if (btest(corner, 0)) i1 = n1
      i2 = 1
      if (btest(corner, 1)) i2 = n2
      i3 = 1
      if (btest(corner, 2)) i3 = n3
      address = transfer(c_loc(field(i1, i2, i3)), 0_c_intptr_t)
      if (address <= 0) then
        valid = .false.
        return
      end if
      lowest = min(lowest, address)
      highest = max(highest, address)
    end do
    valid = .false.
    if (highest > huge(highest) - 8_c_intptr_t) return
    span%first = lowest
    span%after = highest + 8_c_intptr_t
    valid = .true.
  end function

  logical function buffer_span_integer1(field, span) result(valid)
    integer(int32), target, intent(in) :: field(:)
    type(native_address_span), intent(out) :: span
    integer(int64) :: n1, i1
    integer(c_intptr_t) :: address, lowest, highest
    integer :: corner
    span%first = 0
    span%after = 0
    valid = .true.
    n1 = size(field, 1, kind=int64)
    if (n1 == 0) return
    lowest = huge(lowest)
    highest = 0
    do corner = 0, 1
      i1 = 1
      if (btest(corner, 0)) i1 = n1
      address = transfer(c_loc(field(i1)), 0_c_intptr_t)
      if (address <= 0) then
        valid = .false.
        return
      end if
      lowest = min(lowest, address)
      highest = max(highest, address)
    end do
    valid = .false.
    if (highest > huge(highest) - 4_c_intptr_t) return
    span%first = lowest
    span%after = highest + 4_c_intptr_t
    valid = .true.
  end function

end module
