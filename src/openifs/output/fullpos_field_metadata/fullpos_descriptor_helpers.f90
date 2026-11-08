module forecast_native_fullpos_descriptor_helpers
  use iso_fortran_env, only: JPIM => int32, JPRB => real64
  use fullpos_mix, only: fullpos_type
  use type_fpdsphys, only: fpdsphy
  implicit none
  private
public::initialize_dynamic_descriptor,initialize_physical_descriptor,ctrl_tfp,ctrl_gfp,dynamic_declaration_defaults,physical_declaration_defaults
contains
  subroutine dynamic_declaration_defaults(output)
    type(fullpos_type), intent(inout) :: output
    output%IGRIB = -99999
    output%IBITS = 99
    output%INTER = -9
    output%IORDR = 0
    output%ISF = 0
    output%ICOD = 0
    output%ZFK = 0._JPRB
    output%LLGP = .TRUE.
    output%LLBIP = .FALSE.
    output%CLNIL = ' '
    output%CLNAME = ' '
    output%CLPAIR = ' '
    output%ILEVHOLI = (/-1_JPIM, -1_JPIM/)
    output%ILEVHOLF = (/-1_JPIM, -1_JPIM/)
    output%ICPLSIZE = 10_JPIM
    output%ICPLBITS = -1_JPIM
  end subroutine
  subroutine physical_declaration_defaults(output)
    type(fpdsphy), intent(inout) :: output
    output%IGRIB = -9999
    output%IBITS = 99
    output%INTER = -9
    output%IORDR = 0
    output%IANO = 0
    output%ICOD = 0
    output%IMASK = 1
    output%IPREP = 0
    output%LLMON = .FALSE.
    output%LLSRF = .TRUE.
    output%CLNAME = ' '
    output%CLPAIR = ' '
  end subroutine
  subroutine initialize_dynamic_descriptor(output, LDSRF, CDNAME, KGRIB, KBITS, KBITG, KNTER, LDGP, KSF, PFK, KORDR, CDPAIR, LDBIP)

! Purpose :
! -------
!    To set default values to the type

    type(fullpos_type), intent(inout) :: output
    LOGICAL, INTENT(IN) :: LDSRF
    CHARACTER(LEN=*), INTENT(IN) :: CDNAME
    INTEGER(KIND=JPIM), INTENT(IN) :: KGRIB
    INTEGER(KIND=JPIM), INTENT(IN) :: KBITS
    INTEGER(KIND=JPIM), INTENT(IN) :: KBITG
    INTEGER(KIND=JPIM), INTENT(IN) :: KNTER
    LOGICAL, INTENT(IN) :: LDGP
    INTEGER(KIND=JPIM), INTENT(IN) :: KSF
    REAL(KIND=JPRB), INTENT(IN) :: PFK
    INTEGER(KIND=JPIM), INTENT(IN) :: KORDR
    CHARACTER(LEN=*), INTENT(IN) :: CDPAIR
    LOGICAL, INTENT(IN), OPTIONAL :: LDBIP

    call dynamic_declaration_defaults(output)
    output%CLNAME = CDNAME
    output%CLPAIR = CDPAIR
    output%IGRIB = KGRIB
    output%INTER = KNTER
    output%IORDR = KORDR
    output%LLGP = LDGP
    output%LLSRF = LDSRF
    output%ICOD = 0
    output%CLNIL = ' '
    SELECT CASE (LDGP)
    CASE (.TRUE.)
      output%ISF = 0
      output%ZFK = 0.0_JPRB
      output%IBITS = KBITG
    CASE DEFAULT
      output%ISF = MAX(1, MIN(3, KSF))
      output%ZFK = MAX(0.0_JPRB, PFK)
      output%IBITS = KBITS
    END SELECT
    IF (PRESENT(LDBIP)) THEN
      output%LLBIP = LDBIP
    END IF

  end subroutine
  subroutine initialize_physical_descriptor(output, KGRIB, KBITS, KNTER, KORDR, KANO, KMASK, LDMON, LDSRF, CDNAME, &
   & CDPAIR, KPREP)

