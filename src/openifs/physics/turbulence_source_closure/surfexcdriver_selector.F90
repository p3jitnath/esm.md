!> Native surface selector; parameter records are borrowed read-only.
!! FP64 arrays retain source shapes and units. Only active rows mutate.
!! Outputs are INOUT, preserving inactive cells; status2 refuses bounds.
MODULE surfexcdriver_native_selector
  implicit none
  private
  public :: surfexcdriver
contains
! input data, non-tiled
! input data, soil
! input data, tiled
! updated data, tiled
! updated data, non-tiled
! output data, tiled
! output data, non-tiled
! output data, non-tiled CO2
! output canopy and bare soild resistance
! output data, diagnostics
  SUBROUTINE SURFEXCDRIVER(thermal, stability, YDSURF, CDCONF &
   & , KIDIA, KFDIA, KLON, KLEVS, KTILES, KVTYPES, KDIAG, KSTEP &
   & , KLEVSN, KLEVI, KDHVTLS, KDHFTLS, KDHVTSS, KDHFTSS &
   & , KDHVTTS, KDHFTTS, KDHVTIS, KDHFTIS, K_VMASS &
   & , KDHVCO2S, KDHFCO2S, KDHVVEGS, KDHFVEGS &
   & , PTSTEP, PTSTEPF &
   & , KTVL, KCO2TYP, KTVH, PCVL, PCVH, PCUR &
   & , PLAIL, PLAIH, PFWET, PLAT &
   & , PSNM, PRSN &
   & , PMU0, PCARDI &
   & , PUMLEV, PVMLEV, PTMLEV, PQMLEV, PCMLEV, PAPHMS, PGEOMLEV, PCPTGZLEV &
   & , PSST, PTSKM1M, PCHAR, PCHARHQ, PSSRFL, PSLRFL, PEMIS, PTICE, PTSN &
   & , PHLICE, PTLICE, PTLWML &
   & , PTHKICE, PSNTICE &
   & , PWLMX, PUCURR, PVCURR, PI10FGCV &
   & , PTSAM1M, PWSAM1M, KSOTY &
   & , PFRTI, PALBTI &
   & , PUSTRTI, PVSTRTI, PAHFSTI, PEVAPTI, PTSKTI &
   & , PANDAYVT, PANFMVT &
   & , PZ0M, PZ0H &
   & , PSSRFLTI, PQSTI, PDQSTI, PCPTSTI, PCFHTI, PCFQTI, PCSATTI, PCAIRTI &
   & , PCPTSTIU, PCSATTIU, PCAIRTIU, PRAQTI, PTSRF, PLAMSK &
   & , PKHLEV, PKCLEV, PCFMLEV, PKMFL, PKHFL, PKQFL, PEVAPSNW &
   & , PZ0MW, PZ0HW, PZ0QW, PBLENDPP, PCPTSPP, PQSAPP, PBUOMPP, PZDLPP &
   & , PAN, PAG, PRD, PRSOIL_STR, PRECO, PCO2FLUX, PCH4FLUX&
   & , PWETB, PWETL, PWETLU, PWETH, PWETHS &
   & , PDHTLS, PDHTSS, PDHTTS, PDHTIS &
   & , PDHVEGS, PEXDIAG, PDHCO2S &
   & , PRPLRG &
   & , LSICOUP &
   & , status)

    USE PARKIND1, ONLY: JPIM, JPRB, JPRD

!ifndef INTERFACE

    USE YOS_SURF, ONLY: TSURF
    USE owned_ecmwf_thermal_state_port, ONLY: thermal_parameter_record, stability_parameter_record

    USE forecast_native_surface_exchange_controller, ONLY: surfexcdriver_ctl

!endif INTERFACE
! (C) Copyright 2005- ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction.
!------------------------------------------------------------------------

