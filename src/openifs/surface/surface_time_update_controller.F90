module surftstp_ctl_mod
  use iso_fortran_env, only: int32,int64,real64
  use ieee_arithmetic, only: ieee_is_nan
  use yos_cst, only: tcst
  use yos_exc, only: texc
  use yos_soil, only: tsoil
  use yos_veg, only: tveg
  use yos_flake, only: tflake
  use yos_urb, only: turb
  use yos_ags, only: tags
  use yos_mlm, only: tmlm
  use yos_ocean_ml, only: tocean_ml
  use yos_thf, only: rhoh2o
  use srfene_mod, only: srfene
  use srfwl_mod, only: srfwl
  use srfsn_driver_mod, only: srfsn_driver
  use srfrcg_mod, only: srfrcg
  use srft_mod, only: srft
  use srfi_mod, only: srfi
  use srfwexc_vg_mod, only: srfwexc_vg
  use srfwdif_mod, only: srfwdif
  use srfwinc_mod, only: srfwinc
  use srfwng_mod, only: srfwng
  use flake_driver_mod, only: flake_driver
  use srfvegevol_mod, only: srfvegevol
  implicit none
  private
  public :: surftstp_ctl
  interface
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Apply the selected surface update in the order of surface_time_update_controller.S.
  !!
  !! The public native Fortran arguments keep the original typed interface.
  !! The owned snow, lake and vegetation children pass the retained component checks.
  !! Complete parent and adapter bytes pass; whole forecast agreement remains separate.
  subroutine surftstp_ctl(kidia,kfdia,klon,klevs,ktiles,klevsn,klevo,klevi,kstart,kstep,ktvl,ktvh,kveg,ksoty,ptsphy,psdor,pfrti,psst,pustrti,pvstrti,pahfsti,pevapti,pssrflti,pslrflti,plat,panfmvt,pandayvt,pmu0,pcvt,plaivt,plail,plaih,plailc,plaihc,ldland,ldsice,ldsi,ldnh,ldocn_kpp,psnm1m,ptsnm1m,pasnm1m,prsnm1m,pwsnm1m,paprs,ptskm1m,ptsam1m,ptiam1m,pwlm1m,pwsam1m,ptlicem1m,ptlmnwm1m,ptlwmlm1m,ptlbotm1m,ptlsfm1m,phlicem1m,phlmlm1m,pgemu,pldepth,ldlake,pclake,prsfc,prsfl,pslrfl,pssfc,pssfl,pcvl,pcvh,pcur,pwlmx,pevapsnw,pusrf,pvsrf,ptsrf,pzo,pho,pho_inv,pdo,pocdepth,puo0,pvo0,puoc,pvoc,pto0,pso0,padvt,padvs,ptri0,ptri1,pswdk_save,pustrc,pvstrc,pustokes,pvstokes,ptauocx,ptauocy,pphioc,pwsemean,pwsfmean,ydcst,ydexc,ydsoil,ydveg,ydflake,ydurb,ydags,ydmlm,ydocean_ml,ptsdfl,profd,profs,pwfsd,pmelt,pfwev,penes,pdifm,pdift,pdifs,potke,prespbstr,prespbstr2,pbiomass_last,pbiomasstr_last,pbiomasstr2_last,pblossvt,pbgainvt,plai,pbiom,pbloss,pbgain,pbiomstr,pbiomstr2,psne1,ptsne1,pasne1,prsne1,pwsne1,ptsae1,ptiae1,pwle1,pwsae1,ptlicee1,ptlmnwe1,ptlwmle1,ptlbote1,ptlsfe1,phlicee1,phlmle1,puoe1,pvoe1,ptoe1,psoe1,plaie1,pbstre1,pbstr2e1,pdhtss,pdhtts,pdhtis,pdhsss,pdhiis,pdhwls,pdhbios,pdhvegs)
