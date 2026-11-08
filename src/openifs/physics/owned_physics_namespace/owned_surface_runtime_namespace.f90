!> Define fresh surface runtime inputs in the one canonical native record.
module forecast_owned_surface_runtime_namespace
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_ptr, c_int8_t, c_intptr_t, c_null_ptr, c_loc, c_f_pointer
  use ecmwf_physics_control_fields_port, only: physics_runtime_inputs
  implicit none
  private
  public :: physics_runtime_inputs, initialize_fresh_owned_surface_runtime_inputs
contains
  !> Initialize source zero-fill before the actual runtime producer is called.
 !! The one compiler-derived scalar alignment gap is defined before numerics.
 !! No original byte offset, descriptor or post-result byte repair is used.
  integer(int32) function initialize_fresh_owned_surface_runtime_inputs(state) result(status)
    type(physics_runtime_inputs), target, intent(inout) :: state
    integer(c_intptr_t) :: first, next, gap
    integer(c_int8_t), pointer :: padding(:)
    type(c_ptr) :: address
    status = 2
    first = transfer(c_loc(state%lrough), first) + storage_size(state%lrough)/8
    next = transfer(c_loc(state%rextz0m), next); gap = next - first
    if (gap < 0 .or. gap > storage_size(state)/8) return
    if (gap > 0) then
      address = transfer(first, c_null_ptr)
      call c_f_pointer(address, padding, [int(gap)])
      padding = 0_c_int8_t
    end if
    state%lscmec = .false.; state%lvdftraj = .false.; state%lrough = .false.
    state%rextz0m = 0.0_real64; state%rextz0h = 0.0_real64
    status = 0
  end function
end module
