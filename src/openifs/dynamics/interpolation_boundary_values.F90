!> Set the two extra interpolation levels to exact positive zero.
!! LAVABO changes work buffers, not the values at physical model levels.
module md2asm_interpolation_boundary_values
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, operator(/=)
  use md2asm_departure_field_transport, only: constituent_transport_map
  implicit none
  private
  public :: interpolation_boundary_controls, interpolation_boundary_map
  public :: initialize_interpolation_boundaries

  !> Named original choices for the selected third-order hydrostatic route.
  !! Curved departure coordinates are enabled; curved right-hand-side wind,
  !! Runge-Kutta trajectories and extra implicit or split families are disabled.
  type :: interpolation_boundary_controls
    logical :: refined_winds = .false., lsldp_curv = .true., lrhs_curv = .false., lsldp_rk = .false.
    logical :: lsplthoigfl = .false., lnhee = .false., lnhdyn = .false., lslinl = .false., lslinlc2 = .false.
    logical :: split_physics = .true.
    integer(int32) :: nsplthoi = 0, nwlag = 3, ntlag = 3, nvlag = 3
  end type

  !> One-based plane bases in the complete interpolation buffer.
  !! Each field occupies levels0:L+1. trajectory is UR0,VR0,ZR0,WR0;
  !! transported is U9,V9,T9; current is U0,V0,T0; physics is UP9,VP9,TP9.
  !! Constituents use their MP_SL1 or MPSLP slot and the same L+2 plane stride.
  type :: interpolation_boundary_map
    integer(int64) :: trajectory(4) = 0, transported(3) = 0, current(3) = 0, physics(3) = 0
    integer(int64) :: continuity = 0, constituents = 0, physics_constituents = 0
  end type
contains
  !> Initialize only the source-selected top and bottom work values.
  !! buffer(pitch,planes) is a writable contiguous borrowed FP64 owner.
  !! It retains each field's physical unit. first:last is the active column
  !! interval, including both ends. Only level0 and levelL+1 become positive
  !! zero. All physical levels, unselected fields and inactive columns remain
  !! unchanged. Components retain original order and12-character selectors.
  !! Their names are not consumed here. Read-only metadata must remain
  !! separate from the writable buffer and alive until return.
  !! Status0 succeeds;1 refuses private selection storage;2 refuses metadata
  !! before any output write. The compiler owns all descriptors and code.
  subroutine initialize_interpolation_boundaries(pitch, levels, first, last, c, maps, components, buffer, status)
    integer(int32), intent(in) :: pitch, levels, first, last
    type(interpolation_boundary_controls), intent(in) :: c
    type(interpolation_boundary_map), intent(in) :: maps
    type(constituent_transport_map), intent(in) :: components(:)
    real(real64), contiguous, intent(inout) :: buffer(:, :)
    integer(int32), intent(out) :: status
    integer(int64), allocatable :: bases(:)
    integer(int64) :: planes, span, base, offset
    integer :: field, variable, count, allocation_status, i, entry

    status = 2_int32
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch .or. last < first - 1 .or. last > pitch) return
    if (size(buffer, 1) /= pitch .or. size(components) > 2163) return
    if (c%refined_winds .or. .not. c%lsldp_curv .or. c%lrhs_curv .or. c%lsldp_rk) return
    if (c%nsplthoi /= 0 .or. c%lsplthoigfl .or. c%lnhee .or. c%lnhdyn .or. c%lslinl .or. c%lslinlc2) return
    if (c%nwlag /= 3 .or. c%ntlag /= 3 .or. c%nvlag /= 3 .or. .not. c%split_physics) return
    if (.not. environment_supported()) return
    span = int(levels, int64) + 2_int64
    planes = size(buffer, 2, kind=int64)
    if (planes < span) return
    allocate (bases(14 + 2*size(components)), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32
      return
    end if
    count = 0
    ! Validate and retain the complete ordered selection before any store.
    do variable = 1, 4
      if (.not. append(maps%trajectory(variable))) return
    end do
    do variable = 1, 3
      if (.not. append(maps%transported(variable))) return
    end do
    do field = 1, size(components)
      if (.not. components(field)%advected) cycle
      if (components(field)%selector == 'LAITVSPCQM  ') cycle
      if (components(field)%source_slot < 1 .or. components(field)%source_slot > 2164) return
      offset = int(components(field)%source_slot - 1, int64)*span
      if (maps%constituents < 1 .or. maps%constituents > planes) return
      if (offset > planes - maps%constituents) return
      if (.not. append(maps%constituents + offset)) return
    end do
    do variable = 1, 3
      if (.not. append(maps%current(variable))) return
    end do
    if (.not. append(maps%continuity)) return
    do variable = 1, 3
      if (.not. append(maps%physics(variable))) return
    end do
    do field = 1, size(components)
      if (.not. components(field)%physics) cycle
      if (components(field)%physics_slot < 1 .or. components(field)%physics_slot > 2164) return
      offset = int(components(field)%physics_slot - 1, int64)*span
      if (maps%physics_constituents < 1 .or. maps%physics_constituents > planes) return
      if (offset > planes - maps%physics_constituents) return
      if (.not. append(maps%physics_constituents + offset)) return
    end do
    do entry = 1, count
      base = bases(entry)
      do i = first, last
        buffer(i, base) = 0.0_real64
        buffer(i, base + int(levels, int64) + 1_int64) = 0.0_real64
      end do
    end do
    status = 0_int32
  contains
    logical function append(value) result(valid)
      integer(int64), intent(in) :: value
      valid = .false.
      if (value < 1 .or. value > planes - int(levels, int64) - 1_int64) return
      if (count >= size(bases)) return
      count = count + 1
      bases(count) = value
      valid = .true.
    end function
  end subroutine

  logical function environment_supported() result(supported)
    type(ieee_round_type) :: mode
    real(real64), volatile :: normal_value, half, subnormal
    supported = .false.
    call ieee_get_rounding_mode(mode)
    if (mode /= ieee_nearest) return
    normal_value = tiny(1.0_real64)
    half = 0.5_real64
    subnormal = normal_value*half
    if (subnormal /= transfer(int(z'0008000000000000', int64), 1.0_real64)) return
    supported = .true.
  end function
end module md2asm_interpolation_boundary_values
