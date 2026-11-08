!> Source block selection and integer maps for the global hydrostatic route.
!! These leaves own no public transform lifetime or enclosing geometry record.
!! The caller establishes nearest-even rounding and gradual underflow. The old
!! raw FPCR/pointer refusal ABI is outside these native typed interfaces.
module forecast_operational_serial_partition_children
  use iso_c_binding, only: c_int, c_int64_t, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_grid_dimensions, only: native_grid_dimensions
  use oml_mod, only: oml_max_threads
  implicit none
  private
  public :: initialize_operational_serial_block_size, initialize_operational_serial_grid_maps
  public :: initialize_portable_operational_serial_block_size, initialize_portable_operational_serial_grid_maps
  interface
    function errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Select NPROMA16 ->17 through the actual public FIAT thread query.
 !! The caller admits the global hydrostatic scalar-platform configuration.
 !! STATE supplies active and maximum point counts; GRID is updated only
 !! after one actual thread is admitted. Return0 complete or2 refusal.
  integer(c_int) function initialize_operational_serial_block_size(state, grid) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(inout) :: grid
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_error, threads, first, last, count_minus_one, blocks, candidate, trial_blocks, trial_width
    status = 2
    if (.not. operational_block_inputs(state, grid)) return
    if (grid%nproma /= 16 .or. grid%loptproma /= 1) return
    call c_f_pointer(errno_location(), error_pointer)
    saved_error = error_pointer
    call ieee_get_status(saved)
    threads = oml_max_threads()
    if (threads /= 1) goto900
    count_minus_one = state%ngptotmx - 1
    first = grid%nproma + 1
    last = first + grid%nproma*5/100
    blocks = count_minus_one/grid%nproma + 1
    grid%nproma = count_minus_one/blocks + 1
    do candidate = first, last
      trial_blocks = count_minus_one/candidate + 1
      trial_width = count_minus_one/trial_blocks + 1
      if (trial_blocks < blocks) then
        blocks = trial_blocks
        grid%nproma = trial_width
      end if
    end do
    state%npromm = grid%nproma
    state%npromnh = 1
    status = 0
