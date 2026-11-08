module runtime_selected_output_family_port
  !! Own temporary source-ordered selections before synchronous file writing.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_size_t
  use mpl_allreduce_mod, only: MPL_ALLREDUCE
  use runtime_grib_template_port, only: grib_geometry_metadata, grib_template_metadata
  use runtime_grib_field_encoding_port, only: grib_field_metadata
  use runtime_grib_writer_state_port, only: grib_writer_state, update_last_physics_output_steps
  use runtime_output_field_gather_port, only: output_distribution, agree_output_status
  use runtime_synchronous_grib_file_backend_port, only: output_file_plan, output_field_selection, &
                                                        write_runtime_gathered_fields
  use runtime_output_field_selection_port
  implicit none
  private
  public :: output_selection_request, write_runtime_selected_output_family

  type :: output_selection_request
    integer(int32), allocatable :: parameters(:), vertical_sets(:), local_slots(:)
    logical, allocatable :: integrated(:)
    real(real64), allocatable :: levels(:)
    integer(int32) :: local_field_count = 0_int32
  end type output_selection_request

contains

  subroutine write_runtime_selected_output_family(family, request, geometry, &
                                                  template_metadata, field_defaults, distribution, plan, filename, &
                                                  output_directory, &
                                                  gravity, water_density, cloud_cover_precision, cloud_water_precision, &
                                                  writer, status, &
                                                  spectrum, blocked)
    !! family zero selects spectral, one physical, and two upper-grid fields.
    !! spectrum has (local_fields,local_coefficients) elements. blocked has
    !! (block_width,field_capacity,block_count) elements in physical units.
    !! Only the selected input representation must be present.
    !! The 8192-byte nested reserve and actual typed metadata storage are
    !! charged before each owned allocation. The caller retains all inputs.
    integer(int32), intent(in) :: family
    type(output_selection_request), intent(in) :: request
    type(grib_geometry_metadata), intent(in) :: geometry
    type(grib_template_metadata), intent(in) :: template_metadata
    type(grib_field_metadata), intent(in) :: field_defaults
    type(output_distribution), intent(in) :: distribution
    type(output_file_plan), intent(in) :: plan
    character(*), intent(in) :: filename, output_directory
    real(real64), intent(in) :: gravity, water_density, cloud_cover_precision, cloud_water_precision
    type(grib_writer_state), intent(inout) :: writer
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: spectrum(:, :), blocked(:, :, :)
    type(output_field_selection), allocatable :: fields(:)
    integer(int32), allocatable :: indices(:)
    real(real64), allocatable, target :: dense(:, :)
    type(grib_field_metadata) :: reduced_fields
    type(grib_template_metadata) :: reduced_template
    integer(int32) :: local_status, global_count, local_count
    integer(int64) :: source_code_bytes, metadata_bytes, index_bytes, dense_bytes, charged, budget
    integer :: n, allocation_status, field_size, stride, j, k, error, name_length
    logical :: tracked

    status = 2_int32
    local_status = 2_int32
    n = 0
    if (allocated(request%parameters)) n = size(request%parameters)
    if (family >= 0 .and. family <= 2 .and. distribution%maps_ready .and. &
        plan%local_value_count >= 1 .and. plan%global_value_count >= 1 .and. &
        plan%local_value_count <= plan%global_value_count .and. n <= 65536) then
      local_status = 0_int32
      if (family == 0) then
        if (.not. plan%spectral) local_status = 2
      else
        if (plan%spectral) local_status = 2
        if (plan%local_value_count /= distribution%local_grid_points .or. &
            plan%global_value_count /= distribution%global_grid_points) local_status = 2
      end if
      if (family == 1 .and. n > 1639) local_status = 2
      if (n > 0) then
        if (family == 0) then
          if (.not. present(spectrum)) local_status = 2
          if (request%local_field_count < 0 .or. request%local_field_count > 65536) local_status = 2
          if (.not. allocated(request%vertical_sets) .or. .not. allocated(request%local_slots)) local_status = 2
        else
          if (.not. present(blocked)) local_status = 2
        end if
        if (family /= 1) then
          if (.not. allocated(request%integrated) .or. .not. allocated(request%levels)) local_status = 2
        end if
      end if
    end if
    call agree_output_status(distribution, local_status, status)
    if (status /= 0 .or. n == 0) return

    stride = 16
    if (family == 1) stride = 8
    if (family == 2) stride = 12
    source_code_bytes = int(stride, int64)*int(n, int64)
    field_size = storage_size(output_field_selection())/8
    metadata_bytes = max(source_code_bytes, int(field_size, int64)*int(n, int64))
    index_bytes = 0_int64
    if (family == 0) index_bytes = max(4_int64*int(request%local_field_count, int64), 1_int64)
    if (family == 2) index_bytes = 4_int64*int(n, int64)
    dense_bytes = 0_int64
    if (family /= 0) dense_bytes = 8_int64*int(plan%local_value_count, int64)*int(n, int64)
    charged = metadata_bytes + index_bytes + dense_bytes + 8192_int64
    budget = int(field_defaults%workspace_limit_bytes, int64)
    local_status = 0_int32
    if (budget < 0 .or. charged > budget) local_status = 2_int32
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) return

    allocate (fields(n), stat=allocation_status)
    local_status = 0_int32
    if (allocation_status /= 0) local_status = 1_int32
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) goto 900
    global_count = int(n, int32)
    local_count = int(n, int32)
    if (family == 0) then
      allocate (indices(request%local_field_count), stat=allocation_status)
      local_status = 0_int32
      if (allocation_status /= 0) local_status = 1_int32
      call agree_output_status(distribution, local_status, status)
      if (status /= 0) goto 900
      local_status = build_spectral_output_selection(plan%level_kind, request%parameters, &
                                                     request%integrated, request%levels, request%vertical_sets, &
                                                     request%local_slots, &
                                                     request%local_field_count, distribution%vertical_group, fields, indices, &
                                                     global_count, local_count)
      call agree_output_status(distribution, local_status, status)
      if (status /= 0) goto 900
      dense_bytes = max(8_int64*int(plan%local_value_count, int64)*int(local_count, int64), 1_int64)
      charged = metadata_bytes + index_bytes + dense_bytes + 8192_int64
      local_status = 0_int32
      if (charged > budget) local_status = 2_int32
      call agree_output_status(distribution, local_status, status)
      if (status /= 0) goto 900
    else if (family == 2) then
      allocate (indices(n), stat=allocation_status)
      local_status = 0_int32
      if (allocation_status /= 0) local_status = 1_int32
      call agree_output_status(distribution, local_status, status)
      if (status /= 0) goto 900
    end if
    allocate (dense(plan%local_value_count, local_count), stat=allocation_status)
    local_status = 0_int32
    if (allocation_status /= 0) local_status = 1_int32
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) goto 900
    select case (family)
    case (0)
      local_status = pack_spectral_output_fields(spectrum, indices(:local_count), dense)
    case (1)
      local_status = select_physical_output_fields(request%parameters, blocked, &
                                                   plan%local_value_count, gravity, water_density, fields, dense)
    case (2)
      local_status = select_upper_grid_output_fields(plan%level_kind, request%parameters, &
                                                     request%integrated, request%levels, blocked, plan%local_value_count, &
                                                     cloud_cover_precision, cloud_water_precision, fields, dense, indices, &
                                                     global_count)
    end select
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) goto 900

    reduced_fields = field_defaults
    reduced_template = template_metadata
    reduced_fields%workspace_limit_bytes = int(budget - charged, c_size_t)
    reduced_template%workspace_limit_bytes = reduced_fields%workspace_limit_bytes
    name_length = min(len(filename), 256)
    if (family == 0) name_length = min(len(filename), 210)
    if (family == 0) then
      call write_runtime_gathered_fields(geometry, reduced_template, reduced_fields, &
                                         distribution, plan, fields(:global_count), dense, filename(:name_length), &
                                         output_directory, writer, status)
    else
      call write_runtime_gathered_fields(geometry, reduced_template, reduced_fields, &
                                         distribution, plan, fields(:global_count), dense(:, :global_count), &
                                         filename(:name_length), &
                                         output_directory, writer, status)
    end if
    if (status /= 0 .or. family /= 1) goto 900
    if (distribution%world > 1) then
      call MPL_ALLREDUCE(writer%last_output_steps, CDOPER='MAX', KERROR=error, CDSTRING='WROUTGPGB:')
      local_status = 0_int32
      if (error /= 0) local_status = 3_int32
      call agree_output_status(distribution, local_status, status)
      if (status /= 0) goto 900
    end if
    local_status = update_last_physics_output_steps(writer, plan%nstep, [integer(int32) ::])
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) goto 900
    local_status = update_last_physics_output_steps(writer, plan%nstep, request%parameters)
    if (local_status /= 0) then
      status = local_status
      goto 900
    end if
    tracked = .false.
    do j = 1, n
      do k = 1, 5
        if (request%parameters(j) == writer%previous_codes(k)) tracked = .true.
      end do
    end do
    if (tracked) then
      call MPL_ALLREDUCE(writer%last_output_steps, CDOPER='MAX', KERROR=error)
      if (error /= 0) status = 3_int32
    end if

900 continue
    if (allocated(dense)) deallocate (dense)
    if (allocated(indices)) deallocate (indices)
    if (allocated(fields)) deallocate (fields)
    local_status = status
    call agree_output_status(distribution, local_status, status)
  end subroutine write_runtime_selected_output_family
end module runtime_selected_output_family_port
