!> Publish the selected initial-file scalars from their native produced owners.
module forecast_initial_input_data_bindings
  use iso_c_binding, only: c_int32_t, c_int64_t, c_double
  use initial_model_file_headers_port, only: initial_model_header_metadata
  use forecast_vertical_coordinate_storage, only: native_vertical_state
  use forecast_standard_atmosphere_setup, only: standard_atmosphere_state
  use forecast_controls_state_types, only: native_forecast_controls_state
  implicit none
  private
  public :: initial_input_scalar_bindings, bind_initial_input_data, owned_initial_input_data
  !> The four integers are counts/date labels; TOPPRES is pressure in Pa.
  type, bind(C) :: initial_input_scalar_bindings
    integer(c_int32_t) :: ngribfile = 0, nudate = 0, nstepini = 0, nlextrap = 0
    real(c_double) :: toppres = 0.0_c_double
  end type
  type(initial_input_scalar_bindings), save, protected :: owned_initial_input_data
contains
  !> Validate every source predicate before publishing all five named fields.
 !! HEADERS, VERTICAL and ATMOSPHERE are the same live producer cohort.
 !! The caller owns those records and keeps them separate from the owned published namespace.
 !! The selected entry retains19 layers, NCONF1 and the ECMWF forecast branch.
 !! This integer-only binding leaves all inputs, IEEE status and errno unchanged.
  integer(c_int32_t) function bind_initial_input_data(headers, vertical, atmosphere, forecast) result(status)
    type(initial_model_header_metadata), intent(in) :: headers
    type(native_vertical_state), intent(in) :: vertical
    type(standard_atmosphere_state), intent(in) :: atmosphere
    type(native_forecast_controls_state), intent(in) :: forecast
    type(initial_input_scalar_bindings) :: pending
    integer(c_int64_t) :: bits
    status = 2
    if (.not. headers%ready .or. .not. vertical%constructor_ready) return
    if (vertical%levels /= 19) return
    if (forecast%namespace%nconf /= 1 .or. forecast%namespace%lecmwf /= 1) return
    if (headers%ngribfile /= 1 .or. headers%spectral%date < 1) return
    if (atmosphere%extrapolation_level < 1 .or. atmosphere%extrapolation_level > 19) return
    bits = transfer(vertical%toppres, 0_c_int64_t)
    if (bits < 0_c_int64_t .or. ibits(bits, 52, 11) == 2047_c_int64_t) return
    pending%ngribfile = headers%ngribfile
    pending%nudate = headers%spectral%date
    pending%nstepini = 0
    pending%nlextrap = atmosphere%extrapolation_level
    pending%toppres = vertical%toppres
    owned_initial_input_data = pending; status = 0
  end function
end module
