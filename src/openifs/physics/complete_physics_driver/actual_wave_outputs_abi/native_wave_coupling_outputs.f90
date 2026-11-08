! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Produce the source surface fields passed to the wave model.
module forecast_native_wave_coupling_outputs
  use iso_fortran_env, only: int32, real64, JPRB => real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use yoewcou, only: tewcou
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_surface_catalog_lookup, only: surface_catalog_index
  use forecast_physics_work_types, only: dimension_type, aux_type, flux_type, surf_and_more_type
  implicit none
  private
  public :: update_wave_coupling_outputs
contains
  !> Update active source-selected PSD_WW columns without allocating a new owner.
  !! CONSTANTS and WAVE are actual produced readonly records. CATALOG supplies MP
  !! indices. DIMENSIONS supplies inclusive point bounds and the bottom layer.
  !! TEMPERATURE(P,L) is T%PH9 in K; HUMIDITY(P,L) is Q%T9 in kg/kg.
  !! AUXILIARY carries PAPRSF in Pa; FLUX carries bottom turbulent fluxes.
  !! SURFACE borrows actual tile stresses and field views. Its active wave-output
  !! columns change in source order; other rows and columns stay unchanged.
  !! The caller supplies nearest-even rounding and gradual underflow.
  !! Status0 completes or skips disabled coupling;2 refuses before output writes.
  integer(int32) function update_wave_coupling_outputs(constants,wave,catalog,dimensions,temperature,humidity,auxiliary,flux,surface) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(tewcou), intent(in) :: wave
    type(surface_field_registry), intent(in) :: catalog
    type(dimension_type), intent(in) :: dimensions
    real(real64), intent(in) :: temperature(:, :), humidity(:, :)
    type(aux_type), intent(in) :: auxiliary
    type(flux_type), intent(in) :: flux
    type(surf_and_more_type), intent(inout) :: surface
    integer(int32) :: ww_u, ww_v, ww_rho, ww_zil, ww_cif, ww_clk, ww_ucur, ww_vcur
    integer(int32) :: vd_u, vd_v, vd_z0, vf_u, vf_v, vf_lsm, vf_ci, vf_clk
    integer(int32) :: jrof, jtile4wam, first, last, bottom
    real(real64) :: zkappa_pj, znlev_pj, zgznlev_pj, zipbl_pj, z1d3_pj
    real(real64) :: zrho_a, zrho_a_m1, ztau_u, ztau_v, zust, zlog, zrowq, zrowt, zbuo, zwst
    status = 0
    if (.not. wave%lwcou) return
    status = 2
    if (wave%natmflx < 1 .or. wave%natmflx > 3) return
    first = dimensions%kidia; last = dimensions%kfdia; bottom = dimensions%klev
    if (first < 1 .or. last < 0 .or. bottom < 1) return
    if (first > size(temperature, 1) + 1 .or. last > size(temperature, 1) .or. bottom > size(temperature, 2)) return
    if (first > size(humidity, 1) + 1 .or. last > size(humidity, 1) .or. bottom > size(humidity, 2)) return
    if (.not. covers(auxiliary%paprsf, first, last, bottom)) return
    if (.not. covers(flux%pdiftq, first, last, bottom)) return
    if (.not. covers(flux%pdifts, first, last, bottom)) return
    ww_u = surface_catalog_index(catalog, 'YSD_WW%YU10N', 1)
    ww_v = surface_catalog_index(catalog, 'YSD_WW%YV10N', 1)
    ww_rho = surface_catalog_index(catalog, 'YSD_WW%YRHO', 1)
    ww_zil = surface_catalog_index(catalog, 'YSD_WW%YZIL', 1)
    ww_cif = surface_catalog_index(catalog, 'YSD_WW%YCIF', 1)
    ww_clk = surface_catalog_index(catalog, 'YSD_WW%YCLK', 1)
    if (min(ww_u, ww_v, ww_rho, ww_zil, ww_cif, ww_clk) < 1) return
    if (.not. covers(surface%psd_ww, first, last, min(ww_u, ww_v, ww_rho, ww_zil, ww_cif, ww_clk))) return
    if (.not. covers(surface%psd_ww, first, last, max(ww_u, ww_v, ww_rho, ww_zil, ww_cif, ww_clk))) return
    vf_lsm = surface_catalog_index(catalog, 'YSD_VF%YLSM', 1)
    vf_ci = surface_catalog_index(catalog, 'YSD_VF%YCI', 1)
    vf_clk = surface_catalog_index(catalog, 'YSD_VF%YCLK', 1)
    if (min(vf_lsm, vf_ci, vf_clk) < 1) return
    if (.not. covers(surface%psd_vf, first, last, min(vf_lsm, vf_ci, vf_clk))) return
    if (.not. covers(surface%psd_vf, first, last, max(vf_lsm, vf_ci, vf_clk))) return
    vf_u = 0; vf_v = 0; vd_u = 0; vd_v = 0; vd_z0 = 0; ww_ucur = 0; ww_vcur = 0
    if (wave%lwcur .or. (wave%natmflx == 3 .and. wave%lwcournw)) then
      vf_u = surface_catalog_index(catalog, 'YSD_VF%YUCUR', 1)
      vf_v = surface_catalog_index(catalog, 'YSD_VF%YVCUR', 1)
      if (min(vf_u, vf_v) < 1) return
      if (.not. covers(surface%psd_vf, first, last, min(vf_u, vf_v))) return
      if (.not. covers(surface%psd_vf, first, last, max(vf_u, vf_v))) return
    end if
    if (wave%lwcur) then
      ww_ucur = surface_catalog_index(catalog, 'YSD_WW%YUCURW', 1)
      ww_vcur = surface_catalog_index(catalog, 'YSD_WW%YVCURW', 1)
      if (min(ww_ucur, ww_vcur) < 1) return
      if (.not. covers(surface%psd_ww, first, last, min(ww_ucur, ww_vcur))) return
      if (.not. covers(surface%psd_ww, first, last, max(ww_ucur, ww_vcur))) return
    end if
    if (wave%natmflx /= 3 .or. .not. wave%lwcournw) then
      if (.not. covers(surface%pustrti, first, last, 1)) return
      if (.not. covers(surface%pvstrti, first, last, 1)) return
    end if
    if (wave%natmflx == 3) then
      if (wave%lwcournw) then
        vd_u = surface_catalog_index(catalog, 'YSD_VD%Y10NU', 1)
        vd_v = surface_catalog_index(catalog, 'YSD_VD%Y10NV', 1)
        if (min(vd_u, vd_v) < 1) return
        if (.not. covers(surface%psd_vd, first, last, min(vd_u, vd_v))) return
        if (.not. covers(surface%psd_vd, first, last, max(vd_u, vd_v))) return
      else
        vd_z0 = surface_catalog_index(catalog, 'YSD_VD%YZ0F', 1)
        if (vd_z0 < 1) return
        if (.not. covers(surface%psd_vd, first, last, vd_z0)) return
      end if
    end if
    associate (dims => dimensions, rg => constants%rg, rd => constants%rd, retv => constants%retv, rcpd => constants%rcpd, &
               natmflx => wave%natmflx, lwcou => wave%lwcou, lwcournw => wave%lwcournw, lwcur => wave%lwcur, rmissw => wave%rmissw)
      IF (LWCOU) THEN

