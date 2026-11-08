module forecast_selected_surface_context
  !! Project selected SUGRIDG requests from real native surface metadata.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use surface_input_configuration_port, only: surface_input_configuration
  use surface_field_storage_port, only: surface_field_state
  use partitioned_surface_field_placement_port, only: surface_input_owners
  use surface_default_metadata_port, only: surface_default_group_view
  use forecast_live_surface_input_metadata, only: live_surface_conversion_values, &
                                 selected_surface_owner_context, project_live_surface_configuration, project_selected_surface_owners
  implicit none
  private
  public :: project_selected_surface_initial_context
  integer, parameter :: group_kind(33)=[3,4,2,2,2,3,3,2,2,2,2,2,2,2,2,2,2,3,2,2,3,2,2,2,3,3,3,2,2,2,3,3,3]
  integer, parameter :: group_owner(33)=[0,2,1,3,-2,-2,-2,-2,4,-1,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-1,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2]
  integer(int32), parameter :: expected_parameters(52)=[139,170,183,236,39,40,41,42,35,36,37,38,228008,228009,228010,228011,228012,228013,228014,235,198,173,174,160,172,161,162,163,234,27,129172,28,200199,29,30,66,67,43,26,228007,31,34,74,15,16,17,18,228141,32,33,238,228038]
  integer(int32), parameter :: ordinary_positions(3,47)=reshape([139,0,0,170,0,1,183,0,2,236,0,3,39,0,4,40,0,5,41,0,6,42,0,7,35,0,8,36,0,9,37,0,10,38,0,11,228008,1,0,228009,1,1,228010,1,2,228011,1,3,228012,1,4,228013,1,5,228014,1,6,235,3,0,198,3,1,173,4,0,174,4,1,160,4,3,172,4,4,161,4,5,162,4,6,163,4,7,234,4,8,27,4,9,129172,4,10,28,4,11,200199,4,12,29,4,14,30,4,15,66,4,16,67,4,17,43,4,18,26,4,19,228007,4,20,31,4,21,34,4,22,74,4,25,15,4,26,16,4,27,17,4,28,18,4,29],[3,47])
  integer(int32), parameter :: snow_positions(3, 5) = reshape([228141, 2, 0, 32, 2, 1, 33, 2, 2, 238, 2, 3, 228038, 2, 4], [3, 5])
contains
  integer(int32) function project_selected_surface_initial_context(live, state, groups, pitch, points, snow_layers, &
                                         nconf, lifstraj, l_oops, allocation_flag, configuration, owners, parameters) result(status)
    !! Read live conversion values, five complete selected owners and33 source
    !! groups. All input metadata is readonly; state remains a stable TARGET.
    !! configuration is cleared first. After valid scalar projection, owners
    !! and52 identifiers are cleared and then filled in source traversal order.
    !! A failed request keeps its source-defined partial metadata; no numerical
    !! field changes. Known unrequested parameters also require the right plane.
    type(live_surface_conversion_values), intent(in) :: live
    type(surface_field_state), target, intent(inout) :: state
    type(surface_default_group_view), intent(in) :: groups(:)
    integer(int32), intent(in) :: pitch, points, snow_layers, nconf, lifstraj, l_oops, allocation_flag
    type(surface_input_configuration), intent(inout) :: configuration
    type(surface_input_owners), intent(inout) :: owners
    integer(int32), intent(inout) :: parameters(52)
    type(selected_surface_owner_context) :: context
    integer(int64) :: ordinary_seen, snow_seen
    integer :: g, j, k, layers, layer_count, ordinary_count, snow_count, code, flag, plane, child
    status = 1
    child = project_live_surface_configuration(live, configuration)
    if (child /= 0) return
    configuration%invalid = 2
    owners = surface_input_owners(); parameters = 0
    child = project_selected_surface_owners(pitch, points, snow_layers, nconf, lifstraj, l_oops, allocation_flag, state, context)
    if (child /= 0) return
    if (lifstraj /= 0 .or. (l_oops /= 0 .and. nconf == 131)) return
    owners = context%owners
    if (size(groups) /= 33) return
    ordinary_seen = 0; snow_seen = 0; ordinary_count = 0; snow_count = 0
    do g = 1, 33
      if (groups(g)%metadata%stored_fields <= 0) cycle
      if (groups(g)%metadata%registered_fields < 0) return
      layers = groups(g)%metadata%layers
      if (group_kind(g) == 4) then
        if (layers /= 5) return
      else if (group_kind(g) /= 2) then
        if (layers < 0 .or. layers > 4096) return
        if (group_owner(g) == 0 .and. layers /= 4) return
      end if
      if (.not. associated(groups(g)%fields)) return
      if (size(groups(g)%fields) < groups(g)%metadata%registered_fields) return
      do j = 1, groups(g)%metadata%registered_fields
        if (group_kind(g) == 2) then
          code = groups(g)%fields(j)%parameter
          if (group_owner(g) /= -2) then
            if (.not. valid_position(code, group_owner(g), j - 1, ordinary_seen, ordinary_positions)) return
          end if
          if (groups(g)%fields(j)%source_flag == 1) then
            if (ordinary_count >= 47) return
            ordinary_count = ordinary_count + 1; parameters(ordinary_count) = code
          end if
          cycle
        end if
        layer_count = layers
        if (group_kind(g) == 4) layer_count = 1
        if (.not. allocated(groups(g)%fields(j)%layer_parameters)) return
        if (.not. allocated(groups(g)%fields(j)%layer_source_flags)) return
  if (lbound(groups(g)%fields(j)%layer_parameters, 1) > 1 .or. ubound(groups(g)%fields(j)%layer_parameters, 1) < layer_count) return
       if(lbound(groups(g)%fields(j)%layer_source_flags,1)>1.or.ubound(groups(g)%fields(j)%layer_source_flags,1)<layer_count) return
        do k = 1, layer_count
          code = groups(g)%fields(j)%layer_parameters(k)
          flag = groups(g)%fields(j)%layer_source_flags(k)
          if (group_kind(g) == 4) then
            if (.not. valid_position(code, 2, j - 1, snow_seen, snow_positions)) return
            if (flag == 1) then
              if (snow_count >= 5) return
              snow_count = snow_count + 1; parameters(47 + snow_count) = code
            end if
          else
            plane = (j - 1)*layers + k - 1
            if (group_owner(g) /= -2) then
              if (.not. valid_position(code, group_owner(g), plane, ordinary_seen, ordinary_positions)) return
            end if
            if (flag == 1) then
              if (ordinary_count >= 47) return
              ordinary_count = ordinary_count + 1; parameters(ordinary_count) = code
            end if
          end if
        end do
      end do
    end do
    if (ordinary_count /= 47 .or. snow_count /= 5) return
    if (any(parameters /= expected_parameters)) return
    if (ordinary_seen /= 2_int64**47 - 1 .or. snow_seen /= 31) return
    configuration%invalid = 0; status = 0
  end function

  logical function valid_position(code, owner, plane, seen, table) result(valid)
    integer, intent(in) :: code, owner, plane
    integer(int64), intent(inout) :: seen
    integer(int32), intent(in) :: table(:, :)
    integer :: j
    valid = .true.
    do j = 1, size(table, 2)
      if (table(1, j) /= code) cycle
      valid = .false.
      if (table(2, j) /= owner .or. table(3, j) /= plane) return
      if (btest(seen, j - 1)) return
      seen = ibset(seen, j - 1); valid = .true.
      return
    end do
  end function
end module forecast_selected_surface_context
