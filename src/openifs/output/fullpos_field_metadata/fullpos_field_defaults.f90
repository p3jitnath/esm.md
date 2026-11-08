module forecast_native_fullpos_field_defaults
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int32, real64
USE PARFPOS  , ONLY : JPOSSCVA, JPOSVX2, JPOSFSU, JPOSAERO, JPOSGHG, JPOSSFX, JPOSERA40, JPOSNOGW, JPOSAEROUT, JPOSUVP, JPOSEZDIAG, JPOSCHEM, JPOSCHEMFLX, JPOSAERODIAG, JPOSAERLISI, JPOSAERAOT, JPOSAERO_WVL_DIAG, JPOSAERO_WVL_DIAG_TYPES,JPOSEDRP, JPOSEMIS2D, JPOSEMIS2DAUX, JPOSEMIS3D
use yom_grib_codes,only:NGRB10FG,NGRB10FG3,NGRB10FG6,NGRBI10FG,NGRB10U,NGRB10V,NGRB10SI,NGRBDHR,NGRBDHVD,NGRBDHCC,NGRBDHLC,NGRBVDZW,NGRBVDMW,NGRBVP,NGRBSTRF,NGRB2D,NGRB2SH,NGRB2T,NGRBAL,NGRBANOR,NGRBASN,NGRBBLD,NGRBBLH,NGRBBV,NGRBCC,NGRBCCC,NGRBCHNK,NGRBCI,NGRBCIWC,NGRBCLWC,NGRBCP,NGRBCSF,NGRBCVH,NGRBCVL,NGRBCUR,NGRBFWET,NGRBLAIL,NGRBLAIH,NGRBD,NGRBE,NGRBPEV,NGRBES,NGRBEWSS,NGRBFAL,NGRBFLSR,NGRBFSR,NGRBFZRA,NGRBGWD,NGRBHCC,NGRBIE,NGRBIEWS,NGRBINSS,NGRBISHF,NGRBISOR,NGRBISTL1,NGRBISTL2,NGRBISTL3,NGRBISTL4,NGRBLCC,NGRBLGWS,NGRBLNSP,NGRBLSF,NGRBLSM,NGRBLSP,NGRBLSPF,NGRBLSRH,NGRBMCC,NGRBMGWS,NGRBMONT,NGRBMSL,NGRBMN2T,NGRBMN2T3,NGRBMN2T6,NGRBMX2T,NGRBMX2T3,NGRBMX2T6,NGRBMNTPR,NGRBMNTPR3,NGRBMNTPR6,NGRBMXTPR,NGRBMXTPR3,NGRBMXTPR6,NGRBTPR,NGRBLSRR,NGRBCRR,NGRBLSSFR,NGRBCSFR,NGRBPTYPE,NGRBILSPF,NGRBNSSS,NGRBPRES,NGRBPV,NGRBR,NGRBRO,NGRBSRO,NGRBSSRO,NGRBCH4WET,NGRBEMIS,NGRBCL,NGRBRSN,NGRBSD,NGRBSDSL,NGRBWSN,NGRBSDOR,NGRBSF,NGRBSKT,NGRBSLHF,NGRBSLOR,NGRBSMLT,NGRBSP,NGRBSR,NGRBSRC,NGRBSSHF,NGRBSSR,NGRBSSRC,NGRBSSRD,NGRBSSRDC,NGRBSSTK,NGRBSTL1,NGRBSTL2,NGRBSTL3,NGRBSTL4,NGRBSTR,NGRBSTRC,NGRBSTRD,NGRBSTRDC,NGRBSUND,NGRBSWVL1,NGRBSWVL2,NGRBSWVL3,NGRBSWVL4,NGRBT,NGRBTCC,NGRBTCO3,NGRBUCUR,NGRBVCUR,NGRBVIWVE,NGRBVIWVN,NGRBTCW,NGRBTCWV,NGRBPT,NGRBTP,NGRBTSN,NGRBTSR,NGRBTSRC,NGRBTTR,NGRBTTRC,NGRBTVH,NGRBTVL,NGRBU,NGRBV,NGRBVEG,NGRBVO,NGRBW,NGRBZ,NGRBCAPE,NGRBCAPES,NGRBMXCAP6,NGRBMXCAPS6,NGRBMUCAPE,NGRBMLCAPE50,NGRBMLCAPE100,NGRBMUDEPL,NGRBTROPOTP,NGRBFDIR,NGRBCDIR,NGRBDSRP,NGRBTCLW,NGRBTCIW,NGRBTCRW,NGRBTCSW,NGRBTCSLW,NGRBMINXTRA,NGRBMAXXTRA,NGRBMINERA,NGRB080,NGRB118,NGRB119,NGRB120,NGRBSDFOR,NGRBPAR,NGRBUVB,NGRBPARCS,NGRBTISR,NGRBCBASE,NGRB0DEGL,NGRBM10DEGL,NGRBVISIH,NGRBCIN,NGRBMLCIN50,NGRBMLCIN100,NGRBKINDEX,NGRBTTINDEX,NGRBCBASEA,NGRBCTOPC,NGRBZTWETB0,NGRBZTWETB1,NGRBFASGPPCOEF,NGRBFASRECCOEF,NGRBALUVP,NGRBALUVD,NGRBALNIP,NGRBALNID,NGRBALUVI,NGRBALUVV,NGRBALUVG,NGRBALNII,NGRBALNIV,NGRBALNIG,NGRBAERDEP,NGRBAERLTS,NGRBAERSCC,NGRBAERDSF,NGRBAERDSZ,NGRBAERLS13,NGRBAERSO2DD,NGRBAERFCA1,NGRBAERFCA2,NGRBAERURBF,NGRBAEODSS,NGRBAEODDU,NGRBAEODOM,NGRBAEODBC,NGRBAEODSU,NGRBAEODNI,NGRBAEODAM,NGRBAEODSOA,NGRBAEODVFA,NGRBAEODVSU,NGRBACCAOD550,NGRBAEPM1,NGRBAEPM25,NGRBAEPM10,NGRBUVBED,NGRBUVBEDCS,NGRBVIMD,NGRBSLT,NGRBETADOT,NGRB100U,NGRB100V,NGRB100SI,NGRB200U,NGRB200V,NGRB200SI,NGRB10NU,NGRB10NV,NGRBZUST,NGRBCLBT,NGRBCSBT,NGRBDNDZN,NGRBDNDZA,NGRBDCTB,NGRBTPLB,NGRBTPLT,NGRBLITOTI,NGRBLITOTA1,NGRBLITOTA3,NGRBLITOTA6,NGRBLICGI,NGRBLICGA1,NGRBLICGA3,NGRBLICGA6,NGRBPTYPEMODE1,NGRBPTYPEMODE3,NGRBPTYPEMODE6,NGRBPTYPESEVR1,NGRBPTYPESEVR3,NGRBPTYPESEVR6,NGRBICETK,NGRBMLD,NGRBSL,NGRB20D,NGRBSSSO,NGRBTEM300,NGRBSAL300,NGRBCO2TYP
  use yomafn, only: tafn
  use yomfpc, only: tnamfpsci
  use yomcompo, only: tcompo
  use yoeaeratm, only: teaeratm
  use forecast_native_fullpos_descriptor_helpers, only: initialize_dynamic_descriptor, initialize_physical_descriptor
use forecast_fullpos_file_metadata,only:fullpos_field_metadata_controls,native_fullpos_file_metadata,native_fullpos_grib_code_targets
  use grid_field_configuration_types_port, only: grid_field_configuration
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, parse_physics_boolean, physics_fold_equal
  use yoe_aerodiag, only: NPAERODIAG, NPAERAOT, NPAERLISI, JPAERO_WVL_AOD
  implicit none
  private
  public :: initialize_selected_fullpos_field_defaults
  character(3), parameter :: CPAERODIAG_LABEL(8) = [character(3) :: 'SRC', 'DDP', 'SDM', 'WDL', 'WDC', 'NGT', 'OD.', 'TC.']
  character(8), parameter :: CPAERO_WVL_DIAG_LABEL(5) = [character(8) :: 'OptDepth', 'AbOptDep', 'FMOptDep', 'SScatAlb', 'Asymmetr']
contains
integer(int32)function initialize_selected_fullpos_field_defaults(text,YDNAMFPSCI,YDAFN,YGFL,controls,file_metadata,codes,YDCOMPO,YDEAERATM,CDFPSFXFNAME)result(status)
  character(*), intent(in) :: text
  type(tnamfpsci), intent(in) :: YDNAMFPSCI
  type(tafn), target, intent(inout) :: YDAFN
  type(grid_field_configuration), intent(in) :: YGFL
  type(fullpos_field_metadata_controls), intent(in) :: controls
  type(native_fullpos_file_metadata), intent(in) :: file_metadata
  type(native_fullpos_grib_code_targets), intent(in) :: codes
  type(tcompo), intent(in), optional :: YDCOMPO
  type(teaeratm), intent(in), optional :: YDEAERATM
  character(*), intent(in), optional :: CDFPSFXFNAME(:)
  INTEGER(KIND=JPIM) :: JGFL, JEMIS, JDIAG, JSTRLEN, JSTRINDEX
  INTEGER(KIND=JPIM) :: JVAR, IGRIB, IVAR
  INTEGER(KIND=JPIM) :: IG
  INTEGER(KIND=JPIM) :: IS
  INTEGER(KIND=JPIM) :: IA
  INTEGER(KIND=JPIM) :: I0, I1, I2, I3
  REAL(KIND=JPRB) :: ZK, Z0
  CHARACTER(LEN=1) :: CL
  CHARACTER(LEN=16) :: CLFA, CLGHG, CLCHEM, CLAERO, CLPREP(JPOSSFX)
  INTEGER(KIND=JPIM) :: IMASK(JPOSSFX)
  LOGICAL :: LLT = .TRUE., LLF = .FALSE.
  LOGICAL :: LLGP_SP
  CHARACTER(LEN=10) :: CLAERO_SCHEME
  logical :: override_present, override_value
  status = 2
  if (.not. associated(codes%ngrbdl)) return
  if (.not. associated(codes%ngrbgpp)) return
  if (.not. associated(codes%ngrbigpp)) return
  if (.not. associated(codes%ngrbinee)) return
  if (.not. associated(codes%ngrbirec)) return
  if (.not. associated(codes%ngrblblt)) return
  if (.not. associated(codes%ngrblicd)) return
  if (.not. associated(codes%ngrblict)) return
  if (.not. associated(codes%ngrblmld)) return
  if (.not. associated(codes%ngrblmlt)) return
  if (.not. associated(codes%ngrblshf)) return
  if (.not. associated(codes%ngrbltlt)) return
  if (.not. associated(codes%ngrbnee)) return
  if (.not. associated(codes%ngrbrec)) return
  if (.not. associated(codes%ngrbtcghg)) return
  if (size(codes%ngrbtcghg) < JPOSGHG) return
  if (.not. file_metadata%ready) return
if(controls%kfpconf/=0.or.controls%ldnhdyn.or.controls%nprintlev/=0.or.controls%larpegef.or.controls%lelam.or.controls%nconf/=1)return
  if (YDNAMFPSCI%NFPSURFEX /= 0) return
  if (YGFL%alias_controls%nnogw /= 2) return
if(any([YGFL%alias_controls%ngfl_ext,YGFL%alias_controls%ngfl_ezdiag,YGFL%alias_controls%nghg,YGFL%alias_controls%naero,YGFL%alias_controls%nera40,YGFL%alias_controls%nedrp,YGFL%alias_controls%naerout,YGFL%alias_controls%nuvp,YGFL%alias_controls%nchem,YGFL%alias_controls%nemis3d,YGFL%settings%nactaero,YGFL%settings%nemis2d,YGFL%settings%nemis2daux,YGFL%settings%nchem_flxo,YGFL%settings%nchem_wdflx,YGFL%settings%nchem_ddflx,YGFL%settings%nchem_tc,YGFL%settings%laeraot,YGFL%alias_controls%laerlisi]/=0))return
  if (YGFL%settings%naero_wvl_diag /= 1 .or. YGFL%settings%naero_wvl_diag_types /= 1) return
  if (YGFL%inactive%yaero_wvl_diag_nl(1)%iwvl /= 550) return
  status = read_afn_override(text, override_present, override_value)
  if (status /= 0) return
  if (YGFL%aliases%yq < 1 .or. YGFL%aliases%yq > size(YGFL%components)) return
  if (YGFL%aliases%yl < 1 .or. YGFL%aliases%yl > size(YGFL%components)) return
  if (YGFL%aliases%yi < 1 .or. YGFL%aliases%yi > size(YGFL%components)) return
  if (YGFL%aliases%ys < 1 .or. YGFL%aliases%ys > size(YGFL%components)) return
  if (YGFL%aliases%yr < 1 .or. YGFL%aliases%yr > size(YGFL%components)) return
  if (YGFL%aliases%yg < 1 .or. YGFL%aliases%yg > size(YGFL%components)) return
  if (YGFL%aliases%yh < 1 .or. YGFL%aliases%yh > size(YGFL%components)) return
  if (YGFL%aliases%ytke < 1 .or. YGFL%aliases%ytke > size(YGFL%components)) return
  if (YGFL%aliases%yefb1 < 1 .or. YGFL%aliases%yefb1 > size(YGFL%components)) return
  if (YGFL%aliases%yefb2 < 1 .or. YGFL%aliases%yefb2 > size(YGFL%components)) return
  if (YGFL%aliases%yefb3 < 1 .or. YGFL%aliases%yefb3 > size(YGFL%components)) return
  if (YGFL%aliases%ya < 1 .or. YGFL%aliases%ya > size(YGFL%components)) return
  if (YGFL%aliases%yo3 < 1 .or. YGFL%aliases%yo3 > size(YGFL%components)) return
  if (YGFL%aliases%ycpf < 1 .or. YGFL%aliases%ycpf > size(YGFL%components)) return
  if (YGFL%aliases%yspf < 1 .or. YGFL%aliases%yspf > size(YGFL%components)) return
  if (YGFL%aliases%ylconv < 1 .or. YGFL%aliases%ylconv > size(YGFL%components)) return
  if (YGFL%aliases%yiconv < 1 .or. YGFL%aliases%yiconv > size(YGFL%components)) return
  if (YGFL%aliases%yrconv < 1 .or. YGFL%aliases%yrconv > size(YGFL%components)) return
  if (YGFL%aliases%ysconv < 1 .or. YGFL%aliases%ysconv > size(YGFL%components)) return
  if (YGFL%aliases%ylrad < 1 .or. YGFL%aliases%ylrad > size(YGFL%components)) return
  if (YGFL%aliases%yirad < 1 .or. YGFL%aliases%yirad > size(YGFL%components)) return
  if (YGFL%aliases%yuom < 1 .or. YGFL%aliases%yuom > size(YGFL%components)) return
  if (YGFL%aliases%yual < 1 .or. YGFL%aliases%yual > size(YGFL%components)) return
  if (YGFL%aliases%ydom < 1 .or. YGFL%aliases%ydom > size(YGFL%components)) return
  if (YGFL%aliases%ydal < 1 .or. YGFL%aliases%ydal > size(YGFL%components)) return
  if (YGFL%aliases%yuen < 1 .or. YGFL%aliases%yuen > size(YGFL%components)) return
  if (YGFL%aliases%yunebh < 1 .or. YGFL%aliases%yunebh > size(YGFL%components)) return
  if (YGFL%aliases%ytte < 1 .or. YGFL%aliases%ytte > size(YGFL%components)) return
  if (YGFL%aliases%ymxl < 1 .or. YGFL%aliases%ymxl > size(YGFL%components)) return
  if (YGFL%aliases%yshtur < 1 .or. YGFL%aliases%yshtur > size(YGFL%components)) return
  if (YGFL%aliases%yfqtur < 1 .or. YGFL%aliases%yfqtur > size(YGFL%components)) return
  if (YGFL%aliases%yfstur < 1 .or. YGFL%aliases%yfstur > size(YGFL%components)) return
  if (YGFL%aliases%yrkth < 1 .or. YGFL%aliases%yrkth > size(YGFL%components)) return
  if (YGFL%aliases%yrktqv < 1 .or. YGFL%aliases%yrktqv > size(YGFL%components)) return
  if (YGFL%aliases%yrktqc < 1 .or. YGFL%aliases%yrktqc > size(YGFL%components)) return
  if (YGFL%aliases%ylrch4 < 1 .or. YGFL%aliases%ylrch4 > size(YGFL%components)) return
  if (YGFL%aliases%yphycty < 1 .or. YGFL%aliases%yphycty > size(YGFL%components)) return
  if (YGFL%aliases%yext%count < 0) return
  if (YGFL%aliases%yext%count > 0) then