900 call ieee_set_status(saved)
    error_pointer = saved_error
  end function

  !> Separate source-disabled optimization extension: width24 stays24.
 !! Original SUOPTPROMA does not call OML_MAX_THREADS when LOPTPROMA is false.
  integer(c_int) function initialize_portable_operational_serial_block_size(state, grid) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(inout) :: grid
    status = 2
    if (.not. operational_block_inputs(state, grid)) return
    if (grid%nproma /= 24 .or. grid%loptproma /= 0) return
    state%npromm = grid%nproma
    state%npromnh = 1
    status = 0
  end function

  logical function operational_block_inputs(state, grid) result(valid)
    type(native_distributed_partition), intent(in) :: state
    type(native_grid_dimensions), intent(in) :: grid
    valid = .false.
    if (grid%ndglg /= 2560 .or. grid%ncmax /= 1279 .or. grid%nflevg /= 137) return
    if (state%ngptot /= 6599680 .or. state%ngptotmx /= 6599680) return
    valid = .true.
  end function

  !> Fill the eight source map owners for historical width17.
 !! PHYSICAL_LONGITUDES has bounds1:2560 and no halo. All consumed owners
 !! have the source bounds. No NMSMAX check is added: this leaf never reads it.
  integer(c_int) function initialize_operational_serial_grid_maps(state, grid, physical_longitudes) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: physical_longitudes(:)
    status = initialize_grid_maps(state, grid, physical_longitudes, .false.)
  end function

  !> Same source map equations for the separately admitted width24 extension.
  integer(c_int) function initialize_portable_operational_serial_grid_maps(state, grid, physical_longitudes) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: physical_longitudes(:)
    status = initialize_grid_maps(state, grid, physical_longitudes, .true.)
  end function

  integer(c_int) function initialize_grid_maps(state, grid, physical_longitudes, portable) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: physical_longitudes(:)
    logical, intent(in) :: portable
    integer(c_int), allocatable :: global_indices(:, :)
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_error, row, column, point, global_point, block, cell, j, expected_width, expected_blocks
    integer :: allocation_status
    integer(c_int64_t) :: point_sum
    status = 2
    expected_width = 17; expected_blocks = 388217
    if (portable) then
      expected_width = 24; expected_blocks = 274987
    end if
    if (grid%ndglg /= 2560 .or. grid%ndlon /= 5136 .or. grid%nflevg /= 137) return
    if (grid%ncmax /= 1279 .or. grid%nsmax /= 1279) return
    if (grid%nproma /= expected_width .or. state%ngpblks /= expected_blocks) return
    if (portable .and. grid%loptproma /= 0) return
    if (state%ndgsal /= 1 .or. state%ndgenl /= 2560 .or. state%nflevl /= 137) return
    if (state%nfrstloff /= 0 .or. state%nptrfloff /= 0) return
    if (state%ngptot /= 6599680 .or. state%ngptotg /= 6599680) return
    if (state%ngptotmx /= 6599680 .or. state%ngptot_cap /= 6599680) return
    if (state%nbsetsp /= 1 .or. state%ndgll /= 2560) return
    if (size(physical_longitudes) /= 2560) return
    if (.not. rank_one(state%mylevs, 1, 137)) return
    if (.not. rank_one(state%mylats, 1, 2560)) return
    if (.not. rank_one(state%nglobalindex, 1, 6599680)) return
    if (.not. rank_one(state%nglobalat, 1, 6599680)) return
    if (.not. rank_one(state%nglobalproc, 1, 6599680)) return
    if (.not. rank_one(state%nlocalindex, 1, 6599680)) return
    if (.not. rank_two(state%nlatgpp, 1, expected_width, 1, expected_blocks)) return
    if (.not. rank_two(state%nlongpp, 1, expected_width, 1, expected_blocks)) return
    if (.not. rank_two(state%nsta, -1, 2562, 1, 1)) return
    if (.not. rank_two(state%nonl, -1, 2562, 1, 1)) return
    if (.not. rank_one(state%nptrll, 1, 2)) return
    if (.not. rank_one(state%nptrfrstlat, 1, 1)) return
    if (.not. rank_one(state%nfrstlat, 1, 1)) return
    if (.not. rank_one(state%nlstlat, 1, 1)) return
    if (state%nfrstlat(1) /= 1 .or. state%nlstlat(1) /= 2560) return
    if (state%nptrfrstlat(1) /= 1 .or. state%nptrll(1) /= 1) return
    point_sum = 0
    do row = 1, grid%ndglg
      if (physical_longitudes(row) < 1 .or. physical_longitudes(row) > grid%ndlon) return
      if (state%nsta(row, 1) /= 1 .or. state%nonl(row, 1) /= physical_longitudes(row)) return
      point_sum = point_sum + int(physical_longitudes(row), c_int64_t)
    end do
    if (point_sum /= 6599680_c_int64_t) return
    call c_f_pointer(errno_location(), error_pointer)
    saved_error = error_pointer
    call ieee_get_status(saved)
    status = 1
    allocate (global_indices(grid%ndlon, grid%ndglg), stat=allocation_status)
    if (allocation_status /= 0) goto900
    do j = 1, state%nflevl
      state%mylevs(j) = state%nptrll(1) + j - 1
    end do
    do j = 1, grid%ndglg
      state%mylats(j) = state%nfrstlat(1) + j - 1
    end do
    do row = 1, grid%ndglg
      do column = 1, grid%ndlon
        global_indices(column, row) = 0
      end do
    end do
    point = 1
    do row = 1, grid%ndglg
      do column = 1, physical_longitudes(row)
        global_indices(column, row) = point
        point = point + 1
      end do
    end do
    point = 0
    do row = 1, grid%ndglg
      do column = 1, physical_longitudes(row)
        point = point + 1
        state%nglobalindex(point) = global_indices(column, row)
        state%nglobalat(point) = row
      end do
    end do
    do point = 1, state%ngptotg
      state%nglobalproc(point) = 0
    end do
    point = 0
    do row = 1, grid%ndglg
      do column = 1, physical_longitudes(row)
        global_point = global_indices(column, row)
        state%nglobalproc(global_point) = 1
        point = point + 1
        state%nlocalindex(global_point) = point
      end do
    end do
    do block = 1, state%ngpblks
      do cell = 1, grid%nproma
        state%nlatgpp(cell, block) = -99999
        state%nlongpp(cell, block) = -99999
      end do
    end do
    point = 0
    do row = 1, grid%ndglg
      do column = 1, physical_longitudes(row)
        point = point + 1
        block = (point - 1)/grid%nproma + 1
        cell = point - (block - 1)*grid%nproma
        state%nlatgpp(cell, block) = state%mylats(row)
        state%nlongpp(cell, block) = column
      end do
    end do
    if ((point - 1)/grid%nproma + 1 /= state%ngpblks) error stop 'Inconsistent serial partition block count'
    deallocate (global_indices)
    status = 0
900 call ieee_set_status(saved)
    error_pointer = saved_error
  end function

  logical function rank_one(values, first, last) result(valid)
    integer(c_int), allocatable, intent(in) :: values(:)
    integer(c_int), intent(in) :: first, last
    valid = .false.
    if (.not. allocated(values)) return
    if (lbound(values, 1) /= first .or. ubound(values, 1) /= last) return
    valid = .true.
  end function
  logical function rank_two(values, first1, last1, first2, last2) result(valid)
    integer(c_int), allocatable, intent(in) :: values(:, :)
    integer(c_int), intent(in) :: first1, last1, first2, last2
    valid = .false.
    if (.not. allocated(values)) return
    if (any(lbound(values) /= [first1, first2]) .or. any(ubound(values) /= [last1, last2])) return
    valid = .true.
  end function
end module forecast_operational_serial_partition_children
