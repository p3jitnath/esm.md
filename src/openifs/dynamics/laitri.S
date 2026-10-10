/* Complete LAITRI interpolation for flags 0, 1, 2 and 3.
 * The separate flag -1 conservation correction is outside this body.
 * All eighteen arguments are pointers. Rows vary fastest, real values
 * use FP64, and field units are unchanged. The first eight pointers name
 * 32-bit integers. The stack then has ten array or optional pointers.
 * Inputs are read-only, and only selected output cells are written.
 * The caller sets FPCR to zero. No numerical helper or frame is used.
 */
.text
.p2align 2

/* Load one signed base and form the declared source address. */
.macro SOURCE_ADDRESS side, level
 .if \side == 0
  ldrsw x16, [x4]
 .elseif \side == 1
  add x17, x4, x14, lsr #1
  ldrsw x16, [x17]
 .elseif \side == 2
  add x17, x4, x14
  ldrsw x16, [x17]
 .else
  add x17, x4, x14
  add x17, x17, x14, lsr #1
  ldrsw x16, [x17]
 .endif
 add x16, x6, x16, lsl #3
 .if \level == 1
  add x16, x16, x8
 .elseif \level == 2
  add x16, x16, x8, lsl #1
 .elseif \level == 3
  add x16, x16, x8, lsl #1
  add x16, x16, x8
 .endif
.endm

