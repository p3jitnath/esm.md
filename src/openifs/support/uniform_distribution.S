/* Complete random_numbers_mix::uniform_distribution numerical body.
 * Physics: formulations/openifs/support/random_stream.md.
 * Contract: skills/md2asm/references/openifs/support/random_stream.md.
 * x0 is a 64-byte GNU rank-one FP64 descriptor, x1 a 2448-byte stream.
 * Output elements are disjoint from the stream. Only caller-saved
 * registers are used. Every selected element is written exactly once. */
#ifndef UNIFORM_SYMBOL
#define UNIFORM_SYMBOL __random_numbers_mix_MOD_uniform_distribution
#endif
.text
.p2align 2
.global UNIFORM_SYMBOL
.type UNIFORM_SYMBOL,%function
UNIFORM_SYMBOL:
    ldr x6,[x0]                 /* First selected output element. */
    ldp x2,x4,[x0,#40]          /* Element stride and lower bound. */
    ldr x5,[x0,#56]
    sub x5,x5,x4
    add x5,x5,#1
    cmp x5,#0
    b.le .Luniform_empty
    cmp x2,#0
    csinc x2,x2,xzr,ne          /* GNU zero stride denotes one. */
    lsl x2,x2,#3                /* Convert elements to bytes. */
    mov x3,x1
    mov x1,x6
    mov x0,x5
    b md2asm_random_uniform_flat
.Luniform_empty:
    ret
.size UNIFORM_SYMBOL,.-UNIFORM_SYMBOL

/* Internal complete sequence consumer.
 * x0 count, x1 first output, x2 signed byte stride, x3 stream.
 * It is shared with initialization's warm-up and cannot be interposed. */
.global md2asm_random_uniform_flat
.hidden md2asm_random_uniform_flat
.type md2asm_random_uniform_flat,%function
md2asm_random_uniform_flat:
    cbz x0,.Lflat_empty
    add x4,x3,#8                /* Integer array starts after two counts. */
    ldr w5,[x3]
    ldr d1,[x3,#2440]           /* Exact 2^-30 conversion scale. */
.Lconsume:
    mov w6,#607
    sub w6,w6,w5
    cmp x6,x0
    csel x6,x6,x0,lo
    cbz x6,.Lrefill
    add x7,x4,w5,uxtw #2
.Lsample:
    ldr w8,[x7],#4
    scvtf d0,w8
    fmul d0,d0,d1               /* P02, one exact multiplication. */
    str d0,[x1]
    add x1,x1,x2
    add w5,w5,#1
    sub x0,x0,#1
    subs x6,x6,#1
    b.ne .Lsample
    cbnz x0,.Lrefill
    str w5,[x3]
.Lflat_empty:
    ret
.Lrefill:
    mov x7,x4
    add x10,x4,#1336            /* Old array position 335. */
    mov w9,#273
.Lfirst_lag:
    ldr w8,[x7]
    ldr w11,[x10],#4
    add w8,w8,w11
    and w8,w8,#0x3fffffff
    str w8,[x7],#4
    subs w9,w9,#1
    b.ne .Lfirst_lag
    mov x10,x4                 /* The rounded integer predecessor. */
    mov w9,#334
.Lsecond_lag:
    ldr w8,[x7]
    ldr w11,[x10],#4
    add w8,w8,w11
    and w8,w8,#0x3fffffff
    str w8,[x7],#4
    subs w9,w9,#1
    b.ne .Lsecond_lag
    mov w5,#0
    b .Lconsume
.size md2asm_random_uniform_flat,.-md2asm_random_uniform_flat
.section .note.GNU-stack,"",%progbits
