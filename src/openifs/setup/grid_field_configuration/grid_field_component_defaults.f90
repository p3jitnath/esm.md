module grid_field_component_defaults_port
  !! Port source field defaults, reset stores and nine selected profiles.
  !! Native metadata keeps named words and compiler-owned storage. No original
  !! object, global or procedure supplies an assignment.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use grid_field_component_types_port, only: field_component_metadata, &
                                 field_profile_metadata, field_component_is_fresh, field_profile_is_fresh, grid_field_mode_supported
  implicit none
  private
  public :: initialize_field_component_defaults, reset_grid_field_components
  public :: initialize_selected_grid_field_profiles
contains
  integer(int32) function initialize_field_component_defaults(components) result(status)
    !! Apply declared defaults to1..64 fresh zero native records.
    !! Validate every record before the first write. Untouched named words
    !! retain their incoming zero bits. No numerical value is calculated.
    type(field_component_metadata), contiguous, intent(inout) :: components(:)
    integer :: j
    status = 2_int32
    if (size(components, kind=int64) < 1_int64 .or. size(components, kind=int64) > 64_int64) return
    if (.not. grid_field_mode_supported()) return
    do j = 1, size(components)
      if (.not. field_component_is_fresh(components(j))) return
    end do
    do j = 1, size(components)
      components(j)%cname = ' '
      components(j)%igrbcode = -999_int32
      components(j)%lgpingp = 1_int32
      components(j)%cslint = ' '
      call set_component_indices(components(j), -99999999_int32)
      components(j)%ifid = -1_int32
      components(j)%previous_index = 0_int32
    end do
    status = 0_int32
  end function

  integer(int32) function reset_grid_field_components(components, undefined) result(status)
    !! Apply FALSIFY_GFL_COMP to1..2163 native records. undefined is-99999.
    !! Preserve LMGRID,IFID and every chemistry member without a source
    !! assignment. Source index values are integers, and previous_index0
    !! replaces a cleared old pointer. Incoming payloads may be nonzero.
    type(field_component_metadata), contiguous, intent(inout) :: components(:)
    integer(int32), intent(in) :: undefined
    integer :: j
    status = 2_int32
    if (size(components, kind=int64) < 1_int64 .or. size(components, kind=int64) > 2163_int64) return
    if (undefined /= -99999_int32) return
    if (.not. grid_field_mode_supported()) return
    do j = 1, size(components)
      components(j)%cname = ' '
      components(j)%igrbcode = -999_int32
      components(j)%ladv = 0_int32
      components(j)%ladv5 = 0_int32
      components(j)%ltdiablin = 0_int32
      components(j)%lhorturb = 0_int32
      components(j)%nreqin = 0_int32
      components(j)%lreqout = 0_int32
      components(j)%ltrajio = 0_int32
      components(j)%ldiag = 0_int32
      components(j)%lgp = 0_int32
      components(j)%lsp = 0_int32
      components(j)%lcders = 0_int32
      components(j)%lactive = 0_int32
      components(j)%lthermact = 0_int32
      components(j)%lt9 = 0_int32
      components(j)%lt1 = 0_int32
      components(j)%lt5 = 0_int32
      components(j)%lphy = 0_int32
      components(j)%lpt = 0_int32
      components(j)%lpc = 0_int32
      components(j)%ladjust0 = 0_int32
      components(j)%ladjust1 = 0_int32
      components(j)%ncoupling = 0_int32
      components(j)%lbiper = 0_int32
      components(j)%lwater = 0_int32
      components(j)%lprecip = 0_int32
      components(j)%lgpingp = 1_int32
      components(j)%refvali = 0.0_real64
      components(j)%refvalc = 0.0_real64
      components(j)%r = 0.0_real64
      components(j)%rcp = 0.0_real64
      components(j)%rlzer = 0.0_real64
      components(j)%cslint = ' '
      call set_component_indices(components(j), undefined)
      components(j)%mpslp = -99_int32
      components(j)%previous_index = 0_int32
    end do
    status = 0_int32
  end function

  integer(int32) function initialize_selected_grid_field_profiles(profiles) result(status)
    !! Initialize exactly nine fresh profile records in source order:
    !! Q,L,I,S,R,A,O3,TENUNOGW,TENVNOGW. Flags are0/1 words; all other
    !! source-unwritten words stay unchanged. The values-999 and1 are exact.
    type(field_profile_metadata), contiguous, intent(inout) :: profiles(:)
    integer :: j
    status = 2_int32
    if (size(profiles) /= 9) return
    if (.not. grid_field_mode_supported()) return
    do j = 1, 9
      if (.not. field_profile_is_fresh(profiles(j))) return
    end do
    do j = 1, 7
      profiles(j)%nreqin = 1_int32
      profiles(j)%refvali = -999.0_real64
      profiles(j)%lreqout = 1_int32
      profiles(j)%lgpingp = 1_int32
      profiles(j)%lpc = 1_int32
      profiles(j)%ladv = 1_int32
      profiles(j)%refvalc = -999.0_real64
      profiles(j)%betamfbc = 1.0_real64
      if (j <= 6) profiles(j)%lgp = 1_int32
      if (j == 1 .or. j >= 6) profiles(j)%lphy = 1_int32
      if (j /= 6) profiles(j)%lpt = 1_int32
      if (j == 1 .or. j == 7) then
        profiles(j)%lqm = 1_int32
      else
        profiles(j)%lqm3d = 1_int32
      end if
      if (j == 1) profiles(j)%lvweno = 1_int32
      if (j <= 5) profiles(j)%lmassfix = 1_int32
    end do
    profiles(8)%cname = 'TENUNOGW        '
    profiles(9)%cname = 'TENVNOGW        '
    profiles(8)%igrbcode = 228134_int32
    profiles(9)%igrbcode = 228136_int32
    do j = 8, 9
      profiles(j)%lreqout = 1_int32
      profiles(j)%lgp = 1_int32
      profiles(j)%lt5 = 1_int32
      profiles(j)%betamfbc = 1.0_real64
    end do
    status = 0_int32
  end function

  pure subroutine set_component_indices(field, value)
    type(field_component_metadata), intent(inout) :: field
    integer(int32), intent(in) :: value
    field%mp = value
    field%mpl = value
    field%mpm = value
    field%mp9 = value
    field%mp9_ph = value
    field%mp1 = value
    field%mp5 = value
    field%mp5l = value
    field%mp5m = value
    field%mpslp = value
    field%mpsp = value
    field%mp_spl = value
    field%mp_sl1 = value
    field%mp_slx = value
    field%mppt = value
    field%mppc = value
  end subroutine
end module grid_field_component_defaults_port
