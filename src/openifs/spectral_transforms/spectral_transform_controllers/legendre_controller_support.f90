!> Own the serial partition copies and complete direct Legendre packing stages.
module forecast_native_legendre_controller_support
  use iso_fortran_env, only: int32, int64, real64
  use yomhook, only: lhook, dr_hook
  use forecast_native_transform_controller_state, only: native_transform_controller_state
  use md2asm_fourier_buffer_packing, only: prepare_latitude_parity
  use md2asm_legendre_matrix_transforms, only: analyse_legendre_wave
  use md2asm_spectral_latitude_operators, only: wind_to_vorticity_divergence
  implicit none
  private
  public :: copy_legendre_partition, analyse_spectral_order
contains
!> Copy the complete selected interval in increasing order, with no arithmetic.
  subroutine copy_legendre_partition(c, to_latitude, input, output, fields, status)
    type(native_transform_controller_state), intent(in) :: c
    logical, intent(in) :: to_latitude
    real(real64), intent(in) :: input(:)
    real(real64), intent(inout) :: output(:)
    integer(int32), intent(in) :: fields
    integer(int32), intent(out) :: status
    integer(int64) :: first, last, length, j, bits
    integer :: event
    real(real64) :: hook
    character(6) :: name
    status = 2
    if (c%nproc /= 1 .or. c%nprtrns /= 1 .or. c%mysetw /= 1 .or. fields < 0) return
    if (.not. associated(c%nltsgtb) .or. .not. associated(c%nstagt0b) .or. .not. associated(c%nstagt1b)) return
    if (lbound(c%nltsgtb, 1) > 1 .or. ubound(c%nltsgtb, 1) < 1) return
    if (lbound(c%nstagt0b, 1) > 1 .or. ubound(c%nstagt0b, 1) < 1) return
    if (lbound(c%nstagt1b, 1) > 1 .or. ubound(c%nstagt1b, 1) < 1) return
    if (c%nltsgtb(1) < 0 .or. c%nstagt0b(1) < 0 .or. c%nstagt1b(1) < 0) return
    length = int(c%nltsgtb(1), int64)*fields
    first = int(c%nstagt1b(1), int64)*fields + 1
    name = 'TRLTOM'; event = 1607
    if (to_latitude) then
      first = int(c%nstagt0b(1), int64)*fields + 1
      name = 'TRMTOL'; event = 1608
    end if
    last = first + length - 1
    if (first > huge(1_int32) .or. last >= huge(1_int32)) return
    if (length > 0) then
      if (last > min(size(input, kind=int64), size(output, kind=int64))) return
    end if
    if (lhook) call dr_hook(name, 0, hook)
    call gstats(event, 0)
    do j = first, last
      bits = transfer(input(j), 0_int64)
      output(j) = transfer(bits, 0.0_real64)
    end do
    call gstats(event, 1)
    if (lhook) call dr_hook(name, 1, hook)
    status = 0
  end subroutine
