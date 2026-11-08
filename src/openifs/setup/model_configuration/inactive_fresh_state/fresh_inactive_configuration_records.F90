!> Define the named fresh values for inactive model configuration records.
!! The caller owns both canonical native records. All thirteen climate
!! allocatable owners must be absent; a live owner gives status 2 before
!! either record changes. Status 0 means the named values are defined.
!! Native compiler padding is not qualified by this source-only helper.
module forecast_fresh_inactive_configuration
  use iso_fortran_env, only: int32, real64
  use native_inactive_startup_controls, only: native_nudging_controls, native_climate_coupling_controls
  implicit none
  private
  public :: initialize_fresh_inactive_configuration_records
contains
  !> Set formerly undefined named fields to their source fresh values.
  !! NUDGING and CLIMATE are caller-owned INOUT scalar records. Fixed arrays
  !! are XNUVERT(200), NCLIGC(19), and NCLIAER(16); the one 128-character
  !! filename starts with NUL characters. Zero values precede the later
  !! physical setup, which supplies each coefficient in its source units.
  !! This entry neither allocates arrays nor applies the later 59 defaults.
  integer(int32) function initialize_fresh_inactive_configuration_records(nudging, climate) result(status)
    type(native_nudging_controls), intent(inout) :: nudging
    type(native_climate_coupling_controls), intent(inout) :: climate
    status = 2_int32
    if (allocated(climate%ncligc_compo)) return
    if (allocated(climate%nysdmp_compo)) return
    if (allocated(climate%climrco2)) return
    if (allocated(climate%climraer)) return
    if (allocated(climate%climrcompo)) return
    if (allocated(climate%zlake)) return
    if (allocated(climate%oceanbc)) return
    if (allocated(climate%climr)) return
    if (allocated(climate%rnemolvls)) return
    if (allocated(climate%rnemomask)) return
    if (allocated(climate%partsst0)) return
    if (allocated(climate%partmask)) return
    if (allocated(climate%cplng_fld)) return
    nudging = native_nudging_controls( &
              nfnudg=0_int32, &
              nfrnudg=0_int32, &
              ntnudg=0_int32, &
              ntotfnudg3=0_int32, &
              ntotfnudg2=0_int32, &
              nspnu1=0_int32, &
              nspnu2=0_int32, &
              lnudg=.false., &
              lnuddi=.false., &
              lnudlp=.false., &
              lnudrm=.false., &
              lnudsd=.false., &
              lnudsh=.false., &
              lnudsm=.false., &
              lnudst=.false., &
              lnudsv=.false., &
              lnudte=.false., &
              lnudvo=.false., &
              lndriv=.false., &
              lnudtg=.false., &
              lnudqg=.false., &
              lnudug=.false., &
              lnudvg=.false., &
              lnudpg=.false., &
              lwnudg=.false., &
              xnuvert=spread(0.0_real64, 1, size(nudging%xnuvert)), &
              xnuddi=0.0_real64, &
              xnudlp=0.0_real64, &
              xnudrm=0.0_real64, &
              xnudsd=0.0_real64, &
              xnudsh=0.0_real64, &
              xnudsm=0.0_real64, &
              xnudst=0.0_real64, &
              xnudsv=0.0_real64, &
              xnudte=0.0_real64, &
              xnudvo=0.0_real64, &
              xnudtg=0.0_real64, &
              xnudqg=0.0_real64, &
              xnudug=0.0_real64, &
              xnudvg=0.0_real64, &
              xnudpg=0.0_real64)
    climate = native_climate_coupling_controls( &
              n923=0_int32, &
              nclimtot=0_int32, &
              nclimr=0_int32, &
              ncligc=spread(0_int32, 1, size(climate%ncligc)), &
              nclimr_compo=0_int32, &
              ncliaer=spread(0_int32, 1, size(climate%ncliaer)), &
              ndifc=0_int32, &
              njdcr=0_int32, &
              njdcr1=0_int32, &
              ndifc_compo=0_int32, &
              njdcr_compo=0_int32, &
              njdcr1_compo=0_int32, &
              np1=0_int32, &
              np2=0_int32, &
              npco2_1=0_int32, &
              npco2_2=0_int32, &
              npaer_1=0_int32, &
              npaer_2=0_int32, &
              npcompo_1=0_int32, &
              npcompo_2=0_int32, &
              nunitc=0_int32, &
              nunitc1=0_int32, &
              nunitcm=0_int32, &
              noacomm=0_int32, &
              nssticeop=0_int32, &
              lfirstupd=.false., &
              lcurr=.false., &
              lgelato=.false., &
              lmcc01_mse=.false., &
              lmcc01=.false., &
              lmcc02=.false., &
              lmcc03=.false., &
              lmcc04=.false., &
              lmcc05=.false., &
              lmcc06=.false., &
              lmccec=.false., &
              lmcciec=.false., &
              lmcciec_compo=.false., &
              lmcciceic=.false., &
              lmccdynseaice=.false., &
              lnemocoup=.false., &
              lnemofluxnc=.false., &
              lnemooutgrb=.false., &
              lcoupinfout=.false., &
              lnemo1way=.false., &
              lnemoifslog=.false., &
              lnemosstfreez=.false., &
              lnemogribflds=.false., &
              lnemogribmask=.false., &
              l2decv2nemo=.false., &
              lmultiyr=.false., &
              lmcc_compo=.false., &
              nfrcpl=0_int32, &
              lnemolimget=.false., &
              lnemolimput=.false., &
              lnemolimalb=.false., &
              lnemolimtemp=.false., &
              lnemolimtlvl=.false., &
              lnemolimthk=.false., &
              lnemosicoup=.false., &
              lnemoatmflds=.false., &
              lnemooceicemix=.false., &
              lnemoqnsicefilt=.false., &
              lnemoaccumflux=.false., &
              lnemogrib3d=.false., &
              nnemo3dlevs=0, &
              lnemopartcoup=.false., &
              lnemopartmask=.false., &
              lnemopartmaskfile=.false., &
              rnpartrampstart=0.0_real64, &
              rnpartramplen=0.0_real64, &
              rnpartlat=0.0_real64, &
              rnpartlatspread=0.0_real64, &
              cdnpartmaskfile=repeat(achar(0), len(climate%cdnpartmaskfile)), &
              cplng_active=.false., &
              cplng_num_fields=0_int32, &
              ip_a_sst=0_int32, &
              ip_a_ice_frac=0_int32, &
              ip_a_curr_u=0_int32, &
              ip_a_curr_v=0_int32, &
              ip_a_taux_oce=0_int32, &
              ip_a_tauy_oce=0_int32, &
              ip_a_taux_ice=0_int32, &
              ip_a_tauy_ice=0_int32, &
              ip_a_qs_mix=0_int32, &
              ip_a_qns_mix=0_int32, &
              ip_a_qs_oce=0_int32, &
              ip_a_qns_oce=0_int32, &
              ip_a_qs_ice=0_int32, &
              ip_a_qns_ice=0_int32, &
              ip_a_precip_liquid=0_int32, &
              ip_a_precip_solid=0_int32, &
              ip_a_evap_total=0_int32, &
              ip_a_evap_ice=0_int32, &
              ip_a_dqns_dt=0_int32, &
              ip_a_runoff=0_int32, &
              ip_a_total_cc=0_int32, &
              ip_a_low_cc=0_int32, &
              ip_a_ice_temp=0_int32, &
              ip_a_ice_albedo=0_int32, &
              ip_a_ice_thickness=0_int32, &
              ip_a_snow_thickness=0_int32, &
              ip_a_ice_temp_lvls=0_int32, &
              ip_a_taux=0_int32, &
              ip_a_tauy=0_int32, &
              ip_a_qs=0_int32, &
              ip_a_qns=0_int32, &
              ip_a_water=0_int32, &
              ip_a_sst_atm=0_int32, &
              ip_a_tsk_atm=0_int32, &
              ip_a_ist_atm=0_int32, &
              ip_a_2decv_skt=0_int32, &
              lcoupsim=.false.)
    status = 0_int32
  end function initialize_fresh_inactive_configuration_records
end module forecast_fresh_inactive_configuration
