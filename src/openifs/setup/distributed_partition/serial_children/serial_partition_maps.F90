!> Own the selected and operational one-process SUMP calculation.
!! Entries require the parent's admitted global, hydrostatic, scalar platform.
!! The caller establishes nearest-even rounding and gradual underflow; raw
!! nonzero-FPCR and pointer refusals are outside the native typed ABI.
!! Arrays and scalar results use canonical native records. The caller retains
!! the public message/transform context until all partition users are released.
module forecast_serial_partition_maps
  use iso_c_binding, only: c_int, c_int64_t
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_geometry_stream, only: native_geometry_stream, initialize_stream_geometry_metadata, &
                                      release_stream_geometry_metadata
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  use forecast_serial_partition_array_storage, only: allocate_serial_partition_arrays, &
                                            allocate_operational_partition_arrays, allocate_portable_operational_partition_arrays, &
                                                     release_partition_array_phase => release_serial_partition_arrays
  use forecast_operational_serial_partition_children, only: &
    initialize_operational_serial_block_size, initialize_operational_serial_grid_maps, &
    initialize_portable_operational_serial_block_size, initialize_portable_operational_serial_grid_maps
  implicit none
  private
  public :: initialize_serial_partition_maps, initialize_operational_serial_partition_maps
  public :: release_serial_partition_maps, release_serial_partition_arrays
  public :: allocate_serial_partition_arrays, allocate_operational_partition_arrays
  public :: allocate_portable_operational_partition_arrays
  public :: initialize_operational_serial_block_size, initialize_operational_serial_grid_maps
  public :: initialize_portable_operational_serial_block_size, initialize_portable_operational_serial_grid_maps
