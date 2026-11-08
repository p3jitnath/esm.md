!> Saturation humidity in the generated operation order.
!! Native providers replace the former module-global constant loads.
module saturation_humidity_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  implicit none
  private
  public :: satur, ordered_minimum, ordered_maximum, numeric_maximum
  public :: valid_real_matrix, valid_real_vector, public_exp
  interface
    function public_exp(x) bind(c, name="exp") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Return true for a NaN bit pattern without a floating comparison.
  !! The admitted missing inputs are quiet NaNs. Signalling NaNs are outside
  !! this numerical contract and do not have a claimed exception result.
  pure logical function quiet_missing(x)
    real(c_double), intent(in) :: x
    integer(c_int64_t) :: bits
    bits = iand(transfer(x, 0_c_int64_t), int(z'7fffffffffffffff', c_int64_t))
    quiet_missing = bits > int(z'7ff0000000000000', c_int64_t)
  end function
  !> Preserve propagating minimum, including negative zero at a zero tie.
  pure function ordered_minimum(x, y) result(z)
    real(c_double), intent(in) :: x, y
    real(c_double) :: z
    integer(c_int64_t) :: bx, by
    if (quiet_missing(x)) then
      z = x
    elseif (quiet_missing(y)) then
      z = y
    elseif (x < y) then
      z = x
    elseif (y < x) then
      z = y
    else
      bx = transfer(x, 0_c_int64_t); by = transfer(y, 0_c_int64_t)
      if (iand(bx, int(z'7fffffffffffffff', c_int64_t)) == 0_c_int64_t) then
        z = transfer(ior(bx, by), 0.0_c_double)
      else
        z = x
      end if
    end if
  end function
  !> Preserve propagating maximum, including positive zero at a zero tie.
  pure function ordered_maximum(x, y) result(z)
    real(c_double), intent(in) :: x, y
    real(c_double) :: z
    integer(c_int64_t) :: bx, by
    if (quiet_missing(x)) then
      z = x
    elseif (quiet_missing(y)) then
      z = y
    elseif (x > y) then
      z = x
    elseif (y > x) then
      z = y
    else
      bx = transfer(x, 0_c_int64_t); by = transfer(y, 0_c_int64_t)
      if (iand(bx, int(z'7fffffffffffffff', c_int64_t)) == 0_c_int64_t) then
        z = transfer(iand(bx, by), 0.0_c_double)
      else
        z = x
      end if
    end if
  end function
  !> The numeric maximum keeps its numeric operand beside a quiet NaN.
  pure function numeric_maximum(x, y) result(z)
    real(c_double), intent(in) :: x, y
    real(c_double) :: z
    if (quiet_missing(x)) then
      if (quiet_missing(y)) then
        z = x
      else
        z = y
      end if
    elseif (quiet_missing(y)) then
      z = x
    else
      z = ordered_maximum(x, y)
    end if
  end function
  !> Check matrix metadata without a copied contiguous temporary.
  pure logical function valid_real_matrix(x, columns, levels)
    real(c_double), intent(in) :: x(:, :)
    integer(c_int), intent(in) :: columns, levels
    valid_real_matrix = is_contiguous(x) .and. size(x, 1) == columns .and. size(x, 2) >= levels
  end function
  !> Check a readonly vector's consumed extent and original contiguous route.
  pure logical function valid_real_vector(x, columns)
    real(c_double), intent(in) :: x(:)
    integer(c_int), intent(in) :: columns
    valid_real_vector = is_contiguous(x) .and. size(x) >= columns
  end function
  !> Compute selected saturation humidity cells and preserve all other cells.
  !! CONSTANTS and THERMAL are readonly completed native parameter records.
  !! KIDIA:KFDIA selects columns in KLON=0:4096; KTDIA:KLEV selects levels
  !! in KLEV=0:1024. PAPRSF is pressure in Pa and PT is temperature in K.
  !! PQSAT is humidity in kg/kg. All matrices have first extent KLON and
  !! at least KLEV levels; extra levels are unchanged. Ordinary assumed-shape
  !! dummies allow stride refusal before a payload access or caller copy.
  !! Readonly input owners may alias; the caller keeps PQSAT disjoint from
  !! all inputs and providers. Used pressures are positive and finite, and
  !! temperatures are in160:330 K. The caller sets nearest-even rounding
  !! and gradual underflow once; this child makes no control-mode probe.
  !! Return0 after work or an empty interval; return2 before writes for
  !! unsupported metadata. PUBLIC_EXP must bind the qualified C provider.
  function satur(constants, thermal, kidia, kfdia, klon, ktdia, klev, ldphylin, paprsf, pt, pqsat, kflag) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    integer(c_int), intent(in) :: kidia, kfdia, klon, ktdia, klev, kflag
    logical, intent(in) :: ldphylin
    real(c_double), intent(in) :: paprsf(:, :), pt(:, :)
    real(c_double), intent(inout) :: pqsat(:, :)
    integer(c_int) :: status, jl, jk
    real(c_double) :: ice, inverse_interval, t, alpha, water, solid, w0, w1, w2, ratio, correction
    status = 2_c_int
    if (klon < 0 .or. klon > 4096 .or. klev < 0 .or. klev > 1024) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon .or. ktdia < 1 .or. ktdia > klev + 1) return
    if (.not. valid_real_matrix(paprsf, klon, klev)) return
    if (.not. valid_real_matrix(pt, klon, klev)) return
    if (.not. valid_real_matrix(pqsat, klon, klev)) return
    status = 0_c_int
    if (kidia > kfdia .or. ktdia > klev) return
    if (.not. ldphylin .and. kflag == 1) then
      ice = thermal%rticecu
      inverse_interval = thermal%rtwat_rticecu_r
    else
      ice = thermal%rtice
      inverse_interval = thermal%rtwat_rtice_r
    end if
    do jk = ktdia, klev
      do jl = kidia, kfdia
        t = pt(jl, jk)
        alpha = ordered_minimum(thermal%rtwat, t)
        alpha = ordered_maximum(ice, alpha)
        alpha = alpha - ice
        alpha = alpha*inverse_interval
        alpha = alpha*alpha
        alpha = ordered_minimum(1.0_c_double, alpha)
        w0 = t - constants%rtt
        w0 = thermal%r3les*w0
        w1 = t - thermal%r4les
        w0 = w0/w1
        water = public_exp(w0)
        if (ldphylin) water = thermal%r2es*water
        w0 = t - constants%rtt
        w0 = thermal%r3ies*w0
        w1 = t - thermal%r4ies
        w0 = w0/w1
        solid = public_exp(w0)
        if (ldphylin) solid = thermal%r2es*solid
        w0 = alpha*water
        w1 = 1.0_c_double - alpha
        w1 = w1*solid
        w0 = w0 + w1
        if (.not. ldphylin) w0 = thermal%r2es*w0
        ratio = w0/paprsf(jl, jk)
        ratio = ordered_minimum(0.5_c_double, ratio)
        w1 = constants%retv*ratio
        w1 = 1.0_c_double - w1
        correction = 1.0_c_double/w1
        w2 = ratio*correction
        pqsat(jl, jk) = w2
      end do
    end do
  end function
end module saturation_humidity_mod
