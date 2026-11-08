!> Reuse the single native physics runtime owner for its generated namespace.
module forecast_owned_physics_runtime_namespace
  use iso_fortran_env, only: int32
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  implicit none
  private
  public :: native_physics_runtime_data, initialize_fresh_owned_physics_runtime_data
contains
  !> Establish the source zero-born named controls on fresh caller-owned data.
 !! All four forcing owners must be absent. No descriptor bytes are fabricated.
 !! The caller invokes this once before setup or activity flags are consumed.
  integer(int32) function initialize_fresh_owned_physics_runtime_data(state) result(status)
    type(native_physics_runtime_data), intent(inout) :: state
    status = 2
    if (allocated(state%gpforceu) .or. allocated(state%gpforcev)) return
    if (allocated(state%gpforcet) .or. allocated(state%gpforceq)) return
    state%lgradgp = .false.; state%ldry_ecmwf = .false.; state%lmusclfa = .false.
    state%lforcewr = .false.; state%ltestinc = .false.; state%lbfasecv = .false.
    state%lusekf_ref = .false.; state%luse_smos_tb = .false.
    state%npol_max = 0; state%nang_max = 0
    state%lesmos_active = .false.; state%lesmap_active = .false.; state%lesmos_sekf = .false.
    state%legbrad_active = .false.; state%leraingg_active = .false.
    status = 0
  end function
end module
