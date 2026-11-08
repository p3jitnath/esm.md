!> Own the serial transform, cutoff and partition call sequence.
!! This layer composes existing native children and public library services.
module forecast_serial_partition
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_serial_partition_maps, only: initialize_serial_partition_maps, &
                                            initialize_operational_serial_partition_maps, release_serial_partition_arrays
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_geometry_stream, only: native_geometry_stream, release_stream_geometry_metadata
  use forecast_global_grid_cutoffs, only: native_global_grid_cutoffs, &
                                          initialize_global_grid_cutoffs, release_global_grid_cutoffs
  use forecast_public_transform, only: native_transform_control, native_transform_resolution, &
                                       initialize_public_transform_messages, initialize_serial_transform_environment, &
                            initialize_transform_resolution, release_transform_environment_metadata, finish_public_transform_context
  use forecast_transform_configuration, only: require_empty_transform_group, require_operational_transform_group
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: create_owned_serial_geometry_partition, release_owned_serial_geometry_partition
  public :: release_serial_partition_arrays
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
!> Create a serial public context, its global cutoffs and native SUMP owners.
!! PARTITION, DIMENSIONS, STREAM, CONTROL, RESOLUTION and CUTOFFS are native
!! records with INOUT intent. They remain at their caller-owned addresses.
!! Only DIMENSIONS%NPROMA can change. Physical longitudes has contiguous INT32
!! shape(NDGLG), starts at physical row1 and contains grid-point counts.
!! CONSTANTS is read-only; its RA is the sphere radius in metres. TEXT is the
!! original bounded ASCII input. OPERATIONAL selects T1279/L137; false selects
!! T21/L19. Global hydrostatic scalar configuration is a caller precondition.
!! Counts and indices are unitless. Nearest-even rounding with gradual
!! underflow is established by the caller; no extra FP mode test is added.
!! All34 partition,12 stream and3 cutoff owners must be absent. A matching
!! prestarted public message context is adopted into this owner's lifetime.
!! Status0 is ready,1 is allocation failure,2 is unsupported input and3 is a
!! returned external-service failure. Failure releases all acquired owners.
  integer(c_int) function create_owned_serial_geometry_partition(partition, dimensions, stream, control, &
                                              resolution, cutoffs, constants, text, physical_longitudes, operational) result(status)
    type(native_distributed_partition), intent(inout) :: partition
    type(native_grid_dimensions), intent(inout) :: dimensions
    type(native_geometry_stream), intent(inout) :: stream
    type(native_transform_control), intent(inout) :: control
    type(native_transform_resolution), intent(inout) :: resolution
    type(native_global_grid_cutoffs), intent(inout) :: cutoffs
    type(forecast_physical_constants), intent(in) :: constants
    character(len=*), intent(in) :: text
    integer(c_int), contiguous, intent(in) :: physical_longitudes(:)
    logical, intent(in) :: operational
    integer(c_int) :: ignored, original_nproma, j
    logical :: cutoffs_started
    status = 2_c_int
    if (partition%phase /= 0 .or. has_partition_owners(partition)) return
    if (.not. fresh_owned_stream(stream)) return
    if (allocated(cutoffs%nmen) .or. allocated(cutoffs%nmeng) .or. allocated(cutoffs%ndglu)) return
    if (control%environment_ready .or. resolution%resolution /= 0) return
    if (allocated(control%n_regions) .or. allocated(control%ngpset2pe)) return
    if (control%nproc /= 1 .or. control%myproc /= 1) return
    if (control%nprgpns /= 1 .or. control%nprgpew /= 1 .or. control%nprtrw /= 1) return
    if (control%nprtrv /= 1 .or. control%nprtrns /= 1 .or. control%mysetv /= 1 .or. control%mysetw /= 1) return
    if (len(text) < 1 .or. len(text) > 262144) return
    if (dimensions%ncmax /= dimensions%nsmax .or. dimensions%nmsmax /= dimensions%nsmax) return
    if (operational) then
      if (dimensions%nsmax /= 1279 .or. dimensions%ndglg /= 2560 .or. dimensions%nflevg /= 137) return
      if (dimensions%ndlon /= 5136) return
      if (.not. ((dimensions%nproma == 16 .and. dimensions%loptproma == 1) .or. &
                 (dimensions%nproma == 24 .and. dimensions%loptproma == 0))) return
    else
      if (dimensions%nsmax /= 21 .or. dimensions%ndglg /= 32 .or. dimensions%nflevg /= 19) return
      if (dimensions%ndlon /= 64 .or. dimensions%nproma /= 24 .or. dimensions%loptproma /= 0) return
    end if
    if (size(physical_longitudes) /= dimensions%ndglg) return
    do j = 1, dimensions%ndglg
      if (physical_longitudes(j) < 1 .or. physical_longitudes(j) > dimensions%ndlon) return
    end do
    if (transfer(constants%ra, 0_c_int64_t) /= transfer(6371229.0_c_double, 0_c_int64_t)) return
    status = require_empty_transform_group(text, 0_c_int)
    if (status /= 0) return
    if (operational) then
      status = require_operational_transform_group(text)
    else
      status = require_empty_transform_group(text, 1_c_int)
    end if
    if (status /= 0) return
    ! The original serial parents do not consume NAMPAR0 or the distributed
    ! vector group. Actual one-process public state establishes this contract.
    original_nproma = dimensions%nproma
    cutoffs_started = .false.
    call initialize_serial_control_defaults(control, constants)
    if (.not. control%message_ready) then
      status = initialize_public_transform_messages(control, 1_c_int)
      if (status /= 0) goto 900
    end if
    ! Message initialization returns the actual world and one-based rank.
    status = 2_c_int
    if (control%nproc /= 1 .or. control%myproc /= 1) goto 900
    status = initialize_serial_transform_environment(control, text)
    if (status /= 0) goto 900
    call initialize_partition_scalar_defaults(partition)
    call initialize_owned_stream_scalar_defaults(stream)
    resolution%truncation = dimensions%nsmax
    resolution%row_count = dimensions%ndglg
    status = initialize_transform_resolution(control, resolution, text, physical_longitudes, operational)
    if (status /= 0) goto 900
    status = initialize_global_grid_cutoffs(cutoffs, dimensions, resolution%resolution, 1_c_int, 1_c_int)
    cutoffs_started = status == 0
    if (status /= 0) goto 900
    if (operational) then
      status = initialize_operational_serial_partition_maps(partition, dimensions, stream, control, resolution, physical_longitudes)
    else
      status = initialize_serial_partition_maps(partition, dimensions, stream, control, resolution, physical_longitudes)
    end if
    if (status /= 0) goto 900
    return