if(YGFL%aliases%yext%first_index<1.or.int(YGFL%aliases%yext%first_index,8)+int(YGFL%aliases%yext%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yezdiag%count < 0) return
  if (YGFL%aliases%yezdiag%count > 0) then
if(YGFL%aliases%yezdiag%first_index<1.or.int(YGFL%aliases%yezdiag%first_index,8)+int(YGFL%aliases%yezdiag%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yghg%count < 0) return
  if (YGFL%aliases%yghg%count > 0) then
if(YGFL%aliases%yghg%first_index<1.or.int(YGFL%aliases%yghg%first_index,8)+int(YGFL%aliases%yghg%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%ychem%count < 0) return
  if (YGFL%aliases%ychem%count > 0) then
if(YGFL%aliases%ychem%first_index<1.or.int(YGFL%aliases%ychem%first_index,8)+int(YGFL%aliases%ychem%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yaero%count < 0) return
  if (YGFL%aliases%yaero%count > 0) then
if(YGFL%aliases%yaero%first_index<1.or.int(YGFL%aliases%yaero%first_index,8)+int(YGFL%aliases%yaero%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yera40%count < 0) return
  if (YGFL%aliases%yera40%count > 0) then
if(YGFL%aliases%yera40%first_index<1.or.int(YGFL%aliases%yera40%first_index,8)+int(YGFL%aliases%yera40%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%ynogw%count < 0) return
  if (YGFL%aliases%ynogw%count > 0) then
if(YGFL%aliases%ynogw%first_index<1.or.int(YGFL%aliases%ynogw%first_index,8)+int(YGFL%aliases%ynogw%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yemis3d%count < 0) return
  if (YGFL%aliases%yemis3d%count > 0) then
if(YGFL%aliases%yemis3d%first_index<1.or.int(YGFL%aliases%yemis3d%first_index,8)+int(YGFL%aliases%yemis3d%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yedrp%count < 0) return
  if (YGFL%aliases%yedrp%count > 0) then
if(YGFL%aliases%yedrp%first_index<1.or.int(YGFL%aliases%yedrp%first_index,8)+int(YGFL%aliases%yedrp%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yaeraot%count < 0) return
  if (YGFL%aliases%yaeraot%count > 0) then
if(YGFL%aliases%yaeraot%first_index<1.or.int(YGFL%aliases%yaeraot%first_index,8)+int(YGFL%aliases%yaeraot%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yaerlisi%count < 0) return
  if (YGFL%aliases%yaerlisi%count > 0) then
if(YGFL%aliases%yaerlisi%first_index<1.or.int(YGFL%aliases%yaerlisi%first_index,8)+int(YGFL%aliases%yaerlisi%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yaerout%count < 0) return
  if (YGFL%aliases%yaerout%count > 0) then
if(YGFL%aliases%yaerout%first_index<1.or.int(YGFL%aliases%yaerout%first_index,8)+int(YGFL%aliases%yaerout%count,8)-1>size(YGFL%components))return
  end if
  if (YGFL%aliases%yuvp%count < 0) return
  if (YGFL%aliases%yuvp%count > 0) then
if(YGFL%aliases%yuvp%first_index<1.or.int(YGFL%aliases%yuvp%first_index,8)+int(YGFL%aliases%yuvp%count,8)-1>size(YGFL%components))return
  end if
ASSOCIATE(NFPSURFEX=>YDNAMFPSCI%NFPSURFEX, NSPFILP=>YDNAMFPSCI%NSPFILP, NSPFILT=>YDNAMFPSCI%NSPFILT, NSPFILV=>YDNAMFPSCI%NSPFILV, NSPFILI=>YDNAMFPSCI%NSPFILI, NSPFIL2=>YDNAMFPSCI%NSPFIL2, YI=>YGFL%components(YGFL%aliases%yi), YH=>YGFL%components(YGFL%aliases%yh), YAERO=>YGFL%components(max(1,YGFL%aliases%yaero%first_index):max(1,YGFL%aliases%yaero%first_index)+YGFL%aliases%yaero%count-1), YL=>YGFL%components(YGFL%aliases%yl), YEZDIAG=>YGFL%components(max(1,YGFL%aliases%yezdiag%first_index):max(1,YGFL%aliases%yezdiag%first_index)+YGFL%aliases%yezdiag%count-1), YEXT=>YGFL%components(max(1,YGFL%aliases%yext%first_index):max(1,YGFL%aliases%yext%first_index)+YGFL%aliases%yext%count-1), YGHG=>YGFL%components(max(1,YGFL%aliases%yghg%first_index):max(1,YGFL%aliases%yghg%first_index)+YGFL%aliases%yghg%count-1), YA=>YGFL%components(YGFL%aliases%ya), YSPF=>YGFL%components(YGFL%aliases%yspf), YRKTQV=>YGFL%components(YGFL%aliases%yrktqv), YG=>YGFL%components(YGFL%aliases%yg), NACTAERO=>YGFL%settings%nactaero, NAEROUT=>YGFL%alias_controls%naerout, NNOGW=>YGFL%alias_controls%nnogw, NUVP=>YGFL%alias_controls%nuvp, YMXL=>YGFL%components(YGFL%aliases%ymxl), YCHEM=>YGFL%components(max(1,YGFL%aliases%ychem%first_index):max(1,YGFL%aliases%ychem%first_index)+YGFL%aliases%ychem%count-1), YQ=>YGFL%components(YGFL%aliases%yq), YCPF=>YGFL%components(YGFL%aliases%ycpf), YR=>YGFL%components(YGFL%aliases%yr), NEMIS3D=>YGFL%alias_controls%nemis3d, YEMIS3D=>YGFL%components(max(1,YGFL%aliases%yemis3d%first_index):max(1,YGFL%aliases%yemis3d%first_index)+YGFL%aliases%yemis3d%count-1), YLRCH4=>YGFL%components(YGFL%aliases%ylrch4), NGHG=>YGFL%alias_controls%nghg, YDOM=>YGFL%components(YGFL%aliases%ydom), YUNEBH=>YGFL%components(YGFL%aliases%yunebh), YIRAD=>YGFL%components(YGFL%aliases%yirad), NGFL_EXT=>YGFL%alias_controls%ngfl_ext, YRKTQC=>YGFL%components(YGFL%aliases%yrktqc), YTKE=>YGFL%components(YGFL%aliases%ytke), YUOM=>YGFL%components(YGFL%aliases%yuom),YPHYCTY=>YGFL%components(YGFL%aliases%yphycty), YAEROUT=>YGFL%components(max(1,YGFL%aliases%yaerout%first_index):max(1,YGFL%aliases%yaerout%first_index)+YGFL%aliases%yaerout%count-1), YAERAOT=>YGFL%components(max(1,YGFL%aliases%yaeraot%first_index):max(1,YGFL%aliases%yaeraot%first_index)+YGFL%aliases%yaeraot%count-1), YAERLISI=>YGFL%components(max(1,YGFL%aliases%yaerlisi%first_index):max(1,YGFL%aliases%yaerlisi%first_index)+YGFL%aliases%yaerlisi%count-1), YLCONV=>YGFL%components(YGFL%aliases%ylconv), YICONV=>YGFL%components(YGFL%aliases%yiconv), YRCONV=>YGFL%components(YGFL%aliases%yrconv), YSCONV=>YGFL%components(YGFL%aliases%ysconv), YNOGW=>YGFL%components(max(1,YGFL%aliases%ynogw%first_index):max(1,YGFL%aliases%ynogw%first_index)+YGFL%aliases%ynogw%count-1), YDAL=>YGFL%components(YGFL%aliases%ydal), NAERO=>YGFL%alias_controls%naero, YSHTUR=>YGFL%components(YGFL%aliases%yshtur), NERA40=>YGFL%alias_controls%nera40, YUEN=>YGFL%components(YGFL%aliases%yuen), YUAL=>YGFL%components(YGFL%aliases%yual), YTTE=>YGFL%components(YGFL%aliases%ytte), YERA40=>YGFL%components(max(1,YGFL%aliases%yera40%first_index):max(1,YGFL%aliases%yera40%first_index)+YGFL%aliases%yera40%count-1), NCHEM=>YGFL%alias_controls%nchem, NEMIS2D=>YGFL%settings%nemis2d, NEMIS2DAUX=>YGFL%settings%nemis2daux, YS=>YGFL%components(YGFL%aliases%ys), YFQTUR=>YGFL%components(YGFL%aliases%yfqtur), NCHEM_FLXO=>YGFL%settings%nchem_flxo, NCHEM_TC=>YGFL%settings%nchem_tc, NCHEM_WDFLX=>YGFL%settings%nchem_wdflx, NCHEM_DDFLX=>YGFL%settings%nchem_ddflx, YO3=>YGFL%components(YGFL%aliases%yo3), YUVP=>YGFL%components(max(1,YGFL%aliases%yuvp%first_index):max(1,YGFL%aliases%yuvp%first_index)+YGFL%aliases%yuvp%count-1), YRKTH=>YGFL%components(YGFL%aliases%yrkth), NGFL_EZDIAG=>YGFL%alias_controls%ngfl_ezdiag, YFSTUR=>YGFL%components(YGFL%aliases%yfstur), NEDRP=>YGFL%alias_controls%nedrp, YEDRP=>YGFL%components(max(1,YGFL%aliases%yedrp%first_index):max(1,YGFL%aliases%yedrp%first_index)+YGFL%aliases%yedrp%count-1),YLRAD=>YGFL%components(YGFL%aliases%ylrad), YEFB1=>YGFL%components(YGFL%aliases%yefb1), YEFB2=>YGFL%components(YGFL%aliases%yefb2), YEFB3=>YGFL%components(YGFL%aliases%yefb3), LAERLISI=>(YGFL%alias_controls%laerlisi/=0), LAERAOT=>(YGFL%settings%laeraot/=0), NAERO_WVL_DIAG=>YGFL%settings%naero_wvl_diag, NAERO_WVL_DIAG_TYPES=>YGFL%settings%naero_wvl_diag_types, YAERO_WVL_DIAG_NL=>YGFL%inactive%yaero_wvl_diag_nl)
    IF (PRESENT(YDCOMPO)) THEN
      CLAERO_SCHEME = YDCOMPO%AERO_SCHEME
    ELSE
      CLAERO_SCHEME = ''
    END IF
    CL = ' '
    IA = 8*controls%NREALEN
    IG = file_metadata%NBITPG
    I0 = 0
    I1 = 1
    Z0 = 0._JPRB
    IF (controls%KFPCONF /= 1) THEN
      I2 = 0
      I3 = 0
      IS = file_metadata%NBITCS
      LLGP_SP = .FALSE.
      ZK = 0.0_JPRB
    ELSE
      I2 = 2
      I3 = 3
      IS = file_metadata%NBITPG
      LLGP_SP = (controls%KFPCONF == 1)
      SELECT CASE (controls%LELAM)
      CASE (.TRUE.)
        ZK = 6._JPRB
      CASE (.FALSE.)
        ZK = 4._JPRB
      END SELECT
    END IF
    IF (controls%LDNEWCL(1)) THEN
      call initialize_dynamic_descriptor(YDAFN%TFP%L, LLF, 'CLOUDLIQ.WAT    ', NGRBCLWC, IS, IG, 12, LLT, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%I, LLF, 'CLOUDICECONT    ', NGRBCIWC, IS, IG, 12, LLT, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%LRAD, LLF, 'HUMILIQU.RAD    ', NGRBCLWC, IS, IG, 12, LLT, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%IRAD, LLF, 'HUMISOLI.RAD    ', NGRBCIWC, IS, IG, 12, LLT, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%CLF, LLF, 'CLOUD_COVER     ', NGRBCC, IS, IG, 12, LLT, I1, Z0, 0, CL)
    ELSEIF (controls%LDNEWCL(2)) THEN
call initialize_dynamic_descriptor(YDAFN%TFP%L,LLF,file_metadata%YFAL%CLNAME  ,YL%IGRBCODE ,IS,file_metadata%YFAL%NBITS,12,(YL%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%I,LLF,file_metadata%YFAI%CLNAME  ,YI%IGRBCODE ,IS,file_metadata%YFAI%NBITS,12,(YI%LGP/=0) ,I1,Z0,0,CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%LRAD, LLF, 'HUMILIQU.RAD    ', NGRBCLWC, IS, IG, 12, LLT, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%IRAD, LLF, 'HUMISOLI.RAD    ', NGRBCIWC, IS, IG, 12, LLT, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%CLF, LLF, 'CLOUD_COVER     ', NGRBCC, IS, IG, 12, LLT, I1, Z0, 0, CL)
    ELSE
call initialize_dynamic_descriptor(YDAFN%TFP%L,LLF,file_metadata%YFAL%CLNAME  ,YL%IGRBCODE ,IS,file_metadata%YFAL%NBITS,12,(YL%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%I,LLF,file_metadata%YFAI%CLNAME  ,YI%IGRBCODE ,IS,file_metadata%YFAI%NBITS,12,(YI%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%LRAD,LLF,file_metadata%YFALRAD%CLNAME,YLRAD%IGRBCODE,IS,file_metadata%YFALRAD%NBITS,12,(YLRAD%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%IRAD,LLF,file_metadata%YFAIRAD%CLNAME,YIRAD%IGRBCODE,IS,file_metadata%YFAIRAD%NBITS,12,(YIRAD%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%CLF,LLF,file_metadata%YFACLF%CLNAME,YA%IGRBCODE ,IS,file_metadata%YFACLF%NBITS,12,(YA%LGP/=0) ,I1,Z0,0,CL)
    END IF
    call initialize_dynamic_descriptor(YDAFN%TFP%Q,LLF,file_metadata%YFAQ%CLNAME  ,YQ%IGRBCODE ,IS,IG,12,(YQ%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%O3MX,LLF,file_metadata%YFAO3%CLNAME ,YO3%IGRBCODE,IS,file_metadata%YFAO3%NBITS,12,(YO3%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%CPF,LLF,file_metadata%YFACPF%CLNAME ,YCPF%IGRBCODE,IS,file_metadata%YFACPF%NBITS,12,(YCPF%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%SPF,LLF,file_metadata%YFASPF%CLNAME ,YSPF%IGRBCODE,IS,file_metadata%YFASPF%NBITS,12,(YSPF%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%SN,LLF,file_metadata%YFAS%CLNAME  ,YS%IGRBCODE ,IS,file_metadata%YFAS%NBITS,12,(YS%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%RR,LLF,file_metadata%YFAR%CLNAME  ,YR%IGRBCODE ,IS,file_metadata%YFAR%NBITS,12,(YR%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%GR,LLF,file_metadata%YFAG%CLNAME  ,YG%IGRBCODE ,IS,file_metadata%YFAG%NBITS,12,(YG%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%HL,LLF,file_metadata%YFAH%CLNAME  ,YH%IGRBCODE ,IS,file_metadata%YFAH%NBITS,12,(YH%LGP/=0) ,I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%TKE,LLF,file_metadata%YFATKE%CLNAME,YTKE%IGRBCODE,IS,file_metadata%YFATKE%NBITS,12,(YTKE%LGP/=0),I1,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%PHYCTY,LLF,YPHYCTY%CNAME,YPHYCTY%IGRBCODE,IS,IG,12,(YPHYCTY%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%EFB1,LLF,file_metadata%YFAEFB1%CLNAME,YEFB1%IGRBCODE,IS,file_metadata%YFAEFB1%NBITS,12,(YEFB1%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%EFB2,LLF,file_metadata%YFAEFB2%CLNAME,YEFB2%IGRBCODE,IS,file_metadata%YFAEFB2%NBITS,12,(YEFB2%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%EFB3,LLF,file_metadata%YFAEFB3%CLNAME,YEFB3%IGRBCODE,IS,file_metadata%YFAEFB3%NBITS,12,(YEFB3%LGP/=0),I1,Z0,0,CL)
  call initialize_dynamic_descriptor(YDAFN%TFP%DAL,LLF,file_metadata%YFADAL%CLNAME ,YDAL%IGRBCODE,IS,IG,12,(YDAL%LGP/=0),I1,Z0,0,CL)
  call initialize_dynamic_descriptor(YDAFN%TFP%DOM,LLF,file_metadata%YFADOM%CLNAME ,YDOM%IGRBCODE,IS,IG,12,(YDOM%LGP/=0),I1,Z0,0,CL)
  call initialize_dynamic_descriptor(YDAFN%TFP%UAL,LLF,file_metadata%YFAUAL%CLNAME ,YUAL%IGRBCODE,IS,IG,12,(YUAL%LGP/=0),I1,Z0,0,CL)
  call initialize_dynamic_descriptor(YDAFN%TFP%UOM,LLF,file_metadata%YFAUOM%CLNAME ,YUOM%IGRBCODE,IS,IG,12,(YUOM%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%LCONV,LLF,file_metadata%YFALCONV%CLNAME ,YLCONV%IGRBCODE,IS,IG,12,(YLCONV%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%ICONV,LLF,file_metadata%YFAICONV%CLNAME ,YICONV%IGRBCODE,IS,IG,12,(YICONV%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%RCONV,LLF,file_metadata%YFARCONV%CLNAME ,YRCONV%IGRBCODE,IS,IG,12,(YRCONV%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%SCONV,LLF,file_metadata%YFASCONV%CLNAME ,YSCONV%IGRBCODE,IS,IG,12,(YSCONV%LGP/=0),I1,Z0,0,CL)
  call initialize_dynamic_descriptor(YDAFN%TFP%UEN,LLF,file_metadata%YFAUEN%CLNAME ,YUEN%IGRBCODE,IS,IG,12,(YUEN%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%UNEBH,LLF,file_metadata%YFAUNEBH%CLNAME ,YUNEBH%IGRBCODE,IS,IG,12,(YUNEBH%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%RKTH,LLF,file_metadata%YFARKTH%CLNAME ,YRKTH%IGRBCODE,IS,IG,12,(YRKTH%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%RKTQV,LLF,file_metadata%YFARKTQV%CLNAME ,YRKTQV%IGRBCODE,IS,IG,12,(YRKTQV%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%RKTQC,LLF,file_metadata%YFARKTQC%CLNAME ,YRKTQC%IGRBCODE,IS,IG,12,(YRKTQC%LGP/=0),I1,Z0,0,CL)
  call initialize_dynamic_descriptor(YDAFN%TFP%TTE,LLF,file_metadata%YFATTE%CLNAME ,YTTE%IGRBCODE,IS,IG,12,(YTTE%LGP/=0),I1,Z0,0,CL)
  call initialize_dynamic_descriptor(YDAFN%TFP%MXL,LLF,file_metadata%YFAMXL%CLNAME ,YMXL%IGRBCODE,IS,IG,12,(YMXL%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%SHTUR,LLF,file_metadata%YFASHTUR%CLNAME ,YSHTUR%IGRBCODE,IS,IG,12,(YSHTUR%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%FQTUR,LLF,file_metadata%YFAFQTUR%CLNAME ,YFQTUR%IGRBCODE,IS,IG,12,(YFQTUR%LGP/=0),I1,Z0,0,CL)
call initialize_dynamic_descriptor(YDAFN%TFP%FSTUR,LLF,file_metadata%YFAFSTUR%CLNAME ,YFSTUR%IGRBCODE,IS,IG,12,(YFSTUR%LGP/=0),I1,Z0,0,CL)
    DO JGFL = 1, JPOSEMIS3D
    IF (JGFL <= NEMIS3D) THEN
call initialize_dynamic_descriptor(YDAFN%TFP%EMIS3D(JGFL),LLF,YEMIS3D(JGFL)%CNAME,YEMIS3D(JGFL)%IGRBCODE,IS,IG,12,(YEMIS3D(JGFL)%LGP/=0),I1,Z0,0,CL)
    ELSE
      WRITE (CLFA, '(''EMIS3D'',I2.2,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%EMIS3D(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END IF
    YDAFN%TFP%EMIS3D(JGFL)%IORDR = 0
    END DO
    DO JGFL = 1, JPOSGHG
    IF (JGFL <= NGHG) THEN
call initialize_dynamic_descriptor(YDAFN%TFP%GHG(JGFL),LLF,YGHG(JGFL)%CNAME,YGHG(JGFL)%IGRBCODE,IS,IG,12,(YGHG(JGFL)%LGP/=0),I1,Z0,0,CL)
    ELSE
      WRITE (CLFA, '(''GHG'',I2.2,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%GHG(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END IF
    YDAFN%TFP%GHG(JGFL)%IORDR = 0
    END DO
    DO JGFL = 1, JPOSEZDIAG
    IF (JGFL <= NGFL_EZDIAG) THEN
call initialize_dynamic_descriptor(YDAFN%TFP%EZDIAG(JGFL),LLF,YEZDIAG(JGFL)%CNAME,YEZDIAG(JGFL)%IGRBCODE,IS,IG,12,(YEZDIAG(JGFL)%LGP/=0),I1,Z0,0,CL)
    ELSE
      WRITE (CLFA, '(''EZDIAG'',I2.2,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%EZDIAG(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END IF
    YDAFN%TFP%EZDIAG(JGFL)%IORDR = 0
    END DO
    DO JGFL = 1, JPOSAERO
    IF (JGFL <= NAERO) THEN
call initialize_dynamic_descriptor(YDAFN%TFP%AERO(JGFL),LLF,YAERO(JGFL)%CNAME,YAERO(JGFL)%IGRBCODE,IS,IG,12,(YAERO(JGFL)%LGP/=0),I1,Z0,0,CL)
    ELSE
      WRITE (CLFA, '(''AERO'',I2.2,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%AERO(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END IF
    YDAFN%TFP%AERO(JGFL)%IORDR = 0
    END DO
    DO JGFL = 1, JPOSCHEM
    IF (JGFL <= NCHEM) THEN
call initialize_dynamic_descriptor(YDAFN%TFP%CHEM(JGFL),LLF,YCHEM(JGFL)%CNAME,YCHEM(JGFL)%IGRBCODE,IS,IG,12,(YCHEM(JGFL)%LGP/=0),I1,Z0,0,CL)
    ELSE
      WRITE (CLFA, '(''CHEM'',I3.3,''      '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%CHEM(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END IF
    YDAFN%TFP%CHEM(JGFL)%IORDR = 0
    END DO
    call initialize_dynamic_descriptor(YDAFN%TFP%LRCH4,LLF,YLRCH4%CNAME,YLRCH4%IGRBCODE,IS,IG,12,(YLRCH4%LGP/=0),I1,Z0,0,CL)
    IF (NNOGW > 0) THEN
    DO JGFL = 1, NNOGW
call initialize_dynamic_descriptor(YDAFN%TFP%NOGW(JGFL),LLF,YNOGW(JGFL)%CNAME,YNOGW(JGFL)%IGRBCODE,IS,IG,12,(YNOGW(JGFL)%LGP/=0),I1,Z0,0,CL)
    END DO
    ELSE
    DO JGFL = 1, JPOSNOGW
      WRITE (CLFA, '(''NOGW'',I3.3,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%NOGW(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END DO
    END IF
    IF (NEDRP > 0) THEN
    DO JGFL = 1, NEDRP
call initialize_dynamic_descriptor(YDAFN%TFP%EDRP(JGFL),LLF,YEDRP(JGFL)%CNAME,YEDRP(JGFL)%IGRBCODE,IS,IG,12,(YEDRP(JGFL)%LGP/=0),I1,Z0,0,CL)
    END DO
    ELSE
    DO JGFL = 1, JPOSEDRP
      WRITE (CLFA, '(''NEDRP'',I3.3,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%EDRP(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END DO
    END IF
    IF (LAERAOT .AND. NAERO > 0) THEN
    DO JGFL = 1, NPAERAOT
call initialize_dynamic_descriptor(YDAFN%TFP%AERAOT(JGFL),LLF,YAERAOT(JGFL)%CNAME,YAERAOT(JGFL)%IGRBCODE,IS,IG,12,(YAERAOT(JGFL)%LGP/=0),I1,Z0,0,CL)
    END DO
    ELSE
    DO JGFL = 1, JPOSAERAOT
      WRITE (CLFA, '(''AERAOT'',I3.3,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%AERAOT(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END DO
    END IF
    IF (LAERLISI) THEN
    DO JGFL = 1, NPAERLISI
call initialize_dynamic_descriptor(YDAFN%TFP%AERLISI(JGFL),LLF,YAERLISI(JGFL)%CNAME,YAERLISI(JGFL)%IGRBCODE,IS,IG,12,(YAERLISI(JGFL)%LGP/=0),I1,Z0,0,CL)
    END DO
    ELSE
    DO JGFL = 1, JPOSAERLISI
      WRITE (CLFA, '(''AERLISI'',I3.3,''   '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%AERLISI(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END DO
    END IF
    IF (NAEROUT > 0) THEN
    DO JGFL = 1, NAEROUT
call initialize_dynamic_descriptor(YDAFN%TFP%AEROUT(JGFL),LLF,YAEROUT(JGFL)%CNAME,YAEROUT(JGFL)%IGRBCODE,IS,IG,12,(YAEROUT(JGFL)%LGP/=0),I1,Z0,0,CL)
    END DO
    END IF
    IF (NAEROUT < JPOSAEROUT) THEN
    DO JGFL = NAEROUT + 1, JPOSAEROUT
      WRITE (CLFA, '(''AEROUT'',I3.3,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%AEROUT(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END DO
    END IF
    IF (NUVP > 0) THEN
    DO JGFL = 1, NUVP
call initialize_dynamic_descriptor(YDAFN%TFP%UVP(JGFL),LLF,YUVP(JGFL)%CNAME,YUVP(JGFL)%IGRBCODE,IS,IG,12,(YUVP(JGFL)%LGP/=0),I1,Z0,0,CL)
    END DO
    END IF
    IF (NUVP < JPOSUVP) THEN
    DO JGFL = NUVP + 1, JPOSUVP
      WRITE (CLFA, '(''UVP'',I3.3,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%UVP(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END DO
    END IF
    IF (NERA40 > 0) THEN
      IVAR = 1
      IGRIB = NGRBMINERA
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.SW.RAD     ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 1_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.LW.RAD     ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 2_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.SW.RAD.CSKY',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 3_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.LW.RAD.CSKY',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 4_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'MASS.FLUX.UP    ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 5_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'MASS.FLUX.DOWN  ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 6_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'DET.RATE.UP     ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 7_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'DET.RATE.DOWN   ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 8_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TOT.PREP.FLUX   ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 9_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'DIFFUSION.COEFF ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 10_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.TEMPERATURE',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 11_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.SPE.HUMIDIT',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 12_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.U          ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
      IVAR = IVAR + 1
      IGRIB = NGRBMINERA + 13_JPIM
    call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(IVAR),LLF,'TEND.V          ',IGRIB,IS,IG,12,(YERA40(IVAR)%LGP/=0),I1,Z0,0,CL)
    ELSE
      DO JVAR = 1, JPOSERA40
        WRITE (CLFA, '(''ERA40.'',I3.3,''       '')') JVAR
        IGRIB = -9999
        call initialize_dynamic_descriptor(YDAFN%TFP%ERA40(JVAR), LLF, CLFA, IGRIB, IS, IG, 12, LLT, I1, Z0, 0, CL)
      END DO
    END IF
    DO JGFL = 1, JPOSSCVA
    IF (JGFL <= NGFL_EXT) THEN
call initialize_dynamic_descriptor(YDAFN%TFP%EXT(JGFL),LLF,YEXT(JGFL)%CNAME,YEXT(JGFL)%IGRBCODE,IS,IG,12,(YEXT(JGFL)%LGP/=0),I1,Z0,0,CL)
    ELSE
      WRITE (CLFA, '(''EXTGFL.'',I2.2,''       '')') JGFL
      IGRIB = -9999
      call initialize_dynamic_descriptor(YDAFN%TFP%EXT(JGFL), LLF, CLFA, IGRIB, IS, IG, 12, LLF, I1, Z0, 0, CL)
    END IF
    YDAFN%TFP%EXT(JGFL)%IORDR = 0
    END DO
    IF (.NOT. controls%LARPEGEF .AND. controls%NCONF /= 901) THEN
      call initialize_dynamic_descriptor(YDAFN%TFP%U, LLF, 'U-VELOCITY      ', NGRBU, IS, IG, 12, LLF, I1, Z0, +1, 'ATM')
      call initialize_dynamic_descriptor(YDAFN%TFP%V, LLF, 'V-VELOCITY      ', NGRBV, IS, IG, 12, LLF, I1, Z0, -1, 'ATM')
   call initialize_dynamic_descriptor(YDAFN%TFP%KHI, LLF, file_metadata%YFAKHI%CLNAME, NGRBSTRF, IS, IG, 12, LLF, I1, Z0, 0, 'VPSF')
     call initialize_dynamic_descriptor(YDAFN%TFP%PSI, LLF, file_metadata%YFAPSI%CLNAME, NGRBVP, IS, IG, 12, LLF, I1, Z0, 0, 'VPSF')
      call initialize_dynamic_descriptor(YDAFN%TFP%T, LLF, file_metadata%YFAT%CLNAME, NGRBT, IS, IG, 12, LLF, NSPFILI, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%Z, LLF, 'GEOPOTENTIAL    ', NGRBZ, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%WND, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HU, LLF, 'RELATIVE_HUM    ', NGRBR, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TH, LLF, 'POT_TEMPERAT    ', NGRBPT, IS, IG, 12, LLF, NSPFILT, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%THPW, LLF, 'THETA_PRIM_W    ', -99999, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ETH, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%IET, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SRE, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SREDB, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%THV, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%P, LLF, 'PRESSURE        ', NGRBPRES, IS, IG, 12, LLF, NSPFILP, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PD, LLF, file_metadata%YFAPD%CLNAME, NGRB118, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VD, LLF, file_metadata%YFAVD%CLNAME, NGRB119, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MG, LLF, 'MONTGOMERY G    ', NGRBMONT, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VW, LLF, 'VERT.VELOCIT    ', NGRB120, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PV, LLF, 'POT_VORTICIT    ', NGRBPV, IS, IG, 12, LLT, NSPFILV, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VV, LLF, 'VERTVELOCITY    ', NGRBW, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ETAD, LLF, 'ETADOT          ', NGRBETADOT, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%STD, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SHD, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ABS, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VOR, LLF, 'VORTICITY       ', NGRBVO, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%DIV, LLF, 'DIVERGENCE      ', NGRBD, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PTB, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTB, LLF, 'XXXXXXXXXXXX    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%RHO, LLF, 'HUMID_DENSIT    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%EDR, LLF, 'EDR             ', -99999, IS, IG, 12, LLT, I1, Z0, 0, CL)
      DO JVAR = 1, JPOSVX2
        IGRIB = NGRBMINXTRA + JVAR - 1
        IF (IGRIB <= NGRBMAXXTRA) THEN
          WRITE (CLFA, '(''UPPER_AIR.'',I2.2,''    '')') JVAR
          call initialize_dynamic_descriptor(YDAFN%TFP%FUA(JVAR), LLF, CLFA, IGRIB, IS, IG, 12, LLT, I1, ZK, 0, CL)
        ELSE
          CLFA = 'XXXXXXXXXXXX    '
          call initialize_dynamic_descriptor(YDAFN%TFP%FUA(JVAR), LLF, CLFA, -99999, IS, IG, 12, LLT, I1, ZK, 0, CL)
        END IF
      END DO
      IF (controls%KFPCONF /= 1) THEN
        call initialize_dynamic_descriptor(YDAFN%TFP%SP, LLT, 'AGAIN.SURF.PRESS', NGRBSP, IS, IG, 12, LLGP_SP, I1, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%LNSP, LLT, file_metadata%YFASP%CLNAME, NGRBLNSP, IS, IG, 12, LLGP_SP, I1, Z0, 0, CL)
      ELSE
       call initialize_dynamic_descriptor(YDAFN%TFP%SP, LLT, file_metadata%YFASP%CLNAME, NGRBSP, IS, IG, 12, LLGP_SP, I1, Z0, 0, CL)
        call initialize_dynamic_descriptor(YDAFN%TFP%LNSP, LLT, 'LOG.SURF.PRESSIO', NGRBLNSP, IS, IG, 12, LLGP_SP, I1, Z0, 0, CL)
      END IF
      call initialize_dynamic_descriptor(YDAFN%TFP%MSL, LLT, 'MSLPRESSURE     ', NGRBMSL, IS, IG, 12, LLF, I1, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF1, LLT, file_metadata%YFAFSP1%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF2, LLT, file_metadata%YFAFSP2%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF3, LLT, file_metadata%YFAFSP3%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF4, LLT, file_metadata%YFAFSP4%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF5, LLT, file_metadata%YFAFSP5%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FIS, LLT, file_metadata%YFAOROG%CLNAME, NGRBZ, IA, IA, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%WWS, LLT, 'SURFVERT.VELOCIT', NGRB080, IS, IG, 12, LLF, I1, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PJET, LLT, 'JETPRESSURE     ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TCAO, LLT, 'ICAOTROP.TEMPERA', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PCAO, LLT, 'ICAOTROP.PRESSUR', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTPW, LLT, 'SURFISOTPW0.MALT', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTPW1, LLT, 'SURFISOTPW1.MALT', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTPW2, LLT, 'SURFISOTPW2.MALT', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%GM, LLT, 'MAP_FACTOR      ', 126, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FOL, LLT, 'TROPO_FOLD_INDIC', 125, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%UCLS, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, +1, 'CLS')
      call initialize_dynamic_descriptor(YDAFN%TFP%VCLS, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, -1, 'CLS')
      call initialize_dynamic_descriptor(YDAFN%TFP%TCLS, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%QCLS, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%RCLS, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FCLS, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%CAPE, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%CIEN, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TCVS, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SREX, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SREDBX, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TOPR, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 0, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MOCO, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TWV, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%UGST, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, +1, 'GST')
      call initialize_dynamic_descriptor(YDAFN%TFP%VGST, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, -1, 'GST')
      call initialize_dynamic_descriptor(YDAFN%TFP%FGST, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HCLP, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VEIN, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SMC, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ASMC, LLT, file_metadata%YFA_ASMC%CLNAME, -99999, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VSMC, LLT, file_metadata%YFA_VSMC%CLNAME, -99999, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%QNH, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MSK, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MSLNH, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SPNH, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%LCL, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FCL, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%EL, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      DO JVAR = 1, JPOSFSU
        SELECT CASE (JVAR)
        CASE (1)
          IGRIB = 124
        CASE (2)
          IGRIB = 123
        CASE (3)
          IGRIB = 122
        CASE (4)
          IGRIB = 121
        CASE DEFAULT
          IGRIB = -99999
        END SELECT
        IF (IGRIB > 0) THEN
          WRITE (CLFA, '(''SURF2D.'',I2.2,''       '')') JVAR
        ELSE
          CLFA = 'XXXXXXXXXXXXXXXX'
        END IF
        call initialize_dynamic_descriptor(YDAFN%TFP%FSU(JVAR), LLT, CLFA, IGRIB, IS, IG, 12, LLT, I1, Z0, 0, CL)
      END DO
      call initialize_dynamic_descriptor(YDAFN%TFP%UJET, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, +1, 'JET')
      call initialize_dynamic_descriptor(YDAFN%TFP%VJET, LLT, 'XXXXXXXXXXXXXXXX', -99999, IS, IG, 12, LLT, I0, Z0, -1, 'JET')
      call initialize_physical_descriptor(YDAFN%GFP%SDFOR, NGRBSDFOR, IG, 12, 0, 0, 1, LLF, LLT, 'SD FILTERED OROG', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CGPP, NGRBFASGPPCOEF, IG, 12, 0, 0, 1, LLF, LLT, 'GPP.FLX.ADJ.C.', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CREC, NGRBFASRECCOEF, IG, 12, 0, 0, 1, LLF, LLT, 'REC.FLX.ADJ.C.', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10FG, NGRB10FG, IG, 12, 0, 0, 1, LLF, LLT, 'WIND GUST 10 M  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10FG3, NGRB10FG3, IG, 12, 0, 0, 1, LLF, LLT, 'W.G. 10M LAST 3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10FG6, NGRB10FG6, IG, 12, 0, 0, 1, LLF, LLT, 'W.G. 10M LAST 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%I10FG, NGRBI10FG, IG, 12, 0, 0, 1, LLF, LLT, 'W.GUST 10M INST ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10U, NGRB10U, IG, 12, 0, 0, 1, LLF, LLT, '10M.UWIND       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10V, NGRB10V, IG, 12, 0, 0, 1, LLF, LLT, '10M.VWIND       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10SI, NGRB10SI, IG, 12, 0, 0, 1, LLF, LLT, '10M.WIND.SPEED  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC100U, NGRB100U, IG, 12, 0, 0, 1, LLF, LLT, '100M.UWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC100V, NGRB100V, IG, 12, 0, 0, 1, LLF, LLT, '100M.VWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC100SI, NGRB100SI, IG, 12, 0, 0, 1, LLF, LLT, '100M.WIND.SPEED ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC200U, NGRB200U, IG, 12, 0, 0, 1, LLF, LLT, '200M.UWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC200V, NGRB200V, IG, 12, 0, 0, 1, LLF, LLT, '200M.VWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC200SI, NGRB200SI, IG, 12, 0, 0, 1, LLF, LLT, '200M.WIND.SPEED ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ZUST, NGRBZUST, IG, 12, 0, 0, 1, LLF, LLT, 'FRICT. VELOCITY ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10NU, NGRB10NU, IG, 12, 0, 0, 1, LLF, LLT, '10M.NEUTRL UWIND', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10NV, NGRB10NV, IG, 12, 0, 0, 1, LLF, LLT, '10M.NEUTRL VWIND', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC2D, NGRB2D, IG, 12, 0, 0, 1, LLF, LLT, '2M.DEWPOINT     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC2SH, NGRB2SH, IG, 12, 0, 0, 1, LLF, LLT, '2M.HUMIDITY     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC2T, NGRB2T, IG, 12, 0, 0, 1, LLF, LLT, '2M.TEMPERATURE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ACOT, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFVAR.GEOP.ANI', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AL, NGRBAL, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALB, NGRBFAL, IG, 12, 0, 0, 1, LLF, LLT, 'ALBEDO          ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALS, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO.SOLNU', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALSN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVP, NGRBALUVP, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.UVis PARALL.', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVD, NGRBALUVD, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.UVis DIFFUSE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNIP, NGRBALNIP, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.N-IR PARALL.', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNID, NGRBALNID, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.N-IR DIFFUSE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVI, NGRBALUVI, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.UVisPARALL.I', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNII, NGRBALNII, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.N-IRPARALL.I', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVV, NGRBALUVV, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.UVisPARALL.V', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNIV, NGRBALNIV, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.N-IRPARALL.V', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVG, NGRBALUVG, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.UVisPARALL.G', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNIG, NGRBALNIG, IG, 12, 0, 0, 1, LLF, LLT, 'ALB.N-IRPARALL.G', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AERDEP, NGRBAERDEP, IG, 12, 0, 0, 1, LLF, LLT, 'Dust emiss.poten', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AERLTS, NGRBAERLTS, IG, 12, 0, 0, 1, LLF, LLT, 'Lift.Thres.speed', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AERSCC, NGRBAERSCC, IG, 12, 0, 0, 1, LLF, LLT, 'Soil clay contnt', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DSF, NGRBAERDSF, IG, 12, 0, 0, 1, LLF, LLT, 'Dust Source fctn', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DSZ, NGRBAERDSZ, IG, 12, 0, 0, 1, LLF, LLT, 'Dust size distri', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SO2DD, NGRBAERSO2DD, IG, 12, 0, 0, 1, LLF, LLT, 'SO2 dry dep vel.', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DMSO, NGRBAERLS13, IG, 12, 0, 0, 1, LLF, LLT, 'Oceanic DMS     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%URBF, NGRBAERURBF, IG, 12, 0, 0, 1, LLF, LLT, 'Urban fraction  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FCA1, NGRBAERFCA1, IG, 12, 0, 0, 1, LLF, LLT, 'CalciteFraction1', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FCA2, NGRBAERFCA2, IG, 12, 0, 0, 1, LLF, LLT, 'CalciteFraction2', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODSS, NGRBAEODSS, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthSeaSalt ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODDU, NGRBAEODDU, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthDust    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODOM, NGRBAEODOM, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthOrganicM', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODBC, NGRBAEODBC, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthBlackCar', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODSU, NGRBAEODSU, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthSulphate', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODNI, NGRBAEODNI, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthNitrate', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODAM, NGRBAEODAM, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthAmmonium', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODSOA, NGRBAEODSOA, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthSOA     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODVFA, NGRBAEODVFA, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthVFlyAsh ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODVSU, NGRBAEODVSU, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthVSulfate', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODTOACC, NGRBACCAOD550, IG, 12, 0, 0, 1, LLF, LLT, 'OptDepthAerAcc  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AEPM1, NGRBAEPM1, IG, 12, 0, 0, 1, LLF, LLT, 'ParticMatter.1um', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AEPM25, NGRBAEPM25, IG, 12, 0, 0, 1, LLF, LLT, 'ParticMatter25um', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AEPM10, NGRBAEPM10, IG, 12, 0, 0, 1, LLF, LLT, 'ParticMatter10um', CL)
      call initialize_physical_descriptor(YDAFN%GFP%UVBED, NGRBUVBED, IG, 12, 0, 0, 1, LLF, LLT, 'UVBioEffectDose', CL)
      call initialize_physical_descriptor(YDAFN%GFP%UVBEDCS, NGRBUVBEDCS, IG, 12, 0, 0, 1, LLF, LLT, 'UVBioEffectDoseCS', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALV, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO.VEG  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ANOR, NGRBANOR, IG, 12, 0, 0, 1, LLF, LLT, 'ANGLE.SUB.SOROG ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ARG, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.ARGILE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASN, NGRBASN, IG, 12, 0, 0, 1, LLF, LLT, 'SNOW ALBEDO     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%BAAL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO.COMPL', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALBHIS, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO HISTO', CL)
      call initialize_physical_descriptor(YDAFN%GFP%BLD, NGRBBLD, IG, 12, 0, 0, 1, LLF, LLT, 'PBL.DISSIP.     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%BLH, NGRBBLH, IG, 12, 0, 0, 1, LLF, LLT, 'BOUND.LAY.HEIGHT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%BSR, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'SURFZ0REL.FOIS.G', CL)
      call initialize_physical_descriptor(YDAFN%GFP%BV, NGRBBV, IG, 12, 0, 0, 1, LLF, LLT, 'BUDGET VALUES   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CBASE, NGRBCBASE, IG, 12, 0, 0, 1, LLF, LLT, 'CLOUD BASE LEVEL', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CCC, NGRBCCC, IG, 12, 0, 0, 1, LLF, LLT, 'CONV.CC         ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CDSW, NGRBDHR, IG, 12, 0, 0, 1, LLF, LLT, 'PROFPROP.RMAX.EA', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CHAR, NGRBCHNK, IG, 12, 0, 0, 1, LLF, LLT, 'CHARNOCK.PARAM  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CI, NGRBCI, IG, 12, 0, 0, 1, LLF, LLT, 'SEA ICE COVER   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CP, NGRBCP, IG, 12, 0, 0, 1, LLF, LLT, 'CONV.PRECIP.    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSF, NGRBCSF, IG, 12, 0, 0, 1, LLF, LLT, 'CONV.SNOWFALL   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSSW, NGRBDHVD, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.RMAX.EA', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CVH, NGRBCVH, IG, 12, 0, 0, 1, LLF, LLT, 'HIGH VEG. COVER ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CVL, NGRBCVL, IG, 12, 0, 0, 1, LLF, LLT, 'LOW VEG. COVER  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CUR, NGRBCUR, IG, 12, 0, 0, 1, LLF, LLT, 'URBAN COVER     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CO2TYP, NGRBCO2TYP, IG, 12, 0, 0, 1, LLF, LLT, 'CO2 PHOTOS. TYPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FWET, NGRBFWET, IG, 12, 0, 0, 1, LLF, LLT, 'WETLAND FRACTION', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAIL, NGRBLAIL, IG, 12, 0, 0, 1, LLF, LLT, 'LAI LOW VEG.    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAIH, NGRBLAIH, IG, 12, 0, 0, 1, LLF, LLT, 'LAI HIGH VEG.   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%D2, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFEPAIS.SOL   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%D2MX, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DPAT, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFVAR.GEOP.DIR', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DST, NGRBVDMW, IG, 12, 0, 1, 1, LLF, LLT, 'PROFTEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DSW, NGRBDHLC, IG, 12, 0, 1, 1, LLF, LLT, 'PROFRESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%E, NGRBE, IG, 12, 0, 0, 1, LLF, LLT, 'EVAPORATION     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PEV, NGRBPEV, IG, 12, 0, 0, 1, LLF, LLT, 'POT. EVAPORATION', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EMIS, NGRBEMIS, IG, 12, 0, 0, 1, LLF, LLT, 'SURFEMISSIVITE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ES, NGRBES, IG, 12, 0, 0, 1, LLF, LLT, 'EVA. SNOW       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EWSS, NGRBEWSS, IG, 12, 0, 0, 1, LLF, LLT, 'U-STRESS        ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FDSW, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FSSW, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FZRA, NGRBFZRA, IG, 12, 0, 0, 1, LLF, LLT, 'FREEZING RAIN   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%GFIS, NGRBZ, IA, 12, 0, 0, 0, LLF, LLT, 'SURFGEOPOTENTIEL', CL)
      call initialize_physical_descriptor(YDAFN%GFP%GWD, NGRBGWD, IG, 12, 0, 0, 1, LLF, LLT, 'GRAV.WAVE.DISSIP', CL)
      call initialize_physical_descriptor(YDAFN%GFP%HCC, NGRBHCC, IG, 12, 0, 0, 1, LLF, LLT, 'HIGH.CC         ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%HV, -9999, IG, 12, 0, 0, 1, LLT, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IC, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IDZ0, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IE, NGRBIE, IG, 12, 0, 0, 1, LLF, LLT, 'INST.S.MOI.FLUX ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IEWSS, NGRBIEWS, IG, 12, 0, 0, 1, LLF, LLT, 'INST.X-SURF.ST. ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCHN, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.HN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCHX, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.HX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCTN, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.TN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCTX, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.TX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INSSS, NGRBINSS, IG, 12, 0, 0, 1, LLF, LLT, 'INST.Y-SURF.ST. ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISOR, NGRBISOR, IG, 12, 0, 0, 1, LLF, LLT, 'ANISO.SUB.SOROG ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISSHF, NGRBISHF, IG, 12, 0, 0, 1, LLF, LLT, 'INST.S.HEAT.FLUX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL1, NGRBISTL1, IG, 12, 0, 0, 1, LLF, LLT, 'ICE SURF.TEMP. 1', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL2, NGRBISTL2, IG, 12, 0, 0, 1, LLF, LLT, 'ICE SURF.TEMP. 2', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL3, NGRBISTL3, IG, 12, 0, 0, 1, LLF, LLT, 'ICE SURF.TEMP. 3', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL4, NGRBISTL4, IG, 12, 0, 0, 1, LLF, LLT, 'ICE SURF.TEMP. 4', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ITZ0, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IVEG, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFIND.VEG.DOMI', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAI, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFIND.FOLIAIRE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAN, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LCC, NGRBLCC, IG, 12, 0, 0, 1, LLF, LLT, 'LOW.CC          ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LGWS, NGRBLGWS, IG, 12, 0, 0, 1, LLF, LLT, 'LAT.GRAV.WAVE.ST', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSF, NGRBLSF, IG, 12, 0, 0, 1, LLF, LLT, 'LARGE.SCALE.SNOW', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSM, NGRBLSM, IG, 12, 0, 0, 0, LLF, LLT, 'SURFIND.TERREMER', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSP, NGRBLSP, IG, 12, 0, 0, 1, LLF, LLT, 'LARGESCAPRECIP. ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSPF, NGRBLSPF, IG, 12, 0, 0, 1, LLF, LLT, 'LSC PREC. FRACT.', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSRH, NGRBLSRH, IA, 12, 0, 0, 1, LLF, LLT, 'LOG.SURF.ROUGH  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LZ0H, NGRBFLSR, IA, 12, 0, 0, 1, LLF, LLT, 'LOG.S.ROUGH.HEAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MCC, NGRBMCC, IG, 12, 0, 0, 1, LLF, LLT, 'MEDIUM.CC       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MGWS, NGRBMGWS, IG, 12, 0, 0, 1, LLF, LLT, 'MER.GRAV.WAVE.ST', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MN2T, NGRBMN2T, IG, 12, 0, 0, 1, LLF, LLT, 'MIN.TEMP.       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MN2T3, NGRBMN2T3, IG, 12, 0, 0, 1, LLF, LLT, 'MIN.TEMP.LAST 3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MN2T6, NGRBMN2T6, IG, 12, 0, 0, 1, LLF, LLT, 'MIN.TEMP.LAST 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MSLD, NGRBMSL, IG, 12, 0, 0, 1, LLF, LLT, 'MSL             ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SP, NGRBSP, IG, 12, 0, 0, 1, LLF, LLT, 'SURFACE PRESSURE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MX2T, NGRBMX2T, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.TEMP.       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MX2T3, NGRBMX2T3, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.TEMP.LAST 3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MX2T6, NGRBMX2T6, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.TEMP.LAST 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MNTPR, NGRBMNTPR, IG, 12, 0, 0, 1, LLF, LLT, 'MIN.TOT.PRECIP. ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MNTPR3, NGRBMNTPR3, IG, 12, 0, 0, 1, LLF, LLT, 'MIN.TOT.PREC. 3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MNTPR6, NGRBMNTPR6, IG, 12, 0, 0, 1, LLF, LLT, 'MIN.TOT.PREC. 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXTPR, NGRBMXTPR, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.TOT.PRECIP. ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXTPR3, NGRBMXTPR3, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.TOT.PREC. 3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXTPR6, NGRBMXTPR6, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.TOT.PREC. 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TPR, NGRBTPR, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.PREC.RATE   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSRR, NGRBLSRR, IG, 12, 0, 0, 1, LLF, LLT, 'LS RAINRATE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CRR, NGRBCRR, IG, 12, 0, 0, 1, LLF, LLT, 'CV RAINRATE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSSFR, NGRBLSSFR, IG, 12, 0, 0, 1, LLF, LLT, 'LS SNOWRATE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSFR, NGRBCSFR, IG, 12, 0, 0, 1, LLF, LLT, 'CV SNOWRATE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPE, NGRBPTYPE, IG, 12, 0, 0, 1, LLF, LLT, 'PRECIP TYPE     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ILSPF, NGRBILSPF, IG, 12, 0, 0, 1, LLF, LLT, 'LS PREC.FRAC.INS', CL)
      call initialize_physical_descriptor(YDAFN%GFP%NSSS, NGRBNSSS, IG, 12, 0, 0, 1, LLF, LLT, 'V-STRESS        ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PADOU, -9999, IG, 12, +1, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', 'DIR')
      call initialize_physical_descriptor(YDAFN%GFP%PADOV, -9999, IG, 12, -1, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', 'DIR')
      call initialize_physical_descriptor(YDAFN%GFP%PCAAG, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PCAPG, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PSRHU, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PURB, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PVGMX, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RDST, NGRBVDZW, IG, 12, 0, 0, 1, LLF, LLT, 'INTSURFTEMPERATU', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RDSW, NGRBDHCC, IG, 12, 0, 0, 1, LLF, LLT, 'RELAPROP.RMAX.EA', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RO, NGRBRO, IG, 12, 0, 0, 1, LLF, LLT, 'TOTAL RUNOFF    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SRO, NGRBSRO, IG, 12, 0, 0, 1, LLF, LLT, 'SURFACE RUNOFF  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRO, NGRBSSRO, IG, 12, 0, 0, 1, LLF, LLT, 'SUB-SURF. RUNOFF', CL)
      call initialize_physical_descriptor(YDAFN%GFP%NEE, codes%ngrbnee, IG, 12, 0, 0, 1, LLF, LLT, 'NET-CO2 NEE     ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%GPP, codes%ngrbgpp, IG, 12, 0, 0, 1, LLF, LLT, 'GROSS-CO2 GPP   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%REC, codes%ngrbrec, IG, 12, 0, 0, 1, LLF, LLT, 'RESP.-CO2 RECO  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INEE, codes%ngrbinee, IG, 12, 0, 0, 1, LLF, LLT, 'INST.NET-CO2 NEE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IGPP, codes%ngrbigpp, IG, 12, 0, 0, 1, LLF, LLT, 'INST.G.-CO2 GPP ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IREC, codes%ngrbirec, IG, 12, 0, 0, 1, LLF, LLT, 'INST.R.-CO2 RECO', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ICH4, NGRBCH4WET, IG, 12, 0, 0, 1, LLF, LLT, 'WETLAND CH4 FLUX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RSMIN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFRESI.STO.MIN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SNDE, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFDENSIT.NEIGE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SAB, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.SABLE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SDOG, NGRBSDOR, IG, 12, 0, 0, 0, LLF, LLT, 'SURFET.GEOPOTENT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SF, NGRBSF, IG, 12, 0, 0, 1, LLF, LLT, 'SNOWFALL        ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SFIS, -9999, IA, 12, 0, 0, 0, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SKT, NGRBSKT, IG, 12, 0, 0, 1, LLF, LLT, 'SKINTEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SLHF, NGRBSLHF, IG, 12, 0, 0, 1, LLF, LLT, 'S.L.HEAT.FLUX.  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SLOR, NGRBSLOR, IG, 12, 0, 0, 1, LLF, LLT, 'SLOPE.SUB.SOROG ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SMLT, NGRBSMLT, IG, 12, 0, 0, 1, LLF, LLT, 'SNOW MELT       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SOTY, NGRBSLT, IG, 12, 0, 0, 1, LLF, LLT, 'SOIL TYPE       ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CLK, NGRBCL, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE COVER      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DL, codes%ngrbdl, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE DEPTH      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LMLT, codes%ngrblmlt, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE MIX-LAYER T', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LMLD, codes%ngrblmld, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE MIX-LAYER D', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LBLT, codes%ngrblblt, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE BOTTOM T   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LTLT, codes%ngrbltlt, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE TOTAL T    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSHF, codes%ngrblshf, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE SHAPE FACT.', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICT, codes%ngrblict, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE ICE TEMP   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICD, codes%ngrblicd, IG, 12, 0, 0, 1, LLF, LLT, 'LAKE ICE DEPTH  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SR, NGRBSR, IA, 12, 0, 0, 1, LLF, LLT, 'SURFZ0.FOIS.G   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SRC, NGRBSRC, IG, 12, 0, 0, 1, LLF, LLT, 'SKINRESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSHF, NGRBSSHF, IG, 12, 0, 0, 1, LLF, LLT, 'S.S.HEAT.FLUX.  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSR, NGRBSSR, IG, 12, 0, 0, 1, LLF, LLT, 'S.SOLAR.RAD.    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRC, NGRBSSRC, IG, 12, 0, 0, 1, LLF, LLT, 'SURF SOLAR CLEAR', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRD, NGRBSSRD, IG, 12, 0, 0, 1, LLF, LLT, 'S.SOLAR.RAD.DOWN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRDC, NGRBSSRDC, IG, 12, 0, 0, 1, LLF, LLT, 'S.CLR SW.RAD.DWN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SST, NGRBSSTK, IG, 12, 0, 0, 1, LLF, LLT, 'SEA SURF. TEMP. ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSW, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'SURFRESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ST, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'SURFTEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%UCUR, NGRBUCUR, IG, 12, 0, 0, 1, LLF, LLT, 'U-OCEAN CURRENT ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%VCUR, NGRBVCUR, IG, 12, 0, 0, 1, LLF, LLT, 'V-OCEAN CURRENT ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL1, NGRBSTL1, IG, 12, 0, 0, 1, LLF, LLT, 'LEV1TEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL2, NGRBSTL2, IG, 12, 0, 0, 1, LLF, LLT, 'LEV2TEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL3, NGRBSTL3, IG, 12, 0, 0, 1, LLF, LLT, 'LEV3TEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL4, NGRBSTL4, IG, 12, 0, 0, 1, LLF, LLT, 'LEV4TEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STR, NGRBSTR, IG, 12, 0, 0, 1, LLF, LLT, 'S.THERMAL.RAD.  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STRC, NGRBSTRC, IG, 12, 0, 0, 1, LLF, LLT, 'SURF THERM CLEAR', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STRD, NGRBSTRD, IG, 12, 0, 0, 1, LLF, LLT, 'S.THERM.RAD.DOWN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STRDC, NGRBSTRDC, IG, 12, 0, 0, 1, LLF, LLT, 'S.CLR LW.RAD.DWN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SUND, NGRBSUND, IG, 12, 0, 0, 1, LLF, LLT, 'SUNSHI. DURATION', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL1, NGRBSWVL1, IG, 12, 0, 0, 1, LLF, LLT, 'LEV1RESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL2, NGRBSWVL2, IG, 12, 0, 0, 1, LLF, LLT, 'LEV2RESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL3, NGRBSWVL3, IG, 12, 0, 0, 1, LLF, LLT, 'LEV3RESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL4, NGRBSWVL4, IG, 12, 0, 0, 1, LLF, LLT, 'LEV4RESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCC, NGRBTCC, IG, 12, 0, 0, 1, LLF, LLT, 'TOTAL.CC        ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCO3, NGRBTCO3, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.OZON    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SD, NGRBSD, IG, 12, 0, 1, 1, LLF, LLT, 'SURFRESERV.NEIGE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SDSL, NGRBSDSL, IG, 12, 0, 1, 1, LLF, LLT, 'SURFRESERV.NEIGE.TOT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TSN, NGRBTSN, IG, 12, 0, 0, 1, LLF, LLT, 'TEMP.SNOWLAYER  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RSN, NGRBRSN, IG, 12, 0, 0, 1, LLF, LLT, 'SNOW DENSITY    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%WSN, NGRBWSN, IG, 12, 0, 1, 1, LLF, LLT, 'Liquid Water snow', CL)
      DO JGFL = 1, JPOSGHG
      IF (JGFL <= NGHG) THEN
        CLGHG = 'TOT.COL.GHG  '//TRIM(YGHG(JGFL)%CNAME)
        call initialize_physical_descriptor(YDAFN%GFP%TCGHG(JGFL), codes%ngrbtcghg(JGFL), IG, 12, 0, 0, 1, LLF, LLT, CLGHG, CL)
      END IF
      END DO
      DO JGFL = 1, JPOSCHEM
      IF (JGFL <= NCHEM) THEN
      IF (YCHEM(JGFL)%IGRIBTC > 0) THEN
        CLCHEM = 'TC.CHEM '//TRIM(YCHEM(JGFL)%CNAME)
        call initialize_physical_descriptor(YDAFN%GFP%TCCHEM(JGFL), YCHEM(JGFL)%IGRIBTC, IG, 12, 0, 0, 1, LLF, LLT, CLCHEM, CL)
      END IF
      END IF
      END DO
      IVAR = 0
      DO JGFL = 1, JPOSCHEM
      IF (JGFL <= NCHEM) THEN
      IF (YCHEM(JGFL)%IGRBFLXO > 0) THEN
      IF (IVAR < JPOSCHEMFLX) THEN
        IVAR = IVAR + 1
        CLCHEM = 'FLXO.CHEM '//TRIM(YCHEM(JGFL)%CNAME)
        call initialize_physical_descriptor(YDAFN%GFP%CHEMFLXO(IVAR), YCHEM(JGFL)%IGRBFLXO, IG, 12, 0, 0, 1, LLF, LLT, CLCHEM, CL)
      ELSE
        CALL ABOR1('SUAFN1: NCHEM_FLXO exceeded JPOSCHEMFLX')
      END IF
      END IF
      END IF
      END DO
      IVAR = 0
      DO JGFL = 1, JPOSCHEM
      IF (JGFL <= NCHEM) THEN
      IF (YCHEM(JGFL)%IGRBWDFLX > 0) THEN
      IF (IVAR < JPOSCHEMFLX) THEN
        IVAR = IVAR + 1
        CLCHEM = 'WDFLX.CHEM '//TRIM(YCHEM(JGFL)%CNAME)
        call initialize_physical_descriptor(YDAFN%GFP%CHEMWDFLX(IVAR), YCHEM(JGFL)%IGRBWDFLX, IG, 12, 0, 0, 1, LLF, LLT, CLCHEM, CL)
      ELSE
        CALL ABOR1('SUAFN1: NCHEM_WDFLX exceeded JPOSCHEMFLX')
      END IF
      END IF
      END IF
      END DO
      IVAR = 0
      DO JGFL = 1, JPOSCHEM
      IF (JGFL <= NCHEM) THEN
      IF (YCHEM(JGFL)%IGRBDDFLX > 0) THEN
      IF (IVAR < JPOSCHEMFLX) THEN
        IVAR = IVAR + 1
        CLCHEM = 'DDFLX.CHEM '//TRIM(YCHEM(JGFL)%CNAME)
        call initialize_physical_descriptor(YDAFN%GFP%CHEMDDFLX(IVAR), YCHEM(JGFL)%IGRBDDFLX, IG, 12, 0, 0, 1, LLF, LLT, CLCHEM, CL)
      ELSE
        CALL ABOR1('SUAFN1: NCHEM_DDFLX exceeded JPOSCHEMFLX')
      END IF
      END IF
      END IF
      END DO
      IF (PRESENT(YDEAERATM)) THEN
      DO JDIAG = 1, MIN(NPAERODIAG, JPOSAERODIAG)
      DO JGFL = 1, MIN(JPOSAERO, NACTAERO)
        CLAERO = YAERO(JGFL)%CNAME
        JSTRLEN = LEN(TRIM(CLAERO))
        JSTRINDEX = INDEX(CLAERO, '_', BACK=.TRUE.)
        IF (JSTRLEN > 8 .AND. JSTRINDEX > 0) THEN
          CLAERO = CLAERO(1:MIN(JSTRINDEX - 1, 7 + JSTRINDEX - LEN(TRIM(CLAERO))))//CLAERO(JSTRINDEX:LEN(TRIM(CLAERO)))
        END IF
        CLAERO = TRIM(CPAERODIAG_LABEL(JDIAG))//'AERO '//TRIM(CLAERO)
call initialize_physical_descriptor(YDAFN%GFP%AERODIAG(JGFL,JDIAG),YDEAERATM%YAERO_DESC(JGFL)%IGRIBDIAG(JDIAG),IG,12,0,0,1,LLF,LLT,CLAERO,CL)
      END DO
      END DO
      END IF
      DO JDIAG = 1, MIN(NAERO_WVL_DIAG_TYPES, JPOSAERO_WVL_DIAG_TYPES)
      DO JGFL = 1, MIN(JPOSAERO_WVL_DIAG, NAERO_WVL_DIAG)
      IF (JDIAG == JPAERO_WVL_AOD .AND. YAERO_WVL_DIAG_NL(JGFL)%IWVL == 550) THEN
        CLAERO = 'OptDepthTotalAer'
      ELSE
        WRITE (CLAERO, '(I5)') YAERO_WVL_DIAG_NL(JGFL)%IWVL
        CLAERO = TRIM(CPAERO_WVL_DIAG_LABEL(JDIAG))//' @ '//TRIM(CLAERO)
      END IF
call initialize_physical_descriptor(YDAFN%GFP%AERO_WVL_DIAG(JGFL,JDIAG),YAERO_WVL_DIAG_NL(JGFL)%IGRIBDIAG(JDIAG),IG,12,0,0,1,LLF,LLT,CLAERO,CL)
      END DO
      END DO
      IF (PRESENT(YDCOMPO)) THEN
      DO JGFL = 1, MIN(JPOSEMIS2D, NEMIS2D)
      DO JEMIS = 1, YDCOMPO%NEMIS2D_DESC
      IF (YDCOMPO%YEMIS2D_DESC(JEMIS)%PARAM_INDEX == JGFL) THEN
        CLFA = 'EM2D '//TRIM(YDCOMPO%YEMIS2D_DESC(JEMIS)%SPECIES)//' '//YDCOMPO%YEMIS2D_DESC(JEMIS)%SECTOR
        call initialize_physical_descriptor(YDAFN%GFP%EMIS2D(JGFL),YDCOMPO%YEMIS2D_DESC(JEMIS)%PARAMID,IG,12,0,0,1,LLF,LLT,CLFA,CL)
        EXIT
      END IF
      END DO
      END DO
      DO JGFL = 1, MIN(JPOSEMIS2DAUX, NEMIS2DAUX)
        CLFA = YDCOMPO%YEMIS2DAUX_DESC(JGFL)%CNAME
    call initialize_physical_descriptor(YDAFN%GFP%EMIS2DAUX(JGFL),YDCOMPO%YEMIS2DAUX_DESC(JGFL)%PARAMID,IG,12,0,0,1,LLF,LLT,CLFA,CL)
      END DO
      END IF
      call initialize_physical_descriptor(YDAFN%GFP%VIWVE, NGRBVIWVE, IG, 12, 0, 0, 1, LLF, LLT, 'EST.WAT.VAPO.FLX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%VIWVN, NGRBVIWVN, IG, 12, 0, 0, 1, LLF, LLT, 'NRT.WAT.VAPO.FLX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCW, NGRBTCW, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.WATER   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCWV, NGRBTCWV, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.WATVAPOU', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCLW, NGRBTCLW, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.LIQ.WAT ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCIW, NGRBTCIW, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.ICE.WAT ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCRW, NGRBTCRW, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.RAIN.WAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCSW, NGRBTCSW, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.SNOW.WAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCSLW, NGRBTCSLW, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.COL.SLIQ.WAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TP, NGRBTP, IG, 12, 0, 0, 1, LLF, LLT, 'TOTAL.PRECIP.   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TSR, NGRBTSR, IG, 12, 0, 0, 1, LLF, LLT, 'T.SOLAR.RAD.    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TSRC, NGRBTSRC, IG, 12, 0, 0, 1, LLF, LLT, 'TOP SOLAR  CLEAR', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TTR, NGRBTTR, IG, 12, 0, 0, 1, LLF, LLT, 'T.THERMAL.RAD.  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TTRC, NGRBTTRC, IG, 12, 0, 0, 1, LLF, LLT, 'TOP THERMALCLEAR', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TVH, NGRBTVH, IG, 12, 0, 0, 1, LLF, LLT, 'HIG VEG. TYPE   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TVL, NGRBTVL, IG, 12, 0, 0, 1, LLF, LLT, 'LOW VEG. TYPE   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%VEG, NGRBVEG, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.VEGETAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%VIMD, NGRBVIMD, IG, 12, 0, 0, 1, LLF, LLT, 'VertIntegMassDiv', CL)
      call initialize_physical_descriptor(YDAFN%GFP%VISIH, NGRBVISIH, IG, 12, 0, 0, 1, LLF, LLT, 'HORIZ.VISIBILITY', CL)
      call initialize_physical_descriptor(YDAFN%GFP%Z0F, NGRBFSR, IA, 12, 0, 0, 1, LLF, LLT, 'SURF.ROUGHNESS  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%Z0H, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'SURFGZ0.THERM   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%Z0V, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'XXXXXXXXXXXXXXXX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC0DEGL, NGRB0DEGL, IG, 12, 0, 0, 1, LLF, LLT, 'ZERO DEG. LEVEL ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ECM10DEGL, NGRBM10DEGL, IG, 12, 0, 0, 1, LLF, LLT, '-10  DEG. LEVEL ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CIN, NGRBCIN, IG, 12, 0, 0, 1, LLF, LLT, 'CIN             ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCIN50, NGRBMLCIN50, IG, 12, 0, 0, 1, LLF, LLT, 'ML CIN 50HPA    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCIN100, NGRBMLCIN100, IG, 12, 0, 0, 1, LLF, LLT, 'ML CIN 100HPA   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%KINDEX, NGRBKINDEX, IG, 12, 0, 0, 1, LLF, LLT, 'CONV. K INDEX   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TTINDEX, NGRBTTINDEX, IG, 12, 0, 0, 1, LLF, LLT, 'CONV. TT INDEX  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CBASEA, NGRBCBASEA, IG, 12, 0, 0, 1, LLF, LLT, 'CEILING CLD BASE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CTOPC, NGRBCTOPC, IG, 12, 0, 0, 1, LLF, LLT, 'CLOUD TOPLEV CUM', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ZTWETB0, NGRBZTWETB0, IG, 12, 0, 0, 1, LLF, LLT, '0 DEG WETB-T LEV', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ZTWETB1, NGRBZTWETB1, IG, 12, 0, 0, 1, LLF, LLT, '1 DEG WETB-T LEV', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASEA, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.SEA   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALAN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.LAND  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASOO, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.SOOT  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ADES, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.DESERT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASUL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.SULFAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AVOL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.VOLCAN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%O3A, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFA.OF.OZONE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%O3B, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFB.OF.OZONE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%O3C, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFC.OF.OZONE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SPAR, NGRBPAR, IG, 12, 0, 0, 1, LLF, LLT, 'PHOTO.ACTIVE.RAD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SUVB, NGRBUVB, IG, 12, 0, 0, 1, LLF, LLT, 'UV-B RADIATION  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CAPE, NGRBCAPE, IG, 12, 0, 0, 1, LLF, LLT, 'CONV.AV.POT.ENER', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MUCAPE, NGRBMUCAPE, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.UNSTABL.CAPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCAPE50, NGRBMLCAPE50, IG, 12, 0, 0, 1, LLF, LLT, 'MIX.LAYER50 CAPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCAPE100, NGRBMLCAPE100, IG, 12, 0, 0, 1, LLF, LLT, 'MIXLAYER100 CAPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PDEPL, NGRBMUDEPL, IG, 12, 0, 0, 1, LLF, LLT, 'DEPPRES MUCAPE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CAPES, NGRBCAPES, IG, 12, 0, 0, 1, LLF, LLT, 'CAPE-SHEAR      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXCAP6, NGRBMXCAP6, IG, 12, 0, 0, 1, LLF, LLT, 'MAX CAPE LAST 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXCAPS6, NGRBMXCAPS6, IG, 12, 0, 0, 1, LLF, LLT, 'MAX CAPESHEAR 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TROPOTP, NGRBTROPOTP, IG, 12, 0, 0, 1, LLF, LLT, 'PRES.THER.TROPOP', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SPARC, NGRBPARCS, IG, 12, 0, 0, 1, LLF, LLT, 'C-S PHOT.ACT.RAD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STINC, NGRBTISR, IG, 12, 0, 0, 1, LLF, LLT, 'TOA INC.SOL. RAD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SFDIR, NGRBFDIR, IG, 12, 0, 0, 1, LLF, LLT, 'SUR.TOT-SKY DIRD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SCDIR, NGRBCDIR, IG, 12, 0, 0, 1, LLF, LLT, 'SUR.CLR-SKY DIRD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DNDZN, NGRBDNDZN, IG, 12, 0, 0, 1, LLF, LLT, 'Min Refrac Grad ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DNDZA, NGRBDNDZA, IG, 12, 0, 0, 1, LLF, LLT, 'Mean Refrac Grad', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DCTB, NGRBDCTB, IG, 12, 0, 0, 1, LLF, LLT, 'Duct Base Height', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TPLB, NGRBTPLB, IG, 12, 0, 0, 1, LLF, LLT, 'Trap Layer Base ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TPLT, NGRBTPLT, IG, 12, 0, 0, 1, LLF, LLT, 'Trap Layer Top  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTI, NGRBLITOTI, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.INST', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTA1, NGRBLITOTA1, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.AVG1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTA3, NGRBLITOTA3, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.AVG3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTA6, NGRBLITOTA6, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.AVG6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGI, NGRBLICGI, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.INST ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGA1, NGRBLICGA1, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.AVG 1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGA3, NGRBLICGA3, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.AVG 3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGA6, NGRBLICGA6, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.AVG 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPEMODE1, NGRBPTYPEMODE1, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE MODE    1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPEMODE3, NGRBPTYPEMODE3, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE MODE    3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPEMODE6, NGRBPTYPEMODE6, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE MODE    6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPESEVR1, NGRBPTYPESEVR1, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE SEVERE  1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPESEVR3, NGRBPTYPESEVR3, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE SEVERE  3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPESEVR6, NGRBPTYPESEVR6, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE SEVERE  6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SDSRP, NGRBDSRP, IG, 12, 0, 0, 1, LLF, LLT, 'SF.TOT-SKY DIRDP', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CLBT, NGRBCLBT, IG, 12, 0, 0, 0, LLF, LLT, 'Cloud BrightTemp', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSBT, NGRBCSBT, IG, 12, 0, 0, 0, LLF, LLT, 'Clear BrightTemp', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ICTH, NGRBICETK, IG, 12, 0, 0, 1, LLF, LLT, 'Ice thickness  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLD, NGRBMLD, IG, 12, 0, 0, 1, LLF, LLT, 'Mixed Layer Dep', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSH, NGRBSL, IG, 12, 0, 0, 1, LLF, LLT, 'Sea Surf Height', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC20D, NGRB20D, IG, 12, 0, 0, 1, LLF, LLT, '20degC depth   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSS, NGRBSSSO, IG, 12, 0, 0, 1, LLF, LLT, 'Sea Surf Salini', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TEM3, NGRBTEM300, IG, 12, 0, 0, 1, LLF, LLT, 'Ptem avg 300m  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SAL3, NGRBSAL300, IG, 12, 0, 0, 1, LLF, LLT, 'Sali avg 300m  ', CL)
      DO JVAR = 1, JPOSVX2
        IGRIB = NGRBMINXTRA + JVAR - 1
        IF (IGRIB <= NGRBMAXXTRA) THEN
          WRITE (CLFA, '(''SURFEXTRAFIELD'',I2.2)') JVAR
          call initialize_physical_descriptor(YDAFN%GFP%VX2(JVAR), IGRIB, IG, 12, 0, 0, 1, LLF, LLT, CLFA, CL)
        ELSE
          CLFA = 'XXXXXXXXXXXXXXXX'
          call initialize_physical_descriptor(YDAFN%GFP%VX2(JVAR), -9999, IG, 12, 0, 0, 1, LLF, LLT, CLFA, CL)
        END IF
      END DO
      DO JVAR = 1, JPOSFSU
        WRITE (CLFA, '(''SURFFREE.FIELD'',I2.2)') JVAR
        call initialize_physical_descriptor(YDAFN%GFP%FSU(JVAR), -9999, IG, 12, 0, 0, 1, LLF, LLT, CLFA, CL)
      END DO
    ELSE
      call initialize_dynamic_descriptor(YDAFN%TFP%U, LLF, 'VENT_ZONAL      ', -99999, IS, IG, 12, LLF, I1, ZK, +1, 'ATM')
      call initialize_dynamic_descriptor(YDAFN%TFP%V, LLF, 'VENT_MERIDIE    ', -99999, IS, IG, 12, LLF, I1, ZK, -1, 'ATM')
     call initialize_dynamic_descriptor(YDAFN%TFP%KHI, LLF, file_metadata%YFAKHI%CLNAME, -99999, IS, IG, 12, LLF, I1, Z0, 0, 'VPSF')
     call initialize_dynamic_descriptor(YDAFN%TFP%PSI, LLF, file_metadata%YFAPSI%CLNAME, -99999, IS, IG, 12, LLF, I1, ZK, 0, 'VPSF')
      call initialize_dynamic_descriptor(YDAFN%TFP%T, LLF, file_metadata%YFAT%CLNAME, -99999, IS, IG, 12, LLF, NSPFILI, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%Z, LLF, 'GEOPOTENTIEL    ', -99999, IS, IG, 12, LLF, I2, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%WND, LLF, 'WIND_VELOCIT    ', -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HU, LLF, 'HUMI_RELATIV    ', -99999, IS, IG, 12, LLF, I2, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TH, LLF, 'TEMPE_POTENT    ', -99999, IS, IG, 12, LLF, NSPFILT, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%THPW, LLF, 'THETA_PRIM_W    ', -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TPW, LLF, 'TPRIM_W         ', -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ETH, LLF, 'THETA_EQUIVA    ', -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%IET, LLF, 'VIRT_P_TEMPE    ', -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SRE, LLF, 'SIM_REFLECTI    ', -99999, IS, IG, 12, LLF, I2, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SREDB, LLF, 'REFLEC_DBZ     ', -99999, IS, IG, 12, LLF, I2, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%THV, LLF, 'THETA_VIRTUA    ', -99999, IS, IG, 12, LLF, I2, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%P, LLF, 'PRESSURE        ', -99999, IS, IG, 12, LLF, NSPFILP, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PD, LLF, file_metadata%YFAPD%CLNAME, NGRB118, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VD, LLF, file_metadata%YFAVD%CLNAME, NGRB119, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MG, LLF, 'MONTGOMERY G    ', -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VW, LLF, 'VERT.VELOCIT    ', NGRB120, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PV, LLF, 'POT_VORTICIT    ', -99999, IS, IG, 12, LLF, NSPFILV, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VV, LLF, 'VITESSE_VERT    ', -99999, IS, IG, 12, LLF, I3, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ETAD, LLF, 'ETADOT          ', -99999, IS, IG, 12, LLF, I3, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%STD, LLF, 'STRET_DEFORM    ', -99999, IS, IG, 12, LLF, I3, ZK, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SHD, LLF, 'SHEAR_DEFORM    ', -99999, IS, IG, 12, LLF, I3, ZK, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ABS, LLF, 'ABS_VORTICIT    ', -99999, IS, IG, 12, LLF, I3, ZK, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VOR, LLF, 'VORTICITY       ', -99999, IS, IG, 12, LLF, I3, ZK, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%DIV, LLF, 'DIVERGENCE      ', -99999, IS, IG, 12, LLF, I3, ZK, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PTB, LLF, 'ISOT_PRESS      ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTB, LLF, 'ISOT_ALTIT      ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%RHO, LLF, 'HUMID_DENSIT    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%EDR, LLF, 'EDR             ', 136, IS, IG, 12, LLT, I1, Z0, 0, CL)
      DO JVAR = 1, JPOSVX2
        WRITE (CLFA, '(''UPPER_AIR.'',I2.2,''    '')') JVAR
        call initialize_dynamic_descriptor(YDAFN%TFP%FUA(JVAR), LLF, CLFA, -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      END DO
      IF (controls%KFPCONF /= 1) THEN
        call initialize_dynamic_descriptor(YDAFN%TFP%SP, LLT, 'AGAIN.SURF.PRESS', -99999, IS, IG, 12, LLGP_SP, I1, ZK, 0, CL)
     call initialize_dynamic_descriptor(YDAFN%TFP%LNSP, LLT, file_metadata%YFASP%CLNAME, -99999, IS, IG, 12, LLGP_SP, I1, ZK, 0, CL)
      ELSE
       call initialize_dynamic_descriptor(YDAFN%TFP%SP, LLT, file_metadata%YFASP%CLNAME, -99999, IS, IG, 12, LLGP_SP, I1, ZK, 0, CL)
        call initialize_dynamic_descriptor(YDAFN%TFP%LNSP, LLT, 'LOG.SURF.PRESSIO', -99999, IS, IG, 12, LLGP_SP, I1, ZK, 0, CL)
      END IF
      call initialize_dynamic_descriptor(YDAFN%TFP%MSL, LLT, 'MSLPRESSURE     ', -99999, IS, IG, 12, LLF, I2, ZK, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF1, LLT, file_metadata%YFAFSP1%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF2, LLT, file_metadata%YFAFSP2%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF3, LLT, file_metadata%YFAFSP3%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF4, LLT, file_metadata%YFAFSP4%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
   call initialize_dynamic_descriptor(YDAFN%TFP%CUF5, LLT, file_metadata%YFAFSP5%CLNAME, -99999, IS, IG, 12, LLGP_SP, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FIS, LLT, file_metadata%YFAOROG%CLNAME, -99999, IA, IA, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%WWS, LLT, 'SURFVERT.VELOCIT', -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PJET, LLT, 'JETPRESSURE     ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TCAO, LLT, 'ICAOTROP.TEMPERA', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%PCAO, LLT, 'ICAOTROP.PRESSUR', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTPW, LLT, 'SURFISOTPW0.MALT', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTPW1, LLT, 'SURFISOTPW1.MALT', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HTPW2, LLT, 'SURFISOTPW2.MALT', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%GM, LLT, 'MAP_FACTOR      ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FOL, LLT, 'TROPO_FOLD_INDIC', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%UCLS, LLT, 'CLSVENT_ZONA.POS', -99999, IS, IG, 12, LLT, I0, Z0, +1, 'CLS')
      call initialize_dynamic_descriptor(YDAFN%TFP%VCLS, LLT, 'CLSVENT_MERI.POS', -99999, IS, IG, 12, LLT, I0, Z0, -1, 'CLS')
      call initialize_dynamic_descriptor(YDAFN%TFP%TCLS, LLT, 'CLSTEMPERATU.POS', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%QCLS, LLT, 'CLSHU.SPECIF.POS', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%RCLS, LLT, 'CLSHU.RELATI.POS', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FCLS, LLT, 'CLSWIND_VELO.POS', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SREX, LLT, 'SURFREFLECT.MAX ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SREDBX, LLT, 'REFLECT_DBZ.MAX ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TOPR, LLT, 'ECHOTOP         ', -99999, IS, IG, 0, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MOCO, LLT, 'CLPMOCON.POS    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%TWV, LLT, 'SURFTOT.WAT.VAPO', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%UGST, LLT, 'CLSURAFALES.POS ', -99999, IS, IG, 12, LLT, I0, Z0, +1, 'GST')
      call initialize_dynamic_descriptor(YDAFN%TFP%VGST, LLT, 'CLSVRAFALES.POS ', -99999, IS, IG, 12, LLT, I0, Z0, -1, 'GST')
      call initialize_dynamic_descriptor(YDAFN%TFP%FGST, LLT, 'CLSRAFALES.POS  ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%HCLP, LLT, 'CLPMHAUT.POS    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VEIN, LLT, 'CLPVEIND.POS    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SMC, LLT, 'SURFMOCON.POS   ', -99999, IS, IG, 12, LLF, NSPFIL2, ZK, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%ASMC, LLT, 'SURFANAMOCON.POS', -99999, IS, IG, 12, LLF, NSPFIL2, ZK, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%VSMC, LLT, file_metadata%YFA_VSMC%CLNAME, -99999, IS, IG, 12, LLF, I1, Z0, 2, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%QNH, LLT, 'QNHPRESSURE     ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MSK, LLT, 'GEOMASK.FPOS    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%MSLNH, LLT, 'MSL_NHPRESSURE  ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%SPNH, LLT, 'SUR_NHPRESSURE  ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%LCL, LLT, 'SURFLIFTCONDLEV ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%FCL, LLT, 'SURFFREECONVLEV ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%EL, LLT, 'SURFEQUILIBRLEV ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      DO JVAR = 1, JPOSFSU
        WRITE (CLFA, '(''SURF2D.'',I2.2,''       '')') JVAR
        call initialize_dynamic_descriptor(YDAFN%TFP%FSU(JVAR), LLT, CLFA, -99999, IS, IG, 12, LLF, I1, ZK, 0, CL)
      END DO
      call initialize_dynamic_descriptor(YDAFN%TFP%UJET, LLT, 'JETVENT_ZONAL   ', -99999, IS, IG, 12, LLT, I0, Z0, +1, 'JET')
      call initialize_dynamic_descriptor(YDAFN%TFP%VJET, LLT, 'JETVENT_MERIDIEN', -99999, IS, IG, 12, LLT, I0, Z0, -1, 'JET')
      call initialize_dynamic_descriptor(YDAFN%TFP%SRH, LLT, 'STORMRELHELICITY', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%STRMMU, LLT, 'STORMMOTIONU    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_dynamic_descriptor(YDAFN%TFP%STRMMV, LLT, 'STORMMOTIONV    ', -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SDFOR, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SD FILTERED OROG', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CGPP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CREC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10FG, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10FG3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10FG6, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%I10FG, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10U, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10V, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10SI, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC100U, -9999, IG, 12, 0, 0, 1, LLF, LLT, '100M.UWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC100V, -9999, IG, 12, 0, 0, 1, LLF, LLT, '100M.VWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC100SI, -9999, IG, 12, 0, 0, 1, LLF, LLT, '100M.WIND.SPEED ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC200U, -9999, IG, 12, 0, 0, 1, LLF, LLT, '200M.UWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC200V, -9999, IG, 12, 0, 0, 1, LLF, LLT, '200M.VWIND      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC200SI, -9999, IG, 12, 0, 0, 1, LLF, LLT, '200M.WIND.SPEED ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ZUST, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'FRICT. VELOCITY ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10NU, -9999, IG, 12, 0, 0, 1, LLF, LLT, '10M.NEUTRL UWIND', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC10NV, -9999, IG, 12, 0, 0, 1, LLF, LLT, '10M.NEUTRL VWIND', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC2D, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC2SH, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC2T, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ACOT, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFVAR.GEOP.ANI', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALB, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALS, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO.SOLNU', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALSN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO NEIGE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNIP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNID, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVI, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNII, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVV, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNIV, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALUVG, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALNIG, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%AERDEP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%AERLTS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%AERSCC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%DSF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%DSZ, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SO2DD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%DMSO, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%URBF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%FCA1, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CalciteFraction1', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FCA2, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CalciteFraction2', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODSS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODDU, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODOM, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODBC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODSU, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODNI, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODAM, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODSOA, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODVFA, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODVSU, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ODTOACC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%AEPM1, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%AEPM25, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%AEPM10, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%UVBED, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%UVBEDCS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALV, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO.VEG  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ANOR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ARG, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.ARGILE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASN, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%BAAL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO.COMPL', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALBHIS, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFALBEDO HISTO', CL)
      call initialize_physical_descriptor(YDAFN%GFP%BLD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%BLH, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%BSR, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'SURFZ0REL.FOIS.G', CL)
      call initialize_physical_descriptor(YDAFN%GFP%BV, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CBASE, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CCC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CDSW, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PROFPROP.RMAX.EA', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CHAR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CI, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSSW, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.RMAX.EA', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CVH, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CVL, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CUR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CO2TYP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%FWET, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAIL, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAIH, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%D2, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFEPAIS.SOL   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%D2MX, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFEPAI.SOL.MAX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DPAT, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFVAR.GEOP.DIR', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DST, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'PROFTEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DSW, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'PROFRESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%E, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%PEV, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EMIS, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFEMISSIVITE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ES, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%EWSS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%FDSW, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'PROFRESERV.GLACE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FSSW, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'SURFRESERV.GLACE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%FZRA, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%GFIS, -9999, IA, 12, 0, 0, 0, LLF, LLT, 'SURFGEOPOTENTIEL', CL)
      call initialize_physical_descriptor(YDAFN%GFP%GWD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%HCC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%HV, -9999, IG, 12, 0, 0, 1, LLT, LLT, 'SURFRES.EVAPOTRA', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IC, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFRESERV.INTER', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IDZ0, -9999, IA, 12, 0, 0, 1, LLT, LLT, 'INTSURFZ0.FOIS.G', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IE, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%IEWSS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCHN, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.HN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCHX, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.HX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCTN, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.TN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INCTX, -9999, IG, 0, 0, 0, 1, LLF, LLT, 'SURFINCREMENT.TX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%INSSS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISOR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISSHF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL1, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL2, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ISTL4, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ITZ0, -9999, IA, 12, 0, 0, 1, LLT, LLT, 'INTSURFGZ0.THERM', CL)
      call initialize_physical_descriptor(YDAFN%GFP%IVEG, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFIND.VEG.DOMI', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAI, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFIND.FOLIAIRE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LAN, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'SURFPROP.TERRE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LCC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LGWS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSM, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'SURFIND.TERREMER', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSPF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSRH, -9999, IA, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LZ0H, -9999, IA, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MCC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MGWS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MN2T, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MN2T3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MN2T6, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MSLD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SP, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFACE PRESSURE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MX2T, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MX2T3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MX2T6, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MNTPR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MNTPR3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MNTPR6, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXTPR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXTPR3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXTPR6, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TPR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSRR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CRR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSSFR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSFR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPE, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ILSPF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%NSSS, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%PADOU, -9999, IG, 12, +1, 0, 1, LLF, LLT, 'SURF.U.ANISO.DIR', 'DIR')
      call initialize_physical_descriptor(YDAFN%GFP%PADOV, -9999, IG, 12, -1, 0, 1, LLF, LLT, 'SURF.V.ANISO.DIR', 'DIR')
      call initialize_physical_descriptor(YDAFN%GFP%PCAAG, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'SURFETA.GEOPOTEN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PCAPG, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'SURFETP.GEOPOTEN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PSRHU, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFHUMI.RELATIV', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PURB, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.URBANIS', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PVGMX, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.VEG.MAX', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RDST, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'INTSURFTEMPERATU', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RDSW, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'RELAPROP.RMAX.EA', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RO, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SRO, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRO, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%NEE, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%GPP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%REC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%INEE, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%IGPP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%IREC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ICH4, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%RSMIN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFRESI.STO.MIN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%RSN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SNOW DENSITY    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SNDE, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFDENSIT.NEIGE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SAB, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.SABLE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SD, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'SURFRESERV.NEIGE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SDSL, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'SURFRESERV.NEIGE TOT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%WSN, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'Liquid Water snow', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SDOG, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'SURFET.GEOPOTENT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SFIS, -9999, IA, 12, 0, 0, 0, LLF, LLT, 'INTSURFGEOPOTENT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SKT, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SLHF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SLOR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SMLT, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SOTY, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CLK, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%DL, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LMLT, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LMLD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LBLT, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LTLT, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LSHF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICT, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SR, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'SURFZ0.FOIS.G   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SRC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSHF, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSRDC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SST, -9999, IG, 12, 0, 0, 2, LLF, LLT, 'SEASURFTEMPERATU', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSW, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'SURFRESERV.EAU  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ST, -9999, IG, 12, 0, 1, 1, LLF, LLT, 'SURFTEMPERATURE ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%UCUR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%VCUR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL1, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL2, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STL4, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STRC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STRD, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%STRDC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SUND, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SUNSHI. DURATION', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL1, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL2, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%SWL4, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCO3, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      DO JGFL = 1, JPOSGHG
        call initialize_physical_descriptor(YDAFN%GFP%TCGHG(JGFL), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      DO JGFL = 1, JPOSCHEM
        call initialize_physical_descriptor(YDAFN%GFP%TCCHEM(JGFL), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      DO JGFL = 1, JPOSCHEMFLX
        call initialize_physical_descriptor(YDAFN%GFP%CHEMFLXO(JGFL), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      DO JGFL = 1, JPOSCHEMFLX
        call initialize_physical_descriptor(YDAFN%GFP%CHEMWDFLX(JGFL), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      DO JGFL = 1, JPOSCHEMFLX
        call initialize_physical_descriptor(YDAFN%GFP%CHEMDDFLX(JGFL), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      DO JDIAG = 1, JPOSAERODIAG
      DO JGFL = 1, JPOSAERO
        call initialize_physical_descriptor(YDAFN%GFP%AERODIAG(JGFL, JDIAG), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      END DO
      DO JDIAG = 1, JPOSAERO_WVL_DIAG_TYPES
      DO JGFL = 1, JPOSAERO_WVL_DIAG
        call initialize_physical_descriptor(YDAFN%GFP%AERO_WVL_DIAG(JGFL, JDIAG), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      END DO
      DO JGFL = 1, JPOSEMIS2D
        call initialize_physical_descriptor(YDAFN%GFP%EMIS2D(JGFL), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      DO JGFL = 1, JPOSEMIS2DAUX
        call initialize_physical_descriptor(YDAFN%GFP%EMIS2DAUX(JGFL), -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      END DO
      call initialize_physical_descriptor(YDAFN%GFP%VIWVE, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%VIWVN, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCW, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCWV, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCLW, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCIW, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCRW, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCSW, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TCSLW, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TP, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TSN, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TSR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TSRC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TTR, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TTRC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TVH, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TVL, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%VEG, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFPROP.VEGETAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%VIMD, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'VertIntegMassDiv', CL)
      call initialize_physical_descriptor(YDAFN%GFP%VISIH, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%Z0F, -9999, IA, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%Z0H, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'SURFGZ0.THERM   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%Z0V, -9999, IA, 12, 0, 0, 1, LLF, LLT, 'SURFZ0VEG.FOIS.G', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC0DEGL, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ECM10DEGL, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CIN, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCIN50, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCIN100, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%KINDEX, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%TTINDEX, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CBASEA, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%CTOPC, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ZTWETB0, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ZTWETB1, -9999, IG, 12, 0, 0, 1, LLF, LLT, CL, CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASEA, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.SEA   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ALAN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.LAND  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASOO, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.SOOT  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ADES, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.DESERT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ASUL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.SULFAT', CL)
      call initialize_physical_descriptor(YDAFN%GFP%AVOL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFAEROS.VOLCAN', CL)
      call initialize_physical_descriptor(YDAFN%GFP%O3A, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFA.OF.OZONE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%O3B, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFB.OF.OZONE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%O3C, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SURFC.OF.OZONE  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SPAR, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PHOTO.ACTIVE.RAD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SUVB, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'UV-B RADIATION  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CAPE, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CONV.AV.POT.ENER', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MUCAPE, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'MAX.UNSTABL.CAPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCAPE50, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'MIX.LAYER50 CAPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLCAPE100, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'MIX.LAYR100 CAPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PDEPL, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'DEP.LEVEL MUCAPE', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CAPES, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CAPE-SHEAR      ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXCAP6, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'MAX CAPE LAST 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MXCAPS6, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'MAX CAPESHEAR 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TROPOTP, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PRES.THER.TROPOP', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SPARC, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'C-S PHO.ACT. RAD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%STINC, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'TOA INC.SOL. RAD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SFDIR, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SUR.TOT.SKY DIRD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SCDIR, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SUR.CLR-SKY DIRD', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DNDZN, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'Min Refrac Grad ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DNDZA, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'Mean Refrac Grad', CL)
      call initialize_physical_descriptor(YDAFN%GFP%DCTB, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'Duct Base Height', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TPLB, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'Trap Layer Base ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%TPLT, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'Trap Layer Top  ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTI, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.INST', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTA1, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.AVG1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTA3, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.AVG3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LITOTA6, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'TOT.LIGHTN.AVG6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGI, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.INST ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGA1, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.AVG1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGA3, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.AVG 3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%LICGA6, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'CG.LIGHTN.AVG 6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPEMODE1, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE MODE    1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPEMODE3, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE MODE    3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPEMODE6, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE MODE    6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPESEVR1, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE SEVERE  1H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPESEVR3, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE SEVERE  3H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%PTYPESEVR6, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'PTYPE SEVERE  6H', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SDSRP, -9999, IG, 12, 0, 0, 1, LLF, LLT, 'SF.TOT.SKY DIRDP', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CLBT, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'Cloud BrightTemp', CL)
      call initialize_physical_descriptor(YDAFN%GFP%CSBT, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'Clear BrightTemp', CL)
      call initialize_physical_descriptor(YDAFN%GFP%ICTH, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'Ice thickness   ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%MLD, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'Mixed Layer Dep ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSH, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'Sea Surf Height ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%EC20D, -9999, IG, 12, 0, 0, 0, LLF, LLT, '20degC depth    ', CL)
      call initialize_physical_descriptor(YDAFN%GFP%SSS, -9999, IG, 12, 0, 0, 0, LLF, LLT, 'Sea Surf Salini ', CL)
      DO JVAR = 1, JPOSVX2
        WRITE (CLFA, '(''SURFEXTRAFIELD'',I2.2)') JVAR
        call initialize_physical_descriptor(YDAFN%GFP%VX2(JVAR), -9999, IG, 12, 0, 0, 1, LLF, LLT, CLFA, CL)
      END DO
      DO JVAR = 1, JPOSFSU
        WRITE (CLFA, '(''SURFFREE.FIELD'',I2.2)') JVAR
        call initialize_physical_descriptor(YDAFN%GFP%FSU(JVAR), -9999, IG, 12, 0, 0, 1, LLF, LLT, CLFA, CL)
      END DO
    END IF
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT7C1, LLT, file_metadata%YFA_MSAT7C1%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT7C2, LLT, file_metadata%YFA_MSAT7C2%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C1, LLT, file_metadata%YFA_MSAT8C1%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C2, LLT, file_metadata%YFA_MSAT8C2%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C3, LLT, file_metadata%YFA_MSAT8C3%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C4, LLT, file_metadata%YFA_MSAT8C4%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C5, LLT, file_metadata%YFA_MSAT8C5%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C6, LLT, file_metadata%YFA_MSAT8C6%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C7, LLT, file_metadata%YFA_MSAT8C7%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT8C8, LLT, file_metadata%YFA_MSAT8C8%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C1, LLT, file_metadata%YFA_MSAT9C1%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C2, LLT, file_metadata%YFA_MSAT9C2%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C3, LLT, file_metadata%YFA_MSAT9C3%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C4, LLT, file_metadata%YFA_MSAT9C4%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C5, LLT, file_metadata%YFA_MSAT9C5%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C6, LLT, file_metadata%YFA_MSAT9C6%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C7, LLT, file_metadata%YFA_MSAT9C7%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
call initialize_dynamic_descriptor(YDAFN%TFP%MSAT9C8, LLT, file_metadata%YFA_MSAT9C8%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES11C1,LLT,file_metadata%YFA_GOES11C1%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES11C2,LLT,file_metadata%YFA_GOES11C2%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES11C3,LLT,file_metadata%YFA_GOES11C3%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES11C4,LLT,file_metadata%YFA_GOES11C4%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES12C1,LLT,file_metadata%YFA_GOES12C1%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES12C2,LLT,file_metadata%YFA_GOES12C2%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES12C3,LLT,file_metadata%YFA_GOES12C3%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%GOES12C4,LLT,file_metadata%YFA_GOES12C4%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%MTSAT1C1,LLT,file_metadata%YFA_MTSAT1C1%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%MTSAT1C2,LLT,file_metadata%YFA_MTSAT1C2%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%MTSAT1C3,LLT,file_metadata%YFA_MTSAT1C3%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%MTSAT1C4,LLT,file_metadata%YFA_MTSAT1C4%CLNAME,-99999,IS,IG,12,LLT,I0,Z0,0,CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%TX, LLT, file_metadata%YFA_XX2T%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%TN, LLT, file_metadata%YFA_XN2T%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%HUX, LLT, file_metadata%YFA_XX2HU%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%HUN, LLT, file_metadata%YFA_XN2HU%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%CAPE, LLT, file_metadata%YFA_CAPE%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%CIEN, LLT, file_metadata%YFA_CIEN%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_dynamic_descriptor(YDAFN%TFP%TCVS, LLT, file_metadata%YFA_TCVS%CLNAME, -99999, IS, IG, 12, LLT, I0, Z0, 0, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLSP, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CLSP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCP, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CCP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLSS, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CLSS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCSF, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CCSF%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLSG, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CLSG%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCSG, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CCSG%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLSH, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CLSH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCSH, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CCSH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CUSS, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_CUSS%CLNAME, 'CSS')
    call initialize_physical_descriptor(YDAFN%GFP%CVSS, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_CVSS%CLNAME, 'CSS')
    call initialize_physical_descriptor(YDAFN%GFP%CSSH, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSSH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSLH, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSLH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTSP, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTSP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CBLD, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CBLD%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSSR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSSR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSTR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSTR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTSR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTSR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTTR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTTR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CCCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CHCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CHCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CMCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CMCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CLCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CUGW, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_CUGW%CLNAME, 'CGW')
    call initialize_physical_descriptor(YDAFN%GFP%CVGW, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_CVGW%CLNAME, 'CGW')
    call initialize_physical_descriptor(YDAFN%GFP%CUTO, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_CUTO%CLNAME, 'CTO')
    call initialize_physical_descriptor(YDAFN%GFP%CVTO, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_CVTO%CLNAME, 'CTO')
    call initialize_physical_descriptor(YDAFN%GFP%CE, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CE%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CS, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CT, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CT%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLHE, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CLHE%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLHS, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CLHS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLHT, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CLHT%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CWS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CWS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSNS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CSNS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CQTO, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CQTO%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTO3, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTO3%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTME, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTME%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CICE, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CICE%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CLI, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CLI%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCVU, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_CCVU%CLNAME, 'CCV')
    call initialize_physical_descriptor(YDAFN%GFP%CCVV, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_CCVV%CLNAME, 'CCV')
    call initialize_physical_descriptor(YDAFN%GFP%CCVQ, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CCVQ%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCVS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CCVS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTUQ, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CTUQ%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTUS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CTUS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSOC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSOC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTHC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTHC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSOP, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSOP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CDNI, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CDNI%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CGNI, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CGNI%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTOP, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTOP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSOD, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSOD%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTHD, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTHD%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CFON, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CFON%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CCHS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CCHS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CEAS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CEAS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSRU, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CSRU%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CDRU, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CDRU%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CIRU, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CIRU%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CETP, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CETP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTP, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_CTP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CSMR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CSMR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTSOC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTSOC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CTTHC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_CTTHC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CDUTP, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CDUTP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%CFLASH, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_CFLASH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XTCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XTCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%X10U, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_X10U%CLNAME, 'CLS')
    call initialize_physical_descriptor(YDAFN%GFP%X10V, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_X10V%CLNAME, 'CLS')
    call initialize_physical_descriptor(YDAFN%GFP%X10NU, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_X10NU%CLNAME, 'CLS')
    call initialize_physical_descriptor(YDAFN%GFP%X10NV, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_X10NV%CLNAME, 'CLS')
    call initialize_physical_descriptor(YDAFN%GFP%X2T, -9999, IG, 12, 0, 1, 1, LLF, LLT, file_metadata%YFA_X2T%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%X2TPW, -9999, IG, 12, 0, 1, 1, LLF, LLT, file_metadata%YFA_X2TPW%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%X2SH, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_X2SH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%X2RH, -9999, IG, 12, 0, 1, 1, LLF, LLT, file_metadata%YFA_X2RH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XCCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XHCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XHCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XMCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XMCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XLCC, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XLCC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XX2T, -9999, IG, 0, 0, 1, 1, LLF, LLT, file_metadata%YFA_XX2T%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XN2T, -9999, IG, 0, 0, 1, 1, LLF, LLT, file_metadata%YFA_XN2T%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCVU, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_XCVU%CLNAME, 'XCV')
    call initialize_physical_descriptor(YDAFN%GFP%XCVV, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_XCVV%CLNAME, 'XCV')
    call initialize_physical_descriptor(YDAFN%GFP%XCVQ, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_XCVQ%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCVS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_XCVS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XTUU, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_XTUU%CLNAME, 'XTU')
    call initialize_physical_descriptor(YDAFN%GFP%XTUV, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_XTUV%CLNAME, 'XTU')
    call initialize_physical_descriptor(YDAFN%GFP%XTUQ, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_XTUQ%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XTUS, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_XTUS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XGDU, -9999, IG, 12, +1, 0, 1, LLF, LLT, file_metadata%YFA_XGDU%CLNAME, 'XGD')
    call initialize_physical_descriptor(YDAFN%GFP%XGDV, -9999, IG, 12, -1, 0, 1, LLF, LLT, file_metadata%YFA_XGDV%CLNAME, 'XGD')
    call initialize_physical_descriptor(YDAFN%GFP%XLSP, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XLSP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCP, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XCP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XLSS, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XLSS%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCSF, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XCSF%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XLSG, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XLSG%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCSG, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XCSG%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XLSH, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XLSH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCSH, -9999, IG, 12, 0, 0, 0, LLT, LLT, file_metadata%YFA_XCSH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XSSR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XSSR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XSTR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XSTR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XTSR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XTSR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XTTR, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XTTR%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%X10FF, -9999, IG, 12, 0, 0, 1, LLF, LLT, file_metadata%YFA_X10FF%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCAPE, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XCAPE%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCTOP, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XCTOP%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XMOCO, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XMOCO%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XCLPH, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XCLPH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XVEIN, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XVEIN%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XGUST, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XGUST%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XUGST, -9999, IG, 12, +1, 0, 0, LLF, LLT, file_metadata%YFA_XUGST%CLNAME, 'GST')
    call initialize_physical_descriptor(YDAFN%GFP%XVGST, -9999, IG, 12, -1, 0, 0, LLF, LLT, file_metadata%YFA_XVGST%CLNAME, 'GST')
   call initialize_physical_descriptor(YDAFN%GFP%XUGST2, -9999, IG, 12, +1, 0, 0, LLF, LLT, file_metadata%YFA_XUGST2%CLNAME, 'GST2')
   call initialize_physical_descriptor(YDAFN%GFP%XVGST2, -9999, IG, 12, -1, 0, 0, LLF, LLT, file_metadata%YFA_XVGST2%CLNAME, 'GST2')
    call initialize_physical_descriptor(YDAFN%GFP%XX2HU, -9999, IG, 0, 0, 1, 1, LLF, LLT, file_metadata%YFA_XX2HU%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XN2HU, -9999, IG, 0, 0, 1, 1, LLF, LLT, file_metadata%YFA_XN2HU%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XTHW, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XTHW%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XXDIAGH, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_XXDIAGH%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%ACCGREL, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_ACCGREL%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XMRT, -9999, IG, 12, 0, 0, 0, LLF, LLT, file_metadata%YFA_XMRT%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%VISICLD, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_VISICLD%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%VISIHYD, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_VISIHYD%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%MXCLWC, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_MXCLWC%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%VISICLD2, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_VISICLD2%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%VISIHYD2, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_VISIHYD2%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%MXCLWC2, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_MXCLWC2%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XPTYPE, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_XPTYPE%CLNAME, CL)
   call initialize_physical_descriptor(YDAFN%GFP%XPTYPESEV, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_XPTYPESEV%CLNAME, CL)
    call initialize_physical_descriptor(YDAFN%GFP%XPTYPE2, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_XPTYPE2%CLNAME, CL)
 call initialize_physical_descriptor(YDAFN%GFP%XPTYPESEV2, -9999, IG, 0, 0, 0, 0, LLF, LLT, file_metadata%YFA_XPTYPESEV2%CLNAME, CL)
    IF (NFPSURFEX == 2) THEN
      status = 2; return
      DO JVAR = 1, YDAFN%NSFXPRE_CNT
call initialize_physical_descriptor(YDAFN%GFP%SFXPRE(JVAR), -9999, IG, 4, 0, 0, IMASK(JVAR), LLF, LLT, CLPREP(JVAR), CL, KPREP=JVAR)
      END DO
    ELSE
      YDAFN%NSFXPRE_CNT = 0
    END IF
  END ASSOCIATE
  if (override_present) YDAFN%TFP%FUA(1)%LLGP = override_value
  status = 0
  end function
  integer(int32) function read_afn_override(text, present_override, value) result(status)
    character(*), intent(in) :: text
    logical, intent(out) :: present_override, value
    integer :: cursor, first, last
    logical :: parsed_ok
    present_override = .false.; value = .false.; status = 2
    cursor = find_physics_group(text, 'NAMAFN', .false.)
    if (cursor == 0) then
      status = 0; return
    end if
    do
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1; cycle
      end if
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= len(text))
        if (index('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_()% ', text(cursor:cursor)) == 0) exit
        if (text(cursor:cursor) == ' ') exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      if (.not. physics_fold_equal(text(first:last), 'TFP_FUA(1)%LLGP')) return
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      first = cursor
      do while (cursor <= len(text))
        if (index('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz._', text(cursor:cursor)) == 0) exit
        cursor = cursor + 1
      end do
      if (cursor <= first) return
      call parse_physics_boolean(text(first:cursor - 1), value, parsed_ok)
      if (.not. parsed_ok) return
      present_override = .true.
    end do
    status = 0
  end function
end module