! Purpose :
! -------
!    To set default values to the type

    type(fpdsphy), intent(inout) :: output
    INTEGER(KIND=JPIM), INTENT(IN) :: KGRIB
    INTEGER(KIND=JPIM), INTENT(IN) :: KBITS
    INTEGER(KIND=JPIM), INTENT(IN) :: KNTER
    INTEGER(KIND=JPIM), INTENT(IN) :: KORDR
    INTEGER(KIND=JPIM), INTENT(IN) :: KANO
    INTEGER(KIND=JPIM), INTENT(IN) :: KMASK
    LOGICAL, INTENT(IN) :: LDMON
    LOGICAL, INTENT(IN) :: LDSRF
    CHARACTER(LEN=*), INTENT(IN) :: CDNAME
    CHARACTER(LEN=*), INTENT(IN) :: CDPAIR
    INTEGER(KIND=JPIM), INTENT(IN), OPTIONAL :: KPREP

    call physical_declaration_defaults(output)
    output%IGRIB = KGRIB
    output%IBITS = KBITS
    output%INTER = KNTER
    output%IORDR = KORDR
    output%IANO = KANO
    output%IMASK = KMASK
    IF (PRESENT(KPREP)) THEN
      output%IPREP = KPREP
    ELSE
      output%IPREP = -1
    END IF
    output%LLMON = LDMON
    output%LLSRF = LDSRF
    output%CLNAME = CDNAME
    output%CLPAIR = CDPAIR
    output%ICOD = 0

  end subroutine
  SUBROUTINE CTRL_TFP(YDFP_X, KCOD, CDNIL, LDSF, YDFP_DYNDS, KMAX)

! LDSF : .FALSE. to disable spectral filters.

    INTEGER(KIND=JPIM), INTENT(IN) :: KMAX
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCOD
    TYPE(FULLPOS_TYPE), INTENT(INOUT) :: YDFP_X
    TYPE(FULLPOS_TYPE), INTENT(INOUT) :: YDFP_DYNDS(KMAX) ! A single element is modified
    LOGICAL, INTENT(IN) :: LDSF
    CHARACTER(LEN=*), INTENT(IN) :: CDNIL

    SELECT CASE (YDFP_X%LLGP)
    CASE (.TRUE.)
      YDFP_X%ISF = 0
      YDFP_X%ZFK = 0.0_JPRB
    CASE DEFAULT
      SELECT CASE (LDSF)
      CASE (.TRUE.)
        YDFP_X%ISF = MAX(1, MIN(3, YDFP_X%ISF))
        YDFP_X%ZFK = MAX(0.0_JPRB, YDFP_X%ZFK)
      CASE DEFAULT
        YDFP_X%ISF = MIN(1, YDFP_X%ISF)
        YDFP_X%ZFK = 0.0_JPRB
      END SELECT
    END SELECT

    YDFP_X%CLNIL = CDNIL

    IF (KCOD >= 0) THEN
      KCOD = KCOD + 1
      YDFP_X%ICOD = KCOD
      IF (KCOD <= KMAX) THEN
        YDFP_DYNDS(KCOD) = YDFP_X
      END IF
    END IF

  END SUBROUTINE CTRL_TFP
  SUBROUTINE CTRL_GFP(KCOD, KMAX, YD_YGFP_X, YD_YGFP_PHYDS)

    INTEGER(KIND=JPIM), INTENT(IN) :: KMAX
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCOD
    TYPE(FPDSPHY), INTENT(INOUT) :: YD_YGFP_X
    TYPE(FPDSPHY), INTENT(INOUT) :: YD_YGFP_PHYDS(KMAX)

    YD_YGFP_X%ICOD = KCOD

    IF (KCOD >= 0) THEN
      KCOD = KCOD + 1
      YD_YGFP_X%ICOD = KCOD
      IF (KCOD <= KMAX) THEN
        YD_YGFP_PHYDS(KCOD) = YD_YGFP_X
      END IF
    END IF

  END SUBROUTINE CTRL_GFP
end module
