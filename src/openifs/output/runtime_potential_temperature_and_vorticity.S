/* The interface, bounds, units and component limits are in
 * skills/md2asm/references/openifs/output/fullpos_vertical_physics.md.
 */
/* Source GPPVO computes potential temperature and potential vorticity. */
/* The original19 addresses are followed by context24 at incoming stack88. */
.arch armv8.2-a
.symver md2asm_pv_public_power,pow@GLIBC_2.29
.macro ARRAY d,index,linear
 ldr x9,[sp,#(128+8*\index)]
 ldr \d,[x9,\linear,lsl#3]
.endm
.macro SCRATCH n
 mov x9,#\n
 madd x9,x9,x24,x23
.endm
.macro STORE_SCRATCH d,n,linear
 SCRATCH \n
 str \d,[x9,\linear,lsl#3]
.endm
.macro LOAD_SCRATCH d,n,linear
 SCRATCH \n
 ldr \d,[x9,\linear,lsl#3]
.endm
.text
.p2align 4
.global md2asm_runtime_potential_temperature_and_vorticity
.type md2asm_runtime_potential_temperature_and_vorticity,%function
md2asm_runtime_potential_temperature_and_vorticity:
 mov x17,sp
 sub sp,sp,#512
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]
 mov x9,#0
 add x10,sp,#192
.Lstack_arguments:
 ldr x11,[x17,x9,lsl#3]
 str x11,[x10,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#12
 b.lo .Lstack_arguments
 mov x9,#0
.Lnonnull:
 add x10,sp,#128
 ldr x11,[x10,x9,lsl#3]
 cbz x11,.Lbad
 tst x11,#3
 b.ne .Lbad
 add x9,x9,#1
 cmp x9,#20
 b.lo .Lnonnull
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldr w19,[x1]
 ldr w20,[x4]
 ldr w21,[x2]
 ldr w22,[x3]
 sub w9,w19,#1
 mov w10,#32768
 cmp w9,w10
 b.hi .Lbad
 sub w9,w20,#2
 cmp w9,#510
 b.hi .Lbad
 sub w9,w21,#1
 cmp w9,w19
 b.hs .Lbad
 cmp w22,w21
 b.lt .Lbad
 cmp w22,w19
 b.gt .Lbad
 sub w21,w21,#1
 umull x24,w19,w20
 lsl x24,x24,#3
 ldr x9,[sp,#280]
 ldr x10,[x9]
 ldr x11,[x9,#8]
 ldr x12,[x9,#16]
 cbz x10,.Lbad
 cbz x12,.Lbad
 tst x10,#7
 b.ne .Lbad
 ldr w12,[x12]
 cbnz w12,.Lbad
 mov x12,#1
 lsl x12,x12,#30
 cmp x11,x12
 b.hi .Lbad
 mov x12,#7
 mul x12,x24,x12
 cmp x12,x11
 b.hi .Lbad
 str x12,[sp,#368]
 ldr d0,[x10,#112]
 str d0,[sp,#320]
 ldr x9,[sp,#128]
 ldr x25,[x9,#64]
 cbz x25,.Lbad
 tst x25,#7
 b.ne .Lbad
 ldr x10,[x9,#80]
 cmp x10,#8
 b.ne .Lbad
 ldr x10,[x9,#112]
 cbnz x10,.Lbad
 ldr x10,[x9,#120]
 cmp x10,x20
 b.lt .Lbad
 // Validate all original array address ranges before any output write.
 mov x10,#5
.Larray_spans:
 add x9,sp,#128
 ldr x11,[x9,x10,lsl#3]
 tst x11,#7
 b.ne .Lbad
 mov x12,x24
 cmp x10,#8
 b.eq .Lvector_span
 cmp x10,#15
 b.eq .Lvector_span
 cmp x10,#16
 b.ne .Lspan_size
.Lvector_span:
 lsl x12,x19,#3
.Lspan_size:
 adds x13,x11,x12
 b.cs .Lbad
 add x10,x10,#1
 cmp x10,#19
 b.lo .Larray_spans
 ldr x0,[sp,#368]
 bl malloc
 ldr x18,[sp,#96]
 cbz x0,.Lallocation_failed
 mov x23,x0
 // Horizontal derivatives of hydrostatic pressure.
 mov x26,#0
.Lpressure_level:
 ldr d0,[x25,x26,lsl#3]
 add x9,x26,#1
 ldr d1,[x25,x9,lsl#3]
 fadd d2,d0,d1
 fmov d3,#0.5
 fmul d2,d2,d3
 mov x27,x21
.Lpressure_row:
 madd x28,x26,x19,x27
 ARRAY d0,15,x27
 fmul d0,d2,d0
 STORE_SCRATCH d0,3,x28
 ARRAY d0,16,x27
 fmul d0,d2,d0
 STORE_SCRATCH d0,2,x28
 add x27,x27,#1
 cmp x27,x22
 b.lo .Lpressure_row
 add x26,x26,#1
 cmp x26,x20
 b.lo .Lpressure_level
 // Potential temperature and its two horizontal derivatives.
 ldr x9,[sp,#280]
 ldr x9,[x9]
 ldr d0,[x9,#360]
 fmov d1,#1.0
 fdiv d0,d1,d0
 str d0,[sp,#312]
 mov x26,#0
.Ltheta_level:
 mov x27,x21
.Ltheta_row:
 madd x28,x26,x19,x27
 ARRAY d0,12,x28
 fmov d1,#1.0
 fdiv d0,d1,d0
 str d0,[sp,#336]
 ARRAY d0,7,x28
 ARRAY d1,5,x28
 fdiv d2,d0,d1
 str d2,[sp,#344]
 fneg d0,d0
 ldr d2,[sp,#312]
 fmul d1,d1,d2
 fmov d3,d0
 fmov d0,d1
 fmov d1,d3
 bl md2asm_pv_public_power
 ldr x18,[sp,#96]
 ARRAY d1,12,x28
 fmul d0,d1,d0
 ldr x9,[sp,#272]
 str d0,[x9,x28,lsl#3]
 fmov d4,d0
 ARRAY d0,13,x28
 ldr d1,[sp,#336]
 fmul d0,d0,d1
 LOAD_SCRATCH d2,3,x28
 ldr d3,[sp,#344]
 fmul d2,d3,d2
 fsub d0,d0,d2
 fmul d0,d4,d0
 STORE_SCRATCH d0,1,x28
 ARRAY d0,14,x28
 fmul d0,d0,d1
 LOAD_SCRATCH d2,2,x28
 fmul d2,d3,d2
 fsub d0,d0,d2
 fmul d0,d4,d0
 STORE_SCRATCH d0,0,x28
 add x27,x27,#1
 cmp x27,x22
 b.lo .Ltheta_row
 add x26,x26,#1
 cmp x26,x20
 b.lo .Ltheta_level
 // Centered vertical differences on interior model levels.
 ldr d0,[sp,#320]
 fmov d1,#0.5
 fmul d0,d0,d1
 str d0,[sp,#328]
 mov x26,#1
.Linterior_level:
 add x9,x26,#1
 cmp x9,x20
 b.hs .Lend_levels
 mov x27,x21
.Linterior_row:
 madd x28,x26,x19,x27
 ARRAY d0,6,x28
 ldr d1,[sp,#328]
 fmul d4,d1,d0
 add x10,x28,x19
 sub x11,x28,x19
 ARRAY d0,10,x10
 ARRAY d1,10,x11
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,4,x28
 ARRAY d0,11,x10
 ARRAY d1,11,x11
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,5,x28
 ARRAY d0,18,x10
 ARRAY d1,18,x11
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,6,x28
 add x27,x27,#1
 cmp x27,x22
 b.lo .Linterior_row
 add x26,x26,#1
 b .Linterior_level
 // One-sided differences on the top and bottom model levels.
.Lend_levels:
 mov x27,x21
.Lend_row:
 mov x28,x27
 ARRAY d0,6,x28
 ldr d1,[sp,#320]
 fmul d4,d1,d0
 add x10,x28,x19
 ARRAY d0,10,x10
 ARRAY d1,10,x28
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,4,x28
 ARRAY d0,11,x10
 ARRAY d1,11,x28
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,5,x28
 ARRAY d0,18,x10
 ARRAY d1,18,x28
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,6,x28
 sub x9,x20,#1
 madd x28,x9,x19,x27
 ARRAY d0,6,x28
 ldr d1,[sp,#320]
 fmul d4,d1,d0
 sub x10,x28,x19
 ARRAY d0,10,x28
 ARRAY d1,10,x10
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,4,x28
 ARRAY d0,11,x28
 ARRAY d1,11,x10
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,5,x28
 ARRAY d0,18,x28
 ARRAY d1,18,x10
 fsub d0,d0,d1
 fmul d0,d0,d4
 STORE_SCRATCH d0,6,x28
 add x27,x27,#1
 cmp x27,x22
 b.lo .Lend_row
 // Ertel potential vorticity in the exact source product and sum order.
 mov x26,#0
.Lvorticity_level:
 mov x27,x21
.Lvorticity_row:
 madd x28,x26,x19,x27
 ARRAY d0,9,x28
 ARRAY d1,8,x27
 fadd d0,d0,d1
 fneg d0,d0
 LOAD_SCRATCH d1,6,x28
 fmul d0,d0,d1
 LOAD_SCRATCH d1,5,x28
 LOAD_SCRATCH d2,0,x28
 fmul d1,d1,d2
 fadd d0,d0,d1
 LOAD_SCRATCH d1,4,x28
 LOAD_SCRATCH d2,1,x28
 fmul d1,d1,d2
 fsub d0,d0,d1
 ldr x9,[sp,#264]
 str d0,[x9,x28,lsl#3]
 add x27,x27,#1
 cmp x27,x22
 b.lo .Lvorticity_row
 add x26,x26,#1
 cmp x26,x20
 b.lo .Lvorticity_level
 mov x0,x23
 bl free
 ldr x18,[sp,#96]
 mov w0,#0
 b .Lreturn
.Lallocation_failed:
 mov w0,#1
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
 add sp,sp,#512
 ret
.size md2asm_runtime_potential_temperature_and_vorticity,.-md2asm_runtime_potential_temperature_and_vorticity
.section .note.GNU-stack,"",%progbits
