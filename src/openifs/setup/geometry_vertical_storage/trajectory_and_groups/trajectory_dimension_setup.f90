!> Native trajectory truncation scalars. Values are dimensionless wave indices.
module forecast_trajectory_dimensions
  use, intrinsic :: iso_c_binding, only: c_int
  use, intrinsic :: iso_fortran_env, only: int64
  use forecast_setup_empty_groups, only: require_empty_trajectory_dimension_group
  implicit none
  private
  public :: native_trajectory_dimensions, native_trajectory_entry_diagnostics
  public :: initialize_trajectory_dimensions, initialize_trajectory_dimensions_from_text
  public :: record_trajectory_entry, trajectory_native_entry_count
  type :: native_trajectory_dimensions
    integer(c_int) :: nsmax_traj = 0_c_int

    integer(c_int) :: nsmax_backgr00 = 0_c_int
    integer(c_int) :: nsmax_backgr01 = 0_c_int
    integer(c_int) :: nsmax_backgr02 = 0_c_int
    integer(c_int) :: nsmax_backgr03 = 0_c_int
    integer(c_int) :: nsmax_backgr04 = 0_c_int
    integer(c_int) :: nsmax_backgr05 = 0_c_int
    integer(c_int) :: nsmax_backgr06 = 0_c_int
    integer(c_int) :: nsmax_backgr07 = 0_c_int
    integer(c_int) :: nsmax_backgr08 = 0_c_int
    integer(c_int) :: nsmax_backgr09 = 0_c_int
    integer(c_int) :: nsmax_backgr10 = 0_c_int
  end type native_trajectory_dimensions
  !> Caller-owned diagnostic only; this does not construct physical state.
  type :: native_trajectory_entry_diagnostics
    integer(int64) :: successful_entries = 0_int64
  end type native_trajectory_entry_diagnostics
contains
  !> Set all twelve source scalars to WAVE_LIMIT, which must lie in 0:8191.
  !> OUTPUT changes only after admission. Status 0 succeeds; status 2 refuses.
  integer(c_int) function initialize_trajectory_dimensions(wave_limit, output) result(status)
    integer(c_int), intent(in) :: wave_limit
    type(native_trajectory_dimensions), intent(inout) :: output
    status = 2_c_int
    if (wave_limit < 0_c_int .or. wave_limit > 8191_c_int) return
    output%nsmax_traj = wave_limit

    output%nsmax_backgr00 = wave_limit
    output%nsmax_backgr01 = wave_limit
    output%nsmax_backgr02 = wave_limit
    output%nsmax_backgr03 = wave_limit
    output%nsmax_backgr04 = wave_limit
    output%nsmax_backgr05 = wave_limit
    output%nsmax_backgr06 = wave_limit
    output%nsmax_backgr07 = wave_limit
    output%nsmax_backgr08 = wave_limit
    output%nsmax_backgr09 = wave_limit
    output%nsmax_backgr10 = wave_limit
    status = 0_c_int
  end function initialize_trajectory_dimensions

  !> Validate the first trajectory group and set the caller-owned dimensions.
  !> Text is borrowed and unchanged. The optional diagnostic changes on success.
  !> This text-only route preserves incoming errno and floating-point status.
  integer(c_int) function initialize_trajectory_dimensions_from_text(wave_limit, text, output, diagnostics) result(status)
    integer(c_int), intent(in) :: wave_limit
    character(len=*), intent(in) :: text
    type(native_trajectory_dimensions), intent(inout) :: output
    type(native_trajectory_entry_diagnostics), intent(inout), optional :: diagnostics
    status = require_empty_trajectory_dimension_group(text)
    if (status /= 0_c_int) return
    status = initialize_trajectory_dimensions(wave_limit, output)
    if (status == 0_c_int .and. present(diagnostics)) call record_trajectory_entry(diagnostics)
  end function initialize_trajectory_dimensions_from_text

  !> Increment a caller-owned count, with the original 64-bit wrap rule.
  subroutine record_trajectory_entry(diagnostics)
    type(native_trajectory_entry_diagnostics), intent(inout) :: diagnostics
    if (diagnostics%successful_entries == huge(0_int64)) then
      diagnostics%successful_entries = -huge(0_int64) - 1_int64
    else
      diagnostics%successful_entries = diagnostics%successful_entries + 1_int64
    end if
  end subroutine record_trajectory_entry

  !> Return the diagnostic count as its native signed 64-bit word.
  integer(int64) function trajectory_native_entry_count(diagnostics) result(count)
    type(native_trajectory_entry_diagnostics), intent(in) :: diagnostics
    count = diagnostics%successful_entries
  end function trajectory_native_entry_count
end module forecast_trajectory_dimensions
