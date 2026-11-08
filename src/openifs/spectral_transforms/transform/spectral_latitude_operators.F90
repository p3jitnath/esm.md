!> Complete SPNSDE, VDTUV and UVTVD with original neighbouring-degree arithmetic.
module md2asm_spectral_latitude_operators
  use iso_fortran_env, only: int32, real64
  use md2asm_transform_types, only: transform_spectral_tables, transform_environment_ready
  implicit none
  private
  public :: spectral_north_south_derivative, vorticity_divergence_to_wind, wind_to_vorticity_divergence
contains
!> Validate live coefficient tables with their original degree lower bounds.
  logical function tables_ready(t, m, fields, laplacian, degree_map)
    type(transform_spectral_tables), intent(in) :: t
    integer, intent(in) :: m, fields
    logical, intent(in) :: laplacian, degree_map
    tables_ready = .false.
    if (t%maximum_degree < 0 .or. t%total_degree < t%maximum_degree .or. t%total_degree > 4096) return
    if (m < 0 .or. m > t%maximum_degree .or. fields < 0 .or. fields > 4096) return
    if (.not. associated(t%degree_number)) return
    if (lbound(t%degree_number, 1) > -1 .or. ubound(t%degree_number, 1) < t%total_degree + 3) return
    if (laplacian) then
      if (.not. associated(t%inverse_laplacian)) return
      if (lbound(t%inverse_laplacian, 1) > -1 .or. ubound(t%inverse_laplacian, 1) < t%maximum_degree + 2) return
    end if
    if (degree_map) then
      if (.not. associated(t%degree_row)) return
      if (lbound(t%degree_row, 1) > -1 .or. ubound(t%degree_row, 1) < m - 1) return
    end if
    tables_ready = transform_environment_ready()
  end function
!> Write derivative(degree,complex-field) from immutable field and epsilon(0:).
!! Output units equal field units; each complex field occupies two columns.
  subroutine spectral_north_south_derivative(t, m, fields, epsilon, field, derivative, status)
    type(transform_spectral_tables), intent(in) :: t
    integer(int32), intent(in) :: m, fields
    real(real64), intent(in) :: epsilon(0:), field(:, :)
    real(real64), intent(inout) :: derivative(:, :)
    integer(int32), intent(out) :: status
    integer :: n, row, j, stride
    real(real64) :: a, b, x, y
    status = 2
    if (fields < 0 .or. fields > 4096) return
    if (fields == 0) then
      status = 0; return
    end if
    if (.not. tables_ready(t, m, fields, .false., .false.)) return
    if (ubound(epsilon, 1) < t%maximum_degree + 2) return
    if (size(field, 1) < t%maximum_degree + 4 - m .or. size(field, 2) < 2*fields) return
    if (size(derivative, 1) < t%maximum_degree + 3 - m .or. size(derivative, 2) < 2*fields) return
    stride = 1; if (m == 0) stride = 2
    do n = t%maximum_degree + 1, m, -1
      a = -t%degree_number(n - 1)
      a = a*epsilon(n)
      b = t%degree_number(n + 2)*epsilon(n + 1)
      row = t%maximum_degree + 3 - n
      do j = 1, 2*fields, stride
        x = a*field(row + 1, j)
        y = b*field(row - 1, j)
        derivative(row, j) = x + y
      end do
    end do
    status = 0
  end subroutine
