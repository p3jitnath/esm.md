!> Construct source SUDYN controls and SUSLB integer maps with native owners.
!! Inputs remain at their caller-owned addresses. Counts and indices are unitless.
!! The caller establishes nearest-even rounding and gradual underflow. These
!! entries perform no floating calculation; parity and speed values are literals.
module forecast_model_interpolation_setup
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use forecast_semi_lagrangian_buffer_types
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_operational_dynamics, only: native_dynamics_controls
  use grid_field_configuration_types_port, only: grid_field_configuration
  use yoephy, only: tephy
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_key_character, physics_space, physics_fold_equal, parse_physics_boolean
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_interpolation_record_defaults
  public :: initialize_selected_interpolation_controls, initialize_operational_interpolation_controls
  public :: initialize_selected_sl_velocity_controls, initialize_selected_sl_buffer_maps
  public :: release_selected_sl_buffer_maps
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Apply the three declaration defaults to a fresh canonical SL_STRUCT.
  !! Native declaration-default or zero scalar preimages are admitted. All
  !! other named scalar data must be zero and every array owner must be absent.
  !! Status2 preserves the incoming record; status0 writes only these defaults.
  integer(int32) function initialize_interpolation_record_defaults(state) result(status)
    type(native_interpolation_state), intent(inout) :: state
    status = 2
    if (.not. fresh_interpolation_state(state)) return
    state%cver = 'XX'
    state%nunusedhalo = 999999
    state%distunusedhalo = 999999.0_real64
    status = 0
  end function

  !> Initialize the historical empty-group SUDYN control branch.
  !! TEXT is bounded ASCII; DYNAMICS and PLATFORM are read-only source inputs.
  !! OUTPUT owns only named scalar controls, with no allocation. Refusal2
  !! changes nothing; success0 writes the source-assigned controls in order.
  integer(int32) function initialize_selected_interpolation_controls(text, dynamics, platform, output) result(status)
    character(*), intent(in) :: text
    type(native_dynamics_controls), intent(in) :: dynamics
    type(native_interpolation_platform), intent(in) :: platform
    type(native_interpolation_controls), intent(inout) :: output
    status = 2
    if (.not. admitted_dynamics(dynamics) .or. .not. admitted_platform(platform)) return
    if (require_empty_physics_group(text, 'NAMDYN') /= 0) return
    if (require_empty_physics_group(text, 'NAMDYNA') /= 0) return
    call assign_interpolation_controls(dynamics, output)
    status = 0
  end function

  !> Read operational LMASCOR/NITMP before committing the consumed SUDYN fields.
  !! The first NAMDYN group admits LMASCOR as a logical and NITMP=3. Unwritten
  !! members retain their incoming values. TEXT has1:262144 ASCII characters.
  integer(int32) function initialize_operational_interpolation_controls(text, dynamics, platform, output) result(status)
    character(*), intent(in) :: text
    type(native_dynamics_controls), intent(in) :: dynamics
    type(native_interpolation_platform), intent(in) :: platform
    type(native_interpolation_controls), intent(inout) :: output
    logical :: lmascor
    integer(int32) :: nitmp
    status = 2
    if (.not. admitted_dynamics(dynamics) .or. .not. admitted_platform(platform)) return
    if (.not. read_operational_controls(text, lmascor, nitmp)) return
    output%lmascor = lmascor
    output%nitmp = nitmp
    call assign_interpolation_controls(dynamics, output)
    status = 0
  end function

  !> Store exact speed limits in metres per second from1:255 live layers.
  integer(int32) function initialize_selected_sl_velocity_controls(levels, output) result(status)
    integer(int32), intent(in) :: levels
    type(native_interpolation_controls), intent(inout) :: output
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (levels < 91) then
      output%vmax1 = 220.0_real64
      output%vmax2 = 320.0_real64
    else
      output%vmax1 = 250.0_real64
      output%vmax2 = 400.0_real64
    end if
    status = 0
  end function

  !> Build the three SUSLB maps and two parity owners transactionally.
  !! LEVELS is1:255. GFL supplies live NUMFLDS/NUMFLDS_SL1/NDIMSLP and the
  !! separate LSPLTHOIGFL side effect. Read-only source inputs must be disjoint
  !! from BUFFERS. Source-selected branches require both parity owners absent.
  !! Status2 refuses before mutation; allocation failure1 releases new owners.
  !! Both allocations precede commit. The one RPARSL15 element stays unwritten.
  integer(int32) function initialize_selected_sl_buffer_maps(levels, dynamics, controls, gfl, physics, &
                                                             lsplthoigfl, lrsiddh, buffers) result(status)
    integer(int32), intent(in) :: levels
    type(native_dynamics_controls), intent(in) :: dynamics
    type(native_interpolation_controls), intent(in) :: controls
    type(grid_field_configuration), intent(in) :: gfl
    type(tephy), intent(in) :: physics
    logical, intent(in) :: lsplthoigfl, lrsiddh
    type(native_semi_lagrangian_buffers), intent(inout) :: buffers
    type(native_sl_buffer_one) :: first
    type(native_sl_buffer_two) :: second
    type(native_sl_buffer_refined) :: refined
    integer(int32) :: g, p, l2, cursor, starts(6), j, k, ignored
    integer :: allocation_status
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (.not. dynamics%lslag .or. dynamics%lnhdyn .or. dynamics%lnhee) return
    if (controls%nsplthoi /= 0 .or. lsplthoigfl .or. controls%lsvtsm .or. controls%lsldp_rk) return
    if (controls%lrhs_curv .or. .not. controls%lsldp_curv .or. .not. controls%lsldp_xyz) return
    if (controls%nvlag /= 3 .or. controls%nwlag /= 3 .or. controls%ntlag /= 3) return
    if (dynamics%lslhd .or. dynamics%lrdbbc .or. dynamics%l3dturb .or. dynamics%lcomad) return
    if (dynamics%lslinl .or. dynamics%lslinlc2 .or. dynamics%lpc_cheap) return
    if (.not. physics%lagphy .or. .not. physics%lephys .or. .not. physics%lslphy .or. lrsiddh) return
    g = gfl%registration%numflds_sl1
    p = gfl%registration%ndimslp
    if (g < 0 .or. g > 64 .or. g > gfl%registration%numflds .or. p < 0 .or. p > 64) return
    if (gfl%registration%numflds_spl /= 0) return
    if (allocated(buffers%first%rparsl1) .or. allocated(buffers%refined%rparsl15)) return
    first%nfldslb1 = buffers%first%nfldslb1
    first%mslbuf1 = buffers%first%mslbuf1
    first%mslb1u9 = buffers%first%mslb1u9
    first%mslb1v9 = buffers%first%mslb1v9
    first%mslb1z9 = buffers%first%mslb1z9
    first%mslb1t9 = buffers%first%mslb1t9
    first%mslb1gfl9 = buffers%first%mslb1gfl9
    first%mslb1gflsp9 = buffers%first%mslb1gflsp9
    first%mslb1pd9 = buffers%first%mslb1pd9
    first%mslb1vd9 = buffers%first%mslb1vd9
    first%mslb1nhx9 = buffers%first%mslb1nhx9
    first%mslb1ur0 = buffers%first%mslb1ur0
    first%mslb1vr0 = buffers%first%mslb1vr0
    first%mslb1zr0 = buffers%first%mslb1zr0
    first%mslb1wr0 = buffers%first%mslb1wr0
    first%mslb1ur00 = buffers%first%mslb1ur00
    first%mslb1vr00 = buffers%first%mslb1vr00
    first%mslb1zr00 = buffers%first%mslb1zr00
    first%mslb1wr00 = buffers%first%mslb1wr00
    first%mslb1wra = buffers%first%mslb1wra
    first%mslb1ur9 = buffers%first%mslb1ur9
    first%mslb1vr9 = buffers%first%mslb1vr9
    first%mslb1zr9 = buffers%first%mslb1zr9
    first%mslb1dbbc9 = buffers%first%mslb1dbbc9
    first%mslb1dphi9 = buffers%first%mslb1dphi9
    first%mslb1gws9 = buffers%first%mslb1gws9
    first%mslb1u0 = buffers%first%mslb1u0
    first%mslb1v0 = buffers%first%mslb1v0
    first%mslb1z0 = buffers%first%mslb1z0
    first%mslb1t0 = buffers%first%mslb1t0
    first%mslb1pd0 = buffers%first%mslb1pd0
    first%mslb1vd0 = buffers%first%mslb1vd0
    first%mslb1c9 = buffers%first%mslb1c9
    first%mslb1sp9 = buffers%first%mslb1sp9
    first%mslb1sp0 = buffers%first%mslb1sp0
    first%mslb1c0 = buffers%first%mslb1c0
    first%mslb1up9 = buffers%first%mslb1up9
    first%mslb1vp9 = buffers%first%mslb1vp9
    first%mslb1zp9 = buffers%first%mslb1zp9
    first%mslb1tp9 = buffers%first%mslb1tp9
    first%mslb1gflp9 = buffers%first%mslb1gflp9
    first%mslb1u9_si = buffers%first%mslb1u9_si
    first%mslb1v9_si = buffers%first%mslb1v9_si
    first%mslb1t9_si = buffers%first%mslb1t9_si
    first%mslb1pd9_si = buffers%first%mslb1pd9_si
    first%mslb1vd9_si = buffers%first%mslb1vd9_si
    first%mslb1c9_si = buffers%first%mslb1c9_si
    first%mslb1uf9 = buffers%first%mslb1uf9
    first%mslb1vf9 = buffers%first%mslb1vf9
    first%mslb1tf9 = buffers%first%mslb1tf9
    first%mslb1gflf9 = buffers%first%mslb1gflf9
    first%mslb1vdf9 = buffers%first%mslb1vdf9
    first%mslb1gflspf9 = buffers%first%mslb1gflspf9
    first%mslb1u9_nl = buffers%first%mslb1u9_nl
    first%mslb1v9_nl = buffers%first%mslb1v9_nl
    first%mslb1t9_nl = buffers%first%mslb1t9_nl
    first%mslb1pd9_nl = buffers%first%mslb1pd9_nl
    first%mslb1vd9_nl = buffers%first%mslb1vd9_nl
    first%mslb1c9_nl = buffers%first%mslb1c9_nl
    second%nfldslb2 = buffers%second%nfldslb2
    second%mslbuf2 = buffers%second%mslbuf2
    second%mslb2dbbc1 = buffers%second%mslb2dbbc1
    second%mslb2dphi1 = buffers%second%mslb2dphi1
    second%mslb2usi = buffers%second%mslb2usi
    second%mslb2vsi = buffers%second%mslb2vsi
    second%mslb2tsi = buffers%second%mslb2tsi
    second%mslb2pdsi = buffers%second%mslb2pdsi
    second%mslb2vdsi = buffers%second%mslb2vdsi
    second%mslb2spsi = buffers%second%mslb2spsi
    second%mslb2vvel = buffers%second%mslb2vvel
    second%mslb2url = buffers%second%mslb2url
    second%mslb2vrl = buffers%second%mslb2vrl
    second%mslb2wrl = buffers%second%mslb2wrl
    second%mslb2zrl = buffers%second%mslb2zrl
    second%mslb2url5 = buffers%second%mslb2url5
    second%mslb2vrl5 = buffers%second%mslb2vrl5
    second%mslb2wrl5 = buffers%second%mslb2wrl5
    second%mslb2zrl5 = buffers%second%mslb2zrl5
    second%mslb2usi5 = buffers%second%mslb2usi5
    second%mslb2vsi5 = buffers%second%mslb2vsi5
    second%mslb2u15 = buffers%second%mslb2u15
    second%mslb2v15 = buffers%second%mslb2v15
    second%mslb2t15 = buffers%second%mslb2t15
    second%mslb2q15 = buffers%second%mslb2q15
    second%mslb2kappa = buffers%second%mslb2kappa
    second%mslb2kappat = buffers%second%mslb2kappat
    second%mslb2kappam = buffers%second%mslb2kappam
    second%mslb2kappah = buffers%second%mslb2kappah
    second%mslb2kappa5 = buffers%second%mslb2kappa5
    second%mslb2kappat5 = buffers%second%mslb2kappat5
    second%mslb2gwf = buffers%second%mslb2gwf
    second%mslb2gdw = buffers%second%mslb2gdw
    second%mslb2gws = buffers%second%mslb2gws
    second%mslb2stddisu = buffers%second%mslb2stddisu
    second%mslb2stddisv = buffers%second%mslb2stddisv
    second%mslb2stddisw = buffers%second%mslb2stddisw
    second%mslb2stddisu5 = buffers%second%mslb2stddisu5
    second%mslb2stddisv5 = buffers%second%mslb2stddisv5
    second%mslb2stddisw5 = buffers%second%mslb2stddisw5
    refined%nfldslb15 = buffers%refined%nfldslb15
    refined%mslbuf15 = buffers%refined%mslbuf15
    refined%mslb1ur05 = buffers%refined%mslb1ur05
    refined%mslb1vr05 = buffers%refined%mslb1vr05
    refined%mslb1zr05 = buffers%refined%mslb1zr05
    refined%mslb1wr05 = buffers%refined%mslb1wr05
    refined%mslb1ur005 = buffers%refined%mslb1ur005
    refined%mslb1vr005 = buffers%refined%mslb1vr005
    refined%mslb1zr005 = buffers%refined%mslb1zr005
    refined%mslb1wr005 = buffers%refined%mslb1wr005
    refined%mslb1ur95 = buffers%refined%mslb1ur95
    refined%mslb1vr95 = buffers%refined%mslb1vr95
    refined%mslb1zr95 = buffers%refined%mslb1zr95
    refined%mslb1u05 = buffers%refined%mslb1u05
    refined%mslb1v05 = buffers%refined%mslb1v05
    refined%mslb1z05 = buffers%refined%mslb1z05
    refined%mslb1t05 = buffers%refined%mslb1t05
    refined%mslb1c05 = buffers%refined%mslb1c05
    refined%mslb1sp05 = buffers%refined%mslb1sp05
    refined%mslb1u95 = buffers%refined%mslb1u95
    refined%mslb1v95 = buffers%refined%mslb1v95
    refined%mslb1z95 = buffers%refined%mslb1z95
    refined%mslb1t95 = buffers%refined%mslb1t95
    refined%mslb1gfl95 = buffers%refined%mslb1gfl95
    refined%mslb1c95 = buffers%refined%mslb1c95
    refined%mslb1up95 = buffers%refined%mslb1up95
    refined%mslb1vp95 = buffers%refined%mslb1vp95
    refined%mslb1zp95 = buffers%refined%mslb1zp95
    refined%mslb1tp95 = buffers%refined%mslb1tp95
    refined%mslb1gflp95 = buffers%refined%mslb1gflp95
    refined%mslb1sp95 = buffers%refined%mslb1sp95
    first%mslbuf1 = -99999_int32
    first%mslb1ur9 = -99999_int32
    first%mslb1vr9 = -99999_int32
    first%mslb1zr9 = -99999_int32
    first%mslb1u9 = -99999_int32
    first%mslb1v9 = -99999_int32
    first%mslb1z9 = -99999_int32
    first%mslb1t9 = -99999_int32
    first%mslb1gfl9 = -99999_int32
    first%mslb1gflsp9 = -99999_int32
    first%mslb1sp9 = -99999_int32
    first%mslb1c9 = -99999_int32
    first%mslb1vd9 = -99999_int32
    first%mslb1nhx9 = -99999_int32
    first%mslb1pd9 = -99999_int32
    first%mslb1u9_si = -99999_int32
    first%mslb1v9_si = -99999_int32
    first%mslb1t9_si = -99999_int32
    first%mslb1c9_si = -99999_int32
    first%mslb1vd9_si = -99999_int32
    first%mslb1pd9_si = -99999_int32
    first%mslb1u9_nl = -99999_int32
    first%mslb1v9_nl = -99999_int32
    first%mslb1t9_nl = -99999_int32
    first%mslb1c9_nl = -99999_int32
    first%mslb1vd9_nl = -99999_int32
    first%mslb1pd9_nl = -99999_int32
    first%mslb1uf9 = -99999_int32
    first%mslb1vf9 = -99999_int32
    first%mslb1tf9 = -99999_int32
    first%mslb1gflf9 = -99999_int32
    first%mslb1vdf9 = -99999_int32
    first%mslb1gflspf9 = -99999_int32
    first%mslb1dbbc9 = -99999_int32
    first%mslb1dphi9 = -99999_int32
    first%mslb1gws9 = -99999_int32
    first%mslb1ur0 = -99999_int32
    first%mslb1vr0 = -99999_int32
    first%mslb1zr0 = -99999_int32
    first%mslb1wr0 = -99999_int32
    first%mslb1ur00 = -99999_int32
    first%mslb1vr00 = -99999_int32
    first%mslb1zr00 = -99999_int32
    first%mslb1wr00 = -99999_int32
    first%mslb1wra = -99999_int32
    first%mslb1u0 = -99999_int32
    first%mslb1v0 = -99999_int32
    first%mslb1z0 = -99999_int32
    first%mslb1t0 = -99999_int32
    first%mslb1c0 = -99999_int32
    first%mslb1vd0 = -99999_int32
    first%mslb1pd0 = -99999_int32
    first%mslb1up9 = -99999_int32
    first%mslb1vp9 = -99999_int32
    first%mslb1zp9 = -99999_int32
    first%mslb1tp9 = -99999_int32
    first%mslb1gflp9 = -99999_int32
    second%mslbuf2 = -99999_int32
    second%mslb2dbbc1 = -99999_int32
    second%mslb2dphi1 = -99999_int32
    second%mslb2usi = -99999_int32
    second%mslb2vsi = -99999_int32
    second%mslb2tsi = -99999_int32
    second%mslb2pdsi = -99999_int32
    second%mslb2vdsi = -99999_int32
    second%mslb2spsi = -99999_int32
    second%mslb2vvel = -99999_int32
    second%mslb2url = -99999_int32
    second%mslb2vrl = -99999_int32
    second%mslb2wrl = -99999_int32
    second%mslb2zrl = -99999_int32
    second%mslb2u15 = -99999_int32
    second%mslb2v15 = -99999_int32
    second%mslb2t15 = -99999_int32
    second%mslb2q15 = -99999_int32
    second%mslb2url5 = -99999_int32
    second%mslb2vrl5 = -99999_int32
    second%mslb2wrl5 = -99999_int32
    second%mslb2zrl5 = -99999_int32
    second%mslb2kappa = -99999_int32
    second%mslb2kappa5 = -99999_int32
    second%mslb2kappat = -99999_int32
    second%mslb2kappat5 = -99999_int32
    second%mslb2kappam = -99999_int32
    second%mslb2kappah = -99999_int32
    second%mslb2gwf = -99999_int32
    second%mslb2gdw = -99999_int32
    second%mslb2gws = -99999_int32
    second%mslb2stddisu = -99999_int32
    second%mslb2stddisu5 = -99999_int32
    second%mslb2stddisv = -99999_int32
    second%mslb2stddisv5 = -99999_int32
    second%mslb2stddisw = -99999_int32
    second%mslb2stddisw5 = -99999_int32
    refined%mslbuf15 = -99999_int32
    refined%mslb1u95 = -99999_int32
    refined%mslb1v95 = -99999_int32
    refined%mslb1z95 = -99999_int32
    refined%mslb1t95 = -99999_int32
    refined%mslb1gfl95 = -99999_int32
    refined%mslb1u05 = -99999_int32
    refined%mslb1v05 = -99999_int32
    refined%mslb1z05 = -99999_int32
    refined%mslb1t05 = -99999_int32
    refined%mslb1c95 = -99999_int32
    refined%mslb1c05 = -99999_int32
    refined%mslb1sp95 = -99999_int32
    refined%mslb1ur05 = -99999_int32
    refined%mslb1vr05 = -99999_int32
    refined%mslb1zr05 = -99999_int32
    refined%mslb1wr05 = -99999_int32
    refined%mslb1ur005 = -99999_int32
    refined%mslb1vr005 = -99999_int32
    refined%mslb1zr005 = -99999_int32
    refined%mslb1wr005 = -99999_int32
    refined%mslb1ur95 = -99999_int32
    refined%mslb1vr95 = -99999_int32
    refined%mslb1zr95 = -99999_int32
    refined%mslb1up95 = -99999_int32
    refined%mslb1vp95 = -99999_int32
    refined%mslb1zp95 = -99999_int32
    refined%mslb1tp95 = -99999_int32
    refined%mslb1gflp95 = -99999_int32
    cursor = 1
    second%mslbuf2 = cursor
    second%mslb2usi = cursor
    cursor = cursor + levels
    second%mslb2vsi = cursor
    cursor = cursor + levels
    second%mslb2tsi = cursor
    cursor = cursor + levels
    second%mslb2spsi = cursor
    cursor = cursor + 1
    second%mslb2vvel = cursor
    cursor = cursor + levels
    second%mslb2url = cursor
    cursor = cursor + levels
    second%mslb2vrl = cursor
    cursor = cursor + levels
    second%mslb2wrl = cursor
    cursor = cursor + levels
    second%mslb2zrl = cursor
    cursor = cursor + levels
    second%nfldslb2 = cursor - 1
    l2 = levels + 2
    cursor = 1
    first%mslbuf1 = cursor
    first%mslb1u9 = cursor
    cursor = cursor + l2
    first%mslb1v9 = cursor
    cursor = cursor + l2
    first%mslb1t9 = cursor
    cursor = cursor + l2
    if (g /= 0) then
      first%mslb1gfl9 = cursor
      cursor = cursor + g*l2
    end if
    first%mslb1sp9 = cursor
    cursor = cursor + 1
    first%mslb1ur0 = cursor
    cursor = cursor + l2
    first%mslb1vr0 = cursor
    cursor = cursor + l2
    first%mslb1zr0 = cursor
    cursor = cursor + l2
    first%mslb1wr0 = cursor
    cursor = cursor + l2
    first%mslb1u0 = cursor
    cursor = cursor + l2
    first%mslb1v0 = cursor
    cursor = cursor + l2
    first%mslb1t0 = cursor
    cursor = cursor + l2
    first%mslb1c9 = cursor
    cursor = cursor + l2
    first%mslb1up9 = cursor
    cursor = cursor + l2
    first%mslb1vp9 = cursor
    cursor = cursor + l2
    first%mslb1tp9 = cursor
    cursor = cursor + l2
    first%mslb1gflp9 = cursor
    cursor = cursor + p*l2
    first%nfldslb1 = cursor - 1
    refined%nfldslb15 = 1
    allocate (first%rparsl1(first%nfldslb1), stat=allocation_status)
    status = 1
    if (allocation_status /= 0) return
    allocate (refined%rparsl15(1), stat=allocation_status)
    if (allocation_status /= 0) then
      deallocate (first%rparsl1)
      return
    end if
    first%rparsl1 = 1.0_real64
    starts = [first%mslb1u9, first%mslb1v9, first%mslb1u0, first%mslb1v0, first%mslb1up9, first%mslb1vp9]
    do j = 1, 6
      do k = starts(j), starts(j) + l2 - 1
        first%rparsl1(k) = -1.0_real64
      end do
    end do
    call move_alloc(first%rparsl1, buffers%first%rparsl1)
    call move_alloc(refined%rparsl15, buffers%refined%rparsl15)
    buffers%first%nfldslb1 = first%nfldslb1
    buffers%first%mslbuf1 = first%mslbuf1
    buffers%first%mslb1u9 = first%mslb1u9
    buffers%first%mslb1v9 = first%mslb1v9
    buffers%first%mslb1z9 = first%mslb1z9
    buffers%first%mslb1t9 = first%mslb1t9
    buffers%first%mslb1gfl9 = first%mslb1gfl9
    buffers%first%mslb1gflsp9 = first%mslb1gflsp9
    buffers%first%mslb1pd9 = first%mslb1pd9
    buffers%first%mslb1vd9 = first%mslb1vd9
    buffers%first%mslb1nhx9 = first%mslb1nhx9
    buffers%first%mslb1ur0 = first%mslb1ur0
    buffers%first%mslb1vr0 = first%mslb1vr0
    buffers%first%mslb1zr0 = first%mslb1zr0
    buffers%first%mslb1wr0 = first%mslb1wr0
    buffers%first%mslb1ur00 = first%mslb1ur00
    buffers%first%mslb1vr00 = first%mslb1vr00
    buffers%first%mslb1zr00 = first%mslb1zr00
    buffers%first%mslb1wr00 = first%mslb1wr00
    buffers%first%mslb1wra = first%mslb1wra
    buffers%first%mslb1ur9 = first%mslb1ur9
    buffers%first%mslb1vr9 = first%mslb1vr9
    buffers%first%mslb1zr9 = first%mslb1zr9
    buffers%first%mslb1dbbc9 = first%mslb1dbbc9
    buffers%first%mslb1dphi9 = first%mslb1dphi9
    buffers%first%mslb1gws9 = first%mslb1gws9
    buffers%first%mslb1u0 = first%mslb1u0
    buffers%first%mslb1v0 = first%mslb1v0
    buffers%first%mslb1z0 = first%mslb1z0
    buffers%first%mslb1t0 = first%mslb1t0
    buffers%first%mslb1pd0 = first%mslb1pd0
    buffers%first%mslb1vd0 = first%mslb1vd0
    buffers%first%mslb1c9 = first%mslb1c9
    buffers%first%mslb1sp9 = first%mslb1sp9
    buffers%first%mslb1sp0 = first%mslb1sp0
    buffers%first%mslb1c0 = first%mslb1c0
    buffers%first%mslb1up9 = first%mslb1up9
    buffers%first%mslb1vp9 = first%mslb1vp9
    buffers%first%mslb1zp9 = first%mslb1zp9
    buffers%first%mslb1tp9 = first%mslb1tp9
    buffers%first%mslb1gflp9 = first%mslb1gflp9
    buffers%first%mslb1u9_si = first%mslb1u9_si
    buffers%first%mslb1v9_si = first%mslb1v9_si
    buffers%first%mslb1t9_si = first%mslb1t9_si
    buffers%first%mslb1pd9_si = first%mslb1pd9_si
    buffers%first%mslb1vd9_si = first%mslb1vd9_si
    buffers%first%mslb1c9_si = first%mslb1c9_si
    buffers%first%mslb1uf9 = first%mslb1uf9
    buffers%first%mslb1vf9 = first%mslb1vf9
    buffers%first%mslb1tf9 = first%mslb1tf9
    buffers%first%mslb1gflf9 = first%mslb1gflf9
    buffers%first%mslb1vdf9 = first%mslb1vdf9
    buffers%first%mslb1gflspf9 = first%mslb1gflspf9
    buffers%first%mslb1u9_nl = first%mslb1u9_nl
    buffers%first%mslb1v9_nl = first%mslb1v9_nl
    buffers%first%mslb1t9_nl = first%mslb1t9_nl
    buffers%first%mslb1pd9_nl = first%mslb1pd9_nl
    buffers%first%mslb1vd9_nl = first%mslb1vd9_nl
    buffers%first%mslb1c9_nl = first%mslb1c9_nl
    buffers%second%nfldslb2 = second%nfldslb2
    buffers%second%mslbuf2 = second%mslbuf2
    buffers%second%mslb2dbbc1 = second%mslb2dbbc1
    buffers%second%mslb2dphi1 = second%mslb2dphi1
    buffers%second%mslb2usi = second%mslb2usi
    buffers%second%mslb2vsi = second%mslb2vsi
    buffers%second%mslb2tsi = second%mslb2tsi
    buffers%second%mslb2pdsi = second%mslb2pdsi
    buffers%second%mslb2vdsi = second%mslb2vdsi
    buffers%second%mslb2spsi = second%mslb2spsi
    buffers%second%mslb2vvel = second%mslb2vvel
    buffers%second%mslb2url = second%mslb2url
    buffers%second%mslb2vrl = second%mslb2vrl
    buffers%second%mslb2wrl = second%mslb2wrl
    buffers%second%mslb2zrl = second%mslb2zrl
    buffers%second%mslb2url5 = second%mslb2url5
    buffers%second%mslb2vrl5 = second%mslb2vrl5
    buffers%second%mslb2wrl5 = second%mslb2wrl5
    buffers%second%mslb2zrl5 = second%mslb2zrl5
    buffers%second%mslb2usi5 = second%mslb2usi5
    buffers%second%mslb2vsi5 = second%mslb2vsi5
    buffers%second%mslb2u15 = second%mslb2u15
    buffers%second%mslb2v15 = second%mslb2v15
    buffers%second%mslb2t15 = second%mslb2t15
    buffers%second%mslb2q15 = second%mslb2q15
    buffers%second%mslb2kappa = second%mslb2kappa
    buffers%second%mslb2kappat = second%mslb2kappat
    buffers%second%mslb2kappam = second%mslb2kappam
    buffers%second%mslb2kappah = second%mslb2kappah
    buffers%second%mslb2kappa5 = second%mslb2kappa5
    buffers%second%mslb2kappat5 = second%mslb2kappat5
    buffers%second%mslb2gwf = second%mslb2gwf
    buffers%second%mslb2gdw = second%mslb2gdw
    buffers%second%mslb2gws = second%mslb2gws
    buffers%second%mslb2stddisu = second%mslb2stddisu
    buffers%second%mslb2stddisv = second%mslb2stddisv
    buffers%second%mslb2stddisw = second%mslb2stddisw
    buffers%second%mslb2stddisu5 = second%mslb2stddisu5
    buffers%second%mslb2stddisv5 = second%mslb2stddisv5
    buffers%second%mslb2stddisw5 = second%mslb2stddisw5
    buffers%refined%nfldslb15 = refined%nfldslb15
    buffers%refined%mslbuf15 = refined%mslbuf15
    buffers%refined%mslb1ur05 = refined%mslb1ur05
    buffers%refined%mslb1vr05 = refined%mslb1vr05
    buffers%refined%mslb1zr05 = refined%mslb1zr05
    buffers%refined%mslb1wr05 = refined%mslb1wr05
    buffers%refined%mslb1ur005 = refined%mslb1ur005
    buffers%refined%mslb1vr005 = refined%mslb1vr005
    buffers%refined%mslb1zr005 = refined%mslb1zr005
    buffers%refined%mslb1wr005 = refined%mslb1wr005
    buffers%refined%mslb1ur95 = refined%mslb1ur95
    buffers%refined%mslb1vr95 = refined%mslb1vr95
    buffers%refined%mslb1zr95 = refined%mslb1zr95
    buffers%refined%mslb1u05 = refined%mslb1u05
    buffers%refined%mslb1v05 = refined%mslb1v05
    buffers%refined%mslb1z05 = refined%mslb1z05
    buffers%refined%mslb1t05 = refined%mslb1t05
    buffers%refined%mslb1c05 = refined%mslb1c05
    buffers%refined%mslb1sp05 = refined%mslb1sp05
    buffers%refined%mslb1u95 = refined%mslb1u95
    buffers%refined%mslb1v95 = refined%mslb1v95
    buffers%refined%mslb1z95 = refined%mslb1z95
    buffers%refined%mslb1t95 = refined%mslb1t95
    buffers%refined%mslb1gfl95 = refined%mslb1gfl95
    buffers%refined%mslb1c95 = refined%mslb1c95
    buffers%refined%mslb1up95 = refined%mslb1up95
    buffers%refined%mslb1vp95 = refined%mslb1vp95
    buffers%refined%mslb1zp95 = refined%mslb1zp95
    buffers%refined%mslb1tp95 = refined%mslb1tp95
    buffers%refined%mslb1gflp95 = refined%mslb1gflp95
    buffers%refined%mslb1sp95 = refined%mslb1sp95
    status = 0
  end function

  !> Release refined parity before first parity; retain every integer map value.
  integer(int32) function release_selected_sl_buffer_maps(buffers) result(status)
    type(native_semi_lagrangian_buffers), intent(inout) :: buffers
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (allocated(buffers%refined%rparsl15)) deallocate (buffers%refined%rparsl15)
    if (allocated(buffers%first%rparsl1)) deallocate (buffers%first%rparsl1)
    error_number = saved_errno
    status = 0
  end function

  logical function admitted_platform(platform) result(admitted)
    type(native_interpolation_platform), intent(in) :: platform
    admitted = platform%nconf == 1 .and. platform%lecmwf == 1 .and. platform%lr2d == 0 .and. platform%lr3d == 1
  end function
  logical function admitted_dynamics(dynamics) result(admitted)
    type(native_dynamics_controls), intent(in) :: dynamics
    admitted = dynamics%lslag .and. dynamics%ltwotl .and. .not. dynamics%lnhdyn .and. .not. dynamics%lnhee .and. &
               .not. dynamics%l3dturb .and. .not. dynamics%lslhd .and. .not. dynamics%lrdbbc .and. .not. dynamics%lcomad .and. &
               .not. dynamics%lslinl .and. .not. dynamics%lslinlc2 .and. .not. dynamics%lpc_cheap .and. dynamics%lrhsvweno
  end function
  subroutine assign_interpolation_controls(dynamics, output)
    type(native_dynamics_controls), intent(in) :: dynamics
    type(native_interpolation_controls), intent(inout) :: output
    output%nvlag = 3
    output%nwlag = 3
    output%ntlag = 3
    output%nspdlag = 3
    output%nsvdlag = 3
    output%nsplthoi = 0
    output%lsvtsm = .false.
    output%lsldp_rk = .false.
    output%lrhs_curv = .false.
    output%ladvf = .false.
    output%l2tlff = .false.
    output%lsldp_curv = .true.
    output%lsldp_xyz = .true.
    output%lsldp_save = .true.
    output%lslhdheat = .true.
    output%lvweno_t = dynamics%lrhsvweno
    output%nsldimk = 1 + 2*merge(1, 0, dynamics%l3dturb)
  end subroutine
  logical function read_operational_controls(text, lmascor, nitmp) result(valid)
    character(*), intent(in) :: text
    logical, intent(out) :: lmascor
    integer(int32), intent(out) :: nitmp
    integer :: cursor, first, last, key, n, i, digit
    integer(int64) :: number
    logical :: parsed, value
    valid = .false.
    lmascor = .false.
    nitmp = 3
    n = len(text)
    if (n < 1 .or. n > 262144) return
    cursor = find_physics_group(text, 'NAMDYN', .false.)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        valid = .true.
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .false.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first .or. cursor > n) return
      key = 0
      if (physics_fold_equal(text(first:last), 'LMASCOR')) key = 1
      if (physics_fold_equal(text(first:last), 'NITMP')) key = 2
      if (key == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor)) .or. index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first .or. cursor > n) return
      if (key == 1) then
        call parse_physics_boolean(text(first:last), value, parsed)
        if (.not. parsed) return
        lmascor = value
      else
        i = first
        if (text(i:i) == '+') i = i + 1
        if (i > last) return
        number = 0
        do while (i <= last)
          digit = iachar(text(i:i)) - 48
          if (digit < 0 .or. digit > 9) return
          if (number > (2147483647_int64 - digit)/10_int64) return
          number = number*10 + digit
          i = i + 1
        end do
        if (number /= 3) return
        nitmp = 3
      end if
    end do
  end function

  logical function fresh_interpolation_state(state) result(fresh)
    type(native_interpolation_state), intent(in) :: state
    fresh = .false.
    if (state%nslgroup /= 0) return
    if (allocated(state%nslsta)) return
    if (allocated(state%nslonl)) return
    if (allocated(state%nsloff)) return
    if (allocated(state%nslptswest)) return
    if (allocated(state%nslptseast)) return
    if (allocated(state%nslext)) return
    if (allocated(state%lcomplat)) return
    if (allocated(state%nlatglo)) return
    if (allocated(state%dist1gp)) return
    if (allocated(state%nslsendpos)) return
    if (allocated(state%nslrecvpos)) return
    if (allocated(state%nslsendptr)) return
    if (allocated(state%nslrecvptr)) return
    if (allocated(state%nslcomm)) return
    if (allocated(state%lslcomm)) return
    if (state%naslb1 /= 0) return
    if (state%naslb1_true /= 0) return
    if (state%nslpad /= 0) return
    if (state%lslt_arrays_init) return
    if (state%lslondem) return
    if (state%lslondem_active) return
    if (state%nunusedhalo /= 0 .and. state%nunusedhalo /= 999999) return
    if (allocated(state%mask_sl1)) return
    if (allocated(state%mask_sl2)) return
    if (allocated(state%mask_sl2t)) return
    if (allocated(state%mask_sld)) return
    if (state%nslprocs /= 0) return
    if (state%nslrpt /= 0) return
    if (state%nslspt /= 0) return
    if (state%nslwiden /= 0) return
    if (state%nslwides /= 0) return
    if (state%nslwidee /= 0) return
    if (state%nslwidew /= 0) return
    if (state%nslwide /= 0) return
    if (allocated(state%nslmap)) return
    if (allocated(state%nslcore)) return
    if (allocated(state%lslcore)) return
    if (allocated(state%mask_sltot)) return
    if (state%ndglg /= 0) return
    if (state%ndlon /= 0) return
    if (state%ndgsag /= 0) return
    if (state%ndgeng /= 0) return
    if (state%ndgsal /= 0) return
    if (state%ndgenl /= 0) return
    if (state%ndgsah /= 0) return
    if (state%ndgenh /= 0) return
    if (state%ngptot /= 0) return
    if (state%ndguxl /= 0) return
    if (state%ndlung /= 0) return
    if (state%ndluxg /= 0) return
    if (state%ndgung /= 0) return
    if (state%ndguxg /= 0) return
    if (state%ndsur1 /= 0) return
    if (state%ndlsur /= 0) return
    if (state%ndgsur /= 0) return
    if (state%nptrfloff /= 0) return
    if (state%nfrstloff /= 0) return
    if (state%myfrstactlat /= 0) return
    if (state%mylstactlat /= 0) return
    if (allocated(state%nloeng)) return
    if (state%cver /= 'XX' .and. state%cver /= achar(0)//achar(0)) return
    if (transfer(state%distunusedhalo, 0_int64) /= 0_int64 .and. &
        transfer(state%distunusedhalo, 0_int64) /= transfer(999999.0_real64, 0_int64)) return
    fresh = .true.
  end function
end module forecast_model_interpolation_setup
