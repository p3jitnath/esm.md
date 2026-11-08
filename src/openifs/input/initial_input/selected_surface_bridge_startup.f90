module forecast_selected_surface_startup
  !! Native SUGRIDG/SUGRIDF composition with explicit, caller-owned metadata.
  !! Old void entries stopped the process with116. Native status116 lets the
  !! enclosing distributed controller perform its declared collective cleanup.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use surface_input_configuration_port, only: surface_input_configuration
  use surface_field_storage_port, only: surface_field_state
  use partitioned_surface_field_placement_port, only: surface_input_owners
  use surface_default_metadata_port, only: surface_default_group_view, surface_default_plan_summary
  use surface_default_assignment_port, only: surface_default_owner, surface_default_assignment
  use forecast_live_surface_input_metadata, only: live_surface_conversion_values, surface_startup_context, &
                                    project_surface_startup_context, collect_selected_surface_defaults, set_initial_surface_defaults
  use forecast_selected_surface_context, only: project_selected_surface_initial_context
  use forecast_complete_initial_surface_loading, only: load_initial_surface_state
  implicit none
  private
  public :: sugridg, sugridf, surface_input_statistics
  public :: get_surface_input_statistics, get_surface_startup_statistics
  type :: surface_input_statistics
    !! Native named state replaces the historical machine-word counter block.
    !! IEEE state is language-owned; no old register encoding is claimed.
    integer(int64) :: revision = 1, entries = 0, completions = 0, failures = 0
    integer(int32) :: rejection = 0, incoming_errno = 0, outgoing_errno = 0
    type(ieee_status_type) :: incoming_ieee, outgoing_ieee
  end type
  type :: default_plan
    type(surface_default_owner) :: owners(64)
    type(surface_default_assignment) :: assignments(4096)
    type(surface_default_plan_summary) :: summary
  end type
  type(surface_input_statistics), save :: input_counts, startup_counts
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function sugridg(live, state, groups, pitch, points, snow_layers, nconf, lifstraj, l_oops, allocation_flag, &
                                  source_filename, kfile, reset_word, byte_limit) result(status)
    !! Source file is the first16 bytes of CFNIGG, right-trimmed, without NUL.
    !! Its initialized native producer supplies source_filename explicitly.
    !! The two unused old optional arrays are absent on this supported route.
    !! Reset the caller's integer word only after valid context and filename.
    !! Failed file loading retains the incoming owners; its physical conversion
    !! flags remain observable. All native exits retain the source errno.
    type(live_surface_conversion_values), intent(in) :: live
    type(surface_field_state), target, intent(inout) :: state
    type(surface_default_group_view), intent(in) :: groups(:)
    integer(int32), intent(in) :: pitch, points, snow_layers, nconf, lifstraj, l_oops, allocation_flag, kfile
    character(*), intent(in) :: source_filename
    integer(int32), intent(inout) :: reset_word
    integer(int64), intent(in) :: byte_limit
    type(surface_input_configuration) :: configuration
    type(surface_input_owners) :: owners
    integer(int32) :: parameters(52), child, reason
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: incoming, observed
    character(16) :: path
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    input_counts%entries = input_counts%entries + 1
    input_counts%incoming_errno = saved_errno; input_counts%incoming_ieee = incoming
    status = 116; reason = 101; observed = incoming
    if (kfile /= 0 .or. len(source_filename) < 16) goto900
    reason = 102
    child = project_selected_surface_initial_context(live, state, groups, pitch, points, snow_layers, nconf, lifstraj, l_oops, &
                                                     allocation_flag, configuration, owners, parameters)
    if (child /= 0) goto900
    reason = 101
    path = source_filename(1:16)
    if (index(path, achar(0)) /= 0 .or. len_trim(path) == 0) goto900
    call ieee_set_status(incoming); error_number = saved_errno
    reset_word = 0
    child = load_initial_surface_state(trim(path), configuration, owners, parameters, byte_limit)
    call ieee_get_status(observed)
    reason = 1000 + child
    if (child /= 0) goto900
    status = 0; reason = 0
    input_counts%completions = input_counts%completions + 1
