module md2asm_vertical_continuity
  !! Structured generated GPCTY, with initialized live layer/table extents.
  !!
  !! Wind is in m s**(-1); surface-pressure gradients in Pa m**(-1);
  !! divergence and specific mass source in s**(-1). Layer pressure is Pa;
  !! inverse full-level pressure is Pa**(-1). Coordinate weights have no unit.
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(==)
  use md2asm_vertical_operators, only: vertical_operator_matrices, apply_vertical_operator
  implicit none
  private
  public :: compute_vertical_continuity
  interface
    function platform_errno_location() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  subroutine compute_vertical_continuity(pitch, first, last, levels, finite_elements, upper_flux, &
                                         integral_bc, derivative_bc, tables, b_full, delta_b, inverse_coordinate_depth, u, v, &
                                         divergence, layer_pressure, surface_gradient_x, surface_gradient_y, inverse_pressure, &
                                         output, status, mass_source)
    !! Compute the complete source-defined five-field carrier.
    !!
    !! output has bounds(1:pitch,0:levels,1:5). Fields are EVEL,VVEL,PSDIV,
    !! PSDVBC,DIVDP. Level-zero VVEL and DIVDP and all inactive cells remain.
    !! The caller owns an output independent of consumed inputs and tables.
    !! Original byte/physics evidence covers19layers; wider live dimensions
    !! retain the same ordered method but require their own acceptance.
    integer(int32), intent(in) :: pitch, first, last, levels
    logical, intent(in) :: finite_elements, upper_flux
    integer, intent(in) :: integral_bc, derivative_bc
    type(vertical_operator_matrices), intent(in) :: tables
    real(real64), intent(in) :: b_full(:), delta_b(:), inverse_coordinate_depth(:)
    real(real64), intent(in) :: u(:, :), v(:, :), divergence(:, :), layer_pressure(:, :)
    real(real64), intent(in) :: surface_gradient_x(:), surface_gradient_y(:), inverse_pressure(:, :)
    real(real64), intent(inout) :: output(:, 0:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: mass_source(:, :)
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: wind_dot(:, :), rate(:, :), pin(:, :), integral(:, :)
    integer(c_int), pointer :: errno_value
    integer(c_int) :: saved_errno
    integer :: level, cell, allocation_status
    integer(int64) :: field_words, input_words, integral_words, total_words, offset
    real(real64) :: a, b, value, final_integral
    status = 2
    if (pitch < 1 .or. pitch > 256 .or. levels < 1 .or. levels > 512) return
    if (first < 1 .or. first > pitch .or. last < first - 1 .or. last > pitch) return
    if (.not. finite_elements .or. upper_flux .or. integral_bc /= 3) return
    if (.not. environment_ready()) return
    if (size(b_full) < levels .or. size(delta_b) < levels .or. size(inverse_coordinate_depth) < levels) return
    if (.not. valid(u) .or. .not. valid(v) .or. .not. valid(divergence) .or. .not. valid(layer_pressure)) return
    if (.not. valid(inverse_pressure)) return
    if (size(surface_gradient_x) < pitch .or. size(surface_gradient_y) < pitch) return
    if (size(output, 1) /= pitch .or. ubound(output, 2) /= levels .or. size(output, 3) /= 5) return
    if (present(mass_source)) then
      if (.not. valid(mass_source)) return
    end if
    if (.not. associated(tables%rintbf11)) return
    if (any(shape(tables%rintbf11) /= [levels + 1, levels + 2])) return
    if (any(.not. bounded(tables%rintbf11))) return
    do level = 1, levels
      if (.not. bounded(b_full(level))) return
      if (.not. nonnegative(delta_b(level))) return
      if (.not. positive(inverse_coordinate_depth(level))) return
      do cell = first, last
        if (.not. bounded(u(cell, level)) .or. .not. bounded(v(cell, level))) return
        if (.not. bounded(divergence(cell, level))) return
        if (.not. positive(layer_pressure(cell, level)) .or. .not. positive(inverse_pressure(cell, level))) return
        if (.not. bounded(surface_gradient_x(cell)) .or. .not. bounded(surface_gradient_y(cell))) return
        if (present(mass_source)) then
          if (.not. bounded(mass_source(cell, level))) return
        end if
      end do
    end do
    ! The frozen empty interval performs no parent numerical work.
    if (first > last) then
      status = 0
      return
    end if
    field_words = int(pitch, int64)*levels
    input_words = int(pitch, int64)*(levels + 2)
    integral_words = int(pitch, int64)*(levels + 1)
    total_words = 2*field_words + input_words + integral_words
    call c_f_pointer(platform_errno_location(), errno_value)
    saved_errno = errno_value
    allocate (workspace(total_words), stat=allocation_status)
    if (allocation_status /= 0) then
      errno_value = saved_errno
      status = 1
      return
    end if
    wind_dot(1:pitch, 1:levels) => workspace(1:field_words)
    rate(1:pitch, 1:levels) => workspace(field_words + 1:2*field_words)
    offset = 2*field_words
    pin(1:pitch, 0:levels + 1) => workspace(offset + 1:offset + input_words); offset = offset + input_words
    integral(1:pitch, 1:levels + 1) => workspace(offset + 1:offset + integral_words)
    do level = 1, levels
      do cell = first, last
        a = u(cell, level)*surface_gradient_x(cell)
        b = v(cell, level)*surface_gradient_y(cell)
        wind_dot(cell, level) = a + b
      end do
    end do
    do level = 1, levels
      do cell = first, last
        a = divergence(cell, level)*layer_pressure(cell, level)
        b = delta_b(level)*wind_dot(cell, level)
        value = a + b
        if (present(mass_source)) then
          a = mass_source(cell, level)*layer_pressure(cell, level)
          value = value - a
        end if
        rate(cell, level) = value
      end do
    end do
    do level = 1, levels
      do cell = first, last
        pin(cell, level) = rate(cell, level)*inverse_coordinate_depth(level)
      end do
    end do
    pin(first:last, 0) = 0.0_real64; pin(first:last, levels + 1) = 0.0_real64
    call apply_vertical_operator(tables, .true., integral_bc, derivative_bc, 'ITOP', '11', &
                                 int(pitch), int(first), int(last), int(levels), pin, integral, status)
    if (status /= 0) then
      deallocate (workspace)
      errno_value = saved_errno
      return
    end if
    do level = 1, levels
      do cell = first, last
        final_integral = integral(cell, levels + 1)
        a = b_full(level)*final_integral
        output(cell, level, 1) = a - integral(cell, level)
        a = b_full(level)*wind_dot(cell, level)
        b = -integral(cell, level)
        value = b + a
        output(cell, level, 2) = value*inverse_pressure(cell, level)
        output(cell, level, 3) = integral(cell, level)
        output(cell, level - 1, 4) = 0.0_real64
        output(cell, level, 5) = rate(cell, level)
      end do
    end do
    do cell = first, last
      output(cell, 0, 1) = 0.0_real64
      output(cell, 0, 3) = 0.0_real64
      output(cell, levels, 4) = integral(cell, levels + 1)
    end do
    deallocate (workspace)
    errno_value = saved_errno
    status = 0
  contains
    logical function valid(a)
      real(real64), intent(in) :: a(:, :)
      valid = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
  end subroutine
  elemental logical function bounded(value)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, 0_int64)
    bounded = ibits(word, 52, 11) < 1151_int64
  end function
  elemental logical function positive(value)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, 0_int64)
    positive = bounded(value) .and. .not. btest(word, 63) .and. word /= 0
  end function
  elemental logical function nonnegative(value)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, 0_int64)
    nonnegative = bounded(value) .and. (.not. btest(word, 63) .or. ibclr(word, 63) == 0)
  end function
  logical function environment_ready() result(ready)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: minimum_normal, half, subnormal
    ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (.not. (rounding == ieee_nearest)) return
    minimum_normal = tiny(0.0_real64); half = 0.5_real64
    subnormal = minimum_normal*half
    if (transfer(subnormal, 0_int64) /= ibset(0_int64, 51)) return
    ready = .true.
  end function
end module md2asm_vertical_continuity
