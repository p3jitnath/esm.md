!> Publish the selected source gas volume fractions on the actual TERDI owner.
module forecast_initial_radiative_gas_volumes
  use iso_fortran_env, only: int32, int64, real64
  use yoerdi, only: terdi
  implicit none
  private
  public :: initialize_initial_radiative_gas_volumes
contains
!> Require variant0 and eight positive-zero incoming volume fractions.
!! Other TERDI fields stay unchanged. Fractions are dimensionless FP64 words.
  integer(int32) function initialize_initial_radiative_gas_volumes(gases, variant) result(status)
    type(terdi), intent(inout) :: gases
    integer(int32), intent(in) :: variant
    status = 2
    if (variant /= 0) return
    if (transfer(gases%rcco2, 0_int64) /= 0_int64) return
    if (transfer(gases%rcch4, 0_int64) /= 0_int64) return
    if (transfer(gases%rcn2o, 0_int64) /= 0_int64) return
    if (transfer(gases%rcno2, 0_int64) /= 0_int64) return
    if (transfer(gases%rccfc11, 0_int64) /= 0_int64) return
    if (transfer(gases%rccfc12, 0_int64) /= 0_int64) return
    if (transfer(gases%rccfc22, 0_int64) /= 0_int64) return
    if (transfer(gases%rcccl4, 0_int64) /= 0_int64) return
    gases%rcco2 = transfer(int(z'3f37225b749adc90', int64), 0.0_real64)
    gases%rcch4 = transfer(int(z'3ebcdb57fff13c6e', int64), 0.0_real64)
    gases%rcn2o = transfer(int(z'3e94cdc26b1f07d8', int64), 0.0_real64)
    gases%rcno2 = transfer(int(z'3dcb7cdfd9d7bdbb', int64), 0.0_real64)
    gases%rccfc11 = transfer(int(z'3df33dcfe54a3803', int64), 0.0_real64)
    gases%rccfc12 = transfer(int(z'3e00a14f1c1d6744', int64), 0.0_real64)
    gases%rccfc22 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    gases%rcccl4 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    status = 0
  end function
end module
