module forecast_fixed_initial_field_readers
  !! Port every exported entry of operational_initial_spectral_field_reader.S.
  !! Native FP64 arrays replace byte spans; the same public codec service owns
  !! message decoding. Labels are the frozen source tables, not input fields.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema, read_initial_fields
  implicit none
  private
  public :: read_selected_spectral_fields, read_operational_initial_spectral_fields
  public :: read_selected_upper_air_fields_unused, read_selected_surface_fields_unused
  integer(int64), parameter :: labels_1(4, 78) = reshape([ &
    152_int64,1_int64,0_int64,0_int64,138_int64,1_int64,0_int64,0_int64,155_int64,1_int64,0_int64,0_int64,130_int64,1_int64,0_int64,0_int64, &
    138_int64,2_int64,0_int64,0_int64,155_int64,2_int64,0_int64,0_int64,130_int64,2_int64,0_int64,0_int64,138_int64,3_int64,0_int64,0_int64, &
    155_int64,3_int64,0_int64,0_int64,130_int64,3_int64,0_int64,0_int64,138_int64,4_int64,0_int64,0_int64,155_int64,4_int64,0_int64,0_int64, &
    130_int64,4_int64,0_int64,0_int64,138_int64,5_int64,0_int64,0_int64,155_int64,5_int64,0_int64,0_int64,130_int64,5_int64,0_int64,0_int64, &
    138_int64,6_int64,0_int64,0_int64,155_int64,6_int64,0_int64,0_int64,130_int64,6_int64,0_int64,0_int64,138_int64,7_int64,0_int64,0_int64, &
    155_int64,7_int64,0_int64,0_int64,130_int64,7_int64,0_int64,0_int64,138_int64,8_int64,0_int64,0_int64,155_int64,8_int64,0_int64,0_int64, &
    130_int64,8_int64,0_int64,0_int64,138_int64,9_int64,0_int64,0_int64,155_int64,9_int64,0_int64,0_int64,130_int64,9_int64,0_int64,0_int64, &
    138_int64,10_int64,0_int64,0_int64,155_int64,10_int64,0_int64,0_int64,130_int64,10_int64,0_int64,0_int64,138_int64,11_int64,0_int64,0_int64, &
    155_int64,11_int64,0_int64,0_int64,130_int64,11_int64,0_int64,0_int64,138_int64,12_int64,0_int64,0_int64,155_int64,12_int64,0_int64,0_int64, &
    130_int64,12_int64,0_int64,0_int64,138_int64,13_int64,0_int64,0_int64,155_int64,13_int64,0_int64,0_int64,130_int64,13_int64,0_int64,0_int64, &
    138_int64,14_int64,0_int64,0_int64,155_int64,14_int64,0_int64,0_int64,130_int64,14_int64,0_int64,0_int64,138_int64,15_int64,0_int64,0_int64, &
    155_int64,15_int64,0_int64,0_int64,130_int64,15_int64,0_int64,0_int64,138_int64,16_int64,0_int64,0_int64,155_int64,16_int64,0_int64,0_int64, &
    130_int64,16_int64,0_int64,0_int64,138_int64,17_int64,0_int64,0_int64,155_int64,17_int64,0_int64,0_int64,130_int64,17_int64,0_int64,0_int64, &
    138_int64,18_int64,0_int64,0_int64,155_int64,18_int64,0_int64,0_int64,130_int64,18_int64,0_int64,0_int64,138_int64,19_int64,0_int64,0_int64, &
    155_int64,19_int64,0_int64,0_int64,130_int64,19_int64,0_int64,0_int64,129_int64,0_int64,0_int64,0_int64,133_int64,1_int64,0_int64,0_int64, &
    133_int64,2_int64,0_int64,0_int64,133_int64,3_int64,0_int64,0_int64,133_int64,4_int64,0_int64,0_int64,133_int64,5_int64,0_int64,0_int64, &
    133_int64,6_int64,0_int64,0_int64,133_int64,7_int64,0_int64,0_int64,133_int64,8_int64,0_int64,0_int64,133_int64,9_int64,0_int64,0_int64, &
    133_int64,10_int64,0_int64,0_int64,133_int64,11_int64,0_int64,0_int64,133_int64,12_int64,0_int64,0_int64,133_int64,13_int64,0_int64,0_int64, &
    133_int64,14_int64,0_int64,0_int64,133_int64,15_int64,0_int64,0_int64,133_int64,16_int64,0_int64,0_int64,133_int64,17_int64,0_int64,0_int64, &
                                                      133_int64, 18_int64, 0_int64, 0_int64, 133_int64, 19_int64, 0_int64, 0_int64 &
                                                         ], [4, 78])
  integer(int64), parameter :: labels_2(4, 76) = reshape([ &
    133_int64,1_int64,0_int64,0_int64,133_int64,2_int64,0_int64,0_int64,133_int64,3_int64,0_int64,0_int64,133_int64,4_int64,0_int64,0_int64, &
    133_int64,5_int64,0_int64,0_int64,133_int64,6_int64,0_int64,0_int64,133_int64,7_int64,0_int64,0_int64,133_int64,8_int64,0_int64,0_int64, &
    133_int64,9_int64,0_int64,0_int64,133_int64,10_int64,0_int64,0_int64,133_int64,11_int64,0_int64,0_int64,133_int64,12_int64,0_int64,0_int64, &
    133_int64,13_int64,0_int64,0_int64,133_int64,14_int64,0_int64,0_int64,133_int64,15_int64,0_int64,0_int64,133_int64,16_int64,0_int64,0_int64, &
    133_int64,17_int64,0_int64,0_int64,133_int64,18_int64,0_int64,0_int64,133_int64,19_int64,0_int64,0_int64,246_int64,1_int64,0_int64,0_int64, &
    247_int64,1_int64,0_int64,0_int64,248_int64,1_int64,0_int64,0_int64,246_int64,2_int64,0_int64,0_int64,247_int64,2_int64,0_int64,0_int64, &
    248_int64,2_int64,0_int64,0_int64,246_int64,3_int64,0_int64,0_int64,247_int64,3_int64,0_int64,0_int64,248_int64,3_int64,0_int64,0_int64, &
    246_int64,4_int64,0_int64,0_int64,247_int64,4_int64,0_int64,0_int64,248_int64,4_int64,0_int64,0_int64,246_int64,5_int64,0_int64,0_int64, &
    247_int64,5_int64,0_int64,0_int64,248_int64,5_int64,0_int64,0_int64,246_int64,6_int64,0_int64,0_int64,247_int64,6_int64,0_int64,0_int64, &
    248_int64,6_int64,0_int64,0_int64,246_int64,7_int64,0_int64,0_int64,247_int64,7_int64,0_int64,0_int64,248_int64,7_int64,0_int64,0_int64, &
    246_int64,8_int64,0_int64,0_int64,247_int64,8_int64,0_int64,0_int64,248_int64,8_int64,0_int64,0_int64,246_int64,9_int64,0_int64,0_int64, &
    247_int64,9_int64,0_int64,0_int64,248_int64,9_int64,0_int64,0_int64,246_int64,10_int64,0_int64,0_int64,247_int64,10_int64,0_int64,0_int64, &
    248_int64,10_int64,0_int64,0_int64,246_int64,11_int64,0_int64,0_int64,247_int64,11_int64,0_int64,0_int64,248_int64,11_int64,0_int64,0_int64, &
    246_int64,12_int64,0_int64,0_int64,247_int64,12_int64,0_int64,0_int64,248_int64,12_int64,0_int64,0_int64,246_int64,13_int64,0_int64,0_int64, &
    247_int64,13_int64,0_int64,0_int64,248_int64,13_int64,0_int64,0_int64,246_int64,14_int64,0_int64,0_int64,247_int64,14_int64,0_int64,0_int64, &
    248_int64,14_int64,0_int64,0_int64,246_int64,15_int64,0_int64,0_int64,247_int64,15_int64,0_int64,0_int64,248_int64,15_int64,0_int64,0_int64, &
    246_int64,16_int64,0_int64,0_int64,247_int64,16_int64,0_int64,0_int64,248_int64,16_int64,0_int64,0_int64,246_int64,17_int64,0_int64,0_int64, &
    247_int64,17_int64,0_int64,0_int64,248_int64,17_int64,0_int64,0_int64,246_int64,18_int64,0_int64,0_int64,247_int64,18_int64,0_int64,0_int64, &
    248_int64,18_int64,0_int64,0_int64,246_int64,19_int64,0_int64,0_int64,247_int64,19_int64,0_int64,0_int64,248_int64,19_int64,0_int64,0_int64 &
                                                         ], [4, 76])
  integer(int64), parameter :: labels_3(4, 140) = reshape([ &
    32_int64,1_int64,20041015_int64,1200_int64,32_int64,2_int64,20041015_int64,1200_int64,32_int64,3_int64,20041015_int64,1200_int64,32_int64,4_int64,20041015_int64,1200_int64, &
    32_int64,5_int64,20041015_int64,1200_int64,238_int64,1_int64,20041015_int64,0_int64,238_int64,2_int64,20041015_int64,0_int64,238_int64,3_int64,20041015_int64,0_int64, &
    238_int64,4_int64,20041015_int64,0_int64,238_int64,5_int64,20041015_int64,0_int64,33_int64,1_int64,20041015_int64,0_int64,33_int64,2_int64,20041015_int64,0_int64, &
    33_int64,3_int64,20041015_int64,0_int64,33_int64,4_int64,20041015_int64,0_int64,33_int64,5_int64,20041015_int64,0_int64,139_int64,0_int64,20041015_int64,1200_int64, &
    170_int64,7_int64,20041015_int64,1200_int64,183_int64,28_int64,20041015_int64,1200_int64,236_int64,100_int64,20041015_int64,1200_int64,39_int64,0_int64,20041015_int64,1200_int64, &
    40_int64,7_int64,20041015_int64,1200_int64,41_int64,28_int64,20041015_int64,1200_int64,42_int64,100_int64,20041015_int64,1200_int64,198_int64,0_int64,20041015_int64,1200_int64, &
    235_int64,0_int64,20041015_int64,1200_int64,31_int64,0_int64,20041015_int64,1200_int64,34_int64,0_int64,20041015_int64,1200_int64,35_int64,0_int64,20041015_int64,1200_int64, &
    36_int64,7_int64,20041015_int64,1200_int64,37_int64,28_int64,20041015_int64,1200_int64,38_int64,100_int64,20041015_int64,1200_int64,148_int64,0_int64,20041015_int64,1200_int64, &
    172_int64,0_int64,20041015_int64,1200_int64,173_int64,0_int64,20041015_int64,1200_int64,174_int64,0_int64,20041015_int64,1200_int64,160_int64,0_int64,20041015_int64,1200_int64, &
    161_int64,0_int64,20041015_int64,1200_int64,162_int64,0_int64,20041015_int64,1200_int64,163_int64,0_int64,20041015_int64,1200_int64,234_int64,0_int64,20041015_int64,1200_int64, &
    28_int64,0_int64,20041015_int64,1200_int64,27_int64,0_int64,20041015_int64,1200_int64,30_int64,0_int64,20041015_int64,1200_int64,29_int64,0_int64,20041015_int64,1200_int64, &
    74_int64,0_int64,19960101_int64,0_int64,18_int64,0_int64,99990115_int64,0_int64,18_int64,0_int64,99990215_int64,0_int64,18_int64,0_int64,99990315_int64,0_int64, &
    18_int64,0_int64,99990415_int64,0_int64,18_int64,0_int64,99990515_int64,0_int64,18_int64,0_int64,99990615_int64,0_int64,18_int64,0_int64,99990715_int64,0_int64, &
    18_int64,0_int64,99990815_int64,0_int64,18_int64,0_int64,99990915_int64,0_int64,18_int64,0_int64,99991015_int64,0_int64,18_int64,0_int64,99991115_int64,0_int64, &
    18_int64,0_int64,99991215_int64,0_int64,17_int64,0_int64,99990115_int64,0_int64,17_int64,0_int64,99990215_int64,0_int64,17_int64,0_int64,99990315_int64,0_int64, &
    17_int64,0_int64,99990415_int64,0_int64,17_int64,0_int64,99990515_int64,0_int64,17_int64,0_int64,99990615_int64,0_int64,17_int64,0_int64,99990715_int64,0_int64, &
    17_int64,0_int64,99990815_int64,0_int64,17_int64,0_int64,99990915_int64,0_int64,17_int64,0_int64,99991015_int64,0_int64,17_int64,0_int64,99991115_int64,0_int64, &
    17_int64,0_int64,99991215_int64,0_int64,16_int64,0_int64,99990115_int64,0_int64,16_int64,0_int64,99990215_int64,0_int64,16_int64,0_int64,99990315_int64,0_int64, &
    16_int64,0_int64,99990415_int64,0_int64,16_int64,0_int64,99990515_int64,0_int64,16_int64,0_int64,99990615_int64,0_int64,16_int64,0_int64,99990715_int64,0_int64, &
    16_int64,0_int64,99990815_int64,0_int64,16_int64,0_int64,99990915_int64,0_int64,16_int64,0_int64,99991015_int64,0_int64,16_int64,0_int64,99991115_int64,0_int64, &
    16_int64,0_int64,99991215_int64,0_int64,15_int64,0_int64,99990115_int64,0_int64,15_int64,0_int64,99990215_int64,0_int64,15_int64,0_int64,99990315_int64,0_int64, &
    15_int64,0_int64,99990415_int64,0_int64,15_int64,0_int64,99990515_int64,0_int64,15_int64,0_int64,99990615_int64,0_int64,15_int64,0_int64,99990715_int64,0_int64, &
    15_int64,0_int64,99990815_int64,0_int64,15_int64,0_int64,99990915_int64,0_int64,15_int64,0_int64,99991015_int64,0_int64,15_int64,0_int64,99991115_int64,0_int64, &
    15_int64,0_int64,99991215_int64,0_int64,43_int64,0_int64,19950101_int64,0_int64,66_int64,0_int64,99990115_int64,0_int64,66_int64,0_int64,99990215_int64,0_int64, &
    66_int64,0_int64,99990315_int64,0_int64,66_int64,0_int64,99990415_int64,0_int64,66_int64,0_int64,99990515_int64,0_int64,66_int64,0_int64,99990615_int64,0_int64, &
    66_int64,0_int64,99990715_int64,0_int64,66_int64,0_int64,99990815_int64,0_int64,66_int64,0_int64,99990915_int64,0_int64,66_int64,0_int64,99991015_int64,0_int64, &
    66_int64,0_int64,99991115_int64,0_int64,66_int64,0_int64,99991215_int64,0_int64,67_int64,0_int64,99990115_int64,0_int64,67_int64,0_int64,99990215_int64,0_int64, &
    67_int64,0_int64,99990315_int64,0_int64,67_int64,0_int64,99990415_int64,0_int64,67_int64,0_int64,99990515_int64,0_int64,67_int64,0_int64,99990615_int64,0_int64, &
    67_int64,0_int64,99990715_int64,0_int64,67_int64,0_int64,99990815_int64,0_int64,67_int64,0_int64,99990915_int64,0_int64,67_int64,0_int64,99991015_int64,0_int64, &
    67_int64,0_int64,99991115_int64,0_int64,67_int64,0_int64,99991215_int64,0_int64,228007_int64,0_int64,99990115_int64,0_int64,26_int64,0_int64,20140331_int64,0_int64, &
    228011_int64,0_int64,20041015_int64,0_int64,228012_int64,0_int64,20041015_int64,0_int64,228008_int64,0_int64,20041015_int64,0_int64,228009_int64,0_int64,20041015_int64,0_int64, &
    228013_int64,0_int64,20041015_int64,0_int64,228014_int64,0_int64,20041015_int64,0_int64,228010_int64,0_int64,20041015_int64,0_int64,228141_int64,1_int64,20041015_int64,0_int64, &
    228141_int64,2_int64,20041015_int64,0_int64,228141_int64,3_int64,20041015_int64,0_int64,228141_int64,4_int64,20041015_int64,0_int64,228141_int64,5_int64,20041015_int64,0_int64, &
    228038_int64,1_int64,20041015_int64,0_int64,228038_int64,2_int64,20041015_int64,0_int64,228038_int64,3_int64,20041015_int64,0_int64,228038_int64,4_int64,20041015_int64,0_int64, &
    228038_int64,5_int64,20041015_int64,0_int64,200199_int64,0_int64,99990615_int64,0_int64,129172_int64,0_int64,20110131_int64,0_int64,200026_int64,0_int64,99990615_int64,0_int64 &
                                                          ], [4, 140])
  integer(int64), parameter :: labels_4(4, 413) = reshape([ &
    152_int64,1_int64,0_int64,0_int64,138_int64,1_int64,0_int64,0_int64,155_int64,1_int64,0_int64,0_int64,130_int64,1_int64,0_int64,0_int64, &
    138_int64,2_int64,0_int64,0_int64,155_int64,2_int64,0_int64,0_int64,130_int64,2_int64,0_int64,0_int64,138_int64,3_int64,0_int64,0_int64, &
    155_int64,3_int64,0_int64,0_int64,130_int64,3_int64,0_int64,0_int64,138_int64,4_int64,0_int64,0_int64,155_int64,4_int64,0_int64,0_int64, &
    130_int64,4_int64,0_int64,0_int64,138_int64,5_int64,0_int64,0_int64,155_int64,5_int64,0_int64,0_int64,130_int64,5_int64,0_int64,0_int64, &
    138_int64,6_int64,0_int64,0_int64,155_int64,6_int64,0_int64,0_int64,130_int64,6_int64,0_int64,0_int64,138_int64,7_int64,0_int64,0_int64, &
    155_int64,7_int64,0_int64,0_int64,130_int64,7_int64,0_int64,0_int64,138_int64,8_int64,0_int64,0_int64,155_int64,8_int64,0_int64,0_int64, &
    130_int64,8_int64,0_int64,0_int64,138_int64,9_int64,0_int64,0_int64,155_int64,9_int64,0_int64,0_int64,130_int64,9_int64,0_int64,0_int64, &
    138_int64,10_int64,0_int64,0_int64,155_int64,10_int64,0_int64,0_int64,130_int64,10_int64,0_int64,0_int64,138_int64,11_int64,0_int64,0_int64, &
    155_int64,11_int64,0_int64,0_int64,130_int64,11_int64,0_int64,0_int64,138_int64,12_int64,0_int64,0_int64,155_int64,12_int64,0_int64,0_int64, &
    130_int64,12_int64,0_int64,0_int64,138_int64,13_int64,0_int64,0_int64,155_int64,13_int64,0_int64,0_int64,130_int64,13_int64,0_int64,0_int64, &
    138_int64,14_int64,0_int64,0_int64,155_int64,14_int64,0_int64,0_int64,130_int64,14_int64,0_int64,0_int64,138_int64,15_int64,0_int64,0_int64, &
    155_int64,15_int64,0_int64,0_int64,130_int64,15_int64,0_int64,0_int64,138_int64,16_int64,0_int64,0_int64,155_int64,16_int64,0_int64,0_int64, &
    130_int64,16_int64,0_int64,0_int64,138_int64,17_int64,0_int64,0_int64,155_int64,17_int64,0_int64,0_int64,130_int64,17_int64,0_int64,0_int64, &
    138_int64,18_int64,0_int64,0_int64,155_int64,18_int64,0_int64,0_int64,130_int64,18_int64,0_int64,0_int64,138_int64,19_int64,0_int64,0_int64, &
    155_int64,19_int64,0_int64,0_int64,130_int64,19_int64,0_int64,0_int64,138_int64,20_int64,0_int64,0_int64,155_int64,20_int64,0_int64,0_int64, &
    130_int64,20_int64,0_int64,0_int64,138_int64,21_int64,0_int64,0_int64,155_int64,21_int64,0_int64,0_int64,130_int64,21_int64,0_int64,0_int64, &
    138_int64,22_int64,0_int64,0_int64,155_int64,22_int64,0_int64,0_int64,130_int64,22_int64,0_int64,0_int64,138_int64,23_int64,0_int64,0_int64, &
    155_int64,23_int64,0_int64,0_int64,130_int64,23_int64,0_int64,0_int64,138_int64,24_int64,0_int64,0_int64,155_int64,24_int64,0_int64,0_int64, &
    130_int64,24_int64,0_int64,0_int64,138_int64,25_int64,0_int64,0_int64,155_int64,25_int64,0_int64,0_int64,130_int64,25_int64,0_int64,0_int64, &
    138_int64,26_int64,0_int64,0_int64,155_int64,26_int64,0_int64,0_int64,130_int64,26_int64,0_int64,0_int64,138_int64,27_int64,0_int64,0_int64, &
    155_int64,27_int64,0_int64,0_int64,130_int64,27_int64,0_int64,0_int64,138_int64,28_int64,0_int64,0_int64,155_int64,28_int64,0_int64,0_int64, &
    130_int64,28_int64,0_int64,0_int64,138_int64,29_int64,0_int64,0_int64,155_int64,29_int64,0_int64,0_int64,130_int64,29_int64,0_int64,0_int64, &
    138_int64,30_int64,0_int64,0_int64,155_int64,30_int64,0_int64,0_int64,130_int64,30_int64,0_int64,0_int64,138_int64,31_int64,0_int64,0_int64, &
    155_int64,31_int64,0_int64,0_int64,130_int64,31_int64,0_int64,0_int64,138_int64,32_int64,0_int64,0_int64,155_int64,32_int64,0_int64,0_int64, &
    130_int64,32_int64,0_int64,0_int64,138_int64,33_int64,0_int64,0_int64,155_int64,33_int64,0_int64,0_int64,130_int64,33_int64,0_int64,0_int64, &
    138_int64,34_int64,0_int64,0_int64,155_int64,34_int64,0_int64,0_int64,130_int64,34_int64,0_int64,0_int64,138_int64,35_int64,0_int64,0_int64, &
    155_int64,35_int64,0_int64,0_int64,130_int64,35_int64,0_int64,0_int64,138_int64,36_int64,0_int64,0_int64,155_int64,36_int64,0_int64,0_int64, &
    130_int64,36_int64,0_int64,0_int64,138_int64,37_int64,0_int64,0_int64,155_int64,37_int64,0_int64,0_int64,130_int64,37_int64,0_int64,0_int64, &
    138_int64,38_int64,0_int64,0_int64,155_int64,38_int64,0_int64,0_int64,130_int64,38_int64,0_int64,0_int64,138_int64,39_int64,0_int64,0_int64, &
    155_int64,39_int64,0_int64,0_int64,130_int64,39_int64,0_int64,0_int64,138_int64,40_int64,0_int64,0_int64,155_int64,40_int64,0_int64,0_int64, &
    130_int64,40_int64,0_int64,0_int64,138_int64,41_int64,0_int64,0_int64,155_int64,41_int64,0_int64,0_int64,130_int64,41_int64,0_int64,0_int64, &
    138_int64,42_int64,0_int64,0_int64,155_int64,42_int64,0_int64,0_int64,130_int64,42_int64,0_int64,0_int64,138_int64,43_int64,0_int64,0_int64, &
    155_int64,43_int64,0_int64,0_int64,130_int64,43_int64,0_int64,0_int64,138_int64,44_int64,0_int64,0_int64,155_int64,44_int64,0_int64,0_int64, &
    130_int64,44_int64,0_int64,0_int64,138_int64,45_int64,0_int64,0_int64,155_int64,45_int64,0_int64,0_int64,130_int64,45_int64,0_int64,0_int64, &
    138_int64,46_int64,0_int64,0_int64,155_int64,46_int64,0_int64,0_int64,130_int64,46_int64,0_int64,0_int64,138_int64,47_int64,0_int64,0_int64, &
    155_int64,47_int64,0_int64,0_int64,130_int64,47_int64,0_int64,0_int64,138_int64,48_int64,0_int64,0_int64,155_int64,48_int64,0_int64,0_int64, &
    130_int64,48_int64,0_int64,0_int64,138_int64,49_int64,0_int64,0_int64,155_int64,49_int64,0_int64,0_int64,130_int64,49_int64,0_int64,0_int64, &
    138_int64,50_int64,0_int64,0_int64,155_int64,50_int64,0_int64,0_int64,130_int64,50_int64,0_int64,0_int64,138_int64,51_int64,0_int64,0_int64, &
    155_int64,51_int64,0_int64,0_int64,130_int64,51_int64,0_int64,0_int64,138_int64,52_int64,0_int64,0_int64,155_int64,52_int64,0_int64,0_int64, &
    130_int64,52_int64,0_int64,0_int64,138_int64,53_int64,0_int64,0_int64,155_int64,53_int64,0_int64,0_int64,130_int64,53_int64,0_int64,0_int64, &
    138_int64,54_int64,0_int64,0_int64,155_int64,54_int64,0_int64,0_int64,130_int64,54_int64,0_int64,0_int64,138_int64,55_int64,0_int64,0_int64, &
    155_int64,55_int64,0_int64,0_int64,130_int64,55_int64,0_int64,0_int64,138_int64,56_int64,0_int64,0_int64,155_int64,56_int64,0_int64,0_int64, &
    130_int64,56_int64,0_int64,0_int64,138_int64,57_int64,0_int64,0_int64,155_int64,57_int64,0_int64,0_int64,130_int64,57_int64,0_int64,0_int64, &
    138_int64,58_int64,0_int64,0_int64,155_int64,58_int64,0_int64,0_int64,130_int64,58_int64,0_int64,0_int64,138_int64,59_int64,0_int64,0_int64, &
    155_int64,59_int64,0_int64,0_int64,130_int64,59_int64,0_int64,0_int64,138_int64,60_int64,0_int64,0_int64,155_int64,60_int64,0_int64,0_int64, &
    130_int64,60_int64,0_int64,0_int64,138_int64,61_int64,0_int64,0_int64,155_int64,61_int64,0_int64,0_int64,130_int64,61_int64,0_int64,0_int64, &
    138_int64,62_int64,0_int64,0_int64,155_int64,62_int64,0_int64,0_int64,130_int64,62_int64,0_int64,0_int64,138_int64,63_int64,0_int64,0_int64, &
    155_int64,63_int64,0_int64,0_int64,130_int64,63_int64,0_int64,0_int64,138_int64,64_int64,0_int64,0_int64,155_int64,64_int64,0_int64,0_int64, &
    130_int64,64_int64,0_int64,0_int64,138_int64,65_int64,0_int64,0_int64,155_int64,65_int64,0_int64,0_int64,130_int64,65_int64,0_int64,0_int64, &
    138_int64,66_int64,0_int64,0_int64,155_int64,66_int64,0_int64,0_int64,130_int64,66_int64,0_int64,0_int64,138_int64,67_int64,0_int64,0_int64, &
    155_int64,67_int64,0_int64,0_int64,130_int64,67_int64,0_int64,0_int64,138_int64,68_int64,0_int64,0_int64,155_int64,68_int64,0_int64,0_int64, &
    130_int64,68_int64,0_int64,0_int64,138_int64,69_int64,0_int64,0_int64,155_int64,69_int64,0_int64,0_int64,130_int64,69_int64,0_int64,0_int64, &
    138_int64,70_int64,0_int64,0_int64,155_int64,70_int64,0_int64,0_int64,130_int64,70_int64,0_int64,0_int64,138_int64,71_int64,0_int64,0_int64, &
    155_int64,71_int64,0_int64,0_int64,130_int64,71_int64,0_int64,0_int64,138_int64,72_int64,0_int64,0_int64,155_int64,72_int64,0_int64,0_int64, &
    130_int64,72_int64,0_int64,0_int64,138_int64,73_int64,0_int64,0_int64,155_int64,73_int64,0_int64,0_int64,130_int64,73_int64,0_int64,0_int64, &
    138_int64,74_int64,0_int64,0_int64,155_int64,74_int64,0_int64,0_int64,130_int64,74_int64,0_int64,0_int64,138_int64,75_int64,0_int64,0_int64, &
    155_int64,75_int64,0_int64,0_int64,130_int64,75_int64,0_int64,0_int64,138_int64,76_int64,0_int64,0_int64,155_int64,76_int64,0_int64,0_int64, &
    130_int64,76_int64,0_int64,0_int64,138_int64,77_int64,0_int64,0_int64,155_int64,77_int64,0_int64,0_int64,130_int64,77_int64,0_int64,0_int64, &
    138_int64,78_int64,0_int64,0_int64,155_int64,78_int64,0_int64,0_int64,130_int64,78_int64,0_int64,0_int64,138_int64,79_int64,0_int64,0_int64, &
    155_int64,79_int64,0_int64,0_int64,130_int64,79_int64,0_int64,0_int64,138_int64,80_int64,0_int64,0_int64,155_int64,80_int64,0_int64,0_int64, &
    130_int64,80_int64,0_int64,0_int64,138_int64,81_int64,0_int64,0_int64,155_int64,81_int64,0_int64,0_int64,130_int64,81_int64,0_int64,0_int64, &
    138_int64,82_int64,0_int64,0_int64,155_int64,82_int64,0_int64,0_int64,130_int64,82_int64,0_int64,0_int64,138_int64,83_int64,0_int64,0_int64, &
    155_int64,83_int64,0_int64,0_int64,130_int64,83_int64,0_int64,0_int64,138_int64,84_int64,0_int64,0_int64,155_int64,84_int64,0_int64,0_int64, &
    130_int64,84_int64,0_int64,0_int64,138_int64,85_int64,0_int64,0_int64,155_int64,85_int64,0_int64,0_int64,130_int64,85_int64,0_int64,0_int64, &
    138_int64,86_int64,0_int64,0_int64,155_int64,86_int64,0_int64,0_int64,130_int64,86_int64,0_int64,0_int64,138_int64,87_int64,0_int64,0_int64, &
    155_int64,87_int64,0_int64,0_int64,130_int64,87_int64,0_int64,0_int64,138_int64,88_int64,0_int64,0_int64,155_int64,88_int64,0_int64,0_int64, &
    130_int64,88_int64,0_int64,0_int64,138_int64,89_int64,0_int64,0_int64,155_int64,89_int64,0_int64,0_int64,130_int64,89_int64,0_int64,0_int64, &
    138_int64,90_int64,0_int64,0_int64,155_int64,90_int64,0_int64,0_int64,130_int64,90_int64,0_int64,0_int64,138_int64,91_int64,0_int64,0_int64, &
    155_int64,91_int64,0_int64,0_int64,130_int64,91_int64,0_int64,0_int64,138_int64,92_int64,0_int64,0_int64,155_int64,92_int64,0_int64,0_int64, &
    130_int64,92_int64,0_int64,0_int64,138_int64,93_int64,0_int64,0_int64,155_int64,93_int64,0_int64,0_int64,130_int64,93_int64,0_int64,0_int64, &
    138_int64,94_int64,0_int64,0_int64,155_int64,94_int64,0_int64,0_int64,130_int64,94_int64,0_int64,0_int64,138_int64,95_int64,0_int64,0_int64, &
    155_int64,95_int64,0_int64,0_int64,130_int64,95_int64,0_int64,0_int64,138_int64,96_int64,0_int64,0_int64,155_int64,96_int64,0_int64,0_int64, &
    130_int64,96_int64,0_int64,0_int64,138_int64,97_int64,0_int64,0_int64,155_int64,97_int64,0_int64,0_int64,130_int64,97_int64,0_int64,0_int64, &
    138_int64,98_int64,0_int64,0_int64,155_int64,98_int64,0_int64,0_int64,130_int64,98_int64,0_int64,0_int64,138_int64,99_int64,0_int64,0_int64, &
    155_int64,99_int64,0_int64,0_int64,130_int64,99_int64,0_int64,0_int64,138_int64,100_int64,0_int64,0_int64,155_int64,100_int64,0_int64,0_int64, &
    130_int64,100_int64,0_int64,0_int64,138_int64,101_int64,0_int64,0_int64,155_int64,101_int64,0_int64,0_int64,130_int64,101_int64,0_int64,0_int64, &
    138_int64,102_int64,0_int64,0_int64,155_int64,102_int64,0_int64,0_int64,130_int64,102_int64,0_int64,0_int64,138_int64,103_int64,0_int64,0_int64, &
    155_int64,103_int64,0_int64,0_int64,130_int64,103_int64,0_int64,0_int64,138_int64,104_int64,0_int64,0_int64,155_int64,104_int64,0_int64,0_int64, &
    130_int64,104_int64,0_int64,0_int64,138_int64,105_int64,0_int64,0_int64,155_int64,105_int64,0_int64,0_int64,130_int64,105_int64,0_int64,0_int64, &
    138_int64,106_int64,0_int64,0_int64,155_int64,106_int64,0_int64,0_int64,130_int64,106_int64,0_int64,0_int64,138_int64,107_int64,0_int64,0_int64, &
    155_int64,107_int64,0_int64,0_int64,130_int64,107_int64,0_int64,0_int64,138_int64,108_int64,0_int64,0_int64,155_int64,108_int64,0_int64,0_int64, &
    130_int64,108_int64,0_int64,0_int64,138_int64,109_int64,0_int64,0_int64,155_int64,109_int64,0_int64,0_int64,130_int64,109_int64,0_int64,0_int64, &
    138_int64,110_int64,0_int64,0_int64,155_int64,110_int64,0_int64,0_int64,130_int64,110_int64,0_int64,0_int64,138_int64,111_int64,0_int64,0_int64, &
    155_int64,111_int64,0_int64,0_int64,130_int64,111_int64,0_int64,0_int64,138_int64,112_int64,0_int64,0_int64,155_int64,112_int64,0_int64,0_int64, &
    130_int64,112_int64,0_int64,0_int64,138_int64,113_int64,0_int64,0_int64,155_int64,113_int64,0_int64,0_int64,130_int64,113_int64,0_int64,0_int64, &
    138_int64,114_int64,0_int64,0_int64,155_int64,114_int64,0_int64,0_int64,130_int64,114_int64,0_int64,0_int64,138_int64,115_int64,0_int64,0_int64, &
    155_int64,115_int64,0_int64,0_int64,130_int64,115_int64,0_int64,0_int64,138_int64,116_int64,0_int64,0_int64,155_int64,116_int64,0_int64,0_int64, &
    130_int64,116_int64,0_int64,0_int64,138_int64,117_int64,0_int64,0_int64,155_int64,117_int64,0_int64,0_int64,130_int64,117_int64,0_int64,0_int64, &
    138_int64,118_int64,0_int64,0_int64,155_int64,118_int64,0_int64,0_int64,130_int64,118_int64,0_int64,0_int64,138_int64,119_int64,0_int64,0_int64, &
    155_int64,119_int64,0_int64,0_int64,130_int64,119_int64,0_int64,0_int64,138_int64,120_int64,0_int64,0_int64,155_int64,120_int64,0_int64,0_int64, &
    130_int64,120_int64,0_int64,0_int64,138_int64,121_int64,0_int64,0_int64,155_int64,121_int64,0_int64,0_int64,130_int64,121_int64,0_int64,0_int64, &
    138_int64,122_int64,0_int64,0_int64,155_int64,122_int64,0_int64,0_int64,130_int64,122_int64,0_int64,0_int64,138_int64,123_int64,0_int64,0_int64, &
    155_int64,123_int64,0_int64,0_int64,130_int64,123_int64,0_int64,0_int64,138_int64,124_int64,0_int64,0_int64,155_int64,124_int64,0_int64,0_int64, &
    130_int64,124_int64,0_int64,0_int64,138_int64,125_int64,0_int64,0_int64,155_int64,125_int64,0_int64,0_int64,130_int64,125_int64,0_int64,0_int64, &
    138_int64,126_int64,0_int64,0_int64,155_int64,126_int64,0_int64,0_int64,130_int64,126_int64,0_int64,0_int64,138_int64,127_int64,0_int64,0_int64, &
    155_int64,127_int64,0_int64,0_int64,130_int64,127_int64,0_int64,0_int64,138_int64,128_int64,0_int64,0_int64,155_int64,128_int64,0_int64,0_int64, &
    130_int64,128_int64,0_int64,0_int64,138_int64,129_int64,0_int64,0_int64,155_int64,129_int64,0_int64,0_int64,130_int64,129_int64,0_int64,0_int64, &
    138_int64,130_int64,0_int64,0_int64,155_int64,130_int64,0_int64,0_int64,130_int64,130_int64,0_int64,0_int64,138_int64,131_int64,0_int64,0_int64, &
    155_int64,131_int64,0_int64,0_int64,130_int64,131_int64,0_int64,0_int64,138_int64,132_int64,0_int64,0_int64,155_int64,132_int64,0_int64,0_int64, &
    130_int64,132_int64,0_int64,0_int64,138_int64,133_int64,0_int64,0_int64,155_int64,133_int64,0_int64,0_int64,130_int64,133_int64,0_int64,0_int64, &
    138_int64,134_int64,0_int64,0_int64,155_int64,134_int64,0_int64,0_int64,130_int64,134_int64,0_int64,0_int64,138_int64,135_int64,0_int64,0_int64, &
    155_int64,135_int64,0_int64,0_int64,130_int64,135_int64,0_int64,0_int64,138_int64,136_int64,0_int64,0_int64,155_int64,136_int64,0_int64,0_int64, &
    130_int64,136_int64,0_int64,0_int64,138_int64,137_int64,0_int64,0_int64,155_int64,137_int64,0_int64,0_int64,130_int64,137_int64,0_int64,0_int64, &
                                                          129_int64, 0_int64, 0_int64, 0_int64 &
                                                          ], [4, 413])
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function read_selected_spectral_fields(path, values, metadata, messages_read) result(status)
    !! values and metadata are caller-owned contiguous arrays. Bounds follow
    !! the frozen profile; successful prefixes and a partial current decoded
    !! column remain observable on reader failure, as in the source service.
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: values(:, :)
    integer(int64), contiguous, intent(inout) :: metadata(:, :)
    integer(int64), intent(inout) :: messages_read
    status = read_fixed_profile(1, path, values, metadata, messages_read)
  end function

  integer(int32) function read_selected_upper_air_fields_unused(path, values, metadata, messages_read) result(status)
    !! values and metadata are caller-owned contiguous arrays. Bounds follow
    !! the frozen profile; successful prefixes and a partial current decoded
    !! column remain observable on reader failure, as in the source service.
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: values(:, :)
    integer(int64), contiguous, intent(inout) :: metadata(:, :)
    integer(int64), intent(inout) :: messages_read
    status = read_fixed_profile(2, path, values, metadata, messages_read)
  end function

  integer(int32) function read_selected_surface_fields_unused(path, values, metadata, messages_read) result(status)
    !! values and metadata are caller-owned contiguous arrays. Bounds follow
    !! the frozen profile; successful prefixes and a partial current decoded
    !! column remain observable on reader failure, as in the source service.
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: values(:, :)
    integer(int64), contiguous, intent(inout) :: metadata(:, :)
    integer(int64), intent(inout) :: messages_read
    status = read_fixed_profile(3, path, values, metadata, messages_read)
  end function

  integer(int32) function read_operational_initial_spectral_fields(path, values, metadata, messages_read) result(status)
    !! values and metadata are caller-owned contiguous arrays. Bounds follow
    !! the frozen profile; successful prefixes and a partial current decoded
    !! column remain observable on reader failure, as in the source service.
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: values(:, :)
    integer(int64), contiguous, intent(inout) :: metadata(:, :)
    integer(int64), intent(inout) :: messages_read
    status = read_fixed_profile(4, path, values, metadata, messages_read)
  end function

  integer(int32) function read_fixed_profile(profile, path, values, metadata, messages_read) result(status)
    integer, intent(in) :: profile
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: values(:, :)
    integer(int64), contiguous, intent(inout) :: metadata(:, :)
    integer(int64), intent(inout) :: messages_read
    type(initial_field_schema) :: schema
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: count, records, words, gaussian, ios, row, record
    status = 1
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, c_null_char) /= 0) return
    select case (profile)
    case (1); count = 506; records = 78; words = 3; gaussian = 0
    case (2); count = 2048; records = 76; words = 3; gaussian = 0
    case (3); count = 2048; records = 140; words = 5; gaussian = 16
    case (4); count = 1639680; records = 413; words = 3; gaussian = 0
    case default; return
    end select
    if (size(values, 1) /= count .or. size(values, 2) < records) return
    if (size(metadata, 1) /= words .or. size(metadata, 2) < records) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    status = 2
    allocate (schema%labels(4, records), stat=ios)
    if (ios /= 0) goto 900
    do record = 1, records
      do row = 1, 4
        select case (profile)
        case (1); schema%labels(row, record) = labels_1(row, record)
        case (2); schema%labels(row, record) = labels_2(row, record)
        case (3); schema%labels(row, record) = labels_3(row, record)
        case (4); schema%labels(row, record) = labels_4(row, record)
        end select
      end do
    end do
    schema%value_count = int(count, int64); schema%metadata_words = words; schema%gaussian_order = gaussian
    status = read_initial_fields(path, schema, values, metadata, messages_read)
900 if (allocated(schema%labels)) deallocate (schema%labels)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module forecast_fixed_initial_field_readers
