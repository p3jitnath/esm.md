module surface_default_assignment_port
  !! Copy source default bit patterns to complete native field planes.
  !! This leaf chooses no physical default; the metadata producer supplies it.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: surface_default_owner, surface_default_assignment
  public :: set_initial_surface_defaults, set_runtime_partitioned_initial_surface_defaults
  type :: surface_default_owner
    real(real64), pointer, contiguous :: values(:, :, :) => null()
  end type
  type :: surface_default_assignment
    integer(int64) :: owner_index = 0, plane_index = 0, value_bits = 0
  end type
contains
  integer(int32) function set_initial_surface_defaults(owners, assignments) result(status)
    !! The selected small entry has24 rows and86 blocks. owners contains
    !!1..64 disjoint caller-owned views(24,planes,86), each with1..4096planes.
    !! assignments has0..4096 ordered entries with one-based owner/plane
    !! indices and a complete FP64 bit pattern. Copy all rows, including
    !! unused physical padding. Empty assignments succeed without an owner.
    !! Return1 before mutation for an invalid plan; success returns0.
    !! Every FP64 value bit,IEEE state anderrno is retained by integer copies.
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(in) :: assignments(:)
    status = 0
    if (size(assignments) == 0) return
    status = validate_assignments(owners, assignments, 24_int32, 86_int32)
    if (status /= 0) return
    call copy_assignments(owners, assignments, 24_int32, 86_int32)
  end function
  integer(int32) function set_runtime_partitioned_initial_surface_defaults( &
    owners, assignments, rows, blocks, reset_word) result(status)
    !! Runtime entry: rows1..1024,positive blocks; every complete borrowed
    !! view is(rows,planes,blocks). Plan dimensions and all indices pass
    !! before reset_word becomes0 or any field changes. Even an empty plan
    !! resets that caller-owned int32 once dimensions pass. Views, plan and
    !! reset_word are disjoint. No numerical calculation or allocation occurs.
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(in) :: assignments(:)
    integer(int32), intent(in) :: rows, blocks
    integer(int32), intent(inout) :: reset_word
    status = 1
    if (rows < 1 .or. rows > 1024 .or. blocks < 1) return
    if (size(assignments) > 0) then
      status = validate_assignments(owners, assignments, rows, blocks)
      if (status /= 0) return
    end if
    reset_word = 0
    if (size(assignments) > 0) call copy_assignments(owners, assignments, rows, blocks)
    status = 0
  end function
  integer(int32) function validate_assignments(owners, assignments, rows, blocks) result(status)
    type(surface_default_owner), intent(in) :: owners(:)
    type(surface_default_assignment), intent(in) :: assignments(:)
    integer(int32), intent(in) :: rows, blocks
    integer :: j
    integer(int64) :: owner, plane
    status = 1
    if (size(assignments) > 4096 .or. size(owners) < 1 .or. size(owners) > 64) return
    do j = 1, size(owners)
      if (.not. associated(owners(j)%values)) return
      if (size(owners(j)%values, 1) /= rows .or. size(owners(j)%values, 3) /= blocks) return
      if (size(owners(j)%values, 2) < 1 .or. size(owners(j)%values, 2) > 4096) return
    end do
    do j = 1, size(assignments)
      owner = assignments(j)%owner_index
      if (owner < 1 .or. owner > size(owners)) return
      plane = assignments(j)%plane_index
      if (plane < 1 .or. plane > size(owners(owner)%values, 2)) return
    end do
    status = 0
  end function
  subroutine copy_assignments(owners, assignments, rows, blocks)
    type(surface_default_owner), intent(inout) :: owners(:)
    type(surface_default_assignment), intent(in) :: assignments(:)
    integer(int32), intent(in) :: rows, blocks
    integer :: j, row, block, owner, plane
    real(real64) :: value
    do j = 1, size(assignments)
      owner = int(assignments(j)%owner_index)
      plane = int(assignments(j)%plane_index)
      value = transfer(assignments(j)%value_bits, 0.0_real64)
      do block = 1, blocks
        do row = 1, rows
          owners(owner)%values(row, plane, block) = value
        end do
      end do
    end do
  end subroutine
end module
