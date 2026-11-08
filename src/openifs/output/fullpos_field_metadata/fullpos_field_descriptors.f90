!> Construct field descriptors in the source defaults, equivalence and check order.
!! All records are the actual final owners. No file or forecast values change.
module forecast_native_fullpos_field_descriptors
  use iso_fortran_env, only: int32
  use yomafn, only: tafn
  use yomfpc, only: tnamfpsci
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_runtime_output_configuration, only: native_runtime_output_configuration
use forecast_fullpos_file_metadata,only:fullpos_field_metadata_controls,native_fullpos_file_metadata,native_fullpos_grib_code_targets
  use forecast_native_fullpos_descriptor_defaults, only: initialize_fullpos_field_descriptor_defaults
  use forecast_native_fullpos_field_defaults, only: initialize_selected_fullpos_field_defaults
use forecast_native_fullpos_field_equivalences,only:initialize_selected_fullpos_field_equivalences,check_selected_fullpos_field_descriptors
  implicit none
  private
  public :: initialize_runtime_fullpos_field_descriptors
contains
integer(int32)function initialize_runtime_fullpos_field_descriptors(text,model,configuration,afn,scientific,controls,file_metadata,codes)result(status)
  character(*), intent(in) :: text
  type(native_operational_model_configuration), target, intent(in) :: model
  type(native_runtime_output_configuration), intent(in) :: configuration
  type(tafn), target, intent(inout) :: afn
  type(tnamfpsci), intent(in) :: scientific
  type(fullpos_field_metadata_controls), intent(in) :: controls
  type(native_fullpos_file_metadata), intent(in) :: file_metadata
  type(native_fullpos_grib_code_targets), intent(in) :: codes
  status = 2
  if (.not. configuration%ready .or. .not. file_metadata%ready) return
  if (.not. associated(configuration%metadata)) return
  if (controls%kfpconf /= 0 .or. controls%ldnhdyn .or. controls%nprintlev /= 0 .or. controls%larpegef) return
  if (scientific%nfpsurfex /= 0) return
  status = initialize_fullpos_field_descriptor_defaults(afn)
  if (status /= 0) return
  status = initialize_selected_fullpos_field_defaults(text, scientific, afn, model%fields, controls, file_metadata, codes)
  if (status /= 0) return
  status = initialize_selected_fullpos_field_equivalences(afn, controls%ldnhdyn, controls%kfpconf)
  if (status /= 0) return
  status = check_selected_fullpos_field_descriptors(afn, controls%nprintlev, controls%larpegef)
  end function
end module
