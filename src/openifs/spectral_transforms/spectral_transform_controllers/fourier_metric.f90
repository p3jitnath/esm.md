!> Apply the Gaussian Fourier metric and ordered complex derivatives.
module forecast_native_fourier_metric
  use iso_fortran_env, only: int32, int64, real64
  use forecast_native_transform_controller_state, only: native_transform_controller_state
  implicit none
  private
  public :: fsc
contains
!> Fields are rows and Fourier positions are columns, with any native nonzero strides.
!! RACTHE has units 1/m. Input and output field views may share disjoint owner slices.
  subroutine fsc(c, kgl, kf_uv, kf_scalars, kf_scders, puv, pscalar, pnsders, pewders, puvders, status)
    type(native_transform_controller_state), intent(in) :: c
    integer(int32), intent(in) :: kgl, kf_uv, kf_scalars, kf_scders
    real(real64), intent(inout) :: puv(:, :), pnsders(:, :), pewders(:, :), puvders(:, :)
    real(real64), intent(in) :: pscalar(:, :)
    integer(int32), intent(out) :: status
    integer :: j, m, s, cols, nuv, f, col
    real(real64) :: g, k, real_part, negative_imaginary
    status = 2
    if (c%latlon .or. .not. associated(c%layout) .or. .not. associated(c%racthe)) return
    if (kf_uv < 0 .or. kf_scalars < 0 .or. kf_scders < 0) return
    if (kf_uv > huge(1_int32)/2) return
    if (.not. associated(c%layout%maximum_wave) .or. .not. associated(c%layout%column_offset)) return
    j = c%layout%first_latitude + kgl - 1
    if (j < lbound(c%layout%maximum_wave, 1) .or. j > ubound(c%layout%maximum_wave, 1)) return
    if (j < lbound(c%racthe, 1) .or. j > ubound(c%racthe, 1)) return
    if (kgl < lbound(c%layout%column_offset, 1) .or. kgl > ubound(c%layout%column_offset, 1)) return
    m = c%layout%maximum_wave(j); s = c%layout%column_offset(kgl)
    if (m < 0 .or. m > 4096 .or. s < 0) return
    cols = 2*(m + 1); nuv = 2*kf_uv
    if (nuv > 0) then
      if (size(puv, 1) < nuv .or. size(puv, 2) < s + cols) return
      if (c%luvder) then
        if (size(puvders, 1) < nuv .or. size(puvders, 2) < s + cols) return
      end if
    end if
    if (kf_scders > 0 .and. kf_scalars > 0) then
      if (size(pnsders, 1) < kf_scalars .or. size(pnsders, 2) < s + cols) return
      if (size(pscalar, 1) < kf_scalars .or. size(pscalar, 2) < s + cols) return
      if (size(pewders, 1) < kf_scalars .or. size(pewders, 2) < s + cols) return
    end if
    g = c%racthe(j)
    do col = s + 1, s + cols
      do f = 1, nuv
        puv(f, col) = puv(f, col)*g
      end do
    end do
    if (kf_scders > 0) then
      do col = s + 1, s + cols
        do f = 1, kf_scalars
          pnsders(f, col) = pnsders(f, col)*g
        end do
      end do
    end if
    if (c%luvder .and. nuv > 0) then
      do j = 0, m
        k = g*real(j, real64); col = s + 2*j + 1
        do f = 1, nuv
          real_part = puv(f, col); negative_imaginary = -puv(f, col + 1)
          puvders(f, col) = negative_imaginary*k
          puvders(f, col + 1) = real_part*k
        end do
      end do
    end if
    if (kf_scders > 0 .and. kf_scalars > 0) then
      do j = 0, m
        k = g*real(j, real64); col = s + 2*j + 1
        do f = 1, kf_scalars
          real_part = pscalar(f, col); negative_imaginary = -pscalar(f, col + 1)
          pewders(f, col) = negative_imaginary*k
          pewders(f, col + 1) = real_part*k
        end do
      end do
    end if
    status = 0
  end subroutine
end module
