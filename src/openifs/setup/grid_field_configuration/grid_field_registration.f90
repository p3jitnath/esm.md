module grid_field_registration_port
  !! Compose generated definitions, aliases and attributes in source order.
  !! The caller supplies a fresh native namespace, nine readonly profiles
  !! ordered Q,L,I,S,R,A,O3,NOGW1,NOGW2, and initialized physical constants.
  !! Constants are SI values from the accepted own constructor. The two
  !! effect flags return zero. Status2 refuses before namespace mutation;
  !! status3 identifies an unexpected child failure after publication began.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use grid_field_component_types_port, only: field_profile_metadata, grid_field_mode_supported
  use grid_field_registration_types_port, only: field_definition_plan, field_attribute_plan
  use grid_field_component_defaults_port, only: initialize_field_component_defaults,reset_grid_field_components,initialize_selected_grid_field_profiles
  use grid_field_component_definition_port, only: define_grid_field_component
  use grid_field_component_attributes_port, only: set_grid_field_attributes
  use operational_grid_field_component_definition_port, only: define_operational_grid_field_component
  use operational_grid_field_component_attributes_port, only: set_operational_grid_field_attributes
  use grid_field_aliases_port, only: bind_selected_grid_field_aliases, bind_operational_grid_field_aliases
  use grid_field_interpolation_names_port, only: grid_field_interpolation_name
