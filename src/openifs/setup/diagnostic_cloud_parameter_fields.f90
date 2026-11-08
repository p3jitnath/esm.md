!> Set native diagnostic-cloud parameters and copy the live eta levels.
module diagnostic_cloud_parameter_fields_mod
  use iso_fortran_env, only: real64, int64
  use yoecld, only: tecld
  implicit none
  private
  public :: initialize_diagnostic_cloud_fields
contains
  !> Set SUCLD fields after the owner allocates CETA for all active levels.
  !! OUTPUT is a caller-owned native TECLD record with an allocated CETA.
  !! ETA is a readonly dimensionless level vector. The caller admits the
  !! complete shape, separate owners and values between zero and one.
  !! All 24 scalar coefficients retain their generated source bit patterns.
  !! CETA and assigned members change in place. Padding remains incoming.
  !! This raw numerical child allocates nothing and retains no input view.
  subroutine initialize_diagnostic_cloud_fields(output, eta)
    type(tecld), intent(inout) :: output
    real(real64), intent(in) :: eta(:)
    integer :: level
    output%ranva = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%ranvb = transfer(int(z'3fd3333333333333', int64), 0.0_real64)
    output%ranvh = transfer(int(z'3fd999999999999a', int64), 0.0_real64)
    output%rcca = transfer(int(z'3fc0000000000000', int64), 0.0_real64)
    output%rccb = transfer(int(z'3ff8000000000000', int64), 0.0_real64)
    output%rccc = transfer(int(z'3fe999999999999a', int64), 0.0_real64)
    output%rcfct = transfer(int(z'3fd999999999999a', int64), 0.0_real64)
    output%rclwmr = transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64)
    output%rcscal = transfer(int(z'42374876e8000000', int64), 0.0_real64)
    output%rdecorr_cf = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%rdecorr_cw = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%retahb = transfer(int(z'3fdccccccccccccd', int64), 0.0_real64)
    output%retamb = transfer(int(z'3fe999999999999a', int64), 0.0_real64)
    output%rloia = transfer(int(z'4059000000000000', int64), 0.0_real64)
    output%rloib = transfer(int(z'c024000000000000', int64), 0.0_real64)
    output%rloic = transfer(int(z'bfeccccccccccccd', int64), 0.0_real64)
    output%rloid = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%rlonia = transfer(int(z'bfb999999999999a', int64), 0.0_real64)
    output%rlonib = transfer(int(z'c024000000000000', int64), 0.0_real64)
    output%rrhh = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    output%rrhl = transfer(int(z'3fe6666666666666', int64), 0.0_real64)
    output%rgammas = transfer(int(z'3fa999999999999a', int64), 0.0_real64)
    output%repscr = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    output%repsec = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    output%lomega = .true.
    do level = 1, size(eta)
      output%ceta(level) = eta(level)
    end do
  end subroutine
end module
