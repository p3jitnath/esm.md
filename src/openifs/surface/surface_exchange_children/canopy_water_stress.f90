!> Complete native selected canopy-water-stress calculation.
!! Both the legacy leaf and the corrected C3/C4 Farquhar branch are native.
!! Original thirty arguments retain their order, followed by INT32 status.
!! Temperatures use K, pressure Pa, CO2 kgCO2/kgAir, resistance s/m;
!! carbon outputs use kgCO2/(m2 s). Readonly record owners remain live.
!! All six returned arrays preserve inactive cells through INTENT(INOUT).
!! Status0 succeeds,2 refuses input and100+child propagates leaf failure.
module forecast_canopy_water_stress
  use iso_fortran_env, only: int32, real64
  use forecast_surface_scalar_math, only: surface_exp, surface_log
  use forecast_canopy_carbon_children, only: ccetr, cotwo
  use forecast_plant_photosynthesis, only: farquhar
  use yos_cst, only: tcst
  use yos_ags, only: tags
  use yos_agf, only: tagf
  use yos_veg, only: tveg
  use yos_flake, only: tflake
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64
  public :: cotworestress
contains
subroutine cotworestress(KIDIA,KFDIA,KLON,KVTYPE,KCO2TYP,PFRTI,PTM1,PQM1,PCM1,PAPHM1,PTSKM1M,PTSOIL,PEVAP,PLAI,PSRFD,PRAQ,PMU0,PF2,PQS,YDCST,YDAGS,YDAGF,YDVEG,YDFLAKE,PAN,PAG,PRD,PWET,PDSP,PDMAXT,status)
    integer(int32), intent(out) :: status
    integer(int32) :: child_status

    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KVTYPE(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTM1(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQM1(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCM1(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSOIL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PEVAP(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAI(:)
    REAL(KIND=JPRB), INTENT(IN) :: PSRFD(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRAQ(:)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(:)
    REAL(KIND=JPRB), INTENT(IN) :: PF2(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQS(:)
    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TAGS), INTENT(IN) :: YDAGS
    TYPE(TAGF), INTENT(IN) :: YDAGF
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TFLAKE), INTENT(IN) :: YDFLAKE
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWET(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMAXT(:)

    INTEGER(KIND=JPIM) :: JL, JINT

    REAL(KIND=JPRB) :: ZTSK(KLON), ZIA(KLON), ZGAMMT(KLON), ZRHO(KLON), ZQSURF(KLON), &
         & ZDSP(KLON), ZCO2(KLON), ZMU0(KLON), ZAMMAX(KLON), ZGMEST(KLON), &
         & ZTAN(KLON), ZTAG(KLON), ZTRD(KLON), ZTGS(KLON), ZXIA(KLON), &
         & ZAN0(KLON), ZAG0(KLON), ZRD0(KLON), ZGS0(KLON), ZXTGS(KLON), &
         & ZDMAXSTAR(KLON), ZFZEROT(KLON), ZDMAXT(KLON), ZFZEROSTAR(KLON), &
         & ZFZERON(KLON), ZGMESTN(KLON), ZRVGC(KLON), ZRVEPSO(KLON), Z1(KLON)
    LOGICAL :: LDLAND(KLON)

    status = 2
    if (klon < 1 .or. klon > 4096) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon .or. kfdia < kidia - 1) return
    if (size(pfrti, 2) < 9) return
    if (ydveg%leairco2coup) return
    if (size(KVTYPE, 1) < klon) return
    if (size(KCO2TYP, 1) < klon) return
    if (size(PFRTI, 1) < klon) return
    if (size(PTM1, 1) < klon) return
    if (size(PQM1, 1) < klon) return
    if (size(PCM1, 1) < klon) return
    if (size(PAPHM1, 1) < klon) return
    if (size(PTSKM1M, 1) < klon) return
    if (size(PTSOIL, 1) < klon) return
    if (size(PEVAP, 1) < klon) return
    if (size(PLAI, 1) < klon) return
    if (size(PSRFD, 1) < klon) return
    if (size(PRAQ, 1) < klon) return
    if (size(PMU0, 1) < klon) return
    if (size(PF2, 1) < klon) return
    if (size(PQS, 1) < klon) return
    if (size(PAN, 1) < klon) return
    if (size(PAG, 1) < klon) return
    if (size(PRD, 1) < klon) return
    if (size(PWET, 1) < klon) return
    if (size(PDSP, 1) < klon) return
    if (size(PDMAXT, 1) < klon) return
    if (any(kvtype(kidia:kfdia) < 0) .or. any(kvtype(kidia:kfdia) > 20)) return
    if (any(pcm1(kidia:kfdia) <= 0.0_real64)) return

    ASSOCIATE (LVSTRESS => YDAGS%LVSTRESS, RABC => YDAGS%RABC, RASW => YDAGS%RASW, &
     & RAW => YDAGS%RAW, RBW => YDAGS%RBW, RCO2 => YDAGS%RCO2, &
     & RCONDCTMIN => YDAGS%RCONDCTMIN, RDMAXN => YDAGS%RDMAXN, RDMAXX => YDAGS%RDMAXX, &
     & RPARCF => YDAGS%RPARCF, RPOI => YDAGS%RPOI, RRACCF => YDAGS%RRACCF, &
     & RVAH => YDAGS%RVAH, RVAMMAX => YDAGS%RVAMMAX, RVBH => YDAGS%RVBH, &
     & RVDMAX => YDAGS%RVDMAX, RVEPSO => YDAGS%RVEPSO, RVF2I => YDAGS%RVF2I, &
     & RVFZEROST => YDAGS%RVFZEROST, RVGAMM => YDAGS%RVGAMM, RVGC => YDAGS%RVGC, &
     & RVGMES => YDAGS%RVGMES, RVQDAMMAX => YDAGS%RVQDAMMAX, RVQDGAMM => YDAGS%RVQDGAMM, &
     & RVQDGMES => YDAGS%RVQDGMES, RVT1AMMAX => YDAGS%RVT1AMMAX, &
     & RVT1GMES => YDAGS%RVT1GMES, RVT2AMMAX => YDAGS%RVT2AMMAX, &
     & RVT2GMES => YDAGS%RVT2GMES, &
     & RD => YDCST%RD, RETV => YDCST%RETV, RTT => YDCST%RTT, &
     & LEFLAKE => YDFLAKE%LEFLAKE, LEAIRCO2COUP => YDVEG%LEAIRCO2COUP,&
     & LEFARQUHAR => YDVEG%LEFARQUHAR)

      IF (LEFLAKE) THEN
        DO JL = KIDIA, KFDIA
          LDLAND(JL) = ((PFRTI(JL, 1) + PFRTI(JL, 2) + PFRTI(JL, 9)) <= 0.5_JPRB)
        END DO
      ELSE
        DO JL = KIDIA, KFDIA
          LDLAND(JL) = ((PFRTI(JL, 1) + PFRTI(JL, 2)) <= 0.5_JPRB)
        END DO
      END IF
      ZIA(:) = 0.0_JPRB

      DO JL = KIDIA, KFDIA
        IF (LDLAND(JL)) THEN

          ZGAMMT(JL) = 0.0_JPRB
          ZRHO(JL) = 0.0_JPRB
          ZQSURF(JL) = 0.0_JPRB
          ZDSP(JL) = 0.0_JPRB
          ZMU0(JL) = 0.0_JPRB
          ZAMMAX(JL) = 0.0_JPRB
          ZGMEST(JL) = 0.0_JPRB
          ZTAN(JL) = 0.0_JPRB
          ZTAG(JL) = 0.0_JPRB
          ZTRD(JL) = 0.0_JPRB
          ZTGS(JL) = 0.0_JPRB
          ZXIA(JL) = 0.0_JPRB
          ZAN0(JL) = 0.0_JPRB
          ZAG0(JL) = 0.0_JPRB
          ZRD0(JL) = 0.0_JPRB
          ZGS0(JL) = 0.0_JPRB
          ZXTGS(JL) = 0.0_JPRB
          ZDMAXSTAR(JL) = 0.0_JPRB
          ZFZEROT(JL) = 0.0_JPRB
          ZDMAXT(JL) = 0.0_JPRB
          ZFZEROSTAR(JL) = 0.0_JPRB
          ZFZERON(JL) = 0.0_JPRB
          ZGMESTN(JL) = 0.0_JPRB
          ZRVGC(JL) = 0.0_JPRB
          ZRVEPSO(JL) = 0.0_JPRB

          ZTSK(JL) = PTSKM1M(JL) - RTT
          Z1(JL) = 0.1_JPRB*(ZTSK(JL) - 25._JPRB)
          ZIA(JL) = PSRFD(JL)*RPARCF
          IF (KVTYPE(JL) >= 0._JPRB) THEN
            ZGMEST(JL) = RVGMES(KVTYPE(JL))
            ZFZEROT(JL) = RVFZEROST(KVTYPE(JL))
            ZDMAXT(JL) = RVDMAX(KVTYPE(JL))
            ZRVGC(JL) = RVGC(KVTYPE(JL))
            ZRVEPSO(JL) = RVEPSO(KVTYPE(JL))
          ELSE
            ZGMEST(JL) = 0._JPRB
            ZFZEROT(JL) = 0._JPRB
            ZDMAXT(JL) = 0._JPRB
            ZRVGC(JL) = 0._JPRB
            ZRVEPSO(JL) = 0._JPRB
          END IF
          IF (KVTYPE(JL) == 1 .OR. KVTYPE(JL) == 2 .OR. KVTYPE(JL) == 7 .OR. KVTYPE(JL) == 9 .OR. &
            & KVTYPE(JL) == 10 .OR. KVTYPE(JL) == 11 .OR. KVTYPE(JL) == 13 .OR. KVTYPE(JL) == 16 .OR. &
            & KVTYPE(JL) == 17 .OR. KVTYPE(JL) == 20 .OR. KVTYPE(JL) == 0) THEN

            ZDMAXSTAR(JL) = surface_exp((surface_log(ZGMEST(JL)*1000._JPRB) - RVAH(KVTYPE(JL)))/RVBH(KVTYPE(JL)))/1000._JPRB
            ZGAMMT(JL) = RVGAMM(KVTYPE(JL))*surface_exp(Z1(JL)*surface_log(RVQDGAMM(KVTYPE(JL))))

            IF (LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) >= RVF2I(KVTYPE(JL)))) THEN
              ZDMAXT(JL) = RDMAXN + (ZDMAXSTAR(JL) - RDMAXN)*(PF2(JL) - RVF2I(KVTYPE(JL)))/(1._JPRB - RVF2I(KVTYPE(JL)))
              ZGMEST(JL) = surface_exp(RVAH(KVTYPE(JL)) + RVBH(KVTYPE(JL))*surface_log(ZDMAXT(JL)*1000._JPRB))/1000._JPRB

            ELSEIF (LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) < RVF2I(KVTYPE(JL)))) THEN
              ZDMAXT(JL) = RDMAXN
              ZGMEST(JL) = (surface_exp(RVAH(KVTYPE(JL)) + RVBH(KVTYPE(JL))*surface_log(RDMAXN*1000._JPRB))/1000._JPRB)*&
                   & PF2(JL)/RVF2I(KVTYPE(JL))

            ELSEIF (.NOT. LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) >= RVF2I(KVTYPE(JL)))) THEN
              ZDMAXT(JL) = RDMAXX + (ZDMAXSTAR(JL) - RDMAXX)*(PF2(JL) - RVF2I(KVTYPE(JL)))/(1._JPRB - RVF2I(KVTYPE(JL)))
              ZGMEST(JL) = surface_exp(RVAH(KVTYPE(JL)) + RVBH(KVTYPE(JL))*surface_log(ZDMAXT(JL)*1000._JPRB))/1000._JPRB

            ELSEIF (.NOT. LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) < RVF2I(KVTYPE(JL)))) THEN
              ZDMAXT(JL) = RDMAXX*PF2(JL)/RVF2I(KVTYPE(JL))
              ZGMEST(JL) = surface_exp(RVAH(KVTYPE(JL)) + RVBH(KVTYPE(JL))*surface_log(RDMAXX*1000._JPRB))/1000._JPRB
            END IF

            IF (.NOT. LVSTRESS(KVTYPE(JL)) .AND. ((ZDMAXT(JL) <= RDMAXN))) THEN

              ZDMAXT(JL) = RDMAXN
 ZGMEST(JL) = (surface_exp(RVAH(KVTYPE(JL)) + RVBH(KVTYPE(JL))*surface_log(RDMAXN*1000._JPRB))/1000._JPRB)*PF2(JL)/RVF2I(KVTYPE(JL))
            END IF
          ELSEIF (KVTYPE(JL) == 3 .OR. KVTYPE(JL) == 4 .OR. KVTYPE(JL) == 5 .OR. KVTYPE(JL) == 6 .OR. &
                & KVTYPE(JL) == 18 .OR. KVTYPE(JL) == 19) THEN
            ZGAMMT(JL) = RVGAMM(KVTYPE(JL))*surface_exp(Z1(JL)*surface_log(RVQDGAMM(KVTYPE(JL))))
            ZFZEROSTAR(JL) = (RAW - surface_log(ZGMEST(JL)*1000._JPRB))/RBW
            ZFZERON(JL) = (RASW - surface_log(ZGMEST(JL)*1000._JPRB))/RBW
            ZGMESTN(JL) = surface_exp(RASW - RBW*ZFZEROSTAR(JL))/1000._JPRB

            IF (LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) >= RVF2I(KVTYPE(JL)))) THEN
              ZFZEROT(JL) = ZFZERON(JL) + (ZFZEROSTAR(JL) - ZFZERON(JL))*(PF2(JL) - RVF2I(KVTYPE(JL)))/&
                   &(1._JPRB - RVF2I(KVTYPE(JL)))

            ELSEIF (LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) < RVF2I(KVTYPE(JL)))) THEN
              ZGMEST(JL) = MAX(1.0E-6_JPRB, ZGMEST(JL)*PF2(JL)/RVF2I(KVTYPE(JL)))
              ZFZEROT(JL) = MIN(.95_JPRB, (RASW - surface_log(ZGMEST(JL)*1000._JPRB))/RBW)

            ELSEIF (.NOT. LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) >= RVF2I(KVTYPE(JL)))) THEN
              ZGMEST(JL) = ZGMESTN(JL) + (ZGMEST(JL) - ZGMESTN(JL))*(PF2(JL) - RVF2I(KVTYPE(JL)))/(1._JPRB - RVF2I(KVTYPE(JL)))
              ZFZEROT(JL) = ZFZEROSTAR(JL)

            ELSEIF (.NOT. LVSTRESS(KVTYPE(JL)) .AND. (PF2(JL) < RVF2I(KVTYPE(JL)))) THEN
              ZGMEST(JL) = ZGMESTN(JL)*PF2(JL)/RVF2I(KVTYPE(JL))
              ZFZEROT(JL) = MIN(.95_JPRB, (RASW - surface_log(ZGMEST(JL)*1000._JPRB))/RBW)
            END IF
          END IF

          PDMAXT(JL) = ZDMAXT(JL)

          ZRHO(JL) = PAPHM1(JL)/(RD*PTM1(JL)*(1._JPRB + RETV*PQM1(JL)))
          ZQSURF(JL) = PQM1(JL) - MIN(0._JPRB, PEVAP(JL))*PRAQ(JL)/ZRHO(JL)
          PDSP(JL) = MAX(0._JPRB, PQS(JL) - PQM1(JL) + MIN(0._JPRB, PEVAP(JL))*PRAQ(JL)/ZRHO(JL))

          ZMU0(JL) = MAX(PMU0(JL), 0.1_JPRB)

          IF (KVTYPE(JL) >= 0._JPRB) THEN
            ZAMMAX(JL) = (RVAMMAX(KVTYPE(JL))*surface_exp(Z1(JL)*surface_log(RVQDAMMAX(KVTYPE(JL))))) &
               & /((1._JPRB + surface_exp(0.3_JPRB*(RVT1AMMAX(KVTYPE(JL)) - ZTSK(JL))))* &
               & (1._JPRB + surface_exp(0.3_JPRB*(ZTSK(JL) - RVT2AMMAX(KVTYPE(JL))))))
            ZGMEST(JL) = (ZGMEST(JL)*surface_exp(Z1(JL)*surface_log(RVQDGMES(KVTYPE(JL))))) &
               & /((1._JPRB + surface_exp(0.3_JPRB*(RVT1GMES(KVTYPE(JL)) - ZTSK(JL))))* &
               & (1._JPRB + surface_exp(0.3_JPRB*(ZTSK(JL) - RVT2GMES(KVTYPE(JL))))))
          END IF
        END IF

        IF (PCM1(JL) > 0.0_JPRB) THEN
          ZCO2(JL) = PCM1(JL)
        ELSE
          status = 2
          return
        END IF

        ZTAN(JL) = 0._JPRB
        ZTAG(JL) = 0._JPRB
        ZTRD(JL) = 0._JPRB
        ZTGS(JL) = 0._JPRB
      END DO

      IF (LEFARQUHAR) THEN

        CALL FARQUHAR(KIDIA, KFDIA, KLON, LDLAND, KVTYPE, KCO2TYP, YDAGS, YDAGF, &
       &               YDCST, PSRFD, &
       &               PAPHM1, PQS, ZQSURF, PQM1, PTM1, PTSKM1M, PTSOIL, PF2, &
       &               ZCO2, PLAI, ZXTGS, PAG, PRD, PAN, child_status)
        if (child_status /= 0) then
          status = 100 + child_status
          return
        end if

        DO JL = KIDIA, KFDIA
          IF (LDLAND(JL) .AND. KVTYPE(JL) > 0._JPRB) THEN
            PWET(JL) = 1._JPRB/MAX(RCONDCTMIN, ZXTGS(JL))
          ELSE
            PWET(JL) = 0._JPRB
          END IF
        END DO

      ELSE

        DO JINT = 1, SIZE(RABC)

          CALL CCETR(KIDIA, KFDIA, KLON, KVTYPE, LDLAND, ZIA, ZMU0, RABC(JINT), PLAI, YDAGS, ZXIA)

          CALL COTWO(KIDIA, KFDIA, KLON, LDLAND, ZAN0, ZAG0, ZRD0, ZGS0, ZRVGC, ZCO2, &
               & PDSP, ZDMAXT, ZXIA, ZGAMMT, YDAGS, &
               & ZFZEROT, ZGMEST, ZRVEPSO, ZAMMAX)

          DO JL = KIDIA, KFDIA
            IF (LDLAND(JL)) THEN
              ZTAN(JL) = ZTAN(JL) + ZAN0(JL)*RPOI(JINT)
              ZTAG(JL) = ZTAG(JL) + ZAG0(JL)*RPOI(JINT)
              ZTRD(JL) = ZTRD(JL) + ZRD0(JL)*RPOI(JINT)
              ZTGS(JL) = ZTGS(JL) + ZGS0(JL)*RPOI(JINT)
            END IF
          END DO
        END DO

        DO JL = KIDIA, KFDIA
          IF (LDLAND(JL) .AND. KVTYPE(JL) > 0._JPRB) THEN
            PAN(JL) = ZTAN(JL)*PLAI(JL)*ZRHO(JL)
            PAG(JL) = ZTAG(JL)*PLAI(JL)*ZRHO(JL)
            PRD(JL) = ZTRD(JL)*PLAI(JL)*ZRHO(JL)

            ZXTGS(JL) = ZTGS(JL)*PLAI(JL)

            PWET(JL) = 1._JPRB/MAX(RCONDCTMIN, ZXTGS(JL))
          ELSE
            PAN(JL) = 0._JPRB
            PAG(JL) = 0._JPRB
            PRD(JL) = 0._JPRB
            PWET(JL) = 0._JPRB
          END IF
        END DO

      END IF

    END ASSOCIATE
    status = 0
  end subroutine cotworestress
end module
