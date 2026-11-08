!> Apply the complete source daily-snapshot surface update on canonical owners.
module forecast_daily_climate_surface
  use iso_fortran_env, only: int32, int64, real64
  use yoephy, only: tephy
  use physical_constant_setup_port, only: forecast_physical_constants
  use yos_surf, only: tsurf
  use native_inactive_startup_controls, only: native_climate_coupling_controls
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry
  implicit none
  private
  public :: apply_daily_climate_surface_snapshot
contains
!> Preserve source surface arithmetic after the day's climate fields are loaded.
!! CLIMR(local_points,1,15) and named fields remain caller-owned. Pressure is
!! absent here; temperatures are K, sea-ice/albedo/LAI values use source units.
!! Only real local points change; blocked-array padding is retained.
integer(int32)function apply_daily_climate_surface_snapshot(constants,physics,surface,climate,fields,catalog,ngptot,nproma)result(status)
  type(forecast_physical_constants), intent(in) :: constants
  type(tephy), intent(in) :: physics
  type(tsurf), intent(in) :: surface
  type(native_climate_coupling_controls), intent(inout) :: climate
  type(surface_field_state), intent(inout) :: fields
  type(surface_field_registry), intent(in) :: catalog
  integer(int32), intent(in) :: ngptot, nproma
  integer :: iclIm, jcl, jroF, jstglo, iend, ibl, ipar139, ipar31, ipar174, ipar131, ipar132, jgribc, iparmal
  real(real64), volatile :: zr2d
  real(real64) :: zts, zci, zsstci, zdsst0, zrtfreezsice, zrtmeltsice, zrcimin
  logical :: llicen(max(1, min(nproma, 1024))), lliceo(max(1, min(nproma, 1024))), llake(max(1, min(nproma, 1024))), llmiss
integer::i_ysd_vf_yalbf,i_ysd_vf_yalnig,i_ysd_vf_yalnii,i_ysd_vf_yalniv,i_ysd_vf_yaluvg,i_ysd_vf_yaluvi,i_ysd_vf_yaluvv,i_ysd_vf_yci,i_ysd_vf_yclk,i_ysd_vf_ylaih,i_ysd_vf_ylail,i_ysd_vf_ylsm,i_ysd_vf_ysst,i_ysp_rr_yt,i_ysp_sb_yt,i_ysp_sb_ytl,i_ysp_sl_ylicd,i_ysp_sl_ylmlt
  status = 2_int32
  if (ngptot < 1 .or. ngptot > 6599680 .or. nproma < 1 .or. nproma > 1024) return
  if (physics%nalbedoscheme /= 2 .or. physics%lecurr .or. physics%leobc .or. physics%leobcice .or. physics%leoclake) return
  if (physics%leocml .or. physics%locmltke) return
  if (climate%lmcciec .or. climate%lmcc04 .or. climate%lnemocoup .or. climate%lnemo1way) return
  if (climate%nclimr /= 15 .or. climate%np1 /= 1 .or. climate%np2 /= 1) return
  if (.not. allocated(climate%climr)) return
  if (size(climate%climr, 1) /= ngptot .or. size(climate%climr, 2) /= 1 .or. size(climate%climr, 3) /= 15) return
  if (any(climate%ncligc(1:15) /= [31, 139, 174, 15, 16, 17, 18, 210186, 210187, 210188, 210189, 210190, 210191, 66, 67])) return
  if (.not. catalog%ready) return
