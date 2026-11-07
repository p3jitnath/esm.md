module md2asm_geopotential_gradients
  !! Port generated GPGRGEO. Geopotential is in m**2 s**(-2).
  !! Horizontal derivatives retain the caller's coordinate units.
  use iso_fortran_env,only:int32,int64,real64
  use md2asm_vertical_operators,only:vertical_operator_matrices,apply_vertical_operator
  implicit none
  private
  public::compute_geopotential_gradients
contains
  subroutine compute_geopotential_gradients(pitch,first,last,levels,finite_elements, &
      pressure_correction,tables,integral_bc,derivative_bc,thermal,g_x,g_y,delta_log, &
      delta_x,delta_y,surface_x,surface_y,half_x,half_y,full_x,full_y,status, &
      alpha,alpha_x,alpha_y,metric,pressure_ratio,pressure_derivative_x, &
      pressure_derivative_y,nh_output_x,nh_output_y)
    !! Copy surface derivatives, descend over half levels, then form full levels.
    !!
    !! half arrays have bounds(:,0:levels). All other fields have shape
    !! (pitch,levels), except the horizontal surface vectors and metric(level).
    !! Optional local correction outputs observe the computed terms only.
    integer(int32),intent(in)::pitch,first,last,levels
    logical,intent(in)::finite_elements,pressure_correction
    type(vertical_operator_matrices),intent(in)::tables
    integer,intent(in)::integral_bc,derivative_bc
    real(real64),intent(in)::thermal(:,:),g_x(:,:),g_y(:,:),delta_log(:,:)
    real(real64),intent(in)::delta_x(:,:),delta_y(:,:),surface_x(:),surface_y(:)
    real(real64),intent(inout)::half_x(:,0:),half_y(:,0:),full_x(:,:),full_y(:,:)
    integer(int32),intent(out)::status
    real(real64),intent(in),optional::alpha(:,:),alpha_x(:,:),alpha_y(:,:),metric(:)
    real(real64),intent(in),optional::pressure_ratio(:,:),pressure_derivative_x(:,:),pressure_derivative_y(:,:)
    real(real64),intent(inout),optional::nh_output_x(:,:),nh_output_y(:,:)
    real(real64),allocatable,target::workspace(:)
    real(real64),pointer::nhx(:,:),nhy(:,:),pinx(:,:),piny(:,:),intx(:,:),inty(:,:)
    real(real64)::negative_thermal,xvalue,yvalue
    integer::level,cell,allocation_status
    integer(int64)::field_words,input_words,integral_words,total_words,offset
    status=2
    if(pitch<1.or.levels<0.or.first<1.or.last>pitch)return
    if(first>last)then
      status=0
      return
    end if
    if(size(half_x,1)/=pitch.or.ubound(half_x,2)<levels)return
    if(size(half_y,1)/=pitch.or.ubound(half_y,2)<levels)return
    if(size(surface_x)<pitch.or.size(surface_y)<pitch)return
    if(levels==0)then
      half_x(first:last,0)=surface_x(first:last)
      half_y(first:last,0)=surface_y(first:last)
      status=0
      return
    end if
    if(.not.valid(thermal).or..not.valid(g_x).or..not.valid(g_y).or..not.valid(delta_log))return
    if(.not.valid(delta_x).or..not.valid(delta_y).or..not.valid(full_x).or..not.valid(full_y))return
    if(pressure_correction)then
      if(.not.present(pressure_ratio).or..not.present(pressure_derivative_x).or..not.present(pressure_derivative_y))return
      if(.not.valid(pressure_ratio).or..not.valid(pressure_derivative_x).or..not.valid(pressure_derivative_y))return
    end if
    if(present(nh_output_x))then
      if(.not.valid(nh_output_x))return
    end if
    if(present(nh_output_y))then
      if(.not.valid(nh_output_y))return
    end if
    field_words=int(pitch,int64)*levels
    if(finite_elements)then
      if(.not.present(metric))return
      if(size(metric)<levels)return
      input_words=int(pitch,int64)*(levels+2)
      integral_words=int(pitch,int64)*(levels+1)
      total_words=6_int64*int(pitch,int64)*(levels+1)
    else
      if(.not.present(alpha).or..not.present(alpha_x).or..not.present(alpha_y))return
      if(.not.valid(alpha).or..not.valid(alpha_x).or..not.valid(alpha_y))return
      total_words=2_int64*field_words
    end if
    allocate(workspace(total_words),stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      return
    end if
    nhx(1:pitch,1:levels)=>workspace(1:field_words)
    nhy(1:pitch,1:levels)=>workspace(field_words+1:2*field_words)
    do level=1,levels
      do cell=first,last
        xvalue=0.0_real64;yvalue=0.0_real64
        if(pressure_correction)then
          negative_thermal=-thermal(cell,level)
          xvalue=negative_thermal*pressure_derivative_x(cell,level)
          yvalue=negative_thermal*pressure_derivative_y(cell,level)
        end if
        nhx(cell,level)=xvalue;nhy(cell,level)=yvalue
        if(present(nh_output_x))nh_output_x(cell,level)=xvalue
        if(present(nh_output_y))nh_output_y(cell,level)=yvalue
      end do
    end do
    half_x(first:last,levels)=surface_x(first:last)
    half_y(first:last,levels)=surface_y(first:last)
    do level=levels,1,-1
      do cell=first,last
        xvalue=weighted_value(delta_log(cell,level),delta_x(cell,level),g_x(cell,level), &
          nhx(cell,level),half_x(cell,level),cell,level)
        yvalue=weighted_value(delta_log(cell,level),delta_y(cell,level),g_y(cell,level), &
          nhy(cell,level),half_y(cell,level),cell,level)
        half_x(cell,level-1)=xvalue;half_y(cell,level-1)=yvalue
      end do
    end do
    if(.not.finite_elements)then
      do level=1,levels
        do cell=first,last
          full_x(cell,level)=weighted_value(alpha(cell,level),alpha_x(cell,level),g_x(cell,level), &
            nhx(cell,level),half_x(cell,level),cell,level)
          full_y(cell,level)=weighted_value(alpha(cell,level),alpha_y(cell,level),g_y(cell,level), &
            nhy(cell,level),half_y(cell,level),cell,level)
        end do
      end do
    else
      offset=2*field_words
      pinx(1:pitch,0:levels+1)=>workspace(offset+1:offset+input_words);offset=offset+input_words
      piny(1:pitch,0:levels+1)=>workspace(offset+1:offset+input_words);offset=offset+input_words
      intx(1:pitch,1:levels+1)=>workspace(offset+1:offset+integral_words);offset=offset+integral_words
      inty(1:pitch,1:levels+1)=>workspace(offset+1:offset+integral_words)
      do level=1,levels
        do cell=first,last
          pinx(cell,level)=integrand(delta_x(cell,level),g_x(cell,level),nhx(cell,level),cell,level)
          piny(cell,level)=integrand(delta_y(cell,level),g_y(cell,level),nhy(cell,level),cell,level)
        end do
      end do
      pinx(first:last,0)=0.0_real64;piny(first:last,0)=0.0_real64
      pinx(first:last,levels+1)=0.0_real64;piny(first:last,levels+1)=0.0_real64
      call apply_vertical_operator(tables,.true.,integral_bc,derivative_bc,'IBOT','11', &
        int(pitch),int(first),int(last),int(levels),pinx,intx,status)
      if(status/=0)return
      call apply_vertical_operator(tables,.true.,integral_bc,derivative_bc,'IBOT','11', &
        int(pitch),int(first),int(last),int(levels),piny,inty,status)
      if(status/=0)return
      do level=1,levels
        do cell=first,last
          full_x(cell,level)=intx(cell,level)+surface_x(cell)
          full_y(cell,level)=inty(cell,level)+surface_y(cell)
        end do
      end do
    end if
    status=0
  contains
    logical function valid(a)
      real(real64),intent(in)::a(:,:)
      valid=size(a,1)==pitch.and.size(a,2)>=levels
    end function
    function weighted_value(weight,derivative,gradient,nh,lower,cell,level) result(value)
      real(real64),intent(in)::weight,derivative,gradient,nh,lower
      integer,intent(in)::cell,level
      real(real64)::value,a,b,c
      if(pressure_correction)then
        c=gradient+nh
        a=weight*pressure_ratio(cell,level)
        a=a*c
        b=derivative*pressure_ratio(cell,level)
        b=b*thermal(cell,level)
      else
        a=weight*gradient
        b=derivative*thermal(cell,level)
      end if
      value=lower+a
      value=value+b
    end function
    function integrand(derivative,gradient,nh,cell,level) result(value)
      real(real64),intent(in)::derivative,gradient,nh
      integer,intent(in)::cell,level
      real(real64)::value,a,b,c
      a=-delta_log(cell,level)
      if(pressure_correction)then
        a=a*pressure_ratio(cell,level)
        c=gradient+nh
        a=a*c
        b=derivative*pressure_ratio(cell,level)
        b=b*thermal(cell,level)
      else
        a=a*gradient
        b=derivative*thermal(cell,level)
      end if
      a=a-b
      value=a*metric(level)
    end function
  end subroutine
end module md2asm_geopotential_gradients
