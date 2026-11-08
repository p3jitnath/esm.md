!> Compose native halo exchange,trajectory calculation and field updates.
!! This selected spherical route keeps the source order: halo,all trajectory
!! blocks,then all prognostic blocks. It adds no floating-point equation.
module md2asm_semi_lagrangian_transport_stage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use mpi_f08
  use forecast_interpolation_state_types, only: native_interpolation_state
  use md2asm_fixed_interpolation_exchange, only: exchange_fixed_interpolation_halo
  use md2asm_polar_halo_fill, only: fill_polar_halo_mode_one
  use md2asm_trajectory_interpolation_parent, only: trajectory_latitude_partition, &
                                    trajectory_interpolation_controls, trajectory_diagnostic_field, prepare_trajectory_interpolation
  use md2asm_cartesian_departure_points, only: cartesian_departure_controls, cartesian_arrival_geometry, &
                                               cartesian_arrival_wind, cartesian_departure_state
  use md2asm_departure_coordinate_fields, only: departure_field_controls, trajectory_field_component
  use md2asm_departure_interpolation_weights, only: departure_weight_controls, departure_weight_geometry, &
                                                    departure_weight_inputs, departure_weight_outputs
  use md2asm_departure_field_transport, only: departure_transport_controls, general_transport_map, &
                                              constituent_transport_map
  use md2asm_prognostic_departure_update, only: prognostic_departure_controls, prognostic_departure_state_map, &
                                                prognostic_constituent_destination, update_prognostic_departure_fields
  use md2asm_weno_departure_interpolation, only: weno_interpolation_controls
  use md2asm_vertical_operators, only: vertical_operator_matrices
  implicit none
  private
  public :: transport_stage_controls, transport_trajectory_inputs, transport_update_inputs
  public :: transport_block_views, transport_stage_counts, advance_semi_lagrangian_stages
  type :: transport_stage_controls
    integer(int32) :: pitch = 0, levels = 0, point_count = 0, point_capacity = 0, field_count = 0, stencil_width = 2
    integer(int32) :: predictor_storage_count = 0
    logical :: plane = .false., synchronise_exchange = .false., debug_exchange = .false.
    logical :: convective_departure_copy = .false.
  end type
  !> Borrow initialized trajectory controls,geometry and source field planes.
  !! Angles are radians. Cartesian arrival coordinates retain their source
  !! length unit;the operational geometry owner supplies metres.
  !! time_factor inside trajectory is the actual RTDT in seconds from UPDTIM;
  !! its input rates already have the matching coordinate units per second.
  !! full_eta stores0:levels+1;half_eta stores0:levels. Other named views use
  !! their native child contracts. Selectors are exact12-character CSLINT.
  type :: transport_trajectory_inputs
    type(trajectory_interpolation_controls) :: controls
    type(trajectory_latitude_partition) :: latitude
    type(cartesian_departure_controls) :: trajectory
    type(departure_field_controls) :: fields
    type(departure_weight_controls) :: trajectory_weights, final_weights
    type(departure_weight_geometry) :: geometry
    type(trajectory_field_component) :: source_fields(4)
    real(real64), pointer, contiguous :: full_eta(:) => null(), half_eta(:) => null()
    character(len=12), pointer :: selectors(:) => null()
    type(trajectory_diagnostic_field), pointer :: diagnostics(:) => null()
  end type
  !> Borrow the initialized field-selection maps and vertical coefficients.
  !! Layer weights are dimensionless. Inverse layer width has the inverse
  !! unit of the supplied vertical coordinate. dry_gas_constant is J/(kg K).
  !! No model record or private descriptor is interpreted by this type.
  type :: transport_update_inputs
    type(prognostic_departure_controls) :: controls
    type(prognostic_departure_state_map) :: state_map
    type(departure_transport_controls) :: transport
    type(general_transport_map) :: maps(3)
    type(constituent_transport_map), pointer :: components(:) => null()
    type(prognostic_constituent_destination), pointer :: destinations(:) => null()
    type(vertical_operator_matrices) :: tables
    type(weno_interpolation_controls) :: weno
    real(real64), pointer, contiguous :: layer_weight(:) => null(), inverse_layer_width(:) => null()
    real(real64) :: dry_gas_constant = 0.0_real64
  end type
  !> Borrow one complete source block;the caller retains containing owners.
  !! Each real plane uses(pitch,at least levels). Three-dimensional weather
  !! arrays use(pitch,at least levels,field). Diagnostics use the same order.
  !! These are native views only;they do not supply a calculation. The parent
  !! writes weights through its own trajectory child and immediately passes
  !! those same views to its own prognostic child. Inactive cells remain.
  !! Every pointer passed as an ordinary child array must be associated,
  !! including an allocated zero extent for an unused field family.
  type :: transport_block_views
    type(cartesian_arrival_geometry) :: arrival
    type(cartesian_arrival_wind) :: wind
    type(cartesian_departure_state) :: trajectory_state
    type(departure_weight_inputs) :: weight_inputs
    type(departure_weight_outputs) :: weights
    real(real64), pointer, contiguous :: north_m(:) => null(), north_l(:) => null()
    real(real64), pointer, contiguous :: previous_eta_rate(:, :) => null()
    real(real64), pointer, contiguous :: diagnostic_values(:, :, :) => null()
    real(real64), pointer, contiguous :: old_moisture(:, :) => null()
    real(real64), pointer, contiguous :: general_state(:, :, :) => null(), surface_state(:, :) => null()
    real(real64), pointer, contiguous :: constituent_state(:, :, :) => null()
    real(real64), pointer, contiguous :: diffusion_general(:, :, :) => null(), diffusion_constituent(:, :, :) => null()
    real(real64), pointer, contiguous :: linear_general(:, :, :) => null()
    real(real64), pointer, contiguous :: split_u(:, :) => null(), split_v(:, :) => null()
    real(real64), pointer, contiguous :: split_temperature(:, :) => null(), split_constituent(:, :, :) => null()
  end type
  type :: transport_stage_counts
    integer(int64) :: completed_calls = 0, exchanges = 0, polar_fills = 0, trajectory_blocks = 0, prognostic_blocks = 0
  end type
  interface
    subroutine gstats(tag, switch)
      import int32
      integer(int32), intent(in) :: tag, switch
    end subroutine
    function transport_errno_location() bind(C, name='__errno_location') result(p)
      import c_ptr
      type(c_ptr) :: p
    end function
  end interface
