module distributed_spectral_field_storage_port
  !! Copy live partition maps into one native spectral field owner.
  !! The map view borrows typed arrays only during construction. The output
  !! owns its copied maps and numerical fields; it has no original data link.
  use, intrinsic :: iso_fortran_env, only: int32,int64,real64
  use, intrinsic :: iso_c_binding, only: c_ptr,c_int,c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use spectral_field_storage_port, only: spectral_field_state,spectral_field_is_fresh, &
    spectral_storage_mode_supported,release_spectral_field
  implicit none
  private
  public :: distributed_spectral_map_view,initialize_distributed_spectral_field,distributed_spectral_maps_valid
  type :: distributed_spectral_map_view
    integer(int32) :: wave_group=0,level_group=0,wave_groups=0,level_groups=0
    integer(int32) :: local_coefficients=0,local_waves=0,n=0,levels=0
    integer(int32), pointer, contiguous :: myms(:)=>null(),nallms(:)=>null(),nptrms(:)=>null()
    integer(int32), pointer, contiguous :: numll(:)=>null(),nptrll(:)=>null(),npsurf(:)=>null()
    integer(int32), pointer, contiguous :: nasm0(:)=>null(),numpp(:)=>null()
  end type
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  logical function distributed_spectral_maps_valid(m) result(valid)
    !! Runtime source bounds: N1..4096,L1..256, world<=65536 and complete
    !! global field count within signed int32. All map values are dimensionless.
    type(distributed_spectral_map_view), intent(in) :: m
    integer(int32) :: group,level,wave,index,next,count_levels,count_surface,width,first
    integer(int64) :: global_words,total_words
    valid=.false.
    if(m%n<1.or.m%n>4096.or.m%levels<1.or.m%levels>256) return
    if(m%wave_groups<1.or.m%wave_groups>65536.or.m%level_groups<1.or.m%level_groups>m%levels+1) return
    if(int(m%wave_groups,int64)*int(m%level_groups,int64)>65536_int64) return
    if(m%wave_group<1.or.m%wave_group>m%wave_groups.or.m%level_group<1.or.m%level_group>m%level_groups) return
    global_words=int(m%n+1,int64)*int(m%n+2,int64)
    total_words=global_words*int(3*m%levels+2,int64)
    if(total_words>int(huge(0_int32),int64)) return
    if(m%local_coefficients<0.or.int(m%local_coefficients,int64)>global_words.or.mod(m%local_coefficients,2)/=0) return
    if(m%local_waves<0.or.m%local_waves>m%n+1) return
    if(.not.associated(m%myms).or..not.associated(m%nallms).or..not.associated(m%nptrms)) return
    if(.not.associated(m%numll).or..not.associated(m%nptrll).or..not.associated(m%npsurf)) return
    if(.not.associated(m%nasm0).or..not.associated(m%numpp)) return
    if(size(m%myms)<m%local_waves.or.size(m%nallms)<m%n+1.or.size(m%nasm0)<m%n+1) return
    if(size(m%nptrms)<m%wave_groups.or.size(m%numpp)<m%wave_groups) return
    if(size(m%numll)<m%level_groups.or.size(m%nptrll)<m%level_groups.or.size(m%npsurf)<m%level_groups) return
    count_levels=0;count_surface=0
    do group=1,m%level_groups
      if(m%numll(group)<0.or.m%numll(group)>m%levels) return
      if(m%nptrll(group)<0.or.m%nptrll(group)>m%levels+1) return
      if(m%numll(group)+m%nptrll(group)>m%levels+1) return
      if(m%npsurf(group)<0.or.m%npsurf(group)>1) return
      count_levels=count_levels+m%numll(group)
      count_surface=count_surface+m%npsurf(group)
    end do
    if(count_levels/=m%levels.or.count_surface/=1) return
    width=m%n/m%wave_groups+1
    next=1
    do group=1,m%wave_groups
      if(m%numpp(group)<0.or.m%numpp(group)>width) return
      if(m%nptrms(group)/=next) return
      next=next+m%numpp(group)
    end do
    if(next/=m%n+2.or.m%numpp(m%wave_group)/=m%local_waves) return
    first=m%nptrms(m%wave_group)
    next=1
    do index=1,m%local_waves
      wave=m%myms(index)
      if(wave<0.or.wave>m%n) return
      if(m%nallms(first+index-1)/=wave) return
      if(m%nasm0(lbound(m%nasm0,1)+wave)/=next) return
      next=next+2*(m%n+1-wave)
    end do
    if(next-1/=m%local_coefficients) return
    valid=.true.
  end function

  integer(int32) function initialize_distributed_spectral_field(output,m,identifiers,byte_cap) result(status)
    !! output is fresh, TARGET and stable until release. m borrows the exact
    !! source partition. byte_cap includes each of16 source reservations,
    !! using1 byte for a logical zero extent, but excludes object/runtime cost.
    !! Return0 success,1 cleaned allocation failure,2 atomic refusal.
    type(spectral_field_state), target, intent(inout) :: output
    type(distributed_spectral_map_view), intent(in) :: m
    integer(int32), intent(in) :: identifiers(5)
    integer(int64), intent(in) :: byte_cap
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored,n,waves,levels,coefficients,surfaces,width,nw,nv
    integer(int64) :: reservations(16)
    integer :: ios,j,group,index,first,next,wave
    status=2
    if(.not.spectral_field_is_fresh(output)) return
    if(.not.spectral_storage_mode_supported()) return
    if(.not.distributed_spectral_maps_valid(m)) return
    if(count(identifiers(1:3)==138)/=1.or.count(identifiers(1:3)==155)/=1.or.count(identifiers(1:3)==130)/=1) return
    if(count(identifiers(4:5)==152)/=1.or.count(identifiers(4:5)==129)/=1) return
    n=m%n;waves=n+1;nw=m%wave_groups;nv=m%level_groups
    levels=m%numll(m%level_group);coefficients=m%local_coefficients
    surfaces=2*m%npsurf(m%level_group);width=n/nw+1
    reservations=[4_int64*m%local_waves,4_int64*waves,4_int64*nw,4_int64*nv,4_int64*nv,4_int64*nv, &
      4_int64*levels,4_int64*waves,4_int64*waves,4_int64*nw,4_int64*width*nw,4_int64*nv,20_int64, &
      24_int64*levels*coefficients,8_int64*coefficients*surfaces,16_int64]
    if(byte_cap<sum(max(1_int64,reservations))) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    status=1
    allocate(output%myms(m%local_waves),stat=ios)
    if(ios/=0) goto 800
    allocate(output%nallms(waves),stat=ios)
    if(ios/=0) goto 800
    allocate(output%nptrms(nw),stat=ios)
    if(ios/=0) goto 800
    allocate(output%numll(nv),stat=ios)
    if(ios/=0) goto 800
    allocate(output%nptrll(nv),stat=ios)
    if(ios/=0) goto 800
    allocate(output%npsurf(nv),stat=ios)
    if(ios/=0) goto 800
    allocate(output%mylevs(levels),stat=ios)
    if(ios/=0) goto 800
    allocate(output%nasm0(0:n),stat=ios)
    if(ios/=0) goto 800
    allocate(output%nasm0g(0:n),stat=ios)
    if(ios/=0) goto 800
    allocate(output%numpp(nw),stat=ios)
    if(ios/=0) goto 800
    allocate(output%ms_proc(width,nw),stat=ios)
    if(ios/=0) goto 800
    allocate(output%ns2l(nv),stat=ios)
    if(ios/=0) goto 800
    allocate(output%ngrib(5),stat=ios)
    if(ios/=0) goto 800
    allocate(output%sp3d(levels,coefficients,3),stat=ios)
    if(ios/=0) goto 800
    allocate(output%sp2d(coefficients,surfaces),stat=ios)
    if(ios/=0) goto 800
    allocate(output%sp1d(1,2),stat=ios)
    if(ios/=0) goto 800
    output%nsmax=n;output%nmsmax=0;output%ns2d=surfaces;output%ns3d=3;output%ns1d=0;output%ns2g=2
    output%nflevl=levels;output%nflevg=m%levels;output%nspec2=coefficients;output%nspec2g=(n+1)*(n+2)
    output%nump=m%local_waves;output%nspsizel=(3*levels+surfaces)*coefficients
    output%nspsizeg=(3*m%levels+2)*output%nspec2g
    do j=1,m%local_waves
      output%myms(j)=m%myms(j)
    end do
    output%nallms(:)=m%nallms(1:waves);output%nptrms(:)=m%nptrms(1:nw)
    output%numll(:)=m%numll(1:nv);output%nptrll(:)=m%nptrll(1:nv);output%npsurf(:)=m%npsurf(1:nv)
    do wave=0,n
      output%nasm0(wave)=m%nasm0(lbound(m%nasm0,1)+wave)
    end do
    output%numpp(:)=m%numpp(1:nw)
    next=1
    do wave=0,n
      output%nasm0g(wave)=next
      next=next+2*(n+1-wave)
    end do
    do j=1,levels
      output%mylevs(j)=m%nptrll(m%level_group)+j-1
    end do
    do group=1,nv
      output%ns2l(group)=2*m%npsurf(group)
    end do
    ! Source-unwritten MS_PROC tail cells keep their allocation preimage.
    do group=1,nw
      first=output%nptrms(group)
      do index=1,output%numpp(group)
        output%ms_proc(index,group)=output%nallms(first+index-1)
      end do
    end do
    output%ngrib(:)=[138_int32,155_int32,130_int32,152_int32,129_int32]
    output%sp3d=0.0_real64;output%sp2d=0.0_real64;output%sp1d=0.0_real64;output%dummy=0.0_real64
    output%ngrib3=>output%ngrib(1:3);output%ngrib2=>output%ngrib(4:5)
    output%vor=>output%sp3d(:,:,1);output%div=>output%sp3d(:,:,2);output%t=>output%sp3d(:,:,3)
    output%scal=>output%sp3d(:,:,3:3);output%hv=>output%sp3d(:,:,3:3)
    if(surfaces==0) then
      output%sp=>output%dummy(1:1);output%orog=>output%dummy(1:1)
    else
      output%sp=>output%sp2d(:,1);output%orog=>output%sp2d(:,2)
    end if
    output%ub=>output%sp1d(:,1);output%vb=>output%sp1d(:,2)
    output%q(1:1,1:1)=>output%dummy(2:2);output%o3(1:1,1:1)=>output%dummy(2:2)
    output%l(1:1,1:1)=>output%dummy(2:2);output%spd(1:1,1:1)=>output%dummy(2:2)
    output%svd(1:1,1:1)=>output%dummy(2:2);output%nhx(1:1,1:1)=>output%dummy(2:2)
    output%gfl(1:1,1:1,1:1)=>output%dummy(3:3)
    output%ready=.true.
    status=0
    goto 900
800 ignored=release_spectral_field(output)
900 error_number=saved_errno
    call ieee_set_status(saved)
  end function
end module distributed_spectral_field_storage_port
