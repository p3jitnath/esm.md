module initial_spectral_virtual_temperature_port
  !! Own initial spectral temperature conversion and its public call order.
  !! Temperatures are kelvin;gas constants are J/(kg K). Numerical work is
  !! the unchanged owned GPRCP child followed by separately rounded R*T/RD.
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, &
                             ieee_support_underflow_control, ieee_get_underflow_mode, operator(/=)
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  use public_scalar_transform_port
  use initial_virtual_temperature_gas_port
  use initial_virtual_temperature_cells_port
  implicit none
  private
  public :: initialize_spectral_virtual_temperature
  public :: initialize_operational_spectral_virtual_temperature
  public :: initialize_runtime_spectral_virtual_temperature
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function initialize_spectral_virtual_temperature(control,resolution,field_owner,constants,constituents,spectral_water,generic_fields,spectral_temperature) result(status)
    !! Selected source shape is T21/L19,one process,P24,Q2048,B86,
    !! 506local real spectral coefficients and8generic fields.
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), contiguous, intent(in) :: field_owner(:)
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: constituents(:)
    logical, intent(in) :: spectral_water(3)
    real(real64), contiguous, intent(in) :: generic_fields(:, :, :, :)
    real(real64), contiguous, intent(inout) :: spectral_temperature(:, :)
    status = 2
    if (control%nproc /= 1 .or. resolution%resolution /= 1 .or. resolution%truncation /= 21) return
    if (any(shape(generic_fields) /= [24, 19, 8, 86])) return
    if (any(shape(spectral_temperature) /= [19, 506])) return
    status=convert_temperature(control,resolution,field_owner,2048_int64,constants,constituents,spectral_water,generic_fields,spectral_temperature,.true.)
  end function
  integer(int32) function initialize_operational_spectral_virtual_temperature(control,resolution,field_owner,constants,constituents,spectral_water,generic_fields,spectral_temperature) result(status)
    !! Fixed operational source shape is T1279/L137,P17,Q1649920,B97055,
    !! 68or69local levels,819840real coefficients and9generic fields.
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), contiguous, intent(in) :: field_owner(:)
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: constituents(:)
    logical, intent(in) :: spectral_water(3)
    real(real64), contiguous, intent(in) :: generic_fields(:, :, :, :)
    real(real64), contiguous, intent(inout) :: spectral_temperature(:, :)
    status = 2
    if (resolution%resolution /= 1 .or. resolution%truncation /= 1279) return
    if (any(shape(generic_fields) /= [17, 137, 9, 97055])) return
    if (size(spectral_temperature, 1) < 68 .or. size(spectral_temperature, 1) > 69) return
    if (size(spectral_temperature, 2) /= 819840) return
    status=convert_temperature(control,resolution,field_owner,1649920_int64,constants,constituents,spectral_water,generic_fields,spectral_temperature,.false.)
  end function
  integer(int32) function initialize_runtime_spectral_virtual_temperature(control,resolution,field_owner,local_points,constants,constituents,spectral_water,generic_fields,spectral_temperature) result(status)
    !! Runtime source shape is(P,137,9,B),P1..1024,B1..388217 and
    !! B=ceil(local_points/P). The public map supplies local spectral levels.
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), contiguous, intent(in) :: field_owner(:)
    integer(int64), intent(in) :: local_points
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: constituents(:)
    logical, intent(in) :: spectral_water(3)
    real(real64), contiguous, intent(in) :: generic_fields(:, :, :, :)
    real(real64), contiguous, intent(inout) :: spectral_temperature(:, :)
    status = 2
    if (resolution%truncation < 1 .or. resolution%truncation > 4096) return
    if (size(generic_fields, 1) < 1 .or. size(generic_fields, 1) > 1024) return
    if (size(generic_fields, 2) /= 137 .or. size(generic_fields, 3) /= 9) return
    if (size(generic_fields, 4) < 1 .or. size(generic_fields, 4) > 388217) return
    if (local_points < 1 .or. local_points > 2147483647_int64) return
    if (int(size(generic_fields, 4), int64) /= (local_points + size(generic_fields, 1) - 1)/size(generic_fields, 1)) return
    if (size(spectral_temperature, 1) > 137) return
    status=convert_temperature(control,resolution,field_owner,local_points,constants,constituents,spectral_water,generic_fields,spectral_temperature,.false.)
  end function
  integer(int32) function convert_temperature(control,resolution,field_owner,local_points,constants,constituents,spectral_water,generic_fields,spectral_temperature,selected) result(status)
    type(native_transform_control), intent(in) :: control
    type(native_transform_resolution), intent(in) :: resolution
    integer(int32), contiguous, intent(in) :: field_owner(:)
    integer(int64), intent(in) :: local_points
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: constituents(:)
    logical, intent(in) :: spectral_water(3), selected
    real(real64), contiguous, intent(in) :: generic_fields(:, :, :, :)
    real(real64), contiguous, intent(inout) :: spectral_temperature(:, :)
    real(real64), allocatable :: temperature(:, :, :), gas(:, :)
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno, observed_errno
    type(ieee_status_type) :: incoming, observed
    integer :: allocation_status, block, rows, levels, blocks, active
    integer(int32) :: child
    status = 2
    if (any(spectral_water)) return
    rows = size(generic_fields, 1); levels = size(generic_fields, 2); blocks = size(generic_fields, 4)
    if (size(field_owner) /= levels) return
    if (.not. control%message_ready .or. .not. control%environment_ready) return
    if (control%nproc < 1 .or. control%nproc > 32 .or. control%nprtrv < 1 .or. control%nprtrv > control%nproc) return
    if (control%mysetv < 1 .or. control%mysetv > control%nprtrv) return
    if (any(field_owner < 1) .or. any(field_owner > control%nprtrv)) return
    if (count(field_owner == control%mysetv) /= size(spectral_temperature, 1)) return
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    call ieee_get_status(incoming)
    if (.not. floating_environment_ready()) then
      call ieee_set_status(incoming); error_number = saved_errno
      return
    end if
    allocate (temperature(rows, levels, blocks), stat=allocation_status)
    status = 1
    if (allocation_status /= 0) goto900
    allocate (gas(rows, levels), stat=allocation_status)
    if (allocation_status /= 0) goto900
    error_number = saved_errno
    child = inverse_scalar_transform(control, resolution, field_owner, local_points, spectral_temperature, temperature)
    status = 2
    if (child /= 0) goto900
    do block = 1, blocks
      active = rows
      if (block == blocks) active = int(local_points - int(blocks - 1, int64)*rows)
      call initial_virtual_temperature_gas(constants, int(rows, int32), 1_int32, int(active, int32), int(levels, int32), &
                                           [.false., .false., .false., .false., .false., .false.], child, gas_constant=gas, &
                                           generic_fields=generic_fields(:, :, :, block), constituents=constituents)
      if (child /= 0) then
        status = child
        goto900
      end if
      if (selected) then
        child = initial_virtual_temperature_cells(temperature(:, :, block), gas, int(active, int32), constants%dry_gas_constant)
      else
        child = runtime_virtual_temperature_cells(temperature(:, :, block), gas, int(active, int32), constants%dry_gas_constant)
      end if
      if (child /= 0) then
        status = 2
        goto900
      end if
    end do
    child = forward_scalar_transform(control, resolution, field_owner, local_points, temperature, spectral_temperature)
    status = child
900 call ieee_get_status(observed); observed_errno = error_number
    if (allocated(gas)) deallocate (gas)
    if (allocated(temperature)) deallocate (temperature)
    call ieee_set_status(observed); error_number = observed_errno
  end function
  logical function floating_environment_ready() result(ready)
    !! Use the supported public inquiry,or the already-qualified exact
    !! tiny*0.5 probe when GNU does not expose underflow control.
    type(ieee_round_type) :: rounding
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    logical :: gradual
    ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    ready = .true.
  end function
end module
