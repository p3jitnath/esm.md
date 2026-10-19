#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_prepare_grib_template
.type md2asm_prepare_grib_template,%function
md2asm_prepare_grib_template:
 mrs x9,fpcr
 cbnz x9,.Lprepare_invalid
 cbz x0,.Lprepare_invalid
 cbz x1,.Lprepare_invalid
 cbz x3,.Lprepare_invalid
 cmp x2,#2
 b.hi .Lprepare_invalid
 orr x9,x1,x3
 tst x9,#7
 b.ne .Lprepare_invalid
 ldr x9,[x1,#24]
 cmp x9,#1
 b.ne .Lprepare_invalid
 ldr x9,[x1,#40]
 cmp x9,#21
 b.ne .Lprepare_invalid
 ldr x9,[x1,#48]
 cmp x9,#32
 b.ne .Lprepare_invalid
 ldr x9,[x1,#56]
 cmp x9,#64
 b.ne .Lprepare_invalid
 ldr x9,[x1,#64]
 cmp x9,#19
 b.ne .Lprepare_invalid
 ldr x9,[x1,#72]
 cbnz x9,.Lprepare_invalid
 ldr x9,[x1,#80]
 cmp x9,#1
 b.hi .Lprepare_invalid
 ldr x9,[x1,#88]
 movz x10,#0x3ff0,lsl#48
 cmp x9,x10
 b.ne .Lprepare_invalid
 ldrh w9,[x1,#112]
 mov w10,#0x6366
 cmp w9,w10
 b.ne .Lprepare_invalid
 ldrb w9,[x1,#114]
 cbnz w9,.Lprepare_invalid
 ldrh w9,[x1,#120]
 mov w10,#0x6472
 cmp w9,w10
 b.ne .Lprepare_invalid
 ldrb w9,[x1,#122]
 cbnz w9,.Lprepare_invalid
 ldrb w9,[x1,#132]
 cbnz w9,.Lprepare_invalid
 sub sp,sp,#192
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 bl codes_handle_clone
 mov x24,x0
 cbz x24,.Lprepare_clone_failed
 ldr x2,[x20,#16]
 mov x0,x24
 adrp x1,.Lcycle
 add x1,x1,:lo12:.Lcycle
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#24]
 mov x0,x24
 adrp x1,.Llocal
 add x1,x1,:lo12:.Llocal
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#32]
 mov x0,x24
 adrp x1,.Lstream
 add x1,x1,:lo12:.Lstream
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 mov x0,x24
 adrp x1,.Ltype
 add x1,x1,:lo12:.Ltype
 add x2,x20,#112
 mov x9,#2
 str x9,[sp,#128]
 add x3,sp,#128
 bl codes_set_string
 cbnz w0,.Lprepare_error
 mov x0,x24
 adrp x1,.Lclass
 add x1,x1,:lo12:.Lclass
 add x2,x20,#120
 mov x9,#2
 str x9,[sp,#128]
 add x3,sp,#128
 bl codes_set_string
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#0]
 mov x0,x24
 adrp x1,.Ldate
 add x1,x1,:lo12:.Ldate
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#8]
 mov x0,x24
 adrp x1,.Ltime
 add x1,x1,:lo12:.Ltime
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 mov x0,x24
 adrp x1,.Lexperiment
 add x1,x1,:lo12:.Lexperiment
 add x2,x20,#128
 mov x9,#4
 str x9,[sp,#128]
 add x3,sp,#128
 bl codes_set_string
 cbnz w0,.Lprepare_error
 mov x0,x24
 adrp x1,.Leps
 add x1,x1,:lo12:.Leps
 mov x2,#0
 bl codes_set_long
 cbnz w0,.Lprepare_error
 cmp x21,#2
 b.ne .Lprepare_spectral
 mov x0,x24
 adrp x1,.Ltruncate
 add x1,x1,:lo12:.Ltruncate
 mov x2,#1
 bl codes_set_long
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#48]
 mov x0,x24
 adrp x1,.Lmeridian
 add x1,x1,:lo12:.Lmeridian
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 adrp x9,.Langle_constants
 add x9,x9,:lo12:.Langle_constants
 ldr d0,[x9]
 fmov d1,#2.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d1,d0 // fmul d0,d1,d0
 ldr d1,[x9,#8]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d1,d0 // fdiv d0,d1,d0
 str d0,[sp,#144]
 ldr d1,[x20,#96]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
 mov x0,x24
 adrp x1,.Lfirst_lat
 add x1,x1,:lo12:.Lfirst_lat
 bl codes_set_double
 cbnz w0,.Lprepare_error
 mov x0,x24
 adrp x1,.Lfirst_lon
 add x1,x1,:lo12:.Lfirst_lon
 mov x2,#0
 bl codes_set_long
 cbnz w0,.Lprepare_error
 ldr d0,[sp,#144]
 ldr d1,[x20,#104]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
 mov x0,x24
 adrp x1,.Llast_lat
 add x1,x1,:lo12:.Llast_lat
 bl codes_set_double
 cbnz w0,.Lprepare_error
 adrp x9,.Langle_constants
 add x9,x9,:lo12:.Langle_constants
 ldr d0,[x9,#16]
 ldr x9,[x20,#56]
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1,x9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d1,d0,d1 // fdiv d1,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0,d0,d1
 mov x0,x24
 adrp x1,.Llast_lon
 add x1,x1,:lo12:.Llast_lon
 bl codes_set_double
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#48]
 add x2,x2,#1
 asr x2,x2,#1
 mov x0,x24
 adrp x1,.Lgaussian_order
 add x1,x1,:lo12:.Lgaussian_order
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 mov x0,x24
 adrp x1,.Lgrid_type
 add x1,x1,:lo12:.Lgrid_type
 adrp x2,.Lregular_gg; add x2,x2,:lo12:.Lregular_gg
 mov x9,#10
 str x9,[sp,#128]
 add x3,sp,#128
 bl codes_set_string
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#56]
 mov x0,x24
 adrp x1,.Lparallel
 add x1,x1,:lo12:.Lparallel
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 adrp x9,.Langle_constants
 add x9,x9,:lo12:.Langle_constants
 ldr d0,[x9,#16]
 ldr x9,[x20,#56]
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1,x9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0,d0,d1
 mov x0,x24
 adrp x1,.Llongitude_increment
 add x1,x1,:lo12:.Llongitude_increment
 bl codes_set_double
 cbnz w0,.Lprepare_error
 b .Lprepare_vertical
.Lprepare_spectral:
 mov x0,x24
 adrp x1,.Lgrid_type
 add x1,x1,:lo12:.Lgrid_type
 adrp x2,.Lsh; add x2,x2,:lo12:.Lsh
 mov x9,#2
 str x9,[sp,#128]
 add x3,sp,#128
 bl codes_set_string
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#40]
 mov x0,x24
 adrp x1,.LJ
 add x1,x1,:lo12:.LJ
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#40]
 mov x0,x24
 adrp x1,.LK
 add x1,x1,:lo12:.LK
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
 ldr x2,[x20,#40]
 mov x0,x24
 adrp x1,.LM
 add x1,x1,:lo12:.LM
 mov x2,x2
 bl codes_set_long
 cbnz w0,.Lprepare_error
.Lprepare_vertical:
 cbz x21,.Lprepare_success
 mov x0,x24
 adrp x1,.Lpv
 add x1,x1,:lo12:.Lpv
 add x2,x20,#144
 mov x3,#40
 bl codes_set_double_array
 cbnz w0,.Lprepare_error
.Lprepare_success:
 str x24,[x22]
 mov w25,#0
 b .Lprepare_restore
.Lprepare_error:
 mov w25,w0
 mov x0,x24
 bl codes_handle_delete
 b .Lprepare_restore
.Lprepare_clone_failed:
 mov w25,#1
.Lprepare_restore:
 mov w0,w25
 ldr x18,[sp,#80]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.Lprepare_invalid:
 mov w0,#2
 ret
.size md2asm_prepare_grib_template,.-md2asm_prepare_grib_template
.p2align 4
.global md2asm_initialize_grib_template
.type md2asm_initialize_grib_template,%function
md2asm_initialize_grib_template:
 cbz x0,.Linitialize_invalid
 cbz x2,.Linitialize_invalid
 cmp x1,#2
 b.hi .Linitialize_invalid
 mrs x9,fpcr
 cbnz x9,.Linitialize_invalid
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adrp x1,.Lsample_sh
 add x1,x1,:lo12:.Lsample_sh
 cbz x20,.Linitialize_sample
 adrp x1,.Lsample_sh_ml
 add x1,x1,:lo12:.Lsample_sh_ml
 cmp x20,#1
 b.eq .Linitialize_sample
 adrp x1,.Lsample_gg_ml
 add x1,x1,:lo12:.Lsample_gg_ml
.Linitialize_sample:
 mov x0,#0
 bl codes_handle_new_from_samples
 mov x22,x0
 cbz x22,.Linitialize_sample_failed
 cbz x20,.Linitialize_roundtrip
 mov x0,x22
 adrp x1,.Llatest_table
 add x1,x1,:lo12:.Llatest_table
 add x2,sp,#96
 bl codes_get_long
 cbnz w0,.Linitialize_error
 mov x0,x22
 adrp x1,.Ltable_version
 add x1,x1,:lo12:.Ltable_version
 ldr x2,[sp,#96]
 bl codes_set_long
 cbnz w0,.Linitialize_error
.Linitialize_roundtrip:
 mov x0,x22
 add x1,sp,#104
 add x2,sp,#112
 bl codes_get_message
 cbnz w0,.Linitialize_error
 mov x0,#0
 ldr x1,[sp,#104]
 ldr x2,[sp,#112]
 bl codes_handle_new_from_message_copy
 mov x23,x0
 cbz x23,.Linitialize_clone_failed
 mov x0,x22
 bl codes_handle_delete
 mov x22,x23
 mov x0,x22
 mov x1,x19
 mov x2,x20
 mov x3,x21
 bl md2asm_prepare_grib_template
 mov w24,w0
 mov x0,x22
 bl codes_handle_delete
 b .Linitialize_restore
.Linitialize_error:
 mov w24,w0
 b .Linitialize_delete
.Linitialize_clone_failed:
 mov w24,#1
.Linitialize_delete:
 mov x0,x22
 bl codes_handle_delete
 b .Linitialize_restore
.Linitialize_sample_failed:
 mov w24,#1
.Linitialize_restore:
 mov w0,w24
 ldr x18,[sp,#80]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Linitialize_invalid:
 mov w0,#2
 ret
.size md2asm_initialize_grib_template,.-md2asm_initialize_grib_template
.section .rodata
.p2align 3
.Langle_constants: .quad 0x3ff921fb54442d18,0x4066800000000000,0x4076800000000000
.Lcycle: .asciz "generatingProcessIdentifier"
.Llocal: .asciz "localDefinitionNumber"
.Lstream: .asciz "stream"
.Ltype: .asciz "type"
.Lclass: .asciz "class"
.Ldate: .asciz "dataDate"
.Ltime: .asciz "time"
.Lexperiment: .asciz "experimentVersionNumber"
.Leps: .asciz "eps"
.Ltruncate: .asciz "truncateDegrees"
.Lmeridian: .asciz "numberOfPointsAlongAMeridian"
.Lfirst_lat: .asciz "latitudeOfFirstGridPointInDegrees"
.Lfirst_lon: .asciz "longitudeOfFirstGridPointInDegrees"
.Llast_lat: .asciz "latitudeOfLastGridPointInDegrees"
.Llast_lon: .asciz "longitudeOfLastGridPointInDegrees"
.Lgaussian_order: .asciz "numberOfParallelsBetweenAPoleAndTheEquator"
.Lgrid_type: .asciz "gridType"
.Lparallel: .asciz "numberOfPointsAlongAParallel"
.Llongitude_increment: .asciz "iDirectionIncrementInDegrees"
.LJ: .asciz "pentagonalResolutionParameterJ"
.LK: .asciz "pentagonalResolutionParameterK"
.LM: .asciz "pentagonalResolutionParameterM"
.Lpv: .asciz "pv"
.Lsh: .asciz "sh"
.Lregular_gg: .asciz "regular_gg"
.Lsample_sh: .asciz "sh_sfc"
.Lsample_sh_ml: .asciz "sh_ml"
.Lsample_gg_ml: .asciz "gg_ml"
.Llatest_table: .asciz "tablesVersionLatest"
.Ltable_version: .asciz "tablesVersion"
.section .note.GNU-stack,"",%progbits
