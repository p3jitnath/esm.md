!> Canonical native EC physics owners. No original module state is imported.
module forecast_ecmwf_physics_field_types
  use, intrinsic :: iso_c_binding, only: c_double, c_int
  implicit none
  private
  public :: native_ecmwf_physics_fields, native_physics_runtime_data
  !> Six separate FP64 owners. P,T,B,L are dimensionless layout counts.
  !> Tile fields retain their source physical units after later calculation.
  !> PHYS_MWAVE has shape(P,L,9,B); its values begin as positive zero.
  type :: native_ecmwf_physics_fields
    real(c_double), allocatable :: rustrti(:, :, :), rvstrti(:, :, :), rahfsti(:, :, :)
    real(c_double), allocatable :: revapti(:, :, :), rtskti(:, :, :)
    logical :: lphys_mwave_filled_in = .false.
    real(c_double), allocatable :: phys_mwave(:, :, :, :)
    ! This records native storage lifetime, not physical initialization.
    logical :: storage_metadata_written = .false.
  end type native_ecmwf_physics_fields
  !> One caller-owned runtime namespace, shared with the later forcing stage.
  !> Initial false/zero values express the retained source BSS policy.
  !> Array descriptors are valid absent native owners, never raw byte buffers.
  !> Pass this owner as TARGET at every borrowed forcing-view boundary.
  type :: native_physics_runtime_data
    logical :: lgradgp = .false., ldry_ecmwf = .false., lmusclfa = .false.
    logical :: lforcewr = .false., ltestinc = .false.
    logical :: lbfasecv = .false., lusekf_ref = .false., luse_smos_tb = .false.
    integer(c_int) :: npol_max = 0_c_int, nang_max = 0_c_int
    logical :: lesmos_active = .false., lesmap_active = .false., lesmos_sekf = .false.
    logical :: legbrad_active = .false., leraingg_active = .false.
    real(c_double), allocatable :: gpforceu(:, :, :, :), gpforcev(:, :, :, :)
    real(c_double), allocatable :: gpforcet(:, :, :, :), gpforceq(:, :, :, :)
  end type native_physics_runtime_data
end module forecast_ecmwf_physics_field_types
