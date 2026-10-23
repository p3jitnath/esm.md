/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */
/* Contract: skills/md2asm/references/openifs/setup/spectral_geometry_maps.md.
 * Initialize x0 record[200], x1 int32 dimensions[4], x2 MYMS[N+1],
 * x3 NSE0L[N+1], x4 stretch[1]. Return w0:0 ready,1 allocation,2 reject.
 * Own GMR and SCGMAP only; preserve final24 record bytes. Frame10384B,
 * aligned16B, including1282 recurrence words. Only malloc/free/errno external.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_distributed_spectral_geometry_maps
.type md2asm_initialize_distributed_spectral_geometry_maps,%function
md2asm_initialize_distributed_spectral_geometry_maps:
 cbz x0,.Lospectral_reject
 cbz x1,.Lospectral_reject
 cbz x2,.Lospectral_reject
 cbz x3,.Lospectral_reject
 cbz x4,.Lospectral_reject
 orr x9,x0,x4
 tst x9,#7
 b.ne .Lospectral_reject
 orr x9,x1,x2
 orr x9,x9,x3
 tst x9,#3
 b.ne .Lospectral_reject
 mrs x9,fpcr
 cbnz x9,.Lospectral_reject
 ldr x9,[x0]
 ldr x10,[x0,#88]
 orr x9,x9,x10
 cbnz x9,.Lospectral_reject
 ldp w9,w10,[x1]
 cmp w9,#1279
 b.ne .Lospectral_reject
 cmp w10,#640
 b.ne .Lospectral_reject
 ldp w13,w14,[x1,#8]
 movz w12,#0x4140
 movk w12,#6,lsl#16
 cmp w13,w12
 b.ne .Lospectral_reject
 cbnz w14,.Lospectral_reject
 mov x14,#0x3ff0
 lsl x14,x14,#48
 ldr x15,[x4]
 cmp x15,x14
 b.ne .Lospectral_reject
 mov w11,#0
 mov w12,#0
.Lospectral_check_layout:
 ldr w13,[x2,x11,lsl#2]
 cmp w13,#1279
 b.hi .Lospectral_reject
 ldr w14,[x3,x11,lsl#2]
 cmp w14,w12
 b.ne .Lospectral_reject
 mov w14,#1280
 sub w14,w14,w13
 add w12,w12,w14
 add w11,w11,#1
 cmp w11,w10
 b.lo .Lospectral_check_layout
 movz w14,#0x4140
 movk w14,#6,lsl#16
 cmp w12,w14
 b.ne .Lospectral_reject
 mov x9,#10384
 sub sp,sp,x9
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 str x15,[sp,#112]
 ldp w23,w24,[x20]
 ldr w25,[x20,#8]
 bl __errno_location
 mov x27,x0
 ldr w9,[x27]
 str w9,[sp,#120]
 lsl x0,x25,#4
 bl malloc
 cbz x0,.Lospectral_alloc_failed
 mov x26,x0
 mov x9,#24
 mul x0,x25,x9
 bl malloc
 cbz x0,.Lospectral_second_failed
 mov x28,x0
 /* Complete canonical rank-two descriptors; ESCGMAP is untouched. */
 mov x8,x19
 mov x0,x26
 mov x1,#2
 bl .Lospectral_descriptor
 add x8,x19,#88
 mov x0,x28
 mov x1,#3
 bl .Lospectral_descriptor
 ldr d25,[sp,#112]
 fmov d20,#1.0
 fmov d21,#0.5
 fmov d22,#2.0
 fmov d23,#4.0
 fmov d24,xzr
 /* SUSPGM: the two source expressions retain separate divisions. */
 fdiv d0,d20,d25
 fadd d0,d25,d0
 fmul d26,d21,d0
 fdiv d0,d20,d25
 fsub d0,d25,d0
 fmul d27,d21,d0
 mov w10,#0
.Lospectral_first_column:
 ldr w8,[x21,x10,lsl#2]
 ldr w11,[x22,x10,lsl#2]
 bl .Lospectral_recurrence
 mov w9,w8
.Lospectral_GMR_diagonal:
 sub w12,w9,w8
 add w12,w12,w11
 str d26,[x26,x12,lsl#3]
 add w9,w9,#1
 cmp w9,w23
 b.ls .Lospectral_GMR_diagonal
 add x14,x26,x25,lsl#3
 mov w9,w8
.Lospectral_GMR_offdiagonal:
 cmp w9,w23
 b.hs .Lospectral_GMR_last
 add w12,w9,#1
 ldr d0,[x13,x12,lsl#3]
 fmul d0,d27,d0
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x14,x12,lsl#3]
 add w9,w9,#1
 b .Lospectral_GMR_offdiagonal
.Lospectral_GMR_last:
 sub w12,w23,w8
 add w12,w12,w11
 str xzr,[x14,x12,lsl#3]
 add w10,w10,#1
 cmp w10,w24
 b.lo .Lospectral_first_column
 /* SUSMAP then SUGMRE: repeat source coefficient setup and recurrence. */
 fdiv d0,d20,d25
 fadd d0,d25,d0
 fmul d26,d21,d0
 fdiv d0,d20,d25
 fsub d0,d25,d0
 fmul d27,d21,d0
 fmul d28,d26,d26
 fmul d29,d27,d27
 fmul d0,d22,d26
 fmul d30,d0,d27
 mov w10,#0
.Lospectral_second_column:
 ldr w8,[x21,x10,lsl#2]
 ldr w11,[x22,x10,lsl#2]
 bl .Lospectral_recurrence
 mov w9,w8
.Lospectral_squared_diagonal:
 ldr d0,[x13,x9,lsl#3]
 add w12,w9,#1
 ldr d1,[x13,x12,lsl#3]
 fmul d0,d0,d0
 fmul d1,d1,d1
 fadd d0,d0,d1
 fmul d0,d29,d0
 fadd d0,d28,d0
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x28,x12,lsl#3]
 add w9,w9,#1
 cmp w9,w23
 b.ls .Lospectral_squared_diagonal
 add x14,x28,x25,lsl#3
 mov w9,w8
.Lospectral_squared_first:
 cmp w9,w23
 b.hs .Lospectral_squared_first_last
 add w12,w9,#1
 ldr d0,[x13,x12,lsl#3]
 fmul d0,d30,d0
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x14,x12,lsl#3]
 add w9,w9,#1
 b .Lospectral_squared_first
.Lospectral_squared_first_last:
 sub w12,w23,w8
 add w12,w12,w11
 str xzr,[x14,x12,lsl#3]
 add x14,x14,x25,lsl#3
 mov w9,w8
 sub w15,w23,#1
.Lospectral_squared_second:
 cmp w9,w15
 b.hs .Lospectral_squared_second_last
 add w12,w9,#1
 ldr d0,[x13,x12,lsl#3]
 add w12,w9,#2
 ldr d1,[x13,x12,lsl#3]
 fmul d0,d29,d0
 fmul d0,d0,d1
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x14,x12,lsl#3]
 add w9,w9,#1
 b .Lospectral_squared_second
.Lospectral_squared_second_last:
 /* Source JN=N-1,N includes the preceding column boundary for m=N. */
 sub w12,w15,w8
 add w12,w12,w11
 str xzr,[x14,x12,lsl#3]
 add w12,w12,#1
 str xzr,[x14,x12,lsl#3]
 add w10,w10,#1
 cmp w10,w24
 b.lo .Lospectral_second_column
 mov w0,#0
 b .Lospectral_return
.Lospectral_second_failed:
 mov x0,x26
 bl free
.Lospectral_alloc_failed:
 mov w0,#1
.Lospectral_return:
 ldr w9,[sp,#120]
 str w9,[x27]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 mov x9,#10384
 add sp,sp,x9
 ret
.Lospectral_reject:
 mov w0,#2
 ret
/* Private descriptor leaf: x8 destination,x0 base,x1 planes,x25 NSPEC. */
.Lospectral_descriptor:
 str x0,[x8]
 neg x9,x25
 sub x9,x9,#1
 str x9,[x8,#8]
 mov x9,#8
 str x9,[x8,#16]
 str x9,[x8,#32]
 mov x9,#0x302
 lsl x9,x9,#32
 str x9,[x8,#24]
 mov x9,#1
 stp x9,x9,[x8,#40]
 stp x25,x25,[x8,#56]
 stp x9,x1,[x8,#72]
 ret
/* Private source recurrence leaf: w8 m,w23 N,x13 scratch; no saved state. */
.Lospectral_recurrence:
 add x13,sp,#128
 mul w12,w8,w8
 scvtf d3,w12
 mov w9,w8
 add w15,w23,#2
.Lospectral_recurrence_loop:
 mul w12,w9,w9
 scvtf d1,w12
 fsub d0,d1,d3
 fmul d2,d23,d1
 fsub d2,d2,d20
 fdiv d0,d0,d2
 fmaxnm d0,d24,d0
 fsqrt d0,d0
 str d0,[x13,x9,lsl#3]
 add w9,w9,#1
 cmp w9,w15
 b.ls .Lospectral_recurrence_loop
 ret
.size md2asm_initialize_distributed_spectral_geometry_maps,.-md2asm_initialize_distributed_spectral_geometry_maps
.p2align 4

.section .note.GNU-stack,"",%progbits
