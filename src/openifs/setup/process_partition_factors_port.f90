!> Derive source process factors from live counts.
module forecast_process_partition_factors
  use iso_c_binding, only: c_int, c_double
  implicit none
  private
  public :: native_process_partition_factors, derive_runtime_process_partitions
!> Eight named dimensionless int32 results from SUMPINI.
  type, bind(C) :: native_process_partition_factors
    integer(c_int) :: nproc, nprgpns, nprgpew, nprtrw, nprtrv, nprtrns, nprtrn, nspecresmin
  end type
contains
!> Preserve OUTPUT on refusal. WORLD0:65536,THREADS1:65536,MINIMUM0:1000000.
!! OUTPUT is caller-owned and INOUT. The caller supplies nearest-even
!! rounding and gradual underflow. Zero defaults follow the source.
  integer(c_int) function derive_runtime_process_partitions(world, threads, spectral_minimum, output) result(status)
    integer(c_int), intent(in) :: world, threads, spectral_minimum
    type(native_process_partition_factors), intent(inout) :: output
    integer(c_int) :: n, minimum, root_integer, trial, other, grid_ns, grid_ew, waves, levels, threshold
    real(c_double), volatile :: root_input, root_value
    status = 2_c_int
    if (world < 0 .or. world > 65536 .or. threads < 1 .or. threads > 65536) return
    if (spectral_minimum < 0 .or. spectral_minimum > 1000000) return
    n = world
    if (n == 0) n = 1
    minimum = spectral_minimum
    if (minimum == 0) minimum = n
    root_input = real(n, c_double)
    root_value = sqrt(root_input)
    root_integer = int(root_value, c_int)
    do trial = root_integer, n
      other = n/trial
      if (trial*other /= n) cycle
      grid_ns = max(trial, other)
      grid_ew = min(trial, other)
      exit
    end do
    waves = 0
    levels = 0
    threshold = minimum/(2*threads)
    do trial = 4, n
      levels = trial
      waves = n/levels
      if (levels*waves /= n) cycle
      if (levels > waves) exit
      if (waves > minimum) cycle
      if (waves <= threshold) exit
    end do
    if (levels*waves /= n .or. waves > minimum .or. levels > waves) then
      root_input = real(n, c_double)
      root_value = sqrt(root_input)
      root_integer = int(root_value, c_int)
      do trial = root_integer, n
        other = n/trial
        if (trial*other /= n) cycle
        waves = max(trial, other)
        levels = min(trial, other)
        if (waves > minimum) return
        exit
      end do
    end if
    output%nproc = n
    output%nprgpns = grid_ns
    output%nprgpew = grid_ew
    output%nprtrw = waves
    output%nprtrv = levels
    output%nprtrns = waves
    output%nprtrn = levels
    output%nspecresmin = minimum
    status = 0_c_int
  end function
end module forecast_process_partition_factors
