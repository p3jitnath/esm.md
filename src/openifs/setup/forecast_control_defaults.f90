!> Assign the complete source defaults before live forecast overrides.
module forecast_control_defaults
  use forecast_controls_state_types, only: native_forecast_control_namespace
  implicit none
  private
  public :: initialize_forecast_control_defaults
contains
  !> Publish all108 named default values without allocation or FP arithmetic.
  !! Counts and switches are int32; schedule arrays use bounds0:960.
  !! This is a private-stage producer. The complete configuration parent must
  !! validate live groups and its clock before it publishes caller output.
  subroutine initialize_forecast_control_defaults(output)
    type(native_forecast_control_namespace), intent(inout) :: output
    output%nopt_memory = 2
    output%nconf = 1
    output%ntasks_canari = 1
    output%nquad = 1
    output%n2dini = 1
    output%nsppr = 0
    output%nfrpos = -1
    output%nfrhis = 1
    output%n3dini = 0
    output%nfrgdi = 1
    output%nfrsdi = 24
    output%ncntvar = 1
    output%nfrdhfg = 4
    output%nfrdhfz = 4
    output%nfrdhfd = 4
    output%nfrdhp = 48
    output%nfrco = 0
    output%nfrmasscon = 999999
    output%n6bins = 6
    output%lnf = 1
    output%lfdbop = 1
    output%larpegef = 0
    output%lsmssig = 0
    output%larpegef_trajhr = 0
    output%larpegef_trajbg = 0
    output%nfpos = 0
    output%lopdis = 1
    output%lcanari = 0
    output%loldpp = 1
    output%lguess = 0
    output%lobs = 0
    output%lobsc1 = 0
    output%lobsref = 0
    output%lsimob = 1
    output%lelam = 0
    output%lrplane = 0
    output%lfbdap = 0
    output%lbackg = 0
    output%lminim = 0
    output%lscreen = 0
    output%lrefout = 0
    output%lmonitoring = 0
    output%l_screen_call = 1
    output%l_split_screen = 0
    output%linflat = 0
    output%linflp9 = 0
    output%linflf1 = 0
    output%lallopr = 0
    output%lrefgen = 0
    output%lifstraj = 0
    output%lifsmin = 0
    output%larome = 0
    output%lecfpos = 0
    output%ninterptraj = 1
    output%ninterpincr = 1
    output%lscreen_openmp = 1
    output%nfrcorm = 0
    output%lsforc = 0
    output%lsforcs = 0
    output%lspbsbal = 0
    output%nfrsfxhis = 1
    output%larpegef_rdgp_init = 0
    output%larpegef_rdgp_trajhr = 0
    output%larpegef_rdgp_trajbg = 0
    output%lcallsfx = 1
    output%lsfxlsm = 0
    output%lr3d = 1
    output%lr2d = 0
    output%lrshw = 0
    output%lrveq = 0
    output%liolevg = 1
    output%lecmwf = 1
    output%lwrspeca_gp = 0
    output%lsuspeca_gp = 0
    output%lwrspeca_gp_uv = 0
    output%lsuspeca_gp_uv = 0
    output%lgrib_api = 1
    output%nundefld = -99999999
    output%lcouplo4 = 0
    output%l4dvar = 0
    output%l_oops = 0
    output%niter_adtest = 1
    output%lconserv = 0
    output%lcorwat = 0
    output%ltrajnh = 0
    output%l_obs_in_fc_config = 0
    output%nposts = 0
    output%nhists = 0
    output%ngdits = 0
    output%nsdits = 0
    output%ndhfgts = 0
    output%ndhfzts = 0
    output%ndhfdts = 0
    output%ndhpts = 0
    output%nmasscons = 0
    output%nsfxhists = 0
    output%nhistsmin = 0
    output%nsfxhistsmin = 0
    output%npostsmin = 0
    output%cnmexp = '0123'
    output%cfpncf = 'ncf927'
    output%cnppath = ''
    output%cfdirlst = ''
    output%cndispp = ''
    output%cmeter = 'smsmeter'
    output%cevent = 'smsevent'
    output%cscript_ppserver = 'cnt3_wait'
    output%cscript_lamrtc = 'atcp'
  end subroutine
end module forecast_control_defaults
