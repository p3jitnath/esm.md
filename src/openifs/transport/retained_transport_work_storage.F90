!> Own the three work arrays retained between transport calls.
!! The selected CALL_SL calculations define the values before they are read.
!! Allocation itself does not impose initial values on private field cells.
module md2asm_transport_work_storage
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: transport_work_storage, ensure_transport_work_storage
  public :: record_completed_transport_call, release_transport_work_storage
  integer(int64), parameter :: owner_byte_limit = 64_int64*1024_int64**3
  !> Hold native owners whose last dimension is the block number.
  !! level_index uses(pitch,levels,4,blocks),vertical_weights uses
  !! (pitch,levels,vertical_planes,blocks),and coordinates uses
  !! (pitch,levels,coordinate_planes,blocks). Indices and weights have no
  !! unit; each coordinate retains its supplied unit. Contents are private
  !! work, not a declared weather output. One caller has exclusive use from
  !! preparation through the final dependent call. Parent TARGET ownership
  !! permits borrowed views, which must end before resize or release.
  type :: transport_work_storage
    integer(int32), allocatable :: level_index(:, :, :, :)
    real(real64), allocatable :: vertical_weights(:, :, :, :), coordinates(:, :, :, :)
    integer(int32) :: pitch = 0, levels = 0, blocks = 0, vertical_planes = 0, coordinate_planes = 0
    integer(int64) :: completed_calls = 0, allocations = 0, releases = 0
  end type
