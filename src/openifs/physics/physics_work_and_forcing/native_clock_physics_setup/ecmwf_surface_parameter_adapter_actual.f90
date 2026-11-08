!> Call the owned surface constructor through native typed arguments.
module forecast_ecmwf_surface_setup_actual
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use yos_surf, only: tsurf
  use susurf_schemes_ctl_mod, only: susurf_ctl
  use yoephy, only: tephy
  use yoewcou, only: tewcou
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use dynamical_configuration_port, only: native_dynamical_configuration
  use ecmwf_physics_control_fields_port, only: physics_runtime_inputs
  use surface_optimization_parameters_mod, only: rvr0vt, rvcmax25, rhumrel, ra1, rb1, rg0, rgm25, re_vcmax, re_jmax
  implicit none
  private
  public :: create_ecmwf_surface_parameters
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Create the complete native fifteen-record surface parameter object.
  !! SURFACE is an exclusive caller-owned pointer and must be disassociated.
  !! PHYSICS and COUPLING are readonly shared TEPHY and TEWCOU records.
  !! RADIATION borrows the completed owned SUECRAD state. DYNAMICS supplies
  !! the dimensionless RCORIOI and RPLRG values. RUNTIME supplies the named
  !! roughness controls, with REXTZ0M and REXTZ0H in metres. The four readonly
  !! integer counts are the original DDPHY NCOM,NCSS,NTILES,NCSNEC inputs;
  !! their producer is separate from the seventeen-record configuration.
  !! The eighteen optimization owners have already been initialized; the
  !! nine consumed tables are native20-by2 arrays. All inputs remain live
  !! and unchanged. Only the new surface object and the source THF/EXCS
  !! native module parameters change. No original numerical method is used.
  !! Return0 publishes the complete pointer,1 reports allocation failure and
  !!2 refuses unsupported dimensions or missing input owners before writes.
  integer(int32) function create_ecmwf_surface_parameters(surface, physics, coupling, radiation, dynamics, runtime, &
                                                          ncom, ncss, ntiles, ncsnec) result(status)
    type(tsurf), pointer, intent(inout) :: surface
    type(tephy), intent(in) :: physics
    type(tewcou), intent(in) :: coupling
    type(owned_radiation_setup_state), intent(in) :: radiation
    type(native_dynamical_configuration), intent(in) :: dynamics
    type(physics_runtime_inputs), intent(in) :: runtime
    integer(int32), intent(in) :: ncom, ncss, ntiles, ncsnec
    type(tsurf), pointer :: staged
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: failure_errno
    integer :: allocation_status
    real(real64) :: solar(14)
    status = 2_int32
    if (associated(surface)) return
    if (ncss /= 4 .or. ncsnec /= 5 .or. ntiles /= 9 .or. ncom < 0) return
    if (radiation%radiation%nsw /= 6 .or. radiation%radiation%ntsw /= 14) return
    if (radiation%longwave_bands%nsil /= 6 .or. radiation%radiation%nlwemiss /= 2) return
    if ((physics%nalbedoscheme /= 1 .and. physics%nalbedoscheme /= 2) .or. physics%nemissscheme /= 0) return
    if (.not. radiation%radiation%lccnl .or. .not. radiation%radiation%lccno) return
    if (.not. physics%lectessel .or. .not. physics%lefarquhar) return
    if (physics%leocml .or. physics%locmltke) return
    if (physics%nsnmlws < 1 .or. physics%nsnmlws > 3) return
    if (.not. allocated(radiation%shortwave%rsun)) return
    if (size(radiation%shortwave%rsun) /= 14) return
    if (.not. allocated(rvr0vt) .or. .not. allocated(rvcmax25) .or. .not. allocated(rhumrel)) return
    if (.not. allocated(ra1) .or. .not. allocated(rb1) .or. .not. allocated(rg0)) return
    if (.not. allocated(rgm25) .or. .not. allocated(re_vcmax) .or. .not. allocated(re_jmax)) return
    if (any(shape(rvr0vt) /= [20, 2]) .or. any(shape(rvcmax25) /= [20, 2]) .or. any(shape(rhumrel) /= [20, 2])) return
    if (any(shape(ra1) /= [20, 2]) .or. any(shape(rb1) /= [20, 2]) .or. any(shape(rg0) /= [20, 2])) return
    if (any(shape(rgm25) /= [20, 2]) .or. any(shape(re_vcmax) /= [20, 2]) .or. any(shape(re_jmax) /= [20, 2])) return
    solar = radiation%shortwave%rsun
    nullify (staged)
    call c_f_pointer(errno_address(), error_number)
    allocate (staged, stat=allocation_status)
    if (allocation_status /= 0) then
      failure_errno = error_number
      error_number = failure_errno
      status = 1_int32
      return
    end if
    call susurf_ctl(ksw=radiation%radiation%nsw, kcss=ncss, kcsnec=ncsnec, ksil=radiation%longwave_bands%nsil, &
                    kcom=ncom, ktiles=ntiles, ktsw=radiation%radiation%ntsw, klwemiss=radiation%radiation%nlwemiss, &
                    ld_leflake=physics%leflake, ld_leocml=physics%leocml, ld_locmltke=physics%locmltke, &
                    ld_lwcou=coupling%lwcou, ld_lwcou2w=coupling%lwcou2w, ld_lwcouhmf=coupling%lwcouhmf, &
                    ld_llccnl=radiation%radiation%lccnl, ld_llccno=radiation%radiation%lccno, ld_levgen=physics%levgen, &
                    ld_lessro=physics%lessro, ld_lelaiv=physics%lelaiv, ld_lectessel=physics%lectessel, ld_leags=physics%leags, &
                    ld_lefarquhar=physics%lefarquhar, ld_leairco2coup=physics%leairco2coup, &
                    ld_lesn09=physics%lesn09, ld_lesnml=physics%lesnml, ld_leocwa=physics%leocwa, ld_leocco=physics%leocco, &
                    ld_leocsa=physics%leocsa, ld_leocla=physics%leocla, kalbedoscheme=physics%nalbedoscheme, &
                    kemissscheme=physics%nemissscheme, ld_lscmec=runtime%lscmec, ld_lrough=runtime%lrough, &
                    pextz0m=runtime%rextz0m, pextz0h=runtime%rextz0h, pthrfrti=physics%rthrfrti, &
                    ptstand=radiation%longwave_bands%tstand, pxp=radiation%longwave_bands%xp, &
                    prccnsea=radiation%radiation%rccnsea, prccnlnd=radiation%radiation%rccnlnd, &
                    prlaiint=physics%rlaiint, prsun=solar, prcorioi=dynamics%rcorioi, prplrg=dynamics%rplrg, &
                    pnsnmlws=physics%nsnmlws, prvr0vt=rvr0vt, prvcmax25=rvcmax25, prhumrel=rhumrel, &
                    pra1=ra1, prb1=rb1, prg0=rg0, prgm25=rgm25, pre_vcmax=re_vcmax, pre_jmax=re_jmax, &
                    yddim=staged%ydim, ydexc=staged%yexc, ydcst=staged%ycst, ydrad=staged%yrad, ydrdi=staged%yrdi, &
                    ydlw=staged%ylw, ydsw=staged%ysw, ydsoil=staged%ysoil, ydveg=staged%yveg, ydags=staged%yags, &
                    ydagf=staged%yagf, ydmlm=staged%ymlm, ydflake=staged%yflake, ydocean_ml=staged%yocean_ml, ydurb=staged%yurb, &
                    pralfminpsn=physics%ralfminpsn, prcimin=physics%rcimin)
    surface => staged
    status = 0_int32
  end function
end module forecast_ecmwf_surface_setup_actual
