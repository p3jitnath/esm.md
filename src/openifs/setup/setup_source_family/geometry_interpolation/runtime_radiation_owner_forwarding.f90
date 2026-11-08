!> Forward actual native radiation owners to the complete unchanged children.
module forecast_runtime_radiation_owner_forwarding
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_grid_dimensions, only: native_grid_dimensions
  use yomphy, only: tphy
  use native_spectral_band_setup, only: initialize_selected_spectral_radiation_tables, release_selected_spectral_radiation_tables
  use cloud_optical_parameter_setup_mod, only: initialize_runtime_cloud_optical_parameters
  use longwave_reference_parameter_setup_mod, only: initialize_longwave_reference_parameters
  implicit none
  private
  public :: initialize_runtime_band_radiation_from_model, release_runtime_band_radiation_from_model
  public :: initialize_runtime_cloud_optical_from_owners, initialize_runtime_longwave_reference_from_model
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Preserve actual LRAY selection, complete native record spans and first-call
 !! solar ownership. RPLRG is the live source scale, never a default constant.
 !! STATE/CONSTANTS/PHY/RPLRG stay disjoint and live through the call.
  integer(int32) function initialize_runtime_band_radiation_from_model(state, constants, phy, rplrg) result(status)
    type(owned_radiation_setup_state), target, intent(inout) :: state
    type(forecast_physical_constants), target, intent(in) :: constants
    type(tphy), target, intent(in) :: phy
    real(real64), target, intent(in) :: rplrg
    integer(c_intptr_t) :: base(4)
    integer(int64) :: bytes(4)
    status = 2
    if (phy%lray) return
    base = [transfer(c_loc(state), 0_c_intptr_t), transfer(c_loc(constants), 0_c_intptr_t), &
            transfer(c_loc(phy), 0_c_intptr_t), transfer(c_loc(rplrg), 0_c_intptr_t)]
    bytes = [storage_size(state, kind=int64)/8, storage_size(constants, kind=int64)/8, &
             storage_size(phy, kind=int64)/8, 8_int64]
    if (.not. separate_records(base, bytes)) return
    status = initialize_selected_spectral_radiation_tables(state%longwave_bands, state%shortwave, &
                                                           state%radiation, constants%rg, rplrg)
    if (status == 0) state%bands_acquired = .true.
  end function
  !> Release only the two solar owners; other setup owners remain untouched.
  integer(int32) function release_runtime_band_radiation_from_model(state) result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number; call ieee_get_status(floating)
    status = release_selected_spectral_radiation_tables(state%shortwave)
    if (status == 0) state%bands_acquired = .false.
    call ieee_set_status(floating); error_number = saved_errno
  end function
  !> Use the actual global level count and original LRAY/LRAYFM15 controls.
 !! The unchanged child writes only its named TERAD/TESWRT/550nm members.
  integer(int32) function initialize_runtime_cloud_optical_from_owners(dimensions, state, phy) result(status)
    type(native_grid_dimensions), target, intent(in) :: dimensions
    type(owned_radiation_setup_state), target, intent(inout) :: state
    type(tphy), target, intent(in) :: phy
    integer(c_intptr_t) :: base(3)
    integer(int64) :: bytes(3)
    integer(int32) :: allocated_bands, active_bands, levels
    status = 2
    if (phy%lray .or. phy%lrayfm15) return
    if (dimensions%nflevg < 1 .or. dimensions%nflevg > 256) return
    base = [transfer(c_loc(dimensions), 0_c_intptr_t), transfer(c_loc(state), 0_c_intptr_t), transfer(c_loc(phy), 0_c_intptr_t)]
    bytes = [storage_size(dimensions, kind=int64)/8, storage_size(state, kind=int64)/8, storage_size(phy, kind=int64)/8]
    if (.not. separate_records(base, bytes)) return
    allocated_bands = state%radiation%ntsw; active_bands = state%radiation%nsw; levels = dimensions%nflevg
    status = initialize_runtime_cloud_optical_parameters(state%radiation, state%shortwave, state%cloud_optical_550, &
                                                         allocated_bands, active_bands, levels)
  end function
  !> Consume the eight live TERDI fractions and actual molecular masses.
 !! The complete canonical longwave output remains the one setup owner.
  integer(int32) function initialize_runtime_longwave_reference_from_model(state, constants) result(status)
    type(owned_radiation_setup_state), target, intent(inout) :: state
    type(forecast_physical_constants), target, intent(in) :: constants
    integer(c_intptr_t) :: base(2)
    integer(int64) :: bytes(2)
    status = 2
    base = [transfer(c_loc(state), 0_c_intptr_t), transfer(c_loc(constants), 0_c_intptr_t)]
    bytes = [storage_size(state, kind=int64)/8, storage_size(constants, kind=int64)/8]
    if (.not. separate_records(base, bytes)) return
    status = initialize_longwave_reference_parameters(state%longwave_reference, state%gases, constants)
  end function
  logical function separate_records(base, bytes) result(separate)
    integer(c_intptr_t), intent(in) :: base(:)
    integer(int64), intent(in) :: bytes(:)
    integer :: i, j
    separate = .false.
    if (size(base) /= size(bytes)) return
    do i = 1, size(base)
      if (base(i) <= 0 .or. bytes(i) < 1 .or. base(i) > huge(base(i)) - bytes(i)) return
      do j = 1, i - 1
        if (base(i) <= base(j)) then
          if (base(j) - base(i) < bytes(i)) return
        else
          if (base(i) - base(j) < bytes(j)) return
        end if
      end do
    end do
    separate = .true.
  end function
end module forecast_runtime_radiation_owner_forwarding
