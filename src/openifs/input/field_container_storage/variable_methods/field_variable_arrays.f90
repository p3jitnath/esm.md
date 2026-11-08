!> Private field-variable metadata, borrowed block views and call counters.
module forecast_field_variable_arrays
  use, intrinsic :: iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use, intrinsic :: iso_fortran_env, only: int64
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_registry_field_types, only: native_registry_variable_2d, native_registry_variable_3d
  use forecast_native_field_variable_types, only: native_field_variables
  use forecast_physics_field_views, only: physics_field_view_2d, physics_field_view_3d
  implicit none
  private
  public :: clone_field_variable_arrays, reset_field_variable_arrays
  public :: update_field_variable_views, update_variable_view, field_variable_call_count_get
  public :: update_variable_view_2d, update_variable_view_3d
  integer(int64), save :: calls(0:4) = 0_int64
  interface update_variable_view
    module procedure update_variable_view_2d, update_variable_view_3d
  end interface
  interface
    function errno_address() bind(c, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function errno_address
    subroutine fatal_allocation_exit(code) bind(c, name='_exit')
      import :: c_int
      integer(c_int), value :: code
    end subroutine fatal_allocation_exit
  end interface
contains
  !> All18 shared owners must be associated, contiguous and one-based,
  !> including empty owners. Each public alias initially names its shared owner.
  !> Allocate only private variable records. Their FIELD targets stay borrowed.
  !> Original allocation failure terminates through public C _exit(116).
  !> Success returns0. Partial failure has no returned status or rollback.
  integer(c_int) function clone_field_variable_arrays(state) result(status)
    type(native_field_variables), intent(inout) :: state
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    type(ieee_status_type) :: incoming_status
    integer :: allocation_status
    integer(int64) :: i, count
    call increment_count(0)
    call c_f_pointer(errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(incoming_status)

    nullify (state%ghg)
    count = size(state%ghg_g, kind=int64)
    allocate (state%ghg(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%ghg(i)%name = repeat(achar(0), 16)
      state%ghg(i)%ft0 => state%ghg_g(i)%ft0
      state%ghg(i)%ft1 => state%ghg_g(i)%ft1
      state%ghg(i)%ft9 => state%ghg_g(i)%ft9
      state%ghg(i)%fph9 => state%ghg_g(i)%fph9
      state%ghg(i)%fdl => state%ghg_g(i)%fdl
      state%ghg(i)%fdm => state%ghg_g(i)%fdm
    end do
    nullify (state%chem)
    count = size(state%chem_g, kind=int64)
    allocate (state%chem(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%chem(i)%name = repeat(achar(0), 16)
      state%chem(i)%ft0 => state%chem_g(i)%ft0
      state%chem(i)%ft1 => state%chem_g(i)%ft1
      state%chem(i)%ft9 => state%chem_g(i)%ft9
      state%chem(i)%fph9 => state%chem_g(i)%fph9
      state%chem(i)%fdl => state%chem_g(i)%fdl
      state%chem(i)%fdm => state%chem_g(i)%fdm
    end do
    nullify (state%aero)
    count = size(state%aero_g, kind=int64)
    allocate (state%aero(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%aero(i)%name = repeat(achar(0), 16)
      state%aero(i)%ft0 => state%aero_g(i)%ft0
      state%aero(i)%ft1 => state%aero_g(i)%ft1
      state%aero(i)%ft9 => state%aero_g(i)%ft9
      state%aero(i)%fph9 => state%aero_g(i)%fph9
      state%aero(i)%fdl => state%aero_g(i)%fdl
      state%aero(i)%fdm => state%aero_g(i)%fdm
    end do
    nullify (state%forc)
    count = size(state%forc_g, kind=int64)
    allocate (state%forc(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%forc(i)%name = repeat(achar(0), 16)
      state%forc(i)%ft0 => state%forc_g(i)%ft0
      state%forc(i)%ft1 => state%forc_g(i)%ft1
      state%forc(i)%ft9 => state%forc_g(i)%ft9
      state%forc(i)%fph9 => state%forc_g(i)%fph9
      state%forc(i)%fdl => state%forc_g(i)%fdl
      state%forc(i)%fdm => state%forc_g(i)%fdm
    end do
    nullify (state%ezdiag)
    count = size(state%ezdiag_g, kind=int64)
    allocate (state%ezdiag(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%ezdiag(i)%name = repeat(achar(0), 16)
      state%ezdiag(i)%ft0 => state%ezdiag_g(i)%ft0
      state%ezdiag(i)%ft1 => state%ezdiag_g(i)%ft1
      state%ezdiag(i)%ft9 => state%ezdiag_g(i)%ft9
      state%ezdiag(i)%fph9 => state%ezdiag_g(i)%fph9
      state%ezdiag(i)%fdl => state%ezdiag_g(i)%fdl
      state%ezdiag(i)%fdm => state%ezdiag_g(i)%fdm
    end do
    nullify (state%era40)
    count = size(state%era40_g, kind=int64)
    allocate (state%era40(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%era40(i)%name = repeat(achar(0), 16)
      state%era40(i)%ft0 => state%era40_g(i)%ft0
      state%era40(i)%ft1 => state%era40_g(i)%ft1
      state%era40(i)%ft9 => state%era40_g(i)%ft9
      state%era40(i)%fph9 => state%era40_g(i)%fph9
      state%era40(i)%fdl => state%era40_g(i)%fdl
      state%era40(i)%fdm => state%era40_g(i)%fdm
    end do
    nullify (state%nogw)
    count = size(state%nogw_g, kind=int64)
    allocate (state%nogw(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%nogw(i)%name = repeat(achar(0), 16)
      state%nogw(i)%ft0 => state%nogw_g(i)%ft0
      state%nogw(i)%ft1 => state%nogw_g(i)%ft1
      state%nogw(i)%ft9 => state%nogw_g(i)%ft9
      state%nogw(i)%fph9 => state%nogw_g(i)%fph9
      state%nogw(i)%fdl => state%nogw_g(i)%fdl
      state%nogw(i)%fdm => state%nogw_g(i)%fdm
    end do
    nullify (state%emis3d)
    count = size(state%emis3d_g, kind=int64)
    allocate (state%emis3d(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%emis3d(i)%name = repeat(achar(0), 16)
      state%emis3d(i)%ft0 => state%emis3d_g(i)%ft0
      state%emis3d(i)%ft1 => state%emis3d_g(i)%ft1
      state%emis3d(i)%ft9 => state%emis3d_g(i)%ft9
      state%emis3d(i)%fph9 => state%emis3d_g(i)%fph9
      state%emis3d(i)%fdl => state%emis3d_g(i)%fdl
      state%emis3d(i)%fdm => state%emis3d_g(i)%fdm
    end do
    nullify (state%edrp)
    count = size(state%edrp_g, kind=int64)
    allocate (state%edrp(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%edrp(i)%name = repeat(achar(0), 16)
      state%edrp(i)%ft0 => state%edrp_g(i)%ft0
      state%edrp(i)%ft1 => state%edrp_g(i)%ft1
      state%edrp(i)%ft9 => state%edrp_g(i)%ft9
      state%edrp(i)%fph9 => state%edrp_g(i)%fph9
      state%edrp(i)%fdl => state%edrp_g(i)%fdl
      state%edrp(i)%fdm => state%edrp_g(i)%fdm
    end do
    nullify (state%sldia)
    count = size(state%sldia_g, kind=int64)
    allocate (state%sldia(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%sldia(i)%name = repeat(achar(0), 16)
      state%sldia(i)%ft0 => state%sldia_g(i)%ft0
      state%sldia(i)%ft1 => state%sldia_g(i)%ft1
      state%sldia(i)%ft9 => state%sldia_g(i)%ft9
      state%sldia(i)%fph9 => state%sldia_g(i)%fph9
      state%sldia(i)%fdl => state%sldia_g(i)%fdl
      state%sldia(i)%fdm => state%sldia_g(i)%fdm
    end do
    nullify (state%aeraot)
    count = size(state%aeraot_g, kind=int64)
    allocate (state%aeraot(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%aeraot(i)%name = repeat(achar(0), 16)
      state%aeraot(i)%ft0 => state%aeraot_g(i)%ft0
      state%aeraot(i)%ft1 => state%aeraot_g(i)%ft1
      state%aeraot(i)%ft9 => state%aeraot_g(i)%ft9
      state%aeraot(i)%fph9 => state%aeraot_g(i)%fph9
      state%aeraot(i)%fdl => state%aeraot_g(i)%fdl
      state%aeraot(i)%fdm => state%aeraot_g(i)%fdm
    end do
    nullify (state%aerlisi)
    count = size(state%aerlisi_g, kind=int64)
    allocate (state%aerlisi(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%aerlisi(i)%name = repeat(achar(0), 16)
      state%aerlisi(i)%ft0 => state%aerlisi_g(i)%ft0
      state%aerlisi(i)%ft1 => state%aerlisi_g(i)%ft1
      state%aerlisi(i)%ft9 => state%aerlisi_g(i)%ft9
      state%aerlisi(i)%fph9 => state%aerlisi_g(i)%fph9
      state%aerlisi(i)%fdl => state%aerlisi_g(i)%fdl
      state%aerlisi(i)%fdm => state%aerlisi_g(i)%fdm
    end do
    nullify (state%aerout)
    count = size(state%aerout_g, kind=int64)
    allocate (state%aerout(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%aerout(i)%name = repeat(achar(0), 16)
      state%aerout(i)%ft0 => state%aerout_g(i)%ft0
      state%aerout(i)%ft1 => state%aerout_g(i)%ft1
      state%aerout(i)%ft9 => state%aerout_g(i)%ft9
      state%aerout(i)%fph9 => state%aerout_g(i)%fph9
      state%aerout(i)%fdl => state%aerout_g(i)%fdl
      state%aerout(i)%fdm => state%aerout_g(i)%fdm
    end do
    nullify (state%aeroclim)
    count = size(state%aeroclim_g, kind=int64)
    allocate (state%aeroclim(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%aeroclim(i)%name = repeat(achar(0), 16)
      state%aeroclim(i)%ft0 => state%aeroclim_g(i)%ft0
      state%aeroclim(i)%ft1 => state%aeroclim_g(i)%ft1
      state%aeroclim(i)%ft9 => state%aeroclim_g(i)%ft9
      state%aeroclim(i)%fph9 => state%aeroclim_g(i)%fph9
      state%aeroclim(i)%fdl => state%aeroclim_g(i)%fdl
      state%aeroclim(i)%fdm => state%aeroclim_g(i)%fdm
    end do
    nullify (state%uvp)
    count = size(state%uvp_g, kind=int64)
    allocate (state%uvp(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%uvp(i)%name = repeat(achar(0), 16)
      state%uvp(i)%ft0 => state%uvp_g(i)%ft0
      state%uvp(i)%ft1 => state%uvp_g(i)%ft1
      state%uvp(i)%ft9 => state%uvp_g(i)%ft9
      state%uvp(i)%fph9 => state%uvp_g(i)%fph9
      state%uvp(i)%fdl => state%uvp_g(i)%fdl
      state%uvp(i)%fdm => state%uvp_g(i)%fdm
    end do
    nullify (state%phys)
    count = size(state%phys_g, kind=int64)
    allocate (state%phys(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%phys(i)%name = repeat(achar(0), 16)
      state%phys(i)%ft0 => state%phys_g(i)%ft0
      state%phys(i)%ft1 => state%phys_g(i)%ft1
      state%phys(i)%ft9 => state%phys_g(i)%ft9
      state%phys(i)%fph9 => state%phys_g(i)%fph9
      state%phys(i)%fdl => state%phys_g(i)%fdl
      state%phys(i)%fdm => state%phys_g(i)%fdm
    end do
    nullify (state%lima)
    count = size(state%lima_g, kind=int64)
    allocate (state%lima(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%lima(i)%name = repeat(achar(0), 16)
      state%lima(i)%ft0 => state%lima_g(i)%ft0
      state%lima(i)%ft1 => state%lima_g(i)%ft1
      state%lima(i)%ft9 => state%lima_g(i)%ft9
      state%lima(i)%fph9 => state%lima_g(i)%fph9
      state%lima(i)%fdl => state%lima_g(i)%fdl
      state%lima(i)%fdm => state%lima_g(i)%fdm
    end do
    nullify (state%ext)
    count = size(state%ext_g, kind=int64)
    allocate (state%ext(1_int64:count), stat=allocation_status)
    if (allocation_status /= 0) call fatal_allocation_exit(116_c_int)
    do i = 1_int64, count
      ! Retain the old deterministic policy only for source-undefined NAME.
      ! Canonical declaration defaults supply CNAME, code, flags and null views.
      state%ext(i)%name = repeat(achar(0), 16)
      state%ext(i)%ft0 => state%ext_g(i)%ft0
      state%ext(i)%ft1 => state%ext_g(i)%ft1
      state%ext(i)%ft9 => state%ext_g(i)%ft9
      state%ext(i)%fph9 => state%ext_g(i)%fph9
      state%ext(i)%fdl => state%ext_g(i)%fdl
      state%ext(i)%fdm => state%ext_g(i)%fdm
    end do
    call ieee_set_status(incoming_status)
    errno_word = incoming_errno
    status = 0_c_int
  end function clone_field_variable_arrays

  !> Follow exactly one completed clone after all private view users finish.
  !> Release private metadata only, then restore the complete shared aliases.
  !> FIELD metadata and all physical payload owners are never released here.
  integer(c_int) function reset_field_variable_arrays(state) result(status)
    type(native_field_variables), intent(inout) :: state
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    type(ieee_status_type) :: incoming_status
    call increment_count(2)
    call c_f_pointer(errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(incoming_status)

    deallocate (state%ghg)
    state%ghg => state%ghg_g
    deallocate (state%chem)
    state%chem => state%chem_g
    deallocate (state%aero)
    state%aero => state%aero_g
    deallocate (state%forc)
    state%forc => state%forc_g
    deallocate (state%ezdiag)
    state%ezdiag => state%ezdiag_g
    deallocate (state%era40)
    state%era40 => state%era40_g
    deallocate (state%nogw)
    state%nogw => state%nogw_g
    deallocate (state%emis3d)
    state%emis3d => state%emis3d_g
    deallocate (state%edrp)
    state%edrp => state%edrp_g
    deallocate (state%sldia)
    state%sldia => state%sldia_g
    deallocate (state%aeraot)
    state%aeraot => state%aeraot_g
    deallocate (state%aerlisi)
    state%aerlisi => state%aerlisi_g
    deallocate (state%aerout)
    state%aerout => state%aerout_g
    deallocate (state%aeroclim)
    state%aeroclim => state%aeroclim_g
    deallocate (state%uvp)
    state%uvp => state%uvp_g
    deallocate (state%phys)
    state%phys => state%phys_g
    deallocate (state%lima)
    state%lima => state%lima_g
    deallocate (state%ext)
    state%ext => state%ext_g
    call ieee_set_status(incoming_status)
    errno_word = incoming_errno
    status = 0_c_int
  end function reset_field_variable_arrays

  !> Update all79 source-listed entries using the live block number.
  !> Private array descriptors retain actual strides and metadata bounds.
  !> The caller supplies a valid block for every associated active field.
  integer(c_int) function update_field_variable_views(state, block) result(status)
    type(native_field_variables), intent(inout) :: state
    integer(c_int), intent(in) :: block
    integer(int64) :: i
    call increment_count(1)

    status = update_variable_view(state%u, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%v, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%t, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%div, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%vor, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%spd, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%svd, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%nhx, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%edot, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%sgrtl, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%sgrtm, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%sp, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%q, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%i, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%l, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%lconv, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%iconv, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%rconv, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%sconv, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%irad, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%lrad, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%s, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%r, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%g, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%h, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%tke, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%tte, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%efb1, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%efb2, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%efb3, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%a, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%o3, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%src, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%mxl, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%shtur, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%fqtur, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%fstur, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%cpf, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%spf, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%cvgq, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%qva, block)
    if (status /= 0_c_int) return
    do i = lbound(state%ghg, 1, kind=int64), ubound(state%ghg, 1, kind=int64)
      status = update_variable_view(state%ghg(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%chem, 1, kind=int64), ubound(state%chem, 1, kind=int64)
      status = update_variable_view(state%chem(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%aero, 1, kind=int64), ubound(state%aero, 1, kind=int64)
      status = update_variable_view(state%aero(i), block)
      if (status /= 0_c_int) return
    end do
    status = update_variable_view(state%lrch4, block)
    if (status /= 0_c_int) return
    do i = lbound(state%forc, 1, kind=int64), ubound(state%forc, 1, kind=int64)
      status = update_variable_view(state%forc(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%ezdiag, 1, kind=int64), ubound(state%ezdiag, 1, kind=int64)
      status = update_variable_view(state%ezdiag(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%era40, 1, kind=int64), ubound(state%era40, 1, kind=int64)
      status = update_variable_view(state%era40(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%nogw, 1, kind=int64), ubound(state%nogw, 1, kind=int64)
      status = update_variable_view(state%nogw(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%emis3d, 1, kind=int64), ubound(state%emis3d, 1, kind=int64)
      status = update_variable_view(state%emis3d(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%edrp, 1, kind=int64), ubound(state%edrp, 1, kind=int64)
      status = update_variable_view(state%edrp(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%sldia, 1, kind=int64), ubound(state%sldia, 1, kind=int64)
      status = update_variable_view(state%sldia(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%aeraot, 1, kind=int64), ubound(state%aeraot, 1, kind=int64)
      status = update_variable_view(state%aeraot(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%aerlisi, 1, kind=int64), ubound(state%aerlisi, 1, kind=int64)
      status = update_variable_view(state%aerlisi(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%aerout, 1, kind=int64), ubound(state%aerout, 1, kind=int64)
      status = update_variable_view(state%aerout(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%aeroclim, 1, kind=int64), ubound(state%aeroclim, 1, kind=int64)
      status = update_variable_view(state%aeroclim(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%uvp, 1, kind=int64), ubound(state%uvp, 1, kind=int64)
      status = update_variable_view(state%uvp(i), block)
      if (status /= 0_c_int) return
    end do
    do i = lbound(state%phys, 1, kind=int64), ubound(state%phys, 1, kind=int64)
      status = update_variable_view(state%phys(i), block)
      if (status /= 0_c_int) return
    end do
    status = update_variable_view(state%phycty, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%rspec, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%sdsat, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%cvv, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%rkth, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%rktqv, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%rktqc, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%uom, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%ual, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%dom, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%dal, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%uen, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%unebh, block)
    if (status /= 0_c_int) return
    do i = lbound(state%lima, 1, kind=int64), ubound(state%lima, 1, kind=int64)
      status = update_variable_view(state%lima(i), block)
      if (status /= 0_c_int) return
    end do
    status = update_variable_view(state%fsd, block)
    if (status /= 0_c_int) return
    do i = lbound(state%ext, 1, kind=int64), ubound(state%ext, 1, kind=int64)
      status = update_variable_view(state%ext(i), block)
      if (status /= 0_c_int) return
    end do
    status = update_variable_view(state%ecphys%ustrti, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%ecphys%vstrti, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%ecphys%ahfsti, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%ecphys%evapti, block)
    if (status /= 0_c_int) return
    status = update_variable_view(state%ecphys%tskti, block)
    if (status /= 0_c_int) return
    status = 0_c_int
  end function update_field_variable_views

  !> Retain a null FIELD's incoming view, then alias P to the final T0 view.
  !> Numerical arrays are borrowed; this entry reads no physical array value.
  integer(c_int) function update_variable_view_2d(variable, block) result(status)
    type(native_registry_variable_2d), intent(inout) :: variable
    integer(c_int), intent(in) :: block
    call increment_count(3)
    status = 0_c_int
    if (associated(variable%ft0)) then
      status = physics_field_view_2d(variable%t0, variable%ft0, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%ft1)) then
      status = physics_field_view_2d(variable%t1, variable%ft1, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%ft9)) then
      status = physics_field_view_2d(variable%t9, variable%ft9, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%fph9)) then
      status = physics_field_view_2d(variable%ph9, variable%fph9, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%fdl)) then
      status = physics_field_view_2d(variable%dl, variable%fdl, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%fdm)) then
      status = physics_field_view_2d(variable%dm, variable%fdm, block)
      if (status /= 0_c_int) return
    end if
    variable%p => variable%t0
  end function update_variable_view_2d

  !> Retain a null FIELD's incoming view, then alias P to the final T0 view.
  !> Numerical arrays are borrowed; this entry reads no physical array value.
  integer(c_int) function update_variable_view_3d(variable, block) result(status)
    type(native_registry_variable_3d), intent(inout) :: variable
    integer(c_int), intent(in) :: block
    call increment_count(4)
    status = 0_c_int
    if (associated(variable%ft0)) then
      status = physics_field_view_3d(variable%t0, variable%ft0, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%ft1)) then
      status = physics_field_view_3d(variable%t1, variable%ft1, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%ft9)) then
      status = physics_field_view_3d(variable%t9, variable%ft9, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%fph9)) then
      status = physics_field_view_3d(variable%ph9, variable%fph9, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%fdl)) then
      status = physics_field_view_3d(variable%dl, variable%fdl, block)
      if (status /= 0_c_int) return
    end if
    if (associated(variable%fdm)) then
      status = physics_field_view_3d(variable%dm, variable%fdm, block)
      if (status /= 0_c_int) return
    end if
    variable%p => variable%t0
  end function update_variable_view_3d

  !> Count entries0 clone,1 parent update,2 reset,3 rank2 and4 rank3 updates.
  !> This native process-local diagnostic has the original modulo64-bit rule.
  subroutine increment_count(index)
    integer, intent(in) :: index
    if (calls(index) == huge(0_int64)) then
      calls(index) = -huge(0_int64) - 1_int64
    else
      calls(index) = calls(index) + 1_int64
    end if
  end subroutine increment_count

  integer(int64) function field_variable_call_count_get(index) result(count)
    integer(c_int), intent(in) :: index
    count = 0_int64
    if (index < 0_c_int .or. index >= 5_c_int) return
    count = calls(index)
  end function field_variable_call_count_get
end module forecast_field_variable_arrays