900 continue
    ! The cutoff child cleans its own partial allocation when it returns failure.
    if (cutoffs_started) call release_global_grid_cutoffs(cutoffs)
    ignored = release_owned_serial_geometry_partition(partition, stream, control, resolution)
    dimensions%nproma = original_nproma
  end function
!> Release the34 partition arrays, metadata and public lifetime in source order.
!! All arguments are INOUT native records. The caller first releases the three
!! cutoff arrays and the three stream value arrays VAH,VBH,RLATIG. The other
!! absent stream owners remain absent under this qualified serial composition.
!! Already-released partition arrays are allowed. This function ends a live
!! public message context once, then clears the native public resolution handle.
!! Status0 means complete and3 means an external release returned an error.
!! Incoming IEEE status and errno are preserved through the complete release.
  integer(c_int) function release_owned_serial_geometry_partition(partition, stream, control, resolution) result(status)
    type(native_distributed_partition), intent(inout) :: partition
    type(native_geometry_stream), intent(inout) :: stream
    type(native_transform_control), intent(inout) :: control
    type(native_transform_resolution), intent(inout) :: resolution
    type(ieee_status_type) :: saved_floating_status
    integer(c_int), pointer, volatile :: error_value
    integer(c_int) :: saved_errno, ignored, error
    call c_f_pointer(errno_address(), error_value)
    saved_errno = error_value
    call ieee_get_status(saved_floating_status)
    ignored = release_serial_partition_arrays(partition)
    call release_stream_geometry_metadata(stream)
    ignored = release_transform_environment_metadata(control)
    status = 0_c_int
    if (control%message_ready) then
      ignored = finish_public_transform_context(control, resolution, error)
      if (ignored /= 0 .or. error /= 0) status = 3_c_int
    end if
    resolution%resolution = 0_c_int
    call ieee_set_status(saved_floating_status)
    error_value = saved_errno
  end function
