!> Retain the complete output norm calls on the actual distributed grid.
!! A norm summarizes a field; it does not change the forecast field.
module forecast_actual_output_norm_bridge
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08, only: MPI_Comm
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_output_request_types, only: trqfp
  use runtime_fullpos_norm_transport_port, only: fullpos_norm_partition, extract_fullpos_norms
  use runtime_output_field_gather_port, only: output_distribution, agree_output_status
  use mpl_barrier_mod, only: mpl_barrier
  use yomhook, only: dr_hook, jphook
  implicit none
  private
  public :: initialize_actual_output_norm_maps, calculate_actual_grid_output_norms, calculate_actual_spectral_output_norms
#include "specnorm.h"
contains
  !> Derive the field-norm point maps from the one live canonical partition.
 !! All process numbers and local indices retain their source one-based values.
 !! Only integer metadata is copied. The caller invokes this on every rank.
  integer(int32) function initialize_actual_output_norm_maps(geometry, communicator, budget, partition) result(status)
    type(native_geometry_state), intent(in) :: geometry
    type(MPI_Comm), intent(in) :: communicator
    integer(int64), intent(in) :: budget
    type(fullpos_norm_partition), intent(inout) :: partition
    type(output_distribution) :: agreement
    type(fullpos_norm_partition) :: work
    integer :: world, points, owner, local, g, ierr
    integer(int32) :: local_status
    integer(int64) :: required
    world = geometry%transform_control%nproc; points = geometry%partition%ngptotg
    agreement%communicator = communicator
    local_status = 2
    if (world >= 1 .and. world <= 32 .and. points > 0 .and. budget > 0 .and. budget <= 68719476736_int64) then
      if (allocated(geometry%partition%nglobalproc) .and. allocated(geometry%partition%nlocalindex)) then
        if (size(geometry%partition%nglobalproc) == points .and. size(geometry%partition%nlocalindex) == points) then
          if (.not. allocated(partition%point_counts) .and. .not. allocated(partition%point_indices) .and. &
              .not. allocated(partition%field_counts) .and. .not. allocated(partition%field_offsets)) local_status = 0
        end if
      end if
    end if
    call agree_output_status(agreement, local_status, status)
    if (status /= 0) return
    allocate (work%point_counts(world), stat=ierr)
    local_status = 0
    if (ierr /= 0) local_status = 1
    call agree_output_status(agreement, local_status, status)
    if (status /= 0) return
    work%point_counts = 0
    do g = 1, points
      owner = geometry%partition%nglobalproc(g)
      if (owner < 1 .or. owner > world) then
        local_status = 2; exit
      end if
      work%point_counts(owner) = work%point_counts(owner) + 1
    end do
    required = 4_int64*world*(int(maxval(work%point_counts), int64) + 3_int64)
    if (required > budget) local_status = 2
    call agree_output_status(agreement, local_status, status)
    if (status /= 0) return
    allocate (work%point_indices(maxval(work%point_counts), world), stat=ierr)
    if (ierr /= 0) local_status = 1
    call agree_output_status(agreement, local_status, status)
    if (status /= 0) return
    work%point_indices = 0
    do g = 1, points
      owner = geometry%partition%nglobalproc(g); local = geometry%partition%nlocalindex(g)
      if (local < 1 .or. local > work%point_counts(owner)) then
        local_status = 2; exit
      end if
      if (work%point_indices(local, owner) /= 0) then
        local_status = 2; exit
      end if
      work%point_indices(local, owner) = g
    end do
    call agree_output_status(agreement, local_status, status)
    if (status /= 0) return
    partition%communicator = communicator
    partition%global_point_count = points
    partition%profiling_enabled = .false.
    call move_alloc(work%point_counts, partition%point_counts)
    call move_alloc(work%point_indices, partition%point_indices)
  end function

  !> Use the unchanged global-order EXTFPNORM child and source chunk distribution.
 !! FIELD has (pitch,global request fields,local blocks); active excludes padding.
 !! The requested fields share the one actual output domain.
  integer(int32) function calculate_actual_grid_output_norms(partition, distribution, request, field, active, &
                                                             chunk_size, configuration, hook_enabled, budget) result(status)
    type(fullpos_norm_partition), intent(inout) :: partition
    type(output_distribution), intent(in) :: distribution
    type(trqfp), intent(in) :: request
    real(real64), intent(in) :: field(:, :, :)
    integer(int32), intent(in) :: active(:), chunk_size
    character, intent(in) :: configuration
    logical, intent(in) :: hook_enabled
    integer(int64), intent(in) :: budget
    real(real64), allocatable :: values(:, :)
    integer :: fields, world, first, last, chunk, n, j, rank, ierr, quotient, remainder
    integer(int32) :: local_status
    integer(int64) :: private_bytes
    real(kind=jphook) :: handle
    status = 2
    fields = request%nfieldg; world = distribution%world; rank = distribution%process_one_based
    if (fields == 0) then
      status = 0; return
    end if
    local_status = 2
    if (fields > 0 .and. fields <= 65536 .and. size(field, 2) == fields .and. world >= 1 .and. world <= 32) then
      if (allocated(request%llsurf) .and. allocated(request%clpref) .and. allocated(request%clname) .and. &
          allocated(request%igrib) .and. allocated(request%idom) .and. allocated(request%idmp)) then
        if (size(request%llsurf) == fields .and. size(request%idom) == fields .and. size(request%idmp, 1) == 1 .and. &
            size(request%idmp, 2) == fields .and. size(active) == size(field, 3)) then
          if (all(request%idom == 1) .and. all(request%idmp == 1)) local_status = 0
        end if
      end if
    end if
    if (configuration /= 'I' .and. configuration /= 'P' .and. configuration /= 'S') local_status = 2
    if (local_status == 0) then
      if (any(.not. request%llsurf)) then
        if (.not. allocated(request%zlev)) then
          local_status = 2
        else if (size(request%zlev) < fields) then
          local_status = 2
        end if
      end if
    end if
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) return
    if (hook_enabled) call dr_hook('FPGPNORM', 0, handle)
    private_bytes = 24_int64*fields
    local_status = 0
    if (private_bytes + 4_int64*size(partition%point_indices, kind=int64) >= budget) local_status = 2
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) goto900
    allocate (values(3, fields), stat=ierr)
    local_status = 0
    if (ierr /= 0) local_status = 1
    if (allocated(partition%field_counts)) deallocate (partition%field_counts)
    if (allocated(partition%field_offsets)) deallocate (partition%field_offsets)
    if (local_status == 0) then
      allocate (partition%field_counts(world), partition%field_offsets(world), stat=ierr)
      if (ierr /= 0) local_status = 1
    end if
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) goto900
    chunk = fields
    if (chunk_size > 0) chunk = chunk_size
    do first = 1, fields, chunk
      last = min(first + chunk - 1, fields); n = last - first + 1
      quotient = n/world; remainder = modulo(n, world)
      do j = 1, world
        partition%field_counts(j) = quotient
        if (j <= remainder) partition%field_counts(j) = partition%field_counts(j) + 1
      end do
      partition%field_offsets(1) = 0
      do j = 2, world
        partition%field_offsets(j) = partition%field_offsets(j - 1) + partition%field_counts(j - 1)
      end do
      call extract_fullpos_norms(partition, int(first, int32), field, active, request%idom, request%idmp, 1_int32, &
                                 budget - private_bytes - 4_int64*size(partition%point_indices, kind=int64), &
                                 values(1, first:last), values(2, first:last), values(3, first:last), status)
      if (status /= 0) goto900
    end do
    call mpl_barrier(CDSTRING='FPGPNORMS:')
    if (rank == 1) then
      write (6, fmt='(/,'' FULL-POS GPNORMS'')')
      write (6, fmt='(26X,A7,3(9X,A7,6X))') 'PARAMID', 'AVERAGE', 'MINIMUM', 'MAXIMUM'
      do j = 1, fields
        where (abs(values(:, j)) < epsilon(1.0_real64)) values(:, j) = 0.0_real64
        call print_grid_field(request, j, configuration, values(:, j))
      end do
    end if
    status = 0
