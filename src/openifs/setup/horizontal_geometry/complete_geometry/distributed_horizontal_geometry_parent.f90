!> Complete the source distributed horizontal child through native geometry owners.
module forecast_distributed_horizontal_geometry
  use iso_c_binding, only: c_int
  use forecast_geometry_state_types, only: native_geometry_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  use forecast_geometry_horizontal_stages, only: initialize_geometry_horizontal_stages, &
                                                 release_distributed_horizontal_geometry => release_geometry_horizontal_owners
  implicit none
  private
  public :: initialize_distributed_horizontal_geometry, release_distributed_horizontal_geometry
contains
  !> Admit fresh produced owners while preserving the preceding local row maps.
  !! NLOEN/NMEN are valid existing predecessors. All newly produced arrays,
  !! including RLATI and the outer terrain owner, must be unallocated.
  logical function horizontal_outputs_fresh(state) result(fresh)
    type(native_geometry_state), intent(in) :: state
    fresh = .false.
    if (allocated(state%latitudes%rw)) return
    if (allocated(state%latitudes%rmu)) return
    if (allocated(state%latitudes%r1mu2)) return
    if (allocated(state%latitudes%r1mui)) return
    if (allocated(state%latitudes%r1mua)) return
    if (allocated(state%latitudes%rsqm2)) return
    if (allocated(state%latitudes%r1qm2)) return
    if (allocated(state%latitudes%racthe)) return
    if (allocated(state%latitudes%rlatig)) return
    if (allocated(state%latitudes%rlati)) return
    if (allocated(state%laplacian%nasn0)) return
    if (allocated(state%laplacian%nasm0)) return
    if (allocated(state%laplacian%nasm0g)) return
    if (allocated(state%laplacian%nvalue)) return
    if (allocated(state%laplacian%myms)) return
    if (allocated(state%laplacian%nspzero)) return
    if (allocated(state%laplacian%nse0l)) return
    if (allocated(state%laplacian%rlapdi)) return
    if (allocated(state%laplacian%rlapin)) return
    if (allocated(state%grid%nstagp)) return
    if (allocated(state%spectral_maps%gmr)) return
    if (allocated(state%spectral_maps%scgmap)) return
    if (allocated(state%spherical%spherical%rcori)) return
    if (allocated(state%spherical%spherical%rcoric)) return
    if (allocated(state%spherical%spherical%gemu)) return
    if (allocated(state%spherical%spherical%gsqm2)) return
    if (allocated(state%spherical%spherical%gelam)) return
    if (allocated(state%spherical%spherical%gelat)) return
    if (allocated(state%spherical%spherical%geclo)) return
    if (allocated(state%spherical%spherical%geslo)) return
    if (allocated(state%spherical%spherical%gexco)) return
    if (allocated(state%spherical%spherical%geyco)) return
    if (allocated(state%spherical%spherical%gezco)) return
    if (allocated(state%spherical%spherical%gm)) return
    if (allocated(state%spherical%spherical%gmappa)) return
    if (allocated(state%spherical%spherical%gomvrl)) return
    if (allocated(state%spherical%spherical%gomvrm)) return
    if (allocated(state%spherical%spherical%gnordl)) return
    if (allocated(state%spherical%spherical%gnordm)) return
    if (allocated(state%spherical%spherical%gnordlcl)) return
    if (allocated(state%spherical%spherical%gnordmcl)) return
    if (allocated(state%spherical%spherical%gnordmcm)) return
    if (allocated(state%spherical%spherical%gaw)) return
    if (allocated(state%spherical%spherical%ngplat)) return
    if (allocated(state%spherical%spherical%nuniquegp)) return
    if (allocated(state%spherical%computational%rcolon)) return
    if (allocated(state%spherical%computational%rsilon)) return
    if (allocated(state%spherical%computational%rindx)) return
    if (allocated(state%spherical%computational%rindy)) return
    if (allocated(state%spherical%computational%ratath)) return
    if (allocated(state%spherical%computational%ratatx)) return
    if (allocated(state%spherical%blocked%rcori)) return
    if (allocated(state%spherical%blocked%rcoric)) return
    if (allocated(state%spherical%blocked%gemu)) return
    if (allocated(state%spherical%blocked%gsqm2)) return
    if (allocated(state%spherical%blocked%gelam)) return
    if (allocated(state%spherical%blocked%gelat)) return
    if (allocated(state%spherical%blocked%geclo)) return
    if (allocated(state%spherical%blocked%geslo)) return
    if (allocated(state%spherical%blocked%gexco)) return
    if (allocated(state%spherical%blocked%geyco)) return
    if (allocated(state%spherical%blocked%gezco)) return
    if (allocated(state%spherical%blocked%gm)) return
    if (allocated(state%spherical%blocked%gmappa)) return
    if (allocated(state%spherical%blocked%gomvrl)) return
    if (allocated(state%spherical%blocked%gomvrm)) return
    if (allocated(state%spherical%blocked%gnordl)) return
    if (allocated(state%spherical%blocked%gnordm)) return
    if (allocated(state%spherical%blocked%gnordlcl)) return
    if (allocated(state%spherical%blocked%gnordmcl)) return
    if (allocated(state%spherical%blocked%gnordmcm)) return
    if (allocated(state%spherical%blocked%gaw)) return
    if (allocated(state%spherical%blocked%ngplat)) return
    if (allocated(state%spherical%blocked%nuniquegp)) return
    if (allocated(state%spherical%blocked%spherical_views)) return
    if (allocated(state%spherical%blocked%computational_views)) return
    if (allocated(state%terrain%blocks)) return
    fresh = .true.
  end function

  !> Preserve the standalone source order without inserting atmosphere or copies.
  !! Original entry md2asm_initialize_distributed_horizontal_geometry belongs to
  !! src/openifs/setup/owned_distributed_horizontal_geometry.S. The native caller
  !! supplies a complete canonical phase7 partition and live public context.
  !! The physical, wave and global row ranges stay distinct in that producer.
  !! State is TARGET and remains stable while native blocked views are used.
  !! World4 retains the old source domain; world32 uses the explicit new live
  !! count providers and needs separate current-reference byte qualification.
  !! The vertical pointer, atmosphere and stream values are unused and unchanged.
  !! Refusal before child acquisition preserves every incoming owner. A later
  !! failure releases only this horizontal family in the exact source order.
  integer(c_int) function initialize_distributed_horizontal_geometry(state, constants, &
                                                                     child_status, failed_stage) result(status)
    type(native_geometry_state), target, intent(inout) :: state
    type(forecast_physical_constants), intent(in) :: constants
    integer(c_int), intent(out) :: child_status
    integer(c_int), optional, intent(out) :: failed_stage
    integer(c_int) :: local_status, stage
    child_status = 2
    status = 2
    if (present(failed_stage)) failed_stage = 1
    if (.not. state%transform_control%message_ready) return
    local_status = 2
    if (state%partition%phase == 7 .and. .not. state%initialized) then
      if (state%transform_control%nproc == 4 .or. state%transform_control%nproc == 32) then
        if (state%dimensions%nsmax == 1279 .and. state%dimensions%ndglg == 2560) then
          if (horizontal_outputs_fresh(state)) local_status = 0
        end if
      end if
    end if
    child_status = agree_distributed_partition_status(state%transform_control, local_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    status = initialize_geometry_horizontal_stages(state, constants, .false., child_status, stage, &
                                                   include_stream_and_atmosphere=.false.)
    if (present(failed_stage)) failed_stage = stage
    if (status /= 0) call release_distributed_horizontal_geometry(state)
  end function
end module forecast_distributed_horizontal_geometry
