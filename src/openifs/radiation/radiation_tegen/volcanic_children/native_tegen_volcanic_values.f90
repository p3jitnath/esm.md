!> Native source volcanic aerosol optical thickness, a dimensionless quantity.
!! The caller owns the complete arrays and the scalar security threshold.
!! Source year/month assignments stay unscaled until the final runtime loop.
module native_tegen_volcanic_values
  use iso_c_binding, only: c_double, c_int
  implicit none
  private
  public :: initialize_tegen_volcanic_values
  real(c_double), parameter :: source_latitudes(24) = [ &
                               90.0_c_double, 82.2_c_double, 74.3_c_double, 66.5_c_double, 58.7_c_double, 50.9_c_double, &
                               43.0_c_double, 35.2_c_double, 27.4_c_double, 19.6_c_double, 11.7_c_double, 3.9_c_double, &
                               -3.9_c_double, -11.7_c_double, -19.6_c_double, -27.4_c_double, -35.2_c_double, -43.0_c_double, &
                               -50.9_c_double, -58.7_c_double, -66.5_c_double, -74.3_c_double, -82.2_c_double, -90.0_c_double]
  real(c_double), parameter :: source_scale = 1.0e-4_c_double
  real(c_double), parameter :: source_security = 1.0e-12_c_double
