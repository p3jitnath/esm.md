!> Selected spherical CALL_SL with native arrays and owned temporary storage.
!! The caller supplies initialized controls and actual field-array views.
!! This parent binds source planes,owns the missing work and calls its own
!! halo,trajectory and prognostic calculations in their original order.
module md2asm_native_call_sl
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_semi_lagrangian_buffer_types, only: native_semi_lagrangian_buffers, native_interpolation_controls
  use forecast_geometry_block_storage, only: native_spherical_block_view
  use md2asm_internal_interpolation_plane_maps, only: interpolation_plane_controls, linear_weight_plane_map, &
                                                      nonlinear_weight_plane_map, cartesian_coordinate_plane_map
  use md2asm_semi_lagrangian_transport_stage, only: transport_stage_controls, transport_trajectory_inputs, &
                              transport_update_inputs, transport_block_views, transport_stage_counts, advance_semi_lagrangian_stages
  use md2asm_transport_work_storage, only: transport_work_storage, ensure_transport_work_storage, &
                                           record_completed_transport_call
  use md2asm_transport_source_buffer_views, only: bind_first_transport_buffer_sources
  use md2asm_interpolation_weight_views, only: bind_interpolation_weight_views
  use md2asm_transport_geometry_block_views, only: bind_transport_geometry_block_views
  implicit none
  private
  public :: native_call_sl_arrays, advance_native_call_sl
  !> Borrow the actual array arguments of the selected CALL_SL caller.
  !! Every pointer retains its complete containing owner. Parent/horizontal
  !! indices are KL0/KLH0 with native circle slots1:4. Linear/nonlinear
  !! weights are PLSCAW/PRSCAW. second_buffer is PB2 and previous_eta_rate
  !! is PWRL9. saved_departure is source RSAVEDP,used only when enabled.
  !! general_state/surface_state are PGMVT1/PGMVT1S,not remapped field copies.
  !! constituent_state is the independent next-time GFLT1 owner allocated
  !! by the actual next-time storage producer;it is not GFLPT. old_moisture
  !! is the source PGFL(:,:,YQ%MP,:) view,which can be strided between blocks.
  !! diffusion_general,constituent and linear_general retain the caller's
  !! GMVTNDSL_DDH,GFLTNDSL_DDH and GMVTNDSI_DDH arrays. split_u/v/temperature
  !! are PUP9/PVP9/PTP9. split_constituent is the caller-local ZPBGFLP9,
  !! not GFLSLP. All four split arrays remain allocated even with zero fields.
  !! Weather owners have (pitch,levels,field,block),surface fields have
  !! (pitch,field,block),and scalar fields have (pitch,levels,block).
  !! The caller keeps source-declared aliases and every owner alive and fixed.
  type :: native_call_sl_arrays
    integer(int32), pointer :: parent_index(:, :, :, :) => null(), horizontal_index(:, :, :, :) => null()
    real(real64), pointer :: linear_weights(:, :, :, :) => null(), nonlinear_weights(:, :, :, :) => null()
    real(real64), pointer :: second_buffer(:, :, :) => null(), previous_eta_rate(:, :, :) => null()
    real(real64), pointer :: saved_departure(:, :, :, :) => null(), old_moisture(:, :, :) => null()
    real(real64), pointer :: general_state(:, :, :, :) => null(), surface_state(:, :, :) => null()
    real(real64), pointer :: constituent_state(:, :, :, :) => null()
    real(real64), pointer :: diffusion_general(:, :, :, :) => null(), diffusion_constituent(:, :, :, :) => null()
    real(real64), pointer :: linear_general(:, :, :, :) => null()
    real(real64), pointer :: split_u(:, :, :) => null(), split_v(:, :, :) => null(), split_temperature(:, :, :) => null()
    real(real64), pointer :: split_constituent(:, :, :, :) => null()
  end type
  interface
    function call_sl_errno_location() bind(C, name='__errno_location') result(p)
      import c_ptr
      type(c_ptr) :: p
    end function
  end interface
