!> Transform live scalar Fullpos fields through the same public DIR_TRANS stage.
module forecast_runtime_scalar_output_transform
  use iso_fortran_env, only: int32, int64, real64
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  use forecast_distributed_partition_types, only: native_distributed_partition
  use md2asm_scalar_output_transform_caller, only: scalar_output_request, output_stage_counters
  use md2asm_external_transform_services, only: direct_transform_service
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: transform_runtime_fullpos_scalars
contains
  !> Keep scalar transform order and counters with live counts and public handle.
  !! PGP has (block_width,global_scalar_fields,local_blocks). PSCA has
  !! (local_scalar_fields,local_spectral_words). Both retain field units.
  !! The current world1:32 route has one vertical set; its all-one map derives
  !! from checked NPRTRV=MYSETV=1, independently of the wave-process count.
  !! Nonzero fields consume actual canonical control/resolution/partition owners.
  !! Source profiling uses the optional public FIAT policy. No message lifetime
  !! is started or ended here. The caller retains disjoint contiguous arrays.
  subroutine transform_runtime_fullpos_scalars(request, pgp, psca, counters, control, resolution, partition, status, profile)
    type(scalar_output_request), intent(in) :: request
    real(real64), intent(in) :: pgp(:, :, :)
    real(real64), intent(inout) :: psca(:, :)
    type(output_stage_counters), intent(inout) :: counters
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    type(native_distributed_partition), intent(in) :: partition
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    integer(int32) :: n, width, blocks
    status = 2
    width = 0
    n = request%nfpscag
    if (n < 0 .or. n > 65536 .or. request%nfpvecg /= 0) return
    if (n > 0) then
      if (.not. control%message_ready .or. .not. control%environment_ready) return
      if (control%nproc < 1 .or. control%nproc > 32 .or. control%myproc < 1 .or. control%myproc > control%nproc) return
      if (control%nprtrv /= 1 .or. control%mysetv /= 1 .or. control%nprtrw /= control%nproc) return
      if (resolution%resolution < 1 .or. resolution%truncation < 1 .or. resolution%truncation > 8191) return
      if (partition%phase /= 7 .or. partition%ngptot < 1 .or. partition%nspec2 < 1) return
      width = size(pgp, 1)
      if (width < 1 .or. width > 1024) return
      blocks = int((int(partition%ngptot, int64) + width - 1)/width)
      if (size(pgp, 2) /= n .or. size(pgp, 3) /= blocks) return
      if (size(psca, 1) /= n .or. size(psca, 2) /= partition%nspec2) return
      if (.not. is_contiguous(pgp) .or. .not. is_contiguous(psca)) return
    end if
    call transform_admitted_scalars(n, width, pgp, psca, counters, resolution, status, profile)
  end subroutine

  !> Allocate the bounded native stack workspace only after complete admission.
  subroutine transform_admitted_scalars(n, width, pgp, psca, counters, resolution, status, profile)
    integer(int32), intent(in) :: n, width
    real(real64), intent(in) :: pgp(:, :, :)
    real(real64), intent(inout) :: psca(:, :)
    type(output_stage_counters), intent(inout) :: counters
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    integer(int32) :: sets(max(1, n)), j, child_status
    real(real64) :: hook_handle
    call transform_profile_event('TRANSDIR_FP', 0_int32, hook_handle, profile)
    do j = 1, n
      sets(j) = 1
    end do
    child_status = 0
    if (n > 0) call direct_transform_service(PSPSCALAR=psca, KPROMA=width, KVSETSC=sets(1:n), &
                                             KRESOL=resolution%resolution, PGP=pgp, status=child_status)
    call transform_profile_event('TRANSDIR_FP', 1_int32, hook_handle, profile)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    call increment_source_counter(counters%scalar_direct)
    status = 0
  end subroutine
end module
