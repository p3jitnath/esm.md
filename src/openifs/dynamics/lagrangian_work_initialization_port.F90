module md2asm_lagrangian_work_initialization
  !! Complete GPINISLB copies, clears, scaling and pressure-velocity product.
  !! Fields retain their model units. The scale is dimensionless.
  use iso_fortran_env,only:int32,real64
  implicit none
  private
  public::grid_field_view,lagrangian_initialization_controls,lagrangian_component
  public::lagrangian_bank_slots,lagrangian_source_fields,lagrangian_work_fields,initialize_lagrangian_work
  type::grid_field_view
    real(real64),pointer::values(:,:)=>null()
  end type
  type::lagrangian_initialization_controls
    logical::semi_lagrangian=.false.,two_time_levels=.false.,nonhydrostatic=.false.
    logical::extra_nonhydrostatic=.false.,advect_waves=.false.,finite_elements=.false.,finite_element_waves=.false.
    integer(int32)::iteration=0
  end type
  type::lagrangian_component
    logical::advected=.false.,active=.false.,tendency_required=.false.
    integer(int32)::current_field=0,earlier_field=0,new_field=0
  end type
  type::lagrangian_bank_slots
    integer(int32)::vertical_velocity=0,wave=0,wave_divergence=0,surface_wave=0
  end type
  type::lagrangian_source_fields
    type(grid_field_view)::u,v,temperature,pressure_divergence,vertical_divergence,extra_nonhydrostatic
    type(grid_field_view)::surface_pressure,vertical_velocity,full_pressure
    type(grid_field_view)::wave_zero(3),wave_earlier(3)
  end type
  type::lagrangian_work_fields
    type(grid_field_view)::u,v,temperature,pressure_divergence,vertical_divergence,extra_nonhydrostatic
    type(grid_field_view)::surface_pressure,water(4)
    real(real64),pointer::tracers(:,:,:)=>null(),bank(:,:)=>null()
  end type
