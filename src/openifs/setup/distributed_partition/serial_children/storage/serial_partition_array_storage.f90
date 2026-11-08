!> Own the exact three source serial partition storage phases.
module forecast_serial_partition_array_storage
  use iso_c_binding, only: c_int, c_int64_t, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_grid_dimensions, only: native_grid_dimensions
  implicit none
  private
  public :: allocate_serial_partition_arrays, allocate_operational_partition_arrays
  public :: allocate_portable_operational_partition_arrays, release_serial_partition_arrays
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
!> Allocate only the selected source phase,without writing payload values.
!! STATE is a native owner with INOUT intent. GRID and SERIAL_COUNTS are
!! read-only; the five INT32 counts are all one on this one-process entry.
!! PHASE is INT32:0 owns26 arrays,1 owns2 arrays,and2 owns6 arrays.
!! Counts and indices are dimensionless. Fresh phase owners are required.
!! Zero-sized arrays remain allocated with their exact native empty bounds.
!! Return0 completes,1 releases this phase after allocation failure,and2
!! refuses before mutation. Entry IEEE status and errno are preserved.
  integer(c_int) function allocate_serial_partition_arrays(state, grid, serial_counts, phase) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: serial_counts(5), phase
    status = allocate_phase(state, grid, serial_counts, phase, 0_c_int)
  end function
!> Use the historical operational source dimensions and optimized width17.
  integer(c_int) function allocate_operational_partition_arrays(state, grid, serial_counts, phase) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: serial_counts(5), phase
    status = allocate_phase(state, grid, serial_counts, phase, 1_c_int)
  end function
