!> Own the source Fullpos backup and output-norm result namespaces.
module forecast_fullpos_result_types
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: native_fullpos_physics_backup, native_fullpos_grid_norms, native_fullpos_spectral_norms
  !> Source YOMPPC data have no defined value before their first backup.
 !! Only the count and active integer prefix are written by the backup entry.
  type :: native_fullpos_physics_backup
    integer(int32) :: nfpphy, mfpphy(1639)
  end type
  !> Preserve39 complete source result slots and separate display values.
 !! Values have each input field's units; COUNT is dimensionless.
  type :: native_fullpos_grid_norms
    real(real64) :: values(3, 39) = 0.0_real64, display(3, 39) = 0.0_real64
    integer(int32) :: count = 0
  end type
  type :: native_fullpos_spectral_norms
    real(real64) :: values(39) = 0.0_real64, display(39) = 0.0_real64
    integer(int32) :: count = 0
  end type
end module
