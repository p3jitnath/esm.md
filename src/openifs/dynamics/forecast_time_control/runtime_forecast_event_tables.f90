!> Own the twelve source output-event tables in one native allocation.
!! Event values and model-step indices are dimensionless. TSTEP is in seconds.
module forecast_runtime_event_tables
  use iso_fortran_env, only: int32, int64
  use forecast_model_clock_port, only: forecast_clock
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use forecast_operational_schedule, only: forecast_output_switches, forecast_stage_controls
  use forecast_periodic_output_schedule_port, only: select_periodic_output
  implicit none
  private
  public :: native_forecast_event_tables, initialize_runtime_forecast_events
  public :: release_runtime_forecast_events, runtime_event_selected
  public :: event_post, event_history, event_surface_history, event_grid_norm, event_spectral_norm
  public :: event_global_diagnostics, event_zonal_diagnostics, event_regional_diagnostics
  public :: event_diagnostic_print, event_restart, event_mass_check, event_fullpos
  integer, parameter :: event_post = 1, event_history = 2, event_surface_history = 3
  integer, parameter :: event_grid_norm = 4, event_spectral_norm = 5, event_global_diagnostics = 6
  integer, parameter :: event_zonal_diagnostics = 7, event_regional_diagnostics = 8, event_diagnostic_print = 9
  integer, parameter :: event_restart = 10, event_mass_check = 11, event_fullpos = 12

  !> STORAGE is the single owned integer allocation; no numerical field is copied.
  !! After publication, consumers borrow values without mutation. Row offsets are
  !! one-based positions in STORAGE, while each source schedule index starts0.
  !! Compiler descriptors replace the historical private descriptor byte image.
  type :: native_forecast_event_tables
    integer(int32), allocatable :: storage(:)
    integer(int64) :: byte_count = 0, row_start(12) = 0, row_count(12) = 0
    integer(int32) :: ready = 0, first_step = 0, last_step = 0, fullpos_present = 0, frequency(12) = 0
  end type
