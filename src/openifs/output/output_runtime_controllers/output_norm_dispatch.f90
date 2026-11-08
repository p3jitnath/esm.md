!> Choose the source spectral child before the grid child.
module forecast_output_norm_dispatch
  use iso_fortran_env, only: int32, int64, real64
  use forecast_output_request_types, only: trqfp, increment_output_counter
  use forecast_runtime_fullpos_norm_controllers, only: native_fullpos_norm_context, &
                             native_fullpos_norm_results, compute_runtime_fullpos_spectral_norms, compute_runtime_fullpos_grid_norms
  use runtime_fullpos_norm_transport_port, only: fullpos_norm_partition
  implicit none
  private
  public :: dispatch_output_norms
contains
  !> Dispatch complete named request owners without copying their arrays.
  !! spectral has (local fields,local spectral words). grid has
  !! (block width,global grid fields,local blocks). domain_name has32 bytes.
  !! level_kind5 selects S; all other source selectors select P.
  !! transport is the caller-owned point-map service view; its temporary
  !! field distribution is restored by the grid child. calls is a wrapping
  !! observation counter. Status is the first returned child status.
  integer(int32) function dispatch_output_norms(context, owner, spectral_request, grid_request, &
        spectral, grid, transport, block_ends, chunk_size, level_kind, resolution, global_points, domain_name, calls) result(status)
    type(native_fullpos_norm_context), intent(in) :: context
    type(native_fullpos_norm_results), intent(inout) :: owner
    type(trqfp), intent(in) :: spectral_request, grid_request
    real(real64), intent(in) :: spectral(:, :), grid(:, :, :)
    type(fullpos_norm_partition), intent(inout) :: transport
    integer(int32), intent(in) :: block_ends(:), chunk_size, level_kind, resolution, global_points
    character(32), intent(in) :: domain_name
    integer(int64), intent(inout) :: calls
    character(1) :: configuration
    status = 2
    if (spectral_request%nfieldg < 0 .or. grid_request%nfieldg < 0) return
    configuration = 'P'
    if (level_kind == 5) configuration = 'S'
    if (spectral_request%nfieldg /= 0) then
      if (.not. allocated(spectral_request%ivsetg) .or. .not. allocated(spectral_request%llsurf) .or. &
          .not. allocated(spectral_request%clpref) .or. .not. allocated(spectral_request%zlev) .or. &
          .not. allocated(spectral_request%clname) .or. .not. allocated(spectral_request%igrib)) return
      if (size(spectral_request%zlev) /= spectral_request%nfieldg) return
      status = compute_runtime_fullpos_spectral_norms(context, owner, [resolution], spectral, &
                                                      spectral_request%ivsetg, spectral_request%llsurf, spectral_request%clpref, &
                                              spectral_request%zlev, spectral_request%clname, spectral_request%igrib, configuration)
      if (status /= 0) return
    end if
    if (grid_request%nfieldg /= 0) then
      if (.not. allocated(grid_request%llsurf) .or. .not. allocated(grid_request%clpref) .or. &
          .not. allocated(grid_request%zlev) .or. .not. allocated(grid_request%idom) .or. &
          .not. allocated(grid_request%idmp) .or. .not. allocated(grid_request%clname) .or. &
          .not. allocated(grid_request%igrib)) then
        status = 2
        return
      end if
      if (size(grid_request%llsurf) /= grid_request%nfieldg) then
        status = 2
        return
      end if
      status = compute_runtime_fullpos_grid_norms(context, owner, transport, chunk_size, grid, block_ends, &
                                grid_request%llsurf, grid_request%clpref, grid_request%zlev, grid_request%idom, grid_request%idmp, &
                                                 grid_request%clname, domain_name, global_points, grid_request%igrib, configuration)
      if (status /= 0) return
    end if
    call increment_output_counter(calls)
    status = 0
  end function
end module
