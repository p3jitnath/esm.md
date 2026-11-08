!> Establish fresh native non-radiation ECMWF parameter records.
!! Use this separate support stage on a fresh outer state before SUPHEC.
!! Its separately constructed radiation context may already be live.
!! These zero-born field preimages are not initialized physics parameters.
!! Each private SAVE/TARGET template uses a fully named intrinsic native
!! constructor. Its absent owners and static representation are compiler
!! generated. No original method, byte offset or whole-state copy is used.
module forecast_fresh_ecmwf_parameter_state
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_ptr, c_loc, c_size_t
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use yoecld, only: tecld
  use yoecnd, only: tecnd
  use yoecumf, only: tecumf
  use yoecumf2, only: tecumf2
  use yomcumfs, only: tcumfs
  use convection_parameter_fields_mod, only: convection_thermal_parameter_record
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
  use yoevdf, only: tvdf
  use ecmwf_physics_tail_fields_mod, only: methane_oxidation_parameter_record
  implicit none
  private
  public :: initialize_fresh_ecmwf_parameter_records
  interface
    function copy_native_bytes(destination, source, bytes) bind(c, name='memcpy') result(address)
      import c_ptr, c_size_t
      type(c_ptr), value :: destination, source
      integer(c_size_t), value :: bytes
      type(c_ptr) :: address
    end function
  end interface

  type(tecld), save, target :: fresh_cloud = tecld( &
                               ceta=null(), &
                               ranva=0.0_real64, &
                               ranvb=0.0_real64, &
                               ranvh=0.0_real64, &
                               rcca=0.0_real64, &
                               rccb=0.0_real64, &
                               rccc=0.0_real64, &
                               rcfct=0.0_real64, &
                               rclwmr=0.0_real64, &
                               rcscal=0.0_real64, &
                               rdecorr_cf=0.0_real64, &
                               rdecorr_cw=0.0_real64, &
                               retahb=0.0_real64, &
                               retamb=0.0_real64, &
                               rloia=0.0_real64, &
                               rloib=0.0_real64, &
                               rloic=0.0_real64, &
                               rloid=0.0_real64, &
                               rlonia=0.0_real64, &
                               rlonib=0.0_real64, &
                               rrhh=0.0_real64, &
                               rrhl=0.0_real64, &
                               rgammas=0.0_real64, &
                               repscr=0.0_real64, &
                               repsec=0.0_real64, &
                               lomega=.false.)

  type(tecnd), save, target :: fresh_condensation = tecnd( &
                               repflm=0.0_real64, &
                               repqmi=0.0_real64)

  type(tecumf), save, target :: fresh_convection = tecumf( &
                                entrorg=0.0_real64, &
                                entshalp=0.0_real64, &
                                entstpc1=0.0_real64, &
                                entstpc2=0.0_real64, &
                                entstpc3=0.0_real64, &
                                entrdd=0.0_real64, &
                                detrpen=0.0_real64, &
                                rmfcfl=0.0_real64, &
                                rmflia=0.0_real64, &
                                rmfsoluv=0.0_real64, &
                                rmfsoltq=0.0_real64, &
                                rmfsolct=0.0_real64, &
                                rmfsolrhs=0.0_real64, &
                                rmfadvw=0.0_real64, &
                                rmfadvwdd=0.0_real64, &
                                rmfcmin=0.0_real64, &
                                rmfdeps=0.0_real64, &
                                rdepths=0.0_real64, &
                                rprcon=0.0_real64, &
                                rtaua=0.0_real64, &
                                rcapdcycl=0.0_real64, &
                                rcapqadv=0.0_real64, &
                                rmincape=0.0_real64, &
                                rcpecons=0.0_real64, &
                                rcvrfactor=0.0_real64, &
                                rcucov=0.0_real64, &
                                rtaumel=0.0_real64, &
                                rhebc=0.0_real64, &
                                ruvper=0.0_real64, &
                                rbase0=0.0_real64, &
                                rmincin=0.0_real64, &
                                lmfpen=.false., &
                                lmfscv=.false., &
                                lmfmid=.false., &
                                lmfdd=.false., &
                                lmfdudv=.false., &
                                lmfdsnow=.false., &
                                lmfwetb=.false., &
                                lmfglac=.false., &
                                lscvliq=.false., &
                                lmfenthcons=.false., &
                                lmfuvdis=.false., &
                                lmfsmooth=.false., &
                                lmfwstar=.false., &
                                lmfcuca=.false., &
                                lmfprofp=.false., &
                                njkt1=0_int32, &
                                njkt2=0_int32, &
                                njkt3=0_int32, &
                                njkt4=0_int32, &
                                njkt5=0_int32, &
                                njkt6=0_int32, &
                                njkt7=0_int32, &
                                njkt8=0_int32)

  type(tecumf2), save, target :: fresh_linearized_convection = tecumf2( &
                                 entrorg2=0.0_real64, &
                                 detrpen2=0.0_real64, &
                                 entshalp2=0.0_real64, &
                                 entstpc12=0.0_real64, &
                                 entstpc22=0.0_real64, &
                                 entstpc32=0.0_real64, &
                                 entrdd2=0.0_real64, &
                                 rmfcmin2=0.0_real64, &
                                 rmfdeps2=0.0_real64, &
                                 rdepths2=0.0_real64, &
                                 rprcon2=0.0_real64, &
                                 rtau2=0.0_real64, &
                                 rcpecons2=0.0_real64, &
                                 rcucov2=0.0_real64, &
                                 rtaumel2=0.0_real64, &
                                 ruvper2=0.0_real64, &
                                 rmfsolct2=0.0_real64, &
                                 rmfsoltq2=0.0_real64, &
                                 rmfsoluv2=0.0_real64, &
                                 rmfsolrhs2=0.0_real64, &
                                 rmfcfl2=0.0_real64, &
                                 rmflia2=0.0_real64, &
                                 rcapdcycl2=0.0_real64, &
                                 rtau02=0.0_real64, &
                                 lmfmid2=.false., &
                                 lmfdd2=.false., &
                                 lmfdudv2=.false., &
                                 lmfuvdis2=.false., &
                                 lmfwetb2=.false., &
                                 lmfglac2=.false., &
                                 njkt12=0_int32, &
                                 njkt22=0_int32, &
                                 njkt32=0_int32, &
                                 njkt52=0_int32, &
                                 njkt62=0_int32)

  type(tcumfs), save, target :: fresh_convection_switches = tcumfs( &
                                lecumfs=.false., &
                                lregcv=.false., &
                                lmfcfl2_shstep=.false.)

  type(convection_thermal_parameter_record), save, target :: fresh_convection_thermal = convection_thermal_parameter_record( &
                                                             rtwat=0.0_real64, &
                                                             rticecu=0.0_real64, &
                                                             rtwat_rticecu_r=0.0_real64)

  type(tegwd), save, target :: fresh_orographic_gravity_wave = tegwd( &
                               nktopg=0_int32, &
                               ngwdlim=0_int32, &
                               ngwdtop=0_int32, &
                               ndiff_strato=0_int32, &
                               gfrcrit=0.0_real64, &
                               grcrit=0.0_real64, &
                               gkdrag=0.0_real64, &
                               gkwake=0.0_real64, &
                               gssec=0.0_real64, &
                               gtsec=0.0_real64, &
                               gvsec=0.0_real64, &
                               gtenlim=0.0_real64, &
                               grfplm=0.0_real64, &
                               lrdiff_strato=.false., &
                               ldiag_strato=.false.)

  type(tegwwms), save, target :: fresh_nonorographic_gravity_wave = tegwwms( &
                                 lozpr=.false., &
                                 lgacalc=.false., &
                                 lgsatl=.false., &
                                 lgindl=.false., &
                                 nlaunchl=[0_int32, 0_int32, 0_int32], &
                                 nlaunchlev=0_int32, &
                                 nlaunch=0_int32, &
                                 nslope=0_int32, &
                                 ngauss=0_int32, &
                                 gfluxlaunl=[0.0_real64, 0.0_real64, 0.0_real64], &
                                 gfluxlaun=0.0_real64, &
                                 gmstar_l=[0.0_real64, 0.0_real64, 0.0_real64], &
                                 gcstar=0.0_real64, &
                                 gptwo=0.0_real64, &
                                 gtphygwwms=0.0_real64, &
                                 ggaussa=0.0_real64, &
                                 ggaussb=[0.0_real64, 0.0_real64, 0.0_real64], &
                                 gcoeff=0.0_real64)

  type(tvdf), save, target :: fresh_diffusion = tvdf( &
                              rlam=0.0_real64, &
                              rvdifts=0.0_real64, &
                              lwds=.false., &
                              reps1wds=0.0_real64, &
                              reps2wds=0.0_real64, &
                              retawds=0.0_real64, &
                              rtofdalpha=0.0_real64, &
                              reisthsc=0.0_real64, &
                              nsubst=0_int32)

  type(methane_oxidation_parameter_record), save, target :: fresh_methane = methane_oxidation_parameter_record( &
                                                            ralpha1=0.0_real64, &
                                                            ralpha2=0.0_real64, &
                                                            rqlim=0.0_real64, &
                                                            rpbotox=0.0_real64, &
                                                            rpbotph=0.0_real64, &
                                                            rptopox=0.0_real64, &
                                                            rptopph=0.0_real64, &
                                                            ralpha3=0.0_real64, &
                                                            rlogpph=0.0_real64)

