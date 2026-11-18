!> Restore exact input words outside the measured solver call.
!! Each worker writes the global cells that it owns in the numerical coordinator.
!! Fresh anonymous pages then belong to the memory domain of that worker.
module esm_tile_setup
  use, intrinsic :: iso_c_binding, only: c_int, c_int64_t, c_double
  use omp_lib
  implicit none
  private
  public :: cpu_restore_sw, cpu_restore_eb, cpu_touch_workspace
  integer(c_int64_t), parameter :: nan_bits = int(z'7ff8000000000000', c_int64_t)
  interface
    function cpu_getcpu() bind(C) result(value)
      import c_int
      integer(c_int) :: value
    end function
  end interface
contains
  !> Copy one frozen shallow-water seed and clear the three padded states.
  !! seed has shape(nx,ny,3): depth [m] and momenta [m2/s].
  !! q/stage/out have shape(nx+2,ny+2,3), including one ghost cell per side.
  !! The caller owns disjoint arrays. Only q/stage/out and the output records mutate.
  !! cpus has px*py elements. actual is the observed worker count.
  !! Return 0 for success, -1 for invalid sizes, or -2 for a shortened team.
  integer(c_int) function cpu_restore_sw(nx, ny, px, py, seed, q, stage, out, cpus, actual) bind(C)
    integer(c_int), value :: nx, ny, px, py
    real(c_double), intent(in) :: seed(nx, ny, 3)
    real(c_double), intent(out) :: q(0:nx + 1, 0:ny + 1, 3), stage(0:nx + 1, 0:ny + 1, 3), out(0:nx + 1, 0:ny + 1, 3)
    integer(c_int), intent(out) :: cpus(px*py), actual
    integer :: threads, tid, ix, iy, first_x, last_x, first_y, last_y, i, j, field
    real(c_double) :: empty
    cpu_restore_sw = -1
    actual = 0
    if (nx < 1 .or. ny < 1 .or. px < 1 .or. py < 1 .or. px > nx .or. py > ny) return
    if (int(px, c_int64_t)*py > 288) return
    threads = px*py
    cpus = -1
    empty = transfer(nan_bits, 0.0_c_double)
!$omp parallel num_threads(threads) default(shared) &
!$omp private(tid,ix,iy,first_x,last_x,first_y,last_y,i,j,field)
    tid = omp_get_thread_num()
!$omp single
    actual = omp_get_num_threads()
!$omp end single
    cpus(tid + 1) = cpu_getcpu()
    if (actual == threads) then
      ix = modulo(tid, px)
      iy = tid/px
      first_x = ix*nx/px + 1
      last_x = (ix + 1)*nx/px
      first_y = iy*ny/py + 1
      last_y = (iy + 1)*ny/py
      if (ix == 0) first_x = 0
      if (ix == px - 1) last_x = nx + 1
      if (iy == 0) first_y = 0
      if (iy == py - 1) last_y = ny + 1
      do field = 1, 3
        do j = first_y, last_y
          do i = first_x, last_x
            stage(i, j, field) = empty
            out(i, j, field) = empty
            if (i >= 1 .and. i <= nx .and. j >= 1 .and. j <= ny) then
              q(i, j, field) = seed(i, j, field)
            else
              q(i, j, field) = empty
            end if
          end do
        end do
      end do
    end if
!$omp end parallel
    cpu_restore_sw = 0
    if (actual /= threads) cpu_restore_sw = -2
  end function

  !> Restore one frozen temperature seed and its latitude coefficients.
  !! seed has n Celsius values. frozen_coeff and coeff have shape(n+2,3),
  !! with the unchanged K, W and I fields in the accepted coefficient units.
  !! q/stage/out have n+2 Celsius values, including two pole ghosts.
  !! cpus has threads elements. Only destination arrays and records mutate.
  integer(c_int) function cpu_restore_eb(n, threads, seed, frozen_coeff, q, stage, out, coeff, cpus, actual) bind(C)
    integer(c_int), value :: n, threads
    real(c_double), intent(in) :: seed(n), frozen_coeff(0:n + 1, 3)
    real(c_double), intent(out) :: q(0:n + 1), stage(0:n + 1), out(0:n + 1), coeff(0:n + 1, 3)
    integer(c_int), intent(out) :: cpus(threads), actual
    integer :: tid, first, last, i, field
    real(c_double) :: empty
    cpu_restore_eb = -1
    actual = 0
    if (n < 1 .or. threads < 1 .or. threads > min(288, n)) return
    cpus = -1
    empty = transfer(nan_bits, 0.0_c_double)
!$omp parallel num_threads(threads) default(shared) private(tid,first,last,i,field)
    tid = omp_get_thread_num()
!$omp single
    actual = omp_get_num_threads()
!$omp end single
    cpus(tid + 1) = cpu_getcpu()
    if (actual == threads) then
      first = tid*n/threads + 1
      last = (tid + 1)*n/threads
      if (tid == 0) first = 0
      if (tid == threads - 1) last = n + 1
      do i = first, last
        stage(i) = empty
        out(i) = empty
        if (i >= 1 .and. i <= n) then
          q(i) = seed(i)
        else
          q(i) = empty
        end if
      end do
      do field = 1, 3
        coeff(first:last, field) = frozen_coeff(first:last, field)
      end do
    end if
!$omp end parallel
    cpu_restore_eb = 0
    if (actual /= threads) cpu_restore_eb = -2
  end function

  !> First-touch each worker's disjoint private workspace outside timing.
  !! workspace contains threads*stride FP64 scratch values with no physical units.
  !! stride is the capacity per worker, in values. cpus has threads elements.
  integer(c_int) function cpu_touch_workspace(threads, stride, workspace, cpus, actual) bind(C)
    integer(c_int), value :: threads
    integer(c_int64_t), value :: stride
    real(c_double), intent(out) :: workspace(*)
    integer(c_int), intent(out) :: cpus(threads), actual
    integer :: tid
    integer(c_int64_t) :: first, last
    real(c_double) :: empty
    cpu_touch_workspace = -1
    actual = 0
    if (threads < 1 .or. threads > 288 .or. stride < 1) return
    cpus = -1
    empty = transfer(nan_bits, 0.0_c_double)
!$omp parallel num_threads(threads) default(shared) private(tid,first,last)
    tid = omp_get_thread_num()
!$omp single
    actual = omp_get_num_threads()
!$omp end single
    cpus(tid + 1) = cpu_getcpu()
    if (actual == threads) then
      first = int(tid, c_int64_t)*stride + 1
      last = first + stride - 1
      workspace(first:last) = empty
    end if
!$omp end parallel
    cpu_touch_workspace = 0
    if (actual /= threads) cpu_touch_workspace = -2
  end function
end module
