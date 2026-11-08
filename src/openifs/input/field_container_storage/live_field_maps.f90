!> Build source-ordered integer field maps from live native owners.
module forecast_live_field_maps
  use iso_fortran_env, only: int32
  use forecast_grid_motion_types, only: native_grid_motion_state
  use grid_field_configuration_types_port, only: grid_field_configuration
  use surface_field_configuration_port, only: surface_field_registry
  implicit none
  type :: native_live_field_maps
    integer(int32) :: mt9_map(4200) = 0
    integer(int32) :: mt1_map(4200) = 0
    integer(int32) :: mt0_map(4200) = 0
    integer(int32) :: mpc_map(4200) = 0
    integer(int32) :: mpt_map(4200) = 0
    integer(int32) :: mt0_dl_map(4200) = 0
    integer(int32) :: mt0_dm_map(4200) = 0
    integer(int32) :: mt9_dl_map(4200) = 0
    integer(int32) :: mt9_dm_map(4200) = 0
    integer(int32) :: mt0_size(4200) = 0
  end type
contains
  integer(int32) function initialize_live_field_maps(output, motion, configuration, surface, undefined_field) result(status)
    type(native_live_field_maps), intent(inout) :: output
    type(native_grid_motion_state), intent(in) :: motion
    type(grid_field_configuration), intent(in) :: configuration
    type(surface_field_registry), intent(in) :: surface
    integer(int32), intent(in) :: undefined_field
    integer :: gi(44), sg(313), sf(313), se(313), i, j, a
    integer(int32) :: value
    status = 2
    if(configuration%alias_controls%nghg/=0.or.configuration%alias_controls%nchem/=0.or.configuration%alias_controls%naero/=0)return
    gi(1) = configuration%aliases%yq
    if (gi(1) < 1 .or. gi(1) > size(configuration%components)) return
    gi(2) = configuration%aliases%yo3
    if (gi(2) < 1 .or. gi(2) > size(configuration%components)) return
    gi(3) = configuration%aliases%yl
    if (gi(3) < 1 .or. gi(3) > size(configuration%components)) return
    gi(4) = configuration%aliases%yi
    if (gi(4) < 1 .or. gi(4) > size(configuration%components)) return
    gi(5) = configuration%aliases%ya
    if (gi(5) < 1 .or. gi(5) > size(configuration%components)) return
    gi(6) = configuration%aliases%ys
    if (gi(6) < 1 .or. gi(6) > size(configuration%components)) return
    gi(7) = configuration%aliases%yr
    if (gi(7) < 1 .or. gi(7) > size(configuration%components)) return
    gi(8) = configuration%aliases%yg
    if (gi(8) < 1 .or. gi(8) > size(configuration%components)) return
    gi(9) = configuration%aliases%yh
    if (gi(9) < 1 .or. gi(9) > size(configuration%components)) return
    gi(10) = configuration%aliases%ylrch4
    if (gi(10) < 1 .or. gi(10) > size(configuration%components)) return
    gi(11) = configuration%aliases%ylconv
    if (gi(11) < 1 .or. gi(11) > size(configuration%components)) return
    gi(12) = configuration%aliases%yiconv
    if (gi(12) < 1 .or. gi(12) > size(configuration%components)) return
    gi(13) = configuration%aliases%yrconv
    if (gi(13) < 1 .or. gi(13) > size(configuration%components)) return
    gi(14) = configuration%aliases%ysconv
    if (gi(14) < 1 .or. gi(14) > size(configuration%components)) return
    gi(15) = configuration%aliases%ytke
    if (gi(15) < 1 .or. gi(15) > size(configuration%components)) return
    gi(16) = configuration%aliases%ytte
    if (gi(16) < 1 .or. gi(16) > size(configuration%components)) return
    gi(17) = configuration%aliases%yefb1
    if (gi(17) < 1 .or. gi(17) > size(configuration%components)) return
    gi(18) = configuration%aliases%yefb2
    if (gi(18) < 1 .or. gi(18) > size(configuration%components)) return
    gi(19) = configuration%aliases%yefb3
    if (gi(19) < 1 .or. gi(19) > size(configuration%components)) return
    gi(20) = configuration%aliases%ymxl
    if (gi(20) < 1 .or. gi(20) > size(configuration%components)) return
    gi(21) = configuration%aliases%ysrc
    if (gi(21) < 1 .or. gi(21) > size(configuration%components)) return
    gi(22) = configuration%aliases%yshtur
    if (gi(22) < 1 .or. gi(22) > size(configuration%components)) return
    gi(23) = configuration%aliases%yfqtur
    if (gi(23) < 1 .or. gi(23) > size(configuration%components)) return
    gi(24) = configuration%aliases%yfstur
    if (gi(24) < 1 .or. gi(24) > size(configuration%components)) return
    gi(25) = configuration%aliases%ycvv
    if (gi(25) < 1 .or. gi(25) > size(configuration%components)) return
    gi(26) = configuration%aliases%yrkth
    if (gi(26) < 1 .or. gi(26) > size(configuration%components)) return
    gi(27) = configuration%aliases%yrktqv
    if (gi(27) < 1 .or. gi(27) > size(configuration%components)) return
    gi(28) = configuration%aliases%yrktqc
    if (gi(28) < 1 .or. gi(28) > size(configuration%components)) return
    gi(29) = configuration%aliases%ycpf
    if (gi(29) < 1 .or. gi(29) > size(configuration%components)) return
    gi(30) = configuration%aliases%yspf
    if (gi(30) < 1 .or. gi(30) > size(configuration%components)) return
    gi(31) = configuration%aliases%ycvgq
    if (gi(31) < 1 .or. gi(31) > size(configuration%components)) return
    gi(32) = configuration%aliases%ylrad
    if (gi(32) < 1 .or. gi(32) > size(configuration%components)) return
    gi(33) = configuration%aliases%yirad
    if (gi(33) < 1 .or. gi(33) > size(configuration%components)) return
    gi(34) = configuration%aliases%yrspec
    if (gi(34) < 1 .or. gi(34) > size(configuration%components)) return
    gi(35) = configuration%aliases%yuom
    if (gi(35) < 1 .or. gi(35) > size(configuration%components)) return
    gi(36) = configuration%aliases%yual
    if (gi(36) < 1 .or. gi(36) > size(configuration%components)) return
    gi(37) = configuration%aliases%ydom
    if (gi(37) < 1 .or. gi(37) > size(configuration%components)) return
    gi(38) = configuration%aliases%ydal
    if (gi(38) < 1 .or. gi(38) > size(configuration%components)) return
    gi(39) = configuration%aliases%yuen
    if (gi(39) < 1 .or. gi(39) > size(configuration%components)) return
    gi(40) = configuration%aliases%yunebh
    if (gi(40) < 1 .or. gi(40) > size(configuration%components)) return
    gi(41) = configuration%aliases%yext%first_index + 0
    if (gi(41) < 1 .or. gi(41) > size(configuration%components)) return
    gi(42) = configuration%aliases%yezdiag%first_index + 0
    if (gi(42) < 1 .or. gi(42) > size(configuration%components)) return
    gi(43) = configuration%aliases%ynogw%first_index + 0
    if (gi(43) < 1 .or. gi(43) > size(configuration%components)) return
    gi(44) = configuration%aliases%ynogw%first_index + 1
    if (gi(44) < 1 .or. gi(44) > size(configuration%components)) return
    if (surface%totals%registered > 0) then
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SB%YQ') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(1) = surface%aliases(a)%group
      sf(1) = surface%aliases(a)%first_field
      se(1) = max(0, surface%aliases(a)%extent1)
      if (sg(1) < 1 .or. sg(1) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(1))%fields)) return
      if (sf(1) < 1 .or. sf(1) > size(surface%groups(sg(1))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SB%YT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(2) = surface%aliases(a)%group
      sf(2) = surface%aliases(a)%first_field
      se(2) = max(0, surface%aliases(a)%extent1)
      if (sg(2) < 1 .or. sg(2) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(2))%fields)) return
      if (sf(2) < 1 .or. sf(2) > size(surface%groups(sg(2))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SB%YTL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(3) = surface%aliases(a)%group
      sf(3) = surface%aliases(a)%first_field
      se(3) = max(0, surface%aliases(a)%extent1)
      if (sg(3) < 1 .or. sg(3) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(3))%fields)) return
      if (sf(3) < 1 .or. sf(3) > size(surface%groups(sg(3))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SG%YF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(4) = surface%aliases(a)%group
      sf(4) = surface%aliases(a)%first_field
      se(4) = max(0, surface%aliases(a)%extent1)
      if (sg(4) < 1 .or. sg(4) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(4))%fields)) return
      if (sf(4) < 1 .or. sf(4) > size(surface%groups(sg(4))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SG%YA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(5) = surface%aliases(a)%group
      sf(5) = surface%aliases(a)%first_field
      se(5) = max(0, surface%aliases(a)%extent1)
      if (sg(5) < 1 .or. sg(5) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(5))%fields)) return
      if (sf(5) < 1 .or. sf(5) > size(surface%groups(sg(5))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SG%YR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(6) = surface%aliases(a)%group
      sf(6) = surface%aliases(a)%first_field
      se(6) = max(0, surface%aliases(a)%extent1)
      if (sg(6) < 1 .or. sg(6) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(6))%fields)) return
      if (sf(6) < 1 .or. sf(6) > size(surface%groups(sg(6))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SG%YT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(7) = surface%aliases(a)%group
      sf(7) = surface%aliases(a)%first_field
      se(7) = max(0, surface%aliases(a)%extent1)
      if (sg(7) < 1 .or. sg(7) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(7))%fields)) return
      if (sf(7) < 1 .or. sf(7) > size(surface%groups(sg(7))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SG%YW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(8) = surface%aliases(a)%group
      sf(8) = surface%aliases(a)%first_field
      se(8) = max(0, surface%aliases(a)%extent1)
      if (sg(8) < 1 .or. sg(8) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(8))%fields)) return
      if (sf(8) < 1 .or. sf(8) > size(surface%groups(sg(8))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SL%YLICT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(9) = surface%aliases(a)%group
      sf(9) = surface%aliases(a)%first_field
      se(9) = max(0, surface%aliases(a)%extent1)
      if (sg(9) < 1 .or. sg(9) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(9))%fields)) return
      if (sf(9) < 1 .or. sf(9) > size(surface%groups(sg(9))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SL%YLMLT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(10) = surface%aliases(a)%group
      sf(10) = surface%aliases(a)%first_field
      se(10) = max(0, surface%aliases(a)%extent1)
      if (sg(10) < 1 .or. sg(10) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(10))%fields)) return
      if (sf(10) < 1 .or. sf(10) > size(surface%groups(sg(10))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SL%YLTLT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(11) = surface%aliases(a)%group
      sf(11) = surface%aliases(a)%first_field
      se(11) = max(0, surface%aliases(a)%extent1)
      if (sg(11) < 1 .or. sg(11) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(11))%fields)) return
      if (sf(11) < 1 .or. sf(11) > size(surface%groups(sg(11))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SL%YLBLT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(12) = surface%aliases(a)%group
      sf(12) = surface%aliases(a)%first_field
      se(12) = max(0, surface%aliases(a)%extent1)
      if (sg(12) < 1 .or. sg(12) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(12))%fields)) return
      if (sf(12) < 1 .or. sf(12) > size(surface%groups(sg(12))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SL%YLSHF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(13) = surface%aliases(a)%group
      sf(13) = surface%aliases(a)%first_field
      se(13) = max(0, surface%aliases(a)%extent1)
      if (sg(13) < 1 .or. sg(13) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(13))%fields)) return
      if (sf(13) < 1 .or. sf(13) > size(surface%groups(sg(13))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SL%YLICD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(14) = surface%aliases(a)%group
      sf(14) = surface%aliases(a)%first_field
      se(14) = max(0, surface%aliases(a)%extent1)
      if (sg(14) < 1 .or. sg(14) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(14))%fields)) return
      if (sf(14) < 1 .or. sf(14) > size(surface%groups(sg(14))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_SL%YLMLD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(15) = surface%aliases(a)%group
      sf(15) = surface%aliases(a)%first_field
      se(15) = max(0, surface%aliases(a)%extent1)
      if (sg(15) < 1 .or. sg(15) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(15))%fields)) return
      if (sf(15) < 1 .or. sf(15) > size(surface%groups(sg(15))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_RR%YT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(16) = surface%aliases(a)%group
      sf(16) = surface%aliases(a)%first_field
      se(16) = max(0, surface%aliases(a)%extent1)
      if (sg(16) < 1 .or. sg(16) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(16))%fields)) return
      if (sf(16) < 1 .or. sf(16) > size(surface%groups(sg(16))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_RR%YW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(17) = surface%aliases(a)%group
      sf(17) = surface%aliases(a)%first_field
      se(17) = max(0, surface%aliases(a)%extent1)
      if (sg(17) < 1 .or. sg(17) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(17))%fields)) return
      if (sf(17) < 1 .or. sf(17) > size(surface%groups(sg(17))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_RR%YFC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(18) = surface%aliases(a)%group
      sf(18) = surface%aliases(a)%first_field
      se(18) = max(0, surface%aliases(a)%extent1)
      if (sg(18) < 1 .or. sg(18) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(18))%fields)) return
      if (sf(18) < 1 .or. sf(18) > size(surface%groups(sg(18))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_RR%YIC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(19) = surface%aliases(a)%group
      sf(19) = surface%aliases(a)%first_field
      se(19) = max(0, surface%aliases(a)%extent1)
      if (sg(19) < 1 .or. sg(19) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(19))%fields)) return
      if (sf(19) < 1 .or. sf(19) > size(surface%groups(sg(19))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_RR%YFP1') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(20) = surface%aliases(a)%group
      sf(20) = surface%aliases(a)%first_field
      se(20) = max(0, surface%aliases(a)%extent1)
      if (sg(20) < 1 .or. sg(20) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(20))%fields)) return
      if (sf(20) < 1 .or. sf(20) > size(surface%groups(sg(20))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_CL%YTCLS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(21) = surface%aliases(a)%group
      sf(21) = surface%aliases(a)%first_field
      se(21) = max(0, surface%aliases(a)%extent1)
      if (sg(21) < 1 .or. sg(21) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(21))%fields)) return
      if (sf(21) < 1 .or. sf(21) > size(surface%groups(sg(21))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_CL%YHUCLS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(22) = surface%aliases(a)%group
      sf(22) = surface%aliases(a)%first_field
      se(22) = max(0, surface%aliases(a)%extent1)
      if (sg(22) < 1 .or. sg(22) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(22))%fields)) return
      if (sf(22) < 1 .or. sf(22) > size(surface%groups(sg(22))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_OM%YTO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(23) = surface%aliases(a)%group
      sf(23) = surface%aliases(a)%first_field
      se(23) = max(0, surface%aliases(a)%extent1)
      if (sg(23) < 1 .or. sg(23) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(23))%fields)) return
      if (sf(23) < 1 .or. sf(23) > size(surface%groups(sg(23))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_OM%YSO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(24) = surface%aliases(a)%group
      sf(24) = surface%aliases(a)%first_field
      se(24) = max(0, surface%aliases(a)%extent1)
      if (sg(24) < 1 .or. sg(24) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(24))%fields)) return
      if (sf(24) < 1 .or. sf(24) > size(surface%groups(sg(24))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_OM%YUO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(25) = surface%aliases(a)%group
      sf(25) = surface%aliases(a)%first_field
      se(25) = max(0, surface%aliases(a)%extent1)
      if (sg(25) < 1 .or. sg(25) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(25))%fields)) return
      if (sf(25) < 1 .or. sf(25) > size(surface%groups(sg(25))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSP_OM%YVO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(26) = surface%aliases(a)%group
      sf(26) = surface%aliases(a)%first_field
      se(26) = max(0, surface%aliases(a)%extent1)
      if (sg(26) < 1 .or. sg(26) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(26))%fields)) return
      if (sf(26) < 1 .or. sf(26) > size(surface%groups(sg(26))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YZ0F') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(27) = surface%aliases(a)%group
      sf(27) = surface%aliases(a)%first_field
      se(27) = max(0, surface%aliases(a)%extent1)
      if (sg(27) < 1 .or. sg(27) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(27))%fields)) return
      if (sf(27) < 1 .or. sf(27) > size(surface%groups(sg(27))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALBF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(28) = surface%aliases(a)%group
      sf(28) = surface%aliases(a)%first_field
      se(28) = max(0, surface%aliases(a)%extent1)
      if (sg(28) < 1 .or. sg(28) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(28))%fields)) return
      if (sf(28) < 1 .or. sf(28) > size(surface%groups(sg(28))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YEMISF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(29) = surface%aliases(a)%group
      sf(29) = surface%aliases(a)%first_field
      se(29) = max(0, surface%aliases(a)%extent1)
      if (sg(29) < 1 .or. sg(29) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(29))%fields)) return
      if (sf(29) < 1 .or. sf(29) > size(surface%groups(sg(29))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YGETRL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(30) = surface%aliases(a)%group
      sf(30) = surface%aliases(a)%first_field
      se(30) = max(0, surface%aliases(a)%extent1)
      if (sg(30) < 1 .or. sg(30) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(30))%fields)) return
      if (sf(30) < 1 .or. sf(30) > size(surface%groups(sg(30))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YLSM') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(31) = surface%aliases(a)%group
      sf(31) = surface%aliases(a)%first_field
      se(31) = max(0, surface%aliases(a)%extent1)
      if (sg(31) < 1 .or. sg(31) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(31))%fields)) return
      if (sf(31) < 1 .or. sf(31) > size(surface%groups(sg(31))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YVEG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(32) = surface%aliases(a)%group
      sf(32) = surface%aliases(a)%first_field
      se(32) = max(0, surface%aliases(a)%extent1)
      if (sg(32) < 1 .or. sg(32) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(32))%fields)) return
      if (sf(32) < 1 .or. sf(32) > size(surface%groups(sg(32))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YVRLAN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(33) = surface%aliases(a)%group
      sf(33) = surface%aliases(a)%first_field
      se(33) = max(0, surface%aliases(a)%extent1)
      if (sg(33) < 1 .or. sg(33) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(33))%fields)) return
      if (sf(33) < 1 .or. sf(33) > size(surface%groups(sg(33))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YVRLDI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(34) = surface%aliases(a)%group
      sf(34) = surface%aliases(a)%first_field
      se(34) = max(0, surface%aliases(a)%extent1)
      if (sg(34) < 1 .or. sg(34) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(34))%fields)) return
      if (sf(34) < 1 .or. sf(34) > size(surface%groups(sg(34))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YSIG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(35) = surface%aliases(a)%group
      sf(35) = surface%aliases(a)%first_field
      se(35) = max(0, surface%aliases(a)%extent1)
      if (sg(35) < 1 .or. sg(35) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(35))%fields)) return
      if (sf(35) < 1 .or. sf(35) > size(surface%groups(sg(35))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALBSF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(36) = surface%aliases(a)%group
      sf(36) = surface%aliases(a)%first_field
      se(36) = max(0, surface%aliases(a)%extent1)
      if (sg(36) < 1 .or. sg(36) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(36))%fields)) return
      if (sf(36) < 1 .or. sf(36) > size(surface%groups(sg(36))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YLAN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(37) = surface%aliases(a)%group
      sf(37) = surface%aliases(a)%first_field
      se(37) = max(0, surface%aliases(a)%extent1)
      if (sg(37) < 1 .or. sg(37) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(37))%fields)) return
      if (sf(37) < 1 .or. sf(37) > size(surface%groups(sg(37))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YSST') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(38) = surface%aliases(a)%group
      sf(38) = surface%aliases(a)%first_field
      se(38) = max(0, surface%aliases(a)%extent1)
      if (sg(38) < 1 .or. sg(38) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(38))%fields)) return
      if (sf(38) < 1 .or. sf(38) > size(surface%groups(sg(38))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YSSS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(39) = surface%aliases(a)%group
      sf(39) = surface%aliases(a)%first_field
      se(39) = max(0, surface%aliases(a)%extent1)
      if (sg(39) < 1 .or. sg(39) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(39))%fields)) return
      if (sf(39) < 1 .or. sf(39) > size(surface%groups(sg(39))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YLZ0H') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(40) = surface%aliases(a)%group
      sf(40) = surface%aliases(a)%first_field
      se(40) = max(0, surface%aliases(a)%extent1)
      if (sg(40) < 1 .or. sg(40) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(40))%fields)) return
      if (sf(40) < 1 .or. sf(40) > size(surface%groups(sg(40))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCVL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(41) = surface%aliases(a)%group
      sf(41) = surface%aliases(a)%first_field
      se(41) = max(0, surface%aliases(a)%extent1)
      if (sg(41) < 1 .or. sg(41) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(41))%fields)) return
      if (sf(41) < 1 .or. sf(41) > size(surface%groups(sg(41))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCO2TYP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(42) = surface%aliases(a)%group
      sf(42) = surface%aliases(a)%first_field
      se(42) = max(0, surface%aliases(a)%extent1)
      if (sg(42) < 1 .or. sg(42) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(42))%fields)) return
      if (sf(42) < 1 .or. sf(42) > size(surface%groups(sg(42))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCVH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(43) = surface%aliases(a)%group
      sf(43) = surface%aliases(a)%first_field
      se(43) = max(0, surface%aliases(a)%extent1)
      if (sg(43) < 1 .or. sg(43) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(43))%fields)) return
      if (sf(43) < 1 .or. sf(43) > size(surface%groups(sg(43))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YFWET') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(44) = surface%aliases(a)%group
      sf(44) = surface%aliases(a)%first_field
      se(44) = max(0, surface%aliases(a)%extent1)
      if (sg(44) < 1 .or. sg(44) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(44))%fields)) return
      if (sf(44) < 1 .or. sf(44) > size(surface%groups(sg(44))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCUR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(45) = surface%aliases(a)%group
      sf(45) = surface%aliases(a)%first_field
      se(45) = max(0, surface%aliases(a)%extent1)
      if (sg(45) < 1 .or. sg(45) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(45))%fields)) return
      if (sf(45) < 1 .or. sf(45) > size(surface%groups(sg(45))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YTVL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(46) = surface%aliases(a)%group
      sf(46) = surface%aliases(a)%first_field
      se(46) = max(0, surface%aliases(a)%extent1)
      if (sg(46) < 1 .or. sg(46) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(46))%fields)) return
      if (sf(46) < 1 .or. sf(46) > size(surface%groups(sg(46))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YTVH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(47) = surface%aliases(a)%group
      sf(47) = surface%aliases(a)%first_field
      se(47) = max(0, surface%aliases(a)%extent1)
      if (sg(47) < 1 .or. sg(47) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(47))%fields)) return
      if (sf(47) < 1 .or. sf(47) > size(surface%groups(sg(47))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YLAIL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(48) = surface%aliases(a)%group
      sf(48) = surface%aliases(a)%first_field
      se(48) = max(0, surface%aliases(a)%extent1)
      if (sg(48) < 1 .or. sg(48) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(48))%fields)) return
      if (sf(48) < 1 .or. sf(48) > size(surface%groups(sg(48))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YLAIH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(49) = surface%aliases(a)%group
      sf(49) = surface%aliases(a)%first_field
      se(49) = max(0, surface%aliases(a)%extent1)
      if (sg(49) < 1 .or. sg(49) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(49))%fields)) return
      if (sf(49) < 1 .or. sf(49) > size(surface%groups(sg(49))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YSOTY') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(50) = surface%aliases(a)%group
      sf(50) = surface%aliases(a)%first_field
      se(50) = max(0, surface%aliases(a)%extent1)
      if (sg(50) < 1 .or. sg(50) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(50))%fields)) return
      if (sf(50) < 1 .or. sf(50) > size(surface%groups(sg(50))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCLK') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(51) = surface%aliases(a)%group
      sf(51) = surface%aliases(a)%first_field
      se(51) = max(0, surface%aliases(a)%extent1)
      if (sg(51) < 1 .or. sg(51) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(51))%fields)) return
      if (sf(51) < 1 .or. sf(51) > size(surface%groups(sg(51))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YDL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(52) = surface%aliases(a)%group
      sf(52) = surface%aliases(a)%first_field
      se(52) = max(0, surface%aliases(a)%extent1)
      if (sg(52) < 1 .or. sg(52) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(52))%fields)) return
      if (sf(52) < 1 .or. sf(52) > size(surface%groups(sg(52))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(53) = surface%aliases(a)%group
      sf(53) = surface%aliases(a)%first_field
      se(53) = max(0, surface%aliases(a)%extent1)
      if (sg(53) < 1 .or. sg(53) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(53))%fields)) return
      if (sf(53) < 1 .or. sf(53) > size(surface%groups(sg(53))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YUCUR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(54) = surface%aliases(a)%group
      sf(54) = surface%aliases(a)%first_field
      se(54) = max(0, surface%aliases(a)%extent1)
      if (sg(54) < 1 .or. sg(54) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(54))%fields)) return
      if (sf(54) < 1 .or. sf(54) > size(surface%groups(sg(54))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YVCUR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(55) = surface%aliases(a)%group
      sf(55) = surface%aliases(a)%first_field
      se(55) = max(0, surface%aliases(a)%extent1)
      if (sg(55) < 1 .or. sg(55) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(55))%fields)) return
      if (sf(55) < 1 .or. sf(55) > size(surface%groups(sg(55))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YZ0RLF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(56) = surface%aliases(a)%group
      sf(56) = surface%aliases(a)%first_field
      se(56) = max(0, surface%aliases(a)%extent1)
      if (sg(56) < 1 .or. sg(56) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(56))%fields)) return
      if (sf(56) < 1 .or. sf(56) > size(surface%groups(sg(56))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCGPP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(57) = surface%aliases(a)%group
      sf(57) = surface%aliases(a)%first_field
      se(57) = max(0, surface%aliases(a)%extent1)
      if (sg(57) < 1 .or. sg(57) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(57))%fields)) return
      if (sf(57) < 1 .or. sf(57) > size(surface%groups(sg(57))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCREC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(58) = surface%aliases(a)%group
      sf(58) = surface%aliases(a)%first_field
      se(58) = max(0, surface%aliases(a)%extent1)
      if (sg(58) < 1 .or. sg(58) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(58))%fields)) return
      if (sf(58) < 1 .or. sf(58) > size(surface%groups(sg(58))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YSDFOR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(59) = surface%aliases(a)%group
      sf(59) = surface%aliases(a)%first_field
      se(59) = max(0, surface%aliases(a)%extent1)
      if (sg(59) < 1 .or. sg(59) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(59))%fields)) return
      if (sf(59) < 1 .or. sf(59) > size(surface%groups(sg(59))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALUVP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(60) = surface%aliases(a)%group
      sf(60) = surface%aliases(a)%first_field
      se(60) = max(0, surface%aliases(a)%extent1)
      if (sg(60) < 1 .or. sg(60) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(60))%fields)) return
      if (sf(60) < 1 .or. sf(60) > size(surface%groups(sg(60))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALUVD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(61) = surface%aliases(a)%group
      sf(61) = surface%aliases(a)%first_field
      se(61) = max(0, surface%aliases(a)%extent1)
      if (sg(61) < 1 .or. sg(61) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(61))%fields)) return
      if (sf(61) < 1 .or. sf(61) > size(surface%groups(sg(61))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALNIP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(62) = surface%aliases(a)%group
      sf(62) = surface%aliases(a)%first_field
      se(62) = max(0, surface%aliases(a)%extent1)
      if (sg(62) < 1 .or. sg(62) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(62))%fields)) return
      if (sf(62) < 1 .or. sf(62) > size(surface%groups(sg(62))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALNID') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(63) = surface%aliases(a)%group
      sf(63) = surface%aliases(a)%first_field
      se(63) = max(0, surface%aliases(a)%extent1)
      if (sg(63) < 1 .or. sg(63) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(63))%fields)) return
      if (sf(63) < 1 .or. sf(63) > size(surface%groups(sg(63))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALUVI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(64) = surface%aliases(a)%group
      sf(64) = surface%aliases(a)%first_field
      se(64) = max(0, surface%aliases(a)%extent1)
      if (sg(64) < 1 .or. sg(64) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(64))%fields)) return
      if (sf(64) < 1 .or. sf(64) > size(surface%groups(sg(64))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALNII') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(65) = surface%aliases(a)%group
      sf(65) = surface%aliases(a)%first_field
      se(65) = max(0, surface%aliases(a)%extent1)
      if (sg(65) < 1 .or. sg(65) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(65))%fields)) return
      if (sf(65) < 1 .or. sf(65) > size(surface%groups(sg(65))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALUVV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(66) = surface%aliases(a)%group
      sf(66) = surface%aliases(a)%first_field
      se(66) = max(0, surface%aliases(a)%extent1)
      if (sg(66) < 1 .or. sg(66) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(66))%fields)) return
      if (sf(66) < 1 .or. sf(66) > size(surface%groups(sg(66))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALNIV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(67) = surface%aliases(a)%group
      sf(67) = surface%aliases(a)%first_field
      se(67) = max(0, surface%aliases(a)%extent1)
      if (sg(67) < 1 .or. sg(67) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(67))%fields)) return
      if (sf(67) < 1 .or. sf(67) > size(surface%groups(sg(67))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALUVG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(68) = surface%aliases(a)%group
      sf(68) = surface%aliases(a)%first_field
      se(68) = max(0, surface%aliases(a)%extent1)
      if (sg(68) < 1 .or. sg(68) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(68))%fields)) return
      if (sf(68) < 1 .or. sf(68) > size(surface%groups(sg(68))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YALNIG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(69) = surface%aliases(a)%group
      sf(69) = surface%aliases(a)%first_field
      se(69) = max(0, surface%aliases(a)%extent1)
      if (sg(69) < 1 .or. sg(69) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(69))%fields)) return
      if (sf(69) < 1 .or. sf(69) > size(surface%groups(sg(69))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YFP1') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(70) = surface%aliases(a)%group
      sf(70) = surface%aliases(a)%first_field
      se(70) = max(0, surface%aliases(a)%extent1)
      if (sg(70) < 1 .or. sg(70) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(70))%fields)) return
      if (sf(70) < 1 .or. sf(70) > size(surface%groups(sg(70))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YSO2DD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(71) = surface%aliases(a)%group
      sf(71) = surface%aliases(a)%first_field
      se(71) = max(0, surface%aliases(a)%extent1)
      if (sg(71) < 1 .or. sg(71) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(71))%fields)) return
      if (sf(71) < 1 .or. sf(71) > size(surface%groups(sg(71))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YDMSO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(72) = surface%aliases(a)%group
      sf(72) = surface%aliases(a)%first_field
      se(72) = max(0, surface%aliases(a)%extent1)
      if (sg(72) < 1 .or. sg(72) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(72))%fields)) return
      if (sf(72) < 1 .or. sf(72) > size(surface%groups(sg(72))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YURBF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(73) = surface%aliases(a)%group
      sf(73) = surface%aliases(a)%first_field
      se(73) = max(0, surface%aliases(a)%extent1)
      if (sg(73) < 1 .or. sg(73) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(73))%fields)) return
      if (sf(73) < 1 .or. sf(73) > size(surface%groups(sg(73))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YFCA1') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(74) = surface%aliases(a)%group
      sf(74) = surface%aliases(a)%first_field
      se(74) = max(0, surface%aliases(a)%extent1)
      if (sg(74) < 1 .or. sg(74) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(74))%fields)) return
      if (sf(74) < 1 .or. sf(74) > size(surface%groups(sg(74))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YFCA2') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(75) = surface%aliases(a)%group
      sf(75) = surface%aliases(a)%first_field
      se(75) = max(0, surface%aliases(a)%extent1)
      if (sg(75) < 1 .or. sg(75) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(75))%fields)) return
      if (sf(75) < 1 .or. sf(75) > size(surface%groups(sg(75))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YAERDEP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(76) = surface%aliases(a)%group
      sf(76) = surface%aliases(a)%first_field
      se(76) = max(0, surface%aliases(a)%extent1)
      if (sg(76) < 1 .or. sg(76) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(76))%fields)) return
      if (sf(76) < 1 .or. sf(76) > size(surface%groups(sg(76))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YAERLTS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(77) = surface%aliases(a)%group
      sf(77) = surface%aliases(a)%first_field
      se(77) = max(0, surface%aliases(a)%extent1)
      if (sg(77) < 1 .or. sg(77) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(77))%fields)) return
      if (sf(77) < 1 .or. sf(77) > size(surface%groups(sg(77))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YAERSCC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(78) = surface%aliases(a)%group
      sf(78) = surface%aliases(a)%first_field
      se(78) = max(0, surface%aliases(a)%extent1)
      if (sg(78) < 1 .or. sg(78) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(78))%fields)) return
      if (sf(78) < 1 .or. sf(78) > size(surface%groups(sg(78))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YDSF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(79) = surface%aliases(a)%group
      sf(79) = surface%aliases(a)%first_field
      se(79) = max(0, surface%aliases(a)%extent1)
      if (sg(79) < 1 .or. sg(79) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(79))%fields)) return
      if (sf(79) < 1 .or. sf(79) > size(surface%groups(sg(79))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YDSZ') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(80) = surface%aliases(a)%group
      sf(80) = surface%aliases(a)%first_field
      se(80) = max(0, surface%aliases(a)%extent1)
      if (sg(80) < 1 .or. sg(80) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(80))%fields)) return
      if (sf(80) < 1 .or. sf(80) > size(surface%groups(sg(80))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCHEMFLXO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(81) = surface%aliases(a)%group
      sf(81) = surface%aliases(a)%first_field
      se(81) = max(0, surface%aliases(a)%extent1)
      if (sg(81) < 1 .or. sg(81) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(81))%fields)) return
      if (sf(81) < 1 .or. sf(81) > size(surface%groups(sg(81))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCHEMWDFLX') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(82) = surface%aliases(a)%group
      sf(82) = surface%aliases(a)%first_field
      se(82) = max(0, surface%aliases(a)%extent1)
      if (sg(82) < 1 .or. sg(82) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(82))%fields)) return
      if (sf(82) < 1 .or. sf(82) > size(surface%groups(sg(82))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCHEMDDFLX') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(83) = surface%aliases(a)%group
      sf(83) = surface%aliases(a)%first_field
      se(83) = max(0, surface%aliases(a)%extent1)
      if (sg(83) < 1 .or. sg(83) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(83))%fields)) return
      if (sf(83) < 1 .or. sf(83) > size(surface%groups(sg(83))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YCHEMDV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(84) = surface%aliases(a)%group
      sf(84) = surface%aliases(a)%first_field
      se(84) = max(0, surface%aliases(a)%extent1)
      if (sg(84) < 1 .or. sg(84) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(84))%fields)) return
      if (sf(84) < 1 .or. sf(84) > size(surface%groups(sg(84))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YNUDM') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(85) = surface%aliases(a)%group
      sf(85) = surface%aliases(a)%first_field
      se(85) = max(0, surface%aliases(a)%extent1)
      if (sg(85) < 1 .or. sg(85) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(85))%fields)) return
      if (sf(85) < 1 .or. sf(85) > size(surface%groups(sg(85))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YEMIS2D') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(86) = surface%aliases(a)%group
      sf(86) = surface%aliases(a)%first_field
      se(86) = max(0, surface%aliases(a)%extent1)
      if (sg(86) < 1 .or. sg(86) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(86))%fields)) return
      if (sf(86) < 1 .or. sf(86) > size(surface%groups(sg(86))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VF%YEMIS2DAUX') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(87) = surface%aliases(a)%group
      sf(87) = surface%aliases(a)%first_field
      se(87) = max(0, surface%aliases(a)%extent1)
      if (sg(87) < 1 .or. sg(87) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(87))%fields)) return
      if (sf(87) < 1 .or. sf(87) > size(surface%groups(sg(87))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VP%YTPC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(88) = surface%aliases(a)%group
      sf(88) = surface%aliases(a)%first_field
      se(88) = max(0, surface%aliases(a)%extent1)
      if (sg(88) < 1 .or. sg(88) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(88))%fields)) return
      if (sf(88) < 1 .or. sf(88) > size(surface%groups(sg(88))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VP%YWPC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(89) = surface%aliases(a)%group
      sf(89) = surface%aliases(a)%first_field
      se(89) = max(0, surface%aliases(a)%extent1)
      if (sg(89) < 1 .or. sg(89) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(89))%fields)) return
      if (sf(89) < 1 .or. sf(89) > size(surface%groups(sg(89))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YARG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(90) = surface%aliases(a)%group
      sf(90) = surface%aliases(a)%first_field
      se(90) = max(0, surface%aliases(a)%extent1)
      if (sg(90) < 1 .or. sg(90) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(90))%fields)) return
      if (sf(90) < 1 .or. sf(90) > size(surface%groups(sg(90))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YSAB') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(91) = surface%aliases(a)%group
      sf(91) = surface%aliases(a)%first_field
      se(91) = max(0, surface%aliases(a)%extent1)
      if (sg(91) < 1 .or. sg(91) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(91))%fields)) return
      if (sf(91) < 1 .or. sf(91) > size(surface%groups(sg(91))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YD2') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(92) = surface%aliases(a)%group
      sf(92) = surface%aliases(a)%first_field
      se(92) = max(0, surface%aliases(a)%extent1)
      if (sg(92) < 1 .or. sg(92) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(92))%fields)) return
      if (sf(92) < 1 .or. sf(92) > size(surface%groups(sg(92))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YIVEG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(93) = surface%aliases(a)%group
      sf(93) = surface%aliases(a)%first_field
      se(93) = max(0, surface%aliases(a)%extent1)
      if (sg(93) < 1 .or. sg(93) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(93))%fields)) return
      if (sf(93) < 1 .or. sf(93) > size(surface%groups(sg(93))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YRSMIN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(94) = surface%aliases(a)%group
      sf(94) = surface%aliases(a)%first_field
      se(94) = max(0, surface%aliases(a)%extent1)
      if (sg(94) < 1 .or. sg(94) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(94))%fields)) return
      if (sf(94) < 1 .or. sf(94) > size(surface%groups(sg(94))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YLAI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(95) = surface%aliases(a)%group
      sf(95) = surface%aliases(a)%first_field
      se(95) = max(0, surface%aliases(a)%extent1)
      if (sg(95) < 1 .or. sg(95) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(95))%fields)) return
      if (sf(95) < 1 .or. sf(95) > size(surface%groups(sg(95))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YHV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(96) = surface%aliases(a)%group
      sf(96) = surface%aliases(a)%first_field
      se(96) = max(0, surface%aliases(a)%extent1)
      if (sg(96) < 1 .or. sg(96) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(96))%fields)) return
      if (sf(96) < 1 .or. sf(96) > size(surface%groups(sg(96))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YZ0H') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(97) = surface%aliases(a)%group
      sf(97) = surface%aliases(a)%first_field
      se(97) = max(0, surface%aliases(a)%extent1)
      if (sg(97) < 1 .or. sg(97) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(97))%fields)) return
      if (sf(97) < 1 .or. sf(97) > size(surface%groups(sg(97))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YALS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(98) = surface%aliases(a)%group
      sf(98) = surface%aliases(a)%first_field
      se(98) = max(0, surface%aliases(a)%extent1)
      if (sg(98) < 1 .or. sg(98) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(98))%fields)) return
      if (sf(98) < 1 .or. sf(98) > size(surface%groups(sg(98))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VV%YALV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(99) = surface%aliases(a)%group
      sf(99) = surface%aliases(a)%first_field
      se(99) = max(0, surface%aliases(a)%extent1)
      if (sg(99) < 1 .or. sg(99) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(99))%fields)) return
      if (sf(99) < 1 .or. sf(99) > size(surface%groups(sg(99))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VN%YTOP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(100) = surface%aliases(a)%group
      sf(100) = surface%aliases(a)%first_field
      se(100) = max(0, surface%aliases(a)%extent1)
      if (sg(100) < 1 .or. sg(100) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(100))%fields)) return
      if (sf(100) < 1 .or. sf(100) > size(surface%groups(sg(100))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VN%YBAS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(101) = surface%aliases(a)%group
      sf(101) = surface%aliases(a)%first_field
      se(101) = max(0, surface%aliases(a)%extent1)
      if (sg(101) < 1 .or. sg(101) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(101))%fields)) return
      if (sf(101) < 1 .or. sf(101) > size(surface%groups(sg(101))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VN%YACPR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(102) = surface%aliases(a)%group
      sf(102) = surface%aliases(a)%first_field
      se(102) = max(0, surface%aliases(a)%extent1)
      if (sg(102) < 1 .or. sg(102) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(102))%fields)) return
      if (sf(102) < 1 .or. sf(102) > size(surface%groups(sg(102))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VN%YACCPR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(103) = surface%aliases(a)%group
      sf(103) = surface%aliases(a)%first_field
      se(103) = max(0, surface%aliases(a)%extent1)
      if (sg(103) < 1 .or. sg(103) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(103))%fields)) return
      if (sf(103) < 1 .or. sf(103) > size(surface%groups(sg(103))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VN%YACCPR5') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(104) = surface%aliases(a)%group
      sf(104) = surface%aliases(a)%first_field
      se(104) = max(0, surface%aliases(a)%extent1)
      if (sg(104) < 1 .or. sg(104) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(104))%fields)) return
      if (sf(104) < 1 .or. sf(104) > size(surface%groups(sg(104))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VH%YTCCH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(105) = surface%aliases(a)%group
      sf(105) = surface%aliases(a)%first_field
      se(105) = max(0, surface%aliases(a)%extent1)
      if (sg(105) < 1 .or. sg(105) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(105))%fields)) return
      if (sf(105) < 1 .or. sf(105) > size(surface%groups(sg(105))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VH%YSCCH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(106) = surface%aliases(a)%group
      sf(106) = surface%aliases(a)%first_field
      se(106) = max(0, surface%aliases(a)%extent1)
      if (sg(106) < 1 .or. sg(106) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(106))%fields)) return
      if (sf(106) < 1 .or. sf(106) > size(surface%groups(sg(106))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VH%YBCCH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(107) = surface%aliases(a)%group
      sf(107) = surface%aliases(a)%first_field
      se(107) = max(0, surface%aliases(a)%extent1)
      if (sg(107) < 1 .or. sg(107) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(107))%fields)) return
      if (sf(107) < 1 .or. sf(107) > size(surface%groups(sg(107))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VH%YPBLH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(108) = surface%aliases(a)%group
      sf(108) = surface%aliases(a)%first_field
      se(108) = max(0, surface%aliases(a)%extent1)
      if (sg(108) < 1 .or. sg(108) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(108))%fields)) return
      if (sf(108) < 1 .or. sf(108) > size(surface%groups(sg(108))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VH%YSPSH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(109) = surface%aliases(a)%group
      sf(109) = surface%aliases(a)%first_field
      se(109) = max(0, surface%aliases(a)%extent1)
      if (sg(109) < 1 .or. sg(109) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(109))%fields)) return
      if (sf(109) < 1 .or. sf(109) > size(surface%groups(sg(109))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VA%YSEA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(110) = surface%aliases(a)%group
      sf(110) = surface%aliases(a)%first_field
      se(110) = max(0, surface%aliases(a)%extent1)
      if (sg(110) < 1 .or. sg(110) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(110))%fields)) return
      if (sf(110) < 1 .or. sf(110) > size(surface%groups(sg(110))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VA%YLAN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(111) = surface%aliases(a)%group
      sf(111) = surface%aliases(a)%first_field
      se(111) = max(0, surface%aliases(a)%extent1)
      if (sg(111) < 1 .or. sg(111) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(111))%fields)) return
      if (sf(111) < 1 .or. sf(111) > size(surface%groups(sg(111))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VA%YSOO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(112) = surface%aliases(a)%group
      sf(112) = surface%aliases(a)%first_field
      se(112) = max(0, surface%aliases(a)%extent1)
      if (sg(112) < 1 .or. sg(112) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(112))%fields)) return
      if (sf(112) < 1 .or. sf(112) > size(surface%groups(sg(112))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VA%YDES') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(113) = surface%aliases(a)%group
      sf(113) = surface%aliases(a)%first_field
      se(113) = max(0, surface%aliases(a)%extent1)
      if (sg(113) < 1 .or. sg(113) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(113))%fields)) return
      if (sf(113) < 1 .or. sf(113) > size(surface%groups(sg(113))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VA%YSUL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(114) = surface%aliases(a)%group
      sf(114) = surface%aliases(a)%first_field
      se(114) = max(0, surface%aliases(a)%extent1)
      if (sg(114) < 1 .or. sg(114) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(114))%fields)) return
      if (sf(114) < 1 .or. sf(114) > size(surface%groups(sg(114))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VA%YVOL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(115) = surface%aliases(a)%group
      sf(115) = surface%aliases(a)%first_field
      se(115) = max(0, surface%aliases(a)%extent1)
      if (sg(115) < 1 .or. sg(115) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(115))%fields)) return
      if (sf(115) < 1 .or. sf(115) > size(surface%groups(sg(115))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VC%YA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(116) = surface%aliases(a)%group
      sf(116) = surface%aliases(a)%first_field
      se(116) = max(0, surface%aliases(a)%extent1)
      if (sg(116) < 1 .or. sg(116) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(116))%fields)) return
      if (sf(116) < 1 .or. sf(116) > size(surface%groups(sg(116))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VC%YB') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(117) = surface%aliases(a)%group
      sf(117) = surface%aliases(a)%first_field
      se(117) = max(0, surface%aliases(a)%extent1)
      if (sg(117) < 1 .or. sg(117) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(117))%fields)) return
      if (sf(117) < 1 .or. sf(117) > size(surface%groups(sg(117))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VC%YC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(118) = surface%aliases(a)%group
      sf(118) = surface%aliases(a)%first_field
      se(118) = max(0, surface%aliases(a)%extent1)
      if (sg(118) < 1 .or. sg(118) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(118))%fields)) return
      if (sf(118) < 1 .or. sf(118) > size(surface%groups(sg(118))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V2%YOCDEP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(119) = surface%aliases(a)%group
      sf(119) = surface%aliases(a)%first_field
      se(119) = max(0, surface%aliases(a)%extent1)
      if (sg(119) < 1 .or. sg(119) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(119))%fields)) return
      if (sf(119) < 1 .or. sf(119) > size(surface%groups(sg(119))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V2%YUSTRC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(120) = surface%aliases(a)%group
      sf(120) = surface%aliases(a)%first_field
      se(120) = max(0, surface%aliases(a)%extent1)
      if (sg(120) < 1 .or. sg(120) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(120))%fields)) return
      if (sf(120) < 1 .or. sf(120) > size(surface%groups(sg(120))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V2%YVSTRC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(121) = surface%aliases(a)%group
      sf(121) = surface%aliases(a)%first_field
      se(121) = max(0, surface%aliases(a)%extent1)
      if (sg(121) < 1 .or. sg(121) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(121))%fields)) return
      if (sf(121) < 1 .or. sf(121) > size(surface%groups(sg(121))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YDIFM') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(122) = surface%aliases(a)%group
      sf(122) = surface%aliases(a)%first_field
      se(122) = max(0, surface%aliases(a)%extent1)
      if (sg(122) < 1 .or. sg(122) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(122))%fields)) return
      if (sf(122) < 1 .or. sf(122) > size(surface%groups(sg(122))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YDIFT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(123) = surface%aliases(a)%group
      sf(123) = surface%aliases(a)%first_field
      se(123) = max(0, surface%aliases(a)%extent1)
      if (sg(123) < 1 .or. sg(123) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(123))%fields)) return
      if (sf(123) < 1 .or. sf(123) > size(surface%groups(sg(123))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YDIFS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(124) = surface%aliases(a)%group
      sf(124) = surface%aliases(a)%first_field
      se(124) = max(0, surface%aliases(a)%extent1)
      if (sg(124) < 1 .or. sg(124) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(124))%fields)) return
      if (sf(124) < 1 .or. sf(124) > size(surface%groups(sg(124))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YADVT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(125) = surface%aliases(a)%group
      sf(125) = surface%aliases(a)%first_field
      se(125) = max(0, surface%aliases(a)%extent1)
      if (sg(125) < 1 .or. sg(125) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(125))%fields)) return
      if (sf(125) < 1 .or. sf(125) > size(surface%groups(sg(125))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YADVS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(126) = surface%aliases(a)%group
      sf(126) = surface%aliases(a)%first_field
      se(126) = max(0, surface%aliases(a)%extent1)
      if (sg(126) < 1 .or. sg(126) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(126))%fields)) return
      if (sf(126) < 1 .or. sf(126) > size(surface%groups(sg(126))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YTRI0') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(127) = surface%aliases(a)%group
      sf(127) = surface%aliases(a)%first_field
      se(127) = max(0, surface%aliases(a)%extent1)
      if (sg(127) < 1 .or. sg(127) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(127))%fields)) return
      if (sf(127) < 1 .or. sf(127) > size(surface%groups(sg(127))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YTRI1') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(128) = surface%aliases(a)%group
      sf(128) = surface%aliases(a)%first_field
      se(128) = max(0, surface%aliases(a)%extent1)
      if (sg(128) < 1 .or. sg(128) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(128))%fields)) return
      if (sf(128) < 1 .or. sf(128) > size(surface%groups(sg(128))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YSWDK') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(129) = surface%aliases(a)%group
      sf(129) = surface%aliases(a)%first_field
      se(129) = max(0, surface%aliases(a)%extent1)
      if (sg(129) < 1 .or. sg(129) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(129))%fields)) return
      if (sf(129) < 1 .or. sf(129) > size(surface%groups(sg(129))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YZO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(130) = surface%aliases(a)%group
      sf(130) = surface%aliases(a)%first_field
      se(130) = max(0, surface%aliases(a)%extent1)
      if (sg(130) < 1 .or. sg(130) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(130))%fields)) return
      if (sf(130) < 1 .or. sf(130) > size(surface%groups(sg(130))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YHO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(131) = surface%aliases(a)%group
      sf(131) = surface%aliases(a)%first_field
      se(131) = max(0, surface%aliases(a)%extent1)
      if (sg(131) < 1 .or. sg(131) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(131))%fields)) return
      if (sf(131) < 1 .or. sf(131) > size(surface%groups(sg(131))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YDO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(132) = surface%aliases(a)%group
      sf(132) = surface%aliases(a)%first_field
      se(132) = max(0, surface%aliases(a)%extent1)
      if (sg(132) < 1 .or. sg(132) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(132))%fields)) return
      if (sf(132) < 1 .or. sf(132) > size(surface%groups(sg(132))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YHO_INV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(133) = surface%aliases(a)%group
      sf(133) = surface%aliases(a)%first_field
      se(133) = max(0, surface%aliases(a)%extent1)
      if (sg(133) < 1 .or. sg(133) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(133))%fields)) return
      if (sf(133) < 1 .or. sf(133) > size(surface%groups(sg(133))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YUOC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(134) = surface%aliases(a)%group
      sf(134) = surface%aliases(a)%first_field
      se(134) = max(0, surface%aliases(a)%extent1)
      if (sg(134) < 1 .or. sg(134) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(134))%fields)) return
      if (sf(134) < 1 .or. sf(134) > size(surface%groups(sg(134))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YVOC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(135) = surface%aliases(a)%group
      sf(135) = surface%aliases(a)%first_field
      se(135) = max(0, surface%aliases(a)%extent1)
      if (sg(135) < 1 .or. sg(135) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(135))%fields)) return
      if (sf(135) < 1 .or. sf(135) > size(surface%groups(sg(135))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_V3%YOTKE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(136) = surface%aliases(a)%group
      sf(136) = surface%aliases(a)%first_field
      se(136) = max(0, surface%aliases(a)%extent1)
      if (sg(136) < 1 .or. sg(136) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(136))%fields)) return
      if (sf(136) < 1 .or. sf(136) > size(surface%groups(sg(136))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLSP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(137) = surface%aliases(a)%group
      sf(137) = surface%aliases(a)%first_field
      se(137) = max(0, surface%aliases(a)%extent1)
      if (sg(137) < 1 .or. sg(137) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(137))%fields)) return
      if (sf(137) < 1 .or. sf(137) > size(surface%groups(sg(137))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(138) = surface%aliases(a)%group
      sf(138) = surface%aliases(a)%first_field
      se(138) = max(0, surface%aliases(a)%extent1)
      if (sg(138) < 1 .or. sg(138) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(138))%fields)) return
      if (sf(138) < 1 .or. sf(138) > size(surface%groups(sg(138))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(139) = surface%aliases(a)%group
      sf(139) = surface%aliases(a)%first_field
      se(139) = max(0, surface%aliases(a)%extent1)
      if (sg(139) < 1 .or. sg(139) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(139))%fields)) return
      if (sf(139) < 1 .or. sf(139) > size(surface%groups(sg(139))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YFZRA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(140) = surface%aliases(a)%group
      sf(140) = surface%aliases(a)%first_field
      se(140) = max(0, surface%aliases(a)%extent1)
      if (sg(140) < 1 .or. sg(140) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(140))%fields)) return
      if (sf(140) < 1 .or. sf(140) > size(surface%groups(sg(140))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YBLD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(141) = surface%aliases(a)%group
      sf(141) = surface%aliases(a)%first_field
      se(141) = max(0, surface%aliases(a)%extent1)
      if (sg(141) < 1 .or. sg(141) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(141))%fields)) return
      if (sf(141) < 1 .or. sf(141) > size(surface%groups(sg(141))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSSHF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(142) = surface%aliases(a)%group
      sf(142) = surface%aliases(a)%first_field
      se(142) = max(0, surface%aliases(a)%extent1)
      if (sg(142) < 1 .or. sg(142) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(142))%fields)) return
      if (sf(142) < 1 .or. sf(142) > size(surface%groups(sg(142))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSLHF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(143) = surface%aliases(a)%group
      sf(143) = surface%aliases(a)%first_field
      se(143) = max(0, surface%aliases(a)%extent1)
      if (sg(143) < 1 .or. sg(143) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(143))%fields)) return
      if (sf(143) < 1 .or. sf(143) > size(surface%groups(sg(143))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YNEE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(144) = surface%aliases(a)%group
      sf(144) = surface%aliases(a)%first_field
      se(144) = max(0, surface%aliases(a)%extent1)
      if (sg(144) < 1 .or. sg(144) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(144))%fields)) return
      if (sf(144) < 1 .or. sf(144) > size(surface%groups(sg(144))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YGPP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(145) = surface%aliases(a)%group
      sf(145) = surface%aliases(a)%first_field
      se(145) = max(0, surface%aliases(a)%extent1)
      if (sg(145) < 1 .or. sg(145) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(145))%fields)) return
      if (sf(145) < 1 .or. sf(145) > size(surface%groups(sg(145))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YREC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(146) = surface%aliases(a)%group
      sf(146) = surface%aliases(a)%first_field
      se(146) = max(0, surface%aliases(a)%extent1)
      if (sg(146) < 1 .or. sg(146) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(146))%fields)) return
      if (sf(146) < 1 .or. sf(146) > size(surface%groups(sg(146))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMSL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(147) = surface%aliases(a)%group
      sf(147) = surface%aliases(a)%first_field
      se(147) = max(0, surface%aliases(a)%extent1)
      if (sg(147) < 1 .or. sg(147) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(147))%fields)) return
      if (sf(147) < 1 .or. sf(147) > size(surface%groups(sg(147))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(148) = surface%aliases(a)%group
      sf(148) = surface%aliases(a)%first_field
      se(148) = max(0, surface%aliases(a)%extent1)
      if (sg(148) < 1 .or. sg(148) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(148))%fields)) return
      if (sf(148) < 1 .or. sf(148) > size(surface%groups(sg(148))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(149) = surface%aliases(a)%group
      sf(149) = surface%aliases(a)%first_field
      se(149) = max(0, surface%aliases(a)%extent1)
      if (sg(149) < 1 .or. sg(149) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(149))%fields)) return
      if (sf(149) < 1 .or. sf(149) > size(surface%groups(sg(149))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y10U') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(150) = surface%aliases(a)%group
      sf(150) = surface%aliases(a)%first_field
      se(150) = max(0, surface%aliases(a)%extent1)
      if (sg(150) < 1 .or. sg(150) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(150))%fields)) return
      if (sf(150) < 1 .or. sf(150) > size(surface%groups(sg(150))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y10V') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(151) = surface%aliases(a)%group
      sf(151) = surface%aliases(a)%first_field
      se(151) = max(0, surface%aliases(a)%extent1)
      if (sg(151) < 1 .or. sg(151) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(151))%fields)) return
      if (sf(151) < 1 .or. sf(151) > size(surface%groups(sg(151))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y2T') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(152) = surface%aliases(a)%group
      sf(152) = surface%aliases(a)%first_field
      se(152) = max(0, surface%aliases(a)%extent1)
      if (sg(152) < 1 .or. sg(152) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(152))%fields)) return
      if (sf(152) < 1 .or. sf(152) > size(surface%groups(sg(152))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y2D') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(153) = surface%aliases(a)%group
      sf(153) = surface%aliases(a)%first_field
      se(153) = max(0, surface%aliases(a)%extent1)
      if (sg(153) < 1 .or. sg(153) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(153))%fields)) return
      if (sf(153) < 1 .or. sf(153) > size(surface%groups(sg(153))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y2SH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(154) = surface%aliases(a)%group
      sf(154) = surface%aliases(a)%first_field
      se(154) = max(0, surface%aliases(a)%extent1)
      if (sg(154) < 1 .or. sg(154) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(154))%fields)) return
      if (sf(154) < 1 .or. sf(154) > size(surface%groups(sg(154))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSSR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(155) = surface%aliases(a)%group
      sf(155) = surface%aliases(a)%first_field
      se(155) = max(0, surface%aliases(a)%extent1)
      if (sg(155) < 1 .or. sg(155) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(155))%fields)) return
      if (sf(155) < 1 .or. sf(155) > size(surface%groups(sg(155))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSTR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(156) = surface%aliases(a)%group
      sf(156) = surface%aliases(a)%first_field
      se(156) = max(0, surface%aliases(a)%extent1)
      if (sg(156) < 1 .or. sg(156) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(156))%fields)) return
      if (sf(156) < 1 .or. sf(156) > size(surface%groups(sg(156))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTSR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(157) = surface%aliases(a)%group
      sf(157) = surface%aliases(a)%first_field
      se(157) = max(0, surface%aliases(a)%extent1)
      if (sg(157) < 1 .or. sg(157) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(157))%fields)) return
      if (sf(157) < 1 .or. sf(157) > size(surface%groups(sg(157))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTTR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(158) = surface%aliases(a)%group
      sf(158) = surface%aliases(a)%first_field
      se(158) = max(0, surface%aliases(a)%extent1)
      if (sg(158) < 1 .or. sg(158) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(158))%fields)) return
      if (sf(158) < 1 .or. sf(158) > size(surface%groups(sg(158))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YEWSS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(159) = surface%aliases(a)%group
      sf(159) = surface%aliases(a)%first_field
      se(159) = max(0, surface%aliases(a)%extent1)
      if (sg(159) < 1 .or. sg(159) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(159))%fields)) return
      if (sf(159) < 1 .or. sf(159) > size(surface%groups(sg(159))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YNSSS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(160) = surface%aliases(a)%group
      sf(160) = surface%aliases(a)%first_field
      se(160) = max(0, surface%aliases(a)%extent1)
      if (sg(160) < 1 .or. sg(160) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(160))%fields)) return
      if (sf(160) < 1 .or. sf(160) > size(surface%groups(sg(160))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(161) = surface%aliases(a)%group
      sf(161) = surface%aliases(a)%first_field
      se(161) = max(0, surface%aliases(a)%extent1)
      if (sg(161) < 1 .or. sg(161) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(161))%fields)) return
      if (sf(161) < 1 .or. sf(161) > size(surface%groups(sg(161))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YPEV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(162) = surface%aliases(a)%group
      sf(162) = surface%aliases(a)%first_field
      se(162) = max(0, surface%aliases(a)%extent1)
      if (sg(162) < 1 .or. sg(162) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(162))%fields)) return
      if (sf(162) < 1 .or. sf(162) > size(surface%groups(sg(162))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCCC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(163) = surface%aliases(a)%group
      sf(163) = surface%aliases(a)%first_field
      se(163) = max(0, surface%aliases(a)%extent1)
      if (sg(163) < 1 .or. sg(163) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(163))%fields)) return
      if (sf(163) < 1 .or. sf(163) > size(surface%groups(sg(163))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLCC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(164) = surface%aliases(a)%group
      sf(164) = surface%aliases(a)%first_field
      se(164) = max(0, surface%aliases(a)%extent1)
      if (sg(164) < 1 .or. sg(164) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(164))%fields)) return
      if (sf(164) < 1 .or. sf(164) > size(surface%groups(sg(164))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMCC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(165) = surface%aliases(a)%group
      sf(165) = surface%aliases(a)%first_field
      se(165) = max(0, surface%aliases(a)%extent1)
      if (sg(165) < 1 .or. sg(165) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(165))%fields)) return
      if (sf(165) < 1 .or. sf(165) > size(surface%groups(sg(165))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YHCC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(166) = surface%aliases(a)%group
      sf(166) = surface%aliases(a)%first_field
      se(166) = max(0, surface%aliases(a)%extent1)
      if (sg(166) < 1 .or. sg(166) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(166))%fields)) return
      if (sf(166) < 1 .or. sf(166) > size(surface%groups(sg(166))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLGWS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(167) = surface%aliases(a)%group
      sf(167) = surface%aliases(a)%first_field
      se(167) = max(0, surface%aliases(a)%extent1)
      if (sg(167) < 1 .or. sg(167) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(167))%fields)) return
      if (sf(167) < 1 .or. sf(167) > size(surface%groups(sg(167))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMGWS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(168) = surface%aliases(a)%group
      sf(168) = surface%aliases(a)%first_field
      se(168) = max(0, surface%aliases(a)%extent1)
      if (sg(168) < 1 .or. sg(168) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(168))%fields)) return
      if (sf(168) < 1 .or. sf(168) > size(surface%groups(sg(168))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YGWD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(169) = surface%aliases(a)%group
      sf(169) = surface%aliases(a)%first_field
      se(169) = max(0, surface%aliases(a)%extent1)
      if (sg(169) < 1 .or. sg(169) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(169))%fields)) return
      if (sf(169) < 1 .or. sf(169) > size(surface%groups(sg(169))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMX2T') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(170) = surface%aliases(a)%group
      sf(170) = surface%aliases(a)%first_field
      se(170) = max(0, surface%aliases(a)%extent1)
      if (sg(170) < 1 .or. sg(170) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(170))%fields)) return
      if (sf(170) < 1 .or. sf(170) > size(surface%groups(sg(170))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMN2T') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(171) = surface%aliases(a)%group
      sf(171) = surface%aliases(a)%first_field
      se(171) = max(0, surface%aliases(a)%extent1)
      if (sg(171) < 1 .or. sg(171) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(171))%fields)) return
      if (sf(171) < 1 .or. sf(171) > size(surface%groups(sg(171))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YRO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(172) = surface%aliases(a)%group
      sf(172) = surface%aliases(a)%first_field
      se(172) = max(0, surface%aliases(a)%extent1)
      if (sg(172) < 1 .or. sg(172) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(172))%fields)) return
      if (sf(172) < 1 .or. sf(172) > size(surface%groups(sg(172))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSRO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(173) = surface%aliases(a)%group
      sf(173) = surface%aliases(a)%first_field
      se(173) = max(0, surface%aliases(a)%extent1)
      if (sg(173) < 1 .or. sg(173) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(173))%fields)) return
      if (sf(173) < 1 .or. sf(173) > size(surface%groups(sg(173))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSSRO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(174) = surface%aliases(a)%group
      sf(174) = surface%aliases(a)%first_field
      se(174) = max(0, surface%aliases(a)%extent1)
      if (sg(174) < 1 .or. sg(174) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(174))%fields)) return
      if (sf(174) < 1 .or. sf(174) > size(surface%groups(sg(174))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YALB') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(175) = surface%aliases(a)%group
      sf(175) = surface%aliases(a)%first_field
      se(175) = max(0, surface%aliases(a)%extent1)
      if (sg(175) < 1 .or. sg(175) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(175))%fields)) return
      if (sf(175) < 1 .or. sf(175) > size(surface%groups(sg(175))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YIEWSS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(176) = surface%aliases(a)%group
      sf(176) = surface%aliases(a)%first_field
      se(176) = max(0, surface%aliases(a)%extent1)
      if (sg(176) < 1 .or. sg(176) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(176))%fields)) return
      if (sf(176) < 1 .or. sf(176) > size(surface%groups(sg(176))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YINSSS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(177) = surface%aliases(a)%group
      sf(177) = surface%aliases(a)%first_field
      se(177) = max(0, surface%aliases(a)%extent1)
      if (sg(177) < 1 .or. sg(177) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(177))%fields)) return
      if (sf(177) < 1 .or. sf(177) > size(surface%groups(sg(177))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YISSHF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(178) = surface%aliases(a)%group
      sf(178) = surface%aliases(a)%first_field
      se(178) = max(0, surface%aliases(a)%extent1)
      if (sg(178) < 1 .or. sg(178) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(178))%fields)) return
      if (sf(178) < 1 .or. sf(178) > size(surface%groups(sg(178))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YIE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(179) = surface%aliases(a)%group
      sf(179) = surface%aliases(a)%first_field
      se(179) = max(0, surface%aliases(a)%extent1)
      if (sg(179) < 1 .or. sg(179) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(179))%fields)) return
      if (sf(179) < 1 .or. sf(179) > size(surface%groups(sg(179))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YINEE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(180) = surface%aliases(a)%group
      sf(180) = surface%aliases(a)%first_field
      se(180) = max(0, surface%aliases(a)%extent1)
      if (sg(180) < 1 .or. sg(180) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(180))%fields)) return
      if (sf(180) < 1 .or. sf(180) > size(surface%groups(sg(180))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YIGPP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(181) = surface%aliases(a)%group
      sf(181) = surface%aliases(a)%first_field
      se(181) = max(0, surface%aliases(a)%extent1)
      if (sg(181) < 1 .or. sg(181) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(181))%fields)) return
      if (sf(181) < 1 .or. sf(181) > size(surface%groups(sg(181))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YIREC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(182) = surface%aliases(a)%group
      sf(182) = surface%aliases(a)%first_field
      se(182) = max(0, surface%aliases(a)%extent1)
      if (sg(182) < 1 .or. sg(182) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(182))%fields)) return
      if (sf(182) < 1 .or. sf(182) > size(surface%groups(sg(182))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YICH4') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(183) = surface%aliases(a)%group
      sf(183) = surface%aliases(a)%first_field
      se(183) = max(0, surface%aliases(a)%extent1)
      if (sg(183) < 1 .or. sg(183) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(183))%fields)) return
      if (sf(183) < 1 .or. sf(183) > size(surface%groups(sg(183))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCSF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(184) = surface%aliases(a)%group
      sf(184) = surface%aliases(a)%first_field
      se(184) = max(0, surface%aliases(a)%extent1)
      if (sg(184) < 1 .or. sg(184) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(184))%fields)) return
      if (sf(184) < 1 .or. sf(184) > size(surface%groups(sg(184))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLSSF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(185) = surface%aliases(a)%group
      sf(185) = surface%aliases(a)%first_field
      se(185) = max(0, surface%aliases(a)%extent1)
      if (sg(185) < 1 .or. sg(185) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(185))%fields)) return
      if (sf(185) < 1 .or. sf(185) > size(surface%groups(sg(185))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMXTPR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(186) = surface%aliases(a)%group
      sf(186) = surface%aliases(a)%first_field
      se(186) = max(0, surface%aliases(a)%extent1)
      if (sg(186) < 1 .or. sg(186) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(186))%fields)) return
      if (sf(186) < 1 .or. sf(186) > size(surface%groups(sg(186))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMNTPR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(187) = surface%aliases(a)%group
      sf(187) = surface%aliases(a)%first_field
      se(187) = max(0, surface%aliases(a)%extent1)
      if (sg(187) < 1 .or. sg(187) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(187))%fields)) return
      if (sf(187) < 1 .or. sf(187) > size(surface%groups(sg(187))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTPR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(188) = surface%aliases(a)%group
      sf(188) = surface%aliases(a)%first_field
      se(188) = max(0, surface%aliases(a)%extent1)
      if (sg(188) < 1 .or. sg(188) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(188))%fields)) return
      if (sf(188) < 1 .or. sf(188) > size(surface%groups(sg(188))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLSRR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(189) = surface%aliases(a)%group
      sf(189) = surface%aliases(a)%first_field
      se(189) = max(0, surface%aliases(a)%extent1)
      if (sg(189) < 1 .or. sg(189) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(189))%fields)) return
      if (sf(189) < 1 .or. sf(189) > size(surface%groups(sg(189))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCRR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(190) = surface%aliases(a)%group
      sf(190) = surface%aliases(a)%first_field
      se(190) = max(0, surface%aliases(a)%extent1)
      if (sg(190) < 1 .or. sg(190) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(190))%fields)) return
      if (sf(190) < 1 .or. sf(190) > size(surface%groups(sg(190))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLSSFR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(191) = surface%aliases(a)%group
      sf(191) = surface%aliases(a)%first_field
      se(191) = max(0, surface%aliases(a)%extent1)
      if (sg(191) < 1 .or. sg(191) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(191))%fields)) return
      if (sf(191) < 1 .or. sf(191) > size(surface%groups(sg(191))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCSFR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(192) = surface%aliases(a)%group
      sf(192) = surface%aliases(a)%first_field
      se(192) = max(0, surface%aliases(a)%extent1)
      if (sg(192) < 1 .or. sg(192) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(192))%fields)) return
      if (sf(192) < 1 .or. sf(192) > size(surface%groups(sg(192))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YPTYPE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(193) = surface%aliases(a)%group
      sf(193) = surface%aliases(a)%first_field
      se(193) = max(0, surface%aliases(a)%extent1)
      if (sg(193) < 1 .or. sg(193) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(193))%fields)) return
      if (sf(193) < 1 .or. sf(193) > size(surface%groups(sg(193))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YILSPF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(194) = surface%aliases(a)%group
      sf(194) = surface%aliases(a)%first_field
      se(194) = max(0, surface%aliases(a)%extent1)
      if (sg(194) < 1 .or. sg(194) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(194))%fields)) return
      if (sf(194) < 1 .or. sf(194) > size(surface%groups(sg(194))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YZ0F') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(195) = surface%aliases(a)%group
      sf(195) = surface%aliases(a)%first_field
      se(195) = max(0, surface%aliases(a)%extent1)
      if (sg(195) < 1 .or. sg(195) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(195))%fields)) return
      if (sf(195) < 1 .or. sf(195) > size(surface%groups(sg(195))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLZ0H') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(196) = surface%aliases(a)%group
      sf(196) = surface%aliases(a)%first_field
      se(196) = max(0, surface%aliases(a)%extent1)
      if (sg(196) < 1 .or. sg(196) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(196))%fields)) return
      if (sf(196) < 1 .or. sf(196) > size(surface%groups(sg(196))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(197) = surface%aliases(a)%group
      sf(197) = surface%aliases(a)%first_field
      se(197) = max(0, surface%aliases(a)%extent1)
      if (sg(197) < 1 .or. sg(197) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(197))%fields)) return
      if (sf(197) < 1 .or. sf(197) > size(surface%groups(sg(197))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCWV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(198) = surface%aliases(a)%group
      sf(198) = surface%aliases(a)%first_field
      se(198) = max(0, surface%aliases(a)%extent1)
      if (sg(198) < 1 .or. sg(198) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(198))%fields)) return
      if (sf(198) < 1 .or. sf(198) > size(surface%groups(sg(198))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCLW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(199) = surface%aliases(a)%group
      sf(199) = surface%aliases(a)%first_field
      se(199) = max(0, surface%aliases(a)%extent1)
      if (sg(199) < 1 .or. sg(199) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(199))%fields)) return
      if (sf(199) < 1 .or. sf(199) > size(surface%groups(sg(199))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCIW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(200) = surface%aliases(a)%group
      sf(200) = surface%aliases(a)%first_field
      se(200) = max(0, surface%aliases(a)%extent1)
      if (sg(200) < 1 .or. sg(200) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(200))%fields)) return
      if (sf(200) < 1 .or. sf(200) > size(surface%groups(sg(200))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCRW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(201) = surface%aliases(a)%group
      sf(201) = surface%aliases(a)%first_field
      se(201) = max(0, surface%aliases(a)%extent1)
      if (sg(201) < 1 .or. sg(201) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(201))%fields)) return
      if (sf(201) < 1 .or. sf(201) > size(surface%groups(sg(201))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCSW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(202) = surface%aliases(a)%group
      sf(202) = surface%aliases(a)%first_field
      se(202) = max(0, surface%aliases(a)%extent1)
      if (sg(202) < 1 .or. sg(202) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(202))%fields)) return
      if (sf(202) < 1 .or. sf(202) > size(surface%groups(sg(202))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCSLW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(203) = surface%aliases(a)%group
      sf(203) = surface%aliases(a)%first_field
      se(203) = max(0, surface%aliases(a)%extent1)
      if (sg(203) < 1 .or. sg(203) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(203))%fields)) return
      if (sf(203) < 1 .or. sf(203) > size(surface%groups(sg(203))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSSRD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(204) = surface%aliases(a)%group
      sf(204) = surface%aliases(a)%first_field
      se(204) = max(0, surface%aliases(a)%extent1)
      if (sg(204) < 1 .or. sg(204) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(204))%fields)) return
      if (sf(204) < 1 .or. sf(204) > size(surface%groups(sg(204))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSTRD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(205) = surface%aliases(a)%group
      sf(205) = surface%aliases(a)%first_field
      se(205) = max(0, surface%aliases(a)%extent1)
      if (sg(205) < 1 .or. sg(205) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(205))%fields)) return
      if (sf(205) < 1 .or. sf(205) > size(surface%groups(sg(205))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSSRDC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(206) = surface%aliases(a)%group
      sf(206) = surface%aliases(a)%first_field
      se(206) = max(0, surface%aliases(a)%extent1)
      if (sg(206) < 1 .or. sg(206) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(206))%fields)) return
      if (sf(206) < 1 .or. sf(206) > size(surface%groups(sg(206))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSTRDC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(207) = surface%aliases(a)%group
      sf(207) = surface%aliases(a)%first_field
      se(207) = max(0, surface%aliases(a)%extent1)
      if (sg(207) < 1 .or. sg(207) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(207))%fields)) return
      if (sf(207) < 1 .or. sf(207) > size(surface%groups(sg(207))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YBLH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(208) = surface%aliases(a)%group
      sf(208) = surface%aliases(a)%first_field
      se(208) = max(0, surface%aliases(a)%extent1)
      if (sg(208) < 1 .or. sg(208) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(208))%fields)) return
      if (sf(208) < 1 .or. sf(208) > size(surface%groups(sg(208))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSUND') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(209) = surface%aliases(a)%group
      sf(209) = surface%aliases(a)%first_field
      se(209) = max(0, surface%aliases(a)%extent1)
      if (sg(209) < 1 .or. sg(209) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(209))%fields)) return
      if (sf(209) < 1 .or. sf(209) > size(surface%groups(sg(209))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSPAR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(210) = surface%aliases(a)%group
      sf(210) = surface%aliases(a)%first_field
      se(210) = max(0, surface%aliases(a)%extent1)
      if (sg(210) < 1 .or. sg(210) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(210))%fields)) return
      if (sf(210) < 1 .or. sf(210) > size(surface%groups(sg(210))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSUVB') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(211) = surface%aliases(a)%group
      sf(211) = surface%aliases(a)%first_field
      se(211) = max(0, surface%aliases(a)%extent1)
      if (sg(211) < 1 .or. sg(211) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(211))%fields)) return
      if (sf(211) < 1 .or. sf(211) > size(surface%groups(sg(211))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSFDIR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(212) = surface%aliases(a)%group
      sf(212) = surface%aliases(a)%first_field
      se(212) = max(0, surface%aliases(a)%extent1)
      if (sg(212) < 1 .or. sg(212) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(212))%fields)) return
      if (sf(212) < 1 .or. sf(212) > size(surface%groups(sg(212))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSCDIR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(213) = surface%aliases(a)%group
      sf(213) = surface%aliases(a)%first_field
      se(213) = max(0, surface%aliases(a)%extent1)
      if (sg(213) < 1 .or. sg(213) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(213))%fields)) return
      if (sf(213) < 1 .or. sf(213) > size(surface%groups(sg(213))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSDSRP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(214) = surface%aliases(a)%group
      sf(214) = surface%aliases(a)%first_field
      se(214) = max(0, surface%aliases(a)%extent1)
      if (sg(214) < 1 .or. sg(214) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(214))%fields)) return
      if (sf(214) < 1 .or. sf(214) > size(surface%groups(sg(214))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCAPE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(215) = surface%aliases(a)%group
      sf(215) = surface%aliases(a)%first_field
      se(215) = max(0, surface%aliases(a)%extent1)
      if (sg(215) < 1 .or. sg(215) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(215))%fields)) return
      if (sf(215) < 1 .or. sf(215) > size(surface%groups(sg(215))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCAPES') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(216) = surface%aliases(a)%group
      sf(216) = surface%aliases(a)%first_field
      se(216) = max(0, surface%aliases(a)%extent1)
      if (sg(216) < 1 .or. sg(216) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(216))%fields)) return
      if (sf(216) < 1 .or. sf(216) > size(surface%groups(sg(216))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMUCAPE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(217) = surface%aliases(a)%group
      sf(217) = surface%aliases(a)%first_field
      se(217) = max(0, surface%aliases(a)%extent1)
      if (sg(217) < 1 .or. sg(217) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(217))%fields)) return
      if (sf(217) < 1 .or. sf(217) > size(surface%groups(sg(217))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YPDEPL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(218) = surface%aliases(a)%group
      sf(218) = surface%aliases(a)%first_field
      se(218) = max(0, surface%aliases(a)%extent1)
      if (sg(218) < 1 .or. sg(218) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(218))%fields)) return
      if (sf(218) < 1 .or. sf(218) > size(surface%groups(sg(218))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMLCAPE50') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(219) = surface%aliases(a)%group
      sf(219) = surface%aliases(a)%first_field
      se(219) = max(0, surface%aliases(a)%extent1)
      if (sg(219) < 1 .or. sg(219) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(219))%fields)) return
      if (sf(219) < 1 .or. sf(219) > size(surface%groups(sg(219))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMLCAPE100') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(220) = surface%aliases(a)%group
      sf(220) = surface%aliases(a)%first_field
      se(220) = max(0, surface%aliases(a)%extent1)
      if (sg(220) < 1 .or. sg(220) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(220))%fields)) return
      if (sf(220) < 1 .or. sf(220) > size(surface%groups(sg(220))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMLCIN50') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(221) = surface%aliases(a)%group
      sf(221) = surface%aliases(a)%first_field
      se(221) = max(0, surface%aliases(a)%extent1)
      if (sg(221) < 1 .or. sg(221) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(221))%fields)) return
      if (sf(221) < 1 .or. sf(221) > size(surface%groups(sg(221))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YMLCIN100') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(222) = surface%aliases(a)%group
      sf(222) = surface%aliases(a)%first_field
      se(222) = max(0, surface%aliases(a)%extent1)
      if (sg(222) < 1 .or. sg(222) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(222))%fields)) return
      if (sf(222) < 1 .or. sf(222) > size(surface%groups(sg(222))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTROPOTP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(223) = surface%aliases(a)%group
      sf(223) = surface%aliases(a)%first_field
      se(223) = max(0, surface%aliases(a)%extent1)
      if (sg(223) < 1 .or. sg(223) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(223))%fields)) return
      if (sf(223) < 1 .or. sf(223) > size(surface%groups(sg(223))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTSRC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(224) = surface%aliases(a)%group
      sf(224) = surface%aliases(a)%first_field
      se(224) = max(0, surface%aliases(a)%extent1)
      if (sg(224) < 1 .or. sg(224) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(224))%fields)) return
      if (sf(224) < 1 .or. sf(224) > size(surface%groups(sg(224))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTTRC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(225) = surface%aliases(a)%group
      sf(225) = surface%aliases(a)%first_field
      se(225) = max(0, surface%aliases(a)%extent1)
      if (sg(225) < 1 .or. sg(225) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(225))%fields)) return
      if (sf(225) < 1 .or. sf(225) > size(surface%groups(sg(225))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSSRC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(226) = surface%aliases(a)%group
      sf(226) = surface%aliases(a)%first_field
      se(226) = max(0, surface%aliases(a)%extent1)
      if (sg(226) < 1 .or. sg(226) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(226))%fields)) return
      if (sf(226) < 1 .or. sf(226) > size(surface%groups(sg(226))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSTRC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(227) = surface%aliases(a)%group
      sf(227) = surface%aliases(a)%first_field
      se(227) = max(0, surface%aliases(a)%extent1)
      if (sg(227) < 1 .or. sg(227) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(227))%fields)) return
      if (sf(227) < 1 .or. sf(227) > size(surface%groups(sg(227))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YES') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(228) = surface%aliases(a)%group
      sf(228) = surface%aliases(a)%first_field
      se(228) = max(0, surface%aliases(a)%extent1)
      if (sg(228) < 1 .or. sg(228) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(228))%fields)) return
      if (sf(228) < 1 .or. sf(228) > size(surface%groups(sg(228))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSMLT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(229) = surface%aliases(a)%group
      sf(229) = surface%aliases(a)%first_field
      se(229) = max(0, surface%aliases(a)%extent1)
      if (sg(229) < 1 .or. sg(229) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(229))%fields)) return
      if (sf(229) < 1 .or. sf(229) > size(surface%groups(sg(229))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y10FG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(230) = surface%aliases(a)%group
      sf(230) = surface%aliases(a)%first_field
      se(230) = max(0, surface%aliases(a)%extent1)
      if (sg(230) < 1 .or. sg(230) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(230))%fields)) return
      if (sf(230) < 1 .or. sf(230) > size(surface%groups(sg(230))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y10FGCV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(231) = surface%aliases(a)%group
      sf(231) = surface%aliases(a)%first_field
      se(231) = max(0, surface%aliases(a)%extent1)
      if (sg(231) < 1 .or. sg(231) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(231))%fields)) return
      if (sf(231) < 1 .or. sf(231) > size(surface%groups(sg(231))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YI10FG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(232) = surface%aliases(a)%group
      sf(232) = surface%aliases(a)%first_field
      se(232) = max(0, surface%aliases(a)%extent1)
      if (sg(232) < 1 .or. sg(232) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(232))%fields)) return
      if (sf(232) < 1 .or. sf(232) > size(surface%groups(sg(232))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLSPF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(233) = surface%aliases(a)%group
      sf(233) = surface%aliases(a)%first_field
      se(233) = max(0, surface%aliases(a)%extent1)
      if (sg(233) < 1 .or. sg(233) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(233))%fields)) return
      if (sf(233) < 1 .or. sf(233) > size(surface%groups(sg(233))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTCO3') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(234) = surface%aliases(a)%group
      sf(234) = surface%aliases(a)%first_field
      se(234) = max(0, surface%aliases(a)%extent1)
      if (sg(234) < 1 .or. sg(234) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(234))%fields)) return
      if (sf(234) < 1 .or. sf(234) > size(surface%groups(sg(234))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YVIMD') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(235) = surface%aliases(a)%group
      sf(235) = surface%aliases(a)%first_field
      se(235) = max(0, surface%aliases(a)%extent1)
      if (sg(235) < 1 .or. sg(235) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(235))%fields)) return
      if (sf(235) < 1 .or. sf(235) > size(surface%groups(sg(235))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSPARC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(236) = surface%aliases(a)%group
      sf(236) = surface%aliases(a)%first_field
      se(236) = max(0, surface%aliases(a)%extent1)
      if (sg(236) < 1 .or. sg(236) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(236))%fields)) return
      if (sf(236) < 1 .or. sf(236) > size(surface%groups(sg(236))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSTINC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(237) = surface%aliases(a)%group
      sf(237) = surface%aliases(a)%first_field
      se(237) = max(0, surface%aliases(a)%extent1)
      if (sg(237) < 1 .or. sg(237) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(237))%fields)) return
      if (sf(237) < 1 .or. sf(237) > size(surface%groups(sg(237))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCBASE') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(238) = surface%aliases(a)%group
      sf(238) = surface%aliases(a)%first_field
      se(238) = max(0, surface%aliases(a)%extent1)
      if (sg(238) < 1 .or. sg(238) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(238))%fields)) return
      if (sf(238) < 1 .or. sf(238) > size(surface%groups(sg(238))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y0DEGL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(239) = surface%aliases(a)%group
      sf(239) = surface%aliases(a)%first_field
      se(239) = max(0, surface%aliases(a)%extent1)
      if (sg(239) < 1 .or. sg(239) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(239))%fields)) return
      if (sf(239) < 1 .or. sf(239) > size(surface%groups(sg(239))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YM10DEGL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(240) = surface%aliases(a)%group
      sf(240) = surface%aliases(a)%first_field
      se(240) = max(0, surface%aliases(a)%extent1)
      if (sg(240) < 1 .or. sg(240) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(240))%fields)) return
      if (sf(240) < 1 .or. sf(240) > size(surface%groups(sg(240))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YVISIH') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(241) = surface%aliases(a)%group
      sf(241) = surface%aliases(a)%first_field
      se(241) = max(0, surface%aliases(a)%extent1)
      if (sg(241) < 1 .or. sg(241) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(241))%fields)) return
      if (sf(241) < 1 .or. sf(241) > size(surface%groups(sg(241))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCIN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(242) = surface%aliases(a)%group
      sf(242) = surface%aliases(a)%first_field
      se(242) = max(0, surface%aliases(a)%extent1)
      if (sg(242) < 1 .or. sg(242) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(242))%fields)) return
      if (sf(242) < 1 .or. sf(242) > size(surface%groups(sg(242))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YKINDEX') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(243) = surface%aliases(a)%group
      sf(243) = surface%aliases(a)%first_field
      se(243) = max(0, surface%aliases(a)%extent1)
      if (sg(243) < 1 .or. sg(243) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(243))%fields)) return
      if (sf(243) < 1 .or. sf(243) > size(surface%groups(sg(243))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTTINDEX') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(244) = surface%aliases(a)%group
      sf(244) = surface%aliases(a)%first_field
      se(244) = max(0, surface%aliases(a)%extent1)
      if (sg(244) < 1 .or. sg(244) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(244))%fields)) return
      if (sf(244) < 1 .or. sf(244) > size(surface%groups(sg(244))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCBASEA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(245) = surface%aliases(a)%group
      sf(245) = surface%aliases(a)%first_field
      se(245) = max(0, surface%aliases(a)%extent1)
      if (sg(245) < 1 .or. sg(245) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(245))%fields)) return
      if (sf(245) < 1 .or. sf(245) > size(surface%groups(sg(245))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YCTOPC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(246) = surface%aliases(a)%group
      sf(246) = surface%aliases(a)%first_field
      se(246) = max(0, surface%aliases(a)%extent1)
      if (sg(246) < 1 .or. sg(246) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(246))%fields)) return
      if (sf(246) < 1 .or. sf(246) > size(surface%groups(sg(246))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YZTWETB0') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(247) = surface%aliases(a)%group
      sf(247) = surface%aliases(a)%first_field
      se(247) = max(0, surface%aliases(a)%extent1)
      if (sg(247) < 1 .or. sg(247) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(247))%fields)) return
      if (sf(247) < 1 .or. sf(247) > size(surface%groups(sg(247))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YZTWETB1') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(248) = surface%aliases(a)%group
      sf(248) = surface%aliases(a)%first_field
      se(248) = max(0, surface%aliases(a)%extent1)
      if (sg(248) < 1 .or. sg(248) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(248))%fields)) return
      if (sf(248) < 1 .or. sf(248) > size(surface%groups(sg(248))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y100U') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(249) = surface%aliases(a)%group
      sf(249) = surface%aliases(a)%first_field
      se(249) = max(0, surface%aliases(a)%extent1)
      if (sg(249) < 1 .or. sg(249) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(249))%fields)) return
      if (sf(249) < 1 .or. sf(249) > size(surface%groups(sg(249))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y100V') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(250) = surface%aliases(a)%group
      sf(250) = surface%aliases(a)%first_field
      se(250) = max(0, surface%aliases(a)%extent1)
      if (sg(250) < 1 .or. sg(250) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(250))%fields)) return
      if (sf(250) < 1 .or. sf(250) > size(surface%groups(sg(250))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YZUST') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(251) = surface%aliases(a)%group
      sf(251) = surface%aliases(a)%first_field
      se(251) = max(0, surface%aliases(a)%extent1)
      if (sg(251) < 1 .or. sg(251) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(251))%fields)) return
      if (sf(251) < 1 .or. sf(251) > size(surface%groups(sg(251))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y10NU') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(252) = surface%aliases(a)%group
      sf(252) = surface%aliases(a)%first_field
      se(252) = max(0, surface%aliases(a)%extent1)
      if (sg(252) < 1 .or. sg(252) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(252))%fields)) return
      if (sf(252) < 1 .or. sf(252) > size(surface%groups(sg(252))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y10NV') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(253) = surface%aliases(a)%group
      sf(253) = surface%aliases(a)%first_field
      se(253) = max(0, surface%aliases(a)%extent1)
      if (sg(253) < 1 .or. sg(253) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(253))%fields)) return
      if (sf(253) < 1 .or. sf(253) > size(surface%groups(sg(253))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YDNDZN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(254) = surface%aliases(a)%group
      sf(254) = surface%aliases(a)%first_field
      se(254) = max(0, surface%aliases(a)%extent1)
      if (sg(254) < 1 .or. sg(254) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(254))%fields)) return
      if (sf(254) < 1 .or. sf(254) > size(surface%groups(sg(254))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YDNDZA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(255) = surface%aliases(a)%group
      sf(255) = surface%aliases(a)%first_field
      se(255) = max(0, surface%aliases(a)%extent1)
      if (sg(255) < 1 .or. sg(255) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(255))%fields)) return
      if (sf(255) < 1 .or. sf(255) > size(surface%groups(sg(255))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YDCTB') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(256) = surface%aliases(a)%group
      sf(256) = surface%aliases(a)%first_field
      se(256) = max(0, surface%aliases(a)%extent1)
      if (sg(256) < 1 .or. sg(256) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(256))%fields)) return
      if (sf(256) < 1 .or. sf(256) > size(surface%groups(sg(256))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTPLB') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(257) = surface%aliases(a)%group
      sf(257) = surface%aliases(a)%first_field
      se(257) = max(0, surface%aliases(a)%extent1)
      if (sg(257) < 1 .or. sg(257) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(257))%fields)) return
      if (sf(257) < 1 .or. sf(257) > size(surface%groups(sg(257))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YTPLT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(258) = surface%aliases(a)%group
      sf(258) = surface%aliases(a)%first_field
      se(258) = max(0, surface%aliases(a)%extent1)
      if (sg(258) < 1 .or. sg(258) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(258))%fields)) return
      if (sf(258) < 1 .or. sf(258) > size(surface%groups(sg(258))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODSS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(259) = surface%aliases(a)%group
      sf(259) = surface%aliases(a)%first_field
      se(259) = max(0, surface%aliases(a)%extent1)
      if (sg(259) < 1 .or. sg(259) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(259))%fields)) return
      if (sf(259) < 1 .or. sf(259) > size(surface%groups(sg(259))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODDU') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(260) = surface%aliases(a)%group
      sf(260) = surface%aliases(a)%first_field
      se(260) = max(0, surface%aliases(a)%extent1)
      if (sg(260) < 1 .or. sg(260) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(260))%fields)) return
      if (sf(260) < 1 .or. sf(260) > size(surface%groups(sg(260))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODOM') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(261) = surface%aliases(a)%group
      sf(261) = surface%aliases(a)%first_field
      se(261) = max(0, surface%aliases(a)%extent1)
      if (sg(261) < 1 .or. sg(261) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(261))%fields)) return
      if (sf(261) < 1 .or. sf(261) > size(surface%groups(sg(261))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODBC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(262) = surface%aliases(a)%group
      sf(262) = surface%aliases(a)%first_field
      se(262) = max(0, surface%aliases(a)%extent1)
      if (sg(262) < 1 .or. sg(262) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(262))%fields)) return
      if (sf(262) < 1 .or. sf(262) > size(surface%groups(sg(262))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODSU') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(263) = surface%aliases(a)%group
      sf(263) = surface%aliases(a)%first_field
      se(263) = max(0, surface%aliases(a)%extent1)
      if (sg(263) < 1 .or. sg(263) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(263))%fields)) return
      if (sf(263) < 1 .or. sf(263) > size(surface%groups(sg(263))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODNI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(264) = surface%aliases(a)%group
      sf(264) = surface%aliases(a)%first_field
      se(264) = max(0, surface%aliases(a)%extent1)
      if (sg(264) < 1 .or. sg(264) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(264))%fields)) return
      if (sf(264) < 1 .or. sf(264) > size(surface%groups(sg(264))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODAM') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(265) = surface%aliases(a)%group
      sf(265) = surface%aliases(a)%first_field
      se(265) = max(0, surface%aliases(a)%extent1)
      if (sg(265) < 1 .or. sg(265) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(265))%fields)) return
      if (sf(265) < 1 .or. sf(265) > size(surface%groups(sg(265))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODSOA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(266) = surface%aliases(a)%group
      sf(266) = surface%aliases(a)%first_field
      se(266) = max(0, surface%aliases(a)%extent1)
      if (sg(266) < 1 .or. sg(266) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(266))%fields)) return
      if (sf(266) < 1 .or. sf(266) > size(surface%groups(sg(266))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODVFA') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(267) = surface%aliases(a)%group
      sf(267) = surface%aliases(a)%first_field
      se(267) = max(0, surface%aliases(a)%extent1)
      if (sg(267) < 1 .or. sg(267) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(267))%fields)) return
      if (sf(267) < 1 .or. sf(267) > size(surface%groups(sg(267))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODVSU') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(268) = surface%aliases(a)%group
      sf(268) = surface%aliases(a)%first_field
      se(268) = max(0, surface%aliases(a)%extent1)
      if (sg(268) < 1 .or. sg(268) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(268))%fields)) return
      if (sf(268) < 1 .or. sf(268) > size(surface%groups(sg(268))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YODTOACC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(269) = surface%aliases(a)%group
      sf(269) = surface%aliases(a)%first_field
      se(269) = max(0, surface%aliases(a)%extent1)
      if (sg(269) < 1 .or. sg(269) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(269))%fields)) return
      if (sf(269) < 1 .or. sf(269) > size(surface%groups(sg(269))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YAEPM1') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(270) = surface%aliases(a)%group
      sf(270) = surface%aliases(a)%first_field
      se(270) = max(0, surface%aliases(a)%extent1)
      if (sg(270) < 1 .or. sg(270) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(270))%fields)) return
      if (sf(270) < 1 .or. sf(270) > size(surface%groups(sg(270))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YAEPM25') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(271) = surface%aliases(a)%group
      sf(271) = surface%aliases(a)%first_field
      se(271) = max(0, surface%aliases(a)%extent1)
      if (sg(271) < 1 .or. sg(271) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(271))%fields)) return
      if (sf(271) < 1 .or. sf(271) > size(surface%groups(sg(271))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YAEPM10') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(272) = surface%aliases(a)%group
      sf(272) = surface%aliases(a)%first_field
      se(272) = max(0, surface%aliases(a)%extent1)
      if (sg(272) < 1 .or. sg(272) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(272))%fields)) return
      if (sf(272) < 1 .or. sf(272) > size(surface%groups(sg(272))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YUVBED') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(273) = surface%aliases(a)%group
      sf(273) = surface%aliases(a)%first_field
      se(273) = max(0, surface%aliases(a)%extent1)
      if (sg(273) < 1 .or. sg(273) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(273))%fields)) return
      if (sf(273) < 1 .or. sf(273) > size(surface%groups(sg(273))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YUVBEDCS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(274) = surface%aliases(a)%group
      sf(274) = surface%aliases(a)%first_field
      se(274) = max(0, surface%aliases(a)%extent1)
      if (sg(274) < 1 .or. sg(274) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(274))%fields)) return
      if (sf(274) < 1 .or. sf(274) > size(surface%groups(sg(274))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLITOTI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(275) = surface%aliases(a)%group
      sf(275) = surface%aliases(a)%first_field
      se(275) = max(0, surface%aliases(a)%extent1)
      if (sg(275) < 1 .or. sg(275) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(275))%fields)) return
      if (sf(275) < 1 .or. sf(275) > size(surface%groups(sg(275))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YLICGI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(276) = surface%aliases(a)%group
      sf(276) = surface%aliases(a)%first_field
      se(276) = max(0, surface%aliases(a)%extent1)
      if (sg(276) < 1 .or. sg(276) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(276))%fields)) return
      if (sf(276) < 1 .or. sf(276) > size(surface%groups(sg(276))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y200U') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(277) = surface%aliases(a)%group
      sf(277) = surface%aliases(a)%first_field
      se(277) = max(0, surface%aliases(a)%extent1)
      if (sg(277) < 1 .or. sg(277) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(277))%fields)) return
      if (sf(277) < 1 .or. sf(277) > size(surface%groups(sg(277))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%Y200V') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(278) = surface%aliases(a)%group
      sf(278) = surface%aliases(a)%first_field
      se(278) = max(0, surface%aliases(a)%extent1)
      if (sg(278) < 1 .or. sg(278) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(278))%fields)) return
      if (sf(278) < 1 .or. sf(278) > size(surface%groups(sg(278))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VD%YSDSL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(279) = surface%aliases(a)%group
      sf(279) = surface%aliases(a)%first_field
      se(279) = max(0, surface%aliases(a)%extent1)
      if (sg(279) < 1 .or. sg(279) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(279))%fields)) return
      if (sf(279) < 1 .or. sf(279) > size(surface%groups(sg(279))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_SM%YCLBT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(280) = surface%aliases(a)%group
      sf(280) = surface%aliases(a)%first_field
      se(280) = max(0, surface%aliases(a)%extent1)
      if (sg(280) < 1 .or. sg(280) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(280))%fields)) return
      if (sf(280) < 1 .or. sf(280) > size(surface%groups(sg(280))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_SM%YCSBT') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(281) = surface%aliases(a)%group
      sf(281) = surface%aliases(a)%first_field
      se(281) = max(0, surface%aliases(a)%extent1)
      if (sg(281) < 1 .or. sg(281) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(281))%fields)) return
      if (sf(281) < 1 .or. sf(281) > size(surface%groups(sg(281))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YCHAR') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(282) = surface%aliases(a)%group
      sf(282) = surface%aliases(a)%first_field
      se(282) = max(0, surface%aliases(a)%extent1)
      if (sg(282) < 1 .or. sg(282) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(282))%fields)) return
      if (sf(282) < 1 .or. sf(282) > size(surface%groups(sg(282))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YCHARHQ') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(283) = surface%aliases(a)%group
      sf(283) = surface%aliases(a)%first_field
      se(283) = max(0, surface%aliases(a)%extent1)
      if (sg(283) < 1 .or. sg(283) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(283))%fields)) return
      if (sf(283) < 1 .or. sf(283) > size(surface%groups(sg(283))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YUSTOKES') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(284) = surface%aliases(a)%group
      sf(284) = surface%aliases(a)%first_field
      se(284) = max(0, surface%aliases(a)%extent1)
      if (sg(284) < 1 .or. sg(284) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(284))%fields)) return
      if (sf(284) < 1 .or. sf(284) > size(surface%groups(sg(284))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YVSTOKES') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(285) = surface%aliases(a)%group
      sf(285) = surface%aliases(a)%first_field
      se(285) = max(0, surface%aliases(a)%extent1)
      if (sg(285) < 1 .or. sg(285) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(285))%fields)) return
      if (sf(285) < 1 .or. sf(285) > size(surface%groups(sg(285))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YTAUOCX') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(286) = surface%aliases(a)%group
      sf(286) = surface%aliases(a)%first_field
      se(286) = max(0, surface%aliases(a)%extent1)
      if (sg(286) < 1 .or. sg(286) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(286))%fields)) return
      if (sf(286) < 1 .or. sf(286) > size(surface%groups(sg(286))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YTAUOCY') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(287) = surface%aliases(a)%group
      sf(287) = surface%aliases(a)%first_field
      se(287) = max(0, surface%aliases(a)%extent1)
      if (sg(287) < 1 .or. sg(287) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(287))%fields)) return
      if (sf(287) < 1 .or. sf(287) > size(surface%groups(sg(287))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YPHIOC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(288) = surface%aliases(a)%group
      sf(288) = surface%aliases(a)%first_field
      se(288) = max(0, surface%aliases(a)%extent1)
      if (sg(288) < 1 .or. sg(288) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(288))%fields)) return
      if (sf(288) < 1 .or. sf(288) > size(surface%groups(sg(288))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YWSEMEAN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(289) = surface%aliases(a)%group
      sf(289) = surface%aliases(a)%first_field
      se(289) = max(0, surface%aliases(a)%extent1)
      if (sg(289) < 1 .or. sg(289) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(289))%fields)) return
      if (sf(289) < 1 .or. sf(289) > size(surface%groups(sg(289))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WS%YWSFMEAN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(290) = surface%aliases(a)%group
      sf(290) = surface%aliases(a)%first_field
      se(290) = max(0, surface%aliases(a)%extent1)
      if (sg(290) < 1 .or. sg(290) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(290))%fields)) return
      if (sf(290) < 1 .or. sf(290) > size(surface%groups(sg(290))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YU10N') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(291) = surface%aliases(a)%group
      sf(291) = surface%aliases(a)%first_field
      se(291) = max(0, surface%aliases(a)%extent1)
      if (sg(291) < 1 .or. sg(291) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(291))%fields)) return
      if (sf(291) < 1 .or. sf(291) > size(surface%groups(sg(291))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YV10N') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(292) = surface%aliases(a)%group
      sf(292) = surface%aliases(a)%first_field
      se(292) = max(0, surface%aliases(a)%extent1)
      if (sg(292) < 1 .or. sg(292) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(292))%fields)) return
      if (sf(292) < 1 .or. sf(292) > size(surface%groups(sg(292))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YRHO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(293) = surface%aliases(a)%group
      sf(293) = surface%aliases(a)%first_field
      se(293) = max(0, surface%aliases(a)%extent1)
      if (sg(293) < 1 .or. sg(293) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(293))%fields)) return
      if (sf(293) < 1 .or. sf(293) > size(surface%groups(sg(293))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YZIL') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(294) = surface%aliases(a)%group
      sf(294) = surface%aliases(a)%first_field
      se(294) = max(0, surface%aliases(a)%extent1)
      if (sg(294) < 1 .or. sg(294) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(294))%fields)) return
      if (sf(294) < 1 .or. sf(294) > size(surface%groups(sg(294))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YCIF') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(295) = surface%aliases(a)%group
      sf(295) = surface%aliases(a)%first_field
      se(295) = max(0, surface%aliases(a)%extent1)
      if (sg(295) < 1 .or. sg(295) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(295))%fields)) return
      if (sf(295) < 1 .or. sf(295) > size(surface%groups(sg(295))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YCLK') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(296) = surface%aliases(a)%group
      sf(296) = surface%aliases(a)%first_field
      se(296) = max(0, surface%aliases(a)%extent1)
      if (sg(296) < 1 .or. sg(296) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(296))%fields)) return
      if (sf(296) < 1 .or. sf(296) > size(surface%groups(sg(296))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YUCURW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(297) = surface%aliases(a)%group
      sf(297) = surface%aliases(a)%first_field
      se(297) = max(0, surface%aliases(a)%extent1)
      if (sg(297) < 1 .or. sg(297) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(297))%fields)) return
      if (sf(297) < 1 .or. sf(297) > size(surface%groups(sg(297))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_WW%YVCURW') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(298) = surface%aliases(a)%group
      sf(298) = surface%aliases(a)%first_field
      se(298) = max(0, surface%aliases(a)%extent1)
      if (sg(298) < 1 .or. sg(298) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(298))%fields)) return
      if (sf(298) < 1 .or. sf(298) > size(surface%groups(sg(298))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YORO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(299) = surface%aliases(a)%group
      sf(299) = surface%aliases(a)%first_field
      se(299) = max(0, surface%aliases(a)%extent1)
      if (sg(299) < 1 .or. sg(299) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(299))%fields)) return
      if (sf(299) < 1 .or. sf(299) > size(surface%groups(sg(299))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YTSC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(300) = surface%aliases(a)%group
      sf(300) = surface%aliases(a)%first_field
      se(300) = max(0, surface%aliases(a)%extent1)
      if (sg(300) < 1 .or. sg(300) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(300))%fields)) return
      if (sf(300) < 1 .or. sf(300) > size(surface%groups(sg(300))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YPWS') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(301) = surface%aliases(a)%group
      sf(301) = surface%aliases(a)%first_field
      se(301) = max(0, surface%aliases(a)%extent1)
      if (sg(301) < 1 .or. sg(301) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(301))%fields)) return
      if (sf(301) < 1 .or. sf(301) > size(surface%groups(sg(301))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YPWP') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(302) = surface%aliases(a)%group
      sf(302) = surface%aliases(a)%first_field
      se(302) = max(0, surface%aliases(a)%extent1)
      if (sg(302) < 1 .or. sg(302) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(302))%fields)) return
      if (sf(302) < 1 .or. sf(302) > size(surface%groups(sg(302))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YSNO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(303) = surface%aliases(a)%group
      sf(303) = surface%aliases(a)%first_field
      se(303) = max(0, surface%aliases(a)%extent1)
      if (sg(303) < 1 .or. sg(303) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(303))%fields)) return
      if (sf(303) < 1 .or. sf(303) > size(surface%groups(sg(303))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YTPC') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(304) = surface%aliases(a)%group
      sf(304) = surface%aliases(a)%first_field
      se(304) = max(0, surface%aliases(a)%extent1)
      if (sg(304) < 1 .or. sg(304) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(304))%fields)) return
      if (sf(304) < 1 .or. sf(304) > size(surface%groups(sg(304))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YSAB') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(305) = surface%aliases(a)%group
      sf(305) = surface%aliases(a)%first_field
      se(305) = max(0, surface%aliases(a)%extent1)
      if (sg(305) < 1 .or. sg(305) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(305))%fields)) return
      if (sf(305) < 1 .or. sf(305) > size(surface%groups(sg(305))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YXD2') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(306) = surface%aliases(a)%group
      sf(306) = surface%aliases(a)%first_field
      se(306) = max(0, surface%aliases(a)%extent1)
      if (sg(306) < 1 .or. sg(306) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(306))%fields)) return
      if (sf(306) < 1 .or. sf(306) > size(surface%groups(sg(306))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YLSM') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(307) = surface%aliases(a)%group
      sf(307) = surface%aliases(a)%first_field
      se(307) = max(0, surface%aliases(a)%extent1)
      if (sg(307) < 1 .or. sg(307) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(307))%fields)) return
      if (sf(307) < 1 .or. sf(307) > size(surface%groups(sg(307))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YIVEG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(308) = surface%aliases(a)%group
      sf(308) = surface%aliases(a)%first_field
      se(308) = max(0, surface%aliases(a)%extent1)
      if (sg(308) < 1 .or. sg(308) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(308))%fields)) return
      if (sf(308) < 1 .or. sf(308) > size(surface%groups(sg(308))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YARG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(309) = surface%aliases(a)%group
      sf(309) = surface%aliases(a)%first_field
      se(309) = max(0, surface%aliases(a)%extent1)
      if (sg(309) < 1 .or. sg(309) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(309))%fields)) return
      if (sf(309) < 1 .or. sf(309) > size(surface%groups(sg(309))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YRSMIN') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(310) = surface%aliases(a)%group
      sf(310) = surface%aliases(a)%first_field
      se(310) = max(0, surface%aliases(a)%extent1)
      if (sg(310) < 1 .or. sg(310) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(310))%fields)) return
      if (sf(310) < 1 .or. sf(310) > size(surface%groups(sg(310))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YLAI') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(311) = surface%aliases(a)%group
      sf(311) = surface%aliases(a)%first_field
      se(311) = max(0, surface%aliases(a)%extent1)
      if (sg(311) < 1 .or. sg(311) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(311))%fields)) return
      if (sf(311) < 1 .or. sf(311) > size(surface%groups(sg(311))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VX%YVEG') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(312) = surface%aliases(a)%group
      sf(312) = surface%aliases(a)%first_field
      se(312) = max(0, surface%aliases(a)%extent1)
      if (sg(312) < 1 .or. sg(312) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(312))%fields)) return
      if (sf(312) < 1 .or. sf(312) > size(surface%groups(sg(312))%fields)) return
      a = 0
      do j = 1, size(surface%aliases)
        if (surface%aliases(j)%name == 'YSD_VK%YUDGRO') then
          a = j; exit
        end if
      end do
      if (a == 0) return
      sg(313) = surface%aliases(a)%group
      sf(313) = surface%aliases(a)%first_field
      se(313) = max(0, surface%aliases(a)%extent1)
      if (sg(313) < 1 .or. sg(313) > size(surface%groups)) return
      if (.not. allocated(surface%groups(sg(313))%fields)) return
      if (sf(313) < 1 .or. sf(313) > size(surface%groups(sg(313))%fields)) return
    end if
    output%mt9_map = 0
    output%mt1_map = 0
    output%mt0_map = 0
    output%mpc_map = 0
    output%mpt_map = 0
    output%mt0_dl_map = 0
    output%mt0_dm_map = 0
    output%mt9_dl_map = 0
    output%mt9_dm_map = 0
    output%mt0_size = 0
    ! MT0_MAP FID1 <- YDGMV%YT0%MU
    value = motion%yt0%mu
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(1) = value
    ! MT0_MAP FID2 <- YDGMV%YT0%MV
    value = motion%yt0%mv
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(2) = value
    ! MT0_MAP FID3 <- YDGMV%YT0%MDIV
    value = motion%yt0%mdiv
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(3) = value
    ! MT0_MAP FID4 <- YDGMV%YT0%MVOR
    value = motion%yt0%mvor
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(4) = value
    ! MT0_MAP FID5 <- YDGMV%YT0%MT
    value = motion%yt0%mt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(5) = value
    ! MT0_MAP FID6 <- YDGMV%YT0%MSPD
    value = motion%yt0%mspd
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(6) = value
    ! MT0_MAP FID7 <- YDGMV%YT0%MSVD
    value = motion%yt0%msvd
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(7) = value
    ! MT0_MAP FID8 <- YDGMV%YT0%MNHX
    value = motion%yt0%mnhx
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(8) = value
    ! MT0_MAP FID9 <- YDGMV%YT0%MEDOT
    value = motion%yt0%medot
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(9) = value
    ! MT0_MAP FID12 <- YDGMV%YT0%MSGRTL
    value = motion%yt0%msgrtl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(12) = value
    ! MT0_MAP FID13 <- YDGMV%YT0%MSGRTM
    value = motion%yt0%msgrtm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(13) = value
    ! MT0_MAP FID47 <- YDGFLDESC%YQ%MP
    value = -1
    if (configuration%components(gi(1))%lactive /= 0) value = configuration%components(gi(1))%mp
    output%mt0_map(47) = value
    ! MT0_MAP FID48 <- YDGFLDESC%YO3%MP
    value = -1
    if (configuration%components(gi(2))%lactive /= 0) value = configuration%components(gi(2))%mp
    output%mt0_map(48) = value
    ! MT0_MAP FID49 <- YDGFLDESC%YL%MP
    value = -1
    if (configuration%components(gi(3))%lactive /= 0) value = configuration%components(gi(3))%mp
    output%mt0_map(49) = value
    ! MT0_MAP FID50 <- YDGFLDESC%YI%MP
    value = -1
    if (configuration%components(gi(4))%lactive /= 0) value = configuration%components(gi(4))%mp
    output%mt0_map(50) = value
    ! MT0_MAP FID51 <- YDGFLDESC%YA%MP
    value = -1
    if (configuration%components(gi(5))%lactive /= 0) value = configuration%components(gi(5))%mp
    output%mt0_map(51) = value
    ! MT0_MAP FID56 <- YDGFLDESC%YS%MP
    value = -1
    if (configuration%components(gi(6))%lactive /= 0) value = configuration%components(gi(6))%mp
    output%mt0_map(56) = value
    ! MT0_MAP FID57 <- YDGFLDESC%YR%MP
    value = -1
    if (configuration%components(gi(7))%lactive /= 0) value = configuration%components(gi(7))%mp
    output%mt0_map(57) = value
    ! MT0_MAP FID58 <- YDGFLDESC%YG%MP
    value = -1
    if (configuration%components(gi(8))%lactive /= 0) value = configuration%components(gi(8))%mp
    output%mt0_map(58) = value
    ! MT0_MAP FID59 <- YDGFLDESC%YH%MP
    value = -1
    if (configuration%components(gi(9))%lactive /= 0) value = configuration%components(gi(9))%mp
    output%mt0_map(59) = value
    ! MT0_MAP FID52 <- YDGFLDESC%YLRCH4%MP
    value = -1
    if (configuration%components(gi(10))%lactive /= 0) value = configuration%components(gi(10))%mp
    output%mt0_map(52) = value
    ! MT0_MAP FID60 <- YDGFLDESC%YLCONV%MP
    value = -1
    if (configuration%components(gi(11))%lactive /= 0) value = configuration%components(gi(11))%mp
    output%mt0_map(60) = value
    ! MT0_MAP FID61 <- YDGFLDESC%YICONV%MP
    value = -1
    if (configuration%components(gi(12))%lactive /= 0) value = configuration%components(gi(12))%mp
    output%mt0_map(61) = value
    ! MT0_MAP FID62 <- YDGFLDESC%YRCONV%MP
    value = -1
    if (configuration%components(gi(13))%lactive /= 0) value = configuration%components(gi(13))%mp
    output%mt0_map(62) = value
    ! MT0_MAP FID63 <- YDGFLDESC%YSCONV%MP
    value = -1
    if (configuration%components(gi(14))%lactive /= 0) value = configuration%components(gi(14))%mp
    output%mt0_map(63) = value
    ! MT0_MAP FID64 <- YDGFLDESC%YTKE%MP
    value = -1
    if (configuration%components(gi(15))%lactive /= 0) value = configuration%components(gi(15))%mp
    output%mt0_map(64) = value
    ! MT0_MAP FID65 <- YDGFLDESC%YTTE%MP
    value = -1
    if (configuration%components(gi(16))%lactive /= 0) value = configuration%components(gi(16))%mp
    output%mt0_map(65) = value
    ! MT0_MAP FID66 <- YDGFLDESC%YEFB1%MP
    value = -1
    if (configuration%components(gi(17))%lactive /= 0) value = configuration%components(gi(17))%mp
    output%mt0_map(66) = value
    ! MT0_MAP FID67 <- YDGFLDESC%YEFB2%MP
    value = -1
    if (configuration%components(gi(18))%lactive /= 0) value = configuration%components(gi(18))%mp
    output%mt0_map(67) = value
    ! MT0_MAP FID68 <- YDGFLDESC%YEFB3%MP
    value = -1
    if (configuration%components(gi(19))%lactive /= 0) value = configuration%components(gi(19))%mp
    output%mt0_map(68) = value
    ! MT0_MAP FID69 <- YDGFLDESC%YMXL%MP
    value = -1
    if (configuration%components(gi(20))%lactive /= 0) value = configuration%components(gi(20))%mp
    output%mt0_map(69) = value
    ! MT0_MAP FID70 <- YDGFLDESC%YSRC%MP
    value = -1
    if (configuration%components(gi(21))%lactive /= 0) value = configuration%components(gi(21))%mp
    output%mt0_map(70) = value
    ! MT0_MAP FID71 <- YDGFLDESC%YSHTUR%MP
    value = -1
    if (configuration%components(gi(22))%lactive /= 0) value = configuration%components(gi(22))%mp
    output%mt0_map(71) = value
    ! MT0_MAP FID72 <- YDGFLDESC%YFQTUR%MP
    value = -1
    if (configuration%components(gi(23))%lactive /= 0) value = configuration%components(gi(23))%mp
    output%mt0_map(72) = value
    ! MT0_MAP FID73 <- YDGFLDESC%YFSTUR%MP
    value = -1
    if (configuration%components(gi(24))%lactive /= 0) value = configuration%components(gi(24))%mp
    output%mt0_map(73) = value
    ! MT0_MAP FID74 <- YDGFLDESC%YCVV%MP
    value = -1
    if (configuration%components(gi(25))%lactive /= 0) value = configuration%components(gi(25))%mp
    output%mt0_map(74) = value
    ! MT0_MAP FID84 <- YDGFLDESC%YRKTH%MP
    value = -1
    if (configuration%components(gi(26))%lactive /= 0) value = configuration%components(gi(26))%mp
    output%mt0_map(84) = value
    ! MT0_MAP FID85 <- YDGFLDESC%YRKTQV%MP
    value = -1
    if (configuration%components(gi(27))%lactive /= 0) value = configuration%components(gi(27))%mp
    output%mt0_map(85) = value
    ! MT0_MAP FID86 <- YDGFLDESC%YRKTQC%MP
    value = -1
    if (configuration%components(gi(28))%lactive /= 0) value = configuration%components(gi(28))%mp
    output%mt0_map(86) = value
    ! MT0_MAP FID75 <- YDGFLDESC%YCPF%MP
    value = -1
    if (configuration%components(gi(29))%lactive /= 0) value = configuration%components(gi(29))%mp
    output%mt0_map(75) = value
    ! MT0_MAP FID76 <- YDGFLDESC%YSPF%MP
    value = -1
    if (configuration%components(gi(30))%lactive /= 0) value = configuration%components(gi(30))%mp
    output%mt0_map(76) = value
    ! MT0_MAP FID77 <- YDGFLDESC%YCVGQ%MP
    value = -1
    if (configuration%components(gi(31))%lactive /= 0) value = configuration%components(gi(31))%mp
    output%mt0_map(77) = value
    ! MT0_MAP FID87 <- YDGFLDESC%YLRAD%MP
    value = -1
    if (configuration%components(gi(32))%lactive /= 0) value = configuration%components(gi(32))%mp
    output%mt0_map(87) = value
    ! MT0_MAP FID88 <- YDGFLDESC%YIRAD%MP
    value = -1
    if (configuration%components(gi(33))%lactive /= 0) value = configuration%components(gi(33))%mp
    output%mt0_map(88) = value
    ! MT0_MAP FID89 <- YDGFLDESC%YRSPEC%MP
    value = -1
    if (configuration%components(gi(34))%lactive /= 0) value = configuration%components(gi(34))%mp
    output%mt0_map(89) = value
    ! MT0_MAP FID78 <- YDGFLDESC%YUOM%MP
    value = -1
    if (configuration%components(gi(35))%lactive /= 0) value = configuration%components(gi(35))%mp
    output%mt0_map(78) = value
    ! MT0_MAP FID79 <- YDGFLDESC%YUAL%MP
    value = -1
    if (configuration%components(gi(36))%lactive /= 0) value = configuration%components(gi(36))%mp
    output%mt0_map(79) = value
    ! MT0_MAP FID80 <- YDGFLDESC%YDOM%MP
    value = -1
    if (configuration%components(gi(37))%lactive /= 0) value = configuration%components(gi(37))%mp
    output%mt0_map(80) = value
    ! MT0_MAP FID81 <- YDGFLDESC%YDAL%MP
    value = -1
    if (configuration%components(gi(38))%lactive /= 0) value = configuration%components(gi(38))%mp
    output%mt0_map(81) = value
    ! MT0_MAP FID82 <- YDGFLDESC%YUEN%MP
    value = -1
    if (configuration%components(gi(39))%lactive /= 0) value = configuration%components(gi(39))%mp
    output%mt0_map(82) = value
    ! MT0_MAP FID83 <- YDGFLDESC%YUNEBH%MP
    value = -1
    if (configuration%components(gi(40))%lactive /= 0) value = configuration%components(gi(40))%mp
    output%mt0_map(83) = value
    ! MT0_MAP FID93 <- YDGFLDESC%YEXT(1)%MP
    value = -1
    if (configuration%components(gi(41))%lactive /= 0) value = configuration%components(gi(41))%mp
    output%mt0_map(93) = value
    ! MT0_MAP FID94 <- YDGFLDESC%YEZDIAG(1)%MP
    value = -1
    if (configuration%components(gi(42))%lactive /= 0) value = configuration%components(gi(42))%mp
    output%mt0_map(94) = value
    ! MT0_MAP FID167 <- YDGFLDESC%YNOGW(1)%MP
    value = -1
    if (configuration%components(gi(43))%lactive /= 0) value = configuration%components(gi(43))%mp
    output%mt0_map(167) = value
    ! MT0_MAP FID168 <- YDGFLDESC%YNOGW(2)%MP
    value = -1
    if (configuration%components(gi(44))%lactive /= 0) value = configuration%components(gi(44))%mp
    output%mt0_map(168) = value
    ! MT0_MAP FID95 <- YDGMV%YT0%MSP
    value = motion%yt0%msp
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_map(95) = value
    ! MT0_MAP FID1101 <- YDSURF%YSP_SB%YQ%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(1))%fields(sf(1))%initialized /= 0) then
        value = surface%groups(sg(1))%fields(sf(1))%indices(1)
      end if
      output%mt0_map(1101) = value
    end if
    ! MT0_MAP FID1102 <- YDSURF%YSP_SB%YT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(2))%fields(sf(2))%initialized /= 0) then
        value = surface%groups(sg(2))%fields(sf(2))%indices(1)
      end if
      output%mt0_map(1102) = value
    end if
    ! MT0_MAP FID1103 <- YDSURF%YSP_SB%YTL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(3))%fields(sf(3))%initialized /= 0) then
        value = surface%groups(sg(3))%fields(sf(3))%indices(1)
      end if
      output%mt0_map(1103) = value
    end if
    ! MT0_MAP FID1201 <- YDSURF%YSP_SG%YF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(4))%fields(sf(4))%initialized /= 0) then
        value = surface%groups(sg(4))%fields(sf(4))%indices(1)
      end if
      output%mt0_map(1201) = value
    end if
    ! MT0_MAP FID1202 <- YDSURF%YSP_SG%YA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(5))%fields(sf(5))%initialized /= 0) then
        value = surface%groups(sg(5))%fields(sf(5))%indices(1)
      end if
      output%mt0_map(1202) = value
    end if
    ! MT0_MAP FID1203 <- YDSURF%YSP_SG%YR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(6))%fields(sf(6))%initialized /= 0) then
        value = surface%groups(sg(6))%fields(sf(6))%indices(1)
      end if
      output%mt0_map(1203) = value
    end if
    ! MT0_MAP FID1204 <- YDSURF%YSP_SG%YT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(7))%fields(sf(7))%initialized /= 0) then
        value = surface%groups(sg(7))%fields(sf(7))%indices(1)
      end if
      output%mt0_map(1204) = value
    end if
    ! MT0_MAP FID1205 <- YDSURF%YSP_SG%YW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(8))%fields(sf(8))%initialized /= 0) then
        value = surface%groups(sg(8))%fields(sf(8))%indices(1)
      end if
      output%mt0_map(1205) = value
    end if
    ! MT0_MAP FID1301 <- YDSURF%YSP_SL%YLICT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(9))%fields(sf(9))%initialized /= 0) then
        value = surface%groups(sg(9))%fields(sf(9))%indices(1)
      end if
      output%mt0_map(1301) = value
    end if
    ! MT0_MAP FID1302 <- YDSURF%YSP_SL%YLMLT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(10))%fields(sf(10))%initialized /= 0) then
        value = surface%groups(sg(10))%fields(sf(10))%indices(1)
      end if
      output%mt0_map(1302) = value
    end if
    ! MT0_MAP FID1303 <- YDSURF%YSP_SL%YLTLT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(11))%fields(sf(11))%initialized /= 0) then
        value = surface%groups(sg(11))%fields(sf(11))%indices(1)
      end if
      output%mt0_map(1303) = value
    end if
    ! MT0_MAP FID1304 <- YDSURF%YSP_SL%YLBLT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(12))%fields(sf(12))%initialized /= 0) then
        value = surface%groups(sg(12))%fields(sf(12))%indices(1)
      end if
      output%mt0_map(1304) = value
    end if
    ! MT0_MAP FID1305 <- YDSURF%YSP_SL%YLSHF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(13))%fields(sf(13))%initialized /= 0) then
        value = surface%groups(sg(13))%fields(sf(13))%indices(1)
      end if
      output%mt0_map(1305) = value
    end if
    ! MT0_MAP FID1306 <- YDSURF%YSP_SL%YLICD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(14))%fields(sf(14))%initialized /= 0) then
        value = surface%groups(sg(14))%fields(sf(14))%indices(1)
      end if
      output%mt0_map(1306) = value
    end if
    ! MT0_MAP FID1307 <- YDSURF%YSP_SL%YLMLD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(15))%fields(sf(15))%initialized /= 0) then
        value = surface%groups(sg(15))%fields(sf(15))%indices(1)
      end if
      output%mt0_map(1307) = value
    end if
    ! MT0_MAP FID1401 <- YDSURF%YSP_RR%YT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(16))%fields(sf(16))%initialized /= 0) then
        value = surface%groups(sg(16))%fields(sf(16))%indices(1)
      end if
      output%mt0_map(1401) = value
    end if
    ! MT0_MAP FID1402 <- YDSURF%YSP_RR%YW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(17))%fields(sf(17))%initialized /= 0) then
        value = surface%groups(sg(17))%fields(sf(17))%indices(1)
      end if
      output%mt0_map(1402) = value
    end if
    ! MT0_MAP FID1403 <- YDSURF%YSP_RR%YFC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(18))%fields(sf(18))%initialized /= 0) then
        value = surface%groups(sg(18))%fields(sf(18))%indices(1)
      end if
      output%mt0_map(1403) = value
    end if
    ! MT0_MAP FID1404 <- YDSURF%YSP_RR%YIC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(19))%fields(sf(19))%initialized /= 0) then
        value = surface%groups(sg(19))%fields(sf(19))%indices(1)
      end if
      output%mt0_map(1404) = value
    end if
    ! MT0_MAP FID1405 <- YDSURF%YSP_RR%YFP1%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(20))%fields(sf(20))%initialized /= 0) then
        value = surface%groups(sg(20))%fields(sf(20))%indices(1)
      end if
      output%mt0_map(1405) = value
    end if
    ! MT0_MAP FID1501 <- YDSURF%YSP_CL%YTCLS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(21))%fields(sf(21))%initialized /= 0) then
        value = surface%groups(sg(21))%fields(sf(21))%indices(1)
      end if
      output%mt0_map(1501) = value
    end if
    ! MT0_MAP FID1502 <- YDSURF%YSP_CL%YHUCLS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(22))%fields(sf(22))%initialized /= 0) then
        value = surface%groups(sg(22))%fields(sf(22))%indices(1)
      end if
      output%mt0_map(1502) = value
    end if
    ! MT0_MAP FID1601 <- YDSURF%YSP_OM%YTO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(23))%fields(sf(23))%initialized /= 0) then
        value = surface%groups(sg(23))%fields(sf(23))%indices(1)
      end if
      output%mt0_map(1601) = value
    end if
    ! MT0_MAP FID1602 <- YDSURF%YSP_OM%YSO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(24))%fields(sf(24))%initialized /= 0) then
        value = surface%groups(sg(24))%fields(sf(24))%indices(1)
      end if
      output%mt0_map(1602) = value
    end if
    ! MT0_MAP FID1603 <- YDSURF%YSP_OM%YUO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(25))%fields(sf(25))%initialized /= 0) then
        value = surface%groups(sg(25))%fields(sf(25))%indices(1)
      end if
      output%mt0_map(1603) = value
    end if
    ! MT0_MAP FID1604 <- YDSURF%YSP_OM%YVO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(26))%fields(sf(26))%initialized /= 0) then
        value = surface%groups(sg(26))%fields(sf(26))%indices(1)
      end if
      output%mt0_map(1604) = value
    end if
    ! MT0_MAP FID2001 <- YDSURF%YSD_VF%YZ0F%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(27))%fields(sf(27))%initialized /= 0) then
        value = surface%groups(sg(27))%fields(sf(27))%indices(1)
      end if
      output%mt0_map(2001) = value
    end if
    ! MT0_MAP FID2002 <- YDSURF%YSD_VF%YALBF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(28))%fields(sf(28))%initialized /= 0) then
        value = surface%groups(sg(28))%fields(sf(28))%indices(1)
      end if
      output%mt0_map(2002) = value
    end if
    ! MT0_MAP FID2003 <- YDSURF%YSD_VF%YEMISF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(29))%fields(sf(29))%initialized /= 0) then
        value = surface%groups(sg(29))%fields(sf(29))%indices(1)
      end if
      output%mt0_map(2003) = value
    end if
    ! MT0_MAP FID2004 <- YDSURF%YSD_VF%YGETRL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(30))%fields(sf(30))%initialized /= 0) then
        value = surface%groups(sg(30))%fields(sf(30))%indices(1)
      end if
      output%mt0_map(2004) = value
    end if
    ! MT0_MAP FID2005 <- YDSURF%YSD_VF%YLSM%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(31))%fields(sf(31))%initialized /= 0) then
        value = surface%groups(sg(31))%fields(sf(31))%indices(1)
      end if
      output%mt0_map(2005) = value
    end if
    ! MT0_MAP FID2006 <- YDSURF%YSD_VF%YVEG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(32))%fields(sf(32))%initialized /= 0) then
        value = surface%groups(sg(32))%fields(sf(32))%indices(1)
      end if
      output%mt0_map(2006) = value
    end if
    ! MT0_MAP FID2007 <- YDSURF%YSD_VF%YVRLAN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(33))%fields(sf(33))%initialized /= 0) then
        value = surface%groups(sg(33))%fields(sf(33))%indices(1)
      end if
      output%mt0_map(2007) = value
    end if
    ! MT0_MAP FID2008 <- YDSURF%YSD_VF%YVRLDI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(34))%fields(sf(34))%initialized /= 0) then
        value = surface%groups(sg(34))%fields(sf(34))%indices(1)
      end if
      output%mt0_map(2008) = value
    end if
    ! MT0_MAP FID2009 <- YDSURF%YSD_VF%YSIG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(35))%fields(sf(35))%initialized /= 0) then
        value = surface%groups(sg(35))%fields(sf(35))%indices(1)
      end if
      output%mt0_map(2009) = value
    end if
    ! MT0_MAP FID2010 <- YDSURF%YSD_VF%YALBSF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(36))%fields(sf(36))%initialized /= 0) then
        value = surface%groups(sg(36))%fields(sf(36))%indices(1)
      end if
      output%mt0_map(2010) = value
    end if
    ! MT0_MAP FID2011 <- YDSURF%YSD_VF%YLAN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(37))%fields(sf(37))%initialized /= 0) then
        value = surface%groups(sg(37))%fields(sf(37))%indices(1)
      end if
      output%mt0_map(2011) = value
    end if
    ! MT0_MAP FID2012 <- YDSURF%YSD_VF%YSST%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(38))%fields(sf(38))%initialized /= 0) then
        value = surface%groups(sg(38))%fields(sf(38))%indices(1)
      end if
      output%mt0_map(2012) = value
    end if
    ! MT0_MAP FID2013 <- YDSURF%YSD_VF%YSSS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(39))%fields(sf(39))%initialized /= 0) then
        value = surface%groups(sg(39))%fields(sf(39))%indices(1)
      end if
      output%mt0_map(2013) = value
    end if
    ! MT0_MAP FID2014 <- YDSURF%YSD_VF%YLZ0H%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(40))%fields(sf(40))%initialized /= 0) then
        value = surface%groups(sg(40))%fields(sf(40))%indices(1)
      end if
      output%mt0_map(2014) = value
    end if
    ! MT0_MAP FID2015 <- YDSURF%YSD_VF%YCVL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(41))%fields(sf(41))%initialized /= 0) then
        value = surface%groups(sg(41))%fields(sf(41))%indices(1)
      end if
      output%mt0_map(2015) = value
    end if
    ! MT0_MAP FID2082 <- YDSURF%YSD_VF%YCO2TYP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(42))%fields(sf(42))%initialized /= 0) then
        value = surface%groups(sg(42))%fields(sf(42))%indices(1)
      end if
      output%mt0_map(2082) = value
    end if
    ! MT0_MAP FID2016 <- YDSURF%YSD_VF%YCVH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(43))%fields(sf(43))%initialized /= 0) then
        value = surface%groups(sg(43))%fields(sf(43))%indices(1)
      end if
      output%mt0_map(2016) = value
    end if
    ! MT0_MAP FID2083 <- YDSURF%YSD_VF%YFWET%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(44))%fields(sf(44))%initialized /= 0) then
        value = surface%groups(sg(44))%fields(sf(44))%indices(1)
      end if
      output%mt0_map(2083) = value
    end if
    ! MT0_MAP FID2076 <- YDSURF%YSD_VF%YCUR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(45))%fields(sf(45))%initialized /= 0) then
        value = surface%groups(sg(45))%fields(sf(45))%indices(1)
      end if
      output%mt0_map(2076) = value
    end if
    ! MT0_MAP FID2017 <- YDSURF%YSD_VF%YTVL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(46))%fields(sf(46))%initialized /= 0) then
        value = surface%groups(sg(46))%fields(sf(46))%indices(1)
      end if
      output%mt0_map(2017) = value
    end if
    ! MT0_MAP FID2018 <- YDSURF%YSD_VF%YTVH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(47))%fields(sf(47))%initialized /= 0) then
        value = surface%groups(sg(47))%fields(sf(47))%indices(1)
      end if
      output%mt0_map(2018) = value
    end if
    ! MT0_MAP FID2019 <- YDSURF%YSD_VF%YLAIL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(48))%fields(sf(48))%initialized /= 0) then
        value = surface%groups(sg(48))%fields(sf(48))%indices(1)
      end if
      output%mt0_map(2019) = value
    end if
    ! MT0_MAP FID2020 <- YDSURF%YSD_VF%YLAIH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(49))%fields(sf(49))%initialized /= 0) then
        value = surface%groups(sg(49))%fields(sf(49))%indices(1)
      end if
      output%mt0_map(2020) = value
    end if
    ! MT0_MAP FID2021 <- YDSURF%YSD_VF%YSOTY%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(50))%fields(sf(50))%initialized /= 0) then
        value = surface%groups(sg(50))%fields(sf(50))%indices(1)
      end if
      output%mt0_map(2021) = value
    end if
    ! MT0_MAP FID2022 <- YDSURF%YSD_VF%YCLK%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(51))%fields(sf(51))%initialized /= 0) then
        value = surface%groups(sg(51))%fields(sf(51))%indices(1)
      end if
      output%mt0_map(2022) = value
    end if
    ! MT0_MAP FID2023 <- YDSURF%YSD_VF%YDL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(52))%fields(sf(52))%initialized /= 0) then
        value = surface%groups(sg(52))%fields(sf(52))%indices(1)
      end if
      output%mt0_map(2023) = value
    end if
    ! MT0_MAP FID2024 <- YDSURF%YSD_VF%YCI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(53))%fields(sf(53))%initialized /= 0) then
        value = surface%groups(sg(53))%fields(sf(53))%indices(1)
      end if
      output%mt0_map(2024) = value
    end if
    ! MT0_MAP FID2025 <- YDSURF%YSD_VF%YUCUR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(54))%fields(sf(54))%initialized /= 0) then
        value = surface%groups(sg(54))%fields(sf(54))%indices(1)
      end if
      output%mt0_map(2025) = value
    end if
    ! MT0_MAP FID2026 <- YDSURF%YSD_VF%YVCUR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(55))%fields(sf(55))%initialized /= 0) then
        value = surface%groups(sg(55))%fields(sf(55))%indices(1)
      end if
      output%mt0_map(2026) = value
    end if
    ! MT0_MAP FID2027 <- YDSURF%YSD_VF%YZ0RLF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(56))%fields(sf(56))%initialized /= 0) then
        value = surface%groups(sg(56))%fields(sf(56))%indices(1)
      end if
      output%mt0_map(2027) = value
    end if
    ! MT0_MAP FID2032 <- YDSURF%YSD_VF%YCGPP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(57))%fields(sf(57))%initialized /= 0) then
        value = surface%groups(sg(57))%fields(sf(57))%indices(1)
      end if
      output%mt0_map(2032) = value
    end if
    ! MT0_MAP FID2033 <- YDSURF%YSD_VF%YCREC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(58))%fields(sf(58))%initialized /= 0) then
        value = surface%groups(sg(58))%fields(sf(58))%indices(1)
      end if
      output%mt0_map(2033) = value
    end if
    ! MT0_MAP FID2036 <- YDSURF%YSD_VF%YSDFOR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(59))%fields(sf(59))%initialized /= 0) then
        value = surface%groups(sg(59))%fields(sf(59))%indices(1)
      end if
      output%mt0_map(2036) = value
    end if
    ! MT0_MAP FID2037 <- YDSURF%YSD_VF%YALUVP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(60))%fields(sf(60))%initialized /= 0) then
        value = surface%groups(sg(60))%fields(sf(60))%indices(1)
      end if
      output%mt0_map(2037) = value
    end if
    ! MT0_MAP FID2038 <- YDSURF%YSD_VF%YALUVD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(61))%fields(sf(61))%initialized /= 0) then
        value = surface%groups(sg(61))%fields(sf(61))%indices(1)
      end if
      output%mt0_map(2038) = value
    end if
    ! MT0_MAP FID2039 <- YDSURF%YSD_VF%YALNIP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(62))%fields(sf(62))%initialized /= 0) then
        value = surface%groups(sg(62))%fields(sf(62))%indices(1)
      end if
      output%mt0_map(2039) = value
    end if
    ! MT0_MAP FID2040 <- YDSURF%YSD_VF%YALNID%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(63))%fields(sf(63))%initialized /= 0) then
        value = surface%groups(sg(63))%fields(sf(63))%indices(1)
      end if
      output%mt0_map(2040) = value
    end if
    ! MT0_MAP FID2070 <- YDSURF%YSD_VF%YALUVI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(64))%fields(sf(64))%initialized /= 0) then
        value = surface%groups(sg(64))%fields(sf(64))%indices(1)
      end if
      output%mt0_map(2070) = value
    end if
    ! MT0_MAP FID2073 <- YDSURF%YSD_VF%YALNII%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(65))%fields(sf(65))%initialized /= 0) then
        value = surface%groups(sg(65))%fields(sf(65))%indices(1)
      end if
      output%mt0_map(2073) = value
    end if
    ! MT0_MAP FID2071 <- YDSURF%YSD_VF%YALUVV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(66))%fields(sf(66))%initialized /= 0) then
        value = surface%groups(sg(66))%fields(sf(66))%indices(1)
      end if
      output%mt0_map(2071) = value
    end if
    ! MT0_MAP FID2074 <- YDSURF%YSD_VF%YALNIV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(67))%fields(sf(67))%initialized /= 0) then
        value = surface%groups(sg(67))%fields(sf(67))%indices(1)
      end if
      output%mt0_map(2074) = value
    end if
    ! MT0_MAP FID2072 <- YDSURF%YSD_VF%YALUVG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(68))%fields(sf(68))%initialized /= 0) then
        value = surface%groups(sg(68))%fields(sf(68))%indices(1)
      end if
      output%mt0_map(2072) = value
    end if
    ! MT0_MAP FID2075 <- YDSURF%YSD_VF%YALNIG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(69))%fields(sf(69))%initialized /= 0) then
        value = surface%groups(sg(69))%fields(sf(69))%indices(1)
      end if
      output%mt0_map(2075) = value
    end if
    ! MT0_MAP FID2041 <- YDSURF%YSD_VF%YFP1%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(70))%fields(sf(70))%initialized /= 0) then
        value = surface%groups(sg(70))%fields(sf(70))%indices(1)
      end if
      output%mt0_map(2041) = value
    end if
    ! MT0_MAP FID2051 <- YDSURF%YSD_VF%YSO2DD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(71))%fields(sf(71))%initialized /= 0) then
        value = surface%groups(sg(71))%fields(sf(71))%indices(1)
      end if
      output%mt0_map(2051) = value
    end if
    ! MT0_MAP FID2056 <- YDSURF%YSD_VF%YDMSO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(72))%fields(sf(72))%initialized /= 0) then
        value = surface%groups(sg(72))%fields(sf(72))%indices(1)
      end if
      output%mt0_map(2056) = value
    end if
    ! MT0_MAP FID2058 <- YDSURF%YSD_VF%YURBF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(73))%fields(sf(73))%initialized /= 0) then
        value = surface%groups(sg(73))%fields(sf(73))%indices(1)
      end if
      output%mt0_map(2058) = value
    end if
    ! MT0_MAP FID2060 <- YDSURF%YSD_VF%YFCA1%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(74))%fields(sf(74))%initialized /= 0) then
        value = surface%groups(sg(74))%fields(sf(74))%indices(1)
      end if
      output%mt0_map(2060) = value
    end if
    ! MT0_MAP FID2061 <- YDSURF%YSD_VF%YFCA2%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(75))%fields(sf(75))%initialized /= 0) then
        value = surface%groups(sg(75))%fields(sf(75))%indices(1)
      end if
      output%mt0_map(2061) = value
    end if
    ! MT0_MAP FID2062 <- YDSURF%YSD_VF%YAERDEP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(76))%fields(sf(76))%initialized /= 0) then
        value = surface%groups(sg(76))%fields(sf(76))%indices(1)
      end if
      output%mt0_map(2062) = value
    end if
    ! MT0_MAP FID2063 <- YDSURF%YSD_VF%YAERLTS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(77))%fields(sf(77))%initialized /= 0) then
        value = surface%groups(sg(77))%fields(sf(77))%indices(1)
      end if
      output%mt0_map(2063) = value
    end if
    ! MT0_MAP FID2064 <- YDSURF%YSD_VF%YAERSCC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(78))%fields(sf(78))%initialized /= 0) then
        value = surface%groups(sg(78))%fields(sf(78))%indices(1)
      end if
      output%mt0_map(2064) = value
    end if
    ! MT0_MAP FID2065 <- YDSURF%YSD_VF%YDSF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(79))%fields(sf(79))%initialized /= 0) then
        value = surface%groups(sg(79))%fields(sf(79))%indices(1)
      end if
      output%mt0_map(2065) = value
    end if
    ! MT0_MAP FID2079 <- YDSURF%YSD_VF%YDSZ%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(80))%fields(sf(80))%initialized /= 0) then
        value = surface%groups(sg(80))%fields(sf(80))%indices(1)
      end if
      output%mt0_map(2079) = value
    end if
    ! MT0_MAP FID2067 <- YDSURF%YSD_VF%YCHEMFLXO(1)%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(81))%fields(sf(81))%initialized /= 0) then
        value = surface%groups(sg(81))%fields(sf(81))%indices(1)
        output%mt0_size(2067) = se(81)
      end if
      output%mt0_map(2067) = value
    end if
    ! MT0_MAP FID2080 <- YDSURF%YSD_VF%YCHEMWDFLX(1)%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(82))%fields(sf(82))%initialized /= 0) then
        value = surface%groups(sg(82))%fields(sf(82))%indices(1)
        output%mt0_size(2080) = se(82)
      end if
      output%mt0_map(2080) = value
    end if
    ! MT0_MAP FID2081 <- YDSURF%YSD_VF%YCHEMDDFLX(1)%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(83))%fields(sf(83))%initialized /= 0) then
        value = surface%groups(sg(83))%fields(sf(83))%indices(1)
        output%mt0_size(2081) = se(83)
      end if
      output%mt0_map(2081) = value
    end if
    ! MT0_MAP FID2068 <- YDSURF%YSD_VF%YCHEMDV(1)%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(84))%fields(sf(84))%initialized /= 0) then
        value = surface%groups(sg(84))%fields(sf(84))%indices(1)
        output%mt0_size(2068) = se(84)
      end if
      output%mt0_map(2068) = value
    end if
    ! MT0_MAP FID2069 <- YDSURF%YSD_VF%YNUDM%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(85))%fields(sf(85))%initialized /= 0) then
        value = surface%groups(sg(85))%fields(sf(85))%indices(1)
      end if
      output%mt0_map(2069) = value
    end if
    ! MT0_MAP FID2077 <- YDSURF%YSD_VF%YEMIS2D(1)%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(86))%fields(sf(86))%initialized /= 0) then
        value = surface%groups(sg(86))%fields(sf(86))%indices(1)
        output%mt0_size(2077) = se(86)
      end if
      output%mt0_map(2077) = value
    end if
    ! MT0_MAP FID2078 <- YDSURF%YSD_VF%YEMIS2DAUX(1)%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(87))%fields(sf(87))%initialized /= 0) then
        value = surface%groups(sg(87))%fields(sf(87))%indices(1)
        output%mt0_size(2078) = se(87)
      end if
      output%mt0_map(2078) = value
    end if
    ! MT0_MAP FID2101 <- YDSURF%YSD_VP%YTPC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(88))%fields(sf(88))%initialized /= 0) then
        value = surface%groups(sg(88))%fields(sf(88))%indices(1)
      end if
      output%mt0_map(2101) = value
    end if
    ! MT0_MAP FID2102 <- YDSURF%YSD_VP%YWPC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(89))%fields(sf(89))%initialized /= 0) then
        value = surface%groups(sg(89))%fields(sf(89))%indices(1)
      end if
      output%mt0_map(2102) = value
    end if
    ! MT0_MAP FID2201 <- YDSURF%YSD_VV%YARG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(90))%fields(sf(90))%initialized /= 0) then
        value = surface%groups(sg(90))%fields(sf(90))%indices(1)
      end if
      output%mt0_map(2201) = value
    end if
    ! MT0_MAP FID2202 <- YDSURF%YSD_VV%YSAB%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(91))%fields(sf(91))%initialized /= 0) then
        value = surface%groups(sg(91))%fields(sf(91))%indices(1)
      end if
      output%mt0_map(2202) = value
    end if
    ! MT0_MAP FID2203 <- YDSURF%YSD_VV%YD2%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(92))%fields(sf(92))%initialized /= 0) then
        value = surface%groups(sg(92))%fields(sf(92))%indices(1)
      end if
      output%mt0_map(2203) = value
    end if
    ! MT0_MAP FID2204 <- YDSURF%YSD_VV%YIVEG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(93))%fields(sf(93))%initialized /= 0) then
        value = surface%groups(sg(93))%fields(sf(93))%indices(1)
      end if
      output%mt0_map(2204) = value
    end if
    ! MT0_MAP FID2205 <- YDSURF%YSD_VV%YRSMIN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(94))%fields(sf(94))%initialized /= 0) then
        value = surface%groups(sg(94))%fields(sf(94))%indices(1)
      end if
      output%mt0_map(2205) = value
    end if
    ! MT0_MAP FID2206 <- YDSURF%YSD_VV%YLAI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(95))%fields(sf(95))%initialized /= 0) then
        value = surface%groups(sg(95))%fields(sf(95))%indices(1)
      end if
      output%mt0_map(2206) = value
    end if
    ! MT0_MAP FID2207 <- YDSURF%YSD_VV%YHV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(96))%fields(sf(96))%initialized /= 0) then
        value = surface%groups(sg(96))%fields(sf(96))%indices(1)
      end if
      output%mt0_map(2207) = value
    end if
    ! MT0_MAP FID2208 <- YDSURF%YSD_VV%YZ0H%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(97))%fields(sf(97))%initialized /= 0) then
        value = surface%groups(sg(97))%fields(sf(97))%indices(1)
      end if
      output%mt0_map(2208) = value
    end if
    ! MT0_MAP FID2209 <- YDSURF%YSD_VV%YALS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(98))%fields(sf(98))%initialized /= 0) then
        value = surface%groups(sg(98))%fields(sf(98))%indices(1)
      end if
      output%mt0_map(2209) = value
    end if
    ! MT0_MAP FID2210 <- YDSURF%YSD_VV%YALV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(99))%fields(sf(99))%initialized /= 0) then
        value = surface%groups(sg(99))%fields(sf(99))%indices(1)
      end if
      output%mt0_map(2210) = value
    end if
    ! MT0_MAP FID2301 <- YDSURF%YSD_VN%YTOP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(100))%fields(sf(100))%initialized /= 0) then
        value = surface%groups(sg(100))%fields(sf(100))%indices(1)
      end if
      output%mt0_map(2301) = value
    end if
    ! MT0_MAP FID2302 <- YDSURF%YSD_VN%YBAS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(101))%fields(sf(101))%initialized /= 0) then
        value = surface%groups(sg(101))%fields(sf(101))%indices(1)
      end if
      output%mt0_map(2302) = value
    end if
    ! MT0_MAP FID2303 <- YDSURF%YSD_VN%YACPR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(102))%fields(sf(102))%initialized /= 0) then
        value = surface%groups(sg(102))%fields(sf(102))%indices(1)
      end if
      output%mt0_map(2303) = value
    end if
    ! MT0_MAP FID2304 <- YDSURF%YSD_VN%YACCPR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(103))%fields(sf(103))%initialized /= 0) then
        value = surface%groups(sg(103))%fields(sf(103))%indices(1)
      end if
      output%mt0_map(2304) = value
    end if
    ! MT0_MAP FID2305 <- YDSURF%YSD_VN%YACCPR5%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(104))%fields(sf(104))%initialized /= 0) then
        value = surface%groups(sg(104))%fields(sf(104))%indices(1)
      end if
      output%mt0_map(2305) = value
    end if
    ! MT0_MAP FID2401 <- YDSURF%YSD_VH%YTCCH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(105))%fields(sf(105))%initialized /= 0) then
        value = surface%groups(sg(105))%fields(sf(105))%indices(1)
      end if
      output%mt0_map(2401) = value
    end if
    ! MT0_MAP FID2402 <- YDSURF%YSD_VH%YSCCH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(106))%fields(sf(106))%initialized /= 0) then
        value = surface%groups(sg(106))%fields(sf(106))%indices(1)
      end if
      output%mt0_map(2402) = value
    end if
    ! MT0_MAP FID2403 <- YDSURF%YSD_VH%YBCCH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(107))%fields(sf(107))%initialized /= 0) then
        value = surface%groups(sg(107))%fields(sf(107))%indices(1)
      end if
      output%mt0_map(2403) = value
    end if
    ! MT0_MAP FID2404 <- YDSURF%YSD_VH%YPBLH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(108))%fields(sf(108))%initialized /= 0) then
        value = surface%groups(sg(108))%fields(sf(108))%indices(1)
      end if
      output%mt0_map(2404) = value
    end if
    ! MT0_MAP FID2405 <- YDSURF%YSD_VH%YSPSH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(109))%fields(sf(109))%initialized /= 0) then
        value = surface%groups(sg(109))%fields(sf(109))%indices(1)
      end if
      output%mt0_map(2405) = value
    end if
    ! MT0_MAP FID2405 <- YDSURF%YSD_VH%YSPSH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(109))%fields(sf(109))%initialized /= 0) then
        value = surface%groups(sg(109))%fields(sf(109))%indices(1)
      end if
      output%mt0_map(2405) = value
    end if
    ! MT0_MAP FID2501 <- YDSURF%YSD_VA%YSEA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(110))%fields(sf(110))%initialized /= 0) then
        value = surface%groups(sg(110))%fields(sf(110))%indices(1)
      end if
      output%mt0_map(2501) = value
    end if
    ! MT0_MAP FID2502 <- YDSURF%YSD_VA%YLAN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(111))%fields(sf(111))%initialized /= 0) then
        value = surface%groups(sg(111))%fields(sf(111))%indices(1)
      end if
      output%mt0_map(2502) = value
    end if
    ! MT0_MAP FID2503 <- YDSURF%YSD_VA%YSOO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(112))%fields(sf(112))%initialized /= 0) then
        value = surface%groups(sg(112))%fields(sf(112))%indices(1)
      end if
      output%mt0_map(2503) = value
    end if
    ! MT0_MAP FID2504 <- YDSURF%YSD_VA%YDES%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(113))%fields(sf(113))%initialized /= 0) then
        value = surface%groups(sg(113))%fields(sf(113))%indices(1)
      end if
      output%mt0_map(2504) = value
    end if
    ! MT0_MAP FID2505 <- YDSURF%YSD_VA%YSUL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(114))%fields(sf(114))%initialized /= 0) then
        value = surface%groups(sg(114))%fields(sf(114))%indices(1)
      end if
      output%mt0_map(2505) = value
    end if
    ! MT0_MAP FID2506 <- YDSURF%YSD_VA%YVOL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(115))%fields(sf(115))%initialized /= 0) then
        value = surface%groups(sg(115))%fields(sf(115))%indices(1)
      end if
      output%mt0_map(2506) = value
    end if
    ! MT0_MAP FID2701 <- YDSURF%YSD_VC%YA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(116))%fields(sf(116))%initialized /= 0) then
        value = surface%groups(sg(116))%fields(sf(116))%indices(1)
      end if
      output%mt0_map(2701) = value
    end if
    ! MT0_MAP FID2702 <- YDSURF%YSD_VC%YB%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(117))%fields(sf(117))%initialized /= 0) then
        value = surface%groups(sg(117))%fields(sf(117))%indices(1)
      end if
      output%mt0_map(2702) = value
    end if
    ! MT0_MAP FID2703 <- YDSURF%YSD_VC%YC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(118))%fields(sf(118))%initialized /= 0) then
        value = surface%groups(sg(118))%fields(sf(118))%indices(1)
      end if
      output%mt0_map(2703) = value
    end if
    ! MT0_MAP FID2801 <- YDSURF%YSD_V2%YOCDEP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(119))%fields(sf(119))%initialized /= 0) then
        value = surface%groups(sg(119))%fields(sf(119))%indices(1)
      end if
      output%mt0_map(2801) = value
    end if
    ! MT0_MAP FID2802 <- YDSURF%YSD_V2%YUSTRC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(120))%fields(sf(120))%initialized /= 0) then
        value = surface%groups(sg(120))%fields(sf(120))%indices(1)
      end if
      output%mt0_map(2802) = value
    end if
    ! MT0_MAP FID2803 <- YDSURF%YSD_V2%YVSTRC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(121))%fields(sf(121))%initialized /= 0) then
        value = surface%groups(sg(121))%fields(sf(121))%indices(1)
      end if
      output%mt0_map(2803) = value
    end if
    ! MT0_MAP FID2901 <- YDSURF%YSD_V3%YDIFM%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(122))%fields(sf(122))%initialized /= 0) then
        value = surface%groups(sg(122))%fields(sf(122))%indices(1)
      end if
      output%mt0_map(2901) = value
    end if
    ! MT0_MAP FID2902 <- YDSURF%YSD_V3%YDIFT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(123))%fields(sf(123))%initialized /= 0) then
        value = surface%groups(sg(123))%fields(sf(123))%indices(1)
      end if
      output%mt0_map(2902) = value
    end if
    ! MT0_MAP FID2903 <- YDSURF%YSD_V3%YDIFS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(124))%fields(sf(124))%initialized /= 0) then
        value = surface%groups(sg(124))%fields(sf(124))%indices(1)
      end if
      output%mt0_map(2903) = value
    end if
    ! MT0_MAP FID2904 <- YDSURF%YSD_V3%YADVT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(125))%fields(sf(125))%initialized /= 0) then
        value = surface%groups(sg(125))%fields(sf(125))%indices(1)
      end if
      output%mt0_map(2904) = value
    end if
    ! MT0_MAP FID2905 <- YDSURF%YSD_V3%YADVS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(126))%fields(sf(126))%initialized /= 0) then
        value = surface%groups(sg(126))%fields(sf(126))%indices(1)
      end if
      output%mt0_map(2905) = value
    end if
    ! MT0_MAP FID2906 <- YDSURF%YSD_V3%YTRI0%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(127))%fields(sf(127))%initialized /= 0) then
        value = surface%groups(sg(127))%fields(sf(127))%indices(1)
      end if
      output%mt0_map(2906) = value
    end if
    ! MT0_MAP FID2907 <- YDSURF%YSD_V3%YTRI1%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(128))%fields(sf(128))%initialized /= 0) then
        value = surface%groups(sg(128))%fields(sf(128))%indices(1)
      end if
      output%mt0_map(2907) = value
    end if
    ! MT0_MAP FID2908 <- YDSURF%YSD_V3%YSWDK%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(129))%fields(sf(129))%initialized /= 0) then
        value = surface%groups(sg(129))%fields(sf(129))%indices(1)
      end if
      output%mt0_map(2908) = value
    end if
    ! MT0_MAP FID2909 <- YDSURF%YSD_V3%YZO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(130))%fields(sf(130))%initialized /= 0) then
        value = surface%groups(sg(130))%fields(sf(130))%indices(1)
      end if
      output%mt0_map(2909) = value
    end if
    ! MT0_MAP FID2910 <- YDSURF%YSD_V3%YHO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(131))%fields(sf(131))%initialized /= 0) then
        value = surface%groups(sg(131))%fields(sf(131))%indices(1)
      end if
      output%mt0_map(2910) = value
    end if
    ! MT0_MAP FID2911 <- YDSURF%YSD_V3%YDO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(132))%fields(sf(132))%initialized /= 0) then
        value = surface%groups(sg(132))%fields(sf(132))%indices(1)
      end if
      output%mt0_map(2911) = value
    end if
    ! MT0_MAP FID2912 <- YDSURF%YSD_V3%YHO_INV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(133))%fields(sf(133))%initialized /= 0) then
        value = surface%groups(sg(133))%fields(sf(133))%indices(1)
      end if
      output%mt0_map(2912) = value
    end if
    ! MT0_MAP FID2913 <- YDSURF%YSD_V3%YUOC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(134))%fields(sf(134))%initialized /= 0) then
        value = surface%groups(sg(134))%fields(sf(134))%indices(1)
      end if
      output%mt0_map(2913) = value
    end if
    ! MT0_MAP FID2914 <- YDSURF%YSD_V3%YVOC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(135))%fields(sf(135))%initialized /= 0) then
        value = surface%groups(sg(135))%fields(sf(135))%indices(1)
      end if
      output%mt0_map(2914) = value
    end if
    ! MT0_MAP FID2915 <- YDSURF%YSD_V3%YOTKE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(136))%fields(sf(136))%initialized /= 0) then
        value = surface%groups(sg(136))%fields(sf(136))%indices(1)
      end if
      output%mt0_map(2915) = value
    end if
    ! MT0_MAP FID3001 <- YDSURF%YSD_VD%YLSP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(137))%fields(sf(137))%initialized /= 0) then
        value = surface%groups(sg(137))%fields(sf(137))%indices(1)
      end if
      output%mt0_map(3001) = value
    end if
    ! MT0_MAP FID3002 <- YDSURF%YSD_VD%YCP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(138))%fields(sf(138))%initialized /= 0) then
        value = surface%groups(sg(138))%fields(sf(138))%indices(1)
      end if
      output%mt0_map(3002) = value
    end if
    ! MT0_MAP FID3003 <- YDSURF%YSD_VD%YSF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(139))%fields(sf(139))%initialized /= 0) then
        value = surface%groups(sg(139))%fields(sf(139))%indices(1)
      end if
      output%mt0_map(3003) = value
    end if
    ! MT0_MAP FID3004 <- YDSURF%YSD_VD%YFZRA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(140))%fields(sf(140))%initialized /= 0) then
        value = surface%groups(sg(140))%fields(sf(140))%indices(1)
      end if
      output%mt0_map(3004) = value
    end if
    ! MT0_MAP FID3005 <- YDSURF%YSD_VD%YBLD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(141))%fields(sf(141))%initialized /= 0) then
        value = surface%groups(sg(141))%fields(sf(141))%indices(1)
      end if
      output%mt0_map(3005) = value
    end if
    ! MT0_MAP FID3006 <- YDSURF%YSD_VD%YSSHF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(142))%fields(sf(142))%initialized /= 0) then
        value = surface%groups(sg(142))%fields(sf(142))%indices(1)
      end if
      output%mt0_map(3006) = value
    end if
    ! MT0_MAP FID3007 <- YDSURF%YSD_VD%YSLHF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(143))%fields(sf(143))%initialized /= 0) then
        value = surface%groups(sg(143))%fields(sf(143))%indices(1)
      end if
      output%mt0_map(3007) = value
    end if
    ! MT0_MAP FID3008 <- YDSURF%YSD_VD%YNEE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(144))%fields(sf(144))%initialized /= 0) then
        value = surface%groups(sg(144))%fields(sf(144))%indices(1)
      end if
      output%mt0_map(3008) = value
    end if
    ! MT0_MAP FID3009 <- YDSURF%YSD_VD%YGPP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(145))%fields(sf(145))%initialized /= 0) then
        value = surface%groups(sg(145))%fields(sf(145))%indices(1)
      end if
      output%mt0_map(3009) = value
    end if
    ! MT0_MAP FID3010 <- YDSURF%YSD_VD%YREC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(146))%fields(sf(146))%initialized /= 0) then
        value = surface%groups(sg(146))%fields(sf(146))%indices(1)
      end if
      output%mt0_map(3010) = value
    end if
    ! MT0_MAP FID3011 <- YDSURF%YSD_VD%YMSL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(147))%fields(sf(147))%initialized /= 0) then
        value = surface%groups(sg(147))%fields(sf(147))%indices(1)
      end if
      output%mt0_map(3011) = value
    end if
    ! MT0_MAP FID3012 <- YDSURF%YSD_VD%YSP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(148))%fields(sf(148))%initialized /= 0) then
        value = surface%groups(sg(148))%fields(sf(148))%indices(1)
      end if
      output%mt0_map(3012) = value
    end if
    ! MT0_MAP FID3013 <- YDSURF%YSD_VD%YTCC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(149))%fields(sf(149))%initialized /= 0) then
        value = surface%groups(sg(149))%fields(sf(149))%indices(1)
      end if
      output%mt0_map(3013) = value
    end if
    ! MT0_MAP FID3014 <- YDSURF%YSD_VD%Y10U%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(150))%fields(sf(150))%initialized /= 0) then
        value = surface%groups(sg(150))%fields(sf(150))%indices(1)
      end if
      output%mt0_map(3014) = value
    end if
    ! MT0_MAP FID3015 <- YDSURF%YSD_VD%Y10V%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(151))%fields(sf(151))%initialized /= 0) then
        value = surface%groups(sg(151))%fields(sf(151))%indices(1)
      end if
      output%mt0_map(3015) = value
    end if
    ! MT0_MAP FID3016 <- YDSURF%YSD_VD%Y2T%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(152))%fields(sf(152))%initialized /= 0) then
        value = surface%groups(sg(152))%fields(sf(152))%indices(1)
      end if
      output%mt0_map(3016) = value
    end if
    ! MT0_MAP FID3017 <- YDSURF%YSD_VD%Y2D%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(153))%fields(sf(153))%initialized /= 0) then
        value = surface%groups(sg(153))%fields(sf(153))%indices(1)
      end if
      output%mt0_map(3017) = value
    end if
    ! MT0_MAP FID3143 <- YDSURF%YSD_VD%Y2SH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(154))%fields(sf(154))%initialized /= 0) then
        value = surface%groups(sg(154))%fields(sf(154))%indices(1)
      end if
      output%mt0_map(3143) = value
    end if
    ! MT0_MAP FID3018 <- YDSURF%YSD_VD%YSSR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(155))%fields(sf(155))%initialized /= 0) then
        value = surface%groups(sg(155))%fields(sf(155))%indices(1)
      end if
      output%mt0_map(3018) = value
    end if
    ! MT0_MAP FID3019 <- YDSURF%YSD_VD%YSTR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(156))%fields(sf(156))%initialized /= 0) then
        value = surface%groups(sg(156))%fields(sf(156))%indices(1)
      end if
      output%mt0_map(3019) = value
    end if
    ! MT0_MAP FID3020 <- YDSURF%YSD_VD%YTSR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(157))%fields(sf(157))%initialized /= 0) then
        value = surface%groups(sg(157))%fields(sf(157))%indices(1)
      end if
      output%mt0_map(3020) = value
    end if
    ! MT0_MAP FID3021 <- YDSURF%YSD_VD%YTTR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(158))%fields(sf(158))%initialized /= 0) then
        value = surface%groups(sg(158))%fields(sf(158))%indices(1)
      end if
      output%mt0_map(3021) = value
    end if
    ! MT0_MAP FID3022 <- YDSURF%YSD_VD%YEWSS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(159))%fields(sf(159))%initialized /= 0) then
        value = surface%groups(sg(159))%fields(sf(159))%indices(1)
      end if
      output%mt0_map(3022) = value
    end if
    ! MT0_MAP FID3023 <- YDSURF%YSD_VD%YNSSS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(160))%fields(sf(160))%initialized /= 0) then
        value = surface%groups(sg(160))%fields(sf(160))%indices(1)
      end if
      output%mt0_map(3023) = value
    end if
    ! MT0_MAP FID3024 <- YDSURF%YSD_VD%YE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(161))%fields(sf(161))%initialized /= 0) then
        value = surface%groups(sg(161))%fields(sf(161))%indices(1)
      end if
      output%mt0_map(3024) = value
    end if
    ! MT0_MAP FID3025 <- YDSURF%YSD_VD%YPEV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(162))%fields(sf(162))%initialized /= 0) then
        value = surface%groups(sg(162))%fields(sf(162))%indices(1)
      end if
      output%mt0_map(3025) = value
    end if
    ! MT0_MAP FID3026 <- YDSURF%YSD_VD%YCCC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(163))%fields(sf(163))%initialized /= 0) then
        value = surface%groups(sg(163))%fields(sf(163))%indices(1)
      end if
      output%mt0_map(3026) = value
    end if
    ! MT0_MAP FID3027 <- YDSURF%YSD_VD%YLCC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(164))%fields(sf(164))%initialized /= 0) then
        value = surface%groups(sg(164))%fields(sf(164))%indices(1)
      end if
      output%mt0_map(3027) = value
    end if
    ! MT0_MAP FID3028 <- YDSURF%YSD_VD%YMCC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(165))%fields(sf(165))%initialized /= 0) then
        value = surface%groups(sg(165))%fields(sf(165))%indices(1)
      end if
      output%mt0_map(3028) = value
    end if
    ! MT0_MAP FID3029 <- YDSURF%YSD_VD%YHCC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(166))%fields(sf(166))%initialized /= 0) then
        value = surface%groups(sg(166))%fields(sf(166))%indices(1)
      end if
      output%mt0_map(3029) = value
    end if
    ! MT0_MAP FID3030 <- YDSURF%YSD_VD%YLGWS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(167))%fields(sf(167))%initialized /= 0) then
        value = surface%groups(sg(167))%fields(sf(167))%indices(1)
      end if
      output%mt0_map(3030) = value
    end if
    ! MT0_MAP FID3031 <- YDSURF%YSD_VD%YMGWS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(168))%fields(sf(168))%initialized /= 0) then
        value = surface%groups(sg(168))%fields(sf(168))%indices(1)
      end if
      output%mt0_map(3031) = value
    end if
    ! MT0_MAP FID3032 <- YDSURF%YSD_VD%YGWD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(169))%fields(sf(169))%initialized /= 0) then
        value = surface%groups(sg(169))%fields(sf(169))%indices(1)
      end if
      output%mt0_map(3032) = value
    end if
    ! MT0_MAP FID3033 <- YDSURF%YSD_VD%YMX2T%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(170))%fields(sf(170))%initialized /= 0) then
        value = surface%groups(sg(170))%fields(sf(170))%indices(1)
      end if
      output%mt0_map(3033) = value
    end if
    ! MT0_MAP FID3034 <- YDSURF%YSD_VD%YMN2T%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(171))%fields(sf(171))%initialized /= 0) then
        value = surface%groups(sg(171))%fields(sf(171))%indices(1)
      end if
      output%mt0_map(3034) = value
    end if
    ! MT0_MAP FID3037 <- YDSURF%YSD_VD%YRO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(172))%fields(sf(172))%initialized /= 0) then
        value = surface%groups(sg(172))%fields(sf(172))%indices(1)
      end if
      output%mt0_map(3037) = value
    end if
    ! MT0_MAP FID3038 <- YDSURF%YSD_VD%YSRO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(173))%fields(sf(173))%initialized /= 0) then
        value = surface%groups(sg(173))%fields(sf(173))%indices(1)
      end if
      output%mt0_map(3038) = value
    end if
    ! MT0_MAP FID3039 <- YDSURF%YSD_VD%YSSRO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(174))%fields(sf(174))%initialized /= 0) then
        value = surface%groups(sg(174))%fields(sf(174))%indices(1)
      end if
      output%mt0_map(3039) = value
    end if
    ! MT0_MAP FID3040 <- YDSURF%YSD_VD%YALB%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(175))%fields(sf(175))%initialized /= 0) then
        value = surface%groups(sg(175))%fields(sf(175))%indices(1)
      end if
      output%mt0_map(3040) = value
    end if
    ! MT0_MAP FID3041 <- YDSURF%YSD_VD%YIEWSS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(176))%fields(sf(176))%initialized /= 0) then
        value = surface%groups(sg(176))%fields(sf(176))%indices(1)
      end if
      output%mt0_map(3041) = value
    end if
    ! MT0_MAP FID3042 <- YDSURF%YSD_VD%YINSSS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(177))%fields(sf(177))%initialized /= 0) then
        value = surface%groups(sg(177))%fields(sf(177))%indices(1)
      end if
      output%mt0_map(3042) = value
    end if
    ! MT0_MAP FID3043 <- YDSURF%YSD_VD%YISSHF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(178))%fields(sf(178))%initialized /= 0) then
        value = surface%groups(sg(178))%fields(sf(178))%indices(1)
      end if
      output%mt0_map(3043) = value
    end if
    ! MT0_MAP FID3044 <- YDSURF%YSD_VD%YIE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(179))%fields(sf(179))%initialized /= 0) then
        value = surface%groups(sg(179))%fields(sf(179))%indices(1)
      end if
      output%mt0_map(3044) = value
    end if
    ! MT0_MAP FID3045 <- YDSURF%YSD_VD%YINEE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(180))%fields(sf(180))%initialized /= 0) then
        value = surface%groups(sg(180))%fields(sf(180))%indices(1)
      end if
      output%mt0_map(3045) = value
    end if
    ! MT0_MAP FID3046 <- YDSURF%YSD_VD%YIGPP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(181))%fields(sf(181))%initialized /= 0) then
        value = surface%groups(sg(181))%fields(sf(181))%indices(1)
      end if
      output%mt0_map(3046) = value
    end if
    ! MT0_MAP FID3047 <- YDSURF%YSD_VD%YIREC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(182))%fields(sf(182))%initialized /= 0) then
        value = surface%groups(sg(182))%fields(sf(182))%indices(1)
      end if
      output%mt0_map(3047) = value
    end if
    ! MT0_MAP FID3154 <- YDSURF%YSD_VD%YICH4%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(183))%fields(sf(183))%initialized /= 0) then
        value = surface%groups(sg(183))%fields(sf(183))%indices(1)
      end if
      output%mt0_map(3154) = value
    end if
    ! MT0_MAP FID3048 <- YDSURF%YSD_VD%YCSF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(184))%fields(sf(184))%initialized /= 0) then
        value = surface%groups(sg(184))%fields(sf(184))%indices(1)
      end if
      output%mt0_map(3048) = value
    end if
    ! MT0_MAP FID3049 <- YDSURF%YSD_VD%YLSSF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(185))%fields(sf(185))%initialized /= 0) then
        value = surface%groups(sg(185))%fields(sf(185))%indices(1)
      end if
      output%mt0_map(3049) = value
    end if
    ! MT0_MAP FID3050 <- YDSURF%YSD_VD%YMXTPR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(186))%fields(sf(186))%initialized /= 0) then
        value = surface%groups(sg(186))%fields(sf(186))%indices(1)
      end if
      output%mt0_map(3050) = value
    end if
    ! MT0_MAP FID3051 <- YDSURF%YSD_VD%YMNTPR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(187))%fields(sf(187))%initialized /= 0) then
        value = surface%groups(sg(187))%fields(sf(187))%indices(1)
      end if
      output%mt0_map(3051) = value
    end if
    ! MT0_MAP FID3054 <- YDSURF%YSD_VD%YTPR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(188))%fields(sf(188))%initialized /= 0) then
        value = surface%groups(sg(188))%fields(sf(188))%indices(1)
      end if
      output%mt0_map(3054) = value
    end if
    ! MT0_MAP FID3055 <- YDSURF%YSD_VD%YLSRR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(189))%fields(sf(189))%initialized /= 0) then
        value = surface%groups(sg(189))%fields(sf(189))%indices(1)
      end if
      output%mt0_map(3055) = value
    end if
    ! MT0_MAP FID3056 <- YDSURF%YSD_VD%YCRR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(190))%fields(sf(190))%initialized /= 0) then
        value = surface%groups(sg(190))%fields(sf(190))%indices(1)
      end if
      output%mt0_map(3056) = value
    end if
    ! MT0_MAP FID3057 <- YDSURF%YSD_VD%YLSSFR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(191))%fields(sf(191))%initialized /= 0) then
        value = surface%groups(sg(191))%fields(sf(191))%indices(1)
      end if
      output%mt0_map(3057) = value
    end if
    ! MT0_MAP FID3058 <- YDSURF%YSD_VD%YCSFR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(192))%fields(sf(192))%initialized /= 0) then
        value = surface%groups(sg(192))%fields(sf(192))%indices(1)
      end if
      output%mt0_map(3058) = value
    end if
    ! MT0_MAP FID3059 <- YDSURF%YSD_VD%YPTYPE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(193))%fields(sf(193))%initialized /= 0) then
        value = surface%groups(sg(193))%fields(sf(193))%indices(1)
      end if
      output%mt0_map(3059) = value
    end if
    ! MT0_MAP FID3060 <- YDSURF%YSD_VD%YILSPF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(194))%fields(sf(194))%initialized /= 0) then
        value = surface%groups(sg(194))%fields(sf(194))%indices(1)
      end if
      output%mt0_map(3060) = value
    end if
    ! MT0_MAP FID3061 <- YDSURF%YSD_VD%YZ0F%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(195))%fields(sf(195))%initialized /= 0) then
        value = surface%groups(sg(195))%fields(sf(195))%indices(1)
      end if
      output%mt0_map(3061) = value
    end if
    ! MT0_MAP FID3062 <- YDSURF%YSD_VD%YLZ0H%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(196))%fields(sf(196))%initialized /= 0) then
        value = surface%groups(sg(196))%fields(sf(196))%indices(1)
      end if
      output%mt0_map(3062) = value
    end if
    ! MT0_MAP FID3063 <- YDSURF%YSD_VD%YTCW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(197))%fields(sf(197))%initialized /= 0) then
        value = surface%groups(sg(197))%fields(sf(197))%indices(1)
      end if
      output%mt0_map(3063) = value
    end if
    ! MT0_MAP FID3064 <- YDSURF%YSD_VD%YTCWV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(198))%fields(sf(198))%initialized /= 0) then
        value = surface%groups(sg(198))%fields(sf(198))%indices(1)
      end if
      output%mt0_map(3064) = value
    end if
    ! MT0_MAP FID3065 <- YDSURF%YSD_VD%YTCLW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(199))%fields(sf(199))%initialized /= 0) then
        value = surface%groups(sg(199))%fields(sf(199))%indices(1)
      end if
      output%mt0_map(3065) = value
    end if
    ! MT0_MAP FID3066 <- YDSURF%YSD_VD%YTCIW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(200))%fields(sf(200))%initialized /= 0) then
        value = surface%groups(sg(200))%fields(sf(200))%indices(1)
      end if
      output%mt0_map(3066) = value
    end if
    ! MT0_MAP FID3067 <- YDSURF%YSD_VD%YTCRW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(201))%fields(sf(201))%initialized /= 0) then
        value = surface%groups(sg(201))%fields(sf(201))%indices(1)
      end if
      output%mt0_map(3067) = value
    end if
    ! MT0_MAP FID3068 <- YDSURF%YSD_VD%YTCSW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(202))%fields(sf(202))%initialized /= 0) then
        value = surface%groups(sg(202))%fields(sf(202))%indices(1)
      end if
      output%mt0_map(3068) = value
    end if
    ! MT0_MAP FID3069 <- YDSURF%YSD_VD%YTCSLW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(203))%fields(sf(203))%initialized /= 0) then
        value = surface%groups(sg(203))%fields(sf(203))%indices(1)
      end if
      output%mt0_map(3069) = value
    end if
    ! MT0_MAP FID3070 <- YDSURF%YSD_VD%YSSRD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(204))%fields(sf(204))%initialized /= 0) then
        value = surface%groups(sg(204))%fields(sf(204))%indices(1)
      end if
      output%mt0_map(3070) = value
    end if
    ! MT0_MAP FID3071 <- YDSURF%YSD_VD%YSTRD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(205))%fields(sf(205))%initialized /= 0) then
        value = surface%groups(sg(205))%fields(sf(205))%indices(1)
      end if
      output%mt0_map(3071) = value
    end if
    ! MT0_MAP FID3072 <- YDSURF%YSD_VD%YSSRDC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(206))%fields(sf(206))%initialized /= 0) then
        value = surface%groups(sg(206))%fields(sf(206))%indices(1)
      end if
      output%mt0_map(3072) = value
    end if
    ! MT0_MAP FID3073 <- YDSURF%YSD_VD%YSTRDC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(207))%fields(sf(207))%initialized /= 0) then
        value = surface%groups(sg(207))%fields(sf(207))%indices(1)
      end if
      output%mt0_map(3073) = value
    end if
    ! MT0_MAP FID3074 <- YDSURF%YSD_VD%YBLH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(208))%fields(sf(208))%initialized /= 0) then
        value = surface%groups(sg(208))%fields(sf(208))%indices(1)
      end if
      output%mt0_map(3074) = value
    end if
    ! MT0_MAP FID3075 <- YDSURF%YSD_VD%YSUND%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(209))%fields(sf(209))%initialized /= 0) then
        value = surface%groups(sg(209))%fields(sf(209))%indices(1)
      end if
      output%mt0_map(3075) = value
    end if
    ! MT0_MAP FID3076 <- YDSURF%YSD_VD%YSPAR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(210))%fields(sf(210))%initialized /= 0) then
        value = surface%groups(sg(210))%fields(sf(210))%indices(1)
      end if
      output%mt0_map(3076) = value
    end if
    ! MT0_MAP FID3077 <- YDSURF%YSD_VD%YSUVB%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(211))%fields(sf(211))%initialized /= 0) then
        value = surface%groups(sg(211))%fields(sf(211))%indices(1)
      end if
      output%mt0_map(3077) = value
    end if
    ! MT0_MAP FID3078 <- YDSURF%YSD_VD%YSFDIR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(212))%fields(sf(212))%initialized /= 0) then
        value = surface%groups(sg(212))%fields(sf(212))%indices(1)
      end if
      output%mt0_map(3078) = value
    end if
    ! MT0_MAP FID3079 <- YDSURF%YSD_VD%YSCDIR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(213))%fields(sf(213))%initialized /= 0) then
        value = surface%groups(sg(213))%fields(sf(213))%indices(1)
      end if
      output%mt0_map(3079) = value
    end if
    ! MT0_MAP FID3080 <- YDSURF%YSD_VD%YSDSRP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(214))%fields(sf(214))%initialized /= 0) then
        value = surface%groups(sg(214))%fields(sf(214))%indices(1)
      end if
      output%mt0_map(3080) = value
    end if
    ! MT0_MAP FID3081 <- YDSURF%YSD_VD%YCAPE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(215))%fields(sf(215))%initialized /= 0) then
        value = surface%groups(sg(215))%fields(sf(215))%indices(1)
      end if
      output%mt0_map(3081) = value
    end if
    ! MT0_MAP FID3082 <- YDSURF%YSD_VD%YCAPES%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(216))%fields(sf(216))%initialized /= 0) then
        value = surface%groups(sg(216))%fields(sf(216))%indices(1)
      end if
      output%mt0_map(3082) = value
    end if
    ! MT0_MAP FID3146 <- YDSURF%YSD_VD%YMUCAPE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(217))%fields(sf(217))%initialized /= 0) then
        value = surface%groups(sg(217))%fields(sf(217))%indices(1)
      end if
      output%mt0_map(3146) = value
    end if
    ! MT0_MAP FID3147 <- YDSURF%YSD_VD%YPDEPL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(218))%fields(sf(218))%initialized /= 0) then
        value = surface%groups(sg(218))%fields(sf(218))%indices(1)
      end if
      output%mt0_map(3147) = value
    end if
    ! MT0_MAP FID3148 <- YDSURF%YSD_VD%YMLCAPE50%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(219))%fields(sf(219))%initialized /= 0) then
        value = surface%groups(sg(219))%fields(sf(219))%indices(1)
      end if
      output%mt0_map(3148) = value
    end if
    ! MT0_MAP FID3149 <- YDSURF%YSD_VD%YMLCAPE100%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(220))%fields(sf(220))%initialized /= 0) then
        value = surface%groups(sg(220))%fields(sf(220))%indices(1)
      end if
      output%mt0_map(3149) = value
    end if
    ! MT0_MAP FID3150 <- YDSURF%YSD_VD%YMLCIN50%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(221))%fields(sf(221))%initialized /= 0) then
        value = surface%groups(sg(221))%fields(sf(221))%indices(1)
      end if
      output%mt0_map(3150) = value
    end if
    ! MT0_MAP FID3151 <- YDSURF%YSD_VD%YMLCIN100%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(222))%fields(sf(222))%initialized /= 0) then
        value = surface%groups(sg(222))%fields(sf(222))%indices(1)
      end if
      output%mt0_map(3151) = value
    end if
    ! MT0_MAP FID3152 <- YDSURF%YSD_VD%YTROPOTP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(223))%fields(sf(223))%initialized /= 0) then
        value = surface%groups(sg(223))%fields(sf(223))%indices(1)
      end if
      output%mt0_map(3152) = value
    end if
    ! MT0_MAP FID3083 <- YDSURF%YSD_VD%YTSRC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(224))%fields(sf(224))%initialized /= 0) then
        value = surface%groups(sg(224))%fields(sf(224))%indices(1)
      end if
      output%mt0_map(3083) = value
    end if
    ! MT0_MAP FID3084 <- YDSURF%YSD_VD%YTTRC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(225))%fields(sf(225))%initialized /= 0) then
        value = surface%groups(sg(225))%fields(sf(225))%indices(1)
      end if
      output%mt0_map(3084) = value
    end if
    ! MT0_MAP FID3085 <- YDSURF%YSD_VD%YSSRC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(226))%fields(sf(226))%initialized /= 0) then
        value = surface%groups(sg(226))%fields(sf(226))%indices(1)
      end if
      output%mt0_map(3085) = value
    end if
    ! MT0_MAP FID3086 <- YDSURF%YSD_VD%YSTRC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(227))%fields(sf(227))%initialized /= 0) then
        value = surface%groups(sg(227))%fields(sf(227))%indices(1)
      end if
      output%mt0_map(3086) = value
    end if
    ! MT0_MAP FID3087 <- YDSURF%YSD_VD%YES%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(228))%fields(sf(228))%initialized /= 0) then
        value = surface%groups(sg(228))%fields(sf(228))%indices(1)
      end if
      output%mt0_map(3087) = value
    end if
    ! MT0_MAP FID3088 <- YDSURF%YSD_VD%YSMLT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(229))%fields(sf(229))%initialized /= 0) then
        value = surface%groups(sg(229))%fields(sf(229))%indices(1)
      end if
      output%mt0_map(3088) = value
    end if
    ! MT0_MAP FID3089 <- YDSURF%YSD_VD%Y10FG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(230))%fields(sf(230))%initialized /= 0) then
        value = surface%groups(sg(230))%fields(sf(230))%indices(1)
      end if
      output%mt0_map(3089) = value
    end if
    ! MT0_MAP FID3091 <- YDSURF%YSD_VD%Y10FGCV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(231))%fields(sf(231))%initialized /= 0) then
        value = surface%groups(sg(231))%fields(sf(231))%indices(1)
      end if
      output%mt0_map(3091) = value
    end if
    ! MT0_MAP FID3092 <- YDSURF%YSD_VD%YI10FG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(232))%fields(sf(232))%initialized /= 0) then
        value = surface%groups(sg(232))%fields(sf(232))%indices(1)
      end if
      output%mt0_map(3092) = value
    end if
    ! MT0_MAP FID3093 <- YDSURF%YSD_VD%YLSPF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(233))%fields(sf(233))%initialized /= 0) then
        value = surface%groups(sg(233))%fields(sf(233))%indices(1)
      end if
      output%mt0_map(3093) = value
    end if
    ! MT0_MAP FID3094 <- YDSURF%YSD_VD%YTCO3%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(234))%fields(sf(234))%initialized /= 0) then
        value = surface%groups(sg(234))%fields(sf(234))%indices(1)
      end if
      output%mt0_map(3094) = value
    end if
    ! MT0_MAP FID3095 <- YDSURF%YSD_VD%YVIMD%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(235))%fields(sf(235))%initialized /= 0) then
        value = surface%groups(sg(235))%fields(sf(235))%indices(1)
      end if
      output%mt0_map(3095) = value
    end if
    ! MT0_MAP FID3096 <- YDSURF%YSD_VD%YSPARC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(236))%fields(sf(236))%initialized /= 0) then
        value = surface%groups(sg(236))%fields(sf(236))%indices(1)
      end if
      output%mt0_map(3096) = value
    end if
    ! MT0_MAP FID3097 <- YDSURF%YSD_VD%YSTINC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(237))%fields(sf(237))%initialized /= 0) then
        value = surface%groups(sg(237))%fields(sf(237))%indices(1)
      end if
      output%mt0_map(3097) = value
    end if
    ! MT0_MAP FID3098 <- YDSURF%YSD_VD%YCBASE%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(238))%fields(sf(238))%initialized /= 0) then
        value = surface%groups(sg(238))%fields(sf(238))%indices(1)
      end if
      output%mt0_map(3098) = value
    end if
    ! MT0_MAP FID3099 <- YDSURF%YSD_VD%Y0DEGL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(239))%fields(sf(239))%initialized /= 0) then
        value = surface%groups(sg(239))%fields(sf(239))%indices(1)
      end if
      output%mt0_map(3099) = value
    end if
    ! MT0_MAP FID3145 <- YDSURF%YSD_VD%YM10DEGL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(240))%fields(sf(240))%initialized /= 0) then
        value = surface%groups(sg(240))%fields(sf(240))%indices(1)
      end if
      output%mt0_map(3145) = value
    end if
    ! MT0_MAP FID3100 <- YDSURF%YSD_VD%YVISIH%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(241))%fields(sf(241))%initialized /= 0) then
        value = surface%groups(sg(241))%fields(sf(241))%indices(1)
      end if
      output%mt0_map(3100) = value
    end if
    ! MT0_MAP FID3101 <- YDSURF%YSD_VD%YCIN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(242))%fields(sf(242))%initialized /= 0) then
        value = surface%groups(sg(242))%fields(sf(242))%indices(1)
      end if
      output%mt0_map(3101) = value
    end if
    ! MT0_MAP FID3102 <- YDSURF%YSD_VD%YKINDEX%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(243))%fields(sf(243))%initialized /= 0) then
        value = surface%groups(sg(243))%fields(sf(243))%indices(1)
      end if
      output%mt0_map(3102) = value
    end if
    ! MT0_MAP FID3103 <- YDSURF%YSD_VD%YTTINDEX%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(244))%fields(sf(244))%initialized /= 0) then
        value = surface%groups(sg(244))%fields(sf(244))%indices(1)
      end if
      output%mt0_map(3103) = value
    end if
    ! MT0_MAP FID3104 <- YDSURF%YSD_VD%YCBASEA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(245))%fields(sf(245))%initialized /= 0) then
        value = surface%groups(sg(245))%fields(sf(245))%indices(1)
      end if
      output%mt0_map(3104) = value
    end if
    ! MT0_MAP FID3105 <- YDSURF%YSD_VD%YCTOPC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(246))%fields(sf(246))%initialized /= 0) then
        value = surface%groups(sg(246))%fields(sf(246))%indices(1)
      end if
      output%mt0_map(3105) = value
    end if
    ! MT0_MAP FID3106 <- YDSURF%YSD_VD%YZTWETB0%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(247))%fields(sf(247))%initialized /= 0) then
        value = surface%groups(sg(247))%fields(sf(247))%indices(1)
      end if
      output%mt0_map(3106) = value
    end if
    ! MT0_MAP FID3107 <- YDSURF%YSD_VD%YZTWETB1%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(248))%fields(sf(248))%initialized /= 0) then
        value = surface%groups(sg(248))%fields(sf(248))%indices(1)
      end if
      output%mt0_map(3107) = value
    end if
    ! MT0_MAP FID3112 <- YDSURF%YSD_VD%Y100U%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(249))%fields(sf(249))%initialized /= 0) then
        value = surface%groups(sg(249))%fields(sf(249))%indices(1)
      end if
      output%mt0_map(3112) = value
    end if
    ! MT0_MAP FID3113 <- YDSURF%YSD_VD%Y100V%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(250))%fields(sf(250))%initialized /= 0) then
        value = surface%groups(sg(250))%fields(sf(250))%indices(1)
      end if
      output%mt0_map(3113) = value
    end if
    ! MT0_MAP FID3114 <- YDSURF%YSD_VD%YZUST%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(251))%fields(sf(251))%initialized /= 0) then
        value = surface%groups(sg(251))%fields(sf(251))%indices(1)
      end if
      output%mt0_map(3114) = value
    end if
    ! MT0_MAP FID3115 <- YDSURF%YSD_VD%Y10NU%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(252))%fields(sf(252))%initialized /= 0) then
        value = surface%groups(sg(252))%fields(sf(252))%indices(1)
      end if
      output%mt0_map(3115) = value
    end if
    ! MT0_MAP FID3116 <- YDSURF%YSD_VD%Y10NV%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(253))%fields(sf(253))%initialized /= 0) then
        value = surface%groups(sg(253))%fields(sf(253))%indices(1)
      end if
      output%mt0_map(3116) = value
    end if
    ! MT0_MAP FID3117 <- YDSURF%YSD_VD%YDNDZN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(254))%fields(sf(254))%initialized /= 0) then
        value = surface%groups(sg(254))%fields(sf(254))%indices(1)
      end if
      output%mt0_map(3117) = value
    end if
    ! MT0_MAP FID3118 <- YDSURF%YSD_VD%YDNDZA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(255))%fields(sf(255))%initialized /= 0) then
        value = surface%groups(sg(255))%fields(sf(255))%indices(1)
      end if
      output%mt0_map(3118) = value
    end if
    ! MT0_MAP FID3119 <- YDSURF%YSD_VD%YDCTB%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(256))%fields(sf(256))%initialized /= 0) then
        value = surface%groups(sg(256))%fields(sf(256))%indices(1)
      end if
      output%mt0_map(3119) = value
    end if
    ! MT0_MAP FID3120 <- YDSURF%YSD_VD%YTPLB%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(257))%fields(sf(257))%initialized /= 0) then
        value = surface%groups(sg(257))%fields(sf(257))%indices(1)
      end if
      output%mt0_map(3120) = value
    end if
    ! MT0_MAP FID3121 <- YDSURF%YSD_VD%YTPLT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(258))%fields(sf(258))%initialized /= 0) then
        value = surface%groups(sg(258))%fields(sf(258))%indices(1)
      end if
      output%mt0_map(3121) = value
    end if
    ! MT0_MAP FID3122 <- YDSURF%YSD_VD%YODSS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(259))%fields(sf(259))%initialized /= 0) then
        value = surface%groups(sg(259))%fields(sf(259))%indices(1)
      end if
      output%mt0_map(3122) = value
    end if
    ! MT0_MAP FID3123 <- YDSURF%YSD_VD%YODDU%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(260))%fields(sf(260))%initialized /= 0) then
        value = surface%groups(sg(260))%fields(sf(260))%indices(1)
      end if
      output%mt0_map(3123) = value
    end if
    ! MT0_MAP FID3124 <- YDSURF%YSD_VD%YODOM%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(261))%fields(sf(261))%initialized /= 0) then
        value = surface%groups(sg(261))%fields(sf(261))%indices(1)
      end if
      output%mt0_map(3124) = value
    end if
    ! MT0_MAP FID3125 <- YDSURF%YSD_VD%YODBC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(262))%fields(sf(262))%initialized /= 0) then
        value = surface%groups(sg(262))%fields(sf(262))%indices(1)
      end if
      output%mt0_map(3125) = value
    end if
    ! MT0_MAP FID3126 <- YDSURF%YSD_VD%YODSU%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(263))%fields(sf(263))%initialized /= 0) then
        value = surface%groups(sg(263))%fields(sf(263))%indices(1)
      end if
      output%mt0_map(3126) = value
    end if
    ! MT0_MAP FID3127 <- YDSURF%YSD_VD%YODNI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(264))%fields(sf(264))%initialized /= 0) then
        value = surface%groups(sg(264))%fields(sf(264))%indices(1)
      end if
      output%mt0_map(3127) = value
    end if
    ! MT0_MAP FID3128 <- YDSURF%YSD_VD%YODAM%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(265))%fields(sf(265))%initialized /= 0) then
        value = surface%groups(sg(265))%fields(sf(265))%indices(1)
      end if
      output%mt0_map(3128) = value
    end if
    ! MT0_MAP FID3129 <- YDSURF%YSD_VD%YODSOA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(266))%fields(sf(266))%initialized /= 0) then
        value = surface%groups(sg(266))%fields(sf(266))%indices(1)
      end if
      output%mt0_map(3129) = value
    end if
    ! MT0_MAP FID3130 <- YDSURF%YSD_VD%YODVFA%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(267))%fields(sf(267))%initialized /= 0) then
        value = surface%groups(sg(267))%fields(sf(267))%indices(1)
      end if
      output%mt0_map(3130) = value
    end if
    ! MT0_MAP FID3131 <- YDSURF%YSD_VD%YODVSU%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(268))%fields(sf(268))%initialized /= 0) then
        value = surface%groups(sg(268))%fields(sf(268))%indices(1)
      end if
      output%mt0_map(3131) = value
    end if
    ! MT0_MAP FID3144 <- YDSURF%YSD_VD%YODTOACC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(269))%fields(sf(269))%initialized /= 0) then
        value = surface%groups(sg(269))%fields(sf(269))%indices(1)
      end if
      output%mt0_map(3144) = value
    end if
    ! MT0_MAP FID3132 <- YDSURF%YSD_VD%YAEPM1%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(270))%fields(sf(270))%initialized /= 0) then
        value = surface%groups(sg(270))%fields(sf(270))%indices(1)
      end if
      output%mt0_map(3132) = value
    end if
    ! MT0_MAP FID3133 <- YDSURF%YSD_VD%YAEPM25%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(271))%fields(sf(271))%initialized /= 0) then
        value = surface%groups(sg(271))%fields(sf(271))%indices(1)
      end if
      output%mt0_map(3133) = value
    end if
    ! MT0_MAP FID3134 <- YDSURF%YSD_VD%YAEPM10%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(272))%fields(sf(272))%initialized /= 0) then
        value = surface%groups(sg(272))%fields(sf(272))%indices(1)
      end if
      output%mt0_map(3134) = value
    end if
    ! MT0_MAP FID3135 <- YDSURF%YSD_VD%YUVBED%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(273))%fields(sf(273))%initialized /= 0) then
        value = surface%groups(sg(273))%fields(sf(273))%indices(1)
      end if
      output%mt0_map(3135) = value
    end if
    ! MT0_MAP FID3136 <- YDSURF%YSD_VD%YUVBEDCS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(274))%fields(sf(274))%initialized /= 0) then
        value = surface%groups(sg(274))%fields(sf(274))%indices(1)
      end if
      output%mt0_map(3136) = value
    end if
    ! MT0_MAP FID3137 <- YDSURF%YSD_VD%YLITOTI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(275))%fields(sf(275))%initialized /= 0) then
        value = surface%groups(sg(275))%fields(sf(275))%indices(1)
      end if
      output%mt0_map(3137) = value
    end if
    ! MT0_MAP FID3138 <- YDSURF%YSD_VD%YLICGI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(276))%fields(sf(276))%initialized /= 0) then
        value = surface%groups(sg(276))%fields(sf(276))%indices(1)
      end if
      output%mt0_map(3138) = value
    end if
    ! MT0_MAP FID3141 <- YDSURF%YSD_VD%Y200U%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(277))%fields(sf(277))%initialized /= 0) then
        value = surface%groups(sg(277))%fields(sf(277))%indices(1)
      end if
      output%mt0_map(3141) = value
    end if
    ! MT0_MAP FID3142 <- YDSURF%YSD_VD%Y200V%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(278))%fields(sf(278))%initialized /= 0) then
        value = surface%groups(sg(278))%fields(sf(278))%indices(1)
      end if
      output%mt0_map(3142) = value
    end if
    ! MT0_MAP FID3153 <- YDSURF%YSD_VD%YSDSL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(279))%fields(sf(279))%initialized /= 0) then
        value = surface%groups(sg(279))%fields(sf(279))%indices(1)
      end if
      output%mt0_map(3153) = value
    end if
    ! MT0_MAP FID3201 <- YDSURF%YSD_SM%YCLBT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(280))%fields(sf(280))%initialized /= 0) then
        value = surface%groups(sg(280))%fields(sf(280))%indices(1)
      end if
      output%mt0_map(3201) = value
    end if
    ! MT0_MAP FID3202 <- YDSURF%YSD_SM%YCSBT%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(281))%fields(sf(281))%initialized /= 0) then
        value = surface%groups(sg(281))%fields(sf(281))%indices(1)
      end if
      output%mt0_map(3202) = value
    end if
    ! MT0_MAP FID3301 <- YDSURF%YSD_WS%YCHAR%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(282))%fields(sf(282))%initialized /= 0) then
        value = surface%groups(sg(282))%fields(sf(282))%indices(1)
      end if
      output%mt0_map(3301) = value
    end if
    ! MT0_MAP FID3302 <- YDSURF%YSD_WS%YCHARHQ%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(283))%fields(sf(283))%initialized /= 0) then
        value = surface%groups(sg(283))%fields(sf(283))%indices(1)
      end if
      output%mt0_map(3302) = value
    end if
    ! MT0_MAP FID3303 <- YDSURF%YSD_WS%YUSTOKES%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(284))%fields(sf(284))%initialized /= 0) then
        value = surface%groups(sg(284))%fields(sf(284))%indices(1)
      end if
      output%mt0_map(3303) = value
    end if
    ! MT0_MAP FID3304 <- YDSURF%YSD_WS%YVSTOKES%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(285))%fields(sf(285))%initialized /= 0) then
        value = surface%groups(sg(285))%fields(sf(285))%indices(1)
      end if
      output%mt0_map(3304) = value
    end if
    ! MT0_MAP FID3305 <- YDSURF%YSD_WS%YTAUOCX%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(286))%fields(sf(286))%initialized /= 0) then
        value = surface%groups(sg(286))%fields(sf(286))%indices(1)
      end if
      output%mt0_map(3305) = value
    end if
    ! MT0_MAP FID3306 <- YDSURF%YSD_WS%YTAUOCY%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(287))%fields(sf(287))%initialized /= 0) then
        value = surface%groups(sg(287))%fields(sf(287))%indices(1)
      end if
      output%mt0_map(3306) = value
    end if
    ! MT0_MAP FID3307 <- YDSURF%YSD_WS%YPHIOC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(288))%fields(sf(288))%initialized /= 0) then
        value = surface%groups(sg(288))%fields(sf(288))%indices(1)
      end if
      output%mt0_map(3307) = value
    end if
    ! MT0_MAP FID3308 <- YDSURF%YSD_WS%YWSEMEAN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(289))%fields(sf(289))%initialized /= 0) then
        value = surface%groups(sg(289))%fields(sf(289))%indices(1)
      end if
      output%mt0_map(3308) = value
    end if
    ! MT0_MAP FID3309 <- YDSURF%YSD_WS%YWSFMEAN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(290))%fields(sf(290))%initialized /= 0) then
        value = surface%groups(sg(290))%fields(sf(290))%indices(1)
      end if
      output%mt0_map(3309) = value
    end if
    ! MT0_MAP FID3801 <- YDSURF%YSD_WW%YU10N%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(291))%fields(sf(291))%initialized /= 0) then
        value = surface%groups(sg(291))%fields(sf(291))%indices(1)
      end if
      output%mt0_map(3801) = value
    end if
    ! MT0_MAP FID3802 <- YDSURF%YSD_WW%YV10N%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(292))%fields(sf(292))%initialized /= 0) then
        value = surface%groups(sg(292))%fields(sf(292))%indices(1)
      end if
      output%mt0_map(3802) = value
    end if
    ! MT0_MAP FID3803 <- YDSURF%YSD_WW%YRHO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(293))%fields(sf(293))%initialized /= 0) then
        value = surface%groups(sg(293))%fields(sf(293))%indices(1)
      end if
      output%mt0_map(3803) = value
    end if
    ! MT0_MAP FID3804 <- YDSURF%YSD_WW%YZIL%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(294))%fields(sf(294))%initialized /= 0) then
        value = surface%groups(sg(294))%fields(sf(294))%indices(1)
      end if
      output%mt0_map(3804) = value
    end if
    ! MT0_MAP FID3805 <- YDSURF%YSD_WW%YCIF%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(295))%fields(sf(295))%initialized /= 0) then
        value = surface%groups(sg(295))%fields(sf(295))%indices(1)
      end if
      output%mt0_map(3805) = value
    end if
    ! MT0_MAP FID3806 <- YDSURF%YSD_WW%YCLK%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(296))%fields(sf(296))%initialized /= 0) then
        value = surface%groups(sg(296))%fields(sf(296))%indices(1)
      end if
      output%mt0_map(3806) = value
    end if
    ! MT0_MAP FID3807 <- YDSURF%YSD_WW%YUCURW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(297))%fields(sf(297))%initialized /= 0) then
        value = surface%groups(sg(297))%fields(sf(297))%indices(1)
      end if
      output%mt0_map(3807) = value
    end if
    ! MT0_MAP FID3808 <- YDSURF%YSD_WW%YVCURW%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(298))%fields(sf(298))%initialized /= 0) then
        value = surface%groups(sg(298))%fields(sf(298))%indices(1)
      end if
      output%mt0_map(3808) = value
    end if
    ! MT0_MAP FID3401 <- YDSURF%YSD_VX%YORO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(299))%fields(sf(299))%initialized /= 0) then
        value = surface%groups(sg(299))%fields(sf(299))%indices(1)
      end if
      output%mt0_map(3401) = value
    end if
    ! MT0_MAP FID3402 <- YDSURF%YSD_VX%YTSC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(300))%fields(sf(300))%initialized /= 0) then
        value = surface%groups(sg(300))%fields(sf(300))%indices(1)
      end if
      output%mt0_map(3402) = value
    end if
    ! MT0_MAP FID3403 <- YDSURF%YSD_VX%YPWS%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(301))%fields(sf(301))%initialized /= 0) then
        value = surface%groups(sg(301))%fields(sf(301))%indices(1)
      end if
      output%mt0_map(3403) = value
    end if
    ! MT0_MAP FID3404 <- YDSURF%YSD_VX%YPWP%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(302))%fields(sf(302))%initialized /= 0) then
        value = surface%groups(sg(302))%fields(sf(302))%indices(1)
      end if
      output%mt0_map(3404) = value
    end if
    ! MT0_MAP FID3405 <- YDSURF%YSD_VX%YSNO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(303))%fields(sf(303))%initialized /= 0) then
        value = surface%groups(sg(303))%fields(sf(303))%indices(1)
      end if
      output%mt0_map(3405) = value
    end if
    ! MT0_MAP FID3406 <- YDSURF%YSD_VX%YTPC%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(304))%fields(sf(304))%initialized /= 0) then
        value = surface%groups(sg(304))%fields(sf(304))%indices(1)
      end if
      output%mt0_map(3406) = value
    end if
    ! MT0_MAP FID3407 <- YDSURF%YSD_VX%YSAB%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(305))%fields(sf(305))%initialized /= 0) then
        value = surface%groups(sg(305))%fields(sf(305))%indices(1)
      end if
      output%mt0_map(3407) = value
    end if
    ! MT0_MAP FID3408 <- YDSURF%YSD_VX%YXD2%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(306))%fields(sf(306))%initialized /= 0) then
        value = surface%groups(sg(306))%fields(sf(306))%indices(1)
      end if
      output%mt0_map(3408) = value
    end if
    ! MT0_MAP FID3409 <- YDSURF%YSD_VX%YLSM%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(307))%fields(sf(307))%initialized /= 0) then
        value = surface%groups(sg(307))%fields(sf(307))%indices(1)
      end if
      output%mt0_map(3409) = value
    end if
    ! MT0_MAP FID3410 <- YDSURF%YSD_VX%YIVEG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(308))%fields(sf(308))%initialized /= 0) then
        value = surface%groups(sg(308))%fields(sf(308))%indices(1)
      end if
      output%mt0_map(3410) = value
    end if
    ! MT0_MAP FID3411 <- YDSURF%YSD_VX%YARG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(309))%fields(sf(309))%initialized /= 0) then
        value = surface%groups(sg(309))%fields(sf(309))%indices(1)
      end if
      output%mt0_map(3411) = value
    end if
    ! MT0_MAP FID3412 <- YDSURF%YSD_VX%YRSMIN%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(310))%fields(sf(310))%initialized /= 0) then
        value = surface%groups(sg(310))%fields(sf(310))%indices(1)
      end if
      output%mt0_map(3412) = value
    end if
    ! MT0_MAP FID3413 <- YDSURF%YSD_VX%YLAI%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(311))%fields(sf(311))%initialized /= 0) then
        value = surface%groups(sg(311))%fields(sf(311))%indices(1)
      end if
      output%mt0_map(3413) = value
    end if
    ! MT0_MAP FID3414 <- YDSURF%YSD_VX%YVEG%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(312))%fields(sf(312))%initialized /= 0) then
        value = surface%groups(sg(312))%fields(sf(312))%indices(1)
      end if
      output%mt0_map(3414) = value
    end if
    ! MT0_MAP FID3501 <- YDSURF%YSD_VK%YUDGRO%MP
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(313))%fields(sf(313))%initialized /= 0) then
        value = surface%groups(sg(313))%fields(sf(313))%indices(1)
      end if
      output%mt0_map(3501) = value
    end if
    ! MT9_MAP FID1 <- YDGMV%YT9%MU
    value = motion%yt9%mu
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(1) = value
    ! MT9_MAP FID2 <- YDGMV%YT9%MV
    value = motion%yt9%mv
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(2) = value
    ! MT9_MAP FID5 <- YDGMV%YT9%MT
    value = motion%yt9%mt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(5) = value
    ! MT9_MAP FID3 <- YDGMV%YT9%MDIV
    value = motion%yt9%mdiv
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(3) = value
    ! MT9_MAP FID9 <- YDGMV%YT9%MEDOT
    value = motion%yt9%medot
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(9) = value
    ! MT9_MAP FID12 <- YDGMV%YT9%MSGRTL
    value = motion%yt9%msgrtl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(12) = value
    ! MT9_MAP FID13 <- YDGMV%YT9%MSGRTM
    value = motion%yt9%msgrtm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(13) = value
    ! MT9_MAP FID14 <- YDGMV%YT9%MUNL
    value = motion%yt9%munl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(14) = value
    ! MT9_MAP FID15 <- YDGMV%YT9%MUNL_SI
    value = motion%yt9%munl_si
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(15) = value
    ! MT9_MAP FID16 <- YDGMV%YT9%MVNL
    value = motion%yt9%mvnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(16) = value
    ! MT9_MAP FID17 <- YDGMV%YT9%MVNL_SI
    value = motion%yt9%mvnl_si
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(17) = value
    ! MT9_MAP FID18 <- YDGMV%YT9%MTNL
    value = motion%yt9%mtnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(18) = value
    ! MT9_MAP FID19 <- YDGMV%YT9%MTNL_SI
    value = motion%yt9%mtnl_si
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(19) = value
    ! MT9_MAP FID20 <- YDGMV%YT9%MSPNL
    value = motion%yt9%mspnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(20) = value
    ! MT9_MAP FID21 <- YDGMV%YT9%MSPNL_SI
    value = motion%yt9%mspnl_si
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(21) = value
    ! MT9_MAP FID22 <- YDGMV%YT9%MVWVNL
    value = motion%yt9%mvwvnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(22) = value
    ! MT9_MAP FID23 <- YDGMV%YT9%MSVDNL_SI
    value = motion%yt9%msvdnl_si
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(23) = value
    ! MT9_MAP FID24 <- YDGMV%YT9%MSPDNL
    value = motion%yt9%mspdnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(24) = value
    ! MT9_MAP FID25 <- YDGMV%YT9%MSPDNL_SI
    value = motion%yt9%mspdnl_si
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(25) = value
    ! MT9_MAP FID26 <- YDGMV%YT9%MGW
    value = motion%yt9%mgw
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(26) = value
    ! MT9_MAP FID27 <- YDGMV%YT9%MCURHS
    value = motion%yt9%mcurhs
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(27) = value
    ! MT9_MAP FID28 <- YDGMV%YT9%MCVRHS
    value = motion%yt9%mcvrhs
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(28) = value
    ! MT9_MAP FID29 <- YDGMV%YT9%MCTRHS
    value = motion%yt9%mctrhs
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(29) = value
    ! MT9_MAP FID30 <- YDGMV%YT9%MCSPRHS
    value = motion%yt9%mcsprhs
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(30) = value
    ! MT9_MAP FID31 <- YDGMV%YT9%MCSPDRHS
    value = motion%yt9%mcspdrhs
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(31) = value
    ! MT9_MAP FID32 <- YDGMV%YT9%MCSVDRHS
    value = motion%yt9%mcsvdrhs
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(32) = value
    ! MT9_MAP FID33 <- YDGMV%YT9%MCUNL
    value = motion%yt9%mcunl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(33) = value
    ! MT9_MAP FID34 <- YDGMV%YT9%MCVNL
    value = motion%yt9%mcvnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(34) = value
    ! MT9_MAP FID35 <- YDGMV%YT9%MCTNL
    value = motion%yt9%mctnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(35) = value
    ! MT9_MAP FID36 <- YDGMV%YT9%MCSPNL
    value = motion%yt9%mcspnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(36) = value
    ! MT9_MAP FID37 <- YDGMV%YT9%MCVWVNL
    value = motion%yt9%mcvwvnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(37) = value
    ! MT9_MAP FID38 <- YDGMV%YT9%MCSPDNL
    value = motion%yt9%mcspdnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(38) = value
    ! MT9_MAP FID39 <- YDGMV%YT9%MCUPT
    value = motion%yt9%mcupt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(39) = value
    ! MT9_MAP FID40 <- YDGMV%YT9%MCVPT
    value = motion%yt9%mcvpt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(40) = value
    ! MT9_MAP FID41 <- YDGMV%YT9%MCTPT
    value = motion%yt9%mctpt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(41) = value
    ! MT9_MAP FID42 <- YDGMV%YT9%MCSPDPT
    value = motion%yt9%mcspdpt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(42) = value
    ! MT9_MAP FID43 <- YDGMV%YT9%MCSVDPT
    value = motion%yt9%mcsvdpt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(43) = value
    ! MT9_MAP FID44 <- YDGMV%YT9%MDPHI
    value = motion%yt9%mdphi
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(44) = value
    ! MT9_MAP FID45 <- YDGMV%YT9%MNHXNL
    value = motion%yt9%mnhxnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(45) = value
    ! MT9_MAP FID46 <- YDGMV%YT9%MCNHXNL
    value = motion%yt9%mcnhxnl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(46) = value
    ! MT9_MAP FID96 <- YDGMV%YT9%MCSPPT
    value = motion%yt9%mcsppt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(96) = value
    ! MT9_MAP FID97 <- YDGMV%YT9%MDBBC
    value = motion%yt9%mdbbc
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(97) = value
    ! MT9_MAP FID98 <- YDGMV%YT9%MGWS
    value = motion%yt9%mgws
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(98) = value
    ! MT9_MAP FID6 <- YDGMV%YT9%MSPD
    value = motion%yt9%mspd
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(6) = value
    ! MT9_MAP FID7 <- YDGMV%YT9%MSVD
    value = motion%yt9%msvd
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(7) = value
    ! MT9_MAP FID8 <- YDGMV%YT9%MNHX
    value = motion%yt9%mnhx
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(8) = value
    ! MT9_MAP FID8 <- YDGMV%YT9%MNHX
    value = motion%yt9%mnhx
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(8) = value
    ! MT9_MAP FID95 <- YDGMV%YT9%MSP
    value = motion%yt9%msp
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(95) = value
    ! MT9_MAP FID96 <- YDGMV%YT9%MCSPPT
    value = motion%yt9%mcsppt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(96) = value
    ! MT9_MAP FID97 <- YDGMV%YT9%MDBBC
    value = motion%yt9%mdbbc
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(97) = value
    ! MT9_MAP FID98 <- YDGMV%YT9%MGWS
    value = motion%yt9%mgws
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(98) = value
    ! MT9_MAP FID99 <- YDGMV%YT9%MSPNL2
    value = motion%yt9%mspnl2
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(99) = value
    ! MT9_MAP FID100 <- YDGMV%YT9%MCSPNL2
    value = motion%yt9%mcspnl2
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(100) = value
    ! MT9_MAP FID999 <- YDGMV%YT9%MPREHYDS
    value = motion%yt9%mprehyds
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_map(999) = value
    ! MT9_MAP FID47 <- YDGFLDESC%YQ%MP9
    value = -1
    if (configuration%components(gi(1))%lactive /= 0) value = configuration%components(gi(1))%mp9
    output%mt9_map(47) = value
    ! MT9_MAP FID48 <- YDGFLDESC%YO3%MP9
    value = -1
    if (configuration%components(gi(2))%lactive /= 0) value = configuration%components(gi(2))%mp9
    output%mt9_map(48) = value
    ! MT9_MAP FID49 <- YDGFLDESC%YL%MP9
    value = -1
    if (configuration%components(gi(3))%lactive /= 0) value = configuration%components(gi(3))%mp9
    output%mt9_map(49) = value
    ! MT9_MAP FID50 <- YDGFLDESC%YI%MP9
    value = -1
    if (configuration%components(gi(4))%lactive /= 0) value = configuration%components(gi(4))%mp9
    output%mt9_map(50) = value
    ! MT9_MAP FID51 <- YDGFLDESC%YA%MP9
    value = -1
    if (configuration%components(gi(5))%lactive /= 0) value = configuration%components(gi(5))%mp9
    output%mt9_map(51) = value
    ! MT9_MAP FID56 <- YDGFLDESC%YS%MP9
    value = -1
    if (configuration%components(gi(6))%lactive /= 0) value = configuration%components(gi(6))%mp9
    output%mt9_map(56) = value
    ! MT9_MAP FID57 <- YDGFLDESC%YR%MP9
    value = -1
    if (configuration%components(gi(7))%lactive /= 0) value = configuration%components(gi(7))%mp9
    output%mt9_map(57) = value
    ! MT9_MAP FID58 <- YDGFLDESC%YG%MP9
    value = -1
    if (configuration%components(gi(8))%lactive /= 0) value = configuration%components(gi(8))%mp9
    output%mt9_map(58) = value
    ! MT9_MAP FID59 <- YDGFLDESC%YH%MP9
    value = -1
    if (configuration%components(gi(9))%lactive /= 0) value = configuration%components(gi(9))%mp9
    output%mt9_map(59) = value
    ! MT9_MAP FID64 <- YDGFLDESC%YTKE%MP9
    value = -1
    if (configuration%components(gi(15))%lactive /= 0) value = configuration%components(gi(15))%mp9
    output%mt9_map(64) = value
    ! MT9_MAP FID65 <- YDGFLDESC%YTTE%MP9
    value = -1
    if (configuration%components(gi(16))%lactive /= 0) value = configuration%components(gi(16))%mp9
    output%mt9_map(65) = value
    ! MT9_MAP FID69 <- YDGFLDESC%YMXL%MP9
    value = -1
    if (configuration%components(gi(20))%lactive /= 0) value = configuration%components(gi(20))%mp9
    output%mt9_map(69) = value
    ! MT9_MAP FID70 <- YDGFLDESC%YSRC%MP9
    value = -1
    if (configuration%components(gi(21))%lactive /= 0) value = configuration%components(gi(21))%mp9
    output%mt9_map(70) = value
    ! MT9_MAP FID71 <- YDGFLDESC%YSHTUR%MP9
    value = -1
    if (configuration%components(gi(22))%lactive /= 0) value = configuration%components(gi(22))%mp9
    output%mt9_map(71) = value
    ! MT9_MAP FID72 <- YDGFLDESC%YFQTUR%MP9
    value = -1
    if (configuration%components(gi(23))%lactive /= 0) value = configuration%components(gi(23))%mp9
    output%mt9_map(72) = value
    ! MT9_MAP FID73 <- YDGFLDESC%YFSTUR%MP9
    value = -1
    if (configuration%components(gi(24))%lactive /= 0) value = configuration%components(gi(24))%mp9
    output%mt9_map(73) = value
    ! MT9_MAP FID74 <- YDGFLDESC%YCVV%MP9
    value = -1
    if (configuration%components(gi(25))%lactive /= 0) value = configuration%components(gi(25))%mp9
    output%mt9_map(74) = value
    ! MT9_MAP FID84 <- YDGFLDESC%YRKTH%MP9
    value = -1
    if (configuration%components(gi(26))%lactive /= 0) value = configuration%components(gi(26))%mp9
    output%mt9_map(84) = value
    ! MT9_MAP FID85 <- YDGFLDESC%YRKTQV%MP9
    value = -1
    if (configuration%components(gi(27))%lactive /= 0) value = configuration%components(gi(27))%mp9
    output%mt9_map(85) = value
    ! MT9_MAP FID86 <- YDGFLDESC%YRKTQC%MP9
    value = -1
    if (configuration%components(gi(28))%lactive /= 0) value = configuration%components(gi(28))%mp9
    output%mt9_map(86) = value
    ! MT9_MAP FID75 <- YDGFLDESC%YCPF%MP9
    value = -1
    if (configuration%components(gi(29))%lactive /= 0) value = configuration%components(gi(29))%mp9
    output%mt9_map(75) = value
    ! MT9_MAP FID76 <- YDGFLDESC%YSPF%MP9
    value = -1
    if (configuration%components(gi(30))%lactive /= 0) value = configuration%components(gi(30))%mp9
    output%mt9_map(76) = value
    ! MT9_MAP FID87 <- YDGFLDESC%YLRAD%MP9
    value = -1
    if (configuration%components(gi(32))%lactive /= 0) value = configuration%components(gi(32))%mp9
    output%mt9_map(87) = value
    ! MT9_MAP FID88 <- YDGFLDESC%YIRAD%MP9
    value = -1
    if (configuration%components(gi(33))%lactive /= 0) value = configuration%components(gi(33))%mp9
    output%mt9_map(88) = value
    ! MT9_MAP FID78 <- YDGFLDESC%YUOM%MP9
    value = -1
    if (configuration%components(gi(35))%lactive /= 0) value = configuration%components(gi(35))%mp9
    output%mt9_map(78) = value
    ! MT9_MAP FID79 <- YDGFLDESC%YUAL%MP9
    value = -1
    if (configuration%components(gi(36))%lactive /= 0) value = configuration%components(gi(36))%mp9
    output%mt9_map(79) = value
    ! MT9_MAP FID80 <- YDGFLDESC%YDOM%MP9
    value = -1
    if (configuration%components(gi(37))%lactive /= 0) value = configuration%components(gi(37))%mp9
    output%mt9_map(80) = value
    ! MT9_MAP FID81 <- YDGFLDESC%YDAL%MP9
    value = -1
    if (configuration%components(gi(38))%lactive /= 0) value = configuration%components(gi(38))%mp9
    output%mt9_map(81) = value
    ! MT9_MAP FID82 <- YDGFLDESC%YUEN%MP9
    value = -1
    if (configuration%components(gi(39))%lactive /= 0) value = configuration%components(gi(39))%mp9
    output%mt9_map(82) = value
    ! MT9_MAP FID83 <- YDGFLDESC%YUNEBH%MP9
    value = -1
    if (configuration%components(gi(40))%lactive /= 0) value = configuration%components(gi(40))%mp9
    output%mt9_map(83) = value
    ! MT9_MAP FID1101 <- YDSURF%YSP_SB%YQ%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(1))%fields(sf(1))%initialized /= 0) then
        value = surface%groups(sg(1))%fields(sf(1))%indices(3)
      end if
      output%mt9_map(1101) = value
    end if
    ! MT9_MAP FID1102 <- YDSURF%YSP_SB%YT%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(2))%fields(sf(2))%initialized /= 0) then
        value = surface%groups(sg(2))%fields(sf(2))%indices(3)
      end if
      output%mt9_map(1102) = value
    end if
    ! MT9_MAP FID1103 <- YDSURF%YSP_SB%YTL%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(3))%fields(sf(3))%initialized /= 0) then
        value = surface%groups(sg(3))%fields(sf(3))%indices(3)
      end if
      output%mt9_map(1103) = value
    end if
    ! MT9_MAP FID1201 <- YDSURF%YSP_SG%YF%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(4))%fields(sf(4))%initialized /= 0) then
        value = surface%groups(sg(4))%fields(sf(4))%indices(3)
      end if
      output%mt9_map(1201) = value
    end if
    ! MT9_MAP FID1202 <- YDSURF%YSP_SG%YA%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(5))%fields(sf(5))%initialized /= 0) then
        value = surface%groups(sg(5))%fields(sf(5))%indices(3)
      end if
      output%mt9_map(1202) = value
    end if
    ! MT9_MAP FID1203 <- YDSURF%YSP_SG%YR%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(6))%fields(sf(6))%initialized /= 0) then
        value = surface%groups(sg(6))%fields(sf(6))%indices(3)
      end if
      output%mt9_map(1203) = value
    end if
    ! MT9_MAP FID1204 <- YDSURF%YSP_SG%YT%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(7))%fields(sf(7))%initialized /= 0) then
        value = surface%groups(sg(7))%fields(sf(7))%indices(3)
      end if
      output%mt9_map(1204) = value
    end if
    ! MT9_MAP FID1205 <- YDSURF%YSP_SG%YW%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(8))%fields(sf(8))%initialized /= 0) then
        value = surface%groups(sg(8))%fields(sf(8))%indices(3)
      end if
      output%mt9_map(1205) = value
    end if
    ! MT9_MAP FID1301 <- YDSURF%YSP_SL%YLICT%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(9))%fields(sf(9))%initialized /= 0) then
        value = surface%groups(sg(9))%fields(sf(9))%indices(3)
      end if
      output%mt9_map(1301) = value
    end if
    ! MT9_MAP FID1302 <- YDSURF%YSP_SL%YLMLT%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(10))%fields(sf(10))%initialized /= 0) then
        value = surface%groups(sg(10))%fields(sf(10))%indices(3)
      end if
      output%mt9_map(1302) = value
    end if
    ! MT9_MAP FID1303 <- YDSURF%YSP_SL%YLTLT%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(11))%fields(sf(11))%initialized /= 0) then
        value = surface%groups(sg(11))%fields(sf(11))%indices(3)
      end if
      output%mt9_map(1303) = value
    end if
    ! MT9_MAP FID1304 <- YDSURF%YSP_SL%YLBLT%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(12))%fields(sf(12))%initialized /= 0) then
        value = surface%groups(sg(12))%fields(sf(12))%indices(3)
      end if
      output%mt9_map(1304) = value
    end if
    ! MT9_MAP FID1305 <- YDSURF%YSP_SL%YLSHF%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(13))%fields(sf(13))%initialized /= 0) then
        value = surface%groups(sg(13))%fields(sf(13))%indices(3)
      end if
      output%mt9_map(1305) = value
    end if
    ! MT9_MAP FID1306 <- YDSURF%YSP_SL%YLICD%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(14))%fields(sf(14))%initialized /= 0) then
        value = surface%groups(sg(14))%fields(sf(14))%indices(3)
      end if
      output%mt9_map(1306) = value
    end if
    ! MT9_MAP FID1307 <- YDSURF%YSP_SL%YLMLD%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(15))%fields(sf(15))%initialized /= 0) then
        value = surface%groups(sg(15))%fields(sf(15))%indices(3)
      end if
      output%mt9_map(1307) = value
    end if
    ! MT9_MAP FID1401 <- YDSURF%YSP_RR%YT%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(16))%fields(sf(16))%initialized /= 0) then
        value = surface%groups(sg(16))%fields(sf(16))%indices(3)
      end if
      output%mt9_map(1401) = value
    end if
    ! MT9_MAP FID1402 <- YDSURF%YSP_RR%YW%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(17))%fields(sf(17))%initialized /= 0) then
        value = surface%groups(sg(17))%fields(sf(17))%indices(3)
      end if
      output%mt9_map(1402) = value
    end if
    ! MT9_MAP FID1403 <- YDSURF%YSP_RR%YFC%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(18))%fields(sf(18))%initialized /= 0) then
        value = surface%groups(sg(18))%fields(sf(18))%indices(3)
      end if
      output%mt9_map(1403) = value
    end if
    ! MT9_MAP FID1404 <- YDSURF%YSP_RR%YIC%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(19))%fields(sf(19))%initialized /= 0) then
        value = surface%groups(sg(19))%fields(sf(19))%indices(3)
      end if
      output%mt9_map(1404) = value
    end if
    ! MT9_MAP FID1405 <- YDSURF%YSP_RR%YFP1%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(20))%fields(sf(20))%initialized /= 0) then
        value = surface%groups(sg(20))%fields(sf(20))%indices(3)
      end if
      output%mt9_map(1405) = value
    end if
    ! MT9_MAP FID1501 <- YDSURF%YSP_CL%YTCLS%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(21))%fields(sf(21))%initialized /= 0) then
        value = surface%groups(sg(21))%fields(sf(21))%indices(3)
      end if
      output%mt9_map(1501) = value
    end if
    ! MT9_MAP FID1502 <- YDSURF%YSP_CL%YHUCLS%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(22))%fields(sf(22))%initialized /= 0) then
        value = surface%groups(sg(22))%fields(sf(22))%indices(3)
      end if
      output%mt9_map(1502) = value
    end if
    ! MT9_MAP FID1601 <- YDSURF%YSP_OM%YTO%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(23))%fields(sf(23))%initialized /= 0) then
        value = surface%groups(sg(23))%fields(sf(23))%indices(3)
      end if
      output%mt9_map(1601) = value
    end if
    ! MT9_MAP FID1602 <- YDSURF%YSP_OM%YSO%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(24))%fields(sf(24))%initialized /= 0) then
        value = surface%groups(sg(24))%fields(sf(24))%indices(3)
      end if
      output%mt9_map(1602) = value
    end if
    ! MT9_MAP FID1603 <- YDSURF%YSP_OM%YUO%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(25))%fields(sf(25))%initialized /= 0) then
        value = surface%groups(sg(25))%fields(sf(25))%indices(3)
      end if
      output%mt9_map(1603) = value
    end if
    ! MT9_MAP FID1604 <- YDSURF%YSP_OM%YVO%MP9
    if (surface%totals%registered > 0) then
      value = -1
      if (surface%groups(sg(26))%fields(sf(26))%initialized /= 0) then
        value = surface%groups(sg(26))%fields(sf(26))%indices(3)
      end if
      output%mt9_map(1604) = value
    end if
    ! MT1_MAP FID1 <- YDGMV%YT1%MU
    value = motion%yt1%mu
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt1_map(1) = value
    ! MT1_MAP FID2 <- YDGMV%YT1%MV
    value = motion%yt1%mv
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt1_map(2) = value
    ! MT1_MAP FID5 <- YDGMV%YT1%MT
    value = motion%yt1%mt
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt1_map(5) = value
    ! MT1_MAP FID6 <- YDGMV%YT1%MSPD
    value = motion%yt1%mspd
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt1_map(6) = value
    ! MT1_MAP FID7 <- YDGMV%YT1%MSVD
    value = motion%yt1%msvd
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt1_map(7) = value
    ! MT1_MAP FID8 <- YDGMV%YT1%MNHX
    value = motion%yt1%mnhx
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt1_map(8) = value
    ! MT1_MAP FID47 <- YDGFLDESC%YQ%MP1
    value = -1
    if (configuration%components(gi(1))%lactive /= 0) value = configuration%components(gi(1))%mp1
    output%mt1_map(47) = value
    ! MT1_MAP FID48 <- YDGFLDESC%YO3%MP1
    value = -1
    if (configuration%components(gi(2))%lactive /= 0) value = configuration%components(gi(2))%mp1
    output%mt1_map(48) = value
    ! MT1_MAP FID49 <- YDGFLDESC%YL%MP1
    value = -1
    if (configuration%components(gi(3))%lactive /= 0) value = configuration%components(gi(3))%mp1
    output%mt1_map(49) = value
    ! MT1_MAP FID50 <- YDGFLDESC%YI%MP1
    value = -1
    if (configuration%components(gi(4))%lactive /= 0) value = configuration%components(gi(4))%mp1
    output%mt1_map(50) = value
    ! MT1_MAP FID51 <- YDGFLDESC%YA%MP1
    value = -1
    if (configuration%components(gi(5))%lactive /= 0) value = configuration%components(gi(5))%mp1
    output%mt1_map(51) = value
    ! MT1_MAP FID56 <- YDGFLDESC%YS%MP1
    value = -1
    if (configuration%components(gi(6))%lactive /= 0) value = configuration%components(gi(6))%mp1
    output%mt1_map(56) = value
    ! MT1_MAP FID57 <- YDGFLDESC%YR%MP1
    value = -1
    if (configuration%components(gi(7))%lactive /= 0) value = configuration%components(gi(7))%mp1
    output%mt1_map(57) = value
    ! MT1_MAP FID58 <- YDGFLDESC%YG%MP1
    value = -1
    if (configuration%components(gi(8))%lactive /= 0) value = configuration%components(gi(8))%mp1
    output%mt1_map(58) = value
    ! MT1_MAP FID59 <- YDGFLDESC%YH%MP1
    value = -1
    if (configuration%components(gi(9))%lactive /= 0) value = configuration%components(gi(9))%mp1
    output%mt1_map(59) = value
    ! MT1_MAP FID64 <- YDGFLDESC%YTKE%MP1
    value = -1
    if (configuration%components(gi(15))%lactive /= 0) value = configuration%components(gi(15))%mp1
    output%mt1_map(64) = value
    ! MT1_MAP FID65 <- YDGFLDESC%YTTE%MP1
    value = -1
    if (configuration%components(gi(16))%lactive /= 0) value = configuration%components(gi(16))%mp1
    output%mt1_map(65) = value
    ! MT1_MAP FID69 <- YDGFLDESC%YMXL%MP1
    value = -1
    if (configuration%components(gi(20))%lactive /= 0) value = configuration%components(gi(20))%mp1
    output%mt1_map(69) = value
    ! MT1_MAP FID70 <- YDGFLDESC%YSRC%MP1
    value = -1
    if (configuration%components(gi(21))%lactive /= 0) value = configuration%components(gi(21))%mp1
    output%mt1_map(70) = value
    ! MT1_MAP FID71 <- YDGFLDESC%YSHTUR%MP1
    value = -1
    if (configuration%components(gi(22))%lactive /= 0) value = configuration%components(gi(22))%mp1
    output%mt1_map(71) = value
    ! MT1_MAP FID72 <- YDGFLDESC%YFQTUR%MP1
    value = -1
    if (configuration%components(gi(23))%lactive /= 0) value = configuration%components(gi(23))%mp1
    output%mt1_map(72) = value
    ! MT1_MAP FID73 <- YDGFLDESC%YFSTUR%MP1
    value = -1
    if (configuration%components(gi(24))%lactive /= 0) value = configuration%components(gi(24))%mp1
    output%mt1_map(73) = value
    ! MT1_MAP FID74 <- YDGFLDESC%YCVV%MP1
    value = -1
    if (configuration%components(gi(25))%lactive /= 0) value = configuration%components(gi(25))%mp1
    output%mt1_map(74) = value
    ! MT1_MAP FID84 <- YDGFLDESC%YRKTH%MP1
    value = -1
    if (configuration%components(gi(26))%lactive /= 0) value = configuration%components(gi(26))%mp1
    output%mt1_map(84) = value
    ! MT1_MAP FID85 <- YDGFLDESC%YRKTQV%MP1
    value = -1
    if (configuration%components(gi(27))%lactive /= 0) value = configuration%components(gi(27))%mp1
    output%mt1_map(85) = value
    ! MT1_MAP FID86 <- YDGFLDESC%YRKTQC%MP1
    value = -1
    if (configuration%components(gi(28))%lactive /= 0) value = configuration%components(gi(28))%mp1
    output%mt1_map(86) = value
    ! MT1_MAP FID75 <- YDGFLDESC%YCPF%MP1
    value = -1
    if (configuration%components(gi(29))%lactive /= 0) value = configuration%components(gi(29))%mp1
    output%mt1_map(75) = value
    ! MT1_MAP FID76 <- YDGFLDESC%YSPF%MP1
    value = -1
    if (configuration%components(gi(30))%lactive /= 0) value = configuration%components(gi(30))%mp1
    output%mt1_map(76) = value
    ! MT1_MAP FID87 <- YDGFLDESC%YLRAD%MP1
    value = -1
    if (configuration%components(gi(32))%lactive /= 0) value = configuration%components(gi(32))%mp1
    output%mt1_map(87) = value
    ! MT1_MAP FID88 <- YDGFLDESC%YIRAD%MP1
    value = -1
    if (configuration%components(gi(33))%lactive /= 0) value = configuration%components(gi(33))%mp1
    output%mt1_map(88) = value
    ! MT1_MAP FID78 <- YDGFLDESC%YUOM%MP1
    value = -1
    if (configuration%components(gi(35))%lactive /= 0) value = configuration%components(gi(35))%mp1
    output%mt1_map(78) = value
    ! MT1_MAP FID79 <- YDGFLDESC%YUAL%MP1
    value = -1
    if (configuration%components(gi(36))%lactive /= 0) value = configuration%components(gi(36))%mp1
    output%mt1_map(79) = value
    ! MT1_MAP FID80 <- YDGFLDESC%YDOM%MP1
    value = -1
    if (configuration%components(gi(37))%lactive /= 0) value = configuration%components(gi(37))%mp1
    output%mt1_map(80) = value
    ! MT1_MAP FID81 <- YDGFLDESC%YDAL%MP1
    value = -1
    if (configuration%components(gi(38))%lactive /= 0) value = configuration%components(gi(38))%mp1
    output%mt1_map(81) = value
    ! MT1_MAP FID82 <- YDGFLDESC%YUEN%MP1
    value = -1
    if (configuration%components(gi(39))%lactive /= 0) value = configuration%components(gi(39))%mp1
    output%mt1_map(82) = value
    ! MT1_MAP FID83 <- YDGFLDESC%YUNEBH%MP1
    value = -1
    if (configuration%components(gi(40))%lactive /= 0) value = configuration%components(gi(40))%mp1
    output%mt1_map(83) = value
    ! MT1_MAP FID95 <- YDGMV%YT1%MSP
    value = motion%yt1%msp
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt1_map(95) = value
    ! MPC_MAP FID47 <- YDGFLDESC%YQ%MPPC
    value = -1
    if (configuration%components(gi(1))%lactive /= 0) value = configuration%components(gi(1))%mppc
    output%mpc_map(47) = value
    ! MPC_MAP FID48 <- YDGFLDESC%YO3%MPPC
    value = -1
    if (configuration%components(gi(2))%lactive /= 0) value = configuration%components(gi(2))%mppc
    output%mpc_map(48) = value
    ! MPC_MAP FID49 <- YDGFLDESC%YL%MPPC
    value = -1
    if (configuration%components(gi(3))%lactive /= 0) value = configuration%components(gi(3))%mppc
    output%mpc_map(49) = value
    ! MPC_MAP FID50 <- YDGFLDESC%YI%MPPC
    value = -1
    if (configuration%components(gi(4))%lactive /= 0) value = configuration%components(gi(4))%mppc
    output%mpc_map(50) = value
    ! MPC_MAP FID51 <- YDGFLDESC%YA%MPPC
    value = -1
    if (configuration%components(gi(5))%lactive /= 0) value = configuration%components(gi(5))%mppc
    output%mpc_map(51) = value
    ! MPC_MAP FID56 <- YDGFLDESC%YS%MPPC
    value = -1
    if (configuration%components(gi(6))%lactive /= 0) value = configuration%components(gi(6))%mppc
    output%mpc_map(56) = value
    ! MPC_MAP FID57 <- YDGFLDESC%YR%MPPC
    value = -1
    if (configuration%components(gi(7))%lactive /= 0) value = configuration%components(gi(7))%mppc
    output%mpc_map(57) = value
    ! MPC_MAP FID58 <- YDGFLDESC%YG%MPPC
    value = -1
    if (configuration%components(gi(8))%lactive /= 0) value = configuration%components(gi(8))%mppc
    output%mpc_map(58) = value
    ! MPC_MAP FID59 <- YDGFLDESC%YH%MPPC
    value = -1
    if (configuration%components(gi(9))%lactive /= 0) value = configuration%components(gi(9))%mppc
    output%mpc_map(59) = value
    ! MPC_MAP FID64 <- YDGFLDESC%YTKE%MPPC
    value = -1
    if (configuration%components(gi(15))%lactive /= 0) value = configuration%components(gi(15))%mppc
    output%mpc_map(64) = value
    ! MPC_MAP FID65 <- YDGFLDESC%YTTE%MPPC
    value = -1
    if (configuration%components(gi(16))%lactive /= 0) value = configuration%components(gi(16))%mppc
    output%mpc_map(65) = value
    ! MPC_MAP FID69 <- YDGFLDESC%YMXL%MPPC
    value = -1
    if (configuration%components(gi(20))%lactive /= 0) value = configuration%components(gi(20))%mppc
    output%mpc_map(69) = value
    ! MPC_MAP FID70 <- YDGFLDESC%YSRC%MPPC
    value = -1
    if (configuration%components(gi(21))%lactive /= 0) value = configuration%components(gi(21))%mppc
    output%mpc_map(70) = value
    ! MPC_MAP FID71 <- YDGFLDESC%YSHTUR%MPPC
    value = -1
    if (configuration%components(gi(22))%lactive /= 0) value = configuration%components(gi(22))%mppc
    output%mpc_map(71) = value
    ! MPC_MAP FID72 <- YDGFLDESC%YFQTUR%MPPC
    value = -1
    if (configuration%components(gi(23))%lactive /= 0) value = configuration%components(gi(23))%mppc
    output%mpc_map(72) = value
    ! MPC_MAP FID73 <- YDGFLDESC%YFSTUR%MPPC
    value = -1
    if (configuration%components(gi(24))%lactive /= 0) value = configuration%components(gi(24))%mppc
    output%mpc_map(73) = value
    ! MPC_MAP FID74 <- YDGFLDESC%YCVV%MPPC
    value = -1
    if (configuration%components(gi(25))%lactive /= 0) value = configuration%components(gi(25))%mppc
    output%mpc_map(74) = value
    ! MPC_MAP FID84 <- YDGFLDESC%YRKTH%MPPC
    value = -1
    if (configuration%components(gi(26))%lactive /= 0) value = configuration%components(gi(26))%mppc
    output%mpc_map(84) = value
    ! MPC_MAP FID85 <- YDGFLDESC%YRKTQV%MPPC
    value = -1
    if (configuration%components(gi(27))%lactive /= 0) value = configuration%components(gi(27))%mppc
    output%mpc_map(85) = value
    ! MPC_MAP FID86 <- YDGFLDESC%YRKTQC%MPPC
    value = -1
    if (configuration%components(gi(28))%lactive /= 0) value = configuration%components(gi(28))%mppc
    output%mpc_map(86) = value
    ! MPC_MAP FID75 <- YDGFLDESC%YCPF%MPPC
    value = -1
    if (configuration%components(gi(29))%lactive /= 0) value = configuration%components(gi(29))%mppc
    output%mpc_map(75) = value
    ! MPC_MAP FID76 <- YDGFLDESC%YSPF%MPPC
    value = -1
    if (configuration%components(gi(30))%lactive /= 0) value = configuration%components(gi(30))%mppc
    output%mpc_map(76) = value
    ! MPC_MAP FID87 <- YDGFLDESC%YLRAD%MPPC
    value = -1
    if (configuration%components(gi(32))%lactive /= 0) value = configuration%components(gi(32))%mppc
    output%mpc_map(87) = value
    ! MPC_MAP FID88 <- YDGFLDESC%YIRAD%MPPC
    value = -1
    if (configuration%components(gi(33))%lactive /= 0) value = configuration%components(gi(33))%mppc
    output%mpc_map(88) = value
    ! MPC_MAP FID78 <- YDGFLDESC%YUOM%MPPC
    value = -1
    if (configuration%components(gi(35))%lactive /= 0) value = configuration%components(gi(35))%mppc
    output%mpc_map(78) = value
    ! MPC_MAP FID79 <- YDGFLDESC%YUAL%MPPC
    value = -1
    if (configuration%components(gi(36))%lactive /= 0) value = configuration%components(gi(36))%mppc
    output%mpc_map(79) = value
    ! MPC_MAP FID80 <- YDGFLDESC%YDOM%MPPC
    value = -1
    if (configuration%components(gi(37))%lactive /= 0) value = configuration%components(gi(37))%mppc
    output%mpc_map(80) = value
    ! MPC_MAP FID81 <- YDGFLDESC%YDAL%MPPC
    value = -1
    if (configuration%components(gi(38))%lactive /= 0) value = configuration%components(gi(38))%mppc
    output%mpc_map(81) = value
    ! MPC_MAP FID82 <- YDGFLDESC%YUEN%MPPC
    value = -1
    if (configuration%components(gi(39))%lactive /= 0) value = configuration%components(gi(39))%mppc
    output%mpc_map(82) = value
    ! MPC_MAP FID83 <- YDGFLDESC%YUNEBH%MPPC
    value = -1
    if (configuration%components(gi(40))%lactive /= 0) value = configuration%components(gi(40))%mppc
    output%mpc_map(83) = value
    ! MPT_MAP FID47 <- YDGFLDESC%YQ%MPPT
    value = -1
    if (configuration%components(gi(1))%lactive /= 0) value = configuration%components(gi(1))%mppt
    output%mpt_map(47) = value
    ! MPT_MAP FID48 <- YDGFLDESC%YO3%MPPT
    value = -1
    if (configuration%components(gi(2))%lactive /= 0) value = configuration%components(gi(2))%mppt
    output%mpt_map(48) = value
    ! MPT_MAP FID49 <- YDGFLDESC%YL%MPPT
    value = -1
    if (configuration%components(gi(3))%lactive /= 0) value = configuration%components(gi(3))%mppt
    output%mpt_map(49) = value
    ! MPT_MAP FID50 <- YDGFLDESC%YI%MPPT
    value = -1
    if (configuration%components(gi(4))%lactive /= 0) value = configuration%components(gi(4))%mppt
    output%mpt_map(50) = value
    ! MPT_MAP FID51 <- YDGFLDESC%YA%MPPT
    value = -1
    if (configuration%components(gi(5))%lactive /= 0) value = configuration%components(gi(5))%mppt
    output%mpt_map(51) = value
    ! MPT_MAP FID56 <- YDGFLDESC%YS%MPPT
    value = -1
    if (configuration%components(gi(6))%lactive /= 0) value = configuration%components(gi(6))%mppt
    output%mpt_map(56) = value
    ! MPT_MAP FID57 <- YDGFLDESC%YR%MPPT
    value = -1
    if (configuration%components(gi(7))%lactive /= 0) value = configuration%components(gi(7))%mppt
    output%mpt_map(57) = value
    ! MPT_MAP FID58 <- YDGFLDESC%YG%MPPT
    value = -1
    if (configuration%components(gi(8))%lactive /= 0) value = configuration%components(gi(8))%mppt
    output%mpt_map(58) = value
    ! MPT_MAP FID59 <- YDGFLDESC%YH%MPPT
    value = -1
    if (configuration%components(gi(9))%lactive /= 0) value = configuration%components(gi(9))%mppt
    output%mpt_map(59) = value
    ! MPT_MAP FID64 <- YDGFLDESC%YTKE%MPPT
    value = -1
    if (configuration%components(gi(15))%lactive /= 0) value = configuration%components(gi(15))%mppt
    output%mpt_map(64) = value
    ! MPT_MAP FID65 <- YDGFLDESC%YTTE%MPPT
    value = -1
    if (configuration%components(gi(16))%lactive /= 0) value = configuration%components(gi(16))%mppt
    output%mpt_map(65) = value
    ! MPT_MAP FID69 <- YDGFLDESC%YMXL%MPPT
    value = -1
    if (configuration%components(gi(20))%lactive /= 0) value = configuration%components(gi(20))%mppt
    output%mpt_map(69) = value
    ! MPT_MAP FID70 <- YDGFLDESC%YSRC%MPPT
    value = -1
    if (configuration%components(gi(21))%lactive /= 0) value = configuration%components(gi(21))%mppt
    output%mpt_map(70) = value
    ! MPT_MAP FID71 <- YDGFLDESC%YSHTUR%MPPT
    value = -1
    if (configuration%components(gi(22))%lactive /= 0) value = configuration%components(gi(22))%mppt
    output%mpt_map(71) = value
    ! MPT_MAP FID72 <- YDGFLDESC%YFQTUR%MPPT
    value = -1
    if (configuration%components(gi(23))%lactive /= 0) value = configuration%components(gi(23))%mppt
    output%mpt_map(72) = value
    ! MPT_MAP FID73 <- YDGFLDESC%YFSTUR%MPPT
    value = -1
    if (configuration%components(gi(24))%lactive /= 0) value = configuration%components(gi(24))%mppt
    output%mpt_map(73) = value
    ! MPT_MAP FID74 <- YDGFLDESC%YCVV%MPPT
    value = -1
    if (configuration%components(gi(25))%lactive /= 0) value = configuration%components(gi(25))%mppt
    output%mpt_map(74) = value
    ! MPT_MAP FID84 <- YDGFLDESC%YRKTH%MPPT
    value = -1
    if (configuration%components(gi(26))%lactive /= 0) value = configuration%components(gi(26))%mppt
    output%mpt_map(84) = value
    ! MPT_MAP FID85 <- YDGFLDESC%YRKTQV%MPPT
    value = -1
    if (configuration%components(gi(27))%lactive /= 0) value = configuration%components(gi(27))%mppt
    output%mpt_map(85) = value
    ! MPT_MAP FID86 <- YDGFLDESC%YRKTQC%MPPT
    value = -1
    if (configuration%components(gi(28))%lactive /= 0) value = configuration%components(gi(28))%mppt
    output%mpt_map(86) = value
    ! MPT_MAP FID75 <- YDGFLDESC%YCPF%MPPT
    value = -1
    if (configuration%components(gi(29))%lactive /= 0) value = configuration%components(gi(29))%mppt
    output%mpt_map(75) = value
    ! MPT_MAP FID76 <- YDGFLDESC%YSPF%MPPT
    value = -1
    if (configuration%components(gi(30))%lactive /= 0) value = configuration%components(gi(30))%mppt
    output%mpt_map(76) = value
    ! MPT_MAP FID87 <- YDGFLDESC%YLRAD%MPPT
    value = -1
    if (configuration%components(gi(32))%lactive /= 0) value = configuration%components(gi(32))%mppt
    output%mpt_map(87) = value
    ! MPT_MAP FID88 <- YDGFLDESC%YIRAD%MPPT
    value = -1
    if (configuration%components(gi(33))%lactive /= 0) value = configuration%components(gi(33))%mppt
    output%mpt_map(88) = value
    ! MPT_MAP FID78 <- YDGFLDESC%YUOM%MPPT
    value = -1
    if (configuration%components(gi(35))%lactive /= 0) value = configuration%components(gi(35))%mppt
    output%mpt_map(78) = value
    ! MPT_MAP FID79 <- YDGFLDESC%YUAL%MPPT
    value = -1
    if (configuration%components(gi(36))%lactive /= 0) value = configuration%components(gi(36))%mppt
    output%mpt_map(79) = value
    ! MPT_MAP FID80 <- YDGFLDESC%YDOM%MPPT
    value = -1
    if (configuration%components(gi(37))%lactive /= 0) value = configuration%components(gi(37))%mppt
    output%mpt_map(80) = value
    ! MPT_MAP FID81 <- YDGFLDESC%YDAL%MPPT
    value = -1
    if (configuration%components(gi(38))%lactive /= 0) value = configuration%components(gi(38))%mppt
    output%mpt_map(81) = value
    ! MPT_MAP FID82 <- YDGFLDESC%YUEN%MPPT
    value = -1
    if (configuration%components(gi(39))%lactive /= 0) value = configuration%components(gi(39))%mppt
    output%mpt_map(82) = value
    ! MPT_MAP FID83 <- YDGFLDESC%YUNEBH%MPPT
    value = -1
    if (configuration%components(gi(40))%lactive /= 0) value = configuration%components(gi(40))%mppt
    output%mpt_map(83) = value
    ! MT0_DL_MAP FID1 <- YDGMV%YT0%MUL
    value = motion%yt0%mul
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dl_map(1) = value
    ! MT0_DL_MAP FID2 <- YDGMV%YT0%MVL
    value = motion%yt0%mvl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dl_map(2) = value
    ! MT0_DL_MAP FID5 <- YDGMV%YT0%MTL
    value = motion%yt0%mtl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dl_map(5) = value
    ! MT0_DL_MAP FID6 <- YDGMV%YT0%MSPDL
    value = motion%yt0%mspdl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dl_map(6) = value
    ! MT0_DL_MAP FID7 <- YDGMV%YT0%MSVDL
    value = motion%yt0%msvdl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dl_map(7) = value
    ! MT0_DL_MAP FID8 <- YDGMV%YT0%MNHXL
    value = motion%yt0%mnhxl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dl_map(8) = value
    ! MT0_DL_MAP FID47 <- YDGFLDESC%YQ%MPL
    value = -1
    if (configuration%components(gi(1))%lactive /= 0) value = configuration%components(gi(1))%mpl
    output%mt0_dl_map(47) = value
    ! MT0_DL_MAP FID48 <- YDGFLDESC%YO3%MPL
    value = -1
    if (configuration%components(gi(2))%lactive /= 0) value = configuration%components(gi(2))%mpl
    output%mt0_dl_map(48) = value
    ! MT0_DL_MAP FID49 <- YDGFLDESC%YL%MPL
    value = -1
    if (configuration%components(gi(3))%lactive /= 0) value = configuration%components(gi(3))%mpl
    output%mt0_dl_map(49) = value
    ! MT0_DL_MAP FID50 <- YDGFLDESC%YI%MPL
    value = -1
    if (configuration%components(gi(4))%lactive /= 0) value = configuration%components(gi(4))%mpl
    output%mt0_dl_map(50) = value
    ! MT0_DL_MAP FID51 <- YDGFLDESC%YA%MPL
    value = -1
    if (configuration%components(gi(5))%lactive /= 0) value = configuration%components(gi(5))%mpl
    output%mt0_dl_map(51) = value
    ! MT0_DL_MAP FID56 <- YDGFLDESC%YS%MPL
    value = -1
    if (configuration%components(gi(6))%lactive /= 0) value = configuration%components(gi(6))%mpl
    output%mt0_dl_map(56) = value
    ! MT0_DL_MAP FID57 <- YDGFLDESC%YR%MPL
    value = -1
    if (configuration%components(gi(7))%lactive /= 0) value = configuration%components(gi(7))%mpl
    output%mt0_dl_map(57) = value
    ! MT0_DL_MAP FID58 <- YDGFLDESC%YG%MPL
    value = -1
    if (configuration%components(gi(8))%lactive /= 0) value = configuration%components(gi(8))%mpl
    output%mt0_dl_map(58) = value
    ! MT0_DL_MAP FID59 <- YDGFLDESC%YH%MPL
    value = -1
    if (configuration%components(gi(9))%lactive /= 0) value = configuration%components(gi(9))%mpl
    output%mt0_dl_map(59) = value
    ! MT0_DL_MAP FID77 <- YDGFLDESC%YCVGQ%MPL
    value = -1
    if (configuration%components(gi(31))%lactive /= 0) value = configuration%components(gi(31))%mpl
    output%mt0_dl_map(77) = value
    ! MT0_DL_MAP FID89 <- YDGFLDESC%YRSPEC%MPL
    value = -1
    if (configuration%components(gi(34))%lactive /= 0) value = configuration%components(gi(34))%mpl
    output%mt0_dl_map(89) = value
    ! MT0_DL_MAP FID95 <- YDGMV%YT0%MSPL
    value = motion%yt0%mspl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dl_map(95) = value
    ! MT0_DM_MAP FID1 <- YDGMV%YT0%MUL
    value = motion%yt0%mul
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dm_map(1) = value
    ! MT0_DM_MAP FID2 <- YDGMV%YT0%MVL
    value = motion%yt0%mvl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dm_map(2) = value
    ! MT0_DM_MAP FID5 <- YDGMV%YT0%MTM
    value = motion%yt0%mtm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dm_map(5) = value
    ! MT0_DM_MAP FID6 <- YDGMV%YT0%MSPDM
    value = motion%yt0%mspdm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dm_map(6) = value
    ! MT0_DM_MAP FID7 <- YDGMV%YT0%MSVDM
    value = motion%yt0%msvdm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dm_map(7) = value
    ! MT0_DM_MAP FID8 <- YDGMV%YT0%MNHXM
    value = motion%yt0%mnhxm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dm_map(8) = value
    ! MT0_DM_MAP FID47 <- YDGFLDESC%YQ%MPL
    value = -1
    if (configuration%components(gi(1))%lactive /= 0) value = configuration%components(gi(1))%mpl
    output%mt0_dm_map(47) = value
    ! MT0_DM_MAP FID48 <- YDGFLDESC%YO3%MPL
    value = -1
    if (configuration%components(gi(2))%lactive /= 0) value = configuration%components(gi(2))%mpl
    output%mt0_dm_map(48) = value
    ! MT0_DM_MAP FID49 <- YDGFLDESC%YL%MPL
    value = -1
    if (configuration%components(gi(3))%lactive /= 0) value = configuration%components(gi(3))%mpl
    output%mt0_dm_map(49) = value
    ! MT0_DM_MAP FID50 <- YDGFLDESC%YI%MPL
    value = -1
    if (configuration%components(gi(4))%lactive /= 0) value = configuration%components(gi(4))%mpl
    output%mt0_dm_map(50) = value
    ! MT0_DM_MAP FID51 <- YDGFLDESC%YA%MPL
    value = -1
    if (configuration%components(gi(5))%lactive /= 0) value = configuration%components(gi(5))%mpl
    output%mt0_dm_map(51) = value
    ! MT0_DM_MAP FID56 <- YDGFLDESC%YS%MPL
    value = -1
    if (configuration%components(gi(6))%lactive /= 0) value = configuration%components(gi(6))%mpl
    output%mt0_dm_map(56) = value
    ! MT0_DM_MAP FID57 <- YDGFLDESC%YR%MPL
    value = -1
    if (configuration%components(gi(7))%lactive /= 0) value = configuration%components(gi(7))%mpl
    output%mt0_dm_map(57) = value
    ! MT0_DM_MAP FID58 <- YDGFLDESC%YG%MPL
    value = -1
    if (configuration%components(gi(8))%lactive /= 0) value = configuration%components(gi(8))%mpl
    output%mt0_dm_map(58) = value
    ! MT0_DM_MAP FID59 <- YDGFLDESC%YH%MPL
    value = -1
    if (configuration%components(gi(9))%lactive /= 0) value = configuration%components(gi(9))%mpl
    output%mt0_dm_map(59) = value
    ! MT0_DM_MAP FID77 <- YDGFLDESC%YCVGQ%MPL
    value = -1
    if (configuration%components(gi(31))%lactive /= 0) value = configuration%components(gi(31))%mpl
    output%mt0_dm_map(77) = value
    ! MT0_DM_MAP FID89 <- YDGFLDESC%YRSPEC%MPL
    value = -1
    if (configuration%components(gi(34))%lactive /= 0) value = configuration%components(gi(34))%mpl
    output%mt0_dm_map(89) = value
    ! MT0_DM_MAP FID95 <- YDGMV%YT0%MSPM
    value = motion%yt0%mspm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt0_dm_map(95) = value
    ! MT9_DL_MAP FID5 <- YDGMV%YT9%MTL
    value = motion%yt9%mtl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dl_map(5) = value
    ! MT9_DL_MAP FID6 <- YDGMV%YT9%MSPDL
    value = motion%yt9%mspdl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dl_map(6) = value
    ! MT9_DL_MAP FID7 <- YDGMV%YT9%MSVDL
    value = motion%yt9%msvdl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dl_map(7) = value
    ! MT9_DL_MAP FID95 <- YDGMV%YT9%MSPL
    value = motion%yt9%mspl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dl_map(95) = value
    ! MT9_DM_MAP FID5 <- YDGMV%YT9%MTL
    value = motion%yt9%mtl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dm_map(5) = value
    ! MT9_DM_MAP FID6 <- YDGMV%YT9%MSPDM
    value = motion%yt9%mspdm
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dm_map(6) = value
    ! MT9_DM_MAP FID7 <- YDGMV%YT9%MSVDL
    value = motion%yt9%msvdl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dm_map(7) = value
    ! MT9_DM_MAP FID95 <- YDGMV%YT9%MSPL
    value = motion%yt9%mspl
    if (value == undefined_field .and. undefined_field /= 1) value = -1
    output%mt9_dm_map(95) = value
    status = 0
  end function
end module
