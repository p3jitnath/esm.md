!> Preserve SPCM source order with explicit native fields and real children.
!! The Coriolis auxiliary ZSPAUXG is the SPCSI divergence_tendency argument.
!! It is distinct from the three unconsumed one-by-one diagnostic owners.
submodule(forecast_spectral_calculation_driver) forecast_spectral_calculation_implementation
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use mpi_f08, only: MPI_Initialized, MPI_Comm_size, MPI_Comm_rank, MPI_SUCCESS, operator(==)
  use md2asm_spectral_transposes, only: agree_spectral_partition_status
  use forecast_runtime_spectral_transposes, only: transpose_runtime_modes_to_spectral, &
                                                  transpose_runtime_spectral_to_modes
  use forecast_selected_spectral_children, only: initialize_spectral_coriolis, finish_spectral_coriolis
  use forecast_concrete_spectral_implicit_update, only: apply_concrete_spectral_implicit_update
  use md2asm_spectral_pressure_mass_correction, only: apply_spectral_pressure_mass_correction
  use md2asm_surface_pressure_and_spectral_filter, only: filter_spectral_vorticity
  use forecast_spectral_horizontal_diffusion, only: apply_runtime_spectral_horizontal_diffusion
  use md2asm_transform_profile_policy, only: transform_profile_event, increment_source_counter
  implicit none
  interface
    function spectral_driver_errno_location() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine spectral_driver_statistics(section, event) bind(C, name='gstats_')
      import c_int
      integer(c_int), intent(in) :: section, event
    end subroutine
  end interface
