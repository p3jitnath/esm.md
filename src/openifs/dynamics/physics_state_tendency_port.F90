module md2asm_physics_state_tendency
  !! Generated GPMKTEND: convert later states to supplied-interval rates.
  !! Wind rates are m s**(-2), temperature rates K s**(-1), and mass-fraction
  !! rates s**(-1). Other tracers retain their input physical units per s.
  use iso_fortran_env,only:int32,real64
  use md2asm_physics_state_rate_update,only:tracer_state_descriptor
  implicit none
  private
  public::form_physics_state_tendencies
contains
  subroutine form_physics_state_tendencies(pitch,first,last,levels,time_step,components, &
      u,v,t,new_fields,previous_u,previous_v,previous_t,earlier_fields,dynamics_rates,status)
    !! Keep descriptor order, including repeated targets. Each tracer's same
    !! rounded new-minus-earlier rate is stored to both declared outputs.
    integer(int32),intent(in)::pitch,first,last,levels
    real(real64),intent(in)::time_step
    type(tracer_state_descriptor),intent(in)::components(:)
    real(real64),intent(inout)::u(:,:),v(:,:),t(:,:),new_fields(:,:,:),dynamics_rates(:,:,:)
    real(real64),intent(in)::previous_u(:,:),previous_v(:,:),previous_t(:,:),earlier_fields(:,:,:)
    integer(int32),intent(out)::status
    real(real64),volatile::inverse_step
    real(real64)::value
    integer::cell,level,j,field,old_field
    status=2
    if(pitch<1.or.levels<0.or.first<1.or.last>pitch)return
    inverse_step=1.0_real64/time_step
    if(levels==0.or.first>last)then
      status=0
      return
    end if
    if(.not.valid(u).or..not.valid(v).or..not.valid(t))return
    if(.not.valid(previous_u).or..not.valid(previous_v).or..not.valid(previous_t))return
    if(size(new_fields,1)/=pitch.or.size(new_fields,2)<levels)return
    if(size(dynamics_rates,1)/=pitch.or.size(dynamics_rates,2)<levels)return
    if(size(earlier_fields,1)/=pitch.or.size(earlier_fields,2)<levels)return
    do j=1,size(components)
      if(.not.components(j)%new_state_active)cycle
      field=components(j)%new_field;old_field=components(j)%previous_physics_field
      if(field<1.or.field>size(new_fields,3).or.field>size(dynamics_rates,3))return
      if(old_field<1.or.old_field>size(earlier_fields,3))return
    end do
    do level=1,levels
      do cell=first,last
        value=u(cell,level)-previous_u(cell,level)
        u(cell,level)=value*inverse_step
        value=v(cell,level)-previous_v(cell,level)
        v(cell,level)=value*inverse_step
        value=t(cell,level)-previous_t(cell,level)
        t(cell,level)=value*inverse_step
      end do
    end do
    do j=1,size(components)
      if(.not.components(j)%new_state_active)cycle
      field=components(j)%new_field;old_field=components(j)%previous_physics_field
      do level=1,levels
        do cell=first,last
          value=new_fields(cell,level,field)-earlier_fields(cell,level,old_field)
          value=value*inverse_step
          new_fields(cell,level,field)=value
          dynamics_rates(cell,level,field)=value
        end do
      end do
    end do
    status=0
  contains
    logical function valid(a)
      real(real64),intent(in)::a(:,:)
      valid=size(a,1)==pitch.and.size(a,2)>=levels
    end function
  end subroutine
end module md2asm_physics_state_tendency
