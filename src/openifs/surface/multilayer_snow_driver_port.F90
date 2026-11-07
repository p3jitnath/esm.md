module srfsn_driver_mod
  use iso_fortran_env, only: int32,int64,real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_get_rounding_mode,ieee_round_type,ieee_nearest,operator(/=)
  use yos_soil, only: tsoil
  use yos_cst, only: tcst
  use srfsn_asn_mod, only: srfsn_asn
  use srfsn_vgrid_mod, only: srfsn_vgrid
  use srfsn_regrid_mod, only: srfsn_regrid
  use srfsn_rsn_mod, only: srfsn_rsn
  use srfsn_ssrabs_mod, only: srfsn_ssrabs
  use srfsn_webal_mod, only: srfsn_webal
  implicit none
  private
  public :: srfsn_driver
  interface
    function selected_sine(value) bind(c,name="sin") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_sine
    function selected_logarithm10(value) bind(c,name="log10") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_logarithm10
    function selected_power(value,power) bind(c,name="md2asm_pow_original_rounding_candidate") result(answer)
      import c_double
      real(c_double), value :: value,power
      real(c_double) :: answer
    end function selected_power
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Advance the complete snow column using six owned numerical children.
  !!
  !! The first dimension has at least KLON rows. KIDIA:KFDIA selects active rows.
  !! Snow mass and liquid water use kg m^-2, temperatures use kelvin, density
  !! uses kg m^-3, and PTMST uses seconds. Heat fluxes use W m^-2.
  !! Tile arrays contain at least seven tiles. Diagnostic arrays are rank three.
  !! Every mutable array is copied before calculation and committed only after
  !! all child calls return. Inactive cells and all readonly inputs retain their bits.
SUBROUTINE SRFSN_DRIVER(KIDIA   ,KFDIA   ,KLON   ,KLEVSN, PTMST, LDLAND,&
  & PSDOR, &
  & PSSNM1M, PTSNM1M, PRSNM1M  ,PWSNM1M, PASNM1M, &
  & PFRTI, PTSAM1M , PUSRF, PVSRF, PTSRF ,&
  & PSSFC, PSSFL   , PTSFC, PTSFL, &
  & PSLRFLTI, PSSRFLTI , PAHFSTI, PEVAPTI, PEVAPSNW, &
  & PWSAM1M , KSOTY, PAPRS, &
  & YDSOIL , YDCST, &
  & PSSN,  PTSN, PRSN, PWSN, PASN, &
  & PGSN, PMSN, PEMSSN, & 
  & PDHTSS, PDHSSS)
