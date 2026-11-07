!> Structured ports of the generated runtime SIGAM and SITNU calculations.
!! Geometry and physical constants arrive as typed values and named arrays.
!! Finite-element integration uses the ported generated vertical operator.
module md2asm_spectral_thermal_operators
  use, intrinsic :: iso_fortran_env, only : int32,int64,real64
  use md2asm_vertical_operators, only : vertical_operator_matrices,apply_vertical_operator
  implicit none
  private
  public :: spectral_geopotential, spectral_temperature_pressure_rates
contains

  !> Form hydrostatic geopotential with the original descending accumulation.
  !! temperature(level,column) is K; RD is J/(kg K); output is J/kg.
  !! surface_coefficient and logarithmic_pressure retain their source units.
  !! alpha,delta and metric contain the already initialized source coefficients.
  !! gamma preserves cells outside the active temperature shape.
  subroutine spectral_geopotential(temperature,logarithmic_pressure,rd, &
      surface_coefficient,alpha,delta,metric,finite_elements,tables, &
      integral_bc,derivative_bc,gamma,status)
    real(real64), intent(in) :: temperature(:,:),logarithmic_pressure(:)
    real(real64), intent(in) :: rd,surface_coefficient,alpha(:),delta(:),metric(:)
    logical, intent(in) :: finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc,derivative_bc
    real(real64), intent(inout) :: gamma(:,:)
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: input(:,:),integral(:,:)
    integer :: levels,columns,column,level,allocation_status
    integer(int64) :: first_count,total_count
    real(real64) :: accumulated,next_accumulated,surface,product,value,minus_rd
    status=2_int32
    levels=size(temperature,1);columns=size(temperature,2)
    if (levels == 0 .or. columns == 0) then
      status=0_int32
      return
    end if
    if (levels > 512) return
    if (size(gamma,1) < levels .or. size(gamma,2) < columns) return
    if (size(logarithmic_pressure) < columns) return
    if (size(delta) < levels) return
    if (.not. finite_elements .and. size(alpha) < levels) return
    if (finite_elements) then
      if (size(metric) < levels) return
      first_count=int(columns,int64)*int(levels+2,int64)
      total_count=int(columns,int64)*int(2*levels+3,int64)
      allocate(workspace(total_count),stat=allocation_status)
      if (allocation_status /= 0) return
      input(1:columns,0:levels+1)=>workspace(1:first_count)
      integral(1:columns,1:levels+1)=>workspace(first_count+1:total_count)
      minus_rd=-rd
      do column=1,columns
        input(column,0)=0.0_real64
      end do
      do level=1,levels
        do column=1,columns
          product=minus_rd*temperature(level,column)
          product=product*delta(level)
          product=product*metric(level)
          input(column,level)=product
        end do
      end do
      do column=1,columns
        input(column,levels+1)=0.0_real64
      end do
      call apply_vertical_operator(tables,.true.,integral_bc,derivative_bc, &
        'IBOT','11',columns,1,columns,levels,input,integral,status)
      if (status == 0_int32) then
        do column=1,columns
          surface=logarithmic_pressure(column)*surface_coefficient
          do level=1,levels
            gamma(level,column)=integral(column,level)+surface
          end do
        end do
      end if
      deallocate(workspace)
    else
      do column=1,columns
        accumulated=0.0_real64
        surface=logarithmic_pressure(column)*surface_coefficient
        do level=levels,1,-1
          product=rd*temperature(level,column)
          product=product*delta(level)
          next_accumulated=accumulated+product
          product=alpha(level)*rd
          product=product*temperature(level,column)
          value=accumulated+product
          value=value+surface
          gamma(level,column)=value
          accumulated=next_accumulated
        end do
      end do
      status=0_int32
    end if
  end subroutine spectral_geopotential

  !> Form positive temperature and logarithmic-pressure rate operators.
  !! divergence(level,column) is s**(-1); thermal_rate is K/s.
  !! pressure_rate(column) is s**(-1). Coefficients are supplied without recalculation.
  !! The caller supplies independent input, output and coefficient owners.
  subroutine spectral_temperature_pressure_rates(divergence,kappa, &
      thermal_coefficient,surface_coefficient,accumulation_weight,mean_weight, &
      delta,alpha,metric,full_level_weight,finite_elements,tables, &
      integral_bc,derivative_bc,thermal_rate,pressure_rate,status)
    real(real64), intent(in) :: divergence(:,:),kappa,thermal_coefficient,surface_coefficient
    real(real64), intent(in) :: accumulation_weight(:),mean_weight(:),delta(:),alpha(:)
    real(real64), intent(in) :: metric(:),full_level_weight(:)
    logical, intent(in) :: finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc,derivative_bc
    real(real64), intent(inout) :: thermal_rate(:,:),pressure_rate(:)
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: input(:,:),integral(:,:)
    integer :: levels,columns,column,level,allocation_status
    integer(int64) :: first_count,total_count
    real(real64) :: factor,accumulated,old_accumulated,product,local,value,reciprocal
    status=2_int32
    levels=size(divergence,1);columns=size(divergence,2)
    if (columns == 0) then
      status=0_int32
      return
    end if
    if (levels > 512 .or. size(pressure_rate) < columns) return
    if (size(thermal_rate,1) < levels .or. size(thermal_rate,2) < columns) return
    if (levels == 0) then
      value=0.0_real64*surface_coefficient
      do column=1,columns
        pressure_rate(column)=value
      end do
      status=0_int32
      return
    end if
    if (size(accumulation_weight) < levels) return
    factor=kappa*thermal_coefficient
    if (finite_elements) then
      if (size(metric) < levels .or. size(full_level_weight) < levels) return
      first_count=int(columns,int64)*int(levels+2,int64)
      total_count=int(columns,int64)*int(2*levels+3,int64)
      allocate(workspace(total_count),stat=allocation_status)
      if (allocation_status /= 0) return
      input(1:columns,0:levels+1)=>workspace(1:first_count)
      integral(1:columns,1:levels+1)=>workspace(first_count+1:total_count)
      do column=1,columns
        input(column,0)=0.0_real64
        input(column,levels+1)=0.0_real64
        do level=1,levels
          product=divergence(level,column)*accumulation_weight(level)
          product=product*metric(level)
          input(column,level)=product
        end do
      end do
      call apply_vertical_operator(tables,.true.,integral_bc,derivative_bc, &
        'ITOP','11',columns,1,columns,levels,input,integral,status)
      if (status == 0_int32) then
        do column=1,columns
          do level=1,levels
            reciprocal=1.0_real64/full_level_weight(level)
            product=factor*integral(column,level)
            value=product*reciprocal
            thermal_rate(level,column)=value
          end do
          pressure_rate(column)=integral(column,levels+1)*surface_coefficient
        end do
      end if
      deallocate(workspace)
    else
      if (size(mean_weight) < levels .or. size(delta) < levels .or. size(alpha) < levels) return
      do column=1,columns
        accumulated=0.0_real64
        do level=1,levels
          old_accumulated=accumulated
          product=divergence(level,column)*accumulation_weight(level)
          accumulated=accumulated+product
          product=mean_weight(level)*delta(level)
          product=product*old_accumulated
          local=alpha(level)*divergence(level,column)
          product=product+local
          value=factor*product
          thermal_rate(level,column)=value
        end do
        pressure_rate(column)=accumulated*surface_coefficient
      end do
      status=0_int32
    end if
  end subroutine spectral_temperature_pressure_rates
end module md2asm_spectral_thermal_operators
