!> Publish fourteen soil diagnostic class counts from the source SUNDDH.
module forecast_soil_diagnostic_class_counts
  use iso_fortran_env, only: int32
  implicit none
  private
  public :: native_soil_diagnostic_class_counts, initialize_soil_diagnostic_class_counts
  !> Counts are dimensionless int32 values. This owner contains no field data.
  type :: native_soil_diagnostic_class_counts
    integer(int32) :: ndhvtls, ndhvtss, ndhvtts, ndhvtis, ndhvsss, ndhviis, ndhvwls
    integer(int32) :: ndhftls, ndhftss, ndhftts, ndhftis, ndhfsss, ndhfiis, ndhfwls
  end type
contains
  !> ECMWF selects the admitted source branch. Refusal2 changes nothing.
  integer(int32) function initialize_soil_diagnostic_class_counts(output, ecmwf) result(status)
    type(native_soil_diagnostic_class_counts), intent(inout) :: output
    logical, intent(in) :: ecmwf
    status = 2
    if (.not. ecmwf) return
    output%ndhvtls = 3_int32
    output%ndhvtss = 6_int32
    output%ndhvtts = 4_int32
    output%ndhvtis = 4_int32
    output%ndhvsss = 1_int32
    output%ndhviis = 1_int32
    output%ndhvwls = 2_int32
    output%ndhftls = 9_int32
    output%ndhftss = 9_int32
    output%ndhftts = 11_int32
    output%ndhftis = 9_int32
    output%ndhfsss = 4_int32
    output%ndhfiis = 3_int32
    output%ndhfwls = 8_int32
    status = 0
  end function
end module