#include "trans_inq.h"
#include "ini_spec_dist.h"
contains
  !> Initialize T21/L19/P24, with the source-disabled block optimization.
 !! STATE and STREAM own34+2new arrays; GRID keeps live dimensions. CONTROL
 !! and RESOLUTION borrow the root's live public lifetime. LONGITUDES contains
 !! the contiguous physical1:NDGLG prefix, in counts of grid points, no halo.
 !! Return0 complete,1 allocation failure,2 unsupported or occupied input.
  integer(c_int) function initialize_serial_partition_maps(state, grid, stream, control, resolution, longitudes) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(inout) :: grid
    type(native_geometry_stream), intent(inout) :: stream
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(c_int), contiguous, intent(in) :: longitudes(:)
    status = initialize_maps(state, grid, stream, control, resolution, longitudes, .false.)
  end function

  !> Initialize historical T1279/L137/P16opt1 or separate portableP24opt0.
 !! The historical branch queries the actual FIAT maximum thread count.
 !! Both entries preserve source arithmetic, calls, owner order and padding.
  integer(c_int)function initialize_operational_serial_partition_maps(state,grid,stream,control,resolution,longitudes)result(status)
  type(native_distributed_partition), intent(inout) :: state
  type(native_grid_dimensions), intent(inout) :: grid
  type(native_geometry_stream), intent(inout) :: stream
  type(native_transform_control), intent(in) :: control
  type(native_transform_resolution), intent(in) :: resolution
  integer(c_int), contiguous, intent(in) :: longitudes(:)
  status = initialize_maps(state, grid, stream, control, resolution, longitudes, .true.)
  end function

  integer(c_int) function initialize_maps(state, grid, stream, control, resolution, longitudes, operational) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(inout) :: grid
    type(native_geometry_stream), intent(inout) :: stream
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(c_int), contiguous, intent(in) :: longitudes(:)
    logical, intent(in) :: operational
    integer(c_int) :: serial_counts(5), column_wave_count(1), fourier_rows(1)
    integer(c_int) :: wave_numbers(1280), j, wave, start, column_sum, child_status, ignored
    integer(c_int64_t) :: point_sum
    logical :: portable
    status = 2
    if (.not. partition_is_fresh(state)) return
    if (allocated(stream%nbsetlev) .or. allocated(stream%nloeng)) return
    if (control%nproc /= 1 .or. control%myproc /= 1) return
    if (control%nprtrv /= 1 .or. control%nprtrw /= 1 .or. control%nprtrns /= 1) return
    if (control%regions_ns /= 1 .or. control%regions_ew /= 1) return
    if (control%mysetv /= 1 .or. control%mysetw /= 1) return
    if (.not. control%message_ready .or. .not. control%environment_ready) return
    if (resolution%resolution < 1) return
    if (resolution%truncation /= grid%nsmax .or. resolution%row_count /= grid%ndglg) return
    if (size(longitudes) /= grid%ndglg) return
    portable = .false.
    if (operational) then
      if (grid%nsmax /= 1279 .or. grid%nmsmax /= 1279 .or. grid%ncmax /= 1279) return
      if (grid%ndglg /= 2560 .or. grid%ndlon /= 5136 .or. grid%nflevg /= 137) return
      if (grid%ndgsag /= -1 .or. grid%ndgeng /= 2562) return
      if (grid%nproma == 24 .and. grid%loptproma == 0) then
        portable = .true.
      else
        if (grid%nproma /= 16 .or. grid%loptproma /= 1) return
      end if
      point_sum = 0
      do j = 1, grid%ndglg
        if (longitudes(j) < 1 .or. longitudes(j) > grid%ndlon) return
        point_sum = point_sum + int(longitudes(j), c_int64_t)
      end do
      if (point_sum /= 6599680_c_int64_t) return
    else
      if (grid%nsmax /= 21 .or. grid%nmsmax /= 21 .or. grid%ncmax /= 21) return
      if (grid%ndglg /= 32 .or. grid%ndlon /= 64 .or. grid%nflevg /= 19) return
      if (grid%nproma /= 24 .or. grid%loptproma /= 0) return
      if (grid%ndgsag > 1 .or. grid%ndgeng < 32) return
      if (any(longitudes /= 64)) return
    end if
    serial_counts = [control%nprtrv, control%nprtrw, control%nprtrns, control%regions_ns, control%regions_ew]
    status = allocate_phase(0)
    if (status /= 0) goto800
    state%numll(1) = grid%nflevg
    state%numll(2) = 0
    state%nflevl = grid%nflevg
    state%nflevlmx = grid%nflevg
    state%nflsur = grid%nflevg
    state%npsurf(1) = 1
    state%npsp = 1

    call trans_inq(kresol=resolution%resolution, kspec=state%nspec, kspec2=state%nspec2, &
                   kspec2mx=state%nspec2mx, knump=state%nump, kumpp=state%numpp, kpossp=state%npossp, &
                   kptrms=state%nptrms, kallms=state%nallms, kdim0g=state%ndim0g)
    call ini_spec_dist(ksmax=grid%nsmax, ktmax=grid%nsmax, kprtrw=control%nprtrw, &
                       kmysetw=control%mysetw, kprocm=state%nprocm, kumpp=column_wave_count, &
                       kmyms=wave_numbers(1:grid%nsmax + 1))
    state%numcp = column_wave_count(1)
    call trans_inq(kresol=resolution%resolution, kgptot=state%ngptot, &
                   kgptotg=state%ngptot_cap, kgptotmx=state%ngptotmx, kgptotl=state%ngptotl, &
                   kfrstlat=state%nfrstlat, klstlat=state%nlstlat, kfrstloff=state%nfrstloff, &
                   kptrlat=state%nptrlat, kptrfrstlat=state%nptrfrstlat, kptrlstlat=state%nptrlstlat, &
                   kptrfloff=state%nptrfloff, ksta=state%nsta(1:, :), konl=state%nonl(1:, :), ldsplitlat=state%lsplitlat)
    call trans_inq(kresol=resolution%resolution, kultpp=fourier_rows, kptrls=state%nptrls)
    state%ndgll = fourier_rows(1)
    state%ndgsal = 1
    state%ndgunl = 1
    state%ndgenl = state%nlstlat(1) - state%nfrstloff
    state%ndguxl = state%ndgll
    if (state%nfrstlat(1) + state%ndgll > grid%ndgeng) state%ndguxl = grid%ndgeng - state%nfrstlat(1) + 1
    state%myfrstactlat = state%nfrstlat(1)
    state%mylstactlat = state%nlstlat(1)
    state%nptrsv(1) = 1
    state%nptrsv(2) = state%nspec2 + 1
    state%nptrmf(1) = 1
    state%nptrmf(2) = state%nump + 1
    column_sum = 0
    do j = state%nump, 1, -1
      wave = wave_numbers(j)
      column_sum = column_sum + 2*(grid%nsmax + 1 - wave)
    end do
    state%nptrsvf(1) = 1
    state%nptrsvf(2) = column_sum + 1
    do j = 0, max(grid%nsmax, grid%nmsmax)
      state%nspstaf(j) = -999
    end do
    start = 1
    do j = 1, state%nump
      wave = wave_numbers(j)
      state%nspstaf(wave) = start
      start = start + 2*(grid%nsmax + 1 - wave)
    end do
    state%nptrll(1) = 1
    state%nptrll(2) = grid%nflevg + 1
    state%nbsetsp = 1
    do j = 1, grid%nflevg
      state%nbsetlev(j) = 1
    end do

    status = initialize_stream_geometry_metadata(stream, control%myproc, control%nproc, state%nbsetsp, &
                                                 grid%nsmax, state%nbsetlev, longitudes)
    if (status /= 0) goto800
    state%nspec2v = state%nptrsv(2) - state%nptrsv(1)
    state%nspec2vf = state%nptrsvf(2) - state%nptrsvf(1)
    state%nspec2v_nh = 0
    if (operational) then
      if (portable) then
        status = initialize_portable_operational_serial_block_size(state, grid)
      else
        status = initialize_operational_serial_block_size(state, grid)
      end if
      if (status /= 0) goto800
    else
      state%npromm = grid%nproma
      state%npromnh = 1
    end if
    state%ngpblks = (state%ngptot - 1)/grid%nproma + 1
    status = allocate_phase(1)
    if (status /= 0) goto800
    state%ngptotg = state%ngptot
    status = allocate_phase(2)
    if (status /= 0) goto800
    if (operational) then
      if (portable) then
        status = initialize_portable_operational_serial_grid_maps(state, grid, longitudes)
      else
        status = initialize_operational_serial_grid_maps(state, grid, longitudes)
      end if
      if (status /= 0) goto800
    else
      call fill_selected_grid_maps(state, grid)
    end if
    ! Added native region IDs follow from the validated live one-region context.
    state%my_region_ns = 1
    state%my_region_ew = 1
    state%phase = 7
    state%borrowed_resolution = resolution%resolution
    status = 0
    return
