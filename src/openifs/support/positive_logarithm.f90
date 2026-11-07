!> Ordered FP64 natural logarithm for positive normal inputs.
!! The equations and constants are ported from our generated logarithm leaf.
!! The Arm constants retain their MIT or Apache-2.0 WITH LLVM-exception licence.
!! Copyright (c) 2018-2025, Arm Limited.
!! SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
module forecast_positive_logarithm
  use, intrinsic :: iso_fortran_env, only: real64, int64
  use, intrinsic :: iso_c_binding, only: c_int64_t
  implicit none
  private
  public :: positive_logarithm, logarithm_calls
  integer(c_int64_t), bind(C,name="md2asm_log_positive_normal_calls") :: logarithm_calls=0
  integer(int64), parameter :: source_bits(0:529) = [ &
    int(z'3fe62e42fefa3800',int64), int(z'3d2ef35793c76730',int64), int(z'bfe0000000000001',int64), int(z'3fd555555551305b',int64), &
    int(z'bfcfffffffeb4590',int64), int(z'3fc999b324f10111',int64), int(z'bfc55575e506c89f',int64), int(z'bfe0000000000000',int64), &
    int(z'3fd5555555555577',int64), int(z'bfcffffffffffdcb',int64), int(z'3fc999999995dd0c',int64), int(z'bfc55555556745a7',int64), &
    int(z'3fc24924a344de30',int64), int(z'bfbfffffa4423d65',int64), int(z'3fbc7184282ad6ca',int64), int(z'bfb999eb43b068ff',int64), &
    int(z'3fb78182f7afd085',int64), int(z'bfb5521375d145cd',int64), int(z'3ff734f0c3e0de9f',int64), int(z'bfd7cc7f79e69000',int64), &
    int(z'3ff713786a2ce91f',int64), int(z'bfd76feec20d0000',int64), int(z'3ff6f26008fab5a0',int64), int(z'bfd713e31351e000',int64), &
    int(z'3ff6d1a61f138c7d',int64), int(z'bfd6b85b38287800',int64), int(z'3ff6b1490bc5b4d1',int64), int(z'bfd65d5590807800',int64), &
    int(z'3ff69147332f0cba',int64), int(z'bfd602d076180000',int64), int(z'3ff6719f18224223',int64), int(z'bfd5a8ca86909000',int64), &
    int(z'3ff6524f99a51ed9',int64), int(z'bfd54f4356035000',int64), int(z'3ff63356aa8f24c4',int64), int(z'bfd4f637c36b4000',int64), &
    int(z'3ff614b36b9ddc14',int64), int(z'bfd49da7fda85000',int64), int(z'3ff5f66452c65c4c',int64), int(z'bfd445923989a800',int64), &
    int(z'3ff5d867b5912c4f',int64), int(z'bfd3edf439b0b800',int64), int(z'3ff5babccb5b90de',int64), int(z'bfd396ce448f7000',int64), &
    int(z'3ff59d61f2d91a78',int64), int(z'bfd3401e17bda000',int64), int(z'3ff5805612465687',int64), int(z'bfd2e9e2ef468000',int64), &
    int(z'3ff56397cee76bd3',int64), int(z'bfd2941b3830e000',int64), int(z'3ff54725e2a77f93',int64), int(z'bfd23ec58cda8800',int64), &
    int(z'3ff52aff42064583',int64), int(z'bfd1e9e129279000',int64), int(z'3ff50f22dbb2bddf',int64), int(z'bfd1956d2b48f800',int64), &
    int(z'3ff4f38f4734ded7',int64), int(z'bfd141679ab9f800',int64), int(z'3ff4d843cfde2840',int64), int(z'bfd0edd094ef9800',int64), &
    int(z'3ff4bd3ec078a3c8',int64), int(z'bfd09aa518db1000',int64), int(z'3ff4a27fc3e0258a',int64), int(z'bfd047e65263b800',int64), &
    int(z'3ff4880524d48434',int64), int(z'bfcfeb224586f000',int64), int(z'3ff46dce1b192d0b',int64), int(z'bfcf474a7517b000',int64), &
    int(z'3ff453d9d3391854',int64), int(z'bfcea4443d103000',int64), int(z'3ff43a2744b4845a',int64), int(z'bfce020d44e9b000',int64), &
    int(z'3ff420b54115f8fb',int64), int(z'bfcd60a22977f000',int64), int(z'3ff40782da3ef4b1',int64), int(z'bfccc00104959000',int64), &
    int(z'3ff3ee8f5d57fe8f',int64), int(z'bfcc202956891000',int64), int(z'3ff3d5d9a00b4ce9',int64), int(z'bfcb81178d811000',int64), &
    int(z'3ff3bd60c010c12b',int64), int(z'bfcae2c9ccd3d000',int64), int(z'3ff3a5242b75dab8',int64), int(z'bfca45402e129000',int64), &
    int(z'3ff38d22cd9fd002',int64), int(z'bfc9a877681df000',int64), int(z'3ff3755bc5847a1c',int64), int(z'bfc90c6d69483000',int64), &
    int(z'3ff35dce49ad36e2',int64), int(z'bfc87120a645c000',int64), int(z'3ff34679984dd440',int64), int(z'bfc7d68fb4143000',int64), &
    int(z'3ff32f5cceffcb24',int64), int(z'bfc73cb83c627000',int64), int(z'3ff3187775a10d49',int64), int(z'bfc6a39a9b376000',int64), &
    int(z'3ff301c8373e3990',int64), int(z'bfc60b3154b7a000',int64), int(z'3ff2eb4ebb95f841',int64), int(z'bfc5737d76243000',int64), &
    int(z'3ff2d50a0219a9d1',int64), int(z'bfc4dc7b8fc23000',int64), int(z'3ff2bef9a8b7fd2a',int64), int(z'bfc4462c51d20000',int64), &
    int(z'3ff2a91c7a0c1bab',int64), int(z'bfc3b08abc830000',int64), int(z'3ff293726014b530',int64), int(z'bfc31b996b490000',int64), &
    int(z'3ff27dfa5757a1f5',int64), int(z'bfc2875490a44000',int64), int(z'3ff268b39b1d3bbf',int64), int(z'bfc1f3b9f879a000',int64), &
    int(z'3ff2539d838ff5bd',int64), int(z'bfc160c8252ca000',int64), int(z'3ff23eb7aac9083b',int64), int(z'bfc0ce7f57f72000',int64), &
    int(z'3ff22a012ba940b6',int64), int(z'bfc03cdc49fea000',int64), int(z'3ff2157996cc4132',int64), int(z'bfbf57bdbc4b8000',int64), &
    int(z'3ff201201dd2fc9b',int64), int(z'bfbe370896404000',int64), int(z'3ff1ecf4494d480b',int64), int(z'bfbd17983ef94000',int64), &
    int(z'3ff1d8f5528f6569',int64), int(z'bfbbf9674ed8a000',int64), int(z'3ff1c52311577e7c',int64), int(z'bfbadc79202f6000',int64), &
    int(z'3ff1b17c74cb26e9',int64), int(z'bfb9c0c3e7288000',int64), int(z'3ff19e010c2c1ab6',int64), int(z'bfb8a646b372c000',int64), &
    int(z'3ff18ab07bb670bd',int64), int(z'bfb78d01b3ac0000',int64), int(z'3ff1778a25efbcb6',int64), int(z'bfb674f145380000',int64), &
    int(z'3ff1648d354c31da',int64), int(z'bfb55e0e6d878000',int64), int(z'3ff151b990275fdd',int64), int(z'bfb4485cdea1e000',int64), &
    int(z'3ff13f0ea432d24c',int64), int(z'bfb333d94d6aa000',int64), int(z'3ff12c8b7210f9da',int64), int(z'bfb22079f8c56000',int64), &
    int(z'3ff11a3028ecb531',int64), int(z'bfb10e4698622000',int64), int(z'3ff107fbda8434af',int64), int(z'bfaffa6c6ad20000',int64), &
    int(z'3ff0f5ee0f4e6bb3',int64), int(z'bfadda8d4a774000',int64), int(z'3ff0e4065d2a9fce',int64), int(z'bfabbcece4850000',int64), &
    int(z'3ff0d244632ca521',int64), int(z'bfa9a1894012c000',int64), int(z'3ff0c0a77ce2981a',int64), int(z'bfa788583302c000',int64), &
    int(z'3ff0af2f83c636d1',int64), int(z'bfa5715e67d68000',int64), int(z'3ff09ddb98a01339',int64), int(z'bfa35c8a49658000',int64), &
    int(z'3ff08cabaf52e7df',int64), int(z'bfa149e364154000',int64), int(z'3ff07b9f2f4e28fb',int64), int(z'bf9e72c082eb8000',int64), &
    int(z'3ff06ab58c358f19',int64), int(z'bf9a55f152528000',int64), int(z'3ff059eea5ecf92c',int64), int(z'bf963d62cf818000',int64), &
    int(z'3ff04949cdd12c90',int64), int(z'bf9228fb8caa0000',int64), int(z'3ff038c6c6f0ada9',int64), int(z'bf8c317b20f90000',int64), &
    int(z'3ff02865137932a9',int64), int(z'bf8419355daa0000',int64), int(z'3ff0182427ea7348',int64), int(z'bf781203c2ec0000',int64), &
    int(z'3ff008040614b195',int64), int(z'bf60040979240000',int64), int(z'3fefe01ff726fa1a',int64), int(z'3f6feff384900000',int64), &
    int(z'3fefa11cc261ea74',int64), int(z'3f87dc41353d0000',int64), int(z'3fef6310b081992e',int64), int(z'3f93cea3c4c28000',int64), &
    int(z'3fef25f63ceeadcd',int64), int(z'3f9b9fc114890000',int64), int(z'3feee9c8039113e7',int64), int(z'3fa1b0d8ce110000',int64), &
    int(z'3feeae8078cbb1ab',int64), int(z'3fa58a5bd001c000',int64), int(z'3fee741aa29d0c9b',int64), int(z'3fa95c8340d88000',int64), &
    int(z'3fee3a91830a99b5',int64), int(z'3fad276aef578000',int64), int(z'3fee01e009609a56',int64), int(z'3fb07598e598c000',int64), &
    int(z'3fedca01e577bb98',int64), int(z'3fb253f5e30d2000',int64), int(z'3fed92f20b7c9103',int64), int(z'3fb42edd8b380000',int64), &
    int(z'3fed5cac66fb5cce',int64), int(z'3fb606598757c000',int64), int(z'3fed272caa5ede9d',int64), int(z'3fb7da76356a0000',int64), &
    int(z'3fecf26e3e6b2ccd',int64), int(z'3fb9ab434e1c6000',int64), int(z'3fecbe6da2a77902',int64), int(z'3fbb78c7bb0d6000',int64), &
    int(z'3fec8b266d37086d',int64), int(z'3fbd431332e72000',int64), int(z'3fec5894bd5d5804',int64), int(z'3fbf0a3171de6000',int64), &
    int(z'3fec26b533bb9f8c',int64), int(z'3fc067152b914000',int64), int(z'3febf583eeece73f',int64), int(z'3fc147858292b000',int64), &
    int(z'3febc4fd75db96c1',int64), int(z'3fc2266ecdca3000',int64), int(z'3feb951e0c864a28',int64), int(z'3fc303d7a6c55000',int64), &
    int(z'3feb65e2c5ef3e2c',int64), int(z'3fc3dfc33c331000',int64), int(z'3feb374867c9888b',int64), int(z'3fc4ba366b7a8000',int64), &
    int(z'3feb094b211d304a',int64), int(z'3fc5933928d1f000',int64), int(z'3feadbe885f2ef7e',int64), int(z'3fc66acd2418f000',int64), &
    int(z'3feaaf1d31603da2',int64), int(z'3fc740f8ec669000',int64), int(z'3fea82e63fd358a7',int64), int(z'3fc815c0f51af000',int64), &
    int(z'3fea5740ef09738b',int64), int(z'3fc8e92954f68000',int64), int(z'3fea2c2a90ab4b27',int64), int(z'3fc9bb3602f84000',int64), &
    int(z'3fea01a01393f2d1',int64), int(z'3fca8bed1c2c0000',int64), int(z'3fe9d79f24db3c1b',int64), int(z'3fcb5b515c01d000',int64), &
    int(z'3fe9ae2505c7b190',int64), int(z'3fcc2967ccbcc000',int64), int(z'3fe9852ef297ce2f',int64), int(z'3fccf635d5486000',int64), &
    int(z'3fe95cbaeea44b75',int64), int(z'3fcdc1bd3446c000',int64), int(z'3fe934c69de74838',int64), int(z'3fce8c01b8cfe000',int64), &
    int(z'3fe90d4f2f6752e6',int64), int(z'3fcf5509c0179000',int64), int(z'3fe8e6528effd79d',int64), int(z'3fd00e6c121fb800',int64), &
    int(z'3fe8bfce9fcc007c',int64), int(z'3fd071b80e93d000',int64), int(z'3fe899c0dabec30e',int64), int(z'3fd0d46b9e867000',int64), &
    int(z'3fe87427aa2317fb',int64), int(z'3fd13687334bd000',int64), int(z'3fe84f00acb39a08',int64), int(z'3fd1980d67234800',int64), &
    int(z'3fe82a49e8653e55',int64), int(z'3fd1f8ffe0cc8000',int64), int(z'3fe8060195f40260',int64), int(z'3fd2595fd7636800',int64), &
    int(z'3fe7e22563e0a329',int64), int(z'3fd2b9300914a800',int64), int(z'3fe7beb377dcb5ad',int64), int(z'3fd3187210436000',int64), &
    int(z'3fe79baa679725c2',int64), int(z'3fd377266dec1800',int64), int(z'3fe77907f2170657',int64), int(z'3fd3d54ffbaf3000',int64), &
    int(z'3fe756cadbd6130c',int64), int(z'3fd432eee32fe000',int64), int(z'3fe61000014fb66b',int64), int(z'3c7e026c91425b3c',int64), &
    int(z'3fe63000034db495',int64), int(z'3c8dbfea48005d41',int64), int(z'3fe650000d94d478',int64), int(z'3c8e7fa786d6a5b7',int64), &
    int(z'3fe67000074e6fad',int64), int(z'3c61fcea6b54254c',int64), int(z'3fe68ffffedf0fae',int64), int(z'bc7c7e274c590efd',int64), &
    int(z'3fe6b0000763c5bc',int64), int(z'bc8ac16848dcda01',int64), int(z'3fe6d0001e5cc1f6',int64), int(z'3c833f1c9d499311',int64), &
    int(z'3fe6efffeb05f63e',int64), int(z'bc7e80041ae22d53',int64), int(z'3fe710000e869780',int64), int(z'3c7bff6671097952',int64), &
    int(z'3fe72ffffc67e912',int64), int(z'3c8c00e226bd8724',int64), int(z'3fe74fffdf81116a',int64), int(z'bc6e02916ef101d2',int64), &
    int(z'3fe770000f679c90',int64), int(z'bc67fc71cd549c74',int64), int(z'3fe78ffffa7ec835',int64), int(z'3c81bec19ef50483',int64), &
    int(z'3fe7affffe20c2e6',int64), int(z'bc707e1729cc6465',int64), int(z'3fe7cfffed3fc900',int64), int(z'bc808072087b8b1c',int64), &
    int(z'3fe7efffe9261a76',int64), int(z'3c8dc0286d9df9ae',int64), int(z'3fe81000049ca3e8',int64), int(z'3c897fd251e54c33',int64), &
    int(z'3fe8300017932c8f',int64), int(z'bc8afee9b630f381',int64), int(z'3fe850000633739c',int64), int(z'3c89bfbf6b6535bc',int64), &
    int(z'3fe87000204289c6',int64), int(z'bc8bbf65f3117b75',int64), int(z'3fe88fffebf57904',int64), int(z'bc89006ea23dcb57',int64), &
    int(z'3fe8b00022bc04df',int64), int(z'bc7d00df38e04b0a',int64), int(z'3fe8cfffe50c1b8a',int64), int(z'bc88007146ff9f05',int64), &
    int(z'3fe8effffc918e43',int64), int(z'3c83817bd07a7038',int64), int(z'3fe910001efa5fc7',int64), int(z'3c893e9176dfb403',int64), &
    int(z'3fe9300013467bb9',int64), int(z'3c7f804e4b980276',int64), int(z'3fe94fffe6ee076f',int64), int(z'bc8f7ef0d9ff622e',int64), &
    int(z'3fe96fffde3c12d1',int64), int(z'bc7082aa962638ba',int64), int(z'3fe98ffff4458a0d',int64), int(z'bc87801b9164a8ef',int64), &
    int(z'3fe9afffdd982e3e',int64), int(z'bc8740e08a5a9337',int64), int(z'3fe9cfffed49fb66',int64), int(z'3c3fce08c19be000',int64), &
    int(z'3fe9f00020f19c51',int64), int(z'bc8a3faa27885b0a',int64), int(z'3fea10001145b006',int64), int(z'3c74ff489958da56',int64), &
    int(z'3fea300007bbf6fa',int64), int(z'3c8cbeab8a2b6d18',int64), int(z'3fea500010971d79',int64), int(z'3c88fecadd787930',int64), &
    int(z'3fea70001df52e48',int64), int(z'bc8f41763dd8abdb',int64), int(z'3fea90001c593352',int64), int(z'bc8ebf0284c27612',int64), &
    int(z'3feab0002a4f3e4b',int64), int(z'bc69fd043cff3f5f',int64), int(z'3feacfffd7ae1ed1',int64), int(z'bc823ee7129070b4',int64), &
    int(z'3feaefffee510478',int64), int(z'3c6a063ee00edea3',int64), int(z'3feb0fffdb650d5b',int64), int(z'3c5a06c8381f0ab9',int64), &
    int(z'3feb2ffffeaaca57',int64), int(z'bc79011e74233c1d',int64), int(z'3feb4fffd995badc',int64), int(z'bc79ff1068862a9f',int64), &
    int(z'3feb7000249e659c',int64), int(z'3c8aff45d0864f3e',int64), int(z'3feb8ffff9871640',int64), int(z'3c7cfe7796c2c3f9',int64), &
    int(z'3febafffd204cb4f',int64), int(z'bc63ff27eef22bc4',int64), int(z'3febcfffd2415c45',int64), int(z'bc6cffb7ee3bea21',int64), &
    int(z'3febeffff86309df',int64), int(z'bc814103972e0b5c',int64), int(z'3fec0fffe1b57653',int64), int(z'3c8bc16494b76a19',int64), &
    int(z'3fec2ffff1fa57e3',int64), int(z'bc64feef8d30c6ed',int64), int(z'3fec4fffdcbfe424',int64), int(z'bc843f68bcec4775',int64), &
    int(z'3fec6fffed54b9f7',int64), int(z'3c847ea3f053e0ec',int64), int(z'3fec8fffeb998fd5',int64), int(z'3c7383068df992f1',int64), &
    int(z'3fecb0002125219a',int64), int(z'bc68fd8e64180e04',int64), int(z'3feccfffdd94469c',int64), int(z'3c8e7ebe1cc7ea72',int64), &
    int(z'3fecefffeafdc476',int64), int(z'3c8ebe39ad9f88fe',int64), int(z'3fed1000169af82b',int64), int(z'3c757d91a8b95a71',int64), &
    int(z'3fed30000d0ff71d',int64), int(z'3c89c1906970c7da',int64), int(z'3fed4fffea790fc4',int64), int(z'bc580e37c558fe0c',int64), &
    int(z'3fed70002edc87e5',int64), int(z'bc7f80d64dc10f44',int64), int(z'3fed900021dc82aa',int64), int(z'bc747c8f94fd5c5c',int64), &
    int(z'3fedafffd86b0283',int64), int(z'3c8c7f1dc521617e',int64), int(z'3fedd000296c4739',int64), int(z'3c88019eb2ffb153',int64), &
    int(z'3fedefffe54490f5',int64), int(z'3c6e00d2c652cc89',int64), int(z'3fee0fffcdabf694',int64), int(z'bc7f8340202d69d2',int64), &
    int(z'3fee2fffdb52c8dd',int64), int(z'3c7b00c1ca1b0864',int64), int(z'3fee4ffff24216ef',int64), int(z'3c72ffa8b094ab51',int64), &
    int(z'3fee6fffe88a5e11',int64), int(z'bc57f673b1efbe59',int64), int(z'3fee9000119eff0d',int64), int(z'bc84808d5e0bc801',int64), &
    int(z'3feeafffdfa51744',int64), int(z'3c780006d54320b5',int64), int(z'3feed0001a127fa1',int64), int(z'bc5002f860565c92',int64), &
    int(z'3feef00007babcc4',int64), int(z'bc8540445d35e611',int64), int(z'3fef0ffff57a8d02',int64), int(z'bc4ffb3139ef9105',int64), &
    int(z'3fef30001ee58ac7',int64), int(z'3c8a81acf2731155',int64), int(z'3fef4ffff5823494',int64), int(z'3c8a3f41d4d7c743',int64), &
    int(z'3fef6ffffca94c6b',int64), int(z'bc6202f41c987875',int64), int(z'3fef8fffe1f9c441',int64), int(z'3c777dd1f477e74b',int64), &
    int(z'3fefafffd2e0e37e',int64), int(z'bc6f01199a7ca331',int64), int(z'3fefd0001c77e49e',int64), int(z'3c7181ee4bceacb1',int64), &
    int(z'3fefeffff7e0c331',int64), int(z'bc6e05370170875a',int64), int(z'3ff00ffff465606e',int64), int(z'bc8a7ead491c0ada',int64), &
    int(z'3ff02ffff3867a58',int64), int(z'bc977f69c3fcb2e0',int64), int(z'3ff04ffffdfc0d17',int64), int(z'3c97bffe34cb945b',int64), &
    int(z'3ff0700003cd4d82',int64), int(z'3c820083c0e456cb',int64), int(z'3ff08ffff9f2cbe8',int64), int(z'bc6dffdfbe37751a',int64), &
    int(z'3ff0b000010cda65',int64), int(z'bc913f7faee626eb',int64), int(z'3ff0d00001a4d338',int64), int(z'3c807dfa79489ff7',int64), &
    int(z'3ff0effffadafdfd',int64), int(z'bc77040570d66bc0',int64), int(z'3ff110000bbafd96',int64), int(z'3c8e80d4846d0b62',int64), &
    int(z'3ff12ffffae5f45d',int64), int(z'3c9dbffa64fd36ef',int64), int(z'3ff150000dd59ad9',int64), int(z'3c9a0077701250ae',int64), &
    int(z'3ff170000f21559a',int64), int(z'3c8dfdf9e2e3deee',int64), int(z'3ff18ffffc275426',int64), int(z'3c910030dc3b7273',int64), &
    int(z'3ff1b000123d3c59',int64), int(z'3c997f7980030188',int64), int(z'3ff1cffff8299eb7',int64), int(z'bc65f932ab9f8c67',int64), &
    int(z'3ff1effff48ad400',int64), int(z'3c937fbf9da75beb',int64), int(z'3ff210000c8b86a4',int64), int(z'3c9f806b91fd5b22',int64), &
    int(z'3ff2300003854303',int64), int(z'3c93ffc2eb9fbf33',int64), int(z'3ff24fffffbcf684',int64), int(z'3c7601e77e2e2e72',int64), &
    int(z'3ff26ffff52921d9',int64), int(z'3c7ffcbb767f0c61',int64), int(z'3ff2900014933a3c',int64), int(z'bc7202ca3c02412b',int64), &
    int(z'3ff2b00014556313',int64), int(z'bc92808233f21f02',int64), int(z'3ff2cfffebfe523b',int64), int(z'bc88ff7e384fdcf2',int64), &
    int(z'3ff2f0000bb8ad96',int64), int(z'bc85ff51503041c5',int64), int(z'3ff30ffffb7ae2af',int64), int(z'bc810071885e289d',int64), &
    int(z'3ff32ffffeac5f7f',int64), int(z'bc91ff5d3fb7b715',int64), int(z'3ff350000ca66756',int64), int(z'3c957f82228b82bd',int64), &
    int(z'3ff3700011fbf721',int64), int(z'3c8000bac40dd5cc',int64), int(z'3ff38ffff9592fb9',int64), int(z'bc943f9d2db2a751',int64), &
    int(z'3ff3b00004ddd242',int64), int(z'3c857f6b707638e1',int64), int(z'3ff3cffff5b2c957',int64), int(z'3c7a023a10bf1231',int64), &
    int(z'3ff3efffeab0b418',int64), int(z'3c987f6d66b152b0',int64), int(z'3ff410001532aff4',int64), int(z'3c67f8375f198524',int64), &
    int(z'3ff4300017478b29',int64), int(z'3c8301e672dc5143',int64), int(z'3ff44fffe795b463',int64), int(z'3c89ff69b8b2895a',int64), &
    int(z'3ff46fffe80475e0',int64), int(z'bc95c0b19bc2f254',int64), int(z'3ff48fffef6fc1e7',int64), int(z'3c9b4009f23a2a72',int64), &
    int(z'3ff4afffe5bea704',int64), int(z'bc94ffb7bf0d7d45',int64), int(z'3ff4d000171027de',int64), int(z'bc99c06471dc6a3d',int64), &
    int(z'3ff4f0000ff03ee2',int64), int(z'3c977f890b85531c',int64), int(z'3ff5100012dc4bd1',int64), int(z'3c6004657166a436',int64), &
    int(z'3ff530001605277a',int64), int(z'bc96bfcece233209',int64), int(z'3ff54fffecdb704c',int64), int(z'bc8902720505a1d7',int64), &
    int(z'3ff56fffef5f54a9',int64), int(z'3c9bbfe60ec96412',int64), int(z'3ff5900017e61012',int64), int(z'3c887ec581afef90',int64), &
    int(z'3ff5b00003c93e92',int64), int(z'bc9f41080abf0cc0',int64), int(z'3ff5d0001d4919bc',int64), int(z'bc98812afb254729',int64), &
    int(z'3ff5efffe7b87a89',int64), int(z'bc947eb780ed6904',int64) ]
  real(real64), parameter :: data(0:529)=transfer(source_bits,[0.0_real64],530)