!> Establish the controls written by the original fresh serial sidecar owner.
!! The nine admitted process/set controls are already one. A prestarted message
!! lifetime stays live; the two region owners must be absent.
  subroutine initialize_serial_control_defaults(control, constants)
    type(native_transform_control), intent(inout) :: control
    type(forecast_physical_constants), intent(in) :: constants
    control%nprintlev = 0_c_int
    control%ncombflen = 1800000_c_int
    control%lmpoff = 0_c_int
    control%lsync_trans = 0_c_int
    control%leq_regions = 1_c_int
    control%ntrans_sync_level = 0_c_int
    control%nopt_memory = 1_c_int
    control%npromatr = 0_c_int
    control%nepromatr = 0_c_int
    control%nmax_resol = 0_c_int
    control%lalloperm = 0_c_int
    control%lmono_trans = 0_c_int
    control%rdistr_e = 0.0_c_double
    control%ra = constants%ra
    control%regions_ns = 0_c_int
    control%regions_ew = 0_c_int
    control%myregion = 0_c_int
    control%myregion_pe = 0_c_int
    control%luseflt = 0_c_int
    control%luserpnm = 0_c_int
    control%lkeeprpnm = 0_c_int
    control%lfftw = 0_c_int
    control%nulout = 6_c_int
    control%nulerr = 0_c_int
    control%lsplit = 1_c_int
  end subroutine
!> Establish only the named scalar part of the original fresh calloc owner.
  subroutine initialize_partition_scalar_defaults(partition)
    type(native_distributed_partition), intent(inout) :: partition
    partition%phase = 0_c_int
    partition%borrowed_resolution = 0_c_int
    partition%npsp = 0_c_int
    partition%nspec2v = 0_c_int
    partition%nspec2vf = 0_c_int
    partition%nspec2vddh = 0_c_int
    partition%nspec2v_nh = 0_c_int
    partition%nbsetsp = 0_c_int
    partition%nfrstloff = 0_c_int
    partition%myfrstactlat = 0_c_int
    partition%mylstactlat = 0_c_int
    partition%nptrfloff = 0_c_int
    partition%nump = 0_c_int
    partition%numcp = 0_c_int
    partition%nspec = 0_c_int
    partition%nspec2 = 0_c_int
    partition%nspec2mx = 0_c_int
    partition%nflevl = 0_c_int
    partition%nflevlmx = 0_c_int
    partition%nflsur = 0_c_int
    partition%ndgll = 0_c_int
    partition%ndgsal = 0_c_int
    partition%ndgenl = 0_c_int
    partition%ndguxl = 0_c_int
    partition%ndgunl = 0_c_int
    partition%ngptot = 0_c_int
    partition%ngptotg = 0_c_int
    partition%ngptotmx = 0_c_int
    partition%ngptot_cap = 0_c_int
    partition%ngpblks = 0_c_int
    partition%npromm = 0_c_int
    partition%npromnh = 0_c_int
    partition%my_region_ns = 0_c_int
    partition%my_region_ew = 0_c_int
  end subroutine
