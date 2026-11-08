!> Operational temperature and pressure rates with the public matrix boundary.
!! The accepted scalar SITNU entry and its compiled callers remain unchanged.
module md2asm_operational_temperature_pressure_rates
  use iso_fortran_env, only: int32, real64
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_thermal_operators, only: spectral_temperature_pressure_rates
  use md2asm_public_vertical_matrix_integral, only: integrate_public_vertical_matrix
  implicit none
  private
  public :: spectral_temperature_pressure_rates_public
contains
  !> Form the selected operational SITNU rates.
  !! divergence(level,column) is1/s, thermal_rate is K/s and pressure_rate
  !! is1/s. Named coefficient arrays contain initialized source values.
  !! chunk is the actual geometry NPROMA. The finite-element route uses
  !! integral boundary3 and RINTBF11(level+1,level+2), with positive-zero
  !! top and bottom input columns. Public BLAS owns its declared reduction.
  !! The conventional and empty routes reuse the accepted owned entry.
  !! Inputs and outputs are disjoint; padding stays unchanged. Status0
  !! succeeds,1 refuses allocation and2 refuses metadata or matrix bounds.
  subroutine spectral_temperature_pressure_rates_public(divergence, kappa, &
                                                        thermal_coefficient, surface_coefficient, accumulation_weight, &
                                                        mean_weight, &
                                                        delta, alpha, metric, full_level_weight, finite_elements, tables, &
                                                        integral_bc, derivative_bc, chunk, thermal_rate, pressure_rate, status)
    real(real64), intent(in) :: divergence(:, :), kappa, thermal_coefficient, surface_coefficient
    real(real64), intent(in) :: accumulation_weight(:), mean_weight(:), delta(:), alpha(:)
    real(real64), intent(in) :: metric(:), full_level_weight(:)
    logical, intent(in) :: finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc, derivative_bc, chunk
    real(real64), intent(inout) :: thermal_rate(:, :), pressure_rate(:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: input(:, :), integral(:, :)
    real(real64) :: factor, product, reciprocal, value
    integer :: levels, columns, column, level, allocation_status
    status = 2
    levels = size(divergence, 1)
    columns = size(divergence, 2)
    if (chunk < 1 .or. levels > 512) return
    if (.not. finite_elements .or. levels == 0 .or. columns == 0) then
      call spectral_temperature_pressure_rates(divergence, kappa, thermal_coefficient, &
                                               surface_coefficient, accumulation_weight, mean_weight, delta, alpha, metric, &
                                               full_level_weight, &
                                               finite_elements, tables, integral_bc, derivative_bc, thermal_rate, &
                                               pressure_rate, status)
      return
    end if
    if (size(pressure_rate) < columns) return
    if (size(thermal_rate, 1) < levels .or. size(thermal_rate, 2) < columns) return
    if (size(accumulation_weight) < levels .or. size(metric) < levels .or. size(full_level_weight) < levels) return
    if (integral_bc /= 3) return
    if (.not. associated(tables%rintbf11)) return
    if (any(shape(tables%rintbf11) /= [levels + 1, levels + 2])) return
    if (.not. is_contiguous(tables%rintbf11)) return
    factor = kappa*thermal_coefficient
    allocate (input(columns, 0:levels + 1), integral(columns, levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    input(:, 0) = 0.0_real64
    input(:, levels + 1) = 0.0_real64
    do level = 1, levels
      do column = 1, columns
        product = divergence(level, column)*accumulation_weight(level)
        input(column, level) = product*metric(level)
      end do
    end do
    call integrate_public_vertical_matrix(columns, 1, columns, levels + 2, levels + 1, &
                                          tables%rintbf11, input, integral, 0, chunk, status)
    if (status /= 0) return
    do column = 1, columns
      do level = 1, levels
        reciprocal = 1.0_real64/full_level_weight(level)
        product = factor*integral(column, level)
        value = product*reciprocal
        thermal_rate(level, column) = value
      end do
      pressure_rate(column) = integral(column, levels + 1)*surface_coefficient
    end do
    status = 0
  end subroutine
end module
