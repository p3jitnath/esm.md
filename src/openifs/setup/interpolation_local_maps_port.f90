!> Construct local interpolation maps in their original rounded order.
module forecast_interpolation_local_maps
  use iso_fortran_env,only:int32,int64,real64
  use iso_c_binding,only:c_ptr,c_f_pointer,c_int
  use ieee_exceptions,only:ieee_status_type,ieee_get_status,ieee_set_status
  use forecast_interpolation_state_types,only:native_interpolation_state
  implicit none
  private
  public :: native_interpolation_grid_parameters,create_interpolation_local_maps
  public :: release_interpolation_local_maps
  !> Describe the live latitude grid and the local region in source indices.
  !! All members are dimensionless int32 counts or indices. Extended global
  !! rows have bounds-1:NDGLG+2. Local physical rows use1:NDGENL. NFRSTLOFF
  !! converts a local row to its global row; NPTRFLOFF selects its map slice.
  !! These fields are projected from the actual geometry and partition owner.
  type :: native_interpolation_grid_parameters
    integer(int32) :: ndglg=0,ndlon=0,ndgsag=-1,ndgeng=0,ndgsal=1,ndgenl=0
    integer(int32) :: ngptot=0,ndguxl=0,ndlung=1,ndluxg=0,ndgung=0,ndguxg=0
    integer(int32) :: ndsur1=3,ndlsur=0,nptrfloff=0,nfrstloff=0
    integer(int32) :: myfrstactlat=0,mylstactlat=0,nstencilwide=2,ndgsur=2
  end type
  interface
    function errno_address()bind(C,name="__errno_location")result(address)
      import c_ptr
      type(c_ptr)::address
    end function
  end interface