!> Establish the19 source scalar defaults without touching payload storage.
  subroutine initialize_owned_stream_scalar_defaults(stream)
    type(native_geometry_stream), intent(inout) :: stream
    stream%nundef = 0_c_int
    stream%nulerr = 0_c_int
    stream%nulout = 0_c_int
    stream%myproc = 0_c_int
    stream%nproc = 0_c_int
    stream%nrealen = 0_c_int
    stream%nintlen = 0_c_int
    stream%nbsetsp = 0_c_int
    stream%nflevg = 0_c_int
    stream%nsmax = 0_c_int
    stream%ndglg = 0_c_int
    stream%nfprgpl = 0_c_int
    stream%nfprgpg = 0_c_int
    stream%nfprgplx = 0_c_int
    stream%imaxgrid = 0_c_int64_t
    stream%imaxspec2g = 0_c_int64_t
    stream%rpi = 0.0_c_double
    stream%sipr = 0.0_c_double
    stream%lifs_internal = .false.
  end subroutine
  logical function fresh_owned_stream(stream) result(fresh)
    type(native_geometry_stream), intent(in) :: stream
    fresh = .true.
    fresh = fresh .and. .not. allocated(stream%nbsetlev)
    fresh = fresh .and. .not. allocated(stream%nloeng)
    fresh = fresh .and. .not. allocated(stream%vah)
    fresh = fresh .and. .not. allocated(stream%vbh)
    fresh = fresh .and. .not. allocated(stream%rlatig)
    fresh = fresh .and. .not. allocated(stream%numprocfp)
    fresh = fresh .and. .not. allocated(stream%nfpmax)
    fresh = fresh .and. .not. allocated(stream%msatid)
    fresh = fresh .and. .not. allocated(stream%mseries)
    fresh = fresh .and. .not. allocated(stream%minst)
    fresh = fresh .and. .not. allocated(stream%mchan)
    fresh = fresh .and. .not. allocated(stream%rcwn)
  end function
  logical function has_partition_owners(partition) result(live)
    type(native_distributed_partition), intent(in) :: partition
    live = .false.
    live = live .or. allocated(partition%numll)
    live = live .or. allocated(partition%npsurf)
    live = live .or. allocated(partition%numpp)
    live = live .or. allocated(partition%nprocm)
    live = live .or. allocated(partition%nptrms)
    live = live .or. allocated(partition%npossp)
    live = live .or. allocated(partition%nallms)
    live = live .or. allocated(partition%ndim0g)
    live = live .or. allocated(partition%nptrls)
    live = live .or. allocated(partition%nptrsv)
    live = live .or. allocated(partition%nptrsvf)
    live = live .or. allocated(partition%nptrmf)
    live = live .or. allocated(partition%nspstaf)
    live = live .or. allocated(partition%nptrll)
    live = live .or. allocated(partition%nsta)
    live = live .or. allocated(partition%nonl)
    live = live .or. allocated(partition%nptrfrstlat)
    live = live .or. allocated(partition%nptrlstlat)
    live = live .or. allocated(partition%nptrlat)
    live = live .or. allocated(partition%lsplitlat)
    live = live .or. allocated(partition%nfrstlat)
    live = live .or. allocated(partition%nlstlat)
    live = live .or. allocated(partition%nbsetlev)
    live = live .or. allocated(partition%ndlunl)
    live = live .or. allocated(partition%ndluxl)
    live = live .or. allocated(partition%ngptotl)
    live = live .or. allocated(partition%nlongpp)
    live = live .or. allocated(partition%nlatgpp)
    live = live .or. allocated(partition%mylevs)
    live = live .or. allocated(partition%mylats)
    live = live .or. allocated(partition%nglobalindex)
    live = live .or. allocated(partition%nglobalat)
    live = live .or. allocated(partition%nglobalproc)
    live = live .or. allocated(partition%nlocalindex)
  end function
end module forecast_serial_partition
