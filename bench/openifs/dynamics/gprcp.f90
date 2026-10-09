!> Check the complete GPRCP mixture update and its optional arguments.
!! Fractions have units kg/kg. Gas constants and heat capacities use J/(kg K).
!! Arrays have shape (KPROMA, KFLEV) and use 64-bit floating-point values.
!! The reference is the unchanged strict-source Fortran routine.
program verify_gprcp
  use iso_c_binding, only : c_int64_t
  use parkind1, only : jpim, jprb
  use yom_ygfl, only : ygfl
  use, intrinsic :: ieee_arithmetic, only : ieee_is_finite
  use yomcst, only : setup_constants, rd, rv, rcpd, rcpv, rcw, rcs
  use yomdyncore, only : rplradi, rcorioi, lape, rplrg
  use yomlun, only : nulnam, nulout
  use yomhook, only : lhook
  implicit none
  abstract interface
    subroutine kernel(np,ks,kp,nl,q,qi,ql,qr,qs,qg,cp,r,kap,gfl,kind,thermal)
      use parkind1, only : jpim, jprb
      use yom_ygfl, only : ygfl
      integer(jpim), intent(in) :: np,ks,kp,nl
      real(jprb), optional, intent(in) :: q(np,nl),qi(np,nl),ql(np,nl),qr(np,nl),qs(np,nl),qg(np,nl)
      real(jprb), optional, intent(out) :: cp(np,nl),r(np,nl),kap(np,nl)
      real(jprb), optional, intent(in) :: gfl(np,nl,ygfl%ndim)
      integer(jpim), optional, intent(in) :: kind
      logical, optional, intent(in) :: thermal
    end subroutine
  end interface
  interface
    function openifs_fpcr() bind(c) result(value)
      import c_int64_t
      integer(c_int64_t) :: value
    end function
  end interface
  procedure(kernel) :: gprcp, gprcp_assembly
  type buffer
    real(jprb), pointer :: raw(:), field(:,:)
    integer(c_int64_t), allocatable :: before(:)
  end type
  type(buffer) :: inputs(6), assembly(3), reference(3)
  real(jprb), pointer :: generic_raw(:),generic(:,:,:),optional_generic(:,:,:)
  real(jprb), pointer :: q(:,:),qi(:,:),ql(:,:),qr(:,:),qs(:,:),qg(:,:)
  real(jprb), pointer :: acp(:,:),ar(:,:),akap(:,:),rcp(:,:),rr(:,:),rkap(:,:)
  integer(c_int64_t), allocatable :: generic_before(:)
  integer(jpim), target :: map_value
  integer(jpim), pointer :: optional_map
  logical, target :: override_value
  logical, pointer :: optional_override
  integer, parameter :: masks(8)=[0,1,2,4,8,16,32,63],maps(6)=[-1,0,1,5,9,101]
  integer :: shape,route,config,map_case,outmask,np,ks,kp,nl,n,f,i,j,calls=0,pmask,tmask,mode
  integer :: fa,fr,ios
  integer(c_int64_t) :: fpcr,bytes=0,abits,rbits
  real(jprb) :: mass(6),gas(6),heat(6),total,expected(3),tol,value
  character(512) :: argument
  lhook=.false.
  rplradi=1.0_jprb
  rcorioi=1.0_jprb
  rplrg=1.0_jprb
  lape=.false.
  nulout=6
  open(unit=nulnam,status='scratch',form='formatted')
  write(nulnam,'(a)') '&NAMSCEN /'
  rewind(nulnam)
  call setup_constants(nulout,0)
  close(nulnam)
  allocate(ygfl)
  ygfl%ndim=6
  ygfl%numflds=6
  ygfl%yq=>ygfl%ycomp(1)
  ygfl%yi=>ygfl%ycomp(2)
  ygfl%yl=>ygfl%ycomp(3)
  ygfl%yr=>ygfl%ycomp(4)
  ygfl%ys=>ygfl%ycomp(5)
  ygfl%yg=>ygfl%ycomp(6)
  gas=[rv,0.0_jprb,0.0_jprb,0.0_jprb,0.0_jprb,0.0_jprb]
  heat=[rcpv,rcs,rcw,rcw,rcs,rcs]
  do f=1,6
    ygfl%ycomp(f)%r=gas(f)
    ygfl%ycomp(f)%rcp=heat(f)
    ygfl%ycomp(f)%mp=f
    ygfl%ycomp(f)%mp1=7-f
    ygfl%ycomp(f)%mp5=mod(f,6)+1
    ygfl%ycomp(f)%mp9_ph=mod(f+2,6)+1
    ygfl%ycomp(f)%mp_sl1=mod(f+4,6)+1
  end do
  call get_command_argument(1,argument)
  open(newunit=fa,file=trim(argument),access='stream',form='unformatted',status='replace',iostat=ios)
  if(ios/=0) error stop 'assembly output open'
  call get_command_argument(2,argument)
  open(newunit=fr,file=trim(argument),access='stream',form='unformatted',status='replace',iostat=ios)
  if(ios/=0) error stop 'reference output open'
  fpcr=openifs_fpcr()
  if(iand(fpcr,int(z'03C80000',c_int64_t))/=0) error stop 'FPCR rounding or underflow'
  call get_command_argument(3,argument)
  if(trim(argument)=='--capture-capacity') then
    call capture_capacity(fa,fr,fpcr,gas,heat)
    close(fa)
    close(fr)
    stop
  else if(len_trim(argument)/=0) then
    error stop 'unknown optional verifier case'
  end if
  do shape=1,7
    select case(shape)
    case(1)
      np=1
      ks=1
      kp=1
      nl=1
    case(2)
      np=7
      ks=1
      kp=7
      nl=3
    case(3)
      np=9
      ks=3
      kp=8
      nl=2
    case(4)
      np=5
      ks=3
      kp=2
      nl=2
    case(5)
      np=3
      ks=1
      kp=3
      nl=0
    case(6,7)
      np=1
      ks=1
      kp=1
      nl=1
    end select
    n=np*nl
    do f=1,6
      allocate(inputs(f)%raw(n+2),inputs(f)%before(n+2))
      inputs(f)%field(1:np,1:nl)=>inputs(f)%raw(2:n+1)
      inputs(f)%raw=-huge(1.0_jprb)
      do j=1,nl
        do i=1,np
          value=real(mod(i*17+j*11+f*7,29)+1,jprb)/4096.0_jprb
          if(shape==7) value=transfer(1_c_int64_t,value)
          inputs(f)%field(i,j)=value
        end do
      end do
    end do
    do f=1,3
      allocate(assembly(f)%raw(n+2),reference(f)%raw(n+2))
      assembly(f)%field(1:np,1:nl)=>assembly(f)%raw(2:n+1)
      reference(f)%field(1:np,1:nl)=>reference(f)%raw(2:n+1)
    end do
    allocate(generic_raw(6*n+2),generic_before(6*n+2))
    generic(1:np,1:nl,1:6)=>generic_raw(2:6*n+1)
    do route=0,1
      do config=1,merge(17,9,route==0)
        nullify(optional_override)
        if(route==0) then
          pmask=63
          tmask=63
          if(config<=8) then
            pmask=masks(config)
            override_value=.true.
            optional_override=>override_value
          else if(config<=16) then
            tmask=masks(mod(config-9,8)+1)
          else
            tmask=0
            override_value=.false.
            optional_override=>override_value
          end if
        else
          pmask=0
          tmask=masks(mod(config-1,8)+1)
          if(config==9) tmask=0
        end if
        ygfl%numflds=6
        if(route==1.and.config==9) ygfl%numflds=0
        do f=1,6
          ygfl%ycomp(f)%lthermact=btest(tmask,f-1)
          if(shape==6) inputs(f)%field=merge(1.0_jprb,0.0_jprb,popcnt(pmask)==1.and.btest(pmask,f-1))
          inputs(f)%before=transfer(inputs(f)%raw,inputs(f)%before)
        end do
        do map_case=1,merge(1,6,route==0)
          map_value=maps(map_case)
          nullify(optional_map)
          if(map_value/=-1) optional_map=>map_value
          generic_raw=-huge(1.0_jprb)
          do f=1,6
            select case(map_value)
            case(-1,0)
              mode=f
            case(1)
              mode=7-f
            case(5)
              mode=mod(f,6)+1
            case(9)
              mode=mod(f+2,6)+1
            case(101)
              mode=mod(f+4,6)+1
            end select
            generic(:,:,mode)=inputs(f)%field
          end do
          generic_before=transfer(generic_raw,generic_before)
          nullify(optional_generic,q,qi,ql,qr,qs,qg)
          if(route==1) optional_generic=>generic
          if(btest(pmask,0)) q=>inputs(1)%field
          if(btest(pmask,1)) qi=>inputs(2)%field
          if(btest(pmask,2)) ql=>inputs(3)%field
          if(btest(pmask,3)) qr=>inputs(4)%field
          if(btest(pmask,4)) qs=>inputs(5)%field
          if(btest(pmask,5)) qg=>inputs(6)%field
          do outmask=0,7
            do f=1,3
              assembly(f)%raw=-777.75_jprb
              reference(f)%raw=-777.75_jprb
            end do
            nullify(acp,ar,akap,rcp,rr,rkap)
            if(btest(outmask,0)) then
              acp=>assembly(1)%field
              rcp=>reference(1)%field
            end if
            if(btest(outmask,1)) then
              ar=>assembly(2)%field
              rr=>reference(2)%field
            end if
            if(btest(outmask,2)) then
              akap=>assembly(3)%field
              rkap=>reference(3)%field
            end if
            if(associated(optional_override)) nullify(ygfl%yq,ygfl%yi,ygfl%yl,ygfl%yr,ygfl%ys,ygfl%yg)
            call gprcp(np,ks,kp,nl,q,qi,ql,qr,qs,qg,rcp,rr,rkap,optional_generic,optional_map,optional_override)
            call gprcp_assembly(np,ks,kp,nl,q,qi,ql,qr,qs,qg,acp,ar,akap,optional_generic,optional_map,optional_override)
            ygfl%yq=>ygfl%ycomp(1)
            ygfl%yi=>ygfl%ycomp(2)
            ygfl%yl=>ygfl%ycomp(3)
            ygfl%yr=>ygfl%ycomp(4)
            ygfl%ys=>ygfl%ycomp(5)
            ygfl%yg=>ygfl%ycomp(6)
            calls=calls+1
            do f=1,3
              do i=1,n+2
                abits=transfer(assembly(f)%raw(i),abits)
                rbits=transfer(reference(f)%raw(i),rbits)
                if(abits/=rbits) then
                  write(*,'(a,7(i0,1x),2(z16.16,1x))') 'Mismatch GPRCP case route config map output field cell ', &
                    calls,route,config,map_value,outmask,f,i,abits,rbits
                  error stop 'different output bytes'
                end if
                if(i==1.or.i==n+2.or..not.btest(outmask,f-1)) then
                  if(abits/=transfer(-777.75_jprb,abits)) error stop 'output guard or absent output'
                else if(mod(i-2,np)+1<ks.or.mod(i-2,np)+1>kp) then
                  if(abits/=transfer(-777.75_jprb,abits)) error stop 'inactive column'
                end if
              end do
              write(fa) assembly(f)%raw
              write(fr) reference(f)%raw
              bytes=bytes+int((n+2)*8,c_int64_t)
            end do
            do f=1,6
              if(any(transfer(inputs(f)%raw,inputs(f)%before)/=inputs(f)%before)) error stop 'changed water input'
            end do
            if(any(transfer(generic_raw,generic_before)/=generic_before)) error stop 'changed generic input'
            do j=1,nl
              do i=ks,kp
                mass=0.0_jprb
                do f=1,6
                  if(btest(tmask,f-1).and.(route==1.or.btest(pmask,f-1))) mass(f)=inputs(f)%field(i,j)
                end do
                total=sum(mass)
                if(total>1.0_jprb.or.total<0.0_jprb) error stop 'invalid fixture mass'
                expected(1)=(1.0_jprb-total)*rcpd+sum(mass*heat)
                expected(2)=(1.0_jprb-total)*rd+sum(mass*gas)
                expected(3)=expected(2)/expected(1)
                do f=1,3
                  if(.not.btest(outmask,f-1)) cycle
                  if(.not.ieee_is_finite(assembly(f)%field(i,j))) error stop 'nonfinite property'
                  if(transfer(total,abits)==0_c_int64_t) then
                    if(transfer(assembly(f)%field(i,j),abits)/=transfer(expected(f),rbits)) error stop 'dry-air bits'
                  end if
                  tol=64*epsilon(1.0_jprb)*max(1.0_jprb,abs(expected(f)))
                  if(abs(assembly(f)%field(i,j)-expected(f))>tol) error stop 'independent mixture balance'
                end do
              end do
            end do
          end do
        end do
      end do
    end do
    do f=1,6
      deallocate(inputs(f)%raw,inputs(f)%before)
    end do
    do f=1,3
      deallocate(assembly(f)%raw,reference(f)%raw)
    end do
    deallocate(generic_raw,generic_before)
  end do
  if(openifs_fpcr()/=fpcr) error stop 'changed FPCR'
  close(fa)
  close(fr)
  write(*,'(a,i0,a,i0,a,z16.16)') 'GPRCP PASS calls=',calls,' bytes=',bytes,' differing_bytes=0 FPCR=',fpcr