contains
  !> Return log(x), with dimensionless x in [2**(-52), huge(x)].
  !! Input x is read only. Each assignment preserves one rounded operation.
  function positive_logarithm(x) result(y)
    real(real64), intent(in) :: x
    real(real64) :: y, reduced, square, cube, head, middle, tail
    real(real64) :: normalized, exponent_value, leading, sum_high, error_low
    real(real64) :: split_product, split_high, split_low, quadratic, temporary
    integer(int64) :: word, difference, exponent, normalized_word
    integer :: index
    word=transfer(x,word)
    logarithm_calls=logarithm_calls+1_c_int64_t
    if (word>=int(z'3fee000000000000',int64) .and. word<int(z'3ff1090000000000',int64)) then
      if (word==int(z'3ff0000000000000',int64)) then
        y=0.0_real64
        return
      end if
      reduced=x-1.0_real64
      square=reduced*reduced
      cube=reduced*square
      tail=reduced*data(15)
      tail=data(14)+tail
      temporary=square*data(16)
      tail=tail+temporary
      temporary=cube*data(17)
      tail=tail+temporary
      middle=reduced*data(12)
      middle=data(11)+middle
      temporary=square*data(13)
      middle=middle+temporary
      temporary=cube*tail
      middle=middle+temporary
      head=reduced*data(9)
      head=data(8)+head
      temporary=square*data(10)
      head=head+temporary
      temporary=cube*middle
      head=head+temporary
      head=cube*head
      split_product=reduced*134217728.0_real64
      split_high=reduced+split_product
      split_high=split_high-split_product
      split_low=reduced-split_high
      quadratic=split_high*split_high
      quadratic=quadratic*data(7)
      sum_high=reduced+quadratic
      error_low=reduced-sum_high
      error_low=error_low+quadratic
      temporary=data(7)*split_low
      leading=split_high+reduced
      temporary=temporary*leading
      error_low=error_low+temporary
      head=head+error_low
      y=head+sum_high
    else
      difference=word-int(z'3fe6000000000000',int64)
      index=int(iand(shiftr(difference,45),127_int64))
      exponent=shifta(difference,52)
      normalized_word=word-iand(difference,int(z'fff0000000000000',int64))
      normalized=transfer(normalized_word,normalized)
      exponent_value=real(exponent,real64)
      reduced=normalized-data(274+2*index)
      reduced=reduced-data(275+2*index)
      reduced=reduced*data(18+2*index)
      leading=exponent_value*data(0)
      leading=leading+data(19+2*index)
      sum_high=leading+reduced
      error_low=leading-sum_high
      error_low=error_low+reduced
      temporary=exponent_value*data(1)
      error_low=error_low+temporary
      square=reduced*reduced
      tail=reduced*data(6)
      tail=data(5)+tail
      head=reduced*data(4)
      head=data(3)+head
      temporary=square*tail
      head=head+temporary
      temporary=square*data(2)
      error_low=error_low+temporary
      temporary=reduced*square
      temporary=temporary*head
      error_low=error_low+temporary
      y=error_low+sum_high
    end if
  end function positive_logarithm
end module forecast_positive_logarithm
