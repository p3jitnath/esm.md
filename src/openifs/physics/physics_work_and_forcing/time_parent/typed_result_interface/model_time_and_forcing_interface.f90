!> Borrow the actual forecast owners for the complete time-update caller.
!! This file defines types and explicit procedure interfaces only. The declared
!! parent bodies are pending and must not receive a linked or source-count claim.
module forecast_model_time_and_forcing
  use iso_fortran_env, only: int32, real64
  use forecast_selected_model_storage, only: native_selected_model_storage
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry
  use yoecmip, only: TECMIP
  use yomozo, only: TOZO
  use yoerip, only: TERIP
  implicit none
  private
  public :: native_time_and_forcing_context, update_runtime_model_time_and_forcing, update_model_time_and_forcing
!> Keep one set of scientific records next to the forecast's existing clock.
!! The context itself must be TARGET and remain at its final address while setup
!! and timestep users borrow these records. CMIP is passed to the actual SUECRAD
!! default/parser stage; OZONE_CHEMISTRY is produced by the actual chemistry reader.
!! RADIATION_CLOCK contains the six distinct ECMWF radiation-angle outputs.
!! The only temporal model clock remains STORAGE%MODEL%INITIAL%CONTROLS%CLOCK.
!! SURFACE_ARRAYS and SURFACE_CATALOG borrow the same actual input/FIELDS owners.
!! Directory text is owned metadata, with no file handle or numerical payload.
!! Daily CLIMR storage stays in STORAGE%MODEL%CLIMATE. No ready flag is created.
  type native_time_and_forcing_context
    type(TECMIP) :: cmip
    type(TOZO) :: ozone_chemistry
    type(TERIP) :: radiation_clock
    type(surface_field_state), pointer :: surface_arrays => null()
    type(surface_field_registry), pointer :: surface_catalog => null()
    character(len=480) :: data_directory = ''
    logical, pointer :: lscmec => null(), lrlxg => null()
  end type
  interface
    !> Run the runtime source call order on real produced owners.
 !! STEP is the source KSTEP. TDT and TSTEP use seconds. The routine reads the
 !! caller's STEP and preserves clock%CURRENT_STEP; the owning loop updates that
 !! counter separately. Optional UPDATE_AEROSOL retains source presence semantics.
 module integer(int32)function update_runtime_model_time_and_forcing(storage,step,tdt,tstep,update_climate,context,update_aerosol)result(status)
    type(native_selected_model_storage), target, intent(inout) :: storage
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: tdt, tstep
    logical, intent(in) :: update_climate
    type(native_time_and_forcing_context), target, intent(inout) :: context
    logical, optional, intent(in) :: update_aerosol
    end function
    !> Retain the selected source route with the same explicit ownership.
 module integer(int32)function update_model_time_and_forcing(storage,step,tdt,tstep,update_climate,context,update_aerosol)result(status)
    type(native_selected_model_storage), target, intent(inout) :: storage
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: tdt, tstep
    logical, intent(in) :: update_climate
    type(native_time_and_forcing_context), target, intent(inout) :: context
    logical, optional, intent(in) :: update_aerosol
    end function
  end interface
end module
