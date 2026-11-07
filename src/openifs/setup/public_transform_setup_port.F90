!> Own the named controls and region arrays around public transform setup.
!! Generated model code owns configuration, lifetime and public call order.
!! Public FIAT and ectrans libraries own their internal message/transform work.
module forecast_public_transform
  use iso_fortran_env, only: int32,real64
  use iso_c_binding, only: c_ptr,c_int,c_f_pointer
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use mpl_init_mod, only: mpl_init
  use mpl_end_mod, only: mpl_end
  use mpl_myrank_mod, only: mpl_myrank
  use mpl_groups, only: mpl_cart_coords
  use forecast_transform_configuration, only: &
    require_empty_transform_group,require_operational_transform_group
  implicit none
  private
  public :: native_transform_control,native_transform_resolution
  public :: initialize_public_transform_messages,initialize_serial_transform_context
  public :: initialize_serial_transform_environment,initialize_transform_resolution
  public :: release_transform_environment_metadata,finish_public_transform_context

  !> Integer flags retain canonical source values0 or1.
  !! ra is the planetary radius in metres. Regions are native owned arrays.
  type :: native_transform_control
    integer(int32) :: nproc=1,myproc=1,nprgpns=1,nprgpew=1,nprtrw=1
    integer(int32) :: nprtrv=1,nprtrns=1,mysetv=1,mysetw=1
    integer(int32) :: nprintlev=0,ncombflen=1800000
    integer(int32) :: lmpoff=0,lsync_trans=0,leq_regions=1
    integer(int32) :: ntrans_sync_level=0,nopt_memory=1
    integer(int32) :: npromatr=0,nepromatr=0,nmax_resol=37,lalloperm=1,lmono_trans=0
    real(real64) :: rdistr_e=1.0_real64,ra=6371229.0_real64
    integer(int32) :: regions_ns=0,regions_ew=0,myregion=0,myregion_pe=0
    integer(int32),allocatable :: n_regions(:),ngpset2pe(:,:)
    integer(int32) :: luseflt=0,luserpnm=0,lkeeprpnm=0,lfftw=0
    integer(int32) :: nulout=6,nulerr=0,lsplit=1
    logical :: message_ready=.false.,environment_ready=.false.
  end type

  !> resolution is the live public handle. Counts describe its active grid.
  type :: native_transform_resolution
    integer(int32) :: resolution=0,truncation=0,row_count=0
  end type

