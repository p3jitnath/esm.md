!> Own complete longwave two-stream layer calculation.
!! Spectral arrays have ng FP64 cells. Optical depth and two-stream
!! coefficients are dimensionless; Planck values and emission use W/m2.
!! Outputs are separate writable owners. The caller establishes IEEE mode.
!! Scientific source attribution: ECMWF radiation_two_stream and the
!! retained longwave layer energy contract.
module native_longwave_layer_transport
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_is_finite
  use ieee_exceptions, only: ieee_all, ieee_get_flag, ieee_set_flag
  implicit none
  private
  public :: calc_reflectance_transmittance_lw
  interface
    function public_exp(x) bind(C, name="exp") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains
!> Validate every spectral cell before replacing any output cell.
!! The supported thin branch excludes the retained conservative-source
!! negative-emission defect. Admission restores incoming exception flags.
!! The numerical loop keeps each intermediate FP64 rounding separately.
  subroutine calc_reflectance_transmittance_lw(ng, od, gamma1, gamma2, planck_top, planck_bot, &
                                               reflectance, transmittance, source_up, source_dn)
    integer(int32), intent(in) :: ng
    real(real64), intent(in) :: od(ng), gamma1(ng), gamma2(ng), planck_top(ng), planck_bot(ng)
    real(real64), intent(inout) :: reflectance(ng), transmittance(ng), source_up(ng), source_dn(ng)
    real(real64) :: difference, total, product, root, tau, a, b, k, e, e2, reciprocal, p, q, r, t, coef, ut, ub, dt, db, su, sd
    logical :: incoming(size(ieee_all))
    integer :: i
    if (ng <= 0) return
    if (ng > 4096) call public_abort()
    call ieee_get_flag(ieee_all, incoming)
    do i = 1, ng
      if (.not. ieee_is_finite(od(i)) .or. .not. ieee_is_finite(gamma1(i)) .or. &
          .not. ieee_is_finite(gamma2(i)) .or. .not. ieee_is_finite(planck_top(i)) .or. &
          .not. ieee_is_finite(planck_bot(i))) call public_abort()
      if (min(od(i), gamma1(i), gamma2(i), planck_top(i), planck_bot(i)) < 0.0_real64) call public_abort()
      if (max(od(i), gamma1(i), gamma2(i), planck_top(i), planck_bot(i)) > 1.0e6_real64) call public_abort()
      difference = gamma1(i) - gamma2(i)
      if (difference <= 0.0_real64) call public_abort()
      total = gamma1(i) + gamma2(i)
      product = difference*total
      if (product <= 1.0e-12_real64) call public_abort()
      if (od(i) <= 1.0e-3_real64) then
        root = sqrt(product)
        p = root*od(i)
        if (p > 1.0_real64) call public_abort()
        p = gamma1(i) - root
        p = gamma2(i)*p
        p = p*od(i)
        p = difference - p
        if (p < 0.0_real64) call public_abort()
      end if
    end do
    call ieee_set_flag(ieee_all, incoming)
    do i = 1, ng
      tau = od(i); a = gamma1(i); b = gamma2(i)
      p = a - b
      q = a + b
      product = p*q
      k = sqrt(max(product, 1.0e-12_real64))
      if (tau > 1.0e-3_real64) then
        p = k*tau
        p = -p
        e = public_exp(p)
        e2 = e*e
        p = k + a
        q = k - a
        q = q*e2
        q = p + q
        reciprocal = 1.0_real64/q
        p = 1.0_real64 - e2
        p = b*p
        r = p*reciprocal
        p = 2.0_real64*k
        p = p*e
        t = p*reciprocal
        p = planck_bot(i) - planck_top(i)
        q = a + b
        q = tau*q
        coef = p/q
        ut = coef + planck_top(i)
        ub = coef + planck_bot(i)
        dt = (-coef) + planck_top(i)
        db = (-coef) + planck_bot(i)
        p = r*dt
        q = ut - p
        p = t*ub
        su = q - p
        p = r*ub
        q = db - p
        p = t*dt
        sd = q - p
      else
        r = b*tau
        p = k*tau
        p = 1.0_real64 - p
        q = a - k
        q = tau*q
        q = 1.0_real64 + q
        t = p/q
        p = 1.0_real64 - r
        p = p - t
        p = p*0.5_real64
        q = planck_top(i) + planck_bot(i)
        su = p*q
        sd = su
      end if
      reflectance(i) = r; transmittance(i) = t; source_up(i) = su; source_dn(i) = sd
    end do
  end subroutine
end module
