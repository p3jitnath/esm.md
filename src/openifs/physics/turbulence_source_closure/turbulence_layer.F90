!> Native turbulence work and surface-field join for the selected ECMWF route.
!! The caller retains canonical owners for the whole call. Surface metadata is
!! accessed through named P/T9 views; no private MP index or model image is read.
module forecast_native_turbulence_layer
  use iso_fortran_env, only: int32, int64, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record, stability_parameter_record
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_native_field_variable_types, only: native_surface_variables
  use forecast_physics_work_types, only: dimension_type, state_type, aux_type, aux_rad_type, perturb_type, &
                                         aux_diag_local_type, gems_local_type, surf_and_more_type, surf_and_more_local_type, &
                                         flux_type, aux_diag_type, perturb_local_type, keys_local_type, ddh_surf_type
  use forecast_native_vertical_diffusion, only: native_turbulence_controls
  use forecast_native_vertical_diffusion_outer, only: vdfouter
  use spp_mod, only: tspp_config
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  use yomctesseldim, only: ikvtypes, ikdhvco2s, ikdhfco2s, ikdhvvegs, ikdhfvegs
  use yoecldp, only: ncldql, ncldqi
  implicit none
  private
  public :: turbulence_layer
contains
  !> Copy source work, run native VDFOUTER and return surface diagnostics.
  !! Every real work field is FP64. P is KDIM%KLON, L is KDIM%KLEV; full
  !! profiles are(P,L), half profiles(P,0:L), tiles(P,9), soil(P,4) and named
  !! surface planes retain source P/T9 ownership. Temperatures are K, pressure
  !! Pa, winds m/s, heat fluxes W/m2, water fluxes kg/(m2 s), tendencies per s.
  !! PHYSICAL/THERMAL/STABILITY/PARAMETERS/SPP and runtime controls are readonly; MODEL only
  !! passes its actual physics configuration as the child's mutable state.
  !! The surface catalogue borrows named views and keeps its metadata intact.
  !! Only source-selected rows change. Owners must obey child disjointness.
  !! The selected route has P1:4096,L3:512,soil4,tiles9,no tracer diffusion,
  !! no stochastic physics, no coupled carbon, no LBUD23 or LPPTILES output.
  !! Source clock step, time and planet values are explicit initialized inputs.
  !! Status0 completes;2 refuses unsupported metadata before public mutation;
  !! 1 reports private allocation failure. Child status propagates unchanged.
  subroutine turbulence_layer(physical,thermal,stability,parameters,model,surface_catalog,runtime_scalars,scmec_enabled,nemo_limit_thickness,carbon_dioxide,spp, &
                              planet_scale, rplrg, source_time_step, current_step, kdim, paux, state, tendency, prad, ppert, &
                              auxl, gemsl, psurf, surfl, flux, pdiag, pertl, llkeys, pddhs, tendency_loc, status)
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
    type(native_turbulence_controls) :: controls
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
    integer :: jl, jrf, idiag, allocation_status
    character(len=1) :: clconf
    real(real64), volatile :: zrcpd
    real(real64), allocatable :: zevapmu(:), zan(:), zrd(:), zrsoil_str(:), zdhco2s(:, :, :), zgp2dspp(:, :), zexdiag(:, :)
    real(real64), allocatable :: empty_state(:, :, :), empty_tendency(:, :, :)
    real(real64), allocatable :: empty_flux_in(:, :), empty_deposition(:, :), empty_flux_out(:, :)
    integer(int32) :: empty_indices(0)
    integer :: p, l, nrf
    status = 2_int32
    controls%scmec_enabled = scmec_enabled
    controls%nemo_limit_thickness = nemo_limit_thickness
    controls%carbon_dioxide = carbon_dioxide
    controls%prescribed_surface_flux = runtime_scalars%lsfcflx
    controls%external_sensible_flux = runtime_scalars%rextshf
    controls%external_latent_flux = runtime_scalars%rextlhf
    controls%vector_math = runtime_scalars%n_vmass
    p = kdim%klon; l = kdim%klev; nrf = spp%sm%nrftotal
    if (p < 1 .or. p > 4096 .or. l < 3 .or. l > 512 .or. kdim%klevs /= 4 .or. kdim%ktiles /= 9) return
    if (kdim%kidia < 1 .or. kdim%kfdia < kdim%kidia .or. kdim%kfdia > p .or. current_step < 0) return
    if (kdim%klevsn < 1 .or. kdim%klevi < 1 .or. nrf < 0) return
    if (min(kdim%kdhvtls, kdim%kdhftls, kdim%kdhvtss, kdim%kdhftss, &
            kdim%kdhvtts, kdim%kdhftts, kdim%kdhvtis, kdim%kdhftis) < 0) return
    if(model%physics%ecmwf_physics%lbud23.or.model%physics%ecmwf_physics%lpptiles.or.model%physics%ecmwf_physics%lvdftrac.or.model%physics%ecmwf_physics%leairco2coup)return
    if (spp%lspp .or. controls%vector_math > 0) return
    if (.not. associated(parameters%surface) .or. .not. associated(gemsl%itrac)) return
    if (gemsl%itrac /= 0) return
    if (.not. associated(AUXL%ZSOBETA)) return
    if (.not. associated(AUXL%ZSOTEU)) return
    if (.not. associated(AUXL%ZSOTEV)) return
    if (.not. associated(AUXL%ZTSKRAD)) return
    if (.not. associated(FLUX%PDIFTI)) return
    if (.not. associated(FLUX%PDIFTL)) return
    if (.not. associated(FLUX%PDIFTQ)) return
    if (.not. associated(FLUX%PDIFTS)) return
    if (.not. associated(FLUX%PFRSO)) return
    if (.not. associated(FLUX%PFRTH)) return
    if (.not. associated(FLUX%PFTLHEV)) return
    if (.not. associated(FLUX%PFTLHSB)) return
    if (.not. associated(FLUX%PFWSB)) return
    if (.not. associated(FLUX%PSTRDU)) return
    if (.not. associated(FLUX%PSTRDV)) return
    if (.not. associated(FLUX%PSTRTU)) return
    if (.not. associated(FLUX%PSTRTV)) return
    if (.not. associated(FLUX%PTOFDU)) return
    if (.not. associated(FLUX%PTOFDV)) return
    if (.not. associated(GEMSL%ZAZ0H)) return
    if (.not. associated(GEMSL%ZAZ0M)) return
    if (.not. associated(LLKEYS%LLSHCV)) return
    if (.not. associated(PAUX%PAPRS)) return
    if (.not. associated(PAUX%PAPRSF)) return
    if (.not. associated(PAUX%PGELAM)) return
    if (.not. associated(PAUX%PGELAT)) return
    if (.not. associated(PAUX%PGEOM1)) return
    if (.not. associated(PAUX%PGEOMH)) return
    if (.not. associated(PAUX%PMU0)) return
    if (.not. associated(PDDHS%PDHTIS)) return
    if (.not. associated(PDDHS%PDHTLS)) return
    if (.not. associated(PDDHS%PDHTSS)) return
    if (.not. associated(PDDHS%PDHTTS)) return
    if (.not. associated(PDIAG%IPBLTYPE)) return
    if (.not. associated(PDIAG%PI10FG)) return
    if (.not. associated(PDIAG%PKH_VDF)) return
    if (.not. associated(PDIAG%PKM_VDF)) return
    if (.not. associated(PDIAG%PUSTRG)) return
    if (.not. associated(PDIAG%PVDIS)) return
    if (.not. associated(PDIAG%PVDISG)) return
    if (.not. associated(PDIAG%PVSTRG)) return
    if (.not. associated(PDIAG%ZEIS)) return
    if (.not. associated(PDIAG%ZINV)) return
    if (.not. associated(PDIAG%ZRI)) return
    if (.not. associated(PERTL%ZDISSGW)) return
    if (.not. associated(PRAD%PHRLW)) return
    if (.not. associated(PRAD%PHRSW)) return
    if (.not. associated(PSURF%ICO2TYP)) return
    if (.not. associated(PSURF%ISOTY)) return
    if (.not. associated(PSURF%ITVH)) return
    if (.not. associated(PSURF%ITVL)) return
    if (.not. associated(PSURF%PAHFSTI)) return
    if (.not. associated(PSURF%PCUR)) return
    if (.not. associated(PSURF%PCVH)) return
    if (.not. associated(PSURF%PCVL)) return
    if (.not. associated(PSURF%PEMIS)) return
    if (.not. associated(PSURF%PEVAPMU)) return
    if (.not. associated(PSURF%PEVAPTI)) return
    if (.not. associated(PSURF%PLAIH)) return
    if (.not. associated(PSURF%PLAIL)) return
    if (.not. associated(PSURF%PTLE1)) return
    if (.not. associated(PSURF%PTSKTI)) return
    if (.not. associated(PSURF%PUSTRTI)) return
    if (.not. associated(PSURF%PVSTRTI)) return
    if (.not. associated(SURFL%ZAHFTRTI)) return
    if (.not. associated(SURFL%ZALBTI)) return
    if (.not. associated(SURFL%ZANDAYVT)) return
    if (.not. associated(SURFL%ZANFMVT)) return
    if (.not. associated(SURFL%ZDHVEGS)) return
    if (.not. associated(SURFL%ZEVAPSNW)) return
    if (.not. associated(SURFL%ZFRSOTI)) return
    if (.not. associated(SURFL%ZFRTI)) return
    if (.not. associated(SURFL%ZHSDFOR)) return
    if (.not. associated(SURFL%ZSNTICE)) return
    if (.not. associated(SURFL%ZTHKICE)) return
    if (.not. associated(SURFL%ZWLMX)) return
    if (.not. associated(state%T)) return
    if (.not. associated(state%a)) return
    if (.not. associated(state%cld)) return
    if (.not. associated(state%q)) return
    if (.not. associated(state%tke)) return
    if (.not. associated(state%u)) return
    if (.not. associated(state%v)) return
    if (.not. associated(tendency%T)) return
    if (.not. associated(tendency%a)) return
    if (.not. associated(tendency%cld)) return
    if (.not. associated(tendency%q)) return
    if (.not. associated(tendency%u)) return
    if (.not. associated(tendency%v)) return
    if (.not. associated(tendency_loc%T)) return
    if (.not. associated(tendency_loc%a)) return
    if (.not. associated(tendency_loc%cld)) return
    if (.not. associated(tendency_loc%q)) return
    if (.not. associated(tendency_loc%tke)) return
    if (.not. associated(tendency_loc%u)) return
    if (.not. associated(tendency_loc%v)) return
    if (.not. associated(surface_catalog%gsd_vd%v10fgcv%p)) return
    if (.not. associated(surface_catalog%gsd_vd%v10nu%p)) return
    if (.not. associated(surface_catalog%gsd_vd%v10nv%p)) return
    if (.not. associated(surface_catalog%gsd_vd%v10u%p)) return
    if (.not. associated(surface_catalog%gsd_vd%v10v%p)) return
    if (.not. associated(surface_catalog%gsd_vd%v2d%p)) return
    if (.not. associated(surface_catalog%gsd_vd%v2sh%p)) return
    if (.not. associated(surface_catalog%gsd_vd%v2t%p)) return
    if (.not. associated(surface_catalog%gsd_vd%vblh%p)) return
    if (.not. associated(surface_catalog%gsd_vd%vich4%p)) return
    if (.not. associated(surface_catalog%gsd_vd%vigpp%p)) return
    if (.not. associated(surface_catalog%gsd_vd%vinee%p)) return
    if (.not. associated(surface_catalog%gsd_vd%virec%p)) return
    if (.not. associated(surface_catalog%gsd_vd%vzust%p)) return
    if (.not. associated(surface_catalog%gsd_vf%vcgpp%p)) return
    if (.not. associated(surface_catalog%gsd_vf%vcrec%p)) return
    if (.not. associated(surface_catalog%gsd_vf%vfwet%p)) return
    if (.not. associated(surface_catalog%gsd_vf%vlsm%p)) return
    if (.not. associated(surface_catalog%gsd_vf%vsst%p)) return
    if (.not. associated(surface_catalog%gsd_vf%vucur%p)) return
    if (.not. associated(surface_catalog%gsd_vf%vvcur%p)) return
    if (.not. associated(surface_catalog%gsd_ws%vchar%p)) return
    if (.not. associated(surface_catalog%gsd_ws%vcharhq%p)) return
    if (.not. associated(surface_catalog%gsd_ws%vustokes%p)) return
    if (.not. associated(surface_catalog%gsd_ws%vvstokes%p)) return
    if (.not. associated(surface_catalog%gsp_rr%vt%t9)) return
    if (.not. associated(surface_catalog%gsp_sb%vq%t9)) return
    if (.not. associated(surface_catalog%gsp_sb%vt%t9)) return
    if (.not. associated(surface_catalog%gsp_sb%vtl%t9)) return
    if (.not. associated(surface_catalog%gsp_sg%vf%t9)) return
    if (.not. associated(surface_catalog%gsp_sg%vr%t9)) return
    if (.not. associated(surface_catalog%gsp_sg%vt%t9)) return
    if (.not. associated(surface_catalog%gsp_sl%vlicd%t9)) return
    if (.not. associated(surface_catalog%gsp_sl%vlict%t9)) return
    if (.not. associated(surface_catalog%gsp_sl%vlmlt%t9)) return
    if (.not. is_contiguous(AUXL%ZSOBETA)) return
    if (.not. is_contiguous(AUXL%ZSOTEU)) return
    if (.not. is_contiguous(AUXL%ZSOTEV)) return
    if (.not. is_contiguous(AUXL%ZTSKRAD)) return
    if (.not. is_contiguous(FLUX%PDIFTI)) return
    if (.not. is_contiguous(FLUX%PDIFTL)) return
    if (.not. is_contiguous(FLUX%PDIFTQ)) return
    if (.not. is_contiguous(FLUX%PDIFTS)) return
    if (.not. is_contiguous(FLUX%PFRSO)) return
    if (.not. is_contiguous(FLUX%PFRTH)) return
    if (.not. is_contiguous(FLUX%PFTLHEV)) return
    if (.not. is_contiguous(FLUX%PFTLHSB)) return
    if (.not. is_contiguous(FLUX%PFWSB)) return
    if (.not. is_contiguous(FLUX%PSTRDU)) return
    if (.not. is_contiguous(FLUX%PSTRDV)) return
    if (.not. is_contiguous(FLUX%PSTRTU)) return
    if (.not. is_contiguous(FLUX%PSTRTV)) return
    if (.not. is_contiguous(FLUX%PTOFDU)) return
    if (.not. is_contiguous(FLUX%PTOFDV)) return
    if (.not. is_contiguous(GEMSL%ZAZ0H)) return
    if (.not. is_contiguous(GEMSL%ZAZ0M)) return
    if (.not. is_contiguous(LLKEYS%LLSHCV)) return
    if (.not. is_contiguous(PAUX%PAPRS)) return
    if (.not. is_contiguous(PAUX%PAPRSF)) return
    if (.not. is_contiguous(PAUX%PGELAM)) return
    if (.not. is_contiguous(PAUX%PGELAT)) return
    if (.not. is_contiguous(PAUX%PGEOM1)) return
    if (.not. is_contiguous(PAUX%PGEOMH)) return
    if (.not. is_contiguous(PAUX%PMU0)) return
    if (.not. is_contiguous(PDDHS%PDHTIS)) return
    if (.not. is_contiguous(PDDHS%PDHTLS)) return
    if (.not. is_contiguous(PDDHS%PDHTSS)) return
    if (.not. is_contiguous(PDDHS%PDHTTS)) return
    if (.not. is_contiguous(PDIAG%IPBLTYPE)) return
    if (.not. is_contiguous(PDIAG%PI10FG)) return
    if (.not. is_contiguous(PDIAG%PKH_VDF)) return
    if (.not. is_contiguous(PDIAG%PKM_VDF)) return
    if (.not. is_contiguous(PDIAG%PUSTRG)) return
    if (.not. is_contiguous(PDIAG%PVDIS)) return
    if (.not. is_contiguous(PDIAG%PVDISG)) return
    if (.not. is_contiguous(PDIAG%PVSTRG)) return
    if (.not. is_contiguous(PDIAG%ZEIS)) return
    if (.not. is_contiguous(PDIAG%ZINV)) return
    if (.not. is_contiguous(PDIAG%ZRI)) return
    if (.not. is_contiguous(PERTL%ZDISSGW)) return
    if (.not. is_contiguous(PRAD%PHRLW)) return
    if (.not. is_contiguous(PRAD%PHRSW)) return
    if (.not. is_contiguous(PSURF%ICO2TYP)) return
    if (.not. is_contiguous(PSURF%ISOTY)) return
    if (.not. is_contiguous(PSURF%ITVH)) return
    if (.not. is_contiguous(PSURF%ITVL)) return
    if (.not. is_contiguous(PSURF%PAHFSTI)) return
    if (.not. is_contiguous(PSURF%PCUR)) return
    if (.not. is_contiguous(PSURF%PCVH)) return
    if (.not. is_contiguous(PSURF%PCVL)) return
    if (.not. is_contiguous(PSURF%PEMIS)) return
    if (.not. is_contiguous(PSURF%PEVAPMU)) return
    if (.not. is_contiguous(PSURF%PEVAPTI)) return
    if (.not. is_contiguous(PSURF%PLAIH)) return
    if (.not. is_contiguous(PSURF%PLAIL)) return
    if (.not. is_contiguous(PSURF%PTLE1)) return
    if (.not. is_contiguous(PSURF%PTSKTI)) return
    if (.not. is_contiguous(PSURF%PUSTRTI)) return
    if (.not. is_contiguous(PSURF%PVSTRTI)) return
    if (.not. is_contiguous(SURFL%ZAHFTRTI)) return
    if (.not. is_contiguous(SURFL%ZALBTI)) return
    if (.not. is_contiguous(SURFL%ZANDAYVT)) return
    if (.not. is_contiguous(SURFL%ZANFMVT)) return
    if (.not. is_contiguous(SURFL%ZDHVEGS)) return
    if (.not. is_contiguous(SURFL%ZEVAPSNW)) return
    if (.not. is_contiguous(SURFL%ZFRSOTI)) return
    if (.not. is_contiguous(SURFL%ZFRTI)) return
    if (.not. is_contiguous(SURFL%ZHSDFOR)) return
    if (.not. is_contiguous(SURFL%ZSNTICE)) return
    if (.not. is_contiguous(SURFL%ZTHKICE)) return
    if (.not. is_contiguous(SURFL%ZWLMX)) return
    if (.not. is_contiguous(state%T)) return
    if (.not. is_contiguous(state%a)) return
    if (.not. is_contiguous(state%cld)) return
    if (.not. is_contiguous(state%q)) return
    if (.not. is_contiguous(state%tke)) return
    if (.not. is_contiguous(state%u)) return
    if (.not. is_contiguous(state%v)) return
    if (.not. is_contiguous(tendency%T)) return
    if (.not. is_contiguous(tendency%a)) return
    if (.not. is_contiguous(tendency%cld)) return
    if (.not. is_contiguous(tendency%q)) return
    if (.not. is_contiguous(tendency%u)) return
    if (.not. is_contiguous(tendency%v)) return
    if (.not. is_contiguous(tendency_loc%T)) return
    if (.not. is_contiguous(tendency_loc%a)) return
    if (.not. is_contiguous(tendency_loc%cld)) return
    if (.not. is_contiguous(tendency_loc%q)) return
    if (.not. is_contiguous(tendency_loc%tke)) return
    if (.not. is_contiguous(tendency_loc%u)) return
    if (.not. is_contiguous(tendency_loc%v)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v10fgcv%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v10nu%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v10nv%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v10u%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v10v%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v2d%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v2sh%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%v2t%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%vblh%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%vich4%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%vigpp%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%vinee%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%virec%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vd%vzust%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vf%vcgpp%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vf%vcrec%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vf%vfwet%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vf%vlsm%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vf%vsst%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vf%vucur%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_vf%vvcur%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_ws%vchar%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_ws%vcharhq%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_ws%vustokes%p)) return
    if (.not. is_contiguous(surface_catalog%gsd_ws%vvstokes%p)) return
    if (.not. is_contiguous(surface_catalog%gsp_rr%vt%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sb%vq%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sb%vt%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sb%vtl%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sg%vf%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sg%vr%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sg%vt%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sl%vlicd%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sl%vlict%t9)) return
    if (.not. is_contiguous(surface_catalog%gsp_sl%vlmlt%t9)) return
    if (size(AUXL%ZSOBETA, 1) /= p) return
    if (size(AUXL%ZSOTEU, 1) /= p) return
    if (size(AUXL%ZSOTEV, 1) /= p) return
    if (size(AUXL%ZTSKRAD, 1) /= p) return
    if (size(FLUX%PDIFTI, 1) /= p) return
    if (size(FLUX%PDIFTL, 1) /= p) return
    if (size(FLUX%PDIFTQ, 1) /= p) return
    if (size(FLUX%PDIFTS, 1) /= p) return
    if (size(FLUX%PFRSO, 1) /= p) return
    if (size(FLUX%PFRTH, 1) /= p) return
    if (size(FLUX%PFTLHEV, 1) /= p) return
    if (size(FLUX%PFTLHSB, 1) /= p) return
    if (size(FLUX%PFWSB, 1) /= p) return
    if (size(FLUX%PSTRDU, 1) /= p) return
    if (size(FLUX%PSTRDV, 1) /= p) return
    if (size(FLUX%PSTRTU, 1) /= p) return
    if (size(FLUX%PSTRTV, 1) /= p) return
    if (size(FLUX%PTOFDU, 1) /= p) return
    if (size(FLUX%PTOFDV, 1) /= p) return
    if (size(GEMSL%ZAZ0H, 1) /= p) return
    if (size(GEMSL%ZAZ0M, 1) /= p) return
    if (size(LLKEYS%LLSHCV, 1) /= p) return
    if (size(PAUX%PAPRS, 1) /= p) return
    if (size(PAUX%PAPRSF, 1) /= p) return
    if (size(PAUX%PGELAM, 1) /= p) return
    if (size(PAUX%PGELAT, 1) /= p) return
    if (size(PAUX%PGEOM1, 1) /= p) return
    if (size(PAUX%PGEOMH, 1) /= p) return
    if (size(PAUX%PMU0, 1) /= p) return
    if (size(PDDHS%PDHTIS, 1) /= p) return
    if (size(PDDHS%PDHTLS, 1) /= p) return
    if (size(PDDHS%PDHTSS, 1) /= p) return
    if (size(PDDHS%PDHTTS, 1) /= p) return
    if (size(PDIAG%IPBLTYPE, 1) /= p) return
    if (size(PDIAG%PI10FG, 1) /= p) return
    if (size(PDIAG%PKH_VDF, 1) /= p) return
    if (size(PDIAG%PKM_VDF, 1) /= p) return
    if (size(PDIAG%PUSTRG, 1) /= p) return
    if (size(PDIAG%PVDIS, 1) /= p) return
    if (size(PDIAG%PVDISG, 1) /= p) return
    if (size(PDIAG%PVSTRG, 1) /= p) return
    if (size(PDIAG%ZEIS, 1) /= p) return
    if (size(PDIAG%ZINV, 1) /= p) return
    if (size(PDIAG%ZRI, 1) /= p) return
    if (size(PERTL%ZDISSGW, 1) /= p) return
    if (size(PRAD%PHRLW, 1) /= p) return
    if (size(PRAD%PHRSW, 1) /= p) return
    if (size(PSURF%ICO2TYP, 1) /= p) return
    if (size(PSURF%ISOTY, 1) /= p) return
    if (size(PSURF%ITVH, 1) /= p) return
    if (size(PSURF%ITVL, 1) /= p) return
    if (size(PSURF%PAHFSTI, 1) /= p) return
    if (size(PSURF%PCUR, 1) /= p) return
    if (size(PSURF%PCVH, 1) /= p) return
    if (size(PSURF%PCVL, 1) /= p) return
    if (size(PSURF%PEMIS, 1) /= p) return
    if (size(PSURF%PEVAPMU, 1) /= p) return
    if (size(PSURF%PEVAPTI, 1) /= p) return
    if (size(PSURF%PLAIH, 1) /= p) return
    if (size(PSURF%PLAIL, 1) /= p) return
    if (size(PSURF%PTLE1, 1) /= p) return
    if (size(PSURF%PTSKTI, 1) /= p) return
    if (size(PSURF%PUSTRTI, 1) /= p) return
    if (size(PSURF%PVSTRTI, 1) /= p) return
    if (size(SURFL%ZAHFTRTI, 1) /= p) return
    if (size(SURFL%ZALBTI, 1) /= p) return
    if (size(SURFL%ZANDAYVT, 1) /= p) return
    if (size(SURFL%ZANFMVT, 1) /= p) return
    if (size(SURFL%ZDHVEGS, 1) /= p) return
    if (size(SURFL%ZEVAPSNW, 1) /= p) return
    if (size(SURFL%ZFRSOTI, 1) /= p) return
    if (size(SURFL%ZFRTI, 1) /= p) return
    if (size(SURFL%ZHSDFOR, 1) /= p) return
    if (size(SURFL%ZSNTICE, 1) /= p) return
    if (size(SURFL%ZTHKICE, 1) /= p) return
    if (size(SURFL%ZWLMX, 1) /= p) return
    if (size(state%T, 1) /= p) return
    if (size(state%a, 1) /= p) return
    if (size(state%cld, 1) /= p) return
    if (size(state%q, 1) /= p) return
    if (size(state%tke, 1) /= p) return
    if (size(state%u, 1) /= p) return
    if (size(state%v, 1) /= p) return
    if (size(tendency%T, 1) /= p) return
    if (size(tendency%a, 1) /= p) return
    if (size(tendency%cld, 1) /= p) return
    if (size(tendency%q, 1) /= p) return
    if (size(tendency%u, 1) /= p) return
    if (size(tendency%v, 1) /= p) return
    if (size(tendency_loc%T, 1) /= p) return
    if (size(tendency_loc%a, 1) /= p) return
    if (size(tendency_loc%cld, 1) /= p) return
    if (size(tendency_loc%q, 1) /= p) return
    if (size(tendency_loc%tke, 1) /= p) return
    if (size(tendency_loc%u, 1) /= p) return
    if (size(tendency_loc%v, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v10fgcv%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v10nu%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v10nv%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v10u%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v10v%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v2d%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v2sh%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%v2t%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%vblh%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%vich4%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%vigpp%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%vinee%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%virec%p, 1) /= p) return
    if (size(surface_catalog%gsd_vd%vzust%p, 1) /= p) return
    if (size(surface_catalog%gsd_vf%vcgpp%p, 1) /= p) return
    if (size(surface_catalog%gsd_vf%vcrec%p, 1) /= p) return
    if (size(surface_catalog%gsd_vf%vfwet%p, 1) /= p) return
    if (size(surface_catalog%gsd_vf%vlsm%p, 1) /= p) return
    if (size(surface_catalog%gsd_vf%vsst%p, 1) /= p) return
    if (size(surface_catalog%gsd_vf%vucur%p, 1) /= p) return
    if (size(surface_catalog%gsd_vf%vvcur%p, 1) /= p) return
    if (size(surface_catalog%gsd_ws%vchar%p, 1) /= p) return
    if (size(surface_catalog%gsd_ws%vcharhq%p, 1) /= p) return
    if (size(surface_catalog%gsd_ws%vustokes%p, 1) /= p) return
    if (size(surface_catalog%gsd_ws%vvstokes%p, 1) /= p) return
    if (size(surface_catalog%gsp_rr%vt%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sb%vq%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sb%vt%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sb%vtl%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sg%vf%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sg%vr%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sg%vt%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sl%vlicd%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sl%vlict%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sl%vlmlt%t9, 1) /= p) return
    if (size(state%cld, 2) < l .or. size(state%cld, 3) < max(ncldql, ncldqi)) return
    if (size(tendency%cld, 2) < l .or. size(tendency%cld, 3) < max(ncldql, ncldqi)) return
    if (size(tendency_loc%cld, 2) < l .or. size(tendency_loc%cld, 3) < max(ncldql, ncldqi)) return
    if (size(surface_catalog%gsp_sb%vtl%t9, 2) < 1) return
    if (nrf > 0) then
      if (.not. associated(ppert%pgp2dspp)) return
      if (size(ppert%pgp2dspp, 1) < p .or. size(ppert%pgp2dspp, 2) < 1 .or. size(ppert%pgp2dspp, 3) < nrf) return
    end if
    if (min(size(pdiag%pustrg), size(pdiag%pvstrg), size(psurf%pevapmu), size(llkeys%llshcv)) < p) return
    if (lbound(flux%pstrdu, 2) > 0 .or. ubound(flux%pstrdu, 2) < l) return
    if (lbound(flux%pstrdv, 2) > 0 .or. ubound(flux%pstrdv, 2) < l) return
    if (size(PSURF%ITVL, 1) < p) return
    if (size(PSURF%ICO2TYP, 1) < p) return
    if (size(PSURF%ITVH, 1) < p) return
    if (size(PSURF%PCVL, 1) < p) return
    if (size(PSURF%PCVH, 1) < p) return
    if (size(PSURF%PCUR, 1) < p) return
    if (size(PSURF%PLAIL, 1) < p) return
    if (size(PSURF%PLAIH, 1) < p) return
    if (size(surface_catalog%gsd_vf%vfwet%p, 1) < p) return
    if (size(surface_catalog%gsp_sg%vf%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sg%vf%t9, 2) < kdim%klevsn) return
    if (size(surface_catalog%gsp_sg%vr%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sg%vr%t9, 2) < kdim%klevsn) return
    if (size(PAUX%PMU0, 1) < p) return
    if (size(SURFL%ZHSDFOR, 1) < p) return
    if (size(state%u, 1) /= p) return
    if (size(state%u, 2) < l) return
    if (size(state%v, 1) /= p) return
    if (size(state%v, 2) < l) return
    if (size(state%T, 1) /= p) return
    if (size(state%T, 2) < l) return
    if (size(state%q, 1) /= p) return
    if (size(state%q, 2) < l) return
    if (size(state%tke, 1) /= p) return
    if (size(state%tke, 2) < l) return
    if (size(state%cld(:, :, NCLDQL), 1) /= p) return
    if (size(state%cld(:, :, NCLDQL), 2) < l) return
    if (size(state%cld(:, :, NCLDQI), 1) /= p) return
    if (size(state%cld(:, :, NCLDQI), 2) < l) return
    if (size(state%a, 1) /= p) return
    if (size(state%a, 2) < l) return
    if (size(PAUX%PAPRS, 1) /= p) return
    if (size(PAUX%PAPRS, 2) < (l - 0 + 1)) return
    if (size(PAUX%PAPRSF, 1) /= p) return
    if (size(PAUX%PAPRSF, 2) < l) return
    if (size(PAUX%PGEOM1, 1) /= p) return
    if (size(PAUX%PGEOM1, 2) < l) return
    if (size(PAUX%PGEOMH, 1) /= p) return
    if (size(PAUX%PGEOMH, 2) < (l - 0 + 1)) return
    if (size(PAUX%PGELAT, 1) < p) return
    if (size(surface_catalog%gsp_rr%vt%t9, 1) < p) return
    if (size(surface_catalog%gsp_sb%vt%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sb%vt%t9, 2) < kdim%klevs) return
    if (size(surface_catalog%gsp_sb%vq%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sb%vq%t9, 2) < kdim%klevs) return
    if (size(FLUX%PFRSO(:, KDIM%KLEV), 1) < p) return
    if (size(FLUX%PFRTH(:, KDIM%KLEV), 1) < p) return
    if (size(PSURF%PEMIS, 1) < p) return
    if (size(PRAD%PHRLW, 1) /= p) return
    if (size(PRAD%PHRLW, 2) < l) return
    if (size(PRAD%PHRSW, 1) /= p) return
    if (size(PRAD%PHRSW, 2) < l) return
    if (size(surface_catalog%gsp_sg%vt%t9, 1) /= p) return
    if (size(surface_catalog%gsp_sg%vt%t9, 2) < kdim%klevsn) return
    if (size(surface_catalog%gsp_sb%vtl%t9(:, 1), 1) < p) return
    if (size(surface_catalog%gsp_sl%vlicd%t9, 1) < p) return
    if (size(surface_catalog%gsp_sl%vlict%t9, 1) < p) return
    if (size(surface_catalog%gsp_sl%vlmlt%t9, 1) < p) return
    if (size(surface_catalog%gsd_vf%vsst%p, 1) < p) return
    if (size(PSURF%ISOTY, 1) < p) return
    if (size(SURFL%ZFRTI, 1) /= p) return
    if (size(SURFL%ZFRTI, 2) < kdim%ktiles) return
    if (size(SURFL%ZALBTI, 1) /= p) return
    if (size(SURFL%ZALBTI, 2) < kdim%ktiles) return
    if (size(SURFL%ZWLMX, 1) < p) return
    if (size(surface_catalog%gsd_ws%vchar%p, 1) < p) return
    if (size(surface_catalog%gsd_ws%vcharhq%p, 1) < p) return
    if (size(surface_catalog%gsd_vf%vucur%p, 1) < p) return
    if (size(surface_catalog%gsd_vf%vvcur%p, 1) < p) return
    if (size(surface_catalog%gsd_ws%vustokes%p, 1) < p) return
    if (size(surface_catalog%gsd_ws%vvstokes%p, 1) < p) return
    if (size(AUXL%ZTSKRAD, 1) < p) return
    if (size(AUXL%ZSOTEU, 1) /= p) return
    if (size(AUXL%ZSOTEU, 2) < l) return
    if (size(AUXL%ZSOTEV, 1) /= p) return
    if (size(AUXL%ZSOTEV, 2) < l) return
    if (size(AUXL%ZSOBETA, 1) /= p) return
    if (size(AUXL%ZSOBETA, 2) < l) return
    if (size(SURFL%ZTHKICE, 1) < p) return
    if (size(SURFL%ZSNTICE, 1) < p) return
    if (size(GEMSL%ZAZ0M, 1) < p) return
    if (size(GEMSL%ZAZ0H, 1) < p) return
    if (size(PDIAG%PVDIS, 1) < p) return
    if (size(PDIAG%PVDISG, 1) < p) return
    if (size(PERTL%ZDISSGW, 1) /= p) return
    if (size(PERTL%ZDISSGW, 2) < l) return
    if (size(FLUX%PFTLHEV, 1) < p) return
    if (size(FLUX%PFTLHSB, 1) < p) return
    if (size(FLUX%PFWSB, 1) < p) return
    if (size(surface_catalog%gsd_vd%v10u%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%v10v%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%v2t%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%v2d%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%v2sh%p, 1) < p) return
    if (size(PDIAG%ZINV, 1) < p) return
    if (size(surface_catalog%gsd_vd%vblh%p, 1) < p) return
    if (size(PDIAG%ZEIS, 1) < p) return
    if (size(surface_catalog%gsd_vd%v10nu%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%v10nv%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%vzust%p, 1) < p) return
    if (size(SURFL%ZFRSOTI, 1) /= p) return
    if (size(SURFL%ZFRSOTI, 2) < kdim%ktiles) return
    if (size(SURFL%ZEVAPSNW, 1) < p) return
    if (size(PDIAG%PI10FG, 1) < p) return
    if (size(surface_catalog%gsd_vd%v10fgcv%p, 1) < p) return
    if (size(PDIAG%IPBLTYPE, 1) < p) return
    if (size(tendency%T, 1) /= p) return
    if (size(tendency%T, 2) < l) return
    if (size(tendency%q, 1) /= p) return
    if (size(tendency%q, 2) < l) return
    if (size(tendency%cld(:, :, NCLDQL), 1) /= p) return
    if (size(tendency%cld(:, :, NCLDQL), 2) < l) return
    if (size(tendency%cld(:, :, NCLDQI), 1) /= p) return
    if (size(tendency%cld(:, :, NCLDQI), 2) < l) return
    if (size(tendency%a, 1) /= p) return
    if (size(tendency%a, 2) < l) return
    if (size(tendency%u, 1) /= p) return
    if (size(tendency%u, 2) < l) return
    if (size(tendency%v, 1) /= p) return
    if (size(tendency%v, 2) < l) return
    if (size(tendency_loc%T, 1) /= p) return
    if (size(tendency_loc%T, 2) < l) return
    if (size(tendency_loc%q, 1) /= p) return
    if (size(tendency_loc%q, 2) < l) return
    if (size(tendency_loc%cld(:, :, NCLDQL), 1) /= p) return
    if (size(tendency_loc%cld(:, :, NCLDQL), 2) < l) return
    if (size(tendency_loc%cld(:, :, NCLDQI), 1) /= p) return
    if (size(tendency_loc%cld(:, :, NCLDQI), 2) < l) return
    if (size(tendency_loc%a, 1) /= p) return
    if (size(tendency_loc%a, 2) < l) return
    if (size(tendency_loc%u, 1) /= p) return
    if (size(tendency_loc%u, 2) < l) return
    if (size(tendency_loc%v, 1) /= p) return
    if (size(tendency_loc%v, 2) < l) return
    if (size(tendency_loc%tke, 1) /= p) return
    if (size(tendency_loc%tke, 2) < l) return
    if (size(PSURF%PTLE1, 1) < p) return
    if (size(PSURF%PUSTRTI, 1) /= p) return
    if (size(PSURF%PUSTRTI, 2) < kdim%ktiles) return
    if (size(PSURF%PVSTRTI, 1) /= p) return
    if (size(PSURF%PVSTRTI, 2) < kdim%ktiles) return
    if (size(PSURF%PAHFSTI, 1) /= p) return
    if (size(PSURF%PAHFSTI, 2) < kdim%ktiles) return
    if (size(PSURF%PEVAPTI, 1) /= p) return
    if (size(PSURF%PEVAPTI, 2) < kdim%ktiles) return
    if (size(PSURF%PTSKTI, 1) /= p) return
    if (size(PSURF%PTSKTI, 2) < kdim%ktiles) return
    if (size(SURFL%ZAHFTRTI, 1) /= p) return
    if (size(SURFL%ZAHFTRTI, 2) < kdim%ktiles) return
    if (size(SURFL%ZANDAYVT, 1) /= p) return
    if (size(SURFL%ZANDAYVT, 2) < ikvtypes) return
    if (size(SURFL%ZANFMVT, 1) /= p) return
    if (size(SURFL%ZANFMVT, 2) < ikvtypes) return
    if (size(FLUX%PDIFTS, 1) /= p) return
    if (size(FLUX%PDIFTS, 2) < (l - 0 + 1)) return
    if (size(FLUX%PDIFTQ, 1) /= p) return
    if (size(FLUX%PDIFTQ, 2) < (l - 0 + 1)) return
    if (size(FLUX%PDIFTL, 1) /= p) return
    if (size(FLUX%PDIFTL, 2) < (l - 0 + 1)) return
    if (size(FLUX%PDIFTI, 1) /= p) return
    if (size(FLUX%PDIFTI, 2) < (l - 0 + 1)) return
    if (size(FLUX%PSTRTU, 1) /= p) return
    if (size(FLUX%PSTRTU, 2) < (l - 0 + 1)) return
    if (size(FLUX%PSTRTV, 1) /= p) return
    if (size(FLUX%PSTRTV, 2) < (l - 0 + 1)) return
    if (size(FLUX%PTOFDU, 1) < p) return
    if (size(FLUX%PTOFDV, 1) < p) return
    if (size(FLUX%PSTRDU, 1) /= p) return
    if (size(FLUX%PSTRDU, 2) < (l - 0 + 1)) return
    if (size(FLUX%PSTRDV, 1) /= p) return
    if (size(FLUX%PSTRDV, 2) < (l - 0 + 1)) return
    if (size(PDIAG%PKH_VDF, 1) /= p) return
    if (size(PDIAG%PKH_VDF, 2) < l) return
    if (size(PDIAG%PKM_VDF, 1) /= p) return
    if (size(PDIAG%PKM_VDF, 2) < l) return
    if (size(PDIAG%ZRI, 1) /= p) return
    if (size(PDIAG%ZRI, 2) < l) return
    if (size(surface_catalog%gsd_vd%vigpp%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%virec%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%vinee%p, 1) < p) return
    if (size(surface_catalog%gsd_vd%vich4%p, 1) < p) return
    if (size(PDDHS%PDHTLS, 1) /= p) return
    if (size(PDDHS%PDHTLS, 2) /= kdim%ktiles) return
    if (size(PDDHS%PDHTLS, 3) < kdim%kdhvtls + kdim%kdhftls) return
    if (size(PDDHS%PDHTSS, 1) /= p) return
    if (size(PDDHS%PDHTSS, 2) /= kdim%klevsn) return
    if (size(PDDHS%PDHTSS, 3) < kdim%kdhvtss + kdim%kdhftss) return
    if (size(PDDHS%PDHTTS, 1) /= p) return
    if (size(PDDHS%PDHTTS, 2) /= kdim%klevs) return
    if (size(PDDHS%PDHTTS, 3) < kdim%kdhvtts + kdim%kdhftts) return
    if (size(PDDHS%PDHTIS, 1) /= p) return
    if (size(PDDHS%PDHTIS, 2) /= kdim%klevi) return
    if (size(PDDHS%PDHTIS, 3) < kdim%kdhvtis + kdim%kdhftis) return
    if (size(SURFL%ZDHVEGS, 1) /= p) return
    if (size(SURFL%ZDHVEGS, 2) /= ikvtypes) return
    if (size(SURFL%ZDHVEGS, 3) < ikdhvvegs + ikdhfvegs) return
    if (size(surface_catalog%gsd_vf%vcgpp%p, 1) < p) return
    if (size(surface_catalog%gsd_vf%vcrec%p, 1) < p) return
    allocate (zevapmu(p), zan(p), zrd(p), zrsoil_str(p), zdhco2s(p, ikvtypes, ikdhvco2s + ikdhfco2s), &
              zgp2dspp(p, nrf), zexdiag(p, 12), empty_state(p, l, 0), empty_tendency(p, l, 0), &
              empty_flux_in(p, 0), empty_deposition(p, 0), empty_flux_out(p, 0), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32
      return
    end if

    CLCONF = 'F'  !  Not needed. It just has to be anything else from 'T', so why not 'F' :-)

    ZRCPD = 1.0_real64/physical%rcpd

