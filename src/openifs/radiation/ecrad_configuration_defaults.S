/* Source-declared ecRad values; contract: skills/md2asm/references/openifs/radiation/ecrad_configuration.md. */
.text
.p2align 4
.global md2asm_initialize_ecrad_configuration_defaults
.type md2asm_initialize_ecrad_configuration_defaults,%function
md2asm_initialize_ecrad_configuration_defaults:
 cbz x0,.Lcfg_bad
 tst x0,#7
 b.ne .Lcfg_bad
 mov x2,#22472
 cmp x1,x2
 b.lo .Lcfg_bad
 adds x2,x0,x2
 b.cs .Lcfg_bad
 adrp x2,.Lcfg_null_offsets
 add x2,x2,:lo12:.Lcfg_null_offsets
 mov x3,#46
.Lcfg_check_null:
 ldr w4,[x2],#4
 ldr x5,[x0,x4]
 cbnz x5,.Lcfg_bad
 subs x3,x3,#1
 b.ne .Lcfg_check_null
 /* config.use_spectral_solar_scaling = .false.. */
 mov x2,#0
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.directory_name = '.'. */
 mov x2,#4
 add x2,x0,x2
 mov w3,#32
 mov x4,#511
.Lcfg_fill_1:
 strb w3,[x2],#1
 subs x4,x4,#1
 b.ne .Lcfg_fill_1
 mov x2,#4
 add x2,x0,x2
 mov w3,#46
 strb w3,[x2],#1
 /* config.cloud_fraction_threshold = 1.0e-6_jprb. */
 mov x2,#520
 add x2,x0,x2
 movz x3,#60813
 movk x3,#41141,lsl #16
 movk x3,#50935,lsl #32
 movk x3,#16048,lsl #48
 str x3,[x2],#8
 /* config.cloud_mixing_ratio_threshold = 1.0e-9_jprb. */
 mov x2,#528
 add x2,x0,x2
 movz x3,#54933
 movk x3,#59430,lsl #16
 movk x3,#11787,lsl #32
 movk x3,#15889,lsl #48
 str x3,[x2],#8
 /* config.i_overlap_scheme = IOverlapExponentialRandom. */
 mov x2,#536
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.use_beta_overlap = .false.. */
 mov x2,#540
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.i_cloud_pdf_shape = IPdfShapeGamma. */
 mov x2,#544
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.cloud_inhom_decorr_scaling = 0.5_jprb. */
 mov x2,#552
 add x2,x0,x2
 movz x3,#0
 movk x3,#16352,lsl #48
 str x3,[x2],#8
 /* config.clear_to_thick_fraction = 0.0_jprb. */
 mov x2,#560
 add x2,x0,x2
 movz x3,#0
 str x3,[x2],#8
 /* config.overhead_sun_factor = 0.0_jprb. */
 mov x2,#568
 add x2,x0,x2
 movz x3,#0
 str x3,[x2],#8
 /* config.min_gas_od_lw = 1.0e-15_jprb. */
 mov x2,#576
 add x2,x0,x2
 movz x3,#22038
 movk x3,#40679,lsl #16
 movk x3,#943,lsl #32
 movk x3,#15570,lsl #48
 str x3,[x2],#8
 /* config.min_gas_od_sw = 0.0_jprb. */
 mov x2,#584
 add x2,x0,x2
 movz x3,#0
 str x3,[x2],#8
 /* config.max_gas_od_3d = 8.0_jprb. */
 mov x2,#592
 add x2,x0,x2
 movz x3,#0
 movk x3,#16416,lsl #48
 str x3,[x2],#8
 /* config.max_cloud_od = 16.0_jprb. */
 mov x2,#600
 add x2,x0,x2
 movz x3,#0
 movk x3,#16432,lsl #48
 str x3,[x2],#8
 /* config.do_lw_cloud_scattering = .true.. */
 mov x2,#608
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_lw_aerosol_scattering = .true.. */
 mov x2,#612
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.nregions = 3. */
 mov x2,#616
 add x2,x0,x2
 movz w3,#3
 str w3,[x2],#4
 /* config.i_solver_sw = ISolverMcICA. */
 mov x2,#620
 add x2,x0,x2
 movz w3,#2
 str w3,[x2],#4
 /* config.i_solver_lw = ISolverMcICA. */
 mov x2,#624
 add x2,x0,x2
 movz w3,#2
 str w3,[x2],#4
 /* config.do_sw_delta_scaling_with_gases = .false.. */
 mov x2,#628
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.i_gas_model = IGasModelIFSRRTMG. */
 mov x2,#632
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.mono_lw_wavelength = -1.0_jprb. */
 mov x2,#640
 add x2,x0,x2
 movz x3,#0
 movk x3,#49136,lsl #48
 str x3,[x2],#8
 /* config.mono_lw_total_od = 0.0_jprb. */
 mov x2,#648
 add x2,x0,x2
 movz x3,#0
 str x3,[x2],#8
 /* config.mono_sw_total_od = 0.0_jprb. */
 mov x2,#656
 add x2,x0,x2
 movz x3,#0
 str x3,[x2],#8
 /* config.mono_sw_single_scattering_albedo = 0.999999_jprb. */
 mov x2,#664
 add x2,x0,x2
 movz x3,#3049
 movk x3,#59169,lsl #16
 movk x3,#65533,lsl #32
 movk x3,#16367,lsl #48
 str x3,[x2],#8
 /* config.mono_sw_asymmetry_factor = 0.86_jprb. */
 mov x2,#672
 add x2,x0,x2
 movz x3,#60293
 movk x3,#47185,lsl #16
 movk x3,#34078,lsl #32
 movk x3,#16363,lsl #48
 str x3,[x2],#8
 /* config.mono_lw_single_scattering_albedo = 0.538_jprb. */
 mov x2,#680
 add x2,x0,x2
 movz x3,#61342
 movk x3,#50855,lsl #16
 movk x3,#14155,lsl #32
 movk x3,#16353,lsl #48
 str x3,[x2],#8
 /* config.mono_lw_asymmetry_factor = 0.925_jprb. */
 mov x2,#688
 add x2,x0,x2
 movz x3,#39322
 movk x3,#39321,lsl #16
 movk x3,#39321,lsl #32
 movk x3,#16365,lsl #48
 str x3,[x2],#8
 /* config.i_liq_model = ILiquidModelSOCRATES. */
 mov x2,#696
 add x2,x0,x2
 movz w3,#2
 str w3,[x2],#4
 /* config.i_ice_model = IIceModelBaran. */
 mov x2,#700
 add x2,x0,x2
 movz w3,#3
 str w3,[x2],#4
 /* config.use_psrad_cloud_optics = .false.. */
 mov x2,#704
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_nearest_spectral_sw_albedo = .true.. */
 mov x2,#708
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_nearest_spectral_lw_emiss = .true.. */
 mov x2,#712
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.sw_albedo_wavelength_bound = -1.0_jprb. */
 mov x2,#720
 add x2,x0,x2
 movz x3,#0
 movk x3,#49136,lsl #48
 mov x4,#255
