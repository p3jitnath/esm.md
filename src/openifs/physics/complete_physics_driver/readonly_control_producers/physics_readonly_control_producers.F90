! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Produce actual chemistry and cellular control values for the selected driver.
!! These are named native controls, without chemistry or cellular payload owners.
!! The caller supplies genuine initialized field metadata, dynamics and geometry.
!! The caller establishes nearest-even rounding and gradual underflow once.
module forecast_physics_readonly_control_producers
  use iso_fortran_env, only: int32, int64, real32, real64
  use grid_field_configuration_types_port, only: grid_field_configuration
  use yomdyna, only: tdyna
  implicit none
  private
  public :: native_physics_readonly_controls
  public :: initialize_no_chemistry_controls, initialize_cellular_controls
  public :: borrow_physics_readonly_controls
  !> Own every named control written by the NCHEM<=0 NAMCHEM branch.
  !! The remaining TCHEM fields and all active chemistry stages are outside this
  !! record. No type default supplies a scientific control value.
  type, public :: native_no_chemistry_controls
    integer(int32) :: kchem_drydep, kchem_noxadv, kchem_wetdep, kchem_solve, kchem_yearpi
    real(real64) :: rchem_linox_scaling, rch4const
    logical :: lchem_light, lchem_diac, lchem_jout, lchem_bascoe_jon
    logical :: lchem_bascoe_hetchem, lmozart_rsf_dummy, lchem_extendjno2, lchem_stma
    logical :: lchem_anao3, lchem_anach4, lchem_weak_ch4_relaxation, lchem_0nox, lchem_htap
    logical :: lchem_convscav, lchem_cshape, lchem_wdfr, lchem_o3rad, lchem_aeroi
    logical :: lchem_tl, lchem_revchem, lchem_arpclim
  end type
  !> Own the complete NAMCA scalar controls, including native owned NIJH.
  !! RCADELX is a length in metres. RCA_SEEDPROB is dimensionless.
  !! LCA_NBDEBUG has no original default. The caller must set its valid logical
  !! preimage before initialization; an absent namelist assignment preserves it.
  !! This record does not own CA grids, random streams or probability arrays.
  type, public :: native_cellular_readonly_controls
    integer(int32) :: nijh, nfrcaseed, nlives, nfertyrs, ntestproc, ntestgp
    integer(int32) :: ndxunreal, ndyunreal, nspinup
    real(real64) :: rca_seedprob, rcadelx
    logical :: lcuconv_ca, lca_advect, lca_global, lca_smooth, lca_test
    logical :: lca_rantrop, lca_advtest, lca_extract, lca_nbdebug
    character(len=10) :: ca_forc, ca_wind, ca_prob
  end type
  !> Keep produced control values alive while their readonly views are borrowed.
  !! Ready markers describe only native lifecycle. They are not source flags.
  type :: native_physics_readonly_controls
    type(native_no_chemistry_controls) :: chemistry
    type(native_cellular_readonly_controls) :: cellular
    logical :: chemistry_ready = .false., cellular_ready = .false.
  end type
