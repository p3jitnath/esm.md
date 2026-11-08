!> Construct the six native computational point-geometry arrays.
module forecast_computational_geometry
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_spherical_point_geometry, only: spherical_physical_values
  implicit none
  private
  public :: native_computational_geometry, initialize_computational_geometry
  public :: initialize_selected_computational_geometry, release_computational_geometry
  public :: spherical_resolution_scale
  !> Arrays own points 1:point_count in compressed local storage order.
  !! rcolon/rsilon are dimensionless; rindx/rindy are exact one-based indices
  !! stored as FP64. ratath has units of inverse metres; ratatx is zero.
  type :: native_computational_geometry
    real(c_double), allocatable :: rcolon(:), rsilon(:), rindx(:), rindy(:), ratath(:), ratatx(:)
  end type
  interface
    function public_cosine(x) bind(C, name="cos") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_sine(x) bind(C, name="sin") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Admit the qualified unit-sphere constants without floating-point operations.
  logical function qualified_physical(p)
    type(spherical_physical_values), intent(in) :: p
    qualified_physical = .false.
    if (transfer(p%stretch, 0_c_int64_t) /= int(z'3ff0000000000000', c_int64_t)) return
    if (transfer(p%rc2p1, 0_c_int64_t) /= int(z'4000000000000000', c_int64_t)) return
    if (transfer(p%rc2m1, 0_c_int64_t) /= 0_c_int64_t) return
    if (transfer(p%radius, 0_c_int64_t) /= int(z'41584de740000000', c_int64_t)) return
    if (transfer(p%pi, 0_c_int64_t) /= int(z'400921fb54442d18', c_int64_t)) return
    qualified_physical = .true.
  end function

  !> Construct local fields from live global rows and longitude ranges.
  !! All row metadata arrays have the same extent. local_rows gives one-based
  !! global latitude rows; point_starts gives one-based compressed positions.
  !! first_longitudes and longitude_counts give the physical range per row.
  !! mu and cosine_latitude contain complete physical latitude arrays.
  !! Every integer output position must be covered once in increasing order.
  !! The caller owns these read-only arrays; state owns six fresh outputs.
  !! Return2 is an atomic refusal; return1 releases acquired output owners.
  integer(c_int) function initialize_computational_geometry(state, p, point_count, global_longitudes, &
                                   local_rows, point_starts, first_longitudes, longitude_counts, mu, cosine_latitude) result(status)
    type(native_computational_geometry), intent(inout) :: state
    type(spherical_physical_values), intent(in) :: p
    integer(c_int), intent(in) :: point_count
    integer(c_int), intent(in) :: global_longitudes(:), local_rows(:), point_starts(:)
    integer(c_int), intent(in) :: first_longitudes(:), longitude_counts(:)
    real(c_double), intent(in) :: mu(:), cosine_latitude(:)
    integer(c_int64_t) :: expected, last_longitude
    integer :: row, global_row, longitude, last_index, point, allocation_status
    real(c_double) :: angle, temporary, numerator, denominator
    status = 2
    if (allocated(state%rcolon) .or. allocated(state%rsilon)) return
    if (allocated(state%rindx) .or. allocated(state%rindy)) return
    if (allocated(state%ratath) .or. allocated(state%ratatx)) return
    if (.not. qualified_physical(p)) return
    if (point_count < 1) return
    if (size(global_longitudes) < 1 .or. size(local_rows) < 1) return
    if (size(mu) /= size(global_longitudes) .or. size(cosine_latitude) /= size(global_longitudes)) return
    if (size(point_starts) /= size(local_rows) .or. size(first_longitudes) /= size(local_rows)) return
    if (size(longitude_counts) /= size(local_rows)) return
    expected = 1
    do row = 1, size(local_rows)
      global_row = local_rows(row)
      if (global_row < 1 .or. global_row > size(global_longitudes)) return
      if (global_longitudes(global_row) < 1 .or. global_longitudes(global_row) > huge(0_c_int)/2) return
      if (longitude_counts(row) < 0) return
      if (longitude_counts(row) == 0) cycle
      if (first_longitudes(row) < 1) return
      last_longitude = int(first_longitudes(row), c_int64_t) + longitude_counts(row) - 1
      if (last_longitude > global_longitudes(global_row)) return
      if (point_starts(row) /= expected) return
      expected = expected + longitude_counts(row)
      if (expected > int(point_count, c_int64_t) + 1) return
    end do
    if (expected /= int(point_count, c_int64_t) + 1) return
    allocate (state%rcolon(point_count), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%rsilon(point_count), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%rindx(point_count), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%rindy(point_count), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%ratath(point_count), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%ratatx(point_count), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    do row = 1, size(local_rows)
      global_row = local_rows(row)
      if (longitude_counts(row) == 0) cycle
      point = point_starts(row)
      last_index = first_longitudes(row) + longitude_counts(row) - 1
      do longitude = first_longitudes(row), last_index
        temporary = real(2*(longitude - 1), c_double)
        temporary = p%pi*temporary
        temporary = temporary/real(global_longitudes(global_row), c_double)
        angle = 0.0_c_double + temporary
        state%rcolon(point) = public_cosine(angle)
        state%rsilon(point) = public_sine(angle)
        state%rindx(point) = real(longitude, c_double)
        state%rindy(point) = real(global_row, c_double)
        numerator = mu(global_row)*p%rc2p1
        numerator = p%rc2m1 + numerator
        denominator = p%stretch*p%radius
        denominator = denominator*cosine_latitude(global_row)
        state%ratath(point) = numerator/denominator
        state%ratatx(point) = 0.0_c_double
        point = point + 1
      end do
    end do
    status = 0
    return
900 continue
    call release_computational_geometry(state)
    status = 1
  end function

  !> Retain the selected 32-row, 64-longitude route through the shared body.
  integer(c_int) function initialize_selected_computational_geometry(state, p, mu, cosine_latitude) result(status)
    type(native_computational_geometry), intent(inout) :: state
    type(spherical_physical_values), intent(in) :: p
    real(c_double), intent(in) :: mu(32), cosine_latitude(32)
    integer(c_int) :: rows(32), starts(32), first(32), counts(32), global_longitudes(32)
    integer :: row
    do row = 1, 32
      rows(row) = row
      starts(row) = 64*(row - 1) + 1
    end do
    first = 1
    counts = 64
    global_longitudes = 64
    status = initialize_computational_geometry(state, p, 2048_c_int, global_longitudes, rows, starts, &
                                               first, counts, mu, cosine_latitude)
  end function

  !> Calculate the original SLHDP resolution length in metres.
  !! The admitted truncation is 1:1279. Return2 preserves output.
  integer(c_int) function spherical_resolution_scale(output, p, truncation) result(status)
    real(c_double), intent(inout) :: output
    type(spherical_physical_values), intent(in) :: p
    integer(c_int), intent(in) :: truncation
    integer(c_int) :: denominator_integer
    real(c_double) :: temporary, denominator
    status = 2
    if (truncation < 1 .or. truncation > 1279) return
    if (transfer(p%radius, 0_c_int64_t) /= int(z'41584de740000000', c_int64_t)) return
    if (transfer(p%pi, 0_c_int64_t) /= int(z'400921fb54442d18', c_int64_t)) return
    denominator_integer = truncation*(truncation + 1)
    denominator = real(denominator_integer, c_double)
    temporary = 8.0_c_double*p%radius
    temporary = temporary*p%radius
    temporary = temporary/denominator
    temporary = sqrt(temporary)
    output = p%pi*temporary
    status = 0
  end function

  !> Release six owned arrays in source order, preserving incoming status.
  subroutine release_computational_geometry(state)
    type(native_computational_geometry), intent(inout) :: state
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    if (allocated(state%rcolon)) deallocate (state%rcolon)
    if (allocated(state%rsilon)) deallocate (state%rsilon)
    if (allocated(state%rindx)) deallocate (state%rindx)
    if (allocated(state%rindy)) deallocate (state%rindy)
    if (allocated(state%ratath)) deallocate (state%ratath)
    if (allocated(state%ratatx)) deallocate (state%ratatx)
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
  end subroutine
end module forecast_computational_geometry
