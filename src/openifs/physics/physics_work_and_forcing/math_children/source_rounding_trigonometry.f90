! Algorithm and literal table derive from GNU libc 2.38 IBM Accurate Math Library.
! Copyright (C) 2001-2023 Free Software Foundation, Inc.
! SPDX-License-Identifier: LGPL-2.1-or-later
!> Preserve the frozen source sine and cosine arithmetic without a system-math substitution.
!! Angles and results are FP64. Angles use radians with absolute value at most 2**20.
!! The caller establishes nearest rounding and gradual underflow. No array is owned.
module forecast_source_rounding_trigonometry
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int
  use forecast_spline_scalar_inverse, only: rounded_product_sum
  implicit none
  private
  public :: original_rounding_sine, original_rounding_cosine
  interface
    subroutine public_abort() bind(C, name='abort')
    end subroutine
  end interface
  real(real64), parameter :: big = transfer(int(z'42c8000000000000', int64), 0.0_real64)
  real(real64), parameter :: hp0 = transfer(int(z'3ff921fb54442d18', int64), 0.0_real64)
  real(real64), parameter :: hp1 = transfer(int(z'3c91a62633145c07', int64), 0.0_real64)
  real(real64), parameter :: hpinv = transfer(int(z'3fe45f306dc9c883', int64), 0.0_real64)
  real(real64), parameter :: toint = transfer(int(z'4338000000000000', int64), 0.0_real64)
  real(real64), parameter :: mp1 = transfer(int(z'3ff921fb58000000', int64), 0.0_real64)
  real(real64), parameter :: mp2 = transfer(int(z'be4dde973c000000', int64), 0.0_real64)
  real(real64), parameter :: pp3 = transfer(int(z'bc8cb3b398000000', int64), 0.0_real64)
  real(real64), parameter :: pp4 = transfer(int(z'bacd747f23e32ed7', int64), 0.0_real64)
  real(real64), parameter :: sn3 = transfer(int(z'bfc5555555555515', int64), 0.0_real64)
  real(real64), parameter :: sn5 = transfer(int(z'3f811110e829872f', int64), 0.0_real64)
  real(real64), parameter :: cs2 = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
  real(real64), parameter :: cs4 = transfer(int(z'bfa5555555555535', int64), 0.0_real64)
  real(real64), parameter :: cs6 = transfer(int(z'3f56c16bedd9e239', int64), 0.0_real64)
  real(real64), parameter :: s1 = transfer(int(z'bfc5555555555555', int64), 0.0_real64)
  real(real64), parameter :: s2 = transfer(int(z'3f81111111110ece', int64), 0.0_real64)
  real(real64), parameter :: s3 = transfer(int(z'bf2a01a019db08b8', int64), 0.0_real64)
  real(real64), parameter :: s4 = transfer(int(z'3ec71de27b9a7ed9', int64), 0.0_real64)
  real(real64), parameter :: s5 = transfer(int(z'be5addffc2fcdf59', int64), 0.0_real64)
  real(real64), parameter :: taylor_cutoff = transfer(int(z'3fc020c49ba5e354', int64), 0.0_real64)
  integer(int64), parameter :: table_words(440) = [ &
   int(z'0000000000000000',int64), int(z'0000000000000000',int64), int(z'3ff0000000000000',int64), int(z'0000000000000000',int64), &
   int(z'3f7fffeaaaaeeeef',int64), int(z'bc1e45e2ec67b77c',int64), int(z'3fefffc000155552',int64), int(z'3c8f4a01a0196dae',int64), &
   int(z'3f8fffaaaaeeeed5',int64), int(z'bc02ab639a9f0777',int64), int(z'3fefff000155549f',int64), int(z'3c828a28a03a5ef3',int64), &
   int(z'3f97ff7001033255',int64), int(z'3bfefe2b51527336',int64), int(z'3feffdc006bff7e6',int64), int(z'3c8ae6dae86977bd',int64), &
   int(z'3f9ffeaaaeeee86f',int64), int(z'bc3cd406fb224ae2',int64), int(z'3feffc00155527d3',int64), int(z'bc83b54492d89b5b',int64), &
   int(z'3fa3feb2b12d45d5',int64), int(z'3c34ec54203d1c11',int64), int(z'3feff9c03414a7ba',int64), int(z'3c6991f4be6c59bf',int64), &
   int(z'3fa7fdc01032fba9',int64), int(z'bc4599bdf46e997a',int64), int(z'3feff7006bfdf99f',int64), int(z'bc78b3b560648d5f',int64), &
   int(z'3fabfc6d78586dac',int64), int(z'3c18e4fd03dbf236',int64), int(z'3feff3c0c8103a31',int64), int(z'3c74856dbddc0e66',int64), &
   int(z'3faffaaaeeed4edb',int64), int(z'bc42d16d32684b69',int64), int(z'3feff0015549f4d3',int64), int(z'3c8328387b99426f',int64), &
   int(z'3fb1fc343d808bef',int64), int(z'bc5f3d32e6f3be4f',int64), int(z'3fefebc222a8ef9f',int64), int(z'3c57934934f54c77',int64), &
   int(z'3fb3facb12d1755b',int64), int(z'bc5921915299468c',int64), int(z'3fefe7034129ef6f',int64), int(z'bc6cbf4337c96f97',int64), &
   int(z'3fb5f911fd10b737',int64), int(z'bc50184f02be9102',int64), int(z'3fefe1c4c3c873eb',int64), int(z'bc35a9c9057c4a02',int64), &
   int(z'3fb7f701032550e4',int64), int(z'3c3afc2d1800501a',int64), int(z'3fefdc06bf7e6b9b',int64), int(z'3c831902b535f8db',int64), &
   int(z'3fb9f4902d55d1f9',int64), int(z'3c52696d7eac1dc1',int64), int(z'3fefd5c94b43e000',int64), int(z'bc62e768cb4f92f9',int64), &
   int(z'3fbbf1b78568391d',int64), int(z'3c5e91841dea4cc8',int64), int(z'3fefcf0c800e99b1',int64), int(z'3c6ea3d786d186ac',int64), &
   int(z'3fbdee6f16c1cce6',int64), int(z'bc450f8e2fb71673',int64), int(z'3fefc7d078d1bc88',int64), int(z'3c8075d2447db685',int64), &
   int(z'3fbfeaaeee86ee36',int64), int(z'bc4afcb2bcc6f03b',int64), int(z'3fefc015527d5bd3',int64), int(z'3c8b68f35094efb8',int64), &
   int(z'3fc0f3378ddd71d1',int64), int(z'3c6d8468724f0f9e',int64), int(z'3fefb7db2bfe0695',int64), int(z'3c821dadf4f65ab1',int64), &
   int(z'3fc1f0d3d7afceaf',int64), int(z'bc66ef95099769a5',int64), int(z'3fefaf22263c4bd3',int64), int(z'bc552ace133a2769',int64), &
   int(z'3fc2ee285e4ab88f',int64), int(z'bc6e4d0f05dee058',int64), int(z'3fefa5ea641c36f2',int64), int(z'3c404da6ed17cc7c',int64), &
   int(z'3fc3eb312c5d66cb',int64), int(z'3c647d666b66cb91',int64), int(z'3fef9c340a7cc428',int64), int(z'3c8c5b6b063b7462',int64), &
   int(z'3fc4e7ea4dc5f27b',int64), int(z'3c5949db2ac072fc',int64), int(z'3fef91ff40374d01',int64), int(z'bc67d03f4d3a9e4c',int64), &
   int(z'3fc5e44fcfa126f3',int64), int(z'bc66f443063f89b6',int64), int(z'3fef874c2e1eecf6',int64), int(z'bc8c6514e1332b16',int64), &
   int(z'3fc6e05dc05a4d4c',int64), int(z'bbd32c5c8b81c940',int64), int(z'3fef7c1afeffde24',int64), int(z'bc78f55bc47540b1',int64), &
   int(z'3fc7dc102fbaf2b5',int64), int(z'3c45ab50e23c97c3',int64), int(z'3fef706bdf9ece1c',int64), int(z'bc8698c80c36dcb4',int64), &
   int(z'3fc8d7632efaa944',int64), int(z'bc620fa262cbb953',int64), int(z'3fef643efeb82acd',int64), int(z'3c76b00ac1fe28ac',int64), &
   int(z'3fc9d252d0cec312',int64), int(z'3c59c43d80b1137d',int64), int(z'3fef57948cff6797',int64), int(z'3c6e3a0d3e03b1d5',int64), &
   int(z'3fcaccdb297a0765',int64), int(z'bc59883b57d6cdeb',int64), int(z'3fef4a6cbd1e3a79',int64), int(z'3c813df0edaebb57',int64), &
   int(z'3fcbc6f84edc6199',int64), int(z'3c69c1a56a7b0cab',int64), int(z'3fef3cc7c3b3d16e',int64), int(z'bc621a3ad28a3494',int64), &
   int(z'3fccc0a6588289a3',int64), int(z'bc6868d09bc87c6b',int64), int(z'3fef2ea5d753ffed',int64), int(z'3c8cc4215f56d583',int64), &
   int(z'3fcdb9e15fb5a5d0',int64), int(z'bc632e20d6cc6fc2',int64), int(z'3fef20073086649f',int64), int(z'3c7b940416c1984b',int64), &
   int(z'3fceb2a57f8ae5a3',int64), int(z'bc60be06af572ceb',int64), int(z'3fef10ec09c5873b',int64), int(z'3c8d9072762c1283',int64), &
   int(z'3fcfaaeed4f31577',int64), int(z'bc615d88508e32b8',int64), int(z'3fef01549f7deea1',int64), int(z'3c8d3c1e99e5cafd',int64), &
   int(z'3fd0515cbf65155c',int64), int(z'bc79b8c29dfd8ec8',int64), int(z'3feef141300d2f26',int64), int(z'bc82aa1b08ded372',int64), &
   int(z'3fd0cd00cef36436',int64), int(z'bc79fb0a0c93e2b5',int64), int(z'3feee0b1fbc0f11c',int64), int(z'bc4bfd2380bbc3b1',int64), &
   int(z'3fd14861aa94ddeb',int64), int(z'bc6be881b5b615a4',int64), int(z'3feecfa744d5efa1',int64), int(z'bc556d0a4af541d0',int64), &
   int(z'3fd1c37d64c6b876',int64), int(z'3c746076fe0dcff5',int64), int(z'3feebe214f76efa8',int64), int(z'bc802f9f12ba543e',int64), &
   int(z'3fd23e52111aaf36',int64), int(z'bc74f080334eff18',int64), int(z'3feeac2061bbaf4f',int64), int(z'3c62c1d53e94658d',int64), &
   int(z'3fd2b8ddc43eb49f',int64), int(z'3c61553899f2d807',int64), int(z'3fee99a4c3a7cd83',int64), int(z'bc82264b1bc53ce8',int64), &
   int(z'3fd3331e94049f87',int64), int(z'3c7e0cb6b40c302c',int64), int(z'3fee86aebf29a9ed',int64), int(z'3c89397afdbb58a7',int64), &
   int(z'3fd3ad129769d3d8',int64), int(z'3c003d5504878398',int64), int(z'3fee733ea0193d40',int64), int(z'bc86428b3546ce13',int64), &
   int(z'3fd426b7e69ee697',int64), int(z'bc7f09c75705c59f',int64), int(z'3fee5f54b436e9d0',int64), int(z'3c87eb0fd02fc8bc',int64), &
   int(z'3fd4a00c9b0f3d20',int64), int(z'3c7823ba6bb08ead',int64), int(z'3fee4af14b2a449c',int64), int(z'bc868ca02e8a6833',int64), &
   int(z'3fd5190ecf68a77a',int64), int(z'3c7b357155eef0f3',int64), int(z'3fee3614b680d6a5',int64), int(z'bc727793aa015237',int64), &
   int(z'3fd591bc9fa2f597',int64), int(z'3c67c74bac3fe0cb',int64), int(z'3fee20bf49acd6c1',int64), int(z'bc5660aec7ef636c',int64), &
   int(z'3fd60a1429078775',int64), int(z'3c5b1fd80ba89133',int64), int(z'3fee0af15a03dbce',int64), int(z'3c5fe8e702771ae6',int64), &
   int(z'3fd682138a38d7f7',int64), int(z'bc7d889202444aad',int64), int(z'3fedf4ab3ebd875e',int64), int(z'bc8e2d8a7e6736c4',int64), &
   int(z'3fd6f9b8e33a0255',int64), int(z'3c742bc14ee9da0d',int64), int(z'3feddded50f228d6',int64), int(z'bc6e80c8d42ba2bf',int64), &
   int(z'3fd7710255764214',int64), int(z'bc66ead7314bb6ce',int64), int(z'3fedc6b7eb995912',int64), int(z'3c54b364776dcd35',int64), &
   int(z'3fd7e7ee03c86d4e',int64), int(z'bc7b63bcdabf5af2',int64), int(z'3fedaf0b6b888e83',int64), int(z'3c8a249e2b5e5cea',int64), &
   int(z'3fd85e7a12826949',int64), int(z'3c78a40e9b5face0',int64), int(z'3fed96e82f71a9dc',int64), int(z'3c8ff61bd5d2039d',int64), &
   int(z'3fd8d4a4a774992f',int64), int(z'3c744a02ea766326',int64), int(z'3fed7e4e97e17b4a',int64), int(z'bc63b770352bed94',int64), &
   int(z'3fd94a6be9f546c5',int64), int(z'bc769ce13e683f58',int64), int(z'3fed653f073e4040',int64), int(z'bc876236434bec37',int64), &
   int(z'3fd9bfce02e80510',int64), int(z'3c709e39a320b0a4',int64), int(z'3fed4bb9e1c619e0',int64), int(z'3c8f34bb77858f61',int64), &
   int(z'3fda34c91cc50cca',int64), int(z'bc5a310e3b50cecd',int64), int(z'3fed31bf8d8d7c06',int64), int(z'3c7e60dd3089cbdd',int64), &
   int(z'3fdaa95b63a09277',int64), int(z'bc66293eb13c0381',int64), int(z'3fed1750727d94f0',int64), int(z'3c80d52b1ec1a48e',int64), &
   int(z'3fdb1d8305321617',int64), int(z'bc7ae242cb99f519',int64), int(z'3fecfc6cfa52ad9f',int64), int(z'3c88b5b5508f2a0d',int64), &
   int(z'3fdb913e30dbac43',int64), int(z'bc7e38ad2f6c3ff1',int64), int(z'3fece115909a82e5',int64), int(z'3c81f139bb31109a',int64), &
   int(z'3fdc048b17b140a3',int64), int(z'3c619fe6757e9fa7',int64), int(z'3fecc54aa2b2972e',int64), int(z'3c64ee162ba83a98',int64), &
   int(z'3fdc7767ec7fd19e',int64), int(z'bc5eb14d1a3d5826',int64), int(z'3feca90c9fc67d0b',int64), int(z'bc646a81485e3462',int64), &
   int(z'3fdce9d2e3d4a51f',int64), int(z'bc62fc8a12dae298',int64), int(z'3fec8c5bf8ce1a84',int64), int(z'3c7ab3d1a1590123',int64), &
   int(z'3fdd5bca34047661',int64), int(z'3c728a44a75fc29c',int64), int(z'3fec6f39208be53b',int64), int(z'bc8741dbfbaadb42',int64), &
   int(z'3fddcd4c15329c9a',int64), int(z'3c70d4c6e171fd9a',int64), int(z'3fec51a48b8b175e',int64), int(z'bc61bbb43b9aa880',int64), &
   int(z'3fde3e56c1582a69',int64), int(z'bc50a4821099f88f',int64), int(z'3fec339eb01ddd81',int64), int(z'bc8caaf5ee82c5c0',int64), &
   int(z'3fdeaee8744b05f0',int64), int(z'bc5789b43c9b027d',int64), int(z'3fec1528065b7d50',int64), int(z'bc8892111312e828',int64), &
   int(z'3fdf1eff6bc4f97b',int64), int(z'3c717212f8a7525c',int64), int(z'3febf641081e7536',int64), int(z'3c8b7bd71628a9a1',int64), &
   int(z'3fdf8e99e76abc97',int64), int(z'3c59d950af2d00a3',int64), int(z'3febd6ea310294f5',int64), int(z'3c731bbcc88c109d',int64), &
   int(z'3fdffdb628d2f57a',int64), int(z'3c6f4a992e905b6a',int64), int(z'3febb723fe630f32',int64), int(z'3c772bd2452d0a39',int64), &
   int(z'3fe0362939c69955',int64), int(z'bc82d8cd78397b01',int64), int(z'3feb96eeef58840e',int64), int(z'3c545a3cc78fade0',int64), &
   int(z'3fe06d3686946e5b',int64), int(z'3c83f5ae4538ff1b',int64), int(z'3feb764b84b704c2',int64), int(z'bc8f5848c21b389b',int64), &
   int(z'3fe0a4021e9e1001',int64), int(z'bc86f643a13914f6',int64), int(z'3feb553a410c104e',int64), int(z'3c58ff7947027a16',int64), &
   int(z'3fe0da8b26b5672e',int64), int(z'bc8a58def0bee909',int64), int(z'3feb33bba89c8948',int64), int(z'3c8ea6a51d1f6ca9',int64), &
   int(z'3fe110d0c4b69c3b',int64), int(z'3c8d918998809981',int64), int(z'3feb11d04162a4c6',int64), int(z'3c71dd561efbc0c2',int64), &
   int(z'3fe146d21f8b7f82',int64), int(z'3c7bf9535e2739a8',int64), int(z'3feaef78930bd275',int64), int(z'bc7f836279746f94',int64), &
   int(z'3fe17c8e5f2eedb0',int64), int(z'3c635e57102e2488',int64), int(z'3feaccb526f69de5',int64), int(z'3c88fb6a8dd6b6cc',int64), &
   int(z'3fe1b204acb02fdd',int64), int(z'bc5f190c70cbb5ff',int64), int(z'3feaa98688308913',int64), int(z'bc0b83d607cd5070',int64), &
   int(z'3fe1e7343236574c',int64), int(z'3c722a3fa4f41d5a',int64), int(z'3fea85ed4373e02d',int64), int(z'3c69be06385ec792',int64), &
   int(z'3fe21c1c1b0394cf',int64), int(z'3c5e5b324b23aa31',int64), int(z'3fea61e9e72586af',int64), int(z'3c858330e2fd453f',int64), &
   int(z'3fe250bb93788bbb',int64), int(z'3c7ea3d02457bcce',int64), int(z'3fea3d7d0352bdcf',int64), int(z'bc868dbaeca19669',int64), &
   int(z'3fe28511c917a067',int64), int(z'bc801df1d9a16b70',int64), int(z'3fea18a729aee445',int64), int(z'3c395e25736c0358',int64), &
   int(z'3fe2b91dea88421e',int64), int(z'bc8fa371db216ab0',int64), int(z'3fe9f368ed912f85',int64), int(z'bc81d200c5791606',int64), &
   int(z'3fe2ecdf279a3082',int64), int(z'3c8d3557e0e7e37e',int64), int(z'3fe9cdc2e3f25e5c',int64), int(z'3c83f99112993f62',int64), &
   int(z'3fe32054b148bc4f',int64), int(z'3c8f6b42095a135b',int64), int(z'3fe9a7b5a36a6514',int64), int(z'3c8722cfcc9fa7a9',int64), &
   int(z'3fe3537db9be0367',int64), int(z'3c6b327e7af040f0',int64), int(z'3fe98141c42e1310',int64), int(z'3c8d1ff80488f08d',int64), &
   int(z'3fe386597456282b',int64), int(z'bc710fada93b07a8',int64), int(z'3fe95a67e00cb1fd',int64), int(z'bc80befda21f862d',int64), &
   int(z'3fe3b8e715a2840a',int64), int(z'bc797653a7d2f07b',int64), int(z'3fe93328926d9e92',int64), int(z'bc8bb77003600cda',int64), &
   int(z'3fe3eb25d36cd53a',int64), int(z'bc5be570e1570fc0',int64), int(z'3fe90b84784ddaf7',int64), int(z'bc70feb10ab93b87',int64), &
   int(z'3fe41d14e4ba6790',int64), int(z'3c84608fd287ecf5',int64), int(z'3fe8e37c303d9ad1',int64), int(z'bc6463a4b53d4bf8',int64), &
   int(z'3fe44eb381cf386b',int64), int(z'bc83ed6c1e6a5505',int64), int(z'3fe8bb105a5dc900',int64), int(z'3c8863e03e9474c1',int64), &
   int(z'3fe48000e431159f',int64), int(z'bc8b194a7463ed10',int64), int(z'3fe89241985d871f',int64), int(z'3c8c48d9c413ed84',int64), &
   int(z'3fe4b0fc46aab761',int64), int(z'3c20da05738cc59a',int64), int(z'3fe869108d77a6c6',int64), int(z'3c7338ffe2bfe9dd',int64), &
   int(z'3fe4e1a4e54ed51b',int64), int(z'bc8a492f89b7c76a',int64), int(z'3fe83f7dde701ca0',int64), int(z'bc4152cf609bc6e8',int64), &
   int(z'3fe511f9fd7b351c',int64), int(z'bc85c0e861c48831',int64), int(z'3fe8158a31916d5d',int64), int(z'bc6de8b90b8228de',int64), &
   int(z'3fe541facddbb724',int64), int(z'3c7232c28520d391',int64), int(z'3fe7eb362eaa1488',int64), int(z'3c5a1d65a4a5959f',int64), &
   int(z'3fe571a6966d59b3',int64), int(z'3c5c843b4d0fb198',int64), int(z'3fe7c0827f09e54f',int64), int(z'bc6c73d6d72aee68',int64), &
   int(z'3fe5a0fc98813a12',int64), int(z'bc8d82e2b7d4227b',int64), int(z'3fe7956fcd7f6543',int64), int(z'bc8ab276e9d45ae4',int64), &
   int(z'3fe5cffc16bf8f0d',int64), int(z'3c896cb370eb578a',int64), int(z'3fe769fec655211f',int64), int(z'bc6827d5cf8c68c5',int64), &
   int(z'3fe5fea4552a9e57',int64), int(z'3c80b6cef7ee20b7',int64), int(z'3fe73e30174efba1',int64), int(z'bc65d3ae3d94ad5f',int64), &
   int(z'3fe62cf49921ac79',int64), int(z'bc8edd9855b6241a',int64), int(z'3fe712046fa77678',int64), int(z'3c8425b0a5029c81',int64), &
   int(z'3fe65aec2963e755',int64), int(z'3c8126f96b71053c',int64), int(z'3fe6e57c800cf55e',int64), int(z'3c860286dedbd0a6',int64), &
   int(z'3fe6888a4e134b2f',int64), int(z'bc86b7d37644d5e6',int64), int(z'3fe6b898fa9efb5d',int64), int(z'3c715ac786ccf4b2',int64), &
   int(z'3fe6b5ce50b7821a',int64), int(z'bc65d5158f702e0f',int64), int(z'3fe68b5a92eb6253',int64), int(z'bc89a91ad985f89c',int64), &
   int(z'3fe6e2b77c40bde1',int64), int(z'bc70e729857fad53',int64), int(z'3fe65dc1fdeb8cba',int64), int(z'bc597c1b47337c77',int64), &
   int(z'3fe70f451d0a8c40',int64), int(z'3c697ede3885770d',int64), int(z'3fe62fcff20191c7',int64), int(z'3c6d9143895756ef',int64), &
   int(z'3fe73b7680dea578',int64), int(z'bc72248306dc12a2',int64), int(z'3fe6018526f563df',int64), int(z'3c846ca5e0e432d0',int64), &
   int(z'3fe7674af6f7b524',int64), int(z'3c7e9d3f94ac84a8',int64), int(z'3fe5d2e255f1f17a',int64), int(z'3c80314104c8892b',int64), &
   int(z'3fe792c1d0041d52',int64), int(z'bc8abf05eeb354eb',int64), int(z'3fe5a3e839824077',int64), int(z'3c8428aa2759be62',int64), &
   int(z'3fe7bdda5e28b3c2',int64), int(z'3c4ad1197ccd0393',int64), int(z'3fe574978d8e83f2',int64), int(z'3c8f4714af282d23',int64), &
   int(z'3fe7e893f5037959',int64), int(z'3c80eefbaa650c4c',int64), int(z'3fe544f10f592ca5',int64), int(z'bc8e7ae8e6c7a62f',int64), &
 int(z'3fe812ede9ae4ba4', int64), int(z'bc87830adf402dda', int64), int(z'3fe514f57d7bf3da', int64), int(z'3c747a108073c259', int64)]
  real(real64), parameter :: table(4, 0:109) = reshape(transfer(table_words, 0.0_real64, 440), [4, 110])

