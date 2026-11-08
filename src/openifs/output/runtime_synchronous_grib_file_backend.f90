module runtime_synchronous_grib_file_backend_port
  !! Gather, encode and write selected fields in the generated source order.
  !! The caller supplies typed metadata and owns each local field matrix.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding
  use runtime_grib_template_port, only: grib_geometry_metadata, grib_template_metadata, &
                                        create_runtime_grib_template, runtime_grib_edition
  use runtime_grib_field_encoding_port, only: grib_field_metadata, encode_runtime_grib_field
  use runtime_grib_writer_state_port, only: grib_writer_state, previous_grib_output_steps
  use runtime_grib_file_services_port, only: open_grib_path, write_padded_grib_message, close_grib_output
  use runtime_output_field_gather_port, only: output_distribution, gather_runtime_output_field, &
                                              agree_output_status
  implicit none
  private
  public :: output_file_plan, output_field_selection, write_runtime_gathered_fields

  type :: output_file_plan
    logical :: spectral = .false., append = .false.
    character :: level_kind = 's'
    integer(int32) :: truncation = 1, nstep = 0, local_value_count = 0, global_value_count = 0
    real(real64) :: time_step = 0.0_real64
  end type output_file_plan
  type :: output_field_selection
    integer(int32) :: parameter_id = 0, level = 0, vertical_group = 1
  end type output_field_selection

  interface
    function codes_delete(handle) bind(C, name="codes_handle_delete") result(status)
      import c_ptr, c_int
      type(c_ptr), value :: handle
      integer(c_int) :: status
    end function codes_delete
  end interface

contains

  subroutine write_runtime_gathered_fields(geometry, template_metadata, field_defaults, &
                                           distribution, plan, fields, dense_fields, filename, output_directory, writer, status)
    !! dense_fields has (local_value_count,local_selected_fields) elements.
    !! Spectral local columns omit fields owned by other vertical groups.
    !! Field labels remain in the complete global source order.
    !! A service failure can leave a complete prefix of the output file.
    type(grib_geometry_metadata), intent(in) :: geometry
    type(grib_template_metadata), intent(in) :: template_metadata
    type(grib_field_metadata), intent(in) :: field_defaults
    type(output_distribution), intent(in) :: distribution
    type(output_file_plan), intent(in) :: plan
    type(output_field_selection), intent(in) :: fields(:)
    real(real64), contiguous, target, intent(in) :: dense_fields(:, :)
    character(*), intent(in) :: filename, output_directory
    type(grib_writer_state), intent(in) :: writer
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: global_values(:)
    integer(c_int8_t), pointer :: message_bytes(:)
    type(grib_template_metadata) :: reduced_template_metadata
    type(grib_field_metadata) :: field
    type(c_ptr) :: templates(0:4), message, owner
    integer(c_size_t) :: message_length, global_bytes
    integer(c_int) :: fd, service_status, cleanup_status, kind, edition
    integer(int32) :: local_status
    integer :: j, local_column, local_fields, allocation_status, path_length
    character(4095) :: path
    logical :: local_field, is_writer

    templates = c_null_ptr
    message = c_null_ptr
    owner = c_null_ptr
    fd = -1_c_int
    status = 2_int32
    local_status = 2_int32
    is_writer = distribution%process_one_based == 1
    if (writer%initialized .and. .not. writer%io_server .and. writer%output_type == 1 .and. &
        distribution%maps_ready .and. size(fields) <= 65536) then
      local_status = 0_int32
      if (size(fields) > 0) then
        if (len(filename) < 1 .or. len(filename) > 256) local_status = 2
        if (plan%local_value_count < 1 .or. plan%global_value_count < 1) local_status = 2
        if (plan%truncation < 1 .or. plan%truncation > 4096 .or. plan%nstep < 0) local_status = 2
        if (size(dense_fields, 1) /= plan%local_value_count) local_status = 2
        if (plan%spectral) then
          if (int(plan%global_value_count, int64) /= &
              int(plan%truncation + 1, int64)*int(plan%truncation + 2, int64)) local_status = 2
        end if
        local_fields = 0
        do j = 1, size(fields)
          if (.not. plan%spectral .or. fields(j)%vertical_group == distribution%vertical_group) &
            local_fields = local_fields + 1
        end do
        if (size(dense_fields, 2) /= local_fields) local_status = 2
      end if
    end if
    call agree_output_status(distribution, local_status, status)
    if (status /= 0 .or. size(fields) == 0) return

    reduced_template_metadata = template_metadata
    field = field_defaults
    global_bytes = 0_c_size_t
    local_status = 0_int32
    if (is_writer) then
      global_bytes = 8_c_size_t*int(plan%global_value_count, c_size_t)
      if (global_bytes > field_defaults%workspace_limit_bytes) then
        local_status = 2_int32
      else
        field%workspace_limit_bytes = field_defaults%workspace_limit_bytes - global_bytes
        reduced_template_metadata%workspace_limit_bytes = field%workspace_limit_bytes
      end if
    end if
    allocation_status = 0
    if (local_status == 0) then
      if (is_writer) then
        allocate (global_values(plan%global_value_count), stat=allocation_status)
      else
        allocate (global_values(1), stat=allocation_status)
      end if
      if (allocation_status /= 0) local_status = 1_int32
    end if
    if (is_writer .and. local_status == 0) then
      local_status = make_output_path(filename, output_directory, path, path_length)
      if (local_status == 0) then
        fd = open_grib_path(path(:path_length),.not. plan%append, 420_c_int)
        if (fd < 0) local_status = 3_int32
      end if
    end if
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) goto 900

    local_column = 0
    do j = 1, size(fields)
      local_field = .not. plan%spectral .or. fields(j)%vertical_group == distribution%vertical_group
      if (local_field) then
        local_column = local_column + 1
        call gather_runtime_output_field(distribution, plan%spectral, fields(j)%vertical_group, &
                                         plan%truncation, plan%local_value_count, plan%global_value_count, global_values, &
                                         status, dense_fields(:, local_column))
      else
        call gather_runtime_output_field(distribution, plan%spectral, fields(j)%vertical_group, &
                                         plan%truncation, plan%local_value_count, plan%global_value_count, global_values, status)
      end if
      if (status /= 0) goto 900
      local_status = 0_int32
      if (is_writer) then
        if (plan%level_kind == 'm') then
          kind = 1_c_int
          if (.not. plan%spectral) kind = 3_c_int
        else
          edition = runtime_grib_edition(fields(j)%parameter_id, fields(j)%level)
          if (plan%spectral) then
            kind = 0_c_int
            if (edition /= 1) local_status = 3_int32
          else
            kind = 4_c_int
            if (edition == 1) kind = 2_c_int
          end if
        end if
        if (local_status == 0 .and. .not. c_associated(templates(kind))) then
          service_status = create_runtime_grib_template(geometry, reduced_template_metadata, &
                                                        kind, templates(kind))
          if (service_status /= 0 .or. .not. c_associated(templates(kind))) local_status = 3_int32
        end if
        if (local_status == 0) then
          field%template = templates(kind)
          field%parameter_id = fields(j)%parameter_id
          field%level = fields(j)%level
          field%spectral = plan%spectral
          field%level_kind = plan%level_kind
          field%truncation = plan%truncation
          field%nstep = plan%nstep
          field%dt = plan%time_step
          field%previous = previous_grib_output_steps(writer)
          message = c_null_ptr
          message_length = 0_c_size_t
          owner = c_null_ptr
          service_status = encode_runtime_grib_field(field, global_values, message, message_length, owner)
          if (service_status /= 0) local_status = 3_int32
        end if
        if (local_status == 0 .and. message_length > 0) then
          if (.not. c_associated(message) .or. message_length > huge(0_c_int)) then
            local_status = 3_int32
          else
            call c_f_pointer(message, message_bytes, [int(message_length)])
            service_status = write_padded_grib_message(fd, message_bytes)
            if (service_status /= 0) local_status = 3_int32
          end if
        end if
        if (local_status == 0 .and. c_associated(owner)) then
          service_status = codes_delete(owner)
          owner = c_null_ptr
          if (service_status /= 0) local_status = 3_int32
        end if
      end if
      call agree_output_status(distribution, local_status, status)
      if (status /= 0) goto 900
    end do