800 child_status = status
    ignored = release_serial_partition_maps(state, stream)
    status = child_status
  contains
    integer(c_int) function allocate_phase(phase) result(code)
      integer(c_int), intent(in) :: phase
      if (operational) then
        if (portable) then
          code = allocate_portable_operational_partition_arrays(state, grid, serial_counts, phase)
        else
          code = allocate_operational_partition_arrays(state, grid, serial_counts, phase)
        end if
      else
        code = allocate_serial_partition_arrays(state, grid, serial_counts, phase)
      end if
    end function
  end function

  !> Source-selected integer workspace and maps; no file or numerical reference.
  subroutine fill_selected_grid_maps(state, grid)
    type(native_distributed_partition), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: grid
    integer(c_int) :: global_indices(64, 32)
    integer(c_int) :: j, row, column, point, global_point, block, cell
    do j = 1, state%nflevl
      state%mylevs(j) = j
    end do
    do j = 1, state%ndgenl
      state%mylats(j) = j
    end do
    do row = 1, grid%ndglg
      do column = 1, grid%ndlon
        global_indices(column, row) = 0
      end do
    end do
    point = 1
    do row = 1, grid%ndglg
      do column = 1, grid%ndlon
        global_indices(column, row) = point
        point = point + 1
      end do
    end do
    do point = 1, state%ngptotg
      state%nglobalproc(point) = 0
    end do
    point = 0
    do row = 1, grid%ndglg
      do column = 1, grid%ndlon
        point = point + 1
        global_point = global_indices(column, row)
        state%nglobalindex(point) = global_point
        state%nglobalat(point) = row
        state%nglobalproc(global_point) = 1
        state%nlocalindex(global_point) = point
      end do
    end do
    do block = 1, state%ngpblks
      do cell = 1, grid%nproma
        state%nlatgpp(cell, block) = -99999
        state%nlongpp(cell, block) = -99999
      end do
    end do
    point = 0
    do row = 1, grid%ndglg
      do column = 1, grid%ndlon
        point = point + 1
        block = (point - 1)/grid%nproma + 1
        cell = point - (block - 1)*grid%nproma
        state%nlatgpp(cell, block) = row
        state%nlongpp(cell, block) = column
      end do
    end do
  end subroutine

  !> Release only34array owners in the source reverse-phase order2,1,0.
 !! Partial scalar results remain unchanged; lifetime metadata becomes fresh.
  integer(c_int) function release_serial_partition_arrays(state) result(status)
    type(native_distributed_partition), intent(inout) :: state
    integer(c_int) :: code
    status = release_partition_array_phase(state, 2_c_int)
    code = release_partition_array_phase(state, 1_c_int); status = ior(status, code)
    code = release_partition_array_phase(state, 0_c_int); status = ior(status, code)
    state%phase = 0
    state%borrowed_resolution = 0
  end function

  !> Original combined release: stream metadata first, then phases2,1,0.
 !! Only the two metadata owners and34partition owners are released.
  integer(c_int) function release_serial_partition_maps(state, stream) result(status)
    type(native_distributed_partition), intent(inout) :: state
    type(native_geometry_stream), intent(inout) :: stream
    call release_stream_geometry_metadata(stream)
    status = release_serial_partition_arrays(state)
  end function

  logical function partition_is_fresh(state) result(fresh)
    type(native_distributed_partition), intent(in) :: state
    fresh = .false.
    if (state%phase /= 0 .or. state%borrowed_resolution /= 0) return
    if (allocated(state%numll)) return
    if (allocated(state%npsurf)) return
    if (allocated(state%numpp)) return
    if (allocated(state%nprocm)) return
    if (allocated(state%nptrms)) return
    if (allocated(state%npossp)) return
    if (allocated(state%nallms)) return
    if (allocated(state%ndim0g)) return
    if (allocated(state%nptrls)) return
    if (allocated(state%nptrsv)) return
    if (allocated(state%nptrsvf)) return
    if (allocated(state%nptrmf)) return
    if (allocated(state%nspstaf)) return
    if (allocated(state%nptrll)) return
    if (allocated(state%nsta)) return
    if (allocated(state%nonl)) return
    if (allocated(state%nptrfrstlat)) return
    if (allocated(state%nptrlstlat)) return
    if (allocated(state%nptrlat)) return
    if (allocated(state%lsplitlat)) return
    if (allocated(state%nfrstlat)) return
    if (allocated(state%nlstlat)) return
    if (allocated(state%nbsetlev)) return
    if (allocated(state%ndlunl)) return
    if (allocated(state%ndluxl)) return
    if (allocated(state%ngptotl)) return
    if (allocated(state%nlongpp)) return
    if (allocated(state%nlatgpp)) return
    if (allocated(state%mylevs)) return
    if (allocated(state%mylats)) return
    if (allocated(state%nglobalindex)) return
    if (allocated(state%nglobalat)) return
    if (allocated(state%nglobalproc)) return
    if (allocated(state%nlocalindex)) return
    fresh = .true.
  end function
end module forecast_serial_partition_maps
