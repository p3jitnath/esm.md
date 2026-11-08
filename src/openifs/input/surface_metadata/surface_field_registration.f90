module surface_field_registration_port
  !! Construct named surface-field metadata in the generated source order.
  !! These entries change identifiers, names, defaults and index counts only.
  !! They allocate layer metadata but never supply a physical field value.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  private
  public :: surface_group_controls, surface_group_metadata, surface_field_metadata
  public :: surface_registration_plan, surface_trajectory_metadata, surface_field_totals
  public :: initialize_surface_group, define_surface_field_2d, define_layered_surface_field
  public :: release_layered_surface_field, finalize_surface_group
  type :: surface_group_controls
    integer(int32) :: rank = 0, layers = 0, multiple_state = 0, trajectory_start = 0, constant_start = 0
    integer(int32) :: undefined_index = -99999, field_capacity = 0
    character(16) :: name = ' '
  end type
  type :: surface_group_metadata
    integer(int32) :: registered_fields = 0, stored_fields = 0, layers = 0, next_field = 0
    integer(int32) :: unwritten_word = 0, trajectory_fields = 0, trajectory_start = 0, constant_start = 0
    character(16) :: name = ' '
    integer(int32) :: layered = 0, multiple_state = 0, finalized = 0
  end type
  type :: surface_field_metadata
    integer(int32) :: indices(4) = 0, trajectory_kind = 0, registration_index = 0, initialized = 0
    integer(int32) :: parameter = 0
    character(16) :: name = ' '
    real(real64) :: default_value = 0.0_real64
    integer(int32) :: source_flag = 0, unwritten_word = 0
    integer(int32), allocatable :: layer_parameters(:), layer_source_flags(:)
    character(16), allocatable :: layer_names(:)
    real(real64), allocatable :: layer_defaults(:)
  end type
  type :: surface_registration_plan
    integer(int32) :: presence_mask = 0, parameter = 0, trajectory_kind = 0, source_flag = 0
    real(real64) :: default_value = 0.0_real64
    character(16) :: name = ' '
    integer(int32), pointer, contiguous :: layer_parameters(:) => null(), layer_source_flags(:) => null()
    character(16), pointer, contiguous :: layer_names(:) => null()
    real(real64), pointer, contiguous :: layer_defaults(:) => null()
  end type
  type :: surface_trajectory_metadata
    integer(int32) :: dynamic_count = 0, constant_count = 0, parameters(100) = 0
  end type
  type :: surface_field_totals
    integer(int32) :: registered = 0, registered_levels = 0, stored = 0, stored_levels = 0, multiple = 0, multiple_levels = 0
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function initialize_surface_group(controls, group, fields) result(status)
    !! controls selects rank2 with layers-1, or rank3 with layers0..64/137.
    !! It supplies1..694 fields, logical0/1 and nonnegative trajectory starts.
    !! fields is a caller-owned array with at least field_capacity entries.
    !! Only source-written scalar members change. Layer arrays and all other
    !! incoming members remain untouched. Inputs and outputs are disjoint.
    !! Return2 before any write on refusal, otherwise0; no FP work occurs.
    type(surface_group_controls), intent(in) :: controls
    type(surface_group_metadata), intent(inout) :: group
    type(surface_field_metadata), intent(inout) :: fields(:)
    integer :: j
    status = 2
    if (controls%rank /= 2 .and. controls%rank /= 3) return
    if (controls%field_capacity < 1 .or. controls%field_capacity > 694) return
    if (controls%rank == 2) then
      if (controls%layers /= -1) return
    else
      if (controls%layers /= 137 .and. (controls%layers < 0 .or. controls%layers > 64)) return
    end if
    if (controls%multiple_state < 0 .or. controls%multiple_state > 1) return
    if (controls%trajectory_start < 0 .or. controls%constant_start < 0) return
    if (controls%undefined_index /= -99999 .and. controls%undefined_index /= -999999) return
    if (size(fields) < controls%field_capacity) return
    group%finalized = 0
    group%layers = controls%layers
    group%next_field = 1
    group%multiple_state = controls%multiple_state
    group%name = controls%name
    group%trajectory_fields = 0
    group%trajectory_start = controls%trajectory_start
    group%constant_start = controls%constant_start
    do j = 1, controls%field_capacity
      fields(j)%indices = controls%undefined_index
      fields(j)%trajectory_kind = 0
      fields(j)%registration_index = j
      fields(j)%initialized = 0
    end do
    status = 0
  end function
  integer(int32) function define_surface_field_2d(group, field, trajectory, plan) result(status)
    !! Register one named scalar field without allocation. presence_mask0..31
    !! selects parameter,name,default,trajectory and source-flag in bits0..4.
    !! trajectory_kind0..2 means no trajectory,dynamic,constant. The field's
    !! registration index must equal the group's next index1..693.
    !! Refusal2 changes no member; success0 advances the source counters.
    type(surface_group_metadata), intent(inout) :: group
    type(surface_field_metadata), intent(inout) :: field
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_registration_plan), intent(in) :: plan
    integer(int32) :: kind
    status = 2
    if (group%layers /= -1 .or. group%finalized /= 0) return
    if (group%next_field < 1 .or. group%next_field > 693) return
    if (field%registration_index /= group%next_field) return
    if (plan%presence_mask < 0 .or. plan%presence_mask > 31) return
    kind = 0
    if (btest(plan%presence_mask, 3)) then
      kind = plan%trajectory_kind
      if (kind < 0 .or. kind > 2) return
      if (group%trajectory_fields < 0 .or. group%trajectory_fields >= group%next_field) return
      if (kind == 1) then
        if (trajectory%dynamic_count < 0 .or. trajectory%dynamic_count >= 100) return
      else if (kind == 2) then
        if (trajectory%constant_count < 0 .or. trajectory%constant_count == huge(0_int32)) return
      end if
    end if
    field%parameter = -999
    if (btest(plan%presence_mask, 0)) field%parameter = plan%parameter
    field%source_flag = -1
    if (btest(plan%presence_mask, 4)) field%source_flag = plan%source_flag
    field%name = ' '
    if (btest(plan%presence_mask, 1)) field%name = plan%name
    field%default_value = 0.0_real64
    if (btest(plan%presence_mask, 2)) field%default_value = plan%default_value
    if (btest(plan%presence_mask, 3)) then
      if (kind == 1) then
        trajectory%parameters(trajectory%dynamic_count + 1) = field%parameter
        trajectory%dynamic_count = trajectory%dynamic_count + 1
      else if (kind == 2) then
        trajectory%constant_count = trajectory%constant_count + 1
      end if
      group%trajectory_fields = group%trajectory_fields + 1
    end if
    field%trajectory_kind = kind
    field%initialized = 1
    group%next_field = group%next_field + 1
    status = 0
  end function
  integer(int32) function define_layered_surface_field(group, field, trajectory, plan) result(status)
    !! Register one layered field with1..64 or137 layers. Four checked native
    !! owners are allocated in parameter/name/default/source-flag order.
    !! Optional plan arrays must contain every layer when its presence bit
    !! is set. Allocation failure1 frees all staged owners and publishes none.
    !! Admission refusal2 precedes allocation. Success0 moves all four owners
    !! and advances the same ordered trajectory counters. IEEE/errno remain
    !! unchanged. All plan arrays are readonly,disjoint and remain caller-owned.
    type(surface_group_metadata), intent(inout) :: group
    type(surface_field_metadata), intent(inout) :: field
    type(surface_trajectory_metadata), intent(inout) :: trajectory
    type(surface_registration_plan), intent(in) :: plan
    integer :: n, j, error
    integer(int32) :: kind
    integer(int32), allocatable :: parameters(:), source_flags(:)
    character(16), allocatable :: names(:)
    real(real64), allocatable :: defaults(:)
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: incoming
    status = 2; n = group%layers
    if (n /= 137 .and. (n < 1 .or. n > 64)) return
    if (group%finalized /= 0 .or. group%next_field < 1 .or. group%next_field > 693) return
    if (field%registration_index /= group%next_field) return
    if (allocated(field%layer_parameters) .or. allocated(field%layer_names)) return
    if (allocated(field%layer_defaults) .or. allocated(field%layer_source_flags)) return
    if (plan%presence_mask < 0 .or. plan%presence_mask > 31) return
    kind = 0
    if (btest(plan%presence_mask, 3)) then
      kind = plan%trajectory_kind
      if (kind < 0 .or. kind > 2) return
      if (group%trajectory_fields < 0 .or. group%trajectory_fields >= group%next_field) return
      if (kind == 1) then
        if (trajectory%dynamic_count < 0 .or. trajectory%dynamic_count > 100) return
        if (n > 100 - trajectory%dynamic_count) return
      else if (kind == 2) then
        if (trajectory%constant_count < 0) return
        if (int(trajectory%constant_count, int64) + n > huge(0_int32)) return
      end if
    end if
    if (btest(plan%presence_mask, 0)) then
      if (.not. associated(plan%layer_parameters)) return
      if (size(plan%layer_parameters) < n) return
    end if
    if (btest(plan%presence_mask, 1)) then
      if (.not. associated(plan%layer_names)) return
      if (size(plan%layer_names) < n) return
    end if
    if (btest(plan%presence_mask, 2)) then
      if (.not. associated(plan%layer_defaults)) return
      if (size(plan%layer_defaults) < n) return
    end if
    if (btest(plan%presence_mask, 4)) then
      if (.not. associated(plan%layer_source_flags)) return
      if (size(plan%layer_source_flags) < n) return
    end if
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    allocate (parameters(n), stat=error)
    if (error /= 0) goto900
    allocate (names(n), stat=error)
    if (error /= 0) goto900
    allocate (defaults(n), stat=error)
    if (error /= 0) goto900
    allocate (source_flags(n), stat=error)
    if (error /= 0) goto900
    parameters = -999
    if (btest(plan%presence_mask, 0)) parameters = plan%layer_parameters(1:n)
    names = ' '
    if (btest(plan%presence_mask, 1)) names = plan%layer_names(1:n)
    defaults = 0.0_real64
    if (btest(plan%presence_mask, 2)) defaults = plan%layer_defaults(1:n)
    source_flags = -1
    if (btest(plan%presence_mask, 4)) source_flags = plan%layer_source_flags(1:n)
    call move_alloc(parameters, field%layer_parameters)
    call move_alloc(names, field%layer_names)
    call move_alloc(defaults, field%layer_defaults)
    call move_alloc(source_flags, field%layer_source_flags)
    if (btest(plan%presence_mask, 3)) then
      if (kind == 1) then
        do j = 1, n
          trajectory%parameters(trajectory%dynamic_count + j) = field%layer_parameters(j)
        end do
        trajectory%dynamic_count = trajectory%dynamic_count + n
      else if (kind == 2) then
        trajectory%constant_count = trajectory%constant_count + n
      end if
      group%trajectory_fields = group%trajectory_fields + 1
    end if
    field%trajectory_kind = kind
    field%initialized = 1
    group%next_field = group%next_field + 1
    status = 0
    goto910
