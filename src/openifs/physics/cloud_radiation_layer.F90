!> Port the seven-owner runtime_cloud_radiation_layer.S adapter.
module cloud_radiation_layer_mod
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_intptr_t, c_loc
  use iso_fortran_env, only: real64
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use type_model, only: model
  use surface_fields_mix, only: tsurf
  use yomphyder, only: dimension_type, state_type, aux_rad_type, aux_type, surf_and_more_type
  use yoecldp, only: ncldqi, ncldql
  use yomhook, only: lhook, dr_hook, jphook
  use cloud_cover_diagnostics_mod, only: cldpp
  implicit none
  private
  public :: cldprg_layer
  type :: storage_span
    integer(c_intptr_t) :: first = 0_c_intptr_t
    integer(c_intptr_t) :: last = 0_c_intptr_t
  end type storage_span
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Check live native owners and call the new CLDPP with its complete field views.
  !! The seven native arguments retain the original CLDPRG_LAYER order.
  !! KDIM selects up to 2048 columns and 3:512 levels; empty active intervals are supported.
  !! STATE stores temperature in K, dimensionless cloud fraction and cloud water in kg/kg.
  !! PAUX contains pressure in Pa and latitude and longitude in rad.
  !! PSURF owns five diagnostic columns, and PRAD owns three column-first radiation arrays.
  !! Only the active diagnostic and radiation output cells change; unused owners remain exact.
  !! The caller owns every native record and attached pointer target through completion.
  subroutine cldprg_layer(ydsurf, ydmodel, kdim, paux, state, psurf, prad)
    type(tsurf), target, intent(inout) :: ydsurf
    type(model), target, intent(inout) :: ydmodel
    type(dimension_type), target, intent(in) :: kdim
    type(aux_type), target, intent(in) :: paux
    type(state_type), target, intent(in) :: state
    type(surf_and_more_type), target, intent(inout) :: psurf
    type(aux_rad_type), target, intent(inout) :: prad
    type(storage_span) :: arrays(11), owners(12)
    integer(int32) :: columns, levels, planes, fields, index, other
    integer(int32) :: metadata(5)
    real(jphook) :: hook_handle
    logical :: diagnostics
    type(ieee_round_type) :: rounding
    real(real64), volatile :: operand, scale
    real(real64) :: probe

    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    operand = tiny(1.0_real64)
    scale = 0.5_real64
    probe = operand*scale
    if (probe == 0.0_real64) call reject_contract()
    columns = kdim%klon
    levels = kdim%klev
    if (columns < 1_int32 .or. columns > 2048_int32) call reject_contract()
    if (levels < 3_int32 .or. levels > 512_int32) call reject_contract()
    if (kdim%kidia < 1_int32 .or. kdim%kidia > columns) call reject_contract()
    if (kdim%kfdia < 0_int32 .or. kdim%kfdia > columns) call reject_contract()
    if (.not. associated(state%cld)) call reject_contract()
    planes = size(state%cld, 3)
    if (planes < 2_int32 .or. planes > 4096_int32) call reject_contract()
    if (.not. associated(psurf%psd_vd)) call reject_contract()
    fields = size(psurf%psd_vd, 2)
    if (fields < 1_int32 .or. fields > 4096_int32) call reject_contract()
    if (.not. span_r2(paux%prs1, columns, levels + 1_int32, arrays(1), .true.)) call reject_contract()
    if (.not. span_r2(paux%prsf1, columns, levels, arrays(2))) call reject_contract()
    if (.not. span_r2(state%a, columns, levels, arrays(3))) call reject_contract()
    if (.not. span_r3(state%cld, columns, levels, planes, arrays(4))) call reject_contract()
    if (.not. span_r2(state%t, columns, levels, arrays(5))) call reject_contract()
    if (.not. span_r1(paux%pgelat, columns, arrays(6))) call reject_contract()
    if (.not. span_r1(paux%pgelam, columns, arrays(7))) call reject_contract()
    if (.not. span_r2(psurf%psd_vd, columns, fields, arrays(8))) call reject_contract()
    if (.not. span_r2(prad%pneb, columns, levels, arrays(9))) call reject_contract()
    if (.not. span_r2(prad%pqice, columns, levels, arrays(10))) call reject_contract()
    if (.not. span_r2(prad%pqli, columns, levels, arrays(11))) call reject_contract()

    if (.not. associated(ydsurf%ysd_vd%yccc)) call reject_contract()
    if (.not. associated(ydsurf%ysd_vd%yhcc)) call reject_contract()
    if (.not. associated(ydsurf%ysd_vd%ylcc)) call reject_contract()
    if (.not. associated(ydsurf%ysd_vd%ymcc)) call reject_contract()
    if (.not. associated(ydsurf%ysd_vd%ytcc)) call reject_contract()
    metadata = [ydsurf%ysd_vd%yccc%mp, ydsurf%ysd_vd%yhcc%mp, ydsurf%ysd_vd%ylcc%mp, &
                ydsurf%ysd_vd%ymcc%mp, ydsurf%ysd_vd%ytcc%mp]
    if (any(metadata < 1_int32) .or. any(metadata > fields)) call reject_contract()
    do index = 1, 5
      do other = 1, index - 1
        if (metadata(index) == metadata(other)) call reject_contract()
      end do
    end do
    if (.not. owner_span(c_loc(ydsurf), storage_size(ydsurf, kind=int64)/8_int64, owners(1))) call reject_contract()
    if (.not. owner_span(c_loc(ydmodel), storage_size(ydmodel, kind=int64)/8_int64, owners(2))) call reject_contract()
    if (.not. owner_span(c_loc(kdim), storage_size(kdim, kind=int64)/8_int64, owners(3))) call reject_contract()
    if (.not. owner_span(c_loc(paux), storage_size(paux, kind=int64)/8_int64, owners(4))) call reject_contract()
    if (.not. owner_span(c_loc(state), storage_size(state, kind=int64)/8_int64, owners(5))) call reject_contract()
    if (.not. owner_span(c_loc(psurf), storage_size(psurf, kind=int64)/8_int64, owners(6))) call reject_contract()
    if (.not. owner_span(c_loc(prad), storage_size(prad, kind=int64)/8_int64, owners(7))) call reject_contract()
    if (.not. owner_span(c_loc(ydsurf%ysd_vd%yccc%mp), 4_int64, owners(8))) call reject_contract()
    if (.not. owner_span(c_loc(ydsurf%ysd_vd%yhcc%mp), 4_int64, owners(9))) call reject_contract()
    if (.not. owner_span(c_loc(ydsurf%ysd_vd%ylcc%mp), 4_int64, owners(10))) call reject_contract()
    if (.not. owner_span(c_loc(ydsurf%ysd_vd%ymcc%mp), 4_int64, owners(11))) call reject_contract()
    if (.not. owner_span(c_loc(ydsurf%ysd_vd%ytcc%mp), 4_int64, owners(12))) call reject_contract()
    do index = 8, 11
      do other = 1, 11
        if (other == index) cycle
        if (intersects(arrays(index), arrays(other))) call reject_contract()
      end do
      do other = 1, 12
        if (intersects(arrays(index), owners(other))) call reject_contract()
      end do
    end do

    if (lhook) call dr_hook('CLDPRG_LAYER', 0, hook_handle)
    diagnostics = .true.
    call cldpp(ydmodel%yrml_phy_rad%yradiation, ydmodel%yrml_phy_rad%yrerad, &
               ydmodel%yrml_phy_rad%yrerdi, ydmodel%yrml_phy_ec%yrecld, ydmodel%yrml_gconf%yrrip, &
               kdim%kidia, kdim%kfdia, columns, levels, paux%prs1, paux%prsf1, state%a, &
               state%cld(:, :, ncldql), state%cld(:, :, ncldqi), state%t, paux%pgelat, paux%pgelam, diagnostics, &
               psurf%psd_vd(:, metadata(1)), psurf%psd_vd(:, metadata(2)), psurf%psd_vd(:, metadata(3)), &
               psurf%psd_vd(:, metadata(4)), psurf%psd_vd(:, metadata(5)), prad%pneb, prad%pqice, prad%pqli)
    if (lhook) call dr_hook('CLDPRG_LAYER', 1, hook_handle)
  end subroutine cldprg_layer

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
end module cloud_radiation_layer_mod
