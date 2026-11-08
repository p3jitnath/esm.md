!> Bind actual model pressure, constants and clock to the native wave setup.
module forecast_owned_runtime_nonorographic_wave_parameters
  use iso_fortran_env, only: int32, int64, real64
  use forecast_operational_model_types, only: native_operational_model_configuration
  use yoegwwms, only: tegwwms
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use gravity_wave_parameter_fields_mod, only: initialize_nonorographic_gravity_wave_fields
  implicit none
  private
  public :: initialize_owned_runtime_nonorographic_wave_parameters
contains
  !> Write the one existing EC wave record from actual upstream owners.
 !! STPRE is in Pa and RHOUR/TSTEP are in s. Levels2:256 follow the source
 !! standard-atmosphere bound. The caller retains the sole model/clock and
 !! passes its actual EC state%nonorographic_gravity_wave as OUTPUT.
 !! All unsupported metadata refuses before numerical work or output stores.
  integer(int32) function initialize_owned_runtime_nonorographic_wave_parameters(text, model, output) result(status)
    character(*), intent(in) :: text
    type(native_operational_model_configuration), target, intent(in) :: model
    type(tegwwms), intent(inout) :: output
    integer :: levels, j
    integer(int64) :: word
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. model%initial%ready) return
    if (.not. allocated(model%initial%geometry)) return
    if (.not. model%initial%geometry%initialized) return
    if (.not. associated(model%partition)) return
    if (.not. associated(model%partition, model%initial%geometry%partition)) return
    if (model%initial%controls%namespace%nconf /= 1) return
    levels = model%initial%geometry%dimensions%nflevg
    if (levels < 2 .or. levels > 256) return
    if (.not. allocated(model%initial%geometry%atmosphere%full_pressure)) return
    if (size(model%initial%geometry%atmosphere%full_pressure) /= levels) return
    word = transfer(model%initial%constants%rhour, 0_int64)
    if (word /= int(z'40ac200000000000', int64)) return
    word = transfer(model%initial%controls%clock%integration%first_dt, 0_int64)
    if (word < int(z'3ff0000000000000', int64) .or. word > int(z'40f5180000000000', int64)) return
    do j = 1, levels
      word = transfer(model%initial%geometry%atmosphere%full_pressure(j), 0_int64)
      if (word <= 0_int64 .or. word >= int(z'7ff0000000000000', int64)) return
    end do
    status = require_empty_physics_group(text, 'NAMGWWMS'); if (status /= 0) return
 call initialize_nonorographic_gravity_wave_fields(output,model%initial%geometry%atmosphere%full_pressure,model%initial%constants%rhour,model%initial%controls%clock%integration%first_dt)
    status = 0
  end function
end module
