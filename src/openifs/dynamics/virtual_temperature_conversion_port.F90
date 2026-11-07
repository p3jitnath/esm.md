module md2asm_virtual_temperature_conversion
  !! Convert virtual temperature to temperature in kelvin with complete GPRCP.
  use iso_fortran_env,only:int32,real64
  use md2asm_moist_air_gas_properties,only:moist_air_constants,thermal_constituent,compute_moist_air_properties
  implicit none
  private
  public::convert_virtual_to_temperature
contains
  subroutine convert_virtual_to_temperature(c,pitch,first,last,levels,constituents,tracers,temperature,status)
    !! Tracers have shape (cell,level,field) and remain unchanged.
    !! Only the active cells of temperature(cell,level) change.
    type(moist_air_constants),intent(in)::c
    integer(int32),intent(in)::pitch,first,last,levels
    type(thermal_constituent),intent(in)::constituents(:)
    real(real64),intent(in)::tracers(:,:,:)
    real(real64),intent(inout)::temperature(:,:)
    integer(int32),intent(out)::status
    real(real64),allocatable::mixture_gas(:,:)
    real(real64)::product
    integer::allocation_status,cell,level
    status=2
    if(pitch<1.or.levels<0.or.first<1.or.first>pitch+1.or.last<first-1.or.last>pitch)return
    if(size(temperature,1)/=pitch.or.size(temperature,2)<levels)return
    status=0
    if(size(tracers,1)/=pitch.or.size(tracers,2)<levels)then
      status=2
      return
    end if
    allocate(mixture_gas(pitch,levels),stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      return
    end if
    call compute_moist_air_properties(c,pitch,first,last,levels, &
      [.false.,.false.,.false.,.false.,.false.,.false.],status, &
      gas_constant=mixture_gas,generic_fields=tracers,constituents=constituents)
    if(status/=0)return
    do level=1,levels
      do cell=first,last
        product=c%dry_gas_constant*temperature(cell,level)
        temperature(cell,level)=product/mixture_gas(cell,level)
      end do
    end do
  end subroutine
end module md2asm_virtual_temperature_conversion
