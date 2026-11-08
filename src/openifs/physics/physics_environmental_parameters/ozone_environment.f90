!> Seasonal ozone coefficients and tabulated monthly ozone interpolation.
!! All pressures use pascals. Climatology arrays are native contiguous owners.
!! The caller establishes nearest-even rounding and gradual underflow.
module forecast_ozone_environment
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yoeozoc, only: teozoc
  implicit none
  private
  public :: update_yearly_ozone_cycle, update_ozone_climatology
  public :: update_yearly_ozone_record, update_ozone_record
  interface
    function public_cos(x) bind(C, name="cos") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_sin(x) bind(C, name="sin") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
  integer(int64), parameter :: ozone_coefficients_bits(360) = [ &
                               int(z'3faec80c73abc947', int64), int(z'3f129604b9a3245d', int64), int(z'3f4c15e03c155a04', int64), &
                               int(z'bf3214d57a1a7851', int64), int(z'bf2322f2734f82f5', int64), int(z'3f5eeaa6d2674081', int64), &
                               int(z'3ed4ad8c14cbbf06', int64), int(z'3f6947cfa26a22b4', int64), int(z'bf3239be67af3bc2', int64), &
                               int(z'3f366d29cf0662f1', int64), int(z'3f7e59f2ba9d1f60', int64), int(z'3f466094954dda7e', int64), &
                               int(z'3f4e6e80105b97d6', int64), int(z'bf1c7ebbc7c1cb11', int64), int(z'bf02808b2ac0f3d1', int64), &
                               int(z'3f504d551d68c693', int64), int(z'3f28dd46979405dc', int64), int(z'3f3243cf62a94284', int64), &
                               int(z'bf25677051a1b344', int64), int(z'3f2779994911c1c9', int64), int(z'bf575d13d74d594f', int64), &
                               int(z'3f12f14958e472b1', int64), int(z'3f27ef0a0e76bb48', int64), int(z'bf030413b5ea5d2b', int64), &
                               int(z'bf2920627616dd92', int64), int(z'bf2b287a728ce556', int64), int(z'bf32655d51eaae5f', int64), &
                               int(z'bf1a5f26d7045e34', int64), int(z'bf063d841a008739', int64), int(z'befad29437042325', int64), &
                               int(z'bf403bb766333ac0', int64), int(z'3f0a0e9eff342826', int64), int(z'3f1ca049b70336ec', int64), &
                               int(z'3ed95ac4f28dd18f', int64), int(z'3f11299e0914fc91', int64), int(z'3ee0aecedff776ef', int64), &
                               int(z'bf26fa1788b2c189', int64), int(z'bf2097fdb827235a', int64), int(z'bef1db74b0561e9b', int64), &
                               int(z'3f10c7a36d2cff12', int64), int(z'bf38413f65709d21', int64), int(z'bf148f5923ddaac1', int64), &
                               int(z'3f0c2a2d25272be9', int64), int(z'3f07eb0343ac522e', int64), int(z'3f0949522e760a1d', int64), &
                               int(z'3f059466d4cb48e9', int64), int(z'bf259d2036d72ca2', int64), int(z'bf1f24887584e75b', int64), &
                               int(z'bee529070a60562c', int64), int(z'3eddb66317c12b9e', int64), int(z'bf05d37be883b785', int64), &
                               int(z'bf1b2f306f339482', int64), int(z'bf01390d67c78f76', int64), int(z'3efbec6faa5ce056', int64), &
                               int(z'3efe5b34d9fc6038', int64), int(z'bf3338c1e86d3c43', int64), int(z'bf0952b75cf8ff5b', int64), &
                               int(z'bef2b234452c0415', int64), int(z'bef2ba41dac0d649', int64), int(z'bef05e47082740e2', int64), &
                               int(z'3ef6961987658f7c', int64), int(z'bf10868af40f5be9', int64), int(z'bec9511b0bdb3bb7', int64), &
                               int(z'3ef040bfe3b03e21', int64), int(z'3eab71b51ee73e16', int64), int(z'bf32abd42ec0ddab', int64), &
                               int(z'bf1cd5f99c38b04b', int64), int(z'bf16d482cea6ec93', int64), int(z'beaea6e7be734b5a', int64), &
                               int(z'3ee58f087112bcc6', int64), int(z'bf2506218230c748', int64), int(z'bf14d87f3290201e', int64), &
                               int(z'bf16d32b35b8c98b', int64), int(z'3ef8df49fcf93a69', int64), int(z'bee0143074ce1964', int64), &
                               int(z'bf1ba1463645366b', int64), int(z'3eebcee885e5dd95', int64), int(z'3f16a1821b4db946', int64), &
                               int(z'3eb27476ca61b882', int64), int(z'bed23b8e42f0b7db', int64), int(z'3f404c7e5dd3f0ad', int64), &
                               int(z'3efb40a3334b5bf4', int64), int(z'3f0281e2c3af16d9', int64), int(z'3ef81b54c5293f69', int64), &
                               int(z'3ede96cc9349a6f1', int64), int(z'3f1b724c4db66c38', int64), int(z'3ee4d0fb0d5a8f20', int64), &
                               int(z'3f097f0213ab837c', int64), int(z'3ed38a902b1fad33', int64), int(z'bed80de8cbdbe112', int64), &
                               int(z'3f15d178831e82f8', int64), int(z'bee3647200b49707', int64), int(z'3ed06dd8c2f1a414', int64), &
                               int(z'3ec4535a5648f31f', int64), int(z'3ee06ffe846ea8ef', int64), int(z'3f32d5c599d2a47d', int64), &
                               int(z'becd894a387fc5aa', int64), int(z'bf010cc2b1150b55', int64), int(z'3edeb4dd281feae8', int64), &
                               int(z'bec89a91cd589f0f', int64), int(z'3f2178ce47f70f96', int64), int(z'bef2aa26af9731e0', int64), &
                               int(z'be89fc0b9bedf15b', int64), int(z'3ee290619dbaf79e', int64), int(z'3eceeb9fee13e6b4', int64), &
                               int(z'3f3b97353b4b2fa9', int64), int(z'3f109a011d8c57e8', int64), int(z'bf1720580f35a803', int64), &
                               int(z'bf0348872d5b57ea', int64), int(z'bed3204341733ce4', int64), int(z'bf4f6d8391199857', int64), &
                               int(z'3f1e03f705857aff', int64), int(z'3f2193a63a91cc46', int64), int(z'bef74495305359ef', int64), &
                               int(z'bf0bbecd5abc392c', int64), int(z'3f326c134e915d8b', int64), int(z'3f1f3f60681fa40a', int64), &
                               int(z'3f003a09e7098ef5', int64), int(z'bf0481415e193ae5', int64), int(z'beea419fb28d5b73', int64), &
                               int(z'bf2d953c3cc730ac', int64), int(z'3f09de4d7db73aea', int64), int(z'3f15930f3bdd25e0', int64), &
                               int(z'bf070ee54b1de091', int64), int(z'3ef3660e51d25aab', int64), int(z'bf2673dfcbad121c', int64), &
                               int(z'3efc4d12ad56bacd', int64), int(z'3efcadb5b0509544', int64), int(z'bee7f310d9412463', int64), &
                               int(z'bef7d589b4ca21a2', int64), int(z'bf372fc76de83ae7', int64), int(z'3f035094c2f02a1f', int64), &
                               int(z'3ef1f8fbd4cd215b', int64), int(z'bee320ccb1d27e1a', int64), int(z'3edb7b280bda203f', int64), &
                               int(z'3f1cb46bacf74470', int64), int(z'bec417392c9c6b30', int64), int(z'bf18a8427ed59e02', int64), &
                               int(z'bef5163cad5a6bb1', int64), int(z'3eedd24deb1a6aba', int64), int(z'bf3cc532a497fa5d', int64), &
                               int(z'3ef571814c9bba05', int64), int(z'3ef40c7c652b52ea', int64), int(z'3e9f9d6fb61d1247', int64), &
                               int(z'bedb73a3e6a48f41', int64), int(z'bed78252ab1da582', int64), int(z'bf16c3bbd70636a6', int64), &
                               int(z'bf0c5271110f46f0', int64), int(z'becfaac0328a96c7', int64), int(z'3eaad63accbf11cc', int64), &
                               int(z'3f235f58552bab7f', int64), int(z'3f0bcae1bb1b747b', int64), int(z'3f02b8ea41d2b341', int64), &
                               int(z'3ed03715fcfda848', int64), int(z'3efdd4fd1cf6b0cc', int64), int(z'3f32abd42ec0ddab', int64), &
                               int(z'bed183f223af98c6', int64), int(z'3f046e770113506a', int64), int(z'3ef92a737110e454', int64), &
                               int(z'3efa2ed5558770f8', int64), int(z'3f367a95c853c148', int64), int(z'3f0582f410b38177', int64), &
                               int(z'3f07865975e80e9d', int64), int(z'3ef56c22e8e32de2', int64), int(z'3efdd24deb1a6aba', int64), &
                               int(z'3f159f239c3c612f', int64), int(z'3efd2e8f099db88d', int64), int(z'3f00249058275e69', int64), &
                               int(z'bebe9a0535852e39', int64), int(z'3e99ded6ee167c21', int64), int(z'3f22e68c91735a6b', int64), &
                               int(z'3ef2645b9f381419', int64), int(z'3f00c1993cfd616a', int64), int(z'bed74744622fa001', int64), &
                               int(z'beef2f453cf5ffa1', int64), int(z'beecd5f99c38b04b', int64), int(z'3ee7677ab882e8d3', int64), &
                               int(z'bec40ea226a857c5', int64), int(z'3ec5059811d18611', int64), int(z'3ec0642edc3f0e3b', int64), &
                               int(z'40a8bc0000000000', int64), int(z'c041400000000000', int64), int(z'404a147ae147ae14', int64), &
                               int(z'c0632ccccccccccd', int64), int(z'4022851eb851eb85', int64), int(z'4055a851eb851eb8', int64), &
                               int(z'406ad9999999999a', int64), int(z'406429999999999a', int64), int(z'c034f33333333333', int64), &
                               int(z'c0221c28f5c28f5c', int64), int(z'408d60cccccccccd', int64), int(z'4040e147ae147ae1', int64), &
                               int(z'40406b851eb851ec', int64), int(z'c059266666666666', int64), int(z'4015d70a3d70a3d7', int64), &
                               int(z'4033fd70a3d70a3d', int64), int(z'4050566666666666', int64), int(z'c0532ccccccccccd', int64), &
                               int(z'c01d8a3d70a3d70a', int64), int(z'c01e6978d4fdf3b6', int64), int(z'c076100000000000', int64), &
                               int(z'c02f47ae147ae148', int64), int(z'c023189374bc6a7f', int64), int(z'4014cfdf3b645a1d', int64), &
                               int(z'c040a51eb851eb85', int64), int(z'c0408e147ae147ae', int64), int(z'c0455d70a3d70a3d', int64), &
                               int(z'4030147ae147ae14', int64), int(z'3fee305532617c1c', int64), int(z'c024f5c28f5c28f6', int64), &
                               int(z'c04883d70a3d70a4', int64), int(z'40231b22d0e56042', int64), int(z'402475c28f5c28f6', int64), &
                               int(z'bfd868db8bac710d', int64), int(z'4022a7ef9db22d0e', int64), int(z'bfd9b22d0e560419', int64), &
                               int(z'c01296872b020c4a', int64), int(z'c025cccccccccccd', int64), int(z'c009666666666666', int64), &
                               int(z'40126353f7ced917', int64), int(z'c02aa8f5c28f5c29', int64), int(z'c01884189374bc6a', int64), &
                               int(z'4005fbe76c8b4396', int64), int(z'400aed916872b021', int64), int(z'400e9db22d0e5604', int64), &
                               int(z'4016b33333333333', int64), int(z'c01ae872b020c49c', int64), int(z'c00ec49ba5e353f8', int64), &
                               int(z'3fd59e83e425aee6', int64), int(z'c0099ba5e353f7cf', int64), int(z'401ce24dd2f1a9fc', int64), &
                               int(z'c01b0b4395810625', int64), int(z'c0108a3d70a3d70a', int64), int(z'3fd189374bc6a7f0', int64), &
                               int(z'3ffb53f7ced91687', int64), int(z'c03e028f5c28f5c3', int64), int(z'c003bc6a7ef9db23', int64), &
                               int(z'3ff4147ae147ae14', int64), int(z'c0055a1cac083127', int64), int(z'bff8c49ba5e353f8', int64), &
                               int(z'401e47ae147ae148', int64), int(z'c00172b020c49ba6', int64), int(z'bfa0e6afcce1c582', int64), &
                               int(z'3feb0be0ded288ce', int64), int(z'bfe1089a02752546', int64), int(z'c026d70a3d70a3d7', int64), &
                               int(z'c01571a9fbe76c8b', int64), int(z'c015178d4fdf3b64', int64), int(z'3fd6631f8a0902de', int64), &
                               int(z'40084fdf3b645a1d', int64), int(z'c02b4ccccccccccd', int64), int(z'c00328f5c28f5c29', int64), &
                               int(z'c01cfced916872b0', int64), int(z'400189374bc6a7f0', int64), int(z'3fe25e353f7ced91', int64), &
                               int(z'c02e0a3d70a3d70a', int64), int(z'3fe30be0ded288ce', int64), int(z'402bbd70a3d70a3d', int64), &
                               int(z'bfd9c0ebedfa43fe', int64), int(z'3fc15182a9930be1', int64), int(z'40488e147ae147ae', int64), &
                               int(z'4000d916872b020c', int64), int(z'4010bc6a7ef9db23', int64), int(z'3ff8b4395810624e', int64), &
                               int(z'c002d4fdf3b645a2', int64), int(z'402c800000000000', int64), int(z'bff5df3b645a1cac', int64), &
                               int(z'4019fae147ae147b', int64), int(z'bfdd5cfaacd9e83e', int64), int(z'3fd20902de00d1b7', int64), &
                               int(z'4021f74bc6a7ef9e', int64), int(z'c002cac083126e98', int64), int(z'40078d4fdf3b645a', int64), &
                               int(z'3fe664c2f837b4a2', int64), int(z'3ff1ced916872b02', int64), int(z'403ea3d70a3d70a4', int64), &
                               int(z'3fd69ad42c3c9eed', int64), int(z'bfff26e978d4fdf4', int64), int(z'3fe40aa64c2f837b', int64), &
                               int(z'bffe4189374bc6a8', int64), int(z'4030ee147ae147ae', int64), int(z'c0095a1cac083127', int64), &
                               int(z'3ff21cac083126e9', int64), int(z'3ff3a5e353f7ced9', int64), int(z'bfd3ac710cb295ea', int64), &
                               int(z'404527ae147ae148', int64), int(z'400fd0e560418937', int64), int(z'c033ae147ae147ae', int64), &
                               int(z'c00cb4395810624e', int64), int(z'c003916872b020c5', int64), int(z'c0527a3d70a3d70a', int64), &
                               int(z'401420c49ba5e354', int64), int(z'4027d70a3d70a3d7', int64), int(z'3fca92a305532618', int64), &
                               int(z'4010cbc6a7ef9db2', int64), int(z'402975c28f5c28f6', int64), int(z'4018e76c8b439581', int64), &
                               int(z'bff31a9fbe76c8b4', int64), int(z'c000b4395810624e', int64), int(z'c004916872b020c5', int64), &
                               int(z'4034dc28f5c28f5c', int64), int(z'bfd7333333333333', int64), int(z'3ff15810624dd2f2', int64), &
                               int(z'c010a2d0e5604189', int64), int(z'40206353f7ced917', int64), int(z'c02ff0a3d70a3d71', int64), &
                               int(z'bff5f7ced916872b', int64), int(z'4007916872b020c5', int64), int(z'3fccb923a29c779a', int64), &
                               int(z'3fdaeb1c432ca57a', int64), int(z'c041f47ae147ae14', int64), int(z'4012666666666666', int64), &
                               int(z'40050a3d70a3d70a', int64), int(z'bfe8cd9e83e425af', int64), int(z'400ed916872b020c', int64), &
                               int(z'40252e147ae147ae', int64), int(z'40113f7ced916873', int64), int(z'c0291eb851eb851f', int64), &
                               int(z'c005fdf3b645a1cb', int64), int(z'3ff28b4395810625', int64), int(z'c03bca3d70a3d70a', int64), &
                               int(z'40070e5604189375', int64), int(z'3ff651eb851eb852', int64), int(z'3fe72617c1bda512', int64), &
                               int(z'4004604189374bc7', int64), int(z'c01bb126e978d4fe', int64), int(z'c019676c8b439581', int64), &
                               int(z'c001c6a7ef9db22d', int64), int(z'3fdc189374bc6a7f', int64), int(z'bff50624dd2f1aa0', int64), &
                               int(z'402bf0a3d70a3d71', int64), int(z'4016ec8b43958106', int64), int(z'401374bc6a7ef9db', int64), &
                               int(z'bfc5119ce075f6fd', int64), int(z'4002a5e353f7ced9', int64), int(z'4037deb851eb851f', int64), &
                               int(z'c004978d4fdf3b64', int64), int(z'4019cccccccccccd', int64), int(z'3ffb333333333333', int64), &
                               int(z'3ff24dd2f1a9fbe7', int64), int(z'403cd47ae147ae14', int64), int(z'3fd4b4395810624e', int64), &
                               int(z'401645a1cac08312', int64), int(z'3ff0bc6a7ef9db23', int64), int(z'bfdc36113404ea4b', int64), &
                               int(z'40214083126e978d', int64), int(z'400672b020c49ba6', int64), int(z'40152b020c49ba5e', int64), &
                               int(z'bfe923a29c779a6b', int64), int(z'bfe5c01a36e2eb1c', int64), int(z'403011eb851eb852', int64), &
                               int(z'3fea068db8bac711', int64), int(z'4013810624dd2f1b', int64), int(z'bffa4dd2f1a9fbe7', int64), &
                               int(z'c004c8b439581062', int64), int(z'c0056872b020c49c', int64), int(z'40004189374bc6a8', int64), &
                               int(z'bfe840b780346dc6', int64), int(z'3fd0f27bb2fec56d', int64), int(z'3feca64c2f837b4a', int64)]
  real(real64), parameter :: ozone_coefficients(5, 72) = reshape(transfer(ozone_coefficients_bits, [0.0_real64], 360), [5, 72])
  integer(int64), parameter :: time_constants_bits(4) = [ &
                               int(z'4096800000000000', int64), int(z'4096b36dab9f559b', int64), int(z'40e5cc0000000000', int64), &
                               int(z'4120bb7000000000', int64)]
  real(real64), parameter :: time_constants(4) = transfer(time_constants_bits, [0.0_real64], 4)
  integer(int64), parameter :: month_day_offsets_bits(12) = [ &
                               int(z'403f000000000000', int64), int(z'404da00000000000', int64), int(z'4056900000000000', int64), &
                               int(z'405e100000000000', int64), int(z'4062e80000000000', int64), int(z'4066a80000000000', int64), &
                               int(z'406a880000000000', int64), int(z'406e680000000000', int64), int(z'4071140000000000', int64), &
                               int(z'4073040000000000', int64), int(z'4074e40000000000', int64), int(z'4076d40000000000', int64)]
  real(real64), parameter :: month_day_offsets(12) = transfer(month_day_offsets_bits, [0.0_real64], 12)
  integer(int64), parameter :: midpoints_bits(12) = [ &
                               int(z'40d5cc0000000000', int64), int(z'40efba8000000000', int64), int(z'40fa478000000000', int64), &
                               int(z'4102804000000000', int64), int(z'4107dcc000000000', int64), int(z'410d394000000000', int64), &
                               int(z'41114ae000000000', int64), int(z'4114046000000000', int64), int(z'4116b2a000000000', int64), &
                               int(z'411960e000000000', int64), int(z'411c0f2000000000', int64), int(z'411ebd6000000000', int64)]
  real(real64), parameter :: midpoints(12) = transfer(midpoints_bits, [0.0_real64], 12)
  integer(int64), parameter :: latitude_table_bits(19) = [ &
                               int(z'bff0000000000000', int64), int(z'bfef838b8c811c17', int64), int(z'bfee11f642522d1b', int64), &
                               int(z'bfebb67ae8584caa', int64), int(z'bfe8836fa2cf5039', int64), int(z'bfe491b7523c161c', int64), &
                               int(z'bfdfffffffffffff', int64), int(z'bfd5e3a8748a0bf5', int64), int(z'bfc63a1a7e0b7389', int64), &
                               int(z'0000000000000000', int64), int(z'3fc63a1a7e0b7389', int64), int(z'3fd5e3a8748a0bf5', int64), &
                               int(z'3fdfffffffffffff', int64), int(z'3fe491b7523c161c', int64), int(z'3fe8836fa2cf5039', int64), &
                               int(z'3febb67ae8584caa', int64), int(z'3fee11f642522d1b', int64), int(z'3fef838b8c811c17', int64), &
                               int(z'3ff0000000000000', int64)]
  real(real64), parameter :: latitude_table(19) = transfer(latitude_table_bits, [0.0_real64], 19)
  integer(int64), parameter :: perturbation_latitude_bits(9) = [ &
                               int(z'0000000000000000', int64), int(z'3fd87de2a6aea963', int64), int(z'3fe6a09e667f3bcc', int64), &
                               int(z'3fed906bcf328d46', int64), int(z'3ff0000000000000', int64), int(z'3fed906bcf328d46', int64), &
                               int(z'3fe6a09e667f3bcd', int64), int(z'3fd87de2a6aea965', int64), int(z'3ca1a62633145c07', int64)]
  real(real64), parameter :: perturbation_latitude(9) = transfer(perturbation_latitude_bits, [0.0_real64], 9)
  integer(int64), parameter :: perturbation_height_bits(7) = [ &
                               int(z'0000000000000000', int64), int(z'3fdfffffffffffff', int64), int(z'3febb67ae8584caa', int64), &
                               int(z'3ff0000000000000', int64), int(z'3febb67ae8584cab', int64), int(z'3fdfffffffffffff', int64), &
                               int(z'3ca1a62633145c07', int64)]
  real(real64), parameter :: perturbation_height(7) = transfer(perturbation_height_bits, [0.0_real64], 7)
