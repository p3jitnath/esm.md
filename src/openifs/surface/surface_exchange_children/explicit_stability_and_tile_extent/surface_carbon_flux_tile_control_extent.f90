!> Native SRFCOTWO calculation from the frozen source dependencies.
!! Numerical arrays use FP64 in SI units; the original comments name each field.
!! Readonly records are borrowed. Returned arrays are INOUT to retain inactive cells.
!! Status0 means success; status2 refuses shape or unsupported source controls.
!! The caller establishes the frozen IEEE environment and nonoverlapping owners.
module forecast_surface_carbon_flux
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
  public :: srfcotwo
contains
subroutine srfcotwo(KIDIA,KFDIA,KLON,KLEVS,KTILES,KVEG,KVTTL,KCO2TYP,KSOTY,PTSTEP,PTMLEV,PQMLEV,PAPHMS,PCVT,PFRTI,PLAIVT,PWLIQ,PWSOIL,PTSOIL,PDSN,PFWET,PLAT,PANTI,PAGTI,PRDTI,YDCST,YDVEG,YDSOIL,YDAGS,PANDAYVT,PANFMVT,PAG,PRD,PAN,PRSOIL_STR,PRECO,PCO2FLUX,PCH4FLUX,PDHCO2S,status)
    integer(int32), intent(out) :: status

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVS
    INTEGER(KIND=JPIM), INTENT(IN) :: KSOTY(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
    INTEGER(KIND=JPIM), INTENT(IN) :: KVTTL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSTEP
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCVT(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLAIVT(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PWSOIL(:, :)

    REAL(KIND=JPRB), INTENT(IN) :: PDSN(:)

    REAL(KIND=JPRB), INTENT(IN) :: PTSOIL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PFWET(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAT(:)
    REAL(KIND=JPRB), INTENT(IN) :: PANTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAGTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PRDTI(:, :)

    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    TYPE(TAGS), INTENT(IN) :: YDAGS
    INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(:)

    REAL(KIND=JPRB), INTENT(INOUT) :: PANDAYVT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PANFMVT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSOIL_STR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRECO(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCO2FLUX(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCH4FLUX(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHCO2S(:, :, :)

    REAL(KIND=JPRB), INTENT(IN) :: PWLIQ(KLON, KLEVS, KTILES)

    REAL(KIND=JPRB) :: ZFWCO2(KLON), ZWROOT(KLON)
    INTEGER(KIND=JPIM), intent(in) :: KVEG(KLON, KTILES)
    REAL(KIND=JPRB) :: ZRWCAP

    INTEGER(KIND=JPIM) :: JL, JTILE, JVT, JS, JK, IVT, ICTYPE
    REAL(KIND=JPRB) :: ZRHO, ZCVS
    REAL(KIND=JPRB) :: ZAGVT(KLON, YDVEG%NVTILES), ZRDVT(KLON, YDVEG%NVTILES),&
     &                    ZANVT(KLON, YDVEG%NVTILES), ZRSOIL_STRVT(KLON, YDVEG%NVTILES), ZRNOQ10VT(KLON, YDVEG%NVTILES),&
     &                    ZRECOVT(KLON, YDVEG%NVTILES), ZCO2FLUXVT(KLON, YDVEG%NVTILES), ZCH4FLUXVT(KLON, YDVEG%NVTILES)
    REAL(KIND=JPRB) :: ZTSOIL, ZWSOIL, ZRSWC, ZS
    REAL(KIND=JPRB) :: ZFSN(KLON)
    REAL(KIND=JPRB) :: ZOMEGASN(KLON)
    REAL(KIND=JPRB) :: ZFITAUSN(KLON)

    REAL(KIND=JPRB) :: ZBARE(KLON)
    REAL(KIND=JPRB) :: ZRQ10, ZCH4S
    REAL(KIND=JPRB) :: ZEPSR

    status = 2
    if (klon < 1 .or. klon > 4096) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (klevs /= 4 .or. ktiles < 8 .or. ktiles > 32 .or. ydveg%nvtiles /= 2) return
    if (size(kvttl) < ktiles) return
    if (kvttl(4) /= 1 .or. kvttl(6) /= 2) return
    if (size(pdhco2s, 1) < klon .or. size(pdhco2s, 2) < 2 .or. size(pdhco2s, 3) < 6) return
    if (size(pcvt, 2) < 2 .or. size(pcvt, 2) > 3) return
    if (size(plaivt, 2) < 2 .or. size(plaivt, 2) > 3) return
    if (size(pandayvt, 2) < 2 .or. size(pandayvt, 2) > 3) return
    if (size(panfmvt, 2) < 2 .or. size(panfmvt, 2) > 3) return
    if (.not. allocated(ydveg%rvrootsa) .or. .not. allocated(ydags%rvr0vt) .or. .not. allocated(ydags%rvch4qvt)) return
    if (size(KSOTY, 1) < klon) return
    if (size(PTMLEV, 1) < klon) return
    if (size(PQMLEV, 1) < klon) return
    if (size(PAPHMS, 1) < klon) return
    if (size(PCVT, 1) < klon) return
    if (size(PFRTI, 1) < klon) return
    if (size(PLAIVT, 1) < klon) return
    if (size(PWSOIL, 1) < klon) return
    if (size(PDSN, 1) < klon) return
    if (size(PTSOIL, 1) < klon) return
    if (size(PFWET, 1) < klon) return
    if (size(PLAT, 1) < klon) return
    if (size(PANTI, 1) < klon) return
    if (size(PAGTI, 1) < klon) return
    if (size(PRDTI, 1) < klon) return
    if (size(KCO2TYP, 1) < klon) return
    if (size(PANDAYVT, 1) < klon) return
    if (size(PANFMVT, 1) < klon) return
    if (size(PAN, 1) < klon) return
    if (size(PAG, 1) < klon) return
    if (size(PRD, 1) < klon) return
    if (size(PRSOIL_STR, 1) < klon) return
    if (size(PRECO, 1) < klon) return
    if (size(PCO2FLUX, 1) < klon) return
    if (size(PCH4FLUX, 1) < klon) return
    if (size(PDHCO2S, 1) < klon) return
    ASSOCIATE (RQ10 => YDAGS%RQ10, RVR0VT => YDAGS%RVR0VT, RVCH4QVT => YDAGS%RVCH4QVT, RVCH4S => YDAGS%RVCH4S, &
     & RD => YDCST%RD, RETV => YDCST%RETV, RTT => YDCST%RTT, RPI => YDCST%RPI, &
     & LEVGEN => YDSOIL%LEVGEN, RWCAP => YDSOIL%RWCAP, RWCAPM => YDSOIL%RWCAPM, &
     & RWPWP => YDSOIL%RWPWP, &
     & NVTILES => YDVEG%NVTILES, RVROOTSA => YDVEG%RVROOTSA)

      ZFSN(KIDIA:KFDIA) = 1._JPRB
      ZFWCO2(KIDIA:KFDIA) = 0._JPRB
      ZWROOT(KIDIA:KFDIA) = 0._JPRB
      ZAGVT(KIDIA:KFDIA, :) = 0._JPRB
      ZRDVT(KIDIA:KFDIA, :) = 0._JPRB
      ZANVT(KIDIA:KFDIA, :) = 0._JPRB
      ZRSOIL_STRVT(KIDIA:KFDIA, :) = 0._JPRB
      ZRNOQ10VT(KIDIA:KFDIA, :) = 0._JPRB
      ZRECOVT(KIDIA:KFDIA, :) = 0._JPRB
      ZCO2FLUXVT(KIDIA:KFDIA, :) = 0._JPRB
      ZCH4FLUXVT(KIDIA:KFDIA, :) = 0._JPRB
      ZBARE(KIDIA:KFDIA) = 0._JPRB

      ZRWCAP = 0._JPRB
      ZRHO = 0._JPRB
      ZCVS = 0._JPRB
      ZTSOIL = 0._JPRB
      ZWSOIL = 0._JPRB
      ZRSWC = 0._JPRB
      ZS = 0._JPRB
      ZRQ10 = 2.0_JPRB
      ZCH4S = 1.0_JPRB

      ZEPSR = 0.0001_JPRB

      DO JL = KIDIA, KFDIA
        ZBARE(JL) = 1._JPRB - PCVT(JL, KVTTL(4)) - PCVT(JL, KVTTL(6))
        IF (PCVT(JL, KVTTL(6)) .GT. 0._JPRB) THEN
          ZCVS = PFRTI(JL, 7)/PCVT(JL, KVTTL(6))
        ELSEIF (PCVT(JL, KVTTL(4)) .GT. 0._JPRB) THEN
          ZCVS = PFRTI(JL, 5)/(PCVT(JL, KVTTL(4)) + ZBARE(JL))
        ELSE
          ZCVS = 0._JPRB
        END IF
        ZCVS = MAX(ZCVS, 0._JPRB)
        ZCVS = MIN(ZCVS, 1._JPRB)

        IF (PCVT(JL, KVTTL(4)) == 0._JPRB) THEN
          ZAGVT(JL, KVTTL(4)) = 0._JPRB
          ZRDVT(JL, KVTTL(4)) = 0._JPRB
          ZANVT(JL, KVTTL(4)) = 0._JPRB
        ELSE
          ZAGVT(JL, KVTTL(4)) = (1._JPRB - ZCVS)*PAGTI(JL, 4)
          ZAGVT(JL, KVTTL(4)) = MAX(ZAGVT(JL, KVTTL(4)), 0.0_JPRB)
          ZRDVT(JL, KVTTL(4)) = (1._JPRB - ZCVS)*PRDTI(JL, 4)
          ZANVT(JL, KVTTL(4)) = (1._JPRB - ZCVS)*PANTI(JL, 4)
        END IF

        IF (PCVT(JL, KVTTL(6)) > 0._JPRB) THEN
          ZAGVT(JL, KVTTL(6)) = ZCVS*PAGTI(JL, 7) + (1._JPRB - ZCVS)*PAGTI(JL, 6)
          ZAGVT(JL, KVTTL(6)) = MAX(ZAGVT(JL, KVTTL(6)), 0.0_JPRB)
          ZRDVT(JL, KVTTL(6)) = ZCVS*PRDTI(JL, 7) + (1._JPRB - ZCVS)*PRDTI(JL, 6)
          ZANVT(JL, KVTTL(6)) = ZCVS*PANTI(JL, 7) + (1._JPRB - ZCVS)*PANTI(JL, 6)
        ELSE
          ZAGVT(JL, KVTTL(6)) = 0._JPRB
          ZRDVT(JL, KVTTL(6)) = 0._JPRB
          ZANVT(JL, KVTTL(6)) = 0._JPRB
        END IF

      END DO

      DO JL = KIDIA, KFDIA
        ZWROOT(JL) = 0._JPRB
        DO JTILE = 1, KTILES
          DO JK = 1, KLEVS
            ZWROOT(JL) = ZWROOT(JL) + PWLIQ(JL, JK, JTILE)*RVROOTSA(JK, KVEG(JL, JTILE))
          END DO
        END DO
        IF (LEVGEN) THEN
          JS = KSOTY(JL)
          IF (JS .GE. 1_JPIM) ZRWCAP = 1.0_JPRB/RWCAPM(JS)
        ELSE
          ZRWCAP = 1.0_JPRB/RWCAP
        END IF
        ZFWCO2(JL) = MIN(1.0_JPRB, (ZWROOT(JL)*ZRWCAP))
      END DO

      DO JL = KIDIA, KFDIA

        ZTSOIL = 0._JPRB
        DO JK = 1, KLEVS - 2_JPIM
          ZTSOIL = ZTSOIL + PTSOIL(JL, JK)
        END DO
        ZTSOIL = ZTSOIL/(KLEVS - 2_JPIM)
        ZTSOIL = ZTSOIL - RTT

        ZBARE(JL) = 1._JPRB - PCVT(JL, KVTTL(4)) - PCVT(JL, KVTTL(6))

        IF (PCVT(JL, KVTTL(6)) .GT. 0._JPRB) THEN
          ZCVS = PFRTI(JL, 7)/PCVT(JL, KVTTL(6))
        ELSEIF (PCVT(JL, KVTTL(4)) .GT. 0._JPRB) THEN
          ZCVS = PFRTI(JL, 5)/(PCVT(JL, KVTTL(4)) + ZBARE(JL))
        ELSE
          ZCVS = 0._JPRB
        END IF
        ZCVS = MAX(ZCVS, 0._JPRB)
        ZCVS = MIN(ZCVS, 1._JPRB)

        ZFSN(JL) = 1._JPRB - ZCVS*(1._JPRB - surface_exp(-2._JPRB*MAX(PDSN(JL), 0._JPRB)))

        ZRQ10 = 2.5665_JPRB - 0.05308_JPRB*ZTSOIL + 0.00238_JPRB*ZTSOIL*ZTSOIL - 0.00004_JPRB*ZTSOIL*ZTSOIL*ZTSOIL
        ZRQ10 = MAX(ZRQ10, ZEPSR)
        IF ((PLAT(JL)*180._JPRB/RPI) .GT. 25._JPRB) THEN
          ZCH4S = RVCH4S(1)
        ELSEIF ((PLAT(JL)*180._JPRB/RPI) .LT. -25._JPRB) THEN
          ZCH4S = RVCH4S(3)
        ELSE
          ZCH4S = RVCH4S(2)
        END IF

        ICTYPE = 1
        IF (KCO2TYP(JL) .EQ. 4) THEN
          ICTYPE = 2
        END IF

        ZCH4S = ZCH4S*2.0_JPRB

        DO JVT = 1, NVTILES

          IF (JVT == 1) THEN
            IVT = 4
          ELSEIF ((JVT .EQ. 2) .AND. (PFRTI(JL, 7) .EQ. 0._JPRB)) THEN
            IVT = 6
          ELSEIF ((JVT .EQ. 2) .AND. (PFRTI(JL, 7) .GT. 0._JPRB)) THEN
            IVT = 7
          END IF

          ZRSOIL_STRVT(JL, JVT) = ZFWCO2(JL)*RVR0VT(KVEG(JL, IVT), ICTYPE)*surface_power(ZRQ10, (0.1_JPRB*(ZTSOIL - 25._JPRB)))
          ZRSOIL_STRVT(JL, JVT) = ZFSN(JL)*ZRSOIL_STRVT(JL, JVT)

          ZRNOQ10VT(JL, JVT) = ZFWCO2(JL)*RVR0VT(KVEG(JL, IVT), ICTYPE)
          ZRNOQ10VT(JL, JVT) = ZFSN(JL)*ZRNOQ10VT(JL, JVT)
    IF (RVCH4QVT(KVEG(JL,IVT)) .EQ. 0._JPRB .OR. PFWET(JL) .EQ. 0._JPRB .OR. ZRNOQ10VT(JL,JVT) .EQ. 0._JPRB .OR. PTSOIL(JL,1) .LT. 273.15) THEN
            ZCH4FLUXVT(JL, JVT) = 0._JPRB
          ELSE
   ZCH4FLUXVT(JL,JVT)=ZCH4S*PFWET(JL)*ZRNOQ10VT(JL,JVT)*surface_power(RVCH4QVT(KVEG(JL,IVT)),(0.1_JPRB*(PTSOIL(JL,1)-RTT-25._JPRB)))
          END IF

          ZRECOVT(JL, JVT) = ZRDVT(JL, JVT) + ZRSOIL_STRVT(JL, JVT)
        END DO
      END DO

      DO JL = KIDIA, KFDIA
        DO JVT = 1, NVTILES
          ZCO2FLUXVT(JL, JVT) = ZAGVT(JL, JVT)*(-1._JPRB) + ZRECOVT(JL, JVT)
        END DO
      END DO

      PAG(KIDIA:KFDIA) = 0._JPRB
      PRD(KIDIA:KFDIA) = 0._JPRB
      PAN(KIDIA:KFDIA) = 0._JPRB
      PRSOIL_STR(KIDIA:KFDIA) = 0._JPRB
      PRECO(KIDIA:KFDIA) = 0._JPRB
      PCO2FLUX(KIDIA:KFDIA) = 0._JPRB
      PCH4FLUX(KIDIA:KFDIA) = 0._JPRB
      DO JL = KIDIA, KFDIA
        DO JVT = 1, NVTILES
          PAG(JL) = PAG(JL) + PCVT(JL, JVT)*ZAGVT(JL, JVT)
          PRD(JL) = PRD(JL) + PCVT(JL, JVT)*ZRDVT(JL, JVT)*(-1._JPRB)
          PAN(JL) = PAN(JL) + PCVT(JL, JVT)*ZANVT(JL, JVT)
          PRSOIL_STR(JL) = PRSOIL_STR(JL) + PCVT(JL, JVT)*ZRSOIL_STRVT(JL, JVT)*(-1._JPRB)
          PRECO(JL) = PRECO(JL) + PCVT(JL, JVT)*ZRECOVT(JL, JVT)*(-1._JPRB)
          PCO2FLUX(JL) = PCO2FLUX(JL) + PCVT(JL, JVT)*ZCO2FLUXVT(JL, JVT)*(-1._JPRB)
          PCH4FLUX(JL) = PCH4FLUX(JL) + PCVT(JL, JVT)*ZCH4FLUXVT(JL, JVT)*(-1._JPRB)
        END DO

      END DO

      DO JL = KIDIA, KFDIA
        DO JVT = 1, NVTILES

          PDHCO2S(JL, JVT, 1) = ZAGVT(JL, JVT)
          PDHCO2S(JL, JVT, 2) = ZRDVT(JL, JVT)*(-1._JPRB)
          PDHCO2S(JL, JVT, 3) = ZANVT(JL, JVT)
          PDHCO2S(JL, JVT, 4) = ZRSOIL_STRVT(JL, JVT)*(-1._JPRB)
          PDHCO2S(JL, JVT, 5) = ZRECOVT(JL, JVT)*(-1._JPRB)
          PDHCO2S(JL, JVT, 6) = ZCO2FLUXVT(JL, JVT)*(-1._JPRB)
        END DO
      END DO

      DO JL = KIDIA, KFDIA
        ZRHO = PAPHMS(JL)/(RD*PTMLEV(JL)*(1._JPRB + RETV*PQMLEV(JL)))
        DO JVT = 1, NVTILES
          PANDAYVT(JL, JVT) = PANDAYVT(JL, JVT) + ZANVT(JL, JVT)*PTSTEP
          IF ((PCVT(JL, JVT) .GT. 0._JPRB) .AND. (PLAIVT(JL, JVT) .GT. 0._JPRB)) THEN
            PANFMVT(JL, JVT) = MAX(PANFMVT(JL, JVT), ZANVT(JL, JVT)/(ZRHO*PLAIVT(JL, JVT)))
          ELSE
            PANFMVT(JL, JVT) = 0._JPRB
          END IF
        END DO
      END DO

    END ASSOCIATE
    status = 0
  end subroutine srfcotwo
end module forecast_surface_carbon_flux
