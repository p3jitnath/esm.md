!> Build source SUMP owners from a live public transform partition.
module forecast_distributed_partition_computation
use iso_c_binding,only:c_int,c_int64_t,c_ptr,c_f_pointer
use forecast_distributed_partition_types,only:native_distributed_partition
use forecast_grid_dimensions,only:native_grid_dimensions
use forecast_public_transform,only:native_transform_control,native_transform_resolution
use forecast_geometry_stream,only:native_geometry_stream,initialize_stream_geometry_metadata,release_stream_geometry_metadata
use forecast_distributed_partition_collectives,only:agree_distributed_partition_status,abort_distributed_partition
use forecast_distributed_block_size,only:initialize_operational_distributed_block_size
implicit none
private
public::initialize_complete_distributed_partition,release_distributed_partition_arrays,has_partition_owners
include 'trans_inq.h'
include 'ini_spec_dist.h'
interface
 function errno_address() bind(C,name='__errno_location') result(address)
  import c_ptr
  type(c_ptr)::address
 end function
end interface
contains
!> Own thirty-four source arrays. All counts and indices are dimensionless.
!! STATE and STREAM must have no live owners. DIMENSIONS changes only NPROMA
!! at SUOPTPROMA. CONTROL and RESOLUTION are borrowed, live public objects.
!! PHYSICAL_LONGITUDES has NDGLG physical rows, without global halo cells.
!! This selected hydrostatic entry supports the live T1279,L137,one-thread
!! forecast and derives every local extent from the actual public partition.
!! All processes enter each status agreement in the same source order.
integer(c_int) function initialize_complete_distributed_partition(state,dimensions,stream,control,resolution, &
 physical_longitudes,threads) result(status)
 type(native_distributed_partition),intent(inout)::state
 type(native_grid_dimensions),intent(inout)::dimensions
 type(native_geometry_stream),intent(inout)::stream
 type(native_transform_control),intent(in)::control
 type(native_transform_resolution),intent(in)::resolution
 integer(c_int),intent(in)::physical_longitudes(:),threads
 integer(c_int),allocatable::iglobal(:,:),inumcpp(:),imyms(:),inumsvf(:),iultpp(:)
 integer(c_int)::h,v,maxwave,row_end,allocation_status,local_status
 integer(c_int)::iprused,ilevpp,irest,j,jb,jm,jlev,iseq,ilbeg,ilend
 integer(c_int)::insef,irestf,iiter,ibset,ispec2rem,iave,im,inm,iii
 integer(c_int)::igl,jgl,jl,ja,iproc,ind,iglg,jlon,ilong,iproma,igpblks,i
 integer(c_int)::provider_nspec2g,provider_smax,provider_resolutions,provider_h,provider_w,provider_v
 integer(c_int)::provider_lei3,provider_spolegl
 integer(c_int)::original_nproma
 integer(c_int64_t)::point_sum,workspace_count
 logical::balanced,provider_lam,stream_started
 status=2_c_int
 local_status=2_c_int
 stream_started=.false.
 h=control%nprtrw
 v=control%nprtrv
 if(.not.control%message_ready.or..not.control%environment_ready)return
 if(state%phase/=0.or.has_partition_owners(state))return
 if(allocated(stream%nbsetlev).or.allocated(stream%nloeng))return
 if(control%nproc<1.or.control%nproc>65536)return
 if(h<1.or.v<1.or.int(h,c_int64_t)*v/=control%nproc)return
 if(control%mysetw<1.or.control%mysetw>h.or.control%mysetv<1.or.control%mysetv>v)return
 if(control%myproc/=(control%mysetw-1)*v+control%mysetv)return
 if(control%nprtrns/=h)return
 if(dimensions%nsmax/=1279.or.dimensions%ndglg/=2560.or.dimensions%nflevg/=137)return
 if(dimensions%ncmax<0.or.dimensions%ncmax>4096.or.dimensions%nmsmax<0.or.dimensions%nmsmax>4096)return
 if(dimensions%ndlon<1.or.dimensions%ndlon>32768.or.dimensions%ndgsag>1)return
 if(dimensions%ndgeng<dimensions%ndglg.or.dimensions%ndguxg<1)return
 if(v>dimensions%nflevg+1.or.threads/=1)return
 if(size(physical_longitudes)/=dimensions%ndglg)return
 point_sum=0_c_int64_t
 do j=1,dimensions%ndglg
  if(physical_longitudes(j)<1.or.physical_longitudes(j)>dimensions%ndlon)return
  point_sum=point_sum+physical_longitudes(j)
 end do
 if(point_sum>huge(0_c_int).or.point_sum<1)return
 if(resolution%resolution<1.or.resolution%truncation/=dimensions%nsmax.or. &
    resolution%row_count/=dimensions%ndglg)return
 if(control%regions_ns<1.or.control%regions_ew<1)return
 if(.not.allocated(control%n_regions).or..not.allocated(control%ngpset2pe))return
 if(size(control%n_regions)/=control%regions_ns)return
 if(size(control%ngpset2pe,1)/=control%regions_ew.or.size(control%ngpset2pe,2)/=control%regions_ns)return
 if(any(control%n_regions<1).or.any(control%n_regions>control%regions_ew))return
 workspace_count=0_c_int64_t
 do j=1,control%regions_ns
  workspace_count=workspace_count+control%n_regions(j)
 end do
 if(workspace_count/=control%nproc)return
 workspace_count=int(dimensions%ndlon,c_int64_t)*dimensions%ndglg
 if(workspace_count>huge(0_c_int))return
 maxwave=max(dimensions%nsmax,dimensions%nmsmax)
 row_end=dimensions%ndgeng+control%regions_ns-1
 original_nproma=dimensions%nproma
 state%borrowed_resolution=resolution%resolution
 local_status=0
 allocate(iglobal(dimensions%ndlon,dimensions%ndglg),stat=allocation_status)
 if(allocation_status/=0)local_status=1
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 local_status=0
 allocate(inumcpp(h),stat=allocation_status)
 if(allocation_status==0)allocate(imyms(dimensions%ncmax+1),stat=allocation_status)
 if(allocation_status==0)allocate(inumsvf(v+1),stat=allocation_status)
 if(allocation_status==0)allocate(iultpp(h),stat=allocation_status)
 if(allocation_status/=0)local_status=1
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 call allocate_phase_zero(state,dimensions,control,h,v,maxwave,row_end,local_status)
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 state%phase=1
 iprused=min(dimensions%nflevg+1,v)
 ilevpp=dimensions%nflevg/v
 irest=dimensions%nflevg-ilevpp*v
 do jb=1,v
  if(jb<=irest)then
   state%numll(jb)=ilevpp+1
  else
   state%numll(jb)=ilevpp
  end if
 end do
 state%numll(iprused+1:v+1)=0
 state%nflevl=state%numll(control%mysetv)
 state%nflevlmx=state%numll(1)
 state%npsurf(1:iprused)=0
 state%npsurf(iprused)=1
 state%npsp=state%npsurf(control%mysetv)
 state%nflsur=state%nflevl
 call trans_inq(kresol=resolution%resolution,kspec=state%nspec,kspec2=state%nspec2, &
  kspec2g=provider_nspec2g,kspec2mx=state%nspec2mx,knump=state%nump,kumpp=state%numpp, &
  kpossp=state%npossp,kptrms=state%nptrms,kallms=state%nallms,kdim0g=state%ndim0g, &
  ksmax=provider_smax,kdef_resol=provider_resolutions,ldlam=provider_lam, &
  klei3=provider_lei3,kspolegl=provider_spolegl)
 if(provider_smax/=dimensions%nsmax.or.provider_lam.or.provider_resolutions<1)call abort_distributed_partition()
 if(provider_nspec2g/=dimensions%nspec2g.or.state%nspec2/=2*state%nspec)call abort_distributed_partition()
 if(state%nump<0.or.state%nump>dimensions%ncmax+1.or.state%nspec2<0)call abort_distributed_partition()
 call ini_spec_dist(dimensions%ncmax,dimensions%ncmax,h,control%mysetw, &
  kprocm=state%nprocm,kumpp=inumcpp,kmyms=imyms)
 state%numcp=inumcpp(control%mysetw)
 call trans_inq(kresol=resolution%resolution,kfrstlat=state%nfrstlat,klstlat=state%nlstlat, &
  kfrstloff=state%nfrstloff,kptrlat=state%nptrlat,kptrfrstlat=state%nptrfrstlat, &
  kptrlstlat=state%nptrlstlat,kptrfloff=state%nptrfloff,konl=state%nonl(1:,:),ksta=state%nsta(1:,:), &
  ldsplitlat=state%lsplitlat,kgptot=state%ngptot,kgptotg=state%ngptotg, &
  kgptotmx=state%ngptotmx,kgptotl=state%ngptotl,kprtrw=provider_h,kmysetw=provider_w, &
  kmysetv=provider_v,kmy_region_ns=state%my_region_ns,kmy_region_ew=state%my_region_ew)
 if(provider_h/=h.or.provider_w/=control%mysetw.or.provider_v/=control%mysetv)call abort_distributed_partition()
 if(state%my_region_ns<1.or.state%my_region_ns>control%regions_ns)call abort_distributed_partition()
 if(state%my_region_ew<1.or.state%my_region_ew>control%n_regions(state%my_region_ns))call abort_distributed_partition()
 if(state%ngptot<0.or.state%ngptotmx<state%ngptot.or.state%ngptotg/=point_sum)call abort_distributed_partition()
 call trans_inq(kresol=resolution%resolution,kultpp=iultpp,kptrls=state%nptrls)
 state%phase=2
 state%ndgll=iultpp(control%mysetw)
 state%ndgsal=1
 state%ndgenl=state%nlstlat(state%my_region_ns)-state%nfrstloff
 if(state%nfrstlat(state%my_region_ns)+iultpp(control%mysetw)<=dimensions%ndguxg)then
  state%ndguxl=iultpp(control%mysetw)
 else
  state%ndguxl=dimensions%ndguxg-state%nfrstlat(state%my_region_ns)+1
 end if
 state%ndgunl=1
 state%myfrstactlat=state%nfrstlat(state%my_region_ns)
 state%mylstactlat=state%nlstlat(state%my_region_ns)
 ilbeg=state%nfrstlat(state%my_region_ns)-state%nfrstloff
 ilend=state%nlstlat(state%my_region_ns)-state%nfrstloff
 do jgl=ilbeg,ilend
  if(state%nonl(state%nptrfloff+jgl,state%my_region_ew)/=0)exit
  state%myfrstactlat=state%myfrstactlat+1
 end do
 do jgl=ilend,ilbeg,-1
  if(state%nonl(state%nptrfloff+jgl,state%my_region_ew)/=0)exit
  state%mylstactlat=state%mylstactlat-1
 end do
 insef=state%nspec2/v
 irestf=state%nspec2-insef*v
 state%nptrsv(1)=1
 do jb=2,v+1
  if(jb-1<=irestf)then
   state%nptrsv(jb)=state%nptrsv(jb-1)+insef+1
  else
   state%nptrsv(jb)=state%nptrsv(jb-1)+insef
  end if
 end do
 iiter=0
 do
  ibset=min(v,state%nump)
  balanced=iiter/=0
  if(balanced)then
   do jb=min(v,2),ibset
    if(state%nptrmf(jb)==-999)balanced=.false.
   end do
  end if
  if(balanced)exit
  iiter=iiter+1
  state%nptrmf(:)=-999
  inumsvf(:)=0
  state%nptrmf(1)=1
  state%nptrmf(ibset+1:v+1)=state%nump+1
  if(state%nump>0)then
   ispec2rem=state%nspec2
   iave=(ispec2rem-1)/ibset+1-iiter
   do jm=state%nump,1,-1
    im=imyms(jm)
    inm=2*(dimensions%nsmax-im+1)
    if(inumsvf(ibset)<iave)then
     inumsvf(ibset)=inumsvf(ibset)+inm
    else
     state%nptrmf(ibset)=jm+1
     ispec2rem=ispec2rem-inumsvf(ibset)
     ibset=ibset-1
     if(ibset==0)call abort_distributed_partition()
     iave=(ispec2rem-1)/ibset+1-iiter
     inumsvf(ibset)=inumsvf(ibset)+inm
    end if
   end do
  end if
 end do
 state%nptrsvf(1)=1
 do jb=2,v+1
  state%nptrsvf(jb)=state%nptrsvf(jb-1)+inumsvf(jb-1)
 end do
 state%nspstaf(:)=-999
 iii=1
 do jm=state%nptrmf(control%mysetv),state%nptrmf(control%mysetv+1)-1
  state%nspstaf(imyms(jm))=iii
  iii=iii+2*(dimensions%nsmax-imyms(jm)+1)
 end do
 state%nptrll(1)=1
 do jb=2,iprused+1
  state%nptrll(jb)=state%nptrll(jb-1)+state%numll(jb-1)
 end do
 state%nbsetsp=iprused
 iseq=0
 do jb=1,v
  do jlev=1,state%numll(jb)
   iseq=iseq+1
   state%nbsetlev(iseq)=jb
  end do
 end do
 state%phase=3
 local_status=initialize_stream_geometry_metadata(stream,control%myproc,control%nproc,state%nbsetsp, &
  dimensions%nsmax,state%nbsetlev,physical_longitudes)
 stream_started=local_status==0
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 state%nspec2v=state%nptrsv(control%mysetv+1)-state%nptrsv(control%mysetv)
 state%nspec2vf=state%nptrsvf(control%mysetv+1)-state%nptrsvf(control%mysetv)
 state%nspec2v_nh=0
 local_status=initialize_operational_distributed_block_size(dimensions,state%ngptot,state%ngptotmx, &
  .false.,threads,state%npromm,state%npromnh)
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 state%ngpblks=(state%ngptot-1)/dimensions%nproma+1
 state%phase=4
 local_status=0
 allocate(state%nlongpp(dimensions%nproma,state%ngpblks),stat=allocation_status)
 if(allocation_status==0)allocate(state%nlatgpp(dimensions%nproma,state%ngpblks),stat=allocation_status)
 if(allocation_status/=0)local_status=1
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 state%ngptot_cap=state%ngptot
 state%phase=5
 call allocate_phase_two(state,local_status)
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 state%phase=6
 do jlev=1,state%nflevl
  state%mylevs(jlev)=state%nptrll(control%mysetv)+jlev-1
 end do
 do j=state%ndgsal,state%ndgenl
  state%mylats(j)=state%nfrstlat(state%my_region_ns)+j-state%ndgsal
 end do
 i=0
 iglobal(:,:)=0
 do jgl=1,dimensions%ndglg
  do jl=1,physical_longitudes(jgl)
   i=i+1
   iglobal(jl,jgl)=i
  end do
 end do
 i=0
 do jgl=state%nfrstlat(state%my_region_ns),state%nlstlat(state%my_region_ns)
  igl=state%nptrfrstlat(state%my_region_ns)+jgl-state%nfrstlat(state%my_region_ns)
  do jl=state%nsta(igl,state%my_region_ew),state%nsta(igl,state%my_region_ew)+state%nonl(igl,state%my_region_ew)-1
   i=i+1
   if(iglobal(jl,jgl)==0)call abort_distributed_partition()
   state%nglobalindex(i)=iglobal(jl,jgl)
   state%nglobalat(i)=jgl
  end do
 end do
 state%nglobalproc(:)=0
 do ja=1,control%regions_ns
  do jb=1,control%n_regions(ja)
   iproc=control%ngpset2pe(jb,ja)
   i=0
   do jgl=state%nfrstlat(ja),state%nlstlat(ja)
    igl=state%nptrfrstlat(ja)+jgl-state%nfrstlat(ja)
    do jl=state%nsta(igl,jb),state%nsta(igl,jb)+state%nonl(igl,jb)-1
     ind=iglobal(jl,jgl)
     state%nglobalproc(ind)=iproc
     i=i+1
     state%nlocalindex(ind)=i
    end do
   end do
  end do
 end do
 state%nlatgpp(:,:)=-99999
 state%nlongpp(:,:)=-99999
 iproma=0
 igpblks=1
 do jgl=state%ndgsal,state%ndgenl
  iglg=state%mylats(jgl)
  do jlon=1,state%nonl(state%nptrfloff+jgl,state%my_region_ew)
   ilong=state%nsta(state%nptrfloff+jgl,state%my_region_ew)+jlon-1
   iproma=iproma+1
   if(iproma>dimensions%nproma)then
    iproma=1
    igpblks=igpblks+1
   end if
   state%nlatgpp(iproma,igpblks)=iglg
   state%nlongpp(iproma,igpblks)=ilong
  end do
 end do
 if(igpblks/=state%ngpblks)call abort_distributed_partition()
 deallocate(iglobal)
 state%phase=7
 status=0
 return