900 if (hook_enabled) call dr_hook('FPGPNORM', 1, handle)
  end function

  !> Call the exact public SPECNORM boundary used by the generated controller.
 !! Spectrum has (local fields,local complex-coefficient words). The source
 !! spectral provider owns its reduction; this caller adds no positive floor.
 integer(int32)function calculate_actual_spectral_output_norms(geometry,distribution,request,spectrum,configuration,hook_enabled)result(status)
  type(native_geometry_state), intent(in) :: geometry
  type(output_distribution), intent(in) :: distribution
  type(trqfp), intent(in) :: request
  real(real64), intent(in) :: spectrum(:, :)
  character, intent(in) :: configuration
  logical, intent(in) :: hook_enabled
  real(real64), allocatable :: values(:)
  integer :: n, j, ierr
  integer(int32) :: local_status
  real(kind=jphook) :: handle
  status = 2; n = request%nfieldg
  if (n == 0) then
    status = 0; return
  end if
  local_status = 2
  if (n > 0 .and. n <= 65536 .and. size(spectrum, 1) == request%nfieldl .and. &
      size(spectrum, 2) == geometry%partition%nspec2) then
    if (allocated(request%ivsetg) .and. allocated(request%llsurf) .and. allocated(request%zlev) .and. &
        allocated(request%clpref) .and. allocated(request%clname) .and. allocated(request%igrib)) then
      if (size(request%ivsetg) == n .and. size(request%llsurf) == n .and. size(request%zlev) == n) local_status = 0
    end if
  end if
  if (geometry%transform_control%nprtrv < 1 .or. &
      geometry%transform_control%nprtrv > geometry%transform_control%nproc) local_status = 2
  if (geometry%transform_control%mysetv < 1 .or. &
      geometry%transform_control%mysetv > geometry%transform_control%nprtrv) local_status = 2
  if (local_status == 0) then
    if (any(request%ivsetg < 1) .or. any(request%ivsetg > geometry%transform_control%nprtrv)) local_status = 2
    if (count(request%ivsetg == geometry%transform_control%mysetv) /= request%nfieldl) local_status = 2
  end if
  if (configuration /= 'P' .and. configuration /= 'S') local_status = 2
  call agree_output_status(distribution, local_status, status)
  if (status /= 0) return
  if (hook_enabled) call dr_hook('FPSPNORMS', 0, handle)
  allocate (values(n), stat=ierr)
  local_status = 0
  if (ierr /= 0) local_status = 1
  call agree_output_status(distribution, local_status, status)
  if (status /= 0) goto900
  call specnorm(KRESOL=geometry%transform_resolution%resolution, PSPEC=spectrum, &
                KVSET=request%ivsetg, KMASTER=1_int32, PNORM=values)
  if (geometry%transform_control%myproc == 1) then
    where (values < epsilon(1.0_real64)) values = 0.0_real64
    write (6, fmt='(/,''FULL-POS SPNORMS'')')
    write (6, fmt='(26X,A7,9X,A7)') 'PARAMID', 'AVERAGE'
    do j = 1, n
      call print_spectral_field(request, j, configuration, values(j))
    end do
  end if
  status = 0
