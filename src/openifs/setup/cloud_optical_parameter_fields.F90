!> Set the selected SUCLOPN and SU_CLOP550 cloud optical parameters.
!! The caller admits NTSW=14, NSW=6, live levels 1 through 256, separate
!! native record owners, nearest-even rounding and gradual underflow.
!! Literal words come from the two selected generated source files under
!! src/openifs/setup. Named fields replace their historical byte stores.
!! The original OpenIFS modules supply native type declarations only.
module cloud_optical_parameter_fields_mod
  use iso_fortran_env, only: int32, int64, real64
  use yoerad, only: terad
  use yoesw, only: teswrt
  implicit none
  private
  public :: cloud_optical_550_parameter_record
  public :: initialize_cloud_optical_fields, initialize_cloud_optical_550_fields

  !> Owned optical coefficients at a wavelength of 550 nanometres.
  !! RSA55 and RSB55 define droplet extinction; RSC55 and RSD55 define
  !! absorption. RFA55(2) defines the asymmetry fit. Droplet radius is supplied
  !! in micrometres by the source consumer. The caller owns this six-word
  !! native record; there is no original module namespace or saved instance.
  type :: cloud_optical_550_parameter_record
    real(real64) :: rsa55, rsb55, rsc55, rsd55, rfa55(2)
  end type cloud_optical_550_parameter_record

  ! The six words in each named table retain source band order and signs.
  integer(int64), parameter :: raswca_words(6) = [ &
                               int(z'4008c083126e978d', int64), &
                               int(z'40070c49ba5e353f', int64), &
                               int(z'400651eb851eb852', int64), &
                               int(z'400574bc6a7ef9db', int64), &
                               int(z'4002083126e978d5', int64), &
                               int(z'3ff47ef9db22d0e5', int64)]
  integer(int64), parameter :: raswcb_words(6) = [ &
                               int(z'3ff4083126e978d5', int64), &
                               int(z'3ff48b4395810625', int64), &
                               int(z'3ff5020c49ba5e35', int64), &
                               int(z'3ff589374bc6a7f0', int64), &
                               int(z'3ff74bc6a7ef9db2', int64), &
                               int(z'3ffa4189374bc6a8', int64)]
  integer(int64), parameter :: raswcc_words(6) = [ &
                               int(z'3eaa820c5f33ed17', int64), &
                               int(z'3e87c1ac7705b4ba', int64), &
                               int(z'be84cdc26b1f07d8', int64), &
                               int(z'bedd1bc4ac97ce12', int64), &
                               int(z'3f3f212d77318fc5', int64), &
                               int(z'3fc9ba5e353f7cee', int64)]
  integer(int64), parameter :: raswcd_words(6) = [ &
                               int(z'3e98c35f299ffb4c', int64), &
                               int(z'3e80823f71155233', int64), &
                               int(z'3e8828c0be769dc1', int64), &
                               int(z'3ef8a43bb40b34e7', int64), &
                               int(z'3f54a4d2b2bfdb4d', int64), &
                               int(z'3f7ef73c0c1fc8f3', int64)]
  integer(int64), parameter :: raswce_words(6) = [ &
                               int(z'3feb020c49ba5e35', int64), &
                               int(z'3fead916872b020c', int64), &
                               int(z'3fea5e353f7ced91', int64), &
                               int(z'3fe96872b020c49c', int64), &
                               int(z'3fe820c49ba5e354', int64), &
                               int(z'3fea6e978d4fdf3b', int64)]
  integer(int64), parameter :: raswcf_words(6) = [ &
                               int(z'3ff8ed916872b021', int64), &
                               int(z'3ffe9fbe76c8b439', int64), &
                               int(z'4005c8b439581062', int64), &
                               int(z'4010e76c8b439581', int64), &
                               int(z'401a3e76c8b43958', int64), &
                               int(z'40116978d4fdf3b6', int64)]
  integer(int64), parameter :: rkpnwca_words(6) = [ &
                               int(z'3ff8000000000000', int64), &
                               int(z'3ff9b22d0e560419', int64), &
                               int(z'3ffa353f7ced9168', int64), &
                               int(z'3ffaf5c28f5c28f6', int64), &
                               int(z'3ffc51eb851eb852', int64), &
                               int(z'3ffdeb851eb851ec', int64)]
  integer(int64), parameter :: rkpnwcb_words(6) = [ &
                               int(z'3ff0000000000000', int64), &
                               int(z'3ff03d70a3d70a3d', int64), &
                               int(z'3ff04dd2f1a9fbe7', int64), &
                               int(z'3ff0624dd2f1a9fc', int64), &
                               int(z'3ff08f5c28f5c28f', int64), &
                               int(z'3ff0bc6a7ef9db23', int64)]
  integer(int64), parameter :: rkpnwcc_words(6) = [ &
                               int(z'3ff0000000000000', int64), &
                               int(z'3ff0000000000000', int64), &
                               int(z'3ff0000000000000', int64), &
                               int(z'3fefffeb074a771d', int64), &
                               int(z'3feff3b645a1cac1', int64), &
                               int(z'3fea5604189374bc', int64)]
  integer(int64), parameter :: rkpnwcd_words(6) = [ &
                               int(z'3e7ad7f29abcaf48', int64), &
                               int(z'3e61b77c47680d49', int64), &
                               int(z'3e7ad7f29abcaf48', int64), &
                               int(z'3eef3f60681fa40a', int64), &
                               int(z'3f4e2584f4c6e6da', int64), &
                               int(z'3f70624dd2f1a9fc', int64)]
  integer(int64), parameter :: rkpnwce_words(6) = [ &
                               int(z'3febc6a7ef9db22d', int64), &
                               int(z'3febc6a7ef9db22d', int64), &
                               int(z'3febc6a7ef9db22d', int64), &
                               int(z'3febbe76c8b43958', int64), &
                               int(z'3feba5e353f7ced9', int64), &
                               int(z'3fec5a1cac083127', int64)]
  integer(int64), parameter :: rkpnwcf_words(6) = [ &
                               int(z'3f22599ed7c6fbd2', int64), &
                               int(z'3f22599ed7c6fbd2', int64), &
                               int(z'3f30624dd2f1a9fc', int64), &
                               int(z'3f3450efdc9c4da9', int64), &
                               int(z'3f41b1d92b7fe08b', int64), &
                               int(z'3f5205bc01a36e2f', int64)]
  integer(int64), parameter :: rkpnwcg_words(6) = [ &
                               int(z'3faf3b645a1cac08', int64), &
                               int(z'3faf3b645a1cac08', int64), &
                               int(z'3fb020c49ba5e354', int64), &
                               int(z'3fb3f7ced916872b', int64), &
                               int(z'3fc10624dd2f1aa0', int64), &
                               int(z'3fc999999999999a', int64)]
  integer(int64), parameter :: rkpnwch_words(6) = [ &
                               int(z'3fd0000000000000', int64), &
                               int(z'3fd0000000000000', int64), &
                               int(z'3fd0000000000000', int64), &
                               int(z'3fc8f5c28f5c28f6', int64), &
                               int(z'3fc8d4fdf3b645a2', int64), &
                               int(z'3fc70a3d70a3d70a', int64)]
  integer(int64), parameter :: rebcua_words(6) = [ &
                               int(z'3f6c3efae7924af1', int64), &
                               int(z'3f6c3efae7924af1', int64), &
                               int(z'3f6c3efae7924af1', int64), &
                               int(z'3f6c3efae7924af1', int64), &
                               int(z'3f6c3efae7924af1', int64), &
                               int(z'3f6c3efae7924af1', int64)]
  integer(int64), parameter :: rebcub_words(6) = [ &
                               int(z'400372b020c49ba6', int64), &
                               int(z'400372b020c49ba6', int64), &
                               int(z'400372b020c49ba6', int64), &
                               int(z'400372b020c49ba6', int64), &
                               int(z'400372b020c49ba6', int64), &
                               int(z'400372b020c49ba6', int64)]
  integer(int64), parameter :: rebcuc_words(6) = [ &
                               int(z'3ee4f8b588e368f1', int64), &
                               int(z'3ee4f8b588e368f1', int64), &
                               int(z'3ee4f8b588e368f1', int64), &
                               int(z'3f1cd5f99c38b04b', int64), &
                               int(z'3f94411a7c83085e', int64), &
                               int(z'3fdddc725c3dee78', int64)]
  integer(int64), parameter :: rebcud_words(6) = [ &
                               int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), &
                               int(z'3eed77094bd91c66', int64), &
                               int(z'3f4a113f28c60315', int64), &
                               int(z'3ef57eed45e9185d', int64)]
  integer(int64), parameter :: rebcue_words(6) = [ &
                               int(z'3fe883e425aee632', int64), &
                               int(z'3fe883e425aee632', int64), &
                               int(z'3fe883e425aee632', int64), &
                               int(z'3fe8bc6a7ef9db23', int64), &
                               int(z'3fe975fd47bedb73', int64), &
                               int(z'3feeb4395810624e', int64)]
  integer(int64), parameter :: rebcuf_words(6) = [ &
                               int(z'3f432c2caeb4b3d1', int64), &
                               int(z'3f432c2caeb4b3d1', int64), &
                               int(z'3f432c2caeb4b3d1', int64), &
                               int(z'3f4290257c914b16', int64), &
                               int(z'3f47d0005df3d11e', int64), &
                               int(z'3f1c34e9ec98442f', int64)]
  integer(int64), parameter :: ryfwca_words(6) = [ &
                               int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64)]
  integer(int64), parameter :: ryfwcb_words(6) = [ &
                               int(z'3ff8000000000000', int64), &
                               int(z'3ff8000000000000', int64), &
                               int(z'3ff8000000000000', int64), &
                               int(z'3ff8000000000000', int64), &
                               int(z'3ff8000000000000', int64), &
                               int(z'3ff8000000000000', int64)]
  integer(int64), parameter :: ryfwcc_words(6) = [ &
                               int(z'3fefff2e48e8a71e', int64), &
                               int(z'3fefff2e48e8a71e', int64), &
                               int(z'3fefff2e48e8a71e', int64), &
                               int(z'3feff62b6ae7d567', int64), &
                               int(z'3feff62b6ae7d567', int64), &
                               int(z'3feff62b6ae7d567', int64)]
  integer(int64), parameter :: ryfwcd_words(6) = [ &
                               int(z'3f40624dd2f1a9fc', int64), &
                               int(z'3f40624dd2f1a9fc', int64), &
                               int(z'3f40624dd2f1a9fc', int64), &
                               int(z'3f647ae147ae147b', int64), &
                               int(z'3f647ae147ae147b', int64), &
                               int(z'3f647ae147ae147b', int64)]
  integer(int64), parameter :: ryfwce_words(6) = [ &
                               int(z'3fe0000000000000', int64), &
                               int(z'3fe0000000000000', int64), &
                               int(z'3fe0000000000000', int64), &
                               int(z'3fa999999999999a', int64), &
                               int(z'3fa999999999999a', int64), &
                               int(z'3fa999999999999a', int64)]
  integer(int64), parameter :: ryfwcf_words(6) = [ &
                               int(z'3febae147ae147ae', int64), &
                               int(z'3febae147ae147ae', int64), &
                               int(z'3febae147ae147ae', int64), &
                               int(z'3fed1eb851eb851f', int64), &
                               int(z'3fed1eb851eb851f', int64), &
                               int(z'3fed1eb851eb851f', int64)]
  integer(int64), parameter :: rflaa0_words(6) = [ &
                               int(z'bf7b43526527a205', int64), &
                               int(z'bf7b43526527a205', int64), &
                               int(z'bf7b43526527a205', int64), &
                               int(z'bf7b43526527a205', int64), &
                               int(z'bf7b43526527a205', int64), &
                               int(z'bf7b43526527a205', int64)]
  integer(int64), parameter :: rflaa1_words(6) = [ &
                               int(z'400d7ced916872b0', int64), &
                               int(z'400d7ced916872b0', int64), &
                               int(z'400d7ced916872b0', int64), &
                               int(z'400d7ced916872b0', int64), &
                               int(z'400d7ced916872b0', int64), &
                               int(z'400d7ced916872b0', int64)]
  integer(int64), parameter :: rflbb0_words(6) = [ &
                               int(z'3eb2739ae362e9c4', int64), &
                               int(z'3eb2739ae362e9c4', int64), &
                               int(z'3eb2739ae362e9c4', int64), &
                               int(z'3ef5308b2f95e72a', int64), &
                               int(z'3f40e4ea24f75b41', int64), &
                               int(z'3fd94a771c970f7c', int64)]
  integer(int64), parameter :: rflbb1_words(6) = [ &
                               int(z'be5c0696977ef927', int64), &
                               int(z'be5c0696977ef927', int64), &
                               int(z'be5c0696977ef927', int64), &
                               int(z'3ee43be44139847c', int64), &
                               int(z'3f5194e859f10d1e', int64), &
                               int(z'3f59dd8c37b14735', int64)]
  integer(int64), parameter :: rflbb2_words(6) = [ &
                               int(z'3e1f16b478af23a4', int64), &
                               int(z'3e1f16b478af23a4', int64), &
                               int(z'3e1f16b478af23a4', int64), &
                               int(z'3e764855c577e8e6', int64), &
                               int(z'3ebdc8dafe278891', int64), &
                               int(z'beee111e46a338bb', int64)]
  integer(int64), parameter :: rflbb3_words(6) = [ &
                               int(z'bd94d74d48917f60', int64), &
                               int(z'bd94d74d48917f60', int64), &
                               int(z'bd94d74d48917f60', int64), &
                               int(z'bdf623acb123a1d1', int64), &
                               int(z'be53bbfb2634ad4d', int64), &
                               int(z'3e6933a8cb6a825c', int64)]
  integer(int64), parameter :: rflcc0_words(6) = [ &
                               int(z'4001b020c49ba5e3', int64), &
                               int(z'4001b020c49ba5e3', int64), &
                               int(z'4001b020c49ba5e3', int64), &
                               int(z'4001b886594af4f1', int64), &
                               int(z'400206f694467382', int64), &
                               int(z'40055288ce703afb', int64)]
  integer(int64), parameter :: rflcc1_words(6) = [ &
                               int(z'bf51093cbfa3ef5e', int64), &
                               int(z'bf51093cbfa3ef5e', int64), &
                               int(z'bf51093cbfa3ef5e', int64), &
                               int(z'bf498d9ab2c9407b', int64), &
                               int(z'3f5a7b40e8fe5bbb', int64), &
                               int(z'3f77521144cbe1eb', int64)]
  integer(int64), parameter :: rflcc2_words(6) = [ &
                               int(z'3f11176e4a7a3b74', int64), &
                               int(z'3f11176e4a7a3b74', int64), &
                               int(z'3f11176e4a7a3b74', int64), &
                               int(z'3f10b630a91537a0', int64), &
                               int(z'3f07168bcc6b41dc', int64), &
                               int(z'bf0c7a2b8c9820c0', int64)]
  integer(int64), parameter :: rflcc3_words(6) = [ &
                               int(z'be9726b615dcd149', int64), &
                               int(z'be9726b615dcd149', int64), &
                               int(z'be9726b615dcd149', int64), &
                               int(z'be972136b5e472f0', int64), &
                               int(z'be928a484f436ef4', int64), &
                               int(z'3e87f7f64aba586a', int64)]
  integer(int64), parameter :: rfldd0_words(6) = [ &
                               int(z'3fbffcb923a29c78', int64), &
                               int(z'3fbffcb923a29c78', int64), &
                               int(z'3fbffcb923a29c78', int64), &
                               int(z'3fbfa63736cdf267', int64), &
                               int(z'3fbead2dcb1465e9', int64), &
                               int(z'3f965ba6efc371da', int64)]
  integer(int64), parameter :: rfldd1_words(6) = [ &
                               int(z'bf3c8fd8a59e09c1', int64), &
                               int(z'bf3c8fd8a59e09c1', int64), &
                               int(z'bf3c8fd8a59e09c1', int64), &
                               int(z'bf3d1c4585f11b36', int64), &
                               int(z'bf406b5d1b391677', int64), &
                               int(z'bf33239e3fc69479', int64)]
  integer(int64), parameter :: rfldd2_words(6) = [ &
                               int(z'3eed8d95bb79cf60', int64), &
                               int(z'3eed8d95bb79cf60', int64), &
                               int(z'3eed8d95bb79cf60', int64), &
                               int(z'3eed709807620dd6', int64), &
                               int(z'3ee8d62986a5e5c7', int64), &
                               int(z'3ebe4cb5fff07f73', int64)]
  integer(int64), parameter :: rfldd3_words(6) = [ &
                               int(z'be72ac786c13f9ae', int64), &
                               int(z'be72ac786c13f9ae', int64), &
                               int(z'be72ac786c13f9ae', int64), &
                               int(z'be727b6799f1af9f', int64), &
                               int(z'be6fdf569e27fd47', int64), &
                               int(z'be33de02ccbdc21e', int64)]
  integer(int64), parameter :: rfuaa0_words(6) = [ &
                               int(z'bf21257d7938b73d', int64), &
                               int(z'bf21257d7938b73d', int64), &
                               int(z'bf21257d7938b73d', int64), &
                               int(z'bf10c3788e7cc80c', int64), &
                               int(z'bedc4cdbb397071d', int64), &
                               int(z'3f25526f0512dbc7', int64)]
  integer(int64), parameter :: rfuaa1_words(6) = [ &
                               int(z'40043b0b39192642', int64), &
                               int(z'40043b0b39192642', int64), &
                               int(z'40043b0b39192642', int64), &
                               int(z'40043102363b2570', int64), &
                               int(z'40042a1b5c7cd899', int64), &
                               int(z'4003fc60029f16b1', int64)]
  integer(int64), parameter :: rfubb0_words(6) = [ &
                               int(z'be50ae6bb2ec7b7d', int64), &
                               int(z'be50ae6bb2ec7b7d', int64), &
                               int(z'be50ae6bb2ec7b7d', int64), &
                               int(z'beaa87b121527df2', int64), &
                               int(z'3f4f9dae6afbbb3c', int64), &
                               int(z'3fccd07852f7f499', int64)]
  integer(int64), parameter :: rfubb1_words(6) = [ &
                               int(z'3e8a476570ebbe84', int64), &
                               int(z'3e8a476570ebbe84', int64), &
                               int(z'3e8a476570ebbe84', int64), &
                               int(z'3ee05b8b77b30bfc', int64), &
                               int(z'3f4dd007f3471297', int64), &
                               int(z'3f68fcab8cb63155', int64)]
  integer(int64), parameter :: rfubb2_words(6) = [ &
                               int(z'bdefc7d2b6647c25', int64), &
                               int(z'bdefc7d2b6647c25', int64), &
                               int(z'bdefc7d2b6647c25', int64), &
                               int(z'3df3fd761c293e1f', int64), &
                               int(z'becdfe7a653d18d5', int64), &
                               int(z'befaa8987d1e6aa3', int64)]
  integer(int64), parameter :: rfubb3_words(6) = [ &
                               int(z'3d73bf27cd206d53', int64), &
                               int(z'3d73bf27cd206d53', int64), &
                               int(z'3d73bf27cd206d53', int64), &
                               int(z'bd81d70e2b29cffd', int64), &
                               int(z'3e458463697dac7e', int64), &
                               int(z'3e76cb14aa1e9323', int64)]
  integer(int64), parameter :: rfucc0_words(6) = [ &
                               int(z'3fe7ac493426783a', int64), &
                               int(z'3fe7ac493426783a', int64), &
                               int(z'3fe7ac493426783a', int64), &
                               int(z'3fe81320d9945b6c', int64), &
                               int(z'3fe833aabcd78c43', int64), &
                               int(z'3fea96030c23fab1', int64)]
  integer(int64), parameter :: rfucc1_words(6) = [ &
                               int(z'3f4dd65d4ceac7e8', int64), &
                               int(z'3f4dd65d4ceac7e8', int64), &
                               int(z'3f4dd65d4ceac7e8', int64), &
                               int(z'3f5166cfedbe89e9', int64), &
                               int(z'3f5c6769c6982a59', int64), &
                               int(z'3f658710550cccc2', int64)]
  integer(int64), parameter :: rfucc2_words(6) = [ &
                               int(z'be9f09542704447b', int64), &
                               int(z'be9f09542704447b', int64), &
                               int(z'be9f09542704447b', int64), &
                               int(z'bec49ddedd2181fc', int64), &
                               int(z'bee2b5e9f92eddc0', int64), &
                               int(z'bef9803e2fb9ccad', int64)]
  integer(int64), parameter :: rfucc3_words(6) = [ &
                               int(z'be46be76bd3a5435', int64), &
                               int(z'be46be76bd3a5435', int64), &
                               int(z'be46be76bd3a5435', int64), &
                               int(z'be2a16b290024a1d', int64), &
                               int(z'3e553be72c9a9d50', int64), &
                               int(z'3e761b582acad7fa', int64)]

