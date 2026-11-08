module runtime_surface_time_layer_mod
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use surface_fields_mix, only: surface_field_map_type => tsurf
  use yos_surf, only: native_surface_type => tsurf
  use yomphyder, only: dimension_type, state_type, aux_type, surf_and_more_type, surf_and_more_local_type, keys_local_type, &
                       flux_type, ddh_surf_type
  use yomrip, only: trip
  use yomphy2, only: tphy2
  use yoephy, only: tephy
  use yos_thf, only: rhoh2o
  use surface_time_update_adapter_mod, only: surftstp
  implicit none
  private
  public :: runtime_surface_time_layer
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Select native surface fields and call the complete owned time-update graph.
  !!
  !! The first twelve owners keep the original SURFTSTP_LAYER order and types.
  !! The final two arguments replace the old borrowed address context: a native
  !! surface configuration and the explicit current step. The caller owns all
  !! metadata and array targets through return. No registry getter or model
  !! constructor runs here. Dimensions use int32 and physical fields use real64.
  !! The time step is in seconds; water density is in kilograms per cubic metre.
  !! Return zero after completion, or two for the selected shape and step refusals.
  !! Array mutations follow the 171-argument SURFTSTP interface.
  function runtime_surface_time_layer(ydfields, ydephy, ydrip, ydphy2, kdim, state, paux, psurf, surfl, llkeys, flux, pddhs, &
                                      native_surface, current_step) result(status)
    type(surface_field_map_type), intent(in) :: ydfields
    type(tephy), intent(in) :: ydephy
    type(trip), intent(in) :: ydrip
    type(tphy2), intent(in) :: ydphy2
    type(dimension_type), intent(in) :: kdim
    type(state_type), intent(in) :: state
    type(aux_type), intent(in) :: paux
    type(surf_and_more_type), intent(inout) :: psurf
    type(surf_and_more_local_type), intent(inout) :: surfl
    type(keys_local_type), intent(inout) :: llkeys
    type(flux_type), intent(inout) :: flux
    type(ddh_surf_type), intent(inout) :: pddhs
    type(native_surface_type), intent(inout) :: native_surface
    integer(int32), intent(in) :: current_step
    integer(int32) :: status, allocation_status, p
    integer(int32), allocatable :: iveg(:, :)
    real(real64), allocatable :: zlaivt(:, :), zcvt(:, :), zrespbstr(:, :), zrespbstr2(:, :)
    real(real64), allocatable :: zbiomass_last(:, :), zbiomasstr_last(:, :), zbiomasstr2_last(:, :)
    real(real64), allocatable :: zblossvt(:, :), zbgainvt(:, :), zlaie1(:, :), zbstre1(:, :), zbstr2e1(:, :)
    real(real64), allocatable :: zlai(:), zbiom(:), zbloss(:), zbgain(:), zbiomstr(:), zbiomstr2(:), zdhbios(:, :, :)
    real(real64), volatile :: exact_half, half_subnormal, empty_inverse_step, empty_inverse_density
    type(ieee_round_type) :: rounding
    status = 2_int32
    p = kdim%klon
    if (p < 1 .or. p > 128) return
    if (kdim%klev < 6 .or. kdim%klev > 512) return
    if (kdim%klevs /= 4 .or. kdim%ktiles /= 9 .or. kdim%klevsn /= 5) return
    if (kdim%kidia < 1 .or. kdim%kidia > p + 1) return
    if (kdim%kfdia < kdim%kidia - 1 .or. kdim%kfdia > p) return
    if (current_step < 0 .or. current_step > 8) return
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    exact_half = 0.5_real64
    half_subnormal = tiny(0.0_real64)*exact_half
    if (half_subnormal <= 0.0_real64) call reject_contract()
    allocate (iveg(p, 2), zlaivt(p, 2), zcvt(p, 2), zrespbstr(p, 2), zrespbstr2(p, 2), &
              zbiomass_last(p, 2), zbiomasstr_last(p, 2), zbiomasstr2_last(p, 2), zblossvt(p, 2), zbgainvt(p, 2), &
              zlaie1(p, 2), zbstre1(p, 4), zbstr2e1(p, 2), zlai(p), zbiom(p), zbloss(p), zbgain(p), &
              zbiomstr(p), zbiomstr2(p), zdhbios(p, 2, 5), stat=allocation_status)
    if (allocation_status /= 0) call reject_contract()
    ! The source writes ten complete positive-zero owners before any active interval.
    zrespbstr = 0.0_real64
    zrespbstr2 = 0.0_real64
    zbiomass_last = 0.0_real64
    zbiomasstr_last = 0.0_real64
    zbiomasstr2_last = 0.0_real64
    zblossvt = 0.0_real64
    zbgainvt = 0.0_real64
    zlaie1 = 0.0_real64
    zbstre1 = 0.0_real64
    zbstr2e1 = 0.0_real64
    ! Preserve the selected runtime empty-wrapper divisions as real operations.
    if (kdim%kfdia < kdim%kidia) then
      if (transfer(ydphy2%tsphy, 0_int64) /= int(z'407C200000000000', int64)) call reject_contract()
      if (transfer(rhoh2o, 0_int64) /= int(z'408F400000000000', int64)) call reject_contract()
      empty_inverse_step = 1.0_real64/ydphy2%tsphy
      empty_inverse_density = 1.0_real64/rhoh2o
    end if
    call surftstp( &
      ydsurf=native_surface, &
      kidia=kdim%kidia, &
      kfdia=kdim%kfdia, &
      klon=kdim%klon, &
      klevs=kdim%klevs, &
      ktiles=kdim%ktiles, &
      klevsn=kdim%klevsn, &
      klevo=kdim%klevo, &
      klevi=kdim%klevi, &
      kstart=ydrip%nstart, &
      kstep=current_step, &
      kdhvtss=kdim%kdhvtss, &
      kdhftss=kdim%kdhftss, &
      kdhvtts=kdim%kdhvtts, &
      kdhftts=kdim%kdhftts, &
      kdhvtis=kdim%kdhvtis, &
      kdhftis=kdim%kdhftis, &
      kdhvsss=kdim%kdhvsss, &
      kdhfsss=kdim%kdhfsss, &
      kdhviis=kdim%kdhviis, &
      kdhfiis=kdim%kdhfiis, &
      kdhvwls=kdim%kdhvwls, &
      kdhfwls=kdim%kdhfwls, &
      kdhvbios=0_int32, &
      kdhfbios=5_int32, &
      kdhvvegs=7_int32, &
      kdhfvegs=1_int32, &
      ktvl=psurf%itvl, &
      ktvh=psurf%itvh, &
      kveg=iveg, &
      ksoty=psurf%isoty, &
      ptsphy=ydphy2%tsphy, &
      psdor=psurf%phstd, &
      pfrti=surfl%zfrti, &
      psst=psurf%psd_vf(:, ydfields%ysd_vf%ysst%mp), &
      pustrti=psurf%pustrti, &
      pvstrti=psurf%pvstrti, &
      pahfsti=psurf%pahfsti, &
      pevapti=psurf%pevapti, &
      pssrflti=surfl%zfrsoti, &
      pslrflti=surfl%zahftrti, &
      plat=paux%pgelat, &
      panfmvt=surfl%zanfmvt, &
      pandayvt=surfl%zandayvt, &
      pmu0=paux%pmu0, &
      pcvt=zcvt, &
      plaivt=zlaivt, &
      plail=psurf%plail, &
      plaih=psurf%plaih, &
      plailc=psurf%psd_vf(:, ydfields%ysd_vf%ylail%mp), &
      plaihc=psurf%psd_vf(:, ydfields%ysd_vf%ylaih%mp), &
      ldland=llkeys%llland, &
      ldsice=llkeys%llsice, &
      ldsi=ydephy%lesice, &
      ldnh=llkeys%llnh, &
      ldocn_kpp=llkeys%llocn_kpp, &
      psnm1m=surfl%zsnm1m, &
      ptsnm1m=psurf%psp_sg(:, :, ydfields%ysp_sg%yt%mp9), &
      pasnm1m=psurf%psp_sg(:, 1, ydfields%ysp_sg%ya%mp9), &
      prsnm1m=psurf%psp_sg(:, :, ydfields%ysp_sg%yr%mp9), &
      pwsnm1m=psurf%psp_sg(:, :, ydfields%ysp_sg%yw%mp9), &
      paprs=paux%paprs(:, kdim%klev), &
      ptskm1m=psurf%psp_rr(:, ydfields%ysp_rr%yt%mp9), &
      ptsam1m=psurf%psp_sb(:, :, ydfields%ysp_sb%yt%mp9), &
      ptiam1m=psurf%psp_sb(:, :, ydfields%ysp_sb%ytl%mp9), &
      pwlm1m=surfl%zwlm1m, &
      pwsam1m=psurf%psp_sb(:, :, ydfields%ysp_sb%yq%mp9), &
      ptlicem1m=psurf%psp_sl(:, ydfields%ysp_sl%ylict%mp9), &
      ptlmnwm1m=psurf%psp_sl(:, ydfields%ysp_sl%yltlt%mp9), &
      ptlwmlm1m=psurf%psp_sl(:, ydfields%ysp_sl%ylmlt%mp9), &
      ptlbotm1m=psurf%psp_sl(:, ydfields%ysp_sl%ylblt%mp9), &
      ptlsfm1m=psurf%psp_sl(:, ydfields%ysp_sl%ylshf%mp9), &
      phlicem1m=psurf%psp_sl(:, ydfields%ysp_sl%ylicd%mp9), &
      phlmlm1m=psurf%psp_sl(:, ydfields%ysp_sl%ylmld%mp9), &
      pgemu=paux%pgemu, &
      pldepth=psurf%psd_vf(:, ydfields%ysd_vf%ydl%mp), &
      ldlake=llkeys%lllake, &
      pclake=psurf%psd_vf(:, ydfields%ysd_vf%yclk%mp), &
      prsfc=flux%pfplcl(:, kdim%klev), &
      prsfl=flux%pfplsl(:, kdim%klev), &
      pslrfl=flux%pfrth(:, kdim%klev), &
      pssfc=flux%pfplcn(:, kdim%klev), &
      pssfl=flux%pfplsn(:, kdim%klev), &
      pcvl=psurf%pcvl, &
      pcvh=psurf%pcvh, &
      pcur=psurf%pcur, &
      pwlmx=surfl%zwlmx, &
      pevapsnw=surfl%zevapsnw, &
      pusrf=state%u(:, kdim%klev), &
      pvsrf=state%v(:, kdim%klev), &
      ptsrf=state%t(:, kdim%klev), &
      pzo=psurf%psd_v3(:, :, ydfields%ysd_v3%yzo%mp), &
      pho=psurf%psd_v3(:, :, ydfields%ysd_v3%yho%mp), &
      pho_inv=psurf%psd_v3(:, :, ydfields%ysd_v3%yho_inv%mp), &
      pdo=psurf%psd_v3(:, :, ydfields%ysd_v3%ydo%mp), &
      pocdepth=psurf%psd_v2(:, ydfields%ysd_v2%yocdep%mp), &
      puo0=psurf%psp_om(:, :, ydfields%ysp_om%yuo%mp9), &
      pvo0=psurf%psp_om(:, :, ydfields%ysp_om%yvo%mp9), &
      puoc=psurf%psd_v3(:, :, ydfields%ysd_v3%yuoc%mp), &
      pvoc=psurf%psd_v3(:, :, ydfields%ysd_v3%yvoc%mp), &
      pto0=psurf%psp_om(:, :, ydfields%ysp_om%yto%mp9), &
      pso0=psurf%psp_om(:, :, ydfields%ysp_om%yso%mp9), &
      padvt=psurf%psd_v3(:, :, ydfields%ysd_v3%yadvt%mp), &
      padvs=psurf%psd_v3(:, :, ydfields%ysd_v3%yadvs%mp), &
      ptri0=psurf%psd_v3(:, :, ydfields%ysd_v3%ytri0%mp), &
      ptri1=psurf%psd_v3(:, :, ydfields%ysd_v3%ytri1%mp), &
      pswdk_save=psurf%psd_v3(:, :, ydfields%ysd_v3%yswdk%mp), &
      pustrc=psurf%psd_v2(:, ydfields%ysd_v2%yustrc%mp), &
      pvstrc=psurf%psd_v2(:, ydfields%ysd_v2%yvstrc%mp), &
      pustokes=psurf%psd_ws(:, ydfields%ysd_ws%yustokes%mp), &
      pvstokes=psurf%psd_ws(:, ydfields%ysd_ws%yvstokes%mp), &
      ptauocx=psurf%psd_ws(:, ydfields%ysd_ws%ytauocx%mp), &
      ptauocy=psurf%psd_ws(:, ydfields%ysd_ws%ytauocy%mp), &
      pphioc=psurf%psd_ws(:, ydfields%ysd_ws%yphioc%mp), &
      pwsemean=psurf%psd_ws(:, ydfields%ysd_ws%ywsemean%mp), &
      pwsfmean=psurf%psd_ws(:, ydfields%ysd_ws%ywsfmean%mp), &
      ptsdfl=flux%pftg12, &
      profd=flux%pfwrod, &
      profs=flux%pfwro1, &
      pwfsd=flux%pfwg12, &
      pmelt=flux%pfwmlt, &
      pfwev=flux%pfwev, &
      penes=flux%penes, &
      pdifm=psurf%psd_v3(:, :, ydfields%ysd_v3%ydifm%mp), &
      pdift=psurf%psd_v3(:, :, ydfields%ysd_v3%ydift%mp), &
      pdifs=psurf%psd_v3(:, :, ydfields%ysd_v3%ydifs%mp), &
      potke=psurf%psd_v3(:, :, ydfields%ysd_v3%yotke%mp), &
      prespbstr=zrespbstr, &
      prespbstr2=zrespbstr2, &
      pbiomass_last=zbiomass_last, &
      pbiomasstr_last=zbiomasstr_last, &
      pbiomasstr2_last=zbiomasstr2_last, &
      pblossvt=zblossvt, &
      pbgainvt=zbgainvt, &
      plai=zlai, &
      pbiom=zbiom, &
      pbloss=zbloss, &
      pbgain=zbgain, &
      pbiomstr=zbiomstr, &
      pbiomstr2=zbiomstr2, &
      psne1=psurf%psnse1, &
      ptsne1=psurf%ptsne1, &
      pasne1=psurf%pasne1(:, 1), &
      prsne1=psurf%prsne1, &
      pwsne1=psurf%pwsne1, &
      ptsae1=psurf%ptsae1, &
      ptiae1=psurf%ptiae1, &
      pwle1=psurf%pwle1, &
      pwsae1=psurf%pwsae1, &
      ptlicee1=psurf%ptlicee1, &
      ptlmnwe1=psurf%ptlmnwe1, &
      ptlwmle1=psurf%ptlwmle1, &
      ptlbote1=psurf%ptlbote1, &
      ptlsfe1=psurf%ptlsfe1, &
      phlicee1=psurf%phlicee1, &
      phlmle1=psurf%phlmle1, &
      puoe1=psurf%puoe1, &
      pvoe1=psurf%pvoe1, &
      ptoe1=psurf%ptoe1, &
      psoe1=psurf%psoe1, &
      plaie1=zlaie1, &
      pbstre1=zbstre1, &
      pbstr2e1=zbstr2e1, &
      pdhtss=pddhs%pdhtss, &
      pdhtts=pddhs%pdhtts, &
      pdhtis=pddhs%pdhtis, &
      pdhsss=pddhs%pdhsss, &
      pdhiis=pddhs%pdhiis, &
      pdhwls=pddhs%pdhwls, &
      pdhbios=zdhbios, &
      pdhvegs=surfl%zdhvegs)
    status = 0_int32
  end function runtime_surface_time_layer
end module runtime_surface_time_layer_mod
