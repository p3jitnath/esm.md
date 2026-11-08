module grid_field_configuration_types_port
  !! Own the complete selected or operational atmospheric field namespace.
  !! The components, profiles, counters and association indices are native
  !! values. The compiler owns their layout, not historical Arm descriptors.
  !! Inputs and outputs must be disjoint owners. No original module is used.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use grid_field_component_types_port, only: field_component_metadata,field_profile_metadata,field_component_is_fresh,field_profile_is_fresh
  use grid_field_registration_types_port, only: grid_field_registration_state
  use grid_field_alias_types_port, only: grid_field_alias_controls, grid_field_aliases
  use grid_field_inactive_types_port, only: inactive_grid_field_profiles, grid_field_settings, inactive_grid_profiles_are_fresh
  implicit none
  private
  public :: grid_field_configuration, grid_field_configuration_is_fresh, grid_field_profile_equal
  type :: grid_field_configuration
    type(grid_field_registration_state) :: registration
    type(grid_field_alias_controls) :: alias_controls
    type(grid_field_settings) :: settings
    type(field_component_metadata) :: components(2163)
    type(field_profile_metadata) :: profiles(9)
    type(inactive_grid_field_profiles) :: inactive
    type(grid_field_aliases) :: aliases
    integer(int32) :: nddhaero = 0, ngems = 0, laerchem = 0, lqm3dcons = 0
  end type