if(.not.allocated(fields%sd_vf).or..not.allocated(fields%sp_sb).or..not.allocated(fields%sp_sl).or..not.allocated(fields%sp_rr))return
if(size(fields%sd_vf,1)/=nproma.or.size(fields%sp_sb,1)/=nproma.or.size(fields%sp_sl,1)/=nproma.or.size(fields%sp_rr,1)/=nproma)return
  if(min(size(fields%sd_vf,3),size(fields%sp_sb,4),size(fields%sp_sl,3),size(fields%sp_rr,3))<(ngptot+nproma-1)/nproma)return
  if (size(fields%sp_sb, 2) < 4) return
  if (.not. any(climate%nssticeop == [0, 1, 2, 3, 4, 9])) return
  i_ysd_vf_yalbf = native_surface_index(catalog, 'YSD_VF%YALBF', 10)
  if (i_ysd_vf_yalbf < 1 .or. i_ysd_vf_yalbf > size(fields%sd_vf, 2)) return
  i_ysd_vf_yalnig = native_surface_index(catalog, 'YSD_VF%YALNIG', 10)
  if (i_ysd_vf_yalnig < 1 .or. i_ysd_vf_yalnig > size(fields%sd_vf, 2)) return
  i_ysd_vf_yalnii = native_surface_index(catalog, 'YSD_VF%YALNII', 10)
  if (i_ysd_vf_yalnii < 1 .or. i_ysd_vf_yalnii > size(fields%sd_vf, 2)) return
  i_ysd_vf_yalniv = native_surface_index(catalog, 'YSD_VF%YALNIV', 10)
  if (i_ysd_vf_yalniv < 1 .or. i_ysd_vf_yalniv > size(fields%sd_vf, 2)) return
  i_ysd_vf_yaluvg = native_surface_index(catalog, 'YSD_VF%YALUVG', 10)
  if (i_ysd_vf_yaluvg < 1 .or. i_ysd_vf_yaluvg > size(fields%sd_vf, 2)) return
  i_ysd_vf_yaluvi = native_surface_index(catalog, 'YSD_VF%YALUVI', 10)
  if (i_ysd_vf_yaluvi < 1 .or. i_ysd_vf_yaluvi > size(fields%sd_vf, 2)) return
  i_ysd_vf_yaluvv = native_surface_index(catalog, 'YSD_VF%YALUVV', 10)
  if (i_ysd_vf_yaluvv < 1 .or. i_ysd_vf_yaluvv > size(fields%sd_vf, 2)) return
  i_ysd_vf_yci = native_surface_index(catalog, 'YSD_VF%YCI', 10)
  if (i_ysd_vf_yci < 1 .or. i_ysd_vf_yci > size(fields%sd_vf, 2)) return
  i_ysd_vf_yclk = native_surface_index(catalog, 'YSD_VF%YCLK', 10)
  if (i_ysd_vf_yclk < 1 .or. i_ysd_vf_yclk > size(fields%sd_vf, 2)) return
  i_ysd_vf_ylaih = native_surface_index(catalog, 'YSD_VF%YLAIH', 10)
  if (i_ysd_vf_ylaih < 1 .or. i_ysd_vf_ylaih > size(fields%sd_vf, 2)) return
  i_ysd_vf_ylail = native_surface_index(catalog, 'YSD_VF%YLAIL', 10)
  if (i_ysd_vf_ylail < 1 .or. i_ysd_vf_ylail > size(fields%sd_vf, 2)) return
  i_ysd_vf_ylsm = native_surface_index(catalog, 'YSD_VF%YLSM', 10)
  if (i_ysd_vf_ylsm < 1 .or. i_ysd_vf_ylsm > size(fields%sd_vf, 2)) return
  i_ysd_vf_ysst = native_surface_index(catalog, 'YSD_VF%YSST', 10)
  if (i_ysd_vf_ysst < 1 .or. i_ysd_vf_ysst > size(fields%sd_vf, 2)) return
  i_ysp_rr_yt = native_surface_index(catalog, 'YSP_RR%YT', 4)
  if (i_ysp_rr_yt < 1 .or. i_ysp_rr_yt > size(fields%sp_rr, 2)) return
  i_ysp_sb_yt = native_surface_index(catalog, 'YSP_SB%YT', 1)
  if (i_ysp_sb_yt < 1 .or. i_ysp_sb_yt > size(fields%sp_sb, 3)) return
  i_ysp_sb_ytl = native_surface_index(catalog, 'YSP_SB%YTL', 1)
  if (i_ysp_sb_ytl < 1 .or. i_ysp_sb_ytl > size(fields%sp_sb, 3)) return
  i_ysp_sl_ylicd = native_surface_index(catalog, 'YSP_SL%YLICD', 3)
  if (i_ysp_sl_ylicd < 1 .or. i_ysp_sl_ylicd > size(fields%sp_sl, 2)) return
  i_ysp_sl_ylmlt = native_surface_index(catalog, 'YSP_SL%YLMLT', 3)
  if (i_ysp_sl_ylmlt < 1 .or. i_ysp_sl_ylmlt > size(fields%sp_sl, 2)) return
  iclIm = climate%nclimr
  zrtfreezsice = surface%ysoil%rtfreezsice
  zrtmeltsice = surface%ysoil%rtmeltsice
  zrcimin = surface%ysoil%rcimin
  IF (physics%leflake .AND. physics%leolakesst .AND. (.NOT. .false. .OR. .false.)) THEN

    IPAR139 = 0
    DO JCL = 1, ICLIM
      IF (climate%ncligc(JCL) == 139) THEN
        IPAR139 = JCL
        EXIT
      END IF
    END DO

    IPAR31 = 0
    DO JCL = 1, ICLIM
      IF (climate%ncligc(JCL) == 31) THEN
        IPAR31 = JCL
        EXIT
      END IF
    END DO

    IF (IPAR139 == 0 .or. IPAR31 == 0) THEN
      status = 4_int32; return
    END IF

    DO JSTGLO = 1, NGPTOT, NPROMA

      IEND = MIN(NPROMA, NGPTOT - JSTGLO + 1)
      IBL = (JSTGLO - 1)/NPROMA + 1

      DO JROF = 1, IEND
        ! LAKE POINT IN FLAKE.
        IF (fields%sd_vf(JROF, i_ysd_vf_yclk, IBL) > 0.5_real64) THEN
          ! SST
          climate%climr(JSTGLO + JROF - 1, climate%np2, IPAR139) = REAL(fields%sp_sl(JROF, i_ysp_sl_ylmlt, IBL), real64)
          ! CI OVER LAKES DERIVED FROM ICE THICKNESS
          ! GOYETTE ET AL. (2000) ATMOS.-OCEAN 38, 481-503
          IF (fields%sp_sl(JROF, i_ysp_sl_ylicd, IBL) > 0.65_real64) THEN
            climate%climr(JSTGLO + JROF - 1, climate%np2, IPAR31) = 1.0_real64
          ELSEIF (fields%sp_sl(JROF, i_ysp_sl_ylicd, IBL) > 0.05_real64) THEN
 climate%climr(JSTGLO+JROF-1,climate%np2,IPAR31) = REAL(1.287_real64*SQRT(fields%sp_sl(JROF,i_ysp_sl_ylicd,IBL)-0.05_real64),real64)
          ELSE
            climate%climr(JSTGLO + JROF - 1, climate%np2, IPAR31) = 0.0_real64
          END IF
        END IF

      END DO

    END DO

  END IF
  DO JSTGLO = 1, NGPTOT, NPROMA
    IEND = MIN(NPROMA, NGPTOT - JSTGLO + 1)
    IBL = (JSTGLO - 1)/NPROMA + 1

