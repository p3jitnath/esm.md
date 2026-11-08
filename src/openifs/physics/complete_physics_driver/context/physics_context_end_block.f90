! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Release block-local physics views while retaining borrowed weather owners.
module forecast_physics_context_end_block
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use stoph_mix, only: tstoph
  use forecast_complete_physics_context_types, only: native_complete_physics_context
  use forecast_physics_perturbation_views, only: finalize_perturbation_views
  use forecast_field_variable_arrays, only: reset_field_variable_arrays
  use physics_context_helper_counters_mod, only: increment_context_helper_count
  implicit none
  private
  public :: physics_storage_end_block, end_physics_context_block
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine abort_context_failure() bind(c, name="abort")
    end subroutine
  end interface
contains
  !> Finalize perturbations, release seventeen source fallback owners, then reset.
  !! CONTEXT was initialized by its constructor. Its selected surface record
  !! and all borrowed metadata remain live. FALLBACK_OWNED records only owners
  !! created by the matching child-table entry; their values stay unread.
  !! Status2 refuses invalid native metadata. Source-order partial changes stay
  !! if a later provider refuses. Success returns0 and preserves IEEE/errno.
  integer(int32) function physics_storage_end_block(context, stoph, lspsdt, lspp) result(status)
    type(native_complete_physics_context), target, intent(inout) :: context
    type(tstoph), intent(in) :: stoph
    logical, intent(in) :: lspsdt, lspp
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    status = 2
    if (.not. associated(context%records%surface)) return
    if (.not. associated(context%records%perturbation)) return
    call increment_context_helper_count(3, 3)
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    status = finalize_perturbation_views(context%records%perturbation, stoph, lspsdt, lspp)
    if (status /= 0) then
      call ieee_set_status(incoming_status); errno_word = incoming_errno
      return
    end if
    if (context%fallback_owned(1)) then
      if (associated(context%records%surface%psp_sb)) deallocate (context%records%surface%psp_sb)
      nullify (context%records%surface%psp_sb)
      context%fallback_owned(1) = .false.
    end if
    if (context%fallback_owned(2)) then
      if (associated(context%records%surface%psp_sg)) deallocate (context%records%surface%psp_sg)
      nullify (context%records%surface%psp_sg)
      context%fallback_owned(2) = .false.
    end if
    if (context%fallback_owned(3)) then
      if (associated(context%records%surface%psp_sl)) deallocate (context%records%surface%psp_sl)
      nullify (context%records%surface%psp_sl)
      context%fallback_owned(3) = .false.
    end if
    if (context%fallback_owned(4)) then
      if (associated(context%records%surface%psp_rr)) deallocate (context%records%surface%psp_rr)
      nullify (context%records%surface%psp_rr)
      context%fallback_owned(4) = .false.
    end if
    if (context%fallback_owned(5)) then
      if (associated(context%records%surface%psp_ep)) deallocate (context%records%surface%psp_ep)
      nullify (context%records%surface%psp_ep)
      context%fallback_owned(5) = .false.
    end if
    if (context%fallback_owned(6)) then
      if (associated(context%records%surface%psp_x2)) deallocate (context%records%surface%psp_x2)
      nullify (context%records%surface%psp_x2)
      context%fallback_owned(6) = .false.
    end if
    if (context%fallback_owned(7)) then
      if (associated(context%records%surface%psp_om)) deallocate (context%records%surface%psp_om)
      nullify (context%records%surface%psp_om)
      context%fallback_owned(7) = .false.
    end if
    if (context%fallback_owned(8)) then
      if (associated(context%records%surface%psd_vf)) deallocate (context%records%surface%psd_vf)
      nullify (context%records%surface%psd_vf)
      context%fallback_owned(8) = .false.
    end if
    if (context%fallback_owned(9)) then
      if (associated(context%records%surface%psd_vn)) deallocate (context%records%surface%psd_vn)
      nullify (context%records%surface%psd_vn)
      context%fallback_owned(9) = .false.
    end if
    if (context%fallback_owned(10)) then
      if (associated(context%records%surface%psd_vd)) deallocate (context%records%surface%psd_vd)
      nullify (context%records%surface%psd_vd)
      context%fallback_owned(10) = .false.
    end if
    if (context%fallback_owned(11)) then
      if (associated(context%records%surface%psd_ws)) deallocate (context%records%surface%psd_ws)
      nullify (context%records%surface%psd_ws)
      context%fallback_owned(11) = .false.
    end if
    if (context%fallback_owned(12)) then
      if (associated(context%records%surface%psd_ww)) deallocate (context%records%surface%psd_ww)
      nullify (context%records%surface%psd_ww)
      context%fallback_owned(12) = .false.
    end if
    if (context%fallback_owned(13)) then
      if (associated(context%records%surface%psd_xa)) deallocate (context%records%surface%psd_xa)
      nullify (context%records%surface%psd_xa)
      context%fallback_owned(13) = .false.
    end if
    if (context%fallback_owned(14)) then
      if (associated(context%records%surface%psd_x2)) deallocate (context%records%surface%psd_x2)
      nullify (context%records%surface%psd_x2)
      context%fallback_owned(14) = .false.
    end if
    if (context%fallback_owned(15)) then
      if (associated(context%records%surface%psd_sm)) deallocate (context%records%surface%psd_sm)
      nullify (context%records%surface%psd_sm)
      context%fallback_owned(15) = .false.
    end if
    if (context%fallback_owned(16)) then
      if (associated(context%records%surface%psd_v2)) deallocate (context%records%surface%psd_v2)
      nullify (context%records%surface%psd_v2)
      context%fallback_owned(16) = .false.
    end if
    if (context%fallback_owned(17)) then
      if (associated(context%records%surface%psd_v3)) deallocate (context%records%surface%psd_v3)
      nullify (context%records%surface%psd_v3)
      context%fallback_owned(17) = .false.
    end if
    status = reset_field_variable_arrays(context%variables)
    if (status == 0) then
      context%private_metadata_owned = .false.
      context%block_open = .false.
    end if
    call ieee_set_status(incoming_status); errno_word = incoming_errno
  end function physics_storage_end_block
  !> Retain the source's nonreturning native method failure boundary.
  subroutine end_physics_context_block(context, stoph, lspsdt, lspp)
    type(native_complete_physics_context), target, intent(inout) :: context
    type(tstoph), intent(in) :: stoph
    logical, intent(in) :: lspsdt, lspp
    integer(int32) :: status
    status = physics_storage_end_block(context, stoph, lspsdt, lspp)
    if (status /= 0) call abort_context_failure()
  end subroutine end_physics_context_block
end module forecast_physics_context_end_block
