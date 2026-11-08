module forecast_whole_surface_placement
  !! Port both complete-grid entries of initial_surface_state_placement.S.
  !! The existing six-view type borrows actual caller-owned surface arrays.
  !! No map owner is needed: this source visits global points in file order.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use partitioned_surface_field_placement_port, only: surface_input_owners
  implicit none
  private
  public :: place_initial_surface_fields, place_operational_initial_surface_fields
  integer(int32), parameter :: selected_routes(2, 47) = reshape([ &
                                                                0, 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, &
                                                                0, 8, 0, 9, 0, 10, 0, 11, 1, 0, 1, 1, 1, 2, 1, 3, &
                                                                1, 4, 1, 5, 1, 6, 3, 0, 3, 1, 4, 0, 4, 1, 4, 3, &
                                                                4, 4, 4, 5, 4, 6, 4, 7, 4, 8, 4, 9, 4, 10, 4, 11, &
                                                                4, 12, 4, 14, 4, 15, 4, 16, 4, 17, 4, 18, 4, 19, 4, 20, &
                                                                4, 21, 4, 22, 4, 25, 4, 26, 4, 27, 4, 28, 4, 29 &
                                                                ], [2, 47])
  integer(int32), parameter :: operational_routes(2, 50) = reshape([ &
                                                                   0, 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, &
                                                                   0, 8, 0, 9, 0, 10, 0, 11, 1, 0, 1, 1, 1, 2, 1, 3, &
                                                                   1, 4, 1, 5, 1, 6, 3, 0, 3, 1, 4, 0, 4, 1, 4, 3, &
                                                                   4, 4, 4, 5, 4, 6, 4, 7, 4, 8, 4, 9, 4, 10, 4, 11, &
                                                                   4, 12, 4, 14, 4, 15, 4, 16, 4, 17, 4, 18, 4, 19, 4, 20, &
                                                                   4, 21, 4, 22, 4, 25, 4, 30, 4, 31, 4, 32, 4, 33, 4, 34, &
                                                                   4, 35, 5, 0 &
                                                                   ], [2, 50])
  integer(int32), parameter :: selected_parameters(52) = [ &
                               139, 170, 183, 236, 39, 40, 41, 42, 35, 36, 37, 38, 228008, 228009, 228010, 228011, &
                               228012, 228013, 228014, 235, 198, 173, 174, 160, 172, 161, 162, 163, 234, 27, 129172, 28, &
                               200199, 29, 30, 66, 67, 43, 26, 228007, 31, 34, 74, 15, 16, 17, 18, 228141, &
                               32, 33, 238, 228038 &
                               ]
  integer(int32), parameter :: operational_parameters(55) = [ &
                               139, 170, 183, 236, 39, 40, 41, 42, 35, 36, 37, 38, 228008, 228009, 228010, 228011, &
                               228012, 228013, 228014, 235, 198, 173, 174, 160, 172, 161, 162, 163, 234, 27, 129172, 28, &
                               200199, 29, 30, 66, 67, 43, 26, 228007, 31, 34, 74, 210186, 210187, 210188, 210189, 210190, &
                               210191, 148, 228141, 32, 33, 238, 228038 &
                               ]
contains
  integer(int32) function place_initial_surface_fields(ordinary, layered, parameters, owners) result(status)
    !! Selected inputs(2048,47),(2048,5,5),52labels; owners(P,F,B)
    !! withP24,B86,F24/14/50/4/38. Keep all unselected planes and16padcells.
    real(real64), contiguous, intent(in) :: ordinary(:, :), layered(:, :, :)
    integer(int32), contiguous, intent(in) :: parameters(:)
    type(surface_input_owners), intent(inout) :: owners
    status = place_whole_surface_fields(ordinary, layered, parameters, owners, 2048, 24, 86, .false.)
  end function
  integer(int32) function place_operational_initial_surface_fields(ordinary, layered, parameters, owners) result(status)
    !! Operational inputs(6599680,50),(6599680,5,5),55labels. Owners use
    !! P17,B388217 andF24/14/50/4/38/3; preserve the nine final padcells.
    real(real64), contiguous, intent(in) :: ordinary(:, :), layered(:, :, :)
    integer(int32), contiguous, intent(in) :: parameters(:)
    type(surface_input_owners), intent(inout) :: owners
    status = place_whole_surface_fields(ordinary, layered, parameters, owners, 6599680, 17, 388217, .true.)
  end function
  integer(int32) function place_whole_surface_fields(ordinary,layered,parameters,owners,points,pitch,blocks,operational) result(status)
    real(real64), contiguous, intent(in) :: ordinary(:, :), layered(:, :, :)
    integer(int32), contiguous, intent(in) :: parameters(:)
    type(surface_input_owners), intent(inout) :: owners
    integer, intent(in) :: points, pitch, blocks
    logical, intent(in) :: operational
    integer :: columns, field, owner, plane, j, block, column, layer, family
    columns = 47
    if (operational) columns = 50
    status = 1
    if (any(shape(ordinary) /= [points, columns]) .or. any(shape(layered) /= [points, 5, 5])) return
    if (size(parameters) /= columns + 5) return
    if (.not. associated(owners%sp_sb) .or. .not. associated(owners%sp_sl) .or. .not. associated(owners%sp_ssn)) return
    if (.not. associated(owners%sp_rr) .or. .not. associated(owners%sd_vf)) return
    if (any(shape(owners%sp_sb) /= [pitch, 24, blocks])) return
    if (any(shape(owners%sp_sl) /= [pitch, 14, blocks])) return
    if (any(shape(owners%sp_ssn) /= [pitch, 50, blocks])) return
    if (any(shape(owners%sp_rr) /= [pitch, 4, blocks])) return
    if (any(shape(owners%sd_vf) /= [pitch, 38, blocks])) return
    if (operational) then
      if (.not. associated(owners%sd_ws)) return
      if (any(shape(owners%sd_ws) /= [pitch, 3, blocks])) return
    end if
    status = 2
    if (operational) then
      if (any(parameters /= operational_parameters)) return
    else
      if (any(parameters /= selected_parameters)) return
    end if
    do field = 1, columns
      if (operational) then
        owner = operational_routes(1, field); plane = operational_routes(2, field) + 1
      else
        owner = selected_routes(1, field); plane = selected_routes(2, field) + 1
      end if
      do j = 1, points
        block = (j - 1)/pitch + 1; column = mod(j - 1, pitch) + 1
        select case (owner)
        case (0); owners%sp_sb(column, plane, block) = ordinary(j, field)
        case (1); owners%sp_sl(column, plane, block) = ordinary(j, field)
        case (3); owners%sp_rr(column, plane, block) = ordinary(j, field)
        case (4); owners%sd_vf(column, plane, block) = ordinary(j, field)
        case (5); owners%sd_ws(column, plane, block) = ordinary(j, field)
        end select
      end do
    end do
    do plane = 1, 25
      family = (plane - 1)/5 + 1; layer = mod(plane - 1, 5) + 1
      do j = 1, points
        block = (j - 1)/pitch + 1; column = mod(j - 1, pitch) + 1
        owners%sp_ssn(column, plane, block) = layered(j, layer, family)
      end do
    end do
    status = 0
  end function
end module forecast_whole_surface_placement
