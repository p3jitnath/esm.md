module forecast_native_input_memory
  !! Observe Linux memory limits in the process that will run the decoder.
  !! All sizes are bytes. The caller supplies explicit placement and reserve
  !! budgets; this module does not infer a codec bound from total RAM.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use, intrinsic :: iso_c_binding, only: c_int, c_long, c_ptr, c_null_ptr, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use partitioned_upper_air_input_owner_port, only: upper_air_decoder_memory_admission
  implicit none
  private
  public :: native_input_memory_policy, native_input_memory_sample
  public :: minimum_codec_reserve_bytes, minimum_node_reserve_bytes
  integer(int64), parameter :: minimum_codec_reserve_bytes = 2147483648_int64
  integer(int64), parameter :: minimum_node_reserve_bytes = 34359738368_int64
  public :: observe_native_input_memory, make_upper_air_memory_admission
  public :: admit_native_input_payload, record_native_input_memory_sample

  type :: native_input_memory_policy
    !! The credited nodes are memory-node numbers, not MPI ranks. Their free
    !! memory is counted only when the current process can use every node.
    !! other_live_bytes bounds owned context/workspace outside new field owners.
    integer(int64) :: node_budget_bytes = 0, other_live_bytes = 0
    integer(int64) :: future_reserve_bytes = minimum_node_reserve_bytes, codec_reserve_bytes = minimum_codec_reserve_bytes
    integer(int64) :: maximum_age_seconds = 0
    integer(int32) :: memory_node_count = 0, memory_nodes(64) = 0
  end type

  type :: native_input_memory_sample
    integer(int64) :: physical_total = 0, physical_available = 0
    integer(int64) :: domain_total = 0, domain_free = 0
    integer(int64) :: cgroup_limit = 0, cgroup_headroom = 0, maximum_ancestor_charge = 0
    integer(int64) :: node_limit = 0, available = 0, other_live = 0
    integer(int64) :: future_reserve = 0, codec_reserve = 0, maximum_age_seconds = 0
    integer(int64) :: observed_clock = 0, clock_rate = 0
    integer(int32) :: ancestor_count = 0, memory_policy = -1, memory_node_count = 0
    integer(int32) :: memory_nodes(64) = 0
    character(len=4096) :: cgroup_path = ''
    logical :: ready = .false.
  end type

  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    function public_get_mempolicy(mode, nodemask, maxnode, address, flags) bind(C, name="get_mempolicy") result(code)
      import c_ptr, c_int, c_long
      integer(c_int), intent(out) :: mode
      type(c_ptr), value :: nodemask, address
      integer(c_long), value :: maxnode
      integer(c_int), value :: flags
      integer(c_int) :: code
    end function
  end interface
