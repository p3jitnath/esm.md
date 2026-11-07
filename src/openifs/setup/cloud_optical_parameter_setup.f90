!> Admit native selected cloud-optical parameters before their field stores.
module cloud_optical_parameter_setup_mod
  use iso_fortran_env, only: int32,int64,real64
  use iso_c_binding, only: c_loc,c_intptr_t
  use ieee_arithmetic, only: ieee_round_type,ieee_get_rounding_mode,ieee_nearest,operator(/=)
  use ieee_exceptions, only: ieee_get_flag,ieee_set_flag,ieee_underflow,ieee_inexact
  use yoerad, only: terad
  use yoesw, only: teswrt
  use cloud_optical_parameter_fields_mod, only: &
    cloud_optical_550_parameter_record,initialize_cloud_optical_fields,initialize_cloud_optical_550_fields
  implicit none
  private
  public :: initialize_cloud_optical_parameters,initialize_runtime_cloud_optical_parameters
  public :: cloud_optical_550_parameter_record
contains
  !> Set the selected cloud optics for fourteen allocated and six active bands.
  !! RADIATION and SHORTWAVE are complete native TERAD and TESWRT records.
  !! OPTICAL550 owns four scalar coefficients and a two-element coefficient
  !! vector at a wavelength of 550 nm. Every output is caller-owned and
  !! separate from the others and from the readonly int32 controls.
  !! Source-unwritten members, descriptors and padding remain incoming.
  !! LEVELS is 19 for this original selected specialization.
  !! Return 0 after both children or 2 before mutation on unsupported input.
  !! No owner is allocated or released and no original module data are read.
  integer(int32) function initialize_cloud_optical_parameters( &
      radiation,shortwave,optical550,allocated_shortwave_bands,active_shortwave_bands,levels) result(status)
    type(terad), intent(inout), target :: radiation
    type(teswrt), intent(inout), target :: shortwave
    type(cloud_optical_550_parameter_record), intent(inout), target :: optical550
    integer(int32), intent(in), target :: allocated_shortwave_bands,active_shortwave_bands,levels
    status=2_int32
    if (levels/=19_int32) return
    status=initialize_selected(radiation,shortwave,optical550,allocated_shortwave_bands,active_shortwave_bands,levels)
  end function

  !> Set the selected cloud optics for fourteen allocated and six active bands.
  !! RADIATION and SHORTWAVE are complete native TERAD and TESWRT records.
  !! OPTICAL550 owns four scalar coefficients and a two-element coefficient
  !! vector at a wavelength of 550 nm. Every output is caller-owned and
  !! separate from the others and from the readonly int32 controls.
  !! Source-unwritten members, descriptors and padding remain incoming.
  !! LEVELS is the live vertical count from 1 through 256. Only the cloud
  !! overlap pair changes for counts 19, 31 and the other supported counts.
  !! Return 0 after both children or 2 before mutation on unsupported input.
  !! No owner is allocated or released and no original module data are read.
  integer(int32) function initialize_runtime_cloud_optical_parameters( &
      radiation,shortwave,optical550,allocated_shortwave_bands,active_shortwave_bands,levels) result(status)
    type(terad), intent(inout), target :: radiation
    type(teswrt), intent(inout), target :: shortwave
    type(cloud_optical_550_parameter_record), intent(inout), target :: optical550
    integer(int32), intent(in), target :: allocated_shortwave_bands,active_shortwave_bands,levels
    status=2_int32
    status=initialize_selected(radiation,shortwave,optical550,allocated_shortwave_bands,active_shortwave_bands,levels)
  end function

  !> Check compiler-owned spans and selected dimensions before any write.
  integer(int32) function initialize_selected( &
      radiation,shortwave,optical550,allocated_shortwave_bands,active_shortwave_bands,levels) result(status)
    type(terad), intent(inout), target :: radiation
    type(teswrt), intent(inout), target :: shortwave
    type(cloud_optical_550_parameter_record), intent(inout), target :: optical550
    integer(int32), intent(in), target :: allocated_shortwave_bands,active_shortwave_bands,levels
    integer(c_intptr_t) :: addresses(6)
    integer(int64) :: lengths(6)
    integer :: first,second
    status=2_int32
    if (allocated_shortwave_bands/=14_int32) return
    if (active_shortwave_bands/=6_int32) return
    if (levels<1_int32 .or. levels>256_int32) return
    addresses(1)=transfer(c_loc(radiation),addresses(1))
    addresses(2)=transfer(c_loc(shortwave),addresses(2))
    addresses(3)=transfer(c_loc(optical550),addresses(3))
    addresses(4)=transfer(c_loc(allocated_shortwave_bands),addresses(4))
    addresses(5)=transfer(c_loc(active_shortwave_bands),addresses(5))
    addresses(6)=transfer(c_loc(levels),addresses(6))
    lengths(1)=storage_size(radiation,kind=int64)/8_int64
    lengths(2)=storage_size(shortwave,kind=int64)/8_int64
    lengths(3)=storage_size(optical550,kind=int64)/8_int64
    lengths(4:6)=4_int64
    do first=1,3
      do second=first+1,6
        if (.not.disjoint(addresses(first),lengths(first),addresses(second),lengths(second))) return
      end do
    end do
    if (.not.supported_floating_mode()) return
    call initialize_cloud_optical_fields(radiation,shortwave,levels)
    call initialize_cloud_optical_550_fields(optical550)
    status=0_int32
  end function

  !> Check native storage without constructing a private target layout.
  logical function disjoint(first,first_bytes,second,second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first,second
    integer(int64), intent(in) :: first_bytes,second_bytes
    if (first<=second) then
      separate=second-first>=first_bytes
    else
      separate=first-second>=second_bytes
    end if
  end function

  !> Require nearest rounding and gradual underflow without changing flags.
  !! The launcher establishes the complete target floating-point contract.
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
  end function
end module
