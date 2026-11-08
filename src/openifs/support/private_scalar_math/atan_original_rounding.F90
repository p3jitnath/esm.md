! GNU libc2.38 IBM Accurate Math Library algorithm and coefficient literals.
! Copyright(C)2001-2023 Free Software Foundation, Inc.
! SPDX-License-Identifier: LGPL-2.1-or-later
!> Own the complete finite inverse tangent and its exact rounded helper graph.
module forecast_original_rounding_atan
  use iso_fortran_env, only: int64, real64
  use iso_c_binding, only: c_double
  use forecast_spline_scalar_inverse, only: rounded_product_sum
  use forecast_private_math_environment, only: require_private_math_environment
  implicit none
  private
  public :: original_rounding_atan, atan_polynomial, atan_table_polynomial, atan_table_index, atan_table, copy_original_sign
  interface
    subroutine public_abort() bind(C, name='abort')
    end subroutine
  end interface
  real(real64), parameter :: a = transfer(int(z'3e4bb67a00000000', int64), 0.0_real64)
  real(real64), parameter :: b = transfer(int(z'3fb0000000000000', int64), 0.0_real64)
  real(real64), parameter :: e = transfer(int(z'43349ff200000000', int64), 0.0_real64)
  real(real64), parameter :: d3 = transfer(int(z'bfd5555555555555', int64), 0.0_real64)
  real(real64), parameter :: d5 = transfer(int(z'3fc99999999997fd', int64), 0.0_real64)
  real(real64), parameter :: d7 = transfer(int(z'bfc24924923f7603', int64), 0.0_real64)
  real(real64), parameter :: d9 = transfer(int(z'3fbc71c6e5129a3b', int64), 0.0_real64)
  real(real64), parameter :: d11 = transfer(int(z'bfb7458022b13c25', int64), 0.0_real64)
  real(real64), parameter :: d13 = transfer(int(z'3fb375f08b31cbce', int64), 0.0_real64)
  real(real64), parameter :: hpi = transfer(int(z'3ff921fb54442d18', int64), 0.0_real64)
  real(real64), parameter :: hpi1 = transfer(int(z'3c91a62633145c07', int64), 0.0_real64)
  real(real64), parameter :: factor256 = transfer(int(z'4070000000000000', int64), 0.0_real64)
  real(real64), parameter :: two52 = transfer(int(z'4330000000000000', int64), 0.0_real64)
  real(real64), parameter :: minnormal = transfer(int(z'0010000000000000', int64), 0.0_real64)
  integer(int64), parameter :: table_words(1687) = [ &
   int(z'3fb0400665e0244e',int64), int(z'3fb03a737b53dd20',int64), int(z'3fefdf1fcf5cfb72',int64), int(z'bfb01eb3ce2ae4c2',int64), &
   int(z'bfd4d29edd58a40d',int64), int(z'3fafda4ad907a18a',int64), int(z'3fc814df4df65b18',int64), int(z'3fb0fffdb9b88cd8',int64), &
   int(z'3fb0f99c63645300',int64), int(z'3fefdc08a3ded30f',int64), int(z'bfb0d9dc669c1aed',int64), int(z'bfd4c669f7138de2',int64), &
   int(z'3fb0a12f29d085a7',int64), int(z'3fc7f0eecfd48d20',int64), int(z'3fb1fff15a73d4f1',int64), int(z'3fb1f85f2bee2040',int64), &
   int(z'3fefd7b342b56d31',int64), int(z'bfb1d2b7b69dea40',int64), int(z'bfd4b5523922ecc9',int64), int(z'3fb18f93522b1a04',int64), &
   int(z'3fc7bead5660f061',int64), int(z'3fb2fffdb2524aa2',int64), int(z'3fb2f716e71790a0',int64), int(z'3fefd31f53b496a4',int64), &
   int(z'bfb2cad84aab7374',int64), int(z'bfd4a34b58dd2fb2',int64), int(z'3fb27c0ad0cecc18',int64), int(z'3fc789d25d2743d7',int64), &
   int(z'3fb3fffe0573f3ac',int64), int(z'3fb3f59d1702f6a0',int64), int(z'3fefce4db071acc2',int64), int(z'bfb3c20f64db3686',int64), &
   int(z'bfd49059eb3bfe93',int64), int(z'3fb36659caf74fed',int64), int(z'3fc752691c011fb0',int64), int(z'3fb4ffef894384d6',int64), &
   int(z'3fb4f3ed0ce204c0',int64), int(z'3fefc93ea8ea5a01',int64), int(z'bfb4b84f7b5457c9',int64), int(z'bfd47c807401f2f9',int64), &
   int(z'3fb44e64b4f67209',int64), int(z'3fc7187d4c540b77',int64), int(z'3fb5fff8df406528',int64), int(z'3fb5f22b3c73d820',int64), &
   int(z'3fefc3f1b1f60f13',int64), int(z'bfb5adb2cb7fa73b',int64), int(z'bfd467be2b1eb555',int64), int(z'3fb5343599edc463',int64), &
   int(z'3fc6dc1b238f5059',int64), int(z'3fb7000f8c4f0d56',int64), int(z'3fb6f04b495a2fa0',int64), int(z'3fefbe67340dce97',int64), &
   int(z'bfb6a2244d98e1ad',int64), int(z'bfd4521614064df1',int64), int(z'3fb617aa2ba78a66',int64), int(z'3fc69d4f50a3d7ac',int64), &
   int(z'3fb8000fbb4057cf',int64), int(z'3fb7ee27be2cd3a0',int64), int(z'3fefb8a039ec9246',int64), int(z'bfb7957731d9c773',int64), &
   int(z'bfd43b8db6dc7d72',int64), int(z'3fb6f88ad69547df',int64), int(z'3fc65c26f633ce8c',int64), int(z'3fb8fff239cf2b7f',int64), &
   int(z'3fb8ebb79f979e80',int64), int(z'3fefb29d435506e1',int64), int(z'bfb8879a69b9cdb5',int64), int(z'bfd4242885feafa9',int64), &
   int(z'3fb7d6bab6191a0e',int64), int(z'3fc618afa7cb8bb5',int64), int(z'3fb9fff96e2f0772',int64), int(z'3fb9e93ad32a9480',int64), &
   int(z'3fefac5d04a3ec40',int64), int(z'bfb978c253f6ea97',int64), int(z'bfd40be3089c36f6',int64), int(z'3fb8b25c885aeb77',int64), &
   int(z'3fc5d2f763cadce1',int64), int(z'3fbb00026316b097',int64), int(z'3fbae68cce24cc00',int64), int(z'3fefa5e0938c5c66',int64), &
   int(z'bfba68c376f14e4b',int64), int(z'bfd3f2c31696cd7c',int64), int(z'3fb98b3b722a2cb4',int64), int(z'3fc58b0c9067ad62',int64), &
   int(z'3fbc0008604f58b1',int64), int(z'3fbbe3a705650780',int64), int(z'3fef9f285a7a2773',int64), int(z'bfbb578f3d5ac0a4',int64), &
   int(z'bfd3d8cbf767119f',int64), int(z'3fba613dc7e31b88',int64), int(z'3fc540fdf5594565',int64), int(z'3fbd00026cca4eba',int64), &
   int(z'3fbce07ec1298a80',int64), int(z'3fef9834e8d36c4a',int64), int(z'bfbc45135bcac5fe',int64), int(z'bfd3be018b5236f1',int64), &
   int(z'3fbb34472e991970',int64), int(z'3fc4f4dab8adb373',int64), int(z'3fbdfff4b2b47fca',int64), int(z'3fbddd164a051d80',int64), &
   int(z'3fef910678dcc895',int64), int(z'bfbd3149f0966844',int64), int(z'bfd3a266744f9a5f',int64), int(z'3fbc0446edb7f27a',int64), &
   int(z'3fc4a6b2583f9eca',int64), int(z'3fbf000aa9a05be0',int64), int(z'3fbed996a3bda540',int64), int(z'3fef899c1b8ba97f',int64), &
   int(z'bfbe1c512287a677',int64), int(z'bfd385f8edc130bb',int64), int(z'3fbcd14bf306ff50',int64), int(z'3fc45694a667a72b',int64), &
   int(z'3fbffffaba8f63de',int64), int(z'3fbfd5b569fe4780',int64), int(z'3fef81f84863dc7d',int64), int(z'bfbf05dbd1518706',int64), &
   int(z'bfd368c44687a69c',int64), int(z'3fbd9b081b3868da',int64), int(z'3fc40491c345adfc',int64), int(z'3fc07ffa6eccada8',int64), &
   int(z'3fc068d00a396400',int64), int(z'3fef7a19f1fcfc6b',int64), int(z'bfbfee0c861df0df',int64), int(z'bfd34ac65a586c0c',int64), &
   int(z'3fbe618f189d637a',int64), int(z'3fc3b0ba195779d4',int64), int(z'3fc1000333432713',int64), int(z'3fc0e6b0f203d1a0',int64), &
   int(z'3fef7200fe0eb463',int64), int(z'bfc06a72e15cb19a',int64), int(z'bfd32c00b8db761e',int64), int(z'3fbf24d8a11f5e3e',int64), &
   int(z'3fc35b1e569e85dd',int64), int(z'3fc17ffcda1c4811',int64), int(z'3fc1646229ebda00',int64), int(z'3fef69af7d558737',int64), &
   int(z'bfc0dd170b33969b',int64), int(z'bfd30c7d33ac50d1',int64), int(z'3fbfe4aa9be43f0f',int64), int(z'3fc303cf692539cb',int64), &
   int(z'3fc1ffff3cca418d',int64), int(z'3fc1e1fa3b978ea0',int64), int(z'3fef612445d421a9',int64), int(z'bfc14f03acac8aa8',int64), &
   int(z'bfd2ec3962e675a3',int64), int(z'3fc0508c2fa6b426',int64), int(z'3fc2aade780a6467',int64), int(z'3fc27ff7d9c78922',int64), &
   int(z'3fc25f661b91e640',int64), int(z'3fef5860f52e192c',int64), int(z'bfc1c023e5de2394',int64), int(z'bfd2cb3d6bee0abd',int64), &
   int(z'3fc0acfb5e075c1a',int64), int(z'3fc2505cdffe453a',int64), int(z'3fc2fff7a1fc1aaa',int64), int(z'3fc2dcb583257c40',int64), &
   int(z'3fef4f64c719b6fb',int64), int(z'bfc2308261514083',int64), int(z'bfd2a9887f7b72d5',int64), int(z'3fc107a77c887402',int64), &
   int(z'3fc1f45c2c3cd6d1',int64), int(z'3fc380059d78e15e',int64), int(z'3fc359ee6ac98ee0',int64), int(z'3fef462f944cec16',int64), &
   int(z'bfc2a020d85b87a9',int64), int(z'bfd2871c2e4ab369',int64), int(z'3fc1608dc31a65d9',int64), int(z'3fc196ee130bbe50',int64), &
   int(z'3fc400049f431b1a',int64), int(z'3fc3d6f36bd65360',int64), int(z'3fef3cc3dd99b68a',int64), int(z'bfc30ee1b3dd00ed',int64), &
   int(z'bfd26403f8482664',int64), int(z'3fc1b792fe136626',int64), int(z'3fc138246eac7440',int64), int(z'3fc48004e01d95a1',int64), &
   int(z'3fc453d386f00cc0',int64), int(z'3fef3320e3970539',int64), int(z'bfc37ccf0a5279aa',int64), int(z'bfd2403f3b151d5d',int64), &
   int(z'3fc20cbbe331c9e6',int64), int(z'3fc0d81139e3f097',int64), int(z'3fc4fff7aa9382dd',int64), int(z'3fc4d07f8c590a80',int64), &
   int(z'3fef294834df28e0',int64), int(z'bfc3e9d85b43915c',int64), int(z'bfd21bd5eb8845a2',int64), int(z'3fc25ff8ac6ac8ad',int64), &
   int(z'3fc076c688ed96ca',int64), int(z'3fc58006352408be',int64), int(z'3fc54d1ec39a73e0',int64), int(z'3fef1f3709ae009c',int64), &
   int(z'bfc4561cb9be8550',int64), int(z'bfd1f6c00053f52e',int64), int(z'3fc2b15def783be9',int64), int(z'3fc014568615239b',int64), &
   int(z'3fc5ffff2b193f81',int64), int(z'3fc5c9804f73e000',int64), int(z'3fef14f1ae110e29',int64), int(z'bfc4c16e9098b3d2',int64), &
   int(z'bfd1d10f8f058241',int64), int(z'3fc300c6a14fa897',int64), int(z'3fbf61a6d56607c0',int64), int(z'3fc680084460e6e1',int64), &
   int(z'3fc645c804a55e20',int64), int(z'3fef0a758fa36ec5',int64), int(z'bfc52be9d62fa883',int64), int(z'bfd1aabd69a74048',int64), &
   int(z'3fc34e451679eb02',int64), int(z'3fbe989ef7c14c3d',int64), int(z'3fc6fffb9e99a846',int64), int(z'3fc6c1d04b35fd40',int64), &
   int(z'3feeffc63ef8ef95',int64), int(z'bfc5956b76a2fe63',int64), int(z'bfd183d8ddc78ddf',int64), int(z'3fc399bdac606d66',int64), &
   int(z'3fbdcdba070d286a',int64), int(z'3fc780080ffcd490',int64), int(z'3fc73dc5b55758e0',int64), int(z'3feef4e0457e2065',int64), &
   int(z'bfc5fe167d6ff9bc',int64), int(z'bfd15c579fadd384',int64), int(z'3fc3e34773e52d32',int64), int(z'3fbd011c9a65ae4b',int64), &
   int(z'3fc80006148e79c1',int64), int(z'3fc7b9812b7f8ca0',int64), int(z'3feee9c7701687ed',int64), int(z'bfc665c70e1ef36d',int64), &
   int(z'bfd13449ccbcbdab',int64), int(z'3fc42ac75c71b3e8',int64), int(z'3fbc32eb3e81980e',int64), int(z'3fc880060f487c17',int64), &
   int(z'3fc83511bc0e3640',int64), int(z'3feede7ad2d55329',int64), int(z'bfc6cc8737e644ba',int64), int(z'bfd10bae60597557',int64), &
   int(z'3fc4704313e26fbe',int64), int(z'3fbb634a6fb18bf4',int64), int(z'3fc90004d3518d76',int64), int(z'3fc8b0738874c100',int64), &
   int(z'3feed2fb2ed6673b',int64), int(z'bfc732512a6ebac3',int64), int(z'bfd0e28a6924232f',int64), int(z'3fc4b3b573bcc03f',int64), &
   int(z'3fba925e8c72507f',int64), int(z'3fc97fffd2f20d5c',int64), int(z'3fc92ba351af5920',int64), int(z'3feec7493d32449f',int64), &
   int(z'bfc7971fc308255f',int64), int(z'bfd0b8e2d572d28f',int64), int(z'3fc4f51a337448fe',int64), int(z'3fb9c04bcfcbc620',int64), &
   int(z'3fca0005bf80f060',int64), int(z'3fc9a6ae6e9e8960',int64), int(z'3feebb641ef200e7',int64), int(z'bfc7fafb6e96e5c1',int64), &
   int(z'bfd08eb6ec6ad647',int64), int(z'3fc53475f53d0ba6',int64), int(z'3fb8ed364433c20e',int64), int(z'3fca7ff7deeca8e4',int64), &
   int(z'3fca2176948578e0',int64), int(z'3feeaf4f328ff98b',int64), int(z'bfc85dc958149b1c',int64), int(z'bfd06414f933a1ab',int64), &
   int(z'3fc571b760c45a8f',int64), int(z'3fb81941be58c308',int64), int(z'3fcaffff7defd553',int64), int(z'3fca9c229eba6b80',int64), &
   int(z'3feea30710a85e10',int64), int(z'bfc8bfa67f9dea61',int64), int(z'bfd038f35a474e8f',int64), int(z'3fc5acf030c225d2',int64), &
   int(z'3fb74491d062812f',int64), int(z'3fcb7ffe669932a5',int64), int(z'3fcb1694cff6dfe0',int64), int(z'3fee968f1921d387',int64), &
   int(z'bfc92078e075d95a',int64), int(z'bfd00d60526793c4',int64), int(z'3fc5e61073842a52',int64), int(z'3fb66f49c5331d5a',int64), &
   int(z'3fcbfff9b44759f3',int64), int(z'3fcb90d15073a2a0',int64), int(z'3fee89e756598313',int64), int(z'bfc98041cfb9203d',int64), &
   int(z'bfcfc2bcbed91b37',int64), int(z'3fc61d196d4fc2fc',int64), int(z'3fb5998c9411537e',int64), int(z'3fcc80075568f3ec',int64), &
   int(z'3fcc0aec4a31dbe0',int64), int(z'3fee7d0e18f270a8',int64), int(z'bfc9df0ef522b132',int64), int(z'bfcf69d42179c242',int64), &
   int(z'3fc6521336646fcd',int64), int(z'3fb4c37cdc699095',int64), int(z'3fccfff8601a799f',int64), int(z'3fcc84b849db66a0',int64), &
   int(z'3fee7008a0ee780e',int64), int(z'bfca3cbb3a403934',int64), int(z'bfcf102fd490be32',int64), int(z'3fc684ea037d4137',int64), &
   int(z'3fb3ed3cd9ec855a',int64), int(z'3fcd7ff97bbf1497',int64), int(z'3fccfe5f1e008ce0',int64), int(z'3fee62d2f04615c7',int64), &
   int(z'bfca996515aade2c',int64), int(z'bfceb5b90b44b682',int64), int(z'3fc6b5af92ec8d57',int64), int(z'3fb316ee60d831ae',int64), &
   int(z'3fce000840209b20',int64), int(z'3fcd77ddb145a760',int64), int(z'3fee556dbe1dfdf1',int64), int(z'bfcaf5082186af0f',int64), &
   int(z'bfce5a799420489d',int64), int(z'3fc6e462454feb2c',int64), int(z'3fb240b2d2945a8c',int64), int(z'3fce8000c0ae943c',int64), &
   int(z'3fcdf1113ca10100',int64), int(z'3fee47dd59e7308b',int64), int(z'bfcb4f889439f69f',int64), int(z'bfcdfe93798de600',int64), &
   int(z'3fc710f58f267389',int64), int(z'3fb16aab1a8a373e',int64), int(z'3fcf00036d532803',int64), int(z'3fce6a17cb4e5c80',int64), &
   int(z'3fee3a1ee3d0f6c2',int64), int(z'bfcba8fb6e31f768',int64), int(z'bfcda1f7e6a382e3',int64), int(z'3fc73b75b36ac4c0',int64), &
   int(z'3fb094f7a3470b0a',int64), int(z'3fcf7ffa48b8afc3',int64), int(z'3fcee2dbe1654560',int64), int(z'3fee2c3543f2ab37',int64), &
   int(z'bfcc014f598207d6',int64), int(z'bfcd44bf1efe809a',int64), int(z'3fc763dc698a561e',int64), int(z'3faf7f70a7cf78a3',int64), &
   int(z'3fd00002eb334fae',int64), int(z'3fcf5b7b77ab25e0',int64), int(z'3fee1e1d78a5c127',int64), int(z'bfcc5898c555d571',int64), &
   int(z'bfcce6d9b706cf86',int64), int(z'3fc78a350823f643',int64), int(z'3fadd6190b9118e8',int64), int(z'3fd03ffca8af86fe',int64), &
   int(z'3fcfd3cbb53a0c00',int64), int(z'3fee0fdcfdcbac8b',int64), int(z'bfccaeb76c3246ff',int64), int(z'bfcc8870d6e19ad3',int64), &
   int(z'3fc7ae73d2c48e91',int64), int(z'3fac2e260510fdb0',int64), int(z'3fd07ffcd38984b7',int64), int(z'3fd025f75732d4a0',int64), &
   int(z'3fee017049c17ab3',int64), int(z'bfcd03c29afe5028',int64), int(z'bfcc29719a2c1833',int64), int(z'3fc7d0a569041dcf',int64), &
   int(z'3faa87d3f497c653',int64), int(z'3fd0bfff1ed2add7',int64), int(z'3fd061edcd7f7420',int64), int(z'3fedf2d8da96b750',int64), &
   int(z'bfcd57b2c777881e',int64), int(z'bfcbc9ea8692b503',int64), int(z'3fc7f0c942abf9e7',int64), int(z'3fa8e35e04b42bb4',int64), &
   int(z'3fd10003a8515cda',int64), int(z'3fd09dc9027416a0',int64), int(z'3fede41734899950',int64), int(z'bfcdaa867983ede4',int64), &
   int(z'bfcb69e3999706b6',int64), int(z'3fc80ee1b0f126db',int64), int(z'3fa740fe17ee9bab',int64), int(z'3fd14001f3af9cc5',int64), &
   int(z'3fd0d980b6e1aba0',int64), int(z'3fedd52de0412681',int64), int(z'bfcdfc316863b28b',int64), int(z'bfcb0971c55b8d5a',int64), &
   int(z'3fc82aeda6731aac',int64), int(z'3fa5a0ecc73bd8f0',int64), int(z'3fd18003b6122509',int64), int(z'3fd1151daa1e67a0',int64), &
   int(z'3fedc61b2e0c1f32',int64), int(z'bfce4cbeb9ba6b7e',int64), int(z'bfcaa88e90c2431c',int64), int(z'3fc844f48bcbda5e',int64), &
   int(z'3fa4036150e585ff',int64), int(z'3fd1bfffa6a2a153',int64), int(z'3fd15096e7a18dc0',int64), int(z'3fedb6e1e1218f3f',int64), &
   int(z'bfce9c219621d6a2',int64), int(z'bfca475022627b04',int64), int(z'3fc85cf5ff8b908e',int64), int(z'3fa268919833c0d6',int64), &
   int(z'3fd1fffd2d345aaf',int64), int(z'3fd18bf3053bf760',int64), int(z'3feda780cc3acb29',int64), int(z'bfceea622aa756ae',int64), &
   int(z'bfc9e5b347ed9793',int64), int(z'3fc872f887ab542a',int64), int(z'3fa0d0b2158e9e9a',int64), int(z'3fd23ffcf14cf05a',int64), &
   int(z'3fd1c7324d568460',int64), int(z'3fed97f855f32d3d',int64), int(z'bfcf378021d457c8',int64), int(z'bfc983bef065b845',int64), &
   int(z'3fc886fffba70cd8',int64), int(z'3f9e77ebaeb85ccc',int64), int(z'3fd27ffe0bae6fc9',int64), int(z'3fd202539a27c160',int64), &
   int(z'3fed88494619176e',int64), int(z'bfcf83795c0ac9ec',int64), int(z'bfc9217c5e645195',int64), int(z'3fc8990ff4264515',int64), &
   int(z'3f9b551ce6b92e65',int64), int(z'3fd2c001a297a7de',int64), int(z'3fd23d57acb927c0',int64), int(z'3fed7873e4958fb6',int64), &
   int(z'bfcfce4e43572249',int64), int(z'bfc8bef19f3560f3',int64), int(z'3fc8a92cdf7f0e5b',int64), int(z'3f983958116f3b19',int64), &
   int(z'3fd2fffe7267616a',int64), int(z'3fd27835b2f378c0',int64), int(z'3fed687b13906586',int64), int(z'bfd00bf9afda1a0f',int64), &
   int(z'bfc85c34c197ad7d',int64), int(z'3fc8b7591e99f0a7',int64), int(z'3f9524fa6525c365',int64), int(z'3fd33ffe48153b20',int64), &
   int(z'3fd2b2f66a2fdcc0',int64), int(z'3fed585cf827fbe4',int64), int(z'bfd03039b45a6918',int64), int(z'bfc7f93e5dfc3f72',int64), &
   int(z'3fc8c39bc5210022',int64), int(z'3f92185e168fb62e',int64), int(z'3fd380038122579a',int64), int(z'3fd2ed9baf6ec1e0',int64), &
   int(z'3fed4819872f20d3',int64), int(z'bfd053e81f4c1031',int64), int(z'bfc79612621ffd79',int64), int(z'3fc8cdf9db9d9dfc',int64), &
   int(z'3f8e27b480c6852f',int64), int(z'3fd3c0033ef39141',int64), int(z'3fd3281b4668c700',int64), int(z'3fed37b418590d1a',int64), &
   int(z'bfd076fea3ef2560',int64), int(z'bfc732c93033287a',int64), int(z'3fc8d676ca2e5458',int64), int(z'3f882f85d80944b1',int64), &
   int(z'3fd4000163fa0e31',int64), int(z'3fd362787b565000',int64), int(z'3fed272c47a813da',int64), int(z'bfd0997f493b9d88',int64), &
   int(z'bfc6cf643da9fe3c',int64), int(z'3fc8dd18c1cd3331',int64), int(z'3f8248d1f70f6e07',int64), int(z'3fd4400374071092',int64), &
   int(z'3fd39cb80f0a4000',int64), int(z'3fed16813ba47a6b',int64), int(z'bfd0bb6cd8788947',int64), int(z'bfc66be2589596a6',int64), &
   int(z'3fc8e1e5c9b3ec1e',int64), int(z'3f78e868d20fab86',int64), int(z'3fd48000c880f200',int64), int(z'3fd3d6d1deffb460',int64), &
   int(z'3fed05b5cadc576c',int64), int(z'bfd0dcc2a1d352c2',int64), int(z'bfc608583d7d2574',int64), int(z'3fc8e4e303208bc0',int64), &
   int(z'3f6ac9096379e732',int64), int(z'3fd4c0004d97d2cb',int64), int(z'3fd410cbf3a2e220',int64), int(z'3fecf4c8bb7ed511',int64), &
   int(z'bfd0fd8437766a49',int64), int(z'bfc5a4c25aabc13c',int64), int(z'3fc8e616c80dac4b',int64), int(z'3f4038aab04695c2',int64), &
   int(z'3fd4fffd9397539f',int64), int(z'3fd44aa206a7dec0',int64), int(z'3fece3bbcf479dde',int64), int(z'bfd11daf4d122984',int64), &
   int(z'bfc5412eb1024df0',int64), int(z'3fc8e5871b2c560d',int64), int(z'bf625da8951c088d',int64), int(z'3fd53ffff304715f',int64), &
   int(z'3fd4845a791f3900',int64), int(z'3fecd28da45e0fd8',int64), int(z'bfd13d478d61f221',int64), int(z'bfc4dd98d3e9bb99',int64), &
   int(z'3fc8e33a0f181507',int64), int(z'bf743c33d08bd25c',int64), int(z'3fd58002e88ea386',int64), int(z'3fd4bdf0f575d6c0',int64), &
   int(z'3fecc14002035609',int64), int(z'bfd15c4ab808071e',int64), int(z'bfc47a0eb2945fcf',int64), int(z'3fc8df35fc056447',int64), &
   int(z'bf7f2011b00a45cd',int64), int(z'3fd5bffd70f4d590',int64), int(z'3fd4f75d284d7ae0',int64), int(z'3fecafd5f2de98b6',int64), &
   int(z'bfd17ab4a2b42f42',int64), int(z'bfc416a51c285a92',int64), int(z'3fc8d982511d6c5a',int64), int(z'bf84ecc177008605',int64), &
   int(z'3fd5fffdb70d6e53',int64), int(z'3fd530ab8e2ff500',int64), int(z'3fec9e4c32d2429d',int64), int(z'bfd1988c35190681',int64), &
   int(z'bfc3b34cbf748319',int64), int(z'3fc8d22498d3a613',int64), int(z'bf8a33d4aa295f9f',int64), int(z'3fd63ffc5c7399e2',int64), &
   int(z'3fd569d54f022e80',int64), int(z'3fec8ca558dd180f',int64), int(z'bfd1b5ce1d701de4',int64), int(z'bfc35017a7806a5a',int64), &
   int(z'3fc8c92456c01cf9',int64), int(z'bf8f64d9942059e1',int64), int(z'3fd67ffd9a1ac7d2',int64), int(z'3fd5a2ddf50031e0',int64), &
   int(z'3fec7ae0ceff6deb',int64), int(z'bfd1d27c7c8c245b',int64), int(z'bfc2ed05c6aa933f',int64), int(z'3fc8be87ddc5cf1f',int64), &
   int(z'bf923fb6d594386f',int64), int(z'3fd6bffd6f7b9353',int64), int(z'3fd5dbc1b4e066c0',int64), int(z'3fec6900456b591a',int64), &
   int(z'bfd1ee95c2d6d0aa',int64), int(z'bfc28a23b11086f7',int64), int(z'3fc8b256dde22d5a',int64), int(z'bf94c19a489d85a4',int64), &
   int(z'3fd6fffbf02a83e4',int64), int(z'3fd614806a237dc0',int64), int(z'3fec57044cc81773',int64), int(z'bfd20a1a4b9029ca',int64), &
   int(z'bfc2277789f5fb1c',int64), int(z'3fc8a4989b09e911',int64), int(z'bf9737ec130d419a',int64), int(z'3fd73ffe128c213a',int64), &
   int(z'3fd64d1e42499480',int64), int(z'3fec44ec129c0d30',int64), int(z'bfd2250c83787259',int64), int(z'bfc1c4ffd55be4fc',int64), &
   int(z'3fc8955336b2d603',int64), int(z'bf99a2842e43df46',int64), int(z'3fd77ffbea0cdc7a',int64), int(z'3fd6859405b0e220',int64), &
   int(z'3fec32ba687132c0',int64), int(z'bfd23f697273497e',int64), int(z'bfc162cecd39b037',int64), int(z'3fc8848ffa930aaf',int64), &
   int(z'bf9c013da4554412',int64), int(z'3fd7c003f18edab8',int64), int(z'3fd6bdee4127bee0',int64), int(z'3fec206bc01607bd',int64), &
   int(z'bfd259375fee2f42',int64), int(z'bfc100d4307761e1',int64), int(z'3fc872525dfec556',int64), int(z'bf9e53f67958f973',int64), &
   int(z'3fd7fffd41f35c4c',int64), int(z'3fd6f616da6607a0',int64), int(z'3fec0e07cddc8437',int64), int(z'bfd2726cbfb4daea',int64), &
   int(z'bfc09f3be0db1472',int64), int(z'3fc85ea92a95aa1b',int64), int(z'bfa04d47d872cfa2',int64), int(z'3fd8400326c7c46b',int64), &
   int(z'3fd72e2596b8be00',int64), int(z'3febfb874cdedf38',int64), int(z'bfd28b14d09404f3',int64), int(z'bfc03de1e7fb61f2',int64), &
   int(z'3fc84993acb33be9',int64), int(z'bfa16a769b1de607',int64), int(z'3fd88003ca90b179',int64), int(z'3fd7660aa104a220',int64), &
   int(z'3febe8eff236e2f6',int64), int(z'bfd2a32919a94ddf',int64), int(z'bfbfb9ce0856a081',int64), int(z'3fc8331f33f70280',int64), &
   int(z'bfa2817af01308cc',int64), int(z'3fd8c003e9692fd5',int64), int(z'3fd79dc9f0b2cb00',int64), int(z'3febd640f2966495',int64), &
   int(z'bfd2baabfd6ec2ea',int64), int(z'bfbef892e08e9c2d',int64), int(z'3fc81b52031873e3',int64), int(z'bfa39249ac12113d',int64), &
   int(z'3fd8fffe35be5c5f',int64), int(z'3fd7d55ebdccdfc0',int64), int(z'3febc37c6eabcf77',int64), int(z'bfd2d19c2d74f445',int64), &
   int(z'bfbe382ce63f2cdb',int64), int(z'3fc802360e6fe2ae',int64), int(z'bfa49cd90e66ab41',int64), int(z'3fd94002aa8974cd',int64), &
   int(z'3fd80cd6b8afd880',int64), int(z'3febb09e4468ccba',int64), int(z'bfd2e7ffec84e686',int64), int(z'bfbd787688c659e8',int64), &
   int(z'3fc7e7ccc2f15460',int64), int(z'bfa5a120b410d3ed',int64), int(z'3fd98002e08efdea',int64), int(z'3fd8442534856920',int64), &
   int(z'3feb9dab3f290478',int64), int(z'bfd2fdd2bb81edef',int64), int(z'bfbcb9a531e68398',int64), int(z'3fc7cc23c2dbb11b',int64), &
   int(z'bfa69f1998467e78',int64), int(z'3fd9c00275294b6b',int64), int(z'3fd87b4d299f6200',int64), int(z'3feb8aa2de96cf1f',int64), &
   int(z'bfd313168c4d45d2',int64), int(z'bfbbfbb7edce4dba',int64), int(z'3fc7af418907fec9',int64), int(z'bfa796be07419f55',int64), &
   int(z'3fda0002f3e490ec',int64), int(z'3fd8b24fc21a4500',int64), int(z'3feb77853b5ef7dd',int64), int(z'bfd327cc8eae70cd',int64), &
   int(z'bfbb3eb3d49e40da',int64), int(z'3fc7912d4d93f7ea',int64), int(z'bfa888099e21606a',int64), int(z'3fda3fff458461b6',int64), &
   int(z'3fd8e9287754d2c0',int64), int(z'3feb64546a0daf0e',int64), int(z'bfd33bf3dc2a9a3f',int64), int(z'bfba82b14917d003',int64), &
   int(z'3fc771f17c7566cf',int64), int(z'bfa972f93d700dd8',int64), int(z'3fda800287e12aae',int64), int(z'3fd91fe0a5dfd000',int64), &
   int(z'3feb510da0d82e05',int64), int(z'bfd34f90a76ad312',int64), int(z'bfb9c798deec35ad',int64), int(z'3fc751908a0ef43e',int64), &
   int(z'bfaa578b0872efc8',int64), int(z'3fdac00149a86c84',int64), int(z'3fd9566e5c4516e0',int64), int(z'3feb3db4dd03f6b6',int64), &
   int(z'bfd362a0291c1f82',int64), int(z'bfb90d9503f6df60',int64), int(z'3fc7301825091e92',int64), int(z'bfab35be577a022b',int64), &
   int(z'3fdaffff2f4cc2e1',int64), int(z'3fd98cd494226540',int64), int(z'3feb2a499297200a',int64), int(z'bfd375245153fd01',int64), &
   int(z'bfb854a3ae3de27e',int64), int(z'3fc70d8e7eb3f331',int64), int(z'bfac0d93b6ad570e',int64), int(z'3fdb4000c2f3711e',int64), &
   int(z'3fd9c31701cdc4c0',int64), int(z'3feb16caea63781b',int64), int(z'bfd3871f3665b649',int64), int(z'bfb79cc03f70fbc6',int64), &
   int(z'3fc6e9f9061dfc2e',int64), int(z'bfacdf0cd837f9c3',int64), int(z'3fdb8000a777e180',int64), int(z'3fd9f930f3748f20',int64), &
   int(z'3feb033b0fb0162a',int64), int(z'bfd3989025978cab',int64), int(z'bfb6e6025c765aab',int64), int(z'3fc6c5629c16d678',int64), &
   int(z'bfadaa2c92a16ebf',int64), int(z'3fdbbffd087e14ed',int64), int(z'3fda2f20bf0ddb00',int64), int(z'3feaef9b1cce6e94',int64), &
   int(z'bfd3a9778b73e3c3',int64), int(z'bfb6307709efd1cc',int64), int(z'3fc69fd458408d3a',int64), int(z'bfae6ef6d2e48013',int64), &
   int(z'3fdc0000f0086783',int64), int(z'3fda64ef8d448080',int64), int(z'3feadbe835990b5a',int64), int(z'bfd3b9d927241b86',int64), &
   int(z'bfb57c06c20e4001',int64), int(z'3fc6794f90e6c8ab',int64), int(z'bfaf2d709a630a27',int64), int(z'3fdc4001863e58f8',int64), &
   int(z'3fda9a941c3a1ba0',int64), int(z'3feac82635ed7dd2',int64), int(z'bfd3c9b30c075b50',int64), int(z'bfb4c8d7a429793c',int64), &
   int(z'3fc651e295903c22',int64), int(z'bfafe59ff0f8b649',int64), int(z'3fdc7ffc6c62c3bf',int64), int(z'3fdad00c580a5840',int64), &
   int(z'3feab45662d1d808',int64), int(z'bfd3d905acbb06ec',int64), int(z'bfb416f7421e42dc',int64), int(z'3fc62996e5608efd',int64), &
   int(z'bfb04bc5f14b649a',int64), int(z'3fdcc00234b2a209',int64), int(z'3fdb0565f68f3b40',int64), int(z'3feaa0741e3dc946',int64), &
   int(z'bfd3e7d5e2db674e',int64), int(z'bfb3663ea4833ffe',int64), int(z'3fc60069c4f0392b',int64), int(z'bfb0a19e38b10201',int64), &
   int(z'3fdcfffcaac5f9f9',int64), int(z'3fdb3a8e59c45cc0',int64), int(z'3fea8c86d2389c24',int64), int(z'bfd3f61f8362b2cb',int64), &
   int(z'bfb2b6f1c6c746a6',int64), int(z'3fc5d671426d2946',int64), int(z'bfb0f45d4981ce75',int64), int(z'3fdd40040d800c64',int64), &
   int(z'3fdb6f9988af6580',int64), int(z'3fea78877498ced2',int64), int(z'bfd403e8ef8975c0',int64), int(z'bfb208d4bea81e2b',int64), &
   int(z'3fc5aba5283ffa4e',int64), int(z'bfb1440811705130',int64), int(z'3fdd7ffeb0e64500',int64), int(z'3fdba4722324e140',int64), &
   int(z'3fea647e8c5ad680',int64), int(z'bfd4112da03f042d',int64), int(z'bfb15c339580389c',int64), int(z'3fc5801e49d9889e',int64), &
   int(z'bfb190a3ef96554f',int64), int(z'3fddbffe2dfcf4eb',int64), int(z'3fdbd9269f1d27a0',int64), int(z'3fea50671ac286ca',int64), &
   int(z'bfd41df2590a4de1',int64), int(z'bfb0b0e48bd1efa5',int64), int(z'3fc553d8702506d0',int64), int(z'bfb1da36ada415a6',int64), &
   int(z'3fddfffd8a34bbc2',int64), int(z'3fdc0db2c4f7a2c0',int64), int(z'3fea3c432ef70bb3',int64), int(z'bfd42a3716ee647c',int64), &
   int(z'bfb006fadb6270bb',int64), int(z'3fc526de86f08de6',int64), int(z'bfb220c67e5061fb',int64), int(z'3fde3ffdd26415c0',int64), &
   int(z'3fdc421758282940',int64), int(z'3fea2812f391ddcb',int64), int(z'bfd435fd18eddf0a',int64), int(z'bfaebcf288a589af',int64), &
   int(z'3fc4f9374cf96163',int64), int(z'bfb26459f6a18481',int64), int(z'3fde7fff37f72672',int64), int(z'3fdc765467aa3dc0',int64), &
   int(z'3fea13d6d6ce86b3',int64), int(z'bfd4414574037e91',int64), int(z'bfad6ec93b2cc445',int64), int(z'3fc4caea0564f101',int64), &
   int(z'bfb2a4f80c49cd64',int64), int(z'3fdebffda11bc00f',int64), int(z'3fdcaa6685e23660',int64), int(z'3fe9ff90a25c2396',int64), &
   int(z'bfd44c108a64724f',int64), int(z'bfac23992f871e82',int64), int(z'3fc49c010afbfb85',int64), int(z'bfb2e2a80f0ff3fe',int64), &
   int(z'3fdeffff3313756d',int64), int(z'3fdcde529d30cc20',int64), int(z'3fe9eb3edff9491f',int64), int(z'bfd456607e6abaae',int64), &
   int(z'bfaadb4c3e8aa98d',int64), int(z'3fc46c7f25d8ff7d',int64), int(z'bfb31d71a71d448d',int64), int(z'3fdf4001914b856e',int64), &
   int(z'3fdd1216aac1bb20',int64), int(z'3fe9d6e2c9bc4315',int64), int(z'bfd46036004e7e91',int64), int(z'bfa995f7fb901f89',int64), &
   int(z'3fc43c6d3f5be04a',int64), int(z'bfb3555cce8abf92',int64), int(z'3fdf8003cd144428',int64), int(z'3fdd45b1d93e9640',int64), &
   int(z'3fe9c27d256fdfeb',int64), int(z'bfd4699209f7c145',int64), int(z'bfa853a9ed521174',int64), int(z'3fc40bd32b27751f',int64), &
   int(z'bfb38a71cfa5c5f2',int64), int(z'3fdfc00200545bd9',int64), int(z'3fdd7920f536d960',int64), int(z'3fe9ae0faae99ea5',int64), &
   int(z'bfd4727538dd66f4',int64), int(z'bfa7147db5484f74',int64), int(z'3fc3dabaf8efc373',int64), int(z'bfb3bcb93ea6b864',int64), &
   int(z'3fdffffbda6f2aa8',int64), int(z'3fddac63b420faa0',int64), int(z'3fe9999aed4d0cab',int64), int(z'bfd47ae0bfcc6072',int64), &
   int(z'bfa5d87c25bf7a4a',int64), int(z'3fc3a92bf5999ee5',int64), int(z'bfb3ec3bf7f09d08',int64), int(z'3fe01fffa65118c8',int64), &
   int(z'3fdddf852bf70c00',int64), int(z'3fe9851aecd72ae5',int64), int(z'bfd482d78f5794c5',int64), int(z'bfa49f682e4a020b',int64), &
   int(z'3fc3772225a156da',int64), int(z'bfb4190319f58064',int64), int(z'3fe040019c0b0556',int64), int(z'3fde127dfa2ba200',int64), &
   int(z'3fe9709308c17a55',int64), int(z'bfd48a59957a7efd',int64), int(z'bfa369762648f2bb',int64), int(z'3fc344ab592569b1',int64), &
   int(z'bfb4431803752ddb',int64), int(z'3fe05fffc24501db',int64), int(z'3fde4547a495bcc0',int64), int(z'3fe95c064f225b79',int64), &
   int(z'bfd491672163f5b8',int64), int(z'bfa236d34b79b89f',int64), int(z'3fc311d4b530b7be',int64), int(z'bfb46a844d931476',int64), &
   int(z'3fe07ffe865125fc',int64), int(z'3fde77e92a5fad60',int64), int(z'3fe947725c13b0ea',int64), int(z'bfd498026f33abca',int64), &
   int(z'bfa1075ade947c6b',int64), int(z'3fc2de9dd8d5e01b',int64), int(z'bfb48f51ca17ca60',int64), int(z'3fe0a002107eac25',int64), &
   int(z'3fdeaa6908243180',int64), int(z'3fe932d4f339824b',int64), int(z'bfd49e2d7145f475',int64), int(z'bf9fb5d800571424',int64), &
   int(z'3fc2ab0685d1cf84',int64), int(z'bfb4b18a7dbbbabe',int64), int(z'3fe0bfff7376e5d4',int64), int(z'3fdedcb5f79ff560',int64), &
   int(z'3fe91e358ee1b492',int64), int(z'bfd4a3e749498453',int64), int(z'bf9d63e4be685c6f',int64), int(z'3fc27726c4b1f032',int64), &
   int(z'bfb4d1389e6ecc3a',int64), int(z'3fe0dffe1715ee2e',int64), int(z'3fdf0edb9be1bb80',int64), int(z'3fe9098fd993bd60',int64), &
   int(z'bfd4a9329b84e907',int64), int(z'bf9b185ae07dba5e',int64), int(z'3fc242f8f2d7a804',int64), int(z'bfb4ee668ddaa340',int64), &
   int(z'3fe100017f3d776c',int64), int(z'3fdf40df6119e100',int64), int(z'3fe8f4e1fb44bcfb',int64), int(z'bfd4ae1116e3467e',int64), &
   int(z'bf98d304cf368422',int64), int(z'3fc20e7d736708ae',int64), int(z'bfb5091ed7b3658d',int64), int(z'3fe11ffefd8c7b65',int64), &
   int(z'3fdf72b08fd21560',int64), int(z'3fe8e0334770fb0a',int64), int(z'bfd4b2825c0f6783',int64), int(z'bf9694ac7ffe0364',int64), &
   int(z'3fc1d9cbe529bf4c',int64), int(z'bfb5216c2c73e5f0',int64), int(z'3fe14000afa3ee71',int64), int(z'3fdfa45ee3324d60',int64), &
   int(z'3fe8cb7d9ff684df',int64), int(z'bfd4b68917add34d',int64), int(z'bf945ca367276e70',int64), int(z'3fc1a4d9a1fbf3b1',int64), &
   int(z'bfb537595fba2374',int64), int(z'3fe15fff73336187',int64), int(z'3fdfd5df3de48d00',int64), int(z'3fe8b6c60cbe3546',int64), &
   int(z'bfd4ba259b291bcb',int64), int(z'bf922b6f5fb712cc',int64), int(z'3fc16fb855e28b0b',int64), int(z'bfb54af1633f423c',int64), &
   int(z'3fe17fff6c447b82',int64), int(z'3fe0039c0208ecc0',int64), int(z'3fe8a20a48f15926',int64), int(z'bfd4bd59a5808ac3',int64), &
   int(z'bf9000cd5eef6f2a',int64), int(z'3fc13a66ebe54aa7',int64), int(z'bfb55c3f45420ce4',int64), int(z'3fe19fffae932b61',int64), &
   int(z'3fe01c33e0091bc0',int64), int(z'3fe88d4b55664e00',int64), int(z'bfd4c026579f5abb',int64), int(z'bf8bb9a68797c32a',int64), &
   int(z'3fc104ec95d4f64e',int64), int(z'bfb56b4e2bbc325e',int64), int(z'3fe1bfffba12ae50',int64), int(z'3fe034b6d3aba020',int64), &
   int(z'3fe87889ebdccf04',int64), int(z'bfd4c28ce6d463c1',int64), int(z'bf877f1cb36211fc',int64), int(z'3fc0cf4fb90b11e7',int64), &
   int(z'bfb5782952dcbe1a',int64), int(z'3fe1e0014b459e41',int64), int(z'3fe04d262dc05800',int64), int(z'3fe863c551625b6a',int64), &
   int(z'bfd4c48eaffdd399',int64), int(z'bf8351cb603059ca',int64), int(z'3fc09992de65d0d9',int64), int(z'bfb582dc087bb367',int64), &
   int(z'3fe2000032306f33',int64), int(z'3fe0657ebafb6ce0',int64), int(z'3fe84f00a1e2eec3',int64), int(z'bfd4c62cb79ec8c6',int64), &
   int(z'bf7e6488d95de8d1',int64), int(z'3fc063c2661df241',int64), int(z'bfb58b71aaa63bad',int64), int(z'3fe22000d30a486c',int64), &
   int(z'3fe07dc3d2165080',int64), int(z'3fe83a3966b3e5bf',int64), int(z'bfd4c7687de04dee',int64), int(z'bf763ff7800f052f',int64), &
   int(z'3fc02ddc28f35edd',int64), int(z'bfb591f5a351cf91',int64), int(z'3fe23ffe215e03fc',int64), int(z'3fe095f19f380a00',int64), &
   int(z'3fe8257348be5f3f',int64), int(z'bfd4c8431b793f77',int64), int(z'bf6c6e63625993b8',int64), int(z'3fbfefdb8c5e4b3b',int64), &
   int(z'bfb5967366fe9ca7',int64), int(z'3fe260006833d65d',int64), int(z'3fe0ae0e6496a8c0',int64), int(z'3fe810a945b44aa3',int64), &
   int(z'bfd4c8be055b407a',int64), int(z'bf5920a7ae83f0a4',int64), int(z'3fbf83dc860a6a5e',int64), int(z'bfb598f670d98ee7',int64), &
   int(z'3fe28000e82d4d50',int64), int(z'3fe0c615095f5300',int64), int(z'3fe7fbe01e9337b7',int64), int(z'bfd4c8da573c6f6a',int64), &
   int(z'3f38b6c7c50f565d',int64), int(z'3fbf17dbc9c4b6ca',int64), int(z'bfb5998a45d6dae0',int64), int(z'3fe29fff203b6a0b',int64), &
   int(z'3fe0de0530852720',int64), int(z'3fe7e7188520538d',int64), int(z'bfd4c899668c6963',int64), int(z'3f6286ecbeca8ab0',int64), &
   int(z'3fbeabe49b6ac5bd',int64), int(z'bfb5983a575a9684',int64), int(z'3fe2c001e91a9d93',int64), int(z'3fe0f5e3f7817a20',int64), &
   int(z'3fe7d24e63a45d97',int64), int(z'bfd4c7fc5f83c46d',int64), int(z'3f70e1995d9c800a',int64), int(z'3fbe3fe93721a8e0',int64), &
   int(z'bfb59512377da840',int64), int(z'3fe2dfffc6fb4948',int64), int(z'3fe10daa4ce36040',int64), int(z'3fe7bd883e39011f',int64), &
   int(z'bfd4c704b5eae11f',int64), int(z'3f786398192c622b',int64), int(z'3fbdd412b62ba357',int64), int(z'bfb5901d5f0e020e',int64), &
   int(z'3fe2ffff39cb4eed',int64), int(z'3fe1255d0970ad60',int64), int(z'3fe7a8c2365b7a9b',int64), int(z'bfd4c5b38925f532',int64), &
   int(z'3f7fcb03785e3070',int64), int(z'3fbd68540eedf3b3',int64), int(z'bfb58967479c252a',int64), int(z'3fe31ffe002e31cb',int64), &
   int(z'3fe13cfa81fd3780',int64), int(z'3fe793fe1bbe9667',int64), int(z'bfd4c40a3046f4c7',int64), int(z'3f838bae8f5e6bf1',int64), &
   int(z'3fbcfcbd83775c98',int64), int(z'bfb580fb62e887ab',int64), int(z'3fe34000edc7bffd',int64), int(z'3fe1548644d05200',int64), &
   int(z'3fe77f39244a1da5',int64), int(z'bfd4c2099fb764c1',int64), int(z'3f8724e2851b0be5',int64), int(z'3fbc9147507c76e0',int64), &
   int(z'bfb576e519c7f0ab',int64), int(z'3fe36001ce042830',int64), int(z'3fe16bfbc1656ae0',int64), int(z'3fe76a77ad3b2b77',int64), &
   int(z'bfd4bfb374aac296',int64), int(z'3f8ab07005b229c2',int64), int(z'3fbc260e87dca54b',int64), int(z'bfb56b2fc90df763',int64), &
   int(z'3fe37ffe89b8fc54',int64), int(z'3fe1835977d0ba80',int64), int(z'3fe755bb660caa3d',int64), int(z'bfd4bd09308bb975',int64), &
   int(z'3f8e2e26fe0a1240',int64), int(z'3fbbbb2218790f26',int64), int(z'bfb55de6c094f3da',int64), int(z'3fe3a0019b4da842',int64), &
   int(z'3fe19aa7100cd140',int64), int(z'3fe740fdd801f889',int64), int(z'bfd4ba0b2c32c656',int64), int(z'3f90cf998eca44a2',int64), &
   int(z'3fbb5066c9863443',int64), int(z'bfb54f15406672b5',int64), int(z'3fe3c000ce6b63e8',int64), int(z'3fe1b1dd1d0b0ae0',int64), &
   int(z'3fe72c45f28670e6',int64), int(z'bfd4b6bb92422e2e',int64), int(z'3f928141a0d32146',int64), int(z'3fbae60637452321',int64), &
   int(z'bfb53ec677d91f56',int64), int(z'3fe3dfff114a2607',int64), int(z'3fe1c8fdc6ff6f20',int64), int(z'3fe71792206847a7',int64), &
   int(z'bfd4b31b669bd306',int64), int(z'3f942c3a04ffd28a',int64), int(z'3fba7bfde7fc0825',int64), int(z'bfb52d0582f471ba',int64), &
   int(z'3fe3ffffc1da9b7d',int64), int(z'3fe1e00b7f2e8840',int64), int(z'3fe702e084371133',int64), int(z'bfd4af2b8012fbe4',int64), &
   int(z'3f95d0b4bfc47f4b',int64), int(z'3fba1249d80ab6c5',int64), int(z'bfb519dd69a4108d',int64), int(z'3fe41ffee11d9c33',int64), &
   int(z'3fe1f70367c3ec20',int64), int(z'3fe6ee34026a76a0',int64), int(z'bfd4aaed96514b12',int64), int(z'3f976e8307ba2905',int64), &
   int(z'3fb9a8fe261a1221',int64), int(z'bfb505591d552ba0',int64), int(z'3fe43ffffa174676',int64), int(z'3fe20de80faff860',int64), &
   int(z'3fe6d98a9ea6d162',int64), int(z'bfd4a6626b927b3b',int64), int(z'3f9905d8f84adbb0',int64), int(z'3fb94015dd484db5',int64), &
   int(z'bfb4ef83783eef44',int64), int(z'3fe45fff0d457fa4',int64), int(z'3fe224b69f675300',int64), int(z'3fe6c4e73a093351',int64), &
   int(z'bfd4a18bcbf2bff8',int64), int(z'3f9a968a84bb8c16',int64), int(z'3fb8d7a493fbb975',int64), int(z'bfb4d8673b37e4fb',int64), &
   int(z'3fe47ffe8f910e57',int64), int(z'3fe23b70dd92b840',int64), int(z'3fe6b04889b04359',int64), int(z'bfd49c6a974b07ff',int64), &
   int(z'3f9c20be25f20251',int64), int(z'3fb86fa882e9673d',int64), int(z'bfb4c00f0d12f550',int64), int(z'3fe4a0017323fc6b',int64), &
   int(z'3fe25218e34e3420',int64), int(z'3fe69bacf277fe27',int64), int(z'bfd496ff7f856aba',int64), int(z'3f9da49e9928150c',int64), &
   int(z'3fb8081e3eb66a26',int64), int(z'bfb4a68578ab06c5',int64), int(z'3fe4c000b1bf0500',int64), int(z'3fe268a9bd8b2c80',int64), &
   int(z'3fe6871942abbd42',int64), int(z'bfd4914cec74e64a',int64), int(z'3f9f21ded0c3eeec',int64), int(z'3fb7a1225b30aa05',int64), &
   int(z'bfb48bd4ec53ef43',int64), int(z'3fe4e0011d07207b',int64), int(z'3fe27f26da64f7a0',int64), int(z'3fe6728aa7cfbeb2',int64), &
   int(z'bfd48b533fcbb247',int64), int(z'3fa04c60a7354a41',int64), int(z'3fb73aaaeff6f27a',int64), int(z'bfb47007b81a6bb2',int64), &
   int(z'3fe4fffe5f36eb46',int64), int(z'3fe2958d35ddd180',int64), int(z'3fe65e04307b6af3',int64), int(z'bfd48514828bb6e6',int64), &
   int(z'3fa1048e48993ed9',int64), int(z'3fb6d4cb468d7c59',int64), int(z'bfb453280d484989',int64), int(z'3fe520012afdf759',int64), &
   int(z'3fe2abe2eb1c3280',int64), int(z'3fe649808dc5daad',int64), int(z'bfd47e902c11e3b7',int64), int(z'3fa1b9ae88e1b343',int64), &
   int(z'3fb66f6cff4501bf',int64), int(z'bfb4353ffcd6b8de',int64), int(z'3fe54001dfdb2423',int64), int(z'3fe2c222ab0402c0',int64), &
   int(z'3fe63504e7e657fb',int64), int(z'bfd477c8eee53fa9',int64), int(z'3fa26b9a696cd845',int64), int(z'3fb60aad6a3aa6ef',int64), &
   int(z'bfb416597704e1f4',int64), int(z'3fe55ffe72d2a74f',int64), int(z'3fe2d84b16be7240',int64), int(z'3fe62092ce54aede',int64), &
   int(z'bfd470c07b764156',int64), int(z'3fa31a4c4d9abee7',int64), int(z'3fb5a697a899a63d',int64), int(z'bfb3f67e49fa7fb1',int64), &
   int(z'3fe58000ee716c33',int64), int(z'3fe2ee63284f3fe0',int64), int(z'3fe60c24181c5720',int64), int(z'bfd46975c383b0c1',int64), &
   int(z'3fa3c5ffc40a1a5a',int64), int(z'3fb543110b7b3b72',int64), int(z'bfb3d5b821700401',int64), int(z'3fe59fff9825cd2a',int64), &
   int(z'3fe304642defcf40',int64), int(z'3fe5f7bf3c14a317',int64), int(z'bfd461ec227a4cde',int64), int(z'3fa46e856da8d837',int64), &
   int(z'3fb4e03c6162f4c8',int64), int(z'bfb3b410857f5976',int64), int(z'3fe5bffdfe2a42cd',int64), int(z'3fe31a50a5110dc0',int64), &
   int(z'3fe5e36233cf1268',int64), int(z'bfd45a23f68b7dbc',int64), int(z'3fa513f5de40f0e9',int64), int(z'3fb47e12de05901e',int64), &
   int(z'bfb39190da5cabb5',int64), int(z'3fe5e00057330799',int64), int(z'3fe3302b75253480',int64), int(z'3fe5cf0a901da45a',int64), &
   int(z'bfd4521d552754cf',int64), int(z'3fa5b66bbbf000bb',int64), int(z'3fb41c8bd2baf7b2',int64), int(z'bfb36e425f53241a',int64), &
   int(z'3fe600014d6055da',int64), int(z'3fe345f0ff2eda60',int64), int(z'3fe5babbf2ea5900',int64), int(z'bfd449dab2008754',int64), &
   int(z'3fa655d118f56fbb',int64), int(z'3fb3bbbb89a0c1b2',int64), int(z'bfb34a2e2e8d60fc',int64), int(z'3fe620012c3809cb',int64), &
   int(z'3fe35ba1812d5040',int64), int(z'3fe5a676671e49e9',int64), int(z'bfd4415d230e6216',int64), int(z'3fa6f22d6b05c7f7',int64), &
   int(z'3fb35ba4cfe6b72b',int64), int(z'bfb3255d3c3bfa3b',int64), int(z'3fe6400087b47ecc',int64), int(z'3fe3713d69715580',int64), &
   int(z'3fe59239c8fb0e69',int64), int(z'bfd438a5a5bd1f6e',int64), int(z'3fa78b897f9b13cf',int64), int(z'3fb2fc4974f57c8f',int64), &
   int(z'bfb2ffd8566caaca',int64), int(z'3fe66000a746397f',int64), int(z'3fe386c59d968940',int64), int(z'3fe57e0583073c58',int64), &
   int(z'bfd42fb4fe3d0083',int64), int(z'3fa821f14b9e1eeb',int64), int(z'3fb29da91952ee82',int64), int(z'bfb2d9a8245866a8',int64), &
   int(z'3fe68000e4e3094b',int64), int(z'3fe39c39b5fe3900',int64), int(z'3fe569da36dd131e',int64), int(z'bfd4268c74778fe0',int64), &
   int(z'3fa8b5679ab0310f',int64), int(z'3fb23fc8f2e43205',int64), int(z'bfb2b2d526483573',int64), int(z'3fe6a001e2e37787',int64), &
   int(z'3fe3b19a27d52620',int64), int(z'3fe555b7b5d865cd',int64), int(z'bfd41d2cf1600cd3',int64), int(z'3fa945f54b79e859',int64), &
   int(z'3fb1e2aa46a0b02d',int64), int(z'bfb28b67b508a35b',int64), int(z'3fe6bffe0df4bbfb',int64), int(z'3fe3c6e346f2b6e0',int64), &
   int(z'3fe541a1b658afbe',int64), int(z'bfd41399388da137',int64), int(z'3fa9d387e5b3c2ba',int64), int(z'3fb18660173397f9',int64), &
   int(z'bfb2636801db4945',int64), int(z'3fe6dfffea406cea',int64), int(z'3fe3dc1c1bb3d400',int64), int(z'3fe52d91d33ffe8e',int64), &
   int(z'bfd409cf36bcffe9',int64), int(z'3faa5e54174405af',int64), int(z'3fb12acedc041806',int64), int(z'bfb23ade160d6557',int64), &
   int(z'3fe70000ed01ea65',int64), int(z'3fe3f14054e51400',int64), int(z'3fe5198c5c8b9119',int64), int(z'bfd3ffd1f2ea4ff7',int64), &
   int(z'3faae643308c81cd',int64), int(z'3fb0d00c1960aaf7',int64), int(z'bfb211d1d2f50d25',int64), int(z'3fe7200200d515eb',int64), &
   int(z'3fe40650983bb3e0',int64), int(z'3fe50590f2175c71',int64), int(z'bfd3f5a2361bb15c',int64), int(z'3fab6b5f9b536afc',int64), &
   int(z'3fb07617a731624d',int64), int(z'bfb1e84af1a8c054',int64), int(z'3fe740011323de6d',int64), int(z'3fe41b4b9483e720',int64), &
   int(z'3fe4f1a11027ba01',int64), int(z'bfd3eb41bb978c8f',int64), int(z'3fabeda77765626a',int64), int(z'3fb01cf997f58c8a',int64), &
   int(z'bfb1be5103074348',int64), int(z'3fe75fff25cab4ca',int64), int(z'3fe430320001d5c0',int64), int(z'3fe4ddbc4573fb6c',int64), &
   int(z'bfd3e0b141f21d2a',int64), int(z'3fac6d25d1bda00f',int64), int(z'3faf89625935ee68',int64), int(z'bfb193eb6f8e0689',int64), &
   int(z'3fe77ffe90921f76',int64), int(z'3fe445056cc6af00',int64), int(z'3fe4c9e14cffbdae',int64), int(z'bfd3d5f10b247ec4',int64), &
   int(z'3face9ea943f4516',int64), int(z'3faeda73f24a8af1',int64), int(z'bfb16921776aac42',int64), int(z'3fe79ffe47b2f83b',int64), &
   int(z'3fe459c535c19f20',int64), int(z'3fe4b610fc8f20bd',int64), int(z'bfd3cb0273df2a0d',int64), int(z'3fad63f823c5d6de',int64), &
   int(z'3fae2d319c5116ab',int64), int(z'bfb13dfa326e2972',int64), int(z'3fe7bfff2f1e79a9',int64), int(z'3fe46e71f84df5c0',int64), &
   int(z'3fe4a24af586b1bd',int64), int(z'bfd3bfe62ef81e5b',int64), int(z'3faddb58738896f0',int64), int(z'3fad819a2515de78',int64), &
   int(z'bfb1127c9026fdd0',int64), int(z'3fe7e001973c8d05',int64), int(z'3fe4830bf0fb9580',int64), int(z'3fe48e8f3466b08e',int64), &
   int(z'bfd3b49d1c53a01a',int64), int(z'3fae501325103eed',int64), int(z'3facd7af5290f4af',int64), int(z'bfb0e6af57ef003b',int64), &
   int(z'3fe7ffff69efc092',int64), int(z'3fe4978f431c3800',int64), int(z'3fe47ae1a3e1064a',int64), int(z'bfd3a92a666c50c4',int64), &
   int(z'3faec2194098a4be',int64), int(z'3fac2f942eee57e0',int64), int(z'bfb0ba99290d5730',int64), int(z'3fe82001c52b5232',int64), &
   int(z'3fe4ac01d2b83340',int64), int(z'3fe4673cd31b7cf5',int64), int(z'bfd39d8bc67d05f0',int64), int(z'3faf31922a81b5d5',int64), &
   int(z'3fab891b8aa20e90',int64), int(z'bfb08e407adcefd6',int64), int(z'3fe84000bd4d4e3f',int64), int(z'3fe4c05e9b1dbc60',int64), &
   int(z'3fe453a5c8d629f7',int64), int(z'bfd391c513e9ef47',int64), int(z'3faf9e6917383d6b',int64), int(z'3faae471278e21b9',int64), &
   int(z'bfb061ab9cf54d10',int64), int(z'3fe860018c869cbd',int64), int(z'3fe4d4a8fd2285a0',int64), int(z'3fe4401979b82471',int64), &
   int(z'bfd385d55c3e2929',int64), int(z'3fb0045b7b2c8ff2',int64), int(z'3faa417c39d7ca4f',int64), int(z'bfb034e0b767b7d4',int64), &
   int(z'3fe87ffeb5db3710',int64), int(z'3fe4e8dd8b93bca0',int64), int(z'3fe42c9b66c6e6bf',int64), int(z'bfd379bfa32ee2a1',int64), &
   int(z'3fb038386187fe0f',int64), int(z'3fa9a05a8b3a0b33',int64), int(z'bfb007e5caee03a9',int64), int(z'3fe8a000863c77e3',int64), &
   int(z'3fe4fd018fcd1e80',int64), int(z'3fe41926a8a8093f',int64), int(z'bfd36d81b5ee344d',int64), int(z'3fb06adc2841f292',int64), &
   int(z'3fa900e42484560b',int64), int(z'bfafb58162792f0a',int64), int(z'3fe8bfff0ed982af',int64), int(z'3fe5111016e28ac0',int64), &
   int(z'3fe405c0389112ee',int64), int(z'bfd3611f89d38dc7',int64), int(z'3fb09c3db450b9f7',int64), int(z'3fa86342312d0c4a',int64), &
   int(z'bfaf5aee3a6ca012',int64), int(z'3fe8e00002c3aeae',int64), int(z'3fe5250cc0ab0a40',int64), int(z'3fe3f264c65593c5',int64), &
   int(z'bfd35497d82be900',int64), int(z'3fb0cc6968546d39',int64), int(z'3fa7c759db8499fd',int64), int(z'bfaf001d36a32337',int64), &
   int(z'3fe90000ecbfa97b',int64), int(z'3fe538f60e8d4ee0',int64), int(z'3fe3df15f4119333',int64), int(z'bfd347ec7d2149f4',int64), &
   int(z'3fb0fb5efa921d3c',int64), int(z'3fa72d3869693e89',int64), int(z'bfaea51923a0f5f3',int64), int(z'3fe91fffd251c01c',int64), &
   int(z'3fe54ccad3f3bd20',int64), int(z'3fe3cbd51554dd15',int64), int(z'bfd33b1f2bc94245',int64), int(z'3fb1291f2fc4c3f6',int64), &
   int(z'3fa694e81b7a765c',int64), int(z'bfae49ec826e86f6',int64), int(z'3fe94001d90af4e6',int64), int(z'3fe5608e4d4ec640',int64), &
   int(z'3fe3b89f3445ef72',int64), int(z'bfd32e2eb7bbd79a',int64), int(z'3fb155b4e401d071',int64), int(z'3fa5fe513a256f1c',int64), &
   int(z'bfadeea1890ff662',int64), int(z'3fe9600104fd6c17',int64), int(z'3fe5743cd5673c20',int64), int(z'3fe3a57809ebc6e2',int64), &
   int(z'bfd3211e6da5039c',int64), int(z'3fb1811b4e62286b',int64), int(z'3fa5699071bece9d',int64), int(z'bfad934223911641',int64), &
   int(z'3fe980002d214b82',int64), int(z'3fe587d83b0d6120',int64), int(z'3fe3925e01eaac3e',int64), int(z'bfd313ee08425504',int64), &
   int(z'3fb1ab5a02bdb571',int64), int(z'3fa4d6989ebd70b8',int64), int(z'bfad37d7f482965a',int64), int(z'3fe99ffdeb980651',int64), &
   int(z'3fe59b5fb16ba7a0',int64), int(z'3fe37f5210b1ab7a',int64), int(z'bfd3069ef993d676',int64), int(z'3fb1d472cded25a8',int64), &
   int(z'3fa445702d0abd9a',int64), int(z'bfacdc6c56221aa1',int64), int(z'3fe9bfffe5504053',int64), int(z'3fe5aed6b55de6a0',int64), &
   int(z'3fe36c50fa91c51e',int64), int(z'bfd2f92fbe311e56',int64), int(z'3fb1fc705be3af05',int64), int(z'3fa3b5fdacd5cdc7',int64), &
   int(z'bfac81085adbb9b8',int64), int(z'3fe9e0016e60a234',int64), int(z'3fe5c23a79acd480',int64), int(z'3fe3595da5fab2ea',int64), &
   int(z'bfd2eba31ddeceea',int64), int(z'3fb2235035736518',int64), int(z'3fa3285622f9fd28',int64), int(z'bfac25b4ce8b2259',int64), &
   int(z'3fe9ffffb685741b',int64), int(z'3fe5d5895ad40460',int64), int(z'3fe34679d832b8d3',int64), int(z'bfd2ddfb230eda41',int64), &
   int(z'3fb24912b23c0ba2',int64), int(z'3fa29c854c4e86da',int64), int(z'bfabca7a37002a55',int64), int(z'3fea20019d59b943',int64), &
   int(z'3fe5e8c78c187ea0',int64), int(z'3fe333a19ede2183',int64), int(z'bfd2d035b0043779',int64), int(z'3fb26dc37ab9110c',int64), &
   int(z'3fa2126c959cfc0e',int64), int(z'bfab6f60d556233e',int64), int(z'3fea3fffbe9e153f',int64), int(z'3fe5fbf0a9c08ae0',int64), &
   int(z'3fe320d96f7861aa',int64), int(z'bfd2c256c2200f18',int64), int(z'3fb2915da6795293',int64), int(z'3fa18a2b256a8fde',int64), &
   int(z'bfab1470a67a4e89',int64), int(z'3fea5ffe7a23a1ce',int64), int(z'3fe60f0763200600',int64), int(z'3fe30e1ed13d395e',int64), &
   int(z'bfd2b45d44403932',int64), int(z'3fb2b3e9c967f013',int64), int(z'3fa103ad35d002b8',int64), int(z'bfaab9b16496a8f1',int64), &
   int(z'3fea800157f250b8',int64), int(z'3fe6220ddd6453a0',int64), int(z'3fe2fb6fcfffcc1e',int64), int(z'bfd2a6486f8d8291',int64), &
   int(z'3fb2d56f03654cc3',int64), int(z'3fa07ee34bb6e7a6',int64), int(z'bfaa5f2a87992f03',int64), int(z'3feaa000dd839d49',int64), &
   int(z'3fe634ffb412c9a0',int64), int(z'3fe2e8d0e2d59e01',int64), int(z'bfd2981c5467cfdd',int64), int(z'3fb2f5e8ff1fadb5',int64), &
   int(z'3f9ff7d6a3ba803c',int64), int(z'bfaa04e346af8db7',int64), int(z'3feac000770df220',int64), int(z'3fe647defef70020',int64), &
   int(z'3fe2d640220aff7f',int64), int(z'bfd289d836f9e74f',int64), int(z'3fb3155ee509140a',int64), int(z'3f9ef56b61ab0b7f',int64), &
   int(z'bfa9aae298ce391f',int64), int(z'3feae001125bbe48',int64), int(z'3fe65aac57a24d20',int64), int(z'3fe2c3bd1bfb3559',int64), &
   int(z'bfd27b7c6dde55dd',int64), int(z'3fb333d515c4c270',int64), int(z'3f9df67a9bac4ecf',int64), int(z'bfa9512f363a972b',int64), &
   int(z'3feafffe7c321839',int64), int(z'3fe66d65569b83c0',int64), int(z'3fe2b14a53fbf8d9',int64), int(z'bfd26d0b9cfa03ce',int64), &
   int(z'3fb3514b2caa2e0c',int64), int(z'3f9cfb224597be9a',int64), int(z'bfa8f7cf99110022',int64), int(z'3feb1ffe75486924',int64), &
   int(z'3fe6800d68cefb40',int64), int(z'3fe29ee48e6aa814',int64), int(z'bfd25e83e8afa7eb',int64), int(z'3fb36dc9fb0e8ac8',int64), &
   int(z'3f9c0331ad5d66ca',int64), int(z'bfa89ec9fedb1e8b',int64), int(z'3feb40015fb8deb8',int64), int(z'3fe692a4d137c500',int64), &
   int(z'3fe28c8babff668e',int64), int(z'bfd24fe5d8e71e0a',int64), int(z'3fb389551297317a',int64), int(z'3f9b0ea31d844655',int64), &
   int(z'bfa846246914067d',int64), int(z'3feb6000386c27b9',int64), int(z'3fe6a5278cdf6fc0',int64), int(z'3fe27a43c5758db8',int64), &
   int(z'bfd2413559cadce0',int64), int(z'3fb3a3e9ee34ae91',int64), int(z'3f9a1da81c5fff05',int64), int(z'bfa7ede49ec8aac6',int64), &
   int(z'3feb8000d1efddb3',int64), int(z'3fe6b7990accb660',int64), int(z'3fe268099983aab2',int64), int(z'bfd2327076047e08',int64), &
   int(z'3fb3bd90f132139b',int64), int(z'3f99301058deb3e1',int64), int(z'bfa796102d194ce9',int64), int(z'3feb9ffe42cc4047',int64), &
   int(z'3fe6c9f686445e60',int64), int(z'3fe255e0069f871f',int64), int(z'bfd2239a25461639',int64), int(z'3fb3d649a926c127',int64), &
   int(z'3f9845fbc5a21f70',int64), int(z'bfa73eac68e20be6',int64), int(z'3febc001951aeaad',int64), int(z'3fe6dc453c4e45a0',int64), &
   int(z'3fe243c1ff6573b0',int64), int(z'bfd214aee38fa7e7',int64), int(z'3fb3ee1e5ea1330f',int64), int(z'3f975f242bcce6df',int64), &
   int(z'bfa6e7be6f3902c5',int64), int(z'3febdffe6616fe11',int64), int(z'3fe6ee7e27106fe0',int64), int(z'3fe231b697b587f0',int64), &
   int(z'bfd205b5240fef32',int64), int(z'3fb4050944eb818c',int64), int(z'3f967bde108160f9',int64), int(z'bfa6914b271d18ad',int64), &
   int(z'3febffff54511c72',int64), int(z'3fe700a7643bbb40',int64), int(z'3fe21fb7e1823c8b',int64), int(z'bfd1f6a89a854f7a',int64), &
   int(z'3fb41b1571f04837',int64), int(z'3f959bd8bbd10f7c',int64), int(z'bfa63b5741f03711',int64), int(z'3fec2000c537593e',int64), &
   int(z'3fe712bef36d6400',int64), int(z'3fe20dc7f754b2d5',int64), int(z'bfd1e78b9d24dbed',int64), int(z'3fb4304394f485e0',int64), &
   int(z'3f94bf29122a6884',int64), int(z'bfa5e5e73d2aa4e9',int64), int(z'3fec4000ddd35719',int64), int(z'3fe724c3d7fa3000',int64), &
   int(z'3fe1fbe7f2a8b1bf',int64), int(z'bfd1d85fb25dddf6',int64), int(z'3fb44495d2e3b20f',int64), int(z'3f93e5d67fcc1b30',int64), &
   int(z'bfa590ff62d0d00f',int64), int(z'3fec6000402375b6',int64), int(z'3fe736b67dff3720',int64), int(z'3fe1ea1786c92387',int64), &
   int(z'bfd1c92531ddfc58',int64), int(z'3fb4580ff8b6cbc2',int64), int(z'3f930fd700ce998e',int64), int(z'bfa53ca3cb299e5f',int64), &
   int(z'3fec7fff19904fe4',int64), int(z'3fe748970f395860',int64), int(z'3fe1d856a825ba33',int64), int(z'bfd1b9dca75e0fc5',int64), &
   int(z'3fb46ab579f8fd7d',int64), int(z'3f923d23a5a90afe',int64), int(z'bfa4e8d85d2f574b',int64), int(z'3fec9ffef9e2409d',int64), &
   int(z'3fe75a6679e7f1c0',int64), int(z'3fe1c6a48740d2e9',int64), int(z'bfd1aa85f198392c',int64), int(z'3fb47c8a808c583a',int64), &
   int(z'3f916dac857f2526',int64), int(z'bfa495a0d0477576',int64), int(z'3fecc001e038ef72',int64), int(z'3fe76c25e6815140',int64), &
   int(z'3fe1b50019bdadf8',int64), int(z'bfd19b20b4a469ae',int64), int(z'3fb48d9342387ea2',int64), int(z'3f90a15f7305baf5',int64), &
   int(z'bfa44300acae4e17',int64), int(z'3fecdffeeb72037f',int64), int(z'3fe77dd07a7a4aa0',int64), int(z'3fe1a36e4f1f6702',int64), &
   int(z'bfd18bb1d0992cf8',int64), int(z'3fb49dce5aa4990d',int64), int(z'3f8fb0dd63759665',int64), int(z'bfa3f0fb4d2f0c0f',int64), &
   int(z'3fecffffea4839ed',int64), int(z'3fe78f6bb17088c0',int64), int(z'3fe191e9cf32122f',int64), int(z'bfd17c35220400ac',int64), &
   int(z'3fb4ad440a159641',int64), int(z'3f8e252c80894ca9',int64), int(z'bfa39f93df89c265',int64), int(z'3fed1ffdec3ec8b2',int64), &
   int(z'3fe7a0f3c8c6c880',int64), int(z'3fe18076729f01d6',int64), int(z'bfd16cae98515540',int64), int(z'3fb4bbf41b0933ff',int64), &
   int(z'3f8c9ff5e09a60cd',int64), int(z'bfa34ecd662a5704',int64), int(z'3fed3fff7084edd4',int64), int(z'3fe7b26c5f02f220',int64), &
   int(z'3fe16f10b9973206',int64), int(z'bfd15d1b9e1e0a54',int64), int(z'3fb4c9e4ac2c9a30',int64), int(z'3f8b20ddefce76cc',int64), &
   int(z'bfa2feaab888bc37',int64), int(z'3fed5ffe8d728e7c',int64), int(z'3fe7c3d2488d7e80',int64), int(z'3fe15dbbe622a5a7',int64), &
   int(z'bfd14d7fa305ceb2',int64), int(z'3fb4d716417bf1c7',int64), int(z'3f89a81ee19fe239',int64), int(z'bfa2af2e84ddad07',int64), &
   int(z'3fed7fff70aa3b03',int64), int(z'3fe7d527db239580',int64), int(z'3fe14c75be4fea01',int64), int(z'bfd13dd92ad706aa',int64), &
   int(z'3fb4e38db49d32aa',int64), int(z'3f88357a37df2b6d',int64), int(z'bfa2605b507cd77b',int64), int(z'3fed9fff1434fba3',int64), &
   int(z'3fe7e66b82c8a720',int64), int(z'3fe13b3fed9b7fed',int64), int(z'bfd12e2a3ac9d646',int64), int(z'3fb4ef4ce7b01cf5',int64), &
   int(z'3f86c905d25fd52d',int64), int(z'bfa21233798666ef',int64), int(z'3fedbffea8c8de8c',int64), int(z'3fe7f79df4a0a520',int64), &
   int(z'3fe12a19d7fc2119',int64), int(z'bfd11e72c6be19df',int64), int(z'3fb4fa57634e1b91',int64), int(z'3f8562a647f96df5',int64), &
   int(z'bfa1c4b9373af599',int64), int(z'3fede00026573df5',int64), int(z'3fe808c04dbcb960',int64), int(z'3fe119027903e4b9',int64), &
   int(z'bfd10eb25cdfed06',int64), int(z'3fb504b0cca681fa',int64), int(z'3f8402386f3cde09',int64), int(z'bfa177ee9ba8fa6a',int64), &
   int(z'3fedfffe35009b66',int64), int(z'3fe819cfc2cb5340',int64), int(z'3fe107fcb1c942b5',int64), int(z'bfd0feec230d7d92',int64), &
   int(z'3fb50e5a75c5b4f1',int64), int(z'3f82a7e8e3c139d8',int64), int(z'bfa12bd593fa642b',int64), int(z'3fee2000492d4c68',int64), &
   int(z'3fe82ad05ccb8680',int64), int(z'3fe0f704928e55df',int64), int(z'bfd0ef1cee0b0721',int64), int(z'3fb51759937bfb74',int64), &
   int(z'3f8153592bc9fddb',int64), int(z'bfa0e06fea1d1824',int64), int(z'3fee40009412bb65',int64), int(z'3fe83bbf14001a60',int64), &
   int(z'3fe0e61d37f485da',int64), int(z'bfd0df481b2bd37d',int64), int(z'3fb51faf64024d14',int64), int(z'3f8004b99b849698',int64), &
   int(z'bfa095bf450a2434',int64), int(z'3fee5fff4758ef2f',int64), int(z'3fe84c9c1531c180',int64), int(z'3fe0d5468b7fece7',int64), &
   int(z'bfd0cf6e105bfe1e',int64), int(z'3fb5275ef9c5e03a',int64), int(z'3f7d77f217aa1137',int64), int(z'bfa04bc52a6891e1',int64), &
   int(z'3fee8000380f819f',int64), int(z'3fe85d6974ccc060',int64), int(z'3fe0c47e8f1da5b5',int64), int(z'bfd0bf8d62ad700f',int64), &
   int(z'3fb52e6c1f3fbc2b',int64), int(z'3f7af1c3ee24ad7d',int64), int(z'bfa00282fece26c9',int64), int(z'3feea000a6d8cb7b',int64), &
   int(z'3fe86e25d00e3a60',int64), int(z'3fe0b3c6ba314d62',int64), int(z'bfd0afa7e7cb2d84',int64), int(z'3fb534d908e9071f',int64), &
   int(z'3f7877044ce5e5c9',int64), int(z'bf9f73f40eb7c9d5',int64), int(z'3feec0005a13ba60',int64), int(z'3fe87ed119b163e0',int64), &
   int(z'3fe0a31f2ebb7ad7',int64), int(z'bfd09fbe33a3fce1',int64), int(z'3fb53aa889d9af5d',int64), int(z'3f760799f7f7040b',int64), &
   int(z'bf9ee456d3f0b3fb',int64), int(z'3feedfff58f8dd18',int64), int(z'3fe88f6b6681ca80',int64), int(z'3fe09287ec4360b3',int64), &
   int(z'bfd08fd0b7ce07e5',int64), int(z'3fb53fdd7bdedd3f',int64), int(z'3f73a36670c52e66',int64), int(z'bf9e56305dca7315',int64), &
   int(z'3feeffffbe033400',int64), int(z'3fe89ff5dd4d7960',int64), int(z'3fe081ffdffe15bd',int64), int(z'bfd07fdedae56c0f',int64), &
   int(z'3fb5447af84d6f5d',int64), int(z'3f714a247982941e',int64), int(z'bf9dc98281e68835',int64), int(z'3fef2001e6b5125d',int64), &
   int(z'3fe8b070bbe88160',int64), int(z'3fe07186df7122e2',int64), int(z'bfd06fe8de905325',int64), int(z'3fb54883b5deec7a',int64), &
   int(z'3f6df762b4a186d5',int64), int(z'bf9d3e4ede20f495',int64), int(z'3fef3ffdf770e0db',int64), int(z'3fe8c0d809e96380',int64), &
   int(z'3fe06120f5a576a9',int64), int(z'bfd05ff31d2912ff',int64), int(z'3fb54bf98cd1001f',int64), int(z'3f6970fc6e90dc16',int64), &
   int(z'bf9cb496d8eb587e',int64), int(z'3fef5ffe4e16da33',int64), int(z'3fe8d13129bccdc0',int64), int(z'3fe050c8d33ba4e9',int64), &
   int(z'bfd04ff8d74c83d2',int64), int(z'3fb54ee0592bb252',int64), int(z'3f64ff617193eeb5',int64), int(z'bf9c2c5ba459ac86',int64), &
   int(z'3fef80004576ff2e',int64), int(z'3fe8e17acce443a0',int64), int(z'3fe0407fd8a97b6c',int64), int(z'bfd03ffbc91b3e55',int64), &
   int(z'3fb5513a5f3357f7',int64), int(z'3f60a2ba14c92b53',int64), int(z'bf9ba59e3e70df71',int64), int(z'3fef9fff39b6a330',int64), &
   int(z'3fe8f1b2a7f515a0',int64), int(z'3fe0304863064158',int64), int(z'bfd02ffeacbaada8',int64), int(z'3fb55309f27448c0',int64), &
   int(z'3f58b6d64850006b',int64), int(z'bf9b205f742323df',int64), int(z'3fefc001aa76c0b9',int64), int(z'3fe901dc15d66d80',int64), &
   int(z'3fe0201f28d9b4aa',int64), int(z'bfd01ffea98d4c38',int64), int(z'3fb55452089780f8',int64), int(z'3f5050b57f35c5bb',int64), &
   int(z'bf9a9c9fe19247af',int64), int(z'3fefdffe39a592ca',int64), int(z'3fe911f26d88a780',int64), int(z'3fe01008e40c6538',int64), &
   int(z'bfd01000d31688de',int64), int(z'3fb55514e32f1816',int64), int(z'3f402a154e1628d2',int64), int(z'bf9a1a5ff4faf5a0',int64), &
   int(z'3feff8018e92d1b0',int64), int(z'3fe91dfb9bb4bf00',int64), int(z'3fe003ffb884c5a9',int64), int(z'bfd003ff3876a954',int64), &
                               int(z'3fb555515539ddfb', int64), int(z'3f2007e77b95e6c2', int64), int(z'bf99b9a718a3ba58', int64)]
  real(real64), parameter :: atan_table(0:6, 0:240) = reshape(transfer(table_words, [0.0_real64], 1687), [7, 241])
