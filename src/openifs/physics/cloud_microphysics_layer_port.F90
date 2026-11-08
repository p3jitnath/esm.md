!> Replace the private-record wrapper in runtime_cloud_microphysics_layer.S.
!! The called CLOUDSC body is the separately generated structured Fortran port.
module cloud_microphysics_layer_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_intptr_t, c_loc, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yoecldp, only: tecldp, ncldql, ncldqi, ncldqr, ncldqs
  use yoecumf, only: tecumf
  use yoephli, only: tephli
  use yoerad, only: terad
  use yoephy, only: tephy
  use yoevdf, only: tvdf
  use spp_mod, only: tspp_config
  use surface_fields_mix, only: tsurf
  use variable_module, only: variable_3d
  use yomphyder, only: dimension_type, state_type, aux_type, perturb_type, flux_type, &
                       aux_diag_local_type, aux_rad_type, keys_local_type, surf_and_more_type, aux_diag_type
  use yom_ygfl, only: type_gfld
  use yomphy2, only: tphy2
  use yomhook, only: lhook
  use yommp0, only: lscmec
  use cloud_microphysics_mod, only: cloudsc
  implicit none
  private
  public :: cloud_layer
  type :: storage_span
    integer(c_intptr_t) :: first = 0_c_intptr_t
    integer(c_intptr_t) :: last = 0_c_intptr_t
  end type storage_span
  interface
    function error_location() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function error_location
  end interface
