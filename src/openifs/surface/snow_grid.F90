module srfsn_vgrid_mod
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_nan
  implicit none
  private
  public :: srfsn_vgrid
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Build snow layers in the operation order of snow_grid.S.
  !!
  !! Snow mass is in kg m^-2 and density in kg m^-3, so layer depth is in metres.
  !! PSDOR measures terrain-height variation in metres. LEMIN presence selects
  !! the original alternate thresholds; its logical value is not consumed.
  !! Only active PDSNOUT and ILEVSNA cells change.
  subroutine srfsn_vgrid(kidia, kfdia, klon, klevsn, llnosnow, psdor, pssn, prsn, rlevsnmin, rlevsnmax, rlevsnmin_gl, &
                         rlevsnmax_gl, pdsnout, ilevsna, lemin)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevsn
    logical(int32), intent(in) :: llnosnow(:)
    real(real64), intent(in) :: psdor(:), pssn(:, :), prsn(:, :), rlevsnmin(:), rlevsnmax(:), rlevsnmin_gl(:), rlevsnmax_gl(:)
    real(real64), intent(inout) :: pdsnout(:, :)
    integer(int32), intent(inout) :: ilevsna(:)
    logical, optional, intent(in) :: lemin
    real(real64), allocatable :: minima(:), maxima(:)
    real(real64), allocatable, volatile :: cumulative_minima(:)
    real(real64) :: total_depth, total_mass, temporary, difference, variable_minimum, variable_maximum, threshold, terrain, &
                    accumulated, remainder, share, value
    integer(int32) :: column, layer, minimum_index, active, allocation_status, receiver
    if (klon < 1 .or. klon > 4096 .or. klevsn < 1 .or. kidia < 1 .or. kfdia > klon) call reject_contract()
    if (kfdia < kidia) return
    if (min(size(llnosnow), size(psdor), size(pssn, 1), size(prsn, 1), size(pdsnout, 1), size(ilevsna)) < klon) call &
      reject_contract()
    if (min(size(pssn, 2), size(prsn, 2), size(pdsnout, 2), size(rlevsnmin), size(rlevsnmax), size(rlevsnmin_gl), &
            size(rlevsnmax_gl)) < klevsn) call reject_contract()
    allocate (minima(klevsn), maxima(klevsn), cumulative_minima(klevsn), stat=allocation_status)
    if (allocation_status /= 0) call reject_contract()
    do column = kidia, kfdia
      total_depth = 0.0_real64
      total_mass = 0.0_real64
      do layer = 1, klevsn
        temporary = pssn(column, layer)/prsn(column, layer)
        total_depth = total_depth + temporary
        total_mass = total_mass + pssn(column, layer)
        pdsnout(column, layer) = 0.0_real64
      end do
      threshold = 5000.0_real64
      if (present(lemin)) threshold = 2000.0_real64
      if (total_mass >= threshold) then
        do layer = 1, klevsn
          minima(layer) = rlevsnmin_gl(layer)
          maxima(layer) = rlevsnmax_gl(layer)
        end do
      else
        terrain = 50.0_real64
        if (present(lemin)) terrain = 80.0_real64
        if (total_depth > 0.25_real64 .and. psdor(column) >= terrain) then
          difference = total_depth - 0.25_real64
          difference = 0.1_real64*difference
          variable_minimum = 0.1_real64 + difference
          variable_minimum = minimum(0.25_real64, variable_minimum)
          variable_maximum = 0.15_real64 + difference
          variable_maximum = minimum(0.3_real64, variable_maximum)
          do layer = 1, klevsn
            minima(layer) = variable_minimum
            maxima(layer) = variable_maximum
          end do
          maxima(1) = variable_minimum
          maxima(klevsn) = -1.0_real64
        else
          do layer = 1, klevsn
            minima(layer) = rlevsnmin(layer)
            maxima(layer) = rlevsnmax(layer)
          end do
        end if
      end if
      value = maxima(1)
      minimum_index = 1
      do layer = 2, klevsn
        if (maxima(layer) >= value) cycle
        value = maxima(layer)
        minimum_index = layer
      end do
      maxima(minimum_index) = 1.0e10_real64
      ! The reference sums all minima before the mask, including unused later layers.
      ! Volatile storage preserves the observed rounding of these real source additions.
      cumulative_minima(1) = minima(1)
      do layer = 2, klevsn
        cumulative_minima(layer) = cumulative_minima(layer - 1) + minima(layer)
      end do
      active = 1
      if (.not. llnosnow(column)) then
        do layer = 2, klevsn
          if (total_depth < cumulative_minima(layer)) exit
          active = layer
        end do
      end if
      ilevsna(column) = active
      if (active == 1) then
        pdsnout(column, 1) = total_depth
        cycle
      end if
      value = minimum(total_depth, maxima(1))
      pdsnout(column, 1) = value
      remainder = total_depth - value
      share = remainder/real(active - 1, real64)
      accumulated = value
      do layer = 2, active
        value = minimum(share, maxima(layer))
        pdsnout(column, layer) = value
        accumulated = accumulated + value
      end do
      remainder = total_depth - accumulated
      if (remainder > 10.0_real64*epsilon(1.0_real64)) then
        receiver = min(minimum_index, active)
        value = pdsnout(column, receiver) + total_depth
        pdsnout(column, receiver) = value - accumulated
      end if
    end do
  end subroutine srfsn_vgrid
  !> Preserve the assembly minimum and maximum at signed zero.
  pure function minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value = a
    else if (ieee_is_nan(b)) then
      value = b
    else if (a == 0.0_real64 .and. b == 0.0_real64) then
      value = transfer(ior(transfer(a, 0_int64), transfer(b, 0_int64)), value)
    else if (a < b) then
      value = a
    else
      value = b
    end if
  end function minimum
  !> Preserve the assembly maximum, including both signs of zero.
  pure function maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value = a
    else if (ieee_is_nan(b)) then
      value = b
    else if (a == 0.0_real64 .and. b == 0.0_real64) then
      value = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), value)
    else if (a > b) then
      value = a
    else
      value = b
    end if
  end function maximum
end module srfsn_vgrid_mod
