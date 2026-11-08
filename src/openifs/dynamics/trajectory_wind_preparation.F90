!> Prepare the selected Cartesian wind and eta rate for parcel trajectories.
!! Native arrays replace the original Geometry, Model and field byte layouts.
module md2asm_trajectory_wind_preparation
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, operator(/=)
  use md2asm_trajectory_hyperbolic_tangent, only: evaluate_trajectory_tanh
  implicit none
  private
  public :: trajectory_wind_controls, trajectory_wind_outputs, prepare_trajectory_wind

  !> Explicit switches for the frozen two-level Cartesian prediction route.
  !! The selected vertical filter acts on the first two physical levels.
  !! Filter scale is in s**2; filter offset is in s**(-2).
  type :: trajectory_wind_controls
    integer(int32) :: step = -1, filtered_levels = 2, first_order_steps = 0
    logical :: two_time_levels = .true., predict_horizontal = .true., predict_vertical = .true.
    logical :: filter_vertical = .true., curved_departure = .true., cartesian = .true., save_history = .true.
    logical :: elegant_trajectory = .false., non_extrapolate_horizontal = .false.
    logical :: non_extrapolate_vertical = .false., full_corrector = .false., cheap_corrector = .false.
    logical :: extra_horizontal_filter = .false., extra_vertical_filter = .false.
    logical :: vertical_smoothing = .false., extra_vertical_trajectory = .false., curved_rhs = .false.
    logical :: refined_first_step = .false., rayleigh_filter = .false.
    real(real64) :: filter_scale = 1.0e14_real64, filter_offset = 1.0e-14_real64
  end type

  !> Writable native views, each with shape(pitch,at least levels).
  !! Predicted/current x,y,z are Cartesian wind(m/s). Predicted/current eta
  !! rates and history are in1/s. mixing is the original PALPHA owner and
  !! receives positive zero; it is separate from the filter's local weight.
  !! All views retain their complete containing owners and inactive cells.
  type :: trajectory_wind_outputs
    real(real64), pointer, contiguous :: predicted_x(:, :) => null(), predicted_y(:, :) => null()
    real(real64), pointer, contiguous :: predicted_z(:, :) => null(), predicted_eta(:, :) => null()
    real(real64), pointer, contiguous :: current_x(:, :) => null(), current_y(:, :) => null()
    real(real64), pointer, contiguous :: current_z(:, :) => null(), current_eta(:, :) => null()
    real(real64), pointer, contiguous :: history(:, :) => null(), mixing(:, :) => null()
  end type
