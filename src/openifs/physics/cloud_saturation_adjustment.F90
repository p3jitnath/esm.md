!> Complete cloud saturation adjustment from the generated ordered calculation.
!! Arrays use columns first and levels second. Pressure is in Pa, temperature
!! is in K, and water contents are in kg/kg. Input tendencies are per second.
!! The five local tendencies replace only the selected columns and levels;
!! inactive cells and unused diagnostic fields retain their incoming bytes.
!! Settings and stochastic parameters use native derived types and arrays.
module cloud_saturation_adjustment_mod
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yoecldp, only: tecldp
  use yoephli, only: tephli
  use yoecumf, only: tecumf
  use yoephy, only: tephy
  use spp_mod, only: tspp_config
  use yomcst, only: rg, rd, rcpd, retv, rtt
  use yoethf, only: r2es, r3les, r4les, r3ies, r4ies, rtwat, rtice, rtwat_rtice_r, &
                    r5alvcp, r5alscp, ralvdcp, ralsdcp, rkoop1, rkoop2
  use mixed_phase_saturation_mod, only: qsatmixadj
  implicit none
  private
  public :: cloud_satadj
  interface
    function scalar_exp(argument) bind(C, name="exp") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function scalar_exp
    subroutine cloud_supersatcheck(ydecldp, kidia, kfdia, klon, klev, kftliqice, &
                                   pt, pq, pa, pp, psurf, pt_adj, pq_adj, pa_adj, pl_adj, pi_adj)
      import tecldp, int32, real64
      type(tecldp), intent(in) :: ydecldp
      integer(int32), intent(in) :: kidia, kfdia, klon, klev, kftliqice
      real(real64), intent(in) :: pt(klon), pq(klon), pa(klon), pp(klon), psurf(klon)
      real(real64), intent(inout) :: pt_adj(klon), pq_adj(klon), pa_adj(klon), pl_adj(klon), pi_adj(klon)
    end subroutine cloud_supersatcheck
  end interface
