!> Join actual native forecast metadata to the public GRIB writer services.
module forecast_actual_output_writer_bridge
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_size_t
  use mpi_f08, only: MPI_Comm
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_model_clock_port, only: forecast_clock
  use forecast_output_runtime_bindings, only: native_output_metadata_namespace
  use forecast_output_request_types, only: trqfp
  use runtime_grib_template_port, only: grib_geometry_metadata, grib_template_metadata
  use runtime_grib_field_encoding_port, only: grib_field_metadata
  use runtime_grib_soil_levels_port, only: initialize_runtime_grib_soil_levels
  use runtime_output_field_gather_port, only: output_distribution
  use runtime_grib_writer_state_port, only: grib_writer_state, initialize_grib_writer_state, release_grib_writer_state
  use runtime_selected_output_family_port, only: output_selection_request
  implicit none
  private
  public :: native_actual_output_writer_context, initialize_actual_output_writer, release_actual_output_writer
  public :: project_actual_output_selection
  !> Own only format metadata and output history; all weather arrays are borrowed.
  !! Geometry C addresses expire before the actual geometry owner is released.
  type :: native_actual_output_writer_context
    type(grib_geometry_metadata) :: geometry
    type(grib_template_metadata) :: template_metadata
    type(grib_field_metadata) :: field_defaults
    type(output_distribution) :: distribution
    type(grib_writer_state) :: writer
    real(real64) :: gravity, water_density, cloud_cover_precision, cloud_water_precision
    character(256) :: output_directory = ' '
    logical :: ready = .false.
  end type
