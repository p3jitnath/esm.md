!> Complete portable longwave band 16 numerical update.
!! Frozen equations and native interfaces are retained from the named source
!! and Markdown contract. All coefficient/reference owners are explicit inputs.
!! Scientific source attribution: AER RRTM and ECMWF OpenIFS RRTM_TAUMOL16.
module native_rrtm_taumol16
  use iso_fortran_env, only: real64, int32
  use iso_fortran_env, only: JPRB => real64, JPIM => int32
  use yomdimv, only: TDIMV
  use native_absorption_records, only: longwave_absorption_reduced_record
  use longwave_reference_parameter_fields_mod, only: longwave_reference_parameter_record
  implicit none
  private
  public :: rrtm_taumol16
contains
  !> Update the band cells of complete (columns,140,level_capacity) owners.
  !! Depth and Planck fraction are dimensionless. Aerosol depth is
  !! (columns,level_capacity,16). Gas columns use the retained 1e20 scale.
  !! Coefficients, reference tables and every declared input stay readonly;
  !! inactive points and level tails retain their incoming values.
  subroutine rrtm_taumol16(owned_reference,owned_coefficients,YDDIMV,KIDIA,KFDIA,KLEV,P_TAU, P_TAUAERL,P_FAC00,P_FAC01,P_FAC10,P_FAC11,P_FORFAC,P_FORFRAC,K_INDFOR,K_JP,K_JT,K_JT1,P_ONEMINUS, P_COLH2O,P_COLCH4,K_LAYTROP,P_SELFFAC,P_SELFFRAC,K_INDSELF,PFRAC, P_RAT_H2OCH4,P_RAT_H2OCH4_1)
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
    REAL(KIND=JPRB), INTENT(IN) :: P_COLCH4(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_LAYTROP(KIDIA:KFDIA)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_SELFFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDSELF(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFRAC(KIDIA:KFDIA, 140, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_RAT_H2OCH4(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_RAT_H2OCH4_1(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM), INTENT(IN) :: K_INDFOR(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    REAL(KIND=JPRB), INTENT(IN) :: P_FORFRAC(KIDIA:KFDIA, YDDIMV%NFLEVG)
    INTEGER(KIND=JPIM) :: IG, IND0, IND1, INDS, INDF, JS, JS1, JPL, JLAY
    INTEGER(KIND=JPIM) :: JLON
  REAL(KIND=JPRB) ::  Z_FAC000, Z_FAC100, Z_FAC200, Z_FAC010, Z_FAC110, Z_FAC210, Z_FAC001, Z_FAC101, Z_FAC201, Z_FAC011, Z_FAC111, Z_FAC211
    REAL(KIND=JPRB) :: ZP, ZP4, ZFK0, ZFK1, ZFK2
    REAL(KIND=JPRB) :: ZREFRAT_PLANCK_A
    REAL(KIND=JPRB) :: ZTAUFOR, ZTAUSELF, ZTAU_MAJOR, ZTAU_MAJOR1
  REAL(KIND=JPRB) :: Z_FS, Z_SPECMULT, Z_SPECPARM,Z_SPECCOMB, Z_FS1, Z_SPECMULT1, Z_SPECPARM1,Z_SPECCOMB1, Z_FPL, Z_SPECMULT_PLANCK, Z_SPECPARM_PLANCK,Z_SPECCOMB_PLANCK
    real(real64), pointer :: absa(:, :)
    real(real64), pointer :: absb(:, :)
    absa(1:585, 1:2) => owned_coefficients%b16_ka
    absb(1:235, 1:2) => owned_coefficients%b16_kb
    ASSOCIATE (NFLEVG => YDDIMV%NFLEVG)
      ZREFRAT_PLANCK_A = owned_reference%chi_mls(1, 6)/owned_reference%chi_mls(6, 6)
      DO JLAY = 1, KLEV
      DO JLON = KIDIA, KFDIA
      IF (JLAY <= K_LAYTROP(JLON)) THEN
        Z_SPECCOMB = P_COLH2O(JLON, JLAY) + P_RAT_H2OCH4(JLON, JLAY)*P_COLCH4(JLON, JLAY)
        Z_SPECPARM = P_COLH2O(JLON, JLAY)/Z_SPECCOMB
        Z_SPECPARM = MIN(Z_SPECPARM, P_ONEMINUS)
        Z_SPECMULT = 8._JPRB*(Z_SPECPARM)
        JS = 1 + INT(Z_SPECMULT)
        Z_FS = (Z_SPECMULT - REAL(INT(Z_SPECMULT), JPRB))
        Z_SPECCOMB1 = P_COLH2O(JLON, JLAY) + P_RAT_H2OCH4_1(JLON, JLAY)*P_COLCH4(JLON, JLAY)
        Z_SPECPARM1 = P_COLH2O(JLON, JLAY)/Z_SPECCOMB1
        IF (Z_SPECPARM1 >= P_ONEMINUS) Z_SPECPARM1 = P_ONEMINUS
        Z_SPECMULT1 = 8._JPRB*(Z_SPECPARM1)
        JS1 = 1 + INT(Z_SPECMULT1)
        Z_FS1 = (Z_SPECMULT1 - REAL(INT(Z_SPECMULT1), JPRB))
        Z_SPECCOMB_PLANCK = P_COLH2O(JLON, JLAY) + ZREFRAT_PLANCK_A*P_COLCH4(JLON, JLAY)
        Z_SPECPARM_PLANCK = P_COLH2O(JLON, JLAY)/Z_SPECCOMB_PLANCK
        IF (Z_SPECPARM_PLANCK >= P_ONEMINUS) Z_SPECPARM_PLANCK = P_ONEMINUS
        Z_SPECMULT_PLANCK = 8._JPRB*Z_SPECPARM_PLANCK
        JPL = 1 + INT(Z_SPECMULT_PLANCK)
        Z_FPL = (Z_SPECMULT_PLANCK - REAL(INT(Z_SPECMULT_PLANCK), JPRB))
        IND0 = ((K_JP(JLON, JLAY) - 1)*5 + (K_JT(JLON, JLAY) - 1))*owned_reference%nspa(16) + JS
        IND1 = (K_JP(JLON, JLAY)*5 + (K_JT1(JLON, JLAY) - 1))*owned_reference%nspa(16) + JS1
        INDS = K_INDSELF(JLON, JLAY)
        INDF = K_INDFOR(JLON, JLAY)
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
        DO IG = 1, owned_coefficients%ngc(16)
  ZTAUSELF = P_SELFFAC(JLON,JLAY)* (owned_coefficients%b16_selfref(INDS,IG) + P_SELFFRAC(JLON,JLAY) * (owned_coefficients%b16_selfref(INDS+1,IG) - owned_coefficients%b16_selfref(INDS,IG)))
  ZTAUFOR = P_FORFAC(JLON,JLAY) * (owned_coefficients%b16_forref(INDF,IG) + P_FORFRAC(JLON,JLAY) * (owned_coefficients%b16_forref(INDF+1,IG) - owned_coefficients%b16_forref(INDF,IG)))
          IF (Z_SPECPARM < 0.125_JPRB) THEN
  ZTAU_MAJOR = Z_SPECCOMB * (Z_FAC000 * ABSA(IND0,IG) + Z_FAC100 * ABSA(IND0+1,IG) + Z_FAC200 * ABSA(IND0+2,IG) + Z_FAC010 * ABSA(IND0+9,IG) + Z_FAC110 * ABSA(IND0+10,IG) + Z_FAC210 * ABSA(IND0+11,IG))
          ELSEIF (Z_SPECPARM > 0.875_JPRB) THEN
  ZTAU_MAJOR = Z_SPECCOMB * (Z_FAC200 * ABSA(IND0-1,IG) + Z_FAC100 * ABSA(IND0,IG) + Z_FAC000 * ABSA(IND0+1,IG) + Z_FAC210 * ABSA(IND0+8,IG) + Z_FAC110 * ABSA(IND0+9,IG) + Z_FAC010 * ABSA(IND0+10,IG))
          ELSE
  ZTAU_MAJOR = Z_SPECCOMB * (Z_FAC000 * ABSA(IND0,IG) + Z_FAC100 * ABSA(IND0+1,IG) + Z_FAC010 * ABSA(IND0+9,IG) + Z_FAC110 * ABSA(IND0+10,IG))
          END IF
          IF (Z_SPECPARM1 < 0.125_JPRB) THEN
  ZTAU_MAJOR1 = Z_SPECCOMB1 * (Z_FAC001 * ABSA(IND1,IG) + Z_FAC101 * ABSA(IND1+1,IG) + Z_FAC201 * ABSA(IND1+2,IG) + Z_FAC011 * ABSA(IND1+9,IG) + Z_FAC111 * ABSA(IND1+10,IG) + Z_FAC211 * ABSA(IND1+11,IG))
          ELSEIF (Z_SPECPARM1 > 0.875_JPRB) THEN
  ZTAU_MAJOR1 = Z_SPECCOMB1 * (Z_FAC201 * ABSA(IND1-1,IG) + Z_FAC101 * ABSA(IND1,IG) + Z_FAC001 * ABSA(IND1+1,IG) + Z_FAC211 * ABSA(IND1+8,IG) + Z_FAC111 * ABSA(IND1+9,IG) + Z_FAC011 * ABSA(IND1+10,IG))
          ELSE
  ZTAU_MAJOR1 = Z_SPECCOMB1 * (Z_FAC001 * ABSA(IND1,IG) + Z_FAC101 * ABSA(IND1+1,IG) + Z_FAC011 * ABSA(IND1+9,IG) + Z_FAC111 * ABSA(IND1+10,IG))
          END IF
      P_TAU(JLON, owned_coefficients%ngs(15) + IG, JLAY) = ZTAU_MAJOR + ZTAU_MAJOR1 + ZTAUSELF + ZTAUFOR + P_TAUAERL(JLON, JLAY, 16)
  PFRAC(JLON,owned_coefficients%ngs(15)+IG,JLAY) = owned_coefficients%b16_fracrefa(IG,JPL) + Z_FPL * (owned_coefficients%b16_fracrefa(IG,JPL+1) - owned_coefficients%b16_fracrefa(IG,JPL))
        END DO
      END IF
      IF (JLAY > K_LAYTROP(JLON)) THEN
        IND0 = ((K_JP(JLON, JLAY) - 13)*5 + (K_JT(JLON, JLAY) - 1))*owned_reference%nspb(16) + 1
        IND1 = ((K_JP(JLON, JLAY) - 12)*5 + (K_JT1(JLON, JLAY) - 1))*owned_reference%nspb(16) + 1
        DO IG = 1, owned_coefficients%ngc(16)
  P_TAU(JLON,owned_coefficients%ngs(15)+IG,JLAY) =  P_COLCH4(JLON,JLAY) * (P_FAC00(JLON,JLAY) * ABSB(IND0,IG) + P_FAC10(JLON,JLAY) * ABSB(IND0+1,IG) + P_FAC01(JLON,JLAY) * ABSB(IND1,IG) + P_FAC11(JLON,JLAY) * ABSB(IND1+1,IG)) + P_TAUAERL(JLON,JLAY,16)
          PFRAC(JLON, owned_coefficients%ngs(15) + IG, JLAY) = owned_coefficients%b16_fracrefb(IG)
        END DO
      END IF
      END DO
      END DO
    END ASSOCIATE
  end subroutine rrtm_taumol16
end module native_rrtm_taumol16