!  PURPOSE:
!    Routine SURFEXCDRIVER controls the ensemble of routines that prepare
!    the surface exchange coefficients and associated surface quantities
!    needed for the solution of the vertical diffusion equations.

!  SURFEXCDRIVER is called by VDFMAIN

!  METHOD:
!    This routine is only a shell needed by the surface library
!    externalisation.

!  AUTHOR:
!    P. Viterbo       ECMWF May 2005

!  REVISION HISTORY:
!    E. Dutra/G. Balsamo May 2008 Add lake tile
!    S. Boussetta/G.Balsamo May 2009 Add lai
!    S. Boussetta/G.Balsamo May 2010 Add CTESSEL
!    N. Semane  04-10-2012  Include small planet PRPLRG
!    Linus Magnusson     10-09-28 Sea-ice

!  INTERFACE:

!    Characters (In):
!      CDCONF   :    IFS Configuration

!    Integers (In):
!      KIDIA    :    Begin point in arrays
!      KFDIA    :    End point in arrays
!      KLON     :    Length of arrays
!      KLEVS    :    Number of soil layers
!      KTILES   :    Number of tiles
!      KVTYPES  :    Number of biomes for carbon
!      KDIAG    :    Number of diagnostic parameters
!      KSTEP    :    Time step index
!      KLEVSN   :    Number of snow layers (diagnostics)
!      KLEVI    :    Number of sea ice layers (diagnostics)
!      KDHVTLS  :    Number of variables for individual tiles
!      KDHFTLS  :    Number of fluxes for individual tiles
!      KDHVTSS  :    Number of variables for snow energy budget
!      KDHFTSS  :    Number of fluxes for snow energy budget
!      KDHVTTS  :    Number of variables for soil energy budget
!      KDHFTTS  :    Number of fluxes for soil energy budget
!      KDHVTIS  :    Number of variables for sea ice energy budget
!      KDHFTIS  :    Number of fluxes for sea ice energy budget
!      K_VMASS  :    Controls the use of vector functions in the IBM scientific
!                     library. Set K_VMASS=0 to use standard functions
!      KTVL     :    Dominant low vegetation type
!      KCO2TYP :    Type of photosynthetic pathway for low vegetation (c3/c4)
!      KTVH     :    Dominant high vegetation type
!      KSOTY    :    SOIL TYPE                                        (1-7)

!    *KDHVCO2S*     Number of variables for CO2
!    *KDHFCO2S*     Number of fluxes for CO2
!    *KDHVVEGS*     Number of variables for vegetation
!    *KDHFVEGS*     Number of fluxes for vegetation

!    Reals (In):
!      PTSTEP   :    Timestep
!      PCVL     :    Low vegetation fraction
!      PCVH     :    High vegetation fraction
!      PCUR     :    Urban cover                                      (0-1)
!      PLAIL    :    Low vegetation LAI
!      PLAIH    :    High vegetation LAI

!     PSNM      :       SNOW MASS (per unit area)                      kg/m**2
!     PRSN      :      SNOW DENSITY                                   kg/m**3

!      PMU0          : COS SOLAR angle
!      PCARDI        : CONCENTRATION ATMOSPHERIC CO2
!      PRPLRG    :   ! GRAVITY SMALL PLANET FACTOR

!    Reals with tile index (In):
!      PFRTI    :    TILE FRACTIONS                                   (0-1)
!            1 : WATER                  5 : SNOW ON LOW-VEG+BARE-SOIL
!            2 : ICE                    6 : DRY SNOW-FREE HIGH-VEG
!            3 : WET SKIN               7 : SNOW UNDER HIGH-VEG
!            4 : DRY SNOW-FREE LOW-VEG  8 : BARE SOIL
!      PALBTI   :    Tile albedo                                      (0-1)