/* One ordered longitude estimate, with its optional central clip. */
.macro LONGITUDE result, side, level, wide
 SOURCE_ADDRESS \side, \level
 .if \wide
  sub x16, x16, #8
  ldp d0, d1, [x16]
  ldp d2, d3, [x16, #16]
  .if \side == 1
   mov x17, x3
  .else
   add x17, x3, x14, lsl #1
   add x17, x17, x14
  .endif
  ldr d4, [x17]
  fsub d5, d1, d0
  fmul d5, d4, d5
  fadd \result, d0, d5
  add x17, x17, x14
  ldr d4, [x17]
  fsub d5, d2, d0
  fmul d5, d4, d5
  fadd \result, \result, d5
  add x17, x17, x14
  ldr d4, [x17]
  fsub d5, d3, d0
  fmul d5, d4, d5
  fadd \result, \result, d5
  cbz w10, .Llongitude_unclipped\@
  fmin d6, d1, d2
  fmax d7, d1, d2
  fmin \result, d7, \result
  fmax \result, d6, \result
.Llongitude_unclipped\@:
 .else
  ldp d0, d1, [x16]
  .if \side == 0
   mov x17, x2
  .elseif \side == 1
   add x17, x2, x14
  .elseif \side == 2
   add x17, x2, x14, lsl #1
  .else
   add x17, x2, x14, lsl #1
   add x17, x17, x14
  .endif
  ldr d2, [x17]
  fsub d3, d1, d0
  fmul d3, d2, d3
  fadd \result, d0, d3
 .endif
.endm

/* A four-sample estimate keeps its base and three separate partial sums. */
.macro CUBIC result, base, second, third, fourth
 fsub d0, \second, \base
 fmul d0, d29, d0
 fadd \result, \base, d0
 fsub d0, \third, \base
 fmul d0, d30, d0
 fadd \result, \result, d0
 fsub d0, \fourth, \base
 fmul d0, d31, d0
 fadd \result, \result, d0
.endm

.global laitri_assembly_
.type laitri_assembly_, %function
laitri_assembly_:
 ldr w13, [x7]
 cmp w13, #3
 b.hi .Lreturn
 ldr w8, [x0]
 ldr w9, [x1]
 ldr w12, [x4]
 ldr w15, [x2]
 ldr w11, [x3]
 sub w15, w15, #1
 subs w11, w11, w15
 b.le .Lreturn
 cbz w12, .Lreturn
 mul x14, x9, x12
 lsl x14, x14, #3
 sub x9, x9, x11
 lsl x9, x9, #3
 lsl x8, x8, #3
 sub w10, w13, #1
 cmp w10, #1
 cset w10, ls
 lsr w13, w13, #1
 lsl x15, x15, #3
 ldp x0, x1, [sp]
 ldp x2, x3, [sp, #16]
 ldp x4, x5, [sp, #32]
 ldp x6, x7, [sp, #48]
 add x0, x0, x15
 add x1, x1, x15
 add x2, x2, x15
 add x3, x3, x15
 add x4, x4, x15, lsr #1
 add x5, x5, x15
 add x7, x7, x15
.Llevel:
 mov x15, x11
.Lpoint:
 LONGITUDE d16, 1, 0, 0
 LONGITUDE d17, 2, 0, 0
 LONGITUDE d18, 0, 1, 0
 LONGITUDE d19, 1, 1, 1
 LONGITUDE d20, 2, 1, 1
 LONGITUDE d21, 3, 1, 0
 LONGITUDE d22, 0, 2, 0
 LONGITUDE d23, 1, 2, 1
 LONGITUDE d24, 2, 2, 1
 LONGITUDE d25, 3, 2, 0
 LONGITUDE d26, 1, 3, 0
 LONGITUDE d27, 2, 3, 0

 /* Latitude coefficients are shared by the two middle local levels. */
 ldr d28, [x0]
 ldr d29, [x1]
 add x17, x1, x14
 ldr d30, [x17]
 add x17, x17, x14
 ldr d31, [x17]
 fsub d0, d17, d16
 fmul d0, d28, d0
 fadd d16, d16, d0
 CUBIC d17, d18, d19, d20, d21
 cbz w10, .Llatitude_one_unclipped
 fmin d1, d19, d20
 fmax d2, d19, d20
 fmin d17, d2, d17
 fmax d17, d1, d17
.Llatitude_one_unclipped:
 CUBIC d18, d22, d23, d24, d25
 cbz w10, .Llatitude_two_unclipped
 fmin d1, d23, d24
 fmax d2, d23, d24
 fmin d18, d2, d18
 fmax d18, d1, d18
.Llatitude_two_unclipped:
 fsub d0, d27, d26
 fmul d0, d28, d0
 fadd d19, d26, d0

 /* The final vertical estimate owns its optional clip and output write. */
 ldr d29, [x5]
 add x17, x5, x14
 ldr d30, [x17]
 add x17, x17, x14
 ldr d31, [x17]
 CUBIC d20, d16, d17, d18, d19
 cbz w13, .Lvertical_unclipped
 fmin d1, d17, d18
 fmax d2, d17, d18
 fmin d20, d2, d20
 fmax d20, d1, d20
.Lvertical_unclipped:
 str d20, [x7], #8
 add x0, x0, #8
 add x1, x1, #8
 add x2, x2, #8
 add x3, x3, #8
 add x4, x4, #4
 add x5, x5, #8
 subs x15, x15, #1
 b.ne .Lpoint
 add x0, x0, x9
 add x1, x1, x9
 add x2, x2, x9
 add x3, x3, x9
 add x4, x4, x9, lsr #1
 add x5, x5, x9
 add x7, x7, x9
 subs x12, x12, #1
 b.ne .Llevel
.Lreturn:
 ret
.size laitri_assembly_, .-laitri_assembly_

#ifdef LAITRI_ABI_PROBE
/* Forward all eighteen ordinary pointers, preserving the visible ABI state. */
.global laitri_abi_invoke
.type laitri_abi_invoke, %function
laitri_abi_invoke:
 sub sp, sp, #96
 str x30, [sp, #80]
 mov x9, x0
 ldp x10, x11, [x9, #64]
 stp x10, x11, [sp]
 ldp x10, x11, [x9, #80]
 stp x10, x11, [sp, #16]
 ldp x10, x11, [x9, #96]
 stp x10, x11, [sp, #32]
 ldp x10, x11, [x9, #112]
 stp x10, x11, [sp, #48]
 ldp x10, x11, [x9, #128]
 stp x10, x11, [sp, #64]
 ldp x0, x1, [x9]
 ldp x2, x3, [x9, #16]
 ldp x4, x5, [x9, #32]
 ldp x6, x7, [x9, #48]
 bl laitri_assembly_
 ldr x30, [sp, #80]
 add sp, sp, #96
 ret
.size laitri_abi_invoke, .-laitri_abi_invoke
#endif
.section .note.GNU-stack,"",%progbits