contains
  !> Advance the complete selected transport body through its own children.
  !! buffer is the actual real64(0:NASLB1-1,at least NFLDSLB1) packed owner.
  !! Geometry comes from the initialized native spherical block producer.
  !! Controls and field maps come from their native setup producers;no private
  !! model offsets or comparison callback supplies a value or calculation.
  !! RTDT remains trajectory%trajectory%time_factor in seconds. This parent
  !! adds no coordinate,radius or clock scale. The full input-level bounds
  !! remain trajectory%fields%first_input_level:last_input_level.
  !! retained owns the three persistent half-index,half-weight and coordinate
  !! arrays. Matching shapes retain their bits and addresses. Borrowed local
  !! views expire on return,before any later resize or release.
  !! The selected source requires equal physical/capacity point counts,
  !! hydrostatic spherical third-order transport and no on-demand exchange.
  !! Existing children retain their complete,narrower admitted domains.
  !! Status2 refuses metadata collectively before weather writes;status1
  !! reports collective allocation failure. A later child failure aborts the
  !! communicator,so partial weather state is never accepted as a return.
  !! This source is a compiled candidate until an independent parent gate.
  subroutine advance_native_call_sl(comm, c, sl, buffers, buffer_controls, plane_controls, linear_map, &
     nonlinear_map,nonlinear_half_map,cartesian_map,geometry,buffer,arrays,trajectory,update,retained,counts,status,workspace_limit)
    type(MPI_Comm), intent(in) :: comm
    type(transport_stage_controls), intent(in) :: c
    type(native_interpolation_state), target, intent(in) :: sl
    type(native_semi_lagrangian_buffers), intent(in) :: buffers
    type(native_interpolation_controls), intent(in) :: buffer_controls
    type(interpolation_plane_controls), intent(in) :: plane_controls
    type(linear_weight_plane_map), intent(in) :: linear_map
    type(nonlinear_weight_plane_map), intent(in) :: nonlinear_map, nonlinear_half_map
    type(cartesian_coordinate_plane_map), intent(in) :: cartesian_map
    type(native_spherical_block_view), intent(in) :: geometry(:)
    real(real64), contiguous, target, intent(inout) :: buffer(0:, :)
    type(native_call_sl_arrays), intent(inout) :: arrays
    type(transport_trajectory_inputs), intent(in) :: trajectory
    type(transport_update_inputs), intent(in) :: update
    type(transport_work_storage), target, intent(inout) :: retained
    type(transport_stage_counts), intent(inout) :: counts
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: workspace_limit
    type(transport_stage_controls) :: local_c
    type(transport_trajectory_inputs) :: local_trajectory
    type(transport_update_inputs) :: local_update
    type(transport_block_views), allocatable :: blocks(:)
    type(transport_block_views) :: empty_block
    real(real64), allocatable, target :: interpolated_u(:, :, :), interpolated_v(:, :, :)
    integer(int32), allocatable, target :: weno_shift(:, :, :)
    integer(int32), pointer, contiguous :: parent_block(:, :, :), horizontal_block(:, :, :)
    real(real64), pointer, contiguous :: linear_block(:, :, :), nonlinear_block(:, :, :)
    integer(int32) :: local_status, global_status, child_status
    integer(int64) :: block_count, private_bytes, budget, cells
    integer :: j, allocation_status, fields, base
    logical :: hermite
    status = 2
    local_status = 2
    if (c%pitch < 1 .or. c%pitch > 1024 .or. c%levels < 5 .or. c%levels > 256) goto 100
    if (c%point_count < 1 .or. c%point_capacity /= c%point_count) goto 100
    block_count = (int(c%point_count, int64) + int(c%pitch, int64) - 1_int64)/int(c%pitch, int64)
    if (block_count /= size(geometry, kind=int64)) goto 100
    if (.not. allocated(sl%nloeng) .or. .not. allocated(sl%nsloff)) goto 100
    if (.not. allocated(buffers%first%rparsl1)) goto 100
    if (buffers%first%nfldslb1 /= c%field_count) goto 100
    if (size(buffer, 1) /= sl%naslb1 .or. size(buffer, 2) < c%field_count) goto 100
    if (.not. associated(update%components) .or. .not. associated(update%destinations)) goto 100
    if (.not. associated(trajectory%selectors) .or. .not. associated(trajectory%diagnostics)) goto 100
    if (trajectory%trajectory%rhs_curvature .neqv. update%controls%lrhs_curv) goto 100
    if (.not. valid_arrays()) goto 100
    if (cartesian_map%ndim /= 4) goto 100
    if (any([cartesian_map%m_rlon, cartesian_map%m_rlat, cartesian_map%m_rqx, cartesian_map%m_rqy] /= [1, 2, 3, 4])) goto 100
    fields = size(arrays%second_buffer, 2)
    if (buffers%second%nfldslb2 < 1 .or. fields < buffers%second%nfldslb2) goto 100
    if (.not. valid_window(buffers%second%mslb2url, fields)) goto 100
    if (.not. valid_window(buffers%second%mslb2vrl, fields)) goto 100
    if (.not. valid_window(buffers%second%mslb2zrl, fields)) goto 100
    if (.not. valid_window(buffers%second%mslb2wrl, fields)) goto 100
    if (.not. optional_window(buffers%second%mslb2kappa, fields)) goto 100
    if (.not. optional_window(buffers%second%mslb2kappat, fields)) goto 100
    if (.not. optional_window(buffers%second%mslb2kappam, fields)) goto 100
    if (.not. optional_window(buffers%second%mslb2kappah, fields)) goto 100
    if (.not. optional_window(buffers%second%mslb2stddisu, fields)) goto 100
    if (.not. optional_window(buffers%second%mslb2stddisv, fields)) goto 100
    if (.not. optional_window(buffers%second%mslb2stddisw, fields)) goto 100
    cells = int(c%pitch, int64)*int(c%levels, int64)*block_count
    private_bytes = 20_int64*cells + block_count*int(storage_size(empty_block)/8, int64)
    if (private_bytes > 64_int64*1024_int64**3) goto 100
    budget = 3_int64*64_int64*1024_int64**3
    if (present(workspace_limit)) then
      if (workspace_limit < private_bytes) goto 100
      budget = workspace_limit - private_bytes
    end if
    local_status = 0
