/* Contract: skills/md2asm/references/openifs/input/spectral_initial_state_loading.md. */
/* Owned selected initial spectral caller.
 * x0=path,x1=Geometry17096,x2=configuration1556112,x3=spectral2992,x4=logical*.
 * Only explicit owned records, direct assembly children and libc/ecCodes services.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_load_spectral_initial_state
.type md2asm_load_spectral_initial_state,%function
md2asm_load_spectral_initial_state:
 sub sp,sp,#352
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x10,fpsr
 str x10,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x26,xzr
 mov x28,xzr
 mov w27,#1
 cbnz x9,.Lcaller_return
 cbz x19,.Lcaller_return
 cbz x20,.Lcaller_return
 cbz x21,.Lcaller_return
 cbz x22,.Lcaller_return
 cbz x23,.Lcaller_return
 orr x9,x20,x21
 orr x9,x9,x22
 tst x9,#7
 b.ne .Lcaller_return
 tst x23,#3
 b.ne .Lcaller_return
 ldr x9,.Lgeometry_bytes
 adds x10,x20,x9
 b.cs .Lcaller_return
 stp x20,x10,[sp,#160]
 ldr x9,.Lconfiguration_bytes
 adds x10,x21,x9
 b.cs .Lcaller_return
 stp x21,x10,[sp,#176]
 mov x9,#2992
 adds x10,x22,x9
 b.cs .Lcaller_return
 stp x22,x10,[sp,#192]
 mov x10,#0
.Lcaller_path:
 ldrb w9,[x19,x10]
 add x10,x10,#1
 cbz w9,.Lcaller_path_end
 cmp x10,#4096
 b.lo .Lcaller_path
 b .Lcaller_return
.Lcaller_path_end:
 adds x11,x19,x10
 b.cs .Lcaller_return
 stp x19,x11,[sp,#208]
 adds x10,x23,#4
 b.cs .Lcaller_return
 stp x23,x10,[sp,#240]
 mov w27,#2
 ldr w9,[x20,#5168]
 cmp w9,#1
 b.ne .Lcaller_return
 ldr w9,[x20,#5200]
 cmp w9,#506
 b.ne .Lcaller_return
 ldr w9,[x20,#7208]
 cmp w9,#1
 b.ne .Lcaller_return
 ldr w9,[x20,#5224]
 cmp w9,#19
 b.ne .Lcaller_return
 ldr w9,[x20,#5228]
 cmp w9,#19
 b.ne .Lcaller_return
 ldr w9,[x21,#8]
 cmp w9,#1
 b.ne .Lcaller_return
 ldr w9,[x21,#24]
 cmp w9,#3
 b.ne .Lcaller_return
 ldr w9,[x21,#28]
 cmp w9,#2
 b.ne .Lcaller_return
 ldr w9,[x21,#192]
 cbnz w9,.Lcaller_return
 ldr w12,[x21,#184]
 cmp w12,#2163
 b.hi .Lcaller_return
 add x13,x21,#4032
.Lcaller_field:
 cbz w12,.Lcaller_codes
 ldr w9,[x13,#56]
 cbnz w9,.Lcaller_return
 ldr w9,[x13,#52]
 cbz w9,.Lcaller_field_next
 ldr w9,[x13,#36]
 cmp w9,#1
 b.ne .Lcaller_field_next
 ldr w9,[x13,#44]
 cbnz w9,.Lcaller_field_next
 ldr w9,[x13,#108]
 cbz w9,.Lcaller_return
.Lcaller_field_next:
 add x13,x13,#368
 sub w12,w12,#1
 b .Lcaller_field
.Lcaller_codes:
 add x13,x21,#40
 ldr x12,[x13]
 cbz x12,.Lcaller_return
 tst x12,#3
 b.ne .Lcaller_return
 ldr x9,[x13,#8]
 cmn x9,#1
 b.ne .Lcaller_return
 ldr x9,[x13,#16]
 cmp x9,#4
 b.ne .Lcaller_return
 ldr w9,[x13,#24]
 cbnz w9,.Lcaller_return
 ldrb w9,[x13,#28]
 cmp w9,#1
 b.ne .Lcaller_return
 ldrb w9,[x13,#29]
 cmp w9,#1
 b.ne .Lcaller_return
 ldr x9,[x13,#32]
 cmp x9,#4
 b.ne .Lcaller_return
 ldr x9,[x13,#40]
 cmp x9,#1
 b.ne .Lcaller_return
 ldr x9,[x13,#48]
 cmp x9,#1
 b.ne .Lcaller_return
 ldr x9,[x13,#56]
 cmp x9,#3
 b.ne .Lcaller_return
 adds x10,x12,#12
 b.cs .Lcaller_bad_argument
 stp x12,x10,[sp,#224]
 ldr w9,[x12]
 cmp w9,#138
 b.ne .Lcaller_return
 ldr w9,[x12,#4]
 cmp w9,#155
 b.ne .Lcaller_return
 ldr w9,[x12,#8]
 cmp w9,#130
 b.ne .Lcaller_return
 add x0,x22,#88
 adr x1,.Lthree_layout
 mov w2,#3
 bl .Lvalidate_spectral_descriptor
 cbz x0,.Lcaller_scope_failure
 mov x24,x0
 mov x0,x22
 adr x1,.Ltwo_layout
 mov w2,#2
 bl .Lvalidate_spectral_descriptor
 cbz x0,.Lcaller_scope_failure
 mov x25,x0
 mov w27,#1
 ldr x9,.Lthree_bytes
 adds x10,x24,x9
 b.cs .Lcaller_return
 stp x24,x10,[sp,#256]
 ldr x9,.Ltwo_bytes
 adds x10,x25,x9
 b.cs .Lcaller_return
 stp x25,x10,[sp,#272]
 mov x11,#5
.Lcaller_overlap_outer:
 add x9,sp,#160
 add x9,x9,x11,lsl#4
 ldp x12,x13,[x9]
 mov x14,#0
.Lcaller_overlap_inner:
 add x9,sp,#160
 add x9,x9,x14,lsl#4
 ldp x15,x16,[x9]
 cmp x12,x16
 b.hs .Lcaller_disjoint
 cmp x15,x13
 b.lo .Lcaller_return
.Lcaller_disjoint:
 add x14,x14,#1
 cmp x14,x11
 b.lo .Lcaller_overlap_inner
 add x11,x11,#1
 cmp x11,#8
 b.lo .Lcaller_overlap_outer
 bl __errno_location
 mov x28,x0
 ldr w9,[x28]
 str w9,[sp,#120]
 ldr x0,.Lscratch_bytes
 bl malloc
 mov x26,x0
 mov w27,#3
 cbz x26,.Lcaller_return
 mov x0,x19
 mov x1,x26
 ldr x2,.Lvalues_bytes
 add x3,x26,x2
 mov x4,#1872
 add x5,sp,#128
 bl md2asm_read_initial_spectral_fields
 add w27,w0,#10
 cbnz w0,.Lcaller_cleanup
 mov x0,x26
 ldr x1,.Lvalues_bytes
 add x2,x26,x1
 mov x3,#1872
 mov x4,x24
 ldr x5,.Lthree_bytes
 mov x6,x25
 ldr x7,.Ltwo_bytes
 bl md2asm_place_initial_spectral_fields
 add w27,w0,#20
 cbnz w0,.Lcaller_cleanup
 mov w9,#1
 str w9,[x23]
 mov w27,#0
.Lcaller_cleanup:
 mov x0,x26
 bl free
.Lcaller_return:
 cbz x28,.Lcaller_restore_fp
 ldr w9,[sp,#120]
 str w9,[x28]
.Lcaller_restore_fp:
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 mov w0,w27
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#352
 ret
.Lcaller_bad_argument:
 mov w27,#1
 b .Lcaller_return
.Lcaller_scope_failure:
 mov w27,#2
 b .Lcaller_return
.size md2asm_load_spectral_initial_state,.-md2asm_load_spectral_initial_state

/* Private integer validator. x0=descriptor,x1=layout,w2=rank. Return base or0.
 * x0..x17 and condition flags scratch; no stack, memory writes or library call.
 */
