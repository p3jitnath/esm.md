module owned_distributed_spectral_field_storage_port
  !! Bind the canonical native geometry producers to spectral allocation.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_laplacian_geometry, only: native_laplacian_geometry
  use spectral_field_storage_port, only: spectral_field_state, release_spectral_field
  use distributed_spectral_field_storage_port, only: distributed_spectral_map_view, initialize_distributed_spectral_field
  implicit none
  private
  public :: initialize_owned_distributed_spectral_field, release_distributed_spectral_field
contains
  integer(int32) function initialize_owned_distributed_spectral_field(output, dimensions, control, resolution, partition, &
                                                                      laplacian, identifiers, byte_cap) result(status)
    !! All producers are readonly and caller-owned. They must be completed
    !! for the same live public resolution. Only output numerical/map arrays
    !! are acquired; no geometry, map owner or public context is duplicated.
    type(spectral_field_state), target, intent(inout) :: output
    type(native_grid_dimensions), intent(in) :: dimensions
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    type(native_distributed_partition), target, intent(in) :: partition
    type(native_laplacian_geometry), target, intent(in) :: laplacian
    integer(int32), intent(in) :: identifiers(5)
    integer(int64), intent(in) :: byte_cap
    type(distributed_spectral_map_view) :: view
    integer :: nw, nv
    status = 2
    if (partition%phase /= 7 .or. resolution%resolution <= 0) return
    if (dimensions%nsmax < 1 .or. dimensions%nsmax > 4096 .or. dimensions%nflevg < 1 .or. dimensions%nflevg > 256) return
    if (partition%borrowed_resolution /= resolution%resolution) return
    if (resolution%truncation /= dimensions%nsmax) return
    if (.not. control%message_ready .or. .not. control%environment_ready) return
    nw = control%nprtrw; nv = control%nprtrv
    if (nw < 1 .or. nw > 65536 .or. nv < 1 .or. nv > 257) return
    if (int(nw, int64)*int(nv, int64) /= int(control%nproc, int64)) return
    if (.not. allocated(laplacian%myms) .or. .not. allocated(laplacian%nasm0)) return
    if (.not. allocated(partition%nallms) .or. .not. allocated(partition%nptrms)) return
    if (.not. allocated(partition%numll) .or. .not. allocated(partition%nptrll)) return
    if (.not. allocated(partition%npsurf) .or. .not. allocated(partition%numpp)) return
    if (size(laplacian%myms) /= partition%nump) return
    if (size(laplacian%nasm0) /= dimensions%nsmax + 1 .or. lbound(laplacian%nasm0, 1) /= 0) return
    if (size(partition%nallms) /= dimensions%nsmax + 1 .or. size(partition%nptrms) /= nw) return
    if (size(partition%numll) /= nv + 1 .or. size(partition%nptrll) /= nv + 1) return
    if (size(partition%npsurf) /= nv .or. size(partition%numpp) /= nw) return
    view%wave_group = control%mysetw; view%level_group = control%mysetv
    view%wave_groups = nw; view%level_groups = nv
    view%local_coefficients = partition%nspec2; view%local_waves = partition%nump
    view%n = dimensions%nsmax; view%levels = dimensions%nflevg
    view%myms => laplacian%myms; view%nasm0(0:) => laplacian%nasm0
    view%nallms => partition%nallms; view%nptrms => partition%nptrms
    view%numll => partition%numll(1:nv); view%nptrll => partition%nptrll(1:nv)
    view%npsurf => partition%npsurf; view%numpp => partition%numpp
    status = initialize_distributed_spectral_field(output, view, identifiers, byte_cap)
  end function
  integer(int32) function release_distributed_spectral_field(output) result(status)
    !! The source release is shape independent and ends only field owners.
    type(spectral_field_state), intent(inout) :: output
    status = release_spectral_field(output)
  end function
end module owned_distributed_spectral_field_storage_port
