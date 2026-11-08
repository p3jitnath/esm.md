! (C) Copyright 1989- ECMWF. Apache-2.0.
!> Update the actual TEGEN and MACC climatology owners in source order.
module forecast_monthly_aerosol_updates
  use iso_fortran_env, only: int32, int64, real64
  use yoerad, only: TERAD
  use yoecmip, only: TECMIP
  use owned_aerosol_climatology_records, only: TEAERC_TEGEN, TEAERC_MACC
  use forecast_monthly_climate_updates, only: monthly_climate_indices
  use forecast_calendar_and_monthly_fields, only: update_calendar, interpolate_monthly_field
  use forecast_aerosol_vertical_profiles, only: initialize_aerosol_record_profiles
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  implicit none
  private
  public :: update_monthly_aerosols
contains
!> Interpolate monthly optical depth, mass, pressure and volcanic fields.
!! DATE is YYYYMMDD; MINUTES is the nonnegative model offset. Vertical arrays
!! borrow the actual geometry: half arrays0:L, full/difference arrays1:L.
!! Pressure uses Pa, optical depth is dimensionless and scale heights use metres.
!! RADIATION owns its five vertical profiles; TEGEN/CAMS retain their existing
!! tables and output arrays. No allocation or original numerical call is made.
!! A later child failure retains completed source updates. Caller-established
!! arithmetic mode, disjoint owners and valid produced physical records are required.
  recursive integer(int32) function update_monthly_aerosols(date, minutes, levels, radiation, cmip, tegen, cams, &
                                  controls, reference_pressure, half_a, half_b, vc, full_a, full_b, delta_a, delta_b) result(status)
    integer(int32), intent(in) :: date, minutes, levels
    type(TERAD), intent(inout) :: radiation
    type(TECMIP), intent(in) :: cmip
    type(TEAERC_TEGEN), intent(inout) :: tegen
    type(TEAERC_MACC), intent(inout) :: cams
    type(hybrid_pressure_controls), intent(in) :: controls
    real(real64), intent(in) :: reference_pressure, half_a(0:), half_b(0:), vc(:), full_a(:), full_b(:), delta_a(:), delta_b(:)
    integer(int32) :: m1, m2, child, year, month, day, added_days, minute_of_day, new_year, new_month, new_day, month_days(12)
    integer(int32) :: vmonth1, vmonth2, year1, year2, day1, day2, longitude_count, latitude_count, level_count
    integer(int32), parameter :: fields(7) = [1, 2, 3, 4, 5, 6, 7]
    real(real64),parameter::dust_heights(12)=[1000.0_real64,1000.0_real64,2000.0_real64,2000.0_real64,2000.0_real64,3000.0_real64, &
                                           3000.0_real64, 2000.0_real64, 2000.0_real64, 2000.0_real64, 1000.0_real64, 1000.0_real64]
 real(real64),volatile::weight,w1,w2,numerator,denominator,value,left,right,latitude,lat_weight,lower_result,upper_result,difference
    real(real64) :: half(1, 0:256), full(1, 256), eta(0:256)
    integer :: i, j
    status = 2
    if (levels < 1 .or. levels > 256 .or. controls%approximate_mode /= 0) return
