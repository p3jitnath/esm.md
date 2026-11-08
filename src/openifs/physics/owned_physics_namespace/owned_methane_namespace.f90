!> Establish fresh source storage through the canonical methane record.
module forecast_owned_methane_namespace
  use iso_fortran_env, only: int32, real64
  use ecmwf_physics_tail_fields_mod, only: methane_oxidation_parameter_record
  implicit none
  private
  public :: methane_oxidation_parameter_record, initialize_fresh_methane_namespace
contains
  !> Write only the source zero-born named values before the physical producer.
 !! STATE is the existing caller-owned record, never a copied live namespace.
 !! Invoke this once at fresh allocation, before any source setup or consumer.
  integer(int32) function initialize_fresh_methane_namespace(state) result(status)
    type(methane_oxidation_parameter_record), intent(inout) :: state
    state%ralpha1 = 0.0_real64
    state%ralpha2 = 0.0_real64
    state%rqlim = 0.0_real64
    state%rpbotox = 0.0_real64
    state%rpbotph = 0.0_real64
    state%rptopox = 0.0_real64
    state%rptopph = 0.0_real64
    state%ralpha3 = 0.0_real64
    state%rlogpph = 0.0_real64
    status = 0
  end function
end module