contains
  !> Reuse matching owners or replace all three arrays in source order.
  !! All counts are int32. Supported pitch is1:1024,levels5:256,blocks
  !! positive,vertical_planes1:256,and coordinate_planes1:64. Each complete
  !! owner is at most64GiB. The optional workspace_limit bounds their total.
  !! Matching live shapes retain their addresses and every stored bit.
  !! A changed shape releases coordinates,weights,indices,then allocates
  !! indices,weights,coordinates. No automatic zero filling is requested.
  !! Status0 succeeds;2 refuses dimensions,budget or inconsistent incoming
  !! owners before changes;1 reports allocation failure after releasing all
  !! acquired owners and returning the native record to its empty state.
  subroutine ensure_transport_work_storage(owner, pitch, levels, blocks, vertical_planes, &
                                           coordinate_planes, status, workspace_limit)
    type(transport_work_storage), intent(inout) :: owner
    integer(int32), intent(in) :: pitch, levels, blocks, vertical_planes, coordinate_planes
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: workspace_limit
    integer(int64) :: cells, index_bytes, weight_bytes, coordinate_bytes, total_bytes, budget
    integer :: allocation_status
    status = 2
    if (.not. consistent_owner(owner)) return
    if (pitch < 1 .or. pitch > 1024 .or. levels < 5 .or. levels > 256 .or. blocks < 1) return
    if (vertical_planes < 1 .or. vertical_planes > 256 .or. coordinate_planes < 1 .or. coordinate_planes > 64) return
    cells = int(pitch, int64)*int(levels, int64)*int(blocks, int64)
    index_bytes = 16_int64*cells
    weight_bytes = 8_int64*cells*int(vertical_planes, int64)
    coordinate_bytes = 8_int64*cells*int(coordinate_planes, int64)
    if (index_bytes > owner_byte_limit .or. weight_bytes > owner_byte_limit .or. coordinate_bytes > owner_byte_limit) return
    total_bytes = index_bytes + weight_bytes + coordinate_bytes
    budget = 3_int64*owner_byte_limit
    if (present(workspace_limit)) budget = workspace_limit
    if (budget < 0 .or. total_bytes > budget) return
    if (owner%completed_calls >= huge(0_int64) - 1_int64) return
    if (owner%allocations >= huge(0_int64) - 6_int64 .or. owner%releases >= huge(0_int64) - 6_int64) return
    if (allocated(owner%level_index)) then
      if (owner%pitch == pitch .and. owner%levels == levels .and. owner%blocks == blocks .and. &
          owner%vertical_planes == vertical_planes .and. owner%coordinate_planes == coordinate_planes) then
        status = 0
        return
      end if
      call free_payloads(owner)
    end if
    allocate (owner%level_index(pitch, levels, 4, blocks), stat=allocation_status)
    if (allocation_status /= 0) then
      call rollback()
      return
    end if
    owner%allocations = owner%allocations + 1_int64
    allocate (owner%vertical_weights(pitch, levels, vertical_planes, blocks), stat=allocation_status)
    if (allocation_status /= 0) then
      call rollback()
      return
    end if
    owner%allocations = owner%allocations + 1_int64
    allocate (owner%coordinates(pitch, levels, coordinate_planes, blocks), stat=allocation_status)
    if (allocation_status /= 0) then
      call rollback()
      return
    end if
    owner%allocations = owner%allocations + 1_int64
    owner%pitch = pitch
    owner%levels = levels
    owner%blocks = blocks
    owner%vertical_planes = vertical_planes
    owner%coordinate_planes = coordinate_planes
    status = 0
  contains
    subroutine rollback()
      call free_payloads(owner)
      call clear_metadata(owner)
      status = 1
    end subroutine
  end subroutine

  !> Count one normal complete dependent transport call.
  !! The caller invokes this only after the numerical parent succeeds.
  !! A failed numerical call is not a completed step or accepted weather state.
  subroutine record_completed_transport_call(owner, status)
    type(transport_work_storage), intent(inout) :: owner
    integer(int32), intent(out) :: status
    status = 2
    if (.not. consistent_owner(owner)) return
    if (.not. allocated(owner%level_index)) return
    if (owner%completed_calls == huge(0_int64)) return
    owner%completed_calls = owner%completed_calls + 1_int64
    status = 0
  end subroutine

  !> Release all complete private owners and reset the native record.
  !! Release of an empty valid record succeeds. Every borrowed child view
  !! must already have ended. Status2 rejects an inconsistent record before
  !! any release;status0 clears all owned arrays,dimensions and counters.
  subroutine release_transport_work_storage(owner, status)
    type(transport_work_storage), intent(inout) :: owner
    integer(int32), intent(out) :: status
    status = 2
    if (.not. consistent_owner(owner)) return
    call free_payloads(owner)
    call clear_metadata(owner)
    status = 0
  end subroutine

  logical function consistent_owner(owner)
    type(transport_work_storage), intent(in) :: owner
    logical :: have_indices, have_weights, have_coordinates
    integer(int64) :: cells
    consistent_owner = .false.
    if (owner%allocations < 0 .or. owner%releases < 0 .or. owner%completed_calls < 0) return
    if (owner%allocations < owner%releases) return
    have_indices = allocated(owner%level_index)
    have_weights = allocated(owner%vertical_weights)
    have_coordinates = allocated(owner%coordinates)
    if (.not. have_indices .and. .not. have_weights .and. .not. have_coordinates) then
      if (owner%pitch /= 0 .or. owner%levels /= 0 .or. owner%blocks /= 0) return
      if (owner%vertical_planes /= 0 .or. owner%coordinate_planes /= 0) return
      if (owner%allocations /= 0 .or. owner%releases /= 0 .or. owner%completed_calls /= 0) return
      consistent_owner = .true.
      return
    end if
    if (.not. have_indices .or. .not. have_weights .or. .not. have_coordinates) return
    if (owner%pitch < 1 .or. owner%pitch > 1024 .or. owner%levels < 5 .or. owner%levels > 256 .or. owner%blocks < 1) return
    if (owner%vertical_planes < 1 .or. owner%vertical_planes > 256) return
    if (owner%coordinate_planes < 1 .or. owner%coordinate_planes > 64) return
    if (any(shape(owner%level_index, kind=int64) /= &
            [int(owner%pitch, int64), int(owner%levels, int64), 4_int64, int(owner%blocks, int64)])) return
    if (any(shape(owner%vertical_weights, kind=int64) /= &
           [int(owner%pitch, int64), int(owner%levels, int64), int(owner%vertical_planes, int64), int(owner%blocks, int64)])) return
    if (any(shape(owner%coordinates, kind=int64) /= &
         [int(owner%pitch, int64), int(owner%levels, int64), int(owner%coordinate_planes, int64), int(owner%blocks, int64)])) return
    if (any(lbound(owner%level_index) /= 1) .or. any(lbound(owner%vertical_weights) /= 1) .or. &
        any(lbound(owner%coordinates) /= 1)) return
    cells = int(owner%pitch, int64)*int(owner%levels, int64)*int(owner%blocks, int64)
    if (16_int64*cells > owner_byte_limit) return
    if (8_int64*cells*int(owner%vertical_planes, int64) > owner_byte_limit) return
    if (8_int64*cells*int(owner%coordinate_planes, int64) > owner_byte_limit) return
    if (owner%allocations - owner%releases /= 3_int64) return
    consistent_owner = .true.
  end function

  subroutine free_payloads(owner)
    type(transport_work_storage), intent(inout) :: owner
    if (allocated(owner%coordinates)) then
      deallocate (owner%coordinates)
      owner%releases = owner%releases + 1_int64
    end if
    if (allocated(owner%vertical_weights)) then
      deallocate (owner%vertical_weights)
      owner%releases = owner%releases + 1_int64
    end if
    if (allocated(owner%level_index)) then
      deallocate (owner%level_index)
      owner%releases = owner%releases + 1_int64
    end if
  end subroutine

  subroutine clear_metadata(owner)
    type(transport_work_storage), intent(inout) :: owner
    owner%pitch = 0
    owner%levels = 0
    owner%blocks = 0
    owner%vertical_planes = 0
    owner%coordinate_planes = 0
    owner%completed_calls = 0
    owner%allocations = 0
    owner%releases = 0
  end subroutine
end module md2asm_transport_work_storage
