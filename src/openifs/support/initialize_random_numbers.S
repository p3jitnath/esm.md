/* Complete random_numbers_mix::initialize_random_numbers numerical body.
 * Physics: formulations/openifs/support/random_stream.md.
 * Contract: skills/md2asm/references/openifs/support/random_stream.md.
 * x0 addresses an unchanged four-byte signed seed.
 * x1 addresses the disjoint mutable 2448-byte stream.
 * An 8016-byte aligned frame owns all 999 warm-up FP64 outputs.
 * Only x29 and x30 need saving. Stream padding remains unchanged. */
#ifndef INITIALIZE_SYMBOL
#define INITIALIZE_SYMBOL __random_numbers_mix_MOD_initialize_random_numbers
#endif
.text
.p2align 2
.global INITIALIZE_SYMBOL
.type INITIALIZE_SYMBOL,%function
INITIALIZE_SYMBOL:
    mov x9,#8016
    sub sp,sp,x9
    stp x29,x30,[sp]
    mov x29,sp
    mov x3,x1
    ldr w0,[x0]
    mov w7,#0xd924
    movk w7,#0x075b,lsl #16     /* Seed mask 123459876. */
    eor w0,w0,w7
    cmp w0,#0
    cneg w0,w0,lt              /* Original signed ABS after XOR. */
    cmp w0,#0
    csel w0,w0,w7,ne
    mov w8,#175                /* Polynomial feedback after the shift. */
    adr x10,.Lseed_feedback_four
    mov w4,#16
.Lseed_warmup:
    lsr w2,w0,#28
    ldr w2,[x10,w2,uxtw #2]
    eor w0,w2,w0,lsl #4
    subs w4,w4,#1
    b.ne .Lseed_warmup
    add x5,x3,#8
    mov w4,#151
.Lclear_state:
    stp xzr,xzr,[x5],#16
    subs w4,w4,#1
    b.ne .Lclear_state
    str xzr,[x5]               /* Last two of exactly 606 words. */
    and w2,w0,#0x1fffffff
    lsl w2,w2,#1
    str w2,[x3,#12]            /* Canonical integer 2. */
    lsr w2,w0,#29
    str w2,[x3,#2432]          /* Canonical integer 607. */

    adr x11,.Lseed_lane_shifts
    ldr q2,[x11]
    mov w4,#1
    mov w9,#2
.Lseed_bit:
    add x5,x3,#16              /* Integer 3. */
    mov w6,#151
    dup v1.4s,w9
.Lseed_integer:
    dup v0.4s,w0
    ushl v0.4s,v0.4s,v2.4s
    sshr v0.4s,v0.4s,#31       /* Four consecutive outgoing bits become masks. */
    and v0.16b,v0.16b,v1.16b
    ldr q3,[x5]
    orr v3.16b,v3.16b,v0.16b
    str q3,[x5],#16
    lsr w2,w0,#28
    ldr w2,[x10,w2,uxtw #2]
    eor w0,w2,w0,lsl #4        /* Exact four-step polynomial transition. */
    subs w6,w6,#1
    b.ne .Lseed_integer
    lsl w9,w9,#1
    add w4,w4,#1
    cmp w4,#30
    b.ne .Lseed_bit

    ldr w2,[x3,#2012]          /* Integer 502 is the single odd seed. */
    orr w2,w2,#1
    str w2,[x3,#2012]
    mov w2,#607
    str w2,[x3]
    mov w2,#0x614e
    movk w2,#0x00bc,lsl #16    /* Initialization marker 12345678. */
    str w2,[x3,#4]
    movz x2,#0x3e10,lsl #48
    fmov d0,x2
    str d0,[x3,#2440]          /* Exactly 2^-30. */

    mov x0,#999
    add x1,sp,#16
    mov x2,#8
    bl md2asm_random_uniform_flat
    ldp x29,x30,[sp]
    mov x9,#8016
    add sp,sp,x9
    ret
.size INITIALIZE_SYMBOL,.-INITIALIZE_SYMBOL
.p2align 4
.Lseed_lane_shifts:
    .word 0,1,2,3
.Lseed_feedback_four:
    .word 0,175,350,497,700,531,994,845,1400,1495,1062,1161,1988,1899,1690,1589
.section .note.GNU-stack,"",%progbits