900 if (hook_enabled) call dr_hook('FPSPNORMS', 1, handle)

  end function

  subroutine source_level_format(level, configuration, digits, integer_level)
    real(real64), intent(in) :: level
    character, intent(in) :: configuration
    integer, intent(out) :: digits, integer_level
    integer_level = nint(level)
    if (integer_level <= 0) then
      digits = 0
    else
      select case (configuration)
      case ('P')
        digits = 5
      case default
        digits = 3
      end select
    end if
  end subroutine
  subroutine field_label(request, j, configuration, name, digits)
    type(trqfp), intent(in) :: request
    integer, intent(in) :: j
    character, intent(in) :: configuration
    character(16), intent(out) :: name
    integer, intent(out) :: digits
    integer :: integer_level, prefix
    character(8) :: level_text
    digits = 0; integer_level = 0
    prefix = len_trim(request%clpref(j))
    if (.not. request%llsurf(j)) call source_level_format(request%zlev(j), configuration, digits, integer_level)
    if (digits /= 0) then
      write (level_text, fmt='(I8.8)') integer_level
      name = request%clpref(j) (1:prefix)//level_text(9 - digits:8)
    else
      name = request%clpref(j) (1:prefix)//request%clname(j) (1:min(16 - prefix, len_trim(request%clname(j))))
    end if
  end subroutine
  subroutine print_grid_field(request, j, configuration, values)
    type(trqfp), intent(in) :: request
    integer, intent(in) :: j
    character, intent(in) :: configuration
    real(real64), intent(in) :: values(3)
    character(16) :: name
    integer :: digits
    call field_label(request, j, configuration, name, digits)
    write (6, fmt='(1X,A8,1X,A16,1X,I6.0,'' : '',3(E21.15,1X))') &
      adjustl(name), request%clname(j), request%igrib(j), values
  end subroutine
  subroutine print_spectral_field(request, j, configuration, value)
    type(trqfp), intent(in) :: request
    integer, intent(in) :: j
    character, intent(in) :: configuration
    real(real64), intent(in) :: value
    character(16) :: name
    integer :: digits
    call field_label(request, j, configuration, name, digits)
    if (digits /= 0) then
      write (6, fmt='(1X,A8,1X,A16,1X,I6.0,'' : '',E21.15)') &
        adjustl(name), request%clname(j), request%igrib(j), value
    else
      write (6, fmt='(1X,A16,1X,I6.0,'' : '',E21.15)') request%clname(j), request%igrib(j), value
    end if
  end subroutine
end module
