!> Read explicit byte ceilings for the selected T21/L19 one-process forecast.
module forecast_selected_bootstrap_resource_policy
  use iso_fortran_env, only: int32, int64
  use ieee_exceptions, only: ieee_status_type
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  use forecast_native_execution_setup, only: native_forecast_execution_budget
  use forecast_native_input_memory, only: native_input_memory_policy, minimum_codec_reserve_bytes, minimum_node_reserve_bytes
  implicit none
  private
  public :: read_selected_bootstrap_resources
contains
  !> Read the resource file without changing the incoming IEEE status or errno.
  !! PATH is an existing resource namelist. BUDGET contains per-owner byte
  !! ceilings. POLICY contains allowed memory-node numbers and inside-cap
  !! reserves. Actual array sizes remain derived by the live typed owners.
  subroutine read_selected_bootstrap_resources(path, budget, policy, status)
    character(*), intent(in) :: path
    type(native_forecast_execution_budget), intent(out) :: budget
    type(native_input_memory_policy), intent(out) :: policy
    integer(int32), intent(out) :: status
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error
    integer(int64) :: norm_limit
    call save_lifetime_status(saved, saved_error)
    call read_selected_resource_file(path, budget, policy, norm_limit, status)
    call restore_lifetime_status(saved, saved_error)
  end subroutine
  subroutine read_selected_resource_file(path, budget, policy, norm_limit, status)
    !! The separate resource file sets explicit byte capacities. It cannot
    !! change physics,dates,field ordering or configuration-file controls.
    !! Every large child samples its actual process,cgroup and allowed memory
    !! nodes again. The journal directory must already exist and be writable.
    character(*), intent(in) :: path
    type(native_forecast_execution_budget), intent(out) :: budget
    type(native_input_memory_policy), intent(out) :: policy
    integer(int64), intent(out) :: norm_limit
    integer(int32), intent(out) :: status
    integer(int64) :: node_budget_bytes, other_live_bytes, future_reserve_bytes, codec_reserve_bytes, &
          maximum_age_seconds, gridpoint_bytes, spectral_bytes, spectral_map_bytes, interpolation_bytes, work_bytes, norm_work_bytes
    integer(int64)::loop_bytes,spectral_setup_bytes,mass_bytes,transform_bytes,physics_bytes,ozone_bytes,fullpos_bytes,grid_bytes,halo_bytes,event_bytes
    integer(int32) :: memory_node_count, memory_nodes(64)
    integer :: unit, io, close_status, j
    namelist /native_forecast_resources/ node_budget_bytes, other_live_bytes, future_reserve_bytes, codec_reserve_bytes, &
      maximum_age_seconds, memory_node_count, memory_nodes, gridpoint_bytes, spectral_bytes, spectral_map_bytes, &
      interpolation_bytes, work_bytes, norm_work_bytes, loop_bytes, spectral_setup_bytes, mass_bytes, transform_bytes, &
      physics_bytes, ozone_bytes, fullpos_bytes, grid_bytes, halo_bytes, event_bytes
    loop_bytes = 0; spectral_setup_bytes = 0; mass_bytes = 0; transform_bytes = 0; physics_bytes = 0; ozone_bytes = 0
    fullpos_bytes = 0; grid_bytes = 0; halo_bytes = 0; event_bytes = 0
    node_budget_bytes = 0; other_live_bytes = -1
    future_reserve_bytes = minimum_node_reserve_bytes; codec_reserve_bytes = minimum_codec_reserve_bytes
    maximum_age_seconds = 120; memory_node_count = 0; memory_nodes = -1
    gridpoint_bytes = 0; spectral_bytes = 0; spectral_map_bytes = 0; interpolation_bytes = 0; work_bytes = 0; norm_work_bytes = 0
    status = 2; norm_limit = 0
    open (newunit=unit, file=path, status='old', action='read', form='formatted', iostat=io)
    if (io /= 0) return
    read (unit, nml=native_forecast_resources, iostat=io)
    close (unit, iostat=close_status)
    if (io /= 0 .or. close_status /= 0) return
    if (node_budget_bytes < 1 .or. other_live_bytes < 0) return
    if (future_reserve_bytes < minimum_node_reserve_bytes .or. codec_reserve_bytes < minimum_codec_reserve_bytes) return
    if (maximum_age_seconds < 1 .or. maximum_age_seconds > 120) return
    if (memory_node_count < 1 .or. memory_node_count > 64) return
    do j = 1, memory_node_count
      if (memory_nodes(j) < 0 .or. memory_nodes(j) > 4095) return
      if (j > 1) then
        if (memory_nodes(j) <= memory_nodes(j - 1)) return
      end if
    end do
    if (min(gridpoint_bytes, spectral_bytes, spectral_map_bytes, interpolation_bytes, work_bytes, norm_work_bytes) < 1) return
    if (min(loop_bytes, spectral_setup_bytes, mass_bytes, transform_bytes, physics_bytes, ozone_bytes, &
            fullpos_bytes, grid_bytes, halo_bytes, event_bytes) < 1) return
    budget%loop_bytes = loop_bytes; budget%norm_bytes = norm_work_bytes; budget%spectral_setup_bytes = spectral_setup_bytes
    budget%mass_bytes = mass_bytes; budget%transform_bytes = transform_bytes; budget%physics_bytes = physics_bytes
    budget%ozone_bytes = ozone_bytes; budget%fullpos_bytes = fullpos_bytes; budget%grid_bytes = grid_bytes; budget%halo_bytes = halo_bytes; budget%event_bytes = event_bytes
    policy%node_budget_bytes = node_budget_bytes; policy%other_live_bytes = other_live_bytes
    policy%future_reserve_bytes = future_reserve_bytes; policy%codec_reserve_bytes = codec_reserve_bytes
    policy%maximum_age_seconds = maximum_age_seconds
    policy%memory_node_count = memory_node_count; policy%memory_nodes = memory_nodes
    budget%input%input%fields%gridpoint_bytes = gridpoint_bytes
    budget%input%input%fields%spectral_bytes = spectral_bytes; budget%input%input%fields%spectral_map_bytes = spectral_map_bytes
    budget%input%input%interpolation_bytes = interpolation_bytes; budget%input%work_bytes = work_bytes
    norm_limit = norm_work_bytes
    status = 0
  end subroutine

end module forecast_selected_bootstrap_resource_policy
