/* Source GP_MODEL initial PSLBUF2 assignment, before grid-point calculations.
 * Contract skills/md2asm/references/openifs/dynamics/operational_grid_work_initialization.md.
 * Borrowed constructor-owned work128 and complete payload.
 * Two register arguments. No frame, external call or floating-point instruction. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_grid_work
.type md2asm_initialize_operational_grid_work,%function
md2asm_initialize_operational_grid_work:
 cbz x0,.Lzero_bad
 tst x0,#7
 b.ne .Lzero_bad
 cmp x1,#128
 b.lo .Lzero_bad
 adds x2,x0,#128
 b.cs .Lzero_bad
 ldr x2,[x0,#112]
 cmp x2,#15
 b.ne .Lzero_bad
 ldr x2,[x0,#120]
 cbnz x2,.Lzero_bad
 ldp w2,w3,[x0,#80]
 cmp w2,#17
 b.ne .Lzero_bad
 cmp w3,#137
 b.ne .Lzero_bad
 ldp w2,w3,[x0,#88]
 movz w4,#31519
 movk w4,#1,lsl#16
 cmp w2,w4
 b.ne .Lzero_bad
 cmp w3,#12
 b.ne .Lzero_bad
 ldp w2,w3,[x0,#104]
 cmp w2,#3337
 b.ne .Lzero_bad
 cmp w3,#1097
 b.ne .Lzero_bad
 ldr x2,[x0,#8]
 cbz x2,.Lzero_bad
 tst x2,#7
 b.ne .Lzero_bad
 movz x3,#15248
 movk x3,#65,lsl#16
 adds x3,x2,x3
 b.cs .Lzero_bad
 movz x3,#1928
 movk x3,#24,lsl#16
 ldr w3,[x2,x3]
 cbnz w3,.Lzero_bad
 ldp x2,x3,[x0,#64]
 cbz x2,.Lzero_bad
 tst x2,#7
 b.ne .Lzero_bad
 movz x4,#43576
 movk x4,#24336,lsl#16
 movk x4,#3,lsl#32
 cmp x3,x4
 b.ne .Lzero_bad
 adds x5,x2,x3
 b.cs .Lzero_bad
 /* The work record cannot overlap the mutable payload. */
 adds x6,x0,#128
 cmp x2,x6
 b.hs .Lzero_ranges_valid
 cmp x0,x5
 b.lo .Lzero_bad
.Lzero_ranges_valid:
.Lzero_loop:
 cmp x3,#64
 b.lo .Lzero_tail
 stp xzr,xzr,[x2]
 stp xzr,xzr,[x2,#16]
 stp xzr,xzr,[x2,#32]
 stp xzr,xzr,[x2,#48]
 add x2,x2,#64
 sub x3,x3,#64
 b .Lzero_loop
.Lzero_tail:
 cmp x3,#16
 b.lo .Lzero_word
 stp xzr,xzr,[x2],#16
 sub x3,x3,#16
 b .Lzero_tail
.Lzero_word:
 cbz x3,.Lzero_done
 str xzr,[x2]
.Lzero_done:
 mov w0,#0
 ret
.Lzero_bad:
 mov w0,#2
 ret
.size md2asm_initialize_operational_grid_work,.-md2asm_initialize_operational_grid_work
.section .note.GNU-stack,"",%progbits
