!> Complete generated LASSIE linear forecast parent with own Fortran children.
!! Native arrays replace field offsets. Time planes 1 and 2 name current and
!! previous states. Typed child coefficients contain initialized physical data.
module md2asm_linear_forecast_terms
  use iso_fortran_env, only: int32,real64
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use md2asm_spectral_thermal_operators, only: spectral_geopotential,spectral_temperature_pressure_rates
  use md2asm_moist_air_gas_properties, only: moist_air_constants,thermal_constituent,compute_moist_air_properties
  implicit none
  private
  public :: form_linear_forecast_terms
contains
  !> Form pressure expansion, two hydrostatic gradients, moisture and rotation.
  !! All grid fields have shape (column capacity,level capacity,time planes).
  !! Surface fields have shape (column capacity,time planes).
  !! divergence is in 1/s, thermal_rate in K/s and pressure_rate in 1/s.
  !! Wind gradients and their Coriolis corrections retain m/s**2 units.
  !! first:last is inclusive. Every inactive and unused previous-state output
  !! stays unchanged. Stage work is private until all child calls succeed.
  !! two_time_levels selects only time plane1; false also updates plane2.
  !! Optional generic fields are mass fractions with shape(pitch,levels,field).
  !! Only moist_temperature consumes them, with original layout0 or9.
  !! Status0 succeeds;1 denotes private allocation failure;2 refuses a bound
  !! or child condition. No original numerical routine supplies a stage.
  subroutine form_linear_forecast_terms(pitch,levels,first,last,two_time_levels, &
      moist_temperature,implicit_coriolis,finite_elements,integral_bc,derivative_bc, &
      coef,tables,moist_constants,divergence,temperature_l,temperature_m, &
      surface_l,surface_m,wind_u,wind_v,coriolis,thermal_rate,pressure_rate, &
      gradient_l,gradient_m,status,generic_fields,constituents)
    integer(int32), intent(in) :: pitch,levels,first,last
    logical, intent(in) :: two_time_levels,moist_temperature,implicit_coriolis,finite_elements
    integer, intent(in) :: integral_bc,derivative_bc
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(vertical_operator_matrices), intent(in) :: tables
    type(moist_air_constants), intent(in) :: moist_constants
    real(real64), intent(in) :: divergence(:,:,:),temperature_l(:,:,:),temperature_m(:,:,:)
    real(real64), intent(in) :: surface_l(:,:),surface_m(:,:),wind_u(:,:,:),wind_v(:,:,:),coriolis(:)
    real(real64), intent(inout) :: thermal_rate(:,:,:),pressure_rate(:,:),gradient_l(:,:,:),gradient_m(:,:,:)
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: generic_fields(:,:,:)
    type(thermal_constituent), optional, intent(in) :: constituents(:)
    real(real64), allocatable :: work(:,:,:,:),pressure(:,:),gas(:,:)
    real(real64), target :: unused(0)
    real(real64), pointer :: alpha(:),delta(:),metric(:),accumulation(:),mean(:),full_weight(:)
    integer :: ntimes,width,time,i,k,j,allocation_status,layout,map,field
    real(real64) :: product
    integer(int32) :: child_status
    logical :: no_water(6)
    status=2
    if(pitch<1.or.pitch>4096.or.levels<0.or.levels>512)return
    if(first<1.or.first>pitch.or.last<first-1.or.last>pitch)return
    if(first>last)then
      ! Generic property coefficients are prepared even with no selected cells.
      if(moist_temperature)then
        if(.not.present(generic_fields).or..not.present(constituents))return
        allocate(gas(pitch,levels),stat=allocation_status)
        if(allocation_status/=0)then
          status=1
          return
        end if
        layout=0
        if(.not.two_time_levels)layout=9
        no_water=.false.
        call compute_moist_air_properties(moist_constants,pitch,first,last,levels,no_water,child_status, &
          gas_constant=gas,generic_fields=generic_fields,constituents=constituents,layout_code=layout)
        status=child_status
      else
        status=0
      end if
      return
    end if
    ntimes=2
    if(two_time_levels)ntimes=1
    width=last-first+1
    if(size(pressure_rate,1)<pitch.or.size(pressure_rate,2)<ntimes)return
    if(size(thermal_rate,1)<pitch.or.size(thermal_rate,2)<levels.or.size(thermal_rate,3)<ntimes)return
    if(size(gradient_l,1)<pitch.or.size(gradient_l,2)<levels.or.size(gradient_l,3)<ntimes)return
    if(size(gradient_m,1)<pitch.or.size(gradient_m,2)<levels.or.size(gradient_m,3)<ntimes)return
    alpha=>unused;delta=>unused;metric=>unused;accumulation=>unused;mean=>unused;full_weight=>unused
    if(associated(coef%alpha))alpha=>coef%alpha
    if(associated(coef%delta))delta=>coef%delta
    if(associated(coef%metric))metric=>coef%metric
    if(associated(coef%accumulation_weight))accumulation=>coef%accumulation_weight
    if(associated(coef%mean_weight))mean=>coef%mean_weight
    if(associated(coef%full_level_weight))full_weight=>coef%full_level_weight
    if(levels>0)then
      if(size(divergence,1)<pitch.or.size(divergence,2)<levels.or.size(divergence,3)<ntimes)return
      if(size(temperature_l,1)<pitch.or.size(temperature_l,2)<levels.or.size(temperature_l,3)<ntimes)return
      if(size(temperature_m,1)<pitch.or.size(temperature_m,2)<levels.or.size(temperature_m,3)<ntimes)return
      if(size(surface_l,1)<pitch.or.size(surface_l,2)<ntimes)return
      if(size(surface_m,1)<pitch.or.size(surface_m,2)<ntimes)return
      if(size(accumulation)<levels.or.size(delta)<levels)return
      if(finite_elements)then
        if(size(metric)<levels.or.size(full_weight)<levels)return
      else
        if(size(mean)<levels.or.size(alpha)<levels)return
      end if
      if(implicit_coriolis)then
        if(size(wind_u,1)<pitch.or.size(wind_u,2)<levels.or.size(wind_u,3)<ntimes)return
        if(size(wind_v,1)<pitch.or.size(wind_v,2)<levels.or.size(wind_v,3)<ntimes)return
        if(size(coriolis)<pitch)return
      end if
      if(moist_temperature)then
        if(.not.present(generic_fields).or..not.present(constituents))return
        if(size(generic_fields,1)/=pitch.or.size(generic_fields,2)<levels)return
        if(coef%rd/=moist_constants%dry_gas_constant)return
        map=1
        if(.not.two_time_levels)map=4
        do j=1,size(constituents)
          if(.not.constituents(j)%thermal_active)cycle
          field=constituents(j)%field_index_by_layout(map)
          if(field<1.or.field>size(generic_fields,3))return
        end do
      end if
    end if
    allocate(work(levels,width,3,ntimes),pressure(width,ntimes),stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      return
    end if
    do time=1,ntimes
      call spectral_temperature_pressure_rates(transpose(divergence(first:last,1:levels,time)), &
        coef%kappa,coef%thermal_coefficient,coef%pressure_rate_coefficient,accumulation,mean, &
        delta,alpha,metric,full_weight,finite_elements,tables,integral_bc,derivative_bc, &
        work(:,:,1,time),pressure(:,time),child_status)
      if(child_status/=0)then
        status=child_status
        return
      end if
      call spectral_geopotential(transpose(temperature_l(first:last,1:levels,time)), &
        surface_l(first:last,time),coef%rd,coef%geopotential_surface,alpha,delta,metric, &
        finite_elements,tables,integral_bc,derivative_bc,work(:,:,2,time),child_status)
      if(child_status/=0)then
        status=child_status
        return
      end if
      call spectral_geopotential(transpose(temperature_m(first:last,1:levels,time)), &
        surface_m(first:last,time),coef%rd,coef%geopotential_surface,alpha,delta,metric, &
        finite_elements,tables,integral_bc,derivative_bc,work(:,:,3,time),child_status)
      if(child_status/=0)then
        status=child_status
        return
      end if
    end do
    if(moist_temperature)then
      if(.not.present(generic_fields).or..not.present(constituents))return
      allocate(gas(pitch,levels),stat=allocation_status)
      if(allocation_status/=0)then
        status=1
        return
      end if
      layout=0
      if(.not.two_time_levels)layout=9
      no_water=.false.
      call compute_moist_air_properties(moist_constants,pitch,first,last,levels,no_water,child_status, &
        gas_constant=gas,generic_fields=generic_fields,constituents=constituents,layout_code=layout)
      if(child_status/=0)then
        status=child_status
        return
      end if
      do k=1,levels
        do i=first,last
          product=coef%rd*work(k,i-first+1,1,1)
          work(k,i-first+1,1,1)=product/gas(i,k)
          if(.not.two_time_levels)then
            product=coef%rd*work(k,i-first+1,1,2)
            work(k,i-first+1,1,2)=product/gas(i,k)
          end if
        end do
      end do
    end if
    if(implicit_coriolis.and.levels>0)then
      do time=1,ntimes
        do k=1,levels
          do i=first,last
            product=coriolis(i)*wind_v(i,k,time)
            work(k,i-first+1,2,time)=work(k,i-first+1,2,time)-product
            product=coriolis(i)*wind_u(i,k,time)
            work(k,i-first+1,3,time)=work(k,i-first+1,3,time)+product
          end do
        end do
      end do
    end if
    do time=1,ntimes
      pressure_rate(first:last,time)=pressure(:,time)
      do k=1,levels
        do i=first,last
          thermal_rate(i,k,time)=work(k,i-first+1,1,time)
          gradient_l(i,k,time)=work(k,i-first+1,2,time)
          gradient_m(i,k,time)=work(k,i-first+1,3,time)
        end do
      end do
    end do
    status=0
  end subroutine
end module
