!> Own disabled profiling policy for the private surface context.
!! The four-byte native logical is dimensionless and read-only to callers.
!! It does not replace or change the public FIAT profiling service state.
module forecast_surface_boundary_hook_policy
  use iso_fortran_env, only: int32
  implicit none
  private
  logical(int32), protected, save, public :: surface_boundary_hooks_enabled = .false.
  integer(int32), parameter, public :: surface_boundary_hook_word = 0_int32
end module forecast_surface_boundary_hook_policy
