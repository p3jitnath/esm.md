!> Complete portable longwave band 7 numerical update.
!! Frozen equations and native interfaces are retained from the named source
!! and Markdown contract. All coefficient/reference owners are explicit inputs.
!! Scientific source attribution: AER RRTM and ECMWF OpenIFS RRTM_TAUMOL7.
module native_rrtm_taumol7
  use iso_fortran_env, only: real64, int32
  use iso_fortran_env, only: JPRB => real64, JPIM => int32
  use yomdimv, only: TDIMV
  use native_absorption_records, only: longwave_absorption_reduced_record
  use longwave_reference_parameter_fields_mod, only: longwave_reference_parameter_record
  implicit none
  private
  public :: rrtm_taumol7
contains
  !> Update the band cells of complete (columns,140,level_capacity) owners.
  !! Depth and Planck fraction are dimensionless. Aerosol depth is
  !! (columns,level_capacity,16). Gas columns use the retained 1e20 scale.
  !! Coefficients, reference tables and every declared input stay readonly;
  !! inactive points and level tails retain their incoming values.
  subroutine rrtm_taumol7(owned_reference,owned_coefficients,YDDIMV,KIDIA,KFDIA,KLEV,P_TAU, P_TAUAERL,P_FAC00,P_FAC01,P_FAC10,P_FAC11,P_FORFAC,P_FORFRAC,K_INDFOR,K_JP,K_JT,K_JT1,P_ONEMINUS, P_COLH2O,P_COLO3,P_COLCO2,P_COLDRY,K_LAYTROP,P_SELFFAC,P_SELFFRAC,K_INDSELF,PFRAC, P_RAT_H2OO3, P_RAT_H2OO3_1,PMINORFRAC,KINDMINOR)
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
    REAL(KIND=JPRB), INTENT(IN) :: P_COLO3(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_COLCO2(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_COLDRY(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_LAYTROP(KIDIA:KFDIA)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDSELF(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFRAC(KIDIA:KFDIA, 140, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_RAT_H2OO3(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_RAT_H2OO3_1(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDFOR(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: PMINORFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: KINDMINOR(KIDIA:KFDIA, YDDIMV%NFLEVG)
  REAL(KIND=JPRB) :: Z_SPECCOMB(YDDIMV%NFLEVG),Z_SPECCOMB1(YDDIMV%NFLEVG), Z_SPECCOMB_MCO2(YDDIMV%NFLEVG), Z_SPECCOMB_PLANCK(YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: IND0(YDDIMV%NFLEVG), IND1(YDDIMV%NFLEVG), INDS(YDDIMV%NFLEVG), INDF(YDDIMV%NFLEVG), INDM(YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: IG, JS, JLAY, JS1, JPL, JMCO2
    INTEGER(KIND=JPIM) :: JLON
    REAL(KIND=JPRB) :: ZREFRAT_PLANCK_A, ZREFRAT_M_A
    REAL(KIND=JPRB) :: ZCHI_CO2, ZRATCO2, ZADJFAC, ZADJCOLCO2(KIDIA:KFDIA, YDDIMV%NFLEVG)
  REAL(KIND=JPRB) ::  Z_FAC000, Z_FAC100, Z_FAC200, Z_FAC010, Z_FAC110, Z_FAC210, Z_FAC001, Z_FAC101, Z_FAC201, Z_FAC011, Z_FAC111, Z_FAC211
    REAL(KIND=JPRB) :: ZP, ZP4, ZFK0, ZFK1, ZFK2
    REAL(KIND=JPRB) :: ZTAUFOR, ZTAUSELF, ZTAU_MAJOR, ZTAU_MAJOR1, ZCO2M1, ZCO2M2, ZABSCO2
  REAL(KIND=JPRB) :: Z_FS, Z_SPECMULT, Z_SPECPARM, Z_FS1, Z_SPECMULT1, Z_SPECPARM1, Z_FPL, Z_SPECMULT_PLANCK, Z_SPECPARM_PLANCK, Z_FMCO2, Z_SPECMULT_MCO2, Z_SPECPARM_MCO2
    real(real64), pointer :: absa(:, :)
    real(real64), pointer :: absb(:, :)
    absa(1:585, 1:12) => owned_coefficients%b7_ka
    absb(1:235, 1:12) => owned_coefficients%b7_kb
    ASSOCIATE (NFLEVG => YDDIMV%NFLEVG)
      ZREFRAT_PLANCK_A = owned_reference%chi_mls(1, 3)/owned_reference%chi_mls(3, 3)
      ZREFRAT_M_A = owned_reference%chi_mls(1, 3)/owned_reference%chi_mls(3, 3)
      DO JLAY = 1, KLEV
      DO JLON = KIDIA, KFDIA
      IF (JLAY <= K_LAYTROP(JLON)) THEN
        Z_SPECCOMB(JLAY) = P_COLH2O(JLON, JLAY) + P_RAT_H2OO3(JLON, JLAY)*P_COLO3(JLON, JLAY)
        Z_SPECPARM = 1._JPRB/(1._JPRB + P_RAT_H2OO3(JLON, JLAY)/P_COLH2O(JLON, JLAY)*P_COLO3(JLON, JLAY))
        Z_SPECPARM = MIN(P_ONEMINUS, Z_SPECPARM)
        Z_SPECMULT = 8._JPRB*Z_SPECPARM
        JS = 1 + INT(Z_SPECMULT)
        Z_FS = (Z_SPECMULT - REAL(INT(Z_SPECMULT), JPRB))
        Z_SPECCOMB1(JLAY) = P_COLH2O(JLON, JLAY) + P_RAT_H2OO3_1(JLON, JLAY)*P_COLO3(JLON, JLAY)
        Z_SPECPARM1 = 1._JPRB/(1._JPRB + P_RAT_H2OO3_1(JLON, JLAY)/P_COLH2O(JLON, JLAY)*P_COLO3(JLON, JLAY))
        IF (Z_SPECPARM1 >= P_ONEMINUS) Z_SPECPARM1 = P_ONEMINUS
        Z_SPECMULT1 = 8._JPRB*(Z_SPECPARM1)
        JS1 = 1 + INT(Z_SPECMULT1)
        Z_FS1 = (Z_SPECMULT1 - REAL(INT(Z_SPECMULT1), JPRB))
        Z_SPECCOMB_MCO2(JLAY) = P_COLH2O(JLON, JLAY) + ZREFRAT_M_A*P_COLO3(JLON, JLAY)
        Z_SPECPARM_MCO2 = 1._JPRB/(1._JPRB + ZREFRAT_M_A/P_COLH2O(JLON, JLAY)*P_COLO3(JLON, JLAY))
        IF (Z_SPECPARM_MCO2 >= P_ONEMINUS) Z_SPECPARM_MCO2 = P_ONEMINUS
        Z_SPECMULT_MCO2 = 8._JPRB*Z_SPECPARM_MCO2
        JMCO2 = 1 + INT(Z_SPECMULT_MCO2)
        Z_FMCO2 = (Z_SPECMULT_MCO2 - REAL(INT(Z_SPECMULT_MCO2), JPRB))
        ZCHI_CO2 = P_COLCO2(JLON, JLAY)/P_COLDRY(JLON, JLAY)
        ZRATCO2 = 1.E20_JPRB*ZCHI_CO2/owned_reference%chi_mls(2, K_JP(JLON, JLAY) + 1)
        IF (ZRATCO2 > 3.0_JPRB) THEN
          ZADJFAC = 3.0_JPRB + (ZRATCO2 - 3.0_JPRB)**0.79_JPRB
          ZADJCOLCO2(JLON, JLAY) = ZADJFAC*owned_reference%chi_mls(2, K_JP(JLON, JLAY) + 1)*P_COLDRY(JLON, JLAY)*1.E-20_JPRB
        ELSE
          ZADJCOLCO2(JLON, JLAY) = P_COLCO2(JLON, JLAY)
        END IF
        Z_SPECCOMB_PLANCK(JLAY) = P_COLH2O(JLON, JLAY) + ZREFRAT_PLANCK_A*P_COLO3(JLON, JLAY)
        Z_SPECPARM_PLANCK = 1._JPRB/(1._JPRB + ZREFRAT_PLANCK_A/P_COLH2O(JLON, JLAY)*P_COLO3(JLON, JLAY))
        IF (Z_SPECPARM_PLANCK >= P_ONEMINUS) Z_SPECPARM_PLANCK = P_ONEMINUS
        Z_SPECMULT_PLANCK = 8._JPRB*Z_SPECPARM_PLANCK
        JPL = 1 + INT(Z_SPECMULT_PLANCK)
        Z_FPL = (Z_SPECMULT_PLANCK - REAL(INT(Z_SPECMULT_PLANCK), JPRB))
        IND0(JLAY) = ((K_JP(JLON, JLAY) - 1)*5 + (K_JT(JLON, JLAY) - 1))*owned_reference%nspa(7) + JS
        IND1(JLAY) = (K_JP(JLON, JLAY)*5 + (K_JT1(JLON, JLAY) - 1))*owned_reference%nspa(7) + JS1
        INDS(JLAY) = K_INDSELF(JLON, JLAY)
        INDF(JLAY) = K_INDFOR(JLON, JLAY)
        INDM(JLAY) = KINDMINOR(JLON, JLAY)
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
        DO IG = 1, owned_coefficients%ngc(7)
  ZTAUSELF = P_SELFFAC(JLON,JLAY)* (owned_coefficients%b7_selfref(INDS(JLAY),IG) + P_SELFFRAC(JLON,JLAY) * (owned_coefficients%b7_selfref(INDS(JLAY)+1,IG) - owned_coefficients%b7_selfref(INDS(JLAY),IG)))
  ZTAUFOR = P_FORFAC(JLON,JLAY) * (owned_coefficients%b7_forref(INDF(JLAY),IG) + P_FORFRAC(JLON,JLAY) * (owned_coefficients%b7_forref(INDF(JLAY)+1,IG) - owned_coefficients%b7_forref(INDF(JLAY),IG)))
  ZCO2M1 = owned_coefficients%b7_ka_mco2(JMCO2,INDM(JLAY),IG) + Z_FMCO2 * (owned_coefficients%b7_ka_mco2(JMCO2+1,INDM(JLAY),IG) - owned_coefficients%b7_ka_mco2(JMCO2,INDM(JLAY),IG))
  ZCO2M2 = owned_coefficients%b7_ka_mco2(JMCO2,INDM(JLAY)+1,IG) + Z_FMCO2 * (owned_coefficients%b7_ka_mco2(JMCO2+1,INDM(JLAY)+1,IG) - owned_coefficients%b7_ka_mco2(JMCO2,INDM(JLAY)+1,IG))
          ZABSCO2 = ZCO2M1 + PMINORFRAC(JLON, JLAY)*(ZCO2M2 - ZCO2M1)
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
  P_TAU(JLON,owned_coefficients%ngs(6)+IG,JLAY) = ZTAU_MAJOR + ZTAU_MAJOR1 + ZTAUSELF + ZTAUFOR + ZADJCOLCO2(JLON,JLAY)*ZABSCO2 + P_TAUAERL(JLON,JLAY,7)
  PFRAC(JLON,owned_coefficients%ngs(6)+IG,JLAY) = owned_coefficients%b7_fracrefa(IG,JPL) + Z_FPL * (owned_coefficients%b7_fracrefa(IG,JPL+1) - owned_coefficients%b7_fracrefa(IG,JPL))
        END DO
      END IF
      IF (JLAY > K_LAYTROP(JLON)) THEN
        ZCHI_CO2 = P_COLCO2(JLON, JLAY)/P_COLDRY(JLON, JLAY)
        ZRATCO2 = 1.E20_JPRB*ZCHI_CO2/owned_reference%chi_mls(2, K_JP(JLON, JLAY) + 1)
        IF (ZRATCO2 > 3.0_JPRB) THEN
          ZADJFAC = 2.0_JPRB + (ZRATCO2 - 2.0_JPRB)**0.79_JPRB
          ZADJCOLCO2(JLON, JLAY) = ZADJFAC*owned_reference%chi_mls(2, K_JP(JLON, JLAY) + 1)*P_COLDRY(JLON, JLAY)*1.E-20_JPRB
        ELSE
          ZADJCOLCO2(JLON, JLAY) = P_COLCO2(JLON, JLAY)
        END IF
        IND0(JLAY) = ((K_JP(JLON, JLAY) - 13)*5 + (K_JT(JLON, JLAY) - 1))*owned_reference%nspb(7) + 1
        IND1(JLAY) = ((K_JP(JLON, JLAY) - 12)*5 + (K_JT1(JLON, JLAY) - 1))*owned_reference%nspb(7) + 1
        INDM(JLAY) = KINDMINOR(JLON, JLAY)
        DO IG = 1, owned_coefficients%ngc(7)
  ZABSCO2 = owned_coefficients%b7_kb_mco2(INDM(JLAY),IG) + PMINORFRAC(JLON,JLAY) * (owned_coefficients%b7_kb_mco2(INDM(JLAY)+1,IG) - owned_coefficients%b7_kb_mco2(INDM(JLAY),IG))
  P_TAU(JLON,owned_coefficients%ngs(6)+IG,JLAY) = P_COLO3(JLON,JLAY) * (P_FAC00(JLON,JLAY) * ABSB(IND0(JLAY)  ,IG) + P_FAC10(JLON,JLAY) * ABSB(IND0(JLAY)+1,IG) + P_FAC01(JLON,JLAY) * ABSB(IND1(JLAY)  ,IG) + P_FAC11(JLON,JLAY) * ABSB(IND1(JLAY)+1,IG)) + ZADJCOLCO2(JLON,JLAY) * ZABSCO2 + P_TAUAERL(JLON,JLAY,7)
          PFRAC(JLON, owned_coefficients%ngs(6) + IG, JLAY) = owned_coefficients%b7_fracrefb(IG)
        END DO
        P_TAU(JLON, owned_coefficients%ngs(6) + 6, JLAY) = P_TAU(JLON, owned_coefficients%ngs(6) + 6, JLAY)*0.92_JPRB
        P_TAU(JLON, owned_coefficients%ngs(6) + 7, JLAY) = P_TAU(JLON, owned_coefficients%ngs(6) + 7, JLAY)*0.88_JPRB
        P_TAU(JLON, owned_coefficients%ngs(6) + 8, JLAY) = P_TAU(JLON, owned_coefficients%ngs(6) + 8, JLAY)*1.07_JPRB
        P_TAU(JLON, owned_coefficients%ngs(6) + 9, JLAY) = P_TAU(JLON, owned_coefficients%ngs(6) + 9, JLAY)*1.1_JPRB
        P_TAU(JLON, owned_coefficients%ngs(6) + 10, JLAY) = P_TAU(JLON, owned_coefficients%ngs(6) + 10, JLAY)*0.99_JPRB
        P_TAU(JLON, owned_coefficients%ngs(6) + 11, JLAY) = P_TAU(JLON, owned_coefficients%ngs(6) + 11, JLAY)*0.855_JPRB
      END IF
      END DO
      END DO
    END ASSOCIATE
  end subroutine rrtm_taumol7
end module native_rrtm_taumol7
