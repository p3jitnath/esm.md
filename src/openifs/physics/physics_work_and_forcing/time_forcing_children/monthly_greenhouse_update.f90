! (C) Copyright 1989- ECMWF. Apache-2.0.
!> Interpolate the actual owned greenhouse climatology at the model time.
!! Numerical statements follow original UPD_GHGCLIM. No original methods or globals
!! are called. Monthly tables and pressure coordinates remain with the radiation owner.
module forecast_monthly_climate_updates
  use iso_fortran_env, only: int32, int64, real64
  use yoerad, only: TERAD
  use yoerdi, only: TERDI
  use physical_constant_setup_port, only: forecast_physical_constants
  use native_radiation_climate_records, only: radiation_climate_context
  implicit none
  private
  public :: monthly_climate_indices, update_monthly_greenhouse
  real(real64),parameter::day_offsets(12)=[31.0_real64,59.25_real64,90.25_real64,120.25_real64,151.25_real64,181.25_real64, &
                                           212.25_real64, 243.25_real64, 273.25_real64, 304.25_real64, 334.25_real64, 365.25_real64]
real(real64),parameter::midpoints(12)=[22320.0_real64,64980.0_real64,107640.0_real64,151560.0_real64,195480.0_real64,239400.0_real64, &
                               283320.0_real64, 327960.0_real64, 371880.0_real64, 415800.0_real64, 459720.0_real64, 503640.0_real64]
contains
!> Return the source two monthly indices and first-month weight.
!! DATE is YYYYMMDD and MINUTES is the nonnegative model offset. Integer indices
!! are dimensionless. Outputs change only on success. Calendar years1901:2099
!! and offsets up to5259600minutes are supported.
  integer(int32) function monthly_climate_indices(date, minutes, month1, month2, weight) result(status)
    integer(int32), intent(in) :: date, minutes
    integer(int32), intent(inout) :: month1, month2
    real(real64), intent(inout) :: weight
    integer(int32) :: year, month, day, days, m1, m2, j
    integer(int32), parameter :: month_days(12) = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    real(real64), volatile :: time, value, numerator, denominator, w
    status = 2
    year = date/10000; month = mod(date/100, 100); day = mod(date, 100)
    if (year < 1901 .or. year > 2099 .or. month < 1 .or. month > 12) return
    days = month_days(month)
    if (month == 2 .and. mod(year, 4) == 0) days = 29
    if (day < 1 .or. day > days .or. minutes < 0 .or. minutes > 5259600) return
    day = day - 1
    if (month == 1) then
      time = real(day, real64)*1440.0_real64; time = time + real(minutes, real64)
    elseif (month == 2) then
      if (day == 28) day = day - 1
      time = real(day, real64)*1452.8571_real64
      time = 44640.0_real64 + time; time = time + real(minutes, real64)
    else
      time = day_offsets(month - 1) + real(day, real64)
      time = time*1440.0_real64; time = time + real(minutes, real64)
    end if
    time = mod(time, 525960.0_real64)
    m1 = 0; m2 = 0
    if (time <= midpoints(1)) then
      m1 = 12; m2 = 1; numerator = midpoints(1) - time; w = numerator/44640.0_real64
    elseif (time > midpoints(12)) then
      m1 = 12; m2 = 1; numerator = 548280.0_real64 - time; w = numerator/44640.0_real64
    else
      do j = 1, 11
        if (time > midpoints(j) .and. time <= midpoints(j + 1)) then
          m1 = j; m2 = j + 1; numerator = time - midpoints(m2); denominator = midpoints(m1) - midpoints(m2); w = numerator/denominator
        end if
      end do
      if (m1 == 0 .or. m2 == 0) return
    end if
    month1 = m1; month2 = m2; weight = w; status = 0
  end function
