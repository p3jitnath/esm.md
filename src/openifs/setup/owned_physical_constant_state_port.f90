module owned_physical_constant_state_port
  !! Own the forecast constants and publish read-only compatibility names.
  !! The first512 record bytes are64 named FP64 values. Two int32 words
  !! hold the initialized flag and reserved storage. Units and equations
  !! are those of the unchanged physical_constant_setup_port constructor.
  !! Call publication once on the startup owner before starting consumers.
  !! Native module clients cannot change protected values. C data clients
  !! must also treat all exported names as read-only after publication.
  use, intrinsic :: iso_c_binding, only: c_double,c_int
  use physical_constant_setup_port, only: forecast_physical_constants, &
    initialize_physical_constants
  implicit none
  private
  public :: publish_owned_physical_constants,owned_physical_constants_ready
  type(forecast_physical_constants), public, protected, save, &
    bind(c,name="md2asm_owned_initial_physical_constants") :: physical_constants
  ! Compatibility names are compiler-owned copies of named record fields.
  ! Standard Fortran does not give a second C name to a record component.
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rpi") :: rpi=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rclum") :: rclum=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rhpla") :: rhpla=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rkbol") :: rkbol=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rnavo") :: rnavo=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rday") :: rday=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rdayi") :: rdayi=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rhour") :: rhour=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rea") :: rea=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_repsm") :: repsm=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rsiyea") :: rsiyea=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rsiday") :: rsiday=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_romega") :: romega=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_ra") :: ra=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rg") :: rg=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_r1sa") :: r1sa=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_deg2rad") :: deg2rad=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rsigma") :: rsigma=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_ri0") :: ri0=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_r") :: r=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmd") :: rmd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmv") :: rmv=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmo3") :: rmo3=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rd") :: rd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rv") :: rv=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rcpd") :: rcpd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rcpv") :: rcpv=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rcvd") :: rcvd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rcvv") :: rcvv=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rkappa") :: rkappa=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_retv") :: retv=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmco2") :: rmco2=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmch4") :: rmch4=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmn2o") :: rmn2o=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmco") :: rmco=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmhcho") :: rmhcho=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmno2") :: rmno2=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmso2") :: rmso2=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmso4") :: rmso4=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmcfc11") :: rmcfc11=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmcfc12") :: rmcfc12=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmhcfc22") :: rmhcfc22=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rmccl4") :: rmccl4=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rcw") :: rcw=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rcs") :: rcs=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_ratm") :: ratm=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rtt") :: rtt=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rlvtt") :: rlvtt=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rlstt") :: rlstt=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rlvzer") :: rlvzer=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rlszer") :: rlszer=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rlmlt") :: rlmlt=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rdt") :: rdt=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_restt") :: restt=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rgamw") :: rgamw=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rbetw") :: rbetw=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_ralpw") :: ralpw=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rgams") :: rgams=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rbets") :: rbets=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_ralps") :: ralps=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_ralpd") :: ralpd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rbetd") :: rbetd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rgamd") :: rgamd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yomcst_MOD_rsnan") :: rsnan=0.0_c_double
  integer(c_int), public, protected, save, &
    bind(c,name="__yomcst_MOD_l_has_been_setup") :: l_has_been_setup=0_c_int
  logical, save :: published=.false.
contains
  function publish_owned_physical_constants() &
      bind(c,name="md2asm_publish_owned_physical_constants_fortran") result(status)
    !! Build and publish one native immutable constant set.
    !! No input arrays are required. Return0 after publication or when
    !! already published. Propagate any constructor status before stores.
    !! The owned reserved int32 starts at0. The constructor preserves it.
    !! A repeat call performs no numerical work and changes no stored byte.
    integer(c_int) :: status
    type(forecast_physical_constants) :: staged
    if (published) then
      status=0_c_int
      return
    end if
    staged%reserved=0_c_int
    status=initialize_physical_constants(staged)
    if (status/=0_c_int) return
    physical_constants=staged
    rpi=staged%rpi
    rclum=staged%rclum
    rhpla=staged%rhpla
    rkbol=staged%rkbol
    rnavo=staged%rnavo
    rday=staged%rday
    rdayi=staged%rdayi
    rhour=staged%rhour
    rea=staged%rea
    repsm=staged%repsm
    rsiyea=staged%rsiyea
    rsiday=staged%rsiday
    romega=staged%romega
    ra=staged%ra
    rg=staged%rg
    r1sa=staged%r1sa
    deg2rad=staged%deg2rad
    rsigma=staged%rsigma
    ri0=staged%ri0
    r=staged%r
    rmd=staged%rmd
    rmv=staged%rmv
    rmo3=staged%rmo3
    rd=staged%rd
    rv=staged%rv
    rcpd=staged%rcpd
    rcpv=staged%rcpv
    rcvd=staged%rcvd
    rcvv=staged%rcvv
    rkappa=staged%rkappa
    retv=staged%retv
    rmco2=staged%rmco2
    rmch4=staged%rmch4
    rmn2o=staged%rmn2o
    rmco=staged%rmco
    rmhcho=staged%rmhcho
    rmno2=staged%rmno2
    rmso2=staged%rmso2
    rmso4=staged%rmso4
    rmcfc11=staged%rmcfc11
    rmcfc12=staged%rmcfc12
    rmhcfc22=staged%rmhcfc22
    rmccl4=staged%rmccl4
    rcw=staged%rcw
    rcs=staged%rcs
    ratm=staged%ratm
    rtt=staged%rtt
    rlvtt=staged%rlvtt
    rlstt=staged%rlstt
    rlvzer=staged%rlvzer
    rlszer=staged%rlszer
    rlmlt=staged%rlmlt
    rdt=staged%rdt
    restt=staged%restt
    rgamw=staged%rgamw
    rbetw=staged%rbetw
    ralpw=staged%ralpw
    rgams=staged%rgams
    rbets=staged%rbets
    ralps=staged%ralps
    ralpd=staged%ralpd
    rbetd=staged%rbetd
    rgamd=staged%rgamd
    rsnan=staged%rsnan
    l_has_been_setup=staged%initialized
    published=.true.
  end function

  pure function owned_physical_constants_ready() result(ready)
    !! Report whether the serial startup owner finished publication.
    logical :: ready
    ready=published
  end function
end module owned_physical_constant_state_port
