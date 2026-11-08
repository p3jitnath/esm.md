!> Construct native local spherical-grid maps and six ordered constants.
module forecast_spherical_grid_setup
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  private
  public :: native_spherical_grid_constants, native_spherical_grid_state
  public :: initialize_spherical_grid, release_spherical_grid
  !> Source SUGEM1B constants, with spacing rdelxn in metres.
  !! r4jp, rc2p1, rc2m1, rcor0 and rcor1 are dimensionless.
  type, bind(C) :: native_spherical_grid_constants
    real(c_double) :: r4jp, rc2p1, rc2m1, rcor0, rcor1, rdelxn
  end type
  !> The state owns nstagp over the declared local physical-row bounds.
  !! A positive value is the one-based compressed point start; zero is inactive.
  type :: native_spherical_grid_state
    type(native_spherical_grid_constants) :: constants
    integer(c_int), allocatable :: nstagp(:)
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Copy local wave rows, construct compressed starts and calculate constants.
  !! global_rows and maximum_longitudes describe the live complete grid.
  !! wave_offset is zero-based; local_wave_rows is the distinct wave-row count.
  !! longitude_counts(1:) describes rows local_first:local_last.
  !! Global input maps start at row1 and can include higher source halo rows.
  !! The wave-copy window must fit their actual supplied extent. The caller supplies
  !! nloen/nmen physical sections; their halo words remain outside this call.
  !! Pi is in radians and radius is in metres. Unit stretch is required.
  !! Return2 preserves every output; return1 reports allocation failure.
  integer(c_int) function initialize_spherical_grid(state, global_rows, maximum_longitudes, &
                                                    local_wave_rows, wave_offset, local_first, local_last, longitude_counts, &
                                              global_nloen, global_nmen, nloen, nmen, pole_sine, stretch, pi, radius) result(status)
    type(native_spherical_grid_state), intent(inout) :: state
    integer(c_int), intent(in) :: global_rows, maximum_longitudes, local_wave_rows, wave_offset
    integer(c_int), intent(in) :: local_first, local_last
    integer(c_int), intent(in) :: longitude_counts(:), global_nloen(:), global_nmen(:)
    integer(c_int), intent(inout) :: nloen(:), nmen(:)
    real(c_double), intent(in) :: pole_sine, stretch, pi, radius
    integer(c_int64_t) :: running
    integer :: row, local_row, allocation_status
    real(c_double) :: temporary, denominator
    real(c_double), volatile :: square_root_input
    status = 2
    if (allocated(state%nstagp)) return
    if (global_rows < 1 .or. global_rows > 1048576) return
    if (maximum_longitudes < 1 .or. maximum_longitudes > 1048576) return
    if (local_wave_rows < 1 .or. local_wave_rows > global_rows) return
    if (wave_offset < 0 .or. wave_offset > 1048576) return
    if (wave_offset + local_wave_rows > size(global_nloen)) return
    if (wave_offset + local_wave_rows > size(global_nmen)) return
    if (local_first < 1 .or. local_last < local_first) return
    if (int(local_last, c_int64_t) - local_first + 1 /= size(longitude_counts, kind=c_int64_t)) return
    if (size(global_nloen) < global_rows .or. size(global_nmen) < global_rows) return
    if (size(nloen) < local_wave_rows .or. size(nmen) < local_wave_rows) return
    if (transfer(stretch, 0_c_int64_t) /= int(z'3ff0000000000000', c_int64_t)) return
    if (ibits(transfer(pole_sine, 0_c_int64_t), 52, 11) == 2047) return
    if (abs(pole_sine) > 1.0_c_double) return
    if (transfer(pi, 0_c_int64_t) /= int(z'400921fb54442d18', c_int64_t)) return
    if (transfer(radius, 0_c_int64_t) /= int(z'41584de740000000', c_int64_t)) return
    running = 1
    do row = 1, size(longitude_counts)
      if (longitude_counts(row) > maximum_longitudes) return
      running = running + max(0_c_int, longitude_counts(row))
      if (running > huge(0_c_int)) return
    end do
    allocate (state%nstagp(local_first:local_last), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    temporary = 4.0_c_double*real(global_rows, c_double)
    temporary = temporary + 2.0_c_double
    denominator = 4.0_c_double*pi
    state%constants%r4jp = temporary/denominator
    temporary = stretch*stretch
    state%constants%rc2p1 = temporary + 1.0_c_double
    temporary = stretch*stretch
    state%constants%rc2m1 = temporary - 1.0_c_double
    state%constants%rcor0 = 0.0_c_double
    square_root_input = 3.0_c_double
    temporary = sqrt(square_root_input)
    state%constants%rcor1 = pole_sine/temporary
    do row = 1, local_wave_rows
      nmen(row) = global_nmen(wave_offset + row)
      nloen(row) = global_nloen(wave_offset + row)
    end do
    running = 1
    do local_row = local_first, local_last
      row = local_row - local_first + 1
      if (longitude_counts(row) > 0) then
        state%nstagp(local_row) = int(running, c_int)
        running = running + longitude_counts(row)
      else
        state%nstagp(local_row) = 0
      end if
    end do
    temporary = 2.0_c_double*pi
    temporary = temporary*radius
    state%constants%rdelxn = temporary/real(maximum_longitudes, c_double)
    status = 0
  end function

  !> Release the single owned map while preserving incoming status.
  subroutine release_spherical_grid(state)
    type(native_spherical_grid_state), intent(inout) :: state
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    if (allocated(state%nstagp)) deallocate (state%nstagp)
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
  end subroutine
end module forecast_spherical_grid_setup
