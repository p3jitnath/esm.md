/* Contract: skills/md2asm/references/openifs/radiation/cams_climatology_setup.md.
 * Complete selected two-dimensional SETUP_MACC data path from original NetCDF.
 * x0 path,x1 path bytes,x2 TEAERC_MACC6432,x3 capacity. Return0/1/2.
 */
.arch armv8.2-a
.text
.p2align 4
.macro MCALL target
 bl \target
 ldr x18,[sp,#16]
.endm
.global md2asm_initialize_cams_climatology
.type md2asm_initialize_cams_climatology,%function
md2asm_initialize_cams_climatology:
 cbz x0,.Lmacc_bad
 cbz x2,.Lmacc_bad
 cbz x1,.Lmacc_bad
 cmp x1,#4095
 b.hi .Lmacc_bad
 tst x2,#7
 b.ne .Lmacc_bad
 mov x9,#6432
 cmp x3,x9
 b.lo .Lmacc_bad
 adds x10,x2,x9
 b.cs .Lmacc_bad
 adds x11,x0,x1
 b.cs .Lmacc_bad
 adds x11,x11,#1
 b.cs .Lmacc_bad
 cmp x0,x10
 b.hs .Lmacc_path
 cmp x2,x11
 b.lo .Lmacc_bad
.Lmacc_path:
 mov x9,#0
.Lmacc_path_scan:
 ldrb w10,[x0,x9]
 cbz w10,.Lmacc_bad
 add x9,x9,#1
 cmp x9,x1
 b.lo .Lmacc_path_scan
 ldrb w10,[x0,x1]
 cbnz w10,.Lmacc_bad
 ldr w10,[x2,#6424]
 cbnz w10,.Lmacc_bad
 adrp x9,.Lmacc_plan
 add x9,x9,:lo12:.Lmacc_plan
 mov x10,#0
.Lmacc_fresh:
 add x11,x9,x10,lsl #4
 ldr w12,[x11]
 ldr x12,[x2,x12]
 cbnz x12,.Lmacc_bad
 add x10,x10,#1
 cmp x10,#22
 b.lo .Lmacc_fresh
 sub sp,sp,#2720
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,#-1
 mov w25,#1
 add x27,sp,#256
 adrp x23,.Lmacc_plan
 add x23,x23,:lo12:.Lmacc_plan
 mov x22,#0
 mov x10,#112
.Lmacc_clear_private_bases:
 mul x9,x22,x10
 str xzr,[x27,x9]
 add x22,x22,#1
 cmp x22,#22
 b.lo .Lmacc_clear_private_bases
 mov x0,x19
 mov w1,#0
 add x2,sp,#128
 MCALL nc_open
 cbnz w0,.Lmacc_cleanup
 ldr w21,[sp,#128]
 mov x22,#0
.Lmacc_query:
 add x9,x23,x22,lsl #4
 ldr x1,[x9,#8]
 mov w0,w21
 add x2,sp,#136
 add x2,x2,x22,lsl #2
 MCALL nc_inq_varid
 cbnz w0,.Lmacc_cleanup
 mov w0,w21
 add x9,sp,#136
 ldr w1,[x9,x22,lsl #2]
 add x2,sp,#132
 MCALL nc_inq_varndims
 cbnz w0,.Lmacc_cleanup
 ldr w9,[sp,#132]
 cmp w9,#3
 b.ne .Lmacc_shape_bad
 mov w0,w21
 add x9,sp,#136
 ldr w1,[x9,x22,lsl #2]
 add x2,sp,#184
 MCALL nc_inq_vardimid
 cbnz w0,.Lmacc_cleanup
 mov x26,#0
.Lmacc_dimension:
 mov w0,w21
 add x9,sp,#184
 ldr w1,[x9,x26,lsl #2]
 add x2,sp,#200
 MCALL nc_inq_dimlen
 cbnz w0,.Lmacc_cleanup
 adrp x9,.Lmacc_C_dimensions
 add x9,x9,:lo12:.Lmacc_C_dimensions
 ldr x9,[x9,x26,lsl #3]
 ldr x10,[sp,#200]
 cmp x9,x10
 b.ne .Lmacc_shape_bad
 add x26,x26,#1
 cmp x26,#3
 b.lo .Lmacc_dimension
 add x22,x22,#1
 cmp x22,#11
 b.lo .Lmacc_query
 mov x22,#0
.Lmacc_monthly:
 mov x9,#112
 madd x24,x22,x9,x27
 mov x0,x24
 mov w1,#3
 adrp x2,.Lmacc_extents
 add x2,x2,:lo12:.Lmacc_extents
 mov w3,#1
 mov w4,#0
 MCALL md2asm_allocate_radiation_flux_array
 cbnz w0,.Lmacc_cleanup
 mov w0,w21
 add x9,sp,#136
 ldr w1,[x9,x22,lsl #2]
 ldr x2,[x24]
 MCALL nc_get_var_double
 cbnz w0,.Lmacc_cleanup
 add x22,x22,#1
 cmp x22,#11
 b.lo .Lmacc_monthly
 /* Source closes its file before allocating interpolation work arrays. */
 mov w0,w21
 MCALL nc_close
 mov x21,#-1
 cbnz w0,.Lmacc_cleanup
.Lmacc_interpolation:
 mov x9,#112
 madd x24,x22,x9,x27
 mov x0,x24
 mov w1,#2
 adrp x2,.Lmacc_extents
 add x2,x2,:lo12:.Lmacc_extents
 mov w3,#1
 mov w4,#0
 MCALL md2asm_allocate_radiation_flux_array
 cbnz w0,.Lmacc_cleanup
 add x22,x22,#1
 cmp x22,#22
 b.lo .Lmacc_interpolation
 mov x22,#0
.Lmacc_commit:
 add x9,x23,x22,lsl #4
 ldp w10,w11,[x9]
 add x10,x20,x10
 cmp w11,#3
 mov x11,#112
 mov x12,#88
 csel x11,x11,x12,eq
 mov x9,#112
 madd x9,x22,x9,x27
.Lmacc_copy_descriptor:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#8
 b.ne .Lmacc_copy_descriptor
 add x22,x22,#1
 cmp x22,#22
 b.lo .Lmacc_commit
 mov w9,#1
 str w9,[x20,#6424]
 mov w25,#0
 b .Lmacc_return
.Lmacc_shape_bad:
 mov w25,#2
.Lmacc_cleanup:
 cmp x21,#0
 b.lt .Lmacc_free
 mov w0,w21
 MCALL nc_close
 mov x21,#-1
.Lmacc_free:
 mov x22,#0
.Lmacc_free_next:
 mov x9,#112
 madd x24,x22,x9,x27
 ldr x0,[x24]
 cbz x0,.Lmacc_free_skip
 MCALL free
 str xzr,[x24]
.Lmacc_free_skip:
 add x22,x22,#1
 cmp x22,#22
 b.lo .Lmacc_free_next
.Lmacc_return:
 mov w0,w25
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#2720
 ret
.size md2asm_initialize_cams_climatology,.-md2asm_initialize_cams_climatology
.p2align 4
.global md2asm_release_cams_climatology
.type md2asm_release_cams_climatology,%function
md2asm_release_cams_climatology:
 cbz x0,.Lmacc_bad
 tst x0,#7
 b.ne .Lmacc_bad
 mov x9,#6432
 cmp x1,x9
 b.lo .Lmacc_bad
 adds x9,x0,x9
 b.cs .Lmacc_bad
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov x20,#0
 adrp x21,.Lmacc_plan
 add x21,x21,:lo12:.Lmacc_plan
.Lmacc_release_next:
 add x9,x21,x20,lsl #4
 ldr w9,[x9]
 ldr x0,[x19,x9]
 cbz x0,.Lmacc_release_skip
 bl free
 ldr x18,[sp,#40]
 add x9,x21,x20,lsl #4
 ldr w9,[x9]
 str xzr,[x19,x9]
.Lmacc_release_skip:
 add x20,x20,#1
 cmp x20,#22
 b.lo .Lmacc_release_next
 str wzr,[x19,#6424]
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_cams_climatology,.-md2asm_release_cams_climatology
.Lmacc_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lmacc_C_dimensions:.quad 12,61,120
.Lmacc_extents:.word 120,61,12,0
#include "cams_climatology_fields.inc.S"
.section .note.GNU-stack,"",%progbits