!    Reals independent of tiles (In):
!      PUMLEV   :    X-VELOCITY COMPONENT, lowest atmospheric level   m/s
!      PVMLEV   :    Y-VELOCITY COMPONENT, lowest atmospheric level   m/s
!      PTMLEV   :    TEMPERATURE,   lowest atmospheric level          K
!      PQMLEV   :    SPECIFIC HUMIDITY                                kg/kg
!      PCMLEV   :    ATMOSPHERIC CO2                                  kg/kg
!      PAPHMS   :    Surface pressure                                 Pa
!      PGEOMLEV :    Geopotential, lowest atmospehric level           m2/s2
!      PCPTGZLEV:    Geopotential, lowest atmospehric level           J/kg
!      PSST     :    (OPEN) SEA SURFACE TEMPERATURE                   K
!      PTSKM1M  :    SKIN TEMPERATURE                                 K
!      PCHAR    :    CHARNOCK PARAMETER                               -
!      PCHARHQ  :    CHARNOCK PARAMETER FOR HEAT AND MOISTURE         -
!      PSSRFL   :    NET SHORTWAVE RADIATION FLUX AT SURFACE          W/m2
!      PSLRFL   :    NET LONGWAVE RADIATION FLUX AT SURFACE           W/m2
!      PEMIS    :    MODEL SURFACE LONGWAVE EMISSIVITY
!      PTSAM1M  :    SURFACE TEMPERATURE                              K
!      PWSAM1M  :    SOIL MOISTURE ALL LAYERS                         m**3/m**3
!      PTICE    :    Ice temperature, top slab                        K
!      PTSN     :    Snow temperature                                 K
!      PHLICE   :    Lake ice thickness                               m
!      PTLICE   :    Lake ice temperature                             K
!      PTLWML   :    Lake mean water temperature                      K
!      PTHKICE  :    Sea-ice thickness                                m
!      PSNTICE  :    Snow thickness on sea-ice                        m
!      PWLMX    :    Maximum interception layer capacity              kg/m**2
!      PUCURR   :    u component of ocean surface current             m/s
!      PVCURR   :    v component of ocean surface current             m/s
!      PI10FGCV :    gust velocity from deep convection               m/s

!    Reals with tile index (In/Out):
!      PUSTRTI  :    SURFACE U-STRESS                                 N/m2
!      PVSTRTI  :    SURFACE V-STRESS                                 N/m2
!      PAHFSTI  :    SURFACE SENSIBLE HEAT FLUX                       W/m2
!      PEVAPTI  :    SURFACE MOISTURE FLUX                            KG/m2/s
!      PTSKTI   :    SKIN TEMPERATURE                                 K

!            UPDATED PARAMETERS FOR VEGETATION TYPES (REAL):
!      PANDAYVT :    DAILY NET CO2 ASSIMILATION OVER CANOPY           kg_CO2/m**2
!      PANFMVT  :    MAXIMUM LEAF ASSIMILATION                        kg_CO2/kg_Air m/s

!    Reals independent of tiles (In/Out):
!      PZ0M     :    AERODYNAMIC ROUGHNESS LENGTH                     m
!      PZ0H     :    ROUGHNESS LENGTH FOR HEAT                        m

!    Reals with tile index (Out):
!      PSSRFLTI :    Tiled NET SHORTWAVE RADIATION FLUX AT SURFACE    W/m2
!      PQSTI    :    Tiled SATURATION Q AT SURFACE                    kg/kg
!      PDQSTI   :    Tiled DERIVATIVE OF SATURATION Q-CURVE           kg/kg/K
!      PCPTSTI  :    Tiled DRY STATIC ENERGY AT SURFACE               J/kg
!      PCFHTI   :    Tiled EXCHANGE COEFFICIENT AT THE SURFACE        ????
!      PCFQTI   :    Tiled EXCHANGE COEFFICIENT AT THE SURFACE        ????
!      PCSATTI  :    MULTIPLICATION FACTOR FOR QS AT SURFACE          -
!                      FOR SURFACE FLUX COMPUTATION
!      PCAIRTI  :    MULTIPLICATION FACTOR FOR Q AT  LOWEST MODEL     -
!                      LEVEL FOR SURFACE FLUX COMPUTATION
!      PCPTSTIU :    AS PCPTSTI FOR UNSTRESSED LOW VEGETATION         J/kg
!      PCSATTIU :    AS PCSATTI FOR UNSTRESSED LOW VEGETATION         -
!      PCAIRTIU :    AS PCAIRTI FOR UNSTRESSED LOW VEGETATION         -
!      PRAQTI   :    Aerodynamic resistance                           -
!      PTSRF    :    Tiled surface temperature for each tile
!                    Boundary condition in surfseb                    K
!      PLAMSK   :    Tiled skin layer conductivity                    W m-2 K-1

