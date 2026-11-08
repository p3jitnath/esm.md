!> Report source forecast progress through native formatted I/O and public FIAT services.
!! Units are already configured by the caller. Diagnostic text is separate from weather output.
module forecast_execution_reporting
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: native_execution_reporting_context, report_execution_progress, report_execution_status
  public :: write_execution_memory_information, close_execution_reporting_status, admit_reporting_context
  type :: native_execution_reporting_context
    integer(int32) :: myproc = 1, nulout = 6, nulerr = 0, nulstat = 1, ifirst = 0
    character(120) :: cndispp = ' '
    real(real64), pointer :: avnrMdiv => null()
  end type
  interface
    subroutine gstats(event, switch)
      import :: int32
      integer(int32), intent(in) :: event, switch
    end subroutine
    subroutine ec_meminfo(unit, prefix, communicator, barrier, io_task, call_kind)
      import :: int32
      integer(int32), intent(in) :: unit, communicator, barrier, io_task, call_kind
      character(*), intent(in) :: prefix
    end subroutine
    subroutine ec_flush(unit)
      import :: int32
      integer(int32), intent(in) :: unit
    end subroutine
    integer(int64) function getmaxhwm()
      import :: int64
    end function
    integer(int64) function getmaxstk()
      import :: int64
    end function
    integer(int64) function getvmpeak()
      import :: int64
    end function
    subroutine ec_pmon(energy, power)
      import :: int64
      integer(int64), intent(out) :: energy, power
    end subroutine
  end interface
