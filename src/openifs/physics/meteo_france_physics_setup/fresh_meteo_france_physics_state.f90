!> Prepare compiler-native fresh setup storage before the numerical parent.
!! Every named undefined scalar/fixed array receives a zero-born value.
!! Canonical declaration defaults remain in effect. A compiler-emitted
!! SAVE template supplies empty owner descriptors and native padding.
submodule(forecast_meteo_france_physics_state) fresh_meteo_france_physics_state_implementation
  use iso_c_binding, only: c_ptr, c_size_t, c_loc
  implicit none
  !> Hold a complete native empty record without a copied live owner.
  !! Character storage uses NUL bytes to match the original fresh allocation.
  !! The compiler, rather than a private ABI offset, defines this representation.
  type(owned_meteo_france_physics_state), save, target :: fresh_template = &
                                                          owned_meteo_france_physics_state( &
                                                          atmospheric_parameters=tphy0( &
      tym=reshape([0.0_real64],[5],pad=[0.0_real64]),npclo1=0_int32,npclo2=0_int32,a0ml_au=0.0_real64,a0ml_at=0.0_real64,a0ml_bu=0.0_real64, &
                 a0ml_bt=0.0_real64, aercs1=0.0_real64, aercs3=0.0_real64, aercs5=0.0_real64, adjtau=0.0_real64, almav=0.0_real64, &
                             bedifv=0.0_real64, ecmnp=0.0_real64, edb=0.0_real64, edc=0.0_real64, edd=0.0_real64, evap=0.0_real64, &
                     font=0.0_real64, galp=0.0_real64, gcismin=0.0_real64, gevavf=0.0_real64, gccsv=0.0_real64, gcvads=0.0_real64, &
           gcvbeta=0.0_real64, gcvimpt=0.0_real64, gcvomge=0.0_real64, gcvomgq=0.0_real64, gcvomgs=0.0_real64, gcvturb=0.0_real64, &
       gcvomdps=0.0_real64, gcvomgsx=0.0_real64, gcvrhmin=0.0_real64, gcvrhmax=0.0_real64, gcvomca=0.0_real64, gcvomcc=0.0_real64, &
             gddeva=0.0_real64, gddsde=0.0_real64, gddfrevs=0.0_real64, gddinhom=0.0_real64, grcvpp=0.0_real64, gwdamp=0.0_real64, &
                    gwdbc=0.0_real64, gwdcco=0.0_real64, gwdcd=0.0_real64, gwdlt=0.0_real64, gwdse=0.0_real64, gwdprof=0.0_real64, &
                   gwdvali=0.0_real64, hobst=0.0_real64, hucoe=0.0_real64, hutil=0.0_real64, hutil1=0.0_real64, hutil2=0.0_real64, &
                  qsmin=0.0_real64, qsmodc=0.0_real64, qsnebc=0.0_real64, qsnebs=0.0_real64, qssusc=0.0_real64, qssuss=0.0_real64, &
                    qssusv=0.0_real64, qsusxc=0.0_real64, qsusxs=0.0_real64, rphi0=0.0_real64, rphir=0.0_real64, qxral=0.0_real64, &
                qxral_adj=0.0_real64, qxrdel=0.0_real64, qxrhx=0.0_real64, qxrr=0.0_real64, qxrtgh=0.0_real64, qxrcdil=0.0_real64, &
               rcin=0.0_real64, rcvevap=0.0_real64, rdecrd=0.0_real64, rdecrd1=0.0_real64, rdecrd2=0.0_real64, rdecrd3=0.0_real64, &
           rdecrd4=0.0_real64, rdecrdred=0.0_real64, rdtfac=0.0_real64, revapn=0.0_real64, revgsl=0.0_real64, rgelsfon=0.0_real64, &
                    rflchce=0.0_real64, rtcape=0.0_real64, sco=0.0_real64, sensl=0.0_real64, snnbco=0.0_real64, spnbco=0.0_real64, &
                           sxnbco=0.0_real64, tca=0.0_real64, tct=0.0_real64, tcw=0.0_real64, tentr=0.0_real64, tentrx=0.0_real64, &
                        tudgp=0.0_real64, tddgp=0.0_real64, turb=0.0_real64, tvf=0.0_real64, uhdifv=0.0_real64, usdmlt=0.0_real64, &
               usuprc=0.0_real64, usuric=0.0_real64, vchrnk=0.0_real64, vkarmn=0.0_real64, vz0cm=0.0_real64, vziustar0=0.0_real64, &
                       xnbmax=0.0_real64, aecls3=0.0_real64, aecls4=0.0_real64, ald=0.0_real64, akn=0.0_real64, alphat=0.0_real64, &
                      alphae=0.0_real64, eps=0.0_real64, etacut=0.0_real64, adisi=0.0_real64, adise=0.0_real64, ectmin=0.0_real64, &
                 ectmax=0.0_real64, ahclpv=0.0_real64, ricrlm=0.0_real64, rmulacvg=0.0_real64, xblm=0.0_real64, xminlm=0.0_real64, &
               xmaxlm=0.0_real64, xwsalm=0.0_real64, xwsblm=0.0_real64, gcvalfa=0.0_real64, gcvpsi=0.0_real64, gcvpsie=0.0_real64, &
                 usurice=0.0_real64, usuricl=0.0_real64, qssc=0.0_real64, usurid=0.0_real64, gcvnu=0.0_real64, usuride=0.0_real64, &
           gcvmlt=0.0_real64, utilgust=0.0_real64, rrgamma=0.0_real64, rrscale=0.0_real64, gpblhk0=0.0_real64, gpblhra=0.0_real64, &
                  wmxov=0.0_real64, acbrphim=0.0_real64, almave=0.0_real64, almavx=0.0_real64, arsch=0.0_real64, arscq=0.0_real64, &
                  arsc1=0.0_real64, arsb2=0.0_real64, ricret=0.0_real64, sttbmin=0.0_real64, ucwstar=0.0_real64, udect=0.0_real64, &
         upretmin=0.0_real64, upretmax=0.0_real64, ushearm=0.0_real64, rautefr=0.0_real64, rrautcs=0.0_real64, rautefs=0.0_real64, &
                rautsbet=0.0_real64, revasx=0.0_real64, rnintr=0.0_real64, rnints=0.0_real64, rqlcr=0.0_real64, rspcrr=0.0_real64, &
         rqicrmax=0.0_real64, rqicrmin=0.0_real64, rqlcv=0.0_real64, rqicvmax=0.0_real64, rqicvmin=0.0_real64, rqicrt1=0.0_real64, &
               rqicrt2=0.0_real64, rqicrsn=0.0_real64, rqcrns=0.0_real64, raccef=0.0_real64, raggef=0.0_real64, rrimef=0.0_real64, &
                 rhcrit1=0.0_real64, rhcrit2=0.0_real64, retamin=0.0_real64, rfacnsm=0.0_real64, tfvl=0.0_real64, tfvi=0.0_real64, &
                 tfvr=0.0_real64, tfvs=0.0_real64, grhcmod=0.0_real64, rhcexpdx=0.0_real64, nuptke=0.0_real64, tkemult=0.0_real64, &
 c_epsilon=0.0_real64,c3tkefree=0.0_real64,etke_ctheta=0.0_real64,etke_rifc_maf=0.0_real64,etke_rifc=0.0_real64,etke_r=0.0_real64, &
    etke_olam=0.0_real64,etke_lam0=0.0_real64,etke_lam1=0.0_real64,etke_lam2=0.0_real64,etke_lam3=0.0_real64,etke_lam4=0.0_real64, &
 etke_ka1=0.0_real64, etke_ka2=0.0_real64, etke_ka3=0.0_real64, ent_lambda=0.0_real64, etke_cg01=0.0_real64, etke_cg02=0.0_real64, &
      etke_cg03=0.0_real64,etke_beta_eps=0.0_real64,etke_gamma_eps=0.0_real64,etke_gamd=0.0_real64,etke_talph=0.0_real64,etke_alph0=0.0_real64, &
etke_entrx=0.0_real64, etke_entrn=0.0_real64, etke_klm=0.0_real64, etke_taulm=0.0_real64, etke_min=0.0_real64, efb_az0=0.0_real64, &
                   efb_ur=0.0_real64, refb_1=0.0_real64, refb_2=0.0_real64, refb_3=0.0_real64, tudbu=0.0_real64, tddbu=0.0_real64, &
               tudfr=0.0_real64, tddfr=0.0_real64, gcvalmx=0.0_real64, gcvtaude=0.0_real64, gcvachi=0.0_real64, gcvbee=0.0_real64, &
                gcveex=0.0_real64, ecmnpi=0.0_real64, grrmina=0.0_real64, gddbeta=0.0_real64, gdddp=0.0_real64, gddfxm=0.0_real64, &
            gddwpf=0.0_real64, gddevf=0.0_real64, tentrd=0.0_real64, gddalbu=0.0_real64, gddfrac=0.0_real64, gddendymx=0.0_real64, &
      gddfp=reshape([0.0_real64],[3],pad=[0.0_real64]),gddtausig=0.0_real64,gpeiphi=0.0_real64,gpetau=0.0_real64,gpefdc=0.0_real64,genvsrh=0.0_real64, &
     gcvkskv=0.0_real64, gcvalbu=0.0_real64, gcvendy1=0.0_real64, gcvendy2=0.0_real64, gcvendymx=0.0_real64, gcvidpbas=0.0_real64, &
gcvtausig=0.0_real64, gtrgdpmix=0.0_real64, gtrgdphimn=0.0_real64, gtrgpuslmn=0.0_real64, gtrgkck9=0.0_real64, gtrgain=0.0_real64, &
         gtrthrs=0.0_real64, gtrthck=0.0_real64, gtrbrc=0.0_real64, gtrkgain=0.0_real64, gtrkthrs=0.0_real64, gtrkthck=0.0_real64, &
   gcvcatau=0.0_real64, gcathrcap=0.0_real64, gcathrmoc=0.0_real64, gcathrcnd=0.0_real64, gcaomcnd=0.0_real64, nweight=0.0_real64, &
                ncatau=0.0_real64, ncapemax=0.0_real64, ncvgmax=0.0_real64, rnegat=0.0_real64, rnlcurv=0.0_real64, edk=0.0_real64, &
                xklm=0.0_real64, agre1=0.0_real64, agrericr=0.0_real64, ajbumin=0.0_real64, rcoflm=0.0_real64, tentrvl=0.0_real64, &
                      trentrv=0.0_real64, gcvgamma=0.0_real64, lkesc=.false., agre2=0.0_real64, agref=0.0_real64, alfx=0.0_real64, &
                     alfx_lr=0.0_real64, alfx_hr=0.0_real64, tctc=0.0_real64, tvfc=0.0_real64, gamap1=0.0_real64, rkdn=0.0_real64, &
                         vvn=0.0_real64, vvx=0.0_real64, fentrt=0.0_real64, fqlic=0.0_real64, fnebc=0.0_real64, fevapc=0.0_real64, &
                 rdphic=0.0_real64, rwbf1=0.0_real64, rwbf2=0.0_real64, sclespr=0.0_real64, sclesps=0.0_real64, hucred=0.0_real64, &
              hucredra=0.0_real64, fsprain=0.0_real64, effcoll=0.0_real64, rsmdnebx=0.0_real64, rsmdtx=0.0_real64, nsmtpa=0_int32, &
               nsmtpb=0_int32, rkfbtau=0.0_real64, rkfbnbx=0.0_real64, gcvhmin=0.0_real64, gcvresn=0.0_real64, gcvresx=0.0_real64, &
                    gmirh=0.0_real64, rlmlh1=0.0_real64, rprth=0.0_real64, rsmoothmelt=0.0_real64, ladvlim=.false., lgddd=.false., &
                  lcvnhd=.false., lcvresdyn=.false., lcvmicc=.false., gmukedd=0.0_real64, gnhdtat=0.0_real64, gnhdsmos=0.0_real64, &
                          gnhdsmot=0.0_real64, gnhdev=0.0_real64, lgvvex=.false., lcvuvm=.false., ncventr=0_int32, ncvsig=0_int32, &
              ncvclos=0_int32, ncvqli=0_int32, gcventrn=0.0_real64, gcventrx=0.0_real64, adoe=0.0_real64, rfrac_entr_n=0.0_real64, &
      rfrac_entr_x=0.0_real64, gcventr_min=0.0_real64, thpcmt=0.0_real64, aj1peps=0.0_real64, aj1meps=0.0_real64, najiter=0_int32, &
                  gaeps=0.0_real64, gcvez=0.0_real64, gcvtrmin=0.0_real64, lcvfevv=.false., gcvfevv=0.0_real64, lcvcontau=.false., &
               gcvtexc=0.0_real64, gcvwexc=0.0_real64, lcvnauv=.false., gcvfrr=0.0_real64, gcvpnh=0.0_real64, gcvorged=0.0_real64, &
                lcvimpt=.false., gcvtaurem=0.0_real64, gcloea=0.0_real64, gcloeb=0.0_real64, gfrae=0.0_real64, gcvadet=0.0_real64, &
               gcvcinc=0.0_real64, gsdmin=0.0_real64, gsdmax=0.0_real64, galmin=0.0_real64, galmax=0.0_real64, gsdamin=0.0_real64, &
                    gsdamax=0.0_real64, gexpkd=0.0_real64, lcveod=.false., gremin=0.0_real64, gremax=0.0_real64, gchi0=0.0_real64, &
                  gfsurf=0.0_real64, gshell=0.0_real64, gfric=0.0_real64, guddd=0.0_real64, gsiga=0.0_real64, gnhdsmow=0.0_real64, &
                 gdepth=0.0_real64, galtau=0.0_real64, gkeddre=0.0_real64, gnhacc=0.0_real64, gtdcl=0.0_real64, gsinhd=0.0_real64, &
            gsinhr=0.0_real64, gcvfner=0.0_real64, gcvfneo=0.0_real64, gcvfnep1=0.0_real64, gcvfnep2=0.0_real64, grbcc=0.0_real64, &
                gtopdepth=0.0_real64, gcvtsmo=0.0_real64, rkdx=0.0_real64, lcapcin=.false., lcorsedim=.false., gnhdtau=0.0_real64, &
                           grso=0.0_real64, grth=0.0_real64, grfcs=0.0_real64, gcvre=0.0_real64, lsbuo=.false., greddi=0.0_real64, &
                        greddl=0.0_real64, greddr=0.0_real64, gredds=0.0_real64, lcvtadv=.false., lcvds=.false., gcvuv=0.0_real64, &
      gcvgaw=0.0_real64,gcvgax=0.0_real64,gcheckmv_tmin=0.0_real64,gcheckmv_tmax=0.0_real64,gcheckmv_qvmin=0.0_real64,gcheckmv_qvmax=0.0_real64, &
                      lgproni1=.false., nproni=0_int32, gproni=0.0_real64, rnebcx=0.0_real64, reflrhc=0.0_real64, teqh=0.0_real64, &
                                                         reflkuo=0.0_real64, reflcape=0.0_real64, teqk=0.0_real64, teqc=0.0_real64 &
                                                          ), &
                                                          surface_exchange_parameters=tphy1( &
      gf3=reshape([0.0_real64],[18],pad=[0.0_real64]),gf4=reshape([0.0_real64],[18],pad=[0.0_real64]),tref4=reshape([0.0_real64],[18],pad=[0.0_real64]),rctveg=reshape([0.0_real64],[18],pad=[0.0_real64]),rgl=reshape([0.0_real64],[18],pad=[0.0_real64]),sodelx=reshape([0.0_real64],[10],pad=[0.0_real64]), &
      gcz0h=reshape([0.0_real64],[4,4],pad=[0.0_real64]),albgla=0.0_real64,albmax=0.0_real64,albmer=0.0_real64,albmed=0.0_real64,albmin=0.0_real64, &
                     alcrin=0.0_real64, alrcn1=0.0_real64, alrcn2=0.0_real64, ea=0.0_real64, ec2ref=0.0_real64, emcrin=0.0_real64, &
                          emmgla=0.0_real64, emmmer=0.0_real64, ewfc=0.0_real64, ewwilt=0.0_real64, ga=0.0_real64, gc1=0.0_real64, &
                      gc1s1=0.0_real64, gc1s2=0.0_real64, gc1s3=0.0_real64, gc1s4=0.0_real64, gc1y1=0.0_real64, gtsvap=0.0_real64, &
                     gvegmx=0.0_real64, glaimx=0.0_real64, gneimx=0.0_real64, gwpimx=0.0_real64, gcgel=0.0_real64, gc2=0.0_real64, &
                            gc2ref=0.0_real64, gc3=0.0_real64, gc31=0.0_real64, gc32=0.0_real64, gconv=0.0_real64, gf1=0.0_real64, &
                       gwfc=0.0_real64, gwlex=0.0_real64, gwlmx=0.0_real64, gwwilt=0.0_real64, g1b=0.0_real64, g1cgsat=0.0_real64, &
                    g1c1sat=0.0_real64, g1p=0.0_real64, g1wsat=0.0_real64, g2b=0.0_real64, g2cgsat=0.0_real64, g2c1sat=0.0_real64, &
                       g2p=0.0_real64, g2wsat=0.0_real64, g3cgsat=0.0_real64, gsnc1=0.0_real64, gsnc2=0.0_real64, hsol=0.0_real64, &
               hsoliwr=0.0_real64, hsolit0=0.0_real64, omtpro=0.0_real64, omwpro=0.0_real64, rc1max=0.0_real64, rctgla=0.0_real64, &
                    rcgmax=0.0_real64, rd1=0.0_real64, rd2gla=0.0_real64, rd2mer=0.0_real64, rhomax=0.0_real64, rhomin=0.0_real64, &
                  rsmax=0.0_real64, rtiner=0.0_real64, rz0gla=0.0_real64, rz0mer=0.0_real64, rzhz0g=0.0_real64, rzhz0m=0.0_real64, &
                    tmergl=0.0_real64, toexp=0.0_real64, tolin=0.0_real64, wcrin=0.0_real64, wcrinc=0.0_real64, wcring=0.0_real64, &
                     wnew=0.0_real64, wpmx=0.0_real64, wsmx=0.0_real64, xcrinr=0.0_real64, xcrinv=0.0_real64, lalbmerclim=.false., &
                                      limc=.false., limw=.false., lc1vap=.false., lcls_hs=.false., ntvgla=0_int32, ntvmer=0_int32, &
                  gcgels=0.0_real64, gvegmxs=0.0_real64, glaimxs=0.0_real64, gneimxs=0.0_real64, alb1=0.0_real64, alb2=0.0_real64, &
                                                          rlaimx=0.0_real64, rlai=0.0_real64, acls_hs=0.0_real64, nchsp=0_int32 &
                                                          ), &
                                                          legacy_radiation_parameters=tphy3( &
      bsfsa=reshape([0.0_real64],[6],pad=[0.0_real64]),bsfsi=0.0_real64,bsfsn=0.0_real64,bsfta=reshape([0.0_real64],[6],pad=[0.0_real64]),bsfti=0.0_real64,bsftn=0.0_real64, &
      earrt=0.0_real64,eoasa=reshape([0.0_real64],[6],pad=[0.0_real64]),eoasi=0.0_real64,eoasn=0.0_real64,eoata=reshape([0.0_real64],[6],pad=[0.0_real64]),eoati=0.0_real64, &
      eoatn=0.0_real64,eodsa=reshape([0.0_real64],[6],pad=[0.0_real64]),eodsi=0.0_real64,eodsn=0.0_real64,eodta=reshape([0.0_real64],[6],pad=[0.0_real64]),eodti=0.0_real64, &
      eodtn=0.0_real64,eoray=0.0_real64,gca=reshape([0.0_real64],[6],pad=[0.0_real64]),gcb=reshape([0.0_real64],[6],pad=[0.0_real64]),gcc=reshape([0.0_real64],[6],pad=[0.0_real64]),gcd4=0.0_real64, &
                     gce4=0.0_real64, girec1=0.0_real64, girec2=0.0_real64, girec3=0.0_real64, girec4=0.0_real64, qco2=0.0_real64, &
  rii0=0.0_real64,usaa=reshape([0.0_real64],[6],pad=[0.0_real64]),usai=0.0_real64,usan=0.0_real64,usba=0.0_real64,usbi=0.0_real64, &
      usbn=0.0_real64,vdp=reshape([0.0_real64],[5,6],pad=[0.0_real64]),vnp=reshape([0.0_real64],[5,6],pad=[0.0_real64]),rexp_neb=0.0_real64,fcm_del_a=reshape([0.0_real64],[2],pad=[0.0_real64]),fcm_del_d=reshape([0.0_real64],[2],pad=[0.0_real64]), &
      fcm_mu_a=reshape([0.0_real64],[2],pad=[0.0_real64]),fcm_mu_d=reshape([0.0_real64],[2],pad=[0.0_real64]),fcm_n_i=0.0_real64,fcm_n_l=0.0_real64,fcm_ai=0.0_real64,fcm_al=0.0_real64, &
 fcm_b_ai=0.0_real64, fcm_b_al=0.0_real64, fcm_b_bi=0.0_real64, fcm_b_bl=0.0_real64, fcm_del_ai=0.0_real64, fcm_del_al=0.0_real64, &
  fcm_del_di=0.0_real64,fcm_del_dl=0.0_real64,fcm_mu_ai=0.0_real64,fcm_mu_al=0.0_real64,fcm_mu_di=0.0_real64,fcm_mu_dl=0.0_real64, &
      fcm_nu_ai=0.0_real64,fcm_nu_al=0.0_real64,fcm_nu_di=0.0_real64,fcm_nu_dl=0.0_real64,fcm_iwc2de=reshape([0.0_real64],[2,6],pad=[0.0_real64]),fcm_lwc2re=reshape([0.0_real64],[2,6],pad=[0.0_real64]), &
      fcm_p_ai=reshape([0.0_real64],[2,4],pad=[0.0_real64]),fcm_p_al=reshape([0.0_real64],[2,4],pad=[0.0_real64]),fcm_p_di=reshape([0.0_real64],[2,4],pad=[0.0_real64]),fcm_p_dl=reshape([0.0_real64],[2,4],pad=[0.0_real64]),fcm_p_gi=reshape([0.0_real64],[2,4],pad=[0.0_real64]),fcm_p_gl=reshape([0.0_real64],[2,4],pad=[0.0_real64]), &
      fcm_q_ai=reshape([0.0_real64],[2,3],pad=[0.0_real64]),fcm_q_al=reshape([0.0_real64],[2,3],pad=[0.0_real64]),fcm_q_di=reshape([0.0_real64],[2,3],pad=[0.0_real64]),fcm_q_dl=reshape([0.0_real64],[2,3],pad=[0.0_real64]),fcm_q_gi=reshape([0.0_real64],[2,3],pad=[0.0_real64]),fcm_q_gl=reshape([0.0_real64],[2,3],pad=[0.0_real64]), &
      fsm_aa=reshape([0.0_real64],[3],pad=[0.0_real64]),fsm_bb=reshape([0.0_real64],[3],pad=[0.0_real64]),fsm_cc=0.0_real64,fsm_dd=0.0_real64,fsm_ee=0.0_real64,fsm_ff=0.0_real64, &
      fsm_gg=0.0_real64,fsm_hh=0.0_real64,fsm_ii=0.0_real64,golca=reshape([0.0_real64],[6],pad=[0.0_real64]),golcb=reshape([0.0_real64],[6],pad=[0.0_real64]),golcc=reshape([0.0_real64],[6],pad=[0.0_real64]), &
      fgts_a=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgts_b=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgts_c=reshape([0.0_real64],[5],pad=[0.0_real64]),fgts_alpha=reshape([0.0_real64],[3],pad=[0.0_real64]),fgts_delta0=reshape([0.0_real64],[3],pad=[0.0_real64]),fgts_d=reshape([0.0_real64],[3],pad=[0.0_real64]), &
      fgts_p00=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgts_p=reshape([0.0_real64],[3,6,3],pad=[0.0_real64]),fgts_q=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgts_oa=reshape([0.0_real64],[3],pad=[0.0_real64]),fgts_ob=reshape([0.0_real64],[3],pad=[0.0_real64]),fgts_oc=reshape([0.0_real64],[3],pad=[0.0_real64]), &
      fgts_od=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtc_a=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtc_b=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtc_c=reshape([0.0_real64],[5],pad=[0.0_real64]),fgtc_alpha=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtc_delta0=reshape([0.0_real64],[3],pad=[0.0_real64]), &
      fgtc_d=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtc_p00=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtc_p=reshape([0.0_real64],[3,6,3],pad=[0.0_real64]),fgtc_q=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtc_oa=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtc_ob=reshape([0.0_real64],[3],pad=[0.0_real64]), &
      fgtc_oc=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtc_od=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtt_a=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtt_b=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtt_c=reshape([0.0_real64],[5],pad=[0.0_real64]),fgtt_alpha=reshape([0.0_real64],[3],pad=[0.0_real64]), &
      fgtt_delta0=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtt_d=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtt_p00=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtt_p=reshape([0.0_real64],[3,6,3],pad=[0.0_real64]),fgtt_q=reshape([0.0_real64],[3,3],pad=[0.0_real64]),fgtt_oa=reshape([0.0_real64],[3],pad=[0.0_real64]), &
      fgtt_ob=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtt_oc=reshape([0.0_real64],[3],pad=[0.0_real64]),fgtt_od=reshape([0.0_real64],[3],pad=[0.0_real64]),frs_k_scat0=0.0_real64,frs_p_crit=0.0_real64,frs_beta=0.0_real64, &
                                               rlamb_solid=0.0_real64, rlamb_water=0.0_real64, rmixd=0.0_real64, rmixp0=0.0_real64 &
                                                          ), &
                                                          ozone_deposition_parameters=tvdoz( &
      vdhjs=reshape([0.0_real64],[99],pad=[0.0_real64]),vdhjh=reshape([0.0_real64],[99],pad=[0.0_real64]),vdhns=reshape([0.0_real64],[99],pad=[0.0_real64]),vdhnh=reshape([0.0_real64],[99],pad=[0.0_real64]),vdpjs=reshape([0.0_real64],[99],pad=[0.0_real64]),vdpjh=reshape([0.0_real64],[99],pad=[0.0_real64]), &
      vdpns=reshape([0.0_real64],[99],pad=[0.0_real64]),vdpnh=reshape([0.0_real64],[99],pad=[0.0_real64]),vdejs=reshape([0.0_real64],[99],pad=[0.0_real64]),vdejh=reshape([0.0_real64],[99],pad=[0.0_real64]),vdens=reshape([0.0_real64],[99],pad=[0.0_real64]),vdenh=reshape([0.0_real64],[99],pad=[0.0_real64]), &
      vdajs=reshape([0.0_real64],[99],pad=[0.0_real64]),vdajh=reshape([0.0_real64],[99],pad=[0.0_real64]),vdans=reshape([0.0_real64],[99],pad=[0.0_real64]),vdanh=reshape([0.0_real64],[99],pad=[0.0_real64]),vdnjs=reshape([0.0_real64],[99],pad=[0.0_real64]),vdnjh=reshape([0.0_real64],[99],pad=[0.0_real64]), &
      vdnns=reshape([0.0_real64],[99],pad=[0.0_real64]),vdnnh=reshape([0.0_real64],[99],pad=[0.0_real64]),voznj=0.0_real64,vozhs=0.0_real64,lrdifoz=.false.,lrdepoz=.false. &
                                                          ), &
                                                          top_atmosphere_parameters=ttoph( &
                               rfmesoq=0.0_real64, ntqsat=0_int32, ntdifu=0_int32, ntcoef=0_int32, ntdrag=0_int32, ntcvim=0_int32, &
                                     nt850=0_int32, nt950=0_int32, ntplui=0_int32, ntradi=0_int32, ntnebu=0_int32, ntozon=0_int32, &
                             ntdrme=0_int32, ntcoet=0_int32, ntajuc=0_int32, ntrelaxt=0_int32, ntrelaxq=0_int32, ntrelaxu=0_int32, &
                  etqsat=0.0_real64, etdifu=0.0_real64, etcoef=0.0_real64, etdrag=0.0_real64, etcvim=0.0_real64, et850=0.0_real64, &
                  et950=0.0_real64, etplui=0.0_real64, etradi=0.0_real64, etnebu=0.0_real64, etozon=0.0_real64, etdrme=0.0_real64, &
           etcoet=0.0_real64, etajuc=0.0_real64, etrelaxt=0.0_real64, etrelaxq=0.0_real64, etrelaxu=0.0_real64, xdrmuk=0.0_real64, &
                 xdrmux=0.0_real64, xdrmup=0.0_real64, xdrmtk=0.0_real64, xdrmtx=0.0_real64, xdrmtp=0.0_real64, xdrmqk=0.0_real64, &
                                                         xdrmqp=0.0_real64, xdrmqx=0.0_real64, rclx=0.0_real64, tpsclim=0.0_real64 &
                                                          ), &
                                                          nonorographic_wave_parameters=tnorgwd( &
      norgwd_scheme=repeat(achar(0),4),norgwd_prmax=0.0_real64,norgwd_dz=0.0_real64,norgwd_ptropo=0.0_real64,norgwd_ntropo=0_int32,norgwd_ruwmax=0.0_real64, &
      norgwd_sat=0.0_real64,norgwd_rdiss=0.0_real64,norgwd_deltat=0.0_real64,norgwd_kmin=0.0_real64,norgwd_kmax=0.0_real64,norgwd_cmin=0.0_real64, &
      norgwd_cmax=0.0_real64,norgwd_plaunch=0.0_real64,norgwd_nlaunch=0_int32,norgwd_pnoverdif=0.0_real64,norgwd_nnoverdif=0_int32,norgwd_dzfron=0.0_real64, &
                                                          norgwd_gfron=0.0_real64, norgwd_gb=0.0_real64 &
                                                          ), &
                                                          alternative_parameters=tparar( &
              cmicro=repeat(achar(0), 4), csedim=repeat(achar(0), 4), nsplitr=0_int32, nsplitg=0_int32, nrr=0_int32, nrrl=0_int32, &
                                       nrri=0_int32, nsv=0_int32, nswb_mnh=0_int32, ngpar=0_int32, minprr=0_int32, macprr=0_int32, &
                                 minprs=0_int32, macprs=0_int32, minprg=0_int32, macprg=0_int32, malbdir=0_int32, malbsca=0_int32, &
                                            mrain=0_int32, msnow=0_int32, mgz0=0_int32, mgz0h=0_int32, mvqs=0_int32, mvts=0_int32, &
                                       mvemis=0_int32, mswdir=0_int32, mswdif=0_int32, mfrthds=0_int32, mlsm=0_int32, mcd=0_int32, &
                          losubg_cond=.false., losedic=.false., lowarm=.false., losigmas=.false., lolsmc=.false., lotownc=.false., &
          locnd2=.false., lgrsn=.false., radgr=0.0_real64, radsn=0.0_real64, vsigqsat=0.0_real64, cmf_updraft=repeat(achar(0), 4), &
          cmf_cloud=repeat(achar(0), 4), lmixuv=.false., llcrit=.false., ltotprec=.false., xalp_pert=0.0_real64, xabuo=0.0_real64, &
            xbentr=0.0_real64, xbdetr=0.0_real64, xcmf=0.0_real64, xentr_mf=0.0_real64, xcrad_mf=0.0_real64, xentr_dry=0.0_real64, &
    xdetr_dry=0.0_real64, xdetr_lup=0.0_real64, xkcf_mf=0.0_real64, xkrc_mf=0.0_real64, xtausigmf=0.0_real64, xpres_uv=0.0_real64, &
                xfrac_up_max=0.0_real64, xalpha_mf=0.0_real64, xsigma_mf=0.0_real64, xa1=0.0_real64, xb=0.0_real64, xc=0.0_real64, &
                         xbeta1=0.0_real64, xr=0.0_real64, xlambda=0.0_real64, lthetas=.false., lsquall=.false., nrefroi1=0_int32, &
                       nrefroi2=0_int32, vsquall=0.0_real64, nptp=0_int32, nprintfr=0_int32, ldiagwmax=.false., ndiagwmax=0_int32, &
      ndtchem=0_int32,larobu_enable=.false.,xlini=0.0_real64,lharatu=.false.,csubg_aucv_rc=repeat(achar(0),4),csubg_rc_rr_accr=repeat(achar(0),80), &
      csubg_rr_evap=repeat(achar(0),80),csubg_pr_pdf=repeat(achar(0),80),rcriauti=0.0_real64,rcriautc=0.0_real64,rt0criauti=0.0_real64,lcriauti=.false., &
      xtstep_ts=0.0_real64,xmrstep=0.0_real64,nmaxiter_micro=0_int32,csnowriming=repeat(achar(0),4),xfracm90=0.0_real64,lnullwetg=.false., &
                   lwetgpost=.false., lnullweth=.false., lwethpost=.false., lfeedbackt=.false., levlimit=.false., lconvhg=.false., &
      lcrflimit=.false.,cfrac_ice_adjust=repeat(achar(0),1),cfrac_ice_shallow_mf=repeat(achar(0),1),lsedim_after=.false.,xsplit_maxcfl=0.0_real64,lfprec3d=.false., &
                                                          xcqvr=0.0_real64, gqvplim=0.0_real64, gqvtop=0.0_real64, lqvtop=.false. &
                                                          ), &
                                                          convective_energy_controls=native_convective_energy_controls( &
                                    ncapeiter=0_int32, netapes=0_int32, ncapepsd=0_int32, gcaperet=0.0_real64, gcapepsd=0.0_real64 &
                                                          ), &
                                                          land_reference_parameters=land_surface_reference_record( &
                               smask=0.0_real64, smanq=0.0_real64, ntpmer=0_int32, ntpgla=0_int32, ntpdes=0_int32, ntplac=0_int32, &
                       szz0n=0.0_real64, szz0m=0.0_real64, szz0b=0.0_real64, szz0u=0.0_real64, szz0d=0.0_real64, sther=0.0_real64, &
                       salbn=0.0_real64, salbx=0.0_real64, salbm=0.0_real64, salbg=0.0_real64, salbb=0.0_real64, salbd=0.0_real64, &
                       semin=0.0_real64, semix=0.0_real64, semim=0.0_real64, semig=0.0_real64, semib=0.0_real64, semid=0.0_real64, &
                       sdepn=0.0_real64, sdepx=0.0_real64, sdepd=0.0_real64, sargn=0.0_real64, sargx=0.0_real64, sargd=0.0_real64, &
                        ssabn=0.0_real64, ssabx=0.0_real64, ssabd=0.0_real64, srsmx=0.0_real64, srsmn=0.0_real64, srsmd=0.0_real64 &
                                                          ), &
                                                          setup_complete=.false., last_stage=0_int32, status=0_int32)
  interface
    function copy_native_fresh_record(destination, source, bytes) bind(c, name='memcpy') result(address)
      import c_ptr, c_size_t
      type(c_ptr), value :: destination, source
      integer(c_size_t), value :: bytes
      type(c_ptr) :: address
    end function
  end interface
contains
  module procedure initialize_fresh_meteo_france_physics_state
  status = 2_int32
  if (allocated(state%top_atmosphere_parameters%rmesou)) return
  if (allocated(state%top_atmosphere_parameters%rmesot)) return
  if (allocated(state%top_atmosphere_parameters%rmesoq)) return
  if (allocated(state%alternative_parameters%xsw_bands)) return
  call copy_empty_native_representation(state)
  status = 0_int32
  end procedure

  !> Copy only the representation of the same compiler-native empty type.
  !! STATE is a stable INOUT TARGET whose four owners are already absent.
  !! The complete size comes from STORAGE_SIZE. The source is this module's
  !! own SAVE constructor, without original bytes, raw memset, private offsets
  !! or any live owner. No pointer to STATE escapes this procedure.
  subroutine copy_empty_native_representation(state)
    type(owned_meteo_france_physics_state), intent(inout), target :: state
    type(c_ptr) :: copied_address
    copied_address = copy_native_fresh_record(c_loc(state), c_loc(fresh_template), &
                                              storage_size(state, kind=c_size_t)/8_c_size_t)
  end subroutine
end submodule fresh_meteo_france_physics_state_implementation
