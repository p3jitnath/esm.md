!> Own the model carrier at its final address and publish fifteen typed aliases.
!> INITIAL is borrowed and remains at its original address until release.
!> This storage stage supplies named fresh records, not physical parameters.
!> The caller then runs the separate seventeen-stage in-place initializer.
module forecast_selected_model_storage
  use iso_fortran_env, only: int32, real64
  use ieee_exceptions, only: ieee_status_type
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_meteo_france_physics_state, only: owned_meteo_france_physics_state, initialize_fresh_meteo_france_physics_state
  use forecast_fresh_physics_configuration, only: initialize_fresh_physics_configuration
  use forecast_fresh_model_physics_records, only: initialize_fresh_model_physics_records
  use forecast_fresh_inactive_configuration, only: initialize_fresh_inactive_configuration_records
  use forecast_fresh_ecmwf_parameter_state, only: initialize_fresh_ecmwf_parameter_records
  use forecast_in_place_model_configuration, only: release_operational_model_configuration_contents
  use yomdphy, only: tdphy
  use grid_field_configuration_types_port, only: grid_field_configuration
  use yoerad, only: terad
  use yoeaeratm, only: teaeratm
  use yoephli, only: tephli
  use yoeaerlid, only: teaerlid
  use yoeaersnk, only: teaersnk
  use yoeaersrc, only: teaersrc
  use yoeaervol, only: teaervol
  use yoephy, only: tephy
  use yomphy, only: tphy
  use yomphy0, only: tphy0
  use yomphy1, only: tphy1
  use yomphy2, only: tphy2
  use yomphyds, only: tphyds
  use yomlouis, only: tlouis
  implicit none
  private
  public :: native_selected_model_storage, native_model_parameter_aliases, &
            create_selected_model_storage, release_selected_model_storage, model_parameter_aliases_match
  type native_model_parameter_aliases
    type(tdphy), pointer :: yrdphy => null()
    type(grid_field_configuration), pointer :: ygfl => null()
    type(terad), pointer :: yrerad => null()
    type(teaeratm), pointer :: yreaeratm => null()
    type(tephli), pointer :: yrephli => null()
    type(teaerlid), pointer :: yreaerlid => null()
    type(teaersnk), pointer :: yreaersnk => null()
    type(teaersrc), pointer :: yreaersrc => null()
    type(teaervol), pointer :: yreaervol => null()
    type(tephy), pointer :: yrephy => null()
    type(tphy), pointer :: yrphy => null()
    type(tphy0), pointer :: yrphy0 => null()
    type(tphy1), pointer :: yrphy1 => null()
    type(tphy2), pointer :: yrphy2 => null()
    type(tlouis), pointer :: yrlouis => null()
  end type
  type native_selected_model_storage
    type(native_operational_model_configuration) :: model
    type(native_ecmwf_physics_state) :: ecmwf
    type(owned_meteo_france_physics_state) :: meteo_france
    type(tphyds) :: physics_field_descriptions
    type(tlouis) :: louis
    logical :: linear_model = .false.
    integer(int32) :: object_id = 0
    character(len=17) :: object_name = ' '
    type(native_model_parameter_aliases) :: aliases
  end type
