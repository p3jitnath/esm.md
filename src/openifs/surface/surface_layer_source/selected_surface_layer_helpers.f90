!> Borrow native surface columns and profiles without constructing a raw ABI.
!! All views retain their source strides. The caller keeps each TARGET owner
!! alive and follows its numerical input/output intent. No payload is copied.
!! Status0 succeeds and2 refuses metadata; only returned pointer metadata changes.
module forecast_selected_surface_layer_helpers
  use iso_fortran_env, only: int32, int64, real64
  use forecast_surface_catalog_lookup, only: surface_catalog_index
  use forecast_physics_layer_first_address, only: first_array_address
  use iso_c_binding, only: c_char, c_int, c_double, c_size_t
  implicit none
  private
  public :: borrow_surface_column, borrow_surface_plane, borrow_surface_column3
  public :: surface_vector_admitted, surface_matrix_admitted, surface_tensor_admitted
  public :: surface_vector_bounds_admitted, surface_profile_admitted, surface_catalog_index, first_array_address
  public :: surface_hook, borrow_inactive_surface_column
  interface surface_vector_admitted
    module procedure real_vector_admitted, integer_vector_admitted, logical_vector_admitted
  end interface
  interface
    subroutine public_surface_hook(name, phase, handle, length) bind(c, name="__yomhook_MOD_dr_hook_default8")
      import c_char, c_int, c_double, c_size_t
      character(c_char), intent(in) :: name(*)
      integer(c_int), intent(in) :: phase
      real(c_double), intent(inout) :: handle
      integer(c_size_t), value :: length
    end subroutine
  end interface
contains
  !> Call the public profiling service only when its actual caller flag is true.
 !! NAME contains bytes, PHASE is the source entry/exit selector, and HANDLE
 !! is the caller-owned dimensionless public profiling token.
  subroutine surface_hook(enabled, name, phase, handle)
    logical, intent(in) :: enabled
    character(len=*), intent(in) :: name
    integer(int32), intent(in) :: phase
    real(real64), intent(inout) :: handle
    if (.not. enabled) return
    call public_surface_hook(name, phase, handle, int(len(name), c_size_t))
  end subroutine
  subroutine borrow_surface_column(source, index, view, status)
    real(real64), target, intent(inout) :: source(:, :)
    integer(int32), intent(in) :: index
    real(real64), pointer, intent(out) :: view(:)
    integer(int32), intent(out) :: status
    nullify (view); status = 2_int32
    if (index < 1 .or. index > size(source, 2)) return
    view => source(:, index); status = 0_int32
  end subroutine
  subroutine borrow_surface_plane(source, index, view, status)
    real(real64), target, intent(inout) :: source(:, :, :)
    integer(int32), intent(in) :: index
    real(real64), pointer, intent(out) :: view(:, :)
    integer(int32), intent(out) :: status
    nullify (view); status = 2_int32
    if (index < 1 .or. index > size(source, 3)) return
    view => source(:, :, index); status = 0_int32
  end subroutine
  subroutine borrow_surface_column3(source, second, third, view, status)
    real(real64), target, intent(inout) :: source(:, :, :)
    integer(int32), intent(in) :: second, third
    real(real64), pointer, intent(out) :: view(:)
    integer(int32), intent(out) :: status
    nullify (view); status = 2_int32
    if (second < 1 .or. second > size(source, 2) .or. third < 1 .or. third > size(source, 3)) return
    view => source(:, second, third); status = 0_int32
  end subroutine
  subroutine borrow_inactive_surface_column(source, index, view, consumed, status)
    real(real64), target, intent(inout) :: source(:, :)
    integer(int32), intent(in) :: index
    real(real64), pointer, intent(out) :: view(:)
    logical, intent(out) :: consumed
    integer(int32), intent(out) :: status
    nullify (view); consumed = .true.; status = 2_int32
    if (index == -99999_int32 .or. index == -999999_int32) then
      if (.not. is_contiguous(source)) return
      if (index == -99999_int32 .and. size(source, 2) /= 1) return
      if (index == -999999_int32 .and. size(source, 2) /= 3) return
      consumed = .false.
      ! The named inactive selector is retained by the caller. Its empty view
      ! carries no consumed payload and forms no pointer outside the actual owner.
      view => source(1:0, 1); status = 0_int32
      return
    end if
    call borrow_surface_column(source, index, view, status)
  end subroutine
  logical function real_vector_admitted(source, rows) result(ok)
    real(real64), intent(in) :: source(:)
    integer(int32), intent(in) :: rows
    ok = rows >= 0
    if (.not. ok) return
    ok = is_contiguous(source) .and. size(source, kind=int64) >= int(rows, int64)
  end function
  logical function integer_vector_admitted(source, rows) result(ok)
    integer(int32), intent(in) :: source(:)
    integer(int32), intent(in) :: rows
    ok = rows >= 0
    if (.not. ok) return
    ok = is_contiguous(source) .and. size(source, kind=int64) >= int(rows, int64)
  end function
  logical function logical_vector_admitted(source, rows) result(ok)
    logical, intent(in) :: source(:)
    integer(int32), intent(in) :: rows
    ok = rows >= 0
    if (.not. ok) return
    ok = is_contiguous(source) .and. size(source, kind=int64) >= int(rows, int64)
  end function
  logical function surface_vector_bounds_admitted(source, rows) result(ok)
    real(real64), intent(in) :: source(:)
    integer(int32), intent(in) :: rows
    ok = rows >= 0
    if (.not. ok) return
    ok = size(source, kind=int64) >= int(rows, int64)
  end function
  logical function surface_matrix_admitted(source, rows, columns) result(ok)
    real(real64), intent(in) :: source(:, :)
    integer(int32), intent(in) :: rows, columns
    ok = .false.
    if (rows < 0 .or. columns < 0) return
    ok = is_contiguous(source) .and. size(source, 1) == rows .and. size(source, 2) >= columns
  end function
  logical function surface_tensor_admitted(source, rows, columns, planes) result(ok)
    real(real64), intent(in) :: source(:, :, :)
    integer(int32), intent(in) :: rows, columns, planes
    ok = .false.
    if (min(rows, columns, planes) < 0) return
    if (min(rows, columns, planes) == 0) then
      ok = .true.; return
    end if
    ok = is_contiguous(source) .and. size(source, 1) == rows .and. size(source, 2) == columns .and. size(source, 3) >= planes
  end function
  logical function surface_profile_admitted(source, rows, levels) result(ok)
    real(real64), intent(in) :: source(:, :)
    integer(int32), intent(in) :: rows, levels
    ok = rows >= 0 .and. levels >= 0
    if (.not. ok) return
    ok = size(source, 1) >= rows .and. size(source, 2) >= levels
  end function
end module forecast_selected_surface_layer_helpers
