!> All selected normal-physics convective saturation adjustment modes.
module convective_saturation_adjustment_mod
  use iso_c_binding, only: c_double, c_int
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoephli, only: tephli
  use saturation_humidity_mod, only: ordered_minimum,ordered_maximum,numeric_maximum,public_exp,valid_real_matrix,valid_real_vector
  use convective_environment_mod, only: cuinin_environment, adjust_environment_cell
  implicit none
  private
  public :: cuadjtq
contains
  !> Preserve the condensation branch's reciprocal and second-pass formulas.
  !! T and Q mutate in K and kg/kg. PURE_LIQUID selects the source liquid
  !! population. INVERSE_PRESSURE is the once-rounded pressure reciprocal.
  !! The volatile correction retains the second raw calculation even when
  !! a zero first correction subsequently replaces its result.
  subroutine adjust_condensation_cell(constants, thermal, pure_liquid, t, q, inverse_pressure)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    logical, intent(in) :: pure_liquid
    real(c_double), intent(inout) :: t, q
    real(c_double), intent(in) :: inverse_pressure
    real(c_double) :: alpha, zl, zi, water, solid, z, correction, derivative, first_cond, heat
    real(c_double) :: w0, w1, w2, w3, w4
    real(c_double), volatile :: cond
    integer :: pass
    first_cond = 0.0_c_double
    do pass = 1, 2
      if (pure_liquid) then
        alpha = 1.0_c_double
      else
        alpha = ordered_minimum(thermal%rtwat, t)
        alpha = ordered_maximum(thermal%rticecu, alpha)
        alpha = alpha - thermal%rticecu
        alpha = alpha*thermal%rtwat_rticecu_r
        alpha = alpha*alpha
        alpha = ordered_minimum(1.0_c_double, alpha)
      end if
      w1 = t - thermal%r4les
      zl = 1.0_c_double/w1
      w0 = t - constants%rtt
      w0 = thermal%r3les*w0
      w0 = w0*zl
      water = public_exp(w0)
      if (pure_liquid) then
        w0 = water
      else
        w1 = t - thermal%r4ies
        zi = 1.0_c_double/w1
        w0 = t - constants%rtt
        w0 = thermal%r3ies*w0
        w0 = w0*zi
        solid = public_exp(w0)
        w2 = 1.0_c_double - alpha
        w0 = w2*solid
        w2 = alpha*water
        w0 = w2 + w0
      end if
      w0 = thermal%r2es*w0
      z = w0*inverse_pressure
      if (pass == 1) then
        z = ordered_minimum(0.5_c_double, z)
      else
        ! Source MINJ keeps its two subtractions and cancellation rounding.
        w1 = 0.5_c_double - z
        w2 = abs(w1)
        w2 = w2 - w1
        w2 = 0.5_c_double*w2
        z = z - w2
      end if
      w1 = constants%retv*z
      correction = 1.0_c_double - w1
      w1 = zl*zl
      if (pure_liquid) then
        derivative = thermal%r5alvcp*w1
      else
        w3 = alpha*thermal%r5alvcp
        w3 = w3*w1
        w1 = zi*zi
        w2 = 1.0_c_double - alpha
        w2 = w2*thermal%r5alscp
        w2 = w2*w1
        derivative = w3 + w2
      end if
      w2 = correction*correction
      w4 = q*w2
      w1 = z*correction
      w4 = w4 - w1
      w0 = z*derivative
      w0 = w2 + w0
      cond = w4/w0
      if (pass == 1) then
        cond = numeric_maximum(cond, 0.0_c_double)
        first_cond = cond
      elseif (first_cond == 0.0_c_double) then
        cond = 0.0_c_double
      end if
      if (pure_liquid) then
        heat = thermal%ralvdcp
      else
        w2 = alpha*thermal%ralvdcp
        w1 = 1.0_c_double - alpha
        w1 = w1*thermal%ralsdcp
        heat = w2 + w1
      end if
      w1 = heat*cond
      t = t + w1
      q = q - cond
    end do
  end subroutine
  !> Adjust selected temperature and humidity cells for mode KCALL.
  !! Providers are readonly completed native records. Remaining arguments
  !! keep original CUADJTQ names/order. PT and PQ are contiguous native
  !! views with first extent KLON and at least KLEV levels; PSP and used
  !! flags have at least KLON elements. Extra cells remain unchanged.
  !! Temperatures use K, pressures Pa and humidity kg/kg. Used physical
  !! cells meet the retained finite or canonical quiet-missing contract.
  !! PT/PQ and readonly owners are disjoint. The caller establishes nearest
  !! rounding and gradual underflow; this child makes no floating probe.
  !! Modes0/5 use all selected columns; modes1/2/4/6 use LDFLAG. Mode3
  !! calls the owned environment leaf. Mode6 requires optional LDOFLAG.
  !! Return0 for supported work, empty intervals or unknown no-op modes.
  !! Return2 before writes for unsupported metadata or LPHYLIN=true.
  function cuadjtq(constants, thermal, ydephli, kidia, kfdia, klon, klev, kk, psp, pt, pq, ldflag, kcall, ldoflag) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tephli), intent(in) :: ydephli
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kk, kcall
    real(c_double), intent(in) :: psp(:)
    real(c_double), intent(inout) :: pt(:, :), pq(:, :)
    logical, intent(in) :: ldflag(:)
    logical, intent(in), optional :: ldoflag(:)
    integer(c_int) :: status, jl
    logical :: pure_liquid
    real(c_double) :: t, q, inverse_pressure, ice, inverse_interval
    status = 2_c_int
    if (ydephli%lphylin) return
    if (kcall == 3) then
      status = cuinin_environment(constants, thermal, ydephli, kidia, kfdia, klon, klev, kk, psp, pt, pq, ldflag, kcall, ldoflag)
      return
    end if
    if (kcall < 0 .or. kcall > 6) then
      status = 0_c_int
      return
    end if
    if (kcall == 6) then
      if (.not. present(ldoflag)) return
    end if
    if (klon < 1 .or. klev < 1 .or. kk < 1 .or. kk > klev) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. valid_real_vector(psp, klon)) return
    if (.not. valid_real_matrix(pt, klon, klev)) return
    if (.not. valid_real_matrix(pq, klon, klev)) return
    if (kcall /= 0 .and. kcall /= 5) then
      if (.not. is_contiguous(ldflag) .or. size(ldflag) < klon) return
    end if
    if (kcall == 6) then
      if (.not. is_contiguous(ldoflag) .or. size(ldoflag) < klon) return
    end if
    status = 0_c_int
    if (kidia > kfdia) return
    if (kcall == 0 .or. kcall == 4 .or. kcall == 5) then
      ice = thermal%rtice
      inverse_interval = thermal%rtwat_rtice_r
    else
      ice = thermal%rticecu
      inverse_interval = thermal%rtwat_rticecu_r
    end if
    do jl = kidia, kfdia
      if (kcall /= 0 .and. kcall /= 5) then
        if (.not. ldflag(jl)) cycle
      end if
      pure_liquid = .false.
      if (kcall == 6) pure_liquid = ldoflag(jl)
      t = pt(jl, kk)
      q = pq(jl, kk)
      inverse_pressure = 1.0_c_double/psp(jl)
      if (kcall == 1 .or. kcall == 6) then
        call adjust_condensation_cell(constants, thermal, pure_liquid, t, q, inverse_pressure)
      else
        call adjust_environment_cell(constants, thermal, ice, inverse_interval, kcall, t, q, inverse_pressure)
      end if
      pt(jl, kk) = t
      pq(jl, kk) = q
    end do
  end function
end module convective_saturation_adjustment_mod