INTEGER(KIND=int32), INTENT(IN)   :: KIDIA
INTEGER(KIND=int32), INTENT(IN)   :: KFDIA
INTEGER(KIND=int32), INTENT(IN)   :: KLON
INTEGER(KIND=int32), INTENT(IN)   :: KLEVSN
REAL(KIND=real64)   , INTENT(IN)   :: PTMST
LOGICAL(int32)    , INTENT(IN)   :: LDLAND(:)
REAL(KIND=real64)   , INTENT(IN)   :: PSDOR(:)
REAL(KIND=real64),    INTENT(IN)   :: PSSNM1M(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PTSNM1M(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PRSNM1M(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PWSNM1M(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PASNM1M(:)
REAL(KIND=real64),    INTENT(IN)   :: PFRTI(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PTSAM1M(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PUSRF(:)
REAL(KIND=real64),    INTENT(IN)   :: PVSRF(:)
REAL(KIND=real64),    INTENT(IN)   :: PTSRF(:)
REAL(KIND=real64),    INTENT(IN)   :: PAPRS(:)
REAL(KIND=real64),    INTENT(IN)   :: PSSFC(:)
REAL(KIND=real64),    INTENT(IN)   :: PSSFL(:)
REAL(KIND=real64),    INTENT(INOUT)   :: PTSFC(:)
REAL(KIND=real64),    INTENT(INOUT)   :: PTSFL(:)
REAL(KIND=real64),    INTENT(IN)   :: PSLRFLTI(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PSSRFLTI(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PAHFSTI(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PEVAPTI(:,:)
REAL(KIND=real64),    INTENT(IN)   :: PEVAPSNW(:)
REAL(KIND=real64),    INTENT(IN)   :: PWSAM1M(:,:)
INTEGER(KIND=int32), INTENT(IN)   :: KSOTY(:)
TYPE(TSOIL)       , INTENT(IN)   :: YDSOIL
TYPE(TCST)        , INTENT(IN)   :: YDCST
REAL(KIND=real64),    INTENT(INOUT)  :: PSSN(:,:)
REAL(KIND=real64),    INTENT(INOUT)  :: PTSN(:,:)
REAL(KIND=real64),    INTENT(INOUT)  :: PRSN(:,:)
REAL(KIND=real64),    INTENT(INOUT)  :: PwSN(:,:)
REAL(KIND=real64),    INTENT(INOUT)  :: PASN(:)
REAL(KIND=real64),    INTENT(INOUT)  :: PGSN(:)
REAL(KIND=real64),    INTENT(INOUT)  :: PMSN(:)
REAL(KIND=real64),    INTENT(INOUT)  :: PEMSSN(:)
REAL(KIND=real64),    INTENT(INOUT)  :: PDHTSS(:,:,:)
REAL(KIND=real64),    INTENT(INOUT)  :: PDHSSS(:,:,:)

    real(real64), allocatable :: frsn(:),snowfall(:),rainfall(:),heat_flux(:),evaporation(:),surface_conductivity(:),phase_change(:)
    real(real64), allocatable :: melting(:,:),freezing(:,:),mass_old(:,:),temperature_old(:,:),density_old(:,:),water_old(:,:)
    real(real64), allocatable :: new_depth(:,:),clipped_mass(:,:),clipped_water(:,:),radiation(:,:),tile_fraction(:,:),tile_shortwave(:,:)
    logical(int32), allocatable :: no_snow(:)
    integer(int32), allocatable :: active_layers(:)
    real(real64), allocatable :: throughc(:),throughl(:),new_mass(:,:),new_temperature(:,:),new_density(:,:),new_water(:,:)
    real(real64), allocatable :: new_albedo(:),ground_heat(:),runoff(:),emissivity(:),heat_diagnostic(:,:,:),mass_diagnostic(:,:,:)
    real(real64) :: term,value,temporary,first_term,second_term,latent_term,porosity,dry_conductivity,saturated_conductivity
    real(real64) :: frozen_fraction,logarithmic_weight,ice_power,water_power,conductivity_difference
    real(real64), parameter :: zero=0.0_real64,one=1.0_real64
    real(real64), parameter :: timestep_min=transfer(int(z'3e112e0be826d695',int64),0.0_real64)
    real(real64), parameter :: timestep_max=transfer(int(z'41cdcd6500000000',int64),0.0_real64)
    real(real64), parameter :: mass_bound=transfer(int(z'426d1a94a2000000',int64),0.0_real64)
    real(real64), parameter :: fraction_sum_max=transfer(int(z'3ff0000000000001',int64),0.0_real64)
    real(real64), parameter :: conductivity_min=transfer(int(z'3fc851eb851eb852',int64),0.0_real64)
    real(real64), volatile :: smallest,subnormal
    integer(int32) :: column,layer,tile,soil_kind,allocation_status
    logical :: diagnostics
    type(ieee_round_type) :: rounding
    call ieee_get_rounding_mode(rounding)
    if (rounding/=ieee_nearest) call reject_contract()
    smallest=tiny(one)
    subnormal=smallest*0.5_real64
    if (subnormal==zero) call reject_contract()
    if (klon<1 .or. klon>4096 .or. klevsn<1 .or. klevsn>64) call reject_contract()
    if (kidia<1 .or. kidia>klon .or. kfdia<kidia-1 .or. kfdia>klon) call reject_contract()
    if (.not.in_range(ptmst,timestep_min,timestep_max)) call reject_contract()
    if (min(size(ldland),size(psdor),size(pasnm1m),size(pusrf),size(pvsrf),size(ptsrf),size(paprs), &
        size(pssfc),size(pssfl),size(ptsfc),size(ptsfl),size(pevapsnw),size(ksoty),size(pasn), &
        size(pgsn),size(pmsn),size(pemssn))<klon) call reject_contract()
    if (min(size(pssnm1m,1),size(ptsnm1m,1),size(prsnm1m,1),size(pwsnm1m,1),size(pfrti,1),size(ptsam1m,1), &
        size(pslrflti,1),size(pssrflti,1),size(pahfsti,1),size(pevapti,1),size(pwsam1m,1), &
        size(pssn,1),size(ptsn,1),size(prsn,1),size(pwsn,1))<klon) call reject_contract()
    if (min(size(pssnm1m,2),size(ptsnm1m,2),size(prsnm1m,2),size(pwsnm1m,2), &
        size(pssn,2),size(ptsn,2),size(prsn,2),size(pwsn,2))<klevsn) call reject_contract()
    if (min(size(pfrti,2),size(pslrflti,2),size(pssrflti,2),size(pahfsti,2),size(pevapti,2))<7) call reject_contract()
    if (min(size(ptsam1m,2),size(pwsam1m,2))<1) call reject_contract()
    diagnostics=size(pdhtss)>0 .and. size(pdhsss)>0
    if (diagnostics) then
      if (min(size(pdhtss,1),size(pdhsss,1))<klon .or. min(size(pdhtss,2),size(pdhsss,2))<klevsn) call reject_contract()
      if (size(pdhtss,3)<15 .or. size(pdhsss,3)<5) call reject_contract()
    end if
    if (.not.allocated(ydsoil%rwsatm) .or. .not.allocated(ydsoil%rlambdadrym) .or. .not.allocated(ydsoil%rlamsat1m)) &
        call reject_contract()
    if (.not.allocated(ydsoil%rlevsnmin) .or. .not.allocated(ydsoil%rlevsnmax) .or. &
        .not.allocated(ydsoil%rlevsnmin_gl) .or. .not.allocated(ydsoil%rlevsnmax_gl)) call reject_contract()
    ! The selected generated route has diagnostic budget logging disabled.
    if (ydsoil%lesncheck) call reject_contract()
    do column=kidia,kfdia
      if (.not.in_range(psdor(column),zero,1.0e6_real64)) call reject_contract()
      if (.not.in_range(pasnm1m(column),zero,one)) call reject_contract()
      if (.not.in_range(pusrf(column),-1000.0_real64,1000.0_real64)) call reject_contract()
      if (.not.in_range(pvsrf(column),-1000.0_real64,1000.0_real64)) call reject_contract()
      if (.not.in_range(ptsrf(column),100.0_real64,500.0_real64)) call reject_contract()
      if (.not.in_range(pssfc(column),zero,one) .or. .not.in_range(pssfl(column),zero,one)) call reject_contract()
      if (.not.in_range(ptsfc(column),zero,one) .or. .not.in_range(ptsfl(column),zero,one)) call reject_contract()
      if (.not.in_range(pevapsnw(column),-one,one)) call reject_contract()
      if (.not.in_range(paprs(column),one,1.0e7_real64)) call reject_contract()
      do tile=5,7,2
        if (.not.in_range(pfrti(column,tile),zero,one)) call reject_contract()
        if (.not.in_range(pslrflti(column,tile),-1.0e6_real64,1.0e6_real64)) call reject_contract()
        if (.not.in_range(pssrflti(column,tile),-1.0e6_real64,1.0e6_real64)) call reject_contract()
        if (.not.in_range(pahfsti(column,tile),-1.0e6_real64,1.0e6_real64)) call reject_contract()
        if (.not.in_range(pevapti(column,tile),-one,one)) call reject_contract()
      end do
      value=pfrti(column,5)+pfrti(column,7)
      if (.not.in_range(value,zero,fraction_sum_max)) call reject_contract()
      do layer=1,klevsn
        if (.not.in_range(pssnm1m(column,layer),-mass_bound,mass_bound)) call reject_contract()
        if (.not.in_range(pwsnm1m(column,layer),-mass_bound,mass_bound)) call reject_contract()
        if (.not.in_range(ptsnm1m(column,layer),100.0_real64,273.16_real64)) call reject_contract()
        if (.not.in_range(prsnm1m(column,layer),one,1000.0_real64)) call reject_contract()
      end do
    end do
    allocate(frsn(klon),snowfall(klon),rainfall(klon),heat_flux(klon),evaporation(klon),surface_conductivity(klon), &
        phase_change(klon),melting(klon,klevsn),freezing(klon,klevsn),mass_old(klon,klevsn), &
        temperature_old(klon,klevsn),density_old(klon,klevsn),water_old(klon,klevsn),new_depth(klon,klevsn), &
        clipped_mass(klon,klevsn),clipped_water(klon,klevsn),radiation(klon,klevsn+1), &
        tile_fraction(klon,7),tile_shortwave(klon,7),no_snow(klon),active_layers(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    frsn=zero
    snowfall=zero
    rainfall=zero
    heat_flux=zero
    evaporation=zero
    surface_conductivity=zero
    phase_change=zero
    melting=zero
    freezing=zero
    mass_old=zero
    temperature_old=zero
    density_old=zero
    water_old=zero
    new_depth=zero
    clipped_mass=zero
    clipped_water=zero
    radiation=zero
    tile_fraction=zero
    tile_shortwave=zero
    no_snow=.false.
    active_layers=0
    allocate(throughc(size(ptsfc)),throughl(size(ptsfl)),new_mass(size(pssn,1),size(pssn,2)), &
        new_temperature(size(ptsn,1),size(ptsn,2)),new_density(size(prsn,1),size(prsn,2)), &
        new_water(size(pwsn,1),size(pwsn,2)),new_albedo(size(pasn)),ground_heat(size(pgsn)), &
        runoff(size(pmsn)),emissivity(size(pemssn)),heat_diagnostic(size(pdhtss,1),size(pdhtss,2),size(pdhtss,3)), &
        mass_diagnostic(size(pdhsss,1),size(pdhsss,2),size(pdhsss,3)),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    throughc=ptsfc
    throughl=ptsfl
    new_mass=pssn
    new_temperature=ptsn
    new_density=prsn
    new_water=pwsn
    new_albedo=pasn
    ground_heat=pgsn
    runoff=pmsn
    emissivity=pemssn
    heat_diagnostic=pdhtss
    mass_diagnostic=pdhsss
    do column=kidia,kfdia
      do tile=1,7
        tile_fraction(column,tile)=pfrti(column,tile)
        tile_shortwave(column,tile)=pssrflti(column,tile)
      end do
      do layer=1,klevsn
        clipped_mass(column,layer)=maximum(zero,pssnm1m(column,layer))
        value=maximum(zero,pwsnm1m(column,layer))
        clipped_water(column,layer)=minimum(clipped_mass(column,layer),value)
      end do
      value=pfrti(column,5)+pfrti(column,7)
      frsn(column)=maximum(value,ydsoil%rfrtiny)
      no_snow(column)=frsn(column)<ydsoil%rfrsmall
      if (ldland(column)) then
        snowfall(column)=pssfc(column)+pssfl(column)
      else
        snowfall(column)=zero
      end if
      first_term=pfrti(column,5)*pevapti(column,5)
      second_term=pfrti(column,7)*pevapsnw(column)
      evaporation(column)=first_term+second_term
      if (no_snow(column)) then
        heat_flux(column)=zero
        rainfall(column)=zero
        surface_conductivity(column)=zero
        cycle
      end if
      first_term=ydcst%rlstt*pevapti(column,5)
      first_term=pahfsti(column,5)+first_term
      first_term=pfrti(column,5)*first_term
      second_term=pevapti(column,7)-pevapsnw(column)
      second_term=ydcst%rlvtt*second_term
      latent_term=ydcst%rlstt*pevapsnw(column)
      second_term=pahfsti(column,7)+second_term
      second_term=second_term+latent_term
      second_term=pfrti(column,7)*second_term
      value=first_term+second_term
      term=pfrti(column,5)*pssrflti(column,5)
      value=value+term
      term=pfrti(column,7)*pssrflti(column,7)
      value=value+term
      term=pfrti(column,5)*pslrflti(column,5)
      value=value+term
      term=pfrti(column,7)*pslrflti(column,7)
      heat_flux(column)=value+term
      value=ptsfc(column)+ptsfl(column)
      rainfall(column)=frsn(column)*value
      value=one-frsn(column)
      throughc(column)=value*ptsfc(column)
      throughl(column)=value*ptsfl(column)
      value=ptsam1m(column,1)
      if (.not.in_range(value,100.0_real64,500.0_real64)) call reject_contract()
      if (value>=274.16_real64) then
        frozen_fraction=zero
      else if (value<=270.16_real64) then
        frozen_fraction=one
      else
        value=value-272.16_real64
        value=0.7853981633974483_real64*value
        value=selected_sine(value)
        value=one-value
        frozen_fraction=0.5_real64*value
      end if
      soil_kind=ksoty(column)
      if (soil_kind<lbound(ydsoil%rwsatm,1) .or. soil_kind>ubound(ydsoil%rwsatm,1)) call reject_contract()
      if (soil_kind<lbound(ydsoil%rlambdadrym,1) .or. soil_kind>ubound(ydsoil%rlambdadrym,1)) call reject_contract()
      if (soil_kind<lbound(ydsoil%rlamsat1m,1) .or. soil_kind>ubound(ydsoil%rlamsat1m,1)) call reject_contract()
      porosity=ydsoil%rwsatm(soil_kind)
      if (.not.in_range(porosity,0.03125_real64,one)) call reject_contract()
      dry_conductivity=ydsoil%rlambdadrym(soil_kind)
      saturated_conductivity=ydsoil%rlamsat1m(soil_kind)
      value=pwsam1m(column,1)
      if (.not.in_range(value,zero,one)) call reject_contract()
      value=value/porosity
      value=maximum(0.1_real64,value)
      logarithmic_weight=selected_logarithm10(value)
      temporary=porosity*frozen_fraction
      ice_power=selected_power(2.2_real64,temporary)
      temporary=one-frozen_fraction
      temporary=porosity*temporary
      water_power=selected_power(0.57_real64,temporary)
      value=saturated_conductivity*ice_power
      value=value*water_power
      conductivity_difference=value-dry_conductivity
      value=one*logarithmic_weight
      value=value+one
      value=value*conductivity_difference
      value=dry_conductivity+value
      value=minimum(2.0_real64,value)
      surface_conductivity(column)=maximum(conductivity_min,value)
    end do
    call srfsn_vgrid(kidia,kfdia,klon,klevsn,no_snow,psdor,clipped_mass,prsnm1m, &
        ydsoil%rlevsnmin,ydsoil%rlevsnmax,ydsoil%rlevsnmin_gl,ydsoil%rlevsnmax_gl,new_depth,active_layers)
    call srfsn_regrid(kidia,kfdia,klon,klevsn,no_snow,clipped_mass,prsnm1m,clipped_water,ptsnm1m,new_depth, &
        mass_old,density_old,water_old,temperature_old)
    call srfsn_ssrabs(kidia,kfdia,klon,klevsn,no_snow,tile_fraction,tile_shortwave,mass_old,density_old,ydsoil,ydcst,radiation)
    call srfsn_webal(kidia,kfdia,klon,klevsn,ptmst,no_snow,frsn,mass_old,water_old,density_old,temperature_old, &
        ptsam1m(:,1),heat_flux,radiation,snowfall,rainfall,evaporation,surface_conductivity,paprs,ydsoil,ydcst, &
        new_mass,new_water,new_temperature,ground_heat,runoff,melting,freezing,heat_diagnostic,mass_diagnostic)
    call srfsn_rsn(kidia,kfdia,klon,klevsn,ptmst,no_snow,density_old,mass_old,temperature_old,water_old,new_water, &
        snowfall,pusrf,pvsrf,ptsrf,ydsoil,ydcst,new_density,heat_diagnostic)
    do column=kidia,kfdia
      emissivity(column)=zero
      phase_change(column)=melting(column,1)-freezing(column,1)
    end do
    call srfsn_asn(kidia,kfdia,klon,ptmst,no_snow,pasnm1m,phase_change,temperature_old,snowfall,ydsoil,ydcst,new_albedo)
    if (diagnostics) then
      do column=kidia,kfdia
        if (no_snow(column)) cycle
        mass_diagnostic(column,1,2)=pssfl(column)
        mass_diagnostic(column,1,3)=pssfc(column)
        first_term=pfrti(column,5)*pahfsti(column,5)
        second_term=pfrti(column,7)*pahfsti(column,7)
        heat_diagnostic(column,1,11)=first_term+second_term
        first_term=pfrti(column,5)*ydcst%rlstt
        first_term=first_term*pevapti(column,5)
        second_term=pevapti(column,7)-pevapsnw(column)
        second_term=ydcst%rlvtt*second_term
        latent_term=ydcst%rlstt*pevapsnw(column)
        second_term=second_term+latent_term
        second_term=pfrti(column,7)*second_term
        heat_diagnostic(column,1,12)=first_term+second_term
        do layer=1,klevsn
          heat_diagnostic(column,layer,5)=prsnm1m(column,layer)
          if (layer==1) cycle
          mass_diagnostic(column,layer,2)=zero
          mass_diagnostic(column,layer,3)=zero
          heat_diagnostic(column,layer,11)=zero
          heat_diagnostic(column,layer,12)=zero
        end do
      end do
    end if
    ptsfc=throughc
    ptsfl=throughl
    pssn=new_mass
    ptsn=new_temperature
    prsn=new_density
    pwsn=new_water
    pasn=new_albedo
    pgsn=ground_heat
    pmsn=runoff
    pemssn=emissivity
    pdhtss=heat_diagnostic
    pdhsss=mass_diagnostic
  end subroutine srfsn_driver
  !> Check a physical interval before any public output changes.
  elemental pure logical function in_range(value,low,high)
    real(real64), intent(in) :: value,low,high
    integer(int64) :: bits
    bits=transfer(value,0_int64)
    if (iand(shiftr(bits,52),2047_int64)==2047_int64) then
      in_range=.false.
    else
      in_range=value>=low .and. value<=high
    end if
  end function in_range
  !> Preserve a finite minimum and the negative sign of zero.
  pure real(real64) function minimum(left,right) result(value)
    real(real64), intent(in) :: left,right
    if (left<right) then
      value=left
    else if (right<left) then
      value=right
    else if (left==0.0_real64 .and. right==0.0_real64) then
      value=transfer(ior(transfer(left,0_int64),transfer(right,0_int64)),value)
    else
      value=left
    end if
  end function minimum
  !> Preserve a finite maximum and the positive sign of zero.
  pure real(real64) function maximum(left,right) result(value)
    real(real64), intent(in) :: left,right
    if (left>right) then
      value=left
    else if (right>left) then
      value=right
    else if (left==0.0_real64 .and. right==0.0_real64) then
      value=transfer(iand(transfer(left,0_int64),transfer(right,0_int64)),value)
    else
      value=left
    end if
  end function maximum
end module srfsn_driver_mod
