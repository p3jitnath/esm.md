!> Adapt selected SUGEM1B and SUGEM2 entries to the canonical geometry owner.
!! These routines return status. Their enclosing entries own counters and aborts.
module forecast_selected_spherical_context
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_geometry_state_types, only: native_geometry_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_spherical_grid_setup, only: initialize_spherical_grid
  use forecast_spherical_geometry_setup, only: initialize_spherical_geometry
  use forecast_spherical_point_geometry, only: spherical_physical_values
  implicit none
  private
  public :: initialize_sugem1b_context, initialize_sugem2_context
  interface
    function public_get_mode(mode) bind(C, name='fegetmode') result(status)
      import c_int
      integer(c_int), intent(out) :: mode
      integer(c_int) :: status
    end function
  end interface
contains
  !> Read the public AArch64 control word without changing the environment.
  !! The public libc ABI uses one unsigned 32-bit femode_t word on this target.
  logical function source_mode()
    integer(c_int) :: mode, code
    code = public_get_mode(mode)
    source_mode = .false.
    if (code /= 0) return
    source_mode = mode == 0
  end function

  !> Check an inclusive native index interval without overflow.
  logical function contains_interval(lower, upper, first, last)
    integer(c_int64_t), intent(in) :: lower, upper, first, last
    contains_interval = first >= lower .and. last >= first .and. last <= upper
  end function

  !> Read the live scalar and map controls before passing any array section.
  !! geometry owns its allocated arrays. Their native allocation bounds replace
  !! the historical private descriptors. No ownership or pointer is transferred.
  logical function grid_inputs(geometry, mysetw, my_region_ew, first, last, map_first, map_last, wave_first)
    type(native_geometry_state), intent(in) :: geometry
    integer(c_int), intent(in) :: mysetw, my_region_ew
    integer(c_int), intent(out) :: first, last, map_first, map_last, wave_first
    integer(c_int64_t) :: lo, hi
    grid_inputs = .false.
    if (geometry%dimensions%ndglg < 1 .or. geometry%dimensions%ndglg > 32) return
    if (geometry%dimensions%ndlon < 1 .or. geometry%dimensions%ndlon > 64) return
    if (geometry%partition%ndgll < 1 .or. geometry%partition%ndgll > geometry%dimensions%ndglg) return
    first = geometry%partition%ndgsal
    last = geometry%partition%ndgenl
    if (first < 1) return
    if (int(last, c_int64_t) - first < 0 .or. int(last, c_int64_t) - first > 31) return
    lo = int(geometry%partition%nptrfloff, c_int64_t) + first
    hi = int(geometry%partition%nptrfloff, c_int64_t) + last
    if (lo < -int(huge(0_c_int), c_int64_t) .or. hi > huge(0_c_int)) return
    map_first = int(lo, c_int)
    map_last = int(hi, c_int)
    if (.not. allocated(geometry%partition%nptrls)) return
    if (.not. contains_interval(int(lbound(geometry%partition%nptrls, 1), c_int64_t), &
                       int(ubound(geometry%partition%nptrls, 1), c_int64_t), int(mysetw, c_int64_t), int(mysetw, c_int64_t))) return
    wave_first = geometry%partition%nptrls(mysetw)
    if (wave_first < 1) return
    hi = int(wave_first, c_int64_t) + geometry%partition%ndgll - 1
    if (hi > huge(0_c_int)) return
    if (.not. allocated(geometry%partition%nonl)) return
    if (.not. contains_interval(int(lbound(geometry%partition%nonl, 1), c_int64_t), &
                                int(ubound(geometry%partition%nonl, 1), c_int64_t), lo, int(map_last, c_int64_t))) return
    if (my_region_ew < lbound(geometry%partition%nonl, 2) .or. &
        my_region_ew > ubound(geometry%partition%nonl, 2)) return
    if (.not. allocated(geometry%configuration%nloeng) .or. .not. allocated(geometry%configuration%nloen)) return
    if (.not. allocated(geometry%cutoffs%nmeng) .or. .not. allocated(geometry%cutoffs%nmen)) return
    if (.not. contains_interval(int(lbound(geometry%configuration%nloeng, 1), c_int64_t), &
                                int(ubound(geometry%configuration%nloeng, 1), c_int64_t), 1_c_int64_t, &
                                max(int(geometry%dimensions%ndglg, c_int64_t), hi))) return
    if (.not. contains_interval(int(lbound(geometry%cutoffs%nmeng, 1), c_int64_t), &
                                int(ubound(geometry%cutoffs%nmeng, 1), c_int64_t), 1_c_int64_t, &
                                max(int(geometry%dimensions%ndglg, c_int64_t), hi))) return
    if (.not. contains_interval(int(lbound(geometry%configuration%nloen, 1), c_int64_t), &
                                int(ubound(geometry%configuration%nloen, 1), c_int64_t), 1_c_int64_t, &
                                int(geometry%partition%ndgll, c_int64_t))) return
    if (.not. contains_interval(int(lbound(geometry%cutoffs%nmen, 1), c_int64_t), &
                                int(ubound(geometry%cutoffs%nmen, 1), c_int64_t), 1_c_int64_t, &
                                int(geometry%partition%ndgll, c_int64_t))) return
    if (.not. is_contiguous(geometry%partition%nonl)) return
    grid_inputs = .true.
  end function

  !> Run the selected local grid constructor with explicit process indices.
  !! The arrays are dimensionless integer maps. Radius is in metres and pi is
  !! dimensionless. Return 0 succeeds, 1 reports allocation failure, and 2
  !! refuses the call before mutation. Source-unwritten cells retain their bits.
  integer(c_int) function initialize_sugem1b_context(geometry, constants, mysetw, my_region_ew) result(status)
    type(native_geometry_state), target, intent(inout) :: geometry
    type(forecast_physical_constants), intent(in) :: constants
    integer(c_int), intent(in) :: mysetw, my_region_ew
    integer(c_int) :: first, last, map_first, map_last, wave_first
    status = 2
    if (.not. source_mode()) return
    if (.not. grid_inputs(geometry, mysetw, my_region_ew, first, last, map_first, map_last, wave_first)) return
    status = initialize_spherical_grid(geometry%grid, geometry%dimensions%ndglg, geometry%dimensions%ndlon, &
                                       geometry%partition%ndgll, wave_first - 1, first, last, &
                                     geometry%partition%nonl(map_first:map_last, my_region_ew), geometry%configuration%nloeng(1:), &
                                       geometry%cutoffs%nmeng(1:), geometry%configuration%nloen(1:geometry%partition%ndgll), &
                                       geometry%cutoffs%nmen(1:geometry%partition%ndgll), geometry%configuration%values%rmucen, &
                                       geometry%configuration%values%rstret, constants%rpi, constants%ra)
  end function

  !> Run the selected complete spherical constructor over its actual owners.
  !! This entry admits the source 32 by 64 grid, 24-column blocks, and degree-21
  !! truncation. Every output owner stays in geometry. Its address must remain
  !! stable while the child's borrowed blocked views remain live.
  integer(c_int) function initialize_sugem2_context(geometry, constants, mysetw, my_region_ew) result(status)
    type(native_geometry_state), target, intent(inout) :: geometry
    type(forecast_physical_constants), intent(in) :: constants
    integer(c_int), intent(in) :: mysetw, my_region_ew
    type(spherical_physical_values) :: physical
    integer(c_int64_t) :: word
    integer(c_int) :: j, row_first, row_last
    status = 2
    if (.not. source_mode()) return
    if (mysetw /= 1 .or. my_region_ew /= 1) return
    if (geometry%dimensions%ndglg /= 32 .or. geometry%partition%ndgll /= 32) return
    if (geometry%dimensions%ndlon /= 64 .or. geometry%dimensions%nproma /= 24) return
    if (geometry%dimensions%nsmax /= 21 .or. geometry%partition%ngptot /= 2048) return
    if (geometry%configuration%values%nsttyp /= 1) return
    if (transfer(geometry%configuration%values%rstret, 0_c_int64_t) /= int(z'3ff0000000000000', c_int64_t)) return
    if (transfer(geometry%grid%constants%rc2p1, 0_c_int64_t) /= int(z'4000000000000000', c_int64_t)) return
    if (transfer(geometry%grid%constants%rc2m1, 0_c_int64_t) /= 0_c_int64_t) return
    if (transfer(constants%ra, 0_c_int64_t) /= int(z'41584de740000000', c_int64_t)) return
    if (transfer(constants%rpi, 0_c_int64_t) /= int(z'400921fb54442d18', c_int64_t)) return
    word = transfer(constants%romega, 0_c_int64_t)
    if (word < int(z'3e10000000000000', c_int64_t) .or. word > int(z'3f70000000000000', c_int64_t)) return
    if (geometry%partition%nptrfloff < 0 .or. geometry%partition%nptrfloff > 1) return
    row_first = geometry%partition%nptrfloff + 1
    row_last = geometry%partition%nptrfloff + 32
    if (.not. allocated(geometry%configuration%nloeng)) return
    if (.not. allocated(geometry%partition%mylats)) return
    if (.not. allocated(geometry%grid%nstagp)) return
    if (.not. allocated(geometry%partition%nsta) .or. .not. allocated(geometry%partition%nonl)) return
    if (lbound(geometry%configuration%nloeng, 1) > 1 .or. ubound(geometry%configuration%nloeng, 1) < 32) return
    if (lbound(geometry%partition%mylats, 1) > 1 .or. ubound(geometry%partition%mylats, 1) < 32) return
    if (lbound(geometry%grid%nstagp, 1) > 1 .or. ubound(geometry%grid%nstagp, 1) < 32) return
    if (lbound(geometry%partition%nsta, 1) > row_first .or. ubound(geometry%partition%nsta, 1) < row_last) return
    if (lbound(geometry%partition%nonl, 1) > row_first .or. ubound(geometry%partition%nonl, 1) < row_last) return
    if (lbound(geometry%partition%nsta, 2) > 1 .or. ubound(geometry%partition%nsta, 2) < 1) return
    if (lbound(geometry%partition%nonl, 2) > 1 .or. ubound(geometry%partition%nonl, 2) < 1) return
    if (.not. is_contiguous(geometry%partition%nsta) .or. .not. is_contiguous(geometry%partition%nonl)) return
    do j = 1, 32
      if (geometry%partition%mylats(j) /= j) return
      if (geometry%configuration%nloeng(j) /= 64) return
      if (geometry%grid%nstagp(j) /= 1 + 64*(j - 1)) return
      if (geometry%partition%nsta(geometry%partition%nptrfloff + j, 1) /= 1) return
      if (geometry%partition%nonl(geometry%partition%nptrfloff + j, 1) /= 64) return
    end do
    if (.not. allocated(geometry%latitudes%rmu) .or. .not. allocated(geometry%latitudes%rsqm2)) return
    if (.not. allocated(geometry%latitudes%rw)) return
    if (lbound(geometry%latitudes%rmu, 1) > 1 .or. ubound(geometry%latitudes%rmu, 1) < 32) return
    if (lbound(geometry%latitudes%rsqm2, 1) > 1 .or. ubound(geometry%latitudes%rsqm2, 1) < 32) return
    if (lbound(geometry%latitudes%rw, 1) /= 1 .or. ubound(geometry%latitudes%rw, 1) /= 32) return
    physical%stretch = geometry%configuration%values%rstret
    physical%rc2p1 = geometry%grid%constants%rc2p1
    physical%rc2m1 = geometry%grid%constants%rc2m1
    physical%radius = constants%ra
    physical%pi = constants%rpi
    physical%angular_rotation = constants%romega
    status = initialize_spherical_geometry(geometry%spherical, physical, geometry%partition%ngptot, geometry%dimensions%nproma, &
                                           geometry%dimensions%ndlon, geometry%dimensions%nsmax, &
                                 geometry%configuration%nloeng(1:32), geometry%partition%mylats(1:32), geometry%grid%nstagp(1:32), &
                 geometry%partition%nsta(row_first:row_last, 1), geometry%partition%nonl(row_first:row_last, 1), geometry%latitudes)
  end function
end module forecast_selected_spherical_context
