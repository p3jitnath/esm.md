!> Advance the periodic shallow-water equations with ordered binary64 (64-bit floating-point) arithmetic.
!! Physics input is formulations/sw/shallow_water.md revision 1.0.
!! The frozen Rusanov and SSPRK2 specification is in
!! formulations/sw/shallow_water_specification.md. The compiler creates the
!! machine instructions from this portable Fortran source.
!! State component 1 is depth in m. Components 2 and 3 are depth-weighted
!! x and y velocities in m²/s. The first array index is x and is contiguous.
module shallow_water
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_int64_t, c_funptr, c_f_procpointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_all, &
                                                                              ieee_get_status, ieee_set_status, ieee_get_flag, &
                                                                              ieee_set_flag, ieee_support_flag
  use omp_lib, only: omp_get_thread_num, omp_get_num_threads
  implicit none
  private
  public :: sw_step, sw_run, sw_tiles_values, sw_run_tiles
  abstract interface
    subroutine sw_kernel(nx, ny, q, stage, out, work, par, count) bind(C)
      import c_int, c_double
      integer(c_int), value :: nx, ny, count
      real(c_double) :: q(0:nx + 1, 0:ny + 1, 3), stage(0:nx + 1, 0:ny + 1, 3), out(0:nx + 1, 0:ny + 1, 3), work(0:nx + 1, &
                                                                                                                 0:ny + 1, 5)
      real(c_double), intent(in) :: par(4)
    end subroutine
  end interface
contains
  !> Copy periodic faces and corners while preserving the interior.
  !! q has shape (nx+2,ny+2,3) with component units given above.
  !! Only its halo, the copied boundary cells, changes.
  subroutine halo(nx, ny, q)
    integer(c_int), intent(in) :: nx, ny
    real(c_double), intent(inout) :: q(0:nx + 1, 0:ny + 1, 3)
    integer(c_int) :: a, i, j
    do a = 1, 3
      do j = 1, ny
        q(0, j, a) = q(nx, j, a)
        q(nx + 1, j, a) = q(1, j, a)
      end do
!$omp simd
      do i = 0, nx + 1
        q(i, 0, a) = q(i, ny, a)
        q(i, ny + 1, a) = q(i, 1, a)
      end do
    end do
  end subroutine

  !> Evaluate D03 for the initial two rows in compact scratch storage.
  !! q is read only. work has shape (nx+2,5,3), with the last index starting
  !! at zero. Fields 1 to 3 are momentum fluxes in m³/s², and fields
  !! 4 and 5 are wave-speed bounds in m/s. Only selected rows change.
  subroutine prepare(nx, ny, q, work, g, firstrow, lastrow)
    integer(c_int), intent(in) :: nx, ny, firstrow, lastrow
    real(c_double), intent(in) :: q(0:nx + 1, 0:ny + 1, 3), g
    real(c_double), intent(inout) :: work(0:nx + 1, 5, 0:2)
    real(c_double) :: h, mx, my, u, v, z, c, p
    integer(c_int) :: i, j
    do j = firstrow, lastrow
