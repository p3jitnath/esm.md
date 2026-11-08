!> Compute CORMASSDRY through actual public transform and scalar norm services.
module forecast_runtime_dry_mass_reference
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use mpi_f08
  use yomhook, only: lhook
  use forecast_geometry_state_types, only: native_geometry_state
  use md2asm_spectral_transposes, only: spectral_transpose_layout
  use forecast_pressure_norms, only: grid_point_norm
  implicit none
  private
  public :: native_dry_mass_reference, calculate_runtime_dry_mass_reference
  !> The caller owns these source TDYN values. No clock/scalar namespace is copied.
  type :: native_dry_mass_reference
    real(real64) :: gmassi, gmass0, gmassinc
  end type
  interface
    function public_exp(x) bind(C, name='exp') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_log(x) bind(C, name='log') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
#include "inv_trans.h"
contains
  !> Spectral pressure is the produced log-pressure field; MAP_FACTOR is genuine GM.
 !! Geometry and the canonical phase7 layout remain borrowed and unchanged.
 !! Spectral pressure has C words on the last vertical set and one untouched
 !! dummy word elsewhere. Public inverse output has Q local physical cells.
 !! The caller supplies source LMASDRY/LDGPMASCOR and the inactive norm-control
 !! word through named arguments; their producer association is not fabricated.
 !! BUDGET counts bytes and must admit8*(Q+P*B), at most64GiB.
 !! State publishes only after release and the final public-world agreement.
  integer(int32) function calculate_runtime_dry_mass_reference(geometry, layout, spectral_pressure, map_factor, step, &
                                                        ldgpmascor, lmasdry, norm_diagnostics_enabled, budget, state) result(status)
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_transpose_layout), intent(in) :: layout
    real(real64), intent(in), target, contiguous :: spectral_pressure(:)
    real(real64), intent(in), contiguous :: map_factor(:)
    integer(int32), intent(in) :: step
    logical, intent(in) :: ldgpmascor, lmasdry, norm_diagnostics_enabled
    integer(int64), intent(in) :: budget
    type(native_dry_mass_reference), intent(inout) :: state
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer, contiguous :: spectral(:, :), grid(:, :, :), blocked(:, :, :), flat_pressure(:)
    real(real64) :: norms(3, 1), mean_value, initial_value, ratio, increment, x
    integer(int32) :: local_status, global_status, child
    integer :: world, rank, ierr, p, q, b, c, local_fields, first, last, j, allocation_status, field_group(1)
    integer(int64) :: required_words, required_bytes, block
    logical :: initialized, initialise_reference
    status = 2
    call MPI_Initialized(initialized, ierr)
    if (ierr /= MPI_SUCCESS .or. .not. initialized) return
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
    if (ierr /= MPI_SUCCESS) then
      status = 3; return
    end if
    call MPI_Comm_size(MPI_COMM_WORLD, world, ierr)
    if (ierr /= MPI_SUCCESS) then
      status = 3; return
    end if
    local_status = 2
    admission: block
      if (.not. geometry%initialized .or. .not. geometry%transform_control%message_ready .or. &
          .not. geometry%transform_control%environment_ready) exit admission
      if(layout%phase/=7.or.geometry%partition%phase/=7.or..not.layout%geometry_matches.or..not.layout%hooks_disabled)exit admission
      if (layout%world /= world .or. layout%rank_zero_based /= rank .or. world < 1 .or. world > 65536) exit admission
      if (geometry%transform_control%nproc /= world .or. geometry%transform_control%myproc /= rank + 1) exit admission
      if (layout%horizontal_peers < 1 .or. layout%vertical_peers < 1) exit admission
      if (int(layout%horizontal_peers, int64)*layout%vertical_peers /= world) exit admission
      if (layout%horizontal_index < 1 .or. layout%horizontal_index > layout%horizontal_peers) exit admission
      if (layout%vertical_index < 1 .or. layout%vertical_index > layout%vertical_peers) exit admission
      if ((layout%horizontal_index - 1)*layout%vertical_peers + layout%vertical_index /= rank + 1) exit admission
      if (geometry%dimensions%nsmax < 1 .or. geometry%dimensions%nsmax > 8191) exit admission
      if (geometry%dimensions%nflevg < 1 .or. geometry%dimensions%nflevg > 512) exit admission
      if (layout%maximum_degree /= geometry%dimensions%nsmax .or. layout%global_levels /= geometry%dimensions%nflevg) exit admission
      if (transfer(lhook, 0_int32) /= 0 .or. transfer(ldgpmascor, 0_int32) /= 0 .or. transfer(lmasdry, 0_int32) /= 0 .or. &
          transfer(norm_diagnostics_enabled, 0_int32) /= 0 .or. step < 0) exit admission
      p = geometry%dimensions%nproma; q = geometry%partition%ngptot; b = geometry%partition%ngpblks
      c = geometry%partition%nspec2
      if (p < 1 .or. p > 4096 .or. q < 1 .or. b < 1 .or. c < 0 .or. btest(c, 0)) exit admission
      if ((q - 1)/p + 1 /= b) exit admission
      if (layout%spectral_coefficients /= c .or. layout%local_levels /= geometry%partition%nflevl) exit admission
      local_fields = 0
      if (layout%vertical_index == layout%vertical_peers) local_fields = 1
      if (geometry%partition%nflsur /= local_fields) exit admission
      if (local_fields == 0) then
        if (size(spectral_pressure) /= 1) exit admission
      else
        if (size(spectral_pressure) /= c) exit admission
      end if
      if (size(map_factor) /= q) exit admission
      required_words = int(q, int64) + int(p, int64)*b
      required_bytes = 8_int64*required_words
      if (budget < 1 .or. budget > 2_int64**36 .or. required_bytes > budget) exit admission
      local_status = 0
    end block admission
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER4, MPI_MAX, MPI_COMM_WORLD, ierr)
    if (ierr /= MPI_SUCCESS) then
      status = 3; return
    end if
    status = global_status
    if (status /= 0) return
    allocate (workspace(required_words), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER4, MPI_MAX, MPI_COMM_WORLD, ierr)
    if (ierr /= MPI_SUCCESS) then
      status = 3
    else
      status = global_status
    end if
    if (status /= 0) then
      if (allocated(workspace)) deallocate (workspace)
      return
    end if
    grid(1:q, 1:1, 1:1) => workspace(1:q)
    blocked(1:p, 1:1, 1:b) => workspace(q + 1:required_words)
    flat_pressure(1:int(p, int64)*b) => workspace(q + 1:required_words)
    if (local_fields == 1) then
      spectral(1:1, 1:c) => spectral_pressure
    else
      spectral(1:0, 1:c) => spectral_pressure(1:0)
    end if
    field_group(1) = layout%vertical_peers
    call inv_trans(pspscalar=spectral, kresol=geometry%transform_resolution%resolution, kproma=q, &
                   kvsetsc=field_group, pgp=grid)
    do block = 1, int(b, int64)
      first = int((block - 1)*p + 1); last = int(min(block*p, int(q, int64)))
      do j = first, last
        flat_pressure(j) = public_exp(grid(j, 1, 1))
      end do
      do j = first, last
        x = map_factor(j)*map_factor(j)
        flat_pressure(j) = flat_pressure(j)/x
      end do
    end do
    call grid_point_norm(blocked, int(q, int32), geometry%transform_resolution%resolution, int(world, int32), norms, child)
    local_status = 0
    if (child /= 0) local_status = 2
    if (local_status == 0) then
      mean_value = norms(1, 1)
      initial_value = state%gmassi
      initialise_reference = step == 0 .and. initial_value == 0.0_real64
      if (initialise_reference) initial_value = mean_value
      ratio = mean_value/initial_value
      increment = public_log(ratio)
    end if
    deallocate (workspace)
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER4, MPI_MAX, MPI_COMM_WORLD, ierr)
    if (ierr /= MPI_SUCCESS) then
      status = 3; return
    end if
    status = global_status
    if (status /= 0) return
    state%gmass0 = mean_value
    if (initialise_reference) state%gmassi = initial_value
    state%gmassinc = increment
  end function
end module forecast_runtime_dry_mass_reference
