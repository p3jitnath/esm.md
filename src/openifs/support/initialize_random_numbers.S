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
    adr x11,.Lseed_lane_shifts_eight
    ldr q5,[x11]
    adr x11,.Lseed_lane_shifts_sixteen
    ldp q16,q17,[x11]
    adr x12,.Lseed_feedback_eight
    mov w4,#1
    mov w9,#2
.Lseed_bit:
    add x5,x3,#16
    mov w6,#37
    dup v1.4s,w9
.Lseed_sixteen_integers:
    dup v0.4s,w0
    ushl v4.4s,v0.4s,v5.4s
    ushl v18.4s,v0.4s,v16.4s
    ushl v19.4s,v0.4s,v17.4s
    ushl v0.4s,v0.4s,v2.4s
    sshr v0.4s,v0.4s,#31
    sshr v4.4s,v4.4s,#31
    sshr v18.4s,v18.4s,#31
    sshr v19.4s,v19.4s,#31
    and v0.16b,v0.16b,v1.16b
    and v4.16b,v4.16b,v1.16b
    and v18.16b,v18.16b,v1.16b
    and v19.16b,v19.16b,v1.16b
    ldp q3,q6,[x5]
    ldp q20,q21,[x5,#32]
    orr v3.16b,v3.16b,v0.16b
    orr v6.16b,v6.16b,v4.16b
    orr v20.16b,v20.16b,v18.16b
    orr v21.16b,v21.16b,v19.16b
    stp q3,q6,[x5],#32
    stp q20,q21,[x5],#32
    lsr w2,w0,#24
    ubfx w7,w0,#16,#8
    ldr w2,[x12,w2,uxtw #2]
    ldr w7,[x12,w7,uxtw #2]
    eor w0,w7,w0,lsl #16
    eor w0,w0,w2,lsl #8
    subs w6,w6,#1
    b.ne .Lseed_sixteen_integers
    /* Eight final integers retain the qualified eight-step update. */
    dup v0.4s,w0
    ushl v4.4s,v0.4s,v5.4s
    ushl v0.4s,v0.4s,v2.4s
    sshr v0.4s,v0.4s,#31
    sshr v4.4s,v4.4s,#31
    and v0.16b,v0.16b,v1.16b
    and v4.16b,v4.16b,v1.16b
    ldp q3,q6,[x5]
    orr v3.16b,v3.16b,v0.16b
    orr v6.16b,v6.16b,v4.16b
    stp q3,q6,[x5],#32
    lsr w2,w0,#24
    ldr w2,[x12,w2,uxtw #2]
    eor w0,w2,w0,lsl #8
    /* Four final integers retain the original four-step update. */
    dup v0.4s,w0
    ushl v0.4s,v0.4s,v2.4s
    sshr v0.4s,v0.4s,#31
    and v0.16b,v0.16b,v1.16b
    ldr q3,[x5]
    orr v3.16b,v3.16b,v0.16b
    str q3,[x5]
    lsr w2,w0,#28
    ldr w2,[x10,w2,uxtw #2]
    eor w0,w2,w0,lsl #4
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
.Lseed_lane_shifts_eight:
    .word 4,5,6,7
.Lseed_lane_shifts_sixteen:
    .word 8,9,10,11,12,13,14,15
.Lseed_feedback_four:
    .word 0,175,350,497,700,531,994,845,1400,1495,1062,1161,1988,1899,1690,1589
.p2align 4
.Lseed_feedback_eight:
    .word 0,175,350,497,700,531,994,845
    .word 1400,1495,1062,1161,1988,1899,1690,1589
    .word 2800,2655,2990,2817,2124,2275,2322,2493
    .word 3976,3879,3798,3705,3380,3483,3178,3269
    .word 5600,5455,5310,5137,5980,6131,5634,5805
    .word 4248,4151,4550,4457,4644,4747,4986,5077
    .word 7952,8127,7758,7905,7596,7427,7410,7261
    .word 6760,6855,6966,7065,6356,6267,6538,6437
    .word 11200,11119,10910,10801,10620,10707,10274,10381
    .word 11960,11799,12262,12105,11268,11435,11610,11765
    .word 8496,8607,8302,8385,9100,8995,8914,8829
    .word 9288,9447,9494,9657,9972,9819,10154,9989
    .word 15904,16015,16254,16337,15516,15411,15810,15725
    .word 15192,15351,14854,15017,14820,14667,14522,14357
    .word 13520,13439,13710,13601,13932,14019,14130,14237
    .word 12712,12551,12534,12377,13076,13243,12874,13029
    .word 22400,22319,22238,22129,21820,21907,21602,21709
    .word 21240,21079,21414,21257,20548,20715,20762,20917
    .word 23920,24031,23598,23681,24524,24419,24210,24125
    .word 22536,22695,22870,23033,23220,23067,23530,23365
    .word 16992,17103,17214,17297,16604,16499,16770,16685
    .word 18200,18359,17990,18153,17828,17675,17658,17493
    .word 18576,18495,18894,18785,18988,19075,19314,19421
    .word 19944,19783,19638,19481,20308,20475,19978,20133
    .word 31808,31983,32030,32177,32508,32339,32674,32525
    .word 31032,31127,30822,30921,31620,31531,31450,31349
    .word 30384,30239,30702,30529,29708,29859,30034,30205
    .word 29640,29543,29334,29241,29044,29147,28714,28805
    .word 27040,26895,26878,26705,27420,27571,27202,27373
    .word 27864,27767,28038,27945,28260,28363,28474,28565
    .word 25424,25599,25102,25249,25068,24899,24754,24605
    .word 26152,26247,26486,26585,25748,25659,26058,25957
.section .note.GNU-stack,"",%progbits