! 174, albedo
    DO JCL = 1, ICLIM
      IF (climate%ncligc(JCL) == 174) EXIT
    END DO
    IPAR174 = JCL
    DO JROF = 1, IEND
      ZTS = REAL(climate%climr(JSTGLO + JROF - 1, climate%np2, IPAR174), real64)
      fields%sd_vf(JROF, i_ysd_vf_yalbf, IBL) = ZTS
    END DO

!-- MODIS albedo (2x3-components) grib codes: 210186-210191
    DO JGRIBC = 210186, 210191
      IPARMAL = -1
      DO JCL = 1, ICLIM
        IF (climate%ncligc(JCL) == JGRIBC) THEN
          IPARMAL = JCL
          EXIT
        END IF
      END DO
      IF (IPARMAL > 0) THEN
        DO JROF = 1, IEND
          ZTS = climate%climr(JSTGLO + JROF - 1, climate%np2, IPARMAL)
          IF (JGRIBC == 210186) THEN
            fields%sd_vf(JROF, i_ysd_vf_yaluvi, IBL) = ZTS
          ELSEIF (JGRIBC == 210187) THEN
            fields%sd_vf(JROF, i_ysd_vf_yaluvv, IBL) = ZTS
          ELSEIF (JGRIBC == 210188) THEN
            fields%sd_vf(JROF, i_ysd_vf_yaluvg, IBL) = ZTS
          ELSEIF (JGRIBC == 210189) THEN
            fields%sd_vf(JROF, i_ysd_vf_yalnii, IBL) = ZTS
          ELSEIF (JGRIBC == 210190) THEN
            fields%sd_vf(JROF, i_ysd_vf_yalniv, IBL) = ZTS
          ELSEIF (JGRIBC == 210191) THEN
            fields%sd_vf(JROF, i_ysd_vf_yalnig, IBL) = ZTS
          END IF
        END DO
      END IF
    END DO

