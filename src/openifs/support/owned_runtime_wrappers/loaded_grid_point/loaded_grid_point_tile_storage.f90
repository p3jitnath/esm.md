!> Own one source CPG tile and stop before clear, physics and transport.
module forecast_loaded_grid_point_tile_storage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_loaded_grid_point_prefix, only: native_loaded_grid_point_binding, bind_loaded_grid_point_tile
  use forecast_grid_point_update_strided, only: grid_point_update_controls
  use forecast_grid_calculations, only: compute_forecast_grid_calculations
  use forecast_cpg_private_workspace,only:native_cpg_private_workspace,allocate_cpg_private_workspace,release_cpg_private_workspace
  use forecast_hydrostatic_grid_calculations, only: native_hydrostatic_pressure_terms, &
                                                    allocate_hydrostatic_pressure_terms, release_hydrostatic_pressure_terms
  implicit none
  private
  public :: native_loaded_grid_point_tile, create_loaded_grid_point_tile
  public :: run_loaded_grid_point_tile, release_loaded_grid_point_tile
  !> One native temporary owner with readonly links to the actual execution.
  !! Five arrays retain the GP_MODEL source groups for this single block.
  !! Private work and pressure terms retain their existing source definitions.
  !! Source arrays use full pitch P, layers1:L and boundary layers0:L.
  !! No initial field, model, registry, GPwork or clock is copied or allocated.
  type :: native_loaded_grid_point_tile
    type(native_loaded_grid_point_binding) :: binding
    type(native_cpg_private_workspace) :: private_work
    type(native_hydrostatic_pressure_terms) :: terms
    real(real64), allocatable :: zgeo0(:, :), zrcp0(:, :, :), zpre0f(:, :), zcty0(:, :, :), zwrl9(:, :)
    logical :: ready = .false.
  end type
  interface
    function tile_errno_location() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Acquire source temporary arrays, bind global sections, then publish once.
  !! OUTPUT is absent on entry and after failure. Status0 succeeds,1 reports
  !! allocation failure and2 refuses a bound or late source binding.
  !! Creation preserves the caller's IEEE status and public errno.
  integer(int32) function create_loaded_grid_point_tile(state, block, output) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer(int32), intent(in) :: block
    type(native_loaded_grid_point_tile), allocatable, target, intent(inout) :: output
    type(native_loaded_grid_point_tile), allocatable, target :: pending
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved
    integer :: code, p, l, f
    integer(int32) :: child
    status = 2
    if (allocated(output)) return
    if (.not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial) .or. .not. allocated(state%startup%initial%geometry)) return
    p = state%startup%initial%geometry%dimensions%nproma
    l = state%startup%initial%geometry%dimensions%nflevg
    if (p < 1 .or. p > 256 .or. l < 4 .or. l > 256) return
    f = state%grid%blocks%controls%column%first_fields
    if (f < 1 .or. f > 65536) return
    call ieee_get_status(incoming)
    call c_f_pointer(tile_errno_location(), ep); saved = ep
    allocate (pending, stat=code)
    if (code /= 0) then
      status = 1; goto900
    end if
    ! These are the five exact GP_MODEL automatic source groups for one block.
    allocate (pending%zgeo0(p, l), stat=code)
    if (code /= 0) goto800
    allocate (pending%zrcp0(p, l, 3), stat=code)
    if (code /= 0) goto800
    allocate (pending%zpre0f(p, l), stat=code)
    if (code /= 0) goto800
    allocate (pending%zcty0(p, 0:l, 5), stat=code)
    if (code /= 0) goto800
    allocate (pending%zwrl9(p, l), stat=code)
    if (code /= 0) goto800
    call allocate_cpg_private_workspace(pending%private_work, int(p, int32), int(l, int32), int(f, int32), child)
    if (child /= 0) then
      status = child; goto850
    end if
    call allocate_hydrostatic_pressure_terms(pending%terms, int(p, int32), int(l, int32), child)
    if (child /= 0) then
      status = child; goto850
    end if
    call initialize_private_preimages(pending)
    status = bind_loaded_grid_point_tile(state, block, pending%binding)
    if (status /= 0) goto850
    associate (v => pending%binding%column, w => pending%private_work)
      v%hydro%full_geopotential => pending%zgeo0
      v%hydro%heat_capacity => pending%zrcp0(:, :, 1)
      v%hydro%gas_constant => pending%zrcp0(:, :, 2)
      v%hydro%kappa => pending%zrcp0(:, :, 3)
      v%hydro%full_pressure => pending%zpre0f
      v%hydro%continuity(1:p, 0:l, 1:5) => pending%zcty0
      v%wind%history => pending%zwrl9
      v%terrain_x => w%zorogl; v%terrain_y => w%zorogm
      v%pressure_x => w%zpre0l; v%pressure_y => w%zpre0m
      v%first_buffer => w%zslbuf1au; v%auxiliary => w%zgpar
      v%work%water(1)%values => w%zqli; v%work%water(2)%values => w%zqice
      v%work%water(3)%values => w%zqrain; v%work%water(4)%values => w%zqsnow
      v%hydro%half_pressure(1:p, 0:l) => w%zpre0
      v%hydro%pressure_weights => w%zxyb0; v%hydro%kinetic_energy => w%zkene0
      v%hydro%wind_u => w%zatnd(:, :, 1); v%hydro%wind_v => w%zatnd(:, :, 2)
      v%hydro%wind_u_no_coriolis => w%zatnd(:, :, 3)
      v%hydro%wind_v_no_coriolis => w%zatnd(:, :, 4)
      v%hydro%temperature_rate => w%zatnd(:, :, 5)
    end associate
    pending%ready = .true.
    call move_alloc(pending, output)
    status = 0; goto900
