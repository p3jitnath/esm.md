!> Native calendar update and borrowed sea-ice coupling fields.
!! Source date rules and day order are retained, including negative increments.
!! Scientific source attribution: ECMWF, Meteo-France UPDCAL/ICESTATENEMO.
module native_radiation_calendar_and_ice
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int32, real64, int64
  use yomhook, only: lhook, dr_hook, jphook
  implicit none
  private
  public :: updcal, icestatenemo, native_sea_ice_state
  type :: native_sea_ice_state
    logical :: coupled = .false.
    real(real64), pointer :: ice_thickness(:) => null(), snow_thickness(:) => null(), ice_albedo(:) => null()
    real(real64), pointer :: sea_temperature(:) => null(), ice_temperature(:) => null()
  end type
contains
!> Update native day, month, year and twelve month lengths in source order.
!! KINC is a signed day count; KULOUT<0 suppresses the optional date line.
  SUBROUTINE UPDCAL(KD0, KM0, KY0, KINC, KD1, KM1, KY1, KLMO, KULOUT)
    INTEGER(KIND=JPIM), INTENT(IN) :: KD0
    INTEGER(KIND=JPIM), INTENT(IN) :: KM0
    INTEGER(KIND=JPIM), INTENT(IN) :: KY0
    INTEGER(KIND=JPIM), INTENT(IN) :: KINC
    INTEGER(KIND=JPIM), INTENT(OUT) :: KD1
    INTEGER(KIND=JPIM), INTENT(OUT) :: KM1
    INTEGER(KIND=JPIM), INTENT(OUT) :: KY1
    INTEGER(KIND=JPIM), INTENT(OUT) :: KLMO(12)
    INTEGER(KIND=JPIM), INTENT(IN) :: KULOUT
    INTEGER(KIND=JPIM) :: JD, JM
    REAL(KIND=JPHOOK) :: ZHOOK_HANDLE
    IF (LHOOK) CALL DR_HOOK('UPDCAL', 0, ZHOOK_HANDLE)
    DO JM = 1, 12
      KLMO(JM) = 31
      IF (JM == 4 .OR. JM == 6 .OR. JM == 9 .OR. JM == 11) KLMO(JM) = 30
      IF (JM == 2) THEN
      IF (MOD(KY0, 4) == 0 .AND. MOD(KY0, 400) /= 100 .AND. MOD(KY0, 400) /= 200 .AND. MOD(KY0, 400) /= 300) THEN
        KLMO(JM) = 29
      ELSE
        KLMO(JM) = 28
      END IF
      END IF
    END DO
    KD1 = KD0
    KM1 = KM0
    KY1 = KY0
    IF (KINC >= 0) THEN
    DO JD = 1, KINC
      KD1 = KD1 + 1
      IF (KD1 <= KLMO(KM1)) CYCLE
      KD1 = 1
      KM1 = KM1 + 1
      IF (KM1 <= 12) CYCLE
      KM1 = 1
      KY1 = KY1 + 1
      KLMO(2) = 28
      IF (MOD(KY1, 4) == 0 .AND. MOD(KY1, 400) /= 100 .AND. MOD(KY1, 400) /= 200 .AND. MOD(KY1, 400) /= 300) KLMO(2) = 29
    END DO
    ELSE
    DO JD = 1, -KINC
      KD1 = KD1 - 1
      IF (KD1 > 0) CYCLE
      KM1 = 1 + MOD(KM1 + 10, 12)
      KLMO(2) = 28
      IF (MOD(KY1, 4) == 0 .AND. MOD(KY1, 400) /= 100 .AND. MOD(KY1, 400) /= 200 .AND. MOD(KY1, 400) /= 300) KLMO(2) = 29
      KD1 = KLMO(KM1)
      IF (KM1 == 12) KY1 = KY1 - 1
    END DO
    END IF
    IF (KULOUT >= 0) WRITE (KULOUT, '("  DATE=",3I5)') KY1, KM1, KD1
    IF (LHOOK) CALL DR_HOOK('UPDCAL', 1, ZHOOK_HANDLE)
  END SUBROUTINE UPDCAL

!> Read optional active sea-ice fields from explicit coupled vectors.
!! Global first cell plus local first:last select one contiguous input span.
!! Thickness uses metres, albedo is dimensionless and temperature uses kelvin.
!! An inactive coupling reads and writes no numerical owner.
  subroutine icestatenemo(coupling,global_first,first,last,ice_thickness,snow_thickness,albedo,sea_temperature,ice_temperature)
    type(native_sea_ice_state), intent(in) :: coupling
    integer(int32), intent(in) :: global_first, first, last
    real(real64), optional, intent(inout) :: ice_thickness(first:last), snow_thickness(first:last), albedo(first:last)
    real(real64), optional, intent(inout) :: sea_temperature(first:last), ice_temperature(first:last)
    integer(int64) :: begin, finish
    real(jphook) :: hook
    if (lhook) call dr_hook('ICESTATENEMO', 0, hook)
    if (coupling%coupled .and. first <= last) then
      begin = int(global_first, int64) - 1 + first
      finish = int(global_first, int64) - 1 + last
      if (begin < 1) error stop "ICESTATENEMO: unsupported source range"
      if (present(ice_thickness)) call require_vector(coupling%ice_thickness, begin, finish)
      if (present(snow_thickness)) call require_vector(coupling%snow_thickness, begin, finish)
      if (present(albedo)) call require_vector(coupling%ice_albedo, begin, finish)
      if (present(sea_temperature)) call require_vector(coupling%sea_temperature, begin, finish)
      if (present(ice_temperature)) call require_vector(coupling%ice_temperature, begin, finish)
      if (present(ice_thickness)) ice_thickness(:) = coupling%ice_thickness(begin:finish)
      if (present(snow_thickness)) snow_thickness(:) = coupling%snow_thickness(begin:finish)
      if (present(albedo)) albedo(:) = coupling%ice_albedo(begin:finish)
      if (present(sea_temperature)) sea_temperature(:) = coupling%sea_temperature(begin:finish)
      if (present(ice_temperature)) ice_temperature(:) = coupling%ice_temperature(begin:finish)
    end if
    if (lhook) call dr_hook('ICESTATENEMO', 1, hook)
  end subroutine
!> Check every requested borrowed source before the first output copy.
  subroutine require_vector(values, first, last)
    real(real64), pointer, intent(in) :: values(:)
    integer(int64), intent(in) :: first, last
    if (.not. associated(values)) error stop "ICESTATENEMO: missing coupled source"
    if (first < lbound(values, 1) .or. last > ubound(values, 1)) error stop "ICESTATENEMO: short coupled source"
  end subroutine
end module
