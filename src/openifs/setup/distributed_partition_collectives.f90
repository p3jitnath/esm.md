!> Agree source statuses through the borrowed public message context.
module forecast_distributed_partition_collectives
  use iso_c_binding, only: c_int
  use forecast_public_transform, only: native_transform_control
  use mpl_allreduce_mod, only: mpl_allreduce
  use mpl_abort_mod, only: mpl_abort
  implicit none
  private
  public :: agree_distributed_partition_status, abort_distributed_partition
contains
!> All processes in CONTROL enter in the same order.
!! LOCAL_STATUS is a nonnegative source status. CONTROL is borrowed,read-only
!! and message-ready. The source default communicator is selected by omission.
  integer(c_int) function agree_distributed_partition_status(control, local_status) result(status)
    type(native_transform_control), intent(in) :: control
    integer(c_int), intent(in) :: local_status
    integer(c_int) :: error
    if (.not. control%message_ready) then
      status = 3_c_int
      return
    end if
    status = local_status
    call mpl_allreduce(status, cdoper='MAX', ldreprod=.false., kerror=error)
    if (error /= 0) call abort_distributed_partition()
  end function
!> Use the public coordinated abort after an unrecoverable provider result.
  subroutine abort_distributed_partition()
    call mpl_abort('Native distributed partition provider failed')
    error stop 3
  end subroutine
end module forecast_distributed_partition_collectives
