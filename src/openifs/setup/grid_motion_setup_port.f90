!> Construct source-named grid-motion maps and selected field storage.
!! Counts and indices are dimensionless. GMV fields retain their source units.
!! The caller establishes the required IEEE FP64 environment.
module forecast_grid_motion_setup
  use iso_fortran_env,only:int32,real64
  use iso_c_binding,only:c_ptr,c_int,c_f_pointer
  use forecast_grid_motion_types,only:native_grid_motion_state,type_t0
  use yomdimf,only:tdimf
  use yomdyna,only:tdyna
  implicit none
  private
  public::native_grid_motion_controls,initialize_grid_motion_index_maps
  public::initialize_grid_motion_fields,zero_grid_motion_fields,release_grid_motion_fields
  type::native_grid_motion_controls
    integer(int32)::nconf=1,lecmwf=1,lrshw=0,nundefld=-99999999,ldtenc=0,nprintlev=0
  end type
  interface
    function errno_address()bind(C,name='__errno_location')result(address)
      import c_ptr
      type(c_ptr)::address
    end function
  end interface
contains
  !> Produce all 141 named integer map values, without changing any array owner.
  !! DIMENSIONS and DYNAMICS are read-only canonical records. OUTPUT is updated.
  !! MISSING is a negative source marker for an absent one-based field index.
  integer(int32)function initialize_grid_motion_index_maps(output,dimensions,dynamics,missing)result(status)
    type(native_grid_motion_state),intent(inout)::output
    type(tdimf),intent(in)::dimensions
    type(tdyna),intent(in)::dynamics
    integer(int32),intent(in)::missing
    integer(int32)::m,base
    status=2
    if(missing>=0)return
    output%yt0%ndim=missing
    output%yt0%ndims=missing
    output%yt0%ndimuv=missing
    output%yt0%mu=missing
    output%yt0%mv=missing
    output%yt0%mt=missing
    output%yt0%mtl=missing
    output%yt0%mtm=missing
    output%yt0%mdiv=missing
    output%yt0%mvor=missing
    output%yt0%mul=missing
    output%yt0%mvl=missing
    output%yt0%mspd=missing
    output%yt0%mspdl=missing
    output%yt0%mspdm=missing
    output%yt0%msvd=missing
    output%yt0%msvdl=missing
    output%yt0%msvdm=missing
    output%yt0%mnhx=missing
    output%yt0%mnhxl=missing
    output%yt0%mnhxm=missing
    output%yt0%medot=missing
    output%yt0%msgrtl=missing
    output%yt0%msgrtm=missing
    output%yt0%msp=missing
    output%yt0%mspl=missing
    output%yt0%mspm=missing
    output%yt9%ndim=missing
    output%yt9%ndims=missing
    output%yt9%mu=missing
    output%yt9%mv=missing
    output%yt9%mt=missing
    output%yt9%mtl=missing
    output%yt9%mtm=missing
    output%yt9%medot=missing
    output%yt9%munl=missing
    output%yt9%munl_si=missing
    output%yt9%mvnl=missing
    output%yt9%mvnl_si=missing
    output%yt9%mtnl=missing
    output%yt9%mtnl_si=missing
    output%yt9%mspnl=missing
    output%yt9%mspnl_si=missing
    output%yt9%mvwvnl=missing
    output%yt9%msvdnl_si=missing
    output%yt9%mspdnl=missing
    output%yt9%mspdnl_si=missing
    output%yt9%mdiv=missing
    output%yt9%mvor=missing
    output%yt9%mul=missing
    output%yt9%mvl=missing
    output%yt9%mspd=missing
    output%yt9%mspdl=missing
    output%yt9%mspdm=missing
    output%yt9%msvd=missing
    output%yt9%msvdl=missing
    output%yt9%msvdm=missing
    output%yt9%mnhx=missing
    output%yt9%mgw=missing
    output%yt9%mcurhs=missing
    output%yt9%mcvrhs=missing
    output%yt9%mctrhs=missing
    output%yt9%mcsprhs=missing
    output%yt9%mcspdrhs=missing
    output%yt9%mcsvdrhs=missing
    output%yt9%mcunl=missing
    output%yt9%mcvnl=missing
    output%yt9%mctnl=missing
    output%yt9%mcspnl=missing
    output%yt9%mcvwvnl=missing
    output%yt9%mcspdnl=missing
    output%yt9%mcupt=missing
    output%yt9%mcvpt=missing
    output%yt9%mctpt=missing
    output%yt9%mcspdpt=missing
    output%yt9%mcsvdpt=missing
    output%yt9%mdphi=missing
    output%yt9%mnhxnl=missing
    output%yt9%mcnhxnl=missing
    output%yt9%msgrtl=missing
    output%yt9%msgrtm=missing
    output%yt9%msp=missing
    output%yt9%mspl=missing
    output%yt9%mspm=missing
    output%yt9%mcsppt=missing
    output%yt9%mdbbc=missing
    output%yt9%mgws=missing
    output%yt9%mspnl2=missing
    output%yt9%mcspnl2=missing
    output%yt9%mprehyds=missing
    output%yt1%ndim=missing
    output%yt1%ndims=missing
    output%yt1%mu=missing
    output%yt1%mv=missing
    output%yt1%mt=missing
    output%yt1%mspd=missing
    output%yt1%msvd=missing
    output%yt1%mvor=missing
    output%yt1%mdiv=missing
    output%yt1%mnhx=missing
    output%yt1%msp=missing
    output%yph9%mu=missing
    output%yph9%mv=missing
    output%yph9%mt=missing
    output%yph9%msp=missing
    output%ygp%ndim=missing
    output%ygp%mu=missing
    output%ygp%mv=missing
    output%ygp%mt=missing
    output%ygp%mspd=missing
    output%ygp%msvd=missing
    output%ygp%mnhx=missing
    output%yt5%ndim=missing
    output%yt5%ndims=missing
    output%yt5%ndimuv=missing
    output%yt5%mu=missing
    output%yt5%mv=missing
    output%yt5%mt=missing
    output%yt5%mtl=missing
    output%yt5%mtm=missing
    output%yt5%mdiv=missing
    output%yt5%mvor=missing
    output%yt5%mul=missing
    output%yt5%mvl=missing
    output%yt5%mspd=missing
    output%yt5%mspdl=missing
    output%yt5%mspdm=missing
    output%yt5%msvd=missing
    output%yt5%msvdl=missing
    output%yt5%msvdm=missing
    output%yt5%mnhx=missing
    output%yt5%mnhxl=missing
    output%yt5%mnhxm=missing
    output%yt5%medot=missing
    output%yt5%msgrtl=missing
    output%yt5%msgrtm=missing
    output%yt5%msp=missing
    output%yt5%mspl=missing
    output%yt5%mspm=missing
    output%ndimgmv=missing
    output%ndimgmvs=missing
    call initialize_current_map(output%yt0,dimensions%lader,dimensions%luvder,dynamics%lgradsp)
    call initialize_current_map(output%yt5,dimensions%lader,dimensions%luvder,dynamics%lgradsp)
    m=output%yt0%ndim
    base=m
    m=m+1
    output%yt9%mu=m
    m=m+1
    output%yt9%mv=m
    m=m+1
    output%yt9%medot=m
    m=m+1
    output%yt9%munl=m
    m=m+1
    output%yt9%mvnl=m
    m=m+1
    output%yt9%mtnl=m
    m=m+1
    output%yt9%mspnl=m
    if(dynamics%lgradsp)then
      m=m+1
      output%yt9%msgrtl=m
      m=m+1
      output%yt9%msgrtm=m
    end if
    output%yt9%ndim=m-base
    output%yt9%ndims=0
    output%ndimgmv=m
    output%ndimgmvs=output%yt0%ndims
    output%yt1%mu=1
    output%yt1%mv=2
    output%yt1%mt=3
    output%yt1%mvor=1
    output%yt1%mdiv=2
    output%yt1%msp=1
    output%yt1%ndim=3
    output%yt1%ndims=1
    output%yph9%mu=output%yt0%mu
    output%yph9%mv=output%yt0%mv
    output%yph9%mt=output%yt0%mt
    output%yph9%msp=output%yt0%msp
    output%ygp%mu=1
    output%ygp%mv=2
    output%ygp%mt=3
    output%ygp%ndim=3
    output%ygp%mspd=1
    output%ygp%msvd=1
    output%ygp%mnhx=1
    status=0
  end function

  subroutine initialize_current_map(output,lader,luvder,lgradsp)
    type(type_t0),intent(inout)::output
    logical,intent(in)::lader,luvder,lgradsp
    integer(int32)::m,s
    m=0
    s=0
    if(lader)then
      m=m+1
      output%mvor=m
      m=m+1
      output%mdiv=m
    end if
    m=m+1
    output%mu=m
    m=m+1
    output%mv=m
    if(luvder)then
      m=m+1
      output%mul=m
      m=m+1
      output%mvl=m
    end if
    output%ndimuv=m
    m=m+1
    output%mt=m
    if(lader)then
      m=m+1
      output%mtm=m
      m=m+1
      output%mtl=m
    end if
    s=s+1
    output%msp=s
    if(lader)then
      s=s+1
      output%mspm=s
      s=s+1
      output%mspl=s
    end if
    if(lgradsp)then
      m=m+1
      output%msgrtl=m
      m=m+1
      output%msgrtm=m
    end if
    output%ndim=m
    output%ndims=s
  end subroutine

  !> Allocate GMV(P,L,F,B), then GMVS(P,S,B), with one-based bounds.
  !! Newly allocated real payloads remain uninitialized as in SETUP_GMV.
  !! Refusal changes no output. Allocation failure retains the completed maps.
  integer(int32)function initialize_grid_motion_fields(output,points,levels,blocks,dimensions,dynamics,controls)result(status)
    type(native_grid_motion_state),intent(inout)::output
    integer(int32),intent(in)::points,levels,blocks
    type(tdimf),intent(in)::dimensions
    type(tdyna),intent(in)::dynamics
    type(native_grid_motion_controls),intent(in)::controls
    integer(c_int),pointer,volatile::error
    integer(c_int)::saved_error
    integer::allocation_status
    status=2
    if(points<1.or.points>64.or.levels<1.or.levels>64.or.blocks<1.or.blocks>128)return
    if(controls%nconf/=1.or.controls%lecmwf/=1.or.controls%lrshw/=0)return
    if(controls%nundefld>=0.or.controls%ldtenc/=0.or.controls%nprintlev/=0)return
    if(dimensions%nfther/=1)return
    if(.not.admitted_dynamics(dynamics))return
    if(.not.fresh_grid_motion(output))return
    call c_f_pointer(errno_address(),error)
    saved_error=error
    status=initialize_grid_motion_index_maps(output,dimensions,dynamics,controls%nundefld)
    allocate(output%gmv(points,levels,output%ndimgmv,blocks),stat=allocation_status)
    if(allocation_status/=0)then
      error=saved_error
      status=1
      return
    end if
    allocate(output%gmvs(points,output%ndimgmvs,blocks),stat=allocation_status)
    if(allocation_status/=0)then
      deallocate(output%gmv)
      error=saved_error
      status=1
      return
    end if
    error=saved_error
    status=0
  end function

  !> Store positive zero in the two persistent source arrays only.
  integer(int32)function zero_grid_motion_fields(output)result(status)
    type(native_grid_motion_state),intent(inout)::output
    if(allocated(output%gmv))output%gmv=0.0_real64
    if(allocated(output%gmvs))output%gmvs=0.0_real64
    status=0
  end function

  !> Release GMV before GMVS, retaining all maps and all other owners.
  !! An absent owner is accepted. The incoming errno value is preserved.
  integer(int32)function release_grid_motion_fields(output)result(status)
    type(native_grid_motion_state),intent(inout)::output
    integer(c_int),pointer,volatile::error
    integer(c_int)::saved_error
    call c_f_pointer(errno_address(),error)
    saved_error=error
    if(allocated(output%gmv))deallocate(output%gmv)
    if(allocated(output%gmvs))deallocate(output%gmvs)
    error=saved_error
    status=0
  end function

  logical function admitted_dynamics(dynamics)result(admitted)
    type(tdyna),intent(in)::dynamics
    admitted=dynamics%ltwotl.and.dynamics%lgradsp
    admitted=admitted.and..not.(dynamics%lnhee.or.dynamics%lnhqe.or.dynamics%lnhdyn.or. &
      dynamics%lnhx.or.dynamics%lnhxder.or.dynamics%lgwadv.or.dynamics%lrdbbc.or. &
      dynamics%lnhqe_sihyd.or.dynamics%lnesc.or.dynamics%lslinlc2.or.dynamics%lslinl.or. &
      dynamics%lrubc.or.dynamics%lpc_full)
  end function

  logical function fresh_grid_motion(output)result(fresh)
    type(native_grid_motion_state),intent(in)::output
    fresh=.false.
    if(allocated(output%gmv).or.allocated(output%gmvs).or.allocated(output%gmvt1).or. &
      allocated(output%gmvt1s).or.allocated(output%gmv5).or.allocated(output%gmv5s).or. &
      allocated(output%gmv_depart).or.allocated(output%gmvs_depart))return
    if(output%ndimgmv/=0.or.output%ndimgmvs/=0)return
    if(output%yt0%ndim/=0)return
    if(output%yt0%ndims/=0)return
    if(output%yt0%ndimuv/=0)return
    if(output%yt0%mu/=0.and.output%yt0%mu/=-huge(1_int32))return
    if(output%yt0%mv/=0.and.output%yt0%mv/=-huge(1_int32))return
    if(output%yt0%mt/=0.and.output%yt0%mt/=-huge(1_int32))return
    if(output%yt0%mtl/=0.and.output%yt0%mtl/=-huge(1_int32))return
    if(output%yt0%mtm/=0.and.output%yt0%mtm/=-huge(1_int32))return
    if(output%yt0%mdiv/=0.and.output%yt0%mdiv/=-huge(1_int32))return
    if(output%yt0%mvor/=0.and.output%yt0%mvor/=-huge(1_int32))return
    if(output%yt0%mul/=0.and.output%yt0%mul/=-huge(1_int32))return
    if(output%yt0%mvl/=0.and.output%yt0%mvl/=-huge(1_int32))return
    if(output%yt0%mspd/=0.and.output%yt0%mspd/=-huge(1_int32))return
    if(output%yt0%mspdl/=0.and.output%yt0%mspdl/=-huge(1_int32))return
    if(output%yt0%mspdm/=0.and.output%yt0%mspdm/=-huge(1_int32))return
    if(output%yt0%msvd/=0.and.output%yt0%msvd/=-huge(1_int32))return
    if(output%yt0%msvdl/=0.and.output%yt0%msvdl/=-huge(1_int32))return
    if(output%yt0%msvdm/=0.and.output%yt0%msvdm/=-huge(1_int32))return
    if(output%yt0%mnhx/=0.and.output%yt0%mnhx/=-huge(1_int32))return
    if(output%yt0%mnhxl/=0.and.output%yt0%mnhxl/=-huge(1_int32))return
    if(output%yt0%mnhxm/=0.and.output%yt0%mnhxm/=-huge(1_int32))return
    if(output%yt0%medot/=0.and.output%yt0%medot/=-huge(1_int32))return
    if(output%yt0%msgrtl/=0.and.output%yt0%msgrtl/=-huge(1_int32))return
    if(output%yt0%msgrtm/=0.and.output%yt0%msgrtm/=-huge(1_int32))return
    if(output%yt0%msp/=0.and.output%yt0%msp/=-huge(1_int32))return
    if(output%yt0%mspl/=0.and.output%yt0%mspl/=-huge(1_int32))return
    if(output%yt0%mspm/=0.and.output%yt0%mspm/=-huge(1_int32))return
    if(output%yt9%ndim/=0)return
    if(output%yt9%ndims/=0)return
    if(output%yt9%mu/=0.and.output%yt9%mu/=-huge(1_int32))return
    if(output%yt9%mv/=0.and.output%yt9%mv/=-huge(1_int32))return
    if(output%yt9%mt/=0.and.output%yt9%mt/=-huge(1_int32))return
    if(output%yt9%mtl/=0.and.output%yt9%mtl/=-huge(1_int32))return
    if(output%yt9%mtm/=0.and.output%yt9%mtm/=-huge(1_int32))return
    if(output%yt9%medot/=0.and.output%yt9%medot/=-huge(1_int32))return
    if(output%yt9%munl/=0.and.output%yt9%munl/=-huge(1_int32))return
    if(output%yt9%munl_si/=0.and.output%yt9%munl_si/=-huge(1_int32))return
    if(output%yt9%mvnl/=0.and.output%yt9%mvnl/=-huge(1_int32))return
    if(output%yt9%mvnl_si/=0.and.output%yt9%mvnl_si/=-huge(1_int32))return
    if(output%yt9%mtnl/=0.and.output%yt9%mtnl/=-huge(1_int32))return
    if(output%yt9%mtnl_si/=0.and.output%yt9%mtnl_si/=-huge(1_int32))return
    if(output%yt9%mspnl/=0.and.output%yt9%mspnl/=-huge(1_int32))return
    if(output%yt9%mspnl_si/=0.and.output%yt9%mspnl_si/=-huge(1_int32))return
    if(output%yt9%mvwvnl/=0.and.output%yt9%mvwvnl/=-huge(1_int32))return
    if(output%yt9%msvdnl_si/=0.and.output%yt9%msvdnl_si/=-huge(1_int32))return
    if(output%yt9%mspdnl/=0.and.output%yt9%mspdnl/=-huge(1_int32))return
    if(output%yt9%mspdnl_si/=0.and.output%yt9%mspdnl_si/=-huge(1_int32))return
    if(output%yt9%mdiv/=0.and.output%yt9%mdiv/=-huge(1_int32))return
    if(output%yt9%mvor/=0.and.output%yt9%mvor/=-huge(1_int32))return
    if(output%yt9%mul/=0.and.output%yt9%mul/=-huge(1_int32))return
    if(output%yt9%mvl/=0.and.output%yt9%mvl/=-huge(1_int32))return
    if(output%yt9%mspd/=0.and.output%yt9%mspd/=-huge(1_int32))return
    if(output%yt9%mspdl/=0.and.output%yt9%mspdl/=-huge(1_int32))return
    if(output%yt9%mspdm/=0.and.output%yt9%mspdm/=-huge(1_int32))return
    if(output%yt9%msvd/=0.and.output%yt9%msvd/=-huge(1_int32))return
    if(output%yt9%msvdl/=0.and.output%yt9%msvdl/=-huge(1_int32))return
    if(output%yt9%msvdm/=0.and.output%yt9%msvdm/=-huge(1_int32))return
    if(output%yt9%mnhx/=0.and.output%yt9%mnhx/=-huge(1_int32))return
    if(output%yt9%mgw/=0.and.output%yt9%mgw/=-huge(1_int32))return
    if(output%yt9%mcurhs/=0.and.output%yt9%mcurhs/=-huge(1_int32))return
    if(output%yt9%mcvrhs/=0.and.output%yt9%mcvrhs/=-huge(1_int32))return
    if(output%yt9%mctrhs/=0.and.output%yt9%mctrhs/=-huge(1_int32))return
    if(output%yt9%mcsprhs/=0.and.output%yt9%mcsprhs/=-huge(1_int32))return
    if(output%yt9%mcspdrhs/=0.and.output%yt9%mcspdrhs/=-huge(1_int32))return
    if(output%yt9%mcsvdrhs/=0.and.output%yt9%mcsvdrhs/=-huge(1_int32))return
    if(output%yt9%mcunl/=0.and.output%yt9%mcunl/=-huge(1_int32))return
    if(output%yt9%mcvnl/=0.and.output%yt9%mcvnl/=-huge(1_int32))return
    if(output%yt9%mctnl/=0.and.output%yt9%mctnl/=-huge(1_int32))return
    if(output%yt9%mcspnl/=0.and.output%yt9%mcspnl/=-huge(1_int32))return
    if(output%yt9%mcvwvnl/=0.and.output%yt9%mcvwvnl/=-huge(1_int32))return
    if(output%yt9%mcspdnl/=0.and.output%yt9%mcspdnl/=-huge(1_int32))return
    if(output%yt9%mcupt/=0.and.output%yt9%mcupt/=-huge(1_int32))return
    if(output%yt9%mcvpt/=0.and.output%yt9%mcvpt/=-huge(1_int32))return
    if(output%yt9%mctpt/=0.and.output%yt9%mctpt/=-huge(1_int32))return
    if(output%yt9%mcspdpt/=0.and.output%yt9%mcspdpt/=-huge(1_int32))return
    if(output%yt9%mcsvdpt/=0.and.output%yt9%mcsvdpt/=-huge(1_int32))return
    if(output%yt9%mdphi/=0.and.output%yt9%mdphi/=-huge(1_int32))return
    if(output%yt9%mnhxnl/=0.and.output%yt9%mnhxnl/=-huge(1_int32))return
    if(output%yt9%mcnhxnl/=0.and.output%yt9%mcnhxnl/=-huge(1_int32))return
    if(output%yt9%msgrtl/=0.and.output%yt9%msgrtl/=-huge(1_int32))return
    if(output%yt9%msgrtm/=0.and.output%yt9%msgrtm/=-huge(1_int32))return
    if(output%yt9%msp/=0.and.output%yt9%msp/=-huge(1_int32))return
    if(output%yt9%mspl/=0.and.output%yt9%mspl/=-huge(1_int32))return
    if(output%yt9%mspm/=0.and.output%yt9%mspm/=-huge(1_int32))return
    if(output%yt9%mcsppt/=0.and.output%yt9%mcsppt/=-huge(1_int32))return
    if(output%yt9%mdbbc/=0.and.output%yt9%mdbbc/=-huge(1_int32))return
    if(output%yt9%mgws/=0.and.output%yt9%mgws/=-huge(1_int32))return
    if(output%yt9%mspnl2/=0.and.output%yt9%mspnl2/=-huge(1_int32))return
    if(output%yt9%mcspnl2/=0.and.output%yt9%mcspnl2/=-huge(1_int32))return
    if(output%yt9%mprehyds/=0.and.output%yt9%mprehyds/=-huge(1_int32))return
    if(output%yt1%ndim/=0)return
    if(output%yt1%ndims/=0)return
    if(output%yt1%mu/=0.and.output%yt1%mu/=-huge(1_int32))return
    if(output%yt1%mv/=0.and.output%yt1%mv/=-huge(1_int32))return
    if(output%yt1%mt/=0.and.output%yt1%mt/=-huge(1_int32))return
    if(output%yt1%mspd/=0.and.output%yt1%mspd/=-huge(1_int32))return
    if(output%yt1%msvd/=0.and.output%yt1%msvd/=-huge(1_int32))return
    if(output%yt1%mvor/=0.and.output%yt1%mvor/=-huge(1_int32))return
    if(output%yt1%mdiv/=0.and.output%yt1%mdiv/=-huge(1_int32))return
    if(output%yt1%mnhx/=0.and.output%yt1%mnhx/=-huge(1_int32))return
    if(output%yt1%msp/=0.and.output%yt1%msp/=-huge(1_int32))return
    if(output%yph9%mu/=0.and.output%yph9%mu/=-huge(1_int32))return
    if(output%yph9%mv/=0.and.output%yph9%mv/=-huge(1_int32))return
    if(output%yph9%mt/=0.and.output%yph9%mt/=-huge(1_int32))return
    if(output%yph9%msp/=0.and.output%yph9%msp/=-huge(1_int32))return
    if(output%ygp%ndim/=0)return
    if(output%ygp%mu/=0.and.output%ygp%mu/=-huge(1_int32))return
    if(output%ygp%mv/=0.and.output%ygp%mv/=-huge(1_int32))return
    if(output%ygp%mt/=0.and.output%ygp%mt/=-huge(1_int32))return
    if(output%ygp%mspd/=0.and.output%ygp%mspd/=-huge(1_int32))return
    if(output%ygp%msvd/=0.and.output%ygp%msvd/=-huge(1_int32))return
    if(output%ygp%mnhx/=0.and.output%ygp%mnhx/=-huge(1_int32))return
    if(output%yt5%ndim/=0)return
    if(output%yt5%ndims/=0)return
    if(output%yt5%ndimuv/=0)return
    if(output%yt5%mu/=0.and.output%yt5%mu/=-huge(1_int32))return
    if(output%yt5%mv/=0.and.output%yt5%mv/=-huge(1_int32))return
    if(output%yt5%mt/=0.and.output%yt5%mt/=-huge(1_int32))return
    if(output%yt5%mtl/=0.and.output%yt5%mtl/=-huge(1_int32))return
    if(output%yt5%mtm/=0.and.output%yt5%mtm/=-huge(1_int32))return
    if(output%yt5%mdiv/=0.and.output%yt5%mdiv/=-huge(1_int32))return
    if(output%yt5%mvor/=0.and.output%yt5%mvor/=-huge(1_int32))return
    if(output%yt5%mul/=0.and.output%yt5%mul/=-huge(1_int32))return
    if(output%yt5%mvl/=0.and.output%yt5%mvl/=-huge(1_int32))return
    if(output%yt5%mspd/=0.and.output%yt5%mspd/=-huge(1_int32))return
    if(output%yt5%mspdl/=0.and.output%yt5%mspdl/=-huge(1_int32))return
    if(output%yt5%mspdm/=0.and.output%yt5%mspdm/=-huge(1_int32))return
    if(output%yt5%msvd/=0.and.output%yt5%msvd/=-huge(1_int32))return
    if(output%yt5%msvdl/=0.and.output%yt5%msvdl/=-huge(1_int32))return
    if(output%yt5%msvdm/=0.and.output%yt5%msvdm/=-huge(1_int32))return
    if(output%yt5%mnhx/=0.and.output%yt5%mnhx/=-huge(1_int32))return
    if(output%yt5%mnhxl/=0.and.output%yt5%mnhxl/=-huge(1_int32))return
    if(output%yt5%mnhxm/=0.and.output%yt5%mnhxm/=-huge(1_int32))return
    if(output%yt5%medot/=0.and.output%yt5%medot/=-huge(1_int32))return
    if(output%yt5%msgrtl/=0.and.output%yt5%msgrtl/=-huge(1_int32))return
    if(output%yt5%msgrtm/=0.and.output%yt5%msgrtm/=-huge(1_int32))return
    if(output%yt5%msp/=0.and.output%yt5%msp/=-huge(1_int32))return
    if(output%yt5%mspl/=0.and.output%yt5%mspl/=-huge(1_int32))return
    if(output%yt5%mspm/=0.and.output%yt5%mspm/=-huge(1_int32))return
    fresh=.true.
  end function
end module forecast_grid_motion_setup
