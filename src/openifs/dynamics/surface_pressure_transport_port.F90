!> Complete selected generated LATTES continuity and surface-pressure update.
!! Typed field views replace private model field maps. Columns vary first.
module md2asm_surface_pressure_transport
  use iso_fortran_env, only: int32,real64
  use md2asm_vertical_operators, only: vertical_operator_matrices,apply_vertical_operator
  implicit none
  private
  public :: surface_pressure_transport_controls,surface_pressure_transport_fields
  public :: prepare_surface_pressure_transport
  type :: surface_pressure_transport_controls
    logical :: two_time_levels=.true.,finite_elements=.false.
    logical :: full_corrector=.false.,cheap_corrector=.false.,stable_extrapolation=.false.,escape=.false.
    integer(int32) :: continuity_points=3,current_iteration=0,step=0,first_order_steps=0
    integer :: integral_bc=3,derivative_bc=0
    real(real64) :: time_bias=0.0_real64
    real(real64) :: dry_gas_constant,reference_temperature,terrain_coefficient
  end type
  !> Input and output views retain their original complete containing owners.
  !! Wind and history views are (pitch,levels); outgoing and cheap views have
  !! physical levels transport_first_level:transport_last_level.
  !! All vectors have column capacity. Unused views may be unassociated.
  type :: surface_pressure_transport_fields
    real(real64), pointer, contiguous :: wind_u(:,:)=>null(),wind_v(:,:)=>null()
    real(real64), pointer, contiguous :: log_gradient_l(:)=>null(),log_gradient_m(:)=>null()
    real(real64), pointer, contiguous :: current_surface(:)=>null(),saved_surface(:)=>null()
    real(real64), pointer, contiguous :: mixing(:,:)=>null()
    real(real64), pointer, contiguous :: residual_history(:,:)=>null(),nonlinear_history(:,:)=>null()
    real(real64), pointer, contiguous :: new_surface(:)=>null(),linear_buffer(:)=>null(),surface_buffer(:)=>null()
    real(real64), pointer, contiguous :: outgoing(:,:)=>null(),cheap_correction(:,:)=>null()
  end type
