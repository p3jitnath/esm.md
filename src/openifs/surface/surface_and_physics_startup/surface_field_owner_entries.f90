!> Reuse the canonical thirty-four-array surface allocator and lifetime.
module forecast_surface_field_owner_entries
  use iso_fortran_env, only: int32
  use surface_field_storage_port, only: surface_field_state, surface_field_layout, &
                      allocate_surface_field_owners, allocate_runtime_distributed_surface_field_owners, release_surface_field_owners
  implicit none
  private
  public :: allocate_selected_surface_field_storage, allocate_operational_surface_field_storage
  public :: release_surface_field_storage
contains
  !> Selected source bounds are rows1:64,blocks1:128,fields0:512 and
  !! layered levels0:64. Each owner is at most64MiB. LAYOUT is read-only;
  !! STATE owns the actual canonical arrays, initially all absent.
  integer(int32) function allocate_selected_surface_field_storage(state, rows, blocks, layout) result(status)
    type(surface_field_state), intent(inout) :: state
    integer(int32), intent(in) :: rows, blocks
    type(surface_field_layout), intent(in) :: layout
    status = allocate_surface_field_owners(rows, blocks, layout, state)
  end function
  !> The retained whole operational specialization is P17,B388217,L137.
  !! Its canonical live allocator preserves the same thirty-four allocation
  !! order, empty owners and four complete source zero assignments.
  integer(int32) function allocate_operational_surface_field_storage(state, rows, blocks) result(status)
    type(surface_field_state), intent(inout) :: state
    integer(int32), intent(in) :: rows, blocks
    status = 2
    if (rows /= 17 .or. blocks /= 388217) return
    status = allocate_runtime_distributed_surface_field_owners(rows, blocks, 137_int32, state)
  end function
  integer(int32) function release_surface_field_storage(state) result(status)
    type(surface_field_state), intent(inout) :: state
    status = release_surface_field_owners(state)
  end function
end module
