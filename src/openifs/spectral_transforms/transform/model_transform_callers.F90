!> Model-owned spectral/grid transform preparation with explicit native field views.
module md2asm_model_transform_callers
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_model_transform_views, only: transform_call_controls, transform_field_views
  use md2asm_transform_controllers, only: submit_inverse_transform_request, submit_direct_transform_request
  use md2asm_transform_types, only: transform_environment_ready
  implicit none
  private
  public :: model_transform_context, model_transform_state, model_inverse_modes, native_transform_profile
  public :: transform_inverse_model, transform_direct_model, transform_inverse_high_level, transform_direct_high_level
  public :: model_transform_context_ready
  type :: model_transform_context
    type(transform_call_controls) :: transform
    integer(int32) :: global_levels = 0, local_points = 0, pressure_partition = 0, vertical_partition = 0, step = 0
    integer(int32) :: current_wind_fields = 0, current_volume_fields = 0, current_surface_fields = 0
    integer(int32) :: previous_volume_fields = 0, previous_surface_fields = 0, current_u = 0, current_v = 0
    integer(int32) :: gradient_fields(4) = 0, spectral_tracers = 0
    logical :: pressure_gradients = .false., gradient_volume_fields = .false., nonhydrostatic = .false.
    logical :: semiimplicit_diagnostics = .false., hydrostatic_diagnostics = .false.
    integer(int64) :: workspace_budget = huge(0_int64)
    integer(int32), pointer :: level_partition(:) => null()
  end type
  type :: model_transform_state
    real(real64), pointer :: vorticity(:, :) => null(), divergence(:, :) => null(), log_pressure(:) => null()
    real(real64), pointer :: thermodynamic(:, :, :) => null()
    real(real64), pointer :: current_grid(:, :, :, :) => null(), current_surface(:, :, :) => null()
    real(real64), pointer :: previous_grid(:, :, :, :) => null(), previous_surface(:, :, :) => null()
    real(real64), pointer :: gradient_vorticity(:, :) => null(), gradient_divergence(:, :) => null()
  end type
  type :: model_inverse_modes
    logical :: wind_derivatives = .false., derivatives = .false., grid_vorticity = .false., friction = .false.
  end type
  abstract interface
    subroutine native_transform_profile(name, phase, handle)
      import :: int32, real64
      character(len=*), intent(in) :: name
      integer(int32), intent(in) :: phase
      real(real64), intent(inout) :: handle
    end subroutine
  end interface
  interface
    subroutine gstats(event, phase)
      import :: int32
      integer(int32), intent(in) :: event, phase
    end subroutine
  end interface
