!> Produce the runtime loop namespace from one canonical forecast model.
module forecast_runtime_loop_binding
  use iso_fortran_env, only: int32, int64, real64
  use forecast_native_loop_data, only: native_loop_data
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_parallel_interpolation_controls, only: parallel_interpolation_controls, &
                                                      first_parallel_namelist_values, read_operational_interpolation_policy
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use physics_configuration_text_port, only: find_physics_group
  implicit none
  private
  public :: initialize_runtime_loop_data
contains
  !> Initialize source scalars and the four conditional filter owners.
  !! STATE is a fresh native_loop_data owner. Its four arrays must be absent
  !! and owned_mask must be zero. MODEL borrows the actual initial prefix,
  !! geometry, vertical owner, public transform and complete partition.
  !! BYTE_LIMIT bounds only the four new FP64 payloads, in bytes.
  !! Global levels are19 or137; the live transform has1:32 processes.
  !! The canonical partition supplies nonnegative local levels and spectral
  !! coefficients. Pressure VP00 is read from geometry%vertical in Pa.
  !! The canonical clock DT is TSTEP in seconds, not its second-step TDT.
  !! All parsing and private allocations precede publication. Return0 means
  !! the source values were produced;1 means allocation failure;2 refuses.
  !! The LGRADSP false route owns no filters and correctly leaves mask zero.
  !! This mask describes allocation ownership and is not a readiness flag.
  integer(int32) function initialize_runtime_loop_data(state, model, byte_limit) result(status)
    type(native_loop_data), intent(inout) :: state
    type(native_operational_model_configuration), target, intent(in) :: model
    integer(int64), intent(in) :: byte_limit
    type(native_loop_data) :: pending
    type(first_parallel_namelist_values) :: parsed
    type(parallel_interpolation_controls) :: policy
    integer(int32) :: parallel(5), nfrres, nrests(0:40)
    integer(int64) :: word, words, required_bytes, global_coefficients
    integer :: allocation_status, configuration_bytes, failure_status
    logical :: valid, lmoderr, ljcdfi, lusejcdfi, lecv
    real(real64) :: restart_seconds, tstep
    status = 2
    if (byte_limit < 0_int64) return
    if (state%owned_mask /= 0_int64) return
    if (allocated(state%spvor_flt) .or. allocated(state%spdiv_flt)) return
    if (allocated(state%spub_flt) .or. allocated(state%spvb_flt)) return
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. allocated(model%initial%prefix) .or. .not. allocated(model%initial%geometry)) return
    if (.not. model%initial%ready .or. .not. model%initial%prefix%ready) return
    if (.not. model%initial%geometry%initialized) return
    if (.not. allocated(model%initial%prefix%vertical)) return
    if (.not. associated(model%initial%geometry%vertical)) return
    if (.not. associated(model%initial%geometry%vertical, model%initial%prefix%vertical)) return
    if (.not. model%initial%geometry%vertical%constructor_ready) return
    if (.not. associated(model%partition)) return
    if (.not. associated(model%partition, model%initial%geometry%partition)) return
    if (model%partition%phase /= 7) return
    associate (initial => model%initial, geometry => model%initial%geometry, &
               partition => model%partition, transform => model%initial%geometry%transform_control)
      if (initial%controls%namespace%nconf /= 1 .or. initial%controls%namespace%lelam /= 0) return
      if (initial%controls%namespace%larpegef /= 0 .or. initial%controls%namespace%lecmwf /= 1) return
      if (initial%controls%namespace%lfdbop /= 0) return
      if (transform%nproc < 1 .or. transform%nproc > 32) return
      if (transform%myproc < 1 .or. transform%myproc > transform%nproc) return
      if (.not. transform%message_ready .or. .not. transform%environment_ready) return
      if (transform%nprtrv < 1 .or. transform%nprtrv > transform%nproc) return
      if (transform%nprtrw < 1 .or. transform%nprtrw > transform%nproc) return
      if (transform%nprtrv*transform%nprtrw /= transform%nproc) return
      if (transform%mysetv < 1 .or. transform%mysetv > transform%nprtrv) return
      if (transform%npromatr < 0 .or. transform%lsplit /= 1) return
      if (geometry%dimensions%nflevg /= 19 .and. geometry%dimensions%nflevg /= 137) return
      if (geometry%vertical%levels /= geometry%dimensions%nflevg) return
      if (geometry%dimensions%nsmax < 1) return
      global_coefficients = int(geometry%dimensions%nsmax, int64) + 1_int64
      global_coefficients = global_coefficients*(int(geometry%dimensions%nsmax, int64) + 2_int64)
      if (global_coefficients /= int(geometry%dimensions%nspec2g, int64)) return
      if (partition%borrowed_resolution /= geometry%transform_resolution%resolution) return
      if (geometry%transform_resolution%resolution < 1) return
      if (partition%nflevl < 0 .or. partition%nflevl > geometry%dimensions%nflevg) return
      if (partition%nflsur < 0 .or. partition%nflsur > geometry%dimensions%nflevg) return
      if (partition%nspec2 < 0 .or. int(partition%nspec2, int64) > global_coefficients) return
      if (model%nudging%lnudg) return
      word = transfer(geometry%vertical%vp00, 0_int64)
      if (word <= 0_int64 .or. word > int(z'41cdcd6500000000', int64)) return
      tstep = initial%controls%clock%dt
      word = transfer(tstep, 0_int64)
      if (word < int(z'3ff0000000000000', int64) .or. word > int(z'40f5180000000000', int64)) return
      configuration_bytes = initial%prefix%configuration_bytes
      if (configuration_bytes < 1 .or. configuration_bytes > len(initial%prefix%configuration_text)) return
      associate (text => initial%prefix%configuration_text(1:configuration_bytes))
        ! SUMP0 supplies these defaults before the actual first NAMPAR1.
        parallel = [1_int32, 0_int32, 1_int32, 0_int32, -1_int32]
        policy = parallel_interpolation_controls()
        status = read_operational_interpolation_policy(text, policy, parsed)
        if (status /= 0) return
        status = 2
        if (parsed%present(1)) parallel(1) = merge(1_int32, 0_int32, parsed%lsplit)
        if (parsed%present(2)) parallel(2) = parsed%nfldin
        if (parsed%present(3)) parallel(3) = parsed%nstrin
        if (parsed%present(4)) parallel(4) = parsed%nstrout
        if (parsed%present(5)) parallel(5) = parsed%nouttype
        if (any(parallel /= [1_int32, 0_int32, 1_int32, 0_int32, 1_int32])) return
        if (require_empty_physics_group(text, 'NAMGWDIAG') /= 0) return
        if (require_empty_physics_group(text, 'NAMIAU') /= 0) return
        if (require_empty_physics_group(text, 'NAMRLX') /= 0) return
        if (require_empty_physics_group(text, 'NAMVAREPS') /= 0) return
        if (require_empty_physics_group(text, 'NAMPPC') /= 0) return
        call read_runtime_variational_group(text, lmoderr, ljcdfi, lusejcdfi, lecv, valid)
        if (.not. valid) return
        if (lmoderr .or. ljcdfi .or. lusejcdfi .or. lecv) return
        if (initial%initialization%lmoderr /= merge(1_int32, 0_int32, lmoderr)) return
        if (initial%initialization%ljcdfi /= merge(1_int32, 0_int32, ljcdfi)) return
        if (initial%initialization%lusejcdfi /= merge(1_int32, 0_int32, lusejcdfi)) return
        if (initial%initialization%lecv /= merge(1_int32, 0_int32, lecv)) return
        call read_runtime_restart_group(text, nfrres, nrests, valid)
        if (.not. valid) return
        if (nfrres == 0 .or. nfrres == -huge(nfrres) - 1) return
        failure_status = 1
        ! SUALSPA leaves all fresh filter owners absent when LGRADSP is false.
        if (model%dynamics%lgradsp) then
          words = 2_int64*int(partition%nflsur, int64)*int(partition%nspec2, int64)
          words = words + 2_int64*int(partition%nflevl, int64)
          if (words > huge(required_bytes)/8_int64) return
          required_bytes = 8_int64*words
          if (required_bytes > byte_limit) return
          allocate (pending%spvor_flt(partition%nflsur, partition%nspec2), stat=allocation_status)
          if (allocation_status /= 0) goto900
          pending%spvor_flt = 0.0_real64
          allocate (pending%spdiv_flt(partition%nflsur, partition%nspec2), stat=allocation_status)
          if (allocation_status /= 0) goto900
          pending%spdiv_flt = 0.0_real64
          allocate (pending%spub_flt(partition%nflevl), stat=allocation_status)
          if (allocation_status /= 0) goto900
          pending%spub_flt = 0.0_real64
          allocate (pending%spvb_flt(partition%nflevl), stat=allocation_status)
          if (allocation_status /= 0) goto900
          pending%spvb_flt = 0.0_real64
          pending%owned_mask = 15_int64
        end if
        if (nfrres < 0) then
          ! Preserve the selected source position after all private allocations.
          ! SURES retains the multiply, add, divide and integer truncation.
          restart_seconds = real(-nfrres, real64)*3600.0_real64
          restart_seconds = restart_seconds + 0.5_real64
          restart_seconds = restart_seconds/tstep
          if (restart_seconds > real(huge(nfrres), real64)) then
            failure_status = 2; goto900
          end if
          nfrres = int(restart_seconds, int32)
          if (nfrres < 1) then
            failure_status = 2; goto900
          end if
        end if
        pending%lejk = .false.
        pending%lgwdiags_on = .false.
        pending%liau = .false.
        pending%mysetv = transform%mysetv
        pending%nouttype = parallel(5)
        pending%nprtrn = transform%nprtrv
        pending%nprtrv = transform%nprtrv
        pending%lnudg = model%nudging%lnudg
        pending%nrsaccfrq = 0
        pending%nfrres = nfrres
        pending%lrlxg = .false.
        pending%restart = '0'
        pending%npromatr = transform%npromatr
        pending%lecv = initial%initialization%lecv /= 0
        pending%lmoderr = initial%initialization%lmoderr /= 0
        pending%lvareps = .false.
        pending%vp00 = geometry%vertical%vp00
        pending%nrests = nrests
      end associate
    end associate
    state%lejk = pending%lejk
    state%lgwdiags_on = pending%lgwdiags_on
    state%liau = pending%liau
    state%mysetv = pending%mysetv
    state%nouttype = pending%nouttype
    state%nprtrn = pending%nprtrn
    state%nprtrv = pending%nprtrv
    state%lnudg = pending%lnudg
    state%nrsaccfrq = pending%nrsaccfrq
    state%nfrres = pending%nfrres
    state%lrlxg = pending%lrlxg
    state%restart = pending%restart
    state%npromatr = pending%npromatr
    state%lecv = pending%lecv
    state%lmoderr = pending%lmoderr
    state%lvareps = pending%lvareps
    state%vp00 = pending%vp00
    state%nrests = pending%nrests
    call move_alloc(pending%spvor_flt, state%spvor_flt)
    call move_alloc(pending%spdiv_flt, state%spdiv_flt)
    call move_alloc(pending%spub_flt, state%spub_flt)
    call move_alloc(pending%spvb_flt, state%spvb_flt)
    state%owned_mask = pending%owned_mask
    status = 0
    return
