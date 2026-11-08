!> Set the generated legacy radiation coefficients through named records.
!! The declared cloud model has two bands and a linearization temperature
!! of 255.8 kelvin. Empirical coefficient units remain those of the frozen
!! source tables; fractions, mixing ratios and optical fit indices are
!! dimensionless. This module allocates no array and imports no model code.
module legacy_radiation_parameter_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use yomphy3, only: tphy3
  use yomphy, only: tphy
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: declare_legacy_radiation_parameters
  public :: initialize_legacy_radiation_parameters
  public :: set_legacy_radiation_parameters_raw
contains
  !> Set only the two source declaration defaults in a caller-owned record.
  !! OUTPUT is a native TPHY3 INOUT scalar. This function writes N_SPBAND=2
  !! and RTL=255.8 K, retaining every other member and incoming padding.
  !! The compiler owns its layout. A valid typed record is required.
  !! Return 0 on completion; no allocation or library call is needed.
  integer(int32) function declare_legacy_radiation_parameters(output) result(status)
    type(tphy3), intent(inout) :: output
    output%n_spband = 2_int32
    output%rtl = transfer(int(z'406FF9999999999A', int64), 0.0_real64)
    status = 0_int32
  end function

  !> Admit selected SUPHY3 controls, then apply the source-ordered stores.
  !! TEXT is a borrowed scalar character string with 1:262144 characters.
  !! Its first uppercase NAMPHY3 group must be empty. OUTPUT is a stable
  !! caller-owned native TPHY3 INOUT record with the two declaration defaults.
  !! PHYSICS is borrowed readonly native TPHY with NRAY=1, LRSTAER=true,
  !! LRPROX=false, LCLSATUR=false and NRAUTOEV=0. OUTPUT is disjoint from
  !! both inputs. Native records use compiler-owned bounds and alignment.
  !! The caller establishes the declared nearest, gradual-underflow IEEE
  !! environment once before entering this child.
  !! Return 0 succeeds; return 2 preserves OUTPUT on an unsupported input.
  !! The 270 assignments write 2160 bytes of named real64 members. Other
  !! values, including later-computed RII0 and unused tables, remain intact.
  integer(int32) function initialize_legacy_radiation_parameters(text, output, physics) result(status)
    character(len=*), intent(in), target :: text
    type(tphy3), intent(inout), target :: output
    type(tphy), intent(in), target :: physics
    integer(c_intptr_t) :: address
    integer(int64) :: bytes
    status = 2_int32
    if (len(text, kind=int64) < 1_int64 .or. len(text, kind=int64) > 262144_int64) return
    if (output%n_spband /= 2_int32) return
    if (transfer(output%rtl, 0_int64) /= int(z'406FF9999999999A', int64)) return
    if (physics%nray /= 1_int32 .or. physics%nrautoev /= 0_int32) return
    if (transfer(physics%lrstaer, 0_int32) /= 1_int32) return
    if (transfer(physics%lrprox, 0_int32) /= 0_int32) return
    if (transfer(physics%lclsatur, 0_int32) /= 0_int32) return
    address = transfer(c_loc(output), 0_c_intptr_t)
    bytes = storage_size(output, kind=int64)/8_int64
    if (.not. disjoint(address, bytes, transfer(c_loc(text), 0_c_intptr_t), len(text, kind=int64))) return
    if (.not. disjoint(address, bytes, transfer(c_loc(physics), 0_c_intptr_t), &
                       storage_size(physics, kind=int64)/8_int64)) return
    if (require_empty_physics_group(text, 'NAMPHY3') /= 0_int32) return
    call set_legacy_radiation_parameters_raw(output)
    status = 0_int32
  end function

  !> Assign all 270 selected source literal words in their original order.
  !! OUTPUT is native TPHY3 INOUT; the enclosing caller admits its controls.
  !! Each TRANSFER preserves the frozen binary64 rounding of one literal.
  !! There is no runtime arithmetic, allocation, descriptor or raw offset.
  subroutine set_legacy_radiation_parameters_raw(output)
    type(tphy3), intent(inout) :: output
    output%bsfsa(1) = transfer(int(z'3FD65604189374BC', int64), 0.0_real64)
    output%bsfta(1) = transfer(int(z'3FD636E2EB1C432D', int64), 0.0_real64)
    output%eoasa(1) = transfer(int(z'3FB1389B52007DD4', int64), 0.0_real64)
    output%eoata(1) = transfer(int(z'3FA9CA18BD66277C', int64), 0.0_real64)
    output%eodsa(1) = transfer(int(z'3FD774BC6A7EF9DB', int64), 0.0_real64)
    output%eodta(1) = transfer(int(z'3F92157689CA18BD', int64), 0.0_real64)
    output%usaa(1) = transfer(int(z'BFD353F7CED91687', int64), 0.0_real64)
    output%bsfsa(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfsa(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfsa(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfsa(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfsa(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfta(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfta(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfta(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfta(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfta(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoasa(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoasa(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoasa(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoasa(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoasa(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoata(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoata(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoata(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoata(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eoata(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodsa(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodsa(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodsa(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodsa(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodsa(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodta(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodta(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodta(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodta(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%eodta(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usaa(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usaa(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usaa(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usaa(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usaa(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%bsfsi = transfer(int(z'3FD4B923A29C779A', int64), 0.0_real64)
    output%bsfsn = transfer(int(z'3FD51EB851EB851F', int64), 0.0_real64)
    output%bsfti = transfer(int(z'3FD4ADAB9F559B3D', int64), 0.0_real64)
    output%bsftn = transfer(int(z'3FD6F0068DB8BAC7', int64), 0.0_real64)
    output%earrt = transfer(int(z'3F55B1422CCB3A26', int64), 0.0_real64)
    output%eoasi = transfer(int(z'3F915379FA97E133', int64), 0.0_real64)
    output%eoasn = transfer(int(z'3FA12AD81ADEA897', int64), 0.0_real64)
    output%eoati = transfer(int(z'400BA3D70A3D70A4', int64), 0.0_real64)
    output%eoatn = transfer(int(z'4022276C8B439581', int64), 0.0_real64)
    output%eodsi = transfer(int(z'3FF67EF9DB22D0E5', int64), 0.0_real64)
    output%eodsn = transfer(int(z'401A3B645A1CAC08', int64), 0.0_real64)
    output%eodti = transfer(int(z'3FEAFDF3B645A1CB', int64), 0.0_real64)
    output%eodtn = transfer(int(z'401146A7EF9DB22D', int64), 0.0_real64)
    output%usai = transfer(int(z'BFD68DB8BAC710CB', int64), 0.0_real64)
    output%usan = transfer(int(z'BFD5C28F5C28F5C3', int64), 0.0_real64)
    output%usba = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usbi = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%usbn = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gca(1) = transfer(int(z'3FB495BFF04577D9', int64), 0.0_real64)
    output%gca(2) = transfer(int(z'3FC2A305532617C2', int64), 0.0_real64)
    output%gca(3) = transfer(int(z'401325E353F7CED9', int64), 0.0_real64)
    output%gca(4) = transfer(int(z'40A06C0000000000', int64), 0.0_real64)
    output%gca(5) = transfer(int(z'3FF55810624DD2F2', int64), 0.0_real64)
    output%gca(6) = transfer(int(z'3EF0436F158C8432', int64), 0.0_real64)
    output%gcb(1) = transfer(int(z'41611AE800000000', int64), 0.0_real64)
    output%gcb(2) = transfer(int(z'41E1FA6EA8000000', int64), 0.0_real64)
    output%gcb(3) = transfer(int(z'40E1530000000000', int64), 0.0_real64)
    output%gcb(4) = transfer(int(z'41F7BAE7C8000000', int64), 0.0_real64)
    output%gcb(5) = transfer(int(z'4233C9CC7B800000', int64), 0.0_real64)
    output%gcb(6) = transfer(int(z'40F8B50000000000', int64), 0.0_real64)
    output%gcc(1) = transfer(int(z'3DD049591C9781B2', int64), 0.0_real64)
    output%gcc(2) = transfer(int(z'3DB440C4E1D67578', int64), 0.0_real64)
    output%gcc(3) = transfer(int(z'3E5B2FE89A4294DB', int64), 0.0_real64)
    output%gcc(4) = transfer(int(z'413DCCE800000000', int64), 0.0_real64)
    output%gcc(5) = transfer(int(z'3D7E813DE394BC46', int64), 0.0_real64)
    output%gcc(6) = transfer(int(z'3C6C3F1FA949F79F', int64), 0.0_real64)
    output%gcd4 = transfer(int(z'3183EBD3CE5FE518', int64), 0.0_real64)
    output%gce4 = transfer(int(z'40BD8B0000000000', int64), 0.0_real64)
    output%girec1 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%girec2 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%girec3 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%girec4 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%vdp(1, 1) = transfer(int(z'4035DE353F7CED91', int64), 0.0_real64)
    output%vdp(2, 1) = transfer(int(z'403173F7CED91687', int64), 0.0_real64)
    output%vdp(3, 1) = transfer(int(z'3FE60DC33721D53D', int64), 0.0_real64)
    output%vdp(4, 1) = transfer(int(z'3F2EBE870ED280C1', int64), 0.0_real64)
    output%vdp(5, 1) = transfer(int(z'3DEEAC18A85DC099', int64), 0.0_real64)
    output%vdp(1, 2) = transfer(int(z'40483353F7CED917', int64), 0.0_real64)
    output%vdp(2, 2) = transfer(int(z'4032A5E353F7CED9', int64), 0.0_real64)
    output%vdp(3, 2) = transfer(int(z'3FA2059A73B42CC3', int64), 0.0_real64)
    output%vdp(4, 2) = transfer(int(z'3EA55F03E6D564B3', int64), 0.0_real64)
    output%vdp(5, 2) = transfer(int(z'3D38516A74499B1B', int64), 0.0_real64)
    output%vdp(1, 3) = transfer(int(z'40533CAC083126E9', int64), 0.0_real64)
    output%vdp(2, 3) = transfer(int(z'40106C226809D495', int64), 0.0_real64)
    output%vdp(3, 3) = transfer(int(z'3F3BF655B23922B6', int64), 0.0_real64)
    output%vdp(4, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%vdp(5, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%vdp(1, 4) = transfer(int(z'4071068F5C28F5C3', int64), 0.0_real64)
    output%vdp(2, 4) = transfer(int(z'40B64D199999999A', int64), 0.0_real64)
    output%vdp(3, 4) = transfer(int(z'40CC1C8000000000', int64), 0.0_real64)
    output%vdp(4, 4) = transfer(int(z'40A757CCCCCCCCCD', int64), 0.0_real64)
    output%vdp(5, 4) = transfer(int(z'403961CAC083126F', int64), 0.0_real64)
    output%vdp(1, 5) = transfer(int(z'4055BC49BA5E353F', int64), 0.0_real64)
    output%vdp(2, 5) = transfer(int(z'40741DC28F5C28F6', int64), 0.0_real64)
    output%vdp(3, 5) = transfer(int(z'405AF00000000000', int64), 0.0_real64)
    output%vdp(4, 5) = transfer(int(z'40010240B780346E', int64), 0.0_real64)
    output%vdp(5, 5) = transfer(int(z'3F70629E5AC97A32', int64), 0.0_real64)
    output%vdp(1, 6) = transfer(int(z'40386872B020C49C', int64), 0.0_real64)
    output%vdp(2, 6) = transfer(int(z'40206240B780346E', int64), 0.0_real64)
    output%vdp(3, 6) = transfer(int(z'401CE0902DE00D1B', int64), 0.0_real64)
    output%vdp(4, 6) = transfer(int(z'3FE1FE5C91D14E3C', int64), 0.0_real64)
    output%vdp(5, 6) = transfer(int(z'3F64CB691F7E4A89', int64), 0.0_real64)
    output%vnp(1, 1) = transfer(int(z'401BF86C226809D5', int64), 0.0_real64)
    output%vnp(2, 1) = transfer(int(z'3FE473EAB367A0F9', int64), 0.0_real64)
    output%vnp(3, 1) = transfer(int(z'3F32EFF1BFF64FA8', int64), 0.0_real64)
    output%vnp(4, 1) = transfer(int(z'3E11440968084FF9', int64), 0.0_real64)
    output%vnp(5, 1) = transfer(int(z'3C9C8BA40996B4CA', int64), 0.0_real64)
    output%vnp(1, 2) = transfer(int(z'4008E24DD2F1A9FC', int64), 0.0_real64)
    output%vnp(2, 2) = transfer(int(z'3F8D21FF2E48E8A7', int64), 0.0_real64)
    output%vnp(3, 2) = transfer(int(z'3EA7458C94320285', int64), 0.0_real64)
    output%vnp(4, 2) = transfer(int(z'3D5964DB222B1533', int64), 0.0_real64)
    output%vnp(5, 2) = transfer(int(z'3BB4D4EF394C96AF', int64), 0.0_real64)
    output%vnp(1, 3) = transfer(int(z'4002ED5CFAACD9E8', int64), 0.0_real64)
    output%vnp(2, 3) = transfer(int(z'3F524009048B7FFB', int64), 0.0_real64)
    output%vnp(3, 3) = transfer(int(z'3EB1D065724578CD', int64), 0.0_real64)
    output%vnp(4, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%vnp(5, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%vnp(1, 4) = transfer(int(z'4068C33333333333', int64), 0.0_real64)
    output%vnp(2, 4) = transfer(int(z'40B2576666666666', int64), 0.0_real64)
    output%vnp(3, 4) = transfer(int(z'40A1966666666666', int64), 0.0_real64)
    output%vnp(4, 4) = transfer(int(z'404A3B020C49BA5E', int64), 0.0_real64)
    output%vnp(5, 4) = transfer(int(z'3FBDCFAACD9E83E4', int64), 0.0_real64)
    output%vnp(1, 5) = transfer(int(z'40472C8B43958106', int64), 0.0_real64)
    output%vnp(2, 5) = transfer(int(z'4041D0A3D70A3D71', int64), 0.0_real64)
    output%vnp(3, 5) = transfer(int(z'400A676C8B439581', int64), 0.0_real64)
    output%vnp(4, 5) = transfer(int(z'3F927A63736CDF26', int64), 0.0_real64)
    output%vnp(5, 5) = transfer(int(z'3EE29845F800030F', int64), 0.0_real64)
    output%vnp(1, 6) = transfer(int(z'4012F71758E21965', int64), 0.0_real64)
    output%vnp(2, 6) = transfer(int(z'3FFA226809D49518', int64), 0.0_real64)
    output%vnp(3, 6) = transfer(int(z'3FDED330941C8217', int64), 0.0_real64)
    output%vnp(4, 6) = transfer(int(z'3F76FEB4A66559F7', int64), 0.0_real64)
    output%vnp(5, 6) = transfer(int(z'3F11C54F54FCDC8A', int64), 0.0_real64)
    output%golca(1) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcb(1) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcc(1) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golca(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcb(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcc(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golca(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcb(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcc(3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golca(4) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcb(4) = transfer(int(z'409A090000000000', int64), 0.0_real64)
    output%golcc(4) = transfer(int(z'41F2B6E349000000', int64), 0.0_real64)
    output%golca(5) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcb(5) = transfer(int(z'40C2A59AE147AE14', int64), 0.0_real64)
    output%golcc(5) = transfer(int(z'42CCE0001AAC0000', int64), 0.0_real64)
    output%golca(6) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%golcb(6) = transfer(int(z'420BBCEA79000000', int64), 0.0_real64)
    output%golcc(6) = transfer(int(z'42D0C7F9C566C000', int64), 0.0_real64)
    output%qco2 = transfer(int(z'3F419553B9BB7811', int64), 0.0_real64)
    output%eoray = transfer(int(z'3EACE07F69EA14E1', int64), 0.0_real64)
    output%fcm_del_a(1) = transfer(int(z'3FEE936C58EEAE9F', int64), 0.0_real64)
    output%fcm_del_a(2) = transfer(int(z'406664DD2F1A9FBE', int64), 0.0_real64)
    output%fcm_del_d(1) = transfer(int(z'404CA5E00D1B7176', int64), 0.0_real64)
    output%fcm_del_d(2) = transfer(int(z'40690516872B020C', int64), 0.0_real64)
    output%fcm_mu_a(1) = transfer(int(z'3FEBB7E90FF97247', int64), 0.0_real64)
    output%fcm_mu_a(2) = transfer(int(z'3FE54C09C3CE208A', int64), 0.0_real64)
    output%fcm_mu_d(1) = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%fcm_mu_d(2) = transfer(int(z'3FE574E0114D2F5E', int64), 0.0_real64)
    output%fcm_n_i = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%fcm_n_l = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%fcm_p_ai(1, 0) = transfer(int(z'402DC8B439581062', int64), 0.0_real64)
    output%fcm_p_ai(1, 1) = transfer(int(z'C04291A6B50B0F28', int64), 0.0_real64)
    output%fcm_p_ai(1, 2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_ai(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_ai(2, 0) = transfer(int(z'402389D495182A99', int64), 0.0_real64)
    output%fcm_p_ai(2, 1) = transfer(int(z'C01E318FC504816F', int64), 0.0_real64)
    output%fcm_p_ai(2, 2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_ai(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_al(1, 0) = transfer(int(z'3FF6BADC0980B242', int64), 0.0_real64)
    output%fcm_p_al(1, 1) = transfer(int(z'C00C52AD81ADEA89', int64), 0.0_real64)
    output%fcm_p_al(1, 2) = transfer(int(z'3FFBC3FE5C91D14E', int64), 0.0_real64)
    output%fcm_p_al(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_al(2, 0) = transfer(int(z'40145743E963DC48', int64), 0.0_real64)
    output%fcm_p_al(2, 1) = transfer(int(z'C025A0F9096BB98C', int64), 0.0_real64)
    output%fcm_p_al(2, 2) = transfer(int(z'4014A73ABC947065', int64), 0.0_real64)
    output%fcm_p_al(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_di(1, 0) = transfer(int(z'402A18EF34D6A162', int64), 0.0_real64)
    output%fcm_p_di(1, 1) = transfer(int(z'4033DDF3B645A1CB', int64), 0.0_real64)
    output%fcm_p_di(1, 2) = transfer(int(z'C0496DCC63F14120', int64), 0.0_real64)
    output%fcm_p_di(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_di(2, 0) = transfer(int(z'4028A27525460AA6', int64), 0.0_real64)
    output%fcm_p_di(2, 1) = transfer(int(z'C040A3F141205BC0', int64), 0.0_real64)
    output%fcm_p_di(2, 2) = transfer(int(z'404CDD604189374C', int64), 0.0_real64)
    output%fcm_p_di(2, 3) = transfer(int(z'C05264A8C154C986', int64), 0.0_real64)
    output%fcm_p_dl(1, 0) = transfer(int(z'4012BEEF5EC80C74', int64), 0.0_real64)
    output%fcm_p_dl(1, 1) = transfer(int(z'C0218D940789613D', int64), 0.0_real64)
    output%fcm_p_dl(1, 2) = transfer(int(z'400105EB313BE22E', int64), 0.0_real64)
    output%fcm_p_dl(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_dl(2, 0) = transfer(int(z'401217785729B281', int64), 0.0_real64)
    output%fcm_p_dl(2, 1) = transfer(int(z'C02CAA57A786C227', int64), 0.0_real64)
    output%fcm_p_dl(2, 2) = transfer(int(z'4027547AE147AE14', int64), 0.0_real64)
    output%fcm_p_dl(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_gi(1, 0) = transfer(int(z'C0001E2584F4C6E7', int64), 0.0_real64)
    output%fcm_p_gi(1, 1) = transfer(int(z'4056E837B4A2339C', int64), 0.0_real64)
    output%fcm_p_gi(1, 2) = transfer(int(z'40538E8F5C28F5C3', int64), 0.0_real64)
    output%fcm_p_gi(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_gi(2, 0) = transfer(int(z'BFE829F9CE8D972D', int64), 0.0_real64)
    output%fcm_p_gi(2, 1) = transfer(int(z'C012C0E410B630A9', int64), 0.0_real64)
    output%fcm_p_gi(2, 2) = transfer(int(z'4050D269AD42C3CA', int64), 0.0_real64)
    output%fcm_p_gi(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_gl(1, 0) = transfer(int(z'3FEC3EF6B5D462C3', int64), 0.0_real64)
    output%fcm_p_gl(1, 1) = transfer(int(z'C0003212D77318FC', int64), 0.0_real64)
    output%fcm_p_gl(1, 2) = transfer(int(z'3FF73DCF0307F23D', int64), 0.0_real64)
    output%fcm_p_gl(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_p_gl(2, 0) = transfer(int(z'3FC8CDEA033E78E2', int64), 0.0_real64)
    output%fcm_p_gl(2, 1) = transfer(int(z'BFE37214F0520D13', int64), 0.0_real64)
    output%fcm_p_gl(2, 2) = transfer(int(z'3FE1351DEEFE4FFD', int64), 0.0_real64)
    output%fcm_p_gl(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_ai(1, 1) = transfer(int(z'4032A8A71DE69AD4', int64), 0.0_real64)
    output%fcm_q_ai(1, 2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_ai(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_ai(2, 1) = transfer(int(z'40063EBAF102363B', int64), 0.0_real64)
    output%fcm_q_ai(2, 2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_ai(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_al(1, 1) = transfer(int(z'C0067F2E48E8A71E', int64), 0.0_real64)
    output%fcm_q_al(1, 2) = transfer(int(z'4002DC52E72DA123', int64), 0.0_real64)
    output%fcm_q_al(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_al(2, 1) = transfer(int(z'C002800A7C5AC472', int64), 0.0_real64)
    output%fcm_q_al(2, 2) = transfer(int(z'3FF9187E7C06E19C', int64), 0.0_real64)
    output%fcm_q_al(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_di(1, 1) = transfer(int(z'4024EA9930BE0DED', int64), 0.0_real64)
    output%fcm_q_di(1, 2) = transfer(int(z'4018A029F16B11C7', int64), 0.0_real64)
    output%fcm_q_di(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_di(2, 1) = transfer(int(z'3FF2F06F69446738', int64), 0.0_real64)
    output%fcm_q_di(2, 2) = transfer(int(z'4001DADEA897635E', int64), 0.0_real64)
    output%fcm_q_di(2, 3) = transfer(int(z'401C04577D955715', int64), 0.0_real64)
    output%fcm_q_dl(1, 1) = transfer(int(z'C00174D6A161E4F7', int64), 0.0_real64)
    output%fcm_q_dl(1, 2) = transfer(int(z'3FF592AD81ADEA89', int64), 0.0_real64)
    output%fcm_q_dl(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_dl(2, 1) = transfer(int(z'C008FC1BDA5119CE', int64), 0.0_real64)
    output%fcm_q_dl(2, 2) = transfer(int(z'4004A30014F8B589', int64), 0.0_real64)
    output%fcm_q_dl(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_gi(1, 1) = transfer(int(z'4053BFFE5C91D14E', int64), 0.0_real64)
    output%fcm_q_gi(1, 2) = transfer(int(z'404A3F1758E21965', int64), 0.0_real64)
    output%fcm_q_gi(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_gi(2, 1) = transfer(int(z'4013C085B18548AA', int64), 0.0_real64)
    output%fcm_q_gi(2, 2) = transfer(int(z'4037CF41F212D773', int64), 0.0_real64)
    output%fcm_q_gi(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_gl(1, 1) = transfer(int(z'C001AA9930BE0DED', int64), 0.0_real64)
    output%fcm_q_gl(1, 2) = transfer(int(z'3FF65F84CAD57BC8', int64), 0.0_real64)
    output%fcm_q_gl(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%fcm_q_gl(2, 1) = transfer(int(z'C00A38BAC710CB29', int64), 0.0_real64)
    output%fcm_q_gl(2, 2) = transfer(int(z'40064692F6E8294A', int64), 0.0_real64)
    output%fcm_q_gl(2, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rexp_neb = transfer(int(z'4020000000000000', int64), 0.0_real64)
    output%rmixd = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%rmixp0 = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%fsm_cc = transfer(int(z'3FD28F5C28F5C28F', int64), 0.0_real64)
    output%fsm_dd = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%fsm_ee = transfer(int(z'3FB1EB851EB851EC', int64), 0.0_real64)
    output%fsm_ff = transfer(int(z'3FF8000000000000', int64), 0.0_real64)
    output%fsm_gg = transfer(int(z'3FC1EB851EB851EC', int64), 0.0_real64)
    output%fsm_hh = transfer(int(z'4034000000000000', int64), 0.0_real64)
    output%fsm_ii = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rlamb_solid = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rlamb_water = transfer(int(z'0000000000000000', int64), 0.0_real64)
  end subroutine

  logical function disjoint(left, left_bytes, right, right_bytes) result(valid)
    integer(c_intptr_t), intent(in) :: left, right
    integer(int64), intent(in) :: left_bytes, right_bytes
    valid = .false.
    if (left < 0_c_intptr_t .or. right < 0_c_intptr_t .or. left_bytes < 0_int64 .or. right_bytes < 0_int64) return
    if (left > huge(left) - left_bytes .or. right > huge(right) - right_bytes) return
    valid = left + left_bytes <= right .or. right + right_bytes <= left
  end function
end module legacy_radiation_parameter_setup_port
