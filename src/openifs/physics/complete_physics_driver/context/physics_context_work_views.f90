! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Bind native state and parameter work views for one physics block.
module forecast_physics_context_work_views
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use stoph_mix, only: tstoph
  use forecast_complete_physics_context_types, only: native_complete_physics_context
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  use forecast_physics_perturbation_views, only: native_cellular_perturbation_views, update_perturbation_views
  use forecast_auxiliary_work_record, only: update_auxiliary_work_views
  use forecast_radiation_work_record, only: update_radiation_work_views
  use forecast_surface_work_record, only: update_surface_work_views
  use forecast_additional_physics_work_records, only: update_flux_work_views, update_auxiliary_diagnostic_work_views, &
                                               update_surface_diagnostic_work_views, update_auxiliary_diagnostic_local_work_views, &
                                                      update_surface_local_work_views, update_keys_local_work_views
  use forecast_physics_field_views, only: physics_field_view_2d, physics_field_view_3d
  use physics_grid_dimension_helpers_mod, only: update_physics_dimensions
  use physics_context_helper_counters_mod, only: increment_context_helper_count
  implicit none
  private
  public :: physics_storage_work_views, update_physics_context_block
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine abort_context_failure() bind(c, name="abort")
    end subroutine
  end interface
contains
  !> Select source views in the original dimension, surface, AUX, RAD, perturbation
  !! and local-work order. LATITUDE is the actual borrowed integer index view.
  !! Counts are dimensionless. Numerical weather owners are never changed.
  !! The four final local perturbation calls deliberately omit the separate
  !! gravity-wave zero stage. Status0 succeeds; a provider refusal retains
  !! earlier source associations and is returned after preserving IEEE/errno.
  integer(int32) function physics_storage_work_views(context, stoph, lspsdt, lspp, cellular, forcing, &
                                                     block, active, global_start, latitude) result(status)
    type(native_complete_physics_context), target, intent(inout) :: context
    type(tstoph), target, intent(inout) :: stoph
    logical, intent(in) :: lspsdt, lspp
    type(native_cellular_perturbation_views), intent(in) :: cellular
    type(native_physics_runtime_data), target, intent(inout) :: forcing
    integer(int32), intent(in) :: block, active, global_start
    integer(int32), pointer, intent(in) :: latitude(:)
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    status = 2
    if (.not. associated(context%records%geometry)) return
    if (.not. associated(context%records%dimensions)) return
    if (.not. associated(context%records%surface)) return
    if (.not. associated(context%records%auxiliary)) return
    if (.not. associated(context%records%radiation)) return
    if (.not. associated(context%records%perturbation)) return
    if (.not. associated(context%records%flux)) return
    if (.not. associated(context%records%diagnostics)) return
    if (.not. associated(context%records%surface_diagnostics)) return
    if (.not. associated(context%records%auxiliary_local)) return
    if (.not. associated(context%records%surface_local)) return
    if (.not. associated(context%records%keys)) return
    if (.not. associated(context%records%perturbation_local)) return
    call increment_context_helper_count(3, 1)
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    status = update_physics_dimensions(context%records%dimensions, block, active, global_start, latitude)
    if (status /= 0) goto 900
    status = update_surface_work_views(context%records%surface, block)
    if (status /= 0) goto 900
    status = update_auxiliary_work_views(context%records%auxiliary, block)
    if (status /= 0) goto 900
    status = update_radiation_work_views(context%records%radiation, block)
    if (status /= 0) goto 900
    status = update_perturbation_views(context%records%perturbation, stoph, lspsdt, lspp, cellular, block, &
                                       global_start, active, context%records%geometry%dimensions%nproma, &
                                       context%records%geometry%dimensions%nflevg, forcing)
    if (status /= 0) goto 900
    status = update_flux_work_views(context%records%flux, block)
    if (status /= 0) goto 900
    status = update_auxiliary_diagnostic_work_views(context%records%diagnostics, block)
    if (status /= 0) goto 900
    status = update_surface_diagnostic_work_views(context%records%surface_diagnostics, block)
    if (status /= 0) goto 900
    status = update_auxiliary_diagnostic_local_work_views(context%records%auxiliary_local, block)
    if (status /= 0) goto 900
    status = update_surface_local_work_views(context%records%surface_local, block)
    if (status /= 0) goto 900
    status = update_keys_local_work_views(context%records%keys, block)
    if (status /= 0) goto 900
    if (.not. associated(context%records%perturbation_local%f_zwmean)) then
      status = 2; goto 900
    end if
    status = physics_field_view_2d(context%records%perturbation_local%zwmean, &
                                   context%records%perturbation_local%f_zwmean, block)
    if (status /= 0) goto 900
    if (.not. associated(context%records%perturbation_local%f_zdisscu)) then
      status = 2; goto 900
    end if
    status = physics_field_view_3d(context%records%perturbation_local%zdisscu, &
                                   context%records%perturbation_local%f_zdisscu, block)
    if (status /= 0) goto 900
    if (.not. associated(context%records%perturbation_local%f_zcuconvca)) then
      status = 2; goto 900
    end if
    status = physics_field_view_2d(context%records%perturbation_local%zcuconvca, &
                                   context%records%perturbation_local%f_zcuconvca, block)
    if (status /= 0) goto 900
    if (.not. associated(context%records%perturbation_local%f_zdissgw)) then
      status = 2; goto 900
    end if
    status = physics_field_view_3d(context%records%perturbation_local%zdissgw, &
                                   context%records%perturbation_local%f_zdissgw, block)
    if (status /= 0) goto 900
    context%last_block = block; context%block_open = .true.
900 continue
    call ieee_set_status(incoming_status); errno_word = incoming_errno
  end function physics_storage_work_views

  !> Native source boundary: abort when an admitted work-view provider fails.
  subroutine update_physics_context_block(context, stoph, lspsdt, lspp, cellular, forcing, block, active, global_start, latitude)
    type(native_complete_physics_context), target, intent(inout) :: context
    type(tstoph), target, intent(inout) :: stoph
    logical, intent(in) :: lspsdt, lspp
    type(native_cellular_perturbation_views), intent(in) :: cellular
    type(native_physics_runtime_data), target, intent(inout) :: forcing
    integer(int32), intent(in) :: block, active, global_start
    integer(int32), pointer, intent(in) :: latitude(:)
    integer(int32) :: status
    status = physics_storage_work_views(context, stoph, lspsdt, lspp, cellular, forcing, block, active, global_start, latitude)
    if (status /= 0) call abort_context_failure()
  end subroutine update_physics_context_block
end module forecast_physics_context_work_views
