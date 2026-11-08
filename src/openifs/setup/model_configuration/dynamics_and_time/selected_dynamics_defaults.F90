!> Define native source-named SUDYNA controls and exact literal defaults.
module forecast_dynamics_control_defaults
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use YOMDYNA, only: native_dynamics_controls => TDYNA
  implicit none
  private
  public :: native_dynamics_controls, native_dynamics_upstream, initialize_selected_dynamics_defaults
!> Eight read-only upstream words; counts are dimensionless and flags0 or1.
  type, bind(C) :: native_dynamics_upstream
    integer(c_int) :: ndlon, ndglg, nsmax, nmsmax, lvertfe, ndlnpr, lnonhyd_geom, nconf
  end type
!> The canonical data-only TDYNA declaration supplies every source member.
!! Its native LOGICAL fields and three integer maps are used directly.
!! No original method, constructor or module data supplies a stage.
contains
!> Apply every selected source default and its three hydrostatic maps.
!! STATE is a caller-owned native record with INOUT intent. Only named source
!! fields change. Padding keeps its incoming values. All map indices are
!! dimensionless. No allocation, original method or FP arithmetic is used.
!! Status is0 under the caller-established nearest-even/gradual-underflow
!! arithmetic precondition. Historical raw pointer/FPCR guards are outside
!! this typed native entry.
  integer(c_int) function initialize_selected_dynamics_defaults(state) result(status)
    type(native_dynamics_controls), intent(inout) :: state
    state%lnhee = .false.
    state%lnhqe = .false.
    state%lnhdyn = .false.
    state%lsacc = .false.
    state%lsprt = .true.
    state%ltwotl = .true.
    state%lslag = .true.
    state%npdvar = 2_c_int
    state%nvdvar = 3_c_int
    state%nd4sys = 2_c_int
    state%lnhx = .false.
    state%lnhxder = .false.
    state%lgwadv = .false.
    state%ngwadvsi = 1_c_int
    state%lrdbbc = .false.
    state%lsi_nhee = .false.
    state%lnhqe_c2 = .false.
    state%lnhqe_sihyd = .false.
    state%lnhee_svdlapl_first = .false.
    state%lslhd = .false.
    state%lslhd_w = .false.
    state%lslhd_t = .false.
    state%lslhd_spd = .false.
    state%lslhd_svd = .false.
    state%lslhd_gfl = .false.
    state%lslhd_old = .false.
    state%lslhd_static = .false.
    state%lslhdquad = .false.
    state%slhdkmin = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%slhdkmax = transfer(int(z'4018000000000000', c_int64_t), 0.0_c_double)
    state%slhdkref = transfer(int(z'c08f380000000000', c_int64_t), 0.0_c_double)
    state%slhdepsh = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%slhdepsv = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%lslvf = .true.
    state%slvfeps = transfer(int(z'3f747ae147ae147b', c_int64_t), 0.0_c_double)
    state%p_slvf_bot = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%slvfmin = transfer(int(z'3fb999999999999a', c_int64_t), 0.0_c_double)
    state%slvftr = transfer(int(z'3f1a36e2eb1c432d', c_int64_t), 0.0_c_double)
    state%p_slvf_tr = transfer(int(z'4072c00000000000', c_int64_t), 0.0_c_double)
    state%lgradsp = .true.
    state%lpgfsf = .false.
    state%lpgreuse = .false.
    state%l3dturb = .false.
    state%lsldia = .false.
    state%lrprsltrj = .true.
    state%lraltvdisp = .false.
    state%lvsplip = .false.
    state%lrhsvweno = .true.
    state%lcomad = .false.
    state%lcomadh = .false.
    state%lcomadv = .false.
    state%lcomad_w = .false.
    state%lcomad_t = .false.
    state%lcomad_spd = .false.
    state%lcomad_svd = .false.
    state%lcomad_sp = .false.
    state%lcomad_gfl = .false.
    state%lnesct = .false.
    state%lnescv = .false.
    state%lnesc = .false.
    state%lsettlst = .true.
    state%lsettlsv = .true.
    state%lsettls = .true.
    state%leltra = .false.
    state%lslinlc2 = .false.
    state%lslinl = .false.
    state%lhoislt = .false.
    state%hoisltv = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%hoislth = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%lsltvweno = .false.
    state%lrubc = .false.
    state%lpc_full = .false.
    state%lpc_cheap = .false.
    state%lpc_cheap2 = .false.
    state%lmixettls = .false.
    state%lmixettls_print = .false.
    state%rmixnl_trh = transfer(int(z'3fe0000000000000', c_int64_t), 0.0_c_double)
    state%l_rdry_vd = .true.
    state%slhdkref = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%yyttnd%m_tndu = 1_c_int
    state%yyttnd%m_tndv = 2_c_int
    state%yyttnd%m_tndu_noc = 3_c_int
    state%yyttnd%m_tndv_noc = 4_c_int
    state%yyttnd%m_tndt = 5_c_int
    state%yyttnd%m_tndpd = 1_c_int
    state%yyttnd%m_tndvd = 1_c_int
    state%yyttnd%m_tndgw = 1_c_int
    state%yyttnd%ndim = 5_c_int
    state%yytgmvt95%m_u = 1_c_int
    state%yytgmvt95%m_v = 2_c_int
    state%yytgmvt95%m_t = 3_c_int
    state%yytgmvt95%m_div = 1_c_int
    state%yytgmvt95%m_spd = 1_c_int
    state%yytgmvt95%m_svd = 1_c_int
    state%yytgmvt95%ndim = 3_c_int
    state%yytgflt95%m_q = 1_c_int
    state%yytgflt95%m_l = 2_c_int
    state%yytgflt95%m_i = 3_c_int
    state%yytgflt95%ndim = 3_c_int
    status = 0_c_int
  end function
end module forecast_dynamics_control_defaults
