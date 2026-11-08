!> Complete cubic coordinate weights and twelve-point field interpolation.
!! The canonical SL owner supplies real halo bounds and integer index maps.
!! Coordinates use radians. All output arrays are INOUT, preserving inactive
!! point ranges and complete-pitch padding. No private byte image is used.
module forecast_native_radiation_interpolation
  use iso_fortran_env, only: int32, real64, int64
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: runtime_radiation_coordinate_weights, runtime_radiation_twelve_point_interpolation
contains
 integer(int32)function runtime_radiation_coordinate_weights(YDSL,KPROMB,KSTART,KPROF,KSTABUF,KWIS,KFRSTLOFF,P4JP,PIS2,PLSDEPI,PLATI,PIPI,PLON,PLAT,PDLAT,PCLA,PDLO,PCLO,KL0)result(status)
  type(native_interpolation_state), intent(inout) :: YDSL
  integer(int32), intent(in) :: KPROMB, KSTART, KPROF, KWIS, KFRSTLOFF
  integer(int32), intent(in) :: KSTABUF(YDSL%NDGSAH:)
  real(real64), intent(in) :: P4JP, PIS2, PLSDEPI(YDSL%NDGSAH:), PLATI(YDSL%NDGSAH:)
  real(real64), intent(in) :: PIPI(YDSL%NDGSAH:, :), PLON(:), PLAT(:)
  real(real64), intent(inout) :: PDLAT(:), PCLA(:, :), PDLO(:, 0:), PCLO(:, :, :)
  integer(int32), intent(inout) :: KL0(:, 0:)
  integer(int32) :: ILA, ILO, ILO1, ILO2, ILO3, IZLAT, JROF
  real(real64) :: PD, ZDA, ZDB, ZDC, ZDD, ZLO, ZLO1, ZLO2, ZLO3, ZEPS
  real(real64) :: FLAG1, FLAG2, FLAG3
  real(real64), parameter :: Z6_R = 1._real64/6._real64
  integer, parameter :: JPRB = real64, JPRD = real64
  FLAG1(PD) = 0.5_real64*(PD + 1._real64)*(PD - 1._real64)*(PD - 2._real64)
  FLAG2(PD) = -0.5_real64*(PD + 1._real64)*PD*(PD - 2._real64)
  FLAG3(PD) = Z6_R*(PD + 1._real64)*PD*(PD - 1._real64)
  status = 2
  if (KPROMB < 1 .or. KPROMB > 32769 .or. KSTART < 1 .or. KPROF < KSTART .or. KPROF > KPROMB .or. KWIS /= 203) return
  if (YDSL%NDGENH < YDSL%NDGSAH .or. int(YDSL%NDGENH, int64) - YDSL%NDGSAH + 1 > 131072) return
  if (.not. allocated(YDSL%NSLEXT)) return
  if (lbound(YDSL%NSLEXT, 2) > YDSL%NDGSAH .or. ubound(YDSL%NSLEXT, 2) < YDSL%NDGENH) return
  if (size(YDSL%NSLEXT, 1) < 1 .or. size(YDSL%NSLEXT, 1) > 131072 .or. size(YDSL%NSLEXT, 2) > 131072) return
  if (ubound(KSTABUF, 1) < YDSL%NDGENH .or. ubound(PLSDEPI, 1) < YDSL%NDGENH .or. ubound(PLATI, 1) < YDSL%NDGENH) return
  if (ubound(PIPI, 1) < YDSL%NDGENH .or. size(PIPI, 2) < 3) return
  if (size(PLON) < KPROMB .or. size(PLAT) < KPROMB .or. size(PDLAT) < KPROMB) return
  if (size(PCLA, 1) < KPROMB .or. size(PCLA, 2) < 3 .or. size(PDLO, 1) < KPROMB .or. ubound(PDLO, 2) < 3) return
  if (size(PCLO, 1) < KPROMB .or. size(PCLO, 2) < 3 .or. size(PCLO, 3) < 2) return
  if (size(KL0, 1) < KPROMB .or. ubound(KL0, 2) < 3) return
  if (YDSL%LSLONDEM .and. .not. YDSL%LSLONDEM_ACTIVE) then
    if (.not. allocated(YDSL%MASK_SL2)) return
  end if
  ZEPS = 100._real64*TINY(1._real64)