!   Create space for diagnostic array (for possible pp of canopy resitances)
!   Put LAT/LON in field 1 an 2, just in case that it is needed in SURF for debugging.
    IDIAG = 12
    DO JL = KDIM%KIDIA, KDIM%KFDIA
      ZEXDIAG(JL, 11) = PAUX%PGELAT(JL) ! Latitude
      ZEXDIAG(JL, 12) = PAUX%PGELAM(JL) ! Longitude
    END DO

!   Stochastic variable with 0. mean and sd 1. (for the moment set to 0;
!   has to be in the argument list and provided by CALLPAR)

    DO JRF = 1, spp%SM%NRFTOTAL
      DO JL = KDIM%KIDIA, KDIM%KFDIA
        ZGP2DSPP(JL, JRF) = PPERT%PGP2DSPP(JL, 1, JRF)
      END DO
    END DO

!*         1.     UNROLL THE DERIVED STRUCTURES AND CALL VDFMAINS

    !  & ZR0VT  , &
    ! OUTPUT
    ! Input tendencies
    ! OUTPUT TENDENDCIES
    ! UPDATED FIELDS FOR TILES
    !-UPDATED FIELDS FOR VEGETATION TYPES
    ! FLUX OUTPUTS
    ! DDH OUTPUTS
    ! BFAS ADJUSTMENT COEFFICIENTS FOR CTESSEL CO2 VEGETATION FLUXES
    CALL VDFOUTER(physical, thermal, stability, parameters, model%physics, parameters%surface, spp, controls, &
      & planet_scale, rplrg, source_time_step, current_step, CLCONF,&
      & KDIM%KIDIA, KDIM%KFDIA, KDIM%KLON, KDIM%KLEV, KDIM%KLEVS, KDIM%KTILES, IKVTYPES, IDIAG, &
     & GEMSL%ITRAC, empty_indices, empty_indices, KDIM%KLEVSN, KDIM%KLEVI, KDIM%KDHVTLS, KDIM%KDHFTLS, KDIM%KDHVTSS, KDIM%KDHFTSS, &
      & KDIM%KDHVTTS, KDIM%KDHFTTS, KDIM%KDHVTIS, KDIM%KDHFTIS, &
      & IKDHVCO2S, IKDHFCO2S, IKDHVVEGS, IKDHFVEGS, &
      & model%physics_auxiliary%tsphy, PSURF%ITVL, PSURF%ICO2TYP, PSURF%ITVH, PSURF%PCVL, PSURF%PCVH, PSURF%PCUR, &
      & PSURF%PLAIL, PSURF%PLAIH, surface_catalog%gsd_vf%vfwet%p, surface_catalog%gsp_sg%vf%t9, &
      & surface_catalog%gsp_sg%vr%t9, PAUX%PMU0, SURFL%ZHSDFOR, &
      & state%u, state%v, state%T, state%q, state%tke,&
      & state%cld(:, :, NCLDQL), state%cld(:, :, NCLDQI), state%a, empty_state, &
      & PAUX%PAPRS, PAUX%PAPRSF, PAUX%PGEOM1, PAUX%PGEOMH, PAUX%PGELAT, surface_catalog%gsp_rr%vt%t9, &
      & surface_catalog%gsp_sb%vt%t9, surface_catalog%gsp_sb%vq%t9, &
      & FLUX%PFRSO(:, KDIM%KLEV), FLUX%PFRTH(:, KDIM%KLEV), PSURF%PEMIS, PRAD%PHRLW, PRAD%PHRSW, &
      & surface_catalog%gsp_sg%vt%t9, surface_catalog%gsp_sb%vtl%t9(:, 1), &
      & surface_catalog%gsp_sl%vlicd%t9, surface_catalog%gsp_sl%vlict%t9, &
      & surface_catalog%gsp_sl%vlmlt%t9, &
      & surface_catalog%gsd_vf%vsst%p, PSURF%ISOTY, SURFL%ZFRTI, SURFL%ZALBTI, SURFL%ZWLMX, &
      & surface_catalog%gsd_ws%vchar%p, surface_catalog%gsd_ws%vcharhq%p, &
      & surface_catalog%gsd_vf%vucur%p, surface_catalog%gsd_vf%vvcur%p, &
      & surface_catalog%gsd_ws%vustokes%p, surface_catalog%gsd_ws%vvstokes%p, &
      & AUXL%ZTSKRAD, empty_flux_in, empty_deposition, AUXL%ZSOTEU, AUXL%ZSOTEV, AUXL%ZSOBETA, &
      & SURFL%ZTHKICE, SURFL%ZSNTICE, ZGP2DSPP, &
      & model%climate%lnemosicoup, &
      & GEMSL%ZAZ0M, GEMSL%ZAZ0H, &
      & PDIAG%PVDIS, PDIAG%PVDISG, PERTL%ZDISSGW, FLUX%PFTLHEV, FLUX%PFTLHSB, FLUX%PFWSB, &
      & surface_catalog%gsd_vd%v10u%p, surface_catalog%gsd_vd%v10v%p, surface_catalog%gsd_vd%v2t%p, &
      & surface_catalog%gsd_vd%v2d%p, surface_catalog%gsd_vd%v2sh%p, PDIAG%ZINV, &
      & surface_catalog%gsd_vd%vblh%p, PDIAG%ZEIS, &
      & surface_catalog%gsd_vd%v10nu%p, surface_catalog%gsd_vd%v10nv%p, surface_catalog%gsd_vd%vzust%p, &
      & SURFL%ZFRSOTI, SURFL%ZEVAPSNW, ZEVAPMU, ZEXDIAG, PDIAG%PI10FG, surface_catalog%gsd_vd%v10fgcv%p, PDIAG%IPBLTYPE, &
      & tendency%T, tendency%q, tendency%cld(:, :, NCLDQL), tendency%cld(:, :, NCLDQI), &
      & tendency%a, tendency%u, tendency%v, &
      & tendency_loc%T, tendency_loc%q, tendency_loc%cld(:, :, NCLDQL), tendency_loc%cld(:, :, NCLDQI), &
      & tendency_loc%a, tendency_loc%u, tendency_loc%v, tendency_loc%tke,&
      & empty_tendency, PSURF%PTLE1, &
      & PSURF%PUSTRTI, PSURF%PVSTRTI, PSURF%PAHFSTI, PSURF%PEVAPTI, PSURF%PTSKTI, &
      & SURFL%ZAHFTRTI, &
      & SURFL%ZANDAYVT, SURFL%ZANFMVT,&
      & FLUX%PDIFTS, FLUX%PDIFTQ, FLUX%PDIFTL, FLUX%PDIFTI, FLUX%PSTRTU, FLUX%PSTRTV, FLUX%PTOFDU, FLUX%PTOFDV, &
      & FLUX%PSTRDU, FLUX%PSTRDV, PDIAG%PKH_VDF, PDIAG%PKM_VDF, PDIAG%ZRI, &
      & ZAN, surface_catalog%gsd_vd%vigpp%p, ZRD, ZRSOIL_STR, &
      & surface_catalog%gsd_vd%virec%p, surface_catalog%gsd_vd%vinee%p, surface_catalog%gsd_vd%vich4%p, empty_flux_out, &
      & PDDHS%PDHTLS, PDDHS%PDHTSS, PDDHS%PDHTTS, PDDHS%PDHTIS, &
      & ZDHCO2S, SURFL%ZDHVEGS, &
      & PCGPP=surface_catalog%gsd_vf%vcgpp%p, PCREC=surface_catalog%gsd_vf%vcrec%p, status=status)

    if (status /= 0_int32) return

! key for shallow convection (always on)
    DO JL = KDIM%KIDIA, KDIM%KFDIA
      LLKEYS%LLSHCV(JL) = .TRUE.
    END DO

! surface flux of u,v momentum due to gwd
    DO JL = KDIM%KIDIA, KDIM%KFDIA
      PDIAG%PUSTRG(JL) = FLUX%PSTRDU(JL, KDIM%KLEV)
      PDIAG%PVSTRG(JL) = FLUX%PSTRDV(JL, KDIM%KLEV)
    END DO

! Put ZEVAPMU (potential evaporation) into new field for pp
    DO JL = KDIM%KIDIA, KDIM%KFDIA
      IF (surface_catalog%gsd_vf%vlsm%p(JL) > 0.5_real64) THEN
        PSURF%PEVAPMU(JL) = ZEVAPMU(JL)
      ELSE
        PSURF%PEVAPMU(JL) = 0.0_real64
      END IF
    END DO

    status = 0_int32
  end subroutine turbulence_layer
end module forecast_native_turbulence_layer
