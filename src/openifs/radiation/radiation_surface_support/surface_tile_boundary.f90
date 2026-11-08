!> Native surface tile fractions from the complete SURFBC_CTL calculation.
!! Fractions and leaf-area indices are dimensionless. Snow and canopy water
!! use kg/m2, density kg/m3, and lake-ice thickness metres.
module forecast_native_surface_boundary
  use iso_fortran_env, only: int32, int64, real64
  use yos_surf, only: tsurf
  use yos_soil, only: tsoil
  use yos_veg, only: tveg
  use yos_flake, only: tflake
  use yos_ocean_ml, only: tocean_ml
  implicit none
  private
  public :: surfbc, surfbc_ctl
contains
  !> Read the owned surface record directly; preserve original array order.
  !! Native fields replace registered handles. Only selected output rows change.
  subroutine surfbc(ydsurf,kidia,kfdia,klon,ktiles,klevsn,ptvl,pco2typ,ptvh,psoty,psdor,pcvlc,pcvhc,pcurc,plailc,plaihc,plaili,plaihi,plsm,pci,pclake,phlice,pgemu,psnm1m,pwlm1m,prsnm1m,ldland,ldsice,ldlake,ldnh,ldocn_kpp,ktvl,kco2typ,ktvh,ksoty,pcvl,pcvh,pcur,plail,plaih,pwlmx,pfrti,status)
    type(tsurf), intent(in) :: ydsurf
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, klevsn
    real(real64), intent(in) :: ptvl(:), pco2typ(:), ptvh(:), psoty(:), psdor(:), pcvlc(:), pcvhc(:), pcurc(:)
    real(real64), intent(in) :: plailc(:), plaihc(:), plaili(:), plaihi(:), plsm(:), pci(:), pclake(:), phlice(:), pgemu(:)
    real(real64), intent(in) :: psnm1m(:, :), pwlm1m(:), prsnm1m(:, :)
    logical(int32), intent(inout) :: ldland(:), ldsice(:), ldlake(:), ldnh(:), ldocn_kpp(:)
    integer(int32), intent(inout) :: ktvl(:), kco2typ(:), ktvh(:), ksoty(:)
    real(real64), intent(inout) :: pcvl(:), pcvh(:), pcur(:), plail(:), plaih(:), pwlmx(:), pfrti(:, :)
    integer(int32), intent(out) :: status
    call surfbc_ctl(kidia,kfdia,klon,ktiles,klevsn,ptvl,pco2typ,ptvh,psoty,psdor,pcvlc,pcvhc,pcurc,plailc,plaihc,plaili,plaihi,plsm,pci,pclake,phlice,pgemu,psnm1m,pwlm1m,prsnm1m,ldland,ldsice,ldlake,ldnh,ldocn_kpp,ktvl,kco2typ,ktvh,ksoty,pcvl,pcvh,pcur,plail,plaih,pwlmx,pfrti,ydsurf%ysoil,ydsurf%yveg,ydsurf%yflake,ydsurf%yocean_ml,status)
  end subroutine

  !> Form all tile branches, snow/canopy cover and surface classifications.
  !! Rows1:4096,tiles8:16,snow layers0:512 are supported; nominal KLEVSN is
  !! metadata, while the complete PSNM1M second extent defines the reduction.
  !! Native arrays may have signed/gapped strides. Tables keep native bounds.
  !! All owners are caller-owned and outputs must be disjoint from inputs.
  !! Return0 after work,2 before mutation on unsupported metadata, or3 after
  !! a source physical predicate fails. Caller establishes the FP mode once.
  subroutine surfbc_ctl(kidia,kfdia,klon,ktiles,klevsn,ptvl,pco2typ,ptvh,psoty,psdor,pcvlc,pcvhc,pcurc,plailc,plaihc,plaili,plaihi,plsm,pci,pclake,phlice,pgemu,psnm1m,pwlm1m,prsnm1m,ldland,ldsice,ldlake,ldnh,ldocn_kpp,ktvl,kco2typ,ktvh,ksoty,pcvl,pcvh,pcur,plail,plaih,pwlmx,pfrti,ydsoil,ydveg,ydflake,ydocean_ml,status)
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, klevsn
    real(real64), intent(in) :: ptvl(:), pco2typ(:), ptvh(:), psoty(:), psdor(:), pcvlc(:), pcvhc(:), pcurc(:)
    real(real64), intent(in) :: plailc(:), plaihc(:), plaili(:), plaihi(:), plsm(:), pci(:), pclake(:), phlice(:), pgemu(:)
    real(real64), intent(in) :: psnm1m(:, :), pwlm1m(:), prsnm1m(:, :)
    logical(int32), intent(inout) :: ldland(:), ldsice(:), ldlake(:), ldnh(:), ldocn_kpp(:)
    integer(int32), intent(inout) :: ktvl(:), kco2typ(:), ktvh(:), ksoty(:)
    real(real64), intent(inout) :: pcvl(:), pcvh(:), pcur(:), plail(:), plaih(:), pwlmx(:), pfrti(:, :)
    integer(int32), intent(out) :: status
    type(tsoil), intent(in) :: ydsoil
    type(tveg), intent(in) :: ydveg
    type(tflake), intent(in) :: ydflake
    type(tocean_ml), intent(in) :: ydocean_ml
    integer :: j, k, t, low_type, high_type
    real(real64) :: low, high, urban, low_lai, high_lai, snow, wet, lake_ice, lake, low_part, high_part, bare
    real(real64) :: a, b, c, total, retained, capacity
    status = 2
    if (klon < 1 .or. klon > 4096 .or. ktiles < 8 .or. ktiles > 16) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (kidia > kfdia) then
      status = 0; return
    end if
    if (ydflake%leflake .and. ktiles < 9) return
    if(min(size(ptvl),size(pco2typ),size(ptvh),size(psoty),size(pcvlc),size(pcvhc),size(pcurc),size(plailc),size(plaihc),size(plaili),size(plaihi),size(plsm),size(pci),size(pclake),size(phlice),size(pwlm1m))<klon) return
    if (size(pgemu) < kfdia .or. size(psnm1m, 1) < klon .or. size(psnm1m, 2) > 512) return
    if (ydsoil%lesn09) then
      if (size(prsnm1m, 1) < klon .or. size(prsnm1m, 2) /= size(psnm1m, 2)) return
    end if
    if(min(size(ldland),size(ldsice),size(ldlake),size(ldnh),size(ldocn_kpp),size(ktvl),size(kco2typ),size(ktvh),size(ksoty),size(pcvl),size(pcvh),size(pcur),size(plail),size(plaih),size(pwlmx))<klon) return
    if (size(pfrti, 1) < klon .or. size(pfrti, 2) < ktiles) return
    if (.not. allocated(ydveg%rvcov)) return
    if (.not. ydveg%lelaiv) then
      if (.not. allocated(ydveg%rvlai)) return
    end if
    do j = kidia, kfdia
      if(.not.(abs(ptvl(j))<=1000000.0_real64.and.abs(ptvh(j))<=1000000.0_real64.and.abs(pco2typ(j))<=1000000.0_real64.and.abs(psoty(j))<=1000000.0_real64)) return
      low_type = nint(ptvl(j)); high_type = nint(ptvh(j))
      if (min(low_type, high_type) < lbound(ydveg%rvcov, 1) .or. max(low_type, high_type) > ubound(ydveg%rvcov, 1)) return
      if (.not. ydveg%lelaiv) then
        if (min(low_type, high_type) < lbound(ydveg%rvlai, 1) .or. max(low_type, high_type) > ubound(ydveg%rvlai, 1)) return
      end if
    end do
    do j = kidia, kfdia
      ktvl(j) = nint(ptvl(j)); kco2typ(j) = nint(pco2typ(j))
      ktvh(j) = nint(ptvh(j)); ksoty(j) = nint(psoty(j))
      if (ydveg%lelaiv) then
        if (ydveg%rlaiint > 0.0_real64) then
          low_lai = plaili(j); high_lai = plaihi(j)
        else
          low_lai = plailc(j); high_lai = plaihc(j)
        end if
      else
        low_lai = ydveg%rvlai(ktvl(j)); high_lai = ydveg%rvlai(ktvh(j))
      end if
      plail(j) = low_lai; plaih(j) = high_lai
      low = pcvlc(j)*ydveg%rvcov(ktvl(j)); high = pcvhc(j)*ydveg%rvcov(ktvh(j))
      pcvl(j) = low; pcvh(j) = high
      urban = pcurc(j)
      if (urban < 0.0_real64 .or. urban > 1.0_real64) urban = 0.0_real64
      pcur(j) = urban
      ldland(j) = plsm(j) > 0.5_real64
      ldlake(j) = ydflake%leflake .and. (ldland(j) .or. pclake(j) > 0.5_real64)
      ldsice(j) = .not. ldland(j) .and. .not. ldlake(j) .and. pci(j) > ydsoil%rcimin
      ldnh(j) = pgemu(j) > 0.0_real64
      ldocn_kpp(j) = ydocean_ml%leocml .and. .not. ldland(j) .and. .not. ldlake(j)
      total = 0.0_real64
      do k = 1, size(psnm1m, 2)
        a = psnm1m(j, k)
        if (ydsoil%lesn09) a = a/prsnm1m(j, k)
        total = total + a
      end do
      if (ydsoil%lesn09) total = 100.0_real64*total
      snow = total*ydsoil%rqsncr; snow = min(1.0_real64, snow); snow = max(0.0_real64, snow)
      a = 1.0_real64 - low; a = a - high; b = low*low_lai; a = a + b
      b = high*high_lai; a = a + b; capacity = ydsoil%rwlmax*a; pwlmx(j) = capacity
      wet = pwlm1m(j)/capacity; wet = min(1.0_real64, wet); wet = max(0.0_real64, wet)
      if (phlice(j) > ydflake%rh_ice_min_flk) then
        lake_ice = phlice(j)*10.0_real64
        lake_ice = min(1.0_real64, lake_ice); lake_ice = max(0.0_real64, lake_ice)
      else
        lake_ice = 0.0_real64
      end if
      pfrti(j, 1:ktiles) = 0.0_real64
      if (ydflake%leflake) then
        if (.not. ldland(j) .and. .not. ldlake(j)) then
          if (ldsice(j)) then
            a = max(ydsoil%rcimin, pci(j)); a = min(a, 1.0_real64)
            pfrti(j, 2) = a; pfrti(j, 1) = 1.0_real64 - a
          else
            pfrti(j, 1) = 1.0_real64
          end if
        else
          lake = 0.0_real64
          if (ldlake(j)) then
            lake = 1.0_real64
            if (ldland(j)) lake = pclake(j)
          end if
          if (ktiles > 9) then
            a = lake + urban
            if (a > 1.0_real64) then
              urban = 1.0_real64 - lake; pcur(j) = urban
            end if
          end if
          a = 1.0_real64 - lake; low_part = low*a; high_part = high*a
          bare = 1.0_real64 - low_part; bare = bare - high_part; bare = bare - lake
          a = 1.0_real64 - snow; b = wet*a
          c = low_part + high_part; c = c + bare; pfrti(j, 3) = b*c
          a = 1.0_real64 - snow; b = 1.0_real64 - wet
          c = low_part*a; pfrti(j, 4) = c*b
          c = bare + low_part; pfrti(j, 5) = snow*c
          c = high_part*a; pfrti(j, 6) = c*b
          pfrti(j, 7) = snow*high_part
          c = bare*a; pfrti(j, 8) = c*b
          if (ldlake(j) .and. phlice(j) > ydflake%rh_ice_min_flk) then
            pfrti(j, 9) = lake*lake_ice
            a = 1.0_real64 - lake_ice; pfrti(j, 1) = lake*a
          else
            pfrti(j, 9) = lake
          end if
          if (ktiles > 9) then
            a = 1.0_real64 - lake; a = a - urban; low_part = low*a; high_part = high*a
            bare = 1.0_real64 - low_part; bare = bare - high_part; bare = bare - lake; bare = bare - urban
            a = 1.0_real64 - snow; b = wet*a
            c = low_part + high_part; c = c + bare; c = c + urban; pfrti(j, 3) = b*c
            a = 1.0_real64 - snow; b = 1.0_real64 - wet
            c = low_part*a; pfrti(j, 4) = c*b
            c = bare + low_part; pfrti(j, 5) = snow*c
            c = high_part*a; pfrti(j, 6) = c*b
            c = high_part + urban; pfrti(j, 7) = snow*c
            c = bare*a; pfrti(j, 8) = c*b
            c = urban*a; pfrti(j, 10) = c*b
          end if
        end if
      else
        if (.not. ldland(j)) then
          if (ldsice(j)) then
            a = max(ydsoil%rcimin, pci(j)); pfrti(j, 2) = a; pfrti(j, 1) = 1.0_real64 - a
          else
            pfrti(j, 1) = 1.0_real64
          end if
        else
          a = 1.0_real64 - high; pfrti(j, 5) = snow*a; pfrti(j, 7) = snow*high
          a = 1.0_real64 - snow; pfrti(j, 3) = a*wet
          b = 1.0_real64 - wet; c = low*a; pfrti(j, 4) = c*b
          c = high*a; pfrti(j, 6) = c*b
          bare = 1.0_real64 - low; bare = bare - high; c = bare*a; pfrti(j, 8) = c*b
          if (ktiles > 9) then
            a = 1.0_real64 - urban; low_part = low*a; high_part = high*a
            c = high_part + urban; a = 1.0_real64 - c; pfrti(j, 5) = snow*a; pfrti(j, 7) = snow*c
            a = 1.0_real64 - snow; b = 1.0_real64 - wet
            c = low_part*a; pfrti(j, 4) = c*b; c = high_part*a; pfrti(j, 6) = c*b
            bare = 1.0_real64 - low_part; bare = bare - high_part; bare = bare - urban
            c = bare*a; pfrti(j, 8) = c*b; c = urban*a; pfrti(j, 10) = c*b
          end if
        end if
      end if
      if (ydsoil%rthrfrti > 0.0_real64) then
        retained = 0.0_real64
        do t = 1, ktiles
          if (pfrti(j, t) < ydsoil%rthrfrti) pfrti(j, t) = 0.0_real64
          retained = retained + pfrti(j, t)
        end do
        do t = 1, ktiles
          pfrti(j, t) = pfrti(j, t)/retained
        end do
      end if
      a = 1.0_real64 - low; a = a - high
      if (a < 0.0_real64) then
        status = 3; return
      end if
      total = 0.0_real64
      do t = 1, ktiles
        if (pfrti(j, t) < 0.0_real64) then
          status = 3; return
        end if
        total = total + pfrti(j, t)
      end do
      if (total > transfer(int(z'3ff028f5c28f5c29', int64), 0.0_real64)) then
        status = 3; return
      end if
    end do
    status = 0
  end subroutine
end module
