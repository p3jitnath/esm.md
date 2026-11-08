!> Apply selected SUECRAD parameter fields through native records.
!! The enclosing parent owns parsing, admission, private Planck construction,
!! commit and lifetime. These leaves own the selected literal field writes,
!! visibility arithmetic and final control assignments. The complete parent
!! remains required for the selected_radiation_controls.S counterpart.
module selected_radiation_control_fields_mod
  use iso_fortran_env, only: int32, int64, real64
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yoe_uvrad, only: teuvrad
  use yoelwrad, only: telwrad
  use yoecmip, only: tecmip
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: radiation_interpolation_control_record
  public :: radiation_scalar_parameter_record, radiation_control_selection_record
  public :: apply_radiation_control_literal_fields
  public :: prepare_radiation_visibility_constants
  public :: complete_selected_radiation_control_fields
  public :: commit_selected_radiation_control_fields

  !> Named six-field interpolation choices owned by the enclosing constructor.
  type :: radiation_interpolation_control_record
    integer(int32) :: nslwiden, nslwides, nslwidew, nslwidee
    logical :: lslondem
    integer(int32) :: naslb1
  end type radiation_interpolation_control_record

  !> Caller-owned scalar radiation settings, with no original module state.
  !! Counts and logical switches keep their original names. Real coefficients
  !! keep their source radiation conventions. RWGHTDU(3) is dimensionless.
  !! Native alignment bytes and all unselected components stay unchanged.
  type :: radiation_scalar_parameter_record
    integer(int32) :: nuaer, ntraer
    real(real64) :: r10e, replog, repsc, repsca, repsco, repscq, repsct, repscw, diff
    integer(int32) :: naeradjdu
    real(real64) :: rdumulf, rwghtdu(3), rch4a, rch4b, rcn2oa, rcn2ob
    logical :: lvolcdata
    character(len=260) :: clistso4, cvolcdata
    type(radiation_interpolation_control_record) :: input_interpolation
    type(radiation_interpolation_control_record) :: output_interpolation
    integer(int32) :: ngptot, ngptotmx
  end type radiation_scalar_parameter_record

  !> Read-only named output of the admitted climate and NAERAD selection.
  !! The parent normalizes NRPROMA and supplies the padded source filenames.
  !! This native semantic interface makes no historical byte-layout claim.
  !! The three runtime switches have source-selected true defaults. The parent
  !! admits LSRTM; only runtime-prefix completion consumes the other two.
  type :: radiation_control_selection_record
    integer(int32) :: nhincsol, nghgrad, nscen, nrproma, nrcp, nghgcmip
    logical :: lhghg, laer3d, lepo3ra
    logical :: lapproxlwupdate = .true., lecompgrid = .true., lsrtm = .true.
    character(len=256) :: cghgclimfile, cghgtimeseriesfile, csolarirradiancefile
  end type radiation_control_selection_record