contains
  !> Advance one selected CALL_SL stage using complete native block views.
  !! sl and all initialized control/map inputs are read only. buffer is the
  !! writable real64(0:NASLB1-1,field_count) halo owner. blocks supplies the
  !! exact ceil(point_count/pitch) views,with a shorter active final block.
  !! Views are disjoint except source-declared aliases within their complete
  !! containing owner. Source field views must refer to the actual buffer
  !! planes selected by their initialized field metadata. The parent performs
  !! no numerical preparation in an external callback or comparison driver.
  !! Before any profiling or write,processes agree shape/policy admission.
  !! Status2 refuses unsupported parent inputs collectively. Once children
  !! start,a failure aborts comm;partial weather state is not accepted.
  !! All children retain their narrower supported domains and qualification.
  !! This stage core does not create the named field/weight views or own their
  !! retained storage;the explicit native binding producer remains required.
  subroutine advance_semi_lagrangian_stages(comm, c, sl, parity, buffer, trajectory, update, blocks, counts, status)
    type(MPI_Comm), intent(in) :: comm
    type(transport_stage_controls), intent(in) :: c
    type(native_interpolation_state), intent(in) :: sl
    real(real64), intent(in) :: parity(:)
    real(real64), contiguous, target, intent(inout) :: buffer(0:, :)
    type(transport_trajectory_inputs), intent(in) :: trajectory
    type(transport_update_inputs), intent(in) :: update
    type(transport_block_views), intent(inout) :: blocks(:)
    type(transport_stage_counts), intent(inout) :: counts
    integer(int32), intent(out) :: status
    integer(int32) :: local_status, global_status, child_status, last, unused_fixed(2)
    integer :: world, rank, ierr, j, block_count
    integer(int64) :: first_point
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    type(cartesian_departure_controls) :: trajectory_control
    status = 2
    call c_f_pointer(transport_errno_location(), errno_pointer)
    saved_errno = errno_pointer
    call MPI_Comm_size(comm, world, ierr)
    if (ierr /= MPI_SUCCESS) call abort_transport(comm)
    call MPI_Comm_rank(comm, rank, ierr)
    if (ierr /= MPI_SUCCESS) call abort_transport(comm)
    errno_pointer = saved_errno
    call validate_stage(c, sl, world, parity, buffer, trajectory, update, blocks, counts, local_status)
    call agree_stage(comm, local_status, global_status)
    if (global_status /= 0) return
    block_count = size(blocks)
    unused_fixed = 0
    call gstats(8_int32, 2_int32)
    call gstats(51_int32, 0_int32)
    if (world > 1) then
      child_status = exchange_fixed_interpolation_halo(comm, sl, c%field_count, 0_int32, unused_fixed, &
                                                       c%synchronise_exchange, c%debug_exchange, buffer)
      if (child_status /= 0) call abort_transport(comm)
      counts%exchanges = counts%exchanges + 1_int64
    end if
    child_status = fill_polar_halo_mode_one(sl, c%stencil_width, c%field_count, parity, buffer)
    if (child_status /= 0) call abort_transport(comm)
    counts%polar_fills = counts%polar_fills + 1_int64
    call gstats(51_int32, 1_int32)
    call gstats(37_int32, 0_int32)
    call gstats(1004_int32, 0_int32)
    trajectory_control = trajectory%trajectory
    do j = 1, block_count
      first_point = (int(j, int64) - 1_int64)*int(c%pitch, int64)
      last = int(min(int(c%pitch, int64), int(c%point_count, int64) - first_point), int32)
      call prepare_trajectory_interpolation(c%pitch, c%levels, 1_int32, last, trajectory%controls, &
                                        trajectory%latitude, trajectory_control, trajectory%fields, trajectory%trajectory_weights, &
                                            trajectory%final_weights, trajectory%geometry, blocks(j)%arrival, blocks(j)%wind, &
                                  trajectory%full_eta, trajectory%half_eta, blocks(j)%previous_eta_rate, trajectory%source_fields, &
                               trajectory%selectors, trajectory%diagnostics, blocks(j)%diagnostic_values, blocks(j)%weight_inputs, &
                                            blocks(j)%weights, blocks(j)%trajectory_state, child_status)
      if (child_status /= 0) call abort_transport(comm)
      counts%trajectory_blocks = counts%trajectory_blocks + 1_int64
    end do
    call gstats(1004_int32, 1_int32)
    call gstats(1005_int32, 0_int32)
    do j = 1, block_count
      first_point = (int(j, int64) - 1_int64)*int(c%pitch, int64)
      last = int(min(int(c%pitch, int64), int(c%point_count, int64) - first_point), int32)
      call update_prognostic_departure_fields(sl%NASLB1, c%pitch, 1_int32, last, c%levels, update%controls, &
                       update%state_map, update%transport, update%maps, update%components, update%destinations, blocks(j)%weights, &
                     buffer, update%layer_weight, update%inverse_layer_width, update%tables, blocks(j)%north_m, blocks(j)%north_l, &
                             blocks(j)%trajectory_state%rotation_p, blocks(j)%trajectory_state%rotation_q, blocks(j)%old_moisture, &
                           update%dry_gas_constant, blocks(j)%general_state, blocks(j)%surface_state, blocks(j)%constituent_state, &
                                           blocks(j)%diffusion_general, blocks(j)%diffusion_constituent, blocks(j)%linear_general, &
                                   blocks(j)%split_u, blocks(j)%split_v, blocks(j)%split_temperature, blocks(j)%split_constituent, &
                                              child_status, update%weno, trajectory%half_eta)
      if (child_status /= 0) call abort_transport(comm)
      counts%prognostic_blocks = counts%prognostic_blocks + 1_int64
    end do
    call gstats(1005_int32, 1_int32)
    call gstats(37_int32, 1_int32)
    call gstats(8_int32, 3_int32)
    counts%completed_calls = counts%completed_calls + 1_int64
    status = 0
  end subroutine

  subroutine validate_stage(c, sl, world, parity, buffer, t, u, blocks, counts, status)
    type(transport_stage_controls), intent(in) :: c
    type(native_interpolation_state), intent(in) :: sl
    integer, intent(in) :: world
    real(real64), intent(in) :: parity(:), buffer(0:, :)
    type(transport_trajectory_inputs), intent(in) :: t
    type(transport_update_inputs), intent(in) :: u
    type(transport_block_views), intent(in) :: blocks(:)
    type(transport_stage_counts), intent(in) :: counts
    integer(int32), intent(out) :: status
    integer(int64) :: needed
    integer :: j, active_last
    status = 2
    if (c%pitch < 1 .or. c%pitch > 1024 .or. c%levels < 5 .or. c%levels > 256) return
    if (c%point_count < 1 .or. c%point_capacity /= c%point_count .or. c%field_count < 1) return
    if (c%predictor_storage_count /= 0 .or. c%plane .or. c%convective_departure_copy) return
    if (c%stencil_width < 2 .or. c%stencil_width > 3) return
    if (world < 1 .or. world > 65536) return
    if (sl%LSLONDEM .or. sl%LSLONDEM_ACTIVE) return
    if (sl%NASLB1 < 1 .or. c%debug_exchange) return
    if (size(buffer, 1, kind=int64) /= int(sl%NASLB1, int64)) return
    if (size(buffer, 2, kind=int64) < int(c%field_count, int64) .or. size(parity) < c%field_count) return
    needed = (int(c%point_count, int64) + int(c%pitch, int64) - 1_int64)/int(c%pitch, int64)
    if (size(blocks, kind=int64) /= needed) return
    if (t%final_weights%process_count /= world .or. t%trajectory_weights%process_count /= world) return
    if (t%final_weights%on_demand_communication .or. t%trajectory_weights%on_demand_communication) return
    if (.not. associated(t%full_eta) .or. .not. associated(t%half_eta)) return
    if (size(t%full_eta) < c%levels + 2 .or. size(t%half_eta) < c%levels + 1) return
    if (.not. associated(t%selectors) .or. .not. associated(t%diagnostics)) return
    if (.not. associated(u%components) .or. .not. associated(u%destinations)) return
    if (.not. associated(u%layer_weight) .or. .not. associated(u%inverse_layer_width)) return
    if (size(u%layer_weight) < c%levels .or. size(u%inverse_layer_width) < c%levels) return
    if (counts%completed_calls < 0 .or. counts%exchanges < 0 .or. counts%polar_fills < 0) return
    if (counts%trajectory_blocks < 0 .or. counts%prognostic_blocks < 0) return
    if (counts%completed_calls >= huge(0_int64) - 1 .or. counts%exchanges >= huge(0_int64) - 1) return
    if (counts%polar_fills >= huge(0_int64) - 1) return
    if (counts%trajectory_blocks > huge(0_int64) - needed .or. counts%prognostic_blocks > huge(0_int64) - needed) return
    do j = 1, size(blocks)
      if (.not. associated(blocks(j)%north_m) .or. .not. associated(blocks(j)%north_l)) return
      active_last = int(min(int(c%pitch, int64), int(c%point_count, int64) - int(j - 1, int64)*int(c%pitch, int64)))
      if (size(blocks(j)%north_m) < active_last .or. size(blocks(j)%north_l) < active_last) return
      if (.not. associated(blocks(j)%previous_eta_rate) .or. .not. associated(blocks(j)%diagnostic_values)) return
      if (.not. associated(blocks(j)%old_moisture)) return
      if (.not. associated(blocks(j)%general_state) .or. .not. associated(blocks(j)%surface_state)) return
      if (.not. associated(blocks(j)%constituent_state)) return
      if (.not. associated(blocks(j)%diffusion_general) .or. .not. associated(blocks(j)%diffusion_constituent)) return
      if (.not. associated(blocks(j)%linear_general)) return
      if (.not. associated(blocks(j)%split_u) .or. .not. associated(blocks(j)%split_v)) return
      if (.not. associated(blocks(j)%split_temperature) .or. .not. associated(blocks(j)%split_constituent)) return
      if (.not. associated(blocks(j)%trajectory_state%rotation_p) .or. &
          .not. associated(blocks(j)%trajectory_state%rotation_q)) return
    end do
    status = 0
  end subroutine

  subroutine agree_stage(comm, local_status, global_status)
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: global_status
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    integer :: ierr
    call c_f_pointer(transport_errno_location(), errno_pointer)
    saved_errno = errno_pointer
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER4, MPI_MAX, comm, ierr)
    if (ierr /= MPI_SUCCESS) call abort_transport(comm)
    errno_pointer = saved_errno
  end subroutine

  subroutine abort_transport(comm)
    type(MPI_Comm), intent(in) :: comm
    integer :: ierr
    call MPI_Abort(comm, 3, ierr)
    error stop 'Semi-Lagrangian child failure leaves the weather state unaccepted'
  end subroutine
end module md2asm_semi_lagrangian_transport_stage
