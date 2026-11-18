!> Advance the energy-balance model with the frozen two-stage update.
!! Physics input formulations/ebm/budyko_sellers.md, revision 1.1.
!! The numerical and storage rules are in formulations/ebm/budyko_sellers_specification.md.
!! All calculations use binary64 values. The compiler produces the machine code.
!! The caller supplies round-to-nearest arithmetic with gradual underflow.
module esm_energy_balance
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_int64_t, c_funptr, c_f_procpointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_all, &
                                                                              ieee_get_status, ieee_set_status, ieee_get_flag, &
                                                                              ieee_set_flag, ieee_support_flag
  use omp_lib, only: omp_get_thread_num, omp_get_num_threads
  implicit none
  private
  public :: eb_step, eb_run, eb_tiles_values, eb_run_tiles
  abstract interface
    subroutine eb_kernel(n, q, stage, out, work, coeff, par, count) bind(C)
      import c_int, c_double
      integer(c_int), value :: n, count
      real(c_double) :: q(0:n + 1), stage(0:n + 1), out(0:n + 1), work(0:n + 1)
      real(c_double), intent(in) :: coeff(0:n + 1, 3), par(6)
    end subroutine
  end interface
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
  !! Every grid reuses work(0:16) for a complete 16-cell group.
  !! Short ranges use the bounded tail and retain the same rounded faces.
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

  !> Return the parallel scratch size as a binary64 element count, or -1.
  !! n is a C_INT value from 1 to 65536. threads is 1 to min(n,288),
  !! and batch is 1 to 256 complete steps.
  !! The C_INT64_T result counts C_DOUBLE elements rather than bytes.
  !! It is -1 when these size rules fail. No array is read or changed.
  !! Scratch holds private state, fluxes and coefficients without a returned rule.
  integer(c_int64_t) function eb_tiles_values(n, threads, batch) bind(C)
    integer(c_int), value :: n, threads, batch
    integer(c_int64_t) :: m
    eb_tiles_values = -1
    if (n < 1 .or. n > 65536 .or. threads < 1 .or. threads > min(288, n)) return
    if (batch < 1 .or. batch > 256) return
    m = min(int(n, c_int64_t), int((n + threads - 1)/threads, c_int64_t) + 4*batch)
    eb_tiles_values = int(threads, c_int64_t)*7*((m + 2 + 8191)/8192)*8192
    if (threads == 1) eb_tiles_values = n + 2
  end function
  !> Advance one global domain through complete spatially shared time steps.
  !! kernel is a nonnull C function pointer for a complete eb_run-compatible
  !! entry when count is positive. Normal use selects this module's eb_run.
  !! count is a C_INT value from 0 to 1000000.
  !! n,threads,batch follow eb_tiles_values. Each worker owns a nonempty range
  !! of latitude bands. q,stage,out have n+2 Celsius temperatures. Unchanged
  !! coeff has shape (n+2,3), storing K [W/(m2 K)], W [W/m2] and I [W/m2].
  !! Unchanged par(6) stores C [J/(m2 K)], dt [s], dimensionless delta,
  !! A [W/m2], B [W/(m2 K)] and Tf [Celsius], as in eb_step.
  !! Expanded ranges stop at the true poles and retain global coefficient words.
  !! All three returned states have complete pole ghosts.
  !! q,stage,out and workspace are disjoint caller-owned C_DOUBLE arrays,
  !! aligned to at least 8 bytes. workspace_values is a C_INT64_T element count
  !! covering eb_tiles_values for a positive count. Scratch contents are unspecified.
  !! Zero count preserves every array, including ghosts and workspace.
  !! After a positive odd count, out is final and q is the preceding state.
  !! After a positive even count, q is final and out is the preceding state.
  !! stage holds the final step's first stage. No pointer or storage is retained.
  !! The caller supplies nearest rounding, gradual underflow and non-halting
  !! arithmetic. The public status merge covers the five standard IEEE flags.
  !! The C_INT result is 0 on success, -1 for invalid sizes, counts or scratch
  !! capacity, and -2 if the runtime supplies fewer workers than requested.
  !! A rejected worker team changes no state or scratch array. Every numerical
  !! stage, overlap calculation, publication and ghost copy belongs to the solver.
  integer(c_int) function eb_run_tiles(kernel, n, q, stage, out, coeff, par, count, &
                                       threads, batch, workspace, workspace_values) bind(C)
    type(c_funptr), value :: kernel
    integer(c_int), value :: n, count, threads, batch
    integer(c_int64_t), value :: workspace_values
    real(c_double), intent(inout), target :: q(0:n + 1), stage(0:n + 1), out(0:n + 1)
    real(c_double), intent(in) :: coeff(0:n + 1, 3), par(6)
    real(c_double), intent(inout), target :: workspace(*)
    procedure(eb_kernel), pointer :: run
    real(c_double), pointer, contiguous :: lq(:), ls(:), lo(:), lw(:), lc(:, :)
    real(c_double), pointer, contiguous :: source(:), other(:)
    integer(c_int64_t) :: needed, capacity, stride, offset
    type(ieee_status_type) :: caller_status, worker_status
    logical :: supported(size(ieee_all)), incoming(size(ieee_all))
    logical :: flags(size(ieee_all)), observed(size(ieee_all))
    integer :: flag_index
    integer :: actual_threads, tid, first, last, a, b, m, done, k, olda, oldb
    eb_run_tiles = -1
    needed = eb_tiles_values(n, threads, batch)
    if (needed < 0 .or. count < 0 .or. count > 1000000) return
    if (count == 0) then
      eb_run_tiles = 0
      return
    end if
    if (workspace_values < needed) return
    call c_f_procpointer(kernel, run)
    if (threads == 1) then
      lw(0:n + 1) => workspace(1:n + 2)
      call run(n, q, stage, out, lw, coeff, par, count)
      eb_run_tiles = 0
      return
    end if
    capacity = needed/(threads*7)
    stride = 7*capacity
    ! Capture status directly in this procedure. Ordinary helper procedure
    ! boundaries can have their own compiler-managed IEEE flag handling.
    do flag_index = 1, size(ieee_all)
      supported(flag_index) = ieee_support_flag(ieee_all(flag_index), 0.0_c_double)
    end do
    call ieee_get_status(caller_status)
    incoming = .false.
    do flag_index = 1, size(ieee_all)
      if (supported(flag_index)) call ieee_get_flag(ieee_all(flag_index), incoming(flag_index))
    end do
    flags = incoming
    actual_threads = 0
