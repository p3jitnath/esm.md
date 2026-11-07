!> Compose the two source distributed partition parents with native owners.
module forecast_distributed_partition
use iso_c_binding,only:c_int,c_int64_t,c_double,c_ptr,c_f_pointer
use forecast_distributed_partition_types,only:native_distributed_partition
use forecast_distributed_process_controls,only:native_process_control,read_distributed_process_controls
use forecast_distributed_partition_computation,only:initialize_complete_distributed_partition, &
 release_distributed_partition_arrays,has_partition_owners
use forecast_distributed_transform_environment,only:initialize_distributed_transform_environment
use forecast_distributed_partition_collectives,only:agree_distributed_partition_status,abort_distributed_partition
use forecast_grid_dimensions,only:native_grid_dimensions
use forecast_geometry_stream,only:native_geometry_stream,release_stream_geometry_metadata
use forecast_global_grid_cutoffs,only:native_global_grid_cutoffs,initialize_global_grid_cutoffs,release_global_grid_cutoffs
use forecast_public_transform,only:native_transform_control,native_transform_resolution, &
 initialize_public_transform_messages,initialize_transform_resolution, &
 release_transform_environment_metadata,finish_public_transform_context
use physical_constant_setup_port,only:forecast_physical_constants
implicit none
private
public::native_distributed_partition,native_process_control,read_distributed_process_controls
public::create_owned_distributed_geometry_partition,create_owned_distributed_transform_partition
public::release_distributed_partition_arrays,release_owned_distributed_transform_partition
public::agree_distributed_partition_status
interface
 function errno_address() bind(C,name='__errno_location') result(address)
  import c_ptr
  type(c_ptr)::address
 end function
end interface
contains
!> Complete the source public setup, cutoff insertion and SUMP in that order.
!! All records are caller-owned native Fortran types. The public handle stays
!! live until all forecast consumers stop. Counts and indices are unitless;
!! CONSTANTS%RA is the sphere radius in metres. Only DIMENSIONS%NPROMA mutates.
!! PHYSICAL_LONGITUDES is contiguous INT32 with NDGLG active physical rows.
!! EXPECTED_WORLD is1:32; THREADS is the actual count,currently restricted to1.
!! A prestarted message context is reused when its actual world matches.
integer(c_int) function create_owned_distributed_geometry_partition(partition,dimensions,stream,control, &
 resolution,cutoffs,constants,text,expected_world,threads,physical_longitudes) result(status)
 type(native_distributed_partition),intent(inout)::partition
 type(native_grid_dimensions),intent(inout)::dimensions
 type(native_geometry_stream),intent(inout)::stream
 type(native_transform_control),intent(inout)::control
 type(native_transform_resolution),intent(inout)::resolution
 type(native_global_grid_cutoffs),intent(inout)::cutoffs
 type(forecast_physical_constants),intent(in)::constants
 character(len=*),intent(in)::text
 integer(c_int),intent(in)::expected_world,threads
 integer(c_int),contiguous,intent(in)::physical_longitudes(:)
 status=create_partition(partition,dimensions,stream,control,resolution,constants,text, &
  expected_world,threads,physical_longitudes,cutoffs)
end function
!> Complete the same source parent without the separate grid-cutoff insertion.
integer(c_int) function create_owned_distributed_transform_partition(partition,dimensions,stream,control, &
 resolution,constants,text,expected_world,threads,physical_longitudes) result(status)
 type(native_distributed_partition),intent(inout)::partition
 type(native_grid_dimensions),intent(inout)::dimensions
 type(native_geometry_stream),intent(inout)::stream
 type(native_transform_control),intent(inout)::control
 type(native_transform_resolution),intent(inout)::resolution
 type(forecast_physical_constants),intent(in)::constants
 character(len=*),intent(in)::text
 integer(c_int),intent(in)::expected_world,threads
 integer(c_int),contiguous,intent(in)::physical_longitudes(:)
 status=create_partition(partition,dimensions,stream,control,resolution,constants,text, &
  expected_world,threads,physical_longitudes)
