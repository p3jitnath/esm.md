!> Borrow the source-produced soil classes and radiation-call interval.
!! Counts use int32. NRADFR retains the original model time-step convention.
!! Both input records must already have completed their scientific producers.
!! This module owns no records or arrays and does not create readiness.
module forecast_runtime_physics_count_views
  use iso_fortran_env, only: int32
  use forecast_soil_diagnostic_class_counts, only: native_soil_diagnostic_class_counts
  use yoerad, only: TERAD
  implicit none
  private
  public :: project_runtime_physics_counts
contains
  !> Copy fourteen source-named counts and the same actual TERAD%NRADFR.
 !! SOIL and RADIATION are read-only actual owners. SOIL_COUNTS has fourteen
 !! dimensionless entries in the original ECPHYS_DIMENSION source order.
 !! RADIATION_INTERVAL copies NRADFR without conversion. No allocation,
 !! arithmetic, floating-point state, source record or counter is changed.
  integer(int32) function project_runtime_physics_counts(soil, radiation, soil_counts, radiation_interval) result(status)
    type(native_soil_diagnostic_class_counts), intent(in) :: soil
    type(TERAD), intent(in) :: radiation
    integer(int32), intent(out) :: soil_counts(14), radiation_interval
    soil_counts = [soil%ndhvtls, soil%ndhftls, soil%ndhvtss, soil%ndhftss, &
                   soil%ndhvtts, soil%ndhftts, soil%ndhvtis, soil%ndhftis, &
                   soil%ndhvsss, soil%ndhfsss, soil%ndhviis, soil%ndhfiis, soil%ndhvwls, soil%ndhfwls]
    radiation_interval = radiation%nradfr
    status = 0_int32
  end function
end module
