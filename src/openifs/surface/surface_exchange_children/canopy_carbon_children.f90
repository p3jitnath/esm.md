!> Canopy light and column binding for the existing native one-cell leaf.
!! The caller supplies admitted live parameter tables and disjoint FP64 views.
module forecast_canopy_carbon_children
  use iso_fortran_env, only: int32, real64
  use forecast_surface_scalar_math, only: surface_exp
  use photosynthesis_parameter_numerics, only: carbon_assimilation_one_cell
  use yos_ags, only: tags
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64, jprd = real64
  public :: ccetr, cotwo
contains
  subroutine ccetr(KIDIA, KFDIA, KLON, KVTYPE, LDLAND, PIA, PMU0, PABC, PLAI, YDAGS, PXIA)

    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KVTYPE(:)
    LOGICAL, INTENT(IN) :: LDLAND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PIA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(:)
    REAL(KIND=JPRB), INTENT(IN) :: PABC
    REAL(KIND=JPRB), INTENT(IN) :: PLAI(:)
    TYPE(TAGS), INTENT(IN) :: YDAGS
    REAL(KIND=JPRB), INTENT(INOUT) :: PXIA(:)

    REAL(KIND=JPRB) :: ZXFD(KLON), ZXSLAI(KLON), ZXIDF(KLON), ZXIDR(KLON)
    INTEGER(KIND=JPIM) :: JL

    ASSOCIATE (RDIFRACF => YDAGS%RDIFRACF, RXBOMEGA => YDAGS%RXBOMEGA, &
     & RXBOMEGAM => YDAGS%RXBOMEGAM, RXGT => YDAGS%RXGT)

      DO JL = KIDIA, KFDIA
        ZXFD(JL) = 0._JPRB
        ZXSLAI(JL) = 0._JPRB
        ZXIDF(JL) = 0._JPRB
        ZXIDR(JL) = 0._JPRB
      END DO

      DO JL = KIDIA, KFDIA
        PXIA(JL) = 0._JPRB
        IF (LDLAND(JL) .AND. PIA(JL) .GT. 0._JPRB) THEN

          ZXFD(JL) = RDIFRACF/(RDIFRACF + PMU0(JL))

          ZXSLAI(JL) = PLAI(JL)*(1.0_JPRB - PABC)

          ZXIDF(JL) = ZXFD(JL)*(1.0_JPRB - surface_exp(-0.8_JPRB*ZXSLAI(JL)*RXBOMEGAM(KVTYPE(JL))))
          ZXIDR(JL) = (1.0_JPRB - ZXFD(JL))*(1.0_JPRB - surface_exp(-RXGT*ZXSLAI(JL)*RXBOMEGAM(KVTYPE(JL))/PMU0(JL)))
          PXIA(JL) = PIA(JL)*(1.0_JPRB - ZXIDF(JL) - ZXIDR(JL))
        END IF
      END DO

    END ASSOCIATE
  end subroutine ccetr
  subroutine cotwo(KIDIA,KFDIA,KLON,LDLAND,PAN,PAG,PRD,PGS,PGC,PCSP,PDS,PDMAX,PIA,PGAMMT,YDAGS,PFZERO,PGMEST,PEPSO,PAMMAX)
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    LOGICAL, INTENT(IN) :: LDLAND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCSP(:)
    REAL(KIND=JPRB), INTENT(IN) :: PDS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PDMAX(:)
    REAL(KIND=JPRB), INTENT(IN) :: PIA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGAMMT(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFZERO(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGMEST(:)
    REAL(KIND=JPRB), INTENT(IN) :: PEPSO(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAMMAX(:)
    TYPE(TAGS), INTENT(IN) :: YDAGS
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGS(:)
    real(real64) :: input(10), coefficients(4), output(4)
    integer(int32) :: column
    coefficients = [ydags%rairtoh2o, ydags%rco2toh2o, ydags%rcondstmin, ydags%rrdcf]
    do column = kidia, kfdia
      if (ldland(column)) then
        input = [pgc(column), pcsp(column), pds(column), pdmax(column), pia(column), pgammt(column), &
                 pfzero(column), pgmest(column), pepso(column), pammax(column)]
        call carbon_assimilation_one_cell(input, coefficients, output)
        pan(column) = output(1)
        pag(column) = output(2)
        prd(column) = output(3)
        pgs(column) = output(4)
      else
        pan(column) = 0.0_real64
        pag(column) = 0.0_real64
        prd(column) = 0.0_real64
        pgs(column) = 0.0_real64
      end if
    end do

  end subroutine cotwo
end module
