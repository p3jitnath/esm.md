!> Join computed radiation rows to the actual public transform and Gaussian grid.
!! Every live WORLD rank enters together. No serial surrogate supplies a stage.
module forecast_runtime_radiation_transform_prefix
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_intptr_t, c_loc, c_associated, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08, only: MPI_Allreduce, MPI_Comm_size, MPI_Comm_rank, MPI_Initialized, MPI_Finalized, &
                     MPI_INTEGER, MPI_MIN, MPI_MAX, MPI_COMM_WORLD, MPI_SUCCESS
  use forecast_runtime_radiation_prefix_types, only: native_runtime_radiation_prefix_context
  use forecast_runtime_radiation_shape, only: create_runtime_radiation_grid_from_prefix, release_runtime_radiation_grid_shape
  use forecast_live_radiation_setup, only: create_live_radiation_gaussian_setup
  implicit none
  private
  public :: create_runtime_radiation_transform_from_prefix
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine fatal_public_error() bind(c, name="abort")
    end subroutine
  end interface
contains
  !> Produce NRGRI/NLOENG, agree the complete eight-word shape, then construct
 !! the real public transform and its nine owners before Gaussian filling.
 !! CONTEXT borrows stable disjoint canonical targets. All mutable owners are
 !! fresh. World1:32 and live NS/EW are compiled source scope; new large-grid
 !! or world32 numerical agreement is still pending independent acceptance.
 !! Status2 is refusal,1 is allocation failure,0 owns rows and Gaussian state.
 !! Early interpolation/scalar publications remain on later failure, as in
 !! the original caller. Failed row/transform owners are released completely.
  integer(int32) function create_runtime_radiation_transform_from_prefix(context) result(status)
    type(native_runtime_radiation_prefix_context), target, intent(in) :: context
    integer(int32) :: local, ignored, shape(8), minimum(8), maximum(8)
    integer :: world, rank
    logical :: ready
    call world_identity(world, rank, ready)
    status = 2_int32
    if (.not. ready) return
    local = 2_int32
    if (admitted_context(context, world, rank)) local = 0_int32
    status = agree(local); if (status /= 0) return
    local = create_runtime_radiation_grid_from_prefix(context)
    status = agree(local)
    if (status /= 0) then
      ignored = release_runtime_radiation_grid_shape(context%shape)
      if (agree(ignored) /= 0) call fatal_public_error()
      return
    end if
    shape = [context%grid%ndglg, context%grid%nsmax, context%shape%global_first, context%shape%global_last, &
             context%shape%polar_rows, context%setup%radiation%nradint, context%control%regions_ns, context%control%regions_ew]
    call reduce_shape(shape, minimum, maximum)
    if (any(minimum /= maximum)) then
      ignored = release_runtime_radiation_grid_shape(context%shape)
      if (agree(ignored) /= 0) call fatal_public_error()
      status = 2_int32
      return
    end if
    local = create_live_radiation_gaussian_setup(context%storage, context%grid, context%shape%nloeng, &
                                             context%control, context%partition, context%constants, context%setup%radiation%nradint)
    status = agree(local)
    if (status /= 0) then
      ignored = release_runtime_radiation_grid_shape(context%shape)
      if (agree(ignored) /= 0) call fatal_public_error()
    end if
  end function

  logical function admitted_context(c, world, rank) result(valid)
    type(native_runtime_radiation_prefix_context), target, intent(in) :: c
    integer, intent(in) :: world, rank
    integer(c_intptr_t) :: base(12)
    integer(int64) :: bytes(12), occupied
    integer :: i, j, ns, ew
    valid = .false.
    if (.not. associated(c%setup) .or. .not. associated(c%upstream) .or. .not. associated(c%constants)) return
    if (.not. associated(c%dimensions) .or. .not. associated(c%grid) .or. .not. associated(c%shape)) return
    if (.not. associated(c%storage) .or. .not. associated(c%ri) .or. .not. associated(c%ro)) return
    if (.not. associated(c%control) .or. .not. associated(c%partition)) return
    base = [transfer(c_loc(c%setup), 0_c_intptr_t), transfer(c_loc(c%upstream), 0_c_intptr_t), &
            transfer(c_loc(c%constants), 0_c_intptr_t), transfer(c_loc(c%dimensions), 0_c_intptr_t), &
            transfer(c_loc(c%grid), 0_c_intptr_t), transfer(c_loc(c%shape), 0_c_intptr_t), &
            transfer(c_loc(c%storage), 0_c_intptr_t), transfer(c_loc(c%ri), 0_c_intptr_t), &
            transfer(c_loc(c%ro), 0_c_intptr_t), transfer(c_loc(c%control), 0_c_intptr_t), &
            transfer(c_loc(c%partition), 0_c_intptr_t), transfer(c_loc(c), 0_c_intptr_t)]
    bytes = [storage_size(c%setup, kind=int64)/8_int64, storage_size(c%upstream, kind=int64)/8_int64, &
             storage_size(c%constants, kind=int64)/8_int64, storage_size(c%dimensions, kind=int64)/8_int64, &
             storage_size(c%grid, kind=int64)/8_int64, storage_size(c%shape, kind=int64)/8_int64, &
             storage_size(c%storage, kind=int64)/8_int64, storage_size(c%ri, kind=int64)/8_int64, &
             storage_size(c%ro, kind=int64)/8_int64, storage_size(c%control, kind=int64)/8_int64, &
             storage_size(c%partition, kind=int64)/8_int64, storage_size(c, kind=int64)/8_int64]
    do i = 1, 12
      if (base(i) <= 0 .or. bytes(i) < 1) return
      if (base(i) > huge(base(i)) - bytes(i)) return
      do j = 1, i - 1
        if (base(i) <= base(j)) then
          if (base(j) - base(i) < bytes(i)) return
        else
          if (base(i) - base(j) < bytes(j)) return
        end if
      end do
    end do
    if (world < 1 .or. world > 32 .or. c%control%nproc /= world .or. c%control%myproc /= rank + 1) return
    if (.not. c%control%message_ready .or. .not. c%control%environment_ready) return
    if (c%control%lsplit /= 1 .or. c%control%lfftw /= 0) return
    if (c%partition%phase /= 7 .or. c%partition%borrowed_resolution <= 0) return
    ns = c%control%regions_ns; ew = c%control%regions_ew
    if (ns < 1 .or. ns > 64 .or. ew < 1 .or. ew > 64) return
    if (.not. allocated(c%control%n_regions) .or. .not. allocated(c%control%ngpset2pe)) return
    if (size(c%control%n_regions) < ns) return
    if (size(c%control%ngpset2pe, 1) < ew .or. size(c%control%ngpset2pe, 2) < ns) return
    occupied = 0_int64
    do i = 1, ns
      if (c%control%n_regions(i) < 1 .or. c%control%n_regions(i) > ew) return
      occupied = occupied + int(c%control%n_regions(i), int64)
    end do
    if (occupied /= int(world, int64)) return
    if (c%partition%my_region_ns < 1 .or. c%partition%my_region_ns > ns) return
    if (c%partition%my_region_ew < 1 .or. c%partition%my_region_ew > c%control%n_regions(c%partition%my_region_ns)) return
    if (c%control%ngpset2pe(c%partition%my_region_ew, c%partition%my_region_ns) /= c%control%myproc) return
    if (allocated(c%shape%nrgri) .or. allocated(c%shape%nloeng) .or. associated(c%shape%grid)) return
    do i = 1, 2
      if (c_associated(c%shape%allocation_address(i))) return
      if (c_associated(c%storage%halo_address(i))) return
    end do
    if (c%storage%state /= 0 .or. associated(c%storage%grid) .or. associated(c%storage%row_lengths)) return
 if (c%storage%resolution%resolution /= 0 .or. c%storage%resolution%truncation /= 0 .or. c%storage%resolution%row_count /= 0) return
    if (c%storage%points%my_region_ns /= 0 .or. c%storage%points%my_region_ew /= 0) return
    if (c%storage%points%n_regions_ns /= 0 .or. c%storage%points%n_regions_ew /= 0 .or. c%storage%points%nstencilwide /= 0) return
    if (associated(c%storage%points%first_latitude) .or. associated(c%storage%points%last_latitude)) return
  if(associated(c%storage%points%longitude_count).or.associated(c%storage%points%start).or.associated(c%storage%points%count))return
    if (allocated(c%storage%nsta) .or. allocated(c%storage%nonl) .or. allocated(c%storage%nptrfrstlat)) return
    if (allocated(c%storage%nfrstlat) .or. allocated(c%storage%nlstlat) .or. allocated(c%storage%zmu)) return
    do i = 1, 14
      if (c_associated(c%storage%allocation_address(i))) return
    end do
    if (allocated(c%grid%rmu) .or. allocated(c%grid%rsqm2) .or. allocated(c%grid%rlatig)) return
    valid = .true.
  end function

  !> Added integer agreements preserve the incoming floating status and errno.
  integer(int32) function agree(local) result(global)
    integer(int32), intent(in) :: local
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer :: error
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    call MPI_Allreduce(local, global, 1, MPI_INTEGER, MPI_MAX, MPI_COMM_WORLD, error)
    if (error /= MPI_SUCCESS) call fatal_public_error()
    call ieee_set_status(floating); system_error = saved_error
  end function

  subroutine reduce_shape(shape, minimum, maximum)
    integer(int32), intent(in) :: shape(8)
    integer(int32), intent(out) :: minimum(8), maximum(8)
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer :: error
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    call MPI_Allreduce(shape, minimum, 8, MPI_INTEGER, MPI_MIN, MPI_COMM_WORLD, error)
    if (error /= MPI_SUCCESS) call fatal_public_error()
    call MPI_Allreduce(shape, maximum, 8, MPI_INTEGER, MPI_MAX, MPI_COMM_WORLD, error)
    if (error /= MPI_SUCCESS) call fatal_public_error()
    call ieee_set_status(floating); system_error = saved_error
  end subroutine

  subroutine world_identity(world, rank, ready)
    integer, intent(out) :: world, rank
    logical, intent(out) :: ready
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer :: error
    logical :: initialized, finished
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    world = 0; rank = -1; ready = .false.
    call MPI_Initialized(initialized, error)
    if (error /= MPI_SUCCESS) call fatal_public_error()
    if (initialized) then
      call MPI_Finalized(finished, error)
      if (error /= MPI_SUCCESS) call fatal_public_error()
      if (.not. finished) then
        call MPI_Comm_size(MPI_COMM_WORLD, world, error)
        if (error /= MPI_SUCCESS) call fatal_public_error()
        call MPI_Comm_rank(MPI_COMM_WORLD, rank, error)
        if (error /= MPI_SUCCESS) call fatal_public_error()
        ready = .true.
      end if
    end if
    call ieee_set_status(floating); system_error = saved_error
  end subroutine
end module forecast_runtime_radiation_transform_prefix
