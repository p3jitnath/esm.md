// Own the SUPHEC thermal namespace and the complete SUVDFS table.
// Contract: skills/md2asm/references/openifs/setup/thermal_diffusion_parameter_setup.md
.arch armv8-a
.text
.p2align 4
.global md2asm_initialize_thermal_diffusion_parameters
.type md2asm_initialize_thermal_diffusion_parameters,%function
// x0: aligned 1920-byte output; x1: capacity; x2: constants520; x3: capacity.
// Return 0 on success, or 2 before mutation. Preserve errno and raw FP control.
md2asm_initialize_thermal_diffusion_parameters:
 cbz x0,.Lreject
 cbz x2,.Lreject
 cmp x1,#1920
 b.lo .Lreject
 cmp x3,#520
 b.lo .Lreject
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lreject
 adds x4,x0,#1920
 b.cs .Lreject
 adds x5,x2,#520
 b.cs .Lreject
 cmp x0,x5
 b.hs .Ldisjoint
 cmp x2,x4
 b.lo .Lreject
.Ldisjoint:
 mrs x4,fpcr
 cbnz x4,.Lreject
 adrp x4,.Linput_ranges
 add x4,x4,:lo12:.Linput_ranges
 mov x8,#7
.Lrange_loop:
 ldp x5,x6,[x4]
 ldr x7,[x4,#16]
 ldr x9,[x2,x5]
 cmp x9,x6
 b.lo .Lreject
 cmp x9,x7
 b.hi .Lreject
 add x4,x4,#24
 subs x8,x8,#1
 b.ne .Lrange_loop
 stp x29,x30,[sp,#-32]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 mov x19,x0
 mov x1,x2
 bl md2asm_initialize_thermal_namespace_fields
 add x0,x19,#184
 bl md2asm_initialize_stability_table_fields
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Lreject:
 mov w0,#2
 ret
.size md2asm_initialize_thermal_diffusion_parameters,.-md2asm_initialize_thermal_diffusion_parameters

.p2align 4
.global md2asm_initialize_thermal_namespace_fields
.type md2asm_initialize_thermal_namespace_fields,%function
// Raw child: x0 is 184 writable bytes; x1 is constants520, disjoint and aligned.
// Preserve the exact source dependency order, including the initial ice range.
md2asm_initialize_thermal_namespace_fields:
 adrp x8,.Lthermal_literals
 add x8,x8,:lo12:.Lthermal_literals
 ldr d0,[x8,#0]
 ldr d1,[x1,#184]
 fmul d0,d0,d1
 ldr d1,[x1,#192]
 fdiv d0,d0,d1
 str d0,[x0,#0]
 ldp d0,d1,[x8,#8]
 stp d0,d1,[x0,#8]
 ldp d2,d3,[x8,#24]
 stp d2,d3,[x0,#24]
 ldr d4,[x1,#368]
 fsub d5,d4,d2
 fmul d5,d0,d5
 str d5,[x0,#40]
 fsub d6,d4,d3
 fmul d6,d1,d6
 str d6,[x0,#48]
 stp xzr,xzr,[x0,#56]
 ldr d0,[x8,#40]
 str d0,[x0,#64]
 ldr d0,[x1,#376]
 ldr d1,[x1,#384]
 ldr d2,[x1,#200]
 fmul d3,d5,d0
 fdiv d3,d3,d2
 str d3,[x0,#72]
 fmul d3,d6,d1
 fdiv d3,d3,d2
 str d3,[x0,#80]
 fdiv d0,d0,d2
 fdiv d1,d1,d2
 stp d0,d1,[x0,#88]
 ldr d0,[x1,#408]
 fdiv d0,d0,d2
 str d0,[x0,#104]
 str d4,[x0,#112]
 ldr d0,[x8,#48]
 fsub d0,d4,d0
 stp d0,d0,[x0,#120]
 ldr d0,[x8,#56]
 fsub d0,d4,d0
 stp d0,d0,[x0,#136]
 fsub d0,d4,d0
 fmov d1,#1.0
 fdiv d0,d1,d0
 stp d0,d0,[x0,#152]
 ldp d0,d1,[x8,#64]
 stp d0,d1,[x0,#168]
 mov w0,#0
 ret
.size md2asm_initialize_thermal_namespace_fields,.-md2asm_initialize_thermal_namespace_fields

.p2align 4
.global md2asm_initialize_stability_table_fields
.type md2asm_initialize_stability_table_fields,%function
// Raw child: x0 owns 1736 bytes. ZU(101) is private 808-byte stack scratch.
// It has no calls, retained pointers or heap allocation. Stack use is 832 bytes.
md2asm_initialize_stability_table_fields:
 sub sp,sp,#832
 mov x5,sp
 add x6,x0,#808
 adrp x7,.Lstable_constants
 add x7,x7,:lo12:.Lstable_constants
 add x8,x0,#1616
 mov x9,#15
.Lcopy_scalars:
 ldr x10,[x7],#8
 str x10,[x8],#8
 subs x9,x9,#1
 b.ne .Lcopy_scalars
 str xzr,[x0]
 fmov d29,#1.0
 fmov d30,#4.0
 fmov d31,#5.0
 ldr d28,[x0,#1720]
 adrp x7,.Literation_constants
 add x7,x7,:lo12:.Literation_constants
 ldr d27,[x7]
 mov x4,#1
.Ltable_point:
 scvtf d0,x4
 fmul d16,d0,d28
 sub x8,x4,#1
 ldr d17,[x0,x8,lsl #3]
 fmov d0,#0.5
 fcmp d16,d0
 mov x9,#3
 mov x10,#5
 csel x9,x10,x9,lt
.Lnewton:
 fadd d18,d17,d29
 fmul d18,d18,d27
 fadd d19,d17,d18
 fsub d20,d17,d18
 fmul d0,d30,d19
 fadd d0,d29,d0
 fmul d0,d0,d0
 fmul d0,d19,d0
 fmul d1,d31,d19
 fadd d1,d29,d1
 fmul d1,d1,d1
 fdiv d0,d0,d1
 fsub d21,d16,d0
 fmul d0,d30,d20
 fadd d0,d29,d0
 fmul d0,d0,d0
 fmul d0,d20,d0
 fmul d1,d31,d20
 fadd d1,d29,d1
 fmul d1,d1,d1
 fdiv d0,d0,d1
 fsub d22,d16,d0
 fadd d0,d21,d22
 fmul d0,d18,d0
 fsub d1,d21,d22
 fdiv d0,d0,d1
 fsub d17,d17,d0
 subs x9,x9,#1
 b.ne .Lnewton
 str d17,[x0,x4,lsl #3]
 add x4,x4,#1
 cmp x4,#101
 b.lo .Ltable_point
 // Set the left clamped spline equation; the right slope is the last secant.
 fmov d23,#0.5
 fneg d0,d23
 str d0,[x6]
 fmov d24,#2.0
 fmov d25,#3.0
 fmov d26,#6.0
 ldp d0,d1,[x0]
 fsub d0,d1,d0
 fdiv d0,d0,d28
 fsub d0,d0,d29
 fdiv d1,d25,d28
 fmul d0,d1,d0
 str d0,[x5]
 mov x4,#1
.Lspline_forward:
 sub x8,x4,#1
 ldr d0,[x6,x8,lsl #3]
 fmul d0,d23,d0
 fadd d0,d0,d24
 fneg d1,d23
 fdiv d1,d1,d0
 str d1,[x6,x4,lsl #3]
 add x9,x4,#1
 ldr d1,[x0,x9,lsl #3]
 ldr d2,[x0,x4,lsl #3]
 ldr d3,[x0,x8,lsl #3]
 fsub d1,d1,d2
 fdiv d1,d1,d28
 fsub d2,d2,d3
 fdiv d2,d2,d28
 fsub d1,d1,d2
 fmul d1,d26,d1
 fmul d2,d24,d28
 fdiv d1,d1,d2
 ldr d2,[x5,x8,lsl #3]
 fmul d2,d23,d2
 fsub d1,d1,d2
 fdiv d1,d1,d0
 str d1,[x5,x4,lsl #3]
 add x4,x4,#1
 cmp x4,#100
 b.lo .Lspline_forward
 // Keep the source's repeated secant and subtraction, including its zero.
 ldr d0,[x0,#800]
 ldr d1,[x0,#792]
 fsub d2,d0,d1
 fdiv d2,d2,d28
 fsub d0,d0,d1
 fdiv d0,d0,d28
 fsub d0,d2,d0
 fdiv d1,d25,d28
 fmul d0,d1,d0
 ldr d1,[x5,#792]
 fmul d1,d23,d1
 fsub d0,d0,d1
 ldr d1,[x6,#792]
 fmul d1,d23,d1
 fadd d1,d1,d29
 fdiv d0,d0,d1
 str d0,[x6,#800]
 mov x4,#99
.Lspline_backward:
 add x8,x4,#1
 ldr d0,[x6,x4,lsl #3]
 ldr d1,[x6,x8,lsl #3]
 fmul d0,d0,d1
 ldr d1,[x5,x4,lsl #3]
 fadd d0,d0,d1
 str d0,[x6,x4,lsl #3]
 subs x4,x4,#1
 b.ge .Lspline_backward
 add sp,sp,#832
 mov w0,#0
 ret
.size md2asm_initialize_stability_table_fields,.-md2asm_initialize_stability_table_fields
.section .rodata
.p2align 3
.Lthermal_literals:
 .double 611.21,17.502,22.587,32.19,-0.7,1000.0,5.0,23.0,2.583,0.0048116
.Literation_constants:
 .double 0.001
.Lstable_constants:
 .quad 0x3ff0000000000000
 .quad 0x3fe5555555555555
 .quad 0x4014000000000000
 .quad 0x3fd6666666666666
 .quad 0x3fe5555555555555
 .quad 0x40230c30c30c30c3
 .quad 0x402c924924924925
 .quad 0x4014000000000000
 .quad 0x4010000000000000
 .quad 0x4014000000000000
 .quad 0x4030000000000000
 .quad 0x3ff921fb54442d18
 .quad 0x4024000000000000
 .quad 0x3fb999999999999a
 .quad 0x3f5b4e81b4e81b50
.Linput_ranges:
 .quad 184,0x3ff0000000000000,0x40c3880000000000
 .quad 192,0x3ff0000000000000,0x40c3880000000000
 .quad 200,0x3ff0000000000000,0x40c3880000000000
 .quad 368,0x4069000000000000,0x4075e00000000000
 .quad 376,0x3ff0000000000000,0x4197d78400000000
 .quad 384,0x3ff0000000000000,0x4197d78400000000
 .quad 408,0x3ff0000000000000,0x4197d78400000000
.section .note.GNU-stack,"",%progbits
