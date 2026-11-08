!> Allocate the selected local chemistry scratch and prepare borrowed local views.
!> The source domain has no active chemistry or aerosol tracers. Dimensions give
!> columns P, layers L and visible coefficients C. The 52 owners need
!> 348+40*P+8*P*L*(1+C) payload bytes; byte_limit excludes record descriptors.
!> Caller-owned records and input arrays stay live. No original method is called.
module forecast_local_physics_work_storage
  use iso_fortran_env, only: int32, int64, real64
  use forecast_physics_work_types, only: DIMENSION_TYPE, KEYS_LOCAL_TYPE, AUX_DIAG_LOCAL_TYPE, &
                                         SURF_AND_MORE_LOCAL_TYPE, GEMS_LOCAL_TYPE, AUX_RAD_TYPE
  implicit none
  private
  public :: local_physics_options, initialize_fresh_local_chemistry_heads, &
            initialize_runtime_local_physics_work, finish_runtime_local_physics_work
  type local_physics_options
    integer(int32) :: naero = 0, nchem = 0, nchem_dv = 0, nghg = 0, ngems = 0, nactaero = 0
    logical :: lstoph_casbs = .false., lstoph_spbs = .false., leflake = .true., leocml = .false.
  end type
contains
  !> Set only absent pointer metadata before this fresh record has ever owned data.
  !> The caller must never use this entry to clear a live chemistry owner.
  subroutine initialize_fresh_local_chemistry_heads(g)
    type(GEMS_LOCAL_TYPE), intent(out) :: g
    nullify (g%ITRAC)
    nullify (g%IAERO)
    nullify (g%ICHEM)
    nullify (g%ZAZ0M)
    nullify (g%ZAZ0H)
    nullify (g%ZCLAERS)
    nullify (g%ZPRAERS)
    nullify (g%ZVISICL)
    nullify (g%ZLRCH4)
    nullify (g%ZKOZO)
    nullify (g%ZCEN)
    nullify (g%ZTENC)
    nullify (g%ZTENC_SKF)
    nullify (g%ZCFLX)
    nullify (g%ZCFLXO)
    nullify (g%ZDDVLC)
    nullify (g%ZSCAV)
    nullify (g%ZCHEMDV)
    nullify (g%ZAERWS)
    nullify (g%ZAERGUST)
    nullify (g%ZAERUST)
    nullify (g%ZDIST)
    nullify (g%ZAERMAP)
    nullify (g%ZDMSO)
    nullify (g%ZLDAY)
    nullify (g%ZLISS)
    nullify (g%ZSO2)
    nullify (g%ZTDMS)
    nullify (g%ZDMSI)
    nullify (g%ZODMS)
    nullify (g%ZCAERO)
    nullify (g%ZAEROP)
    nullify (g%ZAERSRC)
    nullify (g%ZAERDDP)
    nullify (g%ZAERSDM)
    nullify (g%ZAERFLX)
    nullify (g%ZAERLIF)
    nullify (g%ZTAUAER)
    nullify (g%ZAERAOT)
    nullify (g%ZAERAOTLEV)
    nullify (g%ZAERAAOTLEV)
    nullify (g%ZAERASYLEV)
    nullify (g%ZAERLISI)
    nullify (g%ZDRYDIAM)
    nullify (g%ZWETDIAM)
    nullify (g%ZDRYVOL)
    nullify (g%ZWETVOL)
    nullify (g%ZVOL_WAT)
    nullify (g%ZRHOPAR)
    nullify (g%ZMD)
    nullify (g%ZMDT)
    nullify (g%ZND)
    nullify (g%ZSO2TOSO4)
  end subroutine
  !> Source key/radiation writes precede allocation. On allocation failure these
  !> writes remain; the acquired owner prefix is released in the source order.
  integer(int32) function initialize_runtime_local_physics_work(d, options, keys, auxl, surfl, g, rad, &
                                                                cloud_top, cloud_base, byte_limit) result(status)
    type(DIMENSION_TYPE), intent(in) :: d
    type(local_physics_options), intent(in) :: options
    type(KEYS_LOCAL_TYPE), intent(inout) :: keys
    type(AUX_DIAG_LOCAL_TYPE), intent(inout) :: auxl
    type(SURF_AND_MORE_LOCAL_TYPE), intent(inout) :: surfl
    type(GEMS_LOCAL_TYPE), intent(inout) :: g
    type(AUX_RAD_TYPE), intent(in) :: rad
    real(real64), contiguous, intent(in) :: cloud_top(:), cloud_base(:)
    integer(int64), intent(in) :: byte_limit
    integer :: p, l, c, j, ierr
    integer(int64) :: needed
    real(real64), volatile :: rounded_index
    status = 2
    p = d%klon; l = d%klev; c = d%kvclis
    if (p < 1 .or. p > 1024 .or. l < 1 .or. l > 512 .or. c < 0 .or. c > 64) return
    if (d%kidia < 1 .or. d%kidia > p + 1 .or. d%kfdia < d%kidia - 1 .or. d%kfdia > p) return
    if (any([options%naero, options%nchem, options%nchem_dv, options%nghg, options%ngems, options%nactaero] /= 0)) return
    if (options%lstoph_casbs .or. options%lstoph_spbs .or. .not. options%leflake .or. options%leocml) return
    needed = 348_int64 + 40_int64*p + 8_int64*p*l*(1_int64 + c)
    if (byte_limit < needed) return
    if (associated(g%ITRAC)) return
    if (associated(g%IAERO)) return
    if (associated(g%ICHEM)) return
    if (associated(g%ZAZ0M)) return
    if (associated(g%ZAZ0H)) return
    if (associated(g%ZCLAERS)) return
    if (associated(g%ZPRAERS)) return
    if (associated(g%ZVISICL)) return
    if (associated(g%ZLRCH4)) return
    if (associated(g%ZKOZO)) return
    if (associated(g%ZCEN)) return
    if (associated(g%ZTENC)) return
    if (associated(g%ZTENC_SKF)) return
    if (associated(g%ZCFLX)) return
    if (associated(g%ZCFLXO)) return
    if (associated(g%ZDDVLC)) return
    if (associated(g%ZSCAV)) return
    if (associated(g%ZCHEMDV)) return
    if (associated(g%ZAERWS)) return
    if (associated(g%ZAERGUST)) return
    if (associated(g%ZAERUST)) return
    if (associated(g%ZDIST)) return
    if (associated(g%ZAERMAP)) return
    if (associated(g%ZDMSO)) return
    if (associated(g%ZLDAY)) return
    if (associated(g%ZLISS)) return
    if (associated(g%ZSO2)) return
    if (associated(g%ZTDMS)) return
    if (associated(g%ZDMSI)) return
    if (associated(g%ZODMS)) return
    if (associated(g%ZCAERO)) return
    if (associated(g%ZAEROP)) return
    if (associated(g%ZAERSRC)) return
    if (associated(g%ZAERDDP)) return
    if (associated(g%ZAERSDM)) return
    if (associated(g%ZAERFLX)) return
    if (associated(g%ZAERLIF)) return
    if (associated(g%ZTAUAER)) return
    if (associated(g%ZAERAOT)) return
    if (associated(g%ZAERAOTLEV)) return
    if (associated(g%ZAERAAOTLEV)) return
    if (associated(g%ZAERASYLEV)) return
    if (associated(g%ZAERLISI)) return
    if (associated(g%ZDRYDIAM)) return
    if (associated(g%ZWETDIAM)) return
    if (associated(g%ZDRYVOL)) return
    if (associated(g%ZWETVOL)) return
    if (associated(g%ZVOL_WAT)) return
    if (associated(g%ZRHOPAR)) return
    if (associated(g%ZMD)) return
    if (associated(g%ZMDT)) return
    if (associated(g%ZND)) return
    if (.not. associated(keys%LLSHCV)) return
    if (.not. is_contiguous(keys%LLSHCV)) return
    if (lbound(keys%LLSHCV, 1) /= 1) return
    if (size(keys%LLSHCV, 1) < p) return
    if (.not. associated(keys%LLCUM)) return
    if (.not. is_contiguous(keys%LLCUM)) return
    if (lbound(keys%LLCUM, 1) /= 1) return
    if (size(keys%LLCUM, 1) < p) return
    if (.not. associated(keys%LLSC)) return
    if (.not. is_contiguous(keys%LLSC)) return
    if (lbound(keys%LLSC, 1) /= 1) return
    if (size(keys%LLSC, 1) < p) return
    if (.not. associated(keys%LLOCN_KPP)) return
    if (.not. is_contiguous(keys%LLOCN_KPP)) return
    if (lbound(keys%LLOCN_KPP, 1) /= 1) return
    if (size(keys%LLOCN_KPP, 1) < p) return
    if (.not. associated(auxl%ZSUDU)) return
    if (.not. is_contiguous(auxl%ZSUDU)) return
    if (lbound(auxl%ZSUDU, 1) /= 1) return
    if (size(auxl%ZSUDU, 1) < p) return
    if (.not. associated(auxl%ZCEMTR)) return
    if (.not. is_contiguous(auxl%ZCEMTR)) return
    if (lbound(auxl%ZCEMTR, 1) /= 1) return
    if (size(auxl%ZCEMTR, 1) < p) return
    if (.not. associated(auxl%ZCTRSO)) return
    if (.not. is_contiguous(auxl%ZCTRSO)) return
    if (lbound(auxl%ZCTRSO, 1) /= 1) return
    if (size(auxl%ZCTRSO, 1) < p) return
    if (.not. associated(auxl%ZTRSOD)) return
    if (.not. is_contiguous(auxl%ZTRSOD)) return
    if (lbound(auxl%ZTRSOD, 1) /= 1) return
    if (size(auxl%ZTRSOD, 1) < p) return
    if (.not. associated(auxl%ITOPC)) return
    if (.not. is_contiguous(auxl%ITOPC)) return
    if (lbound(auxl%ITOPC, 1) /= 1) return
    if (size(auxl%ITOPC, 1) < p) return
    if (.not. associated(auxl%IBASC)) return
    if (.not. is_contiguous(auxl%IBASC)) return
    if (lbound(auxl%IBASC, 1) /= 1) return
    if (size(auxl%IBASC, 1) < p) return
    if (.not. associated(auxl%ZRAINFRAC_TOPRFZ)) return
    if (.not. is_contiguous(auxl%ZRAINFRAC_TOPRFZ)) return
    if (lbound(auxl%ZRAINFRAC_TOPRFZ, 1) /= 1) return
    if (size(auxl%ZRAINFRAC_TOPRFZ, 1) < p) return
    if (.not. associated(rad%PSRSWDCS)) return
    if (.not. is_contiguous(rad%PSRSWDCS)) return
    if (lbound(rad%PSRSWDCS, 1) /= 1) return
    if (size(rad%PSRSWDCS, 1) < p) return
    if (.not. associated(rad%PEMTC)) return
    if (.not. is_contiguous(rad%PEMTC)) return
    if (lbound(rad%PEMTC, 1) /= 1) return
    if (size(rad%PEMTC, 1) < p) return
    if (.not. associated(rad%PTRSC)) return
    if (.not. is_contiguous(rad%PTRSC)) return
    if (lbound(rad%PTRSC, 1) /= 1) return
    if (size(rad%PTRSC, 1) < p) return
    if (.not. associated(rad%PSRSWD)) return
    if (.not. is_contiguous(rad%PSRSWD)) return
    if (lbound(rad%PSRSWD, 1) /= 1) return
    if (size(rad%PSRSWD, 1) < p) return
    if (.not. associated(surfl%ZSPECTRALEMISS)) return
    if (.not. is_contiguous(surfl%ZSPECTRALEMISS)) return
    if (lbound(surfl%ZSPECTRALEMISS, 1) /= 1) return
    if (size(surfl%ZSPECTRALEMISS, 1) < p) return
    if (.not. associated(surfl%ZLAILI)) return
    if (.not. is_contiguous(surfl%ZLAILI)) return
    if (lbound(surfl%ZLAILI, 1) /= 1) return
    if (size(surfl%ZLAILI, 1) < p) return
    if (.not. associated(surfl%ZLAIHI)) return
    if (.not. is_contiguous(surfl%ZLAIHI)) return
    if (lbound(surfl%ZLAIHI, 1) /= 1) return
    if (size(surfl%ZLAIHI, 1) < p) return
    if (.not. associated(surfl%ZTHKICE)) return
    if (.not. is_contiguous(surfl%ZTHKICE)) return
    if (lbound(surfl%ZTHKICE, 1) /= 1) return
    if (size(surfl%ZTHKICE, 1) < p) return
    if (.not. associated(surfl%ZSNTICE)) return
    if (.not. is_contiguous(surfl%ZSNTICE)) return
    if (lbound(surfl%ZSNTICE, 1) /= 1) return
    if (size(surfl%ZSNTICE, 1) < p) return
    if (.not. associated(surfl%ZANDAYVT)) return
    if (.not. is_contiguous(surfl%ZANDAYVT)) return
    if (lbound(surfl%ZANDAYVT, 1) /= 1) return
    if (size(surfl%ZANDAYVT, 1) < p) return
    if (.not. associated(surfl%ZANFMVT)) return
    if (.not. is_contiguous(surfl%ZANFMVT)) return
    if (lbound(surfl%ZANFMVT, 1) /= 1) return
    if (size(surfl%ZANFMVT, 1) < p) return
    if (.not. associated(surfl%ZAHFTRTI)) return
    if (.not. is_contiguous(surfl%ZAHFTRTI)) return
    if (lbound(surfl%ZAHFTRTI, 1) /= 1) return
    if (size(surfl%ZAHFTRTI, 1) < p) return
    if (size(cloud_top) < p .or. size(cloud_base) < p) return
    if (lbound(auxl%ZCEMTR, 2) > 0 .or. ubound(auxl%ZCEMTR, 2) < 1) return
    if (lbound(auxl%ZCTRSO, 2) > 0 .or. ubound(auxl%ZCTRSO, 2) < 1) return
    if (lbound(rad%PEMTC, 2) > 1 .or. ubound(rad%PEMTC, 2) < l + 1) return
    if (lbound(rad%PTRSC, 2) > 1 .or. ubound(rad%PTRSC, 2) < l + 1) return
    if (lbound(surfl%ZSPECTRALEMISS, 2) > 1 .or. ubound(surfl%ZSPECTRALEMISS, 2) < 2) return
    do j = d%kidia, d%kfdia
      keys%LLSHCV(j) = .true.
      keys%LLCUM(j) = .false.
      keys%LLSC(j) = .false.
      keys%LLOCN_KPP(j) = .false.
    end do
    do j = d%kidia, d%kfdia
      auxl%ZSUDU(j) = rad%PSRSWDCS(j)
      auxl%ZCEMTR(j, 0) = rad%PEMTC(j, 1)
      auxl%ZCEMTR(j, 1) = rad%PEMTC(j, l + 1)
      auxl%ZCTRSO(j, 0) = rad%PTRSC(j, 1)
      auxl%ZCTRSO(j, 1) = rad%PTRSC(j, l + 1)
      auxl%ZTRSOD(j) = rad%PSRSWD(j)
      rounded_index = cloud_top(j) + 0.01_real64
      auxl%ITOPC(j) = int(rounded_index, int32)
      rounded_index = cloud_base(j) + 0.01_real64
      auxl%IBASC(j) = int(rounded_index, int32)
    end do
    if (d%kidia <= d%kfdia) auxl%ZRAINFRAC_TOPRFZ = 0.0_real64
    surfl%ZEMIR => surfl%ZSPECTRALEMISS(:, 1)
    surfl%ZEMIW => surfl%ZSPECTRALEMISS(:, 2)
    surfl%ZLAILI = 0.0_real64
    surfl%ZLAIHI = 0.0_real64
    surfl%ZTHKICE = 0.0_real64
    surfl%ZSNTICE = 0.0_real64
    surfl%ZANDAYVT = 0.0_real64
    surfl%ZANFMVT = 0.0_real64
    surfl%ZAHFTRTI = 0.0_real64
    allocate (g%ITRAC, stat=ierr)
    if (ierr /= 0) goto 900
    g%ITRAC = 0_int32
    allocate (g%IAERO(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ICHEM(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAZ0M(p), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAZ0H(p), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZCLAERS(p), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZCLAERS = 0.0_real64
    allocate (g%ZPRAERS(p), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZPRAERS = 0.0_real64
    allocate (g%ZVISICL(p), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZVISICL = 0.0_real64
    allocate (g%ZLRCH4(p, l), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZKOZO(p, l, c), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZCEN(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZCEN = 0.0_real64
    allocate (g%ZTENC(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZTENC = 0.0_real64
    allocate (g%ZTENC_SKF(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZTENC_SKF = 0.0_real64
    allocate (g%ZCFLX(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZCFLX = 0.0_real64
    allocate (g%ZCFLXO(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZCFLXO = 0.0_real64
    allocate (g%ZDDVLC(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZDDVLC = 0.0_real64
    allocate (g%ZSCAV(1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZSCAV = 0.0_real64
    allocate (g%ZCHEMDV(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    g%ZCHEMDV = 0.0_real64
    allocate (g%ZAERWS(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERGUST(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERUST(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZDIST(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERMAP(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZDMSO(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZLDAY(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZLISS(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZSO2(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZTDMS(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZDMSI(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZODMS(1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZCAERO(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAEROP(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERSRC(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERDDP(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERSDM(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERFLX(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERLIF(1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZTAUAER(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERAOT(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERAOTLEV(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERAAOTLEV(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERASYLEV(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZAERLISI(1, 1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZDRYDIAM(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZWETDIAM(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZDRYVOL(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZWETVOL(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZVOL_WAT(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZRHOPAR(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZMD(1, 1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZMDT(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    allocate (g%ZND(1, 1, 1), stat=ierr)
    if (ierr /= 0) goto 900
    status = 0
    return
900 continue
    call finish_runtime_local_physics_work(surfl, g)
    status = 1
  end function
  !> Drop the two borrowed emissivity aliases and free only the 52 acquired owners.
  !> ZSO2TOSO4 is not an owner in this source domain and remains untouched.
  subroutine finish_runtime_local_physics_work(surfl, g)
    type(SURF_AND_MORE_LOCAL_TYPE), intent(inout) :: surfl
    type(GEMS_LOCAL_TYPE), intent(inout) :: g
    nullify (surfl%ZEMIR, surfl%ZEMIW)
    if (associated(g%ITRAC)) deallocate (g%ITRAC)
    nullify (g%ITRAC)
    if (associated(g%ZCEN)) deallocate (g%ZCEN)
    nullify (g%ZCEN)
    if (associated(g%ZTENC)) deallocate (g%ZTENC)
    nullify (g%ZTENC)
    if (associated(g%ZTENC_SKF)) deallocate (g%ZTENC_SKF)
    nullify (g%ZTENC_SKF)
    if (associated(g%ZCFLX)) deallocate (g%ZCFLX)
    nullify (g%ZCFLX)
    if (associated(g%ZSCAV)) deallocate (g%ZSCAV)
    nullify (g%ZSCAV)
    if (associated(g%IAERO)) deallocate (g%IAERO)
    nullify (g%IAERO)
    if (associated(g%ICHEM)) deallocate (g%ICHEM)
    nullify (g%ICHEM)
    if (associated(g%ZAZ0M)) deallocate (g%ZAZ0M)
    nullify (g%ZAZ0M)
    if (associated(g%ZAZ0H)) deallocate (g%ZAZ0H)
    nullify (g%ZAZ0H)
    if (associated(g%ZDMSO)) deallocate (g%ZDMSO)
    nullify (g%ZDMSO)
    if (associated(g%ZLDAY)) deallocate (g%ZLDAY)
    nullify (g%ZLDAY)
    if (associated(g%ZLISS)) deallocate (g%ZLISS)
    nullify (g%ZLISS)
    if (associated(g%ZSO2)) deallocate (g%ZSO2)
    nullify (g%ZSO2)
    if (associated(g%ZCLAERS)) deallocate (g%ZCLAERS)
    nullify (g%ZCLAERS)
    if (associated(g%ZPRAERS)) deallocate (g%ZPRAERS)
    nullify (g%ZPRAERS)
    if (associated(g%ZVISICL)) deallocate (g%ZVISICL)
    nullify (g%ZVISICL)
    if (associated(g%ZAERMAP)) deallocate (g%ZAERMAP)
    nullify (g%ZAERMAP)
    if (associated(g%ZLRCH4)) deallocate (g%ZLRCH4)
    nullify (g%ZLRCH4)
    if (associated(g%ZKOZO)) deallocate (g%ZKOZO)
    nullify (g%ZKOZO)
    if (associated(g%ZAERWS)) deallocate (g%ZAERWS)
    nullify (g%ZAERWS)
    if (associated(g%ZAERGUST)) deallocate (g%ZAERGUST)
    nullify (g%ZAERGUST)
    if (associated(g%ZAERUST)) deallocate (g%ZAERUST)
    nullify (g%ZAERUST)
    if (associated(g%ZDIST)) deallocate (g%ZDIST)
    nullify (g%ZDIST)
    if (associated(g%ZTDMS)) deallocate (g%ZTDMS)
    nullify (g%ZTDMS)
    if (associated(g%ZDMSI)) deallocate (g%ZDMSI)
    nullify (g%ZDMSI)
    if (associated(g%ZODMS)) deallocate (g%ZODMS)
    nullify (g%ZODMS)
    if (associated(g%ZCAERO)) deallocate (g%ZCAERO)
    nullify (g%ZCAERO)
    if (associated(g%ZAEROP)) deallocate (g%ZAEROP)
    nullify (g%ZAEROP)
    if (associated(g%ZAERSRC)) deallocate (g%ZAERSRC)
    nullify (g%ZAERSRC)
    if (associated(g%ZAERDDP)) deallocate (g%ZAERDDP)
    nullify (g%ZAERDDP)
    if (associated(g%ZAERSDM)) deallocate (g%ZAERSDM)
    nullify (g%ZAERSDM)
    if (associated(g%ZAERFLX)) deallocate (g%ZAERFLX)
    nullify (g%ZAERFLX)
    if (associated(g%ZAERLIF)) deallocate (g%ZAERLIF)
    nullify (g%ZAERLIF)
    if (associated(g%ZTAUAER)) deallocate (g%ZTAUAER)
    nullify (g%ZTAUAER)
    if (associated(g%ZAERAOT)) deallocate (g%ZAERAOT)
    nullify (g%ZAERAOT)
    if (associated(g%ZAERAOTLEV)) deallocate (g%ZAERAOTLEV)
    nullify (g%ZAERAOTLEV)
    if (associated(g%ZAERAAOTLEV)) deallocate (g%ZAERAAOTLEV)
    nullify (g%ZAERAAOTLEV)
    if (associated(g%ZAERASYLEV)) deallocate (g%ZAERASYLEV)
    nullify (g%ZAERASYLEV)
    if (associated(g%ZAERLISI)) deallocate (g%ZAERLISI)
    nullify (g%ZAERLISI)
    if (associated(g%ZDRYDIAM)) deallocate (g%ZDRYDIAM)
    nullify (g%ZDRYDIAM)
    if (associated(g%ZWETDIAM)) deallocate (g%ZWETDIAM)
    nullify (g%ZWETDIAM)
    if (associated(g%ZDRYVOL)) deallocate (g%ZDRYVOL)
    nullify (g%ZDRYVOL)
    if (associated(g%ZWETVOL)) deallocate (g%ZWETVOL)
    nullify (g%ZWETVOL)
    if (associated(g%ZVOL_WAT)) deallocate (g%ZVOL_WAT)
    nullify (g%ZVOL_WAT)
    if (associated(g%ZRHOPAR)) deallocate (g%ZRHOPAR)
    nullify (g%ZRHOPAR)
    if (associated(g%ZMD)) deallocate (g%ZMD)
    nullify (g%ZMD)
    if (associated(g%ZMDT)) deallocate (g%ZMDT)
    nullify (g%ZMDT)
    if (associated(g%ZND)) deallocate (g%ZND)
    nullify (g%ZND)
    if (associated(g%ZDDVLC)) deallocate (g%ZDDVLC)
    nullify (g%ZDDVLC)
    if (associated(g%ZCFLXO)) deallocate (g%ZCFLXO)
    nullify (g%ZCFLXO)
    if (associated(g%ZCHEMDV)) deallocate (g%ZCHEMDV)
    nullify (g%ZCHEMDV)
  end subroutine
end module forecast_local_physics_work_storage
