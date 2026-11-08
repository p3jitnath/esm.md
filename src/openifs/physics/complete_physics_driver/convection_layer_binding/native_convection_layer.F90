!> Run the complete source-selected convection layer on native borrowed records.
!! The caller owns all field arrays and supplies nearest-even rounding with
!! gradual underflow. Temperature is K, pressure Pa, moisture kg/kg, velocity
!! m/s and the physics interval seconds. This wrapper owns no numerical field.
module forecast_native_convection_layer
  use iso_fortran_env, only: int32, int64, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use physics_configuration_state_port, only: physics_configuration_state
  use forecast_physics_work_types, only: DIMENSION_TYPE, STATE_TYPE, AUX_TYPE, &
                                         AUX_DIAG_TYPE, AUX_DIAG_LOCAL_TYPE, SURF_AND_MORE_TYPE, KEYS_LOCAL_TYPE, &
                                         PERTURB_LOCAL_TYPE, FLUX_TYPE, GEMS_LOCAL_TYPE, PERTURB_TYPE
  use surface_field_configuration_port, only: surface_field_registry
  use yomphy2, only: TPHY2
  use spp_mod, only: TSPP_CONFIG
  use forecast_convection_tendency_views, only: convection_tendency_views
  use convection_controller_mod, only: cucalln
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event
  implicit none
  private
  public :: convection_layer_model_views, runtime_owned_convection_layer
  !> Borrow the four model roles read by the original wrapper and controller.
  !! Associations must remain valid throughout the call. No target is owned here.
  type :: convection_layer_model_views
    type(TPHY2), pointer :: physics2 => null()
    type(TSPP_CONFIG), pointer :: stochastic => null()
    integer(int32), pointer :: active_aerosols => null()
    logical, pointer :: chem_light_active => null()
  end type
