!> Set the selected SUPHY1 soil, vegetation, snow and ozone parameters.
module surface_exchange_parameter_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use yomphy1, only: tphy1
  use yomvdoz, only: tvdoz
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_surface_exchange_parameters, set_surface_exchange_parameters_raw
contains
  ! The caller establishes nearest-even rounding and gradual underflow once.
  ! This native child does not probe or change that floating-point mode.
  !> Admit both source records and complete the selected SUPHY1 stage.
  !! CONSTANTS is the readonly produced physical-constant record. PHYSICAL
  !! is native TPHY1 INOUT; OZONE is native TVDOZ INOUT. The two complete
  !! outputs are separate from each other, TEXT and CONSTANTS. TEXT has
  !! 1:262144 characters with empty first NAMPHY1 and NAMVDOZ groups.
  !! Return 0 on success or 2 before mutation on unsupported input.
  !! No owner is allocated. All source-unwritten padding is preserved.
  integer(int32) function initialize_surface_exchange_parameters(text, constants, physical, ozone) result(status)
    character(len=*), intent(in), target :: text
    type(forecast_physical_constants), intent(in), target :: constants
    type(tphy1), intent(inout), target :: physical
    type(tvdoz), intent(inout), target :: ozone
    integer(c_intptr_t) :: physical_address, ozone_address, text_address, constant_address
    integer(int64) :: physical_bytes, ozone_bytes, text_bytes, constant_bytes
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (constants%initialized /= 1) return
    physical_address = transfer(c_loc(physical), 0_c_intptr_t)
    ozone_address = transfer(c_loc(ozone), 0_c_intptr_t)
    text_address = transfer(c_loc(text), 0_c_intptr_t)
    constant_address = transfer(c_loc(constants), 0_c_intptr_t)
    physical_bytes = storage_size(physical, kind=int64)/8_int64
    ozone_bytes = storage_size(ozone, kind=int64)/8_int64
    text_bytes = int(len(text), int64)
    constant_bytes = storage_size(constants, kind=int64)/8_int64
    if (.not. disjoint(physical_address, physical_bytes, ozone_address, ozone_bytes)) return
    if (.not. disjoint(physical_address, physical_bytes, text_address, text_bytes)) return
    if (.not. disjoint(physical_address, physical_bytes, constant_address, constant_bytes)) return
    if (.not. disjoint(ozone_address, ozone_bytes, text_address, text_bytes)) return
    if (.not. disjoint(ozone_address, ozone_bytes, constant_address, constant_bytes)) return
    if (require_empty_physics_group(text, 'NAMPHY1') /= 0_int32) return
    if (require_empty_physics_group(text, 'NAMVDOZ') /= 0_int32) return
    call set_surface_exchange_parameters_raw(constants, physical, ozone)
    status = 0_int32
  end function initialize_surface_exchange_parameters

  !> Store the source parameters and separately rounded live calculations.
  !! CONSTANTS is IN. PHYSICAL and OZONE are native INOUT records. The
  !! parent must admit their full shapes, separation and floating mode.
  !! Soil coefficients SODELX(0:9) are dimensionless. Gravity is in m/s**2,
  !! day length in seconds and ice heat capacity in J/(kg K). The source
  !! empirical coefficients retain their original values and units.
  !! Literal groups stay on the two sides of each source arithmetic stage.
  subroutine set_surface_exchange_parameters_raw(constants, physical, ozone)
    type(forecast_physical_constants), intent(in) :: constants
    type(tphy1), intent(inout) :: physical
    type(tvdoz), intent(inout) :: ozone
    real(real64), volatile :: one, two, coefficient, thousand
    real(real64) :: value
    integer :: layer
    one = 1.0_real64
    two = 2.0_real64
    coefficient = transfer(int(z'4001C28F5C28F5C3', int64), 0.0_real64)
    thousand = 1000.0_real64
    physical%alcrin = transfer(int(z'3FE6666666666666', int64), 0.0_real64)
    physical%alrcn1 = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    physical%alrcn2 = transfer(int(z'3F647AE147AE147B', int64), 0.0_real64)
    physical%emcrin = transfer(int(z'3FEF5C28F5C28F5C', int64), 0.0_real64)
    physical%wcrin = transfer(int(z'4024000000000000', int64), 0.0_real64)
    physical%tmergl = transfer(int(z'4070F3AE147AE148', int64), 0.0_real64)
    physical%nchsp = int(z'00000000', int32)
    physical%ntvgla = int(z'00000002', int32)
    physical%ntvmer = int(z'00000001', int32)
    physical%rd2gla = transfer(int(z'4020000000000000', int64), 0.0_real64)
    physical%rd2mer = transfer(int(z'4020000000000000', int64), 0.0_real64)
    physical%albgla = transfer(int(z'3FE4CCCCCCCCCCCD', int64), 0.0_real64)
    physical%albmer = transfer(int(z'3FB1EB851EB851EC', int64), 0.0_real64)
    physical%albmed = transfer(int(z'3FAEB851EB851EB8', int64), 0.0_real64)
    physical%emmgla = transfer(int(z'3FEF0A3D70A3D70A', int64), 0.0_real64)
    physical%emmmer = transfer(int(z'3FEEB851EB851EB8', int64), 0.0_real64)
    physical%rz0gla = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    physical%rz0mer = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    physical%rzhz0g = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    physical%rzhz0m = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    physical%hsol = transfer(int(z'3EE4F8B588E368F1', int64), 0.0_real64)
    physical%hsolit0 = transfer(int(z'3FD6666666666666', int64), 0.0_real64)
    physical%hsoliwr = transfer(int(z'4018000000000000', int64), 0.0_real64)
    physical%rtiner = transfer(int(z'4014000000000000', int64), 0.0_real64)
    physical%wpmx = transfer(int(z'4059000000000000', int64), 0.0_real64)
    physical%wsmx = transfer(int(z'4034000000000000', int64), 0.0_real64)
    value = two*constants%rpi
    value = one + value
    value = sqrt(value)
    value = one/value
    physical%sodelx(0) = value
    do layer = 1, 9
      value = value*two
      value = value*constants%rpi
      physical%sodelx(layer) = value
    end do
    physical%omtpro = transfer(int(z'0000000000000000', int64), 0.0_real64)
    physical%omwpro = transfer(int(z'0000000000000000', int64), 0.0_real64)
    physical%ea = transfer(int(z'BFE147AE147AE148', int64), 0.0_real64)
    physical%ga = transfer(int(z'3FE76FFC115DF655', int64), 0.0_real64)
    physical%g1b = transfer(int(z'3FC189374BC6A7F0', int64), 0.0_real64)
    physical%g2b = transfer(int(z'400C000000000000', int64), 0.0_real64)
    physical%g1p = transfer(int(z'3FC126E978D4FDF4', int64), 0.0_real64)
    physical%g2p = transfer(int(z'400B333333333333', int64), 0.0_real64)
    physical%gc1 = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    physical%gc2 = transfer(int(z'4024000000000000', int64), 0.0_real64)
    physical%gc3 = transfer(int(z'4020000000000000', int64), 0.0_real64)
    physical%gconv = transfer(int(z'408F400000000000', int64), 0.0_real64)
    physical%g1wsat = transfer(int(z'BF51B1D92B7FE08B', int64), 0.0_real64)
    physical%g2wsat = transfer(int(z'3FDFA2C669057D18', int64), 0.0_real64)
    physical%ewfc = transfer(int(z'3FD6666666666666', int64), 0.0_real64)
    physical%gwfc = transfer(int(z'3FB6CBC3B85114C6', int64), 0.0_real64)
    physical%ewwilt = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    physical%gwwilt = transfer(int(z'3FA30340FD2051AF', int64), 0.0_real64)
    physical%ec2ref = transfer(int(z'BFEE666666666666', int64), 0.0_real64)
    physical%gc2ref = transfer(int(z'402BA3D70A3D70A4', int64), 0.0_real64)
    physical%g1cgsat = transfer(int(z'BE50B81FB730EED0', int64), 0.0_real64)
    physical%g2cgsat = transfer(int(z'BE4EF1FB350B13CB', int64), 0.0_real64)
    physical%g3cgsat = transfer(int(z'3ED3B8EAA5CF54B6', int64), 0.0_real64)
    physical%g1c1sat = transfer(int(z'3F76DB0DD82FD75E', int64), 0.0_real64)
    physical%g2c1sat = transfer(int(z'3FB5BAB21815A07B', int64), 0.0_real64)
    physical%gc31 = transfer(int(z'40154F5C28F5C28F', int64), 0.0_real64)
    physical%gc32 = transfer(int(z'BFF0B020C49BA5E3', int64), 0.0_real64)
    physical%rd1 = transfer(int(z'3F847AE147AE147B', int64), 0.0_real64)
    physical%rc1max = transfer(int(z'407F400000000000', int64), 0.0_real64)
    physical%rctgla = transfer(int(z'3ED711947CFA26A2', int64), 0.0_real64)
    physical%rcgmax = transfer(int(z'3EE0C6F7A0B5ED8D', int64), 0.0_real64)
    physical%limc = .true.
    physical%limw = .true.
    physical%gf1 = transfer(int(z'3FE199999999999A', int64), 0.0_real64)
    physical%gwlex = transfer(int(z'3FE5555555555555', int64), 0.0_real64)
    physical%gwlmx = transfer(int(z'3FC999999999999A', int64), 0.0_real64)
    physical%rsmax = transfer(int(z'40B3880000000000', int64), 0.0_real64)
    physical%gf3 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    physical%gf4 = transfer(int(z'3F5A36E2EB1C432D', int64), 0.0_real64)
    physical%rctveg = transfer(int(z'3EE0C6F7A0B5ED8D', int64), 0.0_real64)
    physical%rgl = transfer(int(z'4059000000000000', int64), 0.0_real64)
    physical%tref4 = transfer(int(z'4072A00000000000', int64), 0.0_real64)
    physical%gf3(4) = transfer(int(z'4044000000000000', int64), 0.0_real64)
    physical%rgl(4) = transfer(int(z'403E000000000000', int64), 0.0_real64)
    physical%gcz0h(0, 1) = transfer(int(z'401E000000000000', int64), 0.0_real64)
    physical%gcz0h(1, 1) = transfer(int(z'40031F7A4E7AB756', int64), 0.0_real64)
    physical%gcz0h(2, 1) = transfer(int(z'BFD24B09E98DCDB3', int64), 0.0_real64)
    physical%gcz0h(3, 1) = transfer(int(z'3F85FEDA66128390', int64), 0.0_real64)
    physical%gcz0h(0, 2) = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    physical%gcz0h(1, 2) = transfer(int(z'BFB1FDDEBD9018E7', int64), 0.0_real64)
    physical%gcz0h(2, 2) = transfer(int(z'3F84F3775B813016', int64), 0.0_real64)
    physical%gcz0h(3, 2) = transfer(int(z'BF45F45E0B4E11DC', int64), 0.0_real64)
    physical%gcz0h(0, 3) = transfer(int(z'4014000000000000', int64), 0.0_real64)
    physical%gcz0h(1, 3) = transfer(int(z'40120CFBFC6540CC', int64), 0.0_real64)
    physical%gcz0h(2, 3) = transfer(int(z'3FD5C486AD2DCB14', int64), 0.0_real64)
    physical%gcz0h(3, 3) = transfer(int(z'BFAB4A2339C0EBEE', int64), 0.0_real64)
    physical%gcz0h(0, 4) = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    physical%gcz0h(1, 4) = transfer(int(z'BFB81E2584F4C6E7', int64), 0.0_real64)
    physical%gcz0h(2, 4) = transfer(int(z'3F8DF6555C52E72E', int64), 0.0_real64)
    physical%gcz0h(3, 4) = transfer(int(z'BF50385C67DFE32A', int64), 0.0_real64)
    physical%albmax = transfer(int(z'3FEB333333333333', int64), 0.0_real64)
    physical%albmin = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    physical%rhomax = transfer(int(z'3FD3333333333333', int64), 0.0_real64)
    physical%rhomin = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    physical%toexp = transfer(int(z'3EC74D3B7BA75827', int64), 0.0_real64)
    physical%tolin = transfer(int(z'3E78DAEA1D7F4CF7', int64), 0.0_real64)
    physical%wcrinc = transfer(int(z'4051800000000000', int64), 0.0_real64)
    physical%wcring = transfer(int(z'4024000000000000', int64), 0.0_real64)
    physical%wnew = transfer(int(z'4024000000000000', int64), 0.0_real64)
    physical%xcrinr = one/constants%rg
    physical%xcrinv = transfer(int(z'40C3880000000000', int64), 0.0_real64)
    value = coefficient*constants%rcs
    value = value*constants%rday
    value = value*thousand
    physical%gsnc1 = constants%rpi/value
    physical%gsnc2 = transfer(int(z'4007147AE147AE14', int64), 0.0_real64)
    physical%lc1vap = .true.
    physical%gtsvap = transfer(int(z'0000000000000000', int64), 0.0_real64)
    physical%gc1s1 = transfer(int(z'3FF30A3D70A3D70A', int64), 0.0_real64)
    physical%gc1s2 = transfer(int(z'C0145C28F5C28F5C', int64), 0.0_real64)
    physical%gc1s3 = transfer(int(z'C0624CCCCCCCCCCD', int64), 0.0_real64)
    physical%gc1s4 = transfer(int(z'409BE80000000000', int64), 0.0_real64)
    physical%gc1y1 = transfer(int(z'4024000000000000', int64), 0.0_real64)
    physical%gvegmx = transfer(int(z'4014000000000000', int64), 0.0_real64)
    physical%glaimx = transfer(int(z'403E000000000000', int64), 0.0_real64)
    physical%gneimx = transfer(int(z'3FFCCCCCCCCCCCCD', int64), 0.0_real64)
    physical%gwpimx = transfer(int(z'4062C00000000000', int64), 0.0_real64)
    physical%gcgel = transfer(int(z'3EFF75104D551D69', int64), 0.0_real64)
    physical%gcgels = transfer(int(z'3F0A36E2EB1C432D', int64), 0.0_real64)
    physical%gvegmxs = transfer(int(z'4014000000000000', int64), 0.0_real64)
    physical%glaimxs = transfer(int(z'403E000000000000', int64), 0.0_real64)
    physical%gneimxs = transfer(int(z'3FFCCCCCCCCCCCCD', int64), 0.0_real64)
    ozone%lrdifoz = .false.
    ozone%lrdepoz = .false.
    ozone%voznj = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    ozone%vozhs = transfer(int(z'3EE845C8A0CE5129', int64), 0.0_real64)
    ozone%vdhjs = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdhjh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdhns = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdhnh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdpjs = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdpjh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdpns = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdpnh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdejs = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdejh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdens = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdenh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdajs = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdajh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdans = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdanh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdnjs = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdnjh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdnns = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    ozone%vdnnh = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    physical%alb1 = transfer(int(z'3FEBD70A3D70A3D7', int64), 0.0_real64)
    physical%alb2 = transfer(int(z'3FEAE147AE147AE1', int64), 0.0_real64)
    physical%rlaimx = transfer(int(z'401C000000000000', int64), 0.0_real64)
    physical%rlai = transfer(int(z'4008000000000000', int64), 0.0_real64)
    physical%lalbmerclim = .false.
    physical%lcls_hs = .false.
    physical%acls_hs = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
  end subroutine set_surface_exchange_parameters_raw
  logical function disjoint(left, left_bytes, right, right_bytes) result(valid)
    integer(c_intptr_t), intent(in) :: left, right
    integer(int64), intent(in) :: left_bytes, right_bytes
    valid = .false.
    if (left < 0_c_intptr_t .or. right < 0_c_intptr_t .or. left_bytes < 0_int64 .or. right_bytes < 0_int64) return
    if (left > huge(left) - left_bytes .or. right > huge(right) - right_bytes) return
    valid = left + left_bytes <= right .or. right + right_bytes <= left
  end function
end module surface_exchange_parameter_setup_port
