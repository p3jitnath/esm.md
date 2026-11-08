module forecast_parallel_interpolation_controls
  !! Own source parallel interpolation defaults and the first NAMPAR1 values.
  !! Counts have no units. Logical fields use the compiler's native interface.
  !! The first group is parsed completely before either output is published.
  use, intrinsic :: iso_fortran_env, only: int32
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_space, physics_key_character, physics_fold_equal, parse_physics_boolean
  use forecast_public_transform, only: native_transform_control
  implicit none
  private
  public :: parallel_interpolation_controls, first_parallel_namelist_values, serial_interpolation_controls
  public :: initialize_operational_interpolation_policy, read_operational_interpolation_policy
  public :: initialize_serial_interpolation_controls
  type :: parallel_interpolation_controls
    logical :: lsync_slcom = .false., lsldebug = .false., lslondem = .true., lsync_trans = .false.
    integer(int32) :: nslpad = 0
    logical :: ready = .false.
  end type
  type :: first_parallel_namelist_values
    !! present follows the eleven source keys listed below. A value is an
    !! actual parsed assignment only when its corresponding flag is true;
    !! zero/false in an absent field is not an inferred SUMP0 default.
    logical :: present(11) = .false.
    logical :: lsplit = .false., lslondem = .false., lsync_slcom = .false., lsldebug = .false.
    logical :: lsync_trans = .false., lsplitout = .false.
    integer(int32) :: nfldin = 0, nstrin = 0, nstrout = 0, nouttype = 0, nwrtout = 0
  end type
  type :: serial_interpolation_controls
    integer(int32) :: nproc = 0, n_regions_ns = 0, n_regions_ew = 0, nconf = 0, nslpad = 0
    logical :: lelam = .false., lsldebug = .false., ldcsetonly = .false.
  end type
  character(len=11), parameter :: keys(11) = [character(len=11) :: &
                                              'LSPLIT', 'NFLDIN', 'NSTRIN', 'NSTROUT', 'NOUTTYPE', 'LSLONDEM', 'NWRTOUT', &
                                              'LSYNC_SLCOM', 'LSLDEBUG', 'LSYNC_TRANS', 'LSPLITOUT']
  integer, parameter :: key_lengths(11) = [6, 6, 6, 7, 8, 8, 7, 11, 8, 11, 9]
