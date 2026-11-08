module yos_surf
  use iso_c_binding, only: c_ptr, c_loc, c_f_pointer, c_null_ptr, c_associated
  use yos_ags, only: tags
  use yos_agf, only: tagf
  use yos_cst, only: tcst
  use yos_dim, only: tdim
  use yos_exc, only: texc
  use yos_flake, only: tflake
  use yos_lw, only: tlw
  use yos_mlm, only: tmlm
  use yos_ocean_ml, only: tocean_ml
  use yos_rad, only: trad
  use yos_rdi, only: trdi
  use yos_soil, only: tsoil
  use yos_sw, only: tsw
  use yos_veg, only: tveg
  use yos_urb, only: turb
  implicit none
  private
  public :: tsurf, allo_surf, get_surf, deallo_surf
  !> Owned native surface state. Each component owns its declared arrays.
  type :: tsurf
    type(tags) :: yags
    type(tagf) :: yagf
    type(tcst) :: ycst
    type(tdim) :: ydim
    type(texc) :: yexc
    type(tflake) :: yflake
    type(tlw) :: ylw
    type(tmlm) :: ymlm
    type(tocean_ml) :: yocean_ml
    type(trad) :: yrad
    type(trdi) :: yrdi
    type(tsoil) :: ysoil
    type(tsw) :: ysw
    type(tveg) :: yveg
    type(turb) :: yurb
  end type tsurf
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Allocate one native surface object and return its exclusive opaque handle.
  !!
  !! The compiler initializes the allocatable components. Physical values are
  !! set by SUSURF_CTL before the caller can use the completed object.
  subroutine allo_surf(ydsurf)
    type(c_ptr), intent(out) :: ydsurf
    type(tsurf), pointer :: surface
    integer :: status
    nullify (surface)
    allocate (surface, stat=status)
    if (status /= 0) call reject_contract()
    ydsurf = c_loc(surface)
  end subroutine allo_surf
  !> Recover the native pointer from an owned handle without a registry.
  function get_surf(ydsurf) result(surface)
    type(c_ptr), intent(in) :: ydsurf
    type(tsurf), pointer :: surface
    nullify (surface)
    if (c_associated(ydsurf)) call c_f_pointer(ydsurf, surface)
  end function get_surf
  !> Release the owned surface object and all of its allocated arrays.
  !!
  !! YDSURF must be this module's live exclusive handle or the null handle.
  !! A repeated release of the null handle is accepted.
  subroutine deallo_surf(ydsurf)
    type(c_ptr), intent(inout) :: ydsurf
    type(tsurf), pointer :: surface
    if (.not. c_associated(ydsurf)) return
    call c_f_pointer(ydsurf, surface)
    deallocate (surface)
    ydsurf = c_null_ptr
  end subroutine deallo_surf
end module yos_surf

