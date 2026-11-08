!> Preserve original CALL_SL entry names through explicit native interfaces.
module forecast_transport_source_interfaces
  use iso_fortran_env, only: int32, int64
  use md2asm_native_call_sl, only: CALL_SL => advance_native_call_sl
  use md2asm_native_call_sl, only: runtime_call_sl => advance_native_call_sl
  use md2asm_semi_lagrangian_transport_stage, only: transport_stage_counts
  implicit none
  private
  public :: CALL_SL, runtime_call_sl, md2asm_call_sl_7358525, md2asm_runtime_semi_lagrangian_transport
  public :: call_sl_stage_count_get, runtime_call_sl_stage_count_get
  interface md2asm_call_sl_7358525
    procedure CALL_SL
  end interface
  interface md2asm_runtime_semi_lagrangian_transport
    procedure runtime_call_sl
  end interface
  interface runtime_call_sl_stage_count_get
    module procedure call_sl_stage_count_get
  end interface
contains
  !> Query actual source counters from the same caller-owned native context.
  !! index0:3 selects completed calls,polar fills,trajectory blocks and
  !! provisional field blocks. An outside index returns0. counts is produced and updated by
  !! the complete own transport stage;the caller supplies no calculated count.
  !! Explicit native ownership replaces the original process-global words.
  !! CALL_SL and runtime_call_sl have exactly the complete typed interface of
  !! advance_native_call_sl,including actual physical/control/owner inputs.
  !! No comparison driver,private record,original global or numerical stage
  !! is introduced by these source-name interfaces. Arithmetic bodies remain
  !! unchanged and are linked from their frozen object selectors.
  integer(int64) function call_sl_stage_count_get(counts, index) result(value)
    type(transport_stage_counts), intent(in) :: counts
    integer(int32), intent(in) :: index
    value = 0_int64
    select case (index)
    case (0); value = counts%completed_calls
    case (1); value = counts%polar_fills
    case (2); value = counts%trajectory_blocks
    case (3); value = counts%prognostic_blocks
    end select
  end function
end module forecast_transport_source_interfaces
