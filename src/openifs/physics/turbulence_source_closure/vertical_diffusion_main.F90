!> Complete selected heat, moisture and momentum diffusion caller.
!! Physical and parameter records are borrowed read-only. FP64 column-major
!! full-level fields use(P,L), half-level fields(P,0:L), and tiles(P,9).
!! Temperatures use K, pressure Pa, winds m/s and tendencies per second.
!! The complete enabled surface, boundary-layer, mass-flux, diffusion,
!! increment, blending, postprocessing and flux reconstructions run in order.
!! Tracer diffusion, stochastic perturbations and coupled carbon are outside
!! this entry and are refused before public writes. All outputs retain
!! inactive preimages, except the source-required full TKE-rate zero fill.
module forecast_native_vertical_diffusion
use iso_fortran_env, only: int32, real64
implicit none
private
public :: native_turbulence_controls, vdfmain
!> Original request controls supplied by their initialized producer.
!! Fluxes use W/m2 and carbon_dioxide is the source atmospheric CO2 value.
!! This type supplies no defaults, clock or scientific calculation.
type :: native_turbulence_controls
 logical :: scmec_enabled, prescribed_surface_flux, nemo_limit_thickness
 integer(int32) :: vector_math
 real(real64) :: external_sensible_flux, external_latent_flux, carbon_dioxide
end type
contains
! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!OPTIONS XOPT(HSFUN)
#ifdef RS6K
@PROCESS NOSTRICT
#endif
 ! OUTPUT
 ! OUTPUT TENDENCIES
 ! UPDATED FIELDS FOR TILES
 !-UPDATED FIELDS FOR VEGETATION TYPES
 ! OUTPUT FLUXES
 ! DDH OUTPUTS
 ! CO2 VEGETATION FLUX ADJUSTMENT COEFFICIENTS FROM BFAS
SUBROUTINE VDFMAIN(physical,thermal,stability,parameters,physics,surface,spp,controls,planet_scale,rplrg,source_time_step,CDCONF, &
 & KIDIA, KFDIA, KLON, KLEV, KLEVS, KSTEP, KTILES, KVTYPES, KDIAG,&
 & KTRAC, KCHEM, KAERO, KLEVSN, KLEVI, KDHVTLS, KDHFTLS, KDHVTSS, KDHFTSS, &
 & KDHVTTS, KDHFTTS, KDHVTIS, KDHFTIS, &
 & KDHVCO2S, KDHFCO2S, KDHVVEGS, KDHFVEGS,&
 & PTSPHY, KTVL, KCO2TYP, KTVH, PCVL, PCVH, PCUR, PFWET,&
 & PLAIL, PLAIH, PSNM, PRSN, PMU0, PSIGFLT, &
 & PUM1, PVM1, PTM1, PQM1, PLM1, PIM1, PAM1, PCM1, PTKE1,&
 & PAPHM1, PAPM1, PGEOM1, PGEOH, PGELAT, PTSKM1M, PTSAM1M, PWSAM1M, &
 & PSSRFL, PSLRFL, PEMIS, PHRLW, PHRSW, &
 & PTSN, PTICE, &
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
 & PTE, PQE, PLE, PIE, PAE, PVOM, PVOL, PTKEE,&
 & PTENC, PTSKE1, &
 & PUSTRTI, PVSTRTI, PAHFSTI, PEVAPTI, PTSKTI, &
 & PFLTRTI, &
 & PANDAYVT, PANFMVT,&
 & PDIFTS, PDIFTQ, PDIFTL, PDIFTI, PSTRTU, PSTRTV, PTOFDU, PTOFDV, &
 & PSTRSOU, PSTRSOV, PKH, PKM, PRI,&
 & PAN, PAG, PRD, PRSOIL_STR, PRECO, PCO2FLUX, PCH4FLUX, PCFLXO, &
 & PDHTLS, PDHTSS, PDHTTS, PDHTIS, &
 & PDHCO2S, PDHVEGS, &
 & PCGPP, PCREC, status)

!***

!**   *VDFMAIN* - DOES THE VERTICAL EXCHANGE OF U,V,SLG,QT BY TURBULENCE.

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
!    *KSTEP*        CURRENT TIME STEP INDEX
!    *KTILES*       NUMBER OF TILES (I.E. SUBGRID AREAS WITH DIFFERENT
!                   OF SURFACE BOUNDARY CONDITION)
!    *KVTYPES*      NUMBER OF biomes for land carbon
!    *KDIAG*        NUMBER of diagnostic parameters
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
!    *KCO2TYP*      CO2 PHOTOSYNTHESIS TYPE FOR LOW VEGETATION
!    *KTVH*         VEGETATION TYPE FOR HIGH VEGETATION FRACTION
!    *KSOTY*        SOIL TYPE                                     (1-7)

!     INPUT PARAMETERS (LOGICAL)

!     INPUT PARAMETERS (REAL)

!    *PTSPHY*       TIME STEP FOR THE PHYSICS

!     INPUT PARAMETERS AT T-1 OR CONSTANT IN TIME (REAL):

