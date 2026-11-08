!> Produce the selected physics and spectral field dimensions.
!! A field stores one model variable across a grid. All counts are unitless.
!! These native SUDIMF1 and SUDIMF2 replacements preserve the generated
!! field_dimension_setup.S decisions. The compiler owns record layout and ABI.
!! The caller establishes nearest-even rounding and gradual underflow once.
!! This child preserves natural flags and makes no FP-mode refusal claim.
module physics_field_dimensions_port
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_loc, c_intptr_t
  use yomdimf, only: tdimf
  use yomdphy, only: tdphy
  use yomdyna, only: tdyna
  use yoephy, only: tephy
  use yomphy, only: tphy
  use yomarphy, only: tarphy
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_space, physics_key_character, physics_fold_equal
  implicit none
  private
  public :: selected_field_dimension_controls
  public :: initialize_physics_field_dimensions, initialize_spectral_field_dimensions

  !> Readonly selected controls supplied by their native upstream owners.
  !! NCONF, JPVXP and JPCXP are int32 counts; the other values are logical.
  !! This argument bundle owns no model state and produces no upstream value.
  type :: selected_field_dimension_controls
    integer(int32) :: nconf = 1_int32
    logical :: lecmwf = .true., lr3d = .true., lr2d = .false., lelam = .false.
    logical :: l_oops = .false., ljc = .false., lmcc01 = .false.
    integer(int32) :: jpvxp = 20_int32, jpcxp = 50_int32
  end type
