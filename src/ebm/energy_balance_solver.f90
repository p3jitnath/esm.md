!> Advance the energy-balance model with the frozen two-stage update.
!! Physics input formulations/ebm/budyko_sellers.md, revision 1.1.
!! The numerical and storage rules are in skills/md2asm/references/budyko_sellers.md.
!! All calculations use binary64 values. The compiler produces the machine code.
!! The caller supplies round-to-nearest arithmetic with gradual underflow.
module esm_energy_balance
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_int64_t
  implicit none
  private
  public :: eb_step, eb_run
contains
  !> Copy the two pole ghosts, preserving the interior and all sign bits.
  subroutine copy_pole_ghosts(n, q)
    integer(c_int), intent(in) :: n
    real(c_double), intent(inout) :: q(0:n + 1)
    q(0) = q(1)
    q(n + 1) = q(n)
  end subroutine

  !> Write one inclusive cell range while retaining values outside that range.
  !! q and base are read-only temperatures in degrees Celsius, with bounds 0 to n+1.
  !! Each full group shares rounded face fluxes through the caller's work array.
  !! The qualified 4096-cell route reuses work(0:16) to keep its face cache compact.
  !! Other grids retain global face indices. Both routes use the same rounded faces.
  !! The remaining cells use bounded scalar or vector calculations of the same faces.
  !! work has n+2 values in W/m2 and is scratch storage with no returned value rule.
  subroutine evaluate_range(n, first, last, q, base, out, work, coeff, par, beta, scale, scaled, final)
    integer(c_int), intent(in) :: n, first, last
    real(c_double), intent(in) :: q(0:n + 1), base(0:n + 1), coeff(0:n + 1, 3), par(6)
    real(c_double), intent(inout) :: out(0:n + 1)
    real(c_double), intent(inout) :: work(0:n + 1)
    logical, intent(in) :: final
    real(c_double), intent(in) :: beta, scale
    logical, intent(in) :: scaled
    real(c_double) :: forcing, r, ell, e, east, west
    integer(c_int) :: i
    integer(c_int) :: block_first, j, bulk_end
    if (n == 4096) then
      bulk_end = first + (max(0, last - first + 1)/16)*16 - 1
      if (first <= last) then
        work(0) = coeff(first - 1, 1)*(q(first) - q(first - 1))
      end if
      do block_first = first, bulk_end, 16
!$omp simd
        do j = 0, 15
          work(j + 1) = coeff(block_first + j, 1)*(q(block_first + j + 1) - q(block_first + j))
        end do
!$omp simd
        do j = 0, 15
          i = block_first + j
          forcing = merge(coeff(i, 3), coeff(i, 2), q(i) <= par(6))
          r = forcing - (par(4) + par(5)*q(i))
          if (scaled) then
            ell = r + (work(j + 1) - work(j))*scale
          else
            ell = r + (work(j + 1) - work(j))/scale
          end if
          e = q(i) + beta*ell
          if (final) then
            out(i) = base(i)*0.5_c_double + e*0.5_c_double
          else
            out(i) = e
          end if
        end do
        work(0) = work(16)
      end do
    else
      bulk_end = first + (max(0, last - first + 1)/16)*16 - 1
      if (first <= last) then
        work(first - 1) = coeff(first - 1, 1)*(q(first) - q(first - 1))
      end if
      do block_first = first, bulk_end, 16
!$omp simd
        do j = 0, 15
          work(block_first + j) = coeff(block_first + j, 1)*(q(block_first + j + 1) - q(block_first + j))
        end do
!$omp simd
        do j = 0, 15
          i = block_first + j
          forcing = merge(coeff(i, 3), coeff(i, 2), q(i) <= par(6))
          r = forcing - (par(4) + par(5)*q(i))
          if (scaled) then
            ell = r + (work(i) - work(i - 1))*scale
          else
            ell = r + (work(i) - work(i - 1))/scale
          end if
          e = q(i) + beta*ell
          if (final) then
            out(i) = base(i)*0.5_c_double + e*0.5_c_double
          else
            out(i) = e
          end if
        end do
      end do
    end if