900 continue
    ! Match the selected source failure path's forward owner order.
    if (allocated(pending%spvor_flt)) deallocate (pending%spvor_flt)
    if (allocated(pending%spdiv_flt)) deallocate (pending%spdiv_flt)
    if (allocated(pending%spub_flt)) deallocate (pending%spub_flt)
    if (allocated(pending%spvb_flt)) deallocate (pending%spvb_flt)
    status = failure_status
  end function

  !> Extract one bounded first group with the accepted source marker rule.
  !! BUFFER is private language-parser work, with no retained data owner.
  !! Supported groups contain only integer, logical and array assignments.
  subroutine first_runtime_group(text, name, buffer, bytes, valid)
    character(*), intent(in) :: text, name
    character(*), intent(out) :: buffer
    integer, intent(out) :: bytes
    logical, intent(out) :: valid
    integer :: first, last, j, needed
    logical :: comment
    valid = .false.; bytes = 0; buffer = ' '
    if (len(text) < 1 .or. len(text) > 262144) return
    first = find_physics_group(text, name, .true.)
    if (first == 0) return
    comment = .false.; last = 0
    do j = first, len(text)
      if (comment) then
        if (text(j:j) == achar(10) .or. text(j:j) == achar(13)) comment = .false.
        cycle
      end if
      if (text(j:j) == '!') then
        comment = .true.; cycle
      end if
      if (text(j:j) == achar(34) .or. text(j:j) == achar(39)) return
      if (text(j:j) == '/') then
        last = j; exit
      end if
    end do
    if (last == 0) return
    needed = len_trim(name) + 2 + last - first + 1
    if (needed > len(buffer)) return
    buffer(1:needed) = '&'//trim(name)//' '//text(first:last)
    bytes = needed; valid = .true.
  end subroutine

  !> Read only the actual supported NAMVAR keys and retain source defaults.
  subroutine read_runtime_variational_group(text, lmoderr, ljcdfi, lusejcdfi, lecv, valid)
    character(*), intent(in) :: text
    logical, intent(out) :: lmoderr, ljcdfi, lusejcdfi, lecv, valid
    character(262160) :: buffer
    integer :: bytes, io
    namelist /NAMVAR/ lmoderr, ljcdfi, lusejcdfi, lecv
    lmoderr = .false.; ljcdfi = .false.; lusejcdfi = .false.; lecv = .false.
    call first_runtime_group(text, 'NAMVAR', buffer, bytes, valid)
    if (.not. valid) return
    read (buffer(1:bytes), nml=NAMVAR, iostat=io)
    valid = io == 0
  end subroutine

  !> Apply only NFRRES and NRESTS from the first source NAMRES.
  !! NRESTS retains its declared0:40 bounds and unassigned trailing values.
  subroutine read_runtime_restart_group(text, nfrres, nrests, valid)
    character(*), intent(in) :: text
    integer(int32), intent(out) :: nfrres, nrests(0:40)
    logical, intent(out) :: valid
    character(262160) :: buffer
    integer :: bytes, io
    namelist /NAMRES/ nfrres, nrests
    nfrres = -48; nrests = 0
    call first_runtime_group(text, 'NAMRES', buffer, bytes, valid)
    if (.not. valid) return
    read (buffer(1:bytes), nml=NAMRES, iostat=io)
    valid = io == 0
  end subroutine
end module forecast_runtime_loop_binding
