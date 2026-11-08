!> Complete exponential-random cloud generator with native owners.
module md2asm_cloud_generator
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_finite
  use radiation_pdf_sampler, only: pdf_sampler_type
  use md2asm_cloud_random_stream, only: cloud_random_stream, initialize_random_numbers, uniform_distribution
  use md2asm_cloud_pdf_sampler, only: cloud_pdf_sampler, valid_cloud_pdf_sampler
  use md2asm_cloud_column_sampling, only: generate_column_exp_ran
  use forecast_public_scalar_math, only: power_original_rounding
  implicit none
  private
  public :: cloud_generator
contains
!> Sample every spectral column through the owned random and PDF children.
!! Fractions, overlap and spread are dimensionless. The supported scheme is1,
!! with ng1:4096 and nlev1:512. Sampler is a readonly canonical native table.
!! Scaling(ng,nlev) preserves its preimage below the cloud threshold and is
!! otherwise written completely. Total cover is dimensionless. Status0
!! succeeds,1 reports workspace failure and2 refuses unsupported metadata.
!! The public POW boundary retains its own qualified provider identity; this
!! caller's consumed power domain still requires independent byte evidence.
subroutine cloud_generator(ng,nlev,scheme,seed,threshold,fraction,overlap,decorrelation_scale,spread,sampler,scaling,total_cover,is_beta_overlap,status)
    integer(int32), intent(in) :: ng, nlev, scheme, seed
    real(real64), intent(in) :: threshold, fraction(:), overlap(:), decorrelation_scale, spread(:)
    type(pdf_sampler_type), intent(in), target :: sampler
    real(real64), intent(inout) :: scaling(:, :), total_cover
    logical, intent(in), optional :: is_beta_overlap
    integer(int32), intent(out) :: status
    type(cloud_pdf_sampler) :: table
    type(cloud_random_stream) :: stream
    real(real64), allocatable :: cumulative(:), pair(:), overhang(:), sharing(:), top_draw(:)
    integer :: j, g, first, last, top, allocation_status
    real(real64) :: reciprocal, trigger
    status = 2
    if (ng < 1 .or. ng > 4096 .or. nlev < 1 .or. nlev > 512 .or. scheme /= 1) return
    if (size(fraction) < nlev .or. size(spread) < nlev .or. size(overlap) < nlev - 1) return
    if (size(scaling, 1) < ng .or. size(scaling, 2) < nlev) return
    if (.not. ieee_is_finite(threshold) .or. threshold <= 0.0_real64 .or. threshold > 1.0_real64) return
    if (.not. ieee_is_finite(decorrelation_scale) .or. decorrelation_scale <= 0.0_real64) return
    reciprocal = 1.0_real64/decorrelation_scale
    if (.not. ieee_is_finite(reciprocal)) return
    if (.not. allocated(sampler%val)) return
    table%ncdf = sampler%ncdf; table%nfsd = sampler%nfsd
    table%fsd1 = sampler%fsd1; table%inv_fsd_interval = sampler%inv_fsd_interval
    table%table => sampler%val
    if (.not. valid_cloud_pdf_sampler(table)) return
    allocate (cumulative(nlev), pair(nlev - 1), overhang(nlev - 1), sharing(nlev - 1), top_draw(ng), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    call cumulative_cover(nlev, fraction, overlap, cumulative, pair, is_beta_overlap)
    total_cover = cumulative(nlev)
    do j = 1, nlev - 1
      overhang(j) = cumulative(j + 1) - cumulative(j)
    end do
    if (total_cover < threshold) then
      total_cover = 0.0_real64; status = 0; return
    end if
    first = 1
    do while (first <= nlev)
      if (fraction(first) > 0.0_real64) exit
      first = first + 1
    end do
    if (first > nlev) return
    last = first
    do j = first + 1, nlev
      if (fraction(j) > 0.0_real64) last = j
    end do
    do j = 1, nlev - 1
      sharing(j) = overlap(j)
    end do
    do j = first, last - 1
      if (overlap(j) > 0.0_real64) then
        reciprocal = 1.0_real64/decorrelation_scale
        sharing(j) = power_original_rounding(overlap(j), reciprocal)
      end if
    end do
    do j = 1, nlev
      do g = 1, ng
        scaling(g, j) = 0.0_real64
      end do
    end do
    call initialize_random_numbers(seed, stream, status)
    if (status /= 0) return
    call uniform_distribution(top_draw, stream, status)
    if (status /= 0) return
    do g = 1, ng
      trigger = top_draw(g)*total_cover; top = first
      do while (top < last)
        if (trigger <= cumulative(top)) exit
        top = top + 1
      end do
  call generate_column_exp_ran(ng,nlev,int(g,int32),stream,table,fraction,pair,cumulative,overhang,spread,sharing,int(top,int32),int(last,int32),scaling,status)
      if (status /= 0) return
    end do
    status = 0
  end subroutine
!> Accumulate the source exponential-random overlap, including optional beta.
!! This mathematical child has no consumed physical-constant dependency.
  subroutine cumulative_cover(n, fraction, overlap, cumulative, pair, use_beta)
    integer, intent(in) :: n
    real(real64), intent(in) :: fraction(:), overlap(:)
    real(real64), intent(inout) :: cumulative(:), pair(:)
    logical, intent(in), optional :: use_beta
    real(real64) :: upper, lower, alpha, a, b, c, d, cover
    real(real64), volatile :: clear
    real(real64), parameter :: covered = transfer(int(z'3FEFFFFFFFFFFFEC', int64), 0.0_real64)
    logical :: beta
    integer :: j
    upper = fraction(1); cumulative(1) = upper; clear = 1.0_real64 - upper
    if (n == 1) return
    beta = .false.; if (present(use_beta)) beta = use_beta
    do j = 1, n - 1
      lower = fraction(j + 1); alpha = overlap(j)
      if (beta) then
        if (alpha >= 1.0_real64) then
          alpha = 1.0_real64
        else
          a = upper - lower; a = abs(a); b = 1.0_real64 - alpha; b = b*a
          c = 1.0_real64/alpha; c = a + c; c = c - 1.0_real64; b = b/c; alpha = alpha + b
        end if
      end if
      a = numeric_maximum(upper, lower); a = alpha*a
      b = 1.0_real64 - alpha; c = upper + lower; d = upper*lower; c = c - d; b = b*c; cover = a + b
      pair(j) = cover
      if (upper >= covered) then
        clear = 0.0_real64
      else
        b = 1.0_real64 - cover; clear = clear*b; b = 1.0_real64 - upper; clear = clear/b
      end if
      cumulative(j + 1) = 1.0_real64 - clear; upper = lower
    end do
  end subroutine
!> Preserve the numeric maximum's sign rule for equal zero inputs.
  function numeric_maximum(a, b) result(c)
    real(real64), intent(in) :: a, b
    real(real64) :: c
    if (a > b) then
      c = a
    elseif (a < b) then
      c = b
    elseif (a == 0.0_real64) then
      c = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), c)
    else
      c = a
    end if
  end function
end module
