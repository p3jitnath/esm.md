!> Native metadata for the owned selected and runtime tracer correction.
module forecast_tracer_mass_correction_types
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls
  implicit none
  private
  public :: tracer_mass_grid, tracer_mass_layout
  type :: tracer_mass_grid
    integer(int32) :: columns = 0, levels = 0, blocks = 0, active_count = 0
    integer(int32) :: source_pitch = 0, first_plane = 0, last_plane = -1
    integer(int32) :: transform = 0, process_count = 0, communicator = 0
    real(real64) :: gravity = 0.0_real64
    real(real64), pointer :: a_half(:) => null(), b_half(:) => null(), quadrature(:, :) => null()
    type(hybrid_pressure_controls) :: pressure_controls
  end type
  type :: tracer_mass_layout
    integer(int32) :: weight_fields = 0, m_wdlo = 0, m_wdlat = 0, m_wdver = 0
    integer(int32) :: source_fields = 0, mslb1gfl9 = 0
    integer(int32) :: motion_surface_fields = 0, msp0 = 0, predicted_surface_fields = 0, msp1 = 0
    integer(int32) :: ngpmascor = 0
    logical :: lcomad_gfl = .false.
  end type
! Counts and weights have no units. Gravity is m s**(-2); A is Pa, B and
! quadrature are dimensionless. All pointer members borrow live read-only
! native owners. Their first A/B elements name half level0. The caller owns
! a matching initialized public ECTRANS/FIAT/MPI context. Default zero values
! express an unprepared record, not a physical configuration.
end module