integer(kind=int32),intent(in)    :: kidia
integer(kind=int32),intent(in)    :: kfdia
integer(kind=int32),intent(in)    :: klon
integer(kind=int32),intent(in)    :: klevs
integer(kind=int32),intent(in)    :: kstart
integer(kind=int32),intent(in)    :: kstep
integer(kind=int32),intent(in)    :: ktiles
integer(kind=int32),intent(in)    :: klevsn
integer(kind=int32),intent(in)    :: klevi
integer(kind=int32),intent(inout) :: kveg(:,:)
real(kind=real64)   ,intent(in)    :: plat(:)
real(kind=real64)   ,intent(inout) :: pcvt(:,:)
real(kind=real64)   ,intent(in)    :: ptskm1m(:)
real(kind=real64)   ,intent(inout) :: plaivt(:,:)
real(kind=real64)   ,intent(inout) :: plail(:)
real(kind=real64)   ,intent(inout) :: plaih(:)
real(kind=real64)   ,intent(inout) :: panfmvt(:,:)
real(kind=real64)   ,intent(inout) :: pandayvt(:,:)
real(kind=real64)   ,intent(inout) :: prespbstr(:,:)
real(kind=real64)   ,intent(inout) :: prespbstr2(:,:)
real(kind=real64)   ,intent(inout) :: pbiomass_last(:,:)
real(kind=real64)   ,intent(inout) :: pbiomasstr_last(:,:)
real(kind=real64)   ,intent(inout) :: pbiomasstr2_last(:,:)
real(kind=real64)   ,intent(inout) :: pblossvt(:,:)
real(kind=real64)   ,intent(inout) :: pbgainvt(:,:)
real(kind=real64)   ,intent(inout) :: plaie1(:,:)
real(kind=real64)   ,intent(inout) :: pbstre1(:,:)
real(kind=real64)   ,intent(inout) :: pbstr2e1(:,:)
real(kind=real64)   ,intent(inout)   :: plai(:)
real(kind=real64)   ,intent(inout)   :: pbiom(:)
real(kind=real64)   ,intent(inout)   :: pbloss(:)
real(kind=real64)   ,intent(inout)   :: pbgain(:)
real(kind=real64)   ,intent(inout)   :: pbiomstr(:)
real(kind=real64)   ,intent(inout)   :: pbiomstr2(:)
real(kind=real64)   ,intent(inout)   :: pdhbios(:,:,:)
real(kind=real64)   ,intent(inout)   :: pdhvegs(:,:,:)
real(kind=real64)   ,intent(in)    :: plailc(:)
real(kind=real64)   ,intent(in)    :: plaihc(:)
real(kind=real64)   ,intent(in)    :: pmu0(klon)
real(kind=real64)   ,intent(in)    :: paprs(:)
integer(kind=int32),intent(in)    :: klevo
real(kind=real64)   ,intent(in)    :: ptsphy
integer(kind=int32),intent(in)    :: ktvl(:)
integer(kind=int32),intent(in)    :: ktvh(:)
integer(kind=int32),intent(in)    :: ksoty(:)
real(kind=real64)   ,intent(in)    :: psdor(:)
real(kind=real64)   ,intent(in)    :: pfrti(:,:)
real(kind=real64)   ,intent(in)    :: pustrti(:,:)
real(kind=real64)   ,intent(in)    :: pvstrti(:,:)
real(kind=real64)   ,intent(in)    :: pahfsti(:,:)
real(kind=real64)   ,intent(in)    :: pevapti(:,:)
real(kind=real64)   ,intent(in)    :: pssrflti(:,:)
real(kind=real64)   ,intent(in)    :: pslrflti(:,:)
logical           ,intent(in)    :: ldland(:)
logical           ,intent(in)    :: ldsice(:)
logical           ,intent(in)    :: ldsi
logical           ,intent(in)    :: ldnh(:)
logical           ,intent(in)    :: ldlake(:)
logical           ,intent(in)    :: ldocn_kpp(:)
real(kind=real64)   ,intent(in)    :: pclake(:)
real(kind=real64)   ,intent(in)    :: psnm1m(:,:)
real(kind=real64)   ,intent(in)    :: ptsnm1m(:,:)
real(kind=real64)   ,intent(in)    :: pasnm1m(:)
real(kind=real64)   ,intent(in)    :: prsnm1m(:,:)
real(kind=real64)   ,intent(in)    :: pwsnm1m(:,:)
real(kind=real64)   ,intent(in)    :: ptsam1m(:,:)
real(kind=real64)   ,intent(in)    :: ptiam1m(:,:)
real(kind=real64)   ,intent(in)    :: pwlm1m(:)
real(kind=real64)   ,intent(in)    :: pwsam1m(:,:)
real(kind=real64)   ,intent(in)    :: prsfc(:)
real(kind=real64)   ,intent(in)    :: prsfl(:)
real(kind=real64)   ,intent(in)    :: pslrfl(:)
real(kind=real64)   ,intent(in)    :: pssfc(:)
real(kind=real64)   ,intent(in)    :: pssfl(:)
real(kind=real64)   ,intent(in)    :: pcvl(:)
real(kind=real64)   ,intent(in)    :: pcvh(:)
real(kind=real64)   ,intent(in)    :: pcur(:)
real(kind=real64)   ,intent(in)    :: pwlmx(:)
real(kind=real64)   ,intent(in)    :: pevapsnw(:)
real(kind=real64)   ,intent(in)    :: pusrf(:)
real(kind=real64)   ,intent(in)    :: pvsrf(:)
real(kind=real64)   ,intent(in)    :: ptsrf(:)
real(kind=real64)   ,intent(inout)   :: ptsdfl(:)
real(kind=real64)   ,intent(inout)   :: profd(:)
real(kind=real64)   ,intent(inout) :: profs(:)
real(kind=real64)   ,intent(inout)   :: pwfsd(:)
real(kind=real64)   ,intent(inout)   :: pmelt(:)
real(kind=real64)   ,intent(inout)   :: pfwev(:)
real(kind=real64)   ,intent(inout)   :: penes(:,:)
real(kind=real64)   ,intent(inout) :: psne1(:,:)
real(kind=real64)   ,intent(inout) :: ptsne1(:,:)
real(kind=real64)   ,intent(inout) :: pasne1(:)
real(kind=real64)   ,intent(inout) :: prsne1(:,:)
real(kind=real64)   ,intent(inout) :: pwsne1(:,:)
real(kind=real64)   ,intent(inout) :: ptsae1(:,:)
real(kind=real64)   ,intent(inout) :: ptiae1(:,:)
real(kind=real64)   ,intent(inout) :: pwle1(:)
real(kind=real64)   ,intent(inout) :: pwsae1(:,:)
real(kind=real64)   ,intent(inout)   :: pdhtss(:,:,:)
real(kind=real64)   ,intent(inout)   :: pdhtts(:,:,:)
real(kind=real64)   ,intent(inout)   :: pdhtis(:,:,:)
real(kind=real64)   ,intent(inout)   :: pdhsss(:,:,:)
real(kind=real64)   ,intent(inout)   :: pdhiis(:,:)
real(kind=real64)   ,intent(inout) :: pdhwls(:,:,:)
real(kind=real64)   ,intent(in)    :: psst(:)
real(kind=real64)   ,intent(in)    :: ptlicem1m(:)
real(kind=real64)   ,intent(in)    :: ptlmnwm1m(:)
real(kind=real64)   ,intent(in)    :: ptlwmlm1m(:)
real(kind=real64)   ,intent(in)    :: ptlbotm1m(:)
real(kind=real64)   ,intent(in)    :: ptlsfm1m(:)
real(kind=real64)   ,intent(in)    :: phlicem1m(:)
real(kind=real64)   ,intent(in)    :: phlmlm1m(:)
real(kind=real64)   ,intent(in)    :: pgemu(:)
real(kind=real64)   ,intent(in)    :: pldepth(:)
real(kind=real64)   ,intent(inout) :: ptlicee1(:)
real(kind=real64)   ,intent(inout) :: ptlmnwe1(:)
real(kind=real64)   ,intent(inout) :: ptlwmle1(:)
real(kind=real64)   ,intent(inout) :: ptlbote1(:)
real(kind=real64)   ,intent(inout) :: ptlsfe1(:)
real(kind=real64)   ,intent(inout) :: phlicee1(:)
real(kind=real64)   ,intent(inout) :: phlmle1(:)
real(kind=real64)   ,intent(inout) :: pzo(:,:)
real(kind=real64)   ,intent(inout) :: pho(:,:)
real(kind=real64)   ,intent(inout) :: pho_inv(:,:)
real(kind=real64)   ,intent(inout) :: pdo(:,:)
real(kind=real64)   ,intent(in)    :: pocdepth(:)
real(kind=real64)   ,intent(inout) :: padvt(:,:)
real(kind=real64)   ,intent(inout) :: padvs(:,:)
real(kind=real64)   ,intent(inout) :: puo0(:,:)
real(kind=real64)   ,intent(inout) :: pvo0(:,:)
real(kind=real64)   ,intent(inout) :: puoc(:,:)
real(kind=real64)   ,intent(inout) :: pvoc(:,:)
real(kind=real64)   ,intent(inout) :: pustrc(:)
real(kind=real64)   ,intent(inout) :: pvstrc(:)
real(kind=real64)   ,intent(inout) :: pto0(:,:)
real(kind=real64)   ,intent(inout) :: pso0(:,:)
real(kind=real64)   ,intent(inout) :: puoe1(:,:)
real(kind=real64)   ,intent(inout) :: pvoe1(:,:)
real(kind=real64)   ,intent(inout) :: ptoe1(:,:)
real(kind=real64)   ,intent(inout) :: psoe1(:,:)
real(kind=real64)   ,intent(inout) :: ptri0(:,:)
real(kind=real64)   ,intent(inout) :: ptri1(:,:)
real(kind=real64)   ,intent(inout) :: pswdk_save(:,:)
real(kind=real64)   ,intent(inout)   :: pdifm(:,:)
real(kind=real64)   ,intent(inout)   :: pdift(:,:)
real(kind=real64)   ,intent(inout)   :: pdifs(:,:)
real(kind=real64)   ,intent(inout) :: potke(:,:)
real(kind=real64)   ,intent(in)    :: pustokes(:)
real(kind=real64)   ,intent(in)    :: pvstokes(:)
real(kind=real64)   ,intent(in)    :: ptauocx(:)
real(kind=real64)   ,intent(in)    :: ptauocy(:)
real(kind=real64)   ,intent(in)    :: pphioc(:)
real(kind=real64)   ,intent(in)    :: pwsemean(:)
real(kind=real64)   ,intent(in)    :: pwsfmean(:)
type(tcst)        ,intent(in)    :: ydcst
type(texc)        ,intent(in)    :: ydexc
type(tsoil)       ,intent(in)    :: ydsoil
type(tveg)        ,intent(in)    :: ydveg
type(tflake)      ,intent(in)    :: ydflake
type(turb)        ,intent(in)    :: ydurb
type(tags)        ,intent(in)    :: ydags
type(tmlm)        ,intent(in)    :: ydmlm
type(tocean_ml)   ,intent(inout) :: ydocean_ml
    real(real64), allocatable :: zsn(:,:)
    real(real64), allocatable :: ztsn(:,:)
    real(real64), allocatable :: zasn(:)
    real(real64), allocatable :: zrsn(:,:)
    real(real64), allocatable :: ztsa(:,:)
    real(real64), allocatable :: ztia(:,:)
    real(real64), allocatable :: zwl(:)
    real(real64), allocatable :: zwsa(:,:)
    real(real64), allocatable :: zwsn(:,:)
    real(real64), allocatable :: zcfw(:,:)
    real(real64), allocatable :: zrhsw(:,:)
    real(real64), allocatable :: zwsadif(:,:)
    real(real64), allocatable :: zsawgfl(:,:)
    real(real64), allocatable :: zctsa(:,:)
    real(real64), allocatable :: ztsfc(:)
    real(real64), allocatable :: ztsfl(:)
    real(real64), allocatable :: zrsfc(:)
    real(real64), allocatable :: zrsfl(:)
    real(real64), allocatable :: zssfc(:)
    real(real64), allocatable :: zssfl(:)
    real(real64), allocatable :: zfwel1(:)
    real(real64), allocatable :: zfwe234(:)
    real(real64), allocatable :: zgsn(:)
    real(real64), allocatable :: zmsn(:)
    real(real64), allocatable :: zemssn(:)
    real(real64), allocatable :: zeintti(:,:)
    real(real64), allocatable :: zcdawz(:,:)
    real(real64), allocatable :: zslrflti(:,:)
    real(real64), allocatable :: ztlice(:)
    real(real64), allocatable :: ztlmnw(:)
    real(real64), allocatable :: ztlwml(:)
    real(real64), allocatable :: ztlbot(:)
    real(real64), allocatable :: ztlsf(:)
    real(real64), allocatable :: zhlice(:)
    real(real64), allocatable :: zhlml(:)
    real(real64), allocatable :: zrofs(:)
    real(real64), allocatable :: spare36(:)
    real(real64), allocatable :: spare37(:)
    real(real64) :: inverse_step,inverse_density,total,temporary,term,value
    integer(int32) :: column,layer,tile,allocation_status
    if (klon<1 .or. klon>4096 .or. kidia<1 .or. kfdia>klon) call reject_contract()
    if (kfdia<kidia) return
    if (klevs/=4 .or. ktiles/=9 .or. klevsn<1 .or. klevsn>64) call reject_contract()
    if (.not.ydsoil%lesnml .or. .not.ydsoil%levgen .or. ydsoil%lewbcheck .or. ydmlm%locmltke) call reject_contract()
    inverse_step=1.0_real64/ptsphy
    inverse_density=1.0_real64/rhoh2o
    allocate(zsn(klon,klevsn),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zsn=0.0_real64
    allocate(ztsn(klon,klevsn),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztsn=0.0_real64
    allocate(zasn(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zasn=0.0_real64
    allocate(zrsn(klon,klevsn),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zrsn=0.0_real64
    allocate(ztsa(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztsa=0.0_real64
    allocate(ztia(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztia=0.0_real64
    allocate(zwl(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zwl=0.0_real64
    allocate(zwsa(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zwsa=0.0_real64
    allocate(zwsn(klon,klevsn),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zwsn=0.0_real64
    allocate(zcfw(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zcfw=0.0_real64
    allocate(zrhsw(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zrhsw=0.0_real64
    allocate(zwsadif(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zwsadif=0.0_real64
    allocate(zsawgfl(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zsawgfl=0.0_real64
    allocate(zctsa(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zctsa=0.0_real64
    allocate(ztsfc(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztsfc=0.0_real64
    allocate(ztsfl(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztsfl=0.0_real64
    allocate(zrsfc(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zrsfc=0.0_real64
    allocate(zrsfl(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zrsfl=0.0_real64
    allocate(zssfc(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zssfc=0.0_real64
    allocate(zssfl(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zssfl=0.0_real64
    allocate(zfwel1(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zfwel1=0.0_real64
    allocate(zfwe234(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zfwe234=0.0_real64
    allocate(zgsn(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zgsn=0.0_real64
    allocate(zmsn(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zmsn=0.0_real64
    allocate(zemssn(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zemssn=0.0_real64
    allocate(zeintti(klon,9),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zeintti=0.0_real64
    allocate(zcdawz(klon,4),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zcdawz=0.0_real64
    allocate(zslrflti(klon,9),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zslrflti=0.0_real64
    allocate(ztlice(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztlice=0.0_real64
    allocate(ztlmnw(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztlmnw=0.0_real64
    allocate(ztlwml(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztlwml=0.0_real64
    allocate(ztlbot(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztlbot=0.0_real64
    allocate(ztlsf(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    ztlsf=0.0_real64
    allocate(zhlice(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zhlice=0.0_real64
    allocate(zhlml(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zhlml=0.0_real64
    allocate(zrofs(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    zrofs=0.0_real64
    allocate(spare36(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    spare36=0.0_real64
    allocate(spare37(klon),stat=allocation_status)
    if (allocation_status/=0) call reject_contract()
    spare37=0.0_real64
    do layer=1,4
      do column=kidia,kfdia
        zcdawz(column,layer)=ydsoil%rdaw(layer)
      end do
    end do
    do tile=1,9
      do column=kidia,kfdia
        if (ydexc%lelwtl) then
          zslrflti(column,tile)=pslrflti(column,tile)
        else
          zslrflti(column,tile)=pslrfl(column)
        end if
      end do
    end do
    do column=kidia,kfdia
      profs(column)=0.0_real64
      zrsfc(column)=maximum(0.0_real64,prsfc(column))
      zrsfl(column)=maximum(0.0_real64,prsfl(column))
      zssfc(column)=maximum(0.0_real64,pssfc(column))
      zssfl(column)=maximum(0.0_real64,pssfl(column))
    end do
    call srfene(kidia,kfdia,klon,klevs,ldland,ldsice,ptsam1m,ksoty,pcvl,pcvh,ydcst,ydsoil,penes)
    call srfwl(kidia,kfdia,ktiles,ptsphy,pwlm1m,pcvl,pcvh,pwlmx,pfrti,pevapti,zrsfc,zrsfl,pevapsnw,zwl,zfwel1,ztsfc,ztsfl,zeintti,ldland,ydsoil,ydveg,pdhiis)
    call srfsn_driver(kidia,kfdia,klon,klevsn,ptsphy,ldland,psdor,psnm1m,ptsnm1m,prsnm1m,pwsnm1m,pasnm1m,pfrti,ptsam1m,pusrf,pvsrf,ptsrf,zssfc,zssfl,ztsfc,ztsfl,pslrflti,pssrflti,pahfsti,pevapti,pevapsnw,pwsam1m,ksoty,paprs,ydsoil,ydcst,zsn,ztsn,zrsn,zwsn,zasn,zgsn,zmsn,zemssn,pdhtss,pdhsss)
    do column=kidia,kfdia
      total=0.0_real64
      do layer=1,size(psnm1m,2)
        total=total+psnm1m(column,layer)
      end do
      if (total<9000.0_real64) cycle
      zasn(column)=ydsoil%ralfminpsn
      if (ydsoil%lesnwbcon) cycle
      do layer=1,klevsn
        zrsn(column,layer)=ydsoil%rhomaxsn
        zwsn(column,layer)=0.0_real64
      end do
      total=0.0_real64
      do layer=1,klevsn-1
        total=total+zsn(column,layer)
      end do
      zsn(column,klevsn)=10000.0_real64-total
    end do
    call srfrcg(kidia,kfdia,klon,ktiles,klevs,ldland,ldsice,ptsam1m,ksoty,pcvl,pcvh,pcur,ydcst,ydsoil,ydurb,zctsa)
    call srft(kidia,kfdia,klon,ktiles,klevs,ptsphy,ptsam1m,pwsam1m,ksoty,pfrti,pahfsti,pevapti,zslrflti,pssrflti,zgsn,zctsa,ldland,ydcst,ydsoil,ydflake,ydurb,ztsa,ptsdfl,pdhtts)
    if (ldsi) then
    call srfi(kidia,kfdia,klon,klevs,klevi,ptsphy,ptiam1m,pfrti,pahfsti,pevapti,zslrflti(:,2),pssrflti,ldsice,ldnh,ydcst,ydsoil,ztia,pdhtis)
    else
      do layer=1,4
        do column=kidia,kfdia
          ztia(column,layer)=ptiam1m(column,layer)
          if (size(pdhtis)>0) then
            pdhtis(column,layer,1)=0.0_real64
            pdhtis(column,layer,2)=0.0_real64
            pdhtis(column,layer,3)=0.0_real64
            pdhtis(column,layer,4)=0.0_real64
            pdhtis(column,layer,9)=0.0_real64
            pdhtis(column,layer,10)=0.0_real64
            pdhtis(column,layer,11)=0.0_real64
            pdhtis(column,layer,12)=0.0_real64
          end if
        end do
      end do
    end if
    call srfwexc_vg(kidia,kfdia,klon,klevs,ktiles,ptsphy,ktvl,ktvh,ksoty,psdor,pfrti,pevapti,pwsam1m,ptsam1m,pcur,ztsfc,ztsfl,zmsn,zemssn,zeintti,pevapsnw,ydsoil,ydveg,ydurb,profs,zcfw,zrhsw,zsawgfl,zfwel1,zfwe234,ldland,pdhwls)
    call srfwdif(kidia,kfdia,klon,klevs,pwsam1m,zcfw,zrhsw,zcdawz,ydsoil,zwsadif,ldland)
    call srfwinc(kidia,kfdia,klevs,ptsphy,pwsam1m,zwsadif,zsawgfl,zcfw,ydsoil,zwsa,pwfsd,ldland,pdhwls)
    call srfwng(kidia,kfdia,klevs,ptsphy,ksoty,zwl,pwlmx,zwsa,ydsoil,profs,profd,pwfsd,ldland,pdhwls)
    do column=kidia,kfdia
      if (.not.ldland(column)) cycle
      temporary=zsawgfl(column,4)*ptsphy
      profd(column)=profd(column)+temporary
    end do
    if (ydflake%leflake) then
    call flake_driver(kidia,kfdia,klon,ldlake,pssrflti(:,9),zslrflti(:,9),pahfsti(:,9),pevapti(:,9),pustrti(:,9),pvstrti(:,9),pfrti,pldepth,pgemu,ptsphy,ydcst,ydflake,ptlicem1m,ptlmnwm1m,ptlwmlm1m,ptlbotm1m,ptlsfm1m,phlicem1m,phlmlm1m,ztlice,ztlmnw,ztlwml,ztlbot,ztlsf,zhlice,zhlml)
    else
      do column=kidia,kfdia
        ztlice(column)=ptlicem1m(column)
        ztlmnw(column)=ptlmnwm1m(column)
        ztlwml(column)=ptlwmlm1m(column)
        ztlbot(column)=ptlbotm1m(column)
        ztlsf(column)=ptlsfm1m(column)
        zhlice(column)=phlicem1m(column)
        zhlml(column)=phlmlm1m(column)
      end do
    end if
    do column=kidia,kfdia
      if (ldland(column)) cycle
      if (ldlake(column)) then
        do layer=1,4
          ztsa(column,layer)=ztlwml(column)
        end do
      else
        temporary=maximum(psst(column),ydcst%rtt)
        ztlwml(column)=temporary
        ztlmnw(column)=temporary
        ztlbot(column)=temporary
        ztlsf(column)=0.65_real64
        ztlice(column)=ztia(column,1)
        if (ldsice(column)) then
          temporary=pfrti(column,2)/10.0_real64
          zhlice(column)=minimum(temporary,0.1_real64)
        else
          zhlice(column)=0.0_real64
        end if
        zhlml(column)=minimum(pldepth(column),50.0_real64)
      end if
    end do
    do layer=1,klevsn
      do column=kidia,kfdia
        temporary=zsn(column,layer)-psnm1m(column,layer)
        temporary=temporary*inverse_step
        psne1(column,layer)=psne1(column,layer)+temporary
        temporary=ztsn(column,layer)-ptsnm1m(column,layer)
        temporary=temporary*inverse_step
        ptsne1(column,layer)=ptsne1(column,layer)+temporary
        temporary=zrsn(column,layer)-prsnm1m(column,layer)
        temporary=temporary*inverse_step
        prsne1(column,layer)=prsne1(column,layer)+temporary
        temporary=zwsn(column,layer)-pwsnm1m(column,layer)
        temporary=temporary*inverse_step
        pwsne1(column,layer)=pwsne1(column,layer)+temporary
      end do
    end do
    do column=kidia,kfdia
      temporary=zasn(column)-pasnm1m(column)
      temporary=temporary*inverse_step
      pasne1(column)=pasne1(column)+temporary
      temporary=ztlice(column)-ptlicem1m(column)
      temporary=temporary*inverse_step
      ptlicee1(column)=ptlicee1(column)+temporary
      temporary=ztlmnw(column)-ptlmnwm1m(column)
      temporary=temporary*inverse_step
      ptlmnwe1(column)=ptlmnwe1(column)+temporary
      temporary=ztlwml(column)-ptlwmlm1m(column)
      temporary=temporary*inverse_step
      ptlwmle1(column)=ptlwmle1(column)+temporary
      temporary=ztlbot(column)-ptlbotm1m(column)
      temporary=temporary*inverse_step
      ptlbote1(column)=ptlbote1(column)+temporary
      temporary=ztlsf(column)-ptlsfm1m(column)
      temporary=temporary*inverse_step
      ptlsfe1(column)=ptlsfe1(column)+temporary
      temporary=zhlice(column)-phlicem1m(column)
      temporary=temporary*inverse_step
      phlicee1(column)=phlicee1(column)+temporary
      temporary=zhlml(column)-phlmlm1m(column)
      temporary=temporary*inverse_step
      phlmle1(column)=phlmle1(column)+temporary
    end do
    do layer=1,4
      do column=kidia,kfdia
        temporary=ztia(column,layer)-ptiam1m(column,layer)
        temporary=temporary*inverse_step
        ptiae1(column,layer)=ptiae1(column,layer)+temporary
      end do
    end do
    do layer=1,4
      do column=kidia,kfdia
        if (pfrti(column,9)>0.0_real64) then
          temporary=ztsa(column,layer)-ptsam1m(column,layer)
        else
          temporary=ztia(column,layer)-ptiam1m(column,layer)
          term=pfrti(column,2)*temporary
          temporary=1.0_real64-pfrti(column,1)
          temporary=temporary-pfrti(column,2)
          value=ztsa(column,layer)-ptsam1m(column,layer)
          temporary=temporary*value
          temporary=term+temporary
        end if
        temporary=temporary*inverse_step
        ptsae1(column,layer)=ptsae1(column,layer)+temporary
      end do
    end do
    do column=kidia,kfdia
      temporary=zwl(column)-pwlm1m(column)
      temporary=temporary*inverse_step
      pwle1(column)=pwle1(column)+temporary
    end do
    do layer=1,4
      do column=kidia,kfdia
        temporary=zwsa(column,layer)-pwsam1m(column,layer)
        temporary=temporary*inverse_step
        pwsae1(column,layer)=pwsae1(column,layer)+temporary
      end do
    end do
    do column=kidia,kfdia
      pfwev(column)=zfwel1(column)+zfwe234(column)
      profs(column)=profs(column)*inverse_step
      profd(column)=profd(column)*inverse_step
      ptsdfl(column)=-ptsdfl(column)
      pmelt(column)=zmsn(column)
    end do
    if (ydsoil%lerolake) then
      do column=kidia,kfdia
        if (.not.ldland(column) .and. ldlake(column)) then
          temporary=profs(column)+zrsfc(column)
          temporary=temporary+zrsfl(column)
          temporary=temporary+zssfc(column)
          profs(column)=temporary+zssfl(column)
        end if
        profs(column)=profs(column)+zrofs(column)
      end do
    end if
    if (ydveg%lectessel) then
    call srfvegevol(kidia,kfdia,klon,klevs,kstep,ptsphy,plat,pmu0,pcvt,pcvl,pcvh,kveg,ktvl,ktvh,ptskm1m,ptsam1m,panfmvt,pandayvt,plaivt,plail,plaih,plailc,plaihc,prespbstr,prespbstr2,pbiomass_last,pbiomasstr_last,pbiomasstr2_last,pblossvt,pbgainvt,plaie1,pbstre1,pbstr2e1,plai,pbiom,pbloss,pbgain,pbiomstr,pbiomstr2,pdhbios,pdhvegs,ydcst,ydveg,ydags)
    else
      do column=kidia,kfdia
        temporary=pcvl(column)*plail(column)
        term=pcvh(column)*plaih(column)
        plai(column)=temporary+term
        pbiom(column)=0.0_real64
        pbloss(column)=0.0_real64
        pbgain(column)=0.0_real64
        pbiomstr(column)=0.0_real64
        pbiomstr2(column)=0.0_real64
      end do
      if (size(pdhbios)>0) then
        do tile=1,ydveg%nvtiles
          do column=kidia,kfdia
            pdhbios(column,tile,1)=0.0_real64
            pdhbios(column,tile,2)=0.0_real64
            pdhbios(column,tile,3)=0.0_real64
            pdhbios(column,tile,4)=0.0_real64
            pdhbios(column,tile,5)=0.0_real64
          end do
        end do
      end if
    end if
  end subroutine surftstp_ctl
  !> Preserve the assembly minimum, including both signs of zero.
  pure function minimum(a,b) result(value)
    real(real64), intent(in) :: a,b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value=a
    else if (ieee_is_nan(b)) then
      value=b
    else if (a==0.0_real64 .and. b==0.0_real64) then
      value=transfer(ior(transfer(a,0_int64),transfer(b,0_int64)),value)
    else if (a<b) then
      value=a
    else
      value=b
    end if
  end function minimum
  !> Preserve the assembly maximum, including both signs of zero.
  pure function maximum(a,b) result(value)
    real(real64), intent(in) :: a,b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value=a
    else if (ieee_is_nan(b)) then
      value=b
    else if (a==0.0_real64 .and. b==0.0_real64) then
      value=transfer(iand(transfer(a,0_int64),transfer(b,0_int64)),value)
    else if (a>b) then
      value=a
    else
      value=b
    end if
  end function maximum
end module surftstp_ctl_mod
