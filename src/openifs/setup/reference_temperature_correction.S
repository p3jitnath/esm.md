/* Original selected SUDYN controls, SUALDYN owners and SURCORDI stage.
 * Contract skills/md2asm/references/openifs/dynamics/reference_temperature_correction.md.
 * Complete Geometry and MODEL records remain owned by the caller. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.macro POSITIVE reg,bad
 fmov x10,\reg
 tbnz x10,#63,\bad
 lsl x11,x10,#1
 cbz x11,\bad
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq \bad
.endm
/* Leaf validation retains x0 through x8 and x16. */
.Lvalidate:
 mov w9,#2
 cbz x0,.Lvalidated
 cbz x2,.Lvalidated
 orr x10,x0,x2
 tst x10,#7
 b.ne .Lvalidated
 mov x10,#17096
 cmp x1,x10
 b.lo .Lvalidated
 adds x11,x0,x10
 b.cs .Lvalidated
 mov x10,#(4275088 & 65535)
 movk x10,#(4275088 >> 16),lsl#16
 cmp x3,x10
 b.lo .Lvalidated
 adds x12,x2,x10
 b.cs .Lvalidated
 cmp x11,x2
 b.ls .Lrecords_disjoint
 cmp x12,x0
 b.hi .Lvalidated
.Lrecords_disjoint:
 mrs x10,fpcr
 cbnz x10,.Lvalidated
 mov x10,#5224
 ldr w10,[x0,x10]
 sub w10,w10,#1
 cmp w10,#254
 b.hi .Lvalidated
 mov w9,#0
.Lvalidated:
 ret