800 status = 1
850 if (allocated(pending)) call release_private_tile(pending)
900 call ieee_set_status(incoming)
    ep = saved
  end function

  !> Run the complete existing grid calculation on the borrowed live tile.
  !! This entry writes the private result owners and source filter/history/work
  !! destinations. It stops before packed-buffer clearing and later parents.
  !! A late child refusal retains reached writes and its natural status.
  integer(int32) function run_loaded_grid_point_tile(tile) result(status)
    type(native_loaded_grid_point_tile), allocatable, target, intent(inout) :: tile
    type(native_loaded_grid_point_binding) :: current
    type(grid_point_update_controls) :: controls
    integer :: p, l, last
    status = 2
    if (.not. allocated(tile)) return
    if (.not. tile%ready .or. .not. associated(tile%binding%owner)) return
    status = bind_loaded_grid_point_tile(tile%binding%owner, tile%binding%block, current)
    if (status /= 0) return
    status = 2
   if (current%pitch /= tile%binding%pitch .or. current%levels /= tile%binding%levels .or. current%last /= tile%binding%last) return
    if (.not. associated(current%column%motion, tile%binding%column%motion)) return
    if (.not. associated(current%column%surface, tile%binding%column%surface)) return
    if (.not. associated(current%column%tracers, tile%binding%column%tracers)) return
    if (.not. associated(current%column%work%u%values, tile%binding%column%work%u%values)) return
    if (.not. associated(current%column%work%v%values, tile%binding%column%work%v%values)) return
    if (.not. associated(current%column%work%temperature%values, tile%binding%column%work%temperature%values)) return
    if (.not. associated(current%column%work%surface_pressure%values, tile%binding%column%work%surface_pressure%values)) return
    if (.not. associated(current%column%work%tracers, tile%binding%column%work%tracers)) return
    if (.not. associated(current%surface_rr, tile%binding%surface_rr)) return
    if (.not. associated(current%surface_sb, tile%binding%surface_sb)) return
    if (.not. associated(current%surface_sg, tile%binding%surface_sg)) return
    if (.not. associated(current%surface_vf, tile%binding%surface_vf)) return
    if (.not. associated(current%surface_vv, tile%binding%surface_vv)) return
    p = tile%binding%pitch; l = tile%binding%levels; last = tile%binding%last
    associate (grid => tile%binding%owner%grid, v => tile%binding%column)
      if (.not. associated(grid%blocks%constants) .or. .not. associated(grid%blocks%tables)) return
      if (.not. associated(grid%blocks%thermal_components) .or. .not. associated(grid%blocks%work_components)) return
      if (.not. associated(grid%blocks%tracer_pairs)) return
      controls = grid%blocks%controls%column
      controls%first_step = grid%blocks%controls%step <= 0
      controls%grid%first_step = controls%first_step
      controls%grid%update_factor = 1.0_real64
      v%auxiliary = 0.0_real64
      call compute_forecast_grid_calculations(controls%grid, grid%blocks%surface_map, grid%blocks%motion_map, &
                         int(p, int32), 1_int32, int(last, int32), int(l, int32), grid%blocks%tracer_pairs, grid%blocks%constants, &
                            grid%blocks%thermal_components, grid%blocks%work_components, grid%blocks%tables, grid%blocks%vertical, &
                            v%motion, v%surface, v%tracers, v%terrain, v%raw_terrain_x, v%raw_terrain_y, v%map_metric, v%coriolis, &
                              v%terrain_x, v%terrain_y, v%pressure_x, v%pressure_y, tile%terms, v%hydro, v%previous, v%work, status)
    end associate
  end function

  !> Release temporary arrays only; an absent tile already satisfies release.
  !! All borrowed source owners stay live and unchanged. Preserve IEEE/errno.
  integer(int32) function release_loaded_grid_point_tile(tile) result(status)
    type(native_loaded_grid_point_tile), allocatable, target, intent(inout) :: tile
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved
    status = 0
    if (.not. allocated(tile)) return
    status = 2
    if (.not. tile%ready) return
    call ieee_get_status(incoming)
    call c_f_pointer(tile_errno_location(), ep); saved = ep
    call release_private_tile(tile)
    call ieee_set_status(incoming); ep = saved
    status = 0
  end function

  !> Retain historical source-unwritten private bytes without arithmetic.
  subroutine initialize_private_preimages(tile)
    type(native_loaded_grid_point_tile), intent(inout) :: tile
    real(real64), parameter :: fill = transfer(int(z'5757575757575757', int64), 0.0_real64)
    tile%zgeo0 = fill; tile%zrcp0 = fill; tile%zpre0f = fill; tile%zcty0 = fill; tile%zwrl9 = fill
    associate (w => tile%private_work, t => tile%terms)
      w%zorogl = fill; w%zorogm = fill; w%zpre0 = fill; w%zpre0l = fill; w%zpre0m = fill
      w%zxyb0 = fill; w%zkene0 = fill; w%zatnd = fill
      w%zqli = fill; w%zqice = fill; w%zqrain = fill; w%zqsnow = fill
      w%zgpar = fill; w%zslbuf1au = fill
      t%rt0l = fill; t%rt0m = fill; t%phi0fl = fill; t%phi0fm = fill; t%phi0h = fill
    end associate
  end subroutine

  !> Roll back acquired native arrays in source group order.
  subroutine release_private_tile(tile)
    type(native_loaded_grid_point_tile), allocatable, intent(inout) :: tile
    if (.not. allocated(tile)) return
    call release_hydrostatic_pressure_terms(tile%terms)
    call release_cpg_private_workspace(tile%private_work)
    if (allocated(tile%zgeo0)) deallocate (tile%zgeo0)
    if (allocated(tile%zrcp0)) deallocate (tile%zrcp0)
    if (allocated(tile%zpre0f)) deallocate (tile%zpre0f)
    if (allocated(tile%zcty0)) deallocate (tile%zcty0)
    if (allocated(tile%zwrl9)) deallocate (tile%zwrl9)
    nullify (tile%binding%owner)
    tile%ready = .false.
    deallocate (tile)
  end subroutine
end module forecast_loaded_grid_point_tile_storage
