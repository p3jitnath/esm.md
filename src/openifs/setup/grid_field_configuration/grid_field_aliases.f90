module grid_field_aliases_port
  !! Bind named field views after the selected registration stage.
  !! The exact 2163-entry owner stays with the caller. Named indices replace
  !! historical pointer and descriptor bytes, whose address identity is not
  !! part of the new interface. All target checks precede publication.
  use, intrinsic :: iso_fortran_env, only: int32
  use grid_field_component_types_port, only: field_component_metadata, grid_field_mode_supported
  use grid_field_registration_types_port, only: grid_field_registration_state
  use grid_field_alias_types_port, only: grid_field_alias_controls, grid_field_aliases, component_alias_span
  implicit none
  private
  public :: bind_selected_grid_field_aliases, bind_operational_grid_field_aliases
contains
  integer(int32) function bind_selected_grid_field_aliases(state, controls, components, aliases) result(status)
    type(grid_field_registration_state), intent(in) :: state
    type(grid_field_alias_controls), intent(in) :: controls
    type(field_component_metadata), contiguous, intent(in) :: components(:)
    type(grid_field_aliases), intent(inout) :: aliases
    integer(int32) :: i, j, expected_active, expected_mp
    integer(int32), parameter :: first(61) = [ &
                                 1, 2, 3, 4, 5, 2158, 2157, 2156, 2155, 2154, 2153, 6, &
                                 2151, 2150, 2149, 2148, 2147, 2146, 2145, 2144, 2143, 2142, 2141, 2140, &
                                 2139, 2138, 2137, 2136, 2135, 2134, 2133, 2132, 2131, 2130, 2129, 2128, &
                                 2127, 2126, 2125, 2124, 2123, 2122, 2121, 2120, 2119, 2118, 2117, 2116, &
                                 2115, 2114, 2113, 7, 2112, 2111, 2110, 2109, 2108, 2107, 2106, 2105, &
                                 2104]
    integer(int32), parameter :: count(61) = [ &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1]
    status = 2_int32
    if (size(components) /= 2163) return
    if (.not. grid_field_mode_supported()) return
    if (state%numflds /= 8 .or. state%numgpflds /= 8) return
    if (controls%nnogw /= 2) return
    if (controls%ngfl_ext /= 0) return
    if (controls%ngfl_forc /= 0) return
    if (controls%ngfl_ezdiag /= 0) return
    if (controls%nghg /= 0) return
    if (controls%nchem /= 0) return
    if (controls%naero /= 0) return
    if (controls%nera40 /= 0) return
    if (controls%nemis3d /= 0) return
    if (controls%nedrp /= 0) return
    if (controls%naerout /= 0) return
    if (controls%naeroclim /= 0) return
    if (controls%nuvp /= 0) return
    if (controls%nsldia /= 0) return
    if (controls%nlima /= 0) return
    if (controls%laerlisi /= 0) return
    do i = 1, 61
      do j = first(i), first(i) + count(i) - 1
        expected_active = 0; expected_mp = -99999
        if (j <= 8) then
          expected_active = 1; expected_mp = j
        end if
        if (components(j)%lactive /= expected_active .or. components(j)%mp /= expected_mp) return
      end do
    end do
    aliases%yq = 1
    aliases%yl = 2
    aliases%yi = 3
    aliases%ys = 4
    aliases%yr = 5
    aliases%yg = 2158
    aliases%yh = 2157
    aliases%ytke = 2156
    aliases%yefb1 = 2155
    aliases%yefb2 = 2154
    aliases%yefb3 = 2153
    aliases%ya = 6
    aliases%yo3 = 2151
    aliases%ycpf = 2150
    aliases%yspf = 2149
    aliases%ysrc = 2148
    aliases%ycvgq = 2147
    aliases%ylconv = 2146
    aliases%yiconv = 2145
    aliases%yrconv = 2144
    aliases%ysconv = 2143
    aliases%ylrad = 2142
    aliases%yirad = 2141
    aliases%ysdsat = 2140
    aliases%ycvv = 2139
    aliases%yqva = 2138
    aliases%yuom = 2137
    aliases%yual = 2136
    aliases%ydom = 2135
    aliases%ydal = 2134
    aliases%yuen = 2133
    aliases%yunebh = 2132
    aliases%ytte = 2131
    aliases%ymxl = 2130
    aliases%yshtur = 2129
    aliases%yfqtur = 2128
    aliases%yfstur = 2127
    aliases%yrkth = 2126
    aliases%yrspec = 2125
    aliases%yrktqv = 2124
    aliases%yrktqc = 2123
    aliases%ylrch4 = 2122
    aliases%yphycty = 2121
    aliases%yfsd = 2120
    aliases%yext = component_alias_span(2119, 1)
    aliases%yforc = component_alias_span(2118, 1)
    aliases%yezdiag = component_alias_span(2117, 1)
    aliases%yghg = component_alias_span(2116, 1)
    aliases%ychem = component_alias_span(2115, 1)
    aliases%yaero = component_alias_span(2114, 1)
    aliases%yera40 = component_alias_span(2113, 1)
    aliases%ynogw = component_alias_span(7, 2)
    aliases%yemis3d = component_alias_span(2112, 1)
    aliases%yedrp = component_alias_span(2111, 1)
    aliases%yaeraot = component_alias_span(2110, 1)
    aliases%yaerlisi = component_alias_span(2109, 1)
    aliases%yaerout = component_alias_span(2108, 1)
    aliases%yaeroclim = component_alias_span(2107, 1)
    aliases%yuvp = component_alias_span(2106, 1)
    aliases%ysldia = component_alias_span(2105, 1)
    aliases%ylima = component_alias_span(2104, 1)
    status = 0_int32
  end function
  integer(int32) function bind_operational_grid_field_aliases(state, controls, components, aliases) result(status)
    type(grid_field_registration_state), intent(in) :: state
    type(grid_field_alias_controls), intent(in) :: controls
    type(field_component_metadata), contiguous, intent(in) :: components(:)
    type(grid_field_aliases), intent(inout) :: aliases
    integer(int32) :: i, j, expected_active, expected_mp
    integer(int32), parameter :: first(61) = [ &
                                 1, 2, 3, 4, 5, 2158, 2157, 2156, 2155, 2154, 2153, 6, &
                                 7, 2150, 2149, 2148, 2147, 2146, 2145, 2144, 2143, 2142, 2141, 2140, &
                                 2139, 2138, 2137, 2136, 2135, 2134, 2133, 2132, 2131, 2130, 2129, 2128, &
                                 2127, 2126, 2125, 2124, 2123, 2122, 2121, 2120, 2119, 2118, 2117, 2116, &
                                 2115, 2114, 2113, 8, 2112, 2111, 2110, 2109, 2108, 2107, 2106, 2105, &
                                 2104]
    integer(int32), parameter :: count(61) = [ &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, &
                                 1]
    status = 2_int32
    if (size(components) /= 2163) return
    if (.not. grid_field_mode_supported()) return
    if (state%numflds /= 9 .or. state%numgpflds /= 9) return
    if (controls%nnogw /= 2) return
    if (controls%ngfl_ext /= 0) return
    if (controls%ngfl_forc /= 0) return
    if (controls%ngfl_ezdiag /= 0) return
    if (controls%nghg /= 0) return
    if (controls%nchem /= 0) return
    if (controls%naero /= 0) return
    if (controls%nera40 /= 0) return
    if (controls%nemis3d /= 0) return
    if (controls%nedrp /= 0) return
    if (controls%naerout /= 0) return
    if (controls%naeroclim /= 0) return
    if (controls%nuvp /= 0) return
    if (controls%nsldia /= 0) return
    if (controls%nlima /= 0) return
    if (controls%laerlisi /= 0) return
    do i = 1, 61
      do j = first(i), first(i) + count(i) - 1
        expected_active = 0; expected_mp = -99999
        if (j <= 9) then
          expected_active = 1; expected_mp = j
        end if
        if (components(j)%lactive /= expected_active .or. components(j)%mp /= expected_mp) return
      end do
    end do
    aliases%yq = 1
    aliases%yl = 2
    aliases%yi = 3
    aliases%ys = 4
    aliases%yr = 5
    aliases%yg = 2158
    aliases%yh = 2157
    aliases%ytke = 2156
    aliases%yefb1 = 2155
    aliases%yefb2 = 2154
    aliases%yefb3 = 2153
    aliases%ya = 6
    aliases%yo3 = 7
    aliases%ycpf = 2150
    aliases%yspf = 2149
    aliases%ysrc = 2148
    aliases%ycvgq = 2147
    aliases%ylconv = 2146
    aliases%yiconv = 2145
    aliases%yrconv = 2144
    aliases%ysconv = 2143
    aliases%ylrad = 2142
    aliases%yirad = 2141
    aliases%ysdsat = 2140
    aliases%ycvv = 2139
    aliases%yqva = 2138
    aliases%yuom = 2137
    aliases%yual = 2136
    aliases%ydom = 2135
    aliases%ydal = 2134
    aliases%yuen = 2133
    aliases%yunebh = 2132
    aliases%ytte = 2131
    aliases%ymxl = 2130
    aliases%yshtur = 2129
    aliases%yfqtur = 2128
    aliases%yfstur = 2127
    aliases%yrkth = 2126
    aliases%yrspec = 2125
    aliases%yrktqv = 2124
    aliases%yrktqc = 2123
    aliases%ylrch4 = 2122
    aliases%yphycty = 2121
    aliases%yfsd = 2120
    aliases%yext = component_alias_span(2119, 1)
    aliases%yforc = component_alias_span(2118, 1)
    aliases%yezdiag = component_alias_span(2117, 1)
    aliases%yghg = component_alias_span(2116, 1)
    aliases%ychem = component_alias_span(2115, 1)
    aliases%yaero = component_alias_span(2114, 1)
    aliases%yera40 = component_alias_span(2113, 1)
    aliases%ynogw = component_alias_span(8, 2)
    aliases%yemis3d = component_alias_span(2112, 1)
    aliases%yedrp = component_alias_span(2111, 1)
    aliases%yaeraot = component_alias_span(2110, 1)
    aliases%yaerlisi = component_alias_span(2109, 1)
    aliases%yaerout = component_alias_span(2108, 1)
    aliases%yaeroclim = component_alias_span(2107, 1)
    aliases%yuvp = component_alias_span(2106, 1)
    aliases%ysldia = component_alias_span(2105, 1)
    aliases%ylima = component_alias_span(2104, 1)
    status = 0_int32
  end function
end module grid_field_aliases_port
