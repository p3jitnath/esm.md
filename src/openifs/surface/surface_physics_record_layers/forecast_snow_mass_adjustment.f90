!> Own the ordered snow warm-start child using canonical parameter records.
!! Active cells keep their source units and unused cells retain incoming values.
MODULE forecast_snow_mass_adjustment
CONTAINS
  SUBROUTINE adjust_snow_mass(KIDIA, KFDIA, KLON, KLEVSN,    &
                         &   KLEVSNA, ZTHRESWS,             &
                         &  PDSN, PDSNREAL, PSNDEPTH, PSNDEPTHR,&
                         &  PRSN, PSSN, PRSNMAX, PDSNTOT,   &
                         &  PRCONSTAVG, PRMINCL,            &
                         &  ZSNPERT,                        &
                         &  PTSNWS,                         &
                         &  PRSNWS, PSSNWS, PWSNWS, PRSNTOP, &
                         &  YDCST, YDSOIL)
    use iso_fortran_env, only: JPIM => int32, JPRB => real64
    USE YOS_CST, ONLY: TCST
    USE YOS_SOIL, ONLY: TSOIL
    IMPLICIT NONE
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON, KIDIA, KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVSN
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVSNA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PDSN(:, :), PDSNREAL(:, :), PSNDEPTH(:, :), PSNDEPTHR(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PRSN(:), PSSN(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRSNMAX(:)
    REAL(KIND=JPRB), INTENT(IN) :: PDSNTOT(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRCONSTAVG(:, :)
    INTEGER(KIND=JPIM), INTENT(IN) :: PRMINCL(:)
    REAL(KIND=JPRB), INTENT(IN) :: ZSNPERT
    REAL(KIND=JPRB), INTENT(IN) :: ZTHRESWS
    REAL(KIND=JPRB), INTENT(IN) :: PTSNWS(:, :)
    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSNWS(:, :), PSSNWS(:, :), PWSNWS(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSNTOP(:)
    REAL(KIND=JPRB) :: ZRSNWSTST(KLON, KLEVSN)
    REAL(KIND=JPRB) :: ZERRORTST, ZERROR
    REAL(KIND=JPRB) :: ZRBOTTOM
    REAL(KIND=JPRB) :: ZRBOTTOMTST
    REAL(KIND=JPRB) :: ZRBOTTOMSTORE
    REAL(KIND=JPRB) :: ZRSNTOPTST
    REAL(KIND=JPRB) :: ZRSNTOPSTORE
    REAL(KIND=JPRB) :: ZDELTAC
    REAL(KIND=JPRB) :: ZDRSN
    REAL(KIND=JPRB) :: ZBR, ZAR, ZCR
    REAL(KIND=JPRB) :: ZLWC, ZFUNC
    INTEGER(KIND=JPIM) :: KFILLING
    INTEGER(KIND=JPIM) :: ICOUNTMAX, ICOUNT
    INTEGER(KIND=JPIM) :: JL, JK
    REAL(KIND=JPRB) :: ZEPSILON
    real(kind=JPRB) :: snow_mass_argument, snow_density_argument, flwc
    flwc(snow_mass_argument, snow_density_argument) = snow_mass_argument*(YDSOIL%RLWCSWEB + &
                          (YDSOIL%RLWCSWEC - YDSOIL%RLWCSWEB)*max(0._JPRB, YDSOIL%RLWCSWEA - snow_density_argument)/YDSOIL%RLWCSWEA)
    ASSOCIATE (RTT => YDCST%RTT, RPI => YDCST%RPI, &
            & RHOMINSND => YDSOIL%RHOMINSND, RTEMPAMP => YDSOIL%RTEMPAMP)
      ZEPSILON = 10E4*EPSILON(ZEPSILON)
      KFILLING = 1._JPIM
      DO JL = KIDIA, KFDIA
        IF (PDSNTOT(JL) >= ZTHRESWS) THEN
          ZRSNWSTST(JL, 1:KLEVSN) = PRSNWS(JL, 1:KLEVSN)
          ZERRORTST = 0._JPRB
          ZRBOTTOMTST = PRSNWS(JL, KLEVSNA(JL))
          ZRBOTTOMSTORE = PRSNWS(JL, KLEVSNA(JL))
          ZDELTAC = 0._JPRB
          ZDRSN = 50.0_JPRB
          ICOUNTMAX = 50_JPIM*2_JPIM + 1_JPIM
          ICOUNT = 1_JPIM
          ZERROR = (SUM((PRSNWS(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
          ZCR = PRCONSTAVG(JL, PRMINCL(JL))
          DO WHILE ((ABS(ZERROR) > ZEPSILON) .AND. (ICOUNT < ICOUNTMAX))
            ZDELTAC = ZDRSN - (ICOUNT)*ZDRSN/(0.5_JPRB*ICOUNTMAX)
            ZRBOTTOMTST = PRSNWS(JL, KLEVSNA(JL)) - ZDELTAC
            ZBR = (ZRBOTTOMTST - PRSNTOP(JL))/SIGN(MAX(ZEPSILON,             &
                                      &ABS(MAX(ZEPSILON, EXP(-PDSNTOT(JL)*ZCR)) - 1)),&
                                      &(MAX(ZEPSILON, EXP(-PDSNTOT(JL)*ZCR)) - 1))
            ZAR = PRSNTOP(JL) - ZBR*EXP(-PSNDEPTHR(JL, 1)*ZCR)
            DO JK = 1, KLEVSNA(JL)
              ZRSNWSTST(JL, JK) = ZAR + ZBR*MAX(ZEPSILON, EXP(-PSNDEPTHR(JL, JK)*ZCR))
              IF (ZRSNWSTST(JL, JK) < RHOMINSND) ZRSNWSTST(JL, JK) = RHOMINSND
              IF (ZRSNWSTST(JL, JK) > PRSNMAX(JL)) ZRSNWSTST(JL, JK) = PRSNMAX(JL)
            END DO
            IF (KLEVSNA(JL) < KLEVSN) THEN
              ZRSNWSTST(JL, KLEVSNA(JL) + 1:KLEVSN) = 100._JPRB
            END IF
            ZERRORTST = (SUM((ZRSNWSTST(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
            IF (ABS(ZERRORTST) < ABS(ZERROR)) THEN
              PRSNWS(JL, 1:KLEVSNA(JL)) = ZRSNWSTST(JL, 1:KLEVSNA(JL))
              ZERROR = ZERRORTST
              ZRBOTTOMSTORE = ZRBOTTOMTST
            END IF
            ICOUNT = ICOUNT + 1_JPIM
          END DO
          ZRBOTTOM = ZRBOTTOMSTORE
          IF (PSSN(JL) < ZSNPERT) THEN
            ZRSNWSTST(JL, :) = PRSNWS(JL, :)
            ZRSNTOPSTORE = PRSNTOP(JL)
            ZRSNTOPTST = PRSNTOP(JL)
            ZDELTAC = 0._JPRB
            ZERRORTST = 0._JPRB
            ZERROR = (SUM((PRSNWS(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
            ZDRSN = 20.0_JPRB
            ICOUNTMAX = INT(ZDRSN)*2_JPIM + 1_JPIM
            ICOUNT = 1_JPIM
            DO WHILE ((ABS(ZERROR) > ZEPSILON) .AND. (ICOUNT < ICOUNTMAX))
              ZDELTAC = ZDRSN - (ICOUNT)*ZDRSN/(0.5_JPRB*ICOUNTMAX)
              ZRSNTOPTST = PRSNTOP(JL) - ZDELTAC
              ZBR = (ZRBOTTOM - ZRSNTOPTST)/SIGN(MAX(ZEPSILON,            &
                                       &ABS(MAX(ZEPSILON, EXP(-PDSNTOT(JL)*ZCR)) - 1)),&
                                       &(MAX(ZEPSILON, EXP(-PDSNTOT(JL)*ZCR)) - 1))
              ZAR = ZRSNTOPTST - ZBR*MAX(ZEPSILON, EXP(-PSNDEPTHR(JL, 1)*ZCR))
              DO JK = 1, KLEVSNA(JL)
                ZRSNWSTST(JL, JK) = ZAR + ZBR*exp(-PSNDEPTHR(JL, JK)*ZCR)
                IF (ZRSNWSTST(JL, JK) < RHOMINSND) THEN
                  ZRSNWSTST(JL, JK) = RHOMINSND
                END IF
                IF (ZRSNWSTST(JL, JK) > PRSNMAX(JL)) THEN
                  ZRSNWSTST(JL, JK) = PRSNMAX(JL)
                END IF
              END DO
              IF (KLEVSNA(JL) < KLEVSN) THEN
                ZRSNWSTST(JL, KLEVSNA(JL) + 1:KLEVSN) = 100._JPRB
              END IF
              ZERRORTST = (SUM((ZRSNWSTST(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
              IF (ABS(ZERRORTST) < ABS(ZERROR)) THEN
                PRSNWS(JL, :) = ZRSNWSTST(JL, :)
                ZERROR = ZERRORTST
                ZRSNTOPSTORE = ZRSNTOPTST
              END IF
              ICOUNT = ICOUNT + 1_JPIM
            END DO
            PRSNTOP(JL) = ZRSNTOPSTORE
            ICOUNTMAX = 1000_JPIM
            ZERROR = (SUM((PRSNWS(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
            ICOUNT = 1_JPIM
            DO WHILE ((ABS(ZERROR) > ZEPSILON) .AND. (ICOUNT < ICOUNTMAX))
              IF (PDSNTOT(JL) >= 0.15_JPRB) THEN
                KFILLING = MAX(1, KLEVSNA(JL) - 1_JPIM)
              ELSEIF (PDSNTOT(JL) < 0.15_JPRB) THEN
                KFILLING = MIN(2_JPIM, KLEVSNA(JL))
              END IF
              IF (ZERROR < 0._JPRB) THEN
                IF (KFILLING > 1) THEN
                  PRSNWS(JL, KFILLING:KLEVSNA(JL)) = PRSNWS(JL, KFILLING:KLEVSNA(JL)) + 0.1_JPRB
                  IF (KFILLING > 2) THEN
                    PRSNWS(JL, 2:KFILLING - 1) = PRSNWS(JL, 2:KFILLING - 1) + 0.005_JPRB
                  END IF
                ELSE
                  PRSNWS(JL, KFILLING) = PRSNWS(JL, KFILLING) + 0.1_JPRB
                END IF
              ELSEIF (ZERROR > 0._JPRB) THEN
                IF (KFILLING > 1) THEN
                  IF (PRSNWS(JL, KFILLING) > PRSNWS(JL, KFILLING - 1)) THEN
                    PRSNWS(JL, KFILLING:KLEVSNA(JL)) = PRSNWS(JL, KFILLING:KLEVSNA(JL)) - 0.1_JPRB
                    PRSNWS(JL, 1:KFILLING - 1) = PRSNWS(JL, 1:KFILLING - 1) - 0.01_JPRB
                  ELSE
                    PRSNWS(JL, 1:KLEVSNA(JL)) = PRSNWS(JL, 1:KLEVSNA(JL)) - 0.01_JPRB
                  END IF
                ELSE
                  PRSNWS(JL, KFILLING) = PRSNWS(JL, KFILLING) - 0.1_JPRB
                END IF
              END IF
              ZERROR = (SUM((PRSNWS(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
              ICOUNT = ICOUNT + 1_JPIM
            END DO
          ELSE
            ICOUNTMAX = 1000_JPIM
            ZERROR = (SUM((PRSNWS(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
            ICOUNT = 1_JPIM
            DO WHILE ((ABS(ZERROR) > ZEPSILON) .AND. (ICOUNT < ICOUNTMAX))
              KFILLING = 1
              IF (ZERROR < 0._JPRB) THEN
                PRSNWS(JL, 1:KLEVSNA(JL) - 2) = PRSNWS(JL, 1:KLEVSNA(JL) - 2) + 0.01_JPRB
              ELSEIF (ZERROR > 0._JPRB) THEN
                PRSNWS(JL, 1:KLEVSNA(JL) - 2) = PRSNWS(JL, 1:KLEVSNA(JL) - 2) - 0.01_JPRB
              END IF
              ZERROR = (SUM((PRSNWS(JL, 1:KLEVSNA(JL))*PDSNREAL(JL, 1:KLEVSNA(JL))), DIM=1) - PSSN(JL))/PSSN(JL)
              ICOUNT = ICOUNT + 1_JPIM
            END DO
          END IF
          DO JK = 1, KLEVSNA(JL)
            PSSNWS(JL, JK) = (PRSNWS(JL, JK)*PDSNREAL(JL, JK))
          END DO
          IF (SUM(PSSNWS(JL, 1:KLEVSNA(JL)), DIM=1) .NE. PSSN(JL)) THEN
            ZERROR = (SUM(PSSNWS(JL, 1:KLEVSNA(JL)), DIM=1) - PSSN(JL))/PSSN(JL)
            DO JK = 1, KLEVSNA(JL) - 2
              PSSNWS(JL, JK) = PSSNWS(JL, JK) - ((ZERROR*PSSN(JL))*PDSNREAL(JL, JK)/SUM(PDSNREAL(JL, 1:KLEVSNA(JL)), DIM=1))
              PRSNWS(JL, JK) = PSSNWS(JL, JK)/PDSNREAL(JL, JK)
              IF (PRSNWS(JL, JK) < RHOMINSND) THEN
                PRSNWS(JL, JK) = RHOMINSND
                PSSNWS(JL, JK) = (PRSNWS(JL, JK)*PDSNREAL(JL, JK))
              END IF
              IF (PRSNWS(JL, JK) > PRSNMAX(JL)) THEN
                PRSNWS(JL, JK) = PRSNMAX(JL)
                PSSNWS(JL, JK) = (PRSNWS(JL, JK)*PDSNREAL(JL, JK))
              END IF
            END DO
            IF (SUM(PSSNWS(JL, 1:KLEVSNA(JL)), DIM=1) .NE. PSSN(JL)) THEN
              ZERROR = (SUM(PSSNWS(JL, 1:KLEVSNA(JL)), DIM=1) - PSSN(JL))/PSSN(JL)
              if (KLEVSNA(JL) == 1) then
             if (.not. (abs(ZERROR) <= 100000._JPRB*epsilon(1._JPRB))) error stop "Snow mass residual outside the admitted interval"
                PSSNWS(JL, 1) = PSSN(JL)
              else
                PSSNWS(JL, KLEVSNA(JL) - 1) = PSSNWS(JL, KLEVSNA(JL) - 1) - (ZERROR*PSSN(JL))
              end if
            END IF
          END IF
          IF (PSSN(JL) < ZSNPERT) THEN
            DO JK = 1, KLEVSNA(JL)
              ZLWC = FLWC(PSSNWS(JL, JK), PRSNWS(JL, JK))
              IF (PTSNWS(JL, JK) < RTT - 0.5_JPRB*RTEMPAMP) THEN
                ZFUNC = 0._JPRB
              ELSEIF (PTSNWS(JL, JK) < RTT) THEN
                ZFUNC = (1._JPRB + SIN(RPI*(PTSNWS(JL, JK) - RTT)/(RTEMPAMP)))
              ELSE
                ZFUNC = 0._JPRB
              END IF
              PWSNWS(JL, JK) = ZFUNC*ZLWC
            END DO
          ELSE
            PWSNWS(JL, :) = 0._JPRB
          END IF
        END IF
      END DO
    END ASSOCIATE
  END SUBROUTINE adjust_snow_mass
END MODULE forecast_snow_mass_adjustment