!-- LAI Low/High grib codes 66, 67
    DO JGRIBC = 66, 67
      IPARMAL = -1
      DO JCL = 1, ICLIM
        IF (climate%ncligc(JCL) == JGRIBC) THEN
          IPARMAL = JCL
          EXIT
        END IF
      END DO
      IF (IPARMAL > 0) THEN
        DO JROF = 1, IEND
          ZTS = REAL(climate%climr(JSTGLO + JROF - 1, climate%np2, IPARMAL), real64)

          IF (JGRIBC == 66) THEN
            fields%sd_vf(JROF, i_ysd_vf_ylail, IBL) = ZTS
          ELSEIF (JGRIBC == 67) THEN
            fields%sd_vf(JROF, i_ysd_vf_ylaih, IBL) = ZTS
          END IF
        END DO
      END IF
    END DO

! For NEMO single executable coupling updates to ocean fields are now
! done in updnemoocean.F90
! Fill arrays, ensuring compatibility of ice T, ice cover, SST and
!    surface T

    IPAR139 = 0
    DO JCL = 1, ICLIM
      IF (climate%ncligc(JCL) == 139) THEN
        IPAR139 = JCL
        EXIT
      END IF
    END DO

    IPAR31 = 0
    DO JCL = 1, ICLIM
      IF (climate%ncligc(JCL) == 31) THEN
        IPAR31 = JCL
        EXIT
      END IF
    END DO

    IF (IPAR139 == 0 .or. IPAR31 == 0) THEN
      status = 4_int32; return
    END IF

    ZR2D = 180.0_real64/constants%rpi

    DO JROF = 1, IEND

      IF (fields%sd_vf(JROF, i_ysd_vf_ylsm, IBL) <= 0.5_real64) THEN

!  No monthly interpolation of SST possible from OASIS
        ZTS = REAL(climate%climr(JSTGLO + JROF - 1, climate%np2, IPAR139), real64)
        ZCI = REAL(climate%climr(JSTGLO + JROF - 1, climate%np2, IPAR31), real64)
!    DEFINE LOGICALS FOR RESOLVED LAKES
        LLAKE(JROF) = (fields%sd_vf(JROF, i_ysd_vf_yclk, IBL) > 0.5_real64)
!    DEFINE LOGICALS FOR OLD AND NEW SEA-ICE
        LLICEO(JROF) = fields%sd_vf(JROF, i_ysd_vf_yci, IBL) > ZRCIMIN
        LLICEN(JROF) = ZCI > ZRCIMIN

        IF (LLICEN(JROF)) THEN
          fields%sd_vf(JROF, i_ysd_vf_yci, IBL) = ZCI
        ELSE
          fields%sd_vf(JROF, i_ysd_vf_yci, IBL) = 0.
        END IF
!TEST FOR MISSING DATA IN SST
        LLMISS = (ZTS == 19591204.0_real64)

