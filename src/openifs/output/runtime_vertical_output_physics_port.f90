module runtime_vertical_output_physics_port
  !! Port the generated output calculations with typed binary64 arrays.
  !! Pressure is Pa; temperature and potential temperature are K.
  !! Relative humidity is a fraction. Potential vorticity has units
  !! K m**2 kg**(-1) s**(-1). Only the requested row range is changed.
  use, intrinsic :: iso_fortran_env, only: int32,int64,real64
  use, intrinsic :: iso_c_binding, only: c_double
  use, intrinsic :: ieee_arithmetic, only: ieee_is_negative
  implicit none
  private
  public :: theta_level_pressure,pv_level_pressure,potential_temperature_and_vorticity
  public :: output_relative_humidity,relative_humidity_parameters
  real(real64), parameter :: security=transfer(int(z'3ddb7cdfd9d7bdbb',int64),0.0_real64)

  type :: relative_humidity_parameters
    real(real64) :: saturation_scale,liquid_exponent,ice_exponent,liquid_offset,ice_offset
    real(real64) :: water_temperature,ice_temperature,inverse_phase_interval
    real(real64) :: virtual_temperature_ratio,freezing_temperature
    logical :: water_molar=.false.,sonntag=.false.,ecmwf=.true.
  end type relative_humidity_parameters

  interface
    function public_log(x) bind(C,name="log") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function public_log
    function public_power(x,a) bind(C,name="pow") result(y)
      import c_double
      real(c_double), value :: x,a
      real(c_double) :: y
    end function public_power
    function public_exp(x) bind(C,name="exp") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function public_exp
  end interface

