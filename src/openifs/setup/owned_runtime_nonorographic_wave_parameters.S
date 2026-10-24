/* Contract: skills/md2asm/references/openifs/setup/runtime_nonorographic_gravity_wave_parameters.md. */
/* Actual MODEL-owned selected SUGWWMS producer. Eight arguments:
 * text/length, Geometry/capacity, MODEL/capacity, configuration/capacity.
 * Return 0 on success or 2 before mutation. No allocation or release.
 * The configuration owns physical constants and source NCONF=1.
 * Geometry owns STPRE and MODEL owns both TRIP TSTEP and TEGWWMS. */
.arch armv8.2-a
.text
.macro IMM dst,value
 movz \dst,#(\value&65535)
 movk \dst,#((\value>>16)&65535),lsl#16
.endm
.p2align 4
.global md2asm_initialize_owned_runtime_nonorographic_wave_parameters
.type md2asm_initialize_owned_runtime_nonorographic_wave_parameters,%function
md2asm_initialize_owned_runtime_nonorographic_wave_parameters:
 cbz x0,.Lbad_leaf
 cbz x1,.Lbad_leaf
 cbz x2,.Lbad_leaf
 cbz x4,.Lbad_leaf
 cbz x6,.Lbad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lbad_leaf
 mov x9,#20400
 cmp x3,x9
 b.lo .Lbad_leaf
 IMM x9,4275088
 cmp x5,x9
 b.lo .Lbad_leaf
 IMM x9,67616
 cmp x7,x9
 b.lo .Lbad_leaf
 orr x9,x2,x4
 orr x9,x9,x6
 tst x9,#7
 b.ne .Lbad_leaf
 mrs x9,fpcr
 cbnz x9,.Lbad_leaf
 sub sp,sp,#192
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x4
 mov x23,x6
 add x10,sp,#112
 mov x9,#20400
 stp x21,x9,[x10]
 IMM x9,4275088
 stp x22,x9,[x10,#16]
 IMM x9,67616
 stp x23,x9,[x10,#32]
 stp x19,x20,[x10,#48]
 mov x6,#0
 mov x5,#4
 bl .Lranges
 cbnz w0,.Lbad
 ldr x9,[x22,#8]
 cmp x9,x21
 b.ne .Lbad
 ldr x9,[x23]
 cmp x9,x22
 b.ne .Lbad
 ldr x9,[x23,#16]
 cmp x9,x21
 b.ne .Lbad
 ldr x9,[x23,#24]
 IMM x10,0x47314346
 cmp x9,x10
 b.ne .Lbad
 IMM x9,35688
 ldr w9,[x23,x9]
 cmp w9,#1
 b.ne .Lbad
 ldr x9,[x23,#120]
 movz x10,#0x40ac,lsl#48
 movk x10,#0x2000,lsl#32
 cmp x9,x10
 b.ne .Lbad
 ldr w24,[x21,#5224]
 cmp w24,#2
 b.lo .Lbad
 cmp w24,#256
 b.hi .Lbad
 add x10,x21,#3336
 ldr x25,[x10]
 cbz x25,.Lbad
 tst x25,#7
 b.ne .Lbad
 ldr x9,[x10,#8]
 cmn x9,#1
 b.ne .Lbad
 ldr x9,[x10,#16]
 cmp x9,#8
 b.ne .Lbad
 ldr x9,[x10,#24]
 mov x11,#0x30100000000
 cmp x9,x11
 b.ne .Lbad
 ldr x9,[x10,#32]
 cmp x9,#8
 b.ne .Lbad
 ldp x9,x11,[x10,#40]
 cmp x9,#1
 b.ne .Lbad
 cmp x11,#1
 b.ne .Lbad
 ldr x9,[x10,#56]
 cmp x9,x24
 b.ne .Lbad
 lsl x26,x24,#3
 add x10,sp,#112
 stp x25,x26,[x10,#64]
 mov x6,#4
 mov x5,#5
 bl .Lranges
 cbnz w0,.Lbad
 IMM x9,1359528
 add x27,x22,x9
 ldr x9,[x27]
 mov x10,#0x3ff0000000000000
 cmp x9,x10
 b.lo .Lbad
 movz x10,#0x40f5,lsl#48
 movk x10,#0x1800,lsl#32
 cmp x9,x10
 b.hi .Lbad
 mov x10,#0
 mov x11,#0x7ff0000000000000
.Lpositive_pressure:
 ldr x9,[x25,x10]
 cbz x9,.Lbad
 cmp x9,x11
 b.hs .Lbad
 add x10,x10,#8
 cmp x10,x26
 b.lo .Lpositive_pressure
 mov x0,x19
 mov x1,x20
 adr x2,.Lgroup
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lbad
 IMM x9,1588128
 add x28,x22,x9
 mov x0,x28
 mov x1,x25
 add x2,x23,#120
 mov x3,x27
 mov w4,w24
 bl md2asm_runtime_nonorographic_gravity_wave_parameter_fields
 mov w0,#0
 b .Lreturn
.Lbad:
 mov w0,#2
.Lreturn:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.Lbad_leaf:
 mov w0,#2
 ret
/* Admit ranges x6 through x5-1 against every prior range. */
.Lranges:
 add x10,sp,#112
 add x10,x10,x6,lsl#4
 ldp x7,x8,[x10]
 adds x11,x7,x8
 b.cs .Lranges_bad
 mov x9,#0
.Lprior:
 cmp x9,x6
 b.hs .Lnext
 add x10,sp,#112
 add x10,x10,x9,lsl#4
 ldp x12,x13,[x10]
 add x13,x12,x13
 cmp x7,x13
 b.hs .Lclear
 cmp x12,x11
 b.lo .Lranges_bad
.Lclear:
 add x9,x9,#1
 b .Lprior
.Lnext:
 add x6,x6,#1
 cmp x6,x5
 b.lo .Lranges
 mov w0,#0
 ret
.Lranges_bad:
 mov w0,#2
 ret
.size md2asm_initialize_owned_runtime_nonorographic_wave_parameters,.-md2asm_initialize_owned_runtime_nonorographic_wave_parameters
.section .rodata
.Lgroup: .ascii "NAMGWWMS"
.section .note.GNU-stack,"",%progbits
