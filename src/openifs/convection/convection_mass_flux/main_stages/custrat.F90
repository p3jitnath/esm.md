! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!> Complete ordered CUSTRAT calculation on native arrays.
!! Derived from the frozen generated source equations. The caller establishes
!! nearest-even rounding, gradual underflow, finite physical inputs and
!! disjoint writable/read-only owners. Pressure is Pa, temperature K, humidity
!! kg/kg and geopotential m**2/s**2. All writable owners retain inactive bytes.
!! ECMWF's original interface reference is Apache-2.0 licensed; numerical
!! dependencies are owned native procedures, not original model calculations.
module convection_parcel_diffusion_mod
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convective_saturation_adjustment_mod, only: cuadjtq
  USE YOEPHLI, ONLY: TEPHLI
  implicit none
  private
  public :: custrat
contains
  !> Return0 after the complete source update,1 for a native resource failure,
  !! or2 before mutation for unsupported metadata. KLON is the exact leading
  !! extent, KLEV is3:1024, and only KIDIA:KFDIA cells are selected.
  !! The compiler owns automatic scratch on the stack within a one-MiB bound.
  integer(JPIM) function custrat(constants,thermal,YDEPHLI,KIDIA,KFDIA,KLON,KLEV,LDCUM,PTSPHY,PVDIFTS,PAP,PAPH,PGEO,PTEN,PQEN,PQSAT,PENTH,PTENT,PTENQ) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    TYPE(TEPHLI), INTENT(INOUT) :: YDEPHLI
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    LOGICAL, INTENT(IN) :: LDCUM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSPHY
    REAL(KIND=JPRB), INTENT(IN) :: PVDIFTS
    REAL(KIND=JPRB), INTENT(IN) :: PAP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQSAT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PENTH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENQ(:, :)
    status = 2_JPIM
    if (KLON < 0 .or. KLON > 4096 .or. KLEV < 3 .or. KLEV > 1024) return
    if (KIDIA < 1 .or. KIDIA > KLON + 1 .or. KFDIA < 0 .or. KFDIA > KLON) return
    if (YDEPHLI%LPHYLIN) return

    if (76_int64*int(KLON, int64)*int(KLEV, int64) + 72_int64*KLON > 1048576_int64) return
    if (.not. is_contiguous(LDCUM)) return
    if (size(LDCUM, 1) /= KLON) return
    if (.not. is_contiguous(PAP)) return
    if (size(PAP, 1) /= KLON) return
    if (size(PAP, 2) < KLEV) return
    if (.not. is_contiguous(PAPH)) return
    if (size(PAPH, 1) /= KLON) return
    if (size(PAPH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PGEO)) return
    if (size(PGEO, 1) /= KLON) return
    if (size(PGEO, 2) < KLEV) return
    if (.not. is_contiguous(PTEN)) return
    if (size(PTEN, 1) /= KLON) return
    if (size(PTEN, 2) < KLEV) return
    if (.not. is_contiguous(PQEN)) return
    if (size(PQEN, 1) /= KLON) return
    if (size(PQEN, 2) < KLEV) return
    if (.not. is_contiguous(PQSAT)) return
    if (size(PQSAT, 1) /= KLON) return
    if (size(PQSAT, 2) < KLEV) return
    if (.not. is_contiguous(PENTH)) return
    if (size(PENTH, 1) /= KLON) return
    if (size(PENTH, 2) < KLEV) return
    if (.not. is_contiguous(PTENT)) return
    if (size(PTENT, 1) /= KLON) return
    if (size(PTENT, 2) < KLEV) return
    if (.not. is_contiguous(PTENQ)) return
    if (size(PTENQ, 1) /= KLON) return
    if (size(PTENQ, 2) < KLEV) return
    status=custrat_body(constants,thermal,YDEPHLI,KIDIA,KFDIA,KLON,KLEV,LDCUM(1:KLON),PTSPHY,PVDIFTS,PAP(1:KLON,1:KLEV),PAPH(1:KLON,1:KLEV+1),PGEO(1:KLON,1:KLEV),PTEN(1:KLON,1:KLEV),PQEN(1:KLON,1:KLEV),PQSAT(1:KLON,1:KLEV),PENTH(1:KLON,1:KLEV),PTENT(1:KLON,1:KLEV),PTENQ(1:KLON,1:KLEV))
  end function custrat

  integer(JPIM) function custrat_body(constants,thermal,YDEPHLI,KIDIA,KFDIA,KLON,KLEV,LDCUM,PTSPHY,PVDIFTS,PAP,PAPH,PGEO,PTEN,PQEN,PQSAT,PENTH,PTENT,PTENQ) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    TYPE(TEPHLI), INTENT(INOUT) :: YDEPHLI
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    LOGICAL, INTENT(IN) :: LDCUM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSPHY
    REAL(KIND=JPRB), INTENT(IN) :: PVDIFTS
    REAL(KIND=JPRB), INTENT(IN) :: PAP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQSAT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PENTH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENQ(:, :)
    REAL(KIND=JPRB) ::     ZTC(KLON,KLEV),         ZQC(KLON,KLEV), ZCF(KLON,KLEV),         ZCPTGZ(KLON,KLEV), ZTDIF(KLON,KLEV),       ZQDIF(KLON,KLEV), ZCPTS(KLON),            ZQS(KLON), ZEBS(KLON,KLEV),        ZTCOE(KLON), ZAP(KLON,KLEV+1),       ZQOLD(KLON)
    REAL(KIND=JPRB) :: ZPP(KLON)
    INTEGER(KIND=JPIM) :: ILAB(KLON, KLEV)
    LOGICAL :: LLFLAG(KLON), LLO2(KLON), LLBL(KLON)
    INTEGER(KIND=JPIM) :: ICALL, IK, ILEVH, JK, JL
    REAL(KIND=JPRB) :: ZBUO, ZCONS1, ZCONS2, ZCONS3, ZDISC, ZDQDT, ZDTDT, ZFAC, ZKDIFF1, ZKDIFF2, ZQDP, ZTMST, ZTPFAC1, ZTPFAC2
    integer(JPIM) :: native_child_status
    status = 0_JPIM
    ZTPFAC1 = PVDIFTS
    ZTPFAC2 = 1.0_JPRB/ZTPFAC1
    ZKDIFF1 = 10._JPRB
    ZKDIFF2 = 2.5_JPRB
    ZTMST = PTSPHY
    ZCONS1 = ZTPFAC1*ZTMST*constants%rg**2/(0.5_JPRB*constants%rd)
    ZCONS2 = 1.0_JPRB/ZTMST
    ZCONS3 = ZTMST*constants%rcpd
    ILEVH = KLEV/2
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZCPTGZ(JL, JK) = PGEO(JL, JK) + PTEN(JL, JK)*constants%rcpd
      ZCF(JL, JK) = 0.0_JPRB
      ILAB(JL, JK) = 0
    END DO
    END DO
    DO JL = KIDIA, KFDIA
      ZTC(JL, KLEV) = PTEN(JL, KLEV) + 0.25_JPRB
      ZQC(JL, KLEV) = PQEN(JL, KLEV)
      IF (.NOT. LDCUM(JL)) THEN
        ILAB(JL, KLEV) = 1
      ELSE
        ILAB(JL, KLEV) = 0
      END IF
      LLO2(JL) = .FALSE.
      LLBL(JL) = .TRUE.
    END DO
    DO JK = KLEV - 1, ILEVH, -1
    DO JL = KIDIA, KFDIA
      IF (PAP(JL, JK) < 0.9_JPRB*PAPH(JL, KLEV + 1)) LLBL(JL) = .FALSE.
    END DO
    DO JL = KIDIA, KFDIA
    IF (LLBL(JL)) THEN
      ZTC(JL, JK) = (ZTC(JL, JK + 1)*constants%rcpd + PGEO(JL, JK + 1) - PGEO(JL, JK))/constants%rcpd
      ZQC(JL, JK) = ZQC(JL, JK + 1)
      IF (ILAB(JL, JK + 1) > 0) THEN
        LLFLAG(JL) = .TRUE.
      ELSE
        LLFLAG(JL) = .FALSE.
      END IF
      ZAP(JL, JK) = PAP(JL, JK)
      ZPP(JL) = PAP(JL, JK)
      ZQOLD(JL) = ZQC(JL, JK)
    END IF
    END DO
    DO JL = KIDIA, KFDIA
      IF (.NOT. LLBL(JL)) LLFLAG(JL) = .FALSE.
    END DO
    IK = JK
    ICALL = 1
    native_child_status = cuadjtq(constants, thermal, YDEPHLI, KIDIA, KFDIA, KLON, KLEV, IK, ZPP, ZTC, ZQC, LLFLAG, ICALL)
    if (native_child_status /= 0) then
      status = native_child_status
      return
    end if
    DO JL = KIDIA, KFDIA
    IF (LLBL(JL)) THEN
    IF (ZQC(JL, JK) /= ZQOLD(JL)) THEN
      ILAB(JL, JK) = 2
    END IF
    END IF
    END DO
    DO JL = KIDIA, KFDIA
    IF (LLBL(JL)) THEN
      ZBUO = ZTC(JL, JK)*(1.0_JPRB + constants%retv*ZQC(JL, JK)) - PTEN(JL, JK)*(1.0_JPRB + constants%retv*PQEN(JL, JK))
      IF (ZBUO < 0.0_JPRB) ILAB(JL, JK) = 0
      IF (ZBUO > 0.0_JPRB .AND. ILAB(JL, JK) == 0 .AND. ILAB(JL, JK + 1) == 1) ILAB(JL, JK) = 1
      IF (ILAB(JL, JK) == 2) LLO2(JL) = .TRUE.
    END IF
    END DO
    END DO
    DO JL = KIDIA, KFDIA
      LLBL(JL) = .TRUE.
    END DO
    DO JK = KLEV - 1, ILEVH, -1
    DO JL = KIDIA, KFDIA
      IF (PAP(JL, JK) < 0.9_JPRB*PAPH(JL, KLEV + 1)) LLBL(JL) = .FALSE.
    END DO
    DO JL = KIDIA, KFDIA
    IF (LLBL(JL)) THEN
    IF (ILAB(JL, JK) == 2) THEN
      ZCF(JL, JK) = ZKDIFF1
      IF (ILAB(JL, KLEV - 2) == 0) THEN
        ZCF(JL, JK) = ZKDIFF2
      END IF
    ELSE
      ZCF(JL, JK) = 0.0_JPRB
    END IF
    IF (ZCF(JL, JK + 1) > 0.0_JPRB .AND. ILAB(JL, JK) == 0) THEN
    ZCF(JL,JK)=ZCF(JL,JK+1)*5._JPRB* MAX(PQEN(JL,JK+1)/PQSAT(JL,JK+1)-0.8_JPRB,0.0_JPRB)* MAX(PQEN(JL,JK+1)/PQSAT(JL,JK+1)-PQEN(JL,JK)/ PQSAT(JL,JK),0.0_JPRB)
      LLBL(JL) = .FALSE.
    END IF
    END IF
    END DO
    END DO
    DO JK = ILEVH, KLEV - 1
    DO JL = KIDIA, KFDIA
      ZCF(JL, JK) = ZCF(JL, JK)*ZCONS1*PAPH(JL, JK + 1)/((PGEO(JL, JK) - PGEO(JL, JK + 1))*(PTEN(JL, JK) + PTEN(JL, JK + 1)))
    END DO
    END DO
    DO JL = KIDIA, KFDIA
      ZCPTS(JL) = ZTPFAC2*ZCPTGZ(JL, KLEV)
      ZQS(JL) = ZTPFAC2*PQEN(JL, KLEV)
    END DO
    DO JK = ILEVH, KLEV
    DO JL = KIDIA, KFDIA
      ZTDIF(JL, JK) = ZTPFAC2*ZCPTGZ(JL, JK)
      ZQDIF(JL, JK) = ZTPFAC2*PQEN(JL, JK)
    END DO
    END DO
    DO JL = KIDIA, KFDIA
      ZTCOE(JL) = ZCF(JL, ILEVH)
      ZQDP = 1.0_JPRB/(PAPH(JL, ILEVH + 1) - PAPH(JL, ILEVH))
      ZDISC = 1.0_JPRB/(1.0_JPRB + ZCF(JL, ILEVH)*ZQDP)
      ZEBS(JL, ILEVH) = ZDISC*(ZCF(JL, ILEVH)*ZQDP)
      ZQDIF(JL, ILEVH) = ZDISC*ZQDIF(JL, ILEVH)
      ZTDIF(JL, ILEVH) = ZDISC*ZTDIF(JL, ILEVH)
    END DO
    DO JK = ILEVH + 1, KLEV
    DO JL = KIDIA, KFDIA
      ZQDP = 1.0_JPRB/(PAPH(JL, JK + 1) - PAPH(JL, JK))
      ZFAC = ZTCOE(JL)*ZQDP
      ZTCOE(JL) = ZCF(JL, JK)
      ZDISC = 1.0_JPRB/(1.0_JPRB + ZFAC*(1.0_JPRB - ZEBS(JL, JK - 1)) + ZCF(JL, JK)*ZQDP)
      ZEBS(JL, JK) = ZDISC*(ZCF(JL, JK)*ZQDP)
      ZQDIF(JL, JK) = ZDISC*(ZQDIF(JL, JK) + ZFAC*ZQDIF(JL, JK - 1))
      ZTDIF(JL, JK) = ZDISC*(ZTDIF(JL, JK) + ZFAC*ZTDIF(JL, JK - 1))
    END DO
    END DO
    DO JL = KIDIA, KFDIA
      ZQDIF(JL, KLEV) = ZQDIF(JL, KLEV) + (ZEBS(JL, KLEV)*ZQS(JL))
      ZTDIF(JL, KLEV) = ZTDIF(JL, KLEV) + (ZEBS(JL, KLEV)*ZCPTS(JL))
    END DO
    DO JK = KLEV - 1, ILEVH, -1
    DO JL = KIDIA, KFDIA
      ZQDIF(JL, JK) = ZQDIF(JL, JK) + (ZEBS(JL, JK)*ZQDIF(JL, JK + 1))
      ZTDIF(JL, JK) = ZTDIF(JL, JK) + (ZEBS(JL, JK)*ZTDIF(JL, JK + 1))
    END DO
    END DO
    DO JK = ILEVH, KLEV
    DO JL = KIDIA, KFDIA
      ZDQDT = (ZQDIF(JL, JK) - ZTPFAC2*PQEN(JL, JK))*ZCONS2
      PTENQ(JL, JK) = PTENQ(JL, JK) + ZDQDT
      ZDTDT = (ZTDIF(JL, JK) - ZTPFAC2*ZCPTGZ(JL, JK))/ZCONS3
      PTENT(JL, JK) = PTENT(JL, JK) + ZDTDT
      PENTH(JL, JK) = (ZTDIF(JL, JK) - ZTPFAC2*ZCPTGZ(JL, JK))*ZCONS2
    END DO
    END DO
700 CONTINUE
  end function custrat_body
end module convection_parcel_diffusion_mod
