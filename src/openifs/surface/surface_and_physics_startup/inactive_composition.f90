!> Set inactive composition values without changing unrelated source fields.
module forecast_inactive_composition
  use iso_fortran_env, only: int32, int64, real64
  use yomcompo, only: tcompo
  use yomchem, only: tchem
  use yoeaeratm, only: type_aero_desc
  implicit none
  private
  public :: initialize_inactive_chemistry_scalars, initialize_inactive_composition_owners
  public :: release_inactive_composition_owners
contains
  !> COUNTS gives NCHEM,NGHG,NAERO,NACTAERO; all four must be zero.
  !! The caller owns both records. Only the thirteen and twenty-eight
  !! named source scalars change; all retained arrays and strings survive.
  integer(int32) function initialize_inactive_chemistry_scalars(composition, chemistry, counts) result(status)
    type(tcompo), intent(inout) :: composition
    type(tchem), intent(inout) :: chemistry
    integer(int32), intent(in) :: counts(4)
    status = 2
    if (any(counts /= 0)) return
    call set_composition_scalars(composition)
    call set_chemistry_scalars(chemistry)
    status = 0
  end function
  !> Allocate one unwritten aerosol descriptor before publishing defaults.
  !! AEROSOL is an exclusive rank-one pointer owner, initially null. The
  !! source never reads or fills its one TYPE_AERO_DESC element here.
  !! Allocation failure1 leaves every caller record unchanged; refusal2
  !! occurs before allocation. The allocator's natural errno is retained.
  integer(int32) function initialize_inactive_composition_owners(composition, chemistry, grib_codes, aerosol, counts) result(status)
    type(tcompo), intent(inout) :: composition
    type(tchem), intent(inout) :: chemistry
    integer(int32), intent(inout) :: grib_codes(8)
    type(type_aero_desc), pointer, intent(inout) :: aerosol(:)
    integer(int32), intent(in) :: counts(4)
    type(type_aero_desc), pointer :: pending(:)
    integer :: allocation_status
    status = 2
    if (any(counts /= 0)) return
    if (allocated(composition%yemis2d_desc) .or. allocated(composition%yemis3d_desc)) return
    if (allocated(composition%yemis2daux_desc)) return
    if (allocated(chemistry%tco2dg) .or. allocated(chemistry%tcotop)) return
    if (associated(aerosol)) return
    allocate (pending(1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    call set_composition_scalars(composition)
    grib_codes = -999_int32
    call set_chemistry_scalars(chemistry)
    aerosol => pending
    status = 0
  end function
  !> Release only this one descriptor owner; its payload has no child owner.
  integer(int32) function release_inactive_composition_owners(aerosol) result(status)
    type(type_aero_desc), pointer, intent(inout) :: aerosol(:)
    if (associated(aerosol)) deallocate (aerosol)
    nullify (aerosol)
    status = 0
  end function
  subroutine set_composition_scalars(output)
    type(tcompo), intent(inout) :: output
    output%lchem_dia = .false.
    output%rchem_dia_period = 6.0_real64
    output%lchem_ddflx = .false.
    output%lcompo_ddflx_dir = .false.
    output%lchem_tropo = .false.
    output%lcompo_dcdd = .true.
    output%laernitrate = .false.
    output%laereqsam4clim = .false.
    output%laerresuspension = .false.
    output%laersoa = .false.
    output%laersoa_coupled = .false.
    output%laernucl = .true.
    output%kghg_chemtend_ch4 = 0_int32
  end subroutine
  subroutine set_chemistry_scalars(output)
    type(tchem), intent(inout) :: output
    output%kchem_drydep = 0_int32
    output%lchem_light = .false.
    output%rchem_linox_scaling = 0.0_real64
    output%lchem_diac = .false.
    output%lchem_jout = .false.
    output%lchem_bascoe_jon = .false.
    output%lchem_bascoe_hetchem = .true.
    output%lmozart_rsf_dummy = .false.
    output%lchem_extendjno2 = .false.
    output%kchem_noxadv = 0_int32
    output%kchem_wetdep = 1_int32
    output%lchem_stma = .false.
    output%lchem_anao3 = .false.
    output%lchem_anach4 = .false.
    output%lchem_weak_ch4_relaxation = .false.
    output%lchem_0nox = .false.
    output%lchem_htap = .false.
    output%lchem_convscav = .false.
    output%lchem_cshape = .false.
    output%lchem_wdfr = .false.
    output%lchem_o3rad = .false.
    output%lchem_aeroi = .false.
    output%lchem_tl = .false.
    output%kchem_solve = 0_int32
    output%lchem_revchem = .false.
    output%kchem_yearpi = 2000_int32
    output%rch4const = transfer(int(z'C0C387F333333333', int64), 0.0_real64)
    output%lchem_arpclim = .false.
  end subroutine
end module
