module absorption_file_setup
  !! Own the coefficient file/read/decode order and selected shortwave continuum branch.
  use iso_c_binding, only: c_int, c_int8_t
  use native_absorption_records
  use absorption_binary_file_service, only: read_coefficient_file
  use longwave_absorption_decoder, only: decode_longwave_absorption_inputs
  use shortwave_absorption_decoder, only: decode_shortwave_absorption_inputs
  use shortwave_absorption_reduction, only: reduce_shortwave_absorption
  implicit none
  private
  public :: read_longwave_absorption_file, read_shortwave_absorption_file, initialize_shortwave_absorption
contains
  function read_longwave_absorption_file(path, output) result(status)
    !! Read the exact RADRRTM file and replace its complete named coefficient owner.
    !! File/error refusals leave output unchanged. The caller owns output lifetime.
    character(*), intent(in) :: path
    type(longwave_absorption_input_record), intent(inout) :: output
    integer(c_int) :: status
    integer(c_int8_t), allocatable, target :: workspace(:)
    status = read_coefficient_file(path, 1454208, workspace)
    if (status /= 0) return
    status = decode_longwave_absorption_inputs(workspace(1:1454208), output)
  end function
  function initialize_shortwave_absorption(bytes, output, continuum) result(status)
    !! Decode original solar coefficients and reduce their source samples in order.
    !! Only continuum zero is supported; source-unwritten fields and tails remain.
    integer(c_int8_t), intent(in) :: bytes(:)
    type(shortwave_absorption_record), intent(inout) :: output
    integer(c_int), intent(in) :: continuum
    integer(c_int) :: status
    status = 2_c_int
    if (continuum /= 0) return
    status = decode_shortwave_absorption_inputs(bytes, output)
    if (status /= 0) return
    status = reduce_shortwave_absorption(output)
  end function
  function read_shortwave_absorption_file(path, output) result(status)
    !! Read the exact RADSRTM file, then decode and reduce with continuum zero.
    character(*), intent(in) :: path
    type(shortwave_absorption_record), intent(inout) :: output
    integer(c_int) :: status
    integer(c_int8_t), allocatable, target :: workspace(:)
    status = read_coefficient_file(path, 1332584, workspace)
    if (status /= 0) return
    status = initialize_shortwave_absorption(workspace(1:1332584), output, 0_c_int)
  end function
end module absorption_file_setup
