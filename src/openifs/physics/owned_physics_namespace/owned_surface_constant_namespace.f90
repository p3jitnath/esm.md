!> Bind canonical surface constants and retain the existing own module data.
module forecast_owned_surface_constant_namespace
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_ptr, c_int8_t, c_intptr_t, c_null_ptr, c_loc, c_f_pointer
  use yos_cst, only: tcst
  use yos_flake, only: tflake, ropticpar_medium
  use yos_thf, only: rhoh2o, rvtmp2, r2es, r3les, r3ies, r4les, r4ies, r5les, r5ies
 use yos_excs,only:ritbl,dritbl,rimax,rchba,rchbb,rchbc,rchbd,rchb23a,rchbbcd,rchbcd,rcheta,rchetb,rchbhdl,rcdhalf,rcdhpi2,rlpbb,rlpcc,rlpdd
  implicit none
  private
  public :: native_surface_constant_namespace, initialize_fresh_surface_constant_namespace
  public :: bind_produced_surface_constant_namespace, release_surface_constant_namespace
 public::rhoh2o,rvtmp2,r2es,r3les,r3ies,r4les,r4ies,r5les,r5ies,ritbl,dritbl,rimax,rchba,rchbb,rchbc,rchbd,rchb23a,rchbbcd,rchbcd,rcheta,rchetb,rchbhdl,rcdhalf,rcdhpi2,rlpbb,rlpcc,rlpdd
  type :: native_surface_constant_namespace
    type(tcst), pointer :: fundamental => null()
    type(tflake), pointer :: lake => null()
  end type