!> Analyse one selected zonal order, including metric, wind and spectral publication.
!! All Gaussian/epsilon maps are borrowed. Work arrays are private native allocations.
 subroutine analyse_spectral_order(c, m, im, kf_fs, kf_uv, kf_scalars, kled2, pspvor, pspdiv, pspscalar, pspsc3a, pspsc3b, pspsc2, &
                                    kfldptruv, kfldptrsc, status)
    type(native_transform_controller_state), intent(in) :: c
    integer(int32), intent(in) :: m, im, kf_fs, kf_uv, kf_scalars, kled2
    real(real64),optional,intent(inout)::pspvor(:,:),pspdiv(:,:),pspscalar(:,:),pspsc3a(:,:,:),pspsc3b(:,:,:),pspsc2(:,:)
    integer(int32), optional, intent(in) :: kfldptruv(:), kfldptrsc(:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: oa1(:, :), oa2(:, :), anti(:, :), sym(:, :), eps(:)
    integer :: j, f, a, width, selected, first, nlat, at, nsc, start, k
    real(real64) :: hook
    status = 2
    if (.not. associated(c%spectral) .or. .not. associated(c%layout) .or. .not. associated(c%inverse)) return
    if (c%latlon .or. c%spectral%latitude_longitude .or. c%spectral%butterfly) return
    if (c%spectral%maximum_degree /= 21 .or. c%spectral%total_degree /= 21) return
    if (kf_fs < 1 .or. kf_fs > 68 .or. kf_uv < 0 .or. kf_uv > 19 .or. kf_scalars < 0 .or. kf_scalars > 20) return
    if (kled2 /= 2*kf_fs .or. kf_fs /= 2*kf_uv + kf_scalars .or. m < 0 .or. m > 21 .or. im /= m + 1) return
    if (.not. allocated(c%foubuf) .or. .not. associated(c%layout%active_latitudes)) return
    if (m < lbound(c%layout%active_latitudes, 1) .or. m > ubound(c%layout%active_latitudes, 1)) return
    nlat = min(16, c%layout%active_latitudes(m)); first = max(16 - c%layout%active_latitudes(m) + 1, 1)
    if (nlat /= 16 .or. first /= 1) return
    if (.not. associated(c%racthe) .or. .not. associated(c%weights)) return
    if (lbound(c%racthe, 1) > 1 .or. ubound(c%racthe, 1) < 16) return
    if (lbound(c%weights, 1) > 1 .or. ubound(c%weights, 1) < 16) return
    if (.not. associated(c%inverse%spectral_start) .or. .not. associated(c%inverse%epsilon_start)) return
    if (.not. associated(c%inverse%epsilon_values)) return
    if (m < lbound(c%inverse%spectral_start, 1) .or. m > ubound(c%inverse%spectral_start, 1)) return
    if (m < lbound(c%inverse%epsilon_start, 1) .or. m > ubound(c%inverse%epsilon_start, 1)) return
    if (c%inverse%spectral_start(m) < 1 .or. c%inverse%spectral_start(m) + 2*(22 - m) - 1 > 506) return
    if (kf_uv > 0) then
      if (.not. present(pspvor) .or. .not. present(pspdiv)) return
      if (.not. output_ready(pspvor, kf_uv, kfldptruv) .or. .not. output_ready(pspdiv, kf_uv, kfldptruv)) return
    end if
    if (kf_scalars > 0) then
      if (present(pspscalar)) then
        if (.not. output_ready(pspscalar, kf_scalars, kfldptrsc)) return
      else
        nsc = 0
        if (present(pspsc2) .and. c%nf_sc2 > 0) then
          if (.not. output_ready(pspsc2, c%nf_sc2)) return
          nsc = nsc + c%nf_sc2
        end if
        if (present(pspsc3a) .and. c%nf_sc3a > 0) then
          if (size(pspsc3a, 1) < c%nf_sc3a .or. size(pspsc3a, 2) /= 506) return
          nsc = nsc + c%nf_sc3a*size(pspsc3a, 3)
        end if
        if (present(pspsc3b) .and. c%nf_sc3b > 0) then
          if (size(pspsc3b, 1) < c%nf_sc3b .or. size(pspsc3b, 2) /= 506) return
          nsc = nsc + c%nf_sc3b*size(pspsc3b, 3)
        end if
        if (nsc /= kf_scalars) return
      end if
    end if
    if (lhook) call dr_hook('LTDIR_MOD', 0, hook)
    allocate (oa1(25, kled2), oa2(25, max(4*kf_uv, 1)), eps(0:23), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    allocate (sym(kled2, 16), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    allocate (anti(kled2, 16), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    width = 2*kf_fs; selected = width
    if (m == 0) selected = width/2
    call prepare_latitude_parity(c%layout, kf_fs, m, im, c%foubuf, anti, sym, status)
    if (status /= 0) return
    do j = first, 16
      do f = 1, 4*kf_uv
        anti(f, j) = anti(f, j)*c%racthe(j)
        sym(f, j) = sym(f, j)*c%racthe(j)
      end do
    end do
    call analyse_legendre_wave(c%spectral, m, im, int(width, int32), int(selected, int32), int(first, int32), int(nlat, int32), &
                               kled2, anti, sym, oa1, c%weights(1:16), status)
    if (status /= 0) return
    deallocate (anti); deallocate (sym)
    if (kf_uv > 0) then
      start = c%inverse%epsilon_start(m) + im - m
      if (start + m < lbound(c%inverse%epsilon_values, 1) .or. start + 23 > ubound(c%inverse%epsilon_values, 1)) then
        status = 2; return
      end if
      do j = 0, m - 1
        eps(j) = 0.0_real64
      end do
      do j = m, 23
        eps(j) = c%inverse%epsilon_values(start + j)
      end do
      call wind_to_vorticity_divergence(c%spectral, m, kf_uv, eps, oa1(:, 1:2*kf_uv), oa1(:, 2*kf_uv + 1:4*kf_uv), &
                                        oa2(:, 1:2*kf_uv), oa2(:, 2*kf_uv + 1:4*kf_uv), status)
      if (status /= 0) return
    end if
    at = 1
    if (kf_uv > 0) then
      at = at + 4*kf_uv
      call scatter(oa2(:, 1:2*kf_uv), pspvor, kf_uv, kfldptruv)
      call scatter(oa2(:, 2*kf_uv + 1:4*kf_uv), pspdiv, kf_uv, kfldptruv)
      if (m == 0) then
        do f = 1, kf_uv
          k = f; if (present(kfldptruv)) k = kfldptruv(f)
          pspvor(k, c%inverse%spectral_start(0)) = 0.0_real64
          pspdiv(k, c%inverse%spectral_start(0)) = 0.0_real64
        end do
      end if
    end if
    if (kf_scalars > 0) then
      if (present(pspscalar)) then
        call scatter(oa1(:, at:at + 2*kf_scalars - 1), pspscalar, kf_scalars, kfldptrsc)
      else
        if (present(pspsc2) .and. c%nf_sc2 > 0) then
          call scatter(oa1(:, at:at + 2*c%nf_sc2 - 1), pspsc2, c%nf_sc2)
          at = at + 2*c%nf_sc2
        end if
        if (present(pspsc3a) .and. c%nf_sc3a > 0) then
          do j = 1, size(pspsc3a, 3)
            call scatter(oa1(:, at:at + 2*c%nf_sc3a - 1), pspsc3a(:, :, j), c%nf_sc3a)
            at = at + 2*c%nf_sc3a
          end do
        end if
        if (present(pspsc3b) .and. c%nf_sc3b > 0) then
          do j = 1, size(pspsc3b, 3)
            call scatter(oa1(:, at:at + 2*c%nf_sc3b - 1), pspsc3b(:, :, j), c%nf_sc3b)
            at = at + 2*c%nf_sc3b
          end do
        end if
      end if
    end if
    if (lhook) call dr_hook('LTDIR_MOD', 1, hook)
    status = 0
  contains
    logical function output_ready(x, fields, map)
      real(real64), intent(in) :: x(:, :)
      integer, intent(in) :: fields
      integer(int32), optional, intent(in) :: map(:)
      output_ready = .false.
      if (fields < 0 .or. fields > 4096 .or. size(x, 2) /= 506) return
      if (present(map)) then
        if (size(map) /= fields) return
        if (any(map < 1) .or. any(map > size(x, 1))) return
      else
        if (size(x, 1) < fields) return
      end if
      output_ready = .true.
    end function
    subroutine scatter(x, out, fields, map)
      real(real64), intent(in) :: x(:, :)
      real(real64), intent(inout) :: out(:, :)
      integer, intent(in) :: fields
      integer(int32), optional, intent(in) :: map(:)
      integer :: r, col, f, k, n
      if (present(map)) then
        do f = 1, fields
          k = map(f)
          do r = 2, 23 - m
            col = c%inverse%spectral_start(m) + (23 - r - m)*2
            out(k, col) = x(r, 2*f - 1)
            if (m == 0) then
              out(k, col + 1) = 0.0_real64
            else
              out(k, col + 1) = x(r, 2*f)
            end if
          end do
        end do
      else
        do r = 2, 23 - m
          col = c%inverse%spectral_start(m) + (23 - r - m)*2
          do f = 1, fields
            out(f, col) = x(r, 2*f - 1)
            if (m == 0) then
              out(f, col + 1) = 0.0_real64
            else
              out(f, col + 1) = x(r, 2*f)
            end if
          end do
        end do
      end if
    end subroutine
  end subroutine
end module
