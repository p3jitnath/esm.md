!> Compose the real public transform, Gaussian and local radiation grid stages.
!! The caller starts public MPI/transform context and owns every borrowed target.
!! Added integer coordination preserves IEEE state and errno. Public numerical
!! calls retain their natural state. No original model numerical method is used.
module forecast_live_radiation_setup
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_loc, c_associated, c_null_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08, only: MPI_Allreduce, MPI_Comm_size, MPI_Comm_rank, MPI_INTEGER, MPI_MAX, MPI_COMM_WORLD, MPI_SUCCESS
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_types, only: native_distributed_partition
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_native_radiation_grid, only: native_radiation_grid, &
                                          fill_preallocated_radiation_gaussian_fields, create_runtime_radiation_point_coordinates, &
                                            release_runtime_radiation_point_coordinates
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  implicit none
  private
  public :: native_radiation_transform_storage
  public :: create_runtime_radiation_transform_storage, release_runtime_radiation_transform_storage
  public :: create_live_radiation_gaussian_setup, create_live_radiation_point_setup
  public :: release_live_radiation_point_setup, retire_radiation_zmu, validate_live_radiation_storage
  type :: saved_grid_scalars
    integer(int32) :: ndglg, ndlon, nsmax, ngptot, nfrstloff, ndgsl, ndgsah, ndgenh
    integer(int32) :: ndgsal, ndgenl, ndlonh, ndlonm, myfrstlat, mylstlat
    integer(int32) :: nspec2, nump, ngptotg, ngptotmx
  end type
#include "setup_trans.h"
#include "trans_inq.h"
#include "trans_release.h"
  interface
    function errno_location() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine fatal_public_error() bind(c, name="abort")
    end subroutine
  end interface
