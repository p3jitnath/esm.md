!> Ordered turbulent momentum and heat exchange on native column arrays.
module forecast_turbulent_exchange
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: stability_parameter_record
  use yoegwd, only: tegwd
  use yos_surf, only: tsurf
  use spp_mod, only: tspp_config
  implicit none
  private
  public :: vdfexcu
  real(real64), parameter :: kappa = transfer(int(z'3fd999999999999a', int64), 0.0_real64)
  real(real64), parameter :: speed_floor = transfer(int(z'3f847ae147ae147c', int64), 0.0_real64)
  real(real64), parameter :: minimum_length = transfer(int(z'3d19000000000000', int64), 0.0_real64)
  real(real64), parameter :: small_flux = transfer(int(z'3ddb7cdfd9d7bdbb', int64), 0.0_real64)
  real(real64), parameter :: entrainment_factor = transfer(int(z'3fc999999999999a', int64), 0.0_real64)
  real(real64), parameter :: tenth = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
  real(real64), parameter :: minus_third = transfer(int(z'bfd5555555555555', int64), 0.0_real64)
  real(real64), parameter :: third = transfer(int(z'3fd5555555555555', int64), 0.0_real64)
  real(real64), parameter :: cloud_factor = transfer(int(z'3feb333333333333', int64), 0.0_real64)
  real(real64), parameter :: temperature_jump = transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64)
  real(real64), parameter :: latitude_degrees = transfer(int(z'404ca5e353f7ced9', int64), 0.0_real64)
  real(real64), parameter :: hundredth = transfer(int(z'3f847ae147ae147b', int64), 0.0_real64)
  interface
    function public_power(base, exponent) bind(C, name='pow') result(value)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: value
    end function
    function public_exponential(argument) bind(C, name='exp') result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function
  end interface
contains
  !> Calculate four complete returned exchange owners, preserving their tails.
  !! CONSTANTS and STABILITY are produced native readonly physical records.
  !! WAVE is the native gravity-wave record; SURFACE is the owned native
  !! parameter context, whose YEXC%REPUST supplies the minimum friction speed.
  !! SPP is the native stochastic configuration; only its five pointer
  !! selections, PN%MU(1)/XMAG(1)/MP and NRFTOTAL are consumed. No original
  !! module data, constructor, registry query or numerical method is called.
  !! Layer arrays have shape (KLON,KLEV), face arrays (KLON,0:KLEV), column
  !! arrays (KLON), and random fields (KLON,NRFTOTAL). Pressure is Pa,
  !! geopotential m**2/s**2, temperature K and diagnostic PKH/PKM m**2/s.
  !! RPLRG/RPLDARE are dimensionless planetary scales. KLON1:4096 and
  !! KLEV1:1024 are admitted. Output owners are disjoint from all inputs
  !! and one another; unselected cells and the bottom level are preserved.
  !! PZINV/PZCLDBASE remain unread. The caller establishes nearest-even,
  !! gradual underflow and the finite physical domain in the frozen contract.
  !! Return2 before writes for unsupported metadata/strides,0 on completion.
  integer(int32) function vdfexcu(constants, stability, wave, surface, spp, kidia, kfdia, klon, klev, kinv, kcbase, kctop, &
            plam, pz0mm, phrlw, phrsw, pum1, pvm1, ptm1, pqm1, paphm1, pgeom1, pgeoh, pgelat, pcptgz, pkmfl, pkhfl, pkqfl, pkhvfl, &
                                  pgp2dspp, pcfm, pcfh, pzinv, pkh, pkm, pri, pzcldbase, kpbltype, rplrg, rpldare) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(stability_parameter_record), intent(in) :: stability
    type(tegwd), intent(in) :: wave
    type(tsurf), intent(in) :: surface
    type(tspp_config), intent(in) :: spp
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    integer(int32), intent(in) :: kinv(:), kcbase(:), kctop(:), kpbltype(:)
    real(real64), intent(in) :: plam, rplrg, rpldare
    real(real64), intent(in) :: pz0mm(:), phrlw(:, :), phrsw(:, :), pum1(:, :), pvm1(:, :), ptm1(:, :), pqm1(:, :)
    real(real64), intent(in) :: paphm1(:, 0:), pgeom1(:, :), pgeoh(:, 0:), pgelat(:), pcptgz(:, :)
    real(real64), intent(in) :: pkmfl(:), pkhfl(:), pkqfl(:), pkhvfl(:), pgp2dspp(:, :), pzinv(:), pri(:, :), pzcldbase(:)
    real(real64), intent(inout) :: pcfm(:, :), pcfh(:, :), pkh(:, :), pkm(:, :)
    integer :: j, k, inversion, pointer, category, selection(5), n
    real(real64) :: inverse_gravity, inverse_heat_capacity, friction, obukhov, perturb_vd, perturb_kappa
    real(real64) :: cooling, pbl_height, previous_ri, bottom_static, static_energy, richardson_level
    real(real64) :: height_difference, shear, richardson, mid_height, length, squared_length, first, second, temporary
    real(real64) :: momentum_stability, heat_stability, phim, phih, momentum, heat, height, depth, relative_depth, zeta
    real(real64) :: surface_heat_shape, surface_momentum_shape, normal_height, radiative_speed, cloud_mix
    real(real64) :: entrainment, temperature_difference, reduction, latitude, pressure, pressure_factor, virtual_sum
    status = 2_int32
    if (klon < 1 .or. klon > 4096 .or. klev < 1 .or. klev > 1024) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if(.not.is_contiguous(kinv).or..not.is_contiguous(kcbase).or..not.is_contiguous(kctop).or..not.is_contiguous(kpbltype))return
    if (size(kinv) < klon .or. size(kcbase) < klon .or. size(kctop) < klon .or. size(kpbltype) < klon) return
    if (.not. layer_shape(phrlw, klon, klev) .or. .not. layer_shape(phrsw, klon, klev)) return
    if (.not. layer_shape(pum1, klon, klev) .or. .not. layer_shape(pvm1, klon, klev)) return
    if (.not. layer_shape(ptm1, klon, klev) .or. .not. layer_shape(pqm1, klon, klev)) return