!$omp simd
      do i = 0, nx + 1
        h = q(i, j, 1)
        mx = q(i, j, 2)
        my = q(i, j, 3)
        u = mx/h
        v = my/h
        z = g*h
        c = sqrt(z)
        p = (z*h)*0.5_c_double
        work(i, 1, j) = mx*u + p
        work(i, 2, j) = mx*v
        work(i, 3, j) = my*v + p
        work(i, 4, j) = abs(u) + c
        work(i, 5, j) = abs(v) + c
      end do
    end do
  end subroutine

  !> Return one ordered D04 face flux without changing any argument.
  !! ql and qr have the selected state component's units. fl and fr have
  !! its flux units, and halfalpha is half the speed bound in m/s.
  !! The result has the same units as fl and fr.
  pure real(c_double) function face(ql, qr, fl, fr, halfalpha)
    real(c_double), intent(in) :: ql, qr, fl, fr, halfalpha
    face = (fl + fr)*0.5_c_double - halfalpha*(qr - ql)
  end function

  !> Return the ordered divergence and time update for one component.
  !! The face arguments have flux units. qc and base have state units,
  !! and dt is in s. The scales contain spacing in m or inverse spacing
  !! in 1/m, as selected by scaled. No argument changes.
  pure real(c_double) function cell(east, west, north, south, qc, base, xscale, yscale, dt, final, scaled)
    real(c_double), intent(in) :: east, west, north, south, qc, base, xscale, yscale, dt
    logical, intent(in) :: final, scaled
    real(c_double) :: dx, dy, ell, e
    if (scaled) then
      dx = (east - west)*xscale
      dy = (north - south)*yscale
    else
      dx = (east - west)/xscale
      dy = (north - south)/yscale
    end if
    ell = -(dx + dy)
    e = qc + dt*ell
    if (final) then
      cell = base*0.5_c_double + e*0.5_c_double
    else
      cell = e
    end if
  end function

  !> Retain two point rows and one north-face row in caller-owned scratch.
  !! Each interior output follows D03 and D04. The private view uses 15P
  !! values, where P=nx+2. It fits the public 5P(ny+2) values for every
  !! supported ny. Only interior output cells change here.
  !> Advance row j through disjoint current and next point-row views.
  !! current and next have shape (nx+2,5) and the point units given above.
  !! current is read only, while next is fully replaced. faces has shape
  !! (nx+2,3) and stores one north-face flux per component. Its interior
  !! changes after the previous face has been read. Only out's row j changes.
  !! q, base and par are read only. The two point rows and faces are disjoint.
  subroutine row_kernel(nx, ny, j, q, base, out, current, next, faces, par, final, scaled, xscale, yscale)
    integer(c_int), intent(in) :: nx, ny, j
    real(c_double), intent(in) :: q(0:nx + 1, 0:ny + 1, 3), base(0:nx + 1, 0:ny + 1, 3), par(4), xscale, yscale
    real(c_double), intent(in) :: current(0:nx + 1, 5)
    real(c_double), intent(out) :: next(0:nx + 1, 5)
    real(c_double), intent(inout) :: out(0:nx + 1, 0:ny + 1, 3), faces(0:nx + 1, 3)
    logical, intent(in) :: final, scaled
    real(c_double) :: aw, ae, an, east, west, north, south, h, mx, my, u, v, z, c, p, ax, ay, cross, sxn, syn
    integer(c_int) :: i, a
