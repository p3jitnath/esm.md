module grid_field_inactive_types_port
  !! Own inactive atmospheric field profiles and source scalar settings.
  !! Counts and flags use int32; zeros are fresh until explicit defaults run.
  !! Fixed family capacities retain the generated source supported domain.
  !! Wavelengths use nm; no original object or data symbol is imported.
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use grid_field_component_types_port, only: field_profile_metadata, field_profile_is_fresh
  implicit none
  private
  public :: inactive_grid_field_profiles, grid_field_settings, aerosol_wavelength_diagnostic
  public :: inactive_grid_profiles_are_fresh
  type :: aerosol_wavelength_diagnostic
    integer(int32) :: iwvl = 0, igribdiag(5) = 0
  end type
  type :: inactive_grid_field_profiles
    type(field_profile_metadata) :: ylconv_nl(1)
    type(field_profile_metadata) :: yiconv_nl(1)
    type(field_profile_metadata) :: yrconv_nl(1)
    type(field_profile_metadata) :: ysconv_nl(1)
    type(field_profile_metadata) :: ylrad_nl(1)
    type(field_profile_metadata) :: yirad_nl(1)
    type(field_profile_metadata) :: yg_nl(1)
    type(field_profile_metadata) :: yh_nl(1)
    type(field_profile_metadata) :: ytke_nl(1)
    type(field_profile_metadata) :: yefb1_nl(1)
    type(field_profile_metadata) :: yefb2_nl(1)
    type(field_profile_metadata) :: yefb3_nl(1)
    type(field_profile_metadata) :: ysrc_nl(1)
    type(field_profile_metadata) :: ycpf_nl(1)
    type(field_profile_metadata) :: yspf_nl(1)
    type(field_profile_metadata) :: ycvgq_nl(1)
    type(field_profile_metadata) :: yqva_nl(1)
    type(field_profile_metadata) :: ysdsat_nl(1)
    type(field_profile_metadata) :: ycvv_nl(1)
    type(field_profile_metadata) :: yuom_nl(1)
    type(field_profile_metadata) :: yual_nl(1)
    type(field_profile_metadata) :: ydom_nl(1)
    type(field_profile_metadata) :: ydal_nl(1)
    type(field_profile_metadata) :: yuen_nl(1)
    type(field_profile_metadata) :: yunebh_nl(1)
    type(field_profile_metadata) :: ytte_nl(1)
    type(field_profile_metadata) :: ymxl_nl(1)
    type(field_profile_metadata) :: yshtur_nl(1)
    type(field_profile_metadata) :: yfqtur_nl(1)
    type(field_profile_metadata) :: yfstur_nl(1)
    type(field_profile_metadata) :: yrkth_nl(1)
    type(field_profile_metadata) :: yrktqv_nl(1)
    type(field_profile_metadata) :: yrktqc_nl(1)
    type(field_profile_metadata) :: yrspec_nl(1)
    type(field_profile_metadata) :: yphycty_nl(1)
    type(field_profile_metadata) :: yfsd_nl(1)
    type(field_profile_metadata) :: ylima_nl(50)
    type(field_profile_metadata) :: yghg_nl(3)
    type(field_profile_metadata) :: ychem_nl(220)
    type(field_profile_metadata) :: yaero_nl(42)
    type(field_profile_metadata) :: ylrch4_nl(1)
    type(field_profile_metadata) :: yera40_nl(14)
    type(field_profile_metadata) :: yuvp_nl(2)
    type(field_profile_metadata) :: yedrp_nl(2)
    type(field_profile_metadata) :: yaeraot_nl(3)
    type(field_profile_metadata) :: yaerlisi_nl(18)
    type(field_profile_metadata) :: yaerout_nl(38)
    type(field_profile_metadata) :: yaeroclim_nl(3)
    type(field_profile_metadata) :: ysldia_nl(7)
    type(field_profile_metadata) :: yforc_nl(1100)
    type(field_profile_metadata) :: yezdiag_nl(50)
    type(field_profile_metadata) :: yext_nl(579)
    type(aerosol_wavelength_diagnostic) :: yaero_wvl_diag_nl(20)
  end type
  type :: grid_field_settings
    integer(int32) :: nsldiagp = 0
    integer(int32) :: nactaero = 0
    integer(int32) :: nchem_assim = 0
    integer(int32) :: nghg_assim = 0
    integer(int32) :: nchem_flxo = 0
    integer(int32) :: nchem_wdflx = 0
    integer(int32) :: nchem_ddflx = 0
    integer(int32) :: nchem_dv = 0
    integer(int32) :: nchem_scv = 0
    integer(int32) :: nchem_tc = 0
    integer(int32) :: nemis2d = 0
    integer(int32) :: nemis2daux = 0
    integer(int32) :: laeraot = 0
    integer(int32) :: laerout = 0
    integer(int32) :: laeroclim = 0
    integer(int32) :: luvpout = 0
    integer(int32) :: ltrcmfix = 0
    integer(int32) :: ltrcmfix_ps = 0
    integer(int32) :: ltrcmfqm = 0
    integer(int32) :: ltrcmfbc = 0
    integer(int32) :: lextradf = 0
    integer(int32) :: ltrcmfpr = 0
    integer(int32) :: ltrcmfmg = 0
    integer(int32) :: ltrcmfp = 0
    integer(int32) :: ltrcmfa_dif = 0
    integer(int32) :: ltrcmfa_ver = 0
    integer(int32) :: ltrcmfa_lap = 0
    integer(int32) :: lspptgfl = 0
    integer(int32) :: noptmfbc = 0
    integer(int32) :: noptmfpr = 0
    integer(int32) :: noptnegfix = 0
    integer(int32) :: noptvfe = 0
    integer(int32) :: nmfdiaglev = 0
    integer(int32) :: nfsd = 0
    integer(int32) :: naero_wvl_diag = 0
    integer(int32) :: naero_wvl_diag_types = 0
    integer(int32) :: nfldsfix = 0
    integer(int32) :: nnegafix = 0
    integer(int32) :: ladvnegfix = 0
    integer(int32) :: nfmg = 0
    real(real64) :: zmfixeps = 0.0_real64
    integer(int32) :: nmfixflds(292) = 0, nnegflds(292) = 0, nmgflds(292) = 0
  end type
