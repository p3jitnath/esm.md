/* Complete GRIB field headers and values from runtime metadata.
 * Contract skills/md2asm/references/openifs/output/runtime_grib_encoding.md
 * x0 spec128, x1 values, x2 message8, x3 length8, x4 handle owner8.
 * The 512-byte AAPCS64 frame includes outgoing packing arguments.
 */
.arch armv8.2-a
.macro rf_long key
 mov x0,x24
 adrp x1,\key
 add x1,x1,:lo12:\key
 bl codes_set_long
 cbnz w0,.Lrf_error
.endm
.macro rf_string key,text,len
 mov x0,x24
 adrp x1,\key
 add x1,x1,:lo12:\key
 adrp x2,\text
 add x2,x2,:lo12:\text
 mov x9,#\len
 str x9,[sp,#192]
 add x3,sp,#192
 bl codes_set_string
 cbnz w0,.Lrf_error
.endm
.text
.p2align 4
.global md2asm_encode_runtime_grib_field
.type md2asm_encode_runtime_grib_field,%function
md2asm_encode_runtime_grib_field:
 mrs x9,fpcr
 cbnz x9,.Lrf_invalid
 cbz x0,.Lrf_invalid
 cbz x1,.Lrf_invalid
 cbz x2,.Lrf_invalid
 cbz x3,.Lrf_invalid
 cbz x4,.Lrf_invalid
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 orr x9,x9,x4
 tst x9,#7
 b.ne .Lrf_invalid
 adds x9,x0,#128
 b.cs .Lrf_invalid
 adds x9,x2,#8
 b.cs .Lrf_invalid
 adds x9,x3,#8
 b.cs .Lrf_invalid
 adds x9,x4,#8
 b.cs .Lrf_invalid
 ldr x9,[x0]
 cbz x9,.Lrf_invalid
 ldr x9,[x0,#8]
 tbnz x9,#31,.Lrf_invalid
 lsr x10,x9,#32
 cbnz x10,.Lrf_invalid
 movz w10,#0xf99e
 movk w10,#3,lsl#16
 cmp w9,w10
 b.eq .Lrf_invalid
 add w10,w10,#1
 cmp w9,w10
 b.eq .Lrf_invalid
 ldr x9,[x0,#16]
 sxtw x10,w9
 cmp x9,x10
 b.ne .Lrf_invalid
 ldr x9,[x0,#24]
 cmp x9,#1
 b.hi .Lrf_invalid
 ldr x10,[x0,#32]
 cmp x10,#109
 b.eq .Lrf_level_ok
 cmp x10,#112
 b.eq .Lrf_level_ok
 cmp x10,#118
 b.eq .Lrf_level_ok
 cmp x10,#116
 b.eq .Lrf_level_ok
 cmp x10,#115
 b.ne .Lrf_invalid
 ldr x11,[x0,#16]
 cmp x11,#512
 b.hi .Lrf_invalid
.Lrf_level_ok:
 ldr x10,[x0,#40]
 tbnz x10,#31,.Lrf_invalid
 lsr x11,x10,#32
 cbnz x11,.Lrf_invalid
 ldr x10,[x0,#48]
 sub x11,x10,#1
 mov x12,#0x7ffffffe
 cmp x11,x12
 b.hi .Lrf_invalid
 adds x11,x1,x10,lsl#3
 b.cs .Lrf_invalid
 ldr x11,[x0,#56]
 sub x12,x11,#1
 cmp x12,#4095
 b.hi .Lrf_invalid
 cbz x9,.Lrf_count_ok
 add x12,x11,#1
 add x13,x11,#2
 mul x12,x12,x13
 cmp x12,x10
 b.ne .Lrf_invalid
.Lrf_count_ok:
 ldr x11,[x0,#72]
 cbz x11,.Lrf_invalid
 tst x11,#3
 b.ne .Lrf_invalid
 adds x12,x11,#40
 b.cs .Lrf_invalid
 ldr x11,[x0,#80]
 cbz x11,.Lrf_invalid
 tst x11,#7
 b.ne .Lrf_invalid
 adds x12,x11,#128
 b.cs .Lrf_invalid
 ldr x12,[x0,#88]
 cbz x12,.Lrf_invalid
 tst x12,#3
 b.ne .Lrf_invalid
 adds x12,x12,#144
 b.cs .Lrf_invalid
 ldp x12,x13,[x0,#96]
 orr x12,x12,x13
 ldp x13,x14,[x0,#112]
 orr x12,x12,x13
 orr x12,x12,x14
 cbnz x12,.Lrf_invalid
 ldr x12,[x0,#56]
 add x12,x12,#1
 lsl x12,x12,#4
 add x12,x12,#1024
 ldr x13,[x11,#96]
 movz x14,#0x10,lsl#32
 cmp x13,x14
 b.hi .Lrf_invalid
 cmp x12,x13
 b.hi .Lrf_invalid
 ldr x12,[x11,#72]
 cbz x12,.Lrf_invalid
 tst x12,#7
 b.ne .Lrf_invalid
 ldr w13,[x12]
 cmp w13,#1
 b.ne .Lrf_invalid
 ldr w13,[x12,#8]
 cbnz w13,.Lrf_invalid
 ldr w13,[x12,#20]
 cmp w13,#1025
 b.ne .Lrf_invalid
 ldr w13,[x12,#80]
 cmp w13,#1
 b.ne .Lrf_invalid
 ldrh w13,[x12,#90]
 mov w14,#0x6366
 cmp w13,w14
 b.ne .Lrf_invalid
 ldr x12,[x11,#80]
 cbz x12,.Lrf_invalid
 ldr w12,[x12]
 cbnz w12,.Lrf_invalid
 ldr x12,[x11,#64]
 cbz x12,.Lrf_invalid
 ldrb w13,[x12,#44]
 cmp w13,#48
 b.ne .Lrf_invalid
 ldr w13,[x12,#60]
 cbnz w13,.Lrf_invalid
 /* Integer inspection preserves the incoming floating status. */
 mov x11,#0
 movz x12,#0x7ff0,lsl#48
.Lrf_finite:
 ldr x13,[x1,x11,lsl#3]
 and x13,x13,#0x7ff0000000000000
 cmp x13,x12
 b.eq .Lrf_invalid
 add x11,x11,#1
 cmp x11,x10
 b.lo .Lrf_finite
 sub sp,sp,#512
 stp x29,x30,[sp,#64]
 add x29,sp,#64
 stp x19,x20,[sp,#80]
 stp x21,x22,[sp,#96]
 stp x23,x24,[sp,#112]
 stp x25,x26,[sp,#128]
 stp x27,x28,[sp,#144]
 str x18,[sp,#160]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 ldr x26,[x19,#80]
 ldr x0,[x19]
 bl codes_handle_clone
 mov x24,x0
 cbz x24,.Lrf_clone_failed
 ldr x9,[x19,#24]
 cbz x9,.Lrf_type
 ldr x2,[x19,#56]
 rf_long .Lrf_j
 ldr x2,[x19,#56]
 rf_long .Lrf_k
 ldr x2,[x19,#56]
 rf_long .Lrf_m
.Lrf_type:
 rf_string .Lrf_type_key,.Lrf_fc,2
 mov x0,x24
 mov x1,x19
 add x2,sp,#40
 adrp x9,:got:md2asm_owned_dynamical_namespace
 ldr x9,[x9,:got_lo12:md2asm_owned_dynamical_namespace]
 ldr w3,[x9,#284]
 bl md2asm_set_runtime_grib_time
 cbnz w0,.Lrf_error
 ldr w9,[sp,#40]
 cbz w9,.Lrf_time_invalid
 /* The source normal forecast has simulation index0 and linear index999. */
 mov w9,#999
 stp wzr,w9,[sp,#16]
 ldr x10,[x26,#72]
 ldr w9,[x10,#60]
 ldr w11,[x10,#64]
 stp w9,w11,[sp,#24]
 ldr w9,[x10,#92]
 ldr w11,[x10,#96]
 stp w9,w11,[sp,#32]
 ldr w9,[x19,#32]
 mov w10,#0x4653
 mov w11,#0x4c4d
 cmp w9,#109
 csel w10,w11,w10,eq
 mov w11,#0x4c50
 cmp w9,#112
 csel w10,w11,w10,eq
 mov w11,#0x5650
 cmp w9,#118
 csel w10,w11,w10,eq
 mov w11,#0x4854
 cmp w9,#116
 csel w10,w11,w10,eq
 strh w10,[sp,#48]
 strb wzr,[sp,#50]
 ldr x9,[x19,#56]
 str x9,[sp]
 add x9,sp,#16
 str x9,[sp,#8]
 mov x0,x24
 ldr w1,[x19,#8]
 add x2,sp,#48
 mov x3,#2
 ldr w4,[x19,#24]
 mov w5,#0
 mov x6,x20
 ldr x7,[x19,#48]
 bl md2asm_set_runtime_grib_packing
 cbnz w0,.Lrf_error
 mov w27,#-1
 mov w28,#-1
 ldr x9,[x19,#32]
 cmp x9,#115
 b.ne .Lrf_nonsurface
 rf_string .Lrf_level_type,.Lrf_surface,7
 mov x2,#0
 rf_long .Lrf_level
 ldr w9,[x19,#16]
 cbz w9,.Lrf_soil
 ldr w10,[x19,#8]
 cmp w10,#33
 b.eq .Lrf_snow
 cmp w10,#238
 b.eq .Lrf_snow
 movz w11,#0x7b2d
 movk w11,#3,lsl#16
 cmp w10,w11
 b.eq .Lrf_snow
 movz w11,#0x7ac6
 movk w11,#3,lsl#16
 cmp w10,w11
 b.ne .Lrf_soil
.Lrf_snow:
 rf_string .Lrf_level_type,.Lrf_snow_layer,9
 mov x2,#114
 rf_long .Lrf_first_surface
 mov x2,#114
 rf_long .Lrf_second_surface
 mov x2,#0
 rf_long .Lrf_first_scale
 ldrsw x2,[x19,#16]
 sub x2,x2,#1
 rf_long .Lrf_first_value
 mov x2,#0
 rf_long .Lrf_second_scale
 ldrsw x2,[x19,#16]
 rf_long .Lrf_second_value
 ldrsw x2,[x19,#16]
 rf_long .Lrf_level
.Lrf_soil:
 ldr x9,[x19,#88]
 ldr w10,[x19,#8]
 mov x11,#0
.Lrf_soil_find:
 ldr w12,[x9,x11,lsl#2]
 cmp w12,w10
 b.eq .Lrf_soil_found
 add x11,x11,#1
 cmp x11,#12
 b.lo .Lrf_soil_find
 b .Lrf_parameter
.Lrf_soil_found:
 add x10,x9,#48
 ldr w28,[x10,x11,lsl#2]
 add x10,x9,#96
 ldr w27,[x10,x11,lsl#2]
 tbnz w27,#31,.Lrf_parameter
 tbnz w28,#31,.Lrf_parameter
 rf_string .Lrf_level_type,.Lrf_soil_layer,19
 mov x2,#0
 rf_long .Lrf_level
 sxtw x2,w27
 rf_long .Lrf_top
 sxtw x2,w28
 rf_long .Lrf_bottom
 b .Lrf_parameter
.Lrf_nonsurface:
 cmp x9,#109
 b.eq .Lrf_model
 cmp x9,#112
 b.eq .Lrf_pressure
 cmp x9,#118
 b.eq .Lrf_pv
 rf_string .Lrf_level_type,.Lrf_theta,5
 b .Lrf_plain_level
.Lrf_model:
 rf_string .Lrf_level_type,.Lrf_hybrid,6
 b .Lrf_plain_level
.Lrf_pv:
 rf_string .Lrf_level_type,.Lrf_potential_vorticity,18
 b .Lrf_plain_level
.Lrf_pressure:
 ldrsw x9,[x19,#16]
 cmp x9,#100
 b.lt .Lrf_pressure_pa
 rf_string .Lrf_level_type,.Lrf_hpa,13
 ldrsw x2,[x19,#16]
 mov x9,#100
 sdiv x2,x2,x9
 rf_long .Lrf_level
 b .Lrf_parameter
.Lrf_pressure_pa:
 rf_string .Lrf_level_type,.Lrf_pa,12
.Lrf_plain_level:
 ldrsw x2,[x19,#16]
 rf_long .Lrf_level
.Lrf_parameter:
 mov x0,x24
 adrp x1,.Lrf_type_key
 add x1,x1,:lo12:.Lrf_type_key
 add x2,sp,#176
 mov x9,#16
 str x9,[sp,#192]
 add x3,sp,#192
 bl codes_get_string
 cbnz w0,.Lrf_error
 ldrh w9,[sp,#176]
 mov w10,#0x6366
 cmp w9,w10
 b.ne .Lrf_bad_clone
 ldrb w9,[sp,#178]
 cbnz w9,.Lrf_bad_clone
 ldr w9,[x19,#8]
 mov w10,#1000
 udiv w11,w9,w10
 msub w12,w11,w10,w9
 cmp w11,#128
 csel w9,w12,w9,eq
 cmp w9,#128
 b.eq .Lrf_values
 uxtw x2,w9
 rf_long .Lrf_param
.Lrf_values:
 mov x0,x24
 adrp x1,.Lrf_values_key
 add x1,x1,:lo12:.Lrf_values_key
 mov x2,x20
 ldr x3,[x19,#48]
 bl codes_set_double_array
 cbnz w0,.Lrf_error
 mov x0,x24
 add x1,sp,#208
 add x2,sp,#216
 bl codes_get_message
 cbnz w0,.Lrf_error
 ldp x9,x10,[sp,#208]
 str x9,[x21]
 str x10,[x22]
 str x24,[x23]
 mov w25,#0
 b .Lrf_restore
.Lrf_time_invalid:
 str xzr,[x21]
 str xzr,[x22]
 str x24,[x23]
 mov w25,#0
 b .Lrf_restore
.Lrf_bad_clone:
 mov w0,#2
.Lrf_error:
 mov w25,w0
 mov x0,x24
 bl codes_handle_delete
 b .Lrf_restore
.Lrf_clone_failed:
 mov w25,#1
.Lrf_restore:
 mov w0,w25
 ldr x18,[sp,#160]
 ldp x19,x20,[sp,#80]
 ldp x21,x22,[sp,#96]
 ldp x23,x24,[sp,#112]
 ldp x25,x26,[sp,#128]
 ldp x27,x28,[sp,#144]
 ldp x29,x30,[sp,#64]
 add sp,sp,#512
 ret
.Lrf_invalid:
 mov w0,#2
 ret
.size md2asm_encode_runtime_grib_field,.-md2asm_encode_runtime_grib_field

.p2align 4
.global md2asm_runtime_grib_edition
.type md2asm_runtime_grib_edition,%function
md2asm_runtime_grib_edition:
 movz w9,#0xe800
 movk w9,#3,lsl#16
 cmp w0,w9
 b.ge .Lre_two
 cmp w0,#33
 b.eq .Lre_snow_level
 cmp w0,#238
 b.eq .Lre_snow_level
 adrp x9,.Lre_exact
 add x9,x9,:lo12:.Lre_exact
 mov x10,#23
.Lre_exact_loop:
 ldr w11,[x9],#4
 cmp w0,w11
 b.eq .Lre_two
 subs x10,x10,#1
 b.ne .Lre_exact_loop
 adrp x9,.Lre_ranges
 add x9,x9,:lo12:.Lre_ranges
 mov x10,#11
.Lre_range_loop:
 ldp w11,w12,[x9],#8
 sub w13,w0,w11
 cmp w13,w12
 b.ls .Lre_two
 subs x10,x10,#1
 b.ne .Lre_range_loop
 mov w0,#1
 ret
.Lre_snow_level:
 cbnz w1,.Lre_two
 mov w0,#1
 ret
.Lre_two:
 mov w0,#2
 ret
.size md2asm_runtime_grib_edition,.-md2asm_runtime_grib_edition
.section .rodata
.Lrf_type_key: .asciz "type"
.Lrf_fc: .asciz "fc"
.Lrf_j: .asciz "pentagonalResolutionParameterJ"
.Lrf_k: .asciz "pentagonalResolutionParameterK"
.Lrf_m: .asciz "pentagonalResolutionParameterM"
.Lrf_level_type: .asciz "typeOfLevel"
.Lrf_level: .asciz "level"
.Lrf_surface: .asciz "surface"
.Lrf_snow_layer: .asciz "snowLayer"
.Lrf_first_surface: .asciz "typeOfFirstFixedSurface"
.Lrf_second_surface: .asciz "typeOfSecondFixedSurface"
.Lrf_first_scale: .asciz "scaleFactorOfFirstFixedSurface"
.Lrf_second_scale: .asciz "scaleFactorOfSecondFixedSurface"
.Lrf_first_value: .asciz "scaledValueOfFirstFixedSurface"
.Lrf_second_value: .asciz "scaledValueOfSecondFixedSurface"
.Lrf_soil_layer: .asciz "depthBelowLandLayer"
.Lrf_top: .asciz "topLevel"
.Lrf_bottom: .asciz "bottomLevel"
.Lrf_hybrid: .asciz "hybrid"
.Lrf_hpa: .asciz "isobaricInhPa"
.Lrf_pa: .asciz "isobaricInPa"
.Lrf_potential_vorticity: .asciz "potentialVorticity"
.Lrf_theta: .asciz "theta"
.Lrf_param: .asciz "paramId"
.Lrf_values_key: .asciz "values"
.p2align 2
.Lre_exact:
 .word 228035,228036,162071,162072
 .word 228050,228051,228057,228058
 .word 228052,228053,228059,228060
 .word 228235,228231,228233,228232
 .word 228234,228237,228045,228104
 .word 228141,228038,210170
.Lre_ranges:
 .word 210252,1
 .word 215212,14
 .word 217057,149
 .word 217222,10
 .word 218057,149
 .word 218221,11
 .word 219057,175
 .word 221057,149
 .word 221221,11
 .word 222001,255
 .word 223001,255
.bss
.p2align 3
.global md2asm_owned_grib_soil_levels
.type md2asm_owned_grib_soil_levels,%object
md2asm_owned_grib_soil_levels:
 .skip 144
.size md2asm_owned_grib_soil_levels,144
.section .note.GNU-stack,"",%progbits