900 if (allocated(parameters)) deallocate (parameters)
    if (allocated(names)) deallocate (names)
    if (allocated(defaults)) deallocate (defaults)
    if (allocated(source_flags)) deallocate (source_flags)
    status = 1
910 call ieee_set_status(incoming)
    error_number = saved_errno
  end function
  integer(int32) function release_layered_surface_field(field) result(status)
    !! Release four layer owners in source order and preserve scalar members.
    !! Repeated release frees none and returns0. All borrowed layer views expire.
    type(surface_field_metadata), intent(inout) :: field
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: incoming
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (allocated(field%layer_parameters)) deallocate (field%layer_parameters)
    if (allocated(field%layer_names)) deallocate (field%layer_names)
    if (allocated(field%layer_defaults)) deallocate (field%layer_defaults)
    if (allocated(field%layer_source_flags)) deallocate (field%layer_source_flags)
    call ieee_set_status(incoming)
    error_number = saved_errno
    status = 0
  end function
  integer(int32) function finalize_surface_group(group, fields, totals, two_time_levels, undefined_index) result(status)
    !! Finish registered metadata and add six int32 totals atomically.
    !! two_time_levels is0/1; undefined_index is-99999/-999999. fields contains
    !! the complete ordered registered prefix. No physical array is changed.
    !! The source-written index maps cover one,two or three stored states.
    !! Return2 before mutation for shape,sequence or count overflow; else0.
    type(surface_group_metadata), intent(inout) :: group
    type(surface_field_metadata), intent(inout) :: fields(:)
    type(surface_field_totals), intent(inout) :: totals
    integer(int32), intent(in) :: two_time_levels, undefined_index
    integer :: n, levels, j, multiplier, nmultiple
    integer(int64) :: increments(6), old(6)
    status = 2
    if (group%next_field < 1 .or. group%next_field > 694 .or. group%finalized /= 0) return
    n = group%next_field - 1
    levels = group%layers
    if (levels == -1) then
      if (group%layered /= 0) return
      levels = 1
    else
      if (levels /= 137 .and. (levels < 0 .or. levels > 64)) return
      if (group%layered /= 1) return
    end if
    if (size(fields) < n) return
    if (group%multiple_state < 0 .or. group%multiple_state > 1) return
    if (two_time_levels < 0 .or. two_time_levels > 1) return
    if (undefined_index /= -99999 .and. undefined_index /= -999999) return
    do j = 1, n
      if (fields(j)%registration_index /= j .or. fields(j)%initialized /= 1) return
    end do
    multiplier = 1; nmultiple = 0
    if (group%multiple_state /= 0) then
      multiplier = 3 - two_time_levels
      nmultiple = n
    end if
    increments = [int(n, int64), int(n, int64)*levels, int(n, int64)*multiplier, &
                  int(n, int64)*multiplier*levels, int(nmultiple, int64), int(nmultiple, int64)*levels]
    old = [int(totals%registered, int64), int(totals%registered_levels, int64), &
           int(totals%stored, int64), int(totals%stored_levels, int64), &
           int(totals%multiple, int64), int(totals%multiple_levels, int64)]
    if (any(old < 0) .or. any(old + increments > huge(0_int32))) return
    group%registered_fields = n
    group%stored_fields = n*multiplier
    group%finalized = 1
    old = old + increments
    totals%registered = int(old(1), int32); totals%registered_levels = int(old(2), int32)
    totals%stored = int(old(3), int32); totals%stored_levels = int(old(4), int32)
    totals%multiple = int(old(5), int32); totals%multiple_levels = int(old(6), int32)
    do j = 1, n
      fields(j)%indices(1) = j
      if (group%multiple_state == 0) then
        fields(j)%indices(2:4) = undefined_index
      else
        fields(j)%indices(2) = j
        fields(j)%indices(3) = j
        fields(j)%indices(4) = j + n
        if (two_time_levels == 0) then
          fields(j)%indices(3) = j + n
          fields(j)%indices(4) = j + 2*n
        end if
      end if
    end do
    status = 0
  end function
end module
