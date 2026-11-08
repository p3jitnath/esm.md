!> Borrow source-defined diagnostic controls from their actual native owners.
!! The record owns no values or numerical arrays and supplies no model stage.
!! Integer switches retain the canonical integer32 zero/one representation.
!! Field lists contain source GRIB parameter numbers; counts select prefixes.
!! RDTDZ1 is kelvin per metre. RMDI is the source missing-value marker.
module forecast_native_post_physics_control_targets
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: native_post_physics_control_targets, post_control_targets_ready
  type :: native_post_physics_control_targets
    real(real64), pointer :: rdtdz1 => null(), rmdi => null()
    integer(int32), pointer :: nlextrap => null(), lecfpos => null(), lrsacc => null()
    integer(int32), pointer :: nfpphy => null(), no2dgg => null()
    integer(int32), pointer :: lrppuv_cstext => null(), lrppuv_callitpq => null()
    integer(int32), pointer :: mfpphy(:) => null(), m2dggp(:) => null()
  end type
contains
!> Check pointer presence and declared prefixes before numerical output writes.
  logical function post_control_targets_ready(targets) result(ready)
    type(native_post_physics_control_targets), intent(in) :: targets
    ready = .false.
    if (.not. associated(targets%rdtdz1) .or. .not. associated(targets%rmdi)) return
    if (.not. associated(targets%nlextrap) .or. .not. associated(targets%lecfpos)) return
    if (.not. associated(targets%lrsacc)) return
    if (.not. associated(targets%nfpphy) .or. .not. associated(targets%no2dgg)) return
    if (.not. associated(targets%lrppuv_cstext) .or. .not. associated(targets%lrppuv_callitpq)) return
    if (targets%lrppuv_cstext < 0 .or. targets%lrppuv_cstext > 1) return
    if (targets%lrppuv_callitpq < 0 .or. targets%lrppuv_callitpq > 1) return
    if (targets%lecfpos < 0 .or. targets%lecfpos > 1) return
    if (targets%lrsacc < 0 .or. targets%lrsacc > 1) return
    if (targets%nfpphy < 0 .or. targets%no2dgg < 0) return
    if (targets%nfpphy > 0) then
      if (.not. associated(targets%mfpphy)) return
      if (size(targets%mfpphy) < targets%nfpphy) return
    end if
    if (targets%no2dgg > 0) then
      if (.not. associated(targets%m2dggp)) return
      if (size(targets%m2dggp) < targets%no2dgg) return
    end if
    ready = .true.
  end function
end module