contains
  !> Run the complete no-chemistry control branch in original store order.
  !! GFL is the actual canonical namespace after its initializer succeeded.
  !! It is readonly; alias_controls%nchem is its genuine chemistry count.
  !! Status0 produces controls;2 refuses NCHEM/=0 without changing OUTPUT.
  !! NAMCHEM is not read on this source branch. No lightning value is guessed.
  integer(int32) function initialize_no_chemistry_controls(output, gfl) result(status)
    type(native_physics_readonly_controls), intent(inout) :: output
    type(grid_field_configuration), intent(in) :: gfl
    status = 2_int32
    if (gfl%alias_controls%nchem /= 0_int32) return
    output%chemistry%kchem_drydep = 0_int32
    output%chemistry%lchem_light = .false.
    output%chemistry%rchem_linox_scaling = 0.0_real64
    output%chemistry%lchem_diac = .false.
    output%chemistry%lchem_jout = .false.
    output%chemistry%lchem_bascoe_jon = .false.
    output%chemistry%lchem_bascoe_hetchem = .true.
    output%chemistry%lmozart_rsf_dummy = .false.
    output%chemistry%lchem_extendjno2 = .false.
    output%chemistry%kchem_noxadv = 0_int32
    output%chemistry%kchem_wetdep = 1_int32
    output%chemistry%lchem_stma = .false.
    output%chemistry%lchem_anao3 = .false.
    output%chemistry%lchem_anach4 = .false.
    output%chemistry%lchem_weak_ch4_relaxation = .false.
    output%chemistry%lchem_0nox = .false.
    output%chemistry%lchem_htap = .false.
    output%chemistry%lchem_convscav = .false.
    output%chemistry%lchem_cshape = .false.
    output%chemistry%lchem_wdfr = .false.
    output%chemistry%lchem_o3rad = .false.
    output%chemistry%lchem_aeroi = .false.
    output%chemistry%lchem_tl = .false.
    output%chemistry%kchem_solve = 0_int32
    output%chemistry%lchem_revchem = .false.
    output%chemistry%kchem_yearpi = 2000_int32
    output%chemistry%rch4const = -9999.9_real64
    output%chemistry%lchem_arpclim = .false.
    output%chemistry_ready = .true.
    status = 0_int32
  end function

  !> Produce all NAMCA controls and the final LSLAG-dependent active switch.
  !! RECORDS are actual namelist input records containing a complete NAMCA
  !! group. Their total storage is1..262144 bytes; they remain readonly.
  !! ECMWF is the genuine LECMWF configuration value. DYNAMICS is the actual
  !! TDYNA owner. NOMINAL_GRID_SPACING is actual geometry RDELXN in metres.
  !! RDELXN is finite and nonnegative; RCADELX must be finite. The source NINT
  !! result must fit int32. OUTPUT retains its incoming LCA_NBDEBUG preimage
  !! when that member is absent from NAMCA. All other source defaults run.
  !! Status0 produces controls, including a genuinely requested active value.
  !! Status2 refuses unsupported metadata;3 reports native namelist failure.
  !! Refusals preserve OUTPUT. Active CA numerical initialization is a separate
  !! unported stage; this function does not admit that payload to CALLPAR.
  integer(int32) function initialize_cellular_controls(output, records, ecmwf, &
                                                       dynamics, nominal_grid_spacing) result(status)
    type(native_physics_readonly_controls), intent(inout) :: output
    character(len=*), intent(in) :: records(:)
    logical, intent(in) :: ecmwf
    type(tdyna), intent(in) :: dynamics
    real(real64), intent(in) :: nominal_grid_spacing
    integer(int32) :: nijh, nfrcaseed, nlives, nfertyrs, ntestproc, ntestgp
    integer(int32) :: ndxunreal, ndyunreal, nspinup
    real(real64) :: rca_seedprob, rcadelx, ratio
    logical :: lcuconv_ca, lca_advect, lca_global, lca_smooth, lca_test
    logical :: lca_rantrop, lca_advtest, lca_extract, lca_nbdebug
    character(len=10) :: ca_forc, ca_wind, ca_prob
    integer :: ios
    namelist /namca/ lcuconv_ca, lca_advect, lca_global, lca_smooth, lca_test, &
      ca_forc, ca_wind, ca_prob, nfrcaseed, nlives, nfertyrs, rca_seedprob, &
      ntestproc, ntestgp, ndxunreal, ndyunreal, nspinup, lca_rantrop, &
      lca_advtest, lca_extract, lca_nbdebug, rcadelx
    status = 2_int32
    if (.not. is_contiguous(records)) return
    if (len(records) < 1 .or. size(records, kind=int64) < 1_int64) return
    if (int(len(records), int64) > 262144_int64/size(records, kind=int64)) return
    if (.not. finite_word(nominal_grid_spacing)) return
    if (nominal_grid_spacing < 0.0_real64) return
    ! The original setup has no assignment to LCA_NBDEBUG before READ.
    lca_nbdebug = output%cellular%lca_nbdebug
    lcuconv_ca = .false.
    if (ecmwf) then
      lca_advect = .true.
    else
      lca_advect = .false.
    end if
    if (ecmwf) then
      nijh = 4_int32
    else
      nijh = 2_int32
    end if
    rcadelx = 0.0_real64
    lca_global = .false.
    lca_smooth = .true.
    lca_rantrop = .false.
    lca_extract = .false.
    ca_forc = 'CONV_TQ'
    ca_wind = 'REAL'
    ca_prob = 'WIND'
    if (ecmwf) then
      ! Original 0.995 is an unkinded real32 literal, then widened to real64.
      rca_seedprob = real(0.995_real32, real64)
    else
      rca_seedprob = real(0.75_real32, real64)
    end if
    nfrcaseed = 1_int32
    nlives = 10_int32
    nfertyrs = 3_int32
    lca_test = .false.
    lca_advtest = .false.
    ntestproc = 8_int32
    ntestgp = 1_int32
    ndxunreal = -1_int32
    ndyunreal = 0_int32
    nspinup = 1000_int32
    read (records, nml=namca, iostat=ios)
    if (ios /= 0) then
      status = 3_int32
      return
    end if
    if (.not. finite_word(rcadelx)) return
    if (rcadelx > 1.0_real64) then
      ratio = nominal_grid_spacing/rcadelx
      if (.not. finite_word(ratio)) return
      if (ratio >= 2147483647.5_real64) return
      nijh = max(1_int32, nint(ratio, int32))
    end if
    if (.not. dynamics%lslag) lcuconv_ca = .false.
    output%cellular%lcuconv_ca = lcuconv_ca
    output%cellular%lca_advect = lca_advect
    output%cellular%nijh = nijh
    output%cellular%rcadelx = rcadelx
    output%cellular%lca_global = lca_global
    output%cellular%lca_smooth = lca_smooth
    output%cellular%lca_rantrop = lca_rantrop
    output%cellular%lca_extract = lca_extract
    output%cellular%ca_forc = ca_forc
    output%cellular%ca_wind = ca_wind
    output%cellular%ca_prob = ca_prob
    output%cellular%rca_seedprob = rca_seedprob
    output%cellular%nfrcaseed = nfrcaseed
    output%cellular%nlives = nlives
    output%cellular%nfertyrs = nfertyrs
    output%cellular%lca_test = lca_test
    output%cellular%lca_advtest = lca_advtest
    output%cellular%ntestproc = ntestproc
    output%cellular%ntestgp = ntestgp
    output%cellular%ndxunreal = ndxunreal
    output%cellular%ndyunreal = ndyunreal
    output%cellular%nspinup = nspinup
    output%cellular%lca_nbdebug = lca_nbdebug
    output%cellular_ready = .true.
    status = 0_int32
  end function

  !> Borrow only values whose actual native initializers have completed.
  !! OUTPUT must be a persistent caller-owned TARGET. Keep it alive and do not
  !! reinitialize it until all borrowed views have finished. CHEM_LIGHT_ACTIVE
  !! aliases the genuine produced value. CELLULAR_ACTIVE copies its genuine
  !! produced switch into the existing native cellular readonly snapshot.
  !! Status0 publishes both;2 leaves both incoming views unchanged.
  integer(int32) function borrow_physics_readonly_controls(output, &
                                                           chem_light_active, cellular_active) result(status)
    type(native_physics_readonly_controls), target, intent(inout) :: output
    logical, pointer, intent(inout) :: chem_light_active
    logical, intent(inout) :: cellular_active
    status = 2_int32
    if (.not. output%chemistry_ready .or. .not. output%cellular_ready) return
    chem_light_active => output%chemistry%lchem_light
    cellular_active = output%cellular%lcuconv_ca
    status = 0_int32
  end function

  !> Read the binary64 exponent without evaluating an invalid floating value.
  pure logical function finite_word(value) result(finite)
    real(real64), intent(in) :: value
    integer(int64) :: bits
    bits = transfer(value, bits)
    finite = iand(shiftr(bits, 52), 2047_int64) /= 2047_int64
  end function
end module forecast_physics_readonly_control_producers
