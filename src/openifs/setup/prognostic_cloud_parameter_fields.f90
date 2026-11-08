!> Complete native cloud parameter field calculation from selected SUCLDP.
!! Caller-owned TECLDP fields receive cloud, rain, snow, ice and aerosol
!! coefficients. Inputs are full-level pressure in Pa, pi, gravity in m/s^2,
!! reference temperature in K, dimensionless scalings and physics interval in s.
!! The caller first validates all inputs and the empty NAMCLDP selection.
!! RCLDTOPP and every unwritten field or padding byte remain unchanged.
module prognostic_cloud_parameter_fields_mod
  use iso_fortran_env, only: real32, real64, int32, int64
  use iso_c_binding, only: c_double
  use yoecldp, only: tecldp
  use cloud_beta_gamma_mod, only: cloud_generalized_gamma, cloud_incomplete_beta
  implicit none
  private
  public :: prognostic_cloud_parameter_fields
  interface
    function scalar_pow(base, exponent) bind(C, name="pow") result(value)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: value
    end function scalar_pow
  end interface
contains
  !> Construct the complete selected fields and both101-point beta tables.
  subroutine prognostic_cloud_parameter_fields(ydecldp, pressure, rpi, rg, rtt, scalings, tsphy)
    type(tecldp), intent(inout) :: ydecldp
    real(real64), intent(in) :: pressure(:), rpi, rg, rtt, scalings(2), tsphy
    integer(int32) :: index, level
    real(real32), volatile :: beta_coordinate32
    real(real64) :: coordinate, shape, ratio
    real(real64), volatile :: coefficient_001, coefficient_002, coefficient_003, coefficient_004, coefficient_005
    real(real64), volatile :: coefficient_006, coefficient_007, coefficient_008, coefficient_009, coefficient_010
    real(real64), volatile :: coefficient_011, coefficient_012, coefficient_013, coefficient_014, coefficient_015
    real(real64), volatile :: coefficient_016, coefficient_017, coefficient_018, coefficient_019, coefficient_020
    real(real64), volatile :: coefficient_021, coefficient_022, coefficient_023, coefficient_024, coefficient_025
    real(real64), volatile :: coefficient_026, coefficient_027, coefficient_028, coefficient_029, coefficient_030
    real(real64), volatile :: coefficient_031, coefficient_032, coefficient_033, coefficient_034, coefficient_035
    real(real64), volatile :: coefficient_036, coefficient_037, coefficient_038, coefficient_039, coefficient_040
    real(real64), volatile :: coefficient_041, coefficient_042, coefficient_043, coefficient_044, coefficient_045
    real(real64), volatile :: coefficient_046, coefficient_047, coefficient_048, coefficient_049, coefficient_050
    real(real64), volatile :: coefficient_051, coefficient_052, coefficient_053, coefficient_054, coefficient_055
    real(real64), volatile :: coefficient_056, coefficient_057, coefficient_058, coefficient_059, coefficient_060
    real(real64), volatile :: coefficient_061, coefficient_062, coefficient_063, coefficient_064, coefficient_065
    real(real64), volatile :: coefficient_066, coefficient_067, coefficient_068, coefficient_069, coefficient_070
    real(real64), volatile :: coefficient_071, coefficient_072, coefficient_073, coefficient_074, coefficient_075
    real(real64), volatile :: coefficient_076, coefficient_077, coefficient_078, coefficient_079, coefficient_080
    real(real64), volatile :: coefficient_081, coefficient_082, coefficient_083, coefficient_084, coefficient_085
    real(real64), volatile :: coefficient_086, coefficient_087, coefficient_088, coefficient_089, coefficient_090
    real(real64), volatile :: coefficient_091, coefficient_092, coefficient_093, coefficient_094, coefficient_095
    real(real64), volatile :: coefficient_096, coefficient_097, coefficient_098, coefficient_099, coefficient_100
    real(real64), volatile :: coefficient_101, coefficient_102, coefficient_103, coefficient_104, coefficient_105
    real(real64), volatile :: coefficient_106, coefficient_107, coefficient_108, coefficient_109, coefficient_110
    real(real64), volatile :: coefficient_111, coefficient_112, coefficient_113, coefficient_114, coefficient_115
    real(real64), volatile :: coefficient_116, coefficient_117, coefficient_118, coefficient_119, coefficient_120
    real(real64), volatile :: coefficient_121, coefficient_122, coefficient_123, coefficient_124, coefficient_125
    real(real64), volatile :: coefficient_126, coefficient_127, coefficient_128, coefficient_129, coefficient_130
    real(real64), volatile :: coefficient_131, coefficient_132, coefficient_133, coefficient_134, coefficient_135
    real(real64), volatile :: coefficient_136, coefficient_137, coefficient_138, coefficient_139, coefficient_140
    real(real64), volatile :: coefficient_141, coefficient_142, coefficient_143, coefficient_144, coefficient_145
    real(real64), volatile :: coefficient_146, coefficient_147, coefficient_148, coefficient_149, coefficient_150
    real(real64), volatile :: coefficient_151, coefficient_152, coefficient_153, coefficient_154, coefficient_155
    real(real64), volatile :: coefficient_156, coefficient_157, coefficient_158, coefficient_159, coefficient_160
    real(real64), volatile :: coefficient_161, coefficient_162, coefficient_163, coefficient_164, coefficient_165
    real(real64), volatile :: coefficient_166, coefficient_167, coefficient_168, coefficient_169, coefficient_170
    real(real64), volatile :: coefficient_171, coefficient_172, coefficient_173, coefficient_174, coefficient_175
    real(real64), volatile :: coefficient_176, coefficient_177, coefficient_178, coefficient_179, coefficient_180
    real(real64), volatile :: coefficient_181, coefficient_182, coefficient_183, coefficient_184, coefficient_185
    real(real64), volatile :: coefficient_186, coefficient_187, coefficient_188, coefficient_189, coefficient_190
    real(real64), volatile :: coefficient_191, coefficient_192, coefficient_193, coefficient_194, coefficient_195
    real(real64), volatile :: coefficient_196, coefficient_197, coefficient_198, coefficient_199, coefficient_200
    real(real64), volatile :: coefficient_201, coefficient_202, coefficient_203, coefficient_204, coefficient_205
    real(real64), volatile :: coefficient_206, coefficient_207, coefficient_208, coefficient_209, coefficient_210
    real(real64), volatile :: coefficient_211, coefficient_212, coefficient_213, coefficient_214, coefficient_215
    real(real64), volatile :: coefficient_216, coefficient_217, coefficient_218, coefficient_219, coefficient_220
    real(real64), volatile :: coefficient_221, coefficient_222, coefficient_223, coefficient_224, coefficient_225
    real(real64), volatile :: coefficient_226, coefficient_227, coefficient_228, coefficient_229, coefficient_230
    real(real64), volatile :: coefficient_231, coefficient_232, coefficient_233, coefficient_234, coefficient_235
    real(real64), volatile :: coefficient_236, coefficient_237, coefficient_238, coefficient_239, coefficient_240
    real(real64), volatile :: coefficient_241, coefficient_242, coefficient_243, coefficient_244, coefficient_245
    real(real64), volatile :: coefficient_246, coefficient_247, coefficient_248, coefficient_249, coefficient_250
    real(real64), volatile :: coefficient_251, coefficient_252, coefficient_253, coefficient_254, coefficient_255
    real(real64), volatile :: coefficient_256, coefficient_257, coefficient_258, coefficient_259, coefficient_260
    real(real64), volatile :: coefficient_261, coefficient_262, coefficient_263, coefficient_264, coefficient_265
    real(real64), volatile :: coefficient_266, coefficient_267, coefficient_268, coefficient_269, coefficient_270
    real(real64), volatile :: coefficient_271, coefficient_272, coefficient_273, coefficient_274, coefficient_275
    real(real64), volatile :: coefficient_276, coefficient_277, coefficient_278, coefficient_279, coefficient_280
    real(real64), volatile :: coefficient_281, coefficient_282, coefficient_283, coefficient_284, coefficient_285
    real(real64), volatile :: coefficient_286, coefficient_287, coefficient_288, coefficient_289, coefficient_290
    real(real64), volatile :: coefficient_291, coefficient_292, coefficient_293, coefficient_294, coefficient_295
    real(real64), volatile :: coefficient_296, coefficient_297, coefficient_298, coefficient_299, coefficient_300
    real(real64), volatile :: coefficient_301, coefficient_302, coefficient_303, coefficient_304, coefficient_305
    real(real64), volatile :: coefficient_306, coefficient_307, coefficient_308, coefficient_309, coefficient_310
    real(real64), volatile :: coefficient_311, coefficient_312, coefficient_313, coefficient_314, coefficient_315
    real(real64), volatile :: coefficient_316, coefficient_317, coefficient_318, coefficient_319, coefficient_320
    real(real64), volatile :: coefficient_321, coefficient_322, coefficient_323, coefficient_324, coefficient_325
    real(real64), volatile :: coefficient_326, coefficient_327, coefficient_328, coefficient_329, coefficient_330
    real(real64), volatile :: coefficient_331, coefficient_332, coefficient_333, coefficient_334, coefficient_335
    real(real64), volatile :: coefficient_336, coefficient_337, coefficient_338, coefficient_339, coefficient_340
    real(real64), volatile :: coefficient_341, coefficient_342, coefficient_343, coefficient_344, coefficient_345
    real(real64), volatile :: coefficient_346, coefficient_347, coefficient_348
    real(real64) :: gravity_speed, distribution_scale, gamma_rain_speed, gamma_rain_base
    real(real64) :: gamma_rain_mass, gamma_rain_flux, gamma_rain_collection, gamma_rain_freezing
    real(real64) :: gamma_ice_mass, gamma_ice_base, gamma_ice_speed, gamma_ice_flux
    real(real64) :: gamma_snow_mass, gamma_snow_collection, gamma_snow_speed, gamma_snow_base
    real(real64) :: gamma_distribution
    ! Literal stores retain their source order and original overwrites.
    ydecldp%ramid = transfer(int(z'3fe999999999999a', int64), 0.0_real64)
    ydecldp%rprc1 = transfer(int(z'4059000000000000', int64), 0.0_real64)
    ydecldp%rprc2 = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    ydecldp%rtau_cld_tlad = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%rcldmax = transfer(int(z'3f747ae147ae147b', int64), 0.0_real64)
    ydecldp%ramin = transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64)
    ydecldp%rlmin = transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64)
    ydecldp%rcldiff_convi = transfer(int(z'4024000000000000', int64), 0.0_real64)
    ydecldp%rclcrit = transfer(int(z'3f3a36e2eb1c432d', int64), 0.0_real64)
    ydecldp%rclcrit_sea = transfer(int(z'3f30624dd2f1a9fc', int64), 0.0_real64)
    ydecldp%rclcrit_land = transfer(int(z'3f4205bc01a36e2f', int64), 0.0_real64)
    ydecldp%rcl_inhomogaut = transfer(int(z'3ff8000000000000', int64), 0.0_real64)
    ydecldp%rcl_inhomogacc = transfer(int(z'4008000000000000', int64), 0.0_real64)
    ydecldp%rsnowlin2 = transfer(int(z'3f9eb851eb851eb8', int64), 0.0_real64)
    ydecldp%rlcritsnow = transfer(int(z'3ef4f8b588e368f1', int64), 0.0_real64)
    ydecldp%rnice = transfer(int(z'3f9ba5e353f7ced9', int64), 0.0_real64)
    ydecldp%rccn = transfer(int(z'405f400000000000', int64), 0.0_real64)
    ydecldp%rcldtopcf = transfer(int(z'3f847ae147ae147b', int64), 0.0_real64)
    ydecldp%rdepliqrefrate = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    ydecldp%rcl_overlapliqice = transfer(int(z'3fe4cccccccccccd', int64), 0.0_real64)
    ydecldp%rcl_effrime = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ydecldp%riceinit = transfer(int(z'3d719799812dea11', int64), 0.0_real64)
    ydecldp%rprecrhmax = transfer(int(z'3fe6666666666666', int64), 0.0_real64)
    ydecldp%rcovpmin = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
    ydecldp%nssopt = 1_int32
    ydecldp%rdenswat = transfer(int(z'408f400000000000', int64), 0.0_real64)
    ydecldp%rdensref = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ydecldp%rcl_dr = transfer(int(z'3fe570a3d70a3d71', int64), 0.0_real64)
    ydecldp%rcl_br = transfer(int(z'4008000000000000', int64), 0.0_real64)
    ydecldp%rcl_x1r = transfer(int(z'3fcc28f5c28f5c29', int64), 0.0_real64)
    ydecldp%rcl_x2r = transfer(int(z'400199999999999a', int64), 0.0_real64)
    ydecldp%rcl_x4r = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%rcl_x1r_mp = transfer(int(z'415e848000000000', int64), 0.0_real64)
    ydecldp%rcl_x2r_mp = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%rcl_x4r_mp = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%rcl_cdenom1 = transfer(int(z'426035f930400000', int64), 0.0_real64)
    ydecldp%rcl_cdenom2 = transfer(int(z'41988e9f00000000', int64), 0.0_real64)
    ydecldp%rcl_cdenom3 = transfer(int(z'4069800000000000', int64), 0.0_real64)
    ydecldp%rcl_ka273 = transfer(int(z'3f989374bc6a7efa', int64), 0.0_real64)
    ydecldp%rcl_schmidt = transfer(int(z'3fe3333333333333', int64), 0.0_real64)
    ydecldp%rcl_dynvisc = transfer(int(z'3ef201096a61f390', int64), 0.0_real64)
    ydecldp%rcl_eff_racw = transfer(int(z'3fe6666666666666', int64), 0.0_real64)
    ydecldp%rcl_kkaac = transfer(int(z'4050c00000000000', int64), 0.0_real64)
    ydecldp%rcl_kkbac = transfer(int(z'3ff2666666666666', int64), 0.0_real64)
    ydecldp%rcl_kkaau = transfer(int(z'4095180000000000', int64), 0.0_real64)
    ydecldp%rcl_kkbauq = transfer(int(z'4003c28f5c28f5c3', int64), 0.0_real64)
    ydecldp%rcl_kkbaun = transfer(int(z'bffca3d70a3d70a4', int64), 0.0_real64)
    ydecldp%rcl_kk_cloud_num_sea = transfer(int(z'4049000000000000', int64), 0.0_real64)
    ydecldp%rcl_kk_cloud_num_land = transfer(int(z'4072c00000000000', int64), 0.0_real64)
    ydecldp%lcloud_inhomog = .false.
    ydecldp%rcl_fzrab = transfer(int(z'bfe51eb851eb851f', int64), 0.0_real64)
    ydecldp%rcl_fzrbb = transfer(int(z'4069000000000000', int64), 0.0_real64)
    ydecldp%rcl_ai = transfer(int(z'3fb1a9fbe76c8b44', int64), 0.0_real64)
    ydecldp%rcl_bi = transfer(int(z'4000000000000000', int64), 0.0_real64)
    ydecldp%rcl_di = transfer(int(z'3fe0dd2f1a9fbe77', int64), 0.0_real64)
    ydecldp%rcl_ci = transfer(int(z'4059000000000000', int64), 0.0_real64)
    ydecldp%rcl_di = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ydecldp%rcl_x1i = transfer(int(z'413e848000000000', int64), 0.0_real64)
    ydecldp%rcl_x2i = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%rcl_x3i = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ydecldp%rcl_x4i = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%rcl_apb1 = transfer(int(z'4264c7b6ec800000', int64), 0.0_real64)
    ydecldp%rcl_apb2 = transfer(int(z'419ba81400000000', int64), 0.0_real64)
    ydecldp%rcl_apb3 = transfer(int(z'406e333333333333', int64), 0.0_real64)
    ydecldp%rcl_as = transfer(int(z'3fb1a9fbe76c8b44', int64), 0.0_real64)
    ydecldp%rcl_bs = transfer(int(z'4000000000000000', int64), 0.0_real64)
    ydecldp%rcl_ds = transfer(int(z'3fe0dd2f1a9fbe77', int64), 0.0_real64)
    ydecldp%rcl_x1s = transfer(int(z'413e848000000000', int64), 0.0_real64)
    ydecldp%rcl_x2s = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%rcl_x3s = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ydecldp%rcl_x4s = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ydecldp%nptype_sev2wmo(1) = 11_int32
    ydecldp%nptype_sev2wmo(2) = 1_int32
    ydecldp%nptype_sev2wmo(3) = 2_int32
    ydecldp%nptype_sev2wmo(4) = 7_int32
    ydecldp%nptype_sev2wmo(5) = 4_int32
    ydecldp%nptype_sev2wmo(6) = 8_int32
    ydecldp%nptype_sev2wmo(7) = 9_int32
    ydecldp%nptype_sev2wmo(8) = 5_int32
    ydecldp%nptype_sev2wmo(9) = 6_int32
    ydecldp%nptype_sev2wmo(10) = 10_int32
    ydecldp%nptype_sev2wmo(11) = 12_int32
    ydecldp%nptype_sev2wmo(12) = 3_int32
    ydecldp%nclddiag = 0_int32
    ydecldp%lcldbudc = .false.
    ydecldp%lcldbudl = .false.
    ydecldp%lcldbudi = .false.
    ydecldp%lcldbudt = .false.
    ydecldp%lcldbud_vertint = .false.
    ydecldp%lcldbud_timeint = .true.
    ydecldp%naercld = 0_int32
    ydecldp%naeclbc = 9_int32
    ydecldp%naecldu = 4_int32
    ydecldp%naeclom = 7_int32
    ydecldp%naeclss = 1_int32
    ydecldp%naeclsu = 11_int32
    ydecldp%laerliqautolsp = .false.
    ydecldp%laerliqautocp = .false.
    ydecldp%laerliqautocpb = .false.
    ydecldp%laerliqcoll = .false.
    ydecldp%laericesed = .false.
    ydecldp%laericeauto = .false.
    ydecldp%rccnom = transfer(int(z'3fc0a3d70a3d70a4', int64), 0.0_real64)
    ydecldp%rccnss = transfer(int(z'3fa999999999999a', int64), 0.0_real64)
    ydecldp%rccnsu = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    ydecldp%nbeta = 100_int32
    ydecldp%ncldtop = 2_int32
    ydecldp%laerliqautocp = .false.
    ydecldp%ricehi1 = transfer(int(z'3f0179ec9cbd821e', int64), 0.0_real64)
    ydecldp%ricehi2 = transfer(int(z'3f719453808ca29c', int64), 0.0_real64)
    ydecldp%nshapep = transfer(int(z'4003504f333f9de6', int64), 0.0_real64)
    ydecldp%nshapeq = transfer(int(z'4003504f333f9de6', int64), 0.0_real64)
    coefficient_001 = scalings(1)
    coefficient_002 = scalings(2)
    coefficient_003 = transfer(int(z'3ed92a737110e454', int64), 0.0_real64)*coefficient_001
    coefficient_004 = coefficient_003*coefficient_002
    ydecldp%rcldiff = coefficient_004
    coefficient_005 = coefficient_001*coefficient_002
    coefficient_006 = coefficient_005/transfer(int(z'40b7700000000000', int64), 0.0_real64)
    ydecldp%rkconv = coefficient_006
    coefficient_007 = coefficient_001*coefficient_002
    coefficient_008 = coefficient_007/transfer(int(z'408f400000000000', int64), 0.0_real64)
    ydecldp%rsnowlin1 = coefficient_008
    coefficient_009 = sqrt(coefficient_001)
    coefficient_010 = coefficient_002*coefficient_009
    gravity_speed = coefficient_010
    coefficient_011 = transfer(int(z'3fc0a3d70a3d70a4', int64), 0.0_real64)*coefficient_010
    ydecldp%rvice = coefficient_011
    coefficient_012 = 4.0_real64*coefficient_010
    ydecldp%rvrain = coefficient_012
    coefficient_013 = 1.0_real64*coefficient_010
    ydecldp%rvsnow = coefficient_013
    coefficient_014 = scalings(1)
    coefficient_015 = transfer(int(z'407f400000000000', int64), 0.0_real64)/coefficient_014
    ydecldp%rdepliqrefdepth = coefficient_015
    coefficient_016 = rtt
    coefficient_017 = coefficient_016 - transfer(int(z'4043000000000000', int64), 0.0_real64)
    ydecldp%rthomo = coefficient_017
    coefficient_018 = scalings(1)
    coefficient_019 = scalings(2)
    coefficient_020 = transfer(int(z'3f41d3671ac14c66', int64), 0.0_real64)*coefficient_018
    coefficient_021 = coefficient_020*coefficient_019
    coefficient_022 = rg
    coefficient_023 = coefficient_021/coefficient_022
    ydecldp%rpecons = coefficient_023
    coefficient_024 = gravity_speed
    coefficient_025 = transfer(int(z'3f74d940789613d3', int64), 0.0_real64)*coefficient_024
    ydecldp%rvrfactor = coefficient_025
    coefficient_026 = coefficient_018*coefficient_019
    coefficient_027 = transfer(int(z'40bc200000000000', int64), 0.0_real64)/coefficient_026
    ydecldp%rtaumel = coefficient_027
    coefficient_028 = transfer(int(z'40c5180000000000', int64), 0.0_real64)/coefficient_026
    ydecldp%rkooptau = coefficient_028
    coefficient_029 = transfer(int(z'40782ccccccccccd', int64), 0.0_real64)*coefficient_024
    ydecldp%rcl_cr = coefficient_029
    coefficient_030 = ydecldp%rdenswat
    coefficient_031 = rpi
    coefficient_032 = coefficient_030*coefficient_031
    coefficient_033 = coefficient_032/6.0_real64
    ydecldp%rcl_ar = coefficient_033
    ! Rain particle-size distribution and generalized-gamma values.
    coefficient_034 = ydecldp%rcl_ar
    coefficient_035 = ydecldp%rcl_x1r
    coefficient_036 = coefficient_034*coefficient_035
    distribution_scale = coefficient_036
    coefficient_037 = ydecldp%rcl_br
    coefficient_038 = coefficient_037 + 1.0_real64
    coefficient_039 = ydecldp%rcl_x4r
    coefficient_040 = coefficient_038 + coefficient_039
    coefficient_041 = cloud_generalized_gamma(coefficient_040, rpi)
    gamma_rain_speed = coefficient_041
    coefficient_042 = distribution_scale
    coefficient_043 = coefficient_042*coefficient_041
    ydecldp%rcl_lam1r = coefficient_043
    coefficient_044 = ydecldp%rcl_br
    coefficient_045 = coefficient_044 + 1.0_real64
    coefficient_046 = ydecldp%rcl_x4r
    coefficient_047 = coefficient_045 + coefficient_046
    coefficient_048 = ydecldp%rcl_x2r
    coefficient_049 = coefficient_047 - coefficient_048
    coefficient_050 = 1.0_real64/coefficient_049
    ydecldp%rcl_lam2r = coefficient_050
    coefficient_051 = ydecldp%rcl_ar
    coefficient_052 = ydecldp%rcl_x1r_mp
    coefficient_053 = coefficient_051*coefficient_052
    distribution_scale = coefficient_053
    coefficient_054 = ydecldp%rcl_br
    coefficient_055 = coefficient_054 + 1.0_real64
    coefficient_056 = ydecldp%rcl_x4r_mp
    coefficient_057 = coefficient_055 + coefficient_056
    coefficient_058 = cloud_generalized_gamma(coefficient_057, rpi)
    gamma_rain_speed = coefficient_058
    coefficient_059 = distribution_scale
    coefficient_060 = coefficient_059*coefficient_058
    ydecldp%rcl_lam1r_mp = coefficient_060
    coefficient_061 = ydecldp%rcl_br
    coefficient_062 = coefficient_061 + 1.0_real64
    coefficient_063 = ydecldp%rcl_x4r_mp
    coefficient_064 = coefficient_062 + coefficient_063
    coefficient_065 = ydecldp%rcl_x2r_mp
    coefficient_066 = coefficient_064 - coefficient_065
    coefficient_067 = 1.0_real64/coefficient_066
    ydecldp%rcl_lam2r_mp = coefficient_067
    coefficient_068 = ydecldp%rcl_dr
    coefficient_069 = coefficient_068 + 5.0_real64
    coefficient_070 = coefficient_069/2.0_real64
    coefficient_071 = cloud_generalized_gamma(coefficient_070, rpi)
    gamma_rain_speed = coefficient_071
    coefficient_072 = ydecldp%rcl_x4r
    coefficient_073 = 2.0_real64 + coefficient_072
    coefficient_074 = cloud_generalized_gamma(coefficient_073, rpi)
    gamma_rain_base = coefficient_074
    coefficient_075 = ydecldp%rcl_br
    coefficient_076 = coefficient_075 + 1.0_real64
    coefficient_077 = ydecldp%rcl_x4r
    coefficient_078 = coefficient_076 + coefficient_077
    coefficient_079 = cloud_generalized_gamma(coefficient_078, rpi)
    gamma_rain_mass = coefficient_079
    coefficient_080 = ydecldp%rcl_dr
    coefficient_081 = ydecldp%rcl_br
    coefficient_082 = coefficient_080 + coefficient_081
    coefficient_083 = coefficient_082 + 1.0_real64
    coefficient_084 = ydecldp%rcl_x4r
    coefficient_085 = coefficient_083 + coefficient_084
    coefficient_086 = cloud_generalized_gamma(coefficient_085, rpi)
    gamma_rain_flux = coefficient_086
    coefficient_087 = ydecldp%rcl_dr
    coefficient_088 = 3.0_real64 + coefficient_087
    coefficient_089 = ydecldp%rcl_x4r
    coefficient_090 = coefficient_088 + coefficient_089
    coefficient_091 = cloud_generalized_gamma(coefficient_090, rpi)
    gamma_rain_collection = coefficient_091
    coefficient_092 = ydecldp%rcl_br
    coefficient_093 = 4.0_real64 + coefficient_092
    coefficient_094 = ydecldp%rcl_x4r
    coefficient_095 = coefficient_093 + coefficient_094
    coefficient_096 = cloud_generalized_gamma(coefficient_095, rpi)
    gamma_rain_freezing = coefficient_096
    coefficient_097 = rpi
    coefficient_098 = 2.0_real64*coefficient_097
    coefficient_099 = ydecldp%rcl_x1r
    coefficient_100 = coefficient_098*coefficient_099
    coefficient_101 = scalings(1)
    coefficient_102 = scalings(2)
    coefficient_103 = coefficient_100*coefficient_101
    coefficient_104 = coefficient_103*coefficient_102
    ydecldp%rcl_const1r = coefficient_104
    coefficient_105 = ydecldp%rcl_schmidt
    coefficient_106 = scalar_pow(coefficient_105, transfer(int(z'3fd554c985f06f69', int64), 0.0_real64))
    coefficient_107 = transfer(int(z'3fd3d70a3d70a3d7', int64), 0.0_real64)*coefficient_106
    coefficient_108 = gamma_rain_speed
    coefficient_109 = coefficient_107*coefficient_108
    coefficient_110 = ydecldp%rcl_cr
    coefficient_111 = ydecldp%rcl_dynvisc
    coefficient_112 = coefficient_110/coefficient_111
    coefficient_113 = sqrt(coefficient_112)
    coefficient_114 = coefficient_109*coefficient_113
    ydecldp%rcl_const2r = coefficient_114
    coefficient_115 = ydecldp%rcl_dr
    coefficient_116 = coefficient_115 + 5.0_real64
    coefficient_117 = coefficient_116/2.0_real64
    coefficient_118 = ydecldp%rcl_x2r
    coefficient_119 = coefficient_117 - coefficient_118
    ydecldp%rcl_const3r = coefficient_119
    coefficient_120 = ydecldp%rcl_x2r
    coefficient_121 = 2.0_real64 - coefficient_120
    ydecldp%rcl_const4r = coefficient_121
    coefficient_122 = ydecldp%rcl_cr
    coefficient_123 = gamma_rain_flux
    coefficient_124 = coefficient_122*coefficient_123
    coefficient_125 = gamma_rain_mass
    coefficient_126 = coefficient_124/coefficient_125
    ydecldp%rcl_const7r = coefficient_126
    coefficient_127 = gamma_rain_base
    coefficient_128 = transfer(int(z'3fe8f5c28f5c28f6', int64), 0.0_real64)*coefficient_127
    ydecldp%rcl_const8r = coefficient_128
    coefficient_129 = rpi
    coefficient_130 = coefficient_129*0.25_real64
    coefficient_131 = ydecldp%rcl_x1r
    coefficient_132 = coefficient_130*coefficient_131
    coefficient_133 = ydecldp%rcl_cr
    coefficient_134 = coefficient_132*coefficient_133
    coefficient_135 = gamma_rain_collection
    coefficient_136 = coefficient_134*coefficient_135
    ydecldp%rcl_const9r = coefficient_136
    coefficient_137 = ydecldp%rcl_dr
    coefficient_138 = 3.0_real64 + coefficient_137
    coefficient_139 = ydecldp%rcl_x2r
    coefficient_140 = coefficient_138 - coefficient_139
    ydecldp%rcl_const10r = coefficient_140
    coefficient_141 = rpi
    coefficient_142 = coefficient_141/6.0_real64
    coefficient_143 = ydecldp%rcl_fzrbb
    coefficient_144 = coefficient_142*coefficient_143
    coefficient_145 = ydecldp%rcl_ar
    coefficient_146 = coefficient_144*coefficient_145
    coefficient_147 = ydecldp%rcl_x1r
    coefficient_148 = coefficient_146*coefficient_147
    coefficient_149 = gamma_rain_freezing
    coefficient_150 = coefficient_148*coefficient_149
    ydecldp%rcl_const5r = coefficient_150
    coefficient_151 = ydecldp%rcl_br
    coefficient_152 = 4.0_real64 + coefficient_151
    coefficient_153 = ydecldp%rcl_x4r
    coefficient_154 = coefficient_152 + coefficient_153
    coefficient_155 = ydecldp%rcl_x2r
    coefficient_156 = coefficient_154 - coefficient_155
    coefficient_157 = -1.0_real64*coefficient_156
    ydecldp%rcl_const6r = coefficient_157
    ! Source computes the first ice speed, then overwrites it with 100.
    coefficient_158 = gravity_speed
    coefficient_159 = transfer(int(z'4030cccccccccccd', int64), 0.0_real64)*coefficient_158
    ydecldp%rcl_ci = coefficient_159
    ydecldp%rcl_ci = transfer(int(z'4059000000000000', int64), 0.0_real64)
    coefficient_160 = ydecldp%rcl_bi
    coefficient_161 = coefficient_160 + 1.0_real64
    coefficient_162 = ydecldp%rcl_x4i
    coefficient_163 = coefficient_161 + coefficient_162
    coefficient_164 = cloud_generalized_gamma(coefficient_163, rpi)
    gamma_ice_mass = coefficient_164
    coefficient_165 = ydecldp%rcl_x4i
    coefficient_166 = coefficient_165 + 2.0_real64
    coefficient_167 = cloud_generalized_gamma(coefficient_166, rpi)
    gamma_ice_base = coefficient_167
    coefficient_168 = ydecldp%rcl_di
    coefficient_169 = coefficient_168 + 5.0_real64
    coefficient_170 = ydecldp%rcl_x4i
    coefficient_171 = 2.0_real64*coefficient_170
    coefficient_172 = coefficient_169 + coefficient_171
    coefficient_173 = coefficient_172/2.0_real64
    coefficient_174 = cloud_generalized_gamma(coefficient_173, rpi)
    gamma_ice_speed = coefficient_174
    coefficient_175 = ydecldp%rcl_di
    coefficient_176 = ydecldp%rcl_bi
    coefficient_177 = coefficient_175 + coefficient_176
    coefficient_178 = coefficient_177 + 1.0_real64
    coefficient_179 = ydecldp%rcl_x4i
    coefficient_180 = coefficient_178 + coefficient_179
    coefficient_181 = cloud_generalized_gamma(coefficient_180, rpi)
    gamma_ice_flux = coefficient_181
    coefficient_182 = ydecldp%rcl_ai
    coefficient_183 = ydecldp%rcl_x1i
    coefficient_184 = coefficient_182*coefficient_183
    distribution_scale = coefficient_184
    coefficient_185 = ydecldp%rcl_bi
    coefficient_186 = coefficient_185 + 1.0_real64
    coefficient_187 = ydecldp%rcl_x4i
    coefficient_188 = coefficient_186 + coefficient_187
    coefficient_189 = cloud_generalized_gamma(coefficient_188, rpi)
    gamma_distribution = coefficient_189
    coefficient_190 = distribution_scale
    coefficient_191 = coefficient_190*coefficient_189
    ydecldp%rcl_lambda1i = coefficient_191
    coefficient_192 = ydecldp%rcl_bi
    coefficient_193 = coefficient_192 + 1.0_real64
    coefficient_194 = ydecldp%rcl_x4i
    coefficient_195 = coefficient_193 + coefficient_194
    coefficient_196 = ydecldp%rcl_x2i
    coefficient_197 = coefficient_195 - coefficient_196
    coefficient_198 = 1.0_real64/coefficient_197
    ydecldp%rcl_lambda2i = coefficient_198
    coefficient_199 = ydecldp%rcl_ai
    coefficient_200 = ydecldp%rcl_x1i
    coefficient_201 = coefficient_199*coefficient_200
    coefficient_202 = gamma_ice_mass
    coefficient_203 = coefficient_201*coefficient_202
    coefficient_204 = 1.0_real64/coefficient_203
    ydecldp%rcl_const1i = coefficient_204
    coefficient_205 = rpi
    coefficient_206 = 1.0_real64*coefficient_205
    coefficient_207 = ydecldp%rcl_x1i
    coefficient_208 = coefficient_206*coefficient_207
    ydecldp%rcl_const2i = coefficient_208
    coefficient_209 = ydecldp%rcl_ci
    coefficient_210 = sqrt(coefficient_209)
    coefficient_211 = transfer(int(z'3fd7c045b885fdcd', int64), 0.0_real64)*coefficient_210
    coefficient_212 = gamma_ice_speed
    coefficient_213 = coefficient_211*coefficient_212
    coefficient_214 = coefficient_213/transfer(int(z'3f70f8f3e94da09e', int64), 0.0_real64)
    ydecldp%rcl_const3i = coefficient_214
    coefficient_215 = ydecldp%rcl_x4i
    coefficient_216 = 2.0_real64 + coefficient_215
    coefficient_217 = ydecldp%rcl_x2i
    coefficient_218 = coefficient_216 - coefficient_217
    coefficient_219 = ydecldp%rcl_bi
    coefficient_220 = coefficient_219 + 1.0_real64
    coefficient_221 = ydecldp%rcl_x4i
    coefficient_222 = coefficient_220 + coefficient_221
    coefficient_223 = coefficient_222 - coefficient_217
    coefficient_224 = coefficient_218/coefficient_223
    ydecldp%rcl_const4i = coefficient_224
    coefficient_225 = ydecldp%rcl_di
    coefficient_226 = 5.0_real64 + coefficient_225
    coefficient_227 = ydecldp%rcl_x4i
    coefficient_228 = 2.0_real64*coefficient_227
    coefficient_229 = coefficient_226 + coefficient_228
    coefficient_230 = ydecldp%rcl_x2i
    coefficient_231 = 2.0_real64*coefficient_230
    coefficient_232 = coefficient_229 - coefficient_231
    coefficient_233 = ydecldp%rcl_bi
    coefficient_234 = coefficient_233 + 1.0_real64
    coefficient_235 = ydecldp%rcl_x4i
    coefficient_236 = coefficient_234 + coefficient_235
    coefficient_237 = ydecldp%rcl_x2i
    coefficient_238 = coefficient_236 - coefficient_237
    coefficient_239 = 2.0_real64*coefficient_238
    coefficient_240 = coefficient_232/coefficient_239
    ydecldp%rcl_const5i = coefficient_240
    coefficient_241 = gamma_ice_base
    ydecldp%rcl_const6i = coefficient_241
    coefficient_242 = ydecldp%rcl_ci
    coefficient_243 = gamma_ice_flux
    coefficient_244 = coefficient_242*coefficient_243
    coefficient_245 = gamma_ice_mass
    coefficient_246 = coefficient_244/coefficient_245
    ydecldp%rcl_const7i = coefficient_246
    ! Snow coefficients retain their independent gamma evaluations and order.
    coefficient_247 = gravity_speed
    coefficient_248 = transfer(int(z'4030cccccccccccd', int64), 0.0_real64)*coefficient_247
    ydecldp%rcl_cs = coefficient_248
    coefficient_249 = ydecldp%rcl_bs
    coefficient_250 = coefficient_249 + 1.0_real64
    coefficient_251 = ydecldp%rcl_x4s
    coefficient_252 = coefficient_250 + coefficient_251
    coefficient_253 = cloud_generalized_gamma(coefficient_252, rpi)
    gamma_snow_mass = coefficient_253
    coefficient_254 = ydecldp%rcl_ds
    coefficient_255 = 3.0_real64 + coefficient_254
    coefficient_256 = ydecldp%rcl_x4s
    coefficient_257 = coefficient_255 + coefficient_256
    coefficient_258 = cloud_generalized_gamma(coefficient_257, rpi)
    gamma_snow_collection = coefficient_258
    coefficient_259 = ydecldp%rcl_ds
    coefficient_260 = coefficient_259 + 5.0_real64
    coefficient_261 = ydecldp%rcl_x4s
    coefficient_262 = 2.0_real64*coefficient_261
    coefficient_263 = coefficient_260 + coefficient_262
    coefficient_264 = coefficient_263/2.0_real64
    coefficient_265 = cloud_generalized_gamma(coefficient_264, rpi)
    gamma_snow_speed = coefficient_265
    coefficient_266 = ydecldp%rcl_x4s
    coefficient_267 = coefficient_266 + 2.0_real64
    coefficient_268 = cloud_generalized_gamma(coefficient_267, rpi)
    gamma_snow_base = coefficient_268
    coefficient_269 = ydecldp%rcl_as
    coefficient_270 = ydecldp%rcl_x1s
    coefficient_271 = coefficient_269*coefficient_270
    distribution_scale = coefficient_271
    coefficient_272 = ydecldp%rcl_bs
    coefficient_273 = coefficient_272 + 1.0_real64
    coefficient_274 = ydecldp%rcl_x4s
    coefficient_275 = coefficient_273 + coefficient_274
    coefficient_276 = cloud_generalized_gamma(coefficient_275, rpi)
    gamma_distribution = coefficient_276
    coefficient_277 = distribution_scale
    coefficient_278 = coefficient_277*coefficient_276
    ydecldp%rcl_lam1s = coefficient_278
    coefficient_279 = ydecldp%rcl_bs
    coefficient_280 = coefficient_279 + 1.0_real64
    coefficient_281 = ydecldp%rcl_x4s
    coefficient_282 = coefficient_280 + coefficient_281
    coefficient_283 = ydecldp%rcl_x2s
    coefficient_284 = coefficient_282 - coefficient_283
    coefficient_285 = 1.0_real64/coefficient_284
    ydecldp%rcl_lam2s = coefficient_285
    coefficient_286 = ydecldp%rcl_as
    coefficient_287 = ydecldp%rcl_x1s
    coefficient_288 = coefficient_286*coefficient_287
    coefficient_289 = gamma_snow_mass
    coefficient_290 = coefficient_288*coefficient_289
    coefficient_291 = 1.0_real64/coefficient_290
    ydecldp%rcl_const1s = coefficient_291
    coefficient_292 = rpi
    coefficient_293 = 1.0_real64*coefficient_292
    coefficient_294 = ydecldp%rcl_x1s
    coefficient_295 = coefficient_293*coefficient_294
    ydecldp%rcl_const2s = coefficient_295
    coefficient_296 = ydecldp%rcl_cs
    coefficient_297 = sqrt(coefficient_296)
    coefficient_298 = transfer(int(z'3fd7c045b885fdcd', int64), 0.0_real64)*coefficient_297
    coefficient_299 = gamma_snow_speed
    coefficient_300 = coefficient_298*coefficient_299
    coefficient_301 = coefficient_300/transfer(int(z'3f70f8f3e94da09e', int64), 0.0_real64)
    ydecldp%rcl_const3s = coefficient_301
    coefficient_302 = ydecldp%rcl_x4s
    coefficient_303 = 2.0_real64 + coefficient_302
    coefficient_304 = ydecldp%rcl_x2s
    coefficient_305 = coefficient_303 - coefficient_304
    coefficient_306 = ydecldp%rcl_bs
    coefficient_307 = coefficient_306 + 1.0_real64
    coefficient_308 = ydecldp%rcl_x4s
    coefficient_309 = coefficient_307 + coefficient_308
    coefficient_310 = coefficient_309 - coefficient_304
    coefficient_311 = coefficient_305/coefficient_310
    ydecldp%rcl_const4s = coefficient_311
    coefficient_312 = ydecldp%rcl_ds
    coefficient_313 = 5.0_real64 + coefficient_312
    coefficient_314 = ydecldp%rcl_x4s
    coefficient_315 = 2.0_real64*coefficient_314
    coefficient_316 = coefficient_313 + coefficient_315
    coefficient_317 = ydecldp%rcl_x2s
    coefficient_318 = 2.0_real64*coefficient_317
    coefficient_319 = coefficient_316 - coefficient_318
    coefficient_320 = ydecldp%rcl_bs
    coefficient_321 = coefficient_320 + 1.0_real64
    coefficient_322 = ydecldp%rcl_x4s
    coefficient_323 = coefficient_321 + coefficient_322
    coefficient_324 = ydecldp%rcl_x2s
    coefficient_325 = coefficient_323 - coefficient_324
    coefficient_326 = 2.0_real64*coefficient_325
    coefficient_327 = coefficient_319/coefficient_326
    ydecldp%rcl_const5s = coefficient_327
    coefficient_328 = gamma_snow_base
    ydecldp%rcl_const6s = coefficient_328
    coefficient_329 = rpi
    coefficient_330 = coefficient_329*0.25_real64
    coefficient_331 = ydecldp%rcl_x1s
    coefficient_332 = coefficient_330*coefficient_331
    coefficient_333 = ydecldp%rcl_cs
    coefficient_334 = coefficient_332*coefficient_333
    coefficient_335 = gamma_snow_collection
    coefficient_336 = coefficient_334*coefficient_335
    ydecldp%rcl_const7s = coefficient_336
    coefficient_337 = ydecldp%rcl_ds
    coefficient_338 = 3.0_real64 + coefficient_337
    coefficient_339 = ydecldp%rcl_x4s
    coefficient_340 = coefficient_338 + coefficient_339
    coefficient_341 = ydecldp%rcl_x2s
    coefficient_342 = coefficient_340 - coefficient_341
    coefficient_343 = ydecldp%rcl_bs
    coefficient_344 = coefficient_343 + 1.0_real64
    coefficient_345 = ydecldp%rcl_x4s
    coefficient_346 = coefficient_344 + coefficient_345
    coefficient_347 = coefficient_346 - coefficient_341
    coefficient_348 = coefficient_342/coefficient_347
    ydecldp%rcl_const8s = coefficient_348
    ! The coordinate division is explicitly REAL32 before widening to FP64.
    do index = 0, 100
      beta_coordinate32 = real(index, real32)/100.0_real32
      coordinate = real(beta_coordinate32, real64)
      ydecldp%rbeta(index) = cloud_incomplete_beta(ydecldp%nshapep, ydecldp%nshapeq, coordinate)
      shape = ydecldp%nshapep + 1.0_real64
      ydecldp%rbetap1(index) = cloud_incomplete_beta(shape, ydecldp%nshapeq, coordinate)
    end do
    ydecldp%ncldtop = 2_int32
    do level = size(pressure), 2, -1
      if (pressure(level) > ydecldp%rcldtopp) ydecldp%ncldtop = level
    end do
    ydecldp%lcldextra = btest(ydecldp%nclddiag, 0)
    ydecldp%lcldbudget = btest(ydecldp%nclddiag, 1)
    ratio = tsphy/ydecldp%rkooptau
    ydecldp%rssicefactor = min(ratio, 1.0_real64)
    ydecldp%laerliqautolsp = btest(ydecldp%naercld, 0)
    ydecldp%laerliqautocp = btest(ydecldp%naercld, 1)
    ydecldp%laerliqautocpb = btest(ydecldp%naercld, 2)
    ydecldp%laerliqcoll = btest(ydecldp%naercld, 3)
    ydecldp%laericesed = btest(ydecldp%naercld, 4)
    ydecldp%laericeauto = btest(ydecldp%naercld, 5)
  end subroutine prognostic_cloud_parameter_fields
end module prognostic_cloud_parameter_fields_mod
