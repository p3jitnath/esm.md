!> Complete selected serial TRSTOM/TRMTOS field copies with native views.
module forecast_selected_spectral_copies
  use iso_fortran_env, only: int32, int64, real64
  use yomhook, only: lhook, dr_hook
  implicit none
  private
  public :: native_spectral_copy_pair, native_spectral_pressure_copy_pair
  public :: copy_spectral_columns_to_levels, copy_spectral_levels_to_columns, spectral_copy_count
  type :: native_spectral_copy_pair
    real(real64), pointer :: source(:, :) => null(), destination(:, :) => null()
  end type
  type :: native_spectral_pressure_copy_pair
    real(real64), pointer :: source(:) => null(), destination(:) => null()
  end type
  integer(int64), save :: successful_calls(0:1) = 0_int64
contains
  !> PAIRS order is vorticity, divergence, temperature, auxiliary.
 !! Borrow complete19x506 FP64 owners with stable TARGET lifetime.
 !! A missing destination skips its pair as in the source. Pressure is506words.
 !! Both selected process/pressure-owner facts must equal one; the two source
 !! optional-physics flags must be false. Native refusal returns2 before copies.
  integer(int32) function copy_spectral_columns_to_levels(levels, processes, pressure_owner, nonhydrostatic, spectral_diagnostics, &
                                                          pairs, pressure) result(status)
    integer(int32), intent(in) :: levels, processes, pressure_owner
    logical, intent(in) :: nonhydrostatic, spectral_diagnostics
    type(native_spectral_copy_pair), intent(in) :: pairs(4)
    type(native_spectral_pressure_copy_pair), intent(in) :: pressure
 status = copy_selected_spectral_fields(1, levels, processes, pressure_owner, nonhydrostatic, spectral_diagnostics, pairs, pressure)
  end function
  integer(int32) function copy_spectral_levels_to_columns(levels, processes, pressure_owner, nonhydrostatic, spectral_diagnostics, &
                                                          pairs, pressure) result(status)
    integer(int32), intent(in) :: levels, processes, pressure_owner
    logical, intent(in) :: nonhydrostatic, spectral_diagnostics
    type(native_spectral_copy_pair), intent(in) :: pairs(4)
    type(native_spectral_pressure_copy_pair), intent(in) :: pressure
 status = copy_selected_spectral_fields(0, levels, processes, pressure_owner, nonhydrostatic, spectral_diagnostics, pairs, pressure)
  end function
  integer(int32) function copy_selected_spectral_fields(direction, levels, processes, pressure_owner, nonhydrostatic, &
                                                        spectral_diagnostics, pairs, pressure) result(status)
    integer, intent(in) :: direction
    integer(int32), intent(in) :: levels, processes, pressure_owner
    logical, intent(in) :: nonhydrostatic, spectral_diagnostics
    type(native_spectral_copy_pair), intent(in) :: pairs(4)
    type(native_spectral_pressure_copy_pair), intent(in) :: pressure
    integer :: j, k, l, si, sj, di, dj
    integer(int32) :: hook_bits
    real(real64) :: handle
    character(6) :: name
    status = 2
    if (levels /= 19 .or. processes /= 1 .or. pressure_owner /= 1) return
    if (transfer(nonhydrostatic, 0_int32) /= 0 .or. transfer(spectral_diagnostics, 0_int32) /= 0) return
    hook_bits = transfer(lhook, 0_int32)
    if (hook_bits < 0 .or. hook_bits > 1) return
    name = 'TRMTOS'
    if (direction == 1) name = 'TRSTOM'
    if (hook_bits == 1) call dr_hook(name, 0, handle)
    do j = 1, 4
      if (.not. associated(pairs(j)%destination)) cycle
      if (.not. associated(pairs(j)%source)) return
      if (any(shape(pairs(j)%source) /= [19, 506]) .or. any(shape(pairs(j)%destination) /= [19, 506])) return
      if (.not. is_contiguous(pairs(j)%source) .or. .not. is_contiguous(pairs(j)%destination)) return
    end do
    if (associated(pressure%destination)) then
      if (.not. associated(pressure%source)) return
      if (size(pressure%source) /= 506 .or. size(pressure%destination) /= 506) return
      if (.not. is_contiguous(pressure%source) .or. .not. is_contiguous(pressure%destination)) return
    end if
    do j = 1, 4
      if (.not. associated(pairs(j)%destination)) cycle
      si = lbound(pairs(j)%source, 1); sj = lbound(pairs(j)%source, 2)
      di = lbound(pairs(j)%destination, 1); dj = lbound(pairs(j)%destination, 2)
      do l = 0, 18
        do k = 0, 505
          pairs(j)%destination(di + l, dj + k) = pairs(j)%source(si + l, sj + k)
        end do
      end do
    end do
    if (associated(pressure%destination)) then
      si = lbound(pressure%source, 1); di = lbound(pressure%destination, 1)
      do k = 0, 505
        pressure%destination(di + k) = pressure%source(si + k)
      end do
    end if
    if (hook_bits == 1) call dr_hook(name, 1, handle)
    if (successful_calls(direction) == huge(0_int64)) then
      successful_calls(direction) = not(huge(0_int64))
    else
      successful_calls(direction) = successful_calls(direction) + 1_int64
    end if
    status = 0
  end function
  function spectral_copy_count(direction) result(value)
    integer, intent(in) :: direction
    integer(int64) :: value
    value = 0_int64
    if (direction < 0 .or. direction > 1) return
    value = successful_calls(direction)
  end function
end module forecast_selected_spectral_copies