!> Update only enabled gas mass owners in the source species order.
!! Half pressures use Pa and bounds0:N. Gas volume ratios are dimensionless;
!! MASS contains mixing ratio times pressure depth in Pa. CONSTANTS holds
!! molar masses in grams/mole. No allocation or alias creation occurs.
  integer(int32) function update_monthly_greenhouse(date, minutes, radiation, gases, constants, climate) result(status)
    integer(int32), intent(in) :: date, minutes
    type(TERAD), intent(in) :: radiation
    type(TERDI), intent(in) :: gases
    type(forecast_physical_constants), intent(in) :: constants
    type(radiation_climate_context), intent(inout) :: climate
    integer(int32) :: ngas, n, lat, m1, m2, child
    real(real64), volatile :: weight, scaling
    status = 2
    ngas = radiation%nghgrad
    if (ngas < 0 .or. ngas > 21) return
    n = climate%radiation%npressure; lat = climate%radiation%nlatitude
    if (n < 1 .or. n > 4096 .or. lat < 1 .or. lat > 4096) return
    if (n /= climate%climatology%npressure .or. lat /= climate%climatology%nlatitude) return
    if (.not. allocated(climate%radiation%pressure_hl)) return
    if (lbound(climate%radiation%pressure_hl, 1) /= 0 .or. ubound(climate%radiation%pressure_hl, 1) /= n) return
    if (ngas == 1 .or. ngas >= 10) then
      if (.not. allocated(climate%climatology%vmr_co2) .or. .not. allocated(climate%radiation%mass_co2)) return
      if (any(shape(climate%climatology%vmr_co2) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_co2) /= [lat, n])) return
    end if
    if (ngas == 2 .or. ngas >= 11) then
      if (.not. allocated(climate%climatology%vmr_ch4) .or. .not. allocated(climate%radiation%mass_ch4)) return
      if (any(shape(climate%climatology%vmr_ch4) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_ch4) /= [lat, n])) return
    end if
    if (ngas == 3 .or. ngas >= 12) then
      if (.not. allocated(climate%climatology%vmr_n2o) .or. .not. allocated(climate%radiation%mass_n2o)) return
      if (any(shape(climate%climatology%vmr_n2o) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_n2o) /= [lat, n])) return
    end if
    if (ngas == 4 .or. ngas >= 20) then
      if (.not. allocated(climate%climatology%vmr_no2) .or. .not. allocated(climate%radiation%mass_no2)) return
      if (any(shape(climate%climatology%vmr_no2) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_no2) /= [lat, n])) return
    end if
    if (ngas == 5 .or. ngas >= 15) then
      if (.not. allocated(climate%climatology%vmr_cfc11) .or. .not. allocated(climate%radiation%mass_cfc11)) return
     if (any(shape(climate%climatology%vmr_cfc11) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_cfc11) /= [lat, n])) return
    end if
    if (ngas == 6 .or. ngas >= 16) then
      if (.not. allocated(climate%climatology%vmr_cfc12) .or. .not. allocated(climate%radiation%mass_cfc12)) return
     if (any(shape(climate%climatology%vmr_cfc12) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_cfc12) /= [lat, n])) return
    end if
    if (ngas == 7 .or. ngas == 17 .or. ngas >= 21) then
      if (.not. allocated(climate%climatology%vmr_o3) .or. .not. allocated(climate%radiation%mass_o3)) return
      if (any(shape(climate%climatology%vmr_o3) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_o3) /= [lat, n])) return
    end if
    if (ngas == 8 .or. ngas >= 18) then
      if (.not. allocated(climate%climatology%vmr_hcfc22) .or. .not. allocated(climate%radiation%mass_hcfc22)) return
   if (any(shape(climate%climatology%vmr_hcfc22) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_hcfc22) /= [lat, n])) return
    end if
    if (ngas == 9 .or. ngas >= 19) then
      if (.not. allocated(climate%climatology%vmr_ccl4) .or. .not. allocated(climate%radiation%mass_ccl4)) return
      if (any(shape(climate%climatology%vmr_ccl4) /= [lat, n, 12]) .or. any(shape(climate%radiation%mass_ccl4) /= [lat, n])) return
    end if
    m1 = 0; m2 = 0
    child = monthly_climate_indices(date, minutes, m1, m2, weight)
    if (child /= 0) return
    if (ngas == 1 .or. ngas >= 10) then
      scaling = gases%rcardi/climate%climatology%surf_mean_co2
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_co2,climate%radiation%mass_co2)
    end if
    if (ngas == 2 .or. ngas >= 11) then
      scaling = gases%rch4/climate%climatology%surf_mean_ch4
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_ch4,climate%radiation%mass_ch4)
    end if
    if (ngas == 3 .or. ngas >= 12) then
      scaling = gases%rn2o/climate%climatology%surf_mean_n2o
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_n2o,climate%radiation%mass_n2o)
    end if
    if (ngas == 4 .or. ngas >= 20) then
      scaling = constants%rmno2/constants%rmd
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_no2,climate%radiation%mass_no2)
    end if
    if (ngas == 5 .or. ngas >= 15) then
      scaling = gases%rcfc11/climate%climatology%surf_mean_cfc11
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_cfc11,climate%radiation%mass_cfc11)
    end if
    if (ngas == 6 .or. ngas >= 16) then
      scaling = gases%rcfc12/climate%climatology%surf_mean_cfc12
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_cfc12,climate%radiation%mass_cfc12)
    end if
    if (ngas == 7 .or. ngas == 17 .or. ngas >= 21) then
      scaling = constants%rmo3/constants%rmd
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_o3,climate%radiation%mass_o3)
    end if
    if (ngas == 8 .or. ngas >= 18) then
      scaling = gases%rcfc22/climate%climatology%surf_mean_hcfc22
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_hcfc22,climate%radiation%mass_hcfc22)
    end if
    if (ngas == 9 .or. ngas >= 19) then
      scaling = gases%rccl4/climate%climatology%surf_mean_ccl4
 call interpolate_gas_layer_mass(m1,m2,weight,climate%radiation%pressure_hl,scaling,climate%climatology%vmr_ccl4,climate%radiation%mass_ccl4)
    end if
    status = 0
  end function
  recursive subroutine interpolate_gas_layer_mass(month1, month2, weight, pressure, scaling, mixing_ratio, mass)
    integer(int32), intent(in) :: month1, month2
    real(real64), intent(in) :: weight, pressure(0:), scaling, mixing_ratio(:, :, :)
    real(real64), intent(inout) :: mass(:, :)
    real(real64), volatile :: layer_scale, difference, weighted, interpolated
    integer :: level, latitude
    do level = 1, ubound(pressure, 1)
      layer_scale = pressure(level) - pressure(level - 1)
      layer_scale = layer_scale*scaling
      do latitude = 1, size(mass, 1)
        difference = mixing_ratio(latitude, level, month1) - mixing_ratio(latitude, level, month2)
        weighted = weight*difference
        interpolated = mixing_ratio(latitude, level, month2) + weighted
        mass(latitude, level) = layer_scale*interpolated
      end do
    end do
  end subroutine
end module
