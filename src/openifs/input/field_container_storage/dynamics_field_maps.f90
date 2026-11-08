!> Initialize the named integer selectors assigned by SUINTDYN.
module forecast_dynamics_field_maps
  use iso_fortran_env, only: int32
  implicit none
  type :: native_txyb
    integer(int32) :: m_delp = 0, m_rdelp = 0, m_lnpr = 0, m_alph = 0, m_rtgr = 0, m_rpre = 0, m_rpp = 0, ndim = 0
  end type
  type :: native_txybder
    integer(int32) :: m_lnprl=0,m_lnprm=0,m_alphl=0,m_alphm=0,m_alphpll=0,m_alphplm=0,m_coefd=0,m_coefa=0,m_coefapl=0,ndim=0
  end type
  type :: native_trcp
    integer(int32) :: m_cp = 0, m_r = 0, m_kap = 0, ndim = 0
  end type
  type :: native_tcty
    integer(int32) :: m_evel = 0, m_vvel = 0, m_psdiv = 0, m_psdvbc = 0, m_divdp = 0, ndim = 0
  end type
  type :: native_thwind
    integer(int32) :: m_uh = 0, m_vh = 0, m_wwi = 0, ndim = 0
  end type
  type :: native_dynamics_field_maps
    type(native_txyb) :: yytxyb0
    type(native_txyb) :: yytxyb5
    type(native_txyb) :: yytxyb9
    type(native_txyb) :: yytxyb95
    type(native_txyb) :: yytxyb0_phy
    type(native_txyb) :: yytxyb9_phy
    type(native_txyb) :: yytxybpp
    type(native_txyb) :: yytxyb
    type(native_txyb) :: yytxybt
    type(native_txybder) :: yytxybder0
    type(native_txybder) :: yytxybder5
    type(native_txybder) :: yytxybderpp
    type(native_txybder) :: yytxybder
    type(native_txybder) :: yytxybdert
    type(native_trcp) :: yytrcp0
    type(native_trcp) :: yytrcp5
    type(native_trcp) :: yytrcp9
    type(native_trcp) :: yytrcp95
    type(native_tcty) :: yytcty0
    type(native_tcty) :: yytcty5
    type(native_tcty) :: yytctypp
    type(native_tcty) :: yytcty
    type(native_thwind) :: yythw0
    type(native_thwind) :: yythw9
    type(native_thwind) :: yythw5
    type(native_thwind) :: yythw95
    type(native_thwind) :: yythwpp
    type(native_thwind) :: yythw
  end type
contains
  integer(int32) function initialize_dynamics_field_maps(state) result(status)
    type(native_dynamics_field_maps), intent(inout) :: state
    state%yytxyb0 = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 7_int32)
    state%yytxyb5 = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 7_int32)
    state%yytxyb9 = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 7_int32)
    state%yytxyb95 = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 7_int32)
    state%yytxyb0_phy = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 1_int32, 1_int32, 1_int32, 4_int32)
    state%yytxyb9_phy = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 1_int32, 1_int32, 1_int32, 4_int32)
    state%yytxybpp = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 7_int32)
    state%yytxyb = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 7_int32)
    state%yytxybt = native_txyb(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 7_int32)
    state%yytxybder0 = native_txybder(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 1_int32, 1_int32, 1_int32, 6_int32)
    state%yytxybder5 = native_txybder(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 8_int32, 9_int32, 9_int32)
    state%yytxybderpp = native_txybder(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 1_int32, 1_int32, 1_int32, 6_int32)
    state%yytxybder = native_txybder(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 8_int32, 9_int32, 9_int32)
    state%yytxybdert = native_txybder(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, 8_int32, 9_int32, 9_int32)
    state%yytrcp0 = native_trcp(1_int32, 2_int32, 3_int32, 3_int32)
    state%yytrcp5 = native_trcp(1_int32, 2_int32, 3_int32, 3_int32)
    state%yytrcp9 = native_trcp(1_int32, 2_int32, 3_int32, 3_int32)
    state%yytrcp95 = native_trcp(1_int32, 2_int32, 3_int32, 3_int32)
    state%yytcty0 = native_tcty(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 5_int32)
    state%yytcty5 = native_tcty(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 5_int32)
    state%yytctypp = native_tcty(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 5_int32)
    state%yytcty = native_tcty(1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 5_int32)
    state%yythw0 = native_thwind(1_int32, 2_int32, 3_int32, 3_int32)
    state%yythw9 = native_thwind(1_int32, 2_int32, 3_int32, 3_int32)
    state%yythw5 = native_thwind(1_int32, 2_int32, 3_int32, 3_int32)
    state%yythw95 = native_thwind(1_int32, 2_int32, 3_int32, 3_int32)
    state%yythwpp = native_thwind(1_int32, 2_int32, 3_int32, 3_int32)
    state%yythw = native_thwind(1_int32, 2_int32, 3_int32, 3_int32)
    status = 0
  end function
end module
