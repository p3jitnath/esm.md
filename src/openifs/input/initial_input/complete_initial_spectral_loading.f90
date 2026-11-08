module forecast_complete_initial_spectral_loading
  !! Own the selected/global and distributed spectral input transactions.
  !! Ports: spectral_initial_state_loading.S and both operational loaders.
  !! The caller retains stable native owners and supplies its memory budget.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yomdimf, only: tdimf
  use grid_field_configuration_types_port, only: grid_field_configuration
  use spectral_field_storage_port, only: spectral_field_state
  use initial_field_placement_port, only: spectral_initial_partition, place_partitioned_spectral_fields
  use owned_spectral_initial_loading_port, only: project_owned_spectral_input_partition, release_owned_spectral_input_partition
  use forecast_fixed_initial_field_readers, only: read_selected_spectral_fields, read_operational_initial_spectral_fields
  use forecast_initial_spectral_placement, only: place_initial_spectral_fields, place_operational_spectral_fields
  implicit none
  private
  public :: load_spectral_initial_state, load_operational_spectral_initial_state
  public :: load_partitioned_operational_spectral_initial_state
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function load_spectral_initial_state(path,resolution_index,wave_processors,dimensions,configuration,field,loaded_orography,byte_limit) result(status)
    !! Selected whole T21/L19 owner. resolution_index is the source NFRESOL;
    !! wave_processors is NPRTRW. dimensions is the canonical TDIMF record.
    !! The readonly GFL metadata excludes omitted spectral-tracer conversions.
    character(len=*), intent(in) :: path
    integer(int32), intent(in) :: resolution_index, wave_processors
    type(tdimf), intent(in) :: dimensions
    type(grid_field_configuration), intent(in) :: configuration
    type(spectral_field_state), intent(inout) :: field
    integer(int32), intent(inout) :: loaded_orography
    integer(int64), intent(in) :: byte_limit
    status=load_global_spectral_state(path,resolution_index,wave_processors,dimensions,configuration,field,loaded_orography,byte_limit,506,19,78,.false.)
  end function

  integer(int32) function load_operational_spectral_initial_state(path,resolution_index,wave_processors,dimensions,configuration,field,loaded_orography,byte_limit) result(status)
    !! Whole T1279/L137 owner. This entry preserves the original global-matrix
    !! route. The separate production streamed input route stays independent.
    character(len=*), intent(in) :: path
    integer(int32), intent(in) :: resolution_index, wave_processors
    type(tdimf), intent(in) :: dimensions
    type(grid_field_configuration), intent(in) :: configuration
    type(spectral_field_state), intent(inout) :: field
    integer(int32), intent(inout) :: loaded_orography
    integer(int64), intent(in) :: byte_limit
    status=load_global_spectral_state(path,resolution_index,wave_processors,dimensions,configuration,field,loaded_orography,byte_limit,1639680,137,413,.true.)
  end function

  integer(int32) function load_global_spectral_state(path,resolution_index,wave_processors,dimensions,configuration,field,loaded_orography,byte_limit,coefficients,levels,records,operational) result(status)
    character(len=*), intent(in) :: path
    integer(int32), intent(in) :: resolution_index, wave_processors
    type(tdimf), intent(in) :: dimensions
    type(grid_field_configuration), intent(in) :: configuration
    type(spectral_field_state), intent(inout) :: field
    integer(int32), intent(inout) :: loaded_orography
    integer(int64), intent(in) :: byte_limit
    integer, intent(in) :: coefficients, levels, records
    logical, intent(in) :: operational
    real(real64), allocatable :: values(:, :)
    integer(int64), allocatable :: metadata(:, :)
    integer(int64) :: messages_read, required
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: child
    integer :: j, ios
    status = 1
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, c_null_char) /= 0) return
    status = 2
    if (resolution_index /= 1 .or. wave_processors /= 1 .or. .not. field%ready) return
    if (field%nspec2 /= coefficients .or. field%nflevg /= levels .or. field%nflevl /= levels) return
    if (dimensions%nfther /= 1 .or. dimensions%ns3d /= 3 .or. dimensions%ns2d /= 2) return
    if (field%ns3d /= 3 .or. field%ns2d /= 2) return
    if (.not. allocated(field%sp3d) .or. .not. allocated(field%sp2d) .or. .not. allocated(field%ngrib)) return
    if (any(shape(field%sp3d) /= [levels, coefficients, 3]) .or. any(shape(field%sp2d) /= [coefficients, 2])) return
    if (size(field%ngrib) < 3) return
    if (any(field%ngrib(1:3) /= [138, 155, 130])) return
    if (configuration%registration%numspflds /= 0) return
    if (configuration%registration%numflds < 0 .or. configuration%registration%numflds > size(configuration%components)) return
    do j = 1, configuration%registration%numflds
      if (configuration%components(j)%lsp /= 0) return
      if (configuration%components(j)%lgp /= 0 .and. configuration%components(j)%nreqin == 1 .and. &
          configuration%components(j)%lgpingp == 0 .and. configuration%components(j)%ltrajio == 0) return
    end do
    required = 8_int64*int(coefficients, int64)*records + 56_int64*records
    status = 3
    if (byte_limit < required) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    allocate (values(coefficients, records), stat=ios)
    if (ios /= 0) goto 900
    allocate (metadata(3, records), stat=ios)
    if (ios /= 0) goto 900
    messages_read = 0
    if (operational) then
      child = read_operational_initial_spectral_fields(path, values, metadata, messages_read)
    else
      child = read_selected_spectral_fields(path, values, metadata, messages_read)
    end if
    status = 10 + child
    if (child /= 0) goto 900
    if (operational) then
      child = place_operational_spectral_fields(values, metadata, field%sp3d, field%sp2d)
    else
      child = place_initial_spectral_fields(values, metadata, field%sp3d, field%sp2d)
    end if
    status = 20 + child
    if (child /= 0) goto 900
    loaded_orography = 1
    status = 0
