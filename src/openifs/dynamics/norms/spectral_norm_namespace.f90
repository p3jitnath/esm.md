!> Retain the three source norm values in one native process owner.
module forecast_spectral_norm_namespace
  use iso_fortran_env, only: real64
  implicit none
  private
  public :: spectral_norm_persistent_state, owned_spectral_norm_state
  !> A norm has the units of its field. Only AVNRMDIV is updated by SPNORM.
  !! Positive-zero initialization is the source fresh-process storage preimage.
  !! Keep this same owner through initial and later norm calls and reports.
  type :: spectral_norm_persistent_state
    real(real64) :: avnrmdiv = 0.0_real64, avnrmpd = 0.0_real64, avnrmvd = 0.0_real64
  end type
  type(spectral_norm_persistent_state), save, target :: owned_spectral_norm_state
end module forecast_spectral_norm_namespace
