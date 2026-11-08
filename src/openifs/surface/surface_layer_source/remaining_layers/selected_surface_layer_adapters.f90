!> Complete native surface boundary, snow initialization and turbulence entry set.
!! Inputs borrow the actual model, surface catalog, live clock and parameter owners.
!! Scientific fields use FP64 and the source units; outputs preserve inactive cells.
module forecast_selected_surface_layer_adapters
  use iso_fortran_env, only: int32, int64, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record, stability_parameter_record
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_native_field_variable_types, only: native_surface_variables
  use forecast_physics_work_types, only: dimension_type, state_type, aux_type, aux_rad_type, perturb_type, &
                                         aux_diag_local_type, gems_local_type, surf_and_more_type, surf_and_more_local_type, &
                                         flux_type, aux_diag_type, perturb_local_type, keys_local_type, ddh_surf_type
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use spp_mod, only: tspp_config
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  use yos_surf, only: tsurf
  use forecast_native_surface_boundary, only: owned_surface_boundary => surfbc
  use forecast_native_surface_layers, only: owned_surface_boundary_layer => callpar_surface_boundary, &
                                            owned_snow_initialization_layer => callpar_snow_initialization
  use forecast_native_turbulence_layer, only: owned_surface_turbulence_layer => turbulence_layer
  use forecast_snow_warm_start, only: snow_warm_start
  implicit none
  private
 public::surface_boundary_adapter,surface_boundary_layer,snow_initialisation_adapter,snow_initialisation_layer,surface_turbulence_layer
  public :: md2asm_surface_boundary_layer_layout_r2_7358525, md2asm_surface_boundary_adapter_7358525
  public :: md2asm_snow_initialisation_adapter_7358525, md2asm_snow_initialisation_layer_layout_r2_7358525
  public :: md2asm_surface_turbulence_layer_sea_r2_layout_r2_7358525
  interface md2asm_surface_boundary_layer_layout_r2_7358525
    module procedure surface_boundary_layer
  end interface
  interface md2asm_surface_boundary_adapter_7358525
    module procedure surface_boundary_adapter
  end interface
  interface md2asm_snow_initialisation_adapter_7358525
    module procedure snow_initialisation_adapter
  end interface
  interface md2asm_snow_initialisation_layer_layout_r2_7358525
    module procedure snow_initialisation_layer
  end interface
  interface md2asm_surface_turbulence_layer_sea_r2_layout_r2_7358525
    module procedure surface_turbulence_layer
  end interface
