!> Own the complete generated disabled startup controls with native records.
!! The selected and operational entries port SUTRAJP, SUNUD and SUMCC.
!! No original model module, constructor, finalizer or private byte layout is
!! a production dependency. The numerical stores come from the generated
!! assembly; original declarations are used only to name native interfaces.
module native_inactive_startup_controls
  use iso_fortran_env, only: int32, int64, real64
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_key_character, physics_fold_equal, parse_physics_boolean, physics_space
  implicit none
  private
  public :: native_nudging_controls, native_climate_coupling_controls
  public :: initialize_climate_declaration_defaults
  public :: initialize_selected_inactive_startup_controls
  public :: initialize_operational_inactive_startup_controls
  integer, parameter :: nudging_profile_capacity = 200

  !> Store a dormant native coupling field without original type methods.
  !! This route requires the containing field owner to be absent. ID holds
  !! native int32 identifiers; D is real64 data in the selected ocean kind.
  !! All arrays have caller-selected bounds if a later supported owner is
  !! implemented. This producer neither constructs nor reads such elements.
  type :: native_coupling_field
    integer(int32), allocatable :: id(:, :)
    character(len=128) :: name
    integer(int32) :: type, inout, stage, num_lvl, num_cat
    real(real64), allocatable :: d(:, :, :)
  end type

  !> Hold all named SUNUD outputs in native Fortran storage.
  !! Counts and indices are int32; switches are logical. XNUVERT has the
  !! source declaration capacity of 200 and dimensionless weights.
  !! The 15 real64 coefficients have the frozen source units.
  type :: native_nudging_controls
    integer(int32) :: nfnudg, nfrnudg, ntnudg, ntotfnudg3, ntotfnudg2, nspnu1, nspnu2
    logical :: lnudg,lnuddi,lnudlp,lnudrm,lnudsd,lnudsh,lnudsm,lnudst,lnudsv,lnudte,lnudvo,lndriv,lnudtg,lnudqg,lnudug,lnudvg,lnudpg,lwnudg
    real(real64) :: xnuvert(nudging_profile_capacity)
    real(real64) :: xnuddi,xnudlp,xnudrm,xnudsd,xnudsh,xnudsm,xnudst,xnudsv,xnudte,xnudvo,xnudtg,xnudqg,xnudug,xnudvg,xnudpg
  end type

  !> Hold the complete source-named TMCC state without a private Arm layout.
  !! Integer counters and links are int32; switches are native logical.
  !! Floating arrays and partial-coupling constants are real64. The original
  !! eleven calculation owners must be unallocated on entry and remain so.
  !! The two source composition-index tables use caller-sized native arrays
  !! because their live composition dimension belongs to their caller. This
  !! producer does not allocate, read or modify those retained tables.
  !! Every source-unwritten member retains its incoming value. Coupled ocean
  !! execution and live climate-array construction are outside this route.
  type :: native_climate_coupling_controls
    integer(kind=int32) :: n923
    integer(kind=int32) :: nclimtot
    integer(kind=int32) :: nclimr
    integer(kind=int32) :: ncligc(19)
    integer(int32), allocatable :: ncligc_compo(:)
    integer(int32), allocatable :: nysdmp_compo(:)
    integer(kind=int32) :: nclimr_compo
    integer(kind=int32) :: ncliaer(16)
    integer(kind=int32) :: ndifc
    integer(kind=int32) :: njdcr
    integer(kind=int32) :: njdcr1
    integer(kind=int32) :: ndifc_compo
    integer(kind=int32) :: njdcr_compo
    integer(kind=int32) :: njdcr1_compo
    integer(kind=int32) :: np1
    integer(kind=int32) :: np2
    integer(kind=int32) :: npco2_1, npco2_2
    integer(kind=int32) :: npaer_1, npaer_2
    integer(kind=int32) :: npcompo_1, npcompo_2
    integer(kind=int32) :: nunitc
    integer(kind=int32) :: nunitc1
    integer(kind=int32) :: nunitcm
    integer(kind=int32) :: noacomm
    integer(kind=int32) :: nssticeop
    real(kind=real64), allocatable :: climrco2(:, :, :), climraer(:, :, :), climrcompo(:, :, :), zlake(:, :, :), oceanbc(:, :)
    real(kind=real64), allocatable :: climr(:, :, :)
    logical :: lfirstupd
    logical :: lcurr
    logical :: lgelato
    logical :: lmcc01_mse
    logical :: lmcc01
    logical :: lmcc02
    logical :: lmcc03
    logical :: lmcc04
    logical :: lmcc05
    logical :: lmcc06
    logical :: lmccec
    logical :: lmcciec
    logical :: lmcciec_compo
    logical :: lmcciceic
    logical :: lmccdynseaice
    logical :: lnemocoup
    logical :: lnemofluxnc
    logical :: lnemooutgrb
    logical :: lcoupinfout
    logical :: lnemo1way
    logical :: lnemoifslog
    logical :: lnemosstfreez
    logical :: lnemogribflds
    logical :: lnemogribmask
    logical :: l2decv2nemo
    logical :: lmultiyr
    logical :: lmcc_compo
    integer(kind=int32) :: nfrcpl
    logical :: lnemolimget
    logical :: lnemolimput
    logical :: lnemolimalb
    logical :: lnemolimtemp
    logical :: lnemolimtlvl
    logical :: lnemolimthk
    logical :: lnemosicoup
    logical :: lnemoatmflds
    logical :: lnemooceicemix
    logical :: lnemoqnsicefilt
    logical :: lnemoaccumflux
    logical :: lnemogrib3d
    integer :: nnemo3dlevs
    real(kind=real64), allocatable :: rnemolvls(:)
    real(kind=real64), allocatable :: rnemomask(:, :)
    logical :: lnemopartcoup
    logical :: lnemopartmask
    logical :: lnemopartmaskfile
    real(kind=real64) :: rnpartrampstart
    real(kind=real64) :: rnpartramplen
    real(kind=real64) :: rnpartlat
    real(kind=real64) :: rnpartlatspread
    real(kind=real64), allocatable :: partsst0(:)
    real(kind=real64), allocatable :: partmask(:)
    character(len=128) :: cdnpartmaskfile
    type(native_coupling_field), allocatable, dimension(:) :: cplng_fld
    logical :: cplng_active
    integer(kind=int32) :: cplng_num_fields
    integer(kind=int32) :: ip_a_sst
    integer(kind=int32) :: ip_a_ice_frac
    integer(kind=int32) :: ip_a_curr_u
    integer(kind=int32) :: ip_a_curr_v
    integer(kind=int32) :: ip_a_taux_oce
    integer(kind=int32) :: ip_a_tauy_oce
    integer(kind=int32) :: ip_a_taux_ice
    integer(kind=int32) :: ip_a_tauy_ice
    integer(kind=int32) :: ip_a_qs_mix
    integer(kind=int32) :: ip_a_qns_mix
    integer(kind=int32) :: ip_a_qs_oce
    integer(kind=int32) :: ip_a_qns_oce
    integer(kind=int32) :: ip_a_qs_ice
    integer(kind=int32) :: ip_a_qns_ice
    integer(kind=int32) :: ip_a_precip_liquid
    integer(kind=int32) :: ip_a_precip_solid
    integer(kind=int32) :: ip_a_evap_total
    integer(kind=int32) :: ip_a_evap_ice
    integer(kind=int32) :: ip_a_dqns_dt
    integer(kind=int32) :: ip_a_runoff
    integer(kind=int32) :: ip_a_total_cc
    integer(kind=int32) :: ip_a_low_cc
    integer(kind=int32) :: ip_a_ice_temp
    integer(kind=int32) :: ip_a_ice_albedo
    integer(kind=int32) :: ip_a_ice_thickness
    integer(kind=int32) :: ip_a_snow_thickness
    integer(kind=int32) :: ip_a_ice_temp_lvls
    integer(kind=int32) :: ip_a_taux
    integer(kind=int32) :: ip_a_tauy
    integer(kind=int32) :: ip_a_qs
    integer(kind=int32) :: ip_a_qns
    integer(kind=int32) :: ip_a_water
    integer(kind=int32) :: ip_a_sst_atm
    integer(kind=int32) :: ip_a_tsk_atm
    integer(kind=int32) :: ip_a_ist_atm
    integer(kind=int32) :: ip_a_2decv_skt
    logical :: lcoupsim
  end type
