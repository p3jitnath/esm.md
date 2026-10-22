/* Owned layered surface field registration, revision 2.
 * Contract: skills/md2asm/references/openifs/setup/layered_surface_field_registration.md.
 * x0 group60, x1 field288, x2 trajectory408, x3 read-only plan40.
 * Source allocations contain identifiers, names, defaults and requests. */
.arch armv8.2-a
.macro LAYERED_DISJOINT first,first_end,second,second_end
 cmp \first,\second_end
 b.hs .Llayered_separate\@
 cmp \second,\first_end
 b.lo .Llayered_reject
.Llayered_separate\@:
.endm
.text
.p2align 4
.global md2asm_define_layered_surface_field
.type md2asm_define_layered_surface_field,%function
md2asm_define_layered_surface_field:
 cbz x0,.Llayered_reject
 cbz x1,.Llayered_reject
 cbz x2,.Llayered_reject
 cbz x3,.Llayered_reject
 orr x12,x0,x2
 tst x12,#3
 b.ne .Llayered_reject
 orr x12,x1,x3
 tst x12,#7
 b.ne .Llayered_reject
 adds x8,x0,#60
 b.cs .Llayered_reject
 adds x9,x1,#288
 b.cs .Llayered_reject
 adds x10,x2,#408
 b.cs .Llayered_reject
 adds x11,x3,#40
 b.cs .Llayered_reject
 LAYERED_DISJOINT x0,x8,x1,x9
 LAYERED_DISJOINT x0,x8,x2,x10
 LAYERED_DISJOINT x0,x8,x3,x11
 LAYERED_DISJOINT x1,x9,x2,x10
 LAYERED_DISJOINT x1,x9,x3,x11
 LAYERED_DISJOINT x2,x10,x3,x11
 ldr w4,[x0,#8]
 cmp w4,#137
 b.eq .Llayered_level_ok
 sub w12,w4,#1
 cmp w12,#63
 b.hi .Llayered_reject
.Llayered_level_ok:
 ldr w12,[x0,#56]
 cbnz w12,.Llayered_reject
 ldr w7,[x0,#12]
 sub w12,w7,#1
 cmp w12,#692
 b.hi .Llayered_reject
 ldr w12,[x1,#20]
 cmp w12,w7
 b.ne .Llayered_reject
 ldr x12,[x1,#32]
 ldr x13,[x1,#96]
 orr x12,x12,x13
 ldr x13,[x1,#160]
 orr x12,x12,x13
 ldr x13,[x1,#224]
 orr x12,x12,x13
 cbnz x12,.Llayered_reject
 ldr w5,[x3]
 cmp w5,#31
 b.hi .Llayered_reject
 mov w6,#0
 tbz w5,#3,.Llayered_array_checks
 ldr w6,[x3,#4]
 cmp w6,#2
 b.hi .Llayered_reject
 ldr w12,[x0,#20]
 cmp w12,w7
 b.hs .Llayered_reject
 cbz w6,.Llayered_array_checks
 cmp w6,#1
 b.ne .Llayered_constant_bound
 ldr w12,[x2]
 cmp w12,#100
 b.hi .Llayered_reject
 add w12,w12,w4
 cmp w12,#100
 b.hi .Llayered_reject
 b .Llayered_array_checks
.Llayered_constant_bound:
 ldr w12,[x2,#4]
 tbnz w12,#31,.Llayered_reject
 adds w12,w12,w4
 b.vs .Llayered_reject
.Llayered_array_checks:
 adr x12,.Llayered_input_specs
.Llayered_input:
 ldr w14,[x12],#4
 ubfx w15,w14,#8,#8
 lsrv w15,w5,w15
 tbz w15,#0,.Llayered_input_next
 and w15,w14,#0xff
 ldr x15,[x3,x15]
 cbz x15,.Llayered_reject
 ubfx w16,w14,#24,#8
 tst x15,x16
 b.ne .Llayered_reject
 ubfx w16,w14,#16,#8
 lsl x16,x4,x16
 adds x16,x15,x16
 b.cs .Llayered_reject
 LAYERED_DISJOINT x0,x8,x15,x16
 LAYERED_DISJOINT x1,x9,x15,x16
 LAYERED_DISJOINT x2,x10,x15,x16
.Llayered_input_next:
 adr x17,.Llayered_input_specs_end
 cmp x12,x17
 b.lo .Llayered_input
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 stp xzr,xzr,[sp,#112]
 stp xzr,xzr,[sp,#128]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov w24,w5
 mov w25,w6
 mov w26,w7
 mrs x9,fpcr
 str x9,[sp,#144]
 mrs x9,fpsr
 str x9,[sp,#152]
 bl __errno_location
 mov x27,x0
 ldr w28,[x27]
 lsl x0,x23,#2
 bl malloc
 str x0,[sp,#112]
 cbz x0,.Llayered_allocation_failure
 lsl x0,x23,#4
 bl malloc
 str x0,[sp,#120]
 cbz x0,.Llayered_allocation_failure
 lsl x0,x23,#3
 bl malloc
 str x0,[sp,#128]
 cbz x0,.Llayered_allocation_failure
 lsl x0,x23,#2
 bl malloc
 str x0,[sp,#136]
 cbz x0,.Llayered_allocation_failure
 /* Publish all four complete typed descriptors after successful allocation. */
 adr x9,.Llayered_descriptor_specs
 mov x10,#0
 add x16,sp,#112
.Llayered_descriptor:
 ldp w11,w12,[x9],#8
 ldr x13,[x9],#8
 add x14,x20,x11
 ldr x15,[x16,x10,lsl#3]
 mov x17,#-1
 stp x15,x17,[x14]
 stp x12,x13,[x14,#16]
 str x12,[x14,#32]
 mov x17,#1
 stp x17,x17,[x14,#40]
 str x23,[x14,#56]
 add x10,x10,#1
 cmp x10,#4
 b.lo .Llayered_descriptor
 /* Source identifier assignment. */
 ldr x0,[sp,#112]
 mov x2,x23
 tbz w24,#0,.Llayered_codes_default
 ldr x1,[x22,#8]
.Llayered_codes_copy:
 ldr w3,[x1],#4
 str w3,[x0],#4
 subs x2,x2,#1
 b.ne .Llayered_codes_copy
 b .Llayered_names
.Llayered_codes_default:
 mov w3,#-999
.Llayered_codes_fill:
 str w3,[x0],#4
 subs x2,x2,#1
 b.ne .Llayered_codes_fill
.Llayered_names:
 ldr x0,[sp,#120]
 mov x2,x23
 tbz w24,#1,.Llayered_names_default
 ldr x1,[x22,#16]
.Llayered_names_copy:
 ldp x3,x4,[x1],#16
 stp x3,x4,[x0],#16
 subs x2,x2,#1
 b.ne .Llayered_names_copy
 b .Llayered_defaults
.Llayered_names_default:
 adr x1,.Llayered_blank_name
 ldp x3,x4,[x1]
.Llayered_names_fill:
 stp x3,x4,[x0],#16
 subs x2,x2,#1
 b.ne .Llayered_names_fill
.Llayered_defaults:
 ldr x0,[sp,#128]
 mov x2,x23
 tbz w24,#2,.Llayered_defaults_zero
 ldr x1,[x22,#24]
.Llayered_defaults_copy:
 ldr x3,[x1],#8
 str x3,[x0],#8
 subs x2,x2,#1
 b.ne .Llayered_defaults_copy
 b .Llayered_requests
.Llayered_defaults_zero:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Llayered_defaults_zero
.Llayered_requests:
 ldr x0,[sp,#136]
 mov x2,x23
 tbz w24,#4,.Llayered_requests_default
 ldr x1,[x22,#32]
.Llayered_requests_copy:
 ldr w3,[x1],#4
 str w3,[x0],#4
 subs x2,x2,#1
 b.ne .Llayered_requests_copy
 b .Llayered_trajectory
.Llayered_requests_default:
 mov w3,#-1
.Llayered_requests_fill:
 str w3,[x0],#4
 subs x2,x2,#1
 b.ne .Llayered_requests_fill
.Llayered_trajectory:
 tbz w24,#3,.Llayered_trajectory_done
 cbz w25,.Llayered_trajectory_count
 cmp w25,#1
 b.ne .Llayered_constant_increment
 ldr w9,[x21]
 add x10,x21,#8
 add x10,x10,x9,lsl#2
 ldr x11,[sp,#112]
 mov x12,x23
.Llayered_trajectory_codes:
 ldr w13,[x11],#4
 str w13,[x10],#4
 subs x12,x12,#1
 b.ne .Llayered_trajectory_codes
 add w9,w9,w23
 str w9,[x21]
 b .Llayered_trajectory_count
.Llayered_constant_increment:
 ldr w9,[x21,#4]
 add w9,w9,w23
 str w9,[x21,#4]
.Llayered_trajectory_count:
 ldr w9,[x19,#20]
 add w9,w9,#1
 str w9,[x19,#20]
.Llayered_trajectory_done:
 str w25,[x20,#16]
 mov w9,#1
 str w9,[x20,#24]
 add w26,w26,#1
 str w26,[x19,#12]
 mov w0,#0
 b .Llayered_return
.Llayered_allocation_failure:
 mov x24,#0
.Llayered_failure_cleanup:
 add x9,sp,#112
 ldr x0,[x9,x24,lsl#3]
 cbz x0,.Llayered_failure_next
 bl free
.Llayered_failure_next:
 add x24,x24,#1
 cmp x24,#4
 b.lo .Llayered_failure_cleanup
 mov w0,#1
.Llayered_return:
 str w28,[x27]
 ldr x9,[sp,#144]
 msr fpcr,x9
 ldr x9,[sp,#152]
 msr fpsr,x9
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Llayered_reject:
 mov w0,#2
 ret
.size md2asm_define_layered_surface_field,.-md2asm_define_layered_surface_field

.p2align 4
.global md2asm_release_layered_surface_field
.type md2asm_release_layered_surface_field,%function
md2asm_release_layered_surface_field:
 cbz x0,.Llayered_release_empty
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mrs x22,fpcr
 mrs x23,fpsr
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 ldr x0,[x19,#32]
 cbz x0,.Llayered_release_0
 bl free
 str xzr,[x19,#32]
.Llayered_release_0:
 ldr x0,[x19,#96]
 cbz x0,.Llayered_release_1
 bl free
 str xzr,[x19,#96]
.Llayered_release_1:
 ldr x0,[x19,#160]
 cbz x0,.Llayered_release_2
 bl free
 str xzr,[x19,#160]
.Llayered_release_2:
 ldr x0,[x19,#224]
 cbz x0,.Llayered_release_3
 bl free
 str xzr,[x19,#224]
.Llayered_release_3:
 str w21,[x20]
 msr fpcr,x22
 msr fpsr,x23
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#64
.Llayered_release_empty:
 mov w0,#0
 ret
.size md2asm_release_layered_surface_field,.-md2asm_release_layered_surface_field
.section .rodata
.p2align 2
.Llayered_input_specs:
 .byte 8,0,2,3
 .byte 16,1,4,0
 .byte 24,2,3,7
 .byte 32,4,2,3
.Llayered_input_specs_end:
.p2align 3
.Llayered_descriptor_specs:
 .word 32,4
 .quad 0x0000010100000000
 .word 96,16
 .quad 0x0000060100000000
 .word 160,8
 .quad 0x0000030100000000
 .word 224,4
 .quad 0x0000010100000000
.Llayered_blank_name: .ascii "                "
.section .note.GNU-stack,"",%progbits
