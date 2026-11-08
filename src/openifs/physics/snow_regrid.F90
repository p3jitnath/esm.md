module srfsn_regrid_mod
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_nan
  implicit none
  private
  public :: srfsn_regrid
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Remap snow mass and heat in the operation order of snow_regrid.S.
  !!
  !! Snow mass and water use kg m^-2, density uses kg m^-3, temperature uses kelvin,
  !! and layer depths use metres. Only active cells of the four new-state arrays change.
  subroutine srfsn_regrid(kidia, kfdia, klon, klevsn, llnosnow, pssn, prsn, pwsn, ptsn, pdsnnew, pssnnew, prsnnew, pwsnnew, ptsnnew)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevsn
    logical(int32), intent(in) :: llnosnow(:)
    real(real64), intent(in) :: pssn(:, :), prsn(:, :), pwsn(:, :), ptsn(:, :), pdsnnew(:, :)
    real(real64), intent(inout) :: pssnnew(:, :), prsnnew(:, :), pwsnnew(:, :), ptsnnew(:, :)
    real(real64), allocatable :: depth(:), heat(:), old_edges(:), new_edges(:)
    real(real64) :: total_depth, total_new_depth, solid, mass, energy, overlap, left, right, fraction, value, temporary
    real(real64), parameter :: freezing = transfer(int(z'4071128f5c28f5c3', int64), 0.0_real64)
    real(real64), parameter :: heat_capacity = transfer(int(z'40a1688590b21643', int64), 0.0_real64)
    real(real64), parameter :: latent_heat = transfer(int(z'41145e1000000000', int64), 0.0_real64)
    integer(int32) :: column, layer, old_layer, allocation_status
    if (klon < 1 .or. klon > 4096 .or. klevsn < 1 .or. kidia < 1 .or. kfdia > klon) call reject_contract()
    if (kfdia < kidia) return
    if (min(size(llnosnow),size(pssn,1),size(prsn,1),size(pwsn,1),size(ptsn,1),size(pdsnnew,1),size(pssnnew,1),size(prsnnew,1),size(pwsnnew,1),size(ptsnnew,1))<klon) call reject_contract()
    if (min(size(pssn,2),size(prsn,2),size(pwsn,2),size(ptsn,2),size(pdsnnew,2),size(pssnnew,2),size(prsnnew,2),size(pwsnnew,2),size(ptsnnew,2))<klevsn) call reject_contract()
    allocate (depth(klevsn), heat(klevsn), old_edges(0:klevsn), new_edges(0:klevsn), stat=allocation_status)
    if (allocation_status /= 0) call reject_contract()
    do column = kidia, kfdia
      old_edges(0) = 0.0_real64
      new_edges(0) = 0.0_real64
      total_depth = 0.0_real64
      total_new_depth = 0.0_real64
      solid = 0.0_real64
      do layer = 1, klevsn
        depth(layer) = pssn(column, layer)/prsn(column, layer)
        total_depth = total_depth + depth(layer)
        total_new_depth = total_new_depth + pdsnnew(column, layer)
        old_edges(layer) = total_depth
        new_edges(layer) = total_new_depth
        value = heat_capacity*pssn(column, layer)
        temporary = ptsn(column, layer) - freezing
        value = value*temporary
        temporary = pssn(column, layer) - pwsn(column, layer)
        solid = solid + temporary
        temporary = latent_heat*temporary
        heat(layer) = value - temporary
      end do
      if (llnosnow(column) .or. solid == 0.0_real64) then
        do layer = 1, klevsn
          pssnnew(column, layer) = pssn(column, layer)
          prsnnew(column, layer) = prsn(column, layer)
          pwsnnew(column, layer) = pwsn(column, layer)
          ptsnnew(column, layer) = ptsn(column, layer)
        end do
        cycle
      end if
      do layer = 1, klevsn
        mass = 0.0_real64
        energy = 0.0_real64
        do old_layer = 1, klevsn
          left = maximum(new_edges(layer - 1), old_edges(old_layer - 1))
          right = minimum(new_edges(layer), old_edges(old_layer))
          overlap = right - left
          fraction = maximum(0.0_real64, overlap)
          if (fraction > 0.0_real64) fraction = fraction/depth(old_layer)
          value = fraction*pssn(column, old_layer)
          mass = mass + value
          value = fraction*heat(old_layer)
          energy = energy + value
        end do
        pssnnew(column, layer) = mass
        if (pdsnnew(column, layer) > 0.0_real64) then
          prsnnew(column, layer) = mass/pdsnnew(column, layer)
          value = latent_heat*mass
          value = energy + value
          temporary = heat_capacity*mass
          value = value/temporary
          value = freezing + value
          ptsnnew(column, layer) = minimum(freezing, value)
          value = energy/latent_heat
          value = mass + value
          value = minimum(mass, value)
          pwsnnew(column, layer) = maximum(0.0_real64, value)
        else
          pwsnnew(column, layer) = 0.0_real64
          ptsnnew(column, layer) = ptsn(column, layer)
          prsnnew(column, layer) = prsn(column, layer)
        end if
      end do
    end do
  end subroutine srfsn_regrid
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
end module srfsn_regrid_mod
