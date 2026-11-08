!> Complete selected full-level LAPINEA trajectory and interpolation caller.
!! All latitude preparation, trajectory state and final weights are owned here.
!! Mathematical-library equivalence and complete parent acceptance are pending.
module md2asm_trajectory_interpolation_parent
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_int, c_ptr, c_f_pointer, c_associated
  use md2asm_cartesian_departure_points, only: cartesian_departure_controls, cartesian_arrival_geometry, &
                                               cartesian_arrival_wind, cartesian_departure_state, find_cartesian_departure_points
  use md2asm_departure_coordinate_fields, only: departure_field_controls, trajectory_field_component, &
                                                prepare_departure_coordinate_fields
  use md2asm_departure_interpolation_weights, only: departure_weight_controls, departure_weight_geometry, &
                                                    departure_weight_inputs, departure_weight_outputs
  use md2asm_weno_departure_interpolation, only: weno_interpolation_controls
  implicit none
  private
  public :: trajectory_latitude_partition, trajectory_interpolation_controls, trajectory_diagnostic_field
  public :: prepare_trajectory_interpolation

  !> Live latitude partition and the two original integer table owners.
  !! Latitude numbers and all first/last values are integer indices.
  !! point_count starts at count_first and stores NLOENG, the longitude count.
  !! buffer_offset starts at buffer_first and stores NSLOFF, a field-word
  !! address. No numerical input is calculated by a comparison driver.
  type :: trajectory_latitude_partition
    integer(int32) :: halo_first = 1, halo_last = 0
    integer(int32) :: global_first = 1, global_last = 0, local_first = 1, local_last = 0
    integer(int32) :: first_offset = 0, halo_width = 0, count_first = 1, buffer_first = 1
    integer(int32), pointer, contiguous :: point_count(:) => null(), buffer_offset(:) => null()
  end type

  !> Selected source branch and diagnostic-range controls.
  !! diagnostic_first:last indexes the complete supplied diagnostic records.
  !! final_predictor_iteration is source NSITER, with no unit.
  type :: trajectory_interpolation_controls
    logical :: plane = .false., runge_kutta = .false., nonhydrostatic = .false.
    integer(int32) :: final_predictor_iteration = 0, diagnostic_first = 1, diagnostic_last = 0
  end type

  !> Original full16-character field name and its one-based PGFLT1 slot.
  !! Only the six recognised trajectory diagnostics are changed.
  type :: trajectory_diagnostic_field
    character(len=16) :: name = ' '
    integer(int32) :: destination = 0
  end type

  interface
    function diagnostic_sin(x) bind(C, name='sin') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function runtime_errno_location() bind(C, name='__errno_location') result(p)
      import c_ptr
      type(c_ptr) :: p
    end function
  end interface
