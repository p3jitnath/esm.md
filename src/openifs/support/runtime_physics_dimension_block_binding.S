/* Contract: skills/md2asm/references/openifs/support/runtime_physics_dimension_block_binding.md.
 * x0 writable dimensions192, x1 immutable Geometry20400, w2 zero-based block.
 * Live P/N/B and actual GS/NGPLAT owners determine every block bound and address.
 * Return0 complete or2 pre-write refusal. Caller supplies complete mapped owners.
 * Integer leaf, no frame or payload write; tail-call accepted raw dimension UPDATE.
 * Preserve x18..x30, vectors, FPCR/FPSR and errno; caller-saved integers are scratch.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_update_runtime_physics_dimensions
.type md2asm_update_runtime_physics_dimensions,%function
md2asm_update_runtime_physics_dimensions:
 cbz x0,.Ldimension_block_refuse
 cbz x1,.Ldimension_block_refuse
 orr x16,x0,x1
 tst x16,#7
 b.ne .Ldimension_block_refuse
 adds x16,x0,#192
 b.cs .Ldimension_block_refuse
 mov x17,#20400
 adds x17,x1,x17
 b.cs .Ldimension_block_refuse
 cmp x0,x17
 b.hs .Ldimension_block_separate
 cmp x1,x16
 b.lo .Ldimension_block_refuse
.Ldimension_block_separate:
 ldr w3,[x1,#7376]
 cmp w3,#0
 b.le .Ldimension_block_refuse
 ldr w4,[x1,#5144]
 cmp w4,#0
 b.le .Ldimension_block_refuse
 ldr w16,[x0,#12]
 cmp w16,w4
 b.ne .Ldimension_block_refuse
 sub w5,w3,#1
 udiv w5,w5,w4
 add w5,w5,#1
 ldr w16,[x1,#5160]
 cmp w5,w16
 b.ne .Ldimension_block_refuse
 cmp w2,w5
 b.hs .Ldimension_block_refuse
 add w6,w2,#1
 umull x7,w2,w4
 cmp x7,x3
 b.hs .Ldimension_block_refuse
 sub w8,w3,w7
 cmp w8,w4
 csel w8,w8,w4,lo
 /* The actual root owns B contiguous GS records of1472bytes each. */
 ldr x9,[x1,#8472]
 cbz x9,.Ldimension_block_refuse
 tst x9,#7
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#8480]
 cmn x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#8488]
 cmp x16,#1472
 b.ne .Ldimension_block_refuse
 movz x17,#0x0501,lsl#32
 ldr x16,[x1,#8496]
 cmp x16,x17
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#8504]
 cmp x16,#1472
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#8512]
 cmp x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#8520]
 cmp x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#8528]
 cmp x16,x5
 b.ne .Ldimension_block_refuse
 mov w16,#1472
 umull x10,w5,w16
 adds x10,x9,x10
 b.cs .Ldimension_block_refuse
 umaddl x11,w2,w16,x9
 add x12,x11,#1344
 /* The nonblocked owner contains N actual int32 latitude-row indices. */
 ldr x13,[x1,#9880]
 cbz x13,.Ldimension_block_refuse
 tst x13,#3
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#9888]
 cmn x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#9896]
 cmp x16,#4
 b.ne .Ldimension_block_refuse
 movz x17,#0x0101,lsl#32
 ldr x16,[x1,#9904]
 cmp x16,x17
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#9912]
 cmp x16,#4
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#9920]
 cmp x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#9928]
 cmp x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x1,#9936]
 cmp x16,x3
 b.ne .Ldimension_block_refuse
 lsl x14,x3,#2
 adds x14,x13,x14
 b.cs .Ldimension_block_refuse
 add x15,x13,x7,lsl#2
 /* The selected GS pointer is the exact active slice of that owner. */
 ldr x16,[x12]
 cmp x16,x15
 b.ne .Ldimension_block_refuse
 ldr x16,[x12,#8]
 cmn x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x12,#16]
 cmp x16,#4
 b.ne .Ldimension_block_refuse
 ldr x16,[x12,#24]
 cmp x16,x17
 b.ne .Ldimension_block_refuse
 ldr x16,[x12,#32]
 cmp x16,#4
 b.ne .Ldimension_block_refuse
 ldr x16,[x12,#40]
 cmp x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x12,#48]
 cmp x16,#1
 b.ne .Ldimension_block_refuse
 ldr x16,[x12,#56]
 cmp x16,x8
 b.ne .Ldimension_block_refuse
 add x16,x15,x8,lsl#2
 cmp x16,x14
 b.hi .Ldimension_block_refuse
 mov w1,w6
 mov w2,w8
 add w3,w7,#1
 mov x4,x12
 b md2asm_update_physics_dimensions
.Ldimension_block_refuse:
 mov w0,#2
 ret
.size md2asm_update_runtime_physics_dimensions,.-md2asm_update_runtime_physics_dimensions
.section .note.GNU-stack,"",%progbits