contains
  !> Initialize only ten fresh native components in their existing owner.
  !! STATE is native_ecmwf_physics_state INOUT TARGET owned by the caller.
  !! CETA must be absent and SURFACE disassociated. All acquisition, setup
  !! and attempt flags must be false; LAST_STAGE and LAST_STATUS must be zero.
  !! The caller supplies valid fresh native records. A prior SUPHEC attempt
  !! is refused even when its resources have been released.
  !! Scalar and fixed-array fields have zero-born values in their declared
  !! units. Physics children later produce the physical parameter values.
  !! Public memcpy copies complete objects of the same native type after
  !! all checks. This preserves compiler-produced empty metadata and never
  !! copies a live descriptor, allocates or releases storage.
  !! RADIATION and every outer metadata member remain unchanged. The caller
  !! establishes floating controls; this stage performs no FP arithmetic.
  !! Return zero on success or two before any public mutation.
  integer(int32) function initialize_fresh_ecmwf_parameter_records(state) result(status)
    type(native_ecmwf_physics_state), intent(inout), target :: state
    type(c_ptr) :: copied_address
    status = 2_int32
    if (allocated(state%cloud%ceta)) return
    if (associated(state%surface)) return
    if (state%cloud_eta_acquired .or. state%optimization_acquired .or. &
        state%radiation_attempted .or. state%surface_acquired .or. state%setup_complete) return
    if (state%last_stage /= 0_int32 .or. state%last_status /= 0_int32) return
    copied_address = copy_native_bytes(c_loc(state%cloud), c_loc(fresh_cloud), &
                                       storage_size(fresh_cloud, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%condensation), c_loc(fresh_condensation), &
                                       storage_size(fresh_condensation, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%convection), c_loc(fresh_convection), &
                                       storage_size(fresh_convection, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%linearized_convection), c_loc(fresh_linearized_convection), &
                                       storage_size(fresh_linearized_convection, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%convection_switches), c_loc(fresh_convection_switches), &
                                       storage_size(fresh_convection_switches, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%convection_thermal), c_loc(fresh_convection_thermal), &
                                       storage_size(fresh_convection_thermal, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%orographic_gravity_wave), c_loc(fresh_orographic_gravity_wave), &
                                       storage_size(fresh_orographic_gravity_wave, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%nonorographic_gravity_wave), c_loc(fresh_nonorographic_gravity_wave), &
                                       storage_size(fresh_nonorographic_gravity_wave, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%diffusion), c_loc(fresh_diffusion), &
                                       storage_size(fresh_diffusion, kind=c_size_t)/8_c_size_t)
    copied_address = copy_native_bytes(c_loc(state%methane), c_loc(fresh_methane), &
                                       storage_size(fresh_methane, kind=c_size_t)/8_c_size_t)
    status = 0_int32
  end function
end module forecast_fresh_ecmwf_parameter_state
