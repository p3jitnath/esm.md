!> Own the readonly single-column cloud policy.
!! Both native names denote the same compile-time false logical value.
!! It is dimensionless and has no writable owner or original global state.
module forecast_cloud_microphysics_policy
  use iso_fortran_env, only: int32
  implicit none
  private
  integer(int32), parameter, public :: owned_cloud_scm_policy = 0_int32
  integer(int32), parameter, public :: lscmec_word = owned_cloud_scm_policy
  logical, parameter, public :: lscmec = .false.
end module