contains
!> Return atan(argument) in radians for every finite input FP64 word.
!! ARGUMENT is a dimensionless input scalar, passed by value through ISO C.
!! Existing status and errno follow each actual operation; no flags are repaired.
  real(c_double) function original_rounding_atan(argument) bind(C, name='md2asm_atan_original_rounding') result(answer)
    real(c_double), value, intent(in) :: argument
    real(real64) :: magnitude, square, reciprocal, product, error, offset, poly, high, low, cube, temporary
    real(real64), volatile :: underflow_sink
    integer :: index
    integer(int64) :: word
    call require_private_math_environment()
    word = transfer(argument, word)
    if (ibits(word, 52, 11) == 2047_int64) call public_abort()
    magnitude = abs(argument)
    if (magnitude < a) then
      if (magnitude < minnormal) underflow_sink = magnitude*magnitude
      answer = argument
      return
    else if (magnitude < b) then
      square = argument*argument
      poly = atan_polynomial(square)
      cube = argument*square
      answer = rounded_product_sum(cube, poly, argument)
      return
    else if (magnitude < 1.0_real64) then
      index = atan_table_index(magnitude)
      offset = magnitude - atan_table(0, index)
      poly = atan_table_polynomial(offset, index, .false.)
      answer = rounded_product_sum(offset, poly, atan_table(1, index))
    else if (magnitude < 16.0_real64) then
      reciprocal = 1.0_real64/magnitude
      product = reciprocal*magnitude
      temporary = rounded_product_sum(reciprocal, magnitude, -product)
      error = 1.0_real64 - product
      error = error - temporary
      index = atan_table_index(reciprocal)
      offset = reciprocal - atan_table(0, index)
      offset = rounded_product_sum(error, reciprocal, offset)
      poly = atan_table_polynomial(offset, index, .false.)
      low = rounded_product_sum(-offset, poly, hpi1)
      high = hpi - atan_table(1, index)
      answer = high + low
    else if (magnitude < e) then
      reciprocal = 1.0_real64/magnitude
      square = reciprocal*reciprocal
      product = reciprocal*magnitude
      temporary = rounded_product_sum(reciprocal, magnitude, -product)
      error = 1.0_real64 - product
      error = error - temporary
      high = hpi - reciprocal
      temporary = hpi - high
      temporary = temporary - reciprocal
      low = hpi1 + temporary
      poly = atan_polynomial(square)
      cube = reciprocal*square
      low = rounded_product_sum(-error, reciprocal, low)
      low = rounded_product_sum(-cube, poly, low)
      answer = high + low
    else
      answer = hpi
    end if
    answer = copy_original_sign(answer, argument)
  end function
