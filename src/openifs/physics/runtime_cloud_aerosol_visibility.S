/* Direct AArch64 implementation of the original CLAERVIS equations.
 * Contract: skills/md2asm/references/openifs/physics/runtime_cloud_aerosol_visibility.md.
 * The caller supplies the complete argument and constant owners. */
// Runtime CLAERVIS: context16, live P/L bounds and unchanged ordered numerical core.
.text
.p2align 4
.macro CALL target
 stp x18,x30,[sp,#-16]!
 bl \target
 ldp x18,x30,[sp],#16
.endm
.macro CV_NO_OUTPUT_OVERLAP lo,hi
 cmp \lo,x17
 b.hs 1f
 cmp \hi,x15
 b.hi .Lcv_reject
1:
.endm
.global md2asm_runtime_cloud_aerosol_visibility
.type md2asm_runtime_cloud_aerosol_visibility,%function
md2asm_runtime_cloud_aerosol_visibility:
 mov x10,sp
 sub sp,sp,#768
 stp x29,x30,[sp,#128]
 mov x29,sp
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 stp d8,d9,[sp,#224]
 stp d10,d11,[sp,#240]
 stp d12,d13,[sp,#256]
 stp d14,d15,[sp,#272]
 add x19,sp,#320
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 str x6,[x19,#48]
 str x7,[x19,#56]
 ldr x9,[x10,#0]
 str x9,[x19,#64]
 ldr x9,[x10,#8]
 str x9,[x19,#72]
 ldr x9,[x10,#16]
 str x9,[x19,#80]
 ldr x9,[x10,#24]
 str x9,[x19,#88]
 ldr x9,[x10,#32]
 str x9,[x19,#96]
 ldr x9,[x10,#40]
 str x9,[x19,#104]
 mrs x9,fpcr
 cbnz x9,.Lcv_reject
 mov x11,#0
.Lcv_scalar_pointers:
 ldr x9,[x19,x11,lsl #3]
 cbz x9,.Lcv_reject
 tst x9,#3
 b.ne .Lcv_reject
 adds x12,x9,#4
 b.cs .Lcv_reject
 add x11,x11,#1
 cmp x11,#4
 b.lt .Lcv_scalar_pointers
 ldr x9,[x19,#0]
 ldr w20,[x9]
 ldr x9,[x19,#8]
 ldr w21,[x9]
 ldr x9,[x19,#16]
 ldr w22,[x9]
 ldr x9,[x19,#24]
 ldr w23,[x9]
 cmp w22,#1
 b.lt .Lcv_reject
 cmp w23,#1
 b.lt .Lcv_reject
 cmp w22,#24
 b.hi .Lcv_wider_shape
 cmp w23,#19
 b.ls .Lcv_shape_ready
.Lcv_wider_shape:
 cmp w22,#128
 b.hi .Lcv_reject
 cmp w23,#137
 b.hi .Lcv_reject
.Lcv_shape_ready:
 cmp w20,#1
 b.lt .Lcv_reject
 add w9,w22,#1
 cmp w20,w9
 b.gt .Lcv_reject
 cmp w21,#0
 b.lt .Lcv_reject
 cmp w21,w22
 b.gt .Lcv_reject
 sub w9,w20,#1
 cmp w21,w9
 b.lt .Lcv_reject
 umull x13,w22,w23
 lsl x13,x13,#3
 lsl x14,x22,#3
 mov x11,#4
.Lcv_array_pointers:
 ldr x9,[x19,x11,lsl #3]
 cbz x9,.Lcv_reject
 tst x9,#7
 b.ne .Lcv_reject
 cmp x11,#4
 b.eq .Lcv_vector_span
 cmp x11,#12
 b.eq .Lcv_vector_span
 mov x12,x13
 b .Lcv_array_span
.Lcv_vector_span:
 mov x12,x14
.Lcv_array_span:
 adds x12,x9,x12
 b.cs .Lcv_reject
 add x11,x11,#1
 cmp x11,#13
 b.lt .Lcv_array_pointers
 ldr x15,[x19,#96]
 add x17,x15,x14
 mov x11,#0
.Lcv_readonly_overlap:
 ldr x9,[x19,x11,lsl #3]
 cmp x11,#4
 b.lt .Lcv_scalar_overlap
 mov x12,x13
 b.ne .Lcv_overlap_span
 mov x12,x14
 b .Lcv_overlap_span
.Lcv_scalar_overlap:
 mov x12,#4
.Lcv_overlap_span:
 add x12,x9,x12
 CV_NO_OUTPUT_OVERLAP x9,x12
 add x11,x11,#1
 cmp x11,#12
 b.lt .Lcv_readonly_overlap
 ldr x9,[x19,#104]
 cbz x9,.Lcv_reject
 tst x9,#7
 b.ne .Lcv_reject
 adds x10,x9,#16
 b.cs .Lcv_reject
 CV_NO_OUTPUT_OVERLAP x9,x10
 ldp x10,x11,[x9]
 cbz x10,.Lcv_reject
 tst x10,#7
 b.ne .Lcv_reject
 adds x12,x10,#520
 b.cs .Lcv_reject
 CV_NO_OUTPUT_OVERLAP x10,x12
 ldr w12,[x10,#512]
 cmp w12,#1
 b.ne .Lcv_reject
 ldr x12,[x10,#184]
 tbnz x12,#63,.Lcv_reject
 cbz x12,.Lcv_reject
 ubfx x13,x12,#52,#11
 cmp x13,#2047
 b.eq .Lcv_reject
 str x12,[sp,#544]
 cbz x11,.Lcv_reject
 tst x11,#7
 b.ne .Lcv_reject
 adds x12,x11,#16
 b.cs .Lcv_reject
 CV_NO_OUTPUT_OVERLAP x11,x12
 ldp x10,x12,[x11]
 cbnz x12,.Lcv_reject
 cbz x10,.Lcv_reject
 tst x10,#3
 b.ne .Lcv_reject
 adds x12,x10,#4
 b.cs .Lcv_reject
 CV_NO_OUTPUT_OVERLAP x10,x12
 ldr w12,[x10]
 cbnz w12,.Lcv_reject
 sub w20,w20,#1
 sub w23,w23,#1
 umull x23,w23,w22
 ldr d8,[sp,#544]
 ldr d0,.Lcv_c0
 ldr d1,.Lcv_c1
 fdiv d9,d0,d1
 ldr d1,.Lcv_c2
 fdiv d10,d0,d1
 cmp w20,w21
 b.ge .Lcv_done
.Lcv_column:
 add x24,x23,x20
 lsl x24,x24,#3
 lsl x26,x20,#3
 ldr x9,[x19,#80]
 ldr d0,[x9,x24]
 ldr x9,[x19,#88]
 ldr d1,[x9,x24]
 fmul d1,d8,d1
 fdiv d11,d0,d1
 ldr x9,[x19,#32]
 ldr d0,[x9,x26]
 ldr d1,.Lcv_c3
 fdiv d12,d0,d1
 ldr x9,[x19,#48]
 ldr d0,[x9,x24]
 fmul d0,d0,d11
 ldr d1,.Lcv_c3
 fmul d0,d0,d1
 fmov d1,xzr
 fmax d0,d0,d1
 str d0,[sp,#560]
 ldr x9,[x19,#64]
 ldr d0,[x9,x24]
 fmul d0,d0,d11
 ldr d1,.Lcv_c3
 fmul d0,d0,d1
 fmov d1,xzr
 fmax d0,d0,d1
 str d0,[sp,#568]
 ldr x9,[x19,#56]
 ldr d0,[x9,x24]
 fmul d0,d0,d11
 ldr d1,.Lcv_c3
 fmul d0,d0,d1
 fmov d1,xzr
 fmax d0,d0,d1
 str d0,[sp,#576]
 ldr x9,[x19,#72]
 ldr d0,[x9,x24]
 fmul d0,d0,d11
 ldr d1,.Lcv_c3
 fmul d0,d0,d1
 fmov d1,xzr
 fmax d0,d0,d1
 str d0,[sp,#584]
 ldr d0,[sp,#560]
 ldr d1,.Lcv_c4
 fmul d0,d0,d1
 ldr d1,.Lcv_c5
 CALL md2asm_pow_original_rounding_candidate
 fmul d0,d10,d0
 str d0,[sp,#560]
 ldr d0,[sp,#576]
 ldr d1,.Lcv_c6
 fmul d0,d1,d0
 str d0,[sp,#576]
 ldr d0,[sp,#584]
 ldr d1,.Lcv_c7
 CALL md2asm_pow_original_rounding_candidate
 ldr d1,.Lcv_c8
 fmul d0,d1,d0
 str d0,[sp,#584]
 ldr d0,[sp,#568]
 ldr d1,.Lcv_c9
 CALL md2asm_pow_original_rounding_candidate
 ldr d1,.Lcv_c10
 fmul d0,d1,d0
 str d0,[sp,#568]
 ldr d0,[sp,#576]
 ldr d1,[sp,#560]
 fadd d0,d0,d1
 ldr d1,[sp,#584]
 fadd d0,d0,d1
 ldr d1,[sp,#568]
 fadd d0,d0,d1
 fadd d1,d9,d12
 fadd d1,d1,d0
 ldr d0,.Lcv_c0
 fdiv d0,d0,d1
 ldr x9,[x19,#96]
 str d0,[x9,x26]
 add w20,w20,#1
 cmp w20,w21
 b.lt .Lcv_column
.Lcv_done:
 mov w0,#0
.Lcv_restore:
 ldp d8,d9,[sp,#224]
 ldp d10,d11,[sp,#240]
 ldp d12,d13,[sp,#256]
 ldp d14,d15,[sp,#272]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldp x29,x30,[sp,#128]
 add sp,sp,#768
 ret
.Lcv_reject:
 mov w0,#2
 b .Lcv_restore
.size md2asm_runtime_cloud_aerosol_visibility,.-md2asm_runtime_cloud_aerosol_visibility
.section .rodata
.p2align 3
.Lcv_hook_name: .ascii "CLAERVIS"
.p2align 2
.Lcv_hook_phase0: .word 0
.Lcv_hook_phase1: .word 1
.p2align 3
.Lcv_c0: .quad 0x400f4bd2b6f19935 // 3.912023
.Lcv_c1: .quad 0x40f86a0000000000 // 100000.0
.Lcv_c2: .quad 0x408f500000000000 // 1002.0
.Lcv_c3: .quad 0x408f400000000000 // 1000.0
.Lcv_c4: .quad 0x4049000000000000 // 50.0
.Lcv_c5: .quad 0x3fe4b6ae7d566cf4 // 0.6473
.Lcv_c6: .quad 0x3fc4faacd9e83e42 // 0.1639
.Lcv_c7: .quad 0x3fe8f5c28f5c28f6 // 0.78
.Lcv_c8: .quad 0x3f70624dd2f1a9fc // 0.004
.Lcv_c9: .quad 0x3fe8000000000000 // 0.75
.Lcv_c10: .quad 0x3f747ae147ae147b // 0.005
.section .note.GNU-stack,"",%progbits
