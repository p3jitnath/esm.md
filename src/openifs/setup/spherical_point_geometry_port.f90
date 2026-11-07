!> Build nonblocked spherical point geometry from native global/local row metadata.
module forecast_spherical_point_geometry
  use iso_c_binding, only: c_int,c_int64_t,c_double,c_ptr,c_f_pointer
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  implicit none
  private
  public :: spherical_physical_values,native_spherical_point_geometry
  public :: initialize_spherical_point_geometry,initialize_selected_spherical_point_geometry
  public :: release_spherical_point_geometry
  !> Established physical values from the own geometry configuration.
  !! stretch and rc2p1/rc2m1 are dimensionless, radius uses metres, pi uses
  !! radians and angular_rotation uses radians per second.
  type,bind(C) :: spherical_physical_values
    real(c_double) :: stretch,rc2p1,rc2m1,radius,pi,angular_rotation
  end type
  !> The source 21 FP64 arrays and two int32 point maps, each bounds1:point_count.
  !! rcori/rcoric use s**(-1), Cartesian fields use metres, gomvrl uses m s**(-1),
  !! gnordmcm uses m**(-1), gelam/gelat use radians; other real fields are
  !! dimensionless. ngplat stores global row; nuniquegp stores source point ID.
  type :: native_spherical_point_geometry
    real(c_double),allocatable :: rcori(:)
    real(c_double),allocatable :: rcoric(:)
    real(c_double),allocatable :: gemu(:)
    real(c_double),allocatable :: gsqm2(:)
    real(c_double),allocatable :: gelam(:)
    real(c_double),allocatable :: gelat(:)
    real(c_double),allocatable :: geclo(:)
    real(c_double),allocatable :: geslo(:)
    real(c_double),allocatable :: gexco(:)
    real(c_double),allocatable :: geyco(:)
    real(c_double),allocatable :: gezco(:)
    real(c_double),allocatable :: gm(:)
    real(c_double),allocatable :: gmappa(:)
    real(c_double),allocatable :: gomvrl(:)
    real(c_double),allocatable :: gomvrm(:)
    real(c_double),allocatable :: gnordl(:)
    real(c_double),allocatable :: gnordm(:)
    real(c_double),allocatable :: gnordlcl(:)
    real(c_double),allocatable :: gnordmcl(:)
    real(c_double),allocatable :: gnordmcm(:)
    real(c_double),allocatable :: gaw(:)
    integer(c_int),allocatable :: ngplat(:)
    integer(c_int),allocatable :: nuniquegp(:)
  end type
  interface
    function public_inverse_sine(x) bind(C,name="asin") result(value)
      import c_double
      real(c_double),value :: x
      real(c_double) :: value
    end function
    function public_cosine(x) bind(C,name="cos") result(value)
      import c_double
      real(c_double),value :: x
      real(c_double) :: value
    end function
    function public_sine(x) bind(C,name="sin") result(value)
      import c_double
      real(c_double),value :: x
      real(c_double) :: value
    end function
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Require all23new point owners to be fresh.
  logical function point_owners_fresh(state)
    type(native_spherical_point_geometry),intent(in) :: state
    point_owners_fresh=.false.
    if(allocated(state%rcori))return
    if(allocated(state%rcoric))return
    if(allocated(state%gemu))return
    if(allocated(state%gsqm2))return
    if(allocated(state%gelam))return
    if(allocated(state%gelat))return
    if(allocated(state%geclo))return
    if(allocated(state%geslo))return
    if(allocated(state%gexco))return
    if(allocated(state%geyco))return
    if(allocated(state%gezco))return
    if(allocated(state%gm))return
    if(allocated(state%gmappa))return
    if(allocated(state%gomvrl))return
    if(allocated(state%gomvrm))return
    if(allocated(state%gnordl))return
    if(allocated(state%gnordm))return
    if(allocated(state%gnordlcl))return
    if(allocated(state%gnordmcl))return
    if(allocated(state%gnordmcm))return
    if(allocated(state%gaw))return
    if(allocated(state%ngplat))return
    if(allocated(state%nuniquegp))return
    point_owners_fresh=.true.
  end function

  !> Check the selected unit-stretch physical route through its exact FP64 words.
  logical function physical_values_admitted(p)
    type(spherical_physical_values),intent(in) :: p
    integer(c_int64_t) :: bits
    physical_values_admitted=.false.
    if(transfer(p%stretch,0_c_int64_t)/=int(z'3ff0000000000000',c_int64_t))return
    if(transfer(p%rc2p1,0_c_int64_t)/=int(z'4000000000000000',c_int64_t))return
    if(transfer(p%rc2m1,0_c_int64_t)/=0_c_int64_t)return
    if(transfer(p%radius,0_c_int64_t)/=int(z'41584de740000000',c_int64_t))return
    if(transfer(p%pi,0_c_int64_t)/=int(z'400921fb54442d18',c_int64_t))return
    bits=transfer(p%angular_rotation,bits)
    if(bits<int(z'3e10000000000000',c_int64_t))return
    if(bits>int(z'3f70000000000000',c_int64_t))return
    physical_values_admitted=.true.
  end function

  !> Construct the global or distributed source route from live row metadata.
  !! global_longitudes gives every global row length; mu/weights have that
  !! same global ordering. Each local row names its global row, compressed
  !! one-based point start, first one-based longitude and local longitude count.
  !! Local point starts are the source consecutive compressed order, including
  !! zero or unused starts for empty rows. unique_pitch is the separate source global
  !! ID pitch; it does not replace the compressed point-memory index.
  !! Read-only arrays remain complete and disjoint from owned output arrays.
  !! The caller has admitted finite Gaussian inputs with abs(mu)<1 and positive
  !! weights. Return2 changes no output, return1 cleans acquired owners.
  integer(c_int) function initialize_spherical_point_geometry(state,p,point_count,unique_pitch, &
      global_longitudes,local_rows,point_starts,first_longitudes,longitude_counts,mu,weights) result(status)
    type(native_spherical_point_geometry),intent(inout) :: state
    type(spherical_physical_values),intent(in) :: p
    integer(c_int),intent(in) :: point_count,unique_pitch
    integer(c_int),intent(in) :: global_longitudes(:),local_rows(:),point_starts(:)
    integer(c_int),intent(in) :: first_longitudes(:),longitude_counts(:)
    real(c_double),intent(in) :: mu(:),weights(:)
    integer(c_int64_t) :: next_point,finish,unique_id
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: nrows,nlocal,row,global_row,nlongitude,longitude,last_longitude,point,allocation_status
    real(c_double) :: numerator,denominator,sine,cosine,mapping,twice_rotation
    real(c_double) :: coriolis_sine,coriolis_cosine,rotation_vector,meridian_derivative
    real(c_double) :: angle,angle_cosine,angle_sine,temporary,other
    status=2
    if(point_count<1.or.unique_pitch<1)return
    if(.not.physical_values_admitted(p))return
    if(.not.point_owners_fresh(state))return
    nrows=size(global_longitudes)
    nlocal=size(local_rows)
    if(nrows<1.or.nlocal<1)return
    if(size(mu)/=nrows.or.size(weights)/=nrows)return
    if(size(point_starts)/=nlocal.or.size(first_longitudes)/=nlocal.or.size(longitude_counts)/=nlocal)return
    if(any(global_longitudes<1).or.any(global_longitudes>unique_pitch))return
    if(any(global_longitudes>huge(1_c_int)/2))return
    next_point=1_c_int64_t
    do row=1,nlocal
      global_row=local_rows(row)
      if(global_row<1.or.global_row>nrows)return
      if(longitude_counts(row)<0)return
      if(longitude_counts(row)==0)cycle
      if(int(point_starts(row),c_int64_t)/=next_point)return
      if(first_longitudes(row)<1)return
      finish=int(first_longitudes(row),c_int64_t)+int(longitude_counts(row),c_int64_t)-1_c_int64_t
      if(finish>global_longitudes(global_row))return
      next_point=next_point+int(longitude_counts(row),c_int64_t)
      if(next_point>int(point_count,c_int64_t)+1_c_int64_t)return
      unique_id=int(unique_pitch,c_int64_t)*int(global_row-1,c_int64_t)+finish
      if(unique_id>int(huge(1_c_int),c_int64_t))return
    end do
    if(next_point/=int(point_count,c_int64_t)+1_c_int64_t)return
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(state%rcori(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rcoric(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gemu(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gsqm2(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gelam(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gelat(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%geclo(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%geslo(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gexco(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%geyco(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gezco(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gm(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gmappa(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gomvrl(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gomvrm(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gnordl(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gnordm(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gnordlcl(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gnordmcl(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gnordmcm(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%gaw(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%ngplat(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%nuniquegp(point_count),stat=allocation_status)
    if(allocation_status/=0)goto 900
    do row=1,nlocal
      global_row=local_rows(row)
      nlongitude=global_longitudes(global_row)
      temporary=p%rc2p1*mu(global_row)
      numerator=p%rc2m1+temporary
      temporary=p%rc2m1*mu(global_row)
      denominator=p%rc2p1+temporary
      sine=numerator/denominator
      temporary=sine*sine
      temporary=1.0_c_double-temporary
      cosine=sqrt(temporary)
      temporary=0.5_c_double/p%stretch
      mapping=denominator*temporary
      twice_rotation=2.0_c_double*p%angular_rotation
      coriolis_sine=twice_rotation*sine
      coriolis_cosine=twice_rotation*cosine
      temporary=twice_rotation*p%radius
      rotation_vector=temporary*cosine
      temporary=1.0_c_double/p%radius
      temporary=-temporary
      meridian_derivative=temporary*sine
      if(longitude_counts(row)==0)cycle
      point=point_starts(row)
      last_longitude=first_longitudes(row)+longitude_counts(row)-1
      do longitude=first_longitudes(row),last_longitude
        state%rcori(point)=coriolis_sine
        state%rcoric(point)=coriolis_cosine
        state%gemu(point)=sine
        state%gsqm2(point)=cosine
        temporary=real(2*(longitude-1),c_double)
        temporary=p%pi*temporary
        temporary=temporary/real(nlongitude,c_double)
        angle=0.0_c_double+temporary
        state%gelam(point)=angle
        state%gelat(point)=public_inverse_sine(sine)
        angle_cosine=public_cosine(angle)
        state%geclo(point)=angle_cosine
        temporary=p%radius*cosine
        state%gexco(point)=temporary*angle_cosine
        angle_sine=public_sine(angle)
        state%geslo(point)=angle_sine
        temporary=p%radius*cosine
        state%geyco(point)=temporary*angle_sine
        state%gezco(point)=p%radius*sine
        state%gm(point)=mapping
        state%gmappa(point)=p%stretch*p%stretch
        state%gomvrl(point)=rotation_vector
        state%gomvrm(point)=0.0_c_double
        state%gnordl(point)=0.0_c_double
        state%gnordm(point)=1.0_c_double
        state%gnordlcl(point)=0.0_c_double
        state%gnordmcl(point)=0.0_c_double
        state%gnordmcm(point)=meridian_derivative
        temporary=mapping*mapping
        other=real(nlongitude,c_double)*temporary
        state%gaw(point)=weights(global_row)/other
        state%ngplat(point)=global_row
        state%nuniquegp(point)=unique_pitch*(global_row-1)+longitude
        point=point+1
      end do
    end do
    error_pointer=saved_errno
    status=0
    return
900 continue
    call release_spherical_point_geometry(state)
    error_pointer=saved_errno
    status=1
  end function

  !> Preserve the selected32-by64route through the common ordered calculation.
  integer(c_int) function initialize_selected_spherical_point_geometry(state,p,mu,weights) result(status)
    type(native_spherical_point_geometry),intent(inout) :: state
    type(spherical_physical_values),intent(in) :: p
    real(c_double),intent(in) :: mu(32),weights(32)
    integer(c_int) :: rows(32),starts(32),first(32),counts(32),lengths(32)
    integer :: j
    do j=1,32
      rows(j)=j
      starts(j)=1+64*(j-1)
      first(j)=1
      counts(j)=64
      lengths(j)=64
    end do
    status=initialize_spherical_point_geometry(state,p,2048_c_int,64_c_int, &
      lengths,rows,starts,first,counts,mu,weights)
  end function

  !> Release all23owners in source order while preserving IEEE status and errno.
  subroutine release_spherical_point_geometry(state)
    type(native_spherical_point_geometry),intent(inout) :: state
    type(ieee_status_type) :: saved_fp_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_fp_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    if(allocated(state%rcori))deallocate(state%rcori)
    if(allocated(state%rcoric))deallocate(state%rcoric)
    if(allocated(state%gemu))deallocate(state%gemu)
    if(allocated(state%gsqm2))deallocate(state%gsqm2)
    if(allocated(state%gelam))deallocate(state%gelam)
    if(allocated(state%gelat))deallocate(state%gelat)
    if(allocated(state%geclo))deallocate(state%geclo)
    if(allocated(state%geslo))deallocate(state%geslo)
    if(allocated(state%gexco))deallocate(state%gexco)
    if(allocated(state%geyco))deallocate(state%geyco)
    if(allocated(state%gezco))deallocate(state%gezco)
    if(allocated(state%gm))deallocate(state%gm)
    if(allocated(state%gmappa))deallocate(state%gmappa)
    if(allocated(state%gomvrl))deallocate(state%gomvrl)
    if(allocated(state%gomvrm))deallocate(state%gomvrm)
    if(allocated(state%gnordl))deallocate(state%gnordl)
    if(allocated(state%gnordm))deallocate(state%gnordm)
    if(allocated(state%gnordlcl))deallocate(state%gnordlcl)
    if(allocated(state%gnordmcl))deallocate(state%gnordmcl)
    if(allocated(state%gnordmcm))deallocate(state%gnordmcm)
    if(allocated(state%gaw))deallocate(state%gaw)
    if(allocated(state%ngplat))deallocate(state%ngplat)
    if(allocated(state%nuniquegp))deallocate(state%nuniquegp)
    call ieee_set_status(saved_fp_status)
    error_pointer=saved_errno
  end subroutine
end module forecast_spherical_point_geometry
