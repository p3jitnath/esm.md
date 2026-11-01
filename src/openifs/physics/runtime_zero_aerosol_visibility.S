// Original RADVIS_LAYER zero-aerosol route. Visibility is measured in metres.
// Contract: skills/md2asm/references/openifs/physics/runtime_zero_aerosol_visibility.md.
// Copy the climatological visibility, in metres, without floating-point arithmetic.
// Raw ABI: w0=P, w1=first, w2=last, x3=source[1:P], x4=destination[1:P].
// All nonempty arrays contain P aligned FP64 words. Equal arrays are permitted;
// partial overlap is refused before a store. Status is 0 or prewrite refusal 2.
.text
.p2align 2
.global md2asm_copy_climatological_visibility
.type md2asm_copy_climatological_visibility,%function
md2asm_copy_climatological_visibility:
 cmp w0,#1
 b.lt .Lcopy_bad
 cmp w0,#128
 b.gt .Lcopy_bad
 cmp w1,#1
 b.lt .Lcopy_bad
 add w5,w0,#1
 cmp w1,w5
 b.gt .Lcopy_bad
 cmp w2,#0
 b.lt .Lcopy_bad
 cmp w2,w0
 b.gt .Lcopy_bad
 cmp w1,w2
 b.gt .Lcopy_ok
 cbz x3,.Lcopy_bad
 cbz x4,.Lcopy_bad
 orr x5,x3,x4
 tst x5,#7
 b.ne .Lcopy_bad
 uxtw x5,w0
 lsl x5,x5,#3
 adds x6,x3,x5
 b.cs .Lcopy_bad
 adds x7,x4,x5
 b.cs .Lcopy_bad
 cmp x3,x4
 b.eq .Lcopy_ok
 cmp x6,x4
 b.ls .Lcopy_begin
 cmp x7,x3
 b.hi .Lcopy_bad
.Lcopy_begin:
 sub w1,w1,#1
 uxtw x1,w1
 uxtw x2,w2
