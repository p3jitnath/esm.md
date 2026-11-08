! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Native source-ordered arithmetic required by the complete physics sequence.
!! These raw entries use the original argument shapes and optional-field order.
!! The caller supplies valid source bounds, array associations, admitted aliases,
!! nearest-even arithmetic and gradual underflow. Outputs preserve inactive rows.
!! No original numerical routine, original data global or GPU entry is called.
module forecast_complete_state_field_updates
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int
  use forecast_physics_work_types, only: dimension_type, state_type
  use physical_constant_setup_port, only: forecast_physical_constants
  use yoecnd, only: tecnd
  use yomphy2, only: tphy2
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64
  integer(int32), parameter :: ncldql = 1, ncldqi = 2, ncldqr = 3, ncldqs = 4
  public :: state_update, state_increment, update_fields, qnegat
  public :: state_update_raw, state_increment_raw, update_fields_raw, qnegat_raw
  interface state_update_raw
    module procedure state_update
  end interface
  interface state_increment_raw
    module procedure state_increment
  end interface
  interface update_fields_raw
    module procedure update_fields
  end interface
  interface qnegat_raw
    module procedure qnegat
  end interface
contains
!> Complete native ports of four retained CPU arithmetic entries.
!! Native DIMENSION_TYPE and STATE_TYPE preserve their named field ownership.
!! State fields retain wind m/s, temperature K and humidity kg/kg units.
!! TPHY2 supplies seconds. Tendencies have the corresponding units per second.
!! Only active columns and levels are written; enabled fields must be attached.
!! Compiler-owned interfaces replace every old Arm byte-offset descriptor.
!! Source caller bounds and alias obligations remain required.
  SUBROUTINE STATE_UPDATE(YDPHY2, KDIM, PISTATE, PTEND, POSTATE)
    IMPLICIT NONE

    TYPE(TPHY2), INTENT(INOUT) :: YDPHY2
    TYPE(DIMENSION_TYPE), INTENT(IN) :: KDIM
    TYPE(STATE_TYPE), INTENT(IN) :: PISTATE
    TYPE(STATE_TYPE), INTENT(IN) :: PTEND
    TYPE(STATE_TYPE), INTENT(INOUT) :: POSTATE

    INTEGER(KIND=JPIM) :: I, K
    REAL(KIND=JPRB) :: PRODUCT, TIMESTEP
    IF (KDIM%KIDIA > KDIM%KFDIA .OR. KDIM%KLEV <= 0) RETURN
    TIMESTEP = YDPHY2%TSPHY
    DO K = 1, KDIM%KLEV
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%U(I, K)
        POSTATE%U(I, K) = PISTATE%U(I, K) + PRODUCT
      END DO
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%V(I, K)
        POSTATE%V(I, K) = PISTATE%V(I, K) + PRODUCT
      END DO
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%T(I, K)
        POSTATE%T(I, K) = PISTATE%T(I, K) + PRODUCT
      END DO
      IF (POSTATE%KEYMASK%Q) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%Q(I, K)
        POSTATE%Q(I, K) = PISTATE%Q(I, K) + PRODUCT
      END DO
      END IF
      IF (POSTATE%KEYMASK%O3) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%O3(I, K)
        POSTATE%O3(I, K) = PISTATE%O3(I, K) + PRODUCT
      END DO
      END IF
      IF (POSTATE%KEYMASK%A) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%A(I, K)
        POSTATE%A(I, K) = PISTATE%A(I, K) + PRODUCT
      END DO
      END IF
      IF (POSTATE%KEYMASK%QL) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%CLD(I, K, NCLDQL)
        POSTATE%CLD(I, K, NCLDQL) = PISTATE%CLD(I, K, NCLDQL) + PRODUCT
      END DO
      END IF
      IF (POSTATE%KEYMASK%QI) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%CLD(I, K, NCLDQI)
        POSTATE%CLD(I, K, NCLDQI) = PISTATE%CLD(I, K, NCLDQI) + PRODUCT
      END DO
      END IF
      IF (POSTATE%KEYMASK%QR) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%CLD(I, K, NCLDQR)
        POSTATE%CLD(I, K, NCLDQR) = PISTATE%CLD(I, K, NCLDQR) + PRODUCT
      END DO
      END IF
      IF (POSTATE%KEYMASK%QS) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%CLD(I, K, NCLDQS)
        POSTATE%CLD(I, K, NCLDQS) = PISTATE%CLD(I, K, NCLDQS) + PRODUCT
      END DO
      END IF
      IF (POSTATE%KEYMASK%TKE) THEN
      DO I = KDIM%KIDIA, KDIM%KFDIA
        PRODUCT = TIMESTEP*PTEND%TKE(I, K)
        POSTATE%TKE(I, K) = PISTATE%TKE(I, K) + PRODUCT
      END DO
      END IF
    END DO
  END SUBROUTINE STATE_UPDATE

  SUBROUTINE STATE_INCREMENT(KDIM, POSTATE, PA_U, PA_V, PA_T, PA_O3, PA_Q, PA_A, PA_QL, PA_QI, PA_QR, PA_QS,&
                            &PA_TKE)
    IMPLICIT NONE

    TYPE(DIMENSION_TYPE), INTENT(IN) :: KDIM
    TYPE(STATE_TYPE), INTENT(INOUT) :: POSTATE
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_U(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_V(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_T(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_O3(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_Q(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_A(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_QL(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_QI(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_QR(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_QS(KDIM%KLON, KDIM%KLEV)
    REAL(KIND=JPRB), OPTIONAL, TARGET, INTENT(IN) :: PA_TKE(KDIM%KLON, KDIM%KLEV)

    INTEGER(KIND=JPIM) :: I, K, TARGET_LEVEL
    IF (KDIM%KIDIA > KDIM%KFDIA .OR. KDIM%KLEV <= 0) RETURN
    IF (PRESENT(PA_U)) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%U, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%U(I, TARGET_LEVEL) = POSTATE%U(I, TARGET_LEVEL) + PA_U(I, K)
        END DO
      END DO
    END IF
    IF (PRESENT(PA_V)) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%V, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%V(I, TARGET_LEVEL) = POSTATE%V(I, TARGET_LEVEL) + PA_V(I, K)
        END DO
      END DO
    END IF
    IF (PRESENT(PA_T)) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%T, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%T(I, TARGET_LEVEL) = POSTATE%T(I, TARGET_LEVEL) + PA_T(I, K)
        END DO
      END DO
    END IF
    IF (PRESENT(PA_Q)) THEN
      IF (POSTATE%KEYMASK%Q) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%Q, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%Q(I, TARGET_LEVEL) = POSTATE%Q(I, TARGET_LEVEL) + PA_Q(I, K)
        END DO
      END DO
      END IF
    END IF
    IF (PRESENT(PA_O3)) THEN
      IF (POSTATE%KEYMASK%O3) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%O3, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%O3(I, TARGET_LEVEL) = POSTATE%O3(I, TARGET_LEVEL) + PA_O3(I, K)
        END DO
      END DO
      END IF
    END IF
    IF (PRESENT(PA_A)) THEN
      IF (POSTATE%KEYMASK%A) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%A, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%A(I, TARGET_LEVEL) = POSTATE%A(I, TARGET_LEVEL) + PA_A(I, K)
        END DO
      END DO
      END IF
    END IF
    IF (PRESENT(PA_TKE)) THEN
      IF (POSTATE%KEYMASK%TKE) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%TKE, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%TKE(I, TARGET_LEVEL) = POSTATE%TKE(I, TARGET_LEVEL) + PA_TKE(I, K)
        END DO
      END DO
      END IF
    END IF
    IF (PRESENT(PA_QL)) THEN
      IF (POSTATE%KEYMASK%QL) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%CLD, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%CLD(I, TARGET_LEVEL, NCLDQL) = POSTATE%CLD(I, TARGET_LEVEL, NCLDQL) + PA_QL(I, K)
        END DO
      END DO
      END IF
    END IF
    IF (PRESENT(PA_QI)) THEN
      IF (POSTATE%KEYMASK%QI) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%CLD, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%CLD(I, TARGET_LEVEL, NCLDQI) = POSTATE%CLD(I, TARGET_LEVEL, NCLDQI) + PA_QI(I, K)
        END DO
      END DO
      END IF
    END IF
    IF (PRESENT(PA_QR)) THEN
      IF (POSTATE%KEYMASK%QR) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%CLD, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%CLD(I, TARGET_LEVEL, NCLDQR) = POSTATE%CLD(I, TARGET_LEVEL, NCLDQR) + PA_QR(I, K)
        END DO
      END DO
      END IF
    END IF
    IF (PRESENT(PA_QS)) THEN
      IF (POSTATE%KEYMASK%QS) THEN
      DO K = 1, KDIM%KLEV
        TARGET_LEVEL = LBOUND(POSTATE%CLD, 2) + K - 1
        DO I = KDIM%KIDIA, KDIM%KFDIA
          POSTATE%CLD(I, TARGET_LEVEL, NCLDQS) = POSTATE%CLD(I, TARGET_LEVEL, NCLDQS) + PA_QS(I, K)
        END DO
      END DO
      END IF
    END IF
  END SUBROUTINE STATE_INCREMENT

!> Keep all97 original optional arguments and each field's complete store order.
! optional input
! output
  SUBROUTINE UPDATE_FIELDS(YDPHY2, KONFIG, KIDIA, KFDIA, KLON, KLEV, &
                        & PI1, PI2, PI3, PI4, PI5, PI6, PI7, PI8, PI9, PI10, &
                        & PI11, PI12, PI13, &
                        & PS1, PS2, PS3, PS4, PS5, PS6, PS7, PS8, PS9, PS10, &
                        & PS11, PS12, PS13, &
                        & PA1, PA2, PA3, PA4, PA5, PA6, PA7, PA8, PA9, PA10, &
                        & PA11, PA12, PA13, &
                        & LDV1, LDV2, LDV3, LDV4, LDV5, LDV6, LDV7, LDV8, LDV9, LDV10, &
                        & LDV11, LDV12, LDV13, &
                        & PTA1, PTA2, PTA3, PTA4, PTA5, PTA6, PTA7, PTA8, PTA9, PTA10, &
                        & PTA11, PTA12, PTA13, &
                        & PTS1, PTS2, PTS3, PTS4, PTS5, PTS6, PTS7, PTS8, PTS9, PTS10, &
                        & PTS11, PTS12, PTS13, &
                        & PO1, PO2, PO3, PO4, PO5, PO6, PO7, PO8, PO9, PO10, &
                        & PO11, PO12, PO13)
    IMPLICIT NONE

    TYPE(TPHY2), INTENT(INOUT) :: YDPHY2
    INTEGER(KIND=JPIM), INTENT(IN) :: KONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI1(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI2(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI3(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI4(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI5(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI6(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI7(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI8(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI9(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI10(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI11(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI12(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PI13(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS1(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS2(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS3(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS4(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS5(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS6(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS7(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS8(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS9(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS10(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS11(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS12(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PS13(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA1(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA2(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA3(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA4(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA5(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA6(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA7(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA8(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA9(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA10(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA11(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA12(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PA13(KLON, KLEV)
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV1
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV2
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV3
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV4
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV5
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV6
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV7
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV8
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV9
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV10
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV11
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV12
    LOGICAL, OPTIONAL, INTENT(IN) :: LDV13
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA1(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA2(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA3(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA4(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA5(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA6(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA7(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA8(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA9(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA10(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA11(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA12(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTA13(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS1(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS2(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS3(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS4(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS5(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS6(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS7(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS8(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS9(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS10(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS11(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS12(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PTS13(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO1(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO2(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO3(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO4(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO5(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO6(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO7(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO8(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO9(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO10(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO11(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO12(KLON, KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(INOUT) :: PO13(KLON, KLEV)

! ---------------------------------------------------------------------------------

    INTEGER(KIND=JPIM) :: JL, JK
    LOGICAL :: ENABLED
    REAL(KIND=JPRB) :: VALUE, RATE, PRODUCT, TIMESTEP
    TIMESTEP = YDPHY2%TSPHY
    IF (KLEV <= 0 .OR. KIDIA > KFDIA) RETURN

    IF (PRESENT(PO1)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV1)) ENABLED = LDV1
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI1)) THEN
              VALUE = PI1(JL, JK)
            ELSE
              VALUE = PO1(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA1(JL, JK)
              IF (PRESENT(PTS1)) RATE = RATE - PTS1(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA1)) VALUE = VALUE + PA1(JL, JK)
            IF (PRESENT(PS1)) VALUE = VALUE - PS1(JL, JK)
            PO1(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO2)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV2)) ENABLED = LDV2
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI2)) THEN
              VALUE = PI2(JL, JK)
            ELSE
              VALUE = PO2(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA2(JL, JK)
              IF (PRESENT(PTS2)) RATE = RATE - PTS2(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA2)) VALUE = VALUE + PA2(JL, JK)
            IF (PRESENT(PS2)) VALUE = VALUE - PS2(JL, JK)
            PO2(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO3)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV3)) ENABLED = LDV3
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI3)) THEN
              VALUE = PI3(JL, JK)
            ELSE
              VALUE = PO3(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA3(JL, JK)
              IF (PRESENT(PTS3)) RATE = RATE - PTS3(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA3)) VALUE = VALUE + PA3(JL, JK)
            IF (PRESENT(PS3)) VALUE = VALUE - PS3(JL, JK)
            PO3(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO4)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV4)) ENABLED = LDV4
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI4)) THEN
              VALUE = PI4(JL, JK)
            ELSE
              VALUE = PO4(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA4(JL, JK)
              IF (PRESENT(PTS4)) RATE = RATE - PTS4(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA4)) VALUE = VALUE + PA4(JL, JK)
            IF (PRESENT(PS4)) VALUE = VALUE - PS4(JL, JK)
            PO4(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO5)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV5)) ENABLED = LDV5
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI5)) THEN
              VALUE = PI5(JL, JK)
            ELSE
              VALUE = PO5(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA5(JL, JK)
              IF (PRESENT(PTS5)) RATE = RATE - PTS5(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA5)) VALUE = VALUE + PA5(JL, JK)
            IF (PRESENT(PS5)) VALUE = VALUE - PS5(JL, JK)
            PO5(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO6)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV6)) ENABLED = LDV6
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI6)) THEN
              VALUE = PI6(JL, JK)
            ELSE
              VALUE = PO6(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA6(JL, JK)
              IF (PRESENT(PTS6)) RATE = RATE - PTS6(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA6)) VALUE = VALUE + PA6(JL, JK)
            IF (PRESENT(PS6)) VALUE = VALUE - PS6(JL, JK)
            PO6(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO7)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV7)) ENABLED = LDV7
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI7)) THEN
              VALUE = PI7(JL, JK)
            ELSE
              VALUE = PO7(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA7(JL, JK)
              IF (PRESENT(PTS7)) RATE = RATE - PTS7(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA7)) VALUE = VALUE + PA7(JL, JK)
            IF (PRESENT(PS7)) VALUE = VALUE - PS7(JL, JK)
            PO7(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO8)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV8)) ENABLED = LDV8
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI8)) THEN
              VALUE = PI8(JL, JK)
            ELSE
              VALUE = PO8(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA8(JL, JK)
              IF (PRESENT(PTS8)) RATE = RATE - PTS8(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA8)) VALUE = VALUE + PA8(JL, JK)
            IF (PRESENT(PS8)) VALUE = VALUE - PS8(JL, JK)
            PO8(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO9)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV9)) ENABLED = LDV9
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI9)) THEN
              VALUE = PI9(JL, JK)
            ELSE
              VALUE = PO9(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA9(JL, JK)
              IF (PRESENT(PTS9)) RATE = RATE - PTS9(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA9)) VALUE = VALUE + PA9(JL, JK)
            IF (PRESENT(PS9)) VALUE = VALUE - PS9(JL, JK)
            PO9(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO10)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV10)) ENABLED = LDV10
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI10)) THEN
              VALUE = PI10(JL, JK)
            ELSE
              VALUE = PO10(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA10(JL, JK)
              IF (PRESENT(PTS10)) RATE = RATE - PTS10(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA10)) VALUE = VALUE + PA10(JL, JK)
            IF (PRESENT(PS10)) VALUE = VALUE - PS10(JL, JK)
            PO10(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO11)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV11)) ENABLED = LDV11
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI11)) THEN
              VALUE = PI11(JL, JK)
            ELSE
              VALUE = PO11(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA11(JL, JK)
              IF (PRESENT(PTS11)) RATE = RATE - PTS11(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA11)) VALUE = VALUE + PA11(JL, JK)
            IF (PRESENT(PS11)) VALUE = VALUE - PS11(JL, JK)
            PO11(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO12)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV12)) ENABLED = LDV12
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI12)) THEN
              VALUE = PI12(JL, JK)
            ELSE
              VALUE = PO12(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA12(JL, JK)
              IF (PRESENT(PTS12)) RATE = RATE - PTS12(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA12)) VALUE = VALUE + PA12(JL, JK)
            IF (PRESENT(PS12)) VALUE = VALUE - PS12(JL, JK)
            PO12(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF

    IF (PRESENT(PO13)) THEN
      ENABLED = .TRUE.
      IF (PRESENT(LDV13)) ENABLED = LDV13
      IF (ENABLED) THEN
        DO JK = 1, KLEV
          DO JL = KIDIA, KFDIA
            IF (PRESENT(PI13)) THEN
              VALUE = PI13(JL, JK)
            ELSE
              VALUE = PO13(JL, JK)
            END IF
            IF (KONFIG == 1) THEN
              RATE = PTA13(JL, JK)
              IF (PRESENT(PTS13)) RATE = RATE - PTS13(JL, JK)
              PRODUCT = RATE*TIMESTEP
              VALUE = VALUE + PRODUCT
            END IF
            IF (PRESENT(PA13)) VALUE = VALUE + PA13(JL, JK)
            IF (PRESENT(PS13)) VALUE = VALUE - PS13(JL, JK)
            PO13(JL, JK) = VALUE
          END DO
        END DO
      END IF
    END IF
  END SUBROUTINE UPDATE_FIELDS

!> Repair one humidity column and retain its pressure-weighted flux.
!! PHYSICAL supplies readonly gravity in m/s2. YDECND supplies the humidity
!! floor in kg/kg. PQM and optional PITEND are readonly(KLON,KLEV) fields
!! in kg/kg and kg/kg/s. PQE is mutable kg/kg/s. PRESH is Pa and PFCQNG
!! is the mutable diagnostic on faces0:KLEV. Its upper face is unchanged.
!! The caller supplies positive timestep, gravity and layer thickness,
!! KLEV>=1, complete native views, admitted aliases and the frozen FP mode.
  SUBROUTINE QNEGAT(physical, YDECND, KIDIA, KFDIA, KLON, KLEV, PTSPHY, PQM, PQE, PRESH, PFCQNG, PITEND)
    TYPE(forecast_physical_constants), INTENT(IN) :: physical
    TYPE(TECND), INTENT(IN) :: YDECND
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA, KFDIA, KLON, KLEV
    REAL(KIND=JPRB), INTENT(IN) :: PTSPHY, PQM(KLON, KLEV), PRESH(KLON, 0:KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQE(KLON, KLEV), PFCQNG(KLON, 0:KLEV)
    REAL(KIND=JPRB), OPTIONAL, INTENT(IN) :: PITEND(KLON, KLEV)
    INTEGER(KIND=JPIM) :: JL, JK
    REAL(KIND=JPRB), VOLATILE :: INVERSE_TIMESTEP
    REAL(KIND=JPRB) :: FLOOR_VALUE, GRAVITY, DEFICIT, CORRECTION, UPPER_DP, LOWER_DP, COLUMN_FLUX, FLUX_DELTA
    IF (KIDIA > KFDIA) RETURN
    FLOOR_VALUE = YDECND%REPQMI
    INVERSE_TIMESTEP = 1.0_JPRB/PTSPHY
    GRAVITY = physical%rg
    DO JL = KIDIA, KFDIA
      DO JK = 1, KLEV
        PQE(JL, JK) = 0.0_JPRB
        IF (PRESENT(PITEND)) PQE(JL, JK) = PITEND(JL, JK)
      END DO
      DO JK = 1, KLEV
        DEFICIT = PTSPHY*PQE(JL, JK)
        DEFICIT = PQM(JL, JK) + DEFICIT
        DEFICIT = FLOOR_VALUE - DEFICIT
        DEFICIT = MAX(0.0_JPRB, DEFICIT)
        CORRECTION = DEFICIT*INVERSE_TIMESTEP
        PQE(JL, JK) = PQE(JL, JK) + CORRECTION
        IF (JK < KLEV) THEN
          UPPER_DP = PRESH(JL, JK) - PRESH(JL, JK - 1)
          LOWER_DP = PRESH(JL, JK + 1) - PRESH(JL, JK)
          CORRECTION = CORRECTION*UPPER_DP
          CORRECTION = CORRECTION/LOWER_DP
          PQE(JL, JK + 1) = PQE(JL, JK + 1) - CORRECTION
        END IF
      END DO
      IF (PRESENT(PITEND)) THEN
        DO JK = 1, KLEV
          PQE(JL, JK) = PQE(JL, JK) - PITEND(JL, JK)
        END DO
      END IF
      COLUMN_FLUX = 0.0_JPRB
      DO JK = 1, KLEV
        UPPER_DP = PRESH(JL, JK) - PRESH(JL, JK - 1)
        FLUX_DELTA = -PQE(JL, JK)
        FLUX_DELTA = FLUX_DELTA*UPPER_DP
        FLUX_DELTA = FLUX_DELTA/GRAVITY
        COLUMN_FLUX = FLUX_DELTA + COLUMN_FLUX
        PFCQNG(JL, JK) = PFCQNG(JL, JK) + COLUMN_FLUX
      END DO
    END DO
  END SUBROUTINE QNEGAT

end module forecast_complete_state_field_updates
