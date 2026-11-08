!> Public source-only facade for the coherent Fullpos I/O and filter family.
module forecast_fullpos_io_and_filters
 use forecast_fullpos_io_scheme, only: native_fullpos_output_names, initialize_fullpos_io_scheme, initialize_fullpos_filter_controls
  use forecast_fullpos_field_construction, only: initialize_fullpos_fields, release_fullpos_fields
  use forecast_fullpos_io_handler, only: initialize_fullpos_io_handler, release_fullpos_io_handler
  use forecast_fullpos_filter_parent, only: initialize_fullpos_filters, release_fullpos_filters
  implicit none
  public
end module
