!> Assign native field positions for the selected semi-implicit diagnostics.
!! A tendency is a field's change with time. Positions and counts have no unit.
module md2asm_semi_implicit_tendency_layout
  use iso_fortran_env, only: int32
  implicit none
  private
  public :: semi_implicit_tendency_positions, initialize_semi_implicit_tendency_layout
  type :: semi_implicit_tendency_positions
    integer(int32) :: ndimsigmv = 0
    integer(int32) :: msiddh_u1 = 0, msiddh_v1 = 0, msiddh_t1 = 0, msiddh_pd1 = 0, msiddh_vd1 = 0
    integer(int32) :: msiddh_u0 = 0, msiddh_v0 = 0, msiddh_t0 = 0, msiddh_pd0 = 0, msiddh_vd0 = 0
    integer(int32) :: msiddh_u9 = 0, msiddh_v9 = 0, msiddh_t9 = 0, msiddh_pd9 = 0, msiddh_vd9 = 0
  end type
contains
  !> Derive the original three source-group layouts from NFTHER and LNHDYN.
  !! thermal_fields must be nonnegative; nonhydrostatic is the native logical.
  !! layout is caller-owned. Negative thermal_fields returns2 without mutation.
  !! Success returns0 and writes every named integer. No allocation or
  !! floating-point calculation occurs, and unrelated diagnostic stages remain
  !! outside this complete selected SUNDDH cursor block.
  subroutine initialize_semi_implicit_tendency_layout(thermal_fields, nonhydrostatic, layout, status)
    integer(int32), intent(in) :: thermal_fields
    logical, intent(in) :: nonhydrostatic
    type(semi_implicit_tendency_positions), intent(inout) :: layout
    integer(int32), intent(out) :: status
    type(semi_implicit_tendency_positions) :: pending
    integer(int32) :: cursor
    status = 2
    if (thermal_fields < 0) return
    cursor = 1
    call assign_group(pending%msiddh_u1, pending%msiddh_v1, pending%msiddh_t1, pending%msiddh_pd1, pending%msiddh_vd1)
    call assign_group(pending%msiddh_u0, pending%msiddh_v0, pending%msiddh_t0, pending%msiddh_pd0, pending%msiddh_vd0)
    call assign_group(pending%msiddh_u9, pending%msiddh_v9, pending%msiddh_t9, pending%msiddh_pd9, pending%msiddh_vd9)
    pending%ndimsigmv = cursor - 1
    layout = pending
    status = 0
  contains
    subroutine assign_group(u, v, t, pd, vd)
      integer(int32), intent(out) :: u, v, t, pd, vd
      u = cursor; cursor = cursor + 1
      v = cursor; cursor = cursor + 1
      t = 0; pd = 0; vd = 0
      if (thermal_fields > 0) then
        t = cursor; cursor = cursor + 1
        if (nonhydrostatic) then
          pd = cursor; cursor = cursor + 1
          vd = cursor; cursor = cursor + 1
        end if
      end if
    end subroutine
  end subroutine
end module
