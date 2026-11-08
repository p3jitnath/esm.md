!> Bind native primitive physics views to complete owned children.
!> Metadata columns come from the one actual surface catalog. All arrays
!> borrow their current registry owners and remain live during the call.
module forecast_shared_primitive_physics_layers
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_intptr_t, c_loc
  use forecast_physics_work_types, only: DIMENSION_TYPE, STATE_TYPE, AUX_TYPE, AUX_RAD_TYPE, &
                                         SURF_AND_MORE_TYPE, GEMS_LOCAL_TYPE, AUX_DIAG_TYPE
  use forecast_uncoupled_ocean_fields, only: uncoupled_ocean_fields, surface_ocean_layer
  use physical_constant_setup_port, only: forecast_physical_constants
  use radiation_config, only: config_type
  use yoerad, only: TERAD
  use yoerdi, only: TERDI
  use yoecld, only: TECLD
  use forecast_complete_shared_cloud_diagnostics, only: cldpp_selected
  use forecast_primitive_physics_layers, only: cloud_cover_surface_columns
  use forecast_primitive_physics_layers_no_clock, only: cloud_radiation_layer_runtime => cloud_radiation_layer_no_clock
  implicit none
  private
  public :: cloud_cover_surface_columns, cloud_radiation_layer_selected, cloud_radiation_layer_runtime, visibility_layer
  public :: uncoupled_ocean_fields, surface_ocean_layer
  type storage_span
    integer(c_intptr_t) :: first = 0_c_intptr_t, last = 0_c_intptr_t
  end type
  interface
    subroutine reject_contract() bind(c, name='abort')
    end subroutine
  end interface
