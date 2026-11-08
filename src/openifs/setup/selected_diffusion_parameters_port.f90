module selected_diffusion_parameters_port
  !! Build the selected SUVDF parameters in a caller-owned native TVDF.
  !! Contract: skills/md2asm/references/openifs/setup/selected_diffusion_parameters.md.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use yoevdf, only: tvdf
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_selected_diffusion_parameters, initialize_operational_diffusion_parameters
contains
  integer(int32) function initialize_selected_diffusion_parameters(text, output) result(status)
    !! text holds 1 to 262144 configuration bytes. Both first uppercase
    !! NAMVDF and NAMDYNCORE groups must be empty. output is a complete,
    !! disjoint native owner; the compiler supplies its alignment and layout.
    !! RLAM is a length in metres and REISTHSC is a temperature in kelvin.
    !! The remaining real coefficients are dimensionless; NSUBST counts substeps.
    !! Refusal changes no output. Success preserves fields that the source
    !! leaves unwritten, including compiler padding. The caller supplies FPCR
    !! zero, round-to-nearest and gradual underflow. No original state is read.
    character(len=*), intent(in) :: text
    type(tvdf), intent(inout) :: output
    real(real64), volatile :: rusplrg, rplrg
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    status = require_empty_physics_group(text, 'NAMVDF')
    if (status /= 0_int32) return
    status = require_empty_physics_group(text, 'NAMDYNCORE')
    if (status /= 0_int32) return
    ! Keep both source divisions live despite the selected unit operand.
    rusplrg = 1.0_real64
    rplrg = 1.0_real64/rusplrg
    output%rlam = 150.0_real64/rplrg
    output%rvdifts = transfer(int(z'3FF8000000000000', int64), 0.0_real64)
    output%lwds = .false.
    output%reps1wds = transfer(int(z'40122F92041E92A0', int64), 0.0_real64)
    output%reps2wds = transfer(int(z'3FF482F4BC842D15', int64), 0.0_real64)
    output%retawds = transfer(int(z'400B504F333F9DE6', int64), 0.0_real64)
    output%rtofdalpha = transfer(int(z'4038000000000000', int64), 0.0_real64)
    output%reisthsc = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%nsubst = 1_int32
    status = 0_int32
  end function
  integer(int32) function initialize_operational_diffusion_parameters(text, output, rplrg) result(status)
    !! The forecast caller supplies the already parsed, dimensionless RPLRG.
    !! This frozen operational route admits its exact unit value. It requires
    !! empty NAMVDF and leaves the upstream NAMDYNCORE group to its owner.
    !! Units, status, ownership and rounding preconditions match the selected entry.
    character(len=*), intent(in) :: text
    type(tvdf), intent(inout) :: output
    real(real64), intent(in) :: rplrg
    real(real64), volatile :: divisor
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (transfer(rplrg, 0_int64) /= int(z'3FF0000000000000', int64)) return
    status = require_empty_physics_group(text, 'NAMVDF')
    if (status /= 0_int32) return
    divisor = rplrg
    output%rlam = 150.0_real64/divisor
    output%rvdifts = transfer(int(z'3FF8000000000000', int64), 0.0_real64)
    output%lwds = .false.
    output%reps1wds = transfer(int(z'40122F92041E92A0', int64), 0.0_real64)
    output%reps2wds = transfer(int(z'3FF482F4BC842D15', int64), 0.0_real64)
    output%retawds = transfer(int(z'400B504F333F9DE6', int64), 0.0_real64)
    output%rtofdalpha = transfer(int(z'4038000000000000', int64), 0.0_real64)
    output%reisthsc = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%nsubst = 1_int32
    status = 0_int32
  end function
end module selected_diffusion_parameters_port
