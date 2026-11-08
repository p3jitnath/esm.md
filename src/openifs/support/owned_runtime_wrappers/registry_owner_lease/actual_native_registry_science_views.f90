!> Borrow the genuine EC physics and radiation owners for registration.
!! This isolates the unchanged existing metadata binding from unrelated types.
module forecast_actual_native_registry_science_views
  use iso_fortran_env, only: int32
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_native_field_variable_types, only: native_registry_ecphysics_inputs, native_registry_radiation_inputs
  implicit none
  private
  public :: bind_native_registry_science_inputs
contains
  integer(int32) function bind_native_registry_science_inputs(startup, ecphysics, radiation) result(status)
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_registry_ecphysics_inputs), intent(inout) :: ecphysics
    type(native_registry_radiation_inputs), intent(inout) :: radiation
    status = 2_int32
    if (.not. associated(startup%loaded%fields)) return
    if (.not. allocated(startup%loaded%storage)) return
    associate (fields => startup%loaded%fields%ecphysics, flux => startup%loaded%storage%ecmwf%radiation%fluxes)
      if (.not. allocated(fields%rustrti) .or. .not. allocated(fields%rvstrti)) return
      if (.not. allocated(fields%rahfsti) .or. .not. allocated(fields%revapti) .or. .not. allocated(fields%rtskti)) return
      ecphysics%ustrti => fields%rustrti
      ecphysics%vstrti => fields%rvstrti
      ecphysics%ahfsti => fields%rahfsti
      ecphysics%evapti => fields%revapti
      ecphysics%tskti => fields%rtskti
      nullify (radiation%emtd)
      if (allocated(flux%emtd)) radiation%emtd => flux%emtd
      nullify (radiation%trsw)
      if (allocated(flux%trsw)) radiation%trsw => flux%trsw
      nullify (radiation%emtc)
      if (allocated(flux%emtc)) radiation%emtc => flux%emtc
      nullify (radiation%trsc)
      if (allocated(flux%trsc)) radiation%trsc => flux%trsc
      nullify (radiation%emtu)
      if (allocated(flux%emtu)) radiation%emtu => flux%emtu
      nullify (radiation%tauaer)
      if (allocated(flux%tauaer)) radiation%tauaer => flux%tauaer
      nullify (radiation%srswd)
      if (allocated(flux%srswd)) radiation%srswd => flux%srswd
      nullify (radiation%srlwdc)
      if (allocated(flux%srlwdc)) radiation%srlwdc => flux%srlwdc
      nullify (radiation%srlwd)
      if (allocated(flux%srlwd)) radiation%srlwd => flux%srlwd
      nullify (radiation%srswdc)
      if (allocated(flux%srswdc)) radiation%srswdc => flux%srswdc
      nullify (radiation%srswdcs)
      if (allocated(flux%srswdcs)) radiation%srswdcs => flux%srswdcs
      nullify (radiation%srlwdcs)
      if (allocated(flux%srlwdcs)) radiation%srlwdcs => flux%srlwdcs
      nullify (radiation%srswdv)
      if (allocated(flux%srswdv)) radiation%srswdv => flux%srswdv
      nullify (radiation%srswduv)
      if (allocated(flux%srswduv)) radiation%srswduv => flux%srswduv
      nullify (radiation%edro)
      if (allocated(flux%edro)) radiation%edro => flux%edro
      nullify (radiation%srswpar)
      if (allocated(flux%srswpar)) radiation%srswpar => flux%srswpar
      nullify (radiation%srswuvb)
      if (allocated(flux%srswuvb)) radiation%srswuvb => flux%srswuvb
      nullify (radiation%srswparc)
      if (allocated(flux%srswparc)) radiation%srswparc => flux%srswparc
      nullify (radiation%srswtinc)
      if (allocated(flux%srswtinc)) radiation%srswtinc => flux%srswtinc
      nullify (radiation%srfdir)
      if (allocated(flux%srfdir)) radiation%srfdir => flux%srfdir
      nullify (radiation%srcdir)
      if (allocated(flux%srcdir)) radiation%srcdir => flux%srcdir
      nullify (radiation%rmoon)
      if (allocated(flux%rmoon)) radiation%rmoon => flux%rmoon
      nullify (radiation%derivativelw)
      if (associated(flux%derivativelw)) radiation%derivativelw => flux%derivativelw
    end associate
    status = 0_int32
  end function
end module forecast_actual_native_registry_science_views
