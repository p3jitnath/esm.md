!> Expose every actual consumer of the shared field-scatter source loop.
!! Source-private offsets are replaced by the existing native views and layout.
!! The fixed24-point/463-field CPG route and parameterized runtime route share
!! the source field-then-point order. No numerical child or callback is added.
module forecast_complete_transport_scatter_include_contexts
  use forecast_transport_field_scatter, only: transport_scatter_layout, admit_transport_field_block, scatter_transport_field_block
  use forecast_grid_point_transport_handoff, only: complete_grid_point_transport_handoff
  use forecast_grid_point_update, only: grid_point_update_controls, grid_point_column_views, update_grid_point_column, &
                                        grid_point_update_call_count, grid_point_update_stage_count
  implicit none
  private
  public :: transport_scatter_layout, admit_transport_field_block, scatter_transport_field_block
  public :: complete_grid_point_transport_handoff
  public :: grid_point_update_controls, grid_point_column_views, update_grid_point_column
  public :: grid_point_update_call_count, grid_point_update_stage_count
end module forecast_complete_transport_scatter_include_contexts
