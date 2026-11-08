!> Tabulated thermal emission with explicit readonly coefficient inputs.
!! The caller supplies the produced Planck table and band maps. This module
!! imports no original model table or numerical routine. Temperatures use K;
!! returned spectral emission has units W/m2.
module native_radiation_planck_emission
  use iso_fortran_env, only: real64, int32, int64
  implicit none
  private
  public :: planck_function_atmos, planck_function_surf
  public :: tabulated_planck_function_atmos, tabulated_planck_function_surf
contains
  !> Select adjacent rows of the 181-row table without changing temperature.
  subroutine temperature_rows(temperature, row, fraction)
    real(real64), intent(in) :: temperature
    integer, intent(out) :: row
    real(real64), intent(out) :: fraction
    real(real64) :: shifted, integral
    if (temperature >= 339.0_real64) then
      row = 180
      fraction = temperature - 339.0_real64
    elseif (temperature < 160.0_real64) then
      row = 1
      fraction = 0.0_real64
    else
      shifted = temperature - 159.0_real64
      row = int(shifted, int32)
      integral = real(int(temperature, int32), real64)
      fraction = temperature - integral
    end if
  end subroutine
  !> Compute the runtime source conversion, keeping its multiplication rounding.
  function source_conversion() result(factor)
    real(real64) :: factor
    real(real64), volatile :: half_pi, conversion
    half_pi = transfer(int(z'3ff921fb54442d18', int64), 0.0_real64)
    conversion = 10000.0_real64
    factor = half_pi*2.0_real64
    factor = factor*conversion
  end function
  !> Compute atmospheric emission in the standalone source's level-first order.
  !! Temperature is a native (all_columns,0:levels) view. The selected columns
  !! are first:last. Fraction has shape (selected_columns,140,levels).
  !! Maps have ng cells; table is (181,nband), width has nband cells.
  !! Model value 3 uses reordered_map; other values use each sample directly.
  !! Output shape is (ng,0:levels,selected_columns), written completely.
  subroutine planck_function_atmos(levels, first, last, ng, model, band_map, reordered_map, &
                                   temperature, fraction, table, width, emission)
    integer(int32), intent(in) :: levels, first, last, ng, model
    integer(int32), intent(in) :: band_map(:), reordered_map(:)
    real(real64), intent(in) :: temperature(:, 0:), fraction(last - first + 1, 140, levels)
    real(real64), intent(in) :: table(:, :), width(:)
    real(real64), intent(inout) :: emission(ng, 0:levels, last - first + 1)
    integer :: k, i, j, band, sample, row, layer, ncol
    real(real64) :: delta, factor, p, q
    ncol = last - first + 1
    if (ncol <= 0 .or. ng <= 0) return
    factor = source_conversion()
    do k = 0, levels
      layer = levels - k + 1
      if (k == 0) layer = levels
      do i = 1, ncol
        call temperature_rows(temperature(first + i - 1, k), row, delta)
        do j = 1, ng
          band = band_map(j)
          sample = j
          if (model == 3) sample = reordered_map(j)
          p = factor*width(band)
          q = table(row + 1, band) - table(row, band)
          q = delta*q
          q = table(row, band) + q
          p = p*q
          emission(j, k, i) = p*fraction(i, sample, layer)
        end do
      end do
    end do
  end subroutine
  !> Compute surface emission, with all bands evaluated before spectral mapping.
  !! Temperature is a readonly native vector; selected columns are first:last.
  !! Fraction has shape (selected_columns,140); output is (ng,selected_columns).
  !! Readonly table shape is (181,nband), and maps contain ng one-based indices.
  subroutine planck_function_surf(first, last, ng, nband, model, band_map, reordered_map, &
                                  temperature, fraction, table, width, emission)
    integer(int32), intent(in) :: first, last, ng, nband, model
    integer(int32), intent(in) :: band_map(:), reordered_map(:)
    real(real64), intent(in) :: temperature(:), fraction(last - first + 1, 140), table(:, :), width(:)
    real(real64), intent(inout) :: emission(ng, last - first + 1)
    real(real64) :: bands(nband), delta, factor, p, q
    integer :: i, j, b, row, sample, ncol
    ncol = last - first + 1
    if (ncol <= 0) return
    factor = source_conversion()
    do i = 1, ncol
      call temperature_rows(temperature(first + i - 1), row, delta)
      do b = 1, nband
        p = factor*width(b)
        q = table(row + 1, b) - table(row, b)
        q = delta*q
        q = table(row, b) + q
        bands(b) = p*q
      end do
      do j = 1, ng
        sample = j
        if (model == 3) sample = reordered_map(j)
        emission(j, i) = bands(band_map(j))*fraction(i, sample)
      end do
    end do
  end subroutine
  !> Compute the combined-source atmospheric entry in column-first order.
  !! Shapes, units and mutation match planck_function_atmos. Every band is
  !! evaluated for each temperature before the sample loop, as in that source.
  subroutine tabulated_planck_function_atmos(levels, first, last, ng, nband, model, band_map, reordered_map, &
                                             temperature, fraction, table, width, emission)
    integer(int32), intent(in) :: levels, first, last, ng, nband, model
    integer(int32), intent(in) :: band_map(:), reordered_map(:)
    real(real64), intent(in) :: temperature(:, 0:), fraction(last - first + 1, 140, levels), table(:, :), width(:)
    real(real64), intent(inout) :: emission(ng, 0:levels, last - first + 1)
    real(real64) :: bands(nband), delta, p, q
    real(real64), parameter :: factor = transfer(int(z'40deadfb4c5d390c', int64), 0.0_real64)
    integer :: i, k, b, j, row, sample, layer, ncol
    ncol = last - first + 1
    if (ncol <= 0 .or. ng <= 0) return
    do i = 1, ncol
      do k = 0, levels
        call temperature_rows(temperature(first + i - 1, k), row, delta)
        do b = 1, nband
          p = table(row + 1, b) - table(row, b)
          p = delta*p
          p = table(row, b) + p
          q = factor*width(b)
          bands(b) = q*p
        end do
        layer = levels - max(1, k) + 1
        do j = 1, ng
          sample = j
          if (model == 3) sample = reordered_map(j)
          emission(j, k, i) = bands(band_map(j))*fraction(i, sample, layer)
        end do
      end do
    end do
  end subroutine
  !> Compute the combined-source surface entry from explicit readonly tables.
  !! Fraction is (selected_columns,140); output is (ng,selected_columns).
  !! Its precomputed conversion is the exact bit pattern in the combined source.
  subroutine tabulated_planck_function_surf(first, last, ng, nband, model, band_map, reordered_map, &
                                            temperature, fraction, table, width, emission)
    integer(int32), intent(in) :: first, last, ng, nband, model
    integer(int32), intent(in) :: band_map(:), reordered_map(:)
    real(real64), intent(in) :: temperature(:), fraction(last - first + 1, 140), table(:, :), width(:)
    real(real64), intent(inout) :: emission(ng, last - first + 1)
    real(real64) :: bands(nband), delta, p, q
    real(real64), parameter :: factor = transfer(int(z'40deadfb4c5d390c', int64), 0.0_real64)
    integer :: i, b, j, row, sample, ncol
    ncol = last - first + 1
    if (ncol <= 0 .or. ng <= 0) return
    do i = 1, ncol
      call temperature_rows(temperature(first + i - 1), row, delta)
      do b = 1, nband
        p = table(row + 1, b) - table(row, b)
        p = delta*p
        p = table(row, b) + p
        q = factor*width(b)
        bands(b) = q*p
      end do
      do j = 1, ng
        sample = j
        if (model == 3) sample = reordered_map(j)
        emission(j, i) = bands(band_map(j))*fraction(i, sample)
      end do
    end do
  end subroutine
end module