900 continue
 if(stream_started)call release_stream_geometry_metadata(stream)
 local_status=release_distributed_partition_arrays(state)
 dimensions%nproma=original_nproma
 if(status==1)call set_allocation_errno()
end function
!> Allocate the exact first source owner block in declaration order.
subroutine allocate_phase_zero(state,dimensions,control,h,v,maxwave,row_end,status)
 type(native_distributed_partition),intent(inout)::state
 type(native_grid_dimensions),intent(in)::dimensions
 type(native_transform_control),intent(in)::control
 integer(c_int),intent(in)::h,v,maxwave,row_end
 integer(c_int),intent(out)::status
 integer::allocation_status
 status=1
 allocate(state%numll(v+1),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%npsurf(v),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%numpp(h),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nprocm(0:dimensions%ncmax),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrms(h),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%npossp(h+1),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nallms(maxwave+1),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%ndim0g(0:maxwave),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrls(h),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrsv(v+1),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrsvf(v+1),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrmf(v+1),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nspstaf(0:maxwave),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrll(v+1),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nsta(dimensions%ndgsag:row_end,control%regions_ew),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nonl(dimensions%ndgsag:row_end,control%regions_ew),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrfrstlat(control%regions_ns),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrlstlat(control%regions_ns),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nptrlat(dimensions%ndglg),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%lsplitlat(dimensions%ndglg),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nfrstlat(control%regions_ns),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nlstlat(control%regions_ns),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nbsetlev(dimensions%nflevg),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%ndlunl(dimensions%ndgsag:row_end,control%regions_ew),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%ndluxl(dimensions%ndgsag:row_end,control%regions_ew),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%ngptotl(control%regions_ns,control%regions_ew),stat=allocation_status)
 if(allocation_status/=0)return
 status=0
