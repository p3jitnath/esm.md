module runtime_grib_packing_policy_c_interface
  !! Keep the existing public component interface at the C boundary.
  !! The six integer controls become named Fortran metadata immediately.
  use, intrinsic :: iso_c_binding
  use runtime_grib_packing_policy_port
  implicit none
contains
  function set_packing_c(handle, parameter_id, level_bytes, level_length, spectral, &
                         gradient, values_address, value_count, truncation, control_address) &
    bind(C, name="md2asm_set_runtime_grib_packing_fortran") result(status)
    type(c_ptr), value :: handle, level_bytes, values_address, control_address
    integer(c_int), value :: parameter_id, spectral, gradient, truncation
    integer(c_size_t), value :: level_length, value_count
    integer(c_int) :: status
    character(c_char), pointer :: characters(:)
    real(c_double), pointer :: values(:)
    integer(c_int), pointer :: controls(:)
    character(:), allocatable :: level_type
    type(grib_packing_controls) :: metadata
    integer :: j

    status = 2_c_int
    if (.not. c_associated(level_bytes) .or. .not. c_associated(values_address)) return
    if (.not. c_associated(control_address)) return
    if (level_length < 1 .or. level_length > 32) return
    if (value_count < 1 .or. value_count > 2147483647_c_size_t) return
    if (spectral < 0 .or. spectral > 1 .or. gradient < 0 .or. gradient > 1) return
    call c_f_pointer(level_bytes, characters, [int(level_length)])
    call c_f_pointer(values_address, values, [int(value_count)])
    call c_f_pointer(control_address, controls, [6])
    if (controls(5) < 0 .or. controls(5) > 1 .or. controls(6) < 0 .or. controls(6) > 1) return
    allocate (character(int(level_length)) :: level_type)
    do j = 1, int(level_length)
      level_type(j:j) = characters(j)
    end do
    metadata%simulation_index = controls(1)
    metadata%linearisation_index = controls(2)
    metadata%log_pressure_bits = controls(3)
    metadata%expression_bits = controls(4)
    metadata%force_geopotential = controls(5) /= 0
    metadata%force_log_pressure = controls(6) /= 0
    status = set_runtime_grib_packing(handle, parameter_id, level_type, spectral /= 0, &
                                      gradient /= 0, values, truncation, metadata)
  end function set_packing_c
end module runtime_grib_packing_policy_c_interface