contains
  !> Initialise the source table, latitude coordinates and security threshold.
  !! volcanic has shape (24,251,12), intent(inout), with native second-index
  !! bounds 1850:2100. Its optical thickness values are dimensionless.
  !! latitudes has shape (24), intent(inout), in degrees from north to south.
  !! security is real(c_double), intent(inout), and dimensionless.
  !! The caller owns disjoint arrays and selects nearest rounding with gradual
  !! underflow through the accepted outer floating-point-control check.
  !! Return 2 rejects unsupported shapes before mutation; return 0 completes
  !! all source stores and scaling. No original numerical routine is called.
  integer(c_int) function initialize_tegen_volcanic_values(volcanic, latitudes, security) result(status)
    real(c_double), contiguous, intent(inout) :: volcanic(:, 1850:, :), latitudes(:)
    real(c_double), intent(inout) :: security
    integer :: latitude, year, month
    status = 2_c_int
    if (size(volcanic, 1) /= 24 .or. size(volcanic, 2) /= 251 .or. size(volcanic, 3) /= 12) return
    if (size(latitudes) /= 24) return

    ! Write positive zero throughout the complete native owner in stored order.
    do month = 1, size(volcanic, 3)
      do year = lbound(volcanic, 2), ubound(volcanic, 2)
        do latitude = 1, size(volcanic, 1)
          volcanic(latitude, year, month) = 0.0_c_double
        end do
      end do
    end do
    latitudes = source_latitudes

    ! Apply all unscaled 24-word source stores in the retained PART1:PART7 order.
    volcanic(:, 1957, 1) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 2) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 3) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 4) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 5) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 6) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1957, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 1) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 2) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 3) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 4) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 5) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 6) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1958, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 1) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 2) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 3) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 4) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 5) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 6) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1959, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1960, 1) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1960, 2) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1960, 3) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1960, 4) = [ &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double]
    volcanic(:, 1960, 5) = [ &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double]
    volcanic(:, 1960, 6) = [ &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double]
    volcanic(:, 1960, 7) = [ &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double]
    volcanic(:, 1960, 8) = [ &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double]
    volcanic(:, 1960, 9) = [ &
                           100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                           100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                           100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                           100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double]
    volcanic(:, 1960, 10) = [ &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double]
    volcanic(:, 1960, 11) = [ &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double]
    volcanic(:, 1960, 12) = [ &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double]
    volcanic(:, 1961, 1) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 2) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 40.0_c_double, 1.0_c_double, 1.0_c_double, &
                           20.0_c_double, 1.0_c_double, 72.0_c_double, 190.0_c_double, 190.0_c_double, 101.0_c_double, &
                           30.0_c_double, 48.0_c_double, 69.0_c_double, 90.0_c_double, 110.0_c_double, 94.0_c_double, &
                           78.0_c_double, 63.0_c_double, 47.0_c_double, 31.0_c_double, 16.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 3) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 50.0_c_double, 1.0_c_double, 1.0_c_double, &
                           10.0_c_double, 1.0_c_double, 145.0_c_double, 380.0_c_double, 380.0_c_double, 230.0_c_double, &
                           110.0_c_double, 85.0_c_double, 57.0_c_double, 28.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 4) = [ &
                           60.0_c_double, 60.0_c_double, 60.0_c_double, 50.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 175.0_c_double, 460.0_c_double, 460.0_c_double, 272.0_c_double, &
                           120.0_c_double, 93.0_c_double, 62.0_c_double, 30.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 5) = [ &
                           80.0_c_double, 80.0_c_double, 80.0_c_double, 40.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 110.0_c_double, 290.0_c_double, 290.0_c_double, 129.0_c_double, &
                           1.0_c_double, 18.0_c_double, 39.0_c_double, 60.0_c_double, 80.0_c_double, 68.0_c_double, &
                           57.0_c_double, 46.0_c_double, 34.0_c_double, 23.0_c_double, 11.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 6) = [ &
                           90.0_c_double, 90.0_c_double, 90.0_c_double, 10.0_c_double, 50.0_c_double, 50.0_c_double, &
                           1.0_c_double, 1.0_c_double, 61.0_c_double, 160.0_c_double, 160.0_c_double, 71.0_c_double, &
                           1.0_c_double, 25.0_c_double, 53.0_c_double, 82.0_c_double, 110.0_c_double, 94.0_c_double, &
                           78.0_c_double, 63.0_c_double, 47.0_c_double, 31.0_c_double, 16.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 7) = [ &
                           70.0_c_double, 70.0_c_double, 70.0_c_double, 1.0_c_double, 70.0_c_double, 70.0_c_double, &
                           1.0_c_double, 10.0_c_double, 52.0_c_double, 120.0_c_double, 120.0_c_double, 70.0_c_double, &
                           30.0_c_double, 23.0_c_double, 15.0_c_double, 8.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 8) = [ &
                           40.0_c_double, 40.0_c_double, 40.0_c_double, 1.0_c_double, 60.0_c_double, 60.0_c_double, &
                           1.0_c_double, 80.0_c_double, 95.0_c_double, 120.0_c_double, 120.0_c_double, 153.0_c_double, &
                           180.0_c_double, 142.0_c_double, 97.0_c_double, 53.0_c_double, 10.0_c_double, 9.0_c_double, &
                           7.0_c_double, 6.0_c_double, 4.0_c_double, 3.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 40.0_c_double, 40.0_c_double, &
                           1.0_c_double, 60.0_c_double, 83.0_c_double, 120.0_c_double, 120.0_c_double, 214.0_c_double, &
                           290.0_c_double, 236.0_c_double, 173.0_c_double, 111.0_c_double, 50.0_c_double, 43.0_c_double, &
                           36.0_c_double, 28.0_c_double, 21.0_c_double, 14.0_c_double, 7.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 20.0_c_double, 20.0_c_double, &
                            1.0_c_double, 1.0_c_double, 38.0_c_double, 100.0_c_double, 100.0_c_double, 228.0_c_double, &
                            330.0_c_double, 258.0_c_double, 175.0_c_double, 91.0_c_double, 10.0_c_double, 9.0_c_double, &
                            7.0_c_double, 6.0_c_double, 4.0_c_double, 3.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                            80.0_c_double, 1.0_c_double, 4.0_c_double, 10.0_c_double, 10.0_c_double, 193.0_c_double, &
                            340.0_c_double, 264.0_c_double, 175.0_c_double, 86.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1961, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                            80.0_c_double, 1.0_c_double, 8.0_c_double, 20.0_c_double, 20.0_c_double, 164.0_c_double, &
                            280.0_c_double, 217.0_c_double, 144.0_c_double, 71.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 1) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 10.0_c_double, 20.0_c_double, 20.0_c_double, &
                           1.0_c_double, 1.0_c_double, 53.0_c_double, 140.0_c_double, 140.0_c_double, 112.0_c_double, &
                           90.0_c_double, 70.0_c_double, 46.0_c_double, 23.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 2) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 50.0_c_double, 50.0_c_double, &
                           1.0_c_double, 1.0_c_double, 61.0_c_double, 160.0_c_double, 160.0_c_double, 116.0_c_double, &
                           80.0_c_double, 78.0_c_double, 75.0_c_double, 73.0_c_double, 70.0_c_double, 60.0_c_double, &
                           50.0_c_double, 40.0_c_double, 30.0_c_double, 20.0_c_double, 10.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 3) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 70.0_c_double, 70.0_c_double, &
                           1.0_c_double, 1.0_c_double, 11.0_c_double, 30.0_c_double, 30.0_c_double, 152.0_c_double, &
                           250.0_c_double, 259.0_c_double, 269.0_c_double, 280.0_c_double, 290.0_c_double, 248.0_c_double, &
                           206.0_c_double, 165.0_c_double, 124.0_c_double, 83.0_c_double, 41.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 4) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 60.0_c_double, 60.0_c_double, &
                           50.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 216.0_c_double, &
                           390.0_c_double, 363.0_c_double, 332.0_c_double, 300.0_c_double, 270.0_c_double, 231.0_c_double, &
                           192.0_c_double, 154.0_c_double, 115.0_c_double, 77.0_c_double, 38.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 5) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 40.0_c_double, 40.0_c_double, &
                           100.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 28.0_c_double, &
                           50.0_c_double, 46.0_c_double, 40.0_c_double, 35.0_c_double, 30.0_c_double, 26.0_c_double, &
                           21.0_c_double, 17.0_c_double, 13.0_c_double, 9.0_c_double, 4.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 6) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           150.0_c_double, 1.0_c_double, 19.0_c_double, 50.0_c_double, 50.0_c_double, 33.0_c_double, &
                           20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 17.0_c_double, &
                           14.0_c_double, 11.0_c_double, 9.0_c_double, 6.0_c_double, 3.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 20.0_c_double, 1.0_c_double, 1.0_c_double, &
                           160.0_c_double, 1.0_c_double, 46.0_c_double, 120.0_c_double, 120.0_c_double, 270.0_c_double, &
                           390.0_c_double, 311.0_c_double, 220.0_c_double, 129.0_c_double, 40.0_c_double, 34.0_c_double, &
                           28.0_c_double, 23.0_c_double, 17.0_c_double, 11.0_c_double, 6.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 20.0_c_double, 1.0_c_double, 1.0_c_double, &
                           140.0_c_double, 1.0_c_double, 57.0_c_double, 150.0_c_double, 150.0_c_double, 405.0_c_double, &
                           610.0_c_double, 473.0_c_double, 314.0_c_double, 155.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 9) = [ &
                           30.0_c_double, 30.0_c_double, 30.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           80.0_c_double, 10.0_c_double, 44.0_c_double, 100.0_c_double, 100.0_c_double, 189.0_c_double, &
                           260.0_c_double, 202.0_c_double, 134.0_c_double, 66.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 10) = [ &
                            80.0_c_double, 80.0_c_double, 80.0_c_double, 10.0_c_double, 20.0_c_double, 20.0_c_double, &
                            10.0_c_double, 120.0_c_double, 78.0_c_double, 10.0_c_double, 10.0_c_double, 110.0_c_double, &
                            190.0_c_double, 147.0_c_double, 98.0_c_double, 48.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 11) = [ &
                            130.0_c_double, 130.0_c_double, 130.0_c_double, 50.0_c_double, 20.0_c_double, 20.0_c_double, &
                            1.0_c_double, 50.0_c_double, 39.0_c_double, 20.0_c_double, 20.0_c_double, 142.0_c_double, &
                            240.0_c_double, 186.0_c_double, 123.0_c_double, 61.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1962, 12) = [ &
                            180.0_c_double, 180.0_c_double, 180.0_c_double, 60.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 19.0_c_double, 50.0_c_double, 50.0_c_double, 122.0_c_double, &
                            180.0_c_double, 140.0_c_double, 93.0_c_double, 46.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 1) = [ &
                           230.0_c_double, 230.0_c_double, 230.0_c_double, 10.0_c_double, 1.0_c_double, 1.0_c_double, &
                           100.0_c_double, 1.0_c_double, 53.0_c_double, 140.0_c_double, 140.0_c_double, 62.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 2) = [ &
                           280.0_c_double, 280.0_c_double, 280.0_c_double, 70.0_c_double, 1.0_c_double, 1.0_c_double, &
                           130.0_c_double, 1.0_c_double, 61.0_c_double, 160.0_c_double, 160.0_c_double, 71.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 3) = [ &
                           290.0_c_double, 290.0_c_double, 290.0_c_double, 150.0_c_double, 1.0_c_double, 1.0_c_double, &
                           50.0_c_double, 150.0_c_double, 154.0_c_double, 160.0_c_double, 160.0_c_double, 71.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 4) = [ &
                           230.0_c_double, 230.0_c_double, 230.0_c_double, 150.0_c_double, 20.0_c_double, 20.0_c_double, &
                           70.0_c_double, 90.0_c_double, 113.0_c_double, 150.0_c_double, 150.0_c_double, 294.0_c_double, &
                           410.0_c_double, 379.0_c_double, 342.0_c_double, 306.0_c_double, 270.0_c_double, 231.0_c_double, &
                           192.0_c_double, 154.0_c_double, 115.0_c_double, 77.0_c_double, 38.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 5) = [ &
                           80.0_c_double, 80.0_c_double, 80.0_c_double, 100.0_c_double, 40.0_c_double, 40.0_c_double, &
                           130.0_c_double, 1.0_c_double, 53.0_c_double, 140.0_c_double, 140.0_c_double, 578.0_c_double, &
                           930.0_c_double, 874.0_c_double, 809.0_c_double, 743.0_c_double, 680.0_c_double, 581.0_c_double, &
                           484.0_c_double, 387.0_c_double, 290.0_c_double, 194.0_c_double, 97.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 6) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 20.0_c_double, 1.0_c_double, 1.0_c_double, &
                           120.0_c_double, 1.0_c_double, 76.0_c_double, 200.0_c_double, 200.0_c_double, 621.0_c_double, &
                           960.0_c_double, 1025.0_c_double, 1101.0_c_double, 1176.0_c_double, 1250.0_c_double, 1067.0_c_double, &
                           889.0_c_double, 711.0_c_double, 534.0_c_double, 356.0_c_double, 178.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           50.0_c_double, 140.0_c_double, 208.0_c_double, 320.0_c_double, 320.0_c_double, 608.0_c_double, &
                           840.0_c_double, 975.0_c_double, 1131.0_c_double, 1288.0_c_double, 1440.0_c_double, 1229.0_c_double, &
                           1025.0_c_double, 820.0_c_double, 615.0_c_double, 410.0_c_double, 205.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           50.0_c_double, 280.0_c_double, 333.0_c_double, 420.0_c_double, 420.0_c_double, 608.0_c_double, &
                           760.0_c_double, 946.0_c_double, 1163.0_c_double, 1379.0_c_double, 1590.0_c_double, 1357.0_c_double, &
                           1131.0_c_double, 905.0_c_double, 679.0_c_double, 452.0_c_double, 226.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 9) = [ &
                           30.0_c_double, 30.0_c_double, 30.0_c_double, 1.0_c_double, 20.0_c_double, 20.0_c_double, &
                           60.0_c_double, 200.0_c_double, 299.0_c_double, 460.0_c_double, 460.0_c_double, 698.0_c_double, &
                           890.0_c_double, 1072.0_c_double, 1283.0_c_double, 1495.0_c_double, 1700.0_c_double, 1451.0_c_double, &
                           1209.0_c_double, 968.0_c_double, 726.0_c_double, 484.0_c_double, 242.0_c_double, 1.0_c_double]
    volcanic(:, 1963, 10) = [ &
                            90.0_c_double, 90.0_c_double, 90.0_c_double, 10.0_c_double, 90.0_c_double, 90.0_c_double, &
                            120.0_c_double, 180.0_c_double, 271.0_c_double, 420.0_c_double, 420.0_c_double, 1135.0_c_double, &
                            1710.0_c_double, 1714.0_c_double, 1720.0_c_double, 1725.0_c_double, 1730.0_c_double, 1524.0_c_double, &
                            1323.0_c_double, 1123.0_c_double, 922.0_c_double, 721.0_c_double, 521.0_c_double, 320.0_c_double]
    volcanic(:, 1963, 11) = [ &
                            160.0_c_double, 160.0_c_double, 160.0_c_double, 110.0_c_double, 150.0_c_double, 150.0_c_double, &
                            210.0_c_double, 420.0_c_double, 352.0_c_double, 240.0_c_double, 240.0_c_double, 1360.0_c_double, &
                            2260.0_c_double, 2116.0_c_double, 1949.0_c_double, 1782.0_c_double, 1620.0_c_double, 1560.0_c_double, &
                            1502.0_c_double, 1443.0_c_double, 1385.0_c_double, 1327.0_c_double, 1268.0_c_double, 1210.0_c_double]
    volcanic(:, 1963, 12) = [ &
                            220.0_c_double, 220.0_c_double, 220.0_c_double, 180.0_c_double, 210.0_c_double, 210.0_c_double, &
                            330.0_c_double, 490.0_c_double, 364.0_c_double, 160.0_c_double, 160.0_c_double, 1180.0_c_double, &
                            2000.0_c_double, 1823.0_c_double, 1616.0_c_double, 1410.0_c_double, 1210.0_c_double, 1264.0_c_double, &
                            1317.0_c_double, 1369.0_c_double, 1422.0_c_double, 1475.0_c_double, 1527.0_c_double, 1580.0_c_double]
    volcanic(:, 1964, 1) = [ &
                           280.0_c_double, 280.0_c_double, 280.0_c_double, 230.0_c_double, 320.0_c_double, 320.0_c_double, &
                           370.0_c_double, 460.0_c_double, 346.0_c_double, 160.0_c_double, 160.0_c_double, 753.0_c_double, &
                           1230.0_c_double, 1154.0_c_double, 1065.0_c_double, 976.0_c_double, 890.0_c_double, 985.0_c_double, &
                           1078.0_c_double, 1170.0_c_double, 1263.0_c_double, 1355.0_c_double, 1448.0_c_double, 1540.0_c_double]
    volcanic(:, 1964, 2) = [ &
                           340.0_c_double, 340.0_c_double, 340.0_c_double, 300.0_c_double, 390.0_c_double, 390.0_c_double, &
                           350.0_c_double, 370.0_c_double, 317.0_c_double, 230.0_c_double, 230.0_c_double, 707.0_c_double, &
                           1090.0_c_double, 1029.0_c_double, 959.0_c_double, 888.0_c_double, 820.0_c_double, 911.0_c_double, &
                           999.0_c_double, 1087.0_c_double, 1175.0_c_double, 1264.0_c_double, 1352.0_c_double, 1440.0_c_double]
    volcanic(:, 1964, 3) = [ &
                           390.0_c_double, 390.0_c_double, 390.0_c_double, 360.0_c_double, 380.0_c_double, 380.0_c_double, &
                           290.0_c_double, 240.0_c_double, 270.0_c_double, 320.0_c_double, 320.0_c_double, 808.0_c_double, &
                           1200.0_c_double, 1106.0_c_double, 996.0_c_double, 887.0_c_double, 780.0_c_double, 859.0_c_double, &
                           936.0_c_double, 1013.0_c_double, 1089.0_c_double, 1166.0_c_double, 1243.0_c_double, 1320.0_c_double]
    volcanic(:, 1964, 4) = [ &
                           430.0_c_double, 430.0_c_double, 430.0_c_double, 390.0_c_double, 310.0_c_double, 310.0_c_double, &
                           190.0_c_double, 150.0_c_double, 245.0_c_double, 400.0_c_double, 400.0_c_double, 1049.0_c_double, &
                           1570.0_c_double, 1379.0_c_double, 1157.0_c_double, 936.0_c_double, 720.0_c_double, 792.0_c_double, &
                           861.0_c_double, 931.0_c_double, 1001.0_c_double, 1071.0_c_double, 1140.0_c_double, 1210.0_c_double]
    volcanic(:, 1964, 5) = [ &
                           450.0_c_double, 450.0_c_double, 450.0_c_double, 270.0_c_double, 1.0_c_double, 1.0_c_double, &
                           100.0_c_double, 90.0_c_double, 223.0_c_double, 440.0_c_double, 440.0_c_double, 1188.0_c_double, &
                           1790.0_c_double, 1534.0_c_double, 1237.0_c_double, 939.0_c_double, 650.0_c_double, 716.0_c_double, &
                           780.0_c_double, 844.0_c_double, 908.0_c_double, 972.0_c_double, 1036.0_c_double, 1100.0_c_double]
    volcanic(:, 1964, 6) = [ &
                           430.0_c_double, 430.0_c_double, 430.0_c_double, 220.0_c_double, 1.0_c_double, 1.0_c_double, &
                           30.0_c_double, 90.0_c_double, 231.0_c_double, 460.0_c_double, 460.0_c_double, 1397.0_c_double, &
                           2150.0_c_double, 1827.0_c_double, 1451.0_c_double, 1075.0_c_double, 710.0_c_double, 752.0_c_double, &
                           794.0_c_double, 835.0_c_double, 876.0_c_double, 917.0_c_double, 959.0_c_double, 1000.0_c_double]
    volcanic(:, 1964, 7) = [ &
                           400.0_c_double, 400.0_c_double, 400.0_c_double, 250.0_c_double, 30.0_c_double, 30.0_c_double, &
                           10.0_c_double, 170.0_c_double, 277.0_c_double, 450.0_c_double, 450.0_c_double, 1697.0_c_double, &
                           2700.0_c_double, 2296.0_c_double, 1826.0_c_double, 1357.0_c_double, 900.0_c_double, 899.0_c_double, &
                           897.0_c_double, 896.0_c_double, 894.0_c_double, 893.0_c_double, 891.0_c_double, 890.0_c_double]
    volcanic(:, 1964, 8) = [ &
                           320.0_c_double, 320.0_c_double, 320.0_c_double, 290.0_c_double, 90.0_c_double, 90.0_c_double, &
                           10.0_c_double, 240.0_c_double, 308.0_c_double, 420.0_c_double, 420.0_c_double, 1734.0_c_double, &
                           2790.0_c_double, 2363.0_c_double, 1868.0_c_double, 1372.0_c_double, 890.0_c_double, 875.0_c_double, &
                           861.0_c_double, 847.0_c_double, 833.0_c_double, 818.0_c_double, 804.0_c_double, 790.0_c_double]
    volcanic(:, 1964, 9) = [ &
                           220.0_c_double, 220.0_c_double, 220.0_c_double, 360.0_c_double, 160.0_c_double, 160.0_c_double, &
                           20.0_c_double, 320.0_c_double, 343.0_c_double, 380.0_c_double, 380.0_c_double, 1455.0_c_double, &
                           2320.0_c_double, 1938.0_c_double, 1495.0_c_double, 1051.0_c_double, 620.0_c_double, 629.0_c_double, &
                           637.0_c_double, 646.0_c_double, 654.0_c_double, 663.0_c_double, 671.0_c_double, 680.0_c_double]
    volcanic(:, 1964, 10) = [ &
                            120.0_c_double, 120.0_c_double, 120.0_c_double, 330.0_c_double, 230.0_c_double, 230.0_c_double, &
                            100.0_c_double, 430.0_c_double, 384.0_c_double, 310.0_c_double, 310.0_c_double, 1053.0_c_double, &
                            1650.0_c_double, 1356.0_c_double, 1014.0_c_double, 672.0_c_double, 340.0_c_double, 396.0_c_double, &
                            450.0_c_double, 504.0_c_double, 558.0_c_double, 612.0_c_double, 666.0_c_double, 720.0_c_double]
    volcanic(:, 1964, 11) = [ &
                            80.0_c_double, 80.0_c_double, 80.0_c_double, 260.0_c_double, 320.0_c_double, 320.0_c_double, &
                            230.0_c_double, 520.0_c_double, 417.0_c_double, 250.0_c_double, 250.0_c_double, 727.0_c_double, &
                            1110.0_c_double, 903.0_c_double, 663.0_c_double, 423.0_c_double, 190.0_c_double, 292.0_c_double, &
                            392.0_c_double, 492.0_c_double, 591.0_c_double, 691.0_c_double, 790.0_c_double, 890.0_c_double]
    volcanic(:, 1964, 12) = [ &
                            130.0_c_double, 130.0_c_double, 130.0_c_double, 250.0_c_double, 410.0_c_double, 410.0_c_double, &
                            430.0_c_double, 530.0_c_double, 397.0_c_double, 180.0_c_double, 180.0_c_double, 457.0_c_double, &
                            680.0_c_double, 561.0_c_double, 423.0_c_double, 284.0_c_double, 150.0_c_double, 273.0_c_double, &
                            392.0_c_double, 512.0_c_double, 631.0_c_double, 751.0_c_double, 870.0_c_double, 990.0_c_double]
    volcanic(:, 1965, 1) = [ &
                           320.0_c_double, 320.0_c_double, 320.0_c_double, 290.0_c_double, 490.0_c_double, 490.0_c_double, &
                           490.0_c_double, 490.0_c_double, 361.0_c_double, 150.0_c_double, 150.0_c_double, 167.0_c_double, &
                           180.0_c_double, 178.0_c_double, 175.0_c_double, 173.0_c_double, 170.0_c_double, 288.0_c_double, &
                           404.0_c_double, 519.0_c_double, 634.0_c_double, 749.0_c_double, 865.0_c_double, 980.0_c_double]
    volcanic(:, 1965, 2) = [ &
                           570.0_c_double, 570.0_c_double, 570.0_c_double, 430.0_c_double, 500.0_c_double, 500.0_c_double, &
                           450.0_c_double, 420.0_c_double, 317.0_c_double, 150.0_c_double, 150.0_c_double, 67.0_c_double, &
                           1.0_c_double, 49.0_c_double, 107.0_c_double, 164.0_c_double, 220.0_c_double, 314.0_c_double, &
                           405.0_c_double, 496.0_c_double, 587.0_c_double, 678.0_c_double, 769.0_c_double, 860.0_c_double]
    volcanic(:, 1965, 3) = [ &
                           660.0_c_double, 660.0_c_double, 660.0_c_double, 640.0_c_double, 460.0_c_double, 460.0_c_double, &
                           290.0_c_double, 390.0_c_double, 299.0_c_double, 150.0_c_double, 150.0_c_double, 67.0_c_double, &
                           1.0_c_double, 56.0_c_double, 121.0_c_double, 187.0_c_double, 250.0_c_double, 316.0_c_double, &
                           380.0_c_double, 444.0_c_double, 508.0_c_double, 572.0_c_double, 636.0_c_double, 700.0_c_double]
    volcanic(:, 1965, 4) = [ &
                           600.0_c_double, 600.0_c_double, 600.0_c_double, 660.0_c_double, 400.0_c_double, 400.0_c_double, &
                           200.0_c_double, 330.0_c_double, 296.0_c_double, 240.0_c_double, 240.0_c_double, 107.0_c_double, &
                           1.0_c_double, 72.0_c_double, 155.0_c_double, 239.0_c_double, 320.0_c_double, 351.0_c_double, &
                           381.0_c_double, 410.0_c_double, 440.0_c_double, 470.0_c_double, 500.0_c_double, 530.0_c_double]
    volcanic(:, 1965, 5) = [ &
                           520.0_c_double, 520.0_c_double, 520.0_c_double, 630.0_c_double, 270.0_c_double, 270.0_c_double, &
                           170.0_c_double, 190.0_c_double, 239.0_c_double, 320.0_c_double, 320.0_c_double, 143.0_c_double, &
                           1.0_c_double, 90.0_c_double, 194.0_c_double, 299.0_c_double, 400.0_c_double, 400.0_c_double, &
                           400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double]
    volcanic(:, 1965, 6) = [ &
                           470.0_c_double, 470.0_c_double, 470.0_c_double, 550.0_c_double, 250.0_c_double, 250.0_c_double, &
                           60.0_c_double, 20.0_c_double, 146.0_c_double, 350.0_c_double, 350.0_c_double, 156.0_c_double, &
                           1.0_c_double, 90.0_c_double, 194.0_c_double, 299.0_c_double, 400.0_c_double, 380.0_c_double, &
                           360.0_c_double, 340.0_c_double, 320.0_c_double, 300.0_c_double, 280.0_c_double, 260.0_c_double]
    volcanic(:, 1965, 7) = [ &
                           400.0_c_double, 400.0_c_double, 400.0_c_double, 490.0_c_double, 260.0_c_double, 260.0_c_double, &
                           1.0_c_double, 170.0_c_double, 242.0_c_double, 360.0_c_double, 360.0_c_double, 388.0_c_double, &
                           410.0_c_double, 379.0_c_double, 342.0_c_double, 306.0_c_double, 270.0_c_double, 255.0_c_double, &
                           241.0_c_double, 227.0_c_double, 213.0_c_double, 198.0_c_double, 184.0_c_double, 170.0_c_double]
    volcanic(:, 1965, 8) = [ &
                           300.0_c_double, 300.0_c_double, 300.0_c_double, 420.0_c_double, 280.0_c_double, 280.0_c_double, &
                           1.0_c_double, 210.0_c_double, 240.0_c_double, 290.0_c_double, 290.0_c_double, 440.0_c_double, &
                           560.0_c_double, 459.0_c_double, 342.0_c_double, 224.0_c_double, 110.0_c_double, 113.0_c_double, &
                           116.0_c_double, 119.0_c_double, 121.0_c_double, 124.0_c_double, 127.0_c_double, 130.0_c_double]
    volcanic(:, 1965, 9) = [ &
                           200.0_c_double, 200.0_c_double, 200.0_c_double, 340.0_c_double, 290.0_c_double, 290.0_c_double, &
                           30.0_c_double, 240.0_c_double, 248.0_c_double, 260.0_c_double, 260.0_c_double, 399.0_c_double, &
                           510.0_c_double, 411.0_c_double, 296.0_c_double, 182.0_c_double, 70.0_c_double, 80.0_c_double, &
                           90.0_c_double, 100.0_c_double, 110.0_c_double, 120.0_c_double, 130.0_c_double, 140.0_c_double]
    volcanic(:, 1965, 10) = [ &
                            100.0_c_double, 100.0_c_double, 100.0_c_double, 250.0_c_double, 290.0_c_double, 290.0_c_double, &
                            220.0_c_double, 270.0_c_double, 262.0_c_double, 250.0_c_double, 250.0_c_double, 355.0_c_double, &
                            440.0_c_double, 368.0_c_double, 285.0_c_double, 201.0_c_double, 120.0_c_double, 130.0_c_double, &
                            140.0_c_double, 150.0_c_double, 160.0_c_double, 170.0_c_double, 180.0_c_double, 190.0_c_double]
    volcanic(:, 1965, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 180.0_c_double, 280.0_c_double, 280.0_c_double, &
                            300.0_c_double, 290.0_c_double, 275.0_c_double, 250.0_c_double, 250.0_c_double, 305.0_c_double, &
                            350.0_c_double, 339.0_c_double, 326.0_c_double, 313.0_c_double, 300.0_c_double, 287.0_c_double, &
                            274.0_c_double, 261.0_c_double, 248.0_c_double, 236.0_c_double, 223.0_c_double, 210.0_c_double]
    volcanic(:, 1965, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 110.0_c_double, 270.0_c_double, 270.0_c_double, &
                            350.0_c_double, 300.0_c_double, 296.0_c_double, 290.0_c_double, 290.0_c_double, 296.0_c_double, &
                            300.0_c_double, 338.0_c_double, 383.0_c_double, 427.0_c_double, 470.0_c_double, 417.0_c_double, &
                            366.0_c_double, 315.0_c_double, 264.0_c_double, 212.0_c_double, 161.0_c_double, 110.0_c_double]
    volcanic(:, 1966, 1) = [ &
                           335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, &
                           335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, &
                           335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, &
                           335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double, 335.0_c_double]
    volcanic(:, 1966, 2) = [ &
                           320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, &
                           320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, &
                           320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, &
                           320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double, 320.0_c_double]
    volcanic(:, 1966, 3) = [ &
                           305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, &
                           305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, &
                           305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, &
                           305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double, 305.0_c_double]
    volcanic(:, 1966, 4) = [ &
                           290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, &
                           290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, &
                           290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, &
                           290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double]
    volcanic(:, 1966, 5) = [ &
                           275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, &
                           275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, &
                           275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, &
                           275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double, 275.0_c_double]
    volcanic(:, 1966, 6) = [ &
                           260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, &
                           260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, &
                           260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, &
                           260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double, 260.0_c_double]
    volcanic(:, 1966, 7) = [ &
                           245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, &
                           245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, &
                           245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, &
                           245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double, 245.0_c_double]
    volcanic(:, 1966, 8) = [ &
                           230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, &
                           230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, &
                           230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, &
                           230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double]
    volcanic(:, 1966, 9) = [ &
                           215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, &
                           215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, &
                           215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, &
                           215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double, 215.0_c_double]
    volcanic(:, 1966, 10) = [ &
                            200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, &
                            200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, &
                            200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, &
                            200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double, 200.0_c_double]
    volcanic(:, 1966, 11) = [ &
                            185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, &
                            185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, &
                            185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, &
                            185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double]
    volcanic(:, 1966, 12) = [ &
                            170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                            170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                            170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                            170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double]
    volcanic(:, 1967, 1) = [ &
                           155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, &
                           155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, &
                           155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, &
                           155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double]
    volcanic(:, 1967, 2) = [ &
                           140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, &
                           140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, &
                           140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, &
                           140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double]
    volcanic(:, 1967, 3) = [ &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double]
    volcanic(:, 1967, 4) = [ &
                           110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, &
                           110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, &
                           110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, &
                           110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double]
    volcanic(:, 1967, 5) = [ &
                           130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, &
                           130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, &
                           130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, &
                           130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double, 130.0_c_double]
    volcanic(:, 1967, 6) = [ &
                           150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, &
                           150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, &
                           150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, &
                           150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double]
    volcanic(:, 1967, 7) = [ &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double]
    volcanic(:, 1967, 8) = [ &
                           190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, &
                           190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, &
                           190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, &
                           190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double, 190.0_c_double]
    volcanic(:, 1967, 9) = [ &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double]
    volcanic(:, 1967, 10) = [ &
                            230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, &
                            230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, &
                            230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, &
                            230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double]
    volcanic(:, 1967, 11) = [ &
                            207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, &
                            207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, &
                            207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, &
                            207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double, 207.0_c_double]
    volcanic(:, 1967, 12) = [ &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double]
    volcanic(:, 1968, 1) = [ &
                           160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, &
                           160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, &
                           160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, &
                           160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double]
    volcanic(:, 1968, 2) = [ &
                           137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, &
                           137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, &
                           137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, &
                           137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double, 137.0_c_double]
    volcanic(:, 1968, 3) = [ &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double]
    volcanic(:, 1968, 4) = [ &
                           90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, &
                           90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, &
                           90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, &
                           90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double]
    volcanic(:, 1968, 5) = [ &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, &
                           170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double, 170.0_c_double]
    volcanic(:, 1968, 6) = [ &
                           250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, &
                           250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, &
                           250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, &
                           250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double, 250.0_c_double]
    volcanic(:, 1968, 7) = [ &
                           330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, &
                           330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, &
                           330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, &
                           330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double, 330.0_c_double]
    volcanic(:, 1968, 8) = [ &
                           410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, &
                           410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, &
                           410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, &
                           410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double]
    volcanic(:, 1968, 9) = [ &
                           490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, &
                           490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, &
                           490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, &
                           490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double, 490.0_c_double]
    volcanic(:, 1968, 10) = [ &
                            570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, &
                            570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, &
                            570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, &
                            570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double, 570.0_c_double]
    volcanic(:, 1968, 11) = [ &
                            551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, &
                            551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, &
                            551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, &
                            551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double, 551.0_c_double]
    volcanic(:, 1968, 12) = [ &
                            533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, &
                            533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, &
                            533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, &
                            533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double, 533.0_c_double]
    volcanic(:, 1969, 1) = [ &
                           514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, &
                           514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, &
                           514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, &
                           514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double, 514.0_c_double]
    volcanic(:, 1969, 2) = [ &
                           496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, &
                           496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, &
                           496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, &
                           496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double, 496.0_c_double]
    volcanic(:, 1969, 3) = [ &
                           477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, &
                           477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, &
                           477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, &
                           477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double, 477.0_c_double]
    volcanic(:, 1969, 4) = [ &
                           459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, &
                           459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, &
                           459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, &
                           459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double, 459.0_c_double]
    volcanic(:, 1969, 5) = [ &
                           440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, &
                           440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, &
                           440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, &
                           440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double, 440.0_c_double]
    volcanic(:, 1969, 6) = [ &
                           421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, &
                           421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, &
                           421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, &
                           421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double, 421.0_c_double]
    volcanic(:, 1969, 7) = [ &
                           403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, &
                           403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, &
                           403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, &
                           403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double, 403.0_c_double]
    volcanic(:, 1969, 8) = [ &
                           384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, &
                           384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, &
                           384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, &
                           384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double]
    volcanic(:, 1969, 9) = [ &
                           366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, &
                           366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, &
                           366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, &
                           366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double, 366.0_c_double]
    volcanic(:, 1969, 10) = [ &
                            347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, &
                            347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, &
                            347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, &
                            347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double]
    volcanic(:, 1969, 11) = [ &
                            329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, &
                            329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, &
                            329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, &
                            329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double]
    volcanic(:, 1969, 12) = [ &
                            310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, &
                            310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, &
                            310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, &
                            310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double]
    volcanic(:, 1970, 1) = [ &
                           291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, &
                           291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, &
                           291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, &
                           291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double, 291.0_c_double]
    volcanic(:, 1970, 2) = [ &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double]
    volcanic(:, 1970, 3) = [ &
                           254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, &
                           254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, &
                           254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, &
                           254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double, 254.0_c_double]
    volcanic(:, 1970, 4) = [ &
                           236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, &
                           236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, &
                           236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, &
                           236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double, 236.0_c_double]
    volcanic(:, 1970, 5) = [ &
                           217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, &
                           217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, &
                           217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, &
                           217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double]
    volcanic(:, 1970, 6) = [ &
                           199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, &
                           199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, &
                           199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, &
                           199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double]
    volcanic(:, 1970, 7) = [ &
                           180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, &
                           180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, &
                           180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, &
                           180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double, 180.0_c_double]
    volcanic(:, 1970, 8) = [ &
                           161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, &
                           161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, &
                           161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, &
                           161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double]
    volcanic(:, 1970, 9) = [ &
                           143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, &
                           143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, &
                           143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, &
                           143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double]
    volcanic(:, 1970, 10) = [ &
                            124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, &
                            124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, &
                            124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, &
                            124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double]
    volcanic(:, 1970, 11) = [ &
                            106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, &
                            106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, &
                            106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, &
                            106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double]
    volcanic(:, 1970, 12) = [ &
                            87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, &
                            87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, &
                            87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, &
                            87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double, 87.0_c_double]
    volcanic(:, 1971, 1) = [ &
                           69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, &
                           69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, &
                           69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, &
                           69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double, 69.0_c_double]
    volcanic(:, 1971, 2) = [ &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, &
                           50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double]
    volcanic(:, 1971, 3) = [ &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double]
    volcanic(:, 1971, 4) = [ &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double]
    volcanic(:, 1971, 5) = [ &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double]
    volcanic(:, 1971, 6) = [ &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double]
    volcanic(:, 1971, 7) = [ &
                           8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, &
                           8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, &
                           8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, &
                           8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double]
    volcanic(:, 1971, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 1971, 9) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double]
    volcanic(:, 1971, 10) = [ &
                            4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, &
                            4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, &
                            4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, &
                            4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double]
    volcanic(:, 1971, 11) = [ &
                            6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, &
                            6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, &
                            6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, &
                            6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double]
    volcanic(:, 1971, 12) = [ &
                            8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, &
                            8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, &
                            8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, &
                            8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double]
    volcanic(:, 1972, 1) = [ &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double]
    volcanic(:, 1972, 2) = [ &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double]
    volcanic(:, 1972, 3) = [ &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double]
    volcanic(:, 1972, 4) = [ &
                           21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, &
                           21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, &
                           21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, &
                           21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double, 21.0_c_double]
    volcanic(:, 1972, 5) = [ &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double]
    volcanic(:, 1972, 6) = [ &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double]
    volcanic(:, 1972, 7) = [ &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double]
    volcanic(:, 1972, 8) = [ &
                           37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, &
                           37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, &
                           37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, &
                           37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double, 37.0_c_double]
    volcanic(:, 1972, 9) = [ &
                           41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, &
                           41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, &
                           41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, &
                           41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double]
    volcanic(:, 1972, 10) = [ &
                            44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, &
                            44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, &
                            44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, &
                            44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double]
    volcanic(:, 1972, 11) = [ &
                            48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, &
                            48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, &
                            48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, &
                            48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double]
    volcanic(:, 1972, 12) = [ &
                            52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, &
                            52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, &
                            52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, &
                            52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double]
    volcanic(:, 1973, 1) = [ &
                           56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, &
                           56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, &
                           56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, &
                           56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double, 56.0_c_double]
    volcanic(:, 1973, 2) = [ &
                           60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, &
                           60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, &
                           60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, &
                           60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double, 60.0_c_double]
    volcanic(:, 1973, 3) = [ &
                           64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, &
                           64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, &
                           64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, &
                           64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double]
    volcanic(:, 1973, 4) = [ &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double]
    volcanic(:, 1973, 5) = [ &
                           71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, &
                           71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, &
                           71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, &
                           71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double]
    volcanic(:, 1973, 6) = [ &
                           75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, &
                           75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, &
                           75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, &
                           75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double, 75.0_c_double]
    volcanic(:, 1973, 7) = [ &
                           79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, &
                           79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, &
                           79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, &
                           79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double]
    volcanic(:, 1973, 8) = [ &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double]
    volcanic(:, 1973, 9) = [ &
                           86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, &
                           86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, &
                           86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, &
                           86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double, 86.0_c_double]
    volcanic(:, 1973, 10) = [ &
                            90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, &
                            90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, &
                            90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, &
                            90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double]
    volcanic(:, 1973, 11) = [ &
                            94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, &
                            94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, &
                            94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, &
                            94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double]
    volcanic(:, 1973, 12) = [ &
                            98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, &
                            98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, &
                            98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, &
                            98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double, 98.0_c_double]
    volcanic(:, 1974, 1) = [ &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double]
    volcanic(:, 1974, 2) = [ &
                           106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, &
                           106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, &
                           106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, &
                           106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double, 106.0_c_double]
    volcanic(:, 1974, 3) = [ &
                           109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, &
                           109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, &
                           109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, &
                           109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double, 109.0_c_double]
    volcanic(:, 1974, 4) = [ &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, &
                           113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double]
    volcanic(:, 1974, 5) = [ &
                           117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, &
                           117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, &
                           117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, &
                           117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double]
    volcanic(:, 1974, 6) = [ &
                           121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, &
                           121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, &
                           121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, &
                           121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double, 121.0_c_double]
    volcanic(:, 1974, 7) = [ &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                           125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double]
    volcanic(:, 1974, 8) = [ &
                           129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, &
                           129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, &
                           129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, &
                           129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double, 129.0_c_double]
    volcanic(:, 1974, 9) = [ &
                           132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, &
                           132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, &
                           132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, &
                           132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double, 132.0_c_double]
    volcanic(:, 1974, 10) = [ &
                            136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, &
                            136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, &
                            136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, &
                            136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double, 136.0_c_double]
    volcanic(:, 1974, 11) = [ &
                            140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, &
                            140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, &
                            140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, &
                            140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double]
    volcanic(:, 1974, 12) = [ &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, &
                            183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double, 183.0_c_double]
    volcanic(:, 1975, 1) = [ &
                           227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, &
                           227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, &
                           227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, &
                           227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double]
    volcanic(:, 1975, 2) = [ &
                           270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, &
                           270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, &
                           270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, &
                           270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double, 270.0_c_double]
    volcanic(:, 1975, 3) = [ &
                           313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, &
                           313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, &
                           313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, &
                           313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double]
    volcanic(:, 1975, 4) = [ &
                           357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, &
                           357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, &
                           357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, &
                           357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double, 357.0_c_double]
    volcanic(:, 1975, 5) = [ &
                           400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, &
                           400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, &
                           400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, &
                           400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double, 400.0_c_double]
    volcanic(:, 1975, 6) = [ &
                           337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, &
                           337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, &
                           337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, &
                           337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double, 337.0_c_double]
    volcanic(:, 1975, 7) = [ &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, &
                           273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double, 273.0_c_double]
    volcanic(:, 1975, 8) = [ &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double]
    volcanic(:, 1975, 9) = [ &
                           147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, &
                           147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, &
                           147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, &
                           147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double, 147.0_c_double]
    volcanic(:, 1975, 10) = [ &
                            83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                            83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                            83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                            83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double]
    volcanic(:, 1975, 11) = [ &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double]
    volcanic(:, 1975, 12) = [ &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double, 20.0_c_double]
    volcanic(:, 1976, 1) = [ &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double]
    volcanic(:, 1976, 2) = [ &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double]
    volcanic(:, 1976, 3) = [ &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, &
                           19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double, 19.0_c_double]
    volcanic(:, 1976, 4) = [ &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double]
    volcanic(:, 1976, 5) = [ &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double]
    volcanic(:, 1976, 6) = [ &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, &
                           18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double, 18.0_c_double]
    volcanic(:, 1976, 7) = [ &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double]
    volcanic(:, 1976, 8) = [ &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double, 17.0_c_double]
    volcanic(:, 1976, 9) = [ &
                           16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                           16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                           16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                           16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double]
    volcanic(:, 1976, 10) = [ &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double]
    volcanic(:, 1976, 11) = [ &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, &
                            16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double, 16.0_c_double]
    volcanic(:, 1976, 12) = [ &
                            15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                            15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                            15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                            15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double]
    volcanic(:, 1977, 1) = [ &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double]
    volcanic(:, 1977, 2) = [ &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double, 15.0_c_double]
    volcanic(:, 1977, 3) = [ &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double]
    volcanic(:, 1977, 4) = [ &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double]
    volcanic(:, 1977, 5) = [ &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double]
    volcanic(:, 1977, 6) = [ &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double]
    volcanic(:, 1977, 7) = [ &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double]
    volcanic(:, 1977, 8) = [ &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double]
    volcanic(:, 1977, 9) = [ &
                           12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, &
                           12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, &
                           12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, &
                           12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double]
    volcanic(:, 1977, 10) = [ &
                            12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, &
                            12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, &
                            12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, &
                            12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double]
    volcanic(:, 1977, 11) = [ &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double]
    volcanic(:, 1977, 12) = [ &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                            11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double]
    volcanic(:, 1978, 1) = [ &
                           11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                           11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                           11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, &
                           11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double]
    volcanic(:, 1978, 2) = [ &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double]
    volcanic(:, 1978, 3) = [ &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double]
    volcanic(:, 1978, 4) = [ &
                           28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, &
                           28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, &
                           28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, &
                           28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double, 28.0_c_double]
    volcanic(:, 1978, 5) = [ &
                           47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, &
                           47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, &
                           47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, &
                           47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double, 47.0_c_double]
    volcanic(:, 1978, 6) = [ &
                           65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, &
                           65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, &
                           65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, &
                           65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double]
    volcanic(:, 1978, 7) = [ &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double]
    volcanic(:, 1978, 8) = [ &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, &
                           102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double]
    volcanic(:, 1978, 9) = [ &
                           120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, &
                           120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, &
                           120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, &
                           120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double]
    volcanic(:, 1978, 10) = [ &
                            122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, &
                            122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, &
                            122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, &
                            122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double]
    volcanic(:, 1978, 11) = [ &
                            123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, &
                            123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, &
                            123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, &
                            123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double, 123.0_c_double]
    volcanic(:, 1978, 12) = [ &
                            125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                            125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                            125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, &
                            125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double, 125.0_c_double]
    volcanic(:, 1979, 1) = [ &
                           127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, &
                           127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, &
                           127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, &
                           127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double]
    volcanic(:, 1979, 2) = [ &
                           128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, &
                           128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, &
                           128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, &
                           128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double]
    volcanic(:, 1979, 3) = [ &
                           27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, &
                           27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double]
    volcanic(:, 1979, 4) = [ &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, &
                           23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double]
    volcanic(:, 1979, 5) = [ &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                           24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, &
                           24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double]
    volcanic(:, 1979, 6) = [ &
                           23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, &
                           23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, &
                           24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, &
                           24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double]
    volcanic(:, 1979, 7) = [ &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, &
                           26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, &
                           26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double]
    volcanic(:, 1979, 8) = [ &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, &
                           27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, &
                           27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double]
    volcanic(:, 1979, 9) = [ &
                           23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, &
                           23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, 23.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double]
    volcanic(:, 1979, 10) = [ &
                            24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, &
                            24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, 24.0_c_double, &
                            26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, &
                            26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double, 26.0_c_double]
    volcanic(:, 1979, 11) = [ &
                            25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                            25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                            25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                            25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double]
    volcanic(:, 1979, 12) = [ &
                            30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, &
                            30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, &
                            25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, &
                            25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double, 25.0_c_double]
    volcanic(:, 1980, 1) = [ &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, 33.0_c_double, &
                           27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, &
                           27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double, 27.0_c_double]
    volcanic(:, 1980, 2) = [ &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, &
                           22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, 22.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double]
    volcanic(:, 1980, 3) = [ &
                           34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, &
                           34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double]
    volcanic(:, 1980, 4) = [ &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, &
                           29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double, 29.0_c_double]
    volcanic(:, 1980, 5) = [ &
                           30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, &
                           30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, &
                           30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, &
                           30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double, 30.0_c_double]
    volcanic(:, 1980, 6) = [ &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double]
    volcanic(:, 1980, 7) = [ &
                           55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                           55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double]
    volcanic(:, 1980, 8) = [ &
                           65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, &
                           65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, &
                           31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double, 31.0_c_double]
    volcanic(:, 1980, 9) = [ &
                           68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, &
                           68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, &
                           32.0_c_double, 32.0_c_double, 32.0_c_double, 32.0_c_double, 32.0_c_double, 32.0_c_double, &
                           32.0_c_double, 32.0_c_double, 32.0_c_double, 32.0_c_double, 32.0_c_double, 32.0_c_double]
    volcanic(:, 1980, 10) = [ &
                            68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, &
                            68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, &
                            34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, &
                            34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double, 34.0_c_double]
    volcanic(:, 1980, 11) = [ &
                            65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, &
                            65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, &
                            41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, &
                            41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double]
    volcanic(:, 1980, 12) = [ &
                            61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                            61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                            41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, &
                            41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double, 41.0_c_double]
    volcanic(:, 1981, 1) = [ &
                           59.0_c_double, 59.0_c_double, 59.0_c_double, 59.0_c_double, 59.0_c_double, 59.0_c_double, &
                           59.0_c_double, 59.0_c_double, 59.0_c_double, 59.0_c_double, 59.0_c_double, 59.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double]
    volcanic(:, 1981, 2) = [ &
                           55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                           55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double]
    volcanic(:, 1981, 3) = [ &
                           49.0_c_double, 49.0_c_double, 49.0_c_double, 49.0_c_double, 49.0_c_double, 49.0_c_double, &
                           49.0_c_double, 49.0_c_double, 49.0_c_double, 49.0_c_double, 49.0_c_double, 49.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double]
    volcanic(:, 1981, 4) = [ &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double]
    volcanic(:, 1981, 5) = [ &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double, 42.0_c_double]
    volcanic(:, 1981, 6) = [ &
                           52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, &
                           52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, 52.0_c_double, &
                           44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, &
                           44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double, 44.0_c_double]
    volcanic(:, 1981, 7) = [ &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, &
                           48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double]
    volcanic(:, 1981, 8) = [ &
                           57.0_c_double, 57.0_c_double, 57.0_c_double, 57.0_c_double, 57.0_c_double, 57.0_c_double, &
                           57.0_c_double, 57.0_c_double, 57.0_c_double, 57.0_c_double, 57.0_c_double, 57.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double]
    volcanic(:, 1981, 9) = [ &
                           53.0_c_double, 53.0_c_double, 53.0_c_double, 53.0_c_double, 53.0_c_double, 53.0_c_double, &
                           53.0_c_double, 53.0_c_double, 53.0_c_double, 53.0_c_double, 53.0_c_double, 53.0_c_double, &
                           48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, &
                           48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double, 48.0_c_double]
    volcanic(:, 1981, 10) = [ &
                            54.0_c_double, 54.0_c_double, 54.0_c_double, 54.0_c_double, 54.0_c_double, 54.0_c_double, &
                            54.0_c_double, 54.0_c_double, 54.0_c_double, 54.0_c_double, 54.0_c_double, 54.0_c_double, &
                            46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, &
                            46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double]
    volcanic(:, 1981, 11) = [ &
                            55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                            55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                            46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, &
                            46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double]
    volcanic(:, 1981, 12) = [ &
                            55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                            55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, &
                            46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, &
                            46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double]
    volcanic(:, 1982, 1) = [ &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double]
    volcanic(:, 1982, 2) = [ &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double]
    volcanic(:, 1982, 3) = [ &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, 61.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, &
                           51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double, 51.0_c_double]
    volcanic(:, 1982, 4) = [ &
                           101.0_c_double, 101.0_c_double, 101.0_c_double, 101.0_c_double, 101.0_c_double, 23.0_c_double, &
                           20.0_c_double, 13.0_c_double, 123.0_c_double, 2823.0_c_double, 124.0_c_double, 8.0_c_double, &
                           6.0_c_double, 6.0_c_double, 4.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, &
                           1.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double]
    volcanic(:, 1982, 5) = [ &
                           185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 185.0_c_double, 224.0_c_double, &
                           194.0_c_double, 146.0_c_double, 1158.0_c_double, 3001.0_c_double, 1271.0_c_double, 102.0_c_double, &
                           77.0_c_double, 58.0_c_double, 44.0_c_double, 35.0_c_double, 29.0_c_double, 23.0_c_double, &
                           17.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double, 55.0_c_double]
    volcanic(:, 1982, 6) = [ &
                           253.0_c_double, 253.0_c_double, 253.0_c_double, 253.0_c_double, 253.0_c_double, 274.0_c_double, &
                           238.0_c_double, 279.0_c_double, 1266.0_c_double, 2642.0_c_double, 1938.0_c_double, 443.0_c_double, &
                           267.0_c_double, 163.0_c_double, 99.0_c_double, 78.0_c_double, 73.0_c_double, 68.0_c_double, &
                           62.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double]
    volcanic(:, 1982, 7) = [ &
                           284.0_c_double, 284.0_c_double, 284.0_c_double, 284.0_c_double, 284.0_c_double, 299.0_c_double, &
                           263.0_c_double, 437.0_c_double, 1184.0_c_double, 2470.0_c_double, 2386.0_c_double, 1285.0_c_double, &
                           664.0_c_double, 354.0_c_double, 187.0_c_double, 144.0_c_double, 151.0_c_double, 160.0_c_double, &
                           163.0_c_double, 96.0_c_double, 96.0_c_double, 96.0_c_double, 96.0_c_double, 96.0_c_double]
    volcanic(:, 1982, 8) = [ &
                           347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 347.0_c_double, 377.0_c_double, &
                           352.0_c_double, 504.0_c_double, 1242.0_c_double, 2180.0_c_double, 2270.0_c_double, 1575.0_c_double, &
                           829.0_c_double, 468.0_c_double, 260.0_c_double, 197.0_c_double, 209.0_c_double, 227.0_c_double, &
                           221.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double, 143.0_c_double]
    volcanic(:, 1982, 9) = [ &
                           387.0_c_double, 387.0_c_double, 387.0_c_double, 387.0_c_double, 387.0_c_double, 487.0_c_double, &
                           485.0_c_double, 557.0_c_double, 1319.0_c_double, 1916.0_c_double, 2074.0_c_double, 1719.0_c_double, &
                           938.0_c_double, 578.0_c_double, 345.0_c_double, 256.0_c_double, 273.0_c_double, 301.0_c_double, &
                           275.0_c_double, 96.0_c_double, 96.0_c_double, 96.0_c_double, 96.0_c_double, 96.0_c_double]
    volcanic(:, 1982, 10) = [ &
                            476.0_c_double, 476.0_c_double, 476.0_c_double, 476.0_c_double, 476.0_c_double, 630.0_c_double, &
                            670.0_c_double, 618.0_c_double, 1400.0_c_double, 1681.0_c_double, 1895.0_c_double, 1873.0_c_double, &
                            1060.0_c_double, 715.0_c_double, 459.0_c_double, 337.0_c_double, 359.0_c_double, 402.0_c_double, &
                            342.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double, 46.0_c_double]
    volcanic(:, 1982, 11) = [ &
                            689.0_c_double, 689.0_c_double, 689.0_c_double, 689.0_c_double, 689.0_c_double, 882.0_c_double, &
                            900.0_c_double, 773.0_c_double, 1218.0_c_double, 1404.0_c_double, 1738.0_c_double, 1834.0_c_double, &
                            1188.0_c_double, 826.0_c_double, 531.0_c_double, 343.0_c_double, 402.0_c_double, 473.0_c_double, &
                            430.0_c_double, 195.0_c_double, 195.0_c_double, 195.0_c_double, 195.0_c_double, 195.0_c_double]
    volcanic(:, 1982, 12) = [ &
                            1085.0_c_double, 1085.0_c_double, 1085.0_c_double, 1085.0_c_double, 1085.0_c_double, 1240.0_c_double, &
                            1126.0_c_double, 1016.0_c_double, 890.0_c_double, 1134.0_c_double, 1575.0_c_double, 1601.0_c_double, &
                            1255.0_c_double, 865.0_c_double, 532.0_c_double, 287.0_c_double, 397.0_c_double, 497.0_c_double, &
                            526.0_c_double, 461.0_c_double, 461.0_c_double, 461.0_c_double, 461.0_c_double, 461.0_c_double]
    volcanic(:, 1983, 1) = [ &
                           1214.0_c_double, 1214.0_c_double, 1214.0_c_double, 1214.0_c_double, 1214.0_c_double, 1300.0_c_double, &
                           1143.0_c_double, 1018.0_c_double, 803.0_c_double, 1015.0_c_double, 1364.0_c_double, 1344.0_c_double, &
                           1053.0_c_double, 755.0_c_double, 494.0_c_double, 310.0_c_double, 449.0_c_double, 519.0_c_double, &
                           545.0_c_double, 549.0_c_double, 549.0_c_double, 549.0_c_double, 549.0_c_double, 549.0_c_double]
    volcanic(:, 1983, 2) = [ &
                           1377.0_c_double, 1377.0_c_double, 1377.0_c_double, 1377.0_c_double, 1377.0_c_double, 1315.0_c_double, &
                           1132.0_c_double, 976.0_c_double, 747.0_c_double, 923.0_c_double, 1176.0_c_double, 1126.0_c_double, &
                           853.0_c_double, 647.0_c_double, 452.0_c_double, 352.0_c_double, 514.0_c_double, 534.0_c_double, &
                           545.0_c_double, 575.0_c_double, 575.0_c_double, 575.0_c_double, 575.0_c_double, 575.0_c_double]
    volcanic(:, 1983, 3) = [ &
                           2013.0_c_double, 2013.0_c_double, 2013.0_c_double, 2013.0_c_double, 2013.0_c_double, 1341.0_c_double, &
                           1128.0_c_double, 932.0_c_double, 688.0_c_double, 832.0_c_double, 1010.0_c_double, 941.0_c_double, &
                           693.0_c_double, 558.0_c_double, 413.0_c_double, 400.0_c_double, 589.0_c_double, 545.0_c_double, &
                           540.0_c_double, 487.0_c_double, 487.0_c_double, 487.0_c_double, 487.0_c_double, 487.0_c_double]
    volcanic(:, 1983, 4) = [ &
                           1681.0_c_double, 1681.0_c_double, 1681.0_c_double, 1681.0_c_double, 1681.0_c_double, 1365.0_c_double, &
                           1124.0_c_double, 892.0_c_double, 636.0_c_double, 749.0_c_double, 864.0_c_double, 780.0_c_double, &
                           558.0_c_double, 476.0_c_double, 372.0_c_double, 458.0_c_double, 675.0_c_double, 553.0_c_double, &
                           536.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double, 410.0_c_double]
    volcanic(:, 1983, 5) = [ &
                           1460.0_c_double, 1460.0_c_double, 1460.0_c_double, 1460.0_c_double, 1460.0_c_double, 1359.0_c_double, &
                           1093.0_c_double, 846.0_c_double, 590.0_c_double, 678.0_c_double, 746.0_c_double, 656.0_c_double, &
                           457.0_c_double, 409.0_c_double, 337.0_c_double, 502.0_c_double, 740.0_c_double, 552.0_c_double, &
                           526.0_c_double, 331.0_c_double, 331.0_c_double, 331.0_c_double, 331.0_c_double, 331.0_c_double]
    volcanic(:, 1983, 6) = [ &
                           1572.0_c_double, 1572.0_c_double, 1572.0_c_double, 1572.0_c_double, 1572.0_c_double, 1200.0_c_double, &
                           943.0_c_double, 748.0_c_double, 542.0_c_double, 620.0_c_double, 674.0_c_double, 598.0_c_double, &
                           419.0_c_double, 367.0_c_double, 296.0_c_double, 447.0_c_double, 644.0_c_double, 491.0_c_double, &
                           485.0_c_double, 279.0_c_double, 279.0_c_double, 279.0_c_double, 279.0_c_double, 279.0_c_double]
    volcanic(:, 1983, 7) = [ &
                           1294.0_c_double, 1294.0_c_double, 1294.0_c_double, 1294.0_c_double, 1294.0_c_double, 1035.0_c_double, &
                           793.0_c_double, 652.0_c_double, 498.0_c_double, 568.0_c_double, 615.0_c_double, 554.0_c_double, &
                           389.0_c_double, 333.0_c_double, 261.0_c_double, 381.0_c_double, 536.0_c_double, 428.0_c_double, &
                           440.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double, 290.0_c_double]
    volcanic(:, 1983, 8) = [ &
                           1038.0_c_double, 1038.0_c_double, 1038.0_c_double, 1038.0_c_double, 1038.0_c_double, 890.0_c_double, &
                           663.0_c_double, 569.0_c_double, 459.0_c_double, 518.0_c_double, 560.0_c_double, 513.0_c_double, &
                           365.0_c_double, 301.0_c_double, 229.0_c_double, 327.0_c_double, 444.0_c_double, 372.0_c_double, &
                           402.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double, 329.0_c_double]
    volcanic(:, 1983, 9) = [ &
                           1012.0_c_double, 1012.0_c_double, 1012.0_c_double, 1012.0_c_double, 1012.0_c_double, 768.0_c_double, &
                           558.0_c_double, 496.0_c_double, 420.0_c_double, 473.0_c_double, 510.0_c_double, 475.0_c_double, &
                           341.0_c_double, 273.0_c_double, 200.0_c_double, 279.0_c_double, 371.0_c_double, 323.0_c_double, &
                           366.0_c_double, 188.0_c_double, 188.0_c_double, 188.0_c_double, 188.0_c_double, 188.0_c_double]
    volcanic(:, 1983, 10) = [ &
                            818.0_c_double, 818.0_c_double, 818.0_c_double, 818.0_c_double, 818.0_c_double, 662.0_c_double, &
                            468.0_c_double, 433.0_c_double, 385.0_c_double, 432.0_c_double, 465.0_c_double, 440.0_c_double, &
                            319.0_c_double, 246.0_c_double, 176.0_c_double, 238.0_c_double, 308.0_c_double, 282.0_c_double, &
                            333.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double, 122.0_c_double]
    volcanic(:, 1983, 11) = [ &
                            667.0_c_double, 667.0_c_double, 667.0_c_double, 667.0_c_double, 667.0_c_double, 571.0_c_double, &
                            393.0_c_double, 378.0_c_double, 354.0_c_double, 396.0_c_double, 424.0_c_double, 407.0_c_double, &
                            296.0_c_double, 223.0_c_double, 154.0_c_double, 204.0_c_double, 256.0_c_double, 245.0_c_double, &
                            303.0_c_double, 186.0_c_double, 186.0_c_double, 186.0_c_double, 186.0_c_double, 186.0_c_double]
    volcanic(:, 1983, 12) = [ &
                            567.0_c_double, 567.0_c_double, 567.0_c_double, 567.0_c_double, 567.0_c_double, 492.0_c_double, &
                            330.0_c_double, 330.0_c_double, 326.0_c_double, 362.0_c_double, 386.0_c_double, 377.0_c_double, &
                            277.0_c_double, 204.0_c_double, 135.0_c_double, 174.0_c_double, 213.0_c_double, 213.0_c_double, &
                            275.0_c_double, 294.0_c_double, 294.0_c_double, 294.0_c_double, 294.0_c_double, 294.0_c_double]
    volcanic(:, 1984, 1) = [ &
                           540.0_c_double, 540.0_c_double, 540.0_c_double, 540.0_c_double, 540.0_c_double, 424.0_c_double, &
                           276.0_c_double, 287.0_c_double, 297.0_c_double, 329.0_c_double, 351.0_c_double, 349.0_c_double, &
                           259.0_c_double, 183.0_c_double, 119.0_c_double, 147.0_c_double, 177.0_c_double, 185.0_c_double, &
                           251.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double, 310.0_c_double]
    volcanic(:, 1984, 2) = [ &
                           503.0_c_double, 503.0_c_double, 503.0_c_double, 503.0_c_double, 503.0_c_double, 375.0_c_double, &
                           242.0_c_double, 256.0_c_double, 268.0_c_double, 298.0_c_double, 318.0_c_double, 318.0_c_double, &
                           237.0_c_double, 165.0_c_double, 106.0_c_double, 131.0_c_double, 155.0_c_double, 165.0_c_double, &
                           227.0_c_double, 293.0_c_double, 293.0_c_double, 293.0_c_double, 293.0_c_double, 293.0_c_double]
    volcanic(:, 1984, 3) = [ &
                           385.0_c_double, 385.0_c_double, 385.0_c_double, 385.0_c_double, 385.0_c_double, 338.0_c_double, &
                           218.0_c_double, 230.0_c_double, 243.0_c_double, 268.0_c_double, 286.0_c_double, 286.0_c_double, &
                           212.0_c_double, 147.0_c_double, 96.0_c_double, 118.0_c_double, 140.0_c_double, 149.0_c_double, &
                           205.0_c_double, 263.0_c_double, 263.0_c_double, 263.0_c_double, 263.0_c_double, 263.0_c_double]
    volcanic(:, 1984, 4) = [ &
                           433.0_c_double, 433.0_c_double, 433.0_c_double, 433.0_c_double, 433.0_c_double, 303.0_c_double, &
                           197.0_c_double, 207.0_c_double, 217.0_c_double, 242.0_c_double, 257.0_c_double, 257.0_c_double, &
                           191.0_c_double, 133.0_c_double, 86.0_c_double, 107.0_c_double, 125.0_c_double, 133.0_c_double, &
                           184.0_c_double, 246.0_c_double, 246.0_c_double, 246.0_c_double, 246.0_c_double, 246.0_c_double]
    volcanic(:, 1984, 5) = [ &
                           388.0_c_double, 388.0_c_double, 388.0_c_double, 388.0_c_double, 388.0_c_double, 273.0_c_double, &
                           177.0_c_double, 186.0_c_double, 196.0_c_double, 217.0_c_double, 231.0_c_double, 231.0_c_double, &
                           173.0_c_double, 120.0_c_double, 77.0_c_double, 95.0_c_double, 112.0_c_double, 119.0_c_double, &
                           165.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double, 217.0_c_double]
    volcanic(:, 1984, 6) = [ &
                           321.0_c_double, 321.0_c_double, 321.0_c_double, 321.0_c_double, 321.0_c_double, 244.0_c_double, &
                           158.0_c_double, 167.0_c_double, 176.0_c_double, 196.0_c_double, 208.0_c_double, 208.0_c_double, &
                           154.0_c_double, 108.0_c_double, 69.0_c_double, 85.0_c_double, 101.0_c_double, 107.0_c_double, &
                           147.0_c_double, 249.0_c_double, 249.0_c_double, 249.0_c_double, 249.0_c_double, 249.0_c_double]
    volcanic(:, 1984, 7) = [ &
                           284.0_c_double, 284.0_c_double, 284.0_c_double, 284.0_c_double, 284.0_c_double, 220.0_c_double, &
                           142.0_c_double, 150.0_c_double, 157.0_c_double, 175.0_c_double, 187.0_c_double, 187.0_c_double, &
                           140.0_c_double, 98.0_c_double, 62.0_c_double, 76.0_c_double, 90.0_c_double, 96.0_c_double, &
                           133.0_c_double, 276.0_c_double, 276.0_c_double, 276.0_c_double, 276.0_c_double, 276.0_c_double]
    volcanic(:, 1984, 8) = [ &
                           274.0_c_double, 274.0_c_double, 274.0_c_double, 274.0_c_double, 274.0_c_double, 197.0_c_double, &
                           127.0_c_double, 134.0_c_double, 142.0_c_double, 157.0_c_double, 167.0_c_double, 167.0_c_double, &
                           124.0_c_double, 86.0_c_double, 56.0_c_double, 67.0_c_double, 81.0_c_double, 86.0_c_double, &
                           119.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double, 227.0_c_double]
    volcanic(:, 1984, 9) = [ &
                           264.0_c_double, 264.0_c_double, 264.0_c_double, 264.0_c_double, 264.0_c_double, 177.0_c_double, &
                           114.0_c_double, 121.0_c_double, 127.0_c_double, 141.0_c_double, 151.0_c_double, 151.0_c_double, &
                           112.0_c_double, 78.0_c_double, 51.0_c_double, 61.0_c_double, 73.0_c_double, 77.0_c_double, &
                           107.0_c_double, 114.0_c_double, 114.0_c_double, 114.0_c_double, 114.0_c_double, 114.0_c_double]
    volcanic(:, 1984, 10) = [ &
                            256.0_c_double, 256.0_c_double, 256.0_c_double, 256.0_c_double, 256.0_c_double, 158.0_c_double, &
                            102.0_c_double, 109.0_c_double, 114.0_c_double, 127.0_c_double, 135.0_c_double, 135.0_c_double, &
                            101.0_c_double, 70.0_c_double, 44.0_c_double, 55.0_c_double, 66.0_c_double, 69.0_c_double, &
                            95.0_c_double, 84.0_c_double, 84.0_c_double, 84.0_c_double, 84.0_c_double, 84.0_c_double]
    volcanic(:, 1984, 11) = [ &
                            249.0_c_double, 249.0_c_double, 249.0_c_double, 249.0_c_double, 249.0_c_double, 142.0_c_double, &
                            92.0_c_double, 98.0_c_double, 102.0_c_double, 114.0_c_double, 122.0_c_double, 122.0_c_double, &
                            90.0_c_double, 63.0_c_double, 40.0_c_double, 50.0_c_double, 59.0_c_double, 62.0_c_double, &
                            86.0_c_double, 139.0_c_double, 139.0_c_double, 139.0_c_double, 139.0_c_double, 139.0_c_double]
    volcanic(:, 1984, 12) = [ &
                            241.0_c_double, 241.0_c_double, 241.0_c_double, 241.0_c_double, 241.0_c_double, 128.0_c_double, &
                            83.0_c_double, 88.0_c_double, 92.0_c_double, 102.0_c_double, 110.0_c_double, 110.0_c_double, &
                            81.0_c_double, 56.0_c_double, 35.0_c_double, 44.0_c_double, 53.0_c_double, 55.0_c_double, &
                            77.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double, 199.0_c_double]
    volcanic(:, 1985, 1) = [ &
                           229.0_c_double, 229.0_c_double, 229.0_c_double, 229.0_c_double, 229.0_c_double, 256.0_c_double, &
                           251.0_c_double, 186.0_c_double, 134.0_c_double, 120.0_c_double, 133.0_c_double, 134.0_c_double, &
                           140.0_c_double, 145.0_c_double, 128.0_c_double, 104.0_c_double, 112.0_c_double, 145.0_c_double, &
                           182.0_c_double, 213.0_c_double, 213.0_c_double, 213.0_c_double, 213.0_c_double, 213.0_c_double]
    volcanic(:, 1985, 2) = [ &
                           237.0_c_double, 237.0_c_double, 237.0_c_double, 237.0_c_double, 237.0_c_double, 268.0_c_double, &
                           262.0_c_double, 178.0_c_double, 127.0_c_double, 115.0_c_double, 119.0_c_double, 117.0_c_double, &
                           125.0_c_double, 127.0_c_double, 102.0_c_double, 107.0_c_double, 111.0_c_double, 133.0_c_double, &
                           212.0_c_double, 213.0_c_double, 211.0_c_double, 213.0_c_double, 215.0_c_double, 215.0_c_double]
    volcanic(:, 1985, 3) = [ &
                           222.0_c_double, 222.0_c_double, 222.0_c_double, 222.0_c_double, 223.0_c_double, 220.0_c_double, &
                           202.0_c_double, 122.0_c_double, 88.0_c_double, 90.0_c_double, 103.0_c_double, 115.0_c_double, &
                           116.0_c_double, 116.0_c_double, 112.0_c_double, 109.0_c_double, 110.0_c_double, 121.0_c_double, &
                           157.0_c_double, 208.0_c_double, 205.0_c_double, 202.0_c_double, 202.0_c_double, 202.0_c_double]
    volcanic(:, 1985, 4) = [ &
                           234.0_c_double, 234.0_c_double, 234.0_c_double, 240.0_c_double, 238.0_c_double, 191.0_c_double, &
                           155.0_c_double, 115.0_c_double, 93.0_c_double, 92.0_c_double, 97.0_c_double, 117.0_c_double, &
                           123.0_c_double, 115.0_c_double, 105.0_c_double, 107.0_c_double, 111.0_c_double, 134.0_c_double, &
                           165.0_c_double, 192.0_c_double, 192.0_c_double, 192.0_c_double, 192.0_c_double, 192.0_c_double]
    volcanic(:, 1985, 5) = [ &
                           210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 210.0_c_double, 155.0_c_double, &
                           138.0_c_double, 108.0_c_double, 88.0_c_double, 84.0_c_double, 98.0_c_double, 109.0_c_double, &
                           112.0_c_double, 105.0_c_double, 96.0_c_double, 100.0_c_double, 115.0_c_double, 149.0_c_double, &
                           161.0_c_double, 176.0_c_double, 176.0_c_double, 176.0_c_double, 176.0_c_double, 176.0_c_double]
    volcanic(:, 1985, 6) = [ &
                           172.0_c_double, 172.0_c_double, 172.0_c_double, 172.0_c_double, 173.0_c_double, 151.0_c_double, &
                           118.0_c_double, 94.0_c_double, 83.0_c_double, 86.0_c_double, 103.0_c_double, 112.0_c_double, &
                           116.0_c_double, 105.0_c_double, 92.0_c_double, 95.0_c_double, 121.0_c_double, 171.0_c_double, &
                           178.0_c_double, 182.0_c_double, 182.0_c_double, 182.0_c_double, 182.0_c_double, 182.0_c_double]
    volcanic(:, 1985, 7) = [ &
                           150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 122.0_c_double, &
                           98.0_c_double, 79.0_c_double, 79.0_c_double, 88.0_c_double, 109.0_c_double, 115.0_c_double, &
                           122.0_c_double, 98.0_c_double, 79.0_c_double, 86.0_c_double, 120.0_c_double, 161.0_c_double, &
                           176.0_c_double, 205.0_c_double, 205.0_c_double, 205.0_c_double, 205.0_c_double, 205.0_c_double]
    volcanic(:, 1985, 8) = [ &
                           152.0_c_double, 152.0_c_double, 152.0_c_double, 152.0_c_double, 152.0_c_double, 119.0_c_double, &
                           97.0_c_double, 82.0_c_double, 78.0_c_double, 86.0_c_double, 103.0_c_double, 113.0_c_double, &
                           118.0_c_double, 93.0_c_double, 73.0_c_double, 78.0_c_double, 107.0_c_double, 144.0_c_double, &
                           165.0_c_double, 191.0_c_double, 191.0_c_double, 191.0_c_double, 191.0_c_double, 191.0_c_double]
    volcanic(:, 1985, 9) = [ &
                           155.0_c_double, 155.0_c_double, 155.0_c_double, 155.0_c_double, 156.0_c_double, 116.0_c_double, &
                           96.0_c_double, 86.0_c_double, 77.0_c_double, 84.0_c_double, 97.0_c_double, 110.0_c_double, &
                           115.0_c_double, 88.0_c_double, 67.0_c_double, 69.0_c_double, 93.0_c_double, 127.0_c_double, &
                           154.0_c_double, 85.0_c_double, 89.0_c_double, 89.0_c_double, 89.0_c_double, 89.0_c_double]
    volcanic(:, 1985, 10) = [ &
                            157.0_c_double, 157.0_c_double, 157.0_c_double, 157.0_c_double, 157.0_c_double, 125.0_c_double, &
                            97.0_c_double, 77.0_c_double, 76.0_c_double, 84.0_c_double, 93.0_c_double, 107.0_c_double, &
                            108.0_c_double, 86.0_c_double, 73.0_c_double, 80.0_c_double, 105.0_c_double, 126.0_c_double, &
                            130.0_c_double, 75.0_c_double, 76.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double]
    volcanic(:, 1985, 11) = [ &
                            146.0_c_double, 146.0_c_double, 146.0_c_double, 146.0_c_double, 146.0_c_double, 133.0_c_double, &
                            111.0_c_double, 83.0_c_double, 77.0_c_double, 78.0_c_double, 94.0_c_double, 105.0_c_double, &
                            104.0_c_double, 81.0_c_double, 70.0_c_double, 63.0_c_double, 76.0_c_double, 107.0_c_double, &
                            132.0_c_double, 87.0_c_double, 85.0_c_double, 85.0_c_double, 85.0_c_double, 85.0_c_double]
    volcanic(:, 1985, 12) = [ &
                            150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 150.0_c_double, 151.0_c_double, &
                            134.0_c_double, 102.0_c_double, 77.0_c_double, 79.0_c_double, 139.0_c_double, 254.0_c_double, &
                            188.0_c_double, 98.0_c_double, 71.0_c_double, 62.0_c_double, 71.0_c_double, 93.0_c_double, &
                            113.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double]
    volcanic(:, 1986, 1) = [ &
                           178.0_c_double, 178.0_c_double, 178.0_c_double, 178.0_c_double, 178.0_c_double, 168.0_c_double, &
                           157.0_c_double, 121.0_c_double, 76.0_c_double, 80.0_c_double, 185.0_c_double, 404.0_c_double, &
                           271.0_c_double, 116.0_c_double, 71.0_c_double, 60.0_c_double, 66.0_c_double, 79.0_c_double, &
                           94.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double]
    volcanic(:, 1986, 2) = [ &
                           224.0_c_double, 224.0_c_double, 224.0_c_double, 224.0_c_double, 224.0_c_double, 184.0_c_double, &
                           182.0_c_double, 138.0_c_double, 104.0_c_double, 111.0_c_double, 239.0_c_double, 389.0_c_double, &
                           284.0_c_double, 115.0_c_double, 32.0_c_double, 64.0_c_double, 67.0_c_double, 83.0_c_double, &
                           98.0_c_double, 114.0_c_double, 114.0_c_double, 115.0_c_double, 118.0_c_double, 118.0_c_double]
    volcanic(:, 1986, 3) = [ &
                           152.0_c_double, 152.0_c_double, 152.0_c_double, 152.0_c_double, 150.0_c_double, 160.0_c_double, &
                           140.0_c_double, 86.0_c_double, 81.0_c_double, 94.0_c_double, 197.0_c_double, 364.0_c_double, &
                           290.0_c_double, 140.0_c_double, 81.0_c_double, 67.0_c_double, 67.0_c_double, 86.0_c_double, &
                           97.0_c_double, 121.0_c_double, 118.0_c_double, 117.0_c_double, 117.0_c_double, 117.0_c_double]
    volcanic(:, 1986, 4) = [ &
                           173.0_c_double, 173.0_c_double, 173.0_c_double, 181.0_c_double, 179.0_c_double, 149.0_c_double, &
                           140.0_c_double, 110.0_c_double, 94.0_c_double, 120.0_c_double, 178.0_c_double, 354.0_c_double, &
                           273.0_c_double, 138.0_c_double, 81.0_c_double, 68.0_c_double, 69.0_c_double, 89.0_c_double, &
                           107.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double]
    volcanic(:, 1986, 5) = [ &
                           172.0_c_double, 172.0_c_double, 172.0_c_double, 172.0_c_double, 176.0_c_double, 130.0_c_double, &
                           113.0_c_double, 94.0_c_double, 91.0_c_double, 110.0_c_double, 186.0_c_double, 301.0_c_double, &
                           271.0_c_double, 136.0_c_double, 79.0_c_double, 67.0_c_double, 76.0_c_double, 96.0_c_double, &
                           117.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double, 116.0_c_double]
    volcanic(:, 1986, 6) = [ &
                           149.0_c_double, 149.0_c_double, 149.0_c_double, 149.0_c_double, 150.0_c_double, 130.0_c_double, &
                           99.0_c_double, 79.0_c_double, 76.0_c_double, 96.0_c_double, 163.0_c_double, 251.0_c_double, &
                           240.0_c_double, 125.0_c_double, 70.0_c_double, 71.0_c_double, 92.0_c_double, 119.0_c_double, &
                           131.0_c_double, 126.0_c_double, 126.0_c_double, 126.0_c_double, 126.0_c_double, 126.0_c_double]
    volcanic(:, 1986, 7) = [ &
                           135.0_c_double, 135.0_c_double, 135.0_c_double, 135.0_c_double, 135.0_c_double, 116.0_c_double, &
                           85.0_c_double, 63.0_c_double, 62.0_c_double, 83.0_c_double, 140.0_c_double, 202.0_c_double, &
                           208.0_c_double, 138.0_c_double, 87.0_c_double, 78.0_c_double, 107.0_c_double, 122.0_c_double, &
                           134.0_c_double, 201.0_c_double, 201.0_c_double, 201.0_c_double, 201.0_c_double, 201.0_c_double]
    volcanic(:, 1986, 8) = [ &
                           141.0_c_double, 141.0_c_double, 141.0_c_double, 140.0_c_double, 139.0_c_double, 101.0_c_double, &
                           64.0_c_double, 71.0_c_double, 78.0_c_double, 95.0_c_double, 117.0_c_double, 188.0_c_double, &
                           194.0_c_double, 145.0_c_double, 110.0_c_double, 86.0_c_double, 122.0_c_double, 144.0_c_double, &
                           150.0_c_double, 303.0_c_double, 303.0_c_double, 303.0_c_double, 303.0_c_double, 303.0_c_double]
    volcanic(:, 1986, 9) = [ &
                           149.0_c_double, 149.0_c_double, 149.0_c_double, 151.0_c_double, 151.0_c_double, 112.0_c_double, &
                           94.0_c_double, 80.0_c_double, 93.0_c_double, 109.0_c_double, 144.0_c_double, 181.0_c_double, &
                           178.0_c_double, 155.0_c_double, 79.0_c_double, 70.0_c_double, 104.0_c_double, 129.0_c_double, &
                           140.0_c_double, 139.0_c_double, 144.0_c_double, 144.0_c_double, 144.0_c_double, 144.0_c_double]
    volcanic(:, 1986, 10) = [ &
                            148.0_c_double, 148.0_c_double, 148.0_c_double, 148.0_c_double, 148.0_c_double, 118.0_c_double, &
                            100.0_c_double, 82.0_c_double, 87.0_c_double, 114.0_c_double, 169.0_c_double, 207.0_c_double, &
                            186.0_c_double, 153.0_c_double, 105.0_c_double, 86.0_c_double, 100.0_c_double, 136.0_c_double, &
                            138.0_c_double, 59.0_c_double, 63.0_c_double, 62.0_c_double, 62.0_c_double, 62.0_c_double]
    volcanic(:, 1986, 11) = [ &
                            144.0_c_double, 144.0_c_double, 144.0_c_double, 144.0_c_double, 144.0_c_double, 141.0_c_double, &
                            118.0_c_double, 97.0_c_double, 84.0_c_double, 113.0_c_double, 159.0_c_double, 184.0_c_double, &
                            181.0_c_double, 151.0_c_double, 95.0_c_double, 73.0_c_double, 85.0_c_double, 97.0_c_double, &
                            111.0_c_double, 92.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double]
    volcanic(:, 1986, 12) = [ &
                            161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 161.0_c_double, 152.0_c_double, &
                            136.0_c_double, 107.0_c_double, 87.0_c_double, 106.0_c_double, 150.0_c_double, 162.0_c_double, &
                            160.0_c_double, 135.0_c_double, 85.0_c_double, 51.0_c_double, 60.0_c_double, 86.0_c_double, &
                            105.0_c_double, 119.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double, 120.0_c_double]
    volcanic(:, 1987, 1) = [ &
                           247.0_c_double, 247.0_c_double, 247.0_c_double, 247.0_c_double, 247.0_c_double, 159.0_c_double, &
                           105.0_c_double, 113.0_c_double, 91.0_c_double, 112.0_c_double, 136.0_c_double, 141.0_c_double, &
                           138.0_c_double, 119.0_c_double, 74.0_c_double, 28.0_c_double, 35.0_c_double, 76.0_c_double, &
                           93.0_c_double, 118.0_c_double, 118.0_c_double, 118.0_c_double, 118.0_c_double, 118.0_c_double]
    volcanic(:, 1987, 2) = [ &
                           187.0_c_double, 187.0_c_double, 187.0_c_double, 187.0_c_double, 187.0_c_double, 157.0_c_double, &
                           155.0_c_double, 119.0_c_double, 104.0_c_double, 104.0_c_double, 119.0_c_double, 121.0_c_double, &
                           116.0_c_double, 82.0_c_double, 76.0_c_double, 49.0_c_double, 51.0_c_double, 77.0_c_double, &
                           101.0_c_double, 112.0_c_double, 110.0_c_double, 113.0_c_double, 112.0_c_double, 112.0_c_double]
    volcanic(:, 1987, 3) = [ &
                           176.0_c_double, 176.0_c_double, 176.0_c_double, 176.0_c_double, 176.0_c_double, 162.0_c_double, &
                           145.0_c_double, 98.0_c_double, 83.0_c_double, 87.0_c_double, 110.0_c_double, 113.0_c_double, &
                           108.0_c_double, 100.0_c_double, 77.0_c_double, 69.0_c_double, 68.0_c_double, 78.0_c_double, &
                           82.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double, 128.0_c_double]
    volcanic(:, 1987, 4) = [ &
                           164.0_c_double, 164.0_c_double, 164.0_c_double, 167.0_c_double, 170.0_c_double, 135.0_c_double, &
                           124.0_c_double, 104.0_c_double, 86.0_c_double, 89.0_c_double, 96.0_c_double, 105.0_c_double, &
                           105.0_c_double, 97.0_c_double, 76.0_c_double, 70.0_c_double, 69.0_c_double, 83.0_c_double, &
                           93.0_c_double, 115.0_c_double, 115.0_c_double, 115.0_c_double, 115.0_c_double, 115.0_c_double]
    volcanic(:, 1987, 5) = [ &
                           158.0_c_double, 158.0_c_double, 158.0_c_double, 158.0_c_double, 152.0_c_double, 148.0_c_double, &
                           118.0_c_double, 100.0_c_double, 92.0_c_double, 90.0_c_double, 102.0_c_double, 95.0_c_double, &
                           95.0_c_double, 91.0_c_double, 80.0_c_double, 65.0_c_double, 73.0_c_double, 82.0_c_double, &
                           93.0_c_double, 105.0_c_double, 105.0_c_double, 105.0_c_double, 105.0_c_double, 105.0_c_double]
    volcanic(:, 1987, 6) = [ &
                           151.0_c_double, 151.0_c_double, 151.0_c_double, 151.0_c_double, 153.0_c_double, 119.0_c_double, &
                           104.0_c_double, 90.0_c_double, 85.0_c_double, 86.0_c_double, 95.0_c_double, 91.0_c_double, &
                           89.0_c_double, 87.0_c_double, 91.0_c_double, 83.0_c_double, 95.0_c_double, 115.0_c_double, &
                           115.0_c_double, 142.0_c_double, 142.0_c_double, 142.0_c_double, 142.0_c_double, 142.0_c_double]
    volcanic(:, 1987, 7) = [ &
                           124.0_c_double, 124.0_c_double, 124.0_c_double, 124.0_c_double, 126.0_c_double, 108.0_c_double, &
                           89.0_c_double, 80.0_c_double, 79.0_c_double, 82.0_c_double, 90.0_c_double, 86.0_c_double, &
                           83.0_c_double, 87.0_c_double, 83.0_c_double, 88.0_c_double, 102.0_c_double, 114.0_c_double, &
                           118.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double]
    volcanic(:, 1987, 8) = [ &
                           132.0_c_double, 132.0_c_double, 129.0_c_double, 129.0_c_double, 130.0_c_double, 102.0_c_double, &
                           91.0_c_double, 81.0_c_double, 80.0_c_double, 83.0_c_double, 80.0_c_double, 85.0_c_double, &
                           87.0_c_double, 84.0_c_double, 85.0_c_double, 86.0_c_double, 109.0_c_double, 125.0_c_double, &
                           119.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double, 230.0_c_double]
    volcanic(:, 1987, 9) = [ &
                           149.0_c_double, 149.0_c_double, 149.0_c_double, 149.0_c_double, 149.0_c_double, 110.0_c_double, &
                           93.0_c_double, 82.0_c_double, 82.0_c_double, 83.0_c_double, 82.0_c_double, 88.0_c_double, &
                           85.0_c_double, 79.0_c_double, 71.0_c_double, 80.0_c_double, 100.0_c_double, 121.0_c_double, &
                           114.0_c_double, 180.0_c_double, 179.0_c_double, 179.0_c_double, 179.0_c_double, 179.0_c_double]
    volcanic(:, 1987, 10) = [ &
                            140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 140.0_c_double, 119.0_c_double, &
                            99.0_c_double, 81.0_c_double, 82.0_c_double, 76.0_c_double, 77.0_c_double, 86.0_c_double, &
                            86.0_c_double, 73.0_c_double, 68.0_c_double, 72.0_c_double, 102.0_c_double, 122.0_c_double, &
                            120.0_c_double, 86.0_c_double, 91.0_c_double, 82.0_c_double, 82.0_c_double, 82.0_c_double]
    volcanic(:, 1987, 11) = [ &
                            144.0_c_double, 144.0_c_double, 144.0_c_double, 144.0_c_double, 144.0_c_double, 125.0_c_double, &
                            111.0_c_double, 83.0_c_double, 70.0_c_double, 67.0_c_double, 74.0_c_double, 83.0_c_double, &
                            83.0_c_double, 68.0_c_double, 66.0_c_double, 74.0_c_double, 89.0_c_double, 104.0_c_double, &
                            109.0_c_double, 70.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double]
    volcanic(:, 1987, 12) = [ &
                            139.0_c_double, 139.0_c_double, 139.0_c_double, 139.0_c_double, 139.0_c_double, 125.0_c_double, &
                            115.0_c_double, 82.0_c_double, 63.0_c_double, 59.0_c_double, 68.0_c_double, 82.0_c_double, &
                            79.0_c_double, 72.0_c_double, 63.0_c_double, 65.0_c_double, 76.0_c_double, 102.0_c_double, &
                            99.0_c_double, 110.0_c_double, 114.0_c_double, 114.0_c_double, 114.0_c_double, 114.0_c_double]
    volcanic(:, 1988, 1) = [ &
                           139.0_c_double, 139.0_c_double, 139.0_c_double, 139.0_c_double, 139.0_c_double, 136.0_c_double, &
                           113.0_c_double, 80.0_c_double, 54.0_c_double, 57.0_c_double, 67.0_c_double, 80.0_c_double, &
                           75.0_c_double, 75.0_c_double, 61.0_c_double, 56.0_c_double, 63.0_c_double, 74.0_c_double, &
                           87.0_c_double, 114.0_c_double, 115.0_c_double, 115.0_c_double, 115.0_c_double, 115.0_c_double]
    volcanic(:, 1988, 2) = [ &
                           177.0_c_double, 177.0_c_double, 177.0_c_double, 177.0_c_double, 177.0_c_double, 135.0_c_double, &
                           123.0_c_double, 88.0_c_double, 52.0_c_double, 47.0_c_double, 66.0_c_double, 76.0_c_double, &
                           73.0_c_double, 64.0_c_double, 63.0_c_double, 60.0_c_double, 64.0_c_double, 72.0_c_double, &
                           81.0_c_double, 113.0_c_double, 111.0_c_double, 112.0_c_double, 112.0_c_double, 112.0_c_double]
    volcanic(:, 1988, 3) = [ &
                           127.0_c_double, 127.0_c_double, 127.0_c_double, 127.0_c_double, 126.0_c_double, 112.0_c_double, &
                           94.0_c_double, 66.0_c_double, 45.0_c_double, 41.0_c_double, 57.0_c_double, 74.0_c_double, &
                           73.0_c_double, 68.0_c_double, 64.0_c_double, 63.0_c_double, 66.0_c_double, 71.0_c_double, &
                           75.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double, 113.0_c_double]
    volcanic(:, 1988, 4) = [ &
                           122.0_c_double, 122.0_c_double, 122.0_c_double, 124.0_c_double, 129.0_c_double, 91.0_c_double, &
                           82.0_c_double, 61.0_c_double, 42.0_c_double, 44.0_c_double, 58.0_c_double, 66.0_c_double, &
                           68.0_c_double, 54.0_c_double, 60.0_c_double, 58.0_c_double, 62.0_c_double, 73.0_c_double, &
                           88.0_c_double, 108.0_c_double, 108.0_c_double, 108.0_c_double, 108.0_c_double, 108.0_c_double]
    volcanic(:, 1988, 5) = [ &
                           103.0_c_double, 103.0_c_double, 103.0_c_double, 103.0_c_double, 102.0_c_double, 84.0_c_double, &
                           74.0_c_double, 54.0_c_double, 41.0_c_double, 44.0_c_double, 55.0_c_double, 66.0_c_double, &
                           67.0_c_double, 63.0_c_double, 57.0_c_double, 56.0_c_double, 67.0_c_double, 82.0_c_double, &
                           94.0_c_double, 97.0_c_double, 97.0_c_double, 97.0_c_double, 97.0_c_double, 97.0_c_double]
    volcanic(:, 1988, 6) = [ &
                           81.0_c_double, 81.0_c_double, 81.0_c_double, 81.0_c_double, 83.0_c_double, 70.0_c_double, &
                           49.0_c_double, 46.0_c_double, 40.0_c_double, 44.0_c_double, 56.0_c_double, 65.0_c_double, &
                           67.0_c_double, 70.0_c_double, 61.0_c_double, 67.0_c_double, 79.0_c_double, 96.0_c_double, &
                           101.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double, 110.0_c_double]
    volcanic(:, 1988, 7) = [ &
                           68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 69.0_c_double, 54.0_c_double, &
                           46.0_c_double, 39.0_c_double, 40.0_c_double, 43.0_c_double, 57.0_c_double, 64.0_c_double, &
                           67.0_c_double, 65.0_c_double, 58.0_c_double, 58.0_c_double, 79.0_c_double, 98.0_c_double, &
                           104.0_c_double, 243.0_c_double, 243.0_c_double, 243.0_c_double, 243.0_c_double, 243.0_c_double]
    volcanic(:, 1988, 8) = [ &
                           77.0_c_double, 77.0_c_double, 74.0_c_double, 72.0_c_double, 73.0_c_double, 62.0_c_double, &
                           50.0_c_double, 42.0_c_double, 41.0_c_double, 45.0_c_double, 53.0_c_double, 65.0_c_double, &
                           68.0_c_double, 66.0_c_double, 58.0_c_double, 65.0_c_double, 90.0_c_double, 118.0_c_double, &
                           113.0_c_double, 378.0_c_double, 378.0_c_double, 378.0_c_double, 378.0_c_double, 378.0_c_double]
    volcanic(:, 1988, 9) = [ &
                           94.0_c_double, 94.0_c_double, 94.0_c_double, 94.0_c_double, 96.0_c_double, 65.0_c_double, &
                           54.0_c_double, 45.0_c_double, 43.0_c_double, 47.0_c_double, 57.0_c_double, 66.0_c_double, &
                           70.0_c_double, 61.0_c_double, 51.0_c_double, 56.0_c_double, 79.0_c_double, 94.0_c_double, &
                           104.0_c_double, 95.0_c_double, 95.0_c_double, 95.0_c_double, 95.0_c_double, 95.0_c_double]
    volcanic(:, 1988, 10) = [ &
                            90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 90.0_c_double, 67.0_c_double, &
                            59.0_c_double, 45.0_c_double, 41.0_c_double, 44.0_c_double, 53.0_c_double, 60.0_c_double, &
                            63.0_c_double, 62.0_c_double, 56.0_c_double, 57.0_c_double, 73.0_c_double, 100.0_c_double, &
                            105.0_c_double, 67.0_c_double, 63.0_c_double, 62.0_c_double, 62.0_c_double, 62.0_c_double]
    volcanic(:, 1988, 11) = [ &
                            88.0_c_double, 88.0_c_double, 88.0_c_double, 88.0_c_double, 88.0_c_double, 76.0_c_double, &
                            67.0_c_double, 50.0_c_double, 43.0_c_double, 45.0_c_double, 53.0_c_double, 59.0_c_double, &
                            63.0_c_double, 63.0_c_double, 56.0_c_double, 54.0_c_double, 65.0_c_double, 80.0_c_double, &
                            91.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double]
    volcanic(:, 1988, 12) = [ &
                            84.0_c_double, 84.0_c_double, 84.0_c_double, 84.0_c_double, 84.0_c_double, 82.0_c_double, &
                            79.0_c_double, 57.0_c_double, 46.0_c_double, 49.0_c_double, 50.0_c_double, 60.0_c_double, &
                            60.0_c_double, 65.0_c_double, 54.0_c_double, 51.0_c_double, 59.0_c_double, 70.0_c_double, &
                            86.0_c_double, 114.0_c_double, 112.0_c_double, 112.0_c_double, 112.0_c_double, 112.0_c_double]
    volcanic(:, 1989, 1) = [ &
                           160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 160.0_c_double, 88.0_c_double, &
                           77.0_c_double, 57.0_c_double, 41.0_c_double, 44.0_c_double, 49.0_c_double, 61.0_c_double, &
                           58.0_c_double, 67.0_c_double, 51.0_c_double, 49.0_c_double, 53.0_c_double, 63.0_c_double, &
                           76.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double, 100.0_c_double]
    volcanic(:, 1989, 2) = [ &
                           83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 83.0_c_double, 91.0_c_double, &
                           83.0_c_double, 61.0_c_double, 43.0_c_double, 42.0_c_double, 49.0_c_double, 53.0_c_double, &
                           54.0_c_double, 46.0_c_double, 51.0_c_double, 51.0_c_double, 54.0_c_double, 63.0_c_double, &
                           76.0_c_double, 98.0_c_double, 96.0_c_double, 96.0_c_double, 94.0_c_double, 94.0_c_double]
    volcanic(:, 1989, 3) = [ &
                           74.0_c_double, 74.0_c_double, 74.0_c_double, 73.0_c_double, 76.0_c_double, 73.0_c_double, &
                           63.0_c_double, 53.0_c_double, 37.0_c_double, 40.0_c_double, 47.0_c_double, 55.0_c_double, &
                           60.0_c_double, 57.0_c_double, 52.0_c_double, 53.0_c_double, 55.0_c_double, 64.0_c_double, &
                           75.0_c_double, 100.0_c_double, 98.0_c_double, 95.0_c_double, 95.0_c_double, 95.0_c_double]
    volcanic(:, 1989, 4) = [ &
                           79.0_c_double, 79.0_c_double, 79.0_c_double, 81.0_c_double, 82.0_c_double, 72.0_c_double, &
                           67.0_c_double, 49.0_c_double, 44.0_c_double, 42.0_c_double, 46.0_c_double, 51.0_c_double, &
                           54.0_c_double, 51.0_c_double, 48.0_c_double, 47.0_c_double, 49.0_c_double, 61.0_c_double, &
                           71.0_c_double, 93.0_c_double, 93.0_c_double, 93.0_c_double, 93.0_c_double, 93.0_c_double]
    volcanic(:, 1989, 5) = [ &
                           67.0_c_double, 67.0_c_double, 67.0_c_double, 67.0_c_double, 66.0_c_double, 61.0_c_double, &
                           57.0_c_double, 42.0_c_double, 38.0_c_double, 37.0_c_double, 44.0_c_double, 49.0_c_double, &
                           2.0_c_double, 12.0_c_double, 1.0_c_double, 22.0_c_double, 49.0_c_double, 68.0_c_double, &
                           79.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double, 102.0_c_double]
    volcanic(:, 1989, 6) = [ &
                           80.0_c_double, 80.0_c_double, 80.0_c_double, 80.0_c_double, 81.0_c_double, 56.0_c_double, &
                           48.0_c_double, 38.0_c_double, 36.0_c_double, 37.0_c_double, 43.0_c_double, 46.0_c_double, &
                           24.0_c_double, 55.0_c_double, 51.0_c_double, 49.0_c_double, 63.0_c_double, 76.0_c_double, &
                           79.0_c_double, 97.0_c_double, 97.0_c_double, 97.0_c_double, 97.0_c_double, 97.0_c_double]
    volcanic(:, 1989, 7) = [ &
                           80.0_c_double, 80.0_c_double, 80.0_c_double, 80.0_c_double, 78.0_c_double, 43.0_c_double, &
                           40.0_c_double, 34.0_c_double, 34.0_c_double, 37.0_c_double, 43.0_c_double, 44.0_c_double, &
                           46.0_c_double, 50.0_c_double, 49.0_c_double, 52.0_c_double, 65.0_c_double, 80.0_c_double, &
                           86.0_c_double, 203.0_c_double, 203.0_c_double, 203.0_c_double, 203.0_c_double, 203.0_c_double]
    volcanic(:, 1989, 8) = [ &
                           69.0_c_double, 69.0_c_double, 67.0_c_double, 65.0_c_double, 65.0_c_double, 42.0_c_double, &
                           42.0_c_double, 36.0_c_double, 38.0_c_double, 42.0_c_double, 37.0_c_double, 40.0_c_double, &
                           47.0_c_double, 50.0_c_double, 52.0_c_double, 57.0_c_double, 73.0_c_double, 89.0_c_double, &
                           90.0_c_double, 369.0_c_double, 369.0_c_double, 369.0_c_double, 369.0_c_double, 369.0_c_double]
    volcanic(:, 1989, 9) = [ &
                           71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 40.0_c_double, &
                           45.0_c_double, 39.0_c_double, 42.0_c_double, 46.0_c_double, 45.0_c_double, 43.0_c_double, &
                           42.0_c_double, 46.0_c_double, 46.0_c_double, 42.0_c_double, 53.0_c_double, 79.0_c_double, &
                           79.0_c_double, 161.0_c_double, 162.0_c_double, 162.0_c_double, 162.0_c_double, 162.0_c_double]
    volcanic(:, 1989, 10) = [ &
                            71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 71.0_c_double, 55.0_c_double, &
                            48.0_c_double, 40.0_c_double, 42.0_c_double, 43.0_c_double, 42.0_c_double, 41.0_c_double, &
                            41.0_c_double, 46.0_c_double, 48.0_c_double, 50.0_c_double, 65.0_c_double, 76.0_c_double, &
                            81.0_c_double, 63.0_c_double, 60.0_c_double, 58.0_c_double, 58.0_c_double, 58.0_c_double]
    volcanic(:, 1989, 11) = [ &
                            73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 64.0_c_double, &
                            57.0_c_double, 47.0_c_double, 42.0_c_double, 42.0_c_double, 43.0_c_double, 45.0_c_double, &
                            45.0_c_double, 47.0_c_double, 47.0_c_double, 48.0_c_double, 58.0_c_double, 63.0_c_double, &
                            75.0_c_double, 63.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double]
    volcanic(:, 1989, 12) = [ &
                            74.0_c_double, 74.0_c_double, 74.0_c_double, 74.0_c_double, 74.0_c_double, 73.0_c_double, &
                            71.0_c_double, 47.0_c_double, 42.0_c_double, 36.0_c_double, 36.0_c_double, 40.0_c_double, &
                            40.0_c_double, 44.0_c_double, 44.0_c_double, 43.0_c_double, 48.0_c_double, 56.0_c_double, &
                            68.0_c_double, 77.0_c_double, 77.0_c_double, 77.0_c_double, 77.0_c_double, 77.0_c_double]
    volcanic(:, 1990, 1) = [ &
                           157.0_c_double, 157.0_c_double, 157.0_c_double, 157.0_c_double, 157.0_c_double, 81.0_c_double, &
                           72.0_c_double, 57.0_c_double, 38.0_c_double, 35.0_c_double, 35.0_c_double, 34.0_c_double, &
                           36.0_c_double, 41.0_c_double, 41.0_c_double, 39.0_c_double, 40.0_c_double, 45.0_c_double, &
                           59.0_c_double, 74.0_c_double, 77.0_c_double, 77.0_c_double, 77.0_c_double, 77.0_c_double]
    volcanic(:, 1990, 2) = [ &
                           313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 313.0_c_double, 76.0_c_double, &
                           69.0_c_double, 56.0_c_double, 41.0_c_double, 33.0_c_double, 31.0_c_double, 33.0_c_double, &
                           49.0_c_double, 28.0_c_double, 58.0_c_double, 44.0_c_double, 42.0_c_double, 49.0_c_double, &
                           59.0_c_double, 75.0_c_double, 77.0_c_double, 77.0_c_double, 77.0_c_double, 77.0_c_double]
    volcanic(:, 1990, 3) = [ &
                           77.0_c_double, 77.0_c_double, 77.0_c_double, 67.0_c_double, 68.0_c_double, 68.0_c_double, &
                           59.0_c_double, 48.0_c_double, 37.0_c_double, 33.0_c_double, 41.0_c_double, 58.0_c_double, &
                           70.0_c_double, 107.0_c_double, 74.0_c_double, 48.0_c_double, 45.0_c_double, 52.0_c_double, &
                           59.0_c_double, 84.0_c_double, 82.0_c_double, 82.0_c_double, 82.0_c_double, 82.0_c_double]
    volcanic(:, 1990, 4) = [ &
                           77.0_c_double, 77.0_c_double, 77.0_c_double, 75.0_c_double, 75.0_c_double, 71.0_c_double, &
                           64.0_c_double, 50.0_c_double, 39.0_c_double, 7.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 61.0_c_double, 78.0_c_double, 56.0_c_double, 25.0_c_double, 28.0_c_double, &
                           49.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double]
    volcanic(:, 1990, 5) = [ &
                           74.0_c_double, 74.0_c_double, 74.0_c_double, 74.0_c_double, 72.0_c_double, 55.0_c_double, &
                           50.0_c_double, 39.0_c_double, 36.0_c_double, 37.0_c_double, 39.0_c_double, 39.0_c_double, &
                           1.0_c_double, 13.0_c_double, 22.0_c_double, 28.0_c_double, 32.0_c_double, 75.0_c_double, &
                           84.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double, 65.0_c_double]
    volcanic(:, 1990, 6) = [ &
                           74.0_c_double, 74.0_c_double, 74.0_c_double, 74.0_c_double, 74.0_c_double, 51.0_c_double, &
                           40.0_c_double, 35.0_c_double, 34.0_c_double, 37.0_c_double, 41.0_c_double, 46.0_c_double, &
                           32.0_c_double, 72.0_c_double, 61.0_c_double, 56.0_c_double, 76.0_c_double, 91.0_c_double, &
                           94.0_c_double, 93.0_c_double, 93.0_c_double, 93.0_c_double, 93.0_c_double, 93.0_c_double]
    volcanic(:, 1990, 7) = [ &
                           68.0_c_double, 68.0_c_double, 68.0_c_double, 68.0_c_double, 65.0_c_double, 62.0_c_double, &
                           36.0_c_double, 30.0_c_double, 33.0_c_double, 38.0_c_double, 43.0_c_double, 53.0_c_double, &
                           64.0_c_double, 64.0_c_double, 55.0_c_double, 62.0_c_double, 82.0_c_double, 95.0_c_double, &
                           105.0_c_double, 209.0_c_double, 209.0_c_double, 209.0_c_double, 209.0_c_double, 209.0_c_double]
    volcanic(:, 1990, 8) = [ &
                           63.0_c_double, 63.0_c_double, 63.0_c_double, 62.0_c_double, 61.0_c_double, 60.0_c_double, &
                           40.0_c_double, 34.0_c_double, 35.0_c_double, 40.0_c_double, 47.0_c_double, 56.0_c_double, &
                           69.0_c_double, 66.0_c_double, 60.0_c_double, 62.0_c_double, 84.0_c_double, 101.0_c_double, &
                           107.0_c_double, 203.0_c_double, 203.0_c_double, 203.0_c_double, 203.0_c_double, 203.0_c_double]
    volcanic(:, 1990, 9) = [ &
                           64.0_c_double, 64.0_c_double, 64.0_c_double, 64.0_c_double, 66.0_c_double, 58.0_c_double, &
                           44.0_c_double, 37.0_c_double, 38.0_c_double, 42.0_c_double, 51.0_c_double, 57.0_c_double, &
                           66.0_c_double, 58.0_c_double, 47.0_c_double, 51.0_c_double, 64.0_c_double, 87.0_c_double, &
                           92.0_c_double, 162.0_c_double, 171.0_c_double, 171.0_c_double, 171.0_c_double, 171.0_c_double]
    volcanic(:, 1990, 10) = [ &
                            73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 57.0_c_double, &
                            47.0_c_double, 40.0_c_double, 38.0_c_double, 40.0_c_double, 47.0_c_double, 57.0_c_double, &
                            63.0_c_double, 57.0_c_double, 49.0_c_double, 55.0_c_double, 68.0_c_double, 86.0_c_double, &
                            94.0_c_double, 52.0_c_double, 54.0_c_double, 50.0_c_double, 50.0_c_double, 50.0_c_double]
    volcanic(:, 1990, 11) = [ &
                            73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 73.0_c_double, 60.0_c_double, &
                            55.0_c_double, 42.0_c_double, 39.0_c_double, 43.0_c_double, 48.0_c_double, 59.0_c_double, &
                            65.0_c_double, 58.0_c_double, 51.0_c_double, 54.0_c_double, 65.0_c_double, 78.0_c_double, &
                            87.0_c_double, 61.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double, 66.0_c_double]
    volcanic(:, 1990, 12) = [ &
                            79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 79.0_c_double, 67.0_c_double, &
                            62.0_c_double, 48.0_c_double, 35.0_c_double, 37.0_c_double, 39.0_c_double, 59.0_c_double, &
                            65.0_c_double, 58.0_c_double, 51.0_c_double, 48.0_c_double, 51.0_c_double, 66.0_c_double, &
                            81.0_c_double, 81.0_c_double, 82.0_c_double, 82.0_c_double, 82.0_c_double, 82.0_c_double]
    volcanic(:, 1991, 1) = [ &
                           102.0_c_double, 103.0_c_double, 110.0_c_double, 115.0_c_double, 87.0_c_double, 66.0_c_double, &
                           64.0_c_double, 52.0_c_double, 38.0_c_double, 36.0_c_double, 43.0_c_double, 51.0_c_double, &
                           53.0_c_double, 50.0_c_double, 44.0_c_double, 47.0_c_double, 49.0_c_double, 56.0_c_double, &
                           71.0_c_double, 98.0_c_double, 91.0_c_double, 83.0_c_double, 89.0_c_double, 89.0_c_double]
    volcanic(:, 1991, 2) = [ &
                           85.0_c_double, 86.0_c_double, 83.0_c_double, 75.0_c_double, 69.0_c_double, 68.0_c_double, &
                           65.0_c_double, 54.0_c_double, 39.0_c_double, 36.0_c_double, 43.0_c_double, 49.0_c_double, &
                           48.0_c_double, 45.0_c_double, 44.0_c_double, 44.0_c_double, 49.0_c_double, 56.0_c_double, &
                           67.0_c_double, 91.0_c_double, 101.0_c_double, 90.0_c_double, 85.0_c_double, 84.0_c_double]
    volcanic(:, 1991, 3) = [ &
                           73.0_c_double, 73.0_c_double, 72.0_c_double, 68.0_c_double, 65.0_c_double, 59.0_c_double, &
                           51.0_c_double, 42.0_c_double, 34.0_c_double, 34.0_c_double, 41.0_c_double, 49.0_c_double, &
                           51.0_c_double, 49.0_c_double, 47.0_c_double, 48.0_c_double, 51.0_c_double, 58.0_c_double, &
                           68.0_c_double, 83.0_c_double, 111.0_c_double, 109.0_c_double, 92.0_c_double, 90.0_c_double]
    volcanic(:, 1991, 4) = [ &
                           77.0_c_double, 76.0_c_double, 71.0_c_double, 70.0_c_double, 66.0_c_double, 59.0_c_double, &
                           52.0_c_double, 43.0_c_double, 36.0_c_double, 34.0_c_double, 38.0_c_double, 43.0_c_double, &
                           45.0_c_double, 44.0_c_double, 43.0_c_double, 43.0_c_double, 47.0_c_double, 55.0_c_double, &
                           65.0_c_double, 78.0_c_double, 105.0_c_double, 105.0_c_double, 90.0_c_double, 88.0_c_double]
    volcanic(:, 1991, 5) = [ &
                           118.0_c_double, 114.0_c_double, 63.0_c_double, 59.0_c_double, 57.0_c_double, 52.0_c_double, &
                           45.0_c_double, 38.0_c_double, 33.0_c_double, 33.0_c_double, 40.0_c_double, 47.0_c_double, &
                           47.0_c_double, 47.0_c_double, 44.0_c_double, 48.0_c_double, 56.0_c_double, 64.0_c_double, &
                           68.0_c_double, 87.0_c_double, 100.0_c_double, 101.0_c_double, 86.0_c_double, 84.0_c_double]
    volcanic(:, 1991, 6) = [ &
                           168.0_c_double, 160.0_c_double, 66.0_c_double, 57.0_c_double, 55.0_c_double, 52.0_c_double, &
                           51.0_c_double, 45.0_c_double, 59.0_c_double, 164.0_c_double, 378.0_c_double, 720.0_c_double, &
                           558.0_c_double, 175.0_c_double, 60.0_c_double, 51.0_c_double, 63.0_c_double, 70.0_c_double, &
                           74.0_c_double, 98.0_c_double, 99.0_c_double, 110.0_c_double, 97.0_c_double, 95.0_c_double]
    volcanic(:, 1991, 7) = [ &
                           228.0_c_double, 224.0_c_double, 161.0_c_double, 138.0_c_double, 126.0_c_double, 118.0_c_double, &
                           103.0_c_double, 88.0_c_double, 213.0_c_double, 498.0_c_double, 673.0_c_double, 1202.0_c_double, &
                           1218.0_c_double, 780.0_c_double, 146.0_c_double, 78.0_c_double, 93.0_c_double, 92.0_c_double, &
                           89.0_c_double, 134.0_c_double, 151.0_c_double, 171.0_c_double, 111.0_c_double, 105.0_c_double]
    volcanic(:, 1991, 8) = [ &
                           342.0_c_double, 338.0_c_double, 274.0_c_double, 235.0_c_double, 225.0_c_double, 216.0_c_double, &
                           193.0_c_double, 200.0_c_double, 480.0_c_double, 956.0_c_double, 1083.0_c_double, 1729.0_c_double, &
                           1938.0_c_double, 1826.0_c_double, 721.0_c_double, 332.0_c_double, 329.0_c_double, 272.0_c_double, &
                           191.0_c_double, 152.0_c_double, 168.0_c_double, 183.0_c_double, 121.0_c_double, 115.0_c_double]
    volcanic(:, 1991, 9) = [ &
                           366.0_c_double, 366.0_c_double, 368.0_c_double, 330.0_c_double, 336.0_c_double, 325.0_c_double, &
                           312.0_c_double, 398.0_c_double, 883.0_c_double, 1489.0_c_double, 1634.0_c_double, 2008.0_c_double, &
                           2263.0_c_double, 2023.0_c_double, 990.0_c_double, 543.0_c_double, 571.0_c_double, 565.0_c_double, &
                           450.0_c_double, 217.0_c_double, 186.0_c_double, 256.0_c_double, 157.0_c_double, 149.0_c_double]
    volcanic(:, 1991, 10) = [ &
                            547.0_c_double, 559.0_c_double, 748.0_c_double, 531.0_c_double, 515.0_c_double, 529.0_c_double, &
                            552.0_c_double, 613.0_c_double, 1068.0_c_double, 1773.0_c_double, 1947.0_c_double, 2163.0_c_double, &
                            2292.0_c_double, 2090.0_c_double, 1168.0_c_double, 780.0_c_double, 900.0_c_double, 1019.0_c_double, &
                            871.0_c_double, 609.0_c_double, 547.0_c_double, 442.0_c_double, 206.0_c_double, 189.0_c_double]
    volcanic(:, 1991, 11) = [ &
                            715.0_c_double, 732.0_c_double, 1010.0_c_double, 693.0_c_double, 685.0_c_double, 768.0_c_double, &
                            804.0_c_double, 777.0_c_double, 1125.0_c_double, 1716.0_c_double, 1959.0_c_double, 2124.0_c_double, &
                            2301.0_c_double, 2558.0_c_double, 1457.0_c_double, 826.0_c_double, 1020.0_c_double, 1242.0_c_double, &
                            1268.0_c_double, 1240.0_c_double, 1057.0_c_double, 944.0_c_double, 446.0_c_double, 406.0_c_double]
    volcanic(:, 1991, 12) = [ &
                            833.0_c_double, 854.0_c_double, 1201.0_c_double, 1085.0_c_double, 1239.0_c_double, 1635.0_c_double, &
                            1578.0_c_double, 1356.0_c_double, 1226.0_c_double, 1606.0_c_double, 1612.0_c_double, 1748.0_c_double, &
                            1977.0_c_double, 2073.0_c_double, 1161.0_c_double, 720.0_c_double, 785.0_c_double, 924.0_c_double, &
                            1173.0_c_double, 1413.0_c_double, 1220.0_c_double, 1210.0_c_double, 1236.0_c_double, 1236.0_c_double]
    volcanic(:, 1992, 1) = [ &
                           924.0_c_double, 949.0_c_double, 1358.0_c_double, 1392.0_c_double, 1564.0_c_double, 1731.0_c_double, &
                           1761.0_c_double, 1665.0_c_double, 1330.0_c_double, 1539.0_c_double, 1837.0_c_double, 1873.0_c_double, &
                           2006.0_c_double, 2067.0_c_double, 1269.0_c_double, 708.0_c_double, 717.0_c_double, 854.0_c_double, &
                           1158.0_c_double, 1423.0_c_double, 1462.0_c_double, 1600.0_c_double, 1668.0_c_double, 1668.0_c_double]
    volcanic(:, 1992, 2) = [ &
                           1003.0_c_double, 1031.0_c_double, 1454.0_c_double, 1573.0_c_double, 1677.0_c_double, 1801.0_c_double, &
                           1837.0_c_double, 1788.0_c_double, 1444.0_c_double, 1520.0_c_double, 1846.0_c_double, 1880.0_c_double, &
                           1863.0_c_double, 1911.0_c_double, 1213.0_c_double, 740.0_c_double, 729.0_c_double, 871.0_c_double, &
                           1162.0_c_double, 1418.0_c_double, 1553.0_c_double, 1559.0_c_double, 1492.0_c_double, 1489.0_c_double]
    volcanic(:, 1992, 3) = [ &
                           1062.0_c_double, 1089.0_c_double, 1449.0_c_double, 1524.0_c_double, 1571.0_c_double, 1674.0_c_double, &
                           1693.0_c_double, 1581.0_c_double, 1370.0_c_double, 1485.0_c_double, 1705.0_c_double, 1760.0_c_double, &
                           1765.0_c_double, 1699.0_c_double, 1224.0_c_double, 826.0_c_double, 758.0_c_double, 886.0_c_double, &
                           1134.0_c_double, 1350.0_c_double, 1602.0_c_double, 1635.0_c_double, 1472.0_c_double, 1459.0_c_double]
    volcanic(:, 1992, 4) = [ &
                           1120.0_c_double, 1145.0_c_double, 1468.0_c_double, 1496.0_c_double, 1461.0_c_double, 1480.0_c_double, &
                           1465.0_c_double, 1327.0_c_double, 1285.0_c_double, 1427.0_c_double, 1556.0_c_double, 1637.0_c_double, &
                           1681.0_c_double, 1672.0_c_double, 1310.0_c_double, 911.0_c_double, 885.0_c_double, 1025.0_c_double, &
                           1242.0_c_double, 1361.0_c_double, 1598.0_c_double, 1710.0_c_double, 1442.0_c_double, 1420.0_c_double]
    volcanic(:, 1992, 5) = [ &
                           1179.0_c_double, 1193.0_c_double, 1392.0_c_double, 1422.0_c_double, 1428.0_c_double, 1404.0_c_double, &
                           1365.0_c_double, 1298.0_c_double, 1256.0_c_double, 1435.0_c_double, 1560.0_c_double, 1624.0_c_double, &
                           1613.0_c_double, 1566.0_c_double, 1214.0_c_double, 1035.0_c_double, 1117.0_c_double, 1238.0_c_double, &
                           1294.0_c_double, 1369.0_c_double, 1472.0_c_double, 1527.0_c_double, 1378.0_c_double, 1366.0_c_double]
    volcanic(:, 1992, 6) = [ &
                           1233.0_c_double, 1241.0_c_double, 1334.0_c_double, 1334.0_c_double, 1304.0_c_double, 1237.0_c_double, &
                           1110.0_c_double, 971.0_c_double, 995.0_c_double, 1160.0_c_double, 1294.0_c_double, 1394.0_c_double, &
                           1414.0_c_double, 1383.0_c_double, 1149.0_c_double, 1081.0_c_double, 1295.0_c_double, 1464.0_c_double, &
                           1436.0_c_double, 1395.0_c_double, 1479.0_c_double, 1454.0_c_double, 1323.0_c_double, 1316.0_c_double]
    volcanic(:, 1992, 7) = [ &
                           1269.0_c_double, 1270.0_c_double, 1292.0_c_double, 1299.0_c_double, 1180.0_c_double, 1117.0_c_double, &
                           957.0_c_double, 836.0_c_double, 942.0_c_double, 1175.0_c_double, 1369.0_c_double, 1415.0_c_double, &
                           1306.0_c_double, 1257.0_c_double, 1099.0_c_double, 1067.0_c_double, 1317.0_c_double, 1532.0_c_double, &
                           1533.0_c_double, 1366.0_c_double, 1427.0_c_double, 1347.0_c_double, 1272.0_c_double, 1270.0_c_double]
    volcanic(:, 1992, 8) = [ &
                           1272.0_c_double, 1271.0_c_double, 1251.0_c_double, 1261.0_c_double, 1203.0_c_double, 1069.0_c_double, &
                           956.0_c_double, 828.0_c_double, 912.0_c_double, 1059.0_c_double, 1230.0_c_double, 1096.0_c_double, &
                           1031.0_c_double, 1098.0_c_double, 1098.0_c_double, 1078.0_c_double, 1368.0_c_double, 1532.0_c_double, &
                           1418.0_c_double, 1263.0_c_double, 1255.0_c_double, 1177.0_c_double, 1212.0_c_double, 1216.0_c_double]
    volcanic(:, 1992, 9) = [ &
                           1254.0_c_double, 1253.0_c_double, 1233.0_c_double, 1231.0_c_double, 1167.0_c_double, 1041.0_c_double, &
                           913.0_c_double, 779.0_c_double, 864.0_c_double, 1066.0_c_double, 1179.0_c_double, 969.0_c_double, &
                           888.0_c_double, 980.0_c_double, 965.0_c_double, 933.0_c_double, 1185.0_c_double, 1338.0_c_double, &
                           1283.0_c_double, 1175.0_c_double, 1037.0_c_double, 1023.0_c_double, 1156.0_c_double, 1166.0_c_double]
    volcanic(:, 1992, 10) = [ &
                            1193.0_c_double, 1193.0_c_double, 1183.0_c_double, 1161.0_c_double, 1147.0_c_double, 1085.0_c_double, &
                            942.0_c_double, 796.0_c_double, 829.0_c_double, 994.0_c_double, 1012.0_c_double, 889.0_c_double, &
                            824.0_c_double, 866.0_c_double, 832.0_c_double, 871.0_c_double, 1070.0_c_double, 1208.0_c_double, &
                            1228.0_c_double, 1113.0_c_double, 1018.0_c_double, 1012.0_c_double, 1111.0_c_double, 1119.0_c_double]
    volcanic(:, 1992, 11) = [ &
                            1117.0_c_double, 1117.0_c_double, 1115.0_c_double, 1120.0_c_double, 1132.0_c_double, 1100.0_c_double, &
                            979.0_c_double, 820.0_c_double, 721.0_c_double, 783.0_c_double, 884.0_c_double, 862.0_c_double, &
                            785.0_c_double, 821.0_c_double, 797.0_c_double, 803.0_c_double, 935.0_c_double, 1063.0_c_double, &
                            1138.0_c_double, 1136.0_c_double, 1039.0_c_double, 989.0_c_double, 1060.0_c_double, 1066.0_c_double]
    volcanic(:, 1992, 12) = [ &
                            1044.0_c_double, 1044.0_c_double, 1050.0_c_double, 1056.0_c_double, 1143.0_c_double, 1081.0_c_double, &
                            984.0_c_double, 833.0_c_double, 663.0_c_double, 620.0_c_double, 667.0_c_double, 660.0_c_double, &
                            647.0_c_double, 663.0_c_double, 580.0_c_double, 577.0_c_double, 686.0_c_double, 865.0_c_double, &
                            1027.0_c_double, 1091.0_c_double, 1000.0_c_double, 995.0_c_double, 1015.0_c_double, 1017.0_c_double]
    volcanic(:, 1993, 1) = [ &
                           981.0_c_double, 982.0_c_double, 995.0_c_double, 996.0_c_double, 1165.0_c_double, 1123.0_c_double, &
                           1003.0_c_double, 823.0_c_double, 601.0_c_double, 520.0_c_double, 552.0_c_double, 610.0_c_double, &
                           628.0_c_double, 599.0_c_double, 535.0_c_double, 533.0_c_double, 577.0_c_double, 751.0_c_double, &
                           915.0_c_double, 1026.0_c_double, 1041.0_c_double, 1013.0_c_double, 995.0_c_double, 994.0_c_double]
    volcanic(:, 1993, 2) = [ &
                           904.0_c_double, 906.0_c_double, 926.0_c_double, 926.0_c_double, 985.0_c_double, 1002.0_c_double, &
                           927.0_c_double, 690.0_c_double, 482.0_c_double, 430.0_c_double, 496.0_c_double, 572.0_c_double, &
                           563.0_c_double, 521.0_c_double, 462.0_c_double, 478.0_c_double, 519.0_c_double, 638.0_c_double, &
                           789.0_c_double, 907.0_c_double, 1006.0_c_double, 1054.0_c_double, 1042.0_c_double, 1041.0_c_double]
    volcanic(:, 1993, 3) = [ &
                           827.0_c_double, 831.0_c_double, 883.0_c_double, 887.0_c_double, 902.0_c_double, 886.0_c_double, &
                           798.0_c_double, 610.0_c_double, 427.0_c_double, 388.0_c_double, 448.0_c_double, 518.0_c_double, &
                           521.0_c_double, 485.0_c_double, 437.0_c_double, 443.0_c_double, 483.0_c_double, 607.0_c_double, &
                           758.0_c_double, 853.0_c_double, 913.0_c_double, 1021.0_c_double, 1054.0_c_double, 1052.0_c_double]
    volcanic(:, 1993, 4) = [ &
                           749.0_c_double, 754.0_c_double, 817.0_c_double, 825.0_c_double, 833.0_c_double, 811.0_c_double, &
                           725.0_c_double, 530.0_c_double, 383.0_c_double, 347.0_c_double, 407.0_c_double, 474.0_c_double, &
                           465.0_c_double, 431.0_c_double, 410.0_c_double, 412.0_c_double, 466.0_c_double, 589.0_c_double, &
                           721.0_c_double, 808.0_c_double, 839.0_c_double, 934.0_c_double, 1006.0_c_double, 1005.0_c_double]
    volcanic(:, 1993, 5) = [ &
                           664.0_c_double, 664.0_c_double, 672.0_c_double, 704.0_c_double, 717.0_c_double, 702.0_c_double, &
                           603.0_c_double, 436.0_c_double, 335.0_c_double, 323.0_c_double, 393.0_c_double, 457.0_c_double, &
                           447.0_c_double, 424.0_c_double, 398.0_c_double, 418.0_c_double, 527.0_c_double, 649.0_c_double, &
                           713.0_c_double, 744.0_c_double, 811.0_c_double, 881.0_c_double, 945.0_c_double, 945.0_c_double]
    volcanic(:, 1993, 6) = [ &
                           579.0_c_double, 584.0_c_double, 641.0_c_double, 656.0_c_double, 644.0_c_double, 587.0_c_double, &
                           478.0_c_double, 337.0_c_double, 285.0_c_double, 300.0_c_double, 348.0_c_double, 388.0_c_double, &
                           402.0_c_double, 409.0_c_double, 356.0_c_double, 389.0_c_double, 527.0_c_double, 674.0_c_double, &
                           728.0_c_double, 752.0_c_double, 780.0_c_double, 826.0_c_double, 883.0_c_double, 884.0_c_double]
    volcanic(:, 1993, 7) = [ &
                           508.0_c_double, 509.0_c_double, 521.0_c_double, 512.0_c_double, 506.0_c_double, 470.0_c_double, &
                           351.0_c_double, 275.0_c_double, 271.0_c_double, 290.0_c_double, 332.0_c_double, 369.0_c_double, &
                           385.0_c_double, 372.0_c_double, 338.0_c_double, 375.0_c_double, 523.0_c_double, 704.0_c_double, &
                           753.0_c_double, 757.0_c_double, 747.0_c_double, 771.0_c_double, 825.0_c_double, 826.0_c_double]
    volcanic(:, 1993, 8) = [ &
                           505.0_c_double, 505.0_c_double, 506.0_c_double, 497.0_c_double, 466.0_c_double, 416.0_c_double, &
                           331.0_c_double, 270.0_c_double, 262.0_c_double, 296.0_c_double, 357.0_c_double, 361.0_c_double, &
                           378.0_c_double, 380.0_c_double, 322.0_c_double, 333.0_c_double, 463.0_c_double, 654.0_c_double, &
                           720.0_c_double, 719.0_c_double, 696.0_c_double, 711.0_c_double, 756.0_c_double, 758.0_c_double]
    volcanic(:, 1993, 9) = [ &
                           509.0_c_double, 509.0_c_double, 506.0_c_double, 459.0_c_double, 423.0_c_double, 372.0_c_double, &
                           305.0_c_double, 258.0_c_double, 260.0_c_double, 299.0_c_double, 345.0_c_double, 357.0_c_double, &
                           348.0_c_double, 323.0_c_double, 296.0_c_double, 319.0_c_double, 421.0_c_double, 554.0_c_double, &
                           638.0_c_double, 660.0_c_double, 658.0_c_double, 667.0_c_double, 679.0_c_double, 679.0_c_double]
    volcanic(:, 1993, 10) = [ &
                            488.0_c_double, 489.0_c_double, 488.0_c_double, 432.0_c_double, 407.0_c_double, 373.0_c_double, &
                            315.0_c_double, 254.0_c_double, 244.0_c_double, 263.0_c_double, 303.0_c_double, 343.0_c_double, &
                            344.0_c_double, 322.0_c_double, 292.0_c_double, 310.0_c_double, 409.0_c_double, 521.0_c_double, &
                            599.0_c_double, 614.0_c_double, 617.0_c_double, 624.0_c_double, 595.0_c_double, 593.0_c_double]
    volcanic(:, 1993, 11) = [ &
                            467.0_c_double, 467.0_c_double, 470.0_c_double, 422.0_c_double, 402.0_c_double, 381.0_c_double, &
                            325.0_c_double, 260.0_c_double, 230.0_c_double, 237.0_c_double, 258.0_c_double, 301.0_c_double, &
                            342.0_c_double, 319.0_c_double, 284.0_c_double, 295.0_c_double, 373.0_c_double, 450.0_c_double, &
                            537.0_c_double, 538.0_c_double, 532.0_c_double, 535.0_c_double, 539.0_c_double, 539.0_c_double]
    volcanic(:, 1993, 12) = [ &
                            446.0_c_double, 446.0_c_double, 452.0_c_double, 405.0_c_double, 395.0_c_double, 382.0_c_double, &
                            342.0_c_double, 255.0_c_double, 212.0_c_double, 215.0_c_double, 239.0_c_double, 265.0_c_double, &
                            273.0_c_double, 261.0_c_double, 236.0_c_double, 232.0_c_double, 263.0_c_double, 349.0_c_double, &
                            455.0_c_double, 503.0_c_double, 537.0_c_double, 537.0_c_double, 512.0_c_double, 510.0_c_double]
    volcanic(:, 1994, 1) = [ &
                           422.0_c_double, 422.0_c_double, 431.0_c_double, 384.0_c_double, 384.0_c_double, 384.0_c_double, &
                           341.0_c_double, 254.0_c_double, 193.0_c_double, 190.0_c_double, 216.0_c_double, 242.0_c_double, &
                           260.0_c_double, 250.0_c_double, 219.0_c_double, 206.0_c_double, 223.0_c_double, 287.0_c_double, &
                           376.0_c_double, 435.0_c_double, 450.0_c_double, 461.0_c_double, 454.0_c_double, 453.0_c_double]
    volcanic(:, 1994, 2) = [ &
                           392.0_c_double, 392.0_c_double, 405.0_c_double, 375.0_c_double, 369.0_c_double, 368.0_c_double, &
                           328.0_c_double, 241.0_c_double, 167.0_c_double, 172.0_c_double, 208.0_c_double, 220.0_c_double, &
                           248.0_c_double, 234.0_c_double, 203.0_c_double, 188.0_c_double, 204.0_c_double, 252.0_c_double, &
                           325.0_c_double, 390.0_c_double, 422.0_c_double, 454.0_c_double, 470.0_c_double, 471.0_c_double]
    volcanic(:, 1994, 3) = [ &
                           360.0_c_double, 361.0_c_double, 379.0_c_double, 382.0_c_double, 363.0_c_double, 323.0_c_double, &
                           267.0_c_double, 202.0_c_double, 153.0_c_double, 151.0_c_double, 175.0_c_double, 204.0_c_double, &
                           215.0_c_double, 206.0_c_double, 182.0_c_double, 166.0_c_double, 180.0_c_double, 226.0_c_double, &
                           286.0_c_double, 343.0_c_double, 381.0_c_double, 449.0_c_double, 475.0_c_double, 476.0_c_double]
    volcanic(:, 1994, 4) = [ &
                           330.0_c_double, 330.0_c_double, 341.0_c_double, 350.0_c_double, 332.0_c_double, 303.0_c_double, &
                           258.0_c_double, 195.0_c_double, 149.0_c_double, 145.0_c_double, 160.0_c_double, 178.0_c_double, &
                           180.0_c_double, 175.0_c_double, 157.0_c_double, 150.0_c_double, 173.0_c_double, 219.0_c_double, &
                           267.0_c_double, 307.0_c_double, 338.0_c_double, 419.0_c_double, 447.0_c_double, 448.0_c_double]
    volcanic(:, 1994, 5) = [ &
                           323.0_c_double, 322.0_c_double, 316.0_c_double, 299.0_c_double, 264.0_c_double, 244.0_c_double, &
                           211.0_c_double, 167.0_c_double, 135.0_c_double, 138.0_c_double, 155.0_c_double, 168.0_c_double, &
                           170.0_c_double, 174.0_c_double, 158.0_c_double, 156.0_c_double, 195.0_c_double, 249.0_c_double, &
                           270.0_c_double, 283.0_c_double, 323.0_c_double, 386.0_c_double, 414.0_c_double, 414.0_c_double]
    volcanic(:, 1994, 6) = [ &
                           270.0_c_double, 269.0_c_double, 257.0_c_double, 253.0_c_double, 227.0_c_double, 195.0_c_double, &
                           155.0_c_double, 128.0_c_double, 122.0_c_double, 137.0_c_double, 153.0_c_double, 145.0_c_double, &
                           145.0_c_double, 159.0_c_double, 144.0_c_double, 142.0_c_double, 186.0_c_double, 253.0_c_double, &
                           280.0_c_double, 281.0_c_double, 299.0_c_double, 354.0_c_double, 383.0_c_double, 383.0_c_double]
    volcanic(:, 1994, 7) = [ &
                           205.0_c_double, 205.0_c_double, 208.0_c_double, 206.0_c_double, 196.0_c_double, 168.0_c_double, &
                           126.0_c_double, 109.0_c_double, 116.0_c_double, 137.0_c_double, 159.0_c_double, 150.0_c_double, &
                           146.0_c_double, 171.0_c_double, 148.0_c_double, 150.0_c_double, 196.0_c_double, 265.0_c_double, &
                           291.0_c_double, 280.0_c_double, 275.0_c_double, 319.0_c_double, 349.0_c_double, 349.0_c_double]
    volcanic(:, 1994, 8) = [ &
                           211.0_c_double, 211.0_c_double, 205.0_c_double, 195.0_c_double, 184.0_c_double, 162.0_c_double, &
                           125.0_c_double, 110.0_c_double, 119.0_c_double, 141.0_c_double, 184.0_c_double, 154.0_c_double, &
                           142.0_c_double, 151.0_c_double, 142.0_c_double, 136.0_c_double, 179.0_c_double, 240.0_c_double, &
                           267.0_c_double, 266.0_c_double, 254.0_c_double, 282.0_c_double, 313.0_c_double, 313.0_c_double]
    volcanic(:, 1994, 9) = [ &
                           218.0_c_double, 218.0_c_double, 209.0_c_double, 186.0_c_double, 175.0_c_double, 149.0_c_double, &
                           124.0_c_double, 107.0_c_double, 113.0_c_double, 135.0_c_double, 159.0_c_double, 137.0_c_double, &
                           133.0_c_double, 131.0_c_double, 125.0_c_double, 131.0_c_double, 174.0_c_double, 223.0_c_double, &
                           250.0_c_double, 249.0_c_double, 239.0_c_double, 256.0_c_double, 273.0_c_double, 273.0_c_double]
    volcanic(:, 1994, 10) = [ &
                            250.0_c_double, 250.0_c_double, 240.0_c_double, 182.0_c_double, 173.0_c_double, 159.0_c_double, &
                            129.0_c_double, 111.0_c_double, 109.0_c_double, 125.0_c_double, 154.0_c_double, 154.0_c_double, &
                            154.0_c_double, 146.0_c_double, 125.0_c_double, 134.0_c_double, 185.0_c_double, 239.0_c_double, &
                            256.0_c_double, 246.0_c_double, 238.0_c_double, 238.0_c_double, 231.0_c_double, 231.0_c_double]
    volcanic(:, 1994, 11) = [ &
                            294.0_c_double, 293.0_c_double, 285.0_c_double, 198.0_c_double, 188.0_c_double, 189.0_c_double, &
                            160.0_c_double, 122.0_c_double, 106.0_c_double, 110.0_c_double, 123.0_c_double, 134.0_c_double, &
                            149.0_c_double, 140.0_c_double, 118.0_c_double, 118.0_c_double, 152.0_c_double, 198.0_c_double, &
                            232.0_c_double, 237.0_c_double, 238.0_c_double, 228.0_c_double, 219.0_c_double, 219.0_c_double]
    volcanic(:, 1994, 12) = [ &
                            367.0_c_double, 367.0_c_double, 363.0_c_double, 309.0_c_double, 261.0_c_double, 201.0_c_double, &
                            177.0_c_double, 126.0_c_double, 95.0_c_double, 90.0_c_double, 100.0_c_double, 124.0_c_double, &
                            148.0_c_double, 132.0_c_double, 114.0_c_double, 107.0_c_double, 127.0_c_double, 164.0_c_double, &
                            211.0_c_double, 233.0_c_double, 241.0_c_double, 246.0_c_double, 267.0_c_double, 268.0_c_double]
    volcanic(:, 1995, 1) = [ &
                           338.0_c_double, 338.0_c_double, 334.0_c_double, 284.0_c_double, 240.0_c_double, 185.0_c_double, &
                           162.0_c_double, 116.0_c_double, 87.0_c_double, 83.0_c_double, 92.0_c_double, 114.0_c_double, &
                           136.0_c_double, 121.0_c_double, 105.0_c_double, 99.0_c_double, 117.0_c_double, 151.0_c_double, &
                           194.0_c_double, 214.0_c_double, 222.0_c_double, 226.0_c_double, 245.0_c_double, 247.0_c_double]
    volcanic(:, 1995, 2) = [ &
                           311.0_c_double, 311.0_c_double, 308.0_c_double, 262.0_c_double, 221.0_c_double, 170.0_c_double, &
                           149.0_c_double, 107.0_c_double, 80.0_c_double, 76.0_c_double, 85.0_c_double, 105.0_c_double, &
                           125.0_c_double, 111.0_c_double, 96.0_c_double, 91.0_c_double, 108.0_c_double, 139.0_c_double, &
                           179.0_c_double, 197.0_c_double, 204.0_c_double, 208.0_c_double, 226.0_c_double, 227.0_c_double]
    volcanic(:, 1995, 3) = [ &
                           286.0_c_double, 286.0_c_double, 283.0_c_double, 241.0_c_double, 204.0_c_double, 156.0_c_double, &
                           138.0_c_double, 98.0_c_double, 74.0_c_double, 70.0_c_double, 78.0_c_double, 96.0_c_double, &
                           115.0_c_double, 102.0_c_double, 89.0_c_double, 83.0_c_double, 99.0_c_double, 128.0_c_double, &
                           165.0_c_double, 181.0_c_double, 188.0_c_double, 192.0_c_double, 208.0_c_double, 209.0_c_double]
    volcanic(:, 1995, 4) = [ &
                           263.0_c_double, 263.0_c_double, 260.0_c_double, 222.0_c_double, 187.0_c_double, 144.0_c_double, &
                           127.0_c_double, 90.0_c_double, 68.0_c_double, 64.0_c_double, 72.0_c_double, 89.0_c_double, &
                           106.0_c_double, 94.0_c_double, 81.0_c_double, 77.0_c_double, 91.0_c_double, 118.0_c_double, &
                           151.0_c_double, 167.0_c_double, 173.0_c_double, 176.0_c_double, 191.0_c_double, 192.0_c_double]
    volcanic(:, 1995, 5) = [ &
                           242.0_c_double, 242.0_c_double, 240.0_c_double, 204.0_c_double, 172.0_c_double, 132.0_c_double, &
                           116.0_c_double, 83.0_c_double, 63.0_c_double, 59.0_c_double, 66.0_c_double, 82.0_c_double, &
                           97.0_c_double, 87.0_c_double, 75.0_c_double, 71.0_c_double, 84.0_c_double, 108.0_c_double, &
                           139.0_c_double, 153.0_c_double, 159.0_c_double, 162.0_c_double, 176.0_c_double, 177.0_c_double]
    volcanic(:, 1995, 6) = [ &
                           223.0_c_double, 223.0_c_double, 220.0_c_double, 187.0_c_double, 158.0_c_double, 122.0_c_double, &
                           107.0_c_double, 76.0_c_double, 58.0_c_double, 54.0_c_double, 61.0_c_double, 75.0_c_double, &
                           90.0_c_double, 80.0_c_double, 69.0_c_double, 65.0_c_double, 77.0_c_double, 100.0_c_double, &
                           128.0_c_double, 141.0_c_double, 146.0_c_double, 149.0_c_double, 162.0_c_double, 163.0_c_double]
    volcanic(:, 1995, 7) = [ &
                           205.0_c_double, 205.0_c_double, 203.0_c_double, 173.0_c_double, 146.0_c_double, 112.0_c_double, &
                           99.0_c_double, 70.0_c_double, 53.0_c_double, 50.0_c_double, 56.0_c_double, 69.0_c_double, &
                           82.0_c_double, 73.0_c_double, 63.0_c_double, 60.0_c_double, 71.0_c_double, 92.0_c_double, &
                           118.0_c_double, 130.0_c_double, 135.0_c_double, 137.0_c_double, 149.0_c_double, 150.0_c_double]
    volcanic(:, 1995, 8) = [ &
                           189.0_c_double, 189.0_c_double, 187.0_c_double, 159.0_c_double, 134.0_c_double, 103.0_c_double, &
                           91.0_c_double, 65.0_c_double, 49.0_c_double, 46.0_c_double, 51.0_c_double, 64.0_c_double, &
                           76.0_c_double, 68.0_c_double, 58.0_c_double, 55.0_c_double, 65.0_c_double, 84.0_c_double, &
                           108.0_c_double, 120.0_c_double, 124.0_c_double, 126.0_c_double, 137.0_c_double, 138.0_c_double]
    volcanic(:, 1995, 9) = [ &
                           174.0_c_double, 174.0_c_double, 172.0_c_double, 146.0_c_double, 123.0_c_double, 95.0_c_double, &
                           83.0_c_double, 59.0_c_double, 45.0_c_double, 42.0_c_double, 47.0_c_double, 58.0_c_double, &
                           70.0_c_double, 62.0_c_double, 54.0_c_double, 51.0_c_double, 60.0_c_double, 78.0_c_double, &
                           100.0_c_double, 110.0_c_double, 114.0_c_double, 116.0_c_double, 126.0_c_double, 127.0_c_double]
    volcanic(:, 1995, 10) = [ &
                            160.0_c_double, 160.0_c_double, 158.0_c_double, 134.0_c_double, 114.0_c_double, 87.0_c_double, &
                            77.0_c_double, 55.0_c_double, 41.0_c_double, 39.0_c_double, 43.0_c_double, 54.0_c_double, &
                            64.0_c_double, 57.0_c_double, 49.0_c_double, 47.0_c_double, 55.0_c_double, 71.0_c_double, &
                            92.0_c_double, 101.0_c_double, 105.0_c_double, 107.0_c_double, 116.0_c_double, 117.0_c_double]
    volcanic(:, 1995, 11) = [ &
                            147.0_c_double, 147.0_c_double, 145.0_c_double, 124.0_c_double, 104.0_c_double, 80.0_c_double, &
                            71.0_c_double, 50.0_c_double, 38.0_c_double, 36.0_c_double, 40.0_c_double, 50.0_c_double, &
                            59.0_c_double, 53.0_c_double, 45.0_c_double, 43.0_c_double, 51.0_c_double, 66.0_c_double, &
                            84.0_c_double, 93.0_c_double, 96.0_c_double, 98.0_c_double, 107.0_c_double, 107.0_c_double]
    volcanic(:, 1995, 12) = [ &
                            135.0_c_double, 135.0_c_double, 134.0_c_double, 114.0_c_double, 96.0_c_double, 74.0_c_double, &
                            65.0_c_double, 46.0_c_double, 35.0_c_double, 33.0_c_double, 37.0_c_double, 46.0_c_double, &
                            54.0_c_double, 48.0_c_double, 42.0_c_double, 39.0_c_double, 47.0_c_double, 61.0_c_double, &
                            78.0_c_double, 86.0_c_double, 89.0_c_double, 91.0_c_double, 98.0_c_double, 99.0_c_double]
    volcanic(:, 1996, 1) = [ &
                           124.0_c_double, 124.0_c_double, 123.0_c_double, 105.0_c_double, 88.0_c_double, 68.0_c_double, &
                           60.0_c_double, 43.0_c_double, 32.0_c_double, 30.0_c_double, 34.0_c_double, 42.0_c_double, &
                           50.0_c_double, 45.0_c_double, 38.0_c_double, 36.0_c_double, 43.0_c_double, 56.0_c_double, &
                           72.0_c_double, 79.0_c_double, 82.0_c_double, 83.0_c_double, 90.0_c_double, 91.0_c_double]
    volcanic(:, 1996, 2) = [ &
                           114.0_c_double, 114.0_c_double, 113.0_c_double, 96.0_c_double, 81.0_c_double, 62.0_c_double, &
                           55.0_c_double, 39.0_c_double, 30.0_c_double, 28.0_c_double, 31.0_c_double, 39.0_c_double, &
                           46.0_c_double, 41.0_c_double, 35.0_c_double, 33.0_c_double, 40.0_c_double, 51.0_c_double, &
                           66.0_c_double, 72.0_c_double, 75.0_c_double, 77.0_c_double, 83.0_c_double, 83.0_c_double]
    volcanic(:, 1996, 3) = [ &
                           105.0_c_double, 105.0_c_double, 104.0_c_double, 89.0_c_double, 75.0_c_double, 57.0_c_double, &
                           51.0_c_double, 36.0_c_double, 27.0_c_double, 26.0_c_double, 29.0_c_double, 35.0_c_double, &
                           42.0_c_double, 38.0_c_double, 33.0_c_double, 31.0_c_double, 36.0_c_double, 47.0_c_double, &
                           61.0_c_double, 67.0_c_double, 69.0_c_double, 70.0_c_double, 76.0_c_double, 77.0_c_double]
    volcanic(:, 1996, 4) = [ &
                           97.0_c_double, 97.0_c_double, 96.0_c_double, 81.0_c_double, 69.0_c_double, 53.0_c_double, &
                           47.0_c_double, 33.0_c_double, 25.0_c_double, 24.0_c_double, 26.0_c_double, 33.0_c_double, &
                           39.0_c_double, 35.0_c_double, 30.0_c_double, 28.0_c_double, 33.0_c_double, 43.0_c_double, &
                           56.0_c_double, 61.0_c_double, 64.0_c_double, 65.0_c_double, 70.0_c_double, 71.0_c_double]
    volcanic(:, 1996, 5) = [ &
                           89.0_c_double, 89.0_c_double, 88.0_c_double, 75.0_c_double, 63.0_c_double, 49.0_c_double, &
                           43.0_c_double, 31.0_c_double, 23.0_c_double, 22.0_c_double, 24.0_c_double, 30.0_c_double, &
                           36.0_c_double, 32.0_c_double, 28.0_c_double, 26.0_c_double, 31.0_c_double, 40.0_c_double, &
                           51.0_c_double, 56.0_c_double, 58.0_c_double, 60.0_c_double, 65.0_c_double, 65.0_c_double]
    volcanic(:, 1996, 6) = [ &
                           82.0_c_double, 82.0_c_double, 81.0_c_double, 69.0_c_double, 58.0_c_double, 45.0_c_double, &
                           39.0_c_double, 28.0_c_double, 21.0_c_double, 20.0_c_double, 22.0_c_double, 28.0_c_double, &
                           33.0_c_double, 29.0_c_double, 25.0_c_double, 24.0_c_double, 28.0_c_double, 37.0_c_double, &
                           47.0_c_double, 52.0_c_double, 54.0_c_double, 55.0_c_double, 59.0_c_double, 60.0_c_double]
    volcanic(:, 1996, 7) = [ &
                           75.0_c_double, 75.0_c_double, 75.0_c_double, 63.0_c_double, 54.0_c_double, 41.0_c_double, &
                           36.0_c_double, 26.0_c_double, 19.0_c_double, 18.0_c_double, 21.0_c_double, 25.0_c_double, &
                           30.0_c_double, 27.0_c_double, 23.0_c_double, 22.0_c_double, 26.0_c_double, 34.0_c_double, &
                           43.0_c_double, 48.0_c_double, 50.0_c_double, 51.0_c_double, 55.0_c_double, 55.0_c_double]
    volcanic(:, 1996, 8) = [ &
                           69.0_c_double, 69.0_c_double, 69.0_c_double, 58.0_c_double, 49.0_c_double, 38.0_c_double, &
                           33.0_c_double, 24.0_c_double, 18.0_c_double, 17.0_c_double, 19.0_c_double, 23.0_c_double, &
                           28.0_c_double, 25.0_c_double, 21.0_c_double, 20.0_c_double, 24.0_c_double, 31.0_c_double, &
                           40.0_c_double, 44.0_c_double, 46.0_c_double, 46.0_c_double, 50.0_c_double, 51.0_c_double]
    volcanic(:, 1996, 9) = [ &
                           64.0_c_double, 64.0_c_double, 63.0_c_double, 54.0_c_double, 45.0_c_double, 35.0_c_double, &
                           31.0_c_double, 22.0_c_double, 17.0_c_double, 16.0_c_double, 17.0_c_double, 22.0_c_double, &
                           26.0_c_double, 23.0_c_double, 20.0_c_double, 19.0_c_double, 22.0_c_double, 29.0_c_double, &
                           37.0_c_double, 40.0_c_double, 42.0_c_double, 43.0_c_double, 46.0_c_double, 47.0_c_double]
    volcanic(:, 1996, 10) = [ &
                            59.0_c_double, 59.0_c_double, 58.0_c_double, 49.0_c_double, 42.0_c_double, 32.0_c_double, &
                            28.0_c_double, 20.0_c_double, 15.0_c_double, 14.0_c_double, 16.0_c_double, 20.0_c_double, &
                            24.0_c_double, 21.0_c_double, 18.0_c_double, 17.0_c_double, 20.0_c_double, 26.0_c_double, &
                            34.0_c_double, 37.0_c_double, 39.0_c_double, 39.0_c_double, 43.0_c_double, 43.0_c_double]
    volcanic(:, 1996, 11) = [ &
                            54.0_c_double, 54.0_c_double, 53.0_c_double, 45.0_c_double, 38.0_c_double, 30.0_c_double, &
                            26.0_c_double, 19.0_c_double, 14.0_c_double, 13.0_c_double, 15.0_c_double, 18.0_c_double, &
                            22.0_c_double, 19.0_c_double, 17.0_c_double, 16.0_c_double, 19.0_c_double, 24.0_c_double, &
                            31.0_c_double, 34.0_c_double, 35.0_c_double, 36.0_c_double, 39.0_c_double, 39.0_c_double]
    volcanic(:, 1996, 12) = [ &
                            50.0_c_double, 50.0_c_double, 49.0_c_double, 42.0_c_double, 35.0_c_double, 27.0_c_double, &
                            24.0_c_double, 17.0_c_double, 13.0_c_double, 12.0_c_double, 14.0_c_double, 17.0_c_double, &
                            20.0_c_double, 18.0_c_double, 15.0_c_double, 14.0_c_double, 17.0_c_double, 22.0_c_double, &
                            29.0_c_double, 32.0_c_double, 33.0_c_double, 33.0_c_double, 36.0_c_double, 36.0_c_double]
    volcanic(:, 1997, 1) = [ &
                           46.0_c_double, 46.0_c_double, 45.0_c_double, 38.0_c_double, 33.0_c_double, 25.0_c_double, &
                           22.0_c_double, 16.0_c_double, 12.0_c_double, 11.0_c_double, 12.0_c_double, 15.0_c_double, &
                           18.0_c_double, 16.0_c_double, 14.0_c_double, 13.0_c_double, 16.0_c_double, 20.0_c_double, &
                           26.0_c_double, 29.0_c_double, 30.0_c_double, 31.0_c_double, 33.0_c_double, 33.0_c_double]
    volcanic(:, 1997, 2) = [ &
                           42.0_c_double, 42.0_c_double, 42.0_c_double, 35.0_c_double, 30.0_c_double, 23.0_c_double, &
                           20.0_c_double, 14.0_c_double, 11.0_c_double, 10.0_c_double, 11.0_c_double, 14.0_c_double, &
                           17.0_c_double, 15.0_c_double, 13.0_c_double, 12.0_c_double, 15.0_c_double, 19.0_c_double, &
                           24.0_c_double, 27.0_c_double, 28.0_c_double, 28.0_c_double, 31.0_c_double, 31.0_c_double]
    volcanic(:, 1997, 3) = [ &
                           39.0_c_double, 39.0_c_double, 38.0_c_double, 33.0_c_double, 28.0_c_double, 21.0_c_double, &
                           19.0_c_double, 13.0_c_double, 10.0_c_double, 9.0_c_double, 11.0_c_double, 13.0_c_double, &
                           16.0_c_double, 14.0_c_double, 12.0_c_double, 11.0_c_double, 13.0_c_double, 17.0_c_double, &
                           22.0_c_double, 25.0_c_double, 25.0_c_double, 26.0_c_double, 28.0_c_double, 28.0_c_double]
    volcanic(:, 1997, 4) = [ &
                           36.0_c_double, 36.0_c_double, 35.0_c_double, 30.0_c_double, 25.0_c_double, 19.0_c_double, &
                           17.0_c_double, 12.0_c_double, 9.0_c_double, 9.0_c_double, 10.0_c_double, 12.0_c_double, &
                           14.0_c_double, 13.0_c_double, 11.0_c_double, 10.0_c_double, 12.0_c_double, 16.0_c_double, &
                           20.0_c_double, 23.0_c_double, 23.0_c_double, 24.0_c_double, 26.0_c_double, 26.0_c_double]
    volcanic(:, 1997, 5) = [ &
                           33.0_c_double, 33.0_c_double, 32.0_c_double, 28.0_c_double, 23.0_c_double, 18.0_c_double, &
                           16.0_c_double, 11.0_c_double, 8.0_c_double, 8.0_c_double, 9.0_c_double, 11.0_c_double, &
                           13.0_c_double, 12.0_c_double, 10.0_c_double, 10.0_c_double, 11.0_c_double, 15.0_c_double, &
                           19.0_c_double, 21.0_c_double, 22.0_c_double, 22.0_c_double, 24.0_c_double, 24.0_c_double]
    volcanic(:, 1997, 6) = [ &
                           30.0_c_double, 30.0_c_double, 30.0_c_double, 25.0_c_double, 21.0_c_double, 16.0_c_double, &
                           14.0_c_double, 10.0_c_double, 8.0_c_double, 7.0_c_double, 8.0_c_double, 10.0_c_double, &
                           12.0_c_double, 11.0_c_double, 9.0_c_double, 9.0_c_double, 10.0_c_double, 13.0_c_double, &
                           17.0_c_double, 19.0_c_double, 20.0_c_double, 20.0_c_double, 22.0_c_double, 22.0_c_double]
    volcanic(:, 1997, 7) = [ &
                           28.0_c_double, 28.0_c_double, 27.0_c_double, 23.0_c_double, 20.0_c_double, 15.0_c_double, &
                           13.0_c_double, 10.0_c_double, 7.0_c_double, 7.0_c_double, 8.0_c_double, 9.0_c_double, &
                           11.0_c_double, 10.0_c_double, 9.0_c_double, 8.0_c_double, 10.0_c_double, 12.0_c_double, &
                           16.0_c_double, 18.0_c_double, 18.0_c_double, 19.0_c_double, 20.0_c_double, 20.0_c_double]
    volcanic(:, 1997, 8) = [ &
                           26.0_c_double, 26.0_c_double, 25.0_c_double, 21.0_c_double, 18.0_c_double, 14.0_c_double, &
                           12.0_c_double, 9.0_c_double, 7.0_c_double, 6.0_c_double, 7.0_c_double, 9.0_c_double, &
                           10.0_c_double, 9.0_c_double, 8.0_c_double, 7.0_c_double, 9.0_c_double, 11.0_c_double, &
                           15.0_c_double, 16.0_c_double, 17.0_c_double, 17.0_c_double, 19.0_c_double, 19.0_c_double]
    volcanic(:, 1997, 9) = [ &
                           23.0_c_double, 23.0_c_double, 23.0_c_double, 20.0_c_double, 17.0_c_double, 13.0_c_double, &
                           11.0_c_double, 8.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 8.0_c_double, &
                           9.0_c_double, 8.0_c_double, 7.0_c_double, 7.0_c_double, 8.0_c_double, 11.0_c_double, &
                           14.0_c_double, 15.0_c_double, 15.0_c_double, 16.0_c_double, 17.0_c_double, 17.0_c_double]
    volcanic(:, 1997, 10) = [ &
                            22.0_c_double, 22.0_c_double, 21.0_c_double, 18.0_c_double, 15.0_c_double, 12.0_c_double, &
                            10.0_c_double, 7.0_c_double, 6.0_c_double, 5.0_c_double, 6.0_c_double, 7.0_c_double, &
                            9.0_c_double, 8.0_c_double, 7.0_c_double, 6.0_c_double, 7.0_c_double, 10.0_c_double, &
                            12.0_c_double, 14.0_c_double, 14.0_c_double, 14.0_c_double, 16.0_c_double, 16.0_c_double]
    volcanic(:, 1997, 11) = [ &
                            20.0_c_double, 20.0_c_double, 20.0_c_double, 17.0_c_double, 14.0_c_double, 11.0_c_double, &
                            10.0_c_double, 7.0_c_double, 5.0_c_double, 5.0_c_double, 5.0_c_double, 7.0_c_double, &
                            8.0_c_double, 7.0_c_double, 6.0_c_double, 6.0_c_double, 7.0_c_double, 9.0_c_double, &
                            11.0_c_double, 13.0_c_double, 13.0_c_double, 13.0_c_double, 14.0_c_double, 15.0_c_double]
    volcanic(:, 1997, 12) = [ &
                            18.0_c_double, 18.0_c_double, 18.0_c_double, 15.0_c_double, 13.0_c_double, 10.0_c_double, &
                            9.0_c_double, 6.0_c_double, 5.0_c_double, 4.0_c_double, 5.0_c_double, 6.0_c_double, &
                            7.0_c_double, 7.0_c_double, 6.0_c_double, 5.0_c_double, 6.0_c_double, 8.0_c_double, &
                            11.0_c_double, 12.0_c_double, 12.0_c_double, 12.0_c_double, 13.0_c_double, 13.0_c_double]
    volcanic(:, 1998, 1) = [ &
                           17.0_c_double, 17.0_c_double, 17.0_c_double, 14.0_c_double, 12.0_c_double, 9.0_c_double, &
                           8.0_c_double, 6.0_c_double, 4.0_c_double, 4.0_c_double, 5.0_c_double, 6.0_c_double, &
                           7.0_c_double, 6.0_c_double, 5.0_c_double, 5.0_c_double, 6.0_c_double, 8.0_c_double, &
                           10.0_c_double, 11.0_c_double, 11.0_c_double, 11.0_c_double, 12.0_c_double, 12.0_c_double]
    volcanic(:, 1998, 2) = [ &
                           15.0_c_double, 15.0_c_double, 15.0_c_double, 13.0_c_double, 11.0_c_double, 8.0_c_double, &
                           7.0_c_double, 5.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 5.0_c_double, &
                           6.0_c_double, 6.0_c_double, 5.0_c_double, 5.0_c_double, 5.0_c_double, 7.0_c_double, &
                           9.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double, 11.0_c_double, 11.0_c_double]
    volcanic(:, 1998, 3) = [ &
                           14.0_c_double, 14.0_c_double, 14.0_c_double, 12.0_c_double, 10.0_c_double, 8.0_c_double, &
                           7.0_c_double, 5.0_c_double, 4.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double, &
                           6.0_c_double, 5.0_c_double, 4.0_c_double, 4.0_c_double, 5.0_c_double, 6.0_c_double, &
                           8.0_c_double, 9.0_c_double, 9.0_c_double, 10.0_c_double, 10.0_c_double, 10.0_c_double]
    volcanic(:, 1998, 4) = [ &
                           13.0_c_double, 13.0_c_double, 13.0_c_double, 11.0_c_double, 9.0_c_double, 7.0_c_double, &
                           6.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, 4.0_c_double, &
                           5.0_c_double, 5.0_c_double, 4.0_c_double, 4.0_c_double, 5.0_c_double, 6.0_c_double, &
                           8.0_c_double, 8.0_c_double, 9.0_c_double, 9.0_c_double, 10.0_c_double, 10.0_c_double]
    volcanic(:, 1998, 5) = [ &
                           12.0_c_double, 12.0_c_double, 12.0_c_double, 10.0_c_double, 9.0_c_double, 7.0_c_double, &
                           6.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, &
                           5.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 5.0_c_double, &
                           7.0_c_double, 8.0_c_double, 8.0_c_double, 8.0_c_double, 9.0_c_double, 9.0_c_double]
    volcanic(:, 1998, 6) = [ &
                           11.0_c_double, 11.0_c_double, 11.0_c_double, 9.0_c_double, 8.0_c_double, 6.0_c_double, &
                           5.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, &
                           4.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double, &
                           6.0_c_double, 7.0_c_double, 7.0_c_double, 7.0_c_double, 8.0_c_double, 8.0_c_double]
    volcanic(:, 1998, 7) = [ &
                           10.0_c_double, 10.0_c_double, 10.0_c_double, 9.0_c_double, 7.0_c_double, 6.0_c_double, &
                           5.0_c_double, 3.0_c_double, 3.0_c_double, 2.0_c_double, 3.0_c_double, 3.0_c_double, &
                           4.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double, &
                           6.0_c_double, 6.0_c_double, 7.0_c_double, 7.0_c_double, 7.0_c_double, 7.0_c_double]
    volcanic(:, 1998, 8) = [ &
                           9.0_c_double, 9.0_c_double, 9.0_c_double, 8.0_c_double, 7.0_c_double, 5.0_c_double, &
                           5.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, 3.0_c_double, &
                           4.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, &
                           5.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 7.0_c_double, 7.0_c_double]
    volcanic(:, 1998, 9) = [ &
                           9.0_c_double, 9.0_c_double, 9.0_c_double, 7.0_c_double, 6.0_c_double, 5.0_c_double, &
                           4.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, &
                           3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, &
                           5.0_c_double, 5.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double, 6.0_c_double]
    volcanic(:, 1998, 10) = [ &
                            8.0_c_double, 8.0_c_double, 8.0_c_double, 7.0_c_double, 6.0_c_double, 4.0_c_double, &
                            4.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, &
                            3.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double, &
                            5.0_c_double, 5.0_c_double, 5.0_c_double, 5.0_c_double, 6.0_c_double, 6.0_c_double]
    volcanic(:, 1998, 11) = [ &
                            7.0_c_double, 7.0_c_double, 7.0_c_double, 6.0_c_double, 5.0_c_double, 4.0_c_double, &
                            4.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                            3.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, 3.0_c_double, &
                            4.0_c_double, 5.0_c_double, 5.0_c_double, 5.0_c_double, 5.0_c_double, 5.0_c_double]
    volcanic(:, 1998, 12) = [ &
                            7.0_c_double, 7.0_c_double, 7.0_c_double, 6.0_c_double, 5.0_c_double, 4.0_c_double, &
                            3.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                            3.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, &
                            4.0_c_double, 4.0_c_double, 4.0_c_double, 5.0_c_double, 5.0_c_double, 5.0_c_double]
    volcanic(:, 1999, 1) = [ &
                           6.0_c_double, 6.0_c_double, 6.0_c_double, 5.0_c_double, 4.0_c_double, 3.0_c_double, &
                           3.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, &
                           4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 5.0_c_double]
    volcanic(:, 1999, 2) = [ &
                           6.0_c_double, 6.0_c_double, 6.0_c_double, 5.0_c_double, 4.0_c_double, 3.0_c_double, &
                           3.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, &
                           3.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double]
    volcanic(:, 1999, 3) = [ &
                           5.0_c_double, 5.0_c_double, 5.0_c_double, 4.0_c_double, 4.0_c_double, 3.0_c_double, &
                           3.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                           3.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double]
    volcanic(:, 1999, 4) = [ &
                           5.0_c_double, 5.0_c_double, 5.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, 2.0_c_double, &
                           3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 4.0_c_double]
    volcanic(:, 1999, 5) = [ &
                           4.0_c_double, 4.0_c_double, 4.0_c_double, 4.0_c_double, 3.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, 2.0_c_double, &
                           3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double]
    volcanic(:, 1999, 6) = [ &
                           4.0_c_double, 4.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, 2.0_c_double, &
                           2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, &
                           2.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double]
    volcanic(:, 1999, 7) = [ &
                           4.0_c_double, 4.0_c_double, 4.0_c_double, 3.0_c_double, 3.0_c_double, 2.0_c_double, &
                           2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double]
    volcanic(:, 1999, 8) = [ &
                           3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, &
                           2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 3.0_c_double, 3.0_c_double]
    volcanic(:, 1999, 9) = [ &
                           3.0_c_double, 3.0_c_double, 3.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, &
                           2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double]
    volcanic(:, 1999, 10) = [ &
                            3.0_c_double, 3.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double]
    volcanic(:, 1999, 11) = [ &
                            3.0_c_double, 3.0_c_double, 3.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double]
    volcanic(:, 1999, 12) = [ &
                            2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double]
    volcanic(:, 2000, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2000, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2000, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2001, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2001, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2002, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2002, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2003, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2003, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2004, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2004, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2005, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2005, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2006, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2006, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2007, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2007, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2008, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2008, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2009, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2009, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 1) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 2.0_c_double]
    volcanic(:, 2010, 2) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 3) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 4) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 5) = [ &
                           2.0_c_double, 2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 6) = [ &
                           2.0_c_double, 2.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 7) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 8) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 9) = [ &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                           1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 10) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 11) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]
    volcanic(:, 2010, 12) = [ &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, &
                            1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double, 1.0_c_double]

    ! Round one ordinary FP64 product per element after all unscaled stores.
    do month = 1, size(volcanic, 3)
      do year = lbound(volcanic, 2), ubound(volcanic, 2)
        do latitude = 1, size(volcanic, 1)
          volcanic(latitude, year, month) = source_scale*volcanic(latitude, year, month)
        end do
      end do
    end do
    security = source_security
    status = 0_c_int
  end function initialize_tegen_volcanic_values
end module native_tegen_volcanic_values
