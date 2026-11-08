!> Compiler-managed source names for complete selected departure entries.
!! Numerical arrays and controls keep the canonical native types and bounds.
!! Runtime entries receive their live physical/control values explicitly.
!! No private model image or original numerical provider supplies a stage.
module forecast_selected_departure_interfaces
  use iso_fortran_env, only: int32, int64
  use forecast_departure_source_counters, only: departure_source_word
  use forecast_selected_source_larcina, only: md2asm_larcina_7240564 => prepare_departure_coordinate_fields
  use forecast_selected_source_larmes, only: md2asm_larmes_xyz_7259755 => find_cartesian_departure_points
  use forecast_selected_source_lapinea, only: md2asm_lapinea_7259755 => prepare_trajectory_interpolation
  use forecast_selected_source_lapineb, only: md2asm_lapineb_7259755 => update_prognostic_departure_fields
 use md2asm_departure_interpolation_weights, only: md2asm_runtime_local_departure_weights => prepare_departure_interpolation_weights
  use md2asm_weno_departure_interpolation, only: md2asm_laitri_weno => interpolate_weno_departure
  use forecast_selected_source_larcina, only: larcina => prepare_departure_coordinate_fields
  use forecast_selected_source_larmes, only: larmes_xyz => find_cartesian_departure_points
  use forecast_selected_source_lapinea, only: lapinea => prepare_trajectory_interpolation
  implicit none
  private
  public :: md2asm_larcina_7240564
  public :: md2asm_larmes_xyz_7259755
  public :: md2asm_lapinea_7259755
  public :: md2asm_lapineb_7259755
  public :: md2asm_runtime_local_departure_weights
  public :: md2asm_laitri_weno
  public :: larcina
  public :: larmes_xyz
  public :: lapinea
  public :: md2asm_larcina_calls_get
  public :: md2asm_larcina_lascaw_calls_get
  public :: md2asm_larcina_linear_calls_get
  public :: md2asm_larcina_cubic_calls_get
  public :: md2asm_larcina_weno_calls_get
  public :: md2asm_larmes_xyz_calls_get
  public :: md2asm_larmes_reporting_calculations_get
  public :: md2asm_lapinea_calls_get
  public :: md2asm_lapineb_calls_get
  public :: md2asm_lapineb_vertical_calls_get
contains
  integer(int64) function md2asm_larcina_calls_get() result(value)
    value = departure_source_word(0_int32, 0_int32)
  end function
  integer(int64) function md2asm_larcina_lascaw_calls_get() result(value)
    value = departure_source_word(0_int32, 1_int32)
  end function
  integer(int64) function md2asm_larcina_linear_calls_get() result(value)
    value = departure_source_word(0_int32, 2_int32)
  end function
  integer(int64) function md2asm_larcina_cubic_calls_get() result(value)
    value = departure_source_word(0_int32, 3_int32)
  end function
  integer(int64) function md2asm_larcina_weno_calls_get() result(value)
    value = departure_source_word(0_int32, 4_int32)
  end function
  integer(int64) function md2asm_larmes_xyz_calls_get() result(value)
    value = departure_source_word(0_int32, 5_int32)
  end function
  integer(int64) function md2asm_larmes_reporting_calculations_get() result(value)
    value = departure_source_word(0_int32, 6_int32)
  end function
  integer(int64) function md2asm_lapinea_calls_get() result(value)
    value = departure_source_word(0_int32, 7_int32)
  end function
  integer(int64) function md2asm_lapineb_calls_get() result(value)
    value = departure_source_word(0_int32, 8_int32)
  end function
  integer(int64) function md2asm_lapineb_vertical_calls_get() result(value)
    value = departure_source_word(0_int32, 9_int32)
  end function
end module forecast_selected_departure_interfaces
