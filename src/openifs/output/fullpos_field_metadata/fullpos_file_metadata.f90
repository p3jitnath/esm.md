!> Own source file names and packing metadata; no file I/O or original global is used.
!! Counts and bit widths are dimensionless. Caller owns this single native record.
module forecast_fullpos_file_metadata
  use iso_fortran_env, only: int32
  use type_fads, only: fad
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
public::fullpos_field_metadata_controls,native_fullpos_file_metadata,initialize_fullpos_file_metadata,native_fullpos_grib_code_targets
  type :: fullpos_field_metadata_controls
    integer(int32) :: kfpconf, nprintlev, nconf, ngribfile, nrealen
    logical :: ldnhdyn, larpegef, lelam, ldnewcl(2), lecmwf, larome
  end type

  type :: native_fullpos_grib_code_targets
! These readonly targets belong to the actual earlier GRIB-code producer.
    integer(int32), pointer :: ngrbdl => null()
    integer(int32), pointer :: ngrbgpp => null()
    integer(int32), pointer :: ngrbigpp => null()
    integer(int32), pointer :: ngrbinee => null()
    integer(int32), pointer :: ngrbirec => null()
    integer(int32), pointer :: ngrblblt => null()
    integer(int32), pointer :: ngrblicd => null()
    integer(int32), pointer :: ngrblict => null()
    integer(int32), pointer :: ngrblmld => null()
    integer(int32), pointer :: ngrblmlt => null()
    integer(int32), pointer :: ngrblshf => null()
    integer(int32), pointer :: ngrbltlt => null()
    integer(int32), pointer :: ngrbnee => null()
    integer(int32), pointer :: ngrbrec => null()
    integer(int32), pointer :: ngrbtcghg(:) => null()
  end type
  type :: native_fullpos_file_metadata
    type(fad) :: YFACLF
    type(fad) :: YFACPF
    type(fad) :: YFACVGQ
    type(fad) :: YFACVV
    type(fad) :: YFADAL
    type(fad) :: YFADOM
    type(fad) :: YFAEFB1
    type(fad) :: YFAEFB2
    type(fad) :: YFAEFB3
    type(fad) :: YFAFQTUR
    type(fad) :: YFAFSP1
    type(fad) :: YFAFSP2
    type(fad) :: YFAFSP3
    type(fad) :: YFAFSP4
    type(fad) :: YFAFSP5
    type(fad) :: YFAFSTUR
    type(fad) :: YFAG
    type(fad) :: YFAH
    type(fad) :: YFAI
    type(fad) :: YFAICONV
    type(fad) :: YFAIRAD
    type(fad) :: YFAKHI
    type(fad) :: YFAL
    type(fad) :: YFALCONV
    type(fad) :: YFALRAD
    type(fad) :: YFAMXL
    type(fad) :: YFAO3
    type(fad) :: YFAOROG
    type(fad) :: YFAPD
    type(fad) :: YFAPSI
    type(fad) :: YFAQ
    type(fad) :: YFAQVA
    type(fad) :: YFAR
    type(fad) :: YFARCONV
    type(fad) :: YFARKTH
    type(fad) :: YFARKTQC
    type(fad) :: YFARKTQV
    type(fad) :: YFAS
    type(fad) :: YFASCONV
    type(fad) :: YFASDSAT
    type(fad) :: YFASHTUR
    type(fad) :: YFASP
    type(fad) :: YFASPF
    type(fad) :: YFASRC
    type(fad) :: YFAT
    type(fad) :: YFATKE
    type(fad) :: YFATTE
    type(fad) :: YFAUAL
    type(fad) :: YFAUEN
    type(fad) :: YFAUGEO
    type(fad) :: YFAUNEBH
    type(fad) :: YFAUOM
    type(fad) :: YFAVD
    type(fad) :: YFAVGEO
    type(fad) :: YFA_ACCGREL
    type(fad) :: YFA_ASMC
    type(fad) :: YFA_CAPE
    type(fad) :: YFA_CBLD
    type(fad) :: YFA_CCCC
    type(fad) :: YFA_CCHS
    type(fad) :: YFA_CCP
    type(fad) :: YFA_CCSF
    type(fad) :: YFA_CCSG
    type(fad) :: YFA_CCSH
    type(fad) :: YFA_CCVQ
    type(fad) :: YFA_CCVS
    type(fad) :: YFA_CCVU
    type(fad) :: YFA_CCVV
    type(fad) :: YFA_CDNI
    type(fad) :: YFA_CDRU
    type(fad) :: YFA_CDUTP
    type(fad) :: YFA_CE
    type(fad) :: YFA_CEAS
    type(fad) :: YFA_CETP
    type(fad) :: YFA_CFLASH
    type(fad) :: YFA_CFON
    type(fad) :: YFA_CGNI
    type(fad) :: YFA_CHCC
    type(fad) :: YFA_CICE
    type(fad) :: YFA_CIEN
    type(fad) :: YFA_CIRU
    type(fad) :: YFA_CLCC
    type(fad) :: YFA_CLHE
    type(fad) :: YFA_CLHS
    type(fad) :: YFA_CLHT
    type(fad) :: YFA_CLI
    type(fad) :: YFA_CLSG
    type(fad) :: YFA_CLSH
    type(fad) :: YFA_CLSP
    type(fad) :: YFA_CLSS
    type(fad) :: YFA_CMCC
    type(fad) :: YFA_CQTO
    type(fad) :: YFA_CS
    type(fad) :: YFA_CSLH
    type(fad) :: YFA_CSMR
    type(fad) :: YFA_CSNS
    type(fad) :: YFA_CSOC
    type(fad) :: YFA_CSOD
    type(fad) :: YFA_CSOP
    type(fad) :: YFA_CSRU
    type(fad) :: YFA_CSSH
    type(fad) :: YFA_CSSR
    type(fad) :: YFA_CSTR
    type(fad) :: YFA_CT
    type(fad) :: YFA_CTCC
    type(fad) :: YFA_CTHC
    type(fad) :: YFA_CTHD
    type(fad) :: YFA_CTME
    type(fad) :: YFA_CTO3
    type(fad) :: YFA_CTOP
    type(fad) :: YFA_CTP
    type(fad) :: YFA_CTSOC
    type(fad) :: YFA_CTSP
    type(fad) :: YFA_CTSR
    type(fad) :: YFA_CTTHC
    type(fad) :: YFA_CTTR
    type(fad) :: YFA_CTUQ
    type(fad) :: YFA_CTUS
    type(fad) :: YFA_CUGW
    type(fad) :: YFA_CUSS
    type(fad) :: YFA_CUTO
    type(fad) :: YFA_CVGW
    type(fad) :: YFA_CVSS
    type(fad) :: YFA_CVTO
    type(fad) :: YFA_CWS
    type(fad) :: YFA_GOES11C1
    type(fad) :: YFA_GOES11C2
    type(fad) :: YFA_GOES11C3
    type(fad) :: YFA_GOES11C4
    type(fad) :: YFA_GOES12C1
    type(fad) :: YFA_GOES12C2
    type(fad) :: YFA_GOES12C3
    type(fad) :: YFA_GOES12C4
    type(fad) :: YFA_MSAT7C1
    type(fad) :: YFA_MSAT7C2
    type(fad) :: YFA_MSAT8C1
    type(fad) :: YFA_MSAT8C2
    type(fad) :: YFA_MSAT8C3
    type(fad) :: YFA_MSAT8C4
    type(fad) :: YFA_MSAT8C5
    type(fad) :: YFA_MSAT8C6
    type(fad) :: YFA_MSAT8C7
    type(fad) :: YFA_MSAT8C8
    type(fad) :: YFA_MSAT9C1
    type(fad) :: YFA_MSAT9C2
    type(fad) :: YFA_MSAT9C3
    type(fad) :: YFA_MSAT9C4
    type(fad) :: YFA_MSAT9C5
    type(fad) :: YFA_MSAT9C6
    type(fad) :: YFA_MSAT9C7
    type(fad) :: YFA_MSAT9C8
    type(fad) :: YFA_MTSAT1C1
    type(fad) :: YFA_MTSAT1C2
    type(fad) :: YFA_MTSAT1C3
    type(fad) :: YFA_MTSAT1C4
    type(fad) :: YFA_MXCLWC
    type(fad) :: YFA_MXCLWC2
    type(fad) :: YFA_TCVS
    type(fad) :: YFA_VISICLD
    type(fad) :: YFA_VISICLD2
    type(fad) :: YFA_VISIHYD
    type(fad) :: YFA_VISIHYD2
    type(fad) :: YFA_VSMC
    type(fad) :: YFA_X10FF
    type(fad) :: YFA_X10NU
    type(fad) :: YFA_X10NV
    type(fad) :: YFA_X10U
    type(fad) :: YFA_X10V
    type(fad) :: YFA_X2RH
    type(fad) :: YFA_X2SH
    type(fad) :: YFA_X2T
    type(fad) :: YFA_X2TPW
    type(fad) :: YFA_XCAPE
    type(fad) :: YFA_XCCC
    type(fad) :: YFA_XCLPH
    type(fad) :: YFA_XCP
    type(fad) :: YFA_XCSF
    type(fad) :: YFA_XCSG
    type(fad) :: YFA_XCSH
    type(fad) :: YFA_XCTOP
    type(fad) :: YFA_XCVQ
    type(fad) :: YFA_XCVS
    type(fad) :: YFA_XCVU
    type(fad) :: YFA_XCVV
    type(fad) :: YFA_XGDU
    type(fad) :: YFA_XGDV
    type(fad) :: YFA_XGUST
    type(fad) :: YFA_XHCC
    type(fad) :: YFA_XLCC
    type(fad) :: YFA_XLSG
    type(fad) :: YFA_XLSH
    type(fad) :: YFA_XLSP
    type(fad) :: YFA_XLSS
    type(fad) :: YFA_XMCC
    type(fad) :: YFA_XMOCO
    type(fad) :: YFA_XMRT
    type(fad) :: YFA_XN2HU
    type(fad) :: YFA_XN2T
    type(fad) :: YFA_XPTYPE
    type(fad) :: YFA_XPTYPE2
    type(fad) :: YFA_XPTYPESEV
    type(fad) :: YFA_XPTYPESEV2
    type(fad) :: YFA_XSSR
    type(fad) :: YFA_XSTR
    type(fad) :: YFA_XTCC
    type(fad) :: YFA_XTHW
    type(fad) :: YFA_XTSR
    type(fad) :: YFA_XTTR
    type(fad) :: YFA_XTUQ
    type(fad) :: YFA_XTUS
    type(fad) :: YFA_XTUU
    type(fad) :: YFA_XTUV
    type(fad) :: YFA_XUGST
    type(fad) :: YFA_XUGST2
    type(fad) :: YFA_XVEIN
    type(fad) :: YFA_XVGST
    type(fad) :: YFA_XVGST2
    type(fad) :: YFA_XX2HU
    type(fad) :: YFA_XX2T
    type(fad) :: YFA_XXDIAGH
    integer(int32) :: NVGRIB, NBITPG, NBITCS, NSTRON, NPULAP, NVERBOSE, NIDCEN
    character(64) :: cmodel
    logical :: lextern, lsuppdate
    logical :: ready = .false.
  end type
