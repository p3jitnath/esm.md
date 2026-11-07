!> Guarded native selected SUCLDP configuration with explicit upstream inputs.
!! Output is a caller-owned TECLDP record. Pressure is in Pa, gravity in
!! m/s^2, reference temperature in K and the physics interval in seconds.
!! The standard entry consumes19 pressures; the runtime entry consumes
!! the supplied2:256 live levels. Extra pressure elements remain unchanged.
!! Both entries require the first recognized uppercase NAMCLDP group empty.
module prognostic_cloud_parameter_setup_mod
  use iso_fortran_env, only: real64,int32,int64
  use iso_c_binding, only: c_loc,c_intptr_t
  use ieee_arithmetic, only: ieee_round_type,ieee_get_rounding_mode,ieee_nearest,operator(/=)
  use ieee_exceptions, only: ieee_get_flag,ieee_set_flag,ieee_underflow,ieee_inexact
  use yoecldp, only: tecldp
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use prognostic_cloud_parameter_fields_mod, only: prognostic_cloud_parameter_fields
  implicit none
  private
  public :: initialize_prognostic_cloud_parameters,initialize_runtime_prognostic_cloud_parameters
contains
  !> Initialise the selected19-level cloud configuration.
  !! Status0 means success; status2 refuses an unsupported input atomically.
  integer(int32) function initialize_prognostic_cloud_parameters(text,output,pressure,rpi,rg,rtt,scalings,tsphy) result(status)
    character(len=*), intent(in), target :: text
    type(tecldp), intent(inout), target :: output
    real(real64), intent(in), target :: pressure(:),rpi,rg,rtt,scalings(2),tsphy
    integer(int32), target :: levels
    levels=19_int32
    status=initialize_selected(text,output,pressure,levels,rpi,rg,rtt,scalings,tsphy)
  end function initialize_prognostic_cloud_parameters

  !> Initialise the same cloud equations at the actual live level count.
  !! LEVELS is an input int32 scalar in2:256. Output preserves RCLDTOPP
  !! and all source-unwritten bytes. Inputs are readonly and disjoint from it.
  integer(int32) function initialize_runtime_prognostic_cloud_parameters( &
      text,output,pressure,levels,rpi,rg,rtt,scalings,tsphy) result(status)
    character(len=*), intent(in), target :: text
    type(tecldp), intent(inout), target :: output
    real(real64), intent(in), target :: pressure(:),rpi,rg,rtt,scalings(2),tsphy
    integer(int32), intent(in), target :: levels
    status=2_int32
    if (levels<2_int32 .or. levels>256_int32) return
    status=initialize_selected(text,output,pressure,levels,rpi,rg,rtt,scalings,tsphy)
  end function initialize_runtime_prognostic_cloud_parameters

  !> Validate every native owner and control before the first output write.
  integer(int32) function initialize_selected(text,output,pressure,levels,rpi,rg,rtt,scalings,tsphy) result(status)
    character(len=*), intent(in), target :: text
    type(tecldp), intent(inout), target :: output
    real(real64), intent(in), target :: pressure(:),rpi,rg,rtt,scalings(2),tsphy
    integer(int32), intent(in), target :: levels
    integer(int32) :: level
    integer(int64) :: word,output_bytes
    integer(c_intptr_t) :: output_address
    status=2_int32
    if (len(text)<1 .or. len(text)>262144) return
    if (size(pressure)<levels) return
    if (.not.is_contiguous(pressure)) return
    output_bytes=storage_size(output,kind=int64)/8_int64
    output_address=transfer(c_loc(output),output_address)
    if (.not.disjoint(output_address,output_bytes, &
        transfer(c_loc(text(1:1)),output_address),int(len(text),int64))) return
    if (.not.disjoint(output_address,output_bytes, &
        transfer(c_loc(pressure(1)),output_address),8_int64*levels)) return
    if (.not.disjoint(output_address,output_bytes,transfer(c_loc(rpi),output_address),8_int64)) return
    if (.not.disjoint(output_address,output_bytes,transfer(c_loc(rg),output_address),8_int64)) return
    if (.not.disjoint(output_address,output_bytes,transfer(c_loc(rtt),output_address),8_int64)) return
    if (.not.disjoint(output_address,output_bytes,transfer(c_loc(scalings(1)),output_address),16_int64)) return
    if (.not.disjoint(output_address,output_bytes,transfer(c_loc(tsphy),output_address),8_int64)) return
    if (.not.disjoint(output_address,output_bytes,transfer(c_loc(levels),output_address),4_int64)) return
    if (.not.supported_floating_mode()) return
    do level=1,levels
      word=transfer(pressure(level),word)
      if (word<=0_int64 .or. word>=int(z'7ff0000000000000',int64)) return
    end do
    if (transfer(rpi,word)/=int(z'400921fb54442d18',int64)) return
    if (.not.positive_word_in_range(rg,1.0_real64,100.0_real64)) return
    if (.not.positive_word_in_range(rtt,200.0_real64,350.0_real64)) return
    if (.not.positive_word_in_range(scalings(1),0.25_real64,4.0_real64)) return
    if (.not.positive_word_in_range(scalings(2),0.25_real64,4.0_real64)) return
    if (.not.positive_word_in_range(tsphy,1.0_real64,86400.0_real64)) return
    if (.not.positive_word_in_range(output%rcldtopp,0.0_real64,1000000.0_real64)) return
    status=require_empty_physics_group(text,'NAMCLDP')
    if (status/=0_int32) return
    call prognostic_cloud_parameter_fields(output,pressure(:levels),rpi,rg,rtt,scalings,tsphy)
    status=0_int32
  end function initialize_selected

  !> Compare positive finite IEEE64 values through ordered integer words.
  !! This validation raises no arithmetic exception for an invalid NaN.
  logical function positive_word_in_range(value,lower,upper) result(valid)
    real(real64), intent(in) :: value,lower,upper
    integer(int64) :: word,lower_word,upper_word
    word=transfer(value,word)
    lower_word=transfer(lower,lower_word)
    upper_word=transfer(upper,upper_word)
    valid=word>=lower_word .and. word<=upper_word
  end function positive_word_in_range

  !> Require separate complete native owner ranges.
  logical function disjoint(first,first_bytes,second,second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first,second
    integer(int64), intent(in) :: first_bytes,second_bytes
    if (first<=second) then
      separate=second-first>=first_bytes
    else
      separate=first-second>=second_bytes
    end if
  end function disjoint

  !> Require nearest rounding and an exact gradual-underflow result.
  !! Restore only exception flags from this control probe on a refusal.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal,half,subnormal
    logical :: incoming_underflow,incoming_inexact
    supported=.false.
    call ieee_get_rounding_mode(rounding)
    if (rounding/=ieee_nearest) return
    call ieee_get_flag(ieee_underflow,incoming_underflow)
    call ieee_get_flag(ieee_inexact,incoming_inexact)
    smallest_normal=tiny(0.0_real64)
    half=0.5_real64
    subnormal=smallest_normal*half
    supported=transfer(subnormal,0_int64)==int(z'0008000000000000',int64)
    call ieee_set_flag(ieee_underflow,incoming_underflow)
    call ieee_set_flag(ieee_inexact,incoming_inexact)
  end function supported_floating_mode
end module prognostic_cloud_parameter_setup_mod
