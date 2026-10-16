/* Contract: skills/md2asm/references/openifs/setup/legacy_radiation_parameters.md.
 * Complete selected SUPHY3 literal assignments. The source mode is NRAY1,
 * LRSTAERtrue, LRPROXfalse, LCLSATURfalse and NRAUTOEV0.
 * Parent x0 text,x1 length,x2 TPHY3 output5376,x3 capacity,x4 TPHY1096,
 * x5 capacity. Return0/2. FPCR0. All validation precedes mutation.
 * The48B parent frame preserves x18 and x19; raw children are leaves. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_declare_legacy_radiation_parameters
.type md2asm_declare_legacy_radiation_parameters,%function
md2asm_declare_legacy_radiation_parameters:
 cbz x0,.Llegacy_bad_leaf
 tst x0,#7
 b.ne .Llegacy_bad_leaf
 mov x9,#5376
 cmp x1,x9
 b.lo .Llegacy_bad_leaf
 adds x9,x0,x9
 b.cs .Llegacy_bad_leaf
 mov w9,#2
 str w9,[x0] /* N_SPBAND declaration */
 adr x9,.Llegacy_RTL
 ldr x9,[x9]
 str x9,[x0,#8] /* RTL255.8 K declaration */
 mov w0,#0
 ret
.size md2asm_declare_legacy_radiation_parameters,.-md2asm_declare_legacy_radiation_parameters
.p2align 4
.global md2asm_initialize_legacy_radiation_parameters
.type md2asm_initialize_legacy_radiation_parameters,%function
md2asm_initialize_legacy_radiation_parameters:
 cbz x0,.Llegacy_bad_leaf
 cbz x1,.Llegacy_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Llegacy_bad_leaf
 adds x9,x0,x1
 b.cs .Llegacy_bad_leaf
 cbz x2,.Llegacy_bad_leaf
 tst x2,#7
 b.ne .Llegacy_bad_leaf
 mov x10,#5376
 cmp x3,x10
 b.lo .Llegacy_bad_leaf
 adds x10,x2,x10
 b.cs .Llegacy_bad_leaf
 cmp x2,x9
 b.hs .Llegacy_text_disjoint
 cmp x0,x10
 b.lo .Llegacy_bad_leaf
.Llegacy_text_disjoint:
 cbz x4,.Llegacy_bad_leaf
 tst x4,#7
 b.ne .Llegacy_bad_leaf
 cmp x5,#1096
 b.lo .Llegacy_bad_leaf
 adds x9,x4,#1096
 b.cs .Llegacy_bad_leaf
 cmp x2,x9
 b.hs .Llegacy_PHY_disjoint
 cmp x4,x10
 b.lo .Llegacy_bad_leaf
.Llegacy_PHY_disjoint:
 mrs x9,fpcr
 cbnz x9,.Llegacy_bad_leaf
 ldr w9,[x2]
 cmp w9,#2
 b.ne .Llegacy_bad_leaf
 ldr x9,[x2,#8]
 adr x10,.Llegacy_RTL
 ldr x10,[x10]
 cmp x9,x10
 b.ne .Llegacy_bad_leaf
 ldr w9,[x4,#1016] /* NRAY */
 cmp w9,#1
 b.ne .Llegacy_bad_leaf
 ldr w9,[x4,#132] /* LRSTAER */
 cmp w9,#1
 b.ne .Llegacy_bad_leaf
 ldr w9,[x4,#120] /* LRPROX */
 cmp w9,#0
 b.ne .Llegacy_bad_leaf
 ldr w9,[x4,#92] /* LCLSATUR */
 cmp w9,#0
 b.ne .Llegacy_bad_leaf
 ldr w9,[x4,#1028] /* NRAUTOEV */
 cmp w9,#0
 b.ne .Llegacy_bad_leaf
 stp x29,x30,[sp,#-48]!
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x2
 adr x2,.Llegacy_group
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Llegacy_bad
 mov x0,x19
 bl md2asm_set_legacy_radiation_parameters_raw
 mov w0,#0
 b .Llegacy_return
.Llegacy_bad:
 mov w0,#2
.Llegacy_return:
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
.Llegacy_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_legacy_radiation_parameters,.-md2asm_initialize_legacy_radiation_parameters
.p2align 4
.global md2asm_set_legacy_radiation_parameters_raw
.type md2asm_set_legacy_radiation_parameters_raw,%function
md2asm_set_legacy_radiation_parameters_raw:
 /* x0 validated TPHY3. Literal stores keep all unassigned bytes. */
 adr x9,.Llegacy_table
 mov x10,#270
.Llegacy_store:
 ldp x11,x12,[x9],#16
 str x12,[x0,x11]
 subs x10,x10,#1
 b.ne .Llegacy_store
 ret
.size md2asm_set_legacy_radiation_parameters_raw,.-md2asm_set_legacy_radiation_parameters_raw
.section .rodata
.Llegacy_group: .ascii "NAMPHY3"
.p2align 3
.Llegacy_RTL: .quad 0x406ff9999999999a
.Llegacy_table:
 .quad 16,0x3fd65604189374bc /* BSFSA(1)=.3490E+00_JPRB */
 .quad 80,0x3fd636e2eb1c432d /* BSFTA(1)=.3471E+00_JPRB */
 .quad 152,0x3fb1389b52007dd4 /* EOASA(1)=.6727E-01_JPRB */
 .quad 216,0x3fa9ca18bd66277c /* EOATA(1)=.5037E-01_JPRB */
 .quad 280,0x3fd774bc6a7ef9db /* EODSA(1)=.3665E+00_JPRB */
 .quad 344,0x3f92157689ca18bd /* EODTA(1)=.1766E-01_JPRB */
 .quad 624,0xbfd353f7ced91687 /* USAA(1)=-.3020E+00_JPRB */
 .quad 24,0x0000000000000000 /* BSFSA(2:6)=0._JPRB */
 .quad 32,0x0000000000000000 /* BSFSA(2:6)=0._JPRB */
 .quad 40,0x0000000000000000 /* BSFSA(2:6)=0._JPRB */
 .quad 48,0x0000000000000000 /* BSFSA(2:6)=0._JPRB */
 .quad 56,0x0000000000000000 /* BSFSA(2:6)=0._JPRB */
 .quad 88,0x0000000000000000 /* BSFTA(2:6)=0._JPRB */
 .quad 96,0x0000000000000000 /* BSFTA(2:6)=0._JPRB */
 .quad 104,0x0000000000000000 /* BSFTA(2:6)=0._JPRB */
 .quad 112,0x0000000000000000 /* BSFTA(2:6)=0._JPRB */
 .quad 120,0x0000000000000000 /* BSFTA(2:6)=0._JPRB */
 .quad 160,0x0000000000000000 /* EOASA(2:6)=0._JPRB */
 .quad 168,0x0000000000000000 /* EOASA(2:6)=0._JPRB */
 .quad 176,0x0000000000000000 /* EOASA(2:6)=0._JPRB */
 .quad 184,0x0000000000000000 /* EOASA(2:6)=0._JPRB */
 .quad 192,0x0000000000000000 /* EOASA(2:6)=0._JPRB */
 .quad 224,0x0000000000000000 /* EOATA(2:6)=0._JPRB */
 .quad 232,0x0000000000000000 /* EOATA(2:6)=0._JPRB */
 .quad 240,0x0000000000000000 /* EOATA(2:6)=0._JPRB */
 .quad 248,0x0000000000000000 /* EOATA(2:6)=0._JPRB */
 .quad 256,0x0000000000000000 /* EOATA(2:6)=0._JPRB */
 .quad 288,0x0000000000000000 /* EODSA(2:6)=0._JPRB */
 .quad 296,0x0000000000000000 /* EODSA(2:6)=0._JPRB */
 .quad 304,0x0000000000000000 /* EODSA(2:6)=0._JPRB */
 .quad 312,0x0000000000000000 /* EODSA(2:6)=0._JPRB */
 .quad 320,0x0000000000000000 /* EODSA(2:6)=0._JPRB */
 .quad 352,0x0000000000000000 /* EODTA(2:6)=0._JPRB */
 .quad 360,0x0000000000000000 /* EODTA(2:6)=0._JPRB */
 .quad 368,0x0000000000000000 /* EODTA(2:6)=0._JPRB */
 .quad 376,0x0000000000000000 /* EODTA(2:6)=0._JPRB */
 .quad 384,0x0000000000000000 /* EODTA(2:6)=0._JPRB */
 .quad 632,0x0000000000000000 /* USAA(2:6)=0._JPRB */
 .quad 640,0x0000000000000000 /* USAA(2:6)=0._JPRB */
 .quad 648,0x0000000000000000 /* USAA(2:6)=0._JPRB */
 .quad 656,0x0000000000000000 /* USAA(2:6)=0._JPRB */
 .quad 664,0x0000000000000000 /* USAA(2:6)=0._JPRB */
 .quad 64,0x3fd4b923a29c779a /* BSFSI=.3238_JPRB */
 .quad 72,0x3fd51eb851eb851f /* BSFSN=.3300_JPRB */
 .quad 128,0x3fd4adab9f559b3d /* BSFTI=.3231_JPRB */
 .quad 136,0x3fd6f0068db8bac7 /* BSFTN=.3584_JPRB */
 .quad 144,0x3f55b1422ccb3a26 /* EARRT=0.001324_JPRB */
 .quad 200,0x3f915379fa97e133 /* EOASI=.1692E-01_JPRB */
 .quad 208,0x3fa12ad81adea897 /* EOASN=.3353E-01_JPRB */
 .quad 264,0x400ba3d70a3d70a4 /* EOATI=.3455E+01_JPRB */
 .quad 272,0x4022276c8b439581 /* EOATN=.9077E+01_JPRB */
 .quad 328,0x3ff67ef9db22d0e5 /* EODSI=.1406E+01_JPRB */
 .quad 336,0x401a3b645a1cac08 /* EODSN=.6558E+01_JPRB */
 .quad 392,0x3feafdf3b645a1cb /* EODTI=.8435E+00_JPRB */
 .quad 400,0x401146a7ef9db22d /* EODTN=.4319E+01_JPRB */
 .quad 672,0xbfd68db8bac710cb /* USAI=-.3524_JPRB */
 .quad 680,0xbfd5c28f5c28f5c3 /* USAN=-.3400_JPRB */
 .quad 688,0x0000000000000000 /* USBA=0._JPRB */
 .quad 696,0x0000000000000000 /* USBI=0._JPRB */
 .quad 704,0x0000000000000000 /* USBN=0._JPRB */
 .quad 416,0x3fb495bff04577d9 /* GCA(1)=.8041E-01_JPRB */
 .quad 424,0x3fc2a305532617c2 /* GCA(2)=.1456E+00_JPRB */
 .quad 432,0x401325e353f7ced9 /* GCA(3)=.4787E+01_JPRB */
 .quad 440,0x40a06c0000000000 /* GCA(4)=.2102E+04_JPRB */
 .quad 448,0x3ff55810624dd2f2 /* GCA(5)=.1334E+01_JPRB */
 .quad 456,0x3ef0436f158c8432 /* GCA(6)=.1551E-04_JPRB */
 .quad 464,0x41611ae800000000 /* GCB(1)=.8968E+07_JPRB */
 .quad 472,0x41e1fa6ea8000000 /* GCB(2)=.2413E+10_JPRB */
 .quad 480,0x40e1530000000000 /* GCB(3)=.3548E+05_JPRB */
 .quad 488,0x41f7bae7c8000000 /* GCB(4)=.6370E+10_JPRB */
 .quad 496,0x4233c9cc7b800000 /* GCB(5)=.8499E+11_JPRB */
 .quad 504,0x40f8b50000000000 /* GCB(6)=.1012E+06_JPRB */
 .quad 512,0x3dd049591c9781b2 /* GCC(1)=.5925E-10_JPRB */
 .quad 520,0x3db440c4e1d67578 /* GCC(2)=.1842E-10_JPRB */
 .quad 528,0x3e5b2fe89a4294db /* GCC(3)=.2532E-07_JPRB */
 .quad 536,0x413dcce800000000 /* GCC(4)=.1953E+07_JPRB */
 .quad 544,0x3d7e813de394bc46 /* GCC(5)=.1734E-11_JPRB */
 .quad 552,0x3c6c3f1fa949f79f /* GCC(6)=.1225E-16_JPRB */
 .quad 560,0x3183ebd3ce5fe518 /* GCD4  =.3608E-69_JPRD */
 .quad 568,0x40bd8b0000000000 /* GCE4=.7563E+04_JPRB */
 .quad 576,0x0000000000000000 /* GIREC1=0.0_JPRB */
 .quad 584,0x0000000000000000 /* GIREC2=0.0_JPRB */
 .quad 592,0x0000000000000000 /* GIREC3=0.0_JPRB */
 .quad 600,0x0000000000000000 /* GIREC4=0.0_JPRB */
 .quad 712,0x4035de353f7ced91 /* VDP(1,1)=.21868E+02_JPRB */
 .quad 720,0x403173f7ced91687 /* VDP(2,1)=.17453E+02_JPRB */
 .quad 728,0x3fe60dc33721d53d /* VDP(3,1)=.68918E+00_JPRB */
 .quad 736,0x3f2ebe870ed280c1 /* VDP(4,1)=.23456E-03_JPRB */
 .quad 744,0x3deeac18a85dc099 /* VDP(5,1)=.22317E-09_JPRB */
 .quad 752,0x40483353f7ced917 /* VDP(1,2)=.48401E+02_JPRB */
 .quad 760,0x4032a5e353f7ced9 /* VDP(2,2)=.18648E+02_JPRB */
 .quad 768,0x3fa2059a73b42cc3 /* VDP(3,2)=.35199E-01_JPRB */
 .quad 776,0x3ea55f03e6d564b3 /* VDP(4,2)=.63691E-06_JPRB */
 .quad 784,0x3d38516a74499b1b /* VDP(5,2)=.86395E-13_JPRB */
 .quad 792,0x40533cac083126e9 /* VDP(1,3)=.76948E+02_JPRB */
 .quad 800,0x40106c226809d495 /* VDP(2,3)=.41056E+01_JPRB */
 .quad 808,0x3f3bf655b23922b6 /* VDP(3,3)=.42667E-03_JPRB */
 .quad 816,0x0000000000000000 /* VDP(4,3)=0._JPRB */
 .quad 824,0x0000000000000000 /* VDP(5,3)=0._JPRB */
 .quad 832,0x4071068f5c28f5c3 /* VDP(1,4)=.27241E+03_JPRB */
 .quad 840,0x40b64d199999999a /* VDP(2,4)=.57091E+04_JPRB */
 .quad 848,0x40cc1c8000000000 /* VDP(3,4)=.14393E+05_JPRB */
 .quad 856,0x40a757cccccccccd /* VDP(4,4)=.29879E+04_JPRB */
 .quad 864,0x403961cac083126f /* VDP(5,4)=.25382E+02_JPRB */
 .quad 872,0x4055bc49ba5e353f /* VDP(1,5)=.86942E+02_JPRB */
 .quad 880,0x40741dc28f5c28f6 /* VDP(2,5)=.32186E+03_JPRB */
 .quad 888,0x405af00000000000 /* VDP(3,5)=.10775E+03_JPRB */
 .quad 896,0x40010240b780346e /* VDP(4,5)=.21261E+01_JPRB */
 .quad 904,0x3f70629e5ac97a32 /* VDP(5,5)=.40003E-02_JPRB */
 .quad 912,0x40386872b020c49c /* VDP(1,6)=.24408E+02_JPRB */
 .quad 920,0x40206240b780346e /* VDP(2,6)=.81919E+01_JPRB */
 .quad 928,0x401ce0902de00d1b /* VDP(3,6)=.72193E+01_JPRB */
 .quad 936,0x3fe1fe5c91d14e3c /* VDP(4,6)=.56230E+00_JPRB */
 .quad 944,0x3f64cb691f7e4a89 /* VDP(5,6)=.25384E-02_JPRB */
 .quad 952,0x401bf86c226809d5 /* VNP(1,1)=.69926E+01_JPRB */
 .quad 960,0x3fe473eab367a0f9 /* VNP(2,1)=.63915E+00_JPRB */
 .quad 968,0x3f32eff1bff64fa8 /* VNP(3,1)=.28896E-03_JPRB */
 .quad 976,0x3e11440968084ff9 /* VNP(4,1)=.10050E-08_JPRB */
 .quad 984,0x3c9c8ba40996b4ca /* VNP(5,1)=.99037E-16_JPRB */
 .quad 992,0x4008e24dd2f1a9fc /* VNP(1,2)=.31105E+01_JPRB */
 .quad 1000,0x3f8d21ff2e48e8a7 /* VNP(2,2)=.14225E-01_JPRB */
 .quad 1008,0x3ea7458c94320285 /* VNP(3,2)=.69355E-06_JPRB */
 .quad 1016,0x3d5964db222b1533 /* VNP(4,2)=.36087E-12_JPRB */
 .quad 1024,0x3bb4d4ef394c96af /* VNP(5,2)=.44113E-20_JPRB */
 .quad 1032,0x4002ed5cfaacd9e8 /* VNP(1,3)=.23659E+01_JPRB */
 .quad 1040,0x3f524009048b7ffb /* VNP(2,3)=.11139E-02_JPRB */
 .quad 1048,0x3eb1d065724578cd /* VNP(3,3)=.10618E-05_JPRB */
 .quad 1056,0x0000000000000000 /* VNP(4,3)=0._JPRB */
 .quad 1064,0x0000000000000000 /* VNP(5,3)=0._JPRB */
 .quad 1072,0x4068c33333333333 /* VNP(1,4)=.19810E+03_JPRB */
 .quad 1080,0x40b2576666666666 /* VNP(2,4)=.46954E+04_JPRB */
 .quad 1088,0x40a1966666666666 /* VNP(3,4)=.22512E+04_JPRB */
 .quad 1096,0x404a3b020c49ba5e /* VNP(4,4)=.52461E+02_JPRB */
 .quad 1104,0x3fbdcfaacd9e83e4 /* VNP(5,4)=.11645E+00_JPRB */
 .quad 1112,0x40472c8b43958106 /* VNP(1,5)=.46348E+02_JPRB */
 .quad 1120,0x4041d0a3d70a3d71 /* VNP(2,5)=.35630E+02_JPRB */
 .quad 1128,0x400a676c8b439581 /* VNP(3,5)=.33005E+01_JPRB */
 .quad 1136,0x3f927a63736cdf26 /* VNP(4,5)=.18045E-01_JPRB */
 .quad 1144,0x3ee29845f800030f /* VNP(5,5)=.88667E-05_JPRB */
 .quad 1152,0x4012f71758e21965 /* VNP(1,6)=.47413E+01_JPRB */
 .quad 1160,0x3ffa226809d49518 /* VNP(2,6)=.16334E+01_JPRB */
 .quad 1168,0x3fded330941c8217 /* VNP(3,6)=.48164E+00_JPRB */
 .quad 1176,0x3f76feb4a66559f7 /* VNP(4,6)=.56140E-02_JPRB */
 .quad 1184,0x3f11c54f54fcdc8a /* VNP(5,6)=.67790E-04_JPRB */
 .quad 2392,0x0000000000000000 /* GOLCA(1)=0._JPRB */
 .quad 2440,0x0000000000000000 /* GOLCB(1)=0._JPRB */
 .quad 2488,0x0000000000000000 /* GOLCC(1)=0._JPRB */
 .quad 2400,0x0000000000000000 /* GOLCA(2)=0._JPRB */
 .quad 2448,0x0000000000000000 /* GOLCB(2)=0._JPRB */
 .quad 2496,0x0000000000000000 /* GOLCC(2)=0._JPRB */
 .quad 2408,0x0000000000000000 /* GOLCA(3)=0._JPRB */
 .quad 2456,0x0000000000000000 /* GOLCB(3)=0._JPRB */
 .quad 2504,0x0000000000000000 /* GOLCC(3)=0._JPRB */
 .quad 2416,0x0000000000000000 /* GOLCA(4)=0._JPRB */
 .quad 2464,0x409a090000000000 /* GOLCB(4)=1.66625E+03_JPRB */
 .quad 2512,0x41f2b6e349000000 /* GOLCC(4)=5.02361E+09_JPRB */
 .quad 2424,0x0000000000000000 /* GOLCA(5)=0._JPRB */
 .quad 2472,0x40c2a59ae147ae14 /* GOLCB(5)=9.54721E+03_JPRB */
 .quad 2520,0x42cce0001aac0000 /* GOLCC(5)=6.34968E+13_JPRB */
 .quad 2432,0x0000000000000000 /* GOLCA(6)=0._JPRB */
 .quad 2480,0x420bbcea79000000 /* GOLCB(6)=1.48917E+10_JPRB */
 .quad 2528,0x42d0c7f9c566c000 /* GOLCC(6)=7.38043E+13_JPRB */
 .quad 608,0x3f419553b9bb7811 /* QCO2=.5366E-03_JPRB */
 .quad 408,0x3eace07f69ea14e1 /* EORAY=.8606E-06_JPRB */
 .quad 1200,0x3fee936c58eeae9f /* FCM_DEL_A(1) = 9.55496E-01_JPRB */
 .quad 1208,0x406664dd2f1a9fbe /* FCM_DEL_A(2) = 1.79152E+02_JPRB */
 .quad 1216,0x404ca5e00d1b7176 /* FCM_DEL_D(1) = 5.72959E+01_JPRB */
 .quad 1224,0x40690516872b020c /* FCM_DEL_D(2) = 2.00159E+02_JPRB */
 .quad 1232,0x3febb7e90ff97247 /* FCM_MU_A(1)  = 8.66200E-01_JPRB */
 .quad 1240,0x3fe54c09c3ce208a /* FCM_MU_A(2)  = 6.65532E-01_JPRB */
 .quad 1248,0x3ff0000000000000 /* FCM_MU_D(1)  = 1.00000E+00_JPRB */
 .quad 1256,0x3fe574e0114d2f5e /* FCM_MU_D(2)  = 6.70517E-01_JPRB */
 .quad 1264,0x3fb999999999999a /* FCM_N_I      = 1.00000E-01_JPRB */
 .quad 1272,0x3fb999999999999a /* FCM_N_L      = 1.00000E-01_JPRB */
 .quad 1616,0x402dc8b439581062 /* FCM_P_AI(1,0)= 1.48920E+01_JPRB */
 .quad 1632,0xc04291a6b50b0f28 /* FCM_P_AI(1,1)=-3.71379E+01_JPRB */
 .quad 1648,0x0000000000000000 /* FCM_P_AI(1,2)= 0.00000E+00_JPRB */
 .quad 1664,0x0000000000000000 /* FCM_P_AI(1,3)= 0.00000E+00_JPRB */
 .quad 1624,0x402389d495182a99 /* FCM_P_AI(2,0)= 9.76920E+00_JPRB */
 .quad 1640,0xc01e318fc504816f /* FCM_P_AI(2,1)=-7.54840E+00_JPRB */
 .quad 1656,0x0000000000000000 /* FCM_P_AI(2,2)= 0.00000E+00_JPRB */
 .quad 1672,0x0000000000000000 /* FCM_P_AI(2,3)= 0.00000E+00_JPRB */
 .quad 1680,0x3ff6badc0980b242 /* FCM_P_AL(1,0)= 1.42062E+00_JPRB */
 .quad 1696,0xc00c52ad81adea89 /* FCM_P_AL(1,1)=-3.54037E+00_JPRB */
 .quad 1712,0x3ffbc3fe5c91d14e /* FCM_P_AL(1,2)= 1.73535E+00_JPRB */
 .quad 1728,0x0000000000000000 /* FCM_P_AL(1,3)= 0.00000E+00_JPRB */
 .quad 1688,0x40145743e963dc48 /* FCM_P_AL(2,0)= 5.08522E+00_JPRB */
 .quad 1704,0xc025a0f9096bb98c /* FCM_P_AL(2,1)=-1.08144E+01_JPRB */
 .quad 1720,0x4014a73abc947065 /* FCM_P_AL(2,2)= 5.16331E+00_JPRB */
 .quad 1736,0x0000000000000000 /* FCM_P_AL(2,3)= 0.00000E+00_JPRB */
 .quad 1744,0x402a18ef34d6a162 /* FCM_P_DI(1,0)= 1.30487E+01_JPRB */
 .quad 1760,0x4033ddf3b645a1cb /* FCM_P_DI(1,1)= 1.98670E+01_JPRB */
 .quad 1776,0xc0496dcc63f14120 /* FCM_P_DI(1,2)=-5.08578E+01_JPRB */
 .quad 1792,0x0000000000000000 /* FCM_P_DI(1,3)= 0.00000E+00_JPRB */
 .quad 1752,0x4028a27525460aa6 /* FCM_P_DI(2,0)= 1.23173E+01_JPRB */
 .quad 1768,0xc040a3f141205bc0 /* FCM_P_DI(2,1)=-3.32808E+01_JPRB */
 .quad 1784,0x404cdd604189374c /* FCM_P_DI(2,2)= 5.77295E+01_JPRB */
 .quad 1800,0xc05264a8c154c986 /* FCM_P_DI(2,3)=-7.35728E+01_JPRB */
 .quad 1808,0x4012beef5ec80c74 /* FCM_P_DL(1,0)= 4.68646E+00_JPRB */
 .quad 1824,0xc0218d940789613d /* FCM_P_DL(1,1)=-8.77652E+00_JPRB */
 .quad 1840,0x400105eb313be22e /* FCM_P_DL(1,2)= 2.12789E+00_JPRB */
 .quad 1856,0x0000000000000000 /* FCM_P_DL(1,3)= 0.00000E+00_JPRB */
 .quad 1816,0x401217785729b281 /* FCM_P_DL(2,0)= 4.52292E+00_JPRB */
 .quad 1832,0xc02caa57a786c227 /* FCM_P_DL(2,1)=-1.43327E+01_JPRB */
 .quad 1848,0x4027547ae147ae14 /* FCM_P_DL(2,2)= 1.16650E+01_JPRB */
 .quad 1864,0x0000000000000000 /* FCM_P_DL(2,3)= 0.00000E+00_JPRB */
 .quad 1872,0xc0001e2584f4c6e7 /* FCM_P_GI(1,0)=-2.01472E+00_JPRB */
 .quad 1888,0x4056e837b4a2339c /* FCM_P_GI(1,1)= 9.16284E+01_JPRB */
 .quad 1904,0x40538e8f5c28f5c3 /* FCM_P_GI(1,2)= 7.82275E+01_JPRB */
 .quad 1920,0x0000000000000000 /* FCM_P_GI(1,3)= 0.00000E+00_JPRB */
 .quad 1880,0xbfe829f9ce8d972d /* FCM_P_GI(2,0)=-7.55124E-01_JPRB */
 .quad 1896,0xc012c0e410b630a9 /* FCM_P_GI(2,1)=-4.68837E+00_JPRB */
 .quad 1912,0x4050d269ad42c3ca /* FCM_P_GI(2,2)= 6.72877E+01_JPRB */
 .quad 1928,0x0000000000000000 /* FCM_P_GI(2,3)= 0.00000E+00_JPRB */
 .quad 1936,0x3fec3ef6b5d462c3 /* FCM_P_GL(1,0)= 8.82686E-01_JPRB */
 .quad 1952,0xc0003212d77318fc /* FCM_P_GL(1,1)=-2.02445E+00_JPRB */
 .quad 1968,0x3ff73dcf0307f23d /* FCM_P_GL(1,2)= 1.45259E+00_JPRB */
 .quad 1984,0x0000000000000000 /* FCM_P_GL(1,3)= 0.00000E+00_JPRB */
 .quad 1944,0x3fc8cdea033e78e2 /* FCM_P_GL(2,0)= 1.93784E-01_JPRB */
 .quad 1960,0xbfe37214f0520d13 /* FCM_P_GL(2,1)=-6.07676E-01_JPRB */
 .quad 1976,0x3fe1351deefe4ffd /* FCM_P_GL(2,2)= 5.37734E-01_JPRB */
 .quad 1992,0x0000000000000000 /* FCM_P_GL(2,3)= 0.00000E+00_JPRB */
 .quad 2000,0x4032a8a71de69ad4 /* FCM_Q_AI(1,1)= 1.86588E+01_JPRB */
 .quad 2016,0x0000000000000000 /* FCM_Q_AI(1,2)= 0.00000E+00_JPRB */
 .quad 2032,0x0000000000000000 /* FCM_Q_AI(1,3)= 0.00000E+00_JPRB */
 .quad 2008,0x40063ebaf102363b /* FCM_Q_AI(2,1)= 2.78063E+00_JPRB */
 .quad 2024,0x0000000000000000 /* FCM_Q_AI(2,2)= 0.00000E+00_JPRB */
 .quad 2040,0x0000000000000000 /* FCM_Q_AI(2,3)= 0.00000E+00_JPRB */
 .quad 2048,0xc0067f2e48e8a71e /* FCM_Q_AL(1,1)=-2.81210E+00_JPRB */
 .quad 2064,0x4002dc52e72da123 /* FCM_Q_AL(1,2)= 2.35758E+00_JPRB */
 .quad 2080,0x0000000000000000 /* FCM_Q_AL(1,3)= 0.00000E+00_JPRB */
 .quad 2056,0xc002800a7c5ac472 /* FCM_Q_AL(2,1)=-2.31252E+00_JPRB */
 .quad 2072,0x3ff9187e7c06e19c /* FCM_Q_AL(2,2)= 1.56848E+00_JPRB */
 .quad 2088,0x0000000000000000 /* FCM_Q_AL(2,3)= 0.00000E+00_JPRB */
 .quad 2096,0x4024ea9930be0ded /* FCM_Q_DI(1,1)= 1.04582E+01_JPRB */
 .quad 2112,0x4018a029f16b11c7 /* FCM_Q_DI(1,2)= 6.15641E+00_JPRB */
 .quad 2128,0x0000000000000000 /* FCM_Q_DI(1,3)= 0.00000E+00_JPRB */
 .quad 2104,0x3ff2f06f69446738 /* FCM_Q_DI(2,1)= 1.18370E+00_JPRB */
 .quad 2120,0x4001dadea897635e /* FCM_Q_DI(2,2)= 2.23187E+00_JPRB */
 .quad 2136,0x401c04577d955715 /* FCM_Q_DI(2,3)= 7.00424E+00_JPRB */
 .quad 2144,0xc00174d6a161e4f7 /* FCM_Q_DL(1,1)=-2.18205E+00_JPRB */
 .quad 2160,0x3ff592ad81adea89 /* FCM_Q_DL(1,2)= 1.34831E+00_JPRB */
 .quad 2176,0x0000000000000000 /* FCM_Q_DL(1,3)= 0.00000E+00_JPRB */
 .quad 2152,0xc008fc1bda5119ce /* FCM_Q_DL(2,1)=-3.12310E+00_JPRB */
 .quad 2168,0x4004a30014f8b589 /* FCM_Q_DL(2,2)= 2.57959E+00_JPRB */
 .quad 2184,0x0000000000000000 /* FCM_Q_DL(2,3)= 0.00000E+00_JPRB */
 .quad 2192,0x4053bffe5c91d14e /* FCM_Q_GI(1,1)= 7.89999E+01_JPRB */
 .quad 2208,0x404a3f1758e21965 /* FCM_Q_GI(1,2)= 5.24929E+01_JPRB */
 .quad 2224,0x0000000000000000 /* FCM_Q_GI(1,3)= 0.00000E+00_JPRB */
 .quad 2200,0x4013c085b18548aa /* FCM_Q_GI(2,1)= 4.93801E+00_JPRB */
 .quad 2216,0x4037cf41f212d773 /* FCM_Q_GI(2,2)= 2.38096E+01_JPRB */
 .quad 2232,0x0000000000000000 /* FCM_Q_GI(2,3)= 0.00000E+00_JPRB */
 .quad 2240,0xc001aa9930be0ded /* FCM_Q_GL(1,1)=-2.20830E+00_JPRB */
 .quad 2256,0x3ff65f84cad57bc8 /* FCM_Q_GL(1,2)= 1.39832E+00_JPRB */
 .quad 2272,0x0000000000000000 /* FCM_Q_GL(1,3)= 0.00000E+00_JPRB */
 .quad 2248,0xc00a38bac710cb29 /* FCM_Q_GL(2,1)=-3.27770E+00_JPRB */
 .quad 2264,0x40064692f6e8294a /* FCM_Q_GL(2,2)= 2.78446E+00_JPRB */
 .quad 2280,0x0000000000000000 /* FCM_Q_GL(2,3)= 0.00000E+00_JPRB */
 .quad 1192,0x4020000000000000 /* REXP_NEB     = 8._JPRB */
 .quad 5360,0x4000000000000000 /* RMIXD =2.0_JPRB */
 .quad 5368,0x3fb999999999999a /* RMIXP0=0.1_JPRB */
 .quad 2336,0x3fd28f5c28f5c28f /* FSM_CC=0.29_JPRB */
 .quad 2344,0x4000000000000000 /* FSM_DD=2.0_JPRB */
 .quad 2352,0x3fb1eb851eb851ec /* FSM_EE=0.07_JPRB */
 .quad 2360,0x3ff8000000000000 /* FSM_FF=1.5_JPRB */
 .quad 2368,0x3fc1eb851eb851ec /* FSM_GG=0.14_JPRB */
 .quad 2376,0x4034000000000000 /* FSM_HH=20._JPRB */
 .quad 2384,0x0000000000000000 /* FSM_II=0._JPRB */
 .quad 5344,0x0000000000000000 /* RLAMB_SOLID=0._JPRB */
 .quad 5352,0x0000000000000000 /* RLAMB_WATER=0._JPRB */
.section .note.GNU-stack,"",%progbits
