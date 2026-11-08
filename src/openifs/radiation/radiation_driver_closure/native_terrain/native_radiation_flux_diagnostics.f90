!> Reconstruct selected radiation diagnostics from existing flux owners.
!! No printed diagnostic or interpolation stage is supplied by this module.
!! Fluxes use W/m2; transmission and solar cosine are dimensionless.
!! Scientific source attribution: ECMWF RADDIAG and the frozen selected caller.
module native_radiation_flux_diagnostics
  use iso_fortran_env, only: int32, real64
  use yomhook, only: lhook, dr_hook, jphook
  implicit none
  private
  public :: raddiag
contains
!> Update clear boundary pairs and complete active total-flux rows.
!! First-cell and row-point arrays describe the live local latitude rows.
!! A zero first-cell marks an absent row. All arrays use one-based views.
!! Original source-unwritten cells and inactive rows remain unchanged.
  integer(int32) function raddiag(first_row, last_row, first_cell, row_points, curvature, solar_constant, &
                    mu, longwave, shortwave, clear_shortwave, clear_longwave, lw_clear, lw_total, sw_clear, sw_total) result(status)
    integer(int32), intent(in) :: first_row, last_row, first_cell(:), row_points(:)
    real(real64), intent(in) :: curvature, solar_constant, mu(:), longwave(:, :), shortwave(:, :)
    real(real64), intent(in) :: clear_shortwave(:, :), clear_longwave(:, :)
    real(real64), intent(inout) :: lw_clear(:, :), lw_total(:, :), sw_clear(:, :), sw_total(:, :)
    real(real64), allocatable :: effective_cosine(:)
    real(real64), volatile :: curvature_product
    real(real64) :: p, q, scale
    real(jphook) :: hook
    integer :: row, first, last, cell, level, columns, boundaries, error
    status = 2
    columns = size(mu); boundaries = size(longwave, 2)
    if (columns < 1 .or. columns > huge(0_int32) .or. boundaries < 1 .or. boundaries > 513) return
    if (first_row < 1 .or. last_row > size(first_cell) .or. last_row > size(row_points)) return
    if (curvature <= 0.0_real64) return
    if (size(longwave, 1) < columns .or. size(shortwave, 1) < columns .or. size(shortwave, 2) < boundaries) return
    if (size(clear_shortwave, 1) < columns .or. size(clear_shortwave, 2) < boundaries) return
    if (size(clear_longwave, 1) < columns .or. size(clear_longwave, 2) < boundaries) return
    if (size(lw_total, 1) < columns .or. size(lw_total, 2) < boundaries) return
    if (size(sw_total, 1) < columns .or. size(sw_total, 2) < boundaries) return
    if (size(lw_clear, 1) < columns .or. size(lw_clear, 2) < 2 .or. size(sw_clear, 1) < columns .or. size(sw_clear, 2) < 2) return
    do row = first_row, last_row
      first = first_cell(row)
      if (first == 0) cycle
      if (first < 1 .or. row_points(row) < 1) return
      if (int(first, 8) + int(row_points(row), 8) - 1_8 > columns) return
    end do
    if (lhook) call dr_hook('RADDIAG', 0, hook)
    allocate (effective_cosine(columns), stat=error)
    if (error /= 0) then
      status = 1
      return
    end if
    p = curvature + 2.0_real64
    curvature_product = curvature*p
    do row = first_row, last_row
      first = first_cell(row)
      if (first == 0) cycle
      last = first + row_points(row) - 1
      do cell = first, last
        if (mu(cell) >= 1.0e-10_real64) then
          p = mu(cell)*mu(cell)
          p = p + curvature_product
          p = sqrt(p)
          p = p - mu(cell)
          effective_cosine(cell) = curvature/p
        else
          effective_cosine(cell) = 0.0_real64
        end if
      end do
      do level = 1, boundaries
        do cell = first, last
          lw_total(cell, level) = longwave(cell, level)
          p = effective_cosine(cell)*solar_constant
          sw_total(cell, level) = p*shortwave(cell, level)
        end do
      end do
      do cell = first, last
        scale = effective_cosine(cell)*solar_constant
        sw_clear(cell, 1) = scale*clear_shortwave(cell, 1)
        sw_clear(cell, 2) = scale*clear_shortwave(cell, boundaries)
        lw_clear(cell, 1) = clear_longwave(cell, 1)
        lw_clear(cell, 2) = clear_longwave(cell, boundaries)
      end do
    end do
    deallocate (effective_cosine)
    if (lhook) call dr_hook('RADDIAG', 1, hook)
    status = 0
  end function
end module
