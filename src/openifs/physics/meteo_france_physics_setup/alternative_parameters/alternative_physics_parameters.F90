!> Initialize the selected alternative-physics parameters without model calls.
!! This port owns the complete selected SUPARAR body and its two raw stages.
!! Native fields replace the historical Arm byte layout; XSW_BANDS stays owned
!! by the caller. All coefficient stores retain their selected source bits.
!! The caller establishes nearest-even rounding and gradual underflow once.
!! This child preserves natural flags and makes no FP-mode refusal claim.
module alternative_physics_parameter_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_loc, c_intptr_t
  use yomparar, only: tparar
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: selected_alternative_physics_inputs, initialize_alternative_physics_parameters
  public :: set_alternative_parameter_literal_fields, set_alternative_parameter_arithmetic_fields

  !> Readonly named controls supplied by their existing native owners.
  !! LMSE and LMPA must be false. Radiation and hail flags use canonical
  !! logical values. NUNDEFLD is any int32 missing-field sentinel.
  !! LSFORCS is retained as input provenance but is not read on this route.
  !! This bundle is an argument view and owns no model state.
  type :: selected_alternative_physics_inputs
    logical :: lmse = .false., lmpa = .false., lrayfm = .false., lrayfm15 = .false., hail_active = .false.
    integer(int32) :: nundefld = -99999999_int32
    logical :: lsforcs = .false.
  end type
  interface
    function public_log10(value) bind(c, name='log10') result(logarithm)
      import c_double
      real(c_double), value :: value
      real(c_double) :: logarithm
    end function
  end interface
