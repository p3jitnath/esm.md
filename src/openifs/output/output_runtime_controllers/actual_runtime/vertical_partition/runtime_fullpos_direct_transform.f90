!> Keep the spherical Fullpos direct-transform field order at live resolution.
module forecast_runtime_fullpos_direct_transform
  use iso_fortran_env, only: int32, int64, real64
  use forecast_output_request_types, only: type_fprqdyn
  use forecast_runtime_output_vertical_sets, only: derive_runtime_output_vertical_sets
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  use forecast_distributed_partition_types, only: native_distributed_partition
  use md2asm_external_transform_services, only: direct_transform_service
  use md2asm_scalar_output_transform_caller, only: output_stage_counters
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: transform_runtime_fullpos_fields
contains
  !> Transform U components, V components and scalar fields in source order.
 !! PGP is REAL64(pitch,2*global_vectors+global_scalars,local_blocks).
 !! PSCA/PVOR/PDIV are REAL64(local_fields,local_spectral_words), INOUT.
 !! Inputs share the actual initialized public context. Global set maps come
 !! from the classified request; spectral arrays contain this group only.
  subroutine transform_runtime_fullpos_fields(request, pgp, psca, pvor, pdiv, counters, &
                                              control, resolution, partition, limited_area, status, profile)
    type(type_fprqdyn), intent(in) :: request
    real(real64), intent(in) :: pgp(:, :, :)
    real(real64), intent(inout) :: psca(:, :), pvor(:, :), pdiv(:, :)
    type(output_stage_counters), intent(inout) :: counters
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    type(native_distributed_partition), intent(in) :: partition
    logical, intent(in) :: limited_area
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    integer :: s, v, width, blocks
    integer(int64) :: field_count
    status = 2
    if (limited_area) return
    s = request%nfpscag; v = request%nfpvecg
    if (s < 0 .or. v < 0 .or. s > 65536 .or. v > 32768) return
    field_count = int(s, int64) + 2_int64*v
    if (field_count > 65536) return
    width = 0
    if (field_count > 0) then
      if (.not. control%message_ready .or. .not. control%environment_ready) return
      if (control%nproc < 1 .or. control%nproc > 32 .or. control%myproc < 1 .or. control%myproc > control%nproc) return
      if (control%nprtrv < 1 .or. control%nprtrv > control%nproc) return
      if (control%mysetv < 1 .or. control%mysetv > control%nprtrv) return
      if (control%nprtrw < 1 .or. control%nprtrw*control%nprtrv /= control%nproc) return
      if (resolution%resolution < 1 .or. resolution%truncation < 1 .or. resolution%truncation > 8191) return
      if (partition%phase /= 7 .or. partition%ngptot < 1 .or. partition%nspec2 < 1) return
      width = size(pgp, 1)
      if (width < 1 .or. width > 1024) return
      blocks = int((int(partition%ngptot, int64) + width - 1)/width)
      if (size(pgp, 2) /= field_count .or. size(pgp, 3) /= blocks) return
      if (request%nfpsca < 0 .or. request%nfpsca > s .or. request%nfpvec < 0 .or. request%nfpvec > v) return
      if (size(psca, 1) /= request%nfpsca .or. size(pvor, 1) /= request%nfpvec .or. size(pdiv, 1) /= request%nfpvec) return
      if (size(psca, 2) /= partition%nspec2 .or. size(pvor, 2) /= partition%nspec2 .or. size(pdiv, 2) /= partition%nspec2) return
   if (.not. is_contiguous(pgp) .or. .not. is_contiguous(psca) .or. .not. is_contiguous(pvor) .or. .not. is_contiguous(pdiv)) return
    end if
    call admitted_direct()
  contains
    subroutine admitted_direct()
      integer(int32) :: scalar_sets(max(1, s)), vector_sets(max(1, v)), child_status
      real(real64) :: handle
      call transform_profile_event('TRANSDIR_FP', 0_int32, handle, profile)
      child_status = derive_runtime_output_vertical_sets(request, control%nprtrv, scalar_sets(1:s), vector_sets(1:v))
      if (child_status /= 0) then
        status = child_status
        call transform_profile_event('TRANSDIR_FP', 1_int32, handle, profile)
        return
      end if
      if (count(scalar_sets(1:s) == control%mysetv) /= request%nfpsca .or. &
          count(vector_sets(1:v) == control%mysetv) /= request%nfpvec) then
        status = 2
        call transform_profile_event('TRANSDIR_FP', 1_int32, handle, profile)
        return
      end if
      child_status = 0
      if (s > 0 .and. v > 0) then
        call direct_transform_service(PSPVOR=pvor, PSPDIV=pdiv, PSPSCALAR=psca, &
                                      KPROMA=int(width, int32), KRESOL=resolution%resolution, KVSETUV=vector_sets(1:v), &
                                      KVSETSC=scalar_sets(1:s), PGP=pgp, status=child_status)
      else if (s > 0) then
        call direct_transform_service(PSPSCALAR=psca, KPROMA=int(width, int32), &
                                      KRESOL=resolution%resolution, KVSETSC=scalar_sets(1:s), PGP=pgp, status=child_status)
      else if (v > 0) then
        call direct_transform_service(PSPVOR=pvor, PSPDIV=pdiv, KPROMA=int(width, int32), &
                                      KRESOL=resolution%resolution, KVSETUV=vector_sets(1:v), PGP=pgp, status=child_status)
      end if
      call transform_profile_event('TRANSDIR_FP', 1_int32, handle, profile)
      if (child_status /= 0) then
        status = child_status
        return
      end if
      call increment_source_counter(counters%scalar_direct)
      status = 0
    end subroutine
  end subroutine
end module
