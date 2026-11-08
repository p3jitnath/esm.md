!> Own the ordered snow warm-start child using canonical parameter records.
!! Active cells keep their source units and unused cells retain incoming values.
MODULE forecast_snow_exponential_profiles
CONTAINS
  SUBROUTINE calculate_snow_exponential_profiles(KIDIA, KFDIA, KLON, KLEVSN,               &
                         & KLEVSNA, KLEVMID,                         &
                         & ZTHRESWS, ZSNPERT, LLNOSNOW,               &
                         & PTSN, PSSN, PRSN, PTSA,                   &
                         & PDSNTOT, PACTDEPTH, PSNDEPTH, PSNDEPTHR, PSADEPTH,    &
                         & PTSNBOTTOM, PTSNTOP, PTSNMIDDLE,          &
                         & PRSNTOP, PRSNMAX,    &
                         & PTCONSTAVG, PTMINCL, PRCONSTAVG, PRMINCL, &
                         & PTSNWS, PRSNWS,                           &
                         & YDCST, YDSOIL)
    use iso_fortran_env, only: JPIM => int32, JPRB => real64
    USE YOS_CST, ONLY: TCST
    USE YOS_SOIL, ONLY: TSOIL
    IMPLICIT NONE
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA, KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVSN
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVSNA(:), KLEVMID(:)
    LOGICAL, INTENT(IN) :: LLNOSNOW(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSN(:), PRSN(:), PSSN(:), PTSA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PDSNTOT(:), PACTDEPTH(:), PSADEPTH(:)
    REAL(KIND=JPRB), INTENT(IN) :: PSNDEPTH(:, :), PSNDEPTHR(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSNBOTTOM(:), PTSNTOP(:), PTSNMIDDLE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRSNTOP(:), PRSNMAX(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTCONSTAVG(:, :), PRCONSTAVG(:, :)
    INTEGER(KIND=JPIM), INTENT(IN) :: PTMINCL(:), PRMINCL(:)
    REAL(KIND=JPRB), INTENT(IN) :: ZTHRESWS, ZSNPERT
    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    REAL(KIND=JPRB), INTENT(INOUT) :: PTSNWS(:, :), PRSNWS(:, :)
    REAL(KIND=JPRB) :: ZAT, ZBT, ZCT, ZAR, ZBR, ZCR
    REAL(KIND=JPRB) :: ZP1, ZP2, ZP3, ZP4, ZP5
    REAL(KIND=JPRB) :: ZTMULT
    REAL(KIND=JPRB) :: ZEPSILON
    INTEGER(KIND=JPIM) :: JL, JK, ILEVMID
    ASSOCIATE (RTT => YDCST%RTT, RHOMINSND => YDSOIL%RHOMINSND, NSNMLWS => YDSOIL%NSNMLWS)
      ZAT = 0._JPRB
      ZBT = 0._JPRB
      ZCT = 0._JPRB
      ZAR = 0._JPRB
      ZBR = 0._JPRB
      ZCR = 0._JPRB
      ZEPSILON = 10E4*EPSILON(ZEPSILON)
      DO JL = KIDIA, KFDIA
        IF (.NOT. LLNOSNOW(JL)) THEN
        IF ((KLEVSNA(JL) > 1) .AND. (PDSNTOT(JL) >= ZTHRESWS)) THEN
          ILEVMID = KLEVMID(JL)
          ZCT = PTCONSTAVG(JL, PTMINCL(JL))
          IF (PDSNTOT(JL) < 0.20_JPRB) THEN
            ZTMULT = 1._JPRB
            ZBT = (PTSNBOTTOM(JL) - PTSNTOP(JL))/SIGN(MAX(ZEPSILON,                   &
                                         &ABS(MAX(ZEPSILON, EXP(-PDSNTOT(JL)*ZCT)) - 1)),&
                                         &(MAX(ZEPSILON, EXP(-PDSNTOT(JL)*ZCT)) - 1))
            ZAT = PTSNTOP(JL) - ZBT
          ELSE
            ZTMULT = 0._JPRB
            IF (PTSNTOP(JL) >= PTSNMIDDLE(JL)) THEN
              ZBT = (PTSNBOTTOM(JL) - PTSNTOP(JL))/SIGN(MAX(ZEPSILON,                                        &
                                      &ABS((MAX(ZEPSILON, EXP(-PACTDEPTH(JL)*ZCT)) - 1.0_JPRB))),&
                                      &((MAX(ZEPSILON, EXP(-PACTDEPTH(JL)*ZCT)) - 1.0_JPRB)))
              IF (PTSNTOP(JL) <= RTT) THEN
                ZAT = PTSNTOP(JL) - ZBT
              ELSE
                ZAT = RTT - ZBT
              END IF
            ELSE
              ZBT = (PTSNBOTTOM(JL) - PTSNTOP(JL))/SIGN(MAX(ZEPSILON,                                 &
                                      &ABS(MAX(ZEPSILON, EXP(-(PACTDEPTH(JL) + PSADEPTH(JL))*ZCT)) - 1._JPRB)),&
                                      &(MAX(ZEPSILON, EXP(-(PACTDEPTH(JL) + PSADEPTH(JL))*ZCT)) - 1._JPRB))
              ZAT = PTSNTOP(JL) - ZBT
            END IF
          END IF
          ZCR = PRCONSTAVG(JL, PRMINCL(JL))
          ZBR = (PRSN(JL) - PRSNTOP(JL))/SIGN(MAX(ZEPSILON,                                                  &
                                     &ABS(EXP(-PSNDEPTHR(JL, ILEVMID)*ZCR) - EXP(-PSNDEPTHR(JL, 1)*ZCR))),&
                                     &(EXP(-PSNDEPTHR(JL, ILEVMID)*ZCR) - EXP(-PSNDEPTHR(JL, 1)*ZCR)))
          ZAR = PRSNTOP(JL) - ZBR*EXP(-PSNDEPTHR(JL, 1)*ZCR)
          DO JK = 1, KLEVSNA(JL)
            PTSNWS(JL, JK) = MIN(RTT, ZAT + ZBT*MAX(ZEPSILON, EXP(-PSNDEPTH(JL, JK)*ZCT)))
            IF (NSNMLWS == 2_JPIM .OR. NSNMLWS == 3_JPIM) THEN
              IF (PTSNWS(JL, JK) > RTT) PTSNWS(JL, JK) = RTT
              IF (KLEVSNA(JL) >= 2) THEN
                IF (PDSNTOT(JL) >= 0.5_JPRB) THEN
                  PTSNWS(JL, KLEVSNA(JL) - 1) = PTSNMIDDLE(JL)
                ELSEIF (PDSNTOT(JL) >= 0.20_JPRB) THEN
                  PTSNWS(JL, ILEVMID) = PTSNMIDDLE(JL)
                END IF
              END IF
              IF (PDSNTOT(JL) < 0.20_JPRB) THEN
                PTSNWS(JL, ILEVMID) = PTSNMIDDLE(JL)
              END IF
            END IF
            IF (PTSNWS(JL, JK) < 100._JPRB) PTSNWS(JL, JK) = PTSNMIDDLE(JL)
            PRSNWS(JL, JK) = ZAR + ZBR*MAX(ZEPSILON, EXP(-PSNDEPTHR(JL, JK)*ZCR))
            PRSNWS(JL, ILEVMID) = PRSN(JL)
            IF (PRSNWS(JL, JK) < RHOMINSND) THEN
              PRSNWS(JL, JK) = RHOMINSND
            END IF
            IF (PRSNWS(JL, JK) > PRSNMAX(JL)) THEN
              PRSNWS(JL, JK) = PRSNMAX(JL)
            END IF
            IF (PSSN(JL) >= ZSNPERT) THEN
              PRSNWS(JL, KLEVSNA(JL) - 1:KLEVSNA(JL)) = 300._JPRB
            END IF
          END DO
          IF (PSSN(JL) >= ZSNPERT) PTSNWS(JL, KLEVSNA(JL)) = MIN(RTT, PTSA(JL))
          IF (PSSN(JL) >= ZSNPERT) PRSNWS(JL, 1:KLEVSN) = 300._JPRB
          IF (KLEVSNA(JL) < KLEVSN) THEN
            PTSNWS(JL, KLEVSNA(JL) + 1:KLEVSN) = PTSNWS(JL, KLEVSNA(JL))
            PRSNWS(JL, KLEVSNA(JL) + 1:KLEVSN) = 100._JPRB
          END IF
        END IF
        END IF
      END DO
    END ASSOCIATE
  END SUBROUTINE calculate_snow_exponential_profiles
END MODULE forecast_snow_exponential_profiles
