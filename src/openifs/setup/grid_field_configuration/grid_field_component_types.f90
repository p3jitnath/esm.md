module grid_field_component_types_port
  !! Own named atmospheric field and namelist metadata.
  !! Field names follow the OpenIFS public data declarations, used only to
  !! understand the interface. This module imports no original state or code.
  !! Flags are int32 words:0 false and1 true when a consumer uses them.
  !! Source-unwritten words retain their incoming bits without interpretation.
  !! Real values retain source units, including J/(kg K) for R and RCP.
  !! previous_index is0 or a one-based owner index, replacing a private pointer.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, &
                                                 ieee_nearest, ieee_support_underflow_control, ieee_get_underflow_mode, operator(/=)
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  private
  public :: field_component_metadata, field_profile_metadata
  public :: field_component_is_fresh, field_profile_is_fresh, grid_field_mode_supported
  type :: field_component_metadata
    character(len=16) :: cname = repeat(achar(0), 16)
    integer(int32) :: igrbcode = 0_int32
    integer(int32) :: ladv = 0_int32
    integer(int32) :: ladv5 = 0_int32
    integer(int32) :: ltdiablin = 0_int32
    integer(int32) :: lhorturb = 0_int32
    integer(int32) :: nreqin = 0_int32
    integer(int32) :: lreqout = 0_int32
    integer(int32) :: lgpingp = 0_int32
    integer(int32) :: lmgrid = 0_int32
    integer(int32) :: lgp = 0_int32
    integer(int32) :: lsp = 0_int32
    integer(int32) :: lcders = 0_int32
    integer(int32) :: lactive = 0_int32
    integer(int32) :: lthermact = 0_int32
    real(real64) :: r = 0.0_real64
    real(real64) :: rcp = 0.0_real64
    integer(int32) :: lt9 = 0_int32
    integer(int32) :: lt1 = 0_int32
    integer(int32) :: lt5 = 0_int32
    integer(int32) :: lphy = 0_int32
    integer(int32) :: lpt = 0_int32
    integer(int32) :: ltrajio = 0_int32
    integer(int32) :: ldiag = 0_int32
    integer(int32) :: lpc = 0_int32
    real(real64) :: refvali = 0.0_real64
    integer(int32) :: ladjust0 = 0_int32
    integer(int32) :: ladjust1 = 0_int32
    integer(int32) :: ncoupling = 0_int32
    real(real64) :: refvalc = 0.0_real64
    integer(int32) :: lbiper = 0_int32
    character(len=12) :: cslint = repeat(achar(0), 12)
    integer(int32) :: mp = 0_int32
    integer(int32) :: mpl = 0_int32
    integer(int32) :: mpm = 0_int32
    integer(int32) :: mp9 = 0_int32
    integer(int32) :: mp9_ph = 0_int32
    integer(int32) :: mp1 = 0_int32
    integer(int32) :: mp5 = 0_int32
    integer(int32) :: mp5l = 0_int32
    integer(int32) :: mp5m = 0_int32
    integer(int32) :: mpslp = 0_int32
    integer(int32) :: mpsp = 0_int32
    integer(int32) :: mp_spl = 0_int32
    integer(int32) :: mp_sl1 = 0_int32
    integer(int32) :: mp_slx = 0_int32
    integer(int32) :: mppt = 0_int32
    integer(int32) :: mppc = 0_int32
    integer(int32) :: lwater = 0_int32
    integer(int32) :: lprecip = 0_int32
    real(real64) :: rlzer = 0.0_real64
    integer(int32) :: ncouplo4 = 0_int32
    integer(int32) :: lassim = 0_int32
    integer(int32) :: igribdv = 0_int32
    integer(int32) :: igribtc = 0_int32
    integer(int32) :: igrbflxo = 0_int32
    integer(int32) :: igrbwdflx = 0_int32
    integer(int32) :: igrbddflx = 0_int32
    integer(int32) :: ldiff = 0_int32
    integer(int32) :: lconv = 0_int32
    real(real64) :: rmolmass = 0.0_real64
    real(real64) :: refold = 0.0_real64
    real(real64) :: henrya = 0.0_real64
    real(real64) :: henryb = 0.0_real64
    integer(int32) :: lnegfix = 0_int32
    integer(int32) :: lcomad = 0_int32
    real(real64) :: weno_alpha = 0.0_real64
    integer(int32) :: lmassfix = 0_int32
    real(real64) :: betamfbc = 0.0_real64
    integer(int32) :: ifid = 0_int32
    integer(int32) :: previous_index = 0_int32
  end type
  type :: field_profile_metadata
    character(len=16) :: cname = repeat(achar(0), 16)
    integer(int32) :: igrbcode = 0_int32
    integer(int32) :: nreqin = 0_int32
    real(real64) :: refvali = 0.0_real64
    integer(int32) :: lreqout = 0_int32
    integer(int32) :: lgpingp = 0_int32
    integer(int32) :: lmgrid = 0_int32
    integer(int32) :: lgp = 0_int32
    integer(int32) :: lsp = 0_int32
    integer(int32) :: lcders = 0_int32
    integer(int32) :: lt9 = 0_int32
    integer(int32) :: lt1 = 0_int32
    integer(int32) :: lt5 = 0_int32
    integer(int32) :: lphy = 0_int32
    integer(int32) :: lpt = 0_int32
    integer(int32) :: ltrajio = 0_int32
    integer(int32) :: ldiag = 0_int32
    integer(int32) :: lpc = 0_int32
    integer(int32) :: ladv = 0_int32
    integer(int32) :: ladv5 = 0_int32
    integer(int32) :: lintlin = 0_int32
    integer(int32) :: ltdiablin = 0_int32
    integer(int32) :: lhorturb = 0_int32
    integer(int32) :: lqm = 0_int32
    integer(int32) :: lqmh = 0_int32
    integer(int32) :: lqm3d = 0_int32
    integer(int32) :: lqml3d = 0_int32
    integer(int32) :: lvweno = 0_int32
    real(real64) :: weno_alpha = 0.0_real64
    integer(int32) :: lslhd = 0_int32
    integer(int32) :: lcomad = 0_int32
    integer(int32) :: lhv = 0_int32
    integer(int32) :: lvsplip = 0_int32
    integer(int32) :: ncoupling = 0_int32
    real(real64) :: refvalc = 0.0_real64
    integer(int32) :: ncouplo4 = 0_int32
    integer(int32) :: lassim = 0_int32
    integer(int32) :: igribdv = 0_int32
    integer(int32) :: igribtc = 0_int32
    integer(int32) :: igrbflxo = 0_int32
    integer(int32) :: igrbwdflx = 0_int32
    integer(int32) :: igrbddflx = 0_int32
    integer(int32) :: ldiff = 0_int32
    integer(int32) :: lconv = 0_int32
    integer(int32) :: lnegfix = 0_int32
    integer(int32) :: lmassfix = 0_int32
    real(real64) :: betamfbc = 0.0_real64
    real(real64) :: rmolmass = 0.0_real64
    real(real64) :: refold = 0.0_real64
    real(real64) :: henrya = 0.0_real64
    real(real64) :: henryb = 0.0_real64
  end type
