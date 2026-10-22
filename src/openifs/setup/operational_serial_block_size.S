/* Complete selected global SUOPTPROMA for the operational serial input.
 * x0: writable Geometry record (17,096 bytes); x1: read-only config (8 bytes).
 * Return w0: 0 success, 2 unsupported state or actual public thread count.
 * Contract: skills/md2asm/references/openifs/setup/operational_serial_block_size.md.
 * Preserve saved registers, x18, FPCR, FPSR and errno. Frame: 144 bytes.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_serial_block_size
.type md2asm_initialize_operational_serial_block_size,%function
md2asm_initialize_operational_serial_block_size:
 mrs x9,fpcr
 cbnz x9,.Lproma_bad
 cbz x0,.Lproma_bad
 cbz x1,.Lproma_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lproma_bad
 mov x9,#17096
 adds x9,x0,x9
 b.cs .Lproma_bad
 adds x9,x1,#8
 b.cs .Lproma_bad
 ldp w9,w10,[x1]
 cbnz w9,.Lproma_bad
 cmp w10,#1
 b.ne .Lproma_bad
 ldr x9,[x0]
 cbz x9,.Lproma_bad
 tst x9,#3
 b.ne .Lproma_bad
 ldr w9,[x9]
 cbnz w9,.Lproma_bad
 ldr w9,[x0,#5144]
 cmp w9,#16
 b.ne .Lproma_bad
 ldr w9,[x0,#5164]
 cmp w9,#1
 b.ne .Lproma_bad
 ldr w9,[x0,#4872]
 cmp w9,#2560
 b.ne .Lproma_bad
 ldr w9,[x0,#5172]
 cmp w9,#1279
 b.ne .Lproma_bad
 ldr w9,[x0,#5224]
 cmp w9,#137
 b.ne .Lproma_bad
 mov w10,#0xb400
 movk w10,#0x64,lsl#16
 ldr w9,[x0,#7376]
 cmp w9,w10
 b.ne .Lproma_bad
 ldr w9,[x0,#7384]
 cmp w9,w10
 b.ne .Lproma_bad
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
 b.ne .Lproma_threads
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
 b.gt .Lproma_selected
.Lproma_search:
 sdiv w9,w23,w26
 add w9,w9,#1
 sdiv w10,w23,w9
 add w10,w10,#1
 cmp w9,w25
 b.ge .Lproma_next
 mov w25,w9
 mov w22,w10
 str w22,[x19,#5144]
.Lproma_next:
 add w26,w26,#1
 cmp w26,w24
 b.le .Lproma_search
.Lproma_selected:
 str w22,[x19,#5148]
 mov w9,#1
 str w9,[x19,#5156]
 mov w27,#0
 b .Lproma_return
.Lproma_threads:
 mov w27,#2
.Lproma_return:
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
.Lproma_bad:
 mov w0,#2
 ret
.size md2asm_initialize_operational_serial_block_size,.-md2asm_initialize_operational_serial_block_size
.section .note.GNU-stack,"",%progbits
