!> Complete diffusion outer caller: copy, solve and subtract in source order.
!! The readonly current_step comes from the one actual forecast clock.
!! FP64 full-level fields use(P,L); half-level fluxes use(P,0:L).
!! Tendencies are per second. Public owners are INOUT so inactive rows
!! retain their incoming bytes. All stages call the own native VDFMAIN body.
module forecast_native_vertical_diffusion_outer
implicit none
private
public :: vdfouter
contains
! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

 ! OUTPUT
 ! Input tendencies
 ! OUTPUT TENDENCIES
 ! UPDATED FIELDS FOR TILES
 !-UPDATED FIELDS FOR VEGETATION TYPES
 ! OUTPUT FLUXES
 ! DDH OUTPUTS
 ! CO2 VEGETATION FLUX ADJUSTMENT COEFFICIENTS FROM BFAS
SUBROUTINE VDFOUTER(physical,thermal,stability,parameters,physics,surface,spp,controls,planet_scale,rplrg,source_time_step,current_step,CDCONF, &
 & KIDIA, KFDIA, KLON, KLEV, KLEVS, KTILES, KVTYPES, KDIAG, &
 & KTRAC, KCHEM, KAERO, KLEVSN, KLEVI, KDHVTLS, KDHFTLS, KDHVTSS, KDHFTSS, &
 & KDHVTTS, KDHFTTS, KDHVTIS, KDHFTIS, &
 & KDHVCO2S, KDHFCO2S, KDHVVEGS, KDHFVEGS, &
 & PTSPHY, KTVL, KCO2TYP, KTVH, PCVL, PCVH, PCUR, &
 & PLAIL, PLAIH, PFWET, PSNS, PRSN, PMU0, PSIGFLT, &
 & PUM1, PVM1, PTM1, PQM1, PTKE1, PLM1, PIM1, PAM1, PCM1, &
 & PAPHM1, PAPM1, PGEOM1, PGEOH, PGELAT, PTSKM1M, PTSAM1M, PWSAM1M, &
 & PSSRFL, PSLRFL, PEMIS, PHRLW, PHRSW, &
 & PTSNOW, PTICE, &
 & PHLICE, PTLICE, PTLWML, &
 & PSST, KSOTY, PFRTI, PALBTI, PWLMX, &
 & PCHAR, PCHARHQ, PUCURR, PVCURR, PUSTOKES, PVSTOKES, &
 & PTSKRAD, PCFLX, PDDVLC, PSOTEU, PSOTEV, PSOBETA, &
 & PTHKICE, PSNTICE, PGP2DSPP, &
 & LSICOUP, &
 & PZ0M, PZ0H, &
 & PVDIS, PVDISG, PDISGW3D, PAHFLEV, PAHFLSB, PFWSB, &
 & PU10M, PV10M, PT2M, PD2M, PQ2M, PZINV, PBLH, PEIS, &
 & P10NU, P10NV, PUST, &
 & PSSRFLTI, PEVAPSNW, PEVAPMU, PEXDIAG, PGUST, PI10FGCV, KPBLTYPE,&
 & PTE0, PQE0, PLE0, PIE0, PAE0, PVOM0, PVOL0, &
 & PTE, PQE, PLE, PIE, PAE, PVOM, PVOL, PTKEE,&
 & PTENC, PTSKE1, &
 & PUSTRTI, PVSTRTI, PAHFSTI, PEVAPTI, PTSKTI, &
 & PAHFTRTI, &
 & PANDAYVT, PANFMVT,&
 & PDIFTS, PDIFTQ, PDIFTL, PDIFTI, PSTRTU, PSTRTV, PTOFDU, PTOFDV, &
 & PSTRSOU, PSTRSOV, PKH, PKM, PRI, &
 & PAN, PAG, PRD, PRSOIL_STR, PRECO, PCO2FLUX, PCH4FLUX, PCFLXO, &
 & PDHTLS, PDHTSS, PDHTTS, PDHTIS, &
 & PDHCO2S, PDHVEGS, &
 & PCGPP, PCREC, status)

!----compiled for Cray with -Oloop_info loop_trips=small----

!***

!**   *VDFMAIN* - DOES THE VERTICAL EXCHANGE OF U,V,SLG,QT BY TURBULENCE.

!
!     PURPOSE.
!     --------

!          THIS ROUTINE COMPUTES THE PHYSICAL TENDENCIES OF THE FOUR
!     PROGNOSTIC VARIABLES U,V,T AND Q DUE TO THE VERTICAL EXCHANGE BY
!     TURBULENT (= NON-MOIST CONVECTIVE) PROCESSES. THESE TENDENCIES ARE
!     OBTAINED AS THE DIFFERENCE BETWEEN THE RESULT OF AN IMPLICIT
!     TIME-STEP STARTING FROM VALUES AT T-1 AND THESE T-1 VALUES. ALL
!     THE DIAGNOSTIC COMPUTATIONS (EXCHANGE COEFFICIENTS, ...) ARE DONE
!      FROM THE T-1 VALUES. AS A BY-PRODUCT THE ROUGHNESS LENGTH OVER SEA
!     IS UPDATED ACCORDINGLY TO THE *CHARNOCK FORMULA. HEAT AND MOISTURE
!     SURFACE FLUXES AND THEIR DERIVATIVES AGAINST TS, WS AND WL
!     (THE LATTER WILL BE LATER WEIGHTED WITH THE SNOW FACTOR IN
!     *VDIFF*), LATER TO BE USED FOR SOIL PROCESSES TREATMENT, ARE ALSO
!     COMPUTED AS WELL AS A STABILITY VALUE TO BE USED AS A DIAGNOSTIC
!     OF THE DEPTH OF THE WELL MIXED LAYER IN CONVECTIVE COMPUTATIONS.

