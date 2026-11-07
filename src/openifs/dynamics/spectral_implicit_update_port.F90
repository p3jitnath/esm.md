!> Structured port of the generated runtime SPCSI parent.
!! The pressure-stage procedure must supply the ported distributed copies and solve.
!! The agreement procedure combines local status while the partition is live.
!! Neither procedure may substitute an original OpenIFS numerical implementation.
module md2asm_spectral_implicit_update
  use, intrinsic :: iso_fortran_env, only : int32,int64,real64
  use md2asm_vertical_operators, only : vertical_operator_matrices
  use md2asm_spectral_thermal_operators, only : spectral_geopotential,spectral_temperature_pressure_rates
  use md2asm_vertical_matrix_product, only : apply_vertical_matrix_product
  implicit none
  private
  public :: spectral_implicit_controls,spectral_implicit_coefficients
  public :: apply_spectral_implicit_update,spectral_implicit_child_calls
  integer(int64), save :: child_calls(0:4)=0_int64
  type :: spectral_implicit_controls
    integer :: global_levels=0,local_levels=0,degree=0,columns=0,full_columns=0
    integer :: first_column=0,last_column=0,partition_phase=0,vertical_set=0
    integer :: integral_bc=3,derivative_bc=0
    integer(int64) :: temporary_bytes_budget=0_int64
    logical :: geometry_matches_partition=.false.,physical_constants_present=.false.
    logical :: hydrostatic=.true.,coupled_rotation=.true.,single_wave=.false.
    logical :: spectral_diagnostics=.false.,stretched=.false.,finite_elements=.true.
  end type spectral_implicit_controls
  type :: spectral_implicit_coefficients
    real(real64) :: implicit_coefficient=0.0_real64,time_coefficient=0.0_real64
    real(real64) :: stretch=1.0_real64,rd=0.0_real64,kappa=0.0_real64
    real(real64) :: geopotential_surface=0.0_real64,thermal_coefficient=0.0_real64
    real(real64) :: pressure_rate_coefficient=0.0_real64
    real(real64), pointer :: alpha(:)=>null(),delta(:)=>null(),metric(:)=>null()
    real(real64), pointer :: accumulation_weight(:)=>null(),mean_weight(:)=>null()
    real(real64), pointer :: full_level_weight(:)=>null(),laplacian(:)=>null()
    real(real64), pointer :: simi(:,:)=>null(),simo(:,:)=>null()
  end type spectral_implicit_coefficients
  abstract interface
    subroutine distributed_pressure_stage(rhs,solution,active_columns,full_columns,status)
      import :: real64,int32
      real(real64), intent(inout) :: rhs(:,:)
      real(real64), intent(inout) :: solution(:,:)
      integer, intent(in) :: active_columns,full_columns
      integer(int32), intent(out) :: status
    end subroutine distributed_pressure_stage
    function agree_partition_status(local_status) result(global_status)
      import :: int32
      integer(int32), intent(in) :: local_status
      integer(int32) :: global_status
    end function agree_partition_status
  end interface
