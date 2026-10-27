/* Create a GRIB template from complete live geometry and owned metadata.
 * Contract skills/md2asm/references/openifs/output/runtime_grib_encoding.md
 * x0 Geometry20400, x1 common context128, w2 kind0..4, x3 output handle8.
 * AAPCS64 frame512 preserves x18 and every saved register.
 */
.arch armv8.2-a
.macro rt_long key
 mov x0,x24
 adrp x1,\key
 add x1,x1,:lo12:\key
 bl codes_set_long
 cbnz w0,.Lrt_error
.endm
.macro rt_double key
 mov x0,x24
 adrp x1,\key
 add x1,x1,:lo12:\key
 bl codes_set_double
 cbnz w0,.Lrt_error
.endm
.macro rt_string key,ptr,len
 mov x0,x24
 adrp x1,\key
 add x1,x1,:lo12:\key
 mov x2,\ptr
 mov x9,#\len
 str x9,[sp,#128]
 add x3,sp,#128
 bl codes_set_string
 cbnz w0,.Lrt_error
.endm
.text
.p2align 4
.global md2asm_create_runtime_grib_template
.type md2asm_create_runtime_grib_template,%function
md2asm_create_runtime_grib_template:
 mrs x9,fpcr
 cbnz x9,.Lrt_invalid
 cbz x0,.Lrt_invalid
 cbz x1,.Lrt_invalid
 cbz x3,.Lrt_invalid
 cmp w2,#4
 b.hi .Lrt_invalid
 orr x9,x0,x1
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lrt_invalid
 mov x10,#20400
 adds x9,x0,x10
 b.cs .Lrt_invalid
 adds x9,x1,#128
 b.cs .Lrt_invalid
 adds x9,x3,#8
 b.cs .Lrt_invalid
 sub sp,sp,#512
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
 mov w21,w2
 mov x22,x3
 mov x24,#0
 mov x26,#0
 mov x27,#0
 ldr x23,[x20,#72]
 ldr x9,[x20,#48]
 ldr x10,[x20,#56]
 ldr x11,[x20,#80]
 cbz x23,.Lrt_bad
 cbz x9,.Lrt_bad
 cbz x10,.Lrt_bad
 cbz x11,.Lrt_bad
 orr x12,x9,x10
 orr x12,x12,x23
 tst x12,#7
 b.ne .Lrt_bad
 tst x11,#3
 b.ne .Lrt_bad
 ldr w11,[x11]
 cbnz w11,.Lrt_bad
 mov x12,#40104
 ldr w11,[x9,x12]
 cmp w11,#1
 b.ne .Lrt_bad
 mov x12,#35860
 ldr w11,[x9,x12]
 cbnz w11,.Lrt_bad
 ldr x12,[x20,#64]
 cbz x12,.Lrt_bad
 tst x12,#7
 b.ne .Lrt_bad
 ldrb w11,[x12,#44]
 cmp w11,#48
 b.ne .Lrt_bad
 ldr w11,[x12,#60]
 cbnz w11,.Lrt_bad
 ldr w11,[x23]
 cmp w11,#1
 b.ne .Lrt_bad
 ldr w11,[x23,#8]
 cbnz w11,.Lrt_bad
 ldr w11,[x23,#20]
 cmp w11,#1025
 b.ne .Lrt_bad
 ldr w11,[x23,#80]
 cmp w11,#1
 b.ne .Lrt_bad
 ldrh w11,[x23,#90]
 mov w12,#0x6366
 cmp w11,w12
 b.ne .Lrt_bad
 ldrh w11,[x23,#90]
 strh w11,[sp,#292]
 strb wzr,[sp,#294]
 ldrh w11,[x23,#88]
 strh w11,[sp,#288]
 strb wzr,[sp,#290]
 and w12,w11,#255
 cbz w12,.Lrt_bad
 lsr w11,w11,#8
 cbz w11,.Lrt_bad
 ldr w11,[x10]
 tbnz w11,#31,.Lrt_bad
 str w11,[sp,#272]
 ldr w11,[x10,#4]
 movz w12,#0x5180
 movk w12,#1,lsl#16
 cmp w11,w12
 b.hs .Lrt_bad
 mov w12,#3600
 udiv w11,w11,w12
 mov w12,#100
 mul w11,w11,w12
 str w11,[sp,#276]
 mov x12,#35180
 add x9,x9,x12
 ldr w11,[x9]
 str w11,[sp,#136]
 strb wzr,[sp,#140]
 mov x9,#4872
 ldr w10,[x19,x9]
 sub w11,w10,#2
 mov w12,#16382
 cmp w11,w12
 b.hi .Lrt_bad
 str w10,[sp,#176]
 mov x9,#4936
 ldr w10,[x19,x9]
 sub w11,w10,#1
 mov w12,#65535
 cmp w11,w12
 b.hi .Lrt_bad
 str w10,[sp,#180]
 mov x9,#5172
 ldr w10,[x19,x9]
 sub w11,w10,#1
 cmp w11,#4095
 b.hi .Lrt_bad
 str w10,[sp,#184]
 mov x9,#5224
 ldr w10,[x19,x9]
 sub w11,w10,#1
 cmp w11,#511
 b.hi .Lrt_bad
 str w10,[sp,#188]
 mov x9,#7524
 ldr w10,[x19,x9]
 tbnz w10,#31,.Lrt_bad
 str w10,[sp,#192]
 mov x9,#7520
 ldr w10,[x19,x9]
 cmp w10,#1
 b.hi .Lrt_bad
 mov x9,#7512
 ldr x10,[x19,x9]
 movz x11,#0x3ff0,lsl#48
 cmp x10,x11
 b.ne .Lrt_bad
 mov x9,#7388
 ldr w10,[x19,x9]
 cbz w10,.Lrt_bad
 tbnz w10,#31,.Lrt_bad
 str w10,[sp,#196]
 mov x9,#4744
 add x0,x19,x9
 mov x1,#1
 ldr w2,[sp,#176]
 mov x3,#8
 mov x4,#3
 bl .Lrt_view
 cbnz w2,.Lrt_bad
 stp x0,x1,[sp,#208]
 mov x9,#7640
 add x0,x19,x9
 mov x1,#1
 ldr w2,[sp,#176]
 mov x3,#4
 mov x4,#1
 bl .Lrt_view
 cbnz w2,.Lrt_bad
 stp x0,x1,[sp,#224]
 ldr x9,[x19,#3240]
 cbz x9,.Lrt_bad
 tst x9,#7
 b.ne .Lrt_bad
 str x9,[sp,#280]
 add x0,x9,#128
 mov x1,#0
 ldr w2,[sp,#188]
 add w2,w2,#1
 mov x3,#8
 mov x4,#3
 bl .Lrt_view
 cbnz w2,.Lrt_bad
 stp x0,x1,[sp,#240]
 ldr x9,[sp,#280]
 add x0,x9,#64
 mov x1,#0
 ldr w2,[sp,#188]
 add w2,w2,#1
 mov x3,#8
 mov x4,#3
 bl .Lrt_view
 cbnz w2,.Lrt_bad
 stp x0,x1,[sp,#256]
 ldr w9,[sp,#176]
 ldr w10,[sp,#188]
 add x10,x10,#1
 lsl x10,x10,#4
 add x28,x10,x9,lsl#3
 ldr x9,[x20,#96]
 movz x10,#0x10,lsl#32
 cmp x9,x10
 b.hi .Lrt_bad
 add x10,x28,#512
 cmp x10,x9
 b.hi .Lrt_bad
 mov x0,x28
 bl malloc
 mov x26,x0
 cbz x26,.Lrt_alloc_failed
 ldr w28,[sp,#176]
 add x27,x26,x28,lsl#3
 ldp x9,x10,[sp,#224]
 ldr w11,[sp,#180]
 mov x12,#0
 mov x13,#0
.Lrt_copy_rows:
 ldrsw x14,[x9]
 cmp x14,#1
 b.lt .Lrt_bad
 cmp x14,x11
 b.gt .Lrt_bad
 str x14,[x26,x12,lsl#3]
 add x13,x13,x14
 add x9,x9,x10
 add x12,x12,#1
 cmp x12,x28
 b.lo .Lrt_copy_rows
 ldr w9,[sp,#192]
 cbnz w9,.Lrt_reduced_count
 ldr w9,[sp,#180]
 mul x13,x9,x28
.Lrt_reduced_count:
 ldr w9,[sp,#196]
 cmp x13,x9
 b.ne .Lrt_bad
 ldr w28,[sp,#188]
 add x28,x28,#1
 ldp x9,x10,[sp,#240]
 ldp x11,x12,[sp,#256]
 mov x13,#0
 add x14,x27,x28,lsl#3
.Lrt_copy_vertical:
 ldr x15,[x9]
 str x15,[x27,x13,lsl#3]
 ldr x15,[x11]
 str x15,[x14,x13,lsl#3]
 add x9,x9,x10
 add x11,x11,x12
 add x13,x13,#1
 cmp x13,x28
 b.lo .Lrt_copy_vertical
 adrp x9,.Lrt_sample_offsets
 add x9,x9,:lo12:.Lrt_sample_offsets
 ldrsw x10,[x9,x21,lsl#2]
 add x1,x9,x10
 mov x0,#0
 bl codes_handle_new_from_samples
 mov x24,x0
 cbz x24,.Lrt_alloc_failed
 cmp w21,#0
 b.eq .Lrt_sample_roundtrip
 cmp w21,#2
 b.eq .Lrt_sample_roundtrip
 mov x0,x24
 adrp x1,.Lrt_latest
 add x1,x1,:lo12:.Lrt_latest
 add x2,sp,#144
 bl codes_get_long
 cbnz w0,.Lrt_error
 ldr x2,[sp,#144]
 rt_long .Lrt_table
.Lrt_sample_roundtrip:
 mov x0,x24
 add x1,sp,#152
 add x2,sp,#160
 bl codes_get_message
 cbnz w0,.Lrt_error
 mov x0,#0
 ldr x1,[sp,#152]
 ldr x2,[sp,#160]
 bl codes_handle_new_from_message_copy
 mov x28,x0
 cbz x28,.Lrt_alloc_failed
 mov x0,x24
 bl codes_handle_delete
 mov x24,x28
 /* The returned handle is private, matching the source template clone. */
 ldrsw x2,[x23,#84]
 rt_long .Lrt_cycle
 ldrsw x2,[x23]
 rt_long .Lrt_local
 ldrsw x2,[x23,#20]
 rt_long .Lrt_stream
 add x2,sp,#292
 rt_string .Lrt_type,x2,2
 add x2,sp,#288
 rt_string .Lrt_class,x2,2
 ldrsw x2,[sp,#272]
 rt_long .Lrt_date
 ldrsw x2,[sp,#276]
 rt_long .Lrt_time
 add x2,sp,#136
 rt_string .Lrt_experiment,x2,4
 mov x2,#0
 rt_long .Lrt_eps
 cmp w21,#2
 b.lo .Lrt_spectral
 mov x2,#1
 rt_long .Lrt_truncate
 ldr w2,[sp,#176]
 rt_long .Lrt_meridian
 ldp x9,x10,[sp,#208]
 ldr d0,[x9]
 adrp x11,.Lrt_constants
 ldr d1,[x11,:lo12:.Lrt_constants]
 fmul d0,d1,d0
 rt_double .Lrt_first_lat
 mov x2,#0
 rt_long .Lrt_first_lon
 ldp x9,x10,[sp,#208]
 ldr w11,[sp,#176]
 sub x11,x11,#1
 madd x9,x11,x10,x9
 ldr d0,[x9]
 adrp x11,.Lrt_constants
 ldr d1,[x11,:lo12:.Lrt_constants]
 fmul d0,d1,d0
 rt_double .Lrt_last_lat
 adrp x9,.Lrt_constants
 add x9,x9,:lo12:.Lrt_constants
 ldr d0,[x9,#8]
 ldr w10,[sp,#180]
 scvtf d1,w10
 fdiv d1,d0,d1
 fsub d0,d0,d1
 rt_double .Lrt_last_lon
 ldr w2,[sp,#176]
 add w2,w2,#1
 asr w2,w2,#1
 rt_long .Lrt_gaussian_order
 ldr w9,[sp,#192]
 cbz w9,.Lrt_regular
 adrp x2,.Lrt_reduced_gg
 add x2,x2,:lo12:.Lrt_reduced_gg
 rt_string .Lrt_grid_type,x2,10
 mov x0,x24
 adrp x1,.Lrt_pl
 add x1,x1,:lo12:.Lrt_pl
 mov x2,x26
 ldr w3,[sp,#176]
 bl codes_set_long_array
 cbnz w0,.Lrt_error
 b .Lrt_vertical
.Lrt_regular:
 adrp x2,.Lrt_regular_gg
 add x2,x2,:lo12:.Lrt_regular_gg
 rt_string .Lrt_grid_type,x2,10
 ldr w2,[sp,#180]
 rt_long .Lrt_parallel
 adrp x9,.Lrt_constants
 add x9,x9,:lo12:.Lrt_constants
 ldr d0,[x9,#8]
 ldr w9,[sp,#180]
 scvtf d1,w9
 fdiv d0,d0,d1
 rt_double .Lrt_increment
 b .Lrt_vertical
.Lrt_spectral:
 adrp x2,.Lrt_sh
 add x2,x2,:lo12:.Lrt_sh
 rt_string .Lrt_grid_type,x2,2
 ldr w2,[sp,#184]
 rt_long .Lrt_j
 ldr w2,[sp,#184]
 rt_long .Lrt_k
 ldr w2,[sp,#184]
 rt_long .Lrt_m
.Lrt_vertical:
 cmp w21,#1
 b.eq .Lrt_set_vertical
 cmp w21,#3
 b.ne .Lrt_success
.Lrt_set_vertical:
 mov x0,x24
 adrp x1,.Lrt_pv
 add x1,x1,:lo12:.Lrt_pv
 mov x2,x27
 ldr w3,[sp,#188]
 add x3,x3,#1
 lsl x3,x3,#1
 bl codes_set_double_array
 cbnz w0,.Lrt_error
.Lrt_success:
 str x24,[x22]
 mov x24,#0
 mov w25,#0
 b .Lrt_cleanup
.Lrt_bad:
 mov w25,#2
 b .Lrt_cleanup
.Lrt_alloc_failed:
 mov w25,#1
 b .Lrt_cleanup
.Lrt_error:
 mov w25,w0
.Lrt_cleanup:
 cbz x24,.Lrt_free
 mov x0,x24
 bl codes_handle_delete
.Lrt_free:
 cbz x26,.Lrt_restore
 mov x0,x26
 bl free
.Lrt_restore:
 mov w0,w25
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#512
 ret
.Lrt_invalid:
 mov w0,#2
 ret
.size md2asm_create_runtime_grib_template,.-md2asm_create_runtime_grib_template

/* Resolve a complete canonical rank-one view without floating operations.
 * x0 descriptor, x1 first index, x2 count, x3 element bytes, x4 type.
 * Return x0 first address, x1 byte stride and w2 status.
 */
.Lrt_view:
 ldr x9,[x0]
 cbz x9,.Lrt_view_bad
 ldr x10,[x0,#16]
 cmp x10,x3
 b.ne .Lrt_view_bad
 ldr x10,[x0,#32]
 cmp x10,x3
 b.ne .Lrt_view_bad
 ldr x10,[x0,#24]
 lsl x11,x4,#40
 mov x12,#0x100000000
 orr x11,x11,x12
 cmp x10,x11
 b.ne .Lrt_view_bad
 ldr x10,[x0,#40]
 sub x11,x10,#1
 mov x12,#65535
 cmp x11,x12
 b.hi .Lrt_view_bad
 ldr x11,[x0,#48]
 mov x12,#-16384
 cmp x11,x12
 b.lt .Lrt_view_bad
 cmp x11,x1
 b.gt .Lrt_view_bad
 ldr x12,[x0,#56]
 mov x13,#65536
 cmp x12,x13
 b.gt .Lrt_view_bad
 add x13,x1,x2
 sub x13,x13,#1
 cmp x12,x13
 b.lt .Lrt_view_bad
 ldr x12,[x0,#8]
 mneg x13,x11,x10
 cmp x12,x13
 b.ne .Lrt_view_bad
 sub x11,x1,x11
 mul x11,x11,x10
 mul x11,x11,x3
 adds x9,x9,x11
 b.cs .Lrt_view_bad
 mul x10,x10,x3
 sub x11,x2,#1
 mul x11,x11,x10
 adds x11,x9,x11
 b.cs .Lrt_view_bad
 adds x11,x11,x3
 b.cs .Lrt_view_bad
 sub x12,x3,#1
 tst x9,x12
 b.ne .Lrt_view_bad
 mov x0,x9
 mov x1,x10
 mov w2,#0
 ret
.Lrt_view_bad:
 mov w2,#2
 ret
.section .rodata
.p2align 3
.Lrt_constants:
 .quad 0x404ca5dc1a63c1f8
 .double 360.0
.Lrt_sample_offsets:
 .word .Lrt_sample_sh-.Lrt_sample_offsets
 .word .Lrt_sample_sh_ml-.Lrt_sample_offsets
 .word .Lrt_sample_gg-.Lrt_sample_offsets
 .word .Lrt_sample_gg_ml-.Lrt_sample_offsets
 .word .Lrt_sample_gg2-.Lrt_sample_offsets
.Lrt_sample_sh: .asciz "sh_sfc"
.Lrt_sample_sh_ml: .asciz "sh_ml"
.Lrt_sample_gg: .asciz "gg_sfc_grib1"
.Lrt_sample_gg_ml: .asciz "gg_ml"
.Lrt_sample_gg2: .asciz "gg_sfc_grib2"
.Lrt_latest: .asciz "tablesVersionLatest"
.Lrt_table: .asciz "tablesVersion"
.Lrt_cycle: .asciz "generatingProcessIdentifier"
.Lrt_local: .asciz "localDefinitionNumber"
.Lrt_stream: .asciz "stream"
.Lrt_type: .asciz "type"
.Lrt_class: .asciz "class"
.Lrt_date: .asciz "dataDate"
.Lrt_time: .asciz "time"
.Lrt_experiment: .asciz "experimentVersionNumber"
.Lrt_eps: .asciz "eps"
.Lrt_truncate: .asciz "truncateDegrees"
.Lrt_meridian: .asciz "numberOfPointsAlongAMeridian"
.Lrt_first_lat: .asciz "latitudeOfFirstGridPointInDegrees"
.Lrt_first_lon: .asciz "longitudeOfFirstGridPointInDegrees"
.Lrt_last_lat: .asciz "latitudeOfLastGridPointInDegrees"
.Lrt_last_lon: .asciz "longitudeOfLastGridPointInDegrees"
.Lrt_gaussian_order: .asciz "numberOfParallelsBetweenAPoleAndTheEquator"
.Lrt_grid_type: .asciz "gridType"
.Lrt_reduced_gg: .asciz "reduced_gg"
.Lrt_regular_gg: .asciz "regular_gg"
.Lrt_parallel: .asciz "numberOfPointsAlongAParallel"
.Lrt_increment: .asciz "iDirectionIncrementInDegrees"
.Lrt_sh: .asciz "sh"
.Lrt_j: .asciz "pentagonalResolutionParameterJ"
.Lrt_k: .asciz "pentagonalResolutionParameterK"
.Lrt_m: .asciz "pentagonalResolutionParameterM"
.Lrt_pl: .asciz "pl"
.Lrt_pv: .asciz "pv"
.section .note.GNU-stack,"",%progbits
