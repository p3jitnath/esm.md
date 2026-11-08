!> Bind the complete slow-physics child to the one canonical work-record set.
!! This wrapper borrows named native array views; it adds no numerical stage.
module forecast_slow_physics_layer
  use iso_fortran_env, only: int32, int64, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_physics_work_types, only: dimension_type, state_type, aux_type, surf_and_more_type
  use yomphyder, only: model_state_type
  use forecast_slow_physics_averaging, only: sltend
  implicit none
  private
  public :: sltend_layer
contains
  !> Pass source pressure, state, previous-change and tendency views directly.
  !! The caller retains all owners. Saved-rate and constituent arrays are INOUT
  !! real64(P,L,C), with wind/temperature C3:64 and constituents C0:64.
  !! RSLWX is the live L-element readonly averaging-weight owner, dimensionless.
  !! Current/initial step come from the actual root clock, without a clock copy.
  !! Pressure uses Pa, temperature K, winds m/s, water kg/kg and rates per second.
  subroutine sltend_layer(physical, thermal, current_step, initial_step, rslwx, &
                          model, d, aux, state_t0, tendency_dyn, tendency_vdf, tendency_satadj, tendency_cml, &
                          previous, psavtend, pgflslp, surface, tendency_loc, status)
    type(forecast_physical_constants), intent(in) :: physical
    type(thermal_parameter_record), intent(in) :: thermal
    integer(int32), intent(in) :: current_step, initial_step
    real(real64), intent(in) :: rslwx(:)
    type(native_operational_model_configuration), intent(in) :: model
    type(dimension_type), intent(in) :: d
    type(aux_type), intent(in) :: aux
    type(state_type), intent(in) :: state_t0, tendency_dyn, tendency_vdf, tendency_satadj, tendency_cml
    type(model_state_type), intent(in) :: previous
    real(real64), intent(inout) :: psavtend(:, :, :), pgflslp(:, :, :)
    type(surf_and_more_type), intent(inout) :: surface
    type(state_type), intent(inout) :: tendency_loc
    integer(int32), intent(out) :: status
    real(real64), target :: empty_extra_storage(0)
    real(real64), pointer :: extra(:, :, :)
    integer(int32) :: p, l, ktend, tracers
    status = 2
    p = d%klon; l = d%klev
    if (d%kidia /= 1 .or. p < 0 .or. p > 4096 .or. l < 0 .or. l > 512) return
    if (d%kfdia < 0 .or. d%kfdia > p .or. d%kfldx < 0 .or. d%kfldx > 128) return
    ktend = size(psavtend, 3); tracers = model%fields%registration%ndimslp
    if (ktend < 3 .or. ktend > 64 .or. tracers < 0 .or. tracers > 64) return
    if (.not. is_contiguous(psavtend) .or. .not. is_contiguous(pgflslp)) return
    if (any(shape(psavtend) /= [p, l, ktend])) return
    if (any(shape(pgflslp) /= [p, l, tracers])) return
    if (.not. associated(state_t0%t)) return
    if (.not. associated(state_t0%q)) return
    if (.not. associated(state_t0%a)) return
    if (.not. associated(state_t0%cld)) return
    if (.not. associated(aux%prsf1)) return
    if (.not. associated(aux%prs1)) return
    if (.not. associated(tendency_dyn%u)) return
    if (.not. associated(tendency_dyn%v)) return
    if (.not. associated(tendency_dyn%t)) return
    if (.not. associated(tendency_dyn%q)) return
    if (.not. associated(tendency_dyn%o3)) return
    if (.not. associated(tendency_dyn%a)) return
    if (.not. associated(tendency_dyn%cld)) return
    if (.not. associated(tendency_cml%u)) return
    if (.not. associated(tendency_cml%v)) return
    if (.not. associated(tendency_cml%t)) return
    if (.not. associated(tendency_cml%q)) return
    if (.not. associated(tendency_cml%o3)) return
    if (.not. associated(tendency_cml%a)) return
    if (.not. associated(tendency_cml%cld)) return
    if (.not. associated(tendency_loc%u)) return
    if (.not. associated(tendency_loc%v)) return
    if (.not. associated(tendency_loc%t)) return
    if (.not. associated(tendency_loc%q)) return
    if (.not. associated(tendency_loc%o3)) return
    if (.not. associated(tendency_loc%a)) return
    if (.not. associated(tendency_loc%cld)) return
    if (.not. associated(previous%u)) return
    if (.not. associated(previous%v)) return
    if (.not. associated(previous%t)) return
    if (.not. associated(previous%gfl)) return
    if (.not. associated(tendency_vdf%u)) return
    if (.not. associated(tendency_vdf%v)) return
    if (.not. associated(tendency_vdf%t)) return
    if (.not. associated(tendency_vdf%q)) return
    if (.not. associated(tendency_vdf%a)) return
    if (.not. associated(tendency_satadj%t)) return
    if (.not. associated(tendency_satadj%q)) return
    if (.not. associated(tendency_satadj%a)) return
    if (.not. associated(tendency_satadj%cld)) return
    ! The original unused diagnostic argument admits an absent empty owner.
    ! This zero-payload native view preserves that case without allocation.
    if (d%kfldx == 0) then
      if (associated(surface%psd_xa)) then
        if (size(surface%psd_xa, 1) /= p .or. .not. is_contiguous(surface%psd_xa)) return
        if (size(surface%psd_xa, 2) /= l .and. size(surface%psd_xa, 2) /= 1) return
        if (size(surface%psd_xa, 3) /= 0) then
          if (size(surface%psd_xa, 2) /= 1 .or. size(surface%psd_xa, 3) /= 1) return
        end if
      end if
      extra(1:p, 1:l, 1:0) => empty_extra_storage
    else
      if (.not. associated(surface%psd_xa)) return
      if (any(shape(surface%psd_xa) /= [p, l, d%kfldx])) return
      if (.not. is_contiguous(surface%psd_xa)) return
      extra => surface%psd_xa
    end if
    call sltend(physical, thermal, current_step, initial_step, rslwx, model, &
                d%kidia, d%kfdia, p, l, ktend, &
                state_t0%t, state_t0%q, state_t0%a, state_t0%cld, aux%prsf1, aux%prs1, &
                tendency_dyn%u, tendency_dyn%v, tendency_dyn%t, tendency_dyn%q, tendency_dyn%o3, tendency_dyn%a, tendency_dyn%cld, &
                tendency_cml%u, tendency_cml%v, tendency_cml%t, tendency_cml%q, tendency_cml%o3, tendency_cml%a, tendency_cml%cld, &
                tendency_loc%u, tendency_loc%v, tendency_loc%t, tendency_loc%q, tendency_loc%o3, tendency_loc%a, tendency_loc%cld, &
                previous%u, previous%v, previous%t, previous%gfl, &
                tendency_vdf%u, tendency_vdf%v, tendency_vdf%t, tendency_vdf%q, tendency_vdf%a, &
                tendency_satadj%t, tendency_satadj%q, tendency_satadj%a, tendency_satadj%cld, &
                psavtend, pgflslp, extra, d%kfldx, status)
  end subroutine
end module forecast_slow_physics_layer
