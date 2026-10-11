/* Complete forecast-configured radiation_cloud_generator::cloud_generator.
 * Physics: formulations/openifs/physics/cloud_sampling.md.
 * Contract: skills/md2asm/references/openifs/physics/cloud_sampling.md.
 * Thirteen ordinary addresses. Exponential-random scheme one is admitted.
 * Every numerical child is directly bound within the assembled closure. */
#ifndef GENERATOR_SYMBOL
#define GENERATOR_SYMBOL __radiation_cloud_generator_MOD_cloud_generator
#endif
#ifndef GENERATOR_COVER_SYMBOL
#define GENERATOR_COVER_SYMBOL md2asm_generator_cover
#endif
#ifndef GENERATOR_INITIALIZE_SYMBOL
#define GENERATOR_INITIALIZE_SYMBOL md2asm_generator_initialize
#endif
#ifndef GENERATOR_UNIFORM_SYMBOL
#define GENERATOR_UNIFORM_SYMBOL md2asm_generator_uniform
#endif
#ifndef GENERATOR_COLUMN_SYMBOL
#define GENERATOR_COLUMN_SYMBOL md2asm_generator_column
#endif
.text
.p2align 2
.global GENERATOR_SYMBOL
.type GENERATOR_SYMBOL,%function
.hidden GENERATOR_COVER_SYMBOL
.hidden GENERATOR_INITIALIZE_SYMBOL
.hidden GENERATOR_UNIFORM_SYMBOL
.hidden GENERATOR_COLUMN_SYMBOL
GENERATOR_SYMBOL:
    mov x17,sp
    sub sp,sp,#2800
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x29,sp
    stp x0,x1,[x29,#96]
    stp x2,x3,[x29,#112]
    stp x4,x5,[x29,#128]
    stp x6,x7,[x29,#144]
    ldp x8,x9,[x17,#0]
    stp x8,x9,[x29,#160]
    ldp x8,x9,[x17,#16]
    stp x8,x9,[x29,#176]
    ldr x8,[x17,#32]
    str x8,[x29,#192]

    ldr w19,[x0]
    ldr w20,[x1]
    sub w8,w19,#1
    cmp w8,#4095
    b.hi .Lgenerator_reject
    sub w8,w20,#1
    cmp w8,#511
    b.hi .Lgenerator_reject
    ldr w8,[x2]
    cmp w8,#1
    b.ne .Lgenerator_reject
    mrs x8,fpcr
    cbnz x8,.Lgenerator_reject
    ldr d0,[x4]
    fcmp d0,#0.0
    b.le .Lgenerator_reject
    b.vs .Lgenerator_reject
    fmov d1,#1.0
    fcmp d0,d1
    b.gt .Lgenerator_reject
    ldr d0,[x7]
    fmov x9,d0
    ubfx x9,x9,#52,#11
    cmp x9,#2047
    b.eq .Lgenerator_reject
    fcmp d0,#0.0
    b.le .Lgenerator_reject
    b.vs .Lgenerator_reject
    fdiv d0,d1,d0
    fmov x8,d0
    ubfx x8,x8,#52,#11
    cmp x8,#2047
    b.eq .Lgenerator_reject

    lsl x8,x20,#5
    add x8,x8,x19,lsl #3
    add x8,x8,#63
    and x8,x8,#-16
    sub sp,sp,x8
    add x21,sp,#48
    str x21,[x29,#2744]
    add x22,x21,x20,lsl #3
    str x22,[x29,#2752]
    add x23,x22,x20,lsl #3
    str x23,[x29,#2760]
    add x24,x23,x20,lsl #3
    str x24,[x29,#2768]
    add x25,x24,x20,lsl #3
    str x25,[x29,#2776]
    ldr x0,[x29,#104]
    ldr x1,[x29,#136]
    ldr x2,[x29,#144]
    mov x3,x21
    mov x4,x22
    ldr x5,[x29,#192]
    bl GENERATOR_COVER_SYMBOL
    sub w8,w20,#1
    ldr d0,[x21,w8,uxtw #3]
    ldr x9,[x29,#184]
    str d0,[x9]
    mov w8,#0
.Lgenerator_overhang:
    sub w9,w20,#1
    cmp w8,w9
    b.ge .Lgenerator_threshold
    ldr d1,[x21,w8,uxtw #3]
    add w9,w8,#1
    ldr d2,[x21,w9,uxtw #3]
    fsub d1,d2,d1
    str d1,[x23,w8,uxtw #3]
    add w8,w8,#1
    b .Lgenerator_overhang
.Lgenerator_threshold:
    ldr x8,[x29,#128]
    ldr d1,[x8]
    fcmp d0,d1
    b.ge .Lgenerator_cloudy
    fmov d0,xzr
    ldr x8,[x29,#184]
    str d0,[x8]
    b .Lgenerator_done
.Lgenerator_cloudy:
    ldr x26,[x29,#136]
    mov w8,#0
.Lgenerator_first:
    ldr d0,[x26,w8,uxtw #3]
    fcmp d0,#0.0
    b.gt .Lgenerator_first_found
    add w8,w8,#1
    cmp w8,w20
    b.lt .Lgenerator_first
    b .Lgenerator_reject
.Lgenerator_first_found:
    add w9,w8,#1
    str w9,[x29,#2720]
    str w9,[x29,#2724]
    add w8,w8,#1
.Lgenerator_last:
    cmp w8,w20
    b.ge .Lgenerator_copy_overlap
    ldr d0,[x26,w8,uxtw #3]
    fcmp d0,#0.0
    b.le .Lgenerator_last_next
    add w9,w8,#1
    str w9,[x29,#2724]
.Lgenerator_last_next:
    add w8,w8,#1
    b .Lgenerator_last
.Lgenerator_copy_overlap:
    ldr x26,[x29,#144]
    sub w9,w20,#1
    mov w8,#0
.Lgenerator_copy_next:
    cmp w8,w9
    b.ge .Lgenerator_power_begin
    ldr d0,[x26,w8,uxtw #3]
    str d0,[x24,w8,uxtw #3]
    add w8,w8,#1
    b .Lgenerator_copy_next
.Lgenerator_power_begin:
    ldr w27,[x29,#2720]
    sub w27,w27,#1
    ldr w28,[x29,#2724]
    sub w28,w28,#1
.Lgenerator_power:
    cmp w27,w28
    b.ge .Lgenerator_zero_matrix
    ldr d0,[x26,w27,uxtw #3]
    fcmp d0,#0.0
    b.le .Lgenerator_power_next
    ldr x8,[x29,#152]
    ldr d1,[x8]
    fmov d2,#1.0
    fdiv d1,d2,d1
    bl md2asm_pow_original_rounding_candidate
    str d0,[x24,w27,uxtw #3]
.Lgenerator_power_next:
    add w27,w27,#1
    b .Lgenerator_power
.Lgenerator_zero_matrix:
    ldr x8,[x29,#176]
    mul x9,x19,x20
    movi v0.2d,#0
.Lgenerator_zero_pair:
    cmp x9,#2
    b.lo .Lgenerator_zero_tail
    str q0,[x8],#16
    sub x9,x9,#2
    b .Lgenerator_zero_pair
.Lgenerator_zero_tail:
    cbz x9,.Lgenerator_initialize
    str d0,[x8]
.Lgenerator_initialize:
    ldr x0,[x29,#120]
    add x1,x29,#272
    bl GENERATOR_INITIALIZE_SYMBOL
    add x0,x29,#208
    str x25,[x0]
    mov x8,#-1
    str x8,[x0,#8]
    mov x8,#8
    str x8,[x0,#16]
    str x8,[x0,#32]
    movz x8,#0x0301,lsl #32
    str x8,[x0,#24]
    mov x8,#1
    str x8,[x0,#40]
    str x8,[x0,#48]
    str x19,[x0,#56]
    add x1,x29,#272
    bl GENERATOR_UNIFORM_SYMBOL
    mov w27,#1
.Lgenerator_sample:
    cmp w27,w19
    b.gt .Lgenerator_done
    str w27,[x29,#2728]
    sub w8,w27,#1
    ldr d0,[x25,w8,uxtw #3]
    ldr x9,[x29,#184]
    ldr d1,[x9]
    fmul d0,d0,d1
    ldr w8,[x29,#2720]
    ldr w9,[x29,#2724]
.Lgenerator_top:
    sub w10,w8,#1
    ldr d1,[x21,w10,uxtw #3]
    fcmp d0,d1
    b.le .Lgenerator_top_found
    cmp w8,w9
    b.ge .Lgenerator_top_found
    add w8,w8,#1
    b .Lgenerator_top
.Lgenerator_top_found:
    str w8,[x29,#2732]
    ldr x0,[x29,#96]
    ldr x1,[x29,#104]
    add x2,x29,#2728
    add x3,x29,#272
    ldr x4,[x29,#168]
    ldr x5,[x29,#136]
    mov x6,x22
    mov x7,x21
    str x23,[sp,#0]
    ldr x8,[x29,#160]
    str x8,[sp,#8]
    str x24,[sp,#16]
    add x8,x29,#2732
    str x8,[sp,#24]
    add x8,x29,#2724
    str x8,[sp,#32]
    ldr x8,[x29,#176]
    str x8,[sp,#40]
    bl GENERATOR_COLUMN_SYMBOL
    add w27,w27,#1
    b .Lgenerator_sample
.Lgenerator_done:
    mov sp,x29
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#2800
    ret
.Lgenerator_reject:
    brk #0
.size GENERATOR_SYMBOL,.-GENERATOR_SYMBOL
.section .note.GNU-stack,"",%progbits