!> Convert immutable vorticity/divergence coefficients into wind coefficient arrays.
!! Tables carry the original length scale; the returned unit follows their inputs.
  subroutine vorticity_divergence_to_wind(t, m, fields, epsilon, vorticity, divergence, u, v, status)
    type(transform_spectral_tables), intent(in) :: t
    integer(int32), intent(in) :: m, fields
    real(real64), intent(in) :: epsilon(0:), vorticity(:, :), divergence(:, :)
    real(real64), intent(inout) :: u(:, :), v(:, :)
    integer(int32), intent(out) :: status
    integer :: n, row, j, rows
    real(real64) :: a, negative_a, b, positive_m, negative_m, x, y, z, order_value
    status = 2
    if (fields < 0 .or. fields > 4096) return
    if (fields == 0) then
      status = 0; return
    end if
    if (.not. tables_ready(t, m, fields, .true., .false.)) return
    if (ubound(epsilon, 1) < t%maximum_degree + 2) return
    rows = t%maximum_degree + 4 - m
    if (min(size(vorticity, 1), size(divergence, 1)) < rows) return
    if (min(size(vorticity, 2), size(divergence, 2), size(u, 2), size(v, 2)) < 2*fields) return
    if (min(size(u, 1), size(v, 1)) < rows - 1) return
    do n = t%maximum_degree + 1, m, -1
      a = t%degree_number(n - 1); negative_a = -a
      a = a*epsilon(n); negative_a = negative_a*epsilon(n)
      a = a*t%inverse_laplacian(n - 1); negative_a = negative_a*t%inverse_laplacian(n - 1)
      b = t%degree_number(n + 2)*epsilon(n + 1)
      b = b*t%inverse_laplacian(n + 1)
      order_value = real(m, real64)
      positive_m = order_value*t%inverse_laplacian(n)
      negative_m = -order_value
      negative_m = negative_m*t%inverse_laplacian(n)
      row = t%maximum_degree + 3 - n
      do j = 1, 2*fields, 2
        if (m /= 0) then
          x = negative_m*divergence(row, j + 1); y = a*vorticity(row + 1, j); x = x + y
          z = b*vorticity(row - 1, j); u(row, j) = x - z
          x = positive_m*divergence(row, j); y = a*vorticity(row + 1, j + 1); x = x + y
          z = b*vorticity(row - 1, j + 1); u(row, j + 1) = x - z
          x = negative_m*vorticity(row, j + 1); y = a*divergence(row + 1, j); x = x - y
          z = b*divergence(row - 1, j); v(row, j) = x + z
          x = positive_m*vorticity(row, j); y = a*divergence(row + 1, j + 1); x = x - y
          z = b*divergence(row - 1, j + 1); v(row, j + 1) = x + z
        else
          x = a*vorticity(row + 1, j); y = b*vorticity(row - 1, j); u(row, j) = x - y
          x = negative_a*divergence(row + 1, j); y = b*divergence(row - 1, j); v(row, j) = x + y
        end if
      end do
    end do
    status = 0
  end subroutine
!> Prepare the source positive-zero boundary in U/V, then write vorticity/divergence.
!! All matrices are (degree,complex-field); untouched columns and rows are retained.
  subroutine wind_to_vorticity_divergence(t, m, fields, epsilon, u, v, vorticity, divergence, status)
    type(transform_spectral_tables), intent(in) :: t
    integer(int32), intent(in) :: m, fields
    real(real64), intent(in) :: epsilon(0:)
    real(real64), intent(inout) :: u(:, :), v(:, :), vorticity(:, :), divergence(:, :)
    integer(int32), intent(out) :: status
    integer :: n, row, j, rows, boundary
    real(real64) :: a, negative_a, b, positive_m, negative_m, x, y, z
    status = 2
    if (fields < 0 .or. fields > 4096) return
    if (fields == 0) then
      status = 0; return
    end if
    if (.not. tables_ready(t, m, fields, .false., .true.)) return
    if (ubound(epsilon, 1) < t%total_degree + 1) return
    rows = t%total_degree + 3 - m
    if (min(size(u, 1), size(v, 1)) < rows) return
    if (min(size(u, 2), size(v, 2), size(vorticity, 2), size(divergence, 2)) < 2*fields) return
    if (min(size(vorticity, 1), size(divergence, 1)) < rows - 1) return
    boundary = t%degree_row(m - 1)
    if (boundary < 1 .or. boundary > min(size(u, 1), size(v, 1))) return
    do j = 1, 2*fields
      u(boundary, j) = 0.0_real64
      v(boundary, j) = 0.0_real64
    end do
    positive_m = real(m, real64); negative_m = -positive_m
    do n = m, t%total_degree
      a = t%degree_number(n); negative_a = -a
      a = a*epsilon(n + 1); negative_a = negative_a*epsilon(n + 1)
      b = t%degree_number(n + 1)*epsilon(n)
      row = t%total_degree + 2 - n
      do j = 1, 2*fields, 2
        if (m /= 0) then
          x = negative_m*v(row, j + 1); y = a*u(row - 1, j); x = x - y
          z = b*u(row + 1, j); vorticity(row, j) = x + z
          x = positive_m*v(row, j); y = a*u(row - 1, j + 1); x = x - y
          z = b*u(row + 1, j + 1); vorticity(row, j + 1) = x + z
          x = negative_m*u(row, j + 1); y = a*v(row - 1, j); x = x + y
          z = b*v(row + 1, j); divergence(row, j) = x - z
          x = positive_m*u(row, j); y = a*v(row - 1, j + 1); x = x + y
          z = b*v(row + 1, j + 1); divergence(row, j + 1) = x - z
        else
          x = negative_a*u(row - 1, j); y = b*u(row + 1, j); vorticity(row, j) = x + y
          x = a*v(row - 1, j); y = b*v(row + 1, j); divergence(row, j) = x - y
        end if
      end do
    end do
    status = 0
  end subroutine
end module
