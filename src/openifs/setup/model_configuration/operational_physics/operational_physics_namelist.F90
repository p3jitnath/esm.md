!> Apply the exact operational42-key NAEPHY route to private native values.
module forecast_operational_physics_namelist
  use iso_fortran_env, only: int32
  use yoephy, only: tephy
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                        physics_key_character, physics_space, physics_fold_equal, parse_physics_boolean, parse_physics_small_integer
  implicit none
  private
  public :: apply_operational_physics_namelist
contains
!> Read the first uppercase-exact source group before publishing.
!! TEXT is read-only ASCII of1:262144characters. OUTPUT is INOUT canonical
!! TEPHY and WAVES is INOUT INT32(8),with the declared source order. All
!! arguments are complete/disjoint. Flags and update intervals are unitless.
!! This leaf admits the42 exact source keys,case-insensitive member names,
!! T/F/TRUE/FALSE optionallydotted,smallintegers0:2 optionallyplus-prefixed,
!! and the exact quoted CO3CHEM value H1.0. Repeats keep their last value.
!! Status2 changes no output;status0 commits both native staged values.
  integer(int32) function apply_operational_physics_namelist(text, output, waves) result(status)
    character(len=*), intent(in) :: text
    type(tephy), intent(inout) :: output
    integer(int32), intent(inout) :: waves(8)
    type(tephy) :: staged
    integer(int32) :: staged_waves(8), integer_value
    integer :: cursor, first, last, key, n
    logical :: logical_value, valid
    character(len=13), parameter :: keys(42) = [character(len=13) :: &
                                                'lephys', &
                                                'levdif', &
                                                'lesurf', &
                                                'lecond', &
                                                'lecumf', &
                                                'lepcld', &
                                                'leevap', &
                                                'levgen', &
                                                'lessro', &
                                                'lecurr', &
                                                'leocwa', &
                                                'legwdg', &
                                                'legwwms', &
                                                'leozoc', &
                                                'leqngt', &
                                                'leradi', &
                                                'lerads', &
                                                'lesice', &
                                                'leo3ch', &
                                                'lo3ch_hlo', &
                                                'co3chem', &
                                                'ledcld', &
                                                'lductdia', &
                                                'ldiagturb_ec', &
                                                'lelight', &
                                                'lwcou', &
                                                'lwcou2w', &
                                                'lwcouhmf', &
                                                'lwcournw', &
                                                'nstpw', &
                                                'lslphy', &
                                                'lesnml', &
                                                'nsnmlws', &
                                                'lefarquhar', &
                                                'leoptsurf', &
                                                'leairco2coup', &
                                                'lec4map', &
                                                'leags', &
                                                'nalbedoscheme', &
                                                'lelaiv', &
                                                'lwcur', &
                                                'lwstokes']
    integer,parameter::key_lengths(42)=[6,6,6,6,6,6,6,6,6,6,6,6,7,6,6,6,6,6,6,9,7,6,8,12,7,5,7,8,8,5,6,6,7,10,9,12,7,5,13,6,5,8]
    status = 2_int32
    n = len(text)
    if (n < 1 .or. n > 262144) return
    cursor = find_physics_group(text, 'NAEPHY', .true.)
    if (cursor == 0) return
    staged = output
    staged_waves = waves
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        output = staged
        waves = staged_waves
        status = 0_int32
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      if (cursor > n) return
      last = cursor - 1
      if (last < first) return
      do key = 1, 42
        if (physics_fold_equal(text(first:last), keys(key) (1:key_lengths(key)))) exit
      end do
      if (key > 42) return
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
      if (cursor > n) return
      last = cursor - 1
      if (last < first) return
      select case (key)
      case (30, 33, 39)
        call parse_physics_small_integer(text(first:last), integer_value, valid)
      case (21)
        valid = .false.
        if (last - first + 1 == 6) then
          if ((text(first:first) == achar(39) .or. text(first:first) == achar(34)) .and. &
              text(last:last) == text(first:first)) then
            valid = text(first + 1:last - 1) == 'H1.0'
          end if
        end if
      case default
        call parse_physics_boolean(text(first:last), logical_value, valid)
      end select
      if (.not. valid) return
      select case (key)
      case (1); staged%lephys = logical_value
      case (2); staged%levdif = logical_value
      case (3); staged%lesurf = logical_value
      case (4); staged%lecond = logical_value
      case (5); staged%lecumf = logical_value
      case (6); staged%lepcld = logical_value
      case (7); staged%leevap = logical_value
      case (8); staged%levgen = logical_value
      case (9); staged%lessro = logical_value
      case (10); staged%lecurr = logical_value
      case (11); staged%leocwa = logical_value
      case (12); staged%legwdg = logical_value
      case (13); staged%legwwms = logical_value
      case (14); staged%leozoc = logical_value
      case (15); staged%leqngt = logical_value
      case (16); staged%leradi = logical_value
      case (17); staged%lerads = logical_value
      case (18); staged%lesice = logical_value
      case (19); staged%leo3ch = logical_value
      case (20); staged%lo3ch_hlo = logical_value
      case (21); staged%co3chem = 'H1.0'
      case (22); staged%ledcld = logical_value
      case (23); staged%lductdia = logical_value
      case (24); staged%ldiagturb_ec = logical_value
      case (25); staged%lelight = logical_value
      case (26); staged_waves(1) = merge(1_int32, 0_int32, logical_value)
      case (27); staged_waves(2) = merge(1_int32, 0_int32, logical_value)
      case (28); staged_waves(5) = merge(1_int32, 0_int32, logical_value)
      case (29); staged_waves(4) = merge(1_int32, 0_int32, logical_value)
      case (30); staged_waves(8) = integer_value
      case (31); staged%lslphy = logical_value
      case (32); staged%lesnml = logical_value
      case (33); staged%nsnmlws = integer_value
      case (34); staged%lefarquhar = logical_value
      case (35); staged%leoptsurf = logical_value
      case (36); staged%leairco2coup = logical_value
      case (37); staged%lec4map = logical_value
      case (38); staged%leags = logical_value
      case (39); staged%nalbedoscheme = integer_value
      case (40); staged%lelaiv = logical_value
      case (41); staged_waves(3) = merge(1_int32, 0_int32, logical_value)
      case (42); staged_waves(6) = merge(1_int32, 0_int32, logical_value)
      end select
    end do
  end function
end module forecast_operational_physics_namelist
