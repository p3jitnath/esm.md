!> Retain the SCAN2M_HPOS block selection and optional input-climatology check.
module forecast_runtime_physical_output_scan
  use iso_fortran_env, only: int32, real64
  use forecast_runtime_physical_output_block
  use forecast_output_request_types, only: trqfp
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry
  use runtime_input_climatology_port, only: climatology_field_pair, check_input_climatology
  use yomafn, only: tafn
  use yomfpc, only: tnamfpsci
  implicit none
  private
  public :: scan_physical_output_block
contains
  !> Borrow actual block arrays, check the source P-route pairs and call complete HPOS.
  !! terrain has its native active extent. A local padded view supplies only bounds for the
  !! unchanged climatology provider; that provider reads active_count values only.
  integer(int32) function scan_physical_output_block(request, science, afn, horizontal, state, registry, &
                                                   terrain, block, active_count, check_climatology, controls, output) result(status)
    type(trqfp), intent(in) :: request
    type(tnamfpsci), intent(in) :: science
    type(tafn), intent(in) :: afn
    logical, intent(in) :: horizontal, check_climatology
    type(surface_field_state), target, intent(in) :: state
    type(surface_field_registry), target, intent(in) :: registry
    real(real64), target, intent(in) :: terrain(:)
    integer(int32), intent(in) :: block, active_count
    type(native_physical_output_controls), intent(in) :: controls
    real(real64), intent(inout) :: output(:, :)
    integer :: width, blocks, k, flags(5)
    integer(int32) :: child
    status = 2
    if (admit_physical_output_controls(controls) /= 0 .or. horizontal) return
    width = controls%block_width
    blocks = int((int(controls%local_points, 8) + width - 1)/width)
    if (block < 1 .or. block > blocks .or. active_count < 1 .or. active_count > width) return
    if (size(terrain) < active_count) return
    if (.not. allocated(state%sp_sb)) return
    if (size(state%sp_sb, 1) /= width .or. size(state%sp_sb, 4) /= blocks) return
    if (.not. allocated(state%sp_sg)) return
    if (size(state%sp_sg, 1) /= width .or. size(state%sp_sg, 4) /= blocks) return
    if (.not. allocated(state%sp_sl)) return
    if (size(state%sp_sl, 1) /= width .or. size(state%sp_sl, 3) /= blocks) return
    if (.not. allocated(state%sp_rr)) return
    if (size(state%sp_rr, 1) /= width .or. size(state%sp_rr, 3) /= blocks) return
    if (.not. allocated(state%sp_ci)) return
    if (size(state%sp_ci, 1) /= width .or. size(state%sp_ci, 3) /= blocks) return
    if (.not. allocated(state%sd_ws)) return
    if (size(state%sd_ws, 1) /= width .or. size(state%sd_ws, 3) /= blocks) return
    if (.not. allocated(state%sd_vd)) return
    if (size(state%sd_vd, 1) /= width .or. size(state%sd_vd, 3) /= blocks) return
    if (.not. allocated(state%sd_vx)) return
    if (size(state%sd_vx, 1) /= width .or. size(state%sd_vx, 3) /= blocks) return
    if (.not. allocated(state%sd_vf)) return
    if (size(state%sd_vf, 1) /= width .or. size(state%sd_vf, 3) /= blocks) return
    if (.not. allocated(state%sd_vv)) return
    if (size(state%sd_vv, 1) /= width .or. size(state%sd_vv, 3) /= blocks) return
    if (.not. allocated(state%sd_vp)) return
    if (size(state%sd_vp, 1) /= width .or. size(state%sd_vp, 3) /= blocks) return
    if (.not. allocated(state%sd_va)) return
    if (size(state%sd_va, 1) /= width .or. size(state%sd_va, 3) /= blocks) return
    if (.not. allocated(state%sd_vc)) return
    if (size(state%sd_vc, 1) /= width .or. size(state%sd_vc, 3) /= blocks) return
    if (.not. allocated(state%sd_x2)) return
    if (size(state%sd_x2, 1) /= width .or. size(state%sd_x2, 3) /= blocks) return
    if (.not. allocated(state%sd_sm)) return
    if (size(state%sd_sm, 1) /= width .or. size(state%sd_sm, 4) /= blocks) return
    if (.not. allocated(state%sd_oc)) return
    if (size(state%sd_oc, 1) /= width .or. size(state%sd_oc, 3) /= blocks) return
    if (check_climatology) then
      flags(1) = physical_surface_field_flag(registry, 329, 'YSD_VX%YORO')
      flags(2) = physical_surface_field_flag(registry, 95, 'YSD_VV%YSAB')
      flags(3) = physical_surface_field_flag(registry, 335, 'YSD_VX%YSAB')
      flags(4) = physical_surface_field_flag(registry, 96, 'YSD_VV%YD2')
      flags(5) = physical_surface_field_flag(registry, 336, 'YSD_VX%YXD2')
      if (any(flags < 0)) return
      block
        type(climatology_field_pair) :: pairs(3)
        real(real64), target :: terrain_work(width)
        pairs(1)%active = flags(1) == 1
        pairs(2)%active = flags(2) == 1 .and. flags(3) == 1
        pairs(3)%active = flags(4) == 1 .and. flags(5) == 1
        pairs(1)%tolerance = science%rfpcorr
        pairs(2)%tolerance = science%rfpcsab
        pairs(3)%tolerance = science%rfpcd2
        if (pairs(1)%active) then
          do k = 1, active_count
            terrain_work(k) = terrain(k)
          end do
          pairs(1)%left => terrain_work
          call borrow_physical_surface_plane(state, registry, 329, 'YSD_VX%YORO', 1, 0, block, &
                                             controls, pairs(1)%right, child)
          if (child /= 0) return
        end if
        if (pairs(2)%active) then
          call borrow_physical_surface_plane(state, registry, 95, 'YSD_VV%YSAB', 1, 0, block, &
                                             controls, pairs(2)%left, child)
          if (child /= 0) return
          call borrow_physical_surface_plane(state, registry, 335, 'YSD_VX%YSAB', 1, 0, block, &
                                             controls, pairs(2)%right, child)
          if (child /= 0) return
        end if
        if (pairs(3)%active) then
          call borrow_physical_surface_plane(state, registry, 96, 'YSD_VV%YD2', 1, 0, block, &
                                             controls, pairs(3)%left, child)
          if (child /= 0) return
          call borrow_physical_surface_plane(state, registry, 336, 'YSD_VX%YXD2', 1, 0, block, &
                                             controls, pairs(3)%right, child)
          if (child /= 0) return
        end if
        call check_input_climatology(width, active_count, pairs, controls%budget_bytes, child)
        if (child /= 0) then
          status = child
          return
        end if
      end block
    end if
    status = calculate_physical_output_block(request, science%nfpcli, afn, horizontal, state, registry, terrain, &
                                             block, active_count, controls, output)
  end function
end module forecast_runtime_physical_output_scan