contains
  !> Construct every schedule privately, in original CNT4 call order.
  !!
  !! CONFIGURATION and CLOCK borrow the same actual model. MODEL supplies its
  !! source LMSE/LSDDH flags; this qualified route requires both false.
  !! SWITCHES is the complete source NAMCT1 result. RESTART_FREQUENCY is the
  !! actual loop NFRRES, and RESTART_REQUESTS starts with its source count word.
  !! Optional FULLPOS_FREQUENCY denotes actual Fullpos presence, including0.
  !! When nonzero, both Fullpos request arrays are required borrowed views.
  !! OUTPUT must be fresh: no allocation and ready0. All inputs are immutable
  !! and disjoint from this owner. BUDGET covers one allocation, in bytes.
  !!
  !! Status0 publishes all metadata and values. Status1 reports allocation
  !! failure. Status2 leaves OUTPUT unchanged after an unsupported input or
  !! child refusal. Acquired private work is released on every failed return.
  !! The caller qualifies exact default floating-point controls and agrees
  !! returned status across processes before reading a published table.
  integer(int32) function initialize_runtime_forecast_events(configuration, clock, model, switches, &
                                         restart_frequency, restart_requests, budget, output, fullpos_frequency, fullpos_requests, &
                                                             fullpos_minutes) result(status)
    type(native_forecast_control_namespace), intent(in) :: configuration
    type(forecast_clock), intent(in) :: clock
    type(forecast_stage_controls), intent(in) :: model
    type(forecast_output_switches), intent(in) :: switches
    integer(int32), intent(in) :: restart_frequency, restart_requests(:)
    integer(int64), intent(in) :: budget
    type(native_forecast_event_tables), intent(inout) :: output
    integer(int32), intent(in), optional :: fullpos_frequency, fullpos_requests(:), fullpos_minutes(:)
    type(native_forecast_event_tables) :: pending
    integer(int32) :: raw_frequency(12), values(12), all_switches(15), child_status, stop
    integer(int64) :: words, extent, position, finish
    integer :: row, code
    logical :: active, condition
    status = 2
    if (output%ready /= 0 .or. allocated(output%storage)) return
    if (budget < 1_int64 .or. budget > 2_int64**36) return
    if (configuration%nconf /= 1 .or. configuration%lelam /= 0) return
    if (clock%integration%first_step /= 0) return
    stop = clock%integration%total_steps
    if (stop < 0 .or. stop > 576) return
    if (model%lmse .or. model%lsddh) return
    all_switches = [switches%n1pos, switches%n1his, switches%n1sdi, switches%n1res, switches%n1sfxhis, &
                    switches%n1gdi, switches%n1dhp, switches%n1dhfg, switches%n1dhfz, switches%n1dhfd, &
                    switches%n1cfu, switches%n1xfu, switches%n1masscon, switches%lrfilaf, switches%lwrspec]
    if (any(all_switches < 0) .or. any(all_switches > 1)) return
    raw_frequency = [configuration%nfrpos, configuration%nfrhis, configuration%nfrsfxhis, &
                     configuration%nfrgdi, configuration%nfrsdi, configuration%nfrdhfg, configuration%nfrdhfz, &
                     configuration%nfrdhfd, configuration%nfrdhp, restart_frequency, configuration%nfrmasscon, 0_int32]
    if (present(fullpos_frequency)) then
      pending%fullpos_present = 1
      raw_frequency(12) = fullpos_frequency
    end if
    words = 0_int64
    do row = 1, 12
      pending%frequency(row) = raw_frequency(row)
      if (row == 4 .or. row == 5) pending%frequency(row) = max(1_int32, raw_frequency(row))
      if (row == 12 .and. raw_frequency(row) == 0) cycle
      if (pending%frequency(row) < 1 .or. pending%frequency(row) > 1000000) return
      extent = int(stop, int64)/int(pending%frequency(row), int64) + 1_int64
      if (words > huge(words) - extent) return
      pending%row_start(row) = words + 1_int64
      pending%row_count(row) = extent
      words = words + extent
    end do
    if (words > huge(words)/4_int64) return
    pending%byte_count = 4_int64*words
    if (pending%byte_count > budget) return
    if (pending%frequency(12) /= 0) then
      if (.not. present(fullpos_requests) .or. .not. present(fullpos_minutes)) return
    end if
    allocate (pending%storage(words), stat=code)
    if (code /= 0) then
      status = 1
      return
    end if
    pending%storage = 0
    pending%first_step = 0
    pending%last_step = stop
    values = [switches%n1pos, switches%n1his, switches%n1sfxhis, switches%n1gdi, switches%n1sdi, &
              1_int32, 1_int32, 1_int32, 1_int32, switches%n1res, switches%n1masscon, switches%n1pos]
    do row = 1, 12
      if (pending%row_count(row) == 0_int64) cycle
      position = pending%row_start(row)
      finish = position + pending%row_count(row) - 1_int64
      active = row /= 3 .and. (row < 6 .or. row > 9)
      condition = .true.
      if (row == 11) condition = raw_frequency(row) <= stop
      select case (row)
      case (1)
        call build(configuration%nposts, configuration%npostsmin)
      case (2)
        call build(configuration%nhists, configuration%nhistsmin)
      case (3)
        call build(configuration%nsfxhists, configuration%nsfxhistsmin)
      case (4)
        call build(configuration%ngdits)
      case (5)
        call build(configuration%nsdits)
      case (6)
        call build(configuration%ndhfgts)
      case (7)
        call build(configuration%ndhfzts)
      case (8)
        call build(configuration%ndhfdts)
      case (9)
        call build(configuration%ndhpts)
      case (10)
        call build(restart_requests)
      case (11)
        call build(configuration%nmasscons)
      case (12)
        call build(fullpos_requests, fullpos_minutes)
      end select
      if (child_status /= 0) then
        status = 2
        return
      end if
    end do
    call move_alloc(pending%storage, output%storage)
    output%byte_count = pending%byte_count
    output%row_start = pending%row_start
    output%row_count = pending%row_count
    output%first_step = pending%first_step
    output%last_step = pending%last_step
    output%fullpos_present = pending%fullpos_present
    output%frequency = pending%frequency
    output%ready = 1
    status = 0
  contains
    subroutine build(requests, minutes)
      integer(int32), intent(in) :: requests(:)
      integer(int32), intent(in), optional :: minutes(:)
      call select_periodic_output(0_int32, 0_int32, stop, clock%integration%first_dt, &
                                  pending%storage(position:finish), values(row), raw_frequency(row), requests, child_status, &
                                  minutes=minutes, condition=condition, active=active)
    end subroutine
  end function

  !> Read one event without changing the immutable owner or any clock value.
  !! ROW is1:12 and STEP lies in the constructed inclusive source interval.
  !! The absent optional Fullpos row is inactive. Refusal preserves SELECTED.
  integer(int32) function runtime_event_selected(owner, row, step, selected) result(status)
    type(native_forecast_event_tables), intent(in) :: owner
    integer, intent(in) :: row
    integer(int32), intent(in) :: step
    logical, intent(inout) :: selected
    integer(int64) :: index, position
    status = 2
    if (owner%ready /= 1 .or. .not. allocated(owner%storage)) return
    if (row < 1 .or. row > 12) return
    if (step < owner%first_step .or. step > owner%last_step) return
    if (owner%row_count(row) == 0) then
      selected = .false.; status = 0
      return
    end if
    if (owner%frequency(row) < 1) return
    index = int(step, int64)/int(owner%frequency(row), int64)
    if (index < 0_int64 .or. index >= owner%row_count(row)) return
    position = owner%row_start(row) + index
    if (position < 1_int64 .or. position > size(owner%storage, kind=int64)) return
    selected = owner%storage(position) == 1 .and. mod(step, owner%frequency(row)) == 0
    status = 0
  end function

  !> Release the one allocation and disconnect its rows; repeated release succeeds.
  !! Source schedule bounds, effective frequencies and presence remain recorded.
  integer(int32) function release_runtime_forecast_events(output) result(status)
    type(native_forecast_event_tables), intent(inout) :: output
    if (allocated(output%storage)) deallocate (output%storage)
    output%byte_count = 0_int64
    output%ready = 0
    output%row_start = 0_int64
    status = 0
  end function
end module forecast_runtime_event_tables
