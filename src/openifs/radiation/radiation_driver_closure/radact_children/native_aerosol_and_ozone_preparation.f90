!> Own selected and live-size RADACT aerosol/ozone preparation.
!! Native forecast records replace all original model/global lookups.
module native_radiation_aerosol_and_ozone
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use yoeaerd, only: teaerd
  use yoerad, only: terad
  use owned_aerosol_climatology_records, only: teaerc_tegen, teaerc_macc
  use forecast_public_scalar_math, only: power_original_rounding
  use forecast_environmental_ordered_arithmetic, only: maximum_with_finite_floor
  use md2asm_legendre_triangle, only: generate_legendre_triangle
  implicit none
  private
  public :: radact, runtime_radact
  interface
    function public_sine(x) bind(C, name="sin") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Keep the complete selected eight-column,nineteen-layer domain.
  subroutine radact(context,kidia,kfdia,klon,klev,krint,kdlon,kdlonp2,kshift,kcf,paprs,pgelam,psin,pclon,pslon,pth,pq,pqs,pecpo3,paer,paero,pozon,status,heap_budget)
    type(native_radiation_driver_context), intent(in) :: context
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, krint, kdlon, kdlonp2, kshift, kcf
    real(real64), intent(in) :: paprs(:, :), pgelam(:), psin(:), pclon(:), pslon(:), pth(:, :), pq(:, :), pqs(:, :), pecpo3(:, :)
    real(real64), intent(inout) :: paer(:, :, :), paero(:, :, :), pozon(:, :)
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: heap_budget
    status = 2
    if (klon /= 8 .or. klev /= 19 .or. kdlon /= 8 .or. kdlonp2 /= 8) return
    if (.not. associated(context%setup)) return
    if (context%setup%radiation%laer3d) return
    call prepare_radact(.false.,context,kidia,kfdia,klon,klev,krint,kdlon,kdlonp2,kshift,kcf,paprs,pgelam,psin,pclon,pslon,pth,pq,pqs,pecpo3,paer,paero,pozon,status,heap_budget)
  end subroutine

  !> Use complete live bounds and both two-/three-dimensional CAMS branches.
  subroutine runtime_radact(context,kidia,kfdia,klon,klev,krint,kdlon,kdlonp2,kshift,kcf,paprs,pgelam,psin,pclon,pslon,pth,pq,pqs,pecpo3,paer,paero,pozon,status,heap_budget)
    type(native_radiation_driver_context), intent(in) :: context
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, krint, kdlon, kdlonp2, kshift, kcf
    real(real64), intent(in) :: paprs(:, :), pgelam(:), psin(:), pclon(:), pslon(:), pth(:, :), pq(:, :), pqs(:, :), pecpo3(:, :)
    real(real64), intent(inout) :: paer(:, :, :), paero(:, :, :), pozon(:, :)
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: heap_budget
    call prepare_radact(.true.,context,kidia,kfdia,klon,klev,krint,kdlon,kdlonp2,kshift,kcf,paprs,pgelam,psin,pclon,pslon,pth,pq,pqs,pecpo3,paer,paero,pozon,status,heap_budget)
  end subroutine

  !> Produce source layer amounts with all original intermediate rounding.
  !! Pressure PAPRS is real64(KLON,1:L+1) in Pa, PTH uses K in KDLONP2 rows.
  !! PQ/PQS are kg/kg; PECPO3 is read-only and unused by the admitted controls.
  !! PAER(KDLON,6,L) is dimensionless optical depth, PAERO(KDLON,L,12) kg/kg,
  !! and POZON(KDLON,L) the source pressure-weighted ozone amount in Pa.
  !! Native parameter/coordinate/profile owners stay read-only; only selected
  !! outputs change. Caller owns aligned disjoint buffers and establishes the
  !! floating-point mode once. Status0 completes,1 is storage failure,2 refuses
  !! before public writes,3 is an unexpected private Legendre refusal.
  subroutine prepare_radact(runtime,context,kidia,kfdia,klon,klev,krint,kdlon,kdlonp2,kshift,kcf,paprs,pgelam,psin,pclon,pslon,pth,pq,pqs,pecpo3,paer,paero,pozon,status,heap_budget)
    logical, intent(in) :: runtime
    type(native_radiation_driver_context), intent(in) :: context
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, krint, kdlon, kdlonp2, kshift, kcf
    real(real64), intent(in) :: paprs(:, :), pgelam(:), psin(:), pclon(:), pslon(:), pth(:, :), pq(:, :), pqs(:, :), pecpo3(:, :)
    real(real64), intent(inout) :: paer(:, :, :), paero(:, :, :), pozon(:, :)
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: heap_budget
    real(real64), allocatable, target :: arena(:)
 real(real64), pointer, contiguous :: legacy(:, :), mass(:, :), ozone_q(:), ozone_h(:), old_pressure(:), old_ozone(:), old_weight(:)
    real(real64), pointer, contiguous :: old_legacy(:, :), old_mass(:, :), cumulative(:, :, :), mapped(:, :, :), pressure_copy(:, :)
    real(real64), pointer, contiguous, volatile :: harmonic(:, :), unused_sulphate(:), climate3(:, :, :)
    real(real64) :: latitude_grid(61), longitude_grid(120), basis(66), q_fourier(11), h_fourier(11), aerosol_fourier(21, 4)
    real(real64), volatile :: temperature_ratio, humidity_ratio, legacy_land_expression
    real(real64) :: longitude_step, grid_step, t, a, b, pi, gravity, weight, mean_weight, one_minus_weight
    real(real64) :: new_pressure, root_cube, next_ozone, pressure_increment, new_legacy(4), new_mass, air_mass
    real(real64) :: lower_pressure, upper_pressure, latitude, longitude, profile_value
    integer(int64) :: needed, budget, count, offset, span
    integer :: j, out, k, s, m, input_column, output_count, child_status, allocation_status, lower
    logical :: three_dimensional
    integer, parameter :: mass_profile(11) = [1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5]
    integer, parameter :: mass_climate(11) = [8, 9, 10, 5, 6, 7, 3, 4, 1, 2, 11]
    status = 2
    if (klon < 1 .or. klon > 1024 .or. klev < 1 .or. klev > 512) return
    if (kidia < 1 .or. kfdia < kidia .or. kfdia > klon .or. krint < 1 .or. krint > klon .or. kshift < 0) return
    if (kcf < 0 .or. kcf > 1 .or. kdlon < 1 .or. kdlonp2 < 1) return
    output_count = (kfdia - kidia)/krint + 1
    if (kshift + output_count > kdlon) return
    if (runtime) then
      if (krint /= 1 .or. kshift /= kidia - 1 .or. kdlon /= klon .or. kdlonp2 /= klon) return
    end if
    if (.not. associated(context%setup) .or. .not. associated(context%constants)) return
    if (context%stochastic_enabled .or. context%constants%initialized /= 1) return
    if (size(paprs, 1) /= klon .or. size(paprs, 2) < klev + 1) return
    if (min(size(pgelam), size(psin), size(pclon), size(pslon)) < klon) return
    if (size(pth, 1) /= kdlonp2 .or. size(pth, 2) < klev + 1) return
    if (size(pq, 1) /= kdlonp2 .or. size(pq, 2) < klev .or. size(pqs, 1) /= kdlonp2 .or. size(pqs, 2) < klev) return
    if (size(pecpo3, 1) /= kdlonp2 .or. size(pecpo3, 2) < klev) return
    if (size(paer, 1) /= kdlon .or. size(paer, 2) < 6 .or. size(paer, 3) < klev) return
    if (size(paero, 1) /= kdlon .or. size(paero, 2) < klev .or. size(paero, 3) < 12) return
    if (size(pozon, 1) /= kdlon .or. size(pozon, 2) < klev) return
    if (kcf == 0 .and. kfdia > kdlonp2) return
    if (kcf == 1 .and. kshift + output_count > kdlonp2) return
    associate(aerd=>context%setup%aerosol_distribution,rad=>context%setup%radiation,ozone=>context%setup%ozone,tegen=>context%setup%tegen,macc=>context%setup%cams)
      if (rad%nvolcvert /= 0 .or. rad%naermacc /= 1 .or. rad%nmclat /= 61 .or. rad%nmclon /= 120 .or. rad%nmcvar /= 12) return
      if (rad%lhvolca .or. .not. rad%lnewaer .or. rad%leso4his .or. rad%laeradjdu) return
      three_dimensional = rad%laer3d
      if (.not. runtime .and. three_dimensional) return
      pi = context%constants%rpi; gravity = context%constants%rg
      if (.not. (pi > 0.0_real64 .and. pi <= huge(pi))) return
      if (.not. (gravity > 0.0_real64 .and. gravity <= huge(gravity))) return
      if (.not. (aerd%rctrpt >= 0.0_real64 .and. aerd%rctrpt <= 64.0_real64)) return
      if (.not. (tegen%repaer >= 0.0_real64 .and. tegen%repaer <= huge(t))) return
      if (.not. profiles_ready(aerd, rad, klev + 1)) return
    if(any([lbound(aerd%cvdaes,1),lbound(aerd%cvdael,1),lbound(aerd%cvdaeu,1),lbound(aerd%cvdaed,1),lbound(rad%cvdaess,1),lbound(rad%cvdaedu,1),lbound(rad%cvdaeom,1),lbound(rad%cvdaebc,1),lbound(rad%cvdaesu,1)]/=1)) return
      if (.not. tegen_ready(tegen)) return
      if (three_dimensional) then
        if (.not. climate3_ready(macc)) return
      else
        if (.not. climate_ready(macc)) return
      end if
      out = kshift
      do j = kidia, kfdia, krint
        out = out + 1
        if (.not. (abs(psin(j)) <= 1.0_real64 .and. psin(j) == psin(kidia))) return
        if (.not. (pgelam(j) >= 0.0_real64 .and. pgelam(j) < 2.0_real64*pi)) return
        if (.not. (abs(pclon(j)) <= 1.0_real64 .and. abs(pslon(j)) <= 1.0_real64)) return
        if (.not. (paprs(j, 1) >= 0.0_real64 .and. paprs(j, 1) <= huge(t))) return
        do k = 2, klev + 1
          if (.not. (paprs(j, k) > paprs(j, k - 1) .and. paprs(j, k) <= huge(t))) return
        end do
        input_column = j
        if (kcf == 1) input_column = out
        do k = 1, klev + 1
          if (.not. finite_bits(pth(input_column, k))) return
          if (runtime) then
            if (iand(transfer(pth(input_column, k), 0_int64), int(z'7fffffffffffffff', int64)) == 0_int64) return
          else
            if (.not. (pth(input_column, k) > 0.0_real64)) return
          end if
        end do
        do k = 1, klev
          if (.not. finite_bits(pq(input_column, k)) .or. .not. finite_bits(pqs(input_column, k))) return
        end do
      end do
      budget = 67108864_int64
      if (present(heap_budget)) budget = heap_budget
      if (budget < 0 .or. budget > 67108864_int64) return
      needed = int(klon, int64)*(96_int64*klev + 12320_int64)
      if (needed > budget) return
      count = needed/8_int64
      allocate (arena(count), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1; return
      end if
      arena = 0.0_real64; offset = 1
      legacy(1:5, 1:klon) => arena(offset:offset + 5*klon - 1); offset = offset + 5*klon
      mass(1:11, 1:klon) => arena(offset:offset + 11*klon - 1); offset = offset + 11*klon
      ozone_q(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
      ozone_h(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
      old_pressure(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
      old_ozone(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
      old_weight(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
      old_legacy(1:4, 1:klon) => arena(offset:offset + 4*klon - 1); offset = offset + 4*klon
      old_mass(1:11, 1:klon) => arena(offset:offset + 11*klon - 1); offset = offset + 11*klon
      harmonic(1:4, 1:klon) => arena(offset:offset + 4*klon - 1); offset = offset + 4*klon
      unused_sulphate(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
      climate3(1:13, 1:klon, 1:60) => arena(offset:offset + 780_int64*klon - 1); offset = offset + 780_int64*klon
      span = 671_int64*klon
      cumulative(1:klon, 0:60, 1:11) => arena(offset:offset + span - 1); offset = offset + span
      span = int(klon, int64)*int(klev + 1, int64)*11_int64
      mapped(1:klon, 0:klev, 1:11) => arena(offset:offset + span - 1); offset = offset + span
      span = int(klon, int64)*int(klev + 1, int64)
      pressure_copy(1:klon, 1:klev + 1) => arena(offset:offset + span - 1)
      ! Native workspace mapping consumes (12*L+1504)*P values, within the
      ! exact (12*L+1540)*P source payload admission above.
      grid_step = 180.0_real64/45.0_real64
      do k = 1, 46
        t = real(k - 1, real64)*grid_step; t = 90.0_real64 - t; t = t*pi; t = t/180.0_real64
        latitude_grid(k) = public_sine(t)
      end do
      longitude_step = pi + pi; longitude_step = longitude_step/72.0_real64
      do k = 1, 72
        longitude_grid(k) = real(k - 1, real64)*longitude_step
      end do
      do j = kidia, kfdia, krint
     legacy(1, j) = interpolate_climate(tegen%rtaebc, latitude_grid(1:46), longitude_grid(1:72), longitude_step, psin(j), pgelam(j))
     legacy(2, j) = interpolate_climate(tegen%rtaeor, latitude_grid(1:46), longitude_grid(1:72), longitude_step, psin(j), pgelam(j))
     legacy(3, j) = interpolate_climate(tegen%rtaesd, latitude_grid(1:46), longitude_grid(1:72), longitude_step, psin(j), pgelam(j))
     legacy(4, j) = interpolate_climate(tegen%rtaess, latitude_grid(1:46), longitude_grid(1:72), longitude_step, psin(j), pgelam(j))
     legacy(5, j) = interpolate_climate(tegen%rtaesu, latitude_grid(1:46), longitude_grid(1:72), longitude_step, psin(j), pgelam(j))
      end do
      out = kshift
      do j = kidia, kfdia, krint
        out = out + 1; paero(out, 1:klev, 1:12) = 0.0_real64
      end do
      grid_step = 180.0_real64/60.0_real64
      do k = 1, 61
        t = real(k - 1, real64)*grid_step; t = 90.0_real64 - t; t = t*pi; t = t/180.0_real64
        latitude_grid(k) = public_sine(t)
      end do
      longitude_step = pi + pi; longitude_step = longitude_step/120.0_real64
      do k = 1, 120
        longitude_grid(k) = real(k - 1, real64)*longitude_step
      end do
      if (three_dimensional) then
        do j = kidia, kfdia, krint
          do k = 1, 60
         climate3(12,j,k)=interpolate_climate(macc%ref_aer_prs(:,:,k),latitude_grid,longitude_grid,longitude_step,psin(j),pgelam(j))
        climate3(13,j,k)=interpolate_climate(macc%ref_aer_dprs(:,:,k),latitude_grid,longitude_grid,longitude_step,psin(j),pgelam(j))
 climate3(1, j, k) = interpolate_climate(macc%rmaebc13d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(2, j, k) = interpolate_climate(macc%rmaebc23d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(3, j, k) = interpolate_climate(macc%rmaeor13d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(4, j, k) = interpolate_climate(macc%rmaeor23d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(5, j, k) = interpolate_climate(macc%rmaesd13d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(6, j, k) = interpolate_climate(macc%rmaesd23d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(7, j, k) = interpolate_climate(macc%rmaesd33d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(8, j, k) = interpolate_climate(macc%rmaess13d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
 climate3(9, j, k) = interpolate_climate(macc%rmaess23d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
climate3(10, j, k) = interpolate_climate(macc%rmaess33d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
climate3(11, j, k) = interpolate_climate(macc%rmaesu13d(:, :, k), latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          end do
        end do
      else
        do j = kidia, kfdia, krint
          mass(1, j) = interpolate_climate(macc%rmaebc1, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(2, j) = interpolate_climate(macc%rmaebc2, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(3, j) = interpolate_climate(macc%rmaeor1, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(4, j) = interpolate_climate(macc%rmaeor2, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(5, j) = interpolate_climate(macc%rmaesd1, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(6, j) = interpolate_climate(macc%rmaesd2, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(7, j) = interpolate_climate(macc%rmaesd3, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(8, j) = interpolate_climate(macc%rmaess1, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(9, j) = interpolate_climate(macc%rmaess2, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(10, j) = interpolate_climate(macc%rmaess3, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
          mass(11, j) = interpolate_climate(macc%rmaesu1, latitude_grid, longitude_grid, longitude_step, psin(j), pgelam(j))
        end do
      end if
      ! One shared-latitude basis for each order, as in the complete source.
      call generate_legendre_triangle(psin(kidia), 6_int32, basis, child_status)
      if (child_status /= 0) then
        status = 3; return
      end if
      call transform_harmonics(basis, ozone%cozqc, ozone%cozqs, 6, q_fourier)
      call transform_harmonics(basis, ozone%cozhc, ozone%cozhs, 6, h_fourier)
      call generate_legendre_triangle(psin(kidia), 11_int32, basis, child_status)
      if (child_status /= 0) then
        status = 3; return
      end if
      call transform_harmonics(basis, aerd%raesc, aerd%raess, 11, aerosol_fourier(:, 1))
      call transform_harmonics(basis, aerd%raelc, aerd%raels, 11, aerosol_fourier(:, 2))
      call transform_harmonics(basis, aerd%raeuc, aerd%raeus, 11, aerosol_fourier(:, 3))
      call transform_harmonics(basis, aerd%raedc, aerd%raeds, 11, aerosol_fourier(:, 4))
      do j = kidia, kfdia, krint
        ozone_q(j) = evaluate_fourier(q_fourier, 6, pclon(j), pslon(j))
        t = evaluate_fourier(h_fourier, 6, pclon(j), pslon(j)); t = sqrt(t); a = t*t; ozone_h(j) = a*t
        do s = 1, 4
          harmonic(s, j) = evaluate_fourier(aerosol_fourier(:, s), 11, pclon(j), pslon(j))
        end do
      end do
      do j = kidia, kfdia, krint
        old_pressure(j) = paprs(j, 1)
        t = old_pressure(j)*old_pressure(j); t = t*old_pressure(j); t = sqrt(t)
        a = ozone_q(j)*t; b = t + ozone_h(j); old_ozone(j) = a/b
        old_weight(j) = 1.0_real64
        old_legacy(1, j) = legacy(4, j)*aerd%cvdaes(1)
        old_legacy(3, j) = legacy(1, j)*aerd%cvdaeu(1)
        old_legacy(4, j) = legacy(3, j)*aerd%cvdaed(1)
        unused_sulphate(j) = legacy(5, j)*aerd%cvdael(1)
        a = legacy(2, j)*aerd%cvdael(1); old_legacy(2, j) = a + unused_sulphate(j)
        if (.not. three_dimensional) then
          do s = 1, 11
            old_mass(s, j) = mass(mass_climate(s), j)*mass_vertical_profile(rad, mass_profile(s), 1)
          end do
        end if
      end do
      do k = 1, klev
        out = kshift
        do j = kidia, kfdia, krint
          out = out + 1; input_column = j
          if (kcf == 1) input_column = out
          temperature_ratio = pth(input_column, k)/pth(input_column, k + 1)
          humidity_ratio = pq(input_column, k)/pqs(input_column, k)
          new_pressure = paprs(j, k + 1); t = new_pressure*new_pressure; t = t*new_pressure; root_cube = sqrt(t)
          t = new_pressure + old_pressure(j); t = 0.5_real64*t
          if (t < 999.0_real64) then
            weight = 1.0_real64
          else
            t = min(1.0_real64, temperature_ratio); t = power_original_rounding(t, aerd%rctrpt)
            weight = old_weight(j)*t
          end if
          t = weight*old_weight(j); mean_weight = sqrt(t); one_minus_weight = 1.0_real64 - mean_weight
          pressure_increment = new_pressure - old_pressure(j)
          unused_sulphate(j) = legacy(5, j)*aerd%cvdael(k + 1)
          a = legacy(2, j)*aerd%cvdael(k + 1); new_legacy(2) = a + unused_sulphate(j)
          new_legacy(1) = legacy(4, j)*aerd%cvdaes(k + 1)
          new_legacy(3) = legacy(1, j)*aerd%cvdaeu(k + 1)
          new_legacy(4) = legacy(3, j)*aerd%cvdaed(k + 1)
          t = aerd%rctrbga*pressure_increment; a = t + new_legacy(2); a = a - old_legacy(2, j)
          legacy_land_expression = one_minus_weight*a
          paer(out, 1, k) = one_minus_weight*t
          t = new_legacy(1) - old_legacy(1, j); paer(out, 2, k) = one_minus_weight*t
          t = new_legacy(4) - old_legacy(4, j); paer(out, 3, k) = one_minus_weight*t
          t = new_legacy(3) - old_legacy(3, j); paer(out, 4, k) = one_minus_weight*t
          t = mean_weight*aerd%rcvobga; paer(out, 5, k) = t*pressure_increment
          t = mean_weight*aerd%rcstbga; paer(out, 6, k) = t*pressure_increment
          a = ozone_q(j)*root_cube; b = root_cube + ozone_h(j); next_ozone = a/b
          pozon(out, k) = next_ozone - old_ozone(j)
          if (.not. three_dimensional) then
            air_mass = pressure_increment/gravity
            do s = 1, 11
              new_mass = mass(mass_climate(s), j)*mass_vertical_profile(rad, mass_profile(s), k + 1)
              t = new_mass - old_mass(s, j); old_mass(s, j) = new_mass
              t = one_minus_weight*t; paero(out, k, s) = t/air_mass
            end do
            paero(out, k, 12) = 0.0_real64
          end if
          old_pressure(j) = new_pressure; old_ozone(j) = next_ozone; old_weight(j) = weight
          old_legacy(:, j) = new_legacy
          do s = 1, 6
            paer(out, s, k) = maximum_with_finite_floor(paer(out, s, k), tegen%repaer)
          end do
        end do
      end do
      pressure_copy(:, 1:klev + 1) = paprs(:, 1:klev + 1)
      if (three_dimensional) then
        do k = 1, 60
          do s = 1, 11
            do j = kidia, kfdia
              cumulative(j, k, s) = cumulative(j, k - 1, s) + climate3(s, j, k)
            end do
          end do
        end do
        do k = 1, klev
          do j = kidia, kfdia
            t = pressure_copy(j, k + 1); lower = 59
            do m = 0, 59
              lower_pressure = 0.0_real64
              if (m > 0) lower_pressure = climate3(12, j, m)
              upper_pressure = climate3(12, j, m + 1)
              if (t >= lower_pressure .and. t < upper_pressure) then
                lower = m; exit
              end if
            end do
            lower_pressure = 0.0_real64
            if (lower > 0) lower_pressure = climate3(12, j, lower)
            upper_pressure = climate3(12, j, lower + 1)
            a = t - lower_pressure; b = upper_pressure - lower_pressure; weight = a/b
            do s = 1, 11
              a = cumulative(j, lower + 1, s) - cumulative(j, lower, s)
              a = weight*a; mapped(j, k, s) = cumulative(j, lower, s) + a
            end do
          end do
        end do
        do k = 1, klev
          do j = kidia, kfdia
            t = pressure_copy(j, k + 1) - pressure_copy(j, k); air_mass = t/gravity
            do s = 1, 11
              m = mass_climate(s); a = mapped(j, k, m) - mapped(j, k - 1, m)
              paero(j, k, s) = a/air_mass
            end do
            paero(j, k, 12) = 0.0_real64
          end do
        end do
      end if
      status = 0
    end associate
  end subroutine

  !> Test a real64 exponent without changing floating-point status.
  pure logical function finite_bits(x) result(ok)
    real(real64), intent(in) :: x
    ok = ibits(transfer(x, 0_int64), 52, 11) /= 2047_int64
  end function

  logical function tegen_ready(tegen) result(ok)
    type(teaerc_tegen), intent(in) :: tegen
    ok = .false.
    if (any(shape(tegen%rtaebc) /= [72, 46])) return
    if (any(shape(tegen%rtaeor) /= [72, 46])) return
    if (any(shape(tegen%rtaesd) /= [72, 46])) return
    if (any(shape(tegen%rtaess) /= [72, 46])) return
    if (any(shape(tegen%rtaesu) /= [72, 46])) return
    ok = .true.
  end function

  logical function climate3_ready(macc) result(ok)
    type(teaerc_macc), intent(in) :: macc
    ok = .false.
    if (.not. allocated(macc%ref_aer_prs)) return
    if (any(shape(macc%ref_aer_prs) /= [120, 61, 60])) return
    if (.not. allocated(macc%ref_aer_dprs)) return
    if (any(shape(macc%ref_aer_dprs) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaebc13d)) return
    if (any(shape(macc%rmaebc13d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaebc23d)) return
    if (any(shape(macc%rmaebc23d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaeor13d)) return
    if (any(shape(macc%rmaeor13d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaeor23d)) return
    if (any(shape(macc%rmaeor23d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaesd13d)) return
    if (any(shape(macc%rmaesd13d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaesd23d)) return
    if (any(shape(macc%rmaesd23d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaesd33d)) return
    if (any(shape(macc%rmaesd33d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaess13d)) return
    if (any(shape(macc%rmaess13d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaess23d)) return
    if (any(shape(macc%rmaess23d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaess33d)) return
    if (any(shape(macc%rmaess33d) /= [120, 61, 60])) return
    if (.not. allocated(macc%rmaesu13d)) return
    if (any(shape(macc%rmaesu13d) /= [120, 61, 60])) return
    ok = .true.
  end function

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
