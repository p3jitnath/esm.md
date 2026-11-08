!> Own the complete MODEL Fullpos setup with native records and arrays.
!! Fullpos prepares forecast fields for saved output. No weather field is changed.
module forecast_runtime_fullpos_factory
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yomfpc, only: tnamfpobj, tnamfpl
  use yomfpf, only: tnamfpf
  use yomfpg, only: tnamfpv
  use yomfpgeo, only: tfpgeo
  use type_faoph, only: tfaoph
  use type_fpofn, only: tfpofn
  use forecast_fullpos_state_types, only: native_fullpos_state, native_fullpos_data
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_stream, only: native_geometry_stream
  use forecast_runtime_output_configuration, only: native_runtime_output_configuration, initialize_runtime_output_configuration
  use forecast_output_runtime_bindings, only: native_output_metadata_namespace
  use forecast_output_request_preparation, only: native_output_common_metadata
  use forecast_fullpos_configuration, only: initialize_native_fullpos_configuration
  use forecast_fullpos_distribution, only: initialize_native_fullpos_distribution
  use forecast_fullpos_model_geometry, only: initialize_native_fullpos_model_geometry, release_native_fullpos_model_geometry
 use forecast_fullpos_vertical,only:initialize_native_fullpos_vertical_configuration,initialize_native_fullpos_vertical,release_native_fullpos_vertical
  use forecast_fullpos_output_control, only: initialize_native_fullpos_output_control, release_native_fullpos_output_control
 use forecast_fullpos_file_metadata,only:fullpos_field_metadata_controls,native_fullpos_file_metadata,native_fullpos_grib_code_targets,initialize_fullpos_file_metadata
 use forecast_native_fullpos_grib_codes,only:native_fullpos_grib_code_owner,initialize_fullpos_grib_code_owner,bind_fullpos_grib_code_targets,clear_fullpos_grib_code_targets
  use forecast_native_fullpos_descriptor_defaults, only: initialize_fullpos_field_descriptor_defaults
  use forecast_native_fullpos_field_descriptors, only: initialize_runtime_fullpos_field_descriptors
  use forecast_fullpos_upstream_controls, only: native_fullpos_upstream_values, make_fullpos_upstream_controls
 use forecast_fullpos_io_and_filters,only:native_fullpos_output_names,initialize_fullpos_io_scheme,initialize_fullpos_io_handler,initialize_fullpos_filter_controls,initialize_fullpos_filters
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  implicit none
  private
  public :: initialize_runtime_fullpos_factory, release_runtime_fullpos_factory
  interface
    subroutine public_statistics(event, switch) bind(C, name='gstats_')
      import c_int
      integer(c_int), intent(in) :: event, switch
    end subroutine
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
#include "get_current.h"
#include "trans_inq.h"
contains
  !> Create one complete Fullpos state at its final allocation address.
 !! MODEL owns the produced initial geometry, vertical arrays and field metadata.
 !! Its stream is the only changed upstream component: three counts and two owners.
 !! Every rank enters with the same live message/transform protocol and complete
 !! MODEL. Readonly admission and every child result are agreed before continuing.
 !! STATE must be unallocated. DATA,CONFIGURATION,METADATA,COMMON and optional
 !! final metadata outputs are caller-owned TARGET records and stay at fixed addresses.
 !! Text is the actual1:262144-character configuration; budget bounds new arrays.
 !! The four explicit earlier controls have source units/counts and character
 !! lengths256/8. REGIONAL_ANGLES contains ELATC,ELONC,ELON0,ELAT0 in radians.
 !! No values are supplied for absent upstream producers.
 !! Success0 publishes all records once. Any failure retains caller records and
 !! leaves STATE unallocated. CHILD_STATUS is the agreed source child status;
 !! FAILED_STAGE identifies the last attempted stage. No forecast step is run.
 integer(int32)function initialize_runtime_fullpos_factory(state,data,model,text,configuration,metadata,common,budget,child_status,failed_stage, &
     nprintlev,satellite_count,climate_output,surfex_extension,regional_angles,output_levels,output_file_metadata,grid_prefixes,spectral_path)result(status)
  type(native_fullpos_state), allocatable, target, intent(inout) :: state
  type(native_fullpos_data), target, intent(inout) :: data
  type(native_operational_model_configuration), target, intent(inout) :: model
  character(*), intent(in) :: text
  type(native_runtime_output_configuration), target, intent(inout) :: configuration
  type(native_output_metadata_namespace), target, intent(inout) :: metadata
  type(native_output_common_metadata), intent(inout) :: common
  integer(int64), intent(in) :: budget
  integer(int32), intent(out) :: child_status, failed_stage
  integer(int32), optional, intent(in) :: nprintlev, satellite_count
  character(*), optional, intent(in) :: climate_output, surfex_extension, grid_prefixes, spectral_path
  real(real64), optional, intent(in) :: regional_angles(4)
  type(tnamfpl), optional, target, intent(inout) :: output_levels
  type(native_fullpos_file_metadata), optional, target, intent(inout) :: output_file_metadata
  type(native_fullpos_state), allocatable, target :: pending
  type(native_runtime_output_configuration), target :: pending_configuration
  type(native_output_metadata_namespace), target :: pending_metadata
  type(native_output_common_metadata) :: pending_common
  type(native_fullpos_file_metadata), target :: file_metadata
  type(native_fullpos_grib_code_owner), target :: code_owner
  type(native_fullpos_grib_code_targets) :: code_targets
  type(fullpos_field_metadata_controls) :: controls
  type(native_fullpos_upstream_values) :: upstream
  type(native_fullpos_output_names) :: names
  type(tnamfpobj) :: object
  type(tnamfpl) :: levels
  type(tnamfpv) :: vertical_namelist
  type(tnamfpf) :: filter_controls
  type(tfaoph) :: fa_record_extent
  type(tfpofn) :: name_record_extent
  character(180), allocatable :: filename(:), climate_filename(:), surfex_filename(:)
  type(ieee_status_type) :: reached
  integer(c_int), pointer, volatile :: error_number
  integer(int32) :: child, stage, ignored, old_stream_counts(3), reached_errno
  integer :: allocation_status, j, k, physical, global_points, processes, rank, nlayers
  integer(int64) :: owned_bytes, remaining, io_bytes
  logical :: profile_open, stream_saved
  status = 2; child_status = 2; failed_stage = 1
  profile_open = .false.; stream_saved = .false.
  ! These outer producer identities are collective-entry preconditions.
  if (.not. associated(model%initial)) return
  if (.not. allocated(model%initial%geometry)) return
  if (.not. model%initial%geometry%transform_control%message_ready) return
  stage = 1; child = 2
  admission: block
    if (.not. model%ready .or. .not. model%initial%ready) exit admission
    if (.not. associated(model%partition)) exit admission
    if (.not. associated(model%partition, model%initial%geometry%partition)) exit admission
    if (.not. allocated(model%initial%prefix)) exit admission
    if (.not. associated(model%initial%geometry%vertical)) exit admission
    if (.not. model%initial%geometry%initialized .or. model%partition%phase /= 7) exit admission
    if (allocated(state) .or. associated(data%yfpos)) exit admission
    if (configuration%ready .or. associated(configuration%metadata)) exit admission
    if (.not. fresh_fullpos_data(data)) exit admission
    if (allocated(model%initial%geometry%stream%nfpmax) .or. allocated(model%initial%geometry%stream%numprocfp)) exit admission
    if (.not. present(nprintlev) .or. .not. present(satellite_count)) exit admission
    if (.not. present(climate_output) .or. .not. present(surfex_extension) .or. .not. present(regional_angles)) exit admission
    if (.not. present(grid_prefixes) .or. .not. present(spectral_path)) exit admission
    if (len(text) < 1 .or. len(text) > 262144 .or. budget < 1048576_int64) exit admission
    if (len(climate_output) /= 256 .or. len(surfex_extension) /= 8) exit admission
    if (len(grid_prefixes) /= 10 .or. len(spectral_path) /= 200) exit admission
    if (.not. allocated(model%partition%nglobalproc)) exit admission
    if (.not. allocated(model%initial%geometry%spherical%blocked%spherical_views)) exit admission
  if (.not. allocated(model%initial%geometry%vertical%vah) .or. .not. allocated(model%initial%geometry%vertical%vbh)) exit admission
    nlayers = model%initial%geometry%dimensions%nflevg
    if (nlayers < 1 .or. nlayers > 200) exit admission
    global_points = size(model%partition%nglobalproc)
    processes = model%initial%geometry%transform_control%nproc
    rank = model%initial%geometry%transform_control%myproc
    if (global_points < 1 .or. processes < 1 .or. processes > 4096 .or. rank < 1 .or. rank > processes) exit admission
    if (model%initial%geometry%stream%nproc /= processes) exit admission
    if(ubound(model%initial%geometry%vertical%vah,1)<nlayers.or.ubound(model%initial%geometry%vertical%vbh,1)<nlayers)exit admission
    child = 0
  end block admission
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  stage = 2
  allocate (pending, stat=allocation_status)
  child = 0; if (allocation_status /= 0) child = 1
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  call initialize_fresh_fullpos_named_values(pending)
  child = initialize_fullpos_field_descriptor_defaults(pending%yafn)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  stage = 3
  child = make_fullpos_upstream_controls(model, nprintlev, satellite_count, climate_output, surfex_extension, controls, upstream)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  child = initialize_fullpos_file_metadata(text, controls, file_metadata)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  child = initialize_fullpos_grib_code_owner(code_owner)
  if (child == 0) child = bind_fullpos_grib_code_targets(code_owner, code_targets)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  call public_statistics(2001_c_int, 0_c_int); profile_open = .true.
  stage = 4
  pending_metadata%ncycle = metadata%ncycle
 child=initialize_runtime_output_configuration(text,model%initial%controls%namespace%nconf,model%initial%controls%namespace%lecmwf,pending_configuration,pending_metadata)
 if(child==0)child=initialize_native_fullpos_configuration(text,model,pending_configuration,object,pending%ynamfpsci,pending%ynamfpint,levels,pending_common,file_metadata%nvgrib)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  stage = 5
  child = 2
  if (model%initial%controls%namespace%cnppath == ' ' .and. model%initial%controls%namespace%cfdirlst == ' ') &
    child = initialize_native_fullpos_output_control(object, model%initial%controls%namespace%cfpncf, pending%yfpcnt)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  stage = 6
  child = update_fullpos_transform(model%initial%geometry%transform_resolution%resolution)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  stage = 7
  allocate (pending%yfpgeometry%yfpusergeo(1), stat=allocation_status)
  child = 0; if (allocation_status /= 0) child = 1
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
 child=initialize_native_fullpos_model_geometry(model%initial%geometry,model%initial%constants,object%cfpdom(1),regional_angles,0_int32,pending%ynamfpsci%nfpboyd,pending%yfpgeometry%yfpusergeo(1))
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  pending%yfpgeometry%lfposhor = .false.
  pending%yfpgeometry%nmdlresol = model%initial%geometry%transform_resolution%resolution
  pending%yfpgeometry%yfpgeo%nfprgpg = global_points
  pending%yfpgeometry%yfpgeo_dep%nfprgpg = global_points
  stage = 8
 child=initialize_native_fullpos_distribution(model%partition%nglobalproc,processes,rank,-abs(model%initial%geometry%dimensions%nproma),pending%yfpgeometry%yfpgeo,budget)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
 owned_bytes=4_int64*(size(pending%yfpgeometry%yfpgeo%nfprgpnum,kind=int64)+size(pending%yfpgeometry%yfpgeo%nfprgpind,kind=int64)+size(pending%yfpgeometry%yfpgeo%nfpend,kind=int64))
  remaining = budget - owned_bytes
  stage = 9
  child = allocate_and_copy_fullpos_map_factor(pending, model, remaining)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  remaining = remaining - 8_int64*size(pending%yfpgeometry%yfpgeo%rfpgm, kind=int64)
  stage = 10
 child=initialize_native_fullpos_vertical_configuration(text,model%initial%geometry%vertical%vah(0:nlayers),model%initial%geometry%vertical%vbh(0:nlayers),vertical_namelist)
 if(child==0)child=initialize_native_fullpos_vertical(text,vertical_namelist%fpvalh(0:nlayers),vertical_namelist%fpvbh(0:nlayers),model%initial%geometry%vertical%vp00,model%initial%controls%namespace%liolevg/=0,pending%yfpvab,remaining)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  remaining = remaining - 8_int64*(8_int64*nlayers + 5_int64)
  stage = 11
  ! Count native I/O record extents without reading their source-unwritten values.
  io_bytes = int(storage_size(fa_record_extent), int64)/8_int64 + int(storage_size(name_record_extent), int64)/8_int64
  io_bytes = io_bytes + 4_int64*(int(global_points, int64) + 1_int64)
  child = 0
  if (540_int64 + io_bytes > remaining) child = 2
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  allocate (filename(1), stat=allocation_status); if (allocation_status /= 0) child = 1
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  allocate (climate_filename(1), stat=allocation_status); child = 0; if (allocation_status /= 0) child = 1
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  allocate (surfex_filename(1), stat=allocation_status); child = 0; if (allocation_status /= 0) child = 1
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
 child=initialize_fullpos_io_scheme(text,object%nfpgrib,pending%ynamfpsci%nfpsurfex,controls%larpegef,upstream%experiment,upstream%climate_output,upstream%surfex_extension,object%cfpdir,object%cfpdom(1),names)
  if (child == 0) then
    filename = names%filename; climate_filename = names%climate_filename; surfex_filename = names%surfex_filename
  end if
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  remaining = remaining - 540_int64
  stage = 12
 old_stream_counts=[model%initial%geometry%stream%nfprgpl,model%initial%geometry%stream%nfprgpg,model%initial%geometry%stream%nfprgplx]
  stream_saved = .true.
 child=initialize_fullpos_io_handler(names,pending%yfpgeometry,model%initial%geometry%stream,upstream%experiment,grid_prefixes,spectral_path,pending%yfpioh)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  remaining = remaining - io_bytes
  stage = 13
 child=initialize_runtime_fullpos_field_descriptors(text,model,pending_configuration,pending%yafn,pending%ynamfpsci,controls,file_metadata,code_targets)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  stage = 14
  child = initialize_fullpos_filter_controls(text, 0_int32, controls%lelam, filter_controls)
 if(child==0)child=initialize_fullpos_filters(text,model,pending_configuration,filter_controls,nlayers,upstream%snow_levels,upstream%satellite_count,model%initial%geometry%dimensions%nsmax,model%initial%geometry%configuration%values%rstret,pending_common,pending%yfpfilters,remaining,file_metadata%nvgrib)
  child_status = agree_distributed_partition_status(model%initial%geometry%transform_control, child)
  if (child_status /= 0) goto900
  call public_statistics(2001_c_int, 1_c_int); profile_open = .false.
  call clear_fullpos_grib_code_targets(code_targets)
  ! Fixed native records contain no aliases into their private source temporaries.
  metadata = pending_metadata
  configuration%namfpc = pending_configuration%namfpc
  configuration%metadata => metadata
  configuration%ready = .true.
  common = pending_common
  if (present(output_levels)) output_levels = levels
  if (present(output_file_metadata)) output_file_metadata = file_metadata
  data%lfpupdsuw = .true.; data%lfpupdcli = .true.
  data%yfpsuw%lwlan04 = .false.; data%yfpsuw%lwlan12 = .false.
  data%yfpsuw%lwsea04 = .false.; data%yfpsuw%lwsea12 = .false.
  call move_alloc(pending, state)
  data%yfpos => state
  if (allocated(filename)) deallocate (filename)
  if (allocated(climate_filename)) deallocate (climate_filename)
  if (allocated(surfex_filename)) deallocate (surfex_filename)
  child_status = 0; failed_stage = 0; status = 0
  return
