!> Publish the diffusion mode in the one canonical owned scalar namespace.
module forecast_owned_diffusion_scalar_mode
  use iso_c_binding, only: c_int, c_int64_t, c_loc, c_associated
  use forecast_native_scalar_data, only: native_forecast_scalar_data, owned_forecast_scalar_data
  implicit none
  private
  public :: initialize_owned_diffusion_scalar_mode
contains
  !> Require the actual owned namespace and its three source zero inputs.
  !! STATE is a borrowed TARGET native record. No second namespace is created.
  !! LSFCFLX is dimensionless; REXTLHF/REXTSHF retain their source flux units
  !! and must contain positive zero. Only N_VMASS changes, to source minus1.
  integer(c_int) function initialize_owned_diffusion_scalar_mode(state) result(status)
    type(native_forecast_scalar_data), target, intent(inout) :: state
    status = 2
    if (.not. c_associated(c_loc(state), c_loc(owned_forecast_scalar_data))) return
    if (transfer(state%lsfcflx, 0_c_int) /= 0) return
    if (transfer(state%rextlhf, 0_c_int64_t) /= 0_c_int64_t) return
    if (transfer(state%rextshf, 0_c_int64_t) /= 0_c_int64_t) return
    state%n_vmass = -1
    status = 0
  end function
end module forecast_owned_diffusion_scalar_mode