contains
  !> Preserve SIGAM,RHS,SIMI,pressure,SIMO,stretch,SITNU and final assignment order.
  !! Divergence and temperature have dense(level,column) storage.
  !! The caller retains all inactive fields and exact distributed map ownership.
  !! Partial numerical outputs remain unaccepted if a later child refuses.
  subroutine apply_spectral_implicit_update(control,coef,tables,nptrsv,nvalue, &
      divergence,temperature,log_pressure,divergence_tendency,pressure_stage,agree,status)
    type(spectral_implicit_controls), intent(in) :: control
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(vertical_operator_matrices), intent(in) :: tables
    integer(int32), intent(in) :: nptrsv(:),nvalue(:)
    real(real64), intent(inout) :: divergence(:,:),temperature(:,:),log_pressure(:)
    real(real64), intent(in) :: divergence_tendency(:,:)
    procedure(distributed_pressure_stage) :: pressure_stage
    procedure(agree_partition_status) :: agree
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: gamma(:,:),modes_in(:,:),modes_out(:,:),velocity(:,:)
    real(real64), pointer :: thermal_rate(:,:),pressure_rate(:),matrix_work(:)
    integer :: l,s,capacity,level,column,first,degree,allocation_status
    integer(int32) :: local_status
    integer(int64) :: field_words,mode_words,total_words,offset,required_bytes
    real(real64) :: factor,wave_factor,product,value

    local_status=2_int32
    l=control%global_levels;s=control%columns
    capacity=max(s,control%full_columns)
    admission: block
      if (l < 1 .or. l > 512) exit admission
      if (control%local_levels < 0 .or. control%local_levels > l) exit admission
      if (control%degree < 1 .or. control%degree > 8191) exit admission
      if (s < 1 .or. control%full_columns < 0) exit admission
      if (control%first_column /= 1 .or. control%last_column /= s) exit admission
      if (.not. control%hydrostatic .or. .not. control%coupled_rotation) exit admission
      if (control%single_wave .or. control%spectral_diagnostics .or. control%stretched) exit admission
      if (.not. control%finite_elements .or. control%integral_bc /= 3) exit admission
      if (coef%stretch /= 1.0_real64) exit admission
      if (control%partition_phase /= 7 .or. .not. control%geometry_matches_partition) exit admission
      if (.not. control%physical_constants_present) exit admission
      if (control%vertical_set < 1 .or. control%vertical_set > size(nptrsv)) exit admission
      if (control%temporary_bytes_budget < 1_int64 .or. control%temporary_bytes_budget > 2_int64**36) exit admission
      field_words=int(l,int64)*int(s,int64)
      mode_words=int(l,int64)*int(capacity,int64)
      total_words=3_int64*field_words+2_int64*mode_words+int(s,int64)
      required_bytes=8_int64*total_words
      if (required_bytes > control%temporary_bytes_budget) exit admission
      if (size(divergence,1) /= l .or. size(divergence,2) < s) exit admission
      if (size(temperature,1) /= l .or. size(temperature,2) < s) exit admission
      if (size(divergence_tendency,1) /= l .or. size(divergence_tendency,2) < s) exit admission
      if (size(log_pressure) < s) exit admission
      if (.not. is_contiguous(divergence) .or. .not. is_contiguous(temperature)) exit admission
      if (.not. is_contiguous(divergence_tendency) .or. .not. is_contiguous(log_pressure)) exit admission
      if (.not. associated(coef%simi) .or. .not. associated(coef%simo)) exit admission
      if (any(shape(coef%simi) /= [l,l]) .or. any(shape(coef%simo) /= [l,l])) exit admission
      if (.not. is_contiguous(coef%simi) .or. .not. is_contiguous(coef%simo)) exit admission
      if (.not. associated(coef%laplacian)) exit admission
      if (lbound(coef%laplacian,1) /= 0 .or. ubound(coef%laplacian,1) < control%degree) exit admission
      if (.not. associated(coef%alpha) .or. .not. associated(coef%delta)) exit admission
      if (.not. associated(coef%metric) .or. .not. associated(coef%full_level_weight)) exit admission
      if (.not. associated(coef%accumulation_weight) .or. .not. associated(coef%mean_weight)) exit admission
      if (size(coef%delta) < l .or. size(coef%metric) < l) exit admission
      if (size(coef%full_level_weight) < l .or. size(coef%accumulation_weight) < l) exit admission
      first=nptrsv(control%vertical_set)
      if (first < 1 .or. first > size(nvalue)-s+1) exit admission
      do column=first,first+s-1
        if (nvalue(column) < 0 .or. nvalue(column) > control%degree) exit admission
      end do
      local_status=0_int32
    end block admission
    status=agree(local_status)
    if (status /= 0_int32) return
    allocate(workspace(total_words),stat=allocation_status)
    local_status=0_int32
    if (allocation_status /= 0) local_status=1_int32
    status=agree(local_status)
    if (status /= 0_int32) then
      if (allocated(workspace)) deallocate(workspace)
      return
    end if
    offset=0_int64
    gamma(1:l,1:s)=>workspace(offset+1:offset+field_words);offset=offset+field_words
    modes_in(1:l,1:capacity)=>workspace(offset+1:offset+mode_words);offset=offset+mode_words
    modes_out(1:l,1:capacity)=>workspace(offset+1:offset+mode_words);offset=offset+mode_words
    velocity(1:l,1:s)=>workspace(offset+1:offset+field_words)
    matrix_work=>workspace(offset+1:offset+field_words);offset=offset+field_words
    thermal_rate(1:l,1:s)=>workspace(offset+1:offset+field_words);offset=offset+field_words
    pressure_rate=>workspace(offset+1:offset+int(s,int64))
    factor=coef%implicit_coefficient*coef%time_coefficient
    stages: block
      call spectral_geopotential(temperature(:,1:s),log_pressure(1:s),coef%rd, &
        coef%geopotential_surface,coef%alpha,coef%delta,coef%metric,.true.,tables, &
        control%integral_bc,control%derivative_bc,gamma,local_status)
      status=agree(local_status)
      if (status /= 0_int32) exit stages
      call count_child(0)
      do column=1,s
        degree=nvalue(first+column-1)
        wave_factor=factor*coef%laplacian(degree)
        do level=1,l
          product=wave_factor*gamma(level,column)
          value=divergence(level,column)-product
          value=value+divergence_tendency(level,column)
          gamma(level,column)=value
        end do
      end do
      call apply_vertical_matrix_product(coef%simi,gamma,modes_in,matrix_work,local_status)
      status=agree(local_status)
      if (status /= 0_int32) exit stages
      call count_child(1)
      call pressure_stage(modes_in,modes_out,s,control%full_columns,status)
      if (status /= 0_int32) exit stages
      call count_child(2)
      call apply_vertical_matrix_product(coef%simo,modes_out(:,1:s), &
        divergence(:,1:s),matrix_work,local_status)
      status=agree(local_status)
      if (status /= 0_int32) exit stages
      call count_child(3)
      do column=1,s
        do level=1,l
          value=divergence(level,column)*coef%stretch
          value=value*coef%stretch
          velocity(level,column)=value
        end do
      end do
      call spectral_temperature_pressure_rates(velocity,coef%kappa,coef%thermal_coefficient, &
        coef%pressure_rate_coefficient,coef%accumulation_weight,coef%mean_weight,coef%delta, &
        coef%alpha,coef%metric,coef%full_level_weight,.true.,tables,control%integral_bc, &
        control%derivative_bc,thermal_rate,pressure_rate,local_status)
      status=agree(local_status)
      if (status /= 0_int32) exit stages
      call count_child(4)
      do column=1,s
        do level=1,l
          product=factor*thermal_rate(level,column)
          temperature(level,column)=temperature(level,column)-product
        end do
        product=factor*pressure_rate(column)
        log_pressure(column)=log_pressure(column)-product
      end do
      status=0_int32
    end block stages
    deallocate(workspace)
  end subroutine apply_spectral_implicit_update

  subroutine count_child(index)
    integer, intent(in) :: index
    !$omp atomic update
    child_calls(index)=child_calls(index)+1_int64
  end subroutine count_child

  function spectral_implicit_child_calls(index) result(value)
    integer, intent(in) :: index
    integer(int64) :: value
    value=0_int64
    if (index < 0 .or. index > 4) return
    !$omp atomic read
    value=child_calls(index)
  end function spectral_implicit_child_calls
end module md2asm_spectral_implicit_update
