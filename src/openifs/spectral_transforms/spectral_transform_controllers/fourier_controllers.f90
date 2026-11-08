!> Complete selected Fourier controllers over borrowed grid fields and native buffers.
module forecast_native_fourier_controllers
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int64_t
use forecast_native_transform_controller_state,only:native_transform_controller_state,serial_transform_ready,ensure_transform_buffer
  use forecast_native_grid_transform_copies, only: trgtol, trltog
  use forecast_native_fourier_metric, only: fsc
  use forecast_native_inverse_fourier_row, only: ftinv
  use md2asm_direct_fourier_analysis, only: analyse_fourier_latitude
  use md2asm_fourier_buffer_packing, only: copy_fourier_input, copy_fourier_output
  implicit none
  private
  public :: ftdir_ctl, ftinv_ctl
  integer(c_int64_t), bind(C, name="md2asm_ftdir_ctl_7358525_count") :: direct_count = 0
  integer(c_int64_t), bind(C, name="md2asm_ftinv_ctl_7358525_count") :: inverse_count = 0
contains
!> Gather grid owners, analyse each latitude, and publish the persistent packed buffer.
!! Counts are dimensionless; arrays retain the physical units of the supplied fields.
  subroutine ftdir_ctl(c, kf_uv_g, kf_scalars_g, kf_gp, kf_fs, kvsetuv, kvsetsc, kptrgp, kvsetsc3a, kvsetsc3b, kvsetsc2, &
                       pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
    type(native_transform_controller_state), intent(inout) :: c
    integer(int32), intent(in) :: kf_uv_g, kf_scalars_g, kf_gp, kf_fs
    integer(int32), optional, intent(in) :: kvsetuv(:), kvsetsc(:), kptrgp(:), kvsetsc3a(:), kvsetsc3b(:), kvsetsc2(:)
    real(real64),optional,target,intent(inout)::pgp(:,:,:),pgpuv(:,:,:,:),pgp3a(:,:,:,:),pgp3b(:,:,:,:),pgp2(:,:,:)
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: zgtf(:, :)
    integer(int32), allocatable, target :: maps(:)
    integer(int32), pointer :: ivsetuv(:), ivsetsc(:), ivset(:)
    integer :: a, j
    status = 2
    if (.not. serial_transform_ready(c)) return
    if (any([kf_uv_g, kf_scalars_g, kf_gp, kf_fs] < 0) .or. any([kf_uv_g, kf_scalars_g, kf_gp, kf_fs] > 136)) return
    allocate (zgtf(kf_fs, 2144), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    allocate (maps(kf_uv_g + kf_scalars_g + kf_gp), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    ivsetuv => maps(1:kf_uv_g)
    ivsetsc => maps(kf_uv_g + 1:kf_uv_g + kf_scalars_g)
    ivset => maps(kf_uv_g + kf_scalars_g + 1:)
    call field_sets(c, .false., ivsetuv, ivsetsc, ivset, status, kvsetuv, kvsetsc, kvsetsc3a, kvsetsc3b, kvsetsc2, pgp3a, pgp3b)
    if (status /= 0) return
    call gstats(158, 0)
    call trgtol(c, zgtf, kf_fs, kf_gp, kf_scalars_g, ivset, kptrgp, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
    if (status /= 0) return
    call gstats(158, 1)
    call gstats(106, 0)
    call ensure_transform_buffer(c%foubuf_in, 2_int64*c%nlengt0b*kf_fs, .false., status)
    if (status /= 0) return
    call gstats(1640, 0)
    do j = 1, 32
      if (kf_fs > 0) then
        call analyse_fourier_latitude(c%layout, kf_fs, int(j, int32), zgtf, status)
        if (status /= 0) return
      end if
      call copy_fourier_output(c%layout, kf_fs, int(j, int32), zgtf, c%foubuf_in, status)
      if (status /= 0) return
    end do
    call gstats(1640, 1); call gstats(106, 1)
    deallocate (maps); deallocate (zgtf)
    direct_count = direct_count + 1
    status = 0
  end subroutine
!> Unpack coefficients, apply the metric, synthesize rows, then scatter to actual owners.
!! Five native views retain their parent column pitch. No descriptor image is constructed.
  subroutine ftinv_ctl(c, kf_uv_g, kf_scalars_g, kf_uv, kf_scalars, kf_scders, kf_gp, kf_fs, kf_out_lt, kvsetuv, kvsetsc, kptrgp, &
                       kvsetsc3a, kvsetsc3b, kvsetsc2, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
    type(native_transform_controller_state), intent(inout) :: c
    integer(int32), intent(in) :: kf_uv_g, kf_scalars_g, kf_uv, kf_scalars, kf_scders, kf_gp, kf_fs, kf_out_lt
    integer(int32), optional, intent(in) :: kvsetuv(:), kvsetsc(:), kptrgp(:), kvsetsc3a(:), kvsetsc3b(:), kvsetsc2(:)
    real(real64),optional,target,intent(inout)::pgp(:,:,:),pgpuv(:,:,:,:),pgp3a(:,:,:,:),pgp3b(:,:,:,:),pgp2(:,:,:)
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: zgtf(:, :), zdum(:, :)
    real(real64), pointer :: zuv(:, :), zscalar(:, :), znsders(:, :), zewders(:, :), zuvders(:, :)
    integer(int32), allocatable, target :: maps(:)
    integer(int32), pointer :: ivsetuv(:), ivsetsc(:), ivset(:)
    integer :: a, j, at, counts(4), k
    status = 2
    if (.not. serial_transform_ready(c) .or. c%luvder) return
    if (any([kf_uv_g, kf_scalars_g, kf_uv, kf_scalars, kf_scders, kf_gp, kf_fs, kf_out_lt] < 0)) return
    if (any([kf_uv_g, kf_scalars_g, kf_uv, kf_scalars, kf_scders, kf_gp, kf_fs, kf_out_lt] > 136)) return
    if (kf_uv_g /= kf_uv .or. kf_scalars_g /= kf_scalars) return
    if (kf_scders /= 0 .and. kf_scders /= kf_scalars) return
    if (kf_fs /= kf_out_lt + kf_scders) return
    if (.not. allocated(c%foubuf)) return
    allocate (zgtf(kf_fs, 2144), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    if (kf_fs > 0) zgtf(1, 1) = 0.0_real64
    allocate (zdum(1, 2144), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    zuv => zdum; zscalar => zdum; znsders => zdum; zewders => zdum; zuvders => zdum
    if (kf_uv > 0 .or. kf_scders > 0) then
      at = 1 + merge(kf_uv, 0, c%lvorgp) + merge(kf_uv, 0, c%ldivgp)
      counts = [2*kf_uv, kf_scalars, kf_scders, kf_scders]
      do k = 1, 4
        if (counts(k) > 0) then
          if (at + counts(k) - 1 > kf_fs) return
          select case (k)
          case (1)
            zuv => zgtf(at:at + counts(k) - 1, :)
          case (2)
            zscalar => zgtf(at:at + counts(k) - 1, :)
          case (3)
            znsders => zgtf(at:at + counts(k) - 1, :)
          case (4)
            zewders => zgtf(at:at + counts(k) - 1, :)
          end select
        end if
        at = at + counts(k)
      end do
    end if
    call gstats(107, 0); call gstats(1639, 0)
    do j = 1, 32
      call copy_fourier_input(c%layout, kf_out_lt, int(j, int32), c%foubuf, zgtf, status)
      if (status /= 0) return
      if (kf_uv > 0 .or. kf_scders > 0) then
        call fsc(c, int(j, int32), kf_uv, kf_scalars, kf_scders, zuv, zscalar, znsders, zewders, zuvders, status)
        if (status /= 0) return
      end if
      if (kf_fs > 0) then
        call ftinv(c%layout, kf_fs, int(j, int32), zgtf, status)
        if (status /= 0) return
      end if
    end do
    call gstats(1639, 1)
    nullify (zuv, zscalar, znsders, zewders, zuvders); deallocate (zdum)
    call gstats(107, 1)
    allocate (maps(kf_uv_g + kf_scalars_g + kf_gp), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    ivsetuv => maps(1:kf_uv_g)
    ivsetsc => maps(kf_uv_g + 1:kf_uv_g + kf_scalars_g)
    ivset => maps(kf_uv_g + kf_scalars_g + 1:)
    call field_sets(c, .true., ivsetuv, ivsetsc, ivset, status, kvsetuv, kvsetsc, kvsetsc3a, kvsetsc3b, kvsetsc2, pgp3a, pgp3b)
    if (status /= 0) return
    call gstats(157, 0)
    call trltog(c, zgtf, kf_fs, kf_gp, kf_scalars_g, ivset, kptrgp, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
    if (status /= 0) return
    call gstats(157, 1)
    deallocate (maps); deallocate (zgtf)
    inverse_count = inverse_count + 1
    status = 0
  end subroutine
!> Build one combined integer owner in exact source wind/scalar/derivative order.
  subroutine field_sets(c, inverse, uv, sc, all, status, kvsetuv, kvsetsc, kvsetsc3a, kvsetsc3b, kvsetsc2, pgp3a, pgp3b)
    type(native_transform_controller_state), intent(in) :: c
    logical, intent(in) :: inverse
    integer(int32), intent(inout) :: uv(:), sc(:), all(:)
    integer(int32), intent(out) :: status
    integer(int32), optional, intent(in) :: kvsetuv(:), kvsetsc(:), kvsetsc3a(:), kvsetsc3b(:), kvsetsc2(:)
    real(real64), optional, intent(in) :: pgp3a(:, :, :, :), pgp3b(:, :, :, :)
    integer :: at, repeat, j
    status = 2; uv = -1; sc = -1
    if (present(kvsetuv)) then
      if (size(kvsetuv) /= size(uv)) return
      uv = kvsetuv
    end if
    if (present(kvsetsc)) then
      if (size(kvsetsc) /= size(sc)) return
      sc = kvsetsc
    else
      at = 0
      if (present(kvsetsc2)) then
        call append_scalar(kvsetsc2)
        if (status /= 0) return
      end if
      if (present(kvsetsc3a)) then
        status = 2
        if (.not. present(pgp3a)) return
        repeat = size(pgp3a, 3)
        if (inverse .and. c%lscders) repeat = repeat/3
        do j = 1, repeat
          call append_scalar(kvsetsc3a)
          if (status /= 0) return
        end do
      end if
      if (present(kvsetsc3b)) then
        status = 2
        if (.not. present(pgp3b)) return
        repeat = size(pgp3b, 3)
        if (inverse .and. c%lscders) repeat = repeat/3
        do j = 1, repeat
          call append_scalar(kvsetsc3b)
          if (status /= 0) return
        end do
      end if
      if (inverse .and. at > 0 .and. at /= size(sc)) then
        status = 2; return
      end if
    end if
    at = 0
    if (inverse .and. c%lvorgp) then
      call append_group(uv)
      if (status /= 0) return
    end if
    if (inverse .and. c%ldivgp) then
      call append_group(uv)
      if (status /= 0) return
    end if
    call append_group(uv)
    if (status /= 0) return
    call append_group(uv)
    if (status /= 0) return
    call append_group(sc)
    if (status /= 0) return
    if (inverse .and. c%lscders) then
      call append_group(sc)
      if (status /= 0) return
    end if
    if (inverse .and. c%luvder) then
      call append_group(uv)
      if (status /= 0) return
      call append_group(uv)
      if (status /= 0) return
    end if
    if (inverse .and. c%lscders) then
      call append_group(sc)
      if (status /= 0) return
    end if
    if (at /= size(all)) then
      status = 2; return
    end if
    status = 0
  contains
    subroutine append_scalar(x)
      integer(int32), intent(in) :: x(:)
      status = 2
      if (size(x) > 136 .or. at + size(x) > size(sc)) return
      sc(at + 1:at + size(x)) = x
      at = at + size(x); status = 0
    end subroutine
    subroutine append_group(x)
      integer(int32), intent(in) :: x(:)
      status = 2
      if (at + size(x) > size(all)) return
      all(at + 1:at + size(x)) = x
      at = at + size(x); status = 0
    end subroutine
  end subroutine
end module
