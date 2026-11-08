!> Complete runtime UPDTIM using the actual daily-climate numerical child.
!! This draft has no object or linked-source credit until that child is frozen.
!! Each rank borrows the same supported configuration and enters source public
!! agreements in the same order. No payload, clock or ready-state copy is made.
submodule(forecast_model_time_and_forcing) forecast_runtime_model_time_forcing_body
  use forecast_model_time_forcing_core, only: run_time_forcing_prefix, finish_time_forcing_daily, agree_time_status
  use forecast_runtime_daily_climate, only: update_runtime_daily_climate
  implicit none
contains
  module function update_runtime_model_time_and_forcing(storage,step,tdt,tstep,update_climate,context,update_aerosol)result(status)
    type(native_selected_model_storage), target, intent(inout) :: storage
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: tdt, tstep
    logical, intent(in) :: update_climate
    type(native_time_and_forcing_context), target, intent(inout) :: context
    logical, optional, intent(in) :: update_aerosol
    integer(int32) :: status
    logical :: daily
    integer(int32) :: child
    status = run_time_forcing_prefix(storage, step, tdt, tstep, context, .true., daily)
    if (status /= 0) return
! Native LMCCEC/LDCLUPD retain the original daily conditional and call order.
    if (daily .and. storage%model%climate%lmccec .and. update_climate) then
      child = update_runtime_daily_climate(storage, step, tstep, context)
      if (child /= 0) then
        status = agree_time_status(storage, child)
        return
      end if
    end if
    status = finish_time_forcing_daily(storage, context, .true., daily)
  end function
end submodule