contains
  logical function grid_field_configuration_is_fresh(state) result(fresh)
    type(grid_field_configuration), intent(in) :: state
    integer :: i
    fresh = .false.
    if (state%registration%numflds /= 0) return
    if (state%registration%nders /= 0) return
    if (state%registration%numspflds /= 0) return
    if (state%registration%numgpflds /= 0) return
    if (state%registration%numflds9 /= 0) return
    if (state%registration%numflds1 /= 0) return
    if (state%registration%numspflds1 /= 0) return
    if (state%registration%numflds5 /= 0) return
    if (state%registration%numfldsphy /= 0) return
    if (state%registration%numflds_spl /= 0) return
    if (state%registration%numflds_sl1 /= 0) return
    if (state%registration%numfldspc /= 0) return
    if (state%registration%ndim /= 0) return
    if (state%registration%numfldspt /= 0) return
    if (state%registration%ndim0 /= 0) return
    if (state%registration%ndim9 /= 0) return
    if (state%registration%ndim1 /= 0) return
    if (state%registration%ndim5 /= 0) return
    if (state%registration%ndimslp /= 0) return
    if (state%registration%ndim_spl /= 0) return
    if (state%registration%ndimpt /= 0) return
    if (state%registration%ndimpc /= 0) return
    if (state%registration%last_index /= 0) return
    if (state%alias_controls%nnogw /= 0) return
    if (state%alias_controls%ngfl_ext /= 0) return
    if (state%alias_controls%ngfl_forc /= 0) return
    if (state%alias_controls%ngfl_ezdiag /= 0) return
    if (state%alias_controls%nghg /= 0) return
    if (state%alias_controls%nchem /= 0) return
    if (state%alias_controls%naero /= 0) return
    if (state%alias_controls%nera40 /= 0) return
    if (state%alias_controls%nemis3d /= 0) return
    if (state%alias_controls%nedrp /= 0) return
    if (state%alias_controls%naerout /= 0) return
    if (state%alias_controls%naeroclim /= 0) return
    if (state%alias_controls%nuvp /= 0) return
    if (state%alias_controls%nsldia /= 0) return
    if (state%alias_controls%nlima /= 0) return
    if (state%alias_controls%laerlisi /= 0) return
    if (state%settings%nsldiagp /= 0) return
    if (state%settings%nactaero /= 0) return
    if (state%settings%nchem_assim /= 0) return
    if (state%settings%nghg_assim /= 0) return
    if (state%settings%nchem_flxo /= 0) return
    if (state%settings%nchem_wdflx /= 0) return
    if (state%settings%nchem_ddflx /= 0) return
    if (state%settings%nchem_dv /= 0) return
    if (state%settings%nchem_scv /= 0) return
    if (state%settings%nchem_tc /= 0) return
    if (state%settings%nemis2d /= 0) return
    if (state%settings%nemis2daux /= 0) return
    if (state%settings%laeraot /= 0) return
    if (state%settings%laerout /= 0) return
    if (state%settings%laeroclim /= 0) return
    if (state%settings%luvpout /= 0) return
    if (state%settings%ltrcmfix /= 0) return
    if (state%settings%ltrcmfix_ps /= 0) return
    if (state%settings%ltrcmfqm /= 0) return
    if (state%settings%ltrcmfbc /= 0) return
    if (state%settings%lextradf /= 0) return
    if (state%settings%ltrcmfpr /= 0) return
    if (state%settings%ltrcmfmg /= 0) return
    if (state%settings%ltrcmfp /= 0) return
    if (state%settings%ltrcmfa_dif /= 0) return
    if (state%settings%ltrcmfa_ver /= 0) return
    if (state%settings%ltrcmfa_lap /= 0) return
    if (state%settings%lspptgfl /= 0) return
    if (state%settings%noptmfbc /= 0) return
    if (state%settings%noptmfpr /= 0) return
    if (state%settings%noptnegfix /= 0) return
    if (state%settings%noptvfe /= 0) return
    if (state%settings%nmfdiaglev /= 0) return
    if (state%settings%nfsd /= 0) return
    if (state%settings%naero_wvl_diag /= 0) return
    if (state%settings%naero_wvl_diag_types /= 0) return
    if (state%settings%nfldsfix /= 0) return
    if (state%settings%nnegafix /= 0) return
    if (state%settings%ladvnegfix /= 0) return
    if (state%settings%nfmg /= 0) return
    if (transfer(state%settings%zmfixeps, 0_int64) /= 0_int64) return
    if (any(state%settings%nmfixflds /= 0)) return
    if (any(state%settings%nnegflds /= 0)) return
    if (any(state%settings%nmgflds /= 0)) return
    if (state%aliases%yq /= 0) return
    if (state%aliases%yl /= 0) return
    if (state%aliases%yi /= 0) return
    if (state%aliases%ys /= 0) return
    if (state%aliases%yr /= 0) return
    if (state%aliases%yg /= 0) return
    if (state%aliases%yh /= 0) return
    if (state%aliases%ytke /= 0) return
    if (state%aliases%yefb1 /= 0) return
    if (state%aliases%yefb2 /= 0) return
    if (state%aliases%yefb3 /= 0) return
    if (state%aliases%ya /= 0) return
    if (state%aliases%yo3 /= 0) return
    if (state%aliases%ycpf /= 0) return
    if (state%aliases%yspf /= 0) return
    if (state%aliases%ysrc /= 0) return
    if (state%aliases%ycvgq /= 0) return
    if (state%aliases%ylconv /= 0) return
    if (state%aliases%yiconv /= 0) return
    if (state%aliases%yrconv /= 0) return
    if (state%aliases%ysconv /= 0) return
    if (state%aliases%ylrad /= 0) return
    if (state%aliases%yirad /= 0) return
    if (state%aliases%ysdsat /= 0) return
    if (state%aliases%ycvv /= 0) return
    if (state%aliases%yqva /= 0) return
    if (state%aliases%yuom /= 0) return
    if (state%aliases%yual /= 0) return
    if (state%aliases%ydom /= 0) return
    if (state%aliases%ydal /= 0) return
    if (state%aliases%yuen /= 0) return
    if (state%aliases%yunebh /= 0) return
    if (state%aliases%ytte /= 0) return
    if (state%aliases%ymxl /= 0) return
    if (state%aliases%yshtur /= 0) return
    if (state%aliases%yfqtur /= 0) return
    if (state%aliases%yfstur /= 0) return
    if (state%aliases%yrkth /= 0) return
    if (state%aliases%yrspec /= 0) return
    if (state%aliases%yrktqv /= 0) return
    if (state%aliases%yrktqc /= 0) return
    if (state%aliases%ylrch4 /= 0) return
    if (state%aliases%yphycty /= 0) return
    if (state%aliases%yfsd /= 0) return
    if (state%aliases%yext%first_index /= 0 .or. state%aliases%yext%count /= 0) return
    if (state%aliases%yforc%first_index /= 0 .or. state%aliases%yforc%count /= 0) return
    if (state%aliases%yezdiag%first_index /= 0 .or. state%aliases%yezdiag%count /= 0) return
    if (state%aliases%yghg%first_index /= 0 .or. state%aliases%yghg%count /= 0) return
    if (state%aliases%ychem%first_index /= 0 .or. state%aliases%ychem%count /= 0) return
    if (state%aliases%yaero%first_index /= 0 .or. state%aliases%yaero%count /= 0) return
    if (state%aliases%yera40%first_index /= 0 .or. state%aliases%yera40%count /= 0) return
    if (state%aliases%ynogw%first_index /= 0 .or. state%aliases%ynogw%count /= 0) return
    if (state%aliases%yemis3d%first_index /= 0 .or. state%aliases%yemis3d%count /= 0) return
    if (state%aliases%yedrp%first_index /= 0 .or. state%aliases%yedrp%count /= 0) return
    if (state%aliases%yaeraot%first_index /= 0 .or. state%aliases%yaeraot%count /= 0) return
    if (state%aliases%yaerlisi%first_index /= 0 .or. state%aliases%yaerlisi%count /= 0) return
    if (state%aliases%yaerout%first_index /= 0 .or. state%aliases%yaerout%count /= 0) return
    if (state%aliases%yaeroclim%first_index /= 0 .or. state%aliases%yaeroclim%count /= 0) return
    if (state%aliases%yuvp%first_index /= 0 .or. state%aliases%yuvp%count /= 0) return
    if (state%aliases%ysldia%first_index /= 0 .or. state%aliases%ysldia%count /= 0) return
    if (state%aliases%ylima%first_index /= 0 .or. state%aliases%ylima%count /= 0) return
    if (state%nddhaero /= 0 .or. state%ngems /= 0 .or. state%laerchem /= 0 .or. state%lqm3dcons /= 0) return
    do i = 1, 2163
      if (.not. field_component_is_fresh(state%components(i))) return
    end do
    do i = 1, 9
      if (.not. field_profile_is_fresh(state%profiles(i))) return
    end do
    if (.not. inactive_grid_profiles_are_fresh(state%inactive)) return
    fresh = .true.
  end function
  logical function grid_field_profile_equal(left, right) result(equal)
    type(field_profile_metadata), intent(in) :: left, right
    equal = .false.
    if (left%cname /= right%cname) return
    if (left%igrbcode /= right%igrbcode) return
    if (left%nreqin /= right%nreqin) return
    if (transfer(left%refvali, 0_int64) /= transfer(right%refvali, 0_int64)) return
    if (left%lreqout /= right%lreqout) return
    if (left%lgpingp /= right%lgpingp) return
    if (left%lmgrid /= right%lmgrid) return
    if (left%lgp /= right%lgp) return
    if (left%lsp /= right%lsp) return
    if (left%lcders /= right%lcders) return
    if (left%lt9 /= right%lt9) return
    if (left%lt1 /= right%lt1) return
    if (left%lt5 /= right%lt5) return
    if (left%lphy /= right%lphy) return
    if (left%lpt /= right%lpt) return
    if (left%ltrajio /= right%ltrajio) return
    if (left%ldiag /= right%ldiag) return
    if (left%lpc /= right%lpc) return
    if (left%ladv /= right%ladv) return
    if (left%ladv5 /= right%ladv5) return
    if (left%lintlin /= right%lintlin) return
    if (left%ltdiablin /= right%ltdiablin) return
    if (left%lhorturb /= right%lhorturb) return
    if (left%lqm /= right%lqm) return
    if (left%lqmh /= right%lqmh) return
    if (left%lqm3d /= right%lqm3d) return
    if (left%lqml3d /= right%lqml3d) return
    if (left%lvweno /= right%lvweno) return
    if (transfer(left%weno_alpha, 0_int64) /= transfer(right%weno_alpha, 0_int64)) return
    if (left%lslhd /= right%lslhd) return
    if (left%lcomad /= right%lcomad) return
    if (left%lhv /= right%lhv) return
    if (left%lvsplip /= right%lvsplip) return
    if (left%ncoupling /= right%ncoupling) return
    if (transfer(left%refvalc, 0_int64) /= transfer(right%refvalc, 0_int64)) return
    if (left%ncouplo4 /= right%ncouplo4) return
    if (left%lassim /= right%lassim) return
    if (left%igribdv /= right%igribdv) return
    if (left%igribtc /= right%igribtc) return
    if (left%igrbflxo /= right%igrbflxo) return
    if (left%igrbwdflx /= right%igrbwdflx) return
    if (left%igrbddflx /= right%igrbddflx) return
    if (left%ldiff /= right%ldiff) return
    if (left%lconv /= right%lconv) return
    if (left%lnegfix /= right%lnegfix) return
    if (left%lmassfix /= right%lmassfix) return
    if (transfer(left%betamfbc, 0_int64) /= transfer(right%betamfbc, 0_int64)) return
    if (transfer(left%rmolmass, 0_int64) /= transfer(right%rmolmass, 0_int64)) return
    if (transfer(left%refold, 0_int64) /= transfer(right%refold, 0_int64)) return
    if (transfer(left%henrya, 0_int64) /= transfer(right%henrya, 0_int64)) return
    if (transfer(left%henryb, 0_int64) /= transfer(right%henryb, 0_int64)) return
    equal = .true.
  end function
end module grid_field_configuration_types_port