contains
!> Validate metadata and owned spans common to both model transform directions.
  logical function model_transform_context_ready(c, s, inverse)
    type(model_transform_context), intent(in) :: c
    type(model_transform_state), intent(in) :: s
    logical, intent(in) :: inverse
    integer :: pitch, blocks, coefficients, local_levels
    integer(int64) :: needed_blocks
    model_transform_context_ready = .false.
    if (c%nonhydrostatic .or. c%semiimplicit_diagnostics .or. c%hydrostatic_diagnostics) return
    if (c%spectral_tracers /= 0 .or. c%transform%split_fields > 0 .or. c%workspace_budget < 0_int64) return
    if (c%global_levels < 1 .or. c%global_levels > 512 .or. c%local_points < 1) return
    if (c%transform%resolution < 1 .or. c%transform%processes < 1) return
    if (c%transform%block_rows < 1 .or. c%transform%block_rows > 65536) return
    if (c%pressure_partition < 1 .or. c%vertical_partition < 1) return
    if (.not. associated(c%level_partition)) return
    if (size(c%level_partition) /= c%global_levels) return
    if (.not. associated(s%vorticity) .or. .not. associated(s%divergence) .or. .not. associated(s%log_pressure)) return
    if (.not. associated(s%thermodynamic)) return
    local_levels = size(s%vorticity, 1); coefficients = size(s%vorticity, 2)
    if (local_levels < 0 .or. local_levels > c%global_levels .or. coefficients < 0) return
    if (size(s%divergence, 1) /= local_levels .or. size(s%divergence, 2) /= coefficients) return
    if (size(s%thermodynamic, 1) /= local_levels .or. size(s%thermodynamic, 2) /= coefficients) return
    if (size(s%thermodynamic, 3) /= 1 .or. size(s%log_pressure) /= coefficients) return
    pitch = c%transform%block_rows
    needed_blocks = (int(c%local_points, int64) + pitch - 1_int64)/pitch
    if (needed_blocks > huge(1_int32)) return
    blocks = int(needed_blocks)
    if (inverse) then
      if (.not. associated(s%current_grid) .or. .not. associated(s%current_surface)) return
      if (size(s%current_grid, 1) /= pitch .or. size(s%current_grid, 2) /= c%global_levels) return
      if (size(s%current_grid, 4) /= blocks) return
      if (size(s%current_surface, 1) /= pitch .or. size(s%current_surface, 3) /= blocks) return
      if (c%current_wind_fields < 2 .or. c%current_wind_fields > size(s%current_grid, 3)) return
      if (c%current_volume_fields < c%current_wind_fields .or. c%current_volume_fields > size(s%current_grid, 3)) return
      if (c%current_surface_fields < 1 .or. c%current_surface_fields > size(s%current_surface, 2)) return
      if (c%current_u < 1 .or. c%current_v < c%current_u .or. c%current_v > c%current_wind_fields) return
    else
      if (.not. associated(s%previous_grid) .or. .not. associated(s%previous_surface)) return
      if (size(s%previous_grid, 1) /= pitch .or. size(s%previous_grid, 2) /= c%global_levels) return
      if (size(s%previous_grid, 4) /= blocks) return
      if (size(s%previous_surface, 1) /= pitch .or. size(s%previous_surface, 3) /= blocks) return
      if (c%previous_volume_fields < 2 .or. c%previous_volume_fields > size(s%previous_grid, 3)) return
      if (c%previous_surface_fields < 1 .or. c%previous_surface_fields > size(s%previous_surface, 2)) return
    end if
    if (c%pressure_gradients) then
      if (.not. associated(s%gradient_vorticity) .or. .not. associated(s%gradient_divergence)) return
      if (size(s%gradient_vorticity, 1) /= local_levels .or. size(s%gradient_divergence, 1) /= local_levels) return
      if (size(s%gradient_vorticity, 2) /= coefficients .or. size(s%gradient_divergence, 2) /= coefficients) return
      if (.not. associated(s%current_grid)) return
 if (size(s%current_grid, 1) /= pitch .or. size(s%current_grid, 2) /= c%global_levels .or. size(s%current_grid, 4) /= blocks) return
      if (minval(c%gradient_fields) < 1 .or. maxval(c%gradient_fields) > size(s%current_grid, 3)) return
    end if
    model_transform_context_ready = transform_environment_ready()
  end function