!CDIR NODEP
  DO JROF = KSTART, KPROF

    IZLAT = INT(P4JP*(PIS2 - PLAT(JROF)) + 0.75_JPRB + ZEPS) - KFRSTLOFF
    if (IZLAT < YDSL%NDGSAH .or. IZLAT > YDSL%NDGENH) return
    ILA = IZLAT + NINT(SIGN(0.5_JPRB, PLATI(IZLAT) - PLAT(JROF) + ZEPS) - 1.5_JPRB)
    if (ILA < YDSL%NDGSAH .or. ILA + 3 > YDSL%NDGENH) return

    PDLAT(JROF) = (PLAT(JROF) - PLATI(ILA + 1))&
     & /(PLATI(ILA + 2) - PLATI(ILA + 1) + ZEPS)

    ZDA = PLAT(JROF) - PLATI(ILA)
    ZDB = PLAT(JROF) - PLATI(ILA + 1)
    ZDC = PLAT(JROF) - PLATI(ILA + 2)
    ZDD = PLAT(JROF) - PLATI(ILA + 3)

    PCLA(JROF, 1) = REAL((ZDA*ZDC)*ZDD, JPRD)*PIPI(ILA + 1, 1)
    PCLA(JROF, 2) = REAL((ZDA*ZDB)*ZDD, JPRD)*PIPI(ILA + 1, 2)
    PCLA(JROF, 3) = REAL((ZDA*ZDB)*ZDC, JPRD)*PIPI(ILA + 1, 3)

    ZLO = PLON(JROF)*PLSDEPI(ILA)
    ILO = INT(ZLO)
    if (ILO < lbound(YDSL%NSLEXT, 1) .or. ILO > ubound(YDSL%NSLEXT, 1)) return
    PDLO(JROF, 0) = ZLO - REAL(ILO, JPRB)
    ZLO1 = PLON(JROF)*PLSDEPI(ILA + 1)
    ILO1 = INT(ZLO1)
    if (ILO1 < lbound(YDSL%NSLEXT, 1) .or. ILO1 > ubound(YDSL%NSLEXT, 1)) return
    PDLO(JROF, 1) = ZLO1 - REAL(ILO1, JPRB)
    ZLO2 = PLON(JROF)*PLSDEPI(ILA + 2)
    ILO2 = INT(ZLO2)
    if (ILO2 < lbound(YDSL%NSLEXT, 1) .or. ILO2 > ubound(YDSL%NSLEXT, 1)) return
    PDLO(JROF, 2) = ZLO2 - REAL(ILO2, JPRB)
    ZLO3 = PLON(JROF)*PLSDEPI(ILA + 3)
    ILO3 = INT(ZLO3)
    if (ILO3 < lbound(YDSL%NSLEXT, 1) .or. ILO3 > ubound(YDSL%NSLEXT, 1)) return
    PDLO(JROF, 3) = ZLO3 - REAL(ILO3, JPRB)

    PCLO(JROF, 1, 1) = FLAG1(PDLO(JROF, 1))
    PCLO(JROF, 2, 1) = FLAG2(PDLO(JROF, 1))
    PCLO(JROF, 3, 1) = FLAG3(PDLO(JROF, 1))
    PCLO(JROF, 1, 2) = FLAG1(PDLO(JROF, 2))
    PCLO(JROF, 2, 2) = FLAG2(PDLO(JROF, 2))
    PCLO(JROF, 3, 2) = FLAG3(PDLO(JROF, 2))

    KL0(JROF, 0) = KSTABUF(ILA) + YDSL%NSLEXT(ILO, ILA)
    KL0(JROF, 1) = KSTABUF(ILA + 1) + YDSL%NSLEXT(ILO1, ILA + 1)
    KL0(JROF, 2) = KSTABUF(ILA + 2) + YDSL%NSLEXT(ILO2, ILA + 2)
    KL0(JROF, 3) = KSTABUF(ILA + 3) + YDSL%NSLEXT(ILO3, ILA + 3)

    IF (YDSL%LSLONDEM .AND. .NOT. YDSL%LSLONDEM_ACTIVE) THEN
      if (minval(KL0(JROF, 0:3)) < lbound(YDSL%MASK_SL2, 1)) return
      if (int(maxval(KL0(JROF, 0:3)), int64) + 3 > ubound(YDSL%MASK_SL2, 1)) return
      YDSL%MASK_SL2(KL0(JROF, 0)) = 1
      YDSL%MASK_SL2(KL0(JROF, 0) + 1) = 1
      YDSL%MASK_SL2(KL0(JROF, 0) + 2) = 1
      YDSL%MASK_SL2(KL0(JROF, 0) + 3) = 1
      YDSL%MASK_SL2(KL0(JROF, 1)) = 1
      YDSL%MASK_SL2(KL0(JROF, 1) + 1) = 1
      YDSL%MASK_SL2(KL0(JROF, 1) + 2) = 1
      YDSL%MASK_SL2(KL0(JROF, 1) + 3) = 1
      YDSL%MASK_SL2(KL0(JROF, 2)) = 1
      YDSL%MASK_SL2(KL0(JROF, 2) + 1) = 1
      YDSL%MASK_SL2(KL0(JROF, 2) + 2) = 1
      YDSL%MASK_SL2(KL0(JROF, 2) + 3) = 1
      YDSL%MASK_SL2(KL0(JROF, 3)) = 1
      YDSL%MASK_SL2(KL0(JROF, 3) + 1) = 1
      YDSL%MASK_SL2(KL0(JROF, 3) + 2) = 1
      YDSL%MASK_SL2(KL0(JROF, 3) + 3) = 1
    END IF

  END DO

  status = 0
  end function
  !> Interpolate each field from twelve consumed neighbours of a 4x4 table.
 !! Unused corner indices remain opaque. Zero fields read no payload.
  integer(int32)function runtime_radiation_twelve_point_interpolation(KPROMA,KFIELDS,PCLA,PDLO,PCLO,KL0,PRE,POST)result(status)
  integer(int32), intent(in) :: KPROMA, KFIELDS
  real(real64), intent(in) :: PCLA(:), PDLO(0:), PCLO(:, :), PRE(:, :)
  integer(int32), intent(in) :: KL0(0:, 0:)
  real(real64), intent(inout) :: POST(:)
  integer :: f, a, b, c, d, i, j
  real(real64) :: z0, z1, z2, z3, x, t
  status = 2
  if (KPROMA < 1 .or. int(KPROMA, int64) > 268435456_int64 .or. KFIELDS < 0 .or. KFIELDS > 16384) return
  if (KFIELDS == 0) then; status = 0; return; end if
  if (size(PCLA) < 3 .or. ubound(PDLO, 1) < 3 .or. size(PCLO, 1) < 3 .or. size(PCLO, 2) < 2) return
  if(ubound(KL0,1)<3.or.ubound(KL0,2)<3.or.size(PRE,1)<KPROMA.or.size(PRE,2)<KFIELDS.or.size(POST)<KFIELDS)return
  do i = 0, 3
    do j = 0, 3
      if ((i == 0 .or. i == 3) .and. (j == 0 .or. j == 3)) cycle
      if (KL0(i, j) < 1 .or. KL0(i, j) > KPROMA) return
    end do
  end do
  do f = 1, KFIELDS
    a = KL0(0, 1); b = KL0(0, 2)
    x = PRE(b, f) - PRE(a, f); x = PDLO(0)*x; z0 = PRE(a, f) + x
    a = KL0(1, 0); b = KL0(1, 1); c = KL0(1, 2); d = KL0(1, 3)
    x = PRE(b, f) - PRE(a, f); x = PCLO(1, 1)*x; z1 = PRE(a, f) + x
    x = PRE(c, f) - PRE(a, f); x = PCLO(2, 1)*x; z1 = z1 + x
    x = PRE(d, f) - PRE(a, f); x = PCLO(3, 1)*x; z1 = z1 + x
    a = KL0(2, 0); b = KL0(2, 1); c = KL0(2, 2); d = KL0(2, 3)
    x = PRE(b, f) - PRE(a, f); x = PCLO(1, 2)*x; z2 = PRE(a, f) + x
    x = PRE(c, f) - PRE(a, f); x = PCLO(2, 2)*x; z2 = z2 + x
    x = PRE(d, f) - PRE(a, f); x = PCLO(3, 2)*x; z2 = z2 + x
    a = KL0(3, 1); b = KL0(3, 2)
    x = PRE(b, f) - PRE(a, f); x = PDLO(3)*x; z3 = PRE(a, f) + x
    x = z1 - z0; x = PCLA(1)*x; t = z0 + x
    x = z2 - z0; x = PCLA(2)*x; t = t + x
    x = z3 - z0; x = PCLA(3)*x; POST(f) = t + x
  end do
  status = 0
end function
end module
