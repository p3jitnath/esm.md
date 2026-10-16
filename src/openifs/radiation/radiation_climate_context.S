/* Contract: skills/md2asm/references/openifs/radiation/radiation_climate_inputs.md.
 * create(x0 null owner8,x1 paths48,x2 owned constants520,x3 capacity>=520).
 * paths has three {address,uint64 length} pairs: solar,climatology,series.
 * Complete resolved paths contain1..511 bytes with no embedded zero.
 * Return0 success,1 allocation failure,2 unsupported input,3 file error.
 * No OpenIFS callable, global, type metadata or prepared state is used. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_radiation_climate_context
.type md2asm_create_radiation_climate_context,%function
md2asm_create_radiation_climate_context:
 cbz x0,.Lrc_bad_leaf
 cbz x1,.Lrc_bad_leaf
 cbz x2,.Lrc_bad_leaf
 cmp x3,#520
 b.lo .Lrc_bad_leaf
 orr x4,x0,x1
 orr x4,x4,x2
 tst x4,#7
 b.ne .Lrc_bad_leaf
 adds x4,x0,#8
 b.cs .Lrc_bad_leaf
 adds x5,x1,#48
 b.cs .Lrc_bad_leaf
 adds x6,x2,#520
 b.cs .Lrc_bad_leaf
 cmp x0,x5
 b.hs .Lrc_paths_clear
 cmp x1,x4
 b.lo .Lrc_bad_leaf
.Lrc_paths_clear:
 cmp x0,x6
 b.hs .Lrc_constants_clear
 cmp x2,x4
 b.lo .Lrc_bad_leaf
.Lrc_constants_clear:
 ldr x7,[x0]
 cbnz x7,.Lrc_bad_leaf
 mrs x7,fpcr
 cbnz x7,.Lrc_bad_leaf
 ldr x7,[x2]
 adrp x8,.Lrc_owned_pi
 add x8,x8,:lo12:.Lrc_owned_pi
 ldr x8,[x8]
 cmp x7,x8
 b.ne .Lrc_bad_leaf
 mov x7,#0
.Lrc_check_path:
 add x8,x1,x7,lsl#4
 ldp x9,x10,[x8]
 cbz x9,.Lrc_bad_leaf
 sub x11,x10,#1
 cmp x11,#510
 b.hi .Lrc_bad_leaf
 adds x11,x9,x10
 b.cs .Lrc_bad_leaf
 cmp x0,x11
 b.hs .Lrc_path_clear
 cmp x9,x4
 b.lo .Lrc_bad_leaf
.Lrc_path_clear:
 mov x12,#0
.Lrc_path_byte:
 ldrb w13,[x9,x12]
 cbz w13,.Lrc_bad_leaf
 add x12,x12,#1
 cmp x12,x10
 b.lo .Lrc_path_byte
 add x7,x7,#1
 cmp x7,#3
 b.lo .Lrc_check_path
 sub sp,sp,#832
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x23,x2
 mov x21,xzr
 mov w26,#-1
 mov x0,#1
 mov x1,#2792
 bl calloc
 cbz x0,.Lrc_malloc_error
 mov x21,x0
 mov x22,#0
.Lrc_open_file:
 add x9,x20,x22,lsl#4
 ldp x1,x2,[x9]
 str x2,[sp,#136]
 add x0,sp,#256
 bl memcpy
 ldr x9,[sp,#136]
 add x10,sp,#256
 strb wzr,[x10,x9]
 mov x0,x10
 mov w1,#0
 add x2,sp,#128
 bl nc_open
 cbnz w0,.Lrc_file_error
 ldr w26,[sp,#128]
 adrp x9,.Lrc_file_plans
 add x9,x9,:lo12:.Lrc_file_plans
 add x9,x9,x22,lsl#4
 ldp w10,w11,[x9]
 adrp x24,.Lrc_array_plans
 add x24,x24,:lo12:.Lrc_array_plans
 add x24,x24,x10
 add x25,x24,x11
.Lrc_file_array:
 ldr w9,[x24]
 add x2,x21,x9
 ldr w3,[x24,#4]
 ldr w5,[x24,#12]
 cmp w5,#2
 b.eq .Lrc_zero_array
 adrp x10,.Lrc_names
 add x10,x10,:lo12:.Lrc_names
 ldr w9,[x24,#8]
 add x1,x10,x9
 mov w0,w26
 add x4,x24,#16
 bl md2asm_read_radiation_netcdf_array
 b .Lrc_array_done
.Lrc_zero_array:
 mov x0,x2
 mov w1,w3
 add x2,x24,#16
 mov w3,#1
 mov w4,#1
 bl md2asm_allocate_radiation_array
.Lrc_array_done:
 cbnz w0,.Lrc_child_error
 add x24,x24,#32
 cmp x24,x25
 b.lo .Lrc_file_array
 mov w0,w26
 bl nc_close
 mov w26,#-1
 cbnz w0,.Lrc_file_error
 cbnz x22,.Lrc_not_solar
 mov w9,#450
 str w9,[x21,#128]
 b .Lrc_next_file
.Lrc_not_solar:
 cmp x22,#1
 b.ne .Lrc_not_climatology
 mov w9,#91
 str w9,[x21,#1856]
 mov w9,#64
 str w9,[x21,#1860]
 add x0,x21,#656
 mov x1,x23
 bl md2asm_initialize_radiation_climatology_means
 b .Lrc_next_file
.Lrc_not_climatology:
 mov w9,#2501
 str w9,[x21,#648]
.Lrc_next_file:
 add x22,x22,#1
 cmp x22,#3
 b.lo .Lrc_open_file
 adrp x24,.Lrc_rad_plans
 add x24,x24,:lo12:.Lrc_rad_plans
 mov x25,#0
.Lrc_rad_array:
 ldr w9,[x24]
 add x0,x21,x9
 ldr w1,[x24,#4]
 add x2,x24,#16
 ldr w3,[x24,#12]
 mov w4,#0
 bl md2asm_allocate_radiation_array
 cbnz w0,.Lrc_child_error
 add x24,x24,#32
 add x25,x25,#1
 cmp x25,#11
 b.lo .Lrc_rad_array
 mov w9,#64
 str w9,[x21,#2784]
 mov w9,#91
 str w9,[x21,#2788]
 add x0,x21,#1864
 add x1,x21,#656
 mov x2,x23
 bl md2asm_initialize_radiation_gas_coordinates
 str x21,[x19]
 mov w0,#0
 b .Lrc_return
.Lrc_child_error:
 mov w27,w0
 b .Lrc_cleanup
.Lrc_file_error:
 mov w27,#3
 b .Lrc_cleanup
.Lrc_malloc_error:
 mov w27,#1
.Lrc_cleanup:
 cmn w26,#1
 b.eq .Lrc_no_open_file
 mov w0,w26
 bl nc_close
.Lrc_no_open_file:
 cbz x21,.Lrc_failure_result
 mov x0,x21
 bl .Lrc_free_context
.Lrc_failure_result:
 mov w0,w27
.Lrc_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#832
 ret
.Lrc_bad_leaf:
 mov w0,#2
 ret
.size md2asm_create_radiation_climate_context,.-md2asm_create_radiation_climate_context

.p2align 4
.global md2asm_release_radiation_climate_context
.type md2asm_release_radiation_climate_context,%function
md2asm_release_radiation_climate_context:
 cbz x0,.Lrc_bad_leaf
 tst x0,#7
 b.ne .Lrc_bad_leaf
 adds x1,x0,#8
 b.cs .Lrc_bad_leaf
 ldr x1,[x0]
 cbz x1,.Lrc_release_empty
 stp x29,x30,[sp,#-32]!
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x0
 mov x0,x1
 bl .Lrc_free_context
 str xzr,[x19]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#32
.Lrc_release_empty:
 mov w0,#0
 ret
.size md2asm_release_radiation_climate_context,.-md2asm_release_radiation_climate_context

/* Internal cleanup owns only bases explicitly listed in the source maps. */
.Lrc_free_context:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 adrp x20,.Lrc_release_offsets
 add x20,x20,:lo12:.Lrc_release_offsets
 mov x21,#32
