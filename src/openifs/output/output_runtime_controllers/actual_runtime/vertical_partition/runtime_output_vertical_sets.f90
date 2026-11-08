!> Derive direct-transform set maps from the original classified request.
module forecast_runtime_output_vertical_sets
  use iso_fortran_env, only: int32
  use forecast_output_request_types, only: type_fprqdyn
  implicit none
  private
  public :: derive_runtime_output_vertical_sets
contains
  !> Map global scalar/vector positions to their produced vertical owners.
 !! Arrays have NFPSCAG and NFPVECG elements. Values are one-based group
 !! numbers; all bounds come from CPVPOSPR, never from weather payloads.
  integer(int32) function derive_runtime_output_vertical_sets(request, nprtrv, scalar_sets, vector_sets) result(status)
    type(type_fprqdyn), intent(in) :: request
    integer(int32), intent(in) :: nprtrv
    integer(int32), intent(inout) :: scalar_sets(:), vector_sets(:)
    integer :: field, code, level, tensor, slot, owner, global_scalars, global_vectors, pair
    status = 2
    global_scalars = request%nfpscag; global_vectors = request%nfpvecg
    if (nprtrv < 1 .or. nprtrv > 32 .or. global_scalars < 0 .or. global_scalars > 65536) return
    if (global_vectors < 0 .or. global_vectors > 32768) return
    if (size(scalar_sets) /= global_scalars .or. size(vector_sets) /= global_vectors) return
    if (.not. allocated(request%nfptrdyn) .or. .not. allocated(request%isf) .or. .not. allocated(request%iled)) return
    if (.not. allocated(request%ilev) .or. .not. allocated(request%iset) .or. .not. allocated(request%igt1)) return
    if (request%nfposdyn < 0 .or. request%nfposdyn > size(request%nfptrdyn)) return
    if (lbound(request%igt1, 2) > 1 .or. ubound(request%igt1, 2) < 1) return
    scalar_sets = 0; vector_sets = 0
    do field = 1, request%nfposdyn
      code = request%nfptrdyn(field)
      if (code < 1 .or. code > size(request%isf) .or. code > size(request%iled) .or. code > size(request%ilev)) return
      if (request%isf(code) < 1) cycle
      if (code > size(request%iset, 2) .or. code > size(request%igt1, 1)) return
      if (request%ilev(code) < 0 .or. request%ilev(code) > size(request%iset, 1)) return
      tensor = request%iled(code)
      do level = 1, request%ilev(code)
        owner = request%iset(level, code)
        if (owner < 1 .or. owner > nprtrv) return
        select case (tensor)
        case (0)
          slot = request%igt1(code, 1) + level - 1 - 2*global_vectors
          if (slot < 1 .or. slot > global_scalars) return
          if (scalar_sets(slot) /= 0 .and. scalar_sets(slot) /= owner) return
          scalar_sets(slot) = owner
        case (1, 2, 3)
          slot = request%igt1(code, 1) + level - 1
          if (slot < 1 .or. slot > global_vectors) return
          if (vector_sets(slot) /= 0 .and. vector_sets(slot) /= owner) return
          vector_sets(slot) = owner
        case (:-1)
          pair = -tensor
          if (pair < 1 .or. pair > size(request%igt1, 1)) return
          slot = request%igt1(pair, 1) + level - 1
          if (slot < 1 .or. slot > global_vectors) return
          if (vector_sets(slot) /= 0 .and. vector_sets(slot) /= owner) return
          vector_sets(slot) = owner
        case default
          return
        end select
      end do
    end do
    if (any(scalar_sets < 1) .or. any(scalar_sets > nprtrv)) return
    if (any(vector_sets < 1) .or. any(vector_sets > nprtrv)) return
    status = 0
  end function
end module forecast_runtime_output_vertical_sets
