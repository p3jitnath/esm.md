/* Contract: skills/md2asm/references/openifs/setup/inactive_convective_cellular_controls.md.
 * Selected YOE_CUCONVCA::INI_CUCONVCA, ECMWF and empty/absent NAMCA.
 * x0 MODEL4275088,x1 capacity,x2 cfg67616,x3 capacity,
 * x4 text,x5 bytes,x6 NIJH4,x7 capacity. Return0 success or2 before writes.
 * MODEL+1581736 is the actual6296B record. Preserve unassigned fields,
 * padding and every array description. Source inactive branch allocates none.
 * Frame48 aligned16. Preserve x18,saved registers,FPCR,FPSR and errno.
 */
.arch armv8.2-a
.text
.macro CC_CONST reg,value
 movz \reg,#((\value)&65535)
 movk \reg,#(((\value)>>16)&65535),lsl#16
.endm
.macro CC_APART first,endfirst,second,endsecond
 cmp \first,\endsecond
 b.hs .Lcc_separate\@
 cmp \second,\endfirst
 b.lo .Lcc_bad
.Lcc_separate\@:
.endm
.macro CC_WORD offset,value
 mov w9,#\value
 str w9,[x19,#\offset]
.endm
.p2align 4
.global md2asm_initialize_inactive_convective_cellular_controls
.type md2asm_initialize_inactive_convective_cellular_controls,%function
md2asm_initialize_inactive_convective_cellular_controls:
 mrs x8,fpcr
 cbnz x8,.Lcc_bad
 cbz x0,.Lcc_bad
 cbz x2,.Lcc_bad
 cbz x4,.Lcc_bad
 cbz x6,.Lcc_bad
 orr x8,x0,x2
 tst x8,#7
 b.ne .Lcc_bad
 tst x6,#3
 b.ne .Lcc_bad
 CC_CONST x8,4275088
 cmp x1,x8
 b.lo .Lcc_bad
 adds x9,x0,x8
 b.cs .Lcc_bad
 CC_CONST x8,67616
 cmp x3,x8
 b.lo .Lcc_bad
 adds x10,x2,x8
 b.cs .Lcc_bad
 cbz x5,.Lcc_bad
 cmp x5,#64,lsl#12
 b.hi .Lcc_bad
 adds x11,x4,x5
 b.cs .Lcc_bad
 cmp x7,#4
 b.lo .Lcc_bad
 adds x12,x6,#4
 b.cs .Lcc_bad
 CC_APART x0,x9,x2,x10
 CC_APART x0,x9,x4,x11
 CC_APART x0,x9,x6,x12
 CC_APART x6,x12,x2,x10
 CC_APART x6,x12,x4,x11
 ldr x8,[x2]
 cmp x8,x0
 b.ne .Lcc_bad
 ldr x8,[x2,#16]
 cbz x8,.Lcc_bad
 tst x8,#7
 b.ne .Lcc_bad
 ldr x13,[x0,#8]
 cmp x8,x13
 b.ne .Lcc_bad
 ldr x8,[x2,#24]
 CC_CONST x13,0x47314346
 cmp x8,x13
 b.ne .Lcc_bad
 CC_CONST x8,40104
 ldr w13,[x2,x8]
 cmp w13,#1
 b.ne .Lcc_bad
 CC_CONST x8,40088
 ldr w13,[x2,x8]
 cbnz w13,.Lcc_bad
 stp x29,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 CC_CONST x8,1581736
 add x19,x0,x8
 mov x20,x6
 mov x21,x4
 mov x22,x5
 mov x0,x21
 mov x1,x22
 adrp x2,.Lcc_namca
 add x2,x2,:lo12:.Lcc_namca
 mov x3,#5
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lcc_return
 /* Original default stores in source order, with no array allocation. */
 CC_WORD 5888,0
 CC_WORD 5892,1
 mov w9,#4
 str w9,[x20]
 str xzr,[x19,#5880]
 CC_WORD 5896,0
 CC_WORD 5900,1
 CC_WORD 5912,0
 CC_WORD 5920,0
 adrp x9,.Lcc_seedprob
 add x9,x9,:lo12:.Lcc_seedprob
 ldr x9,[x9]
 str x9,[x19,#5872]
 CC_WORD 5956,1
 CC_WORD 2448,10
 CC_WORD 2452,3
 CC_WORD 5904,0
 CC_WORD 5908,0
 CC_WORD 5960,8
 CC_WORD 5964,1
 CC_WORD 5968,-1
 CC_WORD 5972,0
 CC_WORD 2456,1000
 /* Three ten-byte Fortran character assignments, including space padding. */
 adrp x9,.Lcc_strings
 add x9,x9,:lo12:.Lcc_strings
 mov x10,#5924
 add x10,x19,x10
 ldr w11,[x9,#0]
 str w11,[x10,#0]
 ldr w11,[x9,#4]
 str w11,[x10,#4]
 ldr w11,[x9,#8]
 str w11,[x10,#8]
 ldr w11,[x9,#12]
 str w11,[x10,#12]
 ldr w11,[x9,#16]
 str w11,[x10,#16]
 ldr w11,[x9,#20]
 str w11,[x10,#20]
 ldr w11,[x9,#24]
 str w11,[x10,#24]
 ldrh w11,[x9,#28]
 strh w11,[x10,#28]
 mov w0,#0
.Lcc_return:
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
.Lcc_bad:
 mov w0,#2
 ret
.size md2asm_initialize_inactive_convective_cellular_controls,.-md2asm_initialize_inactive_convective_cellular_controls
.section .rodata
.p2align 3
.Lcc_seedprob: .quad 0x3fefd70a40000000
.Lcc_namca: .ascii "NAMCA"
.p2align 3
.Lcc_strings: .ascii "CONV_TQ   REAL      WIND      "
.section .note.GNU-stack,"",%progbits