contains
  subroutine initialize_lagrangian_work(c,slots,components,water_components,pitch,first,last,levels, &
      scale,linearised_model,tracers,previous,work,status)
    !! Input tracers have shape (cell,level,field) and remain unchanged.
    !! Work views may share the complete bank owner in disjoint field ranges.
    !! All consumed views are checked before the first output is changed.
    type(lagrangian_initialization_controls),intent(in)::c
    type(lagrangian_bank_slots),intent(in)::slots
    type(lagrangian_component),intent(in)::components(:)
    integer(int32),intent(in)::water_components(4),pitch,first,last,levels
    real(real64),intent(in)::scale,tracers(:,:,:)
    logical,intent(in)::linearised_model
    type(lagrangian_source_fields),intent(in)::previous
    type(lagrangian_work_fields),intent(inout)::work
    integer(int32),intent(out)::status
    integer::base_mode,mode,field,j,k,cell,level,rows,slot
    logical::copy_waves
    type(grid_field_view)::wave_source(3)
    status=2
    if(pitch<0.or.pitch>4096.or.levels<1.or.levels>1024)return
    if(first<1.or.first>pitch+1.or.last<first-1.or.last>pitch.or.c%iteration<0)return
    status=0
    if(first>last)return
    status=2
    base_mode=0
    if(.not.c%semi_lagrangian.and.c%iteration==0)base_mode=2
    if(.not.valid_pair(work%u,previous%u,levels,base_mode))return
    if(.not.valid_pair(work%v,previous%v,levels,base_mode))return
    if(.not.valid_pair(work%temperature,previous%temperature,levels,base_mode))return
    if(c%nonhydrostatic)then
      if(.not.valid_pair(work%pressure_divergence,previous%pressure_divergence,levels,base_mode))return
      if(.not.valid_pair(work%vertical_divergence,previous%vertical_divergence,levels,base_mode))return
      if(c%extra_nonhydrostatic)then
        if(.not.valid_pair(work%extra_nonhydrostatic,previous%extra_nonhydrostatic,levels,base_mode))return
      end if
    end if
    if(any(water_components<1).or.any(water_components>size(components)))return
    do j=1,4
      k=water_components(j)
      if(.not.valid_view(work%water(j),levels))return
      if(components(k)%active)then
        field=selected_field(components(k))
        if(.not.valid_tracer_input(field))return
      end if
    end do
    do j=1,size(components)
      call component_action(components(j),mode,field)
      if(mode<0)cycle
      if(.not.associated(work%tracers))return
      if(size(work%tracers,1)/=pitch.or.size(work%tracers,2)<levels)return
      if(components(j)%new_field<1.or.components(j)%new_field>size(work%tracers,3))return
      if(mode/=0)then
        if(.not.valid_tracer_input(field))return
      end if
    end do
    if(.not.valid_pair(work%surface_pressure,previous%surface_pressure,1,base_mode))return
    copy_waves=.not.linearised_model.and.c%nonhydrostatic.and.c%advect_waves.and. &
      c%semi_lagrangian.and.c%finite_elements.and.c%finite_element_waves
    if(.not.linearised_model)then
      if(.not.valid_bank(slots%vertical_velocity,levels))return
      if(.not.valid_view(previous%vertical_velocity,levels))return
      if(.not.valid_view(previous%full_pressure,levels))return
    end if
    if(copy_waves)then
      if(c%two_time_levels)then
        wave_source=previous%wave_zero
      else
        wave_source=previous%wave_earlier
      end if
      do j=1,3
        rows=levels
        if(j==3)rows=1
        select case(j)
        case(1);slot=slots%wave
        case(2);slot=slots%wave_divergence
        case(3);slot=slots%surface_wave
        end select
        if(.not.valid_bank(slot,rows).or..not.valid_view(wave_source(j),rows))return
      end do
    end if
    status=0
    call fill(work%u,previous%u,levels,base_mode)
    call fill(work%v,previous%v,levels,base_mode)
    call fill(work%temperature,previous%temperature,levels,base_mode)
    if(c%nonhydrostatic)then
      call fill(work%pressure_divergence,previous%pressure_divergence,levels,base_mode)
      call fill(work%vertical_divergence,previous%vertical_divergence,levels,base_mode)
      if(c%extra_nonhydrostatic)call fill(work%extra_nonhydrostatic,previous%extra_nonhydrostatic,levels,base_mode)
    end if
    do j=1,4
      k=water_components(j)
      do level=1,levels
        do cell=first,last
          if(components(k)%active)then
            field=selected_field(components(k))
            work%water(j)%values(cell,level)=tracers(cell,level,field)
          else
            work%water(j)%values(cell,level)=0.0_real64
          end if
        end do
      end do
    end do
    do j=1,size(components)
      call component_action(components(j),mode,field)
      if(mode<0)cycle
      do level=1,levels
        do cell=first,last
          if(mode==0)then
            work%tracers(cell,level,components(j)%new_field)=0.0_real64
          else
            work%tracers(cell,level,components(j)%new_field)=tracers(cell,level,field)*scale
          end if
        end do
      end do
    end do
    call fill(work%surface_pressure,previous%surface_pressure,1,base_mode)
    if(linearised_model)return
    do level=1,levels
      do cell=first,last
        work%bank(cell,slots%vertical_velocity+level-1)= &
          previous%vertical_velocity%values(cell,level)*previous%full_pressure%values(cell,level)
      end do
    end do
    if(.not.copy_waves)return
    do j=1,3
      rows=levels
      if(j==3)rows=1
      select case(j)
      case(1);slot=slots%wave
      case(2);slot=slots%wave_divergence
      case(3);slot=slots%surface_wave
      end select
      do level=1,rows
        do cell=first,last
          work%bank(cell,slot+level-1)=wave_source(j)%values(cell,level)
        end do
      end do
    end do
  contains
    logical function valid_view(view,nrows)
      type(grid_field_view),intent(in)::view
      integer,intent(in)::nrows
      valid_view=.false.
      if(.not.associated(view%values))return
      valid_view=size(view%values,1)==pitch.and.size(view%values,2)>=nrows
    end function
    logical function valid_pair(output,input,nrows,action)
      type(grid_field_view),intent(in)::output,input
      integer,intent(in)::nrows,action
      valid_pair=valid_view(output,nrows)
      if(.not.valid_pair)return
      if(action/=0)valid_pair=valid_view(input,nrows)
    end function
    logical function valid_tracer_input(index)
      integer,intent(in)::index
      valid_tracer_input=size(tracers,1)==pitch.and.size(tracers,2)>=levels.and. &
        index>=1.and.index<=size(tracers,3)
    end function
    logical function valid_bank(index,nrows)
      integer,intent(in)::index,nrows
      valid_bank=.false.
      if(.not.associated(work%bank))return
      if(size(work%bank,1)/=pitch)return
      valid_bank=index>=1.and.index+nrows-1<=size(work%bank,2)
    end function
    integer function selected_field(component)
      type(lagrangian_component),intent(in)::component
      selected_field=component%earlier_field
      if(c%semi_lagrangian.and.c%two_time_levels)selected_field=component%current_field
    end function
    subroutine component_action(component,action,index)
      type(lagrangian_component),intent(in)::component
      integer,intent(out)::action,index
      action=-1
      index=0
      if(c%semi_lagrangian)then
        if(component%advected)then
          action=0
        else if(component%tendency_required)then
          action=2
          index=selected_field(component)
        end if
      else if(component%tendency_required)then
        action=0
        if(c%iteration==0)then
          action=2
          index=component%earlier_field
        end if
      end if
    end subroutine
    subroutine fill(output,input,nrows,action)
      type(grid_field_view),intent(inout)::output
      type(grid_field_view),intent(in)::input
      integer,intent(in)::nrows,action
      integer::i,k
      do k=1,nrows
        do i=first,last
          if(action==0)then
            output%values(i,k)=0.0_real64
          else
            output%values(i,k)=input%values(i,k)*scale
          end if
        end do
      end do
    end subroutine
  end subroutine
end module md2asm_lagrangian_work_initialization