900 if (status /= 0) input_counts%failures = input_counts%failures + 1
    input_counts%rejection = reason
    input_counts%outgoing_errno = saved_errno; input_counts%outgoing_ieee = observed
    call ieee_set_status(observed); error_number = saved_errno
  end function

  integer(int32) function sugridf(live, state, groups, ngribfile, n3dini, laqua, pitch, blocks, points, sd_vx_fields, &
       snow_layers,nconf,lifstraj,l_oops,allocation_flag,source_filename,kfile,reset_word,byte_limit,plan_byte_limit) result(status)
    !! Branch controls and all33 borrowed groups come from the canonical live
    !! caller. The selected route is24rows,86blocks,2048points and five snow
    !! layers. One checked private native plan is released on every return.
    !! The compiler owns its descriptor storage, so plan_byte_limit admits the
    !! actual native bytes rather than the old99,904-byte private record.
    !! Default assignments run before SUGRIDG. If input loading later fails,
    !! those source-required default writes remain published. There is no
    !! omitted default stage, original global or hidden numerical callback.
    type(live_surface_conversion_values), intent(in) :: live
    type(surface_field_state), target, intent(inout) :: state
    type(surface_default_group_view), intent(in) :: groups(:)
    integer(int32), intent(in) :: ngribfile, n3dini, laqua, pitch, blocks, points, sd_vx_fields, snow_layers
    integer(int32), intent(in) :: nconf, lifstraj, l_oops, allocation_flag, kfile
    character(*), intent(in) :: source_filename
    integer(int32), intent(inout) :: reset_word
    integer(int64), intent(in) :: byte_limit, plan_byte_limit
    integer(int64), parameter :: plan_bytes = int(storage_size(default_plan()), int64)/8
    type(default_plan), allocatable :: plan
    type(surface_startup_context) :: context
    type(ieee_status_type) :: incoming, observed
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno, observed_errno
    integer(int32) :: child, reason
    integer :: error, owner_count, assignment_count
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    startup_counts%entries = startup_counts%entries + 1
    startup_counts%incoming_errno = saved_errno; startup_counts%incoming_ieee = incoming
    status = 116; reason = 101; observed = incoming; observed_errno = saved_errno
    if (kfile /= 0) goto900
    reason = 102
    child = project_surface_startup_context(ngribfile, n3dini, laqua, pitch, blocks, points, sd_vx_fields, context)
    if (child /= 0) goto900
    reason = 103
    if (plan_byte_limit < plan_bytes) goto900
    allocate (plan, stat=error)
    if (error /= 0) goto900
    call collect_selected_surface_defaults(groups, plan%owners, plan%assignments, plan%summary)
    reason = 104
    if (plan%summary%status /= 0) goto900
    owner_count = int(plan%summary%owner_count); assignment_count = int(plan%summary%assignment_count)
    call ieee_set_status(incoming); error_number = saved_errno
    child = set_initial_surface_defaults(plan%owners(1:owner_count), plan%assignments(1:assignment_count))
    reason = 105
    if (child /= 0) goto900
    child = sugridg(live, state, groups, pitch, points, snow_layers, nconf, lifstraj, l_oops, allocation_flag, &
                    source_filename, kfile, reset_word, byte_limit)
    call ieee_get_status(observed); observed_errno = error_number
    reason = 1000 + child
    if (child /= 0) goto900
    status = 0; reason = 0
    startup_counts%completions = startup_counts%completions + 1
900 if (allocated(plan)) deallocate (plan)
    if (status /= 0) startup_counts%failures = startup_counts%failures + 1
    startup_counts%rejection = reason
    startup_counts%outgoing_errno = observed_errno; startup_counts%outgoing_ieee = observed
    call ieee_set_status(observed); error_number = observed_errno
  end function

  function get_surface_input_statistics() result(output)
    type(surface_input_statistics) :: output
    output = input_counts
  end function

  function get_surface_startup_statistics() result(output)
    type(surface_input_statistics) :: output
    output = startup_counts
  end function
end module forecast_selected_surface_startup
