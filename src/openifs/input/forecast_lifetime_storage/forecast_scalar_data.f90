!> Own source scalar defaults without reloading original module globals.
module forecast_native_scalar_data
  use iso_fortran_env, only: int32, real64
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use forecast_native_loop_data, only: native_loop_data
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_forecast_scalar_data, owned_forecast_scalar_data, initialize_selected_forecast_scalar_data
  type native_forecast_scalar_data
    integer(int32) :: cpl_nemo_lim, nimp, nout
    real(real64) :: rmdi
    logical :: lsldebug, lsplitout
    integer(int32) :: my_region_ew
    logical :: lnots_t, lrppuv_callitpq, lrppuv_cstext
    logical :: ltrajsave, ltrajslag, ltrajsave_oops, ltrajslag_oops
    logical :: ltwgra, ltwinc, ltwbgv, ltwcgl, lsfcflx
    real(real64) :: rextlhf, rextshf
    integer(int32) :: n_vmass
  end type
  type(native_forecast_scalar_data), save, target :: owned_forecast_scalar_data = native_forecast_scalar_data( &
                                                     0, 0, 0, 0.0_real64, .false., .false., 0, .false., .false., .false., &
                         .false., .false., .false., .false., .false., .false., .false., .false., .false., 0.0_real64, 0.0_real64, 0)
contains
!> Require source serial controls and empty NAMPPVI, then assign every named scalar.
!! CPLNG_ACTIVE is the borrowed TMCC switch. PROCESS_COUNT is the actual live world size.
!! Read-only controls, loop metadata and text remain unchanged. No array is allocated.
  integer(int32)function initialize_selected_forecast_scalar_data(text,controls,loop,cplng_active,process_count,state)result(status)
  character(*), intent(in) :: text
  type(native_forecast_control_namespace), intent(in) :: controls
  type(native_loop_data), intent(in) :: loop
  logical, intent(in) :: cplng_active
  integer(int32), intent(in) :: process_count
  type(native_forecast_scalar_data), intent(inout) :: state
  status = 2
  if (len(text) < 1 .or. len(text) > 262144) return
  if (controls%nconf /= 1 .or. controls%larpegef /= 0 .or. controls%lelam /= 0 .or. controls%lecmwf /= 1) return
  if (controls%loldpp < 0 .or. controls%loldpp > 1 .or. controls%lfdbop /= 0) return
  if (loop%owned_mask /= 15 .or. loop%nouttype /= 1) return
  if (cplng_active .or. process_count /= 1) return
  status = require_empty_physics_group(text, 'NAMPPVI')
  if (status /= 0) return
  state%cpl_nemo_lim = 0; state%nimp = 0; state%nout = 0
  state%rmdi = 0.0_real64; state%lsldebug = .false.; state%lsplitout = .false.
  state%my_region_ew = 1; state%lnots_t = .false.; state%lrppuv_callitpq = controls%loldpp /= 0
  state%lrppuv_cstext = .false.
  state%ltrajsave = .false.; state%ltrajslag = .false.
  state%ltrajsave_oops = .false.; state%ltrajslag_oops = .false.
  state%ltwgra = .false.; state%ltwinc = .false.; state%ltwbgv = .false.; state%ltwcgl = .false.
  state%lsfcflx = .false.; state%rextlhf = 0.0_real64; state%rextshf = 0.0_real64
  state%n_vmass = -1
  status = 0
  end function
end module
