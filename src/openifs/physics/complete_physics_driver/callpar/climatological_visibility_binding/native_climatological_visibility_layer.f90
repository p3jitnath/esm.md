!> Borrow native work fields for the complete climatological visibility stage.
!! This adapter has no weather payload and creates no copied field array.
!! The separate-depth entry retains the frozen flat calculation's exact order.
module forecast_native_climatological_visibility_layer
  use iso_fortran_env, only: int32, int64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_physics_work_types, only: dimension_type, aux_type, state_type, surf_and_more_type, gems_local_type
  use surface_field_configuration_port, only: surface_field_registry
  use yoe_aerodiag, only: jpaero_wvl_aod
  use forecast_climatological_visibility_separate_depths, only: runtime_climatological_visibility_layer
  implicit none
  private
  public :: callpar_climatological_visibility
contains
  !> Bind the original CLIMAER_LAYER roles to their actual native owners.
  !! The grid supplies P=KLON columns and L=KLEV layers, with first column1.
  !! STATE_TMP supplies T in K, humidity/cloud amounts in kg/kg and cloud
  !! fraction. AUX supplies pressures in Pa and dimensionless angular fields.
  !! Readonly table views come from the live radiation configuration.
  !! Only six selected surface optical-depth columns and LOCAL's ZCLAERS
  !! and ZVISICL outputs change. Their inactive columns retain incoming bits.
  !! The caller owns disjoint initialized records and dense array targets.
  !! The routine performs no allocation; its numerical child owns and frees
  !! only the private workspace already declared by the frozen flat entry.
  subroutine callpar_climatological_visibility(physical,thermal,parameters,model,catalog,d,aux,state0,tmp,surface,local,heap_budget,status)
    type(forecast_physical_constants), intent(in) :: physical
    type(thermal_parameter_record), intent(in) :: thermal
    type(native_ecmwf_physics_state), intent(in) :: parameters
    type(native_operational_model_configuration), intent(in) :: model
    type(surface_field_registry), intent(in) :: catalog
    type(dimension_type), intent(in) :: d
    type(aux_type), intent(in) :: aux
    type(state_type), intent(in) :: state0, tmp
    type(surf_and_more_type), intent(inout) :: surface
    type(gems_local_type), intent(inout) :: local
    integer(int64), intent(in) :: heap_budget
    integer(int32), intent(out) :: status
    integer(int32) :: skin, columns(6), i, j, p, l
    status = 2_int32
    p = d%klon; l = d%klev
    if (p < 1 .or. p > 128 .or. l < 2 .or. l > 137 .or. d%kidia /= 1 .or. d%kfdia < 1 .or. d%kfdia > p) return
    if (.not. model%physics%ecmwf_physics%leradimpl) return
    skin = field_index(catalog, 'YSP_RR%YT', 3, 1)
    columns(1) = field_index(catalog, 'YSD_VD%YAERO_WVL_DIAG', 1, jpaero_wvl_aod)
    columns(2) = field_index(catalog, 'YSD_VD%YODSS', 1, 1)
    columns(3) = field_index(catalog, 'YSD_VD%YODDU', 1, 1)
    columns(4) = field_index(catalog, 'YSD_VD%YODOM', 1, 1)
    columns(5) = field_index(catalog, 'YSD_VD%YODBC', 1, 1)
    columns(6) = field_index(catalog, 'YSD_VD%YODSU', 1, 1)
    if (skin < 1 .or. any(columns < 1)) return
    do i = 1, 6
      do j = i + 1, 6
        if (columns(i) == columns(j)) return
      end do
    end do
    if (.not. associated(surface%psp_rr) .or. .not. associated(surface%psd_vd)) return
    if (size(surface%psp_rr, 1) /= p .or. size(surface%psp_rr, 2) < skin) return
    if (size(surface%psd_vd, 1) /= p .or. size(surface%psd_vd, 2) < maxval(columns)) return
    if (.not. is_contiguous(surface%psp_rr) .or. .not. is_contiguous(surface%psd_vd)) return
    if (.not. associated(aux%prs1) .or. .not. associated(aux%prsf1)) return
    if (.not. associated(aux%pgelam) .or. .not. associated(aux%pgemu)) return
    if (.not. associated(aux%pclon) .or. .not. associated(aux%pslon)) return
    if (.not. associated(tmp%t) .or. .not. associated(tmp%q) .or. .not. associated(tmp%a) .or. .not. associated(tmp%cld)) return
    if (.not. associated(local%zclaers) .or. .not. associated(local%zvisicl)) return
    if (lbound(aux%prs1, 2) /= 0) return
    if (size(aux%prs1, 1) /= p .or. size(aux%prs1, 2) /= l + 1) return
    if (.not. is_contiguous(aux%prs1)) return
    if (.not. parameters%radiation%ecrad_acquired) return
    associate (r => parameters%radiation, a => parameters%radiation%ecrad%config%aerosol_optics)
      call runtime_climatological_visibility_layer(r%aerosol_distribution, r%radiation, r%ozone, r%tegen, r%cams, &
                                                 physical, thermal, d%kidia, d%kfdia, p, l, model%physics%ecmwf_physics%leradimpl, &
                             model%physics%linear_ecmwf%lphylin, aux%prs1, aux%prsf1, aux%pgelam, aux%pgemu, aux%pclon, aux%pslon, &
                                                   tmp%t, tmp%q, tmp%a, tmp%cld, surface%psp_rr(:, skin), &
                                                   a%iclass, a%itype, a%mass_ext_sw_phobic, a%mass_ext_sw_philic, a%rh_lower, &
                                      surface%psd_vd(:, columns(1)), surface%psd_vd(:, columns(2)), surface%psd_vd(:, columns(3)), &
                                      surface%psd_vd(:, columns(4)), surface%psd_vd(:, columns(5)), surface%psd_vd(:, columns(6)), &
                                                   local%zclaers, local%zvisicl, heap_budget, status)
    end associate
  end subroutine

  !> Resolve a current field index from the one source-ordered native catalog.
  integer(int32) function field_index(catalog, name, slot, second_index) result(index)
    type(surface_field_registry), intent(in) :: catalog
    character(len=*), intent(in) :: name
    integer, intent(in) :: slot, second_index
    integer :: i, g, f
    index = 0
    if (.not. catalog%ready .or. slot < 1 .or. slot > 4 .or. second_index < 1) return
    do i = 1, size(catalog%aliases)
      if (catalog%aliases(i)%name /= name) cycle
      g = catalog%aliases(i)%group; f = catalog%aliases(i)%first_field
      if (catalog%aliases(i)%rank == 2) then
        if (second_index > catalog%aliases(i)%extent2) return
        f = f + catalog%aliases(i)%extent1*(second_index - 1)
      else if (second_index /= 1) then
        return
      end if
      if (g < 1 .or. g > size(catalog%groups)) return
      if (.not. allocated(catalog%groups(g)%fields)) return
      if (f < 1 .or. f > size(catalog%groups(g)%fields)) return
      if (catalog%groups(g)%fields(f)%initialized /= 1_int32) return
      index = catalog%groups(g)%fields(f)%indices(slot)
      return
    end do
  end function
end module forecast_native_climatological_visibility_layer
