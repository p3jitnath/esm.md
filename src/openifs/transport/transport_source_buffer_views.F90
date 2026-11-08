!> Bind native transport source planes from the own SL buffer-map producer.
!! Named one-based plane indices select data already packed by the solver.
!! This module creates views and metadata only;it calculates no field value.
module md2asm_transport_source_buffer_views
  use iso_fortran_env, only: int32, int64, real64
  use forecast_semi_lagrangian_buffer_types, only: native_semi_lagrangian_buffers, native_interpolation_controls
  use md2asm_departure_coordinate_fields, only: trajectory_field_component
  use md2asm_departure_field_transport, only: departure_transport_controls, general_transport_map, &
                                              constituent_transport_map
  implicit none
  private
  public :: bind_first_transport_buffer_sources
contains
  !> Bind the selected spherical hydrostatic source windows.
  !! buffer is the caller's complete contiguous real64(0:NASLB1-1,planes)
  !! TARGET owner. buffers%first comes from own native SLBUF setup and stays
  !! read only. first_input_level:last_input_level gives the stored logical
  !! input levels;the first actual plane of each field is its named prefix.
  !! Four trajectory fields borrow UR0,VR0,ZR0,WR0. General high-order sources
  !! borrow U9,V9,T9;linear sources U0,V0,T0;refined saved winds UR9,VR9;
  !! optional linear diagnostics U9_SI,V9_SI,T9_SI;physics UP9,VP9,TP9.
  !! Constituent source prefixes are GFL9/GFLP9. C9 supplies continuity and
  !! SP9 supplies departure surface pressure. No radius or unit conversion
  !! is performed. The field values retain their producer's physical units.
  !! The currently selected native LARCINB has no extra NSPLTHOI correction;
  !! nonzero controls%NSPLTHOI refuses before publishing any view. Consumer
  !! controls and their narrower lag/geometry bounds remain independently
  !! checked by the complete child. It is not a broader original route.
  !! Caller retains disjoint complete input owners and stable TARGET storage.
  !! Returned views end before resize/release. Existing result slots and
  !! output pointers in maps,and result pointers in trajectory_fields,stay.
  !! Status2 refuses counts,selected map spans or active constituent slots
  !! before any output metadata changes. Status0 publishes source views.
  subroutine bind_first_transport_buffer_sources(first_input_level, last_input_level, buffers, controls, &
                                                 buffer, components, trajectory_fields, transport, maps, status)
    integer(int32), intent(in) :: first_input_level, last_input_level
    type(native_semi_lagrangian_buffers), intent(in) :: buffers
    type(native_interpolation_controls), intent(in) :: controls
    real(real64), contiguous, target, intent(in) :: buffer(0:, :)
    type(constituent_transport_map), intent(in) :: components(:)
    type(trajectory_field_component), intent(inout) :: trajectory_fields(4)
    type(departure_transport_controls), intent(inout) :: transport
    type(general_transport_map), intent(inout) :: maps(3)
    integer(int32), intent(out) :: status
    type(trajectory_field_component) :: bound_fields(4)
    type(general_transport_map) :: bound_maps(3)
    type(departure_transport_controls) :: bound_transport
    integer(int64) :: planes, extent, base
    integer(int32) :: trajectory_start(4), high_start(3), linear_start(3), refined_start(2)
    integer(int32) :: diagnostic_start(3), physics_start(3)
    integer :: field, variable
    status = 2
    if (controls%nsplthoi /= 0) return
    if (size(buffer, 1, kind=int64) < 1 .or. size(components) > 2163) return
    planes = int(last_input_level, int64) - int(first_input_level, int64) + 1_int64
    if (planes < 1 .or. planes > int(huge(0_int32), int64)) return
    extent = size(buffer, 2, kind=int64)
    if (buffers%first%NFLDSLB1 < 1 .or. extent < int(buffers%first%NFLDSLB1, int64)) return
    trajectory_start = [buffers%first%MSLB1UR0, buffers%first%MSLB1VR0, &
                        buffers%first%MSLB1ZR0, buffers%first%MSLB1WR0]
    high_start = [buffers%first%MSLB1U9, buffers%first%MSLB1V9, buffers%first%MSLB1T9]
    linear_start = [buffers%first%MSLB1U0, buffers%first%MSLB1V0, buffers%first%MSLB1T0]
    refined_start = [buffers%first%MSLB1UR9, buffers%first%MSLB1VR9]
    diagnostic_start = [buffers%first%MSLB1U9_SI, buffers%first%MSLB1V9_SI, buffers%first%MSLB1T9_SI]
    physics_start = [buffers%first%MSLB1UP9, buffers%first%MSLB1VP9, buffers%first%MSLB1TP9]
    do field = 1, 4
      if (.not. valid_window(int(trajectory_start(field), int64))) return
    end do
    do variable = 1, 3
      if (.not. valid_window(int(high_start(variable), int64))) return
      if (.not. valid_window(int(linear_start(variable), int64))) return
      if (transport%linear_diagnostic) then
        if (.not. valid_window(int(diagnostic_start(variable), int64))) return
      end if
      if (transport%split_physics) then
        if (.not. valid_window(int(physics_start(variable), int64))) return
      end if
    end do
    if (transport%refined_saved_winds) then
      do variable = 1, 2
        if (.not. valid_window(int(refined_start(variable), int64))) return
      end do
    end if
    do field = 1, size(components)
      if (components(field)%advected .and. .not. components(field)%external_grid) then
        if (components(field)%source_slot < 1 .or. buffers%first%MSLB1GFL9 < 1) return
        base = int(buffers%first%MSLB1GFL9, int64) + int(components(field)%source_slot - 1, int64)*planes
        if (.not. valid_window(base)) return
      end if
      if (transport%split_physics .and. components(field)%advected .and. components(field)%physics) then
        if (components(field)%physics_slot < 1 .or. buffers%first%MSLB1GFLP9 < 1) return
        base = int(buffers%first%MSLB1GFLP9, int64) + int(components(field)%physics_slot - 1, int64)*planes
        if (.not. valid_window(base)) return
      end if
    end do
    if (.not. valid_window(int(buffers%first%MSLB1C9, int64))) return
    if (.not. valid_window(int(buffers%first%MSLB1SP9, int64))) return
    bound_fields = trajectory_fields
    bound_maps = maps
    bound_transport = transport
    do field = 1, 4
      base = int(trajectory_start(field), int64)
      bound_fields(field)%field => buffer(:, base:base + planes - 1_int64)
    end do
    do variable = 1, 3
      bound_maps(variable)%high_source = int(high_start(variable), int64)
      bound_maps(variable)%linear_source = int(linear_start(variable), int64)
      if (transport%linear_diagnostic) bound_maps(variable)%diagnostic_source = int(diagnostic_start(variable), int64)
      if (transport%split_physics) bound_maps(variable)%physics_source = int(physics_start(variable), int64)
    end do
    if (transport%refined_saved_winds) then
      do variable = 1, 2
        bound_maps(variable)%refined_source = int(refined_start(variable), int64)
      end do
    end if
    bound_transport%first_input_level = first_input_level
    bound_transport%last_input_level = last_input_level
    bound_transport%constituent_source = int(buffers%first%MSLB1GFL9, int64)
    bound_transport%constituent_physics_source = int(buffers%first%MSLB1GFLP9, int64)
    bound_transport%pressure_source = int(buffers%first%MSLB1C9, int64)
    bound_transport%pressure_departure_source = int(buffers%first%MSLB1SP9, int64)
    trajectory_fields = bound_fields
    maps = bound_maps
    transport = bound_transport
    status = 0
  contains
    logical function valid_window(start)
      integer(int64), intent(in) :: start
      valid_window = .false.
      if (start < 1 .or. start > extent) return
      if (planes > extent - start + 1_int64) return
      valid_window = .true.
    end function
  end subroutine
end module md2asm_transport_source_buffer_views