contains
  !> Pressure is Pa, temperature K, latitude/longitude rad, cloud water kg/kg.
  !> Five surface covers and three radiation arrays receive the original child
  !> updates. PCC and other source-unwritten cells retain the same owners.
  subroutine cloud_radiation_layer_selected(constants, configuration, radiation, gases, cloud, &
                                            d, aux, state, surface, rad, columns)
    type(forecast_physical_constants), target, intent(in) :: constants
    type(config_type), target, intent(inout) :: configuration
    type(TERAD), target, intent(inout) :: radiation
    type(TERDI), target, intent(inout) :: gases
    type(TECLD), target, intent(inout) :: cloud
    type(DIMENSION_TYPE), target, intent(in) :: d
    type(AUX_TYPE), target, intent(in) :: aux
    type(STATE_TYPE), target, intent(in) :: state
    type(SURF_AND_MORE_TYPE), target, intent(inout) :: surface
    type(AUX_RAD_TYPE), target, intent(inout) :: rad
    type(cloud_cover_surface_columns), target, intent(in) :: columns
    type(storage_span) :: arrays(11), records(11)
    integer(int32) :: p, l, planes, fields, metadata(5)
    integer :: i, j
    p = d%klon; l = d%klev
    if (p < 1 .or. p > 2048 .or. l < 3 .or. l > 512) call reject_contract()
    if (d%kidia < 1 .or. d%kidia > p .or. d%kfdia < 0 .or. d%kfdia > p) call reject_contract()
    if (.not. associated(state%cld) .or. .not. associated(surface%psd_vd)) call reject_contract()
    planes = size(state%cld, 3); fields = size(surface%psd_vd, 2)
    if (planes < 2 .or. planes > 4096 .or. fields < 1 .or. fields > 4096) call reject_contract()
    if (.not. span_r2(aux%prs1, p, l + 1, arrays(1), .true.)) call reject_contract()
    if (.not. span_r2(aux%prsf1, p, l, arrays(2))) call reject_contract()
    if (.not. span_r2(state%a, p, l, arrays(3))) call reject_contract()
    if (.not. span_r3(state%cld, p, l, planes, arrays(4))) call reject_contract()
    if (.not. span_r2(state%t, p, l, arrays(5))) call reject_contract()
    if (.not. span_r1(aux%pgelat, p, arrays(6))) call reject_contract()
    if (.not. span_r1(aux%pgelam, p, arrays(7))) call reject_contract()
    if (.not. span_r2(surface%psd_vd, p, fields, arrays(8))) call reject_contract()
    if (.not. span_r2(rad%pneb, p, l, arrays(9))) call reject_contract()
    if (.not. span_r2(rad%pqice, p, l, arrays(10))) call reject_contract()
    if (.not. span_r2(rad%pqli, p, l, arrays(11))) call reject_contract()
    metadata = [columns%ccc, columns%hcc, columns%lcc, columns%mcc, columns%tcc]
    if (any(metadata < 1) .or. any(metadata > fields)) call reject_contract()
    do i = 1, 5
      do j = 1, i - 1
        if (metadata(i) == metadata(j)) call reject_contract()
      end do
    end do
    if (.not. owner_span(c_loc(constants), storage_size(constants, kind=int64)/8_int64, records(1))) call reject_contract()
    if (.not. owner_span(c_loc(configuration), storage_size(configuration, kind=int64)/8_int64, records(2))) call reject_contract()
    if (.not. owner_span(c_loc(radiation), storage_size(radiation, kind=int64)/8_int64, records(3))) call reject_contract()
    if (.not. owner_span(c_loc(gases), storage_size(gases, kind=int64)/8_int64, records(4))) call reject_contract()
    if (.not. owner_span(c_loc(cloud), storage_size(cloud, kind=int64)/8_int64, records(5))) call reject_contract()
    if (.not. owner_span(c_loc(d), storage_size(d, kind=int64)/8_int64, records(6))) call reject_contract()
    if (.not. owner_span(c_loc(aux), storage_size(aux, kind=int64)/8_int64, records(7))) call reject_contract()
    if (.not. owner_span(c_loc(state), storage_size(state, kind=int64)/8_int64, records(8))) call reject_contract()
    if (.not. owner_span(c_loc(surface), storage_size(surface, kind=int64)/8_int64, records(9))) call reject_contract()
    if (.not. owner_span(c_loc(rad), storage_size(rad, kind=int64)/8_int64, records(10))) call reject_contract()
    if (.not. owner_span(c_loc(columns), storage_size(columns, kind=int64)/8_int64, records(11))) call reject_contract()
    do i = 8, 11
      do j = 1, 11
        if (i == j) cycle
        if (intersects(arrays(i), arrays(j))) call reject_contract()
      end do
      do j = 1, 11
        if (intersects(arrays(i), records(j))) call reject_contract()
      end do
    end do
    call cldpp_selected(constants, configuration, radiation, gases, cloud, d%kidia, d%kfdia, p, l, &
                    aux%prs1, aux%prsf1, state%a, state%cld(:, :, 1), state%cld(:, :, 2), state%t, aux%pgelat, aux%pgelam, .true., &
                        surface%psd_vd(:, metadata(1)), surface%psd_vd(:, metadata(2)), surface%psd_vd(:, metadata(3)), &
                        surface%psd_vd(:, metadata(4)), surface%psd_vd(:, metadata(5)), rad%pneb, rad%pqice, rad%pqli)
  end subroutine
  !> The declared zero-aerosol route copies its existing visibility values.
  !> The complete active interval is copied bitwise, without FP arithmetic.
  subroutine visibility_layer(active_aerosol_count, d, local, diagnostics)
    integer(int32), intent(in) :: active_aerosol_count
    type(DIMENSION_TYPE), intent(in) :: d
    type(GEMS_LOCAL_TYPE), intent(in) :: local
    type(AUX_DIAG_TYPE), intent(inout) :: diagnostics
    integer :: j
    if (active_aerosol_count /= 0) call reject_contract()
    if (d%kidia > d%kfdia) return
    if (d%kidia < 1 .or. d%kfdia > d%klon) call reject_contract()
    if (.not. associated(local%ZVISICL)) call reject_contract()
    if (.not. associated(diagnostics%PVISIH)) call reject_contract()
    if (lbound(local%ZVISICL, 1) /= 1 .or. size(local%ZVISICL) < d%klon) call reject_contract()
    if (lbound(diagnostics%PVISIH, 1) /= 1 .or. size(diagnostics%PVISIH) < d%klon) call reject_contract()
    do j = d%kidia, d%kfdia
      diagnostics%PVISIH(j) = local%ZVISICL(j)
    end do
  end subroutine
  !> Record the complete half-open span of one native owner.
  logical function owner_span(address, bytes, span) result(valid)
    type(c_ptr), intent(in) :: address
    integer(int64), intent(in) :: bytes
    type(storage_span), intent(out) :: span
    integer(c_intptr_t) :: first
    valid = .false.
    span = storage_span()
    first = transfer(address, first)
    if (first <= 0_c_intptr_t .or. bytes <= 0_int64) return
    if (first > huge(first) - bytes) return
    span%first = first
    span%last = first + bytes
    valid = .true.
  end function owner_span

  !> Test whether two complete nonempty spans share a byte.
  logical function intersects(first, second) result(overlap)
    type(storage_span), intent(in) :: first, second
    overlap = first%first < second%last .and. second%first < first%last
  end function intersects

  !> Admit a dense native real64 row with bounds starting at one.
  logical function span_r1(array, n1, span) result(valid)
    real(real64), pointer, intent(in) :: array(:)
    integer(int32), intent(in) :: n1
    type(storage_span), intent(out) :: span
    valid = .false.
    if (.not. associated(array)) return
    if (any(lbound(array) /= 1_int32) .or. size(array) /= n1) return
    if (.not. is_contiguous(array)) return
    valid = owner_span(c_loc(array(1)), int(n1, int64)*8_int64, span)
  end function span_r1

  !> Admit a dense native matrix, retaining the qualified zero-origin pressure view.
  logical function span_r2(array, n1, n2, span, zero_origin) result(valid)
    real(real64), pointer, intent(in) :: array(:, :)
    integer(int32), intent(in) :: n1, n2
    type(storage_span), intent(out) :: span
    logical, optional, intent(in) :: zero_origin
    integer(int32) :: lower
    integer(int64) :: elements
    valid = .false.
    if (.not. associated(array)) return
    if (lbound(array, 1) /= 1_int32) return
    lower = lbound(array, 2)
    if (lower /= 1_int32) then
      if (.not. present(zero_origin)) return
      if (.not. zero_origin .or. lower /= 0_int32) return
    end if
    if (any(shape(array) /= [n1, n2]) .or. .not. is_contiguous(array)) return
    elements = int(n1, int64)*int(n2, int64)
    if (elements > 67108864_int64) return
    valid = owner_span(c_loc(array(1, lower)), elements*8_int64, span)
  end function span_r2

  !> Admit the complete dense native cloud owner, including its unused planes.
  logical function span_r3(array, n1, n2, n3, span) result(valid)
    real(real64), pointer, intent(in) :: array(:, :, :)
    integer(int32), intent(in) :: n1, n2, n3
    type(storage_span), intent(out) :: span
    integer(int64) :: elements
    valid = .false.
    if (.not. associated(array)) return
    if (any(lbound(array) /= 1_int32)) return
    if (any(shape(array) /= [n1, n2, n3]) .or. .not. is_contiguous(array)) return
    elements = int(n1, int64)*int(n2, int64)*int(n3, int64)
    if (elements > 67108864_int64) return
    valid = owner_span(c_loc(array(1, 1, 1)), elements*8_int64, span)
  end function span_r3

end module forecast_shared_primitive_physics_layers
