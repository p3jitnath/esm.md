!> Explicit runtime-grid entry points for the complete owned wave calculations.
module md2asm_runtime_nonorographic_waves
  use iso_fortran_env, only: int32, real64
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_standard_atmosphere_setup, only: standard_atmosphere_state
  use forecast_physics_work_types, only: dimension_type, state_type, aux_type, flux_type
  use md2asm_nonorographic_gravity_waves, only: gwdrag_wms
  use md2asm_nonorographic_gravity_wave_launches, only: gwdragwms_layer
  implicit none
  private
  public :: runtime_nonorographic_gravity_wave, runtime_nonorographic_wave_launches
contains
!> Preserve original22 fields and select the source fine-grid spacing factor.
!! Weather and pressure owners retain the complete child's native shapes and
!! SI units. Tendencies and half-level momentum fluxes are INOUT. The runtime
!! default-control admission, empty prefix, status and ordered math are owned
!! by the unchanged child. No additional numerical operation occurs here.
subroutine runtime_nonorographic_gravity_wave(constants,ydsta,ydegwd,ydegwwms,kidia,kfdia,klon,klev,klaunch,ptstep,ptm1,pum1,pvm1,papm1,paphm1,pgeo1,pgelat,pgaw,pprecip,ptenu,ptenv,pfluxu,pfluxv,status)
    type(forecast_physical_constants), intent(in) :: constants
    type(standard_atmosphere_state), intent(in) :: ydsta
    type(tegwd), intent(in) :: ydegwd
    type(tegwwms), intent(in) :: ydegwwms
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, klaunch
    real(real64),intent(in)::ptstep,ptm1(:,:),pum1(:,:),pvm1(:,:),papm1(:,:),paphm1(:,0:),pgeo1(:,:),pgelat(:),pgaw(:),pprecip(:)
    real(real64), intent(inout) :: ptenu(:, :), ptenv(:, :), pfluxu(:, 0:), pfluxv(:, 0:)
    integer(int32), intent(out) :: status
 call gwdrag_wms(constants,ydsta,ydegwd,ydegwwms,kidia,kfdia,klon,klev,klaunch,ptstep,ptm1,pum1,pvm1,papm1,paphm1,pgeo1,pgelat,pgaw,pprecip,ptenu,ptenv,pfluxu,pfluxv,status,runtime_grid_spacing=.true.)
  end subroutine
!> Accumulate all actual launches with the same complete runtime-grid child.
!! Native work records are borrowed; NOGW_U/V and selected FLUX stress cells
!! change in the original source order. Their complete child bounds apply.
  subroutine runtime_nonorographic_wave_launches(constants, ydsta, ydegwd, ydegwwms, dim, state, aux, flux, nogw_u, nogw_v, status)
    type(forecast_physical_constants), intent(in) :: constants
    type(standard_atmosphere_state), intent(in) :: ydsta
    type(tegwd), intent(in) :: ydegwd
    type(tegwwms), intent(in) :: ydegwwms
    type(dimension_type), intent(in) :: dim
    type(state_type), intent(in) :: state
    type(aux_type), intent(in) :: aux
    type(flux_type), intent(inout) :: flux
    real(real64), intent(inout) :: nogw_u(:, :), nogw_v(:, :)
    integer(int32), intent(out) :: status
call gwdragwms_layer(constants, ydsta, ydegwd, ydegwwms, dim, state, aux, flux, nogw_u, nogw_v, status, runtime_grid_spacing=.true.)
  end subroutine
end module