100 continue
    call agree_call_sl(comm, local_status, global_status)
    if (global_status /= 0) then
      status = global_status
      return
    end if
    local_c = c
    local_c%stencil_width = sl%nslwide
    local_trajectory = trajectory
    local_update = update
    call ensure_transport_work_storage(retained, c%pitch, c%levels, int(block_count, int32), &
                                       nonlinear_half_map%ndim, cartesian_map%ndim, local_status, budget)
    call agree_call_sl(comm, local_status, global_status)
    if (global_status /= 0) then
      status = global_status
      return
    end if
    allocate (blocks(int(block_count)), interpolated_u(c%pitch, c%levels, int(block_count)), &
       interpolated_v(c%pitch, c%levels, int(block_count)), weno_shift(c%pitch, c%levels, int(block_count)), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_call_sl(comm, local_status, global_status)
    if (global_status /= 0) then
      status = global_status
      return
    end if
    ! These source-private indicators are not weather inputs or declared output.
    weno_shift = 0
    call bind_first_transport_buffer_sources(trajectory%fields%first_input_level, trajectory%fields%last_input_level, &
                      buffers, buffer_controls, buffer, update%components, local_trajectory%source_fields, local_update%transport, &
                                             local_update%maps, local_status)
    call bind_transport_geometry_block_views(c%pitch, c%point_count, geometry, blocks, child_status)
    local_status = max(local_status, child_status)
    local_trajectory%latitude%halo_first = sl%ndgsah
    local_trajectory%latitude%halo_last = sl%ndgenh
    local_trajectory%latitude%global_first = sl%ndgsag
    local_trajectory%latitude%global_last = sl%ndgeng
    local_trajectory%latitude%local_first = sl%ndgsal
    local_trajectory%latitude%local_last = sl%ndgenl
    local_trajectory%latitude%first_offset = sl%nfrstloff
    local_trajectory%latitude%halo_width = sl%nslwide
    local_trajectory%latitude%count_first = lbound(sl%nloeng, 1)
    local_trajectory%latitude%buffer_first = lbound(sl%nsloff, 1)
    local_trajectory%latitude%point_count => sl%nloeng
    local_trajectory%latitude%buffer_offset => sl%nsloff
    hermite = .false.
    do j = 1, size(trajectory%selectors)
      select case (trajectory%selectors(j))
      case ('LAIHVT      ', 'LAIHVTQM    ', 'LAIHVTQMH   ')
        hermite = .true.
      end select
    end do
    do j = 1, int(block_count)
      ! Each block is contiguous even when its complete outer view is strided.
      ! Contiguous pointer actuals prevent a temporary from outliving a binder.
      parent_block => arrays%parent_index(:, :, :, j)
      horizontal_block => arrays%horizontal_index(:, :, :, j)
      linear_block => arrays%linear_weights(:, :, :, j)
      nonlinear_block => arrays%nonlinear_weights(:, :, :, j)
      call bind_interpolation_weight_views(c%pitch, c%levels, plane_controls, plane_controls%lvsplip, hermite, &
                                           linear_map, nonlinear_map, linear_block, nonlinear_block, &
                                           parent_block, horizontal_block, retained%level_index(:, :, 1, j), &
                                           weno_shift(:, :, j), blocks(j)%weights, child_status)
      local_status = max(local_status, child_status)
      blocks(j)%trajectory_state%longitude => retained%coordinates(:, :, cartesian_map%m_rlon, j)
      blocks(j)%trajectory_state%latitude => retained%coordinates(:, :, cartesian_map%m_rlat, j)
      blocks(j)%trajectory_state%rotation_p => retained%coordinates(:, :, cartesian_map%m_rqx, j)
      blocks(j)%trajectory_state%rotation_q => retained%coordinates(:, :, cartesian_map%m_rqy, j)
      blocks(j)%trajectory_state%u => interpolated_u(:, :, j)
      blocks(j)%trajectory_state%v => interpolated_v(:, :, j)
      blocks(j)%trajectory_state%parent_index => arrays%parent_index(:, :, :, j)
      blocks(j)%trajectory_state%horizontal_index => arrays%horizontal_index(:, :, :, j)
      if (associated(arrays%saved_departure)) blocks(j)%trajectory_state%saved => arrays%saved_departure(:, :, :, j)
      base = buffers%second%mslb2url
      blocks(j)%wind%u => arrays%second_buffer(:, base:base + (c%levels - 1), j)
      base = buffers%second%mslb2vrl
      blocks(j)%wind%v => arrays%second_buffer(:, base:base + (c%levels - 1), j)
      base = buffers%second%mslb2zrl
      blocks(j)%wind%z => arrays%second_buffer(:, base:base + (c%levels - 1), j)
      base = buffers%second%mslb2wrl
      blocks(j)%wind%eta_rate => arrays%second_buffer(:, base:base + (c%levels - 1), j)
      call optional_field(buffers%second%mslb2kappa, j, blocks(j)%weight_inputs%kappa)
      call optional_field(buffers%second%mslb2kappat, j, blocks(j)%weight_inputs%heat_kappa)
      call optional_field(buffers%second%mslb2kappam, j, blocks(j)%weight_inputs%momentum_turbulence)
      call optional_field(buffers%second%mslb2kappah, j, blocks(j)%weight_inputs%heat_turbulence)
      call optional_field(buffers%second%mslb2stddisu, j, blocks(j)%weight_inputs%longitude_correction_scale)
      call optional_field(buffers%second%mslb2stddisv, j, blocks(j)%weight_inputs%latitude_correction_scale)
      call optional_field(buffers%second%mslb2stddisw, j, blocks(j)%weight_inputs%vertical_correction_scale)
      blocks(j)%previous_eta_rate => arrays%previous_eta_rate(:, :, j)
      blocks(j)%diagnostic_values => arrays%constituent_state(:, :, :, j)
      blocks(j)%old_moisture => arrays%old_moisture(:, :, j)
      blocks(j)%general_state => arrays%general_state(:, :, :, j)
      blocks(j)%surface_state => arrays%surface_state(:, :, j)
      blocks(j)%constituent_state => arrays%constituent_state(:, :, :, j)
      blocks(j)%diffusion_general => arrays%diffusion_general(:, :, :, j)
      blocks(j)%diffusion_constituent => arrays%diffusion_constituent(:, :, :, j)
      blocks(j)%linear_general => arrays%linear_general(:, :, :, j)
      blocks(j)%split_u => arrays%split_u(:, :, j)
      blocks(j)%split_v => arrays%split_v(:, :, j)
      blocks(j)%split_temperature => arrays%split_temperature(:, :, j)
      blocks(j)%split_constituent => arrays%split_constituent(:, :, :, j)
    end do
    call agree_call_sl(comm, local_status, global_status)
    if (global_status /= 0) then
      status = global_status
      return
    end if
    call advance_semi_lagrangian_stages(comm, local_c, sl, buffers%first%rparsl1, buffer, &
                                        local_trajectory, local_update, blocks, counts, status)
    if (status /= 0) return
    call record_completed_transport_call(retained, status)
  contains
    logical function valid_window(start, extent)
      integer(int32), intent(in) :: start
      integer, intent(in) :: extent
      valid_window = start >= 1 .and. int(start, int64) + int(c%levels, int64) - 1_int64 <= int(extent, int64)
    end function
    logical function optional_window(start, extent)
      integer(int32), intent(in) :: start
      integer, intent(in) :: extent
      optional_window = .true.
      if (start > 0) optional_window = valid_window(start, extent)
    end function
    subroutine optional_field(start, block, view)
      integer(int32), intent(in) :: start
      integer, intent(in) :: block
      real(real64), pointer, intent(out) :: view(:, :)
      nullify (view)
      if (start > 0) view => arrays%second_buffer(:, start:start + (c%levels - 1), block)
    end subroutine
    logical function valid_arrays()
      integer :: block
      valid_arrays = .false.
      if (.not. associated(arrays%parent_index) .or. .not. associated(arrays%horizontal_index)) return
      if (size(arrays%parent_index, 1) /= c%pitch .or. size(arrays%parent_index, 2) /= c%levels) return
      if (size(arrays%parent_index, 3) /= 4 .or. size(arrays%parent_index, 4, kind=int64) /= block_count) return
      if (any(shape(arrays%horizontal_index) /= shape(arrays%parent_index))) return
      do block = 1, int(block_count)
        if (.not. is_contiguous(arrays%parent_index(:, :, :, block))) return
        if (.not. is_contiguous(arrays%horizontal_index(:, :, :, block))) return
      end do
      if (.not. field4(arrays%linear_weights) .or. .not. field4(arrays%nonlinear_weights)) return
      if (.not. scalar3(arrays%previous_eta_rate) .or. .not. scalar3(arrays%old_moisture)) return
      if (.not. associated(arrays%second_buffer)) return
      if (size(arrays%second_buffer, 1) /= c%pitch .or. size(arrays%second_buffer, 3, kind=int64) /= block_count) return
      do block = 1, int(block_count)
        if (.not. is_contiguous(arrays%second_buffer(:, :, block))) return
      end do
      if (trajectory%trajectory%save_departure) then
        if (.not. field4(arrays%saved_departure)) return
        if (size(arrays%saved_departure, 3) < 3) return
      else if (associated(arrays%saved_departure)) then
        if (.not. field4(arrays%saved_departure)) return
      end if
      if (.not. field4(arrays%general_state) .or. .not. field4(arrays%constituent_state)) return
      if (.not. associated(arrays%surface_state)) return
      if (size(arrays%surface_state, 1) /= c%pitch .or. size(arrays%surface_state, 3, kind=int64) /= block_count) return
      do block = 1, int(block_count)
        if (.not. is_contiguous(arrays%surface_state(:, :, block))) return
      end do
      if (.not. diagnostic4(arrays%diffusion_general, update%transport%diffusion_diagnostic)) return
      if (.not. diagnostic4(arrays%diffusion_constituent, update%transport%diffusion_diagnostic)) return
      if (.not. diagnostic4(arrays%linear_general, update%transport%linear_diagnostic)) return
      if (.not. scalar3(arrays%split_u) .or. .not. scalar3(arrays%split_v)) return
      if (.not. scalar3(arrays%split_temperature) .or. .not. field4(arrays%split_constituent)) return
      valid_arrays = .true.
    end function
    !> Inactive SUNDDH arrays retain their real1x1 source prefix.
    !! Enabled diagnostics require the complete physical block. The child
    !! never reads or writes the prefix when its corresponding flag is false.
    logical function diagnostic4(view, enabled)
      real(real64), pointer, intent(in) :: view(:, :, :, :)
      logical, intent(in) :: enabled
      integer :: block
      diagnostic4 = .false.
      if (.not. associated(view)) return
      if (enabled) then
        diagnostic4 = field4(view)
        return
      end if
      if (field4(view)) then
        diagnostic4 = .true.
        return
      end if
      if (size(view, 1) /= 1 .or. size(view, 2) /= 1) return
      if (size(view, 4, kind=int64) /= block_count) return
      do block = 1, int(block_count)
        if (.not. is_contiguous(view(:, :, :, block))) return
      end do
      diagnostic4 = .true.
    end function
    logical function scalar3(view)
      real(real64), pointer, intent(in) :: view(:, :, :)
      integer :: block
      scalar3 = .false.
      if (.not. associated(view)) return
      if (size(view, 1) /= c%pitch .or. size(view, 2) < c%levels .or. size(view, 3, kind=int64) /= block_count) return
      do block = 1, int(block_count)
        if (.not. is_contiguous(view(:, :, block))) return
      end do
      scalar3 = .true.
    end function
    logical function field4(view)
      real(real64), pointer, intent(in) :: view(:, :, :, :)
      integer :: block
      field4 = .false.
      if (.not. associated(view)) return
      if (size(view, 1) /= c%pitch .or. size(view, 2) < c%levels .or. size(view, 4, kind=int64) /= block_count) return
      do block = 1, int(block_count)
        if (.not. is_contiguous(view(:, :, :, block))) return
      end do
      field4 = .true.
    end function
  end subroutine

  !> Agree only metadata/allocation status,retaining incoming FP status and errno.
  subroutine agree_call_sl(comm, local_status, global_status)
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: global_status
    type(ieee_status_type) :: saved_fp
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    integer :: ierr
    call ieee_get_status(saved_fp)
    call c_f_pointer(call_sl_errno_location(), errno_pointer)
    saved_errno = errno_pointer
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER4, MPI_MAX, comm, ierr)
    call ieee_set_status(saved_fp)
    errno_pointer = saved_errno
    if (ierr /= MPI_SUCCESS) then
      call MPI_Abort(comm, 3, ierr)
      error stop 'CALL_SL metadata agreement failed'
    end if
  end subroutine
end module md2asm_native_call_sl
