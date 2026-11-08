!> Build named metadata over existing geometry and physics arrays.
module forecast_registry_registration
  use iso_fortran_env, only: int32
  use forecast_registry_field_types
  use forecast_registry_storage
  use forecast_native_field_variable_types
  implicit none
contains
  integer(int32) function allocate_field_variables(output) result(status)
    type(native_field_variables), pointer, intent(inout) :: output
    integer :: allocation_status
    status = 0
    if (associated(output)) return
    allocate (output, stat=allocation_status)
    if (allocation_status /= 0) status = 1
  end function
  integer(int32) function register_registry_geometry(output, inputs) result(status)
    type(native_field_variables), pointer, intent(inout) :: output
    type(native_registry_geometry_inputs), intent(in) :: inputs
    status = allocate_field_variables(output)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%rcori, 'RCORI', inputs%rcori)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%rcoric, 'RCORIC', inputs%rcoric)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gemu, 'GEMU', inputs%gemu)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gsqm2, 'GSQM2', inputs%gsqm2)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gelam, 'GELAM', inputs%gelam)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gelat, 'GELAT', inputs%gelat)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%geclo, 'GECLO', inputs%geclo)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%geslo, 'GESLO', inputs%geslo)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gm, 'GM', inputs%gm)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gmappa, 'GMAPPA', inputs%gmappa)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gomvrl, 'GOMVRL', inputs%gomvrl)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gomvrm, 'GOMVRM', inputs%gomvrm)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gnordl, 'GNORDL', inputs%gnordl)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gnordm, 'GNORDM', inputs%gnordm)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gnordlcl, 'GNORDLCL', inputs%gnordlcl)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gnordmcl, 'GNORDMCL', inputs%gnordmcl)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gnordmcm, 'GNORDMCM', inputs%gnordmcm)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%gaw, 'GAW', inputs%gaw)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%orog, 'OROG', inputs%orog)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%orogl, 'OROGL', inputs%orogl)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%geometry%orogm, 'OROGM', inputs%orogm)
    if (status /= 0) return
  end function
  integer(int32) function register_registry_ec_physics(output, inputs) result(status)
    type(native_field_variables), pointer, intent(inout) :: output
    type(native_registry_ecphysics_inputs), intent(in) :: inputs
    status = allocate_field_variables(output)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%ecphys%ustrti, 'USTRTI', inputs%ustrti)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%ecphys%vstrti, 'VSTRTI', inputs%vstrti)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%ecphys%ahfsti, 'AHFSTI', inputs%ahfsti)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%ecphys%evapti, 'EVAPTI', inputs%evapti)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%ecphys%tskti, 'TSKTI', inputs%tskti)
    if (status /= 0) return
  end function
  integer(int32) function register_registry_radiation(output, inputs) result(status)
    type(native_field_variables), pointer, intent(inout) :: output
    type(native_registry_radiation_inputs), intent(in) :: inputs
    status = allocate_field_variables(output)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%radiation%emtd, 'EMTD', inputs%emtd)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%radiation%trsw, 'TRSW', inputs%trsw)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%radiation%emtc, 'EMTC', inputs%emtc)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%radiation%trsc, 'TRSC', inputs%trsc)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%radiation%emtu, 'EMTU', inputs%emtu)
    if (status /= 0) return
    status = wrap_registry_variable_4d(output%radiation%tauaer, 'TAUAER', inputs%tauaer)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswd, 'SRSWD', inputs%srswd)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srlwdc, 'SRLWDC', inputs%srlwdc)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%radiation%srlwd, 'SRLWD', inputs%srlwd)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswdc, 'SRSWDC', inputs%srswdc)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswdcs, 'SRSWDCS', inputs%srswdcs)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srlwdcs, 'SRLWDCS', inputs%srlwdcs)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswdv, 'SRSWDV', inputs%srswdv)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswduv, 'SRSWDUV', inputs%srswduv)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%edro, 'EDRO', inputs%edro)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswpar, 'SRSWPAR', inputs%srswpar)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswuvb, 'SRSWUVB', inputs%srswuvb)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswparc, 'SRSWPARC', inputs%srswparc)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srswtinc, 'SRSWTINC', inputs%srswtinc)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srfdir, 'SRFDIR', inputs%srfdir)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%srcdir, 'SRCDIR', inputs%srcdir)
    if (status /= 0) return
    status = wrap_registry_variable_2d(output%radiation%rmoon, 'RMOON', inputs%rmoon)
    if (status /= 0) return
    status = wrap_registry_variable_3d(output%radiation%derivativelw, 'DERIVATIVELW', inputs%derivativelw)
    if (status /= 0) return
  end function
end module forecast_registry_registration
