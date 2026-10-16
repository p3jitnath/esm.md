// SUINTDYNSL and its four integer index builders from INTDYNSL_MOD.
// x0 is the live MODEL address. x1 is its byte capacity. Return 0 or refusal 2.
// The caller supplies completed SUGFL3 and SUDYN controls. No FP instruction is used.
.arch armv8.2-a+simd
.text
.p2align 4
.macro ADDRESS dst,base,off
 movz \dst,#(\off & 65535)
 movk \dst,#((\off >> 16) & 65535),lsl#16
 add \dst,\base,\dst
.endm
.macro READ_FLAG dst,off
 ADDRESS x16,x19,\off
 ldr \dst,[x16]
 cmp \dst,#1
 b.hi .Lrefuse
.endm
.global md2asm_initialize_internal_interpolation_indices
.type md2asm_initialize_internal_interpolation_indices,%function
md2asm_initialize_internal_interpolation_indices:
 cbz x0,.Lbad_direct
 tst x0,#7
 b.ne .Lbad_direct
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lbad_direct
 adds x9,x0,x9
 b.cs .Lbad_direct
 sub sp,sp,#96
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 mov x19,x0
 READ_FLAG w9,1564160
 cbz w9,.Lrefuse
 ADDRESS x16,x19,1568804
 ldr w20,[x16]
 sub w9,w20,#1
 cmp w9,#3
 b.hi .Lrefuse
 READ_FLAG w25,1566088
 READ_FLAG w26,1568972
 READ_FLAG w22,1564364
 READ_FLAG w23,1564464
 READ_FLAG w9,1564368
 orr w23,w23,w9
 and w26,w26,w9
 READ_FLAG w24,1564288
 ldr w13,[x19,#192]
 cmp w13,#2163
 b.hi .Lrefuse
 mov w21,wzr
 cbz w13,.Lfields_scanned
 ADDRESS x12,x19,4196
.Lnext_field:
 adrp x14,.Lhermite_names
 add x14,x14,:lo12:.Lhermite_names
 mov w15,#3
.Lnext_name:
 mov w8,wzr
.Lcompare_name:
 ldrb w9,[x12,x8]
 ldrb w10,[x14,x8]
 cmp w9,w10
 b.ne .Ldifferent_name
 add w8,w8,#1
 cmp w8,#12
 b.lo .Lcompare_name
 mov w21,#1
 b .Lfields_scanned
.Ldifferent_name:
 add x14,x14,#12
 subs w15,w15,#1
 b.ne .Lnext_name
 add x12,x12,#368
 subs w13,w13,#1
 b.ne .Lnext_field
.Lfields_scanned:
 ADDRESS x0,x19,1570584
 bl .Llinear
 ADDRESS x0,x19,1570612
 bl .Llinear
 ADDRESS x0,x19,1570640
 mov w1,w20
 mov w2,w22
 mov w3,w21
 mov w4,w23
 mov w5,w24
 mov w6,w25
 mov w7,w26
 bl .Lnonlinear
 ADDRESS x0,x19,1570784
 mov w1,w20
 mov w2,wzr
 mov w3,wzr
 mov w4,w23
 mov w5,w24
 mov w6,w25
 mov w7,w26
 bl .Lnonlinear
 ADDRESS x0,x19,1570928
 bl .Lcoordinates
 ADDRESS x0,x19,1570948
 bl .Lcoordinates
 mov w0,wzr
 b .Lreturn
.Lrefuse:
 mov w0,#2
.Lreturn:
 ldp x18,x30,[sp]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 add sp,sp,#96
 ret
.Lbad_direct:
 mov w0,#2
 ret
.size md2asm_initialize_internal_interpolation_indices,.-md2asm_initialize_internal_interpolation_indices

.Llinear:
 mov w8,#1
 str w8,[x0]
 mov w8,#5
 str w8,[x0,#4]
 mov w8,#6
 str w8,[x0,#8]
 mov w8,#7
 str w8,[x0,#12]
 mov w8,#11
 str w8,[x0,#16]
 mov w8,#12
 str w8,[x0,#20]
 str w8,[x0,#24]
 ret
.Lcoordinates:
 mov w8,#1
 str w8,[x0]
 mov w8,#2
 str w8,[x0,#4]
 mov w8,#3
 str w8,[x0,#8]
 mov w8,#4
 str w8,[x0,#12]
 str w8,[x0,#16]
 ret

// This leaf follows SUPTR_TRSCAW in source order. Arrays above NSLDIMK retain input bytes.
.macro SEQUENCE off,increment
 add x10,x0,#\off
 mov w9,w1
.Lsequence_\@:
 str w8,[x10],#4
 add w8,w8,#\increment
 subs w9,w9,#1
 b.ne .Lsequence_\@
.endm
.Lnonlinear:
 mov w8,#1
 SEQUENCE 0,6
 SEQUENCE 16,3
 str w8,[x0,#32]
 add w8,w8,#3
 cbz w4,.Lbase_weights_done
 add w8,w8,#6
.Lbase_weights_done:
 cbz w5,.Lno_vertical_filter
 str w8,[x0,#84]
 add w8,w8,#3
 cbz w7,.Lvertical_filter_done
 add w8,w8,#6
 b .Lvertical_filter_done
.Lno_vertical_filter:
 ldr w9,[x0,#32]
 str w9,[x0,#84]
.Lvertical_filter_done:
 SEQUENCE 36,6
 cbz w6,.Lshared_longitude
 str w8,[x0,#68]
 add w8,w8,#6
 b .Llongitude_done
.Lshared_longitude:
 ldr w9,[x0,#36]
 str w9,[x0,#68]
.Llongitude_done:
 SEQUENCE 52,3
 cbz w6,.Lshared_latitude
 str w8,[x0,#72]
 add w8,w8,#3
 b .Llatitude_done
.Lshared_latitude:
 ldr w9,[x0,#52]
 str w9,[x0,#72]
.Llatitude_done:
 str w8,[x0,#76]
 add w8,w8,#3
 cbz w6,.Lshared_vertical
 str w8,[x0,#80]
 add w8,w8,#3
 b .Lvertical_done
.Lshared_vertical:
 ldr w9,[x0,#76]
 str w9,[x0,#80]
.Lvertical_done:
 SEQUENCE 88,6
 SEQUENCE 104,3
 str w8,[x0,#120]
 add w8,w8,#3
 cbz w2,.Lno_spline
 str w8,[x0,#124]
 add w8,w8,#4
 b .Lspline_done
.Lno_spline:
 mov w9,#1
 str w9,[x0,#124]
.Lspline_done:
 cbz w3,.Lno_hermite_derivative
 str w8,[x0,#128]
 add w8,w8,#4
 b .Lhermite_derivative_done
.Lno_hermite_derivative:
 mov w9,#1
 str w9,[x0,#128]
.Lhermite_derivative_done:
 cbz w3,.Lno_hermite_weights
 str w8,[x0,#132]
 add w8,w8,#4
 b .Lhermite_weights_done
.Lno_hermite_weights:
 mov w9,#1
 str w9,[x0,#132]
.Lhermite_weights_done:
 cbz w4,.Lno_weno
 str w8,[x0,#136]
 add w8,w8,#3
 b .Lweno_done
.Lno_weno:
 mov w9,#1
 str w9,[x0,#136]
.Lweno_done:
 sub w8,w8,#1
 str w8,[x0,#140]
 ret
.section .rodata
.Lhermite_names:
.ascii "LAIHVT      LAIHVTQM    LAIHVTQMH   "
.section .note.GNU-stack,"",%progbits
