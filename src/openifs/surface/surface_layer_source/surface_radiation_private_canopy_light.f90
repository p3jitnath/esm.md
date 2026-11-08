!> Complete source-ordered CANALB urban canyon radiation calculation.
!! Aspect ratio, wall/road albedos, cosine input and albedo output are dimensionless.
module forecast_radiation_private_canopy
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_intptr_t, c_loc
  use yos_urb, only: turb
  use forecast_public_scalar_math, only: power_original_rounding
  implicit none
  private
  public :: canalb, native_call_count
  integer(int64), save :: activity_count = 0_int64
  interface
    function public_acos(x) bind(C, name="acos") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_tan(x) bind(C, name="tan") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_asin(x) bind(C, name="asin") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_cos(x) bind(C, name="cos") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Read the separate private invocation count without numerical work.
  integer(int64) function native_call_count() result(count)
    count = activity_count
  end function native_call_count
  !> Read the native urban record and form reflection, inverse and absorption.
  !! Selected rows lie within 1:4096; inactive words keep their input bits.
  !! Input/output owners are separate and the caller establishes the FP mode.
  !! Both vectors have 1:4096 elements and positive native strides.
  !! Their complete byte spans are at most 256 MiB and do not overlap.
  !! Native status 0 completes; status 2 refuses before any output mutation.
  !! Empty intervals do not read the physical fields or perform floating arithmetic.
  subroutine canalb(kidia, kfdia, ydurb, pmu0, pcanalb, status)
    integer(int32), intent(in) :: kidia, kfdia
    type(turb), intent(in) :: ydurb
    real(real64), intent(in), target :: pmu0(:)
    real(real64), intent(inout), target :: pcanalb(:)
    integer(int32), intent(out) :: status
    real(real64), volatile :: shape_factor(3, 3), reflection(3, 3), inverse(3, 3), reference_flux(3), outgoing(3), incoming(3)
    real(real64), volatile :: aspect, road, wall, a, b, c, e, reciprocal_aspect, determinant, detinv, minor, term
    real(real64), volatile :: angle, tangent, omega, omega_angle, cosine, x_road, x_wall, absorbed
    real(real64), volatile :: pi, two_over_pi, clear_fraction, negative_road, negative_wall, one, zero, two, half, sky
    integer(c_intptr_t) :: input_first, input_end, output_first, output_end
    integer(int64) :: input_count, output_count
    integer :: j, row, column
    status = 2
    if (kidia < 1 .or. kfdia < 0 .or. kfdia > 4096) return
    input_count = size(pmu0, kind=int64)
    output_count = size(pcanalb, kind=int64)
    if (input_count < 1 .or. input_count > 4096 .or. output_count < 1 .or. output_count > 4096) return
    if (int(kidia, int64) - 1 > input_count .or. int(kfdia, int64) > input_count) return
    if (int(kidia, int64) - 1 > output_count .or. int(kfdia, int64) > output_count) return
    if (.not. native_vector_span(pmu0, input_first, input_end)) return
    if (.not. native_vector_span(pcanalb, output_first, output_end)) return
    if (output_first < input_end .and. input_first < output_end) return
    status = 0
    if (kidia > kfdia) then
      activity_count = activity_count + 1_int64
      return
    end if
    status = 2
    aspect = ydurb%rhwr
    if (.not. finite_bits(aspect)) return
    if (aspect < 0.05_real64) return
    if (aspect > 1.5_real64) return
    road = ydurb%rroaalb
    if (.not. finite_bits(road)) return
    if (road < 0.0_real64) return
    if (road > 1.0_real64) return
    wall = ydurb%rwalalb
    if (.not. finite_bits(wall)) return
    if (wall < 0.0_real64) return
    if (wall > 1.0_real64) return
    do j = kidia, kfdia
      if (.not. finite_bits(pmu0(j))) return
      if (pmu0(j) < 0.0_real64) return
      if (pmu0(j) > 1.0_real64) return
    end do
    activity_count = activity_count + 1_int64
    one = 1.0_real64
    zero = 0.0_real64
    sky = 0.3_real64
    pi = transfer(int(z'400921fb54442d18', int64), zero)
    two = 2.0_real64
    half = 0.5_real64
    two_over_pi = two/pi
    clear_fraction = one - sky
    a = aspect*aspect; a = one + a
    a = power_original_rounding(a, half); a = a - aspect
    reciprocal_aspect = one/aspect
    b = reciprocal_aspect*reciprocal_aspect; b = one + b
    b = power_original_rounding(b, half); b = b - reciprocal_aspect
    c = one - a; e = one - b; e = e/two
    shape_factor(1, 1) = zero
    shape_factor(1, 2) = c
    shape_factor(1, 3) = a
    shape_factor(2, 1) = e
    shape_factor(2, 2) = b
    shape_factor(2, 3) = e
    shape_factor(3, 1) = a
    shape_factor(3, 2) = c
    shape_factor(3, 3) = zero
    reflection(1, 1) = one
    reflection(3, 1) = zero
    reflection(3, 2) = zero
    reflection(3, 3) = one
    negative_road = -road
    reflection(1, 2) = negative_road*c
    reflection(1, 3) = negative_road*a
    negative_wall = -wall
    reflection(2, 1) = negative_wall*e
    reflection(2, 3) = reflection(2, 1)
    term = wall*b
    reflection(2, 2) = one - term
    term = reflection(1, 1)*reflection(2, 2); determinant = term*reflection(3, 3)
    term = reflection(1, 1)*reflection(2, 3); term = term*reflection(3, 2); determinant = determinant - term
    term = reflection(1, 2)*reflection(2, 1); term = term*reflection(3, 3); determinant = determinant - term
    term = reflection(1, 2)*reflection(2, 3); term = term*reflection(3, 1); determinant = determinant + term
    term = reflection(1, 3)*reflection(2, 1); term = term*reflection(3, 2); determinant = determinant + term
    term = reflection(1, 3)*reflection(2, 2); term = term*reflection(3, 1); determinant = determinant - term
    detinv = one/determinant
    term = reflection(2, 2)*reflection(3, 3); minor = reflection(2, 3)*reflection(3, 2); minor = term - minor; inverse(1, 1) = detinv*minor
    term = reflection(2, 1)*reflection(3, 3); minor = reflection(2, 3)*reflection(3, 1); minor = term - minor; inverse(2, 1) = (-detinv)*minor
    term = reflection(2, 1)*reflection(3, 2); minor = reflection(2, 2)*reflection(3, 1); minor = term - minor; inverse(3, 1) = detinv*minor
    term = reflection(1, 2)*reflection(3, 3); minor = reflection(1, 3)*reflection(3, 2); minor = term - minor; inverse(1, 2) = (-detinv)*minor
    term = reflection(1, 1)*reflection(3, 3); minor = reflection(1, 3)*reflection(3, 1); minor = term - minor; inverse(2, 2) = detinv*minor
    term = reflection(1, 1)*reflection(3, 2); minor = reflection(1, 2)*reflection(3, 1); minor = term - minor; inverse(3, 2) = (-detinv)*minor
    term = reflection(1, 2)*reflection(2, 3); minor = reflection(1, 3)*reflection(2, 2); minor = term - minor; inverse(1, 3) = detinv*minor
    term = reflection(1, 1)*reflection(2, 3); minor = reflection(1, 3)*reflection(2, 1); minor = term - minor; inverse(2, 3) = (-detinv)*minor
    term = reflection(1, 1)*reflection(2, 2); minor = reflection(1, 2)*reflection(2, 1); minor = term - minor; inverse(3, 3) = detinv*minor
    do j = kidia, kfdia
      angle = public_acos(pmu0(j)); tangent = public_tan(angle)
      if (tangent == zero) tangent = transfer(int(z'3f1a36e2eb1c432d', int64), zero)
      term = tangent*aspect; omega = one/term
      if (omega > one) omega = one
      omega_angle = public_asin(omega); cosine = public_cos(omega_angle)
      term = one - cosine; minor = aspect*omega; term = minor*term
      term = omega_angle - term; x_road = two_over_pi*term
      term = one - x_road; minor = two*aspect; x_wall = term/minor
      term = road*clear_fraction; reference_flux(1) = term*x_road
      term = wall*clear_fraction; reference_flux(2) = term*x_wall
      reference_flux(3) = sky
      do row = 1, 3
        outgoing(row) = zero
        do column = 1, 3
          term = inverse(row, column)*reference_flux(column)
          outgoing(row) = outgoing(row) + term
        end do
      end do
      do row = 1, 3
        incoming(row) = zero
        do column = 1, 3
          term = shape_factor(row, column)*outgoing(column)
          incoming(row) = incoming(row) + term
        end do
      end do
      term = clear_fraction*x_road; incoming(1) = incoming(1) + term; incoming(1) = incoming(1) - outgoing(1)
      term = clear_fraction*x_wall; incoming(2) = incoming(2) + term; incoming(2) = incoming(2) - outgoing(2)
      term = two*aspect; term = term*incoming(2); absorbed = incoming(1) + term
      absorbed = one - absorbed
      if (absorbed > one) absorbed = one
      if (absorbed < zero) absorbed = zero
      pcanalb(j) = absorbed
    end do
    status = 0
  end subroutine
  !> Test the binary64 exponent with integer operations, including signalling NaNs.
  logical function finite_bits(x)
    real(real64), intent(in) :: x
    integer(int64) :: bits
    bits = transfer(x, bits)
    finite_bits = iand(bits, int(z'7ff0000000000000', int64)) /= int(z'7ff0000000000000', int64)
  end function

  !> Check a valid native rank-one view without reading its element payload.
  !! The compiler supplies element addresses; no private descriptor offsets are used.
  logical function native_vector_span(field, first, after_last)
    real(real64), intent(in), target :: field(:)
    integer(c_intptr_t), intent(out) :: first, after_last
    integer(c_intptr_t) :: last
    integer(int64) :: count
    native_vector_span = .false.
    count = size(field, kind=int64)
    first = transfer(c_loc(field(1)), first)
    last = transfer(c_loc(field(count)), last)
    if (first < 0_c_intptr_t .or. last < first) return
    if (count > 1 .and. last == first) return
    if (last > huge(last) - 8_c_intptr_t) return
    if (last - first > 268435448_c_intptr_t) return
    after_last = last + 8_c_intptr_t
    native_vector_span = .true.
  end function
end module
