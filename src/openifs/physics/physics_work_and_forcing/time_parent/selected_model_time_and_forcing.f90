!> Complete the selected UPDTIM source specialization on actual native owners.
!! The selected admission has LMCCEC=false and LEO3CH=false. Those branches
!! therefore perform no daily climate or chemistry calculation in this route.
submodule(forecast_model_time_and_forcing) forecast_selected_model_time_forcing_body
  use forecast_model_time_forcing_core, only: run_time_forcing_prefix, finish_time_forcing_daily
  implicit none
contains
  module function update_model_time_and_forcing(storage, step, tdt, tstep, update_climate, context, update_aerosol) result(status)
    type(native_selected_model_storage), target, intent(inout) :: storage
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: tdt, tstep
    logical, intent(in) :: update_climate
    type(native_time_and_forcing_context), target, intent(inout) :: context
    logical, optional, intent(in) :: update_aerosol
    integer(int32) :: status
    logical :: daily
    status = run_time_forcing_prefix(storage, step, tdt, tstep, context, .false., daily)
    if (status /= 0) return
    status = finish_time_forcing_daily(storage, context, .false., daily)
  end function
end submodule