.type .Lvalidate_spectral_descriptor,%function
.Lvalidate_spectral_descriptor:
 ldr x3,[x0]
 cbz x3,.Ldescriptor_reject
 tst x3,#7
 b.ne .Ldescriptor_reject
 ldr x4,[x0,#8]
 ldr x5,[x1],#8
 cmp x4,x5
 b.ne .Ldescriptor_reject
 ldr x4,[x0,#16]
 cmp x4,#8
 b.ne .Ldescriptor_reject
 ldr w4,[x0,#24]
 cbnz w4,.Ldescriptor_reject
 ldrb w4,[x0,#28]
 cmp w4,w2
 b.ne .Ldescriptor_reject
 ldrb w4,[x0,#29]
 cmp w4,#3
 b.ne .Ldescriptor_reject
 ldr x4,[x0,#32]
 cmp x4,#8
 b.ne .Ldescriptor_reject
 add x0,x0,#40
.Ldescriptor_dimension:
 ldp x4,x5,[x0],#16
 ldp x6,x7,[x1],#16
 cmp x4,x6
 b.ne .Ldescriptor_reject
 cmp x5,x7
 b.ne .Ldescriptor_reject
 ldr x4,[x0],#8
 ldr x5,[x1],#8
 cmp x4,x5
 b.ne .Ldescriptor_reject
 subs w2,w2,#1
 b.ne .Ldescriptor_dimension
 mov x0,x3
 ret
.Ldescriptor_reject:
 mov x0,xzr
 ret
.size .Lvalidate_spectral_descriptor,.-.Lvalidate_spectral_descriptor
.p2align 3
.Lgeometry_bytes: .quad 17096
.Lconfiguration_bytes: .quad 1556112
.Lthree_bytes: .quad 230736
.Ltwo_bytes: .quad 8096
.Lvalues_bytes: .quad 315744
.Lscratch_bytes: .quad 317616
.Ltwo_layout: .quad -507,1,1,506,506,1,2
.Lthree_layout: .quad -9634,1,1,19,19,1,506,9614,1,3
.section .note.GNU-stack,"",%progbits
