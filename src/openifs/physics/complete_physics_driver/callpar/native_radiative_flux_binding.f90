!> Bind the unchanged runtime radiative caller to the shared native work records.
!! SKIN_INDEX is the actual YSP_RR%YT MP9 catalog entry, not a copied surface owner.
!! This metadata-only revision leaves the frozen heating calculation unchanged.
module forecast_native_record_radiative_flux_layer
  use iso_fortran_env, only: int32, int64, real64
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yomphy2, only: tphy2
  use yomphy3, only: tphy3
  use yoephy, only: tephy
  use forecast_physics_work_types, only: dimension_type, state_type, aux_rad_type, aux_type, &
                                         aux_diag_local_type, surf_and_more_type, flux_type, perturb_type, surf_and_more_local_type
  use spp_mod, only: tspp_config
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use dynamical_configuration_port, only: native_dynamical_configuration
  use forecast_radiative_heating, only: radheatn
  implicit none
  private
  public :: radiative_flux_model_views, runtime_radiative_flux_layer
  !> Borrow actual canonical parameter owners; this type owns no numerical data.
  !! Step and hook pointers keep explicit source context. The step is not read.
  type radiative_flux_model_views
    type(terad), pointer :: radiation => null()
    type(terdi), pointer :: radiation_diagnostics => null()
    type(tphy2), pointer :: physics2 => null()
    type(tphy3), pointer :: physics3 => null()
    type(tephy), pointer :: physics_options => null()
    integer(int32), pointer :: step => null()
    logical, pointer :: hook_enabled => null()
  end type
