/* Contract: skills/md2asm/references/openifs/setup/live_disabled_stochastic_physics_forwarding.md.
 * Direct source follows the frozen live-owner forwarding contract.
 * Eight arguments: G20400/cap, MODEL4275088/cap, cfg67616/cap, text/bytes.
 * Forward live embedded STOPH/TDYN/TRIP and the cfg physical radius.
 * SURIP and SUDYN are caller prerequisites; this entry does not repair them.
 * Frame96 aligned16; preserve x18 and all saved registers and status.
 * The accepted child alone writes its 416 STOPH bytes and adds natural FPSR.
 */
.arch armv8.2-a
.text
.macro LS_CONST reg,value
 movz \reg,#((\value)&65535)
 movk \reg,#(((\value)>>16)&65535),lsl#16
.endm
.macro LS_APART a,enda,b,endb
 cmp \a,\endb
 b.hs .Lls_disjoint\@
 cmp \b,\enda
 b.lo .Lls_bad
.Lls_disjoint\@:
.endm
.macro LS_CFG_WORD offset,value
 LS_CONST x15,\offset
 ldr w16,[x4,x15]
 cmp w16,#\value
 b.ne .Lls_bad
.endm
.p2align 4
.global md2asm_initialize_live_disabled_stochastic_physics
.type md2asm_initialize_live_disabled_stochastic_physics,%function
md2asm_initialize_live_disabled_stochastic_physics:
 mrs x8,fpcr
 cbnz x8,.Lls_bad
 cbz x0,.Lls_bad
 cbz x2,.Lls_bad
 cbz x4,.Lls_bad
 cbz x6,.Lls_bad
 orr x8,x0,x2
 orr x8,x8,x4
 tst x8,#7
 b.ne .Lls_bad
 LS_CONST x8,20400
 cmp x1,x8
 b.lo .Lls_bad
 adds x9,x0,x8
 b.cs .Lls_bad
 LS_CONST x8,4275088
 cmp x3,x8
 b.lo .Lls_bad
 adds x11,x2,x8
 b.cs .Lls_bad
 LS_CONST x8,67616
 cmp x5,x8
 b.lo .Lls_bad
 adds x13,x4,x8
 b.cs .Lls_bad
 cbz x7,.Lls_bad
 cmp x7,#64,lsl#12
 b.hi .Lls_bad
 adds x14,x6,x7
 b.cs .Lls_bad
 LS_APART x0,x9,x2,x11
 LS_APART x0,x9,x4,x13
 LS_APART x0,x9,x6,x14
 LS_APART x2,x11,x4,x13
 LS_APART x2,x11,x6,x14
 LS_APART x4,x13,x6,x14
 ldr x15,[x4]
 cmp x15,x2
 b.ne .Lls_bad
 ldr x15,[x4,#16]
 cmp x15,x0
 b.ne .Lls_bad
 ldr x15,[x2,#8]
 cmp x15,x0
 b.ne .Lls_bad
 ldr x15,[x4,#24]
 LS_CONST x16,0x47314346
 cmp x15,x16
 b.ne .Lls_bad
 LS_CFG_WORD 35688,1
 LS_CFG_WORD 40104,1
 LS_CFG_WORD 35872,0
 /* The source early TDT is the existing SURIP TSTEP, in seconds. */
 LS_CONST x15,51704
 ldr x16,[x4,x15]
 cbz x16,.Lls_bad
 tbnz x16,#63,.Lls_bad
 adrp x17,.Lls_step_limit
 ldr x17,[x17,:lo12:.Lls_step_limit]
 cmp x16,x17
 b.hi .Lls_bad
 LS_CONST x15,1359528
 ldr x17,[x2,x15]
 cmp x17,x16
 b.ne .Lls_bad
 add x15,x15,#8
 ldr x17,[x2,x15]
 cmp x17,x16
 b.ne .Lls_bad
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x6
 mov x23,x7
 LS_CONST x9,4126168
 add x0,x20,x9
 mov x1,#2904
 mov x2,x19
 LS_CONST x9,1564592
 add x3,x20,x9
 LS_CONST x9,1359328
 add x4,x20,x9
 add x5,x21,#168
 mov x6,x22
 mov x7,x23
 bl md2asm_initialize_disabled_stochastic_physics
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.Lls_bad:
 mov w0,#2
 ret
.size md2asm_initialize_live_disabled_stochastic_physics,.-md2asm_initialize_live_disabled_stochastic_physics
.section .rodata
.p2align 3
.Lls_step_limit: .quad 0x412e848000000000 /* one million seconds */
.section .note.GNU-stack,"",%progbits
