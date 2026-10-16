/* Selected ECMWF/NCONF1 defaults from SU0PHY, before NAEPHY.
 * x0 writable TEPHY[448],8-byte aligned. w1 LSLAG in0..1.
 * Preserve source-unwritten members and padding. No calls or FP arithmetic.
 * Contract: skills/md2asm/references/openifs/setup/selected_physics_controls.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_default_selected_physics_controls
.type md2asm_default_selected_physics_controls,%function
md2asm_default_selected_physics_controls:
 cbz x0,.Ldefaults_bad
 tst x0,#7
 b.ne .Ldefaults_bad
 cmp w1,#1
 b.hi .Ldefaults_bad
 mov w9,#1
 mov w10,#0
 str w9,[x0,#0] /* LEPHYS */
 str w10,[x0,#4] /* LECOND */
 str w9,[x0,#8] /* LECUMF */
 str w9,[x0,#12] /* LEDCLD */
 str w9,[x0,#16] /* LEEVAP */
 str w9,[x0,#20] /* LEGWDG */
 str w9,[x0,#24] /* LEGWWMS */
 str w9,[x0,#28] /* LEOZOC */
 str w9,[x0,#32] /* LEQNGT */
 str w9,[x0,#36] /* LERADI */
 str w9,[x0,#40] /* LERADIMPL */
 str w9,[x0,#44] /* LERADS */
 str w9,[x0,#48] /* LESICE */
 str w9,[x0,#52] /* LESURF */
 str w9,[x0,#56] /* LEVDIF */
 str w10,[x0,#60] /* LEVDIFSL */
 str w9,[x0,#64] /* LAGPHY */
 str w9,[x0,#68] /* LEPCLD */
 str w10,[x0,#72] /* LEO3CH */
 str w9,[x0,#76] /* LO3CH_SAFE */
 str w10,[x0,#80] /* LO3CH_OLDVER */
 str w10,[x0,#84] /* LO3CH_BMS */
 str w9,[x0,#88] /* LO3CH_HLO */
 movz w11,#12616
 movk w11,#12334,lsl#16
 str w11,[x0,#92] /* CO3CHEM */
 str w9,[x0,#96] /* LNEEONLINE */
 str w10,[x0,#100] /* LWETONLINE */
 str w10,[x0,#104] /* LBUD23 */
 str w10,[x0,#108] /* LPPTILES */
 str w10,[x0,#112] /* LBUDCYCLE */
 str w10,[x0,#116] /* LEXTRATEND */
 str w9,[x0,#120] /* LEMETHOX */
 str w10,[x0,#124] /* LECURR */
 str w10,[x0,#128] /* LESURFTRAJ */
 str w9,[x0,#132] /* LVDFTRAC */
 str w10,[x0,#136] /* LVDFNEWTRAC */
 str w9,[x0,#140] /* LMFTRAC */
 str w9,[x0,#144] /* LMFSCAV */
 str w10,[x0,#148] /* LERAIN */
 str w10,[x0,#152] /* LEMWAVE */
 str w10,[x0,#156] /* LEGBRAD */
 str w10,[x0,#160] /* LERAINGG */
 str w10,[x0,#164] /* LESMOS */
 str w10,[x0,#168] /* LESMAP */
 str w9,[x0,#172] /* LEOCWA */
 str w9,[x0,#176] /* LEOCCO */
 str w9,[x0,#180] /* LEOCSA */
 str w9,[x0,#184] /* LEOCLA */
 str w9,[x0,#188] /* LEVGEN */
 str w9,[x0,#192] /* LESSRO */
 str w9,[x0,#196] /* LEFLAKE */
 str w10,[x0,#200] /* LEOCML */
 str w10,[x0,#204] /* LEOBC */
 str w9,[x0,#208] /* LEOBCMAX */
 /* REOBCMAX = 50.0, source FP64 literal. */
 movz x11,#0
 movk x11,#16457,lsl#48
 str x11,[x0,#216]
 str w10,[x0,#224] /* LEOBCICE */
 str w10,[x0,#228] /* LEOCLAKE */
 str w9,[x0,#232] /* LEOLAKESST */
 str w10,[x0,#236] /* LOCMLTKE */
 str w10,[x0,#240] /* LECLIPQT0 */
 str w10,[x0,#244] /* LECLIPCLDT0 */
 str w10,[x0,#248] /* LDUCTDIA */
 str w10,[x0,#252] /* LDIAGTURB_EC */
 str w10,[x0,#256] /* LDIAGTURBGRAD_EC */
 str w1,[x0,#260]
 str w9,[x0,#264] /* LESN09 */
 str w9,[x0,#268] /* LELAIV */
 str w9,[x0,#272] /* LECTESSEL */
 str w10,[x0,#276] /* LEAGS */
 str w9,[x0,#280] /* LEFARQUHAR */
 str w10,[x0,#284] /* LEOPTSURF */
 str w9,[x0,#288] /* LEC4MAP */
 str w10,[x0,#292] /* LEAIRCO2COUP */
 str w10,[x0,#296] /* LELIGHT */
 str w10,[x0,#300] /* LVEXTRDYNACC */
 /* RTHRFRTI = 0.0, source FP64 literal. */
 movz x11,#0
 str x11,[x0,#304]
 /* RCIMIN = -1.0, source FP64 literal. */
 movz x11,#0
 movk x11,#49136,lsl#48
 str x11,[x0,#312]
 /* RLAIINT = 0.0, source FP64 literal. */
 movz x11,#0
 str x11,[x0,#320]
 movz w11,#21600
 str w11,[x0,#328] /* NPRACCL */
 movz w11,#6
 str w11,[x0,#332] /* NLIMODE */
 str w10,[x0,#340] /* LESNML */
 str w10,[x0,#344] /* LEURBAN */
 str w10,[x0,#348] /* NSNMLWS */
 str w10,[x0,#352] /* LBFASCO2 */
 str w10,[x0,#356] /* NCO2CLIMYY1 */
 str w10,[x0,#360] /* NCO2CLIMYY2 */
 str w10,[x0,#364] /* NCO2CLIMN1 */
 str w10,[x0,#368] /* NCO2CLIMN2 */
 str w10,[x0,#372] /* NCO2CLIMFRQ */
 movz w11,#2
 str w11,[x0,#376] /* NALBEDOSCHEME */
 str w10,[x0,#380] /* NEMISSSCHEME */
 /* RALFMINPSN = 0.82, source FP64 literal. */
 movz x11,#2621
 movk x11,#41943,lsl#16
 movk x11,#15728,lsl#32
 movk x11,#16362,lsl#48
 str x11,[x0,#384]
 /* RNORTHML = 40.0, source FP64 literal. */
 movz x11,#0
 movk x11,#16452,lsl#48
 str x11,[x0,#392]
 /* RSOUTHML = -40.0, source FP64 literal. */
 movz x11,#0
 movk x11,#49220,lsl#48
 str x11,[x0,#400]
 /* RWESTML = 0.0, source FP64 literal. */
 movz x11,#0
 str x11,[x0,#408]
 /* REASTML = 360.0, source FP64 literal. */
 movz x11,#0
 movk x11,#32768,lsl#32
 movk x11,#16502,lsl#48
 str x11,[x0,#416]
 str w10,[x0,#424] /* INVML */
 str w10,[x0,#436] /* LRAD_CLOUD_INHOMOG */
 mov w0,#0
 ret
.Ldefaults_bad:
 mov w0,#2
 ret
.size md2asm_default_selected_physics_controls,.-md2asm_default_selected_physics_controls
