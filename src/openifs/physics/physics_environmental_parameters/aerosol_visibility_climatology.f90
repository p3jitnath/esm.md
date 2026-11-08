!> Native RADACA aerosol and ozone layer amounts.
!! Native parameter records supply all profiles and current climate tables.
!! Pressures are Pa, temperatures K, aerosol layer masses kg/m2, and ozone
!! amounts Pa. The source surface diagnostic keeps its unresolved unit label.
module forecast_aerosol_visibility_climatology
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yoeaerd, only: teaerd
  use yoerad, only: terad
  use yoeozoc, only: teozoc
  use owned_aerosol_climatology_records, only: teaerc_tegen, teaerc_macc
  use forecast_public_scalar_math, only: power_original_rounding
  use forecast_environmental_ordered_arithmetic, only: maximum_with_finite_floor
  use md2asm_legendre_triangle, only: generate_legendre_triangle
  implicit none
  private
  public :: aerosol_visibility_climatology, runtime_aerosol_visibility_climatology
  interface
    function public_sine(x) bind(C, name="sin") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Retain the earlier coarse bounds P<=24 and L<=19.
  subroutine aerosol_visibility_climatology(aerd,rad,ozone,tegen,macc,first,last,pitch,levels,pressure,longitude,sine_latitude,cosine_longitude,sine_longitude,temperature_half,aerosol,aerosol_mass,ozone_amount,surface_diagnostic,total_depth,sea_salt_depth,dust_depth,organic_depth,black_carbon_depth,sulphate_depth,pi,gravity,status)
    type(teaerd), intent(in) :: aerd
    type(terad), intent(in) :: rad
    type(teozoc), intent(in) :: ozone
    type(teaerc_tegen), intent(in) :: tegen
    type(teaerc_macc), intent(in) :: macc
    integer(int32), intent(in) :: first, last, pitch, levels
 real(real64),intent(in) :: pressure(:,0:),longitude(:),sine_latitude(:),cosine_longitude(:),sine_longitude(:),temperature_half(:,:)
    real(real64), intent(in) :: pi, gravity
    real(real64), intent(inout) :: aerosol(:, :, :), aerosol_mass(:, :, :), ozone_amount(:, :), surface_diagnostic(:)
    real(real64),intent(inout) :: total_depth(:),sea_salt_depth(:),dust_depth(:),organic_depth(:),black_carbon_depth(:),sulphate_depth(:)
    integer(int32), intent(out) :: status
    status = 2
    if (pitch > 24 .or. levels > 19) return
    call runtime_aerosol_visibility_climatology(aerd,rad,ozone,tegen,macc,first,last,pitch,levels,pressure,longitude,sine_latitude,cosine_longitude,sine_longitude,temperature_half,aerosol,aerosol_mass,ozone_amount,surface_diagnostic,total_depth,sea_salt_depth,dust_depth,organic_depth,black_carbon_depth,sulphate_depth,pi,gravity,status)
  end subroutine

  !> Compute the selected nonvolcanic MACC route with the original call order.
  !! Supports first1,last1:P,P1:128,L1:137. Climate grids remain72x46 and120x61.
  !! Full aerosol_mass(1:P,1:L,1:12) is cleared, including inactive columns.
  !! Every other output changes only in the active interval. Records stay read-only.
  !! The caller keeps all outputs disjoint and sets the floating-point mode once.
  subroutine runtime_aerosol_visibility_climatology(aerd,rad,ozone,tegen,macc,first,last,pitch,levels,pressure,longitude,sine_latitude,cosine_longitude,sine_longitude,temperature_half,aerosol,aerosol_mass,ozone_amount,surface_diagnostic,total_depth,sea_salt_depth,dust_depth,organic_depth,black_carbon_depth,sulphate_depth,pi,gravity,status)
    type(teaerd), intent(in) :: aerd
    type(terad), intent(in) :: rad
    type(teozoc), intent(in) :: ozone
    type(teaerc_tegen), intent(in) :: tegen
    type(teaerc_macc), intent(in) :: macc
    integer(int32), intent(in) :: first, last, pitch, levels
 real(real64),intent(in) :: pressure(:,0:),longitude(:),sine_latitude(:),cosine_longitude(:),sine_longitude(:),temperature_half(:,:)
    real(real64), intent(in) :: pi, gravity
    real(real64), intent(inout) :: aerosol(:, :, :), aerosol_mass(:, :, :), ozone_amount(:, :), surface_diagnostic(:)
    real(real64),intent(inout) :: total_depth(:),sea_salt_depth(:),dust_depth(:),organic_depth(:),black_carbon_depth(:),sulphate_depth(:)
    integer(int32), intent(out) :: status
    real(real64) :: latitude_grid(61), longitude_grid(120), longitude_step, grid_step, t, a, b
   real(real64) :: climate_legacy(5,max(1,min(pitch,128))),climate_mass(11,max(1,min(pitch,128))),basis(66),fourier_coefficients(21)
    real(real64) :: ozone_q(max(1,min(pitch,128))),ozone_h(max(1,min(pitch,128))),old_pressure(max(1,min(pitch,128))),old_ozone(max(1,min(pitch,128))),old_weight(max(1,min(pitch,128)))
    real(real64) :: old_legacy(4, max(1, min(pitch, 128))), new_legacy(4), old_mass(11, max(1, min(pitch, 128))), new_mass
    real(real64), volatile :: harmonic(4, max(1, min(pitch, 128))), unused_sulphate(max(1, min(pitch, 128)))
    real(real64) :: new_pressure, root_cube, weight, mean_weight, one_minus_weight, pressure_increment
    real(real64) :: next_ozone, ratio, multiplier, legendre_value
    integer :: j, k, s, m, child_status
    integer, parameter :: legacy_profile(4) = [1, 2, 3, 4]
    integer, parameter :: mass_profile(11) = [1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5]
    integer, parameter :: mass_climate(11) = [8, 9, 10, 5, 6, 7, 3, 4, 1, 2, 11]
    status = 2
    if (pitch < 1 .or. pitch > 128 .or. levels < 1 .or. levels > 137) return
    if (first /= 1 .or. last < 1 .or. last > pitch) return
    if (rad%naermacc /= 1 .or. rad%nmclat /= 61 .or. rad%nmclon /= 120 .or. rad%nmcvar /= 12) return
    if (rad%lhvolca .or. .not. rad%lnewaer .or. rad%laeradjdu) return
    if (transfer(pi, 0_int64) /= int(z'400921fb54442d18', int64)) return
    if (.not. (gravity > 0.0_real64 .and. gravity <= huge(gravity))) return
    if (size(pressure, 1) /= pitch .or. ubound(pressure, 2) < levels) return
    if (size(temperature_half, 1) /= pitch .or. size(temperature_half, 2) < levels + 1) return
    if (min(size(longitude), size(sine_latitude), size(cosine_longitude), size(sine_longitude)) < pitch) return
    if (any(shape(aerosol) < [pitch, 6, levels]) .or. any(shape(aerosol_mass) < [pitch, levels, 12])) return
    if (size(ozone_amount, 1) /= pitch .or. size(ozone_amount, 2) < levels) return
    if(min(size(surface_diagnostic),size(total_depth),size(sea_salt_depth),size(dust_depth),size(organic_depth),size(black_carbon_depth),size(sulphate_depth))<pitch) return
    if (.not. profiles_ready(aerd, rad, levels + 1)) return
    if (.not. climate_ready(macc)) return
    if (.not. (aerd%rctrpt >= 0.0_real64 .and. aerd%rctrpt <= 64.0_real64)) return
    if (.not. (tegen%repaer >= 0.0_real64 .and. tegen%repaer <= huge(tegen%repaer))) return
    do j = first, last
      if (.not. (longitude(j) >= 0.0_real64 .and. longitude(j) < 2.0_real64*pi)) return
 if(.not.(abs(sine_latitude(j))<=1.0_real64.and.abs(cosine_longitude(j))<=1.0_real64.and.abs(sine_longitude(j))<=1.0_real64)) return
      if (.not. (pressure(j, 0) >= 0.0_real64 .and. pressure(j, 0) <= huge(t))) return
      do k = 1, levels
        if (.not. (pressure(j, k) > pressure(j, k - 1) .and. pressure(j, k) <= huge(t))) return
      end do
      do k = 1, levels + 1
        if (.not. (temperature_half(j, k) > 0.0_real64 .and. temperature_half(j, k) <= huge(t))) return
      end do
    end do
    aerosol_mass(1:pitch, 1:levels, 1:12) = 0.0_real64
    grid_step = 180.0_real64/45.0_real64
    do k = 1, 46
      t = real(k - 1, real64)*grid_step; t = 90.0_real64 - t
      t = t*pi; t = t/180.0_real64; latitude_grid(k) = public_sine(t)
    end do
    longitude_step = pi + pi; longitude_step = longitude_step/72.0_real64
    do k = 1, 72
      longitude_grid(k) = real(k - 1, real64)*longitude_step
    end do
    do j = first, last
      climate_legacy(1,j)=interpolate_climate(tegen%rtaebc,latitude_grid(1:46),longitude_grid(1:72),longitude_step,sine_latitude(j),longitude(j))
      climate_legacy(2,j)=interpolate_climate(tegen%rtaeor,latitude_grid(1:46),longitude_grid(1:72),longitude_step,sine_latitude(j),longitude(j))
      climate_legacy(3,j)=interpolate_climate(tegen%rtaesd,latitude_grid(1:46),longitude_grid(1:72),longitude_step,sine_latitude(j),longitude(j))
      climate_legacy(4,j)=interpolate_climate(tegen%rtaess,latitude_grid(1:46),longitude_grid(1:72),longitude_step,sine_latitude(j),longitude(j))
      climate_legacy(5,j)=interpolate_climate(tegen%rtaesu,latitude_grid(1:46),longitude_grid(1:72),longitude_step,sine_latitude(j),longitude(j))
    end do
    grid_step = 180.0_real64/60.0_real64
    do k = 1, 61
      t = real(k - 1, real64)*grid_step; t = 90.0_real64 - t
      t = t*pi; t = t/180.0_real64; latitude_grid(k) = public_sine(t)
    end do
    longitude_step = pi + pi; longitude_step = longitude_step/120.0_real64
    do k = 1, 120
      longitude_grid(k) = real(k - 1, real64)*longitude_step
    end do
    do j = first, last
      climate_mass(1,j)=interpolate_climate(macc%rmaebc1,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(2,j)=interpolate_climate(macc%rmaebc2,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(3,j)=interpolate_climate(macc%rmaeor1,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(4,j)=interpolate_climate(macc%rmaeor2,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(5,j)=interpolate_climate(macc%rmaesd1,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(6,j)=interpolate_climate(macc%rmaesd2,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(7,j)=interpolate_climate(macc%rmaesd3,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(8,j)=interpolate_climate(macc%rmaess1,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(9,j)=interpolate_climate(macc%rmaess2,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(10,j)=interpolate_climate(macc%rmaess3,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
      climate_mass(11,j)=interpolate_climate(macc%rmaesu1,latitude_grid,longitude_grid,longitude_step,sine_latitude(j),longitude(j))
    end do
    do j = first, last
      call generate_legendre_triangle(sine_latitude(j), 6_int32, basis, child_status)
      if (child_status /= 0) then
        status = 3; return
      end if
      call transform_harmonics(basis, ozone%cozqc, ozone%cozqs, 6, fourier_coefficients)
      ozone_q(j) = evaluate_fourier(fourier_coefficients, 6, cosine_longitude(j), sine_longitude(j))
      call transform_harmonics(basis, ozone%cozhc, ozone%cozhs, 6, fourier_coefficients)
      t = evaluate_fourier(fourier_coefficients, 6, cosine_longitude(j), sine_longitude(j))
      t = sqrt(t); a = t*t; ozone_h(j) = a*t
    end do
    do j = first, last
      call generate_legendre_triangle(sine_latitude(j), 11_int32, basis, child_status)
      if (child_status /= 0) then
        status = 3; return
      end if
      call transform_harmonics(basis, aerd%raesc, aerd%raess, 11, fourier_coefficients)
      harmonic(1, j) = evaluate_fourier(fourier_coefficients, 11, cosine_longitude(j), sine_longitude(j))
      call transform_harmonics(basis, aerd%raelc, aerd%raels, 11, fourier_coefficients)
      harmonic(2, j) = evaluate_fourier(fourier_coefficients, 11, cosine_longitude(j), sine_longitude(j))
      call transform_harmonics(basis, aerd%raeuc, aerd%raeus, 11, fourier_coefficients)
      harmonic(3, j) = evaluate_fourier(fourier_coefficients, 11, cosine_longitude(j), sine_longitude(j))
      call transform_harmonics(basis, aerd%raedc, aerd%raeds, 11, fourier_coefficients)
      harmonic(4, j) = evaluate_fourier(fourier_coefficients, 11, cosine_longitude(j), sine_longitude(j))
    end do
    do j = first, last
      old_pressure(j) = pressure(j, 0)
      t = old_pressure(j)*old_pressure(j); t = t*old_pressure(j); t = sqrt(t)
      a = ozone_q(j)*t; b = t + ozone_h(j); old_ozone(j) = a/b
      old_weight(j) = 1.0_real64
      old_legacy(1, j) = climate_legacy(4, j)*aerd%cvdaes(1)
      a = climate_legacy(2, j) + climate_legacy(5, j)
      old_legacy(2, j) = a*aerd%cvdael(1)
      old_legacy(3, j) = climate_legacy(1, j)*aerd%cvdaeu(1)
      old_legacy(4, j) = climate_legacy(3, j)*aerd%cvdaed(1)
      unused_sulphate(j) = climate_legacy(5, j)*aerd%cvdael(1)
      sea_salt_depth(j) = climate_legacy(4, j); dust_depth(j) = climate_legacy(3, j)
      organic_depth(j) = climate_legacy(2, j); black_carbon_depth(j) = climate_legacy(1, j)
      sulphate_depth(j) = climate_legacy(5, j)
      t = climate_legacy(4, j) + climate_legacy(3, j); t = t + climate_legacy(2, j)
      t = t + climate_legacy(1, j); total_depth(j) = t + climate_legacy(5, j)
      do s = 1, 11
        old_mass(s, j) = climate_mass(mass_climate(s), j)*mass_vertical_profile(rad, mass_profile(s), 1)
      end do
    end do
    do k = 1, levels
      do j = first, last
        ratio = temperature_half(j, k)/temperature_half(j, k + 1)
        new_pressure = pressure(j, k)
        t = new_pressure*new_pressure; t = t*new_pressure; root_cube = sqrt(t)
        t = new_pressure + old_pressure(j); t = t*0.5_real64
        if (t < 999.0_real64) then
          weight = 1.0_real64; old_weight(j) = 1.0_real64
        else
          t = min(1.0_real64, ratio)
          t = power_original_rounding(t, aerd%rctrpt)
          weight = old_weight(j)*t
        end if
        t = weight*old_weight(j); mean_weight = sqrt(t)
        one_minus_weight = 1.0_real64 - mean_weight
        pressure_increment = new_pressure - old_pressure(j)
        unused_sulphate(j) = climate_legacy(5, j)*aerd%cvdael(k + 1)
        new_legacy(1) = climate_legacy(4, j)*aerd%cvdaes(k + 1)
        a = climate_legacy(2, j) + climate_legacy(5, j)
        new_legacy(2) = a*aerd%cvdael(k + 1)
        new_legacy(3) = climate_legacy(1, j)*aerd%cvdaeu(k + 1)
        new_legacy(4) = climate_legacy(3, j)*aerd%cvdaed(k + 1)
        t = aerd%rctrbga*pressure_increment; t = t + new_legacy(2); t = t - old_legacy(2, j)
        aerosol(j, 1, k) = one_minus_weight*t
        t = new_legacy(1) - old_legacy(1, j); aerosol(j, 2, k) = one_minus_weight*t
        t = new_legacy(4) - old_legacy(4, j); aerosol(j, 3, k) = one_minus_weight*t
        t = new_legacy(3) - old_legacy(3, j); aerosol(j, 4, k) = one_minus_weight*t
        t = mean_weight*aerd%rcvobga; aerosol(j, 5, k) = t*pressure_increment
        t = mean_weight*aerd%rcstbga; aerosol(j, 6, k) = t*pressure_increment
        a = ozone_q(j)*root_cube; b = root_cube + ozone_h(j); next_ozone = a/b
        ozone_amount(j, k) = next_ozone - old_ozone(j)
        do s = 1, 11
          new_mass = climate_mass(mass_climate(s), j)*mass_vertical_profile(rad, mass_profile(s), k + 1)
          t = new_mass - old_mass(s, j); aerosol_mass(j, k, s) = one_minus_weight*t
          old_mass(s, j) = new_mass
        end do
        aerosol_mass(j, k, 12) = 0.0_real64
        old_pressure(j) = new_pressure; old_ozone(j) = next_ozone; old_weight(j) = weight
        old_legacy(:, j) = new_legacy
        do s = 1, 6
          aerosol(j, s, k) = maximum_with_finite_floor(aerosol(j, s, k), tegen%repaer)
        end do
      end do
    end do
    surface_diagnostic(first:last) = 0.0_real64
    do s = 1, 6
      do j = first, last
        t = pressure(j, levels) - pressure(j, levels - 1)
        t = 1000.0_real64*t; multiplier = gravity/t
        t = multiplier*aerosol(j, s, levels); t = t*1000000.0_real64
        surface_diagnostic(j) = surface_diagnostic(j) + t
      end do
    end do
    status = 0
  end subroutine

  !> Interpolate latitude first, then longitude, including the periodic seam.
  real(real64) function interpolate_climate(table, latitude_grid, longitude_grid, step, sine_latitude, longitude) result(value)
    real(real64), intent(in) :: table(:, :), latitude_grid(:), longitude_grid(:), step, sine_latitude, longitude
    integer :: latitude, longitude1, longitude2, k
    real(real64) :: a, b, latitude_weight, longitude_weight, left, right
    latitude = size(latitude_grid) - 1
    do k = 1, size(latitude_grid) - 1
      if (sine_latitude <= latitude_grid(k)) then
        if (sine_latitude > latitude_grid(k + 1) .or. k == size(latitude_grid) - 1) then
          latitude = k; exit
        end if
      end if
    end do
    a = sine_latitude - latitude_grid(latitude)
    b = latitude_grid(latitude + 1) - latitude_grid(latitude); latitude_weight = a/b
    longitude1 = size(longitude_grid); longitude2 = 1
    a = longitude_grid(longitude1); b = a + step
    if (longitude < longitude_grid(longitude1)) then
      do k = 1, size(longitude_grid) - 1
        if (longitude >= longitude_grid(k) .and. longitude < longitude_grid(k + 1)) then
          longitude1 = k; longitude2 = k + 1
          a = longitude_grid(k); b = longitude_grid(k + 1); exit
        end if
      end do
    end if
    a = longitude - a; b = b - longitude_grid(longitude1); longitude_weight = a/b
    a = table(longitude1, latitude + 1) - table(longitude1, latitude)
    a = latitude_weight*a; left = table(longitude1, latitude) + a
    a = table(longitude2, latitude + 1) - table(longitude2, latitude)
    a = latitude_weight*a; right = table(longitude2, latitude) + a
    a = right - left; a = longitude_weight*a; value = left + a
  end function

  !> Sum the triangular coefficients in their original increasing order.
  subroutine transform_harmonics(basis, cosine_coefficients, sine_coefficients, count, output)
    real(real64), intent(in) :: basis(:), cosine_coefficients(:), sine_coefficients(:)
    integer, intent(in) :: count
    real(real64), intent(inout) :: output(:)
    integer :: order, remaining, cosine_index, sine_index, out_index, j
    real(real64) :: total, product
    cosine_index = 0; sine_index = 0; out_index = 0
    do order = 0, count - 1
      remaining = count - order; total = 0.0_real64
      do j = 1, remaining
        product = basis(cosine_index + j)*cosine_coefficients(cosine_index + j)
        total = total + product
      end do
      out_index = out_index + 1; output(out_index) = total
      cosine_index = cosine_index + remaining
      if (order /= 0) then
        total = 0.0_real64
        do j = 1, remaining
          product = basis(sine_index + j + count)*sine_coefficients(sine_index + j)
          total = total + product
        end do
        out_index = out_index + 1; output(out_index) = total; sine_index = sine_index + remaining
      end if
    end do
  end subroutine

  !> Evaluate each Fourier pair with separate product and addition operations.
  real(real64) function evaluate_fourier(coefficients, count, cosine, sine) result(value)
    real(real64), intent(in) :: coefficients(:), cosine, sine
    integer, intent(in) :: count
    real(real64) :: c, s, a, b, next_c, next_s, total
    integer :: order
    c = cosine; s = sine; a = coefficients(2)*c; b = coefficients(3)*s; total = a + b
    do order = 2, count - 1
      a = c*cosine; b = s*sine; next_c = a - b
      a = s*cosine; b = c*sine; next_s = a + b; c = next_c; s = next_s
      a = coefficients(2*order)*c; total = total + a
      a = coefficients(2*order + 1)*s; total = total + a
    end do
    total = 2.0_real64*total; value = coefficients(1) + total
  end function

  !> Return the selected canonical cumulative aerosol profile value.
  real(real64) function mass_vertical_profile(rad, species, level) result(value)
    type(terad), intent(in) :: rad
    integer, intent(in) :: species, level
    select case (species)
    case (1); value = rad%cvdaess(level)
    case (2); value = rad%cvdaedu(level)
    case (3); value = rad%cvdaeom(level)
    case (4); value = rad%cvdaebc(level)
    case (5); value = rad%cvdaesu(level)
    end select
  end function

  logical function profiles_ready(aerd, rad, count)
    type(teaerd), intent(in) :: aerd
    type(terad), intent(in) :: rad
    integer, intent(in) :: count
    profiles_ready = .false.
 if(.not.allocated(aerd%cvdaes).or..not.allocated(aerd%cvdael).or..not.allocated(aerd%cvdaeu).or..not.allocated(aerd%cvdaed)) return
    if(.not.allocated(rad%cvdaess).or..not.allocated(rad%cvdaedu).or..not.allocated(rad%cvdaeom).or..not.allocated(rad%cvdaebc).or..not.allocated(rad%cvdaesu)) return
    if(min(size(aerd%cvdaes),size(aerd%cvdael),size(aerd%cvdaeu),size(aerd%cvdaed),size(rad%cvdaess),size(rad%cvdaedu),size(rad%cvdaeom),size(rad%cvdaebc),size(rad%cvdaesu))<count) return
    profiles_ready = .true.
  end function

  logical function climate_ready(macc)
    type(teaerc_macc), intent(in) :: macc
    climate_ready = .false.
    if (.not. allocated(macc%rmaebc1)) return
    if (any(shape(macc%rmaebc1) /= [120, 61])) return
    if (.not. allocated(macc%rmaebc2)) return
    if (any(shape(macc%rmaebc2) /= [120, 61])) return
    if (.not. allocated(macc%rmaeor1)) return
    if (any(shape(macc%rmaeor1) /= [120, 61])) return
    if (.not. allocated(macc%rmaeor2)) return
    if (any(shape(macc%rmaeor2) /= [120, 61])) return
    if (.not. allocated(macc%rmaesd1)) return
    if (any(shape(macc%rmaesd1) /= [120, 61])) return
    if (.not. allocated(macc%rmaesd2)) return
    if (any(shape(macc%rmaesd2) /= [120, 61])) return
    if (.not. allocated(macc%rmaesd3)) return
    if (any(shape(macc%rmaesd3) /= [120, 61])) return
    if (.not. allocated(macc%rmaess1)) return
    if (any(shape(macc%rmaess1) /= [120, 61])) return
    if (.not. allocated(macc%rmaess2)) return
    if (any(shape(macc%rmaess2) /= [120, 61])) return
    if (.not. allocated(macc%rmaess3)) return
    if (any(shape(macc%rmaess3) /= [120, 61])) return
    if (.not. allocated(macc%rmaesu1)) return
    if (any(shape(macc%rmaesu1) /= [120, 61])) return
    climate_ready = .true.
  end function
end module
