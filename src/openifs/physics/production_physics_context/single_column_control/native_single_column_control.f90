!> Retain the original single-column flag after its real process admission.
module forecast_native_single_column_control
  use iso_fortran_env, only: int32
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  implicit none
  private
  public :: native_single_column_control, initialize_native_single_column_control
  !> One source flag at a stable caller-owned address; it owns no weather data.
  !! SCMEC_ENABLED has no value until the genuine upstream admission completes.
  type :: native_single_column_control
    logical :: scmec_enabled
    logical :: ready = .false.
  end type
contains
  !> Retain the SUMPINI default after the actual first NAMPAR0 was admitted.
  !! STARTUP is the actual complete initial geometry owner. Its ready token
  !! and partition phase7 prove that the real process setup child completed.
  !! That child reads only the original thirteen admitted NAMPAR0 keys and
  !! refuses any LSCMEC assignment. Therefore source line169 remains unchanged.
  !! No parser, source setup child or numerical stage is repeated here.
  !! OUTPUT is TARGET and must remain stationary while physics borrows it.
  !! Status0 writes the source flag and ready token; status2 leaves OUTPUT alone.
  integer(int32) function initialize_native_single_column_control(startup, output) result(status)
    type(native_forecast_startup_storage), intent(in) :: startup
    type(native_single_column_control), target, intent(inout) :: output
    status = 2_int32
    if (output%ready) return
    if (.not. allocated(startup%initial)) return
    if (.not. startup%initial%ready) return
    if (.not. allocated(startup%initial%geometry)) return
    if (startup%initial%geometry%partition%phase /= 7_int32) return
    output%scmec_enabled = .false.
    output%ready = .true.
    status = 0_int32
  end function
end module
