!> Copy complete grid fields between native blocked owners and padded latitude rows.
module forecast_native_grid_transform_copies
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_int64_t
  use yomhook, only: lhook, dr_hook
  use forecast_native_transform_controller_state, only: native_transform_controller_state, serial_transform_ready
  implicit none
  private
  public :: trltog, trgtol, grid_transform_copy_count
  type :: field_reference
    real(real64), pointer :: values(:, :) => null()
  end type
  integer(int64), save :: copy_counts(2) = 0
contains
!> Scatter latitude(field,2144) into optional blocked outputs in source field order.
  subroutine trltog(c, pglat, kfield, kfieldg, kf_scalar, kset, kptrgp, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
    type(native_transform_controller_state), intent(in) :: c
    integer(int32), intent(in) :: kfield, kfieldg, kf_scalar, kset(:)
    integer(int32), optional, intent(in) :: kptrgp(:)
    real(real64), intent(inout) :: pglat(:, :)
    real(real64),optional,target,intent(inout)::pgp(:,:,:),pgpuv(:,:,:,:),pgp3a(:,:,:,:),pgp3b(:,:,:,:),pgp2(:,:,:)
    integer(int32), intent(out) :: status
    call grid_copy(c, .true., pglat, kfield, kfieldg, kf_scalar, kset, kptrgp, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
  end subroutine
!> Gather optional blocked inputs; unselected padded latitude positions stay unchanged.
  subroutine trgtol(c, pglat, kfield, kfieldg, kf_scalar, kset, kptrgp, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
    type(native_transform_controller_state), intent(in) :: c
    integer(int32), intent(in) :: kfield, kfieldg, kf_scalar, kset(:)
    integer(int32), optional, intent(in) :: kptrgp(:)
    real(real64), intent(inout) :: pglat(:, :)
    real(real64),optional,target,intent(inout)::pgp(:,:,:),pgpuv(:,:,:,:),pgp3a(:,:,:,:),pgp3b(:,:,:,:),pgp2(:,:,:)
    integer(int32), intent(out) :: status
    call grid_copy(c, .false., pglat, kfield, kfieldg, kf_scalar, kset, kptrgp, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
  end subroutine
!> Return the independent source counters: 0 scatter, 1 gather; other indices return 0.
  integer(c_int64_t) function grid_transform_copy_count(index) bind(C, name="md2asm_grid_transform_copy_count_get") result(n)
    integer(c_int), value :: index
    n = 0
    if (index >= 0 .and. index < 2) n = copy_counts(index + 1)
  end function
  subroutine grid_copy(c, tog, pglat, kfield, kfieldg, kf_scalar, kset, kptrgp, pgp, pgpuv, pgp3a, pgp3b, pgp2, status)
    type(native_transform_controller_state), intent(in) :: c
    logical, intent(in) :: tog
    integer(int32), intent(in) :: kfield, kfieldg, kf_scalar, kset(:)
    integer(int32), optional, intent(in) :: kptrgp(:)
    real(real64), intent(inout) :: pglat(:, :)
    real(real64),optional,target,intent(inout)::pgp(:,:,:),pgpuv(:,:,:,:),pgp3a(:,:,:,:),pgp3b(:,:,:,:),pgp2(:,:,:)
    integer(int32), intent(out) :: status
    integer(int32), allocatable :: indices(:)
    type(field_reference), allocatable :: refs(:)
    integer :: j, b, f, p, at, n, offset, first, count, field, target, source_col, category_end, base, params, uvparams, a, ev, norm
    integer(int64) :: bits
    real(real64) :: hook, barhook
    character(6) :: name
    status = 2
    if (.not. serial_transform_ready(c)) return
    if (c%nproma /= 24 .or. c%ngpblks /= 86 .or. c%ndgl_gp /= 32 .or. c%ngptot /= 2048) return
    if (c%nfrstloff /= 0 .or. c%nptrfloff /= 0 .or. c%ntrans_sync_level > 0) return
    if (kfield < 1 .or. kfield > 136 .or. kfieldg /= kfield .or. kf_scalar < 0 .or. kf_scalar > kfieldg) return
    if (size(pglat, 1) /= kfield .or. size(pglat, 2) /= 2144 .or. size(kset) /= kfieldg) return
    if (.not. tog) then
      if (c%lvorgp .or. c%ldivgp .or. c%lscders .or. c%luvder) return
    end if
    if (.not. associated(c%nfrstlat) .or. .not. associated(c%nlstlat)) return
    if (.not. associated(c%nptrfrstlat) .or. .not. associated(c%nultpp)) return
    if (min(size(c%nfrstlat), size(c%nlstlat), size(c%nptrfrstlat), size(c%nultpp)) < 1) return
    if (c%nfrstlat(1) /= 1 .or. c%nlstlat(1) /= 32 .or. c%nptrfrstlat(1) /= 1 .or. c%nultpp(1) /= 32) return
    if (c%layout%first_latitude /= 1) return
    if (.not. associated(c%layout%process_of_latitude) .or. .not. associated(c%layout%column_offset)) return
    if (.not. associated(c%nsta) .or. .not. associated(c%nonl)) return
    if (lbound(c%layout%process_of_latitude, 1) > 1 .or. ubound(c%layout%process_of_latitude, 1) < 32) return
    if (lbound(c%layout%column_offset, 1) > 1 .or. ubound(c%layout%column_offset, 1) < 32) return
    if (lbound(c%nsta, 1) > 1 .or. ubound(c%nsta, 1) < 32 .or. lbound(c%nsta, 2) > 1 .or. ubound(c%nsta, 2) < 1) return
    if (lbound(c%nonl, 1) > 1 .or. ubound(c%nonl, 1) < 32 .or. lbound(c%nonl, 2) > 1 .or. ubound(c%nonl, 2) < 1) return
    if (present(kptrgp)) then
      if (size(kptrgp) /= kfieldg) return
    end if
    name = 'TRGTOL'; ev = 1805
    if (tog) then
      name = 'TRLTOG'; ev = 1806
    end if
    if (lhook) call dr_hook(name, 0, hook)
    call gstats(ev, 0)
    allocate (indices(2184), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    at = 0
    do j = 1, 32
      if (c%layout%process_of_latitude(j) /= 1) return
      offset = c%layout%column_offset(j); first = c%nsta(j, 1); count = c%nonl(j, 1)
      if (first /= 1 .or. count < 1 .or. count > 64 .or. offset + first < 1 .or. offset + first + count - 1 > 2144) return
      if (at + count > 2048) return
      do p = 0, count - 1
        at = at + 1; indices(at) = offset + first + p
      end do
    end do
    if (at /= 2048) return
    call gstats(ev, 1)
    if (lhook) call dr_hook(name//'_BAR', 0, barhook)
    call gstats_barrier(merge(762, 761, tog))
    if (lhook) call dr_hook(name//'_BAR', 1, barhook)
    norm = 803; if (c%lgpnorm) norm = 804
    if (tog) norm = 805
    call gstats(norm, 0); call gstats(norm, 1)
    call gstats(ev, 0)
    allocate (refs(kfieldg), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    if (present(pgp)) then
      field = 1
      call map3(pgp, field, kfieldg, 1)
      if (status /= 0) return
    else
      field = 1; uvparams = 2 + merge(1, 0, c%lvorgp) + merge(1, 0, c%ldivgp)
      if (present(pgpuv)) then
        call map4(pgpuv, field, size(pgpuv, 2), uvparams, 1)
        if (status /= 0) return
      end if
      base = field
      call scalar_groups(field, 0)
      if (status /= 0) return
      if (field /= base + kf_scalar) then
        status = 2; return
      end if
      category_end = field
      if (c%lscders) then
        call scalar_groups(field, 1)
        if (status /= 0) return
      end if
      if (c%luvder .and. present(pgpuv)) then
        field = category_end + merge(kf_scalar, 0, c%lscders)
        call map4(pgpuv, field, size(pgpuv, 2), 2, uvparams + 1)
        if (status /= 0) return
      end if
      if (c%lscders) then
        field = base + 2*kf_scalar
        if (c%luvder .and. present(pgpuv)) field = field + 2*size(pgpuv, 2)
        call scalar_groups(field, 2)
        if (status /= 0) return
      end if
    end if
    status = 2
    do f = 1, kfieldg
      if (kset(f) /= 1 .and. kset(f) /= -1) return
      target = f
      if (present(kptrgp)) target = kptrgp(f)
      if (target < 1 .or. target > kfieldg) return
      if (.not. associated(refs(target)%values)) return
      indices(2048 + f) = target
    end do
    call gstats(ev, 1)
    n = 1601; if (tog) n = 1604
    call gstats(n, 0)
    do b = 1, 86
      count = 24; if (b == 86) count = 8
      do f = 1, kfieldg
        target = indices(2048 + f)
        do p = 1, count
          source_col = indices((b - 1)*24 + p)
          if (tog) then
            bits = transfer(pglat(f, source_col), 0_int64)
            refs(target)%values(p, b) = transfer(bits, 0.0_real64)
          else
            bits = transfer(refs(target)%values(p, b), 0_int64)
            pglat(f, source_col) = transfer(bits, 0.0_real64)
          end if
        end do
      end do
    end do
    call gstats(n, 1)
    call gstats(norm, 0); call gstats(norm, 1)
    deallocate (indices); deallocate (refs)
    call gstats_barrier2(merge(762, 761, tog))
    if (lhook) call dr_hook(name, 1, hook)
    if (tog) then
      copy_counts(1) = copy_counts(1) + 1
    else
      copy_counts(2) = copy_counts(2) + 1
    end if
    status = 0
  contains
    !> Associate each field with the actual point/block section; never copy an owner.
    subroutine map3(x, field, parameters, first_parameter)
      real(real64), target, intent(inout) :: x(:, :, :)
      integer, intent(inout) :: field
      integer, intent(in) :: parameters, first_parameter
      integer :: k
      status = 2
      if (parameters < 0) return
      if (parameters == 0) then
        status = 0; return
      end if
      if (size(x, 1) < 24 .or. size(x, 3) < 86 .or. first_parameter < 1) return
      if (first_parameter + parameters - 1 > size(x, 2)) return
      if (field < 1 .or. field + parameters - 1 > kfieldg) return
      do k = first_parameter, first_parameter + parameters - 1
        refs(field)%values => x(:, k, :)
        field = field + 1
      end do
      status = 0
    end subroutine
    subroutine map4(x, field, levels, parameters, first_parameter)
      real(real64), target, intent(inout) :: x(:, :, :, :)
      integer, intent(inout) :: field
      integer, intent(in) :: levels, parameters, first_parameter
      integer :: k, l
      status = 2
      if (parameters < 0) return
      if (parameters == 0) then
        status = 0; return
      end if
      if (size(x, 1) < 24 .or. size(x, 4) < 86 .or. levels < 1 .or. levels > size(x, 2) .or. first_parameter < 1) return
      if (first_parameter + parameters - 1 > size(x, 3)) return
      if (field < 1 .or. field + levels*parameters - 1 > kfieldg) return
      do k = first_parameter, first_parameter + parameters - 1
        do l = 1, levels
          refs(field)%values => x(:, l, k, :)
          field = field + 1
        end do
      end do
      status = 0
    end subroutine
    subroutine scalar_groups(field, phase)
      integer, intent(inout) :: field
      integer, intent(in) :: phase
      integer :: np
      status = 0
      if (present(pgp2)) then
        np = size(pgp2, 2); if (c%lscders) np = np/3
        call map3(pgp2, field, np, np*phase + 1)
        if (status /= 0) return
      end if
      if (present(pgp3a)) then
        np = size(pgp3a, 3); if (c%lscders) np = np/3
        call map4(pgp3a, field, size(pgp3a, 2), np, np*phase + 1)
        if (status /= 0) return
      end if
      if (present(pgp3b)) then
        np = size(pgp3b, 3); if (c%lscders) np = np/3
        call map4(pgp3b, field, size(pgp3b, 2), np, np*phase + 1)
      end if
    end subroutine
  end subroutine
end module
