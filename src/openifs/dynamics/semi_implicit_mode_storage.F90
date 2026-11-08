!> Own the five vertical normal-mode arrays used by the pressure solve.
!! Modes separate the vertical pressure response into independent waves.
module md2asm_semi_implicit_mode_storage
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  implicit none
  private
  public :: semi_implicit_mode_state, allocate_semi_implicit_mode_storage
  public :: release_semi_implicit_mode_storage, semi_implicit_environment_supported
  type :: semi_implicit_mode_state
    real(real64), allocatable :: pressure_response(:, :), modes(:, :), inverse_modes(:, :)
    real(real64), allocatable :: eigenvalues(:), inverse_response(:, :)
  end type
contains
  !> Allocate dense arrays for levels1:255 without initializing their values.
  !! All five owners must be absent on entry. The caller retains the state.
  !! Status0 succeeds,1 refuses storage,2 refuses bounds or an existing owner.
  !! Failed allocation leaves the input state unchanged.
  subroutine allocate_semi_implicit_mode_storage(levels, state, status)
    integer, intent(in) :: levels
    type(semi_implicit_mode_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    type(semi_implicit_mode_state) :: pending
    integer :: code
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (.not. semi_implicit_environment_supported()) return
    if (allocated(state%pressure_response) .or. allocated(state%modes)) return
    if (allocated(state%inverse_modes) .or. allocated(state%eigenvalues)) return
    if (allocated(state%inverse_response)) return
    status = 1
    allocate (pending%pressure_response(levels, levels), stat=code)
    if (code /= 0) return
    allocate (pending%modes(levels, levels), stat=code)
    if (code /= 0) then
      call release_semi_implicit_mode_storage(pending)
      return
    end if
    allocate (pending%inverse_modes(levels, levels), stat=code)
    if (code /= 0) then
      call release_semi_implicit_mode_storage(pending)
      return
    end if
    allocate (pending%eigenvalues(levels), stat=code)
    if (code /= 0) then
      call release_semi_implicit_mode_storage(pending)
      return
    end if
    allocate (pending%inverse_response(levels, levels), stat=code)
    if (code /= 0) then
      call release_semi_implicit_mode_storage(pending)
      return
    end if
    call move_alloc(pending%pressure_response, state%pressure_response)
    call move_alloc(pending%modes, state%modes)
    call move_alloc(pending%inverse_modes, state%inverse_modes)
    call move_alloc(pending%eigenvalues, state%eigenvalues)
    call move_alloc(pending%inverse_response, state%inverse_response)
    status = 0
  end subroutine

  !> Release owned arrays in reverse allocation order. Repeated release is quiet.
  subroutine release_semi_implicit_mode_storage(state)
    type(semi_implicit_mode_state), intent(inout) :: state
    if (allocated(state%inverse_response)) deallocate (state%inverse_response)
    if (allocated(state%eigenvalues)) deallocate (state%eigenvalues)
    if (allocated(state%inverse_modes)) deallocate (state%inverse_modes)
    if (allocated(state%modes)) deallocate (state%modes)
    if (allocated(state%pressure_response)) deallocate (state%pressure_response)
  end subroutine

  !> Require nearest rounding and gradual underflow without changing their state.
  !! The exact subnormal product adds no floating-point exception in this mode.
  logical function semi_implicit_environment_supported() result(ok)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: normal, half, subnormal
    call ieee_get_rounding_mode(rounding)
    ok = .false.
    if (rounding /= ieee_nearest) return
    normal = tiny(1.0_real64)
    half = 0.5_real64
    subnormal = normal*half
    if (transfer(subnormal, 0_int64) /= int(z'0008000000000000', int64)) return
    ok = .true.
  end function
end module
