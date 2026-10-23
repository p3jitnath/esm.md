/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Direct operational SUDYNCORE with the admitted LAQUA=false input.
 * Contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md.
 * Every accepted default and arithmetic instruction remains unchanged. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_dynamical_configuration
.type md2asm_initialize_operational_dynamical_configuration,%function
md2asm_initialize_operational_dynamical_configuration:
 cbz x0,.Ldyn_bad_leaf
 cbz x1,.Ldyn_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Ldyn_bad_leaf
 adds x9,x0,x1
 b.cs .Ldyn_bad_leaf
 cbz x2,.Ldyn_bad_leaf
 tst x2,#7
 b.ne .Ldyn_bad_leaf
 cmp x3,#320
 b.lo .Ldyn_bad_leaf
 adds x10,x2,#320
 b.cs .Ldyn_bad_leaf
 cmp x2,x9
 b.hs .Ldyn_disjoint
 cmp x0,x10
 b.lo .Ldyn_bad_leaf
.Ldyn_disjoint:
 mrs x9,fpcr
 cbnz x9,.Ldyn_bad_leaf
 stp x29,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x2
 str wzr,[sp,#40]
 add x1,x0,x1
 adr x2,.Ldyn_group
 mov x3,#10
 adr x4,.Loperational_dyncore_keys
 add x5,sp,#40
 bl md2asm_parse_operational_forecast_group
 cbnz w0,.Ldyn_bad
 ldr w9,[sp,#40]
 cbnz w9,.Ldyn_bad
 /* All validation precedes the source defaults and numerical work. */
 str wzr,[x19,#284] /* LPPSTEPS */
 adr x9,.Ldyn_literal_RT00_DYN
 ldr d0,[x9]
 str d0,[x19,#64]
 adr x9,.Ldyn_literal_RP00_DYN
 ldr d0,[x9]
 str d0,[x19,#72]
 str xzr,[x19,#80] /* RU00_DYN positive zero */
 str xzr,[x19,#88] /* RST0_DYN positive zero */
 str wzr,[x19,#300] /* NOISEVOR */
 str xzr,[x19,#56] /* RAMP positive zero */
 adr x9,.Ldyn_literal_RUSPLRADI
 ldr d0,[x9]
 str d0,[x19,#24]
 adr x9,.Ldyn_literal_RUSCORIOI
 ldr d0,[x9]
 str d0,[x19,#40]
 adr x9,.Ldyn_literal_RUSPLRG
 ldr d0,[x9]
 str d0,[x19,#48]
 fmov d1,#1.0
 ldr d0,[x19,#24]
 fdiv d2,d1,d0
 str d2,[x19,#16]
 fmov d1,#1.0
 ldr d0,[x19,#40]
 fdiv d2,d1,d0
 str d2,[x19,#32]
 fmov d1,#1.0
 ldr d0,[x19,#48]
 fdiv d2,d1,d0
 str d2,[x19,#0]
 adr x9,.Ldyn_literal_RPLDARE
 ldr d0,[x9]
 str d0,[x19,#8]
 mov x9,#0x2020202020202020
 str x9,[x19,#304]
 str w9,[x19,#312] /* CTEST_FAMILY: twelve spaces */
 mov w9,#-1
 str w9,[x19,#292] /* NTESTCASE */
 str wzr,[x19,#272] /* LAQUA */
 str wzr,[x19,#276] /* LAPE */
 mov w9,#9
 str w9,[x19,#296] /* MSSTSCHEME */
 str wzr,[x19,#280] /* LHELDSUAREZ */
 adr x9,.Ldyn_literal_RDELTA_T
 ldr d0,[x9]
 str d0,[x19,#112]
 adr x9,.Ldyn_literal_RDELTA_THETA
 ldr d0,[x9]
 str d0,[x19,#120]
 adr x9,.Ldyn_literal_RSIGMAB
 ldr d0,[x9]
 str d0,[x19,#96]
 fmov d1,#1.0
 ldr d0,[x19,#96]
 fsub d2,d1,d0
 str d2,[x19,#104] /* REFERENCE_LEVEL */
 adr x9,.Ldyn_literal_RPRESSURE_SCALE
 ldr d0,[x9]
 str d0,[x19,#128]
 adr x9,.Ldyn_literal_RHS_KAPPA
 ldr d0,[x9]
 str d0,[x19,#168]
 str wzr,[x19,#288] /* L_HS_WILLIAMSON */
 adr x9,.Ldyn_literal_RTHSW_0
 ldr d0,[x9]
 str d0,[x19,#176]
 adr x9,.Ldyn_literal_RPHSW_PL
 ldr d0,[x9]
 str d0,[x19,#200]
 adr x9,.Ldyn_literal_RPHSW_D
 ldr d0,[x9]
 str d0,[x19,#184]
 adr x9,.Ldyn_literal_RJACSLDIA
 ldr d0,[x9]
 str d0,[x19,#224]
 adr x9,.Ldyn_literal_RLIPSLDIA
 ldr d0,[x9]
 str d0,[x19,#232]
 /* The accepted empty namelist changes no default. Source post-read ratios. */
 fmov d1,#1.0
 ldr d0,[x19,#24]
 fdiv d2,d1,d0
 str d2,[x19,#16]
 fmov d1,#1.0
 ldr d0,[x19,#40]
 fcmp d0,#0.0
 b.eq .Ldyn_zero_coriolis
 fdiv d2,d1,d0
 str d2,[x19,#32]
 b .Ldyn_coriolis_done
.Ldyn_zero_coriolis:
 str xzr,[x19,#32]
.Ldyn_coriolis_done:
 fmov d1,#1.0
 ldr d0,[x19,#48]
 fdiv d2,d1,d0
 str d2,[x19,#0]
 /* LHELDSUAREZ is false; its seven output fields retain their preimage.
  * Aquaplanet anomaly fields are also source-unwritten. */
 mov w0,#0
 b .Ldyn_return
.Ldyn_bad:
 mov w0,#2
.Ldyn_return:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
.Ldyn_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_operational_dynamical_configuration,.-md2asm_initialize_operational_dynamical_configuration
.section .rodata
.Ldyn_group: .ascii "NAMDYNCORE"
.p2align 3
.Ldyn_literal_RT00_DYN: .double 288.15
.Ldyn_literal_RP00_DYN: .double 101315.0
.Ldyn_literal_RUSPLRADI: .double 1.0
.Ldyn_literal_RUSCORIOI: .double 1.0
.Ldyn_literal_RUSPLRG: .double 1.0
.Ldyn_literal_RPLDARE: .double 1.0
.Ldyn_literal_RDELTA_T: .double 60.0
.Ldyn_literal_RDELTA_THETA: .double 10.0
.Ldyn_literal_RSIGMAB: .double 0.7
.Ldyn_literal_RPRESSURE_SCALE: .double 0.00001
.Ldyn_literal_RHS_KAPPA: .quad 0x3fd2492492492492
.Ldyn_literal_RTHSW_0: .double 200.0
.Ldyn_literal_RPHSW_PL: .double 10.0
.Ldyn_literal_RPHSW_D: .double 10000.0
.Ldyn_literal_RJACSLDIA: .double 1.5
.Ldyn_literal_RLIPSLDIA: .double 5.0
.p2align 3
.Loperational_dyncore_keys:
 .word 5,2,0,0,0,0
 .ascii "LAQUA"
 .zero 11
 .zero 40
.section .note.GNU-stack,"",%progbits
