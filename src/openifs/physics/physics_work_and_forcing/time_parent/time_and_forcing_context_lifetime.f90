!> Bind source scientific storage to actual surface owners without a second clock.
module forecast_time_and_forcing_context_lifetime
  use iso_fortran_env, only: int32
  use forecast_model_time_and_forcing, only: native_time_and_forcing_context
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry
  implicit none
  private
  public :: bind_time_and_forcing_context, release_time_and_forcing_context
contains
!> Bind readonly control identities and the existing mutable surface owner.
!! CONTEXT is fresh TARGET storage and stays at its final address until release.
!! Its CMIP/TOZO/TERIP records are real scientific owners, not a reference fixture.
!! This metadata-only entry does not initialize scientific scalar values, create
!! a ready flag or claim that SUECRAD/UPDO3CH ran. Their actual native producers
!! must assign consumed values at the source stages before numerical use.
  integer(int32) function bind_time_and_forcing_context(context, arrays, catalog, lscmec, lrlxg, directory) result(status)
    type(native_time_and_forcing_context), target, intent(inout) :: context
    type(surface_field_state), target, intent(inout) :: arrays
    type(surface_field_registry), target, intent(in) :: catalog
    logical, target, intent(in) :: lscmec, lrlxg
    character(*), intent(in) :: directory
    status = 2
    if (associated(context%surface_arrays) .or. associated(context%surface_catalog)) return
    if (associated(context%lscmec) .or. associated(context%lrlxg)) return
    if (allocated(context%cmip%zozcl) .or. allocated(context%cmip%rsinc1) .or. allocated(context%cmip%rproc1)) return
    if (allocated(context%cmip%rlatcli) .or. allocated(context%cmip%rloncli) .or. allocated(context%cmip%rozt1)) return
if(allocated(context%ozone_chemistry%toz2dg).or.allocated(context%ozone_chemistry%toz2dl).or.allocated(context%ozone_chemistry%toz3dbl))return
    if (len_trim(directory) < 1 .or. len_trim(directory) > 480 .or. index(directory, achar(0)) /= 0) return
    context%surface_arrays => arrays; context%surface_catalog => catalog
    context%lscmec => lscmec; context%lrlxg => lrlxg
    context%data_directory = directory
    status = 0
  end function
!> Release only this context's nine scientific arrays and borrowed associations.
!! Radiation climate, aerosol and surface payloads retain their original owners.
!! Call this after every dependent physics/radiation user has released its views.
  integer(int32) function release_time_and_forcing_context(context) result(status)
    type(native_time_and_forcing_context), intent(inout) :: context
    if (allocated(context%ozone_chemistry%toz2dg)) deallocate (context%ozone_chemistry%toz2dg)
    if (allocated(context%ozone_chemistry%toz2dl)) deallocate (context%ozone_chemistry%toz2dl)
    if (allocated(context%ozone_chemistry%toz3dbl)) deallocate (context%ozone_chemistry%toz3dbl)
    if (allocated(context%cmip%zozcl)) deallocate (context%cmip%zozcl)
    if (allocated(context%cmip%rsinc1)) deallocate (context%cmip%rsinc1)
    if (allocated(context%cmip%rproc1)) deallocate (context%cmip%rproc1)
    if (allocated(context%cmip%rlatcli)) deallocate (context%cmip%rlatcli)
    if (allocated(context%cmip%rloncli)) deallocate (context%cmip%rloncli)
    if (allocated(context%cmip%rozt1)) deallocate (context%cmip%rozt1)
    nullify (context%surface_arrays, context%surface_catalog, context%lscmec, context%lrlxg)
    status = 0
  end function
end module