if (.not. layer_shape(pgeom1, klon, klev) .or. .not. layer_shape(pcptgz, klon, klev) .or. .not. layer_shape(pri, klon, klev)) return
    if (.not. layer_shape(paphm1, klon, klev + 1) .or. .not. layer_shape(pgeoh, klon, klev + 1)) return
    if (.not. layer_shape(pcfm, klon, klev) .or. .not. layer_shape(pcfh, klon, klev)) return
    if (.not. layer_shape(pkh, klon, klev) .or. .not. layer_shape(pkm, klon, klev)) return
    if (.not. column_shape(pz0mm, klon) .or. .not. column_shape(pgelat, klon)) return
    if (.not. column_shape(pkmfl, klon) .or. .not. column_shape(pkhfl, klon)) return
    if (.not. column_shape(pkqfl, klon) .or. .not. column_shape(pkhvfl, klon)) return
    if (kidia > kfdia) then
      block
        real(real64), volatile :: empty_scalar
        ! Retain both source reciprocals when no column is selected.
        empty_scalar = 1.0_real64/constants%rg
        empty_scalar = 1.0_real64/constants%rcpd
      end block
      status = 0_int32
      return
    end if
    selection = 0
    if (spp%lspp) then
      selection = [spp%pptr%vdexc, spp%pptr%rkap, spp%pptr%rkap1, spp%pptr%rkap2, spp%pptr%rkap3]
      do n = 1, 5
        pointer = selection(n)
        if (pointer <= 0) cycle
        if (.not. allocated(spp%sm%pn)) return
        if (pointer < lbound(spp%sm%pn, 1) .or. pointer > ubound(spp%sm%pn, 1)) return
        if (spp%sm%pn(pointer)%mp < 1 .or. spp%sm%pn(pointer)%mp > spp%sm%nrftotal) return
        if (.not. layer_shape(pgp2dspp, klon, spp%sm%nrftotal)) return
      end do
    end if
    do j = kidia, kfdia
      inversion = kinv(j) - 1
      if (inversion < 1 .or. inversion > klev) return
      if (kpbltype(j) == 2 .and. inversion < 2) return
      if (inversion < klev - 1 .and. inversion < 2) return
      if (kpbltype(j) >= 2 .and. kcbase(j) > kctop(j) + 1) then
        if (kcbase(j) < 1 .or. kcbase(j) > klev + 1) return
      end if
    end do
    inverse_gravity = 1.0_real64/constants%rg
    inverse_heat_capacity = 1.0_real64/constants%rcpd
    do j = kidia, kfdia
      perturb_vd = 1.0_real64
      perturb_kappa = 1.0_real64
      if (spp%lspp) then
        perturb_vd = perturbation_factor(spp, selection(1), pgp2dspp, j)
        category = kpbltype(j)
        if (category >= 0 .and. category <= 3) perturb_kappa = perturbation_factor(spp, selection(category + 2), pgp2dspp, j)
      end if
      inversion = kinv(j) - 1
      friction = sqrt(pkmfl(j))
      friction = max(friction, surface%yexc%repust)
      obukhov = 1.0_real64
      if (pkhvfl(j) < 0.0_real64) then
        first = pkhvfl(j) - small_flux
        second = kappa*perturb_kappa
        second = second*constants%rg
        first = second*first
        second = friction*friction
        second = second*friction
        second = second*ptm1(j, klev)
        obukhov = second/first
        obukhov = sign(max(abs(obukhov), minimum_length), obukhov)
      end if
      cooling = 0.0_real64
      if (kpbltype(j) == 2) then
        first = phrlw(j, inversion) + phrsw(j, inversion)
        second = phrlw(j, inversion - 1) + phrsw(j, inversion - 1)
        first = -min(first, second)
        second = pgeoh(j, inversion - 1) - pgeoh(j, inversion)
        first = first*second
        first = first*inverse_gravity
        first = first/rpldare
        cooling = max(first, 0.0_real64)
      end if
      pbl_height = 0.0_real64
      previous_ri = 0.0_real64
      first = constants%retv*pqm1(j, klev)
      first = 1.0_real64 + first
      second = constants%rcpd*ptm1(j, klev)
      second = second*first
      second = second + pgeom1(j, klev)
      bottom_static = second + small_flux
      if (pkhvfl(j) > 0.0_real64) then
        do k = klev - 1, 1, -1
          first = constants%retv*pqm1(j, k)
          first = 1.0_real64 + first
          second = constants%rcpd*ptm1(j, k)
          second = second*first
          static_energy = second + pgeom1(j, k)
          first = static_energy - bottom_static
          second = static_energy - pgeom1(j, k)
          first = first/second
          second = pgeom1(j, k) - pgeom1(j, klev)
          first = second*first
          second = pum1(j, k)*pum1(j, k)
          temporary = pvm1(j, k)*pvm1(j, k)
          second = second + temporary
          second = max(second, speed_floor)
          richardson_level = first/second
          if (richardson_level > 0.25_real64) then
            first = richardson_level - 0.25_real64
            first = first*pgeom1(j, k + 1)
            second = 0.25_real64 - previous_ri
            second = second*pgeom1(j, k)
            first = first + second
            second = richardson_level - previous_ri
            second = second*constants%rg
            pbl_height = first/second
            exit
          end if
          previous_ri = richardson_level
        end do
      end if
      do k = klev - 1, 1, -1
        height_difference = pgeom1(j, k) - pgeom1(j, k + 1)
        first = pum1(j, k) - pum1(j, k + 1)
        second = pvm1(j, k) - pvm1(j, k + 1)
        first = first*first
        second = second*second
        first = first + second
        first = max(first, speed_floor)
        first = sqrt(first)
        first = first/height_difference
        shear = first*constants%rg
        richardson = pri(j, k)
        first = pgeom1(j, k) + pgeom1(j, k + 1)
        second = 0.5_real64*inverse_gravity
        first = second*first
        mid_height = first + pz0mm(j)
        if (richardson > 0.0_real64) then
          first = pgeom1(j, k)*inverse_gravity
          if (first <= pbl_height) then
            first = perturb_vd*tenth
            first = first*pbl_height
            first = first*rplrg
            first = max(first, 30.0_real64)
            length = min(first, 300.0_real64)
          else
            length = 30.0_real64
          end if
          length = length/rplrg
        else
          length = plam
        end if
        first = kappa*perturb_kappa
        first = first*mid_height
        second = first*length
        first = first + length
        first = second/first
        squared_length = first*first
        if (richardson > 0.0_real64) then
          first = 1.0_real64 + richardson
          first = sqrt(first)
          second = 10.0_real64*richardson
          temporary = second/first
          temporary = 1.0_real64 + temporary
          momentum_stability = 1.0_real64/temporary
          temporary = second*first
          temporary = 1.0_real64 + temporary
          heat_stability = 1.0_real64/temporary
        else
          first = stability%rcdhalf*richardson
          first = 1.0_real64 - first
          first = sqrt(first)
          second = sqrt(first)
          phim = 1.0_real64/second
          phih = 1.0_real64/first
          first = phim*phim
          momentum_stability = 1.0_real64/first
          first = phim*phih
          heat_stability = 1.0_real64/first
        end if
        first = shear*squared_length
        momentum = first*momentum_stability
        heat = first*heat_stability
        if (k > inversion .and. inversion < klev - 1) then
          height = pgeoh(j, k)*inverse_gravity
          depth = pgeoh(j, inversion)*inverse_gravity
          first = max(depth, minimum_length)
          relative_depth = height/first
          zeta = height/obukhov
          first = 39.0_real64*zeta
          first = 1.0_real64 - first
          surface_heat_shape = public_power(first, minus_third)
          first = 15.0_real64*zeta
          first = 1.0_real64 - first
          surface_momentum_shape = public_power(first, minus_third)
          first = 1.0_real64 - relative_depth
          first = first*first
          normal_height = height*first
          if (kpbltype(j) >= 2 .and. kcbase(j) > kctop(j) + 1) then
            first = constants%rcpd*pkhfl(j)
            if (first < -tenth) then
              first = -first
              second = -0.25_real64*constants%rlvtt
              second = second*pkqfl(j)
              if (first < second) then
                first = 1.0_real64 - relative_depth
                first = first*first
                first = first*first
                normal_height = height*first
                first = pgeoh(j, kcbase(j) - 1)*inverse_gravity
                first = max(first, minimum_length)
                first = height/first
                first = min(first, 1.0_real64)
                first = 1.0_real64 - first
                first = first*first
                first = height*first
                normal_height = normal_height + first
              end if
            end if
          end if
          first = kappa*perturb_kappa
          second = first/surface_heat_shape
          first = first/surface_momentum_shape
          second = second*friction
          first = first*friction
          heat = second*normal_height
          momentum = first*normal_height
          if (kpbltype(j) == 2) then
            first = constants%rg/ptm1(j, k)
            first = first*depth
            first = first*cooling
            radiative_speed = public_power(first, third)
            first = height/depth
            first = 1.0_real64 - first
            second = public_power(first, 0.5_real64)
            first = cloud_factor*perturb_kappa
            first = first*kappa
            first = first*radiative_speed
            temporary = height*height
            first = first*temporary
            first = first/depth
            cloud_mix = first*second
            heat = heat + cloud_mix
            momentum = momentum + cloud_mix
          end if
        end if
        if (k == inversion .and. inversion < klev - 1) then
          entrainment = -entrainment_factor*pkhvfl(j)
          if (kpbltype(j) == 2) then
            first = entrainment_factor*cooling
            entrainment = entrainment + first
          end if
          entrainment = max(entrainment, 0.0_real64)
          first = pcptgz(j, k - 1) - pcptgz(j, k)
          first = first*inverse_heat_capacity
          second = pqm1(j, k - 1) - pqm1(j, k)
          temporary = constants%retv*0.5_real64
          second = temporary*second
          temporary = ptm1(j, k) + ptm1(j, k - 1)
          second = second*temporary
          temperature_difference = first + second
          if (temperature_difference > temperature_jump) then
            first = pgeom1(j, k - 1) - pgeom1(j, k)
            first = entrainment*first
            first = first*inverse_gravity
            heat = first/temperature_difference
          else
            heat = 0.0_real64
          end if
          momentum = heat
        end if
        momentum = min(momentum, 1000000.0_real64)
        heat = min(heat, 1000000.0_real64)
        if (wave%lrdiff_strato .and. richardson > 0.25_real64) then
          pressure = paphm1(j, k)
          select case (wave%ndiff_strato)
          case (1)
            if (pressure > 8000.0_real64) then
              first = pressure - 8000.0_real64
              first = first*first
              first = first/16000000.0_real64
              first = min(first, 1.0_real64)
              reduction = max(first, 0.002_real64)
            else
              reduction = 0.002_real64
            end if
            momentum = momentum*reduction
            heat = heat*reduction
          case (2, 5)
            if (wave%ndiff_strato == 5 .or. abs(pgelat(j)) < 0.5_real64) then
              if (wave%ndiff_strato == 5 .and. pressure > 12000.0_real64) then
                reduction = 1.0_real64
              else if (pressure > 8000.0_real64) then
                first = pressure - 8000.0_real64
                first = first*first
                reduction = first/16000000.0_real64
              else if (pressure > 1200.0_real64) then
                reduction = 0.0_real64
              else if (pressure > 800.0_real64) then
                first = pressure - 1200.0_real64
                first = first*first
                reduction = first/160000.0_real64
              else
                reduction = 1.0_real64
              end if
              if (wave%ndiff_strato == 2) then
                reduction = min(reduction, 1.0_real64)
              else
                latitude = abs(pgelat(j))*latitude_degrees
                if (latitude >= 20.0_real64) then
                  if (latitude < 30.0_real64) then
                    first = latitude - 20.0_real64
                    second = hundredth*first
                    second = second*first
                    second = 1.0_real64 - second
                    first = 1.0_real64 - reduction
                    first = second*first
                    reduction = 1.0_real64 - first
                  else
                    reduction = 1.0_real64
                  end if
                end if
              end if
              first = 1.0_real64 + richardson
              first = first*first
              first = first*first
              first = 1.0_real64/first
              reduction = max(reduction, first)
              momentum = momentum*reduction
              heat = heat*reduction
            end if
          end select
        end if
        pkh(j, k) = heat*rpldare
        pkm(j, k) = momentum*rpldare
        first = constants%retv*pqm1(j, k)
        first = 1.0_real64 + first
        first = ptm1(j, k)*first
        second = constants%retv*pqm1(j, k + 1)
        second = 1.0_real64 + second
        second = ptm1(j, k + 1)*second
        virtual_sum = first + second
        first = 0.5_real64*constants%rd
        first = first*height_difference
        first = first*virtual_sum
        second = constants%rg*paphm1(j, k)
        pressure_factor = second/first
        first = momentum*pressure_factor
        second = heat*pressure_factor
        pcfm(j, k) = first*rpldare
        pcfh(j, k) = second*rpldare
      end do
    end do
    status = 0_int32
  end function vdfexcu

  !> Evaluate only a selected stochastic factor from its readonly native owner.
  real(real64) function perturbation_factor(spp, selection, random_fields, column) result(factor)
    type(tspp_config), intent(in) :: spp
    integer, intent(in) :: selection, column
    real(real64), intent(in) :: random_fields(:, :)
    real(real64) :: argument
    factor = 1.0_real64
    if (selection <= 0) return
    argument = spp%sm%pn(selection)%xmag(1)*random_fields(column, spp%sm%pn(selection)%mp)
    argument = spp%sm%pn(selection)%mu(1) + argument
    factor = public_exponential(argument)
  end function

  logical function layer_shape(array, columns, levels) result(valid)
    real(real64), intent(in) :: array(:, :)
    integer, intent(in) :: columns, levels
    valid = .false.
    if (.not. is_contiguous(array)) return
    valid = size(array, 1) >= columns .and. size(array, 2) >= levels
  end function
  logical function column_shape(array, columns) result(valid)
    real(real64), intent(in) :: array(:)
    integer, intent(in) :: columns
    valid = .false.
    if (.not. is_contiguous(array)) return
    valid = size(array) >= columns
  end function
end module forecast_turbulent_exchange
