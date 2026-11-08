!> Borrow the real loaded fields and preserve the ordered transform prefix.
module forecast_loaded_grid_point_prefix
  use iso_fortran_env, only: int32, int64, real64
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_grid_point_update_strided, only: grid_point_column_views
  use md2asm_model_transform_callers, only: model_inverse_modes
  use md2asm_operational_model_transforms, only: operational_inverse_model_transform
  use forecast_operational_step_coefficients, only: update_operational_time_coefficients
  implicit none
  private
  public :: native_loaded_grid_point_binding, bind_loaded_grid_point_tile
  public :: transform_initialized_grid_point_model
  !> Readonly owner links and mutable source field sections for one block.
  !! P is the complete stored pitch; LAST counts active cells in the final block.
  !! All FP64 arrays retain their native bounds and physical source units.
  !! The enclosing execution is TARGET and must outlive every borrowed view.
  type :: native_loaded_grid_point_binding
    type(native_forecast_execution_state), pointer :: owner => null()
    type(grid_point_column_views) :: column
    real(real64), pointer, contiguous :: surface_rr(:, :) => null()
    real(real64), pointer, contiguous :: surface_sb(:, :, :) => null(), surface_sg(:, :, :) => null()
    real(real64), pointer, contiguous :: surface_vf(:, :) => null(), surface_vv(:, :) => null()
    integer(int32) :: pitch = 0, levels = 0, block = 0, last = 0
  end type
