!> Atomic native photosynthesis parameter storage and complete field setup.
!! Nine readonly tables have shape(NVTYPES,2), with NVTYPES=20 in this source.
!! Live TCST/TVEG records supply the physical constants and vegetation count.
!! TAGS/TAGF stay caller-owned; forty-one payload owners move only after success.
module forecast_atomic_photosynthesis_parameter_setup
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_intptr_t, c_loc, c_f_pointer
  use yos_cst, only: tcst
  use yos_veg, only: tveg
  use yos_ags, only: tags
  use yos_agf, only: tagf
  use sucotwo_mod, only: sucotwo
  use sufarquhar_mod, only: sufarquhar
  implicit none
  private
  public :: initialize_photosynthesis_parameters, release_photosynthesis_parameters
  public :: md2asm_initialize_photosynthesis_parameters, md2asm_release_photosynthesis_parameters
  interface md2asm_initialize_photosynthesis_parameters
    module procedure initialize_photosynthesis_parameters
  end interface
  interface md2asm_release_photosynthesis_parameters
    module procedure release_photosynthesis_parameters
  end interface
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate all owners privately, run SUCOTWO then SUFARQUHAR, and publish.
 !! RVR0VT is reference respiration, RE_VCMAX/RE_JMAX use J/mol, and
 !! the other tables retain their original stomatal and dimensionless units.
 !! Status0 succeeds,1 reports allocation failure,2 refuses before mutation.
 !! Caller establishes the FP mode; every input and output span is disjoint.
 integer(int32) function initialize_photosynthesis_parameters(constants,vegetation,rvr0vt,rvcmax25,rhumrel,ra1,rb1,rg0,rgm25,re_vcmax,re_jmax,assimilation,farquhar)result(status)
    type(tcst), target, intent(in) :: constants
    type(tveg), target, intent(in) :: vegetation
  real(real64),target,intent(in)::rvr0vt(:,:),rvcmax25(:,:),rhumrel(:,:),ra1(:,:),rb1(:,:),rg0(:,:),rgm25(:,:),re_vcmax(:,:),re_jmax(:,:)
    type(tags), target, intent(inout) :: assimilation
    type(tagf), target, intent(inout) :: farquhar
    type(tags) :: private_ags
    type(tagf) :: private_agf
    integer(c_int), pointer :: system_error
    integer(int32) :: allocation_status, saved_error, cleanup_status, n
    integer(int64) :: bits
    integer(c_intptr_t) :: span(2, 13)
    integer :: i, j
    status = 2_int32
    n = vegetation%nvtypes
    if (n /= 20_int32) return
    bits = transfer(constants%rpi, 0_int64)
    if (bits < transfer(3.0_real64, 0_int64) .or. bits > transfer(4.0_real64, 0_int64)) return
    bits = transfer(constants%rday, 0_int64)
  if(bits/=transfer(43200.0_real64,0_int64).and.bits/=transfer(86400.0_real64,0_int64).and.bits/=transfer(172800.0_real64,0_int64))return
    if (any(shape(rvr0vt) /= [n, 2]) .or. .not. is_contiguous(rvr0vt)) return
    if (any(shape(rvcmax25) /= [n, 2]) .or. .not. is_contiguous(rvcmax25)) return
    if (any(shape(rhumrel) /= [n, 2]) .or. .not. is_contiguous(rhumrel)) return
    if (any(shape(ra1) /= [n, 2]) .or. .not. is_contiguous(ra1)) return
    if (any(shape(rb1) /= [n, 2]) .or. .not. is_contiguous(rb1)) return
    if (any(shape(rg0) /= [n, 2]) .or. .not. is_contiguous(rg0)) return
    if (any(shape(rgm25) /= [n, 2]) .or. .not. is_contiguous(rgm25)) return
    if (any(shape(re_vcmax) /= [n, 2]) .or. .not. is_contiguous(re_vcmax)) return
    if (any(shape(re_jmax) /= [n, 2]) .or. .not. is_contiguous(re_jmax)) return
    if (allocated(assimilation%rvtopt)) return
    if (allocated(assimilation%rvfzero)) return
    if (allocated(assimilation%rvfzerost)) return
    if (allocated(assimilation%rvepso)) return
    if (allocated(assimilation%rvgamm)) return
    if (allocated(assimilation%rvqdgamm)) return
    if (allocated(assimilation%rvqdgmes)) return
    if (allocated(assimilation%rvt1gmes)) return
    if (allocated(assimilation%rvt2gmes)) return
    if (allocated(assimilation%rvammax)) return
    if (allocated(assimilation%rvqdammax)) return
    if (allocated(assimilation%rvt1ammax)) return
    if (allocated(assimilation%rvt2ammax)) return
    if (allocated(assimilation%rvah)) return
    if (allocated(assimilation%rvbh)) return
    if (allocated(assimilation%lvstress)) return
    if (allocated(assimilation%rvbslai)) return
    if (allocated(assimilation%rvlaimin)) return
    if (allocated(assimilation%rvsefold)) return
    if (allocated(assimilation%rvgmes)) return
    if (allocated(assimilation%rvgc)) return
    if (allocated(assimilation%rvdmax)) return
    if (allocated(assimilation%rvf2i)) return
    if (allocated(assimilation%rvce)) return
    if (allocated(assimilation%rvcf)) return
    if (allocated(assimilation%rvcna)) return
    if (allocated(assimilation%rvbslai_nitro)) return
    if (allocated(assimilation%rxbomegam)) return
    if (allocated(assimilation%rvr0vt)) return
    if (allocated(assimilation%rvch4qvt)) return
    if (allocated(assimilation%rvanmax)) return
    if (allocated(farquhar%rvcmax25)) return
    if (allocated(farquhar%rhumrel)) return
    if (allocated(farquhar%ra1)) return
    if (allocated(farquhar%rb1)) return
    if (allocated(farquhar%rg0)) return
    if (allocated(farquhar%rgm25)) return
    if (allocated(farquhar%re_vcmax)) return
    if (allocated(farquhar%re_jmax)) return
    if (allocated(farquhar%rdownregulation_co2_coef)) return
    if (allocated(farquhar%rstruct_const)) return
    if (.not. native_span(c_loc(constants), storage_size(constants, kind=int64)/8_int64, span(:, 1))) return
    if (.not. native_span(c_loc(vegetation), storage_size(vegetation, kind=int64)/8_int64, span(:, 2))) return
    if (.not. native_span(c_loc(assimilation), storage_size(assimilation, kind=int64)/8_int64, span(:, 3))) return
    if (.not. native_span(c_loc(farquhar), storage_size(farquhar, kind=int64)/8_int64, span(:, 4))) return
    if (.not. native_span(c_loc(rvr0vt(1, 1)), size(rvr0vt, kind=int64)*8_int64, span(:, 5))) return
    if (.not. native_span(c_loc(rvcmax25(1, 1)), size(rvcmax25, kind=int64)*8_int64, span(:, 6))) return
    if (.not. native_span(c_loc(rhumrel(1, 1)), size(rhumrel, kind=int64)*8_int64, span(:, 7))) return
    if (.not. native_span(c_loc(ra1(1, 1)), size(ra1, kind=int64)*8_int64, span(:, 8))) return
    if (.not. native_span(c_loc(rb1(1, 1)), size(rb1, kind=int64)*8_int64, span(:, 9))) return
    if (.not. native_span(c_loc(rg0(1, 1)), size(rg0, kind=int64)*8_int64, span(:, 10))) return
    if (.not. native_span(c_loc(rgm25(1, 1)), size(rgm25, kind=int64)*8_int64, span(:, 11))) return
    if (.not. native_span(c_loc(re_vcmax(1, 1)), size(re_vcmax, kind=int64)*8_int64, span(:, 12))) return
    if (.not. native_span(c_loc(re_jmax(1, 1)), size(re_jmax, kind=int64)*8_int64, span(:, 13))) return
    do i = 1, 12
      do j = i + 1, 13
        if (span(1, i) < span(2, j) .and. span(1, j) < span(2, i)) return
      end do
    end do
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error
    status = 1_int32
    allocate (private_ags%lvstress(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvbslai(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvlaimin(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvsefold(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvgmes(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvgc(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvdmax(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvf2i(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvce(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvcf(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvcna(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvbslai_nitro(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvanmax(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rxbomegam(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvr0vt(0:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvch4qvt(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvtopt(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvfzero(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvfzerost(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvepso(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvgamm(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvqdgamm(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvqdgmes(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvt1gmes(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvt2gmes(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvammax(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvqdammax(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvt1ammax(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvt2ammax(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvah(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_ags%rvbh(0:n), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%rvcmax25(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%rhumrel(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%ra1(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%rb1(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%rg0(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%rgm25(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%re_vcmax(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%re_jmax(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%rdownregulation_co2_coef(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (private_agf%rstruct_const(1:n, 1:2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    system_error = saved_error
    call sucotwo(rvr0vt, vegetation, constants, private_ags)
    call sufarquhar(rvcmax25, rhumrel, ra1, rb1, rg0, rgm25, re_vcmax, re_jmax, vegetation, private_ags, private_agf)
    assimilation%rco2 = private_ags%rco2
    assimilation%rmair = private_ags%rmair
    assimilation%rmco2 = private_ags%rmco2
    assimilation%rmc = private_ags%rmc
    assimilation%rdmax_ags = private_ags%rdmax_ags
    assimilation%rparcf = private_ags%rparcf
    assimilation%rraccf = private_ags%rraccf
    assimilation%rpcco2 = private_ags%rpcco2
    assimilation%riaopt = private_ags%riaopt
    assimilation%rdspopt = private_ags%rdspopt
    assimilation%rxgt = private_ags%rxgt
    assimilation%rdifracf = private_ags%rdifracf
    assimilation%rxbomega = private_ags%rxbomega
    assimilation%rrdcf = private_ags%rrdcf
    assimilation%rammin = private_ags%rammin
    assimilation%rcondctmin = private_ags%rcondctmin
    assimilation%rcondstmin = private_ags%rcondstmin
    assimilation%ranfminit = private_ags%ranfminit
    assimilation%rairtoh2o = private_ags%rairtoh2o
    assimilation%rco2toh2o = private_ags%rco2toh2o
    assimilation%raw = private_ags%raw
    assimilation%rasw = private_ags%rasw
    assimilation%rbw = private_ags%rbw
    assimilation%rdmaxn = private_ags%rdmaxn
    assimilation%rdmaxx = private_ags%rdmaxx
    assimilation%rrespfactor_nit = private_ags%rrespfactor_nit
    assimilation%rcns_nit = private_ags%rcns_nit
    assimilation%rca_1x_co2_nit = private_ags%rca_1x_co2_nit
    assimilation%rca_2x_co2_nit = private_ags%rca_2x_co2_nit
    assimilation%rcc_nit = private_ags%rcc_nit
    assimilation%rabc = private_ags%rabc
    assimilation%rpoi = private_ags%rpoi
    assimilation%rvch4s = private_ags%rvch4s
    farquhar%nlai = private_agf%nlai
    farquhar%nlai1 = private_agf%nlai1
    farquhar%npath = private_agf%npath
    farquhar%rdownregulation_co2_baselevel = private_agf%rdownregulation_co2_baselevel
    farquhar%rdownregulation_co2_minimum = private_agf%rdownregulation_co2_minimum
    farquhar%rundef_sechiba = private_agf%rundef_sechiba
    farquhar%rundef = private_agf%rundef
    farquhar%rone_month = private_agf%rone_month
    farquhar%rarjv = private_agf%rarjv
    farquhar%rbrjv = private_agf%rbrjv
    farquhar%rasj = private_agf%rasj
    farquhar%rbsj = private_agf%rbsj
    farquhar%rasv = private_agf%rasv
    farquhar%rbsv = private_agf%rbsv
    farquhar%rd_vcmax = private_agf%rd_vcmax
    farquhar%rd_jmax = private_agf%rd_jmax
    farquhar%re_gamma_star = private_agf%re_gamma_star
    farquhar%re_gm = private_agf%re_gm
    farquhar%rs_gm = private_agf%rs_gm
    farquhar%rs_jmax = private_agf%rs_jmax
    farquhar%rd_gm = private_agf%rd_gm
    farquhar%re_kmc = private_agf%re_kmc
    farquhar%re_kmo = private_agf%re_kmo
    farquhar%re_rd = private_agf%re_rd
    farquhar%re_sco = private_agf%re_sco
    farquhar%rgamma_star25 = private_agf%rgamma_star25
    farquhar%rkmc25 = private_agf%rkmc25
    farquhar%rkmo25 = private_agf%rkmo25
    farquhar%rsco25 = private_agf%rsco25
    farquhar%rstress_gm = private_agf%rstress_gm
    farquhar%rstress_gs = private_agf%rstress_gs
    farquhar%rstress_vcmax = private_agf%rstress_vcmax
    farquhar%rtphoto_max = private_agf%rtphoto_max
    farquhar%rtphoto_min = private_agf%rtphoto_min
    farquhar%rlai_level_depth = private_agf%rlai_level_depth
    farquhar%rlaimax = private_agf%rlaimax
    farquhar%rext_coeff = private_agf%rext_coeff
    farquhar%rgb_ref = private_agf%rgb_ref
    farquhar%rtp_00 = private_agf%rtp_00
    farquhar%rpb_std = private_agf%rpb_std
    farquhar%rrg_to_par = private_agf%rrg_to_par
    farquhar%rw_to_mol = private_agf%rw_to_mol
    farquhar%ralpha_ll = private_agf%ralpha_ll
    farquhar%rtheta = private_agf%rtheta
    farquhar%rfpsir = private_agf%rfpsir
    farquhar%rfq = private_agf%rfq
    farquhar%rfpseudo = private_agf%rfpseudo
    farquhar%rh_protons = private_agf%rh_protons
    farquhar%rgbs = private_agf%rgbs
    farquhar%roi = private_agf%roi
    farquhar%ralpha = private_agf%ralpha
    farquhar%rkp = private_agf%rkp
    farquhar%rtetens_1 = private_agf%rtetens_1
    farquhar%rtetens_2 = private_agf%rtetens_2
    farquhar%rref_temp = private_agf%rref_temp
    farquhar%rmol_to_m_1 = private_agf%rmol_to_m_1
    farquhar%rratio_h2o_to_co2 = private_agf%rratio_h2o_to_co2
    farquhar%rn_vert_att = private_agf%rn_vert_att
    farquhar%rrveg_pft = private_agf%rrveg_pft
    farquhar%rtau_temp_air_month = private_agf%rtau_temp_air_month
    call move_alloc(private_ags%lvstress, assimilation%lvstress)
    call move_alloc(private_ags%rvbslai, assimilation%rvbslai)
    call move_alloc(private_ags%rvlaimin, assimilation%rvlaimin)
    call move_alloc(private_ags%rvsefold, assimilation%rvsefold)
    call move_alloc(private_ags%rvgmes, assimilation%rvgmes)
    call move_alloc(private_ags%rvgc, assimilation%rvgc)
    call move_alloc(private_ags%rvdmax, assimilation%rvdmax)
    call move_alloc(private_ags%rvf2i, assimilation%rvf2i)
    call move_alloc(private_ags%rvce, assimilation%rvce)
    call move_alloc(private_ags%rvcf, assimilation%rvcf)
    call move_alloc(private_ags%rvcna, assimilation%rvcna)
    call move_alloc(private_ags%rvbslai_nitro, assimilation%rvbslai_nitro)
    call move_alloc(private_ags%rvanmax, assimilation%rvanmax)
    call move_alloc(private_ags%rxbomegam, assimilation%rxbomegam)
    call move_alloc(private_ags%rvr0vt, assimilation%rvr0vt)
    call move_alloc(private_ags%rvch4qvt, assimilation%rvch4qvt)
    call move_alloc(private_ags%rvtopt, assimilation%rvtopt)
    call move_alloc(private_ags%rvfzero, assimilation%rvfzero)
    call move_alloc(private_ags%rvfzerost, assimilation%rvfzerost)
    call move_alloc(private_ags%rvepso, assimilation%rvepso)
    call move_alloc(private_ags%rvgamm, assimilation%rvgamm)
    call move_alloc(private_ags%rvqdgamm, assimilation%rvqdgamm)
    call move_alloc(private_ags%rvqdgmes, assimilation%rvqdgmes)
    call move_alloc(private_ags%rvt1gmes, assimilation%rvt1gmes)
    call move_alloc(private_ags%rvt2gmes, assimilation%rvt2gmes)
    call move_alloc(private_ags%rvammax, assimilation%rvammax)
    call move_alloc(private_ags%rvqdammax, assimilation%rvqdammax)
    call move_alloc(private_ags%rvt1ammax, assimilation%rvt1ammax)
    call move_alloc(private_ags%rvt2ammax, assimilation%rvt2ammax)
    call move_alloc(private_ags%rvah, assimilation%rvah)
    call move_alloc(private_ags%rvbh, assimilation%rvbh)
    call move_alloc(private_agf%rvcmax25, farquhar%rvcmax25)
    call move_alloc(private_agf%rhumrel, farquhar%rhumrel)
    call move_alloc(private_agf%ra1, farquhar%ra1)
    call move_alloc(private_agf%rb1, farquhar%rb1)
    call move_alloc(private_agf%rg0, farquhar%rg0)
    call move_alloc(private_agf%rgm25, farquhar%rgm25)
    call move_alloc(private_agf%re_vcmax, farquhar%re_vcmax)
    call move_alloc(private_agf%re_jmax, farquhar%re_jmax)
    call move_alloc(private_agf%rdownregulation_co2_coef, farquhar%rdownregulation_co2_coef)
    call move_alloc(private_agf%rstruct_const, farquhar%rstruct_const)
    status = 0_int32
    return
900 continue
    cleanup_status = release_photosynthesis_parameters(private_ags, private_agf)
    system_error = saved_error
    status = 1_int32
  end function initialize_photosynthesis_parameters

  !> Release the forty-one native owners in source allocation order.
 !! Scalar values, fixed arrays, caller records and unused members are unchanged.
 !! Repeated release succeeds. Allocation-service errno is retained.
  integer(int32) function release_photosynthesis_parameters(assimilation, farquhar) result(status)
    type(tags), intent(inout) :: assimilation
    type(tagf), intent(inout) :: farquhar
    integer(c_int), pointer :: system_error
    integer(int32) :: saved_error, release_status
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error
    status = 0_int32
    if (allocated(assimilation%lvstress)) then
      deallocate (assimilation%lvstress, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvbslai)) then
      deallocate (assimilation%rvbslai, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvlaimin)) then
      deallocate (assimilation%rvlaimin, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvsefold)) then
      deallocate (assimilation%rvsefold, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvgmes)) then
      deallocate (assimilation%rvgmes, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvgc)) then
      deallocate (assimilation%rvgc, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvdmax)) then
      deallocate (assimilation%rvdmax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvf2i)) then
      deallocate (assimilation%rvf2i, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvce)) then
      deallocate (assimilation%rvce, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvcf)) then
      deallocate (assimilation%rvcf, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvcna)) then
      deallocate (assimilation%rvcna, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvbslai_nitro)) then
      deallocate (assimilation%rvbslai_nitro, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvanmax)) then
      deallocate (assimilation%rvanmax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rxbomegam)) then
      deallocate (assimilation%rxbomegam, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvr0vt)) then
      deallocate (assimilation%rvr0vt, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvch4qvt)) then
      deallocate (assimilation%rvch4qvt, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvtopt)) then
      deallocate (assimilation%rvtopt, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvfzero)) then
      deallocate (assimilation%rvfzero, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvfzerost)) then
      deallocate (assimilation%rvfzerost, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvepso)) then
      deallocate (assimilation%rvepso, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvgamm)) then
      deallocate (assimilation%rvgamm, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvqdgamm)) then
      deallocate (assimilation%rvqdgamm, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvqdgmes)) then
      deallocate (assimilation%rvqdgmes, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvt1gmes)) then
      deallocate (assimilation%rvt1gmes, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvt2gmes)) then
      deallocate (assimilation%rvt2gmes, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvammax)) then
      deallocate (assimilation%rvammax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvqdammax)) then
      deallocate (assimilation%rvqdammax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvt1ammax)) then
      deallocate (assimilation%rvt1ammax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvt2ammax)) then
      deallocate (assimilation%rvt2ammax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvah)) then
      deallocate (assimilation%rvah, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(assimilation%rvbh)) then
      deallocate (assimilation%rvbh, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%rvcmax25)) then
      deallocate (farquhar%rvcmax25, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%rhumrel)) then
      deallocate (farquhar%rhumrel, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%ra1)) then
      deallocate (farquhar%ra1, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%rb1)) then
      deallocate (farquhar%rb1, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%rg0)) then
      deallocate (farquhar%rg0, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%rgm25)) then
      deallocate (farquhar%rgm25, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%re_vcmax)) then
      deallocate (farquhar%re_vcmax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%re_jmax)) then
      deallocate (farquhar%re_jmax, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%rdownregulation_co2_coef)) then
      deallocate (farquhar%rdownregulation_co2_coef, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    if (allocated(farquhar%rstruct_const)) then
      deallocate (farquhar%rstruct_const, stat=release_status)
      if (release_status /= 0) status = 2_int32
    end if
    system_error = saved_error
  end function release_photosynthesis_parameters

  logical function native_span(address, bytes, span) result(valid)
    type(c_ptr), intent(in) :: address
    integer(int64), intent(in) :: bytes
    integer(c_intptr_t), intent(out) :: span(2)
    integer(c_intptr_t) :: first
    first = transfer(address, 0_c_intptr_t); valid = .false.
    if (first <= 0_c_intptr_t .or. bytes <= 0_int64) return
    if (first > huge(first) - bytes) return
    span = [first, first + bytes]; valid = .true.
  end function native_span
end module forecast_atomic_photosynthesis_parameter_setup
