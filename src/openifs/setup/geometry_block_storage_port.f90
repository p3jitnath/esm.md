!> Own blocked spherical fields and native views of existing point arrays.
module forecast_geometry_block_storage
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_spherical_point_geometry, only: native_spherical_point_geometry
  use forecast_computational_geometry, only: native_computational_geometry
  implicit none
  private
  public :: native_spherical_block_view, native_computational_block_view
  public :: native_geometry_block_storage, allocate_geometry_block_storage
  public :: bind_geometry_blocks, release_geometry_block_storage
  !> Each pointer is a non-owning one-based section of a live point owner.
  !! The last view has only the physical points in its block.
  type :: native_spherical_block_view
    real(c_double), pointer :: rcori(:) => null()
    real(c_double), pointer :: rcoric(:) => null()
    real(c_double), pointer :: gemu(:) => null()
    real(c_double), pointer :: gsqm2(:) => null()
    real(c_double), pointer :: gelam(:) => null()
    real(c_double), pointer :: gelat(:) => null()
    real(c_double), pointer :: geclo(:) => null()
    real(c_double), pointer :: geslo(:) => null()
    real(c_double), pointer :: gexco(:) => null()
    real(c_double), pointer :: geyco(:) => null()
    real(c_double), pointer :: gezco(:) => null()
    real(c_double), pointer :: gm(:) => null()
    real(c_double), pointer :: gmappa(:) => null()
    real(c_double), pointer :: gomvrl(:) => null()
    real(c_double), pointer :: gomvrm(:) => null()
    real(c_double), pointer :: gnordl(:) => null()
    real(c_double), pointer :: gnordm(:) => null()
    real(c_double), pointer :: gnordlcl(:) => null()
    real(c_double), pointer :: gnordmcl(:) => null()
    real(c_double), pointer :: gnordmcm(:) => null()
    real(c_double), pointer :: gaw(:) => null()
    integer(c_int), pointer :: ngplat(:) => null()
    integer(c_int), pointer :: nuniquegp(:) => null()
  end type
  !> Six non-owning computational sections use the same physical point bounds.
  type :: native_computational_block_view
    real(c_double), pointer :: rcolon(:) => null()
    real(c_double), pointer :: rsilon(:) => null()
    real(c_double), pointer :: rindx(:) => null()
    real(c_double), pointer :: rindy(:) => null()
    real(c_double), pointer :: ratath(:) => null()
    real(c_double), pointer :: ratatx(:) => null()
  end type
  !> Each array owns shape block_width by block_count, with one-based bounds.
  !! Spherical units match native_spherical_point_geometry. Inactive final-block
  !! rows retain their allocation preimage. Views do not own point arrays.
  type :: native_geometry_block_storage
    integer(c_int) :: block_width = 0, block_count = 0, physical_points = 0
    real(c_double), allocatable :: rcori(:, :)
    real(c_double), allocatable :: rcoric(:, :)
    real(c_double), allocatable :: gemu(:, :)
    real(c_double), allocatable :: gsqm2(:, :)
    real(c_double), allocatable :: gelam(:, :)
    real(c_double), allocatable :: gelat(:, :)
    real(c_double), allocatable :: geclo(:, :)
    real(c_double), allocatable :: geslo(:, :)
    real(c_double), allocatable :: gexco(:, :)
    real(c_double), allocatable :: geyco(:, :)
    real(c_double), allocatable :: gezco(:, :)
    real(c_double), allocatable :: gm(:, :)
    real(c_double), allocatable :: gmappa(:, :)
    real(c_double), allocatable :: gomvrl(:, :)
    real(c_double), allocatable :: gomvrm(:, :)
    real(c_double), allocatable :: gnordl(:, :)
    real(c_double), allocatable :: gnordm(:, :)
    real(c_double), allocatable :: gnordlcl(:, :)
    real(c_double), allocatable :: gnordmcl(:, :)
    real(c_double), allocatable :: gnordmcm(:, :)
    real(c_double), allocatable :: gaw(:, :)
    integer(c_int), allocatable :: ngplat(:, :)
    integer(c_int), allocatable :: nuniquegp(:, :)
    type(native_spherical_block_view), allocatable :: spherical_views(:)
    type(native_computational_block_view), allocatable :: computational_views(:)
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate twenty-three numerical owners and then the two view owners.
  !! The width and point count are live input dimensions; no grid is substituted.
  !! Return2 refuses existing owners or invalid counts before mutation.
  !! Return1 frees every allocation acquired by this call in source order.
  integer(c_int) function allocate_geometry_block_storage(state, block_width, point_count) result(status)
    type(native_geometry_block_storage), intent(inout) :: state
    integer(c_int), intent(in) :: block_width, point_count
    integer(c_int64_t) :: blocks
    integer :: allocation_status
    status = 2
    if (block_width < 1 .or. block_width > 1048576 .or. point_count < 1) return
    blocks = (int(point_count, c_int64_t) + block_width - 1)/block_width
    if (blocks > huge(0_c_int)) return
    if (allocated(state%rcori)) return
    if (allocated(state%rcoric)) return
    if (allocated(state%gemu)) return
    if (allocated(state%gsqm2)) return
    if (allocated(state%gelam)) return
    if (allocated(state%gelat)) return
    if (allocated(state%geclo)) return
    if (allocated(state%geslo)) return
    if (allocated(state%gexco)) return
    if (allocated(state%geyco)) return
    if (allocated(state%gezco)) return
    if (allocated(state%gm)) return
    if (allocated(state%gmappa)) return
    if (allocated(state%gomvrl)) return
    if (allocated(state%gomvrm)) return
    if (allocated(state%gnordl)) return
    if (allocated(state%gnordm)) return
    if (allocated(state%gnordlcl)) return
    if (allocated(state%gnordmcl)) return
    if (allocated(state%gnordmcm)) return
    if (allocated(state%gaw)) return
    if (allocated(state%ngplat)) return
    if (allocated(state%nuniquegp)) return
    if (allocated(state%spherical_views) .or. allocated(state%computational_views)) return
    allocate (state%rcori(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%rcoric(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gemu(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gsqm2(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gelam(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gelat(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%geclo(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%geslo(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gm(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gmappa(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gomvrl(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gomvrm(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gnordl(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gnordm(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gnordlcl(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gnordmcl(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gnordmcm(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gaw(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%ngplat(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%nuniquegp(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gexco(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%geyco(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%gezco(block_width, int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%spherical_views(int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%computational_views(int(blocks)), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    state%block_width = block_width
    state%block_count = int(blocks, c_int)
    state%physical_points = point_count
    status = 0
    return
900 continue
    call release_geometry_block_storage(state)
    status = 1
  end function

  !> Bind views to live input owners and copy only physical spherical points.
  !! Point owners must remain allocated at stable addresses while views exist.
  !! Only view associations and physical blocked cells are changed.
  !! Return2 preserves state if any expected owner or input extent is absent.
  integer(c_int) function bind_geometry_blocks(state, spherical, computational) result(status)
    type(native_geometry_block_storage), intent(inout) :: state
    type(native_spherical_point_geometry), target, intent(in) :: spherical
    type(native_computational_geometry), target, intent(in) :: computational
    integer :: block, first, last, active, local
    status = 2
    if (state%physical_points < 1 .or. state%block_width < 1 .or. state%block_count < 1) return
    if (.not. allocated(state%rcori) .or. .not. allocated(spherical%rcori)) return
    if (size(state%rcori, 1) /= state%block_width .or. size(state%rcori, 2) /= state%block_count) return
    if (size(spherical%rcori) /= state%physical_points) return
    if (.not. allocated(state%rcoric) .or. .not. allocated(spherical%rcoric)) return
    if (size(state%rcoric, 1) /= state%block_width .or. size(state%rcoric, 2) /= state%block_count) return
    if (size(spherical%rcoric) /= state%physical_points) return
    if (.not. allocated(state%gemu) .or. .not. allocated(spherical%gemu)) return
    if (size(state%gemu, 1) /= state%block_width .or. size(state%gemu, 2) /= state%block_count) return
    if (size(spherical%gemu) /= state%physical_points) return
    if (.not. allocated(state%gsqm2) .or. .not. allocated(spherical%gsqm2)) return
    if (size(state%gsqm2, 1) /= state%block_width .or. size(state%gsqm2, 2) /= state%block_count) return
    if (size(spherical%gsqm2) /= state%physical_points) return
    if (.not. allocated(state%gelam) .or. .not. allocated(spherical%gelam)) return
    if (size(state%gelam, 1) /= state%block_width .or. size(state%gelam, 2) /= state%block_count) return
    if (size(spherical%gelam) /= state%physical_points) return
    if (.not. allocated(state%gelat) .or. .not. allocated(spherical%gelat)) return
    if (size(state%gelat, 1) /= state%block_width .or. size(state%gelat, 2) /= state%block_count) return
    if (size(spherical%gelat) /= state%physical_points) return
    if (.not. allocated(state%geclo) .or. .not. allocated(spherical%geclo)) return
    if (size(state%geclo, 1) /= state%block_width .or. size(state%geclo, 2) /= state%block_count) return
    if (size(spherical%geclo) /= state%physical_points) return
    if (.not. allocated(state%geslo) .or. .not. allocated(spherical%geslo)) return
    if (size(state%geslo, 1) /= state%block_width .or. size(state%geslo, 2) /= state%block_count) return
    if (size(spherical%geslo) /= state%physical_points) return
    if (.not. allocated(state%gexco) .or. .not. allocated(spherical%gexco)) return
    if (size(state%gexco, 1) /= state%block_width .or. size(state%gexco, 2) /= state%block_count) return
    if (size(spherical%gexco) /= state%physical_points) return
    if (.not. allocated(state%geyco) .or. .not. allocated(spherical%geyco)) return
    if (size(state%geyco, 1) /= state%block_width .or. size(state%geyco, 2) /= state%block_count) return
    if (size(spherical%geyco) /= state%physical_points) return
    if (.not. allocated(state%gezco) .or. .not. allocated(spherical%gezco)) return
    if (size(state%gezco, 1) /= state%block_width .or. size(state%gezco, 2) /= state%block_count) return
    if (size(spherical%gezco) /= state%physical_points) return
    if (.not. allocated(state%gm) .or. .not. allocated(spherical%gm)) return
    if (size(state%gm, 1) /= state%block_width .or. size(state%gm, 2) /= state%block_count) return
    if (size(spherical%gm) /= state%physical_points) return
    if (.not. allocated(state%gmappa) .or. .not. allocated(spherical%gmappa)) return
    if (size(state%gmappa, 1) /= state%block_width .or. size(state%gmappa, 2) /= state%block_count) return
    if (size(spherical%gmappa) /= state%physical_points) return
    if (.not. allocated(state%gomvrl) .or. .not. allocated(spherical%gomvrl)) return
    if (size(state%gomvrl, 1) /= state%block_width .or. size(state%gomvrl, 2) /= state%block_count) return
    if (size(spherical%gomvrl) /= state%physical_points) return
    if (.not. allocated(state%gomvrm) .or. .not. allocated(spherical%gomvrm)) return
    if (size(state%gomvrm, 1) /= state%block_width .or. size(state%gomvrm, 2) /= state%block_count) return
    if (size(spherical%gomvrm) /= state%physical_points) return
    if (.not. allocated(state%gnordl) .or. .not. allocated(spherical%gnordl)) return
    if (size(state%gnordl, 1) /= state%block_width .or. size(state%gnordl, 2) /= state%block_count) return
    if (size(spherical%gnordl) /= state%physical_points) return
    if (.not. allocated(state%gnordm) .or. .not. allocated(spherical%gnordm)) return
    if (size(state%gnordm, 1) /= state%block_width .or. size(state%gnordm, 2) /= state%block_count) return
    if (size(spherical%gnordm) /= state%physical_points) return
    if (.not. allocated(state%gnordlcl) .or. .not. allocated(spherical%gnordlcl)) return
    if (size(state%gnordlcl, 1) /= state%block_width .or. size(state%gnordlcl, 2) /= state%block_count) return
    if (size(spherical%gnordlcl) /= state%physical_points) return
    if (.not. allocated(state%gnordmcl) .or. .not. allocated(spherical%gnordmcl)) return
    if (size(state%gnordmcl, 1) /= state%block_width .or. size(state%gnordmcl, 2) /= state%block_count) return
    if (size(spherical%gnordmcl) /= state%physical_points) return
    if (.not. allocated(state%gnordmcm) .or. .not. allocated(spherical%gnordmcm)) return
    if (size(state%gnordmcm, 1) /= state%block_width .or. size(state%gnordmcm, 2) /= state%block_count) return
    if (size(spherical%gnordmcm) /= state%physical_points) return
    if (.not. allocated(state%gaw) .or. .not. allocated(spherical%gaw)) return
    if (size(state%gaw, 1) /= state%block_width .or. size(state%gaw, 2) /= state%block_count) return
    if (size(spherical%gaw) /= state%physical_points) return
    if (.not. allocated(state%ngplat) .or. .not. allocated(spherical%ngplat)) return
    if (size(state%ngplat, 1) /= state%block_width .or. size(state%ngplat, 2) /= state%block_count) return
    if (size(spherical%ngplat) /= state%physical_points) return
    if (.not. allocated(state%nuniquegp) .or. .not. allocated(spherical%nuniquegp)) return
    if (size(state%nuniquegp, 1) /= state%block_width .or. size(state%nuniquegp, 2) /= state%block_count) return
    if (size(spherical%nuniquegp) /= state%physical_points) return
    if (.not. allocated(computational%rcolon)) return
    if (size(computational%rcolon) /= state%physical_points) return
    if (.not. allocated(computational%rsilon)) return
    if (size(computational%rsilon) /= state%physical_points) return
    if (.not. allocated(computational%rindx)) return
    if (size(computational%rindx) /= state%physical_points) return
    if (.not. allocated(computational%rindy)) return
    if (size(computational%rindy) /= state%physical_points) return
    if (.not. allocated(computational%ratath)) return
    if (size(computational%ratath) /= state%physical_points) return
    if (.not. allocated(computational%ratatx)) return
    if (size(computational%ratatx) /= state%physical_points) return
    if (.not. allocated(state%spherical_views) .or. .not. allocated(state%computational_views)) return
    if (size(state%spherical_views) /= state%block_count) return
    if (size(state%computational_views) /= state%block_count) return
    if (int(state%block_count, c_int64_t) /= (int(state%physical_points, c_int64_t) + &
                                              state%block_width - 1)/state%block_width) return
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      last = first + min(state%block_width, state%physical_points - first + 1) - 1
      state%spherical_views(block)%rcori(1:) => spherical%rcori(first:last)
      state%spherical_views(block)%rcoric(1:) => spherical%rcoric(first:last)
      state%spherical_views(block)%gemu(1:) => spherical%gemu(first:last)
      state%spherical_views(block)%gsqm2(1:) => spherical%gsqm2(first:last)
      state%spherical_views(block)%gelam(1:) => spherical%gelam(first:last)
      state%spherical_views(block)%gelat(1:) => spherical%gelat(first:last)
      state%spherical_views(block)%geclo(1:) => spherical%geclo(first:last)
      state%spherical_views(block)%geslo(1:) => spherical%geslo(first:last)
      state%spherical_views(block)%gexco(1:) => spherical%gexco(first:last)
      state%spherical_views(block)%geyco(1:) => spherical%geyco(first:last)
      state%spherical_views(block)%gezco(1:) => spherical%gezco(first:last)
      state%spherical_views(block)%gm(1:) => spherical%gm(first:last)
      state%spherical_views(block)%gmappa(1:) => spherical%gmappa(first:last)
      state%spherical_views(block)%gomvrl(1:) => spherical%gomvrl(first:last)
      state%spherical_views(block)%gomvrm(1:) => spherical%gomvrm(first:last)
      state%spherical_views(block)%gnordl(1:) => spherical%gnordl(first:last)
      state%spherical_views(block)%gnordm(1:) => spherical%gnordm(first:last)
      state%spherical_views(block)%gnordlcl(1:) => spherical%gnordlcl(first:last)
      state%spherical_views(block)%gnordmcl(1:) => spherical%gnordmcl(first:last)
      state%spherical_views(block)%gnordmcm(1:) => spherical%gnordmcm(first:last)
      state%spherical_views(block)%gaw(1:) => spherical%gaw(first:last)
      state%spherical_views(block)%ngplat(1:) => spherical%ngplat(first:last)
      state%spherical_views(block)%nuniquegp(1:) => spherical%nuniquegp(first:last)
      state%computational_views(block)%rcolon(1:) => computational%rcolon(first:last)
      state%computational_views(block)%rsilon(1:) => computational%rsilon(first:last)
      state%computational_views(block)%rindx(1:) => computational%rindx(first:last)
      state%computational_views(block)%rindy(1:) => computational%rindy(first:last)
      state%computational_views(block)%ratath(1:) => computational%ratath(first:last)
      state%computational_views(block)%ratatx(1:) => computational%ratatx(first:last)
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%rcori(local, block) = spherical%rcori(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%rcoric(local, block) = spherical%rcoric(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gemu(local, block) = spherical%gemu(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gsqm2(local, block) = spherical%gsqm2(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gelam(local, block) = spherical%gelam(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gelat(local, block) = spherical%gelat(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%geclo(local, block) = spherical%geclo(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%geslo(local, block) = spherical%geslo(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gexco(local, block) = spherical%gexco(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%geyco(local, block) = spherical%geyco(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gezco(local, block) = spherical%gezco(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gm(local, block) = spherical%gm(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gmappa(local, block) = spherical%gmappa(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gomvrl(local, block) = spherical%gomvrl(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gomvrm(local, block) = spherical%gomvrm(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gnordl(local, block) = spherical%gnordl(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gnordm(local, block) = spherical%gnordm(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gnordlcl(local, block) = spherical%gnordlcl(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gnordmcl(local, block) = spherical%gnordmcl(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gnordmcm(local, block) = spherical%gnordmcm(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%gaw(local, block) = spherical%gaw(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%ngplat(local, block) = spherical%ngplat(first + local - 1)
      end do
    end do
    do block = 1, state%block_count
      first = (block - 1)*state%block_width + 1
      active = min(state%block_width, state%physical_points - first + 1)
      do local = 1, active
        state%nuniquegp(local, block) = spherical%nuniquegp(first + local - 1)
      end do
    end do
    status = 0
  end function

  !> Free each backing allocation once; views never free point-owner payloads.
  !! Release keeps the incoming floating-point status and errno unchanged.
  subroutine release_geometry_block_storage(state)
    type(native_geometry_block_storage), intent(inout) :: state
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_pointer)
    saved_errno = error_pointer
    if (allocated(state%rcori)) deallocate (state%rcori)
    if (allocated(state%rcoric)) deallocate (state%rcoric)
    if (allocated(state%gemu)) deallocate (state%gemu)
    if (allocated(state%gsqm2)) deallocate (state%gsqm2)
    if (allocated(state%gelam)) deallocate (state%gelam)
    if (allocated(state%gelat)) deallocate (state%gelat)
    if (allocated(state%geclo)) deallocate (state%geclo)
    if (allocated(state%geslo)) deallocate (state%geslo)
    if (allocated(state%gm)) deallocate (state%gm)
    if (allocated(state%gmappa)) deallocate (state%gmappa)
    if (allocated(state%gomvrl)) deallocate (state%gomvrl)
    if (allocated(state%gomvrm)) deallocate (state%gomvrm)
    if (allocated(state%gnordl)) deallocate (state%gnordl)
    if (allocated(state%gnordm)) deallocate (state%gnordm)
    if (allocated(state%gnordlcl)) deallocate (state%gnordlcl)
    if (allocated(state%gnordmcl)) deallocate (state%gnordmcl)
    if (allocated(state%gnordmcm)) deallocate (state%gnordmcm)
    if (allocated(state%gaw)) deallocate (state%gaw)
    if (allocated(state%ngplat)) deallocate (state%ngplat)
    if (allocated(state%nuniquegp)) deallocate (state%nuniquegp)
    if (allocated(state%gexco)) deallocate (state%gexco)
    if (allocated(state%geyco)) deallocate (state%geyco)
    if (allocated(state%gezco)) deallocate (state%gezco)
    if (allocated(state%spherical_views)) deallocate (state%spherical_views)
    if (allocated(state%computational_views)) deallocate (state%computational_views)
    state%block_width = 0
    state%block_count = 0
    state%physical_points = 0
    call ieee_set_status(saved_status)
    error_pointer = saved_errno
  end subroutine
end module forecast_geometry_block_storage