!UPDATE ICE and OCEAN TEMPERATURES
!---------------------------------
        IF (LLICEN(JROF) .AND. LLICEO(JROF)) THEN
! SEA-ICE TO SEA-ICE
          IF (.NOT. LLAKE(JROF)) THEN
            IF (LLMISS) ZTS = fields%sp_rr(JROF, i_ysp_rr_yt, IBL)

            SELECT CASE (climate%nssticeop) ! INTEGER NUMBER CORRESPONDING TO SSTICEOPT CHOICE IN SSA
            CASE (9) ! SST already corrected in the analysis - trust SST field
              ZSSTCI = MAX(ZTS, ZRTFREEZSICE)
            CASE (1) !'T0220' - use weighted average of sst and ZRTFREEZSICE weight=(tanh((icecover-0.2)*20)+1)/2
 ZSSTCI = ZRTFREEZSICE*0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.2_real64)*20.0_real64) + 1.0_real64)            &
                           & + MAX(ZTS, ZRTFREEZSICE)                                                                              &
                  & *(1.0_real64 - 0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.2_real64)*20.0_real64) + 1.0_real64))
            CASE (0) !'orig' - SST is freezing temperature of ice if any ice present
              IF (LLICEN(JROF)) THEN
                ZSSTCI = ZRTFREEZSICE
              ELSE
                ZSSTCI = ZTS
              END IF
            CASE (2) !'T0310' use weighted average of sst and ZRTFREEZSICE weight=(tanh((icecover-0.3)*10)+1)/2
 ZSSTCI = ZRTFREEZSICE*0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.3_real64)*10.0_real64) + 1.0_real64)            &
                           & + MAX(ZTS, ZRTFREEZSICE)                                                                              &
                  & *(1.0_real64 - 0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.3_real64)*10.0_real64) + 1.0_real64))
            CASE (3) !'L20' for ice concentration greater than 20% reset to -1.8C else linear weight sst/ZRTFREEZSICE
              IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) > 0.2_real64) ZSSTCI = ZRTFREEZSICE
 IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) <= 0.2_real64) ZSSTCI = ZRTFREEZSICE*fields%sd_vf(JROF, i_ysd_vf_yci, IBL)              &
                                                       & + MAX(ZTS, ZRTFREEZSICE)*(1_real64 - fields%sd_vf(JROF, i_ysd_vf_yci, IBL))
            CASE (4) !'L50' for ice concentration greater than 50% reset to -1.8C else linear weight sst/ZRTFREEZSICE
              IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) > 0.5_real64) ZSSTCI = ZRTFREEZSICE
 IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) <= 0.5_real64) ZSSTCI = ZRTFREEZSICE*fields%sd_vf(JROF, i_ysd_vf_yci, IBL)              &
                                                       & + MAX(ZTS, ZRTFREEZSICE)*(1_real64 - fields%sd_vf(JROF, i_ysd_vf_yci, IBL))
            CASE DEFAULT
              status = 4_int32; return
            END SELECT

            IF (physics%leocwa .OR. physics%leocco) THEN
              ZDSST0 = ZSSTCI - fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
            ELSE
              ZDSST0 = 0.0_real64
            END IF

            IF (LLMISS) ZDSST0 = 0.0_real64

            fields%sd_vf(JROF, i_ysd_vf_ysst, IBL) = ZSSTCI

          ELSE
