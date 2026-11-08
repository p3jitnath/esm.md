!> Selected spherical Cartesian LARCINA departure fields.
!! Coordinates already contain longitude and latitude. This parent selects
!! complete owned weight and interpolation children, without a model wrapper.
module md2asm_departure_coordinate_fields
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_departure_interpolation_weights, only: departure_weight_controls, departure_weight_geometry, &
                                          departure_weight_inputs, departure_weight_outputs, prepare_departure_interpolation_weights
  use md2asm_departure_neighbour_interpolation, only: interpolate_eight_neighbours
  use md2asm_three_dimensional_cubic_departure_interpolation, only: interpolate_thirty_two_neighbours
  use md2asm_weno_departure_interpolation, only: weno_interpolation_controls, interpolate_weno_departure
  implicit none
  private
  public :: departure_field_controls, trajectory_field_component, prepare_departure_coordinate_fields
  !> Only the frozen spherical Cartesian route is supported.
  !! Stage1 finds a trajectory midpoint,2 finds its origin, and3 retains the
  !! adjoint weight selector. Extra vertical smoothing and separation searches
  !! remain unsupported. pi is radians; stretch has no unit.
  type :: departure_field_controls
    integer(int32) :: stage = 1, hermite_width = 0, limiter = 0
    integer(int32) :: first_input_level = 0, last_input_level = 0
    logical :: spherical = .true., cartesian = .true., curvature = .true., plane = .false.
    logical :: interpolate_fields = .false., find_vertical_separation = .false., vertical_smoothing = .false.
    logical :: spline_origin = .false., rhs_weno = .false.
    real(real64) :: pi = 0.0_real64, stretch = 0.0_real64
  end type
  !> Each borrowed field uses(source_pitch,input_level), and its result uses
  !! (pitch,level). The first stored input level is first_input_level.
  !! All four results are disjoint from each other, the weights and inputs.
  !! Interpolation preserves the unit of each input field.
  type :: trajectory_field_component
    real(real64), pointer, contiguous :: field(:, :) => null(), result(:, :) => null()
  end type
