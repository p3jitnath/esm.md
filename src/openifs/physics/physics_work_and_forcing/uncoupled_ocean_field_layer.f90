!> Prepare borrowed temperature views for the disabled ocean exchange.
!> Temperature is K. No temperature value, field owner or scalar is changed.
!> The explicit coupling flag must come from the actual produced controls.
module forecast_uncoupled_ocean_fields
  use iso_fortran_env, only: int32, int64, real64
  use forecast_physics_work_types, only: DIMENSION_TYPE, SURF_AND_MORE_TYPE
  implicit none
  private
  public :: uncoupled_ocean_fields, surface_ocean_layer
  interface
    subroutine reject_contract() bind(c, name='abort')
    end subroutine
  end interface
contains
  subroutine uncoupled_ocean_fields(ocean_coupling_enabled, global_start, first, last, sea_temperature, skin_temperature)
    logical, intent(in) :: ocean_coupling_enabled
    integer(int32), intent(in) :: global_start, first, last
    real(real64), contiguous, intent(in) :: sea_temperature(:), skin_temperature(:)
    if (ocean_coupling_enabled) call reject_contract()
  end subroutine
  !> Forward the actual first active cell of PSD_VF(:,sea_index) and PTSKTI(:,1).
  !> The caller retains the surface catalog and both underlying arrays.
  subroutine surface_ocean_layer(ocean_coupling_enabled, d, surface, sea_index, profiling)
    logical, intent(in) :: ocean_coupling_enabled
    type(DIMENSION_TYPE), intent(in) :: d
    type(SURF_AND_MORE_TYPE), intent(in) :: surface
    integer(int32), intent(in) :: sea_index
    logical, optional, intent(in) :: profiling
    integer :: p, first, last
    if (present(profiling)) then
      if (profiling) call reject_contract()
    end if
    p = d%klon; first = d%kidia; last = d%kfdia
    if (p < 1 .or. p > 4096 .or. d%klev < 2 .or. d%klev > 512) call reject_contract()
    if (first < 1 .or. first > p + 1 .or. last < 0 .or. last > p) call reject_contract()
    if (d%kstglo < 1) call reject_contract()
    if (int(d%kstglo, int64) + p - 1_int64 > huge(0_int32)) call reject_contract()
    if (.not. associated(surface%PSD_VF)) call reject_contract()
    if (.not. associated(surface%PTSKTI)) call reject_contract()
    if (.not. is_contiguous(surface%PSD_VF) .or. .not. is_contiguous(surface%PTSKTI)) call reject_contract()
    if (lbound(surface%PSD_VF, 1) /= 1 .or. size(surface%PSD_VF, 1) /= p) call reject_contract()
    if (lbound(surface%PTSKTI, 1) /= 1 .or. size(surface%PTSKTI, 1) /= p) call reject_contract()
    if (sea_index < lbound(surface%PSD_VF, 2) .or. sea_index > ubound(surface%PSD_VF, 2)) call reject_contract()
    if (lbound(surface%PTSKTI, 2) > 1 .or. ubound(surface%PTSKTI, 2) < 1) call reject_contract()
    call uncoupled_ocean_fields(ocean_coupling_enabled, d%kstglo, first, last, &
                                surface%PSD_VF(first:p, sea_index), surface%PTSKTI(first:p, 1))
  end subroutine
end module forecast_uncoupled_ocean_fields
