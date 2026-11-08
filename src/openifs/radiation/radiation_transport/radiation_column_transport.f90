!> Ordered layer emission and whole-column flux transport.
!! The caller supplies disjoint native arrays and establishes nearest-even FP64
!! arithmetic with gradual underflow. Each product rounds before its next sum.
module native_radiation_column_transport
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: calc_no_scattering_transmittance_lw, fast_adding_ica_lw, adding_ica_sw
  interface
    function public_exp(x) bind(C, name="exp") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Compute transmission and source fluxes for ng clear longwave intervals.
  !! Depth is dimensionless; top/bottom sources and emitted fluxes are W/m2.
  !! Every array contains ng contiguous cells and all three outputs are overwritten.
  subroutine calc_no_scattering_transmittance_lw(ng, depth, top, bottom, t, source_up, source_dn)
    integer(int32), intent(in) :: ng
    real(real64), intent(in) :: depth(ng), top(ng), bottom(ng)
    real(real64), intent(inout) :: t(ng), source_up(ng), source_dn(ng)
    real(real64) :: scaled, e, gradient, p, q, up, down
    real(real64), parameter :: threshold = transfer(int(z'3f50624de0000000', int64), 0.0_real64)
    integer :: i
    do i = 1, ng
      scaled = 1.66_real64*depth(i)
      if (depth(i) > threshold) then
        e = public_exp(-scaled)
        gradient = bottom(i) - top(i)
        gradient = gradient/scaled
        p = gradient + top(i)
        q = gradient + bottom(i)
        q = e*q
        up = p - q
        p = top(i) - gradient
        q = bottom(i) - gradient
        p = e*p
        down = q - p
      else
        e = 1.0_real64 - scaled
        p = scaled*0.5_real64
        q = top(i) + bottom(i)
        up = p*q
        down = up
      end if
      t(i) = e; source_up(i) = up; source_dn(i) = down
    end do
  end subroutine
  !> Add longwave layer reflection and emission for a complete column.
  !! Layer arrays have shape (ncol,nlev). Sources and boundary fluxes use W/m2.
  !! Albedo and transmission are fractions. Clear flags select source branches.
  !! Flux outputs have shape (ncol,nlev+1); incoming down flux is read only.
  subroutine fast_adding_ica_lw(ncol, nlev, reflectance, transmittance, source_up, source_dn, &
                                emission, albedo, clear, first_cloud_top, incoming_dn, flux_up, flux_dn)
    integer(int32), intent(in) :: ncol, nlev, first_cloud_top
    real(real64), intent(in) :: reflectance(ncol, nlev), transmittance(ncol, nlev)
    real(real64), intent(in) :: source_up(ncol, nlev), source_dn(ncol, nlev)
    real(real64), intent(in) :: emission(ncol), albedo(ncol), incoming_dn(ncol, nlev + 1)
    logical, intent(in) :: clear(nlev)
    real(real64), intent(inout) :: flux_up(ncol, nlev + 1), flux_dn(ncol, nlev + 1)
    real(real64) :: effective_albedo(nlev + 1), effective_source(nlev + 1), inverse(nlev)
    real(real64) :: a, b, t, r, upward, downward, p, q, inv, next_a, next_b
    integer :: i, k, top
    top = first_cloud_top
    do i = 1, ncol
      do k = 1, top
        flux_dn(i, k) = incoming_dn(i, k)
      end do
      a = albedo(i); b = emission(i)
      effective_albedo(nlev + 1) = a
      effective_source(nlev + 1) = b
      do k = nlev, top, -1
        t = transmittance(i, k)
        p = t*t
        next_a = p*a
        p = a*source_dn(i, k)
        p = b + p
        next_b = t*p
        if (clear(k)) then
          next_b = source_up(i, k) + next_b
        else
          r = reflectance(i, k)
          p = a*r
          p = 1.0_real64 - p
          inv = 1.0_real64/p
          inverse(k) = inv
          next_a = next_a*inv
          next_a = r + next_a
          next_b = next_b*inv
          next_b = source_up(i, k) + next_b
        end if
        effective_albedo(k) = next_a
        effective_source(k) = next_b
        a = next_a; b = next_b
      end do
      downward = flux_dn(i, top)
      p = a*downward
      upward = b + p
      flux_up(i, top) = upward
      do k = top - 1, 1, -1
        p = transmittance(i, k)*upward
        upward = p + source_up(i, k)
        flux_up(i, k) = upward
      end do
      do k = top, nlev
        a = effective_albedo(k + 1); b = effective_source(k + 1)
        p = transmittance(i, k)*downward
        if (clear(k)) then
          q = p + source_dn(i, k)
        else
          q = reflectance(i, k)*b
          p = p + q
          p = p + source_dn(i, k)
          q = p*inverse(k)
        end if
        p = a*q
        upward = p + b
        flux_dn(i, k + 1) = q
        flux_up(i, k + 1) = upward
        downward = q
      end do
    end do
  end subroutine
  !> Add all shortwave reflection paths through nlev layers.
  !! Inputs have ncol independent spectral columns. Layer coefficients are
  !! dimensionless (ncol,nlev); incoming and returned fluxes use W/m2.
  !! Complete up, diffuse-down and direct-down outputs have nlev+1 boundaries.
  subroutine adding_ica_sw(ncol, nlev, incoming, albedo_diffuse, albedo_direct, mu, &
                           reflectance, transmittance, source_up, source_dn, direct_transmittance, up, dn, direct)
    integer(int32), intent(in) :: ncol, nlev
    real(real64), intent(in) :: incoming(ncol), albedo_diffuse(ncol), albedo_direct(ncol), mu(ncol)
    real(real64), intent(in) :: reflectance(ncol, nlev), transmittance(ncol, nlev)
    real(real64), intent(in) :: source_up(ncol, nlev), source_dn(ncol, nlev), direct_transmittance(ncol, nlev)
    real(real64), intent(inout) :: up(ncol, nlev + 1), dn(ncol, nlev + 1), direct(ncol, nlev + 1)
    real(real64) :: effective_albedo(nlev + 1), effective_source(nlev + 1), inverse(nlev)
    real(real64) :: beam, a, b, p, q, inv, next_a, next_b, downward, upward
    integer :: i, k
    do i = 1, ncol
      beam = incoming(i)
      direct(i, 1) = beam
      do k = 1, nlev
        beam = beam*direct_transmittance(i, k)
        direct(i, k + 1) = beam
      end do
      a = albedo_diffuse(i)
      b = albedo_direct(i)*beam
      b = b*mu(i)
      effective_albedo(nlev + 1) = a
      effective_source(nlev + 1) = b
      do k = nlev, 1, -1
        p = a*reflectance(i, k)
        p = 1.0_real64 - p
        inv = 1.0_real64/p
        inverse(k) = inv
        p = transmittance(i, k)*transmittance(i, k)
        p = p*a
        p = p*inv
        next_a = reflectance(i, k) + p
        next_b = source_up(i, k)*direct(i, k)
        p = a*source_dn(i, k)
        p = p*direct(i, k)
        p = b + p
        p = transmittance(i, k)*p
        p = p*inv
        next_b = next_b + p
        effective_albedo(k) = next_a
        effective_source(k) = next_b
        a = next_a; b = next_b
      end do
      downward = 0.0_real64
      dn(i, 1) = downward
      up(i, 1) = b
      do k = 1, nlev
        a = effective_albedo(k + 1); b = effective_source(k + 1)
        p = transmittance(i, k)*downward
        q = reflectance(i, k)*b
        p = p + q
        q = source_dn(i, k)*direct(i, k)
        p = p + q
        downward = p*inverse(k)
        p = a*downward
        upward = p + b
        beam = direct(i, k)*mu(i)
        direct(i, k) = beam
        dn(i, k + 1) = downward
        up(i, k + 1) = upward
      end do
      direct(i, nlev + 1) = direct(i, nlev + 1)*mu(i)
    end do
  end subroutine
end module
