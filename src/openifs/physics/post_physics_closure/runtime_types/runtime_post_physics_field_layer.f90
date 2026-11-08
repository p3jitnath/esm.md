! (C) Copyright1989- ECMWF. Apache Licence Version2.0.
!> Project actual native work arrays into the complete post-physics driver.
!! State arrays retain their existing owners; catalog indices select source planes.
!! Private occurrence counters preserve all12 precipitation-type columns.
submodule(forecast_native_runtime_post_physics) forecast_native_runtime_post_physics_body
  use iso_fortran_env, only: int64
  use yomhook, only: lhook, dr_hook, jphook
  use physics_grid_dimension_helpers_mod, only: surface_group_index
  use forecast_surface_catalog_lookup, only: surface_catalog_index
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_native_post_physics_control_targets, only: post_control_targets_ready
  use forecast_native_runtime_post_physics_driver, only: postphy
  implicit none
contains
  module procedure postphy_layer_runtime
  integer :: P, L, jpt, jrof, ilevoml, group, allocation_status
  real(real64),allocatable::ZDHFSS(:,:),ZEXTRE1(:,:,:),ZXTR2E1(:,:),ZGHG(:,:),ZAEROTC(:,:),ZAEROF(:,:,:),ZCHEM(:,:),ZPTYPEOCC6(:,:)
  real(jphook) :: ZHOOK_HANDLE
  status = 2
  if (.not. context%initialized .or. .not. context%block_open) return
  if (.not. associated(inputs%records%model) .or. .not. associated(inputs%records%surface_metadata)) return
  if (.not. associated(inputs%post_controls)) return
  if (.not. post_control_targets_ready(inputs%post_controls)) return
  if (lrsacc .neqv. (inputs%post_controls%lrsacc /= 0)) return
  P = context%dimensions%KLON; L = context%dimensions%KLEV
  if (P < 1 .or. P > 24 .or. L < 3 .or. L > 256) return
  if(context%dimensions%KIDIA<1.or.context%dimensions%KFDIA>P.or.context%dimensions%KFDIA<context%dimensions%KIDIA-1)return
  if (size(put9, 1) /= P .or. size(put9, 2) /= L) return
  if (any(shape(pvt9) /= shape(put9)) .or. any(shape(ptt9) /= shape(put9)) .or. any(shape(tenq) /= shape(put9))) return
  if (size(pgfl, 1) /= P .or. size(pgfl, 2) /= L) return
if(inputs%records%model%fields%alias_controls%nghg/=0.or.inputs%records%model%fields%settings%nchem_tc/=0.or.inputs%records%model%fields%settings%nactaero/=0)return
  if (inputs%records%model%physics%ecmwf_physics%LOCMLTKE) return
  if (inputs%records%model%lrsiddh) return
  if (inputs%records%model%climate%lnemocoup) return
  if (surface_group_index(inputs%records%surface_metadata, 'YSP_EPD') < 1) return
  if (surface_group_index(inputs%records%surface_metadata, 'YSP_X2D') < 1) return
  if (surface_group_index(inputs%records%surface_metadata, 'YSP_OMD') < 1) return
  if (surface_group_index(inputs%records%surface_metadata, 'YSD_SMD') < 1) return
 if(inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSD_SMD'))%metadata%layers/=0)return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLSM', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCI', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YINEE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YIGPP', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YIREC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YZ0F', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YF', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YW', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YA', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YR', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YT', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YT', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YW', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YT', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YQ', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YTL', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICT', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLTLT', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLMLT', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLBLT', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLSHF', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICD', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLMLD', 4) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YUO', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YVO', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YTO', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YSO', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YW', 2) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YT', 2) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YQ', 2) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y2T', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y2SH', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YBLH', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSUND', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y10FGCV', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTTRC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTSRC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSTRC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSSRC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YES', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSMLT', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y10FG', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y10FG6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YI10FG', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLSPF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YVIMD', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y10U', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y10V', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLZ0H', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YALB', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLCC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMCC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YHCC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLSP', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCP', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YFZRA', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YBLD', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSSHF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSLHF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSP', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMSL', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSSR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSTR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSSRD', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSTRD', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSSRDC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSTRDC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTSR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTTR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSUVB', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSPAR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCAPE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCAPES', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMXCAP6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMXCAPS6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSPARC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSTINC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSFDIR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSDSRP', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSCDIR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCBASE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%Y0DEGL', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YM10DEGL', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YVISIH', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCIN', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YKINDEX', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTTINDEX', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YPDEPL', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMUCAPE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMLCAPE50', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMLCAPE100', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMLCIN50', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMLCIN100', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCBASEA', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCTOPC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTROPOTP', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YZTWETB0', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YZTWETB1', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YIEWSS', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YINSSS', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YEWSS', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YNSSS', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YPEV', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLGWS', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YISSHF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YIE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YVIWVE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YVIWVN', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCW', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCWV', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCLW', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCIW', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCRW', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCSW', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCSLW', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMGWS', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YGWD', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMX2T', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMN2T', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMX2T6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMN2T6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YRO', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSSRO', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YSRO', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCSF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLSSF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMXTPR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMNTPR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMXTPR6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YMNTPR6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTPR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLSRR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCRR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLSSFR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YCSFR', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YPTYPE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YILSPF', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YTCO3', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YNEE', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YGPP', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YREC', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLITOTI', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLITOTA6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLICGI', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YLICGA6', 1, i=1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_SM%YCLBT', 1) < 1) return
  if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_SM%YCSBT', 1) < 1) return
  do jpt = 1, 12
    if (surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YPTYPEOCC6', 1, i=1, j=jpt) < 1) return
  end do
associate(DIMS=>context%dimensions,PAUX=>context%auxiliary,PRAD=>context%radiation,PSURF=>context%surface,FLUX=>context%flux,PDIAG=>context%diagnostics,PDDHS=>context%surface_diagnostics)
   ILEVOML = inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata, 'YSP_OMD'))%metadata%layers
