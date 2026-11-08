!> Produce the exact compiler-branch scalar-machine flags from SUMPINI.
module forecast_scalar_machine_controls
  use iso_fortran_env, only: int32
  use forecast_distributed_process_controls, only: native_process_control, read_distributed_process_controls
  implicit none
  private
  public :: native_scalar_machine_controls, initialize_native_scalar_machine_controls
  type :: native_scalar_machine_controls
    logical :: lopt_scalar, lopt_rs6k, lvecadin
  end type
contains
  !> Publish source machine controls at the caller's final TARGET.
 !! The first actual NAMPAR0 is read by the existing13-key producer. Its
 !! admitted keys exclude LOPT_SCALAR/LOPT_RS6K, so successful parsing proves
 !! that these source defaults were not overridden. Other modes refuse.
 !! EXPECTED_WORLD only validates the real process input; it does not select
 !! a machine flag. No process namespace or ready flag is copied or invented.
  integer(int32) function initialize_native_scalar_machine_controls(text, expected_world, output) result(status)
    character(*), intent(in) :: text
    integer(int32), intent(in) :: expected_world
    type(native_scalar_machine_controls), target, intent(inout) :: output
    type(native_scalar_machine_controls) :: pending
    type(native_process_control) :: admitted
#ifdef RS6K
    pending%lopt_scalar = .true.; pending%lopt_rs6k = .true.
#elif _CRAYFTN
    pending%lopt_scalar = .true.; pending%lopt_rs6k = .false.
#elif __INTEL_COMPILER
    pending%lopt_scalar = .true.; pending%lopt_rs6k = .false.
#elif __GFORTRAN__
    pending%lopt_scalar = .true.; pending%lopt_rs6k = .false.
#elif __PGI
    pending%lopt_scalar = .true.; pending%lopt_rs6k = .false.
#elif __NEC__
    pending%lopt_scalar = .false.; pending%lopt_rs6k = .false.
#else
    pending%lopt_scalar = .false.; pending%lopt_rs6k = .false.
#endif
    pending%lvecadin = .not. pending%lopt_scalar
    status = read_distributed_process_controls(text, expected_world, admitted)
    if (status /= 0) return
    output = pending
  end function
end module
