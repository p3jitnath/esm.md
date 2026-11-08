! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Bind canonical physics work views to the owned native surface calculations.
!! Inputs and work records stay at their caller-owned TARGET addresses.
!! Fields keep the source units and active cell interval. No payload is copied.
module forecast_native_surface_layers
  use iso_fortran_env, only: int32, int64, real64
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use forecast_physics_work_types, only: dimension_type, aux_type, keys_local_type, surf_and_more_type, &
                                         surf_and_more_local_type, state_type, aux_diag_local_type, flux_type, ddh_surf_type
  implicit none
  private
  public :: callpar_surface_boundary, callpar_snow_initialization, callpar_surface_radiation, callpar_surface_time_update
  interface
    module subroutine callpar_surface_boundary(inputs, d, aux, keys, surface, surfl, status)
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
      type(dimension_type), intent(in) :: d
      type(aux_type), intent(in) :: aux
      type(keys_local_type), intent(inout) :: keys
      type(surf_and_more_type), intent(inout) :: surface
      type(surf_and_more_local_type), intent(inout) :: surfl
      integer(int32), intent(out) :: status
    end subroutine
    module subroutine callpar_snow_initialization(inputs, d, surface, surfl, aux, status)
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
      type(dimension_type), intent(in) :: d
      type(surf_and_more_type), intent(inout) :: surface
      type(surf_and_more_local_type), intent(inout) :: surfl
      type(aux_type), intent(in) :: aux
      integer(int32), intent(out) :: status
    end subroutine
    module subroutine callpar_surface_radiation(inputs, d, aux, tmp, keys, auxl, surface, surfl, status)
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
      type(dimension_type), intent(in) :: d
      type(aux_type), intent(in) :: aux
      type(state_type), intent(in) :: tmp
      type(keys_local_type), intent(inout) :: keys
      type(aux_diag_local_type), intent(inout) :: auxl
      type(surf_and_more_type), intent(inout) :: surface
      type(surf_and_more_local_type), intent(inout) :: surfl
      integer(int32), intent(out) :: status
    end subroutine
    module subroutine callpar_surface_time_update(inputs, d, state0, aux, surface, surfl, keys, flux, pddhs, status)
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
      type(dimension_type), intent(in) :: d
      type(state_type), intent(in) :: state0
      type(aux_type), intent(in) :: aux
      type(surf_and_more_type), intent(inout) :: surface
      type(surf_and_more_local_type), intent(inout) :: surfl
      type(keys_local_type), intent(inout) :: keys
      type(flux_type), intent(inout) :: flux
      type(ddh_surf_type), intent(inout) :: pddhs
      integer(int32), intent(out) :: status
    end subroutine
  end interface
end module
