!> Diagnose boundary-layer height and wind at a blending height.
!>
!> The caller supplies native contiguous arrays and explicit physical constants.
!> Columns are contiguous; the second profile index counts levels downwards.
!> The caller establishes nearest-even rounding and gradual underflow once.
module forecast_boundary_layer_helpers
  use, intrinsic :: iso_c_binding, only: c_double, c_int32_t
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  implicit none
  private
  public :: vdfdpbl, vdffblend

contains

  !> Return the first bulk-stability crossing height in metres.
  !>
  !> KIDIA:KFDIA is the inclusive selected column interval. KLON is 0..4096
  !> and KLEV is 1..1024. The five profiles have shape (KLON,KLEV).
  !> PUM1/PVM1 are winds in m/s; PTM1 is temperature in K; PQM1 is specific
  !> humidity in kg/kg; PGEOM1 is geopotential in m2/s2. The three length-KLON
  !> flux inputs remain unread. PDHPBL is a complete length-KLON INOUT owner;
  !> only selected elements are replaced, and all input owners are disjoint
  !> from it. RG is gravity in m/s2, RCPD is dry-air heat capacity in J/(kg K),
  !> RETV is a dimensionless humidity factor and RPLRG is the planet factor.
  !> STATUS is int32: zero succeeds, two refuses unsupported bounds or shapes or noncontiguous views
  !> before any output write. The physical input domain is a caller condition.
  !> This is a native Fortran module interface; the compiler owns descriptors.
  subroutine vdfdpbl(kidia, kfdia, klon, klev, pum1, pvm1, ptm1, pqm1, pgeom1, &
                     pkmfl, pkhfl, pkqfl, pdhpbl, rg, rcpd, retv, rplrg, status)
    integer(c_int32_t), intent(in) :: kidia, kfdia, klon, klev
    real(c_double), intent(in) :: pum1(:, :), pvm1(:, :)
    real(c_double), intent(in) :: ptm1(:, :), pqm1(:, :), pgeom1(:, :)
    real(c_double), intent(in) :: pkmfl(:), pkhfl(:), pkqfl(:)
    real(c_double), intent(inout) :: pdhpbl(:)
    real(c_double), intent(in) :: rg, rcpd, retv, rplrg
    integer(c_int32_t), intent(out) :: status
    integer(c_int32_t) :: jl, jk
    real(c_double), parameter :: epsilon_energy = 1.0e-10_c_double
    real(c_double), parameter :: critical_ri = 0.25_c_double
    real(c_double), parameter :: wind_floor = 0.010000000000000002_c_double
    real(c_double), volatile :: default_height, bottom_energy, bottom_perturbed
    real(c_double) :: cp_t, humidity_factor, thermal_energy, energy
    real(c_double) :: bottom_phi, phi, wind_u_square, wind_v_square, wind_square
    real(c_double) :: previous_ri, richardson, ratio, numerator, denominator
    real(c_double) :: phi_difference, left_weight, right_weight, left_term, right_term
    real(c_double) :: height

    status = 2_c_int32_t
    if (klon < 0 .or. klon > 4096 .or. klev < 1 .or. klev > 1024) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. is_contiguous(pum1) .or. .not. is_contiguous(pvm1)) return
    if (.not. is_contiguous(pgeom1)) return
    if (size(pum1, 1) /= klon .or. size(pum1, 2) /= klev) return
    if (size(pvm1, 1) /= klon .or. size(pvm1, 2) /= klev) return
    if (.not. is_contiguous(ptm1) .or. .not. is_contiguous(pqm1)) return
    if (.not. is_contiguous(pkmfl) .or. .not. is_contiguous(pkhfl)) return
    if (.not. is_contiguous(pkqfl) .or. .not. is_contiguous(pdhpbl)) return
    if (size(ptm1, 1) /= klon .or. size(ptm1, 2) /= klev) return
    if (size(pqm1, 1) /= klon .or. size(pqm1, 2) /= klev) return
    if (size(pgeom1, 1) /= klon .or. size(pgeom1, 2) /= klev) return
    if (size(pkmfl) /= klon .or. size(pkhfl) /= klon .or. size(pkqfl) /= klon) return
    if (size(pdhpbl) /= klon) return

    ! The frozen source divides before an admitted empty column range.
    default_height = 1000.0_c_double/rplrg
    do jl = kidia, kfdia
      height = default_height
      bottom_phi = pgeom1(jl, klev)
      cp_t = rcpd*ptm1(jl, klev)
      humidity_factor = retv*pqm1(jl, klev)
      humidity_factor = 1.0_c_double + humidity_factor
      thermal_energy = cp_t*humidity_factor
      bottom_energy = thermal_energy + bottom_phi
      bottom_perturbed = bottom_energy + epsilon_energy
      previous_ri = 0.0_c_double

      do jk = klev - 1, 1, -1
        phi = pgeom1(jl, jk)
        cp_t = rcpd*ptm1(jl, jk)
        humidity_factor = retv*pqm1(jl, jk)
        humidity_factor = 1.0_c_double + humidity_factor
        thermal_energy = cp_t*humidity_factor
        energy = thermal_energy + phi
        wind_u_square = pum1(jl, jk)*pum1(jl, jk)
        wind_v_square = pvm1(jl, jk)*pvm1(jl, jk)
        wind_square = wind_u_square + wind_v_square
        if (wind_square < wind_floor) wind_square = wind_floor
        numerator = energy - bottom_perturbed
        denominator = energy - phi
        ratio = numerator/denominator
        phi_difference = phi - bottom_phi
        richardson = phi_difference*ratio
        richardson = richardson/wind_square
        if (richardson > critical_ri) then
          left_weight = richardson - critical_ri
          right_weight = critical_ri - previous_ri
          left_term = left_weight*pgeom1(jl, jk + 1)
          right_term = right_weight*phi
          numerator = left_term + right_term
          denominator = richardson - previous_ri
          denominator = denominator*rg
          height = numerator/denominator
          exit
        end if
        previous_ri = richardson
      end do
      pdhpbl(jl) = height
    end do
    status = 0_c_int32_t
  end subroutine vdfdpbl

  !> Return wind speed relative to the surface current in m/s.
  !>
  !> KIDIA:KFDIA selects columns; KLON is 1..4096 and KLEV is 1..1024.
  !> PUM1/PVM1/PGEOM1 have shape (KLON,KLEV); PUCURR, PVCURR, PBLEND and
  !> PFBLEND have length KLON. Winds and currents are in m/s, PGEOM1 is in
  !> m2/s2, PBLEND is in metres, and RG is gravity in m/s2. PFBLEND is INOUT
  !> and disjoint from all inputs. Its inactive elements retain their bits.
  !> STATUS zero succeeds; two refuses unsupported bounds, shapes or physical
  !> preflight before any output write. Empty ranges return before gravity
  !> or payload reads. VOLATILE preserves the first-stage output store even
  !> when interpolation later replaces it. The compiler owns descriptors.
  subroutine vdffblend(kidia, kfdia, klon, klev, pum1, pvm1, pgeom1, pucurr, pvcurr, &
                       pblend, pfblend, rg, status)
    integer(c_int32_t), intent(in) :: kidia, kfdia, klon, klev
    real(c_double), intent(in) :: pum1(:, :), pvm1(:, :), pgeom1(:, :)
    real(c_double), intent(in) :: pucurr(:), pvcurr(:), pblend(:)
    real(c_double), volatile, intent(inout) :: pfblend(:)
    real(c_double), intent(in) :: rg
    integer(c_int32_t), intent(out) :: status
    integer(c_int32_t) :: jl, jk
    real(c_double) :: target, effective_target, lower_phi, upper_phi, previous_phi
    real(c_double) :: lower_distance, upper_distance, denominator
    real(c_double) :: upper_term, lower_term, u_interpolated, v_interpolated
    real(c_double) :: u_relative, v_relative, u_square, v_square, squared_speed
    real(c_double), parameter :: gravity_limit = 100.0_c_double
    real(c_double), parameter :: height_limit = 1.0e10_c_double
    real(c_double), parameter :: phi_limit = 1.0e12_c_double
    real(c_double), parameter :: wind_limit = 1.0e6_c_double

    status = 2_c_int32_t
    if (klon < 1 .or. klon > 4096 .or. klev < 1 .or. klev > 1024) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (kidia > kfdia) then
      status = 0_c_int32_t
      return
    end if
    if (size(pum1, 1) /= klon .or. size(pum1, 2) /= klev) return
    if (size(pvm1, 1) /= klon .or. size(pvm1, 2) /= klev) return
    if (size(pgeom1, 1) /= klon .or. size(pgeom1, 2) /= klev) return
    if (.not. is_contiguous(pucurr) .or. .not. is_contiguous(pvcurr)) return
    if (.not. is_contiguous(pblend) .or. .not. is_contiguous(pfblend)) return
    if (size(pucurr) /= klon .or. size(pvcurr) /= klon .or. size(pblend) /= klon) return
    if (size(pfblend) /= klon) return

    if (.not. ieee_is_finite(rg)) return
    if (rg <= 0.0_c_double .or. rg > gravity_limit) return
    do jl = kidia, kfdia
      if (.not. ieee_is_finite(pucurr(jl))) return
      if (abs(pucurr(jl)) > wind_limit) return
      if (.not. ieee_is_finite(pvcurr(jl))) return
      if (abs(pvcurr(jl)) > wind_limit) return
      if (.not. ieee_is_finite(pblend(jl))) return
      if (pblend(jl) < 0.0_c_double .or. pblend(jl) > height_limit) return
      target = pblend(jl)*rg
      if (.not. (target < pgeom1(jl, 1))) return
      previous_phi = 0.0_c_double
      do jk = 1, klev
        if (.not. ieee_is_finite(pgeom1(jl, jk))) return
        if (abs(pgeom1(jl, jk)) > phi_limit) return
        if (jk > 1) then
          if (previous_phi <= pgeom1(jl, jk)) return
        end if
        previous_phi = pgeom1(jl, jk)
        if (.not. ieee_is_finite(pum1(jl, jk))) return
        if (abs(pum1(jl, jk)) > wind_limit) return
        if (.not. ieee_is_finite(pvm1(jl, jk))) return
        if (abs(pvm1(jl, jk)) > wind_limit) return
      end do
    end do

    do jl = kidia, kfdia
      target = pblend(jl)*rg
      lower_phi = pgeom1(jl, klev)
      effective_target = target
      if (target < lower_phi) then
        u_relative = pum1(jl, klev) - pucurr(jl)
        v_relative = pvm1(jl, klev) - pvcurr(jl)
        u_square = u_relative*u_relative
        v_square = v_relative*v_relative
        squared_speed = u_square + v_square
        pfblend(jl) = sqrt(squared_speed)
        effective_target = lower_phi
      end if
      do jk = klev, 2, -1
        lower_phi = pgeom1(jl, jk)
        upper_phi = pgeom1(jl, jk - 1)
        if (effective_target >= upper_phi) cycle
        if (effective_target < lower_phi) cycle
        lower_distance = effective_target - lower_phi
        upper_distance = upper_phi - effective_target
        denominator = upper_phi - lower_phi

        upper_term = pum1(jl, jk - 1)*lower_distance
        lower_term = pum1(jl, jk)*upper_distance
        u_interpolated = upper_term + lower_term
        u_interpolated = u_interpolated/denominator
        upper_term = pvm1(jl, jk - 1)*lower_distance
        lower_term = pvm1(jl, jk)*upper_distance
        v_interpolated = upper_term + lower_term
        v_interpolated = v_interpolated/denominator

        u_relative = u_interpolated - pucurr(jl)
        v_relative = v_interpolated - pvcurr(jl)
        u_square = u_relative*u_relative
        v_square = v_relative*v_relative
        squared_speed = u_square + v_square
        pfblend(jl) = sqrt(squared_speed)
        exit
      end do
    end do
    status = 0_c_int32_t
  end subroutine vdffblend

end module forecast_boundary_layer_helpers
