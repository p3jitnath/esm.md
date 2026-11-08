!> Finish the hydrostatic lagged grid update through own Fortran children.
module forecast_lagged_grid_update
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_is_finite, ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(==)
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use md2asm_two_part_time_filter, only: time_filter_controls, time_filter_maps, filter_field_pair, apply_time_filter_first
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent, compute_moist_air_properties
  implicit none
  private
  public :: lagged_grid_controls, lagged_grid_field_map, finish_lagged_grid_update, grid_update_environment_supported
  !> Values are copied from initialized dynamics,clock,diagnostic and trajectory controls.
  type :: lagged_grid_controls
    logical :: nonhydrostatic = .false., nonhydrostatic_euler = .false., nonhydrostatic_quasi = .false.
    logical :: semi_lagrangian = .false., diagnostic_accumulation = .false., configuration_x = .false.
    logical :: moist_temperature = .false., stress_enabled = .false., full_corrector = .false.
    logical :: trajectory_present = .false., trajectory_save = .false., trajectory_lag = .false.
    logical :: oops_save = .false., oops_lag = .false.
    integer(int32) :: current_iteration = 0, last_iteration = 0, step = 0, last_step = 0
    real(real64) :: stretch = 0.0_real64
    type(time_filter_controls) :: filter
    type(time_filter_maps) :: filter_maps
    real(real64) :: filter_weights(4) = 0.0_real64
  end type
  !> Source integer indices;three buffer starts each span all physical levels.
  !! Future air indices are the original YT1 MU,MV,MT,and surface is YT1 MSP.
  !! Buffer starts are MSLB2USI,VSI,TSI,and surface is MSLB2SPSI.
  type :: lagged_grid_field_map
    integer(int32) :: future_air(3) = 0, future_surface = 0, buffer_first(3) = 0, buffer_surface = 0
  end type
  interface
    function errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Apply stresses,first time filter,transport increments,mixture and map scaling.
  !!
  !! pitch1:512 and levels0:512 come from the actual owner. last=min(pitch,
  !! global_count-global_first+1),with first1;last0 denotes an empty interval.
  !! air(P,L,A),surface(P,1,S),tracers(P,L,C) are current/old mutable fields.
  !! next_air(P,L,A1),next_surface(P,S1) are independent next-time owners.
  !! increments(P,B2) and next_tracers(P,L,C1) are readonly;every source index
  !! is explicit. Tracer pairs and filter maps retain initialized source order.
  !! Constituents carry actual MP1 maps through layout_code1.
  !!
  !! Wind units are m/s,temperature K,surface state is logarithmic pressure.
  !! Increment units match each destination;metric and stretch are unitless.
  !! Stress(P,L,2 or more) has wind-increment units and is consumed conditionally.
  !! Only active next-time cells change outside the filter source-defined clear.
  !! No stage is delegated to a comparison driver or original OpenIFS routine.
  !! Status0 succeeds,1 reports allocation/child allocation failure and2 refuses
  !! unsupported metadata. A late child failure is not an accepted full update.
  subroutine finish_lagged_grid_update(c, map, pitch, levels, global_count, global_first, &
                                       tracer_pairs, constants, components, air, surface, tracers, increments, next_tracers, &
                                       next_air, next_surface, metric, status, stress)
    type(lagged_grid_controls), intent(in) :: c
    type(lagged_grid_field_map), intent(in) :: map
    integer(int32), intent(in) :: pitch, levels, global_count, global_first
    type(filter_field_pair), intent(in) :: tracer_pairs(:)
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: components(:)
    real(real64), intent(inout) :: air(:, :, :), surface(:, :, :), tracers(:, :, :)
    real(real64), intent(in) :: increments(:, :), next_tracers(:, :, :), metric(:)
    real(real64), intent(inout) :: next_air(:, :, :), next_surface(:, :)
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: stress(:, :, :)
    real(real64), allocatable :: gas(:, :)
    integer(c_int), pointer, volatile :: errno_pointer
    integer(c_int) :: saved_errno
    integer :: last, j, k, i, field, code
    logical :: stretched, need_stress, enabled, last_step
    logical :: no_water(6)
    real(real64), volatile :: stretch_difference, reciprocal_rd
    real(real64) :: value, threshold
    status = 2
    if (c%nonhydrostatic .or. c%nonhydrostatic_euler .or. c%nonhydrostatic_quasi) return
    if (c%filter%nonhydrostatic) return
    if (.not. grid_update_environment_supported()) return
    if (c%semi_lagrangian .and. c%diagnostic_accumulation .and. .not. c%configuration_x) return
    if (c%moist_temperature) then
      if (c%trajectory_present) then
        if (c%trajectory_save .and. c%trajectory_lag) return
      else
        if (c%oops_save .and. c%oops_lag) return
      end if
    end if
    if (pitch < 1 .or. pitch > 512 .or. levels < 0 .or. levels > 512 .or. global_first < 1) return
    last = int(min(int(pitch, int64), int(global_count, int64) - global_first + 1_int64))
    if (last < 0) return
    if (size(air, 1) /= pitch .or. size(air, 2) /= levels .or. size(air, 3) > 4096) return
    if (size(surface, 1) /= pitch .or. size(surface, 2) /= 1 .or. size(surface, 3) > 4096) return
    if (size(tracers, 1) /= pitch .or. size(tracers, 2) /= levels .or. size(tracers, 3) > 4096) return
    if (size(next_air, 1) /= pitch .or. size(next_air, 2) /= levels .or. size(next_air, 3) > 4096) return
    if (size(next_surface, 1) /= pitch .or. size(next_surface, 2) > 4096) return
    if (size(increments, 1) /= pitch .or. size(increments, 2) > 4096) return
    if (size(next_tracers, 1) /= pitch .or. size(next_tracers, 2) /= levels .or. size(next_tracers, 3) > 4096) return
    do j = 1, 3
      if (map%future_air(j) < 1 .or. map%future_air(j) > size(next_air, 3)) return
      if (map%buffer_first(j) < 1) return
      if (int(map%buffer_first(j), int64) + levels - 1_int64 > size(increments, 2)) return
    end do
    if (map%future_surface < 1 .or. map%future_surface > size(next_surface, 2)) return
    if (map%buffer_surface < 1 .or. map%buffer_surface > size(increments, 2)) return
    if (.not. ieee_is_finite(c%stretch) .or. c%stretch <= 0.0_real64) return
    stretch_difference = c%stretch - 1.0_real64
    threshold = transfer(int(z'0079000000000000', int64), 0.0_real64)
    stretched = abs(stretch_difference) > threshold
    if (stretched .and. levels > 0 .and. last > 0) then
      if (size(metric) < last) return
      do i = 1, last
        if (.not. ieee_is_finite(metric(i)) .or. metric(i) <= 0.0_real64) return
      end do
    end if
    need_stress = c%stress_enabled .and. (.not. c%full_corrector .or. c%current_iteration == c%last_iteration)
    if (need_stress) then
      if (.not. present(stress)) return
      if (size(stress, 1) /= pitch .or. size(stress, 2) < levels .or. size(stress, 3) < 2) return
    end if
    enabled = c%current_iteration == 0; last_step = c%step >= c%last_step
    if (.not. filter_maps_supported(c%filter, c%filter_maps, tracer_pairs, enabled, last_step, &
                                    levels, size(air, 3), size(surface, 3), size(tracers, 3))) return
    if (c%moist_temperature) then
      if (.not. ieee_is_finite(constants%dry_gas_constant) .or. constants%dry_gas_constant <= 0.0_real64) return
      do j = 1, size(components)
        if (.not. components(j)%thermal_active) cycle
        field = components(j)%field_index_by_layout(2)
        if (field < 1 .or. field > size(next_tracers, 3)) return
      end do
      call c_f_pointer(errno_location(), errno_pointer)
      saved_errno = errno_pointer
      allocate (gas(pitch, levels), stat=code)
      errno_pointer = saved_errno
      if (code /= 0) then
        status = 1
        return
      end if
    end if
    if (need_stress) then
      do j = 1, 2
        field = map%future_air(j)
        do k = 1, levels
          do i = 1, last
            next_air(i, k, field) = next_air(i, k, field) + stress(i, k, j)
          end do
        end do
      end do
    end if
    call apply_time_filter_first(c%filter, c%filter_maps, tracer_pairs, enabled, last_step, pitch, &
                                 1_int32, int(last, int32), levels, c%filter_weights, air, surface, tracers, status)
    if (status /= 0) goto900
    do j = 1, 3
      field = map%future_air(j)
      do k = 1, levels
        do i = 1, last
          next_air(i, k, field) = next_air(i, k, field) + increments(i, map%buffer_first(j) + k - 1)
        end do
      end do
    end do
    do i = 1, last
      next_surface(i, map%future_surface) = next_surface(i, map%future_surface) + increments(i, map%buffer_surface)
    end do
    if (c%moist_temperature) then
      no_water = .false.
      call compute_moist_air_properties(constants, pitch, 1_int32, int(last, int32), levels, no_water, status, &
                                        gas_constant=gas, generic_fields=next_tracers, constituents=components, layout_code=1_int32)
      if (status /= 0) goto900
      reciprocal_rd = 1.0_real64/constants%dry_gas_constant
      field = map%future_air(3)
      do k = 1, levels
        do i = 1, last
          value = gas(i, k)*next_air(i, k, field)
          next_air(i, k, field) = value*reciprocal_rd
        end do
      end do
    end if
    if (stretched) then
      do k = 1, levels
        do i = 1, last
          next_air(i, k, map%future_air(1)) = next_air(i, k, map%future_air(1))/metric(i)
          next_air(i, k, map%future_air(2)) = next_air(i, k, map%future_air(2))/metric(i)
        end do
      end do
    end if
    status = 0
