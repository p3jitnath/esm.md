!> Map the historical GP_MODEL source names to the complete native parent.
!! The compiler owns the Fortran calling convention. Both original caller
!! names execute the same source body. Counters remain in the actual caller
!! context, so a second forecast cannot borrow another forecast's counters.
module forecast_grid_source_interfaces
  use forecast_complete_forecast_grid_driver, only: &
    md2asm_gp_model_physics_cape_r7_7358525 => gp_model
  use forecast_complete_forecast_grid_driver, only: &
    md2asm_gp_model_lagged_raw_caller_r8_7388001 => gp_model
  use forecast_complete_forecast_grid_driver, only: &
    md2asm_gp_model_physics_cape_r7_stage_count_get => grid_model_stage_count_get
  implicit none
  private
  public :: md2asm_gp_model_physics_cape_r7_7358525
  public :: md2asm_gp_model_lagged_raw_caller_r8_7388001
  public :: md2asm_gp_model_physics_cape_r7_stage_count_get
end module forecast_grid_source_interfaces
