!> Clear the complete source work arrays and the named surface columns.
!> P is the live column count and L is the layer count. Complete borrowed
!> arrays are written, including inactive columns. Their owners remain live.
!> Surface selectors are one-based columns in the actual registry surface views.
module forecast_physics_work_reset
  use iso_fortran_env, only: int32, real64
  use forecast_physics_work_types, only: DIMENSION_TYPE, DDH_SURF_TYPE, AUX_DIAG_TYPE, SURF_AND_MORE_TYPE, FLUX_TYPE
  implicit none
  private
  public :: physics_surface_zero_columns, initialize_runtime_physics_work, finish_runtime_physics_work
  public :: initialize_selected_physics_work, finish_selected_physics_work
  type physics_surface_zero_columns
    integer(int32) :: ucur = 0, vcur = 0
    integer(int32) :: odss = 0, oddu = 0, odom = 0, odbc = 0, odsu = 0, odni = 0, odam = 0, odvfa = 0, odvsu = 0
    integer(int32) :: aepm1 = 0, aepm25 = 0, aepm10 = 0, uvbed = 0, uvbedcs = 0
  end type
contains
  integer(int32) function initialize_runtime_physics_work(d, lecurr, columns, ddh, diag, surface, flux, profiling) result(status)
    type(DIMENSION_TYPE), intent(in) :: d
    logical, intent(in) :: lecurr
    type(physics_surface_zero_columns), intent(in) :: columns
    type(DDH_SURF_TYPE), intent(inout) :: ddh
    type(AUX_DIAG_TYPE), intent(inout) :: diag
    type(SURF_AND_MORE_TYPE), intent(inout) :: surface
    type(FLUX_TYPE), intent(inout) :: flux
    logical, optional, intent(in) :: profiling
    integer(int32) :: vd(14), vf(2)
    integer :: j
    status = 2
    if (present(profiling)) then
      if (profiling) return
    end if
    if (d%klon < 1 .or. d%klon > 1024 .or. d%klev < 1 .or. d%klev > 512) return
    if (.not. associated(ddh%PDHTLS)) return
    if (.not. is_contiguous(ddh%PDHTLS)) return
    if (.not. associated(ddh%PDHTSS)) return
    if (.not. is_contiguous(ddh%PDHTSS)) return
    if (.not. associated(ddh%PDHTTS)) return
    if (.not. is_contiguous(ddh%PDHTTS)) return
    if (.not. associated(ddh%PDHTIS)) return
    if (.not. is_contiguous(ddh%PDHTIS)) return
    if (.not. associated(ddh%PDHSSS)) return
    if (.not. is_contiguous(ddh%PDHSSS)) return
    if (.not. associated(ddh%PDHIIS)) return
    if (.not. is_contiguous(ddh%PDHIIS)) return
    if (.not. associated(ddh%PDHWLS)) return
    if (.not. is_contiguous(ddh%PDHWLS)) return
    if (.not. associated(diag%PMFUDE_RATE)) return
    if (.not. is_contiguous(diag%PMFUDE_RATE)) return
    if (.not. associated(diag%PMFDDE_RATE)) return
    if (.not. is_contiguous(diag%PMFDDE_RATE)) return
    if (.not. associated(diag%PMFU)) return
    if (.not. is_contiguous(diag%PMFU)) return
    if (.not. associated(diag%PMFD)) return
    if (.not. is_contiguous(diag%PMFD)) return
    if (.not. associated(diag%ZLUDE)) return
    if (.not. is_contiguous(diag%ZLUDE)) return
    if (.not. associated(diag%ZLUDELI)) return
    if (.not. is_contiguous(diag%ZLUDELI)) return
    if (.not. associated(diag%ZSNDE)) return
    if (.not. is_contiguous(diag%ZSNDE)) return
    if (.not. associated(diag%PRSUD)) return
    if (.not. is_contiguous(diag%PRSUD)) return
    if (.not. associated(diag%ZLU)) return
    if (.not. is_contiguous(diag%ZLU)) return
    if (.not. associated(diag%ZLRAIN)) return
    if (.not. is_contiguous(diag%ZLRAIN)) return
    if (.not. associated(diag%PCOVPTOT)) return
    if (.not. is_contiguous(diag%PCOVPTOT)) return
    if (.not. associated(diag%ZCAPE)) return
    if (.not. is_contiguous(diag%ZCAPE)) return
    if (.not. associated(diag%PVISIH)) return
    if (.not. is_contiguous(diag%PVISIH)) return
    if (.not. associated(diag%PLIGH_TOT)) return
    if (.not. is_contiguous(diag%PLIGH_TOT)) return
    if (.not. associated(diag%PLIGH_CTG)) return
    if (.not. is_contiguous(diag%PLIGH_CTG)) return
    if (.not. associated(diag%PCHARGE_LIG)) return
    if (.not. is_contiguous(diag%PCHARGE_LIG)) return
    if (.not. associated(diag%ITYPE)) return
    if (.not. is_contiguous(diag%ITYPE)) return
    if (.not. associated(diag%IPBLTYPE)) return
    if (.not. is_contiguous(diag%IPBLTYPE)) return
    if (.not. associated(diag%ICBOT)) return
    if (.not. is_contiguous(diag%ICBOT)) return
    if (.not. associated(diag%ICTOP)) return
    if (.not. is_contiguous(diag%ICTOP)) return
    if (.not. associated(diag%ICBOT_LIG)) return
    if (.not. is_contiguous(diag%ICBOT_LIG)) return
    if (.not. associated(diag%ICTOP_LIG)) return
    if (.not. is_contiguous(diag%ICTOP_LIG)) return
    if (.not. associated(surface%PTSAE1)) return
    if (.not. is_contiguous(surface%PTSAE1)) return
    if (.not. associated(surface%PWSAE1)) return
    if (.not. is_contiguous(surface%PWSAE1)) return
    if (.not. associated(surface%PTIAE1)) return
    if (.not. is_contiguous(surface%PTIAE1)) return
    if (.not. associated(surface%PTLE1)) return
    if (.not. is_contiguous(surface%PTLE1)) return
    if (.not. associated(surface%PWLE1)) return
    if (.not. is_contiguous(surface%PWLE1)) return
    if (.not. associated(surface%PSNSE1)) return
    if (.not. is_contiguous(surface%PSNSE1)) return
    if (.not. associated(surface%PASNE1)) return
    if (.not. is_contiguous(surface%PASNE1)) return
    if (.not. associated(surface%PRSNE1)) return
    if (.not. is_contiguous(surface%PRSNE1)) return
    if (.not. associated(surface%PTSNE1)) return
    if (.not. is_contiguous(surface%PTSNE1)) return
    if (.not. associated(surface%PWSNE1)) return
    if (.not. is_contiguous(surface%PWSNE1)) return
    if (.not. associated(surface%PTLICEE1)) return
    if (.not. is_contiguous(surface%PTLICEE1)) return
    if (.not. associated(surface%PTLMNWE1)) return
    if (.not. is_contiguous(surface%PTLMNWE1)) return
    if (.not. associated(surface%PTLWMLE1)) return
    if (.not. is_contiguous(surface%PTLWMLE1)) return
    if (.not. associated(surface%PTLBOTE1)) return
    if (.not. is_contiguous(surface%PTLBOTE1)) return
    if (.not. associated(surface%PTLSFE1)) return
    if (.not. is_contiguous(surface%PTLSFE1)) return
    if (.not. associated(surface%PHLICEE1)) return
    if (.not. is_contiguous(surface%PHLICEE1)) return
    if (.not. associated(surface%PHLMLE1)) return
    if (.not. is_contiguous(surface%PHLMLE1)) return
    if (.not. associated(flux%PDIFTI)) return
    if (.not. is_contiguous(flux%PDIFTI)) return
    if (.not. associated(flux%PDIFTL)) return
    if (.not. is_contiguous(flux%PDIFTL)) return
    if (.not. associated(flux%PFCQNNG)) return
    if (.not. is_contiguous(flux%PFCQNNG)) return
    if (.not. associated(flux%PFCQLNG)) return
    if (.not. is_contiguous(flux%PFCQLNG)) return
    if (.not. associated(flux%PFCSQN)) return
    if (.not. is_contiguous(flux%PFCSQN)) return
    if (.not. associated(flux%PFCSQL)) return
    if (.not. is_contiguous(flux%PFCSQL)) return
    if (.not. associated(flux%PFSQRF)) return
    if (.not. is_contiguous(flux%PFSQRF)) return
    if (.not. associated(flux%PFSQSF)) return
    if (.not. is_contiguous(flux%PFSQSF)) return
    if (.not. associated(flux%PFCQRNG)) return
    if (.not. is_contiguous(flux%PFCQRNG)) return
    if (.not. associated(flux%PFCQSNG)) return
    if (.not. is_contiguous(flux%PFCQSNG)) return
    if (.not. associated(flux%PFSQLTUR)) return
    if (.not. is_contiguous(flux%PFSQLTUR)) return
    if (.not. associated(flux%PFSQITUR)) return
    if (.not. is_contiguous(flux%PFSQITUR)) return
    if (.not. associated(flux%PFCCQL)) return
    if (.not. is_contiguous(flux%PFCCQL)) return
    if (.not. associated(flux%PFCCQN)) return
    if (.not. is_contiguous(flux%PFCCQN)) return
    if (.not. associated(flux%PFPLCL)) return
    if (.not. is_contiguous(flux%PFPLCL)) return
    if (.not. associated(flux%PFPLCN)) return
    if (.not. is_contiguous(flux%PFPLCN)) return
    if (.not. associated(flux%PFPLSL)) return
    if (.not. is_contiguous(flux%PFPLSL)) return
    if (.not. associated(flux%PFPLSN)) return
    if (.not. is_contiguous(flux%PFPLSN)) return
    if (.not. associated(flux%PFCQNG)) return
    if (.not. is_contiguous(flux%PFCQNG)) return
    vd = [columns%odss, columns%oddu, columns%odom, columns%odbc, columns%odsu, columns%odni, columns%odam, &
          columns%odvfa, columns%odvsu, columns%aepm1, columns%aepm25, columns%aepm10, columns%uvbed, columns%uvbedcs]
    vf = [columns%ucur, columns%vcur]
    if (.not. associated(surface%PSD_VD)) return
    if (.not. is_contiguous(surface%PSD_VD)) return
    if (lbound(surface%PSD_VD, 1) /= 1 .or. size(surface%PSD_VD, 1) < d%klon) return
    if (any(vd < lbound(surface%PSD_VD, 2)) .or. any(vd > ubound(surface%PSD_VD, 2))) return
    if (.not. lecurr) then
      if (.not. associated(surface%PSD_VF)) return
      if (.not. is_contiguous(surface%PSD_VF)) return
      if (lbound(surface%PSD_VF, 1) /= 1 .or. size(surface%PSD_VF, 1) < d%klon) return
      if (any(vf < lbound(surface%PSD_VF, 2)) .or. any(vf > ubound(surface%PSD_VF, 2))) return
    end if
    ddh%PDHTLS = 0.0_real64
    ddh%PDHTSS = 0.0_real64
    ddh%PDHTTS = 0.0_real64
    ddh%PDHTIS = 0.0_real64
    ddh%PDHSSS = 0.0_real64
    ddh%PDHIIS = 0.0_real64
    ddh%PDHWLS = 0.0_real64
    diag%PMFUDE_RATE = 0.0_real64
    diag%PMFDDE_RATE = 0.0_real64
    diag%PMFU = 0.0_real64
    diag%PMFD = 0.0_real64
    diag%ZLUDE = 0.0_real64
    diag%ZLUDELI = 0.0_real64
    diag%ZSNDE = 0.0_real64
    diag%PRSUD = 0.0_real64
    diag%ZLU = 0.0_real64
    diag%ZLRAIN = 0.0_real64
    diag%PCOVPTOT = 0.0_real64
    diag%ZCAPE = 0.0_real64
    diag%PVISIH = 0.0_real64
    diag%PLIGH_TOT = 0.0_real64
    diag%PLIGH_CTG = 0.0_real64
    diag%PCHARGE_LIG = 0.0_real64
    diag%ITYPE = 0_int32
    diag%IPBLTYPE = 0_int32
    diag%ICBOT = 0_int32
    diag%ICTOP = 0_int32
    diag%ICBOT_LIG = 0_int32
    diag%ICTOP_LIG = 0_int32
    surface%PTSAE1 = 0.0_real64
    surface%PWSAE1 = 0.0_real64
    surface%PTIAE1 = 0.0_real64
    surface%PTLE1 = 0.0_real64
    surface%PWLE1 = 0.0_real64
    surface%PSNSE1 = 0.0_real64
    surface%PASNE1 = 0.0_real64
    surface%PRSNE1 = 0.0_real64
    surface%PTSNE1 = 0.0_real64
    surface%PWSNE1 = 0.0_real64
    surface%PTLICEE1 = 0.0_real64
    surface%PTLMNWE1 = 0.0_real64
    surface%PTLWMLE1 = 0.0_real64
    surface%PTLBOTE1 = 0.0_real64
    surface%PTLSFE1 = 0.0_real64
    surface%PHLICEE1 = 0.0_real64
    surface%PHLMLE1 = 0.0_real64
    if (.not. lecurr) then
      do j = 1, 2
        surface%PSD_VF(1:d%klon, vf(j)) = 0.0_real64
      end do
    end if
    do j = 1, 14
      surface%PSD_VD(1:d%klon, vd(j)) = 0.0_real64
    end do
    flux%PDIFTI = 0.0_real64
    flux%PDIFTL = 0.0_real64
    flux%PFCQNNG = 0.0_real64
    flux%PFCQLNG = 0.0_real64
    flux%PFCSQN = 0.0_real64
    flux%PFCSQL = 0.0_real64
    flux%PFSQRF = 0.0_real64
    flux%PFSQSF = 0.0_real64
    flux%PFCQRNG = 0.0_real64
    flux%PFCQSNG = 0.0_real64
    flux%PFSQLTUR = 0.0_real64
    flux%PFSQITUR = 0.0_real64
    flux%PFCCQL = 0.0_real64
    flux%PFCCQN = 0.0_real64
    flux%PFPLCL = 0.0_real64
    flux%PFPLCN = 0.0_real64
    flux%PFPLSL = 0.0_real64
    flux%PFPLSN = 0.0_real64
    flux%PFCQNG = 0.0_real64
    status = 0
  end function
  !> The selected source finalizer has no work when profiling is disabled.
  integer(int32) function finish_runtime_physics_work(d, profiling) result(status)
    type(DIMENSION_TYPE), intent(in) :: d
    logical, optional, intent(in) :: profiling
    status = 2
    if (present(profiling)) then
      if (profiling) return
    end if
    if (d%klon < 1 .or. d%klon > 1024 .or. d%klev < 1 .or. d%klev > 512) return
    status = 0
  end function
  integer(int32) function initialize_selected_physics_work(d, lecurr, columns, ddh, diag, surface, flux, profiling) result(status)
    type(DIMENSION_TYPE), intent(in) :: d
    logical, intent(in) :: lecurr
    type(physics_surface_zero_columns), intent(in) :: columns
    type(DDH_SURF_TYPE), intent(inout) :: ddh
    type(AUX_DIAG_TYPE), intent(inout) :: diag
    type(SURF_AND_MORE_TYPE), intent(inout) :: surface
    type(FLUX_TYPE), intent(inout) :: flux
    logical, optional, intent(in) :: profiling
    status = 2
    if (d%klon /= 24 .or. d%klev /= 19) return
    status = initialize_runtime_physics_work(d, lecurr, columns, ddh, diag, surface, flux, profiling)
  end function
  integer(int32) function finish_selected_physics_work(d, profiling) result(status)
    type(DIMENSION_TYPE), intent(in) :: d
    logical, optional, intent(in) :: profiling
    status = 2
    if (d%klon /= 24 .or. d%klev /= 19) return
    status = finish_runtime_physics_work(d, profiling)
  end function
end module forecast_physics_work_reset
