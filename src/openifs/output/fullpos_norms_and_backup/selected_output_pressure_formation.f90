!> Reuse the canonical generated hybrid-pressure calculation in Fullpos.
module forecast_fullpos_pressure_formation
  use iso_fortran_env, only: int32, real64
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  implicit none
  private
  public :: hybrid_pressure_controls, output_gphpre
contains
  !> Forward all source branches and optional products to the unchanged provider.
 !! A_HALF/B_HALF are pressure Pa and dimensionless values at levels0:L-1.
 !! HALF_PRESSURE(P,0:L) mutates its active rows; its surface row is borrowed.
 !! Optional coefficients retain the source field ordering and full pressure Pa.
 !! All owners and their disjoint active sections remain with the caller.
 subroutine output_gphpre(c,pitch,first,last,levels,a_half,b_half,half_pressure,status,number_fields,field_index,vc,full_a,full_b,delta_a,delta_b,coefficients,full_pressure)
    type(hybrid_pressure_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    real(real64), intent(in) :: a_half(0:), b_half(0:)
    real(real64), intent(inout) :: half_pressure(:, 0:)
    integer(int32), intent(out) :: status
    integer(int32), optional, intent(in) :: number_fields, field_index(:)
    real(real64), optional, intent(in) :: vc(1:), full_a(1:), full_b(1:), delta_a(1:), delta_b(1:)
    real(real64), optional, intent(inout) :: coefficients(:, :, :), full_pressure(:, :)
 call compute_hybrid_pressure_one_based(c,pitch,first,last,levels,a_half,b_half,half_pressure,status,number_fields,field_index,vc,full_a,full_b,delta_a,delta_b,coefficients,full_pressure)
  end subroutine
end module
