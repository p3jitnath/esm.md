!> Operational spectral thermal entries with an explicit public BLAS boundary.
!! The existing scalar entries and their native interfaces remain unchanged.
module md2asm_operational_spectral_thermal
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_thermal_operators, only: spectral_geopotential
  use md2asm_public_vertical_matrix_integral, only: integrate_public_vertical_matrix
  implicit none
  private
  public :: spectral_geopotential_public
contains
  !> Form SIGAM using the original operational finite-element matrix call.
  !! temperature(level,column) is K, rd is J/(kg K), and gamma is J/kg.
  !! All coefficient values are initialized inputs and are not recalculated.
  !! chunk is the actual geometry NPROMA. The finite-element route currently
  !! supports the selected integral boundary3 and its RINTBF11(level+1,level+2)
  !! matrix. The conventional route reuses the accepted owned scalar entry.
  !! Inputs, coefficients and output are disjoint. Only the active gamma
  !! rectangle changes; padding remains unchanged. Status0 succeeds,
  !! 1 refuses allocation and2 refuses bounds or an unsupported matrix.
  subroutine spectral_geopotential_public(temperature, logarithmic_pressure, rd, &
                                          surface_coefficient, alpha, delta, metric, finite_elements, tables, &
                                          integral_bc, derivative_bc, chunk, gamma, status)
    real(real64), intent(in) :: temperature(:, :), logarithmic_pressure(:)
    real(real64), intent(in) :: rd, surface_coefficient, alpha(:), delta(:), metric(:)
    logical, intent(in) :: finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc, derivative_bc, chunk
    real(real64), intent(inout) :: gamma(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: input(:, :), integral(:, :)
    real(real64) :: product, minus_rd, surface
    integer :: levels, columns, column, level, allocation_status
    status = 2
    levels = size(temperature, 1)
    columns = size(temperature, 2)
    if (chunk < 1 .or. levels > 512) return
    if (levels == 0 .or. columns == 0) then
      status = 0
      return
    end if
    if (size(gamma, 1) < levels .or. size(gamma, 2) < columns) return
    if (size(logarithmic_pressure) < columns .or. size(delta) < levels) return
    if (.not. finite_elements) then
      call spectral_geopotential(temperature, logarithmic_pressure, rd, surface_coefficient, &
                                 alpha, delta, metric, finite_elements, tables, integral_bc, derivative_bc, gamma, status)
      return
    end if
    if (integral_bc /= 3 .or. size(metric) < levels) return
    if (.not. associated(tables%rintbf11)) return
    if (any(shape(tables%rintbf11) /= [levels + 1, levels + 2])) return
    if (.not. is_contiguous(tables%rintbf11)) return
    allocate (input(columns, 0:levels + 1), integral(columns, levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    input(:, 0) = 0.0_real64
    input(:, levels + 1) = 0.0_real64
    minus_rd = -rd
    do level = 1, levels
      do column = 1, columns
        product = minus_rd*temperature(level, column)
        product = product*delta(level)
        input(column, level) = product*metric(level)
      end do
    end do
    call integrate_public_vertical_matrix(columns, 1, columns, levels + 2, levels + 1, &
                                          tables%rintbf11, input, integral, 1, chunk, status)
    if (status /= 0) return
    do column = 1, columns
      surface = logarithmic_pressure(column)*surface_coefficient
      do level = 1, levels
        gamma(level, column) = integral(column, level) + surface
      end do
    end do
    status = 0
  end subroutine
end module
