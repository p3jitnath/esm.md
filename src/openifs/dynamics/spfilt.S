/* Private ldp19 complete SPFILT trial; immutable first release is unchanged.
 * Use the cache for NSMAX=21 and at least 24 selected columns.
 * The full ordered factor arithmetic runs at each degree's first occurrence.
 * Later occurrences reuse those exact FP64 bits. Factors stay in [1/1025,1],
 * so zero marks an unused slot. Each factor retains its original rounding.
 * The original general body handles all other supported shapes.
 * x0 geometry, x1 first column, x2 last column, x3 vorticity descriptor,
 * x4 divergence descriptor. Only selected vorticity cells can change.
 * Signed element strides and all original buffer bounds remain supported.
 * Cache path: 272-byte aligned frame, including 22 private FP64 slots.
 * Preserve x19-x29, d8-d15, x18 and FPCR. exp is the frozen scalar dependency. */
#ifndef SPFILT_ENTRY
#define SPFILT_ENTRY spfilt_
#endif
#ifndef SPFILT_CACHE_MIN
#define SPFILT_CACHE_MIN 24
#endif
.text
.p2align 4
.global SPFILT_ENTRY
.type SPFILT_ENTRY,%function
SPFILT_ENTRY:
    ldr w9,[x0,#5172]
    cmp w9,#21
    b.ne spfilt_cache_general_
    ldr w10,[x1]
    ldr w11,[x2]
    sub w12,w11,w10
    cmp w12,#(SPFILT_CACHE_MIN-1)
    b.lt spfilt_cache_general_
    mrs x9,fpcr
    cbnz x9,.Lcache_bad_fpcr
    sub sp,sp,#272
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    add x29,sp,#96
    stp xzr,xzr,[x29]
    stp xzr,xzr,[x29,#16]
    stp xzr,xzr,[x29,#32]
    stp xzr,xzr,[x29,#48]
    stp xzr,xzr,[x29,#64]
    stp xzr,xzr,[x29,#80]
    stp xzr,xzr,[x29,#96]
    stp xzr,xzr,[x29,#112]
    stp xzr,xzr,[x29,#128]
    stp xzr,xzr,[x29,#144]
    stp xzr,xzr,[x29,#160]
    ldr w23,[x0,#5172]
    ldr w28,[x0,#5228]
    ldr w26,[x1]
    ldr w27,[x2]
    lsl w9,w23,#1
    scvtf d0,w9
    fmov d1,#3.0
    fdiv d0,d0,d1
    fcvtas w24,d0
    sub w24,w24,#1
    scvtf d0,w23
    ldr d1,.Lcache_083
    fmul d0,d0,d1
    fcvtas w25,d0
    sub w25,w25,w24
    ldr x19,[x3]
    ldr x20,[x3,#40]
    ldr x21,[x3,#64]
    lsl x20,x20,#3
    lsl x21,x21,#3
    sub w9,w26,#1
    sxtw x9,w9
    mul x9,x9,x21
    add x19,x19,x9
    add x9,x0,#3848
    ldr x22,[x9]
    ldr x10,[x9,#48]
    sxtw x11,w26
    sub x10,x11,x10
    add x22,x22,x10,lsl #2
    cmp w28,#19
    b.ne .Lfield_gate_done
    cmp x20,#8
    b.ne .Lfield_gate_done
    orr w28,w28,#0x80000000
.Lfield_gate_done:
.Lcache_column:
    ldr w9,[x22]
    ldr d0,[x29,w9,uxtw #3]
    fmov x10,d0
    cbnz x10,.Lcache_apply
    add w9,w9,w25
    cmp w9,w24
    b.le .Lcache_unfiltered
    sub w10,w9,w23
    sub w11,w9,w24
    scvtf d0,w10
    scvtf d1,w11
    fmul d0,d0,d0
    fmul d1,d1,d1
    fmov d2,#-0.5
    fmul d0,d0,d2
    fdiv d0,d0,d1
    bl exp
    ldr d1,.Lcache_32
    fmul d0,d0,d1
    b .Lcache_factor
.Lcache_unfiltered:
    fmov d0,xzr
.Lcache_factor:
    fmul d0,d0,d0
    fmov d1,#1.0
    fadd d0,d1,d0
    fdiv d0,d1,d0
    ldr w9,[x22]
    str d0,[x29,w9,uxtw #3]
.Lcache_apply:
    tbnz w28,#31,.Lfield_unroll19
    mov w9,w28
    mov x10,x19
    cbz w9,.Lcache_next
    cmp x20,#8
    b.ne .Lcache_strided
    dup v0.2d,v0.d[0]
    cmp w9,#2
    b.lt .Lcache_tail
.Lcache_pair:
    ldr q1,[x10]
    fmul v1.2d,v1.2d,v0.2d
    str q1,[x10],#16
    sub w9,w9,#2
    cmp w9,#2
    b.ge .Lcache_pair
.Lcache_tail:
    cbz w9,.Lcache_next
    ldr d1,[x10]
    fmul d1,d1,d0
    str d1,[x10]
    b .Lcache_next
.Lcache_strided:
    ldr d1,[x10]
    fmul d1,d1,d0
    str d1,[x10]
    add x10,x10,x20
    subs w9,w9,#1
    b.ne .Lcache_strided
    b .Lcache_next
.Lfield_unroll19:
    dup v0.2d,v0.d[0]
    ldp q1,q2,[x19]
    ldp q3,q4,[x19,#32]
    ldp q5,q6,[x19,#64]
    ldp q7,q16,[x19,#96]
    ldr q17,[x19,#128]
    ldr d18,[x19,#144]
    fmul v1.2d,v1.2d,v0.2d
    fmul v2.2d,v2.2d,v0.2d
    fmul v3.2d,v3.2d,v0.2d
    fmul v4.2d,v4.2d,v0.2d
    fmul v5.2d,v5.2d,v0.2d
    fmul v6.2d,v6.2d,v0.2d
    fmul v7.2d,v7.2d,v0.2d
    fmul v16.2d,v16.2d,v0.2d
    fmul v17.2d,v17.2d,v0.2d
    fmul d18,d18,d0
    stp q1,q2,[x19]
    stp q3,q4,[x19,#32]
    stp q5,q6,[x19,#64]
    stp q7,q16,[x19,#96]
    str q17,[x19,#128]
    str d18,[x19,#144]
.Lcache_next:
    cmp w26,w27
    b.eq .Lcache_return
    add w26,w26,#1
    add x19,x19,x21
    add x22,x22,#4
    b .Lcache_column
.Lcache_return:
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#272
    ret
.Lcache_bad_fpcr:
    brk #0x5f1
.size SPFILT_ENTRY,.-SPFILT_ENTRY
.p2align 3
.Lcache_083:
    .quad 0x3fea8f5c28f5c28f
.Lcache_32:
    .quad 0x4040000000000000
/* The original general body below is copied verbatim, except its private name. */
#undef SPFILT_ENTRY
#define SPFILT_ENTRY spfilt_cache_general_
.hidden spfilt_cache_general_
/* Complete SPFILT revision 1.0, derived from its frozen filter equations.
 * x0 geometry, x1 first column, x2 last column, x3 vorticity descriptor,
 * x4 divergence descriptor. Only selected vorticity cells can change.
 * Geometry and rank-two buffer bounds are defined in skills/md2asm/references/openifs/dynamics/spfilt.md.
 * Preserve x19-x29, d8-d15, x18 and FPCR; stack alignment is 16 bytes.
 * exp is the frozen external scalar dependency, not a driver stage. */
#ifndef SPFILT_ENTRY
#define SPFILT_ENTRY spfilt_
#endif
.text
.p2align 4
.global SPFILT_ENTRY
.type SPFILT_ENTRY,%function
SPFILT_ENTRY:
    mrs x9,fpcr
    cbnz x9,.Lspfilt_bad_fpcr
    sub sp,sp,#96
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    ldr w23,[x0,#5172]
    ldr w28,[x0,#5228]
    ldr w26,[x1]
    ldr w27,[x2]
    lsl w9,w23,#1
    scvtf d0,w9
    fmov d1,#3.0
    fdiv d0,d0,d1
    fcvtas w24,d0
    sub w24,w24,#1
    scvtf d0,w23
    ldr d1,.Lspfilt_083
    fmul d0,d0,d1
    fcvtas w25,d0
    sub w25,w25,w24
    cmp w26,w27
    b.gt .Lspfilt_return
    ldr x19,[x3]
    ldr x20,[x3,#40]
    ldr x21,[x3,#64]
    lsl x20,x20,#3
    lsl x21,x21,#3
    sub w9,w26,#1
    sxtw x9,w9
    mul x9,x9,x21
    add x19,x19,x9
    add x9,x0,#3848
    ldr x22,[x9]
    ldr x10,[x9,#48]
    sxtw x11,w26
    sub x10,x11,x10
    add x22,x22,x10,lsl #2
.Lspfilt_column:
    ldr w9,[x22]
    add w9,w9,w25
    cmp w9,w24
    b.le .Lspfilt_unfiltered
    sub w10,w9,w23
    sub w11,w9,w24
    scvtf d0,w10
    scvtf d1,w11
    fmul d0,d0,d0
    fmul d1,d1,d1
    fmov d2,#-0.5
    fmul d0,d0,d2
    fdiv d0,d0,d1
    bl exp
    ldr d1,.Lspfilt_32
    fmul d0,d0,d1
    b .Lspfilt_factor
.Lspfilt_unfiltered:
    fmov d0,xzr
.Lspfilt_factor:
    fmul d0,d0,d0
    fmov d1,#1.0
    fadd d0,d1,d0
    fdiv d0,d1,d0
    mov w9,w28
    mov x10,x19
    cbz w9,.Lspfilt_next
    cmp x20,#8
    b.ne .Lspfilt_strided
    dup v0.2d,v0.d[0]
    cmp w9,#2
    b.lt .Lspfilt_tail
.Lspfilt_pair:
    ldr q1,[x10]
    fmul v1.2d,v1.2d,v0.2d
    str q1,[x10],#16
    sub w9,w9,#2
    cmp w9,#2
    b.ge .Lspfilt_pair
.Lspfilt_tail:
    cbz w9,.Lspfilt_next
    ldr d1,[x10]
    fmul d1,d1,d0
    str d1,[x10]
    b .Lspfilt_next
.Lspfilt_strided:
    ldr d1,[x10]
    fmul d1,d1,d0
    str d1,[x10]
    add x10,x10,x20
    subs w9,w9,#1
    b.ne .Lspfilt_strided
.Lspfilt_next:
    cmp w26,w27
    b.eq .Lspfilt_return
    add w26,w26,#1
    add x19,x19,x21
    add x22,x22,#4
    b .Lspfilt_column
.Lspfilt_return:
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#96
    ret
.Lspfilt_bad_fpcr:
    brk #0x5f1
.size SPFILT_ENTRY,.-SPFILT_ENTRY
.p2align 3
.Lspfilt_083:
    .quad 0x3fea8f5c28f5c28f
.Lspfilt_32:
    .quad 0x4040000000000000
.section .note.GNU-stack,"",%progbits
