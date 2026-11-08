!> Publish a live source-produced step through two distinct native clocks.
module operational_step_clock_publication_port
  use iso_c_binding, only: c_int, c_int32_t, c_int64_t, c_intptr_t, c_double, c_loc, c_sizeof, c_ptr, c_size_t, c_null_ptr
  use forecast_model_clock_port, only: forecast_clock
  use forecast_controls_state_types, only: native_forecast_controls_state
  implicit none
  private
  public :: publish_operational_convection_step, publish_live_convection_step
  interface
    function compare_native_clock_bytes(left, right, bytes) bind(c, name='memcmp') result(order)
      import c_ptr, c_size_t, c_int
      type(c_ptr), value :: left, right
      integer(c_size_t), value :: bytes
      integer(c_int) :: order
    end function
  end interface
contains
  !> Retain the selected eight-step, 450-second publication guard.
  !! CONTROLS is the actual root owner INOUT; CONVECTION_CLOCK is a distinct
  !! native clock INOUT. CURRENT_STEP is readonly int32 and MODEL_DT is
  !! readonly FP64 seconds. Only the two named CURRENT_STEP members change.
  !! The remaining complete native clock representation must agree.
  !! Arguments have separate storage and valid caller-owned lifetimes.
  !! Return 0 succeeds; return 2 is atomic. Caller establishes IEEE modes once.
  integer(c_int) function publish_operational_convection_step(controls, convection_clock, &
                                                              current_step, model_dt) result(status)
    type(native_forecast_controls_state), intent(inout), target :: controls
    type(forecast_clock), intent(inout), target :: convection_clock
    integer(c_int32_t), intent(in), target :: current_step
    real(c_double), intent(in), target :: model_dt
    status = publish_step_common(controls, convection_clock, current_step, model_dt, .true.)
  end function

  !> Publish within an already produced positive live stop count.
  !! Argument types, units, ownership and mutation match the selected entry.
  !! NCONF is1; all three source timestep words are exactly450 seconds.
  !! The caller supplies the canonical root clock, including its produced
  !! TOTAL_STEPS in1:576. CURRENT_STEP is in0:TOTAL_STEPS. This performs no
  !! stop or calendar arithmetic. The actual t02/two-step cohort and the
  !! historical h1/eight-step cohort need separate independent qualification.
  !! Return 0 succeeds; return 2 leaves both owners unchanged.
  integer(c_int) function publish_live_convection_step(controls, convection_clock, &
                                                       current_step, model_dt) result(status)
    type(native_forecast_controls_state), intent(inout), target :: controls
    type(forecast_clock), intent(inout), target :: convection_clock
    integer(c_int32_t), intent(in), target :: current_step
    real(c_double), intent(in), target :: model_dt
    status = publish_step_common(controls, convection_clock, current_step, model_dt, .false.)
  end function

  !> Compare compiler-native spans, then keep the two source stores in order.
  !! The skipped member span comes from C_LOC and STORAGE_SIZE of CURRENT_STEP.
  !! Public memcmp observes bytes without TRANSFER array allocation or FP work.
  integer(c_int) function publish_step_common(controls, convection_clock, &
                                              current_step, model_dt, selected) result(status)
    type(native_forecast_controls_state), intent(inout), target :: controls
    type(forecast_clock), intent(inout), target :: convection_clock
    integer(c_int32_t), intent(in), target :: current_step
    real(c_double), intent(in), target :: model_dt
    logical, intent(in) :: selected
    integer(c_intptr_t) :: addresses(4), step_offset, suffix_root, suffix_convection
    integer(c_int64_t) :: lengths(4), step_bytes
    integer :: j, k
    status = 2_c_int
    addresses = [transfer(c_loc(controls), 0_c_intptr_t), &
                 transfer(c_loc(convection_clock), 0_c_intptr_t), transfer(c_loc(current_step), 0_c_intptr_t), &
                 transfer(c_loc(model_dt), 0_c_intptr_t)]
    lengths = [storage_size(controls, kind=c_int64_t)/8_c_int64_t, &
               storage_size(convection_clock, kind=c_int64_t)/8_c_int64_t, &
               storage_size(current_step, kind=c_int64_t)/8_c_int64_t, &
               storage_size(model_dt, kind=c_int64_t)/8_c_int64_t]
    do j = 1, 2
      do k = j + 1, 4
        if (.not. disjoint(addresses(j), lengths(j), addresses(k), lengths(k))) return
      end do
    end do
    if (controls%namespace%nconf /= 1_c_int32_t) return
    if (selected) then
      if (controls%clock%total_steps /= 8_c_int) return
    else
      if (controls%clock%total_steps < 1_c_int .or. controls%clock%total_steps > 576_c_int) return
    end if
    if (transfer(controls%clock_input%dt, 0_c_int64_t) /= int(z'407C200000000000', c_int64_t)) return
    if (transfer(model_dt, 0_c_int64_t) /= int(z'407C200000000000', c_int64_t)) return
    if (transfer(convection_clock%dt, 0_c_int64_t) /= int(z'407C200000000000', c_int64_t)) return
    if (current_step < 0_c_int32_t .or. current_step > controls%clock%total_steps) return
    ! Derive the skipped native member span from this compiler's own type.
    step_offset = transfer(c_loc(controls%clock%current_step), 0_c_intptr_t) - &
                  transfer(c_loc(controls%clock), 0_c_intptr_t)
    step_bytes = storage_size(controls%clock%current_step, kind=c_int64_t)/8_c_int64_t
    if (compare_native_clock_bytes(c_loc(controls%clock), c_loc(convection_clock), &
                                   int(step_offset, c_size_t)) /= 0_c_int) return
    suffix_root = transfer(c_loc(controls%clock%current_step), 0_c_intptr_t) + int(step_bytes, c_intptr_t)
    suffix_convection = transfer(c_loc(convection_clock%current_step), 0_c_intptr_t) + int(step_bytes, c_intptr_t)
    if (compare_native_clock_bytes(transfer(suffix_root, c_null_ptr), &
                                   transfer(suffix_convection, c_null_ptr), c_sizeof(convection_clock) - &
                                   int(step_offset, c_size_t) - int(step_bytes, c_size_t)) /= 0_c_int) return
    controls%clock%current_step = current_step
    convection_clock%current_step = current_step
    status = 0_c_int
  end function

  !> Check separate complete native storage without reading its payload.
  pure logical function disjoint(left, left_bytes, right, right_bytes) result(valid)
    integer(c_intptr_t), intent(in) :: left, right
    integer(c_int64_t), intent(in) :: left_bytes, right_bytes
    valid = .false.
    if (left < 0_c_intptr_t .or. right < 0_c_intptr_t .or. left_bytes < 0_c_int64_t .or. right_bytes < 0_c_int64_t) return
    if (left > huge(left) - left_bytes .or. right > huge(right) - right_bytes) return
    valid = left + left_bytes <= right .or. right + right_bytes <= left
  end function
end module operational_step_clock_publication_port