!> Keep the separate live disabled-optimization operational width24 route.
!! The physical grid remains the same T1279,L137 one-process input. Array
!! extents still come from caller-owned live dimensions and local counts.
  integer(c_int) function allocate_portable_operational_partition_arrays(state, grid, serial_counts, phase) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: serial_counts(5), phase
    status = allocate_phase(state, grid, serial_counts, phase, 2_c_int)
  end function
  integer(c_int) function allocate_phase(state, grid, serial_counts, phase, route) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: serial_counts(5), phase, route
    type(ieee_status_type) :: entry_status
    integer(c_int), pointer, volatile :: error_word
    integer(c_int) :: entry_errno, unused_status
    integer :: allocation_status
    status = 2
    if (phase < 0 .or. phase > 2) return
    if (any(serial_counts /= 1)) return
    if (.not. admit_phase(state, grid, phase, route)) return
    if (.not. fresh_phase(state, phase)) return
    call c_f_pointer(errno_address(), error_word)
    entry_errno = error_word
    call ieee_get_status(entry_status)
    select case (phase)
    case (0)
      allocate (state%numll(2), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%npsurf(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%numpp(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nprocm(0:grid%ncmax), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrms(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%npossp(2), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nallms(max(grid%nsmax, grid%nmsmax) + 1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%ndim0g(0:max(grid%nsmax, grid%nmsmax)), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrls(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrsv(2), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrsvf(2), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrmf(2), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nspstaf(0:max(grid%nsmax, grid%nmsmax)), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrll(2), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nsta(grid%ndgsag:grid%ndgeng, 1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nonl(grid%ndgsag:grid%ndgeng, 1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrfrstlat(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrlstlat(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nptrlat(grid%ndglg), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%lsplitlat(grid%ndglg), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nfrstlat(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nlstlat(1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nbsetlev(grid%nflevg), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%ndlunl(grid%ndgsag:grid%ndgeng, 1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%ndluxl(grid%ndgsag:grid%ndgeng, 1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%ngptotl(1, 1), stat=allocation_status)
      if (allocation_status /= 0) goto 900
    case (1)
      allocate (state%nlongpp(grid%nproma, state%ngpblks), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nlatgpp(grid%nproma, state%ngpblks), stat=allocation_status)
      if (allocation_status /= 0) goto 900
    case (2)
      allocate (state%mylevs(state%nflevl), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%mylats(state%ndgsal:state%ndgenl), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nglobalindex(state%ngptot), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nglobalat(state%ngptot), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nglobalproc(state%ngptotg), stat=allocation_status)
      if (allocation_status /= 0) goto 900
      allocate (state%nlocalindex(state%ngptotg), stat=allocation_status)
      if (allocation_status /= 0) goto 900
    end select
    status = 0
    goto 910
900 continue
    unused_status = release_serial_partition_arrays(state, phase)
    status = 1
910 continue
    call ieee_set_status(entry_status)
    error_word = entry_errno
  end function
!> Read only the dimensions used by this source phase.
  logical function admit_phase(state, grid, phase, route) result(admitted)
    type(native_distributed_partition), intent(in) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int), intent(in) :: phase, route
    integer(c_int) :: width, expected_blocks
    admitted = .false.
    if (route < 0 .or. route > 2) return
    if (route == 0) then
      select case (phase)
      case (0)
        if (grid%ncmax < 0 .or. grid%ncmax > 21) return
        if (grid%nsmax < 0 .or. grid%nsmax > 21 .or. grid%nmsmax < 0 .or. grid%nmsmax > 21) return
        if (grid%ndgsag < -1 .or. grid%ndgsag > 1) return
        if (grid%ndgeng /= 33 - grid%ndgsag .or. grid%ndglg /= 32) return
        if (grid%nflevg < 0 .or. grid%nflevg > 19) return
      case (1)
        if (grid%nproma < 1 .or. grid%nproma > 24) return
        if (state%ngpblks < 0 .or. state%ngpblks > 86) return
      case (2)
        if (state%nflevl < 0 .or. state%nflevl > 19) return
        if (state%ndgsal < 1 .or. state%ndgsal > 32) return
        if (state%ndgenl < 0 .or. state%ndgenl > 32) return
        if (state%ndgenl + 1 < state%ndgsal) return
        if (state%ngptot < 0 .or. state%ngptot > 2048) return
        if (state%ngptotg < 1 .or. state%ngptotg > 2048 .or. state%ngptot > state%ngptotg) return
      end select
    else
      select case (phase)
      case (0)
        if (grid%ncmax /= 1279 .or. grid%nsmax /= 1279 .or. grid%nmsmax /= 1279) return
        if (grid%ndgsag /= -1 .or. grid%ndgeng /= 2562 .or. grid%ndglg /= 2560) return
        if (grid%nflevg /= 137) return
      case (1)
        width = 17
        if (route == 2) width = 24
        expected_blocks = (6599680_c_int - 1)/width + 1
        if (grid%nproma /= width .or. state%ngpblks /= expected_blocks) return
      case (2)
        if (state%nflevl /= 137 .or. state%ndgsal /= 1 .or. state%ndgenl /= 2560) return
        if (state%ngptot /= 6599680 .or. state%ngptotg /= 6599680) return
      end select
    end if
    admitted = .true.
  end function
  logical function fresh_phase(state, phase) result(fresh)
    type(native_distributed_partition), intent(in) :: state
    integer(c_int), intent(in) :: phase
    fresh = .true.
    select case (phase)
    case (0)
      if (allocated(state%numll)) fresh = .false.
      if (allocated(state%npsurf)) fresh = .false.
      if (allocated(state%numpp)) fresh = .false.
      if (allocated(state%nprocm)) fresh = .false.
      if (allocated(state%nptrms)) fresh = .false.
      if (allocated(state%npossp)) fresh = .false.
      if (allocated(state%nallms)) fresh = .false.
      if (allocated(state%ndim0g)) fresh = .false.
      if (allocated(state%nptrls)) fresh = .false.
      if (allocated(state%nptrsv)) fresh = .false.
      if (allocated(state%nptrsvf)) fresh = .false.
      if (allocated(state%nptrmf)) fresh = .false.
      if (allocated(state%nspstaf)) fresh = .false.
      if (allocated(state%nptrll)) fresh = .false.
      if (allocated(state%nsta)) fresh = .false.
      if (allocated(state%nonl)) fresh = .false.
      if (allocated(state%nptrfrstlat)) fresh = .false.
      if (allocated(state%nptrlstlat)) fresh = .false.
      if (allocated(state%nptrlat)) fresh = .false.
      if (allocated(state%lsplitlat)) fresh = .false.
      if (allocated(state%nfrstlat)) fresh = .false.
      if (allocated(state%nlstlat)) fresh = .false.
      if (allocated(state%nbsetlev)) fresh = .false.
      if (allocated(state%ndlunl)) fresh = .false.
      if (allocated(state%ndluxl)) fresh = .false.
      if (allocated(state%ngptotl)) fresh = .false.
    case (1)
      if (allocated(state%nlongpp)) fresh = .false.
      if (allocated(state%nlatgpp)) fresh = .false.
    case (2)
      if (allocated(state%mylevs)) fresh = .false.
      if (allocated(state%mylats)) fresh = .false.
      if (allocated(state%nglobalindex)) fresh = .false.
      if (allocated(state%nglobalat)) fresh = .false.
      if (allocated(state%nglobalproc)) fresh = .false.
      if (allocated(state%nlocalindex)) fresh = .false.
    end select
  end function
!> Free only this source phase,in its original owner order.
!! Repeated release succeeds. Other arrays,scalars and parent lifetime stay.
  integer(c_int) function release_serial_partition_arrays(state, phase) result(status)
    type(native_distributed_partition), intent(inout) :: state
    integer(c_int), intent(in) :: phase
    type(ieee_status_type) :: entry_status
    integer(c_int), pointer, volatile :: error_word
    integer(c_int) :: entry_errno
    status = 2
    if (phase < 0 .or. phase > 2) return
    call c_f_pointer(errno_address(), error_word)
    entry_errno = error_word
    call ieee_get_status(entry_status)
    select case (phase)
    case (0)
      if (allocated(state%numll)) deallocate (state%numll)
      if (allocated(state%npsurf)) deallocate (state%npsurf)
      if (allocated(state%numpp)) deallocate (state%numpp)
      if (allocated(state%nprocm)) deallocate (state%nprocm)
      if (allocated(state%nptrms)) deallocate (state%nptrms)
      if (allocated(state%npossp)) deallocate (state%npossp)
      if (allocated(state%nallms)) deallocate (state%nallms)
      if (allocated(state%ndim0g)) deallocate (state%ndim0g)
      if (allocated(state%nptrls)) deallocate (state%nptrls)
      if (allocated(state%nptrsv)) deallocate (state%nptrsv)
      if (allocated(state%nptrsvf)) deallocate (state%nptrsvf)
      if (allocated(state%nptrmf)) deallocate (state%nptrmf)
      if (allocated(state%nspstaf)) deallocate (state%nspstaf)
      if (allocated(state%nptrll)) deallocate (state%nptrll)
      if (allocated(state%nsta)) deallocate (state%nsta)
      if (allocated(state%nonl)) deallocate (state%nonl)
      if (allocated(state%nptrfrstlat)) deallocate (state%nptrfrstlat)
      if (allocated(state%nptrlstlat)) deallocate (state%nptrlstlat)
      if (allocated(state%nptrlat)) deallocate (state%nptrlat)
      if (allocated(state%lsplitlat)) deallocate (state%lsplitlat)
      if (allocated(state%nfrstlat)) deallocate (state%nfrstlat)
      if (allocated(state%nlstlat)) deallocate (state%nlstlat)
      if (allocated(state%nbsetlev)) deallocate (state%nbsetlev)
      if (allocated(state%ndlunl)) deallocate (state%ndlunl)
      if (allocated(state%ndluxl)) deallocate (state%ndluxl)
      if (allocated(state%ngptotl)) deallocate (state%ngptotl)
    case (1)
      if (allocated(state%nlongpp)) deallocate (state%nlongpp)
      if (allocated(state%nlatgpp)) deallocate (state%nlatgpp)
    case (2)
      if (allocated(state%mylevs)) deallocate (state%mylevs)
      if (allocated(state%mylats)) deallocate (state%mylats)
      if (allocated(state%nglobalindex)) deallocate (state%nglobalindex)
      if (allocated(state%nglobalat)) deallocate (state%nglobalat)
      if (allocated(state%nglobalproc)) deallocate (state%nglobalproc)
      if (allocated(state%nlocalindex)) deallocate (state%nlocalindex)
    end select
    call ieee_set_status(entry_status)
    error_word = entry_errno
    status = 0
  end function
end module forecast_serial_partition_array_storage
