!> Complete source-order Legendre controllers with native persistent storage.
module forecast_native_legendre_controllers
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_int64_t
  use forecast_native_transform_controller_state, only: native_transform_controller_state, ensure_transform_buffer
  use forecast_native_legendre_controller_support, only: copy_legendre_partition, analyse_spectral_order
  use md2asm_inverse_spectral_transform, only: reconstruct_spectral_order
  implicit none
  private
  public :: ltinv_ctl, ltdir_ctl, legendre_controllers_count
  integer(int64), save :: controller_counts(2) = 0
  abstract interface
    subroutine spectral_hook()
    end subroutine
  end interface
contains
!> Reconstruct all local orders, transpose their packed values, and release temporary storage.
!! The legacy optional numerical callback is outside the frozen route and is refused.
  subroutine ltinv_ctl(c, kf_out_lt, kf_uv, kf_scalars, kf_scders, pspvor, pspdiv, pspscalar, pspsc3a, pspsc3b, pspsc2, &
                       kfldptruv, kfldptrsc, fspgl_proc, status)
    type(native_transform_controller_state), intent(inout) :: c
    integer(int32), intent(in) :: kf_out_lt, kf_uv, kf_scalars, kf_scders
 real(real64), optional, intent(in) :: pspvor(:, :), pspdiv(:, :), pspscalar(:, :), pspsc3a(:, :, :), pspsc3b(:, :, :), pspsc2(:, :)
    integer(int32), optional, intent(in) :: kfldptruv(:), kfldptrsc(:)
    procedure(spectral_hook), optional :: fspgl_proc
    integer(int32), intent(out) :: status
    real(real64), allocatable :: vor(:, :), div(:, :), sc(:, :)
    integer :: jm, m, internal, leading, a, nsc, j, f, k, at
    integer(int64) :: words
    status = 2
    if (present(fspgl_proc)) return
    if (.not. controller_ready(c)) return
    if (any([kf_out_lt, kf_uv, kf_scalars, kf_scders] < 0) .or. any([kf_out_lt, kf_uv, kf_scalars, kf_scders] > 136)) return
    if (.not. associated(c%spectral) .or. .not. associated(c%inverse)) return
    if (c%inverse%keep_vorticity .neqv. c%lvorgp) return
    if (c%inverse%keep_divergence .neqv. c%ldivgp) return
    internal = 8*kf_uv + 2*kf_scalars + 2*kf_scders; leading = 2*kf_out_lt
    words = int(c%nlengt0b, int64)*leading
    ! Native staging only projects genuine optional field selectors; it supplies no calculation.
    allocate (vor(kf_uv, 506), div(kf_uv, 506), sc(kf_scalars, 506), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    if (kf_uv > 0) then
      if (.not. present(pspvor) .or. .not. present(pspdiv)) return
      call copy_selected(pspvor, vor, kfldptruv)
      if (status /= 0) return
      call copy_selected(pspdiv, div, kfldptruv)
      if (status /= 0) return
    end if
    status = 2
    if (kf_scalars > 0) then
      if (present(pspscalar)) then
        call copy_selected(pspscalar, sc, kfldptrsc)
        if (status /= 0) return
      else
        at = 0
        if (present(pspsc2) .and. c%nf_sc2 > 0) then
          if (size(pspsc2, 1) < c%nf_sc2 .or. size(pspsc2, 2) /= 506 .or. at + c%nf_sc2 > kf_scalars) return
          sc(at + 1:at + c%nf_sc2, :) = pspsc2(1:c%nf_sc2, :); at = at + c%nf_sc2
        end if
        if (present(pspsc3a) .and. c%nf_sc3a > 0) then
          if (size(pspsc3a, 1) < c%nf_sc3a .or. size(pspsc3a, 2) /= 506) return
          do j = 1, size(pspsc3a, 3)
            if (at + c%nf_sc3a > kf_scalars) return
            sc(at + 1:at + c%nf_sc3a, :) = pspsc3a(1:c%nf_sc3a, :, j); at = at + c%nf_sc3a
          end do
        end if
        if (present(pspsc3b) .and. c%nf_sc3b > 0) then
          if (size(pspsc3b, 1) < c%nf_sc3b .or. size(pspsc3b, 2) /= 506) return
          do j = 1, size(pspsc3b, 3)
            if (at + c%nf_sc3b > kf_scalars) return
            sc(at + 1:at + c%nf_sc3b, :) = pspsc3b(1:c%nf_sc3b, :, j); at = at + c%nf_sc3b
          end do
        end if
        if (at /= kf_scalars) return
      end if
    end if
    call gstats(102, 0)
    call ensure_transform_buffer(c%foubuf, words, .false., status)
    if (status /= 0) return
    call ensure_transform_buffer(c%foubuf_in, words, .true., status)
    if (status /= 0) return
    if (c%ldll) c%foubuf_in = 0.0_real64
    if (kf_out_lt > 0) then
      call gstats(1647, 0)
      do jm = 1, size(c%myms)
        m = c%myms(jm)
    call reconstruct_spectral_order(c%spectral,c%layout,c%inverse,int(m,int32),int(jm,int32),kf_out_lt,kf_uv,kf_scalars,kf_scders, &
                          int(internal, int32), int(leading, int32), c%foubuf_in, status, vorticity=vor, divergence=div, scalars=sc)
        if (status /= 0) return
      end do
      call gstats(1647, 1)
    end if
    call gstats(102, 1); call gstats(152, 0)
    call copy_legendre_partition(c, .true., c%foubuf_in, c%foubuf, int(leading, int32), status)
    if (status /= 0) return
    call gstats(152, 1)
    if (.not. c%lalloperm) deallocate (c%foubuf_in)
    controller_counts(1) = controller_counts(1) + 1
    status = 0
  contains
    subroutine copy_selected(x, out, map)
      real(real64), intent(in) :: x(:, :)
      real(real64), intent(inout) :: out(:, :)
      integer(int32), optional, intent(in) :: map(:)
      integer :: f, k, j
      status = 2
      if (size(x, 2) /= 506) return
      if (present(map)) then
        if (size(map) /= size(out, 1)) return
        if (any(map < 1) .or. any(map > size(x, 1))) return
      else
        if (size(x, 1) < size(out, 1)) return
      end if
      do j = 1, 506
        do f = 1, size(out, 1)
          k = f; if (present(map)) k = map(f)
          out(f, j) = x(k, j)
        end do
      end do
      status = 0
    end subroutine
  end subroutine
!> Transpose the input buffer, analyse each order, and publish the supplied spectral fields.
subroutine ltdir_ctl(c, kf_fs, kf_uv, kf_scalars, pspvor, pspdiv, pspscalar, pspsc3a, pspsc3b, pspsc2, kfldptruv, kfldptrsc, status)
    type(native_transform_controller_state), intent(inout) :: c
    integer(int32), intent(in) :: kf_fs, kf_uv, kf_scalars
    real(real64),optional,intent(inout)::pspvor(:,:),pspdiv(:,:),pspscalar(:,:),pspsc3a(:,:,:),pspsc3b(:,:,:),pspsc2(:,:)
    integer(int32), optional, intent(in) :: kfldptruv(:), kfldptrsc(:)
    integer(int32), intent(out) :: status
    integer :: jm, m, leading
    integer(int64) :: words
    status = 2
    if (.not. controller_ready(c)) return
    if (any([kf_fs, kf_uv, kf_scalars] < 0) .or. any([kf_fs, kf_uv, kf_scalars] > 136)) return
    if (.not. allocated(c%foubuf_in)) return
    leading = 2*kf_fs; words = int(c%nlengt0b, int64)*leading
    call ensure_transform_buffer(c%foubuf, words, .false., status)
    if (status /= 0) return
    call gstats(153, 0)
    call copy_legendre_partition(c, .false., c%foubuf_in, c%foubuf, int(leading, int32), status)
    if (status /= 0) return
    call gstats(153, 1)
    if (.not. c%lalloperm) deallocate (c%foubuf_in)
    call gstats(103, 0); call gstats(1645, 0)
    if (kf_fs > 0) then
      do jm = 1, size(c%myms)
        m = c%myms(jm)
        call analyse_spectral_order(c, int(m, int32), int(jm, int32), kf_fs, kf_uv, kf_scalars, int(leading, int32), &
                                    pspvor, pspdiv, pspscalar, pspsc3a, pspsc3b, pspsc2, kfldptruv, kfldptrsc, status)
        if (status /= 0) return
      end do
    end if
    call gstats(1645, 1)
    if (.not. c%lalloperm) deallocate (c%foubuf)
    call gstats(103, 1)
    controller_counts(2) = controller_counts(2) + 1
    status = 0
  end subroutine
  logical function controller_ready(c)
    type(native_transform_controller_state), intent(in) :: c
    integer :: j
    controller_ready = .false.
    if (c%nproc /= 1 .or. c%nlengt0b < 1 .or. .not. associated(c%myms)) return
    if (.not. associated(c%layout)) return
    if (size(c%myms) < 1 .or. size(c%myms) > 22 .or. lbound(c%myms, 1) /= 1) return
    do j = 1, size(c%myms)
      if (c%myms(j) /= j - 1) return
    end do
    if (min(c%nf_sc2, c%nf_sc3a, c%nf_sc3b) < 0) return
    controller_ready = .true.
  end function
!> Return original independent inverse/direct counters using a zero-based C index.
  integer(c_int64_t) function legendre_controllers_count(index) bind(C, name="md2asm_legendre_controllers_count_get") result(n)
    integer(c_int), value :: index
    n = 0
    if (index >= 0 .and. index < 2) n = controller_counts(index + 1)
  end function
end module