contains
  !> Set physics field counts and derivative storage switches.
  !! TEXT is a readonly TARGET character string of 1:262144 ASCII bytes.
  !! DIMF and DPHY are INOUT canonical TDIMF and TDPHY records. The four
  !! physics and dynamics records and CONTROLS are readonly TARGET arguments.
  !! The six records are mutually separate; the two writable records are
  !! separate from TEXT and CONTROLS. Consumed logical values have canonical
  !! zero or one representations. The caller supplies valid native records.
  !! Read the first uppercase NAMDPHY marker in the first ten byte columns.
  !! Keys ignore case; each assignment is checked before a later duplicate.
  !! NCSNEC is 1:16, NVEXTR and NCEXTR are zero, and omitted NCSNEC is one.
  !! Return zero after success or two before any public mutation. No
  !! allocation, release, constructor, whole-record copy or I/O occurs.
  !! Unwritten fields, allocatable owners, padding, FP flags and errno remain.
  integer(int32) function initialize_physics_field_dimensions(text, dimf, dphy, &
                                                              dyna, ecmwf_physics, phy, arpege_physics, controls) result(status)
    character(len=*), intent(in), target :: text
    type(tdimf), intent(inout), target :: dimf
    type(tdphy), intent(inout), target :: dphy
    type(tdyna), intent(in), target :: dyna
    type(tephy), intent(in), target :: ecmwf_physics
    type(tphy), intent(in), target :: phy
    type(tarphy), intent(in), target :: arpege_physics
    type(selected_field_dimension_controls), intent(in), target :: controls
    integer(c_intptr_t) :: addresses(8)
    integer(int64) :: lengths(8)
    integer(int32) :: snow_layers
    integer :: first, second
    logical :: valid
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    addresses = [transfer(c_loc(dimf), 0_c_intptr_t), transfer(c_loc(dphy), 0_c_intptr_t), &
                 transfer(c_loc(dyna), 0_c_intptr_t), transfer(c_loc(ecmwf_physics), 0_c_intptr_t), &
                 transfer(c_loc(phy), 0_c_intptr_t), transfer(c_loc(arpege_physics), 0_c_intptr_t), &
                 transfer(c_loc(text(1:1)), 0_c_intptr_t), transfer(c_loc(controls), 0_c_intptr_t)]
    lengths = [storage_size(dimf, kind=int64)/8_int64, storage_size(dphy, kind=int64)/8_int64, &
               storage_size(dyna, kind=int64)/8_int64, storage_size(ecmwf_physics, kind=int64)/8_int64, &
               storage_size(phy, kind=int64)/8_int64, storage_size(arpege_physics, kind=int64)/8_int64, &
               int(len(text), int64), storage_size(controls, kind=int64)/8_int64]
    do first = 1, 5
      do second = first + 1, 6
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    do first = 1, 2
      do second = 7, 8
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. selected_controls(controls)) return
    if (.not. canonical_logical(dyna%lslag)) return
    if (.not. canonical_logical(dyna%lnhdyn)) return
    if (.not. canonical_logical(dyna%lslhd)) return
    if (.not. canonical_logical(dyna%lslhd_static)) return
    if (.not. canonical_logical(dyna%l3dturb)) return
    if (.not. canonical_logical(dyna%lcomad)) return
    if (.not. canonical_logical(dyna%lnhx)) return
    if (.not. canonical_logical(dyna%lrubc)) return
    if (.not. canonical_logical(ecmwf_physics%leflake)) return
    if (.not. canonical_logical(ecmwf_physics%leurban)) return
    if (.not. canonical_logical(ecmwf_physics%leo3ch)) return
    if (.not. canonical_logical(ecmwf_physics%leocml)) return
    if (.not. canonical_logical(ecmwf_physics%lo3ch_bms)) return
    if (.not. canonical_logical(ecmwf_physics%lo3ch_hlo)) return
    if (.not. canonical_logical(ecmwf_physics%locmltke)) return
    if (.not. canonical_logical(ecmwf_physics%ldiagturb_ec)) return
    if (.not. canonical_logical(ecmwf_physics%ldiagturbgrad_ec)) return
    if (.not. canonical_logical(phy%lozone)) return
    if (.not. canonical_logical(arpege_physics%lmse)) return
    call read_namdphy(text, snow_layers, valid)
    if (.not. valid) return
    if (phy%lozone .and. .not. ecmwf_physics%leo3ch) return

    ! All checks precede named stores; TDIMF allocatable owners stay in place.
    dphy%nvxp = 0_int32
    dphy%ncxp = 0_int32
    dphy%nvxp2 = 0_int32
    dphy%nvecout = 1_int32
    dphy%nvextr = 0_int32
    dphy%nvextrrad = 0_int32
    dphy%nvextrdyn = 0_int32
    dphy%nvxtr2 = 0_int32
    dphy%ncextr = 0_int32
    dphy%ntssg = 0_int32
    dphy%ltprof = .false.
    dphy%ldirclsmod = .false.
    dphy%ncss = 4_int32
    dphy%ntoz3d = 0_int32
    dphy%ntoz2d = 0_int32
    dphy%ntoz1d = 0_int32
    dphy%nvclis = 0_int32
    if (ecmwf_physics%leo3ch) then
      dphy%ntoz2d = 1_int32
      dphy%nvclis = 8_int32 - merge(1_int32, 0_int32, &
                                    ecmwf_physics%lo3ch_bms .or. ecmwf_physics%lo3ch_hlo)
    end if
    dphy%ncsnec = snow_layers
    dphy%ncsi = 0_int32
    dphy%ntiles = 0_int32
    dphy%ncom = 0_int32
    dphy%ncsi = 4_int32
    dphy%ntiles = 8_int32 + merge(1_int32, 0_int32, ecmwf_physics%leflake)
    if (ecmwf_physics%leurban) dphy%ntiles = 10_int32
    if (ecmwf_physics%leocml) dphy%ncom = 35_int32
    if (ecmwf_physics%locmltke) dphy%ncom = 9_int32
    dimf%nfc2d = 1_int32
    dimf%lspt = .true.
    dimf%lader = .true.
    if (.not. dyna%lslag) then
      dimf%luvder = .true.
    else
      dimf%luvder = (dyna%lslhd .and. .not. dyna%lslhd_static) .or. dyna%lnhdyn .or. &
                    dyna%l3dturb .or. dyna%lcomad .or. &
                    (ecmwf_physics%ldiagturb_ec .and. ecmwf_physics%ldiagturbgrad_ec)
    end if
    dimf%lvor = dyna%lnhdyn .or. (dyna%lslhd .and. dyna%lslag) .or. .not. dyna%lslag
    status = 0_int32
  end function

  !> Combine thermodynamic, dynamic and GFL counts into spectral dimensions.
  !! DIMF is INOUT TDIMF. DYNA, NUMSPFLDS and CONTROLS are readonly TARGET
  !! arguments, separate from DIMF. NUMSPFLDS is an int32 count from zero
  !! through 255. Incoming NFC2D is one and all consumed logicals are zero
  !! or one. Return zero after success or two before mutation. This routine
  !! retains every other DIMF member and never copies or changes its owners.
  integer(int32) function initialize_spectral_field_dimensions(dimf, dyna, numspflds, controls) result(status)
    type(tdimf), intent(inout), target :: dimf
    type(tdyna), intent(in), target :: dyna
    integer(int32), intent(in), target :: numspflds
    type(selected_field_dimension_controls), intent(in), target :: controls
    integer(c_intptr_t) :: address, other_addresses(3)
    integer(int64) :: bytes, other_bytes(3)
    integer(int32) :: thermodynamic_fields
    integer :: other
    status = 2_int32
    address = transfer(c_loc(dimf), 0_c_intptr_t)
    bytes = storage_size(dimf, kind=int64)/8_int64
    other_addresses = [transfer(c_loc(dyna), 0_c_intptr_t), transfer(c_loc(numspflds), 0_c_intptr_t), &
                       transfer(c_loc(controls), 0_c_intptr_t)]
    other_bytes = [storage_size(dyna, kind=int64)/8_int64, 4_int64, &
                   storage_size(controls, kind=int64)/8_int64]
    do other = 1, 3
      if (.not. disjoint(address, bytes, other_addresses(other), other_bytes(other))) return
    end do
    if (.not. selected_controls(controls)) return
    if (numspflds < 0 .or. numspflds > 255) return
    if (.not. canonical_logical(dyna%lnhdyn)) return
    if (.not. canonical_logical(dyna%lnhx)) return
    if (.not. canonical_logical(dyna%lrubc)) return
    if (.not. canonical_logical(dimf%lspt)) return
    if (.not. canonical_logical(dimf%lader)) return
    if (dimf%nfc2d /= 1) return

    dimf%nfd2d = 1_int32 + merge(1_int32, 0_int32, dyna%lrubc)
    thermodynamic_fields = 0_int32
    if (dimf%lspt) thermodynamic_fields = thermodynamic_fields + 1_int32
    if (dyna%lnhdyn) then
      thermodynamic_fields = thermodynamic_fields + 2_int32
      if (dyna%lnhx) thermodynamic_fields = thermodynamic_fields + 1_int32
    end if
    dimf%nfther = thermodynamic_fields
    dimf%nf3d = thermodynamic_fields + 2_int32
    dimf%nf3d = dimf%nf3d + numspflds
    if (.not. dimf%lader) dimf%luvder = .false.
    dimf%ns3d = dimf%nf3d
    dimf%ns2d = dimf%nfd2d + dimf%nfc2d
    dimf%ns1d = 2_int32
    status = 0_int32
  end function

  !> Read three dimension keys, validating each assignment in source order.
  !! Scratch values are local. A closing slash commits the final snow count.
  subroutine read_namdphy(text, snow_layers, valid)
    character(len=*), intent(in) :: text
    integer(int32), intent(out) :: snow_layers
    logical, intent(out) :: valid
    integer :: cursor, n, first, last, key
    integer(int32) :: value, values(3)
    logical :: integer_valid
    valid = .false.; snow_layers = 1_int32
    values = [0_int32, 0_int32, 1_int32]
    cursor = find_physics_group(text, 'NAMDPHY', .false.)
    if (cursor == 0) return
    n = len(text)
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        snow_layers = values(3); valid = .true.
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .true.) .and. &
            text(cursor:cursor) /= '(' .and. text(cursor:cursor) /= ')') exit
        cursor = cursor + 1
      end do
      if (cursor > n) return
      last = cursor - 1
      key = 0
      if (physics_fold_equal(text(first:last), 'NVEXTR')) key = 1
      if (physics_fold_equal(text(first:last), 'NCEXTR')) key = 2
      if (physics_fold_equal(text(first:last), 'NCSNEC')) key = 3
      if (key == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor))) exit
        if (index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (cursor > n .or. cursor == first) return
      call read_integer(text(first:cursor - 1), value, integer_valid)
      if (.not. integer_valid) return
      if (key <= 2) then
        if (value /= 0_int32) return
      else
        if (value < 1_int32 .or. value > 16_int32) return
      end if
      values(key) = value
    end do
  end subroutine

  !> Read the source signed decimal syntax with the same 99999999 bound.
  !! Every digit is checked before an optional leading minus is applied.
  subroutine read_integer(token, value, valid)
    character(len=*), intent(in) :: token
    integer(int32), intent(out) :: value
    logical, intent(out) :: valid
    integer(int64) :: magnitude
    integer :: cursor, digit, n
    logical :: negative
    value = 0_int32; valid = .false.; negative = .false.
    n = len(token)
    if (n < 1) return
    cursor = 1
    if (token(1:1) == '-') then
      negative = .true.; cursor = 2
    else if (token(1:1) == '+') then
      cursor = 2
    end if
    if (cursor > n) return
    magnitude = 0_int64
    do while (cursor <= n)
      digit = iachar(token(cursor:cursor)) - 48
      if (digit < 0 .or. digit > 9) return
      magnitude = magnitude*10_int64 + int(digit, int64)
      if (magnitude > 99999999_int64) return
      cursor = cursor + 1
    end do
    value = int(magnitude, int32)
    if (negative) value = -value
    valid = .true.
  end subroutine

  logical function selected_controls(controls) result(selected)
    type(selected_field_dimension_controls), intent(in) :: controls
    selected = .false.
    if (.not. canonical_logical(controls%lecmwf)) return
    if (.not. canonical_logical(controls%lr3d)) return
    if (.not. canonical_logical(controls%lr2d)) return
    if (.not. canonical_logical(controls%lelam)) return
    if (.not. canonical_logical(controls%l_oops)) return
    if (.not. canonical_logical(controls%ljc)) return
    if (.not. canonical_logical(controls%lmcc01)) return
    selected = controls%nconf == 1 .and. controls%lecmwf .and. controls%lr3d .and. &
               .not. controls%lr2d .and. .not. controls%lelam .and. .not. controls%l_oops .and. &
               .not. controls%ljc .and. .not. controls%lmcc01 .and. controls%jpvxp == 20 .and. controls%jpcxp == 50
  end function

  pure logical function canonical_logical(value) result(canonical)
    logical, intent(in) :: value
    integer(int32) :: bits
    bits = transfer(value, 0_int32)
    canonical = bits == 0_int32 .or. bits == 1_int32
  end function

  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

end module physics_field_dimensions_port