allocate(ZDHFSS(P,0),ZEXTRE1(P,inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSP_EPD'))%metadata%layers,inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSP_EPD'))%metadata%registered_fields),ZXTR2E1(P,inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSP_X2D'))%metadata%registered_fields),ZGHG(P,0),ZAEROTC(P,0),ZAEROF(P,0,8),ZCHEM(P,0),ZPTYPEOCC6(P,12),stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    if (lhook) call dr_hook('POSTPHY_LAYER', 0, ZHOOK_HANDLE)
    ZDHFSS(:, :) = 0.0_real64
    status = set_ocean_new_plane(inputs%records%surface_metadata, 'YSP_OM%YUO')
    if (status /= 0) return
    status = set_ocean_new_plane(inputs%records%surface_metadata, 'YSP_OM%YVO')
    if (status /= 0) return
    status = set_ocean_new_plane(inputs%records%surface_metadata, 'YSP_OM%YTO')
    if (status /= 0) return
    status = set_ocean_new_plane(inputs%records%surface_metadata, 'YSP_OM%YSO')
    if (status /= 0) return
    do jpt = 1, 12
      do jrof = DIMS%KIDIA, DIMS%KFDIA
      ZPTYPEOCC6(jrof,jpt)=PSURF%PSD_VD(jrof,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YPTYPEOCC6',1,i=1,j=jpt))
      end do
    end do
status=postphy(context,inputs,lrsacc,DIMS%KLON,DIMS%KIDIA,DIMS%KFDIA,DIMS%KLEV,first_step,mlpp,rs6,reset,DIMS%KLEVS,inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSP_EPD'))%metadata%layers,inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSP_EPD'))%metadata%registered_fields,inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSD_SMD'))%metadata%layers,DIMS%KSTGLO,DIMS%KLEVSN,inputs%records%surface_metadata%groups(surface_group_index(inputs%records%surface_metadata,'YSP_X2D'))%metadata%registered_fields,ILEVOML,inputs%records%model%physics_auxiliary%TSPHY,PUT9,PVT9,PTT9,PGFL,FLUX%PAERODDF,tenq,PAUX%PDELP,FLUX%PDIFTQ,FLUX%PDIFCQ,FLUX%PDIFTS,FLUX%PDIFCS,FLUX%PFRSO,FLUX%PFRSOD,FLUX%PFRSODC,FLUX%PFRTH,FLUX%PFRTHD,FLUX%PFRTHDC,FLUX%PUVDF,FLUX%PPARF,PDIAG%ZCAPE,FLUX%PPARCF,PRAD%PTINCF,PRAD%PFDIR,PRAD%PDSRP,PRAD%PCDIR,PDIAG%PCBASE,PDIAG%PPDEPL,PDIAG%P0DEGL,PDIAG%PM10DEGL,PDIAG%PVISIH,PDIAG%PCIN,PDIAG%PCONVIND,PDIAG%PLIGH_TOT,PDIAG%PLIGH_CTG,PDIAG%PCBASEA,PDIAG%PCTOPC,PDIAG%PTROPOTP,PDIAG%PZTWETB,FLUX%PFHPCL,FLUX%PFHPCN,FLUX%PFHPSL,FLUX%PFHPSN,FLUX%PFPLCL,FLUX%PFPLCN,FLUX%PFPLSL,FLUX%PFPLSN,FLUX%PSTRCU,FLUX%PSTRCV,FLUX%PSTRDU,FLUX%PSTRDV,FLUX%PFCCQN,FLUX%PFCCQL,FLUX%PFCSQN,FLUX%PFCSQL,FLUX%PFCQLNG,FLUX%PFCQNNG,FLUX%PFSQRF,FLUX%PFSQSF,FLUX%PFCQRNG,FLUX%PFCQSNG,FLUX%PFSQLTUR,FLUX%PFSQITUR,FLUX%PSTRTU,FLUX%PSTRTV,PAUX%POROG,FLUX%PENES,FLUX%PFWSB,PAUX%PSLON,PAUX%PCLON,PSURF%PSD_VF(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VF%YLSM',1)),PSURF%PSD_VF(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VF%YCI',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YINEE',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YIGPP',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YIREC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YZ0F',1)),PSURF%PTSAE1,PSURF%PTLE1,PSURF%PWSAE1,PSURF%PTIAE1,PSURF%PWLE1,PSURF%PSNSE1,PSURF%PWSNE1,PSURF%PASNE1,PSURF%PRSNE1,PSURF%PTSNE1,PSURF%PTLICEE1,PSURF%PTLMNWE1,PSURF%PTLWMLE1,PSURF%PTLBOTE1,PSURF%PTLSFE1,PSURF%PHLICEE1,PSURF%PHLMLE1,ZEXTRE1,ZXTR2E1,PSURF%PEVAPMU,PSURF%PUOE1,PSURF%PVOE1,PSURF%PTOE1,PSURF%PSOE1,PSURF%PSP_SG(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SG%YF',4)),PSURF%PSP_SG(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SG%YW',4)),PSURF%PSP_SG(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SG%YA',4)),PSURF%PSP_SG(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SG%YR',4)),PSURF%PSP_SG(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SG%YT',4)),PSURF%PSP_SB(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SB%YT',4)),PSURF%PSP_RR(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_RR%YW',4)),PSURF%PSP_RR(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_RR%YT',4)),PSURF%PSP_SB(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SB%YQ',4)),PSURF%PSP_SB(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SB%YTL',4)),PSURF%PSP_SL(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SL%YLICT',4)),PSURF%PSP_SL(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SL%YLTLT',4)),PSURF%PSP_SL(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SL%YLMLT',4)),PSURF%PSP_SL(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SL%YLBLT',4)),PSURF%PSP_SL(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SL%YLSHF',4)),PSURF%PSP_SL(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SL%YLICD',4)),PSURF%PSP_SL(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SL%YLMLD',4)),PSURF%PSP_EP(:,:,:),PSURF%PSP_X2(:,:),PSURF%PSP_OM(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_OM%YUO',4)),PSURF%PSP_OM(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_OM%YVO',4)),PSURF%PSP_OM(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_OM%YTO',4)),PSURF%PSP_OM(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_OM%YSO',4)),PAUX%PAPRS,PAUX%PAPRSF,PSURF%PSP_RR(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_RR%YW',2) ),FLUX%PFTLHEV,FLUX%PFTLHSB,PSURF%PSP_RR(:,surface_catalog_index(inputs%records%surface_metadata,'YSP_RR%YT',2) ),PSURF%PSP_SB(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSP_SB%YQ',2) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y2T',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y2SH',1)),PRAD%PISUND,PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YBLH',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSUND',1)),FLUX%PFRTHC(:,0),FLUX%PFRSOC(:,0),FLUX%PFRTHC(:,1),FLUX%PFRSOC(:,1),PDIAG%PI10FG,PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y10FGCV',1)),PDIAG%PCOVPTOT(:,DIMS%KLEV),PDIAG%PPRECTYPE,PDIAG%PFZRA,PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTTRC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTSRC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSTRC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSSRC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YES',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSMLT',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y10FG',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y10FG6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YI10FG',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLSPF',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YVIMD',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y10U',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y10V',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLZ0H',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YALB',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLCC',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMCC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YHCC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCC',1)),PDIAG%PVDIS,PDIAG%PVDISG,PDIAG%PUSTRG,PDIAG%PVSTRG,FLUX%PFWRO1,PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLSP',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCP',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSF',1)   ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YFZRA',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YBLD',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSSHF',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSLHF',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSP',1)   ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMSL',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSSR',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSTR',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSSRD',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSTRD',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSSRDC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSTRDC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTSR',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTTR',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSUVB',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSPAR',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCAPE',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCAPES',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMXCAP6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMXCAPS6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSPARC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSTINC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSFDIR',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSDSRP',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSCDIR',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCBASE',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%Y0DEGL',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YM10DEGL',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YVISIH',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCIN',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YKINDEX',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTTINDEX',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YPDEPL',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMUCAPE',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMLCAPE50',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMLCAPE100',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMLCIN50',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMLCIN100',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCBASEA',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCTOPC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTROPOTP',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YZTWETB0',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YZTWETB1',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YIEWSS',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YINSSS',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YEWSS',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YNSSS',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YE',1)    ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YPEV',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLGWS',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YISSHF',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YIE',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YVIWVE',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YVIWVN',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCW',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCWV',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCLW',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCIW',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCRW',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCSW',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCSLW',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMGWS',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YGWD',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMX2T',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMN2T',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMX2T6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMN2T6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YRO',1)   ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSSRO',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YSRO',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCSF',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLSSF',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMXTPR',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMNTPR',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMXTPR6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YMNTPR6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTPR',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLSRR',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCRR',1)  ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLSSFR',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YCSFR',1) ),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YPTYPE',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YILSPF',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YTCO3',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YNEE',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YGPP',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YREC',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLITOTI',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLITOTA6',1,i=1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLICGI',1)),PSURF%PSD_VD(:,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YLICGA6',1,i=1)),PSURF%PSD_SM(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSD_SM%YCLBT',1)),PSURF%PSD_SM(:,:,surface_catalog_index(inputs%records%surface_metadata,'YSD_SM%YCSBT',1)),ZPTYPEOCC6,ZAEROTC,ZAEROF,ZGHG,ZCHEM,PSURF%PSD_VF,PAUX%PGNORDL,PAUX%PGNORDM,PAUX%PGEMU,PAUX%PGSQM2,PAUX%PGELAM,PAUX%PGELAT,PAUX%PGAW,FLUX%PFCQNG,FLUX%PFWMLT,FLUX%PFWROD,PDDHS%PDHTLS,PDDHS%PDHTSS,PDDHS%PDHTTS,PDDHS%PDHTIS,PDDHS%PDHSSS,PDDHS%PDHIIS,PDDHS%PDHWLS,ZDHFSS)
    if (status /= 0) return
    do jpt = 1, 12
      do jrof = DIMS%KIDIA, DIMS%KFDIA
      PSURF%PSD_VD(jrof,surface_catalog_index(inputs%records%surface_metadata,'YSD_VD%YPTYPEOCC6',1,i=1,j=jpt))=ZPTYPEOCC6(jrof,jpt)
      end do
    end do
    if (lhook) call dr_hook('POSTPHY_LAYER', 1, ZHOOK_HANDLE)
  end associate
  status = 0
  end procedure
!> Set only the four original ocean new-time indices on the actual catalog.
  integer(int32) function set_ocean_new_plane(catalog, name) result(status)
    type(surface_field_registry), intent(inout) :: catalog
    character(*), intent(in) :: name
    integer :: j, g, f
    status = 2
    do j = 1, size(catalog%aliases)
      if (trim(catalog%aliases(j)%name) /= name) cycle
      g = catalog%aliases(j)%group; f = catalog%aliases(j)%first_field
      if (g < 1 .or. g > size(catalog%groups)) return
      if (.not. allocated(catalog%groups(g)%fields)) return
      if (f < 1 .or. f > size(catalog%groups(g)%fields)) return
      catalog%groups(g)%fields(f)%indices(4) = 1_int32
      status = 0
      return
    end do
  end function
end submodule
