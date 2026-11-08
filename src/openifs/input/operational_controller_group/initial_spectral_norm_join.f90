module forecast_initial_spectral_norm_join
  !! Join the actual initialized spectral owner to the source norm stage120.
  !! Result words retain their canonical output order; no private record layout
  !! is used. Values keep the physical units of their corresponding source norm.
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_operational_model_types, only: native_operational_model_configuration
  use spectral_field_storage_port, only: spectral_field_state
  use forecast_selected_spectral_norms, only: spectral_norm_model_controls, spectral_norm_fields
  use forecast_spectral_norm_namespace, only: spectral_norm_persistent_state
  use forecast_distributed_spectral_norms, only: compute_operational_distributed_spectral_norms, &
                                                 compute_runtime_distributed_spectral_norms
  implicit none
  private
  public::native_initial_spectral_norm_state,prepare_initial_input_spectral_norms,compute_initial_input_spectral_norms,release_initial_input_spectral_norms
  type :: native_initial_spectral_norm_state
    real(real64), allocatable :: values(:)
    type(spectral_norm_persistent_state) :: persistent
    logical :: ready = .false.
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function prepare_initial_input_spectral_norms(world, levels, truncation, byte_limit, output) result(status)
    !! Allocate the source positive-zero norm owner before model factory stage10.
    !! LEVELS and TRUNCATION come from the existing initial geometry. OUTPUT is
    !! embedded in the caller's single result owner, so no second outer record
    !! is allocated here. Failure leaves its original fresh state unchanged.
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(in) :: levels, truncation
    integer(int64), intent(in) :: byte_limit
    type(native_initial_spectral_norm_state), intent(inout) :: output
    integer(int32) :: local
    integer(int64) :: words, capacity
    integer :: allocation_status
    local = 2
    if (allocated(output%values) .or. output%ready) goto100
    if (levels < 1 .or. levels > 512 .or. truncation < 1 .or. truncation > 8191) goto100
    words = 6_int64 + 4_int64*levels*(truncation + 2_int64)
    capacity = 8_int64*words
    if (byte_limit < capacity .or. byte_limit > 2_int64**36) goto100
    local = 0
100 status = agree(world, local)
    if (status /= 0) return
    allocate (output%values(words), stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree(world, local)
    if (status /= 0) then
      if (allocated(output%values)) deallocate (output%values)
      return
    end if
    output%values = 0.0_real64
  end function

  integer(int32) function compute_initial_input_spectral_norms(configuration, spectral, world, byte_limit, output) result(status)
    !! All ranks enter together after spectral virtual-temperature conversion.
    !! CONFIGURATION and SPECTRAL are readonly stable TARGET owners. OUTPUT owns
    !! its already allocated result and persistent scalar. PREPARE ran before\n    !! factory stage10; this calculation does not move that source allocation.
    !! BYTE_LIMIT bounds each rank's private norm workspace in bytes. Children
    !! preserve their source field traversal and natural floating-point flags.
    !! The world4 T1279/L137 specialization remains behind runtime dispatch.
    type(native_operational_model_configuration), target, intent(in) :: configuration
    type(spectral_field_state), target, intent(in) :: spectral
    type(MPI_Comm), intent(in) :: world
    integer(int64), intent(in) :: byte_limit
    type(native_initial_spectral_norm_state), target, intent(inout) :: output
    type(spectral_norm_model_controls) :: model
    type(spectral_norm_fields) :: fields
    integer(int32) :: local, controls(6)
    integer :: n, l, nc, ll, world_size, error, allocation_status
    integer(int64) :: words, capacity
    local = 2
    if (.not. allocated(output%values) .or. output%ready) goto100
    if (.not. configuration%ready .or. .not. associated(configuration%initial)) goto100
    if (.not. allocated(configuration%initial%geometry)) goto100
    if (.not. configuration%initial%geometry%initialized) goto100
    if (.not. associated(configuration%partition)) goto100
    if (.not. associated(configuration%partition, configuration%initial%geometry%partition)) goto100
    n = configuration%initial%geometry%dimensions%nsmax
    l = configuration%initial%geometry%dimensions%nflevg
    nc = configuration%partition%nspec2; ll = configuration%partition%nflevl
    if (n < 1 .or. n > 8191 .or. l < 1 .or. l > 512 .or. nc < 0 .or. ll < 0) goto100
    if (byte_limit < 1 .or. byte_limit > 2_int64**36) goto100
    if (.not. allocated(spectral%sp3d) .or. .not. allocated(spectral%sp2d)) goto100
    if (size(spectral%sp3d, 1) /= ll .or. size(spectral%sp3d, 2) /= nc .or. size(spectral%sp3d, 3) < 3) goto100
    if (size(spectral%sp2d, 1) /= nc) goto100
    if (configuration%partition%npsp == 1 .and. size(spectral%sp2d, 2) < 1) goto100
    local = 0
100 status = agree(world, local)
    if (status /= 0) return
    call MPI_Comm_size(world, world_size, error)
    if (error /= MPI_SUCCESS) call MPI_Abort(world, 3, error)
    words = 6_int64 + 4_int64*l*(n + 2_int64)
    capacity = 8_int64*words
    local = 2
    if (byte_limit >= capacity .and. world_size == configuration%initial%geometry%transform_control%nproc) local = 0
    status = agree(world, local)
    if (status /= 0) return
    local = 2
    if (size(output%values, kind=int64) >= words) local = 0
    status = agree(world, local)
    if (status /= 0) return
    model%thermal_fields = configuration%field_dimensions%nfther
    model%pressure_fields = configuration%field_dimensions%nfd2d
    model%spectral_tracers = configuration%fields%registration%numspflds
    model%nonhydrostatic = configuration%dynamics%lnhdyn
    fields%vorticity => spectral%sp3d(:, :, 1)
    fields%divergence => spectral%sp3d(:, :, 2)
    fields%temperature => spectral%sp3d(:, :, 3)
    if (configuration%partition%npsp == 1) fields%surface_pressure => spectral%sp2d(:, 1)
    controls = [0_int32, 0_int32, 0_int32, 0_int32, int(world_size, int32), 0_int32]
    if (world_size == 4 .and. n == 1279 .and. l == 137) then
      call compute_operational_distributed_spectral_norms(world, configuration%initial%geometry, model, fields, controls, &
                                                          output%persistent, output%values, local)
    else
      call compute_runtime_distributed_spectral_norms(world, configuration%initial%geometry, model, fields, controls, &
                                                      output%persistent, output%values, capacity, byte_limit, local)
    end if
    status = agree(world, local)
    if (status == 0) output%ready = .true.
  end function

  integer(int32) function release_initial_input_spectral_norms(output) result(status)
    !! Call after all result borrowers have expired; release no weather array.
    type(native_initial_spectral_norm_state), intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    status = 0
    if (.not. allocated(output%values)) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    deallocate (output%values)
    output%ready = .false.
    call ieee_set_status(saved); error_number = saved_errno
  end function

  integer(int32) function agree(world, local) result(status)
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(in) :: local
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: error, ignored
    call ieee_get_status(saved); call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    call MPI_Allreduce(local, status, 1, MPI_INTEGER4, MPI_MAX, world, error)
    call ieee_set_status(saved); error_number = saved_errno
    if (error /= MPI_SUCCESS) call MPI_Abort(world, 3, ignored)
  end function
end module forecast_initial_spectral_norm_join
