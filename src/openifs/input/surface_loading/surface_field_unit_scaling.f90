module surface_field_unit_scaling_port
  !! Apply the original unit factors, including a literal multiply by one.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: scale_initial_surface_fields
contains
  integer(int32) function scale_initial_surface_fields(ordinary, layered, parameters, gravity, water_density) result(status)
    !! ordinary has shape(N,F); layered has shape(N,5,5). Select N/F as
    !!2048/47 or6599680/50. parameters has F+5 identifiers. Arrays are
    !! contiguous, disjoint and caller-owned. Each stored value changes once.
    !! Gravity is m/s**2 and water density kg/m**3. Finite coefficients and
    !! input values use nearest rounding and gradual underflow. Return1
    !! before mutation for an unsupported shape; return0 after scaling.
    real(real64), contiguous, intent(inout) :: ordinary(:, :), layered(:, :, :)
    integer(int32), intent(in) :: parameters(:)
    real(real64), intent(in) :: gravity, water_density
    real(real64), volatile :: factor
    integer :: n, f, j, k, l
    n = size(ordinary, 1); f = size(ordinary, 2)
    status = 1
    if (.not. ((n == 2048 .and. f == 47) .or. (n == 6599680 .and. f == 50))) return
    if (any(shape(layered) /= [n, 5, 5]) .or. size(parameters) /= f + 5) return
    do k = 1, f
      factor = 1.0_real64
      select case (parameters(k))
      case (173, 244, 160)
        factor = gravity
      case (198)
        factor = water_density
      end select
      do j = 1, n
        ordinary(j, k) = factor*ordinary(j, k)
      end do
    end do
    do k = 1, 5
      factor = 1.0_real64
      select case (parameters(f + k))
      case (173, 244, 160)
        factor = gravity
      case (141, 198)
        factor = water_density
      end select
      do l = 1, 5
        do j = 1, n
          layered(j, l, k) = factor*layered(j, l, k)
        end do
      end do
    end do
    status = 0
  end function
end module
