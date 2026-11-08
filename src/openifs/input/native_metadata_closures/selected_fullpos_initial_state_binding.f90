!> Project the actual initial configuration,controls and header into selected Fullpos.
!! The original selected route requires MODEL after its private GAUSS defaults.
!! NVGRIB is the explicit produced source input; no format code is invented.
!! The caller owns each native output. The selected child commits atomically.
module forecast_selected_fullpos_initial_state_binding
  use iso_fortran_env, only: int32
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  use yomfpc, only: tnamfpobj, tnamfpsci, tnamfpint, tnamfpl
  use forecast_output_request_preparation, only: native_output_common_metadata
  use forecast_selected_fullpos_configuration, only: initialize_selected_native_fullpos_configuration
  implicit none
  private
  public :: initialize_selected_fullpos_from_initial_state
contains
 integer(int32)function initialize_selected_fullpos_from_initial_state(initial,nvgrib,object,science,interpolation,levels,common)result(status)
  type(native_initial_geometry_state), target, intent(in) :: initial
  integer(int32), intent(in) :: nvgrib
  type(tnamfpobj), intent(inout) :: object
  type(tnamfpsci), intent(inout) :: science
  type(tnamfpint), intent(inout) :: interpolation
  type(tnamfpl), optional, intent(inout) :: levels
  type(native_output_common_metadata), intent(inout) :: common
  integer(int32) :: n
  status = 2
  if (.not. initial%ready) return
  if (.not. allocated(initial%prefix)) return
  if (.not. initial%prefix%ready .or. .not. initial%prefix%headers%ready) return
  n = initial%prefix%configuration_bytes
  if (n < 1 .or. n > len(initial%prefix%configuration_text)) return
  if (present(levels)) then
    status = initialize_selected_native_fullpos_configuration(initial%prefix%configuration_text(1:n), &
               initial%controls%namespace, initial%prefix%headers%ngribfile, nvgrib, object, science, interpolation, levels, common)
  else
    status = initialize_selected_native_fullpos_configuration(initial%prefix%configuration_text(1:n), &
                initial%controls%namespace, initial%prefix%headers%ngribfile, nvgrib, object, science, interpolation, common=common)
  end if
  end function
end module