!    Reals independent of tiles (Out):
!      PKHLEV   :    SURFACE LAYER: CH*U                              m/s
!      PKCLEV   :    SURFACE LAYER: Cc*U  tracer transfer             m/s
!      PCFMLEV  :    PROP. TO EXCH. COEFF. FOR MOMENTUM               ????
!                     (C-STAR IN DOC.) (SURFACE LAYER ONLY)
!      PKMFL    :    Kinematic momentum flux                          ????
!      PKHFL    :    Kinematic heat flux                              ????
!      PKQFL    :    Kinematic moisture flux                          ????
!      PEVAPSNW :    Evaporation from snow under forest               kgm-2s-1
!      PZ0MW    :    Roughness length for momentum, WMO station       m
!      PZ0HW    :    Roughness length for heat, WMO station           m
!      PZ0QW    :    Roughness length for moisture, WMO station       m
!      PBLENDPP :    Blending weight for 10 m wind postprocessing     m
!      PCPTSPP  :    Cp*Ts for post-processing of weather parameters  J/kg
!      PQSAPP   :    Apparent surface humidity for post-processing    kg/kg
!                     of weather parameters
!      PBUOMPP  :    Buoyancy flux, for post-processing of gustiness  ????
!      PZDLPP   :    z/L for post-processing of weather parameters    -
!      PDHTLS   :    Diagnostic array for tiles (see module yomcdh)
!                      (Wm-2 for energy fluxes, kg/(m2s) for water fluxes)
!      PDHTSS   :    Diagnostic array for snow T (see module yomcdh)
!                      (Wm-2 for fluxes)
!      PDHTTS   :    Diagnostic array for soil T (see module yomcdh)
!                      (Wm-2 for fluxes)
!      PDHTIS   :    Diagnostic array for ice T (see module yomcdh)
!                      (Wm-2 for fluxes)

!     *PDHVEGS*      Diagnostic array for vegetation (see module yomcdh)
!     *PEXDIAG*      Diagnostic array for optional pp of canopy resistances
!     *PDHCO2S*      Diagnostic array for CO2 (see module yomcdh)
!       PWETB        Surface resistance bare soild
!       PWETL        Canopy resistance of low vegetation
!       PWETLU       Canopy resistance of low vegetation , unstressed
!       PWETH        Canopy resistance of high vegetation
!       PWETHS       Canopy resistance of high vegetation snow cover

!     EXTERNALS.
!     ----------

!     ** SURFEXCDRIVER_CTL CALLS SUCCESSIVELY:
!         *VUPDZ0*
!         *VSURF*
!         *CO2*
!         *VEXCS*
!         *VEVAP*
!         *VSFLX*

!  DOCUMENTATION:
!    See Physics Volume of IFS documentation

!------------------------------------------------------------------------

    IMPLICIT NONE

