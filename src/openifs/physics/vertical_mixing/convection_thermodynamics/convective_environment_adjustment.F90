!> Complete two-pass convective environment adjustment.
module convective_environment_mod
  use iso_c_binding, only: c_double, c_int
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoephli, only: tephli
  use saturation_humidity_mod, only: ordered_minimum, ordered_maximum, public_exp, valid_real_matrix, valid_real_vector
  implicit none
  private
  public :: cuinin_environment, adjust_environment_cell
contains
  !> Adjust one admitted environment or evaporation cell in two full passes.
  !! T and Q are temperature in K and humidity in kg/kg; INVERSE_PRESSURE
  !! is the caller's once-rounded1/Pa value. ICE and INVERSE_INTERVAL choose
  !! the standard or convective phase law. MODE2 retains its two evaporation
  !! clamps; the other environment modes use the unclamped correction.
  !! All scalar operations follow the selected generated body. This helper
  !! allocates no storage and supplies no additional physical stage.
  subroutine adjust_environment_cell(constants, thermal, ice, inverse_interval, mode, t, q, inverse_pressure)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: ice, inverse_interval, inverse_pressure
    integer(c_int), intent(in) :: mode
    real(c_double), intent(inout) :: t, q
    real(c_double) :: alpha, water, solid, z, correction, qsat, derivative, first_cond, heat
    real(c_double) :: w0, w1, w2, w3
    real(c_double), volatile :: cond
    integer :: pass
    first_cond = 0.0_c_double
    do pass = 1, 2
      alpha = ordered_minimum(thermal%rtwat, t)
      alpha = ordered_maximum(ice, alpha)
      alpha = alpha - ice
      alpha = alpha*inverse_interval
      alpha = alpha*alpha
      alpha = ordered_minimum(1.0_c_double, alpha)
      w1 = t - constants%rtt
      w1 = thermal%r3les*w1
      w0 = t - thermal%r4les
      w0 = w1/w0
      water = public_exp(w0)
      w1 = t - constants%rtt
      w1 = thermal%r3ies*w1
      w0 = t - thermal%r4ies
      w0 = w1/w0
      solid = public_exp(w0)
      w2 = 1.0_c_double - alpha
      w0 = w2*solid
      w2 = alpha*water
      w0 = w2 + w0
      w0 = thermal%r2es*w0
      w0 = w0*inverse_pressure
      z = ordered_minimum(0.5_c_double, w0)
      w1 = constants%retv*z
      w1 = 1.0_c_double - w1
      correction = 1.0_c_double/w1
      qsat = z*correction
      w1 = t - thermal%r4les
      w1 = w1*w1
      w1 = 1.0_c_double/w1
      w3 = alpha*thermal%r5alvcp
      w3 = w3*w1
      w1 = t - thermal%r4ies
      w1 = w1*w1
      w1 = 1.0_c_double/w1
      w2 = 1.0_c_double - alpha
      w2 = w2*thermal%r5alscp
      w2 = w2*w1
      derivative = w3 + w2
      w1 = qsat*correction
      w1 = w1*derivative
      w1 = 1.0_c_double + w1
      w0 = q - qsat
      cond = w0/w1
      if (mode == 2) then
        if (pass == 1 .or. first_cond == 0.0_c_double) cond = ordered_minimum(cond, 0.0_c_double)
      end if
      if (pass == 1) first_cond = cond
      w2 = alpha*thermal%ralvdcp
      w1 = 1.0_c_double - alpha
      w1 = w1*thermal%ralsdcp
      heat = w2 + w1
      w1 = heat*cond
      t = t + w1
      q = q - cond
    end do
  end subroutine
  !> Run the complete selected mode3 child using native Fortran arguments.
  !! After the two readonly providers, arguments keep the original CUADJTQ
  !! names and order. YDEPHLI uses the canonical data-only TEPHLI identity.
  !! PSP has at least KLON Pa values; PT and PQ have first extent KLON and
  !! at least KLEV levels. PT/PQ mutate only KIDIA:KFDIA at level KK.
  !! They are disjoint from each other and from all readonly inputs.
  !! LDFLAG and optional LDOFLAG are unconsumed for this mode. Return0 for
  !! a supported call or empty interval, otherwise2 before any output write.
  !! Canonical quiet missing cells follow the retained contract; the caller
  !! supplies the admitted domain and establishes the floating environment.
  function cuinin_environment(constants,thermal,ydephli,kidia,kfdia,klon,klev,kk,psp,pt,pq,ldflag,kcall,ldoflag) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tephli), intent(in) :: ydephli
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kk, kcall
    real(c_double), intent(in) :: psp(:)
    real(c_double), intent(inout) :: pt(:, :), pq(:, :)
    logical, intent(in) :: ldflag(:)
    logical, intent(in), optional :: ldoflag(:)
    integer(c_int) :: status, jl
    real(c_double) :: t, q, inverse_pressure
    status = 2_c_int
    if (kcall /= 3 .or. ydephli%lphylin) return
    if (klon < 1 .or. klev < 1 .or. kk < 1 .or. kk > klev) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. valid_real_vector(psp, klon)) return
    if (.not. valid_real_matrix(pt, klon, klev)) return
    if (.not. valid_real_matrix(pq, klon, klev)) return
    status = 0_c_int
    do jl = kidia, kfdia
      t = pt(jl, kk)
      q = pq(jl, kk)
      inverse_pressure = 1.0_c_double/psp(jl)
      call adjust_environment_cell(constants, thermal, thermal%rticecu, thermal%rtwat_rticecu_r, 3_c_int, t, q, inverse_pressure)
      pt(jl, kk) = t
      pq(jl, kk) = q
    end do
  end function
end module convective_environment_mod