end subroutine
!> Allocate the exact final source owner block after local counts exist.
subroutine allocate_phase_two(state,status)
 type(native_distributed_partition),intent(inout)::state
 integer(c_int),intent(out)::status
 integer::allocation_status
 status=1
 allocate(state%mylevs(state%nflevl),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%mylats(state%ndgsal:state%ndgenl),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nglobalindex(state%ngptot),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nglobalat(state%ngptot),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nglobalproc(state%ngptotg),stat=allocation_status)
 if(allocation_status/=0)return
 allocate(state%nlocalindex(state%ngptotg),stat=allocation_status)
 if(allocation_status/=0)return
 status=0
end subroutine
!> Release only partition owners in the original source release order.
!! Scalars outside lifetime metadata retain their stored source values.
integer(c_int) function release_distributed_partition_arrays(state) result(status)
 type(native_distributed_partition),intent(inout)::state
 if(allocated(state%numll))deallocate(state%numll)
 if(allocated(state%npsurf))deallocate(state%npsurf)
 if(allocated(state%numpp))deallocate(state%numpp)
 if(allocated(state%nprocm))deallocate(state%nprocm)
 if(allocated(state%nptrms))deallocate(state%nptrms)
 if(allocated(state%npossp))deallocate(state%npossp)
 if(allocated(state%nallms))deallocate(state%nallms)
 if(allocated(state%ndim0g))deallocate(state%ndim0g)
 if(allocated(state%nptrls))deallocate(state%nptrls)
 if(allocated(state%nptrsv))deallocate(state%nptrsv)
 if(allocated(state%nptrsvf))deallocate(state%nptrsvf)
 if(allocated(state%nptrmf))deallocate(state%nptrmf)
 if(allocated(state%nspstaf))deallocate(state%nspstaf)
 if(allocated(state%nptrll))deallocate(state%nptrll)
 if(allocated(state%nsta))deallocate(state%nsta)
 if(allocated(state%nonl))deallocate(state%nonl)
 if(allocated(state%nptrfrstlat))deallocate(state%nptrfrstlat)
 if(allocated(state%nptrlstlat))deallocate(state%nptrlstlat)
 if(allocated(state%nptrlat))deallocate(state%nptrlat)
 if(allocated(state%lsplitlat))deallocate(state%lsplitlat)
 if(allocated(state%nfrstlat))deallocate(state%nfrstlat)
 if(allocated(state%nlstlat))deallocate(state%nlstlat)
 if(allocated(state%nbsetlev))deallocate(state%nbsetlev)
 if(allocated(state%ndlunl))deallocate(state%ndlunl)
 if(allocated(state%ndluxl))deallocate(state%ndluxl)
 if(allocated(state%ngptotl))deallocate(state%ngptotl)
 if(allocated(state%nlongpp))deallocate(state%nlongpp)
 if(allocated(state%nlatgpp))deallocate(state%nlatgpp)
 if(allocated(state%mylevs))deallocate(state%mylevs)
 if(allocated(state%mylats))deallocate(state%mylats)
 if(allocated(state%nglobalindex))deallocate(state%nglobalindex)
 if(allocated(state%nglobalat))deallocate(state%nglobalat)
 if(allocated(state%nglobalproc))deallocate(state%nglobalproc)
 if(allocated(state%nlocalindex))deallocate(state%nlocalindex)
 state%phase=0
 state%borrowed_resolution=0
 status=0