900 continue
  status = child_status; failed_stage = stage
  call ieee_get_status(reached)
  call c_f_pointer(errno_address(), error_number); reached_errno = error_number
  if (profile_open) call public_statistics(2001_c_int, 1_c_int)
  call clear_fullpos_grib_code_targets(code_targets)
  if (allocated(pending)) call release_fullpos_state_owners(pending, model%initial%geometry%stream, stream_saved)
  if (stream_saved) then
    model%initial%geometry%stream%nfprgpl = old_stream_counts(1)
    model%initial%geometry%stream%nfprgpg = old_stream_counts(2)
    model%initial%geometry%stream%nfprgplx = old_stream_counts(3)
  end if
  if (allocated(filename)) deallocate (filename)
  if (allocated(climate_filename)) deallocate (climate_filename)
  if (allocated(surfex_filename)) deallocate (surfex_filename)
  call ieee_set_status(reached); error_number = reached_errno
  end function

  !> Initialise source-defined fresh scalar values while retaining native descriptors.
  subroutine initialize_fresh_fullpos_named_values(state)
    type(native_fullpos_state), intent(inout) :: state
    call zero_grid_counts(state%yfpgeometry%yfpgeo)
    call zero_grid_counts(state%yfpgeometry%yfpgeo_dep)
    state%yfpfilters%lfpmat = .false.
    state%yfpwstd%lwstd04 = .false.; state%yfpwstd%lwstd12 = .false.
    state%yfpioh%ynamfpios%nfpgrib = 0; state%yfpioh%ynamfpios%nfpdigits = 0
  end subroutine
  subroutine zero_grid_counts(grid)
    type(tfpgeo), intent(inout) :: grid
    grid%nfprgpg = 0; grid%nfprgpl = 0; grid%nfprgplx = 0; grid%nfproma = 0; grid%nfpblocs = 0
  end subroutine

  !> Reproduce public UPDTRANS inquiry and restore, without an original wrapper.
  integer(int32) function update_fullpos_transform(resolution) result(status)
    integer(int32), intent(in) :: resolution
    integer(int32) :: previous
    logical :: previous_lam, requested_lam
    status = 2
    call get_current(previous, previous_lam)
    if (previous_lam .or. previous < 1 .or. resolution < 1) return
    call trans_inq(kresol=resolution, ldlam=requested_lam)
    call trans_inq(kresol=previous)
    if (requested_lam) return
    status = 0
  end function

  !> Copy only the physical portion of each live map-factor block.
  integer(int32) function allocate_and_copy_fullpos_map_factor(state, model, budget) result(status)
    type(native_fullpos_state), intent(inout) :: state
    type(native_operational_model_configuration), intent(in) :: model
    integer(int64), intent(in) :: budget
    integer :: width, blocks, j, n, ierr
    status = 2
    width = state%yfpgeometry%yfpgeo%nfproma; blocks = state%yfpgeometry%yfpgeo%nfpblocs
    if (width < 1 .or. blocks < 0) return
    if (8_int64*width*blocks > budget) return
    if (size(model%initial%geometry%spherical%blocked%spherical_views) < blocks) return
    do j = 1, blocks
      n = state%yfpgeometry%yfpgeo%nfpend(j)
      if (n < 1 .or. n > width) return
      if (.not. associated(model%initial%geometry%spherical%blocked%spherical_views(j)%gm)) return
      if (size(model%initial%geometry%spherical%blocked%spherical_views(j)%gm) < n) return
    end do
    allocate (state%yfpgeometry%yfpgeo%rfpgm(width, blocks), stat=ierr)
    if (ierr /= 0) then
      status = 1; return
    end if
    do j = 1, blocks
      n = state%yfpgeometry%yfpgeo%nfpend(j)
      state%yfpgeometry%yfpgeo%rfpgm(1:n, j) = model%initial%geometry%spherical%blocked%spherical_views(j)%gm(1:n)
    end do
    status = 0
  end function

  !> Release only owners of this setup, in the original parent's ordered groups.
  subroutine release_fullpos_state_owners(state, stream, include_stream)
    type(native_fullpos_state), allocatable, intent(inout) :: state
    type(native_geometry_stream), intent(inout) :: stream
    logical, intent(in) :: include_stream
    integer :: j
    if (.not. allocated(state)) return
    if (allocated(state%yfpgeometry%yfpusergeo)) then
    do j = 1, size(state%yfpgeometry%yfpusergeo)
      call release_native_fullpos_model_geometry(state%yfpgeometry%yfpusergeo(j))
    end do
    deallocate (state%yfpgeometry%yfpusergeo)
    end if
    call release_native_fullpos_output_control(state%yfpcnt)
    if (allocated(state%yfpgeometry%yfpgeo%nfpend)) deallocate (state%yfpgeometry%yfpgeo%nfpend)
    if (allocated(state%yfpgeometry%yfpgeo%nfprgpnum)) deallocate (state%yfpgeometry%yfpgeo%nfprgpnum)
    if (allocated(state%yfpgeometry%yfpgeo%nfprgpind)) deallocate (state%yfpgeometry%yfpgeo%nfprgpind)
    if (allocated(state%yfpgeometry%yfpgeo%rfpgm)) deallocate (state%yfpgeometry%yfpgeo%rfpgm)
    call release_native_fullpos_vertical(state%yfpvab)
    if (allocated(state%yfpfilters%lfpfil)) deallocate (state%yfpfilters%lfpfil)
    if (allocated(state%yfpioh%yfpoph)) deallocate (state%yfpioh%yfpoph)
    if (allocated(state%yfpioh%yfpofn)) deallocate (state%yfpioh%yfpofn)
    if (include_stream) then
      if (allocated(stream%numprocfp)) deallocate (stream%numprocfp)
      if (allocated(stream%nfpmax)) deallocate (stream%nfpmax)
    end if
    deallocate (state)
  end subroutine

  logical function fresh_fullpos_data(data) result(fresh)
    type(native_fullpos_data), intent(in) :: data
    fresh = .false.
    if (associated(data%yfpos)) return
    if (allocated(data%yfpsuw%wlan04) .or. allocated(data%yfpsuw%wlan12) .or. allocated(data%yfpsuw%wlanml)) return
    if (allocated(data%yfpsuw%wsea04) .or. allocated(data%yfpsuw%wsea12) .or. allocated(data%yfpsuw%wseaml)) return
    if (allocated(data%yfpsuw%mwic) .or. allocated(data%yfpsuw%lpslsfx) .or. allocated(data%yfpsuw%npslsfx)) return
    if (allocated(data%yfpsuw%wsfxps) .or. allocated(data%yfpsuw%sfxmsk)) return
    if (allocated(data%yfpclimo%fpbuf)) return
    if (allocated(data%yfpclimo%yrqphy%icod) .or. allocated(data%yfpclimo%yrqphy%igrib)) return
    if (allocated(data%yfpclimo%yrqphy%llsurf) .or. allocated(data%yfpclimo%yrqphy%ivec)) return
  if(allocated(data%yfpclimo%yrqphy%zlev).or.allocated(data%yfpclimo%yrqphy%clname).or.allocated(data%yfpclimo%yrqphy%clpref))return
    if (allocated(data%yfpclimo%yrqphy%idom) .or. allocated(data%yfpclimo%yrqphy%idmp)) return
    if (allocated(data%yfpclimo%yrqphy%ivsetg) .or. allocated(data%yfpclimo%yrqphy%ivlocg)) return
    fresh = .true.
  end function

  !> Release the published allocation before its outer model/geometry lifetime.
 !! The original parent owns only these setup arrays and stream fields. Later
 !! output routines release their own data buffers before this setup release.
 !! Repeated release is harmless. Reached floating status and errno are retained.
  integer(int32) function release_runtime_fullpos_factory(state, data, configuration, stream) result(status)
    type(native_fullpos_state), allocatable, target, intent(inout) :: state
    type(native_fullpos_data), intent(inout) :: data
    type(native_runtime_output_configuration), intent(inout) :: configuration
    type(native_geometry_stream), intent(inout) :: stream
    type(ieee_status_type) :: reached
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    status = 0
    if (.not. allocated(state)) return
    if (associated(data%yfpos)) then
    if (.not. associated(data%yfpos, state)) then
      status = 2; return
    end if
    end if
    call ieee_get_status(reached); call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    nullify (data%yfpos)
    call release_fullpos_state_owners(state, stream, .true.)
    configuration%ready = .false.; nullify (configuration%metadata)
    call ieee_set_status(reached); error_number = saved_errno
  end function
end module forecast_runtime_fullpos_factory
