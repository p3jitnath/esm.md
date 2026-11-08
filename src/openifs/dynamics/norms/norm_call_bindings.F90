!> Bind native selected norm calls to one borrowed result owner per process.
module forecast_norm_call_bindings
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_loc, c_associated, c_sizeof, c_intptr_t, c_int
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_spectral_norm_namespace, only: owned_spectral_norm_state
  use forecast_selected_spectral_norms, only: spectral_norm_fields, spectral_norm_model_controls, &
                                              compute_selected_spectral_norms, selected_spectral_norm_result_words
  use forecast_grid_field_norms, only: selected_gridpoint_norm_result, compute_selected_gridpoint_norms
  implicit none
  private
  public :: attach_spectral_norm_context, attach_gridpoint_norm_context
  public :: detach_spectral_norm_context, detach_gridpoint_norm_context
  public :: SPNORM, GPNORM_GFL, norm_loop_call_count_get
  integer(int32), pointer, save :: spectral_controls(:) => null(), grid_controls(:) => null()
  real(real64), pointer, save :: spectral_results(:) => null()
  type(selected_gridpoint_norm_result), pointer, save :: grid_results => null()
  integer(int64), save :: spectral_calls = 0_int64, grid_calls = 0_int64
  interface
    subroutine public_exit(code) bind(C, name='_exit')
      import c_int
      integer(c_int), value :: code
    end subroutine
  end interface