! STRUCTURE OF FIELDS TO WAVE MODEL IS AS FOLLOWS:
! SEE SU_SURF_FLDS and SURFACE_FIELDS_MIX.

!      YSD_WW%YU10N    10M NEUTRAL WIND U-COMPONENT
!      YSD_WW%YV10N    10M NEUTRAL WIND V-COMPONENT
!      YSD_WW%YRHO     AIR DENSITY AT SURFACE
!      YSD_WW%YZIL     ZI/L USED FOR GUSTINESS
!      YSD_WW%YCIF     SEA ICE FRACTION FOR THE SEA ICE BOUNDARY
!                       (ONLY ON SEA POINTS)

        ZKAPPA_PJ = 0.40_JPRB
        ZNLEV_PJ = 10._JPRB
        ZGZNLEV_PJ = ZNLEV_PJ*RG
        ZIPBL_PJ = 1000._JPRB
        Z1D3_PJ = 1._JPRB/3._JPRB

        DO JROF = DIMS%KIDIA, DIMS%KFDIA

!   COMPUTATION OF THE SURFACE AIR DENSITY
          ZRHO_A = auxiliary%PAPRSF(JROF, DIMS%KLEV)/(RD*temperature(JROF, DIMS%KLEV)*(&
               & 1.0_JPRB + RETV*humidity(JROF, DIMS%KLEV)))
          ZRHO_A_M1 = 1.0_JPRB/ZRHO_A

!   COMPUTATION OF THE COMPONENT OF MOMEMTUM FLUX THAT IS PASSED TO WAM
!   USING SURFACE FROM THE OCEAN TILE

          JTILE4WAM = 1

          SELECT CASE (NATMFLX)
