/* Apply the source packing rules to a borrowed ecCodes handle.
 * Contract skills/md2asm/references/openifs/output/runtime_grib_packing_policy.md
 * The caller owns the handle and complete field values.
 * Public ecCodes and Multio services remain explicit.
 */
.arch armv8.2-a
.macro packing_long key
 mov x0,x19
 adrp x1,\key
 add x1,x1,:lo12:\key
 bl codes_set_long
 cbnz w0,.Lpacking_return
.endm
.macro packing_double key
 mov x0,x19
 adrp x1,\key
 add x1,x1,:lo12:\key
 bl codes_set_double
 cbnz w0,.Lpacking_return
.endm
.text
.p2align 4
.global md2asm_set_runtime_grib_packing
.type md2asm_set_runtime_grib_packing,%function
md2asm_set_runtime_grib_packing:
 mrs x11,fpcr
 cbnz x11,.Lpacking_invalid
 cbz x0,.Lpacking_invalid
 cbz x2,.Lpacking_invalid
 cbz x6,.Lpacking_invalid
 tbnz w1,#31,.Lpacking_invalid
 cmp w4,#1
 b.hi .Lpacking_invalid
 cmp w5,#1
 b.hi .Lpacking_invalid
 sub x11,x3,#1
 cmp x11,#31
 b.hi .Lpacking_invalid
 sub x11,x7,#1
 mov x12,#0x7ffffffe
 cmp x11,x12
 b.hi .Lpacking_invalid
 adds x11,x6,x7,lsl#3
 b.cs .Lpacking_invalid
 adds x11,x2,x3
 b.cs .Lpacking_invalid
 ldr w9,[sp]
 ldr x10,[sp,#8]
 cbz x10,.Lpacking_invalid
 tst x10,#3
 b.ne .Lpacking_invalid
 tst x6,#7
 b.ne .Lpacking_invalid
 adds x11,x10,#24
 b.cs .Lpacking_invalid
 ldr w11,[x10,#8]
 cmp w11,#64
 b.hi .Lpacking_invalid
 ldr w11,[x10,#12]
 cmp w11,#64
 b.hi .Lpacking_invalid
 ldr w11,[x10,#16]
 cmp w11,#1
 b.hi .Lpacking_invalid
 ldr w11,[x10,#20]
 cmp w11,#1
 b.hi .Lpacking_invalid
 cbz w4,.Lpacking_scalar_shape_valid
 sub w11,w9,#1
 cmp w11,#4095
 b.hi .Lpacking_invalid
 add w11,w9,#1
 add w12,w9,#2
 mul w11,w11,w12
 cmp x7,x11
 b.ne .Lpacking_invalid
.Lpacking_scalar_shape_valid:
 mov x11,#0
.Lpacking_level_scan:
 ldrb w12,[x2,x11]
 cbz w12,.Lpacking_invalid
 add x11,x11,#1
 cmp x11,x3
 b.ne .Lpacking_level_scan
 sub x11,x3,#1
 ldrb w12,[x2,x11]
 cmp w12,#32
 b.eq .Lpacking_invalid
 mov x11,#0
 movz x13,#0x7ff0,lsl#48
.Lpacking_finite_scan:
 ldr x12,[x6,x11,lsl#3]
 and x12,x12,#0x7ff0000000000000
 cmp x12,x13
 b.eq .Lpacking_invalid
 add x11,x11,#1
 cmp x11,x7
 b.ne .Lpacking_finite_scan
 sub sp,sp,#256
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov w20,w1
 mov x22,x2
 mov x23,x3
 mov x24,x6
 mov x25,x7
 mov x27,x10
 mov w28,w9
 mov w26,w4
 orr w26,w26,w5,lsl#2
 str w20,[sp,#132]
 str w28,[sp,#136]
 str w25,[sp,#140]
 ldrb w9,[x22]
 cmp w9,#109
 b.eq .Lpacking_model_level
 cmp x23,#2
 b.lo .Lpacking_dispatch
 ldrh w9,[x22]
 mov w10,#0x4c4d
 cmp w9,w10
 b.ne .Lpacking_dispatch
.Lpacking_model_level:
 orr w26,w26,#2
.Lpacking_dispatch:
 tbz w26,#0,.Lpacking_grid
 mov w2,#16
 cmp w20,#152
 b.ne .Lpacking_spectral_bits
 tbz w26,#1,.Lpacking_spectral_bits
 ldp w9,w10,[x27]
 cmp w9,w10
 b.eq .Lpacking_spectral_bits
 ldr w2,[x27,#8]
.Lpacking_spectral_bits:
 packing_long .Lpacking_bits
 cmp w28,#213
 mov w9,#20
 mov w10,#10
 csel w21,w9,w10,ge
 cmp w21,w28
 csel w21,w21,w28,le
 str w21,[sp,#144]
 tbz w26,#1,.Lpacking_fit
 cmp w20,#129
 b.ne .Lpacking_force_lnsp
 ldr w9,[x27,#16]
 cbnz w9,.Lpacking_half
.Lpacking_force_lnsp:
 cmp w20,#152
 b.ne .Lpacking_fit
 tbnz w26,#2,.Lpacking_fit
 ldr w9,[x27,#20]
 cbnz w9,.Lpacking_half
.Lpacking_fit:
 cmp w21,w28
 b.ge .Lpacking_zero
 add x0,sp,#136
 add x1,sp,#140
 mov x2,x24
 add x3,sp,#144
 add x4,sp,#152
 add x5,sp,#160
 bl md2asm_fitspectrum_runtime_rounding
 ldr d0,[sp,#160]
 fneg d0,d0
 adrp x9,.Lpacking_limit
 ldr d1,[x9,:lo12:.Lpacking_limit]
 fneg d2,d1
 fminnm d0,d0,d1
 fmaxnm d0,d0,d2
 b .Lpacking_operator
.Lpacking_half:
 fmov d0,#0.5
 b .Lpacking_operator
.Lpacking_zero:
 fmov d0,xzr
.Lpacking_operator:
 packing_double .Lpacking_operator_key
 mov w2,w21
 packing_long .Lpacking_subset_j
 mov w2,w21
 packing_long .Lpacking_subset_k
 mov w2,w21
 packing_long .Lpacking_subset_m
 b .Lpacking_return
.Lpacking_grid:
 mov x9,#0
 mov x10,#-1
 lsr x10,x10,#1
 movz x11,#0x0010,lsl#48
 sub x10,x10,x11
.Lpacking_missing_scan:
 ldr x11,[x24,x9,lsl#3]
 cmp x11,x10
 b.eq .Lpacking_missing
 add x9,x9,#1
 cmp x9,x25
 b.ne .Lpacking_missing_scan
 b .Lpacking_grid_policy
.Lpacking_missing:
 mov x2,#1
 packing_long .Lpacking_bitmap
 mov x9,#-1
 lsr x9,x9,#1
 movz x10,#0x0010,lsl#48
 sub x9,x9,x10
 fmov d0,x9
 packing_double .Lpacking_missing_key
.Lpacking_grid_policy:
 ldr w2,[x27,#12]
 cmp w2,#0
 b.le .Lpacking_grid_range
 sub w9,w20,#80
 cmp w9,#40
 b.ls .Lpacking_grid_bits
.Lpacking_grid_range:
 movz x9,#0x7ff0,lsl#48
 fmov d1,x9
 mov x9,#0
.Lpacking_minimum:
 ldr d0,[x24,x9,lsl#3]
 fcmpe d0,d1
 fcsel d1,d0,d1,mi
 add x9,x9,#1
 cmp x9,x25
 b.ne .Lpacking_minimum
 str d1,[sp,#168]
 movz x9,#0xfff0,lsl#48
 fmov d1,x9
 mov x9,#0
.Lpacking_maximum:
 ldr d0,[x24,x9,lsl#3]
 fcmpe d0,d1
 fcsel d1,d0,d1,gt
 add x9,x9,#1
 cmp x9,x25
 b.ne .Lpacking_maximum
 str d1,[sp,#176]
 add x0,sp,#128
 add x1,sp,#132
 mov x2,x22
 add x3,sp,#168
 add x4,sp,#176
 mov x5,x23
 bl imultio_encode_bitspervalue_
 cbnz w0,.Lpacking_return
 ldr w2,[sp,#128]
.Lpacking_grid_bits:
 packing_long .Lpacking_bits
.Lpacking_return:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.Lpacking_invalid:
 mov w0,#2
 ret
.size md2asm_set_runtime_grib_packing,.-md2asm_set_runtime_grib_packing
.section .rodata
.p2align 3
.Lpacking_limit: .double 9.9
.Lpacking_bits: .asciz "numberOfBitsContainingEachPackedValue"
.Lpacking_operator_key: .asciz "laplacianOperator"
.Lpacking_subset_j: .asciz "subSetJ"
.Lpacking_subset_k: .asciz "subSetK"
.Lpacking_subset_m: .asciz "subSetM"
.Lpacking_bitmap: .asciz "bitmapPresent"
.Lpacking_missing_key: .asciz "missingValue"
.section .note.GNU-stack,"",%progbits