contains
  !> Build only the local SLCSET stage before its collective/SLRSET children.
  !! The enclosing parent agrees this status on every rank before it enters
  !! communication. KSTA/KONL have first lower bound-1 and second bound1;
  !! KLOENG is global-1:NDGLG+2. KFRSTLAT/KLSTLAT are one-based region lists.
  !! KASET/KBSET select north-south/west-east regions, not spectral groups.
  !! The shared source supports SL at width25 and RI/RO at widths0:63 with
  !! positive maximum. Both routes use the global spherical two-point stencil.
  !! It retains unused NSLEXT rows and all source-unwritten caller members.
  !! New arrays are staged privately. Status0 publishes the local stage,
  !!1 is allocation failure and2 refuses with all caller state unchanged.
  !! allocator_status is the raw native allocation result, or0 otherwise.
  integer(int32) function create_interpolation_local_maps(state,grid,ksta,konl,kloeng, &
      kfrstlat,klstlat,kaset,kbset,allocator_status)result(status)
    type(native_interpolation_state),intent(inout)::state
    type(native_interpolation_grid_parameters),intent(in)::grid
    integer(int32),intent(in)::ksta(-1:,:),konl(-1:,:),kloeng(-1:)
    integer(int32),intent(in)::kfrstlat(:),klstlat(:),kaset,kbset
    integer(int32),intent(out)::allocator_status
    type(native_interpolation_state)::pending
    real(real64),allocatable::start_fraction(:),final_fraction(:)
    integer(int32),allocatable::imap(:,:)
    integer::a,n,w,west,east,north,south,lo,hi,local,global,row,j
    integer::first,last,first_core,last_core,longitude,point,remaining,core_row
    integer::halo_start,halo_end,halo_count,offset,total,map_count,extent
    integer::allocation_status,ignored
    integer(int64)::sum_points,bytes,point_limit
    real(real64)::rlo,rhi,min_fraction,max_fraction,one_point,west_gap,east_gap
    real(real64)::rlength,west_width,east_width,temporary,other
    logical::radiation,has_halo
    status=2;allocator_status=0
    n=grid%ndglg
    if(n<2.or.n>8192.or.mod(n,2)/=0)return
    if(grid%ndlon<1.or.grid%ndlon>32768)return
    if(grid%ndgsag/=-1.or.grid%ndgeng/=n+2.or.grid%ndgsal/=1)return
    if(grid%nstencilwide/=2.or.grid%ndgsur/=2.or.grid%ndsur1/=3)return
    if(grid%ndlsur/=grid%ndlon+3.or.grid%ndlung/=1)return
    if(grid%ndgenl<1.or.grid%ndgenl>n)return
    if(grid%ngptot<1.or.grid%ngptot>268435456)return
    if(kaset<1.or.kaset>size(kfrstlat).or.kaset>size(klstlat))return
    if(kbset<1.or.kbset>size(ksta,2).or.kbset>size(konl,2))return
    if(size(kloeng)<n+4.or.any(shape(ksta)/=shape(konl)))return
    if(size(ksta,1)<n+4)return
    if(state%nslpad/=0)return
    radiation=state%cver=='RI'.or.state%cver=='RO'
    if(.not.radiation.and.state%cver/='SL')return
    if(radiation)then
      north=state%nslwiden;south=state%nslwides
      west=state%nslwidew;east=state%nslwidee
      if(min(north,south,west,east)<0.or.max(north,south,west,east)>63)return
      w=max(north,south,west,east)
      if(w==0)return
    else
      w=state%nslwide
      if(w/=25)return
      north=w;south=w;west=w;east=w
    end if
    if(allocated(state%nloeng))return
    if(allocated(state%nslsta))return
    if(allocated(state%nslonl))return
    if(allocated(state%nsloff))return
    if(.not.radiation)then
      if(allocated(state%nslmap))return
    end if
    if(allocated(state%nslcore))return
    if(allocated(state%nslext))return
    if(allocated(state%mask_sl1))return
    if(allocated(state%mask_sl2))return
    if(allocated(state%mask_sld))return
    first_core=kfrstlat(kaset);last_core=klstlat(kaset)
    if(first_core<1.or.last_core>n.or.last_core<first_core)return
    if(grid%myfrstactlat<first_core.or.grid%mylstactlat>last_core)return
    if(grid%myfrstactlat>grid%mylstactlat)return
    if(grid%nfrstloff/=first_core-1)return
    if(grid%ndgenl/=last_core-first_core+1)return
    if(grid%nptrfloff+1<lbound(ksta,1))return
    if(grid%nptrfloff+grid%ndgenl>ubound(ksta,1))return
    do global=-1,n+2
      if(kloeng(global)<1.or.kloeng(global)>grid%ndlon)return
    end do
    sum_points=0_int64
    do local=1,grid%ndgenl
      row=grid%nptrfloff+local
      a=konl(row,kbset)
      if(a<0.or.a>grid%ndlon)return
      if(a>0)then
        global=grid%nfrstloff+local
        if(ksta(row,kbset)<1)return
        if(int(ksta(row,kbset),int64)+a-1>kloeng(global))return
      end if
      sum_points=sum_points+a
    end do
    if(sum_points/=grid%ngptot)return
    lo=1-north;hi=grid%ndgenl+south
    first=max(-1,grid%myfrstactlat-north)-grid%nfrstloff
    last=min(n+2,grid%mylstactlat+south)-grid%nfrstloff
    if(first<lo.or.last>hi.or.first>last)return
    ! Check every fraction reader before allocations or rounded calculations.
    do local=first,last
      global=local+grid%nfrstloff
      first_core=max(grid%myfrstactlat,global-w)-grid%nfrstloff
      last_core=min(grid%mylstactlat,global+w)-grid%nfrstloff
      if(first_core<1.or.last_core>grid%ndgenl.or.first_core>last_core)return
    end do
    bytes=4_int64*(int(n+4,int64)+3_int64*(hi-lo+1)+grid%ngptot)
    bytes=bytes+4_int64*(3_int64*grid%ndlon)*(hi-lo+1)
    if(bytes>64_int64*1024**3)return
    pending%CVER=state%CVER
    pending%NSLGROUP=state%NSLGROUP
    pending%NASLB1=state%NASLB1
    pending%NASLB1_TRUE=state%NASLB1_TRUE
    pending%NSLPAD=state%NSLPAD
    pending%LSLT_ARRAYS_INIT=state%LSLT_ARRAYS_INIT
    pending%LSLONDEM=state%LSLONDEM
    pending%LSLONDEM_ACTIVE=state%LSLONDEM_ACTIVE
    pending%NUNUSEDHALO=state%NUNUSEDHALO
    pending%DISTUNUSEDHALO=state%DISTUNUSEDHALO
    pending%NSLPROCS=state%NSLPROCS
    pending%NSLRPT=state%NSLRPT
    pending%NSLSPT=state%NSLSPT
    pending%NSLWIDEN=state%NSLWIDEN
    pending%NSLWIDES=state%NSLWIDES
    pending%NSLWIDEE=state%NSLWIDEE
    pending%NSLWIDEW=state%NSLWIDEW
    pending%NSLWIDE=state%NSLWIDE
    pending%NDGLG=state%NDGLG
    pending%NDLON=state%NDLON
    pending%NDGSAG=state%NDGSAG
    pending%NDGENG=state%NDGENG
    pending%NDGSAL=state%NDGSAL
    pending%NDGENL=state%NDGENL
    pending%NDGSAH=state%NDGSAH
    pending%NDGENH=state%NDGENH
    pending%NGPTOT=state%NGPTOT
    pending%NDGUXL=state%NDGUXL
    pending%NDLUNG=state%NDLUNG
    pending%NDLUXG=state%NDLUXG
    pending%NDGUNG=state%NDGUNG
    pending%NDGUXG=state%NDGUXG
    pending%NDSUR1=state%NDSUR1
    pending%NDLSUR=state%NDLSUR
    pending%NDGSUR=state%NDGSUR
    pending%NPTRFLOFF=state%NPTRFLOFF
    pending%NFRSTLOFF=state%NFRSTLOFF
    pending%MYFRSTACTLAT=state%MYFRSTACTLAT
    pending%MYLSTACTLAT=state%MYLSTACTLAT
    pending%ndglg=grid%ndglg
    pending%ndlon=grid%ndlon
    pending%ndgsag=grid%ndgsag
    pending%ndgeng=grid%ndgeng
    pending%ndgsal=grid%ndgsal
    pending%ndgenl=grid%ndgenl
    pending%ngptot=grid%ngptot
    pending%ndguxl=0
    if(.not.radiation)pending%ndguxl=grid%ndguxl
    pending%ndlung=0
    if(.not.radiation)pending%ndlung=grid%ndlung
    pending%ndluxg=0
    if(.not.radiation)pending%ndluxg=grid%ndluxg
    pending%ndgung=0
    if(.not.radiation)pending%ndgung=grid%ndgung
    pending%ndguxg=0
    if(.not.radiation)pending%ndguxg=grid%ndguxg
    pending%ndsur1=grid%ndsur1
    pending%ndlsur=grid%ndlsur
    pending%nptrfloff=grid%nptrfloff
    pending%nfrstloff=grid%nfrstloff
    pending%myfrstactlat=grid%myfrstactlat
    pending%mylstactlat=grid%mylstactlat
    pending%ndgsah=max(-1,grid%nfrstloff+1-north)-grid%nfrstloff
    pending%ndgenh=min(n+2,grid%ndgenl+grid%nfrstloff+south)-grid%nfrstloff
    pending%nslgroup=1
    if(radiation)pending%nslgroup=2
    pending%nslwide=w
    if(.not.radiation)then
      pending%nslwiden=w;pending%nslwides=w
      pending%nslwidew=w;pending%nslwidee=w
    end if
    status=1
    allocate(start_fraction(n),final_fraction(n),stat=allocation_status)
    if(allocation_status/=0)goto900
    if(.not.radiation)then
      allocate(imap(4,n),stat=allocation_status)
      if(allocation_status/=0)goto900
    end if
    allocate(pending%nloeng(-1:n+2),stat=allocation_status)
    if(allocation_status/=0)goto900
    pending%nloeng=kloeng(-1:n+2)
    allocate(pending%nslsta(lo:hi),stat=allocation_status)
    if(allocation_status/=0)goto900
    allocate(pending%nslonl(lo:hi),stat=allocation_status)
    if(allocation_status/=0)goto900
    allocate(pending%nsloff(lo:hi),stat=allocation_status)
    if(allocation_status/=0)goto900
    pending%nslsta=-999999999
    pending%nslonl=-999999999
    pending%nsloff=-999999999
    do local=1,grid%ndgenl
      row=grid%nptrfloff+local
      if(konl(row,kbset)==0)cycle
      global=grid%nfrstloff+local
      j=ksta(row,kbset)-1
      a=j+konl(row,kbset)-1
      start_fraction(local)=real(j,real64)/real(kloeng(global),real64)
      final_fraction(local)=real(a,real64)/real(kloeng(global),real64)
    end do
    total=0;map_count=0
    west_width=real(west-1,real64)
    east_width=real(east-1,real64)
    do local=first,last
      global=local+grid%nfrstloff
      first_core=max(grid%myfrstactlat,global-w)-grid%nfrstloff
      last_core=min(grid%mylstactlat,global+w)-grid%nfrstloff
      min_fraction=1.0_real64;max_fraction=0.0_real64
      has_halo=.false.
      do row=first_core,last_core
        if(konl(grid%nptrfloff+row,kbset)==0)cycle
        has_halo=.true.
        min_fraction=min(min_fraction,start_fraction(row))
        max_fraction=max(max_fraction,final_fraction(row))
      end do
      halo_start=0;halo_count=0;offset=0
      if(has_halo)then
        one_point=0.0_real64;west_gap=0.0_real64;east_gap=0.0_real64
        do row=max(-1,global-2),min(n+2,global+2)
          rlength=real(kloeng(row),real64)
          temporary=1.0_real64/rlength
          one_point=max(one_point,temporary)
          temporary=west_width/rlength
          west_gap=max(west_gap,temporary)
          temporary=east_width/rlength
          east_gap=max(east_gap,temporary)
        end do
        west_gap=west_gap+one_point
        east_gap=east_gap+one_point
        rlength=real(kloeng(global),real64)
        west_gap=west_gap*rlength
        west_gap=west_gap+0.5_real64
        east_gap=east_gap*rlength
        east_gap=east_gap+0.5_real64
        west_gap=west_gap/rlength
        east_gap=east_gap/rlength
        min_fraction=min_fraction-west_gap
        max_fraction=max_fraction+east_gap
        temporary=min_fraction*rlength
        other=max_fraction*rlength
        temporary=temporary-1.0_real64
        other=other+2.0_real64
        halo_start=floor(temporary)
        halo_end=ceiling(other)
        if(global<1.or.global>n)then
          j=kloeng(global)/2
          if(halo_start>j)then
            halo_start=halo_start-j;halo_end=halo_end-j
          else
            halo_start=halo_start+j;halo_end=halo_end+j
          end if
        end if
        halo_count=halo_end-halo_start+1
        point_limit=int(total,int64)+halo_count
        if(halo_count>=kloeng(global).or.global<=north.or.global>=n-south+1)then
          halo_start=1;halo_count=kloeng(global)
          offset=total+1
          point_limit=int(total,int64)+halo_count+3
        else
          offset=total
        end if
        if(point_limit>268435456_int64)then
          status=2
          goto900
        end if
        total=int(point_limit)
      end if
      pending%nslsta(local)=halo_start
      pending%nslonl(local)=halo_count
      pending%nsloff(local)=offset
      if(.not.radiation.and.global>=1.and.global<=n)then
        map_count=map_count+1
        imap(:,map_count)=[global,halo_start,halo_count,offset]
      end if
    end do
    if(.not.radiation)then
      allocate(pending%nslmap(4,map_count),stat=allocation_status)
      if(allocation_status/=0)goto900
      pending%nslmap=imap(:,1:map_count)
    end if
    allocate(pending%nslcore(grid%ngptot),stat=allocation_status)
    if(allocation_status/=0)goto900
    core_row=1;remaining=konl(grid%nptrfloff+1,kbset)
    do point=1,grid%ngptot
      if(remaining==0)then
        do
          core_row=core_row+1
          remaining=konl(grid%nptrfloff+core_row,kbset)
          if(remaining>0)exit
        end do
      end if
      remaining=remaining-1
      offset=pending%nsloff(core_row)
      offset=offset+konl(grid%nptrfloff+core_row,kbset)
      offset=offset-remaining
      offset=offset-1
      offset=offset+ksta(grid%nptrfloff+core_row,kbset)
      offset=offset-pending%nslsta(core_row)
      offset=offset-point
      pending%nslcore(point)=offset+1+point
    end do
    allocate(pending%nslext(1-grid%ndlon:2*grid%ndlon,lo:hi),stat=allocation_status)
    if(allocation_status/=0)goto900
    first=max(-1,kfrstlat(kaset)-north)-grid%nfrstloff
    last=min(n+2,klstlat(kaset)+south)-grid%nfrstloff
    do local=first,last
      global=local+grid%nfrstloff
      a=kloeng(global)
      do longitude=1-grid%ndlon,2*grid%ndlon
        j=longitude
        if(global<1.or.global>n)j=j+a/2
        j=j-pending%nslsta(local)
        j=j+a
        j=mod(j,a)+1
        if(pending%nslsta(local)==1.and.pending%nslonl(local)==a)then
          if(j==a)j=0
        end if
        pending%nslext(longitude,local)=j
      end do
    end do
    pending%naslb1_true=total
    pending%naslb1=((total-1)/1024+1)*1024+29
    if(pending%naslb1>268435456)then
      status=2
      goto900
    end if
    extent=pending%naslb1+4
    allocate(pending%mask_sl1(extent),stat=allocation_status)
    if(allocation_status/=0)goto900
    allocate(pending%mask_sl2(extent),stat=allocation_status)
    if(allocation_status/=0)goto900
    allocate(pending%mask_sld(extent),stat=allocation_status)
    if(allocation_status/=0)goto900
    pending%mask_sl1=0;pending%mask_sl2=0;pending%mask_sld=0
    call move_alloc(pending%nloeng,state%nloeng)
    call move_alloc(pending%nslsta,state%nslsta)
    call move_alloc(pending%nslonl,state%nslonl)
    call move_alloc(pending%nsloff,state%nsloff)
    if(.not.radiation)call move_alloc(pending%nslmap,state%nslmap)
    call move_alloc(pending%nslcore,state%nslcore)
    call move_alloc(pending%nslext,state%nslext)
    call move_alloc(pending%mask_sl1,state%mask_sl1)
    call move_alloc(pending%mask_sl2,state%mask_sl2)
    call move_alloc(pending%mask_sld,state%mask_sld)
    state%ndglg=pending%ndglg
    state%ndlon=pending%ndlon
    state%ndgsag=pending%ndgsag
    state%ndgeng=pending%ndgeng
    state%ndgsal=pending%ndgsal
    state%ndgenl=pending%ndgenl
    state%ndgsah=pending%ndgsah
    state%ndgenh=pending%ndgenh
    state%ngptot=pending%ngptot
    state%ndguxl=pending%ndguxl
    state%ndlung=pending%ndlung
    state%ndluxg=pending%ndluxg
    state%ndgung=pending%ndgung
    state%ndguxg=pending%ndguxg
    state%ndsur1=pending%ndsur1
    state%ndlsur=pending%ndlsur
    state%nptrfloff=pending%nptrfloff
    state%nfrstloff=pending%nfrstloff
    state%myfrstactlat=pending%myfrstactlat
    state%mylstactlat=pending%mylstactlat
    state%nslgroup=pending%nslgroup
    state%nslwiden=pending%nslwiden
    state%nslwides=pending%nslwides
    state%nslwidew=pending%nslwidew
    state%nslwidee=pending%nslwidee
    state%nslwide=pending%nslwide
    state%naslb1=pending%naslb1
    state%naslb1_true=pending%naslb1_true
    status=0