contains
  !> Create nine source-ordered owners and query their actual public grid.
 !! All WORLD processes enter together. Fresh OWNER and the new Gaussian
 !! fields are unallocated. GRID/ROWS are stable disjoint borrowed targets.
 !! ROWS retains source lower bound-1 and upper boundN+2. Physical state is
 !! readonly and stays live for the following Gaussian/point stages.
  integer(int32) function create_runtime_radiation_transform_storage(owner, g, rows, control, partition, physical) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(native_radiation_grid), target, intent(inout) :: g
    integer(int32), target, intent(in) :: rows(-1:)
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    type(forecast_physical_constants), intent(in) :: physical
    type(saved_grid_scalars) :: saved
    integer(int32) :: local, ns, ew, n
    integer :: a, j
    logical :: split, fftw, grid_only
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: allocation_error
    call c_f_pointer(errno_location(), system_error)
    local = 2_int32
    if (storage_admission(owner, g, rows, control, partition)) local = 0_int32
    status = agree(local)
    if (status /= 0) return
    call save_grid(g, saved, owner)
    n = g%ndglg; ns = control%regions_ns; ew = control%regions_ew
    owner%grid => g; owner%row_lengths => rows
    owner%points%n_regions_ns = ns; owner%points%n_regions_ew = ew
    owner%points%my_region_ns = partition%my_region_ns
    owner%points%my_region_ew = partition%my_region_ew
    owner%resolution%truncation = g%nsmax; owner%resolution%row_count = n
    split = control%lsplit == 1; fftw = control%lfftw == 1; grid_only = .true.
    call setup_trans(ksmax=g%nsmax, kdgl=n, kloen=rows(1:n), ldsplit=split, &
                     ldusefftw=fftw, kresol=owner%resolution%resolution, ldgridonly=grid_only)
    if (owner%resolution%resolution <= 0) call fatal_public_error()
    local = 1_int32
    source_allocations: block
      allocate (owner%nsta(-1:n + ns + 1, ew), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(1) = c_loc(owner%nsta)
      allocate (owner%nonl(-1:n + ns + 1, ew), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(2) = c_loc(owner%nonl)
      allocate (owner%nptrfrstlat(ns), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(3) = c_loc(owner%nptrfrstlat)
      allocate (owner%nfrstlat(ns), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(4) = c_loc(owner%nfrstlat)
      allocate (owner%nlstlat(ns), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(5) = c_loc(owner%nlstlat)
      allocate (g%rmu(-1:n + 2), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(6) = c_loc(g%rmu)
      allocate (owner%zmu(-1:n + 2), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(7) = c_loc(owner%zmu)
      allocate (g%rsqm2(-1:n + 2), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(8) = c_loc(g%rsqm2)
      allocate (g%rlatig(-1:n + 2), stat=a); if (a /= 0) exit source_allocations
      owner%allocation_address(9) = c_loc(g%rlatig)
      local = 0_int32
    end block source_allocations
    allocation_error = system_error
    status = agree(local)
    if (status /= 0) then
      call cleanup_storage(owner)
      call restore_grid(g, saved, owner)
      system_error = allocation_error
      return
    end if
    ! The active first-dimension sections retain the full source leading stride.
    ! Exterior map rows and ZMU halo words remain allocator preimages here.
    call trans_inq(kresol=owner%resolution%resolution, kspec2=owner%nspec2, &
                   knump=owner%nump, kgptot=g%ngptot, kgptotg=owner%ngptotg, kgptotmx=owner%ngptotmx, &
                   kptrfrstlat=owner%nptrfrstlat, kfrstlat=owner%nfrstlat, klstlat=owner%nlstlat, &
                   kfrstloff=g%nfrstloff, ksta=owner%nsta(1:n + ns - 1, :), konl=owner%nonl(1:n + ns - 1, :), &
                   kptrfloff=g%ndgsl, pmu=owner%zmu(1:n))
    owner%points%first_latitude => owner%nfrstlat
    owner%points%last_latitude => owner%nlstlat
    owner%points%longitude_count => owner%row_lengths
    owner%points%start => owner%nsta
    owner%points%count => owner%nonl
    owner%state = 1_int32
    ! Keep every fresh allocation distinct. This is ownership metadata only.
    do j = 1, 9
      if (.not. c_associated(owner%allocation_address(j))) call fatal_public_error()
    end do
    status = 0_int32
  end function

  !> Join storage inquiry to the unchanged complete ordered Gaussian child.
  integer(int32) function create_live_radiation_gaussian_setup(owner, g, rows, control, partition, physical, nradint) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(native_radiation_grid), target, intent(inout) :: g
    integer(int32), target, intent(in) :: rows(-1:)
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint
    type(saved_grid_scalars) :: saved
    integer(int32) :: local
    local = 2_int32
    if (nradint >= 2 .and. nradint <= 3) then
      if (finite_word(physical%rpi)) then
        if (physical%rpi >= 3.0_real64 .and. physical%rpi < 4.0_real64) local = 0_int32
      end if
    end if
    status = agree(local); if (status /= 0) return
    call save_grid(g, saved, owner)
    status = create_runtime_radiation_transform_storage(owner, g, rows, control, partition, physical)
    if (status /= 0) return
    local = fill_preallocated_radiation_gaussian_fields(g, owner%zmu, physical, nradint)
    status = agree(local)
    if (status /= 0) then
      call cleanup_storage(owner); call restore_grid(g, saved, owner)
      status = 2_int32
      return
    end if
    owner%state = 2_int32
  end function

  !> Publish six local scalars before the five original point allocations.
 !! All source and mutable owners remain actual caller targets. No shadow grid
 !! or numerical callback supplies any calculation.
 integer(int32) function create_live_radiation_point_setup(owner,g,rows,control,partition,physical,nradint,nstencilwide)result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(native_radiation_grid), target, intent(inout) :: g
    integer(int32), target, intent(in) :: rows(-1:)
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint, nstencilwide
    type(saved_grid_scalars) :: saved
    integer(int32) :: local, ignored, first, last
    local = 2_int32
    if (nstencilwide >= 1 .and. nstencilwide <= 16 .and. g%ndlon >= 1 .and. g%ndlon <= 16400) then
      if (.not. allocated(g%gelam) .and. .not. allocated(g%gelat) .and. .not. allocated(g%geslo) &
          .and. .not. allocated(g%geclo) .and. .not. allocated(g%gemu)) local = 0_int32
    end if
    status = agree(local); if (status /= 0) return
    call save_grid(g, saved, owner)
    status = create_live_radiation_gaussian_setup(owner, g, rows, control, partition, physical, nradint)
    if (status /= 0) return
    owner%points%nstencilwide = nstencilwide
    first = owner%nfrstlat(partition%my_region_ns)
    last = owner%nlstlat(partition%my_region_ns)
    g%ndgsal = 1_int32
    g%ndgenl = last - g%nfrstloff
    g%ndlonh = 2*nstencilwide - 1 - mod(g%ndlon, 2)
    g%ndlonm = max(g%ndlon, 2*g%nsmax + 1) + g%ndlonh
    g%myfrstlat = first; g%mylstlat = last
    local = create_runtime_radiation_point_coordinates(g, owner%zmu, physical, owner%points)
    status = agree(local)
    if (status /= 0) then
      ignored = release_runtime_radiation_point_coordinates(g)
      if (ignored /= 0) call fatal_public_error()
      call cleanup_storage(owner); call restore_grid(g, saved, owner)
      return
    end if
    owner%allocation_address(10) = c_loc(g%gelam)
    owner%allocation_address(11) = c_loc(g%gelat)
    owner%allocation_address(12) = c_loc(g%geslo)
    owner%allocation_address(13) = c_loc(g%geclo)
    owner%allocation_address(14) = c_loc(g%gemu)
    owner%state = 3_int32
  end function

  !> Check the complete owned maps, identities and bounds before any release.
 !! This collective preflight changes no owner. Every process calls together.
  integer(int32) function validate_live_radiation_storage(owner, require_points) result(status)
    type(native_radiation_transform_storage), target, intent(in) :: owner
    logical, intent(in) :: require_points
    integer(int32) :: local
    local = 2_int32
    if (storage_is_valid(owner)) then
      if (require_points) then
        if (points_are_valid(owner)) local = 0_int32
      else
        local = 0_int32
      end if
    end if
    status = agree(local)
  end function

  !> Retire only ZMU after point success, preserving every map for later RI/RO.
 !! This adds no original-source credit; it implements the next source release.
  integer(int32) function retire_radiation_zmu(owner) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer(int32) :: local
    call c_f_pointer(errno_location(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    local = 2_int32
    if (owner%state == 3) then
      if (storage_is_valid(owner)) then
        if (points_are_valid(owner)) local = 0_int32
      end if
    end if
    status = agree(local)
    if (status == 0) then
      deallocate (owner%zmu)
      owner%allocation_address(7) = c_null_ptr
      owner%state = 4_int32
    end if
    call ieee_set_status(floating); system_error = saved_error
  end function

  !> Release the public handle then nine owners in reverse source order.
 !! Point owners belonging to this storage must be released by the point entry.
  integer(int32) function release_runtime_radiation_transform_storage(owner) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer(int32) :: local
    call c_f_pointer(errno_location(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    local = 2_int32
    if (owner%state == 1 .or. owner%state == 2) then
      if (storage_is_valid(owner)) local = 0_int32
    end if
    status = agree(local)
    if (status == 0) call cleanup_storage(owner)
    call ieee_set_status(floating); system_error = saved_error
  end function

  !> Validate every point and storage owner before freeing either group.
 !! Five point owners release first in reverse order, then the public handle
 !! and nine storage owners. Retired ZMU is skipped. Borrowed ROWS survive.
  integer(int32) function release_live_radiation_point_setup(owner) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer(int32) :: ignored
    call c_f_pointer(errno_location(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    ignored = 2_int32
    if (owner%state == 3 .or. owner%state == 4) then
      if (storage_is_valid(owner)) then
        if (points_are_valid(owner)) ignored = 0_int32
      end if
    end if
    status = agree(ignored)
    if (status == 0) then
      ignored = release_runtime_radiation_point_coordinates(owner%grid)
      if (ignored /= 0) call fatal_public_error()
      call cleanup_storage(owner)
    end if
    call ieee_set_status(floating); system_error = saved_error
  end function

  logical function storage_admission(o, g, rows, c, p) result(valid)
    type(native_radiation_transform_storage), intent(in) :: o
    type(native_radiation_grid), intent(in) :: g
    integer(int32), intent(in) :: rows(-1:)
    type(native_transform_control), intent(in) :: c
    type(native_distributed_partition), intent(in) :: p
    integer :: n, ns, ew, i, world, rank
    integer(int64) :: occupied
    valid = .false.
    ! Public messages are already initialized on all WORLD participants.
    call world_identity(world, rank)
    if (.not. c%message_ready .or. .not. c%environment_ready) return
    if (c%nproc /= world .or. c%myproc /= rank + 1 .or. world < 1 .or. world > 32) return
    if (c%lsplit /= 1 .or. c%lfftw /= 0 .or. p%phase /= 7 .or. p%borrowed_resolution <= 0) return
    ns = c%regions_ns; ew = c%regions_ew; n = g%ndglg
    if (ns < 1 .or. ns > 64 .or. ew < 1 .or. ew > 64) return
    if (.not. allocated(c%n_regions) .or. .not. allocated(c%ngpset2pe)) return
    if (size(c%n_regions) < ns .or. size(c%ngpset2pe, 1) < ew .or. size(c%ngpset2pe, 2) < ns) return
    occupied = 0_int64
    do i = 1, ns
      if (c%n_regions(i) < 1 .or. c%n_regions(i) > ew) return
      occupied = occupied + int(c%n_regions(i), int64)
    end do
    if (occupied /= world) return
    if (p%my_region_ns < 1 .or. p%my_region_ns > ns) return
    if (p%my_region_ew < 1 .or. p%my_region_ew > c%n_regions(p%my_region_ns)) return
    if (c%ngpset2pe(p%my_region_ew, p%my_region_ns) /= c%myproc) return
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0 .or. g%nsmax /= 0) return
    if (.not. is_contiguous(rows) .or. ubound(rows, 1) /= n + 2) return
    do i = 1, n
      if (rows(i) < 1) return
    end do
    if (o%state /= 0 .or. associated(o%grid) .or. associated(o%row_lengths)) return
    if (o%resolution%resolution /= 0 .or. o%resolution%truncation /= 0 .or. o%resolution%row_count /= 0) return
    if (o%points%my_region_ns /= 0 .or. o%points%my_region_ew /= 0) return
    if (o%points%n_regions_ns /= 0 .or. o%points%n_regions_ew /= 0 .or. o%points%nstencilwide /= 0) return
    if (associated(o%points%first_latitude) .or. associated(o%points%last_latitude)) return
    if (associated(o%points%longitude_count) .or. associated(o%points%start) .or. associated(o%points%count)) return
    if (c_associated(o%halo_address(1)) .or. c_associated(o%halo_address(2))) return
    if (allocated(o%nsta) .or. allocated(o%nonl) .or. allocated(o%nptrfrstlat)) return
    if (allocated(o%nfrstlat) .or. allocated(o%nlstlat) .or. allocated(o%zmu)) return
    do i = 1, 14
      if (c_associated(o%allocation_address(i))) return
    end do
    if (allocated(g%rmu) .or. allocated(g%rsqm2) .or. allocated(g%rlatig)) return
    valid = .true.
  end function

  logical function storage_is_valid(o) result(valid)
    type(native_radiation_transform_storage), target, intent(in) :: o
    integer :: n, ns, ew, i
    valid = .false.
    if (o%state < 1 .or. o%state > 5 .or. .not. associated(o%grid) .or. .not. associated(o%row_lengths)) return
    n = o%resolution%row_count; ns = o%points%n_regions_ns; ew = o%points%n_regions_ew
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0 .or. o%grid%ndglg /= n .or. o%resolution%resolution <= 0) return
    if (ns < 1 .or. ns > 64 .or. ew < 1 .or. ew > 64) return
    if (.not. allocated(o%nsta) .or. .not. allocated(o%nonl) .or. .not. allocated(o%nptrfrstlat)) return
    if (.not. allocated(o%nfrstlat) .or. .not. allocated(o%nlstlat)) return
    if (any(lbound(o%nsta) /= [-1, 1]) .or. any(ubound(o%nsta) /= [n + ns + 1, ew])) return
    if (any(lbound(o%nonl) /= [-1, 1]) .or. any(ubound(o%nonl) /= [n + ns + 1, ew])) return
    if (lbound(o%nptrfrstlat, 1) /= 1 .or. size(o%nptrfrstlat) /= ns) return
    if (lbound(o%nfrstlat, 1) /= 1 .or. size(o%nfrstlat) /= ns) return
    if (lbound(o%nlstlat, 1) /= 1 .or. size(o%nlstlat) /= ns) return
    if (.not. allocated(o%grid%rmu) .or. .not. allocated(o%grid%rsqm2) .or. .not. allocated(o%grid%rlatig)) return
    if (lbound(o%grid%rmu, 1) /= -1 .or. ubound(o%grid%rmu, 1) /= n + 2) return
    if (lbound(o%grid%rsqm2, 1) /= -1 .or. ubound(o%grid%rsqm2, 1) /= n + 2) return
    if (lbound(o%grid%rlatig, 1) /= -1 .or. ubound(o%grid%rlatig, 1) /= n + 2) return
    if (.not. c_associated(c_loc(o%nsta), o%allocation_address(1))) return
    if (.not. c_associated(c_loc(o%nonl), o%allocation_address(2))) return
    if (.not. c_associated(c_loc(o%nptrfrstlat), o%allocation_address(3))) return
    if (.not. c_associated(c_loc(o%nfrstlat), o%allocation_address(4))) return
    if (.not. c_associated(c_loc(o%nlstlat), o%allocation_address(5))) return
    if (.not. c_associated(c_loc(o%grid%rmu), o%allocation_address(6))) return
    if (.not. c_associated(c_loc(o%grid%rsqm2), o%allocation_address(8))) return
    if (.not. c_associated(c_loc(o%grid%rlatig), o%allocation_address(9))) return
    if (o%state >= 4) then
      if (allocated(o%zmu) .or. c_associated(o%allocation_address(7))) return
    else
      if (.not. allocated(o%zmu)) return
      if (lbound(o%zmu, 1) /= -1 .or. ubound(o%zmu, 1) /= n + 2) return
      if (.not. c_associated(c_loc(o%zmu), o%allocation_address(7))) return
    end if
    do i = 1, 9
      if (i == 7 .and. o%state >= 4) cycle
      if (.not. c_associated(o%allocation_address(i))) return
    end do
    if (lbound(o%row_lengths, 1) /= -1 .or. ubound(o%row_lengths, 1) /= n + 2) return
    if (.not. associated(o%points%first_latitude, o%nfrstlat)) return
    if (.not. associated(o%points%last_latitude, o%nlstlat)) return
    if (.not. associated(o%points%longitude_count, o%row_lengths)) return
    if (.not. associated(o%points%start, o%nsta)) return
    if (.not. associated(o%points%count, o%nonl)) return
    if (any(lbound(o%points%start) /= [-1, 1]) .or. any(ubound(o%points%start) /= [n + ns + 1, ew])) return
    if (any(lbound(o%points%count) /= [-1, 1]) .or. any(ubound(o%points%count) /= [n + ns + 1, ew])) return
    if (lbound(o%points%first_latitude, 1) /= 1 .or. ubound(o%points%first_latitude, 1) /= ns) return
    if (lbound(o%points%last_latitude, 1) /= 1 .or. ubound(o%points%last_latitude, 1) /= ns) return
    if (lbound(o%points%longitude_count, 1) /= -1 .or. ubound(o%points%longitude_count, 1) /= n + 2) return
    if (o%state < 5) then
      if (c_associated(o%halo_address(1)) .or. c_associated(o%halo_address(2))) return
    end if
    valid = .true.
  end function

  logical function points_are_valid(o) result(valid)
    type(native_radiation_transform_storage), target, intent(in) :: o
    integer :: n
    valid = .false.
    if (o%state < 3 .or. o%state > 5) return
    if (.not. associated(o%grid)) return
    n = o%grid%ngptot; if (n < 0) return
    if (.not. allocated(o%grid%gelam) .or. .not. allocated(o%grid%gelat) .or. .not. allocated(o%grid%geslo)) return
    if (.not. allocated(o%grid%geclo) .or. .not. allocated(o%grid%gemu)) return
    if (size(o%grid%gelam) /= n .or. size(o%grid%gelat) /= n .or. size(o%grid%geslo) /= n) return
    if (size(o%grid%geclo) /= n .or. size(o%grid%gemu) /= n) return
    if (.not. c_associated(c_loc(o%grid%gelam), o%allocation_address(10))) return
    if (.not. c_associated(c_loc(o%grid%gelat), o%allocation_address(11))) return
    if (.not. c_associated(c_loc(o%grid%geslo), o%allocation_address(12))) return
    if (.not. c_associated(c_loc(o%grid%geclo), o%allocation_address(13))) return
    if (.not. c_associated(c_loc(o%grid%gemu), o%allocation_address(14))) return
    valid = .true.
  end function

  subroutine cleanup_storage(o)
    type(native_radiation_transform_storage), intent(inout) :: o
    ! No metadata refusal is permitted here: acquisition and collective preflight
    ! have already established the exact local owners on every participant.
    if (o%resolution%resolution /= 0) call trans_release(o%resolution%resolution)
    if (associated(o%grid)) then
      if (allocated(o%grid%rlatig)) deallocate (o%grid%rlatig)
      if (allocated(o%grid%rsqm2)) deallocate (o%grid%rsqm2)
    end if
    if (allocated(o%zmu)) deallocate (o%zmu)
    if (associated(o%grid)) then
      if (allocated(o%grid%rmu)) deallocate (o%grid%rmu)
    end if
    nullify (o%points%first_latitude, o%points%last_latitude, o%points%longitude_count, o%points%start, o%points%count)
    if (allocated(o%nlstlat)) deallocate (o%nlstlat)
    if (allocated(o%nfrstlat)) deallocate (o%nfrstlat)
    if (allocated(o%nptrfrstlat)) deallocate (o%nptrfrstlat)
    if (allocated(o%nonl)) deallocate (o%nonl)
    if (allocated(o%nsta)) deallocate (o%nsta)
    o%resolution%resolution = 0; o%resolution%truncation = 0; o%resolution%row_count = 0
    o%state = 0
    o%points%n_regions_ns = 0; o%points%n_regions_ew = 0
    o%points%my_region_ns = 0; o%points%my_region_ew = 0; o%points%nstencilwide = 0
    o%allocation_address = c_null_ptr; o%halo_address = c_null_ptr
    nullify (o%grid, o%row_lengths)
  end subroutine

  integer(int32) function agree(local) result(global)
    integer(int32), intent(in) :: local
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer :: error
    call c_f_pointer(errno_location(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    call MPI_Allreduce(local, global, 1, MPI_INTEGER, MPI_MAX, MPI_COMM_WORLD, error)
    if (error /= MPI_SUCCESS) call fatal_public_error()
    call ieee_set_status(floating); system_error = saved_error
  end function

  subroutine world_identity(world, rank)
    integer, intent(out) :: world, rank
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer :: error
    call c_f_pointer(errno_location(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    call MPI_Comm_size(MPI_COMM_WORLD, world, error)
    if (error /= MPI_SUCCESS) call fatal_public_error()
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, error)
    if (error /= MPI_SUCCESS) call fatal_public_error()
    call ieee_set_status(floating); system_error = saved_error
  end subroutine

  pure logical function finite_word(x) result(finite)
    real(real64), intent(in) :: x
    finite = iand(transfer(x, 0_int64), int(z'7ff0000000000000', int64)) /= int(z'7ff0000000000000', int64)
  end function

  subroutine save_grid(g, s, o)
    type(native_radiation_grid), intent(in) :: g
    type(saved_grid_scalars), intent(out) :: s
    type(native_radiation_transform_storage), intent(in) :: o
    s%ndglg = g%ndglg
    s%ndlon = g%ndlon
    s%nsmax = g%nsmax
    s%ngptot = g%ngptot
    s%nfrstloff = g%nfrstloff
    s%ndgsl = g%ndgsl
    s%ndgsah = g%ndgsah
    s%ndgenh = g%ndgenh
    s%ndgsal = g%ndgsal
    s%ndgenl = g%ndgenl
    s%ndlonh = g%ndlonh
    s%ndlonm = g%ndlonm
    s%myfrstlat = g%myfrstlat
    s%mylstlat = g%mylstlat
    s%nspec2 = o%nspec2; s%nump = o%nump; s%ngptotg = o%ngptotg; s%ngptotmx = o%ngptotmx
  end subroutine
  subroutine restore_grid(g, s, o)
    type(native_radiation_grid), intent(inout) :: g
    type(saved_grid_scalars), intent(in) :: s
    type(native_radiation_transform_storage), intent(inout) :: o
    g%ndglg = s%ndglg
    g%ndlon = s%ndlon
    g%nsmax = s%nsmax
    g%ngptot = s%ngptot
    g%nfrstloff = s%nfrstloff
    g%ndgsl = s%ndgsl
    g%ndgsah = s%ndgsah
    g%ndgenh = s%ndgenh
    g%ndgsal = s%ndgsal
    g%ndgenl = s%ndgenl
    g%ndlonh = s%ndlonh
    g%ndlonm = s%ndlonm
    g%myfrstlat = s%myfrstlat
    g%mylstlat = s%mylstlat
    o%nspec2 = s%nspec2; o%nump = s%nump; o%ngptotg = s%ngptotg; o%ngptotmx = s%ngptotmx
  end subroutine
end module forecast_live_radiation_setup
