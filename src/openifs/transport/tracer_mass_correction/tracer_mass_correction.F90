!> Complete selected and runtime QMFIXER with owned ordered arithmetic.
module forecast_tracer_mass_correction
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_double, c_loc, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi, only: MPI_INTEGER, MPI_MAX, MPI_SUCCESS
  use grid_field_configuration_types_port, only: grid_field_configuration
  use forecast_tracer_mass_correction_types, only: tracer_mass_grid, tracer_mass_layout
  use md2asm_hybrid_pressure_and_gradients, only: compute_hybrid_pressure
  use md2asm_geopotential_and_column_water, only: integrate_column_water
  use md2asm_departure_neighbour_interpolation, only: interpolate_eight_neighbours, bound_eight_neighbours
  use departure_neighbour_bounds_operational_mod, only: bound_eight_neighbours_operational
  use forecast_pressure_norms, only: fix_surface_pressure, grid_point_norm
  use forecast_public_scalar_math, only: power_original_rounding
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event
  implicit none
  private
  public :: qmfixer_selected, qmfixer_runtime
  external :: MPI_Allreduce
  interface
    function public_exp(value) result(answer) bind(C, name='exp')
      import :: c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function
    function system_errno_address() result(address) bind(C, name='__errno_location')
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
!> Correct the frozen serial24-column,19-level,2048-point selected route.
!! GRID and LAYOUT borrow live native metadata; GFL is read-only complete
!! canonical field metadata. KL0(P,L,0:3,B), PLSCAW(P,L,W,B),
!! PB1(source_pitch,source_fields), PGMVS(P,motion_fields,B) and
!! PGFL(P,L,old_fields,B) remain read only. PGMVT1S(P,1,B) stores log(Pa),
!! and PGFLT1(P,L,new_fields,B) stores predicted mass fractions in kg/kg.
!! Only active predicted log-pressure and the first five tracer fields change;
!! every unused field and last-block padding word stays incoming.
!! Arrays are ordinary assumed-shape, contiguous, valid and disjoint owners.
!! STATUS is 0 on success,1 on workspace failure,2 on native admission refusal,
!! or the unchanged child status. Optional PROFILE enables actual FIAT hooks.
!! The caller establishes nearest-even rounding and gradual underflow once.
  subroutine qmfixer_selected(grid, layout, gfl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status, profile)
    type(tracer_mass_grid), intent(in) :: grid
    type(tracer_mass_layout), intent(in) :: layout
    type(grid_field_configuration), intent(in) :: gfl
    integer(int32), intent(in) :: kl0(:, :, 0:, :)
    real(real64), intent(in) :: plscaw(:, :, :, :), pgmvs(:, :, :), pgfl(:, :, :, :)
    real(real64), target, intent(in) :: pb1(:, :)
    real(real64), target, intent(inout) :: pgmvt1s(:, :, :)
    real(real64), intent(inout) :: pgflt1(:, :, :, :)
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    call correction_body(.false., grid, layout, gfl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status, profile)
  end subroutine
