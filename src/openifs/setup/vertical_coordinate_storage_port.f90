!> Own the selected native vertical storage, source constructor and startup lifetime.
module forecast_vertical_coordinate_storage
  use iso_c_binding, only: c_int,c_int32_t,c_int64_t,c_int8_t,c_double,c_ptr,c_f_pointer,c_loc,c_sizeof
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use vertical_configuration_port, only: native_vertical_configuration, &
    initialize_vertical_configuration,initialize_operational_vertical_configuration
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use physics_configuration_text_port, only: find_physics_group,skip_physics_space,physics_space, &
    physics_key_character,physics_fold_equal,parse_physics_boolean
  use forecast_vertical_coordinate_arrays, only: fill_hybrid_coordinate_arrays
  use forecast_hybrid_coordinate_defaults, only: initialize_default_hybrid_coefficients
  implicit none
  private
  public :: native_vertical_state,initialize_vertical_coordinate_storage
  public :: initialize_hybrid_coordinate_storage,release_hybrid_coordinate_storage
  public :: release_vertical_coordinate_storage,create_vertical_startup_state,release_vertical_startup_state
  !> Named owners for the source nineteen main arrays and eight I/O arrays.
  !! The main A/B interfaces have bounds0:n, layer arrays1:n, full eta0:n+1,
  !! knot centres1:n-2, derivative matrices(n,n+2) and integral(n+1,n+2).
  !! I/O full A/B also own index0, which their producer leaves unchanged.
  !! dvalh/dvbh are the201-word source namespace, with active indices0:n.
  !! vvp00/vp00/toppres use Pa. etah0/etahn are later eta bounds and have
  !! no constructor-produced value until eta_bounds_ready becomes true.
  !! rderb is the separate later spline copy; the constructor does not allocate
  !! or release it. configuration contains only the own named data type.
  type :: native_vertical_state
    type(native_vertical_configuration) :: configuration
    integer(c_int32_t) :: levels=0,io_levels=0
    real(c_double) :: dvalh(0:200),dvbh(0:200),vvp00,vp00,toppres
    real(c_double) :: etah0,etahn
    logical :: constructor_ready=.false.,eta_bounds_ready=.false.
    real(c_double),allocatable :: valh(:)
    real(c_double),allocatable :: vah(:)
    real(c_double),allocatable :: vbh(:)
    real(c_double),allocatable :: vc(:)
    real(c_double),allocatable :: vdelb(:)
    real(c_double),allocatable :: vetah(:)
    real(c_double),allocatable :: vetaf(:)
    real(c_double),allocatable :: vfe_etah(:)
    real(c_double),allocatable :: vfe_etaf(:)
    real(c_double),allocatable :: vaf(:)
    real(c_double),allocatable :: vbf(:)
    real(c_double),allocatable :: vdela(:)
    real(c_double),allocatable :: vfe_rdetah(:)
    real(c_double),allocatable :: vfe_knot(:)
    real(c_double),allocatable :: rderbf00(:,:)
    real(c_double),allocatable :: rderbf01(:,:)
    real(c_double),allocatable :: rderbf10(:,:)
    real(c_double),allocatable :: rderbf11(:,:)
    real(c_double),allocatable :: rintbf11(:,:)
    real(c_double),allocatable :: io_vah(:)
    real(c_double),allocatable :: io_vbh(:)
    real(c_double),allocatable :: io_valh(:)
    real(c_double),allocatable :: io_vc(:)
    real(c_double),allocatable :: io_vdela(:)
    real(c_double),allocatable :: io_vdelb(:)
    real(c_double),allocatable :: io_vaf(:)
    real(c_double),allocatable :: io_vbf(:)
    real(c_double),allocatable :: rderb(:,:)
  end type
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Retain the first NAMVV0 and its source default false file-force control.
  !! SUVV1 reads the complete group before selecting file coefficients. Only the
  !! final false LLFORCE_READ route is supported; repeated assignments use the
  !! final value. The unchanged provider still requires an empty NAMVV1.
  integer(c_int32_t) function require_native_vertical_defaults_group(text) result(status)
    character(*),intent(in) :: text
    integer :: n,first,cursor
    logical :: force_read,parsed,valid
    status=require_empty_physics_group(text,'NAMVV0')
    if(status==0)return
    n=len(text)
    cursor=find_physics_group(text,'NAMVV0',.false.)
    if(cursor==0)return
    force_read=.false.
    do
      call skip_physics_space(text,cursor)
      if(cursor>n)return
      if(text(cursor:cursor)=='/')then
        if(.not.force_read)status=0
        return
      end if
      if(text(cursor:cursor)==',')then
        cursor=cursor+1
        cycle
      end if
      first=cursor
      do while(cursor<=n)
        if(.not.physics_key_character(text(cursor:cursor),.false.))exit
        cursor=cursor+1
      end do
      if(cursor==first)return
      if(.not.physics_fold_equal(text(first:cursor-1),'LLFORCE_READ'))return
      call skip_physics_space(text,cursor)
      if(cursor>n)return
      if(text(cursor:cursor)/='=')return
      cursor=cursor+1
      call skip_physics_space(text,cursor)
      first=cursor
      do while(cursor<=n)
        if(physics_space(text(cursor:cursor)))exit
        if(index(',/!',text(cursor:cursor))/=0)exit
        cursor=cursor+1
      end do
      if(cursor==first)return
      call parse_physics_boolean(text(first:cursor-1),parsed,valid)
      if(.not.valid)return
      force_read=parsed
    end do
  end function
  !> Establish every byte of the owned native C-compatible configuration.
  !! Its complete size comes from the type, including alignment padding.
  !! The pointer is private to this call; no compiler-specific field offset is used.
  subroutine zero_native_configuration(configuration)
    type(native_vertical_configuration),target,intent(inout) :: configuration
    integer(c_int8_t),pointer :: bytes(:)
    call c_f_pointer(c_loc(configuration),bytes,[int(c_sizeof(configuration))])
    bytes=0_c_int8_t
  end subroutine

  !> Test finite FP64 bits without raising a floating-point exception.
  logical function finite_word(x)
    real(c_double),intent(in) :: x
    finite_word=ibits(transfer(x,0_c_int64_t),52,11)/=2047
  end function

  !> Require the complete selected constructor input before any owner mutation.
  logical function coordinate_inputs_admitted(state,text,a,b)
    type(native_vertical_state),intent(in) :: state
    character(len=*),intent(in) :: text
    real(c_double),intent(in) :: a(0:),b(0:)
    integer :: n,j
    real(c_double) :: epsilon,temporary
    coordinate_inputs_admitted=.false.
    n=state%levels
    if(n/=19.and.n/=137)return
    if(state%io_levels/=n)return
    if(state%configuration%nvfe_type/=3.or.state%configuration%nvfe_order/=4)return
    if(state%configuration%nvfe_intbc/=3.or.state%configuration%nvfe_derbc/=3)return
    if(state%configuration%lvertfe/=1.or.state%configuration%lvfe_ecmwf/=0)return
    if(ubound(a,1)<n.or.ubound(b,1)<n)return
    if(require_native_vertical_defaults_group(text)/=0)return
    if(require_empty_physics_group(text,'NAMVV1')/=0)return
    if(allocated(state%valh))return
    if(allocated(state%vah))return
    if(allocated(state%vbh))return
    if(allocated(state%vc))return
    if(allocated(state%vdelb))return
    if(allocated(state%vetah))return
    if(allocated(state%vetaf))return
    if(allocated(state%vfe_etah))return
    if(allocated(state%vfe_etaf))return
    if(allocated(state%vaf))return
    if(allocated(state%vbf))return
    if(allocated(state%vdela))return
    if(allocated(state%vfe_rdetah))return
    if(allocated(state%vfe_knot))return
    if(allocated(state%rderbf00))return
    if(allocated(state%rderbf01))return
    if(allocated(state%rderbf10))return
    if(allocated(state%rderbf11))return
    if(allocated(state%rintbf11))return
    if(allocated(state%io_vah))return
    if(allocated(state%io_vbh))return
    if(allocated(state%io_valh))return
    if(allocated(state%io_vc))return
    if(allocated(state%io_vdela))return
    if(allocated(state%io_vdelb))return
    if(allocated(state%io_vaf))return
    if(allocated(state%io_vbf))return
    do j=0,n
      if(.not.finite_word(a(j)).or..not.finite_word(b(j)))return
    end do
    epsilon=transfer(int(z'3d19000000000000',c_int64_t),epsilon)
    if(abs(a(n))>epsilon)return
    if(abs(b(0))>epsilon)return
    temporary=b(n)-1.0_c_double
    if(abs(temporary)>epsilon)return
    coordinate_inputs_admitted=.true.
  end function

  !> Allocate the eight I/O owners and reuse the frozen nonallocating arithmetic.
  !! n is0..256, A/B have bounds0:n, pressure is positive finite Pa.
  !! The eight I/O owners must be fresh; all other state fields stay unchanged.
  !! Allocation and release follow original source order. No payload is filled
  !! before its numerical producer. Failure cleans all acquired I/O owners.
  integer(c_int32_t) function initialize_hybrid_coordinate_storage(state,n,a,b,pressure) result(status)
    type(native_vertical_state),intent(inout) :: state
    integer(c_int32_t),intent(in) :: n
    real(c_double),intent(in) :: a(0:),b(0:),pressure
    integer :: allocation_status,j
    status=2
    if(n<0.or.n>256)return
    if(ubound(a,1)<n.or.ubound(b,1)<n)return
    if(.not.finite_word(pressure))return
    if(pressure<=0.0_c_double)return
    if(allocated(state%io_vah))return
    if(allocated(state%io_vbh))return
    if(allocated(state%io_valh))return
    if(allocated(state%io_vc))return
    if(allocated(state%io_vdela))return
    if(allocated(state%io_vdelb))return
    if(allocated(state%io_vaf))return
    if(allocated(state%io_vbf))return
    do j=0,n
      if(.not.finite_word(a(j)).or..not.finite_word(b(j)))return
    end do
    allocate(state%io_vah(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%io_vbh(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%io_valh(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%io_vc(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%io_vdela(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%io_vdelb(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%io_vaf(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%io_vbf(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    status=fill_hybrid_coordinate_arrays(n,pressure,a(0:n),b(0:n), &
      state%io_valh,state%io_vah,state%io_vbh,state%io_vc, &
      state%io_vaf,state%io_vbf,state%io_vdela,state%io_vdelb)
    if(status==0)return
900 continue
    call release_hybrid_coordinate_storage(state)
    status=1
  end function

  !> Release only the eight I/O owners in original source allocation order.
  subroutine release_hybrid_coordinate_storage(state)
    type(native_vertical_state),intent(inout) :: state
    if(allocated(state%io_vah))deallocate(state%io_vah)
    if(allocated(state%io_vbh))deallocate(state%io_vbh)
    if(allocated(state%io_valh))deallocate(state%io_valh)
    if(allocated(state%io_vc))deallocate(state%io_vc)
    if(allocated(state%io_vdela))deallocate(state%io_vdela)
    if(allocated(state%io_vdelb))deallocate(state%io_vdelb)
    if(allocated(state%io_vaf))deallocate(state%io_vaf)
    if(allocated(state%io_vbf))deallocate(state%io_vbf)
  end subroutine

  !> Construct all27owners and the selected SUVV1 state in original source order.
  !! state already contains its named controls, level counts and namespace
  !! preimages. text admits first NAMVV0 final false LLFORCE_READ and empty NAMVV1; file A/B use bounds0:n.
  !! Only active dvalh/dvbh indices0:n change; all201-word tails remain exact.
  !! All nineteen main owners precede defaults, file override and conversions;
  !! the eight I/O owners follow those calculations. Main untouched payloads
  !! stay uninitialized until their later producer.
  !! Return2 preserves all state; return1 releases acquired27owners and retains
  !! source scalar/control stores already completed; return0 publishes ready.
  integer(c_int32_t) function initialize_vertical_coordinate_storage(state,text,file_a,file_b) result(status)
    type(native_vertical_state),intent(inout) :: state
    character(len=*),intent(in) :: text
    real(c_double),intent(in) :: file_a(0:),file_b(0:)
    real(c_double) :: private_a(0:137),private_b(0:137),epsilon
    real(c_double),volatile :: observed_difference
    logical,volatile :: observed_comparison
    type(ieee_status_type) :: saved_fp_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: n,j,allocation_status
    status=2
    if(.not.coordinate_inputs_admitted(state,text,file_a,file_b))return
    n=state%levels
    call ieee_get_status(saved_fp_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(state%valh(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vah(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vbh(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vc(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vdelb(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vetah(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vetaf(0:n+1),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vfe_etah(0:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vfe_etaf(0:n+1),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vaf(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vbf(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vdela(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%vfe_rdetah(1:n),stat=allocation_status)
    if(allocation_status/=0)goto 900
    state%configuration%nvfe_internals=n-2
    allocate(state%vfe_knot(1:n-2),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rderbf00(1:n,1:n+2),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rderbf01(1:n,1:n+2),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rderbf10(1:n,1:n+2),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rderbf11(1:n,1:n+2),stat=allocation_status)
    if(allocation_status/=0)goto 900
    allocate(state%rintbf11(1:n+1,1:n+2),stat=allocation_status)
    if(allocation_status/=0)goto 900
    do j=0,n
      private_a(j)=0.0_c_double
      private_b(j)=0.0_c_double
    end do
    call ieee_set_status(saved_fp_status)
    status=initialize_default_hybrid_coefficients(1_c_int,n,private_a(0:n),private_b(0:n),state%vvp00)
    if(status/=0)goto 900
    do j=0,n
      state%dvalh(j)=private_a(j)
      state%dvbh(j)=private_b(j)
    end do
    state%vp00=state%vvp00
    state%toppres=0.1_c_double
    do j=0,n
      state%dvalh(j)=file_a(j)
      state%dvbh(j)=file_b(j)
    end do
    epsilon=transfer(int(z'3d19000000000000',c_int64_t),epsilon)
    do j=0,n
      observed_difference=state%dvalh(j)-file_a(j)
      observed_comparison=abs(observed_difference)>epsilon
    end do
    do j=0,n
      observed_difference=state%dvbh(j)-file_b(j)
      observed_comparison=abs(observed_difference)>epsilon
    end do
    observed_comparison=abs(state%dvalh(n))>epsilon
    observed_comparison=abs(state%dvbh(0))>epsilon
    observed_difference=state%dvbh(n)-1.0_c_double
    observed_comparison=abs(observed_difference)>epsilon
    do j=0,n
      state%vah(j)=state%dvalh(j)
      state%valh(j)=state%dvalh(j)/state%vp00
      state%vbh(j)=state%dvbh(j)
    end do
    do j=0,n
      private_a(j)=state%dvalh(j)
      private_b(j)=state%dvbh(j)
    end do
    status=initialize_hybrid_coordinate_storage(state,n,private_a(0:n),private_b(0:n),state%vp00)
    if(status/=0)goto 900
    state%constructor_ready=.true.
    status=0
    error_pointer=saved_errno
    return
900 continue
    call release_vertical_coordinate_storage(state)
    error_pointer=saved_errno
    status=1
  end function

  !> Release only the constructor27owners; preserve the later rderb lifetime.
  !! Named controls, namespace values, pressure scalars and eta bound values
  !! retain their current bytes. Readiness becomes false after owner release.
  subroutine release_vertical_coordinate_storage(state)
    type(native_vertical_state),intent(inout) :: state
    if(allocated(state%valh))deallocate(state%valh)
    if(allocated(state%vah))deallocate(state%vah)
    if(allocated(state%vbh))deallocate(state%vbh)
    if(allocated(state%vc))deallocate(state%vc)
    if(allocated(state%vdelb))deallocate(state%vdelb)
    if(allocated(state%vetah))deallocate(state%vetah)
    if(allocated(state%vetaf))deallocate(state%vetaf)
    if(allocated(state%vfe_etah))deallocate(state%vfe_etah)
    if(allocated(state%vfe_etaf))deallocate(state%vfe_etaf)
    if(allocated(state%vaf))deallocate(state%vaf)
    if(allocated(state%vbf))deallocate(state%vbf)
    if(allocated(state%vdela))deallocate(state%vdela)
    if(allocated(state%vfe_rdetah))deallocate(state%vfe_rdetah)
    if(allocated(state%vfe_knot))deallocate(state%vfe_knot)
    if(allocated(state%rderbf00))deallocate(state%rderbf00)
    if(allocated(state%rderbf01))deallocate(state%rderbf01)
    if(allocated(state%rderbf10))deallocate(state%rderbf10)
    if(allocated(state%rderbf11))deallocate(state%rderbf11)
    if(allocated(state%rintbf11))deallocate(state%rintbf11)
    call release_hybrid_coordinate_storage(state)
    state%constructor_ready=.false.
    state%eta_bounds_ready=.false.
  end subroutine

  !> Own a fresh native startup object and publish it only after complete SUVV1.
  !! geometry=[levels,ECMWF,nonhydrostatic,two_dimensional]. Admit19or137layers,
  !! the global hydrostatic ECMWF route and the complete own selected controls.
  !! text supplies first NAMVV0 final false LLFORCE_READ and empty NAMVV1 and operational NAMCVER at137layers.
  !! Startup zeroes both201-word namespaces and all own scalar state; raw
  !! coordinate owners still receive no artificial payload initialization.
  !! output must be unallocated. Return1or2leaves it unallocated.
  integer(c_int32_t) function create_vertical_startup_state(output,text,geometry,file_a,file_b) result(status)
    type(native_vertical_state),allocatable,intent(inout) :: output
    character(len=*),intent(in) :: text
    integer(c_int32_t),intent(in) :: geometry(4)
    real(c_double),intent(in) :: file_a(0:),file_b(0:)
    type(native_vertical_state),allocatable :: pending
    type(native_vertical_configuration) :: admitted_configuration
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    integer :: n,j,allocation_status
    status=2
    if(allocated(output))return
    n=geometry(1)
    if(n/=19.and.n/=137)return
    if(any(geometry(2:4)/=[1_c_int32_t,0_c_int32_t,0_c_int32_t]))return
    if(ubound(file_a,1)<n.or.ubound(file_b,1)<n)return
    if(require_native_vertical_defaults_group(text)/=0)return
    if(require_empty_physics_group(text,'NAMVV1')/=0)return
    call zero_native_configuration(admitted_configuration)
    if(n==137)then
      status=initialize_operational_vertical_configuration(text,geometry,admitted_configuration)
    else
      status=initialize_vertical_configuration(admitted_configuration,geometry(2),geometry(3),geometry(4))
    end if
    if(status/=0)return
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    allocate(pending,stat=allocation_status)
    if(allocation_status/=0)then
      status=1
      error_pointer=saved_errno
      return
    end if
    call zero_native_configuration(pending%configuration)
    pending%configuration=admitted_configuration
    pending%levels=n
    pending%io_levels=n
    do j=0,200
      pending%dvalh(j)=0.0_c_double
      pending%dvbh(j)=0.0_c_double
    end do
    pending%vvp00=0.0_c_double
    pending%vp00=0.0_c_double
    pending%toppres=0.0_c_double
    pending%etah0=0.0_c_double
    pending%etahn=0.0_c_double
    pending%constructor_ready=.false.
    pending%eta_bounds_ready=.false.
    status=initialize_vertical_coordinate_storage(pending,text,file_a,file_b)
    if(status/=0)then
      call release_vertical_coordinate_storage(pending)
      deallocate(pending)
      error_pointer=saved_errno
      return
    end if
    call move_alloc(pending,output)
    error_pointer=saved_errno
  end function

  !> Release one complete startup context, including its separate later spline copy.
  !! The context must own a successful constructor. The final release preserves
  !! the caller's floating-point controls, exception flags and errno.
  !! The lower-level27-owner release remains available for root failure cleanup.
  integer(c_int32_t) function release_vertical_startup_state(state) result(status)
    type(native_vertical_state),allocatable,intent(inout) :: state
    type(ieee_status_type) :: saved_fp_status
    integer(c_int),pointer,volatile :: error_pointer
    integer(c_int) :: saved_errno
    status=2
    if(.not.allocated(state))return
    if(.not.state%constructor_ready)return
    call ieee_get_status(saved_fp_status)
    call c_f_pointer(errno_address(),error_pointer)
    saved_errno=error_pointer
    if(allocated(state%rderb))deallocate(state%rderb)
    call release_vertical_coordinate_storage(state)
    deallocate(state)
    call ieee_set_status(saved_fp_status)
    error_pointer=saved_errno
    status=0
  end function
end module forecast_vertical_coordinate_storage
