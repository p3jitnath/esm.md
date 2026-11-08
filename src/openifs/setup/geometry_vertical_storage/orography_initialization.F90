!> Calculate terrain and its two derivatives through the public transform API.
module forecast_orography_initialization
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_public_transform, only: native_transform_resolution
  use forecast_laplacian_geometry, only: native_laplacian_geometry
  use forecast_orography_storage, only: native_orography_storage
  implicit none
  private
  public :: native_blocked_orography, initialize_selected_orography
  public :: initialize_operational_orography, initialize_distributed_operational_orography
  public :: release_initialized_orography
  !> Own the three NPROMA-by-block arrays produced by SUOROG.
  !! OROG uses m**2/s**2. OROGL and OROGM use m/s**2.
  !! Inactive final-block rows retain their allocation preimages.
  type :: native_blocked_orography
    real(c_double), allocatable :: orog(:, :), orogl(:, :), orogm(:, :)
  end type
#include "inv_trans.h"
contains
  !> Preserve the source selected route and call order.
  !! All integer counts and process indices are dimensionless live inputs.
  !! SPECTRAL contains packed real/imaginary coefficients of geopotential.
  !! RESOLUTION is the caller-owned live public handle. LAPLACIAN is read only.
  !! TERRAIN already owns true-extent block arrays; this entry fills them.
  !! Return2 refuses before mutation,1 releases private allocations,0 succeeds.
  integer(c_int)function initialize_selected_orography(blocked,terrain,spectral,resolution,laplacian,truncation,point_count,block_width, &
                                               spectral_count, wave_count, mysetv, nprtrv, lelam, lgradgp, lnonhydro) result(status)
  type(native_blocked_orography), intent(inout) :: blocked
  type(native_orography_storage), intent(inout) :: terrain
  real(c_double), target, contiguous, intent(in) :: spectral(:)
  type(native_transform_resolution), intent(in) :: resolution
  type(native_laplacian_geometry), intent(in) :: laplacian
  integer(c_int), intent(in) :: truncation, point_count, block_width, spectral_count, wave_count, mysetv, nprtrv
  logical, intent(in) :: lelam, lgradgp, lnonhydro
  status=initialize_orography_route(0_c_int,blocked,terrain,spectral,resolution,laplacian,truncation,point_count,block_width, &
                                    spectral_count, wave_count, mysetv, nprtrv, lelam, lgradgp, lnonhydro)
  end function
  !> Preserve the source operational route and call order.
  !! All integer counts and process indices are dimensionless live inputs.
  !! SPECTRAL contains packed real/imaginary coefficients of geopotential.
  !! RESOLUTION is the caller-owned live public handle. LAPLACIAN is read only.
  !! TERRAIN already owns true-extent block arrays; this entry fills them.
  !! Return2 refuses before mutation,1 releases private allocations,0 succeeds.
  integer(c_int)function initialize_operational_orography(blocked,terrain,spectral,resolution,laplacian,truncation,point_count,block_width, &
                                               spectral_count, wave_count, mysetv, nprtrv, lelam, lgradgp, lnonhydro) result(status)
  type(native_blocked_orography), intent(inout) :: blocked
  type(native_orography_storage), intent(inout) :: terrain
  real(c_double), target, contiguous, intent(in) :: spectral(:)
  type(native_transform_resolution), intent(in) :: resolution
  type(native_laplacian_geometry), intent(in) :: laplacian
  integer(c_int), intent(in) :: truncation, point_count, block_width, spectral_count, wave_count, mysetv, nprtrv
  logical, intent(in) :: lelam, lgradgp, lnonhydro
  status=initialize_orography_route(1_c_int,blocked,terrain,spectral,resolution,laplacian,truncation,point_count,block_width, &
                                    spectral_count, wave_count, mysetv, nprtrv, lelam, lgradgp, lnonhydro)
end function
!> Preserve the source distributed operational route and call order.
  !! All integer counts and process indices are dimensionless live inputs.
  !! SPECTRAL contains packed real/imaginary coefficients of geopotential.
  !! RESOLUTION is the caller-owned live public handle. LAPLACIAN is read only.
  !! TERRAIN already owns true-extent block arrays; this entry fills them.
  !! Return2 refuses before mutation,1 releases private allocations,0 succeeds.
  integer(c_int)function initialize_distributed_operational_orography(blocked,terrain,spectral,resolution,laplacian,truncation,point_count,block_width, &
                                               spectral_count, wave_count, mysetv, nprtrv, lelam, lgradgp, lnonhydro) result(status)
