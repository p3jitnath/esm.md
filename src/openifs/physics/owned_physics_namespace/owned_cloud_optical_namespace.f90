!> Establish fresh source storage through the canonical cloud_optical record.
module forecast_owned_cloud_optical_namespace
  use iso_fortran_env, only: int32, real64
  use cloud_optical_parameter_fields_mod, only: cloud_optical_550_parameter_record
  implicit none
  private
  public :: cloud_optical_550_parameter_record, initialize_fresh_cloud_optical_namespace
contains
  !> Write only the source zero-born named values before the physical producer.
 !! STATE is the existing caller-owned record, never a copied live namespace.
 !! Invoke this once at fresh allocation, before any source setup or consumer.
  integer(int32) function initialize_fresh_cloud_optical_namespace(state) result(status)
    type(cloud_optical_550_parameter_record), intent(inout) :: state
    state%rsa55 = 0.0_real64
    state%rsb55 = 0.0_real64
    state%rsc55 = 0.0_real64
    state%rsd55 = 0.0_real64
    state%rfa55 = 0.0_real64
    status = 0
  end function
end module