end program

  !> Verify the six-field CPGLAG input allocation with the total metadata at eight.
  !! The output units are J/(kg K) for heat capacity and gas constant. Kappa
  !! is dimensionless. Gas and heat each contain the six component constants.
  !! The two units receive full output buffers, including guards and inactive
  !! cells. Control is the unchanged 64-bit Arm floating-point control register.
  !! The last input byte precedes a protected page, so an eight-field capture
  !! cannot read it safely. Input fractions use kg/kg; outputs use J/(kg K).
  subroutine capture_capacity(assembly_unit,reference_unit,control,gas,heat)
  use iso_c_binding, only : c_int64_t, c_int, c_long, c_size_t, c_intptr_t, c_ptr, &
    c_null_ptr, c_f_pointer, c_associated
  use parkind1, only : jpim, jprb
  use yom_ygfl, only : ygfl
  use, intrinsic :: ieee_arithmetic, only : ieee_is_finite
  use yomcst, only : rd, rcpd
  implicit none
  abstract interface
    subroutine kernel(np,ks,kp,nl,q,qi,ql,qr,qs,qg,cp,r,kap,gfl,kind,thermal)
      use parkind1, only : jpim, jprb
      use yom_ygfl, only : ygfl
      integer(jpim), intent(in) :: np,ks,kp,nl
      real(jprb), optional, intent(in) :: q(np,nl),qi(np,nl),ql(np,nl),qr(np,nl),qs(np,nl),qg(np,nl)
      real(jprb), optional, intent(out) :: cp(np,nl),r(np,nl),kap(np,nl)
      real(jprb), optional, intent(in) :: gfl(np,nl,ygfl%ndim)
      integer(jpim), optional, intent(in) :: kind
      logical, optional, intent(in) :: thermal
    end subroutine
  end interface
  interface
    function openifs_fpcr() bind(c) result(value)
      import c_int64_t
      integer(c_int64_t) :: value
    end function
    function libc_mmap(address,length,protection,flags,fd,offset) bind(c,name="mmap") result(mapping)
      import c_ptr,c_size_t,c_int,c_long
      type(c_ptr), value :: address
      integer(c_size_t), value :: length
      integer(c_int), value :: protection,flags,fd
      integer(c_long), value :: offset
      type(c_ptr) :: mapping
    end function
    function libc_mprotect(address,length,protection) bind(c,name="mprotect") result(status)
      import c_ptr,c_size_t,c_int
      type(c_ptr), value :: address
      integer(c_size_t), value :: length
      integer(c_int), value :: protection
      integer(c_int) :: status
    end function
    function libc_munmap(address,length) bind(c,name="munmap") result(status)
      import c_ptr,c_size_t,c_int
      type(c_ptr), value :: address
      integer(c_size_t), value :: length
      integer(c_int) :: status
    end function
    function libc_getpagesize() bind(c,name="getpagesize") result(length)
      import c_int
      integer(c_int) :: length
    end function
  end interface
  procedure(kernel) :: gprcp, gprcp_assembly
  type buffer
    real(jprb), pointer :: raw(:), field(:,:)
    integer(c_int64_t), allocatable :: before(:)
  end type
    integer, intent(in) :: assembly_unit,reference_unit
    real(jprb), intent(in) :: gas(6),heat(6)
    integer(c_int64_t), intent(in) :: control
    integer(jpim), parameter :: points=3,levels=2,first=2,last=3,fields=6,kind=1
    integer, parameter :: cells=points*levels
    type(c_ptr) :: mapping,page_address,field_address
    integer(c_intptr_t) :: base,page_start,field_start
    integer(c_size_t) :: page_bytes,mapping_bytes,input_bytes
    real(jprb), pointer, contiguous :: protected_gfl(:,:,:)
    type(buffer) :: native(3),source(3)
    integer(c_int64_t) :: before_input(points*levels*fields),native_bits,source_bits,output_bytes
    integer :: component,row,column,property,cell,storage_field
    real(jprb) :: masses(fields),total_mass,wanted(3),allowance,observed
    page_bytes=int(libc_getpagesize(),c_size_t)
    input_bytes=int(points*levels*fields*8,c_size_t)
    if(page_bytes<input_bytes+8) error stop 'page smaller than capacity fixture'
    mapping_bytes=3*page_bytes
    mapping=libc_mmap(c_null_ptr,mapping_bytes,0_c_int,34_c_int,-1_c_int,0_c_long)
    base=transfer(mapping,base)
    if(.not.c_associated(mapping).or.base==-1_c_intptr_t) error stop 'capacity mmap'
    page_start=base+int(page_bytes,c_intptr_t)
    page_address=transfer(page_start,page_address)
    if(libc_mprotect(page_address,page_bytes,3_c_int)/=0) error stop 'capacity writable page'
    field_start=base+int(2*page_bytes-input_bytes,c_intptr_t)
    field_address=transfer(field_start,field_address)
    call c_f_pointer(field_address,protected_gfl,[points,levels,fields])
    ygfl%ndim=8
    ygfl%ndim1=fields
    ygfl%numflds=fields
    do component=1,fields
      ygfl%ycomp(component)%lthermact=.true.
      storage_field=ygfl%ycomp(component)%mp1
      if(storage_field<1.or.storage_field>fields) error stop 'capacity MP1'
      do row=1,levels
        protected_gfl(1,row,storage_field)=real(component+row,jprb)/4096.0_jprb
        protected_gfl(2,row,storage_field)=0.0_jprb
        protected_gfl(3,row,storage_field)=real(component*row,jprb)/1024.0_jprb
      end do
    end do
    before_input=transfer(protected_gfl,before_input)
    if(libc_mprotect(page_address,page_bytes,1_c_int)/=0) error stop 'capacity read-only page'
    do property=1,3
      allocate(native(property)%raw(cells+2),source(property)%raw(cells+2))
      native(property)%field(1:points,1:levels)=>native(property)%raw(2:cells+1)
      source(property)%field(1:points,1:levels)=>source(property)%raw(2:cells+1)
      native(property)%raw=-777.75_jprb
      source(property)%raw=-777.75_jprb
    end do
    if(openifs_fpcr()/=control) error stop 'capacity entry FPCR'
    call gprcp(points,first,last,levels,cp=source(1)%field,r=source(2)%field,kap=source(3)%field, &
      gfl=protected_gfl,kind=kind)
    if(openifs_fpcr()/=control) error stop 'capacity reference FPCR'
    if(any(transfer(protected_gfl,before_input)/=before_input)) error stop 'capacity reference input'
    call gprcp_assembly(points,first,last,levels,cp=native(1)%field,r=native(2)%field,kap=native(3)%field, &
      gfl=protected_gfl,kind=kind)
    if(openifs_fpcr()/=control) error stop 'capacity native FPCR'
    if(any(transfer(protected_gfl,before_input)/=before_input)) error stop 'capacity native input'
    output_bytes=0_c_int64_t
    do property=1,3
      do cell=1,cells+2
        native_bits=transfer(native(property)%raw(cell),native_bits)
        source_bits=transfer(source(property)%raw(cell),source_bits)
        if(native_bits/=source_bits) then
          write(*,'(a,2(i0,1x),2(z16.16,1x))') 'Mismatch capacity property cell ', &
            property,cell,native_bits,source_bits
          error stop 'capacity output bits'
        end if
        if(cell==1.or.cell==cells+2) then
          if(native_bits/=transfer(-777.75_jprb,native_bits)) error stop 'capacity output guard'
        else
          column=mod(cell-2,points)+1
          if(column<first.or.column>last) then
            if(native_bits/=transfer(-777.75_jprb,native_bits)) error stop 'capacity inactive output'
          end if
        end if
      end do
      write(assembly_unit) native(property)%raw
      write(reference_unit) source(property)%raw
      output_bytes=output_bytes+int((cells+2)*8,c_int64_t)
    end do
    do row=1,levels
      do column=first,last
        do component=1,fields
          masses(component)=protected_gfl(column,row,ygfl%ycomp(component)%mp1)
        end do
        total_mass=sum(masses)
        if(total_mass<0.0_jprb.or.total_mass>1.0_jprb) error stop 'capacity physical mass'
        wanted(1)=(1.0_jprb-total_mass)*rcpd+sum(masses*heat)
        wanted(2)=(1.0_jprb-total_mass)*rd+sum(masses*gas)
        wanted(3)=wanted(2)/wanted(1)
        do property=1,3
          observed=native(property)%field(column,row)
          if(.not.ieee_is_finite(observed)) error stop 'capacity nonfinite mixture'
          allowance=64*epsilon(1.0_jprb)*max(1.0_jprb,abs(wanted(property)))
          if(abs(observed-wanted(property))>allowance) error stop 'capacity independent dry/moist physics'
          if(column==2.and.transfer(observed,native_bits)/=transfer(wanted(property),source_bits)) &
            error stop 'capacity exact dry-air bits'
        end do
      end do
    end do
    if(libc_munmap(mapping,mapping_bytes)/=0) error stop 'capacity munmap'
    nullify(protected_gfl)
    do property=1,3
      deallocate(native(property)%raw,source(property)%raw)
    end do
    write(*,'(a,i0,a,i0,a,z16.16)') 'GPRCP CAPACITY PASS calls=1 bytes=',output_bytes, &
      ' input_bytes=',input_bytes,' differing_bytes=0 FPCR=',control
  end subroutine