module susurf_ctl_mod
  use iso_fortran_env, only: int32, real64
  use yos_ags, only: tags
  use yos_agf, only: tagf
  use yos_cst, only: tcst
  use yos_dim, only: tdim
  use yos_exc, only: texc
  use yos_flake, only: tflake
  use yos_lw, only: tlw
  use yos_mlm, only: tmlm
  use yos_ocean_ml, only: tocean_ml
  use yos_rad, only: trad
  use yos_rdi, only: trdi
  use yos_soil, only: tsoil
  use yos_sw, only: tsw
  use yos_veg, only: tveg
  use yos_urb, only: turb
  use suscst_mod, only: suscst
  use susthf_mod, only: susthf
  use susrad_mod, only: susrad
  use sussoil_mod, only: sussoil
  use susveg_mod, only: susveg
  use sucotwo_mod, only: sucotwo
  use sufarquhar_mod, only: sufarquhar
  use suvexc_mod, only: suvexc
  use suvexcs_mod, only: suvexcs
  use susflake_mod, only: susflake
  use susurb_mod, only: susurb
  implicit none
  private
  public :: susurf_ctl
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Initialize the fifteen native surface records in the frozen source order.
  !!
  !! Soil and snow dimensions are four and five; there are nine tiles, six
  !! shortwave bands, fourteen spectral intervals and two emissivity intervals.
  !! Temperatures use kelvin, lengths use metres, and all configuration scales
  !! and fractions are dimensionless. Each record's constructor defines its
  !! remaining SI units. The nine optimization arrays have shape (20,2).
  !! The caller supplies valid native records and owns their arrays. Disabled
  !! mixed-layer ocean records keep their incoming values. Original public
  !! argument order is retained; PRCIMIN is the optional ice-depth minimum.
  SUBROUTINE SUSURF_CTL(KSW, KCSS, KCSNEC, KSIL, KCOM, KTILES, KTSW, KLWEMISS,&
   & LD_LEFLAKE, LD_LEOCML, LD_LOCMLTKE,&
   & LD_LWCOU, LD_LWCOU2W, LD_LWCOUHMF,&
   & LD_LLCCNL, LD_LLCCNO, LD_LEVGEN, LD_LESSRO, LD_LELAIV,&
   & LD_LECTESSEL, LD_LEAGS, LD_LEFARQUHAR, LD_LEAIRCO2COUP, LD_LESN09, LD_LESNML,&
   & LD_LEOCWA, LD_LEOCCO, LD_LEOCSA, LD_LEOCLA, KALBEDOSCHEME, KEMISSSCHEME,&
   & LD_LSCMEC, LD_LROUGH, PEXTZ0M, PEXTZ0H,&
   & PTHRFRTI, PTSTAND, PXP, PRCCNSEA, PRCCNLND,&
   & PRLAIINT, PRSUN, PRCORIOI, PRPLRG, PNSNMLWS,&
   & PRVR0VT, PRVCMAX25, PRHUMREL, PRA1, PRB1, PRG0, PRGM25, PRE_VCMAX, PRE_JMAX,&
   & YDDIM, YDEXC, YDCST, YDRAD, YDRDI, YDLW, YDSW, YDSOIL,&
   & YDVEG, YDAGS, YDAGF, YDMLM, YDFLAKE, YDOCEAN_ML, YDURB, PRALFMINPSN, PRCIMIN)

    INTEGER(KIND=int32), INTENT(IN) :: KSW
    REAL(KIND=real64), INTENT(IN) :: PTHRFRTI
    INTEGER(KIND=int32), INTENT(IN) :: KCSS
    INTEGER(KIND=int32), INTENT(IN) :: KCSNEC
    INTEGER(KIND=int32), INTENT(IN) :: KSIL
    INTEGER(KIND=int32), INTENT(IN) :: KCOM
    INTEGER(KIND=int32), INTENT(IN) :: KTILES
    INTEGER(KIND=int32), INTENT(IN) :: KTSW
    INTEGER(KIND=int32), INTENT(IN) :: KLWEMISS
    INTEGER(KIND=int32), INTENT(IN) :: KALBEDOSCHEME
    INTEGER(KIND=int32), INTENT(IN) :: KEMISSSCHEME
    LOGICAL(int32), INTENT(IN) :: LD_LLCCNL
    LOGICAL(int32), INTENT(IN) :: LD_LLCCNO
    LOGICAL(int32), INTENT(IN) :: LD_LEVGEN
    LOGICAL(int32), INTENT(IN) :: LD_LESSRO
    LOGICAL(int32), INTENT(IN) :: LD_LELAIV
    LOGICAL(int32), INTENT(IN) :: LD_LECTESSEL
    LOGICAL(int32), INTENT(IN) :: LD_LEAGS
    LOGICAL(int32), INTENT(IN) :: LD_LEFARQUHAR
    LOGICAL(int32), INTENT(IN) :: LD_LEAIRCO2COUP
    LOGICAL(int32), INTENT(IN) :: LD_LESN09
    LOGICAL(int32), INTENT(IN) :: LD_LESNML
    LOGICAL(int32), INTENT(IN) :: LD_LEOCWA
    LOGICAL(int32), INTENT(IN) :: LD_LEOCCO
    LOGICAL(int32), INTENT(IN) :: LD_LEOCSA
    LOGICAL(int32), INTENT(IN) :: LD_LEOCLA
    LOGICAL(int32), INTENT(IN) :: LD_LSCMEC
    LOGICAL(int32), INTENT(IN) :: LD_LROUGH
    LOGICAL(int32), INTENT(IN) :: LD_LEFLAKE
    LOGICAL(int32), INTENT(IN) :: LD_LEOCML
    LOGICAL(int32), INTENT(IN) :: LD_LOCMLTKE
    LOGICAL(int32), INTENT(IN) :: LD_LWCOU
    LOGICAL(int32), INTENT(IN) :: LD_LWCOU2W
    LOGICAL(int32), INTENT(IN) :: LD_LWCOUHMF
    REAL(KIND=real64), INTENT(IN) :: PEXTZ0M
    REAL(KIND=real64), INTENT(IN) :: PEXTZ0H
    REAL(KIND=real64), INTENT(IN) :: PTSTAND
    REAL(KIND=real64), INTENT(IN) :: PXP(6, 6)
    REAL(KIND=real64), INTENT(IN) :: PRCCNSEA
    REAL(KIND=real64), INTENT(IN) :: PRCCNLND
    REAL(KIND=real64), INTENT(IN) :: PRLAIINT
    REAL(KIND=real64), INTENT(IN) :: PRSUN(:)
    REAL(KIND=real64), INTENT(IN) :: PRCORIOI
    REAL(KIND=real64), INTENT(IN) :: PRPLRG
    INTEGER(KIND=int32), INTENT(IN) :: PNSNMLWS
    REAL(KIND=real64), INTENT(IN) :: PRVR0VT(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRVCMAX25(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRHUMREL(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRA1(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRB1(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRG0(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRGM25(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRE_VCMAX(:, :)
    REAL(KIND=real64), INTENT(IN) :: PRE_JMAX(:, :)
    TYPE(TDIM), INTENT(INOUT) :: YDDIM
    TYPE(TEXC), INTENT(INOUT) :: YDEXC
    TYPE(TCST), INTENT(INOUT) :: YDCST
    TYPE(TRAD), INTENT(INOUT) :: YDRAD
    TYPE(TRDI), INTENT(INOUT) :: YDRDI
    TYPE(TLW), INTENT(INOUT) :: YDLW
    TYPE(TSW), INTENT(INOUT) :: YDSW
    TYPE(TSOIL), INTENT(INOUT) :: YDSOIL
    TYPE(TVEG), INTENT(INOUT) :: YDVEG
    TYPE(TAGS), INTENT(INOUT) :: YDAGS
    TYPE(TAGF), INTENT(INOUT) :: YDAGF
    TYPE(TMLM), INTENT(INOUT) :: YDMLM
    TYPE(TFLAKE), INTENT(INOUT) :: YDFLAKE
    TYPE(TOCEAN_ML), INTENT(INOUT) :: YDOCEAN_ML
    TYPE(TURB), INTENT(INOUT) :: YDURB
    REAL(KIND=real64), INTENT(IN) :: PRALFMINPSN
    REAL(KIND=real64), INTENT(IN), OPTIONAL :: PRCIMIN
    if (kcss /= 4 .or. kcsnec /= 5 .or. ktiles /= 9) call reject_contract()
    if (ksw /= 6 .or. ktsw /= 14 .or. ksil /= 6 .or. klwemiss /= 2) call reject_contract()
    if (kalbedoscheme /= 1 .or. kemissscheme /= 0) call reject_contract()
    if (.not. ld_llccnl .or. .not. ld_llccno) call reject_contract()
    if (.not. ld_lectessel .or. .not. ld_lefarquhar) call reject_contract()
    if (ld_leocml .or. ld_locmltke) call reject_contract()
    if (pnsnmlws < 1 .or. pnsnmlws > 3 .or. size(prsun) /= 14) call reject_contract()
    if (any(shape(prvr0vt) /= [20, 2]) .or. any(shape(prvcmax25) /= [20, 2]) .or. &
        any(shape(prhumrel) /= [20, 2]) .or. any(shape(pra1) /= [20, 2]) .or. any(shape(prb1) /= [20, 2]) .or. &
        any(shape(prg0) /= [20, 2]) .or. any(shape(prgm25) /= [20, 2]) .or. &
        any(shape(pre_vcmax) /= [20, 2]) .or. any(shape(pre_jmax) /= [20, 2])) call reject_contract()
    yddim%ncss = kcss
    yddim%ntiles = ktiles
    yddim%nmonth = 12
    yddim%ncsnec = kcsnec
    call suscst(prcorioi, prplrg, ydcst)
    call susthf(ydcst)
    call susrad(ksw, ksil, ktsw, klwemiss, ld_llccnl, ld_llccno, kalbedoscheme, kemissscheme, &
                ptstand, pxp, prccnsea, prccnlnd, prsun, yddim, ydrad, ydrdi, ydlw, ydsw)
    call sussoil(pthrfrti, ld_levgen, ld_lessro, ld_lesn09, ld_lesnml, pnsnmlws, yddim, ydcst, ydsoil, pralfminpsn, prcimin)
    call susveg(ld_lelaiv, ld_lectessel, ld_leags, ld_lefarquhar, ld_leairco2coup, prlaiint, yddim, ydcst, ydsoil, ydveg)
    call sucotwo(prvr0vt, ydveg, ydcst, ydags)
    call sufarquhar(prvcmax25, prhumrel, pra1, prb1, prg0, prgm25, pre_vcmax, pre_jmax, ydveg, ydags, ydagf)
    call suvexc(ld_leocwa, ld_leocco, ld_leocsa, ld_leocla, ld_lwcou, ld_lwcou2w, ld_lwcouhmf, &
                ld_lscmec, ld_lrough, pextz0m, pextz0h, prplrg, ydexc)
    call suvexcs()
    call susflake(ld_leflake, ydflake)
    ydmlm%locmltke = .false.
    call susurb(ydurb)
  end subroutine susurf_ctl
end module susurf_ctl_mod

!> Create and fully initialize an owned native surface object.
!!
!! The original public SUSURF argument order is retained. All configuration
!! and numerical tables are supplied by the caller, and every numerical stage
!! is owned by the native modules above. The opaque handle is exposed only
!! after initialization returns. No original registry or constructor is used.
SUBROUTINE SUSURF(KSW, KCSS, KCSNEC, KSIL, KCOM, KTILES, KTSW, KLWEMISS,&
 & LD_LEFLAKE, LD_LEOCML, LD_LOCMLTKE,&
 & LD_LWCOU, LD_LWCOU2W, LD_LWCOUHMF,&
 & LD_LLCCNL, LD_LLCCNO, LD_LEVGEN, LD_LESSRO,&
 & LD_LELAIV, LD_LECTESSEL, LD_LEAGS, LD_LEFARQUHAR, LD_LEAIRCO2COUP, LD_LESN09, LD_LESNML,&
 & LD_LEOCWA, LD_LEOCCO, LD_LEOCSA, LD_LEOCLA, KALBEDOSCHEME, KEMISSSCHEME,&
 & LD_LSCMEC, LD_LROUGH, PEXTZ0M, PEXTZ0H,&
 & PTHRFRTI, PTSTAND, PXP, PRCCNSEA, PRCCNLND,&
 & PRLAIINT, PRSUN, PRCORIOI, PRPLRG, PNSNMLWS,&
 & PRVR0VT, PRVCMAX25, PRHUMREL, PRA1, PRB1, PRG0, PRGM25, PRE_VCMAX, PRE_JMAX,&
 & YDSURF, PRALFMINPSN, PRCIMIN)

  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_ptr, c_null_ptr
  use yos_surf, only: tsurf, allo_surf, get_surf
  use susurf_ctl_mod, only: susurf_ctl
  implicit none
  INTEGER(KIND=int32), INTENT(IN) :: KSW
  REAL(KIND=real64), INTENT(IN) :: PTHRFRTI
  INTEGER(KIND=int32), INTENT(IN) :: KCSS
  INTEGER(KIND=int32), INTENT(IN) :: KCSNEC
  INTEGER(KIND=int32), INTENT(IN) :: KSIL
  INTEGER(KIND=int32), INTENT(IN) :: KCOM
  INTEGER(KIND=int32), INTENT(IN) :: KTILES
  INTEGER(KIND=int32), INTENT(IN) :: KTSW
  INTEGER(KIND=int32), INTENT(IN) :: KLWEMISS
  INTEGER(KIND=int32), INTENT(IN) :: KALBEDOSCHEME
  INTEGER(KIND=int32), INTENT(IN) :: KEMISSSCHEME
  LOGICAL(int32), INTENT(IN) :: LD_LLCCNL
  LOGICAL(int32), INTENT(IN) :: LD_LLCCNO
  LOGICAL(int32), INTENT(IN) :: LD_LEVGEN
  LOGICAL(int32), INTENT(IN) :: LD_LESSRO
  LOGICAL(int32), INTENT(IN) :: LD_LELAIV
  LOGICAL(int32), INTENT(IN) :: LD_LECTESSEL
  LOGICAL(int32), INTENT(IN) :: LD_LEAGS
  LOGICAL(int32), INTENT(IN) :: LD_LEFARQUHAR
  LOGICAL(int32), INTENT(IN) :: LD_LEAIRCO2COUP
  LOGICAL(int32), INTENT(IN) :: LD_LESN09
  LOGICAL(int32), INTENT(IN) :: LD_LESNML
  LOGICAL(int32), INTENT(IN) :: LD_LEOCWA
  LOGICAL(int32), INTENT(IN) :: LD_LEOCCO
  LOGICAL(int32), INTENT(IN) :: LD_LEOCSA
  LOGICAL(int32), INTENT(IN) :: LD_LEOCLA
  LOGICAL(int32), INTENT(IN) :: LD_LSCMEC
  LOGICAL(int32), INTENT(IN) :: LD_LROUGH
  LOGICAL(int32), INTENT(IN) :: LD_LEFLAKE
  LOGICAL(int32), INTENT(IN) :: LD_LEOCML
  LOGICAL(int32), INTENT(IN) :: LD_LOCMLTKE
  LOGICAL(int32), INTENT(IN) :: LD_LWCOU
  LOGICAL(int32), INTENT(IN) :: LD_LWCOU2W
  LOGICAL(int32), INTENT(IN) :: LD_LWCOUHMF
  REAL(KIND=real64), INTENT(IN) :: PEXTZ0M
  REAL(KIND=real64), INTENT(IN) :: PEXTZ0H
  REAL(KIND=real64), INTENT(IN) :: PTSTAND
  REAL(KIND=real64), INTENT(IN) :: PXP(6, 6)
  REAL(KIND=real64), INTENT(IN) :: PRCCNSEA
  REAL(KIND=real64), INTENT(IN) :: PRCCNLND
  REAL(KIND=real64), INTENT(IN) :: PRLAIINT
  REAL(KIND=real64), INTENT(IN) :: PRSUN(:)
  REAL(KIND=real64), INTENT(IN) :: PRCORIOI
  REAL(KIND=real64), INTENT(IN) :: PRPLRG
  INTEGER(KIND=int32), INTENT(IN) :: PNSNMLWS
  REAL(KIND=real64), INTENT(IN) :: PRVR0VT(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRVCMAX25(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRHUMREL(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRA1(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRB1(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRG0(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRGM25(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRE_VCMAX(:, :)
  REAL(KIND=real64), INTENT(IN) :: PRE_JMAX(:, :)
  TYPE(C_PTR), INTENT(OUT) :: YDSURF
  REAL(KIND=real64), INTENT(IN) :: PRALFMINPSN
  REAL(KIND=real64), INTENT(IN), OPTIONAL :: PRCIMIN
  type(c_ptr) :: private_surface
  type(tsurf), pointer :: surface
  private_surface = c_null_ptr
  call allo_surf(private_surface)
  surface => get_surf(private_surface)
  call susurf_ctl(ksw, kcss, kcsnec, ksil, kcom, ktiles, ktsw, klwemiss, &
                  ld_leflake, ld_leocml, ld_locmltke, ld_lwcou, ld_lwcou2w, ld_lwcouhmf, &
                  ld_llccnl, ld_llccno, ld_levgen, ld_lessro, ld_lelaiv, ld_lectessel, ld_leags, ld_lefarquhar, &
                  ld_leairco2coup, ld_lesn09, ld_lesnml, ld_leocwa, ld_leocco, ld_leocsa, ld_leocla, &
                  kalbedoscheme, kemissscheme, ld_lscmec, ld_lrough, pextz0m, pextz0h, pthrfrti, ptstand, pxp, &
                  prccnsea, prccnlnd, prlaiint, prsun, prcorioi, prplrg, pnsnmlws, &
                  prvr0vt, prvcmax25, prhumrel, pra1, prb1, prg0, prgm25, pre_vcmax, pre_jmax, &
                  surface%ydim, surface%yexc, surface%ycst, surface%yrad, surface%yrdi, surface%ylw, surface%ysw, &
                  surface%ysoil, surface%yveg, surface%yags, surface%yagf, surface%ymlm, surface%yflake, &
                  surface%yocean_ml, surface%yurb, pralfminpsn, prcimin)
  ydsurf = private_surface
end subroutine susurf
