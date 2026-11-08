module runtime_grib_soil_levels_port
  !! Compute GRIB labels for four soil, water and ice layers.
  !! Input layer thicknesses are metres. Encoded bounds are centimetres,
  !! limited to 255 as in the existing generated calculation.
  use, intrinsic :: iso_c_binding
  implicit none
  private
  public :: initialize_runtime_grib_soil_levels
contains
  function initialize_runtime_grib_soil_levels(soil, water, levels) &
    bind(c, name="md2asm_initialize_runtime_grib_soil_levels_fortran") result(status)
    !! Read two contiguous four-element FP64 arrays and publish 36 int32
    !! words only after validation and calculation complete. The first
    !! twelve words are codes, then lower bounds, then upper bounds.
    !! Ice deliberately uses the water thicknesses. The caller selects
    !! nearest rounding and gradual underflow and supplies disjoint arrays.
    real(c_double), intent(in) :: soil(4), water(4)
    integer(c_int), intent(inout) :: levels(36)
    integer(c_int) :: status, local(36)
    integer(c_int), parameter :: codes(12) = [139, 170, 183, 236, 39, 40, 41, 42, 35, 36, 37, 38]
    real(c_double) :: thickness(4, 2), total, current, top, bottom
    integer(c_int64_t) :: bits
    integer :: layer, group, j, index, column
    status = 2
    thickness(:, 1) = soil
    thickness(:, 2) = water
    do layer = 1, 4
      do column = 1, 2
        bits = transfer(thickness(layer, column), bits)
        if (iand(bits, int(z'7fffffffffffffff', c_int64_t)) == 0) cycle
        if (btest(bits, 63)) return
        if (ibits(bits, 52, 11) == 2047) return
        if (thickness(layer, column) > 1000000.0_c_double) return
      end do
    end do
    do group = 1, 3
      column = 2
      if (group == 1) column = 1
      do layer = 1, 4
        total = 0.0_c_double
        do j = 1, layer
          total = total + thickness(j, column)
        end do
        current = thickness(layer, column)
        top = total - current
        top = top*100.0_c_double
        top = top + 0.1_c_double
        top = min(top, 255.0_c_double)
        bottom = total*100.0_c_double
        bottom = bottom + 0.1_c_double
        bottom = min(bottom, 255.0_c_double)
        index = (group - 1)*4 + layer
        local(index) = codes(index)
        local(12 + index) = int(bottom, c_int)
        local(24 + index) = int(top, c_int)
      end do
    end do
    levels = local
    status = 0
  end function
end module