!> Evaluate the complete odd correction in the source coefficient order.
  real(real64) function atan_polynomial(square) result(poly)
    real(real64), intent(in) :: square
    poly = rounded_product_sum(square, d13, d11)
    poly = rounded_product_sum(square, poly, d9)
    poly = rounded_product_sum(square, poly, d7)
    poly = rounded_product_sum(square, poly, d5)
    poly = rounded_product_sum(square, poly, d3)
  end function
!> Select the proven table row0:240 using the original nearest-even sum.
  integer function atan_table_index(value) result(index)
    real(real64), intent(in) :: value
    real(real64) :: rounded
    rounded = rounded_product_sum(value, factor256, two52)
    rounded = rounded - two52
    index = int(rounded) - 16
    if (index < 0 .or. index > 240) call public_abort()
  end function
!> Return table coefficient2, or coefficient3 for the compensated direction path.
  real(real64) function atan_table_polynomial(offset, index, stop_at_three) result(poly)
    real(real64), intent(in) :: offset
    integer, intent(in) :: index
    logical, intent(in) :: stop_at_three
    poly = rounded_product_sum(offset, atan_table(6, index), atan_table(5, index))
    poly = rounded_product_sum(offset, poly, atan_table(4, index))
    poly = rounded_product_sum(offset, poly, atan_table(3, index))
    if (.not. stop_at_three) poly = rounded_product_sum(offset, poly, atan_table(2, index))
  end function
!> Copy only the original sign bit, including negative zero, without arithmetic.
  pure real(real64) function copy_original_sign(value, sign_source) result(answer)
    real(real64), intent(in) :: value, sign_source
    integer(int64) :: word, source_word
    word = transfer(value, word)
    source_word = transfer(sign_source, source_word)
    word = ior(iand(word, int(z'7FFFFFFFFFFFFFFF', int64)), iand(source_word, int(z'8000000000000000', int64)))
    answer = transfer(word, answer)
  end function
end module forecast_original_rounding_atan