!         if sea ice present but a lake point then:
            fields%sd_vf(JROF, i_ysd_vf_ysst, IBL) = ZRTFREEZSICE
          END IF

          fields%sp_sb(JROF,1,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,1,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
          fields%sp_sb(JROF,2,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,2,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
          fields%sp_sb(JROF,3,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,3,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
          fields%sp_sb(JROF,4,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,4,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
! RESTORE SKIN TEMPERATURE ONLY ON OCEAN IF FLAKE IS ACTIVE
          IF (.NOT. (physics%leflake)) THEN
            fields%sp_rr(JROF, i_ysp_rr_yt, IBL) = fields%sp_sb(JROF, 1, i_ysp_sb_yt, IBL)
          ELSEIF (.NOT. LLAKE(JROF)) THEN
            fields%sp_rr(JROF, i_ysp_rr_yt, IBL) = fields%sp_sb(JROF, 1, i_ysp_sb_yt, IBL)
          END IF
        ELSEIF (LLICEN(JROF) .AND. .NOT. LLICEO(JROF)) THEN
! SEA TO SEA-ICE
          IF (.NOT. LLAKE(JROF)) THEN
            IF (LLMISS) ZTS = fields%sp_rr(JROF, i_ysp_rr_yt, IBL)

            SELECT CASE (climate%nssticeop) ! INTEGER NUMBER CORRESPONDING TO SSTICEOPT CHOICE IN SSA
            CASE (9) ! SST already corrected in the analysis - trust SST field
              ZSSTCI = MAX(ZTS, ZRTFREEZSICE)
            CASE (1) !'T0220' - use weighted average of sst and ZRTFREEZSICE weight=(tanh((icecover-0.2)*20)+1)/2
 ZSSTCI = ZRTFREEZSICE*0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.2_real64)*20.0_real64) + 1.0_real64)            &
                           & + MAX(ZTS, ZRTFREEZSICE)                                                                              &
                  & *(1.0_real64 - 0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.2_real64)*20.0_real64) + 1.0_real64))
            CASE (0) !'orig' - SST is freezing temperature of ice if any ice present
              IF (LLICEN(JROF)) THEN
                ZSSTCI = ZRTFREEZSICE
              ELSE
                ZSSTCI = ZTS
              END IF
            CASE (2) !'T0310' use weighted average of sst and ZRTFREEZSICE weight=(tanh((icecover-0.3)*10)+1)/2
 ZSSTCI = ZRTFREEZSICE*0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.3_real64)*10.0_real64) + 1.0_real64)            &
                           & + MAX(ZTS, ZRTFREEZSICE)                                                                              &
                  & *(1.0_real64 - 0.5_real64*(TANH((fields%sd_vf(JROF, i_ysd_vf_yci, IBL) - 0.3_real64)*10.0_real64) + 1.0_real64))
            CASE (3) !'L20' for ice concentration greater than 20% reset to -1.8C else linear weight sst/ZRTFREEZSICE
              IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) > 0.2_real64) ZSSTCI = ZRTFREEZSICE
 IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) <= 0.2_real64) ZSSTCI = ZRTFREEZSICE*fields%sd_vf(JROF, i_ysd_vf_yci, IBL)              &
                                                       & + MAX(ZTS, ZRTFREEZSICE)*(1_real64 - fields%sd_vf(JROF, i_ysd_vf_yci, IBL))
            CASE (4) !'L50' for ice concentration greater than 50% reset to -1.8C else linear weight sst/ZRTFREEZSICE
              IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) > 0.5_real64) ZSSTCI = ZRTFREEZSICE
 IF (fields%sd_vf(JROF, i_ysd_vf_yci, IBL) <= 0.5_real64) ZSSTCI = ZRTFREEZSICE*fields%sd_vf(JROF, i_ysd_vf_yci, IBL)              &
                                                       & + MAX(ZTS, ZRTFREEZSICE)*(1_real64 - fields%sd_vf(JROF, i_ysd_vf_yci, IBL))
            CASE DEFAULT
              status = 4_int32; return
            END SELECT

            IF (physics%leocwa .OR. physics%leocco) THEN
              ZDSST0 = ZSSTCI - fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
            ELSE
              ZDSST0 = 0.0_real64
            END IF

            IF (LLMISS) ZDSST0 = 0.0_real64

            fields%sd_vf(JROF, i_ysd_vf_ysst, IBL) = ZSSTCI
          ELSE
            fields%sd_vf(JROF, i_ysd_vf_ysst, IBL) = ZRTFREEZSICE
          END IF

          fields%sp_sb(JROF, 1, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
          fields%sp_sb(JROF, 2, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
          fields%sp_sb(JROF, 3, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
          fields%sp_sb(JROF, 4, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
          fields%sp_sb(JROF,1,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,1,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
          fields%sp_sb(JROF,2,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,2,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
          fields%sp_sb(JROF,3,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,3,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
          fields%sp_sb(JROF,4,i_ysp_sb_yt,IBL) = fields%sd_vf(JROF,i_ysd_vf_yci,IBL)*fields%sp_sb(JROF,4,i_ysp_sb_ytl,IBL)                    &
          & + (1.-fields%sd_vf(JROF, i_ysd_vf_yci, IBL))*fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
! RESTORE SKIN TEMPERATURE ONLY ON OCEAN IF FLAKE IS ACTIVE
          IF (.NOT. (physics%leflake)) THEN
            fields%sp_rr(JROF, i_ysp_rr_yt, IBL) = fields%sp_sb(JROF, 1, i_ysp_sb_yt, IBL)
          ELSEIF (.NOT. LLAKE(JROF)) THEN
            fields%sp_rr(JROF, i_ysp_rr_yt, IBL) = fields%sp_sb(JROF, 1, i_ysp_sb_yt, IBL)
          END IF

        ELSE
!    SEA TO SEA OR SEA-ICE TO SEA
!       calculate SKIN TEMPERATURE INCREMENT TO BE OF THE SAME AMOUNT AS SST (on ocean)
          IF (physics%leocwa .OR. physics%leocco) THEN
            ZDSST0 = ZTS - fields%sd_vf(JROF, i_ysd_vf_ysst, IBL)
          ELSE
            ZDSST0 = 0.0_real64
          END IF
          IF (LLMISS) THEN
            ZDSST0 = 0.0_real64
            ZTS = fields%sp_rr(JROF, i_ysp_rr_yt, IBL)
          END IF

          fields%sd_vf(JROF, i_ysd_vf_ysst, IBL) = ZTS

! RESTORE SKIN TEMPERATURE ONLY ON OCEAN IF FLAKE IS ACTIVE
          IF (.NOT. (physics%leflake)) THEN
            fields%sp_rr(JROF, i_ysp_rr_yt, IBL) = fields%sp_rr(JROF, i_ysp_rr_yt, IBL) + ZDSST0
          ELSEIF (.NOT. LLAKE(JROF)) THEN
            fields%sp_rr(JROF, i_ysp_rr_yt, IBL) = fields%sp_rr(JROF, i_ysp_rr_yt, IBL) + ZDSST0
          END IF
          fields%sp_sb(JROF, 1, i_ysp_sb_yt, IBL) = ZTS
          fields%sp_sb(JROF, 2, i_ysp_sb_yt, IBL) = ZTS
          fields%sp_sb(JROF, 3, i_ysp_sb_yt, IBL) = ZTS
          fields%sp_sb(JROF, 4, i_ysp_sb_yt, IBL) = ZTS
          fields%sp_sb(JROF, 1, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
          fields%sp_sb(JROF, 2, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
          fields%sp_sb(JROF, 3, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
          fields%sp_sb(JROF, 4, i_ysp_sb_ytl, IBL) = ZRTFREEZSICE
        END IF
      END IF  ! end loop of sea points
    END DO

  END DO ! Loop over NPROMA blocks
  status = 0_int32
  end function
!> Return a stored field column from the canonical named registration.
  integer function native_surface_index(catalog, key, group) result(index)
    type(surface_field_registry), intent(in) :: catalog
    character(*), intent(in) :: key
    integer, intent(in) :: group
    integer :: j, f
    index = 0
    do j = 1, size(catalog%aliases)
      if (catalog%aliases(j)%name /= key) cycle
      if (catalog%aliases(j)%group /= group) return
      f = catalog%aliases(j)%first_field
      if (.not. allocated(catalog%groups(group)%fields)) return
      if (f < 1 .or. f > size(catalog%groups(group)%fields)) return
      if (catalog%groups(group)%fields(f)%initialized /= 1) return
      index = catalog%groups(group)%fields(f)%indices(1)
      return
    end do
  end function
end module forecast_daily_climate_surface
