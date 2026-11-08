!> Own the selected hydrostatic pressure,continuity and tendency call chain.
module forecast_hydrostatic_grid_calculations
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls, &
                                                  compute_thermal_pressure_derivatives, compute_pressure_gradients
  use md2asm_hybrid_pressure_one_based, only: compute_hybrid_pressure_one_based
  use md2asm_horizontal_pressure_weight_gradients, only: pressure_weight_fields, pressure_gradient_fields, &
                                                         compute_horizontal_pressure_weight_gradients
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent, compute_moist_air_properties
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_vertical_continuity, only: compute_vertical_continuity
  use md2asm_geopotential_and_column_water, only: compute_geopotential
  use md2asm_geopotential_gradients, only: compute_geopotential_gradients
  use md2asm_wind_tendency, only: compute_wind_tendencies
  use forecast_lagged_grid_update, only: grid_update_environment_supported
  implicit none
  private
  public :: hydrostatic_grid_controls, hydrostatic_motion_map, hydrostatic_grid_outputs
  public :: native_hydrostatic_pressure_terms, compute_hydrostatic_grid
  public :: allocate_hydrostatic_pressure_terms, release_hydrostatic_pressure_terms
  !> Native pressure-term owner;names retain their original TPG_TYPE identities.
  !! Five persistent arrays are allocated by the enclosing column update.
  !! Five temporary arrays are allocated and released by the hydrostatic child.
  type :: native_hydrostatic_pressure_terms
    real(real64), allocatable :: rt0l(:, :), rt0m(:, :), phi0fl(:, :), phi0fm(:, :), phi0h(:, :)
    real(real64), allocatable :: psgrtl(:, :), psgrtm(:, :), rt0(:, :), phi0hl(:, :), phi0hm(:, :)
    real(real64), allocatable :: phi0f(:, :)
  end type
  !> Actual source flags and pressure field positions; unsupported branches refuse.
  type :: hydrostatic_grid_controls
    type(hybrid_pressure_controls) :: pressure
    integer(int32) :: pressure_fields(7) = 0
    integer :: integral_bc = 3, derivative_bc = 3
    logical :: gravity_wave = .false., horizontal_wave = .false., diabatic = .false., previous_wave = .false.
    logical :: reuse_pressure = .false., reuse_pressure_force = .false., upper_flux = .false.
    logical :: nonhydrostatic = .false., simple_physics = .false., mass_source_active = .false.
    logical :: specific_gas_active = .false., large_scale_forcing = .false., wave_diagnostics = .false.
    logical :: moist_temperature = .false., dry_virtual_wind = .false., filter_pressure_force = .false.
    logical :: two_time_levels = .false., wind_damping = .false.
  end type
  !> Actual one-based TGMV plane indices,not compiler byte offsets.
  type :: hydrostatic_motion_map
    integer(int32) :: u = 0, v = 0, temperature = 0, temperature_x = 0, temperature_y = 0, divergence = 0
    integer(int32) :: force_x = 0, force_y = 0, previous_force_x = 0, previous_force_y = 0
  end type
  !> Borrow the complete source output owners;cells vary first.
  !! Half pressure and continuity have physical second bounds0:levels.
  !! Continuity fields are EVEL,VVEL,PSDIV,PSDVBC,DIVDP in that order.
  !! All other two-dimensional arrays have second bounds1:levels.
  type :: hydrostatic_grid_outputs
    real(real64), pointer :: half_pressure(:, :) => null(), full_pressure(:, :) => null(), pressure_weights(:, :, :) => null()
    real(real64), pointer :: heat_capacity(:, :) => null(), gas_constant(:, :) => null(), kappa(:, :) => null()
    real(real64), pointer :: continuity(:, :, :) => null(), full_geopotential(:, :) => null(), kinetic_energy(:, :) => null()
    real(real64), pointer :: wind_u(:, :) => null(), wind_v(:, :) => null(), wind_u_no_coriolis(:, :) => null()
    real(real64), pointer :: wind_v_no_coriolis(:, :) => null(), temperature_rate(:, :) => null()
  end type
  interface
    function errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate only the five persistent source column-work arrays.
  !! pitch and levels are live positive counts;half geopotential is(P,0:L).
  !! The caller releases them only after its final dependent child returns.
  subroutine allocate_hydrostatic_pressure_terms(terms, pitch, levels, status)
    type(native_hydrostatic_pressure_terms), intent(inout) :: terms
    integer(int32), intent(in) :: pitch, levels
    integer(int32), intent(out) :: status
    integer :: code
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved
    status = 2
    if (pitch < 1 .or. pitch > 256 .or. levels < 1 .or. levels > 512) return
    if (allocated(terms%rt0l) .or. allocated(terms%rt0m) .or. allocated(terms%phi0fl)) return
    if (allocated(terms%phi0fm) .or. allocated(terms%phi0h) .or. temporary_present(terms)) return
    call c_f_pointer(errno_location(), ep); saved = ep
    allocate (terms%rt0l(pitch, levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%rt0m(pitch, levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%phi0fl(pitch, levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%phi0fm(pitch, levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%phi0h(pitch, 0:levels), stat=code)
    if (code /= 0) goto800
    status = 0; ep = saved
    return
800 continue
    call release_hydrostatic_pressure_terms(terms)
    status = 1; ep = saved
  end subroutine

  !> Release persistent arrays in source CPG order;leave unused PHI0F unchanged.
  subroutine release_hydrostatic_pressure_terms(terms)
    type(native_hydrostatic_pressure_terms), intent(inout) :: terms
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved
    call c_f_pointer(errno_location(), ep); saved = ep
    if (allocated(terms%rt0l)) deallocate (terms%rt0l)
    if (allocated(terms%rt0m)) deallocate (terms%rt0m)
    if (allocated(terms%phi0fl)) deallocate (terms%phi0fl)
    if (allocated(terms%phi0fm)) deallocate (terms%phi0fm)
    if (allocated(terms%phi0h)) deallocate (terms%phi0h)
    ep = saved
  end subroutine

  !> Run all nine own numerical children in the generated source order.
  !!
  !! pitch1:256,levels1:512 and first:last are live counts and an inclusive
  !! interval;last=first-1 is empty. The retained complete source is L19.
  !! Wider dimensions are compiled extensions pending their own comparisons.
  !! Native coefficients VAH/VBH have bounds0:L;VC,VAF,VBF,VDELA,VDELB and
  !! inverse_coordinate_depth have bounds1:L. Metric is VFE_RDETAH(1:L).
  !! Tables and controls describe finite elements with both boundary choices3.
  !!
  !! motion(P,L,F) changes only its current pressure-force history planes when
  !! filter_pressure_force is true. False consumes the direct pressure force
  !! and neither reads nor writes any of the four history-map entries.
  !! constituents read generic_fields(P,L,C) without mutation. Surface pressure
  !! is already stored at output%half_pressure(:,L). Pressure is Pa,geopotential
  !! m**2/s**2,winds m/s,temperature K and returned tendencies their units/s.
  !! Every output view and persistent pressure target stays alive and is
  !! disjoint from consumed input owners. Inactive cells retain source preimages,
  !! except the complete pressure coefficient owner is source-defined zeroed.
  !!
  !! Status0 completes the chain,1 reports allocation failure and2 refuses a
  !! control,shape or child. A late child refusal is not a completed update.
  !! The compiler owns native descriptors;no original numerical stage,private
  !! model byte layout or comparison callback is used.
  subroutine compute_hydrostatic_grid(c, map, pitch, first, last, levels, constants, components, tables, &
                                      a_half, b_half, vc, full_a, full_b, delta_a, delta_b, inverse_coordinate_depth, metric, &
                                     motion, generic_fields, surface_geopotential, surface_geopotential_x, surface_geopotential_y, &
                                      surface_pressure_x, surface_pressure_y, coriolis, terms, output, status)
    type(hydrostatic_grid_controls), intent(in) :: c
    type(hydrostatic_motion_map), intent(in) :: map
    integer(int32), intent(in) :: pitch, first, last, levels
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: components(:)
    type(vertical_operator_matrices), intent(in) :: tables
    real(real64), intent(in) :: a_half(0:), b_half(0:), vc(:), full_a(:), full_b(:), delta_a(:), delta_b(:)
    real(real64), intent(in) :: inverse_coordinate_depth(:), metric(:), generic_fields(:, :, :)
    real(real64), target, intent(inout) :: motion(:, :, :)
    real(real64), intent(in) :: surface_geopotential(:), surface_geopotential_x(:), surface_geopotential_y(:)
    real(real64), intent(in) :: surface_pressure_x(:), surface_pressure_y(:), coriolis(:)
    type(native_hydrostatic_pressure_terms), intent(inout) :: terms
    type(hydrostatic_grid_outputs), intent(inout) :: output
    integer(int32), intent(out) :: status
    real(real64), allocatable :: inverse_pressure(:, :), derivatives(:, :, :), mass_source(:, :)
    real(real64), allocatable, volatile :: dry_temperature(:, :)
    real(real64), pointer :: u(:, :), v(:, :), t(:, :), tx(:, :), ty(:, :), divergence(:, :)
    type(pressure_weight_fields) :: input_indices
    type(pressure_gradient_fields) :: gradient_indices
    integer :: i, j, k, code, plane, indices(10)
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved
    real(real64) :: a, b, value, old_value, new_value
    logical :: no_water(6)
    status = 2
    if (pitch < 1 .or. pitch > 256 .or. levels < 1 .or. levels > 512) return
    if (.not. grid_update_environment_supported()) return
    if (first < 1 .or. first > pitch .or. last < first - 1 .or. last > pitch) return
    if (c%gravity_wave .or. c%horizontal_wave .or. c%previous_wave) return
    if (c%reuse_pressure .or. c%reuse_pressure_force .or. c%upper_flux .or. c%nonhydrostatic) return
    if (c%simple_physics .or. c%mass_source_active .or. c%specific_gas_active) return
    if (c%large_scale_forcing .or. c%wave_diagnostics .or. c%wind_damping) return
    if (.not. c%pressure%finite_elements .or. c%integral_bc /= 3 .or. c%derivative_bc /= 3) return
    if (.not. c%moist_temperature .or. .not. c%dry_virtual_wind) return
    if (.not. c%two_time_levels) return
    if (size(motion, 1) /= pitch .or. size(motion, 2) /= levels .or. size(motion, 3) > 4096) return
    if (size(generic_fields, 1) /= pitch .or. size(generic_fields, 2) /= levels) return
    indices(1:6) = [map%u, map%v, map%temperature, map%temperature_x, map%temperature_y, map%divergence]
    if (c%filter_pressure_force) then
      indices(7:10) = [map%force_x, map%force_y, map%previous_force_x, map%previous_force_y]
      if (any(indices < 1) .or. any(indices > size(motion, 3))) return
      do j = 7, 10
        do k = 1, j - 1
          if (indices(j) == indices(k)) return
        end do
      end do
    else
      if (any(indices(1:6) < 1) .or. any(indices(1:6) > size(motion, 3))) return
    end if
    if (ubound(a_half, 1) < levels .or. ubound(b_half, 1) < levels) return
    if (size(vc) < levels .or. size(full_a) < levels .or. size(full_b) < levels) return
    if (size(delta_a) < levels .or. size(delta_b) < levels) return
    if (size(metric) < levels .or. size(inverse_coordinate_depth) < levels) return
    if (size(surface_geopotential) < pitch .or. size(surface_geopotential_x) < pitch) return
    if (size(surface_geopotential_y) < pitch .or. size(surface_pressure_x) < pitch) return
    if (size(surface_pressure_y) < pitch .or. size(coriolis) < last) return
    if (.not. outputs_supported(output, pitch, levels)) return
    if (any(c%pressure_fields(:5) < 1) .or. any(c%pressure_fields(:5) > size(output%pressure_weights, 3))) return
    do j = 1, 5
      do k = 1, j - 1
        if (c%pressure_fields(j) == c%pressure_fields(k)) return
      end do
    end do
    do j = 1, size(components)
      if (.not. components(j)%thermal_active) cycle
      plane = components(j)%field_index_by_layout(1)
      if (plane < 1 .or. plane > size(generic_fields, 3)) return
    end do
    if (.not. persistent_supported(terms, pitch, levels) .or. temporary_present(terms)) return
    u => motion(:, :, map%u); v => motion(:, :, map%v); t => motion(:, :, map%temperature)
    tx => motion(:, :, map%temperature_x); ty => motion(:, :, map%temperature_y); divergence => motion(:, :, map%divergence)
    call c_f_pointer(errno_location(), ep); saved = ep
    allocate (terms%psgrtl(pitch, levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%psgrtm(pitch, levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%rt0(pitch, levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%phi0hl(pitch, 0:levels), stat=code)
    if (code /= 0) goto800
    allocate (terms%phi0hm(pitch, 0:levels), stat=code)
    if (code /= 0) goto800
    allocate (inverse_pressure(pitch, levels), derivatives(pitch, levels, 2), mass_source(pitch, levels), &
              dry_temperature(pitch, levels), stat=code)
    if (code /= 0) goto800
    ep = saved
    call compute_hybrid_pressure_one_based(c%pressure, pitch, first, last, levels, a_half, b_half, &
                                         output%half_pressure, status, number_fields=int(size(output%pressure_weights, 3), int32), &
                             field_index=c%pressure_fields, vc=vc, full_a=full_a, full_b=full_b, delta_a=delta_a, delta_b=delta_b, &
                                           coefficients=output%pressure_weights, full_pressure=output%full_pressure)
    if (status /= 0) goto900
    ! The original parent clears the complete pressure carrier after empty GPHPRE.
    if (last < first) output%pressure_weights = 0.0_real64
    do k = 1, levels
      do i = first, last
        inverse_pressure(i, k) = 1.0_real64/output%full_pressure(i, k)
      end do
    end do
    input_indices%inverse_depth = c%pressure_fields(2)
    input_indices%thermal_gradient = c%pressure_fields(5)
    input_indices%depth_weight = c%pressure_fields(3)
    gradient_indices%depth_x = 1; gradient_indices%depth_y = 2
    call compute_horizontal_pressure_weight_gradients(pitch, first, last, levels, .true., &
                                                int(c%pressure%approximate_mode, int32), .false., input_indices, gradient_indices, &
                              surface_pressure_x, surface_pressure_y, output%pressure_weights, derivatives, status, delta_b=delta_b)
    if (status /= 0) goto900
    no_water = .false.
    call compute_moist_air_properties(constants, pitch, first, last, levels, no_water, status, &
                                      heat_capacity=output%heat_capacity, gas_constant=output%gas_constant, kappa=output%kappa, &
                                      generic_fields=generic_fields, constituents=components)
    if (status /= 0) goto900
    call compute_thermal_pressure_derivatives(.true., pitch, first, last, levels, constants%dry_gas_constant, &
                           constants%vapour_gas_constant, output%gas_constant, t, tx, ty, terms%rt0, terms%rt0l, terms%rt0m, status)
    if (status /= 0) goto900
    do k = 1, levels
      do i = first, last
        dry_temperature(i, k) = constants%dry_gas_constant*t(i, k)
      end do
    end do
    mass_source = 0.0_real64
    call compute_vertical_continuity(pitch, first, last, levels, .true., .false., c%integral_bc, c%derivative_bc, &
                                     tables, full_b, delta_b, inverse_coordinate_depth, u, v, divergence, &
                                     output%pressure_weights(:, :, c%pressure_fields(1)), surface_pressure_x, surface_pressure_y, &
                                     inverse_pressure, output%continuity, status, mass_source)
    if (status /= 0) goto900
    terms%phi0h(first:last, levels) = surface_geopotential(first:last)
    call compute_geopotential(pitch, first, last, levels, .true., tables, c%integral_bc, c%derivative_bc, &
                              output%gas_constant, t, output%pressure_weights(:, :, c%pressure_fields(3)), &
                              terms%phi0h, output%full_geopotential, status, metric=metric)
    if (status /= 0) goto900
    call compute_geopotential_gradients(pitch, first, last, levels, .true., .false., tables, &
                                        c%integral_bc, c%derivative_bc, terms%rt0, terms%rt0l, terms%rt0m, &
                                  output%pressure_weights(:, :, c%pressure_fields(3)), derivatives(:, :, 1), derivatives(:, :, 2), &
                           surface_geopotential_x, surface_geopotential_y, terms%phi0hl, terms%phi0hm, terms%phi0fl, terms%phi0fm, &
                                        status, metric=metric)
    if (status /= 0) goto900
    do k = 1, levels
      do i = first, last
        a = u(i, k)*u(i, k); b = v(i, k)*v(i, k); value = a + b
        output%kinetic_energy(i, k) = 0.5_real64*value
      end do
    end do
    call compute_pressure_gradients(.true., pitch, first, last, levels, terms%rt0, terms%psgrtl, terms%psgrtm, &
                                    status, gradient_weight=output%pressure_weights(:, :, c%pressure_fields(5)), &
                     surface_x=surface_pressure_x, surface_y=surface_pressure_y, full_base_x=terms%phi0fl, full_base_y=terms%phi0fm)
    if (status /= 0) goto900
    ! Source CPG_GP_HYD lines 425:441 skip both history directions when false.
    if (c%filter_pressure_force) then
    do j = 1, 2
      do k = 1, levels
        do i = first, last
          if (j == 1) then
            old_value = motion(i, k, map%previous_force_x) - motion(i, k, map%force_x)
            new_value = terms%psgrtl(i, k) - old_value
            motion(i, k, map%force_x) = terms%psgrtl(i, k)
            terms%psgrtl(i, k) = new_value
          else
            old_value = motion(i, k, map%previous_force_y) - motion(i, k, map%force_y)
            new_value = terms%psgrtm(i, k) - old_value
            motion(i, k, map%force_y) = terms%psgrtm(i, k)
            terms%psgrtm(i, k) = new_value
          end if
        end do
      end do
    end do
    end if
    call compute_wind_tendencies(pitch, first, last, levels, 0_int32, u, v, terms%psgrtl, terms%psgrtm, coriolis, &
                                 output%wind_u, output%wind_v, output%wind_u_no_coriolis, output%wind_v_no_coriolis, status)
    if (status /= 0) goto900
    do k = 1, levels
      do i = first, last
        value = output%kappa(i, k)*t(i, k)
        output%temperature_rate(i, k) = value*output%continuity(i, k, 2)
      end do
    end do
    status = 0
    goto900
800 continue
    status = 1
900 continue
    if (allocated(terms%psgrtl)) deallocate (terms%psgrtl)
    if (allocated(terms%psgrtm)) deallocate (terms%psgrtm)
    if (allocated(terms%rt0)) deallocate (terms%rt0)
    if (allocated(terms%phi0hl)) deallocate (terms%phi0hl)
    if (allocated(terms%phi0hm)) deallocate (terms%phi0hm)
    if (allocated(inverse_pressure)) deallocate (inverse_pressure)
    if (allocated(derivatives)) deallocate (derivatives)
    if (allocated(mass_source)) deallocate (mass_source)
    if (allocated(dry_temperature)) deallocate (dry_temperature)
    ep = saved
  end subroutine

  logical function temporary_present(terms) result(ok)
    type(native_hydrostatic_pressure_terms), intent(in) :: terms
    ok = allocated(terms%psgrtl) .or. allocated(terms%psgrtm) .or. allocated(terms%rt0) .or. &
         allocated(terms%phi0hl) .or. allocated(terms%phi0hm)
  end function
  logical function persistent_supported(terms, p, l) result(ok)
    type(native_hydrostatic_pressure_terms), intent(in) :: terms
    integer, intent(in) :: p, l
    ok = .false.
    if (.not. allocated(terms%rt0l) .or. .not. allocated(terms%rt0m)) return
    if (.not. allocated(terms%phi0fl) .or. .not. allocated(terms%phi0fm) .or. .not. allocated(terms%phi0h)) return
    if (any(shape(terms%rt0l) /= [p, l]) .or. any(shape(terms%rt0m) /= [p, l])) return
    if (any(shape(terms%phi0fl) /= [p, l]) .or. any(shape(terms%phi0fm) /= [p, l])) return
    if (size(terms%phi0h, 1) /= p .or. lbound(terms%phi0h, 2) /= 0 .or. ubound(terms%phi0h, 2) /= l) return
    ok = .true.
  end function
  logical function full(a, p, l) result(ok)
    real(real64), pointer, intent(in) :: a(:, :)
    integer, intent(in) :: p, l
    ok = .false.
    if (.not. associated(a)) return
    ok = size(a, 1) == p .and. size(a, 2) >= l .and. lbound(a, 1) == 1 .and. lbound(a, 2) == 1
  end function
  logical function outputs_supported(o, p, l) result(ok)
    type(hydrostatic_grid_outputs), intent(in) :: o
    integer, intent(in) :: p, l
    ok = .false.
    if (.not. full(o%full_pressure, p, l) .or. .not. full(o%heat_capacity, p, l)) return
    if (.not. full(o%gas_constant, p, l) .or. .not. full(o%kappa, p, l)) return
    if (.not. full(o%full_geopotential, p, l) .or. .not. full(o%kinetic_energy, p, l)) return
    if (.not. full(o%wind_u, p, l) .or. .not. full(o%wind_v, p, l)) return
    if (.not. full(o%wind_u_no_coriolis, p, l) .or. .not. full(o%wind_v_no_coriolis, p, l)) return
    if (.not. full(o%temperature_rate, p, l)) return
    if (.not. associated(o%half_pressure) .or. .not. associated(o%pressure_weights) .or. .not. associated(o%continuity)) return
    if (size(o%half_pressure, 1) /= p .or. lbound(o%half_pressure, 1) /= 1) return
    if (lbound(o%half_pressure, 2) /= 0 .or. ubound(o%half_pressure, 2) < l) return
    if (size(o%pressure_weights, 1) /= p .or. size(o%pressure_weights, 2) < l .or. size(o%pressure_weights, 3) < 5) return
    if (any(lbound(o%pressure_weights) /= [1, 1, 1])) return
    if (size(o%continuity, 1) /= p .or. lbound(o%continuity, 1) /= 1 .or. lbound(o%continuity, 3) /= 1) return
    if (lbound(o%continuity, 2) /= 0 .or. ubound(o%continuity, 2) < l) return
    if (size(o%continuity, 3) /= 5) return
    ok = .true.
  end function
end module forecast_hydrostatic_grid_calculations