!   NATMFLX=1  ::  FRICTION VELOCITY
          CASE (1)
            ZTAU_U = surface%PUSTRTI(JROF, JTILE4WAM)*ZRHO_A_M1
            ZTAU_V = surface%PVSTRTI(JROF, JTILE4WAM)*ZRHO_A_M1
            ZUST = MAX(0.0001_JPRB, (ZTAU_U**2 + ZTAU_V**2)**(0.25_JPRB))
            surface%PSD_WW(JROF, ww_u) = ZTAU_U/ZUST
            surface%PSD_WW(JROF, ww_v) = ZTAU_V/ZUST
!   NATMFLX=2  ::  SURFACE STRESS
          CASE (2)
            ZTAU_U = surface%PUSTRTI(JROF, JTILE4WAM)
            ZTAU_V = surface%PVSTRTI(JROF, JTILE4WAM)
            ZUST = MAX(0.0001_JPRB, (ZTAU_U**2 + ZTAU_V**2)**(0.5_JPRB))
            surface%PSD_WW(JROF, ww_u) = ZTAU_U/ZUST
            surface%PSD_WW(JROF, ww_v) = ZTAU_V/ZUST

!   NATMFLX=3  ::  NEUTRAL 10m WIND
          CASE (3)
!     use the neutral winds and substract ocean currents
            IF (LWCOURNW) THEN
              surface%PSD_WW(JROF, ww_u) = surface%PSD_VD(JROF, vd_u) - surface%PSD_VF(JROF, vf_u)
              surface%PSD_WW(JROF, ww_v) = surface%PSD_VD(JROF, vd_v) - surface%PSD_VF(JROF, vf_v)
            ELSE
!     use the stress equivalent neutral winds
              ZTAU_U = surface%PUSTRTI(JROF, JTILE4WAM)*ZRHO_A_M1
              ZTAU_V = surface%PVSTRTI(JROF, JTILE4WAM)*ZRHO_A_M1
              ZLOG = LOG(ZGZNLEV_PJ/surface%PSD_VD(JROF, vd_z0))/ZKAPPA_PJ
              ZUST = MAX(0.0001_JPRB, (ZTAU_U**2 + ZTAU_V**2)**(0.25_JPRB))
              surface%PSD_WW(JROF, ww_u) = ZTAU_U/ZUST*ZLOG
              surface%PSD_WW(JROF, ww_v) = ZTAU_V/ZUST*ZLOG
            END IF

          END SELECT

          ZROWQ = FLUX%PDIFTQ(JROF, DIMS%KLEV)
          ZROWT = FLUX%PDIFTS(JROF, DIMS%KLEV)/RCPD
          ZBUO = RG*(-RETV*ZROWQ - ZROWT/temperature(JROF, DIMS%KLEV))*ZRHO_A_M1
          IF (ZBUO > 0._JPRB) THEN
            ZWST = (ZIPBL_PJ*ZBUO)**Z1D3_PJ
          ELSE
            ZWST = 0._JPRB
          END IF

          surface%PSD_WW(JROF, ww_rho) = ZRHO_A
          surface%PSD_WW(JROF, ww_zil) = ZWST

!   Sea Ice fraction is only defined for sea points (this includes resolved lakes)
          IF (surface%PSD_VF(JROF, vf_lsm) <= 0.5_JPRB) THEN
            surface%PSD_WW(JROF, ww_cif) = surface%PSD_VF(JROF, vf_ci)
          ELSE
            surface%PSD_WW(JROF, ww_cif) = RMISSW
          END IF

!   Lake fraction
          surface%PSD_WW(JROF, ww_clk) = surface%PSD_VF(JROF, vf_clk)

!   Ocean currents were set to 0. over land
          IF (LWCUR) THEN
            surface%PSD_WW(JROF, ww_ucur) = surface%PSD_VF(JROF, vf_u)
            surface%PSD_WW(JROF, ww_vcur) = surface%PSD_VF(JROF, vf_v)
          END IF

        END DO

      END IF
    end associate
    status = 0
  end function update_wave_coupling_outputs
  !> Check a borrowed pointer before any bounds query or numerical field read.
  logical function covers(values, first, last, column)
    real(real64), pointer, contiguous, intent(in) :: values(:, :)
    integer(int32), intent(in) :: first, last, column
    covers = .false.
    if (.not. associated(values)) return
    if (lbound(values, 1) > first .or. ubound(values, 1) < last) return
    if (column < lbound(values, 2) .or. column > ubound(values, 2)) return
    covers = .true.
  end function covers
end module forecast_native_wave_coupling_outputs