contains
  !> Prepare selected coordinates, weight owners and four trajectory fields.
  !! The weights use the shapes in departure_weight_outputs. Geometry and
  !! input coordinates are read only. Only selected rows of active outputs
  !! change. Unused coordinate, rotation, separation and smoothing owners are
  !! not passed and cannot be changed by this entry.
  !! Status0 succeeds,1 refuses allocation and2 refuses a declared branch or
  !! owner. A later numerical child refusal leaves partial outputs unaccepted.
  subroutine prepare_departure_coordinate_fields(pitch, levels, first, last, c, weight_control, &
                                                 geometry, positions, weights, components, weno_control, status)
    integer(int32), intent(in) :: pitch, levels, first, last
    type(departure_field_controls), intent(in) :: c
    type(departure_weight_controls), intent(in) :: weight_control
    type(departure_weight_geometry), intent(in) :: geometry
    type(departure_weight_inputs), intent(in) :: positions
    type(departure_weight_outputs), intent(inout) :: weights
    type(trajectory_field_component), intent(inout) :: components(4)
    type(weno_interpolation_controls), intent(in) :: weno_control
    integer(int32), intent(out) :: status
    type(departure_weight_controls) :: selected
    type(departure_weight_geometry) :: local_geometry
    real(real64), allocatable :: vertical_windows(:, :, :, :)
    real(real64), pointer, contiguous :: flat_field(:)
    real(real64), volatile :: twice_stretch, twice_pi, half_pi
    integer(int64) :: planes, total
    integer :: component, i, k, window, coefficient, allocation_status
    logical :: interpolate, weno_fields, high_order_fields
    status = 2
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (c%stage < 1 .or. c%stage > 3 .or. c%hermite_width < 0 .or. c%hermite_width > 1) return
    if (c%limiter < 0 .or. c%limiter > 3) return
    if (c%plane .or. .not. c%spherical .or. .not. c%cartesian .or. .not. c%curvature) return
    if (c%find_vertical_separation .or. c%vertical_smoothing) return
    if (weight_control%slots /= 1 .or. weight_control%static_physics_weights) return
    if (weight_control%diffusion .or. weight_control%quadratic .or. weight_control%turbulence) return
    if (weight_control%coordinate_correction .or. weight_control%horizontal_correction .or. &
        weight_control%vertical_correction) return
    interpolate = c%interpolate_fields
    if (interpolate .and. c%stage /= 1) return
    weno_fields = interpolate .and. weight_control%trajectory_weno
    high_order_fields = interpolate .and. weight_control%high_order_trajectories
    if (weno_fields .and. .not. weight_control%high_order_trajectories) return
    selected = weight_control
    selected%vertical_windows = 1
    selected%hermite_width = c%hermite_width
    select case (c%stage)
    case (1)
      selected%kind = 101
      if (weight_control%high_order_trajectories) then
        selected%kind = 102
        if (weight_control%trajectory_weno) selected%vertical_windows = 3
      end if
      selected%horizontal_mode = 1
    case (2)
      if (c%spline_origin) then
        selected%kind = 105
      else if (c%rhs_weno) then
        selected%kind = 106
        selected%vertical_windows = 3
      else
        selected%kind = 103 + c%hermite_width
      end if
      selected%horizontal_mode = 1
    case (3)
      selected%kind = 103
      if (c%rhs_weno) then
        selected%kind = 106
        selected%vertical_windows = 3
      end if
      selected%horizontal_mode = 0
    end select
    planes = int(c%last_input_level, int64) - int(c%first_input_level, int64) + 1_int64
    if (planes < 1 .or. planes > huge(0_int32)) return
    if (geometry%buffer_stride < 1) return
    total = int(geometry%buffer_stride, int64)*planes
    if (total > huge(0_int32)) return
    if (interpolate .and. first <= last) then
      do component = 1, 4
        if (.not. associated(components(component)%field) .or. .not. associated(components(component)%result)) return
        if (size(components(component)%field, 1) /= geometry%buffer_stride) return
        if (int(size(components(component)%field, 2), int64) /= planes) return
        if (size(components(component)%result, 1) /= pitch .or. size(components(component)%result, 2) < levels) return
      end do
      if (weno_fields) then
        allocate (vertical_windows(pitch, levels, 3, 3), stat=allocation_status)
        if (allocation_status /= 0) then
          status = 1
          return
        end if
      end if
    end if
    twice_stretch = 2.0_real64*c%stretch
    twice_pi = 2.0_real64*c%pi
    half_pi = 0.5_real64*c%pi
    local_geometry = geometry
    local_geometry%latitude_pole = half_pi
    local_geometry%field_level = c%first_input_level
    call prepare_departure_interpolation_weights(pitch, levels, first, last, selected, &
                                                 local_geometry, positions, weights, status)
    if (status /= 0) return
    if (.not. interpolate .or. first > last) return
    if (weno_fields) then
      do window = 1, 3
        do coefficient = 1, 3
          do k = 1, levels
            do i = first, last
              vertical_windows(i, k, coefficient, window) = weights%vertical_main(i, k, 3*(window - 1) + coefficient)
            end do
          end do
        end do
      end do
    end if
    do component = 1, 4
      flat_field(1:size(components(component)%field)) => components(component)%field
      if (weno_fields) then
        call interpolate_weno_departure(weno_control, geometry%buffer_stride, pitch, first, last, levels, &
                                        c%first_input_level, c%last_input_level, c%limiter, weights%latitude_fraction, &
                             weights%latitude_main(:, :, :, 1), weights%longitude_fraction, weights%longitude_main(:, :, :, :, 1), &
                                        weights%parent_index, weights%weno_shift, weights%weno_combination, vertical_windows, &
                                        flat_field, components(component)%result, status)
      else if (high_order_fields) then
        call interpolate_thirty_two_neighbours(geometry%buffer_stride, pitch, first, last, levels, &
                                               c%first_input_level, c%last_input_level, c%limiter, weights%latitude_fraction, &
                             weights%latitude_main(:, :, :, 1), weights%longitude_fraction, weights%longitude_main(:, :, :, :, 1), &
                           weights%parent_index, weights%vertical_main(:, :, 1:3), flat_field, components(component)%result, status)
      else
        call interpolate_eight_neighbours(geometry%buffer_stride, pitch, first, last, levels, &
                        c%first_input_level, c%last_input_level, weights%latitude_fraction, weights%longitude_fraction(:, :, 2:3), &
                       weights%parent_index(:, :, 2:3), weights%vertical_fraction, flat_field, components(component)%result, status)
      end if
      if (status /= 0) return
    end do
    status = 0
  end subroutine
end module
