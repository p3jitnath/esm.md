!> Produce the source-defined controls used before output and Fullpos setup.
!! The final target record owns strings and scalar values; it owns no heap arrays.
module forecast_output_setup_upstream
  use iso_fortran_env, only: int32
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_remaining_dynamics_controls, only: native_remaining_dynamics_controls
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_output_setup_upstream, initialize_native_output_setup_upstream

  !> Own a bounded subset of SUOPH0, SU0YOMA and SUDYN source outputs.
 !! Names contain source blank padding. Counts and switches are dimensionless.
 !! NPRINTLEV is copied from the same actual input used by initial geometry.
 !! READY describes this native constructor; it is not a scientific control.
  type :: native_output_setup_upstream
    integer(int32) :: nprintlev, nsatsim
    logical :: lnodryflx
    character(200) :: cfpath
    character(210) :: cfnsh, cfngg, cfnua
    character(256) :: cfnclimout
    character(8) :: cfpextsfx
    logical :: ready = .false.
  end type
contains
  !> Publish the admitted actual forecast branch without changing its model.
 !! TEXT is the same1:262144-character configuration read by the model.
 !! MODEL is the produced canonical operational model and is read only.
 !! REMAINING_DYNAMICS is its produced remaining SUDYN control owner. Its
 !! readiness follows the admitted NAMDYN grammar, which cannot set LNODRYFLX.
 !! NPRINTLEV is nonnegative and is the original initial-geometry caller input.
 !! OUTPUT stays at the caller's final TARGET address. Readonly consumers may
 !! borrow its fields until that owner is released. This routine retains no view.
 !! Status0 writes every named output and then READY. Status2 preserves OUTPUT.
  integer(int32) function initialize_native_output_setup_upstream(text, model, remaining_dynamics, nprintlev, output) result(status)
    character(*), intent(in) :: text
    type(native_operational_model_configuration), intent(in) :: model
    type(native_remaining_dynamics_controls), intent(in) :: remaining_dynamics
    integer(int32), intent(in) :: nprintlev
    type(native_output_setup_upstream), intent(inout) :: output
    character(4) :: experiment
    status = 2_int32
    if (output%ready) return
    if (len(text) < 1 .or. len(text) > 262144) return
    if (nprintlev < 0) return
    if (.not. model%ready) return
    if (.not. associated(model%initial)) return
    if (.not. model%initial%ready) return
    if (model%initial%controls%namespace%nconf /= 1_int32) return
    if (model%initial%controls%namespace%lobsc1 /= 0_int32) return
    if (.not. remaining_dynamics%ready) return
    status = require_empty_physics_group(text, 'NAMOPH')
    if (status /= 0_int32) return

    experiment = model%initial%controls%namespace%cnmexp(1:4)
    ! SUOPH0 establishes these defaults before the admitted empty NAMOPH.
    output%cfpath = './'
    output%cfnclimout = 'const.clim.'
    output%cfpextsfx = '.sfx'
    ! Empty NAMOPH retains the two-character path; fixed slices need no heap temporary.
    ! The spectral name includes that path; the two grid names do not.
    output%cfnsh = output%cfpath(1:2)//'ICMSH'//experiment//'0000'//'   '
    output%cfngg = 'ICMGG'//experiment//'0000'//'   '
    output%cfnua = 'ICMUA'//experiment//'0000'//'   '
    ! SU0YOMA assigns this count only in the admitted NCONF1/LOBSC1-false branch.
    output%nsatsim = 0_int32
    output%nprintlev = nprintlev
    ! SUDYN defines this switch before NAMDYN; the admitted reader cannot alter it.
    output%lnodryflx = .false.
    output%ready = .true.
    status = 0_int32
  end function
end module forecast_output_setup_upstream