contains
  integer(int32) function initialize_fullpos_file_metadata(text, controls, metadata) result(status)
    character(*), intent(in) :: text
    type(fullpos_field_metadata_controls), intent(in) :: controls
    type(native_fullpos_file_metadata), intent(inout) :: metadata
    integer :: IDMOPL, INBARI, IREP
    character(12) :: CLSCRTCH
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    if(controls%ngribfile/=1.or..not.controls%lecmwf.or.controls%larpegef.or.controls%larome.or.controls%nrealen/=8)return
    status = require_empty_physics_group(text, 'NAMFA')
    if (status /= 0) return
associate(NVGRIB=>metadata%NVGRIB,NBITPG=>metadata%NBITPG,NBITCS=>metadata%NBITCS,NSTRON=>metadata%NSTRON,NPULAP=>metadata%NPULAP,YFA_MSAT7C1=>metadata%YFA_MSAT7C1,YFA_MSAT7C2=>metadata%YFA_MSAT7C2,YFA_MSAT8C1=>metadata%YFA_MSAT8C1,YFA_MSAT8C2=>metadata%YFA_MSAT8C2,YFA_MSAT8C3=>metadata%YFA_MSAT8C3,YFA_MSAT8C4=>metadata%YFA_MSAT8C4,YFA_MSAT8C5=>metadata%YFA_MSAT8C5,YFA_MSAT8C6=>metadata%YFA_MSAT8C6,YFA_MSAT8C7=>metadata%YFA_MSAT8C7,YFA_MSAT8C8=>metadata%YFA_MSAT8C8,YFA_MSAT9C1=>metadata%YFA_MSAT9C1,YFA_MSAT9C2=>metadata%YFA_MSAT9C2,YFA_MSAT9C3=>metadata%YFA_MSAT9C3,YFA_MSAT9C4=>metadata%YFA_MSAT9C4,YFA_MSAT9C5=>metadata%YFA_MSAT9C5,YFA_MSAT9C6=>metadata%YFA_MSAT9C6,YFA_MSAT9C7=>metadata%YFA_MSAT9C7,YFA_MSAT9C8=>metadata%YFA_MSAT9C8,YFA_GOES11C1=>metadata%YFA_GOES11C1,YFA_GOES11C2=>metadata%YFA_GOES11C2,YFA_GOES11C3=>metadata%YFA_GOES11C3,YFA_GOES11C4=>metadata%YFA_GOES11C4,YFA_GOES12C1=>metadata%YFA_GOES12C1,YFA_GOES12C2=>metadata%YFA_GOES12C2,YFA_GOES12C3=>metadata%YFA_GOES12C3,YFA_GOES12C4=>metadata%YFA_GOES12C4,YFA_MTSAT1C1=>metadata%YFA_MTSAT1C1,YFA_MTSAT1C2=>metadata%YFA_MTSAT1C2,YFA_MTSAT1C3=>metadata%YFA_MTSAT1C3,YFA_MTSAT1C4=>metadata%YFA_MTSAT1C4,YFA_XTCC=>metadata%YFA_XTCC,YFA_X10U=>metadata%YFA_X10U,YFA_X10V=>metadata%YFA_X10V,YFA_X10NU=>metadata%YFA_X10NU,YFA_X10NV=>metadata%YFA_X10NV,YFA_X2T=>metadata%YFA_X2T,YFA_X2SH=>metadata%YFA_X2SH,YFA_X2RH=>metadata%YFA_X2RH,YFA_XCCC=>metadata%YFA_XCCC,YFA_XHCC=>metadata%YFA_XHCC,YFA_XMCC=>metadata%YFA_XMCC,YFA_XLCC=>metadata%YFA_XLCC,YFA_XX2T=>metadata%YFA_XX2T,YFA_XN2T=>metadata%YFA_XN2T,YFA_XCVU=>metadata%YFA_XCVU,YFA_XCVV=>metadata%YFA_XCVV,YFA_XCVQ=>metadata%YFA_XCVQ,YFA_XCVS=>metadata%YFA_XCVS,YFA_XTUU=>metadata%YFA_XTUU,YFA_XTUV=>metadata%YFA_XTUV,YFA_XTUQ=>metadata%YFA_XTUQ,YFA_XTUS=>metadata%YFA_XTUS,YFA_XGDU=>metadata%YFA_XGDU,YFA_XGDV=>metadata%YFA_XGDV,YFA_XLSP=>metadata%YFA_XLSP,YFA_XCP=>metadata%YFA_XCP,YFA_XLSS=>metadata%YFA_XLSS,YFA_XCSF=>metadata%YFA_XCSF,YFA_XLSG=>metadata%YFA_XLSG,YFA_XCSG=>metadata%YFA_XCSG,YFA_XLSH=>metadata%YFA_XLSH,YFA_XCSH=>metadata%YFA_XCSH,YFA_XSSR=>metadata%YFA_XSSR,YFA_XSTR=>metadata%YFA_XSTR,YFA_XTSR=>metadata%YFA_XTSR,YFA_XTTR=>metadata%YFA_XTTR,YFA_X10FF=>metadata%YFA_X10FF,YFA_XCAPE=>metadata%YFA_XCAPE,YFA_XCTOP=>metadata%YFA_XCTOP,YFA_XMOCO=>metadata%YFA_XMOCO,YFA_XCLPH=>metadata%YFA_XCLPH,YFA_XVEIN=>metadata%YFA_XVEIN,YFA_XGUST=>metadata%YFA_XGUST,YFA_XUGST=>metadata%YFA_XUGST,YFA_XVGST=>metadata%YFA_XVGST,YFA_XUGST2=>metadata%YFA_XUGST2,YFA_XVGST2=>metadata%YFA_XVGST2,YFA_XX2HU=>metadata%YFA_XX2HU,YFA_XN2HU=>metadata%YFA_XN2HU,YFA_XTHW=>metadata%YFA_XTHW,YFA_XXDIAGH=>metadata%YFA_XXDIAGH,YFA_XMRT=>metadata%YFA_XMRT,YFA_VISICLD=>metadata%YFA_VISICLD,YFA_VISIHYD=>metadata%YFA_VISIHYD,YFA_MXCLWC=>metadata%YFA_MXCLWC,YFA_VISICLD2=>metadata%YFA_VISICLD2,YFA_VISIHYD2=>metadata%YFA_VISIHYD2,YFA_MXCLWC2=>metadata%YFA_MXCLWC2,YFA_XPTYPE=>metadata%YFA_XPTYPE,YFA_XPTYPESEV=>metadata%YFA_XPTYPESEV,YFA_XPTYPE2=>metadata%YFA_XPTYPE2,YFA_XPTYPESEV2=>metadata%YFA_XPTYPESEV2,YFA_X2TPW=>metadata%YFA_X2TPW,YFA_CLSP=>metadata%YFA_CLSP,YFA_CCP=>metadata%YFA_CCP,YFA_CLSS=>metadata%YFA_CLSS,YFA_CCSF=>metadata%YFA_CCSF,YFA_CLSG=>metadata%YFA_CLSG,YFA_CCSG=>metadata%YFA_CCSG,YFA_CLSH=>metadata%YFA_CLSH,YFA_CCSH=>metadata%YFA_CCSH,YFA_CUSS=>metadata%YFA_CUSS,YFA_CVSS=>metadata%YFA_CVSS,YFA_CSSH=>metadata%YFA_CSSH,YFA_CSLH=>metadata%YFA_CSLH,YFA_CTSP=>metadata%YFA_CTSP,YFA_CTCC=>metadata%YFA_CTCC,YFA_CBLD=>metadata%YFA_CBLD,YFA_CSSR=>metadata%YFA_CSSR,YFA_CSTR=>metadata%YFA_CSTR,YFA_CTSR=>metadata%YFA_CTSR,YFA_CTTR=>metadata%YFA_CTTR,YFA_CCCC=>metadata%YFA_CCCC,YFA_CHCC=>metadata%YFA_CHCC,YFA_CMCC=>metadata%YFA_CMCC,YFA_CLCC=>metadata%YFA_CLCC,YFA_CUGW=>metadata%YFA_CUGW,YFA_CVGW=>metadata%YFA_CVGW,YFA_CUTO=>metadata%YFA_CUTO,YFA_CVTO=>metadata%YFA_CVTO,YFA_CE=>metadata%YFA_CE,YFA_CS=>metadata%YFA_CS,YFA_CT=>metadata%YFA_CT,YFA_CLHE=>metadata%YFA_CLHE,YFA_CLHS=>metadata%YFA_CLHS,YFA_CLHT=>metadata%YFA_CLHT,YFA_CWS=>metadata%YFA_CWS,YFA_CSNS=>metadata%YFA_CSNS,YFA_CQTO=>metadata%YFA_CQTO,YFA_CTO3=>metadata%YFA_CTO3,YFA_CTME=>metadata%YFA_CTME,YFA_CICE=>metadata%YFA_CICE,YFA_CLI=>metadata%YFA_CLI,YFA_CCVU=>metadata%YFA_CCVU,YFA_CCVV=>metadata%YFA_CCVV,YFA_CCVQ=>metadata%YFA_CCVQ,YFA_CCVS=>metadata%YFA_CCVS,YFA_CTUQ=>metadata%YFA_CTUQ,YFA_CTUS=>metadata%YFA_CTUS,YFA_CSOC=>metadata%YFA_CSOC,YFA_CTHC=>metadata%YFA_CTHC,YFA_CSOP=>metadata%YFA_CSOP,YFA_CDNI=>metadata%YFA_CDNI,YFA_CGNI=>metadata%YFA_CGNI,YFA_CTOP=>metadata%YFA_CTOP,YFA_CSOD=>metadata%YFA_CSOD,YFA_CTHD=>metadata%YFA_CTHD,YFA_CFON=>metadata%YFA_CFON,YFA_CCHS=>metadata%YFA_CCHS,YFA_CEAS=>metadata%YFA_CEAS,YFA_CSRU=>metadata%YFA_CSRU,YFA_CDRU=>metadata%YFA_CDRU,YFA_CIRU=>metadata%YFA_CIRU,YFA_CETP=>metadata%YFA_CETP,YFA_CTP=>metadata%YFA_CTP,YFA_CSMR=>metadata%YFA_CSMR,YFA_CTSOC=>metadata%YFA_CTSOC,YFA_CTTHC=>metadata%YFA_CTTHC,YFA_CDUTP=>metadata%YFA_CDUTP,YFA_CFLASH=>metadata%YFA_CFLASH,YFA_CAPE=>metadata%YFA_CAPE,YFA_CIEN=>metadata%YFA_CIEN,YFA_TCVS=>metadata%YFA_TCVS,YFA_ASMC=>metadata%YFA_ASMC,YFA_VSMC=>metadata%YFA_VSMC,YFA_ACCGREL=>metadata%YFA_ACCGREL,YFAOROG=>metadata%YFAOROG,YFASP=>metadata%YFASP,YFAPSI=>metadata%YFAPSI,YFAKHI=>metadata%YFAKHI,YFAUGEO=>metadata%YFAUGEO,YFAVGEO=>metadata%YFAVGEO,YFAT=>metadata%YFAT,YFAPD=>metadata%YFAPD,YFAVD=>metadata%YFAVD,YFAQ=>metadata%YFAQ,YFAL=>metadata%YFAL,YFALCONV=>metadata%YFALCONV,YFAICONV=>metadata%YFAICONV,YFARCONV=>metadata%YFARCONV,YFASCONV=>metadata%YFASCONV,YFAI=>metadata%YFAI,NVERBOSE=>metadata%NVERBOSE,LSUPPDATE=>metadata%LSUPPDATE,YFAO3=>metadata%YFAO3,YFACLF=>metadata%YFACLF,YFAS=>metadata%YFAS,YFAR=>metadata%YFAR,YFAG=>metadata%YFAG,YFAH=>metadata%YFAH,YFATKE=>metadata%YFATKE,YFAEFB1=>metadata%YFAEFB1,YFAEFB2=>metadata%YFAEFB2,YFAEFB3=>metadata%YFAEFB3,YFACPF=>metadata%YFACPF,YFASPF=>metadata%YFASPF,YFAFSP1=>metadata%YFAFSP1,YFAFSP2=>metadata%YFAFSP2,YFAFSP3=>metadata%YFAFSP3,YFAFSP4=>metadata%YFAFSP4,YFAFSP5=>metadata%YFAFSP5,YFASRC=>metadata%YFASRC,YFASDSAT=>metadata%YFASDSAT,YFACVV=>metadata%YFACVV,YFACVGQ=>metadata%YFACVGQ,YFAQVA=>metadata%YFAQVA,YFAUOM=>metadata%YFAUOM,YFAUAL=>metadata%YFAUAL,YFADOM=>metadata%YFADOM,YFADAL=>metadata%YFADAL,YFAUEN=>metadata%YFAUEN,YFAUNEBH=>metadata%YFAUNEBH,YFARKTH=>metadata%YFARKTH,YFARKTQV=>metadata%YFARKTQV,YFARKTQC=>metadata%YFARKTQC,YFALRAD=>metadata%YFALRAD,YFAIRAD=>metadata%YFAIRAD,YFATTE=>metadata%YFATTE,YFAMXL=>metadata%YFAMXL,CMODEL=>metadata%CMODEL,NIDCEN=>metadata%NIDCEN,LEXTERN=>metadata%LEXTERN,YFASHTUR=>metadata%YFASHTUR,YFAFQTUR=>metadata%YFAFQTUR,YFAFSTUR=>metadata%YFAFSTUR,NGRIBFILE=>controls%ngribfile,LECMWF=>controls%lecmwf,LARPEGEF=>controls%larpegef,LAROME=>controls%larome,NCONF=>controls%nconf)
      IF (NGRIBFILE == 0 .OR. LARPEGEF) THEN
        status = 2; return
      ELSE
        NBITPG = 24
        NBITCS = 24
        NVGRIB = 2
        NSTRON = 10
        NPULAP = 1
      END IF
      YFAOROG = fad('SPECSURFGEOPOTEN', 0)
      YFASP = fad('SURFPRESSION    ', -1)
      YFAPSI = fad('POT.VITESSE     ', -1)
      YFAKHI = fad('FONC.COURANT    ', -1)
      YFAUGEO = fad('WIND.U.PHYS     ', -1)
      YFAVGEO = fad('WIND.V.PHYS     ', -1)
      YFAT = fad('TEMPERATURE     ', -1)
      YFAPD = fad('PRESS.DEPART    ', -1)
      YFAVD = fad('VERTIC.DIVER    ', -1)
      YFAFSP1 = fad('CUF1PRESSURE    ', -1)
      YFAFSP2 = fad('CUF2PRESSURE    ', -1)
      YFAFSP3 = fad('CUF3PRESSURE    ', -1)
      YFAFSP4 = fad('CUF4PRESSURE    ', -1)
      YFAFSP5 = fad('CUF5PRESSURE    ', -1)
      SELECT CASE ((LECMWF .AND. .NOT. LARPEGEF) .OR. NCONF == 901)
      CASE (.TRUE.)
        YFAQ = fad(' HUMIDITY       ', -1)
        YFAL = fad(' LIQUID WATER   ', -1)
        YFALCONV = fad('QL_CONV         ', -1)
        YFAICONV = fad('QI_CONV         ', -1)
        YFARCONV = fad('QR_CONV         ', -1)
        YFASCONV = fad('QS_CONV         ', -1)
        YFAI = fad(' ICE WATER      ', -1)
        YFALRAD = fad('RAD_LIQUID_WATER', -1)
        YFAIRAD = fad('RAD_SOLID_WATER ', -1)
        YFAO3 = fad(' OZONE          ', -1)
        YFACLF = fad(' CLOUD FRACTION ', -1)
        YFACPF = fad('CV_PREC_FLUX    ', -1)
        YFASPF = fad('ST_PREC_FLUX    ', -1)
        YFAS = fad('SNOW            ', -1)
        YFAR = fad('RAIN            ', -1)
        YFAG = fad('GRAUPEL         ', -1)
        YFAH = fad('HAIL            ', -1)
        YFATKE = fad('TKE             ', -1)
        YFAEFB1 = fad('EFB1            ', -1)
        YFAEFB2 = fad('EFB2            ', -1)
        YFAEFB3 = fad('EFB3            ', -1)
        YFASRC = fad('SRC             ', -1)
        YFACVGQ = fad('CVGQ            ', -1)
        YFAQVA = fad('QVA_AMPLITUDE   ', -1)
        YFASDSAT = fad('                ', -1)
        YFACVV = fad('                ', -1)
        YFAUOM = fad('                ', -1)
        YFAUAL = fad('                ', -1)
        YFADOM = fad('                ', -1)
        YFADAL = fad('                ', -1)
        YFAUEN = fad('                ', -1)
        YFAUNEBH = fad('                ', -1)
        YFATTE = fad('                ', -1)
        YFAMXL = fad('                ', -1)
        YFASHTUR = fad('                ', -1)
        YFAFQTUR = fad('                ', -1)
        YFAFSTUR = fad('                ', -1)
        YFARKTH = fad('                ', -1)
        YFARKTQV = fad('                ', -1)
        YFARKTQC = fad('                ', -1)
      CASE DEFAULT
        YFAQ = fad('HUMI.SPECIFI    ', -1)
        YFAL = fad('LIQUID_WATER    ', -1)
        YFALCONV = fad('QL_CONV         ', -1)
        YFAICONV = fad('QI_CONV         ', -1)
        YFARCONV = fad('QR_CONV         ', -1)
        YFASCONV = fad('QS_CONV         ', -1)
        YFAI = fad('SOLID_WATER     ', -1)
        YFALRAD = fad('RAD_LIQUID_WATER', -1)
        YFAIRAD = fad('RAD_SOLID_WATER ', -1)
        YFAO3 = fad('OZONE           ', -1)
        YFACLF = fad('CLOUD_FRACTI    ', -1)
        YFACPF = fad('CV_PREC_FLUX    ', -1)
        YFASPF = fad('ST_PREC_FLUX    ', -1)
        YFAS = fad('SNOW            ', -1)
        YFAR = fad('RAIN            ', -1)
        YFAG = fad('GRAUPEL         ', -1)
        YFAH = fad('HAIL            ', -1)
        YFATKE = fad('TKE             ', -1)
        YFAEFB1 = fad('EFB1            ', -1)
        YFAEFB2 = fad('EFB2            ', -1)
        YFAEFB3 = fad('EFB3            ', -1)
        YFASRC = fad('SRC             ', -1)
        YFACVGQ = fad('CVGQ            ', -1)
        YFAQVA = fad('QVA_AMPLITUDE   ', -1)
        YFASDSAT = fad('SDSAT           ', -1)
        YFACVV = fad('CVV             ', -1)
        YFAUOM = fad('UD_OMEGA        ', -1)
        YFAUAL = fad('UD_MESH_FRAC    ', -1)
        YFADOM = fad('DD_OMEGA        ', -1)
        YFADAL = fad('DD_MESH_FRAC    ', -1)
        YFAUEN = fad('UD_ENTRAINMENT  ', -1)
        YFAUNEBH = fad('PSHI_CONV_CLOUD ', -1)
        YFATTE = fad('TOTAL_TUR_ENERGY', -1)
        YFAMXL = fad('MIXING_LENGTH   ', -1)
        YFASHTUR = fad('SHEAR TERM TURB ', -1)
        YFAFQTUR = fad('Q SRC TERM TURB ', -1)
        YFAFSTUR = fad('S SRC TERM TURB ', -1)
        YFARKTH = fad('RK_TEMPTEND     ', -1)
        YFARKTQV = fad('RK_QVTEND       ', -1)
        YFARKTQC = fad('RK_QCTEND       ', -1)
      END SELECT
      IF (LAROME) THEN
        YFAQ = fad('HUMI.SPECIFI    ', -1)
        YFAL = fad('CLOUD_WATER     ', -1)
        YFALCONV = fad('QL_CONV         ', -1)
        YFAICONV = fad('QI_CONV         ', -1)
        YFARCONV = fad('QR_CONV         ', -1)
        YFASCONV = fad('QS_CONV         ', -1)
        YFAI = fad('ICE_CRYSTAL     ', -1)
        YFAS = fad('SNOW            ', -1)
        YFAR = fad('RAIN            ', -1)
        YFAG = fad('GRAUPEL         ', -1)
        YFAH = fad('HAIL            ', -1)
        YFATKE = fad('TKE             ', -1)
        YFAEFB1 = fad('EFB1            ', -1)
        YFAEFB2 = fad('EFB2            ', -1)
        YFAEFB3 = fad('EFB3            ', -1)
        YFACLF = fad('CLOUD_FRACTI    ', -1)
        YFASRC = fad('SRC             ', -1)
      END IF
      YFA_MSAT7C1 = fad('C001_METEOSAT_07', -1)
      YFA_MSAT7C2 = fad('C002_METEOSAT_07', -1)
      YFA_MSAT8C1 = fad('C001_METEOSAT_08', -1)
      YFA_MSAT8C2 = fad('C002_METEOSAT_08', -1)
      YFA_MSAT8C3 = fad('C003_METEOSAT_08', -1)
      YFA_MSAT8C4 = fad('C004_METEOSAT_08', -1)
      YFA_MSAT8C5 = fad('C005_METEOSAT_08', -1)
      YFA_MSAT8C6 = fad('C006_METEOSAT_08', -1)
      YFA_MSAT8C7 = fad('C007_METEOSAT_08', -1)
      YFA_MSAT8C8 = fad('C008_METEOSAT_08', -1)
      YFA_MSAT9C1 = fad('C001_METEOSAT_09', -1)
      YFA_MSAT9C2 = fad('C002_METEOSAT_09', -1)
      YFA_MSAT9C3 = fad('C003_METEOSAT_09', -1)
      YFA_MSAT9C4 = fad('C004_METEOSAT_09', -1)
      YFA_MSAT9C5 = fad('C005_METEOSAT_09', -1)
      YFA_MSAT9C6 = fad('C006_METEOSAT_09', -1)
      YFA_MSAT9C7 = fad('C007_METEOSAT_09', -1)
      YFA_MSAT9C8 = fad('C008_METEOSAT_09', -1)
      YFA_GOES11C1 = fad('C001_GOES_11_IMA', -1)
      YFA_GOES11C2 = fad('C002_GOES_11_IMA', -1)
      YFA_GOES11C3 = fad('C003_GOES_11_IMA', -1)
      YFA_GOES11C4 = fad('C004_GOES_11_IMA', -1)
      YFA_GOES12C1 = fad('C001_GOES_12_IMA', -1)
      YFA_GOES12C2 = fad('C002_GOES_12_IMA', -1)
      YFA_GOES12C3 = fad('C003_GOES_12_IMA', -1)
      YFA_GOES12C4 = fad('C004_GOES_12_IMA', -1)
      YFA_MTSAT1C1 = fad('C001_MTSAT_01_IM', -1)
      YFA_MTSAT1C2 = fad('C002_MTSAT_01_IM', -1)
      YFA_MTSAT1C3 = fad('C003_MTSAT_01_IM', -1)
      YFA_MTSAT1C4 = fad('C004_MTSAT_01_IM', -1)
      IF (LAROME) THEN
        YFA_XLSS = fad('SURFINSNEIGE    ', -1)
        YFA_XLSP = fad('SURFINSPLUIE    ', -1)
        YFA_XLSG = fad('SURFINSGRAUPEL  ', -1)
      ELSE
        YFA_XLSS = fad('S000NEIGE STRATI', -1)
        YFA_XLSP = fad('S000PLUIE STRATI', -1)
        YFA_XLSG = fad('S000GRAUP STRATI', -1)
      END IF
      YFA_XTCC = fad('SURFNEBUL.TOTALE', -1)
      YFA_X10U = fad('CLSVENT.ZONAL   ', -1)
      YFA_X10V = fad('CLSVENT.MERIDIEN', -1)
      YFA_X10NU = fad('CLSVENTNEUTRE.U ', -1)
      YFA_X10NV = fad('CLSVENTNEUTRE.V ', -1)
      YFA_X2T = fad('CLSTEMPERATURE  ', -1)
      YFA_X2TPW = fad('CLSTPRIM_W      ', -1)
      YFA_X2SH = fad('CLSHUMI.SPECIFIQ', -1)
      YFA_X2RH = fad('CLSHUMI.RELATIVE', -1)
      YFA_XCCC = fad('SURFNEBUL.CONVEC', -1)
      YFA_XHCC = fad('SURFNEBUL.HAUTE ', -1)
      YFA_XMCC = fad('SURFNEBUL.MOYENN', -1)
      YFA_XLCC = fad('SURFNEBUL.BASSE ', -1)
      YFA_XX2T = fad('CLSMAXI.TEMPERAT', -1)
      YFA_XN2T = fad('CLSMINI.TEMPERAT', -1)
      YFA_XCVU = fad('S000FL.U  CONVEC', -1)
      YFA_XCVV = fad('S000FL.V  CONVEC', -1)
      YFA_XCVQ = fad('S000FL.Q  CONVEC', -1)
      YFA_XCVS = fad('S000FL.CT CONVEC', -1)
      YFA_XTUU = fad('S000FL.U  TURBUL', -1)
      YFA_XTUV = fad('S000FL.V  TURBUL', -1)
      YFA_XTUQ = fad('S000FL.Q  TURBUL', -1)
      YFA_XTUS = fad('S000FL.CT TURBUL', -1)
      YFA_XGDU = fad('S000FL.U ONDG.OR', -1)
      YFA_XGDV = fad('S000FL.V ONDG.OR', -1)
      YFA_XCP = fad('S000PLUIE CONVEC', -1)
      YFA_XCSF = fad('S000NEIGE CONVEC', -1)
      YFA_XCSG = fad('S000GRAUP CONVEC', -1)
      YFA_XLSH = fad('S000GRELE STRATI', -1)
      YFA_XCSH = fad('S000GRELE CONVEC', -1)
      YFA_XSSR = fad('S000RAYT.SOLAIRE', -1)
      YFA_XSTR = fad('S000RAYT.TERREST', -1)
      YFA_XTSR = fad('SOMMRAYT.SOLAIRE', -1)
      YFA_XTTR = fad('SOMMRAYT.TERREST', -1)
      YFA_X10FF = fad('CLSWIND.VELOCITY', -1)
      YFA_XCAPE = fad('SURFCAPE.MOD.XFU', -1)
      YFA_XCTOP = fad('CLPTOPCONV.MOD.X', -1)
      YFA_XMOCO = fad('CLPMOCON.MOD.XFU', -1)
      YFA_XCLPH = fad('CLPMHAUT.MOD.XFU', -1)
      YFA_XVEIN = fad('CLPVEIND.MOD.XFU', -1)
      YFA_XGUST = fad('CLSRAFAL.MOD.XFU', -1)
      YFA_XUGST = fad('CLSU.RAF60M.XFU', -1)
      YFA_XVGST = fad('CLSV.RAF60M.XFU', -1)
      YFA_XUGST2 = fad('CLSU.RAF2.MOD.XFU', -1)
      YFA_XVGST2 = fad('CLSV.RAF2.MOD.XFU', -1)
      YFA_XX2HU = fad('CLSMAXI.HUMI.REL', -1)
      YFA_XN2HU = fad('CLSMINI.HUMI.REL', -1)
      YFA_XTHW = fad('THETAPWP_FLUX   ', -1)
      YFA_XXDIAGH = fad('SURFDIAGHAIL    ', -1)
      YFA_XMRT = fad('CLSMEAN.RAD.TEMP', -1)
      YFA_VISICLD = fad('CLSVISIN_60     ', -1)
      YFA_VISIHYD = fad('CLSVISIHYDN60   ', -1)
      YFA_MXCLWC = fad('CLD_WX_60M      ', -1)
      YFA_VISICLD2 = fad('CLSVISIN       ', -1)
      YFA_VISIHYD2 = fad('CLSVISIHYDN    ', -1)
      YFA_MXCLWC2 = fad('CLD_WX          ', -1)
      YFA_XPTYPE = fad('CLSPTYPE_60M    ', -1)
      YFA_XPTYPESEV = fad('CLSPTYPESEV_60M', -1)
      YFA_XPTYPE2 = fad('CLSPTYPE        ', -1)
      YFA_XPTYPESEV2 = fad('CLSPTYPESEV  ', -1)
      IF (LAROME) THEN
        YFA_CLSS = fad('SURFACCNEIGE    ', -1)
        YFA_CLSP = fad('SURFACCPLUIE    ', -1)
        YFA_CLSG = fad('SURFACCGRAUPEL  ', -1)
      ELSE
        YFA_CLSS = fad('SURFPREC.NEI.GEC', -1)
        YFA_CLSP = fad('SURFPREC.EAU.GEC', -1)
        YFA_CLSG = fad('SURFPREC.GRA.GEC', -1)
      END IF
      YFA_CCP = fad('SURFPREC.EAU.CON', -1)
      YFA_CCSF = fad('SURFPREC.NEI.CON', -1)
      YFA_CCSG = fad('SURFPREC.GRA.CON', -1)
      YFA_CLSH = fad('SURFPREC.GRE.GEC', -1)
      YFA_CCSH = fad('SURFPREC.GRE.CON', -1)
      YFA_CUSS = fad('SURFTENS.TURB.ZO', -1)
      YFA_CVSS = fad('SURFTENS.TURB.ME', -1)
      YFA_CSSH = fad('SURFFLU.CHA.SENS', -1)
      YFA_CSLH = fad('SURFCHAL LATENTE', -1)
      YFA_CTSP = fad('SURFPRESSION SOL', -1)
      YFA_CTCC = fad('ATMONEBUL.TOTALE', -1)
      YFA_CBLD = fad('SURFDISSIP SURF ', -1)
      YFA_CSSR = fad('SURFFLU.RAY.SOLA', -1)
      YFA_CSTR = fad('SURFFLU.RAY.THER', -1)
      YFA_CTSR = fad('SOMMFLU.RAY.SOLA', -1)
      YFA_CTTR = fad('SOMMFLU.RAY.THER', -1)
      YFA_CCCC = fad('ATMONEBUL.CONVEC', -1)
      YFA_CHCC = fad('ATMONEBUL.HAUTE ', -1)
      YFA_CMCC = fad('ATMONEBUL.MOYENN', -1)
      YFA_CLCC = fad('ATMONEBUL.BASSE ', -1)
      YFA_CUGW = fad('SURFTENS.DMOG.ZO', -1)
      YFA_CVGW = fad('SURFTENS.DMOG.ME', -1)
      YFA_CUTO = fad('SURFTENS.TOTA.ZO', -1)
      YFA_CVTO = fad('SURFTENS.TOTA.ME', -1)
      YFA_CE = fad('SURFFLU.MEVAP.EA', -1)
      YFA_CS = fad('SURFFLU.MSUBL.NE', -1)
      YFA_CT = fad('SURFFLU.MTOTA.NE', -1)
      YFA_CLHE = fad('SURFFLU.LAT.MEVA', -1)
      YFA_CLHS = fad('SURFFLU.LAT.MSUB', -1)
      YFA_CLHT = fad('SURFFLU.LAT.MTOT', -1)
      YFA_CWS = fad('SURFCONTENU EAU ', -1)
      YFA_CSNS = fad('SURFRESERV NEIGE', -1)
      YFA_CQTO = fad('ATMOHUMI TOTALE ', -1)
      YFA_CTO3 = fad('ATMOOZONE TOTALE', -1)
      YFA_CTME = fad('TOPMESO ENTH    ', -1)
      YFA_CICE = fad('ATMOHUMI SOLIDE ', -1)
      YFA_CLI = fad('ATMOHUMI LIQUIDE', -1)
      YFA_CCVU = fad('SURFTENS.CONV.ZO', -1)
      YFA_CCVV = fad('SURFTENS.CONV.ME', -1)
      YFA_CCVQ = fad('SURFCFU.Q.CONVEC', -1)
      YFA_CCVS = fad('SURFCFU.CT.CONVE', -1)
      YFA_CTUQ = fad('SURFCFU.Q.TURBUL', -1)
      YFA_CTUS = fad('SURFCFU.CT.TURBU', -1)
      YFA_CSOC = fad('SURFRAYT SOL CL ', -1)
      YFA_CTHC = fad('SURFRAYT THER CL', -1)
      YFA_CSOP = fad('SURFRAYT DIR SUR', -1)
      YFA_CDNI = fad('SURFDIR NORM IRR', -1)
      YFA_CGNI = fad('SURFGLB NORM IRR', -1)
      YFA_CTOP = fad('TOPRAYT DIR SOM ', -1)
      YFA_CSOD = fad('SURFRAYT SOLA DE', -1)
      YFA_CTHD = fad('SURFRAYT THER DE', -1)
      YFA_CFON = fad('SURFFONTE NEIGE ', -1)
      YFA_CCHS = fad('SURFCHAL. DS SOL', -1)
      YFA_CEAS = fad('SURFEAU DANS SOL', -1)
      YFA_CSRU = fad('SURFRUISSELLEMEN', -1)
      YFA_CDRU = fad('PROFRUISSELLEMEN', -1)
      YFA_CIRU = fad('SURFRUISS. INTER', -1)
      YFA_CETP = fad('SURFEVAPOTRANSPI', -1)
      YFA_CTP = fad('SURFTRANSPIRATIO', -1)
      YFA_CSMR = fad('SURFRAYT.LUNE.DE', -1)
      YFA_CTSOC = fad('SOMMRAYT SOL CL ', -1)
      YFA_CTTHC = fad('SOMMRAYT THER CL', -1)
      YFA_CDUTP = fad('SURFTIME.PREC.TO', -1)
      YFA_CFLASH = fad('SURFDIAG.FLASH  ', -1)
      YFA_CAPE = fad('SURFCAPE.POS.F00', -1)
      YFA_CIEN = fad('SURFCIEN.POS.F00', -1)
      YFA_TCVS = fad('SURFTCVS.POS.F00', -1)
      YFA_ASMC = fad('SURFANAMOCON.POS', -1)
      YFA_VSMC = fad('VARPACKSURFMOCON', -1)
      YFA_ACCGREL = fad('SURFACCGRELE    ', -1)
      NVERBOSE = 0
      CMODEL = ''
      NIDCEN = 85
      LEXTERN = .FALSE.
      LSUPPDATE = .FALSE.
    end associate
    metadata%ready = .true.
    status = 0
  end function
end module
