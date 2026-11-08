!> Establish fresh source storage through the canonical land_surface_reference record.
module forecast_owned_land_surface_reference_namespace
  use iso_fortran_env, only: int32, real64
  use land_surface_reference_setup_port, only: land_surface_reference_record
  implicit none
  private
  public :: land_surface_reference_record, initialize_fresh_land_surface_reference_namespace
contains
  !> Write only the source zero-born named values before the physical producer.
 !! STATE is the existing caller-owned record, never a copied live namespace.
 !! Invoke this once at fresh allocation, before any source setup or consumer.
  integer(int32) function initialize_fresh_land_surface_reference_namespace(state) result(status)
    type(land_surface_reference_record), intent(inout) :: state
    state%smask = 0.0_real64
    state%smanq = 0.0_real64
    state%ntpmer = 0_int32
    state%ntpgla = 0_int32
    state%ntpdes = 0_int32
    state%ntplac = 0_int32
    state%szz0n = 0.0_real64
    state%szz0m = 0.0_real64
    state%szz0b = 0.0_real64
    state%szz0u = 0.0_real64
    state%szz0d = 0.0_real64
    state%sther = 0.0_real64
    state%salbn = 0.0_real64
    state%salbx = 0.0_real64
    state%salbm = 0.0_real64
    state%salbg = 0.0_real64
    state%salbb = 0.0_real64
    state%salbd = 0.0_real64
    state%semin = 0.0_real64
    state%semix = 0.0_real64
    state%semim = 0.0_real64
    state%semig = 0.0_real64
    state%semib = 0.0_real64
    state%semid = 0.0_real64
    state%sdepn = 0.0_real64
    state%sdepx = 0.0_real64
    state%sdepd = 0.0_real64
    state%sargn = 0.0_real64
    state%sargx = 0.0_real64
    state%sargd = 0.0_real64
    state%ssabn = 0.0_real64
    state%ssabx = 0.0_real64
    state%ssabd = 0.0_real64
    state%srsmx = 0.0_real64
    state%srsmn = 0.0_real64
    state%srsmd = 0.0_real64
    status = 0
  end function
end module
