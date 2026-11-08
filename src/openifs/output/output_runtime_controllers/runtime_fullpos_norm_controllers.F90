!> Preserve the source Fullpos norm calls, adjustment and result lifetime.
!! The caller starts public MPI and establishes nearest-even FP64 arithmetic
!! with gradual underflow. No model routine or private record is imported.
module forecast_runtime_fullpos_norm_controllers
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use runtime_fullpos_norm_transport_port, only: fullpos_norm_partition, extract_fullpos_norms
  implicit none
  private
  public :: native_fullpos_norm_context, native_fullpos_norm_results
  public :: compute_runtime_fullpos_spectral_norms, compute_runtime_fullpos_grid_norms
  public :: release_runtime_fullpos_norm_results
  !> Borrow the live owners for this collective service.
  !! budget_bytes includes retained results and all concurrent work, in bytes.
  !! The caller retains these TARGET owners until the result is released.
  type :: native_fullpos_norm_context
    type(MPI_Comm) :: communicator = MPI_COMM_WORLD
    type(native_transform_control), pointer :: control => null()
    type(native_transform_resolution), pointer :: resolution => null()
    type(native_distributed_partition), pointer :: partition => null()
    type(native_forecast_control_namespace), pointer :: configuration => null()
    integer(int64) :: budget_bytes = 0
    logical :: profiling_enabled = .false.
  end type
  !> Own the complete source result planes on rank one.
  !! spectral(:,1:2) holds raw and adjusted norms. grid(:,1:6) holds raw
  !! mean/minimum/maximum followed by the three adjusted values.
  !! Other ranks retain counts, with no payload. Array bounds start at one.
  type :: native_fullpos_norm_results
    real(real64), allocatable :: spectral(:, :), grid(:, :)
    integer(int32) :: spectral_field_count = 0, grid_domain_count = 0, grid_field_count = 0
    integer(int32) :: rank_one = 0, world = 0
    integer(int64) :: generation = 0
    logical :: ready = .false.
    type(native_distributed_partition), pointer :: partition => null()
  end type