contains
  !> Write the selected source fields after all input checks succeed.
  !! TEXT is readonly TARGET character data of 1:262144 bytes, containing
  !! the first uppercase empty NAMPARAR group in byte columns one through ten.
  !! OUTPUT is caller-owned YOMPARAR::TPARAR INOUT TARGET. INPUTS is a readonly
  !! TARGET selected_alternative_physics_inputs record. OUTPUT is separate
  !! from both inputs. Valid native records and full floating controls are
  !! caller obligations. No allocation, release or whole-record copy occurs.
  !! Return zero after success or two before mutation. Source-unwritten
  !! fields, XSW_BANDS, padding and readonly bytes remain unchanged.
  !! RCRIAUTI/RCRIAUTC use kg/kg, time parameters use seconds, mixing lengths
  !! and cloud radii use metres, and GQVPLIM uses pascals. Remaining empirical
  !! coefficients keep their native declared units and source conventions.
  !! The public C LOG10 call keeps natural FP flags and incoming errno.
  integer(int32) function initialize_alternative_physics_parameters(text, output, inputs) result(status)
    character(len=*), intent(in), target :: text
    type(tparar), intent(inout), target :: output
    type(selected_alternative_physics_inputs), intent(in), target :: inputs
    integer(c_intptr_t) :: address
    integer(int64) :: bytes
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    address = transfer(c_loc(output), 0_c_intptr_t)
    bytes = storage_size(output, kind=int64)/8_int64
    if (.not. disjoint(address, bytes, transfer(c_loc(text(1:1)), 0_c_intptr_t), &
                       int(len(text), int64))) return
    if (.not. disjoint(address, bytes, transfer(c_loc(inputs), 0_c_intptr_t), &
                       storage_size(inputs, kind=int64)/8_int64)) return
    if (transfer(inputs%lmse, 0_int32) /= 0_int32) return
    if (transfer(inputs%lmpa, 0_int32) /= 0_int32) return
    if (.not. canonical_logical(inputs%lrayfm)) return
    if (.not. canonical_logical(inputs%lrayfm15)) return
    if (.not. canonical_logical(inputs%hail_active)) return
    if (require_empty_physics_group(text, 'NAMPARAR') /= 0_int32) return
    call set_alternative_parameter_literal_fields(output)
    call set_alternative_parameter_arithmetic_fields(output, inputs)
    status = 0_int32
  end function

  !> Store the complete selected literal stage through native scalar fields.
  !! OUTPUT is INOUT native TPARAR with valid unchanged XSW_BANDS ownership.
  !! The caller has checked the parent contract. String stores include all
  !! trailing blanks. Exact FP64 words include source real32-to-real64
  !! widening; no runtime arithmetic or rounding replaces these literal bits.
  subroutine set_alternative_parameter_literal_fields(output)
    type(tparar), intent(inout) :: output
    output%csedim = 'STAT'
    output%rcriauti = transfer(int(z'3ef4f8b580000000', int64), 0.0_real64)
    output%rcriautc = transfer(int(z'3f40624de0000000', int64), 0.0_real64)
    output%lcriauti = .false.
    output%xtstep_ts = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xmrstep = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%nmaxiter_micro = 5_int32
    output%lfprec3d = .false.
    output%cmicro = 'OLD3'
    output%nrr = 7_int32
    output%nrrl = 2_int32
    output%nrri = 4_int32
    output%cmicro = 'OLD4'
    output%nrr = 6_int32
    output%nrrl = 2_int32
    output%nrri = 3_int32
    output%losubg_cond = .false.
    output%vsigqsat = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%losigmas = .false.
    output%losedic = .false.
    output%nswb_mnh = 6_int32
    output%lsquall = .false.
    output%nrefroi1 = 1_int32
    output%nrefroi2 = 1_int32
    output%vsquall = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%nptp = 1_int32
    output%ldiagwmax = .false.
    output%ndiagwmax = 1_int32
    output%lowarm = .true.
    output%lolsmc = .false.
    output%lotownc = .false.
    output%locnd2 = .false.
    output%lgrsn = .false.
    output%radgr = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%radsn = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%cmf_updraft = 'EDKF'
    output%cmf_cloud = 'DIRE'
    output%lmixuv = .true.
    output%llcrit = .false.
    output%ltotprec = .false.
    output%xalp_pert = transfer(int(z'3fd3333333333333', int64), 0.0_real64)
    output%xabuo = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%xbentr = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%xbdetr = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xcmf = transfer(int(z'3fb0a3d70a3d70a4', int64), 0.0_real64)
    output%xentr_mf = transfer(int(z'3fa1eb851eb851ec', int64), 0.0_real64)
    output%xcrad_mf = transfer(int(z'4049000000000000', int64), 0.0_real64)
    output%xentr_dry = transfer(int(z'3fe199999999999a', int64), 0.0_real64)
    output%xdetr_dry = transfer(int(z'4024000000000000', int64), 0.0_real64)
    output%xdetr_lup = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%xkcf_mf = transfer(int(z'4006000000000000', int64), 0.0_real64)
    output%xkrc_mf = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%xtausigmf = transfer(int(z'4082c00000000000', int64), 0.0_real64)
    output%xpres_uv = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    output%xfrac_up_max = transfer(int(z'3fd51eb851eb851f', int64), 0.0_real64)
    output%xalpha_mf = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%xsigma_mf = transfer(int(z'4034000000000000', int64), 0.0_real64)
    output%xb = transfer(int(z'3f60624dd2f1a9fc', int64), 0.0_real64)
    output%xc = transfer(int(z'3f889374bc6a7efa', int64), 0.0_real64)
    output%xbeta1 = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    output%xr = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%xlambda = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%lthetas = .false.
    output%ndtchem = 1_int32
    output%larobu_enable = .false.
    output%csubg_aucv_rc = 'PDF '
    output%csubg_rc_rr_accr = 'NONE                                                                            '
    output%csubg_rr_evap = 'NONE                                                                            '
    output%csubg_pr_pdf = 'SIGM                                                                            '
    output%csnowriming = 'M90 '
    output%xfracm90 = transfer(int(z'3fb99999a0000000', int64), 0.0_real64)
    output%lfeedbackt = .true.
    output%levlimit = .true.
    output%lnullwetg = .true.
    output%lwetgpost = .true.
    output%lnullweth = .true.
    output%lwethpost = .true.
    output%lconvhg = .true.
    output%lcrflimit = .true.
    output%cfrac_ice_adjust = 'T'
    output%cfrac_ice_shallow_mf = 'T'
    output%lsedim_after = .false.
    output%xsplit_maxcfl = transfer(int(z'3fe99999a0000000', int64), 0.0_real64)
    output%xlini = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%lharatu = .false.
    output%xcqvr = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gqvplim = transfer(int(z'40c3880000000000', int64), 0.0_real64)
    output%gqvtop = transfer(int(z'3ecf75104d551d69', int64), 0.0_real64)
    output%lqvtop = .false.
    output%nprintfr = 129600_int32

  end subroutine

  !> Complete ordered arithmetic and source input-dependent integer stores.
  !! OUTPUT and INPUTS satisfy the checked parent contract and do not overlap.
  !! The literal stage has already set the positive RCRIAUTI threshold.
  !! Call public C LOG10, add 3.5, then divide by widened-real32 0.06.
  !! The two-thirds division remains a live FP64 operation. Hail and radiation
  !! branches set species/band counts; nineteen indices copy NUNDEFLD.
  subroutine set_alternative_parameter_arithmetic_fields(output, inputs)
    type(tparar), intent(inout) :: output
    type(selected_alternative_physics_inputs), intent(in) :: inputs
    real(real64) :: temperature
    real(real64), volatile :: two, three
    temperature = public_log10(output%rcriauti)
    temperature = temperature + 3.5_real64
    temperature = temperature/transfer(int(z'3faeb851e0000000', int64), 0.0_real64)
    output%rt0criauti = temperature
    two = 2.0_real64
    three = 3.0_real64
    output%xa1 = two/three
    if (inputs%hail_active) then
      output%nrr = 7_int32
      output%nrri = 4_int32
      output%cmicro = 'OLD4'
    else
      output%nrr = 6_int32
      output%nrri = 3_int32
      output%cmicro = 'OLD3'
    end if
    output%nswb_mnh = 1_int32
    if (inputs%lrayfm .or. inputs%lrayfm15) output%nswb_mnh = 6_int32
    output%ngpar = 0_int32
    output%minprr = inputs%nundefld
    output%macprr = inputs%nundefld
    output%minprs = inputs%nundefld
    output%macprs = inputs%nundefld
    output%minprg = inputs%nundefld
    output%macprg = inputs%nundefld
    output%malbdir = inputs%nundefld
    output%malbsca = inputs%nundefld
    output%mvts = inputs%nundefld
    output%mvemis = inputs%nundefld
    output%mswdir = inputs%nundefld
    output%mswdif = inputs%nundefld
    output%mrain = inputs%nundefld
    output%msnow = inputs%nundefld
    output%mvqs = inputs%nundefld
    output%mlsm = inputs%nundefld
    output%mgz0 = inputs%nundefld
    output%mgz0h = inputs%nundefld
    output%mcd = inputs%nundefld
  end subroutine

  pure logical function canonical_logical(value) result(canonical)
    logical, intent(in) :: value
    integer(int32) :: bits
    bits = transfer(value, 0_int32)
    canonical = bits == 0_int32 .or. bits == 1_int32
  end function

  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

end module alternative_physics_parameter_setup_port