contains
  !> Locate only the compiler-defined optical alignment gap.
  logical function optical_gap(opt, first, count) result(ok)
    type(ropticpar_medium), target, intent(in) :: opt
    integer(c_intptr_t), intent(out) :: first, count
    integer(c_intptr_t) :: next
    first = transfer(c_loc(opt%nband_optic), first) + storage_size(opt%nband_optic)/8
    next = transfer(c_loc(opt%rfrac_optic(1)), next); count = next - first
    ok = count >= 0 .and. count <= storage_size(opt)/8
  end function
  !> Establish fresh zero storage before SUSCST,SUSTHF,SUVEXCS and SUSFLAKE.
 !! These zeros describe fresh storage, not physical parameter choices.
 !! One active source namespace exists per process; targets remain stable.
  integer(int32) function initialize_fresh_surface_constant_namespace(view, fundamental, lake) result(status)
    type(native_surface_constant_namespace), intent(inout) :: view
    type(tcst), target, intent(inout) :: fundamental
    type(tflake), target, intent(inout) :: lake
    integer(c_intptr_t) :: addresses(6), counts(6), first, last
    integer(c_int8_t), pointer :: padding(:)
    type(c_ptr) :: address
    integer :: j
    status = 2
    if (associated(view%fundamental) .or. associated(view%lake)) return
    if (.not. optical_gap(lake%ROPTICPAR_WATER_REF, addresses(1), counts(1))) return
    if (.not. optical_gap(lake%ROPTICPAR_WATER_TRANS, addresses(2), counts(2))) return
    if (.not. optical_gap(lake%ROPTICPAR_WHITEICE_REF, addresses(3), counts(3))) return
    if (.not. optical_gap(lake%ROPTICPAR_BLUEICE_REF, addresses(4), counts(4))) return
    if (.not. optical_gap(lake%ROPTICPAR_ICE_OPAQUE, addresses(5), counts(5))) return
    first = transfer(c_loc(lake%leflake), first) + storage_size(lake%leflake)/8
    last = transfer(c_loc(lake), last) + storage_size(lake)/8
    addresses(6) = first; counts(6) = last - first
    if (counts(6) < 0 .or. counts(6) > storage_size(lake)/8) return
    do j = 1, 6
    if (counts(j) > 0) then
      address = transfer(addresses(j), c_null_ptr)
      call c_f_pointer(address, padding, [int(counts(j))])
      padding = 0_c_int8_t
    end if
    end do
    fundamental%RTT = 0.0_real64
    fundamental%RPI = 0.0_real64
    fundamental%RDAY = 0.0_real64
    fundamental%R = 0.0_real64
    fundamental%RD = 0.0_real64
    fundamental%RV = 0.0_real64
    fundamental%RETV = 0.0_real64
    fundamental%RLSTT = 0.0_real64
    fundamental%RLMLT = 0.0_real64
    fundamental%RLVTT = 0.0_real64
    fundamental%RCPD = 0.0_real64
    fundamental%RCPV = 0.0_real64
    fundamental%RSIGMA = 0.0_real64
    fundamental%RG = 0.0_real64
    fundamental%RATM = 0.0_real64
    fundamental%ROMEGA = 0.0_real64
    rhoh2o = 0.0_real64
    rvtmp2 = 0.0_real64
    r2es = 0.0_real64
    r3les = 0.0_real64
    r3ies = 0.0_real64
    r4les = 0.0_real64
    r4ies = 0.0_real64
    r5les = 0.0_real64
    r5ies = 0.0_real64
    ritbl = 0.0_real64
    dritbl = 0.0_real64
    rimax = 0.0_real64
    rchba = 0.0_real64
    rchbb = 0.0_real64
    rchbc = 0.0_real64
    rchbd = 0.0_real64
    rchb23a = 0.0_real64
    rchbbcd = 0.0_real64
    rchbcd = 0.0_real64
    rcheta = 0.0_real64
    rchetb = 0.0_real64
    rchbhdl = 0.0_real64
    rcdhalf = 0.0_real64
    rcdhpi2 = 0.0_real64
    rlpbb = 0.0_real64
    rlpcc = 0.0_real64
    rlpdd = 0.0_real64
    lake%RC_CBL_1 = 0.0_real64
    lake%RC_CBL_2 = 0.0_real64
    lake%RC_SBL_ZM_N = 0.0_real64
    lake%RC_SBL_ZM_S = 0.0_real64
    lake%RC_SBL_ZM_I = 0.0_real64
    lake%RC_RELAX_H = 0.0_real64
    lake%RC_RELAX_C = 0.0_real64
    lake%RC_T_MIN = 0.0_real64
    lake%RC_T_MAX = 0.0_real64
    lake%RPHI_T_PR0_1 = 0.0_real64
    lake%RPHI_T_PR0_2 = 0.0_real64
    lake%RC_TT_1 = 0.0_real64
    lake%RC_TT_2 = 0.0_real64
    lake%RC_B1 = 0.0_real64
    lake%RC_B2 = 0.0_real64
    lake%RC_S_LIN = 0.0_real64
    lake%RPHI_S_PR0_LIN = 0.0_real64
    lake%RC_I_LIN = 0.0_real64
    lake%RPHI_I_PR0_LIN = 0.0_real64
    lake%RPHI_I_PR1_LIN = 0.0_real64
    lake%RPHI_I_AST_MR = 0.0_real64
    lake%RC_I_MR = 0.0_real64
    lake%RH_ICE_MAX = 0.0_real64
    lake%RH_SNOW_MIN_FLK = 0.0_real64
    lake%RH_ICE_MIN_FLK = 0.0_real64
    lake%RH_ML_MIN_FLK = 0.0_real64
    lake%RH_ML_MAX_FLK = 0.0_real64
    lake%RU_STAR_MIN_FLK = 0.0_real64
    lake%RC_SMALL_FLK = 0.0_real64
    lake%RTPL_GRAV = 0.0_real64
    lake%RTPL_T_R = 0.0_real64
    lake%RTPL_T_F = 0.0_real64
    lake%RTPL_A_T = 0.0_real64
    lake%RTPL_RHO_W_R = 0.0_real64
    lake%RTPL_RHO_I = 0.0_real64
    lake%RTPL_L_F = 0.0_real64
    lake%RTPL_C_W = 0.0_real64
    lake%RTPL_C_I = 0.0_real64
    lake%RTPL_KAPPA_W = 0.0_real64
    lake%RTPL_KAPPA_I = 0.0_real64
    lake%RTPSF_L_EVAP = 0.0_real64
    lake%ROPTICPAR_WATER_REF%nband_optic = 0
    lake%ROPTICPAR_WATER_REF%rfrac_optic = 0.0_real64
    lake%ROPTICPAR_WATER_REF%rextincoef_optic = 0.0_real64
    lake%ROPTICPAR_WATER_TRANS%nband_optic = 0
    lake%ROPTICPAR_WATER_TRANS%rfrac_optic = 0.0_real64
    lake%ROPTICPAR_WATER_TRANS%rextincoef_optic = 0.0_real64
    lake%ROPTICPAR_WHITEICE_REF%nband_optic = 0
    lake%ROPTICPAR_WHITEICE_REF%rfrac_optic = 0.0_real64
    lake%ROPTICPAR_WHITEICE_REF%rextincoef_optic = 0.0_real64
    lake%ROPTICPAR_BLUEICE_REF%nband_optic = 0
    lake%ROPTICPAR_BLUEICE_REF%rfrac_optic = 0.0_real64
    lake%ROPTICPAR_BLUEICE_REF%rextincoef_optic = 0.0_real64
    lake%ROPTICPAR_ICE_OPAQUE%nband_optic = 0
    lake%ROPTICPAR_ICE_OPAQUE%rfrac_optic = 0.0_real64
    lake%ROPTICPAR_ICE_OPAQUE%rextincoef_optic = 0.0_real64
    lake%leflake = .false.
    view%fundamental => fundamental; view%lake => lake
    status = 0
  end function
  !> Attach already produced targets without copying or changing physical data.
  integer(int32) function bind_produced_surface_constant_namespace(view, fundamental, lake) result(status)
    type(native_surface_constant_namespace), intent(inout) :: view
    type(tcst), target, intent(in) :: fundamental
    type(tflake), target, intent(in) :: lake
    status = 2
    if (associated(view%fundamental) .or. associated(view%lake)) return
    view%fundamental => fundamental; view%lake => lake
    status = 0
  end function
  !> End borrowed record views; the canonical parents retain all physical owners.
  subroutine release_surface_constant_namespace(view)
    type(native_surface_constant_namespace), intent(inout) :: view
    nullify (view%fundamental, view%lake)
  end subroutine
end module
