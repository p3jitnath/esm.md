! Algorithm and literal data derived from GNU libc2.38 IBM Accurate Math Library.
! Copyright (C)2001-2023 Free Software Foundation, Inc.
! This derived component is licensed under LGPL-2.1-or-later.
!> Bounded inverse sine and cosine with the frozen rounded arithmetic.
!> Inputs are finite and within[-1,1]; outputs are radians. Caller establishes
!> round-to-nearest and gradual underflow. No allocation or global data is used.
module forecast_source_rounding_inverse_trigonometry
  use iso_fortran_env, only: int32, int64, real64
  use forecast_spline_scalar_inverse, only: rounded_product_sum
  implicit none
  private
  public :: original_rounding_asine, original_rounding_acosine
  interface
    subroutine reject_contract() bind(c, name='abort')
    end subroutine
  end interface
  integer(int64), parameter :: coefficients_words(0:12) = [ &
       int(z'3fc55555555554f9',int64),int(z'3fb333333336127d',int64),int(z'3fa6db6dae42c0e4',int64),int(z'3f9f1c7e04f4ad99',int64),&
       int(z'3f96e442c822d419',int64),int(z'3f9292d80f453c72',int64),int(z'3fefffffffecc1dd',int64),int(z'3fdfffffff757304',int64),&
       int(z'3fd800496769c91a',int64),int(z'3fd4006318d1dab9',int64),int(z'3ff921fb54442d18',int64),int(z'3c91a62633145c07',int64),&
                               int(z'41a0000000000000', int64)]
  real(real64), parameter :: coefficients(0:12) = transfer(coefficients_words, [0.0_real64], 13)
  integer(int64), parameter :: inverse_table_words(0:2567) = [ &
       int(z'3fc0400000000000',int64),int(z'3ff0216988994424',int64),int(z'3fb0a6a2b799b115',int64),int(z'3fc6ef15d57409a0',int64),&
       int(z'3faa141eaf52eaa0',int64),int(z'3fb75591abbbe261',int64),int(z'3fa72b51d206d88f',int64),int(z'3c96b5955bb33e7d',int64),&
       int(z'3fc04b41a03e2700',int64),int(z'3ff0400000000000',int64),int(z'bf7e967766bbdc7c',int64),int(z'3fc0c00000000000',int64),&
       int(z'3ff02386f9e23a56',int64),int(z'3fb1308c60fd0235',int64),int(z'3fc7099f14d16b02',int64),int(z'3faafed627c01ee1',int64),&
       int(z'3fb79c6fdbcd5f98',int64),int(z'3fa8144a4084daac',int64),int(z'bc87c09238d8505e',int64),int(z'3fc0cc5556c9f380',int64),&
       int(z'3ff0400000000000',int64),int(z'bf7c79061dc5aa24',int64),int(z'3fc1400000000000',int64),int(z'3ff025b5b27141f6',int64),&
       int(z'3fb1bb1804ce7400',int64),int(z'3fc7251472907342',int64),int(z'3fabec600bf4222c',int64),int(z'3fb7e61075b3736c',int64),&
       int(z'3fa9024c5199c343',int64),int(z'bc8ae84c06b56f60',int64),int(z'3fc14d7a3defa070',int64),int(z'3ff0400000000000',int64),&
       int(z'bf7a4a4d8ebe0a5c',int64),int(z'3fc1c00000000000',int64),int(z'3ff027f5c6de8f57',int64),int(z'3fb2464b345751e1',int64),&
       int(z'3fc74178cf026805',int64),int(z'3facdcd840a9e0d6',int64),int(z'3fb83282eb1d9c38',int64),int(z'3fa9f590d7be707b',int64),&
       int(z'bcab976803a2a6d6',int64),int(z'3fc1ceb0e03b4870',int64),int(z'3ff0400000000000',int64),int(z'bf780a392170a943',int64),&
       int(z'3fc2400000000000',int64),int(z'3ff02a474c759796',int64),int(z'3fb2d22b92771935',int64),int(z'3fc75ecf26aba06d',int64),&
       int(z'3fadd05b486a1932',int64),int(z'3fb881d75af971d5',int64),int(z'3faaee52831aee0c',int64),int(z'3ca13f57ad1b1bef',int64),&
       int(z'3fc24ff9c8e09330',int64),int(z'3ff0400000000000',int64),int(z'bf75b8b38a68699b',int64),int(z'3fc2c00000000000',int64),&
       int(z'3ff02caa59374e09',int64),int(z'3fb35ebed44e8bea',int64),int(z'3fc77d1a92e4be8a',int64),int(z'3faec7064a6c34fd',int64),&
       int(z'3fb8d41e972f6e07',int64),int(z'3fabeccdf9845f69',int64),int(z'3c8ba1fa945c4185',int64),int(z'3fc2d15583c058b0',int64),&
       int(z'3ff0400000000000',int64),int(z'bf7355a6c8b1f774',int64),int(z'3fc3400000000000',int64),int(z'3ff02f1f03dc7745',int64),&
       int(z'3fb3ec0ac1ee9f61',int64),int(z'3fc79c5e4a82e6d2',int64),int(z'3fafc0f719b1ef72',int64),int(z'3fb9296a2aa943e5',int64),&
       int(z'3facf141ef8b9de7',int64),int(z'bc834081083c8716',int64),int(z'3fc352c49d6e5610',int64),int(z'3ff0400000000000',int64),&
       int(z'bf70e0fc2388bb30',int64),int(z'3fc3c00000000000',int64),int(z'3ff031a563d81251',int64),int(z'3fb47a15370b721f',int64),&
       int(z'3fc7bc9da28731e5',int64),int(z'3fb05f261e305be9',int64),int(z'3fb981cc5fa50fbd',int64),int(z'3fadfbef42ac4083',int64),&
       int(z'3ca20acba8e107c7',int64),int(z'3fc3d447a336f5e0',int64),int(z'3ff0400000000000',int64),int(z'bf6cb5384fdb5d5c',int64),&
       int(z'3fc4400000000000',int64),int(z'3ff0343d9159d86f',int64),int(z'3fb508e423b3747c',int64),int(z'3fc7dddc0ed597cb',int64),&
       int(z'3fb0df9279adf104',int64),int(z'3fb9dd584658d945',int64),int(z'3faf0d1914aca06b',int64),int(z'bca4e10ddf636efe',int64),&
       int(z'3fc455df23252c00',int64),int(z'3ff0400000000000',int64),int(z'bf6784dd4c4f221a',int64),int(z'3fc4c00000000000',int64),&
       int(z'3ff036e7a550d410',int64),int(z'3fb5987d8d0af1e7',int64),int(z'3fc8001d22f39726',int64),int(z'3fb161d0a1116d73',int64),&
       int(z'3fba3c21bbea1528',int64),int(z'3fb0128274202ff6',int64),int(z'3caa0611d10866e2',int64),int(z'3fc4d78bac086560',int64),&
       int(z'3ff0400000000000',int64),int(z'bf6230b55e57df8a',int64),int(z'3fc5400000000000',int64),int(z'3ff039a3b96e0f8a',int64),&
       int(z'3fb628e78e0c29f6',int64),int(z'3fc8236492cede01',int64),int(z'3fb1e5f0fb7b5d84',int64),int(z'3fba9e3d71bd08ee',int64),&
       int(z'3fb0a1fd5f7ffab4',int64),int(z'bc90f980ef04f6e7',int64),int(z'3fc5594dcd7a8dc0',int64),int(z'3ff0400000000000',int64),&
       int(z'bf59711a47c1d879',int64),int(z'3fc5c00000000000',int64),int(z'3ff03c71e8275c12',int64),int(z'3fb6ba28584c2a23',int64),&
       int(z'3fc847b6338c3d4b',int64),int(z'3fb26c0459a55dd8',int64),int(z'3fbb03c0f5202d6a',int64),int(z'3fb135229c6466a4',int64),&
       int(z'3c983c9a2a268973',int64),int(z'3fc5db2617e62a20',int64),int(z'3ff0400000000000',int64),int(z'bf4c70bec51f7008',int64),&
       int(z'3fc6400000000000',int64),int(z'3ff03f524cba31a9',int64),int(z'3fb74c4634c49ade',int64),int(z'3fc86d15fc5f33cc',int64),&
       int(z'3fb2f41bfa419d7c',int64),int(z'3fbb6cc2b757e82a',int64),int(z'3fb1cc18da4d5c39',int64),int(z'bca862d42dfb224d',int64),&
       int(z'3fc65d151c8c8af0',int64),int(z'3ff0400000000000',int64),int(z'bf25b668b9cadbbf',int64),int(z'3fc6c00000000000',int64),&
       int(z'3ff04245032ea88f',int64),int(z'3fb7df4784a2b473',int64),int(z'3fc89388076a60f5',int64),int(z'3fb37e498e8394c1',int64),&
       int(z'3fbbd95a160f3472',int64),int(z'3fb2670839844810',int64),int(z'3c994228698bc8ea',int64),int(z'3fc6df1b6d8c14a0',int64),&
       int(z'3ff0400000000000',int64),int(z'3f422819754477ac',int64),int(z'3fc7400000000000',int64),int(z'3ff0454a285a8ceb',int64),&
       int(z'3fb87332c21b9224',int64),int(z'3fc8bb1092a93402',int64),int(z'3fb40a9f3ed3f586',int64),int(z'3fbc499f643217c8',int64),&
       int(z'3fb3061a5d29a16b',int64),int(z'bca3b2df3df9f2d7',int64),int(z'3fc761399de6a160',int64),int(z'3ff0400000000000',int64),&
       int(z'3f5528a16a33ab4b',int64),int(z'3fc7c00000000000',int64),int(z'3ff04861d9e48d58',int64),int(z'3fb9080e81461bf6',int64),&
       int(z'3fc8e3b400e32ffa',int64),int(z'3fb4992fafb1f2a5',int64),int(z'3fbcbdabf33705d5',int64),int(z'3fb3a97a7e23ee89',int64),&
       int(z'3c7aad12cce44c41',int64),int(z'3fc7e3704187fae0',int64),int(z'3ff0400000000000',int64),int(z'3f60c3b3c91aaf11',int64),&
       int(z'3fc8400000000000',int64),int(z'3ff04b8c36478509',int64),int(z'3fb99de170fac1b4',int64),int(z'3fc90d76daa92166',int64),&
       int(z'3fb52a0e06c416a6',int64),int(z'3fbd359a1cdca344',int64),int(z'3fb451557efd4ca0',int64),int(z'3c396ca535a8895d',int64),&
       int(z'3fc865bfed4c6ef0',int64),int(z'3ff0400000000000',int64),int(z'3f67186c8f0a11a4',int64),int(z'3fc8c00000000000',int64),&
       int(z'3ff04ec95cd5e248',int64),int(z'3fba34b25bb94403',int64),int(z'3fc9385dcf5ca73a',int64),int(z'3fb5bd4df01afdbe',int64),&
       int(z'3fbdb1854d61a7a9',int64),int(z'3fb4fdda00bd47cf',int64),int(z'bc9d1119727e8b64',int64),int(z'3fc8e82937077e20',int64),&
       int(z'3ff0400000000000',int64),int(z'3f6d92b9abc490cb',int64),int(z'3fc9400000000000',int64),int(z'3ff052196dbd2a10',int64),&
       int(z'3fbacc882894caa1',int64),int(z'3fc9646db6427516',int64),int(z'3fb65303a3a864d7',int64),int(z'3fbe318a0e3cf3d4',int64),&
       int(z'3fb5af3878cda678',int64),int(z'3ca3841dda9d51df',int64),int(z'3fc96aacb58aa660',int64),int(z'3ff0400000000000',int64),&
       int(z'3f72196dbd2a1052',int64),int(z'3fc9c00000000000',int64),int(z'3ff0557c8a099990',int64),int(z'3fbb6569dc268965',int64),&
       int(z'3fc991ab8f9fba21',int64),int(z'3fb6eb43eaed1e85',int64),int(z'3fbeb5c6115c4c63',int64),int(z'3fb665a347f9aefa',int64),&
       int(z'bca1f8fd03ab3673',int64),int(z'3fc9ed4b00ac4a60',int64),int(z'3ff0400000000000',int64),int(z'3f757c8a0999905b',int64),&
       int(z'3fca400000000000',int64),int(z'3ff058f2d3a9e674',int64),int(z'3fbbff5e99873832',int64),int(z'3fc9c01c85e31ce9',int64),&
       int(z'3fb7862426e09ff2',int64),int(z'3fbf3e583cf0885c',int64),int(z'3fb7214ed2986239',int64),int(z'3c97e3e53e594694',int64),&
       int(z'3fca7004b14eb5d0',int64),int(z'3ff0400000000000',int64),int(z'3f78f2d3a9e6746b',int64),int(z'3fcac00000000000',int64),&
       int(z'3ff05c7c6d731ecb',int64),int(z'3fbc9a6da34fa4b3',int64),int(z'3fc9efc5eed9c253',int64),int(z'3fb823ba5614faeb',int64),&
       int(z'3fbfcb60b7ce698f',int64),int(z'3fb7e27199f3292f',int64),int(z'bc9842c6068d709c',int64),int(z'3fcaf2da61674110',int64),&
       int(z'3ff0400000000000',int64),int(z'3f7c7c6d731ecae2',int64),int(z'3fcb400000000000',int64),int(z'3ff060197b24a973',int64),&
       int(z'3fbd369e5ca0a798',int64),int(z'3fca20ad4cf0db64',int64),int(z'3fb8c41d1b1a3f31',int64),int(z'3fc02e807b35e049',int64),&
       int(z'3fb8a94456fb8a97',int64),int(z'bcacbf9cd337b37c',int64),int(z'3fcb75ccac059370',int64),int(z'3ff0800000000000',int64),&
       int(z'bf7fe684db568d78',int64),int(z'3fcbc00000000000',int64),int(z'3ff063ca216c6801',int64),int(z'3fbdd3f84a32c9fd',int64),&
       int(z'3fca52d850843bc9',int64),int(z'3fb96763c324648a',int64),int(z'3fc079ade4407899',int64),int(z'3fb976021663a5dc',int64),&
       int(z'bca3adc3c637289d',int64),int(z'3fcbf8dc2d5b06a0',int64),int(z'3ff0800000000000',int64),int(z'bf7c35de9397fea6',int64),&
       int(z'3fcc400000000000',int64),int(z'3ff0678e85eafb1f',int64),int(z'3fbe7283136deac6',int64),int(z'3fca864cd93a817d',int64),&
       int(z'3fba0da64cf7089b',int64),int(z'3fc0c74ab3abb322',int64),int(z'3fba48e8562e6e1e',int64),int(z'bc951e3e7eb8fff8',int64),&
       int(z'3fcc7c0982c22b80',int64),int(z'3ff0800000000000',int64),int(z'bf78717a1504e0d3',int64),int(z'3fccc00000000000',int64),&
       int(z'3ff06b66cf382a59',int64),int(z'3fbf1246838936fb',int64),int(z'3fcabb10f76f5c94',int64),int(z'3fbab6fd701a77ae',int64),&
       int(z'3fc11769c26702c6',int64),int(z'3fbb223724cdf38e',int64),int(z'bc8db69ae28307a9',int64),int(z'3fccff554ac67190',int64),&
       int(z'3ff0800000000000',int64),int(z'bf749930c7d5a6b9',int64),int(z'3fcd400000000000',int64),int(z'3ff06f5324e7707f',int64),&
       int(z'3fbfb34a8ab3cbb2',int64),int(z'3fcaf12aedac8d74',int64),int(z'3fbb6382a45da614',int64),int(z'3fc16a1ead8e9f44',int64),&
       int(z'3fbc023141e7749d',int64),int(z'3c76ca2722dc16a2',int64),int(z'3fcd82c0252bf240',int64),int(z'3ff0800000000000',int64),&
       int(z'bf70acdb188f814b',int64),int(z'3fcdc00000000000',int64),int(z'3ff07353af8cada0',int64),int(z'3fc02acb9fa32dc9',int64),&
       int(z'3fcb28a132323718',int64),int(z'3fbc135029a8f15e',int64),int(z'3fc1bf7ddeb270e1',int64),int(z'3fbce91c40d67463',int64),&
       int(z'3ca6e976104baa08',int64),int(z'3fce064ab2f76140',int64),int(z'3ff0800000000000',int64),int(z'bf6958a0e6a4bfc9',int64),&
       int(z'3fce400000000000',int64),int(z'3ff0776898c0ffd9',int64),int(z'3fc07c9a6f7f1af0',int64),int(z'3fcb617a708f2afb',int64),&
       int(z'3fbcc6811025b50c',int64),int(z'3fc2179c9487453a',int64),int(z'3fbdd740ad09b3ab',int64),int(z'bc8d32db189038c0',int64),&
       int(z'3fce89f596762300',int64),int(z'3ff0800000000000',int64),int(z'bf612ece7e004d50',int64),int(z'3fcec00000000000',int64),&
       int(z'3ff07b920b27c417',int64),int(z'3fc0cf15e821087a',int64),int(z'3fcb9bbd8b49dc8c',int64),int(z'3fbd7d3140bef5c2',int64),&
       int(z'3fc27290ec080575',int64),int(z'3fbeccea3056a6a9',int64),int(z'3c9de5060c9b27a2',int64),int(z'3fcf0dc173468a50',int64),&
       int(z'3ff0800000000000',int64),int(z'bf51b7d360efa34d',int64),int(z'3fcf400000000000',int64),int(z'3ff07fd03273c018',int64),&
       int(z'3fc1224251b87f08',int64),int(z'3fcbd7719d9ab2bc',int64),int(z'3fbe377d85ffa125',int64),int(z'3fc2d071ea0cfe55',int64),&
       int(z'3fbfca67bb61ddd3',int64),int(z'bca2538388a645e7',int64),int(z'3fcf91aeee603f40',int64),int(z'3ff0800000000000',int64),&
       int(z'bf07e6c61ff422b6',int64),int(z'3fcfc00000000000',int64),int(z'3ff084233b6c76f2',int64),int(z'3fc176240a1df897',int64),&
       int(z'3fcc149dfd38779d',int64),int(z'3fbef58395531ecd',int64),int(z'3fc33157855fa966',int64),int(z'3fc06805d81e6baa',int64),&
       int(z'3c86827e1b47faec',int64),int(z'3fd00adf570e6798',int64),int(z'3ff0800000000000',int64),int(z'3f508cedb1dbc656',int64),&
       int(z'3fd0200000000000',int64),int(z'3ff0888b53f3a97b',int64),int(z'3fc1cabf858525d6',int64),int(z'3fcc534a3c37af90',int64),&
       int(z'3fbfb76218ad312a',int64),int(z'3fc3955ab151caad',int64),int(z'3fc0ef1607ade82d',int64),int(z'3caeef44fcde8746',int64),&
       int(z'3fd04cf8ad203480',int64),int(z'3ff0800000000000',int64),int(z'3f6116a7e752f5a1',int64),int(z'3fd0600000000000',int64),&
       int(z'3ff08d08ab0b03f8',int64),int(z'3fc220194f34eee8',int64),int(z'3fcc937e2afdabde',int64),int(z'3fc03e9c5c4f35ba',int64),&
       int(z'3fc3fc9568df21a6',int64),int(z'3fc17a9153843c52',int64),int(z'bc9d6f54c2bb835a',int64),int(z'3fd08f23ce0162b8',int64),&
       int(z'3ff0800000000000',int64),int(z'3f6a11561607ef23',int64),int(z'3fd0a00000000000',int64),int(z'3ff0919b70d9fa87',int64),&
       int(z'3fc276360a456c09',int64),int(z'3fccd541da483778',int64),int(z'3fc0a394136d6630',int64),int(z'3fc46722ba615e9c',int64),&
       int(z'3fc20aa6a2bc6f73',int64),int(z'3ca9d0067f1d9d86',int64),int(z'3fd0d1610f0c1ec8',int64),int(z'3ff0800000000000',int64),&
       int(z'3f719b70d9fa8688',int64),int(z'3fd0e00000000000',int64),int(z'3ff09643d6b3d5d1',int64),int(z'3fc2cd1a72641546',int64),&
       int(z'3fcd189d9d4ac7ec',int64),int(z'3fc10aa9149c2e66',int64),int(z'3fc4d51ed3de8741',int64),int(z'3fc29f86f6da4768',int64),&
       int(z'3caea900828c2a81',int64),int(z'3fd113b0c65d88c8',int64),int(z'3ff0800000000000',int64),int(z'3f7643d6b3d5d119',int64),&
       int(z'3fd1200000000000',int64),int(z'3ff09b020f1df195',int64),int(z'3fc324cb5c9e6b3f',int64),int(z'3fcd5d9a0be228b7',int64),&
       int(z'3fc173ecd29602b0',int64),int(z'3fc546a70ffa7799',int64),int(z'3fc3396587ba569f',int64),int(z'bcae32589956f2c3',int64),&
       int(z'3fd156134ada6ff0',int64),int(z'3ff0800000000000',int64),int(z'3f7b020f1df1952f',int64),int(z'3fd1600000000000',int64),&
       int(z'3ff09fd64dd62eb0',int64),int(z'3fc37d4db8335de5',int64),int(z'3fcda44004dfa3f1',int64),int(z'3fc1df7155e59412',int64),&
       int(z'3fc5bbda0394b72e',int64),int(z'3fc3d877e1177398',int64),int(z'3ca8ac883b5720a7',int64),int(z'3fd19888f43427a8',int64),&
       int(z'3ff0800000000000',int64),int(z'3f7fd64dd62eaf85',int64),int(z'3fd1a00000000000',int64),int(z'3ff0a4c0c7d99a5f',int64),&
       int(z'3fc3d6a68f6bb942',int64),int(z'3fcdec98b06cb8a9',int64),int(z'3fc24d49432c74b1',int64),int(z'3fc634d78c1c6ec6',int64),&
       int(z'3fc47cf601bf2560',int64),int(z'3ca3ede7476e25c7',int64),int(z'3fd1db121aed7720',int64),int(z'3ff0c00000000000',int64),&
       int(z'bf7b3f382665a126',int64),int(z'3fd1e00000000000',int64),int(z'3ff0a9c1b36b4c8b',int64),int(z'3fc430db0879e39b',int64),&
       int(z'3fce36ad82887d8b',int64),int(z'3fc2bd87e1b33c79',int64),int(z'3fc6b1c0dea4e95e',int64),int(z'3fc5271a7c90504a',int64),&
       int(z'3caafad98a6ebd08',int64),int(z'3fd21daf185fa360',int64),int(z'3ff0c00000000000',int64),int(z'bf763e4c94b3751c',int64),&
       int(z'3fd2200000000000',int64),int(z'3ff0aed9481b7eed',int64),int(z'3fc48bf066613bb3',int64),int(z'3fce82883d9fdd8f',int64),&
       int(z'3fc3304122470bf2',int64),int(z'3fc732b897c5b476',int64),int(z'3fc5d7229b614f73',int64),int(z'3ca96b82759745c8',int64),&
       int(z'3fd2606046bf95b8',int64),int(z'3ff0c00000000000',int64),int(z'bf7126b7e48112dc',int64),int(z'3fd2600000000000',int64),&
       int(z'3ff0b407becedf0e',int64),int(z'3fc4e7ec09e5699a',int64),int(z'3fced032f541ec2d',int64),int(z'3fc3a589a6688484',int64),&
       int(z'3fc7b7e2cc5228bd',int64),int(z'3fc68d4e83ecad1f',int64),int(z'3ca985867cb79363',int64),int(z'3fd2a32601231ec8',int64),&
       int(z'3ff0c00000000000',int64),int(z'bf67f0826241e449',int64),int(z'3fd2a00000000000',int64),int(z'3ff0b94d51c61d1c',int64),&
       int(z'3fc544d37281f837',int64),int(z'3fcf1fb810f19f89',int64),int(z'3fc41d76c7d08a44',int64),int(z'3fc841651af4e5e6',int64),&
       int(z'3fc749e15ee5d838',int64),int(z'3c8a2a36a1f9a890',int64),int(z'3fd2e600a3865760',int64),int(z'3ff0c00000000000',int64),&
       int(z'bf5acab8e78b8e2f',int64),int(z'3fd2e00000000000',int64),int(z'3ff0beaa3ca5b9c1',int64),int(z'3fc5a2ac3f6a91d3',int64),&
       int(z'3fcf71224f1650db',int64),int(z'3fc4981ea04f63e7',int64),int(z'3fc8cf66bebc9b64',int64),int(z'3fc80d2181598bf7',int64),&
       int(z'bc9841438e0fd320',int64),int(z'3fd328f08ad12008',int64),int(z'3ff0c00000000000',int64),int(z'bf355c35a463f3fd',int64),&
       int(z'3fd3200000000000',int64),int(z'3ff0c41ebc7e151a',int64),int(z'3fc6017c30943e19',int64),int(z'3fcfc47cc80c760d',int64),&
       int(z'3fc51598120b129d',int64),int(z'3fc96210a2a855b5',int64),int(z'3fc8d7589880230d',int64),int(z'bca4d129bf178596',int64),&
       int(z'3fd36bf614dcc050',int64),int(z'3ff0c00000000000',int64),int(z'3f507af1f854661e',int64),int(z'3fd3600000000000',int64),&
       int(z'3ff0c9ab0fd3c135',int64),int(z'3fc6614927c80482',int64),int(z'3fd00ce978ac0ddd',int64),int(z'3fc595fad02204b1',int64),&
       int(z'3fc9f98d7642750d',int64),int(z'3fc9a8d3d82ac48a',int64),int(z'3c977587289b3951',int64),int(z'3fd3af11a079a6d8',int64),&
       int(z'3ff0c00000000000',int64),int(z'3f63561fa7826a0d',int64),int(z'3fd3a00000000000',int64),int(z'3ff0cf4f76a81a69',int64),&
       int(z'3fc6c21929bf5acd',int64),int(z'3fd03898507d5dd4',int64),int(z'3fc6195f67b79439',int64),int(z'3fca9609c35a709f',int64),&
       int(z'3fca81e42bf7455c',int64),int(z'3ca03304f424551e',int64),int(z'3fd3f2438d754b40',int64),int(z'3ff0c00000000000',int64),&
       int(z'3f6e9eed5034d2a8',int64),int(z'3fd3e00000000000',int64),int(z'3ff0d50c3282280d',int64),int(z'3fc723f25f4acc23',int64),&
       int(z'3fd0655108771131',int64),int(z'3fc69fdf4970163e',int64),int(z'3fcb37b404ee9a0a',int64),int(z'3fcb62de6b79bc18',int64),&
       int(z'3caecf2502a2f456',int64),int(z'3fd4358c3ca032e0',int64),int(z'3ff0c00000000000',int64),int(z'3f750c3282280d28',int64),&
       int(z'3fd4200000000000',int64),int(z'3ff0dae18677c82d',int64),int(z'3fc786db16834abe',int64),int(z'3fd09319f1631731',int64),&
       int(z'3fc72994d36297af',int64),int(z'3fcbdebcbf583888',int64),int(z'3fcc4c1b918e2ae6',int64),int(z'3ca92f70f34a155c',int64),&
       int(z'3fd478ec0fd419c8',int64),int(z'3ff0c00000000000',int64),int(z'3f7ae18677c82d53',int64),int(z'3fd4600000000000',int64),&
       int(z'3ff0e0cfb73728f8',int64),int(z'3fc7ead9c406a36a',int64),int(z'3fd0c1f991bda616',int64),int(z'3fc7b69b5b86c42b',int64),&
       int(z'3fcc8b5699cd8c9f',int64),int(z'3fcd3df8f7084936',int64),int(z'bc923b7454942387',int64),int(z'3fd4bc6369fa40e8',int64),&
       int(z'3ff1000000000000',int64),int(z'bf7f3048c8d707bb',int64),int(z'3fd4a00000000000',int64),int(z'3ff0e6d70b1092b8',int64),&
       int(z'3fc84ff5043f9011',int64),int(z'3fd0f1f6a7afd6eb',int64),int(z'3fc8470f3aa5d7b9',int64),int(z'3fcd3db6794e9cfd',int64),&
       int(z'3fce38d890fb69fd',int64),int(z'3c9cfa2dc2327dc5',int64),int(z'3fd4fff2af11e2c0',int64),int(z'3ff1000000000000',int64),&
       int(z'bf7928f4ef6d4848',int64),int(z'3fd4e00000000000',int64),int(z'3ff0ecf7ca008550',int64),int(z'3fc8b6339cb9eca7',int64),&
       int(z'3fd123182b20ac3d',int64),int(z'3fc8db0dd7d5e860',int64),int(z'3fcdf6139d1315af',int64),int(z'3fcf3d2132d8bc6f',int64),&
       int(z'3c9c6a3692e48eee',int64),int(z'3fd5439a4436d008',int64),int(z'3ff1000000000000',int64),int(z'bf730835ff7aaf92',int64),&
       int(z'3fd5200000000000',int64),int(z'3ff0f3323dba2c62',int64),int(z'3fc91d9c7d83983c',int64),int(z'3fd155654fdda02e',int64),&
       int(z'3fc972b5b48747c7',int64),int(z'3fceb4a7bc9105f9',int64),int(z'3fd0259f6a535ecf',int64),int(z'3c87eb36f6ea55c1',int64),&
       int(z'3fd5875a8fa83538',int64),int(z'3ff1000000000000',int64),int(z'bf699b848ba73c6a',int64),int(z'3fd5600000000000',int64),&
       int(z'3ff0f986b1b22d42',int64),int(z'3fc98636c29a92ed',int64),int(z'3fd188e587dbe62d',int64),int(z'3fca0e26792c37eb',int64),&
       int(z'3fcf79af2735e8cd',int64),int(z'3fd0b1d16eccd4c0',int64),int(z'3c9502b5beae0510',int64),int(z'3fd5cb33f8cf8ac0',int64),&
       int(z'3ff1000000000000',int64),int(z'bf59e539374af74c',int64),int(z'3fd5a00000000000',int64),int(z'3ff0fff57329d23a',int64),&
       int(z'3fc9f009b568f082',int64),int(z'3fd1bda085939db2',int64),int(z'3fcaad810283b18a',int64),int(z'3fd022b472f69148',int64),&
       int(z'3fd1436239ad0b79',int64),int(z'bcad796880828b86',int64),int(z'3fd60f26e847b130',int64),int(z'3ff1000000000000',int64),&
       int(z'bee519ac5b8bc081',int64),int(z'3fd5e00000000000',int64),int(z'3ff1067ed13a9687',int64),int(z'3fca5b1cce4f3f61',int64),&
       int(z'3fd1f39e3e764545',int64),int(z'3fcb50e76f90871b',int64),int(z'3fd08c0b6f487f97',int64),int(z'3fd1da9067265c20',int64),&
       int(z'3cae5b02995723ad',int64),int(z'3fd65333c7e43aa0',int64),int(z'3ff1000000000000',int64),int(z'3f59fb44ea5a1d64',int64),&
       int(z'3fd6200000000000',int64),int(z'3ff10d231ce216d9',int64),int(z'3fcac777b63e0b53',int64),int(z'3fd22ae6ed81d055',int64),&
       int(z'3fcbf87d3046c5ac',int64),int(z'3fd0f8fefcb29fe4',int64),int(z'3fd2779dc99a404e',int64),int(z'bca2af1ec3202ae8',int64),&
       int(z'3fd6975b02b8e378',int64),int(z'3ff1000000000000',int64),int(z'3f6a4639c42db2ab',int64),int(z'3fd6600000000000',int64),&
       int(z'3ff113e2a90e6a24',int64),int(z'3fcb3522485f2c6b',int64),int(z'3fd2638315f1d6cc',int64),int(z'3fcca46714f9d555',int64),&
       int(z'3fd169b3245e397e',int64),int(z'3fd31acf99479cf7',int64),int(z'bc730d3f8992c228',int64),int(z'3fd6db9d05213b28',int64),&
       int(z'3ff1000000000000',int64),int(z'3f73e2a90e6a2469',int64),int(z'3fd6a00000000000',int64),int(z'3ff11abdcaaae6d5',int64),&
       int(z'3fcba42493cf9b23',int64),int(z'3fd29d7b86106ad4',int64),int(z'3fcd54cb5e96870b',int64),int(z'3fd1de4d9975d46d',int64),&
       int(z'3fd3c46ea709f8a4',int64),int(z'bc9cb630457b6f5c',int64),int(z'3fd71ffa3cc87fc8',int64),int(z'3ff1000000000000',int64),&
       int(z'3f7abdcaaae6d53d',int64),int(z'3fd6e00000000000',int64),int(z'3ff121b4d8ad589e',int64),int(z'3fcc1486dd6a8c89',int64),&
       int(z'3fd2d8d95a283891',int64),int(z'3fce09d1cfb4f5a1',int64),int(z'3fd256f5cf594bb6',int64),int(z'3fd474c792614c29',int64),&
       int(z'bc88fb31533051e9',int64),int(z'3fd7647318b1ad28',int64),int(z'3ff1400000000000',int64),int(z'bf7e4b2752a761d6',int64),&
       int(z'3fd7200000000000',int64),int(z'3ff128c82c23ab4a',int64),int(z'3fcc8651a1a6a356',int64),int(z'3fd315a5ff99abe3',int64),&
       int(z'3fcec3a3be8ee4c2',int64),int(z'3fd2d3d511207d5d',int64),int(z'3fd52c2b02fe6df8',int64),int(z'bca3f304fe4d8df3',int64),&
       int(z'3fd7a908093fc1f0',int64),int(z'3ff1400000000000',int64),int(z'bf7737d3dc54b622',int64),int(z'3fd7600000000000',int64),&
       int(z'3ff12ff820420f33',int64),int(z'3fccf98d96860d89',int64),int(z'3fd353eb3814f292',int64),int(z'3fcf826c27e81bf7',int64),&
       int(z'3fd355169a827352',int64),int(z'3fd5eaede614c6df',int64),int(z'3c80aedb36c1700c',int64),int(z'3fd7edb9803e3c28',int64),&
       int(z'3ff1400000000000',int64),int(z'bf7007dfbdf0ccc6',int64),int(z'3fd7a00000000000',int64),int(z'3ff1374512719c3a',int64),&
       int(z'3fcd6e43ad9a717f',int64),int(z'3fd393b31cfacd12',int64),int(z'3fd0232be17b8f05',int64),int(z'3fd3dae7b23873bc',int64),&
       int(z'3fd6b169afb712e5',int64),int(z'3c994c0c0bc74599',int64),int(z'3fd83287f0e9cf80',int64),int(z'3ff1400000000000',int64),&
       int(z'bf6175db1cc78ca5',int64),int(z'3fd7e00000000000',int64),int(z'3ff13eaf625f7844',int64),int(z'3fcde47d161d9978',int64),&
       int(z'3fd3d50822e63dca',int64),int(z'3fd087ca8b2ec7eb',int64),int(z'3fd46577c5f619c8',int64),int(z'3fd77ffca08a73de',int64),&
       int(z'3ca1dbde6e7b547f',int64),int(z'3fd87773cff956f8',int64),int(z'3ff1400000000000',int64),int(z'bf3509da087bc752',int64),&
       int(z'3fd8200000000000',int64),int(z'3ff14637720c869d',int64),int(z'3fce5c433f1fd940',int64),int(z'3fd417f51d614654',int64),&
       int(z'3fd0ef2a472052ed',int64),int(z'3fd4f4f888116da6',int64),int(z'3fd8570a102117b6',int64),int(z'bcab6e89214a7328',int64),&
       int(z'3fd8bc7d93a70458',int64),int(z'3ff1400000000000',int64),int(z'3f58ddc8321a7479',int64),int(z'3fd8600000000000',int64),&
       int(z'3ff14ddda5dda5c4',int64),int(z'3fced59fd9cd3739',int64),int(z'3fd45c8542c70412',int64),int(z'3fd1596449c983a8',int64),&
       int(z'3fd5899e0ef7ed0b',int64),int(z'3fd936fabc543499',int64),int(z'3caff50d7b29f22e',int64),int(z'3fd901a5b3b9cf50',int64),&
       int(z'3ff1400000000000',int64),int(z'3f6bbb4bbb4b87e0',int64),int(z'3fd8a00000000000',int64),int(z'3ff155a264ac8172',int64),&
       int(z'3fcf509cdbca7047',int64),int(z'3fd4a2c43055a16f',int64),int(z'3fd1c692d25160c7',int64),int(z'3fd6239ef68f9906',int64),&
       int(z'3fda203d1dfc2ee2',int64),int(z'3cad2019671ef39f',int64),int(z'3fd946eca98f2718',int64),int(z'3ff1400000000000',int64),&
       int(z'3f75a264ac8171a9',int64),int(z'3fd8e00000000000',int64),int(z'3ff15d8617d8ff02',int64),int(z'3fcfcd4481aafd5e',int64),&
       int(z'3fd4eabdee72b776',int64),int(z'3fd236d1377f943f',int64),int(z'3fd6c33483a56db7',int64),int(z'3fdb1345c36d6c50',int64),&
       int(z'bc7841e5761537bb',int64),int(z'3fd98c52f024e808',int64),int(z'3ff1400000000000',int64),int(z'3f7d8617d8ff01de',int64),&
       int(z'3fd9200000000000',int64),int(z'3ff165892b5b4a9a',int64),int(z'3fd025d0a8c0a8c6',int64),int(z'3fd5347ef524e4b6',int64),&
       int(z'3fd2aa3bf565edbd',int64),int(z'3fd7689ac98d2842',int64),int(z'3fdc108fb128b4dd',int64),int(z'bc8a5eeb4452a669',int64),&
       int(z'3fd9d1d904239878',int64),int(z'3ff1800000000000',int64),int(z'bf7a76d4a4b56661',int64),int(z'3fd9600000000000',int64),&
       int(z'3ff16dac0dd68bc8',int64),int(z'3fd065df0ec54c3a',int64),int(z'3fd5801430c58a12',int64),int(z'3fd320f0bbcbccef',int64),&
       int(z'3fd81410d218f380',int64),int(z'3fdd189cc9371d29',int64),int(z'3c58c3c11d6e6ec7',int64),int(z'3fda177f63e8ef18',int64),&
       int(z'3ff1800000000000',int64),int(z'bf7253f229743866',int64),int(z'3fd9a00000000000',int64),int(z'3ff175ef30ac48a8',int64),&
       int(z'3fd0a6d3037ba7c0',int64),int(z'3fd5cd8b06edcd18',int64),int(z'3fd39b0e7d679188',int64),int(z'3fd8c5d8c8128143',int64),&
       int(z'3fde2bf639b3613a',int64),int(z'bc874080c70c9c76',int64),int(z'3fda5d468f92a560',int64),int(z'3ff1800000000000',int64),&
       int(z'bf64219ea76eb06e',int64),int(z'3fd9e00000000000',int64),int(z'3ff17e5308107eef',int64),int(z'3fd0e8b240691386',int64),&
       int(z'3fd61cf15ba2319a',int64),int(z'3fd418b57ff30656',int64),int(z'3fd97e3824624146',int64),int(z'3fdf4b2cf30d6589',int64),&
       int(z'bc8d4ad974dd0c9b',int64),int(z'3fdaa32f090998f8',int64),int(z'3ff1800000000000',int64),int(z'bf3acf7ef81116bc',int64),&
       int(z'3fda200000000000',int64),int(z'3ff186d80b1e7a9d',int64),int(z'3fd12b82a98356f0',int64),int(z'3fd66e5596c051d8',int64),&
       int(z'3fd49a076d28a49d',int64),int(z'3fda3d77de14d616',int64),int(z'3fe03b6d13502f53',int64),int(z'3ca517004ad59707',int64),&
       int(z'3fdae939540d3f08',int64),int(z'3ff1800000000000',int64),int(z'3f5b602c79ea752f',int64),int(z'3fda600000000000',int64),&
       int(z'3ff18f7eb3ee7285',int64),int(z'3fd16f4a4ec4af40',int64),int(z'3fd6c1c6a9b275fd',int64),int(z'3fd51f2764b886b9',int64),&
       int(z'3fdb03e49d72a144',int64),int(z'3fe0d7cfe7207dd5',int64),int(z'bcaace1e8e77d1b2',int64),int(z'3fdb2f65f63f6c78',int64),&
       int(z'3ff1800000000000',int64),int(z'3f6efd67dce509f5',int64),int(z'3fdaa00000000000',int64),int(z'3ff198477fabf325',int64),&
       int(z'3fd1b40f6dd15edb',int64),int(z'3fd71754156d090d',int64),int(z'3fd5a83a0f44ee42',int64),int(z'3fdbd1cef26149cc',int64),&
       int(z'3fe17b149ebb7d53',int64),int(z'3ca18867054c177a',int64),int(z'3fdb75b5773075f8',int64),int(z'3ff1800000000000',int64),&
       int(z'3f78477fabf3257b',int64),int(z'3fdae00000000000',int64),int(z'3ff1a132eead20e6',int64),int(z'3fd1f9d873afa8f4',int64),&
       int(z'3fd76f0df0ba2b44',int64),int(z'3fd63565b2776412',int64),int(z'3fdca78b8e4b8181',int64),int(z'3fe22595de92725a',int64),&
       int(z'bcabda45225ee470',int64),int(z'3fdbbc28606babe0',int64),int(z'3ff1c00000000000',int64),int(z'bf7ecd1152df1a7e',int64),&
       int(z'3fdb200000000000',int64),int(z'3ff1aa41848adb16',int64),int(z'3fd240abfe932abb',int64),int(z'3fd7c904eed7e85d',int64),&
       int(z'3fd6c6d24640b1b3',int64),int(z'3fdd857381d01020',int64),int(z'3fe2d7b39938b939',int64),int(z'3ca12ecb36d76e02',int64),&
       int(z'3fdc02bf3d843430',int64),int(z'3ff1c00000000000',int64),int(z'bf75be7b7524ea70',int64),int(z'3fdb600000000000',int64),&
       int(z'3ff1b373c839c9ac',int64),int(z'3fd28890dfbc912d',int64),int(z'3fd8254a666de3ca',int64),int(z'3fd75ca98b57457c',int64),&
       int(z'3fde6be47e7e55fe',int64),int(z'3fe391d368ec3777',int64),int(z'bc9f7efe4d8a80a5',int64),int(z'3fdc497a9c2247a0',int64),&
       int(z'3ff1c00000000000',int64),int(z'bf69186f8c6ca8a7',int64),int(z'3fdba00000000000',int64),int(z'3ff1bcca44246029',int64),&
       int(z'3fd2d18e1d6eb966',int64),int(z'3fd883f058df9e20',int64),int(z'3fd7f7172308ff84',int64),int(z'3fdf5b411cec1692',int64),&
       int(z'3fe45460efae7f7e',int64),int(z'bcaca88ac247c281',int64),int(z'3fdc905b0c10d428',int64),int(z'3ff1c00000000000',int64),&
       int(z'bf49addedcfeb6f6',int64),int(z'3fdbe00000000000',int64),int(z'3ff1c6458645e0a6',int64),int(z'3fd31baaf4fa598c',int64),&
       int(z'3fd8e5097a00cdbd',int64),int(z'3fd89648a876efa4',int64),int(z'3fe029f893bb3ba0',int64),int(z'3fe51fce3e769492',int64),&
       int(z'bc63bd0adac78ba6',int64),int(z'3fdcd7611f4b8a08',int64),int(z'3ff1c00000000000',int64),int(z'3f591619178298db',int64),&
       int(z'3fdc200000000000',int64),int(z'3ff1cfe620466a93',int64),int(z'3fd366eedce16113',int64),int(z'3fd948a93831a262',int64),&
       int(z'3fd93a6dcb5336b7',int64),int(z'3fe0ab30f50362a5',int64),int(z'3fe5f494440f45e4',int64),int(z'bca1b23f79a811b8',int64),&
       int(z'3fdd1e8d6a0d56c8',int64),int(z'3ff1c00000000000',int64),int(z'3f6fcc408cd52690',int64),int(z'3fdc600000000000',int64),&
       int(z'3ff1d9aca798215a',int64),int(z'3fd3b36187135170',int64),int(z'3fd9aee3c4e92f90',int64),int(z'3fd9e3b86c3b0a06',int64),&
       int(z'3fe13183439d6983',int64),int(z'3fe6d333444347ee',int64),int(z'3c9e6687141d7ade',int64),int(z'3fdd65e082df5278',int64),&
       int(z'3ff1c00000000000',int64),int(z'3f79aca798215a4d',int64),int(z'3fdca00000000000',int64),int(z'3ff1e399b59577b1',int64),&
       int(z'3fd4010ae343e389',int64),int(z'3fda17ce1db4a57b',int64),int(z'3fda925cbac8ca27',int64),int(z'3fe1bd2c29ac5009',int64),&
       int(z'3fe7bc335806abbe',int64),int(z'3c89743ad953cbea',int64),int(z'3fddad5b02a82420',int64),int(z'3ff2000000000000',int64),&
       int(z'bf7c664a6a884eaf',int64),int(z'3fdce00000000000',int64),int(z'3ff1edade7a0ad1e',int64),int(z'3fd44ff3215d62d8',int64),&
       int(z'3fda837e15b2742e',int64),int(z'3fdb4691557c3a62',int64),int(z'3fe24e6b9abecca0',int64),int(z'3fe8b024f75d3619',int64),&
       int(z'bc60a42b953c1f21',int64),int(z'3fddf4fd84bbe168',int64),int(z'3ff2000000000000',int64),int(z'bf7252185f52e269',int64),&
       int(z'3fdd200000000000',int64),int(z'3ff1f7e9df448be1',int64),int(z'3fd4a022b4103d45',int64),int(z'3fdaf20a5f90f152',int64),&
       int(z'3fdc008f6b992e26',int64),int(z'3fe2e58507c18f30',int64),int(z'3fe9afa18dce89c2',int64),int(z'bc8b90a5e5b4e0dd',int64),&
       int(z'3fde3cc8a6ec6ef0',int64),int(z'3ff2000000000000',int64),int(z'bf602c4176e83dee',int64),int(z'3fdd600000000000',int64),&
       int(z'3ff2024e42567651',int64),int(z'3fd4f1a253815e48',int64),int(z'3fdb638a98189f26',int64),int(z'3fdcc092e11f7bb9',int64),&
       int(z'3fe382bf968e1c3c',int64),int(z'3feabb4c1a4c4551',int64),int(z'bcac384dc65ee1e9',int64),int(z'3fde84bd099a6620',int64),&
       int(z'3ff2000000000000',int64),int(z'3f427212b3b2877e',int64),int(z'3fdda00000000000',int64),int(z'3ff20cdbbb19d366',int64),&
       int(z'3fd5447b00190520',int64),int(z'3fdbd817514ac3d7',int64),int(z'3fdd86da7501b24e',int64),int(z'3fe426665d5dcc91',int64),&
       int(z'3febd3d1db834bba',int64),int(z'bca6289264307fe4',int64),int(z'3fdeccdb4fc685e0',int64),int(z'3ff2000000000000',int64),&
       int(z'3f69b77633a6cd00',int64),int(z'3fdde00000000000',int64),int(z'3ff21792f864eb38',int64),int(z'3fd598b60573e0ca',int64),&
       int(z'3fdc4fca1e1d9c05',int64),int(z'3fde53a7e9c2fb44',int64),int(z'3fe4d0c8a26e99af',int64),int(z'3fecf9eb09a8a359',int64),&
       int(z'bcadf861d9afa9e0',int64),int(z'3fdf15241f23b3f8',int64),int(z'3ff2000000000000',int64),int(z'3f7792f864eb3836',int64),&
       int(z'3fde200000000000',int64),int(z'3ff22274adc744f8',int64),int(z'3fd5ee5cfd785957',int64),int(z'3fdccabd9ee01b3a',int64),&
       int(z'3fdf274030a7b7b5',int64),int(z'3fe5823a202e0d0d',int64),int(z'3fee2e5b9eebe829',int64),int(z'bc93bb42e2ea9787',int64),&
       int(z'3fdf5d98202994b8',int64),int(z'3ff2400000000000',int64),int(z'bf7d8b5238bb0864',int64),int(z'3fde600000000000',int64),&
       int(z'3ff22d8193b1990a',int64),int(z'3fd64579d3920d0f',int64),int(z'3fdd490d8e4fe1fe',int64),int(z'3fe000f5cbd3ed59',int64),&
       int(z'3fe63b134e45f774',int64),int(z'3fef71f42fd578ce',int64),int(z'3ca8ad1cc0e1ac47',int64),int(z'3fdfa637fe27bf60',int64),&
       int(z'3ff2400000000000',int64),int(z'bf727e6c4e66f5a1',int64),int(z'3fdea00000000000',int64),int(z'3ff238ba679f6ae1',int64),&
       int(z'3fd69e16c815a8f5',int64),int(z'3fddcad6cf6cd4c9',int64),int(z'3fe071fafd2ade38',int64),int(z'3fe6fbb1afee9630',int64),&
       int(z'3ff062c96a7acb82',int64),int(z'3c7e358035d3555b',int64),int(z'3fdfef0467599588',int64),int(z'3ff2400000000000',int64),&
       int(z'bf5d166182547b6f',int64),int(z'3fdee00000000000',int64),int(z'3ff2441fec425f4b',int64),int(z'3fd6f83e73cf67b4',int64),&
       int(z'3fde50377c1691ba',int64),int(z'3fe0e6d77af8190e',int64),int(z'3fe7c47827f29078',int64),int(z'3ff1151213b5ffdc',int64),&
       int(z'3c6cc7a15feba301',int64),int(z'3fe01bff067d6224',int64),int(z'3ff2400000000000',int64),int(z'3f507fb1097d2bdc',int64),&
       int(z'3fdf200000000000',int64),int(z'3ff24fb2e9af6533',int64),int(z'3fd753fbcbbea804',int64),int(z'3fded94ef480e731',int64),&
       int(z'3fe15fb5106d90c6',int64),int(z'3fe895cf52dad430',int64),int(z'3ff1d05228faae13',int64),int(z'bca50976e849f35a',int64),&
       int(z'3fe04092d1ae3b48',int64),int(z'3ff2400000000000',int64),int(z'3f6f65d35eca665d',int64),int(z'3fdf600000000000',int64),&
       int(z'3ff25b742d8dc7fa',int64),int(z'3fd7b15a25013475',int64),int(z'3fdf663def8d6387',int64),int(z'3fe1dcbfa2df4bff',int64),&
       int(z'3fe97025e7c2e4e5',int64),int(z'3ff295101c2ae4ab',int64),int(z'3ca4c8dcb02a3d13',int64),int(z'3fe0653df0fd9fd8',int64),&
       int(z'3ff2400000000000',int64),int(z'3f7b742d8dc7fa40',int64),int(z'3fdfa00000000000',int64),int(z'3ff267648b4843f2',int64),&
       int(z'3fd8106538f10257',int64),int(z'3fdff7268c1920b1',int64),int(z'3fe25e255148d4e4',int64),int(z'3fea53f12061c3fe',int64),&
       int(z'3ff363db5b9300e5',int64),int(z'bca47774624b8b97',int64),int(z'3fe08a00c1cae338',int64),int(z'3ff2800000000000',int64),&
       int(z'bf789b74b7bc0e50',int64),int(z'3fdfe00000000000',int64),int(z'3ff27384dc4036f2',int64),int(z'3fd8712929775c8f',int64),&
       int(z'3fe0461631a78776',int64),int(z'3fe2e41695ee0c65',int64),int(z'3feb41ad28e05161',int64),int(z'3ff43d4cff1df849',int64),&
       int(z'3ca5941cbabba919',int64),int(z'3fe0aedba3221c1c',int64),int(z'3ff2800000000000',int64),int(z'bf68f6477f921c27',int64),&
       int(z'3fe0100000000000',int64),int(z'3ff27fd600030888',int64),int(z'3fd8d3b28598a1b5',int64),int(z'3fe092ba4e0bc755',int64),&
       int(z'3fe36ec66a428eec',int64),int(z'3fec39c044f514c9',int64),int(z'3ff5220518c4ef3a',int64),int(z'4000c1d1a852f235',int64),&
       int(z'3ca78082d00f64b8',int64),int(z'3fe0d3cef5c846f8',int64),int(z'3ff2800000000000',int64),int(z'bf04fffe7bbc39df',int64),&
       int(z'3fe0300000000000',int64),int(z'3ff28c58dc81e6d7',int64),int(z'3fd9380e4e3bf356',int64),int(z'3fe0e192ffc646a7',int64),&
       int(z'3fe3fe6a6d34756d',int64),int(z'3fed3cef139abc91',int64),int(z'3ff612b8f80111c0',int64),int(z'4001a33c3467c688',int64),&
       int(z'bc8a995434f59445',int64),int(z'3fe0f8db1c47d550',int64),int(z'3ff2800000000000',int64),int(z'3f68b1b903cdae3f',int64),&
       int(z'3fe0500000000000',int64),int(z'3ff2990e5e4bf713',int64),int(z'3fd99e49fb326e9e',int64),int(z'3fe132b48779391a',int64),&
       int(z'3fe4933b0c2fe325',int64),int(z'3fee4bb1aeaae1d0',int64),int(z'3ff710201f4377bd',int64),int(z'400292711c886605',int64),&
       int(z'bca33ab17130ce99',int64),int(z'3fe11e007afdaf10',int64),int(z'3ff2800000000000',int64),int(z'3f790e5e4bf712c7',int64),&
       int(z'3fe0700000000000',int64),int(z'3ff2a5f778cb1a3b',int64),int(z'3fda06738081c5d1',int64),int(z'3fe186340d5e6499',int64),&
       int(z'3fe52d73aedd6be6',int64),int(z'3fef66a51cf1aaa0',int64),int(z'3ff81b024834e5a9',int64),int(z'40039066fce48906',int64),&
       int(z'bca34e4f6bfb4c85',int64),int(z'3fe1433f7826aad4',int64),int(z'3ff2c00000000000',int64),int(z'bf7a088734e5c574',int64),&
       int(z'3fe0900000000000',int64),int(z'3ff2b315268368db',int64),int(z'3fda709953f655b7',int64),int(z'3fe1dc27ad9032ec',int64),&
       int(z'3fe5cd52e5f88e23',int64),int(z'3ff047380a68bdfc',int64),int(z'3ff934352f057820',int64),int(z'40049e27dae8a2fc',int64),&
       int(z'3c86832cfaa44565',int64),int(z'3fe168987bed8260',int64),int(z'3ff2c00000000000',int64),int(z'bf69d5b2f92e4a41',int64),&
       int(z'3fe0b00000000000',int64),int(z'3ff2c06869558a9e',int64),int(z'3fdadcca73011b64',int64),int(z'3fe234a68511146a',int64),&
       int(z'3fe6731a9d6cbf3c',int64),int(z'3ff0e1e1d575f00a',int64),int(z'3ffa5c9dadea17e7',int64),int(z'4005bcd2d9123e7c',int64),&
       int(z'bca23e4fcc2ae1e4',int64),int(z'3fe18e0bf07948f0',int64),int(z'3ff2c00000000000',int64),int(z'3f1a1a5562a7614a',int64),&
       int(z'3fe0d00000000000',int64),int(z'3ff2cdf24ac410c6',int64),int(z'3fdb4b1668e63d97',int64),int(z'3fe28fc8bfa256b2',int64),&
       int(z'3fe71f1051fdf05a',int64),int(z'3ff183ae0753c882',int64),int(z'3ffb9530f1921090',int64),int(z'4006ed9e14f942bc',int64),&
       int(z'3ca2787989c77fa3',int64),int(z'3fe1b39a41fc691c',int64),int(z'3ff2c00000000000',int64),int(z'3f6be49588218cd6',int64),&
       int(z'3fe0f00000000000',int64),int(z'3ff2dbb3dc3bfd25',int64),int(z'3fdbbb8d55413207',int64),int(z'3fe2eda7a6792bf1',int64),&
       int(z'3fe7d17d4ac4e230',int64),int(z'3ff22d00aae6cb05',int64),int(z'3ffcdef5c9028e71',int64),int(z'400831d8b40c626c',int64),&
       int(z'3c953fef9873f484',int64),int(z'3fe1d943dec430c0',int64),int(z'3ff2c00000000000',int64),int(z'3f7bb3dc3bfd24a1',int64),&
       int(z'3fe1100000000000',int64),int(z'3ff2e9ae3760a19b',int64),int(z'3fdc2e3ff2e3e2eb',int64),int(z'3fe34e5dafe1cd38',int64),&
       int(z'3fe88aaed6ce0b26',int64),int(z'3ff2de442c4b06c6',int64),int(z'3ffe3b06138813d2',int64),int(z'40098aed23fd5612',int64),&
       int(z'bc91ec19b7af0e54',int64),int(z'3fe1ff093748f114',int64),int(z'3ff3000000000000',int64),int(z'bf7651c89f5e657e',int64),&
       int(z'3fe1300000000000',int64),int(z'3ff2f7e27e5b072b',int64),int(z'3fdca33f9f169c4d',int64),int(z'3fe3b2068fe1eb56',int64),&
       int(z'3fe94af68f30e1b7',int64),int(z'3ff397e9cfcf9887',int64),int(z'3fffaa904fb7f25f',int64),int(z'400afa6394745d90',int64),&
       int(z'3c96955c2a139390',int64),int(z'3fe224eabe3eba20',int64),int(z'3ff3000000000000',int64),int(z'bf603b0349f1aa85',int64),&
       int(z'3fe1500000000000',int64),int(z'3ff30651dc2d0e76',int64),int(z'3fdd1a9e613ef408',int64),int(z'3fe418bf49ed083d',int64),&
       int(z'3fea12aa9dfd1e23',int64),int(z'3ff45a6a32b75f76',int64),int(z'4000976ca7673f47',int64),int(z'400c81e4b046ac6a',int64),&
       int(z'3c879ff77d1beb80',int64),int(z'3fe24ae8e8a6b8b0',int64),int(z'3ff3000000000000',int64),int(z'3f594770b439d90e',int64),&
       int(z'3fe1700000000000',int64),int(z'3ff314fd85087ecd',int64),int(z'3fdd946ef2f45390',int64),int(z'3fe482a643beda05',int64),&
       int(z'3feae2260a640dd7',int64),int(z'3ff52645d6a3d695',int64),int(z'4001649f08098fe0',int64),int(z'400e233c9d2bade7',int64),&
       int(z'3c9e948c4e5f8348',int64),int(z'3fe271042de13e58',int64),int(z'3ff3000000000000',int64),int(z'3f74fd85087ecd1a',int64),&
       int(z'3fe1900000000000',int64),int(z'3ff323e6b6aa3c67',int64),int(z'3fde10c4c8894828',int64),int(z'3fe4efdb59718389',int64),&
       int(z'3febb9c90a8d7622',int64),int(z'3ff5fc05b8a62b12',int64),int(z'40023d9ae4296831',int64),int(z'400fe05e49c0b830',int64),&
       int(z'3ca19107c1189de8',int64),int(z'3fe2973d07c07bcc',int64),int(z'3ff3400000000000',int64),int(z'bf7c194955c3993d',int64),&
       int(z'3fe1b00000000000',int64),int(z'3ff3330eb8b9e20b',int64),int(z'3fde8fb41a11468b',int64),int(z'3fe5607ff2e740e1',int64),&
       int(z'3fec99f95b91db14',int64),int(z'3ff6dc3bf50c5faa',int64),int(z'4003232a0cfac1c7',int64),int(z'4010ddb3894efd30',int64),&
       int(z'bca7760f3783d916',int64),int(z'3fe2bd93f29bf5f0',int64),int(z'3ff3400000000000',int64),int(z'bf69e28e8c3bea7f',int64),&
       int(z'3fe1d00000000000',int64),int(z'3ff34276dd2dfe6d',int64),int(z'3fdf1151eceb226b',int64),int(z'3fe5d4b71aa123ce',int64),&
       int(z'3fed8322a01f65f8',int64),int(z'3ff7c784791ce583',int64),int(z'40041625c15a6b9c',int64),int(z'4011db5164280feb',int64),&
       int(z'3ca1046328ca6dbb',int64),int(z'3fe2e4096d64beac',int64),int(z'3ff3400000000000',int64),int(z'3f43b6e96ff364e1',int64),&
       int(z'3fe1f00000000000',int64),int(z'3ff3522080b539c7',int64),int(z'3fdf95b41dd91a82',int64),int(z'3fe64ca5961ea9ca',int64),&
       int(z'3fee75b6c65b3b2f',int64),int(z'3ff8be85c412e59f',int64),int(z'4005177802462a51',int64),int(z'4012ea48109fc81b',int64),&
       int(z'3c959e4c9f70ca98',int64),int(z'3fe30a9df9ba7b3c',int64),int(z'3ff3400000000000',int64),int(z'3f722080b539c6a2',int64),&
       int(z'3fe2100000000000',int64),int(z'3ff3620d0b24acda',int64),int(z'3fe00e78b5d803b6',int64),int(z'3fe6c871ffe457fb',int64),&
       int(z'3fef722e759ef386',int64),int(z'3ff9c1f1b8d0e874',int64),int(z'4006281d080fb06e',int64),int(z'40140bf2d1f69df7',int64),&
       int(z'bc8489eacbfaf37f',int64),int(z'3fe331521c0141bc',int64),int(z'3ff3800000000000',int64),int(z'bf7df2f4db532667',int64),&
       int(z'3fe2300000000000',int64),int(z'3ff3723defebb76d',int64),int(z'3fe05390c153fc4c',int64),int(z'3fe74844e34a2666',int64),&
       int(z'3ff03c84c260a400',int64),int(z'3ffad28681e70f01',int64),int(z'40074924dbc4a78e',int64),int(z'401541cb8bbca2e0',int64),&
       int(z'3c9c75287bea8472',int64),int(z'3fe358265b7858f8',int64),int(z'3ff3800000000000',int64),int(z'bf6b842028912510',int64),&
       int(z'3fe2500000000000',int64),int(z'3ff382b4ae8da9c7',int64),int(z'3fe09a2e842cabb9',int64),int(z'3fe7cc48da356141',int64),&
       int(z'3ff0c567bcd4fdb8',int64),int(z'3ffbf10f89b62c32',int64),int(z'40087bb518adc4b9',int64),int(z'40168d6dc516f6f1',int64),&
       int(z'bc933a6b2e37d6a3',int64),int(z'3fe37f1b4251e5ac',int64),int(z'3ff3800000000000',int64),int(z'3f45a5746d4e3a7a',int64),&
       int(z'3fe2700000000000',int64),int(z'3ff39372d3219a4c',int64),int(z'3fe0e25ed4394437',int64),int(z'3fe854aaace4cc74',int64),&
       int(z'3ff154080981ee13',int64),int(z'3ffd1e6688aa5332',int64),int(z'4009c10ada3bd18f',int64),int(z'4017f099ffe4ae21',int64),&
       int(z'bcaed56b7b588abe',int64),int(z'3fe3a6315dcb911c',int64),int(z'3ff3800000000000',int64),int(z'3f7372d3219a4ba9',int64),&
       int(z'3fe2900000000000',int64),int(z'3ff3a479f6d8c6bc',int64),int(z'3fe12c2f11197a32',int64),int(z'3fe8e19973f949d5',int64),&
       int(z'3ff1e8b1ee7a481d',int64),int(z'3ffe5b74abbe8828',int64),int(z'400b1a7cdb3d83bc',int64),int(z'40196d396dc46100',int64),&
       int(z'3ca7798cacd8f69c',int64),int(z'3fe3cd693e4835e8',int64),int(z'3ff3c00000000000',int64),int(z'bf7b860927394391',int64),&
       int(z'3fe2b00000000000',int64),int(z'3ff3b5cbc08be738',int64),int(z'3fe177ad2b5cb6b7',int64),int(z'3fe97346bce90eb1',int64),&
       int(z'3ff283b668ec7f04',int64),int(z'3fffa933d5b8ed04',int64),int(z'400c897dcbcdff9a',int64),int(z'401b05620e4abf55',int64),&
       int(z'3c881ff61ee42043',int64),int(z'3fe3f4c3776aa08c',int64),int(z'3ff3c00000000000',int64),int(z'bf64687ee8319086',int64),&
       int(z'3fe2d00000000000',int64),int(z'3ff3c769e54fe05e',int64),int(z'3fe1c4e7ac1a81a0',int64),int(z'3fea09e6b10fa326',int64),&
       int(z'3ff3256b840f679b',int64),int(z'40008457fee9ef1a',int64),int(z'400e0f9ee4146343',int64),int(z'401cbb5b433496a9',int64),&
       int(z'bca57a4c59f087c0',int64),int(z'3fe41c40a03171a8',int64),int(z'3ff3c00000000000',int64),int(z'3f5da7953f81773d',int64),&
       int(z'3fe2f00000000000',int64),int(z'3ff3d956291249dc',int64),int(z'3fe213edbd044ac9',int64),int(z'3feaa5b03f917fa8',int64),&
       int(z'3ff3ce2cb7380a79',int64),int(z'40013d84576afae8',int64),int(z'400fae92baab74f3',int64),int(z'401e91a2e9129e4a',int64),&
       int(z'3c9056710cec83f7',int64),int(z'3fe443e153143194',int64),int(z'3ff3c00000000000',int64),int(z'3f7956291249dbc4',int64),&
       int(z'3fe3100000000000',int64),int(z'3ff3eb925f3e4715',int64),int(z'3fe264cf30f965d1',int64),int(z'3feb46dd4a4f2fb2',int64),&
       int(z'3ff47e5b4bc2e94f',int64),int(z'400200b954f8f9eb',int64),int(z'4010b41833305d9f',int64),int(z'40204579826ef167',int64),&
       int(z'bc9737a0e06ebcae',int64),int(z'3fe46ba62e21a53c',int64),int(z'3ff4000000000000',int64),int(z'bf746da0c1b8eb04',int64),&
       int(z'3fe3300000000000',int64),int(z'3ff3fe206b6a38d5',int64),int(z'3fe2b79c8d26c7a0',int64),int(z'3febedaad62978f8',int64),&
       int(z'3ff5365ecb8cc6d1',int64),int(z'4002ce9cd894af54',int64),int(z'40119f3b79f7c63e',int64),int(z'402155240c8e7b9e',int64),&
       int(z'3ca485d013dc9a80',int64),int(z'3fe4938fd31f754c',int64),int(z'3ff4000000000000',int64),int(z'bf3df9495c72b1e7',int64),&
       int(z'3fe3500000000000',int64),int(z'3ff41102420ed8e7',int64),int(z'3fe30c6712bce2b2',int64),int(z'3fec9a593ede345e',int64),&
       int(z'3ff5f6a578cab466',int64),int(z'4003a7e13ead62ee',int64),int(z'401299c89cb9a228',int64),int(z'402279741be749b0',int64),&
       int(z'3cafe28fc6a9831f',int64),int(z'3fe4bb9ee7ab3a40',int64),int(z'3ff4000000000000',int64),int(z'3f7102420ed8e776',int64),&
       int(z'3fe3700000000000',int64),int(z'3ff42439e9485b43',int64),int(z'3fe36340c946e033',int64),int(z'3fed4d2c6ecc5a7e',int64),&
       int(z'3ff6bfa4d027255a',int64),int(z'40048d4672504be1',int64),int(z'4013a4ed09445bd5',int64),int(z'4023b435749e19f9',int64),&
       int(z'bc40e7e5eaaaf53e',int64),int(z'3fe4e3d4155d0070',int64),int(z'3ff4400000000000',int64),int(z'bf7bc616b7a4bd36',int64),&
       int(z'3fe3900000000000',int64),int(z'3ff437c979a23c23',int64),int(z'3fe3bc3c89af6a9d',int64),int(z'3fee066c1af553ba',int64),&
       int(z'3ff791da1622569a',int64),int(z'40057f9b1b18ae2b',int64),int(z'4014c1f088bff240',int64),int(z'40250761019a4522',int64),&
       int(z'3ca4c238fdfccb13',int64),int(z'3fe50c3009eb58f8',int64),int(z'3ff4400000000000',int64),int(z'bf606d0cbb87b9e1',int64),&
       int(z'3fe3b00000000000',int64),int(z'3ff44bb31eee6f35',int64),int(z'3fe4176e0a004d1d',int64),int(z'3feec6640399fa54',int64),&
       int(z'3ff86dcaf0cfd106',int64),int(z'40067fbde8c80e97',int64),int(z'4015f237d9cd2d79',int64),int(z'40267521c8076345',int64),&
       int(z'3caec756b089f7af',int64),int(z'3fe534b377510d94',int64),int(z'3ff4400000000000',int64),int(z'3f67663ddcde698f',int64),&
       int(z'3fe3d00000000000',int64),int(z'3ff45ff91928b1be',int64),int(z'3fe474e9e9eb53e9',int64),int(z'3fef8d6439db03b6',int64),&
       int(z'3ff954060f298b87',int64),int(z'40078e9effc72ab6',int64),int(z'40173747941456e7',int64),int(z'4027ffda74a71e71',int64),&
       int(z'bcaeed93fe7483b3',int64),int(z'3fe55d5f13f48ec0',int64),int(z'3ff4400000000000',int64),int(z'3f7ff91928b1bdff',int64),&
       int(z'3fe3f00000000000',int64),int(z'3ff4749dbd66d0c4',int64),int(z'3fe4d4c5c02c2013',int64),int(z'3ff02de0b56768cc',int64),&
       int(z'3ffa4523df53a7bd',int64),int(z'4008ad418a357386',int64),int(z'401892c75e392799',int64),int(z'4029aa2b97746acd',int64),&
       int(z'3c924f0ab4a71e44',int64),int(z'3fe586339ad13548',int64),int(z'3ff4800000000000',int64),int(z'bf66c485325e775e',int64),&
       int(z'3fe4100000000000',int64),int(z'3ff489a376d6c491',int64),int(z'3fe5371828d40829',int64),int(z'3ff098ea98450d83',int64),&
       int(z'3ffb41c755526e3b',int64),int(z'4009dcbd719f540e',int64),int(z'401a0685805d08d1',int64),int(z'402b76faa5142633',int64),&
       int(z'3c2ad9a7f1ff56fc',int64),int(z'3fe5af31cba27244',int64),int(z'3ff4800000000000',int64),int(z'3f6346edad892100',int64),&
       int(z'3fe4300000000000',int64),int(z'3ff49f0cc7cb94cc',int64),int(z'3fe59bf8d492aa1e',int64),int(z'3ff107ff34d2ca82',int64),&
       int(z'3ffc4a9ec3df9e51',int64),int(z'400b1e4145f5874e',int64),int(z'401b947adeb92648',int64),int(z'402d6979d903d532',int64),&
       int(z'3ca4323104c67f5e',int64),int(z'3fe5d85a6b1109a4',int64),int(z'3ff4800000000000',int64),int(z'3f7f0cc7cb94cc1a',int64),&
       int(z'3fe4500000000000',int64),int(z'3ff4b4dc4ada0bf0',int64),int(z'3fe60380990f861f',int64),int(z'3ff17b50cbec7542',int64),&
       int(z'3ffd6064c93cfe8f',int64),int(z'400c731456f36fe3',int64),int(z'401d3ecf696e5374',int64),int(z'402f85311778af1d',int64),&
       int(z'3c7a53bf31ebda84',int64),int(z'3fe601ae42e27660',int64),int(z'3ff4c00000000000',int64),int(z'bf66476a4be81f81',int64),&
       int(z'3fe4700000000000',int64),int(z'3ff4cb14b4065600',int64),int(z'3fe66dc9826ada4f',int64),int(z'3ff1f314a3298d4d',int64),&
       int(z'3ffe83e152191cb4',int64),int(z'400ddc9905ca69af',int64),int(z'401f07df1079c46a',int64),int(z'4030e703f9440eb0',int64),&
       int(z'3ca495e15817d0dd',int64),int(z'3fe62b2e222a98a0',int64),int(z'3ff4c00000000000',int64),int(z'3f6629680cac00d4',int64),&
       int(z'3fe4900000000000',int64),int(z'3ff4e1b8d203bdc9',int64),int(z'3fe6daeee5fe0976',int64),int(z'3ff26f833c44f71e',int64),&
       int(z'3fffb5eab4d92f91',int64),int(z'400f5c4f55a779c8',int64),int(z'4020791fa66a7536',int64),int(z'403224287dce5d75',int64),&
       int(z'3cade7e8964f770b',int64),int(z'3fe654dadd7fd12c',int64),int(z'3ff5000000000000',int64),int(z'bf7e472dfc42374b',int64),&
       int(z'3fe4b00000000000',int64),int(z'3ff4f8cb8f87d541',int64),int(z'3fe74b0d767620c4',int64),int(z'3ff2f0d89126f083',int64),&
       int(z'40007bb373f08794',int64),int(z'401079ebe1419117',int64),int(z'40218062a917f81e',int64),int(z'40337c6b48444dee',int64),&
       int(z'3c907a41f4061e08',int64),int(z'3fe67eb54f31af70',int64),int(z'3ff5000000000000',int64),int(z'bf5cd1c1e0aafa85',int64),&
       int(z'3fe4d00000000000',int64),int(z'3ff5104ff4b2718c',int64),int(z'3fe7be4359659939',int64),int(z'3ff377545502eae6',int64),&
       int(z'400124a66ae0ac51',int64),int(z'4011527b33524d17',int64),int(z'40229b467fbf7a2d',int64),int(z'4034f274ad716768',int64),&
       int(z'bc9c610f7c204ea8',int64),int(z'3fe6a8be57825a6c',int64),int(z'3ff5000000000000',int64),int(z'3f704ff4b2718c01',int64),&
       int(z'3fe4f00000000000',int64),int(z'3ff52849288c017d',int64),int(z'3fe834b03e6d3f7f',int64),int(z'3ff4033a3b0747cb',int64),&
       int(z'4001d652e946b196',int64),int(z'401238cb3c2f8cb4',int64),int(z'4023cb8053e520c1',int64),int(z'40368938607bc0f6',int64),&
       int(z'bc84274ccc053597',int64),int(z'3fe6d2f6dce2dfb8',int64),int(z'3ff5400000000000',int64),int(z'bf77b6d773fe8364',int64),&
       int(z'3fe5100000000000',int64),int(z'3ff540ba729be713',int64),int(z'3fe8ae75781f49a2',int64),int(z'3ff494d2432ac103',int64),&
       int(z'400291479b0015b6',int64),int(z'40132de7156b74e9',int64),int(z'402512f0e8362ec8',int64),int(z'403843fec8d2e0f8',int64),&
       int(z'bc8f55dbbb3acc53',int64),int(z'3fe6fd5fcc3296f0',int64),int(z'3ff5400000000000',int64),int(z'3f274e537ce2565e',int64),&
       int(z'3fe5300000000000',int64),int(z'3ff559a73c98a101',int64),int(z'3fe92bb616c3163d',int64),int(z'3ff52c690db2c44d',int64),&
       int(z'4003561e0f4546b8',int64),int(z'401432f17f099a82',int64),int(z'402673a9831e227a',int64),int(z'403a266fa02bbcd5',int64),&
       int(z'3ca279a8aea9cb9d',int64),int(z'3fe727fa1901cb44',int64),int(z'3ff5400000000000',int64),int(z'3f79a73c98a10084',int64),&
       int(z'3fe5500000000000',int64),int(z'3ff573131433b9bd',int64),int(z'3fe9ac970523e7b2',int64),int(z'3ff5ca50361f7393',int64),&
       int(z'4004257bb0f40825',int64),int(z'4015492746286025',int64),int(z'4027eff1781495b4',int64),int(z'403c349e0a1139f1',int64),&
       int(z'bc5d2c668b6015da',int64),int(z'3fe752c6bdd7e0e0',int64),int(z'3ff5800000000000',int64),int(z'bf69d9d7988c865f',int64),&
       int(z'3fe5700000000000',int64),int(z'3ff58d01ad039e07',int64),int(z'3fea313f279933cd',int64),int(z'3ff66edeb63d93a6',int64),&
       int(z'40050012d836441a',int64),int(z'401671e1f23d152c',int64),int(z'40298a4c65d3a1dd',int64),int(z'403e73165ebdbf39',int64),&
       int(z'bcae5b6c7aaa4996',int64),int(z'3fe77dc6bc7d2fa0',int64),int(z'3ff5800000000000',int64),int(z'3f6a035a073c0e86',int64),&
       int(z'3fe5900000000000',int64),int(z'3ff5a776e28dadb6',int64),int(z'3feab9d77d7be2b5',int64),int(z'3ff71a715234c8a9',int64),&
       int(z'4005e6a3f873554c',int64),int(z'4017ae9ac1f33f9b',int64),int(z'402b45814310046e',int64),int(z'40407376f64b03e7',int64),&
       int(z'bca3f39bb3ab0542',int64),int(z'3fe7a8fb1e48d158',int64),int(z'3ff5c00000000000',int64),int(z'bf78891d725249ca',int64),&
       int(z'3fe5b00000000000',int64),int(z'3ff5c276ba730f9b',int64),int(z'3feb468b454127c3',int64),int(z'3ff7cd6b0e816adb',int64),&
       int(z'4006d9feeddac837',int64),int(z'401900ee0209e3b7',int64),int(z'402d24a257489c7e',int64),int(z'4041caea7f810e14',int64),&
       int(z'bc84f20e24f9675b',int64),int(z'3fe7d464f472a690',int64),int(z'3ff5c00000000000',int64),int(z'3f43b5d3987cd623',int64),&
       int(z'3fe5d00000000000',int64),int(z'3ff5de0566c30cdc',int64),int(z'3febd78823798d1a',int64),int(z'3ff88835b0e567d8',int64),&
       int(z'4007db046e46660a',int64),int(z'401a6a9eca07caa5',int64),int(z'402f2b1641ecef64',int64),int(z'40434315c36f367b',int64),&
       int(z'bca08ca1542594a6',int64),int(z'3fe800055869d9e8',int64),int(z'3ff5c00000000000',int64),int(z'3f7e0566c30cdbd9',int64),&
       int(z'3fe5f00000000000',int64),int(z'3ff5fa274875fa03',int64),int(z'3fec6cfe4cf96d63',int64),int(z'3ff94b424d7b8313',int64),&
       int(z'4008eaa7a1b04592',int64),int(z'401bed9b2c5a9d87',int64),int(z'4030ae511bc92f68',int64),int(z'4044df8c685fbd64',int64),&
       int(z'bcac07a830fe6378',int64),int(z'3fe82bdd6c30303c',int64),int(z'3ff6000000000000',int64),int(z'bf5762de2817f40c',int64),&
       int(z'3fe6100000000000',int64),int(z'3ff616e0f213fcd6',int64),int(z'3fed0720b47784ff',int64),int(z'3ffa1709e13c6707',int64),&
       int(z'400a09efe70b2e72',int64),int(z'401d8c00e976aad9',int64),int(z'4031debad1ae1ea8',int64),int(z'4046a4536424341f',int64),&
       int(z'3ca13e53a65d40b1',int64),int(z'3fe857ee5aba79e8',int64),int(z'3ff6000000000000',int64),int(z'3f76e0f213fcd614',int64),&
       int(z'3fe6300000000000',int64),int(z'3ff634372a8b4ed8',int64),int(z'3feda6253bf69915',int64),int(z'3ffaec0dfb6df86f',int64),&
       int(z'400b39facaf2d64b',int64),int(z'401f4822b7e2dc06',int64),int(z'4033291bb12537e3',int64),int(z'404895f0af3ef0d1',int64),&
       int(z'3caea58871e7ed76',int64),int(z'3fe884395856807c',int64),int(z'3ff6400000000000',int64),int(z'bf6791aae9624f1c',int64),&
       int(z'3fe6500000000000',int64),int(z'3ff6522ef039f5e3',int64),int(z'3fee4a44ea588e54',int64),int(z'3ffbcad977a3f8a4',int64),&
       int(z'400c7bfe3669f2f2',int64),int(z'402092471aea54a4',int64),int(z'4034900a6b866959',int64),int(z'404ab97d620634cf',int64),&
       int(z'3c948649da91b0fd',int64),int(z'3fe8b0bfa316d3a0',int64),int(z'3ff6400000000000',int64),int(z'3f722ef039f5e2ad',int64),&
       int(z'3fe6700000000000',int64),int(z'3ff670cd7c2f4fc3',int64),int(z'3feef3bc2583cf60',int64),int(z'3ffcb4014a2e1684',int64),&
       int(z'400dd14adcb9f8fb',int64),int(z'402192094e164373',int64),int(z'403616698fc171bc',int64),int(z'404d14baa46b7be1',int64),&
       int(z'bcabac31bbdfe65a',int64),int(z'3fe8dd828344e08c',int64),int(z'3ff6800000000000',int64),int(z'bf6e6507a1607a77',int64),&
       int(z'3fe6900000000000',int64),int(z'3ff6901845aa3c85',int64),int(z'3fefa2caf18fbd18',int64),int(z'3ffda825610c140e',int64),&
       int(z'400f3b4ef08895e1',int64),int(z'4022a4e4272cd203',int64),int(z'4037bf7160c4a0ee',int64),int(z'404fae29ec79351d',int64),&
       int(z'3c6bf5bb3e22fb0a',int64),int(z'3fe90a834bd9c858',int64),int(z'3ff6800000000000',int64),int(z'3f701845aa3c8533',int64),&
       int(z'3fe6b00000000000',int64),int(z'3ff6b01505d92e4e',int64),int(z'3ff02bda9abd20d8',int64),int(z'3ffea7f19bc5cc13',int64),&
       int(z'40105dcc94afb2bb',int64),int(z'4023cc8cb382b54a',int64),int(z'40398ebb19c28eae',int64),int(z'405146948f7609b5',int64),&
       int(z'3c9cd223f66137e5',int64),int(z'3fe937c35afe73ac',int64),int(z'3ff6c00000000000',int64),int(z'bf6fd5f44da36334',int64),&
       int(z'3fe6d00000000000',int64),int(z'3ff6d0c9bbe1ef2b',int64),int(z'3ff0896182fbdd29',int64),int(z'3fffb41edcd403ec',int64),&
       int(z'401129ee121d0023',int64),int(z'40250ae5b34159b2',int64),int(z'403b884ddb5ceac4',int64),int(z'4052dd09a0b334b0',int64),&
       int(z'bc96bf1dd8f14bf9',int64),int(z'3fe965441a936d24',int64),int(z'3ff6c00000000000',int64),int(z'3f70c9bbe1ef2aee',int64),&
       int(z'3fe6f00000000000',int64),int(z'3ff6f23cb13786cf',int64),int(z'3ff0ea207b7fc134',int64),int(z'400066ba1bd0d518',int64),&
       int(z'401202f9159ec945',int64),int(z'4026620516ff868a',int64),int(z'403db0ad87398014',int64),int(z'40549f3347d58711',int64),&
       int(z'3c8d858f54b11a28',int64),int(z'3fe9930700c1184c',int64),int(z'3ff7000000000000',int64),int(z'bf6b869d90f2626a',int64),&
       int(z'3fe7100000000000',int64),int(z'3ff714747e455603',int64),int(z'3ff14e403a65655f',int64),int(z'4000fa641f4aa7a1',int64),&
       int(z'4012e9f0b946c70a',int64),int(z'4027d43a3cc53936',int64),int(z'40400675ee087279',int64),int(z'4056927877313cef',int64),&
       int(z'bcab1ba1772d6e62',int64),int(z'3fe9c10d9090e874',int64),int(z'3ff7000000000000',int64),int(z'3f74747e455602d3',int64),&
       int(z'3fe7300000000000',int64),int(z'3ff737780f773dec',int64),int(z'3ff1b5ec1288b243',int64),int(z'400195813a853fa5',int64),&
       int(z'4013dff06d2743e5',int64),int(z'4029641509b4b924',int64),int(z'4041515e19a59d1f',int64),int(z'4058bd01f3e53877',int64),&
       int(z'3c962269fc348bae',int64),int(z'3fe9ef595a90493c',int64),int(z'3ff7400000000000',int64),int(z'bf610fe111842743',int64),&
       int(z'3fe7500000000000',int64),int(z'3ff75b4eaaa78140',int64),int(z'3ff2215228b49576',int64),int(z'4002388e74d66746',int64),&
       int(z'4014e62ea43083a8',int64),int(z'402b146e02885ed7',int64),int(z'4042bc4529a3bc2c',int64),int(z'405b25d8cdafe7e5',int64),&
       int(z'3ca8862df03f8a74',int64),int(z'3fea1debfd7dfbd8',int64),int(z'3ff7400000000000',int64),int(z'3f7b4eaaa7813fba',int64),&
       int(z'3fe7700000000000',int64),int(z'3ff77ffff4fc0008',int64),int(z'3ff290a3ade499e4',int64),int(z'4002e412ff22fe11',int64),&
       int(z'4015fdffd7a17943',int64),int(z'402ce86f8af79aef',int64),int(z'40444aca6f8edf86',int64),int(z'405dd50a29cf9f92',int64),&
       int(z'3ca49db0c5865233',int64),int(z'3fea4cc72702bd90',int64),int(z'3ff7800000000000',int64),int(z'be6607fff08268e1',int64),&
       int(z'3fe7900000000000',int64),int(z'3ff7a593f93d7fbc',int64),int(z'3ff304151f293a81',int64),int(z'400398a131649ea4',int64),&
       int(z'401728d9ed75da1e',int64),int(z'402ee3a07b1736ca',int64),int(z'40460106036ec9d4',int64),int(z'406069e8b3e5a09f',int64),&
       int(z'bca79bbd4e8eb882',int64),int(z'3fea7bec94762100',int64),int(z'3ff7c00000000000',int64),int(z'bf7a6c06c280445c',int64),&
       int(z'3fe7b00000000000',int64),int(z'3ff7cc132eb4e536',int64),int(z'3ff37bde8bd25d7d',int64),int(z'400456d7a51df797',int64),&
       int(z'40186858103af33e',int64),int(z'403084f821121c2e',int64),int(z'4047e39a9d7c6de3',int64),int(z'40621664ef4c9a12',int64),&
       int(z'3c804d2d39db72ff',int64),int(z'3feaab5e13b099b0',int64),int(z'3ff7c00000000000',int64),int(z'3f68265d69ca6c2f',int64),&
       int(z'3fe7d00000000000',int64),int(z'3ff7f386809ba1cd',int64),int(z'3ff3f83be298b2eb',int64),int(z'40051f62708a6abe',int64),&
       int(z'4019be3f090f77ab',int64),int(z'4031afe26c13bf38',int64),int(z'4049f7ca65ff02a8',int64),int(z'4063f614da840fe0',int64),&
       int(z'bca7bde9ab5d1a54',int64),int(z'3feadb1d83ebd320',int64),int(z'3ff8000000000000',int64),int(z'bf68f2fec8bc6562',int64),&
       int(z'3fe7f00000000000',int64),int(z'3ff81bf7562e1e24',int64),int(z'3ff4796d469724db',int64),int(z'4005f2fc86e67917',int64),&
       int(z'401b2c822f5ae582',int64),int(z'4032f50565ee1919',int64),int(z'404c438f4744d220',int64),int(z'40661003d66309fd',int64),&
       int(z'3c8470c8fc828894',int64),int(z'3feb0b2cd6b287dc',int64),int(z'3ff8000000000000',int64),int(z'3f7bf7562e1e23e5',int64),&
       int(z'3fe8100000000000',int64),int(z'3ff8456f9b70ab1d',int64),int(z'3ff4ffb76d01a674',int64),int(z'4006d27142d7b667',int64),&
       int(z'401cb54905dd4055',int64),int(z'40345723e490ca9b',int64),int(z'404ecd1747c5589b',int64),int(z'40686c463d6db036',int64),&
       int(z'4084044decf23c2e',int64),int(z'bc7f09900d173a5f',int64),int(z'3feb3b8e10e12d3c',int64),int(z'3ff8400000000000',int64),&
       int(z'3f55be6dc2ac733c',int64),int(z'3fe8300000000000',int64),int(z'3ff86ff9cab97b9d',int64),int(z'3ff58b6404a71b42',int64),&
       int(z'4007be9e20c0fb6e',int64),int(z'401e5af59b426297',int64),int(z'4035d958013c40ee',int64),int(z'4050cea92215e48c',int64),&
       int(z'406b146bb8c0669a',int64),int(z'40868c96fb8eb0fe',int64),int(z'3ca558481fccbad4',int64),int(z'3feb6c434bb8ea98',int64),&
       int(z'3ff8800000000000',int64),int(z'bf70063546846319',int64),int(z'3fe8500000000000',int64),int(z'3ff89ba0f71469bf',int64),&
       int(z'3ff61cc228717efa',int64),int(z'4008b874afb7baf7',int64),int(z'40201015ec7286db',int64),int(z'40377f1f8329a469',int64),&
       int(z'40525e492927f0dd',int64),int(z'406e135c5ae80cd9',int64),int(z'4089736440df64fd',int64),int(z'3c89f53b1ed91b03',int64),&
       int(z'3feb9d4eb6067abc',int64),int(z'3ff8800000000000',int64),int(z'3f7ba0f71469bf33',int64),int(z'3fe8700000000000',int64),&
       int(z'3ff8c870d797dabf',int64),int(z'3ff6b426de42d55f',int64),int(z'4009c0fcc0e06552',int64),int(z'402103eceb059907',int64),&
       int(z'40394c6a49a75aa7',int64),int(z'40541a81b2a496d0',int64),int(z'4070baee209cb693',int64),int(z'408cc860285808c5',int64),&
       int(z'bcae6d8c9b0dc6f3',int64),int(z'3febceb2955ec1c4',int64),int(z'3ff8c00000000000',int64),int(z'3f60e1af2fb57ee7',int64),&
       int(z'3fe8900000000000',int64),int(z'3ff8f675d3c502f4',int64),int(z'3ff751eda3bfb2e4',int64),int(z'400ad956de3987bc',int64),&
       int(z'40220aa0b30aad0a',int64),int(z'403b45ab16220014',int64),int(z'40560929ec84429c',int64),int(z'4072a5690d747939',int64),&
       int(z'40904f105407f41e',int64),int(z'bc675cebfc269962',int64),int(z'3fec00714773138c',int64),int(z'3ff9000000000000',int64),&
       int(z'bf63145875fa1750',int64),int(z'3fe8b00000000000',int64),int(z'3ff925bd111125df',int64),int(z'3ff7f6790ad2b4c2',int64),&
       int(z'400c02bf1359a3c8',int64),int(z'4023260188857c21',int64),int(z'403d6feb2515d90e',int64),int(z'405830fad421145e',int64),&
       int(z'4074d1d6fd789544',int64),int(z'409285614b30ebf1',int64),int(z'3ca13e7b7876f9d2',int64),int(z'3fec328d437f5e74',int64),&
       int(z'3ff9400000000000',int64),int(z'bf7a42eeeeda20a4',int64),int(z'3fe8d00000000000',int64),int(z'3ff9565481b9477b',int64),&
       int(z'3ff8a23367f87779',int64),int(z'400d3e9014665ea0',int64),int(z'402458155a415747',int64),int(z'403fd0e11d7511c0',int64),&
       int(z'405a99b601ec30fb',int64),int(z'40774a72dd7ee7a1',int64),int(z'409514545c2f1724',int64),int(z'3c8185b3774a5205',int64),&
       int(z'3fec65091bd4ad0c',int64),int(z'3ff9400000000000',int64),int(z'3f765481b9477ac0',int64),int(z'3fe8f00000000000',int64),&
       int(z'3ff9884af50630b5',int64),int(z'3ff9558f94b35a8d',int64),int(z'400e8e46d1a32b1d',int64),int(z'4025a31f0aec68db',int64),&
       int(z'40413785fd21a759',int64),int(z'405d4c53f56dfca6',int64),int(z'407a1b45f89c0f5f',int64),int(z'40980bb3c92c8cf3',int64),&
       int(z'bc8696e8feb6a05e',int64),int(z'3fec97e77f82b8cc',int64),int(z'3ff9800000000000',int64),int(z'3f6095ea0c6169c6',int64),&
       int(z'3fe9100000000000',int64),int(z'3ff9bbb0292bc29f',int64),int(z'3ffa1109c8e3d76b',int64),int(z'400ff3868873c480',int64),&
       int(z'402709a6de619c77',int64),int(z'4042a8e95a9417b9',int64),int(z'4060299dbfe20b57',int64),int(z'407d5283e1225431',int64),&
       int(z'409b7e74c225406c',int64),int(z'bc87943174f396db',int64),int(z'3feccb2b3c239888',int64),int(z'3ff9c00000000000',int64),&
       int(z'bf513f5b50f5839f',int64),int(z'3fe9300000000000',int64),int(z'3ff9f094def4783d',int64),int(z'3ffad5288e300736',int64),&
       int(z'4010b80eb2d4d4ee',int64),int(z'40288e843f3d0057',int64),int(z'404440d4d20263c0',int64),int(z'4061dd4226e14927',int64),&
       int(z'4080807d5ef13d09',int64),int(z'409f836cfe9e94be',int64),int(z'bc813c84e5fd9d2d',int64),int(z'3fecfed73fccf104',int64),&
       int(z'3ffa000000000000',int64),int(z'bf6ed642170f854b',int64),int(z'3fe9500000000000',int64),int(z'3ffa270aef70c9f9',int64),&
       int(z'3ffba27dd12662d9',int64),int(z'40118304e8433b59',int64),int(z'402a34e91b4dd8d9',int64),int(z'4046041f58aa354c',int64),&
       int(z'4063c82387eb035b',int64),int(z'40829d4e7f89a6b6',int64),int(z'40a21b1ab4bed54d',int64),int(z'3c855d66fd8283d4',int64),&
       int(z'3fed32ee9b2a7684',int64),int(z'3ffa400000000000',int64),int(z'bf78f5108f3606b9',int64),int(z'3fe9700000000000',int64),&
       int(z'3ffa5f2563ea127f',int64),int(z'3ffc79a81460c218',int64),int(z'40125bc03d14975c',int64),int(z'402c006f2249db66',int64),&
       int(z'4047f856ed0aefcd',int64),int(z'4065f27f2e2028d0',int64),int(z'40850b956ce59595',int64),int(z'40a4dc2318c497e2',int64),&
       int(z'3c8bdfae76ba54ca',int64),int(z'3fed677483c60554',int64),int(z'3ffa400000000000',int64),int(z'3f7f2563ea127f53',int64),&
       int(z'3fe9900000000000',int64),int(z'3ffa98f89061cefe',int64),int(z'3ffd5b53caa1f466',int64),int(z'40134379a92630e8',int64),&
       int(z'402df52741e37357',int64),int(z'404a23dfd7de2305',int64),int(z'406865fe1911c50f',int64),int(z'4087d981d5ce543d',int64),&
       int(z'40a8192e2134a322',int64),int(z'bc915cf94fe6dac8',int64),int(z'3fed9c6c56821f74',int64),int(z'3ffa800000000000',int64),&
       int(z'3f78f89061cefdbb',int64),int(z'3fe9b00000000000',int64),int(z'3ffad49a30f0dacc',int64),int(z'3ffe483cddbfee70',int64),&
       int(z'40143b8cc4418459',int64),int(z'40300bd5e6e7e816',int64),int(z'404c8e1a02ee200e',int64),int(z'406b2dfc83038a03',int64),&
       int(z'408b1814d987e3d9',int64),int(z'40abeb1e8827cefa',int64),int(z'3ca8829ae22afce0',int64),int(z'3fedd1d99a4c39d0',int64),&
       int(z'3ffac00000000000',int64),int(z'3f749a30f0dacb86',int64),int(z'3fe9d00000000000',int64),int(z'3ffb12218a66e40d',int64),&
       int(z'3fff4130692dc10a',int64),int(z'4015457c64621a80',int64),int(z'4031369aed2a1ab4',int64),int(z'404f3f8dbc003a70',int64),&
       int(z'406e57e1462e99d6',int64),int(z'408edbc2c53f5717',int64),int(z'40b0383d0a71e453',int64),int(z'3c90af9fbedd86a9',int64),&
       int(z'3fee07c0030cf708',int64),int(z'3ffb000000000000',int64),int(z'3f72218a66e40cbe',int64),int(z'3fe9f00000000000',int64),&
       int(z'3ffb51a78e9927e5',int64),int(z'40002387581637b3',int64),int(z'401662f7f5b2c17e',int64),int(z'40327ddb36eac07e',int64),&
       int(z'40512110c70d9c43',int64),int(z'4070f9c488c52943',int64),int(z'40919e9eb1ab4848',int64),int(z'40b2e76bb1ec7695',int64),&
       int(z'3caa24005e9f6fd9',int64),int(z'3fee3e2374dd3c64',int64),int(z'3ffb400000000000',int64),int(z'3f71a78e9927e571',int64),&
       int(z'3fea100000000000',int64),int(z'3ffb934704e0f95f',int64),int(z'4000ad66ac8dc27b',int64),int(z'401795e1ae05a580',int64),&
       int(z'4033e4fa299aa0a0',int64),int(z'4052d0ada33ab75c',int64),int(z'407309e539d64c89',int64),int(z'40942d39154c34c4',int64),&
       int(z'40b61a5959d15b1d',int64),int(z'bcafc899114be565',int64),int(z'3fee75080787fd30',int64),int(z'3ffb800000000000',int64),&
       int(z'3f734704e0f95e8b',int64),int(z'3fea300000000000',int64),int(z'3ffbd71cb75f37a1',int64),int(z'40013ebcfc9006e1',int64),&
       int(z'4018e055c48d2c09',int64),int(z'40356fd7c2c8c9cd',int64),int(z'4054b5576198b971',int64),int(z'4075678c9680f9af',int64),&
       int(z'40972be58af946dd',int64),int(z'40b9ede4e1b531f9',int64),int(z'bc447f69e4527544',int64),int(z'3feeac720a61ad1c',int64),&
       int(z'3ffbc00000000000',int64),int(z'3f771cb75f37a0df',int64),int(z'3fea500000000000',int64),int(z'3ffc1d47a5b24f80',int64),&
       int(z'4001d81e7eb9f789',int64),int(z'401a44b2df42b6b7',int64),int(z'403722e5b4766752',int64),int(z'4056d6eeecfadff0',int64),&
       int(z'407820288b1eb8d5',int64),int(z'409ab0e2ca840144',int64),int(z'40be8614e2126bbf',int64),int(z'bc8d9a932cc624e2',int64),&
       int(z'3feee466087f8d20',int64),int(z'3ffc000000000000',int64),int(z'3f7d47a5b24f8064',int64),int(z'3fea700000000000',int64),&
       int(z'3ffc65e93de98207',int64),int(z'40027a2e811f641b',int64),int(z'401bc5a3f223266d',int64),int(z'40390340a6ecbe29',int64),&
       int(z'40593eb6c3d499af',int64),int(z'407b43d9ad8cc2f1',int64),int(z'409ed77ca519b816',int64),int(z'40c2080a5b3b703b',int64),&
       int(z'3c7b187de993c3dd',int64),int(z'3fef1ce8cd5a7ce8',int64),int(z'3ffc800000000000',int64),int(z'bf7a16c2167df937',int64),&
       int(z'3fea900000000000',int64),int(z'3ffcb1259ca2f05e',int64),int(z'400325a154fc4c95',int64),int(z'401d662bd9c5ff75',int64),&
       int(z'403b16ce8e93577d',int64),int(z'405bf79ae0e3029e',int64),int(z'407ee61204bcdf91',int64),int(z'40a1e0ac31efe3f1',int64),&
       int(z'40c5626785df051c',int64),int(z'bcad61222d0bc06e',int64),int(z'3fef55ff69eab2f0',int64),int(z'3ffcc00000000000',int64),&
       int(z'bf6db4c6ba1f43e4',int64),int(z'3feab00000000000',int64),int(z'3ffcff23d56b9f55',int64),int(z'4003db3e86149a3b',int64),&
       int(z'401f29b30b8d0dad',int64),int(z'403d646340e9d1a7',int64),int(z'405f0e89619d6679',int64),int(z'40818f2e92cf3fbc',int64),&
       int(z'40a4cc10844e51bd',int64),int(z'40c9762df3a9eb60',int64),int(z'3ca20e79ef4b1e02',int64),int(z'3fef8faf3a4bc01c',int64),&
       int(z'3ffd000000000000',int64),int(z'bf2b85528c156248',int64),int(z'3fead00000000000',int64),int(z'3ffd500e44aad4f2',int64),&
       int(z'40049be36b85db68',int64),int(z'40208a0be558f351',int64),int(z'403ff3ecc1bcc632',int64),int(z'406149702a555e45',int64),&
       int(z'408404aedd057f33',int64),int(z'40a847d922610a18',int64),int(z'40ce71463c7aa2b4',int64),int(z'bc9571d053ca14ec',int64),&
       int(z'3fefc9fdebfaa348',int64),int(z'3ffd400000000000',int64),int(z'3f700e44aad4f267',int64),int(z'3feaf00000000000',int64),&
       int(z'3ffda412ec9edc5a',int64),int(z'4005688622b6d908',int64),int(z'402194e0b605b3b4',int64),int(z'404167549338560c',int64),&
       int(z'40634b7b34b16169',int64),int(z'4086e5083b1baf9c',int64),int(z'40ac7475fb9dfbf5',int64),int(z'40d2473ef4b4bb01',int64),&
       int(z'3ca82b31e9f06efc',int64),int(z'3ff00278c2613f02',int64),int(z'3ffdc00000000000',int64),int(z'bf7bed136123a5d1',int64),&
       int(z'3feb100000000000',int64),int(z'3ffdfb63df3ae0db',int64),int(z'4006423908ad38cf',int64),int(z'4022b7dbaa166573',int64),&
       int(z'4042ffb438210d3e',int64),int(z'40659862fb634456',int64),int(z'408a45b4ee8f3e34',int64),int(z'40b0bd59d39a6c6f',int64),&
       int(z'40d60ccd2b4867e8',int64),int(z'bca6097f1cbb85b3',int64),int(z'3ff020483537e800',int64),int(z'3ffe000000000000',int64),&
       int(z'bf527083147c93ed',int64),int(z'3feb300000000000',int64),int(z'3ffe5637b70f5f72',int64),int(z'40072a2eca935102',int64),&
       int(z'4023f5de43559218',int64),int(z'4044c96eb4e19ca3',int64),int(z'40683d621272dda3',int64),int(z'408e4135c6bfaaed',int64),&
       int(z'40b3c717099fb249',int64),int(z'40daba6dd5294f7d',int64),int(z'3ca488b1c91ffa21',int64),int(z'3ff03e70b5b309e0',int64),&
       int(z'3ffe400000000000',int64),int(z'3f7637b70f5f723e',int64),int(z'3feb500000000000',int64),int(z'3ffeb4ca21d4b842',int64),&
       int(z'400821bf2be08fc5',int64),int(z'402552386a6a3bd0',int64),int(z'4046cc00bac907e2',int64),int(z'406b4a7894202458',int64),&
       int(z'40917c35fe065ca6',int64),int(z'40b77848e8d5b845',int64),int(z'40e048200cd72d76',int64),int(z'3ca54b6e9cbe508b',int64),&
       int(z'3ff05cf5e41c2ace',int64),int(z'3ffec00000000000',int64),int(z'bf666bbc568f7c18',int64),int(z'3feb700000000000',int64),&
       int(z'3fff175c7fb6eb26',int64),int(z'40092a6ca7ba9c35',int64),int(z'4026d0bc80f5ba9f',int64),int(z'4049104833bd74fb',int64),&
       int(z'406ed31961fce21f',int64),int(z'40944a2e60df5aed',int64),int(z'40bbfafc1ac97175',int64),int(z'40e3f145c3a8bc22',int64),&
       int(z'bc994b5da70a42d9',int64),int(z'3ff07bdb9f358760',int64),int(z'3fff000000000000',int64),int(z'3f775c7fb6eb2582',int64),&
       int(z'3feb900000000000',int64),int(z'3fff7e369b29492c',int64),int(z'400a45eb1c35ad8a',int64),int(z'402875d7c8373bb1',int64),&
       int(z'404ba0d1885e6ae6',int64),int(z'407177840831631e',int64),int(z'4097a4417f51da78',int64),int(z'40c0c2b26d7642fb',int64),&
       int(z'40e89073594961fb',int64),int(z'bca5dece96cdc181',int64),int(z'3ff09b260a46374e',int64),int(z'3fff800000000000',int64),&
       int(z'bf3c964d6b6d3d05',int64),int(z'3febb00000000000',int64),int(z'3fffe9a77dd9b1cf',int64),int(z'400b7627b9ae77af',int64),&
       int(z'402a46b03338306d',int64),int(z'404e8a38a0caace9',int64),int(z'4073ddbb864f53a2',int64),int(z'409baaf0d6c97f8d',int64),&
       int(z'40c42eefdfae5a98',int64),int(z'40ee701ae19501da',int64),int(z'3c9cc4f4c7d3d675',int64),int(z'3ff0bad993ec49ae',int64),&
       int(z'4000000000000000',int64),int(z'bf765882264e310d',int64),int(z'3febd00000000000',int64),int(z'40002d0334302f3b',int64),&
       int(z'400cbd527f5aaf0d',int64),int(z'402c49490c635c0a',int64),int(z'4050edd1b6bb1732',int64),int(z'4076ae3d9691a9f4',int64),&
       int(z'40a043c761482fc6',int64),int(z'40c87037f81eb6e0',int64),int(z'40f2fa30e84fe55e',int64),int(z'bc9820f1228fc41d',int64),&
       int(z'3ff0dafafdd4ae68',int64),int(z'4000200000000000',int64),int(z'3f7a0668605e76b0',int64),int(z'3febf00000000000',int64),&
       int(z'400067d9f9c947a3',int64),int(z'400e1de9a1722882',int64),int(z'402e84b041fe0247',int64),int(z'4052d3aedbd1d676',int64),&
       int(z'4079ff78e088bef5',int64),int(z'40a3378064d9a484',int64),int(z'40cdc32d1974f9b5',int64),int(z'40f7d295ce268611',int64),&
       int(z'bca5a192d437d23f',int64),int(z'3ff0fb8f657efdca',int64),int(z'4000600000000000',int64),int(z'3f6f67e7251e8cf3',int64),&
       int(z'3fec100000000000',int64),int(z'4000a58db1fffa6d',int64),int(z'400f9ac74e7307c3',int64),int(z'4030809b5ea15962',int64),&
       int(z'405501d05418e1b6',int64),int(z'407ded80b476d79f',int64),int(z'40a6d2bf37f33d5f',int64),int(z'40d23c31a43f6c6f',int64),&
       int(z'40fe1e46db17bbaa',int64),int(z'bca7eb6241d8ad56',int64),int(z'3ff11c9c4e3ade0a',int64),int(z'4000a00000000000',int64),&
       int(z'3f6636c7ffe9b457',int64),int(z'3fec300000000000',int64),int(z'4000e65a1d1bdcc6',int64),int(z'40109b993503ccce',int64),&
       int(z'4031e45b7580ec24',int64),int(z'405785ca1803e176',int64),int(z'40814ddb8458a77d',int64),int(z'40ab41d96c115ab7',int64),&
       int(z'40d67df0d7bce584',int64),int(z'41032ef5f5487646',int64),int(z'bc9c4040f3631254',int64),int(z'3ff13e27ac964da8',int64),&
       int(z'4000e00000000000',int64),int(z'3f6968746f731770',int64),int(z'3fec500000000000',int64),int(z'40012a82068fbcb4',int64),&
       int(z'40117b797fe89a5f',int64),int(z'40337376d37f3897',int64),int(z'405a704edf3b47a2',int64),int(z'40841b83eb114449',int64),&
       int(z'40b05f758d323120',int64),int(z'40dbefec8ae65ddd',int64),int(z'4108a2a2d1814341',int64),int(z'3ca3e83dfb25ec76',int64),&
       int(z'3ff16037f37ffeda',int64),int(z'4001200000000000',int64),int(z'3f75040d1f796787',int64),int(z'3fec700000000000',int64),&
       int(z'400172505f8f574b',int64),int(z'40126f35b566493d',int64),int(z'403534f595186e3d',int64),int(z'405dd60b947d5ea5',int64),&
       int(z'40877c77568c5d73',int64),int(z'40b3cb66a26261f0',int64),int(z'40e17b06bf32194d',int64),int(z'410fe92111490e42',int64),&
       int(z'bca344285376cb61',int64),int(z'3ff182d4236fe314',int64),int(z'4001800000000000',int64),int(z'bf7b5f40e15169a9',int64),&
       int(z'3fec900000000000',int64),int(z'4001be1991b4c8d8',int64),int(z'4013795bbe69bae6',int64),int(z'40373151cd6f8b02',int64),&
       int(z'4060e864d86a7bff',int64),int(z'408b95cc515f5bd6',int64),int(z'40b8180cd070b4a1',int64),int(z'40e60d2cc9b24d80',int64),&
       int(z'4114dbf6aa392caf',int64),int(z'bca89bd0f5844c55',int64),int(z'3ff1a603dbfaf236',int64),int(z'4001c00000000000',int64),&
       int(z'bf4e66e4b37285fc',int64),int(z'3fecb00000000000',int64),int(z'40020e3d1757f6b1',int64),int(z'40149ce9ae890640',int64),&
       int(z'403972d4d6174f60',int64),int(z'406340798c82df92',int64),int(z'40904be6acab5569',int64),int(z'40bd8a99b362e75a',int64),&
       int(z'40ec0ed7389374dc',int64),int(z'411b8adfca5e9653',int64),int(z'bc80cbc74a1e3e49',int64),int(z'3ff1c9cf704f5d26',int64),&
       int(z'4002000000000000',int64),int(z'3f7c7a2eafed62a2',int64),int(z'3fecd00000000000',int64),int(z'400263276b3395aa',int64),&
       int(z'4015dd6633fb1467',int64),int(z'403c0610dcf3437c',int64),int(z'406607cec9d7c47a',int64),int(z'409360fba330dc5c',int64),&
       int(z'40c240b438a3194b',int64),int(z'40f20437baa6a879',int64),int(z'4122610604d6f19c',int64),int(z'3cabccf515e5252c',int64),&
       int(z'3ff1ee3fff35681a',int64),int(z'4002600000000000',int64),int(z'3f593b599cad4ce9',int64),int(z'3fecf00000000000',int64),&
       int(z'4002bd54664a8350',int64),int(z'40173eff945190a0',int64),int(z'403efa80c7cc5224',int64),int(z'406958aa896f1658',int64),&
       int(z'409734504fd54e04',int64),int(z'40c6bf554cd60c4a',int64),int(z'40f75ebe3effd07c',int64),int(z'4128d03c9e2e6981',int64),&
       int(z'bc987ceec8a488ff',int64),int(z'3ff2135f8f597306',int64),int(z'4002c00000000000',int64),int(z'bf555ccdabe583fe',int64),&
       int(z'3fed100000000000',int64),int(z'40031d522a40ea5c',int64),int(z'4018c6b352b4947d',int64),int(z'404131ae5d01146e',int64),&
       int(z'406d54fb0163e71c',int64),int(z'409bfe8aef3ed15b',int64),int(z'40cc9c28a33a6b00',int64),int(z'40fea5231456e1a6',int64),&
       int(z'4130f60ffc8790db',int64),int(z'3cac104f6fabca41',int64),int(z'3ff2393930d87c68',int64),int(z'4003200000000000',int64),&
       int(z'bf556eadf8ad1cf9',int64),int(z'3fed300000000000',int64),int(z'400383c4c053c623',int64),int(z'401a7a816adbff2c',int64),&
       int(z'40432c5be219a24e',int64),int(z'4071148430f4b8d8',int64),int(z'40a10659bc59423e',int64),int(z'40d22c093d537ae5',int64),&
       int(z'410454a2a4b7d930',int64),int(z'41378151c151f3c3',int64),int(z'bca2f226779e9951',int64),int(z'3ff25fd9254e3f9c',int64),&
       int(z'4003800000000000',int64),int(z'3f5e26029e311a8b',int64),int(z'3fed500000000000',int64),int(z'4003f16aa2f65f8c',int64),&
       int(z'401c61af36c0308e',int64),int(z'40457c825337ff7d',int64),int(z'407407a37fb84ba9',int64),int(z'40a4e4764c74dea7',int64),&
       int(z'40d75638df1c2124',int64),int(z'410b5320a2556e94',int64),int(z'414087cd7d68abbe',int64),int(z'bcacd58c73a87ab9',int64),&
       int(z'3ff2874d10017b06',int64),int(z'4004000000000000',int64),int(z'bf7d2aba1340e849',int64),int(z'3fed700000000000',int64),&
       int(z'400467227ba9a810',int64),int(z'401e851fcbc74735',int64),int(z'40483596f3879985',int64),int(z'4077aaebcd297f00',int64),&
       int(z'40a9e3c831669f50',int64),int(z'40de5420b7cbb664',int64),int(z'41129f7bb75100a0',int64),int(z'4147a1c151d127bf',int64),&
       int(z'3cac647e46d9c78f',int64),int(z'3ff2afa4304962ae',int64),int(z'4004600000000000',int64),int(z'3f6c89eea6a041c9',int64),&
       int(z'3fed900000000000',int64),int(z'4004e5f27a99a835',int64),int(z'402077e515b0232d',int64),int(z'404b70c1ee468866',int64),&
       int(z'407c334a43a041c3',int64),int(z'40b036d153d2c164',int64),int(z'40e3f7b110ccedbe',int64),int(z'4119c160f6c2e560',int64),&
       int(z'415131dd6d21d20f',int64),int(z'418786832ec50766',int64),int(z'bca95596d1134ecc',int64),int(z'3ff2d8efa8f4b028',int64),&
       int(z'4004e00000000000',int64),int(z'3f67c9ea66a0d2c7',int64),int(z'3fedb00000000000',int64),int(z'40056f11d6373b90',int64),&
       int(z'4021d7acc3747df3',int64),int(z'404f4ef36a014d6f',int64),int(z'4080f4c4505c454b',int64),int(z'40b48d16214975c5',int64),&
       int(z'40eaacfdf57bfac6',int64),int(z'412222355225a6ed',int64),int(z'41598643acba67ab',int64),int(z'419267b9de5d19b9',int64),&
       int(z'bcaef63c42c92439',int64),int(z'3ff30342d86bed76',int64),int(z'4005600000000000',int64),int(z'3f7e23ac6e771f48',int64),&
       int(z'3fedd00000000000',int64),int(z'400603f53d2d8cf1',int64),int(z'40236a84ef4a10fa',int64),int(z'4051fdf34ea265af',int64),&
       int(z'408499b5d944f636',int64),int(z'40ba64b837f73bac',int64),int(z'40f21b9f259b27fc',int64),int(z'412a0669265d5b9f',int64),&
       int(z'41635d8e3dc806e2',int64),int(z'419d865736ad8b00',int64),int(z'3ca4ceeb3ffcdca3',int64),int(z'3ff32eb3c69d2d10',int64),&
       int(z'4006000000000000',int64),int(z'3f5fa9e96c678625',int64),int(z'3fedf00000000000',int64),int(z'4006a65f5fcdf915',int64),&
       int(z'40253b6e68321bda',int64),int(z'4054d949706e8da9',int64),int(z'408950ef4a70d2d7',int64),int(z'40c133191f15e14e',int64),&
       int(z'40f907b1846a9bd5',int64),int(z'4133139c17c39016',int64),int(z'416e1da3bc86f11b',int64),int(z'41a8597fd9f86f3b',int64),&
       int(z'3c32d4f87d0d5190',int64),int(z'3ff35b5bafa88354',int64),int(z'4006a00000000000',int64),int(z'3f697d7f37e455fd',int64),&
       int(z'3fee100000000000',int64),int(z'4007587741d1dbf9',int64),int(z'402758a8f5852184',int64),int(z'405861ee65c0f467',int64),&
       int(z'408f83c0d2d91276',int64),int(z'40c6ca7c43ec3b0e',int64),int(z'4101a722718322c8',int64),int(z'413ca4c69533d806',int64),&
       int(z'417812b7e9899583',int64),int(z'41b4b87585ee8b86',int64),int(z'bc99defbd1aeeed1',int64),int(z'3ff38957b510476e',int64),&
       int(z'4007600000000000',int64),int(z'bf6e22f8b8901bf9',int64),int(z'3fee300000000000',int64),int(z'40081ce6e1c37e57',int64),&
       int(z'4029d4f3d3dc9910',int64),int(z'405cd074e3095065',int64),int(z'4093e764c5c38224',int64),int(z'40cec5ae3cae1f31',int64),&
       int(z'41097a50c0645f38',int64),int(z'41461866d8a7f25e',int64),int(z'4183daf58c2f04a3',int64),int(z'41c2450ea9143c1f',int64),&
       int(z'3c7d25be9fd995bc',int64),int(z'3ff3b8c9c35d33e6',int64),int(z'4008200000000000',int64),int(z'bf58c8f1e40d49e0',int64),&
       int(z'3fee500000000000',int64),int(z'4008f706285640bb',int64),int(z'402cc96b3b2b7cd1',int64),int(z'40613adfc5341328',int64),&
       int(z'4099908d16e928a9',int64),int(z'40d539867cc08a3c',int64),int(z'4112dfc531dd3e45',int64),int(z'41519499e2a13787',int64),&
       int(z'4190f943f94424ad',int64),int(z'41d0c6bccdcd49be',int64),int(z'bc9e24586d41701d',int64),int(z'3ff3e9d9c088bd28',int64),&
       int(z'4009000000000000',int64),int(z'bf71f3af537e8a00',int64),int(z'3fee700000000000',int64),int(z'4009eb186562d1e0',int64),&
       int(z'40302c3175651223',int64),int(z'4064e431336e41c7',int64),int(z'40a0bca6a065da69',int64),int(z'40de034d917af357',int64),&
       int(z'411cd2c14168fb0f',int64),int(z'415cfeb615bb794d',int64),int(z'419e3ee16effd5e5',int64),int(z'41e024e71acb4d9c',int64),&
       int(z'bc9c29c8d93f153f',int64),int(z'3ff41cb72183e810',int64),int(z'4009e00000000000',int64),int(z'3f7630cac5a3c038',int64),&
       int(z'3fee900000000000',int64),int(z'400afea6a364196f',int64),int(z'403258f30b19a2eb',int64),int(z'4069bda52520ac75',int64),&
       int(z'40a669bc8f67edea',int64),int(z'40e5d78cc026c9f8',int64),int(z'4126ccb41e3b36c2',int64),int(z'4168ede4bf45c805',int64),&
       int(z'41ac2f6a8ac89e76',int64),int(z'41f0675e4ca9eb55',int64),int(z'42336ac10d13e3df',int64),int(z'3c9b1d74f2de93a6',int64),&
       int(z'3ff4519b155fb22e',int64),int(z'400b000000000000',int64),int(z'bf4595c9be690e67',int64),int(z'3feeb00000000000',int64),&
       int(z'400c39084bd1c065',int64),int(z'40350d8826c39ffd',int64),int(z'4070296b69d3e79e',int64),int(z'40aed279d7feea5d',int64),&
       int(z'40f072a8fd5bd547',int64),int(z'4132cdb94a08bb38',int64),int(z'41768482536bed06',int64),int(z'41bbe1ff2f10e88d',int64),&
       int(z'4201c966abdbbdac',int64),int(z'4247101102e62dda',int64),int(z'bca0855d3e907e71',int64),int(z'3ff488cb8fa73920',int64),&
       int(z'400c400000000000',int64),int(z'bf6bded0b8fe6ddf',int64),int(z'3feed00000000000',int64),int(z'400da43912aaf9a9',int64),&
       int(z'40387d4662f25109',int64),int(z'4074c3393f133a3f',int64),int(z'40b5e143662036f9',int64),int(z'40f9cf0474467831',int64),&
       int(z'41404e10576c6fa8',int64),int(z'41859489ff4f8e88',int64),int(z'41cd88d2b44962a9',int64),int(z'4214d83897a288f3',int64),&
       int(z'425de10b6cf738b3',int64),int(z'bc8e9ea75f7263cc',int64),int(z'3ff4c29faa786f36',int64),int(z'400da00000000000',int64),&
       int(z'3f60e44aabe6a2ad',int64),int(z'3feef00000000000',int64),int(z'400f4e35c169b52f',int64),int(z'403cf77329e8699c',int64),&
       int(z'407b6d37fc1818d6',int64),int(z'40c026551386790a',int64),int(z'41054a1f4ff79d1e',int64),int(z'414e104a7db0265a',int64),&
       int(z'41963c39e5c8114b',int64),int(z'41e10156f52a87db',int64),int(z'422add762e9e7abe',int64),int(z'427586ab6ec81361',int64),&
 int(z'3c935690e395eea6', int64), int(z'3ff4ff862e5965a2', int64), int(z'400f400000000000', int64), int(z'3f7c6b82d36a5e70', int64)]
  real(real64), parameter :: inverse_table(0:2567) = transfer(inverse_table_words, [0.0_real64], 2568)
  integer(int64), parameter :: inverse_root_words(0:127) = [ &
       int(z'3ff68a1f80d71820',int64),int(z'3ff65de82af9631f',int64),int(z'3ff632b1201d39e5',int64),int(z'3ff60870d91bf3c2',int64),&
       int(z'3ff5df1e4be5e7a2',int64),int(z'3ff5b6b0e361668b',int64),int(z'3ff58f2077eca742',int64),int(z'3ff568654873c1e3',int64),&
       int(z'3ff54277f40d6cb8',int64),int(z'3ff51d51741283a0',int64),int(z'3ff4f8eb16a59835',int64),int(z'3ff4d53e79a0e15c',int64),&
       int(z'3ff4b24585e1ca16',int64),int(z'3ff48ffa6aea45fe',int64),int(z'3ff46e579ad0c47a',int64),int(z'3ff44d57c6785455',int64),&
       int(z'3ff42cf5da0b1da2',int64),int(z'3ff40d2cf9b1e1cb',int64),int(z'3ff3edf87e83b18e',int64),int(z'3ff3cf53f3a97317',int64),&
       int(z'3ff3b13b13b13b10',int64),int(z'3ff393a9c60dd0e1',int64),int(z'3ff3769c1cbf0b05',int64),int(z'3ff35a0e521ff992',int64),&
       int(z'3ff33dfcc6d81367',int64),int(z'3ff32263ffecdbdd',int64),int(z'3ff30740a4f1a8e0',int64),int(z'3ff2ec8f7e53640d',int64),&
       int(z'3ff2d24d73be4ec9',int64),int(z'3ff2b8778a9bf8ec',int64),int(z'3ff29f0ae4a7bd6f',int64),int(z'3ff28604be983e91',int64),&
       int(z'3ff26d626edc7332',int64),int(z'3ff25521646af854',int64),int(z'3ff23d3f25a271bc',int64),int(z'3ff225b94f39da5b',int64),&
       int(z'3ff20e8d933fbc46',int64),int(z'3ff1f7b9b8275cce',int64),int(z'3ff1e13b97e2f7f2',int64),int(z'3ff1cb111f0a37d1',int64),&
       int(z'3ff1b5384c0c28bc',int64),int(z'3ff19faf2e6beff6',int64),int(z'3ff18a73e6079ee1',int64),int(z'3ff17584a268851e',int64),&
       int(z'3ff160dfa21c700d',int64),int(z'3ff14c8332174f8c',int64),int(z'3ff1386dad1cc065',int64),int(z'3ff1249d7b3107fb',int64),&
       int(z'3ff1111111111120',int64),int(z'3ff0fdc6efb1043e',int64),int(z'3ff0eabda3c11a68',int64),int(z'3ff0d7f3c53851c1',int64),&
       int(z'3ff0c567f6e4acef',int64),int(z'3ff0b318e600b285',int64),int(z'3ff0a10549cddf4f',int64),int(z'3ff08f2be333c85c',int64),&
       int(z'3ff07d8b7c63aadf',int64),int(z'3ff06c22e8802d59',int64),int(z'3ff05af103491a22',int64),int(z'3ff049f4b0cadb27',int64),&
       int(z'3ff0392cdd118774',int64),int(z'3ff028987bdf5125',int64),int(z'3ff0183688662733',int64),int(z'3ff00806050463f7',int64),&
       int(z'3fefe02fb08b05a2',int64),int(z'3fefa1a7bb61d36f',int64),int(z'3fef648a3a321fb7',int64),int(z'3fef28c9b380eba0',int64),&
       int(z'3feeee595eba94c0',int64),int(z'3feeb52d18b3d37d',int64),int(z'3fee7d3959112457',int64),int(z'3fee4673287f9dc5',int64),&
       int(z'3fee10d017ac51a6',int64),int(z'3feddc4636e9573e',int64),int(z'3feda8cc0e7149ee',int64),int(z'3fed7658973b887c',int64),&
       int(z'3fed44e33454e185',int64),int(z'3fed1463acb186ad',int64),int(z'3fece4d2256e352e',int64),int(z'3fecb6271c77707c',int64),&
       int(z'3fec885b638e9087',int64),int(z'3fec5b681ba51d60',int64),int(z'3fec2f46b087a5e7',int64),int(z'3fec03f0d4d1e1b0',int64),&
       int(z'3febd9607e2670d9',int64),int(z'3febaf8fe1a51499',int64),int(z'3feb8679709aaac2',int64),int(z'3feb5e17d566a055',int64),&
       int(z'3feb3665f091e62b',int64),int(z'3feb0f5ed613d3f1',int64),int(z'3feae8fdcac1a25d',int64),int(z'3feac33e41e57a2d',int64),&
       int(z'3fea9e1bdafa4be1',int64),int(z'3fea79925f89def6',int64),int(z'3fea559dc12abd3a',int64),int(z'3fea323a179bcde9',int64),&
       int(z'3fea0f639efb9e4b',int64),int(z'3fe9ed16b6197fd7',int64),int(z'3fe9cb4fdcdec59d',int64),int(z'3fe9aa0bb2ce89c8',int64),&
       int(z'3fe98946f59a8beb',int64),int(z'3fe968fe7fcbc524',int64),int(z'3fe9492f477d78d4',int64),int(z'3fe929d65d2990a8',int64),&
       int(z'3fe90af0ea853815',int64),int(z'3fe8ec7c316cae0f',int64),int(z'3fe8ce758add6570',int64),int(z'3fe8b0da65fd9394',int64),&
       int(z'3fe893a847305ac9',int64),int(z'3fe876dcc735d942',int64),int(z'3fe85a75925660f9',int64),int(z'3fe83e706798349d',int64),&
       int(z'3fe822cb17ff2eb2',int64),int(z'3fe8078385d5c0de',int64),int(z'3fe7ec97a3fec010',int64),int(z'3fe7d205754f8264',int64),&
       int(z'3fe7b7cb0bf1d70f',int64),int(z'3fe79de688cd6672',int64),int(z'3fe784561af81485',int64),int(z'3fe76b17ff2d032c',int64),&
       int(z'3fe7522a7f49d736',int64),int(z'3fe7398bf1d1ee54',int64),int(z'3fe7213ab9772ee3',int64),int(z'3fe7093544a82bc7',int64),&
 int(z'3fe6f17a0d23510e', int64), int(z'3fe6da07978eda76', int64), int(z'3fe6c2dc73154e64', int64), int(z'3fe6abf7390648fe', int64)]
  real(real64), parameter :: inverse_root(0:127) = transfer(inverse_root_words, [0.0_real64], 128)
  integer(int64), parameter :: power_two_words(0:27) = [ &
       int(z'3ff0000000000000',int64),int(z'4000000000000000',int64),int(z'4010000000000000',int64),int(z'4020000000000000',int64),&
       int(z'4030000000000000',int64),int(z'4040000000000000',int64),int(z'4050000000000000',int64),int(z'4060000000000000',int64),&
       int(z'4070000000000000',int64),int(z'4080000000000000',int64),int(z'4090000000000000',int64),int(z'40a0000000000000',int64),&
       int(z'40b0000000000000',int64),int(z'40c0000000000000',int64),int(z'40d0000000000000',int64),int(z'40e0000000000000',int64),&
       int(z'40f0000000000000',int64),int(z'4100000000000000',int64),int(z'4110000000000000',int64),int(z'4120000000000000',int64),&
       int(z'4130000000000000',int64),int(z'4140000000000000',int64),int(z'4150000000000000',int64),int(z'4160000000000000',int64),&
 int(z'4170000000000000', int64), int(z'4180000000000000', int64), int(z'4190000000000000', int64), int(z'41a0000000000000', int64)]
  real(real64), parameter :: power_two(0:27) = transfer(power_two_words, [0.0_real64], 28)
