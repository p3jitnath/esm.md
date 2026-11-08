!> Complete moist cloud ascent with owned native numerical children.
module moist_cloud_ascent_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoephli, only: tephli
  use yoecldp, only: tecldp
  use yoecumf, only: tecumf
  use spp_mod, only: tspp_config
  use convection_leaf_contract_mod, only: real_matrix, real_vector
  use saturation_humidity_mod, only: ordered_minimum, ordered_maximum, public_exp
  use convection_midlevel_base_mod, only: cubasmcn
  use convection_entrainment_mod, only: cuentr
  use convective_saturation_adjustment_mod, only: cuadjtq
  use convective_energy_diagnostics_mod, only: energy_pow
  implicit none
  private
  public :: cuascn, cuascn_raw
  interface cuascn_raw
    module procedure cuascn
  end interface
  interface
    subroutine exit_unsupported(code) bind(c, name="_exit")
      import c_int
      integer(c_int), value :: code
    end subroutine
  end interface
  real(c_double), parameter :: one = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: one_third = transfer(int(z'3fd5555555555555', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: drag_literal = transfer(int(z'3fee5c28f5c28f5c', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: zero = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: initial_top_pressure = transfer(int(z'40e3880000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: half = transfer(int(z'3fe0000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: detrainment_fraction = transfer(int(z'3fe8000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: entrainment_cap = transfer(int(z'3fd999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: humidity_detrainment_factor = transfer(int(z'3ff999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: minimum_temperature = transfer(int(z'4059000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: maximum_temperature = transfer(int(z'4079000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: midlevel_buoyancy_threshold = transfer(int(z'bfe0000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: environment_correction_threshold = transfer(int(z'bfb999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: minimum_kinetic_energy = transfer(int(z'c08f400000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: kinetic_ratio_floor = transfer(int(z'3f50624dd2f1a9fc', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: organized_buoyancy_threshold = transfer(int(z'bfc999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: mixed_phase_enhancement = transfer(int(z'3fd3333333333333', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: top_buoyancy_threshold = transfer(int(z'c000000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: top_lapse_threshold = transfer(int(z'bf689374bc6a7efa', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: condensate_threshold = transfer(int(z'3f33a92a30553261', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: two = transfer(int(z'4000000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: maximum_parcel_speed = transfer(int(z'402e000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: condensate_cap = transfer(int(z'3f747ae147ae147b', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: rain_power = transfer(int(z'3fc999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: rain_speed_coefficient = transfer(int(z'40352e147ae147ae', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: rain_kinetic_floor = transfer(int(z'3fb999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: mean_kinetic_floor = transfer(int(z'3f847ae147ae147b', c_int64_t), 0.0_c_double)
contains
  !> Preserve the selected unsupported-domain process result.
  subroutine admit(condition)
    logical, intent(in) :: condition
    if (.not. condition) call exit_unsupported(116_c_int)
  end subroutine
  !> Resolve a native selected perturbation without copying a live descriptor.
  function selected_perturbation(config, index) result(selected)
    type(tspp_config), intent(in) :: config
    integer(c_int), intent(in) :: index
    integer(c_int) :: selected
    selected = 0_c_int
    if (.not. config%lspp .or. index <= 0) return
    call admit(allocated(config%sm%pn))
    call admit(is_contiguous(config%sm%pn) .and. size(config%sm%pn) <= 128)
    call admit(index >= lbound(config%sm%pn, 1) .and. index <= ubound(config%sm%pn, 1))
    call admit(config%sm%pn(index)%mp >= 1 .and. config%sm%pn(index)%mp <= config%sm%nrftotal)
    selected = index
  end function
  !> Multiply a source coefficient by its selected EXP perturbation.
  function perturbed_coefficient(config, fields, column, index, base) result(answer)
    type(tspp_config), intent(in) :: config
    real(c_double), intent(in) :: fields(:, :), base
    integer(c_int), intent(in) :: column, index
    real(c_double) :: answer, work
    answer = base
    if (index <= 0) return
    work = config%sm%pn(index)%xmag(1)*fields(column, config%sm%pn(index)%mp)
    work = config%sm%pn(index)%mu(1) + work
    work = public_exp(work)
    answer = base*work
  end function
  !> Return the source's propagating bounded quadratic liquid fraction.
  function phase_fraction(thermal, t) result(alpha)
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t
    real(c_double) :: alpha
    alpha = ordered_minimum(thermal%rtwat, t)
    alpha = ordered_maximum(thermal%rticecu, alpha)
    alpha = alpha - thermal%rticecu
    alpha = alpha*thermal%rtwat_rticecu_r
    alpha = alpha*alpha
    alpha = ordered_minimum(one, alpha)
  end function
  !> Preserve native52-position ascent with an explicit active-aerosol count.
  !! Readonly CONSTANTS/THERMAL precede the original arguments. NACTAERO
  !! replaces only original YGFL, at its original position; the generated
  !! calculation tests this int32 value only for positivity.
  !! All matrix views have first extent KLON and at least KLEV levels;
  !! PGEOH/PAPH have at least KLEV+1. PLUDELI has exact(KLON,KLEV)
  !! leading dimensions and two or more phase planes. Vectors have KLON.
  !! All consumed views are contiguous, with disjoint writable owners.
  !! Pressure is Pa, temperature K, humidity kg/kg, geopotential m2/s2,
  !! winds m/s, mass flux kg/(m2 s), kinetic energy m2/s2, time seconds.
  !! Canonical input records remain readonly. Caller supplies the retained
  !! finite/canonical-missing domain, positive denominators, valid cloud
  !! indices and nearest-even/gradual floating environment. No FP probe runs.
  !! Native arrays preserve original column/level order and untouched tails.
  !! The source's shared work flag persists over all ascent levels.
  subroutine cuascn(constants, thermal, ydephli, ydecldp, ydecumf, ydspp_config, nactaero, kidia, kfdia, klon, klev, ptsphy, &
                    ptenh, pqenh, puen, pven, pten, pqen, pqsen, plitot, pgeo, pgeoh, pap, paph, pvervel, pwubase, pgp2dspp, &
                    ldland, ldcum, ktype, klab, lscvflag, ptu, pqu, plu, plrain, pmfu, pmfub, plglac, pmfus, pmfuq, pmful, &
                    plude, pludeli, pdmfup, plcrit_aer, pdmfen, kcbot, kctop, kctop0, kdpl, pmfude_rate, pkineu, pwmean)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tephli), intent(in) :: ydephli
    type(tecldp), intent(in) :: ydecldp
    type(tecumf), intent(in) :: ydecumf
    type(tspp_config), intent(in) :: ydspp_config
    integer(c_int), intent(in) :: nactaero, kidia, kfdia, klon, klev, kdpl(:)
    real(c_double), intent(in) :: ptsphy, puen(:, :), pven(:, :), pten(:, :), pqen(:, :), pqsen(:, :), plitot(:, :)
    real(c_double),intent(in) :: pgeo(:,:),pgeoh(:,:),pap(:,:),paph(:,:),pvervel(:,:),pwubase(:),pgp2dspp(:,:),plcrit_aer(:,:)
    real(c_double), intent(inout) :: ptenh(:, :), pqenh(:, :), ptu(:, :), pqu(:, :), plu(:, :), plrain(:, :), pmfu(:, :), pmfub(:)
    real(c_double), intent(inout) :: plglac(:, :), pmfus(:, :), pmfuq(:, :), pmful(:, :), plude(:, :), pludeli(:, :, :)
    real(c_double), intent(inout) :: pdmfup(:, :), pdmfen(:, :), pmfude_rate(:, :), pkineu(:, :), pwmean(:)
    logical, intent(in) :: ldland(:)
    logical, intent(inout) :: ldcum(:), lscvflag(:)
    integer(c_int), intent(inout) :: ktype(:), klab(:, :), kcbot(:), kctop(:), kctop0(:)
    integer(c_int) :: jl, jk, base, label_sum, flag_count, mode, child_status, ip_org, ip_shallow, ip_rain, ip_detrainment
    logical :: work_active, keep_cloud
    real(c_double), volatile :: mass_limit_factor, inverse_g, inverse_cp, rain_coefficient, cloud_drag, glaciation_switch
    real(c_double) :: w0, w1, w2, w3, w4, w5, w6, coefficient, mass_max, mass_test, new_mass, excess, inverse_mass
    real(c_double) :: entrained_energy, entrained_water, entrained_liquid, detrained_energy, detrained_water
    real(c_double) :: energy_flux, water_flux, liquid_flux, ice_current, ice_previous, glaciation, virtual_parcel
    real(c_double) :: normalized_buoyancy, kinetic_buoyancy, mix_fraction, critical_condensate, enhancement, growth, decay
    real(c_double) :: conversion_rate, new_liquid, fall_speed, old_rain, removal_ratio, new_rain, signed_half
    integer(c_int64_t) :: sign_word
    call admit(.not. ydephli%lphylin)
    call admit(klon >= 1 .and. klon <= 4096 .and. klev >= 4 .and. klev <= 1024)
    call admit(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    if (kidia > kfdia) return
    call admit(ptsphy > zero)
    call admit(ydspp_config%sm%nrftotal >= 0 .and. ydspp_config%sm%nrftotal <= 512)
    call admit(is_contiguous(ldcum) .and. size(ldcum) >= klon .and. is_contiguous(lscvflag) .and. size(lscvflag) >= klon)
    call admit(is_contiguous(ktype) .and. size(ktype) >= klon .and. is_contiguous(kcbot) .and. size(kcbot) >= klon)
    call admit(is_contiguous(kctop) .and. size(kctop) >= klon .and. is_contiguous(kctop0) .and. size(kctop0) >= klon)
    call admit(is_contiguous(kdpl) .and. size(kdpl) >= klon)
    call admit(is_contiguous(klab) .and. size(klab, 1) == klon .and. size(klab, 2) >= klev)
    call real_matrix(ptenh, klon, klev); call real_matrix(pqenh, klon, klev)
    call real_matrix(pten, klon, klev); call real_matrix(pqen, klon, klev); call real_matrix(pqsen, klon, klev)
    call real_matrix(plitot, klon, klev); call real_matrix(pgeo, klon, klev); call real_matrix(pgeoh, klon, klev + 1)
    call real_matrix(pap, klon, klev); call real_matrix(paph, klon, klev + 1); call real_matrix(pvervel, klon, klev)
    call real_vector(pwubase, klon)
    call real_matrix(pgp2dspp, klon, ydspp_config%sm%nrftotal); call real_matrix(plcrit_aer, klon, klev)
    call real_matrix(ptu, klon, klev); call real_matrix(pqu, klon, klev); call real_matrix(plu, klon, klev)
    call real_matrix(plrain, klon, klev); call real_matrix(pmfu, klon, klev); call real_vector(pmfub, klon)
    call real_matrix(plglac, klon, klev); call real_matrix(pmfus, klon, klev); call real_matrix(pmfuq, klon, klev)
    call real_matrix(pmful, klon, klev); call real_matrix(plude, klon, klev)
    call admit(is_contiguous(pludeli) .and. size(pludeli, 1) == klon .and. size(pludeli, 2) == klev .and. size(pludeli, 3) >= 2)
    call real_matrix(pdmfup, klon, klev); call real_matrix(pdmfen, klon, klev)
    call real_matrix(pmfude_rate, klon, klev); call real_matrix(pkineu, klon, klev); call real_vector(pwmean, klon)
    do jl = kidia, kfdia
      call admit(ktype(jl) >= 0 .and. ktype(jl) <= 3 .and. kdpl(jl) >= 1 .and. kdpl(jl) <= klev)
      if (ldcum(jl)) call admit(kcbot(jl) >= 1 .and. kcbot(jl) <= klev)
    end do
    w0 = constants%rg*ptsphy
    mass_limit_factor = ydecumf%rmfcfl/w0
    inverse_g = one/constants%rg
    inverse_cp = one/constants%rcpd
    rain_coefficient = ydecumf%rprcon/constants%rg
    glaciation_switch = zero; if (ydecumf%lmfglac) glaciation_switch = one
    cloud_drag = drag_literal
    ip_org = selected_perturbation(ydspp_config, ydspp_config%pptr%entrorg)
    ip_shallow = selected_perturbation(ydspp_config, ydspp_config%pptr%entshalp)
    ip_rain = selected_perturbation(ydspp_config, ydspp_config%pptr%rprcon)
    ip_detrainment = selected_perturbation(ydspp_config, ydspp_config%pptr%detrpen)
    block
      real(c_double) :: dmf_en(klon), dmf_de(klon), q_old(klon), precipitation(klon), liquid_old(klon)
      real(c_double) :: pressure_weight(klon), organized_entrainment(klon), pressure_row(klon), buoyancy(klon, klev)
      logical :: flag(klon), flag_uv(klon), reset_labels(klon)
      work_active = .false.
      do jl = kidia, kfdia
        liquid_old(jl) = zero
        if (.not. ldcum(jl)) then
          kcbot(jl) = -1; pmfub(jl) = zero; pqu(jl, klev) = zero; ktype(jl) = 0
        end if
        pwmean(jl) = zero; pressure_weight(jl) = zero; organized_entrainment(jl) = zero
        lscvflag(jl) = .false.
        if (ktype(jl) > 1 .and. ydecumf%lscvliq) lscvflag(jl) = .true.
        reset_labels(jl) = .not. ldcum(jl) .or. ktype(jl) == 3
      end do
      do jk = 1, klev
        do jl = kidia, kfdia
          if (jk /= kcbot(jl)) plu(jl, jk) = zero
          pkineu(jl, jk) = zero; pmfu(jl, jk) = zero
          pmfus(jl, jk) = zero; pmfuq(jl, jk) = zero; pmful(jl, jk) = zero
          plude(jl, jk) = zero; plglac(jl, jk) = zero; pdmfup(jl, jk) = zero
          plrain(jl, jk) = zero; pdmfen(jl, jk) = zero; pmfude_rate(jl, jk) = zero
          pludeli(jl, jk, 1) = zero; pludeli(jl, jk, 2) = zero; buoyancy(jl, jk) = zero
          if (reset_labels(jl)) klab(jl, jk) = 0
          if (.not. ldcum(jl)) then
            if (paph(jl, jk) < initial_top_pressure) kctop0(jl) = jk
          end if
        end do
      end do
      do jl = kidia, kfdia
        if (ktype(jl) == 3) ldcum(jl) = .false.
        kctop(jl) = kcbot(jl)
        if (.not. ldcum(jl)) cycle
        base = kcbot(jl)
        w0 = pwubase(jl)*pwubase(jl); pkineu(jl, base) = half*w0
        pmfu(jl, base) = pmfub(jl)
        w1 = constants%rcpd*ptu(jl, base); w1 = w1 + pgeoh(jl, base)
        pmfus(jl, base) = pmfub(jl)*w1
        pmfuq(jl, base) = pmfub(jl)*pqu(jl, base)
        pmful(jl, base) = pmfub(jl)*plu(jl, base)
      end do
      do jk = klev - 1, 3, -1
        call cubasmcn(constants, thermal, ydecumf, kidia, kfdia, klon, klev, jk, pten, pqen, pqsen, pvervel, pgeo, pgeoh, &
                      ldcum, ktype, klab, kcbot, pmfu, pmfub, plrain, ptu, pqu, plu, pmfus, pmfuq, pmful, pdmfup)
        label_sum = 0; flag_count = 0
        do jl = kidia, kfdia
          flag(jl) = .false.; flag_uv(jl) = .false.; precipitation(jl) = zero
          label_sum = label_sum + klab(jl, jk + 1)
          if (klab(jl, jk + 1) == 0) klab(jl, jk) = 0
          flag(jl) = (ldcum(jl) .and. klab(jl, jk + 1) == 2) .or. (ktype(jl) == 3 .and. klab(jl, jk + 1) == 1)
          if (flag(jl)) flag_count = flag_count + 1
          pressure_row(jl) = paph(jl, jk)
          if (ktype(jl) == 3 .and. kcbot(jl) == jk) then
            w0 = paph(jl, jk) - paph(jl, jk - 1)
            w0 = w0*mass_limit_factor
            if (pmfub(jl) > w0) then
              w2 = w0/pmfub(jl)
              pmfub(jl) = w0
              pmfu(jl, jk + 1) = pmfu(jl, jk + 1)*w2
              pmfus(jl, jk + 1) = pmfus(jl, jk + 1)*w2
              pmfuq(jl, jk + 1) = pmfuq(jl, jk + 1)*w2
            end if
          end if
        end do
        work_active = work_active .or. label_sum > 0
        call cuentr(constants, thermal, ydecumf, ydspp_config, kidia, kfdia, klon, klev, jk, kcbot, ktype, ldcum, work_active, &
                    pqsen, paph, pgeoh, pmfu, pgp2dspp, dmf_en, dmf_de)
        if (.not. work_active) cycle
        do jl = kidia, kfdia
          q_old(jl) = zero
          if (.not. flag(jl)) cycle
          w1 = detrainment_fraction*pmfu(jl, jk + 1)
          dmf_de(jl) = ordered_minimum(dmf_de(jl), w1)
          if (kcbot(jl) == jk) then
            coefficient = perturbed_coefficient(ydspp_config, pgp2dspp, jl, ip_org, ydecumf%entrorg)
            w0 = -coefficient
            w1 = pqen(jl, jk)/pqsen(jl, jk); w1 = ordered_minimum(one, w1); w1 = w1 - one
            w0 = w0*w1
            w1 = pgeoh(jl, jk) - pgeoh(jl, jk + 1)
            w0 = w0*w1; w0 = w0*inverse_g
            w0 = ordered_minimum(entrainment_cap, w0)
            organized_entrainment(jl) = w0*pmfu(jl, jk + 1)
          end if
          if (jk < kcbot(jl)) then
            mass_max = paph(jl, jk) - paph(jl, jk - 1)
            mass_max = mass_max*mass_limit_factor
            mass_test = pmfu(jl, jk + 1) - mass_max
            mass_test = ordered_maximum(mass_test, zero)
            w1 = pap(jl, jk + 1) - pap(jl, jk)
            w0 = pkineu(jl, jk + 1)*w1
            pwmean(jl) = pwmean(jl) + w0
            w0 = pressure_weight(jl) + pap(jl, jk + 1)
            pressure_weight(jl) = w0 - pap(jl, jk)
            dmf_en(jl) = organized_entrainment(jl)
            if (ktype(jl) >= 2) then
              coefficient = perturbed_coefficient(ydspp_config, pgp2dspp, jl, ip_shallow, ydecumf%entshalp)
              dmf_en(jl) = coefficient*dmf_en(jl); dmf_de(jl) = dmf_en(jl)
            end if
            w0 = pqen(jl, jk)/pqsen(jl, jk); w0 = ordered_minimum(one, w0)
            w0 = humidity_detrainment_factor - w0
            dmf_de(jl) = dmf_de(jl)*w0
            w0 = pmfu(jl, jk + 1) + dmf_en(jl); w0 = w0 - dmf_de(jl); w0 = w0 - mass_max
            new_mass = ordered_maximum(w0, zero)
            w2 = new_mass - mass_test; excess = ordered_maximum(w2, zero)
            dmf_en(jl) = dmf_en(jl) - excess
            new_mass = new_mass - excess
            dmf_de(jl) = dmf_de(jl) + new_mass
          end if
          pdmfen(jl, jk) = dmf_en(jl) - dmf_de(jl)
          w2 = pmfu(jl, jk + 1) + dmf_en(jl)
          pmfu(jl, jk) = w2 - dmf_de(jl)
          entrained_water = pqenh(jl, jk + 1)*dmf_en(jl)
          w2 = constants%rcpd*ptenh(jl, jk + 1); w2 = w2 + pgeoh(jl, jk + 1)
          entrained_energy = w2*dmf_en(jl)
          entrained_liquid = zero
          if (plitot(jl, jk) > ydecldp%rlmin) entrained_liquid = plitot(jl, jk)*dmf_en(jl)
          w2 = constants%rcpd*ptu(jl, jk + 1); w2 = w2 + pgeoh(jl, jk + 1)
          detrained_energy = w2*dmf_de(jl)
          detrained_water = pqu(jl, jk + 1)*dmf_de(jl)
          plude(jl, jk) = plu(jl, jk + 1)*dmf_de(jl)
          energy_flux = pmfus(jl, jk + 1) + entrained_energy; energy_flux = energy_flux - detrained_energy
          water_flux = pmfuq(jl, jk + 1) + entrained_water; water_flux = water_flux - detrained_water
          liquid_flux = pmful(jl, jk + 1) + entrained_liquid; liquid_flux = liquid_flux - plude(jl, jk)
          w0 = ordered_maximum(ydecumf%rmfcmin, pmfu(jl, jk))
          inverse_mass = one/w0
          plu(jl, jk) = liquid_flux*inverse_mass
          pqu(jl, jk) = water_flux*inverse_mass; q_old(jl) = pqu(jl, jk)
          w1 = energy_flux*inverse_mass; w1 = w1 - pgeoh(jl, jk); w1 = w1*inverse_cp
          w1 = ordered_maximum(minimum_temperature, w1)
          ptu(jl, jk) = ordered_minimum(maximum_temperature, w1)
          w2 = pmfu(jl, jk + 1) - dmf_de(jl)
          w2 = ordered_maximum(zero, w2)
          w1 = plrain(jl, jk + 1)*w2
          plrain(jl, jk) = w1*inverse_mass
          liquid_old(jl) = plu(jl, jk)
        end do
        do jl = kidia, kfdia
          if (jk <= kdpl(jl)) cycle
          ptu(jl, jk) = ptenh(jl, jk); pqu(jl, jk) = pqenh(jl, jk)
          plu(jl, jk) = zero; liquid_old(jl) = zero
        end do
        if (flag_count /= 0) then
          mode = 1_c_int; if (ydecumf%lscvliq) mode = 6_c_int
     child_status = cuadjtq(constants, thermal, ydephli, kidia, kfdia, klon, klev, jk, pressure_row, ptu, pqu, flag, mode, lscvflag)
          call admit(child_status == 0)
        end if

        ! Glaciation follows saturation adjustment and keeps the signed-zero switch.
        do jl = kidia, kfdia
          if (.not. flag(jl)) cycle
          if (pqu(jl, jk) == q_old(jl)) cycle
          ice_current = one - phase_fraction(thermal, ptu(jl, jk))
          ice_previous = one - phase_fraction(thermal, ptu(jl, jk + 1))
          w0 = ice_current - ice_previous
          glaciation = plu(jl, jk)*w0
          if (lscvflag(jl)) glaciation = zero
          w0 = phase_fraction(thermal, pten(jl, jk))
          w0 = w0*pdmfup(jl, jk + 1)
          w1 = ordered_maximum(ydecumf%rmfcmin, pmfu(jl, jk + 1))
          w0 = w0/w1
          w1 = constants%rtt - pten(jl, jk)
          sign_word = iand(transfer(w1, 0_c_int64_t), int(z'8000000000000000', c_int64_t))
          sign_word = ior(transfer(half, 0_c_int64_t), sign_word)
          signed_half = transfer(sign_word, zero)
          w1 = half + signed_half
          w0 = w0*w1; w0 = w0*glaciation_switch
          glaciation = glaciation + w0
          plglac(jl, jk) = glaciation
          w0 = thermal%ralfdcp*glaciation
          ptu(jl, jk) = ptu(jl, jk) + w0
        end do
        ! Trial condensate remains visible even when this level stops the cloud.
        do jl = kidia, kfdia
          if (.not. flag(jl)) cycle
          if (pqu(jl, jk) == q_old(jl)) then
            if (ktype(jl) == 2) then
              klab(jl, jk) = 0; pmfu(jl, jk) = zero; pkineu(jl, jk) = zero
              dmf_de(jl) = pmfu(jl, jk + 1)
              pmfude_rate(jl, jk) = dmf_de(jl)
              plude(jl, jk) = plu(jl, jk + 1)*dmf_de(jl)
            end if
            cycle
          end if
          klab(jl, jk) = 2
          w0 = plu(jl, jk) + q_old(jl)
          plu(jl, jk) = w0 - pqu(jl, jk)
          w0 = constants%retv*pqu(jl, jk); w0 = one + w0
          w0 = w0 - plu(jl, jk + 1); w0 = w0 - plrain(jl, jk + 1)
          virtual_parcel = ptu(jl, jk)*w0
          w1 = constants%retv*pqenh(jl, jk); w1 = one + w1
          w1 = ptenh(jl, jk)*w1
          buoyancy(jl, jk) = virtual_parcel - w1
          if (ktype(jl) == 3 .and. klab(jl, jk + 1) == 1) then
            if (buoyancy(jl, jk) > midlevel_buoyancy_threshold) then
              ldcum(jl) = .true.; kctop(jl) = jk; pkineu(jl, jk) = half
            else
              klab(jl, jk) = 0; pmfu(jl, jk) = zero; plude(jl, jk) = zero; plu(jl, jk) = zero
            end if
          end if
          if (klab(jl, jk + 1) /= 2) cycle
          if (.not. (buoyancy(jl, jk) >= environment_correction_threshold)) then
            w0 = pten(jl, jk) + pten(jl, jk - 1); ptenh(jl, jk) = half*w0
            w0 = pqen(jl, jk) + pqen(jl, jk - 1); pqenh(jl, jk) = half*w0
            w0 = constants%retv*pqenh(jl, jk); w0 = one + w0; w0 = ptenh(jl, jk)*w0
            buoyancy(jl, jk) = virtual_parcel - w0
          end if
          w0 = buoyancy(jl, jk) + buoyancy(jl, jk + 1); w0 = half*w0
          w1 = constants%retv*pqenh(jl, jk); w1 = one + w1; w1 = ptenh(jl, jk)*w1
          normalized_buoyancy = w0/w1
          w1 = pgeoh(jl, jk) - pgeoh(jl, jk + 1); w1 = w1*one_third
          kinetic_buoyancy = w1*normalized_buoyancy
          w0 = dmf_en(jl)
          if (.not. (w0 > zero)) w0 = dmf_de(jl)
          w1 = one + cloud_drag; w0 = w1*w0
          w1 = ordered_maximum(ydecumf%rmfcmin, pmfu(jl, jk + 1))
          w0 = w0/w1; mix_fraction = ordered_minimum(one, w0)
          w1 = one - mix_fraction; w1 = pkineu(jl, jk + 1)*w1
          w1 = w1 + kinetic_buoyancy; w0 = one + mix_fraction
          w0 = w1/w0
          pkineu(jl, jk) = ordered_maximum(minimum_kinetic_energy, w0)
          if (.not. (normalized_buoyancy >= zero)) then
            w1 = ordered_maximum(kinetic_ratio_floor, pkineu(jl, jk + 1))
            w0 = pkineu(jl, jk)/w1
            w0 = ordered_minimum(one, w0); w0 = ordered_maximum(zero, w0); w0 = sqrt(w0)
            w1 = pqen(jl, jk)/pqsen(jl, jk); w1 = ordered_minimum(one, w1)
            w1 = humidity_detrainment_factor - w1; w1 = w1*w0
            w1 = one - w1; w0 = pmfu(jl, jk + 1)*w1
            dmf_de(jl) = ordered_maximum(dmf_de(jl), w0)
            plude(jl, jk) = plu(jl, jk + 1)*dmf_de(jl)
            w1 = pmfu(jl, jk + 1) + dmf_en(jl)
            pmfu(jl, jk) = w1 - dmf_de(jl)
          end if
          if (buoyancy(jl, jk) > organized_buoyancy_threshold) then
            coefficient = perturbed_coefficient(ydspp_config, pgp2dspp, jl, ip_org, ydecumf%entrorg)
            w0 = pqen(jl, jk - 1)/pqsen(jl, jk - 1); w0 = ordered_minimum(one, w0)
            w0 = w0 - one; w0 = mixed_phase_enhancement - w0
            coefficient = coefficient*w0
            w1 = pgeoh(jl, jk - 1) - pgeoh(jl, jk)
            coefficient = coefficient*w1; coefficient = coefficient*inverse_g
            base = kcbot(jl)
            w0 = pqsen(jl, jk)/pqsen(jl, base); w0 = ordered_minimum(one, w0)
            w1 = w0*w0; w0 = w1*w0
            w0 = coefficient*w0; w0 = ordered_minimum(entrainment_cap, w0)
            organized_entrainment(jl) = w0*pmfu(jl, jk)
          else
            organized_entrainment(jl) = zero
          end if
          if (jk > kdpl(jl)) then
            pmfu(jl, jk) = pmfu(jl, jk + 1); pkineu(jl, jk) = half
          end if
          keep_cloud = .false.
          if (pkineu(jl, jk) > zero .and. pmfu(jl, jk) > zero) then
            if (buoyancy(jl, jk) > top_buoyancy_threshold) then
              keep_cloud = .true.
            else
              w0 = pten(jl, jk - 1) - pten(jl, jk)
              w1 = pgeo(jl, jk - 1) - pgeo(jl, jk); w1 = inverse_g*w1
              w0 = w0/w1
              keep_cloud = .not. (w0 >= top_lapse_threshold)
            end if
          end if
          if (keep_cloud) then
            kctop(jl) = jk; flag_uv(jl) = .true.
          else
            klab(jl, jk) = 0; pmfu(jl, jk) = zero; pkineu(jl, jk) = zero
            dmf_de(jl) = pmfu(jl, jk + 1)
            plude(jl, jk) = plu(jl, jk + 1)*dmf_de(jl)
          end if
          if (pmfu(jl, jk + 1) > zero) pmfude_rate(jl, jk) = dmf_de(jl)
        end do
        do jl = kidia, kfdia
          if (.not. flag_uv(jl)) cycle
          if (.not. (plu(jl, jk) > condensate_threshold)) cycle
          w0 = ordered_maximum(half, pkineu(jl, jk + 1)); w0 = two*w0; w0 = sqrt(w0)
          w0 = ordered_minimum(maximum_parcel_speed, w0); w0 = detrainment_fraction*w0
          w1 = phase_fraction(thermal, ptu(jl, jk))
          w1 = mixed_phase_enhancement*w1; w1 = one + w1
          coefficient = perturbed_coefficient(ydspp_config, pgp2dspp, jl, ip_rain, rain_coefficient)
          coefficient = coefficient/w0; coefficient = coefficient*w1
          w0 = thermal%rtbercu - ptu(jl, jk); w0 = ordered_maximum(zero, w0)
          w1 = thermal%rtbercu - thermal%rticecu
          w0 = ordered_minimum(w1, w0); w0 = sqrt(w0); w0 = half*w0
          enhancement = one + w0
          coefficient = coefficient*enhancement
          if (nactaero > 0 .and. (ydecldp%laerliqautocp .or. ydecldp%laerliqautocpb)) then
            base = kcbot(jl)
            w0 = plcrit_aer(jl, base)
            if (ydecldp%laerliqautocp) w0 = plcrit_aer(jl, jk)
            w1 = phase_fraction(thermal, ptu(jl, jk))
            w2 = one - w1; w2 = w2*condensate_threshold
            w0 = w1*w0; critical_condensate = w0 + w2
          else
            critical_condensate = condensate_threshold/enhancement
          end if
          growth = plu(jl, jk) - liquid_old(jl)
          w0 = plu(jl, jk)/critical_condensate; w0 = w0*w0; w0 = -w0
          decay = public_exp(w0)
          w0 = one - decay; coefficient = coefficient*w0
          w0 = pgeoh(jl, jk) - pgeoh(jl, jk + 1); coefficient = coefficient*w0
          decay = public_exp(-coefficient)
          w0 = liquid_old(jl)*decay; w1 = growth/coefficient; w2 = one - decay
          w1 = w1*w2; new_liquid = w0 + w1
          new_liquid = ordered_minimum(plu(jl, jk), new_liquid)
          new_liquid = ordered_maximum(zero, new_liquid)
          new_liquid = ordered_minimum(condensate_cap, new_liquid)
          w0 = liquid_old(jl) + growth; w0 = w0 - new_liquid
          precipitation(jl) = ordered_maximum(zero, w0)
          pdmfup(jl, jk) = precipitation(jl)*pmfu(jl, jk)
          plrain(jl, jk) = plrain(jl, jk) + precipitation(jl)
          plu(jl, jk) = new_liquid
        end do
        do jl = kidia, kfdia
          if (.not. flag_uv(jl)) cycle
          if (.not. (plrain(jl, jk) > zero)) cycle
          w0 = energy_pow(plrain(jl, jk), rain_power)
          fall_speed = rain_speed_coefficient*w0
          w1 = phase_fraction(thermal, ptu(jl, jk)); if (lscvflag(jl)) w1 = one
          w0 = w1*fall_speed; w2 = half*fall_speed
          w1 = one - w1; w1 = w1*w2; fall_speed = w0 + w1
          old_rain = plrain(jl, jk) - precipitation(jl)
          w0 = ordered_maximum(rain_kinetic_floor, pkineu(jl, jk))
          w0 = two*w0; w0 = sqrt(w0); w0 = ordered_minimum(maximum_parcel_speed, w0)
          removal_ratio = fall_speed/w0
          decay = public_exp(-removal_ratio)
          w0 = old_rain*decay; w1 = precipitation(jl)/removal_ratio; w2 = one - decay
          w1 = w1*w2; new_rain = w0 + w1
          new_rain = ordered_minimum(plrain(jl, jk), new_rain)
          plrain(jl, jk) = ordered_maximum(zero, new_rain)
        end do
        do jl = kidia, kfdia
          if (.not. flag(jl)) cycle
          pmful(jl, jk) = plu(jl, jk)*pmfu(jl, jk)
          w0 = constants%rcpd*ptu(jl, jk); w0 = w0 + pgeoh(jl, jk)
          pmfus(jl, jk) = w0*pmfu(jl, jk)
          pmfuq(jl, jk) = pqu(jl, jk)*pmfu(jl, jk)
          w0 = phase_fraction(thermal, ptu(jl, jk)); if (lscvflag(jl)) w0 = one
          pludeli(jl, jk, 1) = w0*plude(jl, jk)
          w0 = one - w0; pludeli(jl, jk, 2) = w0*plude(jl, jk)
        end do
      end do
      do jl = kidia, kfdia
        if (kctop(jl) == -1) ldcum(jl) = .false.
        kcbot(jl) = max(kcbot(jl), kctop(jl))
        if (.not. ldcum(jl)) cycle
        w0 = ordered_maximum(one, pressure_weight(jl))
        w0 = pwmean(jl)/w0
        w0 = ordered_maximum(mean_kinetic_floor, w0); w0 = two*w0
        pwmean(jl) = sqrt(w0)
      end do
    end block
  end subroutine cuascn
end module moist_cloud_ascent_mod
