!> Canonical named request records and caller-owned service observations.
!! Request arrays use one-based bounds except IGT1's second axis, which is 0:2.
!! Canonical OpenIFS modules supply data declarations only; no method or global is used.
module forecast_output_request_types
  use iso_fortran_env, only: int32, int64, real64
  use type_fprqdyns, only: type_fprqdyn
  use type_fpfields, only: tfpfields
  use yomfp4l, only: trqfp
  use yom4fpos, only: trq3fp, trq2fp, trqfpdyn
  use type_fposbuf, only: fposbuf
  implicit none
  private
  public :: type_fprqdyn, tfpfields, trqfp, trq3fp, trq2fp, trqfpdyn, fposbuf
  public :: native_output_request_input, native_output_service_counters, increment_output_counter
  type :: native_output_request_input
    integer(int32) :: field_count(9) = 0
    integer(int32) :: field_code(64, 9) = -1
    integer(int32) :: nrfp3s(64) = -1
    real(real64) :: rfp3p(64) = -1.0_real64, rfp3h(64) = -1.0_real64
    real(real64) :: rfp3th(64) = -1.0_real64, rfp3pv(64) = 100000.0_real64
    real(real64) :: rfp3i(64) = -1000.0_real64, rfp3f(64) = -1.0_real64
  end type
  type :: native_output_service_counters
    integer(int64) :: request_allocation(0:1) = 0, request_release(0:1) = 0
    integer(int64) :: io_request(0:1) = 0, scan(0:1) = 0
    integer(int64) :: empty_physical = 0, auxiliary = 0, header = 0, preparation = 0
    integer(int64) :: spectral_fit = 0, spectral_log = 0
  end type
contains
  !> Increase a binary 64-bit observation without signed integer overflow.
  subroutine increment_output_counter(value)
    integer(int64), intent(inout) :: value
    if (value == huge(value)) then
      value = -huge(value) - 1_int64
    else
      value = value + 1_int64
    end if
  end subroutine
end module forecast_output_request_types
