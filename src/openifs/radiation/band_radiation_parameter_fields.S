/* Contract: skills/md2asm/references/openifs/radiation/band_radiation_setup.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_longwave_band_parameter_fields
.type md2asm_longwave_band_parameter_fields,%function
md2asm_longwave_band_parameter_fields:
 adr x9,.Llw_rows
 mov x10,#1183
.Llongwave_row:
 ldp x11,x12,[x9]
 ldr x13,[x9,#16]
 cmp x13,#4
 b.eq .Llongwave_int
 str x12,[x0,x11]
 b .Llongwave_next
.Llongwave_int:
 str w12,[x0,x11]
.Llongwave_next:
 add x9,x9,#24
 subs x10,x10,#1
 b.ne .Llongwave_row
 ret
.size md2asm_longwave_band_parameter_fields,.-md2asm_longwave_band_parameter_fields
.p2align 4
.global md2asm_selected_shortwave_parameter_fields
.type md2asm_selected_shortwave_parameter_fields,%function
md2asm_selected_shortwave_parameter_fields:
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adr x9,.Lpressure_constants
 ldp d0,d1,[x9]
 fmov d2,#1.0
 fadd d0,d0,d2
 fadd d1,d1,d2
 str d0,[x19,#2432]
 str d1,[x19,#2440]
 ldr d2,[x20,#112]
 ldr d3,[x21]
 fdiv d2,d2,d3
 fmov d3,#10.0
 fmul d2,d3,d2
 fmul d0,d2,d0
 fmul d1,d2,d1
 fmov d3,#1.0
 fdiv d0,d3,d0
 fdiv d1,d3,d1
 stp d0,d1,[sp,#64]
 adr x9,.Lpressure_constants
 ldr d0,[x9,#16]
 ldr d1,[x9,#8]
 bl pow
 ldr x18,[sp,#96]
 ldr d1,[sp,#72]
 fdiv d0,d1,d0
 str d0,[x19,#2456]
 adr x9,.Lpressure_constants
 ldr d0,[x9,#16]
 ldr d1,[x9]
 bl pow
 ldr x18,[sp,#96]
 ldr d1,[sp,#64]
 fdiv d0,d1,d0
 str d0,[x19,#2448]
 adr x9,.Lsw_rows
 mov x10,#413
.Lshortwave_row:
 ldp x11,x12,[x9]
 ldr x13,[x9,#16]
 cmp x13,#4
 b.eq .Lshortwave_int
 str x12,[x19,x11]
 b .Lshortwave_next
.Lshortwave_int:
 str w12,[x19,x11]
.Lshortwave_next:
 add x9,x9,#24
 subs x10,x10,#1
 b.ne .Lshortwave_row
 ldr x9,[x19,#2304]
 ldr x10,[x19,#2368]
 mov x11,#14
.Lsolar_zero:
 str xzr,[x9],#8
 str xzr,[x10],#8
 subs x11,x11,#1
 b.ne .Lsolar_zero
 ldr x9,[x19,#2304]
 ldr x10,[x19,#2368]
 adr x11,.LZSUN6
 adr x12,.LZSUN2KM6
 mov x13,#6
.Lsolar_coefficients:
 ldr x14,[x11],#8
 ldr x15,[x12],#8
 str x14,[x9],#8
 str x15,[x10],#8
 subs x13,x13,#1
 b.ne .Lsolar_coefficients
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_selected_shortwave_parameter_fields,.-md2asm_selected_shortwave_parameter_fields
.section .rodata
.p2align 3
.Lpressure_constants: .double .90,.75,101300.0
#include "band_radiation_literals.inc.S"
.section .note.GNU-stack,"",%progbits
