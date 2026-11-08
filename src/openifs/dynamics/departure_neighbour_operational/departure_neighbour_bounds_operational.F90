!> Live-size local bounds for eight departure-point neighbours.
module departure_neighbour_bounds_operational_mod
  !! This separate entry extends native buffer sizes. The accepted historical
  !! entry, source, object and numerical domain are retained unchanged.
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_intptr_t
  implicit none
  private
  public :: bound_eight_neighbours_operational
  integer(int64), parameter :: address_span_limit = int(huge(0_c_intptr_t), int64)
  integer(int64), parameter :: real_bytes = int(storage_size(0.0_real64)/8, int64)
  integer(int64), parameter :: index_bytes = int(storage_size(0_int32)/8, int64)
contains
  !> Compute source-ordered minimum and optional maximum of eight neighbours.
  !! SOURCE_PITCH is the source-field plane width in elements. PITCH is
  !! the destination-column width. FIRST:LAST selects destination columns
  !! and LEVELS selects destination levels. FIRST_PLANE:LAST_PLANE gives
  !! the source plane count. INDICES has shape(PITCH,at least LEVELS,4);
  !! its middle planes2 and3 hold source indices with zero-origin bases.
  !! FIELD is a flat, readonly source view. Its complete extent must be
  !! SOURCE_PITCH times the source plane count. MINIMUM and optional
  !! MAXIMUM have shape(PITCH,at least LEVELS), keep the field's physical
  !! unit, and mutate only the selected columns and levels.
  !! Ordinary assumed-shape views allow stride refusal before payload
  !! reads; no CONTIGUOUS dummy can introduce an implicit copy.
  !! Caller supplies valid native descriptors and disjoint writable owners,
  !! and establishes nearest-even rounding with gradual underflow.
  !! STATUS is0 on success and2 on refusal. Refusal changes no array.
  !! This extension makes no claim of large-domain byte acceptance.
  subroutine bound_eight_neighbours_operational(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                                indices, field, minimum, status, maximum)
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels, first_plane, last_plane
    integer(int32), intent(in) :: indices(:, :, :)
    real(real64), intent(in) :: field(:)
    real(real64), intent(inout) :: minimum(:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(inout), optional :: maximum(:, :)
    integer(int64) :: planes, total, a, k1, live_source_pitch, cell, level
    integer :: h, s, e
    status = 2
    planes = int(last_plane, int64) - int(first_plane, int64) + 1_int64
    if (source_pitch < 0 .or. pitch < 0 .or. levels < 0 .or. planes < 0) return
    if (first < 1 .or. int(first, int64) > int(pitch, int64) + 1_int64 .or. last < 0 .or. last > pitch) return
    status = 0
    if (levels == 0 .or. first > last) return
    status = 2
    if (planes < 1) return
    if (.not. is_contiguous(indices) .or. .not. is_contiguous(field) .or. .not. is_contiguous(minimum)) return
    if (size(indices, 1, kind=int64) /= int(pitch, int64)) return
    if (size(indices, 2, kind=int64) < int(levels, int64) .or. size(indices, 3, kind=int64) /= 4_int64) return
    if (size(minimum, 1, kind=int64) /= int(pitch, int64) .or. size(minimum, 2, kind=int64) < int(levels, int64)) return
    if (.not. complete_span_fits(size(indices, 1, kind=int64), size(indices, 2, kind=int64), 4_int64, index_bytes)) return
    if (.not. complete_span_fits(size(minimum, 1, kind=int64), size(minimum, 2, kind=int64), 1_int64, real_bytes)) return
    if (present(maximum)) then
      if (.not. is_contiguous(maximum)) return
      if (size(maximum, 1, kind=int64) /= int(pitch, int64) .or. size(maximum, 2, kind=int64) < int(levels, int64)) return
      if (.not. complete_span_fits(size(maximum, 1, kind=int64), size(maximum, 2, kind=int64), 1_int64, real_bytes)) return
    end if
    total = size(field, kind=int64)
    if (.not. complete_span_fits(total, 1_int64, 1_int64, real_bytes)) return
    if (modulo(total, planes) /= 0_int64) return
    live_source_pitch = total/planes
    if (live_source_pitch /= int(source_pitch, int64)) return
    if (live_source_pitch < 1_int64) return
    a = live_source_pitch
    ! The int32 index plus two int32-width planes fits int64. Complete
    ! source and output spans are checked before any neighbour is read.
    do level = 1_int64, int(levels, int64)
      do cell = int(first, int64), int(last, int64)
        do s = 2, 3
          k1 = int(indices(cell, level, s), int64)
          if (k1 + a < 0_int64 .or. k1 + 2_int64*a + 1_int64 >= total) return
          do h = 1, 2
            do e = 0, 1
              if (.not. finite(field(k1 + int(h, int64)*a + int(e, int64) + 1_int64))) return
            end do
          end do
        end do
      end do
    end do
    ! Both optional-output routes call the same single ordered body.
    call ordered_neighbour_bounds(a, first, last, levels, indices, field, minimum, maximum)
    status = 0
  end subroutine bound_eight_neighbours_operational
  !> Check the complete native element span before multiplying its extents.
  logical function complete_span_fits(n1, n2, n3, element_bytes) result(fits)
    integer(int64), intent(in) :: n1, n2, n3, element_bytes
    integer(int64) :: element_limit, elements
    fits = .false.
    if (n1 < 0 .or. n2 < 0 .or. n3 < 0 .or. element_bytes < 1) return
    if (n1 == 0 .or. n2 == 0 .or. n3 == 0) then
      fits = .true.; return
    end if
    element_limit = address_span_limit/element_bytes
    if (n1 > element_limit) return
    if (n2 > element_limit/n1) return
    elements = n1*n2
    if (n3 > element_limit/elements) return
    fits = .true.
  end function complete_span_fits
  !> Reuse the accepted field gather and ordered minimum/maximum sequence.
  !! The sole source transformation here widens the integer loop counters.
  subroutine ordered_neighbour_bounds(a, first, last, levels, indices, field, minimum, maximum)
    integer(int64), intent(in) :: a
    integer(int32), intent(in) :: first, last, levels
    integer(int32), intent(in) :: indices(:, :, :)
    real(real64), intent(in) :: field(:)
    real(real64), intent(inout) :: minimum(:, :)
    real(real64), intent(inout), optional :: maximum(:, :)
    integer(int64) :: cell, level, k1, k2
    integer :: j
    real(real64) :: values(8), lo, hi
    do level = 1_int64, int(levels, int64)
      do cell = int(first, int64), int(last, int64)
        k1 = int(indices(cell, level, 2), int64) + a + 1
        k2 = int(indices(cell, level, 3), int64) + a + 1
        values = [field(k1), field(k1 + 1), field(k2), field(k2 + 1), &
                  field(k1 + a), field(k1 + a + 1), field(k2 + a), field(k2 + a + 1)]
        lo = ordered_minimum(values(1), values(2))
        do j = 3, 8
          lo = ordered_minimum(lo, values(j))
        end do
        minimum(cell, level) = lo
        if (present(maximum)) then
          hi = ordered_maximum(values(1), values(2))
          do j = 3, 8
            hi = ordered_maximum(hi, values(j))
          end do
          maximum(cell, level) = hi
        end if
      end do
    end do
  end subroutine ordered_neighbour_bounds
  elemental logical function finite(value)
    real(real64), intent(in) :: value
    finite = ibits(transfer(value, 0_int64), 52, 11) /= 2047_int64
  end function
  real(real64) function ordered_minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    if (a == b) then
      value = a
      if (a == 0.0_real64) value = transfer(ior(transfer(a, 0_int64), transfer(b, 0_int64)), 0.0_real64)
    else if (a < b) then
      value = a
    else
      value = b
    end if
  end function
  real(real64) function ordered_maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    if (a == b) then
      value = a
      if (a == 0.0_real64) value = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), 0.0_real64)
    else if (a > b) then
      value = a
    else
      value = b
    end if
  end function
end module departure_neighbour_bounds_operational_mod