contains
  !> Clear the complete tendency, call owned RADHEATN and copy boundary fluxes.
  !! The original 14 argument roles and their order remain explicit.
  !! Native MODEL views borrow named records; no private MODEL bytes are read.
  !! P is 1:128 and L is 6:512. Fluxes are W/m^2; tendencies are K/s.
  !! The caller establishes nearest-even and gradual underflow once.
  !! Status 2 refuses unsupported metadata before any output mutation.
  subroutine runtime_radiative_flux_layer(skin_index, ydmodel, ydspp_config, kdim, paux, &
                                          state_t0, state_tmp, psurf, surfl, prad, auxl, flux, tendency_loc, ppert, &
                                          physical, dynamics, thermal, status)
    integer(int32), intent(in) :: skin_index
    type(radiative_flux_model_views), intent(in) :: ydmodel
    type(tspp_config), intent(in) :: ydspp_config
    type(dimension_type), intent(in) :: kdim
    type(aux_type), intent(in) :: paux
    type(state_type), intent(in) :: state_t0, state_tmp
    type(surf_and_more_type), intent(in) :: psurf
    type(surf_and_more_local_type), intent(in) :: surfl
    type(aux_rad_type), intent(inout) :: prad
    type(aux_diag_local_type), intent(inout) :: auxl
    type(flux_type), intent(inout) :: flux
    type(state_type), intent(inout) :: tendency_loc
    type(perturb_type), intent(in) :: ppert
    type(forecast_physical_constants), intent(in) :: physical
    type(native_dynamical_configuration), intent(in) :: dynamics
    type(thermal_parameter_record), intent(in) :: thermal
    integer(int32), intent(out) :: status
    real(real64), target :: empty_pattern_storage(0)
    real(real64), pointer, contiguous :: empty_patterns(:, :)
    integer(int32) :: p, l
    integer :: j, k
    status = 2
    p = kdim%klon
    l = kdim%klev
    if (p < 1 .or. p > 128 .or. l < 6 .or. l > 512) return
    if (kdim%kidia < 1 .or. kdim%kidia > p + 1) return
    if (kdim%kfdia < kdim%kidia - 1 .or. kdim%kfdia > p) return
    if (.not. associated(ydmodel%radiation)) return
    if (.not. associated(ydmodel%radiation_diagnostics)) return
    if (.not. associated(ydmodel%physics2)) return
    if (.not. associated(ydmodel%physics3)) return
    if (.not. associated(ydmodel%physics_options)) return
    if (.not. associated(ydmodel%step)) return
    if (.not. associated(ydmodel%hook_enabled)) return
    if (ydmodel%hook_enabled) return
    if (.not. ydmodel%physics_options%leradimpl) return
    if (ydspp_config%lspp .or. ydspp_config%sm%nrftotal /= 0) return
    if (ydmodel%radiation%nlwout /= 1) return
    if (.not. ydmodel%radiation%lmannersswupdate) return
    if (physical%initialized /= 1) return
    if (transfer(dynamics%rpldare, 0_int64) /= int(z'3ff0000000000000', int64)) return
    if (transfer(thermal%rvtmp2, 0_int64) /= 0_int64) return
    if (.not. associated(paux%prs1)) return
    if (.not. associated(psurf%pemis)) return
    if (.not. associated(surfl%zspectralemiss)) return
    if (.not. associated(prad%pemtd)) return
    if (.not. associated(paux%pmu0)) return
    if (.not. associated(paux%pmu0m)) return
    if (.not. associated(state_tmp%q)) return
    if (.not. associated(tendency_loc%t)) return
    if (.not. associated(prad%ptrsw)) return
    if (.not. associated(auxl%ztrsod)) return
    if (.not. associated(prad%psrlwd)) return
    if (.not. associated(prad%psrswdc)) return
    if (.not. associated(prad%psrlwdc)) return
    if (.not. associated(psurf%psp_rr)) return
    if (.not. associated(prad%phrsw)) return
    if (.not. associated(prad%phrlw)) return
    if (.not. associated(prad%phrsc)) return
    if (.not. associated(prad%phrlc)) return
    if (.not. associated(flux%pfrso)) return
    if (.not. associated(flux%pfrth)) return
    if (.not. associated(flux%pfrsod)) return
    if (.not. associated(flux%pfrsodc)) return
    if (.not. associated(flux%pfrthd)) return
    if (.not. associated(flux%pfrthdc)) return
    if (.not. associated(prad%pemtc)) return
    if (.not. associated(prad%ptrsc)) return
    if (.not. associated(flux%pfrsoc)) return
    if (.not. associated(flux%pfrthc)) return
    if (.not. associated(prad%pincsr)) return
    if (.not. associated(auxl%zsudu)) return
    if (.not. associated(prad%pisund)) return
    if (.not. associated(prad%pdsrp)) return
    if (.not. associated(prad%psrswuvb)) return
    if (.not. associated(prad%psrswpar)) return
    if (.not. associated(prad%psrswparc)) return
    if (.not. associated(prad%psrswtinc)) return
    if (.not. associated(prad%psrfdir)) return
    if (.not. associated(prad%psrcdir)) return
    if (.not. associated(flux%puvdf)) return
    if (.not. associated(flux%pparf)) return
    if (.not. associated(flux%pparcf)) return
    if (.not. associated(prad%ptincf)) return
    if (.not. associated(prad%pfdir)) return
    if (.not. associated(prad%pcdir)) return
    if (.not. associated(prad%derivativelw)) return
    if (.not. associated(auxl%zcemtr) .or. .not. associated(auxl%zctrso)) return
    if (skin_index < lbound(psurf%psp_rr, 2) .or. skin_index > ubound(psurf%psp_rr, 2)) return
    if (.not. fits2(paux%prs1, p, l + 1)) return
    if (.not. fits1(psurf%pemis, p)) return
    if (.not. fits2(prad%pemtd, p, l + 1)) return
    if (.not. fits1(paux%pmu0, p)) return
    if (.not. fits1(paux%pmu0m, p)) return
    if (.not. fits2(state_tmp%q, p, l)) return
    if (.not. fits2(tendency_loc%t, p, l)) return
    if (.not. fits2(prad%ptrsw, p, l + 1)) return
    if (.not. fits1(auxl%ztrsod, p)) return
    if (.not. fits2(prad%psrlwd, p, 1)) return
    if (.not. fits1(prad%psrswdc, p)) return
    if (.not. fits1(prad%psrlwdc, p)) return
    if (.not. fits1(psurf%psp_rr(:, skin_index), p)) return
    if (.not. fits2(prad%phrsw, p, l)) return
    if (.not. fits2(prad%phrlw, p, l)) return
    if (.not. fits2(prad%phrsc, p, l)) return
    if (.not. fits2(prad%phrlc, p, l)) return
    if (.not. fits2(flux%pfrso, p, l + 1)) return
    if (.not. fits2(flux%pfrth, p, l + 1)) return
    if (.not. fits1(flux%pfrsod, p)) return
    if (.not. fits1(flux%pfrsodc, p)) return
    if (.not. fits1(flux%pfrthd, p)) return
    if (.not. fits1(flux%pfrthdc, p)) return
    if (.not. fits2(prad%pemtc, p, l + 1)) return
    if (.not. fits2(prad%ptrsc, p, l + 1)) return
    if (.not. fits2(flux%pfrsoc, p, 2)) return
    if (.not. fits2(flux%pfrthc, p, 2)) return
    if (.not. fits1(prad%pincsr, p)) return
    if (.not. fits1(auxl%zsudu, p)) return
    if (.not. fits1(prad%pisund, p)) return
    if (.not. fits1(prad%pdsrp, p)) return
    if (.not. fits1(prad%psrswuvb, p)) return
    if (.not. fits1(prad%psrswpar, p)) return
    if (.not. fits1(prad%psrswparc, p)) return
    if (.not. fits1(prad%psrswtinc, p)) return
    if (.not. fits1(prad%psrfdir, p)) return
    if (.not. fits1(prad%psrcdir, p)) return
    if (.not. fits1(flux%puvdf, p)) return
    if (.not. fits1(flux%pparf, p)) return
    if (.not. fits1(flux%pparcf, p)) return
    if (.not. fits1(prad%ptincf, p)) return
    if (.not. fits1(prad%pfdir, p)) return
    if (.not. fits1(prad%pcdir, p)) return
    if (.not. fits2(prad%derivativelw, p, l + 1)) return
    if (size(tendency_loc%t, 2, kind=int64) /= int(l, int64)) return
    if (.not. fits2(auxl%zcemtr, p, 2) .or. .not. fits2(auxl%zctrso, p, 2)) return
    do k = lbound(tendency_loc%t, 2), ubound(tendency_loc%t, 2)
      do j = lbound(tendency_loc%t, 1), ubound(tendency_loc%t, 1)
        tendency_loc%t(j, k) = 0.0_real64
      end do
    end do
    ! NRFTOTAL is zero: retain a valid zero-payload native view without allocation.
    empty_patterns(1:p, 1:0) => empty_pattern_storage
    call radheatn( &
      ydmodel%radiation, ydmodel%radiation_diagnostics, ydmodel%physics2, ydmodel%physics3, ydspp_config, &
      kdim%kidia, kdim%kfdia, kdim%klon, kdim%klev, paux%prs1, &
      psurf%pemis, surfl%zspectralemiss, prad%pemtd, paux%pmu0, paux%pmu0m, &
      state_tmp%q, tendency_loc%t, prad%ptrsw, auxl%ztrsod, prad%psrlwd, &
      prad%psrswdc, prad%psrlwdc, psurf%psp_rr(:, skin_index), prad%phrsw, prad%phrlw, &
      prad%phrsc, prad%phrlc, flux%pfrso, flux%pfrth, flux%pfrsod, &
      flux%pfrsodc, flux%pfrthd, flux%pfrthdc, prad%pemtc, prad%ptrsc, &
      flux%pfrsoc, flux%pfrthc, prad%pincsr, auxl%zsudu, prad%pisund, &
      prad%pdsrp, prad%psrswuvb, prad%psrswpar, prad%psrswparc, prad%psrswtinc, &
      prad%psrfdir, prad%psrcdir, flux%puvdf, flux%pparf, flux%pparcf, &
      prad%ptincf, prad%pfdir, prad%pcdir, prad%derivativelw, prad%pneb, &
      paux%prsf1, empty_patterns, &
      physical, dynamics, thermal, status)
    if (status /= 0) return
    call copy_clear_boundaries(kdim%kidia, kdim%kfdia, flux%pfrthc, auxl%zcemtr, &
                               flux%pfrsoc, auxl%zctrso, prad%pincsr, prad%ptincf)
    status = 0
  end subroutine

  !> Use assumed-shape indexing to name each first declared boundary element.
  !! This is a borrowed native view; it changes no descriptor or owner address.
  subroutine copy_clear_boundaries(first, last, thermal, clear_thermal, solar, clear_solar, incident, total)
    integer(int32), intent(in) :: first, last
    real(real64), intent(inout) :: thermal(:, :), solar(:, :), total(:)
    real(real64), intent(in) :: clear_thermal(:, :), clear_solar(:, :), incident(:)
    real(real64), volatile :: value, product
    integer :: j
    do j = first, last
      value = clear_thermal(j, 1)
      thermal(j, 1) = value
      value = clear_thermal(j, 2)
      thermal(j, 2) = value
      value = incident(j)
      product = value*clear_solar(j, 1)
      solar(j, 1) = product
      product = value*clear_solar(j, 2)
      solar(j, 2) = product
      total(j) = value
    end do
  end subroutine

  logical function fits1(field, p)
    real(real64), intent(in) :: field(:)
    integer(int32), intent(in) :: p
    fits1 = is_contiguous(field) .and. size(field, kind=int64) >= int(p, int64)
  end function

  logical function fits2(field, p, levels)
    real(real64), intent(in) :: field(:, :)
    integer(int32), intent(in) :: p, levels
    fits2 = is_contiguous(field) .and. size(field, 1, kind=int64) == int(p, int64) .and. &
            size(field, 2, kind=int64) >= int(levels, int64)
  end function
end module
