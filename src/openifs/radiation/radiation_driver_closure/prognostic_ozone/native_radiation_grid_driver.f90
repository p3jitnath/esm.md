!> Pack same-grid radiation fields, run the complete column and update fluxes.
!! Coordinates and coefficient records are borrowed from their native owners.
!! Pressure is Pa; input temperatures are kelvin and returned fluxes W/m2.
!! Original ECMWF RADINTG arithmetic and78 ordered field selectors are retained.
module native_radiation_grid_driver
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, JPRD => real64, int32, real64
  use yomhook, only: lhook, dr_hook, jphook
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use native_radiation_aerosol_and_ozone, only: runtime_radact
  use native_radiation_climatology_profiles, only: radozc, radghg
  use native_radiation_field_preparation, only: radiation_scheme
  use forecast_public_scalar_math, only: power_original_rounding
  use native_radiation_clock_views, only: radiation_clock_is_ready
  implicit none
  private

  public :: radintg
contains
subroutine radintg(context,KLEV,KMODE,PALBD,PALBP,PCCNL,PCCNO,PAPRS,PAPRSF,PCCO2,PCLFR,PQO3,PAER,PAERMACCS,PAERMACCL,PAERMACCSJ,PAERMACCLJ,PAERTGS,PAERTGL,PAERO,PGHG,PDP,PSPECTRALEMISS,PMU0,PQ,PQS,PQIWP,PQSWP,PQLWP,PFSDP,PQRAIN,PRAINT,PSLM,PT,PECPO3,PTS,PEMTD,PEMTU,PTRSO,PTRSC,PEMTC,PNTOP,PNBAS,PPERTT,PEMIT,PTH,PFRTED,PTRSOD,PTRSODC,PEMTDC,PSUDU,PUVDF,PPARF,PPARCF,PTINCF,PFDIR,PCDIR,PLWDERIVATIVE,status)
    type(native_radiation_driver_context), intent(inout) :: context
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KMODE
    REAL(KIND=JPRB), INTENT(IN) :: PALBD(context%local_points, context%setup%radiation%NTSW)
    REAL(KIND=JPRB), INTENT(IN) :: PALBP(context%local_points, context%setup%radiation%NTSW)
    REAL(KIND=JPRB), INTENT(IN) :: PCCNL(context%local_points)
    REAL(KIND=JPRB), INTENT(IN) :: PCCNO(context%local_points)
    REAL(KIND=JPRB), INTENT(IN) :: PAPRS(context%local_points, KLEV + 1)
    REAL(KIND=JPRB), INTENT(IN) :: PAPRSF(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PCCO2
    REAL(KIND=JPRB), INTENT(IN) :: PCLFR(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQO3(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAER(context%local_points, 6, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAERMACCS(context%local_points, 14)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAERMACCL(context%local_points, 16)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAERMACCSJ(context%local_points, 12)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAERMACCLJ(context%local_points, 12)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAERTGS(context%local_points, KLEV, 14)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAERTGL(context%local_points, KLEV, 16)
    REAL(KIND=JPRB), INTENT(IN) :: PAERO(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGHG(context%local_points, 8, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PDP(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PSPECTRALEMISS(context%local_points, context%setup%radiation%NLWEMISS)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(context%local_points)
    REAL(KIND=JPRB), INTENT(IN) :: PQ(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQS(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQIWP(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQSWP(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQLWP(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PFSDP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQRAIN(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PRAINT(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PSLM(context%local_points)
    REAL(KIND=JPRB), INTENT(IN) :: PT(context%local_points, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PECPO3(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTS(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMTD(context%local_points, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMTU(context%local_points, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTRSO(context%local_points, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTRSC(context%local_points, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMTC(context%local_points, KLEV + 1)
    REAL(KIND=JPRB), INTENT(IN) :: PNTOP(context%local_points)
    REAL(KIND=JPRB), INTENT(IN) :: PNBAS(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMIT(context%local_points)
    REAL(KIND=JPRB), INTENT(IN) :: PPERTT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTH(context%local_points, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFRTED(context%local_points, context%setup%radiation%NLWOUT)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTRSOD(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTRSODC(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMTDC(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSUDU(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PUVDF(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PPARF(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PPARCF(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTINCF(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFDIR(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCDIR(context%local_points)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLWDERIVATIVE(context%local_points, KLEV + 1)
    REAL(KIND=JPRB) :: ZAMU0(context%local_points)
    REAL(KIND=JPRB) :: ZQAER(context%block_columns, 6, KLEV)
    REAL(KIND=JPRB) :: ZQAERO(context%block_columns, KLEV, 12)
    REAL(KIND=JPRB) :: ZQOZ(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQCO2(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQCH4(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQN2O(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQNO2(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQC11(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQC12(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQOZO(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQC22(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQCL4(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZLWFC(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZSWFC(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZFRTH(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZFRSO(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZLWDERIVATIVE(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZFRSOD(context%block_columns)
    REAL(KIND=JPRB) :: ZFRTED(context%block_columns, context%setup%radiation%NLWOUT)
    REAL(KIND=JPRB) :: ZFRSODC(context%block_columns)
    REAL(KIND=JPRB) :: ZFRTEDC(context%block_columns)
    REAL(KIND=JPRB) :: ZCAPH(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZCHTI(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZCLC(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQLWP(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQIWP(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQRWP(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQSWP(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZTRSO(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZEMTD(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZEMTU(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZTRSC(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZEMTC(context%block_columns, KLEV + 1)
    REAL(KIND=JPRB) :: ZRHCL(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZTRSOD(context%block_columns)
    REAL(KIND=JPRB) :: ZTRSODC(context%block_columns)
    REAL(KIND=JPRB) :: ZEMTDC(context%block_columns)
    REAL(KIND=JPRB) :: ZSUDU(context%block_columns)
    REAL(KIND=JPRB) :: ZUVDF(context%block_columns)
    REAL(KIND=JPRB) :: ZPARF(context%block_columns)
    REAL(KIND=JPRB) :: ZPARCF(context%block_columns)
    REAL(KIND=JPRB) :: ZTINCF(context%block_columns)
    REAL(KIND=JPRB) :: ZFDIR(context%block_columns)
    REAL(KIND=JPRB) :: ZCDIR(context%block_columns)
    REAL(KIND=JPRB) :: ZEMIT(context%block_columns)
    REAL(KIND=JPRB) :: ZECPO3(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZQSAT(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZDP(context%block_columns, KLEV)
    REAL(KIND=JPRB) :: ZTAUAER(context%block_columns, 5)
    INTEGER(KIND=JPIM) :: IFLAG
    REAL(KIND=JPRB), ALLOCATABLE :: ZRGP(:, :, :)
    REAL(KIND=JPRD), ALLOCATABLE :: ZDGEMU(:, :)
    REAL(KIND=JPRB) :: ZAERTAUL(context%block_columns, KLEV, 16)
    REAL(KIND=JPRB) :: ZAERASYL(context%block_columns, KLEV, 16)
    REAL(KIND=JPRB) :: ZAEROMGL(context%block_columns, KLEV, 16)
    REAL(KIND=JPRB) :: ZAERTAUS(context%block_columns, KLEV, 14)
    REAL(KIND=JPRB) :: ZAERASYS(context%block_columns, KLEV, 14)
    REAL(KIND=JPRB) :: ZAEROMGS(context%block_columns, KLEV, 14)
    REAL(KIND=JPRB) :: ZAERTAUSJ(context%block_columns, KLEV, 12)
    REAL(KIND=JPRB) :: ZAERTAULJ(context%block_columns, KLEV, 12)
    REAL(KIND=JPRB) :: ZAERMACCM(context%block_columns, KLEV, 12)
    INTEGER(KIND=JPIM) :: I
    INTEGER(KIND=JPIM) :: IBEG
    INTEGER(KIND=JPIM) :: IEND
    INTEGER(KIND=JPIM) :: IB
    INTEGER(KIND=JPIM) :: IL
    INTEGER(KIND=JPIM) :: I1
    INTEGER(KIND=JPIM) :: I2
    INTEGER(KIND=JPIM) :: JAERO
    INTEGER(KIND=JPIM) :: JK
    INTEGER(KIND=JPIM) :: JL
    INTEGER(KIND=JPIM) :: JLEV
    INTEGER(KIND=JPIM) :: JRL
    INTEGER(KIND=JPIM) :: JSW
    INTEGER(KIND=JPIM) :: JLW
    INTEGER(KIND=JPIM) :: JSTGLO
    INTEGER(KIND=JPIM) :: INEXT
    INTEGER(KIND=JPIM) :: IINBEG
    INTEGER(KIND=JPIM) :: IINEND
    INTEGER(KIND=JPIM) :: IOUTBEG
    INTEGER(KIND=JPIM) :: IOUTEND
    INTEGER(KIND=JPIM) :: IFLDSIN
    INTEGER(KIND=JPIM) :: IFLDSOUT
    INTEGER(KIND=JPIM) :: IFLDSTOT
    INTEGER(KIND=JPIM) :: IGPBLKS
    INTEGER(KIND=JPIM) :: IGPBLKS_RAD
    INTEGER(KIND=JPIM) :: IGI
    INTEGER(KIND=JPIM) :: IGIX
    INTEGER(KIND=JPIM) :: IMU0
    INTEGER(KIND=JPIM) :: IAMU0
    INTEGER(KIND=JPIM) :: IEMISS
    INTEGER(KIND=JPIM) :: ITS
    INTEGER(KIND=JPIM) :: ISLM
    INTEGER(KIND=JPIM) :: IBAS
    INTEGER(KIND=JPIM) :: ITOP
    INTEGER(KIND=JPIM) :: IFRSOD
    INTEGER(KIND=JPIM) :: IFRTED
    INTEGER(KIND=JPIM) :: IFRSODC
    INTEGER(KIND=JPIM) :: IFRTEDC
    INTEGER(KIND=JPIM) :: IEMIT
    INTEGER(KIND=JPIM) :: ISUDU
    INTEGER(KIND=JPIM) :: IUVDF
    INTEGER(KIND=JPIM) :: IPARF
    INTEGER(KIND=JPIM) :: IPARCF
    INTEGER(KIND=JPIM) :: ITINCF
    INTEGER(KIND=JPIM) :: IFDIR
    INTEGER(KIND=JPIM) :: IFDIF
    INTEGER(KIND=JPIM) :: ICDIR
    INTEGER(KIND=JPIM) :: ILWDERIVATIVE
    INTEGER(KIND=JPIM) :: ISWDIRECTBAND
    INTEGER(KIND=JPIM) :: ISWDIFFUSEBAND
    INTEGER(KIND=JPIM) :: IALD
    INTEGER(KIND=JPIM) :: IALP
    INTEGER(KIND=JPIM) :: ITI
    INTEGER(KIND=JPIM) :: IPR
    INTEGER(KIND=JPIM) :: IQS
    INTEGER(KIND=JPIM) :: IWV
    INTEGER(KIND=JPIM) :: ICLC
    INTEGER(KIND=JPIM) :: ILWA
    INTEGER(KIND=JPIM) :: IIWA
    INTEGER(KIND=JPIM) :: ISWA
    INTEGER(KIND=JPIM) :: IRWA
    INTEGER(KIND=JPIM) :: IRRA
    INTEGER(KIND=JPIM) :: IDP
    INTEGER(KIND=JPIM) :: IOZ
    INTEGER(KIND=JPIM) :: IHTI
    INTEGER(KIND=JPIM) :: IHPR
    INTEGER(KIND=JPIM) :: IFRSO
    INTEGER(KIND=JPIM) :: ISWFC
    INTEGER(KIND=JPIM) :: IFRTH
    INTEGER(KIND=JPIM) :: ILWFC
    INTEGER(KIND=JPIM) :: IAE
    INTEGER(KIND=JPIM) :: IAER
    INTEGER(KIND=JPIM) :: IAERO
    INTEGER(KIND=JPIM) :: IPERT
    INTEGER(KIND=JPIM) :: IAPRS
    INTEGER(KIND=JPIM) :: IGELAM
    INTEGER(KIND=JPIM) :: IGEMU
    INTEGER(KIND=JPIM) :: ICLON
    INTEGER(KIND=JPIM) :: ISLON
    INTEGER(KIND=JPIM) :: IECPO3
    INTEGER(KIND=JPIM) :: ICCNL
    INTEGER(KIND=JPIM) :: ICCNO
    INTEGER(KIND=JPIM) :: ICO2
    INTEGER(KIND=JPIM) :: ICH4
    INTEGER(KIND=JPIM) :: IN2O
    INTEGER(KIND=JPIM) :: INO2
    INTEGER(KIND=JPIM) :: IC11
    INTEGER(KIND=JPIM) :: IC12
    INTEGER(KIND=JPIM) :: IC22
    INTEGER(KIND=JPIM) :: ICL4
    INTEGER(KIND=JPIM) :: IFSD
    REAL(KIND=JPRB) :: ZCRAE
    REAL(KIND=JPRB) :: ZRII0
    REAL(KIND=JPRB) :: ZREPALB
    LOGICAL :: LLDOLAST
    LOGICAL :: LLPRINT
    LOGICAL :: LLACTAERO
    LOGICAL :: LLAERORAD
    INTEGER(KIND=JPIM) :: IRADAER
    REAL(KIND=JPRB) :: ZPERTAER
    REAL(KIND=JPRB) :: ZPERTOZ
    REAL(KIND=JPRB) :: ZSWDIRECTBAND(context%block_columns, 1:context%setup%radiation%NSW)
    REAL(KIND=JPRB) :: ZSWDIFFUSEBAND(context%block_columns, 1:context%setup%radiation%NSW)
    REAL(KIND=JPRB) :: ZSWDNTOP
    REAL(KIND=JPRB) :: ZSWUPTOP
    REAL(KIND=JPRB) :: ZSWDNSURF
    REAL(KIND=JPRB) :: ZSWUPSURF
    REAL(KIND=JPRB) :: ZSWDNTOPEFF
    REAL(KIND=JPRB) :: ZSWTRANSMITTANCE
    REAL(KIND=JPRB) :: ZSWREFLECTANCE
    REAL(KIND=JPRB) :: ZBROADBANDALBEDO
    REAL(KIND=JPRB) :: ZNEWSWNETSURF
    REAL(KIND=JPRB) :: ZSWNETCHANGE(context%block_columns)
    REAL(KIND=JPRB), PARAMETER :: ZSWTOPSCALINGDEFAULT = 1.0_JPRB
    REAL(KIND=JPRB) :: ZSWTOPSCALING
    REAL(KIND=JPRB) :: ZEPSILON
    real(jphook) :: ZHOOK_HANDLE
    integer(int32), intent(out) :: status
    integer :: allocation_status, point, block, cell
    real(real64) :: longitude_flat(context%local_points), latitude_flat(context%local_points)
    real(real64) :: longitude_cosine_flat(context%local_points), longitude_sine_flat(context%local_points)
    status = 2
    if (.not. radiation_clock_is_ready(context%clock)) return
    if (.not. associated(context%setup) .or. .not. associated(context%surface_parameters)) return
    if (.not. associated(context%legacy_radiation) .or. .not. associated(context%configuration)) return
    if (.not. allocated(context%setup%climate)) return
    if (.not. context%same_radiation_grid .or. context%stochastic_enabled) return
    if (context%active_aerosols /= 0 .or. context%chemistry_species /= 0 .or. context%chemistry_ozone) return
    if (context%setup%radiation%LEPO3RA .neqv. context%prognostic_ozone) return
    if (context%configuration%phy%LRAYFM .or. context%configuration%linear_ecmwf%LPHYLIN) return
    if (context%setup%radiation%LUSEPRE2017RAD .or. context%setup%radiation%LDIAGFORCING) return
    if (.not. context%setup%radiation%LAPPROXLWUPDATE .or. .not. context%setup%radiation%LAPPROXSWUPDATE) return
    if (context%setup%radiation%NAERMACC /= 1) return
    if (context%setup%radiation%NGHGRAD /= 20 .and. context%setup%radiation%NGHGRAD /= 21) return
    if (context%no3cmip /= 0) return
 if (context%local_points < 1 .or. context%block_columns < 1 .or. context%block_columns > 1024 .or. KLEV < 3 .or. KLEV > 256) return
    if (context%prognostic_ozone) then
      if (size(PECPO3, 1) < context%local_points .or. size(PECPO3, 2) < KLEV) return
    end if
    if (.not. associated(context%latitude_sine) .or. .not. associated(context%longitude)) return
    if (.not. associated(context%longitude_cosine) .or. .not. associated(context%longitude_sine)) return
    do point = 1, context%local_points
      cell = mod(point - 1, context%block_columns) + 1; block = (point - 1)/context%block_columns + 1
      latitude_flat(point) = context%latitude_sine(cell, block)
      longitude_flat(point) = context%longitude(cell, block)
      longitude_cosine_flat(point) = context%longitude_cosine(cell, block)
      longitude_sine_flat(point) = context%longitude_sine(cell, block)
    end do
    if (lhook) call dr_hook('RADINTG', 0, ZHOOK_HANDLE)
    ZEPSILON = 1000._JPRB*TINY(ZEPSILON)
    ZAERTAUL = 0._JPRB
    ZAERTAULJ = 0._JPRB
    ZAERASYL = 0._JPRB
    ZAEROMGL = 0._JPRB
    ZAERTAUS = 0._JPRB
    ZAERTAUSJ = 0._JPRB
    ZAERASYS = 0._JPRB
    ZAEROMGS = 0._JPRB
    ZAERMACCM = 0._JPRB
    ZRHCL = 0._JPRB
    ZQSAT = 0._JPRB
    ZDP = 0.0_JPRB
    ZTAUAER = 0.0_JPRB
    IFLAG = 0
    ZREPALB = context%surface_parameters%yrdi%REPALB
    context%nimp = 0
    context%nout = 0
    ZRII0 = context%legacy_radiation%RII0*context%setup%shortwave%RADJUST
    IGPBLKS = (context%local_points - 1)/context%block_columns + 1
    IGPBLKS_RAD = (context%local_points - 1)/context%block_columns + 1
    IF (context%clock%step == 0) THEN
    ELSE
    END IF
    LLACTAERO = .FALSE.
    IRADAER = 12
    LLAERORAD = .FALSE.
    ZPERTAER = FLOAT(context%setup%radiation%NPERTAER)*1.E-2_JPRB
    ZPERTOZ = FLOAT(context%setup%radiation%NPERTOZ)*1.E-2_JPRB
    ZCRAE = context%setup%gases%RRAE*(context%setup%gases%RRAE + 2.0_JPRB)
    DO JL = 1, context%local_points
    IF (PMU0(JL) > 1.E-10_JPRB) THEN
      ZAMU0(JL) = context%setup%gases%RRAE/(SQRT(PMU0(JL)**2 + ZCRAE) - PMU0(JL))
    ELSE
      ZAMU0(JL) = context%setup%gases%RRAE/SQRT(ZCRAE)
    END IF
    END DO
    INEXT = 1
    IINBEG = 1
    IGI = INDRAD(INEXT, 1, .false.)
    IMU0 = INDRAD(INEXT, 1, .TRUE.)
    IAMU0 = INDRAD(INEXT, 1, .TRUE.)
    IEMISS = INDRAD(INEXT, context%setup%radiation%NLWEMISS, .TRUE.)
    ITS = INDRAD(INEXT, 1, .TRUE.)
    ISLM = INDRAD(INEXT, 1, .TRUE.)
    ICCNL = INDRAD(INEXT, 1, .TRUE.)
    ICCNO = INDRAD(INEXT, 1, .TRUE.)
    IBAS = INDRAD(INEXT, 1, .TRUE.)
    ITOP = INDRAD(INEXT, 1, .TRUE.)
    IGELAM = INDRAD(INEXT, 1, .TRUE.)
    IGEMU = INDRAD(INEXT, 1, .TRUE.)
    ICLON = INDRAD(INEXT, 1, .TRUE.)
    ISLON = INDRAD(INEXT, 1, .TRUE.)
    IALD = INDRAD(INEXT, context%setup%radiation%NSW, .TRUE.)
    IALP = INDRAD(INEXT, context%setup%radiation%NSW, .TRUE.)
    ITI = INDRAD(INEXT, KLEV, .TRUE.)
    IPR = INDRAD(INEXT, KLEV, .TRUE.)
    IQS = INDRAD(INEXT, KLEV, .TRUE.)
    IWV = INDRAD(INEXT, KLEV, .TRUE.)
    ICLC = INDRAD(INEXT, KLEV, .TRUE.)
    ILWA = INDRAD(INEXT, KLEV, .TRUE.)
    IIWA = INDRAD(INEXT, KLEV, .TRUE.)
    ISWA = INDRAD(INEXT, KLEV, .TRUE.)
    IRWA = INDRAD(INEXT, KLEV, .TRUE.)
    IRRA = INDRAD(INEXT, KLEV, .TRUE.)
    IDP = INDRAD(INEXT, KLEV, .TRUE.)
    IFSD = INDRAD(INEXT, KLEV, 0 > 0)
    IOZ = INDRAD(INEXT, KLEV, .false.)
    IECPO3 = INDRAD(INEXT, KLEV, context%prognostic_ozone)
    IHPR = INDRAD(INEXT, KLEV + 1, .TRUE.)
    IAPRS = INDRAD(INEXT, KLEV + 1, .TRUE.)
    IHTI = INDRAD(INEXT, KLEV + 1, .TRUE.)
    IAERO = INDRAD(INEXT, IRADAER*KLEV,.NOT. .false. .AND. LLACTAERO .AND. context%setup%radiation%NAERMACC == 0)
    IPERT = INDRAD(INEXT, 0, .false.)
    IINEND = INEXT - 1
    IOUTBEG = INEXT
    IAERO = INDRAD(INEXT, IRADAER*KLEV, context%setup%radiation%LDIAGFORCING)
    IFRSOD = INDRAD(INEXT, 1, .TRUE.)
    IFRTED = INDRAD(INEXT, context%setup%radiation%NLWOUT, .TRUE.)
    IFRSODC = INDRAD(INEXT, 1, .TRUE.)
    IFRTEDC = INDRAD(INEXT, 1, .TRUE.)
    IEMIT = INDRAD(INEXT, 1, .TRUE.)
    ISUDU = INDRAD(INEXT, 1, .TRUE.)
    IUVDF = INDRAD(INEXT, 1, .TRUE.)
    IPARF = INDRAD(INEXT, 1, .TRUE.)
    IPARCF = INDRAD(INEXT, 1, .TRUE.)
    ITINCF = INDRAD(INEXT, 1, .TRUE.)
    IFDIR = INDRAD(INEXT, 1, .TRUE.)
    IFDIF = INDRAD(INEXT, 1, .TRUE.)
    ICDIR = INDRAD(INEXT, 1, .TRUE.)
    ILWDERIVATIVE = INDRAD(INEXT, KLEV + 1, context%setup%radiation%LAPPROXLWUPDATE)
    ISWDIRECTBAND = INDRAD(INEXT, context%setup%radiation%NSW, context%setup%radiation%LAPPROXSWUPDATE)
    ISWDIFFUSEBAND = INDRAD(INEXT, context%setup%radiation%NSW, context%setup%radiation%LAPPROXSWUPDATE)
    IFRSO = INDRAD(INEXT, KLEV + 1, .TRUE.)
    ISWFC = INDRAD(INEXT, KLEV + 1, .TRUE.)
    IFRTH = INDRAD(INEXT, KLEV + 1, .TRUE.)
    ILWFC = INDRAD(INEXT, KLEV + 1, .TRUE.)
    IAER = INDRAD(INEXT, 6*KLEV, context%setup%radiation%LDIAGFORCING)
    IOZ = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    ICO2 = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    ICH4 = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    IN2O = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    INO2 = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    IC11 = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    IC12 = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    IC22 = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    ICL4 = INDRAD(INEXT, KLEV, context%setup%radiation%LDIAGFORCING)
    IGIX = INDRAD(INEXT, 1, .false.)
    IOUTEND = INEXT - 1
    IAERO = INDRAD(INEXT, IRADAER*KLEV, .TRUE.)
    IAER = INDRAD(INEXT, KLEV*6, .TRUE.)
    IOZ = INDRAD(INEXT, KLEV,.NOT. .false.)
    ICO2 = INDRAD(INEXT, KLEV, .TRUE.)
    ICH4 = INDRAD(INEXT, KLEV, .TRUE.)
    IN2O = INDRAD(INEXT, KLEV, .TRUE.)
    INO2 = INDRAD(INEXT, KLEV, .TRUE.)
    IC11 = INDRAD(INEXT, KLEV, .TRUE.)
    IC12 = INDRAD(INEXT, KLEV, .TRUE.)
    IC22 = INDRAD(INEXT, KLEV, .TRUE.)
    ICL4 = INDRAD(INEXT, KLEV, .TRUE.)
    IFLDSIN = IINEND - IINBEG + 1
    IFLDSOUT = IOUTEND - IOUTBEG + 1
    IFLDSTOT = INEXT - 1
    ALLOCATE (ZRGP(context%block_columns, IFLDSTOT, IGPBLKS), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ZRGP = 0.0_JPRB
    ALLOCATE (ZDGEMU(context%block_columns, IGPBLKS), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ZDGEMU = 0.0_JPRB
    DO JSTGLO = 1, context%local_points, context%block_columns
      IBEG = JSTGLO
      IEND = MIN(IBEG + context%block_columns - 1, context%local_points)
      IL = IEND - IBEG + 1
      IB = (JSTGLO - 1)/context%block_columns + 1
      IF (context%setup%radiation%LINTERPINCLOUDMEAN) THEN
      DO JK = 1, KLEV
        ZCLC(1:IL, JK) = MIN(MAX(PCLFR(IBEG:IEND, JK), 0.0_JPRB), 1.0_JPRB)
        DO JL = 1, IL
        IF (ZCLC(JL, JK) > context%setup%gases%REPCLC) THEN
          ZQLWP(JL, JK) = PQLWP(IBEG + JL - 1, JK)/ZCLC(JL, JK)
          ZQIWP(JL, JK) = PQIWP(IBEG + JL - 1, JK)/ZCLC(JL, JK)
          ZQRWP(JL, JK) = PQRAIN(IBEG + JL - 1, JK)/ZCLC(JL, JK)
          ZQSWP(JL, JK) = PQSWP(IBEG + JL - 1, JK)/ZCLC(JL, JK)
        ELSE
          ZQLWP(JL, JK) = 0.0_JPRB
          ZQIWP(JL, JK) = 0.0_JPRB
          ZQRWP(JL, JK) = 0.0_JPRB
          ZQSWP(JL, JK) = 0.0_JPRB
        END IF
        END DO
      END DO
      END IF
      DO JK = 2, KLEV
        ZCAPH(1:IL, JK) = PAPRS(IBEG:IEND, JK)
PTH(IBEG:IEND,JK)=(PT(IBEG:IEND,JK-1)*PAPRSF(IBEG:IEND,JK-1) *(PAPRSF(IBEG:IEND,JK)-PAPRS(IBEG:IEND,JK)) +PT(IBEG:IEND,JK)*PAPRSF(IBEG:IEND,JK)*(PAPRS(IBEG:IEND,JK) -PAPRSF(IBEG:IEND,JK-1))) *(1.0_JPRB/(PAPRS(IBEG:IEND,JK)*(PAPRSF(IBEG:IEND,JK)-PAPRSF(IBEG:IEND,JK-1))))
        ZCHTI(1:IL, JK) = PTH(IBEG:IEND, JK)
      END DO
      ZCAPH(1:IL, 1) = PAPRS(IBEG:IEND, 1)
      ZCAPH(1:IL, KLEV + 1) = PAPRS(IBEG:IEND, KLEV + 1)
   PTH(IBEG:IEND,1)=PT(IBEG:IEND,1)-PAPRSF(IBEG:IEND,1)*(PT(IBEG:IEND,1) -PTH(IBEG:IEND,2))/(PAPRSF(IBEG:IEND,1)-PAPRS(IBEG:IEND,2))
      PTH(IBEG:IEND, KLEV + 1) = PTS(IBEG:IEND)
      ZCHTI(1:IL, KLEV + 1) = PTH(IBEG:IEND, KLEV + 1)
      ZCHTI(1:IL, 1) = PTH(IBEG:IEND, 1)
      ZRGP(1:IL, IMU0, IB) = PMU0(IBEG:IEND)
      ZRGP(1:IL, IAMU0, IB) = ZAMU0(IBEG:IEND)
      DO JLW = 1, context%setup%radiation%NLWEMISS
        ZRGP(1:IL, IEMISS + JLW - 1, IB) = PSPECTRALEMISS(IBEG:IEND, JLW)
      END DO
      ZRGP(1:IL, ITS, IB) = PTS(IBEG:IEND)**4
      ZRGP(1:IL, ISLM, IB) = PSLM(IBEG:IEND)
      ZRGP(1:IL, ICCNL, IB) = PCCNL(IBEG:IEND)
      ZRGP(1:IL, ICCNO, IB) = PCCNO(IBEG:IEND)
      ZRGP(1:IL, IBAS, IB) = PNBAS(IBEG:IEND)
      ZRGP(1:IL, ITOP, IB) = PNTOP(IBEG:IEND)
      ZRGP(1:IL, IGELAM, IB) = longitude_flat(IBEG:IEND)
      ZRGP(1:IL, IGEMU, IB) = latitude_flat(IBEG:IEND)
      ZDGEMU(1:IL, IB) = latitude_flat(IBEG:IEND)
      ZRGP(1:IL, ICLON, IB) = longitude_cosine_flat(IBEG:IEND)
      ZRGP(1:IL, ISLON, IB) = longitude_sine_flat(IBEG:IEND)
      ZRGP(1:IL, IALD:IALD + context%setup%radiation%NSW - 1, IB) = PALBD(IBEG:IEND, 1:context%setup%radiation%NSW)
      ZRGP(1:IL, IALP:IALP + context%setup%radiation%NSW - 1, IB) = PALBP(IBEG:IEND, 1:context%setup%radiation%NSW)
      ZRGP(1:IL, ITI:ITI + KLEV - 1, IB) = PT(IBEG:IEND, 1:KLEV)
      ZRGP(1:IL, IPR:IPR + KLEV - 1, IB) = PAPRSF(IBEG:IEND, 1:KLEV)
      ZRGP(1:IL, IQS:IQS + KLEV - 1, IB) = PQS(IBEG:IEND, 1:KLEV)
      ZRGP(1:IL, IWV:IWV + KLEV - 1, IB) = PQ(IBEG:IEND, 1:KLEV)
      IF (context%setup%radiation%LINTERPINCLOUDMEAN) THEN
        ZRGP(1:IL, ICLC:ICLC + KLEV - 1, IB) = ZCLC(1:IL, 1:KLEV)
        ZRGP(1:IL, ILWA:ILWA + KLEV - 1, IB) = ZQLWP(1:IL, 1:KLEV)
        ZRGP(1:IL, IIWA:IIWA + KLEV - 1, IB) = ZQIWP(1:IL, 1:KLEV)
        ZRGP(1:IL, ISWA:ISWA + KLEV - 1, IB) = ZQSWP(1:IL, 1:KLEV)
        ZRGP(1:IL, IRWA:IRWA + KLEV - 1, IB) = ZQRWP(1:IL, 1:KLEV)
      ELSE
        ZRGP(1:IL, ICLC:ICLC + KLEV - 1, IB) = MIN(MAX(PCLFR(IBEG:IEND, 1:KLEV), 0.0_JPRB), 1.0_JPRB)
        ZRGP(1:IL, ILWA:ILWA + KLEV - 1, IB) = PQLWP(IBEG:IEND, 1:KLEV)
        ZRGP(1:IL, IIWA:IIWA + KLEV - 1, IB) = PQIWP(IBEG:IEND, 1:KLEV)
        ZRGP(1:IL, ISWA:ISWA + KLEV - 1, IB) = PQSWP(IBEG:IEND, 1:KLEV)
        ZRGP(1:IL, IRWA:IRWA + KLEV - 1, IB) = PQRAIN(IBEG:IEND, 1:KLEV)
      END IF
      ZRGP(1:IL, IRRA:IRRA + KLEV - 1, IB) = PRAINT(IBEG:IEND, 1:KLEV)
      ZRGP(1:IL, IDP:IDP + KLEV - 1, IB) = PDP(IBEG:IEND, 1:KLEV)
      IF (context%prognostic_ozone) THEN
        ZRGP(1:IL, IECPO3:IECPO3 + KLEV - 1, IB) = PECPO3(IBEG:IEND, 1:KLEV)
      END IF
      LLPRINT = .FALSE.
      ZRGP(1:IL, IHPR:IHPR + KLEV, IB) = ZCAPH(1:IL, 1:KLEV + 1)
      ZRGP(1:IL, IAPRS:IAPRS + KLEV, IB) = PAPRS(IBEG:IEND, 1:KLEV + 1)
      ZRGP(1:IL, IHTI:IHTI + KLEV, IB) = ZCHTI(1:IL, 1:KLEV + 1)
    END DO
    DO JSTGLO = 1, context%local_points, context%block_columns
      IBEG = JSTGLO
      IEND = MIN(IBEG + context%block_columns - 1, context%local_points)
      IL = IEND - IBEG + 1
      IB = (JSTGLO - 1)/context%block_columns + 1
      DO JSW = 1, context%setup%radiation%NSW
      DO JL = 1, IL
        ZRGP(JL, IALD + JSW - 1, IB) = MIN(1.0_JPRB, MAX(ZREPALB, ZRGP(JL, IALD + JSW - 1, IB)))
        ZRGP(JL, IALP + JSW - 1, IB) = MIN(1.0_JPRB, MAX(ZREPALB, ZRGP(JL, IALP + JSW - 1, IB)))
      END DO
      END DO
      DO JL = 1, IL
        ZRGP(JL, ICCNL, IB) = MIN(1743._JPRB, MAX(292._JPRB, ZRGP(JL, ICCNL, IB)))
        ZRGP(JL, ICCNO, IB) = MIN(287._JPRB, MAX(32._JPRB, ZRGP(JL, ICCNO, IB)))
      END DO
      DO JLEV = 1, KLEV
      DO JL = 1, IL
        ZRGP(JL,IQS+JLEV-1 ,IB) = MAX(context%setup%scalars%repscq, MAX(2.0_JPRB*context%setup%gases%REPH2O,ZRGP(JL,IQS+JLEV-1,IB)))
ZRGP(JL,IWV+JLEV-1 ,IB) = MAX(context%setup%scalars%repscq, MAX(context%setup%gases%REPH2O,MIN(ZRGP(JL,IWV+JLEV-1,IB), ZRGP(JL,IQS+JLEV-1,IB)*(1.0_JPRB-context%setup%gases%REPH2O))))
        ZRGP(JL, ICLC + JLEV - 1, IB) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZRGP(JL, ICLC + JLEV - 1, IB)))
        IF (context%setup%radiation%LINTERPINCLOUDMEAN) THEN
         ZRGP(JL,ILWA+JLEV-1,IB) = MAX(  0.0_JPRB, MAX(context%setup%gases%REPH2O,ZRGP(JL,ILWA+JLEV-1,IB)) *ZRGP(JL,ICLC+JLEV-1,IB))
         ZRGP(JL,IIWA+JLEV-1,IB) = MAX(  0.0_JPRB, MAX(context%setup%gases%REPH2O,ZRGP(JL,IIWA+JLEV-1,IB)) *ZRGP(JL,ICLC+JLEV-1,IB))
         ZRGP(JL,ISWA+JLEV-1,IB) = MAX(  0.0_JPRB, MAX(context%setup%gases%REPH2O,ZRGP(JL,ISWA+JLEV-1,IB)) *ZRGP(JL,ICLC+JLEV-1,IB))
         ZRGP(JL,IRWA+JLEV-1,IB) = MAX(  0.0_JPRB, MAX(context%setup%gases%REPH2O,ZRGP(JL,IRWA+JLEV-1,IB)) *ZRGP(JL,ICLC+JLEV-1,IB))
        ELSE
          ZRGP(JL, ILWA + JLEV - 1, IB) = MAX(0.0_JPRB, ZRGP(JL, ILWA + JLEV - 1, IB))
          ZRGP(JL, IIWA + JLEV - 1, IB) = MAX(0.0_JPRB, ZRGP(JL, IIWA + JLEV - 1, IB))
          ZRGP(JL, ISWA + JLEV - 1, IB) = MAX(0.0_JPRB, ZRGP(JL, ISWA + JLEV - 1, IB))
          ZRGP(JL, IRWA + JLEV - 1, IB) = MAX(0.0_JPRB, ZRGP(JL, IRWA + JLEV - 1, IB))
        END IF
        ZRGP(JL, IRRA + JLEV - 1, IB) = MAX(0.0_JPRB, ZRGP(JL, IRRA + JLEV - 1, IB))
      END DO
      END DO
      IF (context%prognostic_ozone) THEN
        ZECPO3(1:IL, 1:KLEV) = ZRGP(1:IL, IECPO3:IECPO3 + KLEV - 1, IB)
      ELSE
        ZECPO3(:, :) = 0.0_JPRB
      END IF
      I1 = 1
      I2 = 99999999
      DO JL = 1, IL
      IF (ZDGEMU(JL, IB) /= ZDGEMU(I1, IB) .OR. JL == IL) THEN
        LLDOLAST = .FALSE.
        IF (JL == IL) THEN
        IF (ZDGEMU(JL, IB) == ZDGEMU(I1, IB)) THEN
          I2 = IL
        ELSE
          I2 = IL - 1
          LLDOLAST = .TRUE.
        END IF
        ELSE
        I2 = JL - 1
        END IF
1000    CONTINUE
call runtime_radact(context,I1,I2,context%block_columns,KLEV,1,context%block_columns,context%block_columns,I1-1,1,ZRGP(:,IAPRS:IAPRS+KLEV,IB),ZRGP(:,IGELAM,IB),ZDGEMU(:,IB),ZRGP(:,ICLON,IB),ZRGP(:,ISLON,IB),ZRGP(:,IHTI:IHTI+KLEV,IB),ZRGP(:,IWV:IWV+KLEV-1,IB),ZRGP(:,IQS:IQS+KLEV-1,IB),ZECPO3,ZQAER,ZQAERO,ZQOZ,status)
        if (status /= 0) return
IF (context%setup%radiation%NOZOCL == 1.AND..NOT.context%setup%radiation%LEPO3RA.AND..NOT.context%configuration%linear_ecmwf%LPHYLIN) THEN
call radozc(context%setup%ozone,.false.,I1,I2,context%block_columns,KLEV,1,context%block_columns,I1-1,ZRGP(:,IAPRS:IAPRS+KLEV,IB),ZRGP(:,IGEMU,IB),ZQOZ)
        END IF
        IF (context%setup%radiation%NGHGRAD /= 0 .AND. .NOT. context%configuration%linear_ecmwf%LPHYLIN) THEN
call radghg(context%setup%radiation,context%setup%climate%radiation,I1,I2,context%block_columns,KLEV,context%block_columns,ZRGP(:,IAPRS:IAPRS+KLEV,IB),ZRGP(:,IGEMU,IB),ZQCO2,ZQCH4,ZQN2O,ZQNO2,ZQC11,ZQC12,ZQOZO,ZQC22,ZQCL4)
        END IF
        I1 = JL
        IF (LLDOLAST) THEN
          LLDOLAST = .FALSE.
          I2 = IL
          GOTO 1000
        END IF
      END IF
      END DO
      IF (context%prognostic_ozone) THEN
        ZRGP(1:IL, IOZ:IOZ + KLEV - 1, IB) = MAX(context%setup%scalars%repsco, &
         & ZRGP(1:IL, IECPO3:IECPO3 + KLEV - 1, IB)*ZRGP(1:IL, IDP:IDP + KLEV - 1, IB))
      ELSE
        IF (context%setup%radiation%NPERTOZ /= 0) ZQOZ(1:IL, 1:KLEV) = ZQOZ(1:IL, 1:KLEV)*(1.0_JPRB + ZPERTOZ)
        ZRGP(1:IL, IOZ:IOZ + KLEV - 1, IB) = ZQOZ(1:IL, 1:KLEV)
      END IF
      ZRGP(1:IL, ICO2:ICO2 + KLEV - 1, IB) = PCCO2
      ZRGP(1:IL, ICH4:ICH4 + KLEV - 1, IB) = context%setup%gases%RCH4
      ZRGP(1:IL, IN2O:IN2O + KLEV - 1, IB) = context%setup%gases%RN2O
      ZRGP(1:IL, INO2:INO2 + KLEV - 1, IB) = context%setup%gases%RNO2
      ZRGP(1:IL, IC11:IC11 + KLEV - 1, IB) = context%setup%gases%RCFC11
      ZRGP(1:IL, IC12:IC12 + KLEV - 1, IB) = context%setup%gases%RCFC12
      ZRGP(1:IL, IC22:IC22 + KLEV - 1, IB) = context%setup%gases%RCFC22
      ZRGP(1:IL, ICL4:ICL4 + KLEV - 1, IB) = context%setup%gases%RCCL4
      IF (context%setup%radiation%NGHGRAD == 1 .OR. context%setup%radiation%NGHGRAD >= 10) THEN
        ZRGP(1:IL, ICO2:ICO2 + KLEV - 1, IB) = ZQCO2(1:IL, 1:KLEV)
      END IF
      IF (context%setup%radiation%NGHGRAD == 2 .OR. context%setup%radiation%NGHGRAD >= 11) THEN
        ZRGP(1:IL, ICH4:ICH4 + KLEV - 1, IB) = ZQCH4(1:IL, 1:KLEV)
      END IF
      IF (context%setup%radiation%NGHGRAD == 3 .OR. context%setup%radiation%NGHGRAD >= 12) THEN
        ZRGP(1:IL, IN2O:IN2O + KLEV - 1, IB) = ZQN2O(1:IL, 1:KLEV)
      END IF
      IF (context%setup%radiation%NGHGRAD == 4 .OR. context%setup%radiation%NGHGRAD >= 20) THEN
        ZRGP(1:IL, INO2:INO2 + KLEV - 1, IB) = ZQNO2(1:IL, 1:KLEV)
      END IF
      IF (context%setup%radiation%NGHGRAD == 5 .OR. context%setup%radiation%NGHGRAD >= 15) THEN
        ZRGP(1:IL, IC11:IC11 + KLEV - 1, IB) = ZQC11(1:IL, 1:KLEV)
      END IF
      IF (context%setup%radiation%NGHGRAD == 6 .OR. context%setup%radiation%NGHGRAD >= 16) THEN
        ZRGP(1:IL, IC12:IC12 + KLEV - 1, IB) = ZQC12(1:IL, 1:KLEV)
      END IF
IF (context%setup%radiation%NGHGRAD == 7 .OR. context%setup%radiation%NGHGRAD == 17 .OR. context%setup%radiation%NGHGRAD >= 21) THEN
        ZRGP(1:IL, IOZ:IOZ + KLEV - 1, IB) = ZQOZO(1:IL, 1:KLEV)*ZRGP(1:IL, IDP:IDP + KLEV - 1, IB)
      END IF
      IF (context%setup%radiation%NGHGRAD == 8 .OR. context%setup%radiation%NGHGRAD >= 18) THEN
        ZRGP(1:IL, IC22:IC22 + KLEV - 1, IB) = ZQC22(1:IL, 1:KLEV)
      END IF
      IF (context%setup%radiation%NGHGRAD == 9 .OR. context%setup%radiation%NGHGRAD >= 19) THEN
        ZRGP(1:IL, ICL4:ICL4 + KLEV - 1, IB) = ZQCL4(1:IL, 1:KLEV)
      END IF
      DO JLEV = 1, KLEV
        IF (context%setup%radiation%NPERTAER /= 0) ZQAER(1:IL, 1:6, JLEV) = ZQAER(1:IL, 1:6, JLEV)*(1.0_JPRB + ZPERTAER)
        I = (JLEV - 1)*6
        ZRGP(1:IL, IAER + I:IAER + I + 6 - 1, IB) = ZQAER(1:IL, 1:6, JLEV)
      END DO
      DO JLEV = 1, KLEV
        IF (context%setup%radiation%NPERTAER /= 0) ZQAER(1:IL, 1:6, JLEV) = ZQAER(1:IL, 1:6, JLEV)*(1.0_JPRB + ZPERTAER)
        I = (JLEV - 1)*6
        ZRGP(1:IL, IAER + I:IAER + I + 6 - 1, IB) = ZQAER(1:IL, 1:6, JLEV)
      END DO
      IF (context%setup%radiation%NAER == 0) THEN
      DO JLEV = 1, KLEV
        I = (JLEV - 1)*6
        ZRGP(1:IL, IAER + I:IAER + I + 6 - 1, IB) = context%setup%aerosol_distribution%RCAEROS
      END DO
      ELSE
      DO JLEV = 1, KLEV
        I = (JLEV - 1)*6
        ZRGP(1:IL, IAER + I + 5 - 1, IB) = context%setup%aerosol_distribution%RCAEROS
      END DO
      END IF
      IF (context%setup%radiation%NAER == 1 .AND. context%setup%radiation%LNOTROAER) THEN
      DO JLEV = 1, KLEV
        I = (JLEV - 1)*6
        ZRGP(1:IL, IAER + I + 1 - 1, IB) = context%setup%aerosol_distribution%RCAEROS
        ZRGP(1:IL, IAER + I + 2 - 1, IB) = context%setup%aerosol_distribution%RCAEROS
        ZRGP(1:IL, IAER + I + 3 - 1, IB) = context%setup%aerosol_distribution%RCAEROS
        ZRGP(1:IL, IAER + I + 4 - 1, IB) = context%setup%aerosol_distribution%RCAEROS
      END DO
      END IF
      DO JAERO = 1, IRADAER
        IAE = (JAERO - 1)*KLEV
        ZRGP(1:IL, IAERO + IAE:IAERO + IAE + KLEV - 1, IB) = ZQAERO(1:IL, 1:KLEV, JAERO)
      END DO
      do JL = 1, IL
        ZRGP(JL, ITS, IB) = power_original_rounding(MAX(ZRGP(JL, ITS, IB), 0.0_JPRB), 0.25_JPRB)
      end do
    END DO
    DEALLOCATE (ZDGEMU)
    DO JRL = 1, context%local_points, context%block_columns
      IBEG = JRL
      IEND = MIN(IBEG + context%block_columns - 1, context%local_points)
      IL = IEND - IBEG + 1
      IB = (JRL - 1)/context%block_columns + 1
call radiation_scheme(context,1,IL,context%block_columns,KLEV,IRADAER,ZRII0,ZRGP(:,IAMU0,IB),ZRGP(:,ITS,IB),ZRGP(:,IALD:IALD+(context%setup%radiation%NSW)-1,IB),ZRGP(:,IALP:IALP+(context%setup%radiation%NSW)-1,IB),ZRGP(:,IEMISS:IEMISS+(context%setup%radiation%NLWEMISS)-1,IB),ZRGP(:,ICCNL,IB),ZRGP(:,ICCNO,IB),ZRGP(:,IGELAM,IB),ZRGP(:,IGEMU,IB),ZRGP(:,ISLM,IB),ZRGP(:,IPR:IPR+(KLEV)-1,IB),ZRGP(:,ITI:ITI+(KLEV)-1,IB),ZRGP(:,IAPRS:IAPRS+(KLEV+1)-1,IB),ZRGP(:,IHTI:IHTI+(KLEV+1)-1,IB),ZRGP(:,IWV:IWV+(KLEV)-1,IB),ZRGP(:,ICO2:ICO2+(KLEV)-1,IB),ZRGP(:,ICH4:ICH4+(KLEV)-1,IB),ZRGP(:,IN2O:IN2O+(KLEV)-1,IB),ZRGP(:,INO2:INO2+(KLEV)-1,IB),ZRGP(:,IC11:IC11+(KLEV)-1,IB),ZRGP(:,IC12:IC12+(KLEV)-1,IB),ZRGP(:,IC22:IC22+(KLEV)-1,IB),ZRGP(:,ICL4:ICL4+(KLEV)-1,IB),ZRGP(:,IOZ:IOZ+(KLEV)-1,IB),ZRGP(:,ICLC:ICLC+(KLEV)-1,IB),ZRGP(:,ILWA:ILWA+(KLEV)-1,IB),ZRGP(:,IIWA:IIWA+(KLEV)-1,IB),ZRGP(:,IRWA:IRWA+(KLEV)-1,IB),ZRGP(:,ISWA:ISWA+(KLEV)-1,IB),reshape(ZRGP(:,IAER:IAER+(6)*(KLEV)-1,IB),[context%block_columns,6,KLEV]),reshape(ZRGP(:,IAERO:IAERO+(KLEV)*(IRADAER)-1,IB),[context%block_columns,KLEV,IRADAER]),ZRGP(:,IFRSO:IFRSO+(KLEV+1)-1,IB),ZRGP(:,IFRTH:IFRTH+(KLEV+1)-1,IB),ZRGP(:,ISWFC:ISWFC+(KLEV+1)-1,IB),ZRGP(:,ILWFC:ILWFC+(KLEV+1)-1,IB),ZRGP(:,IFRSOD,IB),ZRGP(:,IFRTED:IFRTED+(context%setup%radiation%NLWOUT)-1,IB),ZRGP(:,IFRSODC,IB),ZRGP(:,IFRTEDC,IB),ZRGP(:,IFDIR,IB),ZRGP(:,ICDIR,IB),ZRGP(:,ISUDU,IB),ZRGP(:,IUVDF,IB),ZRGP(:,IPARF,IB),ZRGP(:,IPARCF,IB),ZRGP(:,ITINCF,IB),ZRGP(:,IEMIT,IB),ZRGP(:,ILwDerivative:ILwDerivative+(KLEV+1)-1,IB),ZRGP(:,ISwDiffuseBand:ISwDiffuseBand+(context%setup%radiation%NSW)-1,IB),ZRGP(:,ISwDirectBand:ISwDirectBand+(context%setup%radiation%NSW)-1,IB),status=status)
      if (status /= 0) return
    END DO
    DO JSTGLO = 1, context%local_points, context%block_columns
      IBEG = JSTGLO
      IEND = MIN(IBEG + context%block_columns - 1, context%local_points)
      IL = IEND - IBEG + 1
      IB = (JSTGLO - 1)/context%block_columns + 1
      ZFRSOD(1:IL) = ZRGP(1:IL, IFRSOD, IB)
      ZFRTED(1:IL, 1:context%setup%radiation%NLWOUT) = ZRGP(1:IL, IFRTED:IFRTED + context%setup%radiation%NLWOUT - 1, IB)
      ZFRSODC(1:IL) = ZRGP(1:IL, IFRSODC, IB)
      ZFRTEDC(1:IL) = ZRGP(1:IL, IFRTEDC, IB)
      ZEMIT(1:IL) = ZRGP(1:IL, IEMIT, IB)
      ZSUDU(1:IL) = ZRGP(1:IL, ISUDU, IB)
      ZUVDF(1:IL) = ZRGP(1:IL, IUVDF, IB)
      ZPARF(1:IL) = ZRGP(1:IL, IPARF, IB)
      ZPARCF(1:IL) = ZRGP(1:IL, IPARCF, IB)
      ZTINCF(1:IL) = ZRGP(1:IL, ITINCF, IB)
      ZFDIR(1:IL) = ZRGP(1:IL, IFDIR, IB)
      ZCDIR(1:IL) = ZRGP(1:IL, ICDIR, IB)
      ZFRSO(1:IL, 1:KLEV + 1) = ZRGP(1:IL, IFRSO:IFRSO + KLEV, IB)
      ZSWFC(1:IL, 1:KLEV + 1) = ZRGP(1:IL, ISWFC:ISWFC + KLEV, IB)
      ZFRTH(1:IL, 1:KLEV + 1) = ZRGP(1:IL, IFRTH:IFRTH + KLEV, IB)
      ZLWFC(1:IL, 1:KLEV + 1) = ZRGP(1:IL, ILWFC:ILWFC + KLEV, IB)
      ZFRSOD(1:IL) = MAX(ZFRSO(1:IL, KLEV + 1), ZFRSOD(1:IL))
      ZFRSODC(1:IL) = MAX(ZSWFC(1:IL, KLEV + 1), ZFRSODC(1:IL))
      ZLWDERIVATIVE(1:IL, 1:KLEV + 1) = ZRGP(1:IL, ILWDERIVATIVE:ILWDERIVATIVE + KLEV, IB)
  ZSWDIRECTBAND(1:IL, 1:context%setup%radiation%NSW) = ZRGP(1:IL, ISWDIRECTBAND:ISWDIRECTBAND + context%setup%radiation%NSW - 1, IB)
      ZSWDIFFUSEBAND(1:IL,1:context%setup%radiation%NSW) = ZRGP(1:IL,ISWDIFFUSEBAND:ISWDIFFUSEBAND+context%setup%radiation%NSW-1,IB)
      DO JL = 1, IL
      IF (ZFRSOD(JL) > 0.0_JPRB .AND. ZFRSO(JL, KLEV + 1) > 0.0_JPRB .AND. ZFRSOD(JL) > ZFRSO(JL, KLEV + 1)) THEN
ZBROADBANDALBEDO = ( SUM(ZSWDIRECTBAND(JL,1:context%setup%radiation%NSW) *PALBP(IBEG+JL-1,1:context%setup%radiation%NSW)) + SUM(ZSWDIFFUSEBAND(JL,1:context%setup%radiation%NSW)*PALBD(IBEG+JL-1,1:context%setup%radiation%NSW)) ) / SIGN(MAX(ABS(ZFRSOD(JL)),ZEPSILON),ZFRSOD(JL))
        ZBROADBANDALBEDO = MAX(0.0_JPRB, MIN(ZBROADBANDALBEDO, 0.9999_JPRB))
        ZSWDNTOP = ZRII0*ZAMU0(IBEG + JL - 1)
        ZSWUPTOP = ZSWDNTOP - ZFRSO(JL, 1)
        ZSWDNSURF = ZFRSOD(JL)
        ZSWUPSURF = ZSWDNSURF - ZFRSO(JL, KLEV + 1)
        ZSWTOPSCALING = (ZSWUPTOP + ZSWDNSURF - ZSWUPSURF)/ZSWDNTOP
        IF (ZSWTOPSCALING < ZSWTOPSCALINGDEFAULT) THEN
          ZSWTOPSCALING = ZSWTOPSCALINGDEFAULT
        END IF
        ZSWDNTOPEFF = ZSWDNTOP*ZSWTOPSCALING
        ZSWDNTOPEFF = ZSWDNTOP
        ZSWTRANSMITTANCE = (ZSWDNTOPEFF*ZSWDNSURF - ZSWUPSURF*ZSWUPTOP)/(ZSWDNTOPEFF*ZSWDNTOPEFF - ZSWUPSURF*ZSWUPSURF)
        ZSWREFLECTANCE = (ZSWDNTOPEFF*ZSWUPTOP - ZSWUPSURF*ZSWDNSURF)/(ZSWDNTOPEFF*ZSWDNTOPEFF - ZSWUPSURF*ZSWUPSURF)
        ZNEWSWNETSURF = ZSWDNTOPEFF*ZSWTRANSMITTANCE*(1.0_JPRB - ZBROADBANDALBEDO)/(1.0_JPRB - ZBROADBANDALBEDO*ZSWREFLECTANCE)
        ZSWNETCHANGE(JL) = ZNEWSWNETSURF - ZFRSO(JL, KLEV + 1)
        ZFRSOD(JL) = ZNEWSWNETSURF/(1.0_JPRB - ZBROADBANDALBEDO)
      ELSE
        ZSWNETCHANGE(JL) = 0.0_JPRB
      END IF
      END DO
      DO JK = 1, KLEV + 1
      DO JL = 1, IL
        ZFRSO(JL, JK) = ZFRSO(JL, JK) + ZSWNETCHANGE(JL)
      END DO
      END DO
      DO JK = 1, KLEV + 1
        ZTRSO(1:IL, JK) = ZFRSO(1:IL, JK)/(ZRII0*ZAMU0(IBEG:IEND))
        ZEMTD(1:IL, JK) = ZFRTH(1:IL, JK)
        ZEMTU(1:IL, JK) = ZFRTH(1:IL, JK)
        ZTRSC(1:IL, JK) = ZSWFC(1:IL, JK)/(ZRII0*ZAMU0(IBEG:IEND))
        ZEMTC(1:IL, JK) = ZLWFC(1:IL, JK)
      END DO
      ZTRSOD(1:IL) = ZFRSOD(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      ZTRSODC(1:IL) = ZFRSODC(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      ZEMTDC(1:IL) = ZFRTEDC(1:IL)
      ZEMIT(1:IL) = ZEMIT(1:IL)
      ZUVDF(1:IL) = ZUVDF(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      ZPARF(1:IL) = ZPARF(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      ZPARCF(1:IL) = ZPARCF(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      ZTINCF(1:IL) = ZTINCF(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      ZFDIR(1:IL) = ZFDIR(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      ZCDIR(1:IL) = ZCDIR(1:IL)/(ZRII0*ZAMU0(IBEG:IEND))
      DO JK = 1, KLEV + 1
        PTRSO(IBEG:IEND, JK) = ZTRSO(1:IL, JK)
        PTRSO(IBEG:IEND, JK) = MAX(0.0_JPRB, MIN(1.0_JPRB, PTRSO(IBEG:IEND, JK)))
        PEMTD(IBEG:IEND, JK) = ZEMTD(1:IL, JK)
        PEMTU(IBEG:IEND, JK) = ZEMTU(1:IL, JK)
        PTRSC(IBEG:IEND, JK) = ZTRSC(1:IL, JK)
        PTRSC(IBEG:IEND, JK) = MAX(0.0_JPRB, MIN(1.0_JPRB, PTRSC(IBEG:IEND, JK)))
        PEMTC(IBEG:IEND, JK) = ZEMTC(1:IL, JK)
        PLWDERIVATIVE(IBEG:IEND, JK) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZLWDERIVATIVE(1:IL, JK)))
      END DO
      PFRTED(IBEG:IEND, 1:context%setup%radiation%NLWOUT) = ZFRTED(1:IL, 1:context%setup%radiation%NLWOUT)
      PTRSOD(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZTRSOD(1:IL)))
      PTRSODC(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZTRSODC(1:IL)))
      PEMTDC(IBEG:IEND) = ZEMTDC(1:IL)
      PEMIT(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZEMIT(1:IL)))
      PSUDU(IBEG:IEND) = ZSUDU(1:IL)
      PUVDF(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZUVDF(1:IL)))
      PPARF(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZPARF(1:IL)))
      PPARCF(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZPARCF(1:IL)))
      PTINCF(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZTINCF(1:IL)))
      PFDIR(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZFDIR(1:IL)))
      PCDIR(IBEG:IEND) = MAX(0.0_JPRB, MIN(1.0_JPRB, ZCDIR(1:IL)))
    END DO
    DEALLOCATE (ZRGP)
    if (lhook) call dr_hook('RADINTG', 1, ZHOOK_HANDLE)
    status = 0
  contains
    INTEGER(KIND=JPIM) FUNCTION INDRAD(KNEXT, KFLDS, LDUSE)
      INTEGER(KIND=JPIM), INTENT(INOUT) :: KNEXT
      INTEGER(KIND=JPIM), INTENT(IN) :: KFLDS
      LOGICAL, INTENT(IN) :: LDUSE
      REAL(KIND=JPHOOK) :: ZHOOK_HANDLE
      IF (LHOOK) CALL DR_HOOK('RADINTG:INDRAD', 0, ZHOOK_HANDLE)
      IF (LDUSE) THEN
        INDRAD = KNEXT
        KNEXT = KNEXT + KFLDS
      ELSE
        INDRAD = -99999
      END IF
      IF (LHOOK) CALL DR_HOOK('RADINTG:INDRAD', 1, ZHOOK_HANDLE)
    END FUNCTION INDRAD
  end subroutine
end module