contains
  !> Prepare trajectories, requested diagnostics and complete full-level weights.
  !! pitch is1:1024; levels is4:256. first:last may be empty.
  !! Field planes, arrival geometry, winds and eta have the native units and
  !! bounds in find_cartesian_departure_points. The exact RTDT value is explicit.
  !! transport_selectors retains every original CSLINT character, padded to12.
  !! final_inputs borrows the four selected kappa fields; absent fields stay
  !! null. The parent replaces only longitude,latitude and vertical position.
  !! final_weights points to complete caller-owned full-level weight and index
  !! views. Its vertical_index pointer is unused: the parent owns KLEV.
  !! state owns the public saved points, coordinate planes and U/V fields.
  !! Its eta,w,vertical_index pointers are unused and are replaced privately.
  !! geometry%longitude_scale is also unused on entry:the parent owns and
  !! prepares ZLSDEPI from actual NLOENG,then binds the exact latitude slice.
  !! final_weights parent/horizontal indices are the shared KL0/KLH0 owners.
  !! Diagnostic values use(pitch,levels,field), preserving inactive bytes.
  !! Hydrostatic half-level owners and PSCO are unused and are not passed.
  !! All active writable views are disjoint from consumed inputs, apart from
  !! the explicit shared index and coordinate views described above.
  !! Status0 succeeds;1 refuses allocation;2 refuses a branch, shape or child.
  !! A late child refusal leaves partial state unaccepted. The original
  !! incoming errno is restored on a successful complete return using the
  !! public Linux runtime service; another runtime needs its corresponding
  !! small service binding. The compiler owns every native type and call ABI.
  subroutine prepare_trajectory_interpolation(pitch, levels, first, last, c, latitude, trajectory_control, &
                             field_control, trajectory_weights, final_weight_control, geometry, arrival, wind, full_eta, half_eta, &
                              previous_eta_rate, source_fields, transport_selectors, diagnostics, diagnostic_values, final_inputs, &
                                              final_weights, state, status)
    integer(int32), intent(in) :: pitch, levels, first, last
    type(trajectory_interpolation_controls), intent(in) :: c
    type(trajectory_latitude_partition), intent(in) :: latitude
    type(cartesian_departure_controls), intent(in) :: trajectory_control
    type(departure_field_controls), intent(in) :: field_control
    type(departure_weight_controls), intent(in) :: trajectory_weights, final_weight_control
    type(departure_weight_geometry), intent(in) :: geometry
    type(cartesian_arrival_geometry), intent(in) :: arrival
    type(cartesian_arrival_wind), intent(in) :: wind
    real(real64), intent(in) :: full_eta(0:), half_eta(0:), previous_eta_rate(:, :)
    type(trajectory_field_component), intent(in) :: source_fields(4)
    character(len=12), intent(in) :: transport_selectors(:)
    type(trajectory_diagnostic_field), intent(in) :: diagnostics(:)
    real(real64), intent(inout) :: diagnostic_values(:, :, :)
    type(departure_weight_inputs), intent(in) :: final_inputs
    type(departure_weight_outputs), intent(inout) :: final_weights
    type(cartesian_departure_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    type(cartesian_departure_state) :: private_state
    type(departure_weight_geometry) :: local_geometry
    type(departure_field_controls) :: origin_control, midpoint_control
    type(departure_weight_inputs) :: origin_inputs
    type(departure_weight_outputs) :: origin_weights
    type(trajectory_field_component) :: unused_fields(4)
    type(weno_interpolation_controls) :: unused_weno
    real(real64), allocatable, target, volatile :: latitude_scale(:)
    real(real64), allocatable, target :: departure_eta(:, :), diagnostic_wind(:, :)
    integer(int32), allocatable, target :: level_index(:, :), departure_buffer(:)
    integer(c_int), pointer :: errno_pointer
    type(c_ptr) :: errno_address
    integer(c_int) :: saved_errno
    real(real64), volatile :: twice_pi
    real(real64) :: value
    integer(int64) :: halo_size, first_scale, last_scale, global_row, row, source_index, logical_row, total_bytes, scale_last
    integer :: i, k, record, kind, field_slot, table_count, allocation_status, hermite_width
    logical :: write_diagnostics
    status = 2
    if (real64 /= c_double) return
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (c%plane .or. c%runge_kutta .or. c%nonhydrostatic) return
    if (size(transport_selectors) > 1024) return
    if (c%final_predictor_iteration < 0) return
    if (.not. associated(latitude%point_count) .or. .not. associated(latitude%buffer_offset)) return
    halo_size = int(latitude%halo_last, int64) - int(latitude%halo_first, int64) + 1_int64
    if (halo_size < 1 .or. halo_size > 4096 .or. latitude%halo_width < 0) return
    if (.not. associated(geometry%latitude)) return
    table_count = size(geometry%latitude)
    if (table_count < 4 .or. table_count > 4096) return
    scale_last = int(geometry%first_latitude, int64) + int(table_count, int64) - 1_int64
    if (int(geometry%first_latitude, int64) < int(latitude%halo_first, int64)) return
    if (scale_last > int(latitude%halo_last, int64)) return
    first_scale = max(int(latitude%global_first, int64), &
                      int(latitude%local_first, int64) + int(latitude%first_offset, int64) - int(latitude%halo_width, int64))
    first_scale = first_scale - int(latitude%first_offset, int64)
    last_scale = min(int(latitude%global_last, int64), &
                     int(latitude%local_last, int64) + int(latitude%first_offset, int64) + int(latitude%halo_width, int64))
    last_scale = last_scale - int(latitude%first_offset, int64)
    if (first_scale < int(latitude%halo_first, int64) .or. last_scale > int(latitude%halo_last, int64)) return
    do row = first_scale, last_scale
      global_row = row + int(latitude%first_offset, int64)
      source_index = global_row - int(latitude%count_first, int64) + 1_int64
      if (source_index < 1 .or. source_index > size(latitude%point_count, kind=int64)) return
      if (latitude%point_count(source_index) < 1) return
    end do
    if (.not. real2_has(state%longitude) .or. .not. real2_has(state%latitude)) return
    if (.not. real2_has(state%u) .or. .not. real2_has(state%v)) return
    if (.not. integer3_has(final_weights%parent_index) .or. .not. integer3_has(final_weights%horizontal_index)) return
    write_diagnostics = trajectory_control%diagnostic_wind .and. &
                     (trajectory_control%cheap_predictor .or. trajectory_control%predictor_iteration == c%final_predictor_iteration)
    if (write_diagnostics) then
      if (c%diagnostic_first < 1 .or. c%diagnostic_last > size(diagnostics)) return
      if (c%diagnostic_last > 1024) return
      if (c%diagnostic_last >= c%diagnostic_first) then
        if (size(diagnostic_values, 1) /= pitch .or. size(diagnostic_values, 2) < levels) return
        do record = c%diagnostic_first, c%diagnostic_last
          kind = diagnostic_kind(diagnostics(record)%name)
          if (kind == 0) cycle
          if (diagnostics(record)%destination < 1 .or. diagnostics(record)%destination > size(diagnostic_values, 3)) return
        end do
      end if
    end if
    total_bytes = 16_int64*halo_size + 8_int64*int(pitch, int64)*int(levels, int64)*2_int64 + &
                  4_int64*int(pitch, int64)*int(levels, int64) + 4_int64*int(table_count, int64)
    if (total_bytes > 536870912_int64) return
    errno_address = runtime_errno_location()
    if (.not. c_associated(errno_address)) return
    call c_f_pointer(errno_address, errno_pointer)
    saved_errno = errno_pointer
    allocate (latitude_scale(latitude%halo_first:latitude%halo_last), &
              departure_eta(pitch, levels), diagnostic_wind(pitch, levels), level_index(pitch, levels), &
              departure_buffer(table_count), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    latitude_scale = 0.0_real64
    departure_eta = 0.0_real64
    diagnostic_wind = 0.0_real64
    level_index = 0
    departure_buffer = 0
    twice_pi = 2.0_real64*trajectory_control%pi
    do row = first_scale, last_scale
      global_row = row + int(latitude%first_offset, int64)
      source_index = global_row - int(latitude%count_first, int64) + 1_int64
      value = real(latitude%point_count(source_index), real64)
      latitude_scale(row) = value/twice_pi
    end do
    ! Embed the exact source NSLOFF intersection into the native table view.
    ! Values outside NDGSAH:NDGENH stay unused. Selected interpolation rows
    ! must lie within that initialized local halo, as in the original caller.
    do row = 1, table_count
      logical_row = int(geometry%first_latitude, int64) + row - 1_int64
      if (logical_row < int(latitude%halo_first, int64) .or. logical_row > int(latitude%halo_last, int64)) cycle
      source_index = logical_row - int(latitude%buffer_first, int64) + 1_int64
      if (source_index < 1 .or. source_index > size(latitude%buffer_offset, kind=int64)) cycle
      departure_buffer(row) = latitude%buffer_offset(source_index)
    end do
    hermite_width = 0
    do record = 1, size(transport_selectors)
      select case (transport_selectors(record))
      case ('LAIHVT      ', 'LAIHVTQM    ', 'LAIHVTQMH   ')
        hermite_width = 1
      end select
    end do
    local_geometry = geometry
    local_geometry%first_buffer => departure_buffer
    ! The child indexes all latitude tables from geometry%first_latitude.
    ! Publish this parent-owned ZLSDEPI slice,with native index1 at that row.
    local_geometry%longitude_scale => latitude_scale(geometry%first_latitude:int(scale_last))
    private_state = state
    private_state%eta => departure_eta
    private_state%w => diagnostic_wind
    private_state%vertical_index => level_index
    private_state%parent_index => final_weights%parent_index
    private_state%horizontal_index => final_weights%horizontal_index
    midpoint_control = field_control
    midpoint_control%hermite_width = 0
    midpoint_control%limiter = 0
    call find_cartesian_departure_points(pitch, levels, first, last, trajectory_control, midpoint_control, &
     trajectory_weights, local_geometry, arrival, wind, full_eta, half_eta, previous_eta_rate, source_fields, private_state, status)
    if (status /= 0) return

    if (write_diagnostics) then
      do record = c%diagnostic_first, c%diagnostic_last
        kind = diagnostic_kind(diagnostics(record)%name)
        if (kind == 0) cycle
        field_slot = diagnostics(record)%destination
        do k = 1, levels
          do i = first, last
            select case (kind)
            case (1)
              value = state%u(i, k)
            case (2)
              value = state%v(i, k)
            case (3)
              value = diagnostic_wind(i, k)
            case (4)
              value = diagnostic_sin(state%longitude(i, k))
            case (5)
              value = diagnostic_sin(state%latitude(i, k))
            case (6)
              value = departure_eta(i, k)
            end select
            diagnostic_values(i, k, field_slot) = value
          end do
        end do
      end do
    end if
    origin_control = field_control
    origin_control%stage = 2
    origin_control%hermite_width = hermite_width
    origin_control%interpolate_fields = .false.
    origin_control%plane = .false.
    origin_control%spherical = .true.
    origin_control%cartesian = .true.
    origin_control%curvature = .true.
    origin_control%pi = trajectory_control%pi
    origin_inputs = final_inputs
    origin_inputs%longitude => state%longitude
    origin_inputs%latitude => state%latitude
    origin_inputs%position => departure_eta
    origin_weights = final_weights
    origin_weights%vertical_index => level_index
    unused_fields = source_fields
    call prepare_departure_coordinate_fields(pitch, levels, first, last, origin_control, final_weight_control, &
                                             local_geometry, origin_inputs, origin_weights, unused_fields, unused_weno, status)
    if (status /= 0) return
    deallocate (latitude_scale, departure_eta, diagnostic_wind, level_index, departure_buffer)
    errno_pointer = saved_errno
    status = 0
  contains
    logical function real2_has(p)
      real(real64), pointer, intent(in) :: p(:, :)
      real2_has = .false.
      if (.not. associated(p)) return
      real2_has = size(p, 1) == pitch .and. size(p, 2) >= levels
    end function
    logical function integer3_has(p)
      integer(int32), pointer, intent(in) :: p(:, :, :)
      integer3_has = .false.
      if (.not. associated(p)) return
      integer3_has = size(p, 1) == pitch .and. size(p, 2) >= levels .and. size(p, 3) >= 4
    end function
  end subroutine
  pure integer function diagnostic_kind(name) result(kind)
    character(len=16), intent(in) :: name
    kind = 0
    select case (name)
    case ('UTRAJ           ')
      kind = 1
    case ('VTRAJ           ')
      kind = 2
    case ('WTRAJ           ')
      kind = 3
    case ('LAMBDA0         ')
      kind = 4
    case ('THETA0          ')
      kind = 5
    case ('ETA0            ')
      kind = 6
    end select
  end function
end module
