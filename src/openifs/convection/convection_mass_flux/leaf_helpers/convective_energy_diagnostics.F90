!> Complete CUANCAPE2 departure search and three parcel-energy diagnostics.
module convective_energy_diagnostics_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoecumf, only: tecumf
  use yoephli, only: tephli
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use saturation_humidity_mod, only: ordered_minimum, ordered_maximum, public_exp
  use convective_saturation_adjustment_mod, only: cuadjtq
  implicit none
  private
  public :: cuancape2, cuancape2_raw, energy_log, energy_pow
  interface cuancape2_raw
    module procedure cuancape2
  end interface
  interface
    function energy_log(x) bind(c, name="log") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function energy_pow(x, p) bind(c, name="pow") result(y)
      import c_double
      real(c_double), value :: x, p
      real(c_double) :: y
    end function
  end interface
contains
  !> Retain the sign bit of the rounded temperature difference at freezing.
  !! The abrupt ice/water switch includes negative zero exactly as selected.
  function latent_heat_over_cp(constants, thermal, t) result(heat)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t
    real(c_double) :: heat, delta, w0, w1
    real(c_double), volatile :: liquid
    delta = t - constants%rtt
    liquid = 1.0_c_double
    if (btest(transfer(delta, 0_c_int64_t), 63)) liquid = 0.0_c_double
    w0 = liquid*thermal%ralvdcp
    w1 = 1.0_c_double - liquid
    w1 = w1*thermal%ralsdcp
    heat = w0 + w1
  end function
  !> Return equivalent potential temperature from the ordered parcel formula.
  function equivalent_potential(constants, thermal, t, q, theta) result(answer)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t, q, theta
    real(c_double) :: answer, work
    work = latent_heat_over_cp(constants, thermal, t)
    work = work*q
    work = work/t
    work = public_exp(work)
    answer = theta*work
  end function
  !> Return mixed-phase saturation pressure in the selected arithmetic order.
  function mixed_saturation_pressure(constants, thermal, t) result(answer)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t
    real(c_double) :: answer, alpha, water, solid, w0, w1, w2
    alpha = ordered_minimum(thermal%rtwat, t)
    alpha = ordered_maximum(thermal%rtice, alpha)
    alpha = alpha - thermal%rtice
    alpha = alpha*thermal%rtwat_rtice_r
    alpha = alpha*alpha
    alpha = ordered_minimum(1.0_c_double, alpha)
    w0 = t - constants%rtt; w0 = thermal%r3les*w0
    w1 = t - thermal%r4les; w0 = w0/w1
    water = public_exp(w0)
    w0 = t - constants%rtt; w0 = thermal%r3ies*w0
    w1 = t - thermal%r4ies; w0 = w0/w1
    solid = public_exp(w0)
    w2 = 1.0_c_double - alpha; w0 = w2*solid
    w1 = alpha*water; w0 = w1 + w0
    answer = thermal%r2es*w0
  end function
  !> Return lifting condensation pressure in Pa with the frozen power call.
  function condensation_pressure(constants, thermal, t, q, p, theta, inverse_kappa, inverse_vapor_scale) result(answer)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t, q, p, theta, inverse_kappa, inverse_vapor_scale
    real(c_double) :: answer, dew, w0, w1, w2, w3, w4
    w0 = ordered_maximum(0.0001_c_double, q)
    w0 = w0*p
    w0 = w0*inverse_vapor_scale
    w0 = energy_log(w0)
    w1 = thermal%r4les*w0
    w3 = thermal%r3les*constants%rtt
    w1 = w1 - w3
    w0 = w0 - thermal%r3les
    dew = w1/w0
    w2 = dew - constants%rtt
    w2 = 0.001571_c_double*w2
    w2 = 0.212_c_double + w2
    w1 = t - constants%rtt
    w1 = 0.000436_c_double*w1
    w2 = w2 - w1
    w3 = t - dew
    w2 = w2*w3
    w0 = dew - w2
    w0 = ordered_minimum(w0, t)
    w0 = ordered_maximum(160.0_c_double, w0)
    w0 = w0/theta
    w0 = energy_pow(w0, inverse_kappa)
    answer = constants%ratm*w0
  end function
  !> Add one pressure-thickness layer to a selected mixed parcel.
  subroutine accumulate_mixed_layer(t, q, exner, thickness, mass, theta_mass, water_mass)
    real(c_double), intent(in) :: t, q, exner, thickness
    real(c_double), intent(inout) :: mass, theta_mass, water_mass
    real(c_double) :: work
    mass = mass + thickness
    work = t*thickness
    work = work*exner
    theta_mass = theta_mass + work
    work = q*thickness
    water_mass = water_mass + work
  end subroutine
  !> Compute departure pressure and potential energy for three full ascents.
  !! Providers precede all13 original arguments in their original order.
  !! PAP/PT/PQ have first extent KLON and at least KLEV levels; PAPH has
  !! at least KLEV+1. PCAPE has at least four planes, with this dummy's
  !! second bound0:3; PCIN has at least three planes with bound1:3.
  !! PPDEPL has at least KLON elements. All views are contiguous; writable
  !! owners are separate from one another and from readonly native inputs.
  !! Pressure uses Pa, temperature K, humidity kg/kg and energies J/kg.
  !! Raw callers admit1<=KIDIA<=KFDIA<=KLON<=4096 and4<=KLEV<=512,
  !! normal physics and1<=NJKT2<NJKT1<KLEV, NJKT1>=3,
  !! NJKT2<=NJKT4<KLEV. Used positive pressures increase down the column;
  !! parcel/saturation work uses pressures above8000Pa and finite source
  !! arithmetic. Caller establishes nearest-even and gradual underflow.
  !! Outputs mutate selected columns only; all inactive bytes remain.
  !! Native named allocatables replace the former scratch arena; the
  !! compiler owns their descriptors and allocation. Public EXP/LOG/POW
  !! and the owned CUADJTQ are the only numerical callees. Profiling hooks
  !! are outside this numerical entry. No original model global is read.
  subroutine cuancape2(constants, thermal, ydecumf, ydephli, kidia, kfdia, klon, klev, pap, paph, pt, pq, pcape, pcin, ppdepl)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tecumf), intent(in) :: ydecumf
    type(tephli), intent(in) :: ydephli
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev
    real(c_double), intent(in) :: pap(:, :), paph(:, :), pt(:, :), pq(:, :)
    real(c_double), intent(inout) :: pcape(:, 0:), pcin(:, :), ppdepl(:)
    real(c_double), allocatable :: cape(:, :), cin(:, :), theta_mix(:, :), q_mix(:, :), p_mix(:, :), p_lcl(:, :)
    real(c_double),allocatable :: exner(:,:),inverse_theta_e(:,:),inverse_theta_v(:,:),hydrostatic_weight(:,:),parcel_t(:,:),parcel_q(:,:)
    real(c_double), allocatable :: mixed_t(:), mixed_theta_v(:), mixed_theta_e(:), inhibition(:), accumulated_pressure(:)
    logical, allocatable :: pressure_used(:, :), saturated(:), departed(:)
    integer(c_int), allocatable :: departure(:, :)
    integer(c_int) :: jl, jk, dep, layer, slot, parcel, allocation_status, child_status
    real(c_double) :: inverse_kappa, inverse_vapor_scale, w0, w1, w2, w3, dp, inverse_mass, theta, qsat, buoyancy
    real(c_double), volatile :: unused_virtual_comparison
    call require(.not. ydephli%lphylin)
    call require(klon >= 1 .and. klon <= 4096 .and. klev >= 4 .and. klev <= 512)
    call require(kidia >= 1 .and. kfdia >= kidia .and. kfdia <= klon)
    call require(ydecumf%njkt1 >= 3 .and. ydecumf%njkt1 < klev)
    call require(ydecumf%njkt2 >= 1 .and. ydecumf%njkt2 < ydecumf%njkt1)
    call require(ydecumf%njkt4 >= ydecumf%njkt2 .and. ydecumf%njkt4 < klev)
    call real_matrix(pap, klon, klev); call real_matrix(paph, klon, klev + 1)
    call real_matrix(pt, klon, klev); call real_matrix(pq, klon, klev)
    call real_matrix(pcape, klon, 4_c_int); call real_matrix(pcin, klon, 3_c_int); call real_vector(ppdepl, klon)
    allocate (cape(klon, klev), cin(klon, klev), theta_mix(klon, klev), q_mix(klon, klev), p_mix(klon, klev), p_lcl(klon, klev), &
              exner(klon, klev), inverse_theta_e(klon, klev), inverse_theta_v(klon, klev), hydrostatic_weight(klon, klev), &
              parcel_t(klon, klev), parcel_q(klon, klev), pressure_used(klon, klev), mixed_t(klon), mixed_theta_v(klon), &
              mixed_theta_e(klon), inhibition(klon), accumulated_pressure(klon), saturated(klon), departed(klon), &
              departure(klon, 0:2), stat=allocation_status)
    call require(allocation_status == 0)
    inverse_kappa = 1.0_c_double/constants%rkappa
    w1 = constants%restt*constants%rd
    w1 = w1/constants%rv
    inverse_vapor_scale = 1.0_c_double/w1
    do jl = kidia, kfdia
      pcape(jl, 0) = 0.0_c_double; pcin(jl, 1) = ydecumf%rmincin
      pcape(jl, 1) = 0.0_c_double; pcin(jl, 2) = ydecumf%rmincin
      pcape(jl, 2) = 0.0_c_double; pcin(jl, 3) = ydecumf%rmincin
      pcape(jl, 3) = 0.0_c_double; ppdepl(jl) = 0.0_c_double
      w0 = constants%ratm/pap(jl, klev)
      exner(jl, klev) = energy_pow(w0, constants%rkappa)
    end do
    do jk = klev - 1, ydecumf%njkt2, -1
      do jl = kidia, kfdia
        pressure_used(jl, jk) = pap(jl, jk) > 8000.0_c_double
        if (.not. pressure_used(jl, jk)) cycle
        w1 = 1.0_c_double/pap(jl, jk)
        w0 = mixed_saturation_pressure(constants, thermal, pt(jl, jk))
        w0 = w0*w1
        w0 = ordered_maximum(0.00000001_c_double, w0)
        w2 = constants%retv*w0; w2 = 1.0_c_double - w2
        qsat = w0/w2
        parcel_q(jl, jk) = qsat
        w0 = constants%ratm*w1
        exner(jl, jk) = energy_pow(w0, constants%rkappa)
        theta = pt(jl, jk)*exner(jl, jk)
        w0 = equivalent_potential(constants, thermal, pt(jl, jk), qsat, theta)
        inverse_theta_e(jl, jk) = 1.0_c_double/w0
        w0 = constants%retv*pq(jl, jk)
        w0 = 1.0_c_double + w0
        w0 = theta*w0
        inverse_theta_v(jl, jk) = 1.0_c_double/w0
      end do
    end do
    do jk = ydecumf%njkt2, klev - 1
      do jl = kidia, kfdia
        w0 = 1.0_c_double/pap(jl, jk)
        w1 = paph(jl, jk + 1) - paph(jl, jk)
        w0 = w1*w0
        w0 = w0*constants%rd
        w0 = w0*pt(jl, jk)
        w1 = constants%retv*pq(jl, jk)
        w1 = 1.0_c_double + w1
        hydrostatic_weight(jl, jk) = w0*w1
      end do
    end do
    do dep = klev - 1, ydecumf%njkt1, -1
      do jl = kidia, kfdia
        cape(jl, dep) = 0.0_c_double; cin(jl, dep) = 0.0_c_double
        w0 = paph(jl, klev + 1) - paph(jl, dep - 1)
        if (w0 < 6000.0_c_double) then
          mixed_t(jl) = 0.0_c_double
          theta_mix(jl, dep) = 0.0_c_double; q_mix(jl, dep) = 0.0_c_double; p_mix(jl, dep) = 0.0_c_double
          do layer = dep + 1, dep - 1, -1
            if (p_mix(jl, dep) > 3000.0_c_double) cycle
            dp = paph(jl, layer + 1) - paph(jl, layer)
            call accumulate_mixed_layer(pt(jl, layer), pq(jl, layer), exner(jl, layer), dp, &
                                        p_mix(jl, dep), theta_mix(jl, dep), q_mix(jl, dep))
          end do
          dp = p_mix(jl, dep)
          inverse_mass = 1.0_c_double/dp
          q_mix(jl, dep) = q_mix(jl, dep)*inverse_mass
          w1 = 0.5_c_double*dp
          p_mix(jl, dep) = paph(jl, dep + 2) - w1
          theta_mix(jl, dep) = theta_mix(jl, dep)*inverse_mass
          w0 = p_mix(jl, dep)/constants%ratm
          w0 = energy_pow(w0, constants%rkappa)
          mixed_t(jl) = theta_mix(jl, dep)*w0
        else
          q_mix(jl, dep) = pq(jl, dep); p_mix(jl, dep) = pap(jl, dep); mixed_t(jl) = pt(jl, dep)
          w0 = constants%ratm/p_mix(jl, dep)
          w0 = energy_pow(w0, constants%rkappa)
          theta_mix(jl, dep) = pt(jl, dep)*w0
        end if
        mixed_theta_e(jl) = equivalent_potential(constants, thermal, mixed_t(jl), q_mix(jl, dep), theta_mix(jl, dep))
        w0 = constants%retv*q_mix(jl, dep); w0 = 1.0_c_double + w0
        mixed_theta_v(jl) = theta_mix(jl, dep)*w0
        w0 = paph(jl, klev + 1) - paph(jl, dep)
        saturated(jl) = w0 < 35000.0_c_double
        p_lcl(jl, dep) = condensation_pressure(constants, thermal, mixed_t(jl), q_mix(jl, dep), p_mix(jl, dep), &
                                               theta_mix(jl, dep), inverse_kappa, inverse_vapor_scale)
      end do
      do jk = dep, ydecumf%njkt2, -1
        do jl = kidia, kfdia
          if (.not. pressure_used(jl, jk)) cycle
          if (.not. saturated(jl)) cycle
          w0 = mixed_theta_e(jl)*inverse_theta_e(jl, jk)
          buoyancy = w0 - 1.0_c_double
          w2 = mixed_theta_v(jl)*inverse_theta_v(jl, jk)
          unused_virtual_comparison = w2 - 1.0_c_double
          if (.not. (pap(jl, jk) <= p_lcl(jl, dep))) cycle
          if (buoyancy <= 0.0_c_double) cycle
          w0 = buoyancy*hydrostatic_weight(jl, jk)
          cape(jl, dep) = cape(jl, dep) + w0
        end do
      end do
    end do
    ! The first lowest departure wins exact maximum ties.
    departure(:, 0) = klev - 1
    do dep = klev - 1, ydecumf%njkt1, -1
      do jl = kidia, kfdia
        if (cape(jl, dep) <= pcape(jl, 0)) cycle
        pcape(jl, 0) = cape(jl, dep)
        departure(jl, 0) = dep
      end do
    end do
    do jl = kidia, kfdia
      ppdepl(jl) = pap(jl, departure(jl, 0))
    end do
    do jl = kidia, kfdia
      dp = paph(jl, klev + 1) - paph(jl, klev)
      p_mix(jl, 1) = dp; accumulated_pressure(jl) = dp
      w0 = pt(jl, klev)*dp; theta_mix(jl, 1) = w0*exner(jl, klev)
      q_mix(jl, 1) = pq(jl, klev)*dp
    end do
    do jl = kidia, kfdia
      p_mix(jl, 2) = p_mix(jl, 1); theta_mix(jl, 2) = theta_mix(jl, 1); q_mix(jl, 2) = q_mix(jl, 1)
    end do
    do jk = klev - 1, ydecumf%njkt4, -1
      do jl = kidia, kfdia
        dp = paph(jl, jk + 1) - paph(jl, jk)
        accumulated_pressure(jl) = accumulated_pressure(jl) + dp
        if (accumulated_pressure(jl) <= 5000.0_c_double) then
          call accumulate_mixed_layer(pt(jl, jk), pq(jl, jk), exner(jl, jk), dp, p_mix(jl, 1), theta_mix(jl, 1), q_mix(jl, 1))
        end if
        if (accumulated_pressure(jl) <= 10000.0_c_double) then
          call accumulate_mixed_layer(pt(jl, jk), pq(jl, jk), exner(jl, jk), dp, p_mix(jl, 2), theta_mix(jl, 2), q_mix(jl, 2))
        end if
      end do
    end do
    do slot = 1, 2
      do jl = kidia, kfdia
        inverse_mass = 1.0_c_double/p_mix(jl, slot)
        theta_mix(jl, slot) = theta_mix(jl, slot)*inverse_mass
        q_mix(jl, slot) = q_mix(jl, slot)*inverse_mass
      end do
    end do
    do slot = 1, 2
      do jl = kidia, kfdia
        w1 = 0.5_c_double*p_mix(jl, slot)
        p_mix(jl, slot) = paph(jl, klev + 1) - w1
        w0 = p_mix(jl, slot)/constants%ratm
        w0 = energy_pow(w0, constants%rkappa)
        mixed_t(jl) = theta_mix(jl, slot)*w0
        p_lcl(jl, slot) = condensation_pressure(constants, thermal, mixed_t(jl), q_mix(jl, slot), p_mix(jl, slot), &
                                                theta_mix(jl, slot), inverse_kappa, inverse_vapor_scale)
        departure(jl, slot) = slot
      end do
    end do
    do parcel = 0, 2
      do jl = kidia, kfdia
        inhibition(jl) = 0.0_c_double
        dep = departure(jl, parcel)
        parcel_t(jl, klev - 1) = theta_mix(jl, dep)/exner(jl, klev - 1)
        parcel_q(jl, klev - 1) = q_mix(jl, dep)
        cape(jl, dep) = 0.0_c_double
      end do
      do jk = klev - 2, ydecumf%njkt2, -1
        do jl = kidia, kfdia
          dep = departure(jl, parcel)
          saturated(jl) = .false.
          if (pressure_used(jl, jk)) saturated(jl) = pap(jl, jk) <= p_lcl(jl, dep)
        end do
        do jl = kidia, kfdia
          if (.not. pressure_used(jl, jk)) cycle
          w0 = parcel_t(jl, jk + 1)*exner(jl, jk + 1)
          parcel_t(jl, jk) = w0/exner(jl, jk)
          parcel_q(jl, jk) = parcel_q(jl, jk + 1)
        end do
        child_status=cuadjtq(constants,thermal,ydephli,kidia,kfdia,klon,klev,jk,pap(:,jk),parcel_t,parcel_q,saturated,1_c_int)
        call require(child_status == 0)
        do jl = kidia, kfdia
          dep = departure(jl, parcel)
          departed(jl) = .false.
          if (pressure_used(jl, jk)) departed(jl) = pap(jl, jk) <= p_mix(jl, dep)
          if (.not. departed(jl)) cycle
          w0 = parcel_t(jl, jk)*exner(jl, jk)
          w1 = constants%retv*parcel_q(jl, jk); w1 = 1.0_c_double + w1
          w0 = w0*w1; w0 = w0*inverse_theta_v(jl, jk)
          buoyancy = w0 - 1.0_c_double
          if (pap(jl, jk) <= p_lcl(jl, dep)) then
            w0 = ordered_maximum(0.0_c_double, buoyancy)
            w0 = w0*hydrostatic_weight(jl, jk)
            cape(jl, dep) = cape(jl, dep) + w0
          end if
          if (.not. (buoyancy < 0.0_c_double)) cycle
          if (.not. (cape(jl, dep) < 20.0_c_double)) cycle
          w0 = buoyancy*hydrostatic_weight(jl, jk)
          inhibition(jl) = inhibition(jl) + w0
        end do
      end do
      do jl = kidia, kfdia
        dep = departure(jl, parcel)
        w0 = ordered_maximum(ydecumf%rmincin, inhibition(jl))
        pcin(jl, parcel + 1) = -w0
        pcape(jl, parcel + 1) = cape(jl, dep)
      end do
    end do
    deallocate (cape, cin, theta_mix, q_mix, p_mix, p_lcl, exner, inverse_theta_e, inverse_theta_v, hydrostatic_weight, &
                parcel_t, parcel_q, pressure_used, mixed_t, mixed_theta_v, mixed_theta_e, inhibition, accumulated_pressure, &
                saturated, departed, departure)
  end subroutine
end module convective_energy_diagnostics_mod