!     INTERFACE.
!     ----------
!          *VDIFF* TAKES THE MODEL VARIABLES AT T-1 AND RETURNS THE VALUES
!     FOR THE PROGNOSTIC TIME T+1 DUE TO VERTICAL DIFFUSION.
!     THE MODEL VARIABLES, THE MODEL DIMENSIONS AND THE DIAGNOSTICS DATA
!     ARE PASSED AS SUBROUTINE ARGUMENTS. CONSTANTS THAT DO NOT CHANGE
!     DURING A MODEL RUN (E.G. PHYSICAL CONSTANTS, SWITCHES ETC.) ARE
!     STORED IN A SINGLE COMMON BLOCK *YOMVDF*, WHICH IS INITIALIZED
!     BY SET-UP ROUTINE *SUVDF*.

!     PARAMETER     DESCRIPTION                                   UNITS
!     ---------     -----------                                   -----
!     INPUT PARAMETERS (INTEGER):

!    *KIDIA*        START POINT
!    *KFDIA*        END POINT
!    *KLEV*         NUMBER OF LEVELS
!    *KLON*         NUMBER OF GRID POINTS PER PACKET
!    *KLEVS*        NUMBER OF SOIL LAYERS
!    *KTILES*       NUMBER OF TILES (I.E. SUBGRID AREAS WITH DIFFERENT
!                   OF SURFACE BOUNDARY CONDITION)
!    *KVTYPES*      NUMBER OF biomes for land carbon
!    *KDIAG*        Number of diagnostic parameter
!    *KTRAC*        Number of tracers
!    *KCHEM*        Number of tracers
!    *KAERO*        Number of tracers
!    *KLEVSN*       Number of snow layers (diagnostics)
!    *KLEVI*        Number of sea ice layers (diagnostics)
!    *KDHVTLS*      Number of variables for individual tiles
!    *KDHFTLS*      Number of fluxes for individual tiles
!    *KDHVTSS*      Number of variables for snow energy budget
!    *KDHFTSS*      Number of fluxes for snow energy budget
!    *KDHVTTS*      Number of variables for soil energy budget
!    *KDHFTTS*      Number of fluxes for soil energy budget
!    *KDHVTIS*      Number of variables for sea ice energy budget
!    *KDHFTIS*      Number of fluxes for sea ice energy budget
!    *KDHVCO2S*     Number of variables for land carbon
!    *KDHFCO2S*     Number of fluxes for land carbon
!    *KDHVVEGS*     Number of variables for interactive vegetation
!    *KDHFVEGS*     Number of fluxes for interactive vegetation

!    *KTVL*         VEGETATION TYPE FOR LOW VEGETATION FRACTION
!    *KCO2TYP*         CO2 PHOTOSYNTHESIS TYPE FOR LOW VEGETATION (C3/C4)
!    *KTVH*         VEGETATION TYPE FOR HIGH VEGETATION FRACTION
!    *KSOTY*        SOIL TYPE                                    (1-7)

!     INPUT PARAMETERS (LOGICAL)

!     INPUT PARAMETERS (REAL)

!    *PTSPHY*       TIME STEP FOR THE PHYSICS

!     INPUT PARAMETERS AT T-1 OR CONSTANT IN TIME (REAL):