contains
  integer(int32) function initialize_operational_interpolation_policy(text, output, admitted) result(status)
    !! text holds1..262144 source bytes. SUMP0 supplies policy defaults
    !! false,false,true,false and NSLPAD0; the first admitted group overrides
    !! the four policy fields. Return2 changes neither output. Return0 sets
    !! ready last after complete parsing; no allocation or model data is used.
    character(len=*), intent(in) :: text
    type(parallel_interpolation_controls), intent(inout) :: output
    type(first_parallel_namelist_values), intent(inout) :: admitted
    type(parallel_interpolation_controls) :: proposed
    type(first_parallel_namelist_values) :: parsed
    proposed = parallel_interpolation_controls()
    parsed = first_parallel_namelist_values()
    status = read_operational_interpolation_policy(text, proposed, parsed)
    if (status /= 0) return
    proposed%ready = .false.
    output = proposed
    admitted = parsed
    output%ready = .true.
  end function

  integer(int32) function read_operational_interpolation_policy(text, policy, admitted) result(status)
    !! Port the private first-group scanner through named native values.
    !! Preserve incoming policy fields without an assignment. Group markers
    !! are uppercase NAMPAR1 at the first nonblank token within10columns;
    !! key names and Boolean values are case insensitive. Integers are one
    !! digit0..4 with optional plus. Unknown keys and incomplete groups refuse
    !! atomically. Repeated keys in the first group use the last assignment.
    character(len=*), intent(in) :: text
    type(parallel_interpolation_controls), intent(inout) :: policy
    type(first_parallel_namelist_values), intent(inout) :: admitted
    type(parallel_interpolation_controls) :: proposed
    type(first_parallel_namelist_values) :: parsed
    integer :: cursor, first, last, row, key_index, code
    integer(int32) :: number
    logical :: boolean, valid
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    cursor = find_physics_group(text, 'NAMPAR1', .true.)
    if (cursor == 0) return
    proposed = policy
    parsed = first_parallel_namelist_values()
    do
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= len(text))
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      if (cursor > len(text)) return
      last = cursor - 1; key_index = 0
      do row = 1, 11
        if (last - first + 1 /= key_lengths(row)) cycle
        if (physics_fold_equal(text(first:last), keys(row) (1:key_lengths(row)))) then
          key_index = row
          exit
        end if
      end do
      if (key_index == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      first = cursor
      do while (cursor <= len(text))
        if (physics_space(text(cursor:cursor))) exit
        if (text(cursor:cursor) == ',' .or. text(cursor:cursor) == '!' .or. text(cursor:cursor) == '/') exit
        cursor = cursor + 1
      end do
      if (cursor > len(text)) return
      last = cursor - 1
      if (any(key_index == [1, 6, 8, 9, 10, 11])) then
        call parse_physics_boolean(text(first:last), boolean, valid)
        if (.not. valid) return
        select case (key_index)
        case (1)
          parsed%lsplit = boolean
        case (6)
          parsed%lslondem = boolean; proposed%lslondem = boolean
        case (8)
          parsed%lsync_slcom = boolean; proposed%lsync_slcom = boolean
        case (9)
          parsed%lsldebug = boolean; proposed%lsldebug = boolean
        case (10)
          parsed%lsync_trans = boolean; proposed%lsync_trans = boolean
        case (11)
          parsed%lsplitout = boolean
        end select
      else
        if (last - first + 1 == 2) then
          if (text(first:first) /= '+') return
          first = first + 1
        else if (last - first + 1 /= 1) then
          return
        end if
        code = iachar(text(first:first)) - 48
        if (code < 0 .or. code > 4) return
        number = int(code, int32)
        select case (key_index)
        case (2)
          parsed%nfldin = number
        case (3)
          parsed%nstrin = number
        case (4)
          parsed%nstrout = number
        case (5)
          parsed%nouttype = number
        case (7)
          parsed%nwrtout = number
        end select
      end if
      parsed%present(key_index) = .true.
    end do
    policy = proposed
    admitted = parsed
    status = 0
  end function

  integer(int32) function initialize_serial_interpolation_controls(output, transform, lelam, nconf, policy) result(status)
    !! Compose the selected serial SLCSET control inputs from actual owned
    !! transform region outputs and source LELAM/NCONF. NSLPAD/LSLDEBUG come
    !! from the completed first-NAMPAR1 producer. The original SUSC2B omits
    !! LDCSETONLY, so the local SLCSET default is false. No transform inquiry
    !! or numerical work runs here. Return2 leaves the output unchanged.
    type(serial_interpolation_controls), intent(inout) :: output
    type(native_transform_control), intent(in) :: transform
    logical, intent(in) :: lelam
    integer(int32), intent(in) :: nconf
    type(parallel_interpolation_controls), intent(in) :: policy
    type(serial_interpolation_controls) :: proposed
    status = 2
    if (transform%nproc /= 1 .or. transform%regions_ns /= 1 .or. transform%regions_ew /= 1) return
    if (lelam .or. nconf /= 1) return
    if (.not. policy%ready .or. policy%lsldebug .or. policy%nslpad /= 0) return
    proposed%nproc = transform%nproc
    proposed%n_regions_ns = transform%regions_ns; proposed%n_regions_ew = transform%regions_ew
    proposed%lelam = lelam; proposed%nconf = nconf
    proposed%lsldebug = policy%lsldebug; proposed%nslpad = policy%nslpad
    proposed%ldcsetonly = .false.
    output = proposed
    status = 0
  end function

end module forecast_parallel_interpolation_controls
