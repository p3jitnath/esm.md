!> Complete portable longwave band 12 numerical update.
!! Frozen equations and native interfaces are retained from the named source
!! and Markdown contract. All coefficient/reference owners are explicit inputs.
!! Scientific source attribution: AER RRTM and ECMWF OpenIFS RRTM_TAUMOL12.
module native_rrtm_taumol12
  use iso_fortran_env, only: real64, int32
  use iso_fortran_env, only: JPRB => real64, JPIM => int32
  use yomdimv, only: TDIMV
  use native_absorption_records, only: longwave_absorption_reduced_record
  use longwave_reference_parameter_fields_mod, only: longwave_reference_parameter_record
  implicit none
  private
  public :: rrtm_taumol12
contains
  !> Update the band cells of complete (columns,140,level_capacity) owners.
  !! Depth and Planck fraction are dimensionless. Aerosol depth is
  !! (columns,level_capacity,16). Gas columns use the retained 1e20 scale.
  !! Coefficients, reference tables and every declared input stay readonly;
  !! inactive points and level tails retain their incoming values.
  subroutine rrtm_taumol12(owned_reference,owned_coefficients,YDDIMV,KIDIA,KFDIA,KLEV,P_TAU, P_TAUAERL,P_FAC00,P_FAC01,P_FAC10,P_FAC11,P_FORFAC,P_FORFRAC,K_INDFOR,K_JP,K_JT,K_JT1,P_ONEMINUS, P_COLH2O,P_COLCO2,K_LAYTROP,P_SELFFAC,P_SELFFRAC,K_INDSELF,PFRAC, PRAT_H2OCO2, PRAT_H2OCO2_1)
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
    REAL(KIND=JPRB), INTENT(IN) :: P_ONEMINUS
    REAL(KIND=JPRB), INTENT(IN) :: P_COLH2O(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_COLCO2(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_LAYTROP(KIDIA:KFDIA)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDSELF(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFRAC(KIDIA:KFDIA, 140, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: PRAT_H2OCO2(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: PRAT_H2OCO2_1(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDFOR(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB) :: Z_SPECCOMB(YDDIMV%NFLEVG), Z_SPECCOMB1(YDDIMV%NFLEVG), Z_SPECCOMB_PLANCK(YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: IND0(YDDIMV%NFLEVG), IND1(YDDIMV%NFLEVG), INDS(YDDIMV%NFLEVG), INDF(YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: IG, JS, JLAY, JS1, JPL
    INTEGER(KIND=JPIM) :: JLON
    REAL(KIND=JPRB) :: Z_FS, Z_SPECMULT, Z_SPECPARM, Z_FS1, Z_SPECMULT1, Z_SPECPARM1, Z_FPL, Z_SPECMULT_PLANCK, Z_SPECPARM_PLANCK
  REAL(KIND=JPRB) ::  Z_FAC000, Z_FAC100, Z_FAC200, Z_FAC010, Z_FAC110, Z_FAC210, Z_FAC001, Z_FAC101, Z_FAC201, Z_FAC011, Z_FAC111, Z_FAC211
    REAL(KIND=JPRB) :: ZP, ZP4, ZFK0, ZFK1, ZFK2
    REAL(KIND=JPRB) :: ZTAUFOR, ZTAUSELF, ZTAU_MAJOR, ZTAU_MAJOR1
    REAL(KIND=JPRB) :: ZREFRAT_PLANCK_A
    real(real64), pointer :: absa(:, :)
    absa(1:585, 1:8) => owned_coefficients%b12_ka
    ASSOCIATE (NFLEVG => YDDIMV%NFLEVG)
      ZREFRAT_PLANCK_A = owned_reference%chi_mls(1, 10)/owned_reference%chi_mls(2, 10)
      DO JLAY = 1, KLEV
      DO JLON = KIDIA, KFDIA
      IF (JLAY <= K_LAYTROP(JLON)) THEN
        Z_SPECCOMB(JLAY) = P_COLH2O(JLON, JLAY) + PRAT_H2OCO2(JLON, JLAY)*P_COLCO2(JLON, JLAY)
        Z_SPECPARM = P_COLH2O(JLON, JLAY)/Z_SPECCOMB(JLAY)
        Z_SPECPARM = MIN(P_ONEMINUS, Z_SPECPARM)
        Z_SPECMULT = 8._JPRB*(Z_SPECPARM)
        JS = 1 + INT(Z_SPECMULT)
        Z_FS = (Z_SPECMULT - REAL(INT(Z_SPECMULT), JPRB))
        Z_SPECCOMB1(JLAY) = P_COLH2O(JLON, JLAY) + PRAT_H2OCO2_1(JLON, JLAY)*P_COLCO2(JLON, JLAY)
        Z_SPECPARM1 = P_COLH2O(JLON, JLAY)/Z_SPECCOMB1(JLAY)
        IF (Z_SPECPARM1 >= P_ONEMINUS) Z_SPECPARM1 = P_ONEMINUS
        Z_SPECMULT1 = 8._JPRB*(Z_SPECPARM1)
        JS1 = 1 + INT(Z_SPECMULT1)
        Z_FS1 = (Z_SPECMULT1 - REAL(INT(Z_SPECMULT1), JPRB))
        Z_SPECCOMB_PLANCK(JLAY) = P_COLH2O(JLON, JLAY) + ZREFRAT_PLANCK_A*P_COLCO2(JLON, JLAY)
        Z_SPECPARM_PLANCK = P_COLH2O(JLON, JLAY)/Z_SPECCOMB_PLANCK(JLAY)
        IF (Z_SPECPARM_PLANCK >= P_ONEMINUS) Z_SPECPARM_PLANCK = P_ONEMINUS
        Z_SPECMULT_PLANCK = 8._JPRB*Z_SPECPARM_PLANCK
        JPL = 1 + INT(Z_SPECMULT_PLANCK)
        Z_FPL = (Z_SPECMULT_PLANCK - REAL(INT(Z_SPECMULT_PLANCK), JPRB))
        IND0(JLAY) = ((K_JP(JLON, JLAY) - 1)*5 + (K_JT(JLON, JLAY) - 1))*owned_reference%nspa(12) + JS
        IND1(JLAY) = (K_JP(JLON, JLAY)*5 + (K_JT1(JLON, JLAY) - 1))*owned_reference%nspa(12) + JS1
        INDS(JLAY) = K_INDSELF(JLON, JLAY)
        INDF(JLAY) = K_INDFOR(JLON, JLAY)
        IF (Z_SPECPARM < 0.125_JPRB) THEN
          ZP = Z_FS - 1
          ZP4 = ZP**4
          ZFK0 = ZP4
          ZFK1 = 1 - ZP - 2.0_JPRB*ZP4
          ZFK2 = ZP + ZP4
          Z_FAC000 = ZFK0*P_FAC00(JLON, JLAY)
          Z_FAC100 = ZFK1*P_FAC00(JLON, JLAY)
          Z_FAC200 = ZFK2*P_FAC00(JLON, JLAY)
          Z_FAC010 = ZFK0*P_FAC10(JLON, JLAY)
          Z_FAC110 = ZFK1*P_FAC10(JLON, JLAY)
          Z_FAC210 = ZFK2*P_FAC10(JLON, JLAY)
        ELSEIF (Z_SPECPARM > 0.875_JPRB) THEN
          ZP = -Z_FS
          ZP4 = ZP**4
          ZFK0 = ZP4
          ZFK1 = 1 - ZP - 2.0_JPRB*ZP4
          ZFK2 = ZP + ZP4
          Z_FAC000 = ZFK0*P_FAC00(JLON, JLAY)
          Z_FAC100 = ZFK1*P_FAC00(JLON, JLAY)
          Z_FAC200 = ZFK2*P_FAC00(JLON, JLAY)
          Z_FAC010 = ZFK0*P_FAC10(JLON, JLAY)
          Z_FAC110 = ZFK1*P_FAC10(JLON, JLAY)
          Z_FAC210 = ZFK2*P_FAC10(JLON, JLAY)
        ELSE
          Z_FAC000 = (1._JPRB - Z_FS)*P_FAC00(JLON, JLAY)
          Z_FAC010 = (1._JPRB - Z_FS)*P_FAC10(JLON, JLAY)
          Z_FAC100 = Z_FS*P_FAC00(JLON, JLAY)
          Z_FAC110 = Z_FS*P_FAC10(JLON, JLAY)
        END IF
        IF (Z_SPECPARM1 < 0.125_JPRB) THEN
          ZP = Z_FS1 - 1
          ZP4 = ZP**4
          ZFK0 = ZP4
          ZFK1 = 1 - ZP - 2.0_JPRB*ZP4
          ZFK2 = ZP + ZP4
          Z_FAC001 = ZFK0*P_FAC01(JLON, JLAY)
          Z_FAC101 = ZFK1*P_FAC01(JLON, JLAY)
          Z_FAC201 = ZFK2*P_FAC01(JLON, JLAY)
          Z_FAC011 = ZFK0*P_FAC11(JLON, JLAY)
          Z_FAC111 = ZFK1*P_FAC11(JLON, JLAY)
          Z_FAC211 = ZFK2*P_FAC11(JLON, JLAY)
        ELSEIF (Z_SPECPARM1 > 0.875_JPRB) THEN
          ZP = -Z_FS1
          ZP4 = ZP**4
          ZFK0 = ZP4
          ZFK1 = 1 - ZP - 2.0_JPRB*ZP4
          ZFK2 = ZP + ZP4
          Z_FAC001 = ZFK0*P_FAC01(JLON, JLAY)
          Z_FAC101 = ZFK1*P_FAC01(JLON, JLAY)
          Z_FAC201 = ZFK2*P_FAC01(JLON, JLAY)
          Z_FAC011 = ZFK0*P_FAC11(JLON, JLAY)
          Z_FAC111 = ZFK1*P_FAC11(JLON, JLAY)
          Z_FAC211 = ZFK2*P_FAC11(JLON, JLAY)
        ELSE
          Z_FAC001 = (1._JPRB - Z_FS1)*P_FAC01(JLON, JLAY)
          Z_FAC011 = (1._JPRB - Z_FS1)*P_FAC11(JLON, JLAY)
          Z_FAC101 = Z_FS1*P_FAC01(JLON, JLAY)
          Z_FAC111 = Z_FS1*P_FAC11(JLON, JLAY)
        END IF
        DO IG = 1, owned_coefficients%ngc(12)
  ZTAUSELF = P_SELFFAC(JLON,JLAY)* (owned_coefficients%b12_selfref(INDS(JLAY),IG) + P_SELFFRAC(JLON,JLAY) * (owned_coefficients%b12_selfref(INDS(JLAY)+1,IG) - owned_coefficients%b12_selfref(INDS(JLAY),IG)))
  ZTAUFOR = P_FORFAC(JLON,JLAY) * (owned_coefficients%b12_forref(INDF(JLAY),IG) + P_FORFRAC(JLON,JLAY) * (owned_coefficients%b12_forref(INDF(JLAY)+1,IG) - owned_coefficients%b12_forref(INDF(JLAY),IG)))
          IF (Z_SPECPARM < 0.125_JPRB) THEN
  ZTAU_MAJOR = Z_SPECCOMB(JLAY) * (Z_FAC000 * ABSA(IND0(JLAY),IG) + Z_FAC100 * ABSA(IND0(JLAY)+1,IG) + Z_FAC200 * ABSA(IND0(JLAY)+2,IG) + Z_FAC010 * ABSA(IND0(JLAY)+9,IG) + Z_FAC110 * ABSA(IND0(JLAY)+10,IG) + Z_FAC210 * ABSA(IND0(JLAY)+11,IG))
          ELSEIF (Z_SPECPARM > 0.875_JPRB) THEN
  ZTAU_MAJOR = Z_SPECCOMB(JLAY) * (Z_FAC200 * ABSA(IND0(JLAY)-1,IG) + Z_FAC100 * ABSA(IND0(JLAY),IG) + Z_FAC000 * ABSA(IND0(JLAY)+1,IG) + Z_FAC210 * ABSA(IND0(JLAY)+8,IG) + Z_FAC110 * ABSA(IND0(JLAY)+9,IG) + Z_FAC010 * ABSA(IND0(JLAY)+10,IG))
          ELSE
  ZTAU_MAJOR = Z_SPECCOMB(JLAY) * (Z_FAC000 * ABSA(IND0(JLAY),IG) + Z_FAC100 * ABSA(IND0(JLAY)+1,IG) + Z_FAC010 * ABSA(IND0(JLAY)+9,IG) + Z_FAC110 * ABSA(IND0(JLAY)+10,IG))
          END IF
          IF (Z_SPECPARM1 < 0.125_JPRB) THEN
  ZTAU_MAJOR1 = Z_SPECCOMB1(JLAY) * (Z_FAC001 * ABSA(IND1(JLAY),IG) + Z_FAC101 * ABSA(IND1(JLAY)+1,IG) + Z_FAC201 * ABSA(IND1(JLAY)+2,IG) + Z_FAC011 * ABSA(IND1(JLAY)+9,IG) + Z_FAC111 * ABSA(IND1(JLAY)+10,IG) + Z_FAC211 * ABSA(IND1(JLAY)+11,IG))
          ELSEIF (Z_SPECPARM1 > 0.875_JPRB) THEN
  ZTAU_MAJOR1 = Z_SPECCOMB1(JLAY) * (Z_FAC201 * ABSA(IND1(JLAY)-1,IG) + Z_FAC101 * ABSA(IND1(JLAY),IG) + Z_FAC001 * ABSA(IND1(JLAY)+1,IG) + Z_FAC211 * ABSA(IND1(JLAY)+8,IG) + Z_FAC111 * ABSA(IND1(JLAY)+9,IG) + Z_FAC011 * ABSA(IND1(JLAY)+10,IG))
          ELSE
  ZTAU_MAJOR1 = Z_SPECCOMB1(JLAY) * (Z_FAC001 * ABSA(IND1(JLAY),IG) + Z_FAC101 * ABSA(IND1(JLAY)+1,IG) + Z_FAC011 * ABSA(IND1(JLAY)+9,IG) + Z_FAC111 * ABSA(IND1(JLAY)+10,IG))
          END IF
      P_TAU(JLON, owned_coefficients%ngs(11) + IG, JLAY) = ZTAU_MAJOR + ZTAU_MAJOR1 + ZTAUSELF + ZTAUFOR + P_TAUAERL(JLON, JLAY, 12)
  PFRAC(JLON,owned_coefficients%ngs(11)+IG,JLAY) = owned_coefficients%b12_fracrefa(IG,JPL) + Z_FPL * (owned_coefficients%b12_fracrefa(IG,JPL+1) - owned_coefficients%b12_fracrefa(IG,JPL))
        END DO
      END IF
      IF (JLAY > K_LAYTROP(JLON)) THEN
      DO IG = 1, owned_coefficients%ngc(12)
        P_TAU(JLON, owned_coefficients%ngs(11) + IG, JLAY) = P_TAUAERL(JLON, JLAY, 12)
        PFRAC(JLON, owned_coefficients%ngs(11) + IG, JLAY) = 0.0_JPRB
      END DO
      END IF
      END DO
      END DO
    END ASSOCIATE
  end subroutine rrtm_taumol12
end module native_rrtm_taumol12