contains
  !> Check integer context fields without changing caller state or processor status.
  integer(int32) function admit_reporting_context(context, require_norm) result(status)
    type(native_execution_reporting_context), intent(in) :: context
    logical, intent(in) :: require_norm
    status = 2
    if (context%myproc < 1 .or. min(context%nulout, context%nulerr, context%nulstat) < 0) return
    if (context%ifirst < 0 .or. context%ifirst > 1) return
    if (require_norm) then
      if (.not. associated(context%avnrMdiv)) return
      if (.not. finite_limit(context%avnrMdiv, huge(0.0_real64), .false.)) return
    end if
    status = 0
  end function
  !> LOGDIS: retain date, two internal writes, stderr/memory report and listing order.
  !! Times are seconds. step is 0:25. All arguments and context fields remain unchanged.
  integer(int32) function report_execution_progress(context, step, model_seconds, cpu_first, cpu_second, &
                                                    timer_enabled, date_enabled) result(status)
    type(native_execution_reporting_context), intent(in) :: context
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: model_seconds, cpu_first, cpu_second
    logical, intent(in) :: timer_enabled, date_enabled
    character(10) :: date, time, zone
    integer :: date_values(8), hours, minutes, ierr
    real(real64) :: remaining, elapsed, part
    character(46) :: line
    character(*), parameter :: fmt = "(1X,A,':',A,':',A,' ',A,I5,' H=',I4,':',I2.2,' +CPU=',F7.3)"
    status = 2
    if (admit_reporting_context(context, .false.) /= 0 .or. step < 0 .or. step > 25) return
    if (.not. finite_limit(model_seconds, 1.0e9_real64, .true.)) return
    if (.not. finite_limit(cpu_first, 1.0e12_real64, .false.)) return
    if (.not. finite_limit(cpu_second, 1.0e12_real64, .false.)) return
    call date_and_time(date, time, zone, date_values)
    part = model_seconds/3600.0_real64
    hours = int(part, int32)
    part = real(hours, real64)
    part = part*3600.0_real64
    remaining = model_seconds - part
    part = remaining/60.0_real64
    minutes = int(part, int32)
    elapsed = cpu_second - cpu_first
    write (line, fmt, iostat=ierr) time(1:2), time(3:4), time(5:6), 'STEP', step, hours, minutes, elapsed
    status = 1
    if (ierr /= 0) return
    if (context%myproc == 1) then
      write (context%nulerr, *, iostat=ierr) line
      if (ierr /= 0) return
      status = write_execution_memory_information(context%nulerr, step)
      if (status /= 0) return
    end if
    if (.not. timer_enabled) elapsed = 0.0_real64
    if (.not. date_enabled) time = '0000000000'
    write (line, fmt, iostat=ierr) time(1:2), time(3:4), time(5:6), 'STEP', step, hours, minutes, elapsed
    status = 1
    if (ierr /= 0) return
    write (context%nulout, '(A42)', iostat=ierr) line
    if (ierr == 0) status = 0
  end function
  !> Format the source32-character memory prefix and call actual FIAT MEMINFO/FLUSH.
  integer(int32) function write_execution_memory_information(unit, step) result(status)
    integer(int32), intent(in) :: unit, step
    character(32) :: prefix
    integer :: ierr
    integer(int32) :: communicator
    status = 2
    if (unit < 0 .or. step < 0 .or. step > 25) return
    write (prefix, '(11X,"STEP",I5," :")', iostat=ierr) step
    status = 1
    if (ierr /= 0) return
    communicator = -2
    if (step == 0) communicator = -1
    call ec_meminfo(unit, prefix(1:len_trim(prefix)), communicator, 0_int32, -1_int32, -1_int32)
    call ec_flush(unit)
    status = 0
  end function
  !> OPDIS: emit the hydrostatic status record and update only the owned first-open flag.
  !! CPU and real times are seconds. configuration has9bytes; caller text has1:18 printable bytes.
  integer(int32) function report_execution_status(context, configuration, caller, cpu, pv_cpu, real_time, &
                                                  accumulated_cpu, accumulated_real, step, nonhydrostatic) result(status)
    type(native_execution_reporting_context), intent(inout) :: context
    character(9), intent(in) :: configuration
    character(*), intent(in) :: caller
    real(real64), intent(in) :: cpu, pv_cpu, real_time, accumulated_cpu, accumulated_real
    integer(int32), intent(in) :: step
    logical, intent(in) :: nonhydrostatic
    character(10) :: date, time, zone, accum_cpu_text, accum_real_text
    character(18) :: caller_text
    character(128) :: filename
    character(200) :: message
    character(2) :: heap_unit, stack_unit, virtual_unit
    integer :: date_values(8), i, ierr, prefix_length, n, minutes, seconds, real_minutes, real_seconds, cpu_minutes, cpu_seconds
    integer(int64) :: heap, stack, virtual_memory, energy, power
    real(real64) :: part, remaining
    status = 2
    if (admit_reporting_context(context, .true.) /= 0) return
    if ((step /= -999 .and. (step < 0 .or. step > 25)) .or. nonhydrostatic) return
    if (len(caller) < 1 .or. len(caller) > 18) return
    do i = 1, len(caller)
      if (iachar(caller(i:i)) < 32 .or. iachar(caller(i:i)) > 126) return
    end do
    if (.not. finite_limit(cpu, 1.0e12_real64, .false.)) return
    if (.not. finite_limit(pv_cpu, 1.0e12_real64, .false.)) return
    if (.not. finite_limit(real_time, 1.0e12_real64, .false.)) return
    if (.not. finite_limit(accumulated_cpu, 1.0e9_real64, .true.)) return
    if (.not. finite_limit(accumulated_real, 1.0e9_real64, .true.)) return
    status = 0
    if (context%myproc /= 1) return
    call gstats(1930_int32, 0_int32)
    status = 1
    if (context%ifirst == 0) then
      context%ifirst = 1
      prefix_length = index(context%cndispp, ' ') - 1
      if (prefix_length < 0) prefix_length = 0
      filename = ' '
      if (prefix_length > 0) filename(1:prefix_length) = context%cndispp(1:prefix_length)
      filename(prefix_length + 1:prefix_length + 8) = 'ifs.stat'
      open (unit=context%nulstat, file=filename(1:prefix_length + 8), status='REPLACE', action='WRITE', iostat=ierr)
      if (ierr /= 0) goto 900
    end if
    message = ' '
    caller_text = adjustl(caller)
    call date_and_time(date, time, zone, date_values)
    write (message(2:9), "(A,':',A,':',A)", iostat=ierr) time(1:2), time(3:4), time(5:6)
    if (ierr /= 0) goto 900
    message(11:19) = configuration
    write (message(21:200), '(A,I6)', iostat=ierr) caller_text, step
    if (ierr /= 0) goto 900
    part = accumulated_real/60.0_real64
    minutes = int(part, int32)
    part = real(minutes, real64)
    part = 60.0_real64*part
    remaining = accumulated_real - part
    seconds = int(remaining, int32)
    real_minutes = minutes
    real_seconds = seconds
    part = accumulated_cpu/60.0_real64
    minutes = int(part, int32)
    part = real(minutes, real64)
    part = 60.0_real64*part
    remaining = accumulated_cpu - part
    seconds = int(remaining, int32)
    cpu_minutes = minutes
    cpu_seconds = seconds
    write (accum_real_text, '(I7,":",I2.2)', iostat=ierr) real_minutes, real_seconds
    if (ierr /= 0) goto 900
    write (accum_cpu_text, '(I7,":",I2.2)', iostat=ierr) cpu_minutes, cpu_seconds
    if (ierr /= 0) goto 900
    heap = getmaxhwm()
    if (heap < 10485760_int64) then
      heap = heap/1024_int64
      heap_unit = 'KB'
    else
      heap = heap/1048576_int64
      heap_unit = 'MB'
    end if
    stack = getmaxstk()
    if (stack < 10485760_int64) then
      stack = stack/1024_int64
      stack_unit = 'KB'
    else
      stack = stack/1048576_int64
      stack_unit = 'MB'
    end if
    virtual_memory = getvmpeak()
    if (virtual_memory < 10737418240_int64) then
      virtual_memory = virtual_memory/1048576_int64
      virtual_unit = 'MB'
    else
      virtual_memory = virtual_memory/1073741824_int64
      virtual_unit = 'GB'
    end if
    call ec_pmon(energy, power)
    energy = energy/1000_int64
    n = len_trim(message)
    write (message(n + 1:200), '(3F9.3,2A10,E21.14,43X)', iostat=ierr) &
      pv_cpu, cpu, real_time, accum_cpu_text, accum_real_text, context%avnrMdiv
    if (ierr /= 0) goto 900
    n = len_trim(message) + 1
    write (message(n + 1:200), '(I7,A2,1X,I7,A2,1X,I7,A2,1X,I6,"kJ",1X,I4,"W")', iostat=ierr) &
      heap, heap_unit, stack, stack_unit, virtual_memory, virtual_unit, energy, power
    if (ierr /= 0) goto 900
    write (context%nulstat, '(A)', iostat=ierr) message(1:len_trim(message))
    if (ierr /= 0) goto 900
    flush (context%nulstat)
    status = 0
900 continue
    call gstats(1930_int32, 1_int32)
  end function
  !> Close only this context's status unit; a repeated release succeeds without I/O.
  integer(int32) function close_execution_reporting_status(context) result(status)
    type(native_execution_reporting_context), intent(inout) :: context
    integer :: ierr
    status = 2
    if (context%ifirst < 0 .or. context%ifirst > 1) return
    status = 0
    if (context%ifirst == 0) return
    close (context%nulstat, iostat=ierr)
    if (ierr /= 0) then
      status = 1
      return
    end if
    context%ifirst = 0
  end function
  !> Compare absolute finite FP64 encodings without executing floating-point arithmetic.
  logical function finite_limit(value, limit, nonnegative) result(valid)
    real(real64), intent(in) :: value, limit
    logical, intent(in) :: nonnegative
    integer(int64) :: bits, magnitude, maximum
    bits = transfer(value, bits)
    magnitude = iand(bits, int(z'7FFFFFFFFFFFFFFF', int64))
    maximum = transfer(limit, maximum)
    valid = magnitude <= maximum
    if (nonnegative .and. btest(bits, 63) .and. magnitude /= 0) valid = .false.
  end function
end module forecast_execution_reporting
