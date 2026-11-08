!> Supply a stable separately compiled debugger stop on public metadata.
module forecast_weather_checkpoint_stop
  use iso_c_binding
  implicit none
  integer(c_int), save, volatile, bind(C, name='native_weather_checkpoint_ready_index') :: ready_index = -1
contains
  subroutine native_weather_checkpoint_ready(index, row_base, row_bytes, count, entry_errno, reply_address) bind(C)
    integer(c_int), value :: index, count, entry_errno
    integer(c_int64_t), value :: row_bytes
    type(c_ptr), value :: row_base, reply_address
    ! A volatile observation-only store keeps this compiler-generated call live.
    ready_index = index
  end subroutine
end module