!> Correct the live-dimension selected five-field runtime route.
!! Arguments, units, ownership and mutation match QMFIXER_SELECTED. P and L
!! are1..4096; source slab and all complete owners obey the linked child bounds.
!! Every participating process agrees admission before this collective route.
!! The source runtime hook policy is disabled. Allocation agreement preserves
!! the entering numerical status and errno; numerical child status is natural.
  subroutine qmfixer_runtime(grid, layout, gfl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status)
    type(tracer_mass_grid), intent(in) :: grid
    type(tracer_mass_layout), intent(in) :: layout
    type(grid_field_configuration), intent(in) :: gfl
    integer(int32), intent(in) :: kl0(:, :, 0:, :)
    real(real64), intent(in) :: plscaw(:, :, :, :), pgmvs(:, :, :), pgfl(:, :, :, :)
    real(real64), target, intent(in) :: pb1(:, :)
    real(real64), target, intent(inout) :: pgmvt1s(:, :, :)
    real(real64), intent(inout) :: pgflt1(:, :, :, :)
    integer(int32), intent(out) :: status
    call correction_body(.true., grid, layout, gfl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status)
  end subroutine
  subroutine correction_body(runtime, grid, layout, gfl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status, profile)
    logical, intent(in) :: runtime
    type(tracer_mass_grid), intent(in) :: grid
    type(tracer_mass_layout), intent(in) :: layout
    type(grid_field_configuration), intent(in) :: gfl
    integer(int32), intent(in) :: kl0(:, :, 0:, :)
    real(real64), intent(in) :: plscaw(:, :, :, :), pgmvs(:, :, :), pgfl(:, :, :, :)
    real(real64), target, intent(in) :: pb1(:, :)
    real(real64), target, intent(inout) :: pgmvt1s(:, :, :)
    real(real64), intent(inout) :: pgflt1(:, :, :, :)
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    real(real64), allocatable, target :: work(:)
    real(real64), pointer, contiguous :: pressure0(:, :), pressure1(:, :), half0(:, :, :), half1(:, :, :)
    real(real64), pointer, contiguous :: field0(:, :), field1(:, :), column0(:, :), column1(:, :)
    real(real64), pointer, contiguous :: linear(:, :), minimum(:, :), maximum(:, :), weights(:, :, :, :)
    real(real64), pointer, contiguous :: packed_mass(:, :, :), packed_weight(:, :, :), source_flat(:), log_flat(:)
    real(real64), pointer, contiguous :: pressure0_flat(:), pressure1_flat(:)
    real(real64) :: mass_norms(3, 10), weight_norms(3, 5), mass_difference(5), scale(5), lambda(5)
    real(real64) :: difference, scaled, powered, layer_delta, area_layer, weight, increment, candidate, denominator
    real(real64) :: hook_handle
    integer(int32) :: p, l, b, n, old_fields, new_fields, active, child_status, local_status
    integer(int64) :: point_capacity, plane_count, slab_words, source_begin, source_end, total_words, at, next_at
    integer(int64) :: pl, ph, pb, source_first(5)
    integer :: allocation_status, field, block, level, row
    logical :: hook_started
    status = 2_int32
    hook_started = .false.
    p = grid%columns; l = grid%levels; b = grid%blocks; n = grid%active_count
    if (p < 1 .or. p > 4096 .or. l < 1 .or. l > 4096 .or. b < 1 .or. n < 1) return
    point_capacity = int(p, int64)*int(b, int64)
    if (int(n, int64) > point_capacity .or. int(n, int64) <= point_capacity - int(p, int64)) return
    ! The unchanged pressure child uses default-INT32 complete-owner extents.
    if (point_capacity > int(huge(0_int32), int64)) return
    plane_count = int(grid%last_plane, int64) - int(grid%first_plane, int64) + 1_int64
    if (plane_count < 1 .or. plane_count > int(huge(0_int32), int64)) return
    if (grid%source_pitch < 1) return
    slab_words = int(grid%source_pitch, int64)*plane_count
    if (slab_words > int(huge(0_int32), int64)) return
    old_fields = gfl%registration%ndim
    new_fields = gfl%registration%ndim1
    if (old_fields < 5 .or. old_fields > 2163 .or. new_fields < 5 .or. new_fields > 2163) return
    if (gfl%settings%nfldsfix /= 5 .or. gfl%settings%noptmfbc /= 3) return
    if (gfl%settings%ltrcmfix_ps /= 1) return
    if (gfl%settings%noptvfe /= 0 .or. gfl%settings%nmfdiaglev /= 0) return
    if (gfl%settings%ltrcmfqm /= 0 .or. gfl%settings%ltrcmfp /= 0 .or. gfl%settings%lextradf /= 0) return
    ! PFIXER's proportional/no-extra-diagnostic source admission.
    if (gfl%settings%ltrcmfmg /= 0 .or. layout%ngpmascor /= 0) return
    if (layout%lcomad_gfl) return
    if (layout%weight_fields < 6 .or. layout%weight_fields > 4096) return
    if (layout%m_wdlat < 1 .or. layout%m_wdlat > layout%weight_fields) return
    if (layout%m_wdlo < 1 .or. layout%m_wdlo >= layout%weight_fields) return
    if (layout%m_wdver < 1 .or. layout%m_wdver > layout%weight_fields) return
    if (layout%source_fields < 1 .or. layout%source_fields > 16777216 .or. layout%mslb1gfl9 < 1) return
    if (layout%motion_surface_fields < 1 .or. layout%motion_surface_fields > 4096) return
    if (layout%msp0 < 1 .or. layout%msp0 > layout%motion_surface_fields) return
    if (layout%predicted_surface_fields /= 1 .or. layout%msp1 /= 1) return
    if (grid%transform < 1 .or. grid%process_count < 1) return
    if (.not. associated(grid%a_half) .or. .not. associated(grid%b_half) .or. .not. associated(grid%quadrature)) return
    if (size(grid%a_half) < l .or. size(grid%b_half) < l) return
    if (any(shape(grid%quadrature) /= [p, b])) return
    if (.not. is_contiguous(grid%a_half) .or. .not. is_contiguous(grid%b_half) .or. .not. is_contiguous(grid%quadrature)) return
    if (any(shape(kl0) /= [p, l, 4, b])) return
    if (any(shape(plscaw) /= [p, l, layout%weight_fields, b])) return
    if (any(shape(pb1) /= [grid%source_pitch, layout%source_fields])) return
    if (any(shape(pgmvs) /= [p, layout%motion_surface_fields, b])) return
    if (any(shape(pgmvt1s) /= [p, 1, b])) return
    if (any(shape(pgfl) /= [p, l, old_fields, b]) .or. any(shape(pgflt1) /= [p, l, new_fields, b])) return
    if (.not. is_contiguous(kl0) .or. .not. is_contiguous(plscaw) .or. .not. is_contiguous(pb1)) return
    if (.not. is_contiguous(pgmvs) .or. .not. is_contiguous(pgmvt1s)) return
    if (.not. is_contiguous(pgfl) .or. .not. is_contiguous(pgflt1)) return
    do field = 1, 5
      if (gfl%settings%nmfixflds(field) /= field) return
      if (gfl%components(field)%mp /= field .or. gfl%components(field)%mp1 /= field) return
      if (transfer(gfl%components(field)%betamfbc, 0_int64) /= int(z'3ff0000000000000', int64)) return
      if (gfl%components(field)%lcomad /= 0 .or. gfl%components(field)%mp_sl1 < 1) return
      source_begin = (int(gfl%components(field)%mp_sl1, int64) - 1_int64)*plane_count + int(layout%mslb1gfl9, int64)
      source_end = source_begin + plane_count - 1_int64
      if (source_begin < 1 .or. source_end > int(layout%source_fields, int64)) return
      source_first(field) = (source_begin - 1_int64)*int(grid%source_pitch, int64) + 1_int64
    end do
    if (.not. runtime) then
      if (p /= 24 .or. l /= 19 .or. n /= 2048 .or. b /= 86) return
      if (old_fields /= 8 .or. new_fields /= 6 .or. layout%weight_fields /= 12) return
      if (grid%source_pitch /= 3101 .or. grid%first_plane /= 0 .or. grid%last_plane /= 20) return
      if (layout%m_wdlo /= 1 .or. layout%m_wdlat /= 5 .or. layout%m_wdver /= 6) return
      if (layout%source_fields /= 463 .or. layout%mslb1gfl9 /= 64) return
      if (layout%motion_surface_fields /= 3 .or. layout%msp0 /= 1 .or. grid%process_count /= 1) return
    end if
    ! Form the source's single fourteen-view workspace with checked word counts.
    pb = point_capacity; pl = int(p, int64)*l; ph = int(p, int64)*(int(l, int64) + 1_int64)
    total_words = int(p, int64)*((7_int64*int(l, int64) + 19_int64)*int(b, int64) + 7_int64*int(l, int64) + 2_int64)
    if (total_words > huge(total_words)/8_int64) return
    allocate (work(total_words), stat=allocation_status)
    local_status = 0_int32
    if (allocation_status /= 0) local_status = 1_int32
    if (runtime) then
      call agree_workspace_status(local_status, grid%communicator, status)
    else
      status = local_status
    end if
    if (status /= 0) then
      if (allocated(work)) deallocate (work)
      return
    end if
    at = 1_int64
    next_at = at + pb; pressure0(1:p, 1:b) => work(at:next_at - 1); at = next_at
    next_at = at + pb; pressure1(1:p, 1:b) => work(at:next_at - 1); at = next_at
    next_at = at + ph*b; half0(1:p, 0:l, 1:b) => work(at:next_at - 1); at = next_at
    next_at = at + ph*b; half1(1:p, 0:l, 1:b) => work(at:next_at - 1); at = next_at
    next_at = at + pl; field0(1:p, 1:l) => work(at:next_at - 1); at = next_at
    next_at = at + pl; field1(1:p, 1:l) => work(at:next_at - 1); at = next_at
    next_at = at + ph; column0(1:p, 0:l) => work(at:next_at - 1); at = next_at
    next_at = at + ph; column1(1:p, 0:l) => work(at:next_at - 1); at = next_at
    next_at = at + pl; linear(1:p, 1:l) => work(at:next_at - 1); at = next_at
    next_at = at + pl; minimum(1:p, 1:l) => work(at:next_at - 1); at = next_at
    next_at = at + pl; maximum(1:p, 1:l) => work(at:next_at - 1); at = next_at
    next_at = at + 5_int64*pl*b; weights(1:p, 1:l, 1:5, 1:b) => work(at:next_at - 1); at = next_at
    next_at = at + 10_int64*pb; packed_mass(1:p, 1:10, 1:b) => work(at:next_at - 1); at = next_at
    next_at = at + 5_int64*pb; packed_weight(1:p, 1:5, 1:b) => work(at:next_at - 1)
    call c_f_pointer(c_loc(pb1(1, 1)), source_flat, [size(pb1, kind=int64)])
    call c_f_pointer(c_loc(pgmvt1s(1, 1, 1)), log_flat, [point_capacity])
    pressure0_flat(1:pb) => pressure0
    pressure1_flat(1:pb) => pressure1
    if (.not. runtime) then
      call transform_profile_event('QMFIXER', 0_int32, hook_handle, profile)
      hook_started = .true.
    end if
    ! Each active row calls EXP on old then predicted log surface pressure.
    do block = 1, b
      active = min(p, n - (block - 1)*p)
      do row = 1, active
        pressure0(row, block) = public_exp(pgmvs(row, layout%msp0, block))
        pressure1(row, block) = public_exp(pgmvt1s(row, 1, block))
      end do
    end do
    call fix_surface_pressure(p,n,grid%transform,grid%process_count,grid%communicator,pressure0_flat,pressure1_flat,log_flat,status)
    if (status /= 0) goto 900
    do block = 1, b
      active = min(p, n - (block - 1)*p)
      do row = 1, active
        half0(row, l, block) = pressure0(row, block)
      end do
      call compute_hybrid_pressure(grid%pressure_controls,p,1_int32,active,l,grid%a_half,grid%b_half,half0(:,:,block),child_status)
      if (child_status /= 0) then
        status = child_status
        goto 900
      end if
      do row = 1, active
        half1(row, l, block) = pressure1(row, block)
      end do
      call compute_hybrid_pressure(grid%pressure_controls,p,1_int32,active,l,grid%a_half,grid%b_half,half1(:,:,block),child_status)
      if (child_status /= 0) then
        status = child_status
        goto 900
      end if
    end do
    do field = 1, 5
      do block = 1, b
        active = min(p, n - (block - 1)*p)
        do level = 1, l
          do row = 1, active
            field0(row, level) = pgfl(row, level, field, block)
          end do
        end do
        call integrate_column_water(p, 1_int32, active, l, grid%gravity, field0, half0(:, :, block), column0, child_status)
        if (child_status /= 0) then
          status = child_status
          goto 900
        end if
        do row = 1, active
          packed_mass(row, 2*field - 1, block) = column0(row, l)
        end do
        do level = 1, l
          do row = 1, active
            field1(row, level) = pgflt1(row, level, field, block)
          end do
        end do
        call integrate_column_water(p, 1_int32, active, l, grid%gravity, field1, half1(:, :, block), column1, child_status)
        if (child_status /= 0) then
          status = child_status
          goto 900
        end if
        do row = 1, active
          packed_mass(row, 2*field, block) = column1(row, l)
        end do
      end do
    end do
    call grid_point_norm(packed_mass, n, grid%transform, grid%process_count, mass_norms, status)
    if (status /= 0) goto 900
    do field = 1, 5
      mass_difference(field) = mass_norms(1, 2*field) - mass_norms(1, 2*field - 1)
      if (.not. (mass_difference(field) >= 0.0_real64)) then
        scale(field) = source_minimum(mass_difference(field), -1.0e-8_real64)
      else
        scale(field) = source_maximum(mass_difference(field), 1.0e-8_real64)
      end if
      source_begin = source_first(field); source_end = source_begin + slab_words - 1_int64
      do block = 1, b
        active = min(p, n - (block - 1)*p)
        call interpolate_eight_neighbours(grid%source_pitch, p, 1_int32, active, l, grid%first_plane, grid%last_plane, &
                                    plscaw(:, :, layout%m_wdlat, block), plscaw(:, :, layout%m_wdlo + 1:layout%m_wdlo + 2, block), &
             kl0(:, :, 1:2, block), plscaw(:, :, layout%m_wdver, block), source_flat(source_begin:source_end), linear, child_status)
        if (child_status /= 0) then
          status = child_status
          goto 900
        end if
        do level = 1, l
          do row = 1, active
            difference = pgflt1(row, level, field, block) - linear(row, level)
            scaled = difference/scale(field)
            if (scaled > 1.0e-25_real64) then
              powered = power_original_rounding(scaled, 1.0_real64)
              layer_delta = half1(row, level, block) - half1(row, level - 1, block)
              area_layer = grid%quadrature(row, block)*layer_delta
              area_layer = abs(area_layer)
              weight = powered*area_layer
              weight = weight*pgflt1(row, level, field, block)
            else
              weight = 0.0_real64
            end if
            weights(row, level, field, block) = weight
            field1(row, level) = weight
          end do
        end do
        call integrate_column_water(p, 1_int32, active, l, grid%gravity, field1, half1(:, :, block), column1, child_status)
        if (child_status /= 0) then
          status = child_status
          goto 900
        end if
        do row = 1, active
          packed_weight(row, field, block) = column1(row, l)
        end do
      end do
    end do
    call grid_point_norm(packed_weight, n, grid%transform, grid%process_count, weight_norms, status)
    if (status /= 0) goto 900
    do field = 1, 5
      denominator = source_maximum(weight_norms(1, field), 1.0e-25_real64)
      lambda(field) = mass_difference(field)/denominator
      source_begin = source_first(field); source_end = source_begin + slab_words - 1_int64
      do block = 1, b
        active = min(p, n - (block - 1)*p)
        if (runtime) then
          call bound_eight_neighbours_operational(grid%source_pitch, p, 1_int32, active, l, grid%first_plane, grid%last_plane, &
                                          kl0(:, :, :, block), source_flat(source_begin:source_end), minimum, child_status, maximum)
        else
          call bound_eight_neighbours(grid%source_pitch, p, 1_int32, active, l, grid%first_plane, grid%last_plane, &
                                      kl0(:, :, :, block), source_flat(source_begin:source_end), minimum, child_status, maximum)
        end if
        if (child_status /= 0) then
          status = child_status
          goto 900
        end if
        do level = 1, l
          do row = 1, active
            increment = -lambda(field)
            increment = increment*weights(row, level, field, block)
            candidate = pgflt1(row, level, field, block) + increment
            ! Source B.GE excludes unordered comparisons; do not merge these tests.
            if (.not. (candidate >= minimum(row, level))) then
              if (.not. (increment >= 0.0_real64)) then
                pgflt1(row, level, field, block) = minimum(row, level)
                cycle
              end if
            end if
            if (candidate > maximum(row, level)) then
              if (increment > 0.0_real64) candidate = maximum(row, level)
            end if
            pgflt1(row, level, field, block) = candidate
          end do
        end do
      end do
    end do
    status = 0_int32