use grid_field_configuration_types_port, only: grid_field_configuration, grid_field_configuration_is_fresh, grid_field_profile_equal
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: register_selected_grid_fields, register_operational_grid_fields
contains
 integer(int32) function register_selected_grid_fields(output,profiles,constants,levels,supplementary_levels,effects) result(status)
    type(grid_field_configuration), intent(inout) :: output
    type(field_profile_metadata), contiguous, intent(in) :: profiles(:)
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: levels, supplementary_levels
    integer(int32), intent(inout) :: effects(2)
    status = register_fields(output, profiles, constants, levels, supplementary_levels, effects, .false.)
  end function
  integer(int32) function register_operational_grid_fields(output,profiles,constants,levels,supplementary_levels,effects) result(status)
    type(grid_field_configuration), intent(inout) :: output
    type(field_profile_metadata), contiguous, intent(in) :: profiles(:)
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: levels, supplementary_levels
    integer(int32), intent(inout) :: effects(2)
    status = register_fields(output, profiles, constants, levels, supplementary_levels, effects, .true.)
  end function
  integer(int32) function register_fields(output,profiles,constants,levels,supplementary_levels,effects,operational) result(status)
    type(grid_field_configuration), intent(inout) :: output
    type(field_profile_metadata), contiguous, intent(in) :: profiles(:)
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: levels, supplementary_levels
    integer(int32), intent(inout) :: effects(2)
    logical, intent(in) :: operational
    type(field_profile_metadata) :: expected(9)
    type(field_definition_plan) :: definition
    type(field_attribute_plan) :: attributes
    integer(int32) :: rc, i, j, last, first, n, profile_index, family
    integer(int32) :: attribute_order(9), profile_order(9), flags(10), fix_count
    integer(int32), parameter :: codes(9) = [133, 246, 247, 76, 75, 248, 203, 228134, 228136]
    integer(int32), parameter :: identifiers(9) = [47, 49, 50, 56, 57, 51, 48, -1, -1]
    character(len=16), parameter :: names(9) = [character(len=16) :: &
                                                ' HUMIDITY       ', ' LIQUID WATER   ', ' ICE WATER      ', 'SNOW            ', &
                                 'RAIN            ', ' CLOUD FRACTION ', ' OZONE          ', 'TENUNOGW        ', 'TENVNOGW        ']
    status = 2_int32
    if (size(profiles) /= 9) return
    if (.not. grid_field_mode_supported()) return
    if (operational) then
      if (levels /= 137 .or. supplementary_levels /= 0) return
      n = 9
    else
      if (levels < 1 .or. levels > 64 .or. supplementary_levels < 0 .or. supplementary_levels > 64) return
      n = 8
    end if
    if (constants%initialized /= 1) return
    if (.not. positive_finite_bits(constants%rv) .or. .not. positive_finite_bits(constants%rcpv)) return
    if (.not. positive_finite_bits(constants%rcw) .or. .not. positive_finite_bits(constants%rcs)) return
    if (.not. positive_finite_bits(constants%rlvzer) .or. .not. positive_finite_bits(constants%rlszer)) return
    if (.not. grid_field_configuration_is_fresh(output)) return
    rc = initialize_selected_grid_field_profiles(expected)
    if (rc /= 0) then
      status = 3_int32; return
    end if
    if (operational) then
      expected(7)%lgp = 1
      if (profiles(4)%nreqin /= 1 .or. profiles(5)%nreqin /= 1) return
    else
      if (profiles(4)%nreqin < -1 .or. profiles(4)%nreqin > 1) return
      if (profiles(5)%nreqin < -1 .or. profiles(5)%nreqin > 1) return
    end if
    expected(4)%nreqin = profiles(4)%nreqin
    expected(5)%nreqin = profiles(5)%nreqin
    do i = 1, 9
      if (.not. grid_field_profile_equal(expected(i), profiles(i))) return
    end do
    status = 3_int32
    do first = 1, 2163, 64
      last = min(first + 63, 2163)
      rc = initialize_field_component_defaults(output%components(first:last))
      if (rc /= 0) return
    end do
    rc = reset_grid_field_components(output%components, -99999_int32)
    if (rc /= 0) return
    output%profiles = profiles
    output%alias_controls%nnogw = 2
    output%settings%ltrcmfix = 1; output%settings%ltrcmfix_ps = 1
    output%settings%ltrcmfbc = 1; output%settings%noptmfbc = 3
    output%settings%noptmfpr = 1; output%settings%noptnegfix = 1
    output%settings%zmfixeps = transfer(int(z'3cc0000000000000', int64), 0.0_real64)
    do i = 1, n
      profile_index = i
      if (.not. operational .and. i >= 7) profile_index = i + 1
      family = 0
      if (i == 6 .or. (operational .and. i == 7)) family = 1
      if ((operational .and. i >= 8) .or. (.not. operational .and. i >= 7)) family = 2
      definition = field_definition_plan()
      definition%cname = names(profile_index); definition%igrbcode = codes(profile_index)
      definition%ifid = identifiers(profile_index)
      definition%nreqin = profiles(profile_index)%nreqin
      definition%lreqout = profiles(profile_index)%lreqout
      definition%lgpingp = 1
      if (family /= 2) definition%lgpingp = profiles(profile_index)%lgpingp
      definition%lmgrid = profiles(profile_index)%lmgrid
      definition%ltrajio = profiles(profile_index)%ltrajio
      if (family == 0) then
        definition%lthermact = 1
        if (i == 4 .or. i == 5) definition%lprecip = 1
      end if
      definition%lmassfix = profiles(profile_index)%lmassfix
      definition%lcomad = profiles(profile_index)%lcomad
      definition%lnegfix = profiles(profile_index)%lnegfix
      definition%refvali = profiles(profile_index)%refvali
      if (i == 1) then
        definition%r = constants%rv; definition%rcp = constants%rcpv
      else if (i == 2 .or. i == 5) then
        definition%rcp = constants%rcw; definition%rlzer = constants%rlvzer
      else if (i == 3 .or. i == 4) then
        definition%rcp = constants%rcs; definition%rlzer = constants%rlszer
      end if
      definition%weno_alpha = profiles(profile_index)%weno_alpha
      definition%betamfbc = profiles(profile_index)%betamfbc
      if (operational) then
        rc = define_operational_grid_field_component(output%registration, output%components, i, definition, family)
      else
        rc = define_grid_field_component(output%registration, output%components, i, definition, family)
      end if
      if (rc /= 0) return
    end do
    if (operational) then
      rc = bind_operational_grid_field_aliases(output%registration, output%alias_controls, output%components, output%aliases)
      attribute_order = [7, 1, 6, 2, 3, 4, 5, 8, 9]
      profile_order = attribute_order
    else
      rc = bind_selected_grid_field_aliases(output%registration, output%alias_controls, output%components, output%aliases)
      attribute_order = [1, 6, 2, 3, 4, 5, 7, 8, 0]
      profile_order = [1, 6, 2, 3, 4, 5, 8, 9, 0]
    end if
    if (rc /= 0) return
    do j = 1, n
      i = attribute_order(j); profile_index = profile_order(j)
      attributes = field_attribute_plan()
      attributes%adv = profiles(profile_index)%ladv
      attributes%mgrid = profiles(profile_index)%lmgrid
      attributes%adv5 = profiles(profile_index)%ladv5
      attributes%tdiab = profiles(profile_index)%ltdiablin
      attributes%hort = profiles(profile_index)%lhorturb
      attributes%phy = profiles(profile_index)%lphy
      attributes%coupling = profiles(profile_index)%ncoupling
      attributes%refvalc = profiles(profile_index)%refvalc
      family = 0
      if ((operational .and. j >= 8) .or. (.not. operational .and. j >= 7)) family = 1
      if (family == 0) then
        flags = [profiles(profile_index)%lslhd, profiles(profile_index)%lcomad, profiles(profile_index)%lvsplip, &
                 profiles(profile_index)%lhv, profiles(profile_index)%lqm, profiles(profile_index)%lqmh, &
     profiles(profile_index)%lqm3d, profiles(profile_index)%lqml3d, profiles(profile_index)%lintlin, profiles(profile_index)%lvweno]
        rc = grid_field_interpolation_name(flags, attributes%cslint)
        if (rc /= 0) return
      end if
      if (operational) then
     rc=set_operational_grid_field_attributes(output%registration,output%components,i,attributes,levels,supplementary_levels,family)
      else
        rc = set_grid_field_attributes(output%registration, output%components, i, attributes, levels, supplementary_levels, family)
      end if
      if (rc /= 0) return
    end do
    fix_count = 0
    do i = 1, n
      if (output%components(i)%lmassfix == 0 .or. output%components(i)%ladv == 0) cycle
      fix_count = fix_count + 1; output%settings%nmfixflds(fix_count) = i
    end do
    output%settings%nfldsfix = fix_count
    output%settings%nnegafix = 0; output%settings%ladvnegfix = 0; output%settings%nfmg = 0
    effects = 0_int32
    status = 0_int32
  end function
  logical function positive_finite_bits(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: bits
    bits = transfer(value, 0_int64)
    valid = bits > 0_int64 .and. bits < int(z'7ff0000000000000', int64)
  end function
end module grid_field_registration_port