!$omp simd
    do i = bulk_end + 1, last
      east = coeff(i, 1)*(q(i + 1) - q(i))
      west = coeff(i - 1, 1)*(q(i) - q(i - 1))
      forcing = coeff(i, 2)
      if (q(i) <= par(6)) forcing = coeff(i, 3)
      r = forcing - (par(4) + par(5)*q(i))
      if (scaled) then
        ell = r + (east - west)*scale
      else
        ell = r + (east - west)/scale
      end if
      e = q(i) + beta*ell
      if (final) then
        out(i) = base(i)*0.5_c_double + e*0.5_c_double
      else
        out(i) = e
      end if
    end do
  end subroutine

  !> Return the first stage and the complete step through a public C interface.
  !! n is a value argument of type C_INT, with 1 to 65536 interior cells.
  !! q, stage, out and work each have n+2 contiguous C_DOUBLE values, indexed 0 to n+1.
  !! q contains temperatures in degrees Celsius. Only its two pole ghosts change.
  !! stage and out receive temperatures, including both pole ghosts.
  !! coeff has shape (n+2,3) and stores K in W/(m2 K), then W and I in W/m2.
  !! par stores C in J/(m2 K), dt in s, dimensionless delta, A in W/m2,
  !! B in W/(m2 K), and Tf in degrees Celsius, in that order.
  !! coeff and par remain unchanged. work is scratch storage in W/m2.
  !! The caller owns all six disjoint buffers, aligned to at least eight bytes.
  !! No allocation occurs and no pointer survives this call.
  subroutine eb_step(n, q, stage, out, work, coeff, par) bind(C, name='eb_step')
    integer(c_int), value :: n
    real(c_double), intent(inout) :: q(0:n + 1)
    real(c_double), intent(inout) :: stage(0:n + 1), out(0:n + 1)
    real(c_double), intent(inout) :: work(0:n + 1)
    real(c_double), intent(in) :: coeff(0:n + 1, 3), par(6)
    real(c_double) :: beta, scale
    logical :: scaled
    call prepare_time_coefficients(par, beta, scale, scaled)
    call advance_one_step(n, q, stage, out, work, coeff, par, beta, scale, scaled)
  end subroutine

  !> Round dt/C once and select an exact power-of-two spacing factor.
  !! The stored exponent range admits positive normal spacing and a normal inverse.
  !! Other positive spacing values retain the correctly rounded division route.
  subroutine prepare_time_coefficients(par, beta, scale, scaled)
    real(c_double), intent(in) :: par(6)
    real(c_double), intent(out) :: beta, scale
    logical, intent(out) :: scaled
    integer(c_int64_t) :: bits, exponent_bits
    beta = par(2)/par(1)
    bits = transfer(par(3), bits)
    exponent_bits = ibits(bits, 52, 11)
    scaled = iand(bits, int(z'800fffffffffffff', c_int64_t)) == 0_c_int64_t &
             .and. exponent_bits >= 1_c_int64_t .and. exponent_bits <= 2045_c_int64_t
    scale = par(3)
    if (scaled) scale = transfer(ishft(2046_c_int64_t - exponent_bits, 52), scale)
  end subroutine

  !> Advance one step while retaining the complete first stage and final state.
  !! One extra first-stage cell supplies the next neighbour needed by each final range.
  subroutine advance_one_step(n, q, stage, out, work, coeff, par, beta, scale, scaled)
    integer(c_int), intent(in) :: n
    real(c_double), intent(inout) :: q(0:n + 1)
    real(c_double), intent(inout) :: stage(0:n + 1), out(0:n + 1)
    real(c_double), intent(inout) :: work(0:n + 1)
    real(c_double), intent(in) :: coeff(0:n + 1, 3), par(6), beta, scale
    logical, intent(in) :: scaled
    integer(c_int) :: first, last, next
    call copy_pole_ghosts(n, q)
    next = 1
    do first = 1, n, 64
      last = min(n, first + 64 - 1)
      call evaluate_range(n, next, min(n, last + 1), q, q, stage, work, coeff, par, beta, scale, scaled, .false.)
      if (first == 1) stage(0) = stage(1)
      if (last >= n - 1) stage(n + 1) = stage(n)
      call evaluate_range(n, first, last, stage, q, out, work, coeff, par, beta, scale, scaled, .true.)
      next = last + 2
    end do
    call copy_pole_ghosts(n, out)
  end subroutine

  !> Advance an even group using the existing three state arrays and work array.
  !! Each time step has two stages, and each stage needs its immediate neighbours.
  !! Earlier stages therefore finish farther north before a later stage writes there.
  !! A front marks the last completed cell of a stage. The offset keeps every old
  !! neighbour available until its last read, including partial groups at the poles.
  !! The final q and out states and the final stage remain fully observable.
  subroutine advance_step_group(n, q, stage, out, work, coeff, par, beta, scale, scaled, group)
    integer(c_int), intent(in) :: n, group
    real(c_double), intent(inout) :: q(0:n + 1), stage(0:n + 1), out(0:n + 1)
    real(c_double), intent(inout) :: work(0:n + 1)
    real(c_double), intent(in) :: coeff(0:n + 1, 3), par(6), beta, scale
    logical, intent(in) :: scaled
    integer(c_int) :: first, last, k, lo, hi, offset
    call copy_pole_ghosts(n, q)
    do first = 1, n, 256
      last = min(n, first + 256 - 1)
      do k = 1, group
        offset = 2*(group - k)
        lo = 1
        if (first > 1) lo = first + offset + 1
        hi = min(n, last + offset + 1)
        if (mod(k, 2) == 1) then
          call evaluate_range(n, lo, hi, q, q, stage, work, coeff, par, beta, scale, scaled, .false.)
        else
          call evaluate_range(n, lo, hi, out, out, stage, work, coeff, par, beta, scale, scaled, .false.)
        end if
        if (lo <= hi) then
          if (lo == 1) stage(0) = stage(1)
          if (hi == n) stage(n + 1) = stage(n)
        end if
        lo = 1
        if (first > 1) lo = first + offset
        hi = min(n, last + offset)
        if (mod(k, 2) == 1) then
          call evaluate_range(n, lo, hi, stage, q, out, work, coeff, par, beta, scale, scaled, .true.)
          if (lo <= hi) then
            if (lo == 1) out(0) = out(1)
            if (hi == n) out(n + 1) = out(n)
          end if
        else
          call evaluate_range(n, lo, hi, stage, out, q, work, coeff, par, beta, scale, scaled, .true.)
          if (lo <= hi) then
            if (lo == 1) q(0) = q(1)
            if (hi == n) q(n + 1) = q(n)
          end if
        end if
      end do
    end do
  end subroutine

  !> Run the requested number of complete time steps through a public C interface.
  !! Shapes, units, ownership and disjoint storage follow eb_step.
  !! nsteps is a C_INT value from 0 to 1000000. Zero leaves every buffer unchanged.
  !! For a positive odd count, out is final and q is the preceding state.
  !! For a positive even count, q is final and out is the preceding state.
  !! stage always holds the final step's first stage, with copied pole ghosts.
  !! All mutable arrays use INOUT so a zero count preserves their Fortran definition.
  subroutine eb_run(n, q, stage, out, work, coeff, par, nsteps) bind(C, name='eb_run')
    integer(c_int), value :: n, nsteps
    real(c_double), intent(inout) :: q(0:n + 1), out(0:n + 1)
    real(c_double), intent(inout) :: stage(0:n + 1), work(0:n + 1)
    real(c_double), intent(in) :: coeff(0:n + 1, 3), par(6)
    integer(c_int) :: k
    real(c_double) :: beta, scale
    logical :: scaled
    if (nsteps == 0) return
    call prepare_time_coefficients(par, beta, scale, scaled)
    k = 0
    do while (k + 8 <= nsteps)
      call advance_step_group(n, q, stage, out, work, coeff, par, beta, scale, scaled, 8)
      k = k + 8
    end do
    do while (k < nsteps)
      call advance_one_step(n, q, stage, out, work, coeff, par, beta, scale, scaled)
      k = k + 1
      if (k < nsteps) then
        call advance_one_step(n, out, stage, q, work, coeff, par, beta, scale, scaled)
        k = k + 1
      end if
    end do
  end subroutine
end module
