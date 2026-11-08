! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Borrow stochastic and cellular fields for one physics block.
!! These procedures change pointer associations only. The caller establishes
!! the floating-point mode and keeps every borrowed source target alive.
module forecast_physics_perturbation_views
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use stoph_mix, only: tstoph
  use forecast_physics_work_types, only: perturb_type
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  implicit none
  private
  public :: native_cellular_perturbation_views, update_perturbation_views, finalize_perturbation_views
  public :: perturb_type_update_view, perturb_type_final, perturbation_view_call_count_get
  !> Borrow cellular owners. ACTIVE is the source LCUCONV_CA switch.
  !! An absent inactive pair has no numerical target and stays null.
  type :: native_cellular_perturbation_views
    real(real64), pointer, contiguous :: convective(:) => null(), nonlinear(:) => null(), cape(:) => null()
    logical :: active = .false.
  end type
  integer(int64), save :: calls(0:1) = 0_int64
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine fatal_view_failure() bind(c, name="abort")
    end subroutine
  end interface
contains
  !> Associate source views in their original order, then acquire PTEMP if needed.
  !! BLOCK, FIRST and ACTIVE_ROWS are positive; ACTIVE_ROWS<=COLUMNS.
  !! LEVELS is nonnegative. FORCING owns rank4(cell,level,block,time) arrays
  !! whose time index0 is selected only when STOPH%LFORCENL is true.
  !! Status0 succeeds,1 reports the final dummy allocation failure, and2
  !! refuses unsupported metadata before mutation. LSPSDT/LSPP must be false.
  !! The one-by-one PTEMP dummy has undefined numerical values and is finalized
  !! before this record is updated again. No borrowed owner is deallocated.
  integer(int32) function update_perturbation_views(output, stoph, lspsdt, lspp, cellular, &
                                                    block, first, active_rows, columns, levels, forcing) result(status)
    type(perturb_type), intent(inout) :: output
    type(tstoph), target, intent(inout) :: stoph
    logical, intent(in) :: lspsdt, lspp
    type(native_cellular_perturbation_views), intent(in) :: cellular
    integer(int32), intent(in) :: block, first, active_rows, columns, levels
    type(native_physics_runtime_data), target, intent(inout) :: forcing
    integer(int64) :: last
    integer :: allocation_status
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    status = 2
    if (lspsdt .or. lspp) return
    if (block < 1 .or. first < 1 .or. active_rows < 1 .or. columns < 1 .or. levels < 0) return
    if (active_rows > columns) return
    last = int(first, int64) + int(active_rows, int64) - 1_int64
    if (last > huge(first)) return
    if (allocated(stoph%rstophca)) then
      if (first < lbound(stoph%rstophca, 1) .or. last > ubound(stoph%rstophca, 1)) return
    end if
    if (allocated(stoph%gptotdiss)) then
      if (.not. allocated(stoph%gptotdiss_smooth)) return
      if (.not. valid_stoph_field(stoph%gptotdiss, block)) return
      if (.not. valid_stoph_field(stoph%gptotdiss_smooth, block)) return
    end if
    if (allocated(stoph%gpvortgrad)) then
      if (.not. valid_stoph_field(stoph%gpvortgrad, block)) return
      if (lbound(stoph%gpvortgrad, 2) > 1) return
      if (3_int64*int(levels, int64) > ubound(stoph%gpvortgrad, 2, kind=int64)) return
    end if
    if (stoph%lforcenl) then
      if (.not. allocated(forcing%gpforceu) .or. .not. allocated(forcing%gpforcev)) return
      if (.not. allocated(forcing%gpforcet) .or. .not. allocated(forcing%gpforceq)) return
      if (.not. valid_forcing_field(forcing%gpforceu, block)) return
      if (.not. valid_forcing_field(forcing%gpforcev, block)) return
      if (.not. valid_forcing_field(forcing%gpforcet, block)) return
      if (.not. valid_forcing_field(forcing%gpforceq, block)) return
    end if
    if (associated(cellular%convective) .neqv. associated(cellular%nonlinear)) return
    if (associated(cellular%convective)) then
      if (first < lbound(cellular%convective, 1) .or. last > ubound(cellular%convective, 1)) return
      if (first < lbound(cellular%nonlinear, 1) .or. last > ubound(cellular%nonlinear, 1)) return
    else
      if (cellular%active) return
    end if
    if (cellular%active) then
      if (.not. associated(cellular%cape)) return
      if (first < lbound(cellular%cape, 1) .or. last > ubound(cellular%cape, 1)) return
    end if
    if (allocated(stoph%gpstream)) then
      if (.not. valid_stoph_field(stoph%gpstream, block)) return
    end if
    if (stoph%lstoph_spbs_t) then
      if (.not. allocated(stoph%gptemp)) return
      if (.not. valid_stoph_field(stoph%gptemp, block)) return
    else
      if (associated(output%ptemp)) return
    end if
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    if (allocated(stoph%rstophca)) output%pstophca => stoph%rstophca(first:last)
    nullify (output%pgp2dsdt, output%pgp2dspp)
    if (allocated(stoph%gptotdiss)) output%ptotdiss_smooth => stoph%gptotdiss_smooth(:, :, block)
    if (allocated(stoph%gpvortgrad)) output%pvort => stoph%gpvortgrad(:, 1:levels, block)
    if (allocated(stoph%gpvortgrad)) output%pvortgradx => stoph%gpvortgrad(:, levels + 1:2*levels, block)
    if (allocated(stoph%gpvortgrad)) output%pvortgrady => stoph%gpvortgrad(:, 2*levels + 1:3*levels, block)
    if (stoph%lforcenl) then
      output%pforceu => forcing%gpforceu(:, :, block, 0)
      output%pforcev => forcing%gpforcev(:, :, block, 0)
      output%pforcet => forcing%gpforcet(:, :, block, 0)
      output%pforceq => forcing%gpforceq(:, :, block, 0)
    end if
    if (associated(cellular%convective)) then
      output%pcuconvca => cellular%convective(first:last)
      output%pnlconvca => cellular%nonlinear(first:last)
    else
      ! Native inactive absence has no addressable numerical target.
      nullify (output%pcuconvca, output%pnlconvca)
    end if
    if (cellular%active) output%pcapeconvca => cellular%cape(first:last)
    if (allocated(stoph%gpstream)) output%pstream => stoph%gpstream(:, :, block)
    if (stoph%lstoph_spbs_t) then
      output%ptemp => stoph%gptemp(:, :, block)
    else
      allocate (output%ptemp(1, 1), stat=allocation_status)
      if (allocation_status /= 0) then
        call ieee_set_status(incoming_status); errno_word = incoming_errno
        status = 1; return
      end if
    end if
    if (allocated(stoph%gptotdiss)) output%ptotdiss => stoph%gptotdiss(:, :, block)
    call ieee_set_status(incoming_status); errno_word = incoming_errno
    status = 0
  end function update_perturbation_views

  !> Release only the source-created PTEMP dummy and null its pointer.
  !! Use the same STOPH flag as update. Other borrowed associations stay.
  integer(int32) function finalize_perturbation_views(output, stoph, lspsdt, lspp) result(status)
    type(perturb_type), intent(inout) :: output
    type(tstoph), intent(in) :: stoph
    logical, intent(in) :: lspsdt, lspp
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    status = 2
    if (lspsdt .or. lspp) return
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    if (.not. stoph%lstoph_spbs_t) then
      if (associated(output%ptemp)) deallocate (output%ptemp)
      nullify (output%ptemp)
    end if
    call ieee_set_status(incoming_status); errno_word = incoming_errno
    status = 0
  end function finalize_perturbation_views

  logical function valid_stoph_field(field, block) result(valid)
    real(real64), allocatable, intent(in) :: field(:, :, :)
    integer(int32), intent(in) :: block
    valid = block >= lbound(field, 3) .and. block <= ubound(field, 3)
  end function
  logical function valid_forcing_field(field, block) result(valid)
    real(real64), allocatable, intent(in) :: field(:, :, :, :)
    integer(int32), intent(in) :: block
    valid = block >= lbound(field, 3) .and. block <= ubound(field, 3)
    valid = valid .and. lbound(field, 4) <= 0 .and. ubound(field, 4) >= 0
  end function
  !> Native method adapter; constructor failure retains the public abort boundary.
  subroutine perturb_type_update_view(output, stoph, lspsdt, lspp, cellular, block, first, active_rows, columns, levels, forcing)
    type(perturb_type), intent(inout) :: output
    type(tstoph), target, intent(inout) :: stoph
    logical, intent(in) :: lspsdt, lspp
    type(native_cellular_perturbation_views), intent(in) :: cellular
    integer(int32), intent(in) :: block, first, active_rows, columns, levels
    type(native_physics_runtime_data), target, intent(inout) :: forcing
    integer(int32) :: status
    call increment_count(0)
    status = update_perturbation_views(output, stoph, lspsdt, lspp, cellular, block, first, active_rows, columns, levels, forcing)
    if (status /= 0) call fatal_view_failure()
  end subroutine
  subroutine perturb_type_final(output, stoph, lspsdt, lspp)
    type(perturb_type), intent(inout) :: output
    type(tstoph), intent(in) :: stoph
    logical, intent(in) :: lspsdt, lspp
    integer(int32) :: status
    call increment_count(1)
    status = finalize_perturbation_views(output, stoph, lspsdt, lspp)
    if (status /= 0) call fatal_view_failure()
  end subroutine
  subroutine increment_count(index)
    integer, intent(in) :: index
    if (calls(index) == huge(calls(index))) then
      calls(index) = -huge(calls(index)) - 1_int64
    else
      calls(index) = calls(index) + 1_int64
    end if
  end subroutine
  integer(int64) function perturbation_view_call_count_get(index) result(count)
    integer(int32), intent(in) :: index
    count = 0_int64
    if (index >= 0 .and. index < 2) count = calls(index)
  end function
end module forecast_physics_perturbation_views