end function
integer(c_int) function create_partition(partition,dimensions,stream,control,resolution,constants,text, &
 expected_world,threads,physical_longitudes,cutoffs) result(status)
 type(native_distributed_partition),intent(inout)::partition
 type(native_grid_dimensions),intent(inout)::dimensions
 type(native_geometry_stream),intent(inout)::stream
 type(native_transform_control),intent(inout)::control
 type(native_transform_resolution),intent(inout)::resolution
 type(forecast_physical_constants),intent(in)::constants
 character(len=*),intent(in)::text
 integer(c_int),intent(in)::expected_world,threads
 integer(c_int),contiguous,intent(in)::physical_longitudes(:)
 type(native_global_grid_cutoffs),optional,intent(inout)::cutoffs
 integer(c_int)::local_status,release_status,j,original_nproma
 logical::cutoffs_started
 status=2
 if(expected_world<1.or.expected_world>32)return
 if(partition%phase/=0.or.has_partition_owners(partition))return
 if(control%environment_ready.or.resolution%resolution/=0)return
 if(allocated(control%n_regions).or.allocated(control%ngpset2pe))return
 if(.not.fresh_owned_stream(stream))return
 if(present(cutoffs))then
  if(allocated(cutoffs%nmen).or.allocated(cutoffs%nmeng).or.allocated(cutoffs%ndglu))return
 end if
 cutoffs_started=.false.
 original_nproma=dimensions%nproma
 local_status=0
 if(.not.control%message_ready)then
  local_status=initialize_public_transform_messages(control,expected_world)
  if(local_status==3)call abort_distributed_partition()
 else
  if(control%nproc/=expected_world)local_status=2
 end if
 if(.not.control%message_ready)return
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 local_status=2
 if(len(text)<1.or.len(text)>262144)goto 100
 if(threads/=1)goto 100
 if(dimensions%nsmax/=1279.or.dimensions%ndglg/=2560.or.dimensions%nflevg/=137)goto 100
 if(dimensions%ndlon<1.or.dimensions%ndlon>32768)goto 100
 if(dimensions%ncmax/=dimensions%nsmax.or.dimensions%nmsmax/=dimensions%nsmax)goto 100
 if(dimensions%nproma<1.or.dimensions%nproma>65536)goto 100
 if(dimensions%loptproma<0.or.dimensions%loptproma>1)goto 100
 if(dimensions%ndgsag>1.or.dimensions%ndgeng<dimensions%ndglg)goto 100
 if(size(physical_longitudes)/=dimensions%ndglg)goto 100
 do j=1,dimensions%ndglg
  if(physical_longitudes(j)<1.or.physical_longitudes(j)>dimensions%ndlon)goto 100
 end do
 if(transfer(constants%ra,0_c_int64_t)/=transfer(6371229.0d0,0_c_int64_t))goto 100
 local_status=0
100 continue
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 control%ra=constants%ra
 status=initialize_distributed_transform_environment(control,text,threads)
 if(status/=0)goto 900
 call initialize_partition_scalar_defaults(partition)
 call initialize_owned_stream_scalar_defaults(stream)
 resolution%truncation=dimensions%nsmax
 resolution%row_count=dimensions%ndglg
 status=initialize_transform_resolution(control,resolution,text,physical_longitudes,.true.)
 if(status/=0)call abort_distributed_partition()
 if(present(cutoffs))then
  local_status=initialize_global_grid_cutoffs(cutoffs,dimensions,resolution%resolution,1_c_int,1_c_int)
  cutoffs_started=local_status==0
  status=agree_distributed_partition_status(control,local_status)
  if(status/=0)goto 900
 end if
 local_status=initialize_complete_distributed_partition(partition,dimensions,stream,control,resolution, &
  physical_longitudes,threads)
 status=agree_distributed_partition_status(control,local_status)
 if(status/=0)goto 900
 return
900 continue
 if(present(cutoffs))then
  if(cutoffs_started)call release_global_grid_cutoffs(cutoffs)
 end if
 release_status=release_owned_distributed_transform_partition(partition,stream,control,resolution)
 dimensions%nproma=original_nproma
 if(status==1)call set_allocation_errno()
