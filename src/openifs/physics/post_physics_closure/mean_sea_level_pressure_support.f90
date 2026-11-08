! (C) Copyright 1989- ECMWF and Meteo-France. Apache Licence Version2.0.
!> Compute mean sea-level pressure with explicit physical and lapse inputs.
!! Pressure is Pa, temperature is kelvin, and orography is geopotential m2/s2.
!! RD is J/(kg K), RG is m/s2, and RDTDZ1 is kelvin per metre.
!! All original ordered arithmetic and the optional QNH branch are owned here.
!! Only active output columns change. Caller establishes floating mode once.
module forecast_native_mean_sea_level_pressure
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int32, real64
  implicit none
  private
  public :: pppmer
contains
  integer(int32) function pppmer(KPROMA, KSTART, KPROF, PRPRESS, POROG, PTSTAR, PT0, PMSLPPP, RDTDZ1, RG, RD, LDQNH) result(status)
    real(real64), intent(in) :: RDTDZ1, RG, RD
    INTEGER(KIND=JPIM), INTENT(IN) :: KPROMA
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTART
    INTEGER(KIND=JPIM), INTENT(IN) :: KPROF
    REAL(KIND=JPRB), INTENT(IN) :: PRPRESS(KPROMA)
    REAL(KIND=JPRB), INTENT(IN) :: POROG(KPROMA)
    REAL(KIND=JPRB), INTENT(IN) :: PTSTAR(KPROMA)
    REAL(KIND=JPRB), INTENT(IN) :: PT0(KPROMA)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMSLPPP(KPROMA)
    LOGICAL, OPTIONAL, INTENT(IN) :: LDQNH
    REAL(KIND=JPRB) :: ZTSTAR(KPROMA)
    REAL(KIND=JPRB) :: ZALPHA(KPROMA)
    INTEGER(KIND=JPIM) :: JL
    REAL(KIND=JPRB) :: ZDTDZSG, ZOROG, ZT0, ZTX, ZTY, ZX, ZY, ZY2

    LOGICAL :: LLQNH
    status = 2
    if (KPROMA < 1 .or. KPROMA > 1024 .or. KSTART < 1 .or. KPROF > KPROMA .or. KPROF < KSTART - 1) return
    IF (PRESENT(LDQNH)) THEN
      LLQNH = LDQNH
    ELSE
      LLQNH = .FALSE.
    END IF
    ZTX = 290.5_JPRB
    ZTY = 255.0_JPRB
    ZDTDZSG = -RDTDZ1/RG
    IF (LLQNH) THEN
      ZT0 = 288.15_JPRB
      DO JL = KSTART, KPROF
        ZTSTAR(JL) = ZT0 + (-ZDTDZSG)*POROG(JL)
        ZOROG = SIGN(MAX(1.0_JPRB, ABS(POROG(JL))), POROG(JL))
        ZALPHA(JL) = RD*(ZT0 - ZTSTAR(JL))/ZOROG
      END DO
    ELSE
      DO JL = KSTART, KPROF
        IF (PTSTAR(JL) < ZTY) THEN
          ZTSTAR(JL) = 0.5_JPRB*(ZTY + PTSTAR(JL))
        ELSEIF (PTSTAR(JL) < ZTX) THEN
          ZTSTAR(JL) = PTSTAR(JL)
        ELSE
          ZTSTAR(JL) = 0.5_JPRB*(ZTX + PTSTAR(JL))
        END IF
        ZT0 = ZTSTAR(JL) + ZDTDZSG*POROG(JL)
        IF (ZTX > ZTSTAR(JL) .AND. ZT0 > ZTX) THEN
          ZT0 = ZTX
        ELSEIF (ZTX <= ZTSTAR(JL) .AND. ZT0 > ZTSTAR(JL)) THEN
          ZT0 = ZTSTAR(JL)
        ELSE
          ZT0 = PT0(JL)
        END IF
        ZOROG = SIGN(MAX(1.0_JPRB, ABS(POROG(JL))), POROG(JL))
        ZALPHA(JL) = RD*(ZT0 - ZTSTAR(JL))/ZOROG
      END DO
    END IF
    DO JL = KSTART, KPROF
      IF (ABS(POROG(JL)) >= 0.001_JPRB) THEN
        ZX = POROG(JL)/(RD*ZTSTAR(JL))
        ZY = ZALPHA(JL)*ZX
        ZY2 = ZY*ZY
        PMSLPPP(JL) = PRPRESS(JL)*EXP(ZX*(1.0_JPRB - 0.5_JPRB*ZY + 1.0_JPRB/3._JPRB*ZY2))
      ELSE
        PMSLPPP(JL) = PRPRESS(JL)
      END IF
    END DO
    status = 0
  end function
end module
