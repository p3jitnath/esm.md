!> Add source physical tendencies to the semi-Lagrangian state buffers.
!! A tendency is the change per second in the corresponding physical field.
module forecast_physics_tendency_increment
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: saved_physics_tendency_indices, physical_tracer_increment_map, add_physics_tendencies
!> The three source NVTEND indices select U,V and temperature rates.
  type saved_physics_tendency_indices
    integer(int32) :: u = 0, v = 0, t = 0
  end type
!> Preserve source component order, including repeated active MPSLP values.
  type physical_tracer_increment_map
    logical :: lphy = .false.
    integer(int32) :: mpslp = 0
  end type
contains
!> Add dt times each physical rate, with separate FP64 multiply and add.
!! PITCH,FIRST,LAST,LEVELS and LOWER_LEVEL are dimensionless live counts.
!! DT is seconds. Wind is m/s, temperature K and mass fractions kg/kg.
!! SAVED has shape(P,L,NVTEND); TRACER_RATES has shape(P,L,NDIMSLP).
!! U,V,T have shape(P,LOWER_LEVEL:upper), TRACERS adds NDIMSLP.
!! Only FIRST:LAST and levels1:LEVELS change. Inactive cells, boundaries
!! and unselected tracers retain their bits. All output owners are disjoint
!! from each other, controls and input rates. Callers establish nearest-even
!! rounding, gradual underflow and finite admitted active arithmetic.
!! FIRST_STEP returns0 before accessing any optional numerical array.
!! An empty active interval or zero levels also changes no field.
!! Status2 refuses metadata before any public output mutation.
  integer(int32) function add_physics_tendencies(first_step, pitch, first, last, levels, lower_level, dt, &
                                                 indices, components, saved, tracer_rates, u, v, t, tracers) result(status)
    logical, intent(in) :: first_step
    integer(int32), intent(in) :: pitch, first, last, levels, lower_level
    real(real64), intent(in) :: dt
    type(saved_physics_tendency_indices), intent(in) :: indices
    type(physical_tracer_increment_map), intent(in) :: components(:)
    real(real64), intent(in), optional :: saved(:, :, :), tracer_rates(:, :, :)
    real(real64), intent(inout), optional :: u(:, lower_level:), v(:, lower_level:), t(:, lower_level:)
    real(real64), intent(inout), optional :: tracers(:, lower_level:, :)
    integer(int64) :: time_bits
    integer :: column, level, component, field, upper
    real(real64), volatile :: increment_u, increment_v, increment_t, increment
    status = 0
    if (first_step) return
    status = 2
    if (pitch < 1 .or. levels < 0) return
    if (levels == 0) then
      status = 0; return
    end if
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (last < first) then
      status = 0; return
    end if
    if (lower_level > 1 .or. size(components) > 2163) return
    time_bits = transfer(dt, time_bits)
    if (iand(time_bits, int(z'7ff0000000000000', int64)) == int(z'7ff0000000000000', int64)) return
    if (btest(time_bits, 63) .and. iand(time_bits, int(z'7fffffffffffffff', int64)) /= 0_int64) return
    if (.not. present(saved) .or. .not. present(u) .or. .not. present(v) .or. .not. present(t)) return
    if (size(saved, 1) /= pitch .or. size(saved, 2) /= levels) return
    if (min(indices%u, indices%v, indices%t) < 1) return
    if (max(indices%u, indices%v, indices%t) > size(saved, 3)) return
    if (size(u, 1) /= pitch .or. size(v, 1) /= pitch .or. size(t, 1) /= pitch) return
    upper = ubound(u, 2)
    if (upper < levels .or. ubound(v, 2) /= upper .or. ubound(t, 2) /= upper) return
    if (any(components%lphy)) then
      if (.not. present(tracer_rates) .or. .not. present(tracers)) return
      if (size(tracer_rates, 1) /= pitch .or. size(tracer_rates, 2) /= levels) return
      if (size(tracers, 1) /= pitch .or. ubound(tracers, 2) /= upper) return
      if (size(tracer_rates, 3) /= size(tracers, 3)) return
      do component = 1, size(components)
        if (.not. components(component)%lphy) cycle
        field = components(component)%mpslp
        if (field < 1 .or. field > size(tracer_rates, 3)) return
      end do
    end if
    do level = 1, levels
      do column = first, last
        increment_u = saved(column, level, indices%u)*dt
        increment_v = saved(column, level, indices%v)*dt
        increment_t = saved(column, level, indices%t)*dt
        u(column, level) = u(column, level) + increment_u
        v(column, level) = v(column, level) + increment_v
        t(column, level) = t(column, level) + increment_t
      end do
    end do
    do component = 1, size(components)
      if (.not. components(component)%lphy) cycle
      field = components(component)%mpslp
      do level = 1, levels
        do column = first, last
          increment = tracer_rates(column, level, field)*dt
          tracers(column, level, field) = tracers(column, level, field) + increment
        end do
      end do
    end do
    status = 0
  end function
end module forecast_physics_tendency_increment
