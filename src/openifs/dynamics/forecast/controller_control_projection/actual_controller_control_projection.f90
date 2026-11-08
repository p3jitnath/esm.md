!> Copy produced dimensionless controls into the actual forecast controllers.
!! This module owns no model, weather array, clock or configuration defaults.
module forecast_actual_controller_control_projection
  use iso_fortran_env, only: int32
  use forecast_native_execution_state, only: native_forecast_execution_state
  implicit none
  private
  public :: project_actual_controller_controls
contains
  !> Publish only named scalar controls after the real setup has completed.
 !! STATE is the caller-owned execution record, with INOUT intent. Its
 !! phase70 or later proves that diagnostic, stochastic, flux and output
 !! setup succeeded in source order. Each retained target stays in STATE.
 !! Status2 refuses before any write; status0 publishes all named controls.
 !! This routine reads no source-unwritten separation or iteration flag.
  integer(int32) function project_actual_controller_controls(state) result(status)
    type(native_forecast_execution_state), intent(inout) :: state
    status = 2_int32
    if (state%phase < 70_int32) return
    if (.not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial)) return
    if (.not. state%startup%initial%ready) return
    if (.not. allocated(state%startup%initial%geometry)) return
    if (.not. state%startup%initial%geometry%initialized) return
    if (.not. allocated(state%startup%loaded%storage)) return
    if (.not. state%startup%loaded%storage%model%ready) return
    if (.not. state%remaining%ready) return
    if (.not. state%variational_control%ready) return
    if (.not. state%spectral_setup%ready) return
    if (.not. state%spectral_setup%context%ready) return
    if (.not. state%output_setup%ready) return
    if (.not. state%output_file_metadata%ready) return
    if (.not. allocated(state%fullpos)) return
    state%step_controls%lnsponge = state%lnsponge
    state%step_controls%lspsdt = state%sppt_configuration%lspsdt
    state%step_controls%lspp = state%spp_configuration%lspp
    state%step_controls%lrddhdyn = state%diagnostic_controls%lrddhdyn
    state%step_controls%lrhdddh = state%diagnostic_controls%lrhdddh
    state%step_controls%lsidg = state%spectral_setup%reference%lsidg
    state%step_controls%lstrhd = state%remaining%lstrhd
    state%step_controls%nsiter = state%remaining%nsiter
    state%loop_controls%ljcdfi = state%startup%initial%initialization%ljcdfi /= 0
    state%loop_controls%ldfi = state%startup%initial%initialization%ldfi /= 0
    state%loop_controls%lscrini = state%startup%initial%initialization%lscrini /= 0
    state%loop_controls%locedelay = state%output_common%locedelay
    state%loop_controls%nsim4d = state%variational_control%nsim4d
    state%loop_controls%lmasdry = state%remaining%lmasdry
    state%loop_controls%ldgpmascor = state%remaining%lgpmascor
    state%loop_controls%lxfu = state%flux_controls%xfu%lxfu
    state%loop_controls%lcumfu = state%flux_controls%cfu%lcumfu
    state%loop_controls%lchem_dia = state%composition%lchem_dia
    state%loop_controls%lstoph_casbs = state%stochastic_physics%lstoph_casbs
    state%loop_controls%lstoph_spbs = state%stochastic_physics%lstoph_spbs
    state%step%output%nconf = state%startup%initial%controls%namespace%nconf
    state%step%output%nproc = state%startup%initial%geometry%transform_control%nproc
    state%step%output%lelam = state%startup%initial%controls%namespace%lelam /= 0
    state%step%output%larpegef = state%startup%initial%controls%namespace%larpegef /= 0
    state%step%output%lecfpos = state%startup%initial%controls%namespace%lecfpos /= 0
    state%step%output%ltlevol = state%startup%loaded%storage%model%physics%linear_ecmwf%ltlevol
    state%step%output%hook_enabled = state%hook_control%enabled
    status = 0_int32
  end function
end module
