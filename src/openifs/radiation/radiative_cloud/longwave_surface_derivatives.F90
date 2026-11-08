!> Complete independent-column longwave surface sensitivity.
module md2asm_longwave_surface_derivatives
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: calc_lw_derivatives_ica, modify_lw_derivatives_ica
contains
!> Calculate dimensionless derivatives for one selected output column.
!! Transmission has shape(ng,nlev); surface_flux(ng) is in W/m2.
!! Derivatives(:,0:) retains all other columns and writes levels0:nlev.
  subroutine calc_lw_derivatives_ica(ng, nlev, icol, transmission, surface_flux, derivatives, status)
    integer(int32), intent(in) :: ng, nlev, icol
    real(real64), intent(in) :: transmission(:, :), surface_flux(:)
    real(real64), intent(inout) :: derivatives(:, 0:)
    integer(int32), intent(out) :: status
    call derivative_body(ng, nlev, icol, transmission, surface_flux, .false., 0.0_real64, derivatives, status)
  end subroutine
!> Blend each old layer derivative with the newly calculated response.
!! Weight is dimensionless; the surface value is exactly1 in both modes.
  subroutine modify_lw_derivatives_ica(ng, nlev, icol, transmission, surface_flux, weight, derivatives, status)
    integer(int32), intent(in) :: ng, nlev, icol
    real(real64), intent(in) :: transmission(:, :), surface_flux(:), weight
    real(real64), intent(inout) :: derivatives(:, 0:)
    integer(int32), intent(out) :: status
    call derivative_body(ng, nlev, icol, transmission, surface_flux, .true., weight, derivatives, status)
  end subroutine
  subroutine derivative_body(ng, nlev, icol, transmission, surface_flux, modify, weight, derivatives, status)
    integer(int32), intent(in) :: ng, nlev, icol
    real(real64), intent(in) :: transmission(:, :), surface_flux(:), weight
    logical, intent(in) :: modify
    real(real64), intent(inout) :: derivatives(:, 0:)
    integer(int32), intent(out) :: status
    real(real64) :: q(max(ng, 0)), total, response, a, v
    integer :: j, k
    status = 2
    if (ng < 0 .or. ng > 4096 .or. nlev < 0 .or. icol < 1 .or. icol > size(derivatives, 1)) return
    if (size(derivatives, 2) < nlev + 1 .or. size(surface_flux) < ng) return
    if (size(transmission, 1) < ng .or. size(transmission, 2) < nlev) return
    total = 0.0_real64
    do j = 1, ng
      total = total + surface_flux(j)
    end do
    do j = 1, ng
      q(j) = surface_flux(j)/total
    end do
    derivatives(icol, nlev) = 1.0_real64
    if (nlev == 0) then
      status = 0; return
    end if
    if (modify) a = 1.0_real64 - weight
    do k = nlev, 1, -1
      response = 0.0_real64
      do j = 1, ng
        q(j) = q(j)*transmission(j, k); response = response + q(j)
      end do
      if (modify) then
        v = a*derivatives(icol, k - 1); response = weight*response; response = v + response
      end if
      derivatives(icol, k - 1) = response
    end do
    status = 0
  end subroutine
end module
