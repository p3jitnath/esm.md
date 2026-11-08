!> Native solar-angle calculation with explicit physical constants.
!! Model and radiation solar states remain separate native public records.
!! Inputs use sine latitude and radians; output is dimensionless cosine.
!! The strict entry admits one daylight interval; the compatibility entry
!! retains the original neighbouring-day limitation explicitly.
!! Scientific source attribution: ECMWF COS_SZA.
module native_radiation_solar_geometry
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int32, real64
  use ieee_arithmetic, only: ieee_is_finite
  use yoerad, only: TERAD
  use yoerip, only: TERIP
  use yomrip, only: TRIP
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: cos_sza, cos_sza_openifs_source_compatibility
  interface
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains
!> Commit active cosines only after complete single-period admission.
  subroutine cos_sza(constants, radiation, solar, time, first, last, columns, latitude, longitude, radiation_step, output)
    type(forecast_physical_constants), intent(in) :: constants
    type(TERAD), intent(in) :: radiation
    type(TERIP), intent(in) :: solar
    type(TRIP), intent(in) :: time
    integer(int32), intent(in) :: first, last, columns
    real(real64), intent(in) :: latitude(columns), longitude(columns)
    logical, intent(in) :: radiation_step
    real(real64), intent(inout) :: output(columns)
    call cos_sza_core(constants, .true., radiation, solar, time, first, last, columns, latitude, longitude, radiation_step, output)
  end subroutine
!> Preserve the original clipped-day averaging for operational compatibility.
!! This entry has the same native owners and bounds as COS_SZA. A window that
!! meets daylight from two neighbouring periods retains the source limitation.
subroutine cos_sza_openifs_source_compatibility(constants,radiation,solar,time,first,last,columns,latitude,longitude,radiation_step,output)
    type(forecast_physical_constants), intent(in) :: constants
    type(TERAD), intent(in) :: radiation
    type(TERIP), intent(in) :: solar
    type(TRIP), intent(in) :: time
    integer(int32), intent(in) :: first, last, columns
    real(real64), intent(in) :: latitude(columns), longitude(columns)
    logical, intent(in) :: radiation_step
    real(real64), intent(inout) :: output(columns)
    call cos_sza_core(constants, .false., radiation, solar, time, first, last, columns, latitude, longitude, radiation_step, output)
  end subroutine

  SUBROUTINE cos_sza_core(constants,strict_window,YDERAD,YDERIP,YDRIP,KSTART,KEND,KCOL,PGEMU,PGELAM,LDRADIATIONTIMESTEP,PMU0)
    type(forecast_physical_constants), intent(in) :: constants
    logical, intent(in) :: strict_window
    TYPE(TERAD), INTENT(IN) :: YDERAD
    TYPE(TERIP), INTENT(IN) :: YDERIP
    TYPE(TRIP), INTENT(IN) :: YDRIP
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTART
    INTEGER(KIND=JPIM), INTENT(IN) :: KEND
    INTEGER(KIND=JPIM), INTENT(IN) :: KCOL
    REAL(KIND=JPRB), INTENT(IN) :: PGEMU(KCOL)
    REAL(KIND=JPRB), INTENT(IN) :: PGELAM(KCOL)
    LOGICAL, INTENT(IN) :: LDRADIATIONTIMESTEP
    REAL(KIND=JPRB), INTENT(INOUT) :: PMU0(KCOL)
    REAL(KIND=JPRB) :: ZSOLARTIMESTART, ZSOLARTIMEEND
    REAL(KIND=JPRB) :: ZHALFTIMESTEP
    REAL(KIND=JPRB) :: ZSINDECSINLAT(KSTART:KEND)
    REAL(KIND=JPRB) :: ZCOSDECCOSLAT(KSTART:KEND)
    REAL(KIND=JPRB) :: ZCOSLAT(KSTART:KEND)
    REAL(KIND=JPRB) :: ZTANDEC
    REAL(KIND=JPRB) :: ZHOURANGLESTART, ZHOURANGLEEND
    REAL(KIND=JPRB) :: ZHOURANGLESUNSET, ZCOSHOURANGLESUNSET
    INTEGER(KIND=JPIM) :: JCOL
    real(JPRB) :: working(KCOL)
    if (KCOL < 1 .or. KCOL > 4096 .or. KSTART < 1 .or. KEND > KCOL) call public_abort()
    if (KSTART > KEND) return
    if (any(.not. ieee_is_finite(PGEMU(KSTART:KEND))) .or. any(abs(PGEMU(KSTART:KEND)) > 1.0_JPRB)) call public_abort()