.Lcopy_loop:
 ldr x5,[x3,x1,lsl#3]
 str x5,[x4,x1,lsl#3]
 add x1,x1,#1
 cmp x1,x2
 b.lo .Lcopy_loop
.Lcopy_ok:
 mov w0,#0
 ret
.Lcopy_bad:
 mov w0,#2
 ret
.size md2asm_copy_climatological_visibility,.-md2asm_copy_climatological_visibility

// Typed ABI: x0 DIM192, x1 GEMS4680, x2 AUX_DIAG4104, w3 NACTAERO,
// x4 context16=[unused physical pointer, false-hook-policy16 pointer].
// A false-hook policy contains [int32-false pointer, reserved zero]. The physical
// pointer is never read. Only the zero-aerosol source route is admitted.
// Consumed GNU descriptors have rank1 FP64, bounds1:P and unit stride.
.global md2asm_update_runtime_zero_aerosol_visibility
.type md2asm_update_runtime_zero_aerosol_visibility,%function
md2asm_update_runtime_zero_aerosol_visibility:
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x4
 cbnz w3,.Ltyped_bad
 cbz x19,.Ltyped_bad
 tst x19,#7
 b.ne .Ltyped_bad
 adds x5,x19,#192
 b.cs .Ltyped_bad
 cbz x22,.Ltyped_bad
 tst x22,#7
 b.ne .Ltyped_bad
 adds x5,x22,#16
 b.cs .Ltyped_bad
 ldr x6,[x22,#8]
 cbz x6,.Ltyped_bad
 tst x6,#7
 b.ne .Ltyped_bad
 adds x5,x6,#16
 b.cs .Ltyped_bad
 ldr x7,[x6,#8]
 cbnz x7,.Ltyped_bad
 ldr x7,[x6]
 cbz x7,.Ltyped_bad
 tst x7,#3
 b.ne .Ltyped_bad
 adds x5,x7,#4
 b.cs .Ltyped_bad
 ldr w5,[x7]
 cbnz w5,.Ltyped_bad
 stp x6,x7,[sp,#80]
 ldr w0,[x19,#12]
 ldr w1,[x19]
 ldr w2,[x19,#4]
 cmp w0,#1
 b.lt .Ltyped_bad
 cmp w0,#128
 b.gt .Ltyped_bad
 cmp w1,#1
 b.lt .Ltyped_bad
 add w5,w0,#1
 cmp w1,w5
 b.gt .Ltyped_bad
 cmp w2,#0
 b.lt .Ltyped_bad
 cmp w2,w0
 b.gt .Ltyped_bad
 cmp w1,w2
 b.gt .Ltyped_ok
 stp w0,w1,[sp,#64]
 str w2,[sp,#72]
 cbz x20,.Ltyped_bad
 cbz x21,.Ltyped_bad
 orr x5,x20,x21
 tst x5,#7
 b.ne .Ltyped_bad
 mov x5,#4680
 adds x5,x20,x5
 b.cs .Ltyped_bad
 mov x5,#4104
 adds x5,x21,x5
 b.cs .Ltyped_bad
 add x6,x20,#4096
 add x6,x6,#408
 bl .Lvisibility_descriptor
 cbnz w0,.Ltyped_bad
 mov x23,x7
 add x6,x21,#600
 bl .Lvisibility_descriptor
 cbnz w0,.Ltyped_bad
 mov x24,x7
 ldr w5,[sp,#64]
 uxtw x5,w5
 lsl x5,x5,#3
 adds x12,x24,x5
 b.cs .Ltyped_bad
 mov x6,x19
 mov x7,#192
 bl .Ldestination_disjoint
 cbnz w0,.Ltyped_bad
 mov x6,x20
 mov x7,#4680
 bl .Ldestination_disjoint
 cbnz w0,.Ltyped_bad
 mov x6,x21
 mov x7,#4104
 bl .Ldestination_disjoint
 cbnz w0,.Ltyped_bad
 mov x6,x22
 mov x7,#16
 bl .Ldestination_disjoint
 cbnz w0,.Ltyped_bad
 ldr x6,[sp,#80]
 mov x7,#16
 bl .Ldestination_disjoint
 cbnz w0,.Ltyped_bad
 ldr x6,[sp,#88]
 mov x7,#4
 bl .Ldestination_disjoint
 cbnz w0,.Ltyped_bad
 ldp w0,w1,[sp,#64]
 ldr w2,[sp,#72]
 mov x3,x23
 mov x4,x24
 bl md2asm_copy_climatological_visibility
 b .Ltyped_return
.Ltyped_ok:
 mov w0,#0
 b .Ltyped_return
.Ltyped_bad:
 mov w0,#2
.Ltyped_return:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
// Descriptor validation reads only its64-byte published header. It returns the
// logical element1 pointer in x7 and status in w0; x6 names the descriptor.
.Lvisibility_descriptor:
 ldr x7,[x6]
 cbz x7,.Ldescriptor_bad
 tst x7,#7
 b.ne .Ldescriptor_bad
 ldr x5,[x6,#8]
 cmn x5,#1
 b.ne .Ldescriptor_bad
 ldr x5,[x6,#16]
 cmp x5,#8
 b.ne .Ldescriptor_bad
 ldrb w5,[x6,#28]
 cmp w5,#1
 b.ne .Ldescriptor_bad
 ldrb w5,[x6,#29]
 cmp w5,#3
 b.ne .Ldescriptor_bad
 ldr x5,[x6,#32]
 cmp x5,#8
 b.ne .Ldescriptor_bad
 ldr x5,[x6,#40]
 cmp x5,#1
 b.ne .Ldescriptor_bad
 ldr x5,[x6,#48]
 cmp x5,#1
 b.ne .Ldescriptor_bad
 ldr x5,[x6,#56]
 ldr w8,[sp,#64]
 cmp x5,x8
 b.ne .Ldescriptor_bad
 lsl x8,x8,#3
 adds x8,x7,x8
 b.cs .Ldescriptor_bad
 mov w0,#0
 ret
.Ldescriptor_bad:
 mov w0,#2
 ret
// Refuse an output span that touches one still-live metadata record.
.Ldestination_disjoint:
 add x7,x6,x7
 cmp x12,x6
 b.ls .Ldisjoint_ok
 cmp x7,x24
 b.hi .Ldisjoint_bad
.Ldisjoint_ok:
 mov w0,#0
 ret
.Ldisjoint_bad:
 mov w0,#2
 ret
.size md2asm_update_runtime_zero_aerosol_visibility,.-md2asm_update_runtime_zero_aerosol_visibility
.section .note.GNU-stack,"",%progbits
