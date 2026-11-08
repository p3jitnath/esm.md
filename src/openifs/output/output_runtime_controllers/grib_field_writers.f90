!> Own selected GRIB writer contexts and exact source record order.
module forecast_grib_field_writers
  use iso_c_binding
  use iso_fortran_env, only: int32, int64, real64
  use forecast_model_clock_port, only: forecast_clock
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_selected_grib_metadata, only: selected_grib_output_controls, &
                                             selected_grib_output_metadata, read_grib_output_metadata
  use forecast_output_runtime_bindings, only: native_output_metadata_namespace
  use forecast_output_field_packing, only: native_spectral_field_metadata, native_grid_field_metadata
  use forecast_grib_template_initialization, only: initialize_grib_template
  use forecast_grib_field_encoding, only: native_grib_field_specification, encode_grib_field
  use forecast_eccodes_output_services
  use forecast_output_request_types, only: increment_output_counter
  use runtime_grib_file_services_port, only: open_grib_output, write_grib_record, close_grib_output
  implicit none
  private
  public :: native_grib_writer_inputs, native_grib_writer_policy, native_grib_writer_context
  public :: write_spectral_grib_fields, write_grid_grib_fields, release_grib_writer_context
  !> Borrow actual source geometry, clock, metadata and coefficient views.
  !! Scalars are readonly projections of named live geometry fields.
  !! latitude has -1:nlat+2 bounds; A/B have0:nlev bounds.
  !! No field calculation, metadata reader or template stage is supplied
  !! by the caller; this module executes those format stages itself.
  type :: native_grib_writer_inputs
    type(native_geometry_state), pointer :: geometry => null()
    type(forecast_clock), pointer :: clock => null()
    type(native_output_metadata_namespace), pointer :: namespace => null()
    type(selected_grib_output_controls) :: metadata_controls
    integer(int32) :: nlat, nlon, truncation, nlev, npoints, grid_type, spectral_type
    real(real64) :: stretch
    real(real64), pointer :: latitude(:) => null(), a(:) => null(), b(:) => null()
  end type
  !> Borrow source switches without owning a second forecast configuration.
  type :: native_grib_writer_policy
    integer(int32) :: nproc, nouttype, nconf, lecmwf, l_oops
    integer(int32) :: ltwgra, ltwinc, ltwbgv, ltwcgl, lppsteps, lvareps
  end type
  !> Retain the actual geometry identity and three public template owners.
  !! Counter order is spectral/grid calls, all records, padded bytes,
  !! spectral/grid records, forced records and successful encoder calls.
  type :: native_grib_writer_context
    logical :: ready = .false.
    type(native_geometry_state), pointer :: geometry => null()
    type(c_ptr) :: templates(0:2) = c_null_ptr
    type(selected_grib_output_metadata) :: metadata
    integer(int64) :: calls(0:1) = 0, records = 0, bytes = 0, kind_records(0:1) = 0
    integer(int64) :: forced_records = 0, encoded_fields = 0
  end type
  interface
    function environment_address(name) bind(c, name='getenv') result(address)
      import c_char, c_ptr
      character(c_char), intent(in) :: name(*)
      type(c_ptr) :: address
    end function
    subroutine set_sample_path(context, path) bind(c, name='codes_context_set_samples_path')
      import c_ptr
      type(c_ptr), value :: context, path
    end subroutine
  end interface
