module selected_grid_field_namelist_port
  !! Apply the nine supported NAMGFL settings to native profile metadata.
  !! A namelist is a text group of named input settings. The first line-starting
  !! NAMGFL group is used; group and member names are case insensitive.
  !! Port: src/openifs/setup/selected_grid_field_namelist.S.
  use, intrinsic :: iso_fortran_env, only: int32
  use grid_field_component_types_port, only: field_profile_metadata, grid_field_mode_supported
  use physics_configuration_text_port, only: physics_space, physics_key_character, &
                                             physics_fold_equal, skip_physics_space, parse_physics_boolean
  implicit none
  private
  public :: apply_selected_grid_field_namelist
contains
  integer(int32) function apply_selected_grid_field_namelist(text, profiles) result(status)
    !! text contains1..262144 bytes. profiles has exactly9 records in
    !! Q,L,I,S,R,A,O3,NOGW1,NOGW2 order. The caller owns disjoint inputs.
    !! Keys are contiguous and values are canonical flags or integers-1..1.
    !! Duplicate keys use their last value. A complete closing slash commits
    !! all changes; refusal2 leaves every profile member unchanged. Success0
    !! changes only the nine supported words, with no allocation or FP math.
    character(len=*), intent(in) :: text
    type(field_profile_metadata), contiguous, intent(inout) :: profiles(:)
    type(field_profile_metadata) :: staged(9)
    integer :: cursor, n, first, last, key, selector
    integer(int32) :: value
    logical :: valid, logical_value
    status = 2_int32
    n = len(text)
    if (n < 1 .or. n > 262144 .or. size(profiles) /= 9) return
    if (.not. grid_field_mode_supported()) return
    staged = profiles
    cursor = find_namgfl(text)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        profiles = staged
        status = 0_int32
        return
      end if
      first = cursor
      do
        if (cursor > n) return
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      key = lookup_key(text(first:last))
      if (key == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      first = cursor
      do
        if (cursor > n) return
        if (physics_space(text(cursor:cursor))) exit
        if (text(cursor:cursor) == ',' .or. text(cursor:cursor) == '!' .or. text(cursor:cursor) == '/') exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (key == 5 .or. key == 6) then
        call parse_request_integer(text(first:last), value, valid)
      else
        call parse_physics_boolean(text(first:last), logical_value, valid)
        value = merge(1_int32, 0_int32, logical_value)
      end if
      if (.not. valid) return
      select case (key)
      case (1)
        staged(1)%lgp = value
      case (2)
        staged(1)%lsp = value
      case (3)
        staged(7)%lgp = value
      case (4)
        staged(1)%lgpingp = value
      case (5)
        staged(5)%nreqin = value
      case (6)
        staged(4)%nreqin = value
      case (7)
        staged(2)%lgp = value
      case (8)
        staged(3)%lgp = value
      case (9)
        staged(6)%lgp = value
      end select
    end do
  end function

  integer function find_namgfl(text) result(cursor)
    !! Match NAMGFL without case at the first nonblank token on a line.
    !! Unlike other configuration groups, this source has no ten-column limit.
    character(len=*), intent(in) :: text
    integer :: i, n, last
    cursor = 0
    n = len(text)
    i = 1
    do
      if (i > n) return
      if (physics_space(text(i:i))) then
        i = i + 1
        cycle
      end if
      if (text(i:i) == '&') then
        last = i + 6
        if (last >= n) return
        if (physics_fold_equal(text(i + 1:last), 'NAMGFL')) then
          if (physics_space(text(last + 1:last + 1)) .or. text(last + 1:last + 1) == '/' .or. &
              text(last + 1:last + 1) == ',') then
            cursor = last + 1
            return
          end if
        end if
      end if
      do
        if (i > n) return
        if (iachar(text(i:i)) == 10) exit
        i = i + 1
      end do
      i = i + 1
    end do
  end function

  pure integer function lookup_key(key) result(selector)
    character(len=*), intent(in) :: key
    selector = 0
    if (physics_fold_equal(key, 'yq_nl%lgp')) selector = 1
    if (physics_fold_equal(key, 'yq_nl%lsp')) selector = 2
    if (physics_fold_equal(key, 'yo3_nl%lgp')) selector = 3
    if (physics_fold_equal(key, 'yq_nl%lgpingp')) selector = 4
    if (physics_fold_equal(key, 'yr_nl%nreqin')) selector = 5
    if (physics_fold_equal(key, 'ys_nl%nreqin')) selector = 6
    if (physics_fold_equal(key, 'yl_nl%lgp')) selector = 7
    if (physics_fold_equal(key, 'yi_nl%lgp')) selector = 8
    if (physics_fold_equal(key, 'ya_nl%lgp')) selector = 9
  end function

  pure subroutine parse_request_integer(token, value, valid)
    !! Accept0or1 with an optional plus/minus sign; retain the source's-0.
    character(len=*), intent(in) :: token
    integer(int32), intent(out) :: value
    logical, intent(out) :: valid
    integer :: i, sign, digit
    value = 0_int32; valid = .false.
    i = 1; sign = 1
    if (len(token) == 2) then
      if (token(1:1) == '+') then
        sign = 1
      else if (token(1:1) == '-') then
        sign = -1
      else
        return
      end if
      i = 2
    else if (len(token) /= 1) then
      return
    end if
    digit = iachar(token(i:i)) - 48
    if (digit < 0 .or. digit > 1) return
    value = int(sign*digit, int32)
    valid = .true.
  end subroutine
end module selected_grid_field_namelist_port
