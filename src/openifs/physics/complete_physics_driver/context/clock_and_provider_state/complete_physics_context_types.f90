! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Native owners and borrowed inputs for one complete physics call.
!! The caller keeps every borrowed target alive for the complete call.
!! Counts are dimensionless. Numerical arrays retain their source units.
module forecast_complete_physics_context_types
  use iso_fortran_env, only: int32, int64, real64
  use forecast_physics_work_types, only: dimension_type, state_type, aux_type, aux_rad_type, aux_diag_type, &
                                      aux_diag_local_type, ddh_surf_type, flux_type, surf_and_more_type, surf_and_more_local_type, &
                                         keys_local_type, perturb_type, perturb_local_type, mask_gfl_type
  use forecast_native_field_variable_types, only: native_field_variables, native_surface_variables
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  use physics_context_child_helpers_mod, only: physics_context_record_targets, physics_context_array_targets
  use forecast_physics_provider_targets, only: callpar_provider_targets
  use forecast_physics_perturbation_views, only: native_cellular_perturbation_views
  use native_radiation_clock_views, only: native_radiation_clock_view
  use stoph_mix, only: tstoph
  use forecast_native_post_physics_control_targets, only: native_post_physics_control_targets
  implicit none
  private
  public :: native_complete_physics_context, native_complete_physics_driver_inputs
  !> Storage created by the context constructor and released by its finish entry.
  !! Field metadata is owned here; field payloads stay borrowed except for the
  !! source-selected temporary states and work records. A TARGET actual argument
  !! is required while RECORDS points to components of this same context.
  type :: native_complete_physics_context
    type(physics_context_record_targets) :: records
    type(physics_context_array_targets) :: arrays
    type(native_field_variables) :: variables
    type(native_surface_variables), pointer :: surface_variables => null()
    type(state_type) :: states(8)
    type(state_type), pointer :: tendency_phy(:) => null()
    type(mask_gfl_type) :: mask
    type(dimension_type) :: dimensions
    type(surf_and_more_type) :: surface
    type(aux_type) :: auxiliary
    type(aux_rad_type) :: radiation
    type(flux_type) :: flux
    type(aux_diag_type) :: diagnostics
    type(ddh_surf_type) :: surface_diagnostics
    type(aux_diag_local_type) :: auxiliary_local
    type(surf_and_more_local_type) :: surface_local
    type(keys_local_type) :: keys
    type(perturb_local_type) :: perturbation_local
    type(perturb_type) :: perturbation
    logical :: fallback_owned(17) = .false.
    logical :: global_metadata_owned = .false., private_metadata_owned = .false.
    logical :: state_acquired(8) = .false., work_acquired(10) = .false.
    logical :: initialized = .false., block_open = .false.
    integer(int32) :: last_block = 0_int32
  end type
  !> Borrow the original driver inputs through their actual native types.
  !! RECORDS supplies the geometry, model, registry, motion, previous state,
  !! trajectory and configuration targets. ARRAYS supplies the complete source
  !! array views. The context constructor supplies its own work/state targets.
  !! SOIL_DIAGNOSTICS follows the fourteen-count source order. LSPSDT/N2D,
  !! NVTEND/NRFRAD and VERTICAL_VELOCITY_FIRST stay explicit upstream inputs.
  !! The source driver owns temporary context storage only during EC_PHYS_DRV.
  type :: native_complete_physics_driver_inputs
    type(physics_context_record_targets) :: records
    type(physics_context_array_targets) :: arrays
    type(native_surface_variables), pointer :: surface_variables => null()
    type(native_ecmwf_physics_state), pointer :: physics => null()
    type(native_physics_runtime_data), pointer :: runtime => null()
    integer(int32) :: soil_diagnostics(14) = 0_int32
    integer(int32) :: n2d = 0_int32, nvtend = 0_int32, nrfrad = 0_int32
    integer(int32) :: vertical_velocity_first = 1_int32
    integer(int32) :: t1_components(3) = 0_int32, ph9_components(3) = 0_int32
    logical :: lspsdt = .false.
    logical, pointer :: lnodryflx => null()
    ! Borrow the actual scientific and clock targets; no values are defaulted here.
    type(callpar_provider_targets), pointer :: providers => null()
    type(native_post_physics_control_targets), pointer :: post_controls => null()
    type(tstoph), pointer :: stochastic_physics => null()
    type(native_cellular_perturbation_views) :: cellular
    type(native_radiation_clock_view) :: solar_clock
    real(real64), pointer :: rcovsr => null(), rsivsr => null()
    integer(int32), pointer :: latitude(:) => null()
  end type
end module forecast_complete_physics_context_types

!> The complete driver has this stable native interface.
!! This declaration supplies no numerical stage. The implementation is linked
!! only when its complete dependency-ordered driver body is source-ready.
module forecast_complete_physics_driver
  use iso_fortran_env, only: int32
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  implicit none
  private
  public :: ec_phys_drv, native_complete_physics_driver_inputs
  interface
    module integer(int32) function ec_phys_drv(inputs) result(status)
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
    end function ec_phys_drv
  end interface
end module forecast_complete_physics_driver
