!> Reuse the complete native land exchange and numerical children.
!! The caller owns every record and array. No second parameter record is made.
!! Each entry retains its child's bounds, units, intent and ordered arithmetic.
module forecast_include_land_children_parameters
  use iso_fortran_env, only: int32, real64
  use yos_exc, only: texc
  use suvexc_mod, only: source_suvexc => suvexc
  use cptave_mod, only: source_cptave => cptave
  use srfrootfr_mod, only: source_srfrootfr => srfrootfr
  implicit none
  private
  public :: forward_suvexc, forward_cptave, forward_srfrootfr
contains
  !> Set the caller's canonical TEXC record through the native source body.
 !! The nine logical inputs select ocean, wave and roughness options.
 !! PEXTZ0M and PEXTZ0H are metres. PRPLRG is dimensionless and must be
 !! exactly one half, one or two, as required by the unchanged child.
  subroutine forward_suvexc(ld_leocwa, ld_leocco, ld_leocsa, ld_leocla, ld_lwcou, ld_lwcou2w, ld_lwcouhmf, &
                            ld_lscmec, ld_lrough, pextz0m, pextz0h, prplrg, ydexc)
   logical(int32), intent(in) :: ld_leocwa, ld_leocco, ld_leocsa, ld_leocla, ld_lwcou, ld_lwcou2w, ld_lwcouhmf, ld_lscmec, ld_lrough
    real(real64), intent(in) :: pextz0m, pextz0h, prplrg
    type(texc), intent(inout) :: ydexc
    call source_suvexc(ld_leocwa, ld_leocco, ld_leocsa, ld_leocla, ld_lwcou, ld_lwcou2w, ld_lwcouhmf, &
                       ld_lscmec, ld_lrough, pextz0m, pextz0h, prplrg, ydexc)
  end subroutine
  !> Produce six disjoint real64 vectors, each with three soil classes.
 !! PTHESAT, PTHECAP and PTHEPWP are water fractions in m3/m3.
 !! PCKSAT is m/s, PSISAT is metres and PB is dimensionless.
  subroutine forward_cptave(pthesat, pthecap, pthepwp, pcksat, psisat, pb)
    real(real64), intent(out) :: pthesat(:), pthecap(:), pthepwp(:), pcksat(:), psisat(:), pb(:)
    call source_cptave(pthesat, pthecap, pthepwp, pcksat, psisat, pb)
  end subroutine
  !> Read four soil layer thicknesses in metres and write root fractions.
 !! KLEVS=4 and KVTYPES=20. PSDEPTH has four real64 entries;
 !! the separate dimensionless real64 PROOTF output has shape (4,20).
  subroutine forward_srfrootfr(klevs, kvtypes, psdepth, prootf)
    integer(int32), intent(in) :: klevs, kvtypes
    real(real64), intent(in) :: psdepth(:)
    real(real64), intent(out) :: prootf(:, :)
    call source_srfrootfr(klevs, kvtypes, psdepth, prootf)
  end subroutine
end module