contains
  !> Update only the four annual coefficient arrays of a native ozone record.
  subroutine update_yearly_ozone_record(phase, record, status)
    real(real64), intent(in) :: phase
    type(teozoc), intent(inout) :: record
    integer(int32), intent(out) :: status
    call update_yearly_ozone_cycle(phase, record%cozqc, record%cozqs, record%cozhc, record%cozhs, status)
  end subroutine

  !> Update native ROZT and RSINC while keeping the climatology owner read-only.
  !! Physical controls are supplied by the native radiation and constant owners.
  subroutine update_ozone_record(pi, conversion, amplitude, perturbation_mode, date, minutes, record, status)
    real(real64), intent(in) :: pi, conversion, amplitude
    integer(int32), intent(in) :: perturbation_mode, date, minutes
    type(teozoc), intent(inout) :: record
    integer(int32), intent(out) :: status
    status = 2
    if (.not. allocated(record%zozcl)) return
  call update_ozone_climatology(pi,conversion,amplitude,perturbation_mode,date,minutes,record%zozcl,record%rozt,record%rsinc,status)
  end subroutine

  !> Form all 72 SUECOZO coefficients from the annual phase in radians.
  !! qc/hc contain 21 values and qs/hs contain 15; unused tails stay unchanged.
  !! The four outputs are dimensioned in the canonical original coefficient order.
  subroutine update_yearly_ozone_cycle(phase, qc, qs, hc, hs, status)
    real(real64), intent(in) :: phase
    real(real64), intent(inout) :: qc(:), qs(:), hc(:), hs(:)
    integer(int32), intent(out) :: status
    real(real64) :: c, s, cc, ss, c2, s2, a, b, total, result(72)
    integer :: j
    status = 2
    if (.not. (abs(phase) <= 1048576.0_real64)) return
    if (size(qc) < 21 .or. size(qs) < 15 .or. size(hc) < 21 .or. size(hs) < 15) return
    c = public_cos(phase); s = public_sin(phase)
    cc = c*c; ss = s*s; c2 = cc - ss; s2 = 2.0_real64*s; s2 = s2*c
    do j = 1, 72
      a = ozone_coefficients(2, j)*c
      b = ozone_coefficients(3, j)*s
      total = a + b
      a = ozone_coefficients(4, j)*c2
      total = total + a
      a = ozone_coefficients(5, j)*s2
      total = total + a
      total = 2.0_real64*total
      result(j) = ozone_coefficients(1, j) + total
    end do
    qc(1:21) = result(1:21); qs(1:15) = result(22:36)
    hc(1:21) = result(37:57); hs(1:15) = result(58:72)
    status = 0
  end subroutine

  !> Update the original 19-latitude, 34-level ozone table from monthly data.
  !! climatology(latitude,level,month) is read-only. Ozone(:,0:) changes only
  !! rows1:19 and levels0:35. Latitude sine values1:19 are returned separately.
  !! conversion, amplitude and perturbation_mode are explicit source controls.
 subroutine update_ozone_climatology(pi,conversion,amplitude,perturbation_mode,date,minutes,climatology,ozone,latitude_sines,status)
    real(real64), intent(in) :: pi, conversion, amplitude
    integer(int32), intent(in) :: perturbation_mode, date, minutes
    real(real64), intent(in), contiguous :: climatology(:, :, :)
    real(real64), intent(inout), contiguous :: ozone(:, 0:), latitude_sines(:)
    integer(int32), intent(out) :: status
    integer(int32) :: year, month, day, ndays(12), day_index, month1, month2, start_level
    integer(int64) :: integer_time, remainder
    integer :: i, k
    real(real64) :: time, fraction, weight, a, b, v, latitude_amplitude, factor
    status = 2
    if (transfer(pi, 0_int64) /= int(z'400921fb54442d18', int64)) return
    if (size(climatology, 1) < 19 .or. size(climatology, 2) < 34 .or. size(climatology, 3) < 12) return
    if (size(ozone, 1) < 19 .or. ubound(ozone, 2) < 35 .or. size(latitude_sines) < 19) return
    year = date/10000; month = mod(date/100, 100); day = mod(date, 100)
    if (year < 1 .or. year > 9999 .or. month < 1 .or. month > 12 .or. minutes < 0) return
    ndays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if (mod(year, 4) == 0 .and. (mod(year, 100) /= 0 .or. mod(year, 400) == 0)) ndays(2) = 29
    if (day < 1 .or. day > ndays(month)) return
    day_index = day - 1
    if (month == 1) then
      time = real(day_index, real64)*time_constants(1)
    else if (month == 2) then
      if (day_index == 28) day_index = 27
      time = real(day_index, real64)*time_constants(2)
      time = time + time_constants(3)
    else
      time = month_day_offsets(month - 1) + real(day_index, real64)
      time = time*time_constants(1)
    end if
    time = time + real(minutes, real64)
    if (time >= 525960.0_real64) then
      integer_time = int(time, int64)
      fraction = time - real(integer_time, real64)
      remainder = integer_time - (integer_time/525960_int64)*525960_int64
      time = real(remainder, real64) + fraction
    end if
    month1 = 12; month2 = 1
    if (time <= midpoints(1)) then
      weight = midpoints(1) - time
      weight = weight/44640.0_real64
    else if (time > midpoints(12)) then
      weight = time_constants(4) - time
      weight = weight/44640.0_real64
    else
      do i = 1, 11
        if (time > midpoints(i) .and. time <= midpoints(i + 1)) then
          month1 = i; month2 = i + 1
          a = time - midpoints(i + 1)
          b = midpoints(i) - midpoints(i + 1)
          weight = a/b
          exit
        end if
      end do
    end if
    do k = 1, 34
      do i = 1, 19
        a = climatology(i, k, month1) - climatology(i, k, month2)
        b = weight*a
        v = climatology(i, k, month2) + b
        ozone(i, k) = v*conversion
      end do
    end do
    do i = 1, 19
      ozone(i, 0) = 0.0_real64
      ozone(i, 35) = ozone(i, 34)
    end do
    if (amplitude /= 0.0_real64) then
      start_level = 0
      if (perturbation_mode == 0) start_level = 23
      if (perturbation_mode == 1) start_level = 27
      if (start_level /= 0) then
        do i = 1, 9
          latitude_amplitude = amplitude*perturbation_latitude(i)
          do k = 1, 7
            factor = latitude_amplitude*perturbation_height(k)
            factor = 1.0_real64 + factor
            ozone(i + 5, start_level + k - 1) = ozone(i + 5, start_level + k - 1)*factor
          end do
        end do
      end if
    end if
    latitude_sines(1:19) = latitude_table
    status = 0
  end subroutine
end module
