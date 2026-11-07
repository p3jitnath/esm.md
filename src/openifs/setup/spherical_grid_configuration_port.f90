!> Construct regular and reduced source row-length owners through native metadata.
module forecast_spherical_grid_configuration
  use iso_c_binding, only: c_int,c_int32_t,c_int64_t,c_double,c_ptr,c_f_pointer
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_geometry_configuration_text, only: require_grid_configuration_group
  use runtime_initial_upper_air_reader_port, only: runtime_initial_grid_metadata
  implicit none
  private
  public :: native_spherical_grid_values,native_spherical_grid_configuration
  public :: initialize_regular_spherical_grid_configuration,initialize_reduced_spherical_grid_configuration
  public :: release_spherical_grid_configuration
  !> Named source geometry scalars; angles use radians and other values are dimensionless.
  !! Only named members are written; native C alignment padding retains its input.
  type,bind(C) :: native_spherical_grid_values
    real(c_double) :: rmucen,rlocen,rstret,rnlginc
    integer(c_int32_t) :: nsttyp,nhtyp,lnonhyd_geom
  end type
  !> Own both source row-length arrays with bounds ndgsag:ndgeng.
  !! nloen remains source-unwritten until the later local-grid producer.
  type :: native_spherical_grid_configuration
    type(native_spherical_grid_values) :: values
    integer(c_int32_t),allocatable :: nloen(:),nloeng(:)
  end type
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Check live dimensions and fresh owners before any allocation or scalar store.
  logical function configuration_admitted(state,d,supersede,stretch_type,coordinates)
    type(native_spherical_grid_configuration),intent(in) :: state
    type(native_grid_dimensions),intent(in) :: d
    integer(c_int32_t),intent(in) :: supersede,stretch_type
    real(c_double),intent(in) :: coordinates(3)
    integer :: j
    configuration_admitted=.false.
    if(supersede<0.or.supersede>1.or.stretch_type/=1)return
    if(d%ndglg<1.or.d%ndglg>1048576)return
    if(d%ndlon<1.or.d%ndlon>1048576)return
    if(d%ndgsur<0.or.d%ndgsur>48)return
    if(d%ndgsag/=1-d%ndgsur.or.d%ndgeng/=d%ndglg+d%ndgsur)return
    if(d%nsmax<1.or.d%nsmax>8191.or.d%ncmax/=d%nsmax)return
    if(allocated(state%nloen).or.allocated(state%nloeng))return
    do j=1,3
      if(ibits(transfer(coordinates(j),0_c_int64_t),52,11)==2047)return
    end do
    if(supersede==1)then
      if(transfer(coordinates(3),0_c_int64_t)/=int(z'3ff0000000000000',c_int64_t))return
    end if
    configuration_admitted=.true.
  end function

  !> Retain the otherwise overwritten file-guess arithmetic and final ECMWF rule.
  subroutine construct_geometry_values(state,d,supersede,grid_type)
    type(native_spherical_grid_configuration),intent(inout) :: state
    type(native_grid_dimensions),intent(in) :: d
    integer(c_int32_t),intent(in) :: supersede,grid_type
    real(c_double),volatile :: source_guess
    integer(c_int32_t) :: numerator,rounded
    if(supersede==1)then
      numerator=d%ndlon-1
      numerator=numerator-2*d%nsmax
      source_guess=real(numerator,c_double)/real(d%nsmax,c_double)
      source_guess=source_guess*10.0_c_double
      source_guess=anint(source_guess)
      rounded=int(source_guess,c_int32_t)
      source_guess=real(rounded,c_double)/10.0_c_double
    end if
    state%values%lnonhyd_geom=0
    state%values%rmucen=1.0_c_double
    state%values%rlocen=0.0_c_double
    state%values%rstret=1.0_c_double
    state%values%nsttyp=1
    state%values%nhtyp=grid_type
    state%values%rnlginc=1.0_c_double
    if(d%nsmax>(d%ndlon+3)/3)state%values%rnlginc=0.0_c_double
  end subroutine

  !> Preserve the regular-grid SUGEM_NAML route and its complete row/halo bounds.
  !! The first NAMGEM admits only its selected NHTYP0 source assignments.
  !! Return2 leaves all state unchanged; allocation failure frees both new owners.
  integer(c_int32_t) function initialize_regular_spherical_grid_configuration( &
      state,d,supersede,stretch_type,coordinates,text) result(status)
    type(native_spherical_grid_configuration),intent(inout) :: state
    type(native_grid_dimensions),intent(in) :: d
    integer(c_int32_t),intent(in) :: supersede,stretch_type
    real(c_double),intent(in) :: coordinates(3)
    character(len=*),intent(in) :: text
    type(ieee_status_type) :: saved_fp_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: row,allocation_status
    status=2
    if(.not.configuration_admitted(state,d,supersede,stretch_type,coordinates))return
    if(require_grid_configuration_group(text,0_c_int32_t)/=0)return
    call ieee_get_status(saved_fp_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(state%nloen(d%ndgsag:d%ndgeng),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%nloeng(d%ndgsag:d%ndgeng),stat=allocation_status)
    if(allocation_status/=0)goto 900
    call ieee_set_status(saved_fp_status)
    call construct_geometry_values(state,d,supersede,0_c_int32_t)
    do row=d%ndgsag,d%ndgeng
      state%nloeng(row)=d%ndlon
    end do
    error_pointer=saved_errno
    status=0
    return
900 continue
    call release_spherical_grid_configuration(state)
    error_pointer=saved_errno
    status=1
  end function

  !> Preserve the reduced-grid route using the one canonical input-grid type.
  !! north_rows is read from the actual initialized input metadata, then mirrored
  !! into the southern hemisphere and extended through the declared halo rows.
  !! No Gaussian order or row-length table is compiled into this calculation.
  integer(c_int32_t) function initialize_reduced_spherical_grid_configuration( &
      state,d,grid,coordinates,text) result(status)
    type(native_spherical_grid_configuration),intent(inout) :: state
    type(native_grid_dimensions),intent(in) :: d
    type(runtime_initial_grid_metadata),intent(in) :: grid
    real(c_double),intent(in) :: coordinates(3)
    character(len=*),intent(in) :: text
    type(ieee_status_type) :: saved_fp_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: order,row,allocation_status
    status=2
    if(.not.configuration_admitted(state,d,1_c_int32_t,1_c_int32_t,coordinates))return
    if(transfer(coordinates(1),0_c_int64_t)/=int(z'3ff0000000000000',c_int64_t))return
    if(transfer(coordinates(2),0_c_int64_t)/=0_c_int64_t)return
    if(d%ndgsur>d%ndglg)return
    if(.not.allocated(grid%north_rows))return
    order=grid%gaussian_order
    if(order<1.or.order>524288)return
    if(grid%row_count/=2*order.or.grid%row_count/=d%ndglg)return
    if(size(grid%north_rows)/=order)return
    if(any(grid%north_rows<1).or.any(grid%north_rows>d%ndlon))return
    if(maxval(grid%north_rows)/=d%ndlon.or.grid%maximum_longitudes/=d%ndlon)return
    if(require_grid_configuration_group(text,2_c_int32_t)/=0)return
    call ieee_get_status(saved_fp_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(state%nloen(d%ndgsag:d%ndgeng),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%nloeng(d%ndgsag:d%ndgeng),stat=allocation_status)
    if(allocation_status/=0)goto 900
    call ieee_set_status(saved_fp_status)
    call construct_geometry_values(state,d,1_c_int32_t,2_c_int32_t)
    do row=1,order
      state%nloeng(row)=grid%north_rows(row)
    end do
    do row=order+1,d%ndglg
      state%nloeng(row)=grid%north_rows(d%ndglg+1-row)
    end do
    do row=1,d%ndgsur
      state%nloeng(1-row)=state%nloeng(row)
      state%nloeng(d%ndglg+row)=state%nloeng(d%ndglg+1-row)
    end do
    error_pointer=saved_errno
    status=0
    return
900 continue
    call release_spherical_grid_configuration(state)
    error_pointer=saved_errno
    status=1
  end function

  !> Release only the two row-length owners in source order.
  subroutine release_spherical_grid_configuration(state)
    type(native_spherical_grid_configuration),intent(inout) :: state
    if(allocated(state%nloen))deallocate(state%nloen)
    if(allocated(state%nloeng))deallocate(state%nloeng)
  end subroutine
end module forecast_spherical_grid_configuration
