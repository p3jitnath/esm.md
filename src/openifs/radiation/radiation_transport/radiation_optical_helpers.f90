!> Portable optical helpers from the retained Markdown and ordered source contracts.
!! FP64 operations retain separate rounding. The caller establishes nearest-even
!! arithmetic and gradual underflow. Counts and actual arrays must match.
module native_radiation_optical_helpers
  use iso_c_binding, only: c_double, c_int
  use iso_fortran_env, only: real64, int32, int64
  implicit none
  private
  public :: delta_eddington_extensive, delta_eddington_scat_od
  public :: crop_cloud_fraction, indexed_sum
  public :: calc_two_stream_gammas_lw, calc_two_stream_gammas_sw
  public :: calc_ice_optics_fu_lw, calc_ice_optics_fu_sw
  public :: calc_liq_optics_socrates, calc_fluxes_no_scattering_lw
contains
  !> Update three disjoint dimensionless FP64 optical scalars in place.
  subroutine delta_eddington_extensive(tau, scatter, weighted) bind(C, name="md2asm_delta_eddington_extensive_fortran")
    real(c_double), intent(inout) :: tau, scatter, weighted
    real(c_double) :: t, s, q, g, f, a, h, b, d
    t = tau; s = scatter; q = weighted
    if (s > 0.0_c_double) then
      g = q/s
    else
      g = 0.0_c_double
    end if
    f = g*g
    a = s*f
    t = t - a
    tau = t
    h = 1.0_c_double - f
    s = s*h
    scatter = s
    b = s*g
    d = 1.0_c_double + g
    weighted = b/d
  end subroutine
  !> Rescale three disjoint dimensionless cloud optical scalars in place.
  subroutine delta_eddington_scat_od(tau, scatter, g) bind(C, name="md2asm_delta_eddington_scat_od_fortran")
    real(c_double), intent(inout) :: tau, scatter, g
    real(c_double) :: t, s, a, f, h, d, oldg
    t = tau; s = scatter; oldg = g
    f = oldg*oldg
    a = s*f
    t = t - a
    tau = t
    h = 1.0_c_double - f
    s = s*h
    scatter = s
    d = 1.0_c_double + oldg
    g = oldg/d
  end subroutine
  !> Clear selected cloud fractions below either strict threshold.
  !! Water arrays contain kg/kg. The three arrays have shape (columns,layers).
  !! Only fraction(first:last,:) changes. Native sections may have signed strides.
  subroutine crop_cloud_fraction(q_liq, q_ice, fraction, first, last, area_threshold, water_threshold)
    real(real64), intent(in) :: q_liq(:, :), q_ice(:, :), area_threshold, water_threshold
    real(real64), intent(inout) :: fraction(:, :)
    integer(int32), intent(in) :: first, last
    integer :: i, k
    real(real64) :: water
    do k = 1, size(fraction, 2)
      do i = first, last
        if (fraction(i, k) < area_threshold) then
          fraction(i, k) = 0.0_real64
        else
          water = q_liq(i, k) + q_ice(i, k)
          if (water < water_threshold) fraction(i, k) = 0.0_real64
        end if
      end do
    end do
  end subroutine
  !> Sum source fluxes (W/m2) into one-based destination bands in source order.
  !! Source and index lengths agree. All three native arrays are disjoint.
  subroutine indexed_sum(source, index, destination)
    real(real64), intent(in) :: source(:)
    integer(int32), intent(in) :: index(:)
    real(real64), intent(inout) :: destination(:)
    integer :: i
    do i = 1, size(destination)
      destination(i) = 0.0_real64
    end do
    do i = 1, size(source)
      destination(index(i)) = destination(index(i)) + source(i)
    end do
  end subroutine
  !> Compute dimensionless longwave two-stream coefficients for the first ng cells.
  !! Inputs and disjoint outputs are native rank-one arrays of at least ng cells.
  subroutine calc_two_stream_gammas_lw(ng, ssa, g, gamma1, gamma2)
    integer(int32), intent(in) :: ng
    real(real64), intent(in) :: ssa(:), g(:)
    real(real64), intent(inout) :: gamma1(:), gamma2(:)
    integer :: i
    real(real64) :: factor, a, b
    do i = 1, ng
      factor = 0.83_real64*ssa(i)
      a = 1.0_real64 + g(i)
      a = factor*a
      a = 1.66_real64 - a
      b = 1.0_real64 - g(i)
      b = factor*b
      gamma1(i) = a
      gamma2(i) = b
    end do
  end subroutine
  !> Compute dimensionless shortwave coefficients; mu is the solar zenith cosine.
  !! Only cells 1:ng of the three disjoint output arrays change.
  subroutine calc_two_stream_gammas_sw(ng, mu, ssa, g, gamma1, gamma2, gamma3)
    integer(int32), intent(in) :: ng
    real(real64), intent(in) :: mu, ssa(:), g(:)
    real(real64), intent(inout) :: gamma1(:), gamma2(:), gamma3(:)
    integer :: i
    real(real64) :: factor, a, b, c
    do i = 1, ng
      factor = g(i)*0.75_real64
      a = 1.25_real64 + factor
      a = ssa(i)*a
      a = 2.0_real64 - a
      b = 0.75_real64 - factor
      b = ssa(i)*b
      c = mu*factor
      c = 0.5_real64 - c
      gamma1(i) = a; gamma2(i) = b; gamma3(i) = c
    end do
  end subroutine
  !> Compute Fu longwave ice optics for nb bands.
  !! Coefficients have at least (nb,11) cells; water is kg/m2 and radius is m.
  !! Outputs are dimensionless explicit arrays of nb cells. Stages remain ordered.
  subroutine calc_ice_optics_fu_lw(nb, c, water, radius, tau, scatter, g)
    integer(int32), intent(in) :: nb
    real(real64), intent(in) :: c(:, :), water, radius
    real(real64), intent(inout) :: tau(nb), scatter(nb), g(nb)
    real(real64), volatile :: diameter, inverse, iwp
    real(real64) :: p, q
    integer :: i
    diameter = radius*transfer(int(z'41377e0e79041148', int64), 0.0_real64)
    inverse = 1.0_real64/diameter
    iwp = water*1000.0_real64
    if (nb <= 0) return
    do i = 1, nb
      p = inverse*c(i, 3)
      p = c(i, 2) + p
      p = inverse*p
      p = c(i, 1) + p
      tau(i) = iwp*p
    end do
    q = iwp*inverse
    do i = 1, nb
      p = diameter*c(i, 7)
      p = c(i, 6) + p
      p = diameter*p
      p = c(i, 5) + p
      p = diameter*p
      p = c(i, 4) + p
      p = q*p
      scatter(i) = tau(i) - p
    end do
    do i = 1, nb
      p = diameter*c(i, 11)
      p = c(i, 10) + p
      p = diameter*p
      p = c(i, 9) + p
      p = diameter*p
      p = c(i, 8) + p
      if (p <= 1.0_real64) then
        g(i) = p
      else
        g(i) = 1.0_real64
      end if
    end do
  end subroutine
  !> Compute Fu shortwave ice optics from (nb,10) coefficients.
  !! Water is kg/m2, radius is m, and all three nb-cell outputs are dimensionless.
  subroutine calc_ice_optics_fu_sw(nb, c, water, radius, tau, scatter, g)
    integer(int32), intent(in) :: nb
    real(real64), intent(in) :: c(:, :), water, radius
    real(real64), intent(inout) :: tau(nb), scatter(nb), g(nb)
    real(real64), volatile :: diameter, inverse, iwp
    real(real64) :: p
    integer :: i
    diameter = radius*transfer(int(z'41377e0e79041148', int64), 0.0_real64)
    inverse = 1.0_real64/diameter
    iwp = water*1000.0_real64
    if (nb <= 0) return
    do i = 1, nb
      p = c(i, 2)*inverse
      p = c(i, 1) + p
      tau(i) = iwp*p
    end do
    do i = 1, nb
      p = diameter*c(i, 6)
      p = c(i, 5) + p
      p = diameter*p
      p = c(i, 4) + p
      p = diameter*p
      p = c(i, 3) + p
      p = 1.0_real64 - p
      scatter(i) = tau(i)*p
    end do
    do i = 1, nb
      p = diameter*c(i, 10)
      p = c(i, 9) + p
      p = diameter*p
      p = c(i, 8) + p
      p = diameter*p
      p = c(i, 7) + p
      if (p <= 1.0_real64) then
        g(i) = p
      else
        g(i) = 1.0_real64
      end if
    end do
  end subroutine
  !> Compute liquid cloud rational fits from a native (at least nb,16) table.
  !! Water is kg/m2, radius is m, outputs are dimensionless nb-cell arrays.
  subroutine calc_liq_optics_socrates(nb, c, water, radius, tau, scatter, g)
    integer(int32), intent(in) :: nb
    real(real64), intent(in) :: c(:, :), water, radius
    real(real64), intent(inout) :: tau(nb), scatter(nb), g(nb)
    real(real64) :: p, q
    integer :: i
    do i = 1, nb
      p = radius*c(i, 3); p = c(i, 2) + p; p = radius*p; p = c(i, 1) + p
      p = water*p
      q = radius*c(i, 6); q = c(i, 5) + q; q = radius*q; q = c(i, 4) + q
      q = radius*q; q = 1.0_real64 + q
      tau(i) = p/q
    end do
    do i = 1, nb
      p = radius*c(i, 9); p = c(i, 8) + p; p = radius*p; p = c(i, 7) + p
      q = radius*c(i, 11); q = c(i, 10) + q; q = radius*q; q = 1.0_real64 + q
      p = p/q; p = 1.0_real64 - p
      scatter(i) = tau(i)*p
    end do
    do i = 1, nb
      p = radius*c(i, 14); p = c(i, 13) + p; p = radius*p; p = c(i, 12) + p
      q = radius*c(i, 16); q = c(i, 15) + q; q = radius*q; q = 1.0_real64 + q
      g(i) = p/q
    end do
  end subroutine
  !> Compute longwave fluxes without scattering through nlev layers.
  !! Layer inputs have shape (ncol,nlev); boundary flux outputs have
  !! shape (ncol,nlev+1). Fluxes use W/m2; transmission and albedo are fractions.
  subroutine calc_fluxes_no_scattering_lw(ncol, nlev, t, source_up, source_dn, emission, albedo, up, dn)
    integer(int32), intent(in) :: ncol, nlev
    real(real64), intent(in) :: t(ncol, nlev), source_up(ncol, nlev), source_dn(ncol, nlev)
    real(real64), intent(in) :: emission(ncol), albedo(ncol)
    real(real64), intent(inout) :: up(ncol, nlev + 1), dn(ncol, nlev + 1)
    integer :: i, k
    real(real64) :: downward, upward, p
    do i = 1, ncol
      downward = 0.0_real64
      dn(i, 1) = downward
      do k = 1, nlev
        p = t(i, k)*downward
        downward = p + source_dn(i, k)
        dn(i, k + 1) = downward
      end do
      p = albedo(i)*downward
      upward = emission(i) + p
      up(i, nlev + 1) = upward
      do k = nlev, 1, -1
        p = t(i, k)*upward
        upward = p + source_up(i, k)
        up(i, k) = upward
      end do
    end do
  end subroutine
end module
