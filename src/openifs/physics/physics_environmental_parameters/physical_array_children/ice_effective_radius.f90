!> Diagnose ice effective radius with all four frozen source options.
module forecast_ice_effective_radius
  use iso_fortran_env, only: int32, int64, real64
  use forecast_environmental_radius_support
  implicit none
  private
  public :: ice_effective_radius
contains
  !> Profiles have shape(KLON,KLEV); latitude and output owners retain all
  !! inactive words. Pressure is Pa, temperature K, water kg/kg and radius um.
  !! RD and RTT are explicit original constants. Optional patterns are
  !! dimensionless and read only when the configured option3 consumes them.
  subroutine ice_effective_radius(config, perturb, kidia, kfdia, klon, klev, pressure, temperature, &
                                  cloud, ice, snow, sine_latitude, radius, rd, rtt, status, pattern)
    type(ice_radius_controls), intent(in) :: config
    type(radius_perturbation_view), intent(in) :: perturb
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: pressure(:, :), temperature(:, :), cloud(:, :), ice(:, :), snow(:, :)
    real(real64), intent(in) :: sine_latitude(:), rd, rtt
    real(real64), intent(inout) :: radius(:, :)
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: pattern(:, :)
    real(real64) :: minimum(2048), mean, magnitude, angle, cosine, argument, t, value, term
    real(real64) :: water, density, thermal, content, a, b, diameter, conversion
    integer(int64) :: latitude_bits
    integer :: j, k, entry, pattern_index
    logical :: use_perturbation
    status = 2
    if (klon < 1 .or. klon > 2048 .or. klev < 1 .or. klev > 512) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (config%mode < 0 .or. config%mode > 3) return
    if (kidia > kfdia) then
      status = 0
      return
    end if
    if (any(shape(pressure) /= [klon, klev]) .or. any(shape(temperature) /= [klon, klev])) return
    if (any(shape(cloud) /= [klon, klev]) .or. any(shape(ice) /= [klon, klev])) return
    if (any(shape(snow) /= [klon, klev]) .or. any(shape(radius) /= [klon, klev])) return
    if (size(sine_latitude) /= klon) return
    use_perturbation = .false.
    mean = 0.0_real64; magnitude = 0.0_real64; pattern_index = 0
    entry = 0
    if (perturb%enabled) entry = perturb%selected_entry
    if (perturb%enabled .and. entry > 0) then
      if (.not. associated(perturb%entries)) return
      if (entry < lbound(perturb%entries, 1) .or. entry > ubound(perturb%entries, 1)) return
      mean = perturb%entries(entry)%mean
      magnitude = perturb%entries(entry)%magnitude
      if (config%mode == 3) then
        pattern_index = perturb%entries(entry)%pattern
        if (pattern_index < 1 .or. pattern_index > perturb%pattern_count) return
        if (.not. present(pattern)) return
        if (size(pattern, 1) /= klon .or. size(pattern, 2) < perturb%pattern_count) return
        use_perturbation = .true.
      end if
    end if
    if (config%mode == 3) then
      do j = kidia, kfdia
        value = config%minimum_diameter
        if (config%latitude_minimum) then
          latitude_bits = iand(transfer(sine_latitude(j), 0_int64), int(z'7fffffffffffffff', int64))
          if (latitude_bits > int(z'3ff0000000000000', int64)) return
          angle = public_asin(sine_latitude(j))
          cosine = public_cos(angle)
          value = value - 20.0_real64
          value = value*cosine
          value = 20.0_real64 + value
        end if
        minimum(j) = value
      end do
    end if
    conversion = config%radius_factor
    do k = 1, klev
      do j = kidia, kfdia
        if (config%mode == 0) then
          radius(j, k) = 40.0_real64
        else if (config%mode == 1 .or. config%mode == 2) then
          t = temperature(j, k) - rtt
          t = numeric_min(t, -0.1_real64)
          value = t*0.0012_real64
          value = 0.197_real64 + value
          value = t*value
          value = 12.42_real64 + value
          value = t*value
          value = 326.3_real64 + value
          if (config%mode == 1) then
            value = numeric_max(value, 40.0_real64)
            radius(j, k) = numeric_min(value, 130.0_real64)
          else
            value = numeric_max(value, 30.0_real64)
            radius(j, k) = numeric_min(value, 60.0_real64)
          end if
        else
          if (.not. (cloud(j, k) > 0.001_real64)) then
            radius(j, k) = 80.0_real64*conversion
            cycle
          end if
          water = ice(j, k) + snow(j, k)
          if (.not. (water > 0.0_real64)) then
            radius(j, k) = 80.0_real64*conversion
            cycle
          end if
          density = 1000.0_real64*pressure(j, k)
          thermal = rd*temperature(j, k)
          density = density/thermal
          density = density*water
          content = density/cloud(j, k)
          a = power_original_rounding(content, 0.2214_real64)
          a = 45.8966_real64*a
          b = power_original_rounding(content, 0.2535_real64)
          b = 0.7957_real64*b
          term = temperature(j, k) - 83.15_real64
          b = b*term
          diameter = a + b
          t = temperature(j, k) - rtt
          t = 0.0105_real64*t
          t = 1.2351_real64 + t
          diameter = t*diameter
          if (use_perturbation) then
            argument = magnitude*pattern(j, pattern_index)
            argument = mean + argument
            term = public_exp(argument)
            diameter = diameter*term
          end if
          diameter = numeric_max(diameter, minimum(j))
          diameter = numeric_min(diameter, 155.0_real64)
          radius(j, k) = diameter*conversion
        end if
      end do
    end do
    status = 0
  end subroutine
end module
