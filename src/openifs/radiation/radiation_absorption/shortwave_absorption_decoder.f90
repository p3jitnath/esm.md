module shortwave_absorption_decoder
  !! Decode source coefficient bytes into named native arrays without real arithmetic.
  use iso_c_binding, only: c_int, c_int8_t, c_int64_t, c_double
  use native_absorption_records, only: shortwave_absorption_record
  use absorption_binary_file_service, only: network_word32, decode_real_words
  implicit none
  private
  public :: decode_shortwave_absorption_inputs
  integer(c_int), parameter :: ng_bits_1(14) = [ &
                               int(z'00000010', c_int), int(z'00000010', c_int), int(z'00000010', c_int), int(z'00000010', c_int), &
                               int(z'00000010', c_int), int(z'00000010', c_int), int(z'00000010', c_int), int(z'00000010', c_int), &
                               int(z'00000010', c_int), int(z'00000010', c_int), int(z'00000010', c_int), int(z'00000010', c_int), &
                               int(z'00000010', c_int), int(z'00000010', c_int)]
  integer(c_int), parameter :: nspa_bits_1(14) = [ &
                               int(z'00000009', c_int), int(z'00000009', c_int), int(z'00000009', c_int), int(z'00000009', c_int), &
                               int(z'00000001', c_int), int(z'00000009', c_int), int(z'00000009', c_int), int(z'00000001', c_int), &
                               int(z'00000009', c_int), int(z'00000001', c_int), int(z'00000000', c_int), int(z'00000001', c_int), &
                               int(z'00000009', c_int), int(z'00000001', c_int)]
  integer(c_int), parameter :: nspb_bits_1(14) = [ &
                               int(z'00000001', c_int), int(z'00000005', c_int), int(z'00000001', c_int), int(z'00000001', c_int), &
                               int(z'00000001', c_int), int(z'00000005', c_int), int(z'00000001', c_int), int(z'00000000', c_int), &
                               int(z'00000001', c_int), int(z'00000000', c_int), int(z'00000000', c_int), int(z'00000001', c_int), &
                               int(z'00000005', c_int), int(z'00000001', c_int)]
  integer(c_int), parameter :: nmpsrtm_bits_1(14) = [ &
                               int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000005', c_int), int(z'00000005', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000004', c_int), &
                               int(z'00000004', c_int), int(z'00000003', c_int), int(z'00000002', c_int), int(z'00000002', c_int), &
                               int(z'00000001', c_int), int(z'00000006', c_int)]
  integer(c_int64_t), parameter :: pref_bits_1(59) = [ &
    int(z'409076851eb851ec',c_int64_t), int(z'408af522d0e56042',c_int64_t), int(z'4086122d0e560419',c_int64_t), int(z'408211f7ced91687',c_int64_t), &
    int(z'407d96d916872b02',c_int64_t), int(z'407839c28f5c28f6',c_int64_t), int(z'4073d5916872b021',c_int64_t), int(z'40703d2b020c49ba',c_int64_t), &
    int(z'406a973333333333',c_int64_t), int(z'4065c53f7ced9168',c_int64_t), int(z'4061d3020c49ba5e',c_int64_t), int(z'405d2fbe76c8b439',c_int64_t), &
    int(z'4057e55810624dd3',c_int64_t), int(z'40539074538ef34d',c_int64_t), int(z'4050049374bc6a7f',c_int64_t), int(z'404a3a88ce703afb',c_int64_t), &
    int(z'404579652bd3c361',c_int64_t), int(z'404194e3bcd35a86',c_int64_t), int(z'403cca0902de00d2',c_int64_t), int(z'40379212d77318fc',c_int64_t), &
    int(z'40334c49ba5e353f',c_int64_t), int(z'402f997f62b6ae7d',c_int64_t), int(z'4029df212d773190',c_int64_t), int(z'40252e978d4fdf3b',c_int64_t), &
    int(z'4021579fa97e132b',c_int64_t), int(z'401c65b6c3760bf6',c_int64_t), int(z'40173ff04577d955',c_int64_t), int(z'401309081c2e33f0',c_int64_t), &
    int(z'400f2b65a9a80496',c_int64_t), int(z'400984fa05143bf7',c_int64_t), int(z'4004e4c2f837b4a2',c_int64_t), int(z'40011b328b6d86ec',c_int64_t), &
    int(z'3ffc02be8bc169c2',c_int64_t), int(z'3ff6eeeb702602c9',c_int64_t), int(z'3ff2c6b26bf8769f',c_int64_t), int(z'3feebec892ab68cf',c_int64_t), &
    int(z'3fe92c0e7bc3c5bd',c_int64_t), int(z'3fe49bf162ae4b02',c_int64_t), int(z'3fe0df9378ee2867',c_int64_t), int(z'3fdba122fad6cb53',c_int64_t), &
    int(z'3fd69f01b866e43b',c_int64_t), int(z'3fd2854477ff151e',c_int64_t), int(z'3fce53a81dc0db27',c_int64_t), int(z'3fc8d4562e09fe87',c_int64_t), &
    int(z'3fc4541d8e864021',c_int64_t), int(z'3fc0a4ca4f440af2',c_int64_t), int(z'3fbb40d4dc65c704',c_int64_t), int(z'3fb6502b917e4225',c_int64_t), &
    int(z'3fb244ba44340c77',c_int64_t), int(z'3fade9f5d27f9435',c_int64_t), int(z'3fa87dd0e637011e',c_int64_t), int(z'3fa40d4a6b5e1cec',c_int64_t), &
    int(z'3fa06ac8cbb64c58',c_int64_t), int(z'3f9ae1e207c7749e',c_int64_t), int(z'3f96026b144b10a0',c_int64_t), int(z'3f9205143bf72713',c_int64_t), &
                      int(z'3f8d81bb5682c394', c_int64_t), int(z'3f882872e5d0a9d1', c_int64_t), int(z'3f83c76935a3a5e2', c_int64_t)]
  integer(c_int64_t), parameter :: preflog_bits_1(59) = [ &
    int(z'401bd70a3d70a3d7',c_int64_t), int(z'401b0a3d70a3d70a',c_int64_t), int(z'401a3d70a3d70a3d',c_int64_t), int(z'401970a3d70a3d71',c_int64_t), &
    int(z'4018a3d70a3d70a4',c_int64_t), int(z'4017d70a3d70a3d7',c_int64_t), int(z'40170a3d70a3d70a',c_int64_t), int(z'40163d70a3d70a3d',c_int64_t), &
    int(z'401570a3d70a3d71',c_int64_t), int(z'4014a3d70a3d70a4',c_int64_t), int(z'4013d70a3d70a3d7',c_int64_t), int(z'40130a3d70a3d70a',c_int64_t), &
    int(z'40123d70a3d70a3d',c_int64_t), int(z'401170a3d70a3d71',c_int64_t), int(z'4010a3d70a3d70a4',c_int64_t), int(z'400fae147ae147ae',c_int64_t), &
    int(z'400e147ae147ae14',c_int64_t), int(z'400c7ae147ae147b',c_int64_t), int(z'400ae147ae147ae1',c_int64_t), int(z'400947ae147ae148',c_int64_t), &
    int(z'4007ae147ae147ae',c_int64_t), int(z'4006147ae147ae14',c_int64_t), int(z'40047ae147ae147b',c_int64_t), int(z'4002e147ae147ae1',c_int64_t), &
    int(z'400147ae147ae148',c_int64_t), int(z'3fff5c28f5c28f5c',c_int64_t), int(z'3ffc28f5c28f5c29',c_int64_t), int(z'3ff8f5c28f5c28f6',c_int64_t), &
    int(z'3ff5c28f5c28f5c3',c_int64_t), int(z'3ff28f5c28f5c28f',c_int64_t), int(z'3feeb851eb851eb8',c_int64_t), int(z'3fe851eb851eb852',c_int64_t), &
    int(z'3fe1eb851eb851ec',c_int64_t), int(z'3fd70a3d70a3d70a',c_int64_t), int(z'3fc47ae147ae147b',c_int64_t), int(z'bfa47ae147ae147b',c_int64_t), &
    int(z'bfceb851eb851eb8',c_int64_t), int(z'bfdc28f5c28f5c29',c_int64_t), int(z'bfe47ae147ae147b',c_int64_t), int(z'bfeae147ae147ae1',c_int64_t), &
    int(z'bff0a3d70a3d70a4',c_int64_t), int(z'bff3d70a3d70a3d7',c_int64_t), int(z'bff70a3d70a3d70a',c_int64_t), int(z'bffa3d70a3d70a3d',c_int64_t), &
    int(z'bffd70a3d70a3d71',c_int64_t), int(z'c00051eb851eb852',c_int64_t), int(z'c001eb851eb851ec',c_int64_t), int(z'c003851eb851eb85',c_int64_t), &
    int(z'c0051eb851eb851f',c_int64_t), int(z'c006b851eb851eb8',c_int64_t), int(z'c00851eb851eb852',c_int64_t), int(z'c009eb851eb851ec',c_int64_t), &
    int(z'c00b851eb851eb85',c_int64_t), int(z'c00d1eb851eb851f',c_int64_t), int(z'c00eb851eb851eb8',c_int64_t), int(z'c01028f5c28f5c29',c_int64_t), &
                      int(z'c010f5c28f5c28f6', c_int64_t), int(z'c011c28f5c28f5c3', c_int64_t), int(z'c0128f5c28f5c28f', c_int64_t)]
  integer(c_int64_t), parameter :: tref_bits_1(59) = [ &
    int(z'4072633333333333',c_int64_t), int(z'4071ffd70a3d70a4',c_int64_t), int(z'40716f0a3d70a3d7',c_int64_t), int(z'4070d40000000000',c_int64_t), &
    int(z'40703d47ae147ae1',c_int64_t), int(z'406f4570a3d70a3d',c_int64_t), int(z'406e18a3d70a3d71',c_int64_t), int(z'406cf947ae147ae1',c_int64_t), &
    int(z'406be1eb851eb852',c_int64_t), int(z'406af8f5c28f5c29',c_int64_t), int(z'406af66666666666',c_int64_t), int(z'406af66666666666',c_int64_t), &
    int(z'406af66666666666',c_int64_t), int(z'406b21eb851eb852',c_int64_t), int(z'406b528f5c28f5c3',c_int64_t), int(z'406b85c28f5c28f6',c_int64_t), &
    int(z'406bb7ae147ae148',c_int64_t), int(z'406be8f5c28f5c29',c_int64_t), int(z'406c1947ae147ae1',c_int64_t), int(z'406c51999999999a',c_int64_t), &
    int(z'406c8ae147ae147b',c_int64_t), int(z'406ce428f5c28f5c',c_int64_t), int(z'406d4051eb851eb8',c_int64_t), int(z'406da0f5c28f5c29',c_int64_t), &
    int(z'406e070a3d70a3d7',c_int64_t), int(z'406e76b851eb851f',c_int64_t), int(z'406ee851eb851eb8',c_int64_t), int(z'406f5b3333333333',c_int64_t), &
    int(z'406fd23d70a3d70a',c_int64_t), int(z'4070251eb851eb85',c_int64_t), int(z'4070628f5c28f5c3',c_int64_t), int(z'4070a0f5c28f5c29',c_int64_t), &
    int(z'4070dfd70a3d70a4',c_int64_t), int(z'4071166666666666',c_int64_t), int(z'407135c28f5c28f6',c_int64_t), int(z'40713ae147ae147b',c_int64_t), &
    int(z'40711b851eb851ec',c_int64_t), int(z'4070fa147ae147ae',c_int64_t), int(z'4070d8cccccccccd',c_int64_t), int(z'40709ee147ae147b',c_int64_t), &
    int(z'407061c28f5c28f6',c_int64_t), int(z'4070247ae147ae14',c_int64_t), int(z'406fb33333333333',c_int64_t), int(z'406f1147ae147ae1',c_int64_t), &
    int(z'406e6f5c28f5c28f',c_int64_t), int(z'406dc2e147ae147b',c_int64_t), int(z'406d01eb851eb852',c_int64_t), int(z'406c40f5c28f5c29',c_int64_t), &
    int(z'406b800000000000',c_int64_t), int(z'406acb3333333333',c_int64_t), int(z'406a1bd70a3d70a4',c_int64_t), int(z'40696ccccccccccd',c_int64_t), &
    int(z'4068bd70a3d70a3d',c_int64_t), int(z'40681ccccccccccd',c_int64_t), int(z'406782e147ae147b',c_int64_t), int(z'4066e947ae147ae1',c_int64_t), &
                      int(z'40664fae147ae148', c_int64_t), int(z'4065be147ae147ae', c_int64_t), int(z'406583d70a3d70a4', c_int64_t)]
  integer(c_int), parameter :: ngm_bits_1(128) = [ &
                               int(z'00000001', c_int), int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000002', c_int), &
                               int(z'00000003', c_int), int(z'00000003', c_int), int(z'00000004', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000005', c_int), &
                               int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000007', c_int), &
                               int(z'00000008', c_int), int(z'00000008', c_int), int(z'00000009', c_int), int(z'0000000a', c_int), &
                               int(z'0000000a', c_int), int(z'0000000b', c_int), int(z'0000000c', c_int), int(z'0000000c', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000007', c_int), int(z'00000007', c_int), int(z'00000007', c_int), int(z'00000007', c_int), &
                               int(z'00000008', c_int), int(z'00000008', c_int), int(z'00000008', c_int), int(z'00000008', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000007', c_int), int(z'00000007', c_int), int(z'00000007', c_int), int(z'00000007', c_int), &
                               int(z'00000008', c_int), int(z'00000008', c_int), int(z'00000008', c_int), int(z'00000008', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000007', c_int), int(z'00000008', c_int), &
                               int(z'00000009', c_int), int(z'00000009', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int), &
                               int(z'0000000a', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000007', c_int), int(z'00000008', c_int), &
                               int(z'00000009', c_int), int(z'00000009', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int), &
                               int(z'0000000a', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int), &
                               int(z'00000001', c_int), int(z'00000001', c_int), int(z'00000001', c_int), int(z'00000001', c_int), &
                               int(z'00000001', c_int), int(z'00000001', c_int), int(z'00000001', c_int), int(z'00000001', c_int), &
                               int(z'00000002', c_int), int(z'00000002', c_int), int(z'00000002', c_int), int(z'00000002', c_int), &
                               int(z'00000002', c_int), int(z'00000002', c_int), int(z'00000002', c_int), int(z'00000002', c_int), &
                               int(z'00000001', c_int), int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000002', c_int), &
                               int(z'00000003', c_int), int(z'00000004', c_int), int(z'00000005', c_int), int(z'00000006', c_int), &
                               int(z'00000007', c_int), int(z'00000008', c_int), int(z'00000009', c_int), int(z'00000009', c_int), &
                               int(z'0000000a', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int), int(z'0000000a', c_int)]
  integer(c_int), parameter :: ngm_bits_2(96) = [ &
                               int(z'00000001', c_int), int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000002', c_int), &
                               int(z'00000003', c_int), int(z'00000003', c_int), int(z'00000004', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000007', c_int), int(z'00000007', c_int), int(z'00000008', c_int), int(z'00000008', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000003', c_int), &
                               int(z'00000004', c_int), int(z'00000004', c_int), int(z'00000005', c_int), int(z'00000005', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000003', c_int), &
                               int(z'00000004', c_int), int(z'00000004', c_int), int(z'00000005', c_int), int(z'00000005', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000007', c_int), int(z'00000007', c_int), &
                               int(z'00000007', c_int), int(z'00000007', c_int), int(z'00000008', c_int), int(z'00000008', c_int), &
                               int(z'00000008', c_int), int(z'00000008', c_int), int(z'00000008', c_int), int(z'00000008', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000003', c_int), &
                               int(z'00000004', c_int), int(z'00000004', c_int), int(z'00000005', c_int), int(z'00000005', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000001', c_int), int(z'00000002', c_int), int(z'00000003', c_int), int(z'00000004', c_int), &
                               int(z'00000005', c_int), int(z'00000005', c_int), int(z'00000006', c_int), int(z'00000006', c_int), &
                               int(z'00000007', c_int), int(z'00000007', c_int), int(z'00000008', c_int), int(z'00000008', c_int), &
                               int(z'00000009', c_int), int(z'0000000a', c_int), int(z'0000000b', c_int), int(z'0000000c', c_int)]
  integer(c_int), parameter :: ngc_bits_1(14) = [ &
                               int(z'00000006', c_int), int(z'0000000c', c_int), int(z'00000008', c_int), int(z'00000008', c_int), &
                               int(z'0000000a', c_int), int(z'0000000a', c_int), int(z'00000002', c_int), int(z'0000000a', c_int), &
                               int(z'00000008', c_int), int(z'00000006', c_int), int(z'00000006', c_int), int(z'00000008', c_int), &
                               int(z'00000006', c_int), int(z'0000000c', c_int)]
  integer(c_int), parameter :: ngs_bits_1(14) = [ &
                               int(z'00000006', c_int), int(z'00000012', c_int), int(z'0000001a', c_int), int(z'00000022', c_int), &
                               int(z'0000002c', c_int), int(z'00000036', c_int), int(z'00000038', c_int), int(z'00000042', c_int), &
                               int(z'0000004a', c_int), int(z'00000050', c_int), int(z'00000056', c_int), int(z'0000005e', c_int), &
                               int(z'00000064', c_int), int(z'00000070', c_int)]
  integer(c_int64_t), parameter :: wt_bits_1(16) = [ &
    int(z'3fc38d6c9ff26b70',c_int64_t), int(z'3fc318197ff9778a',c_int64_t), int(z'3fc23034dfe95bba',c_int64_t), int(z'3fc0db2c7ff37cd0',c_int64_t), &
    int(z'3fbe41ff001d28a7',c_int64_t), int(z'3fba181720059896',c_int64_t), int(z'3fb5519f4032dc31',c_int64_t), int(z'3fb00b45e0324ff6',c_int64_t), &
    int(z'3fa5c193b3a68b1a',c_int64_t), int(z'3f72f3c0026e573c',c_int64_t), int(z'3f6f5bdfffce64a4',c_int64_t), int(z'3f68c9ffff2e67d5',c_int64_t), &
    int(z'3f622fa000bbe7a2',c_int64_t), int(z'3f572ac0034bf609',c_int64_t), int(z'3f417720c8cd63cc',c_int64_t), int(z'3f13a92a30553261',c_int64_t)]
  integer(c_int64_t), parameter :: b16_selfref_bits_1(128) = [ &
    int(z'3f54c49da948b92c',c_int64_t), int(z'3f513ea17b655113',c_int64_t), int(z'3f4ca355405f7cce',c_int64_t), int(z'3f47c787689493f6',c_int64_t), &
    int(z'3f43bebfaa0abc2d',c_int64_t), int(z'3f4065308ef1a882',c_int64_t), int(z'3f3b3a3a85da4177',c_int64_t), int(z'3f369bafc0c4ce1d',c_int64_t), &
    int(z'3f32c5c87f3dd658',c_int64_t), int(z'3f2f2ce35a4f4e3e',c_int64_t), int(z'3f57980ca6ac7ca0',c_int64_t), int(z'3f536ad662a2b77b',c_int64_t), &
    int(z'3f4ff5d652d4db86',c_int64_t), int(z'3f4a4d82ae8a5b52',c_int64_t), int(z'3f45a590953075b6',c_int64_t), int(z'3f41d09bfe11ad15',c_int64_t), &
    int(z'3f3d529cec1aac0f',c_int64_t), int(z'3f3821cea0a6420d',c_int64_t), int(z'3f33dc3c11ba4dd5',c_int64_t), int(z'3f30583cd7f7a33a',c_int64_t), &
    int(z'3f6816011e38245f',c_int64_t), int(z'3f62a182c71a3058',c_int64_t), int(z'3f5cd29e9de558b5',c_int64_t), int(z'3f564b7ba96ea3cd',c_int64_t), &
    int(z'3f513ed72b4a868c',c_int64_t), int(z'3f4aade9905a8941',c_int64_t), int(z'3f44a30d9445d04c',c_int64_t), int(z'3f3fed12340186b5',c_int64_t), &
    int(z'3f38b201df17160b',c_int64_t), int(z'3f331a307a3dab29',c_int64_t), int(z'3f7030ea8396f8d5',c_int64_t), int(z'3f6c8a9519d8185a',c_int64_t), &
    int(z'3f6927f490b61b30',c_int64_t), int(z'3f662c1c12b030e0',c_int64_t), int(z'3f638ae1c5d83bec',c_int64_t), int(z'3f61397e25f5b2f5',c_int64_t), &
    int(z'3f5e5cf7d2b4ee34',c_int64_t), int(z'3f5ac304a1fb3cf8',c_int64_t), int(z'3f579669e44a41ee',c_int64_t), int(z'3f54ca31bce67ac9',c_int64_t), &
    int(z'3f712ad00d4913c5',c_int64_t), int(z'3f6f976a3f63ee11',c_int64_t), int(z'3f6d114db03714ea',c_int64_t), int(z'3f6abecd85af56f0',c_int64_t), &
    int(z'3f689bcd7b7368d8',c_int64_t), int(z'3f66a481d501cf8e',c_int64_t), int(z'3f64d569ff4d27a6',c_int64_t), int(z'3f632b55ef1fddec',c_int64_t), &
    int(z'3f61a345eac5dc18',c_int64_t), int(z'3f603a8ac062dc18',c_int64_t), int(z'3f744d5c7f31e454',c_int64_t), int(z'3f72b5a76c401a21',c_int64_t), &
    int(z'3f713deda158aabc',c_int64_t), int(z'3f6fc75b1ddde172',c_int64_t), int(z'3f6d49314c533fc3',c_int64_t), int(z'3f6afd113836a833',c_int64_t), &
    int(z'3f68df144d1404f0',c_int64_t), int(z'3f66eb9f1feb57d2',c_int64_t), int(z'3f651f56b2694945',c_int64_t), int(z'3f637725d14ae0cf',c_int64_t), &
    int(z'3f7595cbd9b2b950',c_int64_t), int(z'3f741939e2cfc377',c_int64_t), int(z'3f72b6deced7e9e1',c_int64_t), int(z'3f716cea39195135',c_int64_t), &
    int(z'3f7039aea26a4da7',c_int64_t), int(z'3f6e3738258b54dd',c_int64_t), int(z'3f6c227ad4319b03',c_int64_t), int(z'3f6a3270c0876f20',c_int64_t), &
    int(z'3f6864904d6a96f8',c_int64_t), int(z'3f66b67ad0d69caf',c_int64_t), int(z'3f7791c76833f0f3',c_int64_t), int(z'3f75c632d4be88bc',c_int64_t), &
    int(z'3f741d9ea16b4a26',c_int64_t), int(z'3f729560fac1a7ab',c_int64_t), int(z'3f712b030dfc6cf8',c_int64_t), int(z'3f6fb88212137de1',c_int64_t), &
    int(z'3f6d4df95d239c92',c_int64_t), int(z'3f6b1290257c914b',c_int64_t), int(z'3f6902ab001e5de4',c_int64_t), int(z'3f671af9ab7d1be0',c_int64_t), &
    int(z'3f7685eb91dee528',c_int64_t), int(z'3f75111eb64e8620',c_int64_t), int(z'3f73b46d2f835057',c_int64_t), int(z'3f726e4705780f05',c_int64_t), &
    int(z'3f713d37181a281f',c_int64_t), int(z'3f701fe07017c010',c_int64_t), int(z'3f6e29fc7dbf7373',c_int64_t), int(z'3f6c36b7a2184343',c_int64_t), &
    int(z'3f6a63b937ef8589',c_int64_t), int(z'3f68aeedbeb4dc15',c_int64_t), int(z'3f78cba0d2c8e537',c_int64_t), int(z'3f76fd174266d7d0',c_int64_t), &
    int(z'3f7550413600421a',c_int64_t), int(z'3f73c2aa8a01cc08',c_int64_t), int(z'3f72520cbd27be35',c_int64_t), int(z'3f70fc4c414c259d',c_int64_t), &
    int(z'3f6f7ee63a063625',c_int64_t), int(z'3f6d335c78d1cde9',c_int64_t), int(z'3f6b12a59f0b737c',c_int64_t), int(z'3f6919a1bca8bd4e',c_int64_t), &
    int(z'3f7a3c2bd545ed1f',c_int64_t), int(z'3f7814234d8cfba6',c_int64_t), int(z'3f76197ca8c80ac6',c_int64_t), int(z'3f74487c45a0c90e',c_int64_t), &
    int(z'3f729db1ac34fcb7',c_int64_t), int(z'3f7115fcec7a3c31',c_int64_t), int(z'3f6f5cf2495e17e3',c_int64_t), int(z'3f6cc903bf7d2dfe',c_int64_t), &
    int(z'3f6a6b560f56343f',c_int64_t), int(z'3f683f6c518ce581',c_int64_t), int(z'3f7bc34792e6a20b',c_int64_t), int(z'3f79374bc6a7ef9e',c_int64_t), &
    int(z'3f76e722388f12ad',c_int64_t), int(z'3f74cd499f5b4f87',c_int64_t), int(z'3f72e4c6e988f029',c_int64_t), int(z'3f71291522261a9c',c_int64_t), &
    int(z'3f6f2c2aab4f4e9d',c_int64_t), int(z'3f6c501d23d2422d',c_int64_t), int(z'3f69b73b96033717',c_int64_t), int(z'3f675b50de94cb54',c_int64_t), &
    int(z'3f7c46d01e100b66',c_int64_t), int(z'3f79ae9a5cb811d5',c_int64_t), int(z'3f775358c28edb50',c_int64_t), int(z'3f752f6f2e611168',c_int64_t), &
    int(z'3f733dcd151c1bea',c_int64_t), int(z'3f7179d5590d6269',c_int64_t), int(z'3f6fbea71a35b645',c_int64_t), int(z'3f6cd4fd47e9ce90',c_int64_t)]
  integer(c_int64_t), parameter :: b16_selfref_bits_2(32) = [ &
    int(z'3f6a2fbc30477082',c_int64_t), int(z'3f67c89e94d6106d',c_int64_t), int(z'3f7c5f46b77475f4',c_int64_t), int(z'3f79eb5624cfc321',c_int64_t), &
    int(z'3f77adae797a9547',c_int64_t), int(z'3f75a19fcd654e0d',c_int64_t), int(z'3f73c2e039e70181',c_int64_t), int(z'3f720d83cc27e145',c_int64_t), &
    int(z'3f707df726bd8405',c_int64_t), int(z'3f6e21e989c6e8b2',c_int64_t), int(z'3f6b87049692a910',c_int64_t), int(z'3f6925c638332241',c_int64_t), &
    int(z'3f7eeba326b6223b',c_int64_t), int(z'3f7be9d8a14158bb',c_int64_t), int(z'3f7932e9b73e4535',c_int64_t), int(z'3f76bf8f7781c1b7',c_int64_t), &
    int(z'3f748936caed4ea2',c_int64_t), int(z'3f7289f30875c554',c_int64_t), int(z'3f70bc687b9475ee',c_int64_t), int(z'3f6e377df09bb3fb',c_int64_t), &
    int(z'3f6b4738f99bb7d7',c_int64_t), int(z'3f68a01a114e3110',c_int64_t), int(z'3f7f2866fc63685a',c_int64_t), int(z'3f7d1252121b8b77',c_int64_t), &
    int(z'3f7b20017d2da82f',c_int64_t), int(z'3f794f0e85ffb3d5',c_int64_t), int(z'3f779d3d6815681c',c_int64_t), int(z'3f760877f3ac8a8d',c_int64_t), &
    int(z'3f748ecade8b103f',c_int64_t), int(z'3f732e687330fa1e',c_int64_t), int(z'3f71e5a08342c019',c_int64_t), int(z'3f70b2db09259896',c_int64_t)]
  integer(c_int64_t), parameter :: b16_forref_bits_1(48) = [ &
    int(z'3ed60b6d0c160f96',c_int64_t), int(z'3ed6214150a7c237',c_int64_t), int(z'3f13948e403fce31',c_int64_t), int(z'3ee0aa4c633db98a',c_int64_t), &
    int(z'3eecb5dec2c54150',c_int64_t), int(z'3f16476f4946c273',c_int64_t), int(z'3ef4aad603b7827e',c_int64_t), int(z'3f1337b5e6e6b04c',c_int64_t), &
    int(z'3f1fe646bdcbf559',c_int64_t), int(z'3f236f3ff6319774',c_int64_t), int(z'3f2640bcbc3c0e82',c_int64_t), int(z'3f259b6189a198b0',c_int64_t), &
    int(z'3f2e2f7393a91d4e',c_int64_t), int(z'3f2b9350cc9896dd',c_int64_t), int(z'3f27dbd89d295fe5',c_int64_t), int(z'3f32634472f697a1',c_int64_t), &
    int(z'3f30fcf0899e0191',c_int64_t), int(z'3f29b35a5ff2d9d2',c_int64_t), int(z'3f35904644ef0395',c_int64_t), int(z'3f331bd116de68d7',c_int64_t), &
    int(z'3f2b233e6aec2981',c_int64_t), int(z'3f36efd74f17fc5c',c_int64_t), int(z'3f3532f15dbf9296',c_int64_t), int(z'3f2d95a3510ea195',c_int64_t), &
    int(z'3f37fe16a464d74e',c_int64_t), int(z'3f351231970d088d',c_int64_t), int(z'3f309726f8924d75',c_int64_t), int(z'3f39238e35c976bd',c_int64_t), &
    int(z'3f37492e0282f854',c_int64_t), int(z'3f3134f1236e442b',c_int64_t), int(z'3f38a31bf0c3c45d',c_int64_t), int(z'3f38688e812f0bff',c_int64_t), &
    int(z'3f31201ac9fd3110',c_int64_t), int(z'3f384a8237dbc211',c_int64_t), int(z'3f390f097710f25a',c_int64_t), int(z'3f30637a78c208a4',c_int64_t), &
    int(z'3f3894ffdf7c5a77',c_int64_t), int(z'3f38dfa87a3ab73f',c_int64_t), int(z'3f316b488997d505',c_int64_t), int(z'3f398a2a3ae706b5',c_int64_t), &
    int(z'3f392f0c434082b8',c_int64_t), int(z'3f351c874a36afea',c_int64_t), int(z'3f3862889c826861',c_int64_t), int(z'3f399631b8bd53e7',c_int64_t), &
    int(z'3f384028392f20aa',c_int64_t), int(z'3f3cb11945a9e0ed',c_int64_t), int(z'3f3878b68ee19e85',c_int64_t), int(z'3f3875a048bde78a',c_int64_t)]
  integer(c_int64_t), parameter :: b16_sfluxref_bits_1(16) = [ &
    int(z'3ffec35696e58a33',c_int64_t), int(z'3ffba7b0b3919264',c_int64_t), int(z'3ffa4acaff6d3309',c_int64_t), int(z'3ff95a272862f599',c_int64_t), &
    int(z'3ff70b827fa1a0cf',c_int64_t), int(z'3ff4046c764adff8',c_int64_t), int(z'3ff06f9335d249e4',c_int64_t), int(z'3fe8db35b0bbf50e',c_int64_t), &
    int(z'3fe11a2a4db163bb',c_int64_t), int(z'3fae17d2849cb253',c_int64_t), int(z'3fa8eb5a568dab4f',c_int64_t), int(z'3fa3dd730d3dd624',c_int64_t), &
    int(z'3f9d22d5edddbe8d',c_int64_t), int(z'3f92ae51b782b8ad',c_int64_t), int(z'3f7c5b805956b36b',c_int64_t), int(z'3f4fcf68b372b3a7',c_int64_t)]
  integer(c_int64_t), parameter :: b16_rayl_bits_1(1) = [ &
                                   int(z'3df3ff537dd73111', c_int64_t)]
  integer(c_int64_t), parameter :: b16_strrat1_bits_1(1) = [ &
                                   int(z'406f843126e978d5', c_int64_t)]
  integer(c_int), parameter :: b16_layreffr_bits_1(1) = [ &
                               int(z'00000012', c_int)]
  integer(c_int64_t), parameter :: b17_selfref_bits_1(128) = [ &
    int(z'3f90706191eb4f6f',c_int64_t), int(z'3f8e85e22cb06233',c_int64_t), int(z'3f8c5634bffb2d32',c_int64_t), int(z'3f8a4e958f48ddbf',c_int64_t), &
    int(z'3f886c2fd40321f3',c_int64_t), int(z'3f86ac570b7f9003',c_int64_t), int(z'3f850c9462f8f39c',c_int64_t), int(z'3f838aa00192a737',c_int64_t), &
    int(z'3f82244b8ec9b1e5',c_int64_t), int(z'3f80d7a268cb1a9b',c_int64_t), int(z'3fa2b9ff6aaeca83',c_int64_t), int(z'3fa186297a4ccd38',c_int64_t), &
    int(z'3fa06614310f6c85',c_int64_t), int(z'3f9eb0fadf2ecf20',c_int64_t), int(z'3f9cb87526f389d0',c_int64_t), int(z'3f9ae04f60906390',c_int64_t), &
    int(z'3f99267e190a9301',c_int64_t), int(z'3f978909ff5d42d1',c_int64_t), int(z'3f960624066f85ca',c_int64_t), int(z'3f949c17f91b0971',c_int64_t), &
    int(z'3fc04f440af1cb8a',c_int64_t), int(z'3fbe597d49d7ba67',c_int64_t), int(z'3fbc3ce2089e3433',c_int64_t), int(z'3fba45e4e69f05ea',c_int64_t), &
    int(z'3fb871ebd5a69022',c_int64_t), int(z'3fb6be7e557074dd',c_int64_t), int(z'3fb5295cf09bdeee',c_int64_t), int(z'3fb3b06b6d366440',c_int64_t), &
    int(z'3fb251b5d53982d9',c_int64_t), int(z'3fb10b66658fa6d2',c_int64_t), int(z'3fd83c68661ae70c',c_int64_t), int(z'3fd6556084a515cf',c_int64_t), &
    int(z'3fd49491f2dc2b0f',c_int64_t), int(z'3fd2f6fd21ff2e49',c_int64_t), int(z'3fd179e16d6dc1a4',c_int64_t), int(z'3fd01ab0856e696a',c_int64_t), &
    int(z'3fcdae1cde5d1809',c_int64_t), int(z'3fcb59ab6d00b45b',c_int64_t), int(z'3fc9340d4dc65c70',c_int64_t), int(z'3fc7398e97071822',c_int64_t), &
    int(z'3fde42b734b51373',c_int64_t), int(z'3fdbd755bccaf70a',c_int64_t), int(z'3fd99d7774aba387',c_int64_t), int(z'3fd7912dba4d6e48',c_int64_t), &
    int(z'3fd5aecd07852f7f',c_int64_t), int(z'3fd3f2fdb8fde2ef',c_int64_t), int(z'3fd25aa715831f04',c_int64_t), int(z'3fd0e2fbe33acd5b',c_int64_t), &
    int(z'3fcf12a94ff0025c',c_int64_t), int(z'3fcc96aad1d041cc',c_int64_t), int(z'3fe02e09fe86833c',c_int64_t), int(z'3fddc36113404ea5',c_int64_t), &
    int(z'3fdb6006d0d4994a',c_int64_t), int(z'3fd92dba4d6e47dc',c_int64_t), int(z'3fd72888b545c78a',c_int64_t), int(z'3fd54cd74927913f',c_int64_t), &
    int(z'3fd39752977c88e8',c_int64_t), int(z'3fd204ea4a8c154d',c_int64_t), int(z'3fd092c8c5004fb1',c_int64_t), int(z'3fce7cb70ac3a861',c_int64_t), &
    int(z'3fe0f9c1f85d744f',c_int64_t), int(z'3fdf3b46fdeb52ca',c_int64_t), int(z'3fdcbacf7446f9ba',c_int64_t), int(z'3fda6da87a072d1b',c_int64_t), &
    int(z'3fd84fb1183b6028',c_int64_t), int(z'3fd65d206c8711d8',c_int64_t), int(z'3fd49285a921ccd9',c_int64_t), int(z'3fd2eca686e7e62e',c_int64_t), &
    int(z'3fd168900c521dda',c_int64_t), int(z'3fd003925bb7b6bb',c_int64_t), int(z'3fe1497fa5d28d00',c_int64_t), int(z'3fdfdb1209edbf8c',c_int64_t), &
    int(z'3fdd59ddc1e7967d',c_int64_t), int(z'3fdb0b135979181a',c_int64_t), int(z'3fd8eabbcb1cc964',c_int64_t), int(z'3fd6f533f42352eb',c_int64_t), &
    int(z'3fd527179bfdf7e8',c_int64_t), int(z'3fd37d523b3636f4',c_int64_t), int(z'3fd1f505d0fa58f7',c_int64_t), int(z'3fd08b9346994185',c_int64_t), &
    int(z'3fe21a6f826edaa9',c_int64_t), int(z'3fe0bb96af038e2a',c_int64_t), int(z'3fdeee99a62ed352',c_int64_t), int(z'3fdc97204295a6c6',c_int64_t), &
    int(z'3fda6d0917d6b65b',c_int64_t), int(z'3fd86ce358298cc1',c_int64_t), int(z'3fd6938151a43782',c_int64_t), int(z'3fd4ddf86e3b46fe',c_int64_t), &
    int(z'3fd349906cca2db6',c_int64_t), int(z'3fd1d3c36113404f',c_int64_t), int(z'3fe3861e92923e5c',c_int64_t), int(z'3fe1feaa2a0a9585',c_int64_t), &
    int(z'3fe095df6555c52e',c_int64_t), int(z'3fde92ab68cef673',c_int64_t), int(z'3fdc2db1e9f27781',c_int64_t), int(z'3fd9f8b9baa1511e',c_int64_t), &
    int(z'3fd7effe2a3cea6c',c_int64_t), int(z'3fd6100e6afcce1c',c_int64_t), int(z'3fd455b035bd512f',c_int64_t), int(z'3fd2bdfd2630ec31',c_int64_t), &
    int(z'3fe4a54823854046',c_int64_t), int(z'3fe2d8bc59b8023a',c_int64_t), int(z'3fe1345069a4df48',c_int64_t), int(z'3fdf691212513b5c',c_int64_t), &
    int(z'3fdcac647778dd61',c_int64_t), int(z'3fda2cc2d6a9c561',c_int64_t), int(z'3fd7e4de3b8a19ca',c_int64_t), int(z'3fd5cfdd22856606',c_int64_t), &
    int(z'3fd3e94ab1d4f9c2',c_int64_t), int(z'3fd22d1f1cfbb949',c_int64_t), int(z'3fe4db078d92fb1a',c_int64_t), int(z'3fe316e9bbf0dc77',c_int64_t), &
    int(z'3fe1791600f34507',c_int64_t), int(z'3fdffc9795b35b0c',c_int64_t), int(z'3fdd472c0e7bc3c6',c_int64_t), int(z'3fdacc78e9f6a93f',c_int64_t), &
    int(z'3fd88787485e3da3',c_int64_t), int(z'3fd673c4f3ba7760',c_int64_t), int(z'3fd48d08919ef955',c_int64_t), int(z'3fd2cf850df15a4b',c_int64_t), &
    int(z'3fe5279dd3bafd97',c_int64_t), int(z'3fe3745bf26f1dc5',c_int64_t), int(z'3fe1e41700cd8559',c_int64_t), int(z'3fe073fd933e35c6',c_int64_t), &
    int(z'3fde42f1ed17c5ef',c_int64_t), int(z'3fdbd451fc4c1659',c_int64_t), int(z'3fd997bb73083559',c_int64_t), int(z'3fd7892ab68cef67',c_int64_t)]
  integer(c_int64_t), parameter :: b17_selfref_bits_2(32) = [ &
    int(z'3fd5a4ebdd334c5e',c_int64_t), int(z'3fd3e79aae6c8f75',c_int64_t), int(z'3fe629670196d8f5',c_int64_t), int(z'3fe4569f4906034f',c_int64_t), &
    int(z'3fe2aa3f034b0e1b',c_int64_t), int(z'3fe1211ec918e326',c_int64_t), int(z'3fdf70a808c8259e',c_int64_t), int(z'3fdcda76d97b30f9',c_int64_t), &
    int(z'3fda7abb8800eae2',c_int64_t), int(z'3fd84d056c508b33',c_int64_t), int(z'3fd64d2f5dbb9cfa',c_int64_t), int(z'3fd47774aba38759',c_int64_t), &
    int(z'3fe6de6149c6f36f',c_int64_t), int(z'3fe5079c4113c686',c_int64_t), int(z'3fe356b441bb8c33',c_int64_t), int(z'3fe1c898f605ab3b',c_int64_t), &
    int(z'3fe05a836eb4e981',c_int64_t), int(z'3fde13b9f127f5e8',c_int64_t), int(z'3fdba89331a08bfc',c_int64_t), int(z'3fd96f32bdc26dce',c_int64_t), &
    int(z'3fd7639d5e4a3832',c_int64_t), int(z'3fd582235b4edb2f',c_int64_t), int(z'3fe9072d1aeb3dd1',c_int64_t), int(z'3fe6bde82d7b634e',c_int64_t), &
    int(z'3fe4aa19439de482',c_int64_t), int(z'3fe2c6de76427c7c',c_int64_t), int(z'3fe10fc9363f572e',c_int64_t), int(z'3fdf019b0ab2e169',c_int64_t), &
    int(z'3fdc2c8c5004fb12',c_int64_t), int(z'3fd999b6f5caf2d8',c_int64_t), int(z'3fd7430f49491f2e',c_int64_t), int(z'3fd52314013ec461',c_int64_t)]
  integer(c_int64_t), parameter :: b17_forref_bits_1(64) = [ &
    int(z'3f42211082147df8',c_int64_t), int(z'3f4233c11a088c38',c_int64_t), int(z'3f43b465ab5e1ac6',c_int64_t), int(z'3f47357bb7dc4fcd',c_int64_t), &
    int(z'3f59fa678fb13872',c_int64_t), int(z'3f5ab2e976d1988f',c_int64_t), int(z'3f60caf90d1c9e1b',c_int64_t), int(z'3f737df9551606fd',c_int64_t), &
    int(z'3f7fa4b0a3f74094',c_int64_t), int(z'3f80115d4a88e541',c_int64_t), int(z'3f86eeecb245620a',c_int64_t), int(z'3f9773845c1ab30a',c_int64_t), &
    int(z'3f9a1f36fcec4f49',c_int64_t), int(z'3f9a3e04478d5d4b',c_int64_t), int(z'3f9bb8008cedb9ac',c_int64_t), int(z'3f9a92c493426784',c_int64_t), &
    int(z'3fa08d12a299f35c',c_int64_t), int(z'3fa09d388a8b08dd',c_int64_t), int(z'3f9f496aad1d041d',c_int64_t), int(z'3f9b086b088c967c',c_int64_t), &
    int(z'3fa1c3265add9c28',c_int64_t), int(z'3fa1d4a5df2239e7',c_int64_t), int(z'3fa0914e717d1ade',c_int64_t), int(z'3f9c4c886eceeab4',c_int64_t), &
    int(z'3fa2c3e821bce92a',c_int64_t), int(z'3fa2c2a2a75f54fa',c_int64_t), int(z'3fa1a290b920479e',c_int64_t), int(z'3fa0581ea506b526',c_int64_t), &
    int(z'3fa3606ed5a0b0e5',c_int64_t), int(z'3fa337ab67f836de',c_int64_t), int(z'3fa32aedea53c651',c_int64_t), int(z'3fa066ae8ac26641',c_int64_t), &
    int(z'3fa4db31139e4276',c_int64_t), int(z'3fa4491ca983f268',c_int64_t), int(z'3fa42c145b00d796',c_int64_t), int(z'3fa04c95dac83813',c_int64_t), &
    int(z'3fa62be0589acbc9',c_int64_t), int(z'3fa5d610426d62da',c_int64_t), int(z'3fa4e4da09cc319c',c_int64_t), int(z'3fa109685e8e2ad1',c_int64_t), &
    int(z'3fa5ed35f8e0510e',c_int64_t), int(z'3fa696411f850085',c_int64_t), int(z'3fa4ef5d1a8d4a00',c_int64_t), int(z'3fa0bf104ba79e3f',c_int64_t), &
    int(z'3fa6b173aaf28771',c_int64_t), int(z'3fa6dedaec4a4096',c_int64_t), int(z'3fa4b82b55186049',c_int64_t), int(z'3fa1f1f7ff807e40',c_int64_t), &
    int(z'3fa7dd4e24504161',c_int64_t), int(z'3fa797ea6cf0c423',c_int64_t), int(z'3fa48bbc6144be76',c_int64_t), int(z'3fa2f742c21c6fa2',c_int64_t), &
    int(z'3fa8c6f0eab946de',c_int64_t), int(z'3fa86fdb5a2e49bf',c_int64_t), int(z'3fa37db38a05a7e0',c_int64_t), int(z'3fa3dccea28fe261',c_int64_t), &
    int(z'3fa9f52e14e64112',c_int64_t), int(z'3fa916bcdae741c3',c_int64_t), int(z'3fa7e9f77ffebde1',c_int64_t), int(z'3fa2e487d47537bb',c_int64_t), &
    int(z'3faa27a12eb950ef',c_int64_t), int(z'3faac41065a8d145',c_int64_t), int(z'3fa99b4dcebfec14',c_int64_t), int(z'3fa8c01960235646',c_int64_t)]
  integer(c_int64_t), parameter :: b17_sfluxref_bits_1(80) = [ &
    int(z'40093fc115df6556',c_int64_t), int(z'400846a2b1704ff4',c_int64_t), int(z'40075d92b7fe08af',c_int64_t), int(z'40051c23b7952d23',c_int64_t), &
    int(z'4002c438088509c0',c_int64_t), int(z'40008f56eac86057',c_int64_t), int(z'3ffb584f4c6e6d9c',c_int64_t), int(z'3ff4a7525460aa65',c_int64_t), &
    int(z'3febfec7863beec4',c_int64_t), int(z'3fb87541cb7c6ab5',c_int64_t), int(z'3fb42b02e3094f34',c_int64_t), int(z'3fafd80940f161d8',c_int64_t), &
    int(z'3fa7813371469439',c_int64_t), int(z'3f9e1e6a4e52736a',c_int64_t), int(z'3f869b753bec3f59',c_int64_t), int(z'3f5a28f6187597b2',c_int64_t), &
    int(z'4006a6d9be4cd749',c_int64_t), int(z'4007ac6bce8533b1',c_int64_t), int(z'4007bbe22e5de15d',c_int64_t), int(z'400636d330941c82',c_int64_t), &
    int(z'4003beff1950331e',c_int64_t), int(z'4000eb21815a07b3',c_int64_t), int(z'3ffbb8088509bf9c',c_int64_t), int(z'3ff4d83a53b8e4b8',c_int64_t), &
    int(z'3fec3f316e371540',c_int64_t), int(z'3fb8a2db61bb05fb',c_int64_t), int(z'3fb488c967bd7e7b',c_int64_t), int(z'3fb0495c6a6421e9',c_int64_t), &
    int(z'3fa832b990afe60c',c_int64_t), int(z'3f9e9f7149ef375b',c_int64_t), int(z'3f86b05319828805',c_int64_t), int(z'3f5a28f6187597b2',c_int64_t), &
    int(z'400695810624dd2f',c_int64_t), int(z'4007966cf41f212d',c_int64_t), int(z'4007abc408d8ec96',c_int64_t), int(z'4006351ac9afe1da',c_int64_t), &
    int(z'4003c486ad2dcb14',c_int64_t), int(z'400101f75104d552',c_int64_t), int(z'3ffbd0c5eb313be2',c_int64_t), int(z'3ff4ed6777079e5a',c_int64_t), &
    int(z'3fec4cf6be37de94',c_int64_t), int(z'3fb8c0e969bb857d',c_int64_t), int(z'3fb487f60326fbed',c_int64_t), int(z'3fb0639bb0cb0e87',c_int64_t), &
    int(z'3fa8351f9c7d79a8',c_int64_t), int(z'3f9ec5d206c8711d',c_int64_t), int(z'3f870336ec2557a8',c_int64_t), int(z'3f5a59072d45de5c',c_int64_t), &
    int(z'40068985f06f6944',c_int64_t), int(z'400780cc78e9f6a9',c_int64_t), int(z'40079b76b3bb83cf',c_int64_t), int(z'400629e6eeb70260',c_int64_t), &
    int(z'4003d1394317acc5',c_int64_t), int(z'40011657fb69984a',c_int64_t), int(z'3ffbe5fd8adab9f5',c_int64_t), int(z'3ff5011b1d92b7fe',c_int64_t), &
    int(z'3fec65eedcc20d56',c_int64_t), int(z'3fb8c16fa1788b2c',c_int64_t), int(z'3fb4911a6f170f10',c_int64_t), int(z'3fb0724ed1f52aba',c_int64_t), &
    int(z'3fa8368349cbfbec',c_int64_t), int(z'3f9ecb31c219eb64',c_int64_t), int(z'3f8783b7b00515e9',c_int64_t), int(z'3f5a858793dd97f6',c_int64_t), &
    int(z'4006963886594af5',c_int64_t), int(z'40077414a4d2b2c0',c_int64_t), int(z'400750ff97247454',c_int64_t), int(z'4006045cbbc2b94e',c_int64_t), &
    int(z'4003eef5ec80c73b',c_int64_t), int(z'400127136a400fbb',c_int64_t), int(z'3ffc1dbca9691a76',c_int64_t), int(z'3ff52f251c193b3a',c_int64_t), &
    int(z'3fec98bb4d48882f',c_int64_t), int(z'3fb8d1ddadc5a089',c_int64_t), int(z'3fb49cf0662f0902',c_int64_t), int(z'3fb061e273273f09',c_int64_t), &
    int(z'3fa85337b578f331',c_int64_t), int(z'3f9f4ce08362f66f',c_int64_t), int(z'3f87a0d0c57fd171',c_int64_t), int(z'3f5a858793dd97f6',c_int64_t)]
  integer(c_int64_t), parameter :: b17_rayl_bits_1(1) = [ &
                                   int(z'3e07921eac14849d', c_int64_t)]
  integer(c_int64_t), parameter :: b17_strrat_bits_1(1) = [ &
                                   int(z'3fd756473471f794', c_int64_t)]
  integer(c_int), parameter :: b17_layreffr_bits_1(1) = [ &
                               int(z'0000001e', c_int)]
  integer(c_int64_t), parameter :: b18_selfref_bits_1(128) = [ &
    int(z'3f48968f4e112ffe',c_int64_t), int(z'3f452221cf18e895',c_int64_t), int(z'3f4229fb48829d20',c_int64_t), int(z'3f3f394509e41e3c',c_int64_t), &
    int(z'3f3ad62b56812743',c_int64_t), int(z'3f3710dbcdfa2701',c_int64_t), int(z'3f33d33114f5db64',c_int64_t), int(z'3f310a1c163eb957',c_int64_t), &
    int(z'3f2d4a68aeeb0f83',c_int64_t), int(z'3f292cd553b795b7',c_int64_t), int(z'3f564dea6e9e434d',c_int64_t), int(z'3f528b6828885f60',c_int64_t), &
    int(z'3f4ed651524f7a89',c_int64_t), int(z'3f49a3951b04be2b',c_int64_t), int(z'3f45512ce5b39aef',c_int64_t), int(z'3f41b945b1651253',c_int64_t), &
    int(z'3f3d78dd729d9289',c_int64_t), int(z'3f388108dca61155',c_int64_t), int(z'3f345f99a9c5f2cf',c_int64_t), int(z'3f30f06c7df16146',c_int64_t), &
    int(z'3f6b5b70691ea78b',c_int64_t), int(z'3f6500e8b33246fa',c_int64_t), int(z'3f6020238bf642e8',c_int64_t), int(z'3f58c2cf47fc4307',c_int64_t), &
    int(z'3f5302a6a36d57f2',c_int64_t), int(z'3f4d30c5f926a58f',c_int64_t), int(z'3f46694114d0d01a',c_int64_t), int(z'3f4134cca194f6d9',c_int64_t), &
    int(z'3f3a6b9e00281062',c_int64_t), int(z'3f3448cccd789944',c_int64_t), int(z'3f803fa8b76ec1aa',c_int64_t), int(z'3f78292ecd72e4fa',c_int64_t), &
    int(z'3f71f68252d610c3',c_int64_t), int(z'3f6ab5b8df0431e9',c_int64_t), int(z'3f63dbaa0a55188b',c_int64_t), int(z'3f5d8719ba3b4fb7',c_int64_t), &
    int(z'3f55f3fd684b1801',c_int64_t), int(z'3f50524e929b5ed2',c_int64_t), int(z'3f4844e7b2f98966',c_int64_t), int(z'3f420b1eb0def45b',c_int64_t), &
    int(z'3f80f5fd9da516fb',c_int64_t), int(z'3f7cccf26186d8a2',c_int64_t), int(z'3f7873d4b8ff657b',c_int64_t), int(z'3f74c2c537014900',c_int64_t), &
    int(z'3f71a063b8363cd3',c_int64_t), int(z'3f6dee47c6be14f9',c_int64_t), int(z'3f69697dc801e1d7',c_int64_t), int(z'3f65935a65513d8a',c_int64_t), &
    int(z'3f62517bc8a3476d',c_int64_t), int(z'3f5f1af853e42dbc',c_int64_t), int(z'3f81158edd7df4f8',c_int64_t), int(z'3f7ff540895d0b74',c_int64_t), &
    int(z'3f7de3fbbd7b2032',c_int64_t), int(z'3f7bf4f60bb56adb',c_int64_t), int(z'3f7a25f65ec1816a',c_int64_t), int(z'3f7874e9360f05ac',c_int64_t), &
    int(z'3f76dfe0a5c7a546',c_int64_t), int(z'3f75650c493984dc',c_int64_t), int(z'3f7402b942d74018',c_int64_t), int(z'3f72b7523c37e9a6',c_int64_t), &
    int(z'3f8863538c6f0eac',c_int64_t), int(z'3f870db346e9c95d',c_int64_t), int(z'3f85cabd28141b40',c_int64_t), int(z'3f8499722c6d4654',c_int64_t), &
    int(z'3f8378da06713349',c_int64_t), int(z'3f8268108a91beda',c_int64_t), int(z'3f816632e4d9b3e6',c_int64_t), int(z'3f807273bae2bf7d',c_int64_t), &
    int(z'3f7f18137222b232',c_int64_t), int(z'3f7d6479fd1c1ff1',c_int64_t), int(z'3f8d7df4f865010c',c_int64_t), int(z'3f8d08695b0d6cd0',c_int64_t), &
    int(z'3f8c94a614d21f1c',c_int64_t), int(z'3f8c22b891ac654e',c_int64_t), int(z'3f8bb285f9a9a4aa',c_int64_t), int(z'3f8b441bb8c32a8d',c_int64_t), &
    int(z'3f8ad76c62ffa999',c_int64_t), int(z'3f8a6c6a8c65d470',c_int64_t), int(z'3f8a0308c8fc5db4',c_int64_t), int(z'3f899b5484bc92c3',c_int64_t), &
    int(z'3f93105c6e95dfd1',c_int64_t), int(z'3f91f2e2e10b4833',c_int64_t), int(z'3f90e615732ecbc5',c_int64_t), int(z'3f8fd2051af1f3ce',c_int64_t), &
    int(z'3f8df57e9cbe1148',c_int64_t), int(z'3f8c34cf14a5a972',c_int64_t), int(z'3f8a8e71476af89c',c_int64_t), int(z'3f8900b7b5e452fb',c_int64_t), &
    int(z'3f878a4568bfdcfa',c_int64_t), int(z'3f8629bd68abbb04',c_int64_t), int(z'3f957130c4c3e9cf',c_int64_t), int(z'3f93f9d39614a9db',c_int64_t), &
    int(z'3f929c205c96d9cc',c_int64_t), int(z'3f915655772ad9c8',c_int64_t), int(z'3f9026d2d2a04b65',c_int64_t), int(z'3f8e18266772d5e0',c_int64_t), &
    int(z'3f8c09586e561ef1',c_int64_t), int(z'3f8a1e81cb46bacf',c_int64_t), int(z'3f88554683720fe8',c_int64_t), int(z'3f86ab4a9c0584a4',c_int64_t), &
    int(z'3f94dad9d5c9cb91',c_int64_t), int(z'3f93cb88292ecd73',c_int64_t), int(z'3f92ca0069b24b41',c_int64_t), int(z'3f91d5941bab5731',c_int64_t), &
    int(z'3f90ed8e0d745cc9',c_int64_t), int(z'3f901153e55a624c',c_int64_t), int(z'3f8e80969354dbfa',c_int64_t), int(z'3f8cf3c12d5c599d',c_int64_t), &
    int(z'3f8b7b1b29513222',c_int64_t), int(z'3f8a159817b95a29',c_int64_t), int(z'3f973901a94d6bc4',c_int64_t), int(z'3f9586876e1deacd',c_int64_t), &
    int(z'3f93f3d2cb138f29',c_int64_t), int(z'3f927e87c55bbf43',c_int64_t), int(z'3f912486c805bdaf',c_int64_t), int(z'3f8fc7962c26cf78',c_int64_t), &
    int(z'3f8d750b44d7a065',c_int64_t), int(z'3f8b4de997deae77',c_int64_t), int(z'3f894f1942c724ed',c_int64_t), int(z'3f87758fcf157c69',c_int64_t), &
    int(z'3f96b5a568dab4ed',c_int64_t), int(z'3f95890bacdc6c7d',c_int64_t), int(z'3f946c043518e681',c_int64_t), int(z'3f935db841fb4d13',c_int64_t), &
    int(z'3f925d6535e4be5b',c_int64_t), int(z'3f916a4f2932ff31',c_int64_t), int(z'3f9083ce5639c879',c_int64_t), int(z'3f8f526882a058d0',c_int64_t)]
  integer(c_int64_t), parameter :: b18_selfref_bits_2(32) = [ &
    int(z'3f8db3da8d7fafe4',c_int64_t), int(z'3f8c2ab0adb25552',c_int64_t), int(z'3f9c4113c68661ae',c_int64_t), int(z'3f99dda059a73b43',c_int64_t), &
    int(z'3f97add814ff6b86',c_int64_t), int(z'3f95ad67acb7838f',c_int64_t), int(z'3f93d845a6d33e00',c_int64_t), int(z'3f922ad3e920c06a',c_int64_t), &
    int(z'3f90a1aa095365d9',c_int64_t), int(z'3f8e737b21df4dd9',c_int64_t), int(z'3f8be07372be637d',c_int64_t), int(z'3f8985271bcdbbe0',c_int64_t), &
    int(z'3f9d8fc1a9831ba9',c_int64_t), int(z'3f9ba50c9462f8f4',c_int64_t), int(z'3f99da23cd64a241',c_int64_t), int(z'3f982d029789f4e1',c_int64_t), &
    int(z'3f969bb1a1ce1b81',c_int64_t), int(z'3f952461df1828ec',c_int64_t), int(z'3f93c56c863b1804',c_int64_t), int(z'3f927d3eefffd7bc',c_int64_t), &
    int(z'3f914a53e128a464',c_int64_t), int(z'3f902b4e6263a267',c_int64_t), int(z'3fa309ceb5db18c0',c_int64_t), int(z'3fa1cbff47735c18',c_int64_t), &
    int(z'3fa0a2e8cdb45359',c_int64_t), int(z'3f9f1a635894ec8c',c_int64_t), int(z'3f9d1328d1b0615c',c_int64_t), int(z'3f9b2dccc1e5123e',c_int64_t), &
    int(z'3f99681b724c4db6',c_int64_t), int(z'3f97bffc03f1fd08',c_int64_t), int(z'3f96338491ca983f',c_int64_t), int(z'3f94c0e60ebd3225',c_int64_t)]
  integer(c_int64_t), parameter :: b18_forref_bits_1(48) = [ &
    int(z'3eace02773ea8efc',c_int64_t), int(z'3eb5e24ff8df2201',c_int64_t), int(z'3ed009c0a49c9647',c_int64_t), int(z'3eab71ee4b9a21eb',c_int64_t), &
    int(z'3eba9bc67250369d',c_int64_t), int(z'3f1144eff5d10fee',c_int64_t), int(z'3eb5b45b329eed4f',c_int64_t), int(z'3ee149fefa900a3f',c_int64_t), &
    int(z'3f18f9fc23e02b90',c_int64_t), int(z'3ed268d89c91d91f',c_int64_t), int(z'3f03adf1653e9062',c_int64_t), int(z'3f1f396765fbee8a',c_int64_t), &
    int(z'3f000bd3d835b4e3',c_int64_t), int(z'3f105386d11a2d61',c_int64_t), int(z'3f1a688c05875371',c_int64_t), int(z'3f1761aaf1aefa16',c_int64_t), &
    int(z'3f167327f894114a',c_int64_t), int(z'3f10a95347911357',c_int64_t), int(z'3f2689fc9000601a',c_int64_t), int(z'3f26bb60f23bcfc2',c_int64_t), &
    int(z'3f100930acfb5e20',c_int64_t), int(z'3f3772cdd2dc306d',c_int64_t), int(z'3f303459e8987419',c_int64_t), int(z'3f09a16be9ebbe15',c_int64_t), &
    int(z'3f3567d31a662a23',c_int64_t), int(z'3f32f8847a67690a',c_int64_t), int(z'3f0cc65343c669b6',c_int64_t), int(z'3f369dde1947c70b',c_int64_t), &
    int(z'3f3507c66a547f00',c_int64_t), int(z'3f10996d5e592500',c_int64_t), int(z'3f39ba2e6d2e5f42',c_int64_t), int(z'3f354f29804e6662',c_int64_t), &
    int(z'3f13841d2edaa105',c_int64_t), int(z'3f36e3e54ad0915b',c_int64_t), int(z'3f36a65fa5acf846',c_int64_t), int(z'3f180662eed85276',c_int64_t), &
    int(z'3f3bdd04972d477b',c_int64_t), int(z'3f36d60df1b8c811',c_int64_t), int(z'3f207cbeb144f5c2',c_int64_t), int(z'3f3ab64ae6696733',c_int64_t), &
    int(z'3f3c901d5dcdaa5c',c_int64_t), int(z'3f32d8d79473616e',c_int64_t), int(z'3f41178a354d94b3',c_int64_t), int(z'3f3fe3b9e8077f95',c_int64_t), &
    int(z'3f3faff7eea85893',c_int64_t), int(z'3f495b055f3a7821',c_int64_t), int(z'3f482879e0858021',c_int64_t), int(z'3f45d24d1cf1dbd9',c_int64_t)]
  integer(c_int64_t), parameter :: b18_sfluxref_bits_1(128) = [ &
    int(z'400d4467381d7dbf',c_int64_t), int(z'400c59999999999a',c_int64_t), int(z'400ac22bbecaab8a',c_int64_t), int(z'4008d7bc7f77af64',c_int64_t), &
    int(z'400663ec02f2f987',c_int64_t), int(z'40036d6238da3c21',c_int64_t), int(z'3fffccb7d41743e9',c_int64_t), int(z'3ff7e67b5f1bef4a',c_int64_t), &
    int(z'3ff00807357e670e',c_int64_t), int(z'3fbbbc4d22c881e4',c_int64_t), int(z'3fb6ea1eed2b1126',c_int64_t), int(z'3fb20d97983799ca',c_int64_t), &
    int(z'3faa70fa3e1f1f80',c_int64_t), int(z'3fa0c660a2014728',c_int64_t), int(z'3f89a092b21ecb9d',c_int64_t), int(z'3f5c583017cacced',c_int64_t), &
    int(z'400ee8e60807357e',c_int64_t), int(z'400be1b5c7cd898b',c_int64_t), int(z'400a7694467381d8',c_int64_t), int(z'4008a5f30e7ff584',c_int64_t), &
    int(z'40063443d46b26c0',c_int64_t), int(z'400341fc8f32378b',c_int64_t), int(z'3fff91b1d92b7fe1',c_int64_t), int(z'3ff7af05a708ede5',c_int64_t), &
    int(z'3fefc71b47842310',c_int64_t), int(z'3fbb91a32b12d341',c_int64_t), int(z'3fb6a433508f648c',c_int64_t), int(z'3fb1e7494fd52a69',c_int64_t), &
    int(z'3faa00e5d90d4cf0',c_int64_t), int(z'3fa098519afd46e8',c_int64_t), int(z'3f8876336303db57',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t), &
    int(z'400f3ac710cb295f',c_int64_t), int(z'400c0d74927913e8',c_int64_t), int(z'400a73482be8bc17',c_int64_t), int(z'40087bd273d5bab2',c_int64_t), &
    int(z'40062897635e742a',c_int64_t), int(z'4003314b9cb6848c',c_int64_t), int(z'3fff6ad2dcb1465f',c_int64_t), int(z'3ff797e132b55ef2',c_int64_t), &
    int(z'3fefa19652bd3c36',c_int64_t), int(z'3fbb508f648c7193',c_int64_t), int(z'3fb667fc689bcacc',c_int64_t), int(z'3fb18f19e3d6d48e',c_int64_t), &
    int(z'3fa9d87d04379d25',c_int64_t), int(z'3fa00ff6ee0886b7',c_int64_t), int(z'3f866eaf0a4426a0',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t), &
    int(z'400f7404ea4a8c15',c_int64_t), int(z'400c2a25d8d79d0a',c_int64_t), int(z'400a81f75104d552',c_int64_t), int(z'40086540cc78e9f7',c_int64_t), &
    int(z'400615feda661284',c_int64_t), int(z'400327967caea748',c_int64_t), int(z'3fff49f94855da27',c_int64_t), int(z'3ff77952d234eb9a',c_int64_t), &
    int(z'3fef7d63022dd7aa',c_int64_t), int(z'3fbb1b4784230fd0',c_int64_t), int(z'3fb659b2f9bcefe0',c_int64_t), int(z'3fb183042bdeab1c',c_int64_t), &
    int(z'3fa8f5034cbb9a75',c_int64_t), int(z'3f9ea5d6bebe1651',c_int64_t), int(z'3f866eaf0a4426a0',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t), &
    int(z'400f86cca2db61bb',c_int64_t), int(z'400c6aed1394317b',c_int64_t), int(z'400a8c8de2ac3223',c_int64_t), int(z'400860ded288ce70',c_int64_t), &
    int(z'4005fe52157689ca',c_int64_t), int(z'400310f51ac9afe2',c_int64_t), int(z'3fff3be22e5de15d',c_int64_t), int(z'3ff7579d0a67620f',c_int64_t), &
    int(z'3fef530ced4e4c94',c_int64_t), int(z'3fbae7f6f4be835e',c_int64_t), int(z'3fb629a946b5c6f7',c_int64_t), int(z'3fb144d0ea68bf06',c_int64_t), &
    int(z'3fa866c962b500fe',c_int64_t), int(z'3f9dccd6070831fe',c_int64_t), int(z'3f866eaf0a4426a0',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t), &
    int(z'400f892ccf6be37e',c_int64_t), int(z'400cb30e7ff583a5',c_int64_t), int(z'400a9187e7c06e1a',c_int64_t), int(z'40087822bbecaab9',c_int64_t), &
    int(z'4005ede00d1b7176',c_int64_t), int(z'4002f482be8bc16a',c_int64_t), int(z'3fff16bb98c7e282',c_int64_t), int(z'3ff73a92a3055326',c_int64_t), &
    int(z'3fef18dac258d584',c_int64_t), int(z'3fbaa2b1704ff434',c_int64_t), int(z'3fb5db02f0754881',c_int64_t), int(z'3fb0e9a97c65ac2c',c_int64_t), &
    int(z'3fa7b79f3e1e48c0',c_int64_t), int(z'3f9dcccf510b8b4e',c_int64_t), int(z'3f866fae0dc4e4a1',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t), &
    int(z'400f7cd898b2e9cd',c_int64_t), int(z'400d11bc55864452',c_int64_t), int(z'400aa6ca03c4b09f',c_int64_t), int(z'4008800a7c5ac472',c_int64_t), &
    int(z'4005eca03c4b09ea',c_int64_t), int(z'4002d6e04c059210',c_int64_t), int(z'3ffed7d1782d3847',c_int64_t), int(z'3ff716872b020c4a',c_int64_t), &
    int(z'3feec723aafff36b',c_int64_t), int(z'3fba557de0d66f0d',c_int64_t), int(z'3fb55ac6f5f336c4',c_int64_t), int(z'3fb068e3ef284168',c_int64_t), &
    int(z'3fa7a53ee949db15',c_int64_t), int(z'3f9dcc8c352d0877',c_int64_t), int(z'3f866fbb79be31ff',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t), &
    int(z'400f66cf41f212d7',c_int64_t), int(z'400d86b7aa25d8d8',c_int64_t), int(z'400ada3c21187e7c',c_int64_t), int(z'4008907c84b5dcc6',c_int64_t), &
    int(z'4005e8b19a415f46',c_int64_t), int(z'4002c1205bc01a37',c_int64_t), int(z'3ffe6e0f3cb3e575',c_int64_t), int(z'3ff6c23b7952d235',c_int64_t), &
    int(z'3fee4b2b777d0f1f',c_int64_t), int(z'3fb9815d62b1a600',c_int64_t), int(z'3fb4d963b4047eeb',c_int64_t), int(z'3fb05945ec735b41',c_int64_t), &
    int(z'3fa7a4d3897f7023',c_int64_t), int(z'3f9dccd6070831fe',c_int64_t), int(z'3f866fbb79be31ff',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t)]
  integer(c_int64_t), parameter :: b18_sfluxref_bits_2(16) = [ &
    int(z'400e752a84380885',c_int64_t), int(z'400df4784230fcf8',c_int64_t), int(z'400c0432ca57a787',c_int64_t), int(z'400970d306a2b170',c_int64_t), &
    int(z'40060f80dc33721d',c_int64_t), int(z'400255c52e72da12',c_int64_t), int(z'3ffd8049667b5f1c',c_int64_t), int(z'3ff5b606b7aa25d9',c_int64_t), &
    int(z'3fed3fd0d0678c00',c_int64_t), int(z'3fb9432a213bb9ea',c_int64_t), int(z'3fb4d8bbee5837cf',c_int64_t), int(z'3fb058be07372be6',c_int64_t), &
    int(z'3fa7a4d6e47dc37a',c_int64_t), int(z'3f9dcb5781c714fd',c_int64_t), int(z'3f8672e0c82c541c',c_int64_t), int(z'3f59d2b9f6b14cbf',c_int64_t)]
  integer(c_int64_t), parameter :: b18_rayl_bits_1(1) = [ &
                                   int(z'3e17e148ded9d33a', c_int64_t)]
  integer(c_int64_t), parameter :: b18_strrat_bits_1(1) = [ &
                                   int(z'40437abd3c361134', c_int64_t)]
  integer(c_int), parameter :: b18_layreffr_bits_1(1) = [ &
                               int(z'00000006', c_int)]
  integer(c_int64_t), parameter :: b19_selfref_bits_1(128) = [ &
    int(z'3f35bd78e94245c2',c_int64_t), int(z'3f32d71d32c0c786',c_int64_t), int(z'3f3053caad62cf2d',c_int64_t), int(z'3f2c4c893cf77996',c_int64_t), &
    int(z'3f28863c4d40d917',c_int64_t), int(z'3f2540d14ddd4ff4',c_int64_t), int(z'3f226b119bdec344',c_int64_t), int(z'3f1fec50edfb9300',c_int64_t), &
    int(z'3f1baa445080babf',c_int64_t), int(z'3f17f998732e13f2',c_int64_t), int(z'3f4cec0532801621',c_int64_t), int(z'3f46e6ea62e8602f',c_int64_t), &
    int(z'3f42229533e1e266',c_int64_t), int(z'3f3cb883a5cd95b1',c_int64_t), int(z'3f36be215223fdfb',c_int64_t), int(z'3f32024b89c13468',c_int64_t), &
    int(z'3f2c8560965c9216',c_int64_t), int(z'3f2695a14512366c',c_int64_t), int(z'3f21e23bdb08b5ed',c_int64_t), int(z'3f1c52936d27173e',c_int64_t), &
    int(z'3f52eac90c22f8fe',c_int64_t), int(z'3f4eb5d41e0b1416',c_int64_t), int(z'3f48ed773c4c8c76',c_int64_t), int(z'3f443bd9167e93fc',c_int64_t), &
    int(z'3f406c7f04420406',c_int64_t), int(z'3f3aa9979c1c087d',c_int64_t), int(z'3f35a45b585a22fb',c_int64_t), int(z'3f31911db050508c',c_int64_t), &
    int(z'3f2c84a39bd9986b',c_int64_t), int(z'3f2725f29417e0ae',c_int64_t), int(z'3f50f301eabbcb1d',c_int64_t), int(z'3f4f774fd3e3fe7e',c_int64_t), &
    int(z'3f4d3545064467b9',c_int64_t), int(z'3f4b1cb58724bbbb',c_int64_t), int(z'3f492aa6fb349cc8',c_int64_t), int(z'3f475c54b708e29f',c_int64_t), &
    int(z'3f45af31e4dd177b',c_int64_t), int(z'3f4420d856878ff1',c_int64_t), int(z'3f42af1568025907',c_int64_t), int(z'3f4157daf720cd19',c_int64_t), &
    int(z'3f67ad9baf1d8f5d',c_int64_t), int(z'3f63abdec09530ff',c_int64_t), int(z'3f6057b6a03a9d8b',c_int64_t), int(z'3f5b27837ca1bc28',c_int64_t), &
    int(z'3f568f3897a11bef',c_int64_t), int(z'3f52bdf2bf4fb6a2',c_int64_t), int(z'3f4f241f3b7bf96d',c_int64_t), int(z'3f49df1980849fb7',c_int64_t), &
    int(z'3f457e5d64456018',c_int64_t), int(z'3f41db4571b56030',c_int64_t), int(z'3f6da2e8a2c13595',c_int64_t), int(z'3f691e1945a149e7',c_int64_t), &
    int(z'3f6549ae1ee1c27d',c_int64_t), int(z'3f620abf20bcb903',c_int64_t), int(z'3f5e950bc05295fa',c_int64_t), int(z'3f59eb4e173a2e4f',c_int64_t), &
    int(z'3f55f798d34b1629',c_int64_t), int(z'3f529e27c8c6d8c2',c_int64_t), int(z'3f4f8ee241ba45c8',c_int64_t), int(z'3f4abf112afe3909',c_int64_t), &
    int(z'3f6b060b06ef327d',c_int64_t), int(z'3f6a1214d57a1a78',c_int64_t), int(z'3f6926b27156da57',c_int64_t), int(z'3f6843a36dd8cb89',c_int64_t), &
    int(z'3f67689743281dd6',c_int64_t), int(z'3f66953d696d010a',c_int64_t), int(z'3f65c96030c23fab',c_int64_t), int(z'3f6504af11500983',c_int64_t), &
    int(z'3f6446e99e69b800',c_int64_t), int(z'3f638fda282a15a8',c_int64_t), int(z'3f680c70fc976ac0',c_int64_t), int(z'3f68951220690120',c_int64_t), &
    int(z'3f6920bdbab61ee0',c_int64_t), int(z'3f69af7e88463519',c_int64_t), int(z'3f6a416f610bde86',c_int64_t), int(z'3f6ad695a36ad3b3',c_int64_t), &
    int(z'3f6b6f1185b967eb',c_int64_t), int(z'3f6c0aedc4bf0c45',c_int64_t), int(z'3f6caa3fda0aa2f1',c_int64_t), int(z'3f6d4d17e0c75595',c_int64_t), &
    int(z'3f670e7f49b72e2a',c_int64_t), int(z'3f683d58d0fc8750',c_int64_t), int(z'3f697bbc8ee70e17',c_int64_t), int(z'3f6aca7be4a7dfd8',c_int64_t), &
    int(z'3f6c2a62d50c6162',c_int64_t), int(z'3f6d9c583ad4923e',c_int64_t), int(z'3f6f214dad87e30e',c_int64_t), int(z'3f705d1a6256e23a',c_int64_t), &
    int(z'3f71340a48ae44a1',c_int64_t), int(z'3f721604cf1cb33f',c_int64_t), int(z'3f639e6d68e41a1b',c_int64_t), int(z'3f6580c059cccffd',c_int64_t), &
    int(z'3f67916c2394afa5',c_int64_t), int(z'3f69d4d834091c08',c_int64_t), int(z'3f6c4fe773ed0cb3',c_int64_t), int(z'3f6f07f846f90dc8',c_int64_t), &
    int(z'3f71016f96bbc3bb',c_int64_t), int(z'3f72a3862c7f64e5',c_int64_t), int(z'3f746dc32706aa13',c_int64_t), int(z'3f7664025dfe37ff',c_int64_t), &
    int(z'3f66334d8a4c74a3',c_int64_t), int(z'3f67f09cb5adcc57',c_int64_t), int(z'3f69d0d6c7a26b7a',c_int64_t), int(z'3f6bd6aaf2069820',c_int64_t), &
    int(z'3f6e0513902ab002',c_int64_t), int(z'3f702fa056a2232b',c_int64_t), int(z'3f71744eb168ee2b',c_int64_t), int(z'3f72d26d4ab1292d',c_int64_t), &
    int(z'3f744bfa297c5033',c_int64_t), int(z'3f75e31b98b7c757',c_int64_t), int(z'3f60eedae99b0eba',c_int64_t), int(z'3f6306b82aff3225',c_int64_t), &
    int(z'3f6560da8b515761',c_int64_t), int(z'3f68056519b532d2',c_int64_t), int(z'3f6afd976ff3ade2',c_int64_t), int(z'3f6e53bd974fbd58',c_int64_t), &
    int(z'3f7109c0482f18c7',c_int64_t), int(z'3f7324f32982db3c',c_int64_t), int(z'3f7582cbccc7995c',c_int64_t), int(z'3f782b8ac8457e8f',c_int64_t), &
    int(z'3f62990473573aa4',c_int64_t), int(z'3f65149f495be98b',c_int64_t), int(z'3f67e513eb6f4f43',c_int64_t), int(z'3f6b15bad24e6bf4',c_int64_t), &
    int(z'3f6eb369a45e6ea0',c_int64_t), int(z'3f71665721fad198',c_int64_t), int(z'3f73b9023fa053f3',c_int64_t), int(z'3f765b109cdb4286',c_int64_t)]
  integer(c_int64_t), parameter :: b19_selfref_bits_2(32) = [ &
    int(z'3f79571ecac66250',c_int64_t), int(z'3f7cb92bb0320c6d',c_int64_t), int(z'3f4be35c169279d1',c_int64_t), int(z'3f524526fb97658d',c_int64_t), &
    int(z'3f57f041710e8b08',c_int64_t), int(z'3f5f5d889c464737',c_int64_t), int(z'3f648c540bc5dbed',c_int64_t), int(z'3f6aec5a5bc11bea',c_int64_t), &
    int(z'3f71a358b522e202',c_int64_t), int(z'3f771c391baa8072',c_int64_t), int(z'3f7e47b6a2e9cf67',c_int64_t), int(z'3f83d6566363fd80',c_int64_t), &
    int(z'3f7e6be3a8dc57af',c_int64_t), int(z'3f7d8bdf1bd9d040',c_int64_t), int(z'3f7cb24d6f9f7526',c_int64_t), int(z'3f7bdefe52abc972',c_int64_t), &
    int(z'3f7b11c1737d5038',c_int64_t), int(z'3f7a4a6bdef64516',c_int64_t), int(z'3f7988d2a1f8e3ac',c_int64_t), int(z'3f78cccac9676798',c_int64_t), &
    int(z'3f78162c1155e8c0',c_int64_t), int(z'3f7764ce35d87f08',c_int64_t), int(z'3f85f2cb641700ce',c_int64_t), int(z'3f84df2d21a13a78',c_int64_t), &
    int(z'3f83d913013990f0',c_int64_t), int(z'3f82dfd53d33bd1c',c_int64_t), int(z'3f81f2d16e47306b',c_int64_t), int(z'3f81116d3ac0f121',c_int64_t), &
    int(z'3f803b17ae1c8877',c_int64_t), int(z'3f7ede8d13a44ca6',c_int64_t), int(z'3f7d5ae72c498a0d',c_int64_t), int(z'3f7bea46b03d9ff4',c_int64_t)]
  integer(c_int64_t), parameter :: b19_forref_bits_1(48) = [ &
    int(z'3eb1d479fb7fced3',c_int64_t), int(z'3eb17ab6307c6a4c',c_int64_t), int(z'3ed19f5e85698768',c_int64_t), int(z'3eb9e4fb3b4df589',c_int64_t), &
    int(z'3edb659b3f280a68',c_int64_t), int(z'3ef24ec6937609b5',c_int64_t), int(z'3ecd44ef7e3ea894',c_int64_t), int(z'3ee6bcc1222fe6df',c_int64_t), &
    int(z'3f0c5b27037f2f6e',c_int64_t), int(z'3eee94c24eac7bee',c_int64_t), int(z'3ef05c516131f940',c_int64_t), int(z'3f171a0e4e406298',c_int64_t), &
    int(z'3ef7170e5d928c9d',c_int64_t), int(z'3f157e33bb0219ed',c_int64_t), int(z'3f15711510ea5044',c_int64_t), int(z'3f077ace85e81484',c_int64_t), &
    int(z'3f1fbff5093d26b8',c_int64_t), int(z'3f1872cebac9d12b',c_int64_t), int(z'3f25d3598c6be737',c_int64_t), int(z'3f2359f9f1731f5c',c_int64_t), &
    int(z'3f13c433f545a9e8',c_int64_t), int(z'3f2ec51aaf615f9f',c_int64_t), int(z'3f2320bb83c695f3',c_int64_t), int(z'3f143b04ea9eba83',c_int64_t), &
    int(z'3f32f4169b558f06',c_int64_t), int(z'3f233cb7852bbd37',c_int64_t), int(z'3f11c4add759bcb7',c_int64_t), int(z'3f35f3adf354064e',c_int64_t), &
    int(z'3f20738475dfc4e6',c_int64_t), int(z'3f10b078ef85277f',c_int64_t), int(z'3f35df7acf5410a3',c_int64_t), int(z'3f21e6b251208404',c_int64_t), &
    int(z'3f0f1fd94ddf67f7',c_int64_t), int(z'3f3648f544eea517',c_int64_t), int(z'3f1e7a0269559ddb',c_int64_t), int(z'3f0f348823ceb1ec',c_int64_t), &
    int(z'3f3bafded562f36a',c_int64_t), int(z'3f237d3df6e42b16',c_int64_t), int(z'3f1085a4be3c9b7a',c_int64_t), int(z'3f3ce0f6d0566f22',c_int64_t), &
    int(z'3f0837beba0dce0c',c_int64_t), int(z'3ee6b21fd79ea870',c_int64_t), int(z'3f3fdd332a018ed4',c_int64_t), int(z'3f3c145519037e87',c_int64_t), &
    int(z'3ee6aad2ac28cb22',c_int64_t), int(z'3f458b330aaa8f1b',c_int64_t), int(z'3f458b0e88d141c9',c_int64_t), int(z'3eea76c62763939b',c_int64_t)]
  integer(c_int64_t), parameter :: b19_sfluxref_bits_1(128) = [ &
    int(z'400a10331e3a7daa',c_int64_t), int(z'400a6031ceaf251c',c_int64_t), int(z'400948509bf9c62a',c_int64_t), int(z'4007b06f69446738',c_int64_t), &
    int(z'400589fe86833c60',c_int64_t), int(z'4002b49cf56eac86',c_int64_t), int(z'3ffed77318fc5048',c_int64_t), int(z'3ff72fd75e2046c7',c_int64_t), &
    int(z'3fef5a3a08398a65',c_int64_t), int(z'3fbb7a5f41aef6f9',c_int64_t), int(z'3fb6e6588f0d4e9d',c_int64_t), int(z'3fb1e08aefb2aae3',c_int64_t), &
    int(z'3faa378e0bc6dda0',c_int64_t), int(z'3fa092146a1a500d',c_int64_t), int(z'3f8945c42f6f5954',c_int64_t), int(z'3f5c127a80fa9156',c_int64_t), &
    int(z'4009d24f227d028a',c_int64_t), int(z'400a4e2c12ad81ae',c_int64_t), int(z'400955bff04577d9',c_int64_t), int(z'4007d01e2584f4c7',c_int64_t), &
    int(z'40058f41f212d773',c_int64_t), int(z'4002c059210385c6',c_int64_t), int(z'3ffedd2f1a9fbe77',c_int64_t), int(z'3ff7433721d53cde',c_int64_t), &
    int(z'3fef70d1fa333765',c_int64_t), int(z'3fbb8e29f9ce8d97',c_int64_t), int(z'3fb6d8d0104e2bdd',c_int64_t), int(z'3fb1eac42e9899bf',c_int64_t), &
    int(z'3faa1876ef4aa616',c_int64_t), int(z'3fa093f799293152',c_int64_t), int(z'3f891f99227b550b',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t), &
    int(z'4009c894c447c30d',c_int64_t), int(z'400a38ef34d6a162',c_int64_t), int(z'400964d7f0ed3d86',c_int64_t), int(z'4007c57d1782d384',c_int64_t), &
    int(z'40059532617c1bda',c_int64_t), int(z'4002cca8198f1d3f',c_int64_t), int(z'3ffee7a0f9096bba',c_int64_t), int(z'3ff73b3a68b19a41',c_int64_t), &
    int(z'3fef87d0aed99cbf',c_int64_t), int(z'3fbba7a85015c209',c_int64_t), int(z'3fb6dffb7dba4002',c_int64_t), int(z'3fb1eb1b6c6d10a5',c_int64_t), &
    int(z'3faa32aa77376f02',c_int64_t), int(z'3fa0a1d24d3f4df4',c_int64_t), int(z'3f88b4ccfbc6b55c',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t), &
    int(z'4009cbac710cb296',c_int64_t), int(z'400a16cb5350092d',c_int64_t), int(z'4009799c38b04ab6',c_int64_t), int(z'4007c0f12c27a637',c_int64_t), &
    int(z'400590fa58f7121b',c_int64_t), int(z'4002d8cd20afa2f0',c_int64_t), int(z'3ffef3e0370cdc87',c_int64_t), int(z'3ff7311c6d1e108c',c_int64_t), &
    int(z'3fef9858bc59b802',c_int64_t), int(z'3fbbcdee34fc610f',c_int64_t), int(z'3fb6d378b87881f2',c_int64_t), int(z'3fb1fa2c81684a6c',c_int64_t), &
    int(z'3faa43bb40b34e77',c_int64_t), int(z'3fa0a78946653f1f',c_int64_t), int(z'3f88d1cb394ed627',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t), &
    int(z'4009ccbd1244a622',c_int64_t), int(z'400a023b7952d235',c_int64_t), int(z'40097fd0d0678c00',c_int64_t), int(z'4007c1f212d77319',c_int64_t), &
    int(z'40058e8a71de69ad',c_int64_t), int(z'4002e1b089a02752',c_int64_t), int(z'3ffeed9be4cd7492',c_int64_t), int(z'3ff73c60029f16b1',c_int64_t), &
    int(z'3fefa250f840181e',c_int64_t), int(z'3fbbb69984a0e411',c_int64_t), int(z'3fb6e1cde5d18091',c_int64_t), int(z'3fb20379314445aa',c_int64_t), &
    int(z'3faa443767755a1f',c_int64_t), int(z'3fa0ddb1f75e70cf',c_int64_t), int(z'3f88d1cb394ed627',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t), &
    int(z'4009cf80dc33721d',c_int64_t), int(z'4009ef1561911490',c_int64_t), int(z'40097b5f1bef49cf',c_int64_t), int(z'4007cacaff6d3309',c_int64_t), &
    int(z'400595a5b9628cbd',c_int64_t), int(z'4002dbff04577d95',c_int64_t), int(z'3ffef0b8cfbfc654',c_int64_t), int(z'3ff74ca2db61bb06',c_int64_t), &
    int(z'3fef9ec7000431be',c_int64_t), int(z'3fbbbc6eb0b7c350',c_int64_t), int(z'3fb6dd98cceaffbe',c_int64_t), int(z'3fb20badb32c11d7',c_int64_t), &
    int(z'3faa84b78a4568c0',c_int64_t), int(z'3fa0f893faf42785',c_int64_t), int(z'3f88d002e2328f9f',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t), &
    int(z'4009d2ccf6be37df',c_int64_t), int(z'4009e31a4bdba0a5',c_int64_t), int(z'40096ae7d566cf42',c_int64_t), int(z'4007d45b6c3760bf',c_int64_t), &
    int(z'40059f99c38b04ab',c_int64_t), int(z'4002d5bab21815a0',c_int64_t), int(z'3ffef8183f91e647',c_int64_t), int(z'3ff756c0d6f544bb',c_int64_t), &
    int(z'3fefa30db6a1e81d',c_int64_t), int(z'3fbbb2dd377e1b8f',c_int64_t), int(z'3fb6ded288ce703b',c_int64_t), int(z'3fb22bae03b3e9a7',c_int64_t), &
    int(z'3faaddc7c6d38e88',c_int64_t), int(z'3fa0f6639f0bc962',c_int64_t), int(z'3f88ce7da6f4cbef',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t), &
    int(z'4009d657fb69984a',c_int64_t), int(z'4009ed4d4024b33e',c_int64_t), int(z'4009410b630a9153',c_int64_t), int(z'4007da8ac5c13fd1',c_int64_t), &
    int(z'4005abe8bc169c24',c_int64_t), int(z'4002cc49ba5e353f',c_int64_t), int(z'3fff044d013a92a3',c_int64_t), int(z'3ff76aa8eb463498',c_int64_t), &
    int(z'3fefa22706d50657',c_int64_t), int(z'3fbbcb81733226c4',c_int64_t), int(z'3fb71ac4a7645d78',c_int64_t), int(z'3fb2401d26817409',c_int64_t), &
    int(z'3faadf3c3b19b182',c_int64_t), int(z'3fa0f3958e721e2b',c_int64_t), int(z'3f88cb07d0aed99d',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t)]
  integer(c_int64_t), parameter :: b19_sfluxref_bits_2(16) = [ &
    int(z'400a2de00d1b7176',c_int64_t), int(z'4009f928e0c9d9d3',c_int64_t), int(z'40091c62a1b5c7ce',c_int64_t), int(z'40079e7967caea74',c_int64_t), &
    int(z'40059d7dbf487fcc',c_int64_t), int(z'4002c1bda5119ce0',c_int64_t), int(z'3fff081c2e33eff2',c_int64_t), int(z'3ff789aaa3ad18d2',c_int64_t), &
    int(z'3fefb4ce3de6149c',c_int64_t), int(z'3fbbd5bab21815a0',c_int64_t), int(z'3fb714e3bcd35a86',c_int64_t), int(z'3fb2426d62d9e9ec',c_int64_t), &
    int(z'3faaded4364d99e7',c_int64_t), int(z'3fa0f3923373cad3',c_int64_t), int(z'3f88ce7da6f4cbef',c_int64_t), int(z'3f5990cabdfed3b0',c_int64_t)]
  integer(c_int64_t), parameter :: b19_rayl_bits_1(1) = [ &
                                   int(z'3e23abc364b196fa', c_int64_t)]
  integer(c_int64_t), parameter :: b19_strrat_bits_1(1) = [ &
                                   int(z'4015f8a32f44912a', c_int64_t)]
  integer(c_int), parameter :: b19_layreffr_bits_1(1) = [ &
                               int(z'00000003', c_int)]
  integer(c_int64_t), parameter :: b20_selfref_bits_1(128) = [ &
    int(z'3f2c734205cdb920',c_int64_t), int(z'3f271eb32711f04b',c_int64_t), int(z'3f22c9c2677f5155',c_int64_t), int(z'3f1e893e3de4784b',c_int64_t), &
    int(z'3f18d09e780197a5',c_int64_t), int(z'3f142a65767fcdbb',c_int64_t), int(z'3f10632ee15a7192',c_int64_t), int(z'3f0aa25ac2cb1487',c_int64_t), &
    int(z'3f05a4e2350467c5',c_int64_t), int(z'3f0196bff0517e7b',c_int64_t), int(z'3f4398d95546587f',c_int64_t), int(z'3f3fc5ad9eb435a7',c_int64_t), &
    int(z'3f39c17225b749ae',c_int64_t), int(z'3f34e0e2ae607b15',c_int64_t), int(z'3f30ecbfe4e57af7',c_int64_t), int(z'3f2b708da080d846',c_int64_t), &
    int(z'3f263e5ad9955d1f',c_int64_t), int(z'3f22080cb63e376b',c_int64_t), int(z'3f1d3bd8a6d34697',c_int64_t), int(z'3f17b2b1eb0a7faa',c_int64_t), &
    int(z'3f50d32c376b7c25',c_int64_t), int(z'3f4e7bc33c4caed2',c_int64_t), int(z'3f4b9d6a5e9891b2',c_int64_t), int(z'3f49042c794986cb',c_int64_t), &
    int(z'3f46a98719dc9768',c_int64_t), int(z'3f448798dd7e6d3b',c_int64_t), int(z'3f429909d1baf331',c_int64_t), int(z'3f40d9050338de5d',c_int64_t), &
    int(z'3f3e864e9f5b8ba8',c_int64_t), int(z'3f3ba6fa80394b50',c_int64_t), int(z'3f6fd4e1ef1dda86',c_int64_t), int(z'3f6de8a8f658e244',c_int64_t), &
    int(z'3f6c1a2cd1f0223c',c_int64_t), int(z'3f6a679fcc639b5b',c_int64_t), int(z'3f68cf4f0825e949',c_int64_t), int(z'3f674fad3c63b384',c_int64_t), &
    int(z'3f65e7327ead5a16',c_int64_t), int(z'3f649481d7b1016a',c_int64_t), int(z'3f635643ae808678',c_int64_t), int(z'3f622b40a0841980',c_int64_t), &
    int(z'3fa1e97d06bbdbe4',c_int64_t), int(z'3fa0b9d57943b8bc',c_int64_t), int(z'3f9f3c925785f8d3',c_int64_t), int(z'3f9d2b0a6fc58ab9',c_int64_t), &
    int(z'3f9b3c8efc87a57b',c_int64_t), int(z'3f996ed824efa391',c_int64_t), int(z'3f97bfab7c1a2cd2',c_int64_t), int(z'3f962d11b1026beb',c_int64_t), &
    int(z'3f94b520de9cd8e9',c_int64_t), int(z'3f93561763c9d3f4',c_int64_t), int(z'3faf6bf444e0daa1',c_int64_t), int(z'3faccf1b5ba61904',c_int64_t), &
    int(z'3faa69df97aaac11',c_int64_t), int(z'3fa837a0803da801',c_int64_t), int(z'3fa63422467be554',c_int64_t), int(z'3fa45b805956b36b',c_int64_t), &
    int(z'3fa2aa2a0a958538',c_int64_t), int(z'3fa11cdbd8d94a8a',c_int64_t), int(z'3f9f6131733f92bd',c_int64_t), int(z'3f9cc5395a94a10c',c_int64_t), &
    int(z'3fb0d19736e8ca59',c_int64_t), int(z'3faedb2f661f18ca',c_int64_t), int(z'3fac4e0daa0cae64',c_int64_t), int(z'3fa9f6ec5b078d93',c_int64_t), &
    int(z'3fa7d1569f490603',c_int64_t), int(z'3fa5d92edadede47',c_int64_t), int(z'3fa40ab8c0a64ddd',c_int64_t), int(z'3fa2627e7a596272',c_int64_t), &
    int(z'3fa0dd575e8ba692',c_int64_t), int(z'3f9ef0c2755af5f0',c_int64_t), int(z'3fb132972c010fca',c_int64_t), int(z'3faf9013deda158b',c_int64_t), &
    int(z'3facf6ad70e6f2e9',c_int64_t), int(z'3faa94141e9af5ba',c_int64_t), int(z'3fa863c24737ccf6',c_int64_t), int(z'3fa6619398ce987f',c_int64_t), &
    int(z'3fa489be5a434275',c_int64_t), int(z'3fa2d8c2a454de7f',c_int64_t), int(z'3fa14b71179a5079',c_int64_t), int(z'3f9fbdad7518b0d1',c_int64_t), &
    int(z'3fb14d976287b495',c_int64_t), int(z'3fafca1a6ae55128',c_int64_t), int(z'3fad33b46272bbdf',c_int64_t), int(z'3faad33aa5177c1e',c_int64_t), &
    int(z'3fa8a44920048246',c_int64_t), int(z'3fa6a2d2fe3f35a0',c_int64_t), int(z'3fa4cb295e9e1b09',c_int64_t), int(z'3fa319e3d6d48d8b',c_int64_t), &
    int(z'3fa18be07372be63',c_int64_t), int(z'3fa01e43b7e5b4fb',c_int64_t), int(z'3fb221f7a18cad22',c_int64_t), int(z'3fb0ad23ba196be2',c_int64_t), &
    int(z'3faeac82aa69cb76',c_int64_t), int(z'3fac35d17324baca',c_int64_t), int(z'3fa9f1c90597ef75',c_int64_t), int(z'3fa7dc5931ca7d67',c_int64_t), &
    int(z'3fa5f1bef49cf56f',c_int64_t), int(z'3fa42e8b2dc60be8',c_int64_t), int(z'3fa28f9533d94b60',c_int64_t), int(z'3fa111f41e4a6de2',c_int64_t), &
    int(z'3fb1e154434e336a',c_int64_t), int(z'3fb08d73f1696448',c_int64_t), int(z'3faea59db3da8d80',c_int64_t), int(z'3fac5f11078f407a',c_int64_t), &
    int(z'3faa43c1f6aff526',c_int64_t), int(z'3fa8508121d38f5f',c_int64_t), int(z'3fa682517e77d524',c_int64_t), int(z'3fa4d67267fc689c',c_int64_t), &
    int(z'3fa34a58e9a62167',c_int64_t), int(z'3fa1dbac63a0b949',c_int64_t), int(z'3fb30b5c5494accb',c_int64_t), int(z'3fb175edc2e699fd',c_int64_t), &
    int(z'3fb002356465db26',c_int64_t), int(z'3fad5acdabefdd73',c_int64_t), int(z'3faae9dd7ecbb7fa',c_int64_t), int(z'3fa8ace901b6b965',c_int64_t), &
    int(z'3fa69f9632dccc1e',c_int64_t), int(z'3fa4bdf670344582',c_int64_t), int(z'3fa304618e90511b',c_int64_t), int(z'3fa16f86a098915c',c_int64_t), &
    int(z'3fb3dc01f3f60682',c_int64_t), int(z'3fb22bdcfd9c7871',c_int64_t), int(z'3fb0a07555ed725f',c_int64_t), int(z'3fae6d4eb7f3f7b4',c_int64_t), &
    int(z'3fabd739375932a1',c_int64_t), int(z'3fa97968a1aa0953',c_int64_t), int(z'3fa74f179547fb41',c_int64_t), int(z'3fa553e1ff63f8ce',c_int64_t)]
  integer(c_int64_t), parameter :: b20_selfref_bits_2(32) = [ &
    int(z'3fa383cbd1fb09f7',c_int64_t), int(z'3fa1db262be3b399',c_int64_t), int(z'3fb3e12a51e321a3',c_int64_t), int(z'3fb24c41f7f21485',c_int64_t), &
    int(z'3fb0d792f96c6808',c_int64_t), int(z'3faf0110a137f38c',c_int64_t), int(z'3fac899616575a5a',c_int64_t), int(z'3faa44559a664833',c_int64_t), &
    int(z'3fa82d567a60186f',c_int64_t), int(z'3fa640e67a1cfc90',c_int64_t), int(z'3fa47ba3e54cf653',c_int64_t), int(z'3fa2da737e7cdda1',c_int64_t), &
    int(z'3fb5e7c06e19b90f',c_int64_t), int(z'3fb427e44a97d3c7',c_int64_t), int(z'3fb28bcb7abd3580',c_int64_t), int(z'3fb1109ddcf538fd',c_int64_t), &
    int(z'3faf676ea4228998',c_int64_t), int(z'3face55ce68ae3f4',c_int64_t), int(z'3faa9695025b2413',c_int64_t), int(z'3fa876f95ba11086',c_int64_t), &
    int(z'3fa682ca4a3b8d75',c_int64_t), int(z'3fa4b68b41e801dc',c_int64_t), int(z'3fb7ee2e4664685f',c_int64_t), int(z'3fb5e492bc2fc697',c_int64_t), &
    int(z'3fb407611d51499f',c_int64_t), int(z'3fb252cfb0acdb96',c_int64_t), int(z'3fb0c36bfafadd81',c_int64_t), int(z'3faeac1094a2b9d4',c_int64_t), &
    int(z'3fac0f817d4321be',c_int64_t), int(z'3fa9abdf167b6c88',c_int64_t), int(z'3fa77c5337b578f3',c_int64_t), int(z'3fa57c69072a96ac',c_int64_t)]
  integer(c_int64_t), parameter :: b20_forref_bits_1(64) = [ &
    int(z'3e8cca4d233c17f3',c_int64_t), int(z'3e9ee5ebc74f04d1',c_int64_t), int(z'3ecdff92c55b93a0',c_int64_t), int(z'3ec01bf692834ece',c_int64_t), &
    int(z'3eb7eb97b2cb8421',c_int64_t), int(z'3ece92c8882f3a06',c_int64_t), int(z'3ee88b294dde02a0',c_int64_t), int(z'3ee78184828ec3b0',c_int64_t), &
    int(z'3ee54b2c2870f02a',c_int64_t), int(z'3eea065a6fdfa242',c_int64_t), int(z'3f0ab23b84990a05',c_int64_t), int(z'3f0da3162993f662',c_int64_t), &
    int(z'3f22cb8114b4e547',c_int64_t), int(z'3f2446dee1a246e7',c_int64_t), int(z'3f3e9289a755914e',c_int64_t), int(z'3f4e1bb240b809a5',c_int64_t), &
    int(z'3f649d15a502d94e',c_int64_t), int(z'3f63cd6cafd69cda',c_int64_t), int(z'3f63aa5c34894995',c_int64_t), int(z'3f6cb496a01508d1',c_int64_t), &
    int(z'3f70ce66d5ccfb9c',c_int64_t), int(z'3f7112ffe1f80230',c_int64_t), int(z'3f7003254e6e221d',c_int64_t), int(z'3f6f6ea57a2285e7',c_int64_t), &
    int(z'3f723e389fd9a4a2',c_int64_t), int(z'3f72608276bd4ba5',c_int64_t), int(z'3f71b51951e09d64',c_int64_t), int(z'3f6e5ef5d9b66a35',c_int64_t), &
    int(z'3f72c40d0aaa7ded',c_int64_t), int(z'3f72d798adb65c1d',c_int64_t), int(z'3f7271293807ae4a',c_int64_t), int(z'3f6b957cff5a12c6',c_int64_t), &
    int(z'3f7310505a358095',c_int64_t), int(z'3f73121e0fb57fa9',c_int64_t), int(z'3f7320e9af8695dc',c_int64_t), int(z'3f6e26cc7289e03e',c_int64_t), &
    int(z'3f743b7e5b4fb1ef',c_int64_t), int(z'3f7413eb9a4260f9',c_int64_t), int(z'3f73bd84856051a4',c_int64_t), int(z'3f6e1ca5fe00f74c',c_int64_t), &
    int(z'3f74f768acbcb700',c_int64_t), int(z'3f741c4f1612bbef',c_int64_t), int(z'3f7434a82852af7a',c_int64_t), int(z'3f6d47b41eab10e5',c_int64_t), &
    int(z'3f74e21cc02a271b',c_int64_t), int(z'3f74f40dae695f6a',c_int64_t), int(z'3f74a525e9c987c9',c_int64_t), int(z'3f6d28141b3ff767',c_int64_t), &
    int(z'3f7574abf96d94ae',c_int64_t), int(z'3f75ba699dd36517',c_int64_t), int(z'3f75748e72491dab',c_int64_t), int(z'3f70f7d20921bcbe',c_int64_t), &
    int(z'3f76930c61b82bd6',c_int64_t), int(z'3f75f2986363a79a',c_int64_t), int(z'3f76649601b48b0d',c_int64_t), int(z'3f7368f08461f9f0',c_int64_t), &
    int(z'3f78fa04686f8016',c_int64_t), int(z'3f78291eb247bb56',c_int64_t), int(z'3f76fc78e1e913aa',c_int64_t), int(z'3f75aac48f3b9cb9',c_int64_t), &
    int(z'3f7a6adff2c45834',c_int64_t), int(z'3f79e00b180c105a',c_int64_t), int(z'3f799bb527bf8c9d',c_int64_t), int(z'3f78982753abf999',c_int64_t)]
  integer(c_int64_t), parameter :: b20_sfluxref_bits_1(16) = [ &
    int(z'4022ae7ea5f84cad',c_int64_t), int(z'4021dfd8adab9f56',c_int64_t), int(z'4020630d306a2b17',c_int64_t), int(z'401d915df6555c53',c_int64_t), &
    int(z'40187c2e33eff195',c_int64_t), int(z'4014f54f3775b813',c_int64_t), int(z'4010ff6555c52e73',c_int64_t), int(z'400999ddc1e7967d',c_int64_t), &
    int(z'400148a47ecfe9b8',c_int64_t), int(z'3fce046412cf0f9d',c_int64_t), int(z'3fc8e86c6583e857',c_int64_t), int(z'3fc364bec679cc75',c_int64_t), &
    int(z'3fbc3d9a95421c04',c_int64_t), int(z'3fb22cc98ca66c10',c_int64_t), int(z'3f9bb4e8aa78e4ee',c_int64_t), int(z'3f6b874fc006c0b9',c_int64_t)]
  integer(c_int64_t), parameter :: b20_absch4_bits_1(16) = [ &
    int(z'3f509c3a32d6c1ee',c_int64_t), int(z'3f79f4be028494a5',c_int64_t), int(z'3f93e27179bfdf7f',c_int64_t), int(z'3fa8bd87b56b8738',c_int64_t), &
    int(z'3f636150fdc96ef4',c_int64_t), int(z'3f45b10831630aa3',c_int64_t), int(z'3f427fce303dfa25',c_int64_t), int(z'3f328f05b949da8c',c_int64_t), &
    int(z'3f137e5e96129a6f',c_int64_t), int(z'3eadde6857966a71',c_int64_t), int(z'3ea772071f0ddddb',c_int64_t), int(z'3e717f5afb3b16cb',c_int64_t), &
    int(z'3e5fd966a725fdc8',c_int64_t), int(z'0000000000000000',c_int64_t), int(z'0000000000000000',c_int64_t), int(z'0000000000000000',c_int64_t)]
  integer(c_int64_t), parameter :: b20_rayl_bits_1(1) = [ &
                                   int(z'3e31b1fce76faef0', c_int64_t)]
  integer(c_int), parameter :: b20_layreffr_bits_1(1) = [ &
                               int(z'00000003', c_int)]
  integer(c_int64_t), parameter :: b21_selfref_bits_1(128) = [ &
    int(z'3f1e610b8008456b',c_int64_t), int(z'3f1849e272069fdb',c_int64_t), int(z'3f136b4f80dd0f59',c_int64_t), int(z'3f0f0d50396d22dd',c_int64_t), &
    int(z'3f08d39cb0e17003',c_int64_t), int(z'3f03d96df36232b1',c_int64_t), int(z'3effbd615440ba7e',c_int64_t), int(z'3ef960680e75fe4e',c_int64_t), &
    int(z'3ef449fc06fdf458',c_int64_t), int(z'3ef038b24e1b6bec',c_int64_t), int(z'3f3e1e164920380c',c_int64_t), int(z'3f3908424c5e5b08',c_int64_t), &
    int(z'3f34ce3ef8f55af2',c_int64_t), int(z'3f314aefd72cbbe5',c_int64_t), int(z'3f2cbeec533eb02e',c_int64_t), int(z'3f27e4670c177f3c',c_int64_t), &
    int(z'3f23dbaa0a55188b',c_int64_t), int(z'3f20814eec6ea013',c_int64_t), int(z'3f1b6fbf77f1f674',c_int64_t), int(z'3f16cdd3b13833de',c_int64_t), &
    int(z'3f5b54fad9249ef1',c_int64_t), int(z'3f58c1b81bbac690',c_int64_t), int(z'3f566c937c1e339d',c_int64_t), int(z'3f544fadbd3d0cd1',c_int64_t), &
    int(z'3f5265c8b1b51952',c_int64_t), int(z'3f50aa06cf271a20',c_int64_t), int(z'3f4e3023aba328dc',c_int64_t), int(z'3f4b57fba5b973bb',c_int64_t), &
    int(z'3f48c46fe49d00b5',c_int64_t), int(z'3f466f08b2924a2b',c_int64_t), int(z'3f72d948dc11e42e',c_int64_t), int(z'3f714267d983139b',c_int64_t), &
    int(z'3f6f9bb176dafdbd',c_int64_t), int(z'3f6cf1628357e3c2',c_int64_t), int(z'3f6a809f4cb6e7de',c_int64_t), int(z'3f684484ea351286',c_int64_t), &
    int(z'3f6638abee0500c6',c_int64_t), int(z'3f645902d094d86a',c_int64_t), int(z'3f62a1c333c6d6ea',c_int64_t), int(z'3f610f921947a4af',c_int64_t), &
    int(z'3f84ce307a1b4f11',c_int64_t), int(z'3f82f04fb3c76d3c',c_int64_t), int(z'3f813d4f40dae696',c_int64_t), int(z'3f7f62aea0e7c19b',c_int64_t), &
    int(z'3f7c91c940a63863',c_int64_t), int(z'3f7a0196581b9fef',c_int64_t), int(z'3f77ac4166fd900e',c_int64_t), int(z'3f758c8432543b16',c_int64_t), &
    int(z'3f739d8e9bb9af64',c_int64_t), int(z'3f71db03f227fb1c',c_int64_t), int(z'3fa0cbb9a7561abf',c_int64_t), int(z'3f9eceae4e5c8465',c_int64_t), &
    int(z'3f9c40ffa4906da1',c_int64_t), int(z'3f99e98061ba2f3b',c_int64_t), int(z'3f97c3b4f6167232',c_int64_t), int(z'3f95cb7259b9afba',c_int64_t), &
    int(z'3f93fcff9a7f72a7',c_int64_t), int(z'3f9254e6e221c8a8',c_int64_t), int(z'3f90cfeec03c9b92',c_int64_t), int(z'3f8ed66a04809841',c_int64_t), &
    int(z'3fa4c8af30da935f',c_int64_t), int(z'3fa340ba04732c48',c_int64_t), int(z'3fa1d5a4e2a2f7e7',c_int64_t), int(z'3fa08550367938d1',c_int64_t), &
    int(z'3f9e9b82a7e58cb7',c_int64_t), int(z'3f9c5a525bed66a0',c_int64_t), int(z'3f9a43a068c0b3ba',c_int64_t), int(z'3f98544e35edf896',c_int64_t), &
    int(z'3f96898046e23ca1',c_int64_t), int(z'3f94e07cacf9c8ae',c_int64_t), int(z'3fa6f4c5395a94a1',c_int64_t), int(z'3fa52fe74e5852a7',c_int64_t), &
    int(z'3fa38df0eeeb04c6',c_int64_t), int(z'3fa20c2ee26b9a83',c_int64_t), int(z'3fa0a826fb168c33',c_int64_t), int(z'3f9ebf1c0a21c1f2',c_int64_t), &
    int(z'3f9c608f8cd05d7b',c_int64_t), int(z'3f9a30c0922be70f',c_int64_t), int(z'3f982c110002843f',c_int64_t), int(z'3f964f39f9f6d183',c_int64_t), &
    int(z'3fa8900fad1c2d5d',c_int64_t), int(z'3fa6cdcd7dccb479',c_int64_t), int(z'3fa52bc9b266193a',c_int64_t), int(z'3fa3a7b5bc0f0f67',c_int64_t), &
    int(z'3fa23f67f4dbdf8f',c_int64_t), int(z'3fa0f0e90bc7b45f',c_int64_t), int(z'3f9f74bfc57d4d33',c_int64_t), int(z'3f9d341c673ed37a',c_int64_t), &
    int(z'3f9b1cc964628028',c_int64_t), int(z'3f992bd06862bfe9',c_int64_t), int(z'3faa96ac7f4f6b78',c_int64_t), int(z'3fa8c996b76709fa',c_int64_t), &
    int(z'3fa71bbcf4e874c9',c_int64_t), int(z'3fa58affa2e2ee77',c_int64_t), int(z'3fa4156acb4ff50b',c_int64_t), int(z'3fa2b921f51d4def',c_int64_t), &
    int(z'3fa174744622fa00',c_int64_t), int(z'3fa045c1ab309ad2',c_int64_t), int(z'3f9e5724aa037429',c_int64_t), int(z'3f9c48fe76930454',c_int64_t), &
    int(z'3fad49d45f684564',c_int64_t), int(z'3fab05b7cfe58601',c_int64_t), int(z'3fa8ee7c49fd7a14',c_int64_t), int(z'3fa700abf76a2f49',c_int64_t), &
    int(z'3fa53910c2c5e2ce',c_int64_t), int(z'3fa394b4578b0150',c_int64_t), int(z'3fa210dcc715d3a7',c_int64_t), int(z'3fa0ab092da62b78',c_int64_t), &
    int(z'3f9ec1c88ccc2bbd',c_int64_t), int(z'3f9c609642cd042a',c_int64_t), int(z'3faec607b6ada697',c_int64_t), int(z'3fac62c69eb5624d',c_int64_t), &
    int(z'3faa2ef4e0114d2f',c_int64_t), int(z'3fa826e03e9998c3',c_int64_t), int(z'3fa6472705fe46c2',c_int64_t), int(z'3fa48ca742cf8869',c_int64_t), &
    int(z'3fa2f47b677f6b1a',c_int64_t), int(z'3fa17bfa4c61d862',c_int64_t), int(z'3fa020b079afef46',c_int64_t), int(z'3f9dc0b2e316bb2d',c_int64_t), &
    int(z'3faf91d57ff9b563',c_int64_t), int(z'3fad09aed56b0100',c_int64_t), int(z'3faab58735e9c6d9',c_int64_t), int(z'3fa8912ce38dd972',c_int64_t), &
    int(z'3fa698cf6f3e7c3d',c_int64_t), int(z'3fa4c8e185c17581',c_int64_t), int(z'3fa31e29b6b2af14',c_int64_t), int(z'3fa195aaf78feef6',c_int64_t)]
  integer(c_int64_t), parameter :: b21_selfref_bits_2(32) = [ &
    int(z'3fa02ca4a3b8d74d',c_int64_t), int(z'3f9dc124f8ddcccf',c_int64_t), int(z'3fb0962eab0e3624',c_int64_t), int(z'3fae55ec9b9f2d57',c_int64_t), &
    int(z'3fabbda0091f6373',c_int64_t), int(z'3fa95e28aa433509',c_int64_t), int(z'3fa732a6457986d5',c_int64_t), int(z'3fa536a75bf9fbda',c_int64_t), &
    int(z'3fa3661f18c9fb61',c_int64_t), int(z'3fa1bd512ec6bce8',c_int64_t), int(z'3fa038d88ea1eed3',c_int64_t), int(z'3f9dab3aabcd78c4',c_int64_t), &
    int(z'3fb1c5b65816418b',c_int64_t), int(z'3fb0534018f4c38c',c_int64_t), int(z'3fadfde5738cbf97',c_int64_t), int(z'3fab8cb585886a9d',c_int64_t), &
    int(z'3fa94e6e221c8a7a',c_int64_t), int(z'3fa73eeaf75a3f11',c_int64_t), int(z'3fa55a5b9628cbd1',c_int64_t), int(z'3fa39d4017474462',c_int64_t), &
    int(z'3fa20462654fe5f1',c_int64_t), int(z'3fa08cd2e1b9c3dc',c_int64_t), int(z'3fb3804beaba1d9e',c_int64_t), int(z'3fb1f76a2f48c2e7',c_int64_t), &
    int(z'3fb08d73f1696448',c_int64_t), int(z'3fae7ff583a53b8e',c_int64_t), int(z'3fac197e56473472',c_int64_t), int(z'3fa9e36163c82675',c_int64_t), &
    int(z'3fa7d9d4f30bfbb7',c_int64_t), int(z'3fa5f95266d5212f',c_int64_t), int(z'3fa43ea04ebf80b4',c_int64_t), int(z'3fa2a6c4fb47339b',c_int64_t)]
  integer(c_int64_t), parameter :: b21_forref_bits_1(64) = [ &
    int(z'3e7d87b133ceca3f',c_int64_t), int(z'3ea52b7e2903507b',c_int64_t), int(z'3ece76c7b756196f',c_int64_t), int(z'3ed9dfd3d1551d15',c_int64_t), &
    int(z'3ed205f71aeb1c25',c_int64_t), int(z'3ee08cd87c969c14',c_int64_t), int(z'3ef6cc37601a7039',c_int64_t), int(z'3f10c2e4cf499525',c_int64_t), &
    int(z'3f06dfb0f9336773',c_int64_t), int(z'3f0b972aec773df8',c_int64_t), int(z'3f1e7f832925fa4c',c_int64_t), int(z'3f2af353fdb6ad2e',c_int64_t), &
    int(z'3f2c433dd3866093',c_int64_t), int(z'3f2ebd40a3f045df',c_int64_t), int(z'3f3261f5710e68ac',c_int64_t), int(z'3f4b7b41d0ebfc79',c_int64_t), &
    int(z'3f4157f296712c4e',c_int64_t), int(z'3f44580ced8a6dbe',c_int64_t), int(z'3f4ea80df2ff32f3',c_int64_t), int(z'3f5c0ed459332216',c_int64_t), &
    int(z'3f61638fc75dcd10',c_int64_t), int(z'3f61e79e8a443c1a',c_int64_t), int(z'3f6234701f21d944',c_int64_t), int(z'3f605af6c69b5a64',c_int64_t), &
    int(z'3f67d93a995901fa',c_int64_t), int(z'3f67088534b2ba27',c_int64_t), int(z'3f654302df02846a',c_int64_t), int(z'3f61375a8a3a2b1f',c_int64_t), &
    int(z'3f69e838e3f735d7',c_int64_t), int(z'3f6973bf147d6586',c_int64_t), int(z'3f66e58f9158019f',c_int64_t), int(z'3f610bab84d38ede',c_int64_t), &
    int(z'3f6d14be28194eb1',c_int64_t), int(z'3f6b9b2beaea6f1f',c_int64_t), int(z'3f687d04379d253f',c_int64_t), int(z'3f5d8f87f2d31bc6',c_int64_t), &
    int(z'3f704a7da7a09866',c_int64_t), int(z'3f6e19200c8fdb55',c_int64_t), int(z'3f6af340a9e94803',c_int64_t), int(z'3f5d21c41ffffaa2',c_int64_t), &
    int(z'3f70bee75bef3f13',c_int64_t), int(z'3f7055a31faa3f59',c_int64_t), int(z'3f6ce538a969c642',c_int64_t), int(z'3f5f88c6e37ebff9',c_int64_t), &
    int(z'3f71c60b3c9f17b3',c_int64_t), int(z'3f713b03613376a5',c_int64_t), int(z'3f6f72d7380ab362',c_int64_t), int(z'3f6217443f4a17d1',c_int64_t), &
    int(z'3f71dff446e44006',c_int64_t), int(z'3f71c465cb0b00ba',c_int64_t), int(z'3f7170555297d26f',c_int64_t), int(z'3f6371718756cbea',c_int64_t), &
    int(z'3f720b3d4ae429e1',c_int64_t), int(z'3f72644b840cea74',c_int64_t), int(z'3f728250d2ab5e12',c_int64_t), int(z'3f660ce210abc9c8',c_int64_t), &
    int(z'3f74202d9cf13cef',c_int64_t), int(z'3f73bb9ea71f941a',c_int64_t), int(z'3f737d1d371d788c',c_int64_t), int(z'3f6db5a842ffaef7',c_int64_t), &
    int(z'3f77013b9455b7ed',c_int64_t), int(z'3f757c563ccd90c2',c_int64_t), int(z'3f74fdab3c036667',c_int64_t), int(z'3f7439e3a6830c0f',c_int64_t)]
  integer(c_int64_t), parameter :: b21_sfluxref_bits_1(128) = [ &
    int(z'40302a0f9096bb99',c_int64_t), int(z'402f294467381d7e',c_int64_t), int(z'402d7367a0f9096c',c_int64_t), int(z'402b1bb2fec56d5d',c_int64_t), &
    int(z'4027e75f6fd21ff3',c_int64_t), int(z'4024e36113404ea5',c_int64_t), int(z'4020c1f75104d552',c_int64_t), int(z'40190e2c12ad81ae',c_int64_t), &
    int(z'4011232ca57a786c',c_int64_t), int(z'3fddc64ba94bbe44',c_int64_t), int(z'3fd8a5657fb69985',c_int64_t), int(z'3fd378705425f202',c_int64_t), &
    int(z'3fcc7a311e85fd05',c_int64_t), int(z'3fc2573215fcc187',c_int64_t), int(z'3fac926ba7eec6f3',c_int64_t), int(z'3f8012e7e42a617d',c_int64_t), &
    int(z'402f4a4a8c154c98',c_int64_t), int(z'402ea24dd2f1a9fc',c_int64_t), int(z'402d65bc01a36e2f',c_int64_t), int(z'402b7851eb851eb8',c_int64_t), &
    int(z'4028741205bc01a3',c_int64_t), int(z'4025086d71f36263',c_int64_t), int(z'4020f16872b020c5',c_int64_t), int(z'40198e0f3cb3e575',c_int64_t), &
    int(z'401157689ca18bd6',c_int64_t), int(z'3fde1e7967caea74',c_int64_t), int(z'3fd8ec5b078d92fb',c_int64_t), int(z'3fd39d0e991ff716',c_int64_t), &
    int(z'3fcc9cdc443914f5',c_int64_t), int(z'3fc256c508b32ce9',c_int64_t), int(z'3fac9429ee101373',c_int64_t), int(z'3f8012e7e42a617d',c_int64_t), &
    int(z'402f37e90ff97247',c_int64_t), int(z'402ea89a02752546',c_int64_t), int(z'402d604ea4a8c155',c_int64_t), int(z'402b56ae7d566cf4',c_int64_t), &
    int(z'402877e90ff97247',c_int64_t), int(z'40250a4a8c154c98',c_int64_t), int(z'4020fd249e44fa05',c_int64_t), int(z'4019af7e3d1cc101',c_int64_t), &
    int(z'40116f41f212d773',c_int64_t), int(z'3fde4b599aa60914',c_int64_t), int(z'3fd90bdcad14a0a1',c_int64_t), int(z'3fd3c460ed80a17b',c_int64_t), &
    int(z'3fccc1db0142f61f',c_int64_t), int(z'3fc288c60cbf2b24',c_int64_t), int(z'3fac941fdd15196d',c_int64_t), int(z'3f8013097219a2e9',c_int64_t), &
    int(z'402f283e425aee63',c_int64_t), int(z'402eaf34d6a161e5',c_int64_t), int(z'402d60f9096bb98c',c_int64_t), int(z'402b353f7ced9168',c_int64_t), &
    int(z'4028836e2eb1c433',c_int64_t), int(z'4024fced916872b0',c_int64_t), int(z'402112070b8cfbfc',c_int64_t), int(z'4019c6eeb702602d',c_int64_t), &
    int(z'40117d028a1dfb94',c_int64_t), int(z'3fde7204295a6c5d',c_int64_t), int(z'3fd92630ec311623',c_int64_t), int(z'3fd3d2bb23571d1d',c_int64_t), &
    int(z'3fccf68be2f7b17d',c_int64_t), int(z'3fc2bff47735c183',c_int64_t), int(z'3faca32f44912989',c_int64_t), int(z'3f8013097219a2e9',c_int64_t), &
    int(z'402f1374bc6a7efa',c_int64_t), int(z'402ec3e425aee632',c_int64_t), int(z'402d50a3d70a3d71',c_int64_t), int(z'402b24f765fd8adb',c_int64_t), &
    int(z'40288779a6b50b0f',c_int64_t), int(z'4024f414a4d2b2c0',c_int64_t), int(z'402124a6223e186a',c_int64_t), int(z'4019da8d64d7f0ed',c_int64_t), &
    int(z'401187c5ac471b48',c_int64_t), int(z'3fde91c4b90214ad',c_int64_t), int(z'3fd93700474d9c6b',c_int64_t), int(z'3fd3e2478854cdb8',c_int64_t), &
    int(z'3fcd22a6f3f52fc2',c_int64_t), int(z'3fc2fdfc19c17226',c_int64_t), int(z'3facb13fa88c7ba4',c_int64_t), int(z'3f800e0653005815',c_int64_t), &
    int(z'402f06594af4f0d8',c_int64_t), int(z'402ecc154c985f07',c_int64_t), int(z'402d3f7ced916873',c_int64_t), int(z'402b1b645a1cac08',c_int64_t), &
    int(z'40287e5c91d14e3c',c_int64_t), int(z'4024fa5269595fee',c_int64_t), int(z'4021356c0d6f544c',c_int64_t), int(z'4019eb5dcc63f141',c_int64_t), &
    int(z'401193f290abb44e',c_int64_t), int(z'3fde9bed30f062d4',c_int64_t), int(z'3fd951ce28ed5f14',c_int64_t), int(z'3fd3e820e6299525',c_int64_t), &
    int(z'3fcd8f041461b6d4',c_int64_t), int(z'3fc30b06c43f5f91',c_int64_t), int(z'3facbb9dd05fff44',c_int64_t), int(z'3f800e0653005815',c_int64_t), &
    int(z'402efb645a1cac08',c_int64_t), int(z'402ece3bcd35a858',c_int64_t), int(z'402d2786c226809d',c_int64_t), int(z'402b19f559b3d07d',c_int64_t), &
    int(z'40286ca57a786c22',c_int64_t), int(z'40250e00d1b71759',c_int64_t), int(z'402140c49ba5e354',c_int64_t), int(z'4019fc5ac471b478',c_int64_t), &
    int(z'4011a59c8c9320da',c_int64_t), int(z'3fdea1d323fee2ca',c_int64_t), int(z'3fd95f28848387df',c_int64_t), int(z'3fd41bd61f5be5da',c_int64_t), &
    int(z'3fcdd70a3d70a3d7',c_int64_t), int(z'3fc31422ccb3a259',c_int64_t), int(z'3facca4be90c9e74',c_int64_t), int(z'3f800e0653005815',c_int64_t), &
    int(z'402ee9930be0ded3',c_int64_t), int(z'402ec91d14e3bcd3',c_int64_t), int(z'402d1a1cac083127',c_int64_t), int(z'402b063f141205bc',c_int64_t), &
    int(z'402860c49ba5e354',c_int64_t), int(z'40252a4a8c154c98',c_int64_t), int(z'4021511c6d1e108c',c_int64_t), int(z'401a0ff43419e300',c_int64_t), &
    int(z'4011b5bab21815a0',c_int64_t), int(z'3fdec347e8ccdd94',c_int64_t), int(z'3fd99bf162ae4b02',c_int64_t), int(z'3fd45c78a6dacabc',c_int64_t), &
    int(z'3fcdf1a5ca29845e',c_int64_t), int(z'3fc31654d61b2a28',c_int64_t), int(z'3facca4be90c9e74',c_int64_t), int(z'3f800e0653005815',c_int64_t)]
  integer(c_int64_t), parameter :: b21_sfluxref_bits_2(16) = [ &
    int(z'402e03886594af4f',c_int64_t), int(z'402e4bb98c7e2824',c_int64_t), int(z'402d8f765fd8adac',c_int64_t), int(z'402b378d4fdf3b64',c_int64_t), &
    int(z'40288f0068db8bac',c_int64_t), int(z'402562c3c9eecbfb',c_int64_t), int(z'402174577d955715',c_int64_t), int(z'401a48d8ec95bff0',c_int64_t), &
    int(z'4011da6b50b0f27c',c_int64_t), int(z'3fdf267c6b8b6955',c_int64_t), int(z'3fd9b14a90470a81',c_int64_t), int(z'3fd4688377186552',c_int64_t), &
    int(z'3fcdf25e56cd6c2f',c_int64_t), int(z'3fc31654d61b2a28',c_int64_t), int(z'3facca4be90c9e74',c_int64_t), int(z'3f800e0653005815',c_int64_t)]
  integer(c_int64_t), parameter :: b21_rayl_bits_1(1) = [ &
                                   int(z'3e443533c3f2cdae', c_int64_t)]
  integer(c_int64_t), parameter :: b21_strrat_bits_1(1) = [ &
                                   int(z'3f7290405483e5d3', c_int64_t)]
  integer(c_int), parameter :: b21_layreffr_bits_1(1) = [ &
                               int(z'00000008', c_int)]
  integer(c_int64_t), parameter :: b22_selfref_bits_1(128) = [ &
    int(z'3f0c3bf93f167758',c_int64_t), int(z'3f085bcbc0a3c2bf',c_int64_t), int(z'3f0503d28563fbaa',c_int64_t), int(z'3f022157cdf91aff',c_int64_t), &
    int(z'3eff4879ff3b0236',c_int64_t), int(z'3efafd271fb909cb',c_int64_t), int(z'3ef748be57359357',c_int64_t), int(z'3ef4168680ed6336',c_int64_t), &
    int(z'3ef1549ee5494a96',c_int64_t), int(z'3eede73e099d5a10',c_int64_t), int(z'3f25498aafe933ad',c_int64_t), int(z'3f20d29c55c7c3e0',c_int64_t), &
    int(z'3f1a96da219f0c1f',c_int64_t), int(z'3f1503407dfec660',c_int64_t), int(z'3f109b13fe4ada55',c_int64_t), int(z'3f0a3f088df4f3fe',c_int64_t), &
    int(z'3f04bdde39b5171e',c_int64_t), int(z'3f0064400a4af662',c_int64_t), int(z'3ef9e85e78b141ac',c_int64_t), int(z'3ef47963e30c25e9',c_int64_t), &
    int(z'3f313a6d97bba692',c_int64_t), int(z'3f2be425f39e6199',c_int64_t), int(z'3f2693a676b2f5f2',c_int64_t), int(z'3f224664cf73ac5b',c_int64_t), &
    int(z'3f1d95e8093e4230',c_int64_t), int(z'3f17f2c6f9a78aef',c_int64_t), int(z'3f13629cfe092216',c_int64_t), int(z'3f0f620ef68f7f3f',c_int64_t), &
    int(z'3f09673cf798828c',c_int64_t), int(z'3f0490198dfc9fa7',c_int64_t), int(z'3f2fd5772f254b58',c_int64_t), int(z'3f2ac4a7645d77aa',c_int64_t), &
    int(z'3f26822b1b953a6d',c_int64_t), int(z'3f22ed39f7141583',c_int64_t), int(z'3f1fd46ce56cbcfe',c_int64_t), int(z'3f1ac3bf76bcb99e',c_int64_t), &
    int(z'3f16816741da4a4c',c_int64_t), int(z'3f12ec9509d4fa75',c_int64_t), int(z'3f0fd34fb5da48e0',c_int64_t), int(z'3f0ac2d261b202b9',c_int64_t), &
    int(z'3f2ee1e4d95568b5',c_int64_t), int(z'3f2b3d14aad44bea',c_int64_t), int(z'3f28064ae19473da',c_int64_t), int(z'3f25309c5da1cf51',c_int64_t), &
    int(z'3f22b08f5d084c5d',c_int64_t), int(z'3f207c01b6c1fc17',c_int64_t), int(z'3f1d142f595654ee',c_int64_t), int(z'3f19a5cdc25ba8ca',c_int64_t), &
    int(z'3f169f15e9d31633',c_int64_t), int(z'3f13f3c87c3f9d78',c_int64_t), int(z'3f2aefb44733b4fd',c_int64_t), int(z'3f28ed2e3899f1d1',c_int64_t), &
    int(z'3f271113a3a0d97f',c_int64_t), int(z'3f2558793542796f',c_int64_t), int(z'3f23c0b852a87fa2',c_int64_t), int(z'3f22476f192c3ab5',c_int64_t), &
    int(z'3f20ea443d2ced5a',c_int64_t), int(z'3f1f4e57847edddf',c_int64_t), int(z'3f1cf866e214e61f',c_int64_t), int(z'3f1acf05ae8d131b',c_int64_t), &
    int(z'3f284079d3e7af62',c_int64_t), int(z'3f26f4fddd29d601',c_int64_t), int(z'3f25bb30cbad709a',c_int64_t), int(z'3f24922ab1d1c120',c_int64_t), &
    int(z'3f237903a1f60987',c_int64_t), int(z'3f226edc457f7fd7',c_int64_t), int(z'3f2172e673df423d',c_int64_t), int(z'3f2084653292570e',c_int64_t), &
    int(z'3f1f45483c377164',c_int64_t), int(z'3f1d99dda5fcc323',c_int64_t), int(z'3f293fb975cf5c6c',c_int64_t), int(z'3f279e3d7e76e49f',c_int64_t), &
    int(z'3f2617bbd5d0f9d0',c_int64_t), int(z'3f24aa75cea8080b',c_int64_t), int(z'3f2354bde9d26387',c_int64_t), int(z'3f221522c9500d00',c_int64_t), &
    int(z'3f20ea21e1151d0c',c_int64_t), int(z'3f1fa4e98c7eb194',c_int64_t), int(z'3f1d99bb49e4f2d6',c_int64_t), int(z'3f1bb04e80b05867',c_int64_t), &
    int(z'3f252f784ed764bc',c_int64_t), int(z'3f246fc602fb7f5f',c_int64_t), int(z'3f23b6dae1d23154',c_int64_t), int(z'3f23047aca31ce15',c_int64_t), &
    int(z'3f22586103eab504',c_int64_t), int(z'3f21b2629bdf21c2',c_int64_t), int(z'3f21124370e567c6',c_int64_t), int(z'3f2077c761d3da88',c_int64_t), &
    int(z'3f1fc586f7196b50',c_int64_t), int(z'3f1ea60867d88161',c_int64_t), int(z'3f1fb01e964322ea',c_int64_t), int(z'3f206b32281b5216',c_int64_t), &
    int(z'3f2103b368cd9eda',c_int64_t), int(z'3f21a1be00563c22',c_int64_t), int(z'3f22457ce1d2ee4f',c_int64_t), int(z'3f22ef34c57355fd',c_int64_t), &
    int(z'3f239f109e55378c',c_int64_t), int(z'3f24554c8da23f85',c_int64_t), int(z'3f251224b4841a70',c_int64_t), int(z'3f25d5ddcb2a68e8',c_int64_t), &
    int(z'3f1b72a233f1f4fa',c_int64_t), int(z'3f1d4c275c20a375',c_int64_t), int(z'3f1f457bc65b29d8',c_int64_t), int(z'3f20b07c5f2122ba',c_int64_t), &
    int(z'3f21d06202a97d92',c_int64_t), int(z'3f2303aca1a2ec42',c_int64_t), int(z'3f244bab3df59dc0',c_int64_t), int(z'3f25a9c69e9b9d3b',c_int64_t), &
    int(z'3f271f78b89ade0a',c_int64_t), int(z'3f28ae5ddd1123d0',c_int64_t), int(z'3f162fa87565c3e5',c_int64_t), int(z'3f18efa3011a88f8',c_int64_t), &
    int(z'3f1c06e088b02c1c',c_int64_t), int(z'3f1f8034290da698',c_int64_t), int(z'3f21b3dc90e51518',c_int64_t), int(z'3f23e59012315aec',c_int64_t), &
    int(z'3f265cec47c4ee3a',c_int64_t), int(z'3f29227fa08dee59',c_int64_t), int(z'3f2c400dc850cd5e',c_int64_t), int(z'3f2fc06d4b907fc8',c_int64_t), &
    int(z'3f118ea49c4cbf5b',c_int64_t), int(z'3f147f4168500192',c_int64_t), int(z'3f17ede447de5317',c_int64_t), int(z'3f1befa84c98679e',c_int64_t), &
    int(z'3f204e9b884b0175',c_int64_t), int(z'3f23099d0cc0adb0',c_int64_t), int(z'3f2639b0d959d694',c_int64_t), int(z'3f29f266dca5545a',c_int64_t)]
  integer(c_int64_t), parameter :: b22_selfref_bits_2(32) = [ &
    int(z'3f2e4aaa038556d3',c_int64_t), int(z'3f31ae93a6bb6b26',c_int64_t), int(z'3f0f4e050ddf5058',c_int64_t), int(z'3f12ef09d255919c',c_int64_t), &
    int(z'3f16e72917c70923',c_int64_t), int(z'3f1bb4554b7ac181',c_int64_t), int(z'3f20c190a5f76d57',c_int64_t), int(z'3f2444d2e5371e47',c_int64_t), &
    int(z'3f288497651d215f',c_int64_t), int(z'3f2da86dae148c0f',c_int64_t), int(z'3f31f00a9d1a8b24',c_int64_t), int(z'3f35b2b7d64e3372',c_int64_t), &
    int(z'3f10c9b8009e1bc6',c_int64_t), int(z'3f143bfe064b60b6',c_int64_t), int(z'3f1863648381371f',c_int64_t), int(z'3f1d651e456dfbe5',c_int64_t), &
    int(z'3f21b6f2d708cc13',c_int64_t), int(z'3f2559ea934278b2',c_int64_t), int(z'3f29bc0293f2d564',c_int64_t), int(z'3f2f04747b496ed6',c_int64_t), &
    int(z'3f32b1480c084bff',c_int64_t), int(z'3f3687a3445fa2ca',c_int64_t), int(z'3f117844d797ce60',c_int64_t), int(z'3f14ffcbba99928f',c_int64_t), &
    int(z'3f193ddbdc1df367',c_int64_t), int(z'3f1e57506b49c76c',c_int64_t), int(z'3f223c4b3d73b186',c_int64_t), int(z'3f25eb688818819b',c_int64_t), &
    int(z'3f2a59140fcecc79',c_int64_t), int(z'3f2fabc1e53d310e',c_int64_t), int(z'3f3308e0123db404',c_int64_t), int(z'3f36e158750c1b97',c_int64_t)]
  integer(c_int64_t), parameter :: b22_forref_bits_1(48) = [ &
    int(z'3e62dd152274558e',c_int64_t), int(z'3e625089987f1cbe',c_int64_t), int(z'3e88560132d1665c',c_int64_t), int(z'3e7d6ef403f121ae',c_int64_t), &
    int(z'3e9719ff87ee771b',c_int64_t), int(z'3eb77074b33672e1',c_int64_t), int(z'3e992768fcc85024',c_int64_t), int(z'3eb15a06e7e9c95e',c_int64_t), &
    int(z'3ebfa9555bcc8e74',c_int64_t), int(z'3ea37683a5eeb520',c_int64_t), int(z'3eb39bc935c7c4c7',c_int64_t), int(z'3eb454c52d06fb72',c_int64_t), &
    int(z'3eb3655367135e23',c_int64_t), int(z'3eb8d946ac019338',c_int64_t), int(z'3eac0de5f5e8069b',c_int64_t), int(z'3ebe71a5ccbd395a',c_int64_t), &
    int(z'3eb65dbfefb3c86a',c_int64_t), int(z'3ea0c866dd5a562c',c_int64_t), int(z'3ec0b38dd5d0e062',c_int64_t), int(z'3eb357110627296c',c_int64_t), &
    int(z'3e9d0ec7c0436f2d',c_int64_t), int(z'3ebed324b6b5e28f',c_int64_t), int(z'3eb48306ea86c54c',c_int64_t), int(z'3e9d1324dad6fa10',c_int64_t), &
    int(z'3ec0a44e91a60ab7',c_int64_t), int(z'3eb0cc8cfe2e2d60',c_int64_t), int(z'3e92199debaca167',c_int64_t), int(z'3ec72f421d10f3f7',c_int64_t), &
    int(z'3ea923b5355a409a',c_int64_t), int(z'3e8fcc79900ef98c',c_int64_t), int(z'3ec903d6d5067dae',c_int64_t), int(z'3ea520fa8e451c0a',c_int64_t), &
    int(z'3e8ea75a17d91304',c_int64_t), int(z'3ece95cfb00b05fd',c_int64_t), int(z'3e9e8e9ce7fb6a73',c_int64_t), int(z'3e8baa92a7984e00',c_int64_t), &
    int(z'3ecf5164dba6a140',c_int64_t), int(z'3e9074acfc282947',c_int64_t), int(z'3e8b1c3870f782f8',c_int64_t), int(z'3ed42604fde7e11e',c_int64_t), &
    int(z'3e87d5faf4b65139',c_int64_t), int(z'3e870340847470bd',c_int64_t), int(z'3ed5e1b60a5ff7af',c_int64_t), int(z'3e8b4b53e282eb6a',c_int64_t), &
    int(z'3e89713298e1e279',c_int64_t), int(z'3ed6c3612156b491',c_int64_t), int(z'3e8d6589e2cb001b',c_int64_t), int(z'3e8d4bbc05220543',c_int64_t)]
  integer(c_int64_t), parameter :: b22_sfluxref_bits_1(128) = [ &
    int(z'400dbb352a843809',c_int64_t), int(z'400d0e219652bd3c',c_int64_t), int(z'400b9566cf41f213',c_int64_t), int(z'40096f544bb1af3a',c_int64_t), &
    int(z'4006e2bbecaab8a6',c_int64_t), int(z'4003e113404ea4a9',c_int64_t), int(z'4000329b280f12c2',c_int64_t), int(z'3ff865604189374c',c_int64_t), &
    int(z'3ff09c193b3a68b2',c_int64_t), int(z'3fbcff64cf8d716d',c_int64_t), int(z'3fb7fd7a13c254a4',c_int64_t), int(z'3fb2eae840c699ad',c_int64_t), &
    int(z'3fabe3a988242650',c_int64_t), int(z'3fa1b5d894812be5',c_int64_t), int(z'3f8aaf1b0b1e4134',c_int64_t), int(z'3f5e2dd2f7085fa0',c_int64_t), &
    int(z'400dea25d8d79d0a',c_int64_t), int(z'400cd42c3c9eecc0',c_int64_t), int(z'400b7837b4a2339c',c_int64_t), int(z'40099475a31a4bdc',c_int64_t), &
    int(z'4007050efdc9c4db',c_int64_t), int(z'4003d58644523f68',c_int64_t), int(z'40002c8b43958106',c_int64_t), int(z'3ff8525460aa64c3',c_int64_t), &
    int(z'3ff093f290abb44e',c_int64_t), int(z'3fbcfeef5ec80c74',c_int64_t), int(z'3fb7fdac68a936c6',c_int64_t), int(z'3fb2eaca0dd5ab99',c_int64_t), &
    int(z'3fabe3ace32279a8',c_int64_t), int(z'3fa1b5dbef7f7f3c',c_int64_t), int(z'3f8aaf1b0b1e4134',c_int64_t), int(z'3f5e2dd2f7085fa0',c_int64_t), &
    int(z'400de93f290abb45',c_int64_t), int(z'400cd2839042d8c3',c_int64_t), int(z'400b78e9f6a93f29',c_int64_t), int(z'4009a5119ce075f7',c_int64_t), &
    int(z'4006fd46b26bf877',c_int64_t), int(z'4003cd1b71758e22',c_int64_t), int(z'40003165d3996fa8',c_int64_t), int(z'3ff85ed288ce703b',c_int64_t), &
    int(z'3ff080dc33721d54',c_int64_t), int(z'3fbcff64cf8d716d',c_int64_t), int(z'3fb7facd9117ead8',c_int64_t), int(z'3fb2eba27ae9ab2a',c_int64_t), &
    int(z'3fabe227a7e4b5f8',c_int64_t), int(z'3fa1b5dbef7f7f3c',c_int64_t), int(z'3f8aaf1b0b1e4134',c_int64_t), int(z'3f5e2dd2f7085fa0',c_int64_t), &
    int(z'400de771c970f7ba',c_int64_t), int(z'400cd7a786c22681',c_int64_t), int(z'400b7e22e5de15ca',c_int64_t), int(z'4009a6b50b0f27bb',c_int64_t), &
    int(z'4006f68f08461f9f',c_int64_t), int(z'4003c95182a9930c',c_int64_t), int(z'400031b9b66f9336',c_int64_t), int(z'3ff866c4c5974e66',c_int64_t), &
    int(z'3ff07c6540cc78ea',c_int64_t), int(z'3fbcd045fe111277',c_int64_t), int(z'3fb7f1ec41065a8d',c_int64_t), int(z'3fb2ef88b9778573',c_int64_t), &
    int(z'3fabd9acaf20139c',c_int64_t), int(z'3fa1b2c0b20c5726',c_int64_t), int(z'3f8aaf0d9f24f3d5',c_int64_t), int(z'3f5e2dd2f7085fa0',c_int64_t), &
    int(z'400de79bbadc0981',c_int64_t), int(z'400ce132b55ef1fe',c_int64_t), int(z'400b7cf80dc33722',c_int64_t), int(z'4009a10e02214270',c_int64_t), &
    int(z'4006f5dcc63f1412',c_int64_t), int(z'4003c995aaf78fef',c_int64_t), int(z'400030307f23cc8e',c_int64_t), int(z'3ff86b313be22e5e',c_int64_t), &
    int(z'3ff08088509bf9c6',c_int64_t), int(z'3fbc75c4a83b1d0d',c_int64_t), int(z'3fb7ce18266772d6',c_int64_t), int(z'3fb2d11e6b251208',c_int64_t), &
    int(z'3fabc5b2fd17ee33',c_int64_t), int(z'3fa1b39416a2d9b4',c_int64_t), int(z'3f8aa89abe5cc781',c_int64_t), int(z'3f5e3c968943e100',c_int64_t), &
    int(z'400de8e60807357e',c_int64_t), int(z'400cf6ddaceee0f4',c_int64_t), int(z'400b6f49cf56eac8',c_int64_t), int(z'40099bda5119ce07',c_int64_t), &
    int(z'4006f36cdf266ba5',c_int64_t), int(z'4003ca5269595fee',c_int64_t), int(z'40002dd052934acb',c_int64_t), int(z'3ff870cdc8754f37',c_int64_t), &
    int(z'3ff08438088509c0',c_int64_t), int(z'3fbc919ef954eb14',c_int64_t), int(z'3fb75a88e29230f0',c_int64_t), int(z'3fb2c48adeebb342',c_int64_t), &
    int(z'3fab6c3760bf5d79',c_int64_t), int(z'3fa1ac6f5f336c3e',c_int64_t), int(z'3f8aa96411f85008',c_int64_t), int(z'3f5e3ca1460b5219',c_int64_t), &
    int(z'400deae297396d09',c_int64_t), int(z'400d3ca42aed1394',c_int64_t), int(z'400b406e19b90eaa',c_int64_t), int(z'400986cca2db61bb',c_int64_t), &
    int(z'4006f419e30014f9',c_int64_t), int(z'4003c87a8d64d7f1',c_int64_t), int(z'40002f5989df1173',c_int64_t), int(z'3ff86baf102363b2',c_int64_t), &
    int(z'3ff0885b18548a9c',c_int64_t), int(z'3fbc9289dadfb507',c_int64_t), int(z'3fb774e65bea0ba2',c_int64_t), int(z'3fb24c0fa30b3263',c_int64_t), &
    int(z'3fab3a0762cad073',c_int64_t), int(z'3fa1a9b8cb8e086c',c_int64_t), int(z'3f8aa9b499d0203e',c_int64_t), int(z'3f5e3ca1460b5219',c_int64_t), &
    int(z'400deb6ae7d566cf',c_int64_t), int(z'400d3a53b8e4b87c',c_int64_t), int(z'400b7f1e8e608073',c_int64_t), int(z'40094ede54b48d3b',c_int64_t), &
    int(z'4006f5d249e44fa0',c_int64_t), int(z'4003ca9691a75cd1',c_int64_t), int(z'40002b4b72c5197a',c_int64_t), int(z'3ff8685db76b3bb8',c_int64_t), &
    int(z'3ff08769ec2ce465',c_int64_t), int(z'3fbc70435efa615b',c_int64_t), int(z'3fb75ba61903dd04',c_int64_t), int(z'3fb234910144a39e',c_int64_t), &
    int(z'3fab3449b3a83899',c_int64_t), int(z'3fa1adf13f72dc96',c_int64_t), int(z'3f8aaab39d50de3f',c_int64_t), int(z'3f5e3cc17c61a561',c_int64_t)]
  integer(c_int64_t), parameter :: b22_sfluxref_bits_2(16) = [ &
    int(z'400de72da122fad7',c_int64_t), int(z'400d33482be8bc17',c_int64_t), int(z'400bc14a4d2b2bfe',c_int64_t), int(z'400938088509bf9c',c_int64_t), &
    int(z'4006e915379fa97e',c_int64_t), int(z'4003ca9bcfd4bf0a',c_int64_t), int(z'4000231f8a0902de',c_int64_t), int(z'3ff857689ca18bd6',c_int64_t), &
    int(z'3ff0818e757928e1',c_int64_t), int(z'3fbc7b784662bae0',c_int64_t), int(z'3fb75f18944b7bff',c_int64_t), int(z'3fb22d0ca884eee8',c_int64_t), &
    int(z'3fab3a4dd9a7a6a3',c_int64_t), int(z'3fa1a964e8b7e4de',c_int64_t), int(z'3f8aa9a72dd6d2e0',c_int64_t), int(z'3f5e3ca1460b5219',c_int64_t)]
  integer(c_int64_t), parameter :: b22_rayl_bits_1(1) = [ &
                                   int(z'3e50891ea90bc822', c_int64_t)]
  integer(c_int64_t), parameter :: b22_strrat_bits_1(1) = [ &
                                   int(z'3f9740c4156e264e', c_int64_t)]
  integer(c_int), parameter :: b22_layreffr_bits_1(1) = [ &
                               int(z'00000002', c_int)]
  integer(c_int64_t), parameter :: b23_selfref_bits_1(128) = [ &
    int(z'3ee52b71840cfba2',c_int64_t), int(z'3ee0ccf152c5a21a',c_int64_t), int(z'3edaaa8a048bb7fd',c_int64_t), int(z'3ed5299b797f881f',c_int64_t), &
    int(z'3ed0cb775dbfaec3',c_int64_t), int(z'3ecaa835885ef400',c_int64_t), int(z'3ec527c2af42186d',c_int64_t), int(z'3ec0c9fec891b984',c_int64_t), &
    int(z'3ebaa5de4c8233d4',c_int64_t), int(z'3eb525e465a4b05d',c_int64_t), int(z'3ee68f480ddf0678',c_int64_t), int(z'3ee4f7af06bcd557',c_int64_t), &
    int(z'3ee37cd89a6ab7ca',c_int64_t), int(z'3ee21cbea3d37d15',c_int64_t), int(z'3ee0d57eb9d1c2e0',c_int64_t), int(z'3edf4aaedefff215',c_int64_t), &
    int(z'3edd1550a870c353',c_int64_t), int(z'3edb07d628ba3525',c_int64_t), int(z'3ed91f74b12027a2',c_int64_t), int(z'3ed7598ace3641a3',c_int64_t), &
    int(z'3f025ed76fcbbc6d',c_int64_t), int(z'3f00bcafabfc331c',c_int64_t), int(z'3efe7f71fb1a1225',c_int64_t), int(z'3efbc93e8ac5ba61',c_int64_t), &
    int(z'3ef950c8953bae2f',c_int64_t), int(z'3ef7108f5aab9121',c_int64_t), int(z'3ef5038dcd345b0e',c_int64_t), int(z'3ef32541701c4e94',c_int64_t), &
    int(z'3ef171735e11455c',c_int64_t), int(z'3eefc8d0c760dabf',c_int64_t), int(z'3f201ef5d34525be',c_int64_t), int(z'3f1d115dcb623e8f',c_int64_t), &
    int(z'3f1a34d00f792416',c_int64_t), int(z'3f17a05e1889f0a1',c_int64_t), int(z'3f154ceffd107cf4',c_int64_t), int(z'3f13341ec769ac2e',c_int64_t), &
    int(z'3f1150286f317c7f',c_int64_t), int(z'3f0f37ac286255d3',c_int64_t), int(z'3f0c24edadea74d9',c_int64_t), int(z'3f095fa434bb0e2d',c_int64_t), &
    int(z'3f2b0ec68ebc933b',c_int64_t), int(z'3f28914663e7860c',c_int64_t), int(z'3f264e7604bf0188',c_int64_t), int(z'3f2440e5df7e9167',c_int64_t), &
    int(z'3f2263b869c6f6a8',c_int64_t), int(z'3f20b26e967a6f21',c_int64_t), int(z'3f1e521463a90b96',c_int64_t), int(z'3f1b87b4ae8cb49e',c_int64_t), &
    int(z'3f18ff193f051252',c_int64_t), int(z'3f16b22bde4097bf',c_int64_t), int(z'3f435ab07ab1a1f9',c_int64_t), int(z'3f41780adc2f9edd',c_int64_t), &
    int(z'3f3f88cf7a84b40d',c_int64_t), int(z'3f3c766dc580524b',c_int64_t), int(z'3f39b0a297109fad',c_int64_t), int(z'3f372ffaf80bf35c',c_int64_t), &
    int(z'3f34edbca048a422',c_int64_t), int(z'3f32e3d4c8912046',c_int64_t), int(z'3f310cc2b1150b55',c_int64_t), int(z'3f2ec726abcc8840',c_int64_t), &
    int(z'3f5ab5ee8ee96762',c_int64_t), int(z'3f585ffdec7f6fa2',c_int64_t), int(z'3f563e501ccdec07',c_int64_t), int(z'3f544c5d7bb12653',c_int64_t), &
    int(z'3f5285f44b40f10c',c_int64_t), int(z'3f50e74370981890',c_int64_t), int(z'3f4ed9bb58ed3d41',c_int64_t), int(z'3f4c271904c4f1f3',c_int64_t), &
    int(z'3f49b0dc9278cf30',c_int64_t), int(z'3f4771baf21dae00',c_int64_t), int(z'3f60c14356c1d8a8',c_int64_t), int(z'3f5f020e4d1fc36a',c_int64_t), &
    int(z'3f5cb16694df759c',c_int64_t), int(z'3f5a8cfed68a3ad7',c_int64_t), int(z'3f589186d0942c9d',c_int64_t), int(z'3f56bbeeae1e0b03',c_int64_t), &
    int(z'3f55096706f53cae',c_int64_t), int(z'3f53775622cc5dbc',c_int64_t), int(z'3f5203427fac5d97',c_int64_t), int(z'3f50aafdc512434f',c_int64_t), &
    int(z'3f61405f15ba2682',c_int64_t), int(z'3f60250674b93a74',c_int64_t), int(z'3f5e37b8fee4a201',c_int64_t), int(z'3f5c4769202a1700',c_int64_t), &
    int(z'3f5a76f9b1874c0f',c_int64_t), int(z'3f58c4471740b959',c_int64_t), int(z'3f572d839bd65fc9',c_int64_t), int(z'3f55b0d6cd00cf33',c_int64_t), &
    int(z'3f544c932b965bcd',c_int64_t), int(z'3f52ff2b6ec3ad13',c_int64_t), int(z'3f641413de2e4914',c_int64_t), int(z'3f6325fce9cb0a55',c_int64_t), &
    int(z'3f6242ede64cfb86',c_int64_t), int(z'3f616a609bf716f8',c_int64_t), int(z'3f609bdeee3780a0',c_int64_t), int(z'3f5fadd00769d6b3',c_int64_t), &
    int(z'3f5e362bb611497e',c_int64_t), int(z'3f5ccfef6c0912a3',c_int64_t), int(z'3f5b7a4469bc5c3c',c_int64_t), int(z'3f5a346969253294',c_int64_t), &
    int(z'3f65e90af0f4ca42',c_int64_t), int(z'3f64c09c3ce2089e',c_int64_t), int(z'3f63a7d297670f59',c_int64_t), int(z'3f629de1fdb679a4',c_int64_t), &
    int(z'3f61a1fe6d02e2b3',c_int64_t), int(z'3f60b36bfdaa0f5e',c_int64_t), int(z'3f5fa2e84cdafa0c',c_int64_t), int(z'3f5df6e0f273a569',c_int64_t), &
    int(z'3f5c61750ff76ee2',c_int64_t), int(z'3f5ae177ff95f7cf',c_int64_t), int(z'3f68f2099d37b3cb',c_int64_t), int(z'3f674236864ee414',c_int64_t), &
    int(z'3f65af94ada18e5b',c_int64_t), int(z'3f643830c8f5a7b7',c_int64_t), int(z'3f62da2d07a00772',c_int64_t), int(z'3f6193d12daf90a7',c_int64_t), &
    int(z'3f60638a93ed3248',c_int64_t), int(z'3f5e8fad5c9a09d7',c_int64_t), int(z'3f5c7ea64e32e8e0',c_int64_t), int(z'3f5a915b87902cb3',c_int64_t), &
    int(z'3f6bb9b4c2140c26',c_int64_t), int(z'3f69c822c3fa404d',c_int64_t), int(z'3f67f96b91489240',c_int64_t), int(z'3f664b2b2196d397',c_int64_t), &
    int(z'3f64bb0d87a7ff8e',c_int64_t), int(z'3f6346ff42ebb7f4',c_int64_t), int(z'3f61ed07aac43955',c_int64_t), int(z'3f60ab53ab4dcc11',c_int64_t)]
  integer(c_int64_t), parameter :: b23_selfref_bits_2(32) = [ &
    int(z'3f5f0056112ea687',c_int64_t), int(z'3f5cd3f636d37bbe',c_int64_t), int(z'3f6fd68f6e478651',c_int64_t), int(z'3f6d3f35cae81b32',c_int64_t), &
    int(z'3f6addd73632411b',c_int64_t), int(z'3f68ae11a0bc4da4',c_int64_t), int(z'3f66abde3fbbd7b2',c_int64_t), int(z'3f64d38171da8dd6',c_int64_t), &
    int(z'3f6321957bfda760',c_int64_t), int(z'3f6192fa6e1abac1',c_int64_t), int(z'3f6024d0c4d404fa',c_int64_t), int(z'3f5da8e816296224',c_int64_t), &
    int(z'3f70e5de6bb0a829',c_int64_t), int(z'3f6fbca3b4d081b8',c_int64_t), int(z'3f6dcda610a06134',c_int64_t), int(z'3f6bfcd5fefa9c69',c_int64_t), &
    int(z'3f6a485050d05212',c_int64_t), int(z'3f68ae6786f7d666',c_int64_t), int(z'3f672d78df0eeeb0',c_int64_t), int(z'3f65c3fc6ea5fafc',c_int64_t), &
    int(z'3f647085233ff60f',c_int64_t), int(z'3f6331bb63eebce2',c_int64_t), int(z'3f75e2d31e758bf3',c_int64_t), int(z'3f73c846ab352277',c_int64_t), &
    int(z'3f71e17ee085bc42',c_int64_t), int(z'3f702980ace3a353',c_int64_t), int(z'3f6d3798f3816c7c',c_int64_t), int(z'3f6a68a6dd79ee2e',c_int64_t), &
    int(z'3f67ded40b5a7c22',c_int64_t), int(z'3f65936fdee01fbb',c_int64_t), int(z'3f638085a16a1d80',c_int64_t), int(z'3f61a0a175b1071f',c_int64_t)]
  integer(c_int64_t), parameter :: b23_forref_bits_1(48) = [ &
    int(z'3e60f3e8eaddf0d9',c_int64_t), int(z'3e7209cc330a451e',c_int64_t), int(z'3e9d924acc0ce029',c_int64_t), int(z'3e950ce0d7610314',c_int64_t), &
    int(z'3e932497903a0730',c_int64_t), int(z'3ed1a8b5f57c8fba',c_int64_t), int(z'3eb6c956b3de6ed7',c_int64_t), int(z'3eb856c08376c32f',c_int64_t), &
    int(z'3ed9a39f69d8afdc',c_int64_t), int(z'3ed6667ab197aa3b',c_int64_t), int(z'3ed89701351d91e1',c_int64_t), int(z'3ee3963697ff8123',c_int64_t), &
    int(z'3ee4377921d7a6a8',c_int64_t), int(z'3ee6766ca17187e0',c_int64_t), int(z'3ee5e98ca6351634',c_int64_t), int(z'3effbf8df4f5b5cf',c_int64_t), &
    int(z'3f02beafb9d2b04d',c_int64_t), int(z'3f01dd1ebfe3cf2b',c_int64_t), int(z'3f1ada6e42753ce5',c_int64_t), int(z'3f1c6fa24f4ac0ee',c_int64_t), &
    int(z'3f1b96df550fa6e7',c_int64_t), int(z'3f2324c24e90ff0e',c_int64_t), int(z'3f228b9dd86d94d9',c_int64_t), int(z'3f21711f2fa3ba37',c_int64_t), &
    int(z'3f257e304b661eb2',c_int64_t), int(z'3f23b024e52b8229',c_int64_t), int(z'3f22b9b86a619513',c_int64_t), int(z'3f2ce3cca9cd7f8b',c_int64_t), &
    int(z'3f27fa8c6770c14d',c_int64_t), int(z'3f23c8bd51375dc3',c_int64_t), int(z'3f2dffd675a935aa',c_int64_t), int(z'3f29e901ae225f1d',c_int64_t), &
    int(z'3f2564c11fc56d32',c_int64_t), int(z'3f2eb1ad1cea57b3',c_int64_t), int(z'3f2c89f0d1863c67',c_int64_t), int(z'3f2840d851292c38',c_int64_t), &
    int(z'3f30dae1c1034892',c_int64_t), int(z'3f2fa9be7fd7fc81',c_int64_t), int(z'3f2cfd808d9dd1a6',c_int64_t), int(z'3f31db09508bb3a8',c_int64_t), &
    int(z'3f31bc8910680ab4',c_int64_t), int(z'3f30cb7af956a9c1',c_int64_t), int(z'3f363ef12c7d8c73',c_int64_t), int(z'3f33ada93d72f48c',c_int64_t), &
    int(z'3f32c7e9f537e129',c_int64_t), int(z'3f3634cf03779d8a',c_int64_t), int(z'3f374b17a2d650a7',c_int64_t), int(z'3f372fada8d65ead',c_int64_t)]
  integer(c_int64_t), parameter :: b23_sfluxref_bits_1(16) = [ &
    int(z'404a9ae48e8a71de',c_int64_t), int(z'4049b507c84b5dcc',c_int64_t), int(z'4048aadab9f559b4',c_int64_t), int(z'4046bb089a027525',c_int64_t), &
    int(z'40446a29c779a6b5',c_int64_t), int(z'4041970d844d013b',c_int64_t), int(z'403cb1d7dbf487fd',c_int64_t), int(z'40359339c0ebedfa',c_int64_t), &
    int(z'402d4710cb295e9e',c_int64_t), int(z'3ff9752fc2656abe',c_int64_t), int(z'3ff518fc504816f0',c_int64_t), int(z'3ff0a493c89f40a3',c_int64_t), &
    int(z'3fe863736cdf266c',c_int64_t), int(z'3fdefd5cb790fb65',c_int64_t), int(z'3fc754c985f06f69',c_int64_t), int(z'3f9a1b4f10df4b55',c_int64_t)]
  integer(c_int64_t), parameter :: b23_rayl_bits_1(16) = [ &
    int(z'3e6fef60a24f2a24',c_int64_t), int(z'3e6ea22ba46fa07e',c_int64_t), int(z'3e70da849acdfd14',c_int64_t), int(z'3e6de1e12ff56fa1',c_int64_t), &
    int(z'3e6c37648ff38b87',c_int64_t), int(z'3e696a31f41490b2',c_int64_t), int(z'3e66699be86870be',c_int64_t), int(z'3e655f674c2be4f7',c_int64_t), &
    int(z'3e65845c600d126c',c_int64_t), int(z'3e63ba9444c5fba5',c_int64_t), int(z'3e6288334431d804',c_int64_t), int(z'3e6295882685bcd0',c_int64_t), &
    int(z'3e61d51a82d88996',c_int64_t), int(z'3e61601a0e1ecb39',c_int64_t), int(z'3e5d44e598f84fea',c_int64_t), int(z'3e5fdebbce7abfb3',c_int64_t)]
  integer(c_int64_t), parameter :: b23_givfac_bits_1(1) = [ &
                                   int(z'3ff076c8b4395810', c_int64_t)]
  integer(c_int), parameter :: b23_layreffr_bits_1(1) = [ &
                               int(z'00000006', c_int)]
  integer(c_int64_t), parameter :: b24_selfref_bits_1(128) = [ &
    int(z'3edabfd7986e2596',c_int64_t), int(z'3ed0f111972b7c17',c_int64_t), int(z'3ec575c1d0d5d2fe',c_int64_t), int(z'3ebb2eebb703f3e7',c_int64_t), &
    int(z'3eb13768d799d745',c_int64_t), int(z'3ea5cedb2f3a2419',c_int64_t), int(z'3e9b9fc8ae7414d7',c_int64_t), int(z'3e917ee983036262',c_int64_t), &
    int(z'3e86296949a2d631',c_int64_t), int(z'3e7c127a0a3b452e',c_int64_t), int(z'3ef2f7a5ffb39ddf',c_int64_t), int(z'3ee6d5fcc3acdfea',c_int64_t), &
    int(z'3edb7e4d7045c23d',c_int64_t), int(z'3ed08ce63b068900',c_int64_t), int(z'3ec3ed0bf856f75c',c_int64_t), int(z'3eb7fd6aabf2c606',c_int64_t), &
    int(z'3eace1fe0b34ce88',c_int64_t), int(z'3ea163054883b3b7',c_int64_t), int(z'3e94eed4a8711f68',c_int64_t), int(z'3e8933cbfa9d84b8',c_int64_t), &
    int(z'3ef641d67c328765',c_int64_t), int(z'3eef9a7bcc112b9b',c_int64_t), int(z'3ee66fed9e8a8c64',c_int64_t), int(z'3edfdbf05ab64ef0',c_int64_t), &
    int(z'3ed69e69157a061d',c_int64_t), int(z'3ed00ef88cb557d6',c_int64_t), int(z'3ec6cd44c178fa48',c_int64_t), int(z'3ec0303c44672ab7',c_int64_t), &
    int(z'3eb6fc7de2d76cb8',c_int64_t), int(z'3eb051c30e123a17',c_int64_t), int(z'3eebc960e6dd8aae',c_int64_t), int(z'3ee8c2e377b0a702',c_int64_t), &
    int(z'3ee610bdb15eaecd',c_int64_t), int(z'3ee3a9b240dc7581',c_int64_t), int(z'3ee185a4724d3de3',c_int64_t), int(z'3edf3a8335b66490',c_int64_t), &
    int(z'3edbd4156f3eae67',c_int64_t), int(z'3ed8cc6c62236aa4',c_int64_t), int(z'3ed619393a72e861',c_int64_t), int(z'3ed3b1484409edb1',c_int64_t), &
    int(z'3eea04e75a11a561',c_int64_t), int(z'3ee954986646639a',c_int64_t), int(z'3ee8a902e8f492e8',c_int64_t), int(z'3ee801efe85c7f9b',c_int64_t), &
    int(z'3ee75f43e79e4fdb',c_int64_t), int(z'3ee6c0f1284a16bd',c_int64_t), int(z'3ee626c0b0a02090',c_int64_t), int(z'3ee590b280a06d56',c_int64_t), &
    int(z'3ee4fe8f9e8b495e',c_int64_t), int(z'3ee470596a38b2c1',c_int64_t), int(z'3f0599b09adbf1aa',c_int64_t), int(z'3f03886a69a2a858',c_int64_t), &
    int(z'3f01a9cf05870991',c_int64_t), int(z'3efff1fe58b7b170',c_int64_t), int(z'3efce33c5a3647df',c_int64_t), int(z'3efa1f6cd60cd489',c_int64_t), &
    int(z'3ef79f573e6d5d82',c_int64_t), int(z'3ef55c836fa8ddc4',c_int64_t), int(z'3ef35117541774e0',c_int64_t), int(z'3ef177c925a87a15',c_int64_t), &
    int(z'3f0c2c89e063e473',c_int64_t), int(z'3f0a4455c3a197fa',c_int64_t), int(z'3f087d2d04f96c9c',c_int64_t), int(z'3f06d4d1d5aa7ee0',c_int64_t), &
    int(z'3f05492fa243b212',c_int64_t), int(z'3f03d857a307b509',c_int64_t), int(z'3f0280731d7d1534',c_int64_t), int(z'3f013fd802162204',c_int64_t), &
    int(z'3f0014f0deed0e4a',c_int64_t), int(z'3efdfc8e5d2fc3d9',c_int64_t), int(z'3f09ea19b64ada63',c_int64_t), int(z'3f08ec3db3f33fb1',c_int64_t), &
    int(z'3f07f81956be27c3',c_int64_t), int(z'3f070d4c699c1827',c_int64_t), int(z'3f062b7d96b58ce0',c_int64_t), int(z'3f055250189706b4',c_int64_t), &
    int(z'3f04817178a0f81e',c_int64_t), int(z'3f03b892afcfced0',c_int64_t), int(z'3f02f764b71ff87f',c_int64_t), int(z'3f023d98878de2de',c_int64_t), &
    int(z'3f03c9f7b577a956',c_int64_t), int(z'3f03d419de7d983f',c_int64_t), int(z'3f03de42e6bb7d9d',c_int64_t), int(z'3f03e872ce315972',c_int64_t), &
    int(z'3f03f2a625433081',c_int64_t), int(z'3f03fcdcebf102cc',c_int64_t), int(z'3f04071a91d6cb8c',c_int64_t), int(z'3f04115ba7588f87',c_int64_t), &
    int(z'3f041ba39c1249f8',c_int64_t), int(z'3f0425f27003fae0',c_int64_t), int(z'3ef9c941e25471bd',c_int64_t), int(z'3efc04239863f91f',c_int64_t), &
    int(z'3efe7062d176f9b3',c_int64_t), int(z'3f0089258843be98',c_int64_t), int(z'3f01f739b7fb922f',c_int64_t), int(z'3f0384facda76d61',c_int64_t), &
    int(z'3f05351eda5b8cb6',c_int64_t), int(z'3f070aa416f7c88c',c_int64_t), int(z'3f0908c325b7a82b',c_int64_t), int(z'3f0b3300403e49ed',c_int64_t), &
    int(z'3ef38f12a7d96a98',c_int64_t), int(z'3ef62b2e8fb1fa94',c_int64_t), int(z'3ef9207713bec0f4',c_int64_t), int(z'3efc7ac99a9f4559',c_int64_t), &
    int(z'3f0023d35da464be',c_int64_t), int(z'3f024b2a4c8f0cbe',c_int64_t), int(z'3f04bc11ce0f9641',c_int64_t), int(z'3f07805d04285de1',c_int64_t), &
    int(z'3f0aa32c5af5f194',c_int64_t), int(z'3f0e311a339ad2a3',c_int64_t), int(z'3ee70bff1f81e6d0',c_int64_t), int(z'3eec0f02bbece1b2',c_int64_t), &
    int(z'3ef1148b8e7a3cee',c_int64_t), int(z'3ef4cb65afe24f4e',c_int64_t), int(z'3ef9510d4d6b4ecb',c_int64_t), int(z'3efed2720b06da95',c_int64_t), &
    int(z'3f02c32b5754773c',c_int64_t), int(z'3f06d7adb27286f0',c_int64_t), int(z'3f0bcf56796544f4',c_int64_t), int(z'3f10edc34f6612db',c_int64_t), &
    int(z'3e88ae3d90bd50a6',c_int64_t), int(z'3e9a3da7bfac7757',c_int64_t), int(z'3eabe64a43abcedb',c_int64_t), int(z'3ebda9c28752b2e9',c_int64_t), &
    int(z'3ecf89cef178516d',c_int64_t), int(z'3ee0c41594a1ee13',c_int64_t), int(z'3ef1d3671ac14c66',c_int64_t), int(z'3f02f3dd0de0deeb',c_int64_t)]
  integer(c_int64_t), parameter :: b24_selfref_bits_2(32) = [ &
    int(z'3f1426907e0b1f78',c_int64_t), int(z'3f256ca3c23c7b06',c_int64_t), int(z'3e6905704a4e82ba',c_int64_t), int(z'3e7929e4f1e8b460',c_int64_t), &
    int(z'3e894e9022ab9014',c_int64_t), int(z'3e99736e57dec8cd',c_int64_t), int(z'3ea9988386d1b535',c_int64_t), int(z'3eb9bdcfaf84554d',c_int64_t), &
    int(z'3ec9e34e6c1048c9',c_int64_t), int(z'3eda0906e20bec24',c_int64_t), int(z'3eea2ef0d2674ad0',c_int64_t), int(z'3efa551cbb424de8',c_int64_t), &
    int(z'3e90b51e0eb51b37',c_int64_t), int(z'3e8d18810b9c560e',c_int64_t), int(z'3e8955aced3b4a24',c_int64_t), int(z'3e860f4c41c71609',c_int64_t), &
    int(z'3e83355342bc665c',c_int64_t), int(z'3e80b9ab8a2ec959',c_int64_t), int(z'3e7d206825915dae',c_int64_t), int(z'3e795c94f0fe80aa',c_int64_t), &
    int(z'3e76155317770a44',c_int64_t), int(z'3e733a8e06aae682',c_int64_t), int(z'3e90ed8da3e6c3c2',c_int64_t), int(z'3e8d92a727f2c65a',c_int64_t), &
    int(z'3e89d4f1a7bdd24d',c_int64_t), int(z'3e86905a61e0bcdc',c_int64_t), int(z'3e83b59fdf3d8036',c_int64_t), int(z'3e813752da19f5cb',c_int64_t), &
    int(z'3e7e13894d0caa3b',c_int64_t), int(z'3e7a457e2336110c',c_int64_t), int(z'3e76f2ad4839877a',c_int64_t), int(z'3e740b7f1155a855',c_int64_t)]
  integer(c_int64_t), parameter :: b24_forref_bits_1(48) = [ &
    int(z'3e36254a75cd6ba3',c_int64_t), int(z'3e8197ce47fa6d9b',c_int64_t), int(z'3e976c6d5baf3dbd',c_int64_t), int(z'3e61b20e7f09301e',c_int64_t), &
    int(z'3e9ce3e1d4322ef7',c_int64_t), int(z'3ed33bd8de7cf24a',c_int64_t), int(z'3e894403bc209b0c',c_int64_t), int(z'3eaa9b39b5842d2d',c_int64_t), &
    int(z'3ec6698f97e3631e',c_int64_t), int(z'3ea4827c60adec03',c_int64_t), int(z'3eaace394f63c867',c_int64_t), int(z'3e9b9ef12d5ba665',c_int64_t), &
    int(z'3eb2c6327f304333',c_int64_t), int(z'3eaeb2e361a2a900',c_int64_t), int(z'3e9dda163bc2d04a',c_int64_t), int(z'3ec3bf27b036abc6',c_int64_t), &
    int(z'3ec692db65ca0fd5',c_int64_t), int(z'3ea8d34e59c9dcc3',c_int64_t), int(z'3ed0c85fb7c3f9b1',c_int64_t), int(z'3ecfb8632597a8ce',c_int64_t), &
    int(z'3e8f0a3473e97384',c_int64_t), int(z'3ed378ebeca82a70',c_int64_t), int(z'3ecf33124e50b8dd',c_int64_t), int(z'3e9ee93c99fd9db9',c_int64_t), &
    int(z'3ed3ff83debd5450',c_int64_t), int(z'3eca28bc070fe84d',c_int64_t), int(z'3eaf5df720e86100',c_int64_t), int(z'3ed74e99ccb571dd',c_int64_t), &
    int(z'3ec3f9c805a549e9',c_int64_t), int(z'3e657e260aa50e35',c_int64_t), int(z'3ed7de52351df05e',c_int64_t), int(z'3ec071e7cccc01bc',c_int64_t), &
    int(z'3e641ac24acfd4aa',c_int64_t), int(z'3ed73e2eea9c3c1b',c_int64_t), int(z'3eb61980b252852b',c_int64_t), int(z'3e6575b5b89c4a2f',c_int64_t), &
    int(z'3ed36808184f9c93',c_int64_t), int(z'3e59a4cc91d7b1a6',c_int64_t), int(z'3e617daa36ae1361',c_int64_t), int(z'3eab2232f6226993',c_int64_t), &
    int(z'3d727e7442cc8133',c_int64_t), int(z'3e4fee5fc9c13285',c_int64_t), int(z'3d6e6f718b0f4a66',c_int64_t), int(z'3d6cefd3b07f1e04',c_int64_t), &
    int(z'3d6d0dbfb32db654',c_int64_t), int(z'3d70a3440de1313a',c_int64_t), int(z'3d6c385bf922a6a4',c_int64_t), int(z'3d697fce373b9e62',c_int64_t)]
  integer(c_int64_t), parameter :: b24_sfluxref_bits_1(128) = [ &
    int(z'40412e353f7ced91',c_int64_t), int(z'40408fdf3b645a1d',c_int64_t), int(z'403f65119ce075f7',c_int64_t), int(z'403cb98c7e28240b',c_int64_t), &
    int(z'4038c9d495182a99',c_int64_t), int(z'40357d3c36113405',c_int64_t), int(z'403165aee631f8a1',c_int64_t), int(z'402b95e9e1b089a0',c_int64_t), &
    int(z'402316d86ec17ebb',c_int64_t), int(z'3ff0cce1c58255b0',c_int64_t), int(z'3febc12f09d8c6d6',c_int64_t), int(z'3fe5f1b0468448cf',c_int64_t), &
    int(z'3fe026a65cf67b1c',c_int64_t), int(z'3fd4adddf43c7d5f',c_int64_t), int(z'3fbf476295208e15',c_int64_t), int(z'3f916fff6c5c49ad',c_int64_t), &
    int(z'40411e4c2f837b4a',c_int64_t), int(z'40403762b6ae7d56',c_int64_t), int(z'403e1617c1bda512',c_int64_t), int(z'403c35604189374c',c_int64_t), &
    int(z'4039a73eab367a10',c_int64_t), int(z'40365758e219652c',c_int64_t), int(z'40324faacd9e83e4',c_int64_t), int(z'402bb4467381d7dc',c_int64_t), &
    int(z'4023054c985f06f7',c_int64_t), int(z'3ff0a97e132b55ef',c_int64_t), int(z'3feba1bc126a65cf',c_int64_t), int(z'3fe5d96a6a01259a',c_int64_t), &
    int(z'3fe026aca7935760',c_int64_t), int(z'3fd4adb402d16b98',c_int64_t), int(z'3fbf480a5accd530',c_int64_t), int(z'3f916fff6c5c49ad',c_int64_t), &
    int(z'4041181a36e2eb1c',c_int64_t), int(z'40401fbb2fec56d6',c_int64_t), int(z'403e43d70a3d70a4',c_int64_t), int(z'403c4a9930be0ded',c_int64_t), &
    int(z'4039a9a027525461',c_int64_t), int(z'403650f9096bb98c',c_int64_t), int(z'4032552bd3c36113',c_int64_t), int(z'402bb39c0ebedfa4',c_int64_t), &
    int(z'4022fbda5119ce07',c_int64_t), int(z'3ff09667b5f1bef5',c_int64_t), int(z'3feb76f6d7625205',c_int64_t), int(z'3fe5ceb9a176ddad',c_int64_t), &
    int(z'3fe00b2a6b0d9514',c_int64_t), int(z'3fd4add590c0ad04',c_int64_t), int(z'3fbf476295208e15',c_int64_t), int(z'3f916fff6c5c49ad',c_int64_t), &
    int(z'40411178d4fdf3b6',c_int64_t), int(z'40401da5119ce076',c_int64_t), int(z'403e551eb851eb85',c_int64_t), int(z'403c549ba5e353f8',c_int64_t), &
    int(z'4039a45a1cac0831',c_int64_t), int(z'4036528240b78034',c_int64_t), int(z'403257525460aa65',c_int64_t), int(z'402bb1b71758e219',c_int64_t), &
    int(z'4022f328b6d86ec1',c_int64_t), int(z'3ff08a47ecfe9b7c',c_int64_t), int(z'3feb5f45e0b4e11e',c_int64_t), int(z'3fe5bb107746887b',c_int64_t), &
    int(z'3fdfdf3300de4c51',c_int64_t), int(z'3fd4ace67d77fae3',c_int64_t), int(z'3fbf476295208e15',c_int64_t), int(z'3f916fff6c5c49ad',c_int64_t), &
    int(z'404105e353f7ced9',c_int64_t), int(z'404023c6a7ef9db2',c_int64_t), int(z'403e6a29c779a6b5',c_int64_t), int(z'403c4ff2e48e8a72',c_int64_t), &
    int(z'4039a4d013a92a30',c_int64_t), int(z'403652e48e8a71de',c_int64_t), int(z'40325816f0068db9',c_int64_t), int(z'402bb4a2339c0ebf',c_int64_t), &
    int(z'4022e789613d31ba',c_int64_t), int(z'3ff07d41743e963e',c_int64_t), int(z'3feb544567125dd1',c_int64_t), int(z'3fe59e236c15d2d0',c_int64_t), &
    int(z'3fdfe4de3b8a19ca',c_int64_t), int(z'3fd47c0f45176146',c_int64_t), int(z'3fbf480a5accd530',c_int64_t), int(z'3f916fff6c5c49ad',c_int64_t), &
    int(z'4040fed5cfaacd9f',c_int64_t), int(z'404028068db8bac7',c_int64_t), int(z'403e7c432ca57a78',c_int64_t), int(z'403c4ced916872b0',c_int64_t), &
    int(z'4039a189374bc6a8',c_int64_t), int(z'403654538ef34d6a',c_int64_t), int(z'4032588ce703afb8',c_int64_t), int(z'402bb295e9e1b08a',c_int64_t), &
    int(z'4022dde15ca6ca04',c_int64_t), int(z'3ff076d330941c82',c_int64_t), int(z'3feb498c3b0c4589',c_int64_t), int(z'3fe583a96d4c33b5',c_int64_t), &
    int(z'3fdfe02645e4e69f',c_int64_t), int(z'3fd45610adcd2d45',c_int64_t), int(z'3fbf476295208e15',c_int64_t), int(z'3f916fff6c5c49ad',c_int64_t), &
    int(z'4040f6147ae147ae',c_int64_t), int(z'404034710cb295ea',c_int64_t), int(z'403e833333333333',c_int64_t), int(z'403c47ef9db22d0e',c_int64_t), &
    int(z'4039a381d7dbf488',c_int64_t), int(z'40364ed916872b02',c_int64_t), int(z'40325f1a9fbe76c9',c_int64_t), int(z'402ba64c2f837b4a',c_int64_t), &
    int(z'4022d630a91537a0',c_int64_t), int(z'3ff070068db8bac7',c_int64_t), int(z'3feb39cf9a06a6e3',c_int64_t), int(z'3fe57befd00713f0',c_int64_t), &
    int(z'3fdfce703afb7e91',c_int64_t), int(z'3fd44c51116a8b8f',c_int64_t), int(z'3fbe8a3f8982cb21',c_int64_t), int(z'3f916ddfd76b8c40',c_int64_t), &
    int(z'4040f26e978d4fdf',c_int64_t), int(z'40403f5f6fd21ff3',c_int64_t), int(z'403e8ca57a786c22',c_int64_t), int(z'403c475f6fd21ff3',c_int64_t), &
    int(z'403998f5c28f5c29',c_int64_t), int(z'4036528f5c28f5c3',c_int64_t), int(z'403255f6fd21ff2e',c_int64_t), int(z'402ba3c9eecbfb16',c_int64_t), &
    int(z'4022ce3fbbd7b203',c_int64_t), int(z'3ff070ae536501e2',c_int64_t), int(z'3feb392c061847f5',c_int64_t), int(z'3fe571e29b6b2af1',c_int64_t), &
    int(z'3fdfa2834d26fa40',c_int64_t), int(z'3fd4368ad6883772',c_int64_t), int(z'3fbdbef49cf56ead',c_int64_t), int(z'3f90cec778cff576',c_int64_t)]
  integer(c_int64_t), parameter :: b24_sfluxref_bits_2(16) = [ &
    int(z'404153367a0f9097',c_int64_t), int(z'404055a1cac08312',c_int64_t), int(z'403e4985f06f6944',c_int64_t), int(z'403c1872b020c49c',c_int64_t), &
    int(z'40397758e219652c',c_int64_t), int(z'40362504816f0069',c_int64_t), int(z'403246809d495183',c_int64_t), int(z'402b83bcd35a8588',c_int64_t), &
    int(z'4022bb9f559b3d08',c_int64_t), int(z'3ff060807357e671',c_int64_t), int(z'3feb1be2b4959e62',c_int64_t), int(z'3fe56481f53825e1',c_int64_t), &
    int(z'3fdf4ed2cbea4ebe',c_int64_t), int(z'3fd41522a6f3f530',c_int64_t), int(z'3fbdf88fc9363f57',c_int64_t), int(z'3f907b06309ba93e',c_int64_t)]
  integer(c_int64_t), parameter :: b24_abso3a_bits_1(16) = [ &
    int(z'3fb48efada2651a3',c_int64_t), int(z'3fc728954a7f8013',c_int64_t), int(z'3fcd1e321a2e7f6f',c_int64_t), int(z'3fc58183f91e646f',c_int64_t), &
    int(z'3fc1b34a44c7b02d',c_int64_t), int(z'3fbd524bfd2e9468',c_int64_t), int(z'3fb852aac7bf46d2',c_int64_t), int(z'3fb4a78ca1639277',c_int64_t), &
    int(z'3fb150e4f4e1becc',c_int64_t), int(z'3fad2c823f0a010b',c_int64_t), int(z'3facd7101cadb5b0',c_int64_t), int(z'3fa76dbff6fb7480',c_int64_t), &
    int(z'3fa5996dfaaf5e27',c_int64_t), int(z'3fa1d0a31b229b35',c_int64_t), int(z'3f9b35fa8dd037bb',c_int64_t), int(z'3f9b67b51aff5fc7',c_int64_t)]
  integer(c_int64_t), parameter :: b24_abso3b_bits_1(16) = [ &
    int(z'3f9e31436eea9966',c_int64_t), int(z'3fa633d519a26875',c_int64_t), int(z'3fb12833fbb00f27',c_int64_t), int(z'3fbae09fe86833c6',c_int64_t), &
    int(z'3fc3fdb4cc250721',c_int64_t), int(z'3fcb79420b3d4ae4',c_int64_t), int(z'3fd10abf76a2f48c',c_int64_t), int(z'3fd459253543aeab',c_int64_t), &
    int(z'3fd6bdad7518b0d1',c_int64_t), int(z'3fd7c2699c7bcc29',c_int64_t), int(z'3fd7f61aa3f034b1',c_int64_t), int(z'3fd4eb0fadf2ecf2',c_int64_t), &
    int(z'3fc0310dbf0563ed',c_int64_t), int(z'3fb1cc7b6e3567c1',c_int64_t), int(z'3f9a6fe718a86d72',c_int64_t), int(z'3f99e4a0282913f6',c_int64_t)]
  integer(c_int64_t), parameter :: b24_rayla_bits_1(128) = [ &
    int(z'3e813bf653138566',c_int64_t), int(z'3e83876054b0e682',c_int64_t), int(z'3e86736c126f4c5a',c_int64_t), int(z'3e8a2733807ed5fd',c_int64_t), &
    int(z'3e8ce3dd6e4bceab',c_int64_t), int(z'3e8f87ca2c3b1ec8',c_int64_t), int(z'3e90ae31a50b8465',c_int64_t), int(z'3e8828e3eda9a01d',c_int64_t), &
    int(z'3e83a9d6cfe775f4',c_int64_t), int(z'3e81a152cc86d0f2',c_int64_t), int(z'3e81ed27c6b7265c',c_int64_t), int(z'3e8233cc8b21e2bc',c_int64_t), &
    int(z'3e806e0b56caf778',c_int64_t), int(z'3e8015bd61458c00',c_int64_t), int(z'3e80188ea8db3c5b',c_int64_t), int(z'3e80243d54cb04d8',c_int64_t), &
    int(z'3e8302184936b727',c_int64_t), int(z'3e89f6690cc290a6',c_int64_t), int(z'3e8e34e64eab26ce',c_int64_t), int(z'3e8afb2a998bcbb3',c_int64_t), &
    int(z'3e88d94b11e7f383',c_int64_t), int(z'3e872cf6f96dbc9b',c_int64_t), int(z'3e861d7d0b19c992',c_int64_t), int(z'3e8561eb2beaf687',c_int64_t), &
    int(z'3e8374d270caa815',c_int64_t), int(z'3e8272ad64ca99d8',c_int64_t), int(z'3e8274ab912e3c0b',c_int64_t), int(z'3e82886d5212cf1c',c_int64_t), &
    int(z'3e806ebb42ca0343',c_int64_t), int(z'3e8015cef8df0d2e',c_int64_t), int(z'3e8018744574fa96',c_int64_t), int(z'3e802507a4305268',c_int64_t), &
    int(z'3e83834998836056',c_int64_t), int(z'3e8a718e3f4ad20c',c_int64_t), int(z'3e8de6b2664ae8b3',c_int64_t), int(z'3e8a50a397121d23',c_int64_t), &
    int(z'3e88a0d716cfeaac',c_int64_t), int(z'3e8726e210dc943c',c_int64_t), int(z'3e862243b3465b8a',c_int64_t), int(z'3e8550392f0386d8',c_int64_t), &
    int(z'3e839fab2b28c769',c_int64_t), int(z'3e83187f56b1379f',c_int64_t), int(z'3e82d9a748d5411b',c_int64_t), int(z'3e82b90bcacf5180',c_int64_t), &
    int(z'3e8109a00c596586',c_int64_t), int(z'3e8015cef8df0d2e',c_int64_t), int(z'3e8018744574fa96',c_int64_t), int(z'3e802507a4305268',c_int64_t), &
    int(z'3e83e5ba66fab9c2',c_int64_t), int(z'3e8ad6812b251684',c_int64_t), int(z'3e8d44127dc641c3',c_int64_t), int(z'3e8a063740ac9fe6',c_int64_t), &
    int(z'3e88942088e1907e',c_int64_t), int(z'3e87409e56ec0de7',c_int64_t), int(z'3e860dfe01627fa1',c_int64_t), int(z'3e853f13eee82099',c_int64_t), &
    int(z'3e83ebf27ebee47e',c_int64_t), int(z'3e836e39973a36dd',c_int64_t), int(z'3e8349a1c06d02dc',c_int64_t), int(z'3e8296c14a988501',c_int64_t), &
    int(z'3e81ae46ed0e6f41',c_int64_t), int(z'3e806a296169f4d6',c_int64_t), int(z'3e8018744574fa96',c_int64_t), int(z'3e802507a4305268',c_int64_t), &
    int(z'3e84501b1b33db66',c_int64_t), int(z'3e8acaece29b8fcc',c_int64_t), int(z'3e8ccc541b6c7abd',c_int64_t), int(z'3e8a03bdef167571',c_int64_t), &
    int(z'3e888f8ea7818211',c_int64_t), int(z'3e873d25ef241258',c_int64_t), int(z'3e86172a8fef5d12',c_int64_t), int(z'3e851ead37aeb488',c_int64_t), &
    int(z'3e844b1fac3ac5e5',c_int64_t), int(z'3e83a5568620e8b5',c_int64_t), int(z'3e8385362d4d815c',c_int64_t), int(z'3e8288e87745575d',c_int64_t), &
    int(z'3e821f7541a485a6',c_int64_t), int(z'3e811d010b71b21a',c_int64_t), int(z'3e8018744574fa96',c_int64_t), int(z'3e802507a4305268',c_int64_t), &
    int(z'3e84bb461ed24a99',c_int64_t), int(z'3e8a85d3f12eadf5',c_int64_t), int(z'3e8c73fd5a1a4eaf',c_int64_t), int(z'3e8a03fb81afb992',c_int64_t), &
    int(z'3e88aec181bc997e',c_int64_t), int(z'3e873c879abe87bb',c_int64_t), int(z'3e8606314ad3b9c6',c_int64_t), int(z'3e8528d8dc6d6314',c_int64_t), &
    int(z'3e848e7803dd49a9',c_int64_t), int(z'3e83b57cb00a7dda',c_int64_t), int(z'3e836cfcee6f21a3',c_int64_t), int(z'3e82df5b6f9a22fd',c_int64_t), &
    int(z'3e826e477e6a4e5d',c_int64_t), int(z'3e81f9de54a5808b',c_int64_t), int(z'3e8029b3e8f6a29a',c_int64_t), int(z'3e802507a4305268',c_int64_t), &
    int(z'3e855988ecc366a6',c_int64_t), int(z'3e89df1480afc042',c_int64_t), int(z'3e8c2ae80fe62871',c_int64_t), int(z'3e8a30af393e78bd',c_int64_t), &
    int(z'3e88a5db5195c0c4',c_int64_t), int(z'3e8752f77405c8ca',c_int64_t), int(z'3e85e80652973409',c_int64_t), int(z'3e85671295e3cefb',c_int64_t), &
    int(z'3e84b6c5d50bbd5a',c_int64_t), int(z'3e839e9a7d5d7521',c_int64_t), int(z'3e83924d7d082206',c_int64_t), int(z'3e83378635ec8c1a',c_int64_t), &
    int(z'3e82c3636a8dc2fe',c_int64_t), int(z'3e825bb99a840ff1',c_int64_t), int(z'3e81e712de25fdfd',c_int64_t), int(z'3e802507a4305268',c_int64_t), &
    int(z'3e85c08b9c9ace7f',c_int64_t), int(z'3e892b728742b56e',c_int64_t), int(z'3e8bcf074f327fa5',c_int64_t), int(z'3e8a8bf1a58c96eb',c_int64_t), &
    int(z'3e88d1cd858bf2f6',c_int64_t), int(z'3e87368d1593a120',c_int64_t), int(z'3e8634d1972c99f6',c_int64_t), int(z'3e858560bd535713',c_int64_t), &
    int(z'3e84b93f26a1e7cf',c_int64_t), int(z'3e83d23638af6ad3',c_int64_t), int(z'3e83c4be272883ab',c_int64_t), int(z'3e83747a7acb2230',c_int64_t), &
    int(z'3e8320d8ca0c06ea',c_int64_t), int(z'3e82f0664c4f4778',c_int64_t), int(z'3e83f4e17ab27dce',c_int64_t), int(z'3e8448af26715c07',c_int64_t)]
  integer(c_int64_t), parameter :: b24_rayla_bits_2(16) = [ &
    int(z'3e7ffdc7f4ca87bb',c_int64_t), int(z'3e8908d8dcd923a0',c_int64_t), int(z'3e8d924666267fde',c_int64_t), int(z'3e8ca948179d2145',c_int64_t), &
    int(z'3e89cbdf7c9736a1',c_int64_t), int(z'3e88612321f5256a',c_int64_t), int(z'3e86d4510de8cb3e',c_int64_t), int(z'3e8627d4aad83b11',c_int64_t), &
    int(z'3e8572d2d96d18a6',c_int64_t), int(z'3e8509b799cbccd4',c_int64_t), int(z'3e844c6520d29bb6',c_int64_t), int(z'3e8452107bcabd02',c_int64_t), &
    int(z'3e84156b611eec3b',c_int64_t), int(z'3e83df2a59370922',c_int64_t), int(z'3e84012e7b07d0e9',c_int64_t), int(z'3e8444aa01dd5709',c_int64_t)]
  integer(c_int64_t), parameter :: b24_raylb_bits_1(16) = [ &
    int(z'3e809c913fbd95e4',c_int64_t), int(z'3e82dc5e2d04afb0',c_int64_t), int(z'3e85b0e097e3c19b',c_int64_t), int(z'3e8897cdb7760f97',c_int64_t), &
    int(z'3e8b3d57dffcbb6b',c_int64_t), int(z'3e8db61cb95b26e6',c_int64_t), int(z'3e8ffe3a4e304f66',c_int64_t), int(z'3e90fad5548787ab',c_int64_t), &
    int(z'3e8c7b3488104a84',c_int64_t), int(z'3e82627e6f14441b',c_int64_t), int(z'3e82ac0ede7af29a',c_int64_t), int(z'3e82669df70e8ade',c_int64_t), &
    int(z'3e81e181e6941e76',c_int64_t), int(z'3e829d861f28b92c',c_int64_t), int(z'3e8016a214111b55',c_int64_t), int(z'3e801d4c853b0dbb',c_int64_t)]
  integer(c_int64_t), parameter :: b24_strrat_bits_1(1) = [ &
                                   int(z'3fbfebd09e12a51e', c_int64_t)]
  integer(c_int), parameter :: b24_layreffr_bits_1(1) = [ &
                               int(z'00000001', c_int)]
  integer(c_int64_t), parameter :: b25_sfluxref_bits_1(16) = [ &
    int(z'404557c84b5dcc64',c_int64_t), int(z'4046e2d0e5604189',c_int64_t), int(z'40467e5c91d14e3c',c_int64_t), int(z'4046fbac710cb296',c_int64_t), &
    int(z'404745dcc63f1412',c_int64_t), int(z'4044d8a71de69ad4',c_int64_t), int(z'40402507c84b5dcc',c_int64_t), int(z'403817c1bda5119d',c_int64_t), &
    int(z'4030c4c2f837b4a2',c_int64_t), int(z'3ffdc486ad2dcb14',c_int64_t), int(z'3ff8a62cba732df5',c_int64_t), int(z'3ff3c2aed1394318',c_int64_t), &
    int(z'3fed48605681ecd5',c_int64_t), int(z'3fe2e2174c4cdfad',c_int64_t), int(z'3fcbfbce4217d285',c_int64_t), int(z'3fa0732c4786a74f',c_int64_t)]
  integer(c_int64_t), parameter :: b25_rayl_bits_1(16) = [ &
    int(z'3eb075ee0ad99ecd',c_int64_t), int(z'3eabb3e4984b5df3',c_int64_t), int(z'3ea68670b5a1b2bd',c_int64_t), int(z'3ea29302846a84bb',c_int64_t), &
    int(z'3e9aaafceaae4bb1',c_int64_t), int(z'3e98b5bb1d195132',c_int64_t), int(z'3e9db0036ae39e3b',c_int64_t), int(z'3e9eb8ed4b73e0a3',c_int64_t), &
    int(z'3e9c5da37e52ef19',c_int64_t), int(z'3e99fa8cfaa337b4',c_int64_t), int(z'3e997d160b9e2e80',c_int64_t), int(z'3e985f974ef74ae1',c_int64_t), &
    int(z'3e979df4ed1dafc2',c_int64_t), int(z'3e966e0b7bc39012',c_int64_t), int(z'3e966f208f7542a5',c_int64_t), int(z'3e96534753b584b6',c_int64_t)]
  integer(c_int64_t), parameter :: b25_abso3a_bits_1(16) = [ &
    int(z'3f97d325ac61f33a',c_int64_t), int(z'3fad7fc4057dee42',c_int64_t), int(z'3fc00cbf2b239a39',c_int64_t), int(z'3fd00296b3354c12',c_int64_t), &
    int(z'3fd83d89ce4a7b4e',c_int64_t), int(z'3fd9bd944aa53fc0',c_int64_t), int(z'3fd687980f55de59',c_int64_t), int(z'3fd687c200c0f020',c_int64_t), &
    int(z'3fd8b85e80bed741',c_int64_t), int(z'3fda88c60cbf2b24',c_int64_t), int(z'3fdae29307af20ea',c_int64_t), int(z'3fdbdec1c1d6cf85',c_int64_t), &
    int(z'3fdc82dbe7f2c301',c_int64_t), int(z'3fdd6940357a3550',c_int64_t), int(z'3fdcfca42aed1394',c_int64_t), int(z'3fdd3cd573647bab',c_int64_t)]
  integer(c_int64_t), parameter :: b25_abso3b_bits_1(16) = [ &
    int(z'3f921dc5e3a47fa7',c_int64_t), int(z'3fa7c42a66dbd72c',c_int64_t), int(z'3fba8826aa8eb463',c_int64_t), int(z'3fc840852b4d8ba4',c_int64_t), &
    int(z'3fd37268d32830a1',c_int64_t), int(z'3fd99da9c99285a9',c_int64_t), int(z'3fdca17f4128bf3c',c_int64_t), int(z'3fde14a0a0f4d7ae',c_int64_t), &
    int(z'3fdfea4228997c3d',c_int64_t), int(z'3fe08094e5d5b24f',c_int64_t), int(z'3fe08bb2bba98eda',c_int64_t), int(z'3fe092e1ef73c0c2',c_int64_t), &
    int(z'3fe0964840e1719f',c_int64_t), int(z'3fe0cc6822ff0889',c_int64_t), int(z'3fe04388ebcc6c55',c_int64_t), int(z'3fde03c8e25c810a',c_int64_t)]
  integer(c_int), parameter :: b25_layreffr_bits_1(1) = [ &
                               int(z'00000002', c_int)]
  integer(c_int64_t), parameter :: b26_sfluxref_bits_1(16) = [ &
    int(z'403d0205bc01a36e',c_int64_t), int(z'403c68a71de69ad4',c_int64_t), int(z'40344f559b3d07c8',c_int64_t), int(z'402a0e7d566cf41f',c_int64_t), &
    int(z'4027b94af4f0d845',c_int64_t), int(z'4023eab367a0f909',c_int64_t), int(z'401abf727136a401',c_int64_t), int(z'40158f3a14cec41e',c_int64_t), &
    int(z'400bfc7f77af6406',c_int64_t), int(z'3fda17a46173b85f',c_int64_t), int(z'3fd323422467be55',c_int64_t), int(z'3fce5058dde7a744',c_int64_t), &
    int(z'3fc820d5629d840a',c_int64_t), int(z'3fc4ed352220bc38',c_int64_t), int(z'3fa7c621b7e0ac7e',c_int64_t), int(z'3f665622f750d9e2',c_int64_t)]
  integer(c_int64_t), parameter :: b26_rayl_bits_1(16) = [ &
    int(z'3eb45834c902366a',c_int64_t), int(z'3eb8102f8998b823',c_int64_t), int(z'3ebc21ac1cb2f9f7',c_int64_t), int(z'3ec0361e991effb2',c_int64_t), &
    int(z'3ec262ca4cda4131',c_int64_t), int(z'3ec47c0c35b07585',c_int64_t), int(z'3ec66431342ad6fb',c_int64_t), int(z'3ec7fd96a6f288f9',c_int64_t), &
    int(z'3ec9329c83859060',c_int64_t), int(z'3ec9c0b05bc056b0',c_int64_t), int(z'3ec9da33751cec86',c_int64_t), int(z'3ec9ef6b0b7f78a6',c_int64_t), &
    int(z'3ec9ffde2ca8a2f4',c_int64_t), int(z'3eca0afde8d931dd',c_int64_t), int(z'3eca10cfbf711dbd',c_int64_t), int(z'3eca12c4068e6747',c_int64_t)]
  integer(c_int64_t), parameter :: b27_sfluxref_bits_1(16) = [ &
    int(z'402c1aee631f8a09',c_int64_t), int(z'4026f573eab367a1',c_int64_t), int(z'402173a92a305532',c_int64_t), int(z'40164754f3775b81',c_int64_t), &
    int(z'400e79628cbd1245',c_int64_t), int(z'3ff93afb7e90ff97',c_int64_t), int(z'3ff26a747d805e5f',c_int64_t), int(z'3ff19a176ddaceee',c_int64_t), &
    int(z'3fe510129cbab64a',c_int64_t), int(z'3fae0c140a78ffc6',c_int64_t), int(z'3fac7a0a88193e95',c_int64_t), int(z'3fa7f6b1a2a4db16',c_int64_t), &
    int(z'3fa2aec728481da6',c_int64_t), int(z'3fa25512810c041a',c_int64_t), int(z'3f8c49fd7a13c255',c_int64_t), int(z'3f5f2945c98dd312',c_int64_t)]
  integer(c_int64_t), parameter :: b27_rayl_bits_1(16) = [ &
    int(z'3ecce6cfb221513c',c_int64_t), int(z'3ed16271f2de19d6',c_int64_t), int(z'3ed4c3c34e1ce849',c_int64_t), int(z'3ed860a163e90cb7',c_int64_t), &
    int(z'3edc175d48c14910',c_int64_t), int(z'3edfbaba617468fa',c_int64_t), int(z'3ee18a1670e7122d',c_int64_t), int(z'3ee2f609ae95da3b',c_int64_t), &
    int(z'3ee418f679fa010a',c_int64_t), int(z'3ee4959d0d7cf847',c_int64_t), int(z'3ee473215944d67b',c_int64_t), int(z'3ee46ffbf4d9347d',c_int64_t), &
    int(z'3ee46dde726c2430',c_int64_t), int(z'3ee46a929260b79d',c_int64_t), int(z'3ee46ada0a405468',c_int64_t), int(z'3ee46b1263d8062f',c_int64_t)]
  integer(c_int64_t), parameter :: b27_scalekur_bits_1(1) = [ &
                                   int(z'3ff096bb3ffc9cdf', c_int64_t)]
  integer(c_int), parameter :: b27_layreffr_bits_1(1) = [ &
                               int(z'00000020', c_int)]
  integer(c_int64_t), parameter :: b28_sfluxref_bits_1(80) = [ &
    int(z'3ff0fc2656abde40',c_int64_t), int(z'3fe3327674d16335',c_int64_t), int(z'3fdb099e0e73604a',c_int64_t), int(z'3fd99adc8fb86f48',c_int64_t), &
    int(z'3fd20fe8ab4fa483',c_int64_t), int(z'3fc80ce0b912dba5',c_int64_t), int(z'3fb1572078458bfb',c_int64_t), int(z'3f9f302c17b5ff2b',c_int64_t), &
    int(z'3f9486777de5deed',c_int64_t), int(z'3f62e7eee728ee8c',c_int64_t), int(z'3f611b5b5032c854',c_int64_t), int(z'3f575d3eca6b1db0',c_int64_t), &
    int(z'3f4fb30152432170',c_int64_t), int(z'3f44d1cd816c6afc',c_int64_t), int(z'3f235ce5447911f6',c_int64_t), int(z'3edcd777b0c69de8',c_int64_t), &
    int(z'3ff13736cdf266ba',c_int64_t), int(z'3fe2b92189bd8384',c_int64_t), int(z'3fdb1001d5c31594',c_int64_t), int(z'3fd99adc8fb86f48',c_int64_t), &
    int(z'3fd20fe8ab4fa483',c_int64_t), int(z'3fc80ce0b912dba5',c_int64_t), int(z'3fb124daaadbe13d',c_int64_t), int(z'3f9fa615a8deb0fb',c_int64_t), &
    int(z'3f94b9cb6848beb6',c_int64_t), int(z'3f644be75f1f4a48',c_int64_t), int(z'3f5f087920525aec',c_int64_t), int(z'3f571f15efd6672a',c_int64_t), &
    int(z'3f526c73f1945765',c_int64_t), int(z'3f42cae89c0b38ee',c_int64_t), int(z'3f2ac2790bda7ebc',c_int64_t), int(z'3ef09b3d399aa119',c_int64_t), &
    int(z'3fdd8b9fdbd2fa0d',c_int64_t), int(z'3fd9fdc1615ebfa9',c_int64_t), int(z'3fd547c73eee5259',c_int64_t), int(z'3fd3ae3608d0891a',c_int64_t), &
    int(z'3fcb07852f7f498c',c_int64_t), int(z'3fce2374794ea077',c_int64_t), int(z'3fdfbc98a222d517',c_int64_t), int(z'3fd74a7b4e54f7a9',c_int64_t), &
    int(z'3fc8aa64c2f837b5',c_int64_t), int(z'3f94f582ce7bf976',c_int64_t), int(z'3f8fd3cd720e3a55',c_int64_t), int(z'3f8546689a1d4d18',c_int64_t), &
    int(z'3f86aff525b16a71',c_int64_t), int(z'3f84954dda7e6637',c_int64_t), int(z'3f7436b0ec1b9c94',c_int64_t), int(z'3f42ca1c993dd421',c_int64_t), &
    int(z'3fc0fb4c3c18b503',c_int64_t), int(z'3fc6684cf0739b02',c_int64_t), int(z'3fd6fe2a3cea6c1a',c_int64_t), int(z'3fd8d7518b0d0edc',c_int64_t), &
    int(z'3fd66c4827b6fe2e',c_int64_t), int(z'3fde7503b81b64e0',c_int64_t), int(z'3fdf557de0d66f0d',c_int64_t), int(z'3fda23d4f15e7c8d',c_int64_t), &
    int(z'3fcc4b5568e820e6',c_int64_t), int(z'3f93eb115b72169e',c_int64_t), int(z'3f8fb67eacae4954',c_int64_t), int(z'3f8db21fa25cb6ba',c_int64_t), &
    int(z'3f8d9b86d9a374e5',c_int64_t), int(z'3f8496828de459b1',c_int64_t), int(z'3f744fdb5f8cad78',c_int64_t), int(z'3f42c96a5b824b8e',c_int64_t), &
    int(z'3fb352a843808851',c_int64_t), int(z'3fcdba3ca7503b82',c_int64_t), int(z'3fd6fe2a3cea6c1a',c_int64_t), int(z'3fd8d7518b0d0edc',c_int64_t), &
    int(z'3fd66c4827b6fe2e',c_int64_t), int(z'3fdb48c7192ea52f',c_int64_t), int(z'3fdf95421c044285',c_int64_t), int(z'3fdba6266fd651b1',c_int64_t), &
    int(z'3fce9e34330d7386',c_int64_t), int(z'3f91ea3c495c6a64',c_int64_t), int(z'3f91ddcf538fca0d',c_int64_t), int(z'3f92cc1292a9bb50',c_int64_t), &
    int(z'3f8da8a24b190306',c_int64_t), int(z'3f84b1d34c42ceb2',c_int64_t), int(z'3f7460877f3ac8a9',c_int64_t), int(z'3f4292ec4dbdf05d',c_int64_t)]
  integer(c_int64_t), parameter :: b28_rayl_bits_1(1) = [ &
                                   int(z'3ef52e656e18e24f', c_int64_t)]
  integer(c_int64_t), parameter :: b28_strrat_bits_1(1) = [ &
                                   int(z'3ea661bc487b0cd1', c_int64_t)]
  integer(c_int), parameter :: b28_layreffr_bits_1(1) = [ &
                               int(z'0000003a', c_int)]
  integer(c_int64_t), parameter :: b29_selfref_bits_1(128) = [ &
    int(z'3fbe39c51dabe271',c_int64_t), int(z'3fb24424f2fe8fbd',c_int64_t), int(z'3fa613cfc09d13a2',c_int64_t), int(z'3f9aaf0d9f24f3d5',c_int64_t), &
    int(z'3f90202a41f2e997',c_int64_t), int(z'3f837d84901d1915',c_int64_t), int(z'3f778e94adcc8178',c_int64_t), int(z'3f6c78dc8aaff1cb',c_int64_t), &
    int(z'3f6134d64b7ba96f',c_int64_t), int(z'3f54cbe9f8d797ac',c_int64_t), int(z'3f8c12fe0985bac0',c_int64_t), int(z'3f8c7a03d21c97e6',c_int64_t), &
    int(z'3f8ce28ed5f138bd',c_int64_t), int(z'3f8d4c843d110287',c_int64_t), int(z'3f8db80c4b67dd5f',c_int64_t), int(z'3f8e252700f5c945',c_int64_t), &
    int(z'3f8e93c6f1c178dc',c_int64_t), int(z'3f8f03f989c43980',c_int64_t), int(z'3f8f75cc34f75892',c_int64_t), int(z'3f8fe93ef35ad60f',c_int64_t), &
    int(z'3f910ea9e6eeb702',c_int64_t), int(z'3f90e32c8aa285d1',c_int64_t), int(z'3f90b81a8e20bf93',c_int64_t), int(z'3f908d7aa7660af7',c_int64_t), &
    int(z'3f9063462075c14d',c_int64_t), int(z'3f90397cf94fe296',c_int64_t), int(z'3f9010187bf7c823',c_int64_t), int(z'3f8fce4c28cd7ea3',c_int64_t), &
    int(z'3f8f7d30ad46f588',c_int64_t), int(z'3f8f2cebf1554252',c_int64_t), int(z'3fae95f74da9d6fe',c_int64_t), int(z'3faa16575a59e8aa',c_int64_t), &
    int(z'3fa6401d26817409',c_int64_t), int(z'3fa2fa574992f109',c_int64_t), int(z'3fa02fc69728a611',c_int64_t), int(z'3f9b9ca26295f74e',c_int64_t), &
    int(z'3f978cff57639424',c_int64_t), int(z'3f941644e5e31e48',c_int64_t), int(z'3f9121f51d4deea0',c_int64_t), int(z'3f8d39bf3e6ed098',c_int64_t), &
    int(z'3fcd1f46ed245b29',c_int64_t), int(z'3fc96534373f316e',c_int64_t), int(z'3fc62539756c93a7',c_int64_t), int(z'3fc34fb549f94856',c_int64_t), &
    int(z'3fc0d70e6f2e8c05',c_int64_t), int(z'3fbd5eaee2003ab8',c_int64_t), int(z'3fb99c7bcc2938de',c_int64_t), int(z'3fb655757d5a9eb2',c_int64_t), &
    int(z'3fb379c6957b26e8',c_int64_t), int(z'3fb0fbbaf6e1734d',c_int64_t), int(z'3fdd01cd5f99c38b',c_int64_t), int(z'3fda8cdea033e78e',c_int64_t), &
    int(z'3fd84d338f798527',c_int64_t), int(z'3fd63e4abe6a337b',c_int64_t), int(z'3fd45c03361565c3',c_int64_t), int(z'3fd2a294141e9af6',c_int64_t), &
    int(z'3fd10e8858ff7597',c_int64_t), int(z'3fcf396d0917d6b6',c_int64_t), int(z'3fcc946801711948',c_int64_t), int(z'3fca28bb0a2ca9ac',c_int64_t), &
    int(z'3fe2376709fa54c5',c_int64_t), int(z'3fe08678c0053e2d',c_int64_t), int(z'3fddfb762d83c6c9',c_int64_t), int(z'3fdb32e7b3d8e001',c_int64_t), &
    int(z'3fd8ac7da1ec4e72',c_int64_t), int(z'3fd662174c4cdfad',c_int64_t), int(z'3fd44e22a2c23748',c_int64_t), int(z'3fd26b8f9b13165d',c_int64_t), &
    int(z'3fd0b5c7cd898b2f',c_int64_t), int(z'3fce514c22ee4192',c_int64_t), int(z'3fdf614df8b15726',c_int64_t), int(z'3fdcacb85a4f00ef',c_int64_t), &
    int(z'3fda33d29563a9f4',c_int64_t), int(z'3fd7f1843c3a42f2',c_int64_t), int(z'3fd5e10cf5b1c865',c_int64_t), int(z'3fd3fe260b2c83ed',c_int64_t), &
    int(z'3fd244e50c5eb314',c_int64_t), int(z'3fd0b1ab0856e697',c_int64_t), int(z'3fce826aa8eb4635',c_int64_t), int(z'3fcbe108c3f3e037',c_int64_t), &
    int(z'3fd085b9e8c47a18',c_int64_t), int(z'3fd0f727136a4010',c_int64_t), int(z'3fd16b9c304ccee6',c_int64_t), int(z'3fd1e3369b9d7fd8',c_int64_t), &
    int(z'3fd25e02ea960b70',c_int64_t), int(z'3fd2dc1a47a9e2bd',c_int64_t), int(z'3fd35d91ab8e8ea4',c_int64_t), int(z'3fd3e28672756862',c_int64_t), &
    int(z'3fd46b09635610ae',c_int64_t), int(z'3fd4f733a8a3f898',c_int64_t), int(z'3fd53fcc9ea9a3d3',c_int64_t), int(z'3fd53de1e2de8709',c_int64_t), &
    int(z'3fd53bf2f5558213',c_int64_t), int(z'3fd53a0407cc7d1c',c_int64_t), int(z'3fd538194c016052',c_int64_t), int(z'3fd5362a5e785b5b',c_int64_t), &
    int(z'3fd5343fa2ad3e92',c_int64_t), int(z'3fd53254e6e221c9',c_int64_t), int(z'3fd53065f9591cd2',c_int64_t), int(z'3fd52e7b3d8e0008',c_int64_t), &
    int(z'3fd6e1a8262456f7',c_int64_t), int(z'3fd69a133c1ce6c1',c_int64_t), int(z'3fd65360d0247022',c_int64_t), int(z'3fd60d887ebf22c0',c_int64_t), &
    int(z'3fd5c88e79aae6c9',c_int64_t), int(z'3fd5846a5d6bebe1',c_int64_t), int(z'3fd5411c2a023209',c_int64_t), int(z'3fd4fe9fadafd114',c_int64_t), &
    int(z'3fd4bcf0b6b6e0d2',c_int64_t), int(z'3fd47c1376d54973',c_int64_t), int(z'3fd2dbbe0157eed4',c_int64_t), int(z'3fd323854046412d',c_int64_t), &
    int(z'3fd36c58eeae9ee4',c_int64_t), int(z'3fd3b645a1cac083',c_int64_t), int(z'3fd4014b599aa609',c_int64_t), int(z'3fd44d6e47dc37a4',c_int64_t), &
    int(z'3fd49aae6c8f7553',c_int64_t), int(z'3fd4e9185cee17a0',c_int64_t), int(z'3fd538b04ab606b8',c_int64_t), int(z'3fd5897204295a6c',c_int64_t), &
    int(z'3fcd1ceaf251c194',c_int64_t), int(z'3fceeaf251c193b4',c_int64_t), int(z'3fd06aceaaf35e31',c_int64_t), int(z'3fd16f5caf2d7f95',c_int64_t), &
    int(z'3fd2841248d7e026',c_int64_t), int(z'3fd3a9ef5232d2bb',c_int64_t), int(z'3fd4e2003ab862b2',c_int64_t), int(z'3fd62d6ece13f4aa',c_int64_t)]
  integer(c_int64_t), parameter :: b29_selfref_bits_2(32) = [ &
    int(z'3fd78d64d7f0ed3e',c_int64_t), int(z'3fd90331e3a7daa5',c_int64_t), int(z'3f793d5b553b45d1',c_int64_t), int(z'3f873fdfe9e0030a',c_int64_t), &
    int(z'3f956a95a00fd560',c_int64_t), int(z'3fa3ba4bc0c8b28c',c_int64_t), int(z'3fb22c1608800142',c_int64_t), int(z'3fc0bd44998d0460',c_int64_t), &
    int(z'3fced6c2efd438d2',c_int64_t), int(z'3fdc6848beb5b2d5',c_int64_t), int(z'3fea2ade657b84dc',c_int64_t), int(z'3ff81aaa3ad18d26',c_int64_t), &
    int(z'3f32521ab2916ad5',c_int64_t), int(z'3f4a7df4665d9bd6',c_int64_t), int(z'3f6327649de45702',c_int64_t), int(z'3f7bb2631421751b',c_int64_t), &
    int(z'3f940668cfcd324d',c_int64_t), int(z'3facf4d7add15f03',c_int64_t), int(z'3fc4ef88b9778573',c_int64_t), int(z'3fde45f5ad96a6a0',c_int64_t), &
    int(z'3ff5e3497b7414a5',c_int64_t), int(z'400fa66ba493c89f',c_int64_t), int(z'3f311af43beb576b',c_int64_t), int(z'3f4943fa3c01f509',c_int64_t), &
    int(z'3f62a8cf16a90ed8',c_int64_t), int(z'3f7b8fa5cfddce52',c_int64_t), int(z'3f945ad1ddadc5a1',c_int64_t), int(z'3fae10b48329eb8c',c_int64_t), &
    int(z'3fc63443d46b26c0',c_int64_t), int(z'3fe06601bc98a223',c_int64_t), int(z'3ff838bac710cb29',c_int64_t), int(z'4011e36b8f9b1316',c_int64_t)]
  integer(c_int64_t), parameter :: b29_forref_bits_1(64) = [ &
    int(z'3ec9268ae2d65140',c_int64_t), int(z'3ec18e4bf6613a69',c_int64_t), int(z'3f19e8b98656c347',c_int64_t), int(z'3f44b717eae97e9a',c_int64_t), &
    int(z'3eda93be5c1b5cc6',c_int64_t), int(z'3f0ab28dfb38978c',c_int64_t), int(z'3f45511546633bba',c_int64_t), int(z'3f65a0e13691369f',c_int64_t), &
    int(z'3f10b15f2557e7ee',c_int64_t), int(z'3f21e6c37f2c6c2b',c_int64_t), int(z'3f5b4784230fcf81',c_int64_t), int(z'3f7ec0edc66c8b6f',c_int64_t), &
    int(z'3f3ef41d2ef61de5',c_int64_t), int(z'3f503136bfebcf02',c_int64_t), int(z'3f77fe0b5e2d06f4',c_int64_t), int(z'3f932f51fd22d5ee',c_int64_t), &
    int(z'3f76e1b668dd392c',c_int64_t), int(z'3f818a78138cfaa5',c_int64_t), int(z'3f901f24887584e7',c_int64_t), int(z'3f9295274411a7c8',c_int64_t), &
    int(z'3f9642e126202539',c_int64_t), int(z'3f97772fe245dad6',c_int64_t), int(z'3f979096bb98c7e3',c_int64_t), int(z'3f8d745cc92eb29b',c_int64_t), &
    int(z'3f9c6335597e2097',c_int64_t), int(z'3f9ea4b62d4e16e4',c_int64_t), int(z'3f9564f2c8dfd842',c_int64_t), int(z'3f80ee8a61c33e84',c_int64_t), &
    int(z'3f99d125f7e14d8d',c_int64_t), int(z'3f9aec0ddab4161d',c_int64_t), int(z'3f933779131154bc',c_int64_t), int(z'3f7115b72169dd13',c_int64_t), &
    int(z'3f9f39d868e241a9',c_int64_t), int(z'3f91f9ce8d972cd8',c_int64_t), int(z'3f83e402c95e026a',c_int64_t), int(z'3f5744e059c77199',c_int64_t), &
    int(z'3fa0c0ad03d9a954',c_int64_t), int(z'3f9618c0c125cf9d',c_int64_t), int(z'3f6c6992c0b76abb',c_int64_t), int(z'3f59e289f866d97e',c_int64_t), &
    int(z'3fa0a3400b88ca3e',c_int64_t), int(z'3f9767da03ecf48b',c_int64_t), int(z'3f5c23acd865b236',c_int64_t), int(z'3f629573c51ead95',c_int64_t), &
    int(z'3fa0b8a77bda6bf2',c_int64_t), int(z'3f9454b63aba1032',c_int64_t), int(z'3ea1dcc1d7411cf0',c_int64_t), int(z'3f66dcdb8dafd672',c_int64_t), &
    int(z'3fa1ac0ab565a7fb',c_int64_t), int(z'3f9145d19b68a6b3',c_int64_t), int(z'3ea0f504976933de',c_int64_t), int(z'3f66a9b5459c9750',c_int64_t), &
    int(z'3fa6fa0d77b7c782',c_int64_t), int(z'3f54482bbdc8f8d8',c_int64_t), int(z'3ea0630a63e70aa0',c_int64_t), int(z'3f540753b157fc40',c_int64_t), &
    int(z'3fa8ee392e1ef73c',c_int64_t), int(z'3e9f29d541a3f250',c_int64_t), int(z'3e9f279982a70bfc',c_int64_t), int(z'3ea94b7ce2963b4d',c_int64_t), &
    int(z'3fab298387089d5d',c_int64_t), int(z'3e993fa6a18d1028',c_int64_t), int(z'3e9b80b9036bffc6',c_int64_t), int(z'3e9f95b49727cd9a',c_int64_t)]
  integer(c_int64_t), parameter :: b29_sfluxref_bits_1(16) = [ &
    int(z'3ff542c3c9eecbfb',c_int64_t), int(z'40011f16b11c6d1e',c_int64_t), int(z'3fff9e30014f8b59',c_int64_t), int(z'3ffca3d70a3d70a4',c_int64_t), &
    int(z'3ff832df505d0fa6',c_int64_t), int(z'3ff3ad234eb9a177',c_int64_t), int(z'3ff0f7e3d1cc100e',c_int64_t), int(z'3fe9a1c25d074214',c_int64_t), &
    int(z'3fe7f00cd855970b',c_int64_t), int(z'3fb620ba8aaae94d',c_int64_t), int(z'3fb2317acc4ef88c',c_int64_t), int(z'3faccbd1244a6224',c_int64_t), &
    int(z'3fa6e2c2d857448a',c_int64_t), int(z'3f9f7b61a02e0851',c_int64_t), int(z'3f87e7e8b205a12a',c_int64_t), int(z'3f5b20a28cdd489b',c_int64_t)]
  integer(c_int64_t), parameter :: b29_absh2o_bits_1(16) = [ &
    int(z'3f33a0e9109ca7b8',c_int64_t), int(z'3f702e004371c4be',c_int64_t), int(z'3f8e94756d6a66a6',c_int64_t), int(z'3fa09bc41644e5e3',c_int64_t), &
    int(z'3fb1bcda10822e43',c_int64_t), int(z'3fbf9f340d4dc65c',c_int64_t), int(z'3fd71a60d4562e0a',c_int64_t), int(z'3ffdd4562e09fe87',c_int64_t), &
    int(z'4024c35d249e44fa',c_int64_t), int(z'3fcb68943e100608',c_int64_t), int(z'3fcb6188b11409a2',c_int64_t), int(z'3fcb3c68661ae70c',c_int64_t), &
    int(z'3fcb97891e215337',c_int64_t), int(z'3fcbea465a57646b',c_int64_t), int(z'3fcc470a808c825a',c_int64_t), int(z'3fcbf950b955f783',c_int64_t)]
  integer(c_int64_t), parameter :: b29_absco2_bits_1(16) = [ &
    int(z'3ec855452e98d1c1',c_int64_t), int(z'3ef64515fda60523',c_int64_t), int(z'3f1b025c4821cf2a',c_int64_t), int(z'3f28714397b7f5ae',c_int64_t), &
    int(z'3f3c4fb4fcaa12c1',c_int64_t), int(z'3f43ee4528ba449b',c_int64_t), int(z'3f61d37735ec760a',c_int64_t), int(z'3fa7c804e6ef8dc2',c_int64_t), &
    int(z'4007c1a8ac5c13fd',c_int64_t), int(z'402de9eecbfb15b5',c_int64_t), int(z'403c7bac710cb296',c_int64_t), int(z'404eb32ca57a786c',c_int64_t), &
    int(z'40648420c49ba5e3',c_int64_t), int(z'408a024189374bc7',c_int64_t), int(z'40b383051eb851ec',c_int64_t), int(z'40c8c30ccccccccd',c_int64_t)]
  integer(c_int64_t), parameter :: b29_rayl_bits_1(1) = [ &
                                   int(z'3dd9904b0fb6b821', c_int64_t)]
  integer(c_int), parameter :: b29_layreffr_bits_1(1) = [ &
                               int(z'00000031', c_int)]
contains
  function decode_shortwave_absorption_inputs(bytes, output) result(status)
    !! Input is the exact big-endian coefficient file; output preserves undeclared stores.
    integer(c_int8_t), intent(in) :: bytes(:)
    type(shortwave_absorption_record), intent(inout) :: output
    integer(c_int) :: status
    status = 2_c_int
    if (size(bytes) /= 1332584) return
    if (network_word32(bytes, 1) /= 104960_c_int64_t) return
    if (network_word32(bytes, 104965) /= 104960_c_int64_t) return
    if (network_word32(bytes, 104969) /= 225280_c_int64_t) return
    if (network_word32(bytes, 330253) /= 225280_c_int64_t) return
    if (network_word32(bytes, 330257) /= 104960_c_int64_t) return
    if (network_word32(bytes, 435221) /= 104960_c_int64_t) return
    if (network_word32(bytes, 435225) /= 104960_c_int64_t) return
    if (network_word32(bytes, 540189) /= 104960_c_int64_t) return
    if (network_word32(bytes, 540193) /= 38400_c_int64_t) return
    if (network_word32(bytes, 578597) /= 38400_c_int64_t) return
    if (network_word32(bytes, 578601) /= 225280_c_int64_t) return
    if (network_word32(bytes, 803885) /= 225280_c_int64_t) return
    if (network_word32(bytes, 803889) /= 104960_c_int64_t) return
    if (network_word32(bytes, 908853) /= 104960_c_int64_t) return
    if (network_word32(bytes, 908857) /= 8320_c_int64_t) return
    if (network_word32(bytes, 917181) /= 8320_c_int64_t) return
    if (network_word32(bytes, 917185) /= 104960_c_int64_t) return
    if (network_word32(bytes, 1022149) /= 104960_c_int64_t) return
    if (network_word32(bytes, 1022153) /= 8320_c_int64_t) return
    if (network_word32(bytes, 1030477) /= 8320_c_int64_t) return
    if (network_word32(bytes, 1030481) /= 38400_c_int64_t) return
    if (network_word32(bytes, 1068885) /= 38400_c_int64_t) return
    if (network_word32(bytes, 1068889) /= 225280_c_int64_t) return
    if (network_word32(bytes, 1294173) /= 225280_c_int64_t) return
    if (network_word32(bytes, 1294177) /= 38400_c_int64_t) return
    if (network_word32(bytes, 1332581) /= 38400_c_int64_t) return
    output%ng = reshape([ng_bits_1], [14])
    output%nspa = reshape([nspa_bits_1], [14])
    output%nspb = reshape([nspb_bits_1], [14])
    output%nmpsrtm = reshape([nmpsrtm_bits_1], [14])
    output%pref = reshape(transfer([pref_bits_1], [0.0_c_double], 59), [59])
    output%preflog = reshape(transfer([preflog_bits_1], [0.0_c_double], 59), [59])
    output%tref = reshape(transfer([tref_bits_1], [0.0_c_double], 59), [59])
    output%ngm = reshape([ngm_bits_1, ngm_bits_2], [224])
    output%ngc = reshape([ngc_bits_1], [14])
    output%ngs = reshape([ngs_bits_1], [14])
    output%wt = reshape(transfer([wt_bits_1], [0.0_c_double], 16), [16])
    output%ngn(1) = int(z'00000002', c_int)
    output%ngn(2) = int(z'00000002', c_int)
    output%ngn(3) = int(z'00000002', c_int)
    output%ngn(4) = int(z'00000002', c_int)
    output%ngn(5) = int(z'00000004', c_int)
    output%ngn(6) = int(z'00000004', c_int)
    output%ngn(7) = int(z'00000001', c_int)
    output%ngn(8) = int(z'00000001', c_int)
    output%ngn(9) = int(z'00000001', c_int)
    output%ngn(10) = int(z'00000001', c_int)
    output%ngn(11) = int(z'00000001', c_int)
    output%ngn(12) = int(z'00000002', c_int)
    output%ngn(13) = int(z'00000001', c_int)
    output%ngn(14) = int(z'00000002', c_int)
    output%ngn(15) = int(z'00000001', c_int)
    output%ngn(16) = int(z'00000002', c_int)
    output%ngn(17) = int(z'00000001', c_int)
    output%ngn(18) = int(z'00000002', c_int)
    output%ngn(19) = int(z'00000001', c_int)
    output%ngn(20) = int(z'00000001', c_int)
    output%ngn(21) = int(z'00000001', c_int)
    output%ngn(22) = int(z'00000001', c_int)
    output%ngn(23) = int(z'00000002', c_int)
    output%ngn(24) = int(z'00000002', c_int)
    output%ngn(25) = int(z'00000004', c_int)
    output%ngn(26) = int(z'00000004', c_int)
    output%ngn(27) = int(z'00000001', c_int)
    output%ngn(28) = int(z'00000001', c_int)
    output%ngn(29) = int(z'00000001', c_int)
    output%ngn(30) = int(z'00000001', c_int)
    output%ngn(31) = int(z'00000002', c_int)
    output%ngn(32) = int(z'00000002', c_int)
    output%ngn(33) = int(z'00000004', c_int)
    output%ngn(34) = int(z'00000004', c_int)
    output%ngn(35) = int(z'00000001', c_int)
    output%ngn(36) = int(z'00000001', c_int)
    output%ngn(37) = int(z'00000001', c_int)
    output%ngn(38) = int(z'00000001', c_int)
    output%ngn(39) = int(z'00000001', c_int)
    output%ngn(40) = int(z'00000001', c_int)
    output%ngn(41) = int(z'00000001', c_int)
    output%ngn(42) = int(z'00000001', c_int)
    output%ngn(43) = int(z'00000002', c_int)
    output%ngn(44) = int(z'00000006', c_int)
    output%ngn(45) = int(z'00000001', c_int)
    output%ngn(46) = int(z'00000001', c_int)
    output%ngn(47) = int(z'00000001', c_int)
    output%ngn(48) = int(z'00000001', c_int)
    output%ngn(49) = int(z'00000001', c_int)
    output%ngn(50) = int(z'00000001', c_int)
    output%ngn(51) = int(z'00000001', c_int)
    output%ngn(52) = int(z'00000001', c_int)
    output%ngn(53) = int(z'00000002', c_int)
    output%ngn(54) = int(z'00000006', c_int)
    output%ngn(55) = int(z'00000008', c_int)
    output%ngn(56) = int(z'00000008', c_int)
    output%ngn(57) = int(z'00000002', c_int)
    output%ngn(58) = int(z'00000002', c_int)
    output%ngn(59) = int(z'00000001', c_int)
    output%ngn(60) = int(z'00000001', c_int)
    output%ngn(61) = int(z'00000001', c_int)
    output%ngn(62) = int(z'00000001', c_int)
    output%ngn(63) = int(z'00000001', c_int)
    output%ngn(64) = int(z'00000001', c_int)
    output%ngn(65) = int(z'00000002', c_int)
    output%ngn(66) = int(z'00000004', c_int)
    output%ngn(67) = int(z'00000002', c_int)
    output%ngn(68) = int(z'00000002', c_int)
    output%ngn(69) = int(z'00000002', c_int)
    output%ngn(70) = int(z'00000002', c_int)
    output%ngn(71) = int(z'00000002', c_int)
    output%ngn(72) = int(z'00000002', c_int)
    output%ngn(73) = int(z'00000002', c_int)
    output%ngn(74) = int(z'00000002', c_int)
    output%ngn(75) = int(z'00000001', c_int)
    output%ngn(76) = int(z'00000001', c_int)
    output%ngn(77) = int(z'00000002', c_int)
    output%ngn(78) = int(z'00000002', c_int)
    output%ngn(79) = int(z'00000004', c_int)
    output%ngn(80) = int(z'00000006', c_int)
    output%ngn(81) = int(z'00000001', c_int)
    output%ngn(82) = int(z'00000001', c_int)
    output%ngn(83) = int(z'00000002', c_int)
    output%ngn(84) = int(z'00000002', c_int)
    output%ngn(85) = int(z'00000004', c_int)
    output%ngn(86) = int(z'00000006', c_int)
    output%ngn(87) = int(z'00000001', c_int)
    output%ngn(88) = int(z'00000001', c_int)
    output%ngn(89) = int(z'00000001', c_int)
    output%ngn(90) = int(z'00000001', c_int)
    output%ngn(91) = int(z'00000001', c_int)
    output%ngn(92) = int(z'00000001', c_int)
    output%ngn(93) = int(z'00000004', c_int)
    output%ngn(94) = int(z'00000006', c_int)
    output%ngn(95) = int(z'00000001', c_int)
    output%ngn(96) = int(z'00000001', c_int)
    output%ngn(97) = int(z'00000002', c_int)
    output%ngn(98) = int(z'00000002', c_int)
    output%ngn(99) = int(z'00000004', c_int)
    output%ngn(100) = int(z'00000006', c_int)
    output%ngn(101) = int(z'00000001', c_int)
    output%ngn(102) = int(z'00000001', c_int)
    output%ngn(103) = int(z'00000001', c_int)
    output%ngn(104) = int(z'00000001', c_int)
    output%ngn(105) = int(z'00000002', c_int)
    output%ngn(106) = int(z'00000002', c_int)
    output%ngn(107) = int(z'00000002', c_int)
    output%ngn(108) = int(z'00000002', c_int)
    output%ngn(109) = int(z'00000001', c_int)
    output%ngn(110) = int(z'00000001', c_int)
    output%ngn(111) = int(z'00000001', c_int)
    output%ngn(112) = int(z'00000001', c_int)
    output%ngbsw(1) = int(z'00000010', c_int)
    output%ngbsw(2) = int(z'00000010', c_int)
    output%ngbsw(3) = int(z'00000010', c_int)
    output%ngbsw(4) = int(z'00000010', c_int)
    output%ngbsw(5) = int(z'00000010', c_int)
    output%ngbsw(6) = int(z'00000010', c_int)
    output%ngbsw(7) = int(z'00000011', c_int)
    output%ngbsw(8) = int(z'00000011', c_int)
    output%ngbsw(9) = int(z'00000011', c_int)
    output%ngbsw(10) = int(z'00000011', c_int)
    output%ngbsw(11) = int(z'00000011', c_int)
    output%ngbsw(12) = int(z'00000011', c_int)
    output%ngbsw(13) = int(z'00000011', c_int)
    output%ngbsw(14) = int(z'00000011', c_int)
    output%ngbsw(15) = int(z'00000011', c_int)
    output%ngbsw(16) = int(z'00000011', c_int)
    output%ngbsw(17) = int(z'00000011', c_int)
    output%ngbsw(18) = int(z'00000011', c_int)
    output%ngbsw(19) = int(z'00000012', c_int)
    output%ngbsw(20) = int(z'00000012', c_int)
    output%ngbsw(21) = int(z'00000012', c_int)
    output%ngbsw(22) = int(z'00000012', c_int)
    output%ngbsw(23) = int(z'00000012', c_int)
    output%ngbsw(24) = int(z'00000012', c_int)
    output%ngbsw(25) = int(z'00000012', c_int)
    output%ngbsw(26) = int(z'00000012', c_int)
    output%ngbsw(27) = int(z'00000013', c_int)
    output%ngbsw(28) = int(z'00000013', c_int)
    output%ngbsw(29) = int(z'00000013', c_int)
    output%ngbsw(30) = int(z'00000013', c_int)
    output%ngbsw(31) = int(z'00000013', c_int)
    output%ngbsw(32) = int(z'00000013', c_int)
    output%ngbsw(33) = int(z'00000013', c_int)
    output%ngbsw(34) = int(z'00000013', c_int)
    output%ngbsw(35) = int(z'00000014', c_int)
    output%ngbsw(36) = int(z'00000014', c_int)
    output%ngbsw(37) = int(z'00000014', c_int)
    output%ngbsw(38) = int(z'00000014', c_int)
    output%ngbsw(39) = int(z'00000014', c_int)
    output%ngbsw(40) = int(z'00000014', c_int)
    output%ngbsw(41) = int(z'00000014', c_int)
    output%ngbsw(42) = int(z'00000014', c_int)
    output%ngbsw(43) = int(z'00000014', c_int)
    output%ngbsw(44) = int(z'00000014', c_int)
    output%ngbsw(45) = int(z'00000015', c_int)
    output%ngbsw(46) = int(z'00000015', c_int)
    output%ngbsw(47) = int(z'00000015', c_int)
    output%ngbsw(48) = int(z'00000015', c_int)
    output%ngbsw(49) = int(z'00000015', c_int)
    output%ngbsw(50) = int(z'00000015', c_int)
    output%ngbsw(51) = int(z'00000015', c_int)
    output%ngbsw(52) = int(z'00000015', c_int)
    output%ngbsw(53) = int(z'00000015', c_int)
    output%ngbsw(54) = int(z'00000015', c_int)
    output%ngbsw(55) = int(z'00000016', c_int)
    output%ngbsw(56) = int(z'00000016', c_int)
    output%ngbsw(57) = int(z'00000017', c_int)
    output%ngbsw(58) = int(z'00000017', c_int)
    output%ngbsw(59) = int(z'00000017', c_int)
    output%ngbsw(60) = int(z'00000017', c_int)
    output%ngbsw(61) = int(z'00000017', c_int)
    output%ngbsw(62) = int(z'00000017', c_int)
    output%ngbsw(63) = int(z'00000017', c_int)
    output%ngbsw(64) = int(z'00000017', c_int)
    output%ngbsw(65) = int(z'00000017', c_int)
    output%ngbsw(66) = int(z'00000017', c_int)
    output%ngbsw(67) = int(z'00000018', c_int)
    output%ngbsw(68) = int(z'00000018', c_int)
    output%ngbsw(69) = int(z'00000018', c_int)
    output%ngbsw(70) = int(z'00000018', c_int)
    output%ngbsw(71) = int(z'00000018', c_int)
    output%ngbsw(72) = int(z'00000018', c_int)
    output%ngbsw(73) = int(z'00000018', c_int)
    output%ngbsw(74) = int(z'00000018', c_int)
    output%ngbsw(75) = int(z'00000019', c_int)
    output%ngbsw(76) = int(z'00000019', c_int)
    output%ngbsw(77) = int(z'00000019', c_int)
    output%ngbsw(78) = int(z'00000019', c_int)
    output%ngbsw(79) = int(z'00000019', c_int)
    output%ngbsw(80) = int(z'00000019', c_int)
    output%ngbsw(81) = int(z'0000001a', c_int)
    output%ngbsw(82) = int(z'0000001a', c_int)
    output%ngbsw(83) = int(z'0000001a', c_int)
    output%ngbsw(84) = int(z'0000001a', c_int)
    output%ngbsw(85) = int(z'0000001a', c_int)
    output%ngbsw(86) = int(z'0000001a', c_int)
    output%ngbsw(87) = int(z'0000001b', c_int)
    output%ngbsw(88) = int(z'0000001b', c_int)
    output%ngbsw(89) = int(z'0000001b', c_int)
    output%ngbsw(90) = int(z'0000001b', c_int)
    output%ngbsw(91) = int(z'0000001b', c_int)
    output%ngbsw(92) = int(z'0000001b', c_int)
    output%ngbsw(93) = int(z'0000001b', c_int)
    output%ngbsw(94) = int(z'0000001b', c_int)
    output%ngbsw(95) = int(z'0000001c', c_int)
    output%ngbsw(96) = int(z'0000001c', c_int)
    output%ngbsw(97) = int(z'0000001c', c_int)
    output%ngbsw(98) = int(z'0000001c', c_int)
    output%ngbsw(99) = int(z'0000001c', c_int)
    output%ngbsw(100) = int(z'0000001c', c_int)
    output%ngbsw(101) = int(z'0000001d', c_int)
    output%ngbsw(102) = int(z'0000001d', c_int)
    output%ngbsw(103) = int(z'0000001d', c_int)
    output%ngbsw(104) = int(z'0000001d', c_int)
    output%ngbsw(105) = int(z'0000001d', c_int)
    output%ngbsw(106) = int(z'0000001d', c_int)
    output%ngbsw(107) = int(z'0000001d', c_int)
    output%ngbsw(108) = int(z'0000001d', c_int)
    output%ngbsw(109) = int(z'0000001d', c_int)
    output%ngbsw(110) = int(z'0000001d', c_int)
    output%ngbsw(111) = int(z'0000001d', c_int)
    output%ngbsw(112) = int(z'0000001d', c_int)
    call decode_real_words(bytes, 5, output%b16_ka, 9360)
    call decode_real_words(bytes, 74885, output%b16_kb, 3760)
    call decode_real_words(bytes, 5, output%b16_ka_d, 9360)
    call decode_real_words(bytes, 74885, output%b16_kb_d, 3760)
    output%b16_selfref = reshape(transfer([b16_selfref_bits_1, b16_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b16_forref = reshape(transfer([b16_forref_bits_1], [0.0_c_double], 48), [3, 16])
    output%b16_sfluxref = reshape(transfer([b16_sfluxref_bits_1], [0.0_c_double], 16), [16])
    output%b16_rayl = transfer(int(z'3df3ff537dd73111', c_int64_t), 0.0_c_double)
    output%b16_strrat1 = transfer(int(z'406f843126e978d5', c_int64_t), 0.0_c_double)
    output%b16_layreffr = int(z'00000012', c_int)
    call decode_real_words(bytes, 104973, output%b17_ka, 9360)
    call decode_real_words(bytes, 179853, output%b17_kb, 18800)
    call decode_real_words(bytes, 104973, output%b17_ka_d, 9360)
    call decode_real_words(bytes, 179853, output%b17_kb_d, 18800)
    output%b17_selfref = reshape(transfer([b17_selfref_bits_1, b17_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b17_forref = reshape(transfer([b17_forref_bits_1], [0.0_c_double], 64), [4, 16])
    output%b17_sfluxref = reshape(transfer([b17_sfluxref_bits_1], [0.0_c_double], 80), [16, 5])
    output%b17_rayl = transfer(int(z'3e07921eac14849d', c_int64_t), 0.0_c_double)
    output%b17_strrat = transfer(int(z'3fd756473471f794', c_int64_t), 0.0_c_double)
    output%b17_layreffr = int(z'0000001e', c_int)
    call decode_real_words(bytes, 330261, output%b18_ka, 9360)
    call decode_real_words(bytes, 405141, output%b18_kb, 3760)
    call decode_real_words(bytes, 330261, output%b18_ka_d, 9360)
    call decode_real_words(bytes, 405141, output%b18_kb_d, 3760)
    output%b18_selfref = reshape(transfer([b18_selfref_bits_1, b18_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b18_forref = reshape(transfer([b18_forref_bits_1], [0.0_c_double], 48), [3, 16])
    output%b18_sfluxref = reshape(transfer([b18_sfluxref_bits_1, b18_sfluxref_bits_2], [0.0_c_double], 144), [16, 9])
    output%b18_rayl = transfer(int(z'3e17e148ded9d33a', c_int64_t), 0.0_c_double)
    output%b18_strrat = transfer(int(z'40437abd3c361134', c_int64_t), 0.0_c_double)
    output%b18_layreffr = int(z'00000006', c_int)
    call decode_real_words(bytes, 435229, output%b19_ka, 9360)
    call decode_real_words(bytes, 510109, output%b19_kb, 3760)
    call decode_real_words(bytes, 435229, output%b19_ka_d, 9360)
    call decode_real_words(bytes, 510109, output%b19_kb_d, 3760)
    output%b19_selfref = reshape(transfer([b19_selfref_bits_1, b19_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b19_forref = reshape(transfer([b19_forref_bits_1], [0.0_c_double], 48), [3, 16])
    output%b19_sfluxref = reshape(transfer([b19_sfluxref_bits_1, b19_sfluxref_bits_2], [0.0_c_double], 144), [16, 9])
    output%b19_rayl = transfer(int(z'3e23abc364b196fa', c_int64_t), 0.0_c_double)
    output%b19_strrat = transfer(int(z'4015f8a32f44912a', c_int64_t), 0.0_c_double)
    output%b19_layreffr = int(z'00000003', c_int)
    call decode_real_words(bytes, 540197, output%b20_ka, 1040)
    call decode_real_words(bytes, 548517, output%b20_kb, 3760)
    call decode_real_words(bytes, 540197, output%b20_ka_d, 1040)
    call decode_real_words(bytes, 548517, output%b20_kb_d, 3760)
    output%b20_selfref = reshape(transfer([b20_selfref_bits_1, b20_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b20_forref = reshape(transfer([b20_forref_bits_1], [0.0_c_double], 64), [4, 16])
    output%b20_sfluxref = reshape(transfer([b20_sfluxref_bits_1], [0.0_c_double], 16), [16])
    output%b20_absch4 = reshape(transfer([b20_absch4_bits_1], [0.0_c_double], 16), [16])
    output%b20_rayl = transfer(int(z'3e31b1fce76faef0', c_int64_t), 0.0_c_double)
    output%b20_layreffr = int(z'00000003', c_int)
    call decode_real_words(bytes, 578605, output%b21_ka, 9360)
    call decode_real_words(bytes, 653485, output%b21_kb, 18800)
    call decode_real_words(bytes, 578605, output%b21_ka_d, 9360)
    call decode_real_words(bytes, 653485, output%b21_kb_d, 18800)
    output%b21_selfref = reshape(transfer([b21_selfref_bits_1, b21_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b21_forref = reshape(transfer([b21_forref_bits_1], [0.0_c_double], 64), [4, 16])
    output%b21_sfluxref = reshape(transfer([b21_sfluxref_bits_1, b21_sfluxref_bits_2], [0.0_c_double], 144), [16, 9])
    output%b21_rayl = transfer(int(z'3e443533c3f2cdae', c_int64_t), 0.0_c_double)
    output%b21_strrat = transfer(int(z'3f7290405483e5d3', c_int64_t), 0.0_c_double)
    output%b21_layreffr = int(z'00000008', c_int)
    call decode_real_words(bytes, 803893, output%b22_ka, 9360)
    call decode_real_words(bytes, 878773, output%b22_kb, 3760)
    call decode_real_words(bytes, 803893, output%b22_ka_d, 9360)
    call decode_real_words(bytes, 878773, output%b22_kb_d, 3760)
    output%b22_selfref = reshape(transfer([b22_selfref_bits_1, b22_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b22_forref = reshape(transfer([b22_forref_bits_1], [0.0_c_double], 48), [3, 16])
    output%b22_sfluxref = reshape(transfer([b22_sfluxref_bits_1, b22_sfluxref_bits_2], [0.0_c_double], 144), [16, 9])
    output%b22_rayl = transfer(int(z'3e50891ea90bc822', c_int64_t), 0.0_c_double)
    output%b22_strrat = transfer(int(z'3f9740c4156e264e', c_int64_t), 0.0_c_double)
    output%b22_layreffr = int(z'00000002', c_int)
    call decode_real_words(bytes, 908861, output%b23_ka, 1040)
    call decode_real_words(bytes, 908861, output%b23_ka_d, 1040)
    output%b23_selfref = reshape(transfer([b23_selfref_bits_1, b23_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b23_forref = reshape(transfer([b23_forref_bits_1], [0.0_c_double], 48), [3, 16])
    output%b23_sfluxref = reshape(transfer([b23_sfluxref_bits_1], [0.0_c_double], 16), [16])
    output%b23_rayl = reshape(transfer([b23_rayl_bits_1], [0.0_c_double], 16), [16])
    output%b23_givfac = transfer(int(z'3ff076c8b4395810', c_int64_t), 0.0_c_double)
    output%b23_layreffr = int(z'00000006', c_int)
    call decode_real_words(bytes, 917189, output%b24_ka, 9360)
    call decode_real_words(bytes, 992069, output%b24_kb, 3760)
    call decode_real_words(bytes, 917189, output%b24_ka_d, 9360)
    call decode_real_words(bytes, 992069, output%b24_kb_d, 3760)
    output%b24_selfref = reshape(transfer([b24_selfref_bits_1, b24_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b24_forref = reshape(transfer([b24_forref_bits_1], [0.0_c_double], 48), [3, 16])
    output%b24_sfluxref = reshape(transfer([b24_sfluxref_bits_1, b24_sfluxref_bits_2], [0.0_c_double], 144), [16, 9])
    output%b24_abso3a = reshape(transfer([b24_abso3a_bits_1], [0.0_c_double], 16), [16])
    output%b24_abso3b = reshape(transfer([b24_abso3b_bits_1], [0.0_c_double], 16), [16])
    output%b24_rayla = reshape(transfer([b24_rayla_bits_1, b24_rayla_bits_2], [0.0_c_double], 144), [16, 9])
    output%b24_raylb = reshape(transfer([b24_raylb_bits_1], [0.0_c_double], 16), [16])
    output%b24_strrat = transfer(int(z'3fbfebd09e12a51e', c_int64_t), 0.0_c_double)
    output%b24_layreffr = int(z'00000001', c_int)
    call decode_real_words(bytes, 1022157, output%b25_ka, 1040)
    call decode_real_words(bytes, 1022157, output%b25_ka_d, 1040)
    output%b25_sfluxref = reshape(transfer([b25_sfluxref_bits_1], [0.0_c_double], 16), [16])
    output%b25_rayl = reshape(transfer([b25_rayl_bits_1], [0.0_c_double], 16), [16])
    output%b25_abso3a = reshape(transfer([b25_abso3a_bits_1], [0.0_c_double], 16), [16])
    output%b25_abso3b = reshape(transfer([b25_abso3b_bits_1], [0.0_c_double], 16), [16])
    output%b25_layreffr = int(z'00000002', c_int)
    output%b26_sfluxref = reshape(transfer([b26_sfluxref_bits_1], [0.0_c_double], 16), [16])
    output%b26_rayl = reshape(transfer([b26_rayl_bits_1], [0.0_c_double], 16), [16])
    call decode_real_words(bytes, 1030485, output%b27_ka, 1040)
    call decode_real_words(bytes, 1038805, output%b27_kb, 3760)
    call decode_real_words(bytes, 1030485, output%b27_ka_d, 1040)
    call decode_real_words(bytes, 1038805, output%b27_kb_d, 3760)
    output%b27_sfluxref = reshape(transfer([b27_sfluxref_bits_1], [0.0_c_double], 16), [16])
    output%b27_rayl = reshape(transfer([b27_rayl_bits_1], [0.0_c_double], 16), [16])
    output%b27_scalekur = transfer(int(z'3ff096bb3ffc9cdf', c_int64_t), 0.0_c_double)
    output%b27_layreffr = int(z'00000020', c_int)
    call decode_real_words(bytes, 1068893, output%b28_ka, 9360)
    call decode_real_words(bytes, 1143773, output%b28_kb, 18800)
    call decode_real_words(bytes, 1068893, output%b28_ka_d, 9360)
    call decode_real_words(bytes, 1143773, output%b28_kb_d, 18800)
    output%b28_sfluxref = reshape(transfer([b28_sfluxref_bits_1], [0.0_c_double], 80), [16, 5])
    output%b28_rayl = transfer(int(z'3ef52e656e18e24f', c_int64_t), 0.0_c_double)
    output%b28_strrat = transfer(int(z'3ea661bc487b0cd1', c_int64_t), 0.0_c_double)
    output%b28_layreffr = int(z'0000003a', c_int)
    call decode_real_words(bytes, 1294181, output%b29_ka, 1040)
    call decode_real_words(bytes, 1302501, output%b29_kb, 3760)
    call decode_real_words(bytes, 1294181, output%b29_ka_d, 1040)
    call decode_real_words(bytes, 1302501, output%b29_kb_d, 3760)
    output%b29_selfref = reshape(transfer([b29_selfref_bits_1, b29_selfref_bits_2], [0.0_c_double], 160), [10, 16])
    output%b29_forref = reshape(transfer([b29_forref_bits_1], [0.0_c_double], 64), [4, 16])
    output%b29_sfluxref = reshape(transfer([b29_sfluxref_bits_1], [0.0_c_double], 16), [16])
    output%b29_absh2o = reshape(transfer([b29_absh2o_bits_1], [0.0_c_double], 16), [16])
    output%b29_absco2 = reshape(transfer([b29_absco2_bits_1], [0.0_c_double], 16), [16])
    output%b29_rayl = transfer(int(z'3dd9904b0fb6b821', c_int64_t), 0.0_c_double)
    output%b29_layreffr = int(z'00000031', c_int)
    status = 0_c_int
  end function
end module shortwave_absorption_decoder
