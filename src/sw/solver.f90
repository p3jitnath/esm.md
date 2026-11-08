!> Advance the periodic shallow-water equations with ordered binary64 (64-bit floating-point) arithmetic.
!! Physics input is formulations/sw/dam_break.md revision 1.0.
!! The frozen Rusanov and SSPRK2 contract is in
!! skills/md2asm/references/2d_rusanov_ssprk2.md. The compiler creates the
!! machine instructions from this portable Fortran source.
!! State component 1 is depth in m. Components 2 and 3 are depth-weighted
!! x and y velocities in m²/s. The first array index is x and is contiguous.
module shallow_water
  use, intrinsic :: iso_c_binding, only: c_int, c_double
  implicit none
  private
  public :: sw_step, sw_run
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
end module