!    *PCVL*         LOW VEGETATION COVER                          -
!    *PCVH*         HIGH VEGETATION COVER                         -
!    *PCUR*         URBAN COVER                                  (0-1)
!    *PLAIL*        LOW VEGETATION LAI                           m2/m2
!    *PLAIH*        HIGH VEGETATION LAI                          m2/m2
!    *PFWET*        WETLAND FRACTION                              -
!    *PSNM*         SNOW MASS                                     kg/m2
!    *PRSN*         SNOW DENSITY                                  kg/m3
!    *PMU0*         LOCAL COSINE OF INSTANTANEOUS SOLAR ZENITH ANGLE. -
!    *PSIGFLT*      STANDARD DEVIATION OF FILTERED OROGRAPHY      M
!    *PUM1*         X-VELOCITY COMPONENT                          M/S
!    *PVM1*         Y-VELOCITY COMPONENT                          M/S
!    *PTM1*         TEMPERATURE                                   K
!    *PQM1*         SPECIFIC HUMIDITY                             KG/KG
!    *PLM1*         SPECIFIC CLOUD LIQUID WATER                   KG/KG
!    *PIM1*         SPECIFIC CLOUD ICE                            KG/KG
!    *PAM1*         CLOUD FRACTION                                1
!    *PCM1*         TRACER CONCENTRATION                          KG/KG
!    *PTKE1*        TURBULENT KINETIC ENERGY                      (M/S)**2
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
!    *PTSN*       SNOW TEMPERATURE                              K
!    *PTICE*        ICE TEMPERATURE (TOP SLAB)                    K
!    *PHLICE*       LAKE ICE THICKNESS                            m
!    *PTLICE*       LAKE ICE TEMPERATURE                          K
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
!    *PUCURR*       OCEAN CURRENT X_COMPONENT
!    *PVCURR*       OCEAN CURRENT Y_COMPONENT
!    *PUSTOKES*     SURFACE STOKES VELOCITY X_COMPONENT
!    *PVSTOKES*     SURFACE STOKES VELOCITY Y_COMPONENT
!    *PTSKRAD*      SKIN TEMPERATURE OF LATEST FULL RADIATION
!                      TIMESTEP                                   K
!    *PCFLX*        TRACER SURFACE FLUX                           kg/(m2 s)
!    *PDDVLC*       TRACER SURFACE DRY DEPOSITION VELOCITY        m/s
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
!    *PFLTRTI*      SURFACE LONGWAVE RADIATION

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
!    *PI10FGCV*     GUST AT 10 M FROM DEEP CONVECTION             M/S
!    *PBLH*         PBL HEIGHT (dry diagnostic based on Ri#)      M
!    *PEIS*         INVERSION STRENGTH                            K
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
!    *PCFLXO*       EFFECTIVE TRACER SURFACE FLUX                 kg/(m2 s)
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

!     Additional parameters for flux boundary condition (in SCM model):

!    *LSFCFLX*      If .TRUE. flux boundary condtion is used
!    *REXTSHF*      Specified sensible heat flux [W/m2]
!    *REXTLHF*      Specified latent heat flux [W/m2]

!     OPTIONAL PARAMETERS:

!    *PCGPP*        GPP flux adjustment coefficient               -
!    *PCREC*        REC flux adjustment coefficient               -

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
!         *SURFEXCDRIVER*
!         *VDFEXCU*
!         *VDFTOFDC*
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
!      A. Beljaars       2/05/2003 New tile coupling
!      P. Viterbo       24/05/2004 Change surface units
!      M. Ko"hler        3/12/2004 Moist Advection-Diffusion
!      A. Beljaars       4/04/2005 Turb. orogr. drag
!      A. Beljaars      30/09/2005 Include Subgr. Oro. in solver
!      A. Beljaars      31/03/2005 Introduction of ocean current b.c.
!      P. Viterbo       17/06/2005 surf external library
!      M. Ko"hler        6/06/2006 Single Column Model option (LSCMEC)
!      G. Balsamo       15/01/2007 Soil type
!      A. Beljaars      27/02/2009 Delete PZIDLWV
!      G. Balsamo       07/04/2008 Lake model (FLAKE)
!      M. Janiskova/G. Balsamo     21/10/2008 Move VDFDIFH5 in VDFDIFH
!      M. Ko"hler/G. Modzinski     Bug correction in optimised qsat computation
!      P.de Rosnay/G.Balsamo       07/03/2009 Offline Jacobians EKF
!      H. Hersbach     04-Dec-2009 10-m neutral wind and friction velocity
!      P.de Rosnay/G.Balsamo       October 2009 commented EKF (offline in callpar)
!      S. Boussetta/G.Balsamo      May 2009 (Add variable LAI)
!      R. Forbes        15/03/2010 Changed fn(T) ice/liq split to prognostic
!      N. Semane+P.Bechtold        Oct-2012 RPLRG/RPLDARE for small planet
!      A. Agusti-Panareda Feb 2013 Coupling of MACC and CTESSEL NEE fluxes
!      L. Magnusson     28-09-2010 For NEMO-LIM
!      K. Yessad (July 2014): Move some variables.
!      S. Boussetta/G.Balsamo      Nov 2010 (Add CTESSEL)
!      A. Beljaars        Jan 2014 Clean-up to prepare for flexible numerics
!      A. Beljaars      26-2-2014  Unstressed low vegetation for Pot. Evap
!      F. Vana  05-Mar-2015  Support for single precision
!      A. Agusti-panareda 31/10/2013 GPP/REC flux adjustment coefficients
!      A. Agusti-panareda 10/06/2015 cleaning GPP/REC flux adjustment coef
!      R. Forbes        01/11/2015 Removed ice from cloud scheme, now liq only
!      M. Leutbecher&S.-J. Lock Jan 2016 Introduced SPP scheme (LSPP)
!      A. Agusti-Panareda 25/11/2016 Include other chemical carbon tracers using CO2 fluxes
!      E. Dutra 11/10/2016  : new interfaces for surfexcdriver
!                             now returning PTSRF and PLAMSK
!      J Flemming       24-4-2018  On-line calculation of dry deposition
!      I. Sandu+P.Bechtold 9/01/2019 Complete revision of moist turbulence
!      M. Leutbecher & S. Lang     Oct 2020 SPP abstraction and revision
!      R.Forbes+P.Bechtold 05/2022 Remove ice from total water, add -ve humidity check
!     --------------------------------------------------------------------------------------

USE PARKIND1, ONLY: JPIM, JPRB

!     ------------------------------------------------------------------

USE physical_constant_setup_port, ONLY: forecast_physical_constants
USE owned_ecmwf_thermal_state_port, ONLY: thermal_parameter_record, stability_parameter_record
USE forecast_ecmwf_physics_state, ONLY: native_ecmwf_physics_state
USE physics_configuration_state_port, ONLY: physics_configuration_state
USE YOS_SURF, ONLY: TSURF
USE SPP_MOD, ONLY: TSPP_CONFIG
USE surfexcdriver_native_selector, ONLY: surfexcdriver
USE surfpp_native_selector, ONLY: surfpp
USE forecast_native_heat_water_diffusion, ONLY: vdfdifh
USE forecast_momentum_diffusion, ONLY: vdfdifm, vdfincr
USE forecast_boundary_layer_helpers, ONLY: vdfdpbl, vdffblend
USE forecast_turbulent_exchange, ONLY: vdfexcu
USE forecast_turbulent_terrain_drag, ONLY: vdftofdc
USE boundary_layer_parcel_height_mod, ONLY: vdfhghtn

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
INTEGER(KIND=JPIM), INTENT(IN) :: KSTEP
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
REAL(KIND=JPRB), INTENT(IN) :: PSNM(KLON, KLEVSN)
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
REAL(KIND=JPRB), INTENT(IN) :: PTSN(KLON, KLEVSN)
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
REAL(KIND=JPRB), INTENT(INOUT) :: PFLTRTI(KLON, KTILES)
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

!     ------------------------------------------------------------------

REAL(KIND=JPRB) :: ZDIFTQT(KLON, 0:KLEV), ZDIFTSLG(KLON, 0:KLEV)

REAL(KIND=JPRB) :: ZCPTGZ(KLON, KLEV), ZCFM(KLON, KLEV), ZCFH(KLON, KLEV),&
                    & ZUDIF(KLON, KLEV), ZVDIF(KLON, KLEV),&
                    & ZDTUTOFD(KLON, KLEV), ZDTVTOFD(KLON, KLEV),&
                    & ZDTUSO(KLON, KLEV), ZDTVSO(KLON, KLEV),&
                    & ZDTUVDF(KLON, KLEV), ZDTVVDF(KLON, KLEV),&
                    & ZQTDIF(KLON, KLEV), ZSLGDIF(KLON, KLEV),&
                    & ZSLGM1(KLON, KLEV), ZQTM1(KLON, KLEV), ZSLGSM1(KLON, KLEV),&
                    & ZSLGE(KLON, KLEV), ZQTE(KLON, KLEV),&
                    & ZSLGEVDF(KLON, KLEV), ZQTEVDF(KLON, KLEV),&
                    & ZTOFDC(KLON, KLEV)
REAL(KIND=JPRB) :: ZKHFL(KLON), ZKQFL(KLON), ZKMFL(KLON),&
                    & ZKHVFL(KLON), ZLIMIN(KLON)
REAL(KIND=JPRB) :: ZQTEA(KLON, KLEV), ZSLGEA(KLON, KLEV), ZSLGEWODIS(KLON, KLEV)
REAL(KIND=JPRB) :: ZZ0MW(KLON), ZZ0HW(KLON), ZZ0QW(KLON),&
                    & ZBLEND(KLON), ZFBLEND(KLON)
REAL(KIND=JPRB) :: ZZCPTS(KLON), ZZQSA(KLON), ZZBUOM(KLON),&
                    & ZZZDL(KLON)
REAL(KIND=JPRB) :: ZSTRTOFDU(KLON, 0:KLEV), ZSTRTOFDV(KLON, 0:KLEV)
REAL(KIND=JPRB) :: ZMFLX(KLON, 0:KLEV), ZSLGUH(KLON, 0:KLEV), ZQTUH(KLON, 0:KLEV),&
                    & ZCLDBASE(KLON), ZUUH(KLON, 0:KLEV), ZVUH(KLON, 0:KLEV)
REAL(KIND=JPRB) :: ZEXTSHF(KLON), ZEXTLHF(KLON)

REAL(KIND=JPRB) :: ZWETB(KLON), ZWETL(KLON), ZWETLU(KLON), ZWETH(KLON), ZWETHS(KLON), ZRAQ(KLON)
REAL(KIND=JPRB) :: ZCFMTKE(KLON, KLEV), ZCFHTKE(KLON, KLEV), ZEDR(KLON, KLEV)

REAL(KIND=JPRB) :: ZCPTSTI(KLON, KTILES), ZQSTI(KLON, KTILES),&
                    & ZDQSTI(KLON, KTILES), ZCSATTI(KLON, KTILES),&
                    & ZCAIRTI(KLON, KTILES), ZCFHTI(KLON, KTILES),&
                    & ZCFQTI(KLON, KTILES), ZAHFLTI(KLON, KTILES),&
                    & ZTSKTIP1(KLON, KTILES), ZCPTSTIU(KLON, KTILES),&
                    & ZCSATTIU(KLON, KTILES), ZCAIRTIU(KLON, KTILES),&
                    & ZEVAPUTI(KLON, KTILES), ZTSKTIH(KLON, KTILES),&
                    & ZTSKTITE(KLON, KTILES), ZTSKTITE1(KLON, KTILES),&
                    & ZEVAPUTI1(KLON, KTILES), ZRAQTI(KLON, KTILES), &
                    & ZTSRF(KLON, KTILES), ZLAMSK(KLON, KTILES)
REAL(KIND=JPRB) :: ZG0(KLON, KTILES)

REAL(KIND=JPRB) :: ZATMCO2(KLON)

REAL(KIND=JPRB) :: ZWD(KLON, KTRAC), ZCFLXIN(KLON, KTRAC)

INTEGER(KIND=JPIM) :: ITRAC, ICO2
INTEGER(KIND=JPIM) :: ITOP, JK, JL, ILEV, JEXT, JT, JTILE, &
                     &IINV(KLON), ICBASE(KLON), ICTOP(KLON)

! A bunch of SPP variables
REAL(KIND=JPRB) :: ZPERTOC, ZPERTLA ! used in CFM loop

REAL(KIND=JPRB) :: ZGDPH, ZRHO, ZTMST, ZRG, ZRTMST
LOGICAL :: LLSFCFLX, LLAND(KLON), LLTEST(KLON), LLFIRST(KLON)
REAL(KIND=JPRB) :: ZTPFAC2, ZTPFAC3
REAL(KIND=JPRB) :: ZOCFR

REAL(KIND=JPRB) :: ZW1, ZW2, ZW3, ZW4
REAL(KIND=JPRB) :: ZDTUTOFD1(KLON, KLEV), ZDTVTOFD1(KLON, KLEV),&
                     &ZDTUSO1(KLON, KLEV), ZDTVSO1(KLON, KLEV),&
                     &ZDTUVDF1(KLON, KLEV), ZDTVVDF1(KLON, KLEV),&
                     &ZUM1S(KLON, KLEV), ZVM1S(KLON, KLEV),&
                     &ZSLGM1S(KLON, KLEV), ZQTM1S(KLON, KLEV),&
                     &ZSLGEVDF1(KLON, KLEV), ZQTEVDF1(KLON, KLEV),&
                     &ZEVAPTI1(KLON, KTILES), ZAHFSTI1(KLON, KTILES),&
                     &ZAHFLTI1(KLON, KTILES), ZFLTRTI1(KLON, KTILES),&
                     &ZG01(KLON, KTILES)

REAL(KIND=JPRB) :: ZEPSILON

!     ------------------------------------------------------------------
! on-line calculation of dry deposition fluxes
REAL(KIND=JPRB), DIMENSION(KLON, KTRAC) :: ZDEPVEL

!     ------------------------------------------------------------------
ASSOCIATE (YDEPHY => physics%ecmwf_physics, YDECLDP => physics%cloud, &
 & YDVDF => parameters%diffusion, YDECUMF => parameters%convection, YDSPP_CONFIG => spp, &
 & YSURF => surface, RVDIFTS => parameters%diffusion%RVDIFTS, LWDS => parameters%diffusion%LWDS, &
 & REPS1WDS => parameters%diffusion%REPS1WDS, REPS2WDS => parameters%diffusion%REPS2WDS, &
 & RETAWDS => parameters%diffusion%RETAWDS, RLAM => parameters%diffusion%RLAM, &
 & NJKT6 => parameters%convection%NJKT6, REPQMI => parameters%condensation%REPQMI)
status = 2
if (klon < 1 .or. klon > 4096 .or. klev < 3 .or. klev > 512 .or. klevs /= 4 .or. ktiles /= 9) return
if (kidia < 1 .or. kfdia > klon .or. kfdia < kidia .or. kstep < 0 .or. ktrac < 0) return
if (kvtypes < 2 .or. klevsn < 1 .or. klevi < 1) return
if (controls%vector_math > 0 .or. spp%lspp .or. YDEPHY%LVDFTRAC .or. YDEPHY%LEAIRCO2COUP) return
if (size(PGP2DSPP, 1) < klon .or. size(PGP2DSPP, 2) < spp%sm%nrftotal) return
if (ptsphy <= 0._jprb .or. source_time_step <= 0._jprb .or. planet_scale <= 0._jprb .or. rplrg <= 0._jprb) return
ZEPSILON = 100._JPRB*EPSILON(ZEPSILON)

!*         1.     INITIALIZE CONSTANTS
!                 --------------------

ZRTMST = 1.0_JPRB/PTSPHY    ! optimization
ZRG = 1.0_JPRB/physical%rg        !     -"-

ILEV = 1

! CTESSEL initialization
PANDAYVT(KIDIA:KFDIA, :) = 0.0_JPRB
PANFMVT(KIDIA:KFDIA, :) = 0.0_JPRB
PDHVEGS(KIDIA:KFDIA, :, :) = 0.0_JPRB
PDHCO2S(KIDIA:KFDIA, :, :) = 0.0_JPRB

PAN(KIDIA:KFDIA) = 0.0_JPRB
PAG(KIDIA:KFDIA) = 0.0_JPRB
PRD(KIDIA:KFDIA) = 0.0_JPRB
PRSOIL_STR(KIDIA:KFDIA) = 0.0_JPRB
PRECO(KIDIA:KFDIA) = 0.0_JPRB
PCO2FLUX(KIDIA:KFDIA) = 0.0_JPRB
PCH4FLUX(KIDIA:KFDIA) = 0.0_JPRB

!*         1.0  SCM: Fixed fluxes for flux boundary condition ([W/m^2] downward)

IF (controls%scmec_enabled) THEN
  LLSFCFLX = controls%prescribed_surface_flux   ! scm namelist parameters
  ZEXTSHF(:) = controls%external_sensible_flux
  ZEXTLHF(:) = controls%external_latent_flux
ELSE
  LLSFCFLX = .FALSE.
  ZEXTSHF(:) = 0.0_JPRB
  ZEXTLHF(:) = 0.0_JPRB
END IF

!*         1.2  dry static energy cp(q)*T + gz

DO JK = ILEV, KLEV
  DO JL = KIDIA, KFDIA
    ZCPTGZ(JL, JK) = PGEOM1(JL, JK) + PTM1(JL, JK)*physical%rcpd*(1.0_JPRB + thermal%rvtmp2*PQM1(JL, JK))
  END DO
END DO

!          1.3 First tracer as atmospheric CO2 to be used in CTESSEL

ZATMCO2(:) = controls%carbon_dioxide
! input data, non-tiled
! input data, soil
! input data, tiled
! updated data, tiled
! updated data, non-tiled
! output data, tiled
! output data, non-tiled
! output data, non-tiled CO2
! output canopy resistance
! output data, diagnostics
CALL surfexcdriver(thermal, stability, YSURF, CDCONF=CDCONF, &
 & KIDIA=KIDIA, KFDIA=KFDIA, KLON=KLON, KLEVS=KLEVS, KTILES=KTILES, KVTYPES=KVTYPES, KDIAG=KDIAG, &
 & KSTEP=KSTEP, KLEVSN=KLEVSN, KLEVI=KLEVI, KDHVTLS=KDHVTLS, KDHFTLS=KDHFTLS, &
 & KDHVTSS=KDHVTSS, KDHFTSS=KDHFTSS, KDHVTTS=KDHVTTS, KDHFTTS=KDHFTTS, &
 & KDHVTIS=KDHVTIS, KDHFTIS=KDHFTIS, K_VMASS=controls%vector_math, &
 & KDHVCO2S=KDHVCO2S, KDHFCO2S=KDHFCO2S, KDHVVEGS=KDHVVEGS, KDHFVEGS=KDHFVEGS, &
 & PTSTEP=PTSPHY, PTSTEPF=source_time_step,&
 & KTVL=KTVL, KCO2TYP=KCO2TYP, KTVH=KTVH, PCVL=PCVL, PCVH=PCVH, PCUR=PCUR, &
 & PLAIL=PLAIL, PLAIH=PLAIH, PFWET=PFWET, PLAT=PGELAT, &
 & PSNM=PSNM, PRSN=PRSN, &
 & PMU0=PMU0, PCARDI=controls%carbon_dioxide, &
 & PUMLEV=PUM1(:, KLEV), PVMLEV=PVM1(:, KLEV), PTMLEV=PTM1(:, KLEV), &
 & PQMLEV=PQM1(:, KLEV), PCMLEV=ZATMCO2, PAPHMS=PAPHM1(:, KLEV), PGEOMLEV=PGEOM1(:, KLEV), &
 & PCPTGZLEV=ZCPTGZ(:, KLEV), PSST=PSST, PTSKM1M=PTSKM1M, PCHAR=PCHAR, PCHARHQ=PCHARHQ, &
 & PSSRFL=PSSRFL, PSLRFL=PSLRFL, PEMIS=PEMIS, PTICE=PTICE, PTSN=PTSN, &
 & PHLICE=PHLICE, PTLICE=PTLICE, PTLWML=PTLWML, &
 & PTHKICE=PTHKICE, PSNTICE=PSNTICE, &
 & PWLMX=PWLMX, PUCURR=PUCURR, PVCURR=PVCURR, PI10FGCV=PI10FGCV,&
 & PTSAM1M=PTSAM1M, PWSAM1M=PWSAM1M, KSOTY=KSOTY, &
 & PFRTI=PFRTI, PALBTI=PALBTI, &
 & PUSTRTI=PUSTRTI, PVSTRTI=PVSTRTI, PAHFSTI=PAHFSTI, PEVAPTI=PEVAPTI, &
 & PTSKTI=PTSKTI, &
 & PANDAYVT=PANDAYVT, PANFMVT=PANFMVT, &
 & PZ0M=PZ0M, PZ0H=PZ0H, &
 & PSSRFLTI=PSSRFLTI, PQSTI=ZQSTI, PDQSTI=ZDQSTI, PCPTSTI=ZCPTSTI, &
 & PCFHTI=ZCFHTI, PCFQTI=ZCFQTI, PCSATTI=ZCSATTI, PCAIRTI=ZCAIRTI, &
 & PCPTSTIU=ZCPTSTIU, PCSATTIU=ZCSATTIU, PCAIRTIU=ZCAIRTIU, PRAQTI=ZRAQTI, &
 & PTSRF=ZTSRF, PLAMSK=ZLAMSK,&
 & PKHLEV=PKH(:, KLEV), PKCLEV=ZRAQ, PCFMLEV=ZCFM(:, KLEV), PKMFL=ZKMFL, PKHFL=ZKHFL, &
 & PKQFL=ZKQFL, PEVAPSNW=PEVAPSNW, PZ0MW=ZZ0MW, PZ0HW=ZZ0HW, PZ0QW=ZZ0QW, &
 & PBLENDPP=ZBLEND, PCPTSPP=ZZCPTS, PQSAPP=ZZQSA, PBUOMPP=ZZBUOM, &
 & PZDLPP=ZZZDL, &
 & PAN=PAN, PAG=PAG, PRD=PRD, PRSOIL_STR=PRSOIL_STR, PRECO=PRECO, PCO2FLUX=PCO2FLUX, PCH4FLUX=PCH4FLUX, &
 &  PWETB=ZWETB, PWETL=ZWETL, PWETLU=ZWETLU, PWETH=ZWETH, PWETHS=ZWETHS, &
 & PDHTLS=PDHTLS, PDHTSS=PDHTSS, PDHTTS=PDHTTS, PDHTIS=PDHTIS, &
 & PDHVEGS=PDHVEGS, PEXDIAG=PEXDIAG, PDHCO2S=PDHCO2S, &
 & PRPLRG=RPLRG, &
 & LSICOUP=LSICOUP, status=status)
IF (status /= 0) return

!  Update total flux of compo tracers with fluxes computed in land surface model

!     ------------------------------------------------------------------

!*         3.     NEW VARIABLES S, SLG, QT
!*                (at initial time level)
!                 ------------------------

DO JK = ILEV, KLEV
  DO JL = KIDIA, KFDIA

!*             total water and generalized liquid water static energy
!*              slg = cp*T + gz - Lcond*ql

    ZSLGM1(JL, JK) = ZCPTGZ(JL, JK) - physical%rlvtt*PLM1(JL, JK)
    ZSLGE(JL, JK) = physical%rcpd*((1.0_JPRB + thermal%rvtmp2*PQM1(JL, JK))*PTE(JL, JK) &!dcpT/dt
                & + thermal%rvtmp2*PTM1(JL, JK)*PQE(JL, JK)) &                    !  -"-
                & - physical%rlvtt*PLE(JL, JK)
    ZQTM1(JL, JK) = PQM1(JL, JK) + PLM1(JL, JK)
    ZSLGSM1(JL, JK) = ZSLGM1(JL, JK) + physical%rcpd*PTM1(JL, JK)*5.87_JPRB*ZQTM1(JL, JK)
    ZQTE(JL, JK) = PQE(JL, JK) + PLE(JL, JK)                     !dyn. qt tendency
    ZSLGEA(JL, JK) = ZSLGE(JL, JK)
    ZQTEA(JL, JK) = ZQTE(JL, JK)

  END DO
END DO

!     ------------------------------------------------------------------

!*         5.     EXCHANGE COEFFICIENTS
!                 ---------------------

!*         5.4  COMPUTATION OF THE PBL EXTENSION

ITOP = 1

!          FLUX BOUNDARY CONDITION
IF (LLSFCFLX) THEN
  DO JL = KIDIA, KFDIA
    ZRHO = PAPHM1(JL, KLEV)/(physical%rd*PTM1(JL, KLEV)*(1.0_JPRB + physical%retv*PQM1(JL, KLEV)))
    ZKHFL(JL) = ZEXTSHF(JL)/(physical%rcpd*(1.0_JPRB + thermal%rvtmp2*PQM1(JL, KLEV)))/ZRHO
    ZKQFL(JL) = ZEXTLHF(JL)/physical%rlvtt/ZRHO
  END DO
END IF

!*         5.5  BOUNDARY LAYER HEIGHT FOR DIANOSTICS ONLY

CALL vdfdpbl(KIDIA, KFDIA, KLON, KLEV,&
 & PUM1, PVM1, PTM1, PQM1, PGEOM1,&
 & ZKMFL, ZKHFL, ZKQFL, PBLH, physical%rg, physical%rcpd, physical%retv, rplrg, status=status)
IF (status /= 0) return

!*         5.6  PARCEL UPDRAFT

DO JL = KIDIA, KFDIA
  IF (PFRTI(JL, 1) + PFRTI(JL, 2) > 0.5_JPRB) THEN
    LLAND(JL) = .FALSE.
  ELSE
    LLAND(JL) = .TRUE.
  END IF
END DO

status = vdfhghtn(physical, thermal, rplrg, planet_scale, physics%linear_ecmwf, YDECLDP, YDECUMF, YDVDF, YDSPP_CONFIG, &
             & KIDIA, KFDIA, KLON, KLEV, PTSPHY, LLAND,&
             & PTM1, PQM1, ZSLGSM1, PUM1, PVM1, ZCPTGZ,&
             & PAPHM1, PAPM1, PGEOM1, PGEOH, PBLH,&
             & ZKMFL, ZKHFL, ZKQFL, PGP2DSPP, ZKHVFL, ZMFLX,&
             & ZSLGUH, ZQTUH, ZUUH, ZVUH, &
             & PZINV, IINV, ICBASE, ICTOP, ZCLDBASE, PRI, PEIS, KPBLTYPE)
IF (status /= 0) return

!* correction for unstable PBL if only PBLTYPE=1 is found but cloud/fog  do exist
DO JL = KIDIA, KFDIA
  ZLIMIN(JL) = 0.0_JPRB
  LLFIRST(JL) = .TRUE.
  LLTEST(JL) = KPBLTYPE(JL) == 1 .AND. PZINV(JL) < 200._JPRB .AND. ZKHVFL(JL)*physical%rcpd > -20._JPRB
END DO
DO JK = KLEV, NJKT6, -1
 DO JL = KIDIA, KFDIA
  IF (PGEOH(JL, JK)*ZRG <= MAX(PBLH(JL), PZINV(JL)) .AND. LLTEST(JL)) THEN
    IF (PLM1(JL, JK) + PIM1(JL, JK) > ZLIMIN(JL)) THEN
      PZINV(JL) = PGEOM1(JL, JK)*ZRG
      IF (LLFIRST(JL)) ICBASE(JL) = JK
      LLFIRST(JL) = .FALSE.
      ICTOP(JL) = JK
      IINV(JL) = JK
      KPBLTYPE(JL) = 2
      ZLIMIN(JL) = PLM1(JL, JK) + PIM1(JL, JK)
    END IF
  END IF
 END DO
END DO

!  Stochastic perturbation of transfer coefficients for momentum
!  Different amplitude over land and ocean

!* correction for unstable PBL if only PBLTYPE=1 is found but cloud/fog  do exist
DO JL = KIDIA, KFDIA
  ZLIMIN(JL) = 0.0_JPRB
  LLFIRST(JL) = .TRUE.
  LLTEST(JL) = KPBLTYPE(JL) == 1 .AND. PZINV(JL) < 200._JPRB .AND. ZKHVFL(JL)*physical%rcpd > -20._JPRB
END DO
DO JK = KLEV, NJKT6, -1
 DO JL = KIDIA, KFDIA
  IF (PGEOH(JL, JK)*ZRG <= MAX(PBLH(JL), PZINV(JL)) .AND. LLTEST(JL)) THEN
    IF (PLM1(JL, JK) + PIM1(JL, JK) > ZLIMIN(JL)) THEN
      PZINV(JL) = PGEOM1(JL, JK)*ZRG
      IF (LLFIRST(JL)) ICBASE(JL) = JK
      LLFIRST(JL) = .FALSE.
      ICTOP(JL) = JK
      IINV(JL) = JK
      KPBLTYPE(JL) = 2
      ZLIMIN(JL) = PLM1(JL, JK) + PIM1(JL, JK)
    END IF
  END IF
 END DO
END DO

!*         5.7  EXCHANGE COEFFICIENTS ABOVE THE SURFACE LAYER

status = vdfexcu(physical, stability, parameters%orographic_gravity_wave, surface, YDSPP_CONFIG, &
           & KIDIA, KFDIA, KLON, KLEV, &
           & IINV, ICBASE, ICTOP, RLAM, PZ0M, &
           & PHRLW, PHRSW, PUM1, PVM1, PTM1, PQM1, &
           & PAPHM1, PGEOM1, PGEOH, PGELAT, ZCPTGZ, &
           & ZKMFL, ZKHFL, ZKQFL, ZKHVFL, PGP2DSPP, ZCFM, ZCFH, &
           & PZINV, PKH, PKM, PRI, ZCLDBASE, KPBLTYPE, rplrg, planet_scale)
IF (status /= 0) return

    PTKEE(:, :) = 0.0_JPRB
!*         5.8  MASS FLUX MODIFICATIONS

!          Selective mflux=0 for single mflux layers
DO JL = KIDIA, KFDIA
  IF (ZMFLX(JL, KLEV - 2) < ZEPSILON) THEN
    ZMFLX(JL, KLEV - 1) = 0.0_JPRB
  END IF
END DO

!*         5.9     TURBULENT OROGRAPHIC DRAG COEFFICIENTS

status = vdftofdc(YDVDF, KIDIA, KFDIA, KLON, KLEV,&
 & PUM1, PVM1, PGEOM1, PSIGFLT,&
 & ZTOFDC, physical%rg, rplrg)
IF (status /= 0) return

!  Stochastic perturbation of drag coefficients in TOFD scheme

!     ------------------------------------------------------------------

!*         6.     SOLVE ADVECTION-DIFFUSION EQUATION
!                 ----------------------------------

!
IF (LWDS) THEN
  !          6.1  Time integration according to predictor corrector method by
  !               Wood, Diamantakis and Staniforth (2007,QJRMS,133,1559-1573)
  !
  ZTPFAC2 = REPS1WDS/RETAWDS
  ZTPFAC3 = 1.-ZTPFAC2
  ZTMST = PTSPHY*RETAWDS
  !
  !               Predictor call for momentum
  !
  status = vdfdifm(KIDIA, KFDIA, KLON, KLEV, ITOP, &
            & ZTMST, PUM1, PVM1, PAPHM1, ZCFM, ZTOFDC, &
            & PSOTEU, PSOTEV, PSOBETA,&
            & PVOM, PVOL, PUCURR, PVCURR, ZMFLX, ZUUH, ZVUH,&
            & ZUDIF, ZVDIF, ZDTUTOFD1, ZDTVTOFD1, ZDTUSO1, ZDTVSO1, ZDTUVDF1, ZDTVVDF1, physical%rg)
IF (status /= 0) return
  !
  !               Computation of star-values and corrector call for momentum
  !
  DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZUM1S(JL, JK) = ZTPFAC3*ZUDIF(JL, JK) + ZTPFAC2*PUM1(JL, JK)
      ZVM1S(JL, JK) = ZTPFAC3*ZVDIF(JL, JK) + ZTPFAC2*PVM1(JL, JK)
    END DO
  END DO
  status = vdfdifm(KIDIA, KFDIA, KLON, KLEV, ITOP, &
            & ZTMST, ZUM1S, ZVM1S, PAPHM1, ZCFM, ZTOFDC, &
            & PSOTEU, PSOTEV, PSOBETA,&
            & PVOM, PVOL, PUCURR, PVCURR, ZMFLX, ZUUH, ZVUH,&
            & ZUDIF, ZVDIF, ZDTUTOFD, ZDTVTOFD, ZDTUSO, ZDTVSO, ZDTUVDF, ZDTVVDF, physical%rg)
IF (status /= 0) return
  ZW1 = RETAWDS - REPS1WDS
  ZW2 = RETAWDS - REPS2WDS
  DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZDTUTOFD(JL, JK) = ZW1*ZDTUTOFD1(JL, JK) + ZW2*ZDTUTOFD(JL, JK)
      ZDTVTOFD(JL, JK) = ZW1*ZDTVTOFD1(JL, JK) + ZW2*ZDTVTOFD(JL, JK)
      ZDTUSO(JL, JK) = ZW1*ZDTUSO1(JL, JK) + ZW2*ZDTUSO(JL, JK)
      ZDTVSO(JL, JK) = ZW1*ZDTVSO1(JL, JK) + ZW2*ZDTVSO(JL, JK)
      ZDTUVDF(JL, JK) = ZW1*ZDTUVDF1(JL, JK) + ZW2*ZDTUVDF(JL, JK)
      ZDTVVDF(JL, JK) = ZW1*ZDTVVDF1(JL, JK) + ZW2*ZDTVVDF(JL, JK)
    END DO
  END DO
  !
  !               Predictor call for heat and moisture
  !
  CALL vdfdifh(physical, thermal, planet_scale, surface, controls%nemo_limit_thickness, source_time_step, YDEPHY, &
            & KIDIA, KFDIA, KLON, KLEV, ITOP, KTILES, &
            & KTVL, KTVH, ZTMST, ZEXTSHF, ZEXTLHF, LLSFCFLX, &
            & PFRTI, PSSRFLTI, PSLRFL, PEMIS, PEVAPSNW, &
            & PHLICE, PTLICE, PTLWML, &
            & ZSLGM1, ZQTM1, PAPHM1, &
            & ZCFH, ZCFHTI, ZCFQTI, ZMFLX, ZSLGUH, ZQTUH, &
            & ZSLGDIF, ZQTDIF, ZCPTSTI, ZQSTI, ZCAIRTI, ZCSATTI, &
            & ZCPTSTIU, ZCAIRTIU, ZCSATTIU, ZTSRF, ZLAMSK, &
            & ZDQSTI, PTSKTI, PTSKRAD, PTSAM1M(1, 1), &
            & PTSN(1, 1), PSNM(1, 1), PRSN(1, 1), PTICE, PSST, &
            & PTHKICE, PSNTICE, &
            & ZTSKTIH, ZSLGE, ZQTE, ZSLGEVDF1, ZQTEVDF1, ZTSKTITE1,&
            & ZEVAPTI1, ZAHFSTI1, ZAHFLTI1, ZFLTRTI1, ZG01, ZEVAPUTI1, status=status)
IF (status /= 0) return
  !
  !              Computation of star-values and corrector call for heat/moisture
  !              Note: The input for TSK is not updated, because TSK is
  !                    diagnostic and does not have a d/dt term. TSK is
  !                    needed at the start of the time step (time level n)
  !                    because non-linear terms are linearized (e.g. qsat)
  !                    around the skin temperature that time level.
  !
  DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZSLGM1S(JL, JK) = ZTPFAC3*ZSLGDIF(JL, JK) + ZTPFAC2*ZSLGM1(JL, JK)
      ZQTM1S(JL, JK) = ZTPFAC3*ZQTDIF(JL, JK) + ZTPFAC2*ZQTM1(JL, JK)
    END DO
  END DO
  CALL vdfdifh(physical, thermal, planet_scale, surface, controls%nemo_limit_thickness, source_time_step, YDEPHY, &
            & KIDIA, KFDIA, KLON, KLEV, ITOP, KTILES, &
            & KTVL, KTVH, ZTMST, ZEXTSHF, ZEXTLHF, LLSFCFLX, &
            & PFRTI, PSSRFLTI, PSLRFL, PEMIS, PEVAPSNW, &
            & PHLICE, PTLICE, PTLWML, &
            & ZSLGM1S, ZQTM1S, PAPHM1, &
            & ZCFH, ZCFHTI, ZCFQTI, ZMFLX, ZSLGUH, ZQTUH, &
            & ZSLGDIF, ZQTDIF, ZCPTSTI, ZQSTI, ZCAIRTI, ZCSATTI, &
            & ZCPTSTIU, ZCAIRTIU, ZCSATTIU, ZTSRF, ZLAMSK,&
            & ZDQSTI, PTSKTI, PTSKRAD, PTSAM1M(1, 1),&
            & PTSN(1, 1), PSNM(1, 1), PRSN(1, 1), PTICE, PSST, &
            & PTHKICE, PSNTICE, &
            & ZTSKTIH, ZSLGE, ZQTE, ZSLGEVDF, ZQTEVDF, ZTSKTITE,&
            & PEVAPTI, PAHFSTI, ZAHFLTI, PFLTRTI, ZG0, ZEVAPUTI, status=status)
IF (status /= 0) return
  ZW1 = RETAWDS - REPS1WDS
  ZW2 = RETAWDS - REPS2WDS
  DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZSLGEVDF(JL, JK) = ZW1*ZSLGEVDF1(JL, JK) + ZW2*ZSLGEVDF(JL, JK)
      ZQTEVDF(JL, JK) = ZW1*ZQTEVDF1(JL, JK) + ZW2*ZQTEVDF(JL, JK)
    END DO
  END DO

  DO JT = 1, KTILES
    DO JL = KIDIA, KFDIA
      ZTSKTITE(JL, JT) = ZW1*ZTSKTITE1(JL, JT) + ZW2*ZTSKTITE(JL, JT)
      ZTSKTIP1(JL, JT) = PTSKTI(JL, JT) + ZTSKTITE(JL, JT)*PTSPHY
    END DO
  END DO

  DO JT = 1, KTILES
    DO JL = KIDIA, KFDIA
      PEVAPTI(JL, JT) = ZW1*ZEVAPTI1(JL, JT) + ZW2*PEVAPTI(JL, JT)
      PAHFSTI(JL, JT) = ZW1*ZAHFSTI1(JL, JT) + ZW2*PAHFSTI(JL, JT)
      ZAHFLTI(JL, JT) = ZW1*ZAHFLTI1(JL, JT) + ZW2*ZAHFLTI(JL, JT)
      PFLTRTI(JL, JT) = ZW1*ZFLTRTI1(JL, JT) + ZW2*PFLTRTI(JL, JT)
      ZG0(JL, JT) = ZW1*ZG01(JL, JT) + ZW2*ZG0(JL, JT)
    END DO
  END DO

  JTILE = 4
  DO JL = KIDIA, KFDIA
    PEVAPMU(JL) = ZW1*ZEVAPUTI1(JL, JTILE) + ZW2*ZEVAPUTI(JL, JTILE)
  END DO

ELSE

  !        6.2  Over-implicit scheme with implicitness factor RVDIFTS.
  !             Note: RVDIFTS is only used to scale the time step
  !

  ZTMST = PTSPHY*RVDIFTS

  !         X,Y components of horizontal momentum

  status = vdfdifm(KIDIA, KFDIA, KLON, KLEV, ITOP, &
            & ZTMST, PUM1, PVM1, PAPHM1, ZCFM, ZTOFDC, &
            & PSOTEU, PSOTEV, PSOBETA,&
            & PVOM, PVOL, PUCURR, PVCURR, ZMFLX, ZUUH, ZVUH,&
            & ZUDIF, ZVDIF, ZDTUTOFD, ZDTVTOFD, ZDTUSO, ZDTVSO, ZDTUVDF, ZDTVVDF, physical%rg)
IF (status /= 0) return

  !         Generalized liquid water static energy and total water

  CALL vdfdifh(physical, thermal, planet_scale, surface, controls%nemo_limit_thickness, source_time_step, YDEPHY, &
            & KIDIA, KFDIA, KLON, KLEV, ITOP, KTILES, &
            & KTVL, KTVH, ZTMST, ZEXTSHF, ZEXTLHF, LLSFCFLX, &
            & PFRTI, PSSRFLTI, PSLRFL, PEMIS, PEVAPSNW, &
            & PHLICE, PTLICE, PTLWML, &
            & ZSLGM1, ZQTM1, PAPHM1, &
            & ZCFH, ZCFHTI, ZCFQTI, ZMFLX, ZSLGUH, ZQTUH, &
            & ZSLGDIF, ZQTDIF, ZCPTSTI, ZQSTI, ZCAIRTI, ZCSATTI, &
            & ZCPTSTIU, ZCAIRTIU, ZCSATTIU, ZTSRF, ZLAMSK,&
            & ZDQSTI, PTSKTI, PTSKRAD, PTSAM1M(1, 1), &
            & PTSN(1, 1), PSNM(1, 1), PRSN(1, 1), PTICE, PSST, &
            & PTHKICE, PSNTICE, &
            & ZTSKTIH, ZSLGE, ZQTE, ZSLGEVDF, ZQTEVDF, ZTSKTITE,&
            & PEVAPTI, PAHFSTI, ZAHFLTI, PFLTRTI, ZG0, ZEVAPUTI, status=status)
IF (status /= 0) return

  DO JT = 1, KTILES
    DO JL = KIDIA, KFDIA
      ZTSKTIP1(JL, JT) = PTSKTI(JL, JT) + ZTSKTITE(JL, JT)*PTSPHY
    END DO
  END DO
  JTILE = 4
  DO JL = KIDIA, KFDIA
    PEVAPMU(JL) = ZEVAPUTI(JL, JTILE)
  END DO
END IF

!*         6.3  INCREMENTATION OF U AND V TENDENCIES, STORAGE OF
!*              THE DISSIPATION, COMPUTATION OF MULTILEVEL FLUXES.

status = vdfincr(KIDIA, KFDIA, KLON, KLEV, ITOP, PTSPHY, &
            & PUM1, PVM1, ZSLGM1, PTM1, ZQTM1, PAPHM1, &
            & ZDTUTOFD, ZDTVTOFD, ZDTUSO, ZDTVSO, ZDTUVDF, ZDTVVDF,&
            & PVOM, PVOL, ZSLGE, ZQTE, &
            & ZSLGEVDF, ZQTEVDF, ZSLGEWODIS, &
            & PVDIS, PVDISG, PSTRTU, PSTRTV, PSTRSOU, PSTRSOV, &
            & ZSTRTOFDU, ZSTRTOFDV, PTOFDU, PTOFDV, &
            & PDISGW3D, physical%rg)
IF (status /= 0) return

!     ------------------------------------------------------------------

!*         7.     SURFACE FLUXES - TILES
!                 ----------------------
!*         AND    COMPUTE 2M TEMPERATURE AND HUMIDITY, 10M WIND,
!*                  and gustiness

!  Compute wind speed at blending height

CALL vdffblend(KIDIA, KFDIA, KLON, KLEV, &
 & PUM1, PVM1, PGEOM1, PUCURR, PVCURR, ZBLEND, &
 & ZFBLEND, physical%rg, status=status)
IF (status /= 0) return

! Wrap-up computations for the surface and 2T/2D/10U/10V/gustiness computation

! input
! updated
! output
! output DDH
CALL surfpp(thermal, stability, YSURF, KIDIA=KIDIA, KFDIA=KFDIA, KLON=KLON, KTILES=KTILES, &
 & KDHVTLS=KDHVTLS, KDHFTLS=KDHFTLS, &
 & PTSTEP=PTSPHY, &
 & PFRTI=PFRTI, PAHFLTI=ZAHFLTI, PG0TI=ZG0, &
 & PSTRTULEV=PSTRTU(:, KLEV), PSTRTVLEV=PSTRTV(:, KLEV), PTSKM1M=PTSKM1M, &
 & PUMLEV=PUM1(:, KLEV), PVMLEV=PVM1(:, KLEV), PQMLEV=PQM1(:, KLEV), &
 & PGEOMLEV=PGEOM1(:, KLEV), PCPTSPP=ZZCPTS, PCPTGZLEV=ZCPTGZ(:, KLEV), &
 & PAPHMS=PAPHM1(:, KLEV), PZ0MW=ZZ0MW, PZ0HW=ZZ0HW, PZ0QW=ZZ0QW, &
 & PZDL=ZZZDL, PQSAPP=ZZQSA, PBLEND=ZBLEND, PFBLEND=ZFBLEND, PBUOM=ZZBUOM, &
 & PZ0M=PZ0M, PEVAPSNW=PEVAPSNW, PSSRFLTI=PSSRFLTI, PSLRFL=PSLRFL, PSST=PSST, &
 & PUCURR=PUCURR, PVCURR=PVCURR, PUSTOKES=PUSTOKES, PVSTOKES=PVSTOKES, &
 & PAHFSTI=PAHFSTI, PEVAPTI=PEVAPTI, PTSKE1=PTSKE1, PTSKTIP1=ZTSKTIP1, &
 & PDIFTSLEV=PDIFTS(:, KLEV), PDIFTQLEV=PDIFTQ(:, KLEV), PUSTRTI=PUSTRTI, &
 & PVSTRTI=PVSTRTI, PTSKTI=PTSKTI, PAHFLEV=PAHFLEV, PAHFLSB=PAHFLSB, &
 & PFWSB=PFWSB, PU10M=PU10M, PV10M=PV10M, PT2M=PT2M, PD2M=PD2M, PQ2M=PQ2M, &
 & PGUST=PGUST, P10NU=P10NU, P10NV=P10NV, PUST=PUST, &
 & PDHTLS=PDHTLS, &
 & PRPLRG=RPLRG, status=status)
IF (status /= 0) return

PDIFTL(KIDIA:KFDIA, KLEV) = 0.0_JPRB
PDIFTI(KIDIA:KFDIA, KLEV) = 0.0_JPRB
ZDIFTQT(KIDIA:KFDIA, KLEV) = 0.0_JPRB
ZDIFTSLG(KIDIA:KFDIA, KLEV) = 0.0_JPRB
ZDIFTQT(KIDIA:KFDIA, KLEV) = PDIFTQ(KIDIA:KFDIA, KLEV)
ZDIFTSLG(KIDIA:KFDIA, KLEV) = PDIFTS(KIDIA:KFDIA, KLEV)

!     ------------------------------------------------------------------

!*         9.     SLG, QT, U, V FLUX COMPUTATIONS AND T,SKIN TENDENCY
!                 ---------------------------------------------------

DO JL = KIDIA, KFDIA
  ZDIFTQT(JL, 0) = 0.0_JPRB
  PDIFTQ(JL, 0) = 0.0_JPRB
  PDIFTL(JL, 0) = 0.0_JPRB
  PDIFTI(JL, 0) = 0.0_JPRB
  PDIFTS(JL, 0) = 0.0_JPRB
  ZDIFTSLG(JL, 0) = 0.0_JPRB
  PSTRTU(JL, 0) = 0.0_JPRB
  PSTRTV(JL, 0) = 0.0_JPRB
END DO

DO JK = KLEV - 1, 1, -1
  DO JL = KIDIA, KFDIA
    ZGDPH = -(PAPHM1(JL, JK) - PAPHM1(JL, JK + 1))*ZRG
!...change in slg,qt,u,v tendencies are converted to fluxes
    ZDIFTSLG(JL, JK) = (ZSLGEWODIS(JL, JK + 1) - ZSLGEA(JL, JK + 1))*ZGDPH &
                    & + ZDIFTSLG(JL, JK + 1)
    ZDIFTQT(JL, JK) = (ZQTE(JL, JK + 1) - ZQTEA(JL, JK + 1))*ZGDPH + ZDIFTQT(JL, JK + 1)
  END DO
END DO

!          Solve diffusion equation for tracers and calculate dry deposition velocities online

!     ------------------------------------------------------------------

DO JK = 1, KLEV
  DO JL = KIDIA, KFDIA
    PTE(JL, JK) = (ZSLGE(JL, JK) + physical%rlvtt*PLE(JL, JK))&
                 &/(physical%rcpd*(1.0_JPRB + thermal%rvtmp2*PQM1(JL, JK)))
    PQE(JL, JK) = ZQTE(JL, JK) - PLE(JL, JK)

    ! Correction in case of very low (<REPQMI) or negative humidity
    ZW1 = PQM1(JL, JK) + PQE(JL, JK)*PTSPHY ! Updated humidity
    ZW2 = PLM1(JL, JK) + PIM1(JL, JK) + (PLE(JL, JK) + PIE(JL, JK))*PTSPHY ! Updated cloud
    IF (ZW1 < REPQMI .AND. ZW2 > REPQMI) THEN
      ZW1 = REPQMI - ZW1
      ZW1 = MIN(ZW1, ZW2)/PTSPHY
    ! ZW4 = 1.0_JPRB/MAX(1.E-10_JPRB,PLM1(JL,JK)+PIM1(JL,JK))
      ! MAX(REPQMI,ZW2) instead of just ZW2 below to avoid spurious FPE
      ZW4 = 1.0_JPRB/MAX(REPQMI, ZW2)
      ! Increase humidity
      PQE(JL, JK) = PQE(JL, JK) + ZW1
      ZW3 = MAX(0.0_JPRB, PLM1(JL, JK) + PLE(JL, JK)*PTSPHY)*ZW4
      ! Take moisture from any cloud liquid present
      PLE(JL, JK) = PLE(JL, JK) - ZW3*ZW1
      PTE(JL, JK) = PTE(JL, JK) - physical%rlvtt/physical%rcpd*ZW3*ZW1
      ! Take moisture from any cloud ice present
     !ZW3 = MAX(0.0_JPRB,PIM1(JL,JK)+PIE(JL,JK)*PTSPHY)*ZW4
      ZW3 = 1.0_JPRB - ZW3
      PIE(JL, JK) = PIE(JL, JK) - ZW3*ZW1
      PTE(JL, JK) = PTE(JL, JK) - physical%rlstt/physical%rcpd*ZW3*ZW1
   END IF
  END DO
END DO

!     ------------------------------------------------------------------

!*         12.    Q, QL, QI AND S FLUX COMPUTATIONS
!                 ---------------------------------

DO JK = KLEV - 1, 1, -1
  DO JL = KIDIA, KFDIA
    PDIFTL(JL, JK) = PDIFTL(JL, JK + 1)
    PDIFTI(JL, JK) = PDIFTI(JL, JK + 1)
    PDIFTQ(JL, JK) = ZDIFTQT(JL, JK) - PDIFTL(JL, JK) - PDIFTI(JL, JK)
    PDIFTS(JL, JK) = ZDIFTSLG(JL, JK) + physical%rlvtt*PDIFTL(JL, JK) + physical%rlstt*PDIFTI(JL, JK)
  END DO
END DO

!     ------------------------------------------------------------------

status = 0
END ASSOCIATE
END SUBROUTINE VDFMAIN

end module forecast_native_vertical_diffusion
