/* Contract: skills/md2asm/references/openifs/radiation/longwave_reference_setup.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_longwave_reference_parameters
.type md2asm_initialize_longwave_reference_parameters,%function
md2asm_initialize_longwave_reference_parameters:
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x4
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 orr x6,x0,x2
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lbad
 mov x6,#0x0a80
 movk x6,#1,lsl#16
 cmp x1,x6
 b.lo .Lbad
 cmp x3,#176
 b.lo .Lbad
 cmp x5,#520
 b.lo .Lbad
 adds x7,x0,x6
 b.cs .Lbad
 adds x8,x2,#176
 b.cs .Lbad
 adds x9,x4,#520
 b.cs .Lbad
 cmp x0,x8
 b.hs .Lspan01
 cmp x2,x7
 b.lo .Lbad
.Lspan01:
 cmp x0,x9
 b.hs .Lspan02
 cmp x4,x7
 b.lo .Lbad
.Lspan02:
 cmp x2,x9
 b.hs .Lspans_done
 cmp x4,x8
 b.lo .Lbad
.Lspans_done:
 mrs x6,fpcr
 cbnz x6,.Lbad
 adrp x6,.Lmass_offsets
 add x6,x6,:lo12:.Lmass_offsets
 mov x7,#10
 mov x10,#0x7ff0
 lsl x10,x10,#48
.Lmass_check:
 ldr w8,[x6],#4
 ldr x9,[x21,x8]
 cbz x9,.Lbad
 cmp x9,x10
 b.hs .Lbad
 subs x7,x7,#1
 b.ne .Lmass_check
 mov x7,#104
.Lmix_check:
 ldr x9,[x20,x7]
 lsl x8,x9,#1
 cbz x8,.Lmix_ok
 cmp x9,x10
 b.hs .Lbad
.Lmix_ok:
 add x7,x7,#8
 cmp x7,#168
 b.lo .Lmix_check
 mov x0,x20
 mov x1,x21
 bl md2asm_longwave_mass_mixing_ratios
 mov x0,x19
 bl md2asm_longwave_transmission_table
 ldr x18,[sp,#48]
 adrp x0,.Llongwave_literal_tables
 add x0,x0,:lo12:.Llongwave_literal_tables
 mov x1,#40016
 add x1,x19,x1
 mov x2,#3526
.Lliteral_copy:
 ldr x3,[x0],#8
 str x3,[x1],#8
 subs x2,x2,#1
 b.ne .Lliteral_copy
 mov w0,#0
 b .Lreturn
.Lbad:
 mov w0,#2
.Lreturn:
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.size md2asm_initialize_longwave_reference_parameters,.-md2asm_initialize_longwave_reference_parameters
.p2align 4
.global md2asm_longwave_mass_mixing_ratios
.type md2asm_longwave_mass_mixing_ratios,%function
md2asm_longwave_mass_mixing_ratios:
 ldr d2,[x1,#160]
 adrp x2,.Lratio_plan
 add x2,x2,:lo12:.Lratio_plan
 mov x3,#9
.Lratio:
 ldp w4,w5,[x2]
 ldr w6,[x2,#8]
 cbnz w4,.Lratio_input
 adrp x7,.Lozone_ppmv
 add x7,x7,:lo12:.Lozone_ppmv
 ldr d0,[x7]
 b .Lratio_mass
.Lratio_input:
 ldr d0,[x0,x4]
.Lratio_mass:
 ldr d1,[x1,x5]
 fmul d0,d0,d1
 fdiv d0,d0,d2
 str d0,[x0,x6]
 add x2,x2,#12
 subs x3,x3,#1
 b.ne .Lratio
 adrp x2,.Lsurdi_literals
 add x2,x2,:lo12:.Lsurdi_literals
 ldp x3,x4,[x2]
 stp x3,x4,[x0]
 ldr x3,[x2,#16]
 str x3,[x0,#88]
 str x3,[x0,#96]
 ret
.size md2asm_longwave_mass_mixing_ratios,.-md2asm_longwave_mass_mixing_ratios
.p2align 4
.global md2asm_longwave_transmission_table
.type md2asm_longwave_transmission_table,%function
md2asm_longwave_transmission_table:
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 adrp x9,.Ltrans_constants
 add x9,x9,:lo12:.Ltrans_constants
 ldr d0,[x9]
 mov x10,#40008
 str d0,[x19,x10]
 fmov d0,#1.0
 str d0,[x19]
 mov x10,#40000
 str xzr,[x19,x10]
 mov x20,#1
.Ltrans_loop:
 scvtf d0,x20
 adrp x9,.Ltrans_constants
 add x9,x9,:lo12:.Ltrans_constants
 ldp d1,d2,[x9]
 fdiv d0,d0,d2
 fmul d1,d1,d0
 fmov d2,#1.0
 fsub d2,d2,d0
 fdiv d0,d1,d2
 fneg d0,d0
 bl md2asm_exp_original_rounding
 ldr x18,[sp,#32]
 str d0,[x19,x20,lsl#3]
 add x20,x20,#1
 mov x9,#5000
 cmp x20,x9
 b.lo .Ltrans_loop
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.size md2asm_longwave_transmission_table,.-md2asm_longwave_transmission_table
.section .rodata
.p2align 3
.Lsurdi_literals: .double 0.1277e-2,120.0,1e-12
.Lozone_ppmv: .double 1e-6
.Ltrans_constants: .quad 0x400cc6e80ebbdb2a
 .double 5000.0
.Lmass_offsets: .word 160,248,256,264,288,176,312,320,328,336
.Lratio_plan:
 .word 104,248,16
 .word 112,256,24
 .word 120,264,32
 .word 128,288,40
 .word 0,176,48
 .word 136,312,64
 .word 144,320,72
 .word 152,328,80
 .word 160,336,56
#include "longwave_reference_tables.inc.S"
.section .note.GNU-stack,"",%progbits
