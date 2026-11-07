!> Keep the complete forecast controls in native named storage.
module forecast_controls_state_types
  use iso_c_binding, only: c_int32_t,c_char
  use forecast_model_clock_port, only: forecast_clock_input,forecast_clock
  implicit none
  private
  public :: native_forecast_control_namespace,native_forecast_controls_state
  public :: native_forecast_control_upstream
  !> Dimensionless scalar switches use0 for false and1 for true.
  !! Schedule arrays hold model-step numbers and have source bounds0:960.
  !! Character members retain their full source length, including spaces.
  !! Source names identify every member; no original byte layout is used.
  type :: native_forecast_control_namespace
    integer(c_int32_t) :: nposts(0:960)=0
    integer(c_int32_t) :: nhists(0:960)=0
    integer(c_int32_t) :: ngdits(0:960)=0
    integer(c_int32_t) :: nsdits(0:960)=0
    integer(c_int32_t) :: ndhfgts(0:960)=0
    integer(c_int32_t) :: ndhfzts(0:960)=0
    integer(c_int32_t) :: ndhfdts(0:960)=0
    integer(c_int32_t) :: ndhpts(0:960)=0
    integer(c_int32_t) :: nmasscons(0:960)=0
    character(kind=c_char,len=16) :: cnmexp=' '
    character(kind=c_char,len=128) :: cfpncf=' '
    integer(c_int32_t) :: nopt_memory=0
    character(kind=c_char,len=120) :: cnppath=' '
    character(kind=c_char,len=120) :: cfdirlst=' '
    character(kind=c_char,len=120) :: cndispp=' '
    integer(c_int32_t) :: nconf=0
    integer(c_int32_t) :: ntasks_canari=0
    integer(c_int32_t) :: nquad=0
    integer(c_int32_t) :: n2dini=0
    integer(c_int32_t) :: nsppr=0
    integer(c_int32_t) :: nfrpos=0
    integer(c_int32_t) :: nfrhis=0
    integer(c_int32_t) :: n3dini=0
    integer(c_int32_t) :: nfrgdi=0
    integer(c_int32_t) :: nfrsdi=0
    integer(c_int32_t) :: ncntvar=0
    integer(c_int32_t) :: nfrdhfg=0
    integer(c_int32_t) :: nfrdhfz=0
    integer(c_int32_t) :: nfrdhfd=0
    integer(c_int32_t) :: nfrdhp=0
    integer(c_int32_t) :: nfrco=0
    integer(c_int32_t) :: nfrmasscon=0
    integer(c_int32_t) :: n6bins=0
    integer(c_int32_t) :: lnf=0
    integer(c_int32_t) :: lfdbop=0
    integer(c_int32_t) :: larpegef=0
    integer(c_int32_t) :: lsmssig=0
    character(kind=c_char,len=25) :: cmeter=' '
    character(kind=c_char,len=25) :: cevent=' '
    integer(c_int32_t) :: larpegef_trajhr=0
    integer(c_int32_t) :: larpegef_trajbg=0
    integer(c_int32_t) :: nfpos=0
    integer(c_int32_t) :: lopdis=0
    integer(c_int32_t) :: lcanari=0
    integer(c_int32_t) :: loldpp=0
    integer(c_int32_t) :: lguess=0
    integer(c_int32_t) :: lobs=0
    integer(c_int32_t) :: lobsc1=0
    integer(c_int32_t) :: lobsref=0
    integer(c_int32_t) :: lsimob=0
    integer(c_int32_t) :: lelam=0
    integer(c_int32_t) :: lrplane=0
    integer(c_int32_t) :: lfbdap=0
    integer(c_int32_t) :: lbackg=0
    integer(c_int32_t) :: lminim=0
    integer(c_int32_t) :: lscreen=0
    integer(c_int32_t) :: lrefout=0
    integer(c_int32_t) :: lmonitoring=0
    character(kind=c_char,len=120) :: cscript_ppserver=' '
    character(kind=c_char,len=120) :: cscript_lamrtc=' '
    integer(c_int32_t) :: l_screen_call=0
    integer(c_int32_t) :: l_split_screen=0
    integer(c_int32_t) :: linflat=0
    integer(c_int32_t) :: linflp9=0
    integer(c_int32_t) :: linflf1=0
    integer(c_int32_t) :: lallopr=0
    integer(c_int32_t) :: lrefgen=0
    integer(c_int32_t) :: lifstraj=0
    integer(c_int32_t) :: lifsmin=0
    integer(c_int32_t) :: larome=0
    integer(c_int32_t) :: lecfpos=0
    integer(c_int32_t) :: ninterptraj=0
    integer(c_int32_t) :: ninterpincr=0
    integer(c_int32_t) :: lscreen_openmp=0
    integer(c_int32_t) :: nfrcorm=0
    integer(c_int32_t) :: lsforc=0
    integer(c_int32_t) :: lsforcs=0
    integer(c_int32_t) :: lspbsbal=0
    integer(c_int32_t) :: nsfxhists(0:960)=0
    integer(c_int32_t) :: nfrsfxhis=0
    integer(c_int32_t) :: larpegef_rdgp_init=0
    integer(c_int32_t) :: larpegef_rdgp_trajhr=0
    integer(c_int32_t) :: larpegef_rdgp_trajbg=0
    integer(c_int32_t) :: lcallsfx=0
    integer(c_int32_t) :: lsfxlsm=0
    integer(c_int32_t) :: lr3d=0
    integer(c_int32_t) :: lr2d=0
    integer(c_int32_t) :: lrshw=0
    integer(c_int32_t) :: lrveq=0
    integer(c_int32_t) :: liolevg=0
    integer(c_int32_t) :: lecmwf=0
    integer(c_int32_t) :: lwrspeca_gp=0
    integer(c_int32_t) :: lsuspeca_gp=0
    integer(c_int32_t) :: lwrspeca_gp_uv=0
    integer(c_int32_t) :: lsuspeca_gp_uv=0
    integer(c_int32_t) :: nhistsmin(0:960)=0
    integer(c_int32_t) :: nsfxhistsmin(0:960)=0
    integer(c_int32_t) :: npostsmin(0:960)=0
    integer(c_int32_t) :: lgrib_api=0
    integer(c_int32_t) :: nundefld=0
    integer(c_int32_t) :: lcouplo4=0
    integer(c_int32_t) :: l4dvar=0
    integer(c_int32_t) :: l_oops=0
    integer(c_int32_t) :: niter_adtest=0
    integer(c_int32_t) :: lconserv=0
    integer(c_int32_t) :: lcorwat=0
    integer(c_int32_t) :: ltrajnh=0
    integer(c_int32_t) :: l_obs_in_fc_config=0
  end type
  !> Initial date is YYYYMMDD and seconds is time within the day.
  !! Print level and the number of GRIB files are dimensionless counts.
  type :: native_forecast_control_upstream
    integer(c_int32_t) :: date=0,seconds=0,nprintlev=0,ngribfile=0
  end type
  !> Own one control namespace and the two accepted native clock records.
  !! Clock input and output use seconds and retain their existing named types.
  !! Their source-unwritten preimages are supplied by the fresh owner before
  !! numerical construction; this data-only declaration performs no clock work.
  type :: native_forecast_controls_state
    type(native_forecast_control_namespace) :: namespace
    type(forecast_clock_input) :: clock_input
    type(forecast_clock) :: clock
  end type
end module forecast_controls_state_types
