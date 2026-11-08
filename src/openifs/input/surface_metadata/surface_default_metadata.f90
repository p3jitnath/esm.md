module surface_default_metadata_port
  !! Collect defaults from named metadata and complete borrowed field owners.
  !! The caller supplies the33 source groups in their fixed registration order.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use surface_field_registration_port, only: surface_group_metadata, surface_field_metadata
  use surface_default_assignment_port, only: surface_default_owner, surface_default_assignment
  implicit none
  private
  public :: surface_default_group_view, surface_default_plan_summary
  public :: collect_surface_default_metadata, collect_runtime_partitioned_surface_defaults
  type :: surface_default_group_view
    type(surface_group_metadata) :: metadata
    logical :: layered = .false.
    type(surface_default_owner) :: owner
    type(surface_field_metadata), pointer, contiguous :: fields(:) => null()
  end type
  type :: surface_default_plan_summary
    integer(int64) :: status = 0, owner_count = 0, assignment_count = 0, rows = 0, blocks = 0, owner_bytes = 0
    integer(int64) :: reserved(2) = 0
  end type
contains
  subroutine collect_surface_default_metadata(groups, owners, assignments, summary)
    !! The selected small collector uses24 rows and86 blocks. Outputs have
    !!64 owner slots and4096 ordered assignments; unused slots become empty.
    !! Metadata and all physical arrays remain readonly. The output plan
    !! borrows its owners,so those arrays must outlive the final default writes.
    type(surface_default_group_view), intent(in) :: groups(:)
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(inout) :: assignments(:)
    type(surface_default_plan_summary), intent(inout) :: summary
    call collect_runtime_partitioned_surface_defaults(groups, 24_int32, 86_int32, owners, assignments, summary)
  end subroutine
  subroutine collect_runtime_partitioned_surface_defaults(groups, rows, blocks, owners, assignments, summary)
    !! Source group order is SP_SB,SP_SG,SP_SL,SP_RR,SP_CL,SP_OM,SP_EP,SP_X2,
    !! SD_VF,SD_VP,SD_VV,SD_VN,SD_VH,SD_VK,SD_VA,SD_VC,SD_V2,SD_V3,SD_OC,
    !! SD_VD,SD_SM,SD_WS,SD_WW,SD_VX,SD_XA,SD_XR,SD_DI,SD_X2,SD_SFL,SD_SFO,
    !! SD_PF,SD_XP,SD_XP2. SP_CI is absent from this source default traversal.
    !! rows is1..1024,blocks positive. Each active owner has exact shape
    !!(rows,stored_fields*layers,blocks),with1..4096planes. Scalar groups use
    !! one layer. Every group field is inspected in registration order; layered
    !! defaults use increasing layer order. A source_flag of-1 selects a copy.
    !! No physical or floating-point calculation occurs. Clear the complete
    !! private plan first; summary%status remains1 on any malformed metadata,
    !! and becomes0 only after every group passes. Partial private plan rows
    !! on refusal are unaccepted. Published physical fields never change here.
    type(surface_default_group_view), intent(in) :: groups(:)
    integer(int32), intent(in) :: rows, blocks
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(inout) :: assignments(:)
    type(surface_default_plan_summary), intent(inout) :: summary
    integer :: g, j, layer, n, levels, plane, owner_count, assignment_count
    integer(int64) :: planes, total_bytes
    summary = surface_default_plan_summary()
    summary%status = 1
    if (size(owners) < 64 .or. size(assignments) < 4096) return
    do j = 1, size(owners)
      nullify (owners(j)%values)
    end do
    assignments = surface_default_assignment()
    if (size(groups) /= 33 .or. rows < 1 .or. rows > 1024 .or. blocks < 1) return
    owner_count = 0; assignment_count = 0; total_bytes = 0
    do g = 1, 33
      n = groups(g)%metadata%stored_fields
      if (n <= 0) cycle
      if (n > 4096) return
      if (groups(g)%metadata%registered_fields < 0) return
      levels = 1
      if (groups(g)%layered) then
        levels = groups(g)%metadata%layers
        if (levels < 1) return
      end if
      planes = int(n, int64)*levels
      if (planes > 4096) return
      if (.not. associated(groups(g)%owner%values)) return
      if (any(shape(groups(g)%owner%values) /= [rows, int(planes), blocks])) return
      if (.not. associated(groups(g)%fields)) return
      if (lbound(groups(g)%fields, 1) /= 1) return
      if (size(groups(g)%fields) < groups(g)%metadata%registered_fields) return
      owner_count = owner_count + 1
      owners(owner_count)%values => groups(g)%owner%values
      total_bytes = total_bytes + int(rows, int64)*blocks*planes*8_int64
      do j = 1, groups(g)%metadata%registered_fields
        if (groups(g)%layered) then
          if (.not. allocated(groups(g)%fields(j)%layer_source_flags)) return
          if (lbound(groups(g)%fields(j)%layer_source_flags, 1) > 1) return
          if (ubound(groups(g)%fields(j)%layer_source_flags, 1) < levels) return
          do layer = 1, levels
            if (groups(g)%fields(j)%layer_source_flags(layer) /= -1) cycle
            if (.not. allocated(groups(g)%fields(j)%layer_defaults)) return
            if (lbound(groups(g)%fields(j)%layer_defaults, 1) > layer) return
            if (ubound(groups(g)%fields(j)%layer_defaults, 1) < layer) return
            plane = groups(g)%fields(j)%indices(1)
            if (plane < 1 .or. plane > n) return
            plane = (plane - 1)*levels + layer
            if (assignment_count >= 4096) return
            assignment_count = assignment_count + 1
            assignments(assignment_count)%owner_index = owner_count
            assignments(assignment_count)%plane_index = plane
            assignments(assignment_count)%value_bits = transfer(groups(g)%fields(j)%layer_defaults(layer), 0_int64)
          end do
        else
          if (groups(g)%fields(j)%source_flag /= -1) cycle
          plane = groups(g)%fields(j)%indices(1)
          if (plane < 1 .or. plane > n) return
          if (assignment_count >= 4096) return
          assignment_count = assignment_count + 1
          assignments(assignment_count)%owner_index = owner_count
          assignments(assignment_count)%plane_index = plane
          assignments(assignment_count)%value_bits = transfer(groups(g)%fields(j)%default_value, 0_int64)
        end if
      end do
    end do
    summary%status = 0
    summary%owner_count = owner_count
    summary%assignment_count = assignment_count
    summary%rows = rows
    summary%blocks = blocks
    summary%owner_bytes = total_bytes
  end subroutine
end module
