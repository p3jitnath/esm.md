module partitioned_surface_field_placement_port
  !! Place the selected global surface fields into six borrowed native owners.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use initial_surface_field_selection_port, only: surface_parameter_codes
  implicit none
  private
  public :: surface_input_owners, place_runtime_partitioned_surface_fields
  type :: surface_input_owners
    real(real64), pointer, contiguous :: sp_sb(:, :, :) => null(), sp_sl(:, :, :) => null()
    real(real64), pointer, contiguous :: sp_ssn(:, :, :) => null(), sp_rr(:, :, :) => null()
    real(real64), pointer, contiguous :: sd_vf(:, :, :) => null(), sd_ws(:, :, :) => null()
  end type
  integer, parameter :: routes(2, 50) = reshape([1, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7, 1, 8, &
                                                 1, 9, 1, 10, 1, 11, 1, 12, 2, 1, 2, 2, 2, 3, 2, 4, &
                                                 2, 5, 2, 6, 2, 7, 4, 1, 4, 2, 5, 1, 5, 2, 5, 4, &
                                                 5, 5, 5, 6, 5, 7, 5, 8, 5, 9, 5, 10, 5, 11, 5, 12, &
                                                 5, 13, 5, 15, 5, 16, 5, 17, 5, 18, 5, 19, 5, 20, 5, 21, &
                                                 5, 22, 5, 23, 5, 26, 5, 31, 5, 32, 5, 33, 5, 34, 5, 35, &
                                                 5, 36, 6, 1], [2, 50])
contains
integer(int32) function place_runtime_partitioned_surface_fields(ordinary, layered, parameters, global_index, owners) result(status)
    !! Read ordinary(6599680,50),layered(6599680,5,5),parameters(55) and the
    !! complete one-based global_index(Q). Owners are disjoint contiguous
    !! writable views(P,F,B), with F24,14,50,4,38,3 in member order.
    !! P is1..1024; Q is1..6599680; B=ceiling(Q/P). Their lifetime belongs
    !! to the caller. Only physical cells of the selected planes change;
    !! padding rows and unselected planes retain their complete input bytes.
    !! Values keep their converted physical units. Return1 for shape/owner,
    !!2 for identifiers,3 for a bad map or0 after all copies. Validate the
    !! complete map, every owner and identifiers before the first write.
    real(real64), contiguous, intent(in) :: ordinary(:, :), layered(:, :, :)
    integer(int32), contiguous, intent(in) :: parameters(:), global_index(:)
    type(surface_input_owners), intent(inout) :: owners
    integer :: p, q, b, k, j, cell, block, source, owner, plane, l
    integer(int32) :: expected(55), ignored
    status = 1
    if (any(shape(ordinary) /= [6599680, 50]) .or. any(shape(layered) /= [6599680, 5, 5])) return
    if (size(parameters) /= 55) return
    q = size(global_index)
    if (q < 1 .or. q > 6599680) return
    status = 3
    do j = 1, q
      if (global_index(j) < 1 .or. global_index(j) > 6599680) return
    end do
    status = 1
    if (.not. associated(owners%sp_sb)) return
    if (.not. associated(owners%sp_sl)) return
    if (.not. associated(owners%sp_ssn)) return
    if (.not. associated(owners%sp_rr)) return
    if (.not. associated(owners%sd_vf)) return
    if (.not. associated(owners%sd_ws)) return
    p = size(owners%sp_sb, 1)
    if (p < 1 .or. p > 1024) return
    b = (q - 1)/p + 1
    if (any(shape(owners%sp_sb) /= [p, 24, b])) return
    if (any(shape(owners%sp_sl) /= [p, 14, b])) return
    if (any(shape(owners%sp_ssn) /= [p, 50, b])) return
    if (any(shape(owners%sp_rr) /= [p, 4, b])) return
    if (any(shape(owners%sd_vf) /= [p, 38, b])) return
    if (any(shape(owners%sd_ws) /= [p, 3, b])) return
    call surface_parameter_codes(50_int32, expected, ignored)
    status = 2
    if (any(parameters /= expected)) return
    do k = 1, 50
      owner = routes(1, k); plane = routes(2, k)
      do j = 1, q
        block = (j - 1)/p + 1
        cell = mod(j - 1, p) + 1
        source = global_index(j)
        select case (owner)
        case (1)
          owners%sp_sb(cell, plane, block) = ordinary(source, k)
        case (2)
          owners%sp_sl(cell, plane, block) = ordinary(source, k)
        case (4)
          owners%sp_rr(cell, plane, block) = ordinary(source, k)
        case (5)
          owners%sd_vf(cell, plane, block) = ordinary(source, k)
        case (6)
          owners%sd_ws(cell, plane, block) = ordinary(source, k)
        end select
      end do
    end do
    do k = 1, 5
      do l = 1, 5
        plane = 5*(k - 1) + l
        do j = 1, q
          block = (j - 1)/p + 1
          cell = mod(j - 1, p) + 1
          owners%sp_ssn(cell, plane, block) = layered(global_index(j), l, k)
        end do
      end do
    end do
    status = 0
  end function
end module
