// Own the complete operational field namespace and its physical constants.
// Contract: skills/md2asm/references/openifs/setup/owned_operational_field_namespace.md. x0 text, x1 bytes,
// x2 read-only int32 stopping count, x3 writable output pointer.
// The returned context starts with the 1,359,136-byte live namespace.
.arch armv8.2-a
.equ namespace_bytes, 1359136
.equ constants_offset, 1359136
.equ controls_offset, 1359656
.equ effects_offset, 1359696
.equ marker_offset, 1359736
.equ context_bytes, 1359744
.text
.p2align 4
.global md2asm_create_operational_field_namespace
.type md2asm_create_operational_field_namespace,%function
md2asm_create_operational_field_namespace:
 cbz x0,.Lowned_namespace_invalid
 cbz x1,.Lowned_namespace_invalid
 cbz x2,.Lowned_namespace_invalid
 cbz x3,.Lowned_namespace_invalid
 mov x9,#64
 lsl x9,x9,#12
 cmp x1,x9
 b.hi .Lowned_namespace_invalid
 tst x2,#3
 b.ne .Lowned_namespace_invalid
 tst x3,#7
 b.ne .Lowned_namespace_invalid
 adds x9,x0,x1
 b.cs .Lowned_namespace_invalid
 adds x10,x2,#4
 b.cs .Lowned_namespace_invalid
 adds x11,x3,#8
 b.cs .Lowned_namespace_invalid
 cmp x11,x0
 b.ls .Lowned_namespace_text_disjoint
 cmp x3,x9
 b.lo .Lowned_namespace_invalid
.Lowned_namespace_text_disjoint:
 cmp x11,x2
 b.ls .Lowned_namespace_count_disjoint
 cmp x3,x10
 b.lo .Lowned_namespace_invalid
.Lowned_namespace_count_disjoint:
 ldr x9,[x3]
 cbnz x9,.Lowned_namespace_invalid
 ldr w9,[x2]
 cmp w9,#0
 b.le .Lowned_namespace_invalid
 mrs x10,fpcr
 cbnz x10,.Lowned_namespace_invalid
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x10,fpsr
 str x10,[sp,#104]
 mov x19,x0
 mov x20,x1
 mov x21,x3
 mov w23,w9
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#112]
 movz x0,#(context_bytes & 65535)
 movk x0,#(context_bytes >> 16),lsl#16
 bl malloc
 mov x22,x0
 ldr x9,[sp,#104]
 msr fpsr,x9
 ldr x10,[sp,#120]
 ldr w9,[sp,#112]
 str w9,[x10]
 cbz x22,.Lowned_namespace_allocation_failed
 mov x9,x22
 movz x10,#(context_bytes & 65535)
 movk x10,#(context_bytes >> 16),lsl#16
 add x10,x22,x10
.Lowned_namespace_clear:
 str xzr,[x9],#8
 cmp x9,x10
 b.lo .Lowned_namespace_clear
 movz x9,#(constants_offset & 65535)
 movk x9,#(constants_offset >> 16),lsl#16
 add x0,x22,x9
 mov x1,#520
 bl md2asm_initialize_physical_constants
 cbnz w0,.Lowned_namespace_child_failed
 movz x9,#(controls_offset & 65535)
 movk x9,#(controls_offset >> 16),lsl#16
 add x24,x22,x9
 adr x10,.Lowned_namespace_controls
 ldp x11,x12,[x10]
 stp x11,x12,[x24]
 ldp x11,x12,[x10,#16]
 stp x11,x12,[x24,#16]
 ldr w11,[x10,#32]
 str w11,[x24,#32]
 str w23,[x24,#8]
 mov x0,x22
 movz x9,#(constants_offset & 65535)
 movk x9,#(constants_offset >> 16),lsl#16
 add x1,x22,x9
 mov x2,x19
 mov x3,x20
 mov x4,x24
 movz x9,#(effects_offset & 65535)
 movk x9,#(effects_offset >> 16),lsl#16
 add x5,x22,x9
 bl md2asm_initialize_operational_grid_field_configuration
 cbnz w0,.Lowned_namespace_child_failed
 movz x9,#(marker_offset & 65535)
 movk x9,#(marker_offset >> 16),lsl#16
 adrp x10,.Lowned_namespace_marker
 ldr x10,[x10,:lo12:.Lowned_namespace_marker]
 str x10,[x22,x9]
 str x22,[x21]
 mov w0,#0
 b .Lowned_namespace_return
.Lowned_namespace_child_failed:
 mrs x9,fpsr
 str x9,[sp,#104]
 mov x0,x22
 bl free
 ldr x9,[sp,#104]
 msr fpsr,x9
 ldr x10,[sp,#120]
 ldr w9,[sp,#112]
 str w9,[x10]
 mov w0,#3
 b .Lowned_namespace_return
.Lowned_namespace_allocation_failed:
 mov w0,#1
.Lowned_namespace_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#128
 ret
.Lowned_namespace_invalid:
 mov w0,#2
 ret
.size md2asm_create_operational_field_namespace,.-md2asm_create_operational_field_namespace
.p2align 4
.global md2asm_release_operational_field_namespace
.type md2asm_release_operational_field_namespace,%function
md2asm_release_operational_field_namespace:
 cbz x0,.Lowned_namespace_release_invalid
 tst x0,#7
 b.ne .Lowned_namespace_release_invalid
 movz x9,#(context_bytes & 65535)
 movk x9,#(context_bytes >> 16),lsl#16
 adds x10,x0,x9
 b.cs .Lowned_namespace_release_invalid
 movz x9,#(marker_offset & 65535)
 movk x9,#(marker_offset >> 16),lsl#16
 ldr x10,[x0,x9]
 adrp x11,.Lowned_namespace_marker
 ldr x11,[x11,:lo12:.Lowned_namespace_marker]
 cmp x10,x11
 b.ne .Lowned_namespace_release_invalid
 stp x29,x30,[sp,#-80]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 str x18,[sp,#48]
 mrs x10,fpsr
 str x10,[sp,#56]
 mov x19,x0
 str xzr,[x0,x9]
 bl __errno_location
 mov x20,x0
 ldr w9,[x20]
 str w9,[sp,#64]
 mov x0,x19
 bl free
 ldr w9,[sp,#64]
 str w9,[x20]
 ldr x9,[sp,#56]
 msr fpsr,x9
 mov w0,#0
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.Lowned_namespace_release_invalid:
 mov w0,#2
 ret
.size md2asm_release_operational_field_namespace,.-md2asm_release_operational_field_namespace
.section .rodata
.balign 8
.Lowned_namespace_marker: .quad 0x47464c4f574e5231
.Lowned_namespace_controls: .word 137,0,0,1,1,0,1,1,1
.section .note.GNU-stack,"",%progbits
