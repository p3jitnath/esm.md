!> Create the source distributed public environment from live process controls.
module forecast_distributed_transform_environment
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_process_controls, only: native_process_control, read_distributed_process_controls
  use forecast_process_partition_factors, only: native_process_partition_factors, derive_runtime_process_partitions
  use forecast_transform_configuration, only: require_empty_transform_group, require_operational_transform_group
  use physics_configuration_text_port, only: skip_physics_space, physics_space
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status, abort_distributed_partition
  use mpl_groups, only: mpl_groups_create, mpl_cart_coords
  implicit none
  private
  public :: initialize_distributed_transform_environment
  include 'setup_trans0.h'
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
!> CONTROL owns the two region arrays and borrows the public message lifetime.
!! TEXT is bounded ASCII namelist input. THREADS is the actual positive thread
!! count. All processes call together, with identical source control settings.
!! The process-factor child uses live NPROC and NSPECRESMIN, including world32.
  integer(c_int) function initialize_distributed_transform_environment(control, text, threads) result(status)
    type(native_transform_control), intent(inout) :: control
    character(len=*), intent(in) :: text
    integer(c_int), intent(in) :: threads
    type(native_process_control) :: process
    type(native_process_partition_factors) :: factors
    integer(c_int), allocatable :: regions(:)
    integer(c_int) :: local_status, allocation_status, ns, ew, rank_count
    integer(c_int), pointer, volatile :: system_error
    status = 2
    if (.not. control%message_ready .or. control%environment_ready) return
    if (control%nproc < 1 .or. control%nproc > 32 .or. control%myproc < 1 .or. control%myproc > control%nproc) return
    if (allocated(control%n_regions) .or. allocated(control%ngpset2pe)) return
    if (control%nprintlev /= 0 .or. control%lmpoff /= 0 .or. control%lsync_trans /= 0) return
    if (control%leq_regions /= 1 .or. control%lsplit /= 1 .or. control%nopt_memory < 1) return
    local_status = read_distributed_process_controls(text, control%nproc, process)
    if (local_status == 0) local_status = require_empty_distributed_vectors(text)
    if (local_status == 0) local_status = require_empty_transform_group(text, 0_c_int)
    if (local_status == 0) local_status = require_operational_transform_group(text)
    if (local_status == 0) local_status = derive_runtime_process_partitions(process%nproc, threads, process%nspecresmin, factors)
    status = agree_distributed_partition_status(control, local_status)
    if (status /= 0) return
    control%nprgpns = factors%nprgpns
    control%nprgpew = factors%nprgpew
    control%nprtrw = factors%nprtrw
    control%nprtrv = factors%nprtrv
    control%nprtrns = factors%nprtrns
    call mpl_groups_create(control%nprtrw, control%nprtrv)
    call mpl_cart_coords(control%myproc, control%mysetw, control%mysetv)
    if (control%mysetw /= (control%myproc - 1)/control%nprtrv + 1) call abort_distributed_partition()
    if (control%mysetv /= mod(control%myproc - 1, control%nprtrv) + 1) call abort_distributed_partition()
    control%npromatr = 0
    control%nepromatr = 0
    control%nmax_resol = 37
    control%lalloperm = 1
    control%lmono_trans = 0
    control%rdistr_e = 1.0d0
    local_status = 0
    allocate (regions(control%nproc + 2), stat=allocation_status)
    if (allocation_status /= 0) local_status = 1
    status = agree_distributed_partition_status(control, local_status)
    if (status /= 0) return
    regions(:) = 0
    call c_f_pointer(errno_address(), system_error)
    system_error = 0
    call setup_trans0(kout=control%nulout, kerr=control%nulerr, kprintlev=control%nprintlev, &
                      kmax_resol=control%nmax_resol, kpromatr=control%npromatr, kprgpns=control%nprgpns, &
                      kprgpew=control%nprgpew, kprtrw=control%nprtrw, kcombflen=control%ncombflen, &
                      ldmpoff=.false., ldsync_trans=.false., ldeq_regions=.true., k_regions_ns=control%regions_ns, &
                      k_regions_ew=control%regions_ew, k_regions=regions, prad=control%ra, ldalloperm=.true.)
    control%environment_ready = .true.
    if (control%regions_ns < 1 .or. control%regions_ns > control%nproc) call abort_distributed_partition()
    if (control%regions_ew < 1 .or. control%regions_ew > control%nproc) call abort_distributed_partition()
    rank_count = 0
    do ns = 1, control%regions_ns
      if (regions(ns) < 1 .or. regions(ns) > control%regions_ew) call abort_distributed_partition()
      rank_count = rank_count + regions(ns)
    end do
    if (rank_count /= control%nproc) call abort_distributed_partition()
    local_status = 0
    allocate (control%n_regions(control%regions_ns), stat=allocation_status)
    if (allocation_status == 0) allocate (control%ngpset2pe(control%regions_ew, control%regions_ns), stat=allocation_status)
    if (allocation_status /= 0) local_status = 1
    status = agree_distributed_partition_status(control, local_status)
    if (status /= 0) return
    do ns = 1, control%regions_ns
      control%n_regions(ns) = regions(ns)
    end do
    control%ngpset2pe(:, :) = 0
    rank_count = 0
    do ns = 1, control%regions_ns
      do ew = 1, control%n_regions(ns)
        rank_count = rank_count + 1
        control%ngpset2pe(ew, ns) = rank_count
      end do
    end do
    if (rank_count /= control%nproc) call abort_distributed_partition()
    ! Preserve the serial-qualified MYREGION/MYREGION_PE members. The actual
    ! public north/south and east/west identifiers are queried later by SUMP.
    status = 0
  end function
!> Accept the first exact empty source group, including a header comment.
  integer(c_int) function require_empty_distributed_vectors(text) result(status)
    character(len=*), intent(in) :: text
    character(len=*), parameter :: name = 'NAM_DISTRIBUTED_VECTORS'
    integer :: i, j, column, n, g
    status = 2
    n = len(text)
    if (n < 1 .or. n > 262144) return
    i = 1
    column = 0
    g = len(name)
    do while (i <= n)
      if (iachar(text(i:i)) == 10) then
        column = 0
        i = i + 1
        cycle
      end if
      if (physics_space(text(i:i))) then
        column = column + 1
        i = i + 1
        cycle
      end if
      if (text(i:i) == '&' .and. column < 10) then
        j = i + 1
        if (j + g > n) return
        if (text(j:j + g - 1) == name) then
          j = j + g
          if (physics_space(text(j:j)) .or. text(j:j) == '/' .or. text(j:j) == '!') then
            call skip_physics_space(text, j)
            if (j <= n) then
              if (text(j:j) == '/') status = 0
            end if
            return
          end if
        end if
      end if
      do while (i <= n)
        if (iachar(text(i:i)) == 10) exit
        i = i + 1
      end do
      if (i <= n) i = i + 1
      column = 0
    end do
  end function
end module forecast_distributed_transform_environment
