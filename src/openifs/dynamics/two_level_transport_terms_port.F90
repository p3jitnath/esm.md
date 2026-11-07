!> Complete ordered LATTEX_DNT field update from the generated transport source.
!! FP64 fields keep their physical units; the caller supplies compatible tendencies
!! and time weights. Columns are first, followed by physical or padded levels.
!! Read-only views may alias unused views. Written and consumed views are disjoint.
module md2asm_two_level_transport_terms
  use iso_fortran_env, only: int32, real64
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  implicit none
  private
  public :: transport_term_controls, transport_field_view, transport_term_fields
  public :: apply_two_level_transport_terms

  !> Named scalar configuration replaces private object offsets.
  type :: transport_term_controls
    integer(int32) :: step=0, first_order_steps=0, current_iteration=0
    logical :: full_predictor_corrector=.false., cheap_corrector=.false.
    logical :: escape=.false., diagnostics=.false., split_interpolation=.false.
    real(real64) :: implicit_time_weight=0.0_real64
  end type

  !> Native contiguous FP64 view; shape is (column capacity, level capacity).
  type :: transport_field_view
    real(real64), pointer, contiguous :: values(:,:)=>null()
  end type

  !> Original field names retain the calculation trace without a foreign ABI.
  type :: transport_term_fields
    type(transport_field_view) :: pxt0,pxt9,pmoy1x,pmixnl
    type(transport_field_view) :: pxsi,pxnlt9,pxt1,pxl0,pxl9,pxlf9,pcxnlt9
    type(transport_field_view) :: psiddhxt1,psiddhxt9,psiddhxl0,pxlf0
  end type