type(native_blocked_orography), intent(inout) :: blocked
type(native_orography_storage), intent(inout) :: terrain
real(c_double), target, contiguous, intent(in) :: spectral(:)
type(native_transform_resolution), intent(in) :: resolution
type(native_laplacian_geometry), intent(in) :: laplacian
integer(c_int), intent(in) :: truncation, point_count, block_width, spectral_count, wave_count, mysetv, nprtrv
logical, intent(in) :: lelam, lgradgp, lnonhydro
status=initialize_orography_route(2_c_int,blocked,terrain,spectral,resolution,laplacian,truncation,point_count,block_width, &
                                  spectral_count, wave_count, mysetv, nprtrv, lelam, lgradgp, lnonhydro)
end function
!> Shared ordered arithmetic, with selected and operational admission separate.
  !! Distributed callers uniformly admit inputs and available workspace before
  !! entering public collective transforms. This child owns no public context.
integer(c_int) function initialize_orography_route(route, blocked, terrain, spectral, resolution, laplacian, &
         truncation, point_count, block_width, spectral_count, wave_count, mysetv, nprtrv, lelam, lgradgp, lnonhydro) result(status)
  integer(c_int), intent(in) :: route
  type(native_blocked_orography), intent(inout) :: blocked
  type(native_orography_storage), intent(inout) :: terrain
  real(c_double), target, contiguous, intent(in) :: spectral(:)
  type(native_transform_resolution), intent(in) :: resolution
  type(native_laplacian_geometry), intent(in) :: laplacian
  integer(c_int), intent(in) :: truncation, point_count, block_width, spectral_count, wave_count, mysetv, nprtrv
  logical, intent(in) :: lelam, lgradgp, lnonhydro
  real(c_double), allocatable, target :: workspace(:)
  real(c_double), allocatable :: pending_orog(:, :), pending_orogl(:, :), pending_orogm(:, :)
  real(c_double), pointer, contiguous :: scalar_grid(:, :, :), spectral_view(:, :), vorticity(:, :), divergence(:, :), uv(:, :, :)
  integer(c_int) :: field_group(1), local_fields, wave, mode, degree, index, block, local, point, blocks, active
  integer(c_int64_t) :: words, coefficient_words, last_index, block_words
  integer :: allocation_status, start
  real(c_double) :: eigenvalue, zero_value, product_value
  status = 2
  if (transfer(lelam, 0_c_int) /= 0 .or. transfer(lgradgp, 0_c_int) /= 0) return
  if (transfer(lnonhydro, 0_c_int) /= 0) return
  if (resolution%resolution < 1) return
  if (block_width < 1 .or. block_width > 1024 .or. point_count < 1) return
  if (truncation < 1 .or. truncation > 4096) return
  if (spectral_count < 0 .or. mod(spectral_count, 2) /= 0) return
  if (int(spectral_count, c_int64_t) > (int(truncation, c_int64_t) + 1)*(int(truncation, c_int64_t) + 2)) return
  if (wave_count < 0 .or. wave_count > truncation + 1) return
  if (nprtrv < 1 .or. nprtrv > 137 .or. mysetv < 1 .or. mysetv > nprtrv) return
  blocks = 1 + (point_count - 1)/block_width
  if (blocks > 388217) return
  if (route == 0) then
    if (truncation /= 21 .or. point_count /= 2048 .or. block_width /= 24) return
    if (spectral_count /= 506 .or. wave_count /= 22 .or. mysetv /= 1 .or. nprtrv /= 1) return
  else if (route == 1) then
    if (truncation /= 1279 .or. point_count /= 6599680 .or. block_width /= 17) return
    if (spectral_count /= 1639680 .or. wave_count /= 1280 .or. mysetv /= 1 .or. nprtrv /= 1) return
  end if
  if (allocated(blocked%orog) .or. allocated(blocked%orogl) .or. allocated(blocked%orogm)) return
  if (.not. allocated(terrain%blocks)) return
  if (lbound(terrain%blocks, 1) /= 1 .or. size(terrain%blocks) /= blocks) return
  do block = 1, blocks
    active = min(block_width, point_count - (block - 1)*block_width)
    if (.not. allocated(terrain%blocks(block)%orog)) return
    if (.not. allocated(terrain%blocks(block)%orogl)) return
    if (.not. allocated(terrain%blocks(block)%orogm)) return
    if (lbound(terrain%blocks(block)%orog, 1) /= 1 .or. size(terrain%blocks(block)%orog) /= active) return
    if (lbound(terrain%blocks(block)%orogl, 1) /= 1 .or. size(terrain%blocks(block)%orogl) /= active) return
    if (lbound(terrain%blocks(block)%orogm, 1) /= 1 .or. size(terrain%blocks(block)%orogm) /= active) return
  end do
  if (.not. allocated(laplacian%myms) .or. .not. allocated(laplacian%nasm0)) return
  if (.not. allocated(laplacian%rlapdi)) return
  if (size(laplacian%myms) < wave_count) return
  if (lbound(laplacian%nasm0, 1) > 0 .or. ubound(laplacian%nasm0, 1) < truncation) return
  if (lbound(laplacian%rlapdi, 1) > 0 .or. ubound(laplacian%rlapdi, 1) < truncation) return
  do wave = 1, wave_count
    mode = laplacian%myms(wave)
    if (mode < 0 .or. mode > truncation) return
    index = laplacian%nasm0(mode)
    if (index < 1) return
    last_index = int(index, c_int64_t) + 2_c_int64_t*(truncation - mode) + 1_c_int64_t
    if (last_index > spectral_count) return
  end do
  local_fields = merge(1_c_int, 0_c_int, mysetv == nprtrv)
  coefficient_words = int(local_fields, c_int64_t)*spectral_count
  if (size(spectral, kind=c_int64_t) < coefficient_words) return
  words = 3_c_int64_t*point_count + 2_c_int64_t*coefficient_words
  block_words = int(block_width, c_int64_t)*blocks
  if (words > huge(0_c_int64_t)/8_c_int64_t .or. block_words > huge(0_c_int64_t)/8_c_int64_t) return
  allocate (workspace(words), stat=allocation_status)
  if (allocation_status /= 0) then
    status = 1; return
  end if
  scalar_grid(1:point_count, 1:1, 1:1) => workspace(1:point_count)
  start = point_count + 1
  vorticity(1:local_fields, 1:spectral_count) => workspace(start:start + coefficient_words - 1)
  start = start + int(coefficient_words)
  divergence(1:local_fields, 1:spectral_count) => workspace(start:start + coefficient_words - 1)
  start = start + int(coefficient_words)
  uv(1:point_count, 1:2, 1:1) => workspace(start:start + 2*point_count - 1)
  spectral_view(1:local_fields, 1:spectral_count) => spectral(1:coefficient_words)
  field_group(1) = nprtrv
  call inv_trans(pspscalar=spectral_view, kresol=resolution%resolution, kproma=point_count, &
                 kvsetsc=field_group, pgp=scalar_grid)
  if (local_fields == 1) then
    do wave = 1, wave_count
      mode = laplacian%myms(wave)
      index = laplacian%nasm0(mode)
      do degree = mode, truncation
        eigenvalue = laplacian%rlapdi(degree)
        zero_value = 0.0_c_double*eigenvalue
        vorticity(1, index) = zero_value
        product_value = spectral(index)*eigenvalue
        divergence(1, index) = product_value
        if (mode == 0) then
          vorticity(1, index + 1) = 0.0_c_double
          divergence(1, index + 1) = 0.0_c_double
        else
          vorticity(1, index + 1) = zero_value
          product_value = spectral(index + 1)*eigenvalue
          divergence(1, index + 1) = product_value
        end if
        index = index + 2
      end do
    end do
  end if
  call inv_trans(pspvor=vorticity, pspdiv=divergence, kvsetuv=field_group, &
                 kresol=resolution%resolution, kproma=point_count, pgp=uv)
  allocate (pending_orog(block_width, blocks), stat=allocation_status)
  if (allocation_status /= 0) goto900
  allocate (pending_orogl(block_width, blocks), stat=allocation_status)
  if (allocation_status /= 0) goto900
  allocate (pending_orogm(block_width, blocks), stat=allocation_status)
  if (allocation_status /= 0) goto900
  call move_alloc(pending_orog, blocked%orog)
  call move_alloc(pending_orogl, blocked%orogl)
  call move_alloc(pending_orogm, blocked%orogm)
  do point = 1, point_count
    block = 1 + (point - 1)/block_width
    local = 1 + mod(point - 1, block_width)
    terrain%blocks(block)%orog(local) = scalar_grid(point, 1, 1)
    blocked%orog(local, block) = scalar_grid(point, 1, 1)
    terrain%blocks(block)%orogl(local) = uv(point, 1, 1)
    blocked%orogl(local, block) = uv(point, 1, 1)
    terrain%blocks(block)%orogm(local) = uv(point, 2, 1)
    blocked%orogm(local, block) = uv(point, 2, 1)
  end do
  deallocate (workspace)
  status = 0
  return
900 continue
  if (allocated(pending_orog)) deallocate (pending_orog)
  if (allocated(pending_orogl)) deallocate (pending_orogl)
  if (allocated(pending_orogm)) deallocate (pending_orogm)
  deallocate (workspace)
  status = 1
end function
!> Release only the three new blocked owners, in original source order.
  !! The caller separately releases its pre-existing true-extent terrain owner.
subroutine release_initialized_orography(blocked)
  type(native_blocked_orography), intent(inout) :: blocked
  if (allocated(blocked%orog)) deallocate (blocked%orog)
  if (allocated(blocked%orogl)) deallocate (blocked%orogl)
  if (allocated(blocked%orogm)) deallocate (blocked%orogm)
end subroutine
end module forecast_orography_initialization
