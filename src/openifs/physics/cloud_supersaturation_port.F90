!> Adjust supersaturation in the exact stage order of cloud_supersatcheck.S.
!! Temperature is in K, pressure in Pa, and water amounts in kg/kg.
!! Original type and constant modules supply definitions and frozen data only.
!! The caller retains the accepted physical activity and disjoint-owner checks.
subroutine cloud_supersatcheck(ydecldp, kidia, kfdia, klon, klev, kftliqice, &
                               pt, pq, pa, pp, psurf, pt_adj, pq_adj, pa_adj, pl_adj, pi_adj)
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, &
                             operator(/=)
  use yoecldp, only: tecldp
  use yomcst, only: retv, rtt
  use yoethf, only: r2es, r3les, r3ies, r4les, r4ies, rtwat, rtice, &
                    rtwat_rtice_r, rkoop1, rkoop2, r5alvcp, r5alscp, ralvdcp, ralsdcp
  implicit none
  type(tecldp), intent(in) :: ydecldp
  integer(int32), intent(in) :: kidia, kfdia, klon, klev, kftliqice
  real(real64), intent(in) :: pt(klon), pq(klon), pa(klon), pp(klon), psurf(klon)
  real(real64), intent(inout) :: pt_adj(klon), pq_adj(klon), pa_adj(klon), pl_adj(klon), pi_adj(klon)
  integer(int32) :: column
  type(ieee_round_type) :: rounding
  real(real64), volatile :: gradual_operand, gradual_scale
  real(real64) :: gradual_probe
  real(real64) :: constants(16), relaxation, homogeneous_temperature
  real(real64) :: raw_temperature, temperature, humidity, cloud, inverse_pressure
  real(real64) :: liquid_fraction, water_exponential, ice_exponential, water_factor
  real(real64) :: clear_humidity, mixed_correction, mixed_humidity, feedback
  real(real64) :: middle_humidity, condensation, cloud_increment, heating, ice_fraction
  real(real64) :: a, b, c, d
  interface
    function selected_exp(value) bind(c, name="exp") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_exp
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface

  call ieee_get_rounding_mode(rounding)
  if (rounding /= ieee_nearest) call reject_contract()
  ! This exact subnormal does not change status under gradual underflow.
  gradual_operand = tiny(1.0_real64)
  gradual_scale = 0.5_real64
  gradual_probe = gradual_operand*gradual_scale
  if (gradual_probe == 0.0_real64) call reject_contract()
  if (kidia < 1_int32 .or. kfdia < 0_int32 .or. klon < 0_int32 .or. klon > 4096_int32) call reject_contract()
  if (klev < 0_int32 .or. klev > 512_int32) call reject_contract()
  if (kidia > klon + 1_int32 .or. kfdia > klon) call reject_contract()
  if (kftliqice /= 1_int32 .and. kftliqice /= 2_int32) call reject_contract()
  if (kidia > kfdia) return

  constants = [retv, rtt, r2es, r3les, r3ies, r4les, r4ies, rtwat, rtice, &
               rtwat_rtice_r, rkoop1, rkoop2, r5alvcp, r5alscp, ralvdcp, ralsdcp]
  relaxation = ydecldp%rssicefactor
  homogeneous_temperature = ydecldp%rthomo
  do column = kidia, kfdia
    raw_temperature = pt(column)
    temperature = max(raw_temperature, 160.0_real64)
    humidity = pq(column)
    cloud = min(pa(column), 1.0_real64)
    if (.not. (cloud > 0.0_real64)) cloud = 0.0_real64
    inverse_pressure = 1.0_real64/pp(column)

    liquid_fraction = min(constants(8), temperature)
    liquid_fraction = max(constants(9), liquid_fraction)
    liquid_fraction = liquid_fraction - constants(9)
    liquid_fraction = liquid_fraction*constants(10)
    liquid_fraction = liquid_fraction*liquid_fraction
    liquid_fraction = min(liquid_fraction, 1.0_real64)

    a = temperature - constants(2)
    a = constants(4)*a
    b = temperature - constants(6)
    a = a/b
    water_exponential = selected_exp(a)
    a = temperature - constants(2)
    a = constants(5)*a
    b = temperature - constants(7)
    a = a/b
    ice_exponential = selected_exp(a)

    a = constants(3)*water_exponential
    a = a*inverse_pressure
    a = min(a, 0.5_real64)
    water_factor = a
    if (temperature >= constants(2)) then
      a = water_exponential
    else
      a = ice_exponential
    end if
    a = constants(3)*a
    a = a*inverse_pressure
    a = min(a, 0.5_real64)

    b = constants(12)*temperature
    c = constants(11)
    b = c - b
    a = a*b
    a = min(a, water_factor)
    b = constants(1)*a
    b = 1.0_real64 - b
    a = a/b
    clear_humidity = a

    a = liquid_fraction*water_exponential
    b = 1.0_real64 - liquid_fraction
    b = b*ice_exponential
    a = a + b
    a = constants(3)*a
    a = a*inverse_pressure
    a = min(a, 0.5_real64)
    b = constants(1)*a
    b = 1.0_real64 - b
    mixed_correction = 1.0_real64/b
    mixed_humidity = a*mixed_correction

    a = temperature - constants(6)
    a = a*a
    a = 1.0_real64/a
    b = liquid_fraction*constants(13)
    a = b*a
    b = temperature - constants(7)
    b = b*b
    b = 1.0_real64/b
    c = 1.0_real64 - liquid_fraction
    c = c*constants(14)
    b = c*b
    a = a + b
    b = mixed_humidity*mixed_correction
    a = b*a
    a = 1.0_real64 + a
    feedback = a

    a = clear_humidity + mixed_humidity
    middle_humidity = 0.5_real64*a
    a = cloud*mixed_humidity
    b = 1.0_real64 - cloud
    b = b*middle_humidity
    a = a + b
    condensation = humidity - a
    if (.not. (condensation > 0.0_real64)) condensation = 0.0_real64
    cloud_increment = 0.0_real64
    if (condensation > 1.0e-14_real64) then
      a = 1.0_real64 - liquid_fraction
      a = a*relaxation
      a = liquid_fraction + a
      b = 1.0_real64 - cloud
      a = b*a
      cloud_increment = a
      cloud = cloud + a
      a = cloud*mixed_humidity
      b = 1.0_real64 - cloud
      b = b*middle_humidity
      a = a + b
      condensation = humidity - a
      condensation = condensation/feedback
    end if

    a = liquid_fraction*constants(15)
    ice_fraction = 1.0_real64 - liquid_fraction
    b = ice_fraction*constants(16)
    a = a + b
    heating = a*condensation
    pt_adj(column) = heating
    pq_adj(column) = -condensation
    pa_adj(column) = cloud_increment
    if (kftliqice == 1_int32) then
      a = condensation*liquid_fraction
      b = condensation*ice_fraction
    else
      a = raw_temperature + heating
      if (a >= homogeneous_temperature) then
        a = condensation
        b = 0.0_real64
      else
        a = 0.0_real64
        b = condensation
      end if
    end if
    pl_adj(column) = a
    pi_adj(column) = b
  end do
end subroutine cloud_supersatcheck
