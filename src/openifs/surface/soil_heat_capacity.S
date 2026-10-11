/* Apparent soil capacity from formulations/openifs/surface/soil_heat_capacity.md.
 * Complete GNU descriptors and the 16-address ABI are in
 * skills/md2asm/references/openifs/surface/srfrcg.md. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL md2asm_srfrcg
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
.macro ARG reg,index
 ldr \reg,[x28,#(160+8*\index)]
.endm
.macro VECTOR reg,record
 ldr x9,[x28,#(320+56*\record)]
 ldr x10,[x28,#(328+56*\record)]
 mul x10,x10,x19
 ldr \reg,[x9,x10]
.endm
.macro MATRIX reg,record
 ldr x9,[x28,#(320+56*\record)]
 ldr x10,[x28,#(328+56*\record)]
 ldr x11,[x28,#(336+56*\record)]
 mul x10,x10,x19
 madd x10,x11,x24,x10
 ldr \reg,[x9,x10]
.endm
.macro STORE reg
 ldr x9,[x28,#712]
 ldr x10,[x28,#720]
 ldr x11,[x28,#728]
 mul x10,x10,x19
 madd x10,x11,x24,x10
 str \reg,[x9,x10]
.endm
ORIGINAL_SYMBOL:
 mov x17,sp
 sub sp,sp,#1024
 stp x19,x20,[sp,#0]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 mov x28,sp
 stp x0,x1,[sp,#160]
 stp x2,x3,[sp,#176]
 stp x4,x5,[sp,#192]
 stp x6,x7,[sp,#208]
 add x9,sp,#224
 mov x10,#8
.Lcapacity_copy_args:
 ldr x11,[x17],#8
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Lcapacity_copy_args
 mrs x9,fpcr
 cbnz x9,.Lcapacity_invalid
 mov x10,#0
.Lcapacity_pointer_check:
 add x9,x28,#160
 ldr x11,[x9,x10,lsl #3]
 cbz x11,.Lcapacity_invalid
 mov x12,#7
 cmp x10,#5
 b.hs .Lcapacity_pointer_alignment
 mov x12,#3
.Lcapacity_pointer_alignment:
 tst x11,x12
 b.ne .Lcapacity_invalid
 add x10,x10,#1
 cmp x10,#16
 b.lt .Lcapacity_pointer_check
 ARG x9,2
 ldrsw x20,[x9]
 cmp x20,#1
 b.lt .Lcapacity_invalid
 cmp x20,#4096
 b.gt .Lcapacity_invalid
 ARG x9,4
 ldrsw x21,[x9]
 cmp x21,#1
 b.lt .Lcapacity_invalid
 cmp x21,#512
 b.gt .Lcapacity_invalid
 ARG x9,0
 ldrsw x22,[x9]
 subs x22,x22,#1
 b.lt .Lcapacity_invalid
 cmp x22,x20
 b.gt .Lcapacity_invalid
 ARG x9,1
 ldrsw x23,[x9]
 cmp x23,#0
 b.lt .Lcapacity_invalid
 cmp x23,x20
 b.gt .Lcapacity_invalid
 ARG x9,3
 ldr w0,[x9]
 cmp w0,#1
 b.lt .Lcapacity_invalid
 cmp w0,#16
 b.gt .Lcapacity_invalid
ARG x0,5
mov x1,#1
mov x2,#2
mov x3,#4
mov x4,x20
mov x5,#1
add x6,x28,#320
bl .Lcapacity_decode
ARG x0,6
mov x1,#1
mov x2,#2
mov x3,#4
mov x4,x20
mov x5,#1
add x6,x28,#376
bl .Lcapacity_decode
ARG x0,7
mov x1,#2
mov x2,#3
mov x3,#8
mov x4,x20
mov x5,x21
add x6,x28,#432
bl .Lcapacity_decode
ARG x0,8
mov x1,#1
mov x2,#1
mov x3,#4
mov x4,x20
mov x5,#1
add x6,x28,#488
bl .Lcapacity_decode
ARG x0,9
mov x1,#1
mov x2,#3
mov x3,#8
mov x4,x20
mov x5,#1
add x6,x28,#544
bl .Lcapacity_decode
ARG x0,10
mov x1,#1
mov x2,#3
mov x3,#8
mov x4,x20
mov x5,#1
add x6,x28,#600
bl .Lcapacity_decode
ARG x0,11
mov x1,#1
mov x2,#3
mov x3,#8
mov x4,x20
mov x5,#1
add x6,x28,#656
bl .Lcapacity_decode
ARG x0,15
mov x1,#2
mov x2,#3
mov x3,#8
mov x4,x20
mov x5,x21
add x6,x28,#712
bl .Lcapacity_decode
ARG x9,13
 ldr w25,[x9,#440]
 cmp w25,#1
 b.hi .Lcapacity_invalid
 cbz w25,.Lcapacity_scalar_tables
 add x0,x9,#944
 mov x1,#1
 mov x2,#3
 mov x3,#8
 mov x4,#1
 mov x5,#1
 add x6,x28,#768
 bl .Lcapacity_decode
 ARG x9,13
 add x0,x9,#1520
 mov x1,#1
 mov x2,#3
 mov x3,#8
 mov x4,#1
 mov x5,#1
 add x6,x28,#824
 bl .Lcapacity_decode
.Lcapacity_scalar_tables:
 ldr x0,[x28,#736]
 ldr x1,[x28,#744]
 mov x2,#0
.Lcapacity_input_data_separation:
 mov x9,#56
 madd x9,x2,x9,x28
 ldr x3,[x9,#344]
 ldr x4,[x9,#352]
 bl .Lcapacity_separate
 add x2,x2,#1
 cmp x2,#7
 b.lt .Lcapacity_input_data_separation
 cbz w25,.Lcapacity_table_separation_done
 ldr x3,[x28,#792]
 ldr x4,[x28,#800]
 bl .Lcapacity_separate
 ldr x3,[x28,#848]
 ldr x4,[x28,#856]
 bl .Lcapacity_separate
.Lcapacity_table_separation_done:
 mov x2,#0
.Lcapacity_argument_owner_separation:
 add x9,x28,#160
 ldr x3,[x9,x2,lsl #3]
 mov x5,#4
 cmp x2,#5
 b.lt .Lcapacity_argument_length
 mov x5,#64
 cmp x2,#7
 b.eq .Lcapacity_rank_two_length
 cmp x2,#15
 b.eq .Lcapacity_rank_two_length
 cmp x2,#12
 b.eq .Lcapacity_constants_length
 cmp x2,#13
 b.eq .Lcapacity_soil_length
 cmp x2,#14
 b.eq .Lcapacity_urban_length
 b .Lcapacity_argument_length
.Lcapacity_rank_two_length:
 mov x5,#88
 b .Lcapacity_argument_length
.Lcapacity_constants_length:
 mov x5,#128
 b .Lcapacity_argument_length
.Lcapacity_soil_length:
 mov x5,#2416
 b .Lcapacity_argument_length
.Lcapacity_urban_length:
 mov x5,#472
.Lcapacity_argument_length:
 adds x4,x3,x5
 b.cs .Lcapacity_invalid
 bl .Lcapacity_separate
 add x2,x2,#1
 cmp x2,#16
 b.lt .Lcapacity_argument_owner_separation
 ARG x9,13
 ldr d11,[x9,#208]
movz x17,#62915
movk x17,#23592,lsl #16
movk x17,#8847,lsl #32
movk x17,#16497,lsl #48
fmov d0,x17
fcmp d11,d0
b.ne .Lcapacity_invalid
ldr d12,[x9,#216]
movz x17,#62915
movk x17,#23592,lsl #16
movk x17,#57999,lsl #32
movk x17,#16496,lsl #48
fmov d0,x17
fcmp d12,d0
b.ne .Lcapacity_invalid
ldr d13,[x9,#224]
movz x17,#62915
movk x17,#23592,lsl #16
movk x17,#655,lsl #32
movk x17,#16497,lsl #48
fmov d0,x17
fcmp d13,d0
b.ne .Lcapacity_invalid
ldr d14,[x9,#232]
movz x17,#11544
movk x17,#21572,lsl #16
movk x17,#8699,lsl #32
movk x17,#16361,lsl #48
fmov d0,x17
fcmp d14,d0
b.ne .Lcapacity_invalid
ldr d15,[x9,#424]
fcmp d15,d15
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d15,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#41472,lsl #16
movk x17,#6804,lsl #32
movk x17,#17005,lsl #48
fmov d0,x17
fcmp d15,d0
b.gt .Lcapacity_invalid
ARG x9,12
ldr d8,[x9,#64]
fcmp d8,d8
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d8,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#52581,lsl #32
movk x17,#16845,lsl #48
fmov d0,x17
fcmp d8,d0
b.gt .Lcapacity_invalid
adrp x9,:got:__yos_thf_MOD_rhoh2o
ldr x9,[x9,:got_lo12:__yos_thf_MOD_rhoh2o]
ldr d7,[x9]
fcmp d7,d7
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d7,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#33920,lsl #32
movk x17,#16686,lsl #48
fmov d0,x17
fcmp d7,d0
b.gt .Lcapacity_invalid
fmul d8,d8,d7
cbnz w25,.Lcapacity_selected_tables
ARG x9,13
ldr d6,[x9,#8]
fcmp d6,d6
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d6,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#41472,lsl #16
movk x17,#6804,lsl #32
movk x17,#17005,lsl #48
fmov d0,x17
fcmp d6,d0
b.gt .Lcapacity_invalid
ldr d7,[x9,#128]
fcmp d7,d7
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#0,lsl #48
fmov d0,x17
fcmp d7,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d7,d0
b.gt .Lcapacity_invalid
.Lcapacity_selected_tables:
 ARG x9,3
 ldr w0,[x9]
 cmp w0,#9
 b.le .Lcapacity_no_urban_constant
 ARG x9,14
 ldr d6,[x9,#408]
fcmp d6,d6
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d6,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#41472,lsl #16
movk x17,#6804,lsl #32
movk x17,#17005,lsl #48
fmov d0,x17
fcmp d6,d0
b.gt .Lcapacity_invalid
.Lcapacity_no_urban_constant:
 mov x19,x22
 cmp x19,x23
 b.ge .Lcapacity_return
.Lcapacity_admit_column:
 VECTOR w0,0
 cmp w0,#1
 b.hi .Lcapacity_invalid
 VECTOR w1,1
 cmp w1,#1
 b.hi .Lcapacity_invalid
 cbz w0,.Lcapacity_admit_next
 VECTOR d6,4
fcmp d6,d6
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#0,lsl #48
fmov d0,x17
fcmp d6,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d6,d0
b.gt .Lcapacity_invalid
VECTOR d7,5
fcmp d7,d7
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#0,lsl #48
fmov d0,x17
fcmp d7,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d7,d0
b.gt .Lcapacity_invalid
fadd d6,d6,d7
fmov d0,#1.0
fcmp d6,d0
b.gt .Lcapacity_invalid
ARG x9,3
ldr w0,[x9]
cmp w0,#9
b.le .Lcapacity_admit_soil_kind
VECTOR d6,6
fcmp d6,d6
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#0,lsl #48
fmov d0,x17
fcmp d6,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d6,d0
b.gt .Lcapacity_invalid
.Lcapacity_admit_soil_kind:
 cbz w25,.Lcapacity_admit_temperature
 VECTOR w26,3
 ldr x9,[x28,#816]
 ldr x10,[x28,#808]
 add x10,x10,x9
 cmp x26,x9
 b.lt .Lcapacity_invalid
 cmp x26,x10
 b.ge .Lcapacity_invalid
 ldr x11,[x28,#768]
 ldr x12,[x28,#776]
 sub x9,x26,x9
 mul x9,x9,x12
 ldr d6,[x11,x9]
fcmp d6,d6
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#0,lsl #48
fmov d0,x17
fcmp d6,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d6,d0
b.gt .Lcapacity_invalid
ldr x9,[x28,#872]
 ldr x10,[x28,#864]
 add x10,x10,x9
 cmp x26,x9
 b.lt .Lcapacity_invalid
 cmp x26,x10
 b.ge .Lcapacity_invalid
 ldr x11,[x28,#824]
 ldr x12,[x28,#832]
 sub x9,x26,x9
 mul x9,x9,x12
 ldr d6,[x11,x9]
fcmp d6,d6
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16368,lsl #48
fmov d0,x17
fcmp d6,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#41472,lsl #16
movk x17,#6804,lsl #32
movk x17,#17005,lsl #48
fmov d0,x17
fcmp d6,d0
b.gt .Lcapacity_invalid
.Lcapacity_admit_temperature:
 mov x24,#0
.Lcapacity_temperature_check:
 MATRIX d6,2
fcmp d6,d6
b.vs .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#16473,lsl #48
fmov d0,x17
fcmp d6,d0
b.lt .Lcapacity_invalid
movz x17,#0
movk x17,#0,lsl #16
movk x17,#16384,lsl #32
movk x17,#16511,lsl #48
fmov d0,x17
fcmp d6,d0
b.gt .Lcapacity_invalid
add x24,x24,#1
 cmp x24,x21
 b.lt .Lcapacity_temperature_check
.Lcapacity_admit_next:
 add x19,x19,#1
 cmp x19,x23
 b.lt .Lcapacity_admit_column
 mov x19,x22
.Lcapacity_column:
 VECTOR w0,0
 cbz w0,.Lcapacity_not_land
 cbz w25,.Lcapacity_scalar_soil
 VECTOR w26,3
 ldr x9,[x28,#816]
 sub x9,x26,x9
 ldr x10,[x28,#776]
 mul x9,x9,x10
 ldr x10,[x28,#768]
 ldr d7,[x10,x9]
 ldr x9,[x28,#872]
 sub x9,x26,x9
 ldr x10,[x28,#832]
 mul x9,x9,x10
 ldr x10,[x28,#824]
 ldr d9,[x10,x9]
 b .Lcapacity_soil_selected
.Lcapacity_scalar_soil:
 ARG x9,13
 ldr d7,[x9,#128]
 ldr d9,[x9,#8]
.Lcapacity_soil_selected:
 VECTOR d0,4
 VECTOR d1,5
 fadd d0,d0,d1
 fmul d0,d0,d7
 fmul d10,d8,d0
 str d9,[x28,#880]
 ARG x9,3
 ldr w0,[x9]
 cmp w0,#9
 b.le .Lcapacity_land_levels
 VECTOR d0,6
 fmov d1,#1.0
 fsub d1,d1,d0
 fmul d1,d9,d1
 ARG x9,14
 ldr d2,[x9,#408]
 fmul d2,d2,d0
 fadd d1,d1,d2
 str d1,[x28,#880]
.Lcapacity_land_levels:
 mov x24,#0
.Lcapacity_land_level:
 MATRIX d0,2
 fcmp d0,d11
 b.ge .Lcapacity_no_phase
 fcmp d0,d12
 b.le .Lcapacity_no_phase
 fsub d0,d0,d13
 fmul d0,d14,d0
 bl md2asm_cos_original_rounding
movz x17,#0
movk x17,#0,lsl #16
movk x17,#0,lsl #32
movk x17,#49120,lsl #48
fmov d1,x17
fmul d1,d1,d14
fmul d0,d1,d0
b .Lcapacity_phase_ready
.Lcapacity_no_phase:
fmov d0,xzr
.Lcapacity_phase_ready:
fmul d0,d10,d0
fmov d1,d9
cbnz x24,.Lcapacity_selected_layer_capacity
ldr d1,[x28,#880]
.Lcapacity_selected_layer_capacity:
fsub d0,d1,d0
STORE d0
add x24,x24,#1
cmp x24,x21
b.lt .Lcapacity_land_level
b .Lcapacity_next_column
.Lcapacity_not_land:
 VECTOR w0,1
 mov x27,x0
 mov x24,#0
.Lcapacity_nonland_level:
 fmov d0,xzr
 cbz x27,.Lcapacity_nonland_store
 cbnz x24,.Lcapacity_nonland_store
 fmov d0,d15
.Lcapacity_nonland_store:
 STORE d0
 add x24,x24,#1
 cmp x24,x21
 b.lt .Lcapacity_nonland_level
.Lcapacity_next_column:
 add x19,x19,#1
 cmp x19,x23
 b.lt .Lcapacity_column
.Lcapacity_return:
 ldp d8,d9,[sp,#96]
 ldp d10,d11,[sp,#112]
 ldp d12,d13,[sp,#128]
 ldp d14,d15,[sp,#144]
 ldp x19,x20,[sp,#0]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x29,x30,[sp,#80]
 add sp,sp,#1024
 ret
/* Decode complete data bounds without writing any caller state. */
.Lcapacity_decode:
 ldr x7,[x0]
 cbz x7,.Lcapacity_invalid
 sub x8,x3,#1
 tst x7,x8
 b.ne .Lcapacity_invalid
 ldr x8,[x0,#16]
 cmp x8,x3
 b.ne .Lcapacity_invalid
 ldr w8,[x0,#24]
 cbnz w8,.Lcapacity_invalid
 ldrb w8,[x0,#28]
 cmp x8,x1
 b.ne .Lcapacity_invalid
 ldrb w8,[x0,#29]
 cmp x8,x2
 b.ne .Lcapacity_invalid
 ldrh w8,[x0,#30]
 cbnz w8,.Lcapacity_invalid
 ldr x8,[x0,#32]
 cmp x8,x3
 b.ne .Lcapacity_invalid
 ldr x8,[x0,#40]
 cmp x8,#0
 cneg x9,x8,lt
 cmp x9,#1
 b.lt .Lcapacity_invalid
 cmp x9,#4096
 b.gt .Lcapacity_invalid
 ldr x10,[x0,#48]
 ldr x11,[x0,#56]
 subs x11,x11,x10
 b.vs .Lcapacity_invalid
 adds x11,x11,#1
 b.vs .Lcapacity_invalid
 cmp x11,x4
 b.lt .Lcapacity_invalid
 cmp x11,#4096
 b.gt .Lcapacity_invalid
 str x11,[x6,#40]
 str x10,[x6,#48]
 sub x10,x11,#1
 mul x10,x10,x8
 mov x12,#0
 mov x13,#0
 cmp x10,#0
 csel x12,x10,x12,lt
 csel x13,x10,x13,gt
 mov x14,#0
 cmp x1,#2
 b.ne .Lcapacity_decode_ranges
 ldr x14,[x0,#64]
 cmp x14,#0
 cneg x15,x14,lt
 cmp x15,#1
 b.lt .Lcapacity_invalid
 mov x16,#1048576
 cmp x15,x16
 b.gt .Lcapacity_invalid
 sub x16,x11,#1
 mul x16,x16,x9
 add x16,x16,#1
 cmp x15,x16
 b.lt .Lcapacity_invalid
 ldr x15,[x0,#72]
 ldr x16,[x0,#80]
 subs x16,x16,x15
 b.vs .Lcapacity_invalid
 adds x16,x16,#1
 b.vs .Lcapacity_invalid
 cmp x16,x5
 b.lt .Lcapacity_invalid
 cmp x16,#512
 b.gt .Lcapacity_invalid
 sub x16,x16,#1
 mul x16,x16,x14
 mov x15,#0
 cmp x16,#0
 csel x15,x16,x15,lt
 add x12,x12,x15
 mov x15,#0
 cmp x16,#0
 csel x15,x16,x15,gt
 add x13,x13,x15
.Lcapacity_decode_ranges:
 mul x8,x8,x3
 mul x14,x14,x3
 str x7,[x6]
 str x8,[x6,#8]
 str x14,[x6,#16]
 neg x12,x12
 mul x12,x12,x3
 mul x13,x13,x3
 subs x12,x7,x12
 b.lo .Lcapacity_invalid
 adds x13,x7,x13
 b.cs .Lcapacity_invalid
 adds x13,x13,x3
 b.cs .Lcapacity_invalid
 str x12,[x6,#24]
 str x13,[x6,#32]
 ret
.Lcapacity_separate:
 cmp x0,x4
 b.hs .Lcapacity_separated
 cmp x3,x1
 b.lo .Lcapacity_invalid
.Lcapacity_separated:
 ret
.Lcapacity_invalid:
 bl abort
 brk #0
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
