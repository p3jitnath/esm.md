!> Set the selected atmospheric exchange, cloud and convection parameters.
!! This is the generated SUPHY0 calculation, with native TPHY0 and TPHY.
module atmospheric_physics_parameter_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use yomphy0, only: tphy0
  use yomphy, only: tphy
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_atmospheric_physics_parameters
  public :: apply_atmospheric_parameter_literals, apply_atmospheric_parameter_arithmetic
contains
  ! The caller establishes nearest-even rounding and gradual underflow once.
  ! This native child does not probe or change that floating-point mode.
  !> Apply complete selected SUPHY0 after admitting its readonly inputs.
  !! OUTPUT is a caller-owned TPHY0 record, changed only at source-written
  !! members. PHYSICS is readonly TPHY. ROTATION_RATE is in radians/second,
  !! finite with magnitude at most1, including either signed zero.
  !! GRID_LENGTH is in metres, in1:100000000. LSIMPH must be false and
  !! LECMWF true. The source alternative-physics switches must be false.
  !! TEXT has1:262144characters and its first NAMPHY0 group must be empty.
  !! Complete OUTPUT storage is separate from all readonly arguments.
  !! Return0 on success or2 without mutation on unsupported input.
  !! No owner is allocated; source-unwritten values and padding are kept.
  integer(int32) function initialize_atmospheric_physics_parameters(text, output, physics, &
                                                                    rotation_rate, grid_length, lsimph, lecmwf) result(status)
    character(len=*), intent(in), target :: text
    type(tphy0), intent(inout), target :: output
    type(tphy), intent(in), target :: physics
    real(real64), intent(in), target :: rotation_rate, grid_length
    logical, intent(in), target :: lsimph, lecmwf
    integer(c_intptr_t) :: address, inputs(6)
    integer(int64) :: lengths(6), bytes
    integer :: index
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (lsimph .or. .not. lecmwf) return
    if (physics%lcoefktke .or. physics%lmphys) return
    if (.not. canonical_logical(physics%lcondwt) .or. .not. canonical_logical(physics%lprocld)) return
    if (.not. canonical_logical(physics%lnebco) .or. .not. canonical_logical(physics%lnebr)) return
    if (.not. canonical_logical(physics%lnebgr) .or. .not. canonical_logical(physics%lect)) return
    if (.not. canonical_logical(physics%lcvrav3)) return
    if (iand(transfer(rotation_rate, 0_int64), int(z'7FFFFFFFFFFFFFFF', int64)) > int(z'3FF0000000000000', int64)) return
    if (transfer(grid_length, 0_int64) < int(z'3FF0000000000000', int64)) return
    if (transfer(grid_length, 0_int64) > int(z'4197D78400000000', int64)) return
    address = transfer(c_loc(output), 0_c_intptr_t)
    bytes = storage_size(output, kind=int64)/8_int64
    inputs = [transfer(c_loc(text), 0_c_intptr_t), transfer(c_loc(physics), 0_c_intptr_t), &
              transfer(c_loc(rotation_rate), 0_c_intptr_t), transfer(c_loc(grid_length), 0_c_intptr_t), &
              transfer(c_loc(lsimph), 0_c_intptr_t), transfer(c_loc(lecmwf), 0_c_intptr_t)]
    lengths = [int(len(text), int64), storage_size(physics, kind=int64)/8_int64, 8_int64, 8_int64, &
               int(storage_size(lsimph)/8, int64), int(storage_size(lecmwf)/8, int64)]
    do index = 1, 6
      if (.not. disjoint(address, bytes, inputs(index), lengths(index))) return
    end do
    if (require_empty_physics_group(text, 'NAMPHY0') /= 0_int32) return
    call apply_atmospheric_parameter_literals(output)
    call apply_atmospheric_parameter_arithmetic(output, physics, rotation_rate, grid_length)
    status = 0_int32
  end function initialize_atmospheric_physics_parameters

  !> Store the source literal values in source order.
  !! OUTPUT is native TPHY0 INOUT. It has no new owner. Literal words
  !! retain the source kind, including literals first rounded to real32.
  !! The enclosing parent must admit the complete selected interface.
  subroutine apply_atmospheric_parameter_literals(output)
    type(tphy0), intent(inout) :: output
    output%a0ml_au = transfer(int(z'4012000000000000', int64), 0.0_real64)
    output%a0ml_at = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%a0ml_bu = transfer(int(z'4008000000000000', int64), 0.0_real64)
    output%a0ml_bt = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
    output%aercs1 = transfer(int(z'3FD172474538EF35', int64), 0.0_real64)
    output%aercs3 = transfer(int(z'BFDB212D77318FC5', int64), 0.0_real64)
    output%aercs5 = transfer(int(z'3FD7020C49BA5E35', int64), 0.0_real64)
    output%almav = transfer(int(z'4072C00000000000', int64), 0.0_real64)
    output%bedifv = transfer(int(z'3FA999999999999A', int64), 0.0_real64)
    output%ecmnp = transfer(int(z'40A7700000000000', int64), 0.0_real64)
    output%edb = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%edc = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%edd = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%edk = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%efb_az0 = transfer(int(z'3FC999999999999A', int64), 0.0_real64)
    output%efb_ur = transfer(int(z'3FDD16872B020C4A', int64), 0.0_real64)
    output%etacut = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%evap = transfer(int(z'41524F8000000000', int64), 0.0_real64)
    output%font = transfer(int(z'40D7700000000000', int64), 0.0_real64)
    output%galp = transfer(int(z'3FE0F5C28F5C28F6', int64), 0.0_real64)
    output%gcismin = transfer(int(z'3F11904B3C3E74B0', int64), 0.0_real64)
    output%gevavf = transfer(int(z'3F11904B3C3E74B0', int64), 0.0_real64)
    output%gccsv = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvads = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
    output%gcvalfa = transfer(int(z'3F0797CC39FFD60F', int64), 0.0_real64)
    output%gcvbeta = transfer(int(z'3FC999999999999A', int64), 0.0_real64)
    output%gcvimpt = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvmlt = transfer(int(z'3F24F8B588E368F1', int64), 0.0_real64)
    output%gcvnu = transfer(int(z'3EFA36E2EB1C432D', int64), 0.0_real64)
    output%gcvpsi = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%gcvpsie = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gddeva = transfer(int(z'3FD0000000000000', int64), 0.0_real64)
    output%gddsde = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%gpblhk0 = transfer(int(z'3FD0000000000000', int64), 0.0_real64)
    output%gpblhra = transfer(int(z'4010000000000000', int64), 0.0_real64)
    output%grcvpp = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gwdamp = transfer(int(z'3FE3333333333333', int64), 0.0_real64)
    output%gwdbc = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%gwdcco = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gwdcd = transfer(int(z'4018000000000000', int64), 0.0_real64)
    output%gwdlt = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gwdse = transfer(int(z'3F6CAC083126E979', int64), 0.0_real64)
    output%gwdprof = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gwdvali = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%hobst = transfer(int(z'4008000000000000', int64), 0.0_real64)
    output%hucoe = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%hutil = transfer(int(z'3FFCCCCCCCCCCCCD', int64), 0.0_real64)
    output%hutil1 = transfer(int(z'BFE3333333333333', int64), 0.0_real64)
    output%hutil2 = transfer(int(z'3FF199999999999A', int64), 0.0_real64)
    output%npclo1 = int(z'00000001', int32)
    output%npclo2 = int(z'00000001', int32)
    output%qssc = transfer(int(z'4099000000000000', int64), 0.0_real64)
    output%qsmodc = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%qsmin = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    output%qsnebc = transfer(int(z'40D9640000000000', int64), 0.0_real64)
    output%qsnebs = transfer(int(z'3FE6666666666666', int64), 0.0_real64)
    output%qssusc = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%qssuss = transfer(int(z'3FD0000000000000', int64), 0.0_real64)
    output%qssusv = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%qsusxc = transfer(int(z'3F014D2F5DBB9CFA', int64), 0.0_real64)
    output%qsusxs = transfer(int(z'3F014D2F5DBB9CFA', int64), 0.0_real64)
    output%rdecrd = transfer(int(z'40D3880000000000', int64), 0.0_real64)
    output%rdecrd1 = transfer(int(z'40C3880000000000', int64), 0.0_real64)
    output%rdecrd2 = transfer(int(z'40D3880000000000', int64), 0.0_real64)
    output%rdecrd3 = transfer(int(z'3FD3333333333333', int64), 0.0_real64)
    output%rdecrd4 = transfer(int(z'3FDCCCCCCCCCCCCD', int64), 0.0_real64)
    output%rdecrdred = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rgelsfon = transfer(int(z'3F8999999999999A', int64), 0.0_real64)
    output%revapn = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rphi0 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rphir = transfer(int(z'409B580000000000', int64), 0.0_real64)
    output%qxral = transfer(int(z'4060400000000000', int64), 0.0_real64)
    output%qxral_adj = transfer(int(z'4060400000000000', int64), 0.0_real64)
    output%qxrcdil = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%qxrdel = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%qxrhx = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%qxrr = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%qxrtgh = transfer(int(z'400C000000000000', int64), 0.0_real64)
    output%rcin = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rcvevap = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%revgsl = transfer(int(z'4054000000000000', int64), 0.0_real64)
    output%refb_1 = transfer(int(z'4022000000000000', int64), 0.0_real64)
    output%refb_2 = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%refb_3 = transfer(int(z'C026000000000000', int64), 0.0_real64)
    output%rflchce = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rtcape = transfer(int(z'40C5180000000000', int64), 0.0_real64)
    output%sco = transfer(int(z'C034000000000000', int64), 0.0_real64)
    output%sensl = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%snnbco = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%spnbco = transfer(int(z'40A7700000000000', int64), 0.0_real64)
    output%sxnbco = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%tca = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%tct = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    output%tcw = transfer(int(z'3F4A36E2EB1C432D', int64), 0.0_real64)
    output%tentr = transfer(int(z'3EC4F8B588E368F1', int64), 0.0_real64)
    output%tentrx = transfer(int(z'3F14F8B588E368F1', int64), 0.0_real64)
    output%tddgp = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
    output%tudgp = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
    output%turb = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%tvf = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%tym(1) = transfer(int(z'3FED70A3D70A3D71', int64), 0.0_real64)
    output%tym(2) = transfer(int(z'3FE7AE147AE147AE', int64), 0.0_real64)
    output%tym(3) = transfer(int(z'403099999999999A', int64), 0.0_real64)
    output%tym(4) = transfer(int(z'4024333333333333', int64), 0.0_real64)
    output%tym(5) = transfer(int(z'3FB47AE147AE147B', int64), 0.0_real64)
    output%uhdifv = transfer(int(z'3F4A36E2EB1C432D', int64), 0.0_real64)
    output%usdmlt = transfer(int(z'40C86A0000000000', int64), 0.0_real64)
    output%usuprc = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usuric = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%usurid = transfer(int(z'3FA1EB851EB851EC', int64), 0.0_real64)
    output%usuride = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%usurice = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%usuricl = transfer(int(z'4010000000000000', int64), 0.0_real64)
    output%utilgust = transfer(int(z'3FC0000000000000', int64), 0.0_real64)
    output%vchrnk = transfer(int(z'3F95810624DD2F1B', int64), 0.0_real64)
    output%vkarmn = transfer(int(z'3FD999999999999A', int64), 0.0_real64)
    output%vz0cm = transfer(int(z'3F23A92A30553261', int64), 0.0_real64)
    output%vziustar0 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xnbmax = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%ahclpv = transfer(int(z'408F400000000000', int64), 0.0_real64)
    output%ricrlm = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%rrgamma = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
    output%rrscale = transfer(int(z'3F1E2584F4C6E6DA', int64), 0.0_real64)
    output%xblm = transfer(int(z'401A000000000000', int64), 0.0_real64)
    output%xklm = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%xmaxlm = transfer(int(z'40A7700000000000', int64), 0.0_real64)
    output%xminlm = transfer(int(z'407F400000000000', int64), 0.0_real64)
    output%xwsalm = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%xwsblm = transfer(int(z'401C000000000000', int64), 0.0_real64)
    output%rnegat = transfer(int(z'BF12599ED7C6FBD2', int64), 0.0_real64)
    output%rnlcurv = transfer(int(z'40F1170000000000', int64), 0.0_real64)
    output%wmxov = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%trentrv = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%tentrvl = transfer(int(z'BFF0000000000000', int64), 0.0_real64)
    output%gcvgamma = transfer(int(z'4034000000000000', int64), 0.0_real64)
    output%lkesc = .false.
    output%rdtfac = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%rdtfac = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rautefr = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%rrautcs = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rautefs = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%rautsbet = transfer(int(z'3F9999999999999A', int64), 0.0_real64)
    output%rnintr = transfer(int(z'415E848000000000', int64), 0.0_real64)
    output%rnints = transfer(int(z'413E848000000000', int64), 0.0_real64)
    output%rqlcr = transfer(int(z'3F2A36E2EB1C432D', int64), 0.0_real64)
    output%rspcrr = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rqicrmax = transfer(int(z'3EFF75104D551D69', int64), 0.0_real64)
    output%rqicrmin = transfer(int(z'3E8AD7F29ABCAF48', int64), 0.0_real64)
    output%rqlcv = transfer(int(z'3F2A36E2EB1C432D', int64), 0.0_real64)
    output%rqicvmax = transfer(int(z'3EFF75104D551D69', int64), 0.0_real64)
    output%rqicvmin = transfer(int(z'3E8AD7F29ABCAF48', int64), 0.0_real64)
    output%rqicrt1 = transfer(int(z'C054000000000000', int64), 0.0_real64)
    output%rqicrt2 = transfer(int(z'403E000000000000', int64), 0.0_real64)
    output%rqicrsn = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%rqcrns = transfer(int(z'3F9EB851EB851EB8', int64), 0.0_real64)
    output%raccef = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%raggef = transfer(int(z'3FC999999999999A', int64), 0.0_real64)
    output%rrimef = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%revasx = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rhcrit1 = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%rhcrit2 = transfer(int(z'3FED1EB851EB851F', int64), 0.0_real64)
    output%retamin = transfer(int(z'3FD999999999999A', int64), 0.0_real64)
    output%rfacnsm = transfer(int(z'3FF6666666666666', int64), 0.0_real64)
    output%tfvl = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%tfvi = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%tfvr = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%tfvs = transfer(int(z'3FE3333333333333', int64), 0.0_real64)
    output%grhcmod = transfer(int(z'3FD3333333333333', int64), 0.0_real64)
    output%rhcexpdx = transfer(int(z'3FD3333333333333', int64), 0.0_real64)
    output%adjtau = transfer(int(z'408C200000000000', int64), 0.0_real64)
    output%rdphic = transfer(int(z'40C3880000000000', int64), 0.0_real64)
    output%rwbf1 = transfer(int(z'4072C00000000000', int64), 0.0_real64)
    output%rwbf2 = transfer(int(z'4010000000000000', int64), 0.0_real64)
    output%sclespr = transfer(int(z'410E460000000000', int64), 0.0_real64)
    output%sclesps = transfer(int(z'40CE460000000000', int64), 0.0_real64)
    output%hucred = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%hucredra = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fsprain = transfer(int(z'402ACCCCCCCCCCCD', int64), 0.0_real64)
    output%effcoll = transfer(int(z'3FB126E978D4FDF4', int64), 0.0_real64)
    output%rsmdnebx = transfer(int(z'3FC999999999999A', int64), 0.0_real64)
    output%rsmdtx = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%nsmtpa = int(z'00000002', int32)
    output%nsmtpb = int(z'00000003', int32)
    output%tudbu = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%tddbu = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%tudfr = transfer(int(z'3F53A92A30553261', int64), 0.0_real64)
    output%tddfr = transfer(int(z'3F43A92A30553261', int64), 0.0_real64)
    output%gcvalmx = transfer(int(z'3FEE666666666666', int64), 0.0_real64)
    output%rmulacvg = transfer(int(z'4039000000000000', int64), 0.0_real64)
    output%gcvachi = transfer(int(z'41CDCD6500000000', int64), 0.0_real64)
    output%gcvbee = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcveex = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcvtaude = transfer(int(z'408C200000000000', int64), 0.0_real64)
    output%ecmnpi = transfer(int(z'40A7700000000000', int64), 0.0_real64)
    output%gpeiphi = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%genvsrh = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gpetau = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gpefdc = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%grrmina = transfer(int(z'3EE4F8B588E368F1', int64), 0.0_real64)
    output%gddbeta = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%gdddp = transfer(int(z'40C3880000000000', int64), 0.0_real64)
    output%gddfxm = transfer(int(z'40F86A0000000000', int64), 0.0_real64)
    output%gddevf = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%gddwpf = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%tentrd = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    output%gddalbu = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gddfrac = transfer(int(z'3FD51EB860000000', int64), 0.0_real64)
    output%gddendymx = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    output%gddfp(1) = transfer(int(z'3FA6848BEB5B2D4D', int64), 0.0_real64)
    output%gddfp(2) = transfer(int(z'3FE8000000000000', int64), 0.0_real64)
    output%gddfp(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gddtausig = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gddfrevs = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%gddinhom = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%gcvalbu = transfer(int(z'3FECCCCCCCCCCCCD', int64), 0.0_real64)
    output%gcvendy1 = transfer(int(z'3E45798EE2308C3A', int64), 0.0_real64)
    output%gcvendy2 = transfer(int(z'3F0A36E2EB1C432D', int64), 0.0_real64)
    output%gcvendymx = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    output%gcvidpbas = transfer(int(z'3F689374BC6A7EFA', int64), 0.0_real64)
    output%gcvtausig = transfer(int(z'BFF0000000000000', int64), 0.0_real64)
    output%gcvkskv = transfer(int(z'4008000000000000', int64), 0.0_real64)
    output%gcvcatau = transfer(int(z'408F400000000000', int64), 0.0_real64)
    output%gcathrcap = transfer(int(z'4069000000000000', int64), 0.0_real64)
    output%gcathrmoc = transfer(int(z'BFF0000000000000', int64), 0.0_real64)
    output%gcathrcnd = transfer(int(z'BFF0000000000000', int64), 0.0_real64)
    output%gcaomcnd = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gtrgkck9 = transfer(int(z'3FD999999999999A', int64), 0.0_real64)
    output%gtrgdpmix = transfer(int(z'40B7700000000000', int64), 0.0_real64)
    output%gtrgdphimn = transfer(int(z'40DCA70000000000', int64), 0.0_real64)
    output%gtrgpuslmn = transfer(int(z'40DD4C0000000000', int64), 0.0_real64)
    output%gtrgain = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%gtrthrs = transfer(int(z'3FC3333333333333', int64), 0.0_real64)
    output%gtrthck = transfer(int(z'40E86A0000000000', int64), 0.0_real64)
    output%gtrbrc = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%gtrkgain = transfer(int(z'4059000000000000', int64), 0.0_real64)
    output%gtrkthrs = transfer(int(z'3F947AE147AE147B', int64), 0.0_real64)
    output%gtrkthck = transfer(int(z'409F400000000000', int64), 0.0_real64)
    output%lgddd = .false.
    output%lcvnhd = .false.
    output%lcvresdyn = .false.
    output%lcvds = .false.
    output%lcvmicc = .false.
    output%gmukedd = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gnhdtat = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%gnhdsmos = transfer(int(z'408C200000000000', int64), 0.0_real64)
    output%gnhdsmot = transfer(int(z'3FCC28F5C28F5C29', int64), 0.0_real64)
    output%gnhdev = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gnhdtau = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%lcveod = .false.
    output%lgproni1 = .false.
    output%nproni = int(z'00000000', int32)
    output%gproni = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%lgvvex = .false.
    output%ncventr = int(z'00000001', int32)
    output%ncvsig = int(z'00000001', int32)
    output%ncvclos = int(z'00000001', int32)
    output%ncvqli = int(z'00000001', int32)
    output%gcventrn = transfer(int(z'3F1F75104D551D69', int64), 0.0_real64)
    output%gcventrx = transfer(int(z'3F43A92A30553261', int64), 0.0_real64)
    output%gcventr_min = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%thpcmt = transfer(int(z'BFF0000000000000', int64), 0.0_real64)
    output%gaeps = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcvez = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcvtrmin = transfer(int(z'40C3880000000000', int64), 0.0_real64)
    output%lcvfevv = .false.
    output%gcvfevv = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvtexc = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvwexc = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gfsurf = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%lcvnauv = .true.
    output%gcvfrr = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcvpnh = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvorged = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvtaurem = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcloea = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcloeb = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gfrae = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvadet = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvcinc = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gsdmin = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%gchi0 = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gsdmax = transfer(int(z'3F554C985F06F694', int64), 0.0_real64)
    output%galmin = transfer(int(z'3F86872B020C49BA', int64), 0.0_real64)
    output%galmax = transfer(int(z'3F9EB851EB851EB8', int64), 0.0_real64)
    output%gsdamin = transfer(int(z'3F43A92A30553261', int64), 0.0_real64)
    output%gsdamax = transfer(int(z'3F613404EA4A8C15', int64), 0.0_real64)
    output%gexpkd = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%gremin = transfer(int(z'3F847AE147AE147B', int64), 0.0_real64)
    output%gremax = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gshell = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvfner = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvfneo = transfer(int(z'C014000000000000', int64), 0.0_real64)
    output%gcvfnep1 = transfer(int(z'40DD4C0000000000', int64), 0.0_real64)
    output%gcvfnep2 = transfer(int(z'40C3880000000000', int64), 0.0_real64)
    output%grbcc = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%greddi = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%greddl = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%greddr = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gredds = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcvuv = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcheckmv_tmin = transfer(int(z'C069000000000000', int64), 0.0_real64)
    output%gcheckmv_tmax = transfer(int(z'4069000000000000', int64), 0.0_real64)
    output%gcheckmv_qvmin = transfer(int(z'BFB999999999999A', int64), 0.0_real64)
    output%gcheckmv_qvmax = transfer(int(z'3FC999999999999A', int64), 0.0_real64)
    output%gcvre = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%lsbuo = .false.
    output%lcvtadv = .false.
    output%grso = transfer(int(z'4059000000000000', int64), 0.0_real64)
    output%grth = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%grfcs = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gfric = transfer(int(z'3F713404EA4A8C15', int64), 0.0_real64)
    output%guddd = transfer(int(z'3FD0000000000000', int64), 0.0_real64)
    output%gsiga = transfer(int(z'3FECCCCCCCCCCCCD', int64), 0.0_real64)
    output%gnhdsmow = transfer(int(z'409C200000000000', int64), 0.0_real64)
    output%gsinhd = transfer(int(z'409C200000000000', int64), 0.0_real64)
    output%gsinhr = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gdepth = transfer(int(z'4089000000000000', int64), 0.0_real64)
    output%galtau = transfer(int(z'3EF3EC460ED80A18', int64), 0.0_real64)
    output%gkeddre = transfer(int(z'3F46DF3F961804DA', int64), 0.0_real64)
    output%gnhacc = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gtdcl = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%lcvcontau = .true.
    output%lcvimpt = .true.
    output%ladvlim = .true.
    output%lcvuvm = .false.
    output%adoe = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rfrac_entr_n = transfer(int(z'3EE4F8B588E368F1', int64), 0.0_real64)
    output%rfrac_entr_x = transfer(int(z'3F5205BC01A36E2F', int64), 0.0_real64)
    output%gcvturb = transfer(int(z'3F0A36E2EB1C432D', int64), 0.0_real64)
    output%rnebcx = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcvtsmo = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%rkdx = transfer(int(z'3F33A92A30553261', int64), 0.0_real64)
    output%lcapcin = .false.
    output%lcorsedim = .false.
    output%gtopdepth = transfer(int(z'40AF400000000000', int64), 0.0_real64)
    output%nweight = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%ncatau = transfer(int(z'408F400000000000', int64), 0.0_real64)
    output%ncapemax = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%ncvgmax = transfer(int(z'3EB0C6F7A0B5ED8D', int64), 0.0_real64)
    output%adise = transfer(int(z'BFE0000000000000', int64), 0.0_real64)
    output%adisi = transfer(int(z'3FF8000000000000', int64), 0.0_real64)
    output%aecls3 = transfer(int(z'400E000000000000', int64), 0.0_real64)
    output%aecls4 = transfer(int(z'3FD3333333333333', int64), 0.0_real64)
    output%akn = transfer(int(z'3FC020C49BA5E354', int64), 0.0_real64)
    output%ald = transfer(int(z'3FF2E147AE147AE1', int64), 0.0_real64)
    output%alphae = transfer(int(z'400599999999999A', int64), 0.0_real64)
    output%alphat = transfer(int(z'3FF2147AE147AE14', int64), 0.0_real64)
    output%ectmin = transfer(int(z'3EB0C6F7A0B5ED8D', int64), 0.0_real64)
    output%ectmax = transfer(int(z'4059000000000000', int64), 0.0_real64)
    output%udect = transfer(int(z'4014000000000000', int64), 0.0_real64)
    output%ushearm = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    output%upretmin = transfer(int(z'40ED4C0000000000', int64), 0.0_real64)
    output%upretmax = transfer(int(z'40F7CDC000000000', int64), 0.0_real64)
    output%arsch = transfer(int(z'4010000000000000', int64), 0.0_real64)
    output%arscq = transfer(int(z'3FF3333333333333', int64), 0.0_real64)
    output%acbrphim = transfer(int(z'400199999999999A', int64), 0.0_real64)
    output%almave = transfer(int(z'4024000000000000', int64), 0.0_real64)
    output%almavx = transfer(int(z'408F400000000000', int64), 0.0_real64)
    output%ricret = transfer(int(z'3FC8F5C28F5C28F6', int64), 0.0_real64)
    output%gcvhmin = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvomge = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvomgq = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvomgs = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcvomdps = transfer(int(z'409F400000000000', int64), 0.0_real64)
    output%gcvomgsx = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%gcvrhmin = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%gcvrhmax = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gcvomca = transfer(int(z'BFFEB020C49BA5E3', int64), 0.0_real64)
    output%gcvomcc = transfer(int(z'3FF599999999999A', int64), 0.0_real64)
    output%rkfbtau = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rkfbnbx = transfer(int(z'3FD3333333333333', int64), 0.0_real64)
    output%ajbumin = transfer(int(z'3F747AE147AE147B', int64), 0.0_real64)
    output%rcoflm = transfer(int(z'3FB5C28F5C28F5C3', int64), 0.0_real64)
    output%aj1meps = transfer(int(z'3FEFAE147AE147AE', int64), 0.0_real64)
    output%aj1peps = transfer(int(z'4024000000000000', int64), 0.0_real64)
    output%najiter = int(z'0000001E', int32)
    output%agre1 = transfer(int(z'3FC47AE147AE147B', int64), 0.0_real64)
    output%agre2 = transfer(int(z'4059000000000000', int64), 0.0_real64)
    output%agref = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%agrericr = transfer(int(z'4049000000000000', int64), 0.0_real64)
    output%nuptke = transfer(int(z'3FE0A3D70A3D70A4', int64), 0.0_real64)
    output%tkemult = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%c_epsilon = transfer(int(z'3FEBDF3B645A1CAC', int64), 0.0_real64)
    output%etke_ctheta = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%etke_rifc_maf = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%etke_rifc = transfer(int(z'3FC7CED916872B02', int64), 0.0_real64)
    output%etke_r = transfer(int(z'3FD77CED916872B0', int64), 0.0_real64)
    output%etke_lam1 = transfer(int(z'3FBB645A1CAC0831', int64), 0.0_real64)
    output%etke_lam2 = transfer(int(z'3F34F8B588E368F1', int64), 0.0_real64)
    output%etke_lam3 = transfer(int(z'3FB61E4F765FD8AE', int64), 0.0_real64)
    output%etke_lam4 = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%ent_lambda = transfer(int(z'40177AE147AE147B', int64), 0.0_real64)
    output%etke_cg01 = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%etke_cg02 = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%etke_cg03 = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%etke_beta_eps = transfer(int(z'3F947AE147AE147B', int64), 0.0_real64)
    output%etke_gamma_eps = transfer(int(z'3F9EB851EB851EB8', int64), 0.0_real64)
    output%etke_gamd = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%etke_talph = transfer(int(z'4069000000000000', int64), 0.0_real64)
    output%etke_alph0 = transfer(int(z'4059000000000000', int64), 0.0_real64)
    output%etke_entrx = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%etke_entrn = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    output%etke_klm = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%etke_taulm = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%etke_min = transfer(int(z'3E45798EE2308C3A', int64), 0.0_real64)
    output%c3tkefree = transfer(int(z'3FF2F1A9FBE76C8B', int64), 0.0_real64)
    output%alfx = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%alfx_lr = transfer(int(z'3FA47AE147AE147B', int64), 0.0_real64)
    output%alfx_hr = transfer(int(z'3FC3333333333333', int64), 0.0_real64)
    output%gcvresn = transfer(int(z'3EDF34A3A0AE8BC4', int64), 0.0_real64)
    output%gcvresx = transfer(int(z'3F0F75104D551D69', int64), 0.0_real64)
    output%gmirh = transfer(int(z'3FEF5C28F5C28F5C', int64), 0.0_real64)
    output%gcvgaw = transfer(int(z'3FE6666666666666', int64), 0.0_real64)
    output%gcvgax = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%tctc = transfer(int(z'3F40624DD2F1A9FC', int64), 0.0_real64)
    output%tvfc = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%gamap1 = transfer(int(z'3FF8000000000000', int64), 0.0_real64)
    output%rkdn = transfer(int(z'3EFF75104D551D69', int64), 0.0_real64)
    output%vvn = transfer(int(z'C000000000000000', int64), 0.0_real64)
    output%vvx = transfer(int(z'C043000000000000', int64), 0.0_real64)
    output%fentrt = transfer(int(z'4004000000000000', int64), 0.0_real64)
    output%fqlic = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%fnebc = transfer(int(z'401C000000000000', int64), 0.0_real64)
    output%fevapc = transfer(int(z'4010000000000000', int64), 0.0_real64)
    output%rlmlh1 = transfer(int(z'3FD999999999999A', int64), 0.0_real64)
    output%rprth = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rsmoothmelt = transfer(int(z'3FE3333340000000', int64), 0.0_real64)
    output%reflkuo = transfer(int(z'40D1258000000000', int64), 0.0_real64)
    output%reflcape = transfer(int(z'40F5DD6000000000', int64), 0.0_real64)
    output%reflrhc = transfer(int(z'41024F8000000000', int64), 0.0_real64)
  end subroutine apply_atmospheric_parameter_literals

  !> Complete the separately rounded SUPHY0 arithmetic.
  !! OUTPUT is native TPHY0 INOUT after its literal stage. PHYSICS is IN.
  !! ROTATION_RATE and GRID_LENGTH have the parent units and bounds.
  !! Temporary names follow the turbulence equations; each assignment
  !! retains one source operation and its intermediate real64 rounding.
  subroutine apply_atmospheric_parameter_arithmetic(output, physics, rotation_rate, grid_length)
    type(tphy0), intent(inout) :: output
    type(tphy), intent(in) :: physics
    real(real64), intent(in) :: rotation_rate, grid_length
    real(real64), volatile :: one, two, three, four, five, six, eight, ten, fourteen, fifteen, twenty, twentyfive, thirty
    real(real64), volatile :: seventyfive, threehundredseventyfive, quarter, half
    real(real64) :: value, other, sm0, square, root, lambda, sf, common
    logical :: cloud_condition
    one = 1.0_real64; two = 2.0_real64; three = 3.0_real64; four = 4.0_real64
    five = 5.0_real64; six = 6.0_real64; eight = 8.0_real64; ten = 10.0_real64
    fourteen = 14.0_real64; fifteen = 15.0_real64; twenty = 20.0_real64
    twentyfive = 25.0_real64; thirty = 30.0_real64; seventyfive = 75.0_real64
    threehundredseventyfive = 375.0_real64; quarter = 0.25_real64; half = 0.5_real64
    output%rdtfac = one
    if (physics%lcondwt .and. physics%lprocld) output%rdtfac = half
    cloud_condition = (physics%lnebr .or. physics%lnebgr .or. physics%lect) .and. physics%lnebco
    if (physics%lcvrav3 .and. .not. cloud_condition) output%tentrvl = 0.0_real64
    if (rotation_rate == 0.0_real64) then
      output%gpetau = 0.0_real64
    else
      output%gpetau = one/rotation_rate
    end if
    output%ucwstar = one/three
    value = three*output%arsch
    value = value*output%arscq
    output%arsc1 = two/value
    value = three*output%arsch
    value = value*output%arsc1
    output%arsb2 = value/two
    output%sttbmin = sqrt(three)
    output%etke_olam = two/three
    output%etke_lam0 = two/three
    sm0 = output%nuptke*output%nuptke
    sm0 = sm0*sm0
    sm0 = sm0/two
    square = output%c3tkefree*output%c3tkefree
    value = threehundredseventyfive*square
    other = two*output%c3tkefree
    other = square + other
    other = other + one
    value = value*other
    other = sm0*sm0
    value = value*other
    other = square + output%c3tkefree
    other = other - one
    other = twenty*other
    other = other*sm0
    value = value - other
    value = value + one
    root = sqrt(value)
    value = sqrt(five)
    value = value*three
    value = value/four
    value = value*root
    other = thirty*output%c3tkefree
    common = output%c3tkefree + one
    other = other*common
    other = other*sm0
    value = value - other
    lambda = value + quarter
    other = seventyfive*output%c3tkefree
    other = other*common
    other = other*sm0
    value = ten - other
    other = eight*lambda
    sf = value/other
    value = four/fifteen
    output%etke_lam1 = value*lambda
    value = fourteen*lambda
    value = value*sf
    other = five*lambda
    value = value + other
    output%etke_lam3 = value/seventyfive
    value = six*lambda
    value = value*sf
    value = other - value
    output%etke_lam2 = value/twentyfive
    value = output%c_epsilon*output%c3tkefree
    value = value/output%etke_olam
    output%etke_ctheta = value
    output%etke_ka1 = lambda/two
    other = two*output%c3tkefree
    output%etke_ka2 = output%etke_olam/other
    output%etke_ka3 = one
    output%teqk = output%reflkuo/grid_length
    output%teqc = output%reflcape/grid_length
    output%teqh = output%reflrhc/grid_length
  end subroutine apply_atmospheric_parameter_arithmetic

  logical function canonical_logical(value) result(valid)
    logical, intent(in) :: value
    integer(int32) :: word
    word = transfer(value, 0_int32)
    valid = word == 0_int32 .or. word == 1_int32
  end function

  logical function disjoint(left, left_bytes, right, right_bytes) result(valid)
    integer(c_intptr_t), intent(in) :: left, right
    integer(int64), intent(in) :: left_bytes, right_bytes
    valid = .false.
    if (left < 0_c_intptr_t .or. right < 0_c_intptr_t .or. left_bytes < 0_int64 .or. right_bytes < 0_int64) return
    if (left > huge(left) - left_bytes .or. right > huge(right) - right_bytes) return
    valid = left + left_bytes <= right .or. right + right_bytes <= left
  end function
end module atmospheric_physics_parameter_setup_port