contains
  !> Prepare all selected two-level and finite-volume three-level terms.
  !! half_interval is seconds. linear_coefficient(:) holds one time weight
  !! per column, in seconds; pesgp/pesgm are dimensionless. Divergence is 1/s;
  !! bottom_column_divergence is Pa/s and bottom_pressure is Pa.
  !! Orography and its gradients retain their physical source units.
  !! layer_weight and inverse_eta_thickness are initialized vertical data.
  !! Inputs and writable views are disjoint. Unsupported three-level finite
  !! elements refuse before mutation. A later child failure leaves partial
  !! outputs unaccepted. Status0 succeeds;1 refuses allocation;2 refuses
  !! an owner, source branch or vertical-child condition.
  subroutine prepare_surface_pressure_transport(pitch,levels,first,last, &
      transport_first_level,transport_last_level,half_interval,linear_coefficient, &
      pesgp,pesgm,c,terrain_gradient_l,terrain_gradient_m,current_divergence, &
      previous_divergence,bottom_column_divergence,bottom_pressure,terrain, &
      layer_weight,inverse_eta_thickness,tables,f,status)
    integer(int32), intent(in) :: pitch,levels,first,last,transport_first_level,transport_last_level
    real(real64), intent(in) :: half_interval,pesgp,pesgm
    real(real64), intent(in) :: linear_coefficient(:)
    type(surface_pressure_transport_controls), intent(in) :: c
    real(real64), intent(in) :: terrain_gradient_l(:),terrain_gradient_m(:),current_divergence(:),previous_divergence(:)
    real(real64), intent(in) :: bottom_column_divergence(:),bottom_pressure(:),terrain(:)
    real(real64), intent(in) :: layer_weight(:),inverse_eta_thickness(:)
    type(vertical_operator_matrices), intent(in) :: tables
    type(surface_pressure_transport_fields), intent(inout) :: f
    integer(int32), intent(out) :: status
    real(real64), allocatable, volatile :: nonlinear(:,:)
    real(real64), allocatable :: integral_input(:,:),integral_output(:,:),bottom_term(:)
    real(real64), volatile :: z,residual,empty_terrain_factor
    real(real64) :: denominator,terrain_factor,linear_scale,a,b,delta,increment,old_residual
    real(real64) :: base,centred,weighted,correction
    integer :: i,k,t,padded_levels,allocation_status
    integer(int32) :: child_status
    logical :: active,corrector,cheap_corrector,early,need_outgoing,need_surface_buffer,need_terrain
    status=2
    if(pitch<1.or.pitch>4096.or.levels<1.or.levels>512)return
    if(first<1.or.first>pitch+1.or.last<0.or.last>pitch)return
    if(c%finite_elements.and..not.c%two_time_levels)return
    if(transport_first_level<0.or.transport_first_level>1)return
    if(transport_last_level<levels.or.transport_last_level>levels+1)return
    if(c%current_iteration<0.or.c%step<0.or.c%first_order_steps<0)return
    if(first>last)then
      ! Preserve the source scalar preparation even when no column is active.
      z=1.0_real64+c%time_bias
      denominator=c%dry_gas_constant*c%reference_temperature
      empty_terrain_factor=c%terrain_coefficient/denominator
      status=0
      return
    end if
    active=c%continuity_points==2.or.c%continuity_points==3
    corrector=c%full_corrector.and.c%current_iteration>0
    cheap_corrector=c%cheap_corrector.and.c%current_iteration>0
    early=c%escape.or.c%step<=c%first_order_steps
    need_outgoing=active.or.(c%two_time_levels.and.corrector.and..not.cheap_corrector)
    need_surface_buffer=(c%two_time_levels.and. &
      ((.not.corrector.and.active).or.(corrector.and..not.cheap_corrector))).or. &
      (.not.c%two_time_levels.and.active)
    need_terrain=active.or.(c%two_time_levels.and.corrector)
    padded_levels=transport_last_level-transport_first_level+1
    if(.not.matrix_has(f%wind_u,pitch,levels).or..not.matrix_has(f%wind_v,pitch,levels))return
    if(.not.vector_has(f%log_gradient_l,pitch).or..not.vector_has(f%log_gradient_m,pitch))return
    if(.not.vector_has(f%linear_buffer,pitch))return
    if(size(terrain_gradient_l)<pitch.or.size(terrain_gradient_m)<pitch)return
    if(size(linear_coefficient)<pitch)return
    if(size(current_divergence)<pitch.or.size(bottom_column_divergence)<pitch.or.size(bottom_pressure)<pitch)return
    if(size(layer_weight)<levels)return
    if(c%finite_elements.and.size(inverse_eta_thickness)<levels)return
    if(need_terrain.and.size(terrain)<pitch)return
    if(c%two_time_levels.or.active)then
      if(.not.vector_has(f%new_surface,pitch))return
    end if
    if(need_outgoing)then
      if(.not.matrix_has(f%outgoing,pitch,padded_levels))return
    end if
    if(need_surface_buffer)then
      if(.not.vector_has(f%surface_buffer,pitch))return
      if(c%two_time_levels.and..not.corrector)then
        if(.not.vector_has(f%current_surface,pitch))return
      else
        if(.not.vector_has(f%saved_surface,pitch))return
      end if
    end if
    if(c%two_time_levels)then
      if(.not.corrector)then
        if(.not.c%escape)then
          if(.not.matrix_has(f%residual_history,pitch,levels))return
        end if
        if(c%full_corrector)then
          if(.not.matrix_has(f%nonlinear_history,pitch,levels))return
        end if
        if(active.and..not.early.and.c%stable_extrapolation)then
          if(.not.matrix_has(f%mixing,pitch,levels))return
          if(c%cheap_corrector)then
            if(.not.matrix_has(f%cheap_correction,pitch,padded_levels))return
          end if
        end if
      else if(.not.cheap_corrector)then
        if(.not.matrix_has(f%nonlinear_history,pitch,levels))return
      end if
    else if(active)then
      if(size(previous_divergence)<pitch)return
    end if
    allocate(nonlinear(pitch,levels),integral_input(pitch,0:levels+1), &
      integral_output(pitch,levels+1),bottom_term(pitch),stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      return
    end if
    denominator=c%dry_gas_constant*c%reference_temperature
    terrain_factor=c%terrain_coefficient/denominator
    z=1.0_real64+c%time_bias
    linear_scale=pesgp
    if(c%time_bias>0.0_real64)linear_scale=z
    do i=first,last
      f%linear_buffer(i)=linear_coefficient(i)*current_divergence(i)
      a=bottom_column_divergence(i)/bottom_pressure(i)
      b=-half_interval
      bottom_term(i)=b*a
    end do
    do k=1,levels
      do i=first,last
        a=terrain_factor*terrain_gradient_l(i)
        a=f%log_gradient_l(i)+a
        a=f%wind_u(i,k)*a
        b=terrain_factor*terrain_gradient_m(i)
        b=f%log_gradient_m(i)+b
        b=f%wind_v(i,k)*b
        a=a+b
        a=half_interval*a
        nonlinear(i,k)=a+bottom_term(i)
      end do
    end do
    do k=1,levels
      t=k-transport_first_level+1
      do i=first,last
        a=nonlinear(i,k)
        base=f%linear_buffer(i)
        if(c%two_time_levels)then
          b=z*base
          residual=a+b
          if(corrector)then
            if(.not.cheap_corrector)then
              b=pesgm*f%nonlinear_history(i,k)
              f%outgoing(i,t)=f%outgoing(i,t)+b
            end if
            if(c%finite_elements)then
              increment=residual*layer_weight(k)
              increment=increment*inverse_eta_thickness(k)
              increment=increment*pesgp
              integral_input(i,k)=increment
            else
              increment=layer_weight(k)*residual
              increment=increment*pesgp
              f%new_surface(i)=f%new_surface(i)+increment
            end if
          else
            if(active)then
              b=pesgm*a
              if(early)then
                f%outgoing(i,t)=f%outgoing(i,t)+b
                if(c%finite_elements)then
                  increment=residual*layer_weight(k)
                  increment=increment*inverse_eta_thickness(k)
                  increment=increment*pesgp
                else
                  increment=pesgp*layer_weight(k)
                  increment=increment*residual
                end if
              else
                old_residual=f%residual_history(i,k)
                delta=residual-old_residual
                if(c%stable_extrapolation)then
                  weighted=f%mixing(i,k)*delta
                  b=f%outgoing(i,t)+b
                  if(c%cheap_corrector)then
                    f%outgoing(i,t)=b
                    f%cheap_correction(i,t)=weighted
                  else
                    f%outgoing(i,t)=b+weighted
                  end if
                  if(c%finite_elements)then
                    increment=residual*pesgp
                    increment=increment*layer_weight(k)
                    increment=increment*inverse_eta_thickness(k)
                  else
                    increment=pesgp*layer_weight(k)
                    increment=increment*residual
                  end if
                else
                  weighted=0.5_real64*pesgm
                  weighted=weighted*delta
                  b=f%outgoing(i,t)+b
                  f%outgoing(i,t)=b+weighted
                  centred=1.5_real64*residual
                  weighted=0.5_real64*old_residual
                  centred=centred-weighted
                  if(c%finite_elements)then
                    increment=centred*layer_weight(k)
                    increment=increment*inverse_eta_thickness(k)
                    increment=increment*pesgp
                  else
                    increment=pesgp*layer_weight(k)
                    increment=increment*centred
                  end if
                end if
              end if
              if(c%finite_elements)then
                integral_input(i,k)=increment
              else
                f%new_surface(i)=f%new_surface(i)+increment
              end if
            end if
            if(c%full_corrector)f%nonlinear_history(i,k)=a
            if(.not.c%escape)f%residual_history(i,k)=residual
          end if
        else if(active)then
          residual=a+base
          b=pesgm*residual
          b=f%outgoing(i,t)+b
          weighted=pesgm*linear_coefficient(i)
          weighted=weighted*previous_divergence(i)
          f%outgoing(i,t)=b-weighted
          increment=pesgp*layer_weight(k)
          increment=increment*residual
          f%new_surface(i)=f%new_surface(i)+increment
        end if
      end do
    end do
    if(c%finite_elements.and.(corrector.or.active))then
      do i=first,last
        integral_input(i,0)=0.0_real64
        integral_input(i,levels+1)=0.0_real64
      end do
      call apply_vertical_operator(tables,.true.,c%integral_bc,c%derivative_bc, &
        'ITOP','11',pitch,first,last,levels,integral_input,integral_output,child_status)
      if(child_status/=0)then
        status=child_status
        return
      end if
      do i=first,last
        f%new_surface(i)=f%new_surface(i)+integral_output(i,levels+1)
      end do
    end if
    do i=first,last
      if(c%two_time_levels)then
        if(corrector)then
          if(.not.cheap_corrector)then
            a=f%surface_buffer(i)+f%saved_surface(i)
            correction=terrain_factor*terrain(i)
            f%surface_buffer(i)=a+correction
          else
            correction=terrain_factor*terrain(i)
          end if
          f%new_surface(i)=f%new_surface(i)-correction
        else if(active)then
          a=f%surface_buffer(i)+f%current_surface(i)
          correction=terrain_factor*terrain(i)
          f%surface_buffer(i)=a+correction
          f%new_surface(i)=f%new_surface(i)-correction
        end if
        weighted=linear_scale*f%linear_buffer(i)
        f%new_surface(i)=f%new_surface(i)-weighted
        f%linear_buffer(i)=weighted
      else if(active)then
        a=f%surface_buffer(i)+f%saved_surface(i)
        correction=terrain_factor*terrain(i)
        f%surface_buffer(i)=a+correction
        weighted=pesgp*f%linear_buffer(i)
        a=f%new_surface(i)-correction
        f%new_surface(i)=a-weighted
        f%linear_buffer(i)=weighted
      end if
    end do
    status=0
  end subroutine

  logical function matrix_has(a,rows,columns)
    real(real64), pointer, contiguous, intent(in) :: a(:,:)
    integer, intent(in) :: rows,columns
    matrix_has=.false.
    if(.not.associated(a))return
    if(size(a,1)<rows.or.size(a,2)<columns)return
    matrix_has=.true.
  end function
  logical function vector_has(a,rows)
    real(real64), pointer, contiguous, intent(in) :: a(:)
    integer, intent(in) :: rows
    vector_has=.false.
    if(.not.associated(a))return
    if(size(a)<rows)return
    vector_has=.true.
  end function
end module