#include "specnorm.h"
contains
  subroutine require_mpi(context, error)
    type(native_fullpos_norm_context), intent(in) :: context
    integer, intent(in) :: error
    integer :: ignored
    if (error == MPI_SUCCESS) return
    call MPI_Abort(context%communicator, 3, ignored)
    error stop 3
  end subroutine

  subroutine agree_status(context, local_status, status)
    type(native_fullpos_norm_context), intent(in) :: context
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: status
    integer :: error
    call MPI_Allreduce(local_status, status, 1, MPI_INTEGER4, MPI_MAX, context%communicator, error)
    call require_mpi(context, error)
  end subroutine

  !> Check named live ownership after the two source MPI queries.
  subroutine bind_context(context, rank, world, status)
    type(native_fullpos_norm_context), intent(in) :: context
    integer, intent(out) :: rank, world
    integer(int32), intent(out) :: status
    integer :: error, degree
    call MPI_Comm_rank(context%communicator, rank, error)
    call require_mpi(context, error)
    call MPI_Comm_size(context%communicator, world, error)
    call require_mpi(context, error)
    status = 2
    if (world < 1 .or. world > 65536 .or. context%profiling_enabled) return
    if (.not. associated(context%control) .or. .not. associated(context%resolution) .or. &
        .not. associated(context%partition) .or. .not. associated(context%configuration)) return
    if (.not. context%control%message_ready .or. context%partition%phase /= 7) return
    degree = context%resolution%truncation
    if (degree < 1 .or. degree > 8191) return
    if (context%control%nproc /= world .or. context%control%myproc /= rank + 1) return
    if (context%control%nprtrw < 1 .or. context%control%nprtrv < 1) return
    if (int(context%control%nprtrw, int64)*context%control%nprtrv /= world) return
    if (context%control%mysetw < 1 .or. context%control%mysetw > context%control%nprtrw) return
    if (context%control%mysetv < 1 .or. context%control%mysetv > context%control%nprtrv) return
    if (context%configuration%lelam /= 0) return
    if (context%budget_bytes < 1 .or. context%budget_bytes > 68719476736_int64) return
    status = 0
  end subroutine

  subroutine admit_owner(context, owner, rank, world, retained, status)
    type(native_fullpos_norm_context), intent(in) :: context
    type(native_fullpos_norm_results), intent(in) :: owner
    integer, intent(in) :: rank, world
    integer(int64), intent(out) :: retained
    integer(int32), intent(out) :: status
    retained = 0
    status = 2
    if (.not. owner%ready) then
      if (associated(owner%partition) .or. allocated(owner%spectral) .or. allocated(owner%grid)) return
      if (owner%spectral_field_count /= 0 .or. owner%grid_domain_count /= 0 .or. owner%grid_field_count /= 0) return
      if (owner%rank_one /= 0 .or. owner%world /= 0 .or. owner%generation /= 0) return
      status = 0
      return
    end if
    if (.not. associated(owner%partition, context%partition)) return
    if (owner%rank_one /= rank + 1 .or. owner%world /= world) return
    if (owner%spectral_field_count < 0 .or. owner%spectral_field_count > 65536) return
    if (owner%grid_field_count < 0 .or. owner%grid_field_count > 65536) return
    if (owner%grid_field_count == 0) then
      if (owner%grid_domain_count /= 0) return
    else
      if (owner%grid_domain_count /= 1) return
    end if
    if (rank == 0 .and. owner%spectral_field_count > 0) then
      if (.not. allocated(owner%spectral)) return
      if (any(shape(owner%spectral) /= [owner%spectral_field_count, 2])) return
      retained = 16_int64*owner%spectral_field_count
    else
      if (allocated(owner%spectral)) return
    end if
    if (rank == 0 .and. owner%grid_field_count > 0) then
      if (.not. allocated(owner%grid)) return
      if (any(shape(owner%grid) /= [owner%grid_field_count, 6])) return
      retained = retained + 48_int64*owner%grid_field_count
    else
      if (allocated(owner%grid)) return
    end if
    status = 0
  end subroutine

  subroutine stamp_owner(context, owner, rank, world)
    type(native_fullpos_norm_context), intent(in) :: context
    type(native_fullpos_norm_results), intent(inout) :: owner
    integer, intent(in) :: rank, world
    owner%ready = .true.
    owner%partition => context%partition
    owner%rank_one = rank + 1
    owner%world = world
    if (owner%generation == huge(owner%generation)) then
      owner%generation = -huge(owner%generation) - 1_int64
    else
      owner%generation = owner%generation + 1_int64
    end if
  end subroutine

  !> Retain the source display conversion even though no text is emitted.
  !! The volatile local preserves its natural floating-point flags.
  subroutine consume_display_level(level, configuration)
    real(real64), intent(in) :: level
    character(*), intent(in) :: configuration
    real(real64) :: value
    integer(int32), volatile :: display_level
    value = level
    if (configuration == 'V') value = value*10000000.0_real64
    display_level = nint(value, int32)
  end subroutine

  !> Compute all spectral fields through the official public SPECNORM service.
  !! spectral has (fields on this vertical set,local spectral words).
  !! sets, surface, levels, prefixes and names have the global field count.
  !! prefixes and names have lengths8 and12. They are validated but unread.
  !! Status0 publishes,1 is common allocation failure and2 is admission failure.
  !! A failure keeps both old result owners. MPI errors end the communicator.
  integer(int32) function compute_runtime_fullpos_spectral_norms(context, owner, resolutions, &
                                               spectral, sets, surface, prefixes, levels, names, grib, configuration) result(status)
    type(native_fullpos_norm_context), intent(in) :: context
    type(native_fullpos_norm_results), intent(inout) :: owner
    integer(int32), intent(in) :: resolutions(:), sets(:)
    real(real64), intent(in) :: spectral(:, :), levels(:)
    logical, intent(in) :: surface(:)
    character(*), intent(in) :: prefixes(:), names(:)
    integer(int32), optional, intent(in) :: grib(:)
    character(*), optional, intent(in) :: configuration
    real(real64), allocatable :: staged(:, :), retired(:, :)
    real(real64), parameter :: threshold = transfer(int(z'3cb0000000000000', int64), 0.0_real64)
    integer :: rank, world, fields, local_fields, words, j, allocation_status
    integer(int32) :: local_status
    integer(int64) :: retained
    call bind_context(context, rank, world, local_status)
    fields = size(levels)
    if (local_status == 0) call admit_owner(context, owner, rank, world, retained, local_status)
    if (local_status == 0) then
      local_status = 2
      if (fields >= 1 .and. fields <= 65536) then
        if (size(sets) == fields .and. size(surface) == fields .and. size(prefixes) == fields .and. &
            size(names) == fields .and. len(prefixes) == 8 .and. len(names) == 12) then
          if (size(resolutions) == 1) then
            if (resolutions(1) > 0) then
              if (all(sets >= 1) .and. all(sets <= context%control%nprtrv)) then
                local_fields = count(sets == context%control%mysetv)
                words = context%partition%nspec2
                if (words >= 0 .and. int(words, int64) <= &
                    int(context%resolution%truncation + 1, int64)*(context%resolution%truncation + 2)) then
                  if (all(shape(spectral) == [local_fields, words])) then
                    if (is_contiguous(spectral) .and. is_contiguous(resolutions) .and. is_contiguous(sets) .and. &
                        is_contiguous(surface) .and. is_contiguous(levels) .and. is_contiguous(prefixes) .and. &
                        is_contiguous(names)) local_status = 0
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
      if (present(grib)) then
        if (size(grib) /= fields .or. .not. is_contiguous(grib)) local_status = 2
      end if
      if (present(configuration)) then
        if (len(configuration) /= 1) then
          local_status = 2
        else if (index('PVTS', configuration) == 0) then
          local_status = 2
        end if
      else
        if (.not. all(surface)) local_status = 2
      end if
      if (retained + 16_int64*fields + 1632_int64 > context%budget_bytes) local_status = 2
    end if
    call agree_status(context, local_status, status)
    if (status /= 0) return
    allocate (staged(fields, 2), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_status(context, local_status, status)
    if (status /= 0) then
      if (allocated(staged)) deallocate (staged)
      return
    end if
    call specnorm(pspec=spectral, kvset=sets, kmaster=1_int32, kresol=resolutions(1), pnorm=staged(:, 1))
    if (rank == 0) then
      do j = 1, fields
        if (staged(j, 1) < threshold) then
          staged(j, 2) = 0.0_real64
        else
          staged(j, 2) = staged(j, 1)
        end if
      end do
      do j = 1, fields
        if (.not. surface(j)) call consume_display_level(levels(j), configuration)
      end do
    end if
    call agree_status(context, 0_int32, status)
    if (status /= 0) then
      deallocate (staged)
      return
    end if
    if (rank == 0) then
      call move_alloc(owner%spectral, retired)
      call move_alloc(staged, owner%spectral)
    else
      deallocate (staged)
    end if
    owner%spectral_field_count = fields
    call stamp_owner(context, owner, rank, world)
    if (allocated(retired)) deallocate (retired)
  end function

  !> Gather complete raw grid norms, then retain the source adjustments.
  !! blocked has (width,global fields,local blocks), including final padding.
  !! transport owns live point maps. Its existing field_counts/field_offsets
  !! are temporarily used for source chunk distributions and restored on exit.
  !! No point map or physical field is copied into an alternate owner.
  !! All ranks call together. levels and configuration may be absent only
  !! when every field is a surface field. domain_name has length32.
  integer(int32) function compute_runtime_fullpos_grid_norms(context, owner, transport, chunk_size, &
                                blocked, block_ends, surface, prefixes, levels, domain_counts, domain_indices, names, domain_name, &
                                                             global_points, grib, configuration) result(status)
    type(native_fullpos_norm_context), intent(in) :: context
    type(native_fullpos_norm_results), intent(inout) :: owner
    type(fullpos_norm_partition), intent(inout) :: transport
    integer(int32), intent(in) :: chunk_size, block_ends(:), domain_counts(:), domain_indices(:, :), global_points
    real(real64), intent(in) :: blocked(:, :, :)
    logical, intent(in) :: surface(:)
    character(*), intent(in) :: prefixes(:), names(:), domain_name
    real(real64), optional, intent(in) :: levels(:)
    integer(int32), optional, intent(in) :: grib(:)
    character(*), optional, intent(in) :: configuration
    real(real64), allocatable :: staged(:, :), retired(:, :)
    integer(int32), allocatable :: distribution_backup(:, :)
    real(real64), parameter :: threshold = transfer(int(z'3cb0000000000000', int64), 0.0_real64)
    integer :: rank, world, fields, width, blocks, local_points, j, k, first, last, chunk, chunk_fields
    integer :: allocation_status, error, prefix
    integer(int32) :: local_status
    integer(int64) :: retained, reserved, remaining
    call bind_context(context, rank, world, local_status)
    fields = size(surface)
    if (local_status == 0) call admit_owner(context, owner, rank, world, retained, local_status)
    if (local_status == 0) then
      local_status = 2
      if (fields >= 1 .and. fields <= 65536 .and. len(domain_name) == 32 .and. len(prefixes) == 8 .and. len(names) == 12) then
        if (size(prefixes) == fields .and. size(names) == fields .and. size(domain_counts) == fields) then
          if (all(shape(domain_indices) == [1, fields])) then
            if (all(domain_counts == 1) .and. all(domain_indices == 1)) then
              if (is_contiguous(blocked) .and. is_contiguous(block_ends) .and. is_contiguous(surface) .and. &
                  is_contiguous(prefixes) .and. is_contiguous(names) .and. is_contiguous(domain_counts) .and. &
                  is_contiguous(domain_indices)) then
                if (allocated(transport%field_counts) .and. allocated(transport%field_offsets) .and. &
                    allocated(transport%point_counts) .and. allocated(transport%point_indices)) then
                  if (size(transport%field_counts) == world .and. size(transport%field_offsets) == world .and. &
                      size(transport%point_counts) == world) then
                    if (transport%communicator == context%communicator .and. .not. transport%profiling_enabled) then
                      if (global_points >= 1 .and. global_points == transport%global_point_count) then
                        width = size(blocked, 1)
                        local_points = transport%point_counts(rank + 1)
                        if (width >= 1 .and. width <= 1024 .and. local_points >= 0) then
                          blocks = int((int(local_points, int64) + width - 1)/width)
                          if (all(shape(blocked) == [width, fields, blocks]) .and. size(block_ends) == blocks) then
                            local_status = 0
                            do j = 1, blocks
                              if (block_ends(j) /= min(width, local_points - (j - 1)*width)) local_status = 2
                            end do
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
      if (present(levels)) then
        if (size(levels) /= fields .or. .not. is_contiguous(levels)) local_status = 2
      else
        if (.not. all(surface)) local_status = 2
      end if
      if (present(grib)) then
        if (size(grib) /= fields .or. .not. is_contiguous(grib)) local_status = 2
      end if
      if (present(configuration)) then
        if (len(configuration) /= 1) then
          local_status = 2
        else if (index('PVTS', configuration) == 0) then
          local_status = 2
        end if
      else
        if (.not. all(surface)) local_status = 2
      end if
      reserved = retained + 48_int64*fields + 8_int64*world + 1632_int64
      if (reserved >= context%budget_bytes) local_status = 2
    end if
    call agree_status(context, local_status, status)
    if (status /= 0) return
    remaining = context%budget_bytes - reserved
    chunk = fields
    if (chunk_size > 0) chunk = min(chunk_size, fields)
    allocate (staged(fields, 6), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_status(context, local_status, status)
    if (status /= 0) then
      if (allocated(staged)) deallocate (staged)
      return
    end if
    allocate (distribution_backup(world, 2), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_status(context, local_status, status)
    if (status /= 0) then
      if (allocated(distribution_backup)) deallocate (distribution_backup)
      deallocate (staged)
      return
    end if
    distribution_backup(:, 1) = transport%field_counts
    distribution_backup(:, 2) = transport%field_offsets
    do first = 1, fields, chunk
      last = min(first + chunk - 1, fields)
      chunk_fields = last - first + 1
      prefix = 0
      do j = 1, world
        transport%field_counts(j) = chunk_fields/world
        if (j <= modulo(chunk_fields, world)) transport%field_counts(j) = transport%field_counts(j) + 1
        transport%field_offsets(j) = prefix
        prefix = prefix + transport%field_counts(j)
      end do
      call extract_fullpos_norms(transport, int(first, int32), blocked, block_ends, domain_counts, &
                    domain_indices, 1_int32, remaining, staged(first:last, 1), staged(first:last, 2), staged(first:last, 3), status)
      if (status /= 0) exit
    end do
    if (status == 0) then
      call MPI_Barrier(context%communicator, error)
      call require_mpi(context, error)
      if (rank == 0) then
        do j = 1, fields
          if (.not. surface(j)) call consume_display_level(levels(j), configuration)
          do k = 1, 3
            if (abs(staged(j, k)) < threshold) then
              staged(j, k + 3) = 0.0_real64
            else
              staged(j, k + 3) = staged(j, k)
            end if
          end do
        end do
      end if
    end if
    transport%field_counts = distribution_backup(:, 1)
    transport%field_offsets = distribution_backup(:, 2)
    deallocate (distribution_backup)
    if (status /= 0) then
      deallocate (staged)
      return
    end if
    call agree_status(context, 0_int32, status)
    if (status /= 0) then
      deallocate (staged)
      return
    end if
    if (rank == 0) then
      call move_alloc(owner%grid, retired)
      call move_alloc(staged, owner%grid)
    else
      deallocate (staged)
    end if
    owner%grid_domain_count = 1
    owner%grid_field_count = fields
    call stamp_owner(context, owner, rank, world)
    if (allocated(retired)) deallocate (retired)
  end function

  !> Release both result owners after common admission, then clear metadata.
  !! A fresh or repeatedly released owner is valid. Borrowed model state
  !! and public message lifetime are not changed.
  integer(int32) function release_runtime_fullpos_norm_results(context, owner) result(status)
    type(native_fullpos_norm_context), intent(in) :: context
    type(native_fullpos_norm_results), intent(inout) :: owner
    integer :: rank, world
    integer(int32) :: local_status
    integer(int64) :: retained
    call bind_context(context, rank, world, local_status)
    if (local_status == 0) call admit_owner(context, owner, rank, world, retained, local_status)
    call agree_status(context, local_status, status)
    if (status /= 0) return
    if (allocated(owner%spectral)) deallocate (owner%spectral)
    if (allocated(owner%grid)) deallocate (owner%grid)
    owner%spectral_field_count = 0
    owner%grid_domain_count = 0
    owner%grid_field_count = 0
    owner%rank_one = 0
    owner%world = 0
    owner%generation = 0
    owner%ready = .false.
    nullify (owner%partition)
  end function
end module