!$omp simd
    do i = 1, nx
      h = q(i, j + 1, 1)
      mx = q(i, j + 1, 2)
      my = q(i, j + 1, 3)
      u = mx/h
      v = my/h
      z = par(1)*h
      c = sqrt(z)
      p = (z*h)*0.5_c_double
      ax = mx*u + p
      cross = mx*v
      ay = my*v + p
      sxn = abs(u) + c
      syn = abs(v) + c
      next(i, 1) = ax
      next(i, 2) = cross
      next(i, 3) = ay
      next(i, 4) = sxn
      next(i, 5) = syn
      ae = max(current(i, 4), current(i + 1, 4))*0.5_c_double
      aw = max(current(i - 1, 4), current(i, 4))*0.5_c_double
      an = max(current(i, 5), syn)*0.5_c_double
      east = face(q(i, j, 1), q(i + 1, j, 1), q(i, j, 2), q(i + 1, j, 2), ae)
      west = face(q(i - 1, j, 1), q(i, j, 1), q(i - 1, j, 2), q(i, j, 2), aw)
      north = face(q(i, j, 1), h, q(i, j, 3), my, an)
      south = faces(i, 1)
      faces(i, 1) = north
      out(i, j, 1) = cell(east, west, north, south, q(i, j, 1), base(i, j, 1), xscale, yscale, par(4), final, scaled)
      east = face(q(i, j, 2), q(i + 1, j, 2), current(i, 1), current(i + 1, 1), ae)
      west = face(q(i - 1, j, 2), q(i, j, 2), current(i - 1, 1), current(i, 1), aw)
      north = face(q(i, j, 2), mx, current(i, 2), cross, an)
      south = faces(i, 2)
      faces(i, 2) = north
      out(i, j, 2) = cell(east, west, north, south, q(i, j, 2), base(i, j, 2), xscale, yscale, par(4), final, scaled)
      east = face(q(i, j, 3), q(i + 1, j, 3), current(i, 2), current(i + 1, 2), ae)
      west = face(q(i - 1, j, 3), q(i, j, 3), current(i - 1, 2), current(i, 2), aw)
      north = face(q(i, j, 3), my, current(i, 3), ay, an)
      south = faces(i, 3)
      faces(i, 3) = north
      out(i, j, 3) = cell(east, west, north, south, q(i, j, 3), base(i, j, 3), xscale, yscale, par(4), final, scaled)
    end do
    do a = 1, 5
      next(0, a) = next(nx, a)
      next(nx + 1, a) = next(1, a)
    end do
  end subroutine

  subroutine update(nx, ny, q, base, out, work, par, final)
    integer(c_int), intent(in) :: nx, ny
    real(c_double), intent(in) :: q(0:nx + 1, 0:ny + 1, 3), base(0:nx + 1, 0:ny + 1, 3), par(4)
    real(c_double), intent(inout) :: work(0:nx + 1, 5, 0:2)
    real(c_double), intent(inout) :: out(0:nx + 1, 0:ny + 1, 3)
    logical, intent(in) :: final
    real(c_double) :: ass, xscale, yscale
    logical :: scaled
    integer(c_int) :: i, j, r, rn
    scaled = fraction(par(2)) == 0.5_c_double .and. fraction(par(3)) == 0.5_c_double .and. &
             par(2) >= tiny(par(2)) .and. par(3) >= tiny(par(3)) .and. &
             par(2) <= 1.0_c_double/tiny(par(2)) .and. par(3) <= 1.0_c_double/tiny(par(3))
    xscale = par(2)
    yscale = par(3)
    if (scaled) then
      xscale = 1.0_c_double/par(2)
      yscale = 1.0_c_double/par(3)
    end if
    call prepare(nx, ny, q, work, par(1), 0, 1)
