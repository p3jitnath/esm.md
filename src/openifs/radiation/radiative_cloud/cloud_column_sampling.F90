!> Complete exponential-random cloud-column sampling with explicit owners.
module md2asm_cloud_column_sampling
  use iso_fortran_env, only: int32, real64
  use md2asm_cloud_random_stream, only: cloud_random_stream, uniform_distribution
  use md2asm_cloud_pdf_sampler, only: cloud_pdf_sampler, sample_from_pdf, valid_cloud_pdf_sampler
  implicit none
  private
  public :: generate_column_exp_ran
contains
!> Fill selected cloudy cells while preserving clear cells and other columns.
!! NG and NLEV give the full (sample,level) output shape. IG is one-based.
!! Fractions, pair covers, cumulative cover, overhang, spread and sharing
!! are dimensionless read-only arrays. TOP:BOTTOM is a valid cloudy region.
!! STREAM is the sole random owner. Status0 succeeds; status1 reports failed
!! private allocation; status2 rejects metadata before the first draw.
subroutine generate_column_exp_ran(ng,nlev,ig,stream,sampler,fraction,pair,cumulative,overhang,spread,sharing,top,bottom,multiplier,status)
    integer(int32), intent(in) :: ng, nlev, ig, top, bottom
    type(cloud_random_stream), intent(inout) :: stream
    type(cloud_pdf_sampler), intent(in) :: sampler
    real(real64), intent(in) :: fraction(:), pair(:), cumulative(:), overhang(:), spread(:), sharing(:)
    real(real64), intent(inout) :: multiplier(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: location(:), variation(:), share(:)
    real(real64) :: a, b
    integer :: i, j, count, position, layer, allocation_status
    status = 2
    if (ng < 1 .or. nlev < 1 .or. ig < 1 .or. ig > ng) return
    if (top < 1 .or. bottom < top .or. bottom > nlev) return
    if (size(multiplier, 1) < ng .or. size(multiplier, 2) < nlev) return
    if (size(fraction) < nlev .or. size(cumulative) < nlev .or. size(spread) < nlev) return
    if (size(pair) < nlev - 1 .or. size(overhang) < nlev - 1 .or. size(sharing) < nlev - 1) return
    if (.not. valid_cloud_pdf_sampler(sampler)) return
    allocate (location(nlev), variation(nlev), share(nlev), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    call uniform_distribution(location(1:bottom + 1 - top), stream, status)
    if (status /= 0) return
    count = 1; position = 0
    do j = top + 1, bottom + 1
      if (j <= bottom) then
        position = position + 1
        a = location(position)
        if (count /= 0) then
          b = fraction(j) + fraction(j - 1); b = b - pair(j - 1)
          a = a*fraction(j - 1)
          if (a < b) then
            count = count + 1; cycle
          end if
        else
          b = cumulative(j - 1) - fraction(j - 1); a = a*b
          b = pair(j - 1) - overhang(j - 1); b = b - fraction(j - 1)
          if (a < b) count = 1
          cycle
        end if
      end if
      call uniform_distribution(variation(1:count), stream, status)
      if (status /= 0) return
      call uniform_distribution(share(1:count), stream, status)
      if (status /= 0) return
      do i = 2, count
        layer = j - count + i - 2
        if (share(i) < sharing(layer)) variation(i) = variation(i - 1)
      end do
      do i = 1, count
        layer = j - count + i - 1
        call sample_from_pdf(sampler, spread(layer), variation(i), multiplier(ig, layer), status)
        if (status /= 0) return
      end do
      count = 0
    end do
    status = 0
  end subroutine
end module
