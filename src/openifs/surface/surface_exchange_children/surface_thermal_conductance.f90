!> Native VLAMSK calculation from the frozen source dependencies.
!! Numerical arrays use FP64 in SI units; the original comments name each field.
!! Readonly records are borrowed. Returned arrays are INOUT to retain inactive cells.
!! Status0 means success; status2 refuses shape or unsupported source controls.
!! The caller establishes the frozen IEEE environment and nonoverlapping owners.
module forecast_surface_thermal_conductance
  use iso_fortran_env, only: int32, int64, real64
  use forecast_surface_scalar_math
  use yos_cst, only: tcst
  use yos_veg, only: tveg
  use yos_soil, only: tsoil
  use yos_urb, only: turb
  use yos_ags, only: tags
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64, jprd = real64
  public :: vlamsk
contains
subroutine vlamsk(KIDIA,KFDIA,KLON,KTILES,KTVL,KTVH,PTSTEP,PTSKM1M,PTSRF,PSNM,PRSN,PSNTICE,PWSAM1M,KSOTY,YDCST,YDVEG,YDSOIL,YDURB,LSICOUP,PLAMSK,status)
    integer(int32), intent(out) :: status

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVH(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSTEP
    REAL(KIND=JPRB), INTENT(IN) :: PSNM(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PRSN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSRF(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSNTICE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWSAM1M(:, :)
    INTEGER(KIND=JPIM), INTENT(IN) :: KSOTY(:)

    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    TYPE(TURB), INTENT(IN) :: YDURB

    LOGICAL, INTENT(IN) :: LSICOUP

    REAL(KIND=JPRB), INTENT(INOUT) :: PLAMSK(:, :)

    REAL(KIND=JPRB) :: ZLARGE, ZLARGESN, ZRTTMEPS, ZSNOW, ZSNOWHVEG, ZSTABEXSN, ZLARGEWT, ZSNOW_GLACIER
    REAL(KIND=JPRB) :: ZSNOWSK, ZTMP1, ZTMP2, ZTMP3, ZTMP4, ZFF

    INTEGER(KIND=JPIM) :: JL, JT, JSNOW
    real(real64) :: ordered_snow_mass

    REAL(KIND=JPRB) :: ZZSNM
    REAL(KIND=JPRB) :: ZZRSN
    REAL(KIND=JPRB) :: ZZWSA
    REAL(KIND=JPRB) :: ZZF
    INTEGER(KIND=JPIM) :: JJS

    REAL(KIND=JPRB) :: FLWC
    FLWC(ZZSNM, ZZRSN) = ZZSNM*(YDSOIL%RLWCSWEB + (YDSOIL%RLWCSWEC - YDSOIL%RLWCSWEB)*&
                          &MAX(0._JPRB, (YDSOIL%RLWCSWEA - ZZRSN))/YDSOIL%RLWCSWEA)

    REAL(KIND=JPRB) :: FSNTCOND
    FSNTCOND(ZZRSN) = 2.5E-6_JPRB*ZZRSN*ZZRSN &
                   & - 1.23E-4_JPRB*ZZRSN + 0.024_JPRB

    REAL(KIND=JPRB) :: FSOILTCOND
    FSOILTCOND(ZZWSA, ZZF, JJS) = YDSOIL%RLAMBDADRYM(JJS) + &
                                  (YDSOIL%RKERST2*surface_log10(MAX(YDSOIL%RKERST1, ZZWSA/YDSOIL%RWSATM(JJS))) + YDSOIL%RKERST3)* &
                                  (YDSOIL%RLAMSAT1M(JJS)* &
                                   surface_power(YDSOIL%RLAMBDAICE, (YDSOIL%RWSATM(JJS)*ZZF))* &
                                   surface_power(YDSOIL%RLAMBDAWAT, (YDSOIL%RWSATM(JJS)*(1.0_JPRB - ZZF))) - &
                                   YDSOIL%RLAMBDADRYM(JJS))

    status = 2
    if (klon < 1 .or. klon > 4096) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (ktiles < 7 .or. ktiles > 10) return
    if (ydsoil%leskti8 .and. ktiles < 8) return
    if (size(psnm, 2) < 1 .or. size(psnm, 2) > 64 .or. size(prsn, 2) < 1 .or. size(pwsam1m, 2) < 1) return
    if (size(plamsk, 2) < ktiles .or. size(ptskm1m, 2) < ktiles .or. size(ptsrf, 2) < ktiles) return
    if (.not. allocated(ydveg%rvlamsk) .or. .not. allocated(ydveg%rvlamsks)) return
    if (size(KTVH, 1) < klon) return
    if (size(KTVL, 1) < klon) return
    if (size(PSNM, 1) < klon) return
    if (size(PRSN, 1) < klon) return
    if (size(PTSKM1M, 1) < klon) return
    if (size(PTSRF, 1) < klon) return
    if (size(PSNTICE, 1) < klon) return
    if (size(PWSAM1M, 1) < klon) return
    if (size(KSOTY, 1) < klon) return
    if (size(PLAMSK, 1) < klon) return
    ASSOCIATE (RTT => YDCST%RTT, RVLAMSK => YDVEG%RVLAMSK, RVLAMSKS => YDVEG%RVLAMSKS, &
              RQSNCR => YDSOIL%RQSNCR, RHOCI => YDSOIL%RHOCI, RHOICE => YDSOIL%RHOICE, RURBTC => YDURB%RURBTC, &
              & RTF1 => YDSOIL%RTF1, RTF2 => YDSOIL%RTF2, RTF3 => YDSOIL%RTF3, RTF4 => YDSOIL%RTF4)

      ZLARGE = 1.E10_JPRB
      ZLARGESN = 50._JPRB
      ZLARGEWT = 20._JPRB
      ZRTTMEPS = RTT - 0.2_JPRB
      ZSNOW = 7._JPRB
      ZSNOW_GLACIER = 8._JPRB
      ZSNOWHVEG = 20._JPRB

      DO JT = 1, KTILES
        SELECT CASE (JT)

        CASE (1, 9)
          PLAMSK(KIDIA:KFDIA, JT) = ZLARGE

        CASE (2)
          IF (LSICOUP) THEN
            PLAMSK(KIDIA:KFDIA, JT) = ZLARGE
          ELSE
            DO JL = KIDIA, KFDIA
              IF (PTSKM1M(JL, JT) > PTSRF(JL, JT)) THEN
                PLAMSK(JL, JT) = RVLAMSKS(12)
              ELSE
                PLAMSK(JL, JT) = RVLAMSK(12)
              END IF
            END DO
          END IF

        CASE (3)
          PLAMSK(KIDIA:KFDIA, JT) = ZLARGEWT

        CASE (4)
          DO JL = KIDIA, KFDIA
            IF (PTSKM1M(JL, JT) > PTSRF(JL, JT)) THEN
              PLAMSK(JL, JT) = RVLAMSKS(KTVL(JL))
            ELSE
              PLAMSK(JL, JT) = RVLAMSK(KTVL(JL))
            END IF
          END DO

        CASE (5)
          do jl = kidia, kfdia
            if (ptskm1m(jl, jt) >= ptsrf(jl, jt) .and. ptskm1m(jl, jt) > zrttmeps) then
              plamsk(jl, jt) = zlargesn
            else
              ordered_snow_mass = 0.0_real64
              do jsnow = 1, size(psnm, 2)
                ordered_snow_mass = ordered_snow_mass + psnm(jl, jsnow)
              end do
              if (ordered_snow_mass > 9000.0_real64) then
                plamsk(jl, jt) = zsnow_glacier
              else
                plamsk(jl, jt) = zsnow
              end if
            end if
          end do

        CASE (6)
          DO JL = KIDIA, KFDIA
            IF (PTSKM1M(JL, JT) > PTSRF(JL, JT)) THEN
              PLAMSK(JL, JT) = RVLAMSKS(KTVH(JL))
            ELSE
              PLAMSK(JL, JT) = RVLAMSK(KTVH(JL))
            END IF
          END DO

        CASE (7)
          DO JL = KIDIA, KFDIA
            IF (PTSKM1M(JL, JT) > PTSRF(JL, JT)) THEN
              PLAMSK(JL, JT) = RVLAMSKS(KTVH(JL))
            ELSE
              PLAMSK(JL, JT) = ZSNOWHVEG
            END IF
          END DO

        CASE (8)
          DO JL = KIDIA, KFDIA
            IF (PTSKM1M(JL, JT) > PTSRF(JL, JT)) THEN
              PLAMSK(JL, JT) = RVLAMSKS(8)
            ELSE
              PLAMSK(JL, JT) = RVLAMSK(8)
            END IF
          END DO

        CASE (10)
          DO JL = KIDIA, KFDIA
            IF (PTSKM1M(JL, JT) > PTSRF(JL, JT)) THEN
              PLAMSK(JL, JT) = RURBTC
            ELSE
              PLAMSK(JL, JT) = RURBTC
            END IF
          END DO

        END SELECT
      END DO

      JT = 7
      DO JL = KIDIA, KFDIA
        ZSTABEXSN = PTSTEP/(MAX(RQSNCR, (PSNM(JL, 1)/PRSN(JL, 1)))*RHOCI*PRSN(JL, 1)/RHOICE)
        PLAMSK(JL, JT) = PLAMSK(JL, JT)/(1._JPRB + ZSTABEXSN*PLAMSK(JL, JT))
      END DO

      IF (YDSOIL%LESKTI5) THEN
        JT = 5
        DO JL = KIDIA, KFDIA
          ZTMP1 = 1._JPRB/MAX(0.01_JPRB, (PSNM(JL, 1)/PRSN(JL, 1)))
          ZTMP2 = RHOCI*PRSN(JL, 1)/RHOICE
          ZSNOWSK = FSNTCOND(PRSN(JL, 1))
          PLAMSK(JL, JT) = 2._JPRB*ZSNOWSK*ZTMP1

        END DO
      END IF

      IF (YDSOIL%LESKTI8) THEN
        JT = 8
        DO JL = KIDIA, KFDIA
          ZTMP1 = 1._JPRB/YDSOIL%RDAW(1)

          IF (PTSRF(JL, JT) < RTF1 .AND. PTSRF(JL, JT) > RTF2) THEN
            ZFF = 0.5_JPRB*(1.0_JPRB - surface_sin(RTF4*(PTSRF(JL, JT) - RTF3)))
          ELSEIF (PTSRF(JL, JT) <= RTF2) THEN
            ZFF = 1.0_JPRB
          ELSE
            ZFF = 0.0_JPRB
          END IF
          ZSNOWSK = MAX(0.19_JPRB, MIN(2._JPRB, FSOILTCOND(PWSAM1M(JL, 1), ZFF, MAX(1, KSOTY(JL)))))
          PLAMSK(JL, JT) = 2._JPRB*ZSNOWSK*ZTMP1
        END DO

      END IF

    END ASSOCIATE
    status = 0
  end subroutine vlamsk
end module forecast_surface_thermal_conductance
