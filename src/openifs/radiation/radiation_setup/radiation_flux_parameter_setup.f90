!> Own source-ordered radiation frequencies and native flux-array lifetimes.
module radiation_flux_parameter_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_double, c_f_pointer, c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_all, ieee_underflow, ieee_inexact
  use yomradf, only: tradf
  use yoerad, only: terad
  use yoe_uvrad, only: teuvrad
  use physical_constant_setup_port, only: forecast_physical_constants
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record
  implicit none
  private
  public :: radiation_frequency_choices, radiation_frequency_counts
  public :: calculate_radiation_frequency_counts
  public :: create_runtime_radiation_flux_owners, release_selected_radiation_fluxes
  public :: initialize_selected_radiation_fluxes
  type :: radiation_frequency_choices
    integer(int32) :: nradfr, nradpfr, nradpla, nraduv, nlngr1h
  end type
  type :: radiation_frequency_counts
    integer(int32) :: nradfr, nradpfr, nradpla, nraduv, nradnfr, nradsfr, nrade1h, nrade3h, nlngr1h
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
    function public_fmod(first, second) bind(C, name='fmod') result(remainder)
      import :: c_double
      real(c_double), value :: first, second
      real(c_double) :: remainder
    end function
  end interface
contains
  !> Convert source radiation periods to step counts without public stores.
  !! HOUR and TIMESTEP are seconds. HOUR must be3600 and TIMESTEP1:3600.
  !! CHOICES carries five source int32 namelist choices. Negative radiation
  !! periods are hours; positive periods already count model steps.
  !! COUNTS is caller-owned INOUT and commits only on return0. Return2 for
  !! unsupported input or an invalid hourly schedule. ALLOW_HOUR_SEARCH
  !! selects the existing runtime divisor search; false is the selected
  !! nineteen-level route. Each conversion keeps the source add/truncate
  !! order. Public FMOD supplies the unchanged remainder calculation.
  integer(int32) function calculate_radiation_frequency_counts(hour, timestep, choices, counts, allow_hour_search) result(status)
    real(real64), intent(in) :: hour, timestep
    type(radiation_frequency_choices), intent(in) :: choices
    type(radiation_frequency_counts), intent(inout) :: counts
    logical, intent(in) :: allow_hour_search
    type(radiation_frequency_counts) :: staged
    integer(int64) :: timestep_word
    integer(int32) :: one_hour, long_period
    real(real64) :: step, steps_per_hour, temporary, remainder
    status = 2_int32
    if (transfer(hour, 0_int64) /= int(z'40ac200000000000', int64)) return
    timestep_word = transfer(timestep, 0_int64)
    if (timestep_word < int(z'3ff0000000000000', int64) .or. timestep_word > int(z'40ac200000000000', int64)) return
    if (choices%nradfr == 0 .or. choices%nradfr < -65535 .or. choices%nradfr > 65535) return
    if (choices%nradpfr < 0 .or. choices%nradpfr > 8) return
    if (choices%nradpla < 0 .or. choices%nradpla > 65535) return
    if (choices%nraduv < -65535 .or. choices%nraduv > 65535) return
    if (choices%nlngr1h < 1 .or. choices%nlngr1h > 64) return
    if (.not. supported_floating_mode()) return
    step = max(timestep, 1.0_real64)
    steps_per_hour = hour/step
    staged%nradfr = choices%nradfr
    if (staged%nradfr < 0) then
      temporary = real(-staged%nradfr, real64)*steps_per_hour
      temporary = temporary + 0.5_real64
      staged%nradfr = int(temporary, int32)
    end if
    staged%nradpfr = choices%nradpfr*staged%nradfr
    staged%nradpla = choices%nradpla
    if (staged%nradpla /= 0 .and. iand(staged%nradpla, 1_int32) == 0) staged%nradpla = staged%nradpla + 1
    staged%nraduv = choices%nraduv
    if (staged%nraduv < 0) then
      temporary = real(-staged%nraduv, real64)*steps_per_hour
      temporary = temporary + 0.5_real64
      staged%nraduv = int(temporary, int32)
    end if
    temporary = steps_per_hour + 0.05_real64
    one_hour = int(temporary, int32)
    temporary = real(choices%nlngr1h, real64)*steps_per_hour
    temporary = temporary + 0.05_real64
    long_period = int(temporary, int32)
    remainder = public_fmod(hour, step)
    if (remainder > 0.1_real64) then
      if (.not. allow_hour_search) return
      if (long_period <= one_hour) return
      do
        one_hour = one_hour + 1
        if (mod(long_period, one_hour) == 0) exit
      end do
    end if
    staged%nradnfr = staged%nradfr
    if (staged%nradfr == 1) then
      staged%nradsfr = staged%nradfr
    else
      staged%nradsfr = one_hour
    end if
    staged%nrade1h = one_hour
    staged%nrade3h = one_hour + 2*one_hour
    staged%nlngr1h = choices%nlngr1h
    counts = staged
    status = 0_int32
  end function

  !> Allocate the21source owners using live native dimensions and a byte quota.
  !! OUTPUT is a fresh caller-owned TRADF. All23associations must be absent.
  !! NPROMA1:4096,LEVELS1:512 and positive BLOCKS are int32. LONGWAVE_OUTPUTS
  !! is1or6,as admitted by the enclosing physical-control producer.
  !! APPROXIMATE_LONGWAVE_UPDATE selects the full derivative owner or its
  !! source1by1by1inactive owner. BYTE_QUOTA is positive and at most64GiB.
  !! Allocate privately in source order,zero only TAUAER,then commit named
  !! owners. Failure returns1 with complete public output unchanged; return2
  !! rejects before allocation. Preserve source-unwritten payloads and both
  !! unused EMTU/RMOON descriptors. Only native compiler descriptors are used.
  integer(int32) function create_runtime_radiation_flux_owners(output, nproma, levels, blocks, &
                                                           longwave_outputs, approximate_longwave_update, byte_quota) result(status)
    type(tradf), intent(inout) :: output
    integer(int32), intent(in) :: nproma, levels, blocks, longwave_outputs
    logical, intent(in) :: approximate_longwave_update
    integer(int64), intent(in) :: byte_quota
    type(tradf) :: staged
    integer :: allocation_status
    integer(int32) :: derivative_columns, derivative_levels, derivative_blocks, release_result
    integer(int64) :: total_bytes, payload_bytes
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno, failure_errno
    logical :: incoming_flags(size(ieee_all))
    status = 2_int32
    if (nproma < 1 .or. nproma > 4096 .or. levels < 1 .or. levels > 512 .or. blocks < 1) return
    if (longwave_outputs /= 1 .and. longwave_outputs /= 6) return
    if (byte_quota < 1_int64 .or. byte_quota > shiftl(1_int64, 36)) return
    if (.not. fresh(output)) return
    derivative_columns = 1; derivative_levels = 1; derivative_blocks = 1
    if (approximate_longwave_update) then
      derivative_columns = nproma; derivative_levels = levels + 1; derivative_blocks = blocks
    end if
    total_bytes = 0_int64
    payload_bytes = int(nproma, int64)*int(levels + 1, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(levels + 1, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(levels + 1, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(levels + 1, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(levels, int64)*int(6, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(longwave_outputs, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(nproma, int64)*int(blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    payload_bytes = int(derivative_columns, int64)*int(derivative_levels, int64)*int(derivative_blocks, int64)*8_int64
    total_bytes = total_bytes + payload_bytes
    if (total_bytes > byte_quota) return
    if (.not. supported_floating_mode()) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    acquire: block
      allocate (staged%emtd(nproma, levels + 1, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%trsw(nproma, levels + 1, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%emtc(nproma, levels + 1, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%trsc(nproma, levels + 1, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%tauaer(nproma, levels, 6, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      staged%tauaer = 0.0_real64
      allocate (staged%srswd(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswdc(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srlwd(nproma, longwave_outputs, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srlwdc(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswdcs(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srlwdcs(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswdv(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswduv(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%edro(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswpar(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswuvb(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswparc(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srswtinc(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srfdir(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%srcdir(nproma, blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      allocate (staged%derivativelw(derivative_columns, derivative_levels, derivative_blocks), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      call move_alloc(staged%emtd, output%emtd)
      call move_alloc(staged%trsw, output%trsw)
      call move_alloc(staged%emtc, output%emtc)
      call move_alloc(staged%trsc, output%trsc)
      call move_alloc(staged%tauaer, output%tauaer)
      call move_alloc(staged%srswd, output%srswd)
      call move_alloc(staged%srswdc, output%srswdc)
      call move_alloc(staged%srlwd, output%srlwd)
      call move_alloc(staged%srlwdc, output%srlwdc)
      call move_alloc(staged%srswdcs, output%srswdcs)
      call move_alloc(staged%srlwdcs, output%srlwdcs)
      call move_alloc(staged%srswdv, output%srswdv)
      call move_alloc(staged%srswduv, output%srswduv)
      call move_alloc(staged%edro, output%edro)
      call move_alloc(staged%srswpar, output%srswpar)
      call move_alloc(staged%srswuvb, output%srswuvb)
      call move_alloc(staged%srswparc, output%srswparc)
      call move_alloc(staged%srswtinc, output%srswtinc)
      call move_alloc(staged%srfdir, output%srfdir)
      call move_alloc(staged%srcdir, output%srcdir)
      output%derivativelw => staged%derivativelw
      nullify (staged%derivativelw)
      call ieee_set_flag(ieee_all, incoming_flags)
      errno_value = incoming_errno
      status = 0_int32
      return
    end block acquire
    failure_errno = errno_value
    release_result = release_selected_radiation_fluxes(staged)
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = failure_errno
    status = 1_int32
  end function

  !> Release the21owned arrays in source order and accept repeated release.
  !! OUTPUT remains caller-owned. EMTU,RMOON and all scalar/metadata fields
  !! outside the released associations retain their incoming bytes.
  !! Incoming FP flags and errno remain intact. Return0or1on native failure.
  integer(int32) function release_selected_radiation_fluxes(output) result(status)
    type(tradf), intent(inout) :: output
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer :: release_status
    logical :: incoming_flags(size(ieee_all))
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    status = 0_int32
    if (allocated(output%emtd)) then
      deallocate (output%emtd, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%trsw)) then
      deallocate (output%trsw, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%emtc)) then
      deallocate (output%emtc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%trsc)) then
      deallocate (output%trsc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%tauaer)) then
      deallocate (output%tauaer, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswd)) then
      deallocate (output%srswd, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswdc)) then
      deallocate (output%srswdc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srlwd)) then
      deallocate (output%srlwd, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srlwdc)) then
      deallocate (output%srlwdc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswdcs)) then
      deallocate (output%srswdcs, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srlwdcs)) then
      deallocate (output%srlwdcs, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswdv)) then
      deallocate (output%srswdv, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswduv)) then
      deallocate (output%srswduv, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%edro)) then
      deallocate (output%edro, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswpar)) then
      deallocate (output%srswpar, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswuvb)) then
      deallocate (output%srswuvb, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswparc)) then
      deallocate (output%srswparc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srswtinc)) then
      deallocate (output%srswtinc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srfdir)) then
      deallocate (output%srfdir, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(output%srcdir)) then
      deallocate (output%srcdir, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (associated(output%derivativelw)) then
      deallocate (output%derivativelw, stat=release_status)
      if (release_status /= 0) status = 1_int32
      if (release_status == 0) nullify (output%derivativelw)
    end if
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = incoming_errno
  end function

  logical function fresh(output) result(empty)
    type(tradf), intent(in) :: output
    empty = .false.
    if (allocated(output%emtd)) return
    if (allocated(output%trsw)) return
    if (allocated(output%emtc)) return
    if (allocated(output%trsc)) return
    if (allocated(output%tauaer)) return
    if (allocated(output%srswd)) return
    if (allocated(output%srswdc)) return
    if (allocated(output%srlwd)) return
    if (allocated(output%srlwdc)) return
    if (allocated(output%srswdcs)) return
    if (allocated(output%srlwdcs)) return
    if (allocated(output%srswdv)) return
    if (allocated(output%srswduv)) return
    if (allocated(output%edro)) return
    if (allocated(output%srswpar)) return
    if (allocated(output%srswuvb)) return
    if (allocated(output%srswparc)) return
    if (allocated(output%srswtinc)) return
    if (allocated(output%srfdir)) return
    if (allocated(output%srcdir)) return
    if (associated(output%derivativelw)) return
    if (allocated(output%emtu)) return
    if (allocated(output%rmoon)) return
    empty = .true.
  end function

  !> Compose the original selected frequency and21-owner allocation phase.
  !! UPSTREAM supplies live19level,T21 dimensions and an admitted timestep.
  !! RADIATION and UV are at the declared pre-frequency source point.
  !! OUTPUT,records,constants and upstream are separate complete native
  !! objects. Quota bounds the native allocation total before any allocation.
  !! Frequency stores commit only after all owners succeed. Return0/1/2.
 integer(int32) function initialize_selected_radiation_fluxes(output, radiation, uv, constants, upstream, byte_quota) result(status)
    type(tradf), intent(inout), target :: output
    type(terad), intent(inout), target :: radiation
    type(teuvrad), intent(inout), target :: uv
    type(forecast_physical_constants), intent(in), target :: constants
    type(radiation_control_upstream_record), intent(in), target :: upstream
    integer(int64), intent(in) :: byte_quota
    type(radiation_frequency_choices) :: choices
    type(radiation_frequency_counts) :: counts
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer(c_intptr_t) :: addresses(5)
    integer(int64) :: lengths(5)
    integer :: first, second
    status = 2_int32
    if (.not. upstream%lecmwf .or. upstream%larpegef .or. .not. upstream%lephys) return
    if (upstream%lrayfm .or. .not. upstream%lopt_scalar .or. upstream%lape .or. upstream%lhlradupd) return
    if (upstream%lray .or. upstream%laeruvp .or. .not. upstream%leradi .or. upstream%leradlw2) return
    if (upstream%nemissscheme /= 0 .or. upstream%leradn2) return
    if (upstream%nproma /= 24 .or. upstream%nsmax /= 21 .or. upstream%ndglg /= 32) return
    if (upstream%ngptot /= 2048 .or. upstream%ngptotmx /= 2048 .or. upstream%nflevg /= 19) return
    if (upstream%ngpblks /= 86 .or. upstream%ndlon /= 64) return
    select case (transfer(upstream%timestep, 0_int64))
    case (int(z'4082c00000000000', int64), int(z'408c200000000000', int64), &
          int(z'409c200000000000', int64), int(z'40ac200000000000', int64))
    case default
      return
    end select
    if (radiation%nradfr /= -1 .or. radiation%nradpfr /= 0 .or. radiation%nradpla /= 15) return
    if (radiation%nlngr1h /= 12 .or. radiation%nlwout /= 1 .or. .not. radiation%lapproxlwupdate) return
    if (uv%nraduv /= -1) return
    addresses = [transfer(c_loc(output), 0_c_intptr_t), transfer(c_loc(radiation), 0_c_intptr_t), &
               transfer(c_loc(uv), 0_c_intptr_t), transfer(c_loc(constants), 0_c_intptr_t), transfer(c_loc(upstream), 0_c_intptr_t)]
    lengths = [storage_size(output, kind=int64)/8_int64, storage_size(radiation, kind=int64)/8_int64, &
      storage_size(uv, kind=int64)/8_int64, storage_size(constants, kind=int64)/8_int64, storage_size(upstream, kind=int64)/8_int64]
    do first = 1, 4
      do second = first + 1, 5
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. fresh(output)) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    choices%nradfr = radiation%nradfr; choices%nradpfr = radiation%nradpfr
    choices%nradpla = radiation%nradpla; choices%nraduv = uv%nraduv; choices%nlngr1h = radiation%nlngr1h
    status = calculate_radiation_frequency_counts(constants%rhour, upstream%timestep, choices, counts, .false.)
    if (status /= 0_int32) then
      errno_value = incoming_errno
      return
    end if
    status = create_runtime_radiation_flux_owners(output, upstream%nproma, upstream%nflevg, upstream%ngpblks, &
                                                  radiation%nlwout, radiation%lapproxlwupdate, byte_quota)
    if (status /= 0_int32) return
    radiation%nradfr = counts%nradfr; radiation%nradpfr = counts%nradpfr; radiation%nradpla = counts%nradpla
    radiation%nradnfr = counts%nradnfr; radiation%nradsfr = counts%nradsfr
    radiation%nrade1h = counts%nrade1h; radiation%nrade3h = counts%nrade3h
    uv%nraduv = counts%nraduv
    errno_value = incoming_errno
    status = 0_int32
  end function

  !> Check native storage without constructing a private target layout.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Require nearest rounding and gradual underflow without changing flags.
  !! The launcher establishes the complete target floating-point contract.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module
