!> Own diagnostic-cloud storage and selected gravity-wave setup.
module cloud_gravity_wave_parameter_setup_mod
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_loc, c_f_pointer, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_all, ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoecld, only: tecld
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use diagnostic_cloud_parameter_fields_mod, only: initialize_diagnostic_cloud_fields
  use gravity_wave_parameter_fields_mod, only: &
    initialize_orographic_gravity_wave_fields, initialize_nonorographic_gravity_wave_fields
  implicit none
  private
  public :: initialize_cloud_gravity_wave_parameters
  public :: initialize_runtime_cloud_gravity_wave_parameters, release_cloud_parameter_eta
  interface
    function errno_pointer() bind(c, name="__errno_location") result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Initialize the selected 19-level cloud and gravity-wave parameters.
  !! TEXT contains readonly namelist text. CLOUD, OROGRAPHIC and
  !! NONOROGRAPHIC are separate native output records. CLOUD%CETA must
  !! be unallocated on entry. The other output bytes retain their preimage
  !! wherever the selected source leaves them unchanged.
  !! ETA contains dimensionless full-level coordinates in [0,1].
  !! PRESSURE contains positive reference pressures in Pa. VAH and VBH
  !! contain half-level coefficients in Pa and dimensionless units.
  !! They supply at least 20 cells for the 19 active levels.
  !! CONSTANTS supplies RHOUR equal to 3600 s. TIMESTEP is in seconds.
  !! LEPHYS selects the source gravity-wave limiter. Empty NAMGWD and
  !! NAMGWWMS groups retain configuration 1 with one launch level.
  !! Return 0 on success, 1 after an allocation failure or 2 before output
  !! mutation for unsupported inputs. Release CETA through the native
  !! release entry while its outer record remains live.
  integer(int32) function initialize_cloud_gravity_wave_parameters( &
    text, cloud, orographic, nonorographic, eta, pressure, vah, vbh, constants, timestep, lephys) result(status)
    character(len=*), intent(in), target :: text
    type(tecld), intent(inout), target :: cloud
    type(tegwd), intent(inout), target :: orographic
    type(tegwwms), intent(inout), target :: nonorographic
    real(real64), intent(in), target :: eta(:), pressure(:), vah(:), vbh(:), timestep
    type(forecast_physical_constants), intent(in), target :: constants
    logical, intent(in), target :: lephys
    integer(int32), target :: levels
    levels = 19_int32
    status = initialize_selected(text, cloud, orographic, nonorographic, eta, pressure, &
                                 vah, vbh, levels, constants, timestep, lephys)
  end function

  !> Use the same owned setup with the caller's live 2 through 512 levels.
  !! LEVELS is an explicit int32 count. ETA and PRESSURE supply that many
  !! cells, while VAH and VBH supply LEVELS+1 cells. Extra cells remain
  !! untouched and unread. Separate default and live-level byte evidence
  !! are required before claiming either complete supported domain.
  integer(int32) function initialize_runtime_cloud_gravity_wave_parameters( &
    text, cloud, orographic, nonorographic, eta, pressure, vah, vbh, levels, constants, timestep, lephys) result(status)
    character(len=*), intent(in), target :: text
    type(tecld), intent(inout), target :: cloud
    type(tegwd), intent(inout), target :: orographic
    type(tegwwms), intent(inout), target :: nonorographic
    real(real64), intent(in), target :: eta(:), pressure(:), vah(:), vbh(:), timestep
    type(forecast_physical_constants), intent(in), target :: constants
    integer(int32), intent(in), target :: levels
    logical, intent(in), target :: lephys
    status = 2_int32
    if (levels < 2_int32 .or. levels > 512_int32) return
    status = initialize_selected(text, cloud, orographic, nonorographic, eta, pressure, &
                                 vah, vbh, levels, constants, timestep, lephys)
  end function

  !> Admit complete native inputs before creating the one private owner.
  integer(int32) function initialize_selected( &
    text, cloud, orographic, nonorographic, eta, pressure, vah, vbh, levels, constants, timestep, lephys) result(status)
    character(len=*), intent(in), target :: text
    type(tecld), intent(inout), target :: cloud
    type(tegwd), intent(inout), target :: orographic
    type(tegwwms), intent(inout), target :: nonorographic
    real(real64), intent(in), target :: eta(:), pressure(:), vah(:), vbh(:), timestep
    type(forecast_physical_constants), intent(in), target :: constants
    integer(int32), intent(in), target :: levels
    logical, intent(in), target :: lephys
    real(real64), allocatable :: eta_owner(:)
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    logical :: incoming_flags(size(ieee_all))
    integer(c_intptr_t) :: addresses(12)
    integer(int64) :: lengths(12), word
    integer :: first, second, level, allocation_status
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (size(eta) < levels .or. size(pressure) < levels) return
    if (size(vah) < levels + 1 .or. size(vbh) < levels + 1) return
    if (.not. is_contiguous(eta) .or. .not. is_contiguous(pressure)) return
    if (.not. is_contiguous(vah) .or. .not. is_contiguous(vbh)) return
    if (allocated(cloud%ceta)) return
    addresses(1) = transfer(c_loc(cloud), addresses(1))
    addresses(2) = transfer(c_loc(orographic), addresses(2))
    addresses(3) = transfer(c_loc(nonorographic), addresses(3))
    addresses(4) = transfer(c_loc(text(1:1)), addresses(4))
    addresses(5) = transfer(c_loc(eta(1)), addresses(5))
    addresses(6) = transfer(c_loc(pressure(1)), addresses(6))
    addresses(7) = transfer(c_loc(vah(1)), addresses(7))
    addresses(8) = transfer(c_loc(vbh(1)), addresses(8))
    addresses(9) = transfer(c_loc(constants), addresses(9))
    addresses(10) = transfer(c_loc(timestep), addresses(10))
    addresses(11) = transfer(c_loc(levels), addresses(11))
    addresses(12) = transfer(c_loc(lephys), addresses(12))
    lengths(1) = storage_size(cloud, kind=int64)/8_int64
    lengths(2) = storage_size(orographic, kind=int64)/8_int64
    lengths(3) = storage_size(nonorographic, kind=int64)/8_int64
    lengths(4) = int(len(text), int64)
    lengths(5) = 8_int64*int(levels, int64)
    lengths(6) = lengths(5)
    lengths(7) = 8_int64*(int(levels, int64) + 1_int64)
    lengths(8) = lengths(7)
    lengths(9) = storage_size(constants, kind=int64)/8_int64
    lengths(10) = 8_int64
    lengths(11) = 4_int64
    lengths(12) = storage_size(lephys, kind=int64)/8_int64
    do first = 1, 3
      do second = first + 1, 12
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    do level = 1, levels
      if (.not. nonnegative_word_in_range(eta(level), 1.0_real64)) return
      word = transfer(pressure(level), word)
      if (word <= 0_int64 .or. word >= int(z'7ff0000000000000', int64)) return
    end do
    do level = 1, levels + 1
      if (.not. nonnegative_word_in_range(vah(level), 101325.0_real64)) return
      if (.not. nonnegative_word_in_range(vbh(level), 1.0_real64)) return
    end do
    if (transfer(constants%rhour, word) /= int(z'40ac200000000000', int64)) return
    word = transfer(timestep, word)
    if (word < transfer(1.0_real64, 0_int64) .or. word > transfer(86400.0_real64, 0_int64)) return
    status = require_empty_physics_group(text, 'NAMGWD')
    if (status /= 0_int32) return
    status = require_empty_physics_group(text, 'NAMGWWMS')
    if (status /= 0_int32) return
    call c_f_pointer(errno_pointer(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    allocate (eta_owner(levels), stat=allocation_status)
    errno_value = incoming_errno
    call ieee_set_flag(ieee_all, incoming_flags)
    if (allocation_status /= 0) then
      status = 1_int32
      return
    end if
    call move_alloc(eta_owner, cloud%ceta)
    call initialize_diagnostic_cloud_fields(cloud, eta(:levels))
    call initialize_orographic_gravity_wave_fields( &
      orographic, pressure(:levels), vah(:levels + 1), vbh(:levels + 1), constants%rhour, lephys)
    call initialize_nonorographic_gravity_wave_fields( &
      nonorographic, pressure(:levels), constants%rhour, timestep)
    status = 0_int32
  end function

  !> Release CETA once or return success for an already empty owner.
  !! CLOUD remains live. Deallocation clears its native data association
  !! and retains all numerical fields. The compiler owns descriptor state.
  !! The public C errno service and IEEE flag queries isolate allocator
  !! side effects. Return 1 only if native deallocation itself reports failure.
  integer(int32) function release_cloud_parameter_eta(cloud) result(status)
    type(tecld), intent(inout) :: cloud
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    logical :: incoming_flags(size(ieee_all))
    integer :: allocation_status
    status = 0_int32
    if (.not. allocated(cloud%ceta)) return
    call c_f_pointer(errno_pointer(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    deallocate (cloud%ceta, stat=allocation_status)
    errno_value = incoming_errno
    call ieee_set_flag(ieee_all, incoming_flags)
    if (allocation_status /= 0) status = 1_int32
  end function

  !> Accept finite nonnegative values, including either signed zero.
  logical function nonnegative_word_in_range(value, upper) result(valid)
    real(real64), intent(in) :: value, upper
    integer(int64) :: word, magnitude, limit
    word = transfer(value, word)
    magnitude = iand(word, int(z'7fffffffffffffff', int64))
    limit = transfer(upper, limit)
    valid = magnitude <= limit .and. (word >= 0_int64 .or. magnitude == 0_int64)
  end function

  !> Require separate native spans without private target-specific offsets.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Require nearest rounding and gradual underflow without changing flags.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module
