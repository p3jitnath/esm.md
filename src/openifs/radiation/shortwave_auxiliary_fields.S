/* Original ordered field writes for three complete shortwave setup children.
 * x0=validated complete output namespace; return0. Only EXP is external.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_shortwave_transmission_table_fields
.type md2asm_shortwave_transmission_table_fields,%function
md2asm_shortwave_transmission_table_fields:
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 movz x9,#0x3888
 movk x9,#1,lsl #16
 add x21,x19,x9
 adrp x9,.Lsw_constants
 add x9,x9,:lo12:.Lsw_constants
 ldr x10,[x9,#8]
 str x10,[x21,#8]
 ldr x10,[x9,#16]
 str x10,[x21,#16]
 ldr x10,[x9]
 str x10,[x21]
 fmov d0,#1.0
 str d0,[x19]
 str xzr,[x21,#-8]
 mov x20,#1
.Lsw_transmission_loop:
 scvtf d0,w20
 ldr d1,[x21,#16]
 fdiv d0,d0,d1
 ldr d1,[x21]
 fmul d1,d1,d0
 fmov d2,#1.0
 fsub d0,d2,d0
 fdiv d0,d1,d0
 fneg d0,d0
 bl exp
 ldr x18,[sp,#40]
 str d0,[x19,x20,lsl #3]
 add x20,x20,#1
 mov x9,#10000
 cmp x20,x9
 b.lo .Lsw_transmission_loop
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_shortwave_transmission_table_fields,.-md2asm_shortwave_transmission_table_fields
.p2align 4
.global md2asm_shortwave_aerosol_optical_fields
.type md2asm_shortwave_aerosol_optical_fields,%function
md2asm_shortwave_aerosol_optical_fields:
 adrp x9,.Lsw_aerosol_literals
 add x9,x9,:lo12:.Lsw_aerosol_literals
 mov x10,#0
.Lsw_aerosol_interval:
 mov x11,x10
 mov x12,#0
.Lsw_aerosol_type:
 ldr x13,[x9,x11]
 str x13,[x0,x11]
 add x14,x11,#672
 ldr x13,[x9,x14]
 str x13,[x0,x14]
 add x14,x14,#672
 ldr x13,[x9,x14]
 str x13,[x0,x14]
 add x11,x11,#112
 add x12,x12,#1
 cmp x12,#6
 b.lo .Lsw_aerosol_type
 add x10,x10,#8
 cmp x10,#112
 b.lo .Lsw_aerosol_interval
 mov w0,#0
 ret
.size md2asm_shortwave_aerosol_optical_fields,.-md2asm_shortwave_aerosol_optical_fields
.p2align 4
.global md2asm_shortwave_cloud_optical_fields
.type md2asm_shortwave_cloud_optical_fields,%function
md2asm_shortwave_cloud_optical_fields:
 adrp x9,.Lsw_cloud_literals
 add x9,x9,:lo12:.Lsw_cloud_literals
 adrp x10,.Lsw_cloud_operations
 add x10,x10,:lo12:.Lsw_cloud_operations
 adrp x11,.Lsw_constants
 add x11,x11,:lo12:.Lsw_constants
 ldr d1,[x11,#24]
 ldr d2,[x11,#32]
 mov x12,#0
.Lsw_cloud_interval:
 mov x13,#0
 mov x14,x10
.Lsw_cloud_field:
 ldp w15,w16,[x14]
 ldr w17,[x14,#8]
 add x16,x16,x12
 ldr d0,[x9,x16]
 cmp w17,#1
 b.eq .Lsw_scale_one
 cmp w17,#2
 b.ne .Lsw_cloud_store
 fmul d0,d0,d2
 b .Lsw_cloud_store
.Lsw_scale_one:
 fmul d0,d0,d1
.Lsw_cloud_store:
 add x15,x15,x12
 str d0,[x0,x15]
 add x14,x14,#12
 add x13,x13,#1
 cmp x13,#42
 b.lo .Lsw_cloud_field
 add x12,x12,#8
 cmp x12,#112
 b.lo .Lsw_cloud_interval
 mov w0,#0
 ret
.size md2asm_shortwave_cloud_optical_fields,.-md2asm_shortwave_cloud_optical_fields
#include "shortwave_auxiliary_literals.inc.S"
.section .note.GNU-stack,"",%progbits