contains
  !> Execute complete selected LAVENT with the existing FP64-pair tangent.
  !! eta(0:levels) is dimensionless. pressure_flux(pitch,0:levels) is in Pa/s,
  !! and inverse_pressure_depth(pitch,levels) is in1/Pa. The full-level flux
  !! at indexk is multiplied by eta(k)-eta(k-1), then by reciprocal pressure.
  !! The four trigonometric-factor vectors are dimensionless, supplied values;
  !! this entry does not recompute or normalize them. Wind arrays are in m/s.
  !! previous_eta_rate is a writable GMV history view in1/s. At positive steps,
  !! its previous values are saved before it receives the newly computed rate.
  !! counters has at least levels entries; only its first two entries are
  !! cleared at positive steps, including a valid empty column interval.
  !! Every consumed input is checked before the first output write. A late
  !! nonfinite tangent argument returns2 and leaves the whole call unaccepted.
  !! Caller input/output views obey the selected original non-overlap contract.
  !! The compiler owns the native descriptors and machine calling convention.
  !! Status0 succeeds and2 refuses metadata, finite inputs or a child result.
  subroutine prepare_trajectory_wind(pitch, levels, first, last, c, eta, &
                                     sin_latitude, cos_latitude, cos_longitude, sin_longitude, current_u, current_v, &
                              previous_u, previous_v, pressure_flux, inverse_pressure_depth, previous_eta_rate, f, counters, status)
    integer(int32), intent(in) :: pitch, levels, first, last
    type(trajectory_wind_controls), intent(in) :: c
    real(real64), intent(in) :: eta(0:), sin_latitude(:), cos_latitude(:), cos_longitude(:), sin_longitude(:)
    real(real64), intent(in) :: current_u(:, :), current_v(:, :), previous_u(:, :), previous_v(:, :)
    real(real64), intent(in) :: pressure_flux(:, 0:), inverse_pressure_depth(:, :)
    real(real64), intent(inout) :: previous_eta_rate(:, :)
    type(trajectory_wind_outputs), intent(inout) :: f
    integer(int32), intent(inout) :: counters(:)
    integer(int32), intent(out) :: status
    integer :: i, k
    real(real64), volatile :: eta_thickness
    real(real64) :: current_w, old_w, u, v, up, vp, wp, product, a, b, argument, tangent, weight

    status = 2_int32
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch .or. last < 0 .or. last > pitch) return
    if (c%step < 0 .or. c%filtered_levels /= 2 .or. c%first_order_steps /= 0) return
    if (.not. c%two_time_levels .or. .not. c%predict_horizontal .or. .not. c%predict_vertical) return
    if (.not. c%filter_vertical .or. .not. c%curved_departure .or. .not. c%cartesian .or. .not. c%save_history) return
    if (c%elegant_trajectory .or. c%non_extrapolate_horizontal .or. c%non_extrapolate_vertical) return
    if (c%full_corrector .or. c%cheap_corrector .or. c%extra_horizontal_filter .or. c%extra_vertical_filter) return
    if (c%vertical_smoothing .or. c%extra_vertical_trajectory .or. c%curved_rhs) return
    if (c%refined_first_step .or. c%rayleigh_filter) return
    if (ubound(eta, 1) < levels .or. size(counters) < levels) return
    if (size(sin_latitude) < pitch .or. size(cos_latitude) < pitch) return
    if (size(cos_longitude) < pitch .or. size(sin_longitude) < pitch) return
    if (.not. valid_plane(current_u) .or. .not. valid_plane(current_v)) return
    if (.not. valid_plane(inverse_pressure_depth) .or. .not. valid_plane(previous_eta_rate)) return
    if (size(pressure_flux, 1) /= pitch .or. ubound(pressure_flux, 2) < levels) return
    if (c%step > 0) then
      if (.not. valid_plane(previous_u) .or. .not. valid_plane(previous_v)) return
    end if
    if (.not. output_plane(f%predicted_x) .or. .not. output_plane(f%predicted_y)) return
    if (.not. output_plane(f%predicted_z) .or. .not. output_plane(f%predicted_eta)) return
    if (.not. output_plane(f%current_x) .or. .not. output_plane(f%current_y)) return
    if (.not. output_plane(f%current_z) .or. .not. output_plane(f%current_eta)) return
    if (.not. output_plane(f%history) .or. .not. output_plane(f%mixing)) return
    if (.not. environment_supported()) return
    if (.not. positive_finite(c%filter_scale) .or. .not. positive_finite(c%filter_offset)) return
    do k = 0, levels
      if (.not. finite_bits(eta(k))) return
    end do
    do i = first, last
      if (.not. finite_bits(sin_latitude(i)) .or. .not. finite_bits(cos_latitude(i))) return
      if (.not. finite_bits(cos_longitude(i)) .or. .not. finite_bits(sin_longitude(i))) return
    end do
    do k = 1, levels
      do i = first, last
        if (.not. finite_bits(pressure_flux(i, k))) return
        if (.not. positive_finite(inverse_pressure_depth(i, k))) return
        if (.not. finite_bits(current_u(i, k)) .or. .not. finite_bits(current_v(i, k))) return
        if (c%step > 0) then
          if (.not. finite_bits(previous_u(i, k)) .or. .not. finite_bits(previous_v(i, k))) return
          if (.not. finite_bits(previous_eta_rate(i, k))) return
        end if
      end do
    end do

    do k = 1, levels
      ! This source subtraction executes even when the active range is empty.
      eta_thickness = eta(k) - eta(k - 1)
      if (c%step > 0 .and. k <= c%filtered_levels) counters(k) = 0_int32
      do i = first, last
        current_w = pressure_flux(i, k)*eta_thickness
        current_w = current_w*inverse_pressure_depth(i, k)
        u = current_u(i, k)
        v = current_v(i, k)
        if (c%step == 0) then
          up = u
          vp = v
          wp = current_w
          old_w = 0.0_real64
        else
          up = 2.0_real64*u
          up = up - previous_u(i, k)
          vp = 2.0_real64*v
          vp = vp - previous_v(i, k)
          old_w = previous_eta_rate(i, k)
          if (k <= c%filtered_levels) then
            product = current_w*old_w
            a = product + c%filter_offset
            b = -c%filter_scale
            argument = b*a
            call evaluate_trajectory_tanh(argument, tangent, status)
            if (status /= 0) return
            weight = 1.0_real64 - tangent
            weight = 0.5_real64*weight
            a = current_w - old_w
            product = weight*a
            wp = current_w + product
          else
            wp = 2.0_real64*current_w
            wp = wp - old_w
          end if
        end if
        f%predicted_eta(i, k) = wp
        f%current_eta(i, k) = current_w
        f%history(i, k) = old_w
        previous_eta_rate(i, k) = current_w
        f%mixing(i, k) = 0.0_real64

        f%predicted_z(i, k) = vp*cos_latitude(i)
        a = -up
        a = a*sin_longitude(i)
        b = vp*cos_longitude(i)
        b = b*sin_latitude(i)
        f%predicted_x(i, k) = a - b
        a = up*cos_longitude(i)
        b = vp*sin_longitude(i)
        b = b*sin_latitude(i)
        f%predicted_y(i, k) = a - b

        f%current_z(i, k) = v*cos_latitude(i)
        a = -u
        a = a*sin_longitude(i)
        b = v*cos_longitude(i)
        b = b*sin_latitude(i)
        f%current_x(i, k) = a - b
        a = u*cos_longitude(i)
        b = v*sin_longitude(i)
        b = b*sin_latitude(i)
        f%current_y(i, k) = a - b
      end do
    end do
    status = 0_int32
  contains
    logical function valid_plane(array) result(valid)
      real(real64), intent(in) :: array(:, :)
      valid = size(array, 1) == pitch .and. size(array, 2) >= levels
    end function
    logical function output_plane(array) result(valid)
      real(real64), pointer, intent(in) :: array(:, :)
      valid = .false.
      if (.not. associated(array)) return
      valid = size(array, 1) == pitch .and. size(array, 2) >= levels
    end function
  end subroutine

  logical function finite_bits(x) result(finite)
    real(real64), intent(in) :: x
    integer(int64) :: bits
    bits = transfer(x, bits)
    finite = iand(shiftr(bits, 52), 2047_int64) /= 2047_int64
  end function

  logical function positive_finite(x) result(positive)
    real(real64), intent(in) :: x
    integer(int64) :: bits
    bits = transfer(x, bits)
    positive = .false.
    if (btest(bits, 63) .or. bits == 0_int64) return
    positive = finite_bits(x)
  end function

  logical function environment_supported() result(supported)
    type(ieee_round_type) :: mode
    real(real64), volatile :: normal_value, half, subnormal
    supported = .false.
    call ieee_get_rounding_mode(mode)
    if (mode /= ieee_nearest) return
    normal_value = tiny(1.0_real64)
    half = 0.5_real64
    subnormal = normal_value*half
    if (subnormal /= transfer(int(z'0008000000000000', int64), 1.0_real64)) return
    supported = .true.
  end function
end module md2asm_trajectory_wind_preparation