contains
  logical function inactive_grid_profiles_are_fresh(profiles) result(fresh)
    type(inactive_grid_field_profiles), intent(in) :: profiles
    integer :: i
    fresh = .false.
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ylconv_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yiconv_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yrconv_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ysconv_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ylrad_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yirad_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yg_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yh_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ytke_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yefb1_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yefb2_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yefb3_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ysrc_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ycpf_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yspf_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ycvgq_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yqva_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ysdsat_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ycvv_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yuom_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yual_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ydom_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ydal_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yuen_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yunebh_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ytte_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ymxl_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yshtur_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yfqtur_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yfstur_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yrkth_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yrktqv_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yrktqc_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yrspec_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yphycty_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%yfsd_nl(i))) return
    end do
    do i = 1, 50
      if (.not. field_profile_is_fresh(profiles%ylima_nl(i))) return
    end do
    do i = 1, 3
      if (.not. field_profile_is_fresh(profiles%yghg_nl(i))) return
    end do
    do i = 1, 220
      if (.not. field_profile_is_fresh(profiles%ychem_nl(i))) return
    end do
    do i = 1, 42
      if (.not. field_profile_is_fresh(profiles%yaero_nl(i))) return
    end do
    do i = 1, 1
      if (.not. field_profile_is_fresh(profiles%ylrch4_nl(i))) return
    end do
    do i = 1, 14
      if (.not. field_profile_is_fresh(profiles%yera40_nl(i))) return
    end do
    do i = 1, 2
      if (.not. field_profile_is_fresh(profiles%yuvp_nl(i))) return
    end do
    do i = 1, 2
      if (.not. field_profile_is_fresh(profiles%yedrp_nl(i))) return
    end do
    do i = 1, 3
      if (.not. field_profile_is_fresh(profiles%yaeraot_nl(i))) return
    end do
    do i = 1, 18
      if (.not. field_profile_is_fresh(profiles%yaerlisi_nl(i))) return
    end do
    do i = 1, 38
      if (.not. field_profile_is_fresh(profiles%yaerout_nl(i))) return
    end do
    do i = 1, 3
      if (.not. field_profile_is_fresh(profiles%yaeroclim_nl(i))) return
    end do
    do i = 1, 7
      if (.not. field_profile_is_fresh(profiles%ysldia_nl(i))) return
    end do
    do i = 1, 1100
      if (.not. field_profile_is_fresh(profiles%yforc_nl(i))) return
    end do
    do i = 1, 50
      if (.not. field_profile_is_fresh(profiles%yezdiag_nl(i))) return
    end do
    do i = 1, 579
      if (.not. field_profile_is_fresh(profiles%yext_nl(i))) return
    end do
    do i = 1, 20
      if (profiles%yaero_wvl_diag_nl(i)%iwvl /= 0) return
      if (any(profiles%yaero_wvl_diag_nl(i)%igribdiag /= 0)) return
    end do
    fresh = .true.
  end function
end module grid_field_inactive_types_port