contains

  !> Apply the source literal plan at either original private-record phase.
  !! The five native records are INOUT and INITIAL_ONLY is read only. True
  !! writes only TERAD and TERDI. False repeats those writes and includes
  !! selected UV, climate and own scalar fields. The parent places the two
  !! phases around its private Planck constructor. Optional RUNTIME_PREFIX
  !! defaults false; true retains the source DIFF/R10E incoming values.
  !! No owner is allocated,
  !! released or read; all unselected members and padding remain unchanged.
  subroutine apply_radiation_control_literal_fields( &
    radiation, gases, uv, cmip, scalars, initial_only, runtime_prefix)
    type(terad), intent(inout) :: radiation
    type(terdi), intent(inout) :: gases
    type(teuvrad), intent(inout) :: uv
    type(tecmip), intent(inout) :: cmip
    type(radiation_scalar_parameter_record), intent(inout) :: scalars
    logical, intent(in) :: initial_only
    logical, intent(in), optional :: runtime_prefix
    logical :: runtime_mode
    runtime_mode = .false.
    if (present(runtime_prefix)) runtime_mode = runtime_prefix
    radiation%lerad1h = .false.
    radiation%nlngr1h = int(z'0000000c', int32)
    radiation%lonewsw = .true.
    radiation%lapproxlwupdate = .true.
    radiation%lapproxswupdate = .true.
    radiation%lmannersswupdate = .true.
    radiation%lcentredtimesza = .true.
    radiation%laveragesza = .true.
    radiation%nswwvcontinuum = int(z'00000000', int32)
    radiation%ndumpbadinputs = int(z'00000000', int32)
    radiation%ndumpinputs = int(z'00000000', int32)
    radiation%linterpincloudmean = .false.
    radiation%nscen = int(z'00000001', int32)
    radiation%ldiagforcing = .false.
    radiation%lusepre2017rad = .false.
    radiation%nlwscattering = int(z'00000001', int32)
    radiation%nlwsolver = int(z'00000000', int32)
    radiation%nswsolver = int(z'00000000', int32)
    radiation%ncloudoverlap = int(z'00000003', int32)
    radiation%rcloud_separation_scale_toa = transfer(int(z'40cb580000000000', int64), 0.0_real64)
    radiation%rcloud_separation_scale_surf = transfer(int(z'40a3880000000000', int64), 0.0_real64)
    radiation%nliqopt = int(z'00000004', int32)
    radiation%niceopt = int(z'00000003', int32)
    radiation%nswliqopt = int(z'00000004', int32)
    radiation%nlwliqopt = int(z'00000004', int32)
    radiation%nswiceopt = int(z'00000003', int32)
    radiation%nlwiceopt = int(z'00000003', int32)
    radiation%nradip = int(z'00000003', int32)
    radiation%nradlp = int(z'00000002', int32)
    radiation%rre2de = transfer(int(z'3fe4c8de2ac32229', int64), 0.0_real64)
    radiation%rminice = transfer(int(z'404e000000000000', int64), 0.0_real64)
    radiation%nminice = int(z'00000001', int32)
    radiation%ndecolat = int(z'00000002', int32)
    radiation%lrrtm = .true.
    radiation%lecsrad = .false.
    radiation%lsrtm = .true.
    radiation%nredglw = int(z'00000001', int32)
    radiation%nredgsw = int(z'00000001', int32)
    radiation%nmcica = int(z'00000002', int32)
    radiation%rcloud_frac_std = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    radiation%lecsrad = .false.
    radiation%lfu_lw_ice_optics_bug = .false.
    radiation%ninhom = int(z'00000000', int32)
    radiation%nlayinh = int(z'00000000', int32)
    radiation%rlwinhf = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    radiation%rswinhf = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    radiation%ldiffc = .false.
    radiation%lnewaer = .true.
    radiation%lnotroaer = .false.
    radiation%npertaer = int(z'00000000', int32)
    radiation%leso4his = .false.
    radiation%letracgms = .true.
    radiation%naermacc = int(z'00000001', int32)
    radiation%laer3d = .true.
    radiation%nmclat = int(z'00000001', int32)
    radiation%nmclon = int(z'00000001', int32)
    radiation%nmclev = int(z'00000001', int32)
    radiation%nmcvar = int(z'00000001', int32)
    radiation%laeradcli = .false.
    radiation%laeradjdu = .false.
    if (.not. initial_only) scalars%naeradjdu = int(z'00000000', int32)
    if (.not. initial_only) scalars%rdumulf = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    if (.not. initial_only) scalars%rwghtdu(1) = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    if (.not. initial_only) scalars%rwghtdu(2) = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    if (.not. initial_only) scalars%rwghtdu(3) = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    radiation%lduseason = .true.
    radiation%raeshss = transfer(int(z'408f400000000000', int64), 0.0_real64)
    radiation%raeshdu = transfer(int(z'40a7700000000000', int64), 0.0_real64)
    radiation%raeshom = transfer(int(z'409f400000000000', int64), 0.0_real64)
    radiation%raeshbc = transfer(int(z'408f400000000000', int64), 0.0_real64)
    radiation%raeshsu = transfer(int(z'40af400000000000', int64), 0.0_real64)
    radiation%trbkg = transfer(int(z'3fab573eab367a10', int64), 0.0_real64)
    radiation%stbkg = transfer(int(z'3f726e978d4fdf3b', int64), 0.0_real64)
    radiation%lrayl = .true.
    radiation%lperpet = .false.
    radiation%lccnl = .true.
    radiation%lccno = .true.
    radiation%rccnlnd = transfer(int(z'408c200000000000', int64), 0.0_real64)
    radiation%rccnsea = transfer(int(z'4049000000000000', int64), 0.0_real64)
    radiation%laerclim = .false.
    radiation%laervisi = .true.
    if (.not. initial_only) scalars%rch4a = transfer(int(z'40436adfb0774d0d', int64), 0.0_real64)
    if (.not. initial_only) scalars%rch4b = transfer(int(z'4041b2f9341b2f93', int64), 0.0_real64)
    if (.not. initial_only) scalars%rcn2oa = transfer(int(z'40233b13b13b13b1', int64), 0.0_real64)
    if (.not. initial_only) scalars%rcn2ob = transfer(int(z'40344df833facd52', int64), 0.0_real64)
    radiation%lhvolca = .false.
    radiation%nvolcvert = int(z'00000000', int32)
    radiation%lvolcspec = .false.
    radiation%lvolcdamp = .false.
    if (.not. initial_only) scalars%lvolcdata = .false.
    radiation%rpertoz = transfer(int(z'0000000000000000', int64), 0.0_real64)
    radiation%npertoz = int(z'00000000', int32)
    radiation%nghgrad = int(z'ffffffff', int32)
    radiation%naer = int(z'00000001', int32)
    radiation%nmode = int(z'00000000', int32)
    radiation%nozocl = int(z'00000001', int32)
    radiation%nradpfr = int(z'00000000', int32)
    radiation%nradpla = int(z'0000000f', int32)
    radiation%nradfr = int(z'ffffffff', int32)
    radiation%nradelg = int(z'00000000', int32)
    if (.not. initial_only) uv%luvproc = .false.
    if (.not. initial_only) uv%luvtdep = .true.
    if (.not. initial_only) uv%luvdbg = .false.
    if (.not. initial_only) uv%luvaerp = .false.
    if (.not. initial_only) uv%lo3_chem_uv = .false.
    if (.not. initial_only) uv%nraduv = int(z'ffffffff', int32)
    if (.not. initial_only) uv%nuvtim = int(z'00000000', int32)
    radiation%kmodts = int(z'00000000', int32)
    radiation%nuv = int(z'00000048', int32)
    radiation%ledbug = .false.
    radiation%nradint = int(z'00000003', int32)
    radiation%nradres = int(z'00000000', int32)
    radiation%lecompgrid = .false.
    radiation%novlp = int(z'00000001', int32)
    radiation%ntsw = int(z'0000000e', int32)
    radiation%nsw = int(z'00000006', int32)
    radiation%nswnl = int(z'00000006', int32)
    radiation%nswtl = int(z'00000002', int32)
    if (.not. initial_only) uv%rmuzuv = transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64)
    if (.not. initial_only) scalars%nuaer = int(z'00000018', int32)
    if (.not. initial_only) scalars%ntraer = int(z'0000000f', int32)
    if (.not. initial_only) scalars%repsc = transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64)
    if (.not. initial_only) scalars%repsca = transfer(int(z'3ddb7cdfd9d7bdbb', int64), 0.0_real64)
    if (.not. initial_only) scalars%repsco = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    if (.not. initial_only) scalars%repscq = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    if (.not. initial_only) scalars%repsct = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    if (.not. initial_only) scalars%repscw = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    if (.not. initial_only) scalars%replog = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    radiation%lhghg = .true.
    radiation%leco2var = .true.
    radiation%nhincsol = int(z'00000004', int32)
    radiation%nsolarspectrum = int(z'00000000', int32)
    gases%rcco2 = transfer(int(z'3f37225b749adc90', int64), 0.0_real64)
    gases%rcch4 = transfer(int(z'3ebcdb57fff13c6e', int64), 0.0_real64)
    gases%rcn2o = transfer(int(z'3e94cdc26b1f07d8', int64), 0.0_real64)
    gases%rcno2 = transfer(int(z'3dcb7cdfd9d7bdbb', int64), 0.0_real64)
    gases%rccfc11 = transfer(int(z'3df33dcfe54a3803', int64), 0.0_real64)
    gases%rccfc12 = transfer(int(z'3e00a14f1c1d6744', int64), 0.0_real64)
    gases%rccfc22 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    gases%rcccl4 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    if (.not. initial_only .and. .not. runtime_mode) scalars%diff = transfer(int(z'3ffa8f5c28f5c28f', int64), 0.0_real64)
    if (.not. initial_only .and. .not. runtime_mode) scalars%r10e = transfer(int(z'3fdbcb7b28954a80', int64), 0.0_real64)
    if (.not. initial_only) cmip%no3cmip = int(z'00000000', int32)
    if (.not. initial_only) cmip%nghgcmip = int(z'00000006', int32)
    if (.not. initial_only) cmip%nrcp = int(z'00000003', int32)
    if (.not. initial_only) cmip%ncmipfixyr = int(z'ffffffff', int32)
  end subroutine apply_radiation_control_literal_fields

  !> Preserve the ordered visibility calculation and intermediate RNS store.
  !! RADIATION is INOUT; only RNS and RSIGAIR change. GASES and CONSTANTS
  !! are read only. RCCO2 is a dimensionless volume fraction and the wavelength
  !! is 0.55 micrometres. RNS is molecular density per cubic centimetre;
  !! RSIGAIR is the source Rayleigh prefactor in inverse centimetres to the
  !! fourth power. Its consumer supplies the separate density scaling.
  !! Volatile named coefficients retain otherwise constant-foldable arithmetic.
  subroutine prepare_radiation_visibility_constants(radiation, gases, constants)
    type(terad), intent(inout) :: radiation
    type(terdi), intent(in) :: gases
    type(forecast_physical_constants), intent(in) :: constants
    real(real64), volatile :: co2_percent_scale
    real(real64), volatile :: wavelength_um
    real(real64), volatile :: um_to_cm
    real(real64), volatile :: nitrogen_base
    real(real64), volatile :: nitrogen_inverse_square
    real(real64), volatile :: oxygen_base
    real(real64), volatile :: oxygen_inverse_square
    real(real64), volatile :: oxygen_inverse_fourth
    real(real64), volatile :: nitrogen_weight
    real(real64), volatile :: oxygen_weight_numerator
    real(real64), volatile :: argon_weight
    real(real64), volatile :: co2_weight
    real(real64), volatile :: oxygen_weight_denominator
    real(real64), volatile :: molar_volume
    real(real64), volatile :: nitrogen_resonance
    real(real64), volatile :: nitrogen_strength
    real(real64), volatile :: oxygen_resonance
    real(real64), volatile :: oxygen_strength
    real(real64), volatile :: refractivity_base
    real(real64), volatile :: refractivity_scale
    real(real64), volatile :: reference_co2
    real(real64), volatile :: co2_adjustment
    real(real64), volatile :: rayleigh_coefficient
    real(real64) :: co2_percent, wavelength_squared, inverse_square, inverse_fourth
    real(real64) :: wavelength_cm, wavelength_cm_squared, wavelength_cm_fourth
    real(real64) :: nitrogen_factor, oxygen_factor, term, weighted_numerator
    real(real64) :: weighted_denominator, weighted_factor, molecular_density
    real(real64) :: nitrogen_term, oxygen_term, refractivity, co2_correction
    real(real64) :: refractive_index, index_squared, pi_squared, pi_cubed
    real(real64) :: rayleigh_numerator, index_difference, index_sum, rayleigh_denominator
    co2_percent_scale = transfer(int(z'4059000000000000', int64), 0.0_real64)
    wavelength_um = transfer(int(z'3fe199999999999a', int64), 0.0_real64)
    um_to_cm = transfer(int(z'3f1a36e2eb1c432d', int64), 0.0_real64)
    nitrogen_base = transfer(int(z'3ff08b4395810625', int64), 0.0_real64)
    nitrogen_inverse_square = transfer(int(z'3f34c660a2014728', int64), 0.0_real64)
    oxygen_base = transfer(int(z'3ff189374bc6a7f0', int64), 0.0_real64)
    oxygen_inverse_square = transfer(int(z'3f56b11c6d1e108c', int64), 0.0_real64)
    oxygen_inverse_fourth = transfer(int(z'3f22faae876767ee', int64), 0.0_real64)
    nitrogen_weight = transfer(int(z'405385604189374c', int64), 0.0_real64)
    oxygen_weight_numerator = transfer(int(z'4034f22d0e560419', int64), 0.0_real64)
    argon_weight = transfer(int(z'3fede353f7ced917', int64), 0.0_real64)
    co2_weight = transfer(int(z'3ff2666666666666', int64), 0.0_real64)
    oxygen_weight_denominator = transfer(int(z'40347ef9db22d0e5', int64), 0.0_real64)
    molar_volume = transfer(int(z'40d5e38000000000', int64), 0.0_real64)
    nitrogen_resonance = transfer(int(z'406088c49ba5e354', int64), 0.0_real64)
    nitrogen_strength = transfer(int(z'4142edaf00000000', int64), 0.0_real64)
    oxygen_resonance = transfer(int(z'4043aa2f5989df11', int64), 0.0_real64)
    oxygen_strength = transfer(int(z'40d10beccccccccd', int64), 0.0_real64)
    refractivity_base = transfer(int(z'40bf7c828f5c28f6', int64), 0.0_real64)
    refractivity_scale = transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64)
    reference_co2 = transfer(int(z'3f33a92a30553261', int64), 0.0_real64)
    co2_adjustment = transfer(int(z'3fe147ae147ae148', int64), 0.0_real64)
    rayleigh_coefficient = transfer(int(z'4038000000000000', int64), 0.0_real64)
    co2_percent = gases%rcco2*co2_percent_scale
    wavelength_squared = wavelength_um*wavelength_um
    inverse_square = 1.0_real64/wavelength_squared
    inverse_fourth = inverse_square*inverse_square
    wavelength_cm = wavelength_um*um_to_cm
    wavelength_cm_squared = wavelength_cm*wavelength_cm
    wavelength_cm_fourth = wavelength_cm_squared*wavelength_cm_squared
    term = nitrogen_inverse_square*inverse_square
    nitrogen_factor = nitrogen_base + term
    term = oxygen_inverse_square*inverse_square
    oxygen_factor = oxygen_base + term
    term = oxygen_inverse_fourth*inverse_fourth
    oxygen_factor = oxygen_factor + term
    weighted_numerator = nitrogen_weight*nitrogen_factor
    term = oxygen_weight_numerator*oxygen_factor
    weighted_numerator = weighted_numerator + term
    weighted_numerator = weighted_numerator + argon_weight
    term = co2_percent*co2_weight
    weighted_numerator = weighted_numerator + term
    weighted_denominator = nitrogen_weight + oxygen_weight_denominator
    weighted_denominator = weighted_denominator + argon_weight
    weighted_denominator = weighted_denominator + co2_percent
    weighted_factor = weighted_numerator/weighted_denominator
    molecular_density = constants%rnavo/molar_volume
    radiation%rns = molecular_density
    term = nitrogen_resonance - inverse_square
    nitrogen_term = nitrogen_strength/term
    term = oxygen_resonance - inverse_square
    oxygen_term = oxygen_strength/term
    refractivity = refractivity_base + nitrogen_term
    refractivity = refractivity + oxygen_term
    refractivity = refractivity_scale*refractivity
    co2_correction = gases%rcco2 - reference_co2
    co2_correction = co2_adjustment*co2_correction
    co2_correction = 1.0_real64 + co2_correction
    refractivity = refractivity*co2_correction
    refractive_index = 1.0_real64 + refractivity
    index_squared = refractive_index*refractive_index
    pi_squared = constants%rpi*constants%rpi
    pi_cubed = pi_squared*constants%rpi
    rayleigh_numerator = rayleigh_coefficient*pi_cubed
    index_difference = index_squared - 1.0_real64
    index_difference = index_difference*index_difference
    rayleigh_numerator = rayleigh_numerator*index_difference
    rayleigh_numerator = rayleigh_numerator*weighted_factor
    index_sum = index_squared + 2.0_real64
    index_sum = index_sum*index_sum
    rayleigh_denominator = wavelength_cm_fourth*index_sum
    radiation%rsigair = rayleigh_numerator/rayleigh_denominator
  end subroutine prepare_radiation_visibility_constants

  !> Apply selected post-Planck controls and UV wavelength assignments.
  !! Output records are native INOUT owners. SELECTION, CONSTANTS and the
  !! three int32 point/count scalars are read only. The parent admits disjoint
  !! owners and the selected geometry and filenames. Prior literal phases set
  !! NUV=72; only that active prefix of RUVLAM(3000) is changed. Wavelengths are in
  !! nanometres, with separate source multiply/add rounding in every cell.
  !! Optional RUNTIME_PREFIX defaults false. True uses the parsed update/grid
  !! switches and skips selected fixed-grid, loop and NASLB1 resets. The parent
  !! admits LSRTM true. This leaf does no parsing, allocation or source callback.
  subroutine complete_selected_radiation_control_fields( &
    radiation, gases, uv, longwave, cmip, scalars, selection, nproma, ngptot, ngptotmx, constants, runtime_prefix)
    type(terad), intent(inout) :: radiation
    type(terdi), intent(inout) :: gases
    type(teuvrad), intent(inout) :: uv
    type(telwrad), intent(inout) :: longwave
    type(tecmip), intent(inout) :: cmip
    type(radiation_scalar_parameter_record), intent(inout) :: scalars
    type(radiation_control_selection_record), intent(in) :: selection
    integer(int32), intent(in) :: nproma, ngptot, ngptotmx
    logical, intent(in), optional :: runtime_prefix
    logical :: runtime_mode
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32) :: wavelength
    real(real64), volatile :: wavelength_step, wavelength_start
    real(real64) :: displacement
    runtime_mode = .false.
    if (present(runtime_prefix)) runtime_mode = runtime_prefix
    radiation%rvolcspec = radiation%stbkg
    radiation%nspmapl = [1_int32, 1_int32, 2_int32, 2_int32, 2_int32, 3_int32, 4_int32, &
                         3_int32, 3_int32, 5_int32, 5_int32, 5_int32, 5_int32, 5_int32, 5_int32, 5_int32]
    radiation%nspmaps = [1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32, 7_int32, &
                         8_int32, 9_int32, 10_int32, 11_int32, 12_int32, 13_int32, 14_int32]
    radiation%nhincsol = selection%nhincsol
    radiation%nghgrad = selection%nghgrad
    radiation%lhghg = selection%lhghg
    radiation%nscen = selection%nscen
    radiation%nrproma = selection%nrproma
    radiation%laer3d = selection%laer3d
    radiation%lepo3ra = selection%lepo3ra
    if (runtime_mode) then
      radiation%lapproxlwupdate = selection%lapproxlwupdate
      radiation%lecompgrid = selection%lecompgrid
    end if
    radiation%nlwemiss = 2_int32
    radiation%nlwout = 1_int32
    radiation%loptrproma = .false.
    if (.not. runtime_mode) then
      radiation%nradint = 0_int32
      radiation%nradres = 21_int32
    end if
    gases%rsolinc = constants%ri0
    radiation%csolarirradiancefile = selection%csolarirradiancefile
    radiation%cghgclimfile = selection%cghgclimfile
    radiation%cghgtimeseriesfile = selection%cghgtimeseriesfile
    cmip%nrcp = selection%nrcp
    cmip%nghgcmip = selection%nghgcmip
    cmip%ghgdatadir = './'
    cmip%csolardata = ''
    cmip%co3datadir = './'
    cmip%co3datafil = 'not set '
    scalars%clistso4 = ''
    scalars%cvolcdata = ''
    scalars%input_interpolation%nslwiden = 0_int32
    scalars%input_interpolation%nslwides = 0_int32
    scalars%input_interpolation%nslwidew = 0_int32
    scalars%input_interpolation%nslwidee = 0_int32
    scalars%input_interpolation%lslondem = .true.
    if (.not. runtime_mode) scalars%input_interpolation%naslb1 = 0_int32
    scalars%output_interpolation%nslwiden = 0_int32
    scalars%output_interpolation%nslwides = 0_int32
    scalars%output_interpolation%nslwidew = 0_int32
    scalars%output_interpolation%nslwidee = 0_int32
    scalars%output_interpolation%lslondem = .true.
    if (.not. runtime_mode) scalars%output_interpolation%naslb1 = 0_int32
    if (.not. runtime_mode) then
      scalars%ngptot = ngptot
      scalars%ngptotmx = ngptotmx
      longwave%npromalw = nproma
      longwave%nlooplw = 0_int32
      longwave%nlastlw = 0_int32
    end if
    wavelength_step = 5.0_real64
    wavelength_start = 280.0_real64
    do wavelength = 0_int32, radiation%nuv - 1_int32
      displacement = real(wavelength, real64)*wavelength_step
      uv%ruvlam(wavelength + 1_int32) = wavelength_start + displacement
    end do
  end subroutine complete_selected_radiation_control_fields

  !> Commit only selected named TERAD controls from private staged storage.
  !! TARGET is INOUT and STAGED is read only. No array owner or descriptor,
  !! including Planck and aerosol components, is copied or allocated.
  !! Other TARGET fields and its padding retain their incoming bits.
  subroutine commit_selected_radiation_control_fields(target, staged)
    type(terad), intent(inout) :: target
    type(terad), intent(in) :: staged
    target%lerad1h = staged%lerad1h
    target%nlngr1h = staged%nlngr1h
    target%lonewsw = staged%lonewsw
    target%lapproxlwupdate = staged%lapproxlwupdate
    target%lapproxswupdate = staged%lapproxswupdate
    target%lmannersswupdate = staged%lmannersswupdate
    target%lcentredtimesza = staged%lcentredtimesza
    target%laveragesza = staged%laveragesza
    target%nswwvcontinuum = staged%nswwvcontinuum
    target%ndumpbadinputs = staged%ndumpbadinputs
    target%ndumpinputs = staged%ndumpinputs
    target%linterpincloudmean = staged%linterpincloudmean
    target%nscen = staged%nscen
    target%ldiagforcing = staged%ldiagforcing
    target%lusepre2017rad = staged%lusepre2017rad
    target%nlwscattering = staged%nlwscattering
    target%nlwsolver = staged%nlwsolver
    target%nswsolver = staged%nswsolver
    target%ncloudoverlap = staged%ncloudoverlap
    target%rcloud_separation_scale_toa = staged%rcloud_separation_scale_toa
    target%rcloud_separation_scale_surf = staged%rcloud_separation_scale_surf
    target%nliqopt = staged%nliqopt
    target%niceopt = staged%niceopt
    target%nswliqopt = staged%nswliqopt
    target%nlwliqopt = staged%nlwliqopt
    target%nswiceopt = staged%nswiceopt
    target%nlwiceopt = staged%nlwiceopt
    target%nradip = staged%nradip
    target%nradlp = staged%nradlp
    target%rre2de = staged%rre2de
    target%rminice = staged%rminice
    target%nminice = staged%nminice
    target%ndecolat = staged%ndecolat
    target%lrrtm = staged%lrrtm
    target%lecsrad = staged%lecsrad
    target%lsrtm = staged%lsrtm
    target%nredglw = staged%nredglw
    target%nredgsw = staged%nredgsw
    target%nmcica = staged%nmcica
    target%rcloud_frac_std = staged%rcloud_frac_std
    target%lfu_lw_ice_optics_bug = staged%lfu_lw_ice_optics_bug
    target%ninhom = staged%ninhom
    target%nlayinh = staged%nlayinh
    target%rlwinhf = staged%rlwinhf
    target%rswinhf = staged%rswinhf
    target%ldiffc = staged%ldiffc
    target%lnewaer = staged%lnewaer
    target%lnotroaer = staged%lnotroaer
    target%npertaer = staged%npertaer
    target%leso4his = staged%leso4his
    target%letracgms = staged%letracgms
    target%naermacc = staged%naermacc
    target%laer3d = staged%laer3d
    target%nmclat = staged%nmclat
    target%nmclon = staged%nmclon
    target%nmclev = staged%nmclev
    target%nmcvar = staged%nmcvar
    target%laeradcli = staged%laeradcli
    target%laeradjdu = staged%laeradjdu
    target%lduseason = staged%lduseason
    target%raeshss = staged%raeshss
    target%raeshdu = staged%raeshdu
    target%raeshom = staged%raeshom
    target%raeshbc = staged%raeshbc
    target%raeshsu = staged%raeshsu
    target%trbkg = staged%trbkg
    target%stbkg = staged%stbkg
    target%lrayl = staged%lrayl
    target%lperpet = staged%lperpet
    target%lccnl = staged%lccnl
    target%lccno = staged%lccno
    target%rccnlnd = staged%rccnlnd
    target%rccnsea = staged%rccnsea
    target%laerclim = staged%laerclim
    target%laervisi = staged%laervisi
    target%lhvolca = staged%lhvolca
    target%nvolcvert = staged%nvolcvert
    target%lvolcspec = staged%lvolcspec
    target%lvolcdamp = staged%lvolcdamp
    target%rpertoz = staged%rpertoz
    target%npertoz = staged%npertoz
    target%nghgrad = staged%nghgrad
    target%naer = staged%naer
    target%nmode = staged%nmode
    target%nozocl = staged%nozocl
    target%nradpfr = staged%nradpfr
    target%nradpla = staged%nradpla
    target%nradfr = staged%nradfr
    target%nradelg = staged%nradelg
    target%kmodts = staged%kmodts
    target%nuv = staged%nuv
    target%ledbug = staged%ledbug
    target%nradint = staged%nradint
    target%nradres = staged%nradres
    target%lecompgrid = staged%lecompgrid
    target%novlp = staged%novlp
    target%ntsw = staged%ntsw
    target%nsw = staged%nsw
    target%nswnl = staged%nswnl
    target%nswtl = staged%nswtl
    target%lhghg = staged%lhghg
    target%leco2var = staged%leco2var
    target%nhincsol = staged%nhincsol
    target%nsolarspectrum = staged%nsolarspectrum
    target%rns = staged%rns
    target%rsigair = staged%rsigair
    target%rvolcspec = staged%rvolcspec
    target%nspmapl = staged%nspmapl
    target%nspmaps = staged%nspmaps
    target%nrproma = staged%nrproma
    target%lepo3ra = staged%lepo3ra
    target%nlwemiss = staged%nlwemiss
    target%nlwout = staged%nlwout
    target%loptrproma = staged%loptrproma
    target%csolarirradiancefile = staged%csolarirradiancefile
    target%cghgclimfile = staged%cghgclimfile
    target%cghgtimeseriesfile = staged%cghgtimeseriesfile
  end subroutine commit_selected_radiation_control_fields

end module selected_radiation_control_fields_mod
