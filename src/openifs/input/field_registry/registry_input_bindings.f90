!> Bind named read-only registry views to canonical live owners.
module forecast_registry_input_bindings
  use iso_fortran_env, only: int32, real64
  use forecast_native_field_variable_types
  use forecast_geometry_state_types, only: native_geometry_state
  use yomradf, only: tradf
  implicit none
contains
  !> Bind the eighteen spherical block owners and three existing terrain views.
  !! The terrain rank-2 owners must come from their real producer; the current
  !! separate per-block terrain storage cannot be reinterpreted as one array.
  subroutine bind_registry_geometry_inputs(output, geometry, orog, orogl, orogm)
    type(native_registry_geometry_inputs), intent(out) :: output
    type(native_geometry_state), target, intent(in) :: geometry
    real(real64), pointer, intent(in) :: orog(:, :), orogl(:, :), orogm(:, :)
    output%rcori => geometry%spherical%blocked%rcori
    output%rcoric => geometry%spherical%blocked%rcoric
    output%gemu => geometry%spherical%blocked%gemu
    output%gsqm2 => geometry%spherical%blocked%gsqm2
    output%gelam => geometry%spherical%blocked%gelam
    output%gelat => geometry%spherical%blocked%gelat
    output%geclo => geometry%spherical%blocked%geclo
    output%geslo => geometry%spherical%blocked%geslo
    output%gm => geometry%spherical%blocked%gm
    output%gmappa => geometry%spherical%blocked%gmappa
    output%gomvrl => geometry%spherical%blocked%gomvrl
    output%gomvrm => geometry%spherical%blocked%gomvrm
    output%gnordl => geometry%spherical%blocked%gnordl
    output%gnordm => geometry%spherical%blocked%gnordm
    output%gnordlcl => geometry%spherical%blocked%gnordlcl
    output%gnordmcl => geometry%spherical%blocked%gnordmcl
    output%gnordmcm => geometry%spherical%blocked%gnordmcm
    output%gaw => geometry%spherical%blocked%gaw
    output%orog => orog
    output%orogl => orogl
    output%orogm => orogm
  end subroutine
  !> Absent original EMTU/RMOON remain absent; no payload is initialized.
  subroutine bind_registry_radiation_inputs(output, fluxes)
    type(native_registry_radiation_inputs), intent(out) :: output
    type(tradf), target, intent(in) :: fluxes
    nullify (output%emtd)
    if (allocated(fluxes%emtd)) output%emtd => fluxes%emtd
    nullify (output%trsw)
    if (allocated(fluxes%trsw)) output%trsw => fluxes%trsw
    nullify (output%emtc)
    if (allocated(fluxes%emtc)) output%emtc => fluxes%emtc
    nullify (output%trsc)
    if (allocated(fluxes%trsc)) output%trsc => fluxes%trsc
    nullify (output%emtu)
    if (allocated(fluxes%emtu)) output%emtu => fluxes%emtu
    nullify (output%tauaer)
    if (allocated(fluxes%tauaer)) output%tauaer => fluxes%tauaer
    nullify (output%srswd)
    if (allocated(fluxes%srswd)) output%srswd => fluxes%srswd
    nullify (output%srlwdc)
    if (allocated(fluxes%srlwdc)) output%srlwdc => fluxes%srlwdc
    nullify (output%srlwd)
    if (allocated(fluxes%srlwd)) output%srlwd => fluxes%srlwd
    nullify (output%srswdc)
    if (allocated(fluxes%srswdc)) output%srswdc => fluxes%srswdc
    nullify (output%srswdcs)
    if (allocated(fluxes%srswdcs)) output%srswdcs => fluxes%srswdcs
    nullify (output%srlwdcs)
    if (allocated(fluxes%srlwdcs)) output%srlwdcs => fluxes%srlwdcs
    nullify (output%srswdv)
    if (allocated(fluxes%srswdv)) output%srswdv => fluxes%srswdv
    nullify (output%srswduv)
    if (allocated(fluxes%srswduv)) output%srswduv => fluxes%srswduv
    nullify (output%edro)
    if (allocated(fluxes%edro)) output%edro => fluxes%edro
    nullify (output%srswpar)
    if (allocated(fluxes%srswpar)) output%srswpar => fluxes%srswpar
    nullify (output%srswuvb)
    if (allocated(fluxes%srswuvb)) output%srswuvb => fluxes%srswuvb
    nullify (output%srswparc)
    if (allocated(fluxes%srswparc)) output%srswparc => fluxes%srswparc
    nullify (output%srswtinc)
    if (allocated(fluxes%srswtinc)) output%srswtinc => fluxes%srswtinc
    nullify (output%srfdir)
    if (allocated(fluxes%srfdir)) output%srfdir => fluxes%srfdir
    nullify (output%srcdir)
    if (allocated(fluxes%srcdir)) output%srcdir => fluxes%srcdir
    nullify (output%rmoon)
    if (allocated(fluxes%rmoon)) output%rmoon => fluxes%rmoon
    nullify (output%derivativelw)
    if (associated(fluxes%derivativelw)) output%derivativelw => fluxes%derivativelw
  end subroutine
end module forecast_registry_input_bindings