end function
!> Release partition arrays,stream metadata,and then the public context.
!! The caller first releases cutoff and stream value owners,which this entry
!! does not own. All processes finish the borrowed public lifetime together.
integer(c_int) function release_owned_distributed_transform_partition(partition,stream,control,resolution) result(status)
 type(native_distributed_partition),intent(inout)::partition
 type(native_geometry_stream),intent(inout)::stream
 type(native_transform_control),intent(inout)::control
 type(native_transform_resolution),intent(inout)::resolution
 integer(c_int)::release_status,error
 release_status=release_distributed_partition_arrays(partition)
 call release_stream_geometry_metadata(stream)
 release_status=release_transform_environment_metadata(control)
 status=0
 if(control%message_ready)then
  release_status=finish_public_transform_context(control,resolution,error)
  if(release_status/=0.or.error/=0)call abort_distributed_partition()
 end if
end function
!> Establish the named scalar part of the original fresh calloc owner.
subroutine initialize_partition_scalar_defaults(partition)
 type(native_distributed_partition),intent(inout)::partition
 partition%phase=0_c_int
 partition%borrowed_resolution=0_c_int
 partition%npsp=0_c_int
 partition%nspec2v=0_c_int
 partition%nspec2vf=0_c_int
 partition%nspec2vddh=0_c_int
 partition%nspec2v_nh=0_c_int
 partition%nbsetsp=0_c_int
 partition%nfrstloff=0_c_int
 partition%myfrstactlat=0_c_int
 partition%mylstactlat=0_c_int
 partition%nptrfloff=0_c_int
 partition%nump=0_c_int
 partition%numcp=0_c_int
 partition%nspec=0_c_int
 partition%nspec2=0_c_int
 partition%nspec2mx=0_c_int
 partition%nflevl=0_c_int
 partition%nflevlmx=0_c_int
 partition%nflsur=0_c_int
 partition%ndgll=0_c_int
 partition%ndgsal=0_c_int
 partition%ndgenl=0_c_int
 partition%ndguxl=0_c_int
 partition%ndgunl=0_c_int
 partition%ngptot=0_c_int
 partition%ngptotg=0_c_int
 partition%ngptotmx=0_c_int
 partition%ngptot_cap=0_c_int
 partition%ngpblks=0_c_int
 partition%npromm=0_c_int
 partition%npromnh=0_c_int
 partition%my_region_ns=0_c_int
 partition%my_region_ew=0_c_int
end subroutine
!> Establish the named scalar part of the fresh source stream owner.
subroutine initialize_owned_stream_scalar_defaults(stream)
 type(native_geometry_stream),intent(inout)::stream
 stream%nundef=0_c_int
 stream%nulerr=0_c_int
 stream%nulout=0_c_int
 stream%myproc=0_c_int
 stream%nproc=0_c_int
 stream%nrealen=0_c_int
 stream%nintlen=0_c_int
 stream%nbsetsp=0_c_int
 stream%nflevg=0_c_int
 stream%nsmax=0_c_int
 stream%ndglg=0_c_int
 stream%nfprgpl=0_c_int
 stream%nfprgpg=0_c_int
 stream%nfprgplx=0_c_int
 stream%imaxgrid=0_c_int64_t
 stream%imaxspec2g=0_c_int64_t
 stream%rpi=0.0_c_double
 stream%sipr=0.0_c_double
 stream%lifs_internal=.false.
end subroutine
logical function fresh_owned_stream(stream) result(fresh)
 type(native_geometry_stream),intent(in)::stream
 fresh=.true.
 fresh=fresh.and..not.allocated(stream%nbsetlev)
 fresh=fresh.and..not.allocated(stream%nloeng)
 fresh=fresh.and..not.allocated(stream%vah)
 fresh=fresh.and..not.allocated(stream%vbh)
 fresh=fresh.and..not.allocated(stream%rlatig)
 fresh=fresh.and..not.allocated(stream%numprocfp)
 fresh=fresh.and..not.allocated(stream%nfpmax)
 fresh=fresh.and..not.allocated(stream%msatid)
 fresh=fresh.and..not.allocated(stream%mseries)
 fresh=fresh.and..not.allocated(stream%minst)
 fresh=fresh.and..not.allocated(stream%mchan)
 fresh=fresh.and..not.allocated(stream%rcwn)
end function
subroutine set_allocation_errno()
 integer(c_int),pointer::error_value
 call c_f_pointer(errno_address(),error_value)
 error_value=12
end subroutine
end module forecast_distributed_partition