end function
logical function has_partition_owners(state) result(live)
 type(native_distributed_partition),intent(in)::state
 live=.false.
 live=live.or.allocated(state%numll)
 live=live.or.allocated(state%npsurf)
 live=live.or.allocated(state%numpp)
 live=live.or.allocated(state%nprocm)
 live=live.or.allocated(state%nptrms)
 live=live.or.allocated(state%npossp)
 live=live.or.allocated(state%nallms)
 live=live.or.allocated(state%ndim0g)
 live=live.or.allocated(state%nptrls)
 live=live.or.allocated(state%nptrsv)
 live=live.or.allocated(state%nptrsvf)
 live=live.or.allocated(state%nptrmf)
 live=live.or.allocated(state%nspstaf)
 live=live.or.allocated(state%nptrll)
 live=live.or.allocated(state%nsta)
 live=live.or.allocated(state%nonl)
 live=live.or.allocated(state%nptrfrstlat)
 live=live.or.allocated(state%nptrlstlat)
 live=live.or.allocated(state%nptrlat)
 live=live.or.allocated(state%lsplitlat)
 live=live.or.allocated(state%nfrstlat)
 live=live.or.allocated(state%nlstlat)
 live=live.or.allocated(state%nbsetlev)
 live=live.or.allocated(state%ndlunl)
 live=live.or.allocated(state%ndluxl)
 live=live.or.allocated(state%ngptotl)
 live=live.or.allocated(state%nlongpp)
 live=live.or.allocated(state%nlatgpp)
 live=live.or.allocated(state%mylevs)
 live=live.or.allocated(state%mylats)
 live=live.or.allocated(state%nglobalindex)
 live=live.or.allocated(state%nglobalat)
 live=live.or.allocated(state%nglobalproc)
 live=live.or.allocated(state%nlocalindex)
end function
subroutine set_allocation_errno()
 integer(c_int),pointer::error_value
 call c_f_pointer(errno_address(),error_value)
 error_value=12
end subroutine
end module forecast_distributed_partition_computation