contains
  logical function field_component_is_fresh(field) result(fresh)
    type(field_component_metadata), intent(in) :: field
    fresh = .false.
    if (field%cname /= repeat(achar(0), 16)) return
    if (field%igrbcode /= 0_int32) return
    if (field%ladv /= 0_int32) return
    if (field%ladv5 /= 0_int32) return
    if (field%ltdiablin /= 0_int32) return
    if (field%lhorturb /= 0_int32) return
    if (field%nreqin /= 0_int32) return
    if (field%lreqout /= 0_int32) return
    if (field%lgpingp /= 0_int32) return
    if (field%lmgrid /= 0_int32) return
    if (field%lgp /= 0_int32) return
    if (field%lsp /= 0_int32) return
    if (field%lcders /= 0_int32) return
    if (field%lactive /= 0_int32) return
    if (field%lthermact /= 0_int32) return
    if (transfer(field%r, 0_int64) /= 0_int64) return
    if (transfer(field%rcp, 0_int64) /= 0_int64) return
    if (field%lt9 /= 0_int32) return
    if (field%lt1 /= 0_int32) return
    if (field%lt5 /= 0_int32) return
    if (field%lphy /= 0_int32) return
    if (field%lpt /= 0_int32) return
    if (field%ltrajio /= 0_int32) return
    if (field%ldiag /= 0_int32) return
    if (field%lpc /= 0_int32) return
    if (transfer(field%refvali, 0_int64) /= 0_int64) return
    if (field%ladjust0 /= 0_int32) return
    if (field%ladjust1 /= 0_int32) return
    if (field%ncoupling /= 0_int32) return
    if (transfer(field%refvalc, 0_int64) /= 0_int64) return
    if (field%lbiper /= 0_int32) return
    if (field%cslint /= repeat(achar(0), 12)) return
    if (field%mp /= 0_int32) return
    if (field%mpl /= 0_int32) return
    if (field%mpm /= 0_int32) return
    if (field%mp9 /= 0_int32) return
    if (field%mp9_ph /= 0_int32) return
    if (field%mp1 /= 0_int32) return
    if (field%mp5 /= 0_int32) return
    if (field%mp5l /= 0_int32) return
    if (field%mp5m /= 0_int32) return
    if (field%mpslp /= 0_int32) return
    if (field%mpsp /= 0_int32) return
    if (field%mp_spl /= 0_int32) return
    if (field%mp_sl1 /= 0_int32) return
    if (field%mp_slx /= 0_int32) return
    if (field%mppt /= 0_int32) return
    if (field%mppc /= 0_int32) return
    if (field%lwater /= 0_int32) return
    if (field%lprecip /= 0_int32) return
    if (transfer(field%rlzer, 0_int64) /= 0_int64) return
    if (field%ncouplo4 /= 0_int32) return
    if (field%lassim /= 0_int32) return
    if (field%igribdv /= 0_int32) return
    if (field%igribtc /= 0_int32) return
    if (field%igrbflxo /= 0_int32) return
    if (field%igrbwdflx /= 0_int32) return
    if (field%igrbddflx /= 0_int32) return
    if (field%ldiff /= 0_int32) return
    if (field%lconv /= 0_int32) return
    if (transfer(field%rmolmass, 0_int64) /= 0_int64) return
    if (transfer(field%refold, 0_int64) /= 0_int64) return
    if (transfer(field%henrya, 0_int64) /= 0_int64) return
    if (transfer(field%henryb, 0_int64) /= 0_int64) return
    if (field%lnegfix /= 0_int32) return
    if (field%lcomad /= 0_int32) return
    if (transfer(field%weno_alpha, 0_int64) /= 0_int64) return
    if (field%lmassfix /= 0_int32) return
    if (transfer(field%betamfbc, 0_int64) /= 0_int64) return
    if (field%ifid /= 0_int32) return
    if (field%previous_index /= 0_int32) return
    fresh = .true.
  end function
  logical function field_profile_is_fresh(field) result(fresh)
    type(field_profile_metadata), intent(in) :: field
    fresh = .false.
    if (field%cname /= repeat(achar(0), 16)) return
    if (field%igrbcode /= 0_int32) return
    if (field%nreqin /= 0_int32) return
    if (transfer(field%refvali, 0_int64) /= 0_int64) return
    if (field%lreqout /= 0_int32) return
    if (field%lgpingp /= 0_int32) return
    if (field%lmgrid /= 0_int32) return
    if (field%lgp /= 0_int32) return
    if (field%lsp /= 0_int32) return
    if (field%lcders /= 0_int32) return
    if (field%lt9 /= 0_int32) return
    if (field%lt1 /= 0_int32) return
    if (field%lt5 /= 0_int32) return
    if (field%lphy /= 0_int32) return
    if (field%lpt /= 0_int32) return
    if (field%ltrajio /= 0_int32) return
    if (field%ldiag /= 0_int32) return
    if (field%lpc /= 0_int32) return
    if (field%ladv /= 0_int32) return
    if (field%ladv5 /= 0_int32) return
    if (field%lintlin /= 0_int32) return
    if (field%ltdiablin /= 0_int32) return
    if (field%lhorturb /= 0_int32) return
    if (field%lqm /= 0_int32) return
    if (field%lqmh /= 0_int32) return
    if (field%lqm3d /= 0_int32) return
    if (field%lqml3d /= 0_int32) return
    if (field%lvweno /= 0_int32) return
    if (transfer(field%weno_alpha, 0_int64) /= 0_int64) return
    if (field%lslhd /= 0_int32) return
    if (field%lcomad /= 0_int32) return
    if (field%lhv /= 0_int32) return
    if (field%lvsplip /= 0_int32) return
    if (field%ncoupling /= 0_int32) return
    if (transfer(field%refvalc, 0_int64) /= 0_int64) return
    if (field%ncouplo4 /= 0_int32) return
    if (field%lassim /= 0_int32) return
    if (field%igribdv /= 0_int32) return
    if (field%igribtc /= 0_int32) return
    if (field%igrbflxo /= 0_int32) return
    if (field%igrbwdflx /= 0_int32) return
    if (field%igrbddflx /= 0_int32) return
    if (field%ldiff /= 0_int32) return
    if (field%lconv /= 0_int32) return
    if (field%lnegfix /= 0_int32) return
    if (field%lmassfix /= 0_int32) return
    if (transfer(field%betamfbc, 0_int64) /= 0_int64) return
    if (transfer(field%rmolmass, 0_int64) /= 0_int64) return
    if (transfer(field%refold, 0_int64) /= 0_int64) return
    if (transfer(field%henrya, 0_int64) /= 0_int64) return
    if (transfer(field%henryb, 0_int64) /= 0_int64) return
    fresh = .true.
  end function
  logical function grid_field_mode_supported() result(supported)
    !! Preserve flags while checking nearest rounding and exact subnormals.
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: saved
    real(real64), volatile :: minimum_normal, half_value, probe
    logical :: gradual
    call ieee_get_status(saved)
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) goto 900
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) goto 900
    else
      minimum_normal = tiny(0.0_real64); half_value = 0.5_real64
      probe = minimum_normal*half_value
      if (transfer(probe, 0_int64) /= ibset(0_int64, 51)) goto 900
    end if
    supported = .true.
900 call ieee_set_status(saved)
  end function
end module grid_field_component_types_port