!$omp simd
    do i = 1, nx
      ass = max(work(i, 5, 0), work(i, 5, 1))*0.5_c_double
      work(i, 1, 2) = face(q(i, 0, 1), q(i, 1, 1), q(i, 0, 3), q(i, 1, 3), ass)
      work(i, 2, 2) = face(q(i, 0, 2), q(i, 1, 2), work(i, 2, 0), work(i, 2, 1), ass)
      work(i, 3, 2) = face(q(i, 0, 3), q(i, 1, 3), work(i, 3, 0), work(i, 3, 1), ass)
    end do
    r = 1
    rn = 0
    do j = 1, ny
      call row_kernel(nx, ny, j, q, base, out, work(:, :, r), work(:, :, rn), work(:, 1:3, 2), par, &
                      final, scaled, xscale, yscale)
      rn = r
      r = 1 - r
    end do
  end subroutine

  !> Compute a complete step from an input whose periodic halo is ready.
  !! The state and parameter units follow the public sw_step interface.
  !! stage and out are fully replaced, and work is reusable scratch.
  subroutine complete_step(nx, ny, q, stage, out, work, par)
    integer(c_int), intent(in) :: nx, ny
    real(c_double), intent(inout) :: q(0:nx + 1, 0:ny + 1, 3)
    real(c_double), intent(out) :: stage(0:nx + 1, 0:ny + 1, 3), out(0:nx + 1, 0:ny + 1, 3)
    real(c_double), intent(out) :: work(0:nx + 1, 0:ny + 1, 5)
    real(c_double), intent(in) :: par(4)
    call update(nx, ny, q, q, stage, work, par, .false.)
    call halo(nx, ny, stage)
    call update(nx, ny, stage, q, out, work, par, .true.)
    call halo(nx, ny, out)
  end subroutine

  !> Return the complete first stage and final step under T01 and BC01.
  !! nx and ny are interior cell counts from 1 to 4096. q, stage and out
  !! have shape (nx+2,ny+2,3) and the state units defined above. q's interior
  !! is preserved, while its halo may change. stage and out are fully written.
  !! work has shape (nx+2,ny+2,5), with unspecified contents on return.
  !! par has four read-only values, g in m/s², dx and dy in m, and dt in s.
  !! The caller provides arrays that do not overlap, aligned to at least 8 bytes.
  !! The caller retains ownership. No storage is retained after the call.
  subroutine sw_step(nx, ny, q, stage, out, work, par) bind(C, name='sw_step')
    integer(c_int), value :: nx, ny
    real(c_double), intent(inout) :: q(0:nx + 1, 0:ny + 1, 3)
    real(c_double), intent(out) :: stage(0:nx + 1, 0:ny + 1, 3), out(0:nx + 1, 0:ny + 1, 3)
    real(c_double), intent(out) :: work(0:nx + 1, 0:ny + 1, 5)
    real(c_double), intent(in) :: par(4)
    call halo(nx, ny, q)
    call complete_step(nx, ny, q, stage, out, work, par)
  end subroutine

  !> Run nsteps complete updates with alternating caller-owned state buffers.
  !! Shapes, units, bounds, ownership and alignment follow sw_step. nsteps
  !! is from 0 to 1000000. Both q and out may change. The final state is out
  !! after an odd count and q after an even count. stage holds the last first
  !! stage. All buffers remain unchanged when nsteps is zero. A completed
  !! output already has the periodic halo required by the next step.
  subroutine sw_run(nx, ny, q, stage, out, work, par, nsteps) bind(C, name='sw_run')
    integer(c_int), value :: nx, ny, nsteps
    real(c_double), intent(inout) :: q(0:nx + 1, 0:ny + 1, 3), out(0:nx + 1, 0:ny + 1, 3)
    real(c_double), intent(inout) :: stage(0:nx + 1, 0:ny + 1, 3), work(0:nx + 1, 0:ny + 1, 5)
    real(c_double), intent(in) :: par(4)
    integer(c_int) :: n
    if (nsteps > 0) call halo(nx, ny, q)
    do n = 1, nsteps, 2
      call complete_step(nx, ny, q, stage, out, work, par)
      if (n < nsteps) call complete_step(nx, ny, out, stage, q, work, par)
    end do
  end subroutine

  !> Return the parallel scratch size as a binary64 element count, or -1.
  !! nx,ny are C_INT values from 1 to 4096. Positive px,py do not exceed
  !! their corresponding dimensions, and px*py is at most 288. batch is 1 to 32.
  !! Expanded local dimensions also remain at most 4096.
  !! The C_INT64_T result counts C_DOUBLE elements rather than bytes.
  !! It is -1 when these size rules fail. No array is read or changed.
  !! Scratch holds private state and flux values without a returned rule.
  integer(c_int64_t) function sw_tiles_values(nx, ny, px, py, batch) bind(C)
    integer(c_int), value :: nx, ny, px, py, batch
    integer(c_int64_t) :: mx, my
    sw_tiles_values = -1
    if (nx < 1 .or. nx > 4096 .or. ny < 1 .or. ny > 4096) return
    if (px < 1 .or. px > nx .or. py < 1 .or. py > ny) return
    if (int(px, c_int64_t)*py > 288 .or. batch < 1 .or. batch > 32) return
    mx = (nx + px - 1)/px
    my = (ny + py - 1)/py
    if (px > 1) mx = mx + 4*batch
    if (py > 1) my = my + 4*batch
    if (mx > 4096 .or. my > 4096) return
    sw_tiles_values = int(px, c_int64_t)*py*14*(((mx + 2)*(my + 2) + 8191)/8192)*8192
    if (px*py == 1) sw_tiles_values = 5*(mx + 2)*(my + 2)
  end function
  !> Advance one global domain through complete spatially shared time steps.
  !! kernel is a nonnull C function pointer for a complete sw_run-compatible
  !! entry when count is positive. Normal use selects this module's sw_run.
  !! count is a C_INT value from 0 to 1000000.
  !! nx,ny,px,py,batch follow sw_tiles_values. Each of px*py workers owns a
  !! nonempty spatial tile. q,stage,out have shape (nx+2,ny+2,3). Depth is in m,
  !! and the two momenta are in m2/s. Unchanged par(4) stores g [m/s2],
  !! dx [m], dy [m] and dt [s]. Private halos cover two cells per complete step
  !! on each partitioned side. All three returned states have complete ghosts.
  !! q,stage,out and workspace are disjoint caller-owned C_DOUBLE arrays,
  !! aligned to at least 8 bytes. workspace_values is a C_INT64_T element count
  !! covering sw_tiles_values for a positive count. Scratch contents are unspecified.
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
  integer(c_int) function sw_run_tiles(kernel, nx, ny, q, stage, out, par, count, &
                                       px, py, batch, workspace, workspace_values) bind(C)
    type(c_funptr), value :: kernel
    integer(c_int), value :: nx, ny, count, px, py, batch
    integer(c_int64_t), value :: workspace_values
    real(c_double), intent(inout), target :: q(0:nx + 1, 0:ny + 1, 3), stage(0:nx + 1, 0:ny + 1, 3), out(0:nx + 1, 0:ny + 1, 3)
    real(c_double), intent(in) :: par(4)
    real(c_double), intent(inout), target :: workspace(*)
    procedure(sw_kernel), pointer :: run
    real(c_double), pointer, contiguous :: lq(:, :, :), ls(:, :, :), lo(:, :, :), lw(:, :, :)
    real(c_double), pointer, contiguous :: source(:, :, :), other(:, :, :)
    integer(c_int64_t) :: needed, stride, capacity, offset, actual_size
    type(ieee_status_type) :: caller_status, worker_status
    logical :: supported(size(ieee_all)), incoming(size(ieee_all))
    logical :: flags(size(ieee_all)), observed(size(ieee_all))
    integer :: flag_index
    integer :: threads, actual_threads, tid, ix, iy, x0, y0, ow, oh, hx, hy, mx, my, done, k, a, i, j, gy, first, cursor, length
    sw_run_tiles = -1
    needed = sw_tiles_values(nx, ny, px, py, batch)
    if (needed < 0 .or. count < 0 .or. count > 1000000) return
    if (count == 0) then
      sw_run_tiles = 0
      return
    end if
    if (workspace_values < needed) return
    call c_f_procpointer(kernel, run)
    threads = px*py
    if (threads == 1) then
      lw(0:nx + 1, 0:ny + 1, 1:5) => workspace(1:needed)
      call run(nx, ny, q, stage, out, lw, par, count)
      sw_run_tiles = 0
      return
    end if
    capacity = needed/(threads*14)
    stride = 14*capacity
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
    actual_threads = 0
    flags = incoming
