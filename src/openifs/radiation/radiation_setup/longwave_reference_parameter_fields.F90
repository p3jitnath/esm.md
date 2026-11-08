!> Construct the selected longwave radiation reference parameters.
!! These native records retain SURDI, SURRTAB, SURRTPK and SURRTRF in their
!! generated order. Literal tables come from longwave_reference_tables.inc.S.
!! Original modules supply type declarations only, never numerical state.
module longwave_reference_parameter_fields_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yoerdi, only: terdi
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: longwave_reference_parameter_record
  public :: initialize_longwave_reference_fields
  public :: initialize_longwave_mass_mixing_ratios
  public :: initialize_longwave_transmission_fields
  public :: initialize_longwave_planck_fields
  public :: initialize_longwave_atmosphere_fields

  !> Caller-owned longwave tables with the original native element types.
  !! TRANS is dimensionless transmission. BPADE is its dimensionless shape
  !! coefficient. NG, NSPA and NSPB are int32 quadrature and gas-table counts.
  !! DELWAVE is in inverse centimetres. TOTPLNK uses the original integrated
  !! Planck-table convention. PREF is in hectopascals, PREFLOG is its source
  !! logarithmic coordinate, TREF is in kelvin and CHI_MLS contains gas fractions.
  !! Every component is written by the complete four-stage initializer.
  type :: longwave_reference_parameter_record
    real(real64) :: trans(0:5000), bpade
    integer(int32) :: ng(16), nspa(16), nspb(16)
    real(real64) :: delwave(16), totplnk(181, 16)
    real(real64) :: pref(59), preflog(59), tref(59), chi_mls(7, 59)
  end type longwave_reference_parameter_record

  interface
    function selected_public_exp(value) bind(C, name='exp') result(exponential)
      import :: c_double
      real(c_double), value, intent(in) :: value
      real(c_double) :: exponential
    end function selected_public_exp
  end interface

  ! Exact source words are grouped by named native table columns.
  integer(int32), parameter :: ng_values(16) = [ &
                               16_int32, 16_int32, &
                               16_int32, 16_int32, &
                               16_int32, 16_int32, &
                               16_int32, 16_int32, &
                               16_int32, 16_int32, &
                               16_int32, 16_int32, &
                               16_int32, 16_int32, &
                               16_int32, 16_int32]
  integer(int32), parameter :: nspa_values(16) = [ &
                               1_int32, 1_int32, &
                               9_int32, 9_int32, &
                               9_int32, 1_int32, &
                               9_int32, 1_int32, &
                               9_int32, 1_int32, &
                               1_int32, 9_int32, &
                               9_int32, 1_int32, &
                               9_int32, 9_int32]
  integer(int32), parameter :: nspb_values(16) = [ &
                               1_int32, 1_int32, &
                               5_int32, 5_int32, &
                               5_int32, 0_int32, &
                               1_int32, 1_int32, &
                               1_int32, 1_int32, &
                               1_int32, 0_int32, &
                               0_int32, 1_int32, &
                               0_int32, 0_int32]
  real(real64), parameter :: delwave_values(16) = [ &
                     transfer(int(z'4075400000000000', int64), 0.0_real64), transfer(int(z'4062c00000000000', int64), 0.0_real64), &
                     transfer(int(z'4060400000000000', int64), 0.0_real64), transfer(int(z'4051800000000000', int64), 0.0_real64), &
                     transfer(int(z'405e000000000000', int64), 0.0_real64), transfer(int(z'4064000000000000', int64), 0.0_real64), &
                     transfer(int(z'4059000000000000', int64), 0.0_real64), transfer(int(z'4059000000000000', int64), 0.0_real64), &
                     transfer(int(z'406a400000000000', int64), 0.0_real64), transfer(int(z'4056800000000000', int64), 0.0_real64), &
                     transfer(int(z'4074000000000000', int64), 0.0_real64), transfer(int(z'4071800000000000', int64), 0.0_real64), &
                     transfer(int(z'4065400000000000', int64), 0.0_real64), transfer(int(z'4060400000000000', int64), 0.0_real64), &
                       transfer(int(z'406b800000000000', int64), 0.0_real64), transfer(int(z'4084500000000000', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_1(181) = [ &
                     transfer(int(z'3eb8cd400a1244d5', int64), 0.0_real64), transfer(int(z'3eb92d07260d508e', int64), 0.0_real64), &
                     transfer(int(z'3eb98d3c3587c3a6', int64), 0.0_real64), transfer(int(z'3eb9eddf38819e1d', int64), 0.0_real64), &
                     transfer(int(z'3eba4ef02efadff3', int64), 0.0_real64), transfer(int(z'3ebab06f18f38928', int64), 0.0_real64), &
                     transfer(int(z'3ebb125bf66b99bc', int64), 0.0_real64), transfer(int(z'3ebb74b6c76311ae', int64), 0.0_real64), &
                     transfer(int(z'3ebbd77f8bd9f100', int64), 0.0_real64), transfer(int(z'3ebc3ab643d037b1', int64), 0.0_real64), &
                     transfer(int(z'3ebc9ec8e2c54d20', int64), 0.0_real64), transfer(int(z'3ebd02db81ba628f', int64), 0.0_real64), &
                     transfer(int(z'3ebd675c142edf5c', int64), 0.0_real64), transfer(int(z'3ebdccb88da22ae8', int64), 0.0_real64), &
                     transfer(int(z'3ebe321507157673', int64), 0.0_real64), transfer(int(z'3ebe97df7408295e', int64), 0.0_real64), &
                     transfer(int(z'3ebefe17d47a43a8', int64), 0.0_real64), transfer(int(z'3ebf64be286bc550', int64), 0.0_real64), &
                     transfer(int(z'3ebfcc40635c15b7', int64), 0.0_real64), transfer(int(z'3ec019e14f26330f', int64), 0.0_real64), &
                     transfer(int(z'3ec04da26c9e5b42', int64), 0.0_real64), transfer(int(z'3ec081d17d95ead4', int64), 0.0_real64), &
                     transfer(int(z'3ec0b637884d2e16', int64), 0.0_real64), transfer(int(z'3ec0ea9d93047157', int64), 0.0_real64), &
                     transfer(int(z'3ec11f71913b1bf8', int64), 0.0_real64), transfer(int(z'3ec154458f71c699', int64), 0.0_real64), &
                     transfer(int(z'3ec18950876824e9', int64), 0.0_real64), transfer(int(z'3ec1be92791e36e8', int64), 0.0_real64), &
                     transfer(int(z'3ec1f40b6493fc97', int64), 0.0_real64), transfer(int(z'3ec229bb49c975f6', int64), 0.0_real64), &
                     transfer(int(z'3ec25f6b2efeef54', int64), 0.0_real64), transfer(int(z'3ec2958907b3d012', int64), 0.0_real64), &
                     transfer(int(z'3ec2cba6e068b0d0', int64), 0.0_real64), transfer(int(z'3ec301fbb2dd453d', int64), 0.0_real64), &
                     transfer(int(z'3ec338508551d9aa', int64), 0.0_real64), transfer(int(z'3ec36f134b45d576', int64), 0.0_real64), &
                     transfer(int(z'3ec3a5d61139d142', int64), 0.0_real64), transfer(int(z'3ec3dccfd0ed80bd', int64), 0.0_real64), &
                     transfer(int(z'3ec413c990a13038', int64), 0.0_real64), transfer(int(z'3ec44b3143d44713', int64), 0.0_real64), &
                     transfer(int(z'3ec48298f7075ded', int64), 0.0_real64), transfer(int(z'3ec4ba37a3fa2877', int64), 0.0_real64), &
                     transfer(int(z'3ec4f1d650ecf301', int64), 0.0_real64), transfer(int(z'3ec529e2f15f24ea', int64), 0.0_real64), &
                     transfer(int(z'3ec561ef91d156d3', int64), 0.0_real64), transfer(int(z'3ec599fc324388bc', int64), 0.0_real64), &
                     transfer(int(z'3ec5d276c6352204', int64), 0.0_real64), transfer(int(z'3ec60af15a26bb4b', int64), 0.0_real64), &
                     transfer(int(z'3ec6436bee185493', int64), 0.0_real64), transfer(int(z'3ec67c547589553a', int64), 0.0_real64), &
                     transfer(int(z'3ec6b53cfcfa55e1', int64), 0.0_real64), transfer(int(z'3ec6ee25846b5688', int64), 0.0_real64), &
                     transfer(int(z'3ec7277bff5bbe8d', int64), 0.0_real64), transfer(int(z'3ec760d27a4c2693', int64), 0.0_real64), &
                     transfer(int(z'3ec79a28f53c8e99', int64), 0.0_real64), transfer(int(z'3ec7d3b669ecaa4e', int64), 0.0_real64), &
                     transfer(int(z'3ec80d7ad85c79b3', int64), 0.0_real64), transfer(int(z'3ec84776408bfcc7', int64), 0.0_real64), &
                     transfer(int(z'3ec88171a8bb7fdb', int64), 0.0_real64), transfer(int(z'3ec8bb6d10eb02ef', int64), 0.0_real64), &
                     transfer(int(z'3ec8f59f72da39b3', int64), 0.0_real64), transfer(int(z'3ec93008ce892426', int64), 0.0_real64), &
                     transfer(int(z'3ec96a722a380e9a', int64), 0.0_real64), transfer(int(z'3ec9a5127fa6acbc', int64), 0.0_real64), &
                     transfer(int(z'3ec9dfe9ced4fe8e', int64), 0.0_real64), transfer(int(z'3eca1ac11e035060', int64), 0.0_real64), &
                     transfer(int(z'3eca55986d31a233', int64), 0.0_real64), transfer(int(z'3eca90ddafdf5b64', int64), 0.0_real64), &
                     transfer(int(z'3ecacbebf8cd60e5', int64), 0.0_real64), transfer(int(z'3ecb07313b7b1a16', int64), 0.0_real64), &
                     transfer(int(z'3ecb42ad77e886f7', int64), 0.0_real64), transfer(int(z'3ecb7e29b455f3d8', int64), 0.0_real64), &
                     transfer(int(z'3ecbb9dcea831468', int64), 0.0_real64), transfer(int(z'3ecbf59020b034f8', int64), 0.0_real64), &
                     transfer(int(z'3ecc317a509d0937', int64), 0.0_real64), transfer(int(z'3ecc6d648089dd77', int64), 0.0_real64), &
                     transfer(int(z'3ecca985aa366566', int64), 0.0_real64), transfer(int(z'3ecce5a6d3e2ed55', int64), 0.0_real64), &
                     transfer(int(z'3ecd21fef74f28f3', int64), 0.0_real64), transfer(int(z'3ecd5e571abb6492', int64), 0.0_real64), &
                     transfer(int(z'3ecd9ae637e753e0', int64), 0.0_real64), transfer(int(z'3ecdd7755513432e', int64), 0.0_real64), &
                     transfer(int(z'3ece143b6bfee62b', int64), 0.0_real64), transfer(int(z'3ece510182ea8929', int64), 0.0_real64), &
                     transfer(int(z'3ece8dfe9395dfd6', int64), 0.0_real64), transfer(int(z'3ececafba4413683', int64), 0.0_real64), &
                     transfer(int(z'3ecf07f8b4ec8d30', int64), 0.0_real64), transfer(int(z'3ecf452cbf57978c', int64), 0.0_real64), &
                     transfer(int(z'3ecf8297c3825598', int64), 0.0_real64), transfer(int(z'3ecfbfcbcded5ff5', int64), 0.0_real64), &
                     transfer(int(z'3ecffd6dcbd7d1b0', int64), 0.0_real64), transfer(int(z'3ed01d6c680147de', int64), 0.0_real64), &
                     transfer(int(z'3ed03c3d66f680bc', int64), 0.0_real64), transfer(int(z'3ed05b29e2cb9371', int64), 0.0_real64), &
                     transfer(int(z'3ed07a165ea0a627', int64), 0.0_real64), transfer(int(z'3ed09902da75b8dc', int64), 0.0_real64), &
                     transfer(int(z'3ed0b80ad32aa569', int64), 0.0_real64), transfer(int(z'3ed0d712cbdf91f6', int64), 0.0_real64), &
                     transfer(int(z'3ed0f6364174585b', int64), 0.0_real64), transfer(int(z'3ed11559b7091ec0', int64), 0.0_real64), &
                     transfer(int(z'3ed1347d2c9de525', int64), 0.0_real64), transfer(int(z'3ed153bc1f128562', int64), 0.0_real64), &
                     transfer(int(z'3ed172fb1187259f', int64), 0.0_real64), transfer(int(z'3ed1923a03fbc5db', int64), 0.0_real64), &
                     transfer(int(z'3ed1b19473503ff0', int64), 0.0_real64), transfer(int(z'3ed1d0eee2a4ba04', int64), 0.0_real64), &
                     transfer(int(z'3ed1f064ced90df0', int64), 0.0_real64), transfer(int(z'3ed20fdabb0d61dc', int64), 0.0_real64), &
                     transfer(int(z'3ed22f50a741b5c8', int64), 0.0_real64), transfer(int(z'3ed24ee21055e38c', int64), 0.0_real64), &
                     transfer(int(z'3ed26e73796a1150', int64), 0.0_real64), transfer(int(z'3ed28e04e27e3f14', int64), 0.0_real64), &
                     transfer(int(z'3ed2adb1c87246b0', int64), 0.0_real64), transfer(int(z'3ed2cd5eae664e4b', int64), 0.0_real64), &
                     transfer(int(z'3ed2ed27113a2fbf', int64), 0.0_real64), transfer(int(z'3ed30cd3f72e375a', int64), 0.0_real64), &
                     transfer(int(z'3ed32c9c5a0218ce', int64), 0.0_real64), transfer(int(z'3ed34c8039b5d419', int64), 0.0_real64), &
                     transfer(int(z'3ed36c6419698f64', int64), 0.0_real64), transfer(int(z'3ed38c47f91d4aaf', int64), 0.0_real64), &
                     transfer(int(z'3ed3ac2bd8d105fa', int64), 0.0_real64), transfer(int(z'3ed3cc2b35649b1d', int64), 0.0_real64), &
                     transfer(int(z'3ed3ec2a91f83040', int64), 0.0_real64), transfer(int(z'3ed40c29ee8bc563', int64), 0.0_real64), &
                     transfer(int(z'3ed42c44c7ff345d', int64), 0.0_real64), transfer(int(z'3ed44c5fa172a358', int64), 0.0_real64), &
                     transfer(int(z'3ed46c95f7c5ec2a', int64), 0.0_real64), transfer(int(z'3ed48cb0d1395b25', int64), 0.0_real64), &
                     transfer(int(z'3ed4ace7278ca3f7', int64), 0.0_real64), transfer(int(z'3ed4cd1d7ddfecca', int64), 0.0_real64), &
                     transfer(int(z'3ed4ed6f51130f74', int64), 0.0_real64), transfer(int(z'3ed50dc12446321e', int64), 0.0_real64), &
                     transfer(int(z'3ed52e12f77954c8', int64), 0.0_real64), transfer(int(z'3ed54e64caac7772', int64), 0.0_real64), &
                     transfer(int(z'3ed56ed21abf73f4', int64), 0.0_real64), transfer(int(z'3ed58f3f6ad27076', int64), 0.0_real64), &
                     transfer(int(z'3ed5afacbae56cf7', int64), 0.0_real64), transfer(int(z'3ed5d03587d84351', int64), 0.0_real64), &
                     transfer(int(z'3ed5f0a2d7eb3fd3', int64), 0.0_real64), transfer(int(z'3ed6112ba4de162c', int64), 0.0_real64), &
                     transfer(int(z'3ed631cfeeb0c65e', int64), 0.0_real64), transfer(int(z'3ed65258bba39cb7', int64), 0.0_real64), &
                     transfer(int(z'3ed672fd05764ce9', int64), 0.0_real64), transfer(int(z'3ed693a14f48fd1a', int64), 0.0_real64), &
                     transfer(int(z'3ed6b46115fb8723', int64), 0.0_real64), transfer(int(z'3ed6d5055fce3754', int64), 0.0_real64), &
                     transfer(int(z'3ed6f5c52680c15d', int64), 0.0_real64), transfer(int(z'3ed716a06a13253e', int64), 0.0_real64), &
                     transfer(int(z'3ed7376030c5af47', int64), 0.0_real64), transfer(int(z'3ed7583b74581328', int64), 0.0_real64), &
                     transfer(int(z'3ed77916b7ea7709', int64), 0.0_real64), transfer(int(z'3ed799f1fb7cdae9', int64), 0.0_real64), &
                     transfer(int(z'3ed7bacd3f0f3eca', int64), 0.0_real64), transfer(int(z'3ed7dbc3ff817c83', int64), 0.0_real64), &
                     transfer(int(z'3ed7fcbabff3ba3b', int64), 0.0_real64), transfer(int(z'3ed81db18065f7f4', int64), 0.0_real64), &
                     transfer(int(z'3ed83ea840d835ac', int64), 0.0_real64), transfer(int(z'3ed85fba7e2a4d3d', int64), 0.0_real64), &
                     transfer(int(z'3ed880ccbb7c64cd', int64), 0.0_real64), transfer(int(z'3ed8a1def8ce7c5d', int64), 0.0_real64), &
                     transfer(int(z'3ed8c2f1362093ed', int64), 0.0_real64), transfer(int(z'3ed8e41ef0528555', int64), 0.0_real64), &
                     transfer(int(z'3ed905312da49ce6', int64), 0.0_real64), transfer(int(z'3ed9265ee7d68e4e', int64), 0.0_real64), &
                     transfer(int(z'3ed947a81ee8598d', int64), 0.0_real64), transfer(int(z'3ed968d5d91a4af5', int64), 0.0_real64), &
                     transfer(int(z'3ed98a1f102c1635', int64), 0.0_real64), transfer(int(z'3ed9ab68473de175', int64), 0.0_real64), &
                     transfer(int(z'3ed9ccb17e4facb5', int64), 0.0_real64), transfer(int(z'3ed9edfab56177f4', int64), 0.0_real64), &
                     transfer(int(z'3eda0f43ec734334', int64), 0.0_real64), transfer(int(z'3eda30a8a064e84c', int64), 0.0_real64), &
                     transfer(int(z'3eda520d54568d63', int64), 0.0_real64), transfer(int(z'3eda73720848327b', int64), 0.0_real64), &
                     transfer(int(z'3eda94f23919b16a', int64), 0.0_real64), transfer(int(z'3edab656ed0b5681', int64), 0.0_real64), &
                     transfer(int(z'3edad7bba0fcfb99', int64), 0.0_real64), transfer(int(z'3edaf93bd1ce7a88', int64), 0.0_real64), &
                     transfer(int(z'3edb1abc029ff977', int64), 0.0_real64), transfer(int(z'3edb3c57b051523e', int64), 0.0_real64), &
                             transfer(int(z'3edb5dd7e122d12e', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_2(181) = [ &
                     transfer(int(z'3ec0ff3b3ae7d326', int64), 0.0_real64), transfer(int(z'3ec1698824944375', int64), 0.0_real64), &
                     transfer(int(z'3ec1d4e7eeff3632', int64), 0.0_real64), transfer(int(z'3ec2419193e85f0c', int64), 0.0_real64), &
                     transfer(int(z'3ec2afbc0d0f71b3', int64), 0.0_real64), transfer(int(z'3ec31ef966f506c7', int64), 0.0_real64), &
                     transfer(int(z'3ec38fb7951885a7', int64), 0.0_real64), transfer(int(z'3ec40188a3fa86f4', int64), 0.0_real64), &
                     transfer(int(z'3ec474da871a720e', int64), 0.0_real64), transfer(int(z'3ec4e93f4af8df96', int64), 0.0_real64), &
                     transfer(int(z'3ec55f24e31536ea', int64), 0.0_real64), transfer(int(z'3ec5d61d5bf010ab', int64), 0.0_real64), &
                     transfer(int(z'3ec64e5faf492089', int64), 0.0_real64), transfer(int(z'3ec6c7ebdd206684', int64), 0.0_real64), &
                     transfer(int(z'3ec7428aebb62eec', int64), 0.0_real64), transfer(int(z'3ec7beaace89e121', int64), 0.0_real64), &
                     transfer(int(z'3ec83bdd921c15c3', int64), 0.0_real64), transfer(int(z'3ec8ba5a302c8082', int64), 0.0_real64), &
                     transfer(int(z'3ec93a20a8bb215e', int64), 0.0_real64), transfer(int(z'3ec9bafa020844a7', int64), 0.0_real64), &
                     transfer(int(z'3eca3d1d35d39e0e', int64), 0.0_real64), transfer(int(z'3ecac0534a5d79e1', int64), 0.0_real64), &
                     transfer(int(z'3ecb44d339658bd2', int64), 0.0_real64), transfer(int(z'3ecbca66092c2030', int64), 0.0_real64), &
                     transfer(int(z'3ecc5142b370eaab', int64), 0.0_real64), transfer(int(z'3eccd9693833eb42', int64), 0.0_real64), &
                     transfer(int(z'3ecd626ba3f5ba98', int64), 0.0_real64), transfer(int(z'3ecdeceee3f573ba', int64), 0.0_real64), &
                     transfer(int(z'3ece784e0af3fb9a', int64), 0.0_real64), transfer(int(z'3ecf04f70c70b997', int64), 0.0_real64), &
                     transfer(int(z'3ecf92b2eeabfa01', int64), 0.0_real64), transfer(int(z'3ed010dc55b2b844', int64), 0.0_real64), &
                     transfer(int(z'3ed058cd278edae7', int64), 0.0_real64), transfer(int(z'3ed0a162e6aa1898', int64), 0.0_real64), &
                     transfer(int(z'3ed0ea8216249780', int64), 0.0_real64), transfer(int(z'3ed1342ab5fe579e', int64), 0.0_real64), &
                     transfer(int(z'3ed17e5cc63758f3', int64), 0.0_real64), transfer(int(z'3ed1c933c3af7557', int64), 0.0_real64), &
                     transfer(int(z'3ed21478b4a6f919', int64), 0.0_real64), transfer(int(z'3ed2604715fdbe12', int64), 0.0_real64), &
                     transfer(int(z'3ed2acba64939e1a', int64), 0.0_real64), transfer(int(z'3ed2f99ba6a8e581', int64), 0.0_real64), &
                     transfer(int(z'3ed34706591d6e1e', int64), 0.0_real64), transfer(int(z'3ed394fa7bf137f2', int64), 0.0_real64), &
                     transfer(int(z'3ed3e3780f2442fd', int64), 0.0_real64), transfer(int(z'3ed4326395d6b567', int64), 0.0_real64), &
                     transfer(int(z'3ed481f409c842df', int64), 0.0_real64), transfer(int(z'3ed4d1f2713937b6', int64), 0.0_real64), &
                     transfer(int(z'3ed5227a49096dc4', int64), 0.0_real64), transfer(int(z'3ed5737014590b31', int64), 0.0_real64), &
                     transfer(int(z'3ed5c4ef5007e9d4', int64), 0.0_real64), transfer(int(z'3ed616f7fc1609ae', int64), 0.0_real64), &
                     transfer(int(z'3ed6696e9ba390e8', int64), 0.0_real64), transfer(int(z'3ed6bc6eab905957', int64), 0.0_real64), &
                     transfer(int(z'3ed70ff82bdc62fe', int64), 0.0_real64), transfer(int(z'3ed763ef9fa7d404', int64), 0.0_real64), &
                     transfer(int(z'3ed7b85506f2ac68', int64), 0.0_real64), transfer(int(z'3ed80d2861bcec2c', int64), 0.0_real64), &
                     transfer(int(z'3ed862a0a9c646fe', int64), 0.0_real64), transfer(int(z'3ed8b86b686f2f57', int64), 0.0_real64), &
                     transfer(int(z'3ed90ebf977758e7', int64), 0.0_real64), transfer(int(z'3ed96581b9fee9d5', int64), 0.0_real64), &
                     transfer(int(z'3ed9bcb1d005e223', int64), 0.0_real64), transfer(int(z'3eda146b566c1ba8', int64), 0.0_real64), &
                     transfer(int(z'3eda6c92d051bc8b', int64), 0.0_real64), transfer(int(z'3edac5283db6c4ce', int64), 0.0_real64), &
                     transfer(int(z'3edb1e2b9e9b346f', int64), 0.0_real64), transfer(int(z'3edb779cf2ff0b6f', int64), 0.0_real64), &
                     transfer(int(z'3edbd17c3ae249cf', int64), 0.0_real64), transfer(int(z'3edc2be4f324c965', int64), 0.0_real64), &
                     transfer(int(z'3edc86a02206d682', int64), 0.0_real64), transfer(int(z'3edce1c944684afe', int64), 0.0_real64), &
                     transfer(int(z'3edd3d7bd72900b1', int64), 0.0_real64), transfer(int(z'3edd9980e08943eb', int64), 0.0_real64), &
                     transfer(int(z'3eddf5f3dd68ee84', int64), 0.0_real64), transfer(int(z'3ede52d4cdc8007d', int64), 0.0_real64), &
                     transfer(int(z'3edeb023b1a679d4', int64), 0.0_real64), transfer(int(z'3edf0de089045a8a', int64), 0.0_real64), &
                     transfer(int(z'3edf6befd701c8c7', int64), 0.0_real64), transfer(int(z'3edfca88955e783b', int64), 0.0_real64), &
                     transfer(int(z'3ee014b9e52d5a9b', int64), 0.0_real64), transfer(int(z'3ee04458bafb3fdc', int64), 0.0_real64), &
                     transfer(int(z'3ee0743c48f8c5b9', int64), 0.0_real64), transfer(int(z'3ee0a44912461259', int64), 0.0_real64), &
                     transfer(int(z'3ee0d47f16e325bd', int64), 0.0_real64), transfer(int(z'3ee104f9d3afd9bc', int64), 0.0_real64), &
                     transfer(int(z'3ee1359dcbcc547e', int64), 0.0_real64), transfer(int(z'3ee1666aff389605', int64), 0.0_real64), &
                     transfer(int(z'3ee1976f2c648b3b', int64), 0.0_real64), transfer(int(z'3ee1c89c94e04734', int64), 0.0_real64), &
                     transfer(int(z'3ee1fa00f71bb6dd', int64), 0.0_real64), transfer(int(z'3ee22b9c5316da35', int64), 0.0_real64), &
                     transfer(int(z'3ee25d532bf1d766', int64), 0.0_real64), transfer(int(z'3ee28f40fe8c8845', int64), 0.0_real64), &
                     transfer(int(z'3ee2c165cae6ecd4', int64), 0.0_real64), transfer(int(z'3ee2f3b3d2911827', int64), 0.0_real64), &
                     transfer(int(z'3ee3262b158b0a3d', int64), 0.0_real64), transfer(int(z'3ee358d95244b003', int64), 0.0_real64), &
                     transfer(int(z'3ee38ba30bde2fa1', int64), 0.0_real64), transfer(int(z'3ee3bea3bf3762ee', int64), 0.0_real64), &
                     transfer(int(z'3ee3f1db6c5049ea', int64), 0.0_real64), transfer(int(z'3ee4252e96490abe', int64), 0.0_real64), &
                     transfer(int(z'3ee458b8ba017f42', int64), 0.0_real64), transfer(int(z'3ee48c5e5a99cd9e', int64), 0.0_real64), &
                     transfer(int(z'3ee4c03af4f1cfa9', int64), 0.0_real64), transfer(int(z'3ee4f440ca999877', int64), 0.0_real64), &
                     transfer(int(z'3ee5287d9a0114f5', int64), 0.0_real64), transfer(int(z'3ee55c912e18cab0', int64), 0.0_real64), &
                     transfer(int(z'3ee5912e328fc1a1', int64), 0.0_real64), transfer(int(z'3ee5c5cb3706b892', int64), 0.0_real64), &
                     transfer(int(z'3ee5faf1abdcf0ba', int64), 0.0_real64), transfer(int(z'3ee6301820b328e2', int64), 0.0_real64), &
                     transfer(int(z'3ee6653e9589610a', int64), 0.0_real64), transfer(int(z'3ee69a650a5f9932', int64), 0.0_real64), &
                     transfer(int(z'3ee6cf8b7f35d159', int64), 0.0_real64), transfer(int(z'3ee7053b646b4ab8', int64), 0.0_real64), &
                     transfer(int(z'3ee73aeb49a0c417', int64), 0.0_real64), transfer(int(z'3ee771249f357eac', int64), 0.0_real64), &
                     transfer(int(z'3ee7a75df4ca3941', int64), 0.0_real64), transfer(int(z'3ee7dd974a5ef3d6', int64), 0.0_real64), &
                     transfer(int(z'3ee813d09ff3ae6c', int64), 0.0_real64), transfer(int(z'3ee84a9365e7aa38', int64), 0.0_real64), &
                     transfer(int(z'3ee880ccbb7c64cd', int64), 0.0_real64), transfer(int(z'3ee8b78f81706099', int64), 0.0_real64), &
                     transfer(int(z'3ee8eedbb7c39d9b', int64), 0.0_real64), transfer(int(z'3ee92627ee16da9e', int64), 0.0_real64), &
                     transfer(int(z'3ee95ceab40ad66a', int64), 0.0_real64), transfer(int(z'3ee994c05abd54a4', int64), 0.0_real64), &
                     transfer(int(z'3ee9cc0c911091a6', int64), 0.0_real64), transfer(int(z'3eea03e237c30fe0', int64), 0.0_real64), &
                     transfer(int(z'3eea3bb7de758e19', int64), 0.0_real64), transfer(int(z'3eea738d85280c52', int64), 0.0_real64), &
                     transfer(int(z'3eeaab632bda8a8c', int64), 0.0_real64), transfer(int(z'3eeae3c242ec49fc', int64), 0.0_real64), &
                     transfer(int(z'3eeb1c2159fe096c', int64), 0.0_real64), transfer(int(z'3eeb5480710fc8dc', int64), 0.0_real64), &
                     transfer(int(z'3eeb8d68f880c983', int64), 0.0_real64), transfer(int(z'3eebc6517ff1ca2a', int64), 0.0_real64), &
                     transfer(int(z'3eebfeb09703899a', int64), 0.0_real64), transfer(int(z'3eec38228ed3cb77', int64), 0.0_real64), &
                     transfer(int(z'3eec710b1644cc1e', int64), 0.0_real64), transfer(int(z'3eecaa7d0e150dfc', int64), 0.0_real64), &
                     transfer(int(z'3eece3ef05e54fd9', int64), 0.0_real64), transfer(int(z'3eed1d60fdb591b7', int64), 0.0_real64), &
                     transfer(int(z'3eed56d2f585d394', int64), 0.0_real64), transfer(int(z'3eed90ce5db556a8', int64), 0.0_real64), &
                     transfer(int(z'3eedcac9c5e4d9bc', int64), 0.0_real64), transfer(int(z'3eee04c52e145cd1', int64), 0.0_real64), &
                     transfer(int(z'3eee3ec09643dfe5', int64), 0.0_real64), transfer(int(z'3eee79456ed2a430', int64), 0.0_real64), &
                     transfer(int(z'3eeeb340d7022744', int64), 0.0_real64), transfer(int(z'3eeeedc5af90eb8f', int64), 0.0_real64), &
                     transfer(int(z'3eef284a881fafda', int64), 0.0_real64), transfer(int(z'3eef6358d10db55b', int64), 0.0_real64), &
                     transfer(int(z'3eef9ddda99c79a6', int64), 0.0_real64), transfer(int(z'3eefd8ebf28a7f28', int64), 0.0_real64), &
                     transfer(int(z'3ef009fd1dbc4255', int64), 0.0_real64), transfer(int(z'3ef027c8fa62e5b1', int64), 0.0_real64), &
                     transfer(int(z'3ef045501ed9e872', int64), 0.0_real64), transfer(int(z'3ef0631bfb808bce', int64), 0.0_real64), &
                     transfer(int(z'3ef080e7d8272f2a', int64), 0.0_real64), transfer(int(z'3ef09eb3b4cdd286', int64), 0.0_real64), &
                     transfer(int(z'3ef0bc7f917475e2', int64), 0.0_real64), transfer(int(z'3ef0da4b6e1b193f', int64), 0.0_real64), &
                     transfer(int(z'3ef0f85c02f15d36', int64), 0.0_real64), transfer(int(z'3ef1166c97c7a12e', int64), 0.0_real64), &
                     transfer(int(z'3ef1347d2c9de525', int64), 0.0_real64), transfer(int(z'3ef152d279a3c9b8', int64), 0.0_real64), &
                     transfer(int(z'3ef170e30e7a0db0', int64), 0.0_real64), transfer(int(z'3ef18f385b7ff242', int64), 0.0_real64), &
                     transfer(int(z'3ef1ad8da885d6d5', int64), 0.0_real64), transfer(int(z'3ef1cbe2f58bbb68', int64), 0.0_real64), &
                     transfer(int(z'3ef1ea3842919ffb', int64), 0.0_real64), transfer(int(z'3ef2088d8f97848e', int64), 0.0_real64), &
                     transfer(int(z'3ef2272794cd09bc', int64), 0.0_real64), transfer(int(z'3ef245c19a028eea', int64), 0.0_real64), &
                     transfer(int(z'3ef2645b9f381419', int64), 0.0_real64), transfer(int(z'3ef282f5a46d9947', int64), 0.0_real64), &
                     transfer(int(z'3ef2a1d461d2bf10', int64), 0.0_real64), transfer(int(z'3ef2c06e6708443f', int64), 0.0_real64), &
                             transfer(int(z'3ef2df4d246d6a08', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_3(181) = [ &
                     transfer(int(z'3eb69e8f9119d0b1', int64), 0.0_real64), transfer(int(z'3eb757c28218bb0c', int64), 0.0_real64), &
                     transfer(int(z'3eb814910a12a352', int64), 0.0_real64), transfer(int(z'3eb8d4fb29078982', int64), 0.0_real64), &
                     transfer(int(z'3eb99900def76d9c', int64), 0.0_real64), transfer(int(z'3eba60a22be24fa2', int64), 0.0_real64), &
                     transfer(int(z'3ebb2bf50d48110b', int64), 0.0_real64), transfer(int(z'3ebbfae385a8d05e', int64), 0.0_real64), &
                     transfer(int(z'3ebccd8392846f16', int64), 0.0_real64), transfer(int(z'3ebda3bf365b0bb7', int64), 0.0_real64), &
                     transfer(int(z'3ebe7db76d6c787a', int64), 0.0_real64), transfer(int(z'3ebf5b563a38d3e4', int64), 0.0_real64), &
                     transfer(int(z'3ec01e534dc00759', int64), 0.0_real64), transfer(int(z'3ec090d448a11471', int64), 0.0_real64), &
                     transfer(int(z'3ec105338d1f899a', int64), 0.0_real64), transfer(int(z'3ec17b661c7b7617', int64), 0.0_real64), &
                     transfer(int(z'3ec1f376f574caa4', int64), 0.0_real64), transfer(int(z'3ec26d66180b8741', int64), 0.0_real64), &
                     transfer(int(z'3ec2e92e04dfb390', int64), 0.0_real64), transfer(int(z'3ec366cebbf14f91', int64), 0.0_real64), &
                     transfer(int(z'3ec3e64dbca053a3', int64), 0.0_real64), transfer(int(z'3ec467ab06ecbfc5', int64), 0.0_real64), &
                     transfer(int(z'3ec4eae11b769b98', int64), 0.0_real64), transfer(int(z'3ec56ff5799ddf7c', int64), 0.0_real64), &
                     transfer(int(z'3ec5f6e821628b70', int64), 0.0_real64), transfer(int(z'3ec67fb39364a717', int64), 0.0_real64), &
                     transfer(int(z'3ec70a5d4f042acd', int64), 0.0_real64), transfer(int(z'3ec796dfd4e11e36', int64), 0.0_real64), &
                     transfer(int(z'3ec82540a45b79ae', int64), 0.0_real64), transfer(int(z'3ec8b57fbd733d37', int64), 0.0_real64), &
                     transfer(int(z'3ec9479221687814', int64), 0.0_real64), transfer(int(z'3ec9db82cefb1b01', int64), 0.0_real64), &
                     transfer(int(z'3eca7151c62b25fe', int64), 0.0_real64), transfer(int(z'3ecb08f40838a84f', int64), 0.0_real64), &
                     transfer(int(z'3ecba26f14839a52', int64), 0.0_real64), transfer(int(z'3ecc3dc2eb0bfc06', int64), 0.0_real64), &
                     transfer(int(z'3eccdaf50b31c5cb', int64), 0.0_real64), transfer(int(z'3ecd79f4f6d50e86', int64), 0.0_real64), &
                     transfer(int(z'3ece1acdacb5c6f2', int64), 0.0_real64), transfer(int(z'3ecebd79ad73f6b2', int64), 0.0_real64), &
                     transfer(int(z'3ecf61fe786f9624', int64), 0.0_real64), transfer(int(z'3ed0042887745a45', int64), 0.0_real64), &
                     transfer(int(z'3ed0583e37cfa152', int64), 0.0_real64), transfer(int(z'3ed0ad380e39abaa', int64), 0.0_real64), &
                     transfer(int(z'3ed1031b8a1271ab', int64), 0.0_real64), transfer(int(z'3ed159e8ab59f357', int64), 0.0_real64), &
                     transfer(int(z'3ed1b199f2b0384e', int64), 0.0_real64), transfer(int(z'3ed20a34df7538ef', int64), 0.0_real64), &
                     transfer(int(z'3ed263b1329900ac', int64), 0.0_real64), transfer(int(z'3ed2be172b2b8413', int64), 0.0_real64), &
                     transfer(int(z'3ed3195e8a1cce96', int64), 0.0_real64), transfer(int(z'3ed3758cceccd894', int64), 0.0_real64), &
                     transfer(int(z'3ed3d29c79dba9ae', int64), 0.0_real64), transfer(int(z'3ed4308d8b4941e4', int64), 0.0_real64), &
                     transfer(int(z'3ed48f62c2c59d66', int64), 0.0_real64), transfer(int(z'3ed4ef1960a0c004', int64), 0.0_real64), &
                     transfer(int(z'3ed54faea52aad8f', int64), 0.0_real64), transfer(int(z'3ed5b12290636607', int64), 0.0_real64), &
                     transfer(int(z'3ed6137aa1aae1cb', int64), 0.0_real64), transfer(int(z'3ed676abda41301d', int64), 0.0_real64), &
                     transfer(int(z'3ed6dabbb986495d', int64), 0.0_real64), transfer(int(z'3ed73faa3f7a2d89', int64), 0.0_real64), &
                     transfer(int(z'3ed7a574ac6ce074', int64), 0.0_real64), transfer(int(z'3ed80c1840ae65ed', int64), 0.0_real64), &
                     transfer(int(z'3ed87397bbeeba25', int64), 0.0_real64), transfer(int(z'3ed8dbf05e7de0eb', int64), 0.0_real64), &
                     transfer(int(z'3ed94522285bda3f', int64), 0.0_real64), transfer(int(z'3ed9af2a59d8a9f4', int64), 0.0_real64), &
                     transfer(int(z'3eda1a0bb2a44c37', int64), 0.0_real64), transfer(int(z'3eda85c3730ec4da', int64), 0.0_real64), &
                     transfer(int(z'3edaf24edb6817ad', int64), 0.0_real64), transfer(int(z'3edb5fadebb044b0', int64), 0.0_real64), &
                     transfer(int(z'3edbcde623474443', int64), 0.0_real64), transfer(int(z'3edc3cef431d21d6', int64), 0.0_real64), &
                     transfer(int(z'3edcacc94b31dd6b', int64), 0.0_real64), transfer(int(z'3edd1d717bd57ad2', int64), 0.0_real64), &
                     transfer(int(z'3edd8eed5467f269', int64), 0.0_real64), transfer(int(z'3ede013a15394801', int64), 0.0_real64), &
                     transfer(int(z'3ede74523ee9833d', int64), 0.0_real64), transfer(int(z'3edee8389128a04a', int64), 0.0_real64), &
                     transfer(int(z'3edf5ced0bf69f29', int64), 0.0_real64), transfer(int(z'3edfd26cefa383ac', int64), 0.0_real64), &
                     transfer(int(z'3ee0245c1e17a6e8', int64), 0.0_real64), transfer(int(z'3ee05fe4b91d029d', int64), 0.0_real64), &
                     transfer(int(z'3ee09bd46869cf3b', int64), 0.0_real64), transfer(int(z'3ee0d8270c76127b', int64), 0.0_real64), &
                     transfer(int(z'3ee114de0519ca75', int64), 0.0_real64), transfer(int(z'3ee151f7f27cf912', int64), 0.0_real64), &
                     transfer(int(z'3ee18f7374c7a039', int64), 0.0_real64), transfer(int(z'3ee1cd51ebd1be02', int64), 0.0_real64), &
                     transfer(int(z'3ee20b93579b526d', int64), 0.0_real64), transfer(int(z'3ee24a33989c6334', int64), 0.0_real64), &
                     transfer(int(z'3ee28936ce5cea9e', int64), 0.0_real64), transfer(int(z'3ee2c89a392cec7a', int64), 0.0_real64), &
                     transfer(int(z'3ee3085c79346ab2', int64), 0.0_real64), transfer(int(z'3ee348804e236175', int64), 0.0_real64), &
                     transfer(int(z'3ee389019871d67b', int64), 0.0_real64), transfer(int(z'3ee3c9e1b7f7c7dd', int64), 0.0_real64), &
                     transfer(int(z'3ee40b1ded05396b', int64), 0.0_real64), transfer(int(z'3ee44cba5722256d', int64), 0.0_real64), &
                     transfer(int(z'3ee48eb2d6c6919a', int64), 0.0_real64), transfer(int(z'3ee4d1076bf27df5', int64), 0.0_real64), &
                     transfer(int(z'3ee513b6b6cdec63', int64), 0.0_real64), transfer(int(z'3ee556c4d6e0d72e', int64), 0.0_real64), &
                     transfer(int(z'3ee59a332c033c6b', int64), 0.0_real64), transfer(int(z'3ee5ddf3f7c52f30', int64), 0.0_real64), &
                     transfer(int(z'3ee62214f8969c68', int64), 0.0_real64), transfer(int(z'3ee6668870079727', int64), 0.0_real64), &
                     transfer(int(z'3ee6ab5c1c880c59', int64), 0.0_real64), transfer(int(z'3ee6f0823fa80f12', int64), 0.0_real64), &
                     transfer(int(z'3ee7360897d78c3e', int64), 0.0_real64), transfer(int(z'3ee77be166a696f2', int64), 0.0_real64), &
                     transfer(int(z'3ee7c21a6a851c19', int64), 0.0_real64), transfer(int(z'3ee80898269341db', int64), 0.0_real64), &
                     transfer(int(z'3ee84f83d620cefc', int64), 0.0_real64), transfer(int(z'3ee896b43dddfcb8', int64), 0.0_real64), &
                     transfer(int(z'3ee8de44daaaa4e7', int64), 0.0_real64), transfer(int(z'3ee92627ee16da9e', int64), 0.0_real64), &
                     transfer(int(z'3ee96e5d78229ddc', int64), 0.0_real64), transfer(int(z'3ee9b6e578cdeea1', int64), 0.0_real64), &
                     transfer(int(z'3ee9ffbff018ccee', int64), 0.0_real64), transfer(int(z'3eea48fa9c7325ad', int64), 0.0_real64), &
                     transfer(int(z'3eea927a00fd1f08', int64), 0.0_real64), transfer(int(z'3eeadc4bdc26a5ea', int64), 0.0_real64), &
                     transfer(int(z'3eeb267dec5fa73f', int64), 0.0_real64), transfer(int(z'3eeb70f4b4c8492f', int64), 0.0_real64), &
                     transfer(int(z'3eebbbbdf3d078a7', int64), 0.0_real64), transfer(int(z'3eec06d9a97835a6', int64), 0.0_real64), &
                     transfer(int(z'3eec5247d5bf802c', int64), 0.0_real64), transfer(int(z'3eec9e0878a6583a', int64), 0.0_real64), &
                     transfer(int(z'3eecea1b922cbdce', int64), 0.0_real64), transfer(int(z'3eed367363e2c3fe', int64), 0.0_real64), &
                     transfer(int(z'3eed831dac3857b5', int64), 0.0_real64), transfer(int(z'3eedd01a6b2d78f4', int64), 0.0_real64), &
                     transfer(int(z'3eee1d5be2523acd', int64), 0.0_real64), transfer(int(z'3eee6afd8e86771a', int64), 0.0_real64), &
                     transfer(int(z'3eeeb8d6347a6717', int64), 0.0_real64), transfer(int(z'3eef0701510de49a', int64), 0.0_real64), &
                     transfer(int(z'3eef557ee440efa5', int64), 0.0_real64), transfer(int(z'3eefa4412fa39b4b', int64), 0.0_real64), &
                     transfer(int(z'3eeff355f1a5d478', int64), 0.0_real64), transfer(int(z'3ef02157b5ebd721', int64), 0.0_real64), &
                     transfer(int(z'3ef0492dae548ac8', int64), 0.0_real64), transfer(int(z'3ef0712602d50ebe', int64), 0.0_real64), &
                     transfer(int(z'3ef09940b36d6301', int64), 0.0_real64), transfer(int(z'3ef0c1849f557e08', int64), 0.0_real64), &
                     transfer(int(z'3ef0e9eae755695d', int64), 0.0_real64), transfer(int(z'3ef112738b6d24ff', int64), 0.0_real64), &
                     transfer(int(z'3ef13b1e8b9cb0ef', int64), 0.0_real64), transfer(int(z'3ef163f2c71c03a3', int64), 0.0_real64), &
                     transfer(int(z'3ef18ce95eb326a4', int64), 0.0_real64), transfer(int(z'3ef1b5fb732a237d', int64), 0.0_real64), &
                     transfer(int(z'3ef1df3da228dd8f', int64), 0.0_real64), transfer(int(z'3ef2089b4e07717a', int64), 0.0_real64), &
                     transfer(int(z'3ef2321b55fdd5b2', int64), 0.0_real64), transfer(int(z'3ef25bbdba0c0a37', int64), 0.0_real64), &
                     transfer(int(z'3ef285827a320f0b', int64), 0.0_real64), transfer(int(z'3ef2af7075a7daa2', int64), 0.0_real64), &
                     transfer(int(z'3ef2d979edfd8010', int64), 0.0_real64), transfer(int(z'3ef303a5c26af5cd', int64), 0.0_real64), &
                     transfer(int(z'3ef32df3f2f03bd7', int64), 0.0_real64), transfer(int(z'3ef358647f8d522e', int64), 0.0_real64), &
                     transfer(int(z'3ef382f0890a425e', int64), 0.0_real64), transfer(int(z'3ef3ada5cdd6f951', int64), 0.0_real64), &
                     transfer(int(z'3ef3d8768f838a1b', int64), 0.0_real64), transfer(int(z'3ef40369ad47eb34', int64), 0.0_real64), &
                     transfer(int(z'3ef42e7f27241c9a', int64), 0.0_real64), transfer(int(z'3ef459b01de027d8', int64), 0.0_real64), &
                     transfer(int(z'3ef4850370b40363', int64), 0.0_real64), transfer(int(z'3ef4b0791f9faf3d', int64), 0.0_real64), &
                     transfer(int(z'3ef4dc0a4b6b34ee', int64), 0.0_real64), transfer(int(z'3ef507bdd34e8aec', int64), 0.0_real64), &
                     transfer(int(z'3ef53393b749b139', int64), 0.0_real64), transfer(int(z'3ef55f851824b15d', int64), 0.0_real64), &
                     transfer(int(z'3ef58b98d51781ce', int64), 0.0_real64), transfer(int(z'3ef5b7c80eea2c18', int64), 0.0_real64), &
                     transfer(int(z'3ef5e412c59cb039', int64), 0.0_real64), transfer(int(z'3ef6107fd86704a8', int64), 0.0_real64), &
                     transfer(int(z'3ef63d0f47492965', int64), 0.0_real64), transfer(int(z'3ef669ba330b27f9', int64), 0.0_real64), &
                             transfer(int(z'3ef69679bc7509ef', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_4(181) = [ &
                     transfer(int(z'3eade193c81ed0d7', int64), 0.0_real64), transfer(int(z'3eaf0301abd9d7fa', int64), 0.0_real64), &
                     transfer(int(z'3eb015d4783f058c', int64), 0.0_real64), transfer(int(z'3eb0adcd96d275b0', int64), 0.0_real64), &
                     transfer(int(z'3eb14972ca80ccd9', int64), 0.0_real64), transfer(int(z'3eb1e8caac239b79', int64), 0.0_real64), &
                     transfer(int(z'3eb28bdf21013a39', int64), 0.0_real64), transfer(int(z'3eb332bb27d999d7', int64), 0.0_real64), &
                     transfer(int(z'3eb3dd5ec0acba52', int64), 0.0_real64), transfer(int(z'3eb48bd4ea3a8c67', int64), 0.0_real64), &
                     transfer(int(z'3eb53e33a202f18f', int64), 0.0_real64), transfer(int(z'3eb5f464ea860852', int64), 0.0_real64), &
                     transfer(int(z'3eb6ae7ec143b227', int64), 0.0_real64), transfer(int(z'3eb76c9723bbd08a', int64), 0.0_real64), &
                     transfer(int(z'3eb82e98146e8200', int64), 0.0_real64), transfer(int(z'3eb8f49790dba802', int64), 0.0_real64), &
                     transfer(int(z'3eb9be9599034292', int64), 0.0_real64), transfer(int(z'3eba8c9d2ba5426b', int64), 0.0_real64), &
                     transfer(int(z'3ebb5eb94781984a', int64), 0.0_real64), transfer(int(z'3ebc34deedd85372', int64), 0.0_real64), &
                     transfer(int(z'3ebd0f241c29555e', int64), 0.0_real64), transfer(int(z'3ebded7dd3b4ad4f', int64), 0.0_real64), &
                     transfer(int(z'3ebed00211fa3cc0', int64), 0.0_real64), transfer(int(z'3ebfb6b0d6fa03b1', int64), 0.0_real64), &
                     transfer(int(z'3ec050bf91fa08b2', int64), 0.0_real64), transfer(int(z'3ec0c8417b3423aa', int64), 0.0_real64), &
                     transfer(int(z'3ec141e3a68b4b1e', int64), 0.0_real64), transfer(int(z'3ec1bd9b153f8e53', int64), 0.0_real64), &
                     transfer(int(z'3ec23b6d46b0e5a5', int64), 0.0_real64), transfer(int(z'3ec2bb65399f41d2', int64), 0.0_real64), &
                     transfer(int(z'3ec33d7d6eaaaa7b', int64), 0.0_real64), transfer(int(z'3ec3c1bb65331800', int64), 0.0_real64), &
                     transfer(int(z'3ec4481f1d388a5f', int64), 0.0_real64), transfer(int(z'3ec4d0a3175b093b', int64), 0.0_real64), &
                     transfer(int(z'3ec55b52525a8550', int64), 0.0_real64), transfer(int(z'3ec5e82cce36fe9e', int64), 0.0_real64), &
                     transfer(int(z'3ec6772d0b907cc6', int64), 0.0_real64), transfer(int(z'3ec7085e0926f087', int64), 0.0_real64), &
                     transfer(int(z'3ec79bba479a6180', int64), 0.0_real64), transfer(int(z'3ec83141c6eacfb3', int64), 0.0_real64), &
                     transfer(int(z'3ec8c8fa0678337d', int64), 0.0_real64), transfer(int(z'3ec962e306428cdf', int64), 0.0_real64), &
                     transfer(int(z'3ec9fef746e9e37a', int64), 0.0_real64), transfer(int(z'3eca9d41c72e280b', int64), 0.0_real64), &
                     transfer(int(z'3ecb3dc2870f5a91', int64), 0.0_real64), transfer(int(z'3ecbe06e87cd8a51', int64), 0.0_real64), &
                     transfer(int(z'3ecc8550c828a807', int64), 0.0_real64), transfer(int(z'3ecd2c63c8c0bb54', int64), 0.0_real64), &
                     transfer(int(z'3ecdd5ad08f5bc97', int64), 0.0_real64), transfer(int(z'3ece81270967b372', int64), 0.0_real64), &
                     transfer(int(z'3ecf2edcc8d690a0', int64), 0.0_real64), transfer(int(z'3ecfdec348826367', int64), 0.0_real64), &
                     transfer(int(z'3ed0487003e59211', int64), 0.0_real64), transfer(int(z'3ed0a296c3a86d3b', int64), 0.0_real64), &
                     transfer(int(z'3ed0fddb62e9bb8f', int64), 0.0_real64), transfer(int(z'3ed15a38624984af', int64), 0.0_real64), &
                     transfer(int(z'3ed1b7b08177c4ca', int64), 0.0_real64), transfer(int(z'3ed21643c0747bdf', int64), 0.0_real64), &
                     transfer(int(z'3ed275ef5f8fadc1', int64), 0.0_real64), transfer(int(z'3ed2d6b8de2952cc', int64), 0.0_real64), &
                     transfer(int(z'3ed33897fd317674', int64), 0.0_real64), transfer(int(z'3ed39b94fbb80d46', int64), 0.0_real64), &
                     transfer(int(z'3ed3ffaa5a5d1ee4', int64), 0.0_real64), transfer(int(z'3ed464d81920ab4e', int64), 0.0_real64), &
                     transfer(int(z'3ed4cb1e3802b283', int64), 0.0_real64), transfer(int(z'3ed5328236632ce3', int64), 0.0_real64), &
                     transfer(int(z'3ed59afbd53225df', int64), 0.0_real64), transfer(int(z'3ed6049093cf95d6', int64), 0.0_real64), &
                     transfer(int(z'3ed66f38332b883a', int64), 0.0_real64), transfer(int(z'3ed6dafdb205edc9', int64), 0.0_real64), &
                     transfer(int(z'3ed747d6119ed5c5', int64), 0.0_real64), transfer(int(z'3ed7b5c6d156388d', int64), 0.0_real64), &
                     transfer(int(z'3ed824cd317c19f1', int64), 0.0_real64), transfer(int(z'3ed894e9321079f2', int64), 0.0_real64), &
                     transfer(int(z'3ed9061d92c354bf', int64), 0.0_real64), transfer(int(z'3ed9786793e4ae28', int64), 0.0_real64), &
                     transfer(int(z'3ed9ebc1b6148dcf', int64), 0.0_real64), transfer(int(z'3eda60343862e843', int64), 0.0_real64), &
                     transfer(int(z'3edad5bc5b1fc152', int64), 0.0_real64), transfer(int(z'3edb4c51df3b2471', int64), 0.0_real64), &
                     transfer(int(z'3edbc3fd03c5062d', int64), 0.0_real64), transfer(int(z'3edc3cbdc8bd6685', int64), 0.0_real64), &
                     transfer(int(z'3edcb68bef1450ec', int64), 0.0_real64), transfer(int(z'3edd316a3679c191', int64), 0.0_real64), &
                     transfer(int(z'3eddad5b5e9db4a4', int64), 0.0_real64), transfer(int(z'3ede2a59e82031c6', int64), 0.0_real64), &
                     transfer(int(z'3edea86892b13526', int64), 0.0_real64), transfer(int(z'3edf27875e50bec5', int64), 0.0_real64), &
                     transfer(int(z'3edfa7b0cb9ed643', int64), 0.0_real64), transfer(int(z'3ee01473cd25bbe8', int64), 0.0_real64), &
                     transfer(int(z'3ee0559745034fce', int64), 0.0_real64), transfer(int(z'3ee0973d4e082e74', int64), 0.0_real64), &
                     transfer(int(z'3ee0d96a07bc5222', int64), 0.0_real64), transfer(int(z'3ee11c1c1247bcc0', int64), 0.0_real64), &
                     transfer(int(z'3ee15f536daa6e4e', int64), 0.0_real64), transfer(int(z'3ee1a30d5a346a9d', int64), 0.0_real64), &
                     transfer(int(z'3ee1e74c9795addc', int64), 0.0_real64), transfer(int(z'3ee22c1125ce380a', int64), 0.0_real64), &
                     transfer(int(z'3ee27156e5560ee2', int64), 0.0_real64), transfer(int(z'3ee2b71f3605307b', int64), 0.0_real64), &
                     transfer(int(z'3ee2fd6b77b39aec', int64), 0.0_real64), transfer(int(z'3ee344378ad953ee', int64), 0.0_real64), &
                     transfer(int(z'3ee38b862f2657b1', int64), 0.0_real64), transfer(int(z'3ee3d357649aa635', int64), 0.0_real64), &
                     transfer(int(z'3ee41ba86b86434b', int64), 0.0_real64), transfer(int(z'3ee4647943e92ef2', int64), 0.0_real64), &
                     transfer(int(z'3ee4adcb4d9b6743', int64), 0.0_real64), transfer(int(z'3ee4f799093cf3de', int64), 0.0_real64), &
                     transfer(int(z'3ee541f0353dc1b0', int64), 0.0_real64), transfer(int(z'3ee58cb97445f128', int64), 0.0_real64), &
                     transfer(int(z'3ee5d7fe653d74ea', int64), 0.0_real64), transfer(int(z'3ee623ccc69439e3', int64), 0.0_real64), &
                     transfer(int(z'3ee67016d9da5328', int64), 0.0_real64), transfer(int(z'3ee6bcdc9f0fc0b6', int64), 0.0_real64), &
                     transfer(int(z'3ee70a1e16348290', int64), 0.0_real64), transfer(int(z'3ee757db3f4898b5', int64), 0.0_real64), &
                     transfer(int(z'3ee7a6141a4c0324', int64), 0.0_real64), transfer(int(z'3ee7f4c8a73ec1de', int64), 0.0_real64), &
                     transfer(int(z'3ee843f8e620d4e3', int64), 0.0_real64), transfer(int(z'3ee8939718824f48', int64), 0.0_real64), &
                     transfer(int(z'3ee8e3bebb430ae2', int64), 0.0_real64), transfer(int(z'3ee9345451832ddc', int64), 0.0_real64), &
                     transfer(int(z'3ee985735822920c', int64), 0.0_real64), transfer(int(z'3ee9d70052415d9c', int64), 0.0_real64), &
                     transfer(int(z'3eea28fb3fdf908a', int64), 0.0_real64), transfer(int(z'3eea7b71df6d17c3', int64), 0.0_real64), &
                     transfer(int(z'3eeace6430e9f347', int64), 0.0_real64), transfer(int(z'3eeb21d234562316', int64), 0.0_real64), &
                     transfer(int(z'3eeb75bbe9b1a730', int64), 0.0_real64), transfer(int(z'3eebca05d41ca5bd', int64), 0.0_real64), &
                     transfer(int(z'3eec1ecb7076f894', int64), 0.0_real64), transfer(int(z'3eec740cbec09fb7', int64), 0.0_real64), &
                     transfer(int(z'3eecc9c9bef99b24', int64), 0.0_real64), transfer(int(z'3eed1fe6f4421104', int64), 0.0_real64), &
                     transfer(int(z'3eed767fdb79db30', int64), 0.0_real64), transfer(int(z'3eedcd9474a0f9a6', int64), 0.0_real64), &
                     transfer(int(z'3eee251701477f7b', int64), 0.0_real64), transfer(int(z'3eee7d07816d6caf', int64), 0.0_real64), &
                     transfer(int(z'3eeed565f512c142', int64), 0.0_real64), transfer(int(z'3eef2e325c377d34', int64), 0.0_real64), &
                     transfer(int(z'3eef877a754b8d70', int64), 0.0_real64), transfer(int(z'3eefe13081df050c', int64), 0.0_real64), &
                     transfer(int(z'3ef01da361c0fb8d', int64), 0.0_real64), transfer(int(z'3ef04aec5b8a1eba', int64), 0.0_real64), &
                     transfer(int(z'3ef0786c4f12f597', int64), 0.0_real64), transfer(int(z'3ef0a62a1b937698', int64), 0.0_real64), &
                     transfer(int(z'3ef0d4112363be5e', int64), 0.0_real64), transfer(int(z'3ef10236042bb048', int64), 0.0_real64), &
                     transfer(int(z'3ef13091deb355e3', int64), 0.0_real64), transfer(int(z'3ef15f24b2faaf2c', int64), 0.0_real64), &
                     transfer(int(z'3ef18de7a1c9c5b0', int64), 0.0_real64), transfer(int(z'3ef1bce869908658', int64), 0.0_real64), &
                     transfer(int(z'3ef1ec194bdf043a', int64), 0.0_real64), transfer(int(z'3ef21b7a48b53f56', int64), 0.0_real64), &
                     transfer(int(z'3ef24b191e832497', int64), 0.0_real64), transfer(int(z'3ef27ae80ed8c712', int64), 0.0_real64), &
                     transfer(int(z'3ef2aaedf8ee1d3c', int64), 0.0_real64), transfer(int(z'3ef2db23fd8b30a0', int64), 0.0_real64), &
                     transfer(int(z'3ef30b90fbe7f7b3', int64), 0.0_real64), transfer(int(z'3ef33c2e14cc7c00', int64), 0.0_real64), &
                     transfer(int(z'3ef36d022770b3fd', int64), 0.0_real64), transfer(int(z'3ef39e0d33d49fa8', int64), 0.0_real64), &
                     transfer(int(z'3ef3cf417b885218', int64), 0.0_real64), transfer(int(z'3ef400acbcfbb837', int64), 0.0_real64), &
                     transfer(int(z'3ef4324ef82ed205', int64), 0.0_real64), transfer(int(z'3ef464214de9a90d', int64), 0.0_real64), &
                     transfer(int(z'3ef4961cdef446d8', int64), 0.0_real64), transfer(int(z'3ef4c85d282e853f', int64), 0.0_real64), &
                     transfer(int(z'3ef4fabfcd8093f4', int64), 0.0_real64), transfer(int(z'3ef52d596c925658', int64), 0.0_real64), &
                     transfer(int(z'3ef56023262bd5f5', int64), 0.0_real64), transfer(int(z'3ef5931cfa4d12cc', int64), 0.0_real64), &
                     transfer(int(z'3ef5c646e8f60cdd', int64), 0.0_real64), transfer(int(z'3ef5f9a0f226c427', int64), 0.0_real64), &
                     transfer(int(z'3ef62d2b15df38ab', int64), 0.0_real64), transfer(int(z'3ef660e5541f6a68', int64), 0.0_real64), &
                     transfer(int(z'3ef694cface7595f', int64), 0.0_real64), transfer(int(z'3ef6c8f0ff6efc05', int64), 0.0_real64), &
                     transfer(int(z'3ef6fd34ae0e6ef9', int64), 0.0_real64), transfer(int(z'3ef731af566d959d', int64), 0.0_real64), &
                             transfer(int(z'3ef7665a1954797a', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_5(181) = [ &
                     transfer(int(z'3ea3223d07f07ecc', int64), 0.0_real64), transfer(int(z'3ea3f530a4e5431d', int64), 0.0_real64), &
                     transfer(int(z'3ea4ce7d55de0460', int64), 0.0_real64), transfer(int(z'3ea5ae36e56773e8', int64), 0.0_real64), &
                     transfer(int(z'3ea69479e9db039f', int64), 0.0_real64), transfer(int(z'3ea7815a2dc564da', int64), 0.0_real64), &
                     transfer(int(z'3ea874efe199a937', int64), 0.0_real64), transfer(int(z'3ea96f5568be127b', int64), 0.0_real64), &
                     transfer(int(z'3eaa709e8dbf51fa', int64), 0.0_real64), transfer(int(z'3eab78df1b2a1908', int64), 0.0_real64), &
                     transfer(int(z'3eac88317464a969', int64), 0.0_real64), transfer(int(z'3ead9ea963fbb472', int64), 0.0_real64), &
                     transfer(int(z'3eaebc5f1a624bc0', int64), 0.0_real64), transfer(int(z'3eafe161fc3ec05d', int64), 0.0_real64), &
                     transfer(int(z'3eb086e74ff5421a', int64), 0.0_real64), transfer(int(z'3eb120dc67f9244b', int64), 0.0_real64), &
                     transfer(int(z'3eb1be92791e36e8', int64), 0.0_real64), transfer(int(z'3eb2602619bdebdc', int64), 0.0_real64), &
                     transfer(int(z'3eb3058c4b18526a', int64), 0.0_real64), transfer(int(z'3eb3aedb0aad4c0c', int64), 0.0_real64), &
                     transfer(int(z'3eb45c12587cd8c1', int64), 0.0_real64), transfer(int(z'3eb50d483206da02', int64), 0.0_real64), &
                     transfer(int(z'3eb5c27c974b4fd0', int64), 0.0_real64), transfer(int(z'3eb67bba870a2ae8', int64), 0.0_real64), &
                     transfer(int(z'3eb7390d00035c06', int64), 0.0_real64), transfer(int(z'3eb7fa7f00f6d3e7', int64), 0.0_real64), &
                     transfer(int(z'3eb8c01089e4928b', int64), 0.0_real64), transfer(int(z'3eb989d7984c796b', int64), 0.0_real64), &
                     transfer(int(z'3eba57c92d6e97ca', int64), 0.0_real64), transfer(int(z'3ebb29fb46cacf23', int64), 0.0_real64), &
                     transfer(int(z'3ebc0078e3211031', int64), 0.0_real64), transfer(int(z'3ebcdb3703b16a38', int64), 0.0_real64), &
                     transfer(int(z'3ebdba56a4bbaf6e', int64), 0.0_real64), transfer(int(z'3ebe9dccc77fef16', int64), 0.0_real64), &
                     transfer(int(z'3ebf85a46abe19ee', int64), 0.0_real64), transfer(int(z'3ec038f4469b1058', int64), 0.0_real64), &
                     transfer(int(z'3ec0b14c977401b0', int64), 0.0_real64), transfer(int(z'3ec12be0a749d95c', int64), 0.0_real64), &
                     transfer(int(z'3ec1a8b5f57c8fba', int64), 0.0_real64), transfer(int(z'3ec227cc820c24cb', int64), 0.0_real64), &
                     transfer(int(z'3ec2a929cc5890ec', int64), 0.0_real64), transfer(int(z'3ec32ccdd461d41f', int64), 0.0_real64), &
                     transfer(int(z'3ec3b2be1987e6c1', int64), 0.0_real64), transfer(int(z'3ec43b001b2ac130', int64), 0.0_real64), &
                     transfer(int(z'3ec4c58e59ea6b0f', int64), 0.0_real64), transfer(int(z'3ec5526e5526dcbb', int64), 0.0_real64), &
                     transfer(int(z'3ec5e1a58c400e94', int64), 0.0_real64), transfer(int(z'3ec673397e95f8f6', int64), 0.0_real64), &
                     transfer(int(z'3ec70724acc8a385', int64), 0.0_real64), transfer(int(z'3ec79d6c9638069e', int64), 0.0_real64), &
                     transfer(int(z'3ec83616ba441a9f', int64), 0.0_real64), transfer(int(z'3ec8d12318ecdf8a', int64), 0.0_real64), &
                     transfer(int(z'3ec96e91b232555c', int64), 0.0_real64), transfer(int(z'3eca0e6805747476', int64), 0.0_real64), &
                     transfer(int(z'3ecab0a612b33cd7', int64), 0.0_real64), transfer(int(z'3ecb5551594ea6dd', int64), 0.0_real64), &
                     transfer(int(z'3ecbfc6459e6ba2a', int64), 0.0_real64), transfer(int(z'3ecca5e493db6f1d', int64), 0.0_real64), &
                     transfer(int(z'3ecd51d7868cbe13', int64), 0.0_real64), transfer(int(z'3ece003d31faa70d', int64), 0.0_real64), &
                     transfer(int(z'3eceb11016c531ad', int64), 0.0_real64), transfer(int(z'3ecf6455b44c5650', int64), 0.0_real64), &
                     transfer(int(z'3ed00d09c4f806aa', int64), 0.0_real64), transfer(int(z'3ed06924cbd82b5e', int64), 0.0_real64), &
                     transfer(int(z'3ed0c67beec69942', int64), 0.0_real64), transfer(int(z'3ed1250f2dc35058', int64), 0.0_real64), &
                     transfer(int(z'3ed184de88ce509f', int64), 0.0_real64), transfer(int(z'3ed1e5ecbf979645', int64), 0.0_real64), &
                     transfer(int(z'3ed24839d21f214c', int64), 0.0_real64), transfer(int(z'3ed2abc300b4f584', int64), 0.0_real64), &
                     transfer(int(z'3ed3108dcab90b4c', int64), 0.0_real64), transfer(int(z'3ed37694b0cb6a44', int64), 0.0_real64), &
                     transfer(int(z'3ed3dddff1fc06fb', int64), 0.0_real64), transfer(int(z'3ed446674f3aece3', int64), 0.0_real64), &
                     transfer(int(z'3ed4b03047e8145b', int64), 0.0_real64), transfer(int(z'3ed51b3adc037d61', int64), 0.0_real64), &
                     transfer(int(z'3ed587870b8d27f7', int64), 0.0_real64), transfer(int(z'3ed5f514d685141d', int64), 0.0_real64), &
                     transfer(int(z'3ed663e17d3b45a3', int64), 0.0_real64), transfer(int(z'3ed6d3f27f0fb4e7', int64), 0.0_real64), &
                     transfer(int(z'3ed745451c5265ba', int64), 0.0_real64), transfer(int(z'3ed7b7d695535bee', int64), 0.0_real64), &
                     transfer(int(z'3ed82bac69728fe0', int64), 0.0_real64), transfer(int(z'3ed8a0c3d9000562', int64), 0.0_real64), &
                     transfer(int(z'3ed9171ce3fbbc73', int64), 0.0_real64), transfer(int(z'3ed98eba4a15b143', int64), 0.0_real64), &
                     transfer(int(z'3eda07994b9de7a2', int64), 0.0_real64), transfer(int(z'3eda81b728e46361', int64), 0.0_real64), &
                     transfer(int(z'3edafd1961491cdf', int64), 0.0_real64), transfer(int(z'3edb79bd351c17ec', int64), 0.0_real64), &
                     transfer(int(z'3edbf7a2a45d5488', int64), 0.0_real64), transfer(int(z'3edc76cc6ebccee3', int64), 0.0_real64), &
                     transfer(int(z'3edcf73514da8e9f', int64), 0.0_real64), transfer(int(z'3edd78dc96b693ba', int64), 0.0_real64), &
                     transfer(int(z'3eddfbc873b0d694', int64), 0.0_real64), transfer(int(z'3ede7ff5ec195afd', int64), 0.0_real64), &
                     transfer(int(z'3edf0562404024c7', int64), 0.0_real64), transfer(int(z'3edf8c102fd53020', int64), 0.0_real64), &
                     transfer(int(z'3ee009ffdd6c3e84', int64), 0.0_real64), transfer(int(z'3ee04e95b0f50991', int64), 0.0_real64), &
                     transfer(int(z'3ee093cc5234f565', int64), 0.0_real64), transfer(int(z'3ee0d9a2615403e9', int64), 0.0_real64), &
                     transfer(int(z'3ee12017de52351e', int64), 0.0_real64), transfer(int(z'3ee1672cc92f8903', int64), 0.0_real64), &
                     transfer(int(z'3ee1aee281c3fdaf', int64), 0.0_real64), transfer(int(z'3ee1f734e88798dc', int64), 0.0_real64), &
                     transfer(int(z'3ee24026bd2a56b9', int64), 0.0_real64), transfer(int(z'3ee289b53ffc3b18', int64), 0.0_real64), &
                     transfer(int(z'3ee2d3e49085403e', int64), 0.0_real64), transfer(int(z'3ee31eaf2f656dcd', int64), 0.0_real64), &
                     transfer(int(z'3ee36a193c24be0c', int64), 0.0_real64), transfer(int(z'3ee3b62156eb32e4', int64), 0.0_real64), &
                     transfer(int(z'3ee402c4c008d025', int64), 0.0_real64), transfer(int(z'3ee45006372d91ff', int64), 0.0_real64), &
                     transfer(int(z'3ee49de5bc597871', int64), 0.0_real64), transfer(int(z'3ee4ec61efb48565', int64), 0.0_real64), &
                     transfer(int(z'3ee53b713256c634', int64), 0.0_real64), transfer(int(z'3ee58b2ae1981a6f', int64), 0.0_real64), &
                     transfer(int(z'3ee5db7bbfa89cce', int64), 0.0_real64), transfer(int(z'3ee62c63cc884d4f', int64), 0.0_real64), &
                     transfer(int(z'3ee67de308372bf2', int64), 0.0_real64), transfer(int(z'3ee6d007312525a4', int64), 0.0_real64), &
                     transfer(int(z'3ee722c288e24d79', int64), 0.0_real64), transfer(int(z'3ee776150f6ea370', int64), 0.0_real64), &
                     transfer(int(z'3ee7c9fec4ca278a', int64), 0.0_real64), transfer(int(z'3ee81e7fa8f4d9c6', int64), 0.0_real64), &
                     transfer(int(z'3ee873a57a5ea711', int64), 0.0_real64), transfer(int(z'3ee8c954bc27b592', int64), 0.0_real64), &
                     transfer(int(z'3ee91fa8eb2fdf22', int64), 0.0_real64), transfer(int(z'3ee97694490736d4', int64), 0.0_real64), &
                     transfer(int(z'3ee9ce16d5adbca9', int64), 0.0_real64), transfer(int(z'3eea2622d2b383b5', int64), 0.0_real64), &
                     transfer(int(z'3eea7ed3bcf865cf', int64), 0.0_real64), transfer(int(z'3eead81bd60c760c', int64), 0.0_real64), &
                     transfer(int(z'3eeb31ed5f7fc77f', int64), 0.0_real64), transfer(int(z'3eeb8c63d6323401', int64), 0.0_real64), &
                     transfer(int(z'3eebe763bd43e1ba', int64), 0.0_real64), transfer(int(z'3eec42fad324bd95', int64), 0.0_real64), &
                     transfer(int(z'3eec9f2917d4c793', int64), 0.0_real64), transfer(int(z'3eecfbee8b53ffb3', int64), 0.0_real64), &
                     transfer(int(z'3eed593d6f32790a', int64), 0.0_real64), transfer(int(z'3eedb72381e02084', int64), 0.0_real64), &
                     transfer(int(z'3eee15a0c35cf620', int64), 0.0_real64), transfer(int(z'3eee74b533a8f9df', int64), 0.0_real64), &
                     transfer(int(z'3eeed45314543ed4', int64), 0.0_real64), transfer(int(z'3eef347a655ec500', int64), 0.0_real64), &
                     transfer(int(z'3eef9546a3a8663b', int64), 0.0_real64), transfer(int(z'3eeff69c525148ac', int64), 0.0_real64), &
                     transfer(int(z'3ef02c3db8acb62a', int64), 0.0_real64), transfer(int(z'3ef05d78df985f10', int64), 0.0_real64), &
                     transfer(int(z'3ef08ef8beb3a890', int64), 0.0_real64), transfer(int(z'3ef0c0bd55fe92ac', int64), 0.0_real64), &
                     transfer(int(z'3ef0f2cd84b113da', int64), 0.0_real64), transfer(int(z'3ef125294acb2c18', int64), 0.0_real64), &
                     transfer(int(z'3ef157c2e9dcee7c', int64), 0.0_real64), transfer(int(z'3ef18aa8205647f1', int64), 0.0_real64), &
                     transfer(int(z'3ef1bdd8ee373878', int64), 0.0_real64), transfer(int(z'3ef1f147950fd324', int64), 0.0_real64), &
                     transfer(int(z'3ef22501d35004e1', int64), 0.0_real64), transfer(int(z'3ef258f9ea87e0c4', int64), 0.0_real64), &
                     transfer(int(z'3ef28d3d992753b8', int64), 0.0_real64), transfer(int(z'3ef2c1c5fff66747', int64), 0.0_real64), &
                     transfer(int(z'3ef2f6931ef51b72', int64), 0.0_real64), transfer(int(z'3ef32ba4f6237038', int64), 0.0_real64), &
                     transfer(int(z'3ef360fb8581659a', int64), 0.0_real64), transfer(int(z'3ef39696cd0efb96', int64), 0.0_real64), &
                     transfer(int(z'3ef3cc6fed943bb8', int64), 0.0_real64), transfer(int(z'3ef40294a58112ec', int64), 0.0_real64), &
                     transfer(int(z'3ef438f736659445', int64), 0.0_real64), transfer(int(z'3ef46fa55eb1acaf', int64), 0.0_real64), &
                     transfer(int(z'3ef4a6915ff56f3f', int64), 0.0_real64), transfer(int(z'3ef4ddc21968d269', int64), 0.0_real64), &
                     transfer(int(z'3ef51530abd3dfba', int64), 0.0_real64), transfer(int(z'3ef54ce3f66e8da6', int64), 0.0_real64), &
                     transfer(int(z'3ef584dbf938dc2d', int64), 0.0_real64), transfer(int(z'3ef5bd18b432cb4f', int64), 0.0_real64), &
                     transfer(int(z'3ef5f59348246497', int64), 0.0_real64), transfer(int(z'3ef62e4bb50da804', int64), 0.0_real64), &
                     transfer(int(z'3ef6674fb95e8283', int64), 0.0_real64), transfer(int(z'3ef6a08ab76f10b1', int64), 0.0_real64), &
                             transfer(int(z'3ef6da0a6daf3f7a', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_6(181) = [ &
                     transfer(int(z'3e925a92ef38dc30', int64), 0.0_real64), transfer(int(z'3e9349a1c06d02dc', int64), 0.0_real64), &
                     transfer(int(z'3e9441b58b14a453', int64), 0.0_real64), transfer(int(z'3e95430315fc441d', int64), 0.0_real64), &
                     transfer(int(z'3e964dc38dd6c611', int64), 0.0_real64), transfer(int(z'3e976222eda3ed21', int64), 0.0_real64), &
                     transfer(int(z'3e98805ec7fcfd6e', int64), 0.0_real64), transfer(int(z'3e99a8a77dc81a35', int64), 0.0_real64), &
                     transfer(int(z'3e9adb31d5d1c702', int64), 0.0_real64), transfer(int(z'3e9c183296e6875d', int64), 0.0_real64), &
                     transfer(int(z'3e9d5fe2edb93f1b', int64), 0.0_real64), transfer(int(z'3e9eb2733b30117b', int64), 0.0_real64), &
                     transfer(int(z'3ea0080c230bc104', int64), 0.0_real64), transfer(int(z'3ea0bc859d913a4a', int64), 0.0_real64), &
                     transfer(int(z'3ea176c0708eb656', int64), 0.0_real64), transfer(int(z'3ea236d2998416a1', int64), 0.0_real64), &
                     transfer(int(z'3ea2fcdd14b12d60', int64), 0.0_real64), transfer(int(z'3ea3c8f3aca2abe8', int64), 0.0_real64), &
                     transfer(int(z'3ea49b352aa53448', int64), 0.0_real64), transfer(int(z'3ea573b78c38a7fb', int64), 0.0_real64), &
                     transfer(int(z'3ea6529767b678eb', int64), 0.0_real64), transfer(int(z'3ea737ef2084e8dc', int64), 0.0_real64), &
                     transfer(int(z'3ea823d4b423d948', int64), 0.0_real64), transfer(int(z'3ea91666ebdfec40', int64), 0.0_real64), &
                     transfer(int(z'3eaa0fb99245d317', int64), 0.0_real64), transfer(int(z'3eab0feb70a22fde', int64), 0.0_real64), &
                     transfer(int(z'3eac17128474e40d', int64), 0.0_real64), transfer(int(z'3ead2546fe310144', int64), 0.0_real64), &
                     transfer(int(z'3eae3aa3413cc948', int64), 0.0_real64), transfer(int(z'3eaf573f7e0b4db8', int64), 0.0_real64), &
                     transfer(int(z'3eb03d9b0c01682c', int64), 0.0_real64), transfer(int(z'3eb0d34b39e4d119', int64), 0.0_real64), &
                     transfer(int(z'3eb16cc0c6cfcabe', int64), 0.0_real64), transfer(int(z'3eb20a08e47575fc', int64), 0.0_real64), &
                     transfer(int(z'3eb2ab2e9195c391', int64), 0.0_real64), transfer(int(z'3eb3503cccf0a439', int64), 0.0_real64), &
                     transfer(int(z'3eb3f93e954608b2', int64), 0.0_real64), transfer(int(z'3eb4a633ea95f0fb', int64), 0.0_real64), &
                     transfer(int(z'3eb5573dc9202f49', int64), 0.0_real64), transfer(int(z'3eb60c5c30e4c39e', int64), 0.0_real64), &
                     transfer(int(z'3eb6c59a20a39eb6', int64), 0.0_real64), transfer(int(z'3eb78302971cb14d', int64), 0.0_real64), &
                     transfer(int(z'3eb844ab91cfdcde', int64), 0.0_real64), transfer(int(z'3eb90a8a11fd30aa', int64), 0.0_real64), &
                     transfer(int(z'3eb9d4bf13e47ee9', int64), 0.0_real64), transfer(int(z'3ebaa33f98c5d6de', int64), 0.0_real64), &
                     transfer(int(z'3ebb762c9ce10abe', int64), 0.0_real64), transfer(int(z'3ebc4d7b217629cd', int64), 0.0_real64), &
                     transfer(int(z'3ebd294c22c50642', int64), 0.0_real64), transfer(int(z'3ebe0994a20daf5f', int64), 0.0_real64), &
                     transfer(int(z'3ebeee6a9cd0069d', int64), 0.0_real64), transfer(int(z'3ebfd7ce130c0bfe', int64), 0.0_real64), &
                     transfer(int(z'3ec062ea8120d07d', int64), 0.0_real64), transfer(int(z'3ec0dc3fb53862c8', int64), 0.0_real64), &
                     transfer(int(z'3ec157ec252cb540', int64), 0.0_real64), transfer(int(z'3ec1d5f5505dc041', int64), 0.0_real64), &
                     transfer(int(z'3ec25660b62b7c2c', int64), 0.0_real64), transfer(int(z'3ec2d933d5f5e15d', int64), 0.0_real64), &
                     transfer(int(z'3ec35e6eafbcefd6', int64), 0.0_real64), transfer(int(z'3ec3e616c2e09ff3', int64), 0.0_real64), &
                     transfer(int(z'3ec470318ec0ea15', int64), 0.0_real64), transfer(int(z'3ec4fcc492bdc698', int64), 0.0_real64), &
                     transfer(int(z'3ec58bd54e372ddc', int64), 0.0_real64), transfer(int(z'3ec61d5e41cd2782', int64), 0.0_real64), &
                     transfer(int(z'3ec6b16feb9f9ca5', int64), 0.0_real64), transfer(int(z'3ec7480a4bae8d45', int64), 0.0_real64), &
                     transfer(int(z'3ec7e127e29a0104', int64), 0.0_real64), transfer(int(z'3ec87cd92e81e0fd', int64), 0.0_real64), &
                     transfer(int(z'3ec91b1e2f662d2f', int64), 0.0_real64), transfer(int(z'3ec9bbf6e546e59b', int64), 0.0_real64), &
                     transfer(int(z'3eca5f68cf8402a0', int64), 0.0_real64), transfer(int(z'3ecb05796d7d7c9b', int64), 0.0_real64), &
                     transfer(int(z'3ecbae28bf33538c', int64), 0.0_real64), transfer(int(z'3ecc597c44057fd2', int64), 0.0_real64), &
                     transfer(int(z'3ecd0773fbf4016d', int64), 0.0_real64), transfer(int(z'3ecdb81ae5bec91a', int64), 0.0_real64), &
                     transfer(int(z'3ece6b6b8205de79', int64), 0.0_real64), transfer(int(z'3ecf216b502939ea', int64), 0.0_real64), &
                     transfer(int(z'3ecfda254ee8cc2a', int64), 0.0_real64), transfer(int(z'3ed04ac73fc2523d', int64), 0.0_real64), &
                     transfer(int(z'3ed0a9d8f05e59cd', int64), 0.0_real64), transfer(int(z'3ed10a4a78f878f3', int64), 0.0_real64), &
                     transfer(int(z'3ed16c1bd990afaf', int64), 0.0_real64), transfer(int(z'3ed1cf4a527701d2', int64), 0.0_real64), &
                     transfer(int(z'3ed233de22bb63ea', int64), 0.0_real64), transfer(int(z'3ed299d1cafddd98', int64), 0.0_real64), &
                     transfer(int(z'3ed3012aca9e673b', int64), 0.0_real64), transfer(int(z'3ed369ebe14cfd02', int64), 0.0_real64), &
                     transfer(int(z'3ed3d4124f59a2bd', int64), 0.0_real64), transfer(int(z'3ed43fa0d474549c', int64), 0.0_real64), &
                     transfer(int(z'3ed4ac97709d129f', int64), 0.0_real64), transfer(int(z'3ed51af8e383d8f5', int64), 0.0_real64), &
                     transfer(int(z'3ed58ac52d28a79e', int64), 0.0_real64), transfer(int(z'3ed5fbfc4d8b7e9a', int64), 0.0_real64), &
                     transfer(int(z'3ed66ea1045c5a18', int64), 0.0_real64), transfer(int(z'3ed6e2b3519b3a18', int64), 0.0_real64), &
                     transfer(int(z'3ed75835f4f81ac9', int64), 0.0_real64), transfer(int(z'3ed7cf28ee72fc2c', int64), 0.0_real64), &
                     transfer(int(z'3ed847897e5be211', int64), 0.0_real64), transfer(int(z'3ed8c15d2412c4d7', int64), 0.0_real64), &
                     transfer(int(z'3ed93ca3df97a47d', int64), 0.0_real64), transfer(int(z'3ed9b95af13a84d4', int64), 0.0_real64), &
                     transfer(int(z'3eda3787d85b5e3b', int64), 0.0_real64), transfer(int(z'3edab72a94fa30b2', int64), 0.0_real64), &
                     transfer(int(z'3edb383da7b703da', int64), 0.0_real64), transfer(int(z'3edbbac94fa1cc41', int64), 0.0_real64), &
                     transfer(int(z'3edc3ecacd0a8db7', int64), 0.0_real64), transfer(int(z'3edcc4421ff1483d', int64), 0.0_real64), &
                     transfer(int(z'3edd4b320805f803', int64), 0.0_real64), transfer(int(z'3eddd397c598a0d7', int64), 0.0_real64), &
                     transfer(int(z'3ede5d78d8093b1a', int64), 0.0_real64), transfer(int(z'3edee8cfbff7ce6d', int64), 0.0_real64), &
                     transfer(int(z'3edf75a1fcc4532d', int64), 0.0_real64), transfer(int(z'3ee001f6675f6696', int64), 0.0_real64), &
                     transfer(int(z'3ee049d81af39e35', int64), 0.0_real64), transfer(int(z'3ee0927778f6ce8b', int64), 0.0_real64), &
                     transfer(int(z'3ee0dbd5e140f5b0', int64), 0.0_real64), transfer(int(z'3ee125f094221774', int64), 0.0_real64), &
                     transfer(int(z'3ee170ca514a3007', int64), 0.0_real64), transfer(int(z'3ee1bc5ef9314522', int64), 0.0_real64), &
                     transfer(int(z'3ee208b40b374f22', int64), 0.0_real64), transfer(int(z'3ee255c407fc55ab', int64), 0.0_real64), &
                     transfer(int(z'3ee2a3946ee0511a', int64), 0.0_real64), transfer(int(z'3ee2f223e00b4357', int64), 0.0_real64), &
                     transfer(int(z'3ee3416f9bcd3034', int64), 0.0_real64), transfer(int(z'3ee3917a61d613df', int64), 0.0_real64), &
                     transfer(int(z'3ee3e2443225ee59', int64), 0.0_real64), transfer(int(z'3ee433cd0cbcbfa2', int64), 0.0_real64), &
                     transfer(int(z'3ee4861391c289a2', int64), 0.0_real64), transfer(int(z'3ee4d917c1374c58', int64), 0.0_real64), &
                     transfer(int(z'3ee52cd6db6b0b97', int64), 0.0_real64), transfer(int(z'3ee58157bf95bdd3', int64), 0.0_real64), &
                     transfer(int(z'3ee5d6990ddf64f6', int64), 0.0_real64), transfer(int(z'3ee62c9ac64800fe', int64), 0.0_real64), &
                     transfer(int(z'3ee6835ce8cf91ed', int64), 0.0_real64), transfer(int(z'3ee6dad1b7062ad6', int64), 0.0_real64), &
                     transfer(int(z'3ee73314adcba591', int64), 0.0_real64), transfer(int(z'3ee78c0a50402847', int64), 0.0_real64), &
                     transfer(int(z'3ee7e5c05cd39fe3', int64), 0.0_real64), transfer(int(z'3ee84036d3860c65', int64), 0.0_real64), &
                     transfer(int(z'3ee89b5ff5e780e1', int64), 0.0_real64), transfer(int(z'3ee8f75740d7d72f', int64), 0.0_real64), &
                     transfer(int(z'3ee9540137773578', int64), 0.0_real64), transfer(int(z'3ee9b16b983588a6', int64), 0.0_real64), &
                     transfer(int(z'3eea0f966312d0bb', int64), 0.0_real64), transfer(int(z'3eea6e81980f0db7', int64), 0.0_real64), &
                     transfer(int(z'3eeace1f78ba52ac', int64), 0.0_real64), transfer(int(z'3eeb2e7dc3848c88', int64), 0.0_real64), &
                     transfer(int(z'3eeb8f9c786dbb4a', int64), 0.0_real64), transfer(int(z'3eebf17b9775def2', int64), 0.0_real64), &
                     transfer(int(z'3eec540d622d0a94', int64), 0.0_real64), transfer(int(z'3eecb75f97032b1c', int64), 0.0_real64), &
                     transfer(int(z'3eed1b7235f8408b', int64), 0.0_real64), transfer(int(z'3eed80453f0c4ae0', int64), 0.0_real64), &
                     transfer(int(z'3eede5caf3cf5d2f', int64), 0.0_real64), transfer(int(z'3eee4c1112b16465', int64), 0.0_real64), &
                     transfer(int(z'3eeeb309dd427395', int64), 0.0_real64), transfer(int(z'3eef1ac311f277aa', int64), 0.0_real64), &
                     transfer(int(z'3eef833cb0c170a7', int64), 0.0_real64), transfer(int(z'3eefec68fb3f719d', int64), 0.0_real64), &
                     transfer(int(z'3ef02b2ad7ee33bd', int64), 0.0_real64), transfer(int(z'3ef0607a881432a8', int64), 0.0_real64), &
                     transfer(int(z'3ef0962a6d49ac07', int64), 0.0_real64), transfer(int(z'3ef0cc3a878e9fd9', int64), 0.0_real64), &
                     transfer(int(z'3ef102a3f7ab17a7', int64), 0.0_real64), transfer(int(z'3ef13966bd9f1373', int64), 0.0_real64), &
                     transfer(int(z'3ef17089b8a289b2', int64), 0.0_real64), transfer(int(z'3ef1a806097d83ef', int64), 0.0_real64), &
                     transfer(int(z'3ef1dfe28f67f89e', int64), 0.0_real64), transfer(int(z'3ef218186b29f14a', int64), 0.0_real64), &
                     transfer(int(z'3ef250a79cc36df4', int64), 0.0_real64), transfer(int(z'3ef28997036c6511', int64), 0.0_real64), &
                     transfer(int(z'3ef2c2dfbfece02b', int64), 0.0_real64), transfer(int(z'3ef2fc88b17cd5b8', int64), 0.0_real64), &
                     transfer(int(z'3ef3368af8e44f42', int64), 0.0_real64), transfer(int(z'3ef370e696234cc9', int64), 0.0_real64), &
                     transfer(int(z'3ef3ab9b8939ce4e', int64), 0.0_real64), transfer(int(z'3ef3e6a9d227d3cf', int64), 0.0_real64), &
                     transfer(int(z'3ef42218502553c4', int64), 0.0_real64), transfer(int(z'3ef45de023fa57b6', int64), 0.0_real64), &
                             transfer(int(z'3ef499fa6e6ee92f', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_7(181) = [ &
                     transfer(int(z'3e80d2f576d87b59', int64), 0.0_real64), transfer(int(z'3e81d0bd6844feb3', int64), 0.0_real64), &
                     transfer(int(z'3e82da19a23b08c5', int64), 0.0_real64), transfer(int(z'3e83ef594eed5ede', int64), 0.0_real64), &
                     transfer(int(z'3e8510e5fbf50812', int64), 0.0_real64), transfer(int(z'3e863f0ed384c9b0', int64), 0.0_real64), &
                     transfer(int(z'3e877a349768ea33', int64), 0.0_real64), transfer(int(z'3e88c2b8096db018', int64), 0.0_real64), &
                     transfer(int(z'3e8a1902b72c2273', int64), 0.0_real64), transfer(int(z'3e8b7d5aff0a45fc', int64), 0.0_real64), &
                     transfer(int(z'3e8cf03c063aa2f4', int64), 0.0_real64), transfer(int(z'3e8e71fdc2bcbf40', int64), 0.0_real64), &
                     transfer(int(z'3e900184e114d0fa', int64), 0.0_real64), transfer(int(z'3e90d1dbfd40687b', int64), 0.0_real64), &
                     transfer(int(z'3e91aa3d629409f7', int64), 0.0_real64), transfer(int(z'3e928ad0a6291817', int64), 0.0_real64), &
                     transfer(int(z'3e9373d35a98d6fb', int64), 0.0_real64), transfer(int(z'3e94657a46afca2d', int64), 0.0_real64), &
                     transfer(int(z'3e955fecff875454', int64), 0.0_real64), transfer(int(z'3e96636917b8b990', int64), 0.0_real64), &
                     transfer(int(z'3e97701ef02a1d21', int64), 0.0_real64), transfer(int(z'3e9886434fa8028f', int64), 0.0_real64), &
                     transfer(int(z'3e99a60f62e54db0', int64), 0.0_real64), transfer(int(z'3e9acfaf24e1c177', int64), 0.0_real64), &
                     transfer(int(z'3e9c035bc25041b9', int64), 0.0_real64), transfer(int(z'3e9d414a01fd5200', int64), 0.0_real64), &
                     transfer(int(z'3e9e89b3109bd620', int64), 0.0_real64), transfer(int(z'3e9fdcbe834530c2', int64), 0.0_real64), &
                     transfer(int(z'3ea09d595c2fb34e', int64), 0.0_real64), transfer(int(z'3ea151ddd5751d52', int64), 0.0_real64), &
                     transfer(int(z'3ea20c0b76bf787b', int64), 0.0_real64), transfer(int(z'3ea2cbf60a9b761e', int64), 0.0_real64), &
                     transfer(int(z'3ea391be8d48e871', int64), 0.0_real64), transfer(int(z'3ea45d7afc47b0ee', int64), 0.0_real64), &
                     transfer(int(z'3ea52f4c53d7a1ca', int64), 0.0_real64), transfer(int(z'3ea607465e856c59', int64), 0.0_real64), &
                     transfer(int(z'3ea6e58a1890e2d1', int64), 0.0_real64), transfer(int(z'3ea7ca2d7f79e6ac', int64), 0.0_real64), &
                     transfer(int(z'3ea8b54d2999e9d3', int64), 0.0_real64), transfer(int(z'3ea9a7037a572e0d', int64), 0.0_real64), &
                     transfer(int(z'3eaa9f6d080b2544', int64), 0.0_real64), transfer(int(z'3eab9ea20328e116', int64), 0.0_real64), &
                     transfer(int(z'3eaca4bccf16a349', int64), 0.0_real64), transfer(int(z'3eadb1d7cf3aada2', int64), 0.0_real64), &
                     transfer(int(z'3eaec611cce1a230', int64), 0.0_real64), transfer(int(z'3eafe17e92983248', int64), 0.0_real64), &
                     transfer(int(z'3eb0821d5b5be7ea', int64), 0.0_real64), transfer(int(z'3eb1173281468e72', int64), 0.0_real64), &
                     transfer(int(z'3eb1b00320f26d08', int64), 0.0_real64), transfer(int(z'3eb24ca65158fd38', int64), 0.0_real64), &
                     transfer(int(z'3eb2ed27113a2fbf', int64), 0.0_real64), transfer(int(z'3eb391905f55f559', int64), 0.0_real64), &
                     transfer(int(z'3eb439ed3a6c3ec3', int64), 0.0_real64), transfer(int(z'3eb4e6539ffced76', int64), 0.0_real64), &
                     transfer(int(z'3eb596c390080173', int64), 0.0_real64), transfer(int(z'3eb64b48094d6b77', int64), 0.0_real64), &
                     transfer(int(z'3eb703f7094d0cf9', int64), 0.0_real64), transfer(int(z'3eb7c0db8ec6d6b8', int64), 0.0_real64), &
                     transfer(int(z'3eb88200987ab970', int64), 0.0_real64), transfer(int(z'3eb947712528a5de', int64), 0.0_real64), &
                     transfer(int(z'3eba114332507d7b', int64), 0.0_real64), transfer(int(z'3ebadf6bc1324f8a', int64), 0.0_real64), &
                     transfer(int(z'3ebbb20bce0dee41', int64), 0.0_real64), transfer(int(z'3ebc892e57a34a5d', int64), 0.0_real64), &
                     transfer(int(z'3ebd64c85f327322', int64), 0.0_real64), transfer(int(z'3ebe4505dfbb2b83', int64), 0.0_real64), &
                     transfer(int(z'3ebf29dbda7d82c1', int64), 0.0_real64), transfer(int(z'3ec009b0267cad2c', int64), 0.0_real64), &
                     transfer(int(z'3ec080c99b975923', int64), 0.0_real64), transfer(int(z'3ec0fa454b4eb603', int64), 0.0_real64), &
                     transfer(int(z'3ec1762e3462b488', int64), 0.0_real64), transfer(int(z'3ec1f479581363f6', int64), 0.0_real64), &
                     transfer(int(z'3ec275373480ad68', int64), 0.0_real64), transfer(int(z'3ec2f872c86a819a', int64), 0.0_real64), &
                     transfer(int(z'3ec37e269470e82e', int64), 0.0_real64), transfer(int(z'3ec4065817f3d982', int64), 0.0_real64), &
                     transfer(int(z'3ec4911251b34654', int64), 0.0_real64), transfer(int(z'3ec51e5ac10f2701', int64), 0.0_real64), &
                     transfer(int(z'3ec5ae3166077b89', int64), 0.0_real64), transfer(int(z'3ec640a13f5c34aa', int64), 0.0_real64), &
                     transfer(int(z'3ec6d5aa4d0d5263', int64), 0.0_real64), transfer(int(z'3ec76d520e7acd12', int64), 0.0_real64), &
                     transfer(int(z'3ec8079e03049d16', int64), 0.0_real64), transfer(int(z'3ec8a499296ab32b', int64), 0.0_real64), &
                     transfer(int(z'3ec9443e024d16f4', int64), 0.0_real64), transfer(int(z'3ec9e6978c6bb92d', int64), 0.0_real64), &
                     transfer(int(z'3eca8bab47269233', int64), 0.0_real64), transfer(int(z'3ecb3373b31da9aa', int64), 0.0_real64), &
                     transfer(int(z'3ecbde06cdd0e10a', int64), 0.0_real64), transfer(int(z'3ecc8b5998804797', int64), 0.0_real64), &
                     transfer(int(z'3ecd3b7711ebce0c', int64), 0.0_real64), transfer(int(z'3ecdee64b9736cca', int64), 0.0_real64), &
                     transfer(int(z'3ecea4228f1723cf', int64), 0.0_real64), transfer(int(z'3ecf5cb61236eb7a', int64), 0.0_real64), &
                     transfer(int(z'3ed00c1520c95a44', int64), 0.0_real64), transfer(int(z'3ed06b3a0f35471e', int64), 0.0_real64), &
                     transfer(int(z'3ed0cbd4d31f2d07', int64), 0.0_real64), transfer(int(z'3ed12ddfed2713a2', int64), 0.0_real64), &
                     transfer(int(z'3ed19160dcacf34c', int64), 0.0_real64), transfer(int(z'3ed1f657a1b0cc07', int64), 0.0_real64), &
                     transfer(int(z'3ed25ccc7b42925e', int64), 0.0_real64), transfer(int(z'3ed2c4b9ea024df4', int64), 0.0_real64), &
                     transfer(int(z'3ed32e256d4ff728', int64), 0.0_real64), transfer(int(z'3ed3990c457b91c9', int64), 0.0_real64), &
                     transfer(int(z'3ed40576b1951266', int64), 0.0_real64), transfer(int(z'3ed47361f1ec7cd0', int64), 0.0_real64), &
                     transfer(int(z'3ed4e2d0c631cd35', int64), 0.0_real64), transfer(int(z'3ed553c5ee14ffc4', int64), 0.0_real64), &
                     transfer(int(z'3ed5c6416996147f', int64), 0.0_real64), transfer(int(z'3ed63a45f8650793', int64), 0.0_real64), &
                     transfer(int(z'3ed6afd39a81d901', int64), 0.0_real64), transfer(int(z'3ed726efcf4c8127', int64), 0.0_real64), &
                     transfer(int(z'3ed79f97d71503d7', int64), 0.0_real64), transfer(int(z'3ed819ce718b5d3f', int64), 0.0_real64), &
                     transfer(int(z'3ed895965e5f898e', int64), 0.0_real64), transfer(int(z'3ed912ef9d9188c5', int64), 0.0_real64), &
                     transfer(int(z'3ed991dceed15712', int64), 0.0_real64), transfer(int(z'3eda1258d2befc17', int64), 0.0_real64), &
                     transfer(int(z'3eda947107ca64c1', int64), 0.0_real64), transfer(int(z'3edb181d4ee39c81', int64), 0.0_real64), &
                     transfer(int(z'3edb9d63276a9bb6', int64), 0.0_real64), transfer(int(z'3edc2445510f5e8f', int64), 0.0_real64), &
                     transfer(int(z'3edcacc10c21e8dd', int64), 0.0_real64), transfer(int(z'3edd36d658a23aa0', int64), 0.0_real64), &
                     transfer(int(z'3eddc287f6405008', int64), 0.0_real64), transfer(int(z'3ede4fd8a4ac2542', int64), 0.0_real64), &
                     transfer(int(z'3ededecb2395b67f', int64), 0.0_real64), transfer(int(z'3edf6f59f39d0b60', int64), 0.0_real64), &
                     transfer(int(z'3ee000c6a9e90c39', int64), 0.0_real64), transfer(int(z'3ee04aafe26a72ac', int64), 0.0_real64), &
                     transfer(int(z'3ee0956e22b2b167', int64), 0.0_real64), transfer(int(z'3ee0e0fbeb61d00c', int64), 0.0_real64), &
                     transfer(int(z'3ee12d5bfc27caca', int64), 0.0_real64), transfer(int(z'3ee17a8fb4dc9fb7', int64), 0.0_real64), &
                     transfer(int(z'3ee1c895b5a850be', int64), 0.0_real64), transfer(int(z'3ee217721e12d824', int64), 0.0_real64), &
                     transfer(int(z'3ee267222e6c39bb', int64), 0.0_real64), transfer(int(z'3ee2b7a5e6b47582', int64), 0.0_real64), &
                     transfer(int(z'3ee308fea6c38991', int64), 0.0_real64), transfer(int(z'3ee35b2f2e497217', int64), 0.0_real64), &
                     transfer(int(z'3ee3ae31fde636b7', int64), 0.0_real64), transfer(int(z'3ee4020df4d1cde4', int64), 0.0_real64), &
                     transfer(int(z'3ee456bef3843d5a', int64), 0.0_real64), transfer(int(z'3ee4ac44f9fd8518', int64), 0.0_real64), &
                     transfer(int(z'3ee502a427c59f65', int64), 0.0_real64), transfer(int(z'3ee559e1fc3c849e', int64), 0.0_real64), &
                     transfer(int(z'3ee5b1edf9424baa', int64), 0.0_real64), transfer(int(z'3ee60ad5dd46e174', int64), 0.0_real64), &
                     transfer(int(z'3ee6648be9da590f', int64), 0.0_real64), transfer(int(z'3ee6bf2b9bdc8c55', int64), 0.0_real64), &
                     transfer(int(z'3ee71a99766da16c', int64), 0.0_real64), transfer(int(z'3ee776e337fd8542', int64), 0.0_real64), &
                     transfer(int(z'3ee7d3fb221c4ae9', int64), 0.0_real64), transfer(int(z'3ee831fcb1a9cc3b', int64), 0.0_real64), &
                     transfer(int(z'3ee890cc69c62f5e', int64), 0.0_real64), transfer(int(z'3ee8f07808e16140', int64), 0.0_real64), &
                     transfer(int(z'3ee950ff8efb61df', int64), 0.0_real64), transfer(int(z'3ee9b262fc14313c', int64), 0.0_real64), &
                     transfer(int(z'3eea14a2502bcf57', int64), 0.0_real64), transfer(int(z'3eea77afccd24f44', int64), 0.0_real64), &
                     transfer(int(z'3eeadba6eee78adb', int64), 0.0_real64), transfer(int(z'3eeb406c398ba844', int64), 0.0_real64), &
                     transfer(int(z'3eeba60d6b2e946b', int64), 0.0_real64), transfer(int(z'3eec0c9842403c3c', int64), 0.0_real64), &
                     transfer(int(z'3eec73f141e0c5df', int64), 0.0_real64), transfer(int(z'3eecdc2628801e40', int64), 0.0_real64), &
                     transfer(int(z'3eed4536f61e455f', int64), 0.0_real64), transfer(int(z'3eedaf15ec4b4e4f', int64), 0.0_real64), &
                     transfer(int(z'3eee19de87e712ea', int64), 0.0_real64), transfer(int(z'3eee85830a81a642', int64), 0.0_real64), &
                     transfer(int(z'3eeef1f5b5ab1b6d', int64), 0.0_real64), transfer(int(z'3eef5f5206434c41', int64), 0.0_real64), &
                     transfer(int(z'3eefcd7c7f6a5ee8', int64), 0.0_real64), transfer(int(z'3ef01e484f00169c', int64), 0.0_real64), &
                     transfer(int(z'3ef0563972926ead', int64), 0.0_real64), transfer(int(z'3ef08e9889a42e1d', int64), 0.0_real64), &
                     transfer(int(z'3ef0c76c736d4b62', int64), 0.0_real64), transfer(int(z'3ef100a7717dd990', int64), 0.0_real64), &
                     transfer(int(z'3ef13a4983d5d8a7', int64), 0.0_real64), transfer(int(z'3ef1746068e53593', int64), 0.0_real64), &
                             transfer(int(z'3ef1aee54173f9de', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_8(181) = [ &
                     transfer(int(z'3e721ac0311174dd', int64), 0.0_real64), transfer(int(z'3e734744949940b1', int64), 0.0_real64), &
                     transfer(int(z'3e7483382c9afbcd', int64), 0.0_real64), transfer(int(z'3e75cf27b5e2afa1', int64), 0.0_real64), &
                     transfer(int(z'3e772ba8b9092633', int64), 0.0_real64), transfer(int(z'3e78994d39eedc80', int64), 0.0_real64), &
                     transfer(int(z'3e7a18b00841101c', int64), 0.0_real64), transfer(int(z'3e7baa6f78654ba4', int64), 0.0_real64), &
                     transfer(int(z'3e7d4f113db6fe75', int64), 0.0_real64), transfer(int(z'3e7f075a60870293', int64), 0.0_real64), &
                     transfer(int(z'3e8069ebced0b0b5', int64), 0.0_real64), transfer(int(z'3e815a93a4b5d2cd', int64), 0.0_real64), &
                     transfer(int(z'3e8255fca7f26d77', int64), 0.0_real64), transfer(int(z'3e835c7ece860697', int64), 0.0_real64), &
                     transfer(int(z'3e846e720e702415', int64), 0.0_real64), transfer(int(z'3e858c1cc616caa7', int64), 0.0_real64), &
                     transfer(int(z'3e86b5e883130160', int64), 0.0_real64), transfer(int(z'3e87ec246f978d91', int64), 0.0_real64), &
                     transfer(int(z'3e892f2881a3f51d', int64), 0.0_real64), transfer(int(z'3e8a7f557b047e82', int64), 0.0_real64), &
                     transfer(int(z'3e8bdd0c1d85703c', int64), 0.0_real64), transfer(int(z'3e8d48a45f265030', int64), 0.0_real64), &
                     transfer(int(z'3e8ec27635e6a445', int64), 0.0_real64), transfer(int(z'3e90257131c9597c', int64), 0.0_real64), &
                     transfer(int(z'3e90f1293ae1c1ad', int64), 0.0_real64), transfer(int(z'3e91c48f313c4da9', int64), 0.0_real64), &
                     transfer(int(z'3e929fcf0fd8c062', int64), 0.0_real64), transfer(int(z'3e9383220369fdaf', int64), 0.0_real64), &
                     transfer(int(z'3e946eb86cd628cd', int64), 0.0_real64), transfer(int(z'3e9562c2ad0364fa', int64), 0.0_real64), &
                     transfer(int(z'3e965f7124d7d575', int64), 0.0_real64), transfer(int(z'3e9764f435399d7c', int64), 0.0_real64), &
                     transfer(int(z'3e9873850adba0e4', int64), 0.0_real64), transfer(int(z'3e998b4fa0bda2a0', int64), 0.0_real64), &
                     transfer(int(z'3e9aac8d23928685', int64), 0.0_real64), transfer(int(z'3e9bd76df4406fd2', int64), 0.0_real64), &
                     transfer(int(z'3e9d0c26d993e210', int64), 0.0_real64), transfer(int(z'3e9e4ae83473007e', int64), 0.0_real64), &
                     transfer(int(z'3e9f93ef97770f3c', int64), 0.0_real64), transfer(int(z'3ea073b24bdcb879', int64), 0.0_real64), &
                     transfer(int(z'3ea122c496dce505', int64), 0.0_real64), transfer(int(z'3ea1d7427748be97', int64), 0.0_real64), &
                     transfer(int(z'3ea2914ce9601765', int64), 0.0_real64), transfer(int(z'3ea350f7b7afa0c1', int64), 0.0_real64), &
                     transfer(int(z'3ea41661ab83fcbe', int64), 0.0_real64), transfer(int(z'3ea4e1a528436d1f', int64), 0.0_real64), &
                     transfer(int(z'3ea5b2dec44763ce', int64), 0.0_real64), transfer(int(z'3ea68a20172961fb', int64), 0.0_real64), &
                     transfer(int(z'3ea76792e8f5fa72', int64), 0.0_real64), transfer(int(z'3ea84b446b604e16', int64), 0.0_real64), &
                     transfer(int(z'3ea9355367b4fef6', int64), 0.0_real64), transfer(int(z'3eaa25dea740af23', int64), 0.0_real64), &
                     transfer(int(z'3eab1cfe5a76703d', int64), 0.0_real64), transfer(int(z'3eac1acab1c953e2', int64), 0.0_real64), &
                     transfer(int(z'3ead1f64a9792c48', int64), 0.0_real64), transfer(int(z'3eae2ae00c12aac4', int64), 0.0_real64), &
                     transfer(int(z'3eaf3d5dd5d5a18b', int64), 0.0_real64), transfer(int(z'3eb02b7a0220f90b', int64), 0.0_real64), &
                     transfer(int(z'3eb0bbdf96d88729', int64), 0.0_real64), transfer(int(z'3eb14fef0db7cc26', int64), 0.0_real64), &
                     transfer(int(z'3eb1e7accca5284f', int64), 0.0_real64), transfer(int(z'3eb283321d8d4555', int64), 0.0_real64), &
                     transfer(int(z'3eb32289ff3013f4', int64), 0.0_real64), transfer(int(z'3eb3c5bf704d84eb', int64), 0.0_real64), &
                     transfer(int(z'3eb46cd270e59838', int64), 0.0_real64), transfer(int(z'3eb517e3fd382012', int64), 0.0_real64), &
                     transfer(int(z'3eb5c6ff14050d36', int64), 0.0_real64), transfer(int(z'3eb67a23b54c5fa2', int64), 0.0_real64), &
                     transfer(int(z'3eb73167de8df8d2', int64), 0.0_real64), transfer(int(z'3eb7ece18d49ba3e', int64), 0.0_real64), &
                     transfer(int(z'3eb8ac85c2bfb32a', int64), 0.0_real64), transfer(int(z'3eb970757b2fb5cb', int64), 0.0_real64), &
                     transfer(int(z'3eba38bbb559b2df', int64), 0.0_real64), transfer(int(z'3ebb054d727db9a8', int64), 0.0_real64), &
                     transfer(int(z'3ebbd661ac5b7dd6', int64), 0.0_real64), transfer(int(z'3ebcabd766b32d33', int64), 0.0_real64), &
                     transfer(int(z'3ebd85e59b447b6f', int64), 0.0_real64), transfer(int(z'3ebe64764c8f8710', int64), 0.0_real64), &
                     transfer(int(z'3ebf47aa76d4224d', int64), 0.0_real64), transfer(int(z'3ec017c10d092692', int64), 0.0_real64), &
                     transfer(int(z'3ec08e0f1944ece6', int64), 0.0_real64), transfer(int(z'3ec106b4615d7367', int64), 0.0_real64), &
                     transfer(int(z'3ec181c6e2d29b8c', int64), 0.0_real64), transfer(int(z'3ec1ff469da46557', int64), 0.0_real64), &
                     transfer(int(z'3ec27f3391d2d0c8', int64), 0.0_real64), transfer(int(z'3ec3019e3d7dc6f9', int64), 0.0_real64), &
                     transfer(int(z'3ec38686a0a547ea', int64), 0.0_real64), transfer(int(z'3ec40df23aa94bfa', int64), 0.0_real64), &
                     transfer(int(z'3ec497e68ae9cb87', int64), 0.0_real64), transfer(int(z'3ec5246e9026b74e', int64), 0.0_real64), &
                     transfer(int(z'3ec5b38a4a600f4e', int64), 0.0_real64), transfer(int(z'3ec6453f38f5cbe7', int64), 0.0_real64), &
                     transfer(int(z'3ec6d9985aa7ddd4', int64), 0.0_real64), transfer(int(z'3ec77095af764517', int64), 0.0_real64), &
                     transfer(int(z'3ec80a423620f26b', int64), 0.0_real64), transfer(int(z'3ec8a69deea7e5d0', int64), 0.0_real64), &
                     transfer(int(z'3ec945b3d7cb1004', int64), 0.0_real64), transfer(int(z'3ec9e77e722a78a7', int64), 0.0_real64), &
                     transfer(int(z'3eca8c13bb460134', int64), 0.0_real64), transfer(int(z'3ecb3368b45db8ed', int64), 0.0_real64), &
                     transfer(int(z'3ecbdd885c319090', int64), 0.0_real64), transfer(int(z'3ecc8a7db18178d9', int64), 0.0_real64), &
                     transfer(int(z'3ecd3a4334ed7969', int64), 0.0_real64), transfer(int(z'3ecdece964957b5c', int64), 0.0_real64), &
                     transfer(int(z'3ecea27040797eb1', int64), 0.0_real64), transfer(int(z'3ecf5ad7c899836a', int64), 0.0_real64), &
                     transfer(int(z'3ed00b157ddabd21', int64), 0.0_real64), transfer(int(z'3ed06a37ac96adcb', int64), 0.0_real64), &
                     transfer(int(z'3ed0cad2708093b5', int64), 0.0_real64), transfer(int(z'3ed12ce889486b0c', int64), 0.0_real64), &
                     transfer(int(z'3ed1907cb69e3001', int64), 0.0_real64), transfer(int(z'3ed1f591b831dec2', int64), 0.0_real64), &
                     transfer(int(z'3ed25c2a4db3737f', int64), 0.0_real64), transfer(int(z'3ed2c44936d2ea66', int64), 0.0_real64), &
                     transfer(int(z'3ed32dee73904378', int64), 0.0_real64), transfer(int(z'3ed3991a03eb7eb5', int64), 0.0_real64), &
                     transfer(int(z'3ed405d426f490aa', int64), 0.0_real64), transfer(int(z'3ed4741cdcab7957', int64), 0.0_real64), &
                     transfer(int(z'3ed4e3f4251038bd', int64), 0.0_real64), transfer(int(z'3ed5555f7f82c739', int64), 0.0_real64), &
                     transfer(int(z'3ed5c85c2c53289d', int64), 0.0_real64), transfer(int(z'3ed63cefaae15546', int64), 0.0_real64), &
                     transfer(int(z'3ed6b319fb2d4d35', int64), 0.0_real64), transfer(int(z'3ed72ae09c9708c8', int64), 0.0_real64), &
                     transfer(int(z'3ed7a440cf6e8bd1', int64), 0.0_real64), transfer(int(z'3ed81f42d2c3cadb', int64), 0.0_real64), &
                     transfer(int(z'3ed89be12736cd8a', int64), 0.0_real64), transfer(int(z'3ed91a1e8c77900c', int64), 0.0_real64), &
                     transfer(int(z'3ed99a03419606ef', int64), 0.0_real64), transfer(int(z'3eda1b89c73239d4', int64), 0.0_real64), &
                     transfer(int(z'3eda9eb4dcfc24eb', int64), 0.0_real64), transfer(int(z'3edb238f81b3b8f0', int64), 0.0_real64), &
                     transfer(int(z'3edbaa1176490157', int64), 0.0_real64), transfer(int(z'3edc32403a1bf67c', int64), 0.0_real64), &
                     transfer(int(z'3edcbc190d7c9c31', int64), 0.0_real64), transfer(int(z'3edd47a16fcaead5', int64), 0.0_real64), &
                     transfer(int(z'3eddd4dc20b6de96', int64), 0.0_real64), transfer(int(z'3ede63c920407774', int64), 0.0_real64), &
                     transfer(int(z'3edef46b2e17b1a0', int64), 0.0_real64), transfer(int(z'3edf86bccadc94b9', int64), 0.0_real64), &
                     transfer(int(z'3ee00d647aa788bf', int64), 0.0_real64), transfer(int(z'3ee0584676df95df', int64), 0.0_real64), &
                     transfer(int(z'3ee0a4045a1671bd', int64), 0.0_real64), transfer(int(z'3ee0f0a0e3fc1889', int64), 0.0_real64), &
                     transfer(int(z'3ee13e1c14908a41', int64), 0.0_real64), transfer(int(z'3ee18c732c23cab8', int64), 0.0_real64), &
                     transfer(int(z'3ee1dbabaa15d24a', int64), 0.0_real64), transfer(int(z'3ee22bc42e8ea2e1', int64), 0.0_real64), &
                     transfer(int(z'3ee27cbe19663a95', int64), 0.0_real64), transfer(int(z'3ee2ce954b149f1e', int64), 0.0_real64), &
                     transfer(int(z'3ee3215202a9c50a', int64), 0.0_real64), transfer(int(z'3ee374f0209db213', int64), 0.0_real64), &
                     transfer(int(z'3ee3c97264a06266', int64), 0.0_real64), transfer(int(z'3ee41ed76ed9d7ee', int64), 0.0_real64), &
                     transfer(int(z'3ee4751f3f4a12aa', int64), 0.0_real64), transfer(int(z'3ee4cc4c95a10ec8', int64), 0.0_real64), &
                     transfer(int(z'3ee5245b5256d203', int64), 0.0_real64), transfer(int(z'3ee57d5eb33b41a5', int64), 0.0_real64), &
                     transfer(int(z'3ee5d7303cae9318', int64), 0.0_real64), transfer(int(z'3ee631f92a008d21', int64), 0.0_real64), &
                     transfer(int(z'3ee68dabbcc142d4', int64), 0.0_real64), transfer(int(z'3ee6ea3a3680c745', int64), 0.0_real64), &
                     transfer(int(z'3ee747b255af0760', int64), 0.0_real64), transfer(int(z'3ee7a6141a4c0324', int64), 0.0_real64), &
                     transfer(int(z'3ee8055f8457ba92', int64), 0.0_real64), transfer(int(z'3ee8659493d22daa', int64), 0.0_real64), &
                     transfer(int(z'3ee8c6b348bb5c6c', int64), 0.0_real64), transfer(int(z'3ee928c9618333c4', int64), 0.0_real64), &
                     transfer(int(z'3ee98bbb6149d9d9', int64), 0.0_real64), transfer(int(z'3ee9ef97067f3b99', int64), 0.0_real64), &
                     transfer(int(z'3eea545c51235902', int64), 0.0_real64), transfer(int(z'3eeaba0b41363214', int64), 0.0_real64), &
                     transfer(int(z'3eeb20b19527b3bd', int64), 0.0_real64), transfer(int(z'3eeb88418e87f10f', int64), 0.0_real64), &
                     transfer(int(z'3eebf0ad6ee6fd20', int64), 0.0_real64), transfer(int(z'3eec5a1e71949eb1', int64), 0.0_real64), &
                     transfer(int(z'3eecc46b5b410f01', int64), 0.0_real64), transfer(int(z'3eed2fa1ea5c3afb', int64), 0.0_real64), &
                     transfer(int(z'3eed9bcfdd560f8a', int64), 0.0_real64), transfer(int(z'3eee08e775be9fc3', int64), 0.0_real64), &
                             transfer(int(z'3eee76f67205d891', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_9(181) = [ &
                     transfer(int(z'3e5c14a978b31de2', int64), 0.0_real64), transfer(int(z'3e5e216e70e4e57e', int64), 0.0_real64), &
                     transfer(int(z'3e6026af9cf0953b', int64), 0.0_real64), transfer(int(z'3e614cf863fbe94a', int64), 0.0_real64), &
                     transfer(int(z'3e62844179937ab9', int64), 0.0_real64), transfer(int(z'3e63cd4fe6082389', int64), 0.0_real64), &
                     transfer(int(z'3e6528de2381d6a1', int64), 0.0_real64), transfer(int(z'3e6697b4bf09bb0d', int64), 0.0_real64), &
                     transfer(int(z'3e681aa34f1991ea', int64), 0.0_real64), transfer(int(z'3e69b275e572cf4d', int64), 0.0_real64), &
                     transfer(int(z'3e6b6006a6b81b70', int64), 0.0_real64), transfer(int(z'3e6d242c32d3d182', int64), 0.0_real64), &
                     transfer(int(z'3e6effcb3c9180d8', int64), 0.0_real64), transfer(int(z'3e7079e43b5e5c64', int64), 0.0_real64), &
                     transfer(int(z'3e7180844a108452', int64), 0.0_real64), transfer(int(z'3e729440ef91c07a', int64), 0.0_real64), &
                     transfer(int(z'3e73b591cc5c4c12', int64), 0.0_real64), transfer(int(z'3e74e4f3c7fed5e0', int64), 0.0_real64), &
                     transfer(int(z'3e7622e74ec059b5', int64), 0.0_real64), transfer(int(z'3e776feb0a8bacd9', int64), 0.0_real64), &
                     transfer(int(z'3e78cc8671186530', int64), 0.0_real64), transfer(int(z'3e7a393d7365cb91', int64), 0.0_real64), &
                     transfer(int(z'3e7bb69949879c63', int64), 0.0_real64), transfer(int(z'3e7d451a5fc4d374', int64), 0.0_real64), &
                     transfer(int(z'3e7ee567d64fbbf9', int64), 0.0_real64), transfer(int(z'3e804bfe692d6f1a', int64), 0.0_real64), &
                     transfer(int(z'3e812ebbd425e260', int64), 0.0_real64), transfer(int(z'3e821b328a773c87', int64), 0.0_real64), &
                     transfer(int(z'3e8311a8ea878247', int64), 0.0_real64), transfer(int(z'3e84126e1e8978ee', int64), 0.0_real64), &
                     transfer(int(z'3e851dda1c7ca661', int64), 0.0_real64), transfer(int(z'3e86343342c70f59', int64), 0.0_real64), &
                     transfer(int(z'3e8755c8bb9b7924', int64), 0.0_real64), transfer(int(z'3e8882e9b12ca911', int64), 0.0_real64), &
                     transfer(int(z'3e89bbee197a2504', int64), 0.0_real64), transfer(int(z'3e8b011c52e9f1b7', int64), 0.0_real64), &
                     transfer(int(z'3e8c52ddeb15163c', int64), 0.0_real64), transfer(int(z'3e8db1707494d6b4', int64), 0.0_real64), &
                     transfer(int(z'3e8f1d34b135799b', int64), 0.0_real64), transfer(int(z'3e904b414b7b426c', int64), 0.0_real64), &
                     transfer(int(z'3e910ed90debbf28', int64), 0.0_real64), transfer(int(z'3e91d98d9aebf5f3', int64), 0.0_real64), &
                     transfer(int(z'3e92ab8687954977', int64), 0.0_real64), transfer(int(z'3e9384f89ab43d3b', int64), 0.0_real64), &
                     transfer(int(z'3e94660b696233e8', int64), 0.0_real64), transfer(int(z'3e954eef548550bc', int64), 0.0_real64), &
                     transfer(int(z'3e963fd4bd03b6f4', int64), 0.0_real64), transfer(int(z'3e9738e79ddd2985', int64), 0.0_real64), &
                     transfer(int(z'3e983a5857f7cbab', int64), 0.0_real64), transfer(int(z'3e9944574c39c0a6', int64), 0.0_real64), &
                     transfer(int(z'3e9a571075a2cb68', int64), 0.0_real64), transfer(int(z'3e9b72b435190f2f', int64), 0.0_real64), &
                     transfer(int(z'3e9c977bb74f6fd1', int64), 0.0_real64), transfer(int(z'3e9dc58e915f4ff5', int64), 0.0_real64), &
                     transfer(int(z'3e9efd218a153325', int64), 0.0_real64), transfer(int(z'3ea01f32812b9e4f', int64), 0.0_real64), &
                     transfer(int(z'3ea0c4c4ad85c7d0', int64), 0.0_real64), transfer(int(z'3ea16f61ad7f57da', int64), 0.0_real64), &
                     transfer(int(z'3ea21f23e47e9031', int64), 0.0_real64), transfer(int(z'3ea2d41f1d10222a', int64), 0.0_real64), &
                     transfer(int(z'3ea38e745373dffb', int64), 0.0_real64), transfer(int(z'3ea44e3752367af7', int64), 0.0_real64), &
                     transfer(int(z'3ea513827cbe34e3', int64), 0.0_real64), transfer(int(z'3ea5de7269647faa', int64), 0.0_real64), &
                     transfer(int(z'3ea6af1f489c6cea', int64), 0.0_real64), transfer(int(z'3ea785a14ad90e44', int64), 0.0_real64), &
                     transfer(int(z'3ea862150673d5a1', int64), 0.0_real64), transfer(int(z'3ea94492abdfd4a1', int64), 0.0_real64), &
                     transfer(int(z'3eaa2d36d1767d2e', int64), 0.0_real64), transfer(int(z'3eab1c1774b7b0c2', int64), 0.0_real64), &
                     transfer(int(z'3eac11535ef0116d', int64), 0.0_real64), transfer(int(z'3ead0d008d9f80a9', int64), 0.0_real64), &
                     transfer(int(z'3eae0f3ffd05d0ab', int64), 0.0_real64), transfer(int(z'3eaf182577afb2c7', int64), 0.0_real64), &
                     transfer(int(z'3eb013e6c9fb4c74', int64), 0.0_real64), transfer(int(z'3eb09f295aa06269', int64), 0.0_real64), &
                     transfer(int(z'3eb12deaebe7045f', int64), 0.0_real64), transfer(int(z'3eb1c034499bf2eb', int64), 0.0_real64), &
                     transfer(int(z'3eb2560e3f8beea5', int64), 0.0_real64), transfer(int(z'3eb2ef8ecb36d906', int64), 0.0_real64), &
                     transfer(int(z'3eb38cc0eb5ca2cb', int64), 0.0_real64), transfer(int(z'3eb42dba9d7d2d6d', int64), 0.0_real64), &
                     transfer(int(z'3eb4d270e2d88830', int64), 0.0_real64), transfer(int(z'3eb57b04b7ae854a', int64), 0.0_real64), &
                     transfer(int(z'3eb627811abf1577', int64), 0.0_real64), transfer(int(z'3eb6d7f10aca2974', int64), 0.0_real64), &
                     transfer(int(z'3eb78c5f868fb1fd', int64), 0.0_real64), transfer(int(z'3eb844e28b8f908d', int64), 0.0_real64), &
                     transfer(int(z'3eb9017a19c9c523', int64), 0.0_real64), transfer(int(z'3eb9c23c2ebe3139', int64), 0.0_real64), &
                     transfer(int(z'3eba8733c92cc58b', int64), 0.0_real64), transfer(int(z'3ebb506be7d572d6', int64), 0.0_real64), &
                     transfer(int(z'3ebc1dfa88381a93', int64), 0.0_real64), transfer(int(z'3ebcefdfaa54bcc3', int64), 0.0_real64), &
                     transfer(int(z'3ebdc6314bab3ade', int64), 0.0_real64), transfer(int(z'3ebea0ef6c3b94e5', int64), 0.0_real64), &
                     transfer(int(z'3ebf803b08459d0e', int64), 0.0_real64), transfer(int(z'3ec0320f8f44a20b', int64), 0.0_real64), &
                     transfer(int(z'3ec0a64dd78344fe', int64), 0.0_real64), transfer(int(z'3ec11cdddc3eafbe', int64), 0.0_real64), &
                     transfer(int(z'3ec195ca9c36d309', int64), 0.0_real64), transfer(int(z'3ec2111996cba73c', int64), 0.0_real64), &
                     transfer(int(z'3ec28ed5cabd1d15', int64), 0.0_real64), transfer(int(z'3ec30eff380b3494', int64), 0.0_real64), &
                     transfer(int(z'3ec3919b5e15e615', int64), 0.0_real64), transfer(int(z'3ec416afbc3d29f9', int64), 0.0_real64), &
                     transfer(int(z'3ec49e4cd0a0e95a', int64), 0.0_real64), transfer(int(z'3ec5286d1be12bda', int64), 0.0_real64), &
                     transfer(int(z'3ec5b51b9cbde236', int64), 0.0_real64), transfer(int(z'3ec6446351f6fd29', int64), 0.0_real64), &
                     transfer(int(z'3ec6d6443b8c7cb4', int64), 0.0_real64), transfer(int(z'3ec76abe597e60d8', int64), 0.0_real64), &
                     transfer(int(z'3ec801e7a94c8b0d', int64), 0.0_real64), transfer(int(z'3ec89bbaab9702f6', int64), 0.0_real64), &
                     transfer(int(z'3ec938425f1db94e', int64), 0.0_real64), transfer(int(z'3ec9d77ec3e0ae16', int64), 0.0_real64), &
                     transfer(int(z'3eca797ad89fd20a', int64), 0.0_real64), transfer(int(z'3ecb1e3c1cbb1d8a', int64), 0.0_real64), &
                     transfer(int(z'3ecbc5c80f9288f3', int64), 0.0_real64), transfer(int(z'3ecc7029afe60502', int64), 0.0_real64), &
                     transfer(int(z'3ecd1d5b7e559958', int64), 0.0_real64), transfer(int(z'3ecdcd6879a136b3', int64), 0.0_real64), &
                     transfer(int(z'3ece805ba088cdcf', int64), 0.0_real64), transfer(int(z'3ecf362f73ac664d', int64), 0.0_real64), &
                     transfer(int(z'3ecfeef4712be949', int64), 0.0_real64), transfer(int(z'3ed055554c83ab62', int64), 0.0_real64), &
                     transfer(int(z'3ed0b4ae74ff4fbc', int64), 0.0_real64), transfer(int(z'3ed11582f258e584', int64), 0.0_real64), &
                     transfer(int(z'3ed177db03a06148', int64), 0.0_real64), transfer(int(z'3ed1dbb6a8d5c307', int64), 0.0_real64), &
                     transfer(int(z'3ed2411b61590320', int64), 0.0_real64), transfer(int(z'3ed2a8066d7a2564', int64), 0.0_real64), &
                     transfer(int(z'3ed310800c491e60', int64), 0.0_real64), transfer(int(z'3ed37a857e15f1e5', int64), 0.0_real64), &
                     transfer(int(z'3ed3e621c1a090b0', int64), 0.0_real64), transfer(int(z'3ed4534c97d90633', int64), 0.0_real64), &
                     transfer(int(z'3ed4c210ff7f432b', int64), 0.0_real64), transfer(int(z'3ed5326ef8934799', int64), 0.0_real64), &
                     transfer(int(z'3ed5a4668315137b', int64), 0.0_real64), transfer(int(z'3ed617fd1e649f30', int64), 0.0_real64), &
                     transfer(int(z'3ed68d32ca81eab9', int64), 0.0_real64), transfer(int(z'3ed7040fc67ceaa2', int64), 0.0_real64), &
                     transfer(int(z'3ed77c8e92f5a68e', int64), 0.0_real64), transfer(int(z'3ed7f6b76efc130a', int64), 0.0_real64), &
                     transfer(int(z'3ed872879ae033e6', int64), 0.0_real64), transfer(int(z'3ed8f00755b1fdb1', int64), 0.0_real64), &
                     transfer(int(z'3ed96f33dfc1743c', int64), 0.0_real64), transfer(int(z'3ed9f00ff8be93b4', int64), 0.0_real64), &
                     transfer(int(z'3eda72a3dfb950a9', int64), 0.0_real64), transfer(int(z'3edaf6ecd501aeea', int64), 0.0_real64), &
                     transfer(int(z'3edb7cead897ae77', int64), 0.0_real64), transfer(int(z'3edc04a369db47b0', int64), 0.0_real64), &
                     transfer(int(z'3edc8e19487c76c3', int64), 0.0_real64), transfer(int(z'3edd194f342b37e0', int64), 0.0_real64), &
                     transfer(int(z'3edda6426d378ed6', int64), 0.0_real64), transfer(int(z'3ede34fb32b17034', int64), 0.0_real64), &
                     transfer(int(z'3edec576c4e8dfcb', int64), 0.0_real64), transfer(int(z'3edf57b7e38dd9ca', int64), 0.0_real64), &
                     transfer(int(z'3edfebc6cdb052be', int64), 0.0_real64), transfer(int(z'3ee040cda2202b0d', int64), 0.0_real64), &
                     transfer(int(z'3ee08ca022feea4d', int64), 0.0_real64), transfer(int(z'3ee0d95829c46af0', int64), 0.0_real64), &
                     transfer(int(z'3ee126fb35d0a554', int64), 0.0_real64), transfer(int(z'3ee1758687739d4b', int64), 0.0_real64), &
                     transfer(int(z'3ee1c4fb7e8550eb', int64), 0.0_real64), transfer(int(z'3ee2155a1b05c035', int64), 0.0_real64), &
                     transfer(int(z'3ee266a67c7ce570', int64), 0.0_real64), transfer(int(z'3ee2b8e0a2eac09c', int64), 0.0_real64), &
                     transfer(int(z'3ee30c072e7753a0', int64), 0.0_real64), transfer(int(z'3ee3601cded29aac', int64), 0.0_real64), &
                     transfer(int(z'3ee3b521b3fc95c1', int64), 0.0_real64), transfer(int(z'3ee40b186da5410d', int64), 0.0_real64), &
                     transfer(int(z'3ee461fe4c1ca061', int64), 0.0_real64), transfer(int(z'3ee4b9d8cec2ac1c', int64), 0.0_real64), &
                     transfer(int(z'3ee512a3d60f69f6', int64), 0.0_real64), transfer(int(z'3ee56c67a112ce7e', int64), 0.0_real64), &
                     transfer(int(z'3ee5c7151184eeaf', int64), 0.0_real64), transfer(int(z'3ee622c7a445a462', int64), 0.0_real64), &
                     transfer(int(z'3ee67f63dc7515bf', int64), 0.0_real64), transfer(int(z'3ee6dcf778832fb1', int64), 0.0_real64), &
                             transfer(int(z'3ee73b82786ff239', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_10(181) = [ &
                     transfer(int(z'3e4318fa7be3bfe1', int64), 0.0_real64), transfer(int(z'3e44af9827075e51', int64), 0.0_real64), &
                     transfer(int(z'3e46626135ba27e0', int64), 0.0_real64), transfer(int(z'3e4832ec63354c4c', int64), 0.0_real64), &
                     transfer(int(z'3e4a22b1745c2239', int64), 0.0_real64), transfer(int(z'3e4c3372c5552e3c', int64), 0.0_real64), &
                     transfer(int(z'3e4e66e49f65c0c9', int64), 0.0_real64), transfer(int(z'3e505f64af5a2f3b', int64), 0.0_real64), &
                     transfer(int(z'3e519e78b9246001', int64), 0.0_real64), transfer(int(z'3e52f19dae05e925', int64), 0.0_real64), &
                     transfer(int(z'3e5459d7eb450f50', int64), 0.0_real64), transfer(int(z'3e55d824c4b77d16', int64), 0.0_real64), &
                     transfer(int(z'3e576d8fa1141132', int64), 0.0_real64), transfer(int(z'3e591b31f9f2de83', int64), 0.0_real64), &
                     transfer(int(z'3e5ae21e3f7b5dd4', int64), 0.0_real64), transfer(int(z'3e5cc38a11080a4d', int64), 0.0_real64), &
                     transfer(int(z'3e5ec08ee830f6ce', int64), 0.0_real64), transfer(int(z'3e606d34b6e09c48', int64), 0.0_real64), &
                     transfer(int(z'3e6189322eb28c79', int64), 0.0_real64), transfer(int(z'3e62b4de2ff3d699', int64), 0.0_real64), &
                     transfer(int(z'3e63f0e19d32ec5e', int64), 0.0_real64), transfer(int(z'3e653de8ddb68c8c', int64), 0.0_real64), &
                     transfer(int(z'3e669ca3dd7dc2ee', int64), 0.0_real64), transfer(int(z'3e680dd09b68cf73', int64), 0.0_real64), &
                     transfer(int(z'3e699222882f0aef', int64), 0.0_real64), transfer(int(z'3e6b2a5b2769025d', int64), 0.0_real64), &
                     transfer(int(z'3e6cd73bfcaf42b4', int64), 0.0_real64), transfer(int(z'3e6e998d950af301', int64), 0.0_real64), &
                     transfer(int(z'3e70390e011ec3ac', int64), 0.0_real64), transfer(int(z'3e7130def218ad74', int64), 0.0_real64), &
                     transfer(int(z'3e7234a168b01768', int64), 0.0_real64), transfer(int(z'3e7344c439927c29', int64), 0.0_real64), &
                     transfer(int(z'3e7461b477112fd4', int64), 0.0_real64), transfer(int(z'3e758be7ff4a471d', int64), 0.0_real64), &
                     transfer(int(z'3e76c3d12ba389ae', int64), 0.0_real64), transfer(int(z'3e7809e25582bf30', int64), 0.0_real64), &
                     transfer(int(z'3e795e9be92ee375', int64), 0.0_real64), transfer(int(z'3e7ac275872231b3', int64), 0.0_real64), &
                     transfer(int(z'3e7c35ef9ba3a5ba', int64), 0.0_real64), transfer(int(z'3e7db9838989a147', int64), 0.0_real64), &
                     transfer(int(z'3e7f4da72ef2390d', int64), 0.0_real64), transfer(int(z'3e80797c70217bd5', int64), 0.0_real64), &
                     transfer(int(z'3e8154f9e15732af', int64), 0.0_real64), transfer(int(z'3e823992498045cd', int64), 0.0_real64), &
                     transfer(int(z'3e8327833b35f950', int64), 0.0_real64), transfer(int(z'3e841f1314de51ee', int64), 0.0_real64), &
                     transfer(int(z'3e85209100ac14f7', int64), 0.0_real64), transfer(int(z'3e862c4c28d207b9', int64), 0.0_real64), &
                     transfer(int(z'3e874279541cadbe', int64), 0.0_real64), transfer(int(z'3e88637944584d83', int64), 0.0_real64), &
                     transfer(int(z'3e898f80c0516a91', int64), 0.0_real64), transfer(int(z'3e8ac6f089d44b65', int64), 0.0_real64), &
                     transfer(int(z'3e8c0a06337a341f', int64), 0.0_real64), transfer(int(z'3e8d5919b342aaa5', int64), 0.0_real64), &
                     transfer(int(z'3e8eb47a33607446', int64), 0.0_real64), transfer(int(z'3e900e3b6f032b28', int64), 0.0_real64), &
                     transfer(int(z'3e90c8b3d499eb55', int64), 0.0_real64), transfer(int(z'3e9189c979a77d04', int64), 0.0_real64), &
                     transfer(int(z'3e9251a8592ba32a', int64), 0.0_real64), transfer(int(z'3e93207c6e2620b9', int64), 0.0_real64), &
                     transfer(int(z'3e93f671b396b8a3', int64), 0.0_real64), transfer(int(z'3e94d3afbe96cd90', int64), 0.0_real64), &
                     transfer(int(z'3e95b8628a262273', int64), 0.0_real64), transfer(int(z'3e96a4b611447a3e', int64), 0.0_real64), &
                     transfer(int(z'3e9798d64ef197e5', int64), 0.0_real64), transfer(int(z'3e9894f3a4139ea5', int64), 0.0_real64), &
                     transfer(int(z'3e99993a0baa5172', int64), 0.0_real64), transfer(int(z'3e9aa5d11acf12f2', int64), 0.0_real64), &
                     transfer(int(z'3e9bbaed984e66af', int64), 0.0_real64), transfer(int(z'3e9cd8bb7f280f9d', int64), 0.0_real64), &
                     transfer(int(z'3e9dff66ca5bd0ae', int64), 0.0_real64), transfer(int(z'3e9f2f2440b62d6b', int64), 0.0_real64), &
                     transfer(int(z'3ea0340fee9b7464', int64), 0.0_real64), transfer(int(z'3ea0d542cd6ee2db', int64), 0.0_real64), &
                     transfer(int(z'3ea17b47532ed407', int64), 0.0_real64), transfer(int(z'3ea226314a67f939', int64), 0.0_real64), &
                     transfer(int(z'3ea2d61f7c66f484', int64), 0.0_real64), transfer(int(z'3ea38b1f1adee6c8', int64), 0.0_real64), &
                     transfer(int(z'3ea4455587f60289', int64), 0.0_real64), transfer(int(z'3ea504d2285298cd', int64), 0.0_real64), &
                     transfer(int(z'3ea5c9b1924e1b80', int64), 0.0_real64), transfer(int(z'3ea6940e294ecc66', int64), 0.0_real64), &
                     transfer(int(z'3ea764001dc7bd1f', int64), 0.0_real64), transfer(int(z'3ea8399fa02bff49', int64), 0.0_real64), &
                     transfer(int(z'3ea9150713e1d4aa', int64), 0.0_real64), transfer(int(z'3ea9f64ea95c4ee1', int64), 0.0_real64), &
                     transfer(int(z'3eaadd92f6f4dfd8', int64), 0.0_real64), transfer(int(z'3eabcaee6011c954', int64), 0.0_real64), &
                     transfer(int(z'3eacbe7049595c5d', int64), 0.0_real64), transfer(int(z'3eadb84047e4fb9b', int64), 0.0_real64), &
                     transfer(int(z'3eaeb87226415861', int64), 0.0_real64), transfer(int(z'3eafbf2047d4b475', int64), 0.0_real64), &
                     transfer(int(z'3eb066328802a8cd', int64), 0.0_real64), transfer(int(z'3eb0f032f07cb12a', int64), 0.0_real64), &
                     transfer(int(z'3eb17d8bddf87af2', int64), 0.0_real64), transfer(int(z'3eb20e5f662f706e', int64), 0.0_real64), &
                     transfer(int(z'3eb2a2b887e1825c', int64), 0.0_real64), transfer(int(z'3eb33a97430eb0ba', int64), 0.0_real64), &
                     transfer(int(z'3eb3d6119536dd04', int64), 0.0_real64), transfer(int(z'3eb4753d7bd9e8b1', int64), 0.0_real64), &
                     transfer(int(z'3eb5180ff837e305', int64), 0.0_real64), transfer(int(z'3eb5beb505508ef3', int64), 0.0_real64), &
                     transfer(int(z'3eb66921a463fbbf', int64), 0.0_real64), transfer(int(z'3eb7176bd2f20ae1', int64), 0.0_real64), &
                     transfer(int(z'3eb7c99e8fbaad16', int64), 0.0_real64), transfer(int(z'3eb87fcfd83dc3d9', int64), 0.0_real64), &
                     transfer(int(z'3eb939ffac7b4f28', int64), 0.0_real64), transfer(int(z'3eb9f84409f3307d', int64), 0.0_real64), &
                     transfer(int(z'3ebabab2ee254952', int64), 0.0_real64), transfer(int(z'3ebb81415a51a8ea', int64), 0.0_real64), &
                     transfer(int(z'3ebc4c1b49781237', int64), 0.0_real64), transfer(int(z'3ebd1b35bcd8947d', int64), 0.0_real64), &
                     transfer(int(z'3ebdeea6b1f31136', int64), 0.0_real64), transfer(int(z'3ebec6792787791e', int64), 0.0_real64), &
                     transfer(int(z'3ebfa2c31b15adae', int64), 0.0_real64), transfer(int(z'3ec041c2464ed773', int64), 0.0_real64), &
                     transfer(int(z'3ec0b469bccfaf20', int64), 0.0_real64), transfer(int(z'3ec1295d706d563d', int64), 0.0_real64), &
                     transfer(int(z'3ec1a0a85fe7bd85', int64), 0.0_real64), transfer(int(z'3ec21a4a8b3ee4fa', int64), 0.0_real64), &
                     transfer(int(z'3ec2964ef132bd57', int64), 0.0_real64), transfer(int(z'3ec314bb11233efb', int64), 0.0_real64), &
                     transfer(int(z'3ec3958eeb1069e6', int64), 0.0_real64), transfer(int(z'3ec418e07c7a1f91', int64), 0.0_real64), &
                     transfer(int(z'3ec49ea4c6a06f40', int64), 0.0_real64), transfer(int(z'3ec526f1c7033a6c', int64), 0.0_real64), &
                     transfer(int(z'3ec5b1c1fe4288b7', int64), 0.0_real64), transfer(int(z'3ec63f25ea7e433c', int64), 0.0_real64), &
                     transfer(int(z'3ec6cf1d8bb669fa', int64), 0.0_real64), transfer(int(z'3ec761ae614af551', int64), 0.0_real64), &
                     transfer(int(z'3ec7f6e369fbd5fd', int64), 0.0_real64), transfer(int(z'3ec88ebca5c90bfd', int64), 0.0_real64), &
                     transfer(int(z'3ec9294a92d2806d', int64), 0.0_real64), transfer(int(z'3ec9c68d3118334d', int64), 0.0_real64), &
                     transfer(int(z'3eca668f7f5a155a', int64), 0.0_real64), transfer(int(z'3ecb09517d982693', int64), 0.0_real64), &
                     transfer(int(z'3ecbaed8ab325f57', int64), 0.0_real64), transfer(int(z'3ecc57358648a8c1', int64), 0.0_real64), &
                     transfer(int(z'3ecd02628f7b0a73', int64), 0.0_real64), transfer(int(z'3ecdb07044e96d87', int64), 0.0_real64), &
                     transfer(int(z'3ece61592733d9a0', int64), 0.0_real64), transfer(int(z'3ecf152db47a37d8', int64), 0.0_real64), &
                     transfer(int(z'3ecfcbf36c1c808e', int64), 0.0_real64), transfer(int(z'3ed042d7e6bd5610', int64), 0.0_real64), &
                     transfer(int(z'3ed0a12eac9a6118', int64), 0.0_real64), transfer(int(z'3ed1010bc6154e4a', int64), 0.0_real64), &
                     transfer(int(z'3ed16269b3ce2549', int64), 0.0_real64), transfer(int(z'3ed1c54df524de72', int64), 0.0_real64), &
                     transfer(int(z'3ed229bb49c975f6', int64), 0.0_real64), transfer(int(z'3ed28fb7311be432', int64), 0.0_real64), &
                     transfer(int(z'3ed2f73eeb6c2cf6', int64), 0.0_real64), transfer(int(z'3ed3605ab7ca44d2', int64), 0.0_real64), &
                     transfer(int(z'3ed3cb0a96362bc4', int64), 0.0_real64), transfer(int(z'3ed43756c5bfd65a', int64), 0.0_real64), &
                     transfer(int(z'3ed4a53c86b74865', int64), 0.0_real64), transfer(int(z'3ed514be98cc7e14', int64), 0.0_real64), &
                     transfer(int(z'3ed585e27b5f6fc6', int64), 0.0_real64), transfer(int(z'3ed5f8adadd015d8', int64), 0.0_real64), &
                     transfer(int(z'3ed66d17f10e7bbe', int64), 0.0_real64), transfer(int(z'3ed6e33482ea86c1', int64), 0.0_real64), &
                     transfer(int(z'3ed75af864a44625', int64), 0.0_real64), transfer(int(z'3ed7d46bd54bae78', int64), 0.0_real64), &
                     transfer(int(z'3ed84f8ed4e0bfb8', int64), 0.0_real64), transfer(int(z'3ed8cc69a2736e75', int64), 0.0_real64), &
                     transfer(int(z'3ed94afc3e03baad', int64), 0.0_real64), transfer(int(z'3ed9cb46a791a462', int64), 0.0_real64), &
                     transfer(int(z'3eda4d4e5e7d23f0', int64), 0.0_real64), transfer(int(z'3edad11362c63959', int64), 0.0_real64), &
                     transfer(int(z'3edb56a0b32cd559', int64), 0.0_real64), transfer(int(z'3edbddeb50f10732', int64), 0.0_real64), &
                     transfer(int(z'3edc6700fa82bbd2', int64), 0.0_real64), transfer(int(z'3edcf1e1afe1f338', int64), 0.0_real64), &
                     transfer(int(z'3edd7e87f1aeb506', int64), 0.0_real64), transfer(int(z'3ede0d043e08ea56', int64), 0.0_real64), &
                     transfer(int(z'3ede9d4e55e09e9c', int64), 0.0_real64), transfer(int(z'3edf2f6bb895ca35', int64), 0.0_real64), &
                     transfer(int(z'3edfc361e5886581', int64), 0.0_real64), transfer(int(z'3ee02c95aeac3c10', int64), 0.0_real64), &
                     transfer(int(z'3ee0786aef3af77f', int64), 0.0_real64), transfer(int(z'3ee0c52c94e86ac7', int64), 0.0_real64), &
                             transfer(int(z'3ee112debf3c902f', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_11(181) = [ &
                     transfer(int(z'3e25cc6535530fa0', int64), 0.0_real64), transfer(int(z'3e27d09db5b9aaec', int64), 0.0_real64), &
                     transfer(int(z'3e29fd73e5a65b6d', int64), 0.0_real64), transfer(int(z'3e2c55800d0524b5', int64), 0.0_real64), &
                     transfer(int(z'3e2edb81dbd235f0', int64), 0.0_real64), transfer(int(z'3e30c92a93e6134a', int64), 0.0_real64), &
                     transfer(int(z'3e323e78f639fb31', int64), 0.0_real64), transfer(int(z'3e33cf3e9740d92e', int64), 0.0_real64), &
                     transfer(int(z'3e357d193ba47711', int64), 0.0_real64), transfer(int(z'3e3749c2cdd106f6', int64), 0.0_real64), &
                     transfer(int(z'3e3937034b13ef1d', int64), 0.0_real64), transfer(int(z'3e3b46b0c39bc9ea', int64), 0.0_real64), &
                     transfer(int(z'3e3d7ab7cc32b862', int64), 0.0_real64), transfer(int(z'3e3fd5211f6543d5', int64), 0.0_real64), &
                     transfer(int(z'3e412c005d06dc71', int64), 0.0_real64), transfer(int(z'3e4282c08ed0f566', int64), 0.0_real64), &
                     transfer(int(z'3e43eff478ad0a8d', int64), 0.0_real64), transfer(int(z'3e4574c677a7d3be', int64), 0.0_real64), &
                     transfer(int(z'3e4712695a885b4e', int64), 0.0_real64), transfer(int(z'3e48ca294544a305', int64), 0.0_real64), &
                     transfer(int(z'3e4a9d49ea185a30', int64), 0.0_real64), transfer(int(z'3e4c8d2b21019866', int64), 0.0_real64), &
                     transfer(int(z'3e4e9b3ad4dfa961', int64), 0.0_real64), transfer(int(z'3e50646c6ed8525c', int64), 0.0_real64), &
                     transfer(int(z'3e518bc7a60b1f38', int64), 0.0_real64), transfer(int(z'3e52c47b21c9af58', int64), 0.0_real64), &
                     transfer(int(z'3e540f44e0f442ae', int64), 0.0_real64), transfer(int(z'3e556cf7febce75e', int64), 0.0_real64), &
                     transfer(int(z'3e56de7cb2a779c9', int64), 0.0_real64), transfer(int(z'3e5864a617e60814', int64), 0.0_real64), &
                     transfer(int(z'3e5a00636f6d08b0', int64), 0.0_real64), transfer(int(z'3e5bb295e74fbde9', int64), 0.0_real64), &
                     transfer(int(z'3e5d7c41dcd46c67', int64), 0.0_real64), transfer(int(z'3e5f5e4f877ef087', int64), 0.0_real64), &
                     transfer(int(z'3e60ace8abbb618b', int64), 0.0_real64), transfer(int(z'3e61b7e25048c754', int64), 0.0_real64), &
                     transfer(int(z'3e62d0a4f2ec0017', int64), 0.0_real64), transfer(int(z'3e63f7b2c2482e29', int64), 0.0_real64), &
                     transfer(int(z'3e652da309524214', int64), 0.0_real64), transfer(int(z'3e6672ff001df83e', int64), 0.0_real64), &
                     transfer(int(z'3e67c86c04817556', int64), 0.0_real64), transfer(int(z'3e692e7a58010fd6', int64), 0.0_real64), &
                     transfer(int(z'3e6aa5cf5872ec6d', int64), 0.0_real64), transfer(int(z'3e6c2f0250cbfba6', int64), 0.0_real64), &
                     transfer(int(z'3e6dcac6b1c39654', int64), 0.0_real64), transfer(int(z'3e6f79bacfbf4716', int64), 0.0_real64), &
                     transfer(int(z'3e709e4ad01759e5', int64), 0.0_real64), transfer(int(z'3e718a0002d02713', int64), 0.0_real64), &
                     transfer(int(z'3e72805bff7a2b0e', int64), 0.0_real64), transfer(int(z'3e7381b6bc14ebbb', int64), 0.0_real64), &
                     transfer(int(z'3e748e747f24fca0', int64), 0.0_real64), transfer(int(z'3e75a6f0c36230ac', int64), 0.0_real64), &
                     transfer(int(z'3e76cb9191ad41e9', int64), 0.0_real64), transfer(int(z'3e77fcb5e976504f', int64), 0.0_real64), &
                     transfer(int(z'3e793acc9f6ad67f', int64), 0.0_real64), transfer(int(z'3e7a863675571af6', int64), 0.0_real64), &
                     transfer(int(z'3e7bdf6b0bb558ec', int64), 0.0_real64), transfer(int(z'3e7d46c09628efc2', int64), 0.0_real64), &
                     transfer(int(z'3e7ebca7abbb809e', int64), 0.0_real64), transfer(int(z'3e8020d6849c8a77', int64), 0.0_real64), &
                     transfer(int(z'3e80eb145250994d', int64), 0.0_real64), transfer(int(z'3e81bd4ad19330f1', int64), 0.0_real64), &
                     transfer(int(z'3e8297aec930d4ed', int64), 0.0_real64), transfer(int(z'3e837a8f635c4a8f', int64), 0.0_real64), &
                     transfer(int(z'3e84660fcf489433', int64), 0.0_real64), transfer(int(z'3e855a7f37287729', int64), 0.0_real64), &
                     transfer(int(z'3e86581b2d95378f', int64), 0.0_real64), transfer(int(z'3e875f2145281988', int64), 0.0_real64), &
                     transfer(int(z'3e886fcf107a6135', int64), 0.0_real64), transfer(int(z'3e898a62222552b4', int64), 0.0_real64), &
                     transfer(int(z'3e8aaf29a45bb356', int64), 0.0_real64), transfer(int(z'3e8bde6329b6c73b', int64), 0.0_real64), &
                     transfer(int(z'3e8d1855109c931b', int64), 0.0_real64), transfer(int(z'3e8e5d3ceba65b16', int64), 0.0_real64), &
                     transfer(int(z'3e8fad69e506e47b', int64), 0.0_real64), transfer(int(z'3e9084912d921a00', int64), 0.0_real64), &
                     transfer(int(z'3e91385656322730', int64), 0.0_real64), transfer(int(z'3e91f2279b969c29', int64), 0.0_real64), &
                     transfer(int(z'3e92b22c92d8db91', int64), 0.0_real64), transfer(int(z'3e93788405458779', int64), 0.0_real64), &
                     transfer(int(z'3e94455e53c2c320', int64), 0.0_real64), transfer(int(z'3e9518da479d3095', int64), 0.0_real64), &
                     transfer(int(z'3e95f323dbd492cc', int64), 0.0_real64), transfer(int(z'3e96d459d9b58bd5', int64), 0.0_real64), &
                     transfer(int(z'3e97bcb1080c9f39', int64), 0.0_real64), transfer(int(z'3e98ac43ca400ebe', int64), 0.0_real64), &
                     transfer(int(z'3e99a33e1b4f9d56', int64), 0.0_real64), transfer(int(z'3e9aa1cbf63b0df4', int64), 0.0_real64), &
                     transfer(int(z'3e9ba8195602238b', int64), 0.0_real64), transfer(int(z'3e9cb64503f1802b', int64), 0.0_real64), &
                     transfer(int(z'3e9dcc882cbc07aa', int64), 0.0_real64), transfer(int(z'3e9eeafd33c7fbcb', int64), 0.0_real64), &
                     transfer(int(z'3ea008ec6ff0f00d', int64), 0.0_real64), transfer(int(z'3ea0a0a163118b9f', int64), 0.0_real64), &
                     transfer(int(z'3ea13cb370c5b214', int64), 0.0_real64), transfer(int(z'3ea1dd36639a14c0', int64), 0.0_real64), &
                     transfer(int(z'3ea28246d1e8258f', int64), 0.0_real64), transfer(int(z'3ea32bf1ed630561', int64), 0.0_real64), &
                     transfer(int(z'3ea3da567f575648', int64), 0.0_real64), transfer(int(z'3ea48d83ec6b694c', int64), 0.0_real64), &
                     transfer(int(z'3ea54596caf8b057', int64), 0.0_real64), transfer(int(z'3ea602a2e58bdcbd', int64), 0.0_real64), &
                     transfer(int(z'3ea6c4c06c98001e', int64), 0.0_real64), transfer(int(z'3ea78c032aa9cbcc', int64), 0.0_real64), &
                     transfer(int(z'3ea85887b61ab1b3', int64), 0.0_real64), transfer(int(z'3ea92a61d9776326', int64), 0.0_real64), &
                     transfer(int(z'3eaa01abf82621ea', int64), 0.0_real64), transfer(int(z'3eaade79dcb39f52', int64), 0.0_real64), &
                     transfer(int(z'3eabc0e81d794d4a', int64), 0.0_real64), transfer(int(z'3eaca90cb7f70d4a', int64), 0.0_real64), &
                     transfer(int(z'3ead96fda9acc0cd', int64), 0.0_real64), transfer(int(z'3eae8ad788f3d9bc', int64), 0.0_real64), &
                     transfer(int(z'3eaf84ae2059096b', int64), 0.0_real64), transfer(int(z'3eb0424f031ae0e2', int64), 0.0_real64), &
                     transfer(int(z'3eb0c55d828b5a0f', int64), 0.0_real64), transfer(int(z'3eb14b8d8d3de0f7', int64), 0.0_real64), &
                     transfer(int(z'3eb1d4f2edbf26ef', int64), 0.0_real64), transfer(int(z'3eb2619bef3be4ec', int64), 0.0_real64), &
                     transfer(int(z'3eb2f18891b41aee', int64), 0.0_real64), transfer(int(z'3eb384c3d3e7b9b1', int64), 0.0_real64), &
                     transfer(int(z'3eb41b6eb216936c', int64), 0.0_real64), transfer(int(z'3eb4b57e2d80b763', int64), 0.0_real64), &
                     transfer(int(z'3eb553134265f7ca', int64), 0.0_real64), transfer(int(z'3eb5f42df0c654a2', int64), 0.0_real64), &
                     transfer(int(z'3eb698e43621af65', int64), 0.0_real64), transfer(int(z'3eb7413612780813', int64), 0.0_real64), &
                     transfer(int(z'3eb7ed3983494024', int64), 0.0_real64), transfer(int(z'3eb89cf987554856', int64), 0.0_real64), &
                     transfer(int(z'3eb950811d5c1165', int64), 0.0_real64), transfer(int(z'3eba07db441d8c0e', int64), 0.0_real64), &
                     transfer(int(z'3ebac31df91999cb', int64), 0.0_real64), transfer(int(z'3ebb82543b102b57', int64), 0.0_real64), &
                     transfer(int(z'3ebc458908c13171', int64), 0.0_real64), transfer(int(z'3ebd0cbc622cac17', int64), 0.0_real64), &
                     transfer(int(z'3ebdd80f43926d80', int64), 0.0_real64), transfer(int(z'3ebea78cabb26668', int64), 0.0_real64), &
                     transfer(int(z'3ebf7b349a8c96d0', int64), 0.0_real64), transfer(int(z'3ec0298e86d07019', int64), 0.0_real64), &
                     transfer(int(z'3ec097a881d799a4', int64), 0.0_real64), transfer(int(z'3ec107f33d1bb8c7', int64), 0.0_real64), &
                     transfer(int(z'3ec17a69393cd523', int64), 0.0_real64), transfer(int(z'3ec1ef2073bad032', int64), 0.0_real64), &
                     transfer(int(z'3ec266136d35b194', int64), 0.0_real64), transfer(int(z'3ec2df4d246d6a08', int64), 0.0_real64), &
                     transfer(int(z'3ec35ad89821ea4a', int64), 0.0_real64), transfer(int(z'3ec3d8b5c8533258', int64), 0.0_real64), &
                     transfer(int(z'3ec458efb3c132f2', int64), 0.0_real64), transfer(int(z'3ec4db865a6bec15', int64), 0.0_real64), &
                     transfer(int(z'3ec5608a3a7346de', int64), 0.0_real64), transfer(int(z'3ec5e7fb53d7434c', int64), 0.0_real64), &
                     transfer(int(z'3ec671df25f7d9be', int64), 0.0_real64), transfer(int(z'3ec6fe40af94faf1', int64), 0.0_real64), &
                     transfer(int(z'3ec78d25700e9f42', int64), 0.0_real64), transfer(int(z'3ec81e92e6c4bf10', int64), 0.0_real64), &
                     transfer(int(z'3ec8b28e931752ba', int64), 0.0_real64), transfer(int(z'3ec9492373c64afb', int64), 0.0_real64), &
                     transfer(int(z'3ec9e25188d1a7d5', int64), 0.0_real64), transfer(int(z'3eca7e2950595262', int64), 0.0_real64), &
                     transfer(int(z'3ecb1ca54afd5244', int64), 0.0_real64), transfer(int(z'3ecbbdd0777d9838', int64), 0.0_real64), &
                     transfer(int(z'3ecc61b5d49a14f9', int64), 0.0_real64), transfer(int(z'3ecd085ae1b2c0e8', int64), 0.0_real64), &
                     transfer(int(z'3ecdb1bf9ec79c02', int64), 0.0_real64), transfer(int(z'3ece5def0a989707', int64), 0.0_real64), &
                     transfer(int(z'3ecf0ceea485aa52', int64), 0.0_real64), transfer(int(z'3ecfbec96b4ec6a2', int64), 0.0_real64), &
                     transfer(int(z'3ed039bfaf79f5fb', int64), 0.0_real64), transfer(int(z'3ed095907eca81b5', int64), 0.0_real64), &
                     transfer(int(z'3ed0f2d1a4390e20', int64), 0.0_real64), transfer(int(z'3ed1518e1e858bf9', int64), 0.0_real64), &
                     transfer(int(z'3ed1b1c5edaffb41', int64), 0.0_real64), transfer(int(z'3ed2137bd1685825', int64), 0.0_real64), &
                     transfer(int(z'3ed276b5490e9b05', int64), 0.0_real64), transfer(int(z'3ed2db751452c010', int64), 0.0_real64), &
                     transfer(int(z'3ed341bb3334c745', int64), 0.0_real64), transfer(int(z'3ed3a98d2514a904', int64), 0.0_real64), &
                     transfer(int(z'3ed412eda9a2617a', int64), 0.0_real64), transfer(int(z'3ed47de2403de908', int64), 0.0_real64), &
                     transfer(int(z'3ed4ea6ae8e73fac', int64), 0.0_real64), transfer(int(z'3ed5588d22fe5dc5', int64), 0.0_real64), &
                             transfer(int(z'3ed5c848ee834352', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_12(181) = [ &
                     transfer(int(z'3df2d2de8376a22d', int64), 0.0_real64), transfer(int(z'3df4ecd216271ce9', int64), 0.0_real64), &
                     transfer(int(z'3df73b24e0294fb1', int64), 0.0_real64), transfer(int(z'3df9c22ac42de718', int64), 0.0_real64), &
                     transfer(int(z'3dfc867fb3a40b4f', int64), 0.0_real64), transfer(int(z'3dff8d07aeb96024', int64), 0.0_real64), &
                     transfer(int(z'3e016d806404d1f4', int64), 0.0_real64), transfer(int(z'3e033afd11637000', int64), 0.0_real64), &
                     transfer(int(z'3e0531ee7a489c2a', int64), 0.0_real64), transfer(int(z'3e075574024581cc', int64), 0.0_real64), &
                     transfer(int(z'3e09a8e317fa28f5', int64), 0.0_real64), transfer(int(z'3e0c2fbe333da6f7', int64), 0.0_real64), &
                     transfer(int(z'3e0eedc0176be1b6', int64), 0.0_real64), transfer(int(z'3e10f36cc977cde7', int64), 0.0_real64), &
                     transfer(int(z'3e128f9b00172e25', int64), 0.0_real64), transfer(int(z'3e144d9c82893d63', int64), 0.0_real64), &
                     transfer(int(z'3e162fb9a85eae12', int64), 0.0_real64), transfer(int(z'3e18387434e7fd22', int64), 0.0_real64), &
                     transfer(int(z'3e1a6a4deb75a786', int64), 0.0_real64), transfer(int(z'3e1cc800dadcfac0', int64), 0.0_real64), &
                     transfer(int(z'3e1f5468d8dc8e49', int64), 0.0_real64), transfer(int(z'3e210941c10e21c3', int64), 0.0_real64), &
                     transfer(int(z'3e2282b81d16a2e9', int64), 0.0_real64), transfer(int(z'3e24183815c5053d', int64), 0.0_real64), &
                     transfer(int(z'3e25cb7e6618ebac', int64), 0.0_real64), transfer(int(z'3e279e5e4dad7fc8', int64), 0.0_real64), &
                     transfer(int(z'3e2992b64e6bae71', int64), 0.0_real64), transfer(int(z'3e2baa810ffeccd2', int64), 0.0_real64), &
                     transfer(int(z'3e2de7ca1d86d50d', int64), 0.0_real64), transfer(int(z'3e3026623519f671', int64), 0.0_real64), &
                     transfer(int(z'3e316dd4452e8dd9', int64), 0.0_real64), transfer(int(z'3e32cb686ca1596d', int64), 0.0_real64), &
                     transfer(int(z'3e3440571b604526', int64), 0.0_real64), transfer(int(z'3e35cde9a4cde1fc', int64), 0.0_real64), &
                     transfer(int(z'3e3775749e9a8434', int64), 0.0_real64), transfer(int(z'3e393857e0c44363', int64), 0.0_real64), &
                     transfer(int(z'3e3b180426bddc19', int64), 0.0_real64), transfer(int(z'3e3d15f29db45d62', int64), 0.0_real64), &
                     transfer(int(z'3e3f33bb692aaf66', int64), 0.0_real64), transfer(int(z'3e40b9771d74b3ea', int64), 0.0_real64), &
                     transfer(int(z'3e41eaa27eae5c62', int64), 0.0_real64), transfer(int(z'3e432e372c518881', int64), 0.0_real64), &
                     transfer(int(z'3e44851ec62bcd10', int64), 0.0_real64), transfer(int(z'3e45f0401b774e01', int64), 0.0_real64), &
                     transfer(int(z'3e4770a3c257793b', int64), 0.0_real64), transfer(int(z'3e49073d349dee6d', int64), 0.0_real64), &
                     transfer(int(z'3e4ab509c620582c', int64), 0.0_real64), transfer(int(z'3e4c7b22f076c956', int64), 0.0_real64), &
                     transfer(int(z'3e4e5ab0401a88ee', int64), 0.0_real64), transfer(int(z'3e502a659751d4ea', int64), 0.0_real64), &
                     transfer(int(z'3e51354da445b985', int64), 0.0_real64), transfer(int(z'3e524eab16962fdd', int64), 0.0_real64), &
                     transfer(int(z'3e53771fc7610f97', int64), 0.0_real64), transfer(int(z'3e54af4d8fc4305b', int64), 0.0_real64), &
                     transfer(int(z'3e55f7e45bbe9df3', int64), 0.0_real64), transfer(int(z'3e57518d0ddeca18', int64), 0.0_real64), &
                     transfer(int(z'3e58bd05a504f4ba', int64), 0.0_real64), transfer(int(z'3e5a3af703bf8f92', int64), 0.0_real64), &
                     transfer(int(z'3e5bcc2d3bd00eb4', int64), 0.0_real64), transfer(int(z'3e5d71664c16b210', int64), 0.0_real64), &
                     transfer(int(z'3e5f2b6e4654edbc', int64), 0.0_real64), transfer(int(z'3e607d889e261ae5', int64), 0.0_real64), &
                     transfer(int(z'3e617094a94f993b', int64), 0.0_real64), transfer(int(z'3e626f414d87abe9', int64), 0.0_real64), &
                     transfer(int(z'3e637a09b000db32', int64), 0.0_real64), transfer(int(z'3e649153d99be11f', int64), 0.0_real64), &
                     transfer(int(z'3e65b5a1f8fbe004', int64), 0.0_real64), transfer(int(z'3e66e76120722bfe', int64), 0.0_real64), &
                     transfer(int(z'3e6827137ea1e761', int64), 0.0_real64), transfer(int(z'3e697537bd75e777', int64), 0.0_real64), &
                     transfer(int(z'3e6ad24c86d9018a', int64), 0.0_real64), transfer(int(z'3e6c3ed78e26a4f8', int64), 0.0_real64), &
                     transfer(int(z'3e6dbb620b728e28', int64), 0.0_real64), transfer(int(z'3e6f487536d0797e', int64), 0.0_real64), &
                     transfer(int(z'3e70734ee6863835', int64), 0.0_real64), transfer(int(z'3e714b37ca318b37', int64), 0.0_real64), &
                     transfer(int(z'3e722c3f29888786', int64), 0.0_real64), transfer(int(z'3e7316ad254d585e', int64), 0.0_real64), &
                     transfer(int(z'3e740ad46c6b1017', int64), 0.0_real64), transfer(int(z'3e750900a45c26f7', int64), 0.0_real64), &
                     transfer(int(z'3e761182b9af88d0', int64), 0.0_real64), transfer(int(z'3e7724ad5b5047fa', int64), 0.0_real64), &
                     transfer(int(z'3e7842d4fa859d52', int64), 0.0_real64), transfer(int(z'3e796c4a83de74aa', int64), 0.0_real64), &
                     transfer(int(z'3e7aa16cf6caedfc', int64), 0.0_real64), transfer(int(z'3e7be282b1b10dfe', int64), 0.0_real64), &
                     transfer(int(z'3e7d300192aee964', int64), 0.0_real64), transfer(int(z'3e7e8a37019b1ef9', int64), 0.0_real64), &
                     transfer(int(z'3e7ff17af47534a1', int64), 0.0_real64), transfer(int(z'3e80b31b7c6b18b8', int64), 0.0_real64), &
                     transfer(int(z'3e81746a4e2b8e3d', int64), 0.0_real64), transfer(int(z'3e823ccd1eaefd3b', int64), 0.0_real64), &
                     transfer(int(z'3e830c78b4c1e93c', int64), 0.0_real64), transfer(int(z'3e83e3aaa2fd9661', int64), 0.0_real64), &
                     transfer(int(z'3e84c297b02e8833', int64), 0.0_real64), transfer(int(z'3e85a9630b87c10e', int64), 0.0_real64), &
                     transfer(int(z'3e869853136f45aa', int64), 0.0_real64), transfer(int(z'3e878f9c8eb19991', int64), 0.0_real64), &
                     transfer(int(z'3e888f6b784e7fb5', int64), 0.0_real64), transfer(int(z'3e8997fd62df3c37', int64), 0.0_real64), &
                     transfer(int(z'3e8aa98fe0fd1338', int64), 0.0_real64), transfer(int(z'3e8bc457b9748842', int64), 0.0_real64), &
                     transfer(int(z'3e8ce8927ededf74', int64), 0.0_real64), transfer(int(z'3e8e167dc3d55cf1', int64), 0.0_real64), &
                     transfer(int(z'3e8f4e4e4f248441', int64), 0.0_real64), transfer(int(z'3e904820d9b2ccc3', int64), 0.0_real64), &
                     transfer(int(z'3e90ee4ac198f070', int64), 0.0_real64), transfer(int(z'3e9199cc745e0fce', int64), 0.0_real64), &
                     transfer(int(z'3e924abbef820c58', int64), 0.0_real64), transfer(int(z'3e930137fc51881e', int64), 0.0_real64), &
                     transfer(int(z'3e93bd682fe5e5c6', int64), 0.0_real64), transfer(int(z'3e947f6b538bc762', int64), 0.0_real64), &
                     transfer(int(z'3e95476496762f4c', int64), 0.0_real64), transfer(int(z'3e961572c1f1bf97', int64), 0.0_real64), &
                     transfer(int(z'3e96e9b905317a9c', int64), 0.0_real64), transfer(int(z'3e97c4562982026d', int64), 0.0_real64), &
                     transfer(int(z'3e98a57629e319fc', int64), 0.0_real64), transfer(int(z'3e998d2f03d4a2c3', int64), 0.0_real64), &
                     transfer(int(z'3e9a7bb57e23204c', int64), 0.0_real64), transfer(int(z'3e9b711f964e740f', int64), 0.0_real64), &
                     transfer(int(z'3e9c6d94e17000b5', int64), 0.0_real64), transfer(int(z'3e9d713cf4a128e4', int64), 0.0_real64), &
                     transfer(int(z'3e9e7c3f64fb4f44', int64), 0.0_real64), transfer(int(z'3e9f8ebf61b17631', int64), 0.0_real64), &
                     transfer(int(z'3ea0546dda081fde', int64), 0.0_real64), transfer(int(z'3ea0e5625e7ee790', int64), 0.0_real64), &
                     transfer(int(z'3ea17a5108c9c384', int64), 0.0_real64), transfer(int(z'3ea213493d8f04c1', int64), 0.0_real64), &
                     transfer(int(z'3ea2b060fa4e8cc1', int64), 0.0_real64), transfer(int(z'3ea351a9d6a1dcb2', int64), 0.0_real64), &
                     transfer(int(z'3ea3f73c02fc0633', int64), 0.0_real64), transfer(int(z'3ea4a12916f68a72', int64), 0.0_real64), &
                     transfer(int(z'3ea54f8710114ae8', int64), 0.0_real64), transfer(int(z'3ea60269b8d8f8e8', int64), 0.0_real64), &
                     transfer(int(z'3ea6b9e70ecd75ed', int64), 0.0_real64), transfer(int(z'3ea7760e769512ff', int64), 0.0_real64), &
                     transfer(int(z'3ea836fa539611e1', int64), 0.0_real64), transfer(int(z'3ea8fcc2d6438435', int64), 0.0_real64), &
                     transfer(int(z'3ea9c77530508adb', int64), 0.0_real64), transfer(int(z'3eaa972df81697be', int64), 0.0_real64), &
                     transfer(int(z'3eab6bfec52f2c0d', int64), 0.0_real64), transfer(int(z'3eac45ffc80d5966', int64), 0.0_real64), &
                     transfer(int(z'3ead2544cb3dd11e', int64), 0.0_real64), transfer(int(z'3eae09e83226d4f9', int64), 0.0_real64), &
                     transfer(int(z'3eaef3fb9461e624', int64), 0.0_real64), transfer(int(z'3eafe394ef6ee61a', int64), 0.0_real64), &
                     transfer(int(z'3eb06c686cd3a363', int64), 0.0_real64), transfer(int(z'3eb0e9e2a84574cf', int64), 0.0_real64), &
                     transfer(int(z'3eb16a430f533ffd', int64), 0.0_real64), transfer(int(z'3eb1ed8f215cfd4a', int64), 0.0_real64), &
                     transfer(int(z'3eb273dcdbe28e30', int64), 0.0_real64), transfer(int(z'3eb2fd373da3e36b', int64), 0.0_real64), &
                     transfer(int(z'3eb3899e46a0fcfc', int64), 0.0_real64), transfer(int(z'3eb41932f319ad18', int64), 0.0_real64), &
                     transfer(int(z'3eb4abea444e0303', int64), 0.0_real64), transfer(int(z'3eb541da37bde037', int64), 0.0_real64), &
                     transfer(int(z'3eb5db0dcc29356f', int64), 0.0_real64), transfer(int(z'3eb6779aff0fe425', int64), 0.0_real64), &
                     transfer(int(z'3eb71776d1b1fb9e', int64), 0.0_real64), transfer(int(z'3eb7bacd3f0f3eca', int64), 0.0_real64), &
                     transfer(int(z'3eb8618849a7cc32', int64), 0.0_real64), transfer(int(z'3eb90bc8edbb760b', int64), 0.0_real64), &
                     transfer(int(z'3eb9b99a2a0a2d11', int64), 0.0_real64), transfer(int(z'3eba6b06fd53e202', int64), 0.0_real64), &
                     transfer(int(z'3ebb200f679894de', int64), 0.0_real64), transfer(int(z'3ebbd8d4651817da', int64), 0.0_real64), &
                     transfer(int(z'3ebc9555f5d26af7', int64), 0.0_real64), transfer(int(z'3ebd559f18877ef1', int64), 0.0_real64), &
                     transfer(int(z'3ebe19c5cab73541', int64), 0.0_real64), transfer(int(z'3ebee1ca0c618de9', int64), 0.0_real64), &
                     transfer(int(z'3ebfadccd9c65b1d', int64), 0.0_real64), transfer(int(z'3ec03ee19a12d611', int64), 0.0_real64), &
                     transfer(int(z'3ec0a8e18c7fb137', int64), 0.0_real64), transfer(int(z'3ec114f142e9afc0', int64), 0.0_real64), &
                     transfer(int(z'3ec18310bd50d1a9', int64), 0.0_real64), transfer(int(z'3ec1f34afa7507b1', int64), 0.0_real64), &
                     transfer(int(z'3ec265a579b64a35', int64), 0.0_real64), transfer(int(z'3ec2da203b149936', int64), 0.0_real64), &
                     transfer(int(z'3ec350cbbcafddcf', int64), 0.0_real64), transfer(int(z'3ec3c9a7fe8817fe', int64), 0.0_real64), &
                             transfer(int(z'3ec444ba7ffd4024', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_13(181) = [ &
                     transfer(int(z'3dc8f054bb0e8122', int64), 0.0_real64), transfer(int(z'3dcc1dcec7c45265', int64), 0.0_real64), &
                     transfer(int(z'3dcfa704665ee80f', int64), 0.0_real64), transfer(int(z'3dd1ca6b80d2657d', int64), 0.0_real64), &
                     transfer(int(z'3dd3f881e57724e7', int64), 0.0_real64), transfer(int(z'3dd662f8a4b677a8', int64), 0.0_real64), &
                     transfer(int(z'3dd90f72b29d2f88', int64), 0.0_real64), transfer(int(z'3ddc040d82af23a8', int64), 0.0_real64), &
                     transfer(int(z'3ddf474268096f2a', int64), 0.0_real64), transfer(int(z'3de170166b7ae1aa', int64), 0.0_real64), &
                     transfer(int(z'3de36b212b15f5f7', int64), 0.0_real64), transfer(int(z'3de598df4a77c45b', int64), 0.0_real64), &
                     transfer(int(z'3de7fd9baa7929f3', int64), 0.0_real64), transfer(int(z'3dea9dfb3e611e65', int64), 0.0_real64), &
                     transfer(int(z'3ded7f060dbc834d', int64), 0.0_real64), transfer(int(z'3df052fd15938b7f', int64), 0.0_real64), &
                     transfer(int(z'3df20c49e184f80e', int64), 0.0_real64), transfer(int(z'3df3ee6b88465077', int64), 0.0_real64), &
                     transfer(int(z'3df5fc95b18e52d6', int64), 0.0_real64), transfer(int(z'3df83a4413d238e7', int64), 0.0_real64), &
                     transfer(int(z'3dfaab0d6b0eaac0', int64), 0.0_real64), transfer(int(z'3dfd52de04c28342', int64), 0.0_real64), &
                     transfer(int(z'3e001ae55b5be16b', int64), 0.0_real64), transfer(int(z'3e01ac1a7331669f', int64), 0.0_real64), &
                     transfer(int(z'3e035f5e830f5931', int64), 0.0_real64), transfer(int(z'3e0537214a96972c', int64), 0.0_real64), &
                     transfer(int(z'3e0735fd52291800', int64), 0.0_real64), transfer(int(z'3e095eaa68263553', int64), 0.0_real64), &
                     transfer(int(z'3e0bb41665fc2583', int64), 0.0_real64), transfer(int(z'3e0e3943693eb1b2', int64), 0.0_real64), &
                     transfer(int(z'3e1078b70dbe33b8', int64), 0.0_real64), transfer(int(z'3e11f00017bd70c9', int64), 0.0_real64), &
                     transfer(int(z'3e138444cfea764c', int64), 0.0_real64), transfer(int(z'3e15375e17074f79', int64), 0.0_real64), &
                     transfer(int(z'3e170b51d70d14cb', int64), 0.0_real64), transfer(int(z'3e190225f9f4debe', int64), 0.0_real64), &
                     transfer(int(z'3e1b1e18b53c965e', int64), 0.0_real64), transfer(int(z'3e1d61683e6224ba', int64), 0.0_real64), &
                     transfer(int(z'3e1fce7fd41a8021', int64), 0.0_real64), transfer(int(z'3e2133f09cdb12c3', int64), 0.0_real64), &
                     transfer(int(z'3e229817fcb76de6', int64), 0.0_real64), transfer(int(z'3e241513110cf83b', int64), 0.0_real64), &
                     transfer(int(z'3e25ac5565e1df25', int64), 0.0_real64), transfer(int(z'3e275f636ab0f502', int64), 0.0_real64), &
                     transfer(int(z'3e292fccd142cf7d', int64), 0.0_real64), transfer(int(z'3e2b1f322ed4a93c', int64), 0.0_real64), &
                     transfer(int(z'3e2d2f55df8d06d7', int64), 0.0_real64), transfer(int(z'3e2f61eefd44a995', int64), 0.0_real64), &
                     transfer(int(z'3e30dc73a61920d3', int64), 0.0_real64), transfer(int(z'3e321b1718d9b073', int64), 0.0_real64), &
                     transfer(int(z'3e336de1fb4d1f12', int64), 0.0_real64), transfer(int(z'3e34d5e555512d14', int64), 0.0_real64), &
                     transfer(int(z'3e365434ff570baf', int64), 0.0_real64), transfer(int(z'3e37e9f2e4b1203d', int64), 0.0_real64), &
                     transfer(int(z'3e39984c32ff936b', int64), 0.0_real64), transfer(int(z'3e3b607efb5732dd', int64), 0.0_real64), &
                     transfer(int(z'3e3d43cc1f603d0c', int64), 0.0_real64), transfer(int(z'3e3f438834cb063c', int64), 0.0_real64), &
                     transfer(int(z'3e40b086b937622f', int64), 0.0_real64), transfer(int(z'3e41cee21101f0c1', int64), 0.0_real64), &
                     transfer(int(z'3e42fd9588ef272e', int64), 0.0_real64), transfer(int(z'3e443d608828fdd1', int64), 0.0_real64), &
                     transfer(int(z'3e458f0db8273054', int64), 0.0_real64), transfer(int(z'3e46f367c2617a61', int64), 0.0_real64), &
                     transfer(int(z'3e486b45fae7135e', int64), 0.0_real64), transfer(int(z'3e49f797a2ac71bb', int64), 0.0_real64), &
                     transfer(int(z'3e4b992fd4e3a39f', int64), 0.0_real64), transfer(int(z'3e4d50efbf9feb56', int64), 0.0_real64), &
                     transfer(int(z'3e4f1fe2c998279a', int64), 0.0_real64), transfer(int(z'3e50838323510180', int64), 0.0_real64), &
                     transfer(int(z'3e5183a4bbd8f9fc', int64), 0.0_real64), transfer(int(z'3e5290e2eb3006b0', int64), 0.0_real64), &
                     transfer(int(z'3e53abca6e22310c', int64), 0.0_real64), transfer(int(z'3e54d4d9ee9a4e5a', int64), 0.0_real64), &
                     transfer(int(z'3e560cba4f26d054', int64), 0.0_real64), transfer(int(z'3e5753f143232656', int64), 0.0_real64), &
                     transfer(int(z'3e58ab199a3c8df3', int64), 0.0_real64), transfer(int(z'3e5a12dc370178e6', int64), 0.0_real64), &
                     transfer(int(z'3e5b8bdaf28fbed4', int64), 0.0_real64), transfer(int(z'3e5d16b7a6053764', int64), 0.0_real64), &
                     transfer(int(z'3e5eb4223d60ee60', int64), 0.0_real64), transfer(int(z'3e603261cd98aac1', int64), 0.0_real64), &
                     transfer(int(z'3e6114b063e3a366', int64), 0.0_real64), transfer(int(z'3e620154d790e705', int64), 0.0_real64), &
                     transfer(int(z'3e62f8b531812fa7', int64), 0.0_real64), transfer(int(z'3e63fb2967b40333', int64), 0.0_real64), &
                     transfer(int(z'3e65091b07c268bc', int64), 0.0_real64), transfer(int(z'3e6622f39f456755', int64), 0.0_real64), &
                     transfer(int(z'3e674919371db908', int64), 0.0_real64), transfer(int(z'3e687bfc6654fefd', int64), 0.0_real64), &
                     transfer(int(z'3e69bc06ba844045', int64), 0.0_real64), transfer(int(z'3e6b09a8cab51e07', int64), 0.0_real64), &
                     transfer(int(z'3e6c655a3761d37b', int64), 0.0_real64), transfer(int(z'3e6dcf92a1049bd9', int64), 0.0_real64), &
                     transfer(int(z'3e6f48c6235f6551', int64), 0.0_real64), transfer(int(z'3e7068b9b42e8296', int64), 0.0_real64), &
                     transfer(int(z'3e71350c8cf4285b', int64), 0.0_real64), transfer(int(z'3e72099cb3523522', int64), 0.0_real64), &
                     transfer(int(z'3e72e6ab3e9a3a13', int64), 0.0_real64), transfer(int(z'3e73cc79461dc859', int64), 0.0_real64), &
                     transfer(int(z'3e74bb4eea9f0b30', int64), 0.0_real64), transfer(int(z'3e75b3728a840750', int64), 0.0_real64), &
                     transfer(int(z'3e76b52a8432c171', int64), 0.0_real64), transfer(int(z'3e77c0c0bac98b52', int64), 0.0_real64), &
                     transfer(int(z'3e78d67b8cae69ad', int64), 0.0_real64), transfer(int(z'3e79f6abe6704854', int64), 0.0_real64), &
                     transfer(int(z'3e7b219d6d899f8c', int64), 0.0_real64), transfer(int(z'3e7c579bc774e79c', int64), 0.0_real64), &
                     transfer(int(z'3e7d99026ee9f371', int64), 0.0_real64), transfer(int(z'3e7ee617c24ec7c4', int64), 0.0_real64), &
                     transfer(int(z'3e801f911004b4a6', int64), 0.0_real64), transfer(int(z'3e80d24e56a63025', int64), 0.0_real64), &
                     transfer(int(z'3e818b5e18721824', int64), 0.0_real64), transfer(int(z'3e824aec50682f97', int64), 0.0_real64), &
                     transfer(int(z'3e83112dc554fa05', int64), 0.0_real64), transfer(int(z'3e83de4e72383a64', int64), 0.0_real64), &
                     transfer(int(z'3e84b27a5211b3a4', int64), 0.0_real64), transfer(int(z'3e858de62bade951', int64), 0.0_real64), &
                     transfer(int(z'3e8670ac62731d2e', int64), 0.0_real64), transfer(int(z'3e875b1c2094148a', int64), 0.0_real64), &
                     transfer(int(z'3e884d4fc977112c', int64), 0.0_real64), transfer(int(z'3e89477c23e8969b', int64), 0.0_real64), &
                     transfer(int(z'3e8a49dec281e8f8', int64), 0.0_real64), transfer(int(z'3e8b549ad4760aa1', int64), 0.0_real64), &
                     transfer(int(z'3e8c67ff83f7c0e3', int64), 0.0_real64), transfer(int(z'3e8d841e68a08ceb', int64), 0.0_real64), &
                     transfer(int(z'3e8ea93de0d67373', int64), 0.0_real64), transfer(int(z'3e8fd7a44aff7931', int64), 0.0_real64), &
                     transfer(int(z'3e9087b60540eff5', int64), 0.0_real64), transfer(int(z'3e91286dbee1d62b', int64), 0.0_real64), &
                     transfer(int(z'3e91ce181baf114b', int64), 0.0_real64), transfer(int(z'3e9278cb192882ce', int64), 0.0_real64), &
                     transfer(int(z'3e9328a9e6812d11', int64), 0.0_real64), transfer(int(z'3e93ddcee71f51d7', int64), 0.0_real64), &
                     transfer(int(z'3e949858e44f9331', int64), 0.0_real64), transfer(int(z'3e955866a75e9330', int64), 0.0_real64), &
                     transfer(int(z'3e961e1293b29399', int64), 0.0_real64), transfer(int(z'3e96e97fd87e96c7', int64), 0.0_real64), &
                     transfer(int(z'3e97bacd3f0f3eca', int64), 0.0_real64), transfer(int(z'3e98921df6978dff', int64), 0.0_real64), &
                     transfer(int(z'3e996f87fc9765df', int64), 0.0_real64), transfer(int(z'3e9a53374c0e895d', int64), 0.0_real64), &
                     transfer(int(z'3e9b3d41e27cd9f2', int64), 0.0_real64), transfer(int(z'3e9c2dcf54fbba45', int64), 0.0_real64), &
                     transfer(int(z'3e9d2502d2be2cb2', int64), 0.0_real64), transfer(int(z'3e9e22fb2510d34a', int64), 0.0_real64), &
                     transfer(int(z'3e9f27d71540501d', int64), 0.0_real64), transfer(int(z'3ea019e14f26330f', int64), 0.0_real64), &
                     transfer(int(z'3ea0a36e44c0dbae', int64), 0.0_real64), transfer(int(z'3ea1309f9d2342ce', int64), 0.0_real64), &
                     transfer(int(z'3ea1c18d88c07a10', int64), 0.0_real64), transfer(int(z'3ea256476c3ed27a', int64), 0.0_real64), &
                     transfer(int(z'3ea2eededf37cd3b', int64), 0.0_real64), transfer(int(z'3ea38b67ac381ba6', int64), 0.0_real64), &
                     transfer(int(z'3ea42bf59dcc6f0f', int64), 0.0_real64), transfer(int(z'3ea4d095e5a7e858', int64), 0.0_real64), &
                     transfer(int(z'3ea57960b43d9921', int64), 0.0_real64), transfer(int(z'3ea62667a1270298', int64), 0.0_real64), &
                     transfer(int(z'3ea6d7be76f0d610', int64), 0.0_real64), transfer(int(z'3ea78d76cd3494b6', int64), 0.0_real64), &
                     transfer(int(z'3ea847a46e7eefe0', int64), 0.0_real64), transfer(int(z'3ea9065f8b42f92b', int64), 0.0_real64), &
                     transfer(int(z'3ea9c9b32240a155', int64), 0.0_real64), transfer(int(z'3eaa91bbc9d15a47', int64), 0.0_real64), &
                     transfer(int(z'3eab5e8b198ea531', int64), 0.0_real64), transfer(int(z'3eac3032a9120340', int64), 0.0_real64), &
                     transfer(int(z'3ead06caa8ce8613', int64), 0.0_real64), transfer(int(z'3eade264b05daed8', int64), 0.0_real64), &
                     transfer(int(z'3eaec31b2325bf54', int64), 0.0_real64), transfer(int(z'3eafa8fb32d9d869', int64), 0.0_real64), &
                     transfer(int(z'3eb04a0e87f685db', int64), 0.0_real64), transfer(int(z'3eb0c24b5bef9d5b', int64), 0.0_real64), &
                     transfer(int(z'3eb13d402d91bb83', int64), 0.0_real64), transfer(int(z'3eb1baf6e22338fe', int64), 0.0_real64), &
                     transfer(int(z'3eb23b784570d662', int64), 0.0_real64), transfer(int(z'3eb2becf563a846b', int64), 0.0_real64), &
                     transfer(int(z'3eb34507134033d8', int64), 0.0_real64), transfer(int(z'3eb3ce357a01c620', int64), 0.0_real64), &
                     transfer(int(z'3eb45a4f8bbf4a88', int64), 0.0_real64), transfer(int(z'3eb4e97644b89345', int64), 0.0_real64), &
                             transfer(int(z'3eb57ba9a4eda058', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_14(181) = [ &
                     transfer(int(z'3daecfa9227adce8', int64), 0.0_real64), transfer(int(z'3db185876835b6cf', int64), 0.0_real64), &
                     transfer(int(z'3db3e59238c20254', int64), 0.0_real64), transfer(int(z'3db68f0cdcd5af4f', int64), 0.0_real64), &
                     transfer(int(z'3db989b4e9e70525', int64), 0.0_real64), transfer(int(z'3dbcde034ef5263e', int64), 0.0_real64), &
                     transfer(int(z'3dc04a8b5b410f0f', int64), 0.0_real64), transfer(int(z'3dc25c7dcaa8ae80', int64), 0.0_real64), &
                     transfer(int(z'3dc4aa4411843d08', int64), 0.0_real64), transfer(int(z'3dc739b8fc1a92a3', int64), 0.0_real64), &
                     transfer(int(z'3dca1143d9d92b8d', int64), 0.0_real64), transfer(int(z'3dcd37b8104b3d6d', int64), 0.0_real64), &
                     transfer(int(z'3dd05a4593144a06', int64), 0.0_real64), transfer(int(z'3dd247e6c75475b1', int64), 0.0_real64), &
                     transfer(int(z'3dd46908b893d558', int64), 0.0_real64), transfer(int(z'3dd6c25b291c5991', int64), 0.0_real64), &
                     transfer(int(z'3dd958db5177eb07', int64), 0.0_real64), transfer(int(z'3ddc31eee5f7d8d7', int64), 0.0_real64), &
                     transfer(int(z'3ddf534ade5893b0', int64), 0.0_real64), transfer(int(z'3de161a07600d2f6', int64), 0.0_real64), &
                     transfer(int(z'3de3442e32dfe4cb', int64), 0.0_real64), transfer(int(z'3de554d35e168884', int64), 0.0_real64), &
                     transfer(int(z'3de7976ec25fe1d7', int64), 0.0_real64), transfer(int(z'3dea100331d65244', int64), 0.0_real64), &
                     transfer(int(z'3decc2db8d52b6ec', int64), 0.0_real64), transfer(int(z'3defb4a5c9f3d6e6', int64), 0.0_real64), &
                     transfer(int(z'3df1751e7307c346', int64), 0.0_real64), transfer(int(z'3df3346f7a20c219', int64), 0.0_real64), &
                     transfer(int(z'3df51b0d8bddec9d', int64), 0.0_real64), transfer(int(z'3df72be8c2236d0d', int64), 0.0_real64), &
                     transfer(int(z'3df96a2bc2d03212', int64), 0.0_real64), transfer(int(z'3dfbd91c394a98b3', int64), 0.0_real64), &
                     transfer(int(z'3dfe7c4c60a3614a', int64), 0.0_real64), transfer(int(z'3e00abb6fd2f5125', int64), 0.0_real64), &
                     transfer(int(z'3e02373d6b5f76e0', int64), 0.0_real64), transfer(int(z'3e03e2c866b309c6', int64), 0.0_real64), &
                     transfer(int(z'3e05b093e431ff06', int64), 0.0_real64), transfer(int(z'3e07a2eb9c1df6dc', int64), 0.0_real64), &
                     transfer(int(z'3e09bc4a906592a4', int64), 0.0_real64), transfer(int(z'3e0bff448808ee35', int64), 0.0_real64), &
                     transfer(int(z'3e0e6e95d2534af1', int64), 0.0_real64), transfer(int(z'3e10868ae20bac4a', int64), 0.0_real64), &
                     transfer(int(z'3e11eee69e255deb', int64), 0.0_real64), transfer(int(z'3e1371f9118d1359', int64), 0.0_real64), &
                     transfer(int(z'3e15115e50941f80', int64), 0.0_real64), transfer(int(z'3e16cee3f9aeca47', int64), 0.0_real64), &
                     transfer(int(z'3e18ac57ab515b98', int64), 0.0_real64), transfer(int(z'3e1aaba8cad9654b', int64), 0.0_real64), &
                     transfer(int(z'3e1ccee8848dc32c', int64), 0.0_real64), transfer(int(z'3e1f181cc2678db7', int64), 0.0_real64), &
                     transfer(int(z'3e20c4c1dcf256fc', int64), 0.0_real64), transfer(int(z'3e2212b9128f49cf', int64), 0.0_real64), &
                     transfer(int(z'3e237724003e38d5', int64), 0.0_real64), transfer(int(z'3e24f34ec9f525d8', int64), 0.0_real64), &
                     transfer(int(z'3e26887ff28330f7', int64), 0.0_real64), transfer(int(z'3e28381fc3a0c446', int64), 0.0_real64), &
                     transfer(int(z'3e2a039c282d2b7f', int64), 0.0_real64), transfer(int(z'3e2bec6e4d5575af', int64), 0.0_real64), &
                     transfer(int(z'3e2df425e4e23882', int64), 0.0_real64), transfer(int(z'3e300e31c208574f', int64), 0.0_real64), &
                     transfer(int(z'3e31336f225ccca4', int64), 0.0_real64), transfer(int(z'3e326aa3cfc76c11', int64), 0.0_real64), &
                     transfer(int(z'3e33b4c4ac638dad', int64), 0.0_real64), transfer(int(z'3e3512b8876b556e', int64), 0.0_real64), &
                     transfer(int(z'3e368585266ec063', int64), 0.0_real64), transfer(int(z'3e380e27dd437923', int64), 0.0_real64), &
                     transfer(int(z'3e39adb4845ab0e4', int64), 0.0_real64), transfer(int(z'3e3b654765dfeb59', int64), 0.0_real64), &
                     transfer(int(z'3e3d35ff9c921d08', int64), 0.0_real64), transfer(int(z'3e3f210ff7385046', int64), 0.0_real64), &
                     transfer(int(z'3e4093d70a96801d', int64), 0.0_real64), transfer(int(z'3e41a5903c9fa683', int64), 0.0_real64), &
                     transfer(int(z'3e42c65b0bfc54a3', int64), 0.0_real64), transfer(int(z'3e43f6e494182575', int64), 0.0_real64), &
                     transfer(int(z'3e4537e26219066c', int64), 0.0_real64), transfer(int(z'3e468a0461fe0353', int64), 0.0_real64), &
                     transfer(int(z'3e47ee2620b37ccd', int64), 0.0_real64), transfer(int(z'3e4964eadfa102ec', int64), 0.0_real64), &
                     transfer(int(z'3e4aef25b9f8a3d5', int64), 0.0_real64), transfer(int(z'3e4c8dc5f0aed5fa', int64), 0.0_real64), &
                     transfer(int(z'3e4e418279333f37', int64), 0.0_real64), transfer(int(z'3e5005a54a3d2aff', int64), 0.0_real64), &
                     transfer(int(z'3e50f5ffb84bae4d', int64), 0.0_real64), transfer(int(z'3e51f24f30affed0', int64), 0.0_real64), &
                     transfer(int(z'3e52fb0b53e457c0', int64), 0.0_real64), transfer(int(z'3e5410a4b8f25a44', int64), 0.0_real64), &
                     transfer(int(z'3e5533af2616a9dc', int64), 0.0_real64), transfer(int(z'3e5664a9453c1bd4', int64), 0.0_real64), &
                     transfer(int(z'3e57a41fd32eb99a', int64), 0.0_real64), transfer(int(z'3e58f29179d9587a', int64), 0.0_real64), &
                     transfer(int(z'3e5a50a01259d01a', int64), 0.0_real64), transfer(int(z'3e5bbedf62ecc3fb', int64), 0.0_real64), &
                     transfer(int(z'3e5d3ddc285e3d8d', int64), 0.0_real64), transfer(int(z'3e5ece3f453cae88', int64), 0.0_real64), &
                     transfer(int(z'3e6038554952f749', int64), 0.0_real64), transfer(int(z'3e6112d8eb6b5098', int64), 0.0_real64), &
                     transfer(int(z'3e61f70988578327', int64), 0.0_real64), transfer(int(z'3e62e5380ca67aca', int64), 0.0_real64), &
                     transfer(int(z'3e63ddbff3100a70', int64), 0.0_real64), transfer(int(z'3e64e0fcb64c0507', int64), 0.0_real64), &
                     transfer(int(z'3e65ef50da82d791', int64), 0.0_real64), transfer(int(z'3e670910d0fbbae9', int64), 0.0_real64), &
                     transfer(int(z'3e682ea6274fb625', int64), 0.0_real64), transfer(int(z'3e69606fdceee93a', int64), 0.0_real64), &
                     transfer(int(z'3e6a9ede88e2f550', int64), 0.0_real64), transfer(int(z'3e6bea512a9bfa5e', int64), 0.0_real64), &
                     transfer(int(z'3e6d43385923998a', int64), 0.0_real64), transfer(int(z'3e6ea9fa1d5a8cde', int64), 0.0_real64), &
                     transfer(int(z'3e700f8c52f1fb57', int64), 0.0_real64), transfer(int(z'3e70d1797917fb7a', int64), 0.0_real64), &
                     transfer(int(z'3e719b03d614b17b', int64), 0.0_real64), transfer(int(z'3e726c673a253af8', int64), 0.0_real64), &
                     transfer(int(z'3e7345dbf0ce6883', int64), 0.0_real64), transfer(int(z'3e7427a858763ed5', int64), 0.0_real64), &
                     transfer(int(z'3e751204bca18e7f', int64), 0.0_real64), transfer(int(z'3e7605377bb65c3a', int64), 0.0_real64), &
                     transfer(int(z'3e77017feaaa12aa', int64), 0.0_real64), transfer(int(z'3e78071d5e721c76', int64), 0.0_real64), &
                     transfer(int(z'3e791660c39d6570', int64), 0.0_real64), transfer(int(z'3e7a2f80a35497a7', int64), 0.0_real64), &
                     transfer(int(z'3e7b52d16edeebf7', int64), 0.0_real64), transfer(int(z'3e7c8090b8d5a681', int64), 0.0_real64), &
                     transfer(int(z'3e7db919fbf09a33', int64), 0.0_real64), transfer(int(z'3e7efc906762c96a', int64), 0.0_real64), &
                     transfer(int(z'3e8025b7902f5e33', int64), 0.0_real64), transfer(int(z'3e80d2fe42a53bf0', int64), 0.0_real64), &
                     transfer(int(z'3e818636ae793fb1', int64), 0.0_real64), transfer(int(z'3e823f959a77ecff', int64), 0.0_real64), &
                     transfer(int(z'3e82ff3e35d44636', int64), 0.0_real64), transfer(int(z'3e83c553afc14db2', int64), 0.0_real64), &
                     transfer(int(z'3e8492139ad84793', int64), 0.0_real64), transfer(int(z'3e8565985a7f75a0', int64), 0.0_real64), &
                     transfer(int(z'3e864016b5835b60', int64), 0.0_real64), transfer(int(z'3e8721baa6e3bbc8', int64), 0.0_real64), &
                     transfer(int(z'3e880aa75dd39933', int64), 0.0_real64), transfer(int(z'3e88fb1a6cec37c1', int64), 0.0_real64), &
                     transfer(int(z'3e89f337036099cf', int64), 0.0_real64), transfer(int(z'3e8af3291c30824e', int64), 0.0_real64), &
                     transfer(int(z'3e8bfb2e49f53561', int64), 0.0_real64), transfer(int(z'3e8d0b7287ae75fa', int64), 0.0_real64), &
                     transfer(int(z'3e8e2419048f4674', int64), 0.0_real64), transfer(int(z'3e8f45681efdab87', int64), 0.0_real64), &
                     transfer(int(z'3e9037ca4ee3145f', int64), 0.0_real64), transfer(int(z'3e90d15c72277fee', int64), 0.0_real64), &
                     transfer(int(z'3e916f8da87f1acd', int64), 0.0_real64), transfer(int(z'3e92127cbb36870b', int64), 0.0_real64), &
                     transfer(int(z'3e92ba36dc00e58d', int64), 0.0_real64), transfer(int(z'3e9366e39ff798f8', int64), 0.0_real64), &
                     transfer(int(z'3e941899049a82c6', int64), 0.0_real64), transfer(int(z'3e94cf75d3364508', int64), 0.0_real64), &
                     transfer(int(z'3e958b946f312183', int64), 0.0_real64), transfer(int(z'3e964d0f3bf159fb', int64), 0.0_real64), &
                     transfer(int(z'3e97140968a9f0cc', int64), 0.0_real64), transfer(int(z'3e97e09d58c127bb', int64), 0.0_real64), &
                     transfer(int(z'3e98b2e56f9d408c', int64), 0.0_real64), transfer(int(z'3e998b04dc713d9d', int64), 0.0_real64), &
                     transfer(int(z'3e9a691602a360b1', int64), 0.0_real64), transfer(int(z'3e9b4d37ab804bd9', int64), 0.0_real64), &
                     transfer(int(z'3e9c3788a054a125', int64), 0.0_real64), transfer(int(z'3e9d28307639c33d', int64), 0.0_real64), &
                     transfer(int(z'3e9e1f499095f3e6', int64), 0.0_real64), transfer(int(z'3e9f1cee52cf74e4', int64), 0.0_real64), &
                     transfer(int(z'3ea010a328ffd46f', int64), 0.0_real64), transfer(int(z'3ea096382bb998f3', int64), 0.0_real64), &
                     transfer(int(z'3ea11f45963b5905', int64), 0.0_real64), transfer(int(z'3ea1abdf3311c5fa', int64), 0.0_real64), &
                     transfer(int(z'3ea23c1466e330d9', int64), 0.0_real64), transfer(int(z'3ea2cff6c9491ad1', int64), 0.0_real64), &
                     transfer(int(z'3ea367938bf6a4c3', int64), 0.0_real64), transfer(int(z'3ea40302df5ee050', int64), 0.0_real64), &
                     transfer(int(z'3ea4a251f534ee58', int64), 0.0_real64), transfer(int(z'3ea5459498058031', int64), 0.0_real64), &
                     transfer(int(z'3ea5ecd7f983b6bd', int64), 0.0_real64), transfer(int(z'3ea698344a22a39a', int64), 0.0_real64), &
                     transfer(int(z'3ea747b8ee8897d1', int64), 0.0_real64), transfer(int(z'3ea7fb7e1728a501', int64), 0.0_real64), &
                     transfer(int(z'3ea8b38a5cdc5b9b', int64), 0.0_real64), transfer(int(z'3ea96ffc88f05daf', int64), 0.0_real64), &
                     transfer(int(z'3eaa30dd67316bd5', int64), 0.0_real64), transfer(int(z'3eaaf64bc0ec281d', int64), 0.0_real64), &
                             transfer(int(z'3eabc04e2efa22f8', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_15(181) = [ &
                     transfer(int(z'3d912c729ea5372b', int64), 0.0_real64), transfer(int(z'3d93b40533ee5d5f', int64), 0.0_real64), &
                     transfer(int(z'3d96913d7880ebe9', int64), 0.0_real64), transfer(int(z'3d99ce1806d7b2b7', int64), 0.0_real64), &
                     transfer(int(z'3d9d759aa57229e6', int64), 0.0_real64), transfer(int(z'3da0c9efe7278a71', int64), 0.0_real64), &
                     transfer(int(z'3da31b184fe038be', int64), 0.0_real64), transfer(int(z'3da5b58f669fb37a', int64), 0.0_real64), &
                     transfer(int(z'3da8a15229fec34f', int64), 0.0_real64), transfer(int(z'3dabe6fd905bc872', int64), 0.0_real64), &
                     transfer(int(z'3daf903ef0c6713d', int64), 0.0_real64), transfer(int(z'3db1d3aa985d5bd4', int64), 0.0_real64), &
                     transfer(int(z'3db41bd6ed03e808', int64), 0.0_real64), transfer(int(z'3db6a6b8e802e4e6', int64), 0.0_real64), &
                     transfer(int(z'3db97b0ab6894339', int64), 0.0_real64), transfer(int(z'3dbca001053cf924', int64), 0.0_real64), &
                     transfer(int(z'3dc00ec252d018e9', int64), 0.0_real64), transfer(int(z'3dc1fe03a902b4da', int64), 0.0_real64), &
                     transfer(int(z'3dc42265de26f50d', int64), 0.0_real64), transfer(int(z'3dc680dd28eef2bb', int64), 0.0_real64), &
                     transfer(int(z'3dc91ec9d62a8087', int64), 0.0_real64), transfer(int(z'3dcc01f1141a848c', int64), 0.0_real64), &
                     transfer(int(z'3dcf30929076ea39', int64), 0.0_real64), transfer(int(z'3dd158ab3a5f81ba', int64), 0.0_real64), &
                     transfer(int(z'3dd345be1e4ddfa7', int64), 0.0_real64), transfer(int(z'3dd5635d246b5f9d', int64), 0.0_real64), &
                     transfer(int(z'3dd7b5af2631a0ec', int64), 0.0_real64), transfer(int(z'3dda41213ead9505', int64), 0.0_real64), &
                     transfer(int(z'3ddd0a8737886a4c', int64), 0.0_real64), transfer(int(z'3de00b6c70e5467a', int64), 0.0_real64), &
                     transfer(int(z'3de1b5c9ae7b33bc', int64), 0.0_real64), transfer(int(z'3de3874fef560ee1', int64), 0.0_real64), &
                     transfer(int(z'3de58305d1f588c5', int64), 0.0_real64), transfer(int(z'3de7ac43056f9d52', int64), 0.0_real64), &
                     transfer(int(z'3dea068c421155b9', int64), 0.0_real64), transfer(int(z'3dec9593495ec86b', int64), 0.0_real64), &
                     transfer(int(z'3def5d63ef4a265d', int64), 0.0_real64), transfer(int(z'3df1311707926f2a', int64), 0.0_real64), &
                     transfer(int(z'3df2d43dcb573ccc', int64), 0.0_real64), transfer(int(z'3df49a7d3d82dfa2', int64), 0.0_real64), &
                     transfer(int(z'3df68666e49f7fa6', int64), 0.0_real64), transfer(int(z'3df89a99c9fafc02', int64), 0.0_real64), &
                     transfer(int(z'3dfad9f403c9e009', int64), 0.0_real64), transfer(int(z'3dfd47732eb40d23', int64), 0.0_real64), &
                     transfer(int(z'3dffe638eec0a286', int64), 0.0_real64), transfer(int(z'3e015cd0b9f8c1ed', int64), 0.0_real64), &
                     transfer(int(z'3e02e29afbbfd102', int64), 0.0_real64), transfer(int(z'3e048651dd0195df', int64), 0.0_real64), &
                     transfer(int(z'3e0649edc4f371d1', int64), 0.0_real64), transfer(int(z'3e082f7d9f664cc8', int64), 0.0_real64), &
                     transfer(int(z'3e0a392fde9e64c5', int64), 0.0_real64), transfer(int(z'3e0c694739058a91', int64), 0.0_real64), &
                     transfer(int(z'3e0ec2312dc6a859', int64), 0.0_real64), transfer(int(z'3e10a3333f2d35cd', int64), 0.0_real64), &
                     transfer(int(z'3e11fc509ccb10ed', int64), 0.0_real64), transfer(int(z'3e136dcb76b19871', int64), 0.0_real64), &
                     transfer(int(z'3e14f91758e6f9bd', int64), 0.0_real64), transfer(int(z'3e169fbe540ce8d4', int64), 0.0_real64), &
                     transfer(int(z'3e186355bb12dd0d', int64), 0.0_real64), transfer(int(z'3e1a4594a7d197ad', int64), 0.0_real64), &
                     transfer(int(z'3e1c48323421d9fc', int64), 0.0_real64), transfer(int(z'3e1e6cfbfe77ebe2', int64), 0.0_real64), &
                     transfer(int(z'3e205af6573f9144', int64), 0.0_real64), transfer(int(z'3e219279d4ca87e5', int64), 0.0_real64), &
                     transfer(int(z'3e22de16af272961', int64), 0.0_real64), transfer(int(z'3e243ee0bec6a6ef', int64), 0.0_real64), &
                     transfer(int(z'3e25b60260b5b866', int64), 0.0_real64), transfer(int(z'3e27449aafb3524e', int64), 0.0_real64), &
                     transfer(int(z'3e28ebf5cfb5766e', int64), 0.0_real64), transfer(int(z'3e2aad4960169ff1', int64), 0.0_real64), &
                     transfer(int(z'3e2c89fdaa8f38e7', int64), 0.0_real64), transfer(int(z'3e2e836a1563066c', int64), 0.0_real64), &
                     transfer(int(z'3e304d81164c1af1', int64), 0.0_real64), transfer(int(z'3e3169252fd4ccd3', int64), 0.0_real64), &
                     transfer(int(z'3e3295638f09020a', int64), 0.0_real64), transfer(int(z'3e33d30f4f1ac8bc', int64), 0.0_real64), &
                     transfer(int(z'3e3523012c6310ba', int64), 0.0_real64), transfer(int(z'3e36860f12a758fe', int64), 0.0_real64), &
                     transfer(int(z'3e37fd2b136f88cd', int64), 0.0_real64), transfer(int(z'3e39893bfdf5c41b', int64), 0.0_real64), &
                     transfer(int(z'3e3b2b3c557c44a9', int64), 0.0_real64), transfer(int(z'3e3ce42c3e6c25df', int64), 0.0_real64), &
                     transfer(int(z'3e3eb51cc0a32821', int64), 0.0_real64), transfer(int(z'3e404f89d0d8a440', int64), 0.0_real64), &
                     transfer(int(z'3e41519d9f519f6a', int64), 0.0_real64), transfer(int(z'3e426157f0d24767', int64), 0.0_real64), &
                     transfer(int(z'3e437f522cbe2162', int64), 0.0_real64), transfer(int(z'3e44ac288b0c2359', int64), 0.0_real64), &
                     transfer(int(z'3e45e87fb56d95c6', int64), 0.0_real64), transfer(int(z'3e4734fdbddd798e', int64), 0.0_real64), &
                     transfer(int(z'3e48924e577db13e', int64), 0.0_real64), transfer(int(z'3e4a011a64dcae8e', int64), 0.0_real64), &
                     transfer(int(z'3e4b8235012c7fa6', int64), 0.0_real64), transfer(int(z'3e4d1638fc1a6219', int64), 0.0_real64), &
                     transfer(int(z'3e4ebe0783b99834', int64), 0.0_real64), transfer(int(z'3e503d2bc6bce3ea', int64), 0.0_real64), &
                     transfer(int(z'3e51260523b719a2', int64), 0.0_real64), transfer(int(z'3e5219eb53834031', int64), 0.0_real64), &
                     transfer(int(z'3e531955f69b92cf', int64), 0.0_real64), transfer(int(z'3e5424ae9a991890', int64), 0.0_real64), &
                     transfer(int(z'3e553c73e966a6bf', int64), 0.0_real64), transfer(int(z'3e5661167a0dde80', int64), 0.0_real64), &
                     transfer(int(z'3e579314f6799520', int64), 0.0_real64), transfer(int(z'3e58d2e6ff2405d5', int64), 0.0_real64), &
                     transfer(int(z'3e5a211950d93a10', int64), 0.0_real64), transfer(int(z'3e5b7e1c82a2d2f5', int64), 0.0_real64), &
                     transfer(int(z'3e5cea845abd7408', int64), 0.0_real64), transfer(int(z'3e5e66e49f65c0c9', int64), 0.0_real64), &
                     transfer(int(z'3e5ff3c303f72895', int64), 0.0_real64), transfer(int(z'3e60c8d6229eda6e', int64), 0.0_real64), &
                     transfer(int(z'3e61a0a11e2b9ea2', int64), 0.0_real64), transfer(int(z'3e62818c57c032a8', int64), 0.0_real64), &
                     transfer(int(z'3e636bec40a3cf5b', int64), 0.0_real64), transfer(int(z'3e646007373c7974', int64), 0.0_real64), &
                     transfer(int(z'3e655e3c3afa50ea', int64), 0.0_real64), transfer(int(z'3e6666d8b3b3f488', int64), 0.0_real64), &
                     transfer(int(z'3e677a349768ea33', int64), 0.0_real64), transfer(int(z'3e6898ab60d104d9', int64), 0.0_real64), &
                     transfer(int(z'3e69c29505ebca61', int64), 0.0_real64), transfer(int(z'3e6af85086295ac2', int64), 0.0_real64), &
                     transfer(int(z'3e6c3a395c4188eb', int64), 0.0_real64), transfer(int(z'3e6d88b591150ee6', int64), 0.0_real64), &
                     transfer(int(z'3e6ee42424140cac', int64), 0.0_real64), transfer(int(z'3e702677516bc4a8', int64), 0.0_real64), &
                     transfer(int(z'3e70e1bd8b201f6d', int64), 0.0_real64), transfer(int(z'3e71a416013b4d28', int64), 0.0_real64), &
                     transfer(int(z'3e726dbc83fa6b73', int64), 0.0_real64), transfer(int(z'3e733ee79c86245d', int64), 0.0_real64), &
                     transfer(int(z'3e7417ca4f4ed4eb', int64), 0.0_real64), transfer(int(z'3e74f8a22eedc13e', int64), 0.0_real64), &
                     transfer(int(z'3e75e1a786e7b9e9', int64), 0.0_real64), transfer(int(z'3e76d317e9d6030c', int64), 0.0_real64), &
                     transfer(int(z'3e77cd2f27f5ba44', int64), 0.0_real64), transfer(int(z'3e78d02ad3e023b2', int64), 0.0_real64), &
                     transfer(int(z'3e79dc4c04e6d07e', int64), 0.0_real64), transfer(int(z'3e7af1c944326ab8', int64), 0.0_real64), &
                     transfer(int(z'3e7c10f7030a2b3c', int64), 0.0_real64), transfer(int(z'3e7d3a0a083a9594', int64), 0.0_real64), &
                     transfer(int(z'3e7e6d48b229ae77', int64), 0.0_real64), transfer(int(z'3e7faaf95f3d7a9d', int64), 0.0_real64), &
                     transfer(int(z'3e8079b136edff5f', int64), 0.0_real64), transfer(int(z'3e8123651e359fc8', int64), 0.0_real64), &
                     transfer(int(z'3e81d2bb94a8a0e6', int64), 0.0_real64), transfer(int(z'3e8287d7c97a0516', int64), 0.0_real64), &
                     transfer(int(z'3e8342e5b7a98f48', int64), 0.0_real64), transfer(int(z'3e8404088e6a41db', int64), 0.0_real64), &
                     transfer(int(z'3e84cb637cef1f28', int64), 0.0_real64), transfer(int(z'3e85992b4a04aaba', int64), 0.0_real64), &
                     transfer(int(z'3e866d7a59112657', int64), 0.0_real64), transfer(int(z'3e87487ca51454f0', int64), 0.0_real64), &
                     transfer(int(z'3e882a555d4138e1', int64), 0.0_real64), transfer(int(z'3e8913421431164c', int64), 0.0_real64), &
                     transfer(int(z'3e8a0354617d6e5d', int64), 0.0_real64), transfer(int(z'3e8afac9d7bf8537', int64), 0.0_real64), &
                     transfer(int(z'3e8bf9ce71f71dcb', int64), 0.0_real64), transfer(int(z'3e8d00855f573a75', int64), 0.0_real64), &
                     transfer(int(z'3e8e0f1a9adf9e29', int64), 0.0_real64), transfer(int(z'3e8f25c2eb5ccc70', int64), 0.0_real64), &
                     transfer(int(z'3e9022598bcda469', int64), 0.0_real64), transfer(int(z'3e90b602c180aa8c', int64), 0.0_real64), &
                     transfer(int(z'3e914e0045fa7afb', int64), 0.0_real64), transfer(int(z'3e91ea63b0d496e4', int64), 0.0_real64), &
                     transfer(int(z'3e928b476575400d', int64), 0.0_real64), transfer(int(z'3e9330c5c742b83a', int64), 0.0_real64), &
                     transfer(int(z'3e93daf939a34131', int64), 0.0_real64), transfer(int(z'3e9489f354305c1e', int64), 0.0_real64), &
                     transfer(int(z'3e953dd7461d0b5e', int64), 0.0_real64), transfer(int(z'3e95f6bb0ce9306b', int64), 0.0_real64), &
                     transfer(int(z'3e96b4b90bfb0d08', int64), 0.0_real64), transfer(int(z'3e9777eba6b8e2fc', int64), 0.0_real64), &
                     transfer(int(z'3e984071a66f5456', int64), 0.0_real64), transfer(int(z'3e990e656e84a2db', int64), 0.0_real64), &
                     transfer(int(z'3e99e1dcfc78b005', int64), 0.0_real64), transfer(int(z'3e9abaffe564de7b', int64), 0.0_real64), &
                     transfer(int(z'3e9b99db5afc4f1f', int64), 0.0_real64), transfer(int(z'3e9c7e9b583ec4e4', int64), 0.0_real64), &
                     transfer(int(z'3e9d6955daac2144', int64), 0.0_real64), transfer(int(z'3e9e5a29ab91064f', int64), 0.0_real64), &
                     transfer(int(z'3e9f51312e53b5c9', int64), 0.0_real64), transfer(int(z'3ea02747c9139908', int64), 0.0_real64), &
                             transfer(int(z'3ea0a934031f3ebf', int64), 0.0_real64)]
  real(real64), parameter :: totplnk_column_16(181) = [ &
                     transfer(int(z'3d542724c241dbc1', int64), 0.0_real64), transfer(int(z'3d57779f2b97d217', int64), 0.0_real64), &
                     transfer(int(z'3d5b4719f7dada8d', int64), 0.0_real64), transfer(int(z'3d5fa65605400498', int64), 0.0_real64), &
                     transfer(int(z'3d62541ecc7d7b29', int64), 0.0_real64), transfer(int(z'3d6531204d8982cb', int64), 0.0_real64), &
                     transfer(int(z'3d6875fc2d470f71', int64), 0.0_real64), transfer(int(z'3d6c2fc1e4a2ef38', int64), 0.0_real64), &
                     transfer(int(z'3d7036a70bd9b6e4', int64), 0.0_real64), transfer(int(z'3d729f82b46c40be', int64), 0.0_real64), &
                     transfer(int(z'3d755aeb6a18e32c', int64), 0.0_real64), transfer(int(z'3d78738d9968a5f8', int64), 0.0_real64), &
                     transfer(int(z'3d7bf43845547a55', int64), 0.0_real64), transfer(int(z'3d7fe8a1066a103b', int64), 0.0_real64), &
                     transfer(int(z'3d822f5ef5957a46', int64), 0.0_real64), transfer(int(z'3d84b2b5cbd6b979', int64), 0.0_real64), &
                     transfer(int(z'3d878636a2ce4aea', int64), 0.0_real64), transfer(int(z'3d8ab2a9ace67294', int64), 0.0_real64), &
                     transfer(int(z'3d8e426aa24dc249', int64), 0.0_real64), transfer(int(z'3d911fcdcae6ce15', int64), 0.0_real64), &
                     transfer(int(z'3d935b32b55f07c7', int64), 0.0_real64), transfer(int(z'3d95d99554ee2dc2', int64), 0.0_real64), &
                     transfer(int(z'3d98a22a563a3627', int64), 0.0_real64), transfer(int(z'3d9bbc7cde00dea3', int64), 0.0_real64), &
                     transfer(int(z'3d9f30c5012f73f4', int64), 0.0_real64), transfer(int(z'3da1841f1e7d4cbc', int64), 0.0_real64), &
                     transfer(int(z'3da3a65a1609f4e2', int64), 0.0_real64), transfer(int(z'3da604414354fb56', int64), 0.0_real64), &
                     transfer(int(z'3da8a3daaeb11bd7', int64), 0.0_real64), transfer(int(z'3dab8b82d888d9b1', int64), 0.0_real64), &
                     transfer(int(z'3daec16b053ad468', int64), 0.0_real64), transfer(int(z'3db12702778cc437', int64), 0.0_real64), &
                     transfer(int(z'3db31c08fc004641', int64), 0.0_real64), transfer(int(z'3db54449fbdfaa28', int64), 0.0_real64), &
                     transfer(int(z'3db7a48e71d1255f', int64), 0.0_real64), transfer(int(z'3dba41e7673968f6', int64), 0.0_real64), &
                     transfer(int(z'3dbd2165e57d25fc', int64), 0.0_real64), transfer(int(z'3dc0245589bf025f', int64), 0.0_real64), &
                     transfer(int(z'3dc1df3c298bcdfd', int64), 0.0_real64), transfer(int(z'3dc3c4a37bb3836b', int64), 0.0_real64), &
                     transfer(int(z'3dc5d7ec3123ee08', int64), 0.0_real64), transfer(int(z'3dc81d2b1fa70e3d', int64), 0.0_real64), &
                     transfer(int(z'3dca985115a7a6a7', int64), 0.0_real64), transfer(int(z'3dcd4dbaf7ae334a', int64), 0.0_real64), &
                     transfer(int(z'3dd0212ae3e013b5', int64), 0.0_real64), transfer(int(z'3dd1bd8743f17b23', int64), 0.0_real64), &
                     transfer(int(z'3dd37e8d246d4760', int64), 0.0_real64), transfer(int(z'3dd5673120238a5f', int64), 0.0_real64), &
                     transfer(int(z'3dd77a67d1e45615', int64), 0.0_real64), transfer(int(z'3dd9bb91ea9d75e1', int64), 0.0_real64), &
                     transfer(int(z'3ddc2e34229bf2f2', int64), 0.0_real64), transfer(int(z'3dded54314afdf3d', int64), 0.0_real64), &
                     transfer(int(z'3de0db02eaa66444', int64), 0.0_real64), transfer(int(z'3de269a67bf1c17c', int64), 0.0_real64), &
                     transfer(int(z'3de4195cd1aadb6c', int64), 0.0_real64), transfer(int(z'3de5ebe847f836ab', int64), 0.0_real64), &
                     transfer(int(z'3de7e419724aa760', int64), 0.0_real64), transfer(int(z'3dea0466d1a4e72a', int64), 0.0_real64), &
                     transfer(int(z'3dec4fa0f977ca2f', int64), 0.0_real64), transfer(int(z'3deec8f28fa23f19', int64), 0.0_real64), &
                     transfer(int(z'3df0b9c31d019a4a', int64), 0.0_real64), transfer(int(z'3df229164605bf61', int64), 0.0_real64), &
                     transfer(int(z'3df3b462283b20ac', int64), 0.0_real64), transfer(int(z'3df55d691fc842c3', int64), 0.0_real64), &
                     transfer(int(z'3df7261a920ab780', int64), 0.0_real64), transfer(int(z'3df91092ed971dfe', int64), 0.0_real64), &
                     transfer(int(z'3dfb1eeea1021559', int64), 0.0_real64), transfer(int(z'3dfd53a42d4e5732', int64), 0.0_real64), &
                     transfer(int(z'3dffb0a2f7d97564', int64), 0.0_real64), transfer(int(z'3e011c744ea5a8ab', int64), 0.0_real64), &
                     transfer(int(z'3e02775f4ab7cbb2', int64), 0.0_real64), transfer(int(z'3e03ea913e77147d', int64), 0.0_real64), &
                     transfer(int(z'3e057772739bed1e', int64), 0.0_real64), transfer(int(z'3e071f983d15cce9', int64), 0.0_real64), &
                     transfer(int(z'3e08e497edd42b34', int64), 0.0_real64), transfer(int(z'3e0ac81d5d6205f6', int64), 0.0_real64), &
                     transfer(int(z'3e0ccbeae7e5e1c5', int64), 0.0_real64), transfer(int(z'3e0ef1eff2bd507b', int64), 0.0_real64), &
                     transfer(int(z'3e109e02af552ea8', int64), 0.0_real64), transfer(int(z'3e11d60d48854d10', int64), 0.0_real64), &
                     transfer(int(z'3e13228b50f530d8', int64), 0.0_real64), transfer(int(z'3e1483b51429aa93', int64), 0.0_real64), &
                     transfer(int(z'3e15fbbd8552dffe', int64), 0.0_real64), transfer(int(z'3e178b153b7a723f', int64), 0.0_real64), &
                     transfer(int(z'3e19337e92c6e5ee', int64), 0.0_real64), transfer(int(z'3e1af64b50551e7c', int64), 0.0_real64), &
                     transfer(int(z'3e1cd45ca2385e35', int64), 0.0_real64), transfer(int(z'3e1ecf74e49729b0', int64), 0.0_real64), &
                     transfer(int(z'3e2074ab39cc02c2', int64), 0.0_real64), transfer(int(z'3e2191a98a2bea92', int64), 0.0_real64), &
                     transfer(int(z'3e22bf5e45f9be00', int64), 0.0_real64), transfer(int(z'3e23fee2e6cd8fec', int64), 0.0_real64), &
                     transfer(int(z'3e2550e04f35d20d', int64), 0.0_real64), transfer(int(z'3e26b6a8444f67d5', int64), 0.0_real64), &
                     transfer(int(z'3e2830ab5d23f26a', int64), 0.0_real64), transfer(int(z'3e29c03b5ed0553f', int64), 0.0_real64), &
                     transfer(int(z'3e2b6671c2eca330', int64), 0.0_real64), transfer(int(z'3e2d242fb78c1e8b', int64), 0.0_real64), &
                     transfer(int(z'3e2efa8eb646da2d', int64), 0.0_real64), transfer(int(z'3e307570421cdcc4', int64), 0.0_real64), &
                     transfer(int(z'3e317b0327bbff75', int64), 0.0_real64), transfer(int(z'3e328ee13a141773', int64), 0.0_real64), &
                     transfer(int(z'3e33b17b102ec5e6', int64), 0.0_real64), transfer(int(z'3e34e395b25ce4ce', int64), 0.0_real64), &
                     transfer(int(z'3e3625da032ce5e6', int64), 0.0_real64), transfer(int(z'3e37790d0aefa32f', int64), 0.0_real64), &
                     transfer(int(z'3e38ddd7ac338e63', int64), 0.0_real64), transfer(int(z'3e3a551b150be9cb', int64), 0.0_real64), &
                     transfer(int(z'3e3bdf8028072723', int64), 0.0_real64), transfer(int(z'3e3d7e0438faf0fe', int64), 0.0_real64), &
                     transfer(int(z'3e3f31502a75b916', int64), 0.0_real64), transfer(int(z'3e407d3ebb07c924', int64), 0.0_real64), &
                     transfer(int(z'3e416d28920cab4c', int64), 0.0_real64), transfer(int(z'3e4268e44434584e', int64), 0.0_real64), &
                     transfer(int(z'3e4370f07b69a573', int64), 0.0_real64), transfer(int(z'3e4485cbe1976807', int64), 0.0_real64), &
                     transfer(int(z'3e45a7bcd523a4c0', int64), 0.0_real64), transfer(int(z'3e46d84d66b00fa5', int64), 0.0_real64), &
                     transfer(int(z'3e48169c68296668', int64), 0.0_real64), transfer(int(z'3e4964500ff3c558', int64), 0.0_real64), &
                     transfer(int(z'3e4ac0dba1432305', int64), 0.0_real64), transfer(int(z'3e4c2e720f47a52d', int64), 0.0_real64), &
                     transfer(int(z'3e4dac869d354261', int64), 0.0_real64), transfer(int(z'3e4f3c32c4a40d7f', int64), 0.0_real64), &
                     transfer(int(z'3e506f01a13007fb', int64), 0.0_real64), transfer(int(z'3e514942699aa99b', int64), 0.0_real64), &
                     transfer(int(z'3e522d2219f7f057', int64), 0.0_real64), transfer(int(z'3e531b73cd79ea56', int64), 0.0_real64), &
                     transfer(int(z'3e5413f125ba92e0', int64), 0.0_real64), transfer(int(z'3e55176d3debf81c', int64), 0.0_real64), &
                     transfer(int(z'3e562674d2da237a', int64), 0.0_real64), transfer(int(z'3e5740c1861f1042', int64), 0.0_real64), &
                     transfer(int(z'3e58676cd152d153', int64), 0.0_real64), transfer(int(z'3e599a76b47566ac', int64), 0.0_real64), &
                     transfer(int(z'3e5adab24ab8de75', int64), 0.0_real64), transfer(int(z'3e5c281f941d38ad', int64), 0.0_real64), &
                     transfer(int(z'3e5d8391abd4837c', int64), 0.0_real64), transfer(int(z'3e5eed954eaac851', int64), 0.0_real64), &
                     transfer(int(z'3e6033153e500396', int64), 0.0_real64), transfer(int(z'3e60f71228732719', int64), 0.0_real64), &
                     transfer(int(z'3e61c307c424d36b', int64), 0.0_real64), transfer(int(z'3e62973c6fcb0d42', int64), 0.0_real64), &
                     transfer(int(z'3e6373d35a98d6fb', int64), 0.0_real64), transfer(int(z'3e645936122737a9', int64), 0.0_real64), &
                     transfer(int(z'3e6547aaf4dc3404', int64), 0.0_real64), transfer(int(z'3e663f78611dd0c3', int64), 0.0_real64), &
                     transfer(int(z'3e6740e4b552129e', int64), 0.0_real64), transfer(int(z'3e684c597f1200a9', int64), 0.0_real64), &
                     transfer(int(z'3e6961f9ed909d3f', int64), 0.0_real64), transfer(int(z'3e6a822f8e66ef73', int64), 0.0_real64), &
                     transfer(int(z'3e6bad40bffafbfe', int64), 0.0_real64), transfer(int(z'3e6ce3970fe5c9f3', int64), 0.0_real64), &
                     transfer(int(z'3e6e259c0bc06066', int64), 0.0_real64), transfer(int(z'3e6f739611f0c40e', int64), 0.0_real64), &
                     transfer(int(z'3e7066e5c06e7cd1', int64), 0.0_real64), transfer(int(z'3e711a52f30f041b', int64), 0.0_real64), &
                     transfer(int(z'3e71d458ff3ffc9d', int64), 0.0_real64), transfer(int(z'3e7295097c9ae785', int64), 0.0_real64), &
                     transfer(int(z'3e735caac985c98a', int64), 0.0_real64), transfer(int(z'3e742b71accd2636', int64), 0.0_real64), &
                     transfer(int(z'3e750192ed3d8113', int64), 0.0_real64), transfer(int(z'3e75df31ba09dc7d', int64), 0.0_real64), &
                     transfer(int(z'3e76c4a60931be59', int64), 0.0_real64), transfer(int(z'3e77b201724ea7d5', int64), 0.0_real64), &
                     transfer(int(z'3e78a79beb601ed7', int64), 0.0_real64), transfer(int(z'3e79a5aa3b32a6e8', int64), 0.0_real64), &
                     transfer(int(z'3e7aac612892c393', int64), 0.0_real64), transfer(int(z'3e7bbc18a97ffabc', int64), 0.0_real64), &
                     transfer(int(z'3e7cd478c7fac67e', int64), 0.0_real64), transfer(int(z'3e7df727ba674328', int64), 0.0_real64), &
                     transfer(int(z'3e7f22c5a8c75922', int64), 0.0_real64), transfer(int(z'3e802c59358c9002', int64), 0.0_real64), &
                     transfer(int(z'3e80cc1f0aaec601', int64), 0.0_real64), transfer(int(z'3e8171643fc95a59', int64), 0.0_real64), &
                     transfer(int(z'3e821c28d4dc4d0a', int64), 0.0_real64), transfer(int(z'3e82cc14d3e8182e', int64), 0.0_real64), &
                     transfer(int(z'3e8381d828ebc792', int64), 0.0_real64), transfer(int(z'3e843d72d3e75b34', int64), 0.0_real64), &
                     transfer(int(z'3e84fee4d4dad315', int64), 0.0_real64), transfer(int(z'3e85c68621c5b51a', int64), 0.0_real64), &
                             transfer(int(z'3e869456baa80143', int64), 0.0_real64)]
  real(real64), parameter :: pref_values(59) = [ &
                     transfer(int(z'409076851eb851ec', int64), 0.0_real64), transfer(int(z'408af522d0e56042', int64), 0.0_real64), &
                     transfer(int(z'4086122d0e560419', int64), 0.0_real64), transfer(int(z'408211f7ced91687', int64), 0.0_real64), &
                     transfer(int(z'407d96d916872b02', int64), 0.0_real64), transfer(int(z'407839c28f5c28f6', int64), 0.0_real64), &
                     transfer(int(z'4073d5916872b021', int64), 0.0_real64), transfer(int(z'40703d2b020c49ba', int64), 0.0_real64), &
                     transfer(int(z'406a973333333333', int64), 0.0_real64), transfer(int(z'4065c53f7ced9168', int64), 0.0_real64), &
                     transfer(int(z'4061d3020c49ba5e', int64), 0.0_real64), transfer(int(z'405d2fbe76c8b439', int64), 0.0_real64), &
                     transfer(int(z'4057e55810624dd3', int64), 0.0_real64), transfer(int(z'40539074538ef34d', int64), 0.0_real64), &
                     transfer(int(z'4050049374bc6a7f', int64), 0.0_real64), transfer(int(z'404a3a88ce703afb', int64), 0.0_real64), &
                     transfer(int(z'404579652bd3c361', int64), 0.0_real64), transfer(int(z'404194e3bcd35a86', int64), 0.0_real64), &
                     transfer(int(z'403cca0902de00d2', int64), 0.0_real64), transfer(int(z'40379212d77318fc', int64), 0.0_real64), &
                     transfer(int(z'40334c49ba5e353f', int64), 0.0_real64), transfer(int(z'402f997f62b6ae7d', int64), 0.0_real64), &
                     transfer(int(z'4029df212d773190', int64), 0.0_real64), transfer(int(z'40252e978d4fdf3b', int64), 0.0_real64), &
                     transfer(int(z'4021579fa97e132b', int64), 0.0_real64), transfer(int(z'401c65b6c3760bf6', int64), 0.0_real64), &
                     transfer(int(z'40173ff04577d955', int64), 0.0_real64), transfer(int(z'401309081c2e33f0', int64), 0.0_real64), &
                     transfer(int(z'400f2b65a9a80496', int64), 0.0_real64), transfer(int(z'400984fa05143bf7', int64), 0.0_real64), &
                     transfer(int(z'4004e4c2f837b4a2', int64), 0.0_real64), transfer(int(z'40011b328b6d86ec', int64), 0.0_real64), &
                     transfer(int(z'3ffc02be8bc169c2', int64), 0.0_real64), transfer(int(z'3ff6eeeb702602c9', int64), 0.0_real64), &
                     transfer(int(z'3ff2c6b26bf8769f', int64), 0.0_real64), transfer(int(z'3feebec892ab68cf', int64), 0.0_real64), &
                     transfer(int(z'3fe92c0e7bc3c5bd', int64), 0.0_real64), transfer(int(z'3fe49bf162ae4b02', int64), 0.0_real64), &
                     transfer(int(z'3fe0df9378ee2867', int64), 0.0_real64), transfer(int(z'3fdba122fad6cb53', int64), 0.0_real64), &
                     transfer(int(z'3fd69f01b866e43b', int64), 0.0_real64), transfer(int(z'3fd2854477ff151e', int64), 0.0_real64), &
                     transfer(int(z'3fce53a81dc0db27', int64), 0.0_real64), transfer(int(z'3fc8d4562e09fe87', int64), 0.0_real64), &
                     transfer(int(z'3fc4541d8e864021', int64), 0.0_real64), transfer(int(z'3fc0a4ca4f440af2', int64), 0.0_real64), &
                     transfer(int(z'3fbb40d4dc65c704', int64), 0.0_real64), transfer(int(z'3fb6502b917e4225', int64), 0.0_real64), &
                     transfer(int(z'3fb244ba44340c77', int64), 0.0_real64), transfer(int(z'3fade9f5d27f9435', int64), 0.0_real64), &
                     transfer(int(z'3fa87dd0e637011e', int64), 0.0_real64), transfer(int(z'3fa40d4a6b5e1cec', int64), 0.0_real64), &
                     transfer(int(z'3fa06ac8cbb64c58', int64), 0.0_real64), transfer(int(z'3f9ae1e207c7749e', int64), 0.0_real64), &
                     transfer(int(z'3f96026b144b10a0', int64), 0.0_real64), transfer(int(z'3f9205143bf72713', int64), 0.0_real64), &
                     transfer(int(z'3f8d81bb5682c394', int64), 0.0_real64), transfer(int(z'3f882872e5d0a9d1', int64), 0.0_real64), &
                             transfer(int(z'3f83c76935a3a5e2', int64), 0.0_real64)]
  real(real64), parameter :: preflog_values(59) = [ &
                     transfer(int(z'401bd70a3d70a3d7', int64), 0.0_real64), transfer(int(z'401b0a3d70a3d70a', int64), 0.0_real64), &
                     transfer(int(z'401a3d70a3d70a3d', int64), 0.0_real64), transfer(int(z'401970a3d70a3d71', int64), 0.0_real64), &
                     transfer(int(z'4018a3d70a3d70a4', int64), 0.0_real64), transfer(int(z'4017d70a3d70a3d7', int64), 0.0_real64), &
                     transfer(int(z'40170a3d70a3d70a', int64), 0.0_real64), transfer(int(z'40163d70a3d70a3d', int64), 0.0_real64), &
                     transfer(int(z'401570a3d70a3d71', int64), 0.0_real64), transfer(int(z'4014a3d70a3d70a4', int64), 0.0_real64), &
                     transfer(int(z'4013d70a3d70a3d7', int64), 0.0_real64), transfer(int(z'40130a3d70a3d70a', int64), 0.0_real64), &
                     transfer(int(z'40123d70a3d70a3d', int64), 0.0_real64), transfer(int(z'401170a3d70a3d71', int64), 0.0_real64), &
                     transfer(int(z'4010a3d70a3d70a4', int64), 0.0_real64), transfer(int(z'400fae147ae147ae', int64), 0.0_real64), &
                     transfer(int(z'400e147ae147ae14', int64), 0.0_real64), transfer(int(z'400c7ae147ae147b', int64), 0.0_real64), &
                     transfer(int(z'400ae147ae147ae1', int64), 0.0_real64), transfer(int(z'400947ae147ae148', int64), 0.0_real64), &
                     transfer(int(z'4007ae147ae147ae', int64), 0.0_real64), transfer(int(z'4006147ae147ae14', int64), 0.0_real64), &
                     transfer(int(z'40047ae147ae147b', int64), 0.0_real64), transfer(int(z'4002e147ae147ae1', int64), 0.0_real64), &
                     transfer(int(z'400147ae147ae148', int64), 0.0_real64), transfer(int(z'3fff5c28f5c28f5c', int64), 0.0_real64), &
                     transfer(int(z'3ffc28f5c28f5c29', int64), 0.0_real64), transfer(int(z'3ff8f5c28f5c28f6', int64), 0.0_real64), &
                     transfer(int(z'3ff5c28f5c28f5c3', int64), 0.0_real64), transfer(int(z'3ff28f5c28f5c28f', int64), 0.0_real64), &
                     transfer(int(z'3feeb851eb851eb8', int64), 0.0_real64), transfer(int(z'3fe851eb851eb852', int64), 0.0_real64), &
                     transfer(int(z'3fe1eb851eb851ec', int64), 0.0_real64), transfer(int(z'3fd70a3d70a3d70a', int64), 0.0_real64), &
                     transfer(int(z'3fc47ae147ae147b', int64), 0.0_real64), transfer(int(z'bfa47ae147ae147b', int64), 0.0_real64), &
                     transfer(int(z'bfceb851eb851eb8', int64), 0.0_real64), transfer(int(z'bfdc28f5c28f5c29', int64), 0.0_real64), &
                     transfer(int(z'bfe47ae147ae147b', int64), 0.0_real64), transfer(int(z'bfeae147ae147ae1', int64), 0.0_real64), &
                     transfer(int(z'bff0a3d70a3d70a4', int64), 0.0_real64), transfer(int(z'bff3d70a3d70a3d7', int64), 0.0_real64), &
                     transfer(int(z'bff70a3d70a3d70a', int64), 0.0_real64), transfer(int(z'bffa3d70a3d70a3d', int64), 0.0_real64), &
                     transfer(int(z'bffd70a3d70a3d71', int64), 0.0_real64), transfer(int(z'c00051eb851eb852', int64), 0.0_real64), &
                     transfer(int(z'c001eb851eb851ec', int64), 0.0_real64), transfer(int(z'c003851eb851eb85', int64), 0.0_real64), &
                     transfer(int(z'c0051eb851eb851f', int64), 0.0_real64), transfer(int(z'c006b851eb851eb8', int64), 0.0_real64), &
                     transfer(int(z'c00851eb851eb852', int64), 0.0_real64), transfer(int(z'c009eb851eb851ec', int64), 0.0_real64), &
                     transfer(int(z'c00b851eb851eb85', int64), 0.0_real64), transfer(int(z'c00d1eb851eb851f', int64), 0.0_real64), &
                     transfer(int(z'c00eb851eb851eb8', int64), 0.0_real64), transfer(int(z'c01028f5c28f5c29', int64), 0.0_real64), &
                     transfer(int(z'c010f5c28f5c28f6', int64), 0.0_real64), transfer(int(z'c011c28f5c28f5c3', int64), 0.0_real64), &
                             transfer(int(z'c0128f5c28f5c28f', int64), 0.0_real64)]
  real(real64), parameter :: tref_values(59) = [ &
                     transfer(int(z'4072633333333333', int64), 0.0_real64), transfer(int(z'4071ffd70a3d70a4', int64), 0.0_real64), &
                     transfer(int(z'40716f0a3d70a3d7', int64), 0.0_real64), transfer(int(z'4070d40000000000', int64), 0.0_real64), &
                     transfer(int(z'40703d47ae147ae1', int64), 0.0_real64), transfer(int(z'406f4570a3d70a3d', int64), 0.0_real64), &
                     transfer(int(z'406e18a3d70a3d71', int64), 0.0_real64), transfer(int(z'406cf947ae147ae1', int64), 0.0_real64), &
                     transfer(int(z'406be1eb851eb852', int64), 0.0_real64), transfer(int(z'406af8f5c28f5c29', int64), 0.0_real64), &
                     transfer(int(z'406af66666666666', int64), 0.0_real64), transfer(int(z'406af66666666666', int64), 0.0_real64), &
                     transfer(int(z'406af66666666666', int64), 0.0_real64), transfer(int(z'406b21eb851eb852', int64), 0.0_real64), &
                     transfer(int(z'406b528f5c28f5c3', int64), 0.0_real64), transfer(int(z'406b85c28f5c28f6', int64), 0.0_real64), &
                     transfer(int(z'406bb7ae147ae148', int64), 0.0_real64), transfer(int(z'406be8f5c28f5c29', int64), 0.0_real64), &
                     transfer(int(z'406c1947ae147ae1', int64), 0.0_real64), transfer(int(z'406c51999999999a', int64), 0.0_real64), &
                     transfer(int(z'406c8ae147ae147b', int64), 0.0_real64), transfer(int(z'406ce428f5c28f5c', int64), 0.0_real64), &
                     transfer(int(z'406d4051eb851eb8', int64), 0.0_real64), transfer(int(z'406da0f5c28f5c29', int64), 0.0_real64), &
                     transfer(int(z'406e070a3d70a3d7', int64), 0.0_real64), transfer(int(z'406e76b851eb851f', int64), 0.0_real64), &
                     transfer(int(z'406ee851eb851eb8', int64), 0.0_real64), transfer(int(z'406f5b3333333333', int64), 0.0_real64), &
                     transfer(int(z'406fd23d70a3d70a', int64), 0.0_real64), transfer(int(z'4070251eb851eb85', int64), 0.0_real64), &
                     transfer(int(z'4070628f5c28f5c3', int64), 0.0_real64), transfer(int(z'4070a0f5c28f5c29', int64), 0.0_real64), &
                     transfer(int(z'4070dfd70a3d70a4', int64), 0.0_real64), transfer(int(z'4071166666666666', int64), 0.0_real64), &
                     transfer(int(z'407135c28f5c28f6', int64), 0.0_real64), transfer(int(z'40713ae147ae147b', int64), 0.0_real64), &
                     transfer(int(z'40711b851eb851ec', int64), 0.0_real64), transfer(int(z'4070fa147ae147ae', int64), 0.0_real64), &
                     transfer(int(z'4070d8cccccccccd', int64), 0.0_real64), transfer(int(z'40709ee147ae147b', int64), 0.0_real64), &
                     transfer(int(z'407061c28f5c28f6', int64), 0.0_real64), transfer(int(z'4070247ae147ae14', int64), 0.0_real64), &
                     transfer(int(z'406fb33333333333', int64), 0.0_real64), transfer(int(z'406f1147ae147ae1', int64), 0.0_real64), &
                     transfer(int(z'406e6f5c28f5c28f', int64), 0.0_real64), transfer(int(z'406dc2e147ae147b', int64), 0.0_real64), &
                     transfer(int(z'406d01eb851eb852', int64), 0.0_real64), transfer(int(z'406c40f5c28f5c29', int64), 0.0_real64), &
                     transfer(int(z'406b800000000000', int64), 0.0_real64), transfer(int(z'406acb3333333333', int64), 0.0_real64), &
                     transfer(int(z'406a1bd70a3d70a4', int64), 0.0_real64), transfer(int(z'40696ccccccccccd', int64), 0.0_real64), &
                     transfer(int(z'4068bd70a3d70a3d', int64), 0.0_real64), transfer(int(z'40681ccccccccccd', int64), 0.0_real64), &
                     transfer(int(z'406782e147ae147b', int64), 0.0_real64), transfer(int(z'4066e947ae147ae1', int64), 0.0_real64), &
                     transfer(int(z'40664fae147ae148', int64), 0.0_real64), transfer(int(z'4065be147ae147ae', int64), 0.0_real64), &
                             transfer(int(z'406583d70a3d70a4', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_1(7) = [ &
                     transfer(int(z'3f9335d249e44fa0', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e6032888183fa26', int64), 0.0_real64), transfer(int(z'3e95798ee2308c3a', int64), 0.0_real64), &
                     transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), transfer(int(z'3ebc8571c4687a3d', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_2(7) = [ &
                     transfer(int(z'3f89085f4a1272c9', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e62a491521ef20e', int64), 0.0_real64), transfer(int(z'3e95798ee2308c3a', int64), 0.0_real64), &
                     transfer(int(z'3e8333811158871c', int64), 0.0_real64), transfer(int(z'3ebc8571c4687a3d', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_3(7) = [ &
                     transfer(int(z'3f78210e6d810cdb', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e66cdfe92be5ebd', int64), 0.0_real64), transfer(int(z'3e95798ee2308c3a', int64), 0.0_real64), &
                     transfer(int(z'3e8215a192e55d00', int64), 0.0_real64), transfer(int(z'3ebc8503d0e912de', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_4(7) = [ &
                     transfer(int(z'3f66abde3fbbd7b2', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e6c5324497b1af4', int64), 0.0_real64), transfer(int(z'3e95798ee2308c3a', int64), 0.0_real64), &
                     transfer(int(z'3e8187b9b5aa59a3', int64), 0.0_real64), transfer(int(z'3ebc5c3674a1b6a0', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_5(7) = [ &
                     transfer(int(z'3f570b49e01de269', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e71f85b4d746698', int64), 0.0_real64), transfer(int(z'3e95798ee2308c3a', int64), 0.0_real64), &
                     transfer(int(z'3e812ba42e2a2d4e', int64), 0.0_real64), transfer(int(z'3ebbf823d5aca132', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_6(7) = [ &
                     transfer(int(z'3f48e4d353cf8aed', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e7763872b886503', int64), 0.0_real64), transfer(int(z'3e95738b9138e508', int64), 0.0_real64), &
                     transfer(int(z'3e802839ad92493f', int64), 0.0_real64), transfer(int(z'3ebb6eb3766b6a7d', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_7(7) = [ &
                     transfer(int(z'3f397a4f7c6a08dd', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e7e93d5e98dc415', int64), 0.0_real64), transfer(int(z'3e95292806a02862', int64), 0.0_real64), &
                     transfer(int(z'3e7cfc543fc37285', int64), 0.0_real64), transfer(int(z'3ebb0209d18241a3', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_8(7) = [ &
                     transfer(int(z'3f25ae92faeef414', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e850a9380ca9b92', int64), 0.0_real64), transfer(int(z'3e9463c278b22cb1', int64), 0.0_real64), &
                     transfer(int(z'3e794bfc6daf23da', int64), 0.0_real64), transfer(int(z'3eba27daa0b12131', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_9(7) = [ &
                     transfer(int(z'3f037f8eab7ef452', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e8d3e4cbf67deb2', int64), 0.0_real64), transfer(int(z'3e93bea93e975b4c', int64), 0.0_real64), &
                     transfer(int(z'3e75565faf2e3066', int64), 0.0_real64), transfer(int(z'3eb95dfd94c958d8', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_10(7) = [ &
                     transfer(int(z'3edf5bd4abd8245e', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e95c5aa3ac6e65c', int64), 0.0_real64), transfer(int(z'3e931f675a746e26', int64), 0.0_real64), &
                     transfer(int(z'3e707a69eeb9cbc1', int64), 0.0_real64), transfer(int(z'3eb8bb36172b4f40', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_11(7) = [ &
                     transfer(int(z'3ed211e4ffaa8cdf', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e9f44c9ca9820ea', int64), 0.0_real64), transfer(int(z'3e9291d77338f0ae', int64), 0.0_real64), &
                     transfer(int(z'3e6876218ba4cdb5', int64), 0.0_real64), transfer(int(z'3eb8224f79ff8f31', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_12(7) = [ &
                     transfer(int(z'3ecbf33365737c6d', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ea30f99268a5ee5', int64), 0.0_real64), transfer(int(z'3e91c3aee4571e9f', int64), 0.0_real64), &
                     transfer(int(z'3e61f8c4db0d6dac', int64), 0.0_real64), transfer(int(z'3eb77dd02e63e81d', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_13(7) = [ &
                     transfer(int(z'3ecae052a6f10f04', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ea75b321e13f604', int64), 0.0_real64), transfer(int(z'3e904c2198607175', int64), 0.0_real64), &
                     transfer(int(z'3e5af8621dc2dbf0', int64), 0.0_real64), transfer(int(z'3eb6c58f21e3adf9', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_14(7) = [ &
                     transfer(int(z'3eca8620e86e431e', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eb2c459b4f2d381', int64), 0.0_real64), transfer(int(z'3e8c20154af52eb1', int64), 0.0_real64), &
                     transfer(int(z'3e540c3ed2920ec9', int64), 0.0_real64), transfer(int(z'3eb6074ac46bcca4', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_15(7) = [ &
                     transfer(int(z'3ecb4879cf207a79', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ebd8edf95f8057d', int64), 0.0_real64), transfer(int(z'3e87142831f692dc', int64), 0.0_real64), &
                     transfer(int(z'3e4ed072386cd445', int64), 0.0_real64), transfer(int(z'3eb4fddcf2dc4164', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_16(7) = [ &
                     transfer(int(z'3eccb5fa3fa51b28', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ec384facda76d61', int64), 0.0_real64), transfer(int(z'3e82741ed462329c', int64), 0.0_real64), &
                     transfer(int(z'3e4ad87f5788b8b8', int64), 0.0_real64), transfer(int(z'3eb3935e2ad3744e', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_17(7) = [ &
                     transfer(int(z'3ece70c9e5be6a9c', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ec8cf9cc54efd5f', int64), 0.0_real64), transfer(int(z'3e7e6b4a85c60c43', int64), 0.0_real64), &
                     transfer(int(z'3e4aa4d2049d41d8', int64), 0.0_real64), transfer(int(z'3eb1b47a9eec39b1', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_18(7) = [ &
                     transfer(int(z'3ed06b7c07b4eb8a', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eceb24973237eae', int64), 0.0_real64), transfer(int(z'3e7aefffde9b4c0e', int64), 0.0_real64), &
                     transfer(int(z'3e4cee4f717081ee', int64), 0.0_real64), transfer(int(z'3eaf4cc6e20d0a04', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_19(7) = [ &
                     transfer(int(z'3ed166bd75d8238c', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ed345d7fb7f11d9', int64), 0.0_real64), transfer(int(z'3e7880c855960481', int64), 0.0_real64), &
                     transfer(int(z'3e4fff5c939522db', int64), 0.0_real64), transfer(int(z'3eab407cb7ab9160', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_20(7) = [ &
                     transfer(int(z'3ed211c982cab308', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ed64f201968156f', int64), 0.0_real64), transfer(int(z'3e76f0f8fef43708', int64), 0.0_real64), &
                     transfer(int(z'3e5143c309a24b42', int64), 0.0_real64), transfer(int(z'3ea93efb1b7464a9', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_21(7) = [ &
                     transfer(int(z'3ed2a18fa9a31e75', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ed9016f1b09d467', int64), 0.0_real64), transfer(int(z'3e759280d8dab855', int64), 0.0_real64), &
                     transfer(int(z'3e526bce2cd423e9', int64), 0.0_real64), transfer(int(z'3ea7bb7d2b0e4a95', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_22(7) = [ &
                     transfer(int(z'3ed333601518b4e5', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3edb4f7483f6ca40', int64), 0.0_real64), transfer(int(z'3e73b215dfdc037a', int64), 0.0_real64), &
                     transfer(int(z'3e53fd208aa70b54', int64), 0.0_real64), transfer(int(z'3ea663604bebf8f9', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_23(7) = [ &
                     transfer(int(z'3ed3bfed99b5990b', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3edda060187fb9db', int64), 0.0_real64), transfer(int(z'3e71b5c4796a6fcd', int64), 0.0_real64), &
                     transfer(int(z'3e5596b1f86e8046', int64), 0.0_real64), transfer(int(z'3ea50cb94247a06d', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_24(7) = [ &
                     transfer(int(z'3ed41bd72636026d', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ee0217332cbb0f8', int64), 0.0_real64), transfer(int(z'3e6e15f107095382', int64), 0.0_real64), &
                     transfer(int(z'3e574034c95306d3', int64), 0.0_real64), transfer(int(z'3ea3aa0b96b3f97e', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_25(7) = [ &
                     transfer(int(z'3ed46cccf1859fda', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ee15151a565dfec', int64), 0.0_real64), transfer(int(z'3e69480014e7df73', int64), 0.0_real64), &
                     transfer(int(z'3e58cc9483f99955', int64), 0.0_real64), transfer(int(z'3ea2609f0bfd43f8', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_26(7) = [ &
                     transfer(int(z'3ed4a94091d1b550', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ee2432de50622b1', int64), 0.0_real64), transfer(int(z'3e657665a49b55fa', int64), 0.0_real64), &
                     transfer(int(z'3e5a22873bb885cb', int64), 0.0_real64), transfer(int(z'3ea146192c05735b', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_27(7) = [ &
                     transfer(int(z'3ed4d52b1374befe', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ee285e98e797ff4', int64), 0.0_real64), transfer(int(z'3e61b4996838dbc1', int64), 0.0_real64), &
                     transfer(int(z'3e5b88b1b4fa8894', int64), 0.0_real64), transfer(int(z'3ea02cdd268bd8da', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_28(7) = [ &
                     transfer(int(z'3ed4f4bc7c88ecc2', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ee246c6bc51246c', int64), 0.0_real64), transfer(int(z'3e5bfc6af2c04a9c', int64), 0.0_real64), &
                     transfer(int(z'3e5cfaf467c55aee', int64), 0.0_real64), transfer(int(z'3e9e29260b21dd23', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_29(7) = [ &
                     transfer(int(z'3ed5314b99b4dc10', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ee0f9981effa667', int64), 0.0_real64), transfer(int(z'3e569e93f70030fd', int64), 0.0_real64), &
                     transfer(int(z'3e5e8decfbfc5ea8', int64), 0.0_real64), transfer(int(z'3e9bfc595b26c96e', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_30(7) = [ &
                     transfer(int(z'3ed580a513e6b5d9', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3edebf4778f175a7', int64), 0.0_real64), transfer(int(z'3e51d0c63411bf4a', int64), 0.0_real64), &
                     transfer(int(z'3e60071a3e8d10cc', int64), 0.0_real64), transfer(int(z'3e99cf60b02bf2c6', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_31(7) = [ &
                     transfer(int(z'3ed60577798e5551', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eda776b14a2aea9', int64), 0.0_real64), transfer(int(z'3e4bf42be2cbbd16', int64), 0.0_real64), &
                     transfer(int(z'3e609cc6068a196e', int64), 0.0_real64), transfer(int(z'3e979f505f35670c', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_32(7) = [ &
                     transfer(int(z'3ed678246f6f255c', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ed682fcb3c0177a', int64), 0.0_real64), transfer(int(z'3e45ab0941ebdd5c', int64), 0.0_real64), &
                     transfer(int(z'3e61313525bc0cd5', int64), 0.0_real64), transfer(int(z'3e956cd85442320c', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_33(7) = [ &
                     transfer(int(z'3ed6dcdbfba355d9', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ed2cd7a2b462823', int64), 0.0_real64), transfer(int(z'3e405fd54663d061', int64), 0.0_real64), &
                     transfer(int(z'3e61c55de687fb84', int64), 0.0_real64), transfer(int(z'3e93395867506b5a', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_34(7) = [ &
                     transfer(int(z'3ed6ff5390537d5e', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ed01a33c5c5c096', int64), 0.0_real64), transfer(int(z'3e3a4480cf606677', int64), 0.0_real64), &
                     transfer(int(z'3e6264a89677a941', int64), 0.0_real64), transfer(int(z'3e911c85e63f29d9', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_35(7) = [ &
                     transfer(int(z'3ed711947cfa26a2', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ecb898b6906272c', int64), 0.0_real64), transfer(int(z'3e340ba402e4d135', int64), 0.0_real64), &
                     transfer(int(z'3e62fbd765a5cbd5', int64), 0.0_real64), transfer(int(z'3e8e2a01f220abe1', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_36(7) = [ &
                     transfer(int(z'3ed711947cfa26a2', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ec7af6b8a5f0b76', int64), 0.0_real64), transfer(int(z'3e2c3954a975f996', int64), 0.0_real64), &
                     transfer(int(z'3e638a5d974659cf', int64), 0.0_real64), transfer(int(z'3e8a4a62b38131d1', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_37(7) = [ &
                     transfer(int(z'3ed6dfc2273f4f9a', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ec4e485d47f6e81', int64), 0.0_real64), transfer(int(z'3e2877b2a5b71bcb', int64), 0.0_real64), &
                     transfer(int(z'3e6407d8ec31c34f', int64), 0.0_real64), transfer(int(z'3e888e1d37e9e94d', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_38(7) = [ &
                     transfer(int(z'3ed6ab409fa83281', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ec2283a758b8c2a', int64), 0.0_real64), transfer(int(z'3e2525fec90af222', int64), 0.0_real64), &
                     transfer(int(z'3e64848125eb1ea7', int64), 0.0_real64), transfer(int(z'3e86efbc562921cd', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_39(7) = [ &
                     transfer(int(z'3ed676bf18111567', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ebed84c20aebb03', int64), 0.0_real64), transfer(int(z'3e21d44aec5ec879', int64), 0.0_real64), &
                     transfer(int(z'3e650106307177a4', int64), 0.0_real64), transfer(int(z'3e8551037e68d468', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_40(7) = [ &
                     transfer(int(z'3ed608b01bc9dc99', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ebbe1606c4c3a88', int64), 0.0_real64), transfer(int(z'3e1fded0eacc8dea', int64), 0.0_real64), &
                     transfer(int(z'3e662ca41ed18d9f', int64), 0.0_real64), transfer(int(z'3e84da21030ddc21', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_41(7) = [ &
                     transfer(int(z'3ed592e6008d5f1d', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eb940c8e6f1e39e', int64), 0.0_real64), transfer(int(z'3e1c76aef73549b6', int64), 0.0_real64), &
                     transfer(int(z'3e676f7c35de3238', int64), 0.0_real64), transfer(int(z'3e848a6a137c8414', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_42(7) = [ &
                     transfer(int(z'3ed51d376230bb79', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eb69fc36e182555', int64), 0.0_real64), transfer(int(z'3e190e1c6c94645d', int64), 0.0_real64), &
                     transfer(int(z'3e68b2777c1dd92d', int64), 0.0_real64), transfer(int(z'3e843ab323eb2c07', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_43(7) = [ &
                     transfer(int(z'3ed4743599db5700', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eb415ef521e3513', int64), 0.0_real64), transfer(int(z'3e16ab38ed5509fd', int64), 0.0_real64), &
                     transfer(int(z'3e6affaae35258f3', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_44(7) = [ &
                     transfer(int(z'3ed3b454eb45b207', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eb195fc16968e5a', int64), 0.0_real64), transfer(int(z'3e14bd525e1720f1', int64), 0.0_real64), &
                     transfer(int(z'3e6dc470b1e0dccb', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_45(7) = [ &
                     transfer(int(z'3ed2f458bfd03335', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3eae2c95a71d181a', int64), 0.0_real64), transfer(int(z'3e12cefb37cf96c0', int64), 0.0_real64), &
                     transfer(int(z'3e70449b4037b052', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_46(7) = [ &
                     transfer(int(z'3ed22fbe9ac11d27', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ea99dd052f0c02a', int64), 0.0_real64), transfer(int(z'3e11245eed52fd54', int64), 0.0_real64), &
                     transfer(int(z'3e7281eedbe89fa9', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_47(7) = [ &
                     transfer(int(z'3ed161cd059efec8', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ea5f02f650be015', int64), 0.0_real64), transfer(int(z'3e0fff731830a97d', int64), 0.0_real64), &
                     transfer(int(z'3e7674858c075f39', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_48(7) = [ &
                     transfer(int(z'3ed093bff39d0691', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ea2428e77270000', int64), 0.0_real64), transfer(int(z'3e0db62855bb5851', int64), 0.0_real64), &
                     transfer(int(z'3e7a670aa48c9d9b', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_49(7) = [ &
                     transfer(int(z'3ecf8b9cbcf5d062', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e9d29af17847ce4', int64), 0.0_real64), transfer(int(z'3e0b6cdd93460726', int64), 0.0_real64), &
                     transfer(int(z'3e7e596c8dded9a1', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_50(7) = [ &
                     transfer(int(z'3ecdf73db7e724a1', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e98711485123706', int64), 0.0_real64), transfer(int(z'3e09d1355810d4c1', int64), 0.0_real64), &
                     transfer(int(z'3e83d18f187d1f9e', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_51(7) = [ &
                     transfer(int(z'3ecc664e4ed3b3d8', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e94ef16a0f0c3d5', int64), 0.0_real64), transfer(int(z'3e088581f918aca3', int64), 0.0_real64), &
                     transfer(int(z'3e89b1242055ebdc', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_52(7) = [ &
                     transfer(int(z'3ecad55ee5c0430f', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e916d18bccf50a3', int64), 0.0_real64), transfer(int(z'3e0739ce9a208486', int64), 0.0_real64), &
                     transfer(int(z'3e8f90b9282eb819', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_53(7) = [ &
                     transfer(int(z'3ec9446f7cacd245', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3e8bd635b15bbae3', int64), 0.0_real64), transfer(int(z'3e05ee1b3b285c69', int64), 0.0_real64), &
                     transfer(int(z'3e92b8271803c22b', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_54(7) = [ &
                     transfer(int(z'3ec7b537e196fef8', int64), 0.0_real64), transfer(int(z'3f373f0bd97d096b', int64), 0.0_real64), &
                     transfer(int(z'3e89b283f8540372', int64), 0.0_real64), transfer(int(z'3e04f3f20b5cb5e8', int64), 0.0_real64), &
                     transfer(int(z'3e977d204264dc52', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_55(7) = [ &
                     transfer(int(z'3ec626dc2d7ffa68', int64), 0.0_real64), transfer(int(z'3f3737aa105f48bb', int64), 0.0_real64), &
                     transfer(int(z'3e89fd6b73ec08f1', int64), 0.0_real64), transfer(int(z'3e042282b0d98ce6', int64), 0.0_real64), &
                     transfer(int(z'3e9d2bead6816338', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_56(7) = [ &
                     transfer(int(z'3ec498807968f5d8', int64), 0.0_real64), transfer(int(z'3f3730733a5f4c6c', int64), 0.0_real64), &
                     transfer(int(z'3e8a4852ef840e6f', int64), 0.0_real64), transfer(int(z'3e0350fcd1badd42', int64), 0.0_real64), &
                     transfer(int(z'3ea16d70b2ced689', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_57(7) = [ &
                     transfer(int(z'3ec309edcb923d99', int64), 0.0_real64), transfer(int(z'3f37291171418bbc', int64), 0.0_real64), &
                     transfer(int(z'3e8a933a6b1c13ee', int64), 0.0_real64), transfer(int(z'3e027f8d7737b43f', int64), 0.0_real64), &
                     transfer(int(z'3ea444ebfa5cfb75', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_58(7) = [ &
                     transfer(int(z'3ed22fbe9ac11d27', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ea99dd052f0c02a', int64), 0.0_real64), transfer(int(z'3e11245eed52fd54', int64), 0.0_real64), &
                     transfer(int(z'3e7281eedbe89fa9', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]
  real(real64), parameter :: chi_mls_column_59(7) = [ &
                     transfer(int(z'3ed161cd059efec8', int64), 0.0_real64), transfer(int(z'3f3743e963dc486b', int64), 0.0_real64), &
                     transfer(int(z'3ea5f02f650be015', int64), 0.0_real64), transfer(int(z'3e0fff731830a97d', int64), 0.0_real64), &
                     transfer(int(z'3e7674858c075f39', int64), 0.0_real64), transfer(int(z'3e8421f5f40d8376', int64), 0.0_real64), &
                             transfer(int(z'3fcac083126e978d', int64), 0.0_real64)]

contains

  !> Run the four selected original stages in their declared order.
  !! OUTPUT and GASES are caller-owned INOUT records. CONSTANTS is a read-only
  !! forecast_physical_constants record from the accepted own producer. The
  !! caller admits all disjoint spans, positive finite molecular masses,
  !! nonnegative finite input volume fractions, nearest rounding and gradual
  !! underflow. Link the public EXP call to the permitted C math provider.
  subroutine initialize_longwave_reference_fields(output, gases, constants)
    type(longwave_reference_parameter_record), intent(inout) :: output
    type(terdi), intent(inout) :: gases
    type(forecast_physical_constants), intent(in) :: constants
    call initialize_longwave_mass_mixing_ratios(gases, constants)
    call initialize_longwave_transmission_fields(output)
    call initialize_longwave_planck_fields(output)
    call initialize_longwave_atmosphere_fields(output)
  end subroutine initialize_longwave_reference_fields

  !> Convert nine volume fractions to mass fractions as SURDI does.
  !! GASES is native YOERDI::TERDI with intent INOUT. CONSTANTS is read only;
  !! its molecular masses are in grams per mole. Every multiply precedes its
  !! separate divide by dry-air mass RMD. Incoming signed zeros are retained.
  !! Only the thirteen selected fields are changed; other TERDI bytes remain.
  subroutine initialize_longwave_mass_mixing_ratios(gases, constants)
    type(terdi), intent(inout) :: gases
    type(forecast_physical_constants), intent(in) :: constants
    real(real64) :: product
    product = gases%rcco2*constants%rmco2
    gases%rcardi = product/constants%rmd
    product = gases%rcch4*constants%rmch4
    gases%rch4 = product/constants%rmd
    product = gases%rcn2o*constants%rmn2o
    gases%rn2o = product/constants%rmd
    product = gases%rcno2*constants%rmno2
    gases%rno2 = product/constants%rmd
    product = 1.0e-6_real64*constants%rmo3
    gases%ro3 = product/constants%rmd
    product = gases%rccfc11*constants%rmcfc11
    gases%rcfc11 = product/constants%rmd
    product = gases%rccfc12*constants%rmcfc12
    gases%rcfc12 = product/constants%rmd
    product = gases%rccfc22*constants%rmhcfc22
    gases%rcfc22 = product/constants%rmd
    product = gases%rcccl4*constants%rmccl4
    gases%rccl4 = product/constants%rmd
    gases%rrae = 0.1277e-2_real64
    gases%rsundur = 120.0_real64
    gases%repclc = 1.0e-12_real64
    gases%reph2o = 1.0e-12_real64
  end subroutine initialize_longwave_mass_mixing_ratios

  !> Evaluate every SURRTAB transmission entry in increasing index order.
  !! OUTPUT is INOUT. This stage changes only TRANS and BPADE. Each quotient,
  !! product, subtraction and negation keeps its separate FP64 rounding.
  !! EXP may naturally set underflow/inexact flags and errno; preserve them.
  subroutine initialize_longwave_transmission_fields(output)
    type(longwave_reference_parameter_record), intent(inout) :: output
    integer(int32) :: index
    real(real64) :: coordinate, numerator, denominator, optical_depth, argument
    output%bpade = transfer(int(z'400cc6e80ebbdb2a', int64), 0.0_real64)
    output%trans(0) = 1.0_real64
    output%trans(ubound(output%trans, 1)) = 0.0_real64
    do index = 1_int32, ubound(output%trans, 1) - 1_int32
      coordinate = real(index, real64)/real(ubound(output%trans, 1), real64)
      numerator = output%bpade*coordinate
      denominator = 1.0_real64 - coordinate
      optical_depth = numerator/denominator
      argument = -optical_depth
      output%trans(index) = selected_public_exp(argument)
    end do
  end subroutine initialize_longwave_transmission_fields

  !> Publish the source-defined SURRTPK arrays through native fields.
  !! OUTPUT is INOUT. NG, NSPA, NSPB, DELWAVE and TOTPLNK are changed.
  !! Named column copies retain the source column order and every literal bit.
  subroutine initialize_longwave_planck_fields(output)
    type(longwave_reference_parameter_record), intent(inout) :: output
    output%ng = ng_values
    output%nspa = nspa_values
    output%nspb = nspb_values
    output%delwave = delwave_values
    output%totplnk(:, 1) = totplnk_column_1
    output%totplnk(:, 2) = totplnk_column_2
    output%totplnk(:, 3) = totplnk_column_3
    output%totplnk(:, 4) = totplnk_column_4
    output%totplnk(:, 5) = totplnk_column_5
    output%totplnk(:, 6) = totplnk_column_6
    output%totplnk(:, 7) = totplnk_column_7
    output%totplnk(:, 8) = totplnk_column_8
    output%totplnk(:, 9) = totplnk_column_9
    output%totplnk(:, 10) = totplnk_column_10
    output%totplnk(:, 11) = totplnk_column_11
    output%totplnk(:, 12) = totplnk_column_12
    output%totplnk(:, 13) = totplnk_column_13
    output%totplnk(:, 14) = totplnk_column_14
    output%totplnk(:, 15) = totplnk_column_15
    output%totplnk(:, 16) = totplnk_column_16
  end subroutine initialize_longwave_planck_fields

  !> Publish the source-defined SURRTRF reference atmosphere arrays.
  !! OUTPUT is INOUT. PREF, PREFLOG, TREF and CHI_MLS are changed; all other
  !! fields stay unchanged. Each named copy retains Fortran column order.
  subroutine initialize_longwave_atmosphere_fields(output)
    type(longwave_reference_parameter_record), intent(inout) :: output
    output%pref = pref_values
    output%preflog = preflog_values
    output%tref = tref_values
    output%chi_mls(:, 1) = chi_mls_column_1
    output%chi_mls(:, 2) = chi_mls_column_2
    output%chi_mls(:, 3) = chi_mls_column_3
    output%chi_mls(:, 4) = chi_mls_column_4
    output%chi_mls(:, 5) = chi_mls_column_5
    output%chi_mls(:, 6) = chi_mls_column_6
    output%chi_mls(:, 7) = chi_mls_column_7
    output%chi_mls(:, 8) = chi_mls_column_8
    output%chi_mls(:, 9) = chi_mls_column_9
    output%chi_mls(:, 10) = chi_mls_column_10
    output%chi_mls(:, 11) = chi_mls_column_11
    output%chi_mls(:, 12) = chi_mls_column_12
    output%chi_mls(:, 13) = chi_mls_column_13
    output%chi_mls(:, 14) = chi_mls_column_14
    output%chi_mls(:, 15) = chi_mls_column_15
    output%chi_mls(:, 16) = chi_mls_column_16
    output%chi_mls(:, 17) = chi_mls_column_17
    output%chi_mls(:, 18) = chi_mls_column_18
    output%chi_mls(:, 19) = chi_mls_column_19
    output%chi_mls(:, 20) = chi_mls_column_20
    output%chi_mls(:, 21) = chi_mls_column_21
    output%chi_mls(:, 22) = chi_mls_column_22
    output%chi_mls(:, 23) = chi_mls_column_23
    output%chi_mls(:, 24) = chi_mls_column_24
    output%chi_mls(:, 25) = chi_mls_column_25
    output%chi_mls(:, 26) = chi_mls_column_26
    output%chi_mls(:, 27) = chi_mls_column_27
    output%chi_mls(:, 28) = chi_mls_column_28
    output%chi_mls(:, 29) = chi_mls_column_29
    output%chi_mls(:, 30) = chi_mls_column_30
    output%chi_mls(:, 31) = chi_mls_column_31
    output%chi_mls(:, 32) = chi_mls_column_32
    output%chi_mls(:, 33) = chi_mls_column_33
    output%chi_mls(:, 34) = chi_mls_column_34
    output%chi_mls(:, 35) = chi_mls_column_35
    output%chi_mls(:, 36) = chi_mls_column_36
    output%chi_mls(:, 37) = chi_mls_column_37
    output%chi_mls(:, 38) = chi_mls_column_38
    output%chi_mls(:, 39) = chi_mls_column_39
    output%chi_mls(:, 40) = chi_mls_column_40
    output%chi_mls(:, 41) = chi_mls_column_41
    output%chi_mls(:, 42) = chi_mls_column_42
    output%chi_mls(:, 43) = chi_mls_column_43
    output%chi_mls(:, 44) = chi_mls_column_44
    output%chi_mls(:, 45) = chi_mls_column_45
    output%chi_mls(:, 46) = chi_mls_column_46
    output%chi_mls(:, 47) = chi_mls_column_47
    output%chi_mls(:, 48) = chi_mls_column_48
    output%chi_mls(:, 49) = chi_mls_column_49
    output%chi_mls(:, 50) = chi_mls_column_50
    output%chi_mls(:, 51) = chi_mls_column_51
    output%chi_mls(:, 52) = chi_mls_column_52
    output%chi_mls(:, 53) = chi_mls_column_53
    output%chi_mls(:, 54) = chi_mls_column_54
    output%chi_mls(:, 55) = chi_mls_column_55
    output%chi_mls(:, 56) = chi_mls_column_56
    output%chi_mls(:, 57) = chi_mls_column_57
    output%chi_mls(:, 58) = chi_mls_column_58
    output%chi_mls(:, 59) = chi_mls_column_59
  end subroutine initialize_longwave_atmosphere_fields

end module longwave_reference_parameter_fields_mod