#include "setup_trans0.h"
#include "setup_trans.h"
#include "trans_release.h"
  interface
    function errno_location() bind(c,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Start public messages once and record the actual world and one-based rank.
  !! expected_world is1 through32. All participating processes call together.
  !! A mismatch returns2 with a live message context requiring collective end.
  integer(int32) function initialize_public_transform_messages(control,expected_world) result(status)
    type(native_transform_control),intent(inout) :: control
    integer(int32),intent(in) :: expected_world
    integer(int32) :: error,world
    status=2
    if(expected_world<1 .or. expected_world>32)return
    if(control%message_ready)return
    call mpl_init(koutput=0_int32,kerror=error,kprocs=world,ldinfo=.false.,ldenv=.false.)
    status=3
    if(error/=0)return
    control%message_ready=.true.
    control%nproc=world
    control%myproc=mpl_myrank()
    status=2
    if(world/=expected_world)return
    status=0
  end function

  !> Compose the source environment then selected or operational resolution.
  !! row_lengths is the contiguous active1:row_count view, in grid points.
  !! The caller retains any exterior halo words. No numerical stage is supplied
  !! by this interface or by a comparison driver.
  integer(int32) function initialize_serial_transform_context(control,grid,text,row_lengths,operational) result(status)
    type(native_transform_control),intent(inout) :: control
    type(native_transform_resolution),intent(inout) :: grid
    character(len=*),intent(in) :: text
    integer(int32),contiguous,intent(in) :: row_lengths(:)
    logical,intent(in) :: operational
    integer(int32) :: ignored
    status=2
    if(operational)then
      if(require_operational_transform_group(text)/=0)return
    else
      if(require_empty_transform_group(text,1_int32)/=0)return
    end if
    status=initialize_serial_transform_environment(control,text)
    if(status/=0)return
    status=initialize_transform_resolution(control,grid,text,row_lengths,operational)
    if(status/=0)ignored=release_transform_environment_metadata(control)
  end function

  !> Own both serial region arrays after actual public SETUP_TRANS0.
  !! Status0 is complete,1 is allocation refusal,2 is unsupported input and3
  !! is a returned partition shape outside the declared serial contract.
  integer(int32) function initialize_serial_transform_environment(control,text) result(status)
    type(native_transform_control),intent(inout) :: control
    character(len=*),intent(in) :: text
    integer(int32) :: regions(3),coordinate_w,coordinate_v
    integer :: allocation_status
    logical :: message_off,synchronize,equal_regions,permanent
    integer(c_int),pointer,volatile :: system_error
    status=2
    if(control%nproc/=1 .or. control%myproc/=1)return
    if(control%nprgpns/=1 .or. control%nprgpew/=1 .or. control%nprtrw/=1)return
    if(control%nprtrv/=1 .or. control%nprtrns/=1)return
    if(control%mysetv/=1 .or. control%mysetw/=1)return
    if(control%nprintlev/=0 .or. control%lmpoff/=0 .or. control%lsync_trans/=0)return
    if(control%leq_regions/=1 .or. control%lsplit/=1 .or. control%nopt_memory<1)return
    if(allocated(control%n_regions) .or. allocated(control%ngpset2pe))return
    if(control%environment_ready .or. .not.control%message_ready)return
    status=require_empty_transform_group(text,0_int32)
    if(status/=0)return
    control%npromatr=0
    control%nepromatr=0
    control%nmax_resol=37
    control%lalloperm=1
    control%lmono_trans=0
    control%rdistr_e=1.0_real64
    message_off=.false.
    synchronize=.false.
    equal_regions=.true.
    permanent=.true.
    call c_f_pointer(errno_location(),system_error)
    system_error=0
    call setup_trans0(kout=control%nulout,kerr=control%nulerr, &
      kprintlev=control%nprintlev,kmax_resol=control%nmax_resol,kpromatr=control%npromatr, &
      kprgpns=control%nprgpns,kprgpew=control%nprgpew,kprtrw=control%nprtrw, &
      kcombflen=control%ncombflen,ldmpoff=message_off,ldsync_trans=synchronize, &
      ldeq_regions=equal_regions,k_regions_ns=control%regions_ns, &
      k_regions_ew=control%regions_ew,k_regions=regions,prad=control%ra,ldalloperm=permanent)
    status=3
    if(control%regions_ns/=1 .or. control%regions_ew/=1)return
    allocate(control%n_regions(1),stat=allocation_status)
    status=1
    if(allocation_status/=0)return
    control%n_regions(1)=regions(1)
    allocate(control%ngpset2pe(1,1),stat=allocation_status)
    if(allocation_status/=0)then
      deallocate(control%n_regions)
      return
    end if
    control%ngpset2pe(1,1)=1
    control%myregion=1
    control%myregion_pe=control%myproc
    call mpl_cart_coords(control%myproc,coordinate_w,coordinate_v)
    status=3
    if(coordinate_w/=1 .or. coordinate_v/=1)then
      deallocate(control%n_regions,control%ngpset2pe)
      return
    end if
    control%environment_ready=.true.
    status=0
  end function

  !> Create the public resolution from the caller's exact active row counts.
  !! Selected input isT21 with32rows. Operational input isT1279 with2560rows.
  !! The public library supplies the transform method and all internal storage.
  integer(int32) function initialize_transform_resolution(control,grid,text,row_lengths,operational) result(status)
    type(native_transform_control),intent(inout) :: control
    type(native_transform_resolution),intent(inout) :: grid
    character(len=*),intent(in) :: text
    integer(int32),contiguous,intent(in) :: row_lengths(:)
    logical,intent(in) :: operational
    logical :: split,use_fast,use_recurrence,keep_recurrence,use_fftw
    integer(c_int),pointer,volatile :: system_error
    status=2
    if(control%lsplit/=1 .or. .not.control%environment_ready)return
    if(operational)then
      if(grid%truncation/=1279 .or. grid%row_count/=2560)return
      if(require_operational_transform_group(text)/=0)return
    else
      if(grid%truncation/=21 .or. grid%row_count/=32)return
      if(require_empty_transform_group(text,1_int32)/=0)return
    end if
    if(size(row_lengths)/=grid%row_count)return
    use_fast=grid%truncation>1280
    use_recurrence=.not.use_fast
    keep_recurrence=.not.use_fast
    use_fftw=.false.
    split=.true.
    control%luseflt=merge(1_int32,0_int32,use_fast)
    control%luserpnm=merge(1_int32,0_int32,use_recurrence)
    control%lkeeprpnm=merge(1_int32,0_int32,keep_recurrence)
    control%lfftw=0
    call c_f_pointer(errno_location(),system_error)
    system_error=0
    call setup_trans(ksmax=grid%truncation,kdgl=grid%row_count,kloen=row_lengths, &
      ldsplit=split,kresol=grid%resolution,lduserpnm=use_recurrence, &
      ldkeeprpnm=keep_recurrence,lduseflt=use_fast,ldusefftw=use_fftw)
    status=0
  end function

  !> Release the two owned metadata arrays and retain complete floating status.
  !! Other scalar and public library state remain owned by the caller.
  integer(int32) function release_transform_environment_metadata(control) result(status)
    type(native_transform_control),intent(inout) :: control
    type(ieee_status_type) :: floating_status
    integer(c_int),pointer,volatile :: system_error
    integer(c_int) :: saved_error
    call c_f_pointer(errno_location(),system_error)
    saved_error=system_error
    call ieee_get_status(floating_status)
    if(allocated(control%n_regions))deallocate(control%n_regions)
    if(allocated(control%ngpset2pe))deallocate(control%ngpset2pe)
    control%environment_ready=.false.
    call ieee_set_status(floating_status)
    system_error=saved_error
    status=0
  end function

  !> Release the public transform and end its message lifetime exactly once.
  !! All participating processes call together after their consumers stop.
  integer(int32) function finish_public_transform_context(control,grid,error) result(status)
    type(native_transform_control),intent(inout) :: control
    type(native_transform_resolution),intent(inout) :: grid
    integer(int32),intent(out) :: error
    status=2
    error=0
    if(.not.control%message_ready)return
    if(grid%resolution/=0)call trans_release(grid%resolution)
    call mpl_end(kerror=error,ldmeminfo=.false.)
    control%message_ready=.false.
    status=0
  end function
end module forecast_public_transform
