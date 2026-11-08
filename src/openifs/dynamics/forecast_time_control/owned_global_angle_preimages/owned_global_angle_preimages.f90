!> Preserve regional-angle preimages from the owned global geometry creator.
module forecast_owned_global_angle_preimages
  use iso_fortran_env, only: real64
  use iso_c_binding, only: c_int
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  implicit none
  private
  public :: native_owned_global_angle_preimages
  public :: initialize_owned_global_angle_preimages
  !> Own four angles in radians until the Fullpos model-geometry consumer runs.
  !! The original owned outer namespace starts with positive-zero words.
  !! These are that storage policy, not original TEGEO declaration defaults.
  !! READY is published only after every named scalar has been established.
  type :: native_owned_global_angle_preimages
    real(real64) :: elatc, elonc, elon0, elat0
    logical :: ready = .false.
  end type
contains
  !> Establish the source-owned preimages for the admitted global startup.
  !!
  !! INITIAL is the actual completed native initial-geometry owner. Its
  !! declared route constructs the global T1279 grid with137 model layers.
  !! OUTPUT starts fresh and remains at its caller-owned final address.
  !! Each angle has units of radians and no array or external storage.
  !! Return0 publishes all four values. Return2 preserves OUTPUT unchanged.
  !! No original routine, model global, allocation or numerical stage runs.
  !! The Fullpos child still evaluates its four ordered angle products.
  integer(c_int) function initialize_owned_global_angle_preimages(initial, output) result(status)
    type(native_initial_geometry_state), intent(in) :: initial
    type(native_owned_global_angle_preimages), intent(inout) :: output
    status = 2_c_int
    if (output%ready) return
    if (.not. initial%ready) return
    if (.not. allocated(initial%prefix)) return
    if (.not. allocated(initial%geometry)) return
    if (initial%controls%namespace%nconf /= 1) return
    if (initial%geometry%dimensions%nflevg /= 137) return
    if (initial%geometry%dimensions%nsmax /= 1279) return
    output%elatc = 0.0_real64
    output%elonc = 0.0_real64
    output%elon0 = 0.0_real64
    output%elat0 = 0.0_real64
    output%ready = .true.
    status = 0_c_int
  end function
end module forecast_owned_global_angle_preimages