if(size(half_a)<levels+1.or.size(half_b)<levels+1.or.min(size(vc),size(full_a),size(full_b),size(delta_a),size(delta_b))<levels)return
    if (.not. associated(tegen%raerv) .or. .not. associated(tegen%rlatv)) return
    if (size(tegen%rlatv) /= 24 .or. size(tegen%raerv, 1) /= 24 .or. size(tegen%raerv, 3) /= 12) return
    if (tegen%isyear < lbound(tegen%raerv, 2) .or. tegen%ieyear > ubound(tegen%raerv, 2) .or. tegen%isyear > tegen%ieyear) return
    if (tegen%rlatv(1) /= 90.0_real64 .or. tegen%rlatv(24) /= -90.0_real64) return
    do j = 2, 24
      if (.not. (tegen%rlatv(j) < tegen%rlatv(j - 1))) return
    end do
    if (.not. associated(tegen%raerbc)) return
    if (any(shape(tegen%raerbc) /= [72, 46, 12])) return
    if (.not. associated(tegen%raeror)) return
    if (any(shape(tegen%raeror) /= [72, 46, 12])) return
    if (.not. associated(tegen%raersd)) return
    if (any(shape(tegen%raersd) /= [72, 46, 12])) return
    if (.not. associated(tegen%raerss)) return
    if (any(shape(tegen%raerss) /= [72, 46, 12])) return
    if (.not. associated(tegen%raersu)) return
    if (any(shape(tegen%raersu) /= [72, 46, 12])) return
    if (radiation%naermacc < 0 .or. radiation%naermacc > 1) return
    longitude_count = radiation%nmclon; latitude_count = radiation%nmclat; level_count = radiation%nmclev
    if (radiation%naermacc == 1) then
      if (longitude_count < 1 .or. longitude_count > 4096 .or. latitude_count < 1 .or. latitude_count > 4096) return
      if (.not. allocated(cams%rmacbc1) .or. .not. allocated(cams%rmaebc1)) return
 if(any(shape(cams%rmacbc1)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaebc1)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacbc2) .or. .not. allocated(cams%rmaebc2)) return
 if(any(shape(cams%rmacbc2)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaebc2)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacor1) .or. .not. allocated(cams%rmaeor1)) return
 if(any(shape(cams%rmacor1)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaeor1)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacor2) .or. .not. allocated(cams%rmaeor2)) return
 if(any(shape(cams%rmacor2)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaeor2)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacsd1) .or. .not. allocated(cams%rmaesd1)) return
 if(any(shape(cams%rmacsd1)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaesd1)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacsd2) .or. .not. allocated(cams%rmaesd2)) return
 if(any(shape(cams%rmacsd2)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaesd2)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacsd3) .or. .not. allocated(cams%rmaesd3)) return
 if(any(shape(cams%rmacsd3)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaesd3)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacss1) .or. .not. allocated(cams%rmaess1)) return
 if(any(shape(cams%rmacss1)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaess1)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacss2) .or. .not. allocated(cams%rmaess2)) return
 if(any(shape(cams%rmacss2)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaess2)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacss3) .or. .not. allocated(cams%rmaess3)) return
 if(any(shape(cams%rmacss3)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaess3)/=[longitude_count,latitude_count]))return
      if (.not. allocated(cams%rmacsu1) .or. .not. allocated(cams%rmaesu1)) return
 if(any(shape(cams%rmacsu1)/=[longitude_count,latitude_count,12]).or.any(shape(cams%rmaesu1)/=[longitude_count,latitude_count]))return
      if (radiation%laer3d) then
        if (level_count < 1 .or. level_count > 4096) return
        if (.not. associated(cams%rmacbc13d) .or. .not. allocated(cams%rmaebc13d)) return
  if(any(shape(cams%rmacbc13d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaebc13d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacbc23d) .or. .not. allocated(cams%rmaebc23d)) return
  if(any(shape(cams%rmacbc23d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaebc23d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacor13d) .or. .not. allocated(cams%rmaeor13d)) return
  if(any(shape(cams%rmacor13d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaeor13d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacor23d) .or. .not. allocated(cams%rmaeor23d)) return
  if(any(shape(cams%rmacor23d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaeor23d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacsd13d) .or. .not. allocated(cams%rmaesd13d)) return
  if(any(shape(cams%rmacsd13d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaesd13d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacsd23d) .or. .not. allocated(cams%rmaesd23d)) return
  if(any(shape(cams%rmacsd23d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaesd23d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacsd33d) .or. .not. allocated(cams%rmaesd33d)) return
  if(any(shape(cams%rmacsd33d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaesd33d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacss13d) .or. .not. allocated(cams%rmaess13d)) return
  if(any(shape(cams%rmacss13d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaess13d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacss23d) .or. .not. allocated(cams%rmaess23d)) return
  if(any(shape(cams%rmacss23d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaess23d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacss33d) .or. .not. allocated(cams%rmaess33d)) return
  if(any(shape(cams%rmacss33d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaess33d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%rmacsu13d) .or. .not. allocated(cams%rmaesu13d)) return
  if(any(shape(cams%rmacsu13d)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%rmaesu13d)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%ref_mon_aer_prs) .or. .not. allocated(cams%ref_aer_prs)) return
  if(any(shape(cams%ref_mon_aer_prs)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%ref_aer_prs)/=[longitude_count,latitude_count,level_count]))return
        if (.not. associated(cams%ref_mon_aer_dprs) .or. .not. allocated(cams%ref_aer_dprs)) return
  if(any(shape(cams%ref_mon_aer_dprs)/=[longitude_count,latitude_count,level_count,12]).or.any(shape(cams%ref_aer_dprs)/=[longitude_count,latitude_count,level_count]))return
      end if
    end if
    m1 = 0; m2 = 0
    child = monthly_climate_indices(date, minutes, m1, m2, weight)
    if (child /= 0) return
    year = date/10000; month = mod(date/100, 100); day = mod(date, 100)
    added_days = minutes/1440; minute_of_day = minutes - 1440*added_days
    call update_calendar(day, month, year, added_days, new_day, new_month, new_year, month_days, child)
    if (child /= 0) return
    if (new_day >= 16) then
      vmonth1 = new_month; vmonth2 = 1 + mod(new_month, 12)
      year1 = new_year; year2 = new_year
      if (vmonth1 == 12) year2 = new_year + 1
      day1 = 16; day2 = 16 + month_days(vmonth1)
    else
      vmonth1 = 1 + mod(new_month + 10, 12); vmonth2 = new_month
      year1 = new_year; year2 = new_year
      if (vmonth1 == 12) year1 = new_year - 1
      day1 = 16 - month_days(vmonth1); day2 = 16
    end if
    year1 = max(year1, tegen%isyear); year2 = max(year2, tegen%isyear)
    year1 = min(year1, tegen%ieyear); year2 = min(year2, tegen%ieyear)
    numerator = real(day2*1440 - (new_day*1440 + minute_of_day), real64)
    denominator = real((day2 - day1)*1440, real64)
    w1 = numerator/denominator; w2 = 1.0_real64 - w1
    if (cmip%ncmipfixyr > 0) then
      if (cmip%ncmipfixyr < lbound(tegen%raerv, 2) .or. cmip%ncmipfixyr > ubound(tegen%raerv, 2)) return
    end if
    call interpolate_monthly_field(tegen%raerbc, m1, m2, weight, tegen%rtaebc, child)
    if (child /= 0) then
      status = child; return
    end if
    call interpolate_monthly_field(tegen%raeror, m1, m2, weight, tegen%rtaeor, child)
    if (child /= 0) then
      status = child; return
    end if
    call interpolate_monthly_field(tegen%raersd, m1, m2, weight, tegen%rtaesd, child)
    if (child /= 0) then
      status = child; return
    end if
    call interpolate_monthly_field(tegen%raerss, m1, m2, weight, tegen%rtaess, child)
    if (child /= 0) then
      status = child; return
    end if
    call interpolate_monthly_field(tegen%raersu, m1, m2, weight, tegen%rtaesu, child)
    if (child /= 0) then
      status = child; return
    end if
    if (radiation%naermacc == 1) then
      if (radiation%lduseason) then
        difference = dust_heights(m1) - dust_heights(m2)
        value = weight*difference; radiation%raeshdu = dust_heights(m2) + value
        half(1, levels) = reference_pressure
        if (controls%finite_elements) then
      call compute_hybrid_pressure_one_based(controls, 1_int32, 1_int32, 1_int32, levels, half_a, half_b, half(:, :levels), child, &
 number_fields=7_int32,field_index=fields,full_a=full_a,full_b=full_b,delta_a=delta_a,delta_b=delta_b,full_pressure=full(:,:levels))
        else
      call compute_hybrid_pressure_one_based(controls, 1_int32, 1_int32, 1_int32, levels, half_a, half_b, half(:, :levels), child, &
                                  number_fields=7_int32, field_index=fields, vc=vc, delta_b=delta_b, full_pressure=full(:, :levels))
        end if
        if (child /= 0) then
          status = child; return
        end if
        do j = 0, levels
          eta(j) = half(1, j)/half(1, levels)
        end do
        call initialize_aerosol_record_profiles(levels, eta(:levels), radiation, child)
        if (child /= 0) then
          status = child; return
        end if
      end if
      if (radiation%laer3d) then
        call interpolate_monthly_field(cams%rmacbc13d, m1, m2, weight, cams%rmaebc13d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacbc23d, m1, m2, weight, cams%rmaebc23d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacor13d, m1, m2, weight, cams%rmaeor13d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacor23d, m1, m2, weight, cams%rmaeor23d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacsd13d, m1, m2, weight, cams%rmaesd13d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacsd23d, m1, m2, weight, cams%rmaesd23d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacsd33d, m1, m2, weight, cams%rmaesd33d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacss13d, m1, m2, weight, cams%rmaess13d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacss23d, m1, m2, weight, cams%rmaess23d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacss33d, m1, m2, weight, cams%rmaess33d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%rmacsu13d, m1, m2, weight, cams%rmaesu13d, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%ref_mon_aer_prs, m1, m2, weight, cams%ref_aer_prs, child)
        if (child /= 0) then
          status = child; return
        end if
        call interpolate_monthly_field(cams%ref_mon_aer_dprs, m1, m2, weight, cams%ref_aer_dprs, child)
        if (child /= 0) then
          status = child; return
        end if
      end if
      call interpolate_monthly_field(cams%rmacbc1, m1, m2, weight, cams%rmaebc1, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacbc2, m1, m2, weight, cams%rmaebc2, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacor1, m1, m2, weight, cams%rmaeor1, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacor2, m1, m2, weight, cams%rmaeor2, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacsd1, m1, m2, weight, cams%rmaesd1, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacsd2, m1, m2, weight, cams%rmaesd2, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacsd3, m1, m2, weight, cams%rmaesd3, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacss1, m1, m2, weight, cams%rmaess1, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacss2, m1, m2, weight, cams%rmaess2, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacss3, m1, m2, weight, cams%rmaess3, child)
      if (child /= 0) then
        status = child; return
      end if
      call interpolate_monthly_field(cams%rmacsu1, m1, m2, weight, cams%rmaesu1, child)
      if (child /= 0) then
        status = child; return
      end if
    end if
    if (cmip%ncmipfixyr > 0) then
      year1 = cmip%ncmipfixyr; year2 = cmip%ncmipfixyr
    end if
    do i = 1, 46
      latitude = real(i - 1, real64)*4.0_real64; latitude = 90.0_real64 - latitude
      do j = 1, 23
        if (latitude == tegen%rlatv(j)) then
          left = w1*tegen%raerv(j, year1, vmonth1)
          right = w2*tegen%raerv(j, year2, vmonth2)
          value = left + right
        elseif (latitude < tegen%rlatv(j) .and. latitude >= tegen%rlatv(j + 1)) then
          numerator = latitude - tegen%rlatv(j + 1); denominator = tegen%rlatv(j) - tegen%rlatv(j + 1)
          lat_weight = numerator/denominator
          left = w1*tegen%raerv(j, year1, vmonth1); right = w2*tegen%raerv(j, year2, vmonth2); lower_result = left + right
          left = w1*tegen%raerv(j + 1, year1, vmonth1); right = w2*tegen%raerv(j + 1, year2, vmonth2); upper_result = left + right
          difference = upper_result - lower_result; difference = lat_weight*difference; value = upper_result - difference
        end if
      end do
      tegen%rtaevo(i) = value
    end do
    tegen%repaer = 1.0e-12_real64
    status = 0
  end function
end module