contains
  !> Describe a native C-interoperable buffer without a private model layout.
  !! Pointer-to-integer conversion uses the platform's public intptr kind.
  !! The qualified user address range is representable as a positive intptr.
  logical function native_span(address, bytes, span, alignment) result(ok)
    type(c_ptr), intent(in) :: address
    integer(int64), intent(in) :: bytes
    integer(c_intptr_t), intent(out) :: span(2)
    integer, intent(in) :: alignment
    integer(c_intptr_t) :: first
    first = transfer(address, 0_c_intptr_t)
    ok = .false.
    if (first <= 0_c_intptr_t .or. bytes < 1_int64) return
    if (modulo(first, int(alignment, c_intptr_t)) /= 0_c_intptr_t) return
    if (bytes > int(huge(first) - first, int64)) return
    span = [first, first + int(bytes, c_intptr_t)]
    ok = .true.
  end function

  logical function overlap(a, b)
    integer(c_intptr_t), intent(in) :: a(2), b(2)
    overlap = a(1) < b(2) .and. b(1) < a(2)
  end function

  !> Check the three actual persistent components separately.
  !! No assumption about a compiler's derived-type component spacing is made.
  logical function persistent_disjoint(a, b) result(ok)
    integer(c_intptr_t), intent(in) :: a(2), b(2)
    integer(c_intptr_t) :: span(2)
    integer :: j
    type(c_ptr) :: address(3)
    address(1) = c_loc(owned_spectral_norm_state%avnrmdiv)
    address(2) = c_loc(owned_spectral_norm_state%avnrmpd)
    address(3) = c_loc(owned_spectral_norm_state%avnrmvd)
    ok = .false.
    do j = 1, 3
      if (.not. native_span(address(j), 8_int64, span, 8)) return
      if (overlap(a, span) .or. overlap(b, span)) return
    end do
    ok = .true.
  end function

  !> Borrow six fixed controls and at least2616 canonical result words.
  !! Neither array is copied or changed. Both must be contiguous TARGET owners
  !! at stable addresses until detach,with unchanged controls. A repeated
  !! identical attachment succeeds;another live attachment returns2.
  !! Capacity is bytes. Calls and attachment changes are serial on each rank.
  integer(int32) function attach_spectral_norm_context(controls, results, capacity) result(status)
    integer(int32), target, intent(in) :: controls(:)
    real(real64), target, intent(inout) :: results(:)
    integer(int64), intent(in) :: capacity
    integer(c_intptr_t) :: a(2), b(2), other_a(2), other_b(2)
    status = 2
    if (size(controls) < 6 .or. size(results) < selected_spectral_norm_result_words) return
    if (.not. is_contiguous(controls) .or. .not. is_contiguous(results)) return
    if (capacity < 20928_int64) return
    if (any(controls(1:6) /= [0_int32, 0_int32, 0_int32, 0_int32, 1_int32, 0_int32])) return
    if (.not. native_span(c_loc(controls(1)), 24_int64, a, 4)) return
    if (.not. native_span(c_loc(results(1)), 20928_int64, b, 8)) return
    if (overlap(a, b) .or. .not. persistent_disjoint(a, b)) return
    if (associated(grid_results)) then
      if (.not. native_span(c_loc(grid_controls(1)), 12_int64, other_a, 4)) return
      if (.not. native_span(c_loc(grid_results), int(c_sizeof(grid_results), int64), other_b, 8)) return
      if (overlap(a, other_a) .or. overlap(a, other_b) .or. overlap(b, other_a) .or. overlap(b, other_b)) return
    end if
    if (associated(spectral_results)) then
      if (.not. c_associated(c_loc(spectral_results(1)), c_loc(results(1)))) return
      if (.not. c_associated(c_loc(spectral_controls(1)), c_loc(controls(1)))) return
    else
      spectral_controls => controls(1:6)
      spectral_results => results(1:selected_spectral_norm_result_words)
    end if
    status = 0
  end function

  !> Borrow selected grid controls and one complete public output record.
  !! Controls are0,0,1 and capacity is at least264 bytes. Output and reserved
  !! words stay unchanged during attach/detach. No numerical stage is omitted.
  integer(int32) function attach_gridpoint_norm_context(controls, result, capacity) result(status)
    integer(int32), target, intent(in) :: controls(:)
    type(selected_gridpoint_norm_result), target, intent(inout) :: result
    integer(int64), intent(in) :: capacity
    integer(c_intptr_t) :: a(2), b(2), other_a(2), other_b(2)
    status = 2
    if (size(controls) < 3 .or. .not. is_contiguous(controls)) return
    if (capacity < 264_int64) return
    if (any(controls(1:3) /= [0_int32, 0_int32, 1_int32])) return
    if (.not. native_span(c_loc(controls(1)), 12_int64, a, 4)) return
    if (.not. native_span(c_loc(result), int(c_sizeof(result), int64), b, 8)) return
    if (overlap(a, b) .or. .not. persistent_disjoint(a, b)) return
    if (associated(spectral_results)) then
      if (.not. native_span(c_loc(spectral_controls(1)), 24_int64, other_a, 4)) return
      if (.not. native_span(c_loc(spectral_results(1)), 20928_int64, other_b, 8)) return
      if (overlap(a, other_a) .or. overlap(a, other_b) .or. overlap(b, other_a) .or. overlap(b, other_b)) return
    end if
    if (associated(grid_results)) then
      if (.not. c_associated(c_loc(grid_results), c_loc(result))) return
      if (.not. c_associated(c_loc(grid_controls(1)), c_loc(controls(1)))) return
    else
      grid_controls => controls(1:3)
      grid_results => result
    end if
    status = 0
  end function

  !> Detach only the same borrowed owner;an empty context is already released.
  integer(int32) function detach_spectral_norm_context(results) result(status)
    real(real64), target, intent(inout) :: results(:)
    status = 0
    if (.not. associated(spectral_results)) return
    status = 2
    if (size(results) < 1) return
    if (.not. c_associated(c_loc(spectral_results(1)), c_loc(results(1)))) return
    nullify (spectral_results, spectral_controls)
    status = 0
  end function

  integer(int32) function detach_gridpoint_norm_context(result) result(status)
    type(selected_gridpoint_norm_result), target, intent(inout) :: result
    status = 0
    if (.not. associated(grid_results)) return
    status = 2
    if (.not. c_associated(c_loc(grid_results), c_loc(result))) return
    nullify (grid_results, grid_controls)
    status = 0
  end function

  !> Call the numerical selected SPNORM entry through its actual borrowed state.
  !! Optional LDSPOR may be absent or false. A missing context,unsupported
  !! option or failed numerical call exits127,as the source void interface does.
  !! The numerical result is always calculated;no report-only placeholder runs.
  subroutine SPNORM(geometry, model, fields, LDSPOR)
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_norm_model_controls), intent(in) :: model
    type(spectral_norm_fields), intent(in) :: fields
    logical, intent(in), optional :: LDSPOR
    integer(int32) :: status
    if (.not. associated(spectral_results)) then
      call public_exit(127_c_int)
      return
    end if
    if (present(LDSPOR)) then
      if (LDSPOR) then
        call public_exit(127_c_int)
        return
      end if
    end if
    call compute_selected_spectral_norms(geometry, model, fields, spectral_controls, &
                                         owned_spectral_norm_state, spectral_results, status)
    if (status /= 0) then
      call public_exit(127_c_int)
      return
    end if
    call increment_counter(spectral_calls)
  end subroutine

  !> Native GPNORM_GFL keeps the source optional-argument presence rule.
  !! LDPRINT_TL must be absent;present false selects another source field list.
  !! Data owner and public context requirements are those of the raw utility.
  subroutine GPNORM_GFL(geometry, fields, lgp, LDPRINT_TL)
    type(native_geometry_state), intent(in) :: geometry
    real(real64), intent(in) :: fields(:, :, :, :)
    logical, intent(in) :: lgp(:)
    logical, intent(in), optional :: LDPRINT_TL
    integer(int32) :: status
    if (.not. associated(grid_results) .or. present(LDPRINT_TL)) then
      call public_exit(127_c_int)
      return
    end if
    call compute_selected_gridpoint_norms(geometry, fields, lgp, grid_controls, grid_results, status)
    if (status /= 0) then
      call public_exit(127_c_int)
      return
    end if
    call increment_counter(grid_calls)
  end subroutine

  !> Preserve the source unsigned64 counter bits without signed overflow.
  subroutine increment_counter(counter)
    integer(int64), intent(inout) :: counter
    if (counter == huge(counter)) then
      counter = -huge(counter) - 1_int64
    else
      counter = counter + 1_int64
    end if
  end subroutine

  integer(int64) function norm_loop_call_count_get(index) result(value)
    integer(int64), intent(in) :: index
    value = 0_int64
    if (index == 0_int64) value = spectral_calls
    if (index == 1_int64) value = grid_calls
  end function
end module forecast_norm_call_bindings
