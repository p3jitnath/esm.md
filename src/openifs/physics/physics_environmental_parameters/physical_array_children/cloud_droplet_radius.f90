!> Diagnose complete liquid-cloud effective radius in micrometres.
module forecast_cloud_droplet_radius
  use iso_fortran_env, only: int32, int64, real64
  use forecast_environmental_radius_support
  implicit none
  private
  public :: liquid_effective_radius
contains
  !> All profiles have shape(KLON,KLEV), vectors length KLON. Pressure is Pa,
  !! temperature K, water kg/kg and nuclei particles/cm3. Only selected output
  !! columns change. All configurations and optional patterns are read-only.
  !! RD,RPI,REPLOG,REPSCW are supplied from the caller's physical owner.
  subroutine liquid_effective_radius(config, perturb, kidia, kfdia, klon, klev, &
                                     pressure, temperature, cloud, liquid, rain, land, nuclei_land, nuclei_sea, radius, &
                                     rd, rpi, replog, repscw, status, pattern)
    type(liquid_radius_controls), intent(in) :: config
    type(radius_perturbation_view), intent(in) :: perturb
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: pressure(:, :), temperature(:, :), cloud(:, :), liquid(:, :), rain(:, :)
    real(real64), intent(in) :: land(:), nuclei_land(:), nuclei_sea(:), rd, rpi, replog, repscw
    real(real64), intent(inout) :: radius(:, :)
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: pattern(:, :)
    integer :: j, k, active_aerosols, entry, pattern_index
    logical :: use_perturbation
    real(real64) :: concentration, quadratic, linear, dispersion, ratio_constant
    real(real64) :: argument, water, density, thermal, ql, qr, rain_ratio, rain_factor
    real(real64) :: volume, power_value, value, term
    real(real64), volatile :: number, denominator
    status = 2
    if (klon < 0 .or. klon == huge(klon) .or. klev < 0 .or. klev == huge(klev)) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    active_aerosols = config%atmospheric_aerosols
    if (active_aerosols == 0 .and. config%radiation_selector == 1) active_aerosols = config%radiation_aerosols
    if (active_aerosols >= 12 .and. config%cloud_aerosols > 0) return
    if (config%mode < 0 .or. config%mode > 2) return
    if (any(shape(pressure) /= [klon, klev]) .or. any(shape(temperature) /= [klon, klev])) return
    if (any(shape(cloud) /= [klon, klev]) .or. any(shape(liquid) /= [klon, klev])) return
    if (any(shape(rain) /= [klon, klev]) .or. any(shape(radius) /= [klon, klev])) return
    if (size(land) /= klon .or. size(nuclei_land) /= klon .or. size(nuclei_sea) /= klon) return
    if (kidia > kfdia .or. klev == 0) then
      status = 0
      return
    end if
    use_perturbation = .false.
    entry = 0
    if (perturb%enabled) entry = perturb%selected_entry
    pattern_index = 0
    if (perturb%enabled .and. entry > 0 .and. config%mode == 2) then
      if (.not. associated(perturb%entries)) return
      if (entry < lbound(perturb%entries, 1) .or. entry > ubound(perturb%entries, 1)) return
      pattern_index = perturb%entries(entry)%pattern
      if (pattern_index < 1 .or. pattern_index > perturb%pattern_count) return
      if (.not. present(pattern)) return
      if (size(pattern, 1) /= klon .or. size(pattern, 2) < perturb%pattern_count) return
      use_perturbation = .true.
    end if
    do j = kidia, kfdia
      if (config%mode == 0) then
        do k = 1, klev
          value = 100000.0_real64 - pressure(j, k)
          value = value*3.5_real64
          radius(j, k) = 10.0_real64 + value
        end do
        cycle
      else if (config%mode == 1) then
        value = 10.0_real64
        if (land(j) < 0.5_real64) value = 13.0_real64
        do k = 1, klev
          radius(j, k) = value
        end do
        cycle
      end if
      if (land(j) < 0.5_real64) then
        concentration = config%sea_nuclei
        if (config%local_sea_nuclei) concentration = nuclei_sea(j)
        quadratic = concentration*0.00115_real64
        quadratic = quadratic*concentration
        linear = concentration*0.963_real64
        number = linear - quadratic
        number = number + 5.30_real64
        dispersion = 0.77_real64
        ratio_constant = transfer(int(z'3fe5261293de469b', int64), 0.0_real64)
      else
        concentration = config%land_nuclei
        if (config%local_land_nuclei) concentration = nuclei_land(j)
        quadratic = concentration*0.000210_real64
        quadratic = quadratic*concentration
        linear = concentration*0.568_real64
        number = linear - quadratic
        number = number - 27.9_real64
        dispersion = 0.69_real64
        ratio_constant = transfer(int(z'3fe5ef8102bb5092', int64), 0.0_real64)
      end if
      if (use_perturbation) then
        argument = perturb%entries(entry)%magnitude*pattern(j, pattern_index)
        argument = perturb%entries(entry)%mean + argument
        term = public_exp(argument)
        number = number*term
      end if
      denominator = 4.0_real64*rpi
      denominator = denominator*number
      denominator = denominator*dispersion
      do k = 1, klev
        if (.not. (cloud(j, k) >= 0.001_real64)) then
          radius(j, k) = 4.0_real64
          cycle
        end if
        water = liquid(j, k) + rain(j, k)
        if (.not. (water > 0.0_real64)) then
          radius(j, k) = 4.0_real64
          cycle
        end if
        density = 1000.0_real64*pressure(j, k)
        thermal = rd*temperature(j, k)
        density = density/thermal
        ql = density*liquid(j, k)
        qr = density*rain(j, k)
        ql = ql/cloud(j, k)
        qr = qr/cloud(j, k)
        rain_factor = 1.0_real64
        if (ql > repscw) then
          rain_ratio = qr/ql
          argument = 1.0_real64 + rain_ratio
          power_value = power_original_rounding(argument, 0.666_real64)
          term = 0.2_real64*ratio_constant
          term = term*rain_ratio
          term = 1.0_real64 + term
          rain_factor = power_value/term
        end if
        volume = ql + qr
        volume = 3.0_real64*volume
        volume = volume/denominator
        if (.not. (volume > replog)) then
          radius(j, k) = 4.0_real64
          cycle
        end if
        value = public_log(volume)
        value = value*0.333_real64
        value = public_exp(value)
        term = rain_factor*100.0_real64
        value = term*value
        value = numeric_min(value, 30.0_real64)
        radius(j, k) = numeric_max(value, 4.0_real64)
      end do
    end do
    status = 0
  end subroutine
end module
