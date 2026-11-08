!> Complete selected scalar-only TRANSDIR_FP caller.
module md2asm_scalar_output_transform_caller
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_external_transform_services, only: direct_transform_service
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: scalar_output_request, output_stage_counters, transdir_fp
  type :: scalar_output_request
    integer(int32) :: nfpscag = 0, nfpvecg = 0
  end type
  type :: output_stage_counters
    integer(int64) :: scalar_direct = 0_int64
  end type
contains
!> Transform requested scalar grid fields through the actual public DIR_TRANS.
!! REQUEST supplies dimensionless global scalar and vector counts. PGP is
!! REAL64(24,NFPSCAG,blocks), read only, in the source field's physical units.
!! PSCA is REAL64(NFPSCAG,spectral_words), inout so all unwritten bytes survive.
!! The compiler owns array descriptors; the caller owns both disjoint arrays.
!! COUNTERS is borrowed native state. STATUS is 0 on completion or 2 when
!! native bounds or the selected scalar-only controls are unsupported.
!! Optional PROFILE enables paired real FIAT hooks. The caller establishes
!! nearest-even rounding and gradual underflow before this source route.
  subroutine transdir_fp(request, pgp, psca, counters, status, profile)
    type(scalar_output_request), intent(in) :: request
    real(real64), intent(in) :: pgp(:, :, :)
    real(real64), intent(inout) :: psca(:, :)
    type(output_stage_counters), intent(inout) :: counters
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    integer(int32) :: sets(39), n, j, child_status
    real(real64) :: hook_handle
    status = 2_int32
    n = request%nfpscag
    if (n < 0 .or. n > 39) return
    if (request%nfpvecg /= 0) return
    if (n > 0) then
      if (size(pgp, 1) /= 24) return
      if (size(pgp, 2) /= n) return
      if (size(pgp, 3) < 1) return
      if (size(psca, 1) /= n) return
      if (size(psca, 2) < 1) return
    end if
    call transform_profile_event('TRANSDIR_FP', 0_int32, hook_handle, profile)
    do j = 1, n
      sets(j) = 1_int32
    end do
    child_status = 0_int32
    if (n > 0) then
     call direct_transform_service(PSPSCALAR=psca, KPROMA=24_int32, KVSETSC=sets(1:n), KRESOL=1_int32, PGP=pgp, status=child_status)
    end if
    call transform_profile_event('TRANSDIR_FP', 1_int32, hook_handle, profile)
    if (child_status /= 0_int32) then
      status = child_status
      return
    end if
    call increment_source_counter(counters%scalar_direct)
    status = 0_int32
  end subroutine
end module
