module md2asm_two_part_time_filter
  !! Structured GPTF1/GPTF2 with typed, initialized field pairs.
  !! Each field keeps its original physical unit. All weights are unitless.
  use iso_fortran_env,only:int32,real64
  implicit none
  private
  public::filter_field_pair,time_filter_maps,time_filter_controls,apply_time_filter_first,apply_time_filter_second
  type::filter_field_pair
    integer::source=0,destination=0
    logical::enabled=.true.
  end type
  type::time_filter_maps
    type(filter_field_pair)::motion(3),temperature(3),nonhydro(6),gradients(2),surface(3),extra
    integer::air_clear_first=1,air_clear_last=0,surface_clear_first=1,surface_clear_last=0
  end type
  type::time_filter_controls
    logical::two_time_levels=.false.,copy_gradients=.false.,copy_full_state=.false.,nonhydrostatic=.false.
    integer::temperature_fields=0,nonhydrostatic_scheme=0
  end type
contains
  subroutine apply_time_filter_first(c,maps,tracers,enabled,last_step,pitch,first,last,levels, &
      weights,air,surface,tracer,status)
    !! Complete source branch order. Last-step air/surface clears cover every
    !! horizontal cell, while tracer clears retain the active interval.
    type(time_filter_controls),intent(in)::c
    type(time_filter_maps),intent(in)::maps
    type(filter_field_pair),intent(in)::tracers(:)
    logical,intent(in)::enabled,last_step
    integer(int32),intent(in)::pitch,first,last,levels
    real(real64),intent(in)::weights(4)
    real(real64),intent(inout)::air(:,:,:),surface(:,:,:),tracer(:,:,:)
    integer(int32),intent(out)::status
    real(real64),volatile::a,b,ta,tb,temporary
    status=2
    if(.not.valid_extents())return
    status=0
    if(.not.enabled)then
      if(c%copy_gradients)call group(air,maps%gradients,0,0.0_real64,0.0_real64)
    else if(c%two_time_levels)then
      call group(air,maps%motion(:2),0,0.0_real64,0.0_real64)
      if(c%copy_gradients)call group(air,maps%gradients,0,0.0_real64,0.0_real64)
      if(c%copy_full_state)then
        call group(air,maps%temperature,0,0.0_real64,0.0_real64)
        call group(tracer,tracers,0,0.0_real64,0.0_real64)
        if(c%nonhydrostatic)call group(air,maps%nonhydro,0,0.0_real64,0.0_real64)
        call group(surface,maps%surface,0,0.0_real64,0.0_real64,1)
      end if
    else
      if(last_step)then
        call clear_all(air,maps%air_clear_first,maps%air_clear_last,levels,status)
        call clear_all(surface,maps%surface_clear_first,maps%surface_clear_last,1,status)
        call group(tracer,tracers,3,0.0_real64,0.0_real64)
      else
        a=weights(1)
        temporary=weights(1)+weights(2)
        b=1.0_real64-temporary
        ta=0.0_real64
        tb=0.0_real64
        if(size(tracers)>0)then
          ta=weights(3)
          temporary=weights(3)+weights(4)
          tb=1.0_real64-temporary
        end if
        call group(air,maps%motion,1,a,b)
        if(c%temperature_fields>=1)call group(air,maps%temperature,1,a,b)
        if(c%nonhydrostatic)call group(air,maps%nonhydro,1,a,b)
        call group(tracer,tracers,1,ta,tb)
        call group(surface,maps%surface,1,a,b,1)
      end if
    end if
  contains
    logical function valid_extents()
      valid_extents=pitch>=1.and.levels>=0.and.first>=1.and.last<=pitch
      if(.not.valid_extents)return
      valid_extents=size(air,1)==pitch.and.size(air,2)>=levels.and.size(surface,1)==pitch.and. &
        size(surface,2)==1.and.size(tracer,1)==pitch.and.size(tracer,2)>=levels
    end function
    subroutine group(array,pairs,mode,a,b,field_levels)
      real(real64),intent(inout)::array(:,:,:)
      type(filter_field_pair),intent(in)::pairs(:)
      integer,intent(in)::mode
      real(real64),intent(in)::a,b
      integer,intent(in),optional::field_levels
      integer::j,rows
      if(status/=0)return
      rows=levels
      if(present(field_levels))rows=field_levels
      do j=1,size(pairs)
        if(.not.pairs(j)%enabled)cycle
        call apply_field(array,pairs(j),first,last,rows,mode,a,b,status)
        if(status/=0)return
      end do
    end subroutine
  end subroutine

  subroutine apply_time_filter_second(c,maps,tracers,copy_only,pitch,first,last,levels, &
      weights,air,surface,tracer,status)
    !! Complete source contribution/copy stage, including extra NH field.
    type(time_filter_controls),intent(in)::c
    type(time_filter_maps),intent(in)::maps
    type(filter_field_pair),intent(in)::tracers(:)
    logical,intent(in)::copy_only
    integer(int32),intent(in)::pitch,first,last,levels
    real(real64),intent(in)::weights(4)
    real(real64),intent(inout)::air(:,:,:),surface(:,:,:),tracer(:,:,:)
    integer(int32),intent(out)::status
    integer::mode
    status=2
    if(pitch<1.or.levels<0.or.first<1.or.last>pitch)return
    if(size(air,1)/=pitch.or.size(air,2)<levels)return
    if(size(surface,1)/=pitch.or.size(surface,2)/=1)return
    if(size(tracer,1)/=pitch.or.size(tracer,2)<levels)return
    status=0
    if(c%two_time_levels)then
      if(copy_only)call group(air,maps%motion(:2),0,weights(2))
      return
    end if
    mode=2
    if(copy_only)mode=0
    call group(air,maps%motion,mode,weights(2))
    if(c%temperature_fields>=1)call group(air,maps%temperature,mode,weights(2))
    if(c%nonhydrostatic)then
      call group(air,maps%nonhydro,mode,weights(2))
      if(copy_only.and.c%nonhydrostatic_scheme==4)call group(air,[maps%extra],mode,weights(2))
    end if
    call group(tracer,tracers,mode,weights(4))
    call group(surface,maps%surface,mode,weights(2),1)
  contains
    subroutine group(array,pairs,mode,b,field_levels)
      real(real64),intent(inout)::array(:,:,:)
      type(filter_field_pair),intent(in)::pairs(:)
      integer,intent(in)::mode
      real(real64),intent(in)::b
      integer,intent(in),optional::field_levels
      integer::j,rows
      if(status/=0)return
      rows=levels
      if(present(field_levels))rows=field_levels
      do j=1,size(pairs)
        if(.not.pairs(j)%enabled)cycle
        call apply_field(array,pairs(j),first,last,rows,mode,0.0_real64,b,status)
        if(status/=0)return
      end do
    end subroutine
  end subroutine

  subroutine apply_field(array,pair,first,last,rows,mode,a,b,status)
    real(real64),intent(inout)::array(:,:,:)
    type(filter_field_pair),intent(in)::pair
    integer,intent(in)::first,last,rows,mode
    real(real64),intent(in)::a,b
    integer(int32),intent(inout)::status
    integer::cell,level
    real(real64)::source_value,target_value,product
    if(status/=0.or.rows<=0.or.first>last)return
    if(pair%destination<1.or.pair%destination>size(array,3))then
      status=2
      return
    end if
    if(mode/=3)then
      if(pair%source<1.or.pair%source>size(array,3))then
        status=2
        return
      end if
    end if
    do level=1,rows
      do cell=first,last
        if(mode==3)then
          array(cell,level,pair%destination)=0.0_real64
        else
          source_value=array(cell,level,pair%source)
          if(mode==0)then
            array(cell,level,pair%destination)=source_value
          else if(mode==1)then
            target_value=a*array(cell,level,pair%destination)
            product=b*source_value
            array(cell,level,pair%destination)=target_value+product
          else
            product=b*source_value
            array(cell,level,pair%destination)=array(cell,level,pair%destination)+product
          end if
        end if
      end do
    end do
  end subroutine

  subroutine clear_all(array,first_field,last_field,rows,status)
    real(real64),intent(inout)::array(:,:,:)
    integer,intent(in)::first_field,last_field,rows
    integer(int32),intent(inout)::status
    if(status/=0.or.last_field<first_field)return
    if(rows==0)return
    if(first_field<1.or.last_field>size(array,3))then
      status=2
      return
    end if
    array(:,1:rows,first_field:last_field)=0.0_real64
  end subroutine
end module md2asm_two_part_time_filter
