!> Calculate source spectral wave norms and their ordered vertical means.
module forecast_ordered_spectral_norm_arithmetic
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_nan
  implicit none
  private
  public :: spectral_norm_matrix, spectral_norm_average
  public :: selected_spectral_norm_matrix, selected_spectral_norm_average
  public :: operational_spectral_norm_matrix, operational_spectral_norm_average
  public :: SPNORMB, SPNORMBE, SPNORMAVE
  interface SPNORMB
    module procedure scalar_spectral_norm_matrix
  end interface
  interface SPNORMBE
    module procedure kinetic_spectral_norm_matrix
  end interface
  interface SPNORMAVE
    module procedure spectral_norm_average
  end interface
contains
  !> Form one local wave value for each active level in original degree order.
  !!
  !! maximum_degree is1:8191. waves lists local wave numbers in their actual
  !! producer order. first_column(0:) gives one-based REAL column addresses.
  !! Each degree occupies adjacent real/imaginary columns,including the unused
  !! imaginary position of wave zero. field(level,real_column) is borrowed.
  !! inverse_laplacian(0:) is the signed original RLAPIN in square metres;only
  !! the kinetic route consumes it. result(level,local_wave) is caller-owned.
  !! Levels0:512 and empty local wave lists are valid. Inactive output stays
  !! unchanged. All arrays must be disjoint from the mutable result.
  !!
  !! Ordinary results have squared field units. Kinetic values multiply by
  !! minus RLAPIN before the degree sum. Every product and sum rounds in FP64.
  !! The caller establishes nearest rounding and gradual underflow. Natural
  !! floating flags remain visible. Status2 refuses metadata before any write;
  !! status0 computes all admitted cells. There is no allocation or reduction.
  subroutine spectral_norm_matrix(maximum_degree, waves, first_column, inverse_laplacian, field, &
                                  kinetic, levels, result, status)
    integer(int32), intent(in) :: maximum_degree, waves(:), first_column(0:), levels
    real(real64), intent(in) :: inverse_laplacian(0:), field(:, :)
    logical, intent(in) :: kinetic
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    integer :: j, m, degree, level, column
    real(real64) :: total, real_square, imaginary_square, coefficient, metric, product
    real(real64), parameter :: floor_value = transfer(int(z'0079000000000000', int64), 0.0_real64)
    status = 2
    if (maximum_degree < 1 .or. maximum_degree > 8191) return
    if (levels < 0 .or. levels > 512) return
    if (size(waves) > maximum_degree + 1) return
    if (ubound(first_column, 1) < maximum_degree) return
    if (kinetic) then
      if (ubound(inverse_laplacian, 1) < maximum_degree) return
    end if
    if (size(field, 1) < levels .or. size(result, 1) < levels .or. size(result, 2) < size(waves)) return
    do j = 1, size(waves)
      m = waves(j)
      if (m < 0 .or. m > maximum_degree) return
      column = first_column(m)
      if (column < 1) return
      if (2_int64*(maximum_degree - m + 1) > int(size(field, 2), int64) - int(column, int64) + 1_int64) return
    end do
    do j = 1, size(waves)
      m = waves(j)
      do level = 1, levels
        total = 0.0_real64
        column = first_column(m)
        do degree = m, maximum_degree
          real_square = field(level, column)*field(level, column)
          coefficient = real_square
          if (m /= 0) then
            imaginary_square = field(level, column + 1)*field(level, column + 1)
            coefficient = real_square + imaginary_square
          end if
          metric = 1.0_real64
          if (kinetic) metric = -inverse_laplacian(degree)
          if (m /= 0) metric = 2.0_real64*metric
          product = metric*coefficient
          total = total + product
          column = column + 2
        end do
        ! The source FMAXNM selects its numeric floor when the sum is a NaN.
        if (ieee_is_nan(total)) then
          result(level, j) = floor_value
        else
          result(level, j) = max(floor_value, total)
        end if
      end do
    end do
    status = 0
  end subroutine

  !> Ordinary SPNORMB entry with the same native array contract.
  subroutine scalar_spectral_norm_matrix(maximum_degree, waves, first_column, field, levels, result, status)
    integer(int32), intent(in) :: maximum_degree, waves(:), first_column(0:), levels
    real(real64), intent(in) :: field(:, :)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    real(real64) :: unused_inverse(0:0)
    call spectral_norm_matrix(maximum_degree, waves, first_column, unused_inverse, field, .false., levels, result, status)
  end subroutine

  !> Kinetic SPNORMBE entry; RLAPIN is consumed with its source sign.
  subroutine kinetic_spectral_norm_matrix(maximum_degree, waves, first_column, inverse_laplacian, &
                                          field, levels, result, status)
    integer(int32), intent(in) :: maximum_degree, waves(:), first_column(0:), levels
    real(real64), intent(in) :: inverse_laplacian(0:), field(:, :)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    call spectral_norm_matrix(maximum_degree, waves, first_column, inverse_laplacian, field, .true., levels, result, status)
  end subroutine

  !> Sum waves,then levels,in the original SPNORMAVE order.
  !!
  !! matrix(level,wave) contains complete global wave columns in ascending m.
  !! levels1:512 and wave_count1:8192 select its active prefix. For ordinary
  !! norms,square root follows each wave sum. Energy retains the wave sum.
  !! per_level and mean have the resulting field units;only their active values
  !! change. Each addition,square root and final division rounds separately.
  !! Status2 preserves both outputs on invalid shape;status0 publishes values.
  subroutine spectral_norm_average(matrix, levels, kinetic, wave_count, per_level, mean, status)
    real(real64), intent(in) :: matrix(:, :)
    integer(int32), intent(in) :: levels, wave_count
    logical, intent(in) :: kinetic
    real(real64), intent(inout) :: per_level(:), mean
    integer(int32), intent(out) :: status
    integer :: level, wave
    real(real64) :: total, value, total_levels
    status = 2
    if (levels < 1 .or. levels > 512 .or. wave_count < 1 .or. wave_count > 8192) return
    if (size(matrix, 1) < levels .or. size(matrix, 2) < wave_count .or. size(per_level) < levels) return
    total_levels = 0.0_real64
    do level = 1, levels
      total = 0.0_real64
      do wave = 1, wave_count
        value = matrix(level, wave)
        total = total + value
      end do
      if (.not. kinetic) total = sqrt(total)
      per_level(level) = total
      total_levels = total_levels + total
    end do
    mean = total_levels/real(levels, real64)
    status = 0
  end subroutine

  !> Retain the selected T21 child domain while sharing its exact arithmetic.
  subroutine selected_spectral_norm_matrix(waves, first_column, inverse_laplacian, field, &
                                           kinetic, levels, result, status)
    integer(int32), intent(in) :: waves(:), first_column(0:), levels
    real(real64), intent(in) :: inverse_laplacian(0:), field(:, :)
    logical, intent(in) :: kinetic
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    integer :: j
    status = 2
    if (size(waves) /= 22 .or. levels < 0 .or. levels > 19) return
    do j = 1, 22
      if (waves(j) /= j - 1) return
    end do
    call spectral_norm_matrix(21_int32, waves, first_column, inverse_laplacian, field, kinetic, levels, result, status)
  end subroutine

  subroutine selected_spectral_norm_average(matrix, levels, kinetic, per_level, mean, status)
    real(real64), intent(in) :: matrix(:, :)
    integer(int32), intent(in) :: levels
    logical, intent(in) :: kinetic
    real(real64), intent(inout) :: per_level(:), mean
    integer(int32), intent(out) :: status
    status = 2
    if (levels < 1 .or. levels > 19) return
    call spectral_norm_average(matrix, levels, kinetic, 22_int32, per_level, mean, status)
  end subroutine

  !> Retain the four-process T1279 child's640 local waves and live level view.
  subroutine operational_spectral_norm_matrix(waves, first_column, inverse_laplacian, field, &
                                              kinetic, levels, result, status)
    integer(int32), intent(in) :: waves(:), first_column(0:), levels
    real(real64), intent(in) :: inverse_laplacian(0:), field(:, :)
    logical, intent(in) :: kinetic
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    status = 2
    if (size(waves) /= 640 .or. levels < 0 .or. levels > 137) return
    call spectral_norm_matrix(1279_int32, waves, first_column, inverse_laplacian, field, kinetic, levels, result, status)
  end subroutine

  subroutine operational_spectral_norm_average(matrix, levels, kinetic, per_level, mean, status)
    real(real64), intent(in) :: matrix(:, :)
    integer(int32), intent(in) :: levels
    logical, intent(in) :: kinetic
    real(real64), intent(inout) :: per_level(:), mean
    integer(int32), intent(out) :: status
    status = 2
    if (levels < 1 .or. levels > 137) return
    call spectral_norm_average(matrix, levels, kinetic, 1280_int32, per_level, mean, status)
  end subroutine
end module forecast_ordered_spectral_norm_arithmetic