if(any(.not.ieee_is_finite(PGELAM(KSTART:KEND))).or.any(PGELAM(KSTART:KEND)<0.0_JPRB).or.any(PGELAM(KSTART:KEND)>2.0_JPRB*constants%rpi))call public_abort()
    if (YDERAD%LAVERAGESZA) then
      if (.not. YDERAD%LCENTREDTIMESZA .or. YDRIP%TSTEP <= 0.0_JPRB) call public_abort()
      if (LDRADIATIONTIMESTEP .and. YDERAD%NRADFR <= 0) call public_abort()
    end if
    IF (YDERAD%LAVERAGESZA .AND. .NOT. YDERAD%LCENTREDTIMESZA) THEN
      call public_abort()
    END IF
    DO JCOL = KSTART, KEND
      ZCOSLAT(JCOL) = SQRT(1.0_JPRB - PGEMU(JCOL)**2)
    END DO
    IF (LDRADIATIONTIMESTEP) THEN
    DO JCOL = KSTART, KEND
      ZSINDECSINLAT(JCOL) = YDERIP%RSIDECM*PGEMU(JCOL)
      ZCOSDECCOSLAT(JCOL) = YDERIP%RCODECM*ZCOSLAT(JCOL)
    END DO
    IF (.NOT. YDERAD%LAVERAGESZA) THEN
    DO JCOL = KSTART, KEND
working(JCOL) = MAX(0.0_JPRB, ZSINDECSINLAT(JCOL) - YDERIP%RCODECM*COS(YDERIP%RWSOVRM)*ZCOSLAT(JCOL)*COS(PGELAM(JCOL)) + YDERIP%RCODECM*SIN(YDERIP%RWSOVRM)*ZCOSLAT(JCOL)*SIN(PGELAM(JCOL)))
    END DO
    ELSE
    ZHALFTIMESTEP = YDRIP%TSTEP*REAL(YDERAD%NRADFR)*constants%rpi/constants%rday
    ZSOLARTIMESTART = YDERIP%RWSOVRM - ZHALFTIMESTEP
    ZSOLARTIMEEND = YDERIP%RWSOVRM + ZHALFTIMESTEP
    ZTANDEC = YDERIP%RSIDECM/MAX(YDERIP%RCODECM, 1.0E-12_JPRB)
    DO JCOL = KSTART, KEND
      ZCOSHOURANGLESUNSET = -ZTANDEC*PGEMU(JCOL)/MAX(ZCOSLAT(JCOL), 1.0E-12_JPRB)
      IF (ZCOSHOURANGLESUNSET > 1.0) THEN
        working(JCOL) = 0.0_JPRB
      ELSE
        IF (YDERIP%RWSOVRM + PGELAM(JCOL) < 2.0_JPRB*constants%rpi) THEN
          ZHOURANGLESTART = ZSOLARTIMESTART + PGELAM(JCOL) - constants%rpi
          ZHOURANGLEEND = ZSOLARTIMEEND + PGELAM(JCOL) - constants%rpi
        ELSE
          ZHOURANGLESTART = ZSOLARTIMESTART + PGELAM(JCOL) - 3.0_JPRB*constants%rpi
          ZHOURANGLEEND = ZSOLARTIMEEND + PGELAM(JCOL) - 3.0_JPRB*constants%rpi
        END IF
        IF (ZCOSHOURANGLESUNSET >= -1.0) THEN
          ZHOURANGLESUNSET = ACOS(ZCOSHOURANGLESUNSET)
          if (strict_window) then
            if (ZHOURANGLESTART < ZHOURANGLESUNSET - 2.0_JPRB*constants%rpi .or. &
                ZHOURANGLEEND > 2.0_JPRB*constants%rpi - ZHOURANGLESUNSET) call public_abort()
          end if
          IF (ZHOURANGLEEND <= -ZHOURANGLESUNSET .OR. ZHOURANGLESTART >= ZHOURANGLESUNSET) THEN
            working(JCOL) = 0.0_JPRB
            CYCLE
          END IF
          ZHOURANGLESTART = MAX(-ZHOURANGLESUNSET, MIN(ZHOURANGLESTART, ZHOURANGLESUNSET))
          ZHOURANGLEEND = MAX(-ZHOURANGLESUNSET, MIN(ZHOURANGLEEND, ZHOURANGLESUNSET))
        END IF
        IF (ZHOURANGLEEND - ZHOURANGLESTART > 1.0E-8) THEN
