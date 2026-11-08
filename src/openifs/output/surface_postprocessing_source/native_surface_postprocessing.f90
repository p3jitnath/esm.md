!> Complete surface postprocessing after vertical diffusion.
module forecast_native_surface_postprocessing
  use iso_fortran_env, only: int32, real64
  use yos_cst, only: tcst
  use yos_exc, only: texc
  use yos_flake, only: tflake
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record, stability_parameter_record
  use forecast_native_surface_weather_children, only: sppcfl, sppgust, voskin
  implicit none
  private
  public :: surfpp_ctl
contains
  !> Return tile fluxes, screen weather, ocean skin and skin tendency.
  !! Original 63 arguments retain their order after the two readonly canonical
  !! thermal/stability records. Reals are FP64, integer controls are int32.
  !! Tile arrays have at least (KLON,KTILES), vectors at least KLON and optional
  !! diagnostics either no elements or at least (KLON,KTILES,11). Only active
  !! rows and declared tiles change. Every mutable owner is disjoint from all
  !! other consumed owners; readonly views may share storage. Time is seconds,
  !! heat flux W/m2, water flux kg/(m2 s), stress N/m2, temperature K, wind m/s,
  !! pressure Pa, roughness m, geopotential m2/s2 and static energy J/kg.
  !! Supported width is 1:4096, tiles 8:10; lake mode requires tile 9. Enabled
  !! ocean skin requires width at most 512 and contiguous consumed column views.
  !! Status 0 means success and 2 means an unsupported bound before writes.
  !! Canonical parameters and finite physical fields are caller preconditions.
  subroutine surfpp_ctl(thermal, stability, kidia, kfdia, klon, ktiles, kdhvtls, kdhftls, ptstep, &
                       pfrti, pahflti, pg0ti, pstrtulev, pstrtvlev, ptskm1m, pumlev, pvmlev, pqmlev, pgeomlev, pcptspp, pcptgzlev, &
                        paphms, pz0mw, pz0hw, pz0qw, pzdl, pqsapp, pblend, pfblend, pbuom, pz0m, pevapsnw, pssrflti, pslrfl, psst, &
                        pucurr, pvcurr, pustokes, pvstokes, ydcst, ydexc, ydflake, pahfsti, pevapti, ptske1, ptsktip1, &
                        pdiftslev, pdiftqlev, pustrti, pvstrti, ptskti, pahflev, pahflsb, pfwsb, &
                        pu10m, pv10m, pt2m, pd2m, pq2m, pgust, p10nu, p10nv, pust, pdhtls, prplrg, status)
    type(thermal_parameter_record), intent(in) :: thermal
    type(stability_parameter_record), intent(in) :: stability
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, kdhvtls, kdhftls
    real(real64), intent(in) :: ptstep, prplrg
    real(real64), intent(in) :: pfrti(:, :), pahflti(:, :), pg0ti(:, :)
    real(real64), intent(in) :: pstrtulev(:), pstrtvlev(:), ptskm1m(:), pumlev(:), pvmlev(:), pqmlev(:)
    real(real64), intent(in) :: pgeomlev(:), pcptspp(:), pcptgzlev(:), paphms(:)
    real(real64), intent(in) :: pz0mw(:), pz0hw(:), pz0qw(:), pzdl(:), pqsapp(:), pblend(:), pfblend(:)
    real(real64), intent(in) :: pbuom(:), pz0m(:), pevapsnw(:), pssrflti(:, :), pslrfl(:), psst(:)
    real(real64), intent(in) :: pucurr(:), pvcurr(:), pustokes(:), pvstokes(:)
    type(tcst), intent(in) :: ydcst
    type(texc), intent(in) :: ydexc
    type(tflake), intent(in) :: ydflake
    real(real64), intent(inout) :: pahfsti(:, :), pevapti(:, :), ptske1(:), ptsktip1(:, :)
    real(real64), intent(inout) :: pdiftslev(:), pdiftqlev(:), pustrti(:, :), pvstrti(:, :), ptskti(:, :)
    real(real64), intent(inout) :: pahflev(:), pahflsb(:), pfwsb(:)
    real(real64), intent(inout) :: pu10m(:), pv10m(:), pt2m(:), pd2m(:), pq2m(:), pgust(:)
    real(real64), intent(inout) :: p10nu(:), p10nv(:), pust(:), pdhtls(:, :, :)
    integer(int32), intent(out) :: status
    real(real64) :: skin_mean(max(1, min(klon, 4096))), heat_mean(max(1, min(klon, 4096)))
    real(real64) :: water_mean(max(1, min(klon, 4096))), stress_velocity(max(1, min(klon, 4096)))
    real(real64), volatile :: inverse_step, ground_diagnostic
    real(real64) :: work, work2, density, heat
    integer :: j, t
    integer(int32) :: child_status
    logical :: ocean
    status = 2
    if (klon < 1 .or. klon > 4096 .or. ktiles < 8 .or. ktiles > 10) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. (ptstep > 0.0_real64)) return
    inverse_step = 1.0_real64/ptstep
    if (.not. tile_owner(pfrti, klon, ktiles)) return
    if (.not. tile_owner(pahflti, klon, ktiles)) return
    if (.not. tile_owner(pg0ti, klon, ktiles)) return
    if (.not. tile_owner(pssrflti, klon, ktiles)) return
    if (.not. tile_owner(pahfsti, klon, ktiles)) return
    if (.not. tile_owner(pevapti, klon, ktiles)) return
    if (.not. tile_owner(ptsktip1, klon, ktiles)) return
    if (.not. tile_owner(pustrti, klon, ktiles)) return
    if (.not. tile_owner(pvstrti, klon, ktiles)) return
    if (.not. tile_owner(ptskti, klon, ktiles)) return
    if (min(size(pstrtulev), size(pstrtvlev), size(ptskm1m), size(pumlev), size(pvmlev), size(pqmlev)) < klon) return
    if (min(size(pgeomlev), size(pcptspp), size(pcptgzlev), size(paphms)) < klon) return
    if (min(size(pz0mw), size(pz0hw), size(pz0qw), size(pzdl), size(pqsapp), size(pblend), size(pfblend)) < klon) return
    if (min(size(pbuom), size(pz0m), size(pevapsnw), size(pslrfl), size(psst)) < klon) return
    if (min(size(pucurr), size(pvcurr), size(pustokes), size(pvstokes)) < klon) return
    if (min(size(ptske1), size(pdiftslev), size(pdiftqlev), size(pahflev), size(pahflsb), size(pfwsb)) < klon) return
    if(min(size(pu10m),size(pv10m),size(pt2m),size(pd2m),size(pq2m),size(pgust),size(p10nu),size(p10nv),size(pust))<klon)return
    if (size(pdhtls) > 0) then
      if (size(pdhtls, 1) < klon .or. size(pdhtls, 2) < ktiles .or. size(pdhtls, 3) < 11) return
    end if
    ocean = ydexc%leocwa .or. ydexc%leocco
    if (ocean) then
      if (klon > 512) return
      if (.not. is_contiguous(pumlev(1:klon)) .or. .not. is_contiguous(pvmlev(1:klon))) return
      if (.not. is_contiguous(pslrfl(1:klon)) .or. .not. is_contiguous(psst(1:klon))) return
      if (.not. is_contiguous(pustokes(1:klon)) .or. .not. is_contiguous(pvstokes(1:klon))) return
      if (.not. is_contiguous(pssrflti(1:klon, 1)) .or. .not. is_contiguous(pahfsti(1:klon, 1))) return
      if (.not. is_contiguous(pahflti(1:klon, 1)) .or. .not. is_contiguous(pustrti(1:klon, 1))) return
      if (.not. is_contiguous(pvstrti(1:klon, 1)) .or. .not. is_contiguous(ptskti(1:klon, 1))) return
      if (.not. is_contiguous(ptsktip1(1:klon, 1))) return
    end if
    if (ydflake%leflake .and. ktiles < 9) return
    if (.not. (prplrg > 0.0_real64)) return
    if (kidia > kfdia) then
      status = 0
      return
    end if
    do j = kidia, kfdia
      heat_mean(j) = 0.0_real64
      water_mean(j) = 0.0_real64
      pdiftslev(j) = 0.0_real64
      pdiftqlev(j) = 0.0_real64
    end do
    do t = 1, ktiles
      do j = kidia, kfdia
        work = pfrti(j, t)*pahfsti(j, t)
        heat_mean(j) = heat_mean(j) + work
        work = pfrti(j, t)*pevapti(j, t)
        water_mean(j) = water_mean(j) + work
      end do
    end do
    do t = 1, ktiles
      do j = kidia, kfdia
        work = pfrti(j, t)*pahfsti(j, t)
        pdiftslev(j) = pdiftslev(j) + work
        work = pfrti(j, t)*pevapti(j, t)
        pdiftqlev(j) = pdiftqlev(j) + work
        pustrti(j, t) = pstrtulev(j)
        pvstrti(j, t) = pstrtvlev(j)
        if (pfrti(j, t) == 0.0_real64 .and. t <= 8) then
          pahfsti(j, t) = heat_mean(j)
          pevapti(j, t) = water_mean(j)
        end if
      end do
    end do
    if (size(pdhtls) > 0) then
      do t = 1, ktiles
        do j = kidia, kfdia
          pdhtls(j, t, 8) = pfrti(j, t)*pahfsti(j, t)
          pdhtls(j, t, 9) = pfrti(j, t)*pahflti(j, t)
          ground_diagnostic = pfrti(j, t)*pg0ti(j, t)
          if (t == 1) then
            pdhtls(j, t, 10) = 0.0_real64
          else
            pdhtls(j, t, 10) = ground_diagnostic
          end if
          pdhtls(j, t, 11) = pfrti(j, t)*pevapti(j, t)
        end do
      end do
    end if
    do j = kidia, kfdia
      heat = pfrti(j, 1)*pahflti(j, 1)
      work = pfrti(j, 3)*pahflti(j, 3)
      heat = heat + work
      work = pfrti(j, 4)*pahflti(j, 4)
      heat = heat + work
      work = pfrti(j, 6)*pahflti(j, 6)
      heat = heat + work
      work = ydcst%rlstt*pevapsnw(j)
      work = pahflti(j, 7) - work
      work = pfrti(j, 7)*work
      heat = heat + work
      work = pfrti(j, 8)*pahflti(j, 8)
      heat = heat + work
      if (ydflake%leflake) then
        work = pfrti(j, 9)*pahflti(j, 9)
        heat = heat + work
      end if
      pahflev(j) = heat
      heat = pfrti(j, 2)*pahflti(j, 2)
      work = pfrti(j, 5)*pahflti(j, 5)
      heat = heat + work
      work = pfrti(j, 7)*ydcst%rlstt
      work = work*pevapsnw(j)
      pahflsb(j) = heat + work
      heat = pfrti(j, 5)*pevapti(j, 5)
      work = pfrti(j, 7)*pevapsnw(j)
      pfwsb(j) = heat + work
    end do
    do j = kidia, kfdia
      work = ydcst%rd*ptskm1m(j)
      work2 = ydcst%retv*pqmlev(j)
      work2 = 1.0_real64 + work2
      work = work*work2
      density = paphms(j)/work
      work = pstrtulev(j)*pstrtulev(j)
      work2 = pstrtvlev(j)*pstrtvlev(j)
      work = work + work2
      work = sqrt(work)
      work = work/density
      work = sqrt(work)
      stress_velocity(j) = max(ydexc%repust, work)
    end do
    call sppcfl(thermal, stability, kidia, kfdia, klon, pumlev, pvmlev, pqmlev, pgeomlev, pcptspp, pcptgzlev, &
                paphms, pz0mw, pz0hw, pz0qw, pzdl, pqsapp, pblend, pfblend, pucurr, pvcurr, ydcst, ydexc, &
                pu10m, pv10m, p10nu, p10nv, pust, pt2m, pd2m, pq2m, prplrg, child_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    call sppgust(kidia, kfdia, klon, pz0m, pbuom, stress_velocity(1:klon), pu10m, pv10m, ydcst, ydexc, pgust, child_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    if (ocean) then
      call voskin(kidia, kfdia, klon, ptstep, pssrflti(1:klon, 1), pslrfl(1:klon), pahfsti(1:klon, 1), pahflti(1:klon, 1), &
                  pustrti(1:klon, 1), pvstrti(1:klon, 1), pumlev(1:klon), pvmlev(1:klon), ptskti(1:klon, 1), psst(1:klon), &
                  pustokes(1:klon), pvstokes(1:klon), ydcst, ydexc, ptsktip1(1:klon, 1), prplrg, child_status)
      if (child_status /= 0) then
        status = child_status
        return
      end if
    end if
    do j = kidia, kfdia
      skin_mean(j) = 0.0_real64
    end do
    do t = 1, ktiles
      do j = kidia, kfdia
        work = pfrti(j, t)*ptsktip1(j, t)
        skin_mean(j) = skin_mean(j) + work
      end do
    end do
    do t = 1, ktiles
      do j = kidia, kfdia
        if (pfrti(j, t) == 0.0_real64 .and. t <= 8) then
          ptskti(j, t) = skin_mean(j)
        else
          ptskti(j, t) = ptsktip1(j, t)
        end if
      end do
    end do
    do j = kidia, kfdia
      work = skin_mean(j) - ptskm1m(j)
      work = work*inverse_step
      ptske1(j) = ptske1(j) + work
    end do
    status = 0
  end subroutine surfpp_ctl

  !> Check a native tile view without touching its physical payload.
  pure logical function tile_owner(owner, columns, tiles)
    real(real64), intent(in) :: owner(:, :)
    integer(int32), intent(in) :: columns, tiles
    tile_owner = size(owner, 1) >= columns .and. size(owner, 2) >= tiles
  end function
end module forecast_native_surface_postprocessing