900 continue
    if (allocated(gas)) then
      saved_errno = errno_pointer
      deallocate (gas)
      errno_pointer = saved_errno
    end if
  end subroutine

  logical function grid_update_environment_supported() result(ok)
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: saved
    real(real64), volatile :: normal, half
    call ieee_get_status(saved)
    call ieee_get_rounding_mode(rounding)
    ok = .false.
    if (rounding == ieee_nearest) then
      normal = tiny(0.0_real64); half = normal*0.5_real64
      ok = transfer(half, 0_int64) == int(z'0008000000000000', int64)
    end if
    call ieee_set_status(saved)
  end function

  logical function filter_maps_supported(c, maps, tracers, enabled, last_step, levels, na, ns, nt) result(ok)
    type(time_filter_controls), intent(in) :: c
    type(time_filter_maps), intent(in) :: maps
    type(filter_field_pair), intent(in) :: tracers(:)
    logical, intent(in) :: enabled, last_step
    integer, intent(in) :: levels, na, ns, nt
    ok = .false.
    if (.not. enabled) then
      if (c%copy_gradients) then
        if (.not. pairs_valid(maps%gradients, na, .false.)) return
      end if
    else if (c%two_time_levels) then
      if (.not. pairs_valid(maps%motion(:2), na, .false.)) return
      if (c%copy_gradients) then
        if (.not. pairs_valid(maps%gradients, na, .false.)) return
      end if
      if (c%copy_full_state) then
        if (.not. pairs_valid(maps%temperature, na, .false.)) return
        if (.not. pairs_valid(tracers, nt, .false.)) return
        if (c%nonhydrostatic) then
          if (.not. pairs_valid(maps%nonhydro, na, .false.)) return
        end if
        if (.not. pairs_valid(maps%surface, ns, .false.)) return
      end if
    else if (last_step) then
      if (maps%air_clear_last >= maps%air_clear_first) then
        if (maps%air_clear_first < 1 .or. maps%air_clear_last > na) return
      end if
      if (maps%surface_clear_last >= maps%surface_clear_first) then
        if (maps%surface_clear_first < 1 .or. maps%surface_clear_last > ns) return
      end if
      if (.not. pairs_valid(tracers, nt, .true.)) return
    else
      if (.not. pairs_valid(maps%motion, na, .false.)) return
      if (c%temperature_fields >= 1) then
        if (.not. pairs_valid(maps%temperature, na, .false.)) return
      end if
      if (c%nonhydrostatic) then
        if (.not. pairs_valid(maps%nonhydro, na, .false.)) return
      end if
      if (.not. pairs_valid(tracers, nt, .false.)) return
      if (.not. pairs_valid(maps%surface, ns, .false.)) return
    end if
    ok = .true.
  end function

  logical function pairs_valid(pairs, fields, clear) result(ok)
    type(filter_field_pair), intent(in) :: pairs(:)
    integer, intent(in) :: fields
    logical, intent(in) :: clear
    integer :: j
    ok = .false.
    do j = 1, size(pairs)
      if (.not. pairs(j)%enabled) cycle
      if (pairs(j)%destination < 1 .or. pairs(j)%destination > fields) return
      if (.not. clear) then
        if (pairs(j)%source < 1 .or. pairs(j)%source > fields) return
      end if
    end do
    ok = .true.
  end function
end module forecast_lagged_grid_update
