!> Compiler-managed source names for complete runtime departure entries.
!! Numerical arrays and controls keep the canonical native types and bounds.
!! Runtime entries receive their live physical/control values explicitly.
!! No private model image or original numerical provider supplies a stage.
module forecast_runtime_departure_interfaces
  use iso_fortran_env, only: int32, int64
  use forecast_departure_source_counters, only: departure_source_word
  use forecast_runtime_source_larcina, only: md2asm_runtime_departure_coordinate_fields => prepare_departure_coordinate_fields
  use forecast_runtime_source_larmes, only: md2asm_runtime_cartesian_departure_points => find_cartesian_departure_points
  use forecast_runtime_source_lapinea, only: md2asm_runtime_trajectory_interpolation_weights => prepare_trajectory_interpolation
  use forecast_runtime_source_lapineb, only: md2asm_runtime_prognostic_departure_update => update_prognostic_departure_fields
 use md2asm_departure_interpolation_weights, only: md2asm_runtime_local_departure_weights => prepare_departure_interpolation_weights
  use md2asm_weno_departure_interpolation, only: md2asm_laitri_weno => interpolate_weno_departure
  implicit none
  private
  public :: md2asm_runtime_departure_coordinate_fields
  public :: md2asm_runtime_cartesian_departure_points
  public :: md2asm_runtime_trajectory_interpolation_weights
  public :: md2asm_runtime_prognostic_departure_update
  public :: md2asm_runtime_local_departure_weights
  public :: md2asm_laitri_weno
  public :: md2asm_larcina_calls_get
  public :: md2asm_larcina_lascaw_calls_get
  public :: md2asm_larcina_linear_calls_get
  public :: md2asm_larcina_cubic_calls_get
  public :: md2asm_larcina_weno_calls_get
  public :: md2asm_larmes_xyz_calls_get
  public :: md2asm_larmes_reporting_calculations_get
  public :: md2asm_lapinea_calls_get
  public :: md2asm_runtime_prognostic_departure_calls_get
  public :: md2asm_runtime_prognostic_vertical_calls_get
contains
  integer(int64) function md2asm_larcina_calls_get() result(value)
    value = departure_source_word(1_int32, 0_int32)
  end function
  integer(int64) function md2asm_larcina_lascaw_calls_get() result(value)
    value = departure_source_word(1_int32, 1_int32)
  end function
  integer(int64) function md2asm_larcina_linear_calls_get() result(value)
    value = departure_source_word(1_int32, 2_int32)
  end function
  integer(int64) function md2asm_larcina_cubic_calls_get() result(value)
    value = departure_source_word(1_int32, 3_int32)
  end function
  integer(int64) function md2asm_larcina_weno_calls_get() result(value)
    value = departure_source_word(1_int32, 4_int32)
  end function
  integer(int64) function md2asm_larmes_xyz_calls_get() result(value)
    value = departure_source_word(1_int32, 5_int32)
  end function
  integer(int64) function md2asm_larmes_reporting_calculations_get() result(value)
    value = departure_source_word(1_int32, 6_int32)
  end function
  integer(int64) function md2asm_lapinea_calls_get() result(value)
    value = departure_source_word(1_int32, 7_int32)
  end function
  integer(int64) function md2asm_runtime_prognostic_departure_calls_get() result(value)
    value = departure_source_word(1_int32, 8_int32)
  end function
  integer(int64) function md2asm_runtime_prognostic_vertical_calls_get() result(value)
    value = departure_source_word(1_int32, 9_int32)
  end function
end module forecast_runtime_departure_interfaces
