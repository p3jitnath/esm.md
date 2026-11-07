module selected_spline_operators
  !! Construct the five qualified integral and derivative matrices on native owned arrays.
  use iso_c_binding, only: c_int,c_double,c_int64_t
  use vertical_spline_knots_port, only: build_spline_knots
  use forecast_spline_inverse_products, only: selected_spline_inverse,spline_matrix_product
  use spline_polynomial_operations, only: spline_sample_position,coordinate_from_local
  use spline_operator_components
  implicit none
  private
  public :: selected_spline_operator, sampling_transform
  type :: spline_role
    real(c_double) :: transform(4,4)
    real(c_double), allocatable :: knots(:),pieces(:,:,:),centres(:)
  end type
contains
  function sampling_transform(bounds,order,transform) result(status)
    !! Read the unit interval and cubic order; replace the 4-by-4 sampling inverse.
    real(c_double), intent(in) :: bounds(2)
    integer(c_int), intent(in) :: order
    real(c_double), intent(inout) :: transform(4,4)
    integer(c_int) :: status,child
    integer :: row,degree
    real(c_double) :: vandermonde(4,4),coordinate,power
    status=2
    if(order/=4) return
    if(transfer(bounds(1),0_c_int64_t)/=0_c_int64_t) return
    if(transfer(bounds(2),0_c_int64_t)/=int(z'3ff0000000000000',c_int64_t)) return
    do row=1,4
      coordinate=spline_sample_position(order,int(row,c_int),bounds)
      coordinate=coordinate_from_local(bounds(1),bounds(2),coordinate)
      power=1.0_c_double
      vandermonde(row,1)=power
      do degree=2,4
        power=coordinate*power
        vandermonde(row,degree)=power
      end do
    end do
    child=selected_spline_inverse(1_c_int,vandermonde,transform)
    status=0
    if(child/=0) status=3
  end function
  function selected_spline_operator(controls,eta_in,eta_out,output) result(status)
    !! Eta is dimensionless. Read the complete coordinate owners and replace one rows-by-dimension matrix.
    !! Controls select operator kind, active rows, two value boundaries and two endpoint derivative flags.
    integer(c_int), intent(in) :: controls(6)
    real(c_double), intent(in) :: eta_in(0:),eta_out(:)
    real(c_double), intent(inout) :: output(:,:)
    integer(c_int) :: status,child
    integer :: dimension,basis,rows,role,i,alloc_status
    integer(c_int), allocatable :: input_types(:),output_types(:)
    type(spline_role) :: owners(3)
    real(c_double), allocatable :: mass(:,:),stiffness(:,:),input_evaluation(:,:),output_evaluation(:,:)
    real(c_double), allocatable :: inverse_mass(:,:),inverse_evaluation(:,:),product1(:,:),product2(:,:)
    real(c_double) :: bounds(2)
    status=2
    dimension=size(eta_in)
    if(dimension/=21.and.dimension/=139) return
    rows=controls(2)
    if(.not.selected_tuple(controls,dimension)) return
    if(size(eta_out)<rows) return
    if(size(output,1)/=rows.or.size(output,2)/=dimension) return
    if(transfer(eta_in(0),0_c_int64_t)/=0_c_int64_t) return
    if(transfer(eta_in(dimension-1),0_c_int64_t)/=int(z'3ff0000000000000',c_int64_t)) return
    do i=1,dimension-1
      if(ibits(transfer(eta_in(i),0_c_int64_t),52,11)==2047) return
      if(eta_in(i)<=eta_in(i-1)) return
    end do
    do i=1,rows
      if(transfer(eta_out(i),0_c_int64_t)/=transfer(eta_in(i),0_c_int64_t)) return
    end do
    basis=dimension+controls(3)+controls(4)
    allocate(input_types(dimension),output_types(rows),mass(dimension,dimension),stiffness(dimension,dimension), &
      input_evaluation(dimension,dimension),output_evaluation(rows,dimension),inverse_mass(dimension,dimension), &
      inverse_evaluation(dimension,dimension),product1(dimension,dimension),product2(dimension,dimension),stat=alloc_status)
    status=3
    if(alloc_status/=0) return
    bounds=[0.0_c_double,1.0_c_double]
    do role=1,3
      child=sampling_transform(bounds,4_c_int,owners(role)%transform)
      if(child/=0) return
    end do
    do role=1,3
      i=basis
      if(role==1) i=dimension
      allocate(owners(role)%knots(i+4),owners(role)%pieces(i,4,4),owners(role)%centres(i),stat=alloc_status)
      if(alloc_status/=0) return
      child=build_spline_knots(4_c_int,int(i,c_int),int(dimension,c_int),eta_in,owners(role)%knots)
      if(child/=0) return
    end do
    do role=1,3
      child=piece_coefficients(owners(role)%transform,owners(role)%knots,0.0_c_double, &
        owners(role)%pieces,owners(role)%centres)
      if(child/=0) return
    end do
    child=value_boundaries(0_c_int,0_c_int,owners(1)%pieces)
    if(child/=0) return
    do role=2,3
      child=value_boundaries(controls(3),controls(4),owners(role)%pieces)
      if(child/=0) return
    end do
    child=operator_matrix(0_c_int,controls(3),controls(3),owners(2)%transform,owners(3)%transform, &
      owners(2)%knots,owners(3)%knots,owners(2)%pieces,owners(3)%pieces,mass)
    if(child/=0) return
    child=operator_matrix(controls(1),0_c_int,controls(3),owners(1)%transform,owners(3)%transform, &
      owners(1)%knots,owners(3)%knots,owners(1)%pieces,owners(3)%pieces,stiffness)
    if(child/=0) return
    input_types=0
    output_types=0
    input_types(1)=controls(5)
    input_types(dimension)=controls(6)
    child=evaluation_matrix(0_c_int,eta_in,input_types,owners(1)%knots,owners(1)%pieces,input_evaluation)
    if(child/=0) return
    child=evaluation_matrix(controls(3),eta_out(1:rows),output_types,owners(2)%knots,owners(2)%pieces,output_evaluation)
    if(child/=0) return
    child=selected_spline_inverse(1_c_int,mass,inverse_mass)
    if(child/=0) return
    child=selected_spline_inverse(1_c_int,input_evaluation,inverse_evaluation)
    if(child/=0) return
    child=spline_matrix_product(stiffness,inverse_evaluation,product1)
    if(child/=0) return
    child=spline_matrix_product(inverse_mass,product1,product2)
    if(child/=0) return
    child=spline_matrix_product(output_evaluation,product2,output)
    if(child/=0) return
    status=0
  end function
  function selected_tuple(controls,dimension) result(valid)
    integer(c_int), intent(in) :: controls(6)
    integer, intent(in) :: dimension
    logical :: valid
    integer :: rows,i
    integer :: tuples(6,5)
    rows=dimension-2
    tuples=reshape([-1,rows+1,1,0,1,1, 1,rows,0,0,0,0, 1,rows,0,1,0,1, &
      1,rows,1,0,1,0, 1,rows,0,0,1,1],[6,5])
    valid=.false.
    do i=1,5
      if(all(controls==tuples(:,i))) valid=.true.
    end do
  end function
  function selected_spline_operator_c(controls,dimension,eta_in,eta_out,output) &
      bind(C,name='md2asm_selected_spline_operator_fortran') result(status)
    integer(c_int), intent(in) :: controls(6)
    integer(c_int), value, intent(in) :: dimension
    real(c_double), intent(in) :: eta_in(0:dimension-1),eta_out(controls(2))
    real(c_double), intent(inout) :: output(controls(2),dimension)
    integer(c_int) :: status
    status=selected_spline_operator(controls,eta_in,eta_out,output)
  end function
end module