900 continue
    local_status = status
    if (c_associated(owner)) then
      cleanup_status = codes_delete(owner)
      owner = c_null_ptr
      if (local_status == 0 .and. cleanup_status /= 0) local_status = 3_int32
    end if
    do j = 0, 4
      if (c_associated(templates(j))) then
        cleanup_status = codes_delete(templates(j))
        templates(j) = c_null_ptr
        if (local_status == 0 .and. cleanup_status /= 0) local_status = 3_int32
      end if
    end do
    if (fd >= 0) then
      cleanup_status = close_grib_output(fd)
      if (local_status == 0 .and. cleanup_status /= 0) local_status = 3_int32
    end if
    if (allocated(global_values)) deallocate (global_values)
    call agree_output_status(distribution, local_status, status)
  end subroutine write_runtime_gathered_fields

  function make_output_path(filename, directory, path, path_length) result(status)
    !! Join a relative name to its directory without changing source bytes.
    character(*), intent(in) :: filename, directory
    character(4095), intent(out) :: path
    integer, intent(out) :: path_length
    integer(int32) :: status
    integer :: n, d

    status = 2_int32
    path_length = 0
    n = len_trim(filename)
    if (n < 1 .or. n > 256 .or. index(filename(:n), c_null_char) /= 0) return
    path = ''
    if (filename(1:1) == '/' .or. len(directory) == 0) then
      path(:n) = filename(:n)
      path_length = n
    else
      d = len(directory)
      if (d > 3839 .or. index(directory, c_null_char) /= 0) return
      if (d + n + 1 > 4095) return
      path(:d) = directory
      path_length = d
      if (directory(d:d) /= '/') then
        path_length = path_length + 1
        path(path_length:path_length) = '/'
      end if
      path(path_length + 1:path_length + n) = filename(:n)
      path_length = path_length + n
    end if
    status = 0_int32
  end function make_output_path
end module runtime_synchronous_grib_file_backend_port