.Lcfg_fill_33:
 str x3,[x2],#8
 subs x4,x4,#1
 b.ne .Lcfg_fill_33
 /* config.lw_emiss_wavelength_bound = -1.0_jprb. */
 mov x2,#2760
 add x2,x0,x2
 movz x3,#0
 movk x3,#49136,lsl #48
 mov x4,#255
.Lcfg_fill_34:
 str x3,[x2],#8
 subs x4,x4,#1
 b.ne .Lcfg_fill_34
 /* config.i_sw_albedo_index = 0. */
 mov x2,#4800
 add x2,x0,x2
 movz w3,#0
 mov x4,#256
.Lcfg_fill_35:
 str w3,[x2],#4
 subs x4,x4,#1
 b.ne .Lcfg_fill_35
 /* config.i_lw_emiss_index = 0. */
 mov x2,#5824
 add x2,x0,x2
 movz w3,#0
 mov x4,#256
.Lcfg_fill_36:
 str w3,[x2],#4
 subs x4,x4,#1
 b.ne .Lcfg_fill_36
 /* config.do_lw = .true.. */
 mov x2,#6848
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_sw = .true.. */
 mov x2,#6852
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_clear = .true.. */
 mov x2,#6856
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_sw_direct = .true.. */
 mov x2,#6860
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_3d_effects = .true.. */
 mov x2,#6864
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.i_3d_sw_entrapment = IEntrapmentExplicit. */
 mov x2,#6868
 add x2,x0,x2
 movz w3,#2
 str w3,[x2],#4
 /* config.do_3d_lw_multilayer_effects = .false.. */
 mov x2,#6872
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_lw_side_emissivity = .true.. */
 mov x2,#6876
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.max_3d_transfer_rate = 10.0_jprb. */
 mov x2,#6880
 add x2,x0,x2
 movz x3,#0
 movk x3,#16420,lsl #48
 str x3,[x2],#8
 /* config.min_cloud_effective_size = 100.0_jprb. */
 mov x2,#6888
 add x2,x0,x2
 movz x3,#0
 movk x3,#16473,lsl #48
 str x3,[x2],#8
 /* config.overhang_factor = 0.0_jprb. */
 mov x2,#6896
 add x2,x0,x2
 movz x3,#0
 str x3,[x2],#8
 /* config.use_expm_everywhere = .false.. */
 mov x2,#6904
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.use_aerosols = .false.. */
 mov x2,#6908
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_aerosol_types = 0. */
 mov x2,#6912
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_save_radiative_properties = .false.. */
 mov x2,#7940
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_save_spectral_flux = .false.. */
 mov x2,#7944
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_surface_sw_spectral_flux = .true.. */
 mov x2,#7948
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_lw_derivatives = .false.. */
 mov x2,#7952
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_save_gpoint_flux = .false.. */
 mov x2,#7956
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_setup_ifsrrtm = .true.. */
 mov x2,#7960
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_fu_lw_ice_optics_bug = .false.. */
 mov x2,#7964
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.iverbosesetup = 2. */
 mov x2,#7968
 add x2,x0,x2
 movz w3,#2
 str w3,[x2],#4
 /* config.iverbose = 1. */
 mov x2,#7972
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.do_canopy_fluxes_sw = .false.. */
 mov x2,#7976
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_canopy_fluxes_lw = .false.. */
 mov x2,#7980
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.use_canopy_full_spectrum_sw = .false.. */
 mov x2,#7984
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.use_canopy_full_spectrum_lw = .false.. */
 mov x2,#7988
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_canopy_gases_sw = .false.. */
 mov x2,#7992
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_canopy_gases_lw = .false.. */
 mov x2,#7996
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.ice_optics_override_file_name = ''. */
 mov x2,#8000
 add x2,x0,x2
 mov w3,#32
 mov x4,#511