contains
  !> Check the supported cloud route, allocate its workspace and call CLOUDSC once.
  !! The 26 native arguments retain the original CLOUD_LAYER order and ownership.
  !! KDIM gives 1 <= KLON <= 4096, 2 <= KLEV <= 256, KIDIA=1 and 0 <= KFDIA <= KLON.
  !! KFLDX=0 selects no extra diagnostic fields. Every attached array starts at index one.
  !! STATE stores temperature in K, water in kg/kg and dimensionless cloud fraction.
  !! Tendencies store their corresponding quantity per s; pressure is in Pa and TSPHY in s.
  !! PRAD contains heating rates, PSURF contains surface data and FLUX contains precipitation fluxes.
  !! Read-only owners and inactive output cells retain their incoming bytes.
  !! The caller owns aligned native records; all consumed array spans are checked before writing.
  !! Return 0 for a completed call, -1 for unsupported metadata, -2 for allocation failure or -3 for release failure.
  integer(int32) function cloud_layer(ydsurf, ydecldp, ydecumf, ydephli, ydphy2, yderad, ydephy, ydvdf, &
                                      ydspp_config, ygfl, kdim, ldslphy, paux, ppert, state, tendency_cml, tendency_dyn, &
                                      tendency_vdf, &
                                      prad, psurf, llkeys, auxl, flux, pdiag, fsd, tendency_loc) result(status)
    type(tsurf), target, intent(inout) :: ydsurf
    type(tecldp), target, intent(inout) :: ydecldp
    type(tecumf), target, intent(inout) :: ydecumf
    type(tephli), target, intent(inout) :: ydephli
    type(tphy2), target, intent(inout) :: ydphy2
    type(terad), target, intent(inout) :: yderad
    type(tephy), target, intent(inout) :: ydephy
    type(tvdf), target, intent(inout) :: ydvdf
    type(tspp_config), target, intent(in) :: ydspp_config
    type(type_gfld), target, intent(inout) :: ygfl
    type(dimension_type), target, intent(in) :: kdim
    logical, target, intent(in) :: ldslphy
    type(aux_type), target, intent(in) :: paux
    type(perturb_type), target, intent(in) :: ppert
    type(state_type), target, intent(in) :: state, tendency_cml, tendency_dyn, tendency_vdf
    type(aux_rad_type), target, intent(in) :: prad
    type(surf_and_more_type), target, intent(inout) :: psurf
    type(keys_local_type), target, intent(in) :: llkeys
    type(aux_diag_local_type), target, intent(inout) :: auxl
    type(flux_type), target, intent(inout) :: flux
    type(aux_diag_type), target, intent(inout) :: pdiag
    type(variable_3d), target, intent(inout) :: fsd
    type(state_type), target, intent(inout) :: tendency_loc
    integer(int32) :: columns, levels, land_mask_field, surface_fields, patterns_count
    integer(int32) :: index, other, allocation_status, release_status, saved_error, flag
    integer(int64) :: step_bits
    integer(c_int), pointer :: system_error
    integer(int32), parameter :: written(21) = [9, 10, 11, 12, 31, 36, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56]
    type(storage_span) :: arrays(56), owners(27)
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: environment
    real(real64), volatile :: gradual_operand, gradual_scale
    real(real64) :: gradual_probe
    real(real64), allocatable :: heterogeneity(:, :), patterns(:, :)
    real(real64) :: empty_extra(1, 1, 0)

    status = -1_int32
    call ieee_get_status(environment)
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    gradual_operand = tiny(1.0_real64)
    gradual_scale = 0.5_real64
    gradual_probe = gradual_operand*gradual_scale
    if (gradual_probe == 0.0_real64) then
      call ieee_set_status(environment)
      return
    end if
    columns = kdim%klon
    levels = kdim%klev
    if (columns < 1_int32 .or. columns > 4096_int32) return
    if (levels < 2_int32 .or. levels > 256_int32) return
    if (kdim%kidia /= 1_int32 .or. kdim%kfdia < 0_int32 .or. kdim%kfdia > columns) return
    if (kdim%kfldx /= 0_int32 .or. lhook .or. lscmec) return
    if (ydspp_config%lspp .or. ydspp_config%sm%nrftotal /= 0_int32) return
    if (ydephy%lrad_cloud_inhomog .or. ydephy%lbud23) return
    if (ydecldp%ncldtop < 2_int32 .or. ydecldp%ncldtop > levels .or. ydecldp%nssopt /= 1_int32) return
    if (ydecldp%laericeauto .or. ydecldp%laericesed .or. ydecldp%laerliqautolsp) return
    if (ydecldp%laerliqcoll .or. ydecldp%lcloud_inhomog) return
    if (ydecldp%lcldbudget .or. ydecldp%lcldbudc .or. ydecldp%lcldbudl) return
    if (ydecldp%lcldbudi .or. ydecldp%lcldbudt .or. ydecldp%lcldbud_vertint) return
    step_bits = transfer(ydphy2%tsphy, step_bits)
    if (step_bits <= 0_int64 .or. shiftr(step_bits, 52) == 2047_int64) return
    flag = transfer(ldslphy, flag)
    if (flag < 0_int32 .or. flag > 1_int32) return
    if (.not. associated(ydsurf%ysd_vf%ylsm)) return
    land_mask_field = ydsurf%ysd_vf%ylsm%mp
    if (land_mask_field < 1_int32) return
    if (.not. associated(psurf%psd_vf)) return
    surface_fields = size(psurf%psd_vf, 2)
    if (surface_fields < land_mask_field .or. surface_fields > 1024_int32) return
    patterns_count = ydspp_config%sm%nrftotal
    if (patterns_count /= 0_int32) return

    if (.not. span_r2(state%t, columns, levels, arrays(1))) return
    if (.not. span_r2(state%q, columns, levels, arrays(2))) return
    if (.not. span_r2(state%a, columns, levels, arrays(3))) return
    if (.not. span_r3(state%cld, columns, levels, 5_int32, arrays(4))) return
    if (.not. span_r2(tendency_cml%t, columns, levels, arrays(5))) return
    if (.not. span_r2(tendency_cml%q, columns, levels, arrays(6))) return
    if (.not. span_r2(tendency_cml%a, columns, levels, arrays(7))) return
    if (.not. span_r3(tendency_cml%cld, columns, levels, 5_int32, arrays(8))) return
    if (.not. span_r2(tendency_loc%t, columns, levels, arrays(9))) return
    if (.not. span_r2(tendency_loc%q, columns, levels, arrays(10))) return
    if (.not. span_r2(tendency_loc%a, columns, levels, arrays(11))) return
    if (.not. span_r3(tendency_loc%cld, columns, levels, 5_int32, arrays(12))) return
    if (.not. span_r2(tendency_dyn%a, columns, levels, arrays(13))) return
    if (.not. span_r3(tendency_dyn%cld, columns, levels, 5_int32, arrays(14))) return
    if (.not. span_r2(tendency_vdf%a, columns, levels, arrays(15))) return
    if (.not. span_r3(tendency_vdf%cld, columns, levels, 5_int32, arrays(16))) return
    if (.not. span_r2(prad%phrsw, columns, levels, arrays(17))) return
    if (.not. span_r2(prad%phrlw, columns, levels, arrays(18))) return
    if (.not. span_r2(paux%pvervel, columns, levels, arrays(19))) return
    if (.not. span_r2(paux%prsf1, columns, levels, arrays(20))) return
    if (.not. span_r2(paux%prs1, columns, levels + 1_int32, arrays(21))) return
    if (.not. span_r1(paux%pgaw, columns, arrays(22))) return
    if (.not. span_r2(psurf%psd_vf, columns, surface_fields, arrays(23))) return
    if (.not. span_r3(psurf%psd_xa, columns, levels, 0_int32, arrays(24))) return
    if (.not. span_l1(llkeys%llcum, columns, arrays(25))) return
    if (.not. span_i1(pdiag%ictop, columns, arrays(26))) return
    if (.not. span_i1(pdiag%itype, columns, arrays(27))) return
    if (.not. span_i1(pdiag%ipbltype, columns, arrays(28))) return
    if (.not. span_r1(pdiag%zeis, columns, arrays(29))) return
    if (.not. span_r2(pdiag%zlu, columns, levels, arrays(30))) return
    if (.not. span_r2(pdiag%zlude, columns, levels, arrays(31))) return
    if (.not. span_r3(pdiag%zludeli, columns, levels, 4_int32, arrays(32))) return
    if (.not. span_r3(pdiag%zsnde, columns, levels, 2_int32, arrays(33))) return
    if (.not. span_r2(pdiag%pmfu, columns, levels, arrays(34))) return
    if (.not. span_r2(pdiag%pmfd, columns, levels, arrays(35))) return
    if (.not. span_r2(pdiag%pcovptot, columns, levels, arrays(36))) return
    if (.not. span_r2(auxl%zlcrit_aer, columns, levels, arrays(37))) return
    if (.not. span_r2(auxl%zicrit_aer, columns, levels, arrays(38))) return
    if (.not. span_r2(auxl%zre_ice, columns, levels, arrays(39))) return
    if (.not. span_r2(auxl%zccn, columns, levels, arrays(40))) return
    if (.not. span_r2(auxl%znice, columns, levels, arrays(41))) return
    if (.not. span_r1(auxl%zrainfrac_toprfz, columns, arrays(42))) return
    if (.not. span_r2(flux%pfcsql, columns, levels + 1_int32, arrays(43))) return
    if (.not. span_r2(flux%pfcsqn, columns, levels + 1_int32, arrays(44))) return
    if (.not. span_r2(flux%pfcqnng, columns, levels + 1_int32, arrays(45))) return
    if (.not. span_r2(flux%pfcqlng, columns, levels + 1_int32, arrays(46))) return
    if (.not. span_r2(flux%pfsqrf, columns, levels + 1_int32, arrays(47))) return
    if (.not. span_r2(flux%pfsqsf, columns, levels + 1_int32, arrays(48))) return
    if (.not. span_r2(flux%pfcqrng, columns, levels + 1_int32, arrays(49))) return
    if (.not. span_r2(flux%pfcqsng, columns, levels + 1_int32, arrays(50))) return
    if (.not. span_r2(flux%pfsqltur, columns, levels + 1_int32, arrays(51))) return
    if (.not. span_r2(flux%pfsqitur, columns, levels + 1_int32, arrays(52))) return
    if (.not. span_r2(flux%pfplsl, columns, levels + 1_int32, arrays(53))) return
    if (.not. span_r2(flux%pfplsn, columns, levels + 1_int32, arrays(54))) return
    if (.not. span_r2(flux%pfhpsl, columns, levels + 1_int32, arrays(55))) return
    if (.not. span_r2(flux%pfhpsn, columns, levels + 1_int32, arrays(56))) return

    if (.not. owner_span(c_loc(ydsurf), storage_size(ydsurf, kind=int64)/8_int64, owners(1))) return
    if (.not. owner_span(c_loc(ydecldp), storage_size(ydecldp, kind=int64)/8_int64, owners(2))) return
    if (.not. owner_span(c_loc(ydecumf), storage_size(ydecumf, kind=int64)/8_int64, owners(3))) return
    if (.not. owner_span(c_loc(ydephli), storage_size(ydephli, kind=int64)/8_int64, owners(4))) return
    if (.not. owner_span(c_loc(ydphy2), storage_size(ydphy2, kind=int64)/8_int64, owners(5))) return
    if (.not. owner_span(c_loc(yderad), storage_size(yderad, kind=int64)/8_int64, owners(6))) return
    if (.not. owner_span(c_loc(ydephy), storage_size(ydephy, kind=int64)/8_int64, owners(7))) return
    if (.not. owner_span(c_loc(ydvdf), storage_size(ydvdf, kind=int64)/8_int64, owners(8))) return
    if (.not. owner_span(c_loc(ydspp_config), storage_size(ydspp_config, kind=int64)/8_int64, owners(9))) return
    if (.not. owner_span(c_loc(ygfl), storage_size(ygfl, kind=int64)/8_int64, owners(10))) return
    if (.not. owner_span(c_loc(kdim), storage_size(kdim, kind=int64)/8_int64, owners(11))) return
    if (.not. owner_span(c_loc(ldslphy), storage_size(ldslphy, kind=int64)/8_int64, owners(12))) return
    if (.not. owner_span(c_loc(paux), storage_size(paux, kind=int64)/8_int64, owners(13))) return
    if (.not. owner_span(c_loc(ppert), storage_size(ppert, kind=int64)/8_int64, owners(14))) return
    if (.not. owner_span(c_loc(state), storage_size(state, kind=int64)/8_int64, owners(15))) return
    if (.not. owner_span(c_loc(tendency_cml), storage_size(tendency_cml, kind=int64)/8_int64, owners(16))) return
    if (.not. owner_span(c_loc(tendency_dyn), storage_size(tendency_dyn, kind=int64)/8_int64, owners(17))) return
    if (.not. owner_span(c_loc(tendency_vdf), storage_size(tendency_vdf, kind=int64)/8_int64, owners(18))) return
    if (.not. owner_span(c_loc(prad), storage_size(prad, kind=int64)/8_int64, owners(19))) return
    if (.not. owner_span(c_loc(psurf), storage_size(psurf, kind=int64)/8_int64, owners(20))) return
    if (.not. owner_span(c_loc(llkeys), storage_size(llkeys, kind=int64)/8_int64, owners(21))) return
    if (.not. owner_span(c_loc(auxl), storage_size(auxl, kind=int64)/8_int64, owners(22))) return
    if (.not. owner_span(c_loc(flux), storage_size(flux, kind=int64)/8_int64, owners(23))) return
    if (.not. owner_span(c_loc(pdiag), storage_size(pdiag, kind=int64)/8_int64, owners(24))) return
    if (.not. owner_span(c_loc(fsd), storage_size(fsd, kind=int64)/8_int64, owners(25))) return
    if (.not. owner_span(c_loc(tendency_loc), storage_size(tendency_loc, kind=int64)/8_int64, owners(26))) return
    if (.not. owner_span(c_loc(ydsurf%ysd_vf%ylsm%mp), storage_size(ydsurf%ysd_vf%ylsm%mp, kind=int64)/8_int64, owners(27))) return

    do index = 1, size(written)
      do other = 1, size(arrays)
        if (other == written(index)) cycle
        if (intersects(arrays(written(index)), arrays(other))) return
      end do
      do other = 1, size(owners)
        if (intersects(arrays(written(index)), owners(other))) return
      end do
    end do

    call c_f_pointer(error_location(), system_error)
    saved_error = system_error
    call ieee_get_status(environment)
    allocate (heterogeneity(columns, levels), patterns(columns, patterns_count), stat=allocation_status)
    system_error = saved_error
    call ieee_set_status(environment)
    if (allocation_status /= 0_int32) then
      if (allocated(heterogeneity)) deallocate (heterogeneity)
      if (allocated(patterns)) deallocate (patterns)
      system_error = saved_error
      call ieee_set_status(environment)
      status = -2_int32
      return
    end if
    ! Anonymous mmap supplied positive-zero workspace in the earlier wrapper.
    heterogeneity = 0.0_real64
    ! LSPP is false, so the numerical child does not read the pattern payload.
    patterns = 0.0_real64
    call cloudsc(ydecldp, ydecumf, ydephli, yderad, ydephy, ydvdf, ydspp_config, &
                 kdim%kidia, kdim%kfdia, columns, levels, ydphy2%tsphy, state%t, state%q, &
                 tendency_cml%t, tendency_cml%q, tendency_cml%a, tendency_cml%cld, &
                 tendency_loc%t, tendency_loc%q, tendency_loc%a, tendency_loc%cld, &
                 tendency_vdf%a, tendency_vdf%cld(:, :, ncldql), tendency_vdf%cld(:, :, ncldqi), &
                 tendency_dyn%a, tendency_dyn%cld(:, :, ncldql), tendency_dyn%cld(:, :, ncldqi), &
                 tendency_dyn%cld(:, :, ncldqr), tendency_dyn%cld(:, :, ncldqs), prad%phrsw, prad%phrlw, &
                 paux%pvervel, paux%prsf1, paux%prs1, psurf%psd_vf(:, land_mask_field), paux%pgaw, &
                 llkeys%llcum, pdiag%ictop, pdiag%itype, pdiag%ipbltype, pdiag%zeis, pdiag%zlu, &
                 pdiag%zlude, pdiag%zludeli, pdiag%zsnde, pdiag%pmfu, pdiag%pmfd, patterns, ldslphy, &
                 state%a, state%cld, auxl%zlcrit_aer, auxl%zicrit_aer, auxl%zre_ice, auxl%zccn, &
                 auxl%znice, pdiag%pcovptot, heterogeneity, auxl%zrainfrac_toprfz, &
                 flux%pfcsql, flux%pfcsqn, flux%pfcqnng, flux%pfcqlng, flux%pfsqrf, flux%pfsqsf, &
                 flux%pfcqrng, flux%pfcqsng, flux%pfsqltur, flux%pfsqitur, flux%pfplsl, flux%pfplsn, &
                 flux%pfhpsl, flux%pfhpsn, empty_extra, kdim%kfldx)

    saved_error = system_error
    call ieee_get_status(environment)
    deallocate (heterogeneity, patterns, stat=release_status)
    system_error = saved_error
    call ieee_set_status(environment)
    status = 0_int32
    if (release_status /= 0_int32) status = -3_int32
  end function cloud_layer

  !> Make the half-open address span of one native owner without private offsets.
  logical function owner_span(address, bytes, span) result(valid)
    type(c_ptr), intent(in) :: address
    integer(int64), intent(in) :: bytes
    type(storage_span), intent(out) :: span
    integer(c_intptr_t) :: first
    valid = .false.
    span = storage_span()
    if (bytes == 0_int64) then
      valid = .true.
      return
    end if
    first = transfer(address, first)
    if (first <= 0_c_intptr_t .or. bytes < 0_int64) return
    if (first > huge(first) - bytes) return
    span%first = first
    span%last = first + bytes
    valid = .true.
  end function owner_span

  !> Test whether two nonempty owned spans share a byte.
  logical function intersects(first, second) result(overlap)
    type(storage_span), intent(in) :: first, second
    overlap = .false.
    if (first%first == first%last .or. second%first == second%last) return
    overlap = first%first < second%last .and. second%first < first%last
  end function intersects

  !> Check a native real(real64) array and retain its complete contiguous byte span.
  logical function span_r1(array, n1, span) result(valid)
    real(real64), pointer, intent(in) :: array(:)
    integer(int32), intent(in) :: n1
    type(storage_span), intent(out) :: span
    integer(int64) :: elements
    valid = .false.
    span = storage_span()
    elements = int(n1, int64)
    if (.not. associated(array)) then
      valid = elements == 0_int64
      return
    end if
    if (any(lbound(array) /= 1_int32)) return
    if (any(shape(array) /= [n1])) return
    if (.not. is_contiguous(array)) return
    if (elements == 0_int64) then
      valid = .true.
      return
    end if
    valid = owner_span(c_loc(array(1)), elements*8_int64, span)
  end function span_r1

  !> Check a native real(real64) array and retain its complete contiguous byte span.
  logical function span_r2(array, n1, n2, span) result(valid)
    real(real64), pointer, intent(in) :: array(:, :)
    integer(int32), intent(in) :: n1, n2
    type(storage_span), intent(out) :: span
    integer(int64) :: elements
    valid = .false.
    span = storage_span()
    elements = int(n1, int64)*int(n2, int64)
    if (.not. associated(array)) then
      valid = elements == 0_int64
      return
    end if
    if (any(lbound(array) /= 1_int32)) return
    if (any(shape(array) /= [n1, n2])) return
    if (.not. is_contiguous(array)) return
    if (elements == 0_int64) then
      valid = .true.
      return
    end if
    valid = owner_span(c_loc(array(1, 1)), elements*8_int64, span)
  end function span_r2

  !> Check a native real(real64) array and retain its complete contiguous byte span.
  logical function span_r3(array, n1, n2, n3, span) result(valid)
    real(real64), pointer, intent(in) :: array(:, :, :)
    integer(int32), intent(in) :: n1, n2, n3
    type(storage_span), intent(out) :: span
    integer(int64) :: elements
    valid = .false.
    span = storage_span()
    elements = int(n1, int64)*int(n2, int64)*int(n3, int64)
    if (.not. associated(array)) then
      valid = elements == 0_int64
      return
    end if
    if (any(lbound(array) /= 1_int32)) return
    if (any(shape(array) /= [n1, n2, n3])) return
    if (.not. is_contiguous(array)) return
    if (elements == 0_int64) then
      valid = .true.
      return
    end if
    valid = owner_span(c_loc(array(1, 1, 1)), elements*8_int64, span)
  end function span_r3

  !> Check a native integer(int32) array and retain its complete contiguous byte span.
  logical function span_i1(array, n1, span) result(valid)
    integer(int32), pointer, intent(in) :: array(:)
    integer(int32), intent(in) :: n1
    type(storage_span), intent(out) :: span
    integer(int64) :: elements
    valid = .false.
    span = storage_span()
    elements = int(n1, int64)
    if (.not. associated(array)) then
      valid = elements == 0_int64
      return
    end if
    if (any(lbound(array) /= 1_int32)) return
    if (any(shape(array) /= [n1])) return
    if (.not. is_contiguous(array)) return
    if (elements == 0_int64) then
      valid = .true.
      return
    end if
    valid = owner_span(c_loc(array(1)), elements*4_int64, span)
  end function span_i1

  !> Check a native logical array and retain its complete contiguous byte span.
  logical function span_l1(array, n1, span) result(valid)
    logical, pointer, intent(in) :: array(:)
    integer(int32), intent(in) :: n1
    type(storage_span), intent(out) :: span
    integer(int64) :: elements
    valid = .false.
    span = storage_span()
    elements = int(n1, int64)
    if (.not. associated(array)) then
      valid = elements == 0_int64
      return
    end if
    if (any(lbound(array) /= 1_int32)) return
    if (any(shape(array) /= [n1])) return
    if (.not. is_contiguous(array)) return
    if (elements == 0_int64) then
      valid = .true.
      return
    end if
    valid = owner_span(c_loc(array(1)), elements*4_int64, span)
  end function span_l1

end module cloud_microphysics_layer_mod