contains
  subroutine add_bytes(value, amount)
    integer(int64), intent(inout) :: value
    integer(int64), intent(in) :: amount
    if (value > huge(value) - amount) then
      value = -huge(value) - 1_int64 + (value - (huge(value) - amount) - 1_int64)
    else
      value = value + amount
    end if
  end subroutine

  integer(int32) function admit_policy(inputs, policy) result(status)
    type(native_grib_writer_inputs), intent(in) :: inputs
    type(native_grib_writer_policy), intent(in) :: policy
    status = 2
    if (.not. associated(inputs%clock) .or. .not. associated(inputs%namespace)) return
    if (policy%nproc /= 1 .or. policy%nouttype == 2 .or. policy%nconf /= 1 .or. policy%lecmwf /= 1) return
    if (policy%l_oops /= 0 .or. policy%ltwgra /= 0 .or. policy%ltwinc /= 0 .or. policy%ltwbgv /= 0 .or. &
        policy%ltwcgl /= 0 .or. policy%lppsteps /= 0 .or. policy%lvareps /= 0) return
    if (inputs%clock%current_step < 0 .or. inputs%clock%current_step > 24) return
    status = 0
  end function

  integer(int32) function prepare_context(context, inputs) result(status)
    type(native_grib_writer_context), intent(inout) :: context
    type(native_grib_writer_inputs), intent(in) :: inputs
    type(c_ptr) :: path
    integer :: j, k
    integer(c_int) :: ignored
    status = 2
    if (.not. associated(inputs%geometry)) return
    if (context%ready) then
      if (associated(context%geometry, inputs%geometry)) status = 0
      return
    end if
    if (.not. associated(inputs%clock) .or. .not. associated(inputs%latitude) .or. &
        .not. associated(inputs%a) .or. .not. associated(inputs%b)) return
    do j = 0, 2
      if (c_associated(context%templates(j))) return
    end do
    path = environment_address('MD2ASM_GRIB_SAMPLES_PATH'//c_null_char)
    if (.not. c_associated(path)) return
    call set_sample_path(c_null_ptr, path)
    status = read_grib_output_metadata(inputs%nlat, inputs%nlon, inputs%truncation, inputs%nlev, &
                                       inputs%npoints, inputs%grid_type, inputs%spectral_type, inputs%stretch, inputs%latitude, &
                                       inputs%a, inputs%b, inputs%clock, inputs%metadata_controls, context%metadata)
    if (status /= 0) return
    do j = 0, 2
      status = initialize_grib_template(context%metadata, int(j, int32), context%templates(j))
      if (status /= 0) then
        do k = 0, j - 1
          ignored = codes_delete(context%templates(k))
          context%templates(k) = c_null_ptr
        end do
        return
      end if
    end do
    context%geometry => inputs%geometry
    context%ready = .true.
  end function

  !> Write spectral fields in increasing source request order.
  !! fields is contiguous(506,1:25); metadata is its complete4-integer row
  !! array. level_type is m or p. The source consumes filename's first210
  !! bytes and appends records. Input clock dt is exactly3600seconds.
  !! Errors return the first service status after closing an acquired file;
  !! earlier records and counters remain visible, as in the source prefix.
  integer(int32) function write_spectral_grib_fields(context, inputs, policy, fields, metadata, &
                                                     level_type, filename) result(status)
    type(native_grib_writer_context), intent(inout) :: context
    type(native_grib_writer_inputs), intent(in) :: inputs
    type(native_grib_writer_policy), intent(in) :: policy
    real(real64), intent(in) :: fields(:, :)
    type(native_spectral_field_metadata), intent(in) :: metadata(:)
    character(1), intent(in) :: level_type
    character(*), intent(in) :: filename
    type(native_grib_field_specification) :: specification
    type(c_ptr) :: message, handle
    integer(c_size_t) :: length
    integer(c_int8_t), pointer :: message_bytes(:)
    integer(c_int) :: fd, ignored
    integer :: j, model
    status = 2
    if (.not. associated(inputs%clock)) return
    if (transfer(inputs%clock%dt, 0_int64) /= int(z'40ac200000000000', int64)) return
    if (size(fields, 1) /= 506 .or. size(fields, 2) < 1 .or. size(fields, 2) > 25) return
    if (size(metadata) /= size(fields, 2) .or. len(filename) < 210) return
    if (.not. is_contiguous(fields) .or. .not. is_contiguous(metadata)) return
    if (level_type /= 'm' .and. level_type /= 'p') return
    model = 0
    if (level_type == 'm') model = 1
    status = prepare_context(context, inputs)
    if (status /= 0) return
    status = admit_policy(inputs, policy)
    if (status /= 0) return
    fd = open_grib_output(filename(:210), .false.)
    if (fd < 0) then
      status = fd
      return
    end if
    do j = 1, size(fields, 2)
      status = 2
      if (metadata(j)%distribution_set /= 1) exit
      specification%template = context%templates(model)
      specification%parameter = metadata(j)%parameter
      specification%level = metadata(j)%level
      specification%representation = 1
      specification%model_level = model
      specification%forecast_seconds = int(inputs%clock%current_step, int64)*3600_int64
      specification%value_count = 506
      specification%force_log_surface_pressure = inputs%namespace%lforcelnsp
      message = c_null_ptr; handle = c_null_ptr; length = 0
      status = encode_grib_field(specification, fields(:, j), message, length, handle, context%encoded_fields)
      if (status /= 0) exit
      call c_f_pointer(message, message_bytes, [int(length)])
      status = write_grib_record(fd, message_bytes)
      if (status /= 0) then
        ignored = codes_delete(handle)
        exit
      end if
      call increment_output_counter(context%records)
      call increment_output_counter(context%kind_records(0))
      if (specification%parameter == 152 .and. model == 1 .and. specification%force_log_surface_pressure == 1) &
        call increment_output_counter(context%forced_records)
      call add_bytes(context%bytes, iand(int(length, int64) + 3_int64, -4_int64))
      status = codes_delete(handle)
      if (status /= 0) exit
    end do
    ignored = close_grib_output(fd)
    if (status == 0) status = ignored
    if (status == 0) call increment_output_counter(context%calls(0))
  end function

  !> Write contiguous humidity fields(2048,1:19) from a live context.
  !! Only model level_type m and mode a/w are source-admitted.
  !! Filename has1:256bytes. Mode w truncates; a appends. No spectral
  !! prerequisite is fabricated: context must already be ready.
  integer(int32) function write_grid_grib_fields(context, inputs, policy, fields, metadata, &
                                                 level_type, mode, filename) result(status)
    type(native_grib_writer_context), intent(inout) :: context
    type(native_grib_writer_inputs), intent(in) :: inputs
    type(native_grib_writer_policy), intent(in) :: policy
    real(real64), intent(in) :: fields(:, :)
    type(native_grid_field_metadata), intent(in) :: metadata(:)
    character(1), intent(in) :: level_type, mode
    character(*), intent(in) :: filename
    type(native_grib_field_specification) :: specification
    type(c_ptr) :: message, handle
    integer(c_size_t) :: length
    integer(c_int8_t), pointer :: message_bytes(:)
    integer(c_int) :: fd, ignored
    integer :: j
    status = 2
    if (.not. context%ready .or. .not. associated(inputs%clock)) return
    if (transfer(inputs%clock%dt, 0_int64) /= int(z'40ac200000000000', int64)) return
    if (size(fields, 1) /= 2048 .or. size(fields, 2) < 1 .or. size(fields, 2) > 19) return
    if (size(metadata) /= size(fields, 2) .or. len(filename) < 1 .or. len(filename) > 256) return
    if (.not. is_contiguous(fields) .or. .not. is_contiguous(metadata)) return
    if (level_type /= 'm' .or. (mode /= 'a' .and. mode /= 'w')) return
    status = admit_policy(inputs, policy)
    if (status /= 0) return
    fd = open_grib_output(filename, mode == 'w')
    if (fd < 0) then
      status = fd
      return
    end if
    do j = 1, size(fields, 2)
      specification%template = context%templates(2)
      specification%parameter = metadata(j)%parameter
      specification%level = metadata(j)%level
      specification%representation = 0
      specification%model_level = 1
      specification%forecast_seconds = int(inputs%clock%current_step, int64)*3600_int64
      specification%value_count = 2048
      specification%force_log_surface_pressure = inputs%namespace%lforcelnsp
      message = c_null_ptr; handle = c_null_ptr; length = 0
      status = encode_grib_field(specification, fields(:, j), message, length, handle, context%encoded_fields)
      if (status /= 0) exit
      call c_f_pointer(message, message_bytes, [int(length)])
      status = write_grib_record(fd, message_bytes)
      if (status /= 0) then
        ignored = codes_delete(handle)
        exit
      end if
      call increment_output_counter(context%records)
      call increment_output_counter(context%kind_records(1))
      call add_bytes(context%bytes, iand(int(length, int64) + 3_int64, -4_int64))
      status = codes_delete(handle)
      if (status /= 0) exit
    end do
    ignored = close_grib_output(fd)
    if (status == 0) status = ignored
    if (status == 0) call increment_output_counter(context%calls(1))
  end function

  !> Release public C owners at the native caller's lifetime boundary.
  !! This added native lifetime service preserves observation counters.
  integer(int32) function release_grib_writer_context(context) result(status)
    type(native_grib_writer_context), intent(inout) :: context
    integer :: j
    integer(c_int) :: child
    status = 0
    do j = 0, 2
      if (c_associated(context%templates(j))) then
        child = codes_delete(context%templates(j))
        if (status == 0 .and. child /= 0) status = child
        context%templates(j) = c_null_ptr
      end if
    end do
    context%ready = .false.
    nullify (context%geometry)
  end function
end module