contains
  !> Update one transport term and its optional linear diagnostics.
  !! pitch and levels are active column and physical-level capacities.
  !! first:last is inclusive; first=last+1 denotes empty work.
  !! Transport views contain levels transport_first_level:transport_last_level.
  !! pesgp and pesgm are the original separately rounded time weights.
  !! Every required owner is checked before mutation. Status is 0 on success
  !! and 2 on a shape or configuration refusal; refusal writes no field.
  subroutine apply_two_level_transport_terms(pitch,levels,first,last, &
      transport_first_level,transport_last_level,lagrangian_levels,pesgp,pesgm, &
      stable_extrapolation,c,f,status,escape_override)
    integer(int32), intent(in) :: pitch,levels,first,last
    integer(int32), intent(in) :: transport_first_level,transport_last_level,lagrangian_levels
    real(real64), intent(in) :: pesgp,pesgm
    logical, intent(in) :: stable_extrapolation
    type(transport_term_controls), intent(in) :: c
    type(transport_term_fields), intent(inout) :: f
    integer(int32), intent(out) :: status
    logical, optional, intent(in) :: escape_override
    integer :: i,k,t,transport_levels
    logical :: corrector,escape,early,predictor,need_transport,need_old_nonlinear
    logical :: need_mix,need_saved,need_diagnostic_old
    real(real64) :: h,moy,xsi,previous,base,delta,forcing
    real(real64), volatile :: z,residual
    real(real64) :: a,b,v,w,one_minus_w,linear,old_diagnostic
    status=2
    if(pitch<0.or.pitch>4096.or.levels<0.or.levels>1024)return
    if(first<1.or.first>pitch+1.or.last<0.or.last>pitch)return
    if(transport_first_level<0.or.transport_first_level>1)return
    if(transport_last_level<levels.or.transport_last_level>levels+1)return
    if(c%step<0.or.c%first_order_steps<0.or.c%current_iteration<0)return
    if(.not.ieee_is_finite(c%implicit_time_weight))return
    if(c%implicit_time_weight< -1.0_real64.or.c%implicit_time_weight>1.0_real64)return
    if(.not.ieee_is_finite(pesgp).or..not.ieee_is_finite(pesgm))return
    if(pesgp<0.0_real64.or.pesgp>2.0_real64.or.pesgm<0.0_real64.or.pesgm>2.0_real64)return
    z=1.0_real64+c%implicit_time_weight
    if(levels==0.or.first>last)then
      status=0
      return
    end if
    transport_levels=transport_last_level-transport_first_level+1
    corrector=c%full_predictor_corrector.and.c%current_iteration>0
    predictor=.not.corrector
    escape=c%escape
    if(present(escape_override))escape=escape_override
    early=c%step<=c%first_order_steps.or.escape
    need_transport=lagrangian_levels>=2.and.(predictor.or..not.c%cheap_corrector)
    need_old_nonlinear=predictor.and.(.not.escape.or.(lagrangian_levels>=2.and..not.early))
    need_mix=predictor.and.lagrangian_levels>=2.and..not.early.and.stable_extrapolation
    need_saved=(predictor.and.c%full_predictor_corrector).or. &
      (corrector.and.lagrangian_levels>=2.and..not.c%cheap_corrector)
    need_diagnostic_old=c%diagnostics.and.predictor.and..not.escape
    if(.not.has(f%pmoy1x,pitch,levels))return
    if(.not.has(f%pxsi,pitch,levels))return
    if(.not.has(f%pxt1,pitch,levels))return
    if(predictor.and.lagrangian_levels>=2)then
      if(.not.has(f%pxt0,pitch,levels))return
    end if
    if(corrector.and.lagrangian_levels>=2.and..not.c%cheap_corrector)then
      if(.not.has(f%pxt9,pitch,levels))return
    end if
    if(need_old_nonlinear)then
      if(.not.has(f%pxnlt9,pitch,levels))return
    end if
    if(need_mix)then
      if(.not.has(f%pmixnl,pitch,levels))return
    end if
    if(need_saved)then
      if(.not.has(f%pcxnlt9,pitch,levels))return
    end if
    if(need_transport)then
      if(.not.has(f%pxl9,pitch,transport_levels))return
      if(lagrangian_levels==2.and.c%split_interpolation)then
        if(.not.has(f%pxlf9,pitch,transport_levels))return
      else if(lagrangian_levels>=3)then
        if(.not.has(f%pxl0,pitch,transport_levels))return
      end if
    end if
    if(need_mix.and.lagrangian_levels>=3.and.c%cheap_corrector)then
      if(.not.has(f%pxlf0,pitch,transport_levels))return
    end if
    if(need_diagnostic_old)then
      if(.not.has(f%psiddhxt9,pitch,levels))return
    end if
    if(c%diagnostics.and.lagrangian_levels>=3)then
      if(.not.has(f%psiddhxt1,pitch,levels))return
      if(predictor.and..not.early)then
        if(.not.has(f%psiddhxl0,pitch,transport_levels))return
      end if
    end if
    h=pesgp
    if(c%implicit_time_weight>0.0_real64)h=z
    do k=1,levels
      t=k-transport_first_level+1
      do i=first,last
        moy=f%pmoy1x%values(i,k)
        xsi=f%pxsi%values(i,k)
        a=z*xsi
        residual=moy+a
        if(predictor)then
          if(lagrangian_levels>=2)then
            base=pesgm*moy
            if(early)then
              if(lagrangian_levels==2)then
                if(c%split_interpolation)then
                  f%pxl9%values(i,t)=f%pxl9%values(i,t)+f%pxt0%values(i,k)
                  f%pxlf9%values(i,t)=f%pxlf9%values(i,t)+base
                else
                  a=f%pxl9%values(i,t)+f%pxt0%values(i,k)
                  f%pxl9%values(i,t)=a+base
                end if
              else
                f%pxl0%values(i,t)=f%pxl0%values(i,t)+base
                f%pxl9%values(i,t)=f%pxl9%values(i,t)+f%pxt0%values(i,k)
              end if
              forcing=pesgp*residual
            else
              previous=f%pxnlt9%values(i,k)
              delta=residual-previous
              if(stable_extrapolation)then
                w=f%pmixnl%values(i,k)
                if(lagrangian_levels==2)then
                  if(c%split_interpolation)then
                    f%pxl9%values(i,t)=f%pxl9%values(i,t)+f%pxt0%values(i,k)
                  else
                    base=f%pxt0%values(i,k)+base
                  end if
                  a=base+delta
                  b=w*a
                  one_minus_w=1.0_real64-w
                  a=one_minus_w*base
                  if(c%split_interpolation)then
                    v=f%pxlf9%values(i,t)+b
                    f%pxlf9%values(i,t)=v+a
                  else
                    v=f%pxl9%values(i,t)+b
                    f%pxl9%values(i,t)=v+a
                  end if
                else
                  a=w*delta
                  v=f%pxl0%values(i,t)+base
                  if(c%cheap_corrector)then
                    f%pxl0%values(i,t)=v
                    f%pxlf0%values(i,t)=a
                  else
                    f%pxl0%values(i,t)=v+a
                  end if
                  f%pxl9%values(i,t)=f%pxl9%values(i,t)+f%pxt0%values(i,k)
                end if
                forcing=pesgp*residual
              else
                a=0.5_real64*pesgm
                delta=a*delta
                a=1.5_real64*residual
                b=0.5_real64*previous
                a=a-b
                forcing=pesgp*a
                if(lagrangian_levels==2)then
                  if(c%split_interpolation)then
                    f%pxl9%values(i,t)=f%pxl9%values(i,t)+f%pxt0%values(i,k)
                    a=f%pxlf9%values(i,t)+base
                    f%pxlf9%values(i,t)=a+delta
                  else
                    a=f%pxl9%values(i,t)+f%pxt0%values(i,k)
                    a=a+base
                    f%pxl9%values(i,t)=a+delta
                  end if
                else
                  a=f%pxl0%values(i,t)+base
                  f%pxl0%values(i,t)=a+delta
                  f%pxl9%values(i,t)=f%pxl9%values(i,t)+f%pxt0%values(i,k)
                end if
              end if
            end if
            f%pxt1%values(i,k)=f%pxt1%values(i,k)+forcing
          end if
          if(c%full_predictor_corrector)f%pcxnlt9%values(i,k)=moy
          if(.not.escape)f%pxnlt9%values(i,k)=residual
        else if(lagrangian_levels>=2)then
          if(.not.c%cheap_corrector)then
            previous=f%pxt9%values(i,k)
            a=pesgm*f%pcxnlt9%values(i,k)
            if(lagrangian_levels==2)then
              if(c%split_interpolation)then
                f%pxl9%values(i,t)=f%pxl9%values(i,t)+previous
                f%pxlf9%values(i,t)=f%pxlf9%values(i,t)+a
              else
                b=f%pxl9%values(i,t)+previous
                f%pxl9%values(i,t)=b+a
              end if
            else
              f%pxl0%values(i,t)=f%pxl0%values(i,t)+a
              f%pxl9%values(i,t)=f%pxl9%values(i,t)+previous
            end if
          end if
          forcing=pesgp*residual
          f%pxt1%values(i,k)=f%pxt1%values(i,k)+forcing
        end if
        linear=h*xsi
        f%pxt1%values(i,k)=f%pxt1%values(i,k)-linear
        f%pxsi%values(i,k)=linear
        if(c%diagnostics)then
          if(predictor)then
            if(lagrangian_levels>=3)then
              if(early)then
                a=pesgp*z
                a=a*linear
                f%psiddhxt1%values(i,k)=f%psiddhxt1%values(i,k)+a
              else
                old_diagnostic=f%psiddhxt9%values(i,k)
                a=z*linear
                delta=a-old_diagnostic
                if(stable_extrapolation)then
                  f%psiddhxl0%values(i,t)=f%psiddhxl0%values(i,t)+delta
                  a=pesgp*z
                  a=a*linear
                  f%psiddhxt1%values(i,k)=f%psiddhxt1%values(i,k)+a
                else
                  a=0.5_real64*pesgm
                  delta=a*delta
                  f%psiddhxl0%values(i,t)=f%psiddhxl0%values(i,t)+delta
                  a=1.5_real64*z
                  a=a*linear
                  b=0.5_real64*old_diagnostic
                  a=a-b
                  a=pesgp*a
                  f%psiddhxt1%values(i,k)=f%psiddhxt1%values(i,k)+a
                end if
              end if
            end if
            if(.not.escape)then
              a=z*linear
              f%psiddhxt9%values(i,k)=a
            end if
          else if(lagrangian_levels>=3)then
            a=pesgp*z
            a=a*linear
            f%psiddhxt1%values(i,k)=f%psiddhxt1%values(i,k)+a
          end if
        end if
      end do
    end do
    status=0
  end subroutine

  !> Check capacity without touching an absent or unused field.
  logical function has(view,rows,columns)
    type(transport_field_view), intent(in) :: view
    integer, intent(in) :: rows,columns
    has=.false.
    if(.not.associated(view%values))return
    if(size(view%values,1)<rows.or.size(view%values,2)<columns)return
    has=.true.
  end function
end module