900 if (allocated(metadata)) deallocate (metadata)
    if (allocated(values)) deallocate (values)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function load_partitioned_operational_spectral_initial_state(path,field,loaded_orography,byte_limit) result(status)
    !! Fixed source2x2 partition:69or68levels,819840coefficients,0or2surface
    !! fields. The native source MYLEVS labels already run from1 to137.
    !! byte_limit includes matrix values, metadata, schema labels and four
    !! temporary map copies. The complete field and flag stay unchanged on error.
    character(len=*), intent(in) :: path
    type(spectral_field_state), intent(inout) :: field
    integer(int32), intent(inout) :: loaded_orography
    integer(int64), intent(in) :: byte_limit
    type(spectral_initial_partition) :: partition
    real(real64), allocatable :: values(:, :)
    integer(int64), allocatable :: metadata(:, :)
    integer(int64) :: messages_read, map_bytes, required
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: child
    integer :: ios
    status = 1
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, c_null_char) /= 0) return
    if (.not. field%ready) return
    status = 23
    if (field%nsmax /= 1279 .or. field%nflevg /= 137 .or. field%nspec2 /= 819840 .or. field%nump /= 640) return
    if (field%nflevl == 69) then
      if (field%ns2d /= 0) return
    else if (field%nflevl == 68) then
      if (field%ns2d /= 2) return
    else
      return
    end if
    map_bytes = max(1_int64, 4_int64*field%nump) + max(1_int64, 4_int64*field%nflevl) + 8_int64*(field%nsmax + 1)
    required = 5417512632_int64 + 13216_int64 + map_bytes
    status = 3
    if (byte_limit < required) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    child = project_owned_spectral_input_partition(partition, field, 1_int32, map_bytes)
    if (child /= 0) then
      if (child /= 1) status = 23
      goto 900
    end if
    allocate (values(1639680, 413), stat=ios)
    if (ios /= 0) goto 900
    allocate (metadata(3, 413), stat=ios)
    if (ios /= 0) goto 900
    messages_read = 0
    child = read_operational_initial_spectral_fields(path, values, metadata, messages_read)
    status = 10 + child
    if (child /= 0) goto 900
    call place_partitioned_spectral_fields(partition, values, metadata, field%sp3d, field%sp2d, child)
    status = 20 + child
    if (child /= 0) goto 900
    loaded_orography = 1
    status = 0
900 if (allocated(metadata)) deallocate (metadata)
    if (allocated(values)) deallocate (values)
    call release_owned_spectral_input_partition(partition)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module forecast_complete_initial_spectral_loading
