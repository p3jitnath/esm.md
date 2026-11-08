!> Complete the source setup weights from the produced trajectory controls.
module forecast_implicit_time_weights
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_operational_lagrangian_controls, only: native_lagrangian_controls
  implicit none
  private
  public :: native_implicit_time_weight_state, initialize_implicit_time_weights
  !> Own the two dimensionless semi-implicit weights at one final address.
  type :: native_implicit_time_weight_state
    real(c_double) :: rbt = 0.0_c_double, rbts2 = 0.0_c_double
    logical :: ready = .false.
  end type
contains
  !> Apply SUDYN's ordered RBT and RBTS2 calculations without a time-step copy.
 !! CONTROLS supplies the initialized dimensionless BETADT, VESL and XIDT.
 !! LR2D selects a two-dimensional model; LSLAG selects trajectory transport.
 !! LTWOTL selects a calculation using two time levels. All flags are read-only.
 !! STATE is the caller-owned output. Its two weights are dimensionless.
 !! A finite-input refusal returns 2 and preserves STATE. Success returns 0.
 !! The caller retains STATE at its final TARGET address through all consumers.
  integer(c_int) function initialize_implicit_time_weights(controls, lr2d, lslag, ltwotl, state) result(status)
    type(native_lagrangian_controls), intent(in) :: controls
    logical, intent(in) :: lr2d, lslag, ltwotl
    type(native_implicit_time_weight_state), intent(inout) :: state
    real(c_double) :: rbt, rbts2
    integer(c_int64_t) :: bits
    status = 2_c_int
    bits = transfer(controls%betadt, bits)
    if (ibits(bits, 52, 11) == 2047_c_int64_t) return
    if (lslag) then
      bits = transfer(controls%vesl, bits)
      if (ibits(bits, 52, 11) == 2047_c_int64_t) return
      if (.not. lr2d .and. ltwotl) then
        bits = transfer(controls%xidt, bits)
        if (ibits(bits, 52, 11) == 2047_c_int64_t) return
      end if
    end if
    if (lslag) then
      if (lr2d) then
        rbt = (1.0_c_double + controls%vesl)*controls%betadt
      else
        if (ltwotl) then
          rbt = (1.0_c_double + controls%vesl)*controls%betadt*(1.0_c_double + controls%xidt)
        else
          rbt = (1.0_c_double + controls%vesl)*controls%betadt
        end if
      end if
    else
      rbt = controls%betadt
    end if
    rbts2 = 0.5_c_double*rbt
    state%rbt = rbt
    state%rbts2 = rbts2
    state%ready = .true.
    status = 0_c_int
  end function
end module forecast_implicit_time_weights