!$omp parallel num_threads(threads) default(shared) &
!$omp private(tid,first,last,a,b,m,done,k,olda,oldb,offset,lq,ls,lo,lw,lc,source,other,worker_status,observed,flag_index) &
!$omp reduction(.or.:flags)
    tid = omp_get_thread_num()
!$omp single
    actual_threads = omp_get_num_threads()
!$omp end single
    call ieee_get_status(worker_status)
    call ieee_set_status(caller_status)
    if (actual_threads == threads) then
      first = tid*n/threads + 1
      last = (tid + 1)*n/threads
      offset = int(tid, c_int64_t)*stride
      olda = -1
      oldb = -1
      do done = 0, count - 1, batch
        k = min(batch, count - done)
        a = max(1, first - 2*k)
        b = min(n, last + 2*k)
        m = b - a + 1
        lq(0:m + 1) => workspace(offset + 1:offset + m + 2)
        ls(0:m + 1) => workspace(offset + capacity + 1:offset + capacity + m + 2)
        lo(0:m + 1) => workspace(offset + 2*capacity + 1:offset + 2*capacity + m + 2)
        lw(0:m + 1) => workspace(offset + 3*capacity + 1:offset + 3*capacity + m + 2)
        lc(0:m + 1, 1:3) => workspace(offset + 4*capacity + 1:offset + 4*capacity + 3*(m + 2))
        if (a /= olda .or. b /= oldb) then
          lc = coeff(a - 1:b + 1, :)
          olda = a
          oldb = b
        end if
        if (modulo(done/batch, 2) == 0) then
          source => q
          other => out
        else
          source => out
          other => q
        end if
        lq(1:m) = source(a:b)
        call run(m, lq, ls, lo, lw, lc, par, k)
        if (done + k == count) then
          ! Only the returned group replaces both public states and stage.
!$omp barrier
          if (modulo(count, 2) == modulo(k, 2)) then
            call eb_publish_owned(n, m, first, last, a, q, lq)
            call eb_publish_owned(n, m, first, last, a, out, lo)
          else
            call eb_publish_owned(n, m, first, last, a, q, lo)
            call eb_publish_owned(n, m, first, last, a, out, lq)
          end if
          call eb_publish_owned(n, m, first, last, a, stage, ls)
        else
          ! The gather source stays unchanged until every owner finishes.
          if (modulo(k, 2) == 0) then
            call eb_publish_owned(n, m, first, last, a, other, lq)
          else
            call eb_publish_owned(n, m, first, last, a, other, lo)
          end if
!$omp barrier
        end if
      end do
    end if
    observed = .false.
    do flag_index = 1, size(ieee_all)
      if (supported(flag_index)) call ieee_get_flag(ieee_all(flag_index), observed(flag_index))
    end do
    flags = flags .or. observed
    call ieee_set_status(worker_status)
!$omp end parallel
    call ieee_set_status(caller_status)
    do flag_index = 1, size(ieee_all)
      if (supported(flag_index)) call ieee_set_flag(ieee_all(flag_index), flags(flag_index))
    end do
    eb_run_tiles = 0
    if (actual_threads /= threads) eb_run_tiles = -2
  end function
  !> Copy one owned temperature range and its disjoint pole ghosts.
  !! target has n+2 Celsius values and local has m+2 Celsius values.
  !! Both arrays are caller-owned and disjoint; a is the local global origin.
  subroutine eb_publish_owned(n, m, first, last, a, target, local)
    integer, intent(in) :: n, m, first, last, a
    real(c_double), intent(inout) :: target(0:n + 1)
    real(c_double), intent(in) :: local(0:m + 1)
    target(first:last) = local(first - a + 1:last - a + 1)
    ! Pole owners publish ghosts from their protected local endpoints.
    if (first == 1) then
      target(0) = local(first - a + 1)
    end if
    if (last == n) then
      target(n + 1) = local(last - a + 1)
    end if
  end subroutine
end module
