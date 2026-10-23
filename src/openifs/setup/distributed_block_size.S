/* Contract: skills/md2asm/references/openifs/setup/operational_distributed_partition.md.
 * Internal complete source SUOPTPROMA. x0 live Geometry17096, x1 config8.
 * Return0 succeeds,2 refuses unsupported state or thread count. Frame144 bytes.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_distributed_block_size
.type md2asm_initialize_operational_distributed_block_size,%function
md2asm_initialize_operational_distributed_block_size:
 mrs x9,fpcr
 cbnz x9,.Ldproma_bad
 cbz x0,.Ldproma_bad
 cbz x1,.Ldproma_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Ldproma_bad
 mov x9,#17096
 adds x9,x0,x9
 b.cs .Ldproma_bad
 adds x9,x1,#8
 b.cs .Ldproma_bad
 ldp w9,w10,[x1]
 cbnz w9,.Ldproma_bad
 cmp w10,#1
 b.ne .Ldproma_bad
 ldr x9,[x0]
 cbz x9,.Ldproma_bad
 tst x9,#3
 b.ne .Ldproma_bad
 ldr w9,[x9]
 cbnz w9,.Ldproma_bad
 ldr w9,[x0,#5144]
 cmp w9,#16
 b.ne .Ldproma_bad
 ldr w9,[x0,#5164]
 cmp w9,#1
 b.ne .Ldproma_bad
 ldr w9,[x0,#4872]
 cmp w9,#2560
 b.ne .Ldproma_bad
 ldr w9,[x0,#5172]
 cmp w9,#1279
 b.ne .Ldproma_bad
 ldr w9,[x0,#5224]
 cmp w9,#137
 b.ne .Ldproma_bad
 mov w10,#0x2d00
 movk w10,#0x19,lsl#16
 ldr w9,[x0,#7376]
 cmp w9,w10
 b.ne .Ldproma_bad
 ldr w9,[x0,#7384]
 cmp w9,w10
 b.ne .Ldproma_bad
 sub sp,sp,#144
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#104]
 mov x19,x0
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 bl __oml_mod_MOD_oml_max_threads
 cmp w0,#1
 b.ne .Ldproma_threads
 ldr w22,[x19,#5144]
 ldr w23,[x19,#7384]
 sub w23,w23,#1
 add w26,w22,#1
 mov w9,#5
 mul w9,w22,w9
 mov w10,#100
 sdiv w9,w9,w10
 add w24,w26,w9
 sdiv w25,w23,w22
 add w25,w25,#1
 sdiv w22,w23,w25
 add w22,w22,#1
 str w22,[x19,#5144]
 cmp w26,w24
 b.gt .Ldproma_selected
.Ldproma_search:
 sdiv w9,w23,w26
 add w9,w9,#1
 sdiv w10,w23,w9
 add w10,w10,#1
 cmp w9,w25
 b.ge .Ldproma_next
 mov w25,w9
 mov w22,w10
 str w22,[x19,#5144]
.Ldproma_next:
 add w26,w26,#1
 cmp w26,w24
 b.le .Ldproma_search
.Ldproma_selected:
 str w22,[x19,#5148]
 mov w9,#1
 str w9,[x19,#5156]
 mov w27,#0
 b .Ldproma_return
.Ldproma_threads:
 mov w27,#2
.Ldproma_return:
 str w21,[x20]
 ldp x9,x10,[sp,#104]
 msr fpcr,x9
 msr fpsr,x10
 mov w0,w27
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.Ldproma_bad:
 mov w0,#2
 ret
.size md2asm_initialize_operational_distributed_block_size,.-md2asm_initialize_operational_distributed_block_size
.section .note.GNU-stack,"",%progbits