!    *PCVL*         LOW VEGETATION COVER                          -
!    *PCVH*         HIGH VEGETATION COVER                         -
!    *PCUR*         URBAN COVER (PASSIVE)                         -
!    *PLAIL*        LOW VEGETATION LAI                            m2/m2
!    *PLAIH*        HIGH VEGETATION LAI                           m2/m2
!    *PFWET*        WETLAND FRACTION                              -
!    *PSNS*         SNOW MASS                                     kg/m2
!    *PRSN*         SNOW DENSITY                                  kg/m3
!    *PMU0*         LOCAL COSINE OF INSTANTANEOUS SOLAR ZENITH ANGLE. -
!    *PSIGFLT*      STANDARD DEVIATION OF FILTERED OROGRAPHY      M
!    *PUM1*         X-VELOCITY COMPONENT                          M/S
!    *PVM1*         Y-VELOCITY COMPONENT                          M/S
!    *PTM1*         TEMPERATURE                                   K
!    *PQM1*         SPECIFIC HUMIDITY                             KG/KG
!    *PTKE1*        TURBULENT KINETIC ENERGY                      (M/S)**2
!    *PLM1*         SPECIFIC CLOUD LIQUID WATER                   KG/KG
!    *PIM1*         SPECIFIC CLOUD ICE                            KG/KG
!    *PAM1*         CLOUD FRACTION                                1
!    *PCM1*         TRACER CONCENTRATION                          KG/KG
!    *PAPM1*        PRESSURE ON FULL LEVELS                       PA
!    *PAPHM1*       PRESSURE ON HALF LEVELS                       PA
!    *PGEOM1*       GEOPOTENTIAL                                  M2/S2
!    *PGEOH*        GEOPOTENTIAL AT HALF LEVELS                   M2/S2
!    *PGELAT*       LATITUDE                                      -
!    *PTSKM1M*      SKIN TEMPERATURE                              K
!    *PTSAM1M*      SURFACE TEMPERATURE                           K
!    *PWSAM1M*      SOIL MOISTURE ALL LAYERS                      M**3/M**3
!    *PSSRFL*       NET SHORTWAVE RADIATION FLUX AT SURFACE       W/M2
!    *PSLRFL*       NET LONGWAVE RADIATION FLUX AT SURFACE        W/M2
!    *PEMIS*        MODEL SURFACE LONGWAVE EMISSIVITY
!    *PHRLW*        LONGWAVE HEATING RATE                         K/s
!    *PHRSW*        SHORTWAVE HEATING RATE                        K/s
!    *PTSNOW*       SNOW TEMPERATURE                              K
!    *PTICE*        ICE TEMPERATURE (TOP SLAB)                    K
!    *PTLICE*       LAKE ICE TEMPERATURE                          K
!    *PHLICE*       LAKE ICE THICKNESS                            m
!    *PTLWML*       LAKE MEAN WATER TEMPERATURE                   K
!    *PSST*         (OPEN) SEA SURFACE TEMPERATURE                K
!    *PFRTI*        TILE FRACTIONS                                (0-1)
!            1 : WATER                  5 : SNOW ON LOW-VEG+BARE-SOIL
!            2 : ICE                    6 : DRY SNOW-FREE HIGH-VEG
!            3 : WET SKIN               7 : SNOW UNDER HIGH-VEG
!            4 : DRY SNOW-FREE LOW-VEG  8 : BARE SOIL
!    *PALBTI*       BROADBAND ALBEDO FOR TILE FRACTIONS
!    *PWLMX*        MAXIMUM SKIN RESERVOIR CAPACITY               kg/m**2
!    *PCHAR*        CHARNOCK PARAMETER                               -
!    *PCHARHQ*      CHARNOCK PARAMETER FOR HEAT AND MOISTURE         -
!    *PUCURR*       OCEAN CURRENT X-DIRECTION
!    *PVCURR*       OCEAN CURRENT Y-DIRECTION
!    *PUSTOKES*     SURFACE STOKES VELOCITY X-DIRECTION
!    *PVSTOKES*     SURFACE STOKES VELOCITY Y-DIRECTION
!    *PTSKRAD*      SKIN TEMPERATURE OF LATEST FULL RADIATION
!                      TIMESTEP                                   K
!    *PCFLX*        TRACER SURFACE FLUX                           kg/(m2 s)
!    *PDDVLC*       DRY DEPOSITION VELOCITY                       m/s
!    *PSOTEU*       Explicit part of U-tendency from subgrid orography scheme
!    *PSOTEV*       Explicit part of V-tendency from subgrid orography scheme
!    *PSOBETA*      Implicit part of subgrid orography
!    *PTHKICE*      Sea ice thickness                             m
!    *PSNTICE*      Thickness of snow layer on sea ice            m
!    *PGP2DSPP*     Standard stochastic variable (mean=0, SD=1)

!     INPUT PARAMETERS (LOGICAL):

!     CONTRIBUTIONS TO BUDGETS (OUTPUT,REAL):

!    *PVDIS*        TURBULENT DISSIPATION                         W/M2
!    *PVDISG*       SUBGRID OROGRAPHY DISSIPATION                 W/M2
!    *PAHFLEV*      LATENT HEAT FLUX  (SNOW/ICE FREE PART)        W/M2
!    *PAHFLSB*      LATENT HEAT FLUX  (SNOW/ICE COVERED PART)     W/M2

!     UPDATED PARAMETERS (REAL):

!    *PTE*          TEMPERATURE TENDENCY                          K/S
!    *PQE*          MOISTURE TENDENCY                             KG/(KG S)
!    *PLE*          LIQUID WATER TENDENCY                         KG/(KG S)
!    *PIE*          ICE WATER TENDENCY                            KG/(KG S)
!    *PAE*          CLOUD FRACTION TENDENCY                       1/S)
!    *PVOM*         MERIODINAL VELOCITY TENDENCY (DU/DT)          M/S2
!    *PVOL*         LATITUDE TENDENCY            (DV/DT)          M/S2
!    *PTKEE*        TURBULENT KINETIC ENERGY TENDENCY             M2/S3
!    *PTENC*        TRACER TENDENCY                               KG/(KG S)
!    *PTSKE1*       SKIN TEMPERATURE TENDENCY                     K/S
!    *PZ0M*         AERODYNAMIC ROUGHNESS LENGTH                  M
!    *PZ0H*         ROUGHNESS LENGTH FOR HEAT                     M

