!> Preserve the interleaved native horizontal setup stages after live partitioning.
module forecast_geometry_horizontal_stages
  use iso_c_binding, only: c_int, c_double, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  use forecast_latitude_geometry, only: initialize_selected_latitude_geometry, &
                                        initialize_public_latitude_geometry, release_latitude_geometry
  use forecast_laplacian_geometry, only: initialize_serial_laplacian, &
                                         initialize_distributed_laplacian, release_laplacian_geometry
  use forecast_geometry_stream, only: copy_stream_half_level_values, copy_stream_latitude_values
  use forecast_standard_atmosphere, only: atmosphere_physical_inputs
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls
  use forecast_native_standard_atmosphere, only: initialize_standard_atmosphere_from_native_vertical
  use forecast_spherical_grid_setup, only: initialize_spherical_grid, release_spherical_grid
  use forecast_spectral_geometry_maps, only: initialize_spectral_geometry_maps, &
                                     initialize_operational_spectral_geometry_maps, initialize_distributed_spectral_geometry_maps, &
                                             release_spectral_geometry_maps
  use forecast_spherical_point_geometry, only: spherical_physical_values
  use forecast_spherical_geometry_setup, only: initialize_spherical_geometry, release_spherical_geometry
  use forecast_local_geometry_maps, only: initialize_local_geometry_maps
  use forecast_orography_storage, only: allocate_orography_storage, release_orography_storage
  implicit none
  private
  public :: initialize_geometry_horizontal_stages, release_geometry_horizontal_owners
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Apply the source's common MAX agreement only for a distributed context.
  integer(c_int) function agree_stage(state, local_status) result(status)
    type(native_geometry_state), intent(in) :: state
    integer(c_int), intent(in) :: local_status
    status = local_status
    if (state%transform_control%nproc > 1) &
      status = agree_distributed_partition_status(state%transform_control, local_status)
  end function

  !> Complete latitude, spectral, atmosphere, point, local-map and terrain setup.
  !! The preceding producer owns a live transform and complete native partition.
  !! The vertical pointer borrows the completed caller-owned vertical state.
  !! selected is true only for the qualified T21 regular route; the other route
  !! consumes the actual public Gaussian latitude arrays. Both use live counts.
  !! Source stages8:17 retain the original stream-half, atmosphere, local-grid
  !! and stream-latitude positions. The standalone horizontal parent passes
  !! include_stream_and_atmosphere=false to retain its own shorter source order.
  !! No caller or verification tool supplies a numerical stage.
  !! The caller keeps state TARGET and its borrowed vertical state alive.
  !! Status is the first agreed child failure. Failed stage and child_status
  !! identify that location; acquired owners remain for the enclosing cleanup.
  integer(c_int) function initialize_geometry_horizontal_stages(state, constants, selected, &
                                                           child_status, failed_stage, include_stream_and_atmosphere) result(status)
    type(native_geometry_state), target, intent(inout) :: state
    type(forecast_physical_constants), intent(in) :: constants
    logical, intent(in) :: selected
    integer(c_int), intent(out) :: child_status, failed_stage
    logical, optional, intent(in) :: include_stream_and_atmosphere
    type(atmosphere_physical_inputs) :: atmosphere
    type(hybrid_pressure_controls) :: pressure
    type(spherical_physical_values) :: spherical
    integer(c_int) :: first, last, offset, region, wave_first, child
    logical :: with_stream
    with_stream = .true.
    if (present(include_stream_and_atmosphere)) with_stream = include_stream_and_atmosphere
    child_status = 2
    failed_stage = 8
    status = 2
    if (with_stream) then
      if (.not. associated(state%vertical)) return
    end if
    if (state%partition%phase /= 7) return
    if (.not. allocated(state%configuration%nloen)) return
    if (.not. allocated(state%configuration%nloeng)) return
    if (.not. allocated(state%cutoffs%nmen)) return
    if (.not. allocated(state%cutoffs%nmeng)) return
    first = state%partition%ndgsal
    last = state%partition%ndgenl
    offset = state%partition%nptrfloff
    region = state%partition%my_region_ew
    wave_first = state%partition%nptrls(state%transform_control%mysetw)
    if (selected) then
      child = initialize_selected_latitude_geometry(state%latitudes, constants%ra)
    else
      child = initialize_public_latitude_geometry(state%latitudes, state%dimensions%ndglg, &
                                        state%dimensions%ndgsur, constants%ra, constants%rpi, state%transform_resolution%resolution)
    end if
    child_status = agree_stage(state, child)
    if (child_status /= 0) goto900
    failed_stage = 9
    if (state%transform_control%nproc == 1) then
      child = initialize_serial_laplacian(state%laplacian, state%dimensions, constants%ra)
    else
      child = initialize_distributed_laplacian(state%laplacian, state%dimensions, constants%ra, &
                                               state%transform_resolution, state%partition%nump, state%partition%numcp, &
                                              state%partition%nspec, state%partition%nspec2, state%transform_control%nproc, 0_c_int)
    end if
    child_status = agree_stage(state, child)
    if (child_status /= 0) goto900
    if (with_stream) then
      failed_stage = 10
      child = copy_stream_half_level_values(state%stream, state%vertical%vah, state%vertical%vbh)
      child_status = agree_stage(state, child)
      if (child_status /= 0) goto900
      failed_stage = 11
      atmosphere%gravity = constants%rg
      atmosphere%dry_gas_constant = constants%rd
      atmosphere%planet_scale = 1.0_c_double
      atmosphere%surface_pressure = state%vertical%vp00
      pressure%approximate_mode = state%vertical%configuration%ndlnpr
      pressure%finite_elements = state%vertical%configuration%lvertfe /= 0
      pressure%arithmetic_full_pressure = state%vertical%configuration%laprxpk /= 0
      pressure%top_pressure = state%vertical%toppres
      pressure%top_alpha = state%vertical%configuration%rhydr0
      pressure%dry_gas_constant = constants%rd
      pressure%dry_isochoric_heat_capacity = constants%rcvd
      call initialize_standard_atmosphere_from_native_vertical(state%atmosphere, atmosphere, pressure, &
                                state%vertical%vah, state%vertical%vbh, state%vertical%vc, state%vertical%vaf, state%vertical%vbf, &
                                                         state%vertical%vdela, state%vertical%vdelb, 1_c_int, 150.0_c_double, child)
      child_status = agree_stage(state, child)
      if (child_status /= 0) goto900
    end if
    failed_stage = 12
    child = initialize_spherical_grid(state%grid, state%dimensions%ndglg, state%dimensions%ndlon, &
                                      state%partition%ndgll, wave_first - 1, first, last, &
                                      state%partition%nonl(offset + first:offset + last, region), &
                                      state%configuration%nloeng(1:), state%cutoffs%nmeng(1:), &
                                      state%configuration%nloen(1:state%partition%ndgll), &
                                      state%cutoffs%nmen(1:state%partition%ndgll), state%configuration%values%rmucen, &
                                      state%configuration%values%rstret, constants%rpi, constants%ra)
    child_status = agree_stage(state, child)
    if (child_status /= 0) goto900
    if (with_stream) then
      failed_stage = 13
      child = copy_stream_latitude_values(state%stream, state%latitudes%rlatig(1:state%dimensions%ndglg))
      child_status = agree_stage(state, child)
      if (child_status /= 0) goto900
    end if
    failed_stage = 14
    if (state%transform_control%nproc > 1) then
      if (state%transform_control%nproc == 32) then
        child = initialize_distributed_spectral_geometry_maps(state%spectral_maps, state%dimensions, &
                            state%partition%nspec, state%laplacian%myms, state%laplacian%nse0l, state%configuration%values%rstret, &
                                                              active_column_count=state%partition%nump)
      else
        child = initialize_distributed_spectral_geometry_maps(state%spectral_maps, state%dimensions, &
                              state%partition%nspec, state%laplacian%myms, state%laplacian%nse0l, state%configuration%values%rstret)
      end if
    else if (selected) then
      child = initialize_spectral_geometry_maps(state%spectral_maps, state%dimensions, &
                                                state%laplacian%myms, state%laplacian%nse0l, state%configuration%values%rstret)
    else
      child = initialize_operational_spectral_geometry_maps(state%spectral_maps, state%dimensions, &
                                                     state%laplacian%myms, state%laplacian%nse0l, state%configuration%values%rstret)
    end if
    child_status = agree_stage(state, child)
    if (child_status /= 0) goto900
    failed_stage = 15
    spherical%stretch = state%configuration%values%rstret
    spherical%rc2p1 = state%grid%constants%rc2p1
    spherical%rc2m1 = state%grid%constants%rc2m1
    spherical%radius = constants%ra
    spherical%pi = constants%rpi
    spherical%angular_rotation = constants%romega
    child = initialize_spherical_geometry(state%spherical, spherical, state%partition%ngptot, &
                                          state%dimensions%nproma, state%dimensions%ndlon, state%dimensions%nsmax, &
                                         state%configuration%nloeng(1:state%dimensions%ndglg), state%partition%mylats(first:last), &
                                        state%grid%nstagp(first:last), state%partition%nsta(offset + first:offset + last, region), &
                                          state%partition%nonl(offset + first:offset + last, region), state%latitudes)
    child_status = agree_stage(state, child)
    if (child_status /= 0) goto900
    failed_stage = 16
    child = initialize_local_geometry_maps(state%configuration%nloen, state%cutoffs%nmen, state%latitudes%rlati, &
                                      state%latitude_first, state%latitude_last, state%dimensions%ndgsag, state%dimensions%ndgeng, &
                                           first, last, state%partition%ndgll, wave_first, state%partition%nfrstloff, &
                                           state%configuration%nloeng, state%cutoffs%nmeng, state%latitudes%rlatig)
    child_status = agree_stage(state, child)
    if (child_status /= 0) goto900
    failed_stage = 17
    child = allocate_orography_storage(state%terrain, state%dimensions%nproma, state%partition%ngptot, &
                                       state%configuration%values%lnonhyd_geom)
    child_status = agree_stage(state, child)
    if (child_status /= 0) goto900
    failed_stage = 0
    status = 0
    return
900 continue
    status = child_status
  end function

  !> Release the distributed horizontal owner's exact source groups.
  !! This frees the terrain first, then nine latitude and nine Laplacian owners,
  !! the local grid start, both spectral maps, spherical points and views, and
  !! RLATI/NLOEN/NMEN. Global maps, atmosphere, stream and public context remain
  !! owned by the enclosing parent. The caller's IEEE status and errno remain.
  subroutine release_geometry_horizontal_owners(state)
    type(native_geometry_state), intent(inout) :: state
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno, ignored
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    call release_orography_storage(state%terrain)
    call release_latitude_geometry(state%latitudes)
    ignored = release_laplacian_geometry(state%laplacian)
    call release_spherical_grid(state%grid)
    ignored = release_spectral_geometry_maps(state%spectral_maps)
    call release_spherical_geometry(state%spherical)
    if (allocated(state%latitudes%rlati)) deallocate (state%latitudes%rlati)
    if (allocated(state%configuration%nloen)) deallocate (state%configuration%nloen)
    if (allocated(state%cutoffs%nmen)) deallocate (state%cutoffs%nmen)
    call ieee_set_status(incoming)
    error_number = saved_errno
  end subroutine
end module forecast_geometry_horizontal_stages
