module surface_field_storage_port
  !! Own all34 numerical surface arrays in the source allocation order.
  !! Allocation changes no physical value except the four source zero fills.
  !! Parameter records remain separate from these numerical field owners.
  use, intrinsic :: iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use partitioned_surface_field_placement_port, only: surface_input_owners
  implicit none
  private
  public :: surface_field_state, surface_field_layout, allocate_surface_field_owners
  public :: allocate_runtime_distributed_surface_field_owners, release_surface_field_owners
  public :: borrow_surface_input_owners
  type :: surface_field_layout
    !! Each named pair is field count then layer count; rank3 ignores layers.
    integer(int32) :: sp_sb(2) = [6, 4]
    integer(int32) :: sp_sg(2) = [10, 5]
    integer(int32) :: sp_sl(2) = [14, 1]
    integer(int32) :: sp_rr(2) = [4, 1]
    integer(int32) :: sp_cl(2) = [0, 1]
    integer(int32) :: sp_om(2) = [0, 0]
    integer(int32) :: sp_ep(2) = [0, 0]
    integer(int32) :: sp_x2(2) = [0, 1]
    integer(int32) :: sp_ci(2) = [0, 1]
    integer(int32) :: sd_vf(2) = [38, 1]
    integer(int32) :: sd_vp(2) = [0, 1]
    integer(int32) :: sd_vv(2) = [0, 1]
    integer(int32) :: sd_vn(2) = [5, 1]
    integer(int32) :: sd_vh(2) = [0, 1]
    integer(int32) :: sd_vk(2) = [0, 1]
    integer(int32) :: sd_va(2) = [0, 1]
    integer(int32) :: sd_vc(2) = [0, 1]
    integer(int32) :: sd_v2(2) = [0, 1]
    integer(int32) :: sd_v3(2) = [0, 0]
    integer(int32) :: sd_vd(2) = [272, 1]
    integer(int32) :: sd_sm(2) = [0, 0]
    integer(int32) :: sd_ws(2) = [3, 1]
    integer(int32) :: sd_ww(2) = [6, 1]
    integer(int32) :: sd_vx(2) = [0, 1]
    integer(int32) :: sd_xa(2) = [0, 0]
    integer(int32) :: sd_xr(2) = [0, 0]
    integer(int32) :: sd_x2(2) = [0, 1]
    integer(int32) :: sd_sfl(2) = [0, 1]
    integer(int32) :: sd_sfo(2) = [0, 1]
    integer(int32) :: sd_pf(2) = [1, 137]
    integer(int32) :: sd_di(2) = [0, 0]
    integer(int32) :: sd_oc(2) = [0, 1]
    integer(int32) :: sd_xp(2) = [0, 0]
    integer(int32) :: sd_xp2(2) = [0, 0]
  end type
  type :: surface_field_state
    !! Native arrays use(P,field,B) or(P,layer,field,B), all FP64.
    !! Only this state owns their allocation; borrowed views must expire
    !! before release. Physical units belong to each source field contract.
    real(real64), allocatable :: sp_sb(:, :, :, :)
    real(real64), allocatable :: sp_sg(:, :, :, :)
    real(real64), allocatable :: sp_sl(:, :, :)
    real(real64), allocatable :: sp_rr(:, :, :)
    real(real64), allocatable :: sp_cl(:, :, :)
    real(real64), allocatable :: sp_om(:, :, :, :)
    real(real64), allocatable :: sp_ep(:, :, :, :)
    real(real64), allocatable :: sp_x2(:, :, :)
    real(real64), allocatable :: sp_ci(:, :, :)
    real(real64), allocatable :: sd_vf(:, :, :)
    real(real64), allocatable :: sd_vp(:, :, :)
    real(real64), allocatable :: sd_vv(:, :, :)
    real(real64), allocatable :: sd_vn(:, :, :)
    real(real64), allocatable :: sd_vh(:, :, :)
    real(real64), allocatable :: sd_vk(:, :, :)
    real(real64), allocatable :: sd_va(:, :, :)
    real(real64), allocatable :: sd_vc(:, :, :)
    real(real64), allocatable :: sd_v2(:, :, :)
    real(real64), allocatable :: sd_v3(:, :, :, :)
    real(real64), allocatable :: sd_vd(:, :, :)
    real(real64), allocatable :: sd_sm(:, :, :, :)
    real(real64), allocatable :: sd_ws(:, :, :)
    real(real64), allocatable :: sd_ww(:, :, :)
    real(real64), allocatable :: sd_vx(:, :, :)
    real(real64), allocatable :: sd_xa(:, :, :, :)
    real(real64), allocatable :: sd_xr(:, :, :, :)
    real(real64), allocatable :: sd_x2(:, :, :)
    real(real64), allocatable :: sd_sfl(:, :, :)
    real(real64), allocatable :: sd_sfo(:, :, :)
    real(real64), allocatable :: sd_pf(:, :, :, :)
    real(real64), allocatable :: sd_di(:, :, :, :)
    real(real64), allocatable :: sd_oc(:, :, :)
    real(real64), allocatable :: sd_xp(:, :, :, :)
    real(real64), allocatable :: sd_xp2(:, :, :, :)
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function allocate_surface_field_owners(rows, blocks, layout, state) result(status)
    !! General source entry: rows1..64,blocks1..128,fields0..512,layers0..64.
    !! Each complete array is at most64MiB. All arrays must be unallocated.
    !! Refusal2 occurs before mutation; allocation failure1 releases every
    !! new owner; success0 publishes all34 arrays. Preserve IEEE state/errno.
    integer(int32), intent(in) :: rows, blocks
    type(surface_field_layout), intent(in) :: layout
    type(surface_field_state), intent(inout) :: state
    status = 2
    if (rows < 1 .or. rows > 64 .or. blocks < 1 .or. blocks > 128) return
    status = allocate_fields(rows, blocks, layout, .false., state)
  end function
  integer(int32) function allocate_runtime_distributed_surface_field_owners(rows, blocks, global_levels, state) result(status)
    !! Selected operational allocation derives local extents from live
    !! rows1..1024 and positive blocks. The frozen field layout has137 global
    !! layers; other global schemas require their own qualification.
    integer(int32), intent(in) :: rows, blocks, global_levels
    type(surface_field_state), intent(inout) :: state
    type(surface_field_layout) :: layout
    status = 2
    if (rows < 1 .or. rows > 1024 .or. blocks < 1 .or. global_levels /= 137) return
    status = allocate_fields(rows, blocks, layout, .true., state)
  end function
  integer(int32) function allocate_fields(rows, blocks, layout, operational, state) result(status)
    integer(int32), intent(in) :: rows, blocks
    type(surface_field_layout), intent(in) :: layout
    logical, intent(in) :: operational
    type(surface_field_state), intent(inout) :: state
    integer(int64) :: elements
    integer :: error
    integer(int32) :: ignored
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: incoming
    status = 2
    if (allocated(state%sp_sb)) return
    if (layout%sp_sb(1) < 0 .or. layout%sp_sb(1) > 512) return
    if (layout%sp_sb(2) < 0) return
    if (.not. operational .and. layout%sp_sb(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sp_sb(1)*layout%sp_sb(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_sg)) return
    if (layout%sp_sg(1) < 0 .or. layout%sp_sg(1) > 512) return
    if (layout%sp_sg(2) < 0) return
    if (.not. operational .and. layout%sp_sg(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sp_sg(1)*layout%sp_sg(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_sl)) return
    if (layout%sp_sl(1) < 0 .or. layout%sp_sl(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sp_sl(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_rr)) return
    if (layout%sp_rr(1) < 0 .or. layout%sp_rr(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sp_rr(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_cl)) return
    if (layout%sp_cl(1) < 0 .or. layout%sp_cl(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sp_cl(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_om)) return
    if (layout%sp_om(1) < 0 .or. layout%sp_om(1) > 512) return
    if (layout%sp_om(2) < 0) return
    if (.not. operational .and. layout%sp_om(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sp_om(1)*layout%sp_om(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_ep)) return
    if (layout%sp_ep(1) < 0 .or. layout%sp_ep(1) > 512) return
    if (layout%sp_ep(2) < 0) return
    if (.not. operational .and. layout%sp_ep(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sp_ep(1)*layout%sp_ep(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_x2)) return
    if (layout%sp_x2(1) < 0 .or. layout%sp_x2(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sp_x2(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sp_ci)) return
    if (layout%sp_ci(1) < 0 .or. layout%sp_ci(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sp_ci(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vf)) return
    if (layout%sd_vf(1) < 0 .or. layout%sd_vf(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vf(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vp)) return
    if (layout%sd_vp(1) < 0 .or. layout%sd_vp(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vp(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vv)) return
    if (layout%sd_vv(1) < 0 .or. layout%sd_vv(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vv(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vn)) return
    if (layout%sd_vn(1) < 0 .or. layout%sd_vn(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vn(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vh)) return
    if (layout%sd_vh(1) < 0 .or. layout%sd_vh(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vh(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vk)) return
    if (layout%sd_vk(1) < 0 .or. layout%sd_vk(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vk(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_va)) return
    if (layout%sd_va(1) < 0 .or. layout%sd_va(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_va(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vc)) return
    if (layout%sd_vc(1) < 0 .or. layout%sd_vc(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vc(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_v2)) return
    if (layout%sd_v2(1) < 0 .or. layout%sd_v2(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_v2(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_v3)) return
    if (layout%sd_v3(1) < 0 .or. layout%sd_v3(1) > 512) return
    if (layout%sd_v3(2) < 0) return
    if (.not. operational .and. layout%sd_v3(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_v3(1)*layout%sd_v3(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vd)) return
    if (layout%sd_vd(1) < 0 .or. layout%sd_vd(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vd(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_sm)) return
    if (layout%sd_sm(1) < 0 .or. layout%sd_sm(1) > 512) return
    if (layout%sd_sm(2) < 0) return
    if (.not. operational .and. layout%sd_sm(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_sm(1)*layout%sd_sm(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_ws)) return
    if (layout%sd_ws(1) < 0 .or. layout%sd_ws(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_ws(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_ww)) return
    if (layout%sd_ww(1) < 0 .or. layout%sd_ww(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_ww(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_vx)) return
    if (layout%sd_vx(1) < 0 .or. layout%sd_vx(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_vx(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_xa)) return
    if (layout%sd_xa(1) < 0 .or. layout%sd_xa(1) > 512) return
    if (layout%sd_xa(2) < 0) return
    if (.not. operational .and. layout%sd_xa(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_xa(1)*layout%sd_xa(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_xr)) return
    if (layout%sd_xr(1) < 0 .or. layout%sd_xr(1) > 512) return
    if (layout%sd_xr(2) < 0) return
    if (.not. operational .and. layout%sd_xr(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_xr(1)*layout%sd_xr(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_x2)) return
    if (layout%sd_x2(1) < 0 .or. layout%sd_x2(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_x2(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_sfl)) return
    if (layout%sd_sfl(1) < 0 .or. layout%sd_sfl(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_sfl(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_sfo)) return
    if (layout%sd_sfo(1) < 0 .or. layout%sd_sfo(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_sfo(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_pf)) return
    if (layout%sd_pf(1) < 0 .or. layout%sd_pf(1) > 512) return
    if (layout%sd_pf(2) < 0) return
    if (.not. operational .and. layout%sd_pf(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_pf(1)*layout%sd_pf(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_di)) return
    if (layout%sd_di(1) < 0 .or. layout%sd_di(1) > 512) return
    if (layout%sd_di(2) < 0) return
    if (.not. operational .and. layout%sd_di(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_di(1)*layout%sd_di(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_oc)) return
    if (layout%sd_oc(1) < 0 .or. layout%sd_oc(1) > 512) return
    elements = int(rows, int64)*blocks*layout%sd_oc(1)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_xp)) return
    if (layout%sd_xp(1) < 0 .or. layout%sd_xp(1) > 512) return
    if (layout%sd_xp(2) < 0) return
    if (.not. operational .and. layout%sd_xp(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_xp(1)*layout%sd_xp(2)
    if (.not. operational .and. elements > 8388608_int64) return
    if (allocated(state%sd_xp2)) return
    if (layout%sd_xp2(1) < 0 .or. layout%sd_xp2(1) > 512) return
    if (layout%sd_xp2(2) < 0) return
    if (.not. operational .and. layout%sd_xp2(2) > 64) return
    elements = int(rows, int64)*blocks*layout%sd_xp2(1)*layout%sd_xp2(2)
    if (.not. operational .and. elements > 8388608_int64) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    allocate (state%sp_sb(rows, layout%sp_sb(2), layout%sp_sb(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_sg(rows, layout%sp_sg(2), layout%sp_sg(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_sl(rows, layout%sp_sl(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_rr(rows, layout%sp_rr(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_cl(rows, layout%sp_cl(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_om(rows, layout%sp_om(2), layout%sp_om(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_ep(rows, layout%sp_ep(2), layout%sp_ep(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_x2(rows, layout%sp_x2(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sp_ci(rows, layout%sp_ci(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vf(rows, layout%sd_vf(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vp(rows, layout%sd_vp(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vv(rows, layout%sd_vv(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vn(rows, layout%sd_vn(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vh(rows, layout%sd_vh(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vk(rows, layout%sd_vk(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_va(rows, layout%sd_va(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vc(rows, layout%sd_vc(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_v2(rows, layout%sd_v2(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_v3(rows, layout%sd_v3(2), layout%sd_v3(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vd(rows, layout%sd_vd(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_sm(rows, layout%sd_sm(2), layout%sd_sm(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_ws(rows, layout%sd_ws(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_ww(rows, layout%sd_ww(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_vx(rows, layout%sd_vx(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_xa(rows, layout%sd_xa(2), layout%sd_xa(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_xr(rows, layout%sd_xr(2), layout%sd_xr(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_x2(rows, layout%sd_x2(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_sfl(rows, layout%sd_sfl(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_sfo(rows, layout%sd_sfo(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_pf(rows, layout%sd_pf(2), layout%sd_pf(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_di(rows, layout%sd_di(2), layout%sd_di(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_oc(rows, layout%sd_oc(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_xp(rows, layout%sd_xp(2), layout%sd_xp(1), blocks), stat=error)
    if (error /= 0) goto900
    allocate (state%sd_xp2(rows, layout%sd_xp2(2), layout%sd_xp2(1), blocks), stat=error)
    if (error /= 0) goto900
    state%sp_sl = 0.0_real64
    state%sp_rr = 0.0_real64
    state%sp_sg = 0.0_real64
    state%sd_vf = 0.0_real64
    status = 0
    goto910
900 ignored = release_surface_field_owners(state)
    status = 1
910 call ieee_set_status(incoming)
    error_number = saved_errno
  end function
  integer(int32) function release_surface_field_owners(state) result(status)
    !! Release every allocated array in source order. Repeated release is
    !! harmless. Borrowed views are no longer valid after this call.
    type(surface_field_state), intent(inout) :: state
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: incoming
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (allocated(state%sp_sb)) deallocate (state%sp_sb)
    if (allocated(state%sp_sg)) deallocate (state%sp_sg)
    if (allocated(state%sp_sl)) deallocate (state%sp_sl)
    if (allocated(state%sp_rr)) deallocate (state%sp_rr)
    if (allocated(state%sp_cl)) deallocate (state%sp_cl)
    if (allocated(state%sp_om)) deallocate (state%sp_om)
    if (allocated(state%sp_ep)) deallocate (state%sp_ep)
    if (allocated(state%sp_x2)) deallocate (state%sp_x2)
    if (allocated(state%sp_ci)) deallocate (state%sp_ci)
    if (allocated(state%sd_vf)) deallocate (state%sd_vf)
    if (allocated(state%sd_vp)) deallocate (state%sd_vp)
    if (allocated(state%sd_vv)) deallocate (state%sd_vv)
    if (allocated(state%sd_vn)) deallocate (state%sd_vn)
    if (allocated(state%sd_vh)) deallocate (state%sd_vh)
    if (allocated(state%sd_vk)) deallocate (state%sd_vk)
    if (allocated(state%sd_va)) deallocate (state%sd_va)
    if (allocated(state%sd_vc)) deallocate (state%sd_vc)
    if (allocated(state%sd_v2)) deallocate (state%sd_v2)
    if (allocated(state%sd_v3)) deallocate (state%sd_v3)
    if (allocated(state%sd_vd)) deallocate (state%sd_vd)
    if (allocated(state%sd_sm)) deallocate (state%sd_sm)
    if (allocated(state%sd_ws)) deallocate (state%sd_ws)
    if (allocated(state%sd_ww)) deallocate (state%sd_ww)
    if (allocated(state%sd_vx)) deallocate (state%sd_vx)
    if (allocated(state%sd_xa)) deallocate (state%sd_xa)
    if (allocated(state%sd_xr)) deallocate (state%sd_xr)
    if (allocated(state%sd_x2)) deallocate (state%sd_x2)
    if (allocated(state%sd_sfl)) deallocate (state%sd_sfl)
    if (allocated(state%sd_sfo)) deallocate (state%sd_sfo)
    if (allocated(state%sd_pf)) deallocate (state%sd_pf)
    if (allocated(state%sd_di)) deallocate (state%sd_di)
    if (allocated(state%sd_oc)) deallocate (state%sd_oc)
    if (allocated(state%sd_xp)) deallocate (state%sd_xp)
    if (allocated(state%sd_xp2)) deallocate (state%sd_xp2)
    call ieee_set_status(incoming)
    error_number = saved_errno
    status = 0
  end function
  integer(int32) function borrow_surface_input_owners(state, views) result(status)
    !! Borrow the six complete input-array views without allocation/copy.
    !! The actual state must have TARGET and outlive every view. The
    !! original SP_SG snow array is exposed as the sp_ssn flattened view.
    !! Each view is(P,plane,B); layer then field form the plane index.
    !! Return2 without changing views for an incomplete selected layout.
    type(surface_field_state), target, intent(inout) :: state
    type(surface_input_owners), intent(inout) :: views
    type(surface_input_owners) :: staged
    integer :: p, b
    status = 2
    if (.not. allocated(state%sp_sb)) return
    if (.not. allocated(state%sp_sl)) return
    if (.not. allocated(state%sp_sg)) return
    if (.not. allocated(state%sp_rr)) return
    if (.not. allocated(state%sd_vf)) return
    if (.not. allocated(state%sd_ws)) return
    p = size(state%sp_sb, 1); b = size(state%sp_sb, 4)
    if (p < 1 .or. p > 1024 .or. b < 1) return
    if (any(shape(state%sp_sb) /= [p, 4, 6, b])) return
    if (any(shape(state%sp_sg) /= [p, 5, 10, b])) return
    if (any(shape(state%sp_sl) /= [p, 14, b])) return
    if (any(shape(state%sp_rr) /= [p, 4, b])) return
    if (any(shape(state%sd_vf) /= [p, 38, b])) return
    if (any(shape(state%sd_ws) /= [p, 3, b])) return
    staged%sp_sb(1:p, 1:24, 1:b) => state%sp_sb
    staged%sp_sl => state%sp_sl
    staged%sp_ssn(1:p, 1:50, 1:b) => state%sp_sg
    staged%sp_rr => state%sp_rr
    staged%sd_vf => state%sd_vf
    staged%sd_ws => state%sd_ws
    views = staged
    status = 0
  end function
end module
