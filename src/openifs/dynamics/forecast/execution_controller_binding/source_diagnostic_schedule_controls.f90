!> Produce the five source DDH schedule flags for the admitted empty group.
!! This support entry owns no diagnostic field, table or MODEL namespace.
module forecast_source_diagnostic_schedule_controls
  use iso_fortran_env, only: int32
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use forecast_operational_schedule, only: forecast_stage_controls
  implicit none
  private
  public :: project_empty_source_diagnostic_schedule
contains
  !> Borrow configuration bytes and replace only the five named schedule flags.
  !! TEXT contains1 to262144 unchanged source bytes. STAGES is a persistent
  !! controller record; its other members remain unchanged. All flags are
  !! dimensionless. The first exact NAMDDH group must be empty, as required
  !! by the actual native CPG route. A refusal returns2 without any store.
  !! SUNDDH initializes its component switches, reads this empty group,
  !! then derives LSDDH and LHDPR with the original logical expressions.
  !! Status0 means these five source controls were produced. It does not
  !! mean that a diagnostic calculation or the complete SUNDDH was executed.
  integer(int32) function project_empty_source_diagnostic_schedule(text, stages) result(status)
    character(*), intent(in) :: text
    type(forecast_stage_controls), intent(inout) :: stages
    logical :: lhdglb, lhdzon, lhddop, lhdprg, lhdprz, lhdprd
    logical :: lsddh, lhdpr, lhdefg, lhdefz, lhdefd
    status = require_empty_physics_group(text, 'NAMDDH')
    if (status /= 0) return
    ! Source SUNDDH237:252 stores before its unchanged empty NAMDDH read.
    lhdglb = .false.; lhdzon = .false.; lhddop = .false.
    lhdprg = .false.; lhdprz = .false.; lhdprd = .false.
    lhdefg = .false.; lhdefz = .false.; lhdefd = .false.
    ! Source SUNDDH775:776 derives both combined control words.
    lsddh = lhdglb .or. lhdzon .or. lhddop
    lhdpr = lhdprg .or. lhdprz .or. lhdprd
    stages%lsddh = lsddh; stages%lhdpr = lhdpr
    stages%lhdefg = lhdefg; stages%lhdefz = lhdefz; stages%lhdefd = lhdefd
    status = 0
  end function
end module forecast_source_diagnostic_schedule_controls
