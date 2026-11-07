!> Retain the selected source hybrid-coordinate defaults as owned FP64 constants.
module forecast_hybrid_coordinate_defaults
  use iso_c_binding, only: c_int,c_double
  implicit none
  private
  public :: initialize_default_hybrid_coefficients
  real(c_double),parameter :: a19(0:19)=[ &
    0.0_c_double,2000.0_c_double,4000.0_c_double,6046.110595_c_double,8267.92756_c_double, &
    10609.513232_c_double,12851.100169_c_double,14698.498086_c_double,15861.125180_c_double, &
    16116.236610_c_double,15356.924115_c_double,13621.460403_c_double,11101.561987_c_double, &
    8127.144155_c_double,5125.141747_c_double,2549.969411_c_double,783.195032_c_double, &
    0.0_c_double,0.0_c_double,0.0_c_double]
  real(c_double),parameter :: b19(0:19)=[ &
    0.0_c_double,0.0_c_double,0.0_c_double,0.0003389933_c_double,0.0033571866_c_double, &
    0.0130700434_c_double,0.0340771467_c_double,0.0706498323_c_double,0.1259166826_c_double, &
    0.2011954093_c_double,0.2955196487_c_double,0.4054091989_c_double,0.5249322235_c_double, &
    0.6461079479_c_double,0.7596983769_c_double,0.8564375573_c_double,0.9287469142_c_double, &
    0.9729851852_c_double,0.9922814815_c_double,1.0_c_double]
contains
  !> Publish the source defaults without allocating or doing floating-point arithmetic.
  !! ecmwf is canonical0or1. The common one-layer route writes A=[0,0],B=[0,1].
  !! The ECMWF19-layer route copies the complete fixed tables. At137layers,
  !! both A/B arrays retain their incoming bytes and only reference_pressure
  !! changes. Arrays have bounds0:n, A/reference_pressure use Pa and B is
  !! dimensionless. Buffers are disjoint and aligned for FP64.
  !! Return2 changes no output; return0 writes exactly the source-defined words.
  integer(c_int) function initialize_default_hybrid_coefficients(ecmwf,n,a,b,reference_pressure) &
      bind(C,name="md2asm_initialize_default_hybrid_coefficients_fortran") result(status)
    integer(c_int),value,intent(in) :: ecmwf,n
    real(c_double),intent(inout) :: a(0:n),b(0:n),reference_pressure
    integer :: j
    status=2
    if(ecmwf<0.or.ecmwf>1)return
    if(n/=1.and.n/=137)then
      if(ecmwf/=1.or.n/=19)return
    end if
    if(n==1)then
      a(0)=0.0_c_double
      a(1)=0.0_c_double
      b(0)=0.0_c_double
      b(1)=1.0_c_double
    else if(n==19)then
      do j=0,19
        a(j)=a19(j)
        b(j)=b19(j)
      end do
    end if
    reference_pressure=101325.0_c_double
    status=0
  end function
end module forecast_hybrid_coordinate_defaults
