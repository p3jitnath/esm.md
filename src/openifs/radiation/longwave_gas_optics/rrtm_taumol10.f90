!> Complete portable longwave band 10 numerical update.
!! Frozen equations and native interfaces are retained from the named source
!! and Markdown contract. All coefficient/reference owners are explicit inputs.
!! Scientific source attribution: AER RRTM and ECMWF OpenIFS RRTM_TAUMOL10.
module native_rrtm_taumol10
  use iso_fortran_env, only: real64, int32
  use iso_fortran_env, only: JPRB => real64, JPIM => int32
  use yomdimv, only: TDIMV
  use native_absorption_records, only: longwave_absorption_reduced_record
  use longwave_reference_parameter_fields_mod, only: longwave_reference_parameter_record
  implicit none
  private
  public :: rrtm_taumol10
contains
  !> Update the band cells of complete (columns,140,level_capacity) owners.
  !! Depth and Planck fraction are dimensionless. Aerosol depth is
  !! (columns,level_capacity,16). Gas columns use the retained 1e20 scale.
  !! Coefficients, reference tables and every declared input stay readonly;
  !! inactive points and level tails retain their incoming values.
  subroutine rrtm_taumol10(owned_reference,owned_coefficients,YDDIMV,KIDIA,KFDIA,KLEV,P_TAU, P_TAUAERL,P_FAC00,P_FAC01,P_FAC10,P_FAC11,P_FORFAC,P_FORFRAC,K_INDFOR,K_JP,K_JT,K_JT1, P_COLH2O,K_LAYTROP,P_SELFFAC,P_SELFFRAC,K_INDSELF,PFRAC)
    type(longwave_reference_parameter_record), intent(in) :: owned_reference
    type(longwave_absorption_reduced_record), intent(in), target :: owned_coefficients
    TYPE(TDIMV), INTENT(IN) :: YDDIMV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    REAL(KIND=JPRB), INTENT(INOUT) :: P_TAU(KIDIA:KFDIA, 140, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_TAUAERL(KIDIA:KFDIA, YDDIMV%NFLEVG, 16)
    REAL(KIND=JPRB), INTENT(IN) :: P_FAC00(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FAC01(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FAC10(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FAC11(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_JP(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_JT(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_JT1(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_COLH2O(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_LAYTROP(KIDIA:KFDIA)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFRAC(KIDIA:KFDIA, 140, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDSELF(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDFOR(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: IND0(YDDIMV%NFLEVG), IND1(YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: INDS(YDDIMV%NFLEVG), INDF(YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: IG, JLAY
    INTEGER(KIND=JPIM) :: JLON
    REAL(KIND=JPRB) :: ZTAUFOR, ZTAUSELF
    real(real64), pointer :: absa(:, :)
    real(real64), pointer :: absb(:, :)
    absa(1:65, 1:6) => owned_coefficients%b10_ka
    absb(1:235, 1:6) => owned_coefficients%b10_kb
    ASSOCIATE (NFLEVG => YDDIMV%NFLEVG)
    DO JLAY = 1, KLEV
    DO JLON = KIDIA, KFDIA
    IF (JLAY <= K_LAYTROP(JLON)) THEN
      IND0(JLAY) = ((K_JP(JLON, JLAY) - 1)*5 + (K_JT(JLON, JLAY) - 1))*owned_reference%nspa(10) + 1
      IND1(JLAY) = (K_JP(JLON, JLAY)*5 + (K_JT1(JLON, JLAY) - 1))*owned_reference%nspa(10) + 1
      INDS(JLAY) = K_INDSELF(JLON, JLAY)
      INDF(JLAY) = K_INDFOR(JLON, JLAY)
      DO IG = 1, owned_coefficients%ngc(10)
  ZTAUSELF = P_SELFFAC(JLON,JLAY) * (owned_coefficients%b10_selfref(INDS(JLAY),IG) + P_SELFFRAC(JLON,JLAY) * (owned_coefficients%b10_selfref(INDS(JLAY)+1,IG) - owned_coefficients%b10_selfref(INDS(JLAY),IG)))
  ZTAUFOR =  P_FORFAC(JLON,JLAY) * (owned_coefficients%b10_forref(INDF(JLAY),IG) + P_FORFRAC(JLON,JLAY) * (owned_coefficients%b10_forref(INDF(JLAY)+1,IG) - owned_coefficients%b10_forref(INDF(JLAY),IG)))
  P_TAU(JLON,owned_coefficients%ngs(9)+IG,JLAY) = P_COLH2O(JLON,JLAY) * (P_FAC00(JLON,JLAY) * ABSA(IND0(JLAY)  ,IG) + P_FAC10(JLON,JLAY) * ABSA(IND0(JLAY)+1,IG) + P_FAC01(JLON,JLAY) * ABSA(IND1(JLAY)  ,IG) + P_FAC11(JLON,JLAY) * ABSA(IND1(JLAY)+1,IG)) + ZTAUSELF + ZTAUFOR + P_TAUAERL(JLON,JLAY,10)
        PFRAC(JLON, owned_coefficients%ngs(9) + IG, JLAY) = owned_coefficients%b10_fracrefa(IG)
      END DO
    END IF
    IF (JLAY > K_LAYTROP(JLON)) THEN
      IND0(JLAY) = ((K_JP(JLON, JLAY) - 13)*5 + (K_JT(JLON, JLAY) - 1))*owned_reference%nspb(10) + 1
      IND1(JLAY) = ((K_JP(JLON, JLAY) - 12)*5 + (K_JT1(JLON, JLAY) - 1))*owned_reference%nspb(10) + 1
      INDF(JLAY) = K_INDFOR(JLON, JLAY)
      DO IG = 1, owned_coefficients%ngc(10)
  ZTAUFOR = P_FORFAC(JLON,JLAY) * (owned_coefficients%b10_forref(INDF(JLAY),IG) + P_FORFRAC(JLON,JLAY) * (owned_coefficients%b10_forref(INDF(JLAY)+1,IG) - owned_coefficients%b10_forref(INDF(JLAY),IG)))
  P_TAU(JLON,owned_coefficients%ngs(9)+IG,JLAY) = P_COLH2O(JLON,JLAY) * (P_FAC00(JLON,JLAY) * ABSB(IND0(JLAY)  ,IG) + P_FAC10(JLON,JLAY) * ABSB(IND0(JLAY)+1,IG) + P_FAC01(JLON,JLAY) * ABSB(IND1(JLAY)  ,IG) + P_FAC11(JLON,JLAY) * ABSB(IND1(JLAY)+1,IG)) + ZTAUFOR + P_TAUAERL(JLON,JLAY,10)
        PFRAC(JLON, owned_coefficients%ngs(9) + IG, JLAY) = owned_coefficients%b10_fracrefb(IG)
      END DO
    END IF
    END DO
    END DO
    END ASSOCIATE
  end subroutine rrtm_taumol10
end module native_rrtm_taumol10