contains

  function theta_level_pressure(first_row,last_row,pressure,theta,target, &
      output_pressure,output_log_pressure) result(status)
    !! PPLTETA: find the source-selected theta interval and interpolate Pa.
    !! The bottom selected level keeps the source bottom-copy rule.
    integer(int32), intent(in) :: first_row,last_row
    real(real64), intent(in) :: pressure(:,:),theta(:,:),target
    real(real64), intent(inout) :: output_pressure(:),output_log_pressure(:)
    integer(int32) :: status
    integer :: width,levels,row,level,selected
    real(real64) :: denominator,difference,value

    status=2_int32
    width=size(pressure,1)
    levels=size(pressure,2)
    if(.not.valid_rows(width,levels,first_row,last_row,2)) return
    if(any(shape(theta)/=shape(pressure))) return
    if(size(output_pressure)/=width.or.size(output_log_pressure)/=width) return
    do row=first_row,last_row
      selected=levels
      do level=levels,1,-1
        if(theta(row,level)<target) selected=level
      end do
      if(selected==levels.or.selected==1) then
        value=pressure(row,selected)
      else
        denominator=theta(row,selected-1)-theta(row,selected)
        if(abs(denominator)<=security) then
          value=pressure(row,selected)
        else
          difference=pressure(row,selected-1)-pressure(row,selected)
          value=target-theta(row,selected)
          difference=difference*value
          difference=difference/denominator
          value=difference+pressure(row,selected)
        end if
      end if
      output_pressure(row)=value
      output_log_pressure(row)=public_log(value)
    end do
    status=0_int32
  end function theta_level_pressure

  function pv_level_pressure(first_row,last_row,pressure,pv,target,cap_pressure, &
      iterations,repeated_search,folding_enabled,coriolis,workspace_limit_bytes, &
      output_pressure,output_log_pressure,output_folding) result(status)
    !! PPLTP: map a signed potential-vorticity surface to pressure in Pa.
    !! iterations is 1:3. A folding search must have a later valid level.
    !! The Coriolis sign includes negative zero. A false folding switch
    !! preserves all output_folding values.
    integer(int32), intent(in) :: first_row,last_row,iterations
    logical, intent(in) :: repeated_search,folding_enabled
    real(real64), intent(in) :: pressure(:,:),pv(:,:),target,cap_pressure,coriolis(:)
    integer(int64), intent(in) :: workspace_limit_bytes
    real(real64), intent(inout) :: output_pressure(:),output_log_pressure(:),output_folding(:)
    integer(int32) :: status
    real(real64), allocatable :: signed_pv(:,:)
    integer :: width,levels,row,level,cap_level,selected,interpolation_level
    integer :: count,search_start,search_iterations,ordinal,j,allocation_status
    real(real64) :: sign_factor,denominator,difference,value,threshold
    logical :: fold_present

    status=2_int32
    width=size(pressure,1)
    levels=size(pressure,2)
    if(.not.valid_rows(width,levels,first_row,last_row,2)) return
    if(any(shape(pv)/=shape(pressure)).or.size(coriolis)/=width) return
    if(size(output_pressure)/=width.or.size(output_log_pressure)/=width.or. &
        size(output_folding)/=width) return
    if(iterations<1.or.iterations>3) return
    if(workspace_limit_bytes<0.or.workspace_limit_bytes>268435456_int64) return
    if(8_int64*int(width,int64)*int(levels,int64)>workspace_limit_bytes) return
    allocate(signed_pv(width,levels),stat=allocation_status)
    if(allocation_status/=0) then
      status=1_int32
      return
    end if
    do level=1,levels
      do row=first_row,last_row
        sign_factor=1.0_real64
        if(ieee_is_negative(coriolis(row))) sign_factor=-1.0_real64
        signed_pv(row,level)=sign_factor*pv(row,level)
      end do
    end do
    do row=first_row,last_row
      cap_level=1
      do while(cap_level<=levels)
        if(pressure(row,cap_level)>=cap_pressure) exit
        cap_level=cap_level+1
      end do
      if(cap_level>levels) return
      if(folding_enabled) then
        search_start=2
        count=levels-1
      else
        search_start=cap_level
        count=levels-cap_level+1
      end if
      search_iterations=0
      if(repeated_search) then
        search_iterations=iterations
        if(count<search_iterations) return
      end if
      ordinal=find_below(signed_pv,row,search_start,count,search_iterations,target)
      if(folding_enabled) then
        selected=ordinal+1
        if(selected>=levels) return
        interpolation_level=max(selected,cap_level)
      else
        selected=ordinal+cap_level-1
        selected=max(selected,cap_level)
        interpolation_level=selected
      end if
      if((folding_enabled.and.interpolation_level==1).or. &
          (.not.folding_enabled.and.selected==cap_level)) then
        value=pressure(row,interpolation_level)
      else if(interpolation_level>=levels+1) then
        value=pressure(row,levels)
      else
        denominator=signed_pv(row,interpolation_level-1)-signed_pv(row,interpolation_level)
        threshold=security
        if(folding_enabled.and.repeated_search.and.denominator<0.0_real64) then
          threshold=-threshold
          denominator=min(denominator,threshold)
        else
          denominator=max(denominator,threshold)
        end if
        difference=pressure(row,selected-1)-pressure(row,selected)
        value=target-signed_pv(row,interpolation_level)
        difference=difference*value
        difference=difference/denominator
        value=difference+pressure(row,interpolation_level)
        value=max(value,pressure(row,cap_level))
      end if
      output_pressure(row)=value
      output_log_pressure(row)=public_log(value)
      if(folding_enabled) then
        count=max(levels-selected,1)
        fold_present=.false.
        do j=0,count-1
          if(signed_pv(row,selected+j)>=target) then
            fold_present=.true.
            exit
          end if
        end do
        output_folding(row)=0.0_real64
        if(fold_present) output_folding(row)=1.0_real64
      end if
    end do
    status=0_int32
  end function pv_level_pressure

  function find_below(values,row,first_level,count,iterations,target) result(ordinal)
    real(real64), intent(in) :: values(:,:),target
    integer, intent(in) :: row,first_level,count,iterations
    integer :: ordinal,offset,last_candidate
    logical :: below

    ordinal=1
    if(count==0) then
      ordinal=0
      return
    end if
    if(iterations>0) then
      last_candidate=count-iterations
      do while(ordinal<=last_candidate)
        below=.true.
        do offset=0,iterations
          if(values(row,first_level+ordinal-1+offset)>=target) then
            below=.false.
            exit
          end if
        end do
        if(below) return
        ordinal=ordinal+1
      end do
      ordinal=count-iterations+1
    end if
    do while(ordinal<=count)
      if(values(row,first_level+ordinal-1)<target) return
      ordinal=ordinal+1
    end do
    ordinal=count+1
  end function find_below

  function potential_temperature_and_vorticity(first_row,last_row,hybrid_b,gravity, &
      reference_pressure,pressure,inverse_dp,kappa,coriolis,vorticity,u,v,temperature, &
      temperature_m,temperature_l,surface_pressure_m,surface_pressure_l, &
      workspace_limit_bytes,output_pv,output_theta) result(status)
    !! GPPVO: retain the seven source scratch fields and all product orders.
    !! hybrid_b has lower bound zero and at least levels+1 entries.
    !! gravity is m/s**2; reference_pressure is Pa. Row inputs use the
    !! complete (width,levels) shape; vectors have width entries.
    integer(int32), intent(in) :: first_row,last_row
    real(real64), intent(in) :: hybrid_b(0:),gravity,reference_pressure
    real(real64), intent(in) :: pressure(:,:),inverse_dp(:,:),kappa(:,:),coriolis(:)
    real(real64), intent(in) :: vorticity(:,:),u(:,:),v(:,:),temperature(:,:)
    real(real64), intent(in) :: temperature_m(:,:),temperature_l(:,:)
    real(real64), intent(in) :: surface_pressure_m(:),surface_pressure_l(:)
    integer(int64), intent(in) :: workspace_limit_bytes
    real(real64), intent(inout) :: output_pv(:,:),output_theta(:,:)
    integer(int32) :: status
    real(real64), allocatable :: scratch(:,:,:)
    real(real64) :: factor,inverse_reference,inverse_temperature,kappa_over_p
    real(real64) :: value,temporary,other,theta_value,half_gravity
    integer :: width,levels,row,level,allocation_status

    status=2_int32
    width=size(pressure,1)
    levels=size(pressure,2)
    if(.not.valid_rows(width,levels,first_row,last_row,2)) return
    if(size(hybrid_b)<levels+1.or.size(coriolis)/=width) return
    if(size(surface_pressure_m)/=width.or.size(surface_pressure_l)/=width) return
    if(any(shape(inverse_dp)/=shape(pressure)).or.any(shape(kappa)/=shape(pressure))) return
    if(any(shape(vorticity)/=shape(pressure)).or.any(shape(u)/=shape(pressure))) return
    if(any(shape(v)/=shape(pressure)).or.any(shape(temperature)/=shape(pressure))) return
    if(any(shape(temperature_m)/=shape(pressure)).or.any(shape(temperature_l)/=shape(pressure))) return
    if(any(shape(output_pv)/=shape(pressure)).or.any(shape(output_theta)/=shape(pressure))) return
    if(workspace_limit_bytes<0.or.workspace_limit_bytes>1073741824_int64) return
    if(56_int64*int(width,int64)*int(levels,int64)>workspace_limit_bytes) return
    allocate(scratch(width,levels,7),stat=allocation_status)
    if(allocation_status/=0) then
      status=1_int32
      return
    end if
    associate(theta_l=>scratch(:,:,1),theta_m=>scratch(:,:,2), &
        pressure_l=>scratch(:,:,3),pressure_m=>scratch(:,:,4), &
        u_vertical=>scratch(:,:,5),v_vertical=>scratch(:,:,6),theta_vertical=>scratch(:,:,7))
      do level=1,levels
        factor=hybrid_b(level-1)+hybrid_b(level)
        factor=factor*0.5_real64
        do row=first_row,last_row
          pressure_m(row,level)=factor*surface_pressure_m(row)
          pressure_l(row,level)=factor*surface_pressure_l(row)
        end do
      end do
      inverse_reference=1.0_real64/reference_pressure
      do level=1,levels
        do row=first_row,last_row
          inverse_temperature=1.0_real64/temperature(row,level)
          kappa_over_p=kappa(row,level)/pressure(row,level)
          value=pressure(row,level)*inverse_reference
          factor=-kappa(row,level)
          value=public_power(value,factor)
          theta_value=temperature(row,level)*value
          output_theta(row,level)=theta_value
          value=temperature_m(row,level)*inverse_temperature
          temporary=kappa_over_p*pressure_m(row,level)
          value=value-temporary
          theta_m(row,level)=theta_value*value
          value=temperature_l(row,level)*inverse_temperature
          temporary=kappa_over_p*pressure_l(row,level)
          value=value-temporary
          theta_l(row,level)=theta_value*value
        end do
      end do
      half_gravity=gravity*0.5_real64
      do level=2,levels-1
        do row=first_row,last_row
          factor=half_gravity*inverse_dp(row,level)
          value=u(row,level+1)-u(row,level-1)
          u_vertical(row,level)=value*factor
          value=v(row,level+1)-v(row,level-1)
          v_vertical(row,level)=value*factor
          value=output_theta(row,level+1)-output_theta(row,level-1)
          theta_vertical(row,level)=value*factor
        end do
      end do
      do row=first_row,last_row
        factor=gravity*inverse_dp(row,1)
        value=u(row,2)-u(row,1)
        u_vertical(row,1)=value*factor
        value=v(row,2)-v(row,1)
        v_vertical(row,1)=value*factor
        value=output_theta(row,2)-output_theta(row,1)
        theta_vertical(row,1)=value*factor
        factor=gravity*inverse_dp(row,levels)
        value=u(row,levels)-u(row,levels-1)
        u_vertical(row,levels)=value*factor
        value=v(row,levels)-v(row,levels-1)
        v_vertical(row,levels)=value*factor
        value=output_theta(row,levels)-output_theta(row,levels-1)
        theta_vertical(row,levels)=value*factor
      end do
      do level=1,levels
        do row=first_row,last_row
          value=vorticity(row,level)+coriolis(row)
          value=-value
          value=value*theta_vertical(row,level)
          temporary=v_vertical(row,level)*theta_l(row,level)
          value=value+temporary
          temporary=u_vertical(row,level)*theta_m(row,level)
          output_pv(row,level)=value-temporary
        end do
      end do
    end associate
    status=0_int32
  end function potential_temperature_and_vorticity

  function output_relative_humidity(first_row,last_row,limits,parameters,humidity, &
      temperature,pressure,output_saturation,output_rh) result(status)
    !! GPRH: mixed liquid/ice saturation and bounded relative humidity.
    !! humidity is kg/kg; output_saturation is Pa; limits=(minimum,maximum).
    integer(int32), intent(in) :: first_row,last_row
    real(real64), intent(in) :: limits(2)
    type(relative_humidity_parameters), intent(in) :: parameters
    real(real64), intent(in) :: humidity(:,:),temperature(:,:),pressure(:,:)
    real(real64), intent(inout) :: output_saturation(:,:),output_rh(:,:)
    integer(int32) :: status
    integer :: width,levels,row,level
    real(real64) :: t,weight,liquid,ice,numerator,denominator,value,one_plus_ratio

    status=2_int32
    width=size(pressure,1)
    levels=size(pressure,2)
    if(.not.valid_rows(width,levels,first_row,last_row,1)) return
    if(parameters%water_molar.or.parameters%sonntag.or..not.parameters%ecmwf) return
    if(any(shape(humidity)/=shape(pressure)).or.any(shape(temperature)/=shape(pressure))) return
    if(any(shape(output_saturation)/=shape(pressure)).or.any(shape(output_rh)/=shape(pressure))) return
    do level=1,levels
      do row=first_row,last_row
        t=temperature(row,level)
        weight=min(parameters%water_temperature,t)
        weight=max(parameters%ice_temperature,weight)
        weight=weight-parameters%ice_temperature
        weight=weight*parameters%inverse_phase_interval
        weight=weight*weight
        weight=min(1.0_real64,weight)
        numerator=t-parameters%freezing_temperature
        numerator=parameters%liquid_exponent*numerator
        denominator=t-parameters%liquid_offset
        value=numerator/denominator
        liquid=public_exp(value)
        numerator=t-parameters%freezing_temperature
        numerator=parameters%ice_exponent*numerator
        denominator=t-parameters%ice_offset
        value=numerator/denominator
        ice=public_exp(value)
        liquid=weight*liquid
        value=1.0_real64-weight
        ice=value*ice
        value=liquid+ice
        value=parameters%saturation_scale*value
        one_plus_ratio=parameters%virtual_temperature_ratio+1.0_real64
        output_saturation(row,level)=one_plus_ratio*value
      end do
      do row=first_row,last_row
        numerator=pressure(row,level)*humidity(row,level)
        one_plus_ratio=parameters%virtual_temperature_ratio+1.0_real64
        numerator=numerator*one_plus_ratio
        denominator=parameters%virtual_temperature_ratio*humidity(row,level)
        denominator=1.0_real64+denominator
        denominator=denominator*output_saturation(row,level)
        value=numerator/denominator
        value=min(value,limits(2))
        output_rh(row,level)=max(limits(1),value)
      end do
    end do
    status=0_int32
  end function output_relative_humidity

  pure logical function valid_rows(width,levels,first_row,last_row,minimum_levels)
    integer, intent(in) :: width,levels,minimum_levels
    integer(int32), intent(in) :: first_row,last_row
    valid_rows=width>=1.and.width<=32769.and.levels>=minimum_levels.and.levels<=512.and. &
      first_row>=1.and.first_row<=width.and.last_row>=first_row.and.last_row<=width
  end function valid_rows
end module runtime_vertical_output_physics_port