900 continue
    allocator_status=allocation_status
    ignored=release_interpolation_local_maps(pending)
  end function

  !> Release only the ten local map owners, preserving other state and status.
  !! The complete parent releases communication owners before this entry.
  integer(int32) function release_interpolation_local_maps(state,include_nslmap)result(status)
    type(native_interpolation_state),intent(inout)::state
    logical,optional,intent(in)::include_nslmap
    logical::owns_map
    type(ieee_status_type)::incoming
    integer(c_int),pointer,volatile::error_number
    integer(c_int)::saved_errno
    status=0
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    if(allocated(state%nloeng))deallocate(state%nloeng)
    if(allocated(state%nslsta))deallocate(state%nslsta)
    if(allocated(state%nslonl))deallocate(state%nslonl)
    if(allocated(state%nsloff))deallocate(state%nsloff)
    owns_map=state%cver=='SL'
    if(present(include_nslmap))owns_map=include_nslmap
    if(owns_map)then
      if(allocated(state%nslmap))deallocate(state%nslmap)
    end if
    if(allocated(state%nslcore))deallocate(state%nslcore)
    if(allocated(state%nslext))deallocate(state%nslext)
    if(allocated(state%mask_sl1))deallocate(state%mask_sl1)
    if(allocated(state%mask_sl2))deallocate(state%mask_sl2)
    if(allocated(state%mask_sld))deallocate(state%mask_sld)
    call ieee_set_status(incoming)
    error_number=saved_errno
  end function
end module forecast_interpolation_local_maps