!> Copy pressure, prepare requested gradients, and reconstruct the complete current state.
!! Grid owners are (block-row,global-level,field,block); spectral owners are
!! (local-level,coefficient), with a final scalar plane for thermodynamic fields.
!! This selected body keeps the hydrostatic, no-spectral-tracer source route.
  subroutine transform_inverse_model(c, s, modes, status, profile, model_events)
    type(model_transform_context), intent(in) :: c
    type(model_transform_state), intent(inout) :: s
    type(model_inverse_modes), intent(in) :: modes
    integer(int32), intent(out) :: status
    procedure(native_transform_profile), optional :: profile
    logical, intent(in), optional :: model_events
    logical :: events
    type(transform_field_views) :: v
    type(transform_call_controls) :: call_controls
    real(real64), allocatable, target :: pressure(:, :), gradient(:, :, :, :)
    integer(int32), target :: pressure_set(1)
    integer :: ncoeff, alloc_status, wind_first, wind_last, volume_first, volume_last, surface_last
    integer :: block, active, row, level, field, pitch, blocks
    integer(int64) :: gradient_words
    real(real64) :: handle
    events = .true.
    if (present(model_events)) events = model_events
    status = 2
    if (.not. model_transform_context_ready(c, s, .true.) .or. modes%friction) return
    if (size(s%vorticity, 2, kind=int64) > c%workspace_budget/8_int64) return
    ncoeff = size(s%vorticity, 2); pitch = c%transform%block_rows; blocks = size(s%current_grid, 4)
    volume_first = c%current_wind_fields + 1; volume_last = c%current_volume_fields
    if (c%gradient_volume_fields) volume_last = volume_last - 2
    if (volume_last < volume_first - 1) return
    if (volume_last >= volume_first) then
      if (modes%derivatives) then
        if (volume_last - volume_first + 1 /= 3*size(s%thermodynamic, 3)) return
      else
        if ((volume_last - volume_first + 1)/3 /= size(s%thermodynamic, 3)) return
      end if
    end if
    if (c%pressure_gradients .and. c%step > 0) then
      gradient_words = int(pitch, int64)*c%global_levels*2_int64*blocks
      if (gradient_words > c%workspace_budget/8_int64 - size(s%vorticity, 2, kind=int64)) return
    end if
    if (present(profile)) call profile('TRANSINV_MDL', 0_int32, handle)
    allocate (pressure(1, ncoeff), stat=alloc_status)
    if (alloc_status /= 0) then
      status = 1
      if (present(profile)) call profile('TRANSINV_MDL', 1_int32, handle)
      return
    end if
    pressure = 0.0_real64
    pressure_set(1) = c%pressure_partition
    if (events) call gstats(1894_int32, 0_int32)
    if (c%pressure_partition == c%vertical_partition) pressure(1, :) = s%log_pressure
    if (events) call gstats(1894_int32, 1_int32)
    if (c%pressure_gradients) then
      if (c%step > 0) then
        allocate (gradient(pitch, c%global_levels, 2, blocks), stat=alloc_status)
        if (alloc_status /= 0) then
          status = 1
          if (present(profile)) call profile('TRANSINV_MDL', 1_int32, handle)
          return
        end if
        v%vorticity => s%gradient_vorticity; v%divergence => s%gradient_divergence
        v%set_wind => c%level_partition; v%grid_wind => gradient
        call_controls = c%transform
        call_controls%scalar_derivatives = .false.; call_controls%grid_vorticity = .false.
        call_controls%grid_divergence = .false.; call_controls%wind_derivatives = .false.
        call submit_inverse_transform_request(call_controls, v, status)
        if (status /= 0) then
          if (present(profile)) call profile('TRANSINV_MDL', 1_int32, handle)
          return
        end if
        do block = 1, blocks
          active = min(pitch, c%local_points - (block - 1)*pitch)
          do level = 1, c%global_levels
            do row = 1, active
              s%current_grid(row, level, c%gradient_fields(3), block) = gradient(row, level, 1, block)
              s%current_grid(row, level, c%gradient_fields(4), block) = gradient(row, level, 2, block)
            end do
          end do
        end do
        deallocate (gradient)
      else
        do block = 1, blocks
          active = min(pitch, c%local_points - (block - 1)*pitch)
          do level = 1, c%global_levels
            do row = 1, active
              do field = 1, 4
                s%current_grid(row, level, c%gradient_fields(field), block) = 0.0_real64
              end do
            end do
          end do
        end do
      end if
    end if
    v = transform_field_views()
    v%vorticity => s%vorticity; v%divergence => s%divergence
    v%scalar2 => pressure; v%set_scalar2 => pressure_set; v%set_wind => c%level_partition
    wind_first = 2; if (modes%grid_vorticity) wind_first = 1
    wind_last = c%current_wind_fields; surface_last = c%current_surface_fields
    if (.not. modes%derivatives) then
      volume_last = max(volume_first, volume_first - 1 + (volume_last - volume_first + 1)/3)
      surface_last = max(1, surface_last/3)
      wind_first = c%current_u; wind_last = c%current_v
    end if
    if (wind_first > wind_last .or. volume_last > size(s%current_grid, 3)) then
      status = 2
      if (present(profile)) call profile('TRANSINV_MDL', 1_int32, handle)
      return
    end if
    v%grid_wind => s%current_grid(:, :, wind_first:wind_last, :)
    v%grid2 => s%current_surface(:, 1:surface_last, :)
    if (volume_first <= volume_last) then
      v%scalar3a => s%thermodynamic
      v%set_scalar3a => c%level_partition
      v%grid3a => s%current_grid(:, :, volume_first:volume_last, :)
    end if
    call_controls = c%transform
    call_controls%scalar_derivatives = modes%derivatives
    call_controls%grid_vorticity = modes%grid_vorticity
    call_controls%grid_divergence = modes%derivatives
    call_controls%wind_derivatives = modes%wind_derivatives .and. modes%derivatives
    call submit_inverse_transform_request(call_controls, v, status)
    if (present(profile)) call profile('TRANSINV_MDL', 1_int32, handle)
  end subroutine
