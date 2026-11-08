module streaming_spectral_initial_loading_port
  !! Own the operational one-record-at-a-time spectral input transaction.
  !! Port: src/openifs/input/streaming_runtime_spectral_loading.S.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema
  use initial_field_placement_port, only: spectral_initial_partition
  use streaming_spectral_record_reader_port, only: read_streaming_spectral_records
  implicit none
  private
  public :: load_streaming_runtime_spectral_state
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function load_streaming_runtime_spectral_state(path, partition, &
                                                                spectral, surface, loaded_orography) result(status)
    !! spectral has shape(local_levels,local_coefficients,3), ordered as
    !! vorticity, divergence and temperature. surface has shape
    !! (local_coefficients,surface_fields), with zero or two fields ordered
    !! as logarithmic surface pressure and orography. Arrays are contiguous
    !! disjoint owned buffers. The read-only partition owns complete maps.
    !! This native interface replaces the private descriptor/map records.
    !! It accepts degree 1..4096 and global levels 1..256. The caller supplies
    !! round-to-nearest, gradual underflow and FPCR zero. Status 1 refuses
    !! metadata, 2 reports allocation failure, or 16+reader status reports a
    !! file failure. Every failure retains all outputs and the incoming flag.
    !! All decoded values retain their source units and exact bit patterns.
    character(len=*), intent(in) :: path
    type(spectral_initial_partition), intent(in) :: partition
    real(real64), contiguous, intent(inout) :: spectral(:, :, :), surface(:, :)
    integer(int32), intent(inout) :: loaded_orography
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: staged_spectral(:, :, :), staged_surface(:, :)
    integer(int64), allocatable :: metadata(:, :)
    integer(int64) :: messages_read
    type(initial_field_schema) :: schema
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    integer(int32), parameter :: codes(5) = [138, 155, 130, 152, 129]
    integer :: degree, levels, local_levels, k, nwaves, wave, m, j, record, allocation_status, reader_status
    integer(int64) :: global_words, coverage, span, volume_words, volume_space, surface_words, &
                      surface_offset, total_words, records
    status = 1_int32
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, c_null_char) /= 0) return
    degree = partition%degree; levels = partition%global_levels
    local_levels = partition%local_levels; k = partition%local_coefficients
    if (degree < 1 .or. degree > 4096 .or. levels < 1 .or. levels > 256) return
    global_words = int(degree + 1, int64)*int(degree + 2, int64)
    if (partition%global_coefficients /= global_words) return
    if (local_levels < 0 .or. local_levels > levels .or. k < 0) return
    if (int(k, int64) > global_words .or. mod(k, 2) /= 0) return
    if (partition%surface_fields /= 0 .and. partition%surface_fields /= 2) return
    if (any(shape(spectral) /= [local_levels, k, 3])) return
    if (any(shape(surface) /= [k, partition%surface_fields])) return
    if (.not. allocated(partition%waves) .or. .not. allocated(partition%levels)) return
    if (.not. allocated(partition%local_first) .or. .not. allocated(partition%global_first)) return
    if (lbound(partition%waves, 1) /= 1 .or. lbound(partition%levels, 1) /= 1) return
    nwaves = size(partition%waves)
    if (nwaves > degree + 1 .or. size(partition%levels) /= local_levels) return
    if (lbound(partition%local_first, 1) /= 0 .or. ubound(partition%local_first, 1) /= degree) return
    if (lbound(partition%global_first, 1) /= 0 .or. ubound(partition%global_first, 1) /= degree) return
    if (any(partition%field_codes /= codes)) return
    coverage = 0_int64
    do wave = 1, nwaves
      m = partition%waves(wave)
      if (m < 0 .or. m > degree) return
      if (int(partition%local_first(m), int64) /= coverage + 1_int64) return
      if (int(partition%global_first(m), int64) /= 1_int64 + int(m, int64)*(2_int64*degree + 3_int64 - m)) return
      span = 2_int64*(degree + 1 - m)
      coverage = coverage + span
      if (coverage > k) return
    end do
    if (coverage /= k) return
    j = 0
    do wave = 1, local_levels
      if (partition%levels(wave) <= j .or. partition%levels(wave) > levels) return
      j = partition%levels(wave)
    end do
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    volume_words = 3_int64*local_levels*k
    volume_space = max(1_int64, volume_words)
    surface_words = int(partition%surface_fields, int64)*k
    surface_offset = global_words + volume_space
    total_words = surface_offset + max(1_int64, surface_words)
    records = 3_int64*levels + 2_int64
    status = 2_int32
    allocate (workspace(total_words), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (schema%labels(4, records), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (metadata(3, records), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    staged_spectral(1:local_levels, 1:k, 1:3) => workspace(global_words + 1:global_words + volume_words)
    staged_surface(1:k, 1:partition%surface_fields) => workspace(surface_offset + 1:surface_offset + surface_words)
    staged_spectral = spectral
    staged_surface = surface
    schema%value_count = global_words
    schema%metadata_words = 3
    schema%gaussian_order = 0
    schema%labels = 0_int64
    schema%labels(1, 1) = 152_int64; schema%labels(2, 1) = 1_int64
    do j = 1, levels
      do m = 1, 3
        record = 3*(j - 1) + m + 1
        schema%labels(1, record) = int(codes(m), int64)
        schema%labels(2, record) = int(j, int64)
      end do
    end do
    schema%labels(1, records) = 129_int64
    reader_status = read_streaming_spectral_records(path, schema, partition, workspace(1:global_words), &
                                                    staged_spectral, staged_surface, metadata, messages_read)
    if (reader_status /= 0) then
      status = 16_int32 + int(reader_status, int32)
      goto 900
    end if
    spectral = staged_spectral
    surface = staged_surface
    loaded_orography = 1_int32
    status = 0_int32
900 if (allocated(metadata)) deallocate (metadata)
    if (allocated(schema%labels)) deallocate (schema%labels)
    if (allocated(workspace)) deallocate (workspace)
    error_number = saved_errno
    call ieee_set_status(saved_status)
  end function
end module streaming_spectral_initial_loading_port