900 continue
    deallocate (work)
    if (hook_started) call transform_profile_event('QMFIXER', 1_int32, hook_handle, profile)
  end subroutine
!> Agree the new runtime workspace without replacing numerical child status.
  subroutine agree_workspace_status(local_status, communicator, global_status)
    integer(int32), intent(in) :: local_status, communicator
    integer(int32), intent(out) :: global_status
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_error
    integer :: error
    call ieee_get_status(saved_status)
    call c_f_pointer(system_errno_address(), error_number)
    saved_error = error_number
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER, MPI_MAX, communicator, error)
    error_number = saved_error
    call ieee_set_status(saved_status)
    if (error /= MPI_SUCCESS) global_status = 3_int32
  end subroutine
!> Retain source FMAX signed-zero and NaN selection without fast-math.
  function source_maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    integer(int64) :: aw, bw
    aw = transfer(a, 0_int64); bw = transfer(b, 0_int64)
    if ((ibits(aw, 52, 11) == 2047 .and. ibits(aw, 0, 52) /= 0) .or. (ibits(bw, 52, 11) == 2047 .and. ibits(bw, 0, 52) /= 0)) then
      value = a + b
    else if (a == b) then
      value = a
      if (a == 0.0_real64) value = transfer(iand(aw, bw), 0.0_real64)
    else if (a > b) then
      value = a
    else
      value = b
    end if
  end function
!> Retain source FMIN signed-zero and NaN selection without fast-math.
  function source_minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    integer(int64) :: aw, bw
    aw = transfer(a, 0_int64); bw = transfer(b, 0_int64)
    if ((ibits(aw, 52, 11) == 2047 .and. ibits(aw, 0, 52) /= 0) .or. (ibits(bw, 52, 11) == 2047 .and. ibits(bw, 0, 52) /= 0)) then
      value = a + b
    else if (a == b) then
      value = a
      if (a == 0.0_real64) value = transfer(ior(aw, bw), 0.0_real64)
    else if (a < b) then
      value = a
    else
      value = b
    end if
  end function
end module
