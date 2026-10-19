#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_encode_grib_field
.type md2asm_encode_grib_field,%function
md2asm_encode_grib_field:
 mrs x9,fpcr
 cbnz x9,.Linvalid
 cbz x0,.Linvalid
 cbz x1,.Linvalid
 cbz x2,.Linvalid
 cbz x3,.Linvalid
 cbz x4,.Linvalid
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 orr x9,x9,x4
 tst x9,#7
 b.ne .Linvalid
 ldr x9,[x0]
 cbz x9,.Linvalid
 ldr x10,[x0,#24]
 cmp x10,#1
 b.hi .Linvalid
 ldr x11,[x0,#32]
 cmp x11,#1
 b.hi .Linvalid
 ldr x12,[x0,#16]
 cbz x12,.Linvalid
 tbnz x12,#63,.Linvalid
 cbz x11,.Lpressure
 cmp x12,#19
 b.hi .Linvalid
 b .Llevel_valid
.Lpressure:
 cmp x12,#100
 b.lo .Linvalid
.Llevel_valid:
 ldr x12,[x0,#40]
 movz x13,#0x5180
 movk x13,#1,lsl#16
 cmp x12,x13
 b.hi .Linvalid
 mov x13,#3600
 udiv x14,x12,x13
 msub x14,x14,x13,x12
 cbnz x14,.Linvalid
 ldr x12,[x0,#56]
 cmp x12,#1
 b.hi .Linvalid
 ldr x12,[x0,#8]
 ldr x13,[x0,#48]
 cbz x10,.Lgrid_shape
 cmp x13,#506
 b.ne .Linvalid
 cmp x12,#130
 b.eq .Lspan
 cmp x12,#152
 b.ne .Linvalid
 b .Lspan
.Lgrid_shape:
 cmp x13,#2048
 b.ne .Linvalid
 cmp x12,#133
 b.ne .Linvalid
 cmp x11,#1
 b.ne .Linvalid
.Lspan:
 adds x9,x1,x13,lsl#3
 b.cs .Linvalid
 mov x9,x1
 mov x14,x13
 movz x15,#0x7ff0,lsl#48
 mov x16,#-1
 lsr x16,x16,#1
 movz x17,#0x0010,lsl#48
 sub x16,x16,x17
.Lfinite:
 ldr x17,[x9],#8
 and x12,x17,#0x7ff0000000000000
 cmp x12,x15
 b.eq .Linvalid
 cbnz x10,.Lfinite_next
 cmp x17,x16
 b.eq .Linvalid
.Lfinite_next:
 subs x14,x14,#1
 b.ne .Lfinite
 sub sp,sp,#224
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 ldr x0,[x19]
 bl codes_handle_clone
 mov x24,x0
 cbz x24,.Lclone_failed
 ldr x9,[x19,#24]
 cbz x9,.Ltime
 mov x0,x24
 adrp x1,.LJ
 add x1,x1,:lo12:.LJ
 mov x2,#21
 bl codes_set_long
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.LK
 add x1,x1,:lo12:.LK
 mov x2,#21
 bl codes_set_long
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.LM
 add x1,x1,:lo12:.LM
 mov x2,#21
 bl codes_set_long
 cbnz w0,.Lcode_error
.Ltime:
 mov x0,x24
 adrp x1,.Ltype
 add x1,x1,:lo12:.Ltype
 adrp x2,.Lfc
 add x2,x2,:lo12:.Lfc
 mov x9,#2
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_set_string
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Ltime_range
 add x1,x1,:lo12:.Ltime_range
 mov x2,#0
 bl codes_set_long
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Lstep_type
 add x1,x1,:lo12:.Lstep_type
 adrp x2,.Linstant
 add x2,x2,:lo12:.Linstant
 mov x9,#7
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_set_string
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Lstep_units
 add x1,x1,:lo12:.Lstep_units
 adrp x2,.Lseconds
 add x2,x2,:lo12:.Lseconds
 mov x9,#1
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_set_string
 cbnz w0,.Lcode_error
 ldr x2,[x19,#40]
 mov x0,x24
 adrp x1,.Lend_step
 add x1,x1,:lo12:.Lend_step
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lcode_error
 ldr x9,[x19,#40]
 cbnz x9,.Lpositive_time
 mov x0,x24
 adrp x1,.Lstep_type
 add x1,x1,:lo12:.Lstep_type
 adrp x2,.Linstant
 add x2,x2,:lo12:.Linstant
 mov x9,#7
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_set_string
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Ltime_range
 add x1,x1,:lo12:.Ltime_range
 mov x2,#1
 bl codes_set_long
 cbnz w0,.Lcode_error
 b .Lpacking
.Lpositive_time:
 mov x0,x24
 adrp x1,.Lstep_units
 add x1,x1,:lo12:.Lstep_units
 adrp x2,.Lhours
 add x2,x2,:lo12:.Lhours
 mov x9,#1
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_set_string
 cbnz w0,.Lcode_error
.Lpacking:
 ldr x9,[x19,#24]
 cbz x9,.Lgrid_packing
 mov x0,x24
 adrp x1,.Lbits
 add x1,x1,:lo12:.Lbits
 mov x2,#16
 bl codes_set_long
 cbnz w0,.Lcode_error
 ldr x9,[x19,#8]
 cmp x9,#152
 b.ne .Lfit
 ldr x9,[x19,#32]
 cbz x9,.Lfit
 ldr x9,[x19,#56]
 cbz x9,.Lfit
 fmov d0,#0.5
 b .Loperator
.Lfit:
 mov w9,#21
 str w9,[sp,#128]
 mov w9,#506
 str w9,[sp,#132]
 mov w9,#10
 str w9,[sp,#136]
 add x0,sp,#128
 add x1,sp,#132
 mov x2,x20
 add x3,sp,#136
 add x4,sp,#144
 add x5,sp,#152
 bl md2asm_fitspectrum_original_rounding
 ldr d0,[sp,#152]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0,d0
 adrp x9,.Lpacking_limit
 ldr d1,[x9,:lo12:.Lpacking_limit]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d2,d1 // fneg d2,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,14,d0,d1,d0 // fmin d0,d1,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,5,d0,d2,d0 // fmax d0,d2,d0
.Loperator:
 mov x0,x24
 adrp x1,.Llaplacian
 add x1,x1,:lo12:.Llaplacian
 bl codes_set_double
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Lsubset_j
 add x1,x1,:lo12:.Lsubset_j
 mov x2,#10
 bl codes_set_long
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Lsubset_k
 add x1,x1,:lo12:.Lsubset_k
 mov x2,#10
 bl codes_set_long
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Lsubset_m
 add x1,x1,:lo12:.Lsubset_m
 mov x2,#10
 bl codes_set_long
 cbnz w0,.Lcode_error
 b .Llevels
.Lgrid_packing:
 ldr d0,[x20]
 mov x9,#1
.Lminimum:
 ldr d1,[x20,x9,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,14,d0,d0,d1 // fmin d0,d0,d1
 add x9,x9,#1
 cmp x9,#2048
 b.ne .Lminimum
 ldr d0,[x20]
 mov x9,#1
.Lmaximum:
 ldr d1,[x20,x9,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,5,d0,d0,d1 // fmax d0,d0,d1
 add x9,x9,#1
 cmp x9,#2048
 b.ne .Lmaximum
 mov x0,x24
 adrp x1,.Lbits
 add x1,x1,:lo12:.Lbits
 mov x2,#16
 bl codes_set_long
 cbnz w0,.Lcode_error
.Llevels:
 ldr x9,[x19,#32]
 cbz x9,.Lpressure_level
 mov x0,x24
 adrp x1,.Llevel_type
 add x1,x1,:lo12:.Llevel_type
 adrp x2,.Lhybrid
 add x2,x2,:lo12:.Lhybrid
 mov x9,#6
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_set_string
 cbnz w0,.Lcode_error
 ldr x2,[x19,#16]
 mov x0,x24
 adrp x1,.Llevel
 add x1,x1,:lo12:.Llevel
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lcode_error
 b .Lparameter
.Lpressure_level:
 mov x0,x24
 adrp x1,.Llevel_type
 add x1,x1,:lo12:.Llevel_type
 adrp x2,.Lhpa
 add x2,x2,:lo12:.Lhpa
 mov x9,#13
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_set_string
 cbnz w0,.Lcode_error
 ldr x2,[x19,#16]
 mov x9,#100
 sdiv x2,x2,x9
 mov x0,x24
 adrp x1,.Llevel
 add x1,x1,:lo12:.Llevel
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lcode_error
.Lparameter:
 mov x0,x24
 adrp x1,.Ltype
 add x1,x1,:lo12:.Ltype
 add x2,sp,#184
 mov x9,#16
 str x9,[sp,#176]
 add x3,sp,#176
 bl codes_get_string
 cbnz w0,.Lcode_error
 ldrh w9,[sp,#184]
 mov w10,#0x6366
 cmp w9,w10
 b.ne .Ltype_failed
 ldrb w9,[sp,#186]
 cbnz w9,.Ltype_failed
 ldr x2,[x19,#8]
 mov x0,x24
 adrp x1,.Lparam
 add x1,x1,:lo12:.Lparam
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lcode_error
 mov x0,x24
 adrp x1,.Lvalues
 add x1,x1,:lo12:.Lvalues
 mov x2,x20
 ldr x3,[x19,#48]
 bl codes_set_double_array
 cbnz w0,.Lcode_error
 mov x0,x24
 add x1,sp,#160
 add x2,sp,#168
 bl codes_get_message
 cbnz w0,.Lcode_error
 ldr x9,[sp,#160]
 ldr x10,[sp,#168]
 str x9,[x21]
 str x10,[x22]
 str x24,[x23]
 adrp x9,.Lsuccessful_fields
 add x9,x9,:lo12:.Lsuccessful_fields
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 mov w25,#0
 b .Lrestore
.Ltype_failed:
 mov w0,#2
.Lcode_error:
 mov w25,w0
 mov x0,x24
 bl codes_handle_delete
 b .Lrestore
.Lclone_failed:
 mov w25,#1
.Lrestore:
 mov w0,w25
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#224
 ret
.Linvalid:
 mov w0,#2
 ret
.size md2asm_encode_grib_field,.-md2asm_encode_grib_field
.global md2asm_grib_encoded_field_count_get
.type md2asm_grib_encoded_field_count_get,%function
md2asm_grib_encoded_field_count_get:
 adrp x0,.Lsuccessful_fields
 add x0,x0,:lo12:.Lsuccessful_fields
 ldr x0,[x0]
 ret
.size md2asm_grib_encoded_field_count_get,.-md2asm_grib_encoded_field_count_get
.section .rodata
.p2align 3
.Lpacking_limit: .double 9.9
.LJ: .asciz "pentagonalResolutionParameterJ"
.LK: .asciz "pentagonalResolutionParameterK"
.LM: .asciz "pentagonalResolutionParameterM"
.Ltype: .asciz "type"
.Lfc: .asciz "fc"
.Ltime_range: .asciz "timeRangeIndicator"
.Lstep_type: .asciz "stepType"
.Linstant: .asciz "instant"
.Lstep_units: .asciz "stepUnits"
.Lseconds: .asciz "s"
.Lhours: .asciz "h"
.Lend_step: .asciz "endStep"
.Lbits: .asciz "numberOfBitsContainingEachPackedValue"
.Llaplacian: .asciz "laplacianOperator"
.Lsubset_j: .asciz "subSetJ"
.Lsubset_k: .asciz "subSetK"
.Lsubset_m: .asciz "subSetM"
.Llevel_type: .asciz "typeOfLevel"
.Lhybrid: .asciz "hybrid"
.Lhpa: .asciz "isobaricInhPa"
.Llevel: .asciz "level"
.Lparam: .asciz "paramId"
.Lvalues: .asciz "values"
.bss
.p2align 3
.Lsuccessful_fields: .zero 8
.section .note.GNU-stack,"",%progbits