contains
  integer(int32) function observe_native_input_memory(policy, output) result(status)
    !! Read fresh procfs, sysfs and every cgroup-v2 ancestor in this process.
    !! Require the public default memory policy. Publish only a complete
    !! sample; refusal leaves output unchanged. Save IEEE status and errno
    !! around public queries and file operations. No numerical owner is made.
    type(native_input_memory_policy), intent(in) :: policy
    type(native_input_memory_sample), intent(inout) :: output
    type(native_input_memory_sample) :: proposed
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno, mode, code
    integer(int64) :: total, free, current, high, maximum, limit, headroom, now, rate
    integer :: j, ios, last, slash
    character(len=4096) :: relative, path, parent, allowed
    character(len=32) :: node_number
    logical :: valid, exists

    status = 2
    if (policy%node_budget_bytes <= 0 .or. policy%other_live_bytes < 0) return
  if (policy%future_reserve_bytes < minimum_node_reserve_bytes .or. policy%codec_reserve_bytes < minimum_codec_reserve_bytes) return
    if (policy%maximum_age_seconds < 1 .or. policy%maximum_age_seconds > 120) return
    if (policy%memory_node_count < 1 .or. policy%memory_node_count > 64) return
    do j = 1, policy%memory_node_count
      if (policy%memory_nodes(j) < 0 .or. policy%memory_nodes(j) > 4095) return
      if (j > 1) then
        if (policy%memory_nodes(j) <= policy%memory_nodes(j - 1)) return
      end if
    end do
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    code = public_get_mempolicy(mode, c_null_ptr, 0_c_long, c_null_ptr, 0_c_int)
    if (code /= 0 .or. mode /= 0) goto 900
    proposed%memory_policy = mode
    call read_meminfo('/proc/meminfo', total, free, .true., valid)
    if (.not. valid) goto 900
    proposed%physical_total = total; proposed%physical_available = free
    call read_allowed_memory_nodes(allowed, valid)
    if (.not. valid) goto 900
    do j = 1, policy%memory_node_count
      if (.not. node_is_listed(policy%memory_nodes(j), trim(allowed))) goto 900
      write (node_number, '(i0)', iostat=ios) policy%memory_nodes(j)
      if (ios /= 0) goto 900
      path = '/sys/devices/system/node/node'//trim(node_number)//'/meminfo'
      call read_meminfo(trim(path), total, free, .false., valid)
      if (.not. valid) goto 900
      if (total > huge(0_int64) - proposed%domain_total) goto 900
      if (free > huge(0_int64) - proposed%domain_free) goto 900
      proposed%domain_total = proposed%domain_total + total
      proposed%domain_free = proposed%domain_free + free
    end do
    call read_current_cgroup(relative, valid)
    if (.not. valid) goto 900
    path = '/sys/fs/cgroup'//trim(relative)
    if (len_trim(path) >= len(path)) goto 900
    proposed%cgroup_path = path
    proposed%cgroup_limit = huge(0_int64)
    proposed%cgroup_headroom = huge(0_int64)
    do
      if (trim(path) == '/sys/fs/cgroup') then
        ! The hierarchy root can omit files that apply only below the root.
        current = 0; maximum = huge(0_int64); high = huge(0_int64)
        inquire (file=trim(path)//'/memory.current', exist=exists)
        if (exists) then
          call read_cgroup_word(trim(path)//'/memory.current', current, .false., valid)
          if (.not. valid) goto 900
        end if
        inquire (file=trim(path)//'/memory.max', exist=exists)
        if (exists) then
          call read_cgroup_word(trim(path)//'/memory.max', maximum, .true., valid)
          if (.not. valid) goto 900
        end if
        inquire (file=trim(path)//'/memory.high', exist=exists)
        if (exists) then
          call read_cgroup_word(trim(path)//'/memory.high', high, .true., valid)
          if (.not. valid) goto 900
        end if
      else
        call read_cgroup_word(trim(path)//'/memory.current', current, .false., valid)
        if (.not. valid) goto 900
        call read_cgroup_word(trim(path)//'/memory.max', maximum, .true., valid)
        if (.not. valid) goto 900
        call read_cgroup_word(trim(path)//'/memory.high', high, .true., valid)
        if (.not. valid) goto 900
      end if
      limit = min(maximum, high)
      headroom = max(0_int64, limit - current)
      proposed%cgroup_limit = min(proposed%cgroup_limit, limit)
      proposed%cgroup_headroom = min(proposed%cgroup_headroom, headroom)
      proposed%maximum_ancestor_charge = max(proposed%maximum_ancestor_charge, current)
      proposed%ancestor_count = proposed%ancestor_count + 1
      if (trim(path) == '/sys/fs/cgroup') exit
      last = len_trim(path); slash = index(path(:last), '/', back=.true.)
      if (slash <= len('/sys/fs/cgroup')) then
        path = '/sys/fs/cgroup'
      else
        parent = path(:slash - 1); path = parent
      end if
    end do
    proposed%node_limit = min(policy%node_budget_bytes, proposed%physical_total, proposed%domain_total, proposed%cgroup_limit)
    proposed%available = min(proposed%physical_available, proposed%domain_free, proposed%cgroup_headroom)
    ! Count the complete ancestor charge as other live memory. This can count
    ! already resident destination pages twice, but never adds memory credit.
    proposed%other_live = max(policy%other_live_bytes, proposed%maximum_ancestor_charge)
    ! A complete observation can show insufficient capacity. Admission below
    ! rejects that state before any field or decoder allocation.
    if (proposed%node_limit <= 0) goto 900
    proposed%future_reserve = policy%future_reserve_bytes
    proposed%codec_reserve = policy%codec_reserve_bytes
    proposed%maximum_age_seconds = policy%maximum_age_seconds
    proposed%memory_node_count = policy%memory_node_count
    proposed%memory_nodes = policy%memory_nodes
    call system_clock(now, rate)
    if (now < 0 .or. rate <= 0) goto 900
    proposed%observed_clock = now; proposed%clock_rate = rate
    proposed%ready = .true.
    output = proposed
    status = 0
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function make_upper_air_memory_admission(sample, node_destination_bytes, output) result(status)
    !! Retain the sample's observation clock, so conversion cannot refresh
    !! an old observation. The batch scheduler bounds each active decoder's
    !! destination and point-map faults against the actual physical headroom.
    type(native_input_memory_sample), intent(in) :: sample
    integer(int64), intent(in) :: node_destination_bytes
    type(upper_air_decoder_memory_admission), intent(inout) :: output
    type(upper_air_decoder_memory_admission) :: proposed
    status = 2
    if (.not. sample_is_fresh(sample) .or. node_destination_bytes < 0) return
    if (sample%other_live > sample%node_limit) return
    proposed%node_limit = sample%node_limit; proposed%other_live = sample%other_live
    proposed%available = sample%available; proposed%reserve = sample%future_reserve
    proposed%codec_reserve = sample%codec_reserve
    proposed%observed_clock = sample%observed_clock; proposed%clock_rate = sample%clock_rate
    proposed%maximum_age_seconds = sample%maximum_age_seconds
    output = proposed
    status = 0
  end function

  integer(int32) function admit_native_input_payload(sample, new_node_payload, minimum_decoder_bytes) result(status)
    !! Admit proposed complete node payloads before allocation. The caller
    !! sums all ranks' new owners on their shared-memory node first. Reserve
    !! one decoder only when minimum_decoder_bytes is nonzero. Its external
    !! codec reservation is always separate and explicitly supplied.
    type(native_input_memory_sample), intent(in) :: sample
    integer(int64), intent(in) :: new_node_payload, minimum_decoder_bytes
    integer(int64) :: headroom, needed
    status = 2
    if (.not. sample_is_fresh(sample)) return
    if (new_node_payload < 0 .or. minimum_decoder_bytes < 0) return
    if (sample%other_live > sample%node_limit) return
    headroom = min(sample%node_limit - sample%other_live, sample%available)
    if (sample%future_reserve > headroom) return
    headroom = headroom - sample%future_reserve
    if (new_node_payload > headroom) return
    headroom = headroom - new_node_payload
    if (minimum_decoder_bytes > 0) then
      if (minimum_decoder_bytes > huge(0_int64) - sample%codec_reserve) return
      needed = minimum_decoder_bytes + sample%codec_reserve
      if (needed > headroom) return
    end if
    status = 0
  end function

  integer(int32) function record_native_input_memory_sample(path, sample) result(status)
    !! Write this process's complete observation before a batch. The caller
    !! owns an existing directory and supplies a new, distinct file name for
    !! every rank and batch. Completion is the final line. A partial file is
    !! retained on I/O failure; it cannot admit decoding.
    character(len=*), intent(in) :: path
    type(native_input_memory_sample), intent(in) :: sample
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: unit, ios, j, closed
    status = 2
    if (.not. sample_is_fresh(sample)) return
    if (len_trim(path) < 1 .or. len_trim(path) > 4095 .or. index(path, achar(0)) /= 0) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    open (newunit=unit, file=trim(path), status='new', action='write', iostat=ios)
    if (ios /= 0) goto 900
    write (unit, '(a)', iostat=ios) 'NATIVE_INPUT_MEMORY_OBSERVATION_V1'
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'observed_clock', sample%observed_clock
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'clock_rate', sample%clock_rate
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'maximum_age_seconds', sample%maximum_age_seconds
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'physical_total', sample%physical_total
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'physical_available', sample%physical_available
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'domain_total', sample%domain_total
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'domain_free', sample%domain_free
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'cgroup_limit', sample%cgroup_limit
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'cgroup_headroom', sample%cgroup_headroom
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'maximum_ancestor_charge', sample%maximum_ancestor_charge
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'ancestor_count', sample%ancestor_count
    if (ios == 0) write (unit, '(a,1x,a)', iostat=ios) 'cgroup_path', trim(sample%cgroup_path)
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'memory_policy', sample%memory_policy
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'memory_node_count', sample%memory_node_count
    do j = 1, sample%memory_node_count
      if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'memory_node', sample%memory_nodes(j)
    end do
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'node_limit', sample%node_limit
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'available', sample%available
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'other_live', sample%other_live
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'future_reserve', sample%future_reserve
    if (ios == 0) write (unit, '(a,1x,i0)', iostat=ios) 'codec_reserve', sample%codec_reserve
    if (ios == 0) write (unit, '(a)', iostat=ios) 'COMPLETE'
    close (unit, iostat=closed)
    if (ios == 0 .and. closed == 0) status = 0
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  logical function sample_is_fresh(sample) result(fresh)
    type(native_input_memory_sample), intent(in) :: sample
    integer(int64) :: now, rate
    fresh = .false.
    if (.not. sample%ready .or. sample%clock_rate <= 0) return
    if (sample%maximum_age_seconds < 1 .or. sample%maximum_age_seconds > 120) return
    call system_clock(now, rate)
    if (rate /= sample%clock_rate .or. now < sample%observed_clock) return
    if (rate > huge(0_int64)/sample%maximum_age_seconds) return
    if (now - sample%observed_clock > rate*sample%maximum_age_seconds) return
    fresh = .true.
  end function

  subroutine read_meminfo(path, total, available, global, valid)
    character(len=*), intent(in) :: path
    integer(int64), intent(out) :: total, available
    logical, intent(in) :: global
    logical, intent(out) :: valid
    character(len=1024) :: line
    character(len=8) :: units
    integer :: unit, ios, position, close_status
    integer(int64) :: number
    logical :: have_total, have_available
    total = 0; available = 0; valid = .false.; have_total = .false.; have_available = .false.
    open (newunit=unit, file=path, status='old', action='read', iostat=ios)
    if (ios /= 0) return
    do
      read (unit, '(a)', iostat=ios) line
      if (ios < 0) exit
      if (ios /= 0) exit
      position = index(line, 'MemTotal:')
      if (position > 0) then
        read (line(position + 9:), *, iostat=ios) number, units
        if (ios /= 0 .or. units /= 'kB' .or. number < 0 .or. number > huge(number)/1024) exit
        total = number*1024; have_total = .true.
      end if
      if (global) then
        position = index(line, 'MemAvailable:')
      else
        position = index(line, 'MemFree:')
      end if
      if (position > 0) then
        if (global) then
          read (line(position + 13:), *, iostat=ios) number, units
        else
          read (line(position + 8:), *, iostat=ios) number, units
        end if
        if (ios /= 0 .or. units /= 'kB' .or. number < 0 .or. number > huge(number)/1024) exit
        available = number*1024; have_available = .true.
      end if
    end do
    close (unit, iostat=close_status)
    valid = ios < 0 .and. close_status == 0 .and. have_total .and. have_available .and. total > 0 .and. available <= total
  end subroutine

  subroutine read_current_cgroup(relative, valid)
    character(len=*), intent(out) :: relative
    logical, intent(out) :: valid
    character(len=8192) :: line
    integer :: unit, ios, close_status, n
    relative = ''; valid = .false.
    open (newunit=unit, file='/proc/self/cgroup', status='old', action='read', iostat=ios)
    if (ios /= 0) return
    do
      read (unit, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (line(:3) /= '0::') cycle
      n = len_trim(line) - 3
      if (n < 1 .or. n >= len(relative)) exit
      if (line(4:4) /= '/' .or. index(line(4:3 + n), '..') /= 0) exit
      relative = line(4:3 + n); valid = .true.
      if (relative == '/') relative = ''
      exit
    end do
    close (unit, iostat=close_status)
    if (close_status /= 0) valid = .false.
  end subroutine

  subroutine read_cgroup_word(path, value, allow_max, valid)
    character(len=*), intent(in) :: path
    integer(int64), intent(out) :: value
    logical, intent(in) :: allow_max
    logical, intent(out) :: valid
    character(len=128) :: line
    integer :: unit, ios, close_status, j
    value = 0; valid = .false.
    open (newunit=unit, file=path, status='old', action='read', iostat=ios)
    if (ios /= 0) return
    read (unit, '(a)', iostat=ios) line
    close (unit, iostat=close_status)
    if (ios /= 0 .or. close_status /= 0) return
    if (trim(line) == 'max' .and. allow_max) then
      value = huge(0_int64); valid = .true.; return
    end if
    if (len_trim(line) < 1) return
    do j = 1, len_trim(line)
      if (line(j:j) < '0' .or. line(j:j) > '9') return
    end do
    read (line, *, iostat=ios) value
    valid = ios == 0 .and. value >= 0
  end subroutine

  subroutine read_allowed_memory_nodes(list, valid)
    character(len=*), intent(out) :: list
    logical, intent(out) :: valid
    character(len=8192) :: line
    integer :: unit, ios, close_status, cursor
    list = ''; valid = .false.
    open (newunit=unit, file='/proc/self/status', status='old', action='read', iostat=ios)
    if (ios /= 0) return
    do
      read (unit, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (line(:18) /= 'Mems_allowed_list:') cycle
      cursor = 19
      do while (cursor <= len_trim(line))
        if (line(cursor:cursor) /= ' ' .and. iachar(line(cursor:cursor)) /= 9) exit
        cursor = cursor + 1
      end do
      if (cursor <= len_trim(line)) then
        list = line(cursor:); valid = len_trim(list) > 0
      end if
      exit
    end do
    close (unit, iostat=close_status)
    if (close_status /= 0) valid = .false.
  end subroutine

  logical function node_is_listed(node, list) result(found)
    integer(int32), intent(in) :: node
    character(len=*), intent(in) :: list
    integer :: cursor, first, last, start, finish, ios, n
    found = .false.; cursor = 1; n = len_trim(list)
    do while (cursor <= n)
      start = cursor
      do while (cursor <= n)
        if (list(cursor:cursor) < '0' .or. list(cursor:cursor) > '9') exit
        cursor = cursor + 1
      end do
      if (cursor == start) return
      read (list(start:cursor - 1), *, iostat=ios) first
      if (ios /= 0) return
      last = first
      if (cursor <= n) then
        if (list(cursor:cursor) == '-') then
          cursor = cursor + 1; start = cursor
          do while (cursor <= n)
            if (list(cursor:cursor) < '0' .or. list(cursor:cursor) > '9') exit
            cursor = cursor + 1
          end do
          if (cursor == start) return
          read (list(start:cursor - 1), *, iostat=ios) last
          if (ios /= 0 .or. last < first) return
        end if
      end if
      if (node >= first .and. node <= last) found = .true.
      if (cursor > n) return
      if (list(cursor:cursor) /= ',') then
        found = .false.; return
      end if
      cursor = cursor + 1
    end do
  end function
end module forecast_native_input_memory
