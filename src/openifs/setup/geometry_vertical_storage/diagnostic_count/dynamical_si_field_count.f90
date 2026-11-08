!> Produce the source SI diagnostic field count from actual model metadata.
!!
!! SUNDDH numbers three groups at time t+dt, t and t-dt, including while
!! dynamical diagnostics are disabled. The result belongs to the caller.
module forecast_dynamical_si_field_count
  use, intrinsic :: iso_c_binding, only: c_int32_t
  implicit none
  private
  public :: initialize_dynamical_si_field_count
contains
  !> Establish the dimensionless NDIMSIGMV count using source integer order.
  !!
  !! NFTHER is the actual nonnegative thermal-field count from TDIMF.
  !! LNHDYN is the actual canonical logical from the dynamical configuration.
  !! NDIMSIGMV is a caller-owned integer32 result, preserved on refusal.
  !! Status zero commits the result; status two rejects negative NFTHER or
  !! a noncanonical logical word. No array, global or floating state is used.
  integer(c_int32_t) function initialize_dynamical_si_field_count(nfther, lnhdyn, ndimsigmv) result(status)
    integer(c_int32_t), intent(in) :: nfther
    logical, intent(in) :: lnhdyn
    integer(c_int32_t), intent(inout) :: ndimsigmv
    integer(c_int32_t) :: next_field, logical_word

    status = 2_c_int32_t
    if (nfther < 0_c_int32_t) return
    logical_word = transfer(lnhdyn, 0_c_int32_t)
    if (logical_word /= 0_c_int32_t .and. logical_word /= 1_c_int32_t) return

    ! Source SUNDDH852:866: U1, V1, then optional T1, PD1 and VD1.
    next_field = 1_c_int32_t
    next_field = next_field + 1_c_int32_t
    next_field = next_field + 1_c_int32_t
    if (nfther > 0_c_int32_t) then
      next_field = next_field + 1_c_int32_t
      if (lnhdyn) then
        next_field = next_field + 1_c_int32_t
        next_field = next_field + 1_c_int32_t
      end if
    end if

    ! Source SUNDDH867:880: U0, V0, then optional T0, PD0 and VD0.
    next_field = next_field + 1_c_int32_t
    next_field = next_field + 1_c_int32_t
    if (nfther > 0_c_int32_t) then
      next_field = next_field + 1_c_int32_t
      if (lnhdyn) then
        next_field = next_field + 1_c_int32_t
        next_field = next_field + 1_c_int32_t
      end if
    end if

    ! Source SUNDDH881:896: U9, V9, then optional T9, PD9 and VD9.
    next_field = next_field + 1_c_int32_t
    next_field = next_field + 1_c_int32_t
    if (nfther > 0_c_int32_t) then
      next_field = next_field + 1_c_int32_t
      if (lnhdyn) then
        next_field = next_field + 1_c_int32_t
        next_field = next_field + 1_c_int32_t
      end if
    end if
    ndimsigmv = next_field - 1_c_int32_t
    status = 0_c_int32_t
  end function initialize_dynamical_si_field_count
end module forecast_dynamical_si_field_count
