!> Complete source-ordered SURFRAD_CTL surface radiation calculation.
!! Albedos, emissivities, fractions and solar-angle cosine are dimensionless.
!! Temperature uses kelvin, wind m/s, and lake-ice depth metres.
module forecast_surface_radiation_controller
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yos_cst, only: tcst
  use yos_lw, only: tlw
  use yos_sw, only: tsw
  use yos_rad, only: trad
  use yos_rdi, only: trdi
  use yos_soil, only: tsoil
  use yos_flake, only: tflake
  use yos_urb, only: turb
  use forecast_public_scalar_math, only: power_original_rounding
  use forecast_urban_canyon_albedo, only: canalb
  implicit none
  private
  public :: surfrad_ctl
  interface
    function public_acos(x) bind(C, name="acos") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_exp(x) bind(C, name="exp") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_log10(x) bind(C, name="log10") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
  integer(int64), parameter :: constant_words(0:35) = [ &
                               int(z'0000000000000000', int64), int(z'3ff0000000000000', int64), int(z'bf7f05ea24cc6823', int64), &
                               int(z'3fb22c343b70ef56', int64), int(z'3fd3af8594291750', int64), int(z'bff48efcbd556085', int64), &
                               int(z'3fc549c6f36ef805', int64), int(z'3fa56c0d6f544bb2', int64), int(z'3fd3333333333333', int64), &
                               int(z'3fc8372e6a76965f', int64), int(z'bff60abd5dc40075', int64), int(z'3ff6666666666666', int64), &
                               int(z'3ff199999999999a', int64), int(z'3fc3333333333333', int64), int(z'3fa2f1a9fbe76c8b', int64), &
                               int(z'3fe7ae147ae147ae', int64), int(z'3fe23d70a3d70a3d', int64), int(z'3fde147ae147ae14', int64), &
                               int(z'3fec7ae147ae147b', int64), int(z'3f947ae147ae147b', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fe0000000000000', int64), int(z'c057e66666666666', int64), int(z'3fe6666666666666', int64), &
                               int(z'3fd999999999999a', int64), int(z'403e000000000000', int64), int(z'402e000000000000', int64), &
                               int(z'3fc47ae147ae147b', int64), int(z'3ff70a3d70a3d70a', int64), int(z'3fc0a3d70a3d70a4', int64), &
                               int(z'3ffe3d70a3d70a3d', int64), int(z'4074700000000000', int64), int(z'3ff3333333333333', int64), &
                               int(z'4024000000000000', int64), int(z'3ff7333333333333', int64), int(z'4001ae147ae147ae', int64)]
  real(real64), parameter :: c(0:35) = transfer(constant_words, [0.0_real64], 36)
contains
  !> Read eight canonical surface scheme records and change eight field owners.
  !! Original43-argument order is retained, followed by native status.
  !! Supports columns1:4096,tiles9/10,solar bands2/6,thermal requests2:32 and
  !! configured emissivity2:16; request2 or at least the configured count.
  !! Caller-owned inputs and outputs are disjoint; positive/gapped array
  !! strides are supported and inactive rows/extra spectral cells stay incoming.
  !! Caller establishes nearest-even/gradual mode. Status0 completes,2 refuses
  !! metadata before public mutation,3 reports a private canyon child refusal.
  subroutine surfrad_ctl(kddn,kmmn,kmon,kseco,kidia,kfdia,klon,ktiles,ksw,klw,ldnh,palbf,palbicef,ptvh,palcoeff,pcur,pcvh,pasn,pmu0,pts,pwnd,pws1,ksoty,pfrti,phlice,ptlice,ydcst,ydlw,ydsw,ydrad,ydrdi,ydsoil,ydflake,ydurb,palbd,palbp,palb,pspectralemiss,pemit,palbti,pccnl,pccno,lnemolimalb,status)
    integer(int32), intent(in) :: kddn, kmmn, kmon(:), kseco, kidia, kfdia, klon, ktiles, ksw, klw, ksoty(:)
    logical(int32), intent(in) :: ldnh(:), lnemolimalb
    real(real64),intent(in) :: palbf(:),palbicef(:),ptvh(:),palcoeff(:,:),pcur(:),pcvh(:),pasn(:),pmu0(:),pts(:),pwnd(:),pws1(:),pfrti(:,:),phlice(:),ptlice(:)
    type(tcst), intent(in) :: ydcst
    type(tlw), intent(in) :: ydlw
    type(tsw), intent(in) :: ydsw
    type(trad), intent(in) :: ydrad
    type(trdi), intent(in) :: ydrdi
    type(tsoil), intent(in) :: ydsoil
    type(tflake), intent(in) :: ydflake
    type(turb), intent(in) :: ydurb
  real(real64), intent(inout) :: palbd(:, :), palbp(:, :), palb(:), pspectralemiss(:, :), pemit(:), palbti(:, :), pccnl(:), pccno(:)
    integer(int32), intent(out) :: status
    real(real64) :: canyon_albedo(max(1, min(klon, 4096))), spectral(16), tile_emissivity(10)
    real(real64), volatile :: diffuse(10), direct(10), inverse_standard, temperature_coordinate, volume_angle, geometry_angle
    real(real64), volatile :: solar_visible, solar_infrared, ice_ar_total, ice_an_total, solar_total
    real(real64), volatile :: month_length, weight1, weight2
    real(real64) :: scale_ar, scale_an, angle, angle2, angle3
    real(real64) :: lake_ice, lake_water, moisture, capacity, wilting, reciprocal, a, b, t, total, coefficient
    real(real64) :: longwave_sum, longwave_weight, band_radiance, ice_ar, ice_an, albedo_diffuse, albedo_direct, lake_albedo
    real(real64) :: numerator, denominator, vegetated_urban, cloud_amount, cloud_exponent
    integer :: month1,month2,month_days,remaining_days,j,s,band,tile,degree,soil_type,forest_type,first_coefficient,child_status
    status = 2
    if (klon < 1 .or. klon > 4096 .or. kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (ktiles /= 9 .and. ktiles /= 10) return
    if (ksw /= 2 .and. ksw /= 6) return
    if (klw < 2 .or. klw > 32 .or. ydrad%nsw /= ksw) return
    if (ydrad%nuvvis < 1 .or. ydrad%nuvvis >= ksw .or. ydrad%nlwemiss < 2 .or. ydrad%nlwemiss > 16) return
    if (klw /= 2 .and. klw < ydrad%nlwemiss) return
    if(ydlw%nsil<1.or.ydlw%nsil>6.or.kddn<1.or.kddn>31.or.kmmn<1.or.kmmn>12.or.kseco<0.or.kseco>=86400) return
    if (size(kmon) < 12) return
    if (any(kmon(1:12) < 1) .or. any(kmon(1:12) > 31)) return
    if(min(size(ldnh),size(palbf),size(palbicef),size(ptvh),size(pcur),size(pcvh),size(pasn),size(pmu0),size(pts),size(pwnd),size(pws1),size(ksoty),size(phlice),size(ptlice),size(palb),size(pemit),size(pccnl),size(pccno))<klon) return
    if (size(palcoeff, 1) < klon .or. size(palcoeff, 2) < 4 .or. size(pfrti, 1) < klon .or. size(pfrti, 2) < ktiles) return
    if (ydrad%nalbedoscheme == 2 .and. size(palcoeff, 2) < 6) return
    if (size(palbd, 1) < klon .or. size(palbd, 2) < ksw .or. size(palbp, 1) < klon .or. size(palbp, 2) < ksw) return
    if(size(pspectralemiss,1)<klon.or.size(pspectralemiss,2)<klw.or.size(palbti,1)<klon.or.size(palbti,2)<ktiles) return
    if (.not. allocated(ydsw%rsun) .or. .not. allocated(ydsw%ralbice_ar) .or. .not. allocated(ydsw%ralbice_an)) return
    if(size(ydsw%rsun)<ksw.or.size(ydsw%ralbice_ar,1)<12.or.size(ydsw%ralbice_ar,2)<ksw.or.size(ydsw%ralbice_an,1)<12.or.size(ydsw%ralbice_an,2)<ksw) return
    if (.not. allocated(ydsoil%rwcapm) .or. .not. allocated(ydsoil%rwpwpm)) return
 if (lbound(ydsoil%rwcapm, 1) /= 0 .or. lbound(ydsoil%rwpwpm, 1) /= 0 .or. min(size(ydsoil%rwcapm), size(ydsoil%rwpwpm)) < 8) return
    do j = kidia, kfdia
      if (ksoty(j) < 0 .or. ksoty(j) > 7) return
      if (.not. (ptvh(j) >= 0.0_real64 .and. ptvh(j) <= 20.0_real64)) return
      if (ydsoil%levgen) then
        if (ksoty(j) > 0) then
          if (.not. (ydsoil%rwcapm(ksoty(j)) > ydsoil%rwpwpm(ksoty(j)))) return
        end if
      else
        if (.not. (ydsoil%rwcap > ydsoil%rwpwp)) return
      end if
    end do
    inverse_standard = 1.0_real64/ydlw%tstand
    if (kddn >= 15) then
      month1 = kmmn; month2 = 1 + mod(kmmn, 12)
      month_days = kmon(month1); remaining_days = month_days - kddn + 15
    else
      month1 = 1 + mod(kmmn + 10, 12); month2 = kmmn
      month_days = kmon(month1); remaining_days = 15 - kddn
    end if
    month_length = real(month_days, real64)*ydcst%rday
    a = real(remaining_days, real64)*ydcst%rday
    a = a - real(kseco, real64); weight1 = a/month_length; weight2 = 1.0_real64 - weight1
    solar_visible = 0.0_real64; solar_infrared = 0.0_real64
    ice_ar_total = 0.0_real64; ice_an_total = 0.0_real64; solar_total = 0.0_real64
    do band = 1, ksw
      t = ydsw%rsun(band)
      if (band <= ydrad%nuvvis) then
        solar_visible = solar_visible + t
      else
        solar_infrared = solar_infrared + t
      end if
      if (lnemolimalb) then
        solar_total = solar_total + t
        a = weight1*ydsw%ralbice_ar(month1, band); b = weight2*ydsw%ralbice_ar(month2, band)
        a = a + b; a = t*a; ice_ar_total = ice_ar_total + a
        a = weight1*ydsw%ralbice_an(month1, band); b = weight2*ydsw%ralbice_an(month2, band)
        a = a + b; a = t*a; ice_an_total = ice_an_total + a
      end if
    end do
    call canalb(kidia, kfdia, ydurb, pmu0, canyon_albedo, child_status)
    if (child_status /= 0) then
      status = 3; return
    end if
    do j = kidia, kfdia
      angle = public_acos(pmu0(j)); angle2 = angle*angle; angle3 = angle*angle2
      a = c(3)*angle2; b = c(2) - a; a = c(4)*angle3; volume_angle = b + a
      a = c(6)*angle2; b = c(5) - a; a = c(7)*angle3; geometry_angle = b + a
      a = pts(j) - ydlw%tstand; temperature_coordinate = a*inverse_standard
      lake_ice = 0.0_real64; lake_water = 1.0_real64
      if (ydflake%leflake) then
        if (phlice(j) > ydflake%rh_ice_min_flk) then
          lake_ice = 1.0_real64; lake_water = 0.0_real64
        end if
      end if
      if (ydsoil%levgen .and. ksoty(j) <= 0) then
        moisture = 1.0_real64
      else
        capacity = ydsoil%rwcap; wilting = ydsoil%rwpwp
        if (ydsoil%levgen) then
          soil_type = ksoty(j); capacity = ydsoil%rwcapm(soil_type); wilting = ydsoil%rwpwpm(soil_type)
        end if
        a = capacity - wilting; reciprocal = 1.0_real64/a
        a = pws1(j) - wilting; moisture = a*reciprocal
        moisture = min(moisture, 1.0_real64); moisture = max(moisture, 0.0_real64)
      end if
      do band = 1, ydrad%nlwemiss
        tile_emissivity(1) = ydrdi%remiss_sea(band); tile_emissivity(2) = ydrdi%remiss_snow(band)
        tile_emissivity(3) = ydrdi%remiss_land(band)
        a = 1.0_real64 - moisture; b = ydrdi%remiss_land(band)*moisture
        a = ydrdi%remiss_desert(band)*a; tile_emissivity(4) = b + a
        tile_emissivity(5) = tile_emissivity(2); tile_emissivity(6) = tile_emissivity(4); tile_emissivity(7) = tile_emissivity(4)
        tile_emissivity(8) = tile_emissivity(4)
        if (palbf(j) > c(8)) tile_emissivity(8) = ydrdi%remiss_desert(band)
        total = 0.0_real64
        do tile = 1, 8
          a = tile_emissivity(tile)*pfrti(j, tile); total = total + a
        end do
        if (ktiles == 10) then
          a = ydurb%rurbemis*pfrti(j, 10); total = total + a
        end if
        if (ydflake%leflake) then
          a = tile_emissivity(1)*lake_water; b = tile_emissivity(2)*lake_ice
          a = a + b; a = pfrti(j, 9)*a; total = total + a
        end if
        spectral(band) = total
      end do
      if (klw < ydrad%nlwemiss) then
        do s = 1, 2
          total = 0.0_real64
          do band = 1, ydrad%nlwemiss
            a = spectral(band)*ydrdi%remiss_old_weight(band, s); total = total + a
          end do
          pspectralemiss(j, s) = total
        end do
      else
        pspectralemiss(j, 1:ydrad%nlwemiss) = spectral(1:ydrad%nlwemiss)
      end if
      if (klw == 2) then
        longwave_sum = 0.0_real64; longwave_weight = 0.0_real64
        do band = 1, ydlw%nsil
          band_radiance = ydlw%xp(6, band)
          do degree = 5, 1, -1
            a = temperature_coordinate*band_radiance
            band_radiance = ydlw%xp(degree, band) + a
          end do
          longwave_sum = longwave_sum + band_radiance
          s = 2
          if (band == 3 .or. band == 4) s = 1
          a = band_radiance*pspectralemiss(j, s); longwave_weight = longwave_weight + a
        end do
        pemit(j) = longwave_weight/longwave_sum
      else
        total = 0.0_real64
        do band = 1, ydrad%nlwemiss
          a = pspectralemiss(j, band)*ydrdi%remiss_weight(band); total = total + a
        end do
        pemit(j) = total
      end if
      palb(j) = 0.0_real64; palbti(j, 1:ktiles) = 0.0_real64
      scale_ar = 1.0_real64; scale_an = 1.0_real64
      if (lnemolimalb .and. palbicef(j) > 0.0_real64) then
        a = palbicef(j)*solar_total; scale_ar = a/ice_ar_total; scale_an = a/ice_an_total
      end if
      do band = 1, ksw
        first_coefficient = 1
        if (band > ydrad%nuvvis) first_coefficient = 3
        select case (ydrad%nalbedoscheme)
        case (1)
          albedo_direct = palcoeff(j, first_coefficient); albedo_diffuse = palcoeff(j, first_coefficient + 1)
        case (3)
          albedo_diffuse = palcoeff(j, first_coefficient + 1); albedo_direct = albedo_diffuse
        case (2)
          first_coefficient = 1
          if (band > ydrad%nuvvis) first_coefficient = 4
          albedo_direct = palcoeff(j, first_coefficient); albedo_diffuse = albedo_direct
          a = palcoeff(j, first_coefficient + 1)*volume_angle; albedo_direct = albedo_direct + a
          a = palcoeff(j, first_coefficient + 1)*c(9); albedo_diffuse = albedo_diffuse + a
          a = palcoeff(j, first_coefficient + 2)*geometry_angle; albedo_direct = albedo_direct + a
          a = palcoeff(j, first_coefficient + 2)*c(10); albedo_diffuse = albedo_diffuse + a
        case default
          albedo_diffuse = palbf(j); albedo_direct = palbf(j)
        end select
        if (ydrad%nalbedoscheme >= 1 .and. ydrad%nalbedoscheme <= 3) then
          a = 1.0_real64 - ydrdi%repalb
          albedo_diffuse = max(albedo_diffuse, ydrdi%repalb); albedo_diffuse = min(a, albedo_diffuse)
          albedo_direct = max(albedo_direct, ydrdi%repalb); albedo_direct = min(a, albedo_direct)
        end if
        diffuse(3) = albedo_diffuse; diffuse(4) = albedo_diffuse; diffuse(6) = albedo_diffuse; diffuse(8) = albedo_diffuse
        direct(3) = albedo_direct; direct(4) = albedo_direct; direct(6) = albedo_direct; direct(8) = albedo_direct
        if (ktiles == 10) then
          a = 1.0_real64 + ydurb%rwrr; b = 1.0_real64/a; t = ydurb%rwrr/a
          b = ydurb%rrooalb*b; t = canyon_albedo(j)*t; coefficient = b + t
          diffuse(10) = coefficient; direct(10) = coefficient
          a = 1.0_real64 - pcur(j)
          b = albedo_diffuse*a; t = albedo_direct*a; coefficient = coefficient*pcur(j)
          diffuse(3) = b + coefficient; direct(3) = t + coefficient
        end if
        diffuse(1) = ydrdi%ralbsead
        a = power_original_rounding(pmu0(j), c(11)); a = c(12)*a; a = a + c(13)
        a = c(14)/a; direct(1) = max(a, ydrdi%repalb)
        a = weight1*ydsw%ralbice_ar(month1, band); b = weight2*ydsw%ralbice_ar(month2, band)
        a = a + b; a = scale_ar*a; ice_ar = min(1.0_real64, a)
        a = weight1*ydsw%ralbice_an(month1, band); b = weight2*ydsw%ralbice_an(month2, band)
        a = a + b; a = scale_an*a; ice_an = min(1.0_real64, a)
        ice_ar = merge(ice_ar, ice_an, ldnh(j)); diffuse(2) = ice_ar; direct(2) = ice_ar
        a = c(15) - pasn(j); a = c(16)*a; b = pasn(j) - c(17); b = c(18)*b; a = a + b
        b = c(15) - c(17); a = a/b; a = max(a, c(19)); a = min(c(20), a)
        if (band > ydrad%nuvvis) then
          a = a*solar_visible; a = pasn(j) - a; a = a/solar_infrared; a = max(a, c(19)); a = min(c(20), a)
        end if
        diffuse(5) = a; direct(5) = a
        forest_type = 0
        if (ydsoil%lesn09) forest_type = nint(ptvh(j))
        s = 1
        if (band > ydrad%nuvvis) s = 2
        coefficient = ydrdi%ralb_snow_forest(forest_type, s)
        if (ktiles == 10 .and. pcur(j) > 0.0_real64) then
          a = 1.0_real64 - pcur(j); vegetated_urban = pcvh(j)*a
          a = coefficient*vegetated_urban; b = c(21)*coefficient; t = c(21)*diffuse(10); b = b + t; b = b*pcur(j)
          a = a + b; denominator = vegetated_urban + pcur(j); coefficient = a/denominator
        end if
        diffuse(7) = coefficient; direct(7) = coefficient
        if (ydflake%leflake) then
          a = ydcst%rtt - ptlice(j); a = c(22)*a; a = a/ydcst%rtt; lake_albedo = public_exp(a)
        else
          lake_albedo = 1.0_real64
        end if
        a = 1.0_real64 - lake_albedo; a = c(23)*a; b = c(24)*lake_albedo; lake_albedo = a + b
        a = lake_albedo*lake_ice
        b = diffuse(1)*lake_water; diffuse(9) = b + a
        b = direct(1)*lake_water; direct(9) = b + a
        do tile = 1, ktiles
          if (tile == 9 .and. .not. ydflake%leflake) cycle
          a = diffuse(tile) + direct(tile); a = ydsw%rsun(band)*a; a = a*c(21)
          palbti(j, tile) = palbti(j, tile) + a
        end do
        a = pfrti(j, 1)*diffuse(1); b = pfrti(j, 1)*direct(1)
        do tile = 2, 8
          t = pfrti(j, tile)*diffuse(tile); a = a + t; t = pfrti(j, tile)*direct(tile); b = b + t
        end do
        if (ktiles == 10) then
          t = pfrti(j, 10)*diffuse(10); a = a + t; b = b + t
        end if
        if (ydflake%leflake) then
          t = pfrti(j, 9)*diffuse(9); a = a + t; t = pfrti(j, 9)*direct(9); b = b + t
        end if
        palbd(j, band) = a; palbp(j, band) = b
        a = ydsw%rsun(band)*a; palb(j) = palb(j) + a
      end do
      if (ydrad%lccno) then
        if (pwnd(j) > c(25)) then
          cloud_amount = c(31)
        else
          if (pwnd(j) > c(26)) then
            a = c(29)*pwnd(j); a = a + c(30)
          else
            a = c(27)*pwnd(j); a = a + c(28)
          end if
          cloud_amount = public_exp(a)
        end if
        a = public_log10(cloud_amount); a = c(21)*a; cloud_exponent = c(32) + a
        pccno(j) = power_original_rounding(c(33), cloud_exponent)
      else
        pccno(j) = ydrad%rccnsea
      end if
      if (ydrad%lccnl) then
        if (pwnd(j) > c(26)) then
          a = c(29)*pwnd(j); a = a + c(30)
        else
          a = c(27)*pwnd(j); a = a + c(34)
        end if
        cloud_amount = public_exp(a); a = public_log10(cloud_amount); a = c(8)*a
        cloud_exponent = c(35) + a; pccnl(j) = power_original_rounding(c(33), cloud_exponent)
      else
        pccnl(j) = ydrad%rccnlnd
      end if
    end do
    status = 0
  end subroutine
end module