contains
  module procedure advance_spectral_calculations
  type(native_runtime_spectral_fields) :: local, columns
  real(real64), allocatable, target :: zzps(:), zspvorg(:, :), zspdivg(:, :), zsptg(:, :)
  real(real64), allocatable, target :: zspspdg(:, :), zspsvdg(:, :), zspspg(:)
  real(real64), allocatable :: diagnostic_vorticity(:, :), diagnostic_divergence(:, :), diagnostic_temperature(:, :)
  real(real64), allocatable, target :: zspaux(:, :), zspauxg(:, :)
  integer(c_int), pointer, volatile :: errno_target
  integer(c_int) :: saved_errno
  integer(int32) :: local_status, n, l, ll, s, capacity, nspec, self, world, rank, ierr, code, j, m, first
  integer(int64) :: required_bytes, words
  logical :: initialized, opened, owns_pressure, mass_visit
  logical :: selection3d(0), selection2d(0)
  real(real64) :: hook
  status = 2_int32; opened = .false.
  call MPI_Initialized(initialized, ierr)
  if (ierr /= MPI_SUCCESS) return
  if (.not. initialized) return
  if (context%communicator == MPI_COMM_NULL) return
  call MPI_Comm_size(context%communicator, world, ierr)
  if (ierr /= MPI_SUCCESS) return
  call MPI_Comm_rank(context%communicator, rank, ierr)
  if (ierr /= MPI_SUCCESS) return
  local_status = 2_int32
  admission: block
    if (.not. context%ready .or. .not. associated(context%pressure)) exit admission
    if (configuration /= 'A' .and. configuration /= 'I' .and. configuration /= '0') exit admission
    associate (layout => context%pressure%layout)
      n = layout%maximum_degree; l = layout%global_levels; ll = layout%local_levels
      s = layout%local_columns; nspec = layout%spectral_coefficients; self = layout%vertical_index
      if (layout%world /= world .or. layout%rank_zero_based /= rank) exit admission
      if (layout%phase /= 7 .or. .not. layout%geometry_matches) exit admission
      if (n < 1 .or. n > 4096 .or. l < 1 .or. l > 256 .or. ll < 0 .or. ll > l .or. s < 1 .or. nspec < 1) exit admission
      if (self < 1 .or. self > layout%vertical_peers) exit admission
      if (.not. allocated(layout%pressure_partition)) exit admission
      if (size(layout%pressure_partition) < self) exit admission
      owns_pressure = layout%pressure_partition(self) == 1
    end associate
    if (context%temporary_bytes_budget < 1_int64 .or. context%temporary_bytes_budget > 2_int64**36) exit admission
    if (owns_pressure) then
      if (.not. associated(fields%level%surface_pressure)) exit admission
      if (size(fields%level%surface_pressure) /= nspec) exit admission
    end if
    words = int(nspec, int64)
    if (configuration /= '0') then
      if (.not. context%lr3d .or. .not. context%limpf .or. context%lsidg) exit admission
      if (context%lnhdyn .or. context%lnhx .or. context%lnhee .or. context%lrsiddh) exit admission
      if (context%lnhqe .and. .not. context%lnhqe_sihyd) exit admission
      if (context%ncurrent_iter < 0 .or. context%nsiter < context%ncurrent_iter) exit admission
      if (context%level_offset < 0 .or. context%level_offset > l - ll) exit admission
      if (context%vertical_chunk < 1 .or. context%vertical_chunk > 1024) exit admission
      if (.not. associated(context%myms) .or. .not. associated(context%nasm0)) exit admission
      if (.not. associated(context%nvalue) .or. .not. associated(context%nptrsv)) exit admission
      if (lbound(context%nasm0, 1) /= 0 .or. size(context%nasm0) < n + 1) exit admission
      if (size(context%nvalue) /= nspec .or. size(context%myms) > n + 1) exit admission
      if (context%implicit_control%global_levels /= l .or. context%implicit_control%local_levels /= ll) exit admission
      if (context%implicit_control%columns /= s .or. context%implicit_control%degree /= n) exit admission
      if (context%implicit_control%first_column /= 1 .or. context%implicit_control%last_column /= s) exit admission
      if (context%implicit_control%spectral_diagnostics) exit admission
      if (context%implicit_control%full_columns < 0) exit admission
      if (transfer(context%implicit_coefficients%implicit_coefficient, 0_int64) /= &
          transfer(context%pressure%beta_time, 0_int64)) exit admission
      if (transfer(context%implicit_coefficients%time_coefficient, 0_int64) /= &
          transfer(context%pressure%time_step, 0_int64)) exit admission
      if (.not. associated(fields%level%vorticity) .or. .not. associated(fields%level%divergence)) exit admission
      if (.not. associated(fields%level%temperature)) exit admission
      if (size(fields%level%vorticity, 1) < ll .or. size(fields%level%vorticity, 2) /= nspec) exit admission
      if (size(fields%level%divergence, 1) < ll .or. size(fields%level%divergence, 2) /= nspec) exit admission
      if (size(fields%level%temperature, 1) < ll .or. size(fields%level%temperature, 2) /= nspec) exit admission
      if (.not. is_contiguous(fields%level%vorticity) .or. .not. is_contiguous(fields%level%divergence)) exit admission
      if (.not. is_contiguous(fields%level%temperature)) exit admission
      if (lbound(context%myms, 1) /= 1) exit admission
      do j = 1, size(context%myms)
        m = context%myms(j)
        if (m < 0 .or. m > n) exit admission
        first = context%nasm0(m)
        if (first < 1 .or. first > nspec .or. 2_int64*(n - m + 1) > int(nspec, int64) - first + 1) exit admission
      end do
      if (configuration == 'A') then
        if (.not. associated(context%diffusion) .or. .not. associated(context%rcordit)) exit admission
        if (.not. allocated(context%diffusion%rdivor) .or. .not. allocated(context%diffusion%rdidiv)) exit admission
        if (.not. allocated(context%diffusion%rditg)) exit admission
        if (context%lgradsp) then
          if (.not. associated(fields%filtered_vorticity)) exit admission
          if (size(fields%filtered_vorticity, 1) < ll .or. size(fields%filtered_vorticity, 2) < nspec) exit admission
        end if
      end if
      if (context%lmascor .and. .not. context%lgpmascor) then
        if (context%zero_wave_horizontal_owner < 1 .or. &
            context%zero_wave_horizontal_owner > context%pressure%layout%horizontal_peers) exit admission
        if (context%pressure%layout%horizontal_index == context%zero_wave_horizontal_owner .and. owns_pressure) then
          if (context%ncurrent_iter == context%nsiter .and. .not. associated(context%mass)) exit admission
        end if
      end if
      capacity = max(s, context%implicit_control%full_columns)
      if (capacity > 134217728) exit admission
      words = words + 6_int64*l*capacity + int(capacity, int64) + 3_int64 + int(ll, int64)*nspec
    end if
    required_bytes = 8_int64*words
    if (required_bytes > context%temporary_bytes_budget) exit admission
    local_status = 0_int32
  end block admission
  call agree_spectral_partition_status(context%communicator, local_status, status)
  if (status /= 0_int32) return
  call transform_profile_event('SPCM', 0_int32, hook, profile); opened = .true.
  call c_f_pointer(spectral_driver_errno_location(), errno_target)
  saved_errno = errno_target
  allocate (zzps(nspec), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  if (owns_pressure) zzps = fields%level%surface_pressure
  if (configuration == '0') goto700
  ! Preserve the original named-owner allocation order, including inactive SPD/SVD.
  saved_errno = errno_target
  allocate (zspvorg(l, capacity), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (zspdivg(l, capacity), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (zsptg(l, capacity), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (zspspdg(l, capacity), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (zspsvdg(l, capacity), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (zspspg(capacity), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (diagnostic_vorticity(1, 1), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (diagnostic_divergence(1, 1), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (diagnostic_temperature(1, 1), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (zspaux(ll, nspec), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  saved_errno = errno_target
  allocate (zspauxg(l, capacity), stat=code); errno_target = saved_errno
  call allocation_agreement()
  if (status /= 0) goto900
  mass_visit = context%lmascor .and. .not. context%lgpmascor
  mass_visit = mass_visit .and. context%pressure%layout%horizontal_index == context%zero_wave_horizontal_owner
  mass_visit = mass_visit .and. owns_pressure .and. context%ncurrent_iter == context%nsiter
  if (mass_visit) then
    call apply_spectral_pressure_mass_correction(context%nasm0, context%mass%gmassinc, zzps, status)
  end if
  call child_agreement()
  if (status /= 0) goto900
  call spectral_driver_statistics(9_c_int, 0_c_int)
  call spectral_driver_statistics(1022_c_int, 0_c_int)
  do j = 1, size(context%myms)
    m = context%myms(j); first = context%nasm0(m)
    call initialize_spectral_coriolis(n, m, ll, first, context%implicit_coefficients%implicit_coefficient, &
                                      context%implicit_coefficients%time_coefficient, context%pressure%rotation_rate, &
                                      fields%level%vorticity, zspaux, status)
    if (status /= 0) exit
  end do
  call child_agreement()
  if (status /= 0) goto900
  call spectral_driver_statistics(1022_c_int, 1_c_int)
  call spectral_driver_statistics(9_c_int, 2_c_int)
  call spectral_driver_statistics(54_c_int, 0_c_int)
  local%vorticity => fields%level%vorticity; local%divergence => fields%level%divergence
  local%temperature => fields%level%temperature; local%surface_pressure => zzps; local%auxiliary => zspaux
  columns%vorticity => zspvorg(:, 1:s); columns%divergence => zspdivg(:, 1:s)
  columns%temperature => zsptg(:, 1:s); columns%surface_pressure => zspspg(1:s); columns%auxiliary => zspauxg(:, 1:s)
  status = transpose_runtime_modes_to_spectral(context%pressure%layout, context%communicator, local, columns, &
                                               .false., .false., selection3d, selection2d)
  if (status /= 0) goto900
  call spectral_driver_statistics(54_c_int, 2_c_int)
  call spectral_driver_statistics(9_c_int, 3_c_int)
  ! ZSPAUXG is the actual rotation source term, not a diagnostic tendency.
  call apply_concrete_spectral_implicit_update(context%implicit_control, context%implicit_coefficients, &
                           context%vertical_matrices, context%nptrsv, context%nvalue, zspdivg(:, 1:s), zsptg(:, 1:s), zspspg(1:s), &
                                       zspauxg(:, 1:s), int(context%vertical_chunk), context%pressure, context%communicator, status)
  if (status /= 0) goto900
  call spectral_driver_statistics(9_c_int, 2_c_int)
  call spectral_driver_statistics(54_c_int, 3_c_int)
  nullify (local%auxiliary, columns%auxiliary)
  status = transpose_runtime_spectral_to_modes(context%pressure%layout, context%communicator, local, columns, &
                                               .false., .false., selection3d, selection2d, need_surface=.true.)
  if (status /= 0) goto900
  call spectral_driver_statistics(54_c_int, 1_c_int)
  call spectral_driver_statistics(9_c_int, 3_c_int)
  call spectral_driver_statistics(1024_c_int, 0_c_int)
  do j = 1, size(context%myms)
    m = context%myms(j); first = context%nasm0(m)
    call finish_spectral_coriolis(n, m, ll, first, context%implicit_coefficients%implicit_coefficient, &
                                  context%implicit_coefficients%time_coefficient, context%pressure%rotation_rate, &
                                  fields%level%divergence, fields%level%vorticity, status)
    if (status /= 0) exit
  end do
  call child_agreement()
  if (status /= 0) goto900
  call spectral_driver_statistics(1024_c_int, 1_c_int)
  if (configuration == 'A') then
    if (context%lgradsp) then
      call filter_spectral_vorticity(n, 1_int32, nspec, ll, context%nvalue, fields%filtered_vorticity, status)
      call child_agreement()
      if (status /= 0) goto900
    end if
    status = apply_runtime_spectral_horizontal_diffusion(nspec, context%diffusion_switches, ll, n, context%level_offset, &
                            context%myms, context%nasm0, context%implicit_coefficients%time_coefficient, context%diffusion%rdivor, &
                                 context%diffusion%rdidiv, context%diffusion%rditg, context%rcordit, zzps, fields%level%vorticity, &
                                                         fields%level%divergence, fields%level%temperature)
    call child_agreement()
    if (status /= 0) goto900
  end if
  call spectral_driver_statistics(9_c_int, 1_c_int)
700 continue
  if (owns_pressure) fields%level%surface_pressure = zzps
  status = 0_int32
900 continue
  call release_columns()
  saved_errno = errno_target
  if (allocated(zzps)) deallocate (zzps)
  errno_target = saved_errno
  if (opened) call transform_profile_event('SPCM', 1_int32, hook, profile)
  if (status == 0) call increment_source_counter(context%successful_calls)
contains
  subroutine allocation_agreement()
    local_status = 0_int32
    if (code /= 0) local_status = 1_int32
    call agree_spectral_partition_status(context%communicator, local_status, status)
  end subroutine
  subroutine child_agreement()
    local_status = status
    call agree_spectral_partition_status(context%communicator, local_status, status)
  end subroutine
  subroutine release_columns()
    integer(c_int) :: cleanup_errno
    cleanup_errno = errno_target
    if (allocated(zspvorg)) deallocate (zspvorg)
    if (allocated(zspdivg)) deallocate (zspdivg)
    if (allocated(zsptg)) deallocate (zsptg)
    if (allocated(zspspdg)) deallocate (zspspdg)
    if (allocated(zspsvdg)) deallocate (zspsvdg)
    if (allocated(zspspg)) deallocate (zspspg)
    if (allocated(diagnostic_vorticity)) deallocate (diagnostic_vorticity)
    if (allocated(diagnostic_divergence)) deallocate (diagnostic_divergence)
    if (allocated(diagnostic_temperature)) deallocate (diagnostic_temperature)
    if (allocated(zspaux)) deallocate (zspaux)
    if (allocated(zspauxg)) deallocate (zspauxg)
    errno_target = cleanup_errno
  end subroutine
  end procedure advance_spectral_calculations
end submodule forecast_spectral_calculation_implementation