contains
  !> Bind one final geometry target and source-produced format controls.
  !! soil and water contain four layer thicknesses in metres. Their exact
  !! source prefix sums produce centimetre labels through the existing child.
  !! Cloud precisions are TECLDP RAMIN/RLMIN. No weather payload is copied.
  integer(int32) function initialize_actual_output_writer(state, geometry, metadata, clock, experiment, &
                                   communicator, time_loop_ready, output_directory, gravity, water_density, cloud_cover_precision, &
                                                          cloud_water_precision, soil, water, budget) result(status)
    type(native_actual_output_writer_context), intent(inout) :: state
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_output_metadata_namespace), intent(in) :: metadata
    type(forecast_clock), intent(in) :: clock
    character(*), intent(in) :: experiment, output_directory
    type(MPI_Comm), intent(in) :: communicator
    logical, intent(in) :: time_loop_ready
    real(real64), intent(in) :: gravity, water_density, cloud_cover_precision, cloud_water_precision
    real(real64), intent(in) :: soil(4), water(4)
    integer(int64), intent(in) :: budget
    type(native_actual_output_writer_context) :: work
    integer :: rows, levels, j
    integer(int64) :: points
    status = 2
    if (state%ready .or. state%writer%initialized) return
    if (.not. geometry%initialized .or. .not. associated(geometry%vertical)) return
    if (.not. allocated(geometry%latitudes%rw) .or. .not. allocated(geometry%latitudes%rlatig)) return
    if (.not. allocated(geometry%configuration%nloeng)) return
    if (.not. allocated(geometry%vertical%valh) .or. .not. allocated(geometry%vertical%vbh)) return
    rows = size(geometry%latitudes%rw); levels = geometry%vertical%levels
    if (rows < 2 .or. rows > 16384 .or. levels < 1 .or. levels > 512) return
    if (lbound(geometry%latitudes%rlatig, 1) > 1 .or. ubound(geometry%latitudes%rlatig, 1) < rows) return
    if (lbound(geometry%configuration%nloeng, 1) > 1 .or. ubound(geometry%configuration%nloeng, 1) < rows) return
    if (lbound(geometry%vertical%valh, 1) /= 0 .or. ubound(geometry%vertical%valh, 1) < levels) return
    if (lbound(geometry%vertical%vbh, 1) /= 0 .or. ubound(geometry%vertical%vbh, 1) < levels) return
    if (budget < 65536_int64 .or. budget > 68719476736_int64) return
    if (len(experiment) < 4 .or. len_trim(output_directory) > 256) return
    if (metadata%nlocgrb /= 1 .or. metadata%nstream /= 1025 .or. metadata%ctype /= 'fc') return
    points = 0
    do j = 1, rows
      if (geometry%configuration%nloeng(j) < 1 .or. geometry%configuration%nloeng(j) > 65536) return
      points = points + geometry%configuration%nloeng(j)
    end do
    if (points /= geometry%partition%ngptotg .or. points > huge(0_int32)) return
    work%geometry%nlat = rows
    work%geometry%nlon = maxval(geometry%configuration%nloeng(1:rows))
    work%geometry%truncation = geometry%transform_resolution%truncation
    work%geometry%nlev = levels
    work%geometry%reduced = 1
    if (all(geometry%configuration%nloeng(1:rows) == work%geometry%nlon)) work%geometry%reduced = 0
    work%geometry%npoints = int(points, int32)
    work%geometry%latitudes = c_loc(geometry%latitudes%rlatig(1))
    work%geometry%points_per_row = c_loc(geometry%configuration%nloeng(1))
    work%geometry%hybrid_a = c_loc(geometry%vertical%valh(0))
    work%geometry%hybrid_b = c_loc(geometry%vertical%vbh(0))
    work%template_metadata%cycle = metadata%ncycle
    work%template_metadata%local_definition = metadata%nlocgrb
    work%template_metadata%stream = metadata%nstream
    work%template_metadata%data_date = clock%initial_date
    work%template_metadata%seconds = clock%initial_seconds
    work%template_metadata%classification = [metadata%cfclass(1:1), metadata%cfclass(2:2)]
    work%template_metadata%forecast_type = [metadata%ctype(1:1), metadata%ctype(2:2)]
    work%template_metadata%experiment = [experiment(1:1), experiment(2:2), experiment(3:3), experiment(4:4)]
    work%template_metadata%workspace_limit_bytes = int(budget, c_size_t)
    work%field_defaults%truncation = geometry%transform_resolution%truncation
    work%field_defaults%workspace_limit_bytes = int(budget, c_size_t)
    work%field_defaults%packing%log_pressure_bits = metadata%nbitsshlnsp
    work%field_defaults%packing%expression_bits = metadata%nbitsexpr
    work%field_defaults%packing%force_geopotential = metadata%lforcez /= 0
    work%field_defaults%packing%force_log_pressure = metadata%lforcelnsp /= 0
    status = initialize_runtime_grib_soil_levels(soil, water, work%field_defaults%soil_levels)
    if (status /= 0) return
    work%distribution%communicator = communicator
    work%distribution%world = geometry%transform_control%nproc
    work%distribution%process_one_based = geometry%transform_control%myproc
    work%distribution%vertical_groups = geometry%transform_control%nprtrv
    work%distribution%vertical_group = geometry%transform_control%mysetv
    work%distribution%local_grid_points = geometry%partition%ngptot
    work%distribution%global_grid_points = geometry%partition%ngptotg
    work%distribution%resolution = geometry%transform_resolution%resolution
    work%distribution%maps_ready = .true.
    work%gravity = gravity; work%water_density = water_density
    work%cloud_cover_precision = cloud_cover_precision; work%cloud_water_precision = cloud_water_precision
    work%output_directory = output_directory
    status = initialize_grib_writer_state(work%writer, time_loop_ready, 1_int32)
    if (status /= 0) return
    work%ready = .true.
    state = work
  end function
  !> Copy named request metadata into the format service's native interface.
  !! No field value changes or numerical calculation occurs. The new small
  !! metadata owners live until the synchronous writer returns.
  integer(int32) function project_actual_output_selection(request, spectral, physical, output) result(status)
    type(trqfp), intent(in) :: request
    logical, intent(in) :: spectral, physical
    type(output_selection_request), intent(inout) :: output
    integer :: n, ierr
    status = 2
    n = request%nfieldg
    if (n < 0 .or. n > 65536 .or. (physical .and. n > 1639)) return
    if (allocated(output%parameters) .or. allocated(output%integrated) .or. allocated(output%levels)) return
    if (allocated(output%vertical_sets) .or. allocated(output%local_slots)) return
    if (n > 0) then
      if (.not. allocated(request%igrib)) return
      if (size(request%igrib) < n) return
      if (.not. physical) then
        if (.not. allocated(request%llsurf) .or. .not. allocated(request%zlev)) return
        if (size(request%llsurf) < n .or. size(request%zlev) < n) return
      end if
      if (spectral) then
        if (.not. allocated(request%ivsetg) .or. .not. allocated(request%ivlocg)) return
        if (size(request%ivsetg) < n .or. size(request%ivlocg) < n) return
      end if
    end if
    allocate (output%parameters(n), stat=ierr)
    if (ierr /= 0) goto700
    if (n > 0) output%parameters = request%igrib(1:n)
    if (.not. physical) then
      allocate (output%integrated(n), stat=ierr)
      if (ierr /= 0) goto700
      allocate (output%levels(n), stat=ierr)
      if (ierr /= 0) goto700
      if (n > 0) output%integrated = request%llsurf(1:n)
      if (n > 0) output%levels = request%zlev(1:n)
    end if
    if (spectral) then
      allocate (output%vertical_sets(n), stat=ierr)
      if (ierr /= 0) goto700
      allocate (output%local_slots(n), stat=ierr)
      if (ierr /= 0) goto700
      if (n > 0) output%vertical_sets = request%ivsetg(1:n)
      if (n > 0) output%local_slots = request%ivlocg(1:n)
    end if
    output%local_field_count = request%nfieldl
    status = 0
    return
700 status = 1
  end function
  subroutine release_actual_output_writer(state)
    type(native_actual_output_writer_context), intent(inout) :: state
    call release_grib_writer_state(state%writer)
    state%ready = .false.
  end subroutine
end module