! Declaration of arguments

    TYPE(TSURF), INTENT(IN) :: YDSURF
    TYPE(thermal_parameter_record), INTENT(IN) :: thermal
    TYPE(stability_parameter_record), INTENT(IN) :: stability
    INTEGER(KIND=JPIM), INTENT(OUT) :: status

    CHARACTER(LEN=1), INTENT(IN) :: CDCONF

    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVS
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
    INTEGER(KIND=JPIM), INTENT(IN) :: KVTYPES
    INTEGER(KIND=JPIM), INTENT(IN) :: KDIAG
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTEP
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVSN
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVI
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHVTLS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHFTLS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHVTSS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHFTSS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHVTTS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHFTTS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHVTIS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHFTIS
    INTEGER(KIND=JPIM), INTENT(IN) :: K_VMASS
    REAL(KIND=JPRB), INTENT(IN) :: PTSTEP
    REAL(KIND=JPRB), INTENT(IN) :: PTSTEPF
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVL(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVH(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KSOTY(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHVCO2S
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHFCO2S
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHVVEGS
    INTEGER(KIND=JPIM), INTENT(IN) :: KDHFVEGS
    REAL(KIND=JPRB), INTENT(IN) :: PCVL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCVH(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCUR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAIL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAIH(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFWET(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAT(:)
    REAL(KIND=JPRB), INTENT(IN) :: PSNM(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PRSN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCARDI
    REAL(KIND=JPRB), INTENT(IN) :: PUMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCPTGZLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PSST(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(:)
    REAL(KIND=JPRB), INTENT(IN) :: PHLICE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTLICE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTLWML(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTHKICE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PSNTICE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCHAR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCHARHQ(:)
    REAL(KIND=JPRB), INTENT(IN) :: PSSRFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PSLRFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PEMIS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTICE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PWLMX(:)
    REAL(KIND=JPRB), INTENT(IN) :: PUCURR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVCURR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PI10FGCV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PWSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PALBTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PUSTRTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVSTRTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAHFSTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEVAPTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTSKTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PANDAYVT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PANFMVT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0M(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0H(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSSRFLTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDQSTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTSTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCFHTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCFQTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCSATTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAIRTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTSTIU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCSATTIU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAIRTIU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRAQTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTSRF(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLAMSK(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKHLEV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKCLEV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCFMLEV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKMFL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKHFL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKQFL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEVAPSNW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0MW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0HW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0QW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PBLENDPP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTSPP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSAPP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PBUOMPP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZDLPP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSOIL_STR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRECO(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCO2FLUX(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCH4FLUX(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHVEGS(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEXDIAG(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHCO2S(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHTLS(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHTSS(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHTTS(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHTIS(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PRPLRG
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETB(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETLU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETH(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETHS(:)

    LOGICAL, INTENT(IN) :: LSICOUP
!ifndef INTERFACE

    status = 2
    if (klon < 1 .or. klon > 4096 .or. kidia < 1 .or. kfdia > klon .or. kfdia < kidia - 1) return

    IF (UBOUND(KTVL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(KCO2TYP, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(KTVH, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCVL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCVH, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCUR, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PLAIL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PLAIH, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PSNM, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PSNM, 2) < KLEVSN) THEN
      return
    END IF

    IF (UBOUND(PRSN, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PRSN, 2) < KLEVSN) THEN
      return
    END IF

    IF (UBOUND(PMU0, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PUMLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PVMLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTMLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PQMLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCMLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PAPHMS, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PGEOMLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCPTGZLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PSST, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTSKM1M, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCHAR, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCHARHQ, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PSSRFL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PSLRFL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PEMIS, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTICE, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTSN, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTSN, 2) < KLEVSN) THEN
      return
    END IF

    IF (UBOUND(PWLMX, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PUCURR, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PVCURR, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTSAM1M, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTSAM1M, 2) < KLEVS) THEN
      return
    END IF

    IF (UBOUND(PWSAM1M, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PWSAM1M, 2) < KLEVS) THEN
      return
    END IF

    IF (UBOUND(KSOTY, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PFRTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PFRTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PALBTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PALBTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PUSTRTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PUSTRTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PVSTRTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PVSTRTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PAHFSTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PAHFSTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PEVAPTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PEVAPTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PTSKTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTSKTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PANDAYVT, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PANDAYVT, 2) < KVTYPES) THEN
      return
    END IF

    IF (UBOUND(PANFMVT, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PANFMVT, 2) < KVTYPES) THEN
      return
    END IF

    IF (UBOUND(PZ0M, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PZ0H, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PSSRFLTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PSSRFLTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PQSTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PQSTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PDQSTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PDQSTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCPTSTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCPTSTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCFHTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCFHTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCFQTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCFQTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCSATTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCSATTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCAIRTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCAIRTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCPTSTIU, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCPTSTIU, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCSATTIU, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCSATTIU, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PCAIRTIU, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCAIRTIU, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PRAQTI, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PRAQTI, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PTSRF, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTSRF, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PLAMSK, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PLAMSK, 2) < KTILES) THEN
      return
    END IF

    IF (UBOUND(PKHLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PKCLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCFMLEV, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PKMFL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PKHFL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PKQFL, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PEVAPSNW, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PZ0MW, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PZ0HW, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PZ0QW, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PBLENDPP, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PCPTSPP, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PQSAPP, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PBUOMPP, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PZDLPP, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHTLS) > 0 .AND. UBOUND(PDHTLS, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHTLS) > 0 .AND. UBOUND(PDHTLS, 2) < KTILES) THEN
      return
    END IF

    IF (SIZE(PDHTLS) > 0 .AND. UBOUND(PDHTLS, 3) < KDHVTLS + KDHFTLS) THEN
      return
    END IF

    IF (SIZE(PDHTSS) > 0 .AND. UBOUND(PDHTSS, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHTSS) > 0 .AND. UBOUND(PDHTSS, 2) < KLEVSN) THEN
      return
    END IF

    IF (SIZE(PDHTSS) > 0 .AND. UBOUND(PDHTSS, 3) < KDHVTSS + KDHFTSS) THEN
      return
    END IF

    IF (SIZE(PDHTTS) > 0 .AND. UBOUND(PDHTTS, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHTTS) > 0 .AND. UBOUND(PDHTTS, 2) < KLEVS) THEN
      return
    END IF

    IF (SIZE(PDHTTS) > 0 .AND. UBOUND(PDHTTS, 3) < KDHVTTS + KDHFTTS) THEN
      return
    END IF

    IF (SIZE(PDHTIS) > 0 .AND. UBOUND(PDHTIS, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHTIS) > 0 .AND. UBOUND(PDHTIS, 2) < KLEVI) THEN
      return
    END IF

    IF (SIZE(PDHTIS) > 0 .AND. UBOUND(PDHTIS, 3) < KDHVTIS + KDHFTIS) THEN
      return
    END IF

    IF (UBOUND(PHLICE, 1) < KLON) THEN
      return
    END IF
    IF (UBOUND(PTLICE, 1) < KLON) THEN
      return
    END IF
    IF (UBOUND(PTLWML, 1) < KLON) THEN
      return
    END IF

    IF (UBOUND(PTHKICE, 1) < KLON) THEN
      return
    END IF
    IF (UBOUND(PSNTICE, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHCO2S) > 0 .AND. UBOUND(PDHCO2S, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHCO2S) > 0 .AND. UBOUND(PDHCO2S, 2) < 2) THEN !nb vegetation tiles
      return
    END IF

    IF (SIZE(PDHCO2S) > 0 .AND. UBOUND(PDHCO2S, 3) < KDHVCO2S + KDHFCO2S) THEN
      return
    END IF

    IF (SIZE(PDHVEGS) > 0 .AND. UBOUND(PDHVEGS, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PDHVEGS) > 0 .AND. UBOUND(PDHVEGS, 2) < 2) THEN !nb vegetation tiles
      return
    END IF

    IF (SIZE(PDHVEGS) > 0 .AND. UBOUND(PDHVEGS, 3) < KDHVVEGS + KDHFVEGS) THEN
      return
    END IF

    IF (UBOUND(PWETB, 1) < KLON) THEN
      return
    END IF
    IF (UBOUND(PWETL, 1) < KLON) THEN
      return
    END IF
    IF (UBOUND(PWETLU, 1) < KLON) THEN
      return
    END IF
    IF (UBOUND(PWETH, 1) < KLON) THEN
      return
    END IF
    IF (UBOUND(PWETHS, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PEXDIAG) > 0 .AND. UBOUND(PEXDIAG, 1) < KLON) THEN
      return
    END IF

    IF (SIZE(PEXDIAG) > 0 .AND. UBOUND(PEXDIAG, 2) < KDIAG) THEN
      return
    END IF

!the diagnostics are not needed in SURFEXCDRIVER_CTL
!    *KDHVCO2S*     Number of variables for CO2
!    *KDHFCO2S*     Number of fluxes for CO2
!    *KDHVVEGS*     Number of variables for vegetation
!    *KDHFVEGS*     Number of fluxes for vegetation

    CALL SURFEXCDRIVER_CTL(thermal, stability, CDCONF &
     & , KIDIA, KFDIA, KLON, KLEVS, KTILES, KVTYPES, KDIAG, KSTEP &
     & , KLEVSN, KLEVI, KDHVTLS, KDHFTLS, KDHVTSS, KDHFTSS &
     & , KDHVTTS, KDHFTTS, KDHVTIS, KDHFTIS, K_VMASS &
     & , PTSTEP, PTSTEPF &
     & , KTVL, KCO2TYP, KTVH, PCVL, PCVH, PCUR &
     & , PLAIL, PLAIH, PFWET, PLAT &
     & , PSNM, PRSN &
     & , PMU0, PCARDI &
     & , PUMLEV, PVMLEV, PTMLEV, PQMLEV, PCMLEV, PAPHMS, PGEOMLEV, PCPTGZLEV &
     & , PSST, PTSKM1M, PCHAR, PCHARHQ, PSSRFL, PSLRFL, PEMIS, PTICE, PTSN &
     & , PHLICE, PTLICE, PTLWML &
     & , PTHKICE, PSNTICE &
     & , PWLMX, PUCURR, PVCURR, PI10FGCV  &
     & , PTSAM1M, PWSAM1M, KSOTY &
     & , PFRTI, PALBTI &
     & , PUSTRTI, PVSTRTI, PAHFSTI, PEVAPTI, PTSKTI &
     & , PANDAYVT, PANFMVT &
     & , PZ0M, PZ0H &
     & , PSSRFLTI, PQSTI, PDQSTI, PCPTSTI, PCFHTI, PCFQTI, PCSATTI, PCAIRTI &
     & , PCPTSTIU, PCSATTIU, PCAIRTIU, PRAQTI, PTSRF, PLAMSK &
     & , PKHLEV, PKCLEV, PCFMLEV, PKMFL, PKHFL, PKQFL, PEVAPSNW &
     & , PZ0MW, PZ0HW, PZ0QW, PBLENDPP, PCPTSPP, PQSAPP, PBUOMPP, PZDLPP &
     & , PAN, PAG, PRD, PRSOIL_STR, PRECO, PCO2FLUX, PCH4FLUX&
     & , PWETB, PWETL, PWETLU, PWETH, PWETHS &
     & , PDHTLS, PDHTSS, PDHTTS, PDHTIS &
     & , PDHVEGS, PEXDIAG, PDHCO2S &
     & , PRPLRG &
     & , LSICOUP &
     & , YDSURF%YCST, YDSURF%YEXC, YDSURF%YVEG, YDSURF%YAGS, YDSURF%YAGF, YDSURF%YSOIL, YDSURF%YFLAKE, YDSURF%YURB &
     & , status=status)

!endif INTERFACE

!------------------------------------------------------------------------

  END SUBROUTINE SURFEXCDRIVER

END MODULE surfexcdriver_native_selector