contains
  !> Allocate this native outer target once, then bind aliases before science.
  !> Status1 is allocation failure; status2 refuses occupied output or fresh state.
  integer(int32) function create_selected_model_storage(output, initial) result(status)
    type(native_selected_model_storage), allocatable, target, intent(inout) :: output
    type(native_initial_geometry_state), target, intent(inout) :: initial
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error, s
    integer :: allocation_status
    status = 2
    if (allocated(output)) return
    call save_lifetime_status(saved, saved_error)
    allocate (output, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      call restore_lifetime_status(saved, saved_error)
      return
    end if
    output%model%initial => initial
    s = initialize_fresh_physics_configuration(output%model%physics)
    if (s /= 0) goto900
    s = initialize_fresh_model_physics_records(output%model%field_dimensions, &
                                               output%model%physics_dimensions, output%model%physics_auxiliary)
    if (s /= 0) goto900
    s = initialize_fresh_inactive_configuration_records(output%model%nudging, output%model%climate)
    if (s /= 0) goto900
    s = initialize_fresh_ecmwf_parameter_records(output%ecmwf)
    if (s /= 0) goto900
    s = initialize_fresh_meteo_france_physics_state(output%meteo_france)
    if (s /= 0) goto900
    call initialize_named_alias_preimages(output)
    output%model%physics%mse%LPGDFWR = .false.
    output%model%physics%mse%LHISFWR = .true.
    output%model%physics%mse%LFTZERO = .true.
    output%model%physics%mse%NSURFEXCTLMAX = 3_int32
    output%model%physics%mse%NSURFEXCTL = 3_int32
    output%model%physics%mse%CPREFIX_SFX1 = 'SFX.'
    output%model%physics%mse%CPREFIX_SFX2 = 'X   '
    output%model%physics%mse%XZSEPS = 0.01_real64
    output%model%physics%ecmwf_physics%LFPOS_EC_PHYS = .false.
    call bind_model_parameter_aliases(output)
    status = 0
    call restore_lifetime_status(saved, saved_error)
    return
900 continue
    deallocate (output)
    status = 2
    call restore_lifetime_status(saved, saved_error)
  end function
  !> Supply only named scalar/fixed-array zero-born preimages in the nine aliases.
  !> Allocatable descriptors remain compiler-created and absent. No raw padding
  !> or public numerical method supplies a value.
  subroutine initialize_named_alias_preimages(output)
    type(native_selected_model_storage), intent(inout) :: output
    output%ecmwf%radiation%radiation%NAER = 0_int32
    output%ecmwf%radiation%radiation%NMODE = 0_int32
    output%ecmwf%radiation%radiation%NOZOCL = 0_int32
    output%ecmwf%radiation%radiation%NRADFR = 0_int32
    output%ecmwf%radiation%radiation%NRADPFR = 0_int32
    output%ecmwf%radiation%radiation%NRADPLA = 0_int32
    output%ecmwf%radiation%radiation%NRADINT = 0_int32
    output%ecmwf%radiation%radiation%NRADRES = 0_int32
    output%ecmwf%radiation%radiation%NRADNFR = 0_int32
    output%ecmwf%radiation%radiation%NRADSFR = 0_int32
    output%ecmwf%radiation%radiation%NRADE1H = 0_int32
    output%ecmwf%radiation%radiation%NRADE3H = 0_int32
    output%ecmwf%radiation%radiation%NRADELG = 0_int32
    output%ecmwf%radiation%radiation%NOVLP = 0_int32
    output%ecmwf%radiation%radiation%NRPROMA = 0_int32
    output%ecmwf%radiation%radiation%NSW = 0_int32
    output%ecmwf%radiation%radiation%NSWNL = 0_int32
    output%ecmwf%radiation%radiation%NSWTL = 0_int32
    output%ecmwf%radiation%radiation%NLWEMISS = 0_int32
    output%ecmwf%radiation%radiation%NLWOUT = 0_int32
    output%ecmwf%radiation%radiation%NTSW = 0_int32
    output%ecmwf%radiation%radiation%NUV = 0_int32
    output%ecmwf%radiation%radiation%NCSRADF = 0_int32
    output%ecmwf%radiation%radiation%NICEOPT = 0_int32
    output%ecmwf%radiation%radiation%NLIQOPT = 0_int32
    output%ecmwf%radiation%radiation%NSWICEOPT = 0_int32
    output%ecmwf%radiation%radiation%NSWLIQOPT = 0_int32
    output%ecmwf%radiation%radiation%NLWICEOPT = 0_int32
    output%ecmwf%radiation%radiation%NLWLIQOPT = 0_int32
    output%ecmwf%radiation%radiation%NRADIP = 0_int32
    output%ecmwf%radiation%radiation%NRADLP = 0_int32
    output%ecmwf%radiation%radiation%NINHOM = 0_int32
    output%ecmwf%radiation%radiation%NLAYINH = 0_int32
    output%ecmwf%radiation%radiation%NLNGR1H = 0_int32
    output%ecmwf%radiation%radiation%NPERTAER = 0_int32
    output%ecmwf%radiation%radiation%NPERTOZ = 0_int32
    output%ecmwf%radiation%radiation%NSCEN = 0_int32
    output%ecmwf%radiation%radiation%NHINCSOL = 0_int32
    output%ecmwf%radiation%radiation%NMCICA = 0_int32
    output%ecmwf%radiation%radiation%NGHGRAD = 0_int32
    output%ecmwf%radiation%radiation%NDECOLAT = 0_int32
    output%ecmwf%radiation%radiation%NMINICE = 0_int32
    output%ecmwf%radiation%radiation%NVOLCVERT = 0_int32
    output%ecmwf%radiation%radiation%NREDGLW = 0_int32
    output%ecmwf%radiation%radiation%NREDGSW = 0_int32
    output%ecmwf%radiation%radiation%NAERMACC = 0_int32
    output%ecmwf%radiation%radiation%NMCLAT = 0_int32
    output%ecmwf%radiation%radiation%NMCLON = 0_int32
    output%ecmwf%radiation%radiation%NMCLEV = 0_int32
    output%ecmwf%radiation%radiation%NMCVAR = 0_int32
    output%ecmwf%radiation%radiation%NSPMAPL = 0_int32
    output%ecmwf%radiation%radiation%NSPMAPS = 0_int32
    output%ecmwf%radiation%radiation%NLWSCATTERING = 0_int32
    output%ecmwf%radiation%radiation%NSWSOLVER = 0_int32
    output%ecmwf%radiation%radiation%NLWSOLVER = 0_int32
    output%ecmwf%radiation%radiation%KMODTS = 0_int32
    output%ecmwf%radiation%radiation%NSOLARSPECTRUM = 0_int32
    output%ecmwf%radiation%radiation%NSWWVCONTINUUM = 0_int32
    output%ecmwf%radiation%radiation%NDUMPBADINPUTS = 0_int32
    output%ecmwf%radiation%radiation%NDUMPINPUTS = 0_int32
    output%ecmwf%radiation%radiation%NCLOUDOVERLAP = 0_int32
    output%ecmwf%radiation%radiation%RCLOUD_FRAC_STD = 0.0_real64
    output%ecmwf%radiation%radiation%RCLOUD_SEPARATION_SCALE_TOA = 0.0_real64
    output%ecmwf%radiation%radiation%RCLOUD_SEPARATION_SCALE_SURF = 0.0_real64
    output%ecmwf%radiation%radiation%LFU_LW_ICE_OPTICS_BUG = .false.
    output%ecmwf%radiation%radiation%LINTERPINCLOUDMEAN = .false.
    output%ecmwf%radiation%radiation%LERAD1H = .false.
    output%ecmwf%radiation%radiation%LEPO3RA = .false.
    output%ecmwf%radiation%radiation%LONEWSW = .false.
    output%ecmwf%radiation%radiation%LECSRAD = .false.
    output%ecmwf%radiation%radiation%LRRTM = .false.
    output%ecmwf%radiation%radiation%LSRTM = .false.
    output%ecmwf%radiation%radiation%LDIFFC = .false.
    output%ecmwf%radiation%radiation%LHVOLCA = .false.
    output%ecmwf%radiation%radiation%LNEWAER = .false.
    output%ecmwf%radiation%radiation%LNOTROAER = .false.
    output%ecmwf%radiation%radiation%LRAYL = .false.
    output%ecmwf%radiation%radiation%LOPTRPROMA = .false.
    output%ecmwf%radiation%radiation%LECO2VAR = .false.
    output%ecmwf%radiation%radiation%LHGHG = .false.
    output%ecmwf%radiation%radiation%LESO4HIS = .false.
    output%ecmwf%radiation%radiation%LETRACGMS = .false.
    output%ecmwf%radiation%radiation%LAERCLIM = .false.
    output%ecmwf%radiation%radiation%LAERVISI = .false.
    output%ecmwf%radiation%radiation%LAER3D = .false.
    output%ecmwf%radiation%radiation%LVOLCSPEC = .false.
    output%ecmwf%radiation%radiation%LVOLCDAMP = .false.
    output%ecmwf%radiation%radiation%LDIAGFORCING = .false.
    output%ecmwf%radiation%radiation%LAERADCLI = .false.
    output%ecmwf%radiation%radiation%LAERADJDU = .false.
    output%ecmwf%radiation%radiation%LAPPROXLWUPDATE = .false.
    output%ecmwf%radiation%radiation%LAPPROXSWUPDATE = .false.
    output%ecmwf%radiation%radiation%LMANNERSSWUPDATE = .false.
    output%ecmwf%radiation%radiation%LCENTREDTIMESZA = .false.
    output%ecmwf%radiation%radiation%LAVERAGESZA = .false.
    output%ecmwf%radiation%radiation%LECOMPGRID = .false.
    output%ecmwf%radiation%radiation%LUSEPRE2017RAD = .false.
    output%ecmwf%radiation%radiation%LDUSEASON = .false.
    output%ecmwf%radiation%radiation%LCCNL = .false.
    output%ecmwf%radiation%radiation%LCCNO = .false.
    output%ecmwf%radiation%radiation%LPERPET = .false.
    output%ecmwf%radiation%radiation%RAOVLP = 0.0_real64
    output%ecmwf%radiation%radiation%RBOVLP = 0.0_real64
    output%ecmwf%radiation%radiation%RCCNLND = 0.0_real64
    output%ecmwf%radiation%radiation%RCCNSEA = 0.0_real64
    output%ecmwf%radiation%radiation%LEDBUG = .false.
    output%ecmwf%radiation%radiation%RPERTOZ = 0.0_real64
    output%ecmwf%radiation%radiation%RRE2DE = 0.0_real64
    output%ecmwf%radiation%radiation%RLWINHF = 0.0_real64
    output%ecmwf%radiation%radiation%RSWINHF = 0.0_real64
    output%ecmwf%radiation%radiation%RMINICE = 0.0_real64
    output%ecmwf%radiation%radiation%RVOLCSPEC = 0.0_real64
    output%ecmwf%radiation%radiation%RNS = 0.0_real64
    output%ecmwf%radiation%radiation%RSIGAIR = 0.0_real64
    output%ecmwf%radiation%radiation%RAESHSS = 0.0_real64
    output%ecmwf%radiation%radiation%RAESHDU = 0.0_real64
    output%ecmwf%radiation%radiation%RAESHOM = 0.0_real64
    output%ecmwf%radiation%radiation%RAESHBC = 0.0_real64
    output%ecmwf%radiation%radiation%RAESHSU = 0.0_real64
    output%ecmwf%radiation%radiation%TRBKG = 0.0_real64
    output%ecmwf%radiation%radiation%STBKG = 0.0_real64
    output%ecmwf%radiation%radiation%CGHGCLIMFILE = repeat(achar(0), len(output%ecmwf%radiation%radiation%CGHGCLIMFILE))
    output%ecmwf%radiation%radiation%CGHGTIMESERIESFILE = repeat(achar(0), len(output%ecmwf%radiation%radiation%CGHGTIMESERIESFILE))
output%ecmwf%radiation%radiation%CSOLARIRRADIANCEFILE = repeat(achar(0), len(output%ecmwf%radiation%radiation%CSOLARIRRADIANCEFILE))
    output%ecmwf%radiation%aerosol_atmosphere%NAERCONF = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NINIDAY = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NXT3DAER = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NDD1 = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NSS1 = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NBCOPTP = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NDDOPTP = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NOMOPTP = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NSSOPTP = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NSUOPTP = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NVISWL = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NTAER = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NTYPAER = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NAER_BLNUCL = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%NAERSCAV = 0_int32
    output%ecmwf%radiation%aerosol_atmosphere%RGRATE = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%REPSCAER = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%LAERCLIMG = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERCLIMZ = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERCLIST = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERDRYDP = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERHYGRO = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERLISI = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERNGAT = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERSEDIM = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERSURF = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERELVS = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAER6SDIA = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERSEDIMSS = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERGTOP = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERRAD = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERCCN = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAEROPT = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERINIT = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERVOL = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERCSTR = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERDIAG1 = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERDIAG2 = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERRRTM = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERUVP = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAEREXTR = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERGBUD = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERPRNT = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERNITRATE = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LSEASALT_RH80 = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERDUSTSOURCE = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERDUSTSIZEVAR = .false.
    output%ecmwf%radiation%aerosol_atmosphere%LAERDUST_NEWBIN = .false.
    output%ecmwf%radiation%aerosol_atmosphere%RSS_DRY_DIAFAC = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%RSS_DRY_DENSFAC = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%RSS_DRY_MASSFAC = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%RSS_RH80_DIAFAC = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%RSS_RH80_DENSFAC = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%RSS_RH80_MASSFAC = 0.0_real64
    output%ecmwf%radiation%aerosol_atmosphere%RAERDUST_REBOUND = 0.0_real64
    nullify (output%ecmwf%radiation%aerosol_atmosphere%YAERO_DESC)
    output%ecmwf%radiation%aerosol_lidar%NAELID = 0_int32
    output%ecmwf%radiation%aerosol_lidar%NWLID = 0_int32
    output%ecmwf%radiation%aerosol_lidar%NAERLISI = 0_int32
    output%ecmwf%radiation%aerosol_lidar%JWLID = 0_int32
    output%ecmwf%radiation%aerosol_lidar%RWLID = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLICO2 = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLIO2 = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLINO2 = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLIO3 = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLICLS = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLIDELT = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLINS = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLIPREF = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLITREF = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLIT0 = 0.0_real64
    output%ecmwf%radiation%aerosol_lidar%RLIDDZ = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%NDRYDEPVEL_DYN = 0_int32
    output%ecmwf%radiation%aerosol_sinks%NDRYDEP = 0_int32
    output%ecmwf%radiation%aerosol_sinks%R_R = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%R_S = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RAERTS = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RFRAER = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RRHTAB = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RSSGROWTH_RHTAB = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RSSDENS_RHTAB = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RMMD_DD = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RRHO_DD = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RMMD_NI = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RRHO_NI = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RMMD_SS = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RRHO_SS = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RHO_WAT = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RHO_ICE = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RHAMAKER = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RSO2CV1 = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RSO2CV2 = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RSUCV1 = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RSUCV2 = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RVSO2CV1 = 0.0_real64
    output%ecmwf%radiation%aerosol_sinks%RVSO2CV2 = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%NDDUST = 0_int32
    output%ecmwf%radiation%aerosol_sources%NSSALT = 0_int32
    output%ecmwf%radiation%aerosol_sources%NAERWND = 0_int32
    output%ecmwf%radiation%aerosol_sources%NDMSO = 0_int32
    output%ecmwf%radiation%aerosol_sources%NPIST = 0_int32
    output%ecmwf%radiation%aerosol_sources%NSO4SCHEME = 0_int32
    output%ecmwf%radiation%aerosol_sources%LEPAERO = .false.
    output%ecmwf%radiation%aerosol_sources%LAEROMIN = .false.
    output%ecmwf%radiation%aerosol_sources%LOCNDMS = .false.
    output%ecmwf%radiation%aerosol_sources%RGELAV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RGEMUV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RDGLAV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RDGMUV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RCLONV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RSLONV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RDCLONV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RDSLONV = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RLATVOL = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RLONVOL = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RFCTDU = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RFCTSS = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RFCTDUR = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RFCTSSR = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RAERDUB = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RDMSMIN = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RCODECA = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RSIDECA = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RCOVSRA = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RSIVSRA = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RSSFLX = 0.0_real64
    output%ecmwf%radiation%aerosol_sources%RDDUSRC = 0.0_real64
    output%ecmwf%radiation%aerosol_volume%NAERVOLC = 0_int32
    output%ecmwf%radiation%aerosol_volume%NAERVOLE = 0_int32
    output%ecmwf%radiation%aerosol_volume%NINTERPT = 0_int32
    output%ecmwf%radiation%aerosol_volume%NTVOLC = 0_int32
    output%ecmwf%radiation%aerosol_volume%NVOLERUP = 0_int32
    output%ecmwf%radiation%aerosol_volume%NVOLHOMO = 0_int32
    output%ecmwf%radiation%aerosol_volume%NVOLOPTP = 0_int32
    output%ecmwf%radiation%aerosol_volume%NVOLERUZ = 0_int32
    output%ecmwf%radiation%aerosol_volume%NVOLDATS = 0_int32
    output%ecmwf%radiation%aerosol_volume%NVOLDATE = 0_int32
    output%ecmwf%radiation%aerosol_volume%RAERVOLC = 0.0_real64
    output%ecmwf%radiation%aerosol_volume%RAERVOLE = 0.0_real64
    output%ecmwf%radiation%aerosol_volume%RVOLERUZ = 0.0_real64
    output%ecmwf%radiation%aerosol_volume%RVSEDVOL = 0.0_real64
    output%ecmwf%radiation%aerosol_volume%RVDEPVOL = 0.0_real64
    output%ecmwf%radiation%aerosol_volume%RWDEPVOL = 0.0_real64
    output%louis%RLOUIS_S0 = 0.0_real64
    output%louis%PLOUIS_S0 = 0.0_real64
    output%louis%RLOUIS_GU1 = 0.0_real64
    output%louis%RLOUIS_GU2 = 0.0_real64
    output%louis%PLOUIS_GU1 = 0.0_real64
    output%louis%PLOUIS_GU2 = 0.0_real64
    output%louis%RLOUIS_GS1 = 0.0_real64
    output%louis%RLOUIS_GS2 = 0.0_real64
    output%louis%RLOUIS_GS3 = 0.0_real64
    output%louis%RLOUIS_GS4 = 0.0_real64
    output%louis%PLOUIS_GS1 = 0.0_real64
    output%louis%PLOUIS_GS2 = 0.0_real64
    output%louis%PLOUIS_GS3 = 0.0_real64
    output%louis%PLOUIS_GS4 = 0.0_real64
    output%physics_field_descriptions%JPVXP = 0_int32
    output%physics_field_descriptions%JPVXP2 = 0_int32
    output%physics_field_descriptions%JPCXP = 0_int32
    output%physics_field_descriptions%JPVEXTR = 0_int32
    output%physics_field_descriptions%JPVEXTRDI = 0_int32
    output%physics_field_descriptions%JPVXTR2 = 0_int32
    output%physics_field_descriptions%JPVPRECIP = 0_int32
    output%physics_field_descriptions%JPVPRECIP2 = 0_int32
    output%physics_field_descriptions%CEXTRP = repeat(achar(0), len(output%physics_field_descriptions%CEXTRP))
    output%physics_field_descriptions%CXTRP2 = repeat(achar(0), len(output%physics_field_descriptions%CXTRP2))
    output%physics_field_descriptions%CVEXTRA = repeat(achar(0), len(output%physics_field_descriptions%CVEXTRA))
    output%physics_field_descriptions%CVEXRAD = repeat(achar(0), len(output%physics_field_descriptions%CVEXRAD))
    output%physics_field_descriptions%CVEXTRDI = repeat(achar(0), len(output%physics_field_descriptions%CVEXTRDI))
    output%physics_field_descriptions%CVEXTR2 = repeat(achar(0), len(output%physics_field_descriptions%CVEXTR2))
    output%physics_field_descriptions%CVPRECIP = repeat(achar(0), len(output%physics_field_descriptions%CVPRECIP))
    output%physics_field_descriptions%CVPRECIP2 = repeat(achar(0), len(output%physics_field_descriptions%CVPRECIP2))
    output%physics_field_descriptions%NEXTRPGB = 0_int32
    output%physics_field_descriptions%NXTRP2GB = 0_int32
    output%physics_field_descriptions%NVEXTRAGB = 0_int32
    output%physics_field_descriptions%NVEXRADGB = 0_int32
    output%physics_field_descriptions%NVEXTR2GB = 0_int32
    output%physics_field_descriptions%NVEXTRDIGB = 0_int32
    output%physics_field_descriptions%NVPRECIPGB = 0_int32
    output%physics_field_descriptions%NVPRECIPGB2 = 0_int32
    output%physics_field_descriptions%NSFLUX = 0_int32
    output%physics_field_descriptions%NSFORC = 0_int32
    output%physics_field_descriptions%EXTRPDF = 0.0_real64
    output%physics_field_descriptions%XTRP2DF = 0.0_real64
    output%physics_field_descriptions%VEXTRADF = 0.0_real64
    output%physics_field_descriptions%VEXRADDF = 0.0_real64
    output%physics_field_descriptions%VEXTR2DF = 0.0_real64
    output%physics_field_descriptions%VEXTRDI = 0.0_real64
    output%physics_field_descriptions%VPRECIP = 0.0_real64
    output%physics_field_descriptions%VPRECIP2 = 0.0_real64
    output%physics_field_descriptions%LREQIN_VEXTRDI = .false.
    output%physics_field_descriptions%LREQOUT_VEXTRDI = .false.
    output%ecmwf%radiation%radiation%YSPECTPLANCK%NINTERVALS = 0_int32
    output%ecmwf%radiation%radiation%YSPECTPLANCK%NTEMPS = 0_int32
    output%ecmwf%radiation%radiation%YSPECTPLANCK%TEMP1 = 0.0_real64
    output%ecmwf%radiation%radiation%YSPECTPLANCK%DTEMP = 0.0_real64

    output%physics_field_descriptions%JPVXP = 20_int32
    output%physics_field_descriptions%JPVXP2 = 50_int32
    output%physics_field_descriptions%JPCXP = 50_int32
    output%physics_field_descriptions%JPVEXTR = 99_int32
    output%physics_field_descriptions%JPVEXTRDI = 99_int32
    output%physics_field_descriptions%JPVXTR2 = 99_int32
    output%physics_field_descriptions%JPVPRECIP = 99_int32
    output%physics_field_descriptions%JPVPRECIP2 = 99_int32
  end subroutine
  subroutine bind_model_parameter_aliases(output)
    type(native_selected_model_storage), target, intent(inout) :: output
    output%aliases%yrdphy => output%model%physics_dimensions
    output%aliases%ygfl => output%model%fields
    output%aliases%yrerad => output%ecmwf%radiation%radiation
    output%aliases%yreaeratm => output%ecmwf%radiation%aerosol_atmosphere
    output%aliases%yrephli => output%model%physics%linear_ecmwf
    output%aliases%yreaerlid => output%ecmwf%radiation%aerosol_lidar
    output%aliases%yreaersnk => output%ecmwf%radiation%aerosol_sinks
    output%aliases%yreaersrc => output%ecmwf%radiation%aerosol_sources
    output%aliases%yreaervol => output%ecmwf%radiation%aerosol_volume
    output%aliases%yrephy => output%model%physics%ecmwf_physics
    output%aliases%yrphy => output%model%physics%phy
    output%aliases%yrphy0 => output%meteo_france%atmospheric_parameters
    output%aliases%yrphy1 => output%meteo_france%surface_exchange_parameters
    output%aliases%yrphy2 => output%model%physics_auxiliary
    output%aliases%yrlouis => output%louis
  end subroutine
  logical function model_parameter_aliases_match(output) result(matched)
    type(native_selected_model_storage), target, intent(in) :: output
    matched = .false.
    if (.not. associated(output%aliases%yrdphy, output%model%physics_dimensions)) return
    if (.not. associated(output%aliases%ygfl, output%model%fields)) return
    if (.not. associated(output%aliases%yrerad, output%ecmwf%radiation%radiation)) return
    if (.not. associated(output%aliases%yreaeratm, output%ecmwf%radiation%aerosol_atmosphere)) return
    if (.not. associated(output%aliases%yrephli, output%model%physics%linear_ecmwf)) return
    if (.not. associated(output%aliases%yreaerlid, output%ecmwf%radiation%aerosol_lidar)) return
    if (.not. associated(output%aliases%yreaersnk, output%ecmwf%radiation%aerosol_sinks)) return
    if (.not. associated(output%aliases%yreaersrc, output%ecmwf%radiation%aerosol_sources)) return
    if (.not. associated(output%aliases%yreaervol, output%ecmwf%radiation%aerosol_volume)) return
    if (.not. associated(output%aliases%yrephy, output%model%physics%ecmwf_physics)) return
    if (.not. associated(output%aliases%yrphy, output%model%physics%phy)) return
    if (.not. associated(output%aliases%yrphy0, output%meteo_france%atmospheric_parameters)) return
    if (.not. associated(output%aliases%yrphy1, output%meteo_france%surface_exchange_parameters)) return
    if (.not. associated(output%aliases%yrphy2, output%model%physics_auxiliary)) return
    if (.not. associated(output%aliases%yrlouis, output%louis)) return
    matched = .true.
  end function

  !> Release after the field, physics and other dependent owners have closed.
  !> A changed alias or live dependent state is refused without dropping aliases.
  integer(int32) function release_selected_model_storage(output) result(status)
    type(native_selected_model_storage), allocatable, target, intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error, s
    status = 0
    if (.not. allocated(output)) return
    status = 2
    if (.not. model_parameter_aliases_match(output)) return
    if (output%ecmwf%cloud_eta_acquired .or. output%ecmwf%optimization_acquired) return
    if (output%ecmwf%radiation_attempted .or. output%ecmwf%surface_acquired .or. output%ecmwf%setup_complete) return
    if (associated(output%ecmwf%surface)) return
    if (allocated(output%ecmwf%cloud%CETA)) return
    if(output%ecmwf%radiation%context_ready.or.output%ecmwf%radiation%storage_ready.or.output%ecmwf%radiation%setup_complete)return
    if (output%meteo_france%setup_complete) return
    if (allocated(output%meteo_france%top_atmosphere_parameters%rmesou)) return
    if (allocated(output%meteo_france%top_atmosphere_parameters%rmesot)) return
    if (allocated(output%meteo_france%top_atmosphere_parameters%rmesoq)) return
    if (allocated(output%meteo_france%alternative_parameters%xsw_bands)) return
    call save_lifetime_status(saved, saved_error)
    s = release_operational_model_configuration_contents(output%model)
    if (s /= 0) then
      call restore_lifetime_status(saved, saved_error)
      return
    end if
    nullify (output%aliases%yrdphy)
    nullify (output%aliases%ygfl)
    nullify (output%aliases%yrerad)
    nullify (output%aliases%yreaeratm)
    nullify (output%aliases%yrephli)
    nullify (output%aliases%yreaerlid)
    nullify (output%aliases%yreaersnk)
    nullify (output%aliases%yreaersrc)
    nullify (output%aliases%yreaervol)
    nullify (output%aliases%yrephy)
    nullify (output%aliases%yrphy)
    nullify (output%aliases%yrphy0)
    nullify (output%aliases%yrphy1)
    nullify (output%aliases%yrphy2)
    nullify (output%aliases%yrlouis)
    deallocate (output)
    status = 0
    call restore_lifetime_status(saved, saved_error)
  end function
end module forecast_selected_model_storage
