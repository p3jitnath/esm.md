module owned_spectral_initial_loading_port
  !! Join the native spectral owner to the unchanged streaming file loader.
  !! Only four small map copies are temporary. They supply metadata, never
  !! decoded fields or a missing numerical stage. The caller owns field state.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use spectral_field_storage_port, only: spectral_field_state
  use initial_field_placement_port, only: spectral_initial_partition
  use streaming_spectral_initial_loading_port, only: load_streaming_runtime_spectral_state
  implicit none
  private
  public :: project_owned_spectral_input_partition, release_owned_spectral_input_partition
  public :: load_owned_streaming_spectral_state
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function project_owned_spectral_input_partition(output, field, level_index_origin, byte_cap) result(status)
    !! output has no map owners. level_index_origin is0 for the serial source
    !! MYLEVS and1 for distributed source MYLEVS. This explicit source policy
    !! converts only integer level labels into the loader's one-based labels.
    !! Field values and ownership do not change. byte_cap bounds four map
    !! payload reservations; caller admits remaining object/runtime memory.
    type(spectral_initial_partition), intent(inout) :: output
    type(spectral_field_state), intent(in) :: field
    integer(int32), intent(in) :: level_index_origin
    integer(int64), intent(in) :: byte_cap
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int64) :: required, coverage, span, global_start
    integer :: ios, n, waves, j, wave, previous, level
    status = 2
   if(allocated(output%waves).or.allocated(output%levels).or.allocated(output%local_first).or.allocated(output%global_first)) return
    if (.not. field%ready) return
    if (level_index_origin < 0 .or. level_index_origin > 1) return
    n = field%nsmax
    if (n < 1 .or. n > 4096 .or. field%nflevg < 1 .or. field%nflevg > 256) return
    if (field%ns3d /= 3 .or. (field%ns2d /= 0 .and. field%ns2d /= 2)) return
if(.not.allocated(field%myms).or..not.allocated(field%mylevs).or..not.allocated(field%nasm0).or..not.allocated(field%nasm0g)) return
    if (.not. allocated(field%ngrib) .or. .not. allocated(field%sp3d) .or. .not. allocated(field%sp2d)) return
    waves = size(field%myms)
    if (waves /= field%nump .or. size(field%mylevs) /= field%nflevl .or. waves > n + 1) return
    if (size(field%nasm0) /= n + 1 .or. size(field%nasm0g) /= n + 1) return
    if (lbound(field%nasm0, 1) /= 0 .or. lbound(field%nasm0g, 1) /= 0) return
    if (size(field%ngrib) /= 5) return
    if (any(field%ngrib /= [138, 155, 130, 152, 129])) return
    if (any(shape(field%sp3d) /= [field%nflevl, field%nspec2, 3])) return
    if (any(shape(field%sp2d) /= [field%nspec2, field%ns2d])) return
    if (int(field%nspec2g, int64) /= int(n + 1, int64)*int(n + 2, int64)) return
    coverage = 0
    do j = 1, waves
      wave = field%myms(j)
      if (wave < 0 .or. wave > n) return
      if (int(field%nasm0(wave), int64) /= coverage + 1) return
      global_start = 1_int64 + int(wave, int64)*int(2*n + 3 - wave, int64)
      if (int(field%nasm0g(wave), int64) /= global_start) return
      span = 2_int64*int(n + 1 - wave, int64)
      coverage = coverage + span
      if (coverage > int(field%nspec2, int64)) return
    end do
    if (coverage /= int(field%nspec2, int64)) return
    previous = 0
    do j = 1, field%nflevl
      if (field%mylevs(j) < level_index_origin .or. field%mylevs(j) > field%nflevg - 1 + level_index_origin) return
      level = field%mylevs(j) + 1 - level_index_origin
      if (level <= previous .or. level > field%nflevg) return
      previous = level
    end do
    required = max(1_int64, 4_int64*waves) + max(1_int64, 4_int64*field%nflevl) + 8_int64*(n + 1)
    if (byte_cap < required) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = 1
    allocate (output%waves(waves), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%levels(field%nflevl), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%local_first(0:n), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%global_first(0:n), stat=ios)
    if (ios /= 0) goto 800
    do j = 1, waves
      output%waves(j) = field%myms(j)
    end do
    do j = 1, field%nflevl
      output%levels(j) = field%mylevs(j) + 1 - level_index_origin
    end do
    do j = 0, n
      output%local_first(j) = field%nasm0(j)
      output%global_first(j) = field%nasm0g(j)
    end do
    output%degree = n; output%global_levels = field%nflevg; output%local_levels = field%nflevl
    output%surface_fields = field%ns2d; output%local_coefficients = field%nspec2; output%global_coefficients = field%nspec2g
    output%field_codes = field%ngrib
    status = 0
    goto 900
800 call release_owned_spectral_input_partition(output)
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  subroutine release_owned_spectral_input_partition(output)
    !! End only this map projection. Source field owners stay unchanged.
    !! Preserve scalar preimages on a failed map acquisition; a successful
    !! projection's scalar labels remain available after its maps are ended.
    type(spectral_initial_partition), intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (allocated(output%global_first)) deallocate (output%global_first)
    if (allocated(output%local_first)) deallocate (output%local_first)
    if (allocated(output%levels)) deallocate (output%levels)
    if (allocated(output%waves)) deallocate (output%waves)
    error_number = saved_errno
    call ieee_set_status(saved)
  end subroutine

  integer(int32) function load_owned_streaming_spectral_state(path,field,level_index_origin,loaded_orography,metadata_byte_cap) result(status)
    !! Load exact file fields into this already initialized native owner.
    !! Return32+projection status or64+streaming status on failure. The
    !! unchanged streaming child owns decoding/placement and atomic output
    !! publication. Its natural returned IEEE/errno state is left unchanged.
    character(len=*), intent(in) :: path
    type(spectral_field_state), intent(inout) :: field
    integer(int32), intent(in) :: level_index_origin
    integer(int32), intent(inout) :: loaded_orography
    integer(int64), intent(in) :: metadata_byte_cap
    type(spectral_initial_partition) :: metadata
    integer(int32) :: rc
    rc = project_owned_spectral_input_partition(metadata, field, level_index_origin, metadata_byte_cap)
    if (rc /= 0) then
      status = 32 + rc
      return
    end if
    rc = load_streaming_runtime_spectral_state(path, metadata, field%sp3d, field%sp2d, loaded_orography)
    call release_owned_spectral_input_partition(metadata)
    status = 0
    if (rc /= 0) status = 64 + rc
  end function
end module owned_spectral_initial_loading_port