contains
  !> Apply the complete selected SUNUD, SUMCC and SUTRAJP state.
  !! TEXT is read-only ASCII with 1:262144 bytes. NUDGING and CLIMATE are
  !! caller-owned INOUT records; all eleven CLIMATE calculation owners must
  !! be absent. NG3NH95 is an INOUT int32 trajectory count and becomes nine.
  !! NBITSEXPR is an INOUT int32 packing word whose incoming bits are retained.
  !! LMSE, LESICE and LR2D are read-only native logical controls from their
  !! canonical physics/forecast producers; NFRCO is a read-only int32 frequency.
  !! LR2D must be false. Selected NAMNUD and NAMMCC groups must be empty.
  !! Return 0 applies all stores; return 2 leaves both records/scalars intact.
  !! The caller establishes the primary floating-point environment. There is
  !! no floating arithmetic, allocation, original constructor or finalizer.
  integer(int32) function initialize_selected_inactive_startup_controls(text, nudging, climate, &
                                                                       ng3nh95, nbitsexpr, lmse, lesice, nfrco, lr2d) result(status)
    character(len=*), intent(in) :: text
    type(native_nudging_controls), intent(inout) :: nudging
    type(native_climate_coupling_controls), intent(inout) :: climate
    integer(int32), intent(inout) :: ng3nh95, nbitsexpr
    logical, intent(in) :: lmse, lesice, lr2d
    integer(int32), intent(in) :: nfrco
    integer(int32) :: child
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144 .or. lr2d) return
    child = require_empty_physics_group(text, 'NAMNUD')
    if (child /= 0_int32) return
    child = require_empty_physics_group(text, 'NAMMCC')
    if (child /= 0_int32) return
    child = initialize_climate_declaration_defaults(climate)
    if (child /= 0_int32) return
    ng3nh95 = 9_int32
    call apply_disabled_nudging(nudging)
    call apply_selected_coupling(climate)
    status = 0_int32
  end function

  !> Apply the operational route with a bounded two-key NAMMCC group.
  !! Arguments have the same types, ownership, units and mutations as the
  !! selected entry. NAMNUD remains empty. NAMMCC accepts LMCCEC/LMCCIEC only.
  !! Its first uppercase group controls the result; each final repeated key
  !! wins within that group. NFRCO replaces NFRCPL only when LMCCEC is true.
  !! All source resets after the group remain in source order, including
  !! false LMCCDYNSEAICE and LNEMO1WAY. NBITSEXPR retains every incoming bit.
  integer(int32) function initialize_operational_inactive_startup_controls(text, nudging, climate, &
                                                                       ng3nh95, nbitsexpr, lmse, lesice, nfrco, lr2d) result(status)
    character(len=*), intent(in) :: text
    type(native_nudging_controls), intent(inout) :: nudging
    type(native_climate_coupling_controls), intent(inout) :: climate
    integer(int32), intent(inout) :: ng3nh95, nbitsexpr
    logical, intent(in) :: lmse, lesice, lr2d
    integer(int32), intent(in) :: nfrco
    integer(int32) :: child
    logical :: parsed_lmccec, parsed_lmcciec
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144 .or. lr2d) return
    child = require_empty_physics_group(text, 'NAMNUD')
    if (child /= 0_int32) return
    child = read_operational_coupling_group(text, parsed_lmccec, parsed_lmcciec)
    if (child /= 0_int32) return
    child = initialize_climate_declaration_defaults(climate)
    if (child /= 0_int32) return
    ng3nh95 = 9_int32
    call apply_disabled_nudging(nudging)
    call apply_operational_coupling(climate, parsed_lmccec, parsed_lmcciec, nfrco)
    status = 0_int32
  end function

  !> Store all named disabled SUNUD outputs, preserving native padding.
  !! NUDGING is caller-owned INOUT. The 200-entry dimension is the frozen
  !! declaration capacity, not the number of active model levels. Each
  !! dimensionless vertical weight becomes one; coefficients become positive
  !! zero. No array is allocated or released.
  subroutine apply_disabled_nudging(nudging)
    type(native_nudging_controls), intent(inout) :: nudging
    nudging%nfnudg = 0_int32
    nudging%nfrnudg = 0_int32
    nudging%ntnudg = 0_int32
    nudging%ntotfnudg3 = 0_int32
    nudging%ntotfnudg2 = 0_int32
    nudging%nspnu1 = 0_int32
    nudging%nspnu2 = 0_int32
    nudging%lnudg = .false.
    nudging%lnuddi = .false.
    nudging%lnudlp = .false.
    nudging%lnudrm = .false.
    nudging%lnudsd = .false.
    nudging%lnudsh = .false.
    nudging%lnudsm = .false.
    nudging%lnudst = .false.
    nudging%lnudsv = .false.
    nudging%lnudte = .false.
    nudging%lnudvo = .false.
    nudging%lndriv = .false.
    nudging%lnudtg = .false.
    nudging%lnudqg = .false.
    nudging%lnudug = .false.
    nudging%lnudvg = .false.
    nudging%lnudpg = .false.
    nudging%lwnudg = .false.
    nudging%nfrnudg = 999_int32
    nudging%ntnudg = 1_int32
    nudging%nspnu1 = 998_int32
    nudging%nspnu2 = 999_int32
    nudging%xnuvert = 1.0_real64
    nudging%xnuddi = 0.0_real64
    nudging%xnudlp = 0.0_real64
    nudging%xnudrm = 0.0_real64
    nudging%xnudsd = 0.0_real64
    nudging%xnudsh = 0.0_real64
    nudging%xnudsm = 0.0_real64
    nudging%xnudst = 0.0_real64
    nudging%xnudsv = 0.0_real64
    nudging%xnudte = 0.0_real64
    nudging%xnudvo = 0.0_real64
    nudging%xnudtg = 0.0_real64
    nudging%xnudqg = 0.0_real64
    nudging%xnudug = 0.0_real64
    nudging%xnudvg = 0.0_real64
    nudging%xnudpg = 0.0_real64
  end subroutine

  !> Test the original eleven native calculation owners without mutation.
  logical function climate_owners_absent(climate) result(absent)
    type(native_climate_coupling_controls), intent(in) :: climate
    absent = .not. (allocated(climate%climrco2) .or. allocated(climate%climraer) .or. &
                    allocated(climate%climrcompo) .or. allocated(climate%zlake) .or. &
                    allocated(climate%oceanbc) .or. allocated(climate%climr) .or. &
                    allocated(climate%rnemolvls) .or. allocated(climate%rnemomask) .or. &
                    allocated(climate%partsst0) .or. allocated(climate%partmask) .or. &
                    allocated(climate%cplng_fld))
  end function

  !> Apply the 59 explicit TMCC declaration defaults without constructing owners.
  !! CLIMATE is caller-owned INOUT. Its eleven calculation owners must be
  !! absent; otherwise return 2 before mutation. Return 0 writes only named
  !! source defaults. Retained counters/tables, unused flags and native
  !! descriptor metadata remain unchanged. Latitudes are degrees; ramp
  !! intervals are days. This leaf allocates nothing and calls no original code.
  integer(int32) function initialize_climate_declaration_defaults(climate) result(status)
    type(native_climate_coupling_controls), intent(inout) :: climate
    status = 2_int32
    if (.not. climate_owners_absent(climate)) return
    climate%lfirstupd = .true.
    climate%lnemolimget = .true.
    climate%lnemolimput = .true.
    climate%lnemolimalb = .false.
    climate%lnemolimtemp = .false.
    climate%lnemolimtlvl = .false.
    climate%lnemolimthk = .false.
    climate%lnemosicoup = .false.
    climate%lnemoatmflds = .true.
    climate%lnemooceicemix = .false.
    climate%lnemoqnsicefilt = .false.
    climate%lnemoaccumflux = .true.
    climate%lnemopartcoup = .false.
    climate%lnemopartmask = .false.
    climate%lnemopartmaskfile = .false.
    climate%rnpartrampstart = transfer(int(z'4014000000000000', int64), 0.0_real64)
    climate%rnpartramplen = transfer(int(z'4010000000000000', int64), 0.0_real64)
    climate%rnpartlat = transfer(int(z'4034000000000000', int64), 0.0_real64)
    climate%rnpartlatspread = transfer(int(z'4014000000000000', int64), 0.0_real64)
    climate%cplng_active = .false.
    climate%cplng_num_fields = 0_int32
    climate%ip_a_sst = -1_int32
    climate%ip_a_ice_frac = -1_int32
    climate%ip_a_curr_u = -1_int32
    climate%ip_a_curr_v = -1_int32
    climate%ip_a_taux_oce = -1_int32
    climate%ip_a_tauy_oce = -1_int32
    climate%ip_a_taux_ice = -1_int32
    climate%ip_a_tauy_ice = -1_int32
    climate%ip_a_qs_mix = -1_int32
    climate%ip_a_qns_mix = -1_int32
    climate%ip_a_qs_oce = -1_int32
    climate%ip_a_qns_oce = -1_int32
    climate%ip_a_qs_ice = -1_int32
    climate%ip_a_qns_ice = -1_int32
    climate%ip_a_precip_liquid = -1_int32
    climate%ip_a_precip_solid = -1_int32
    climate%ip_a_evap_total = -1_int32
    climate%ip_a_evap_ice = -1_int32
    climate%ip_a_dqns_dt = -1_int32
    climate%ip_a_runoff = -1_int32
    climate%ip_a_total_cc = -1_int32
    climate%ip_a_low_cc = -1_int32
    climate%ip_a_ice_temp = -1_int32
    climate%ip_a_ice_albedo = -1_int32
    climate%ip_a_ice_thickness = -1_int32
    climate%ip_a_snow_thickness = -1_int32
    climate%ip_a_ice_temp_lvls = -1_int32
    climate%ip_a_taux = -1_int32
    climate%ip_a_tauy = -1_int32
    climate%ip_a_qs = -1_int32
    climate%ip_a_qns = -1_int32
    climate%ip_a_water = -1_int32
    climate%ip_a_sst_atm = -1_int32
    climate%ip_a_tsk_atm = -1_int32
    climate%ip_a_ist_atm = -1_int32
    climate%ip_a_2decv_skt = -1_int32
    climate%lcoupsim = .false.
    climate%cdnpartmaskfile = 'partialmask.grib'
    status = 0_int32
  end function

  subroutine apply_selected_coupling(climate)
    type(native_climate_coupling_controls), intent(inout) :: climate
    climate%lmcc01 = .false.
    climate%lmcc02 = .false.
    climate%lmcc03 = .false.
    climate%lmcc04 = .false.
    climate%lmcc05 = .false.
    climate%lmccec = .false.
    climate%lmcciec = .true.
    climate%lmcciceic = .false.
    climate%n923 = 0_int32
    climate%noacomm = 2_int32
    climate%nfrcpl = 999999_int32
    climate%lcurr = .false.
    climate%lgelato = .false.
    climate%lmcc01_mse = .false.
    climate%lnemocoup = .false.
    climate%lnemosstfreez = .false.
    climate%lnemo1way = .false.
    climate%lnemofluxnc = .false.
    climate%lnemooutgrb = .false.
    climate%lcoupinfout = .false.
    climate%lnemoifslog = .false.
    climate%lmccdynseaice = .false.
    climate%lnemogribflds = .false.
    climate%lmultiyr = .false.
    climate%lmcciec_compo = .false.
    climate%lmcc_compo = .false.
    climate%nssticeop = 9_int32
    climate%lnemogrib3d = .false.
    climate%nnemo3dlevs = 20_int32
    climate%lnemogribmask = .false.
    climate%l2decv2nemo = .false.
    climate%n923 = 0_int32
    climate%lnemo1way = .false.
    climate%lnemofluxnc = .false.
    climate%lnemooutgrb = .false.
    climate%lnemogribflds = .false.
    climate%lnemogrib3d = .false.
    climate%lnemogribmask = .false.
    climate%lmccdynseaice = .false.
    climate%lnemolimget = .false.
    climate%lnemolimput = .false.
    climate%lnemolimalb = .false.
    climate%lnemolimtemp = .false.
    climate%lnemolimtlvl = .false.
    climate%lnemolimthk = .false.
  end subroutine

  subroutine apply_operational_coupling(climate, lmccec, lmcciec, nfrco)
    type(native_climate_coupling_controls), intent(inout) :: climate
    logical, intent(in) :: lmccec, lmcciec
    integer(int32), intent(in) :: nfrco
    climate%lmcc01 = .false.
    climate%lmcc02 = .false.
    climate%lmcc03 = .false.
    climate%lmcc04 = .false.
    climate%lmcc05 = .false.
    climate%lmccec = .false.
    climate%lmcciec = .true.
    climate%lmcciceic = .false.
    climate%n923 = 0_int32
    climate%noacomm = 2_int32
    climate%nfrcpl = 999999_int32
    climate%lcurr = .false.
    climate%lgelato = .false.
    climate%lmcc01_mse = .false.
    climate%lnemocoup = .false.
    climate%lnemosstfreez = .false.
    climate%lnemo1way = .false.
    climate%lnemofluxnc = .false.
    climate%lnemooutgrb = .false.
    climate%lcoupinfout = .false.
    climate%lnemoifslog = .false.
    climate%lmccdynseaice = .false.
    climate%lnemogribflds = .false.
    climate%lmultiyr = .false.
    climate%lmcciec_compo = .false.
    climate%lmcc_compo = .false.
    climate%nssticeop = 9_int32
    climate%lnemogrib3d = .false.
    climate%nnemo3dlevs = 20_int32
    climate%lnemogribmask = .false.
    climate%l2decv2nemo = .false.
    climate%lmccec = lmccec
    climate%lmcciec = lmcciec
    climate%n923 = 0_int32
    if (lmccec) climate%nfrcpl = nfrco
    climate%lnemo1way = .false.
    climate%lnemofluxnc = .false.
    climate%lnemooutgrb = .false.
    climate%lnemogribflds = .false.
    climate%lnemogrib3d = .false.
    climate%lnemogribmask = .false.
    climate%lmccdynseaice = .false.
    climate%lnemolimget = .false.
    climate%lnemolimput = .false.
    climate%lnemolimalb = .false.
    climate%lnemolimtemp = .false.
    climate%lnemolimtlvl = .false.
    climate%lnemolimthk = .false.
  end subroutine

  !> Read only LMCCEC and LMCCIEC from the first uppercase NAMMCC group.
  !! TEXT has 1:262144 unchanged ASCII bytes. Repeated keys use their final
  !! value in that first group. Full TRUE/FALSE tokens, with optional dots,
  !! are accepted in either case. Unknown keys or incomplete syntax return 2.
  integer(int32) function read_operational_coupling_group(text, lmccec, lmcciec) result(status)
    character(len=*), intent(in) :: text
    logical, intent(out) :: lmccec, lmcciec
    integer :: cursor, first, last, key, n
    logical :: value, valid
    status = 2_int32
    lmccec = .false.; lmcciec = .true.
    n = len(text)
    if (n < 1 .or. n > 262144) return
    cursor = find_physics_group(text, 'NAMMCC', .false.)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        status = 0_int32
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .true.) .and. &
            text(cursor:cursor) /= '(' .and. text(cursor:cursor) /= ')') exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      if (physics_fold_equal(text(first:last), 'LMCCEC')) then
        key = 1
      else if (physics_fold_equal(text(first:last), 'LMCCIEC')) then
        key = 2
      else
        return
      end if
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor)) .or. text(cursor:cursor) == ',' .or. &
            text(cursor:cursor) == '!' .or. text(cursor:cursor) == '/') exit
        cursor = cursor + 1
      end do
      if (cursor > n) return
      last = cursor - 1
      if (last < first) return
      select case (last - first + 1)
      case (4, 5, 6, 7)
      case default
        return
      end select
      call parse_physics_boolean(text(first:last), value, valid)
      if (.not. valid) return
      if (key == 1) then
        lmccec = value
      else
        lmcciec = value
      end if
    end do
  end function
end module native_inactive_startup_controls
