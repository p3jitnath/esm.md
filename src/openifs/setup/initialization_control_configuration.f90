!> Own selected initialization switches and the admitted variational controls.
module forecast_initialization_controls
  use iso_c_binding, only: c_int32_t
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_key_character, physics_space, physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: native_initialization_controls, owned_initialization_controls
  public :: initialize_selected_initialization_controls
  public :: initialize_operational_initialization_controls
  public :: initialize_owned_initialization_controls, initialization_controls_ready
  !> Native int32 switches use0 for false and1 for true.
  !! Six named values are the selected producer's complete result. The
  !! remaining four variational flags belong to the operational
  !! extension. Their bytes remain unchanged on the selected route.
  type, bind(C) :: native_initialization_controls
    integer(c_int32_t) :: ldfi = 0, lbias = 0, lincr = 0, liniter = 0, lscrini = 0, ljcdfi = 0
    integer(c_int32_t) :: lmoderr = 0, lusejcdfi = 0, lecv = 0, ljc = 0
  end type
  type(native_initialization_controls), save, protected :: owned_initialization_controls
  logical, save :: published = .false.
contains
  !> Initialize the selected five SUINI flags and the selected LJCDFI flag.
  !! text has1..262144 bytes and contains empty first NAMINI/NAMVAR groups.
  !! NCONF must be1. Output changes only after both groups pass. The remaining
  !! four variational words and all input text retain their incoming bytes.
  !! Status0 succeeds;2 refuses. No allocation or floating operation occurs.
  integer(c_int32_t) function initialize_selected_initialization_controls(text, nconf, output) result(status)
    character(*), intent(in) :: text
    integer(c_int32_t), intent(in) :: nconf
    type(native_initialization_controls), intent(inout) :: output
    status = 2
    if (nconf /= 1) return
    if (require_empty_physics_group(text, 'NAMINI') /= 0) return
    if (require_empty_physics_group(text, 'NAMVAR') /= 0) return
    output%ldfi = 0; output%lbias = 0; output%lincr = 0
    output%liniter = 0; output%lscrini = 0; output%ljcdfi = 0
    status = 0
  end function

  !> Admit the operational NAMVAR keys with the existing false values.
  !! Use the accepted bounded text helpers and the first exact uppercase
  !! group marker within its first ten columns. Key/value case is ignored.
  !! The source logical syntax is TRUE/FALSE with optional surrounding dots.
  !! Repeated fields retain their last value; all four final values must be false.
  !! Empty groups pass. Unknown keys, incomplete tokens and true values refuse.
  logical function operational_variational_group_admitted(text) result(admitted)
    character(*), intent(in) :: text
    character(9), parameter :: keys(4) = [character(9) :: 'LMODERR', 'LJCDFI', 'LUSEJCDFI', 'LECV']
    integer, parameter :: key_lengths(4) = [7, 6, 9, 4]
    integer(c_int32_t) :: values(4)
    integer :: cursor, first, last, n, j, which
    logical :: found, value, valid
    admitted = .false.
    cursor = find_physics_group(text, 'NAMVAR', .false.)
    if (cursor == 0) return
    n = len(text)
    values = 0
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        admitted = all(values == 0)
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .false.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      found = .false.; which = 0
      do j = 1, size(keys)
        if (physics_fold_equal(text(first:last), keys(j) (1:key_lengths(j)))) then
          found = .true.; which = j
        end if
      end do
      if (.not. found) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor))) exit
        if (index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (cursor > n .or. last < first) return
      select case (last - first + 1)
      case (4, 5)
        if (text(first:first) == '.') return
      case (6, 7)
        if (text(first:first) /= '.' .or. text(last:last) /= '.') return
      case default
        return
      end select
      call parse_physics_boolean(text(first:last), value, valid)
      if (.not. valid) return
      values(which) = 0
      if (value) values(which) = 1
    end do
  end function

  !> Publish the complete operational zero-valued initialization record.
  !! NAMINI is empty and NAMVAR uses only the admitted four false keys.
  !! All ten source flags are assigned only
  !! after complete admission. Status0 succeeds;2 preserves all output bytes.
  integer(c_int32_t) function initialize_operational_initialization_controls(text, nconf, output) result(status)
    character(*), intent(in) :: text
    integer(c_int32_t), intent(in) :: nconf
    type(native_initialization_controls), intent(inout) :: output
    status = 2
    if (nconf /= 1) return
    if (require_empty_physics_group(text, 'NAMINI') /= 0) return
    if (.not. operational_variational_group_admitted(text)) return
    output%ldfi = 0; output%lbias = 0; output%lincr = 0
    output%liniter = 0; output%lscrini = 0; output%ljcdfi = 0
    output%lmoderr = 0; output%lusejcdfi = 0; output%lecv = 0; output%ljc = 0
    status = 0
  end function

  !> Produce the native owned namespace before forecast consumers read it.
  !! The same canonical named record is shared by the two supported routes.
  !! A refusal preserves its incoming state and publication flag.
  integer(c_int32_t) function initialize_owned_initialization_controls(text, nconf, operational) result(status)
    character(*), intent(in) :: text
    integer(c_int32_t), intent(in) :: nconf
    logical, intent(in) :: operational
    if (operational) then
      status = initialize_operational_initialization_controls(text, nconf, owned_initialization_controls)
    else
      status = initialize_selected_initialization_controls(text, nconf, owned_initialization_controls)
    end if
    if (status == 0) published = .true.
  end function
  !> Report publication without changing the namespace or machine status.
  pure logical function initialization_controls_ready() result(ready)
    ready = published
  end function
end module forecast_initialization_controls