contains
  !> Forward the original seventeen field roles to the complete native controller.
  !! Providers precede the original argument order. KDIM supplies P columns,
  !! L levels and the inclusive active interval. The surface registry supplies
  !! the live YACPR MP selector; no historical private record address is used.
  !! Readonly STATE/CML/DYN/PAUX/PPERT payloads remain owned by the caller.
  !! LLKEYS/PDIAG/AUXL/PERTL/FLUX/PSURF/GEMSL/LOC retain source mutation.
  !! Valid array pointers must describe dense, sufficiently sized live targets.
  !! The controller checks the complete consumed array extents before its work.
  !! Return 2 for unsupported metadata, 0 after completion, or the child status
  !! after preceding child work. A child refusal does not roll back earlier work.
  integer(int32) function runtime_owned_convection_layer( &
    constants, thermal, rplrg, rpldare, parameters, configuration, current_step, &
    surface_registry, model_views, kdim, ldslphy, state, tendency_cml, tendency_dyn, &
    paux, ppert, llkeys, pdiag, auxl, pertl, flux, psurf, gemsl, tendency_loc, profile) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(real64), intent(in) :: rplrg, rpldare
    type(native_ecmwf_physics_state), intent(inout) :: parameters
    type(physics_configuration_state), intent(inout) :: configuration
    integer(int32), intent(in) :: current_step
    type(surface_field_registry), intent(in) :: surface_registry
    type(convection_layer_model_views), intent(in) :: model_views
    type(DIMENSION_TYPE), intent(in) :: kdim
    logical, intent(in) :: ldslphy
    type(STATE_TYPE), intent(in) :: state, tendency_cml, tendency_dyn
    type(AUX_TYPE), intent(in) :: paux
    type(PERTURB_TYPE), intent(in) :: ppert
    type(KEYS_LOCAL_TYPE), intent(inout) :: llkeys
    type(AUX_DIAG_TYPE), intent(inout) :: pdiag
    type(AUX_DIAG_LOCAL_TYPE), intent(inout) :: auxl
    type(PERTURB_LOCAL_TYPE), intent(inout) :: pertl
    type(FLUX_TYPE), intent(inout) :: flux
    type(SURF_AND_MORE_TYPE), intent(inout) :: psurf
    type(GEMS_LOCAL_TYPE), intent(inout) :: gemsl
    type(STATE_TYPE), intent(inout) :: tendency_loc
    type(transform_profile_policy), intent(in), optional :: profile
    type(convection_tendency_views) :: cml_views, dyn_views, loc_views
    real(real64), target :: empty_pattern_storage(0)
    real(real64), pointer, contiguous :: patterns(:, :), tracer_state(:, :, :), tracer_tendency(:, :, :)
    real(real64) :: hook_handle
    integer(int64) :: columns, levels, work_bytes
    integer(int32) :: alias_index, group_index, field_index, precipitation_index, matches

    status = 2_int32
    columns = int(kdim%KLON, int64)
    levels = int(kdim%KLEV, int64)
    if (columns < 1_int64 .or. columns > 4096_int64) return
    if (levels < 4_int64 .or. levels > 137_int64) return
    if (columns*levels > 65536_int64) return
    work_bytes = 60_int64*columns*levels + 8_int64*columns
    work_bytes = iand(work_bytes + 31_int64, not(15_int64))
    if (work_bytes > 1048576_int64) return
    if (kdim%KIDIA < 1 .or. int(kdim%KIDIA, int64) > columns) return
    if (kdim%KFDIA < 0 .or. int(kdim%KFDIA, int64) > columns) return
    if (.not. associated(model_views%physics2)) return
    if (.not. associated(model_views%stochastic)) return
    if (.not. associated(model_views%active_aerosols)) return
    if (.not. associated(model_views%chem_light_active)) return
    if (configuration%linear_ecmwf%LPHYLIN) return
    if (.not. configuration%ecmwf_physics%LEPCLD) return
    if (.not. parameters%convection%LMFDD) return
    call transform_profile_event('CONVECTION_LAYER', 0_int32, hook_handle, profile)
    if (model_views%stochastic%SM%NRFTOTAL /= 0) return

    ! The original unroll has no SPP iterations in this admitted branch.
    ! These zero-element native views need no payload allocation or copy.
    patterns(1:kdim%KLON, 1:0) => empty_pattern_storage
    if (.not. associated(state%T)) return
    if (.not. associated(state%Q)) return
    if (.not. associated(state%U)) return
    if (.not. associated(state%V)) return
    if (.not. associated(tendency_cml%T)) return
    if (.not. associated(tendency_cml%Q)) return
    if (.not. associated(tendency_cml%U)) return
    if (.not. associated(tendency_cml%V)) return
    if (.not. associated(tendency_dyn%T)) return
    if (.not. associated(tendency_dyn%Q)) return
    if (.not. associated(tendency_loc%T)) return
    if (.not. associated(tendency_loc%Q)) return
    if (.not. associated(tendency_loc%U)) return
    if (.not. associated(tendency_loc%V)) return
    if (.not. associated(llkeys%LLLAND)) return
    if (.not. associated(llkeys%LLCUM)) return
    if (.not. associated(llkeys%LLSC)) return
    if (.not. associated(llkeys%LLCUM_LIG)) return
    if (.not. associated(llkeys%LLSHCV)) return
    if (.not. associated(paux%PVERVEL)) return
    if (.not. associated(paux%PAPRS)) return
    if (.not. associated(paux%PRSF1)) return
    if (.not. associated(paux%PRS1)) return
    if (.not. associated(paux%PGEOM1)) return
    if (.not. associated(paux%PGEOMH)) return
    if (.not. associated(paux%PGAW)) return
    if (.not. associated(auxl%ZLISUM)) return
    if (.not. associated(auxl%ITOPC)) return
    if (.not. associated(auxl%IBASC)) return
    if (.not. associated(auxl%IBOTSC)) return
    if (.not. associated(auxl%ZLCRIT_AER)) return
    if (.not. associated(pertl%ZCUCONVCA)) return
    if (.not. associated(pertl%ZWMEAN)) return
    if (.not. associated(pertl%ZDISSCU)) return
    if (.not. associated(flux%PDIFTQ)) return
    if (.not. associated(flux%PDIFTS)) return
    if (.not. associated(flux%PDIFCQ)) return
    if (.not. associated(flux%PDIFCS)) return
    if (.not. associated(flux%PFHPCL)) return
    if (.not. associated(flux%PFHPCN)) return
    if (.not. associated(flux%PFPLCL)) return
    if (.not. associated(flux%PFPLCN)) return
    if (.not. associated(flux%PSTRCU)) return
    if (.not. associated(flux%PSTRCV)) return
    if (.not. associated(flux%PFCCQL)) return
    if (.not. associated(flux%PFCCQN)) return
    if (.not. associated(pdiag%ITYPE)) return
    if (.not. associated(pdiag%ICBOT)) return
    if (.not. associated(pdiag%ICTOP)) return
    if (.not. associated(pdiag%ICBOT_LIG)) return
    if (.not. associated(pdiag%ICTOP_LIG)) return
    if (.not. associated(pdiag%ZLU)) return
    if (.not. associated(pdiag%ZLUDE)) return
    if (.not. associated(pdiag%ZLUDELI)) return
    if (.not. associated(pdiag%ZSNDE)) return
    if (.not. associated(pdiag%PMFU)) return
    if (.not. associated(pdiag%PMFD)) return
    if (.not. associated(pdiag%ZLRAIN)) return
    if (.not. associated(pdiag%PRSUD)) return
    if (.not. associated(pdiag%PMFUDE_RATE)) return
    if (.not. associated(pdiag%PMFDDE_RATE)) return
    if (.not. associated(pdiag%PCAPE)) return
    if (.not. associated(pdiag%PVDISCU)) return
    if (.not. associated(psurf%PSD_VN)) return
    if (.not. associated(gemsl%ITRAC)) return
    if (.not. associated(gemsl%ZCEN)) return
    if (.not. associated(gemsl%ZTENC)) return
    if (.not. associated(gemsl%ZSCAV)) return
    if (gemsl%ITRAC /= 0) return
    if (.not. is_contiguous(gemsl%ZCEN)) return
    if (.not. is_contiguous(gemsl%ZTENC)) return
    if (.not. is_contiguous(gemsl%ZSCAV)) return
    tracer_state(1:kdim%KLON, 1:kdim%KLEV, 1:0) => gemsl%ZCEN
    tracer_tendency(1:kdim%KLON, 1:kdim%KLEV, 1:0) => gemsl%ZTENC

    ! Follow the actual metadata alias to its active ordinary scalar record.
    if (.not. surface_registry%ready) return
    matches = 0
    alias_index = 0
    do field_index = 1, size(surface_registry%aliases)
      if (surface_registry%aliases(field_index)%name /= 'YSD_VN%YACPR') cycle
      matches = matches + 1
      alias_index = field_index
    end do
    if (matches /= 1) return
    group_index = surface_registry%aliases(alias_index)%group
    field_index = surface_registry%aliases(alias_index)%first_field
    if (group_index < 1 .or. group_index > size(surface_registry%groups)) return
    if (.not. allocated(surface_registry%groups(group_index)%fields)) return
    if (field_index < 1) return
    if (field_index > size(surface_registry%groups(group_index)%fields)) return
    if (field_index > surface_registry%groups(group_index)%metadata%registered_fields) return
    if (surface_registry%groups(group_index)%metadata%registered_fields > &
        size(surface_registry%groups(group_index)%fields)) return
    if (surface_registry%groups(group_index)%fields(field_index)%initialized /= 1) return
    precipitation_index = surface_registry%groups(group_index)%fields(field_index)%indices(1)
    if (precipitation_index < 1 .or. precipitation_index > size(psurf%PSD_VN, 2)) return
    if (size(psurf%PSD_VN, 1) /= kdim%KLON) return

    cml_views%T => tendency_cml%T
    cml_views%Q => tendency_cml%Q
    cml_views%U => tendency_cml%U
    cml_views%V => tendency_cml%V
    dyn_views%T => tendency_dyn%T
    dyn_views%Q => tendency_dyn%Q
    loc_views%T => tendency_loc%T
    loc_views%Q => tendency_loc%Q
    loc_views%U => tendency_loc%U
    loc_views%V => tendency_loc%V
    status = cucalln(constants, thermal, rplrg, rpldare, parameters, configuration, current_step, &
                     parameters%radiation%radiation, model_views%active_aerosols, model_views%chem_light_active, &
                     model_views%stochastic, kdim%KIDIA, kdim%KFDIA, kdim%KLON, kdim%KSMAX, kdim%KLEV, &
                     llkeys%LLLAND, ldslphy, model_views%physics2%TSPHY, parameters%diffusion%RVDIFTS, &
                     state%T, state%Q, state%U, state%V, auxl%ZLISUM, paux%PVERVEL, flux%PDIFTQ, flux%PDIFTS, &
                     paux%PAPRS, paux%PRSF1, paux%PRS1, paux%PGEOM1, paux%PGEOMH, paux%PGAW, &
                     pertl%ZCUCONVCA, patterns, cml_views, loc_views, dyn_views, &
                     psurf%PSD_VN(:, precipitation_index), auxl%ITOPC, auxl%IBASC, pdiag%ITYPE, &
                     pdiag%ICBOT, pdiag%ICTOP, auxl%IBOTSC, llkeys%LLCUM, llkeys%LLSC, &
                     pdiag%ICBOT_LIG, pdiag%ICTOP_LIG, llkeys%LLCUM_LIG, llkeys%LLSHCV, auxl%ZLCRIT_AER, &
                     pdiag%ZLU, pdiag%ZLUDE, pdiag%ZLUDELI, pdiag%ZSNDE, pdiag%PMFU, pdiag%PMFD, &
                     flux%PDIFCQ, flux%PDIFCS, flux%PFHPCL, flux%PFHPCN, flux%PFPLCL, flux%PFPLCN, &
                     pdiag%ZLRAIN, pdiag%PRSUD, flux%PSTRCU, flux%PSTRCV, flux%PFCCQL, flux%PFCCQN, &
                     pdiag%PMFUDE_RATE, pdiag%PMFDDE_RATE, pdiag%PCAPE, pertl%ZWMEAN, pdiag%PVDISCU, pertl%ZDISSCU, &
                     gemsl%ITRAC, tracer_state, tracer_tendency, gemsl%ZSCAV(1:0))
    if (status /= 0_int32) return
    call transform_profile_event('CONVECTION_LAYER', 1_int32, hook_handle, profile)
  end function runtime_owned_convection_layer
end module forecast_native_convection_layer