.Lrc_free_owner:
 ldr w9,[x20],#4
 ldr x0,[x19,x9]
 cbz x0,.Lrc_free_next
 bl free
.Lrc_free_next:
 subs x21,x21,#1
 b.ne .Lrc_free_owner
 mov x0,x19
 bl free
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret

.section .rodata
.p2align 3
.Lrc_owned_pi: .quad 0x400921fb54442d18
/* Rows are byte offset and byte length within the source array plan. */
.Lrc_file_plans: .word 0,64,0,0,64,352,0,0,416,256,0,0
.p2align 3
.Lrc_array_plans:
 .word 0,1,0,0,450,1,1,0
 .word 64,1,5,0,450,1,1,0
 .word 656,1,9,0,91,1,1,0
 .word 720,1,18,0,64,1,1,0
 .word 784,3,27,0,64,91,12,0
 .word 896,3,35,0,64,91,12,0
 .word 1008,3,43,0,64,91,12,0
 .word 1232,3,51,0,64,91,12,0
 .word 1344,3,61,0,64,91,12,0
 .word 1456,3,71,0,64,91,12,0
 .word 1568,3,78,0,64,91,12,0
 .word 1680,3,89,0,64,91,12,0
 .word 1120,3,98,2,64,91,12,0
 .word 136,1,0,0,2501,1,1,0
 .word 200,1,27,0,2501,1,1,0
 .word 264,1,35,0,2501,1,1,0
 .word 328,1,43,0,2501,1,1,0
 .word 392,1,51,0,2501,1,1,0
 .word 456,1,61,0,2501,1,1,0
 .word 520,1,78,1,2501,1,1,0
 .word 584,1,89,1,2501,1,1,0
.Lrc_rad_plans:
 .word 1864,1,0,1,64,1,1,0
 .word 1928,1,0,0,92,1,1,0
 .word 1992,2,0,1,64,91,1,0
 .word 2080,2,0,1,64,91,1,0
 .word 2168,2,0,1,64,91,1,0
 .word 2256,2,0,1,64,91,1,0
 .word 2344,2,0,1,64,91,1,0
 .word 2432,2,0,1,64,91,1,0
 .word 2520,2,0,1,64,91,1,0
 .word 2608,2,0,1,64,91,1,0
 .word 2696,2,0,1,64,91,1,0
.Lrc_names:
 .asciz "time"
 .asciz "tsi"
 .asciz "pressure"
 .asciz "latitude"
 .asciz "co2_vmr"
 .asciz "ch4_vmr"
 .asciz "n2o_vmr"
 .asciz "cfc11_vmr"
 .asciz "cfc12_vmr"
 .asciz "o3_vmr"
 .asciz "hcfc22_vmr"
 .asciz "ccl4_vmr"
 .asciz ""
.p2align 2
.Lrc_release_offsets:
 .word 0,64,656,720,784,896,1008,1232,1344,1456,1568,1680,1120,136,200,264,328,392,456,520,584,1864,1928,1992,2080,2168,2256,2344,2432,2520,2608,2696
.section .note.GNU-stack,"",%progbits
