! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Construct and release the native temporary physics context.
module forecast_physics_context_construction
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yoerad, only: terad
  use forecast_complete_physics_context_types, only: native_complete_physics_context, native_complete_physics_driver_inputs
  use forecast_native_physics_state_storage, only: initialize_physics_state, finalize_physics_state
  use forecast_auxiliary_work_record, only: initialize_auxiliary_work_record, finalize_auxiliary_work_record
  use forecast_radiation_work_record, only: initialize_radiation_work_record, finalize_radiation_work_record
  use forecast_surface_work_record, only: initialize_surface_work_record, finalize_surface_work_record
  use forecast_additional_physics_work_records
  use physics_grid_dimension_helpers_mod, only: initialize_physics_dimensions, surface_group_index
  implicit none
  private
  public :: initialize_physics_context, finish_physics_context, physics_context_lifetime_count_get
  integer(int64), save :: lifetime_calls(0:1) = 0_int64
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine fatal_context_allocation(code) bind(c, name="_exit")
      import c_int
      integer(c_int), value :: code
    end subroutine
  end interface
contains
  !> Own one context while borrowing the caller's scientific records and arrays.
  !! CONTEXT must be disassociated. All eighteen global registry arrays must be
  !! associated, contiguous and one-based, including allocated-empty arrays.
  !! The first two states borrow FT9 and FT0 fields; six states own temporary
  !! fields. The empty tendency array has its own native allocation.
  !! Work constructors retain source order. New numerical payloads are undefined.
  !! Metadata refusal returns2 before ownership begins. Allocation failure uses
  !! the source's nonreturning public _exit(116) boundary. Success returns0.
  integer(int32) function initialize_physics_context(context, inputs, radiation) result(status)
    type(native_complete_physics_context), pointer, intent(inout) :: context
    type(native_complete_physics_driver_inputs), target, intent(in) :: inputs
    type(terad), intent(in) :: radiation
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    integer :: allocation_status, j, soil, ocean, extra, extra2
    integer(int32) :: columns, levels, blocks, surface_levels(3), flux_settings(4), surface_local_settings(4)
    status = 2
    if (associated(context)) return
    if (.not. associated(inputs%records%geometry)) return
    if (.not. associated(inputs%records%model)) return
    if (.not. associated(inputs%records%variables)) return
    if (.not. associated(inputs%records%surface_metadata)) return
    if (.not. associated(inputs%surface_variables)) return
    columns = inputs%records%geometry%dimensions%nproma
    levels = inputs%records%geometry%dimensions%nflevg
    blocks = inputs%records%geometry%partition%ngpblks
    if (columns < 1 .or. levels < 0 .or. blocks < 1) return
    soil = surface_group_index(inputs%records%surface_metadata, 'YSP_SBD')
    ocean = surface_group_index(inputs%records%surface_metadata, 'YSP_OMD')
    extra = surface_group_index(inputs%records%surface_metadata, 'YSD_XAD')
    extra2 = surface_group_index(inputs%records%surface_metadata, 'YSD_X2D')
    if (soil == 0 .or. ocean == 0 .or. extra == 0 .or. extra2 == 0) return
    if (.not. associated(inputs%records%variables%ghg_g)) return
    if (.not. is_contiguous(inputs%records%variables%ghg_g)) return
    if (lbound(inputs%records%variables%ghg_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%chem_g)) return
    if (.not. is_contiguous(inputs%records%variables%chem_g)) return
    if (lbound(inputs%records%variables%chem_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%aero_g)) return
    if (.not. is_contiguous(inputs%records%variables%aero_g)) return
    if (lbound(inputs%records%variables%aero_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%forc_g)) return
    if (.not. is_contiguous(inputs%records%variables%forc_g)) return
    if (lbound(inputs%records%variables%forc_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%ezdiag_g)) return
    if (.not. is_contiguous(inputs%records%variables%ezdiag_g)) return
    if (lbound(inputs%records%variables%ezdiag_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%era40_g)) return
    if (.not. is_contiguous(inputs%records%variables%era40_g)) return
    if (lbound(inputs%records%variables%era40_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%nogw_g)) return
    if (.not. is_contiguous(inputs%records%variables%nogw_g)) return
    if (lbound(inputs%records%variables%nogw_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%emis3d_g)) return
    if (.not. is_contiguous(inputs%records%variables%emis3d_g)) return
    if (lbound(inputs%records%variables%emis3d_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%edrp_g)) return
    if (.not. is_contiguous(inputs%records%variables%edrp_g)) return
    if (lbound(inputs%records%variables%edrp_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%sldia_g)) return
    if (.not. is_contiguous(inputs%records%variables%sldia_g)) return
    if (lbound(inputs%records%variables%sldia_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%aeraot_g)) return
    if (.not. is_contiguous(inputs%records%variables%aeraot_g)) return
    if (lbound(inputs%records%variables%aeraot_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%aerlisi_g)) return
    if (.not. is_contiguous(inputs%records%variables%aerlisi_g)) return
    if (lbound(inputs%records%variables%aerlisi_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%aerout_g)) return
    if (.not. is_contiguous(inputs%records%variables%aerout_g)) return
    if (lbound(inputs%records%variables%aerout_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%aeroclim_g)) return
    if (.not. is_contiguous(inputs%records%variables%aeroclim_g)) return
    if (lbound(inputs%records%variables%aeroclim_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%uvp_g)) return
    if (.not. is_contiguous(inputs%records%variables%uvp_g)) return
    if (lbound(inputs%records%variables%uvp_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%phys_g)) return
    if (.not. is_contiguous(inputs%records%variables%phys_g)) return
    if (lbound(inputs%records%variables%phys_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%lima_g)) return
    if (.not. is_contiguous(inputs%records%variables%lima_g)) return
    if (lbound(inputs%records%variables%lima_g, 1) /= 1) return
    if (.not. associated(inputs%records%variables%ext_g)) return
    if (.not. is_contiguous(inputs%records%variables%ext_g)) return
    if (lbound(inputs%records%variables%ext_g, 1) /= 1) return
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    allocate (context, stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%records = inputs%records
    context%arrays = inputs%arrays
    context%surface_variables => inputs%surface_variables
    context%variables = inputs%records%variables
    nullify (context%variables%ghg_g)
    allocate (context%variables%ghg_g(1:size(inputs%records%variables%ghg_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%ghg_g = inputs%records%variables%ghg_g
    nullify (context%variables%chem_g)
    allocate (context%variables%chem_g(1:size(inputs%records%variables%chem_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%chem_g = inputs%records%variables%chem_g
    nullify (context%variables%aero_g)
    allocate (context%variables%aero_g(1:size(inputs%records%variables%aero_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%aero_g = inputs%records%variables%aero_g
    nullify (context%variables%forc_g)
    allocate (context%variables%forc_g(1:size(inputs%records%variables%forc_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%forc_g = inputs%records%variables%forc_g
    nullify (context%variables%ezdiag_g)
    allocate (context%variables%ezdiag_g(1:size(inputs%records%variables%ezdiag_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%ezdiag_g = inputs%records%variables%ezdiag_g
    nullify (context%variables%era40_g)
    allocate (context%variables%era40_g(1:size(inputs%records%variables%era40_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%era40_g = inputs%records%variables%era40_g
    nullify (context%variables%nogw_g)
    allocate (context%variables%nogw_g(1:size(inputs%records%variables%nogw_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%nogw_g = inputs%records%variables%nogw_g
    nullify (context%variables%emis3d_g)
    allocate (context%variables%emis3d_g(1:size(inputs%records%variables%emis3d_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%emis3d_g = inputs%records%variables%emis3d_g
    nullify (context%variables%edrp_g)
    allocate (context%variables%edrp_g(1:size(inputs%records%variables%edrp_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%edrp_g = inputs%records%variables%edrp_g
    nullify (context%variables%sldia_g)
    allocate (context%variables%sldia_g(1:size(inputs%records%variables%sldia_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%sldia_g = inputs%records%variables%sldia_g
    nullify (context%variables%aeraot_g)
    allocate (context%variables%aeraot_g(1:size(inputs%records%variables%aeraot_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%aeraot_g = inputs%records%variables%aeraot_g
    nullify (context%variables%aerlisi_g)
    allocate (context%variables%aerlisi_g(1:size(inputs%records%variables%aerlisi_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%aerlisi_g = inputs%records%variables%aerlisi_g
    nullify (context%variables%aerout_g)
    allocate (context%variables%aerout_g(1:size(inputs%records%variables%aerout_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%aerout_g = inputs%records%variables%aerout_g
    nullify (context%variables%aeroclim_g)
    allocate (context%variables%aeroclim_g(1:size(inputs%records%variables%aeroclim_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%aeroclim_g = inputs%records%variables%aeroclim_g
    nullify (context%variables%uvp_g)
    allocate (context%variables%uvp_g(1:size(inputs%records%variables%uvp_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%uvp_g = inputs%records%variables%uvp_g
    nullify (context%variables%phys_g)
    allocate (context%variables%phys_g(1:size(inputs%records%variables%phys_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%phys_g = inputs%records%variables%phys_g
    nullify (context%variables%lima_g)
    allocate (context%variables%lima_g(1:size(inputs%records%variables%lima_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%lima_g = inputs%records%variables%lima_g
    nullify (context%variables%ext_g)
    allocate (context%variables%ext_g(1:size(inputs%records%variables%ext_g, kind=int64)), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%variables%ext_g = inputs%records%variables%ext_g
    context%global_metadata_owned = .true.
    context%mask%o3 = context%variables%o3%lactive
    context%mask%q = context%variables%q%lactive
    context%mask%a = context%variables%a%lactive
    context%mask%ql = context%variables%l%lactive
    context%mask%qi = context%variables%i%lactive
    context%mask%qr = context%variables%r%lactive
    context%mask%qs = context%variables%s%lactive
    context%mask%tke = context%variables%tke%lactive
    status = initialize_physics_state(context%states(1), columns, levels, blocks, context%mask, .false., &
      u=context%variables%u%ft9,v=context%variables%v%ft9,t=context%variables%t%ft9,o3=context%variables%o3%ft9,q=context%variables%q%ft9,a=context%variables%a%ft9,ql=context%variables%l%ft9,qi=context%variables%i%ft9,qr=context%variables%r%ft9,qs=context%variables%s%ft9,tke=context%variables%tke%ft9)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%state_acquired(1) = .true.
    status = initialize_physics_state(context%states(2), columns, levels, blocks, context%mask, .false., &
      u=context%variables%u%ft0,v=context%variables%v%ft0,t=context%variables%t%ft0,o3=context%variables%o3%ft0,q=context%variables%q%ft0,a=context%variables%a%ft0,ql=context%variables%l%ft0,qi=context%variables%i%ft0,qr=context%variables%r%ft0,qs=context%variables%s%ft0,tke=context%variables%tke%ft0)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%state_acquired(2) = .true.
    do j = 3, 8
      status = initialize_physics_state(context%states(j), columns, levels, blocks, context%mask, .false.)
      if (status /= 0) call fatal_context_allocation(116_c_int)
      context%state_acquired(j) = .true.
    end do
    allocate (context%tendency_phy(0), stat=allocation_status)
    if (allocation_status /= 0) call fatal_context_allocation(116_c_int)
    context%dimensions%kidia = 0_int32
    context%dimensions%kfdia = 0_int32
    context%dimensions%kbl = 0_int32
    context%dimensions%klon = 0_int32
    context%dimensions%ksmax = 0_int32
    context%dimensions%klevs = 0_int32
    context%dimensions%ktiles = 0_int32
    context%dimensions%kstglo = 0_int32
    context%dimensions%klevx = 0_int32
    context%dimensions%kfldx = 0_int32
    context%dimensions%kfldx2 = 0_int32
    context%dimensions%ktdia = 0_int32
    context%dimensions%klev = 0_int32
    context%dimensions%kvclis = 0_int32
    context%dimensions%klevi = 0_int32
    context%dimensions%klevo = 0_int32
    context%dimensions%klevsn = 0_int32
    context%dimensions%kdhvtls = 0_int32
    context%dimensions%kdhftls = 0_int32
    context%dimensions%kdhvtss = 0_int32
    context%dimensions%kdhftss = 0_int32
    context%dimensions%kdhvtts = 0_int32
    context%dimensions%kdhftts = 0_int32
    context%dimensions%kdhvtis = 0_int32
    context%dimensions%kdhftis = 0_int32
    context%dimensions%kdhvsss = 0_int32
    context%dimensions%kdhfsss = 0_int32
    context%dimensions%kdhviis = 0_int32
    context%dimensions%kdhfiis = 0_int32
    context%dimensions%kdhvwls = 0_int32
    context%dimensions%kdhfwls = 0_int32
    context%dimensions%k2dsdt = 0_int32
    nullify (context%dimensions%kgplat)
    context%auxiliary%nlev = 0_int32
    context%auxiliary_local%iext3d = 0_int32
    status = initialize_physics_dimensions(context%dimensions, inputs%records%geometry, inputs%records%model, &
                                           inputs%records%surface_metadata, inputs%soil_diagnostics, inputs%lspsdt, inputs%n2d)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    surface_levels = [inputs%records%surface_metadata%groups(soil)%metadata%layers, &
                      inputs%records%model%physics_dimensions%ncsnec, inputs%records%surface_metadata%groups(ocean)%metadata%layers]
    flux_settings = [levels, surface_levels(1), inputs%records%model%fields%settings%nactaero, 8_int32]
    surface_local_settings = [surface_levels(2), inputs%records%model%physics_dimensions%ntiles, radiation%ntsw, radiation%nlwemiss]
    status=initialize_surface_work_record(context%surface,inputs%records%geometry,context%variables,inputs%surface_variables,surface_levels,.false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(1) = .true.
    status = initialize_auxiliary_work_record(context%auxiliary, inputs%records%geometry, context%variables, levels, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(2) = .true.
    status = initialize_radiation_work_record(context%radiation, inputs%records%geometry, context%variables, levels, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(3) = .true.
    status = initialize_flux_work_record(context%flux, inputs%records%geometry, flux_settings, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(4) = .true.
    status = initialize_auxiliary_diagnostic_work_record(context%diagnostics, inputs%records%geometry, levels, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(5) = .true.
    status=initialize_surface_diagnostic_work_record(context%surface_diagnostics,inputs%records%geometry,context%dimensions,.false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(6) = .true.
    status = initialize_auxiliary_diagnostic_local_work_record(context%auxiliary_local, inputs%records%geometry, levels, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(7) = .true.
    status = initialize_surface_local_work_record(context%surface_local, inputs%records%geometry, surface_local_settings, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(8) = .true.
    status = initialize_keys_local_work_record(context%keys, inputs%records%geometry, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(9) = .true.
    status = initialize_perturbation_local_work_record(context%perturbation_local, inputs%records%geometry, levels, .false.)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    context%work_acquired(10) = .true.
    context%records%variables => context%variables
    context%records%dimensions => context%dimensions
    context%records%surface => context%surface
    context%records%auxiliary => context%auxiliary
    context%records%radiation => context%radiation
    context%records%flux => context%flux
    context%records%diagnostics => context%diagnostics
    context%records%surface_diagnostics => context%surface_diagnostics
    context%records%auxiliary_local => context%auxiliary_local
    context%records%surface_local => context%surface_local
    context%records%keys => context%keys
    context%records%perturbation => context%perturbation
    context%records%perturbation_local => context%perturbation_local
    context%records%state_t0 => context%states(1)
    context%records%tendency_dyn => context%states(2)
    context%records%tendency_cml => context%states(3)
    context%records%state_tmp => context%states(4)
    context%records%tendency_tmp => context%states(5)
    context%records%tendency_vdf => context%states(6)
    context%records%tendency_satadj => context%states(7)
    context%records%tendency_loc => context%states(8)
    context%records%tendency_phy => context%tendency_phy
    context%initialized = .true.
    call increment_lifetime(0)
    call ieee_set_status(incoming_status); errno_word = incoming_errno
    status = 0
  end function initialize_physics_context

  !> Release owned storage in the original state, PHY, work and global-array order.
  !! Finish after the matching end-block reset. Borrowed fields stay untouched.
  integer(int32) function finish_physics_context(context) result(status)
    type(native_complete_physics_context), pointer, intent(inout) :: context
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    integer :: j
    status = 0
    if (.not. associated(context)) return
    status = 2
    if (context%private_metadata_owned .or. any(context%fallback_owned)) return
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    do j = 1, 8
      call finalize_physics_state(context%states(j))
    end do
    if (associated(context%tendency_phy)) deallocate (context%tendency_phy)
    status = finalize_surface_work_record(context%surface)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_auxiliary_work_record(context%auxiliary)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_radiation_work_record(context%radiation)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_flux_work_record(context%flux)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_auxiliary_diagnostic_work_record(context%diagnostics)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_surface_diagnostic_work_record(context%surface_diagnostics)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_auxiliary_diagnostic_local_work_record(context%auxiliary_local)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_surface_local_work_record(context%surface_local)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_keys_local_work_record(context%keys)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    status = finalize_perturbation_local_work_record(context%perturbation_local)
    if (status /= 0) call fatal_context_allocation(116_c_int)
    if (associated(context%variables%ghg_g)) deallocate (context%variables%ghg_g)
    if (associated(context%variables%chem_g)) deallocate (context%variables%chem_g)
    if (associated(context%variables%aero_g)) deallocate (context%variables%aero_g)
    if (associated(context%variables%forc_g)) deallocate (context%variables%forc_g)
    if (associated(context%variables%ezdiag_g)) deallocate (context%variables%ezdiag_g)
    if (associated(context%variables%era40_g)) deallocate (context%variables%era40_g)
    if (associated(context%variables%nogw_g)) deallocate (context%variables%nogw_g)
    if (associated(context%variables%emis3d_g)) deallocate (context%variables%emis3d_g)
    if (associated(context%variables%edrp_g)) deallocate (context%variables%edrp_g)
    if (associated(context%variables%sldia_g)) deallocate (context%variables%sldia_g)
    if (associated(context%variables%aeraot_g)) deallocate (context%variables%aeraot_g)
    if (associated(context%variables%aerlisi_g)) deallocate (context%variables%aerlisi_g)
    if (associated(context%variables%aerout_g)) deallocate (context%variables%aerout_g)
    if (associated(context%variables%aeroclim_g)) deallocate (context%variables%aeroclim_g)
    if (associated(context%variables%uvp_g)) deallocate (context%variables%uvp_g)
    if (associated(context%variables%phys_g)) deallocate (context%variables%phys_g)
    if (associated(context%variables%lima_g)) deallocate (context%variables%lima_g)
    if (associated(context%variables%ext_g)) deallocate (context%variables%ext_g)
    deallocate (context); nullify (context)
    call increment_lifetime(1)
    call ieee_set_status(incoming_status); errno_word = incoming_errno
    status = 0
  end function finish_physics_context

  subroutine increment_lifetime(index)
    integer, intent(in) :: index
    if (lifetime_calls(index) == huge(lifetime_calls(index))) then
      lifetime_calls(index) = -huge(lifetime_calls(index)) - 1_int64
    else
      lifetime_calls(index) = lifetime_calls(index) + 1_int64
    end if
  end subroutine
  integer(int64) function physics_context_lifetime_count_get(index) result(count)
    integer(int32), intent(in) :: index
    count = 0_int64
    if (index >= 0 .and. index < 2) count = lifetime_calls(index)
  end function
end module forecast_physics_context_construction
