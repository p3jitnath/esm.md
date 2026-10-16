/* Complete selected serial SUMPFPOS, retaining all unrelated TFPGEO bytes.
 * x0 controls16 {N,NPROC=1,MYPROC=1,KPROMA},x1 ranks[N],x2 TFPGEO848,x3 cap.
 * Return0 ready,1 cleaned allocation failure,2 unchanged rejection.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_distribution
.type md2asm_initialize_selected_fullpos_distribution,%function
md2asm_initialize_selected_fullpos_distribution:
 cmp x3,#848
 b.lo .Ldist_bad
 cbz x0,.Ldist_bad
 cbz x1,.Ldist_bad
 cbz x2,.Ldist_bad
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Ldist_bad
 adds x9,x0,#16
 b.cs .Ldist_bad
 adds x10,x2,#848
 b.cs .Ldist_bad
 cmp x0,x10
 b.hs .Ldist_controls_disjoint
 cmp x2,x9
 b.lo .Ldist_bad
.Ldist_controls_disjoint:
 mrs x11,fpcr
 cbnz x11,.Ldist_bad
 ldr w11,[x0]
 sub w12,w11,#1
 cmp w12,#4095
 b.hi .Ldist_bad
 ldr w12,[x0,#4]
 cmp w12,#1
 b.ne .Ldist_bad
 ldr w12,[x0,#8]
 cmp w12,#1
 b.ne .Ldist_bad
 ldr w12,[x0,#12]
 cbz w12,.Ldist_bad
 cmp w12,#0
 cneg w12,w12,lt
 cmp w12,#4096
 b.hi .Ldist_bad
 lsl x12,x11,#2
 adds x12,x1,x12
 b.cs .Ldist_bad
 cmp x1,x10
 b.hs .Ldist_ranks_output_disjoint
 cmp x2,x12
 b.lo .Ldist_bad
.Ldist_ranks_output_disjoint:
 cmp x0,x12
 b.hs .Ldist_ranks_control_disjoint
 cmp x1,x9
 b.lo .Ldist_bad
.Ldist_ranks_control_disjoint:
 ldr x9,[x2,#24]
 cbnz x9,.Ldist_bad
 ldr x9,[x2,#88]
 cbnz x9,.Ldist_bad
 ldr x9,[x2,#152]
 cbnz x9,.Ldist_bad
 mov x9,#0
.Ldist_ranks:
 ldr w10,[x1,x9,lsl #2]
 cmp w10,#1
 b.ne .Ldist_bad
 add x9,x9,#1
 cmp x9,x11
 b.lo .Ldist_ranks
 sub sp,sp,#448
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x18,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov w22,w11
 ldr w23,[x19,#12]
 cmp w23,#0
 b.lt .Ldist_negative_proma
 and w9,w23,#1
 add w23,w23,#1
 sub w23,w23,w9
 b .Ldist_clamp_proma
.Ldist_negative_proma:
 neg w23,w23
.Ldist_clamp_proma:
 cmp w23,w22
 csel w23,w22,w23,gt
 mov w9,#1
 cmp w23,#1
 csel w23,w23,w9,gt
 sub w24,w22,#1
 udiv w24,w24,w23
 add w24,w24,#1
 str xzr,[sp,#176]
 str xzr,[sp,#240]
 str xzr,[sp,#328]
 add x0,sp,#176
 mov w1,#1
 mov w2,#1
 mov w3,#1
 bl .Ldist_allocate_integer
 cbnz w0,.Ldist_failure
 ldr x9,[sp,#176]
 str w22,[x9]
 add x0,sp,#240
 mov w1,#2
 mov w2,w22
 mov w3,#1
 bl .Ldist_allocate_integer
 cbnz w0,.Ldist_failure
 ldr x9,[sp,#240]
 mov w10,#1
.Ldist_indices:
 str w10,[x9],#4
 add w10,w10,#1
 cmp w10,w22
 b.ls .Ldist_indices
 add x0,sp,#328
 mov w1,#1
 mov w2,w24
 mov w3,#1
 bl .Ldist_allocate_integer
 cbnz w0,.Ldist_failure
 ldr x9,[sp,#328]
 mov w10,#1
.Ldist_ends:
 cmp w10,w24
 b.hs .Ldist_last_end
 str w23,[x9],#4
 add w10,w10,#1
 b .Ldist_ends
.Ldist_last_end:
 sub w10,w24,#1
 msub w10,w23,w10,w22
 str w10,[x9]
 /* Commit complete source descriptors after all three owners are ready. */
 add x9,sp,#176
 add x10,x21,#88
 mov x11,#64
 bl .Ldist_copy
 add x9,sp,#240
 add x10,x21,#152
 mov x11,#88
 bl .Ldist_copy
 add x9,sp,#328
 add x10,x21,#24
 mov x11,#64
 bl .Ldist_copy
 stp w22,w22,[x21,#4]
 stp w23,w24,[x21,#12]
 mov w0,#0
 b .Ldist_return
.Ldist_failure:
 mov x25,#0
 adrp x26,.Ldist_private_offsets
 add x26,x26,:lo12:.Ldist_private_offsets
.Ldist_failure_loop:
 ldr w9,[x26,x25,lsl #2]
 add x9,sp,x9
 ldr x0,[x9]
 cbz x0,.Ldist_failure_next
 bl free
 ldr x18,[sp,#88]
.Ldist_failure_next:
 add x25,x25,#1
 cmp x25,#3
 b.lo .Ldist_failure_loop
 mov w0,#1
.Ldist_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x18,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#448
 ret
.Ldist_copy:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#8
 b.ne .Ldist_copy
 ret
.Ldist_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_fullpos_distribution,.-md2asm_initialize_selected_fullpos_distribution
/* The accepted partition allocator's integer descriptor mechanism, local only.
 * x0 descriptor,w1 rank1/2,w2 first extent,w3 second extent, all positive. */
.Ldist_allocate_integer:
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 mov w20,w1
 mov w21,w2
 mov w22,w3
 mul x0,x21,x22
 lsl x0,x0,#2
 bl malloc
 ldr x18,[sp,#56]
 cbz x0,.Ldist_allocate_failed
 str x0,[x19]
 mov x9,#-1
 sub x10,x9,x21
 cmp w20,#2
 csel x9,x10,x9,eq
 str x9,[x19,#8]
 mov x9,#4
 str x9,[x19,#16]
 str x9,[x19,#32]
 mov w10,#0x100
 orr w10,w10,w20
 lsl x10,x10,#32
 str x10,[x19,#24]
 mov x9,#1
 stp x9,x9,[x19,#40]
 str x21,[x19,#56]
 cmp w20,#2
 b.ne .Ldist_allocate_ready
 stp x21,x9,[x19,#64]
 str x22,[x19,#80]
.Ldist_allocate_ready:
 mov w0,#0
 b .Ldist_allocate_return
.Ldist_allocate_failed:
 mov w0,#1
.Ldist_allocate_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp],#64
 ret
.p2align 4
.global md2asm_release_selected_fullpos_distribution
.type md2asm_release_selected_fullpos_distribution,%function
md2asm_release_selected_fullpos_distribution:
 cmp x1,#848
 b.lo .Ldist_bad
 cbz x0,.Ldist_bad
 tst x0,#7
 b.ne .Ldist_bad
 adds x9,x0,#848
 b.cs .Ldist_bad
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov x20,#0
 adrp x21,.Ldist_public_offsets
 add x21,x21,:lo12:.Ldist_public_offsets
.Ldist_release_loop:
 ldr w9,[x21,x20,lsl #2]
 ldr x0,[x19,x9]
 cbz x0,.Ldist_release_next
 bl free
 ldr x18,[sp,#40]
 ldr w9,[x21,x20,lsl #2]
 str xzr,[x19,x9]
.Ldist_release_next:
 add x20,x20,#1
 cmp x20,#3
 b.lo .Ldist_release_loop
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_selected_fullpos_distribution,.-md2asm_release_selected_fullpos_distribution
.section .rodata
.p2align 2
.Ldist_private_offsets:.word 176,240,328
.Ldist_public_offsets:.word 88,152,24
.section .note.GNU-stack,"",%progbits
