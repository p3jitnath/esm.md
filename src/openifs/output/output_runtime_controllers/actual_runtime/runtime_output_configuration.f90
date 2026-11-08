!> Own parsed runtime output configuration and borrow its canonical metadata.
module forecast_runtime_output_configuration
  use iso_fortran_env, only: int32, int64
  use forecast_output_namelist, only: native_runtime_output_namelist, parse_runtime_output_namfpc
  use forecast_output_runtime_bindings, only: native_output_metadata_namespace
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_space, physics_key_character, physics_fold_equal, parse_physics_boolean
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_runtime_output_configuration, initialize_runtime_output_configuration
  public :: borrow_runtime_physical_output_requests
  !> One persistent configuration owner. Counts/codes are the actual parsed input.
  !! metadata points to the existing canonical output scalar owner.
  type :: native_runtime_output_configuration
    type(native_runtime_output_namelist) :: namfpc
    type(native_output_metadata_namespace), pointer :: metadata => null()
    logical :: ready = .false.
  end type
contains
  !> Parse the first NAMGRIB/NAMOPH/NAMPPC/NAMFPC groups before publication.
  !! text is1:262144 characters. Configuration/ECMWF source flags equal1.
  !! CFCLASS has two characters; NCYCLE is signed decimal within99999999.
  !! NAMPPC accepts LRSACC with the accepted Fortran logical token grammar.
  !! Repeated assignments retain the final value in the first group.
  !! Returned status2 leaves both caller owners unchanged.
  integer(int32) function initialize_runtime_output_configuration(text, configuration, lecmwf, state, metadata) result(status)
    character(*), intent(in) :: text
    integer(int32), intent(in) :: configuration, lecmwf
    type(native_runtime_output_configuration), target, intent(inout) :: state
    type(native_output_metadata_namespace), target, intent(inout) :: metadata
    type(native_runtime_output_namelist) :: parsed
    type(native_output_metadata_namespace) :: staged
    status = 2
    if (len(text) < 1 .or. len(text) > 262144 .or. configuration /= 1 .or. lecmwf /= 1) return
    if (state%ready .or. associated(state%metadata)) return
    staged%nlocgrb = 1; staged%nensfnb = 0; staged%ntotens = 0
    staged%nwinoff = 0; staged%nwinoff_4v = 0; staged%nstream = 0
    staged%nsystem = 0; staged%nmethod = 1; staged%nreference = 20000101
    staged%nconsensus = 0; staged%ndwd = 0; staged%nmfr = 0; staged%nncep = 0; staged%nukm = 0
    staged%nbitssh = 16; staged%nbitsshlnsp = 16; staged%nbitsexpr = -1
    staged%njdiag = 99; staged%njdomai = 99; staged%njiter = 0; staged%nleg = 1
    staged%ncycle = metadata%ncycle
    staged%cfclass = 'rd'; staged%ctype = 'fc'
    staged%lforcez = 1; staged%lforcelnsp = 1; staged%linc = 0; staged%ntimefmt = 0; staged%lrsacc = 0
    status = parse_runtime_grib_group(text, staged)
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMOPH')
    if (status /= 0) return
    status = parse_runtime_ppc_group(text, staged%lrsacc)
    if (status /= 0) return
    status = parse_runtime_output_namfpc(text, parsed)
    if (status /= 0) return
    staged%nstream = 1025
    metadata = staged
    state%namfpc = parsed
    state%metadata => metadata
    state%ready = .true.
    status = 0
  end function

  integer(int32) function parse_runtime_grib_group(text, metadata) result(status)
    character(*), intent(in) :: text
    type(native_output_metadata_namespace), intent(inout) :: metadata
    integer :: cursor, first, last, sign, digit, j
    integer(int64) :: magnitude
    character :: quote
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
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= len(text))
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (physics_fold_equal(text(first:last), 'CFCLASS')) then
        quote = text(cursor:cursor)
        if (quote /= "'" .and. quote /= '"') return
        if (cursor + 3 > len(text)) return
        if (text(cursor + 3:cursor + 3) /= quote) return
        metadata%cfclass = text(cursor + 1:cursor + 2)
        cursor = cursor + 4
        if (cursor > len(text)) return
        if (.not. physics_space(text(cursor:cursor)) .and. index(',!/', text(cursor:cursor)) == 0) return
      elseif (physics_fold_equal(text(first:last), 'NCYCLE')) then
        first = cursor
        do while (cursor <= len(text))
          if (physics_space(text(cursor:cursor)) .or. index(',!/', text(cursor:cursor)) /= 0) exit
          cursor = cursor + 1
        end do
        if (cursor > len(text) .or. cursor == first) return
        last = cursor - 1
        sign = 1
        if (text(first:first) == '-') then
          sign = -1; first = first + 1
        elseif (text(first:first) == '+') then
          first = first + 1
        end if
        if (first > last) return
        magnitude = 0
        do j = first, last
          digit = iachar(text(j:j)) - 48
          if (digit < 0 .or. digit > 9) return
          magnitude = magnitude*10_int64 + digit
          if (magnitude > 99999999_int64) return
        end do
        metadata%ncycle = int(sign*magnitude, int32)
      else
        return
      end if
    end do
    status = 0
  end function

  integer(int32) function parse_runtime_ppc_group(text, lrsacc) result(status)
    character(*), intent(in) :: text
    integer(int32), intent(inout) :: lrsacc
    integer :: cursor, first, last
    logical :: value, ok
    status = 2
    cursor = find_physics_group(text, 'NAMPPC', .false.)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1; cycle
      end if
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= len(text))
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (.not. physics_fold_equal(text(first:last), 'LRSACC')) return
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
      call parse_physics_boolean(text(first:cursor - 1), value, ok)
      if (.not. ok) return
      lrsacc = merge(1_int32, 0_int32, value)
    end do
    status = 0
  end function

  !> Return readonly views of the persistent requested physical codes and flag.
  !! The caller keeps STATE and its borrowed metadata at stable addresses.
  !! Views expire before either owner is changed or released. No copy is made.
  integer(int32) function borrow_runtime_physical_output_requests(state, nfpphy, mfpphy, lrsacc) result(status)
    type(native_runtime_output_configuration), target, intent(in) :: state
    integer(int32), pointer, intent(out) :: nfpphy, mfpphy(:), lrsacc
    nullify (nfpphy, mfpphy, lrsacc)
    status = 2
    if (.not. state%ready .or. .not. associated(state%metadata)) return
    if (state%namfpc%field_count(9) < 0 .or. state%namfpc%field_count(9) > size(state%namfpc%field_code, 1)) return
    nfpphy => state%namfpc%field_count(9)
    mfpphy => state%namfpc%field_code(1:state%namfpc%field_count(9), 9)
    lrsacc => state%metadata%lrsacc
    status = 0
  end function
end module
