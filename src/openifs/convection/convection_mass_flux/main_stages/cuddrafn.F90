! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!> Complete ordered CUDDRAFN calculation on native arrays.
!! Derived from the frozen generated source equations. The caller establishes
!! nearest-even rounding, gradual underflow, finite physical inputs and
!! disjoint writable/read-only owners. Pressure is Pa, temperature K, humidity
!! kg/kg and geopotential m**2/s**2. All writable owners retain inactive bytes.
!! ECMWF's original interface reference is Apache-2.0 licensed; numerical
!! dependencies are owned native procedures, not original model calculations.
module convection_downdraft_descent_mod
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convective_saturation_adjustment_mod, only: cuadjtq
  USE YOEPHLI, ONLY: TEPHLI
  USE YOECUMF, ONLY: TECUMF
  implicit none
  private
  public :: cuddrafn
contains
  !> Return0 after the complete source update,1 for a native resource failure,
  !! or2 before mutation for unsupported metadata. KLON is the exact leading
  !! extent, KLEV is3:1024, and only KIDIA:KFDIA cells are selected.
  !! The compiler owns automatic scratch on the stack within a one-MiB bound.
  integer(JPIM) function cuddrafn(constants,thermal,YDEPHLI,YDECUMF,KIDIA,KFDIA,KLON,KLEV,LDDRAF,PTENH,PQENH,PQSEN,PGEO,PGEOH,PAPH,PRFL,PTD,PQD,PMFU,PMFD,PMFDS,PMFDQ,PDMFDP,PDMFDE,PMFDDE_RATE,PKINED) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    TYPE(TEPHLI), INTENT(INOUT) :: YDEPHLI
    TYPE(TECUMF), INTENT(INOUT) :: YDECUMF
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    LOGICAL, INTENT(IN) :: LDDRAF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQSEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRFL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQD(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PMFU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDS(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDQ(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMFDP(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMFDE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKINED(:, :)
    status = 2_JPIM
    if (KLON < 0 .or. KLON > 4096 .or. KLEV < 3 .or. KLEV > 1024) return
    if (KIDIA < 1 .or. KIDIA > KLON + 1 .or. KFDIA < 0 .or. KFDIA > KLON) return
    if (YDEPHLI%LPHYLIN) return

    if (.not. is_contiguous(LDDRAF)) return
    if (size(LDDRAF, 1) /= KLON) return
    if (.not. is_contiguous(PTENH)) return
    if (size(PTENH, 1) /= KLON) return
    if (size(PTENH, 2) < KLEV) return
    if (.not. is_contiguous(PQENH)) return
    if (size(PQENH, 1) /= KLON) return
    if (size(PQENH, 2) < KLEV) return
    if (.not. is_contiguous(PQSEN)) return
    if (size(PQSEN, 1) /= KLON) return
    if (size(PQSEN, 2) < KLEV) return
    if (.not. is_contiguous(PGEO)) return
    if (size(PGEO, 1) /= KLON) return
    if (size(PGEO, 2) < KLEV) return
    if (.not. is_contiguous(PGEOH)) return
    if (size(PGEOH, 1) /= KLON) return
    if (size(PGEOH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAPH)) return
    if (size(PAPH, 1) /= KLON) return
    if (size(PAPH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PRFL)) return
    if (size(PRFL, 1) /= KLON) return
    if (.not. is_contiguous(PTD)) return
    if (size(PTD, 1) /= KLON) return
    if (size(PTD, 2) < KLEV) return
    if (.not. is_contiguous(PQD)) return
    if (size(PQD, 1) /= KLON) return
    if (size(PQD, 2) < KLEV) return
    if (.not. is_contiguous(PMFU)) return
    if (size(PMFU, 1) /= KLON) return
    if (size(PMFU, 2) < KLEV) return
    if (.not. is_contiguous(PMFD)) return
    if (size(PMFD, 1) /= KLON) return
    if (size(PMFD, 2) < KLEV) return
    if (.not. is_contiguous(PMFDS)) return
    if (size(PMFDS, 1) /= KLON) return
    if (size(PMFDS, 2) < KLEV) return
    if (.not. is_contiguous(PMFDQ)) return
    if (size(PMFDQ, 1) /= KLON) return
    if (size(PMFDQ, 2) < KLEV) return
    if (.not. is_contiguous(PDMFDP)) return
    if (size(PDMFDP, 1) /= KLON) return
    if (size(PDMFDP, 2) < KLEV) return
    if (.not. is_contiguous(PDMFDE)) return
    if (size(PDMFDE, 1) /= KLON) return
    if (size(PDMFDE, 2) < KLEV) return
    if (.not. is_contiguous(PMFDDE_RATE)) return
    if (size(PMFDDE_RATE, 1) /= KLON) return
    if (size(PMFDDE_RATE, 2) < KLEV) return
    if (.not. is_contiguous(PKINED)) return
    if (size(PKINED, 1) /= KLON) return
    if (size(PKINED, 2) < KLEV) return
    status=cuddrafn_body(constants,thermal,YDEPHLI,YDECUMF,KIDIA,KFDIA,KLON,KLEV,LDDRAF(1:KLON),PTENH(1:KLON,1:KLEV),PQENH(1:KLON,1:KLEV),PQSEN(1:KLON,1:KLEV),PGEO(1:KLON,1:KLEV),PGEOH(1:KLON,1:KLEV+1),PAPH(1:KLON,1:KLEV+1),PRFL(1:KLON),PTD(1:KLON,1:KLEV),PQD(1:KLON,1:KLEV),PMFU(1:KLON,1:KLEV),PMFD(1:KLON,1:KLEV),PMFDS(1:KLON,1:KLEV),PMFDQ(1:KLON,1:KLEV),PDMFDP(1:KLON,1:KLEV),PDMFDE(1:KLON,1:KLEV),PMFDDE_RATE(1:KLON,1:KLEV),PKINED(1:KLON,1:KLEV))
  end function cuddrafn

  integer(JPIM) function cuddrafn_body(constants,thermal,YDEPHLI,YDECUMF,KIDIA,KFDIA,KLON,KLEV,LDDRAF,PTENH,PQENH,PQSEN,PGEO,PGEOH,PAPH,PRFL,PTD,PQD,PMFU,PMFD,PMFDS,PMFDQ,PDMFDP,PDMFDE,PMFDDE_RATE,PKINED) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    TYPE(TECUMF), INTENT(INOUT) :: YDECUMF
    TYPE(TEPHLI), INTENT(INOUT) :: YDEPHLI
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    LOGICAL, INTENT(IN) :: LDDRAF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQSEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRFL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQD(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PMFU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDS(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDQ(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMFDP(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMFDE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKINED(:, :)
    REAL(KIND=JPRB) :: ZDMFEN(KLON), ZDMFDE(KLON), ZCOND(KLON), ZOENTR(KLON), ZBUOY(KLON)
    REAL(KIND=JPRB) :: ZPH(KLON)
    LOGICAL :: LLO2(KLON)
    INTEGER(KIND=JPIM) :: ICALL, IK, IS, ITOPDE, JK, JL
    REAL(KIND=JPRB) :: ZBUO, ZBUOYZ, ZBUOYV, ZDMFDP, ZDZ, ZENTR, ZMFDQK, ZMFDSK, ZQDDE, ZQEEN, ZRAIN, ZSDDE, ZSEEN, ZZENTR, ZRG, ZFACBUO, Z_CWDRAG , ZDKBUO, ZDKEN
    integer(JPIM) :: native_child_status
    status = 0_JPIM
    ASSOCIATE (ENTRDD => YDECUMF%ENTRDD, NJKT3 => YDECUMF%NJKT3, RMFCMIN => YDECUMF%RMFCMIN)
      ITOPDE = NJKT3
      ZRG = 1.0_JPRB/constants%rg
      ZFACBUO = 0.5_JPRB/(1.0_JPRB + 0.5_JPRB)
      Z_CWDRAG = (3._JPRB/8._JPRB)*0.506_JPRB/0.2_JPRB
      DO JL = KIDIA, KFDIA
        ZOENTR(JL) = 0.0_JPRB
        ZBUOY(JL) = 0.0_JPRB
        ZDMFEN(JL) = 0.0_JPRB
        ZDMFDE(JL) = 0.0_JPRB
        PDMFDE(JL, :) = 0.0_JPRB
        PMFDDE_RATE(JL, :) = 0.0_JPRB
        PKINED(JL, :) = 0.0_JPRB
      END DO
      DO JK = 3, KLEV
        IS = 0
        DO JL = KIDIA, KFDIA
          ZPH(JL) = PAPH(JL, JK)
          LLO2(JL) = LDDRAF(JL) .AND. PMFD(JL, JK - 1) < 0.0_JPRB
          IF (LLO2(JL)) THEN
            IS = IS + 1
          END IF
        END DO
        IF (IS == 0) CYCLE
        DO JL = KIDIA, KFDIA
        IF (LLO2(JL)) THEN
          ZENTR = ENTRDD*PMFD(JL, JK - 1)*(PGEOH(JL, JK - 1) - PGEOH(JL, JK))*ZRG
          ZDMFEN(JL) = ZENTR
          ZDMFDE(JL) = ZENTR
        END IF
        END DO
        IF (JK > ITOPDE) THEN
        DO JL = KIDIA, KFDIA
        IF (LLO2(JL)) THEN
          ZDMFEN(JL) = 0.0_JPRB
          ZDMFDE(JL) = PMFD(JL, ITOPDE)*(PAPH(JL, JK) - PAPH(JL, JK - 1))/(PAPH(JL, KLEV + 1) - PAPH(JL, ITOPDE))
        END IF
        END DO
        END IF
        IF (JK <= ITOPDE) THEN
        DO JL = KIDIA, KFDIA
        IF (LLO2(JL)) THEN
          ZDZ = -(PGEOH(JL, JK - 1) - PGEOH(JL, JK))*ZRG
          ZZENTR = ZOENTR(JL)*ZDZ*PMFD(JL, JK - 1)
          ZDMFEN(JL) = ZDMFEN(JL) + ZZENTR
          ZDMFEN(JL) = MAX(ZDMFEN(JL), 0.3_JPRB*PMFD(JL, JK - 1))
          ZDMFEN(JL) = MAX(ZDMFEN(JL), -0.75_JPRB*PMFU(JL, JK) - (PMFD(JL, JK - 1) - ZDMFDE(JL)))
          ZDMFEN(JL) = MIN(ZDMFEN(JL), 0.0_JPRB)
        END IF
        PDMFDE(JL, JK) = ZDMFEN(JL) - ZDMFDE(JL)
        END DO
        END IF
        DO JL = KIDIA, KFDIA
        IF (LLO2(JL)) THEN
          PMFD(JL, JK) = PMFD(JL, JK - 1) + ZDMFEN(JL) - ZDMFDE(JL)
          ZSEEN = (constants%rcpd*PTENH(JL, JK - 1) + PGEOH(JL, JK - 1))*ZDMFEN(JL)
          ZQEEN = PQENH(JL, JK - 1)*ZDMFEN(JL)
          ZSDDE = (constants%rcpd*PTD(JL, JK - 1) + PGEOH(JL, JK - 1))*ZDMFDE(JL)
          ZQDDE = PQD(JL, JK - 1)*ZDMFDE(JL)
          ZMFDSK = PMFDS(JL, JK - 1) + ZSEEN - ZSDDE
          ZMFDQK = PMFDQ(JL, JK - 1) + ZQEEN - ZQDDE
          PQD(JL, JK) = ZMFDQK*(1.0_JPRB/MIN(-RMFCMIN, PMFD(JL, JK)))
          PTD(JL, JK) = (ZMFDSK*(1.0_JPRB/MIN(-RMFCMIN, PMFD(JL, JK))) - PGEOH(JL, JK))/constants%rcpd
          PTD(JL, JK) = MIN(400._JPRB, PTD(JL, JK))
          PTD(JL, JK) = MAX(100._JPRB, PTD(JL, JK))
          ZCOND(JL) = PQD(JL, JK)
        END IF
        END DO
        IK = JK
        ICALL = 2
        native_child_status = cuadjtq(constants, thermal, YDEPHLI, KIDIA, KFDIA, KLON, KLEV, IK, ZPH, PTD, PQD, LLO2, ICALL)
        if (native_child_status /= 0) then
          status = native_child_status
          return
        end if
        DO JL = KIDIA, KFDIA
        IF (LLO2(JL)) THEN
          ZCOND(JL) = ZCOND(JL) - PQD(JL, JK)
          ZBUO = PTD(JL, JK)*(1.0_JPRB + constants%retv*PQD(JL, JK)) - PTENH(JL, JK)*(1.0_JPRB + constants%retv*PQENH(JL, JK))
          IF (PRFL(JL) > 0.0_JPRB .AND. PMFU(JL, JK) > 0.0_JPRB) THEN
            ZRAIN = PRFL(JL)/PMFU(JL, JK)
            ZBUO = ZBUO - PTD(JL, JK)*ZRAIN
          END IF
          IF (ZBUO >= 0.0_JPRB .OR. PRFL(JL) <= (PMFD(JL, JK)*ZCOND(JL))) THEN
            PMFD(JL, JK) = 0.0_JPRB
            ZBUO = 0.0_JPRB
          END IF
          PMFDS(JL, JK) = (constants%rcpd*PTD(JL, JK) + PGEOH(JL, JK))*PMFD(JL, JK)
          PMFDQ(JL, JK) = PQD(JL, JK)*PMFD(JL, JK)
          ZDMFDP = -PMFD(JL, JK)*ZCOND(JL)
          PDMFDP(JL, JK - 1) = ZDMFDP
          PRFL(JL) = PRFL(JL) + ZDMFDP
          ZBUOYZ = ZBUO/PTENH(JL, JK)
          ZBUOYV = ZBUOYZ
          ZBUOYZ = MIN(ZBUOYZ, 0.0_JPRB)
          ZDZ = -(PGEO(JL, JK - 1) - PGEO(JL, JK))
          ZBUOY(JL) = ZBUOY(JL) + ZBUOYZ*ZDZ
          ZOENTR(JL) = constants%rg*ZBUOYZ*0.5_JPRB/(1.0_JPRB + ZBUOY(JL))
          PMFDDE_RATE(JL, JK) = -ZDMFDE(JL)
          ZDKBUO = ZDZ*ZBUOYV*ZFACBUO
          IF (ZDMFEN(JL) < 0.0_JPRB) THEN
            ZDKEN = MIN(1.0_JPRB, (1 + Z_CWDRAG)*ZDMFEN(JL)/MIN(-RMFCMIN, PMFD(JL, JK - 1)))
          ELSE
            ZDKEN = MIN(1.0_JPRB, (1 + Z_CWDRAG)*ZDMFDE(JL)/MIN(-RMFCMIN, PMFD(JL, JK - 1)))
          END IF
          PKINED(JL, JK) = MAX(0.0_JPRB, (PKINED(JL, JK - 1)*(1 - ZDKEN) + ZDKBUO)/(1 + ZDKEN))
        END IF
        END DO
      END DO
    END ASSOCIATE
  end function cuddrafn_body
end module convection_downdraft_descent_mod