!$omp parallel num_threads(threads) default(shared) &
!$omp private(tid,ix,iy,x0,y0,ow,oh,hx,hy,mx,my,done,k,a,i,j,gy,first,cursor,length,offset,actual_size) &
!$omp private(lq,ls,lo,lw,source,other,worker_status,observed,flag_index) reduction(.or.:flags)
    tid = omp_get_thread_num()
!$omp single
    actual_threads = omp_get_num_threads()
!$omp end single
    call ieee_get_status(worker_status)
    call ieee_set_status(caller_status)
    if (actual_threads == threads) then
      ix = modulo(tid, px)
      iy = tid/px
      x0 = ix*nx/px
      y0 = iy*ny/py
      ow = (ix + 1)*nx/px - x0
      oh = (iy + 1)*ny/py - y0
      offset = int(tid, c_int64_t)*stride
      do done = 0, count - 1, batch
        k = min(batch, count - done)
        hx = 0
        hy = 0
        if (px > 1) hx = 2*k
        if (py > 1) hy = 2*k
        mx = ow + 2*hx
        my = oh + 2*hy
        actual_size = int(mx + 2, c_int64_t)*(my + 2)
        lq(0:mx + 1, 0:my + 1, 1:3) => workspace(offset + 1:offset + 3*actual_size)
        ls(0:mx + 1, 0:my + 1, 1:3) => workspace(offset + 3*capacity + 1:offset + 3*capacity + 3*actual_size)
        lo(0:mx + 1, 0:my + 1, 1:3) => workspace(offset + 6*capacity + 1:offset + 6*capacity + 3*actual_size)
        lw(0:mx + 1, 0:my + 1, 1:5) => workspace(offset + 9*capacity + 1:offset + 9*capacity + 5*actual_size)
        if (modulo(done/batch, 2) == 0) then
          source => q
          other => out
        else
          source => out
          other => q
        end if
        first = modulo(x0 - hx, nx) + 1
        do a = 1, 3
          do j = 1, my
            gy = modulo(y0 - hy + j - 1, ny) + 1
            length = min(mx, nx - first + 1)
            lq(1:length, j, a) = source(first:first + length - 1, gy, a)
            cursor = length + 1
            do while (cursor <= mx)
              length = min(nx, mx - cursor + 1)
              lq(cursor:cursor + length - 1, j, a) = source(1:length, gy, a)
              cursor = cursor + length
            end do
          end do
        end do
        call run(mx, my, lq, ls, lo, lw, par, k)
        if (done + k == count) then
          ! Only the returned group replaces both public states and stage.