contains
  !> Return the selected cloud-process rates without completing the model step.
  subroutine cloud_satadj(ydecldp, ydephli, ydecumf, ydephy, ydspp_config,&
   & kidia, kfdia, klon, klev, ktype, &
   & ptsphy, pap, paph, &
   & pt, pq, pa, &
   & pl, pi, &
   & ptendency_cml_t, ptendency_cml_q, ptendency_cml_a, &
   & ptendency_cml_l, ptendency_cml_i, &
   & phrsw, phrlw, &
   & ptendency_vdf_t, ptendency_vdf_q, &
   & pmfu, pmfd, pludeli, &
   & pvervel, pgp2dspp, &
   & ptendency_loc_t, ptendency_loc_q, ptendency_loc_a, &
   & ptendency_loc_l, ptendency_loc_i, &
   & pextra, kfldx)
    TYPE(TECLDP), INTENT(IN) :: YDECLDP
    TYPE(TEPHLI), INTENT(IN) :: YDEPHLI
    TYPE(TECUMF), INTENT(IN) :: YDECUMF
    TYPE(TEPHY), INTENT(IN) :: YDEPHY
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=int32), INTENT(IN) :: KIDIA
    INTEGER(KIND=int32), INTENT(IN) :: KFDIA
    INTEGER(KIND=int32), INTENT(IN) :: KLON             ! Number of grid points
    INTEGER(KIND=int32), INTENT(IN) :: KLEV             ! Number of levels
    INTEGER(KIND=int32), INTENT(IN) :: KTYPE(KLON)      ! Convection type 0-3
    REAL(KIND=real64), INTENT(IN) :: PTSPHY           ! Physics timestep
    REAL(KIND=real64), INTENT(IN) :: PAP(KLON, KLEV)   ! Pressure on full levels
    REAL(KIND=real64), INTENT(IN) :: PAPH(KLON, KLEV + 1)! Pressure on half levels
    REAL(KIND=real64), INTENT(IN) :: PT(KLON, KLEV)    ! Temperature (K)
    REAL(KIND=real64), INTENT(IN) :: PQ(KLON, KLEV)    ! Humidity (kg/kg)
    REAL(KIND=real64), INTENT(IN) :: PA(KLON, KLEV)    ! Cloud fraction (0-1)
    REAL(KIND=real64), INTENT(IN) :: PL(KLON, KLEV)    ! Cloud liquid (kg/kg)
    REAL(KIND=real64), INTENT(IN) :: PI(KLON, KLEV)    ! Cloud ice (kg/kg)
    REAL(KIND=real64), INTENT(IN) :: PTENDENCY_CML_T(KLON, KLEV) ! Temperature
    REAL(KIND=real64), INTENT(IN) :: PTENDENCY_CML_Q(KLON, KLEV) ! Humidity
    REAL(KIND=real64), INTENT(IN) :: PTENDENCY_CML_A(KLON, KLEV) ! Cloud fraction
    REAL(KIND=real64), INTENT(IN) :: PTENDENCY_CML_L(KLON, KLEV) ! Cloud liquid
    REAL(KIND=real64), INTENT(IN) :: PTENDENCY_CML_I(KLON, KLEV) ! Cloud ice
    REAL(KIND=real64), INTENT(IN) :: PHRSW(KLON, KLEV)   ! Short-wave heating rate
    REAL(KIND=real64), INTENT(IN) :: PHRLW(KLON, KLEV)   ! Long-wave heating rate
    REAL(KIND=real64), INTENT(IN) :: PTENDENCY_VDF_T(KLON, KLEV) ! Vert diff T
    REAL(KIND=real64), INTENT(IN) :: PTENDENCY_VDF_Q(KLON, KLEV) ! Vert diff Q
    REAL(KIND=real64), INTENT(IN) :: PMFU(KLON, KLEV)    ! Conv. mass flux up
    REAL(KIND=real64), INTENT(IN) :: PMFD(KLON, KLEV)    ! Conv. mass flux down
    REAL(KIND=real64), INTENT(IN) :: PLUDELI(KLON, KLEV, 4)! Conv. detrained liq/ice/vapor/T
    REAL(KIND=real64), INTENT(IN) :: PVERVEL(KLON, KLEV) ! Vertical velocity
    REAL(KIND=real64), INTENT(IN) :: PGP2DSPP(KLON, YDSPP_CONFIG%SM%NRFTOTAL) ! perturbation pattern
    REAL(KIND=real64), INTENT(INOUT) :: PTENDENCY_LOC_T(KLON, KLEV) ! Temperature
    REAL(KIND=real64), INTENT(INOUT) :: PTENDENCY_LOC_Q(KLON, KLEV) ! Humidity
    REAL(KIND=real64), INTENT(INOUT) :: PTENDENCY_LOC_A(KLON, KLEV) ! Cloud fraction
    REAL(KIND=real64), INTENT(INOUT) :: PTENDENCY_LOC_L(KLON, KLEV) ! Cloud liquid
    REAL(KIND=real64), INTENT(INOUT) :: PTENDENCY_LOC_I(KLON, KLEV) ! Cloud ice
    REAL(KIND=real64), INTENT(INOUT) :: PEXTRA(KLON, KLEV, KFLDX) ! extra fields
    INTEGER(KIND=int32), INTENT(IN) :: KFLDX ! Number of extra fields
    integer(int32) :: column, level, base, needed, pattern_velocity, pattern_humidity
    logical :: perturb_velocity, perturb_humidity
    real(real64), parameter :: cover_epsilon = transfer(int(z'3d06849b86a12b9b', int64), 0.0_real64)
    ! These rounded preparations also run for empty selections and layers.
    real(real64), volatile :: inverse_timestep, gas_heat_ratio
    real(real64) :: velocity_mean, velocity_magnitude, humidity_mean, humidity_magnitude
    real(real64) :: updated_temperature, updated_humidity, updated_cover, updated_liquid, updated_ice
    real(real64) :: liquid_fraction, ice_fraction, reciprocal_pressure, pressure_depth, weighted_timestep
    real(real64) :: temperature_forcing, humidity_forcing, layer_depth, vertical_velocity
    real(real64) :: original_saturation, clear_saturation, original_feedback, updated_saturation, unused_clear, updated_feedback
    real(real64) :: critical_humidity, forcing_temperature, forcing_humidity, humidity_change
    real(real64) :: new_cover, new_liquid, new_ice, existing_liquid, existing_ice, evaporated_liquid, evaporated_ice
    real(real64) :: evaporated_cover, pre_temperature, pre_humidity, pre_cover
    real(real64) :: supersaturated_liquid, supersaturated_ice, supersaturated_cover
    real(real64) :: liquid_increment, ice_increment, liquid_rate, ice_rate, humidity_rate, temperature_rate, cover_rate
    real(real64) :: pressure_limit, temperature_pressure, lower_bound, radiation, temporary, temporary2, temporary3
    real(real64) :: clear_area, environment_humidity, condensate, phase_amount, phase_deficit
    real(real64) :: child_t(1), child_q(1), child_a(1), child_p(1), child_surface(1)
    real(real64) :: child_dt(1), child_dq(1), child_da(1), child_dl(1), child_di(1)
    real(real64), volatile :: smallest_normal, half, subnormal
    type(ieee_round_type) :: rounding
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call abort()
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    if (transfer(subnormal, 0_int64) /= int(z'0008000000000000', int64)) call abort()
    if (klon < 0 .or. klon > 4096 .or. klev < 0 .or. klev > 512) call abort()
    if (kidia < 1 .or. kfdia > klon .or. kidia > kfdia + 1) call abort()
    if (ydecldp%ncldtop < 1 .or. ydecldp%ncldtop > klev + 1 .or. kfldx < 0) call abort()
    if (ydspp_config%sm%nrftotal < 0) call abort()
    base = 0
    if (ydephy%lbud23) base = 26
    needed = 0
    if (ydecldp%lcldbud_vertint) then
      if (klev < 43) call abort()
      needed = 1
      base = base + 1
    end if
    if (ydecldp%lcldbudc) then
      needed = base + 3
      base = base + 12
    end if
    if (ydecldp%lcldbudl) then
      needed = base + 4
      base = base + 22
    end if
    if (ydecldp%lcldbudi) needed = base + 4
    if (kfldx < needed) call abort()
    perturb_velocity = .false.
    perturb_humidity = .false.
    if (ydspp_config%lspp) then
      if (ydspp_config%pptr%qsatvervel > 0) then
        call read_parameter(ydspp_config, ydspp_config%pptr%qsatvervel, &
                            velocity_mean, velocity_magnitude, pattern_velocity)
        perturb_velocity = .true.
      end if
      if (ydspp_config%pptr%ramid > 0) then
        call read_parameter(ydspp_config, ydspp_config%pptr%ramid, &
                            humidity_mean, humidity_magnitude, pattern_humidity)
        perturb_humidity = .true.
      end if
    end if
    inverse_timestep = 1.0_real64/ptsphy
    gas_heat_ratio = rd/rcpd
    do level = 1, klev
      do column = kidia, kfdia
        if (level < ydecldp%ncldtop) then
          ptendency_loc_t(column, level) = 0.0_real64
          ptendency_loc_q(column, level) = 0.0_real64
          ptendency_loc_a(column, level) = 0.0_real64
          ptendency_loc_l(column, level) = 0.0_real64
          ptendency_loc_i(column, level) = 0.0_real64
          cycle
        end if
        temporary = ptsphy*ptendency_cml_t(column, level)
        updated_temperature = pt(column, level) + temporary
        temporary = ptsphy*ptendency_cml_q(column, level)
        updated_humidity = pq(column, level) + temporary
        temporary = ptsphy*ptendency_cml_a(column, level)
        updated_cover = pa(column, level) + temporary
        updated_cover = min(1.0_real64, updated_cover)
        updated_cover = max(0.0_real64, updated_cover)
        temporary = ptsphy*ptendency_cml_l(column, level)
        updated_liquid = pl(column, level) + temporary
        temporary = ptsphy*ptendency_cml_i(column, level)
        updated_ice = pi(column, level) + temporary
        if (perturb_velocity) then
          temporary = velocity_magnitude*pgp2dspp(column, pattern_velocity)
          temporary = velocity_mean + temporary
          temporary = scalar_exp(temporary)
          vertical_velocity = pvervel(column, level)*temporary
        else
          vertical_velocity = pvervel(column, level)
        end if
        pressure_depth = paph(column, level + 1) - paph(column, level)
        weighted_timestep = rg/pressure_depth
        weighted_timestep = ptsphy*weighted_timestep
        pressure_limit = pressure_depth*inverse_timestep
        temperature_pressure = gas_heat_ratio*pt(column, level)
        temperature_pressure = temperature_pressure/pap(column, level)
        lower_bound = -pressure_limit
        temporary = max(lower_bound, vertical_velocity)
        temporary = min(pressure_limit, temporary)
        radiation = phrsw(column, level) + phrlw(column, level)
        ! Negation precedes multiplication in the generated lower heat bound.
        lower_bound = -pressure_limit
        lower_bound = lower_bound*temperature_pressure
        radiation = max(lower_bound, radiation)
        lower_bound = pressure_limit*temperature_pressure
        radiation = min(lower_bound, radiation)
        radiation = radiation*ptsphy
        temperature_forcing = temperature_pressure*temporary
        temperature_forcing = temperature_forcing*ptsphy
        temperature_forcing = temperature_forcing + radiation
        temporary = pludeli(column, level, 4)*weighted_timestep
        temperature_forcing = temperature_forcing + temporary
        temporary = ptendency_vdf_t(column, level)*ptsphy
        temperature_forcing = temperature_forcing + temporary
        humidity_forcing = pludeli(column, level, 3)*weighted_timestep
        temporary = ptendency_vdf_q(column, level)*ptsphy
        humidity_forcing = humidity_forcing + temporary
        layer_depth = rd*pt(column, level)
        layer_depth = pap(column, level)/layer_depth
        layer_depth = layer_depth*rg
        layer_depth = pressure_depth/layer_depth
        reciprocal_pressure = 1.0_real64/pap(column, level)
        temporary = updated_liquid + updated_ice
        if (temporary > ydecldp%rlmin) then
          liquid_fraction = updated_liquid/temporary
          ice_fraction = 1.0_real64 - liquid_fraction
        else
          liquid_fraction = 0.0_real64
          ice_fraction = 0.0_real64
        end if
        if (perturb_humidity) then
          temporary = humidity_magnitude*pgp2dspp(column, pattern_humidity)
          temporary = humidity_mean + temporary
          temporary = scalar_exp(temporary)
          critical_humidity = ydecldp%ramid*temporary
          if (ydspp_config%lramidlimit1) critical_humidity = min(1.0_real64, critical_humidity)
        else
          critical_humidity = ydecldp%ramid
        end if
        temporary = pap(column, level)/paph(column, klev + 1)
        if (temporary > 0.8_real64) then
          temporary = temporary - 0.8_real64
          temporary = temporary/0.2_real64
          temporary = temporary*temporary
          temporary2 = 1.0_real64 - critical_humidity
          temporary = temporary2*temporary
          critical_humidity = critical_humidity + temporary
        end if
        call parent_thermodynamics(pt(column, level), reciprocal_pressure, &
                                   original_saturation, clear_saturation, original_feedback)
        call parent_thermodynamics(updated_temperature, reciprocal_pressure, &
                                   updated_saturation, unused_clear, updated_feedback)
        forcing_temperature = pt(column, level) + temperature_forcing
        forcing_temperature = max(forcing_temperature, 160.0_real64)
        forcing_humidity = original_saturation + humidity_forcing
        humidity_change = qsatmixadj(forcing_temperature, forcing_humidity, pap(column, level))
        humidity_change = humidity_change - forcing_humidity
        new_cover = 0.0_real64
        new_liquid = 0.0_real64
        new_ice = 0.0_real64
        existing_ice = 0.0_real64
        existing_liquid = 0.0_real64
        evaporated_liquid = 0.0_real64
        evaporated_ice = 0.0_real64
        evaporated_cover = 0.0_real64
        temporary = -ydecldp%rlmin
        if (humidity_change <= temporary) then
          temporary = 1.0_real64 - cover_epsilon
          if (pa(column, level) < temporary) then
            environment_humidity = pa(column, level)*original_saturation
            environment_humidity = pq(column, level) - environment_humidity
            clear_area = 1.0_real64 - pa(column, level)
            temporary = max(cover_epsilon, clear_area)
            environment_humidity = environment_humidity/temporary
            environment_humidity = max(0.0_real64, environment_humidity)
            temporary = critical_humidity*clear_saturation
            if (environment_humidity >= temporary .and. environment_humidity < clear_saturation) then
              new_cover = -clear_area
              new_cover = new_cover*humidity_change
              temporary = clear_saturation - environment_humidity
              temporary = temporary + temporary
              temporary2 = max(temporary, cover_epsilon)
              new_cover = new_cover/temporary2
              new_cover = min(new_cover, clear_area)
              condensate = -humidity_change
              condensate = condensate*0.5_real64
              condensate = condensate*new_cover
              temporary2 = max(cover_epsilon, clear_area)
              temporary = temporary/temporary2
              temporary = -temporary
              if (humidity_change < temporary) then
                temporary = pa(column, level) - 1.0_real64
                temporary = temporary*humidity_change
                temporary = temporary - clear_saturation
                temporary = temporary + pq(column, level)
                condensate = min(condensate, temporary)
              end if
              condensate = max(condensate, 0.0_real64)
              if (condensate < ydecldp%rlmin .or. clear_area < cover_epsilon .or. condensate == 0.0_real64) then
                condensate = 0.0_real64
                new_cover = 0.0_real64
              end if
              if (pt(column, level) > ydecldp%rthomo) then
                new_liquid = condensate
              else
                new_ice = condensate
              end if
            end if
          end if
        end if
        if (pa(column, level) > cover_epsilon) then
          temporary = -ydecldp%rlmin
          if (humidity_change <= temporary) then
            condensate = -humidity_change
            condensate = max(condensate, 0.0_real64)
            temporary = updated_humidity - updated_saturation
            temporary = temporary/updated_feedback
            temporary = max(temporary, 0.0_real64)
            condensate = min(condensate, temporary)
            condensate = pa(column, level)*condensate
            if (condensate < ydecldp%rlmin) condensate = 0.0_real64
            if (pt(column, level) > ydecldp%rthomo) then
              existing_liquid = condensate
            else
              existing_ice = condensate
            end if
          end if
        end if
        if (humidity_change > 0.0_real64) then
          temporary = updated_liquid + updated_ice
          if (temporary > 0.0_real64) then
            condensate = pa(column, level)*humidity_change
            condensate = min(condensate, temporary)
            evaporated_liquid = liquid_fraction*condensate
            evaporated_ice = ice_fraction*condensate
          end if
        end if
        pre_temperature = existing_liquid + new_liquid
        pre_temperature = pre_temperature - evaporated_liquid
        pre_temperature = ralvdcp*pre_temperature
        pre_temperature = updated_temperature + pre_temperature
        temporary = existing_ice + new_ice
        temporary = temporary - evaporated_ice
        temporary = ralsdcp*temporary
        pre_temperature = pre_temperature + temporary
        pre_humidity = evaporated_liquid - existing_liquid
        pre_humidity = pre_humidity - new_liquid
        pre_humidity = updated_humidity + pre_humidity
        temporary = evaporated_ice - existing_ice
        temporary = temporary - new_ice
        pre_humidity = pre_humidity + temporary
        pre_cover = updated_cover + new_cover
        pre_cover = pre_cover - evaporated_cover
        pre_cover = min(pre_cover, 1.0_real64)
        if (pre_cover < ydecldp%ramin) pre_cover = 0.0_real64
        child_t(1) = pre_temperature
        child_q(1) = pre_humidity
        child_a(1) = pre_cover
        child_p(1) = pap(column, level)
        child_surface(1) = paph(column, klev + 1)
        call cloud_supersatcheck(ydecldp, 1_int32, 1_int32, 1_int32, klev, 2_int32, &
                                 child_t, child_q, child_a, child_p, child_surface, child_dt, child_dq, child_da, &
                                 child_dl, child_di)
        phase_amount = child_dl(1) + child_di(1)
        if (pre_temperature > ydecldp%rthomo) then
          supersaturated_liquid = phase_amount
          supersaturated_ice = 0.0_real64
        else
          supersaturated_ice = phase_amount
          supersaturated_liquid = 0.0_real64
        end if
        supersaturated_cover = child_da(1)
        liquid_increment = existing_liquid + new_liquid
        liquid_increment = liquid_increment + supersaturated_liquid
        liquid_increment = liquid_increment - evaporated_liquid
        liquid_rate = liquid_increment*inverse_timestep
        temperature_rate = ralvdcp*liquid_increment
        temperature_rate = temperature_rate*inverse_timestep
        ice_increment = existing_ice + new_ice
        ice_increment = ice_increment + supersaturated_ice
        ice_increment = ice_increment - evaporated_ice
        ice_rate = ice_increment*inverse_timestep
        temporary = ralsdcp*ice_increment
        temporary = temporary*inverse_timestep
        temperature_rate = temperature_rate + temporary
        humidity_rate = evaporated_liquid - existing_liquid
        humidity_rate = humidity_rate - new_liquid
        humidity_rate = humidity_rate - supersaturated_liquid
        humidity_rate = humidity_rate + evaporated_ice
        humidity_rate = humidity_rate - existing_ice
        humidity_rate = humidity_rate - new_ice
        humidity_rate = humidity_rate - supersaturated_ice
        humidity_rate = humidity_rate*inverse_timestep
        cover_rate = updated_cover + new_cover
        cover_rate = cover_rate - evaporated_cover
        cover_rate = cover_rate + supersaturated_cover
        cover_rate = min(cover_rate, 1.0_real64)
        if (cover_rate < ydecldp%ramin) cover_rate = 0.0_real64
        cover_rate = cover_rate - updated_cover
        cover_rate = cover_rate*inverse_timestep
        phase_deficit = liquid_rate*ptsphy
        phase_deficit = updated_liquid + phase_deficit
        temporary = -ydecldp%rlmin
        if (phase_deficit < temporary) call abort()
        if (phase_deficit < 0.0_real64) then
          liquid_rate = liquid_rate - phase_deficit
          humidity_rate = humidity_rate + phase_deficit
          phase_deficit = ralvdcp*phase_deficit
          temperature_rate = temperature_rate - phase_deficit
        end if
        phase_deficit = ice_rate*ptsphy
        phase_deficit = updated_ice + phase_deficit
        temporary = -ydecldp%rlmin
        if (phase_deficit < temporary) call abort()
        if (phase_deficit < 0.0_real64) then
          ice_rate = ice_rate - phase_deficit
          humidity_rate = humidity_rate + phase_deficit
          phase_deficit = ralsdcp*phase_deficit
          temperature_rate = temperature_rate - phase_deficit
        end if
        ptendency_loc_t(column, level) = temperature_rate
        ptendency_loc_q(column, level) = humidity_rate
        ptendency_loc_a(column, level) = cover_rate
        ptendency_loc_l(column, level) = liquid_rate
        ptendency_loc_i(column, level) = ice_rate
        base = 0
        if (ydephy%lbud23) base = 26
        if (ydecldp%lcldbud_vertint) then
          call add_vertical(new_cover, 1, .false.)
          call add_vertical(evaporated_cover, 2, .false.)
          call add_vertical(supersaturated_cover, 3, .false.)
          call add_vertical(new_liquid, 15, .false.)
          call add_vertical(existing_liquid, 16, .false.)
          call add_vertical(evaporated_liquid, 17, .true.)
          call add_vertical(supersaturated_liquid, 18, .false.)
          call add_vertical(new_ice, 40, .false.)
          call add_vertical(existing_ice, 41, .false.)
          call add_vertical(evaporated_ice, 42, .true.)
          call add_vertical(supersaturated_ice, 43, .false.)
          base = base + 1
        end if
        if (ydecldp%lcldbudc) then
          call add_budget(new_cover, base + 1, .false.)
          call add_budget(evaporated_cover, base + 2, .false.)
          call add_budget(supersaturated_cover, base + 3, .false.)
          base = base + 12
        end if
        if (ydecldp%lcldbudl) then
          call add_budget(new_liquid, base + 1, .false.)
          call add_budget(existing_liquid, base + 2, .false.)
          call add_budget(evaporated_liquid, base + 3, .true.)
          call add_budget(supersaturated_liquid, base + 4, .false.)
          base = base + 22
        end if
        if (ydecldp%lcldbudi) then
          call add_budget(new_ice, base + 1, .false.)
          call add_budget(existing_ice, base + 2, .false.)
          call add_budget(evaporated_ice, base + 3, .true.)
          call add_budget(supersaturated_ice, base + 4, .false.)
        end if
      end do
    end do
  contains
    !> Add a process rate weighted by physical layer depth to field one.
    subroutine add_vertical(amount, diagnostic_level, subtract)
      real(real64), intent(in) :: amount
      integer, intent(in) :: diagnostic_level
      logical, intent(in) :: subtract
      real(real64) :: increment
      increment = amount*inverse_timestep
      increment = increment*layer_depth
      if (subtract) then
        pextra(column, diagnostic_level, 1) = pextra(column, diagnostic_level, 1) - increment
      else
        pextra(column, diagnostic_level, 1) = pextra(column, diagnostic_level, 1) + increment
      end if
    end subroutine add_vertical
    !> Add a process rate to its selected ordinary diagnostic field.
    subroutine add_budget(amount, field, subtract)
      real(real64), intent(in) :: amount
      integer, intent(in) :: field
      logical, intent(in) :: subtract
      real(real64) :: increment
      increment = amount*inverse_timestep
      if (subtract) then
        pextra(column, level, field) = pextra(column, level, field) - increment
      else
        pextra(column, level, field) = pextra(column, level, field) + increment
      end if
    end subroutine add_budget
  end subroutine cloud_satadj

  !> Read only the mean, magnitude and pattern index used by one perturbation.
  subroutine read_parameter(configuration, index, mean, magnitude, pattern)
    type(tspp_config), intent(in) :: configuration
    integer(int32), intent(in) :: index
    real(real64), intent(out) :: mean, magnitude
    integer(int32), intent(out) :: pattern
    if (.not. allocated(configuration%sm%pn)) call abort()
    if (index < lbound(configuration%sm%pn, 1) .or. index > ubound(configuration%sm%pn, 1)) call abort()
    pattern = configuration%sm%pn(index)%mp
    if (pattern < 1 .or. pattern > configuration%sm%nrftotal) call abort()
    mean = configuration%sm%pn(index)%mu(1)
    magnitude = configuration%sm%pn(index)%xmag(1)
  end subroutine read_parameter

  !> Evaluate mixed saturation, the clear-air limit and latent feedback.
  !! Temperature is in K; reciprocal pressure is in Pa^-1. The humidity
  !! outputs are in kg/kg, and the feedback denominator is dimensionless.
  subroutine parent_thermodynamics(temperature, reciprocal_pressure, mixed, clear, feedback)
    real(real64), intent(in) :: temperature, reciprocal_pressure
    real(real64), intent(out) :: mixed, clear, feedback
    real(real64) :: fraction, water_exp, ice_exp, argument, denominator
    real(real64) :: water_factor, koop_factor, mixed_factor, correction
    real(real64) :: water_feedback, ice_feedback, temporary
    fraction = min(rtwat, temperature)
    fraction = max(rtice, fraction)
    fraction = fraction - rtice
    fraction = fraction*rtwat_rtice_r
    fraction = fraction*fraction
    fraction = min(1.0_real64, fraction)
    argument = temperature - rtt
    argument = r3les*argument
    denominator = temperature - r4les
    argument = argument/denominator
    water_exp = scalar_exp(argument)
    argument = temperature - rtt
    argument = r3ies*argument
    denominator = temperature - r4ies
    argument = argument/denominator
    ice_exp = scalar_exp(argument)
    water_factor = r2es*water_exp
    water_factor = water_factor*reciprocal_pressure
    water_factor = min(0.5_real64, water_factor)
    if (temperature >= rtt) then
      koop_factor = water_exp
    else
      koop_factor = ice_exp
    end if
    koop_factor = r2es*koop_factor
    koop_factor = koop_factor*reciprocal_pressure
    koop_factor = min(0.5_real64, koop_factor)
    temporary = rkoop2*temperature
    temporary = rkoop1 - temporary
    koop_factor = koop_factor*temporary
    koop_factor = min(koop_factor, water_factor)
    correction = retv*koop_factor
    correction = 1.0_real64 - correction
    koop_factor = koop_factor/correction
    mixed_factor = fraction*water_exp
    temporary = 1.0_real64 - fraction
    temporary = temporary*ice_exp
    mixed_factor = mixed_factor + temporary
    mixed_factor = r2es*mixed_factor
    mixed_factor = mixed_factor*reciprocal_pressure
    mixed_factor = min(0.5_real64, mixed_factor)
    correction = retv*mixed_factor
    correction = 1.0_real64 - correction
    correction = 1.0_real64/correction
    mixed = mixed_factor*correction
    clear = koop_factor + mixed
    clear = 0.5_real64*clear
    water_feedback = temperature - r4les
    water_feedback = water_feedback*water_feedback
    water_feedback = 1.0_real64/water_feedback
    temporary = fraction*r5alvcp
    water_feedback = temporary*water_feedback
    ice_feedback = temperature - r4ies
    ice_feedback = ice_feedback*ice_feedback
    ice_feedback = 1.0_real64/ice_feedback
    temporary = 1.0_real64 - fraction
    temporary = temporary*r5alscp
    ice_feedback = temporary*ice_feedback
    feedback = water_feedback + ice_feedback
    temporary = mixed*correction
    temporary = temporary*feedback
    feedback = 1.0_real64 + temporary
  end subroutine parent_thermodynamics
end module cloud_saturation_adjustment_mod