contains
  subroutine surface_boundary_adapter(ydsurf,kidia,kfdia,klon,ktiles,klevsn,ptvl,pco2typ,ptvh,psoty,psdor,pcvlc,pcvhc,pcurc,plailc,plaihc,plaili,plaihi,plsm,pci,pclake,phlice,pgemu,psnm1m,pwlm1m,prsnm1m,ldland,ldsice,ldlake,ldnh,ldocn_kpp,ktvl,kco2typ,ktvh,ksoty,pcvl,pcvh,pcur,plail,plaih,pwlmx,pfrti,status)
    type(tsurf), intent(in) :: ydsurf
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, klevsn
    real(real64), intent(in) :: ptvl(:), pco2typ(:), ptvh(:), psoty(:), psdor(:), pcvlc(:), pcvhc(:), pcurc(:)
    real(real64), intent(in) :: plailc(:), plaihc(:), plaili(:), plaihi(:), plsm(:), pci(:), pclake(:), phlice(:), pgemu(:)
    real(real64), intent(in) :: psnm1m(:, :), pwlm1m(:), prsnm1m(:, :)
    logical(int32), intent(inout) :: ldland(:), ldsice(:), ldlake(:), ldnh(:), ldocn_kpp(:)
    integer(int32), intent(inout) :: ktvl(:), kco2typ(:), ktvh(:), ksoty(:)
    real(real64), intent(inout) :: pcvl(:), pcvh(:), pcur(:), plail(:), plaih(:), pwlmx(:), pfrti(:, :)
    integer(int32), intent(out) :: status
    call owned_surface_boundary(ydsurf,kidia,kfdia,klon,ktiles,klevsn,ptvl,pco2typ,ptvh,psoty,psdor,pcvlc,pcvhc,pcurc,plailc,plaihc,plaili,plaihi,plsm,pci,pclake,phlice,pgemu,psnm1m,pwlm1m,prsnm1m,ldland,ldsice,ldlake,ldnh,ldocn_kpp,ktvl,kco2typ,ktvh,ksoty,pcvl,pcvh,pcur,plail,plaih,pwlmx,pfrti,status)
  end subroutine surface_boundary_adapter
  subroutine surface_boundary_layer(inputs, d, aux, keys, surface, surfl, status)
    type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
    type(dimension_type), intent(in) :: d
    type(aux_type), intent(in) :: aux
    type(keys_local_type), intent(inout) :: keys
    type(surf_and_more_type), intent(inout) :: surface
    type(surf_and_more_local_type), intent(inout) :: surfl
    integer(int32), intent(out) :: status
    call owned_surface_boundary_layer(inputs, d, aux, keys, surface, surfl, status)
  end subroutine surface_boundary_layer
  subroutine snow_initialisation_layer(inputs, d, surface, surfl, aux, status)
    type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
    type(dimension_type), intent(in) :: d
    type(surf_and_more_type), intent(inout) :: surface
    type(surf_and_more_local_type), intent(inout) :: surfl
    type(aux_type), intent(in) :: aux
    integer(int32), intent(out) :: status
    call owned_snow_initialization_layer(inputs, d, surface, surfl, aux, status)
  end subroutine snow_initialisation_layer
  subroutine surface_turbulence_layer(physical,thermal,stability,parameters,model,surface_catalog,runtime_scalars,scmec_enabled,nemo_limit_thickness,carbon_dioxide,spp,planet_scale,rplrg,source_time_step,current_step,kdim,paux,state,tendency,prad,ppert,auxl,gemsl,psurf,surfl,flux,pdiag,pertl,llkeys,pddhs,tendency_loc,status)
    type(forecast_physical_constants), intent(in) :: physical
    type(thermal_parameter_record), intent(in) :: thermal
    type(stability_parameter_record), intent(in) :: stability
    type(native_ecmwf_physics_state), intent(in) :: parameters
    type(native_operational_model_configuration), intent(inout) :: model
    type(native_surface_variables), intent(inout) :: surface_catalog
    type(tspp_config), intent(in) :: spp
    type(native_forecast_scalar_data), intent(in) :: runtime_scalars
    logical, intent(in) :: scmec_enabled, nemo_limit_thickness
    real(real64), intent(in) :: carbon_dioxide
    real(real64), intent(in) :: planet_scale, rplrg, source_time_step
    integer(int32), intent(in) :: current_step
    type(dimension_type), intent(in) :: kdim
    type(aux_type), intent(in) :: paux
    type(state_type), intent(in) :: state, tendency
    type(aux_rad_type), intent(in) :: prad
    type(perturb_type), intent(in) :: ppert
    type(aux_diag_local_type), intent(inout) :: auxl
    type(gems_local_type), intent(inout) :: gemsl
    type(surf_and_more_type), intent(inout) :: psurf
    type(surf_and_more_local_type), intent(inout) :: surfl
    type(flux_type), intent(inout) :: flux
    type(aux_diag_type), intent(inout) :: pdiag
    type(perturb_local_type), intent(inout) :: pertl
    type(keys_local_type), intent(inout) :: llkeys
    type(ddh_surf_type), intent(inout) :: pddhs
    type(state_type), intent(inout) :: tendency_loc
    integer(int32), intent(out) :: status
    call owned_surface_turbulence_layer(physical,thermal,stability,parameters,model,surface_catalog,runtime_scalars,scmec_enabled,nemo_limit_thickness,carbon_dioxide,spp,planet_scale,rplrg,source_time_step,current_step,kdim,paux,state,tendency,prad,ppert,auxl,gemsl,psurf,surfl,flux,pdiag,pertl,llkeys,pddhs,tendency_loc,status)
  end subroutine surface_turbulence_layer
  !> Map the actual surface constants and soil record to the complete snow child.
  !! P is KLON, snow profiles are(P,KLEVSN), tile fractions(P,KTILES).
  !! Temperatures are K, snow mass kg/m2 and density kg/m3.
  !! Ordinary assumed-shape arrays retain caller strides and ownership.
  subroutine snow_initialisation_adapter(surface,kidia,kfdia,klon,klevs,klevsn,ktiles,psdor,plsm,pfrti,pmu0,ptsam1m,ptskin,palbsn,ptsnm1m,psnm1m,prsnm1m,pwsnm1m,status)
    type(tsurf), intent(in) :: surface
    integer(int32), intent(in) :: kidia, kfdia, klon, klevs, klevsn, ktiles
    real(real64), intent(in) :: psdor(:), plsm(:), pfrti(:, :), pmu0(:), ptsam1m(:, :), ptskin(:), palbsn(:)
    real(real64), intent(inout) :: ptsnm1m(:, :), psnm1m(:, :), prsnm1m(:, :), pwsnm1m(:, :)
    integer(int32), intent(out) :: status
    status = 2_int32
    if (klon < 1 .or. klon > 4096 .or. kidia < 1 .or. kfdia < kidia .or. kfdia > klon) return
    if (klevs < 1 .or. klevsn < 1 .or. ktiles < 1) return
    if (min(size(plsm), size(psdor), size(pmu0), size(ptskin), size(palbsn)) < klon) return
    if (size(pfrti, 1) < klon .or. size(pfrti, 2) < ktiles) return
    if (size(ptsam1m, 1) < klon .or. size(ptsam1m, 2) < klevs) return
    if (min(size(ptsnm1m, 1), size(psnm1m, 1), size(prsnm1m, 1), size(pwsnm1m, 1)) < klon) return
    if (min(size(ptsnm1m, 2), size(psnm1m, 2), size(prsnm1m, 2), size(pwsnm1m, 2)) < klevsn) return
    call snow_warm_start(kidia, kfdia, klon, klevsn, psdor, plsm, pfrti, pmu0, ptsam1m, ptskin, palbsn, &
                         ptsnm1m, psnm1m, prsnm1m, pwsnm1m, surface%ycst, surface%ysoil, status)
  end subroutine snow_initialisation_adapter
end module forecast_selected_surface_layer_adapters