!     UPDATED PARAMETERS FOR TILES (REAL):

!    *PUSTRTI*      SURFACE U-STRESS                              N/M2
!    *PVSTRTI*      SURFACE V-STRESS                              N/M2
!    *PAHFSTI*      SURFACE SENSIBLE HEAT FLUX                    W/M2
!    *PEVAPTI*      SURFACE MOISTURE FLUX                         KG/M2/S
!    *PTSKTI*       SKIN TEMPERATURE                              K

!    UPDATED PARAMETERS FOR VEGETATION TYPES (REAL):

!    *PANDAYVT*     DAILY NET CO2 ASSIMILATION OVER CANOPY        KG_CO2/M2
!    *PANFMVT*      MAXIMUM LEAF ASSIMILATION                     KG_CO2/KG_AIR M/S

!     OUTPUT PARAMETERS (REAL):

!    *PFWSB*        EVAPORATION OF SNOW                           KG/(M**2*S)
!    *PU10M*        U-COMPONENT WIND AT 10 M                      M/S
!    *PV10M*        V-COMPONENT WIND AT 10 M                      M/S
!    *P10NU*        U-COMPONENT NEUTRAL WIND AT 10 M              M/S
!    *P10NV*        V-COMPONENT NEUTRAL WIND AT 10 M              M/S
!    *PUST*         FRICTION VELOCITY                             M/S
!    *PT2M*         TEMPERATURE AT 2M                             K
!    *PD2M*         DEW POINT TEMPERATURE AT 2M                   K
!    *PQ2M*         SPECIFIC HUMIDITY AT 2M                       KG/KG
!    *PEXDIAG*      Extra diagnostic fields
!    *PGUST*        GUST AT 10 M                                  M/S
!    *PI10FGCV*     GUST AT 10 M DUE TO DEEP CONVECTION           M/S
!    *PBLH*         PBL HEIGHT (dry diagnostic based on Ri#)      M
!    *PEIS*         NORMALISED INVERSION STRENGTH                 K
!    *PZINV*        PBL HEIGHT (moist parcel, not for stable PBL) M
!    *PSSRFLTI*     NET SHORTWAVE RADIATION FLUX AT SURFACE, FOR
!                      EACH TILE                                  W/M2
!    *PEVAPSNW*     EVAPORATION FROM SNOW UNDER FOREST            KG/(M2*S)
!    *PEVAPMU*      POTENTIAL EVAPORATION (UNSTRESSED LOW VEG)    KG/M2/S
!    *PSTRTU*       TURBULENT FLUX OF U-MOMEMTUM                  KG*(M/S)/(M2*S)
!    *PSTRTV*       TURBULENT FLUX OF V-MOMEMTUM                  KG*(M/S)/(M2*S)
!    *PTOFDU*       TOFD COMP. OF TURBULENT FLUX OF U-MOMEMTUM    KG*(M/S)/(M2*S)
!    *PTOFDV*       TOFD COMP. OF TURBULENT FLUX OF V-MOMEMTUM    KG*(M/S)/(M2*S)
!    *PDIFTS*       TURBULENT FLUX OF HEAT                        J/(M2*S)
!    *PDIFTQ*       TURBULENT FLUX OF SPECIFIC HUMIDITY           KG/(M2*S)
!    *PDIFTL*       TURBULENT FLUX OF LIQUID WATER                KG/(M2*S)
!    *PDIFTI*       TURBULENT FLUX OF ICE WATER                   KG/(M2*S)
!    *PSTRSOU*      SUBGRID OROGRAPHY FLUX OF U-MOMEMTUM          KG*(M/S)/(M2*S)
!    *PSTRSOV*      SUBGRID OROGRAPHY FLUX OF V-MOMEMTUM          KG*(M/S)/(M2*S)

!    *PKH*          TURB. DIFF. COEFF. FOR HEAT ABOVE SURF. LAY.  M2/S
!                   IN SURFACE LAYER: CH*U                        M/S
!    *PKM*          TURB. DIFF. COEFF. FOR MOMENTUM               M2/S
!    *PRI*          RICHARDSON NUMBER
!    *PAN*          NET CO2 ASSIMILATION OVER CANOPY              KG_CO2/M2/S
!    *PAG*          GROSS CO2 ASSIMILATION OVER CANOPY            KG_CO2/M2/S
!    *PRD*          DARK RESPIRATION                              KG_CO2/M2/S
!    *PRSOIL_STR*   RESPIRATION FROM SOIL AND STRUCTURAL BIOMASS  KG_CO2/M2/S
!    *PRECO*        ECOSYSTEM RESPIRATION                         KG_CO2/M2/S
!    *PCO2FLUX*     CO2 FLUX                                      KG_CO2/M2/S
!    *PCH4FLUX*     CH4 FLUX                                      KG_CO2/M2/S
!    *PCFLXO*       EFFECTIVE TRACER SURFACE FLUX                           kg/(m2 s)
!    *PDHTLS*       Diagnostic array for tiles (see module yomcdh)
!                      (Wm-2 for energy fluxes, kg/(m2s) for water fluxes)
!    *PDHTSS*       Diagnostic array for snow T (see module yomcdh)
!                      (Wm-2 for fluxes)
!    *PDHTTS*       Diagnostic array for soil T (see module yomcdh)
!                      (Wm-2 for fluxes)
!    *PDHTIS*       Diagnostic array for ice T (see module yomcdh)
!                      (Wm-2 for fluxes)
!    *PDHCO2S       Diagnostic array for land carbon
!    *PDHVEGS       Diagnostic array for interactive vegetation

!     OPTIONAL PARAMETERS:

!    *PCGPP*        GPP FLUX ADJUSTMENT COEFFICIENT               -
!    *PCREC*        rec FLUX ADJUSTMENT COEFFICIENT               -

!     METHOD.
!     -------

!          FIRST AN AUXIALIARY VARIABLE CP(Q)T+GZ IS CREATED ON WHICH
!     THE VERTICAL DIFFUSION PROCESS WILL WORK LIKE ON U,V AND Q. THEN
!     ALONG THE VERTICAL AND AT THE SURFACE, EXCHANGE COEFFICIENTS (WITH
!     THE DIMENSION OF A PRESSURE THICKNESS) ARE COMPUTED FOR MOMENTUM
!     AND FOR HEAT (SENSIBLE PLUS LATENT). THE LETTERS M AND H ARE USED
!     TO DISTINGUISH THEM AND THE COMPUTATION IS THE RESULT OF A
!     CONDITIONAL MERGE BETWEEN THE STABLE AND THE UNSTABLE CASE
!     (DEPENDING ON THE SIGN OF THE *RICHARDSON BULK NUMBER).
!          IN THE SECOND PART OF THE ROUTINE THE IMPLICIT LINEAR
!     SYSTEMS FOR U,V FIRST AND T,Q SECOND ARE SOLVED BY A *GAUSSIAN
!     ELIMINATION BACK-SUBSTITUTION METHOD. FOR T AND Q THE LOWER
!     BOUNDARY CONDITION DEPENDS ON THE SURFACE STATE.
!     OVER LAND, TWO DIFFERENT REGIMES OF EVAPORATION PREVAIL:
!     A STOMATAL RESISTANCE DEPENDENT ONE OVER THE VEGETATED PART
!     AND A SOIL RELATIVE HUMIDITY DEPENDENT ONE OVER THE
!     BARE SOIL PART OF THE GRID MESH.
!     POTENTIAL EVAPORATION TAKES PLACE OVER THE SEA, THE SNOW
!     COVERED PART AND THE LIQUID WATER COVERED PART OF THE
!     GRID MESH AS WELL AS IN CASE OF DEW DEPOSITION.
!          FINALLY ONE RETURNS TO THE VARIABLE TEMPERATURE TO COMPUTE
!     ITS TENDENCY AND THE LATER IS MODIFIED BY THE DISSIPATION'S EFFECT
!     (ONE ASSUMES NO STORAGE IN THE TURBULENT KINETIC ENERGY RANGE) AND
!     THE EFFECT OF MOISTURE DIFFUSION ON CP. Z0 IS UPDATED AND THE
!     SURFACE FLUXES OF T AND Q AND THEIR DERIVATIVES ARE PREPARED AND
!     STORED LIKE THE DIFFERENCE BETWEEN THE IMPLICITELY OBTAINED
!     CP(Q)T+GZ AND CP(Q)T AT THE SURFACE.

!     EXTERNALS.
!     ----------

!     *VDFMAIN* CALLS SUCESSIVELY:
!         *VDFSURF*
!         *VDFEXCS*
!         *VDFEVAP*
!         *VDFEXCU*
!         *VDFDIFM*
!         *VDFDIFH*
!         *VDFDIFC*
!         *VDFINCR*
!         *VDFSDRV*
!         *VDFPPCFL*
!         *VDFUPDZ0*

!     REFERENCE.
!     ----------

!          SEE VERTICAL DIFFUSION'S PART OF THE MODEL'S DOCUMENTATION
!     FOR DETAILS ABOUT THE MATHEMATICS OF THIS ROUTINE.

!     AUTHOR.
!     -------
!      J.F.GELEYN       20/04/82   Original

!     MODIFICATIONS.
!     --------------
!      D. Salmond       15/10/2001 FULLIMP mods
!      S. Abdalla       27/11/2001 Passing Zi/L to waves
!      J.Hague          25/06/2003 Tuning for p690
!      P.Viterbo        24/05/2004 Change surface units
!      M. Ko"hler        3/12/2004 Moist Advection-Diffusion
!      A.Beljaars (12-11-02) Introduction of ocean current b.c.
!      A. Beljaars      30/09/2005 Include Subgr. Oro. in solver
!      G. Balsamo       15/01/2007 Include soil type
!      A. Beljaars      27/02/2009 Delete PZIDLWV
!      G. Balsamo       18/04/2008 Include lake tile
!      H. Hersbach      04/12/2009 10-m neutral wind and friction velocity
!      S. Boussetta/G.Balsamo May 2009 Add variable LAI
!      S. Boussetta/G.Balsamo Nov 2010 Add CTESSEL
!      A.Beljaars       Jan 2014   Add substep in module and control by LWDS
!      A.Beljaars       26/02/2014 Add unstressed low vegetation for Pot Evap
!      A. Agusti-Panareda 31/10/2013 GPP/REC flux adjustment coefficients
!      A. Agusti-Panareda 10/06/2015 cleaning (GPP/REC flux adjustment coefficients)
!      P. Bechtold      10/11/2020 Major revision/cleaning: all iteration=substep
!                                  variables/storage removed
!     --------------------------------------------------------------------------------------

USE PARKIND1, ONLY: JPIM, JPRB

USE forecast_native_vertical_diffusion, ONLY: vdfmain, native_turbulence_controls
USE physical_constant_setup_port, ONLY: forecast_physical_constants
USE owned_ecmwf_thermal_state_port, ONLY: thermal_parameter_record, stability_parameter_record
USE forecast_ecmwf_physics_state, ONLY: native_ecmwf_physics_state
USE physics_configuration_state_port, ONLY: physics_configuration_state
USE YOS_SURF, ONLY: TSURF
USE SPP_MOD, ONLY: TSPP_CONFIG

IMPLICIT NONE
TYPE(forecast_physical_constants), INTENT(IN) :: physical
TYPE(thermal_parameter_record), INTENT(IN) :: thermal
TYPE(stability_parameter_record), INTENT(IN) :: stability
TYPE(native_ecmwf_physics_state), INTENT(IN) :: parameters
TYPE(physics_configuration_state), INTENT(INOUT) :: physics
TYPE(TSURF), INTENT(IN) :: surface
TYPE(TSPP_CONFIG), INTENT(IN) :: spp
TYPE(native_turbulence_controls), INTENT(IN) :: controls
REAL(KIND=JPRB), INTENT(IN) :: planet_scale, rplrg, source_time_step
INTEGER(KIND=JPIM), INTENT(IN) :: current_step
INTEGER(KIND=JPIM), INTENT(OUT) :: status

INTEGER(KIND=JPIM), INTENT(IN) :: KLON
INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
INTEGER(KIND=JPIM), INTENT(IN) :: KLEVS
INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
INTEGER(KIND=JPIM), INTENT(IN) :: KVTYPES
INTEGER(KIND=JPIM), INTENT(IN) :: KDIAG
INTEGER(KIND=JPIM), INTENT(IN) :: KTRAC
INTEGER(KIND=JPIM), INTENT(IN) :: KCHEM(:)
INTEGER(KIND=JPIM), INTENT(IN) :: KAERO(:)
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
INTEGER(KIND=JPIM), INTENT(IN) :: KDHVCO2S
INTEGER(KIND=JPIM), INTENT(IN) :: KDHFCO2S
INTEGER(KIND=JPIM), INTENT(IN) :: KDHVVEGS
INTEGER(KIND=JPIM), INTENT(IN) :: KDHFVEGS
CHARACTER(LEN=1), INTENT(IN) :: CDCONF
INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
REAL(KIND=JPRB), INTENT(IN) :: PTSPHY
INTEGER(KIND=JPIM), INTENT(IN) :: KTVL(KLON)
INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(KLON)
INTEGER(KIND=JPIM), INTENT(IN) :: KTVH(KLON)
INTEGER(KIND=JPIM), INTENT(IN) :: KSOTY(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PCVL(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PCVH(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PCUR(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PLAIL(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PLAIH(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PFWET(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PSNS(KLON, KLEVSN)
REAL(KIND=JPRB), INTENT(IN) :: PRSN(KLON, KLEVSN)
REAL(KIND=JPRB), INTENT(IN) :: PMU0(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PSIGFLT(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PUM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PVM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PTM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PQM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PTKE1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PLM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PIM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PAM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PCM1(KLON, KLEV, KTRAC)
REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PAPM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PGEOM1(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PGEOH(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PGELAT(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PTSAM1M(KLON, KLEVS)
REAL(KIND=JPRB), INTENT(IN) :: PWSAM1M(KLON, KLEVS)
REAL(KIND=JPRB), INTENT(IN) :: PSSRFL(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PSLRFL(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PEMIS(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PHRLW(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PHRSW(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PTSNOW(KLON, KLEVSN)
REAL(KIND=JPRB), INTENT(IN) :: PTICE(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PHLICE(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PTLICE(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PTLWML(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PSST(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PFRTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(IN) :: PALBTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(IN) :: PWLMX(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PCHAR(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PCHARHQ(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PUCURR(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PVCURR(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PUSTOKES(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PVSTOKES(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PTSKRAD(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PCFLX(KLON, KTRAC)
REAL(KIND=JPRB), INTENT(INOUT) :: PDDVLC(KLON, KTRAC)
REAL(KIND=JPRB), INTENT(IN) :: PSOTEU(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PSOTEV(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PSOBETA(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PTHKICE(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PSNTICE(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
LOGICAL, INTENT(IN) :: LSICOUP
REAL(KIND=JPRB), INTENT(INOUT) :: PZ0M(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PZ0H(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PVDIS(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PVDISG(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PDISGW3D(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PAHFLEV(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PAHFLSB(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PFWSB(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PU10M(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PV10M(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: P10NU(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: P10NV(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PUST(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PT2M(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PD2M(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PQ2M(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PZINV(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PBLH(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PEIS(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PSSRFLTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(INOUT) :: PEVAPSNW(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PEVAPMU(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PEXDIAG(KLON, KDIAG)
REAL(KIND=JPRB), INTENT(INOUT) :: PGUST(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PI10FGCV(KLON)
INTEGER(KIND=JPIM), INTENT(INOUT) :: KPBLTYPE(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PTE0(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PQE0(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PLE0(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PIE0(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PAE0(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PVOM0(KLON, KLEV)
REAL(KIND=JPRB), INTENT(IN) :: PVOL0(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PTE(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PQE(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PLE(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PIE(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PAE(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PVOM(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PVOL(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PTKEE(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PTENC(KLON, KLEV, KTRAC)
REAL(KIND=JPRB), INTENT(INOUT) :: PTSKE1(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PUSTRTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(INOUT) :: PVSTRTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(INOUT) :: PAHFSTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(INOUT) :: PEVAPTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(INOUT) :: PTSKTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(INOUT) :: PAHFTRTI(KLON, KTILES)
REAL(KIND=JPRB), INTENT(INOUT) :: PANDAYVT(KLON, KVTYPES)
REAL(KIND=JPRB), INTENT(INOUT) :: PANFMVT(KLON, KVTYPES)
REAL(KIND=JPRB), INTENT(INOUT) :: PDIFTS(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PDIFTQ(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PDIFTL(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PDIFTI(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PSTRTU(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PSTRTV(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PTOFDU(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PTOFDV(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PSTRSOU(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PSTRSOV(KLON, 0:KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PKH(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PKM(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PRI(KLON, KLEV)
REAL(KIND=JPRB), INTENT(INOUT) :: PAN(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PAG(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PRD(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PRSOIL_STR(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PRECO(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PCO2FLUX(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PCH4FLUX(KLON)
REAL(KIND=JPRB), INTENT(INOUT) :: PCFLXO(KLON, KTRAC)
REAL(KIND=JPRB), INTENT(INOUT) :: PDHTLS(KLON, KTILES, KDHVTLS + KDHFTLS)
REAL(KIND=JPRB), INTENT(INOUT) :: PDHTSS(KLON, KLEVSN, KDHVTSS + KDHFTSS)
REAL(KIND=JPRB), INTENT(INOUT) :: PDHTTS(KLON, KLEVS, KDHVTTS + KDHFTTS)
REAL(KIND=JPRB), INTENT(INOUT) :: PDHTIS(KLON, KLEVI, KDHVTIS + KDHFTIS)
REAL(KIND=JPRB), INTENT(INOUT) :: PDHVEGS(KLON, KVTYPES, KDHVVEGS + KDHFVEGS)
REAL(KIND=JPRB), INTENT(INOUT) :: PDHCO2S(KLON, KVTYPES, KDHVCO2S + KDHFCO2S)
REAL(KIND=JPRB), INTENT(IN) :: PCGPP(KLON)
REAL(KIND=JPRB), INTENT(IN) :: PCREC(KLON)

INTEGER(KIND=JPIM) :: JROF, JLEV
LOGICAL :: LLTROPQ_OFFL

!     ------------------------------------------------------------------

!     ------------------------------------------------------------------

!*         1.     INITIALIZE CONSTANTS
!                 --------------------
status = 2
if (klon < 1 .or. klon > 4096 .or. klev < 3 .or. klev > 512 .or. klevs /= 4 .or. ktiles /= 9) return
if (kidia < 1 .or. kfdia > klon .or. kfdia < kidia .or. current_step < 0 .or. ktrac < 0) return
if (kvtypes < 2 .or. klevsn < 1 .or. klevi < 1) return
if (controls%vector_math > 0 .or. spp%lspp .or. physics%ecmwf_physics%LVDFTRAC .or. physics%ecmwf_physics%LEAIRCO2COUP) return
if (size(PGP2DSPP, 1) < klon .or. size(PGP2DSPP, 2) < spp%sm%nrftotal) return

LLTROPQ_OFFL = .TRUE.

!        INITIALIZE TENDENCIES
DO JLEV = 1, KLEV
  DO JROF = KIDIA, KFDIA
    PVOM(JROF, JLEV) = PVOM0(JROF, JLEV)
    PVOL(JROF, JLEV) = PVOL0(JROF, JLEV)
    PTE(JROF, JLEV) = PTE0(JROF, JLEV)
  END DO
END DO
DO JLEV = 1, KLEV
  DO JROF = KIDIA, KFDIA
    PQE(JROF, JLEV) = PQE0(JROF, JLEV)
    PLE(JROF, JLEV) = PLE0(JROF, JLEV)
    PIE(JROF, JLEV) = PIE0(JROF, JLEV)
    PAE(JROF, JLEV) = PAE0(JROF, JLEV)
  END DO
END DO

!*         2.2    CALL VDFMAIN
!                 ------------

  ! OUTPUT
  ! OUTPUT TENDENDCIES
  ! UPDATED FIELDS FOR TILES
  !-UPDATED FIELDS FOR VEGETATION TYPES
  ! FLUX OUTPUTS
  ! DDH OUTPUTS
  ! CO2 VEGETATION FLUX ADJUSTMENT COEFFICIENTS FROM BFAS
CALL VDFMAIN(physical,thermal,stability,parameters,physics,surface,spp,controls,planet_scale,rplrg,source_time_step,CDCONF, &
  & KIDIA, KFDIA, KLON, KLEV, KLEVS, current_step, KTILES, KVTYPES, KDIAG,&
  & KTRAC, KCHEM, KAERO, KLEVSN, KLEVI, KDHVTLS, KDHFTLS, KDHVTSS, KDHFTSS, &
  & KDHVTTS, KDHFTTS, KDHVTIS, KDHFTIS, &
  & KDHVCO2S, KDHFCO2S, KDHVVEGS, KDHFVEGS,&
  & PTSPHY, KTVL, KCO2TYP, KTVH, PCVL, PCVH, PCUR, PFWET,&
  & PLAIL, PLAIH, PSNS, PRSN, PMU0, PSIGFLT,&
  & PUM1, PVM1, PTM1, PQM1, PLM1, PIM1, PAM1, PCM1, PTKE1,&
  & PAPHM1, PAPM1, PGEOM1, PGEOH, PGELAT, PTSKM1M, PTSAM1M, PWSAM1M, &
  & PSSRFL, PSLRFL, PEMIS, PHRLW, PHRSW, &
  & PTSNOW, PTICE, &
  & PHLICE, PTLICE, PTLWML, &
  & PSST, KSOTY, PFRTI, PALBTI, PWLMX, &
  & PCHAR, PCHARHQ, PUCURR, PVCURR, PUSTOKES, PVSTOKES, &
  & PTSKRAD, PCFLX, PDDVLC, &
  & PSOTEU, PSOTEV, PSOBETA,&
  & PTHKICE, PSNTICE, PGP2DSPP, &
  & LSICOUP, &
  & PZ0M, PZ0H, &
  & PVDIS, PVDISG, PDISGW3D, PAHFLEV, PAHFLSB, PFWSB, &
  & PU10M, PV10M, PT2M, PD2M, PQ2M, PZINV, PBLH, PEIS, &
  & P10NU, P10NV, PUST, &
  & PSSRFLTI, PEVAPSNW, PEVAPMU, PEXDIAG, PGUST, PI10FGCV, KPBLTYPE,&
  & PTE, PQE, PLE, PIE, PAE, PVOM, PVOL, PTKEE, &
  & PTENC, PTSKE1, &
  & PUSTRTI, PVSTRTI, PAHFSTI, PEVAPTI, PTSKTI, &
  & PAHFTRTI, &
  & PANDAYVT, PANFMVT,&
  & PDIFTS, PDIFTQ, PDIFTL, PDIFTI, PSTRTU, PSTRTV, PTOFDU, PTOFDV,&
  & PSTRSOU, PSTRSOV, PKH, PKM, PRI, &
  & PAN, PAG, PRD, PRSOIL_STR, PRECO, PCO2FLUX, PCH4FLUX, PCFLXO, &
  & PDHTLS, PDHTSS, PDHTTS, PDHTIS, &
  & PDHCO2S, PDHVEGS, &
  & PCGPP=PCGPP, PCREC=PCREC, status=status)
IF (status /= 0) return

!        SUBTRACT TENDENCIES TO ONLY THOSE FROM THIS ROUTINE
DO JLEV = 1, KLEV
  DO JROF = KIDIA, KFDIA
    PVOM(JROF, JLEV) = PVOM(JROF, JLEV) - PVOM0(JROF, JLEV)
    PVOL(JROF, JLEV) = PVOL(JROF, JLEV) - PVOL0(JROF, JLEV)
    PTE(JROF, JLEV) = PTE(JROF, JLEV) - PTE0(JROF, JLEV)
  END DO
END DO
DO JLEV = 1, KLEV
  DO JROF = KIDIA, KFDIA
    PQE(JROF, JLEV) = PQE(JROF, JLEV) - PQE0(JROF, JLEV)
    PLE(JROF, JLEV) = PLE(JROF, JLEV) - PLE0(JROF, JLEV)
    PIE(JROF, JLEV) = PIE(JROF, JLEV) - PIE0(JROF, JLEV)
    PAE(JROF, JLEV) = PAE(JROF, JLEV) - PAE0(JROF, JLEV)
  END DO
END DO

status = 0
END SUBROUTINE VDFOUTER

end module forecast_native_vertical_diffusion_outer
