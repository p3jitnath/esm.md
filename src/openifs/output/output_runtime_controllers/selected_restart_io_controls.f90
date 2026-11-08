!> Own the selected restart filenames and time-marker control as named fields.
module forecast_restart_io_controls
  use iso_fortran_env, only: int32
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_restart_io_controls, initialize_selected_restart_io_controls
  type :: native_restart_io_controls
    character(120) :: cfrcf, ciosprf
    logical :: lrcftime
  end type
contains
  !> Read the first empty NAMIOS and publish source defaults for one process.
  !! A refusal leaves all output fields unchanged. Names are paths with blank padding.
  integer(int32) function initialize_selected_restart_io_controls(text, process_count, output) result(status)
    character(*), intent(in) :: text
    integer(int32), intent(in) :: process_count
    type(native_restart_io_controls), intent(inout) :: output
    status = 2
    if (process_count /= 1) return
    status = require_empty_physics_group(text, 'NAMIOS')
    if (status /= 0) return
    output%cfrcf = 'rcf'
    output%ciosprf = 'srf'
    output%lrcftime = .false.
  end function
end module forecast_restart_io_controls
