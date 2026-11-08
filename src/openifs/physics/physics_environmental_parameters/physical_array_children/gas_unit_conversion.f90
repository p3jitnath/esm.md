!> Read and rescale the native base gas owner without private class offsets.
module forecast_gas_unit_conversion
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: native_gas_state, get_gas, set_units_gas
  !> The caller initializes every member and owns mixing_ratio(ncol,nlev,12).
  !! Unit0 is mass ratio; unit1 is volume ratio; scales are dimensionless.
  type :: native_gas_state
    integer(int32) :: iunits(12), ntype, ncol, nlev, icode(12)
    real(real64) :: scale_factor(12)
    logical :: is_present(12), is_well_mixed(12)
    real(real64), allocatable :: mixing_ratio(:, :, :)
  end type
contains
  !> Calculate the ordered gas/air conversion with caller-supplied g/mol values.
  function gas_factor(this, gas, unit, molar_mass, initial) result(factor)
    type(native_gas_state), intent(in) :: this
    integer(int32), intent(in) :: gas, unit
    real(real64), intent(in) :: molar_mass(0:), initial
    real(real64) :: factor
    real(real64), parameter :: air_mass = transfer(int(z'403cf851e0000000', int64), 0.0_real64)
    factor = initial
    if (unit == 0 .and. this%iunits(gas) == 1) then
      factor = factor*molar_mass(gas)
      factor = factor/air_mass
    else if (unit == 1 .and. this%iunits(gas) == 0) then
      factor = factor*air_mass
      factor = factor/molar_mass(gas)
    end if
    factor = factor*this%scale_factor(gas)
  end function
  !> Read selected columns into a native, possibly strided INOUT ratio array.
  !! Absent gas writes positive zero. A factor of one copies each input bit.
  !! All scales are positive finite caller inputs. Status2 leaves output intact.
  subroutine get_gas(this, igas, iunits, mixing_ratio, molar_mass, status, scale_factor, istartcol)
    type(native_gas_state), intent(in) :: this
    integer(int32), intent(in) :: igas, iunits
    real(real64), intent(inout) :: mixing_ratio(:, :)
    real(real64), intent(in) :: molar_mass(0:)
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: scale_factor
    integer(int32), optional, intent(in) :: istartcol
    integer :: first, j, k
    real(real64) :: initial
    real(real64), volatile :: factor
    status = 2
    if (igas < 1 .or. igas > 12 .or. iunits < 0 .or. iunits > 1) return
    if (size(mixing_ratio, 1) < 1) return
    if (.not. this%is_present(igas)) then
      do k = 1, size(mixing_ratio, 2)
        do j = 1, size(mixing_ratio, 1)
          mixing_ratio(j, k) = 0.0_real64
        end do
      end do
      status = 0
      return
    end if
    if (this%ncol < 0 .or. this%nlev < 0 .or. ubound(molar_mass, 1) < 12) return
    first = 1
    if (present(istartcol)) first = istartcol
    if (size(mixing_ratio, 1) < 1 .or. size(mixing_ratio, 2) /= this%nlev) return
    if (first < 1 .or. int(first, int64) + size(mixing_ratio, 1, kind=int64) - 1 > this%ncol) return
    initial = 1.0_real64
    if (present(scale_factor)) initial = scale_factor
    if (this%is_present(igas)) then
      if (.not. allocated(this%mixing_ratio)) return
      if (any(shape(this%mixing_ratio) /= [this%ncol, this%nlev, 12])) return
      factor = gas_factor(this, igas, iunits, molar_mass, initial)
      do k = 1, size(mixing_ratio, 2)
        do j = 1, size(mixing_ratio, 1)
          if (factor == 1.0_real64) then
            mixing_ratio(j, k) = this%mixing_ratio(first + j - 1, k, igas)
          else
            mixing_ratio(j, k) = this%mixing_ratio(first + j - 1, k, igas)*factor
          end if
        end do
      end do
    else
      do k = 1, size(mixing_ratio, 2)
        do j = 1, size(mixing_ratio, 1)
          mixing_ratio(j, k) = 0.0_real64
        end do
      end do
    end if
    status = 0
  end subroutine
  !> Update one gas or the exact listed sequence; all inactive members persist.
  !! The optional reciprocal is calculated even for an admitted empty list.
  subroutine set_units_gas(this, iunits, molar_mass, status, igas, scale_factor)
    type(native_gas_state), intent(inout) :: this
    integer(int32), intent(in) :: iunits
    real(real64), intent(in) :: molar_mass(0:)
    integer(int32), intent(out) :: status
    integer(int32), optional, intent(in) :: igas
    real(real64), optional, intent(in) :: scale_factor
    integer :: count, j, gas, col, lev
    real(real64) :: new_scale, factor
    real(real64), volatile :: reciprocal
    status = 2
    if (iunits < 0 .or. iunits > 1 .or. this%ntype < 0 .or. this%ntype > 12) return
    if (this%ncol < 0 .or. this%nlev < 0 .or. ubound(molar_mass, 1) < 12) return
    count = this%ntype
    if (present(igas)) then
      if (igas < 1 .or. igas > 12) return
      count = 1
    else
      do j = 1, count
        if (this%icode(j) < 1 .or. this%icode(j) > 12) return
      end do
    end if
    do j = 1, count
      if (present(igas)) then
        gas = igas
      else
        gas = this%icode(j)
      end if
      if (this%is_present(gas)) then
        if (.not. allocated(this%mixing_ratio)) return
        if (any(shape(this%mixing_ratio) /= [this%ncol, this%nlev, 12])) return
      end if
    end do
    new_scale = 1.0_real64
    reciprocal = 1.0_real64
    if (present(scale_factor)) then
      new_scale = scale_factor
      reciprocal = 1.0_real64/new_scale
    end if
    do j = 1, count
      if (present(igas)) then
        gas = igas
      else
        gas = this%icode(j)
      end if
      if (.not. this%is_present(gas)) cycle
      factor = gas_factor(this, gas, iunits, molar_mass, reciprocal)
      if (factor /= 1.0_real64) then
        do lev = 1, this%nlev
          do col = 1, this%ncol
            this%mixing_ratio(col, lev, gas) = this%mixing_ratio(col, lev, gas)*factor
          end do
        end do
      end if
      this%iunits(gas) = iunits
      this%scale_factor(gas) = new_scale
    end do
    status = 0
  end subroutine
end module