contains
  function small_polynomial(square) result(value)
    real(real64), intent(in) :: square
    real(real64), volatile :: value
    integer :: j
    value = coefficients(5)
    do j = 4, 0, -1
      value = rounded_product_sum(value, square, coefficients(j))
    end do
  end function
  subroutine table_polynomial(value, high_word, base, correction)
    real(real64), intent(in) :: value
    integer(int64), intent(in) :: high_word
    real(real64), intent(out) :: base, correction
    real(real64), volatile :: offset, square, polynomial
    integer :: index, degree, j
    if (high_word < int(z'3fe00000', int64)) then
      if (high_word < int(z'3fd00000', int64)) then
        index = int(ibits(high_word, 15, 5))*11
      else
        index = int(ibits(high_word, 14, 6))*11 + 352
      end if
      degree = 6
    else if (high_word < int(z'3fe80000', int64)) then
      index = int(ibits(high_word, 13, 7))*12 + 1056; degree = 7
    else if (high_word < int(z'3fed8000', int64)) then
      index = int(ibits(high_word, 13, 7))*13 + 992; degree = 8
    else if (high_word < int(z'3fee8000', int64)) then
      index = int(ibits(high_word, 13, 7))*14 + 884; degree = 9
    else
      index = int(ibits(high_word, 13, 7))*15 + 768; degree = 10
    end if
    offset = abs(value) - inverse_table(index)
    square = offset*offset
    polynomial = inverse_table(index + degree)
    do j = degree - 1, 2, -1
      polynomial = rounded_product_sum(polynomial, offset, inverse_table(index + j))
    end do
    polynomial = rounded_product_sum(square, polynomial, inverse_table(index + degree + 1))
    correction = rounded_product_sum(inverse_table(index + 1), offset, polynomial)
    base = inverse_table(index + degree + 2)
  end subroutine
  subroutine root_approximation(value, square, root, correction)
    real(real64), intent(in) :: value
    real(real64), intent(out) :: square, root, correction
    real(real64), volatile :: argument, inverse, product, error, polynomial, approximate, adjust
    integer(int64) :: word
    integer :: index, power
    argument = 1.0_real64 - abs(value)
    argument = argument*0.5_real64
    word = transfer(argument, 0_int64)
    index = int(ibits(word, 46, 7)); power = 511 - int(ishft(word, -53))
    inverse = inverse_root(index)*power_two(power)
    product = inverse*inverse
    product = -product
    error = rounded_product_sum(product, argument, 1.0_real64)
    polynomial = rounded_product_sum(coefficients(9), error, coefficients(8))
    polynomial = rounded_product_sum(polynomial, error, coefficients(7))
    polynomial = rounded_product_sum(polynomial, error, coefficients(6))
    inverse = inverse*polynomial
    approximate = inverse*argument
    adjust = inverse*0.5_real64
    adjust = -adjust
    adjust = rounded_product_sum(adjust, approximate, 1.5_real64)
    square = argument; root = approximate; correction = adjust
  end subroutine
  !> Every table and correction follows the source increasing dependency order.
  function original_rounding_asine(value) result(answer)
    real(real64), intent(in) :: value
    real(real64) :: answer
    real(real64), volatile :: square, polynomial, cube, a, b, c, root, adjust, high, low, denominator
    integer(int64) :: word, magnitude, high_word
    word = transfer(value, 0_int64); magnitude = iand(word, huge(0_int64))
    if (magnitude > int(z'3ff0000000000000', int64)) call reject_contract()
    if (magnitude == int(z'3ff0000000000000', int64)) then
      answer = coefficients(10)
      if (btest(word, 63)) answer = -answer
      return
    end if
    high_word = ishft(magnitude, -32)
    if (high_word < int(z'3e500000', int64)) then
      if (magnitude < int(z'0010000000000000', int64)) square = value*value
      answer = value; return
    end if
    if (high_word < int(z'3fc00000', int64)) then
      square = value*value
      polynomial = small_polynomial(square)
      cube = square*value
      answer = rounded_product_sum(polynomial, cube, value)
      return
    else if (high_word < int(z'3fef0000', int64)) then
      call table_polynomial(value, high_word, a, b)
      answer = a + b
    else
      call root_approximation(value, square, root, adjust)
      a = transfer(int(z'4170000000000000', int64), 0.0_real64)
      high = root + a
      high = high - a
      denominator = rounded_product_sum(adjust, root, high)
      a = -high
      low = rounded_product_sum(a, high, square)
      low = low/denominator
      polynomial = small_polynomial(square)
      polynomial = polynomial*square
      a = -low
      c = rounded_product_sum(a, 2.0_real64, coefficients(11))
      b = high + low
      b = b + b
      b = -b
      c = rounded_product_sum(b, polynomial, c)
      a = -high
      b = rounded_product_sum(a, 2.0_real64, coefficients(10))
      answer = b + c
    end if
    if (btest(word, 63)) answer = -answer
  end function
  function original_rounding_acosine(value) result(answer)
    real(real64), intent(in) :: value
    real(real64) :: answer
    real(real64), volatile :: square, polynomial, cube, a, b, c, root, adjust, high, low, denominator
    integer(int64) :: word, magnitude, high_word
    word = transfer(value, 0_int64); magnitude = iand(word, huge(0_int64))
    if (magnitude > int(z'3ff0000000000000', int64)) call reject_contract()
    if (magnitude == int(z'3ff0000000000000', int64)) then
      answer = 0.0_real64
      if (btest(word, 63)) then
        a = coefficients(10)
        answer = a + a
      end if
      return
    end if
    high_word = ishft(magnitude, -32)
    if (high_word < int(z'3c880000', int64)) then
      answer = coefficients(10); return
    end if
    if (high_word < int(z'3fc00000', int64)) then
      square = value*value
      polynomial = small_polynomial(square)
      cube = square*value
      a = coefficients(10) - value
      b = coefficients(10) - a
      b = b - value
      b = b + coefficients(11)
      c = -polynomial
      b = rounded_product_sum(c, cube, b)
      answer = a + b
    else if (high_word < int(z'3fef0000', int64)) then
      call table_polynomial(value, high_word, a, b)
      if (btest(word, 63)) then
        c = coefficients(10) + a
        b = coefficients(11) + b
      else
        c = coefficients(10) - a
        b = coefficients(11) - b
      end if
      answer = c + b
    else
      call root_approximation(value, square, root, adjust)
      a = rounded_product_sum(coefficients(12), root, root)
      b = -coefficients(12)
      high = rounded_product_sum(b, root, a)
      denominator = rounded_product_sum(adjust, root, high)
      a = -high
      low = rounded_product_sum(a, high, square)
      low = low/denominator
      polynomial = small_polynomial(square)
      polynomial = polynomial*square
      a = high + low
      a = polynomial*a
      if (btest(word, 63)) then
        low = coefficients(11) - low
        low = low - a
        high = coefficients(10) - high
        answer = high + low
      else
        low = low + a
        answer = high + low
      end if
      answer = answer + answer
    end if
  end function
end module forecast_source_rounding_inverse_trigonometry