.Lcfg_fill_66:
 strb w3,[x2],#1
 subs x4,x4,#1
 b.ne .Lcfg_fill_66
 /* config.liq_optics_override_file_name = ''. */
 mov x2,#8511
 add x2,x0,x2
 mov w3,#32
 mov x4,#511
.Lcfg_fill_67:
 strb w3,[x2],#1
 subs x4,x4,#1
 b.ne .Lcfg_fill_67
 /* config.aerosol_optics_override_file_name = ''. */
 mov x2,#9022
 add x2,x0,x2
 mov w3,#32
 mov x4,#511
.Lcfg_fill_68:
 strb w3,[x2],#1
 subs x4,x4,#1
 b.ne .Lcfg_fill_68
 /* config.cloud_pdf_override_file_name = ''. */
 mov x2,#9533
 add x2,x0,x2
 mov w3,#32
 mov x4,#511
.Lcfg_fill_69:
 strb w3,[x2],#1
 subs x4,x4,#1
 b.ne .Lcfg_fill_69
 /* config.is_consolidated = .false.. */
 mov x2,#10044
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_canopy_bands_sw = 1. */
 mov x2,#11120
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.n_canopy_bands_lw = 1. */
 mov x2,#11124
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.aerosol_optics.description_phobic_str = ' '. */
 mov x2,#13800
 add x2,x0,x2
 mov w3,#32
 mov x4,#2000
.Lcfg_fill_73:
 strb w3,[x2],#1
 subs x4,x4,#1
 b.ne .Lcfg_fill_73
 /* config.aerosol_optics.description_philic_str = ' '. */
 mov x2,#15800
 add x2,x0,x2
 mov w3,#32
 mov x4,#2000
.Lcfg_fill_74:
 strb w3,[x2],#1
 subs x4,x4,#1
 b.ne .Lcfg_fill_74
 /* config.aerosol_optics.n_bands_lw = 0. */
 mov x2,#17816
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.aerosol_optics.n_bands_sw = 0. */
 mov x2,#17820
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.aerosol_optics.n_mono_wl = 0. */
 mov x2,#17824
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.aerosol_optics.use_hydrophilic = .true.. */
 mov x2,#17828
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 /* config.aerosol_optics.use_monochromatic = .false.. */
 mov x2,#17832
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_g_sw = 0. */
 mov x2,#19996
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_g_lw = 0. */
 mov x2,#20000
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_bands_sw = 0. */
 mov x2,#20004
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_bands_lw = 0. */
 mov x2,#20008
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_spec_sw = 0. */
 mov x2,#20012
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_spec_lw = 0. */
 mov x2,#20016
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_g_lw_if_scattering = 0. */
 mov x2,#20020
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.n_bands_lw_if_scattering = 0. */
 mov x2,#20024
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.is_homogeneous = .false.. */
 mov x2,#20028
 add x2,x0,x2
 movz w3,#0
 str w3,[x2],#4
 /* config.do_clouds = .true.. */
 mov x2,#20032
 add x2,x0,x2
 movz w3,#1
 str w3,[x2],#4
 mov w0,#0
 ret
.Lcfg_bad:
 mov w0,#1
 ret
.size md2asm_initialize_ecrad_configuration_defaults,.-md2asm_initialize_ecrad_configuration_defaults
.section .rodata
.p2align 2
.Lcfg_null_offsets:
.word 10048,10112,10176,10240,10304,10368,10432,10520,10608,10672,10736,10800
.word 10864,10928,10992,11056,11128,11216,11304,11392,11480,11544,11608,11672
.word 11736,11824,11912,12000,12088,12176,12264,12376,12488,12600,12712,12824
.word 12936,13024,13112,13200,13288,13400,13512,13624,13736,17864
.section .note.GNU-stack,"",%progbits
