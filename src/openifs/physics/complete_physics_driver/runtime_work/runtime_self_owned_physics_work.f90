! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Own the seven runtime physics work records at their source lifetime.
module forecast_runtime_self_owned_physics_work
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use oml_mod, only: oml_max_threads
  use yoerad, only: terad
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_physics_work_types
  use forecast_additional_physics_work_records
  use runtime_physics_work_shape_counts_mod, only: bind_runtime_physics_work_shape_counts
  use runtime_physics_dimension_binding_mod, only: update_runtime_physics_dimensions
  implicit none
  private
  public :: native_runtime_physics_work, create_runtime_self_owned_physics_work
  public :: update_runtime_self_owned_physics_work, release_runtime_self_owned_physics_work
  type :: native_runtime_physics_work
    type(native_geometry_state), pointer :: geometry => null()
    type(native_operational_model_configuration), pointer :: model => null()
    type(surface_field_registry), pointer :: surface => null()
    type(dimension_type), pointer :: dimensions => null()
    type(terad), pointer :: radiation => null()
    integer(int32) :: counts(8) = 0_int32, acquired = 0_int32
    type(flux_type) :: flux
    type(aux_diag_type) :: diagnostics
    type(ddh_surf_type) :: surface_diagnostics
    type(aux_diag_local_type) :: auxiliary_local
    type(surf_and_more_local_type) :: surface_local
    type(keys_local_type) :: keys
    type(perturb_local_type) :: perturbation_local
  end type
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Construct in source order, committing OUTPUT only after all seven children.
  !! The five target inputs remain borrowed and stable until release. Source
  !! bounds are columns1:1024, positive layers and all eight counts0:512;
  !! fourteen surface diagnostic classes are0:512. This route uses one thread.
  !! New numerical owners are undefined. Status0 succeeds,1 reports allocation
  !! failure after ordered prefix cleanup, and2 refuses metadata before owning.
  integer(int32) function create_runtime_self_owned_physics_work(output,geometry,model,surface,dimensions,radiation) result(status)
    type(native_runtime_physics_work), pointer, intent(inout) :: output
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    type(surface_field_registry), target, intent(in) :: surface
    type(dimension_type), target, intent(inout) :: dimensions
    type(terad), target, intent(in) :: radiation
    type(native_runtime_physics_work), pointer :: fresh
    integer(int32) :: counts(8), classes(14), discard_status
    integer :: allocation_status
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    status = 2
    if (associated(output)) return
    if (geometry%dimensions%nproma < 1 .or. geometry%dimensions%nproma > 1024) return
    counts = 0_int32
    status = bind_runtime_physics_work_shape_counts(counts, geometry, model, surface, dimensions, radiation)
    if (status /= 0) return
    status = 2
    if (counts(1) < 1 .or. any(counts < 0) .or. any(counts > 512)) return
    classes = [dimensions%kdhvtls, dimensions%kdhftls, dimensions%kdhvtss, dimensions%kdhftss, &
               dimensions%kdhvtts, dimensions%kdhftts, dimensions%kdhvtis, dimensions%kdhftis, &
               dimensions%kdhvsss, dimensions%kdhfsss, dimensions%kdhviis, dimensions%kdhfiis, &
               dimensions%kdhvwls, dimensions%kdhfwls]
    if (dimensions%klevi < 0 .or. dimensions%klevi > 512) return
    if (any(classes < 0) .or. any(classes > 512)) return
    if (dimensions%klon /= geometry%dimensions%nproma) return
    if (geometry%partition%ngptot <= 0) return
    if (1 + (geometry%partition%ngptot - 1)/geometry%dimensions%nproma /= geometry%partition%ngpblks) return
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    if (oml_max_threads() /= 1) goto 900
    allocate (fresh, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; goto 900
    end if
    fresh%geometry => geometry; fresh%model => model; fresh%surface => surface
    fresh%dimensions => dimensions; fresh%radiation => radiation; fresh%counts = counts
    fresh%auxiliary_local%iext3d = 0_int32
    fresh%acquired = 1_int32
    status = initialize_flux_work_record(fresh%flux, geometry, counts(1:4), .false.)
    if (status /= 0) goto 800
    fresh%acquired = 2_int32
    status = initialize_auxiliary_diagnostic_work_record(fresh%diagnostics, geometry, counts(1), .false.)
    if (status /= 0) goto 800
    fresh%acquired = 3_int32
    status = initialize_surface_diagnostic_work_record(fresh%surface_diagnostics, geometry, dimensions, .false.)
    if (status /= 0) goto 800
    fresh%acquired = 4_int32
    status = initialize_auxiliary_diagnostic_local_work_record(fresh%auxiliary_local, geometry, counts(1), .false.)
    if (status /= 0) goto 800
    fresh%acquired = 5_int32
    status = initialize_surface_local_work_record(fresh%surface_local, geometry, counts(5:8), .false.)
    if (status /= 0) goto 800
    fresh%acquired = 6_int32
    status = initialize_keys_local_work_record(fresh%keys, geometry, .false.)
    if (status /= 0) goto 800
    fresh%acquired = 7_int32
    status = initialize_perturbation_local_work_record(fresh%perturbation_local, geometry, counts(1), .false.)
    if (status /= 0) goto 800
    output => fresh
    status = 0
    goto 900
800 continue
    discard_status = finalize_work_prefix(fresh)
    deallocate (fresh); nullify (fresh)
    status = 1
900 continue
    call ieee_set_status(incoming_status); errno_word = incoming_errno
  end function create_runtime_self_owned_physics_work

  !> Bind zero-origin BLOCK0 and update seven work views in source order.
  !! Latitude inputs are the actual complete owner and selected borrowed view.
  integer(int32) function update_runtime_self_owned_physics_work(owner, block0, latitude_owner, latitude_view) result(status)
    type(native_runtime_physics_work), intent(inout) :: owner
    integer(int32), intent(in) :: block0
    integer(int32), pointer, intent(in) :: latitude_owner(:), latitude_view(:)
    integer(int32) :: block
    status = 2
    if (owner%acquired /= 7) return
    if (.not. associated(owner%geometry) .or. .not. associated(owner%dimensions)) return
    status = update_runtime_physics_dimensions(owner%dimensions, owner%geometry, block0, latitude_owner, latitude_view)
    if (status /= 0) return
    block = block0 + 1_int32
    status = update_flux_work_views(owner%flux, block)
    if (status /= 0) return
    status = update_auxiliary_diagnostic_work_views(owner%diagnostics, block)
    if (status /= 0) return
    status = update_surface_diagnostic_work_views(owner%surface_diagnostics, block)
    if (status /= 0) return
    status = update_auxiliary_diagnostic_local_work_views(owner%auxiliary_local, block)
    if (status /= 0) return
    status = update_surface_local_work_views(owner%surface_local, block)
    if (status /= 0) return
    status = update_keys_local_work_views(owner%keys, block)
    if (status /= 0) return
    status = update_perturbation_local_work_views(owner%perturbation_local, block)
    if (status /= 0) return
    status = 0
  end function update_runtime_self_owned_physics_work

  !> Finalize exactly the acquired prefix in source order, then release owner.
  !! A disassociated owner succeeds without work. Borrowed targets stay live.
  integer(int32) function release_runtime_self_owned_physics_work(owner) result(status)
    type(native_runtime_physics_work), pointer, intent(inout) :: owner
    type(ieee_status_type) :: incoming_status
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    status = 0
    if (.not. associated(owner)) return
    status = 2
    if (owner%acquired /= 7) return
    call ieee_get_status(incoming_status)
    call c_f_pointer(errno_address(), errno_word); incoming_errno = errno_word
    status = finalize_work_prefix(owner)
    if (status == 0) then
      deallocate (owner); nullify (owner)
    end if
    call ieee_set_status(incoming_status); errno_word = incoming_errno
  end function release_runtime_self_owned_physics_work

  integer(int32) function finalize_work_prefix(owner) result(status)
    type(native_runtime_physics_work), intent(inout) :: owner
    status = 0
    if (owner%acquired >= 1) then
      status = finalize_flux_work_record(owner%flux)
      if (status /= 0) return
    end if
    if (owner%acquired >= 2) then
      status = finalize_auxiliary_diagnostic_work_record(owner%diagnostics)
      if (status /= 0) return
    end if
    if (owner%acquired >= 3) then
      status = finalize_surface_diagnostic_work_record(owner%surface_diagnostics)
      if (status /= 0) return
    end if
    if (owner%acquired >= 4) then
      status = finalize_auxiliary_diagnostic_local_work_record(owner%auxiliary_local)
      if (status /= 0) return
    end if
    if (owner%acquired >= 5) then
      status = finalize_surface_local_work_record(owner%surface_local)
      if (status /= 0) return
    end if
    if (owner%acquired >= 6) then
      status = finalize_keys_local_work_record(owner%keys)
      if (status /= 0) return
    end if
    if (owner%acquired >= 7) then
      status = finalize_perturbation_local_work_record(owner%perturbation_local)
      if (status /= 0) return
    end if
    owner%acquired = 0_int32
  end function finalize_work_prefix
end module forecast_runtime_self_owned_physics_work
