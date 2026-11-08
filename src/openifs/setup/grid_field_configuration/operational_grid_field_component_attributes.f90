module operational_grid_field_component_attributes_port
  !! Apply the selected field attributes to an already registered array.
  !! Components(:) has capacity 9..2163 and the first nine fields are live.
  !! Levels is137 and supplementary levels is0 in the admitted operational route.
  !! Family 0 selects named moist/cloud fields and 1 selects NOGW.
  !! Only the target and declared counters change; input plans do not alias
  !! outputs. Unwritten metadata and omitted optional attributes stay intact.
  use, intrinsic :: iso_fortran_env, only: int32
  use grid_field_component_types_port, only: field_component_metadata, grid_field_mode_supported
  use grid_field_registration_types_port, only: grid_field_registration_state, field_attribute_plan
  implicit none
  private
  public :: set_operational_grid_field_attributes
contains
  integer(int32) function set_operational_grid_field_attributes(state,components,index,plan,levels,supplementary_levels,family) result(status)
    type(grid_field_registration_state), intent(inout) :: state
    type(field_component_metadata), contiguous, intent(inout) :: components(:)
    integer(int32), intent(in) :: index, levels, supplementary_levels, family
    type(field_attribute_plan), intent(in) :: plan
    integer(int32) :: advection_count, physics_count, spline_count
    logical :: add_physics, add_spline
    status = 2_int32
    if (size(components) < 9 .or. size(components) > 2163) return
    if (family < 0 .or. family > 1 .or. index < 1 .or. index > 9) return
    if (levels /= 137 .or. supplementary_levels /= 0) return
    if (.not. grid_field_mode_supported()) return
    if (state%numflds /= 9 .or. state%numgpflds /= 9 .or. state%ndim /= 9 .or. state%ndim0 /= 9) return
    if (state%numflds1 /= 7 .or. state%ndim1 /= 7) return
    if (state%nders /= 0 .or. state%numspflds /= 0 .or. state%numflds9 /= 0) return
    if (state%numspflds1 /= 0 .or. state%numflds5 /= 0 .or. state%numfldspc /= 0) return
    if (state%numfldspt /= 0 .or. state%ndim9 /= 0 .or. state%ndim5 /= 0) return
    if (state%ndimpt /= 0 .or. state%ndimpc /= 0) return
    associate (c => components(index))
      if (c%mp /= index) return
      if (index <= 7) then
        if (family /= 0) return
      else
        if (family /= 1) return
      end if
      if (c%lgp /= 1 .or. c%lcders /= 0 .or. c%lt5 /= 0) return
      if (plan%lt9 /= 0 .or. plan%pt /= 0 .or. plan%pc /= 0) return
      if (.not. flag(plan%phy)) return
      if (family == 0) then
        if (.not. flag(plan%adv) .or. .not. flag(plan%mgrid) .or. .not. flag(plan%adv5)) return
        if (.not. flag(plan%tdiab) .or. .not. flag(plan%hort)) return
      else
        if (plan%adv /= 0 .or. plan%mgrid /= 0) return
      end if
      advection_count = state%numflds_sl1
      if (advection_count < 0 .or. advection_count > 7) return
      if (plan%adv /= 0) then
        if (c%lt1 /= 1) return
        advection_count = advection_count + 1
        if (advection_count > 7) return
      end if
      physics_count = state%numfldsphy
      if (physics_count < 0 .or. physics_count > 7 .or. state%ndimslp /= physics_count) return
      add_physics = .false.
      if (c%mpslp == -99 .and. plan%phy /= 0) then
        if (c%lt1 /= 1) return
        physics_count = physics_count + 1
        if (physics_count > 7) return
        add_physics = .true.
      end if
      spline_count = state%numflds_spl
      if (spline_count < 0 .or. spline_count > 7 .or. state%ndim_spl /= spline_count) return
      add_spline = .false.
      if (family == 0 .and. c%mp_spl == -99999 .and. plan%cslint == 'LAITVSPCQM  ') then
        spline_count = spline_count + 1
        if (spline_count > 7) return
        add_spline = .true.
      end if
      c%ladv = plan%adv
      if (plan%adv /= 0) then
        state%numflds_sl1 = advection_count; c%mp_sl1 = advection_count
        c%mp_slx = (advection_count - 1)*(levels + 2*supplementary_levels)
      end if
      c%lmgrid = plan%mgrid
      if (family == 0) then
        c%ladv5 = plan%adv5; c%ltdiablin = plan%tdiab; c%lhorturb = plan%hort
      else
        c%ltdiablin = 0; c%lhorturb = 0
      end if
      c%lt9 = 0; c%mp9 = index; c%mp9_ph = index; c%lphy = plan%phy
      if (c%mpslp == -99) then
        if (add_physics) then
          state%numfldsphy = physics_count; state%ndimslp = physics_count; c%mpslp = physics_count
        else
          c%mpslp = -99999
        end if
      end if
      c%lpt = 0; c%lpc = 0; c%ncoupling = plan%coupling; c%refvalc = plan%refvalc
      if (family == 0) then
        c%cslint = plan%cslint
        if (add_spline) then
          state%numflds_spl = spline_count; state%ndim_spl = spline_count; c%mp_spl = spline_count
        end if
      end if
    end associate
    status = 0_int32
  end function
  pure logical function flag(value) result(valid)
    integer(int32), intent(in) :: value
    valid = value >= 0 .and. value <= 1
  end function
end module operational_grid_field_component_attributes_port