contains
!> Return the sine of a finite angle in radians. The input remains unchanged.
  real(real64) function original_rounding_sine(angle) result(answer)
    real(real64), intent(in) :: angle
    answer = source_projection(angle, .false.)
  end function
!> Return the cosine of a finite angle in radians. The input remains unchanged.
  real(real64) function original_rounding_cosine(angle) result(answer)
    real(real64), intent(in) :: angle
    answer = source_projection(angle, .true.)
  end function
  real(real64) function signed_value(value, sign_source) result(answer)
    real(real64), intent(in) :: value, sign_source
    integer(int64) :: v, q
    v = transfer(value, v); q = transfer(sign_source, q)
    v = ior(iand(v, int(z'7fffffffffffffff', int64)), iand(q, int(z'8000000000000000', int64)))
    answer = transfer(v, answer)
  end function
  recursive real(real64) function source_projection(angle, cosine) result(answer)
    real(real64), intent(in) :: angle
    logical, intent(in) :: cosine
    real(real64), volatile :: x, dx, a, b, c, d, rounded, xn, unused
    integer(int64) :: bits, absolute_bits
    integer(int32) :: high_word, quadrant, offset
    logical :: use_cosine
    bits = transfer(angle, bits); absolute_bits = iand(bits, int(z'7fffffffffffffff', int64))
    if (absolute_bits > int(z'4130000000000000', int64)) call public_abort()
    high_word = int(shiftr(absolute_bits, 32), int32)
    quadrant = 0
    if (cosine) then
      if (high_word < int(z'3e400000', int32)) then
        answer = 1.0_real64; return
      end if
    else
      if (high_word < int(z'3e500000', int32)) then
        if (absolute_bits < int(z'0010000000000000', int64)) unused = angle*angle
        answer = angle; return
      end if
    end if
    if (high_word < int(z'3feb6000', int32)) then
      x = angle; dx = 0.0_real64; use_cosine = cosine
    elseif (high_word < int(z'400368fd', int32)) then
      if (cosine) then
        a = hp0 - abs(angle); b = a + hp1; a = a - b; a = a + hp1
        x = b; dx = a; use_cosine = .false.
      else
        x = hp0 - abs(angle); dx = hp1; quadrant = 4; use_cosine = .true.
      end if
    else
      rounded = rounded_product_sum(angle, hpinv, toint)
      bits = transfer(rounded, bits); offset = 0; if (cosine) offset = 1
      quadrant = iand(int(iand(bits, 3_int64), int32) + offset, 3_int32)
      xn = rounded - toint
      a = rounded_product_sum(-xn, mp1, angle)
      a = rounded_product_sum(-xn, mp2, a)
      b = rounded_product_sum(-xn, pp3, a)
      c = a - b; c = rounded_product_sum(-xn, pp3, c)
      x = rounded_product_sum(-xn, pp4, b)
      d = b - x; d = rounded_product_sum(-xn, pp4, d)
      dx = c + d; use_cosine = btest(quadrant, 0)
    end if
    if (use_cosine) then
      answer = cosine_kernel(x, dx)
    else
      answer = sine_kernel(x, dx)
    end if
    if (btest(quadrant, 2)) answer = signed_value(answer, angle)
    if (btest(quadrant, 1)) answer = -answer
  end function
  recursive real(real64) function sine_kernel(input_x, input_dx) result(answer)
    real(real64), intent(in) :: input_x, input_dx
    real(real64), volatile :: x, dx, z, cube, poly, s, c, rounded, remainder, a
    integer(int64) :: bits
    integer :: index
    x = input_x; dx = input_dx
    if (abs(x) < taylor_cutoff) then
      z = x*x
      poly = rounded_product_sum(z, s5, s4)
      poly = rounded_product_sum(z, poly, s3)
      poly = rounded_product_sum(z, poly, s2)
      poly = rounded_product_sum(z, poly, s1)
      a = dx*0.5_real64
      a = rounded_product_sum(poly, x, -a)
      a = rounded_product_sum(z, a, dx)
      answer = x + a; return
    end if
    if (x <= 0.0_real64) dx = -dx
    x = abs(x); rounded = x + big; bits = transfer(rounded, bits)
    index = int(iand(bits, int(z'ffffffff', int64)))
    rounded = rounded - big; x = x - rounded; z = x*x; cube = x*z
    poly = rounded_product_sum(z, sn5, sn3)
    s = rounded_product_sum(cube, poly, dx); s = x + s
    poly = rounded_product_sum(z, cs6, cs4)
    poly = rounded_product_sum(z, poly, cs2)
    c = z*poly; c = rounded_product_sum(x, dx, c)
    remainder = rounded_product_sum(s, table(4, index), table(2, index))
    remainder = rounded_product_sum(-c, table(1, index), remainder)
    remainder = rounded_product_sum(table(3, index), s, remainder)
    a = table(1, index) + remainder
    answer = signed_value(a, input_x)
  end function
  recursive real(real64) function cosine_kernel(input_x, input_dx) result(answer)
    real(real64), intent(in) :: input_x, input_dx
    real(real64), volatile :: x, dx, z, cube, poly, s, c, rounded, remainder
    integer(int64) :: bits
    integer :: index
    x = input_x; dx = input_dx
    if (x < 0.0_real64) dx = -dx
    x = abs(x); rounded = x + big; bits = transfer(rounded, bits)
    index = int(iand(bits, int(z'ffffffff', int64)))
    rounded = rounded - big; x = x - rounded; x = x + dx; z = x*x; cube = x*z
    poly = rounded_product_sum(z, sn5, sn3)
    s = rounded_product_sum(cube, poly, x)
    poly = rounded_product_sum(z, cs6, cs4)
    poly = rounded_product_sum(z, poly, cs2); c = z*poly
    remainder = rounded_product_sum(-s, table(2, index), table(4, index))
    remainder = rounded_product_sum(-c, table(3, index), remainder)
    remainder = rounded_product_sum(-s, table(1, index), remainder)
    answer = table(3, index) + remainder
  end function
end module
