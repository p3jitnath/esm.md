!> Bound owned mode storage and its complete setup by a caller-supplied budget.
!! This runtime entry uses live vertical dimensions and the public matrix route.
module md2asm_runtime_semi_implicit_modes
  use iso_fortran_env, only: int32, int64
  use md2asm_semi_implicit_mode_storage, only: semi_implicit_mode_state, &
                                               allocate_semi_implicit_mode_storage, release_semi_implicit_mode_storage
  use md2asm_semi_implicit_mode_setup, only: semi_implicit_mode_controls, initialize_operational_semi_implicit_modes
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use md2asm_vertical_operators, only: vertical_operator_matrices
  implicit none
  private
  public :: allocate_runtime_semi_implicit_modes, initialize_runtime_semi_implicit_modes
  public :: release_runtime_semi_implicit_modes
contains
  !> Allocate five owned arrays within heap_budget bytes, bounded above by64GiB.
  !! No numerical values are supplied by the caller or initialized here.
  subroutine allocate_runtime_semi_implicit_modes(levels, heap_budget, state, status)
    integer, intent(in) :: levels
    integer(int64), intent(in) :: heap_budget
    type(semi_implicit_mode_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    integer(int64) :: n, required
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (heap_budget < 0_int64 .or. heap_budget > 2_int64**36) return
    n = int(levels, int64)
    required = 32_int64*n*n + 8_int64*n
    if (required > heap_budget) return
    call allocate_semi_implicit_mode_storage(levels, state, status)
  end subroutine

  !> Initialize the public-matrix route within the retained temporary bound.
  !! All owner dimensions derive from state%eigenvalues. vertical_chunk is
  !! actual NPROMA. This is setup only; distributed spectral solve follows later.
  !! The retained bound64*n*n+136*n+128 bytes also covers this native work.
  subroutine initialize_runtime_semi_implicit_modes(control, coef, tables, vertical_chunk, heap_budget, state, status)
    type(semi_implicit_mode_controls), intent(in) :: control
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: vertical_chunk
    integer(int64), intent(in) :: heap_budget
    type(semi_implicit_mode_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    integer(int64) :: n, required
    status = 2
    if (heap_budget < 0_int64 .or. heap_budget > 2_int64**36) return
    if (.not. allocated(state%eigenvalues)) return
    n = int(size(state%eigenvalues), int64)
    if (n < 1_int64 .or. n > 255_int64) return
    required = 64_int64*n*n + 136_int64*n + 128_int64
    if (required > heap_budget) return
    call initialize_operational_semi_implicit_modes(control, coef, tables, state, vertical_chunk, status)
  end subroutine

  !> Release the owned mode arrays. The operation is safe to repeat.
  subroutine release_runtime_semi_implicit_modes(state)
    type(semi_implicit_mode_state), intent(inout) :: state
    call release_semi_implicit_mode_storage(state)
  end subroutine
end module
