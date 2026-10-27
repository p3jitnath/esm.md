/* Contract skills/md2asm/references/openifs/input/runtime_operational_input_state.md. */
/* Bind the live accepted partition owner to complete SLCSET/SLRSET.
 * x0 Geometry, x1 capacity, x2 final MODEL, x3 capacity, x4 owner4096,
 * x5 owner capacity. The owner remains borrowed through release. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_owned_distributed_interpolation_halo
.type md2asm_initialize_owned_distributed_interpolation_halo,%function
md2asm_initialize_owned_distributed_interpolation_halo:
 cbz x4,.Ldhp_bad
 tst x4,#7
 b.ne .Ldhp_bad
 cmp x5,#4096
 b.lo .Ldhp_bad
 adds x6,x4,#4096
 b.cs .Ldhp_bad
 ldr x6,[x4]
 cmp x6,x0
 b.ne .Ldhp_bad
 ldr x6,[x4,#8]
 ldr x7,.Ldhp_cookie
 cmp x6,x7
 b.ne .Ldhp_bad
 ldr w6,[x4,#16]
 cmp w6,#7
 b.ne .Ldhp_bad
 stp x29,x30,[sp,#-112]!
 str x18,[sp,#16]
 ldr w6,[x4,#24]
 str w6,[sp,#32]
 ldr w6,[x4,#28]
 str w6,[sp,#36]
 ldr w6,[x4,#48]
 str w6,[sp,#40]
 ldr w6,[x4,#52]
 str w6,[sp,#44]
 ldr w6,[x4,#932]
 str w6,[sp,#48]
 ldr w6,[x4,#936]
 str w6,[sp,#52]
 str xzr,[sp,#56]
 ldr x6,[x4,#216]
 str x6,[sp,#64]
 ldr x6,[x4,#280]
 str x6,[sp,#72]
 mov w6,#6
 str w6,[sp,#80]
 str wzr,[sp,#84]
 mov w6,#1
 str w6,[sp,#88]
 str wzr,[sp,#92]
 add x4,sp,#32
 mov x5,#64
 bl md2asm_initialize_distributed_interpolation_buffer
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.Ldhp_bad:
 mov w0,#2
 ret
.size md2asm_initialize_owned_distributed_interpolation_halo,.-md2asm_initialize_owned_distributed_interpolation_halo
.p2align 3
.Ldhp_cookie: .quad 0x445054585f4f574e
.section .note.GNU-stack,"",%progbits