contains
  !> Stage all actual field sections before changing the destination metadata.
  !! BLOCK is a one-based local block. Status2 leaves OUTPUT unchanged.
  !! Six numerical sections and five surface sections borrow complete owners.
  integer(int32) function bind_loaded_grid_point_tile(state, block, output) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer(int32), intent(in) :: block
    type(native_loaded_grid_point_binding), intent(inout) :: output
    type(native_loaded_grid_point_binding) :: pending
    integer(int32) :: pitch, levels, blocks, points, active
    integer(int64) :: first
    status = 2
    if (.not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial) .or. .not. allocated(state%startup%loaded%storage)) return
    if (.not. allocated(state%startup%loaded%input)) return
    if (.not. allocated(state%startup%initial%geometry)) return
    if (.not. state%startup%initial%ready .or. .not. state%startup%initial%geometry%initialized) return
    if (.not. state%gp_work%columns_bound .or. .not. state%gp_work%maps_bound) return
    if (.not. allocated(state%gp_work%columns)) return
    if (.not. associated(state%grid%model, state%startup%loaded%storage%model)) return
    if (.not. associated(state%grid%fields, state%startup%loaded%input%upper%fields)) return
    if (.not. associated(state%grid%next, state%startup%loaded%next)) return
    if (.not. associated(state%grid%surface_arrays, state%startup%loaded%input%surface_arrays)) return
    associate (g => state%startup%initial%geometry, m => state%startup%loaded%storage%model%motion, &
               fields => state%startup%loaded%input%upper%fields, next => state%startup%loaded%next, &
               surface => state%startup%loaded%input%surface_arrays)
      pitch = g%dimensions%nproma; levels = g%dimensions%nflevg
      blocks = g%partition%ngpblks; points = g%partition%ngptot
      if (pitch < 1 .or. pitch > 256 .or. levels < 4 .or. levels > 256 .or. points < 1 .or. blocks < 1) return
      if (int(blocks, int64) /= (int(points, int64) + pitch - 1_int64)/pitch) return
      if (block < 1 .or. block > blocks .or. size(state%gp_work%columns) /= blocks) return
      if (state%gp_work%pitch /= pitch .or. state%gp_work%levels /= levels .or. state%gp_work%blocks /= blocks) return
      if (.not. allocated(m%gmv) .or. .not. allocated(m%gmvs)) return
      if (.not. allocated(m%gmvt1) .or. .not. allocated(m%gmvt1s)) return
      if (.not. allocated(fields%gfl) .or. .not. allocated(next%gflt1)) return
      if (size(m%gmv, 1) /= pitch .or. size(m%gmv, 2) /= levels) return
      if (size(m%gmv, 4) /= blocks .or. size(m%gmvs, 1) /= pitch .or. size(m%gmvs, 3) /= blocks) return
      if (size(m%gmvt1, 1) /= pitch .or. size(m%gmvt1, 2) /= levels .or. size(m%gmvt1, 4) /= blocks) return
      if (size(m%gmvt1s, 1) /= pitch .or. size(m%gmvt1s, 3) /= blocks) return
      if (size(fields%gfl, 1) /= pitch .or. size(fields%gfl, 2) /= levels .or. size(fields%gfl, 4) /= blocks) return
      if (size(next%gflt1, 1) /= pitch .or. size(next%gflt1, 2) /= levels .or. size(next%gflt1, 4) /= blocks) return
      if (.not. allocated(surface%sp_rr) .or. .not. allocated(surface%sp_sb) .or. .not. allocated(surface%sp_sg)) return
      if (.not. allocated(surface%sd_vf) .or. .not. allocated(surface%sd_vv)) return
      if (size(surface%sp_rr, 1) /= pitch .or. size(surface%sp_rr, 3) /= blocks) return
      if (size(surface%sp_sb, 1) /= pitch .or. size(surface%sp_sb, 4) /= blocks) return
      if (size(surface%sp_sg, 1) /= pitch .or. size(surface%sp_sg, 4) /= blocks) return
      if (size(surface%sd_vf, 1) /= pitch .or. size(surface%sd_vf, 3) /= blocks) return
      if (size(surface%sd_vv, 1) /= pitch .or. size(surface%sd_vv, 3) /= blocks) return
      first = 1_int64 + int(block - 1, int64)*pitch
      active = int(min(int(pitch, int64), int(points, int64) - first + 1_int64), int32)
      if (active < 1) return
      pending = output
      pending%owner => state
      pending%column = state%gp_work%columns(block)
      pending%column%motion => m%gmv(:, :, :, block)
      pending%column%surface(1:pitch, 1:1, 1:size(m%gmvs, 2)) => m%gmvs(:, :, block)
      pending%column%tracers => fields%gfl(:, :, :, block)
      pending%column%work%tracers => next%gflt1(:, :, :, block)
      pending%surface_rr => surface%sp_rr(:, :, block)
      pending%surface_sb => surface%sp_sb(:, :, :, block)
      pending%surface_sg => surface%sp_sg(:, :, :, block)
      pending%surface_vf => surface%sd_vf(:, :, block)
      pending%surface_vv => surface%sd_vv(:, :, block)
      pending%pitch = pitch; pending%levels = levels; pending%block = block; pending%last = active
      output = pending
    end associate
    status = 0
  end function

  !> Update existing coefficients, then reconstruct the same actual grid fields.
  !! MODES retains the historical eight integer words. The qualified mode has
  !! only word4 true. A mode refusal follows the source coefficient writes.
  !! Natural child flags and errno are not reset or replaced.
  integer(int32) function transform_initialized_grid_point_model(state, modes) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer(int32), intent(in) :: modes(8)
    type(model_inverse_modes) :: native_modes
    status = 2
    if (.not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial) .or. .not. allocated(state%startup%loaded%storage)) return
    associate (clock => state%startup%initial%controls%clock, model => state%startup%loaded%storage%model)
      status = update_operational_time_coefficients(clock%integration%second_dt, state%startup%initial%constants%ra, &
                       clock%integration%work(1), clock%integration%work(2), clock%integration%work(3), clock%integration%work(4), &
                                                    clock%integration%work(5), model%physics_auxiliary%tsphy)
    end associate
    if (status /= 0) return
    status = 2
    if (any(modes /= [0_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32, 0_int32])) return
    native_modes%wind_derivatives = .false.; native_modes%derivatives = .true.
    native_modes%grid_vorticity = .false.; native_modes%friction = .false.
    call operational_inverse_model_transform(state%transform, state%transform_fields, native_modes, status)
  end function
end module forecast_loaded_grid_point_prefix
