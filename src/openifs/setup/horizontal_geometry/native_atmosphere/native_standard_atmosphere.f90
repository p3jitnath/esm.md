!> Construct atmosphere state from the native one-based vertical coefficients.
module forecast_native_standard_atmosphere
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use forecast_standard_atmosphere, only: atmosphere_physical_inputs, &
                                        initialize_atmosphere_layers, calculate_atmosphere_profile, adjust_postprocessing_atmosphere
  use forecast_standard_atmosphere_setup, only: standard_atmosphere_state, release_standard_atmosphere
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  implicit none
  private
  public :: initialize_standard_atmosphere_from_native_vertical
  interface
    function public_errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Preserve the source setup order without padding or rebasing layer owners.
  !! half_a/half_b have bounds0:levels; vc/full_a/full_b/delta_a/delta_b have
  !! native physical bounds1:levels. Levels is the exact size of vc.
  !! A, vc, delta_a and full_a use Pa; B coefficients are dimensionless.
  !! physical supplies gravity m/s**2, gas constant J/(kg K), planet scale and
  !! surface pressure Pa. extrapolation_height is already parsed in metres.
  !! The existing standard_atmosphere_state owns all six output arrays and both
  !! reference tables. The accepted table/profile bodies are reused unchanged.
  !! Return2 refuses before publication or reports a child admission failure.
  !! Return3 reports this constructor's allocation failure after exact cleanup.
  subroutine initialize_standard_atmosphere_from_native_vertical(state, physical, controls, &
                                          half_a, half_b, vc, full_a, full_b, delta_a, delta_b, ecmwf, extrapolation_height, status)
    type(standard_atmosphere_state), intent(inout) :: state
    type(atmosphere_physical_inputs), intent(in) :: physical
    type(hybrid_pressure_controls), intent(in) :: controls
    real(real64), intent(in) :: half_a(0:), half_b(0:), vc(1:)
    real(real64), intent(in) :: full_a(1:), full_b(1:), delta_a(1:), delta_b(1:)
    integer(int32), intent(in) :: ecmwf
    real(real64), intent(in) :: extrapolation_height
    integer(int32), intent(out) :: status
    real(real64), allocatable :: half(:, :), full(:, :)
    real(real64) :: distance, best, value
    integer :: levels, j, allocation_status
    integer(int32) :: child_status, selected
    integer(c_int), pointer, volatile :: error_value
    integer(c_int) :: incoming_error
    integer(int64) :: bits
    integer(int32), parameter :: field_index(7) = [1, 2, 3, 4, 5, 6, 7]
    status = 2
    levels = size(vc)
    if (levels < 1 .or. levels > 256) return
    if (size(half_a) /= levels + 1 .or. size(half_b) /= levels + 1) return
    if (size(full_a) /= levels .or. size(full_b) /= levels) return
    if (size(delta_a) /= levels .or. size(delta_b) /= levels) return
    if (ecmwf < 0 .or. ecmwf > 1) return
    if (controls%approximate_mode /= 0) return
    if (allocated(state%half_pressure) .or. allocated(state%full_pressure)) return
    if (allocated(state%geopotential) .or. allocated(state%temperature)) return
    if (allocated(state%density) .or. allocated(state%height)) return
    bits = transfer(extrapolation_height, bits)
    if (bits < 0_int64 .or. bits > transfer(100000.0_real64, bits)) return
    if (.not. in_range(physical%gravity, 9.0_real64, 10.0_real64)) return
    if (.not. in_range(physical%dry_gas_constant, 270.0_real64, 310.0_real64)) return
    if (.not. in_range(physical%planet_scale, 0.5_real64, 2.0_real64)) return
    if (.not. in_range(physical%surface_pressure, 90000.0_real64, 110000.0_real64)) return
    if (.not. in_range(controls%top_pressure, 0.001_real64, 1.0_real64)) return
    if (.not. in_range(controls%dry_isochoric_heat_capacity, 650.0_real64, 800.0_real64)) return
    call c_f_pointer(public_errno_location(), error_value)
    incoming_error = error_value
    allocation_status = 0
    construction: block
      allocate (state%half_pressure(0:levels), stat=allocation_status)
      if (allocation_status /= 0) exit construction
      allocate (state%full_pressure(levels), stat=allocation_status)
      if (allocation_status /= 0) exit construction
      allocate (state%geopotential(levels), stat=allocation_status)
      if (allocation_status /= 0) exit construction
      allocate (state%temperature(levels), stat=allocation_status)
      if (allocation_status /= 0) exit construction
      allocate (state%density(levels), stat=allocation_status)
      if (allocation_status /= 0) exit construction
      allocate (state%height(levels), stat=allocation_status)
      if (allocation_status /= 0) exit construction
      allocate (half(1, 0:levels), full(1, levels), stat=allocation_status)
      if (allocation_status /= 0) exit construction
      child_status = initialize_atmosphere_layers(state%reference_tables(1), physical, ecmwf)
      if (child_status /= 0) exit construction
      half(1, levels) = physical%surface_pressure
      if (controls%finite_elements) then
        call compute_hybrid_pressure_one_based(controls, 1_int32, 1_int32, 1_int32, int(levels, int32), &
                                               half_a, half_b, half, child_status, number_fields=7_int32, field_index=field_index, &
                                               full_a=full_a, full_b=full_b, delta_a=delta_a, delta_b=delta_b, full_pressure=full)
      else
        call compute_hybrid_pressure_one_based(controls, 1_int32, 1_int32, 1_int32, int(levels, int32), &
                                               half_a, half_b, half, child_status, number_fields=7_int32, field_index=field_index, &
                                               vc=vc, delta_b=delta_b, full_pressure=full)
      end if
      if (child_status /= 0) exit construction
      state%half_pressure = half(1, :)
      state%full_pressure = full(1, :)
      child_status = calculate_atmosphere_profile(state%temperature, state%geopotential, &
                                                  state%full_pressure, state%reference_tables(1), physical)
      if (child_status /= 0) exit construction
      do j = 1, levels
        state%height(j) = state%geopotential(j)/physical%gravity
        value = state%full_pressure(j)/physical%dry_gas_constant
        state%density(j) = value/state%temperature(j)
      end do
      selected = int(levels, int32)
      best = 1.0e12_real64
      do j = levels, 1, -1
        value = state%height(j) - extrapolation_height
        distance = abs(value)
        if (distance < best) selected = int(j, int32)
        best = min(best, distance)
      end do
      child_status = adjust_postprocessing_atmosphere(state%reference_tables(2), &
                                                      state%reference_tables(1), state%full_pressure, physical)
      if (child_status /= 0) exit construction
      state%extrapolation_level = selected
      status = 0
      deallocate (half, full)
      error_value = incoming_error
      return
    end block construction
    if (allocation_status /= 0) then
      status = 3
    else
      status = 2
    end if
    call release_standard_atmosphere(state)
    if (allocated(half)) deallocate (half)
    if (allocated(full)) deallocate (full)
    error_value = incoming_error
  end subroutine

  !> Classify the declared positive scalar ranges without new FP exceptions.
  logical function in_range(value, low, high)
    real(real64), intent(in) :: value, low, high
    integer(int64) :: value_bits, low_bits, high_bits
    value_bits = transfer(value, value_bits)
    low_bits = transfer(low, low_bits)
    high_bits = transfer(high, high_bits)
    in_range = value_bits >= low_bits .and. value_bits <= high_bits
  end function
end module forecast_native_standard_atmosphere
