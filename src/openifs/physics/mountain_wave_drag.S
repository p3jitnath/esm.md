/* Complete wind drag from formulations/openifs/physics/mountain_wave_drag.md.
 * The 19-address interface and complete private children are in
 * skills/md2asm/references/openifs/physics/gwdrag.md. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL md2asm_gwdrag
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
.macro PA reg,number
 ldr \reg,[x28,#(368+8*\number)]
.endm
.macro CA reg,number
 ldr \reg,[x28,#(528+8*\number)]
.endm
.macro READ reg,number,delta=0
 PA x9,\number
 sub x10,x24,#1
 .if \delta
 add x10,x10,#\delta
 .endif
 mul x10,x10,x20
 add x10,x10,x19
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro CHILD reg,number,delta=0
 CA x9,\number
 sub x10,x24,#1
 .if \delta
 add x10,x10,#\delta
 .endif
 mul x10,x10,x20
 add x10,x10,x19
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro PSCALAR reg,number
 PA x9,\number
 ldr \reg,[x9,x19,lsl #3]
.endm
.macro CSCALAR reg,number
 CA x9,\number
 ldr \reg,[x9,x19,lsl #3]
.endm
.macro OUTPUT reg,number
 PA x9,\number
 sub x10,x24,#1
 mul x10,x10,x20
 add x10,x10,x19
 str \reg,[x9,x10,lsl #3]
.endm
.macro PBOUND number,value
 mov x10,#\value
 str x10,[x28,#(880+8*\number)]
.endm
ORIGINAL_SYMBOL:
 mov x17,sp
 sub sp,sp,#1152
 stp x19,x20,[sp,#208]
 stp x21,x22,[sp,#224]
 stp x23,x24,[sp,#240]
 stp x25,x26,[sp,#256]
 stp x27,x28,[sp,#272]
 stp x29,x30,[sp,#288]
 stp d8,d9,[sp,#304]
 stp d10,d11,[sp,#320]
 stp d12,d13,[sp,#336]
 stp d14,d15,[sp,#352]
 mov x28,sp
 stp x0,x1,[sp,#368]
 stp x2,x3,[sp,#384]
 stp x4,x5,[sp,#400]
 stp x6,x7,[sp,#416]
 add x10,sp,#432
 mov x11,#11
.Ldrag_copy_args:
 ldr x12,[x17],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Ldrag_copy_args
 mrs x9,fpcr
 cbnz x9,.Ldrag_invalid
 mov x10,#0
.Ldrag_pointer_check:
 add x9,x28,#368
 ldr x11,[x9,x10,lsl #3]
 cbz x11,.Ldrag_invalid
 mov x12,#7
 cmp x10,#2
 b.lt .Ldrag_pointer_alignment
 cmp x10,#5
 b.gt .Ldrag_pointer_alignment
 mov x12,#3
.Ldrag_pointer_alignment:
 tst x11,x12
 b.ne .Ldrag_invalid
 add x10,x10,#1
 cmp x10,#19
 b.lt .Ldrag_pointer_check
 PA x9,4
 ldrsw x20,[x9]
 cmp x20,#1
 b.lt .Ldrag_invalid
 cmp x20,#4096
 b.gt .Ldrag_invalid
 PA x9,5
 ldrsw x21,[x9]
 cmp x21,#6
 b.lt .Ldrag_invalid
 cmp x21,#512
 b.gt .Ldrag_invalid
 PA x9,2
 ldrsw x22,[x9]
 subs x22,x22,#1
 b.lt .Ldrag_invalid
 cmp x22,x20
 b.gt .Ldrag_invalid
 PA x9,3
 ldrsw x23,[x9]
 cmp x23,#0
 b.lt .Ldrag_invalid
 cmp x23,x20
 b.gt .Ldrag_invalid
 PBOUND 0,120
 PBOUND 1,96
 PBOUND 2,4
 PBOUND 3,4
 PBOUND 4,4
 PBOUND 5,4
 add x10,x21,#1
 mul x10,x10,x20
 lsl x10,x10,#3
 str x10,[x28,#928]
 mul x10,x20,x21
 lsl x26,x10,#3
 mov x11,#7
 add x12,x28,#880
.Ldrag_full_owner_lengths:
 str x26,[x12,x11,lsl #3]
 add x11,x11,#1
 cmp x11,#12
 b.lt .Ldrag_full_owner_lengths
 lsl x10,x20,#3
 mov x11,#12
.Ldrag_scalar_owner_lengths:
 str x10,[x12,x11,lsl #3]
 add x11,x11,#1
 cmp x11,#16
 b.lt .Ldrag_scalar_owner_lengths
 mov x11,#16
.Ldrag_output_owner_lengths:
 str x26,[x12,x11,lsl #3]
 add x11,x11,#1
 cmp x11,#19
 b.lt .Ldrag_output_owner_lengths
 mov x0,#13
.Ldrag_output_overlap_outer:
 add x9,x28,#368
 add x10,x28,#880
 ldr x11,[x9,x0,lsl #3]
 ldr x12,[x10,x0,lsl #3]
 adds x12,x11,x12
 b.cs .Ldrag_invalid
 mov x1,#0
.Ldrag_output_overlap_inner:
 cmp x0,x1
 b.eq .Ldrag_output_overlap_next
 ldr x13,[x9,x1,lsl #3]
 ldr x14,[x10,x1,lsl #3]
 adds x14,x13,x14
 b.cs .Ldrag_invalid
 cmp x11,x14
 b.hs .Ldrag_output_overlap_next
 cmp x13,x12
 b.lo .Ldrag_invalid
.Ldrag_output_overlap_next:
 add x1,x1,#1
 cmp x1,#19
 b.lt .Ldrag_output_overlap_inner
 cmp x0,#13
 b.ne .Ldrag_output_overlap_increment
 mov x0,#15
.Ldrag_output_overlap_increment:
 add x0,x0,#1
 cmp x0,#19
 b.lt .Ldrag_output_overlap_outer
 PA x9,0
 ldr w0,[x9,#4]
 cmp w0,#1
 b.hi .Ldrag_invalid
 cbz w0,.Ldrag_nonlinear
 ldr d8,[x9,#96]
 b .Ldrag_chosen_drag
.Ldrag_nonlinear:
 PA x9,1
 ldr d8,[x9,#32]
.Ldrag_chosen_drag:
 fcmp d8,d8
 b.vs .Ldrag_invalid
 fcmp d8,#0.0
 b.lt .Ldrag_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#33920,lsl #32
movk x17,#16686,lsl #48
fmov d0,x17
fcmp d8,d0
b.gt .Ldrag_invalid
PA x9,1
ldr d10,[x9,#40]
fcmp d10,d10
b.vs .Ldrag_invalid
fcmp d10,#0.0
b.lt .Ldrag_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#33920,lsl #32
movk x17,#16686,lsl #48
fmov d0,x17
fcmp d10,d0
b.gt .Ldrag_invalid
ldr d11,[x9,#72]
fcmp d11,d11
b.vs .Ldrag_invalid
fcmp d11,#0.0
b.lt .Ldrag_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#33920,lsl #32
movk x17,#16686,lsl #48
fmov d0,x17
fcmp d11,d0
b.gt .Ldrag_invalid
ldr d12,[x9,#80]
fcmp d12,d12
b.vs .Ldrag_invalid
fcmp d12,#0.0
b.lt .Ldrag_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#55172,lsl #32
movk x17,#16791,lsl #48
fmov d0,x17
fcmp d12,d0
b.gt .Ldrag_invalid
ldr w0,[x9,#4]
 cmp w0,#0
 b.lt .Ldrag_invalid
 add x10,x21,#1
 cmp x0,x10
 b.gt .Ldrag_invalid
 ldr w0,[x9,#8]
 cmp w0,#1
 b.lt .Ldrag_invalid
 cmp x0,x21
 b.gt .Ldrag_invalid
 cmp x22,x23
 b.ge .Ldrag_return
 mov x19,x22
.Ldrag_new_inputs:
 PSCALAR d0,12
 fcmp d0,d0
 b.vs .Ldrag_invalid
 fcmp d0,#0.0
 b.lt .Ldrag_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#4816,lsl #32
movk x17,#16739,lsl #48
fmov d1,x17
fcmp d0,d1
b.gt .Ldrag_invalid
PSCALAR d0,15
fcmp d0,d0
b.vs .Ldrag_invalid
fcmp d0,#0.0
b.lt .Ldrag_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#33920,lsl #32
movk x17,#16686,lsl #48
fmov d1,x17
fcmp d0,d1
 b.gt .Ldrag_invalid
 add x19,x19,#1
 cmp x19,x23
 b.lt .Ldrag_new_inputs
 mov x0,#56
 mul x0,x0,x21
 add x0,x0,#120
 mul x0,x0,x20
 bl malloc
 cbz x0,.Ldrag_invalid
 mov x25,x0
 str x25,[x28,#800]
 PA x9,1
 str x9,[x28,#528]
 PA x9,2
 str x9,[x28,#536]
 PA x9,3
 str x9,[x28,#544]
 PA x9,4
 str x9,[x28,#552]
 PA x9,5
 str x9,[x28,#560]
 mov x10,x25
 mov x11,#5
 lsl x12,x20,#2
 add x9,x28,#528
.Ldrag_integer_fields:
 str x10,[x9,x11,lsl #3]
 add x10,x10,x12
 add x11,x11,#1
 cmp x11,#11
 b.lt .Ldrag_integer_fields
PA x9,6
str x9,[x28,#616]
PA x9,7
str x9,[x28,#624]
PA x9,10
str x9,[x28,#632]
PA x9,11
str x9,[x28,#640]
PA x9,9
str x9,[x28,#648]
PA x9,8
str x9,[x28,#656]
PA x9,12
str x9,[x28,#664]
add x9,x28,#528
 mov x11,#18
 add x12,x21,#1
 mul x12,x12,x20
 lsl x12,x12,#3
.Ldrag_half_fields:
 str x10,[x9,x11,lsl #3]
 add x10,x10,x12
 add x11,x11,#1
 cmp x11,#24
 b.lt .Ldrag_half_fields
 str x10,[x28,#720]
 add x10,x10,x26
 str x10,[x28,#728]
 lsl x12,x20,#3
 add x10,x10,x12
 str x10,[x28,#736]
 add x10,x10,x12
 PA x9,14
 str x9,[x28,#744]
 PA x9,13
 str x9,[x28,#752]
 mov x11,#29
 add x9,x28,#528
.Ldrag_remaining_scalars:
 str x10,[x9,x11,lsl #3]
 add x10,x10,x12
 add x11,x11,#1
 cmp x11,#33
 b.lt .Ldrag_remaining_scalars
 mov x19,x22
 CA x11,5
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16457,lsl #48
fmov d1,x17
 .Ldrag_mask:
 PSCALAR d0,12
 fcmp d0,d1
 cset w0,gt
 str w0,[x11,x19,lsl #2]
 add x19,x19,#1
 cmp x19,x23
 b.lt .Ldrag_mask
 add x9,x28,#592
 mov x10,sp
 mov x11,#25
.Ldrag_setup_stack:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Ldrag_setup_stack
 add x9,x28,#528
 ldp x0,x1,[x9,#0]
 ldp x2,x3,[x9,#16]
 ldp x4,x5,[x9,#32]
 ldp x6,x7,[x9,#48]
 bl md2asm_gwsetup_drag_child
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 ldr d9,[x9]
 mov x19,x22
 add x24,x21,#1
.Ldrag_surface_stress:
 CA x9,5
 ldr w0,[x9,x19,lsl #2]
 fmov d0,xzr
 cbz w0,.Ldrag_store_surface
 CA x9,8
 ldr w0,[x9,x19,lsl #2]
 sub x0,x0,#1
 mul x0,x0,x20
 add x0,x0,x19
 PA x9,8
 ldr d0,[x9,x0,lsl #3]
 fdiv d0,d0,d9
 PSCALAR d1,12
 fmov d2,#3.0
 fmul d2,d2,d1
 fsub d2,d2,d0
 fmov d0,xzr
 fmax d2,d2,d0
 fmov d0,#2.0
 fmul d2,d2,d0
 fmul d2,d2,d2
 CHILD d0,18
 fmul d0,d8,d0
 PSCALAR d3,15
 fmul d0,d0,d3
 fmul d0,d0,d2
 fmov d2,#9.0
 fdiv d0,d0,d2
 fdiv d0,d0,d1
 CHILD d1,22
 fmul d0,d0,d1
 CSCALAR d1,32
 fmul d0,d0,d1
 CHILD d1,20
 fsqrt d1,d1
 fmul d0,d0,d1
.Ldrag_store_surface:
 CA x9,21
 mul x10,x21,x20
 add x10,x10,x19
 str d0,[x9,x10,lsl #3]
 add x19,x19,#1
 cmp x19,x23
 b.lt .Ldrag_surface_stress
CA x9,7
str x9,[sp,#0]
CA x9,8
str x9,[sp,#8]
CA x9,9
str x9,[sp,#16]
CA x9,10
str x9,[sp,#24]
CA x9,18
str x9,[sp,#40]
CA x9,20
str x9,[sp,#48]
CA x9,22
str x9,[sp,#56]
CA x9,19
str x9,[sp,#64]
CA x9,21
str x9,[sp,#72]
CA x9,32
str x9,[sp,#80]
PA x9,6
str x9,[sp,#32]
PA x9,15
str x9,[sp,#88]
PA x9,12
str x9,[sp,#96]
PA x0,0
 PA x1,1
 PA x2,2
 PA x3,3
 PA x4,4
 PA x5,5
 CA x6,5
 CA x7,6
 bl md2asm_gwprofil_drag_child
 mov x19,x22
.Ldrag_column:
 mov x24,#1
.Ldrag_level:
 fmov d0,xzr
 OUTPUT d0,16
 OUTPUT d0,17
 OUTPUT d0,18
 CA x9,5
 ldr w0,[x9,x19,lsl #2]
 cbz w0,.Ldrag_next_level
 READ d0,6,1
 READ d1,6,0
 fsub d3,d0,d1
 READ d0,7
 fcmp d0,d12
 b.lt .Ldrag_upper_pressure
 CHILD d0,21,1
 CHILD d1,21
 fsub d0,d0,d1
 fneg d1,d9
 fmul d0,d1,d0
 mov x0,x24
 add x24,x21,#1
 CHILD d1,22
 mov x24,x0
 fmul d1,d3,d1
 fdiv d0,d0,d1
 b .Ldrag_tendency_factor
.Ldrag_upper_pressure:
 PA x9,1
 ldr w0,[x9,#8]
 mul x0,x0,x20
 add x0,x0,x19
 PA x9,6
 ldr d1,[x9,x0,lsl #3]
 ldr d2,[x9,x19,lsl #3]
 fsub d1,d1,d2
 fmul d1,d1,d1
 CA x9,21
 ldr d0,[x9,x0,lsl #3]
 ldr d2,[x9,x19,lsl #3]
 fsub d0,d0,d2
 fneg d2,d9
 fmul d0,d2,d0
 fmul d0,d0,d3
 mov x0,x24
 add x24,x21,#1
 CHILD d2,22
 mov x24,x0
 fmul d1,d2,d1
 fdiv d0,d0,d1
.Ldrag_tendency_factor:
 str d0,[x28,#808]
 CSCALAR d1,25
 CSCALAR d2,26
 CSCALAR d3,30
 CSCALAR d4,31
 fmul d5,d1,d3
 fmul d6,d2,d4
 fsub d5,d5,d6
 fmul d5,d5,d0
 CSCALAR d6,32
 fdiv d5,d5,d6
 fmul d2,d2,d3
 fmul d1,d1,d4
 fadd d2,d2,d1
 fmul d2,d2,d0
 fdiv d2,d2,d6
 PA x9,1
 ldr w0,[x9,#4]
 cmp x24,x0
 b.ge .Ldrag_store_explicit
 fmov x1,d5
 fabs d5,d5
 fmin d5,d5,d11
 fmov x0,d5
 lsr x1,x1,#63
 bfi x0,x1,#63,#1
 fmov d5,x0
 fmov x1,d2
 fabs d2,d2
 fmin d2,d2,d11
 fmov x0,d2
 lsr x1,x1,#63
 bfi x0,x1,#63,#1
 fmov d2,x0
.Ldrag_store_explicit:
 OUTPUT d5,16
 OUTPUT d2,17
 CA x9,8
 ldr w0,[x9,x19,lsl #2]
 cmp x24,x0
 b.lt .Ldrag_next_level
 PSCALAR d14,13
 fmul d15,d14,d14
 fmov d6,#1.0
movz x17,#55050
movk x17,#28835,lsl #16
movk x17,#2621,lsl #32
movk x17,#16327,lsl #48
fmov d0,x17
fmul d0,d0,d14
fsub d6,d6,d0
movz x17,#5243
movk x17,#18350,lsl #16
movk x17,#31457,lsl #32
movk x17,#16292,lsl #48
fmov d0,x17
fmul d0,d0,d15
fsub d6,d6,d0
movz x17,#7864
movk x17,#60293,lsl #16
movk x17,#47185,lsl #32
movk x17,#16350,lsl #48
fmov d0,x17
fmul d7,d0,d14
movz x17,#13107
movk x17,#13107,lsl #16
movk x17,#13107,lsl #32
movk x17,#16339,lsl #48
fmov d0,x17
fmul d0,d0,d15
fadd d7,d7,d0
str d6,[x28,#1040]
str d7,[x28,#1048]
CHILD d0,23
bl md2asm_cos_original_rounding
fmul d0,d0,d0
fmov d1,#1.0
fsub d1,d1,d0
str d0,[x28,#1056]
str d1,[x28,#1064]
PSCALAR d2,15
fmul d2,d10,d2
PSCALAR d3,12
fmov d4,#2.0
fmul d3,d4,d3
fdiv d2,d2,d3
str d2,[x28,#1072]
READ d2,10
READ d3,11
fmul d2,d2,d2
fmul d3,d3,d3
fadd d2,d2,d3
fsqrt d2,d2
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16352,lsl #48
fmov d3,x17
fmul d2,d3,d2
 str d2,[x28,#1080]
 ldr d6,[x28,#1040]
 ldr d7,[x28,#1048]
 fmul d6,d6,d0
 fmul d7,d7,d1
 fadd d6,d6,d7
 str d6,[x28,#1088]
 fmul d2,d15,d1
 fadd d2,d0,d2
 fmul d3,d15,d0
 fadd d3,d3,d1
 fdiv d2,d2,d3
 fsqrt d2,d2
 fmov d3,#1.0
 fdiv d2,d3,d2
 fmov d3,#2.0
 fsub d2,d3,d2
 fmov d3,xzr
 fmax d2,d3,d2
 ldr d3,[x28,#1072]
 fmul d2,d2,d3
 CHILD d3,24
 fmul d2,d2,d3
 ldr d3,[x28,#1088]
 fmul d2,d2,d3
 ldr d3,[x28,#1080]
 fmul d2,d2,d3
 OUTPUT d2,18
 fmov d0,xzr
 OUTPUT d0,16
 OUTPUT d0,17
.Ldrag_next_level:
 add x24,x24,#1
 cmp x24,x21
 b.le .Ldrag_level
 add x19,x19,#1
 cmp x19,x23
 b.lt .Ldrag_column
 ldr x0,[x28,#800]
 bl free
.Ldrag_return:
 ldp d8,d9,[sp,#304]
 ldp d10,d11,[sp,#320]
 ldp d12,d13,[sp,#336]
 ldp d14,d15,[sp,#352]
 ldp x19,x20,[sp,#208]
 ldp x21,x22,[sp,#224]
 ldp x23,x24,[sp,#240]
 ldp x25,x26,[sp,#256]
 ldp x27,x28,[sp,#272]
 ldp x29,x30,[sp,#288]
 add sp,sp,#1152
 ret
.Ldrag_invalid:
 bl abort
 brk #0
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