.p2align 4
.global md2asm_initialize_temperature_correction_controls
.type md2asm_initialize_temperature_correction_controls,%function
md2asm_initialize_temperature_correction_controls:
 cbz x0,.Lbad
 tst x0,#7
 b.ne .Lbad
 mov x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 cbz x2,.Lbad
 tst x2,#3
 b.ne .Lbad
 ldp w9,w10,[x2]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x2,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 mrs x9,fpcr
 cbnz x9,.Lbad
 MADDR x9,x0,1564136
 ldr w10,[x9,#20]
 cmp w10,#1
 b.ne .Lbad
 fmov d0,#1.0
 fdiv d1,d0,d0
 MADDR x9,x0,1569104
 str d0,[x9]
 str d1,[x9,#8]
 MADDR x9,x0,1569048
 str d0,[x9]
 mov w0,#0
 ret
.size md2asm_initialize_temperature_correction_controls,.-md2asm_initialize_temperature_correction_controls
.p2align 4
.global md2asm_allocate_reference_temperature_correction
.type md2asm_allocate_reference_temperature_correction,%function
md2asm_allocate_reference_temperature_correction:
 mov x16,x30
 bl .Lvalidate
 mov x30,x16
 cbnz w9,.Lbad
 MADDR x9,x2,1566736
 mov x10,#3
.Lnull_owners:
 ldr x11,[x9],#64
 cbnz x11,.Lbad
 subs x10,x10,#1
 b.ne .Lnull_owners
 sub sp,sp,#112
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x2
 mov x9,#5224
 ldr w20,[x0,x9]
 add x21,sp,#80
 mov x22,#0
.Lallocate_owner:
 mov x0,x20
 cmp x22,#1
 cinc x0,x0,eq
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lrollback
 str x0,[x21,x22,lsl#3]
 add x22,x22,#1
 cmp x22,#3
 b.lo .Lallocate_owner
 MADDR x23,x19,1566736
 mov x22,#0
.Lpublish_owner:
 ldr x9,[x21,x22,lsl#3]
 str x9,[x23]
 mov x9,#1
 cmp x22,#1
 csel x9,xzr,x9,eq
 neg x10,x9
 str x10,[x23,#8]
 mov x10,#8
 str x10,[x23,#16]
 str wzr,[x23,#24]
 mov w10,#0x301
 strh w10,[x23,#28]
 strh wzr,[x23,#30]
 mov x10,#8
 str x10,[x23,#32]
 mov x10,#1
 stp x10,x9,[x23,#40]
 str x20,[x23,#56]
 add x23,x23,#64
 add x22,x22,#1
 cmp x22,#3
 b.lo .Lpublish_owner
 mov w0,#0
 b .Lallocate_done
.Lrollback:
 cbz x22,.Lallocation_failed
 sub x22,x22,#1
 ldr x0,[x21,x22,lsl#3]
 bl free
 b .Lrollback
.Lallocation_failed:
 mov w0,#1
.Lallocate_done:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_allocate_reference_temperature_correction,.-md2asm_allocate_reference_temperature_correction

.p2align 4
.global md2asm_initialize_reference_temperature_correction
.type md2asm_initialize_reference_temperature_correction,%function
md2asm_initialize_reference_temperature_correction:
 mov x16,x30
 bl .Lvalidate
 mov x30,x16
 cbnz w9,.Lbad
 cbz x4,.Lbad
 tst x4,#7
 b.ne .Lbad
 cmp x5,#48
 b.lo .Lbad
 adds x9,x4,#48
 b.cs .Lbad
 mov x9,#0
.Lconstants_valid:
 ldr x10,[x4,x9]
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Lbad
 cmp x9,#24
 b.eq .Lconstant_next
 tbnz x10,#63,.Lbad
 lsl x10,x10,#1
 cbz x10,.Lbad
.Lconstant_next:
 add x9,x9,#8
 cmp x9,#48
 b.lo .Lconstants_valid
 mov x9,#5224
 ldr w12,[x0,x9]
 MADDR x9,x2,1566736
 mov x13,#0
.Lshape:
 ldr x10,[x9]
 cbz x10,.Lbad
 tst x10,#7
 b.ne .Lbad
 ldr x10,[x9,#16]
 cmp x10,#8
 b.ne .Lbad
 ldr w10,[x9,#24]
 cbnz w10,.Lbad
 ldr w10,[x9,#28]
 mov w11,#0x301
 cmp w10,w11
 b.ne .Lbad
 ldr x10,[x9,#32]
 cmp x10,#8
 b.ne .Lbad
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lbad
 mov x11,#1
 cmp x13,#1
 csel x11,xzr,x11,eq
 ldr x10,[x9,#48]
 cmp x10,x11
 b.ne .Lbad
 neg x11,x11
 ldr x10,[x9,#8]
 cmp x10,x11
 b.ne .Lbad
 ldr x10,[x9,#56]
 cmp x10,x12
 b.ne .Lbad
 add x9,x9,#64
 add x13,x13,#1
 cmp x13,#3
 b.lo .Lshape
 cmp x12,#1
 b.eq .Lsingle
 ldr x6,[x0,#3240]
 cbz x6,.Lbad
 tst x6,#7
 b.ne .Lbad
 add x7,x6,#64
 mov x13,#0
.Linput_shape:
 ldr x10,[x7]
 cbz x10,.Lbad
 tst x10,#7
 b.ne .Lbad
 ldr x10,[x7,#8]
 cbnz x10,.Lbad
 ldr x10,[x7,#16]
 cmp x10,#8
 b.ne .Lbad
 ldr w10,[x7,#24]
 cbnz w10,.Lbad
 ldr w10,[x7,#28]
 mov w11,#0x301
 cmp w10,w11
 b.ne .Lbad
 ldr x10,[x7,#32]
 cmp x10,#8
 b.ne .Lbad
 ldp x10,x11,[x7,#40]
 cmp x10,#1
 b.ne .Lbad
 cbnz x11,.Lbad
 ldr x10,[x7,#56]
 cmp x10,x12
 b.ne .Lbad
 add x7,x7,#64
 add x13,x13,#1
 cmp x13,#2
 b.lo .Linput_shape
 ldr x7,[x6,#64]
 ldr x8,[x6,#128]
 mov x13,#0
.Lpressure_domain:
 ldr x10,[x7,x13,lsl#3]
 ldr x11,[x8,x13,lsl#3]
 orr x9,x10,x11
 tbnz x9,#63,.Lbad
 ubfx x9,x10,#52,#11
 cmp x9,#2047
 b.eq .Lbad
 ubfx x9,x11,#52,#11
 cmp x9,#2047
 b.eq .Lbad
 cbz x13,.Ldomain_next
 orr x9,x10,x11
 cbz x9,.Lbad
.Ldomain_next:
 add x13,x13,#1
 cmp x13,x12
 b.ls .Lpressure_domain
 sub sp,sp,#240
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 mov x19,x2
 mov x20,x12
 mov x21,x4
 mov x22,x7
 mov x23,x8
 MADDR x9,x19,1566736
 ldr x24,[x9]
 ldr x25,[x9,#64]
 ldr x26,[x9,#128]
 ldr d0,[x21,#24]
 fneg d0,d0
 ldr d1,[x21]
 fmul d0,d0,d1
 ldr d1,[x21,#8]
 fdiv d8,d0,d1
 ldr d9,[x21,#16]
 ldr d10,[x21,#32]
 ldr d11,[x21,#40]
 str xzr,[x25]
 mov x27,#1
.Ltemperature_level:
 sub x9,x27,#1
 ldr d0,[x23,x27,lsl#3]
 ldr d1,[x23,x9,lsl#3]
 fadd d2,d0,d1
 ldr d3,[x22,x27,lsl#3]
 ldr d4,[x22,x9,lsl#3]
 fadd d5,d3,d4
 str d5,[sp,#160]
 fmul d6,d5,d9
 fadd d6,d2,d6
 fmov d7,#0.5
 fmul d12,d7,d6
 fmul d4,d3,d9
 fadd d13,d0,d4
 str d3,[sp,#168]
 fdiv d0,d12,d9
 fmov d1,d8
 bl md2asm_pow_original_rounding_candidate
 fmul d14,d10,d0
 fdiv d0,d13,d9
 fmov d1,d8
 bl md2asm_pow_original_rounding_candidate
 fmul d15,d10,d0
 ldr d0,[sp,#160]
 fmov d1,#0.5
 fmul d0,d1,d0
 fmul d0,d0,d8
 fmul d0,d0,d14
 fmul d0,d0,d9
 fdiv d0,d0,d12
 sub x9,x27,#1
 str d0,[x26,x9,lsl#3]
 fcmp d14,d11
 fmov d2,xzr
 fcsel d2,d0,d2,gt
 str d2,[x24,x9,lsl#3]
 ldr d0,[sp,#168]
 fmul d0,d0,d8
 fmul d0,d0,d15
 fmul d0,d0,d9
 fdiv d0,d0,d13
 str d0,[x25,x27,lsl#3]
 add x27,x27,#1
 cmp x27,x20
 b.ls .Ltemperature_level
 mov w0,#0
 ldp d14,d15,[sp,#144]
 ldp d12,d13,[sp,#128]
 ldp d10,d11,[sp,#112]
 ldp d8,d9,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#240
 ret
.Lsingle:
 MADDR x9,x2,1566736
 ldr x9,[x9]
 fmov d0,#1.0
 str d0,[x9]
 mov w0,#0
 ret
.size md2asm_initialize_reference_temperature_correction,.-md2asm_initialize_reference_temperature_correction
.p2align 4
.global md2asm_release_reference_temperature_correction
.type md2asm_release_reference_temperature_correction,%function
md2asm_release_reference_temperature_correction:
 cbz x0,.Lbad
 tst x0,#7
 b.ne .Lbad
 mov x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 stp x18,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x19,x0
 MADDR x20,x19,1566864
 mov x21,#3
.Lrelease:
 ldr x0,[x20]
 cbz x0,.Lrelease_next
 str xzr,[x20]
 bl free
.Lrelease_next:
 sub x20,x20,#64
 subs x21,x21,#1
 b.ne .Lrelease
 mov w0,#0
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#48
 ret
.size md2asm_release_reference_temperature_correction,.-md2asm_release_reference_temperature_correction
.Lbad:
 mov w0,#2
 ret
.section .note.GNU-stack,"",%progbits
