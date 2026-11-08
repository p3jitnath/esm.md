MODULE forecast_snow_warm_start
CONTAINS
  SUBROUTINE snow_warm_start(KIDIA, KFDIA, KLON, KLEVSN,  &
                       & PSDOR, &
                       & LSMASK, PFRTI, PMU0,          &
                       & PTSA, PTSKIN, PALBSN,        &
                       & PTSN, PSSN, PRSN, PWSN,      &
                       & YDCST, YDSOIL, status)
    use iso_fortran_env, only: JPIM => int32, JPRB => real64
    USE YOS_CST, ONLY: TCST
    USE YOS_SOIL, ONLY: TSOIL
    USE SRFSN_VGRID_MOD
    use forecast_snow_profile_initialization, only: initialize_snow_profiles
    use forecast_snow_exponential_profiles, only: calculate_snow_exponential_profiles
    use forecast_snow_mass_adjustment, only: adjust_snow_mass
    IMPLICIT NONE
    integer(JPIM), intent(out) :: status
    integer(JPIM) :: allocation_status
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA, KFDIA, KLON, KLEVSN
    REAL(KIND=JPRB), INTENT(IN) :: PSDOR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSA(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKIN(:)
    REAL(KIND=JPRB), INTENT(IN) :: PALBSN(:)
    REAL(KIND=JPRB), INTENT(IN) :: LSMASK(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTSN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSSN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWSN(:, :)
    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    REAL(KIND=JPRB) :: ZACTDEPTH(KLON)
    REAL(KIND=JPRB) :: ZTHRESWS
    REAL(KIND=JPRB) :: ZSNPERT
    REAL(KIND=JPRB) :: ZDSN(KLON, KLEVSN), ZDSNREAL(KLON, KLEVSN)
    REAL(KIND=JPRB) :: ZSNDEPTH(KLON, KLEVSN)
    REAL(KIND=JPRB) :: ZSNDEPTHREAL(KLON, KLEVSN)
    REAL(KIND=JPRB), VOLATILE :: ZHSN(KLON)
    REAL(KIND=JPRB) :: ZDSNTOT(KLON)
    REAL(KIND=JPRB) :: ZDSNTOTREAL(KLON)
    REAL(KIND=JPRB) :: ZTSN(KLON)
    REAL(KIND=JPRB) :: ZRSN(KLON)
    REAL(KIND=JPRB) :: ZSSN(KLON)
    REAL(KIND=JPRB) :: ZWSN(KLON)
    REAL(KIND=JPRB) :: ZFRSN(KLON)
    REAL(KIND=JPRB) :: ZLEVMAX(KLEVSN), ZLEVMIN(KLEVSN)
    REAL(KIND=JPRB) :: ZLEVMAX_GL(KLEVSN), ZLEVMIN_GL(KLEVSN)
    REAL(KIND=JPRB) :: ZLEVMINA(KLEVSN)
    LOGICAL :: LLNOSNOW(KLON)
    INTEGER(KIND=JPRB) :: JL, JK
    REAL(KIND=JPRB) :: ZTSNTOP(KLON)
    REAL(KIND=JPRB) :: ZTSNBOTTOM(KLON)
    REAL(KIND=JPRB) :: ZTSNMIDDLE(KLON)
    REAL(KIND=JPRB) :: ZRSNTOP(KLON)
    REAL(KIND=JPRB) :: ZRSNMAX(KLON)
    REAL(KIND=JPRB) :: ZSADEPTH(KLON)
    INTEGER(KIND=JPIM) :: KLEVSNA(KLON)
    INTEGER(KIND=JPIM) :: KLEVMID(KLON)
    INTEGER(KIND=JPIM) :: ZTMINCL(KLON)
    INTEGER(KIND=JPIM) :: ZRMINCL(KLON)
    LOGICAL :: LDLAND(KLON)
    INTEGER(KIND=JPIM) :: INCL
    REAL(KIND=JPRB) :: ZTSNWS(KLON, KLEVSN)
    REAL(KIND=JPRB) :: ZRSNWS(KLON, KLEVSN)
    REAL(KIND=JPRB) :: ZSSNWS(KLON, KLEVSN)
    REAL(KIND=JPRB) :: ZWSNWS(KLON, KLEVSN)
    REAL(KIND=JPRB), ALLOCATABLE :: ZTCONSTAVG(:, :), ZTCONSTSTD(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZRCONSTAVG(:, :), ZRCONSTSTD(:, :)
    REAL(KIND=JPRB), VOLATILE :: ZIHCAP
    status = 2_JPIM
    if (klon < 1 .or. klon > 4096 .or. klevsn < 5 .or. klevsn > 512) return
    if (kidia < 1 .or. kfdia < kidia .or. kfdia > klon) return
    if (ydsoil%nsnmlws /= 2) return
    if (.not. allocated(ydsoil%rlevsnmin) .or. .not. allocated(ydsoil%rlevsnmax)) return
    if (.not. allocated(ydsoil%rlevsnmin_gl) .or. .not. allocated(ydsoil%rlevsnmax_gl)) return
    if (min(size(ydsoil%rlevsnmin), size(ydsoil%rlevsnmax), size(ydsoil%rlevsnmin_gl), size(ydsoil%rlevsnmax_gl)) < klevsn) return
    if (min(size(psdor), size(lsmask), size(pmu0), size(ptskin), size(palbsn)) < klon) return
    if (size(pfrti, 1) < klon .or. size(pfrti, 2) < 7) return
    if (size(ptsa, 1) < klon .or. size(ptsa, 2) < 1) return
    if (min(size(ptsn, 1), size(pssn, 1), size(prsn, 1), size(pwsn, 1)) < klon) return
    if (min(size(ptsn, 2), size(pssn, 2), size(prsn, 2), size(pwsn, 2)) < klevsn) return
    ASSOCIATE (RTT => YDCST%RTT, RLMLT => YDCST%RLMLT, RPI => YDCST%RPI,    &
            & RLWCSWEA => YDSOIL%RLWCSWEA, RLWCSWEB => YDSOIL%RLWCSWEB, &
            & RLWCSWEC => YDSOIL%RLWCSWEC, RTEMPAMP => YDSOIL%RTEMPAMP, &
            & RDSNMAX => YDSOIL%RDSNMAX, RHOMINSND => YDSOIL%RHOMINSND, &
            & RHOMAXSN_NEW => YDSOIL%RHOMAXSN_NEW, RDAT => YDSOIL%RDAT, &
            & NSNMLWS => YDSOIL%NSNMLWS)
      INCL = 27_JPIM
      ZTHRESWS = 0.125_JPRB
      ZIHCAP = YDSOIL%RHOCI/YDSOIL%RHOICE
      ZSNPERT = 9000.0_JPRB
      ZLEVMAX = YDSOIL%RLEVSNMAX
      ZLEVMIN = YDSOIL%RLEVSNMIN
      ZLEVMAX_GL = YDSOIL%RLEVSNMAX_GL
      ZLEVMIN_GL = YDSOIL%RLEVSNMIN_GL
      allocate (ZTCONSTAVG(KLON, INCL), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_JPIM; return
      end if
      allocate (ZTCONSTSTD(KLON, INCL), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_JPIM; return
      end if
      allocate (ZRCONSTAVG(KLON, INCL), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_JPIM; return
      end if
      allocate (ZRCONSTSTD(KLON, INCL), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_JPIM; return
      end if
      DO JL = KIDIA, KFDIA
        ZFRSN(JL) = MAX(PFRTI(JL, 5) + PFRTI(JL, 7), YDSOIL%RFRTINY)
        IF (ZFRSN(JL) < YDSOIL%RFRSMALL) THEN
          LLNOSNOW(JL) = .TRUE.
        ELSE
          LLNOSNOW(JL) = .FALSE.
        END IF
        IF (LSMASK(JL) == 1._JPRB) THEN
          LDLAND(JL) = .TRUE.
        ELSE
          LDLAND(JL) = .FALSE.
        END IF
      END DO
      CALL SRFSN_VGRID(KIDIA, KFDIA, KLON, KLEVSN, LLNOSNOW, &
                     & PSDOR,                             &
                     & PSSN, PRSN,                         &
                     & ZLEVMIN, ZLEVMAX, &
                     & ZLEVMIN_GL, ZLEVMAX_GL, &
                     & ZDSN, KLEVSNA)
      DO JL = KIDIA, KFDIA
        DO JK = 1, KLEVSN
          ZDSNREAL(JL, JK) = ZDSN(JL, JK)
          ZDSN(JL, JK) = MIN(1._JPRB, ZDSN(JL, JK))
        END DO
      END DO
      ZHSN(KIDIA:KFDIA) = ZIHCAP*(PSSN(KIDIA:KFDIA, 1))* &
                          (PTSN(KIDIA:KFDIA, 1) - RTT) - RLMLT*(PSSN(KIDIA:KFDIA, 1) - PWSN(KIDIA:KFDIA, 1))
      ZDSNTOT(KIDIA:KFDIA) = SUM(ZDSN(KIDIA:KFDIA, :), DIM=2)
      ZDSNTOTREAL(KIDIA:KFDIA) = SUM(ZDSNREAL(KIDIA:KFDIA, :), DIM=2)
      ZTSN(KIDIA:KFDIA) = PTSN(KIDIA:KFDIA, 1)
      ZRSN(KIDIA:KFDIA) = PRSN(KIDIA:KFDIA, 1)
      ZSSN(KIDIA:KFDIA) = SUM(PSSN(KIDIA:KFDIA, :), DIM=2)
      ZWSN(KIDIA:KFDIA) = 0._JPRB
      IF (NSNMLWS == 3_JPIM) THEN
        ZSNDEPTH(KIDIA:KFDIA, :) = 0.5_JPRB*ZDSN(KIDIA:KFDIA, :)
        ZSNDEPTHREAL(KIDIA:KFDIA, :) = 0.5_JPRB*ZDSNREAL(KIDIA:KFDIA, :)
      ELSE
        ZSNDEPTH(KIDIA:KFDIA, 1) = 0._JPRB
        ZSNDEPTHREAL(KIDIA:KFDIA, 1) = 0._JPRB
      END IF
      DO JK = 2, KLEVSN
        ZSNDEPTH(KIDIA:KFDIA, JK) = ZSNDEPTH(KIDIA:KFDIA, JK - 1) + 0.5*(ZDSN(KIDIA:KFDIA, JK - 1) + ZDSN(KIDIA:KFDIA, JK))
        ZSNDEPTHREAL(KIDIA:KFDIA, JK) = ZSNDEPTHREAL(KIDIA:KFDIA, JK - 1) + &
                                       &0.5*(ZDSNREAL(KIDIA:KFDIA, JK - 1) + ZDSNREAL(KIDIA:KFDIA, JK))
      END DO
      DO JL = KIDIA, KFDIA
        ZTSNWS(JL, 1:KLEVSN) = ZTSN(JL)
        ZRSNWS(JL, 1:KLEVSN) = ZRSN(JL)
        ZSSNWS(JL, 1) = ZSSN(JL)
        ZSSNWS(JL, 2:KLEVSN) = 0._JPRB
        ZWSNWS(JL, 1:KLEVSN) = 0._JPRB
      END DO
      ZTCONSTAVG = 0._JPRB
      ZTCONSTSTD = 0._JPRB
      ZRCONSTAVG = 0._JPRB
      ZRCONSTSTD = 0._JPRB
      ZTMINCL = 1_JPIM
      ZRMINCL = 1_JPIM
      CALL initialize_snow_profiles(KIDIA, KFDIA, KLON, KLEVSN, INCL, PMU0, PSDOR,  &
                     & PTSA(:, 1), PTSKIN, &
                     & ZDSNTOT, ZSNDEPTH,               &
                     & ZSNPERT,                &
                     & ZDSNREAL, ZTSN, ZRSN, ZSSN, ZWSN, PALBSN,            &
                     & ZTSNWS, ZSSNWS, ZRSNWS, ZWSNWS,                       &
                     & ZTSNTOP, ZTSNBOTTOM, ZTSNMIDDLE,                   &
                     & ZRSNMAX, ZSADEPTH, KLEVSNA, KLEVMID, ZACTDEPTH,    &
                     & ZTMINCL, ZRMINCL,                                   &
                     & ZTCONSTAVG, ZTCONSTSTD,                            &
                     & ZRCONSTAVG, ZRCONSTSTD, ZRSNTOP,                   &
                     & YDCST, YDSOIL)
      CALL calculate_snow_exponential_profiles(KIDIA, KFDIA, KLON, KLEVSN,               &
                       & KLEVSNA, KLEVMID,                         &
                       & ZTHRESWS, ZSNPERT, LLNOSNOW,              &
                       & ZTSN, ZSSN, ZRSN, PTSA(:, 1),              &
                       & ZDSNTOT, ZACTDEPTH, ZSNDEPTH, ZSNDEPTHREAL, ZSADEPTH,    &
                       & ZTSNBOTTOM, ZTSNTOP, ZTSNMIDDLE,          &
                       & ZRSNTOP, ZRSNMAX,                         &
                       & ZTCONSTAVG, ZTMINCL, ZRCONSTAVG, ZRMINCL, &
                       & ZTSNWS, ZRSNWS, YDCST, YDSOIL)
      CALL adjust_snow_mass(KIDIA, KFDIA, KLON, KLEVSN,         &
                       &  KLEVSNA, ZTHRESWS,                   &
                       &  ZDSN, ZDSNREAL, ZSNDEPTH, ZSNDEPTHREAL,&
                       &  ZRSN, ZSSN, ZRSNMAX, ZDSNTOT,       &
                       &  ZRCONSTAVG, ZRMINCL,                &
                       &  ZSNPERT,                            &
                       &  ZTSNWS,                             &
                       &  ZRSNWS, ZSSNWS, ZWSNWS, ZRSNTOP,     &
                       &  YDCST, YDSOIL)

      DO JL = KIDIA, KFDIA
        IF (.NOT. LLNOSNOW(JL) .AND. KLEVSNA(JL) > 1) THEN
          IF ((.NOT. ANY(ZTSNWS(JL, 1:KLEVSN) < 100._JPRB)) .AND. (.NOT. ANY(ZTSNWS(JL, 1:KLEVSN) > RTT))) THEN
            PTSN(JL, 1:KLEVSN) = ZTSNWS(JL, 1:KLEVSN)
            PRSN(JL, 1:KLEVSN) = ZRSNWS(JL, 1:KLEVSN)
            PSSN(JL, 1:KLEVSN) = ZSSNWS(JL, 1:KLEVSN)
            PWSN(JL, 1:KLEVSN) = ZWSNWS(JL, 1:KLEVSN)
          ELSE
            WRITE (*, *) 'Very cold snow temperature in snow_warm_start. Reset to initial (not-warm-started) values.'
            WRITE (*, *) 'Tsn warm start:', PTSN(JL, 1:KLEVSN), ZTSNWS(JL, 1:KLEVSN)
          END IF
        END IF
      END DO
      DEALLOCATE (ZTCONSTAVG)
      DEALLOCATE (ZTCONSTSTD)
      DEALLOCATE (ZRCONSTAVG)
      DEALLOCATE (ZRCONSTSTD)
    END ASSOCIATE
    status = 0_JPIM
  END SUBROUTINE snow_warm_start
END MODULE forecast_snow_warm_start
