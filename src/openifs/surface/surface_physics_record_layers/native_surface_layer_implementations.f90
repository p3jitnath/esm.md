!> Implement four surface layer entries using the live canonical records.
submodule(forecast_native_surface_layers) native_surface_layer_implementations
  use forecast_surface_catalog_lookup, only: surface_catalog_index
  use forecast_native_surface_boundary, only: surfbc
  use forecast_native_surface_radiation, only: surfrad
  use surftstp_ctl_mod, only: surftstp_ctl
  use forecast_snow_warm_start, only: snow_warm_start
  use forecast_calendar_and_monthly_fields, only: update_calendar
  implicit none
contains
  !> Admit live canonical parameter and metadata owners and a nonempty block.
  logical function surface_inputs_ready(inputs, d) result(ready)
    type(native_complete_physics_driver_inputs), intent(in) :: inputs
    type(dimension_type), intent(in) :: d
    ready = .false.
    if (.not. associated(inputs%physics)) return
    if (.not. associated(inputs%physics%surface)) return
    if (.not. associated(inputs%records%surface_metadata)) return
    if (.not. associated(inputs%records%model)) return
    if (.not. inputs%records%surface_metadata%ready) return
    if (d%klon < 1 .or. d%klon > 4096 .or. d%klev < 1 .or. d%klev > 512) return
    if (d%kidia < 1 .or. d%kfdia < d%kidia .or. d%kfdia > d%klon) return
    ready = .true.
  end function
  !> Set tile fractions and surface switches through the actual catalog.
  module procedure callpar_surface_boundary
  integer(int32) :: i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13
  status = 2_int32
  if (.not. surface_inputs_ready(inputs, d)) return
  if (.not. associated(aux%pgemu)) return
  if (.not. associated(keys%lllake)) return
  if (.not. associated(keys%llland)) return
  if (.not. associated(keys%llnh)) return
  if (.not. associated(keys%llocn_kpp)) return
  if (.not. associated(keys%llsice)) return
  if (.not. associated(surface%ico2typ)) return
  if (.not. associated(surface%isoty)) return
  if (.not. associated(surface%itvh)) return
  if (.not. associated(surface%itvl)) return
  if (.not. associated(surface%pcur)) return
  if (.not. associated(surface%pcvh)) return
  if (.not. associated(surface%pcvl)) return
  if (.not. associated(surface%phstd)) return
  if (.not. associated(surface%plaih)) return
  if (.not. associated(surface%plail)) return
  if (.not. associated(surface%psd_vf)) return
  if (.not. associated(surface%psp_sl)) return
  if (.not. associated(surfl%zfrti)) return
  if (.not. associated(surfl%zlaihi)) return
  if (.not. associated(surfl%zlaili)) return
  if (.not. associated(surfl%zrsnm1m)) return
  if (.not. associated(surfl%zsnm1m)) return
  if (.not. associated(surfl%zwlm1m)) return
  if (.not. associated(surfl%zwlmx)) return
  i1 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YTVL', 1_int32)
  if (i1 < 1 .or. i1 > size(surface%psd_vf, 2)) return
  i2 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCO2TYP', 1_int32)
  if (i2 < 1 .or. i2 > size(surface%psd_vf, 2)) return
  i3 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YTVH', 1_int32)
  if (i3 < 1 .or. i3 > size(surface%psd_vf, 2)) return
  i4 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YSOTY', 1_int32)
  if (i4 < 1 .or. i4 > size(surface%psd_vf, 2)) return
  i5 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCVL', 1_int32)
  if (i5 < 1 .or. i5 > size(surface%psd_vf, 2)) return
  i6 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCVH', 1_int32)
  if (i6 < 1 .or. i6 > size(surface%psd_vf, 2)) return
  i7 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCUR', 1_int32)
  if (i7 < 1 .or. i7 > size(surface%psd_vf, 2)) return
  i8 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLAIL', 1_int32)
  if (i8 < 1 .or. i8 > size(surface%psd_vf, 2)) return
  i9 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLAIH', 1_int32)
  if (i9 < 1 .or. i9 > size(surface%psd_vf, 2)) return
  i10 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLSM', 1_int32)
  if (i10 < 1 .or. i10 > size(surface%psd_vf, 2)) return
  i11 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCI', 1_int32)
  if (i11 < 1 .or. i11 > size(surface%psd_vf, 2)) return
  i12 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCLK', 1_int32)
  if (i12 < 1 .or. i12 > size(surface%psd_vf, 2)) return
  i13 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICD', 1_int32)
  if (i13 < 1 .or. i13 > size(surface%psp_sl, 2)) return
  call surfbc( &
    ydsurf=inputs%physics%surface, &
    kidia=d%kidia, &
    kfdia=d%kfdia, &
    klon=d%klon, &
    ktiles=d%ktiles, &
    klevsn=d%klevsn, &
    ptvl=surface%psd_vf(:, i1), &
    pco2typ=surface%psd_vf(:, i2), &
    ptvh=surface%psd_vf(:, i3), &
    psoty=surface%psd_vf(:, i4), &
    psdor=surface%phstd, &
    pcvlc=surface%psd_vf(:, i5), &
    pcvhc=surface%psd_vf(:, i6), &
    pcurc=surface%psd_vf(:, i7), &
    plailc=surface%psd_vf(:, i8), &
    plaihc=surface%psd_vf(:, i9), &
    plaili=surfl%zlaili, &
    plaihi=surfl%zlaihi, &
    plsm=surface%psd_vf(:, i10), &
    pci=surface%psd_vf(:, i11), &
    pclake=surface%psd_vf(:, i12), &
    phlice=surface%psp_sl(:, i13), &
    pgemu=aux%pgemu, &
    psnm1m=surfl%zsnm1m, &
    pwlm1m=surfl%zwlm1m, &
    prsnm1m=surfl%zrsnm1m, &
    ldland=keys%llland, &
    ldsice=keys%llsice, &
    ldlake=keys%lllake, &
    ldnh=keys%llnh, &
    ldocn_kpp=keys%llocn_kpp, &
    ktvl=surface%itvl, &
    kco2typ=surface%ico2typ, &
    ktvh=surface%itvh, &
    ksoty=surface%isoty, &
    pcvl=surface%pcvl, &
    pcvh=surface%pcvh, &
    pcur=surface%pcur, &
    plail=surface%plail, &
    plaih=surface%plaih, &
    pwlmx=surfl%zwlmx, &
    pfrti=surfl%zfrti, status=status)
  end procedure
  !> Update albedo and emissivity at the same calendar time as the source.
  module procedure callpar_surface_radiation
  integer(int32)::i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,idd,imm,iyy,ilmon(12),isec,idincr,initial,year,month,day,seconds,jl,nsw,nlwemiss
  real(real64) :: zalbice(d%klon)
  logical :: lnemolimalb
  status = 2_int32
  if (.not. surface_inputs_ready(inputs, d)) return
  if (.not. associated(aux%pmu0m)) return
  if (.not. associated(auxl%zccnl)) return
  if (.not. associated(auxl%zccno)) return
  if (.not. associated(auxl%zwnd)) return
  if (.not. associated(keys%llnh)) return
  if (.not. associated(surface%isoty)) return
  if (.not. associated(surface%pemis)) return
  if (.not. associated(surface%psd_vd)) return
  if (.not. associated(surface%psd_vf)) return
  if (.not. associated(surface%psp_rr)) return
  if (.not. associated(surface%psp_sb)) return
  if (.not. associated(surface%psp_sg)) return
  if (.not. associated(surface%psp_sl)) return
  if (.not. associated(surfl%zalbd)) return
  if (.not. associated(surfl%zalbp)) return
  if (.not. associated(surfl%zalbti)) return
  if (.not. associated(surfl%zfrti)) return
  if (.not. associated(surfl%zspectralemiss)) return
  if (.not. associated(tmp%u)) return
  if (.not. associated(tmp%v)) return
  i1 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YALBF', 1_int32)
  if (i1 < 1 .or. i1 > size(surface%psd_vf, 2)) return
  i2 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YTVH', 1_int32)
  if (i2 < 1 .or. i2 > size(surface%psd_vf, 2)) return
  i3 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCUR', 1_int32)
  if (i3 < 1 .or. i3 > size(surface%psd_vf, 2)) return
  i4 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCVH', 1_int32)
  if (i4 < 1 .or. i4 > size(surface%psd_vf, 2)) return
  i5 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YA', 3_int32)
  if (i5 < 1 .or. i5 > size(surface%psp_sg, 3)) return
  i6 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YT', 3_int32)
  if (i6 < 1 .or. i6 > size(surface%psp_rr, 2)) return
  i7 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YQ', 3_int32)
  if (i7 < 1 .or. i7 > size(surface%psp_sb, 3)) return
  i8 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICD', 3_int32)
  if (i8 < 1 .or. i8 > size(surface%psp_sl, 2)) return
  i9 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICT', 3_int32)
  if (i9 < 1 .or. i9 > size(surface%psp_sl, 2)) return
  i10 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YALB', 1_int32)
  if (i10 < 1 .or. i10 > size(surface%psd_vd, 2)) return
  if (.not. associated(inputs%providers)) return
  if (.not. associated(inputs%providers%physical)) return
  if (.not. associated(inputs%solar_clock%initial_date)) return
  if (.not. associated(inputs%solar_clock%initial_seconds)) return
  if (.not. associated(inputs%solar_clock%rstati)) return
  lnemolimalb = inputs%records%model%climate%lnemolimalb
  if (lnemolimalb) return
  nsw = inputs%physics%radiation%radiation%nsw
  nlwemiss = inputs%physics%radiation%radiation%nlwemiss
  if (nsw < 1 .or. nlwemiss < 1) return
  if (size(tmp%u, 1) < d%klon .or. size(tmp%u, 2) < d%klev) return
  if (size(tmp%v, 1) < d%klon .or. size(tmp%v, 2) < d%klev) return
  if (size(auxl%zwnd) < d%klon) return
  if (size(surfl%zalbd, 2) < nsw .or. size(surfl%zalbp, 2) < nsw) return
  if (size(surfl%zspectralemiss, 2) < nlwemiss) return
  if (inputs%records%surface_metadata%albedo_first < 1) return
  if (inputs%records%surface_metadata%albedo_last > size(surface%psd_vf, 2)) return
  do jl = d%kidia, d%kfdia
    auxl%zwnd(jl) = sqrt(tmp%u(jl, d%klev)*tmp%u(jl, d%klev) + tmp%v(jl, d%klev)*tmp%v(jl, d%klev))
  end do
  initial = inputs%solar_clock%initial_date
  year = initial/10000; month = mod(initial/100, 100); day = mod(initial, 100)
  seconds = inputs%solar_clock%initial_seconds + nint(inputs%solar_clock%rstati)
  idincr = seconds/nint(inputs%providers%physical%rday)
  isec = mod(seconds, nint(inputs%providers%physical%rday))
  call update_calendar(day, month, year, idincr, idd, imm, iyy, ilmon, status)
  if (status /= 0_int32) return
  zalbice(d%kidia:d%kfdia) = 0.0_real64
  call surfrad( &
    ydsurf=inputs%physics%surface, &
    kdd=idd, &
    kmm=imm, &
    kmon=ilmon, &
    kseco=isec, &
    kidia=d%kidia, &
    kfdia=d%kfdia, &
    klon=d%klon, &
    ktiles=d%ktiles, &
    ksw=nsw, &
    klw=nlwemiss, &
    ldnh=keys%llnh, &
    palbf=surface%psd_vf(:, i1), &
    palbicef=zalbice, &
    ptvh=surface%psd_vf(:, i2), &
    palcoeff=surface%psd_vf(:, inputs%records%surface_metadata%albedo_first:inputs%records%surface_metadata%albedo_last), &
    pcurc=surface%psd_vf(:, i3), &
    pcvh=surface%psd_vf(:, i4), &
    pasn=surface%psp_sg(:, 1, i5), &
    pmu0=aux%pmu0m, &
    pts=surface%psp_rr(:, i6), &
    pwnd=auxl%zwnd, &
    pws1=surface%psp_sb(:, 1, i7), &
    ksoty=surface%isoty, &
    pfrti=surfl%zfrti, &
    phlice=surface%psp_sl(:, i8), &
    ptlice=surface%psp_sl(:, i9), &
    palbd=surfl%zalbd(:, 1:nsw), &
    palbp=surfl%zalbp(:, 1:nsw), &
    palb=surface%psd_vd(:, i10), &
    pspectralemiss=surfl%zspectralemiss(:, 1:nlwemiss), &
    pemit=surface%pemis, &
    palbti=surfl%zalbti, &
    pccnl=auxl%zccnl, &
    pccno=auxl%zccno, &
    lnemolimalb=lnemolimalb, status=status)
  end procedure
  !> Prepare four snow profiles and publish both original surface time slots.
  module procedure callpar_snow_initialization
  integer(int32) :: jl, allocation_status, idx1, idx2, idx3, idx4, idx5, idx6, idx7, idx8, idx9, idx10, idx11, idx12
  real(real64), allocatable :: zsnm1m(:, :), ztsnm1m(:, :), zrsnm1m(:, :), zwsnm1m(:, :)
  status = 2_int32
  if (.not. surface_inputs_ready(inputs, d)) return
  if (d%klevs /= 4 .or. d%ktiles /= 9 .or. d%klevsn /= 5) return
  if (inputs%physics%surface%ysoil%nsnmlws /= 2) return
  if (.not. associated(aux%pmu0)) return
  if (.not. associated(surface%phstd)) return
  if (.not. associated(surface%psd_vf)) return
  if (.not. associated(surface%psp_rr)) return
  if (.not. associated(surface%psp_sb)) return
  if (.not. associated(surface%psp_sg)) return
  if (.not. associated(surfl%zfrti)) return
  if (.not. associated(surfl%zsnm1m)) return
  idx1 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLSM', 1_int32)
  if (idx1 < 1 .or. idx1 > size(surface%psd_vf, 2)) return
  idx2 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YT', 3_int32)
  if (idx2 < 1 .or. idx2 > size(surface%psp_sb, 3)) return
  idx3 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YT', 3_int32)
  if (idx3 < 1 .or. idx3 > size(surface%psp_rr, 2)) return
  idx4 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YA', 3_int32)
  if (idx4 < 1 .or. idx4 > size(surface%psp_sg, 3)) return
  idx5 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YR', 3_int32)
  if (idx5 < 1 .or. idx5 > size(surface%psp_sg, 3)) return
  idx6 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YT', 3_int32)
  if (idx6 < 1 .or. idx6 > size(surface%psp_sg, 3)) return
  idx7 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YF', 3_int32)
  if (idx7 < 1 .or. idx7 > size(surface%psp_sg, 3)) return
  idx8 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YW', 3_int32)
  if (idx8 < 1 .or. idx8 > size(surface%psp_sg, 3)) return
  idx9 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YF', 4_int32)
  if (idx9 < 1 .or. idx9 > size(surface%psp_sg, 3)) return
  idx10 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YR', 4_int32)
  if (idx10 < 1 .or. idx10 > size(surface%psp_sg, 3)) return
  idx11 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YT', 4_int32)
  if (idx11 < 1 .or. idx11 > size(surface%psp_sg, 3)) return
  idx12 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YW', 4_int32)
  if (idx12 < 1 .or. idx12 > size(surface%psp_sg, 3)) return
  if (size(surface%psp_sg, 1) < d%klon .or. size(surface%psp_sg, 2) < d%klevsn) return
  if (size(surface%psp_sb, 1) < d%klon .or. size(surface%psp_sb, 2) < d%klevs) return
  if (size(surfl%zsnm1m, 1) < d%klon .or. size(surfl%zsnm1m, 2) < d%klevsn) return
  allocate (zsnm1m(d%klon, d%klevsn), ztsnm1m(d%klon, d%klevsn), &
            zrsnm1m(d%klon, d%klevsn), zwsnm1m(d%klon, d%klevsn), stat=allocation_status)
  if (allocation_status /= 0) then
    status = 1_int32; return
  end if
  do jl = d%kidia, d%kfdia
    zsnm1m(jl, 1:d%klevsn) = surfl%zsnm1m(jl, 1:d%klevsn)
    zrsnm1m(jl, 1:d%klevsn) = surface%psp_sg(jl, 1, idx5)
    ztsnm1m(jl, 1:d%klevsn) = surface%psp_sg(jl, 1, idx6)
    zwsnm1m(jl, 1:d%klevsn) = 0._real64

  end do
  call snow_warm_start(kidia=d%kidia,kfdia=d%kfdia,klon=d%klon,klevsn=d%klevsn,      psdor=surface%phstd,        lsmask=surface%psd_vf(:,idx1), pfrti=surfl%zfrti, pmu0=aux%pmu0,        ptsa=surface%psp_sb(:,:,idx2), ptskin=surface%psp_rr(:,idx3),       palbsn=surface%psp_sg(:,1,idx4), ptsn=ztsnm1m, pssn=zsnm1m, prsn=zrsnm1m, pwsn= zwsnm1m,ydcst=inputs%physics%surface%ycst,ydsoil=inputs%physics%surface%ysoil,status=status)
  if (status /= 0_int32) return
  do jl = d%kidia, d%kfdia
    surfl%zsnm1m(jl, 1:d%klevsn) = zsnm1m(jl, 1:d%klevsn)
    surface%psp_sg(jl, 1:d%klevsn, idx7) = zsnm1m(jl, 1:d%klevsn)
    surface%psp_sg(jl, 1:d%klevsn, idx5) = zrsnm1m(jl, 1:d%klevsn)
    surface%psp_sg(jl, 1:d%klevsn, idx6) = ztsnm1m(jl, 1:d%klevsn)
    surface%psp_sg(jl, 1:d%klevsn, idx8) = zwsnm1m(jl, 1:d%klevsn)

    surface%psp_sg(jl, 1:d%klevsn, idx9) = zsnm1m(jl, 1:d%klevsn)
    surface%psp_sg(jl, 1:d%klevsn, idx10) = zrsnm1m(jl, 1:d%klevsn)
    surface%psp_sg(jl, 1:d%klevsn, idx11) = ztsnm1m(jl, 1:d%klevsn)
    surface%psp_sg(jl, 1:d%klevsn, idx12) = zwsnm1m(jl, 1:d%klevsn)
  end do

  status = 0_int32
  end procedure
  !> Apply the complete selected surface update to caller-owned rate arrays.
  module procedure callpar_surface_time_update
  integer(int32) :: p, allocation_status
  integer(int32), allocatable :: iveg(:, :)
  real(real64), allocatable :: zlaivt(:, :), zcvt(:, :), zrespbstr(:, :), zrespbstr2(:, :)
  real(real64), allocatable :: zbiomass_last(:, :), zbiomasstr_last(:, :), zbiomasstr2_last(:, :)
  real(real64), allocatable :: zblossvt(:, :), zbgainvt(:, :), zlaie1(:, :), zbstre1(:, :), zbstr2e1(:, :)
  real(real64), allocatable :: zlai(:), zbiom(:), zbloss(:), zbgain(:), zbiomstr(:), zbiomstr2(:), zdhbios(:, :, :)
  real(real64), target :: empty_vector(0), empty_plane(0, 0)
  integer(int32)::idx1,idx2,idx3,idx4,idx5,idx6,idx7,idx8,idx9,idx10,idx11,idx12,idx13,idx14,idx15,idx16,idx17,idx18,idx19,idx20,idx21,idx22,idx23,idx24,idx25,idx26,idx27,idx28,idx29,idx30,idx31,idx32,idx33,idx34,idx35,idx36,idx37,idx38,idx39,idx40,idx41,idx42,idx43,idx44,idx45,idx46,idx47,idx48,idx49
  real(real64), pointer :: view1(:)
  real(real64), pointer :: view2(:)
  real(real64), pointer :: view3(:)
  real(real64), pointer :: view4(:, :)
  real(real64), pointer :: view5(:)
  real(real64), pointer :: view6(:, :)
  real(real64), pointer :: view7(:, :)
  real(real64), pointer :: view8(:)
  real(real64), pointer :: view9(:, :)
  real(real64), pointer :: view10(:, :)
  real(real64), pointer :: view11(:, :)
  real(real64), pointer :: view12(:)
  real(real64), pointer :: view13(:)
  real(real64), pointer :: view14(:)
  real(real64), pointer :: view15(:)
  real(real64), pointer :: view16(:)
  real(real64), pointer :: view17(:)
  real(real64), pointer :: view18(:)
  real(real64), pointer :: view19(:)
  real(real64), pointer :: view20(:)
  real(real64), pointer :: view21(:, :)
  real(real64), pointer :: view22(:, :)
  real(real64), pointer :: view23(:, :)
  real(real64), pointer :: view24(:, :)
  real(real64), pointer :: view25(:)
  real(real64), pointer :: view26(:, :)
  real(real64), pointer :: view27(:, :)
  real(real64), pointer :: view28(:, :)
  real(real64), pointer :: view29(:, :)
  real(real64), pointer :: view30(:, :)
  real(real64), pointer :: view31(:, :)
  real(real64), pointer :: view32(:, :)
  real(real64), pointer :: view33(:, :)
  real(real64), pointer :: view34(:, :)
  real(real64), pointer :: view35(:, :)
  real(real64), pointer :: view36(:, :)
  real(real64), pointer :: view37(:)
  real(real64), pointer :: view38(:)
  real(real64), pointer :: view39(:)
  real(real64), pointer :: view40(:)
  real(real64), pointer :: view41(:)
  real(real64), pointer :: view42(:)
  real(real64), pointer :: view43(:)
  real(real64), pointer :: view44(:)
  real(real64), pointer :: view45(:)
  real(real64), pointer :: view46(:, :)
  real(real64), pointer :: view47(:, :)
  real(real64), pointer :: view48(:, :)
  real(real64), pointer :: view49(:, :)
  status = 2_int32
  if (.not. surface_inputs_ready(inputs, d)) return
  if (.not. associated(inputs%providers)) return
  if (.not. associated(inputs%providers%current_step)) return
  if (.not. associated(inputs%providers%initial_step)) return
  if (inputs%physics%surface%yocean_ml%leocml) return
  if (inputs%physics%surface%ymlm%locmltke) return
  if (.not. inputs%physics%surface%ysoil%lesnml) return
  if (.not. inputs%physics%surface%ysoil%levgen) return
  if (inputs%physics%surface%ysoil%lewbcheck) return
  if (d%klevs /= 4 .or. d%ktiles /= 9 .or. d%klevsn < 1 .or. d%klevsn > 64) return
  p = d%klon
  idx1 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YSST', 1_int32)
  idx2 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLAIL', 1_int32)
  idx3 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YLAIH', 1_int32)
  idx4 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YT', 3_int32)
  idx5 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YA', 3_int32)
  idx6 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YR', 3_int32)
  idx7 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YW', 3_int32)
  idx8 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YT', 3_int32)
  idx9 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YT', 3_int32)
  idx10 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YTL', 3_int32)
  idx11 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YQ', 3_int32)
  idx12 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICT', 3_int32)
  idx13 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLTLT', 3_int32)
  idx14 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLMLT', 3_int32)
  idx15 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLBLT', 3_int32)
  idx16 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLSHF', 3_int32)
  idx17 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICD', 3_int32)
  idx18 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLMLD', 3_int32)
  idx19 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YDL', 1_int32)
  idx20 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCLK', 1_int32)
  idx21 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YZO', 1_int32)
  idx22 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YHO', 1_int32)
  idx23 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YHO_INV', 1_int32)
  idx24 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YDO', 1_int32)
  idx25 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V2%YOCDEP', 1_int32)
  idx26 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YUO', 3_int32)
  idx27 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YVO', 3_int32)
  idx28 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YUOC', 1_int32)
  idx29 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YVOC', 1_int32)
  idx30 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YTO', 3_int32)
  idx31 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_OM%YSO', 3_int32)
  idx32 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YADVT', 1_int32)
  idx33 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YADVS', 1_int32)
  idx34 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YTRI0', 1_int32)
  idx35 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YTRI1', 1_int32)
  idx36 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YSWDK', 1_int32)
  idx37 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V2%YUSTRC', 1_int32)
  idx38 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V2%YVSTRC', 1_int32)
  idx39 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_WS%YUSTOKES', 1_int32)
  idx40 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_WS%YVSTOKES', 1_int32)
  idx41 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_WS%YTAUOCX', 1_int32)
  idx42 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_WS%YTAUOCY', 1_int32)
  idx43 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_WS%YPHIOC', 1_int32)
  idx44 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_WS%YWSEMEAN', 1_int32)
  idx45 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_WS%YWSFMEAN', 1_int32)
  idx46 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YDIFM', 1_int32)
  idx47 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YDIFT', 1_int32)
  idx48 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YDIFS', 1_int32)
  idx49 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_V3%YOTKE', 1_int32)
  if (.not. associated(surface%psd_vf)) return
  if (idx1 < 1 .or. idx1 > size(surface%psd_vf, 2)) return
  if (size(surface%psd_vf, 1) < d%klon) return
  if (idx2 < 1 .or. idx2 > size(surface%psd_vf, 2)) return
  if (idx3 < 1 .or. idx3 > size(surface%psd_vf, 2)) return
  if (.not. associated(surface%psp_sg)) return
  if (idx4 < 1 .or. idx4 > size(surface%psp_sg, 3)) return
  if (size(surface%psp_sg, 1) < d%klon) return
  if (idx5 < 1 .or. idx5 > size(surface%psp_sg, 3)) return
  if (size(surface%psp_sg, 2) < 1) return
  if (idx6 < 1 .or. idx6 > size(surface%psp_sg, 3)) return
  if (idx7 < 1 .or. idx7 > size(surface%psp_sg, 3)) return
  if (.not. associated(surface%psp_rr)) return
  if (idx8 < 1 .or. idx8 > size(surface%psp_rr, 2)) return
  if (size(surface%psp_rr, 1) < d%klon) return
  if (.not. associated(surface%psp_sb)) return
  if (idx9 < 1 .or. idx9 > size(surface%psp_sb, 3)) return
  if (size(surface%psp_sb, 1) < d%klon) return
  if (idx10 < 1 .or. idx10 > size(surface%psp_sb, 3)) return
  if (idx11 < 1 .or. idx11 > size(surface%psp_sb, 3)) return
  if (.not. associated(surface%psp_sl)) return
  if (idx12 < 1 .or. idx12 > size(surface%psp_sl, 2)) return
  if (size(surface%psp_sl, 1) < d%klon) return
  if (idx13 < 1 .or. idx13 > size(surface%psp_sl, 2)) return
  if (idx14 < 1 .or. idx14 > size(surface%psp_sl, 2)) return
  if (idx15 < 1 .or. idx15 > size(surface%psp_sl, 2)) return
  if (idx16 < 1 .or. idx16 > size(surface%psp_sl, 2)) return
  if (idx17 < 1 .or. idx17 > size(surface%psp_sl, 2)) return
  if (idx18 < 1 .or. idx18 > size(surface%psp_sl, 2)) return
  if (idx19 < 1 .or. idx19 > size(surface%psd_vf, 2)) return
  if (idx20 < 1 .or. idx20 > size(surface%psd_vf, 2)) return
  if (.not. associated(aux%paprs)) return
  if (.not. associated(aux%pgelat)) return
  if (.not. associated(aux%pgemu)) return
  if (.not. associated(aux%pmu0)) return
  if (.not. associated(flux%penes)) return
  if (.not. associated(flux%pfplcl)) return
  if (.not. associated(flux%pfplcn)) return
  if (.not. associated(flux%pfplsl)) return
  if (.not. associated(flux%pfplsn)) return
  if (.not. associated(flux%pfrth)) return
  if (.not. associated(flux%pftg12)) return
  if (.not. associated(flux%pfwev)) return
  if (.not. associated(flux%pfwg12)) return
  if (.not. associated(flux%pfwmlt)) return
  if (.not. associated(flux%pfwro1)) return
  if (.not. associated(flux%pfwrod)) return
  if (.not. associated(keys%lllake)) return
  if (.not. associated(keys%llland)) return
  if (.not. associated(keys%llnh)) return
  if (.not. associated(keys%llocn_kpp)) return
  if (.not. associated(keys%llsice)) return
  if (.not. associated(pddhs%pdhiis)) return
  if (.not. associated(pddhs%pdhsss)) return
  if (.not. associated(pddhs%pdhtis)) return
  if (.not. associated(pddhs%pdhtss)) return
  if (.not. associated(pddhs%pdhtts)) return
  if (.not. associated(pddhs%pdhwls)) return
  if (.not. associated(state0%t)) return
  if (.not. associated(state0%u)) return
  if (.not. associated(state0%v)) return
  if (.not. associated(surface%isoty)) return
  if (.not. associated(surface%itvh)) return
  if (.not. associated(surface%itvl)) return
  if (.not. associated(surface%pahfsti)) return
  if (.not. associated(surface%pasne1)) return
  if (.not. associated(surface%pcur)) return
  if (.not. associated(surface%pcvh)) return
  if (.not. associated(surface%pcvl)) return
  if (.not. associated(surface%pevapti)) return
  if (.not. associated(surface%phlicee1)) return
  if (.not. associated(surface%phlmle1)) return
  if (.not. associated(surface%phstd)) return
  if (.not. associated(surface%plaih)) return
  if (.not. associated(surface%plail)) return
  if (.not. associated(surface%prsne1)) return
  if (.not. associated(surface%psnse1)) return
  continue ! The disabled ocean view has no elements.
  if (.not. associated(surface%ptiae1)) return
  if (.not. associated(surface%ptlbote1)) return
  if (.not. associated(surface%ptlicee1)) return
  if (.not. associated(surface%ptlmnwe1)) return
  if (.not. associated(surface%ptlsfe1)) return
  if (.not. associated(surface%ptlwmle1)) return
  continue ! The disabled ocean view has no elements.
  if (.not. associated(surface%ptsae1)) return
  if (.not. associated(surface%ptsne1)) return
  continue ! The disabled ocean view has no elements.
  if (.not. associated(surface%pustrti)) return
  continue ! The disabled ocean view has no elements.
  if (.not. associated(surface%pvstrti)) return
  if (.not. associated(surface%pwle1)) return
  if (.not. associated(surface%pwsae1)) return
  if (.not. associated(surface%pwsne1)) return
  if (.not. associated(surfl%zahftrti)) return
  if (.not. associated(surfl%zandayvt)) return
  if (.not. associated(surfl%zanfmvt)) return
  if (.not. associated(surfl%zdhvegs)) return
  if (.not. associated(surfl%zevapsnw)) return
  if (.not. associated(surfl%zfrsoti)) return
  if (.not. associated(surfl%zfrti)) return
  if (.not. associated(surfl%zsnm1m)) return
  if (.not. associated(surfl%zwlm1m)) return
  if (.not. associated(surfl%zwlmx)) return
  view1 => surface%psd_vf(:, idx1)
  view2 => surface%psd_vf(:, idx2)
  view3 => surface%psd_vf(:, idx3)
  view4 => surface%psp_sg(:, :, idx4)
  view5 => surface%psp_sg(:, 1, idx5)
  view6 => surface%psp_sg(:, :, idx6)
  view7 => surface%psp_sg(:, :, idx7)
  view8 => surface%psp_rr(:, idx8)
  view9 => surface%psp_sb(:, :, idx9)
  view10 => surface%psp_sb(:, :, idx10)
  view11 => surface%psp_sb(:, :, idx11)
  view12 => surface%psp_sl(:, idx12)
  view13 => surface%psp_sl(:, idx13)
  view14 => surface%psp_sl(:, idx14)
  view15 => surface%psp_sl(:, idx15)
  view16 => surface%psp_sl(:, idx16)
  view17 => surface%psp_sl(:, idx17)
  view18 => surface%psp_sl(:, idx18)
  view19 => surface%psd_vf(:, idx19)
  view20 => surface%psd_vf(:, idx20)
  view21 => empty_plane
  view22 => empty_plane
  view23 => empty_plane
  view24 => empty_plane
  view25 => empty_vector
  view26 => empty_plane
  view27 => empty_plane
  view28 => empty_plane
  view29 => empty_plane
  view30 => empty_plane
  view31 => empty_plane
  view32 => empty_plane
  view33 => empty_plane
  view34 => empty_plane
  view35 => empty_plane
  view36 => empty_plane
  view37 => empty_vector
  view38 => empty_vector
  view39 => empty_vector
  view40 => empty_vector
  view41 => empty_vector
  view42 => empty_vector
  view43 => empty_vector
  view44 => empty_vector
  view45 => empty_vector
  view46 => empty_plane
  view47 => empty_plane
  view48 => empty_plane
  view49 => empty_plane
  allocate (iveg(p, 2), zlaivt(p, 2), zcvt(p, 2), zrespbstr(p, 2), zrespbstr2(p, 2), &
            zbiomass_last(p, 2), zbiomasstr_last(p, 2), zbiomasstr2_last(p, 2), zblossvt(p, 2), zbgainvt(p, 2), &
            zlaie1(p, 2), zbstre1(p, 4), zbstr2e1(p, 2), zlai(p), zbiom(p), zbloss(p), zbgain(p), &
            zbiomstr(p), zbiomstr2(p), zdhbios(p, 2, 5), stat=allocation_status)
  if (allocation_status /= 0) then
    status = 1_int32; return
  end if
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
  call surftstp_ctl( &
    kidia=d%kidia, &
    kfdia=d%kfdia, &
    klon=d%klon, &
    klevs=d%klevs, &
    ktiles=d%ktiles, &
    klevsn=d%klevsn, &
    klevo=d%klevo, &
    klevi=d%klevi, &
    kstart=inputs%providers%initial_step, &
    kstep=inputs%providers%current_step, &
    ktvl=surface%itvl, &
    ktvh=surface%itvh, &
    kveg=iveg, &
    ksoty=surface%isoty, &
    ptsphy=inputs%records%model%physics_auxiliary%tsphy, &
    psdor=surface%phstd, &
    pfrti=surfl%zfrti, &
    psst=view1, &
    pustrti=surface%pustrti, &
    pvstrti=surface%pvstrti, &
    pahfsti=surface%pahfsti, &
    pevapti=surface%pevapti, &
    pssrflti=surfl%zfrsoti, &
    pslrflti=surfl%zahftrti, &
    plat=aux%pgelat, &
    panfmvt=surfl%zanfmvt, &
    pandayvt=surfl%zandayvt, &
    pmu0=aux%pmu0, &
    pcvt=zcvt, &
    plaivt=zlaivt, &
    plail=surface%plail, &
    plaih=surface%plaih, &
    plailc=view2, &
    plaihc=view3, &
    ldland=keys%llland, &
    ldsice=keys%llsice, &
    ldsi=inputs%records%model%physics%ecmwf_physics%lesice, &
    ldnh=keys%llnh, &
    ldocn_kpp=keys%llocn_kpp, &
    psnm1m=surfl%zsnm1m, &
    ptsnm1m=view4, &
    pasnm1m=view5, &
    prsnm1m=view6, &
    pwsnm1m=view7, &
    paprs=aux%paprs(:, d%klev), &
    ptskm1m=view8, &
    ptsam1m=view9, &
    ptiam1m=view10, &
    pwlm1m=surfl%zwlm1m, &
    pwsam1m=view11, &
    ptlicem1m=view12, &
    ptlmnwm1m=view13, &
    ptlwmlm1m=view14, &
    ptlbotm1m=view15, &
    ptlsfm1m=view16, &
    phlicem1m=view17, &
    phlmlm1m=view18, &
    pgemu=aux%pgemu, &
    pldepth=view19, &
    ldlake=keys%lllake, &
    pclake=view20, &
    prsfc=flux%pfplcl(:, d%klev), &
    prsfl=flux%pfplsl(:, d%klev), &
    pslrfl=flux%pfrth(:, d%klev), &
    pssfc=flux%pfplcn(:, d%klev), &
    pssfl=flux%pfplsn(:, d%klev), &
    pcvl=surface%pcvl, &
    pcvh=surface%pcvh, &
    pcur=surface%pcur, &
    pwlmx=surfl%zwlmx, &
    pevapsnw=surfl%zevapsnw, &
    pusrf=state0%u(:, d%klev), &
    pvsrf=state0%v(:, d%klev), &
    ptsrf=state0%t(:, d%klev), &
    pzo=view21, &
    pho=view22, &
    pho_inv=view23, &
    pdo=view24, &
    pocdepth=view25, &
    puo0=view26, &
    pvo0=view27, &
    puoc=view28, &
    pvoc=view29, &
    pto0=view30, &
    pso0=view31, &
    padvt=view32, &
    padvs=view33, &
    ptri0=view34, &
    ptri1=view35, &
    pswdk_save=view36, &
    pustrc=view37, &
    pvstrc=view38, &
    pustokes=view39, &
    pvstokes=view40, &
    ptauocx=view41, &
    ptauocy=view42, &
    pphioc=view43, &
    pwsemean=view44, &
    pwsfmean=view45, &
    ptsdfl=flux%pftg12, &
    profd=flux%pfwrod, &
    profs=flux%pfwro1, &
    pwfsd=flux%pfwg12, &
    pmelt=flux%pfwmlt, &
    pfwev=flux%pfwev, &
    penes=flux%penes, &
    pdifm=view46, &
    pdift=view47, &
    pdifs=view48, &
    potke=view49, &
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
    psne1=surface%psnse1, &
    ptsne1=surface%ptsne1, &
    pasne1=surface%pasne1(:, 1), &
    prsne1=surface%prsne1, &
    pwsne1=surface%pwsne1, &
    ptsae1=surface%ptsae1, &
    ptiae1=surface%ptiae1, &
    pwle1=surface%pwle1, &
    pwsae1=surface%pwsae1, &
    ptlicee1=surface%ptlicee1, &
    ptlmnwe1=surface%ptlmnwe1, &
    ptlwmle1=surface%ptlwmle1, &
    ptlbote1=surface%ptlbote1, &
    ptlsfe1=surface%ptlsfe1, &
    phlicee1=surface%phlicee1, &
    phlmle1=surface%phlmle1, &
    puoe1=empty_plane, &
    pvoe1=empty_plane, &
    ptoe1=empty_plane, &
    psoe1=empty_plane, &
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
    pdhvegs=surfl%zdhvegs, &
    ydcst=inputs%physics%surface%ycst, &
    ydexc=inputs%physics%surface%yexc, &
    ydsoil=inputs%physics%surface%ysoil, &
    ydveg=inputs%physics%surface%yveg, &
    ydflake=inputs%physics%surface%yflake, &
    ydurb=inputs%physics%surface%yurb, &
    ydags=inputs%physics%surface%yags, &
    ydmlm=inputs%physics%surface%ymlm, &
    ydocean_ml=inputs%physics%surface%yocean_ml)
  status = 0_int32
  end procedure
end submodule