!> Analyse current gradient planes before previous-time winds,temperature and pressure.
!! This body accepts the source A configuration. Only the owning pressure group
!! publishes log-pressure coefficients after the public transform completes.
  subroutine transform_direct_model(c, s, configuration, status, profile, model_events)
    type(model_transform_context), intent(in) :: c
    type(model_transform_state), intent(inout) :: s
    character(len=1), intent(in) :: configuration
    integer(int32), intent(out) :: status
    procedure(native_transform_profile), optional :: profile
    logical, intent(in), optional :: model_events
    logical :: events
    type(transform_field_views) :: v
    real(real64), allocatable, target :: pressure(:, :)
    integer(int32), target :: pressure_set(1)
    integer :: alloc_status, pressure_rows, ncoeff
    real(real64) :: handle
    events = .true.
    if (present(model_events)) events = model_events
    status = 2
    if (configuration /= 'A') return
    if (.not. model_transform_context_ready(c, s, .false.)) return
    if (c%previous_volume_fields > 2) then
      if (c%previous_volume_fields - 2 /= size(s%thermodynamic, 3)) return
    end if
    if (size(s%vorticity, 2, kind=int64) > c%workspace_budget/8_int64) return
    if (present(profile)) call profile('TRANSDIR_MDL', 0_int32, handle)
    ncoeff = size(s%vorticity, 2)
    allocate (pressure(1, ncoeff), stat=alloc_status)
    if (alloc_status /= 0) then
      status = 1
      if (present(profile)) call profile('TRANSDIR_MDL', 1_int32, handle)
      return
    end if
    pressure = 0.0_real64; pressure_set(1) = c%pressure_partition
    pressure_rows = merge(1, 0, c%pressure_partition == c%vertical_partition)
    if (c%pressure_gradients .and. c%previous_volume_fields > 2) then
      v%vorticity => s%gradient_vorticity; v%divergence => s%gradient_divergence
      v%set_wind => c%level_partition
      if (c%gradient_fields(4) /= c%gradient_fields(3) + 1) then
        status = 2
        if (present(profile)) call profile('TRANSDIR_MDL', 1_int32, handle)
        return
      end if
      v%grid_wind => s%current_grid(:, :, c%gradient_fields(3):c%gradient_fields(4), :)
      call submit_direct_transform_request(c%transform, v, status)
      if (status /= 0) then
        if (present(profile)) call profile('TRANSDIR_MDL', 1_int32, handle)
        return
      end if
    end if
    v = transform_field_views()
    v%vorticity => s%vorticity; v%divergence => s%divergence
    v%scalar2 => pressure(1:pressure_rows, :)
    v%set_wind => c%level_partition; v%set_scalar2 => pressure_set
    v%grid_wind => s%previous_grid(:, :, 1:2, :)
    v%grid2 => s%previous_surface(:, 1:c%previous_surface_fields, :)
    if (c%previous_volume_fields > 2) then
      v%scalar3a => s%thermodynamic; v%set_scalar3a => c%level_partition
      v%grid3a => s%previous_grid(:, :, 3:c%previous_volume_fields, :)
    end if
    call submit_direct_transform_request(c%transform, v, status)
    if (status == 0) then
      if (events) call gstats(1036_int32, 0_int32)
      if (pressure_rows == 1) s%log_pressure = pressure(1, :)
      if (events) call gstats(1036_int32, 1_int32)
    end if
    if (present(profile)) call profile('TRANSDIR_MDL', 1_int32, handle)
  end subroutine
!> Derive TRANSINVH flags from live model controls and forward the supported model route.
  subroutine transform_inverse_high_level(c, s, configuration, configuration_number, ecmwf, lagrangian, &
                     requested_derivatives, requested_vorticity, requested_wind_derivatives, rayleigh, status, post_output, profile)
    type(model_transform_context), intent(in) :: c
    type(model_transform_state), intent(inout) :: s
    character(len=9), intent(in) :: configuration
    integer(int32), intent(in) :: configuration_number
    logical, intent(in) :: ecmwf, lagrangian, requested_derivatives, requested_vorticity, requested_wind_derivatives, rayleigh
    integer(int32), intent(out) :: status
    logical, intent(in), optional :: post_output
    procedure(native_transform_profile), optional :: profile
    type(model_inverse_modes) :: modes
    real(real64) :: handle
    status = 2
    if (.not. any(configuration(2:3) == ['AA', 'M1', 'GB'])) return
    modes%derivatives = lle(configuration(2:2), 'F') .and. requested_derivatives
    modes%friction = modes%derivatives .and. rayleigh .and. lagrangian .and. &
                     (configuration_number == 1 .or. configuration_number == 302)
    modes%grid_vorticity = requested_vorticity .and. modes%derivatives
    modes%wind_derivatives = requested_wind_derivatives
    if (present(post_output)) then
      modes%grid_vorticity = post_output .or. modes%grid_vorticity
      modes%wind_derivatives = (post_output .and. .not. ecmwf) .or. modes%wind_derivatives
    end if
    if (present(profile)) call profile('TRANSINVH', 0_int32, handle)
    call transform_inverse_model(c, s, modes, status, profile)
    if (present(profile)) call profile('TRANSINVH', 1_int32, handle)
  end subroutine
!> Preserve the TRANSDIRH profile pair and complete native model call.
  subroutine transform_direct_high_level(c, s, configuration, status, profile)
    type(model_transform_context), intent(in) :: c
    type(model_transform_state), intent(inout) :: s
    character(len=1), intent(in) :: configuration
    integer(int32), intent(out) :: status
    procedure(native_transform_profile), optional :: profile
    real(real64) :: handle
    if (present(profile)) call profile('TRANSDIRH', 0_int32, handle)
    call transform_direct_model(c, s, configuration, status, profile)
    if (present(profile)) call profile('TRANSDIRH', 1_int32, handle)
  end subroutine
end module
