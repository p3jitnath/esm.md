! Base-ten split: Copyright(C)1993 Sun Microsystems, freely redistributable
! with this notice. Permission to use, copy, modify and distribute the Sun
! component is freely granted provided that this notice is preserved. Normalized log and literals: GNU libc2.38, Copyright(C)
! 2018-2023 Free Software Foundation, Inc., LGPL-2.1-or-later.
!> Own both source-bounded base-ten logarithm entries and their shared body.
module forecast_original_rounding_log10
  use iso_fortran_env, only: int64, real64
  use iso_c_binding, only: c_double
  use forecast_spline_scalar_inverse, only: rounded_product_sum
  use forecast_private_math_environment, only: require_private_math_environment
  implicit none
  private
  public :: original_rounding_log10, original_rounding_radiation_log10
  interface
    subroutine public_abort() bind(C, name='abort')
    end subroutine
  end interface
  integer(int64), parameter :: data_words(277) = [ &
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
   int(z'3fe756cadbd6130c',int64), int(z'3fd432eee32fe000',int64), int(z'3fdbcb7b1526e50e',int64), int(z'3fd34413509f6000',int64), &
                               int(z'3d59fef311f12b36', int64)]
  real(real64), parameter :: data(0:276) = transfer(data_words, [0.0_real64], 277)
contains
!> Return log10(argument) for a finite dimensionless ratio in [2**(-40),32].
  real(c_double) function original_rounding_log10(argument) bind(C, name='md2asm_log10_original_rounding') result(answer)
    real(c_double), value, intent(in) :: argument
    integer(int64) :: word
    call require_private_math_environment()
    word = transfer(argument, word)
    if (word < int(z'3D70000000000000', int64) .or. word > int(z'4040000000000000', int64)) call public_abort()
    answer = base_ten_body(word)
  end function
!> Return the identical ordered logarithm on the radiation range through2**20.
real(c_double)function original_rounding_radiation_log10(argument)bind(C,name='md2asm_log10_radiation_original_rounding')result(answer)
  real(c_double), value, intent(in) :: argument
  integer(int64) :: word
  call require_private_math_environment()
  word = transfer(argument, word)
  if (word < int(z'3D70000000000000', int64) .or. word > int(z'4130000000000000', int64)) call public_abort()
  answer = base_ten_body(word)
  end function
!> Keep normalization, the selected polynomial and the base-ten split in order.
  real(real64) function base_ten_body(word) result(answer)
    integer(int64), intent(in) :: word
    integer(int64) :: mantissa_word, delta, normalized_word
    integer :: exponent, adjustment, index, table_exponent
    real(real64) :: outer_exponent, mantissa, r, square, cube, p, q, rhigh, rlow, high, low, temporary, natural_log, table_power, z
    exponent = int(ibits(word, 52, 11)) - 1023
    adjustment = 0
    if (exponent < 0) adjustment = 1
    exponent = exponent + adjustment
    outer_exponent = real(exponent, real64)
    mantissa_word = ior(iand(word, int(z'000FFFFFFFFFFFFF', int64)), shiftl(int(1023 - adjustment, int64), 52))
    mantissa = transfer(mantissa_word, mantissa)
    if (mantissa_word >= int(z'3FEE000000000000', int64) .and. mantissa_word < int(z'3FF1090000000000', int64)) then
      if (mantissa_word == int(z'3FF0000000000000', int64)) then
        natural_log = 0.0_real64
      else
        r = mantissa - 1.0_real64
        square = r*r
        cube = r*square
        p = rounded_product_sum(r, data(15), data(14))
        p = rounded_product_sum(square, data(16), p)
        p = rounded_product_sum(cube, data(17), p)
        q = rounded_product_sum(r, data(12), data(11))
        q = rounded_product_sum(square, data(13), q)
        q = rounded_product_sum(cube, p, q)
        p = rounded_product_sum(r, data(9), data(8))
        p = rounded_product_sum(square, data(10), p)
        p = rounded_product_sum(cube, q, p)
        rhigh = rounded_product_sum(r, 134217728.0_real64, r)
        rhigh = rounded_product_sum(-r, 134217728.0_real64, rhigh)
        temporary = rhigh*rhigh
        rlow = r - rhigh
        high = rounded_product_sum(temporary, data(7), r)
        low = r - high
        low = rounded_product_sum(temporary, data(7), low)
        rlow = rlow*data(7)
        rhigh = rhigh + r
        low = rounded_product_sum(rlow, rhigh, low)
        low = rounded_product_sum(p, cube, low)
        natural_log = high + low
      end if
    else
      delta = mantissa_word - int(z'3FE6000000000000', int64)
      index = int(ibits(delta, 45, 7))
      table_exponent = int(shifta(delta, 52))
      normalized_word = mantissa_word - iand(delta, int(z'FFF0000000000000', int64))
      z = transfer(normalized_word, z)
      table_power = real(table_exponent, real64)
      r = rounded_product_sum(z, data(18 + 2*index), -1.0_real64)
      high = rounded_product_sum(table_power, data(0), data(19 + 2*index))
      temporary = high + r
      low = high - temporary
      low = low + r
      low = rounded_product_sum(table_power, data(1), low)
      square = r*r
      cube = r*square
      p = rounded_product_sum(r, data(6), data(5))
      q = rounded_product_sum(r, data(4), data(3))
      q = rounded_product_sum(square, p, q)
      low = rounded_product_sum(square, data(2), low)
      low = rounded_product_sum(cube, q, low)
      natural_log = temporary + low
    end if
    temporary = natural_log*data(274)
    temporary = rounded_product_sum(outer_exponent, data(276), temporary)
    answer = rounded_product_sum(outer_exponent, data(275), temporary)
  end function
end module forecast_original_rounding_log10