!$omp barrier
          if (modulo(count, 2) == modulo(k, 2)) then
            call sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, q, lq)
            call sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, out, lo)
          else
            call sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, q, lo)
            call sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, out, lq)
          end if
          call sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, stage, ls)
        else
          ! The gather source stays unchanged until every owner finishes.
          if (modulo(k, 2) == 0) then
            call sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, other, lq)
          else
            call sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, other, lo)
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
    sw_run_tiles = 0
    if (actual_threads /= threads) sw_run_tiles = -2
  end function
  !> Copy one owned state and its disjoint periodic ghosts from protected scratch.
  !! target has shape (nx+2,ny+2,3); local has shape (mx+2,my+2,3).
  !! Both store the original field units. Their caller-owned storage is disjoint.
  subroutine sw_publish_owned(nx, ny, mx, my, x0, y0, ow, oh, hx, hy, target, local)
    integer, intent(in) :: nx, ny, mx, my, x0, y0, ow, oh, hx, hy
    real(c_double), intent(inout) :: target(0:nx + 1, 0:ny + 1, 3)
    real(c_double), intent(in) :: local(0:mx + 1, 0:my + 1, 3)
    integer :: a, i, j
    target(x0 + 1:x0 + ow, y0 + 1:y0 + oh, :) = local(hx + 1:hx + ow, hy + 1:hy + oh, :)
    ! Each source-edge owner also writes its opposite periodic ghost.
    do a = 1, 3
      if (x0 == 0) then
        do j = 1, oh
          target(nx + 1, y0 + j, a) = local(hx + 1, hy + j, a)
        end do
      end if
      if (x0 + ow == nx) then
        do j = 1, oh
          target(0, y0 + j, a) = local(hx + ow, hy + j, a)
        end do
      end if
      if (y0 == 0) then
        do i = 1, ow
          target(x0 + i, ny + 1, a) = local(hx + i, hy + 1, a)
        end do
      end if
      if (y0 + oh == ny) then
        do i = 1, ow
          target(x0 + i, 0, a) = local(hx + i, hy + oh, a)
        end do
      end if
      if (x0 == 0 .and. y0 == 0) then
        target(nx + 1, ny + 1, a) = local(hx + 1, hy + 1, a)
      end if
      if (x0 + ow == nx .and. y0 == 0) then
        target(0, ny + 1, a) = local(hx + ow, hy + 1, a)
      end if
      if (x0 == 0 .and. y0 + oh == ny) then
        target(nx + 1, 0, a) = local(hx + 1, hy + oh, a)
      end if
      if (x0 + ow == nx .and. y0 + oh == ny) then
        target(0, 0, a) = local(hx + ow, hy + oh, a)
      end if
    end do
  end subroutine
end module
