!> Native cloud overlap and shortwave layer transport.
!! All arrays use compiler-owned descriptors. Public C EXP and LOG are explicit
!! external mathematical services; no original model routine supplies a stage.
module native_radiation_layer_transport
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  use, intrinsic :: ieee_arithmetic, only: ieee_is_nan
  implicit none
  private
  public :: calc_reflectance_transmittance_sw, set_overlap_param, set_overlap_param_approx
  interface
    function public_exp(x) bind(C, name="exp") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_log(x) bind(C, name="log") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains
  !> Match IEEE numeric maximum, including signed zero, for one FP64 pair.
  function numeric_max(a, b) result(c)
    real(real64), intent(in) :: a, b
    real(real64) :: c
    if (ieee_is_nan(a)) then
      c = b
    elseif (ieee_is_nan(b)) then
      c = a
    elseif (a > b) then
      c = a
    elseif (a < b) then
      c = b
    elseif (a == 0.0_real64) then
      c = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), c)
    else
      c = a
    end if
  end function
  !> Match IEEE numeric minimum, including signed zero, for one FP64 pair.
  function numeric_min(a, b) result(c)
    real(real64), intent(in) :: a, b
    real(real64) :: c
    if (ieee_is_nan(a)) then
      c = b
    elseif (ieee_is_nan(b)) then
      c = a
    elseif (a < b) then
      c = a
    elseif (a > b) then
      c = b
    elseif (a == 0.0_real64) then
      c = transfer(ior(transfer(a, 0_int64), transfer(b, 0_int64)), c)
    else
      c = a
    end if
  end function
  !> Compute diffuse/direct reflection and transmission for ng intervals.
  !! All arrays are disjoint ng-cell native FP64 arrays. Inputs and outputs are
  !! dimensionless; mu is the solar zenith cosine. No output tail is touched.
  subroutine calc_reflectance_transmittance_sw(ng, mu, depth, ssa, gamma1, gamma2, gamma3, &
                                               diffuse_reflect, diffuse_transmit, direct_reflect, direct_transmit, beam_transmit)
    integer(int32), intent(in) :: ng
    real(real64), intent(in) :: mu, depth(ng), ssa(ng), gamma1(ng), gamma2(ng), gamma3(ng)
    real(real64), intent(inout) :: diffuse_reflect(ng), diffuse_transmit(ng)
    real(real64), intent(inout) :: direct_reflect(ng), direct_transmit(ng), beam_transmit(ng)
    real(real64) :: angle, g1, g2, g3, tau, one_minus_g3, k, alpha1, alpha2
    real(real64) :: p, q, coupling, kg3, kcomplement, beam, e, e2, twoke, reciprocal
    real(real64) :: denominator, scaled, minus, plus, rd, td
    integer :: i
    do i = 1, ng
      angle = mu; g1 = gamma1(i); g2 = gamma2(i); g3 = gamma3(i); tau = depth(i)
      one_minus_g3 = 1.0_real64 - g3
      p = g1 - g2
      q = g1 + g2
      p = p*q
      p = numeric_max(p, 1.0e-12_real64)
      k = sqrt(p)
      p = g1*one_minus_g3
      q = g2*g3
      alpha1 = p + q
      p = g1*g3
      q = g2*one_minus_g3
      alpha2 = p + q
      p = k*angle
      p = 1.0_real64 - p
      p = abs(p)
      if (p < 2.220446049250313080847263336181640625e-13_real64) then
        angle = angle*0.9999999999997779553950749686919152736663818359375_real64
      end if
      p = tau/angle
      coupling = k*angle
      kg3 = k*g3
      kcomplement = k*one_minus_g3
      p = numeric_max(p, 0.0_real64)
      beam = public_exp(-p)
      beam_transmit(i) = beam
      p = k*tau
      e = public_exp(-p)
      e2 = e*e
      twoke = 2.0_real64*k
      twoke = twoke*e
      p = k + g1
      q = k - g1
      q = q*e2
      p = p + q
      reciprocal = 1.0_real64/p
      denominator = coupling*coupling
      denominator = 1.0_real64 - denominator
      scaled = angle*ssa(i)
      minus = 1.0_real64 - coupling
      plus = 1.0_real64 + coupling
      p = 1.0_real64 - e2
      p = g2*p
      diffuse_reflect(i) = p*reciprocal
      diffuse_transmit(i) = twoke*reciprocal
      scaled = scaled*reciprocal
      scaled = scaled/denominator
      p = alpha2 + kg3
      p = minus*p
      q = alpha2 - kg3
      q = plus*q
      q = q*e2
      p = p - q
      q = alpha2*angle
      q = g3 - q
      q = twoke*q
      q = q*beam
      p = p - q
      rd = scaled*p
      rd = numeric_min(rd, 1.0_real64)
      rd = numeric_max(rd, 0.0_real64)
      direct_reflect(i) = rd
      p = alpha1*angle
      p = one_minus_g3 + p
      p = twoke*p
      q = alpha1 + kcomplement
      q = plus*q
      td = alpha1 - kcomplement
      td = minus*td
      td = td*e2
      q = q - td
      q = beam*q
      p = p - q
      td = scaled*p
      q = 1.0_real64 - rd
      td = numeric_min(td, q)
      direct_transmit(i) = numeric_max(td, 0.0_real64)
    end do
  end subroutine
  !> Set full cloud overlap from pressure (Pa), temperature (K) and length (m).
  !! Pressure has shape (columns,levels+1), temperature (columns,levels).
  !! An absent overlap owner is allocated as (columns,levels-1); otherwise its
  !! native allocation and all unselected cells are preserved. Bounds are optional.
  subroutine set_overlap_param(overlap, pressure, temperature, length, first, last)
    real(real64), allocatable, intent(inout) :: overlap(:, :)
    real(real64), intent(in) :: pressure(:, :), temperature(:, :), length
    integer(int32), optional, intent(in) :: first, last
    call overlap_body(overlap, pressure, temperature, length, .false., first, last)
  end subroutine
  !> Set approximate cloud overlap with the fixed 8000 m scale height.
  !! Ownership, dimensions and selected mutation match set_overlap_param.
  subroutine set_overlap_param_approx(overlap, pressure, temperature, length, first, last)
    real(real64), allocatable, intent(inout) :: overlap(:, :)
    real(real64), intent(in) :: pressure(:, :), temperature(:, :), length
    integer(int32), optional, intent(in) :: first, last
    call overlap_body(overlap, pressure, temperature, length, .true., first, last)
  end subroutine
  subroutine overlap_body(overlap, pressure, temperature, length, approximate, first, last)
    real(real64), allocatable, intent(inout) :: overlap(:, :)
    real(real64), intent(in) :: pressure(:, :), temperature(:, :), length
    logical, intent(in) :: approximate
    integer(int32), optional, intent(in) :: first, last
    real(real64), volatile :: factor, half_factor
    real(real64) :: coefficient, ratio, value
    real(real64), parameter :: r_over_g = transfer(int(z'403d4592b265ab8d', int64), 0.0_real64)
    real(real64), parameter :: half_r_over_g = transfer(int(z'402d4592b265ab8d', int64), 0.0_real64)
    integer :: ncol, nlev, begin_col, end_col, k, i, upper, lower, allocation_status
    logical :: ascending
    ncol = size(pressure, 1); nlev = size(pressure, 2) - 1
    begin_col = 1; if (present(first)) begin_col = first
    end_col = ncol; if (present(last)) end_col = last
    if (approximate) then
      factor = 8000.0_real64/length
    else
      factor = r_over_g/length
    end if
    factor = -factor
    half_factor = half_r_over_g/length
    half_factor = -half_factor
    if (.not. allocated(overlap)) then
      allocate (overlap(ncol, nlev - 1), stat=allocation_status)
      if (allocation_status /= 0) call public_abort()
    end if
    ascending = pressure(begin_col, 2) > pressure(begin_col, 1)
    do k = 1, nlev - 1
      if (begin_col > end_col) cycle
      if (approximate) then
        lower = k + 1; upper = k
        if (ascending) upper = k + 2
        coefficient = factor
      elseif (ascending) then
        if (k == 1) then
          upper = 3; lower = 2; coefficient = factor
        else
          upper = k + 2; lower = k; coefficient = half_factor
        end if
      else
        if (k == nlev - 1) then
          upper = nlev - 1; lower = nlev; coefficient = factor
        else
          upper = k; lower = k + 2; coefficient = half_factor
        end if
      end if
      do i = begin_col, end_col
        ratio = pressure(i, upper)/pressure(i, lower)
        value = coefficient
        if (.not. approximate) value = value*temperature(i, k + 1)
        ratio = public_log(ratio)
        value = value*ratio
        overlap(i, k) = public_exp(value)
      end do
    end do
  end subroutine
end module
