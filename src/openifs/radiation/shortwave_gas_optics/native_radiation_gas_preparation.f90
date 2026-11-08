!> Portable gas interpolation and molecular preparation.
!! Native arrays replace private packet layouts. The caller sets nearest-even
!! FP64 arithmetic with gradual underflow. Each operation rounds separately.
module native_radiation_gas_preparation
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  use native_absorption_records, only: shortwave_absorption_record
  use native_shortwave_gas_inputs
  implicit none
  private
  public :: interp_gas, rrtm_prepare_gases, srtm_setcoef
  interface
    function public_log(x) bind(C, name="log") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Conservatively interpolate cumulative gas amounts to model layers.
  !! Source pressure has source_layers+1 interfaces in Pa; gas profiles have
  !! shape (latitude_rows,source_layers). Model pressure is (columns,levels+1).
  !! Output mass ratios (kg/kg) change only in selected columns first:last.
  subroutine interp_gas(first, last, latitude_index, latitude_fraction, source_pressure, source_gas, model_pressure, output)
    integer(int32), intent(in) :: first, last, latitude_index(:)
    real(real64), intent(in) :: latitude_fraction(:), source_pressure(:), source_gas(:, :), model_pressure(:, :)
    real(real64), intent(inout) :: output(:, :)
    real(real64) :: cumulative(size(source_gas, 2) + 1), total, previous, p, q, f, amount, thickness
    integer :: i, k, j, source_layers, levels, latitude
    source_layers = size(source_gas, 2); levels = size(model_pressure, 2) - 1
    if (first > last .or. levels <= 0) return
    do i = first, last
      latitude = latitude_index(i)
      total = 0.0_real64
      cumulative(1) = total
      do j = 1, source_layers
        p = source_gas(latitude + 1, j) - source_gas(latitude, j)
        p = latitude_fraction(i)*p
        p = source_gas(latitude, j) + p
        total = total + p
        cumulative(j + 1) = total
      end do
      j = 1; previous = 0.0_real64
      do k = 1, levels
        p = model_pressure(i, k + 1)
        do
          if (p >= source_pressure(j)) then
            if (p < source_pressure(j + 1)) exit
          end if
          j = j + 1
          if (j > source_layers) then
            j = source_layers
            exit
          end if
        end do
        q = p - source_pressure(j)
        f = source_pressure(j + 1) - source_pressure(j)
        f = q/f
        q = cumulative(j + 1) - cumulative(j)
        q = f*q
        amount = cumulative(j) + q
        thickness = p - model_pressure(i, k)
        q = amount - previous
        output(i, k) = q/thickness
        previous = amount
      end do
    end do
  end subroutine
  !> Prepare reversed pressure, temperature and molecular columns.
  !! Inputs use full_columns and top-to-bottom levels; pressure is Pa and
  !! temperatures are K. Gas mass ratios use kg/kg. Outputs use compact selected
  !! columns and bottom-to-top levels. WKL has 35 channels and WX has 4.
  !! Dry/broad/WKL columns use molecules/cm2; WX uses scaled 1e20 columns.
  !! Boundaries PZ/TZ have lower level bound zero; pressure outputs use hPa.
  subroutine rrtm_prepare_gases(first, last, full_columns, levels, half_pressure, pressure, half_temperature, temperature, &
                                humidity, co2, ch4, n2o, ozone, c11, c12, c22, ccl4, gravity, planet_scale, &
                                dry, broad, wkl, wx, pavel, tavel, pz, tz, reflect)
    integer(int32), intent(in) :: first, last, full_columns, levels
    real(real64), intent(in) :: half_pressure(full_columns, levels + 1), pressure(full_columns, levels)
    real(real64), intent(in) :: half_temperature(full_columns, levels + 1), temperature(full_columns, levels)
    real(real64), intent(in) :: humidity(full_columns, levels), co2(full_columns, levels), ch4(full_columns, levels)
    real(real64), intent(in) :: n2o(full_columns, levels), ozone(full_columns, levels)
    real(real64),intent(in)::c11(full_columns,levels),c12(full_columns,levels),c22(full_columns,levels),ccl4(full_columns,levels)
    real(real64), intent(in) :: gravity, planet_scale
    real(real64), intent(inout) :: dry(last - first + 1, levels), broad(last - first + 1, levels)
    real(real64), intent(inout) :: wkl(last - first + 1, 35, levels), wx(last - first + 1, 4, levels)
    real(real64), intent(inout) :: pavel(last - first + 1, levels), tavel(last - first + 1, levels)
    real(real64), intent(inout) :: pz(last - first + 1, 0:levels), tz(last - first + 1, 0:levels)
    integer(int32), intent(inout) :: reflect(last - first + 1)
    real(real64), volatile :: gravity_cgs
    real(real64) :: p, q, water, molar_mass, numerator, denominator, sum_volume
    integer :: i, j, k, original_level, column, columns
    columns = last - first + 1
    if (columns <= 0) return
    gravity_cgs = gravity/planet_scale
    gravity_cgs = gravity_cgs*100.0_real64
    do i = 1, columns
      reflect(i) = 0
    end do
    do k = 1, levels
      do j = 1, 35
        do i = 1, columns
          wkl(i, j, k) = 0.0_real64
        end do
      end do
    end do
    do i = 1, columns
      column = first + i - 1
      pz(i, 0) = half_pressure(column, levels + 1)/100.0_real64
      tz(i, 0) = half_temperature(column, levels + 1)
    end do
    do k = 1, levels
      original_level = levels - k + 1
      do i = 1, columns
        column = first + i - 1
        pavel(i, k) = pressure(column, original_level)/100.0_real64
        tavel(i, k) = temperature(column, original_level)
        pz(i, k) = half_pressure(column, original_level)/100.0_real64
        tz(i, k) = half_temperature(column, original_level)
        p = humidity(column, original_level)*28.970_real64
        wkl(i, 1, k) = p/18.0154_real64
        p = co2(column, original_level)*28.970_real64
        wkl(i, 2, k) = p/44.011_real64
        p = ozone(column, original_level)*28.970_real64
        wkl(i, 3, k) = p/47.9982_real64
        p = n2o(column, original_level)*28.970_real64
        wkl(i, 4, k) = p/44.013_real64
        p = ch4(column, original_level)*28.970_real64
        wkl(i, 6, k) = p/16.043_real64
        wkl(i, 7, k) = 0.209488_real64
        water = wkl(i, 1, k)
        p = 1.0_real64 - water
        p = p*28.970_real64
        q = water*18.0154_real64
        molar_mass = p + q
        p = pz(i, k - 1) - pz(i, k)
        p = p*1000.0_real64
        numerator = p*6.02214e23_real64
        p = gravity_cgs*molar_mass
        q = 1.0_real64 + water
        denominator = p*q
        dry(i, k) = numerator/denominator
      end do
    end do
    do k = 1, levels
      do j = 1, 4
        do i = 1, columns
          wx(i, j, k) = 0.0_real64
        end do
      end do
    end do
    do k = 1, levels
      original_level = levels - k + 1
      do i = 1, columns
        column = first + i - 1
        p = ccl4(column, original_level)*28.970_real64
        wx(i, 1, k) = p/153.8230_real64
        p = c11(column, original_level)*28.970_real64
        wx(i, 2, k) = p/137.3686_real64
        p = c12(column, original_level)*28.970_real64
        wx(i, 3, k) = p/120.9140_real64
        p = c22(column, original_level)*28.970_real64
        wx(i, 4, k) = p/86.4690_real64
        do j = 1, 4
          p = dry(i, k)*wx(i, j, k)
          wx(i, j, k) = p*1.0e-20_real64
        end do
        sum_volume = 0.0_real64
        do j = 2, 7
          sum_volume = sum_volume + wkl(i, j, k)
        end do
        p = 1.0_real64 - sum_volume
        broad(i, k) = dry(i, k)*p
        do j = 1, 7
          wkl(i, j, k) = dry(i, k)*wkl(i, j, k)
        end do
      end do
    end do
  end subroutine
  !> Compute shortwave pressure, temperature, continuum and molecular factors.
  !! Pressure is hPa, temperature K, dry/WKL columns molecules/cm2.
  !! Input contains mutable native output views; its levels and solar cosine
  !! are readonly. Night cells and layer capacity beyond levels are preserved.
  subroutine srtm_setcoef(coefficients, pressure, temperature, dry, wkl, input)
    type(shortwave_absorption_record), intent(in) :: coefficients
    real(real64), intent(in) :: pressure(:, :), temperature(:, :), dry(:, :), wkl(:, :, :)
    type(shortwave_layer_inputs), intent(inout) :: input
    real(real64), parameter :: shift = transfer(int(z'3fa47ae140000000', int64), 0.0_real64)
    real(real64), parameter :: spacing = transfer(int(z'401cccccc0000000', int64), 0.0_real64)
    real(real64), parameter :: scale = transfer(int(z'3bc79ca100000000', int64), 0.0_real64)
    real(real64), parameter :: floor_value = transfer(int(z'3949f623e0000000', int64), 0.0_real64)
    real(real64), parameter :: standard_ratio = transfer(int(z'3fd2b36d6ceb87b5', int64), 0.0_real64)
    real(real64) :: log_pressure, p, q, pressure_fraction, temp_fraction, next_temp_fraction
    real(real64) :: water_ratio, density, foreign_density, coordinate, complement
    integer :: i, k, jp, jt, jt1, index, columns
    columns = size(input%solar_cosine)
    if (columns <= 0) return
    do i = 1, columns
      if (input%solar_cosine(i) > 0.0_real64) input%tropopause(i) = 0
    end do
    do k = 1, input%levels
      do i = 1, columns
        if (input%solar_cosine(i) <= 0.0_real64) cycle
        log_pressure = public_log(pressure(i, k))
        p = log_pressure + shift
        p = 5.0_real64*p
        p = 36.0_real64 - p
        jp = max(1, min(58, int(p, int32)))
        input%pressure_index(i, k) = jp
        p = coefficients%preflog(jp) - log_pressure
        pressure_fraction = 5.0_real64*p
        p = temperature(i, k) - coefficients%tref(jp)
        p = p/15.0_real64
        q = 3.0_real64 + p
        jt = max(1, min(4, int(q, int32)))
        input%temperature_index(i, k) = jt
        q = real(jt - 3, real64)
        temp_fraction = p - q
        p = temperature(i, k) - coefficients%tref(jp + 1)
        p = p/15.0_real64
        q = 3.0_real64 + p
        jt1 = max(1, min(4, int(q, int32)))
        input%next_temperature_index(i, k) = jt1
        q = real(jt1 - 3, real64)
        next_temp_fraction = p - q
        water_ratio = wkl(i, 1, k)/dry(i, k)
        p = pressure(i, k)*standard_ratio
        density = p/temperature(i, k)
        p = 1.0_real64 + water_ratio
        foreign_density = density/p
        input%foreign_factor(i, k) = foreign_density
        if (jp < 13) then
          input%tropopause(i) = input%tropopause(i) + 1
          p = 332.0_real64 - temperature(i, k)
          coordinate = p/36.0_real64
          index = max(1, min(2, int(coordinate, int32)))
          input%foreign_index(i, k) = index
          input%foreign_fraction(i, k) = coordinate - real(index, real64)
          input%self_factor(i, k) = foreign_density*water_ratio
          p = temperature(i, k) - 188.0_real64
          coordinate = p/spacing
          index = max(1, min(9, int(coordinate, int32) - 7))
          input%self_index(i, k) = index
          input%self_fraction(i, k) = coordinate - real(index + 7, real64)
        else
          input%foreign_index(i, k) = 3
          p = temperature(i, k) - 188.0_real64
          p = p/36.0_real64
          input%foreign_fraction(i, k) = p - 1.0_real64
          input%self_factor(i, k) = 0.0_real64
          input%self_fraction(i, k) = 0.0_real64
          input%self_index(i, k) = 0
        end if
        input%gas(i, k, water_column) = scale*wkl(i, 1, k)
        p = scale*wkl(i, 2, k)
        if (p == 0.0_real64) p = floor_value*dry(i, k)
        input%gas(i, k, carbon_dioxide_column) = p
        input%gas(i, k, ozone_column) = scale*wkl(i, 3, k)
        p = scale*wkl(i, 6, k)
        if (p == 0.0_real64) p = floor_value*dry(i, k)
        input%gas(i, k, methane_column) = p
        p = scale*wkl(i, 7, k)
        if (p == 0.0_real64) p = floor_value*dry(i, k)
        input%gas(i, k, oxygen_column) = p
        p = scale*dry(i, k)
        input%molecules(i, k) = p + input%gas(i, k, water_column)
        complement = 1.0_real64 - pressure_fraction
        input%fac10(i, k) = complement*temp_fraction
        p = 1.0_real64 - temp_fraction
        input%fac00(i, k) = complement*p
        input%fac11(i, k) = pressure_fraction*next_temp_fraction
        p = 1.0_real64 - next_temp_fraction
        input%fac01(i, k) = pressure_fraction*p
      end do
    end do
  end subroutine
end module
