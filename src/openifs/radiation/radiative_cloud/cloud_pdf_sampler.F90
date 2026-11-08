!> Ordered bilinear lookup of a dimensionless cloud-water sample.
module md2asm_cloud_pdf_sampler
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_finite
  implicit none
  private
  public :: cloud_pdf_sampler, sample_from_pdf, sample_from_pdf_simd, valid_cloud_pdf_sampler
  type :: cloud_pdf_sampler
    integer(int32) :: ncdf = 0, nfsd = 0
    real(real64) :: fsd1 = 0.0_real64, inv_fsd_interval = 0.0_real64
    real(real64), pointer :: table(:, :) => null()
  end type
  interface sample_from_pdf_simd
    module procedure sample_from_pdf
  end interface
contains
!> Check the complete read-only table extent before a caller changes outputs.
  logical function valid_cloud_pdf_sampler(sampler) result(valid)
    type(cloud_pdf_sampler), intent(in) :: sampler
    valid = .false.
    if (sampler%ncdf < 2 .or. sampler%nfsd < 2) return
    if (.not. associated(sampler%table)) return
    if (size(sampler%table, 1) < sampler%ncdf .or. size(sampler%table, 2) < sampler%nfsd) return
    if (.not. ieee_is_finite(sampler%fsd1) .or. .not. ieee_is_finite(sampler%inv_fsd_interval)) return
    valid = .true.
  end function
!> Interpolate four table corners in the original rounded addition order.
!! FSD and CDF are dimensionless input scalars. SAMPLE is one caller-owned
!! FP64 value and changes only on status0; status2 refuses invalid metadata
!! or a coordinate outside the source signed32-bit conversion domain.
  subroutine sample_from_pdf(sampler, fsd, cdf, sample, status)
    type(cloud_pdf_sampler), intent(in) :: sampler
    real(real64), intent(in) :: fsd, cdf
    real(real64), intent(inout) :: sample
    integer(int32), intent(out) :: status
    integer(int32) :: i, j
    real(real64) :: x, y, a, b, w, t1, t2, t3, t4, value
    status = 2
    if (.not. valid_cloud_pdf_sampler(sampler)) return
    if (.not. ieee_is_finite(fsd) .or. .not. ieee_is_finite(cdf)) return
    x = cdf*real(sampler%ncdf - 1, real64); x = x + 1.0_real64
    y = fsd - sampler%fsd1; y = y*sampler%inv_fsd_interval; y = y + 1.0_real64
    if (.not. ieee_is_finite(x) .or. .not. ieee_is_finite(y)) return
    if (x < -2147483648.0_real64 .or. x >= 2147483648.0_real64) return
    if (y < -2147483648.0_real64 .or. y >= 2147483648.0_real64) return
    i = int(x, int32); i = min(max(i, 1_int32), sampler%ncdf - 1)
    j = int(y, int32); j = min(max(j, 1_int32), sampler%nfsd - 1)
    x = x - real(i, real64); y = y - real(j, real64)
    if (x > 1.0_real64) x = 1.0_real64
    if (x <= 0.0_real64) x = 0.0_real64
    if (y > 1.0_real64) y = 1.0_real64
    if (y <= 0.0_real64) y = 0.0_real64
    a = 1.0_real64 - x; b = 1.0_real64 - y
    w = a*b; t1 = w*sampler%table(i, j)
    w = a*y; t2 = w*sampler%table(i, j + 1); value = t1 + t2
    w = x*b; t3 = w*sampler%table(i + 1, j); value = value + t3
    w = x*y; t4 = w*sampler%table(i + 1, j + 1); value = value + t4
    sample = value; status = 0
  end subroutine
end module
