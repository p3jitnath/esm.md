!> Own the standard-atmosphere arrays used by forecast setup.
!! This module composes the accepted pressure child with the native atmosphere
!! tables. It imports no original model state or numerical routine.
module forecast_standard_atmosphere_setup
  use iso_fortran_env, only: int32,int64,real64
  use iso_c_binding, only: c_ptr,c_int,c_f_pointer
  use forecast_standard_atmosphere, only: atmosphere_layers,atmosphere_physical_inputs, &
    initialize_atmosphere_layers,calculate_atmosphere_profile,adjust_postprocessing_atmosphere
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls,compute_hybrid_pressure
  implicit none
  private
  public :: standard_atmosphere_state,atmosphere_vertical_coefficients
  public :: initialize_standard_atmosphere,release_standard_atmosphere
  type :: standard_atmosphere_state
    real(real64),allocatable :: half_pressure(:),full_pressure(:)
    real(real64),allocatable :: geopotential(:),temperature(:),density(:),height(:)
    type(atmosphere_layers) :: reference_tables(2)
    integer(int32) :: extrapolation_level=0
  end type
  type :: atmosphere_vertical_coefficients
    integer(int32) :: levels=0
    type(hybrid_pressure_controls) :: controls
    real(real64),allocatable :: a_half(:),b_half(:),vc(:)
    real(real64),allocatable :: full_a(:),full_b(:),delta_a(:),delta_b(:)
  end type
  interface
    function public_errno_location() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Calculate all six numerical owners and both complete reference tables.
  !! Pressure has units Pa, temperature K, height m and density kg/m**3.
  !! Geopotential has units m**2/s**2. The caller supplies live vertical
  !! coefficients and the parsed extrapolation height in m.
  !! An empty state receives all allocations. A refusal returns2 before writes.
  !! Allocation failure returns3 and releases only these new allocations.
  subroutine initialize_standard_atmosphere(state,physical,vertical,ecmwf,extrapolation_height,status)
    type(standard_atmosphere_state),intent(inout) :: state
    type(atmosphere_physical_inputs),intent(in) :: physical
    type(atmosphere_vertical_coefficients),intent(in) :: vertical
    integer(int32),intent(in) :: ecmwf
    real(real64),intent(in) :: extrapolation_height
    integer(int32),intent(out) :: status
    real(real64),allocatable :: half(:,:),full(:,:)
    real(real64) :: distance,best,value
    integer :: levels,j,allocation_status
    integer(int32) :: child_status,selected
    integer(c_int),pointer :: error_value
    integer(c_int) :: incoming_error
    integer(int64) :: bits
    integer(int32),parameter :: field_index(7)=[1,2,3,4,5,6,7]

    status=2
    levels=vertical%levels
    if(levels<1 .or. levels>256)return
    if(ecmwf<0 .or. ecmwf>1)return
    if(vertical%controls%approximate_mode/=0)return
    if(allocated(state%half_pressure) .or. allocated(state%full_pressure))return
    if(allocated(state%geopotential) .or. allocated(state%temperature))return
    if(allocated(state%density) .or. allocated(state%height))return
    if(.not.allocated(vertical%a_half) .or. .not.allocated(vertical%b_half))return
    if(lbound(vertical%a_half,1)/=0 .or. ubound(vertical%a_half,1)<levels-1)return
    if(lbound(vertical%b_half,1)/=0 .or. ubound(vertical%b_half,1)<levels-1)return
    if(.not.allocated(vertical%delta_b))return
    if(lbound(vertical%delta_b,1)/=0 .or. ubound(vertical%delta_b,1)<levels)return
    if(vertical%controls%finite_elements)then
      if(.not.allocated(vertical%full_a) .or. .not.allocated(vertical%full_b))return
      if(.not.allocated(vertical%delta_a))return
      if(lbound(vertical%full_a,1)/=0 .or. ubound(vertical%full_a,1)<levels)return
      if(lbound(vertical%full_b,1)/=0 .or. ubound(vertical%full_b,1)<levels)return
      if(lbound(vertical%delta_a,1)/=0 .or. ubound(vertical%delta_a,1)<levels)return
    else
      if(.not.allocated(vertical%vc))return
      if(lbound(vertical%vc,1)/=0 .or. ubound(vertical%vc,1)<levels)return
    end if
    bits=transfer(extrapolation_height,bits)
    if(bits<0_int64 .or. bits>transfer(100000.0_real64,bits))return
    if(.not.in_range(physical%gravity,9.0_real64,10.0_real64))return
    if(.not.in_range(physical%dry_gas_constant,270.0_real64,310.0_real64))return
    if(.not.in_range(physical%planet_scale,0.5_real64,2.0_real64))return
    if(.not.in_range(physical%surface_pressure,90000.0_real64,110000.0_real64))return
    if(.not.in_range(vertical%controls%top_pressure,0.001_real64,1.0_real64))return
    if(.not.in_range(vertical%controls%dry_isochoric_heat_capacity,650.0_real64,800.0_real64))return
    call c_f_pointer(public_errno_location(),error_value)
    incoming_error=error_value

    construction:block
      allocate(state%half_pressure(0:levels),stat=allocation_status)
      if(allocation_status/=0)exit construction
      allocate(state%full_pressure(levels),stat=allocation_status)
      if(allocation_status/=0)exit construction
      allocate(state%geopotential(levels),stat=allocation_status)
      if(allocation_status/=0)exit construction
      allocate(state%temperature(levels),stat=allocation_status)
      if(allocation_status/=0)exit construction
      allocate(state%density(levels),stat=allocation_status)
      if(allocation_status/=0)exit construction
      allocate(state%height(levels),stat=allocation_status)
      if(allocation_status/=0)exit construction
      allocate(half(1,0:levels),full(1,levels),stat=allocation_status)
      if(allocation_status/=0)exit construction
      child_status=initialize_atmosphere_layers(state%reference_tables(1),physical,ecmwf)
      if(child_status/=0)exit construction
      half(1,levels)=physical%surface_pressure
      if(vertical%controls%finite_elements)then
        call compute_hybrid_pressure(vertical%controls,1_int32,1_int32,1_int32,int(levels,int32), &
          vertical%a_half,vertical%b_half,half,child_status,number_fields=7_int32,field_index=field_index, &
          full_a=vertical%full_a,full_b=vertical%full_b,delta_a=vertical%delta_a, &
          delta_b=vertical%delta_b,full_pressure=full)
      else
        call compute_hybrid_pressure(vertical%controls,1_int32,1_int32,1_int32,int(levels,int32), &
          vertical%a_half,vertical%b_half,half,child_status,number_fields=7_int32,field_index=field_index, &
          vc=vertical%vc,delta_b=vertical%delta_b,full_pressure=full)
      end if
      if(child_status/=0)exit construction
      state%half_pressure=half(1,:)
      state%full_pressure=full(1,:)
      child_status=calculate_atmosphere_profile(state%temperature,state%geopotential, &
        state%full_pressure,state%reference_tables(1),physical)
      if(child_status/=0)exit construction
      do j=1,levels
        state%height(j)=state%geopotential(j)/physical%gravity
        value=state%full_pressure(j)/physical%dry_gas_constant
        state%density(j)=value/state%temperature(j)
      end do
      selected=int(levels,int32)
      best=1.0e12_real64
      do j=levels,1,-1
        value=state%height(j)-extrapolation_height
        distance=abs(value)
        if(distance<best)selected=int(j,int32)
        best=min(best,distance)
      end do
      child_status=adjust_postprocessing_atmosphere(state%reference_tables(2), &
        state%reference_tables(1),state%full_pressure,physical)
      if(child_status/=0)exit construction
      state%extrapolation_level=selected
      status=0
      deallocate(half,full)
      error_value=incoming_error
      return
    end block construction
    if(allocation_status/=0)then
      status=3
    else
      status=2
    end if
    call release_standard_atmosphere(state)
    if(allocated(half))deallocate(half)
    if(allocated(full))deallocate(full)
    error_value=incoming_error
  end subroutine

  !> Release the six owned arrays once. Reference-table values remain stored.
  subroutine release_standard_atmosphere(state)
    type(standard_atmosphere_state),intent(inout) :: state
    if(allocated(state%half_pressure))deallocate(state%half_pressure)
    if(allocated(state%full_pressure))deallocate(state%full_pressure)
    if(allocated(state%geopotential))deallocate(state%geopotential)
    if(allocated(state%temperature))deallocate(state%temperature)
    if(allocated(state%density))deallocate(state%density)
    if(allocated(state%height))deallocate(state%height)
  end subroutine

  logical function in_range(value,low,high)
    real(real64),intent(in) :: value,low,high
    integer(int64) :: value_bits,low_bits,high_bits
    value_bits=transfer(value,value_bits)
    low_bits=transfer(low,low_bits)
    high_bits=transfer(high,high_bits)
    in_range=value_bits>=low_bits .and. value_bits<=high_bits
  end function
end module forecast_standard_atmosphere_setup
