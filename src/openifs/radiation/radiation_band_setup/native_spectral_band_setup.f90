module native_spectral_band_setup
  !! Prepare source longwave constants and the selected six-band solar coefficients.
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer
  use yoerad, only: TERAD
  use yoesw, only: TESWRT
  use native_longwave_band_record, only: longwave_band_parameter_record, fill_longwave_band_parameters
  use native_shortwave_band_parameters, only: selected_shortwave_parameter_fields
  implicit none
  private
  public :: initialize_selected_spectral_radiation_tables, release_selected_spectral_radiation_tables
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  function initialize_selected_spectral_radiation_tables(longwave, shortwave, radiation, rg, rplrg) result(status)
    !! Read live radiation controls, gravitational acceleration in m/s2 and dimensionless scaling.
    !! Only the selected scalar/inline fields and the two newly owned solar arrays change.
    type(longwave_band_parameter_record), intent(inout) :: longwave
    type(TESWRT), intent(inout) :: shortwave
    type(TERAD), intent(in) :: radiation
    real(c_double), intent(in) :: rg, rplrg
    integer(c_int) :: status, child, saved_errno, failure_errno
    integer(c_int), pointer, volatile :: error_number
    real(c_double), allocatable :: solar(:), solar2(:)
    integer :: allocation_status
    status = 2_c_int
    if (radiation%NSW /= 6 .or. radiation%NTSW /= 14) return
    if (.not. radiation%LONEWSW .or. .not. radiation%LRAYL) return
    if (allocated(shortwave%RSUN) .or. allocated(shortwave%RSUN2)) return
    if (.not. positive_finite(rg) .or. .not. positive_finite(rplrg)) return
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = 1_c_int
    allocate (solar(14), stat=allocation_status)
    if (allocation_status /= 0) return
    allocate (solar2(14), stat=allocation_status)
    if (allocation_status /= 0) then
      failure_errno = error_number
      deallocate (solar)
      error_number = failure_errno
      return
    end if
    child = selected_shortwave_parameter_fields(shortwave, rg, rplrg, solar, solar2)
    if (child /= 0) then
      failure_errno = error_number
      deallocate (solar)
      deallocate (solar2)
      error_number = failure_errno
      status = 2_c_int
      return
    end if
    child = fill_longwave_band_parameters(longwave)
    call move_alloc(solar, shortwave%RSUN)
    call move_alloc(solar2, shortwave%RSUN2)
    error_number = saved_errno
    status = 0_c_int
  end function
  function release_selected_spectral_radiation_tables(shortwave) result(status)
    !! Release only RSUN and RSUN2 in source order; repeated release leaves other members unchanged.
    type(TESWRT), intent(inout) :: shortwave
    integer(c_int) :: status
    if (allocated(shortwave%RSUN)) deallocate (shortwave%RSUN)
    if (allocated(shortwave%RSUN2)) deallocate (shortwave%RSUN2)
    status = 0_c_int
  end function
  elemental function positive_finite(value) result(valid)
    real(c_double), intent(in) :: value
    logical :: valid
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    valid = bits > 0_c_int64_t .and. bits < int(z'7ff0000000000000', c_int64_t)
  end function
end module native_spectral_band_setup