working(JCOL) = ZSINDECSINLAT(JCOL) + (ZCOSDECCOSLAT(JCOL) * (SIN(ZHOURANGLEEND) - SIN(ZHOURANGLESTART))) / (ZHOURANGLEEND - ZHOURANGLESTART)
          IF (working(JCOL) < 0.0_JPRB) THEN
            working(JCOL) = 0.0_JPRB
          END IF
        ELSE
          working(JCOL) = 0.0_JPRB
        END IF
      END IF
    END DO
    END IF
    ELSE
    DO JCOL = KSTART, KEND
      ZSINDECSINLAT(JCOL) = YDRIP%RSIDEC*PGEMU(JCOL)
      ZCOSDECCOSLAT(JCOL) = YDRIP%RCODEC*ZCOSLAT(JCOL)
    END DO
    IF (.NOT. YDERAD%LAVERAGESZA) THEN
    DO JCOL = KSTART, KEND
working(JCOL) = MAX(0.0_JPRB, ZSINDECSINLAT(JCOL) - YDRIP%RCODEC*COS(YDRIP%RWSOVR)*ZCOSLAT(JCOL)*COS(PGELAM(JCOL)) + YDRIP%RCODEC*SIN(YDRIP%RWSOVR)*ZCOSLAT(JCOL)*SIN(PGELAM(JCOL)))
    END DO
    ELSE
    ZHALFTIMESTEP = YDRIP%TSTEP*constants%rpi/constants%rday
    ZSOLARTIMESTART = YDRIP%RWSOVR - ZHALFTIMESTEP
    ZSOLARTIMEEND = YDRIP%RWSOVR + ZHALFTIMESTEP
    ZTANDEC = YDRIP%RSIDEC/MAX(YDRIP%RCODEC, 1.0E-12_JPRB)
    DO JCOL = KSTART, KEND
      ZCOSHOURANGLESUNSET = -ZTANDEC*PGEMU(JCOL)/MAX(ZCOSLAT(JCOL), 1.0E-12_JPRB)
      IF (ZCOSHOURANGLESUNSET > 1.0) THEN
        working(JCOL) = 0.0_JPRB
      ELSE
        IF (YDRIP%RWSOVR + PGELAM(JCOL) < 2.0_JPRB*constants%rpi) THEN
          ZHOURANGLESTART = ZSOLARTIMESTART + PGELAM(JCOL) - constants%rpi
          ZHOURANGLEEND = ZSOLARTIMEEND + PGELAM(JCOL) - constants%rpi
        ELSE
          ZHOURANGLESTART = ZSOLARTIMESTART + PGELAM(JCOL) - 3.0_JPRB*constants%rpi
          ZHOURANGLEEND = ZSOLARTIMEEND + PGELAM(JCOL) - 3.0_JPRB*constants%rpi
        END IF
        IF (ZCOSHOURANGLESUNSET >= -1.0) THEN
          ZHOURANGLESUNSET = ACOS(ZCOSHOURANGLESUNSET)
          if (strict_window) then
            if (ZHOURANGLESTART < ZHOURANGLESUNSET - 2.0_JPRB*constants%rpi .or. &
                ZHOURANGLEEND > 2.0_JPRB*constants%rpi - ZHOURANGLESUNSET) call public_abort()
          end if
          IF (ZHOURANGLEEND <= -ZHOURANGLESUNSET .OR. ZHOURANGLESTART >= ZHOURANGLESUNSET) THEN
            working(JCOL) = 0.0_JPRB
            CYCLE
          END IF
          ZHOURANGLESTART = MAX(-ZHOURANGLESUNSET, MIN(ZHOURANGLESTART, ZHOURANGLESUNSET))
          ZHOURANGLEEND = MAX(-ZHOURANGLESUNSET, MIN(ZHOURANGLEEND, ZHOURANGLESUNSET))
        END IF
working(JCOL) = (ZSINDECSINLAT(JCOL) * (ZHOURANGLEEND-ZHOURANGLESTART) + ZCOSDECCOSLAT(JCOL)*(SIN(ZHOURANGLEEND)-SIN(ZHOURANGLESTART))) / (2.0_JPRB * ZHALFTIMESTEP)
        IF (working(JCOL) < 0.0_JPRB) THEN
          working(JCOL) = 0.0_JPRB
        END IF
      END IF
    END DO
    END IF
    END IF
    PMU0(KSTART:KEND) = working(KSTART:KEND)
  end subroutine
end module