contains

  !> Set the complete selected cloud optical fields in native records.
  !! RADIATION is a TERAD record; only RAOVLP and RBOVLP are changed.
  !! SHORTWAVE is a TESWRT record. Its named fixed longwave tables and six
  !! consumed shortwave bands are changed in their generated source order.
  !! LEVELS is the live int32 level count admitted by the parent. The choices
  !! 19, 31 and all other supported counts select exact overlap words.
  !! REFFIA is the reference ice radius in micrometres. The source coefficient
  !! fits retain their consumer units; RASWCA and RASWCF retain their separate
  !! 1e-2 and 1e-3 source conversions. Other fields, padding and all allocated
  !! owners retain their incoming bits. No allocation or external call occurs.
  subroutine initialize_cloud_optical_fields(radiation, shortwave, levels)
    type(terad), intent(inout) :: radiation
    type(teswrt), intent(inout) :: shortwave
    integer(int32), intent(in) :: levels
    integer(int32) :: band
    real(real64), volatile :: source_coefficient, conversion_scale
    real(real64) :: converted_coefficient

    ! Store all 461 unconditional literal words in their original order.
    shortwave%rhsavi(1, 1) = transfer(int(z'3fc52243f7a6952b', int64), 0.0_real64)
    shortwave%rhsavi(1, 2) = transfer(int(z'bf6ca13566b68fc1', int64), 0.0_real64)
    shortwave%rhsavi(1, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rhsavi(2, 1) = transfer(int(z'3fd4fb033dc47e16', int64), 0.0_real64)
    shortwave%rhsavi(2, 2) = transfer(int(z'bf967d9564d329b8', int64), 0.0_real64)
    shortwave%rhsavi(2, 3) = transfer(int(z'3f409b36224f7157', int64), 0.0_real64)
    shortwave%rhsavi(3, 1) = transfer(int(z'3fe0275dc3ef4765', int64), 0.0_real64)
    shortwave%rhsavi(3, 2) = transfer(int(z'bfa8812303a4cb07', int64), 0.0_real64)
    shortwave%rhsavi(3, 3) = transfer(int(z'3f572fd3430fca7a', int64), 0.0_real64)
    shortwave%rhsavi(4, 1) = transfer(int(z'3fe06be196f8186f', int64), 0.0_real64)
    shortwave%rhsavi(4, 2) = transfer(int(z'bfaa0f0adb8c696c', int64), 0.0_real64)
    shortwave%rhsavi(4, 3) = transfer(int(z'3f597a16b21f27b3', int64), 0.0_real64)
    shortwave%rhsavi(5, 1) = transfer(int(z'3fdcacb8b25afdf5', int64), 0.0_real64)
    shortwave%rhsavi(5, 2) = transfer(int(z'bfa61c719ed577ff', int64), 0.0_real64)
    shortwave%rhsavi(5, 3) = transfer(int(z'3f55703433fbe869', int64), 0.0_real64)
    shortwave%rhsavi(6, 1) = transfer(int(z'3fcff129f2dc6fc7', int64), 0.0_real64)
    shortwave%rhsavi(6, 2) = transfer(int(z'bf92f8d7a8da0f92', int64), 0.0_real64)
    shortwave%rhsavi(6, 3) = transfer(int(z'3f40809bc7cd58c1', int64), 0.0_real64)
    shortwave%rhsavi(7, 1) = transfer(int(z'3fc157a19eee0eb3', int64), 0.0_real64)
    shortwave%rhsavi(7, 2) = transfer(int(z'bf77ff1b5a1fc566', int64), 0.0_real64)
    shortwave%rhsavi(7, 3) = transfer(int(z'3f1f1fea4ff0505b', int64), 0.0_real64)
    shortwave%rhsavi(8, 1) = transfer(int(z'3fc036af118393a6', int64), 0.0_real64)
    shortwave%rhsavi(8, 2) = transfer(int(z'bf74655fe38fe6ce', int64), 0.0_real64)
    shortwave%rhsavi(8, 3) = transfer(int(z'3f18518cae9576da', int64), 0.0_real64)
    shortwave%rhsavi(9, 1) = transfer(int(z'3fc0c299dccf3d2e', int64), 0.0_real64)
    shortwave%rhsavi(9, 2) = transfer(int(z'bf75c87b252d959e', int64), 0.0_real64)
    shortwave%rhsavi(9, 3) = transfer(int(z'3f19d1e86b478bc9', int64), 0.0_real64)
    shortwave%rhsavi(10, 1) = transfer(int(z'3fc2d1b30e685633', int64), 0.0_real64)
    shortwave%rhsavi(10, 2) = transfer(int(z'bf7b82d23d5c246c', int64), 0.0_real64)
    shortwave%rhsavi(10, 3) = transfer(int(z'3f2127c65ee9fe83', int64), 0.0_real64)
    shortwave%rhsavi(11, 1) = transfer(int(z'3fcee84a1ee5a6ec', int64), 0.0_real64)
    shortwave%rhsavi(11, 2) = transfer(int(z'bf91de0ed16f97ea', int64), 0.0_real64)
    shortwave%rhsavi(11, 3) = transfer(int(z'3f3dffe170034006', int64), 0.0_real64)
    shortwave%rhsavi(12, 1) = transfer(int(z'3fb365630634a274', int64), 0.0_real64)
    shortwave%rhsavi(12, 2) = transfer(int(z'bf5bc7cfc07ab78a', int64), 0.0_real64)
    shortwave%rhsavi(12, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rhsavi(13, 1) = transfer(int(z'3fba6c7b535d7526', int64), 0.0_real64)
    shortwave%rhsavi(13, 2) = transfer(int(z'bf68094bae2948a4', int64), 0.0_real64)
    shortwave%rhsavi(13, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rhsavi(14, 1) = transfer(int(z'3fb2cc32c9000e99', int64), 0.0_real64)
    shortwave%rhsavi(14, 2) = transfer(int(z'bf5d1574b157d14d', int64), 0.0_real64)
    shortwave%rhsavi(14, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rhsavi(15, 1) = transfer(int(z'3fa7ce3603722561', int64), 0.0_real64)
    shortwave%rhsavi(15, 2) = transfer(int(z'bf4e088bfa259ec1', int64), 0.0_real64)
    shortwave%rhsavi(15, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rhsavi(16, 1) = transfer(int(z'3fb1a5bc9297f2a5', int64), 0.0_real64)
    shortwave%rhsavi(16, 2) = transfer(int(z'bf2052e02c0d14b5', int64), 0.0_real64)
    shortwave%rhsavi(16, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rlilia(1, 1) = transfer(int(z'3fb68ec52a411c2a', int64), 0.0_real64)
    shortwave%rlilia(1, 2) = transfer(int(z'bf55109ddcf538fd', int64), 0.0_real64)
    shortwave%rlilia(1, 3) = transfer(int(z'3fea216c61522a6f', int64), 0.0_real64)
    shortwave%rlilia(1, 4) = transfer(int(z'c00f8adab9f559b4', int64), 0.0_real64)
    shortwave%rlilia(1, 5) = transfer(int(z'4012a92a30553261', int64), 0.0_real64)
    shortwave%rlilia(2, 1) = transfer(int(z'3f3b122a2415dee4', int64), 0.0_real64)
    shortwave%rlilia(2, 2) = transfer(int(z'bf0f43898f01dd72', int64), 0.0_real64)
    shortwave%rlilia(2, 3) = transfer(int(z'40036b851eb851ec', int64), 0.0_real64)
    shortwave%rlilia(2, 4) = transfer(int(z'c0222ae7d566cf42', int64), 0.0_real64)
    shortwave%rlilia(2, 5) = transfer(int(z'402336bb98c7e282', int64), 0.0_real64)
    shortwave%rlilia(3, 1) = transfer(int(z'bfad8c08b75ea67f', int64), 0.0_real64)
    shortwave%rlilia(3, 2) = transfer(int(z'3f503b56c33040e5', int64), 0.0_real64)
    shortwave%rlilia(3, 3) = transfer(int(z'4008e4f765fd8adb', int64), 0.0_real64)
    shortwave%rlilia(3, 4) = transfer(int(z'c0231ba5e353f7cf', int64), 0.0_real64)
    shortwave%rlilia(3, 5) = transfer(int(z'402209ad42c3c9ef', int64), 0.0_real64)
    shortwave%rlilia(4, 1) = transfer(int(z'bfab2bdc26dce39b', int64), 0.0_real64)
    shortwave%rlilia(4, 2) = transfer(int(z'3f5061f7ecb6213a', int64), 0.0_real64)
    shortwave%rlilia(4, 3) = transfer(int(z'40066f9db22d0e56', int64), 0.0_real64)
    shortwave%rlilia(4, 4) = transfer(int(z'c01d226809d49518', int64), 0.0_real64)
    shortwave%rlilia(4, 5) = transfer(int(z'40190779a6b50b0f', int64), 0.0_real64)
    shortwave%rlilia(5, 1) = transfer(int(z'bf9831ad2135daad', int64), 0.0_real64)
    shortwave%rlilia(5, 2) = transfer(int(z'3f421e252f0e8b5e', int64), 0.0_real64)
    shortwave%rlilia(5, 3) = transfer(int(z'40016d916872b021', int64), 0.0_real64)
    shortwave%rlilia(5, 4) = transfer(int(z'c015dd97f62b6ae8', int64), 0.0_real64)
    shortwave%rlilia(5, 5) = transfer(int(z'4012f39c0ebedfa4', int64), 0.0_real64)
    shortwave%rlilia(6, 1) = transfer(int(z'3f9db7f1737542a2', int64), 0.0_real64)
    shortwave%rlilia(6, 2) = transfer(int(z'bf39fd572e3a2515', int64), 0.0_real64)
    shortwave%rlilia(6, 3) = transfer(int(z'3ff7d7dbf487fcb9', int64), 0.0_real64)
    shortwave%rlilia(6, 4) = transfer(int(z'c0144f9096bb98c8', int64), 0.0_real64)
    shortwave%rlilia(6, 5) = transfer(int(z'4014de353f7ced91', int64), 0.0_real64)
    shortwave%rlilia(7, 1) = transfer(int(z'bf997fa5d28d002e', int64), 0.0_real64)
    shortwave%rlilia(7, 2) = transfer(int(z'3f253a23e83c94dc', int64), 0.0_real64)
    shortwave%rlilia(7, 3) = transfer(int(z'403d600000000000', int64), 0.0_real64)
    shortwave%rlilia(7, 4) = transfer(int(z'c026dfbe76c8b439', int64), 0.0_real64)
    shortwave%rlilia(7, 5) = transfer(int(z'40288bc6a7ef9db2', int64), 0.0_real64)
    shortwave%rlilia(8, 1) = transfer(int(z'bfc243aa79bbadc1', int64), 0.0_real64)
    shortwave%rlilia(8, 2) = transfer(int(z'3f6240dfc42055e1', int64), 0.0_real64)
    shortwave%rlilia(8, 3) = transfer(int(z'40129758e219652c', int64), 0.0_real64)
    shortwave%rlilia(8, 4) = transfer(int(z'c0305e76c8b43958', int64), 0.0_real64)
    shortwave%rlilia(8, 5) = transfer(int(z'40308872b020c49c', int64), 0.0_real64)
    shortwave%rlilia(9, 1) = transfer(int(z'bfca1c044284dfce', int64), 0.0_real64)
    shortwave%rlilia(9, 2) = transfer(int(z'3f6c6ecb8fb5eb09', int64), 0.0_real64)
    shortwave%rlilia(9, 3) = transfer(int(z'401524a8c154c986', int64), 0.0_real64)
    shortwave%rlilia(9, 4) = transfer(int(z'c0309a5e353f7cee', int64), 0.0_real64)
    shortwave%rlilia(9, 5) = transfer(int(z'402ec8b439581062', int64), 0.0_real64)
    shortwave%rlilia(10, 1) = transfer(int(z'bfc7727136a400fc', int64), 0.0_real64)
    shortwave%rlilia(10, 2) = transfer(int(z'3f6b1960fa15db34', int64), 0.0_real64)
    shortwave%rlilia(10, 3) = transfer(int(z'401272b020c49ba6', int64), 0.0_real64)
    shortwave%rlilia(10, 4) = transfer(int(z'c02719999999999a', int64), 0.0_real64)
    shortwave%rlilia(10, 5) = transfer(int(z'40216acd9e83e426', int64), 0.0_real64)
    shortwave%rlilia(11, 1) = transfer(int(z'bfca2339c0ebedfa', int64), 0.0_real64)
    shortwave%rlilia(11, 2) = transfer(int(z'3f6e727c1e5e8fd8', int64), 0.0_real64)
    shortwave%rlilia(11, 3) = transfer(int(z'40136d288ce703b0', int64), 0.0_real64)
    shortwave%rlilia(11, 4) = transfer(int(z'c027f1a9fbe76c8b', int64), 0.0_real64)
    shortwave%rlilia(11, 5) = transfer(int(z'402144d013a92a30', int64), 0.0_real64)
    shortwave%rlilia(12, 1) = transfer(int(z'bfc1f7a4e7ab7564', int64), 0.0_real64)
    shortwave%rlilia(12, 2) = transfer(int(z'3f66fc3067a6d846', int64), 0.0_real64)
    shortwave%rlilia(12, 3) = transfer(int(z'400bf9a6b50b0f28', int64), 0.0_real64)
    shortwave%rlilia(12, 4) = transfer(int(z'c00b04189374bc6a', int64), 0.0_real64)
    shortwave%rlilia(12, 5) = transfer(int(z'c002d532617c1bda', int64), 0.0_real64)
    shortwave%rlilia(13, 1) = transfer(int(z'bfc1f7a4e7ab7564', int64), 0.0_real64)
    shortwave%rlilia(13, 2) = transfer(int(z'3f66fc3067a6d846', int64), 0.0_real64)
    shortwave%rlilia(13, 3) = transfer(int(z'400bf9a6b50b0f28', int64), 0.0_real64)
    shortwave%rlilia(13, 4) = transfer(int(z'c00b04189374bc6a', int64), 0.0_real64)
    shortwave%rlilia(13, 5) = transfer(int(z'c002d532617c1bda', int64), 0.0_real64)
    shortwave%rlilia(14, 1) = transfer(int(z'bfc1f7a4e7ab7564', int64), 0.0_real64)
    shortwave%rlilia(14, 2) = transfer(int(z'3f66fc3067a6d846', int64), 0.0_real64)
    shortwave%rlilia(14, 3) = transfer(int(z'400bf9a6b50b0f28', int64), 0.0_real64)
    shortwave%rlilia(14, 4) = transfer(int(z'c00b04189374bc6a', int64), 0.0_real64)
    shortwave%rlilia(14, 5) = transfer(int(z'c002d532617c1bda', int64), 0.0_real64)
    shortwave%rlilia(15, 1) = transfer(int(z'bfc1f7a4e7ab7564', int64), 0.0_real64)
    shortwave%rlilia(15, 2) = transfer(int(z'3f66fc3067a6d846', int64), 0.0_real64)
    shortwave%rlilia(15, 3) = transfer(int(z'400bf9a6b50b0f28', int64), 0.0_real64)
    shortwave%rlilia(15, 4) = transfer(int(z'c00b04189374bc6a', int64), 0.0_real64)
    shortwave%rlilia(15, 5) = transfer(int(z'c002d532617c1bda', int64), 0.0_real64)
    shortwave%rlilia(16, 1) = transfer(int(z'bfc1f7a4e7ab7564', int64), 0.0_real64)
    shortwave%rlilia(16, 2) = transfer(int(z'3f66fc3067a6d846', int64), 0.0_real64)
    shortwave%rlilia(16, 3) = transfer(int(z'400bf9a6b50b0f28', int64), 0.0_real64)
    shortwave%rlilia(16, 4) = transfer(int(z'c00b04189374bc6a', int64), 0.0_real64)
    shortwave%rlilia(16, 5) = transfer(int(z'c002d532617c1bda', int64), 0.0_real64)
    shortwave%rlilib(1, 1) = transfer(int(z'3fe85aee631f8a09', int64), 0.0_real64)
    shortwave%rlilib(1, 2) = transfer(int(z'3fe2415f45e0b4e1', int64), 0.0_real64)
    shortwave%rlilib(1, 3) = transfer(int(z'bf911f4f50a02b84', int64), 0.0_real64)
    shortwave%rlilib(1, 4) = transfer(int(z'3f32467e94858896', int64), 0.0_real64)
    shortwave%rlilib(2, 1) = transfer(int(z'3fe09b66f9335d25', int64), 0.0_real64)
    shortwave%rlilib(2, 2) = transfer(int(z'3feba1f4b1ee2435', int64), 0.0_real64)
    shortwave%rlilib(2, 3) = transfer(int(z'bf67d680aab54ad0', int64), 0.0_real64)
    shortwave%rlilib(2, 4) = transfer(int(z'3f108c506c0f58f5', int64), 0.0_real64)
    shortwave%rlilib(3, 1) = transfer(int(z'3fe04ef88b977857', int64), 0.0_real64)
    shortwave%rlilib(3, 2) = transfer(int(z'3fe85696e58a32f4', int64), 0.0_real64)
    shortwave%rlilib(3, 3) = transfer(int(z'bf599bb2788db057', int64), 0.0_real64)
    shortwave%rlilib(3, 4) = transfer(int(z'3efb8516aabc56b3', int64), 0.0_real64)
    shortwave%rlilib(4, 1) = transfer(int(z'3fe1a858793dd97f', int64), 0.0_real64)
    shortwave%rlilib(4, 2) = transfer(int(z'3fe50f51ac9afe1e', int64), 0.0_real64)
    shortwave%rlilib(4, 3) = transfer(int(z'bf711bb1366e5116', int64), 0.0_real64)
    shortwave%rlilib(4, 4) = transfer(int(z'3f10d74656034a6b', int64), 0.0_real64)
    shortwave%rlilib(5, 1) = transfer(int(z'3fe37c1bda5119ce', int64), 0.0_real64)
    shortwave%rlilib(5, 2) = transfer(int(z'3fe30c49ba5e353f', int64), 0.0_real64)
    shortwave%rlilib(5, 3) = transfer(int(z'bf7e89de3ab35a35', int64), 0.0_real64)
    shortwave%rlilib(5, 4) = transfer(int(z'3f1ed1fd384f7cc0', int64), 0.0_real64)
    shortwave%rlilib(6, 1) = transfer(int(z'3fdfdd1a21ea3593', int64), 0.0_real64)
    shortwave%rlilib(6, 2) = transfer(int(z'3fe7ddaceee0f3cb', int64), 0.0_real64)
    shortwave%rlilib(6, 3) = transfer(int(z'bf6e9ef1c82ed85b', int64), 0.0_real64)
    shortwave%rlilib(6, 4) = transfer(int(z'3f17bd0b0dd02242', int64), 0.0_real64)
    shortwave%rlilib(7, 1) = transfer(int(z'3fa7b7a5f41aef70', int64), 0.0_real64)
    shortwave%rlilib(7, 2) = transfer(int(z'3ff035a858793dd9', int64), 0.0_real64)
    shortwave%rlilib(7, 3) = transfer(int(z'3f9323fee2c98e54', int64), 0.0_real64)
    shortwave%rlilib(7, 4) = transfer(int(z'bf2cb3bfe08032eb', int64), 0.0_real64)
    shortwave%rlilib(8, 1) = transfer(int(z'bfa6327ed84d338f', int64), 0.0_real64)
    shortwave%rlilib(8, 2) = transfer(int(z'3fe91af3a14cec42', int64), 0.0_real64)
    shortwave%rlilib(8, 3) = transfer(int(z'3f9b1572580c3090', int64), 0.0_real64)
    shortwave%rlilib(8, 4) = transfer(int(z'bf37d863d9c42c14', int64), 0.0_real64)
    shortwave%rlilib(9, 1) = transfer(int(z'bf9bae89eba6aca8', int64), 0.0_real64)
    shortwave%rlilib(9, 2) = transfer(int(z'3fe1826aa8eb4635', int64), 0.0_real64)
    shortwave%rlilib(9, 3) = transfer(int(z'3f9c929aa1d755bd', int64), 0.0_real64)
    shortwave%rlilib(9, 4) = transfer(int(z'bf3aeb12ddfe2285', int64), 0.0_real64)
    shortwave%rlilib(10, 1) = transfer(int(z'3fbdaee631f8a090', int64), 0.0_real64)
    shortwave%rlilib(10, 2) = transfer(int(z'3fd38ec95bff0457', int64), 0.0_real64)
    shortwave%rlilib(10, 3) = transfer(int(z'3f9745bf26f1dc51', int64), 0.0_real64)
    shortwave%rlilib(10, 4) = transfer(int(z'bf379d2a9db86232', int64), 0.0_real64)
    shortwave%rlilib(11, 1) = transfer(int(z'bf8e3c968943e100', int64), 0.0_real64)
    shortwave%rlilib(11, 2) = transfer(int(z'3fd221c044284dfd', int64), 0.0_real64)
    shortwave%rlilib(11, 3) = transfer(int(z'3f981450efdc9c4e', int64), 0.0_real64)
    shortwave%rlilib(11, 4) = transfer(int(z'bf360f8be424574d', int64), 0.0_real64)
    shortwave%rlilib(12, 1) = transfer(int(z'3f7be03056dfe0a6', int64), 0.0_real64)
    shortwave%rlilib(12, 2) = transfer(int(z'3faea2f48c2e770c', int64), 0.0_real64)
    shortwave%rlilib(12, 3) = transfer(int(z'3f95a1cac083126f', int64), 0.0_real64)
    shortwave%rlilib(12, 4) = transfer(int(z'bf337d8b4619bfc5', int64), 0.0_real64)
    shortwave%rlilib(13, 1) = transfer(int(z'3f7be03056dfe0a6', int64), 0.0_real64)
    shortwave%rlilib(13, 2) = transfer(int(z'3faea2f48c2e770c', int64), 0.0_real64)
    shortwave%rlilib(13, 3) = transfer(int(z'3f95a1cac083126f', int64), 0.0_real64)
    shortwave%rlilib(13, 4) = transfer(int(z'bf337d8b4619bfc5', int64), 0.0_real64)
    shortwave%rlilib(14, 1) = transfer(int(z'3f7be03056dfe0a6', int64), 0.0_real64)
    shortwave%rlilib(14, 2) = transfer(int(z'3faea2f48c2e770c', int64), 0.0_real64)
    shortwave%rlilib(14, 3) = transfer(int(z'3f95a1cac083126f', int64), 0.0_real64)
    shortwave%rlilib(14, 4) = transfer(int(z'bf337d8b4619bfc5', int64), 0.0_real64)
    shortwave%rlilib(15, 1) = transfer(int(z'3f7be03056dfe0a6', int64), 0.0_real64)
    shortwave%rlilib(15, 2) = transfer(int(z'3faea2f48c2e770c', int64), 0.0_real64)
    shortwave%rlilib(15, 3) = transfer(int(z'3f95a1cac083126f', int64), 0.0_real64)
    shortwave%rlilib(15, 4) = transfer(int(z'bf337d8b4619bfc5', int64), 0.0_real64)
    shortwave%rlilib(16, 1) = transfer(int(z'3f7be03056dfe0a6', int64), 0.0_real64)
    shortwave%rlilib(16, 2) = transfer(int(z'3faea2f48c2e770c', int64), 0.0_real64)
    shortwave%rlilib(16, 3) = transfer(int(z'3f95a1cac083126f', int64), 0.0_real64)
    shortwave%rlilib(16, 4) = transfer(int(z'bf337d8b4619bfc5', int64), 0.0_real64)
    shortwave%rfulio(1, 1) = transfer(int(z'bf7fc08fa7a85016', int64), 0.0_real64)
    shortwave%rfulio(1, 2) = transfer(int(z'40127ef9db22d0e5', int64), 0.0_real64)
    shortwave%rfulio(1, 3) = transfer(int(z'c0450147ae147ae1', int64), 0.0_real64)
    shortwave%rfulio(2, 1) = transfer(int(z'bf91d3ed527e5215', int64), 0.0_real64)
    shortwave%rfulio(2, 2) = transfer(int(z'401629fbe76c8b44', int64), 0.0_real64)
    shortwave%rfulio(2, 3) = transfer(int(z'c04d35c28f5c28f6', int64), 0.0_real64)
    shortwave%rfulio(3, 1) = transfer(int(z'bf9172ef0ae53650', int64), 0.0_real64)
    shortwave%rfulio(3, 2) = transfer(int(z'401351eb851eb852', int64), 0.0_real64)
    shortwave%rfulio(3, 3) = transfer(int(z'4030451eb851eb85', int64), 0.0_real64)
    shortwave%rfulio(4, 1) = transfer(int(z'bf87928e0c9d9d34', int64), 0.0_real64)
    shortwave%rfulio(4, 2) = transfer(int(z'4010ba5e353f7cee', int64), 0.0_real64)
    shortwave%rfulio(4, 3) = transfer(int(z'403f2147ae147ae1', int64), 0.0_real64)
    shortwave%rfulio(5, 1) = transfer(int(z'bf850331e3a7daa5', int64), 0.0_real64)
    shortwave%rfulio(5, 2) = transfer(int(z'40106b851eb851ec', int64), 0.0_real64)
    shortwave%rfulio(5, 3) = transfer(int(z'40305c28f5c28f5c', int64), 0.0_real64)
    shortwave%rfulio(6, 1) = transfer(int(z'bf80fc71d6063172', int64), 0.0_real64)
    shortwave%rfulio(6, 2) = transfer(int(z'400f666666666666', int64), 0.0_real64)
    shortwave%rfulio(6, 3) = transfer(int(z'3ff50a3d70a3d70a', int64), 0.0_real64)
    shortwave%rfulio(7, 1) = transfer(int(z'bf879d0a67620ee9', int64), 0.0_real64)
    shortwave%rfulio(7, 2) = transfer(int(z'40106f9db22d0e56', int64), 0.0_real64)
    shortwave%rfulio(7, 3) = transfer(int(z'403151eb851eb852', int64), 0.0_real64)
    shortwave%rfulio(8, 1) = transfer(int(z'bf83ade225fa658c', int64), 0.0_real64)
    shortwave%rfulio(8, 2) = transfer(int(z'400e24dd2f1a9fbe', int64), 0.0_real64)
    shortwave%rfulio(8, 3) = transfer(int(z'40410e147ae147ae', int64), 0.0_real64)
    shortwave%rfulio(9, 1) = transfer(int(z'bf828e92d55a3a08', int64), 0.0_real64)
    shortwave%rfulio(9, 2) = transfer(int(z'400ded916872b021', int64), 0.0_real64)
    shortwave%rfulio(9, 3) = transfer(int(z'403a7ae147ae147b', int64), 0.0_real64)
    shortwave%rfulio(10, 1) = transfer(int(z'bf814983d790752e', int64), 0.0_real64)
    shortwave%rfulio(10, 2) = transfer(int(z'400db851eb851eb8', int64), 0.0_real64)
    shortwave%rfulio(10, 3) = transfer(int(z'40337ae147ae147b', int64), 0.0_real64)
    shortwave%rfulio(11, 1) = transfer(int(z'bf809070fbeb9e49', int64), 0.0_real64)
    shortwave%rfulio(11, 2) = transfer(int(z'400dbc6a7ef9db23', int64), 0.0_real64)
    shortwave%rfulio(11, 3) = transfer(int(z'40312b851eb851ec', int64), 0.0_real64)
    shortwave%rfulio(12, 1) = transfer(int(z'bf809070fbeb9e49', int64), 0.0_real64)
    shortwave%rfulio(12, 2) = transfer(int(z'400dbc6a7ef9db23', int64), 0.0_real64)
    shortwave%rfulio(12, 3) = transfer(int(z'40312b851eb851ec', int64), 0.0_real64)
    shortwave%rfulio(13, 1) = transfer(int(z'bf7fd36f7e3d1cc1', int64), 0.0_real64)
    shortwave%rfulio(13, 2) = transfer(int(z'400ddf3b645a1cac', int64), 0.0_real64)
    shortwave%rfulio(13, 3) = transfer(int(z'4027b33333333333', int64), 0.0_real64)
    shortwave%rfulio(14, 1) = transfer(int(z'bf7b43526527a205', int64), 0.0_real64)
    shortwave%rfulio(14, 2) = transfer(int(z'400d7ced916872b0', int64), 0.0_real64)
    shortwave%rfulio(14, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rfulio(15, 1) = transfer(int(z'bf7b43526527a205', int64), 0.0_real64)
    shortwave%rfulio(15, 2) = transfer(int(z'400d7ced916872b0', int64), 0.0_real64)
    shortwave%rfulio(15, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rfulio(16, 1) = transfer(int(z'bf7b43526527a205', int64), 0.0_real64)
    shortwave%rfulio(16, 2) = transfer(int(z'400d7ced916872b0', int64), 0.0_real64)
    shortwave%rfulio(16, 3) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    shortwave%rfueta(1, 1) = transfer(int(z'3f7426a9e2e7ec38', int64), 0.0_real64)
    shortwave%rfueta(1, 2) = transfer(int(z'40029f36ac647779', int64), 0.0_real64)
    shortwave%rfueta(1, 3) = transfer(int(z'c02bd13165d39970', int64), 0.0_real64)
    shortwave%rfueta(2, 1) = transfer(int(z'3f6b3e9da824aa62', int64), 0.0_real64)
    shortwave%rfueta(2, 2) = transfer(int(z'4004cf95d4e8fb01', int64), 0.0_real64)
    shortwave%rfueta(2, 3) = transfer(int(z'c0331894c447c30d', int64), 0.0_real64)
    shortwave%rfueta(3, 1) = transfer(int(z'bf8b5682c3943ee7', int64), 0.0_real64)
    shortwave%rfueta(3, 2) = transfer(int(z'40102cdc011d3672', int64), 0.0_real64)
    shortwave%rfueta(3, 3) = transfer(int(z'c035b5d590c0ad04', int64), 0.0_real64)
    shortwave%rfueta(4, 1) = transfer(int(z'bf838168fecfb1e2', int64), 0.0_real64)
    shortwave%rfueta(4, 2) = transfer(int(z'400cb3b213e3e293', int64), 0.0_real64)
    shortwave%rfueta(4, 3) = transfer(int(z'c02560be0ded288d', int64), 0.0_real64)
    shortwave%rfueta(5, 1) = transfer(int(z'bf710978e0cd9be6', int64), 0.0_real64)
    shortwave%rfueta(5, 2) = transfer(int(z'400860ebedfa43fe', int64), 0.0_real64)
    shortwave%rfueta(5, 3) = transfer(int(z'c0143f0bae89eba7', int64), 0.0_real64)
    shortwave%rfueta(6, 1) = transfer(int(z'bf5bb738077ac007', int64), 0.0_real64)
    shortwave%rfueta(6, 2) = transfer(int(z'40062044ae85b9e9', int64), 0.0_real64)
    shortwave%rfueta(6, 3) = transfer(int(z'c020a97d2849cb25', int64), 0.0_real64)
    shortwave%rfueta(7, 1) = transfer(int(z'bf8125b43bfeab39', int64), 0.0_real64)
    shortwave%rfueta(7, 2) = transfer(int(z'400ba3e07a28bb0a', int64), 0.0_real64)
    shortwave%rfueta(7, 3) = transfer(int(z'c02e557689ca18bd', int64), 0.0_real64)
    shortwave%rfueta(8, 1) = transfer(int(z'bf80bff22f182cae', int64), 0.0_real64)
    shortwave%rfueta(8, 2) = transfer(int(z'400b35bff04577d9', int64), 0.0_real64)
    shortwave%rfueta(8, 3) = transfer(int(z'c021a029f16b11c7', int64), 0.0_real64)
    shortwave%rfueta(9, 1) = transfer(int(z'bf743869280cb977', int64), 0.0_real64)
    shortwave%rfueta(9, 2) = transfer(int(z'4008b3bd9cae2110', int64), 0.0_real64)
    shortwave%rfueta(9, 3) = transfer(int(z'c00f12f7f498c3b1', int64), 0.0_real64)
    shortwave%rfueta(10, 1) = transfer(int(z'bf68dbf5f95ab923', int64), 0.0_real64)
    shortwave%rfueta(10, 2) = transfer(int(z'40073349be8ff328', int64), 0.0_real64)
    shortwave%rfueta(10, 3) = transfer(int(z'bffd993c46d82ba6', int64), 0.0_real64)
    shortwave%rfueta(11, 1) = transfer(int(z'bf68dbf5f95ab923', int64), 0.0_real64)
    shortwave%rfueta(11, 2) = transfer(int(z'40073349be8ff328', int64), 0.0_real64)
    shortwave%rfueta(11, 3) = transfer(int(z'bffd993c46d82ba6', int64), 0.0_real64)
    shortwave%rfueta(12, 1) = transfer(int(z'bf6431f97fe6c8aa', int64), 0.0_real64)
    shortwave%rfueta(12, 2) = transfer(int(z'4006aa5df2239e6b', int64), 0.0_real64)
    shortwave%rfueta(12, 3) = transfer(int(z'bfdb0e74a2694bf4', int64), 0.0_real64)
    shortwave%rfueta(13, 1) = transfer(int(z'bf62ea130c54d5a3', int64), 0.0_real64)
    shortwave%rfueta(13, 2) = transfer(int(z'400683137b07075b', int64), 0.0_real64)
    shortwave%rfueta(13, 3) = transfer(int(z'3ff127c6b8b69553', int64), 0.0_real64)
    shortwave%rfueta(14, 1) = transfer(int(z'bf62ea130c54d5a3', int64), 0.0_real64)
    shortwave%rfueta(14, 2) = transfer(int(z'400683137b07075b', int64), 0.0_real64)
    shortwave%rfueta(14, 3) = transfer(int(z'3ff127c6b8b69553', int64), 0.0_real64)
    shortwave%rfueta(15, 1) = transfer(int(z'bf62ea130c54d5a3', int64), 0.0_real64)
    shortwave%rfueta(15, 2) = transfer(int(z'400683137b07075b', int64), 0.0_real64)
    shortwave%rfueta(15, 3) = transfer(int(z'3ff127c6b8b69553', int64), 0.0_real64)
    shortwave%rfueta(16, 1) = transfer(int(z'bf62ea130c54d5a3', int64), 0.0_real64)
    shortwave%rfueta(16, 2) = transfer(int(z'400683137b07075b', int64), 0.0_real64)
    shortwave%rfueta(16, 3) = transfer(int(z'3ff127c6b8b69553', int64), 0.0_real64)
    shortwave%rfuetb(1, 1) = transfer(int(z'3fec62212797f47e', int64), 0.0_real64)
    shortwave%rfuetb(1, 2) = transfer(int(z'3f95b14836fb69c3', int64), 0.0_real64)
    shortwave%rfuetb(1, 3) = transfer(int(z'bf323a76a8bbbbfc', int64), 0.0_real64)
    shortwave%rfuetb(1, 4) = transfer(int(z'3eb25d1ba57557ad', int64), 0.0_real64)
    shortwave%rfuetb(2, 1) = transfer(int(z'3fc9abe0c3fa9634', int64), 0.0_real64)
    shortwave%rfuetb(2, 2) = transfer(int(z'3f95d685076650c2', int64), 0.0_real64)
    shortwave%rfuetb(2, 3) = transfer(int(z'bf26f38e36f7d45c', int64), 0.0_real64)
    shortwave%rfuetb(2, 4) = transfer(int(z'3ea1f8ab9120c3fa', int64), 0.0_real64)
    shortwave%rfuetb(3, 1) = transfer(int(z'3fd33943830c8f5a', int64), 0.0_real64)
    shortwave%rfuetb(3, 2) = transfer(int(z'3f9501f5ce78c96a', int64), 0.0_real64)
    shortwave%rfuetb(3, 3) = transfer(int(z'bf2951a7ebd67828', int64), 0.0_real64)
    shortwave%rfuetb(3, 4) = transfer(int(z'3ea616c7d37b6b41', int64), 0.0_real64)
    shortwave%rfuetb(4, 1) = transfer(int(z'3fee908a265f0f5a', int64), 0.0_real64)
    shortwave%rfuetb(4, 2) = transfer(int(z'3f8ad315105d7049', int64), 0.0_real64)
    shortwave%rfuetb(4, 3) = transfer(int(z'bf2782a369ef356c', int64), 0.0_real64)
    shortwave%rfuetb(4, 4) = transfer(int(z'3ea88a27e8933ef8', int64), 0.0_real64)
    shortwave%rfuetb(5, 1) = transfer(int(z'3ff776b4c7f34938', int64), 0.0_real64)
    shortwave%rfuetb(5, 2) = transfer(int(z'bf61714f81253725', int64), 0.0_real64)
    shortwave%rfuetb(5, 3) = transfer(int(z'beec8e3205ac546c', int64), 0.0_real64)
    shortwave%rfuetb(5, 4) = transfer(int(z'3e800558c3949f77', int64), 0.0_real64)
    shortwave%rfuetb(6, 1) = transfer(int(z'3ff320d4562e09ff', int64), 0.0_real64)
    shortwave%rfuetb(6, 2) = transfer(int(z'3f6b72c04486cb3e', int64), 0.0_real64)
    shortwave%rfuetb(6, 3) = transfer(int(z'bf0b9d3e0ba2cf39', int64), 0.0_real64)
    shortwave%rfuetb(6, 4) = transfer(int(z'3e8df9d32f3fb760', int64), 0.0_real64)
    shortwave%rfuetb(7, 1) = transfer(int(z'3fe14f7dec94e931', int64), 0.0_real64)
    shortwave%rfuetb(7, 2) = transfer(int(z'3f93f6e34bbf4626', int64), 0.0_real64)
    shortwave%rfuetb(7, 3) = transfer(int(z'bf2ae1b48eb323be', int64), 0.0_real64)
    shortwave%rfuetb(7, 4) = transfer(int(z'3ea8b636424bd974', int64), 0.0_real64)
    shortwave%rfuetb(8, 1) = transfer(int(z'3fe2cc3ed2a3a663', int64), 0.0_real64)
    shortwave%rfuetb(8, 2) = transfer(int(z'3f933777bb786699', int64), 0.0_real64)
    shortwave%rfuetb(8, 3) = transfer(int(z'bf2ad0ae064cc60d', int64), 0.0_real64)
    shortwave%rfuetb(8, 4) = transfer(int(z'3ea9331c0e9e78ed', int64), 0.0_real64)
    shortwave%rfuetb(9, 1) = transfer(int(z'3fe6e32492867fe1', int64), 0.0_real64)
    shortwave%rfuetb(9, 2) = transfer(int(z'3f909b4743b66329', int64), 0.0_real64)
    shortwave%rfuetb(9, 3) = transfer(int(z'bf287dcb13009134', int64), 0.0_real64)
    shortwave%rfuetb(9, 4) = transfer(int(z'3ea7c096f2bcf885', int64), 0.0_real64)
    shortwave%rfuetb(10, 1) = transfer(int(z'3fec5c1b1e697793', int64), 0.0_real64)
    shortwave%rfuetb(10, 2) = transfer(int(z'3f891e976fc8bac4', int64), 0.0_real64)
    shortwave%rfuetb(10, 3) = transfer(int(z'bf23f6985265b63a', int64), 0.0_real64)
    shortwave%rfuetb(10, 4) = transfer(int(z'3ea422ba1b304a36', int64), 0.0_real64)
    shortwave%rfuetb(11, 1) = transfer(int(z'3fec5c1b1e697793', int64), 0.0_real64)
    shortwave%rfuetb(11, 2) = transfer(int(z'3f891e976fc8bac4', int64), 0.0_real64)
    shortwave%rfuetb(11, 3) = transfer(int(z'bf23f6985265b63a', int64), 0.0_real64)
    shortwave%rfuetb(11, 4) = transfer(int(z'3ea422ba1b304a36', int64), 0.0_real64)
    shortwave%rfuetb(12, 1) = transfer(int(z'3fe7c5cd33fad950', int64), 0.0_real64)
    shortwave%rfuetb(12, 2) = transfer(int(z'3f8a34cb63c11a92', int64), 0.0_real64)
    shortwave%rfuetb(12, 3) = transfer(int(z'bf223e1dac6a2a0b', int64), 0.0_real64)
    shortwave%rfuetb(12, 4) = transfer(int(z'3ea161acea8d3fd4', int64), 0.0_real64)
    shortwave%rfuetb(13, 1) = transfer(int(z'3fdbd146af10fa23', int64), 0.0_real64)
    shortwave%rfuetb(13, 2) = transfer(int(z'3f91a0b23ca8a7d4', int64), 0.0_real64)
    shortwave%rfuetb(13, 3) = transfer(int(z'bf2546a5603438bb', int64), 0.0_real64)
    shortwave%rfuetb(13, 4) = transfer(int(z'3ea2a94fd76151e0', int64), 0.0_real64)
    shortwave%rfuetb(14, 1) = transfer(int(z'3fdbd146af10fa23', int64), 0.0_real64)
    shortwave%rfuetb(14, 2) = transfer(int(z'3f91a0b23ca8a7d4', int64), 0.0_real64)
    shortwave%rfuetb(14, 3) = transfer(int(z'bf2546a5603438bb', int64), 0.0_real64)
    shortwave%rfuetb(14, 4) = transfer(int(z'3ea2a94fd76151e0', int64), 0.0_real64)
    shortwave%rfuetb(15, 1) = transfer(int(z'3fdbd146af10fa23', int64), 0.0_real64)
    shortwave%rfuetb(15, 2) = transfer(int(z'3f91a0b23ca8a7d4', int64), 0.0_real64)
    shortwave%rfuetb(15, 3) = transfer(int(z'bf2546a5603438bb', int64), 0.0_real64)
    shortwave%rfuetb(15, 4) = transfer(int(z'3ea2a94fd76151e0', int64), 0.0_real64)
    shortwave%rfuetb(16, 1) = transfer(int(z'3fdbd146af10fa23', int64), 0.0_real64)
    shortwave%rfuetb(16, 2) = transfer(int(z'3f91a0b23ca8a7d4', int64), 0.0_real64)
    shortwave%rfuetb(16, 3) = transfer(int(z'bf2546a5603438bb', int64), 0.0_real64)
    shortwave%rfuetb(16, 4) = transfer(int(z'3ea2a94fd76151e0', int64), 0.0_real64)
    shortwave%rfuetc(1, 1) = transfer(int(z'3fdface4cff8d138', int64), 0.0_real64)
    shortwave%rfuetc(1, 2) = transfer(int(z'3f884af7cafd3edb', int64), 0.0_real64)
    shortwave%rfuetc(1, 3) = transfer(int(z'bf209d75050a8ce9', int64), 0.0_real64)
    shortwave%rfuetc(1, 4) = transfer(int(z'3e9ee4e141c6395a', int64), 0.0_real64)
    shortwave%rfuetc(2, 1) = transfer(int(z'3fe60d7243ea3a9c', int64), 0.0_real64)
    shortwave%rfuetc(2, 2) = transfer(int(z'3f795d13c61f4d67', int64), 0.0_real64)
    shortwave%rfuetc(2, 3) = transfer(int(z'bf10eee80e1c7c7b', int64), 0.0_real64)
    shortwave%rfuetc(2, 4) = transfer(int(z'3e905aaba977c7c8', int64), 0.0_real64)
    shortwave%rfuetc(3, 1) = transfer(int(z'3fe73bc9daaa0522', int64), 0.0_real64)
    shortwave%rfuetc(3, 2) = transfer(int(z'3f65d3836ca8ed16', int64), 0.0_real64)
    shortwave%rfuetc(3, 3) = transfer(int(z'beea3cfc3993cbd8', int64), 0.0_real64)
    shortwave%rfuetc(3, 4) = transfer(int(z'3e58168c38d99da4', int64), 0.0_real64)
    shortwave%rfuetc(4, 1) = transfer(int(z'3fe79026beb0aa57', int64), 0.0_real64)
    shortwave%rfuetc(4, 2) = transfer(int(z'3f73a758b8c29885', int64), 0.0_real64)
    shortwave%rfuetc(4, 3) = transfer(int(z'bf07236bed9f6254', int64), 0.0_real64)
    shortwave%rfuetc(4, 4) = transfer(int(z'3e847a8500e48018', int64), 0.0_real64)
    shortwave%rfuetc(5, 1) = transfer(int(z'3fe98c828f91d8db', int64), 0.0_real64)
    shortwave%rfuetc(5, 2) = transfer(int(z'3f704a4f372868dd', int64), 0.0_real64)
    shortwave%rfuetc(5, 3) = transfer(int(z'bf077232009408bb', int64), 0.0_real64)
    shortwave%rfuetc(5, 4) = transfer(int(z'3e86bfb284d7562d', int64), 0.0_real64)
    shortwave%rfuetc(6, 1) = transfer(int(z'3febb90b84988095', int64), 0.0_real64)
    shortwave%rfuetc(6, 2) = transfer(int(z'3f66ebb160d7fe7c', int64), 0.0_real64)
    shortwave%rfuetc(6, 3) = transfer(int(z'bf00b588a43020dc', int64), 0.0_real64)
    shortwave%rfuetc(6, 4) = transfer(int(z'3e80564c5bf10cbe', int64), 0.0_real64)
    shortwave%rfuetc(7, 1) = transfer(int(z'3fec80064a9cdc44', int64), 0.0_real64)
    shortwave%rfuetc(7, 2) = transfer(int(z'3f5f2ee387124744', int64), 0.0_real64)
    shortwave%rfuetc(7, 3) = transfer(int(z'bef22d77dd044616', int64), 0.0_real64)
    shortwave%rfuetc(7, 4) = transfer(int(z'3e6f6f25f779ff92', int64), 0.0_real64)
    shortwave%rfuetc(8, 1) = transfer(int(z'3feb8cfcd324d5a2', int64), 0.0_real64)
    shortwave%rfuetc(8, 2) = transfer(int(z'3f6206aae9f9028b', int64), 0.0_real64)
    shortwave%rfuetc(8, 3) = transfer(int(z'bef254889bda0b86', int64), 0.0_real64)
    shortwave%rfuetc(8, 4) = transfer(int(z'3e6bcaafd5c5d66a', int64), 0.0_real64)
    shortwave%rfuetc(9, 1) = transfer(int(z'3feb45e40fdf7114', int64), 0.0_real64)
    shortwave%rfuetc(9, 2) = transfer(int(z'3f64ac6dedd56c3f', int64), 0.0_real64)
    shortwave%rfuetc(9, 3) = transfer(int(z'bef689343ec7762c', int64), 0.0_real64)
    shortwave%rfuetc(9, 4) = transfer(int(z'3e71f1f16c806035', int64), 0.0_real64)
    shortwave%rfuetc(10, 1) = transfer(int(z'3febf92c061847f5', int64), 0.0_real64)
    shortwave%rfuetc(10, 2) = transfer(int(z'3f641d5dab4e4453', int64), 0.0_real64)
    shortwave%rfuetc(10, 3) = transfer(int(z'bef9c348e030bc3c', int64), 0.0_real64)
    shortwave%rfuetc(10, 4) = transfer(int(z'3e77323406d4086d', int64), 0.0_real64)
    shortwave%rfuetc(11, 1) = transfer(int(z'3febf92c061847f5', int64), 0.0_real64)
    shortwave%rfuetc(11, 2) = transfer(int(z'3f641d5dab4e4453', int64), 0.0_real64)
    shortwave%rfuetc(11, 3) = transfer(int(z'bef9c348e030bc3c', int64), 0.0_real64)
    shortwave%rfuetc(11, 4) = transfer(int(z'3e77323406d4086d', int64), 0.0_real64)
    shortwave%rfuetc(12, 1) = transfer(int(z'3feb1d03b165683a', int64), 0.0_real64)
    shortwave%rfuetc(12, 2) = transfer(int(z'3f64f89c4d41ebf7', int64), 0.0_real64)
    shortwave%rfuetc(12, 3) = transfer(int(z'bef6e30887eac3ce', int64), 0.0_real64)
    shortwave%rfuetc(12, 4) = transfer(int(z'3e7277e25a890148', int64), 0.0_real64)
    shortwave%rfuetc(13, 1) = transfer(int(z'3fe97b0e94177999', int64), 0.0_real64)
    shortwave%rfuetc(13, 2) = transfer(int(z'3f689ac5577c5783', int64), 0.0_real64)
    shortwave%rfuetc(13, 3) = transfer(int(z'bef5d5d5e41073e0', int64), 0.0_real64)
    shortwave%rfuetc(13, 4) = transfer(int(z'3e6ccfb9293ece9a', int64), 0.0_real64)
    shortwave%rfuetc(14, 1) = transfer(int(z'3fe97b0e94177999', int64), 0.0_real64)
    shortwave%rfuetc(14, 2) = transfer(int(z'3f689ac5577c5783', int64), 0.0_real64)
    shortwave%rfuetc(14, 3) = transfer(int(z'bef5d5d5e41073e0', int64), 0.0_real64)
    shortwave%rfuetc(14, 4) = transfer(int(z'3e6ccfb9293ece9a', int64), 0.0_real64)
    shortwave%rfuetc(15, 1) = transfer(int(z'3fe97b0e94177999', int64), 0.0_real64)
    shortwave%rfuetc(15, 2) = transfer(int(z'3f689ac5577c5783', int64), 0.0_real64)
    shortwave%rfuetc(15, 3) = transfer(int(z'bef5d5d5e41073e0', int64), 0.0_real64)
    shortwave%rfuetc(15, 4) = transfer(int(z'3e6ccfb9293ece9a', int64), 0.0_real64)
    shortwave%rfuetc(16, 1) = transfer(int(z'3fe97b0e94177999', int64), 0.0_real64)
    shortwave%rfuetc(16, 2) = transfer(int(z'3f689ac5577c5783', int64), 0.0_real64)
    shortwave%rfuetc(16, 3) = transfer(int(z'bef5d5d5e41073e0', int64), 0.0_real64)
    shortwave%rfuetc(16, 4) = transfer(int(z'3e6ccfb9293ece9a', int64), 0.0_real64)
    shortwave%rebcui(1) = transfer(int(z'3ff22d0e56041893', int64), 0.0_real64)
    shortwave%rebcui(2) = transfer(int(z'3ff56872b020c49c', int64), 0.0_real64)
    shortwave%rebcui(3) = transfer(int(z'3ff2a7ef9db22d0e', int64), 0.0_real64)
    shortwave%rebcui(4) = transfer(int(z'3ff2a7ef9db22d0e', int64), 0.0_real64)
    shortwave%rebcui(5) = transfer(int(z'3ff1e353f7ced917', int64), 0.0_real64)
    shortwave%rebcui(6) = transfer(int(z'3fe3333333333333', int64), 0.0_real64)
    shortwave%rebcuj(1) = transfer(int(z'3f6d7dbf487fcb92', int64), 0.0_real64)
    shortwave%rebcuj(2) = transfer(int(z'3f33a92a30553261', int64), 0.0_real64)
    shortwave%rebcuj(3) = transfer(int(z'3f5a36e2eb1c432d', int64), 0.0_real64)
    shortwave%rebcuj(4) = transfer(int(z'3f5a36e2eb1c432d', int64), 0.0_real64)
    shortwave%rebcuj(5) = transfer(int(z'3f60624dd2f1a9fc', int64), 0.0_real64)
    shortwave%rebcuj(6) = transfer(int(z'3f7bda5119ce075f', int64), 0.0_real64)
    shortwave%rebcug(1) = transfer(int(z'3fe6f9db22d0e560', int64), 0.0_real64)
    shortwave%rebcug(2) = transfer(int(z'3fe73b645a1cac08', int64), 0.0_real64)
    shortwave%rebcug(3) = transfer(int(z'3ff22d0e56041893', int64), 0.0_real64)
    shortwave%rebcug(4) = transfer(int(z'3ff51eb851eb851f', int64), 0.0_real64)
    shortwave%rebcug(5) = transfer(int(z'3ff8147ae147ae14', int64), 0.0_real64)
    shortwave%rebcug(6) = transfer(int(z'3ff4a3d70a3d70a4', int64), 0.0_real64)
    shortwave%rebcug(7) = transfer(int(z'3fed26e978d4fdf4', int64), 0.0_real64)
    shortwave%rebcug(8) = transfer(int(z'3fee5e353f7ced91', int64), 0.0_real64)
    shortwave%rebcug(9) = transfer(int(z'3ff05604189374bc', int64), 0.0_real64)
    shortwave%rebcug(10) = transfer(int(z'3ff316872b020c4a', int64), 0.0_real64)
    shortwave%rebcug(11) = transfer(int(z'3ff476c8b4395810', int64), 0.0_real64)
    shortwave%rebcug(12) = transfer(int(z'3fe4083126e978d5', int64), 0.0_real64)
    shortwave%rebcug(13) = transfer(int(z'3fe4b4395810624e', int64), 0.0_real64)
    shortwave%rebcug(14) = transfer(int(z'3fe5604189374bc7', int64), 0.0_real64)
    shortwave%rebcug(15) = transfer(int(z'3fe6147ae147ae14', int64), 0.0_real64)
    shortwave%rebcug(16) = transfer(int(z'3fe6147ae147ae14', int64), 0.0_real64)
    shortwave%rebcuh(1) = transfer(int(z'3f7c432ca57a786c', int64), 0.0_real64)
    shortwave%rebcuh(2) = transfer(int(z'3f789374bc6a7efa', int64), 0.0_real64)
    shortwave%rebcuh(3) = transfer(int(z'3f63a92a30553261', int64), 0.0_real64)
    shortwave%rebcuh(4) = transfer(int(z'3f3a36e2eb1c432d', int64), 0.0_real64)
    shortwave%rebcuh(5) = transfer(int(z'bf5a36e2eb1c432d', int64), 0.0_real64)
    shortwave%rebcuh(6) = transfer(int(z'3f33a92a30553261', int64), 0.0_real64)
    shortwave%rebcuh(7) = transfer(int(z'3f719ce075f6fd22', int64), 0.0_real64)
    shortwave%rebcuh(8) = transfer(int(z'3f6f212d77318fc5', int64), 0.0_real64)
    shortwave%rebcuh(9) = transfer(int(z'3f689374bc6a7efa', int64), 0.0_real64)
    shortwave%rebcuh(10) = transfer(int(z'3f554c985f06f694', int64), 0.0_real64)
    shortwave%rebcuh(11) = transfer(int(z'3f40624dd2f1a9fc', int64), 0.0_real64)
    shortwave%rebcuh(12) = transfer(int(z'3f761e4f765fd8ae', int64), 0.0_real64)
    shortwave%rebcuh(13) = transfer(int(z'3f754c985f06f694', int64), 0.0_real64)
    shortwave%rebcuh(14) = transfer(int(z'3f747ae147ae147b', int64), 0.0_real64)
    shortwave%rebcuh(15) = transfer(int(z'3f73a92a30553261', int64), 0.0_real64)
    shortwave%rebcuh(16) = transfer(int(z'3f73a92a30553261', int64), 0.0_real64)
    shortwave%reffia = transfer(int(z'4044000000000000', int64), 0.0_real64)

    do band = 1_int32, size(shortwave%raswca, kind=int32)
      source_coefficient = transfer(raswca_words(band), 0.0_real64)
      conversion_scale = 1.0e-2_real64
      converted_coefficient = source_coefficient*conversion_scale
      shortwave%raswca(band) = converted_coefficient
      shortwave%raswcb(band) = transfer(raswcb_words(band), 0.0_real64)
      shortwave%raswcc(band) = transfer(raswcc_words(band), 0.0_real64)
      shortwave%raswcd(band) = transfer(raswcd_words(band), 0.0_real64)
      shortwave%raswce(band) = transfer(raswce_words(band), 0.0_real64)
      source_coefficient = transfer(raswcf_words(band), 0.0_real64)
      conversion_scale = 1.0e-3_real64
      converted_coefficient = source_coefficient*conversion_scale
      shortwave%raswcf(band) = converted_coefficient
      shortwave%rkpnwca(band) = transfer(rkpnwca_words(band), 0.0_real64)
      shortwave%rkpnwcb(band) = transfer(rkpnwcb_words(band), 0.0_real64)
      shortwave%rkpnwcc(band) = transfer(rkpnwcc_words(band), 0.0_real64)
      shortwave%rkpnwcd(band) = transfer(rkpnwcd_words(band), 0.0_real64)
      shortwave%rkpnwce(band) = transfer(rkpnwce_words(band), 0.0_real64)
      shortwave%rkpnwcf(band) = transfer(rkpnwcf_words(band), 0.0_real64)
      shortwave%rkpnwcg(band) = transfer(rkpnwcg_words(band), 0.0_real64)
      shortwave%rkpnwch(band) = transfer(rkpnwch_words(band), 0.0_real64)
      shortwave%rebcua(band) = transfer(rebcua_words(band), 0.0_real64)
      shortwave%rebcub(band) = transfer(rebcub_words(band), 0.0_real64)
      shortwave%rebcuc(band) = transfer(rebcuc_words(band), 0.0_real64)
      shortwave%rebcud(band) = transfer(rebcud_words(band), 0.0_real64)
      shortwave%rebcue(band) = transfer(rebcue_words(band), 0.0_real64)
      shortwave%rebcuf(band) = transfer(rebcuf_words(band), 0.0_real64)
      shortwave%ryfwca(band) = transfer(ryfwca_words(band), 0.0_real64)
      shortwave%ryfwcb(band) = transfer(ryfwcb_words(band), 0.0_real64)
      shortwave%ryfwcc(band) = transfer(ryfwcc_words(band), 0.0_real64)
      shortwave%ryfwcd(band) = transfer(ryfwcd_words(band), 0.0_real64)
      shortwave%ryfwce(band) = transfer(ryfwce_words(band), 0.0_real64)
      shortwave%ryfwcf(band) = transfer(ryfwcf_words(band), 0.0_real64)
      shortwave%rflaa0(band) = transfer(rflaa0_words(band), 0.0_real64)
      shortwave%rflaa1(band) = transfer(rflaa1_words(band), 0.0_real64)
      shortwave%rflbb0(band) = transfer(rflbb0_words(band), 0.0_real64)
      shortwave%rflbb1(band) = transfer(rflbb1_words(band), 0.0_real64)
      shortwave%rflbb2(band) = transfer(rflbb2_words(band), 0.0_real64)
      shortwave%rflbb3(band) = transfer(rflbb3_words(band), 0.0_real64)
      shortwave%rflcc0(band) = transfer(rflcc0_words(band), 0.0_real64)
      shortwave%rflcc1(band) = transfer(rflcc1_words(band), 0.0_real64)
      shortwave%rflcc2(band) = transfer(rflcc2_words(band), 0.0_real64)
      shortwave%rflcc3(band) = transfer(rflcc3_words(band), 0.0_real64)
      shortwave%rfldd0(band) = transfer(rfldd0_words(band), 0.0_real64)
      shortwave%rfldd1(band) = transfer(rfldd1_words(band), 0.0_real64)
      shortwave%rfldd2(band) = transfer(rfldd2_words(band), 0.0_real64)
      shortwave%rfldd3(band) = transfer(rfldd3_words(band), 0.0_real64)
      shortwave%rfuaa0(band) = transfer(rfuaa0_words(band), 0.0_real64)
      shortwave%rfuaa1(band) = transfer(rfuaa1_words(band), 0.0_real64)
      shortwave%rfubb0(band) = transfer(rfubb0_words(band), 0.0_real64)
      shortwave%rfubb1(band) = transfer(rfubb1_words(band), 0.0_real64)
      shortwave%rfubb2(band) = transfer(rfubb2_words(band), 0.0_real64)
      shortwave%rfubb3(band) = transfer(rfubb3_words(band), 0.0_real64)
      shortwave%rfucc0(band) = transfer(rfucc0_words(band), 0.0_real64)
      shortwave%rfucc1(band) = transfer(rfucc1_words(band), 0.0_real64)
      shortwave%rfucc2(band) = transfer(rfucc2_words(band), 0.0_real64)
      shortwave%rfucc3(band) = transfer(rfucc3_words(band), 0.0_real64)
    end do

    select case (levels)
    case (19_int32)
      radiation%raovlp = transfer(int(z'bef797cc39ffd60f', int64), 0.0_real64)
      radiation%rbovlp = transfer(int(z'3fe92b020c49ba5e', int64), 0.0_real64)
    case (31_int32)
      radiation%raovlp = transfer(int(z'bedeaf7ec4675ec5', int64), 0.0_real64)
      radiation%rbovlp = transfer(int(z'3fea31f8a0902de0', int64), 0.0_real64)
    case default
      radiation%raovlp = transfer(int(z'bef49d70e9a21a9d', int64), 0.0_real64)
      radiation%rbovlp = transfer(int(z'3fec7ae147ae147b', int64), 0.0_real64)
    end select
  end subroutine initialize_cloud_optical_fields

  !> Set all six SU_CLOP550 words in the caller-owned diagnostic record.
  !! OUTPUT has type cloud_optical_550_parameter_record and intent INOUT.
  !! The six field stores preserve every selected literal bit, including
  !! signed zeros. No original module data or numerical routine is consumed.
  subroutine initialize_cloud_optical_550_fields(output)
    type(cloud_optical_550_parameter_record), intent(inout) :: output
    output%rsa55 = transfer(int(z'3f9d0fa58f7121ab', int64), 0.0_real64)
    output%rsb55 = transfer(int(z'3ff4cccccccccccd', int64), 0.0_real64)
    output%rsc55 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rsd55 = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rfa55(1) = transfer(int(z'beffc87e50c14d38', int64), 0.0_real64)
    output%rfa55(2) = transfer(int(z'400424f765fd8adb', int64), 0.0_real64)
  end subroutine initialize_cloud_optical_550_fields

end module cloud_optical_parameter_fields_mod
