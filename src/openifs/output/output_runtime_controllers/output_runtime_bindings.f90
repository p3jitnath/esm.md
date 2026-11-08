!> Own the selected GRIB scalar namespace and borrow one Fullpos control owner.
module forecast_output_runtime_bindings
  use iso_fortran_env, only: int32, int64
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_space, physics_key_character, physics_fold_equal
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use forecast_output_request_preparation, only: native_output_common_metadata
  implicit none
  private
  public :: native_output_metadata_namespace, initialize_selected_output_metadata
  public :: bind_fullpos_runtime_controls
  !> Source-named dimensionless controls; NCYCLE retains its incoming value.
  !! Source declaration initialization gives NCYCLE=-100 for a fresh owner.
  !! All other named fields are replaced only after all three groups pass.
  type :: native_output_metadata_namespace
    integer(int32) :: nlocgrb, nensfnb, ntotens, nwinoff, nwinoff_4v, nstream
    integer(int32) :: nsystem, nmethod, nreference, nconsensus, ndwd, nmfr, nncep, nukm
    integer(int32) :: nbitssh, nbitsshlnsp, nbitsexpr, njdiag, njdomai, njiter, nleg
    integer(int32) :: ncycle = -100
    character(2) :: cfclass, ctype
    integer(int32) :: lforcez, lforcelnsp, linc, ntimefmt, lrsacc
  end type
contains
  !> Read the first NAMGRIB group, retaining the final NCYCLE assignment.
  !! This source accepts signed decimal integers in -99999999:99999999.
  !! Group names are uppercase; key names ignore ASCII case. Line comments
  !! begin with an exclamation mark. Commas may separate assignments.
  integer(int32) function parse_cycle(text, value) result(status)
    character(*), intent(in) :: text
    integer(int32), intent(inout) :: value
    integer :: cursor, first, last, i, digit, sign
    integer(int64) :: magnitude
    status = 2
    cursor = find_physics_group(text, 'NAMGRIB', .false.)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        status = 0
        return
      end if
      first = cursor
      do while (cursor <= len(text))
        if (.not. physics_key_character(text(cursor:cursor), .true.) .and. &
            text(cursor:cursor) /= '(' .and. text(cursor:cursor) /= ')') exit
        cursor = cursor + 1
      end do
      if (.not. physics_fold_equal(text(first:cursor - 1), 'NCYCLE')) return
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      first = cursor
      do while (cursor <= len(text))
        if (physics_space(text(cursor:cursor)) .or. index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (cursor > len(text) .or. cursor == first) return
      last = cursor - 1
      sign = 1
      if (text(first:first) == '-') then
        sign = -1
        first = first + 1
      else if (text(first:first) == '+') then
        first = first + 1
      end if
      if (first > last) return
      magnitude = 0
      do i = first, last
        digit = iachar(text(i:i)) - 48
        if (digit < 0 .or. digit > 9) return
        magnitude = magnitude*10_int64 + digit
        if (magnitude > 99999999_int64) return
      end do
      value = int(sign*magnitude, int32)
    end do
  end function

  !> Atomically publish all named selected metadata after parsing.
  !! text contains1:262144 bytes. configuration and lecmwf are source flags1.
  !! NAMOPH and NAMPPC must each be present and empty under the accepted
  !! source reader. Output is unchanged for every returned refusal.
  integer(int32) function initialize_selected_output_metadata(text, configuration, lecmwf, output) result(status)
    character(*), intent(in) :: text
    integer(int32), intent(in) :: configuration, lecmwf
    type(native_output_metadata_namespace), intent(inout) :: output
    type(native_output_metadata_namespace) :: staged
    status = 2
    if (len(text) < 1 .or. len(text) > 262144 .or. configuration /= 1 .or. lecmwf /= 1) return
    staged%nlocgrb = 1; staged%nensfnb = 0; staged%ntotens = 0
    staged%nwinoff = 0; staged%nwinoff_4v = 0; staged%nstream = 0
    staged%nsystem = 0; staged%nmethod = 1; staged%nreference = 20000101
    staged%nconsensus = 0; staged%ndwd = 0; staged%nmfr = 0; staged%nncep = 0; staged%nukm = 0
    staged%nbitssh = 16; staged%nbitsshlnsp = 16; staged%nbitsexpr = -1
    staged%njdiag = 99; staged%njdomai = 99; staged%njiter = 0; staged%nleg = 1
    staged%ncycle = output%ncycle
    staged%cfclass = 'rd'; staged%ctype = 'fc'
    staged%lforcez = 1; staged%lforcelnsp = 1; staged%linc = 0; staged%ntimefmt = 0; staged%lrsacc = 0
    status = parse_cycle(text, staged%ncycle)
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMOPH')
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMPPC')
    if (status /= 0) return
    staged%nstream = 1025
    output = staged
  end function

  !> Copy the complete named controls into the existing canonical owner.
  !! Compiler-owned padding replaces the former private48-byte encoding.
  !! Both objects have the same native type; no hidden global alias exists.
  integer(int32) function bind_fullpos_runtime_controls(input, output) result(status)
    type(native_output_common_metadata), intent(in) :: input
    type(native_output_common_metadata), intent(inout) :: output
    output = input
    status = 0
  end function
end module
