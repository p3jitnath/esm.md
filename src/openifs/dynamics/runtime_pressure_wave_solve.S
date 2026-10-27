// Physics formulations/openifs/dynamics/spectral_semi_implicit_update.md.
// Contract skills/md2asm/references/openifs/dynamics/runtime_pressure_and_rotation.md.
#define PRESSURE_WAVE_INDEX_SLOT 488
#define PRESSURE_TIME_FACTOR_SQUARED_SLOT 472
/* Complete SPCIMPFSOLVE with live source maps and owned workspace.
 * Both exact copies and every coefficient stage are performed here.
 * The sole numerical helper is the complete verified SIMPLICO assembly.
 */
#ifndef RUNTIME_PRESSURE_ENTRY
#define RUNTIME_PRESSURE_ENTRY md2asm_runtime_pressure_wave_solve
#endif
.text
.p2align 4
.global RUNTIME_PRESSURE_ENTRY
.type RUNTIME_PRESSURE_ENTRY,%function
RUNTIME_PRESSURE_ENTRY:
    sub sp,sp,#1024
    stp x19,x20,[sp,#240]
    stp x21,x22,[sp,#256]
    stp x23,x24,[sp,#272]
    stp x25,x26,[sp,#288]
    stp x27,x28,[sp,#304]
    stp x29,x30,[sp,#320]
    stp d8,d9,[sp,#336]
    stp d10,d11,[sp,#352]
    stp d12,d13,[sp,#368]
    str x18,[sp,#744]
    ldr x9,[sp,#1024]
    str x9,[sp,#752]
    str x3,[sp,#720]
    str x4,[sp,#728]
    str x5,[sp,#736]
    mov x27,#0
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x6
    mov x23,x7
    ldrsw x24,[x19,#5172]
    ldrsw x25,[x19,#5228]
    ldrsw x26,[x19,#5200]

    /* Live source shape and explicit owned dependencies. */
    mrs x9,fpcr
    cbnz x9,.Lruntime_refuse
    cmp x24,#1
    b.lt .Lruntime_refuse
    cmp x24,#2,lsl #12
    b.hs .Lruntime_refuse
    ldr w9,[x19,#5224]
    sub w10,w9,#1
    cmp w10,#511
    b.hi .Lruntime_refuse
    cmp x25,#0
    b.lt .Lruntime_refuse
    cmp x25,x9
    b.gt .Lruntime_refuse
    ldr w10,[x19,#5236]
    cmp x25,x10
    b.ne .Lruntime_refuse
    cmp x26,#0
    b.lt .Lruntime_refuse
    add x10,x24,#1
    add x11,x24,#2
    mul x10,x10,x11
    cmp x26,x10
    b.gt .Lruntime_refuse
    ldr w9,[x19,#5212]
    str w9,[sp,#784]
    cmp w9,#0
    b.lt .Lruntime_refuse
    add x10,x24,#1
    cmp x9,x10
    b.gt .Lruntime_refuse
    ldr x9,[sp,#752]
    cbz x9,.Lruntime_refuse
    tst x9,#7
    b.ne .Lruntime_refuse
    ldr x10,[x9]
    cbz x10,.Lruntime_refuse
    tst x10,#7
    b.ne .Lruntime_refuse
    str x10,[sp,#760]
    ldr x11,[x10]
    cmp x11,x19
    b.ne .Lruntime_refuse
    ldr w11,[x10,#16]
    cmp w11,#7
    b.ne .Lruntime_refuse
    ldr x10,[x9,#8]
    cbz x10,.Lruntime_refuse
    tst x10,#7
    b.ne .Lruntime_refuse
    ldr x10,[x9,#24]
    cbnz x10,.Lruntime_refuse
    ldr x10,[x9,#16]
    cbz x10,.Lruntime_refuse
    mov x11,#1
    lsl x11,x11,#36
    cmp x10,x11
    b.hi .Lruntime_refuse
    /* One complete owned allocation, including reusable solve workspace. */
    mul x9,x25,x26
    lsl x9,x9,#3
    str x9,[sp,#448]
    lsl x0,x9,#1
    add x11,x24,#2
    lsl x11,x11,#3
    mov x12,#5
    madd x0,x11,x12,x0
    add x0,x0,x25,lsl #3
    add x11,x24,#1
    mul x11,x11,x25
    add x0,x0,x11,lsl #4
    cmp x0,#1
    csinc x0,x0,xzr,hs
    cmp x0,x10
    b.hi .Lruntime_refuse
    str x0,[sp,#792]
    mov w0,#0
    bl md2asm_agree_owned_distributed_partition_status
    cbnz w0,.Lruntime_return
    ldr x0,[sp,#792]
    bl malloc
    mov x27,x0
    cmp x0,#0
    cset w0,eq
    bl md2asm_agree_owned_distributed_partition_status
    cbnz w0,.Lruntime_error
    mov x28,x27
    ldr x9,[sp,#448]
    add x29,x28,x9
    add x11,x29,x9
    str x11,[sp,#400]
    add x10,x24,#2
    lsl x10,x10,#3
    add x11,x11,x10
    str x11,[sp,#408]
    add x11,x11,x10
    str x11,[sp,#416]
    add x11,x11,x10
    str x11,[sp,#424]
    add x11,x11,x10
    str x11,[sp,#432]
    add x11,x11,x10
    str x11,[sp,#440]
    add x11,x11,x25,lsl #3
    str x11,[sp,#768]
    /* b=(0.5*TDT)*RBT, b2=(b*RSTRET)^2, f=(2*b)*ROMEGA. */
    ldr d0,[x20,#208]
    fmov d1,#0.5
    fmul d8,d1,d0
    ldr d0,[x21,#2488]
    fmul d8,d8,d0
    ldr d0,[x19,#7512]
    fmul d9,d8,d0
    fmul d9,d9,d9
    str d9,[sp,#PRESSURE_TIME_FACTOR_SQUARED_SLOT]
    fmov d0,#2.0
    fmul d10,d0,d8
    ldr x9,[sp,#752]
    ldr x9,[x9,#8]
    ldr d0,[x9,#96]
    fmul d10,d10,d0

    /* Source-shaped local descriptors for the real distributed copies. */
    add x0,sp,#544
    mov x1,x28
    bl .Lruntime_descriptor
    add x0,sp,#632
    mov x1,x29
    bl .Lruntime_descriptor
    mov x9,sp
    mov x10,#22
.Lruntime_input_args:
    str xzr,[x9],#8
    subs x10,x10,#1
    b.ne .Lruntime_input_args
    add x9,sp,#544
    str x9,[sp,#56]
    ldr x9,[sp,#736]
    str x9,[sp,#152]
    ldr x9,[sp,#760]
    str x9,[sp,#168]
    mov x0,x19
    ldr x1,[sp,#720]
    ldr x2,[sp,#728]
    mov x3,xzr
    mov x4,x22
    mov x5,xzr
    mov x6,xzr
    mov x7,xzr
    bl md2asm_runtime_trstom
    cbnz w0,.Lruntime_error
    /* Local vertical modes are copied from the declared source indices. */
    ldr x9,[x19,#5960]
    ldr x10,[x21,#3312]
    ldr x11,[sp,#440]
    mov x12,#0
.Lvertical_mode:
    cmp x12,x25
    b.ge .Lvertical_mode_done
    ldrsw x13,[x9,x12,lsl #2]
    sub x13,x13,#1
    ldr x14,[x10,x13,lsl #3]
    str x14,[x11,x12,lsl #3]
    add x12,x12,#1
    b .Lvertical_mode
.Lvertical_mode_done:
    ldr x9,[x19,#4104]
    add x9,x9,#8
    str x9,[sp,#496]
    ldr x9,[x19,#3912]
    ldr x10,[x19,#3960]
    mov x11,#1
    sub x10,x11,x10
    add x9,x9,x10,lsl #2
    str x9,[sp,#504]
    ldr x9,[x19,#3720]
    str x9,[sp,#512]
    str xzr,[sp,#456]
    ldr w9,[sp,#784]
    cbz w9,.Lruntime_waves_done

.Lwave:
    ldr x10,[sp,#456]
    ldr x9,[sp,#504]
    ldr w9,[x9,x10,lsl #2]
    str w9,[sp,#PRESSURE_WAVE_INDEX_SLOT]
    scvtf d11,w9
    fmul d12,d10,d11
    fmov d31,#1.0
    fmov d30,#4.0
    ldr x13,[sp,#400]
    ldr x14,[sp,#408]
    ldr x15,[sp,#416]
    ldr x16,[sp,#424]
    ldr x17,[sp,#432]
    cbnz w9,.Lnonzero_wave
    str xzr,[x13]
    str xzr,[x14]
    str xzr,[x15]
    str xzr,[x16]
    str xzr,[x17]
    mov x10,#1
    b .Lcoefficient_loop
.Lnonzero_wave:
    sxtw x10,w9

    /* alpha, reciprocal diagonal and epsilon, each rounding kept separate. */
.Lcoefficient_loop:
    scvtf d0,w10
    fadd d1,d0,d31
    fmul d2,d0,d1
    fdiv d3,d12,d2
    fmul d4,d3,d3
    fadd d4,d31,d4
    fdiv d4,d31,d4
    fmul d5,d0,d0
    fmul d6,d11,d11
    fsub d5,d5,d6
    fmul d6,d30,d0
    fmul d6,d6,d0
    fsub d6,d6,d31
    fdiv d5,d5,d6
    fsqrt d5,d5
    str d3,[x13,x10,lsl #3]
    str d4,[x14,x10,lsl #3]
    str d5,[x15,x10,lsl #3]
    add x10,x10,#1
    cmp x10,x24
    b.le .Lcoefficient_loop
    add x11,x24,#1
    str xzr,[x13,x11,lsl #3]
    str xzr,[x14,x11,lsl #3]
    ldrsw x10,[sp,#PRESSURE_WAVE_INDEX_SLOT]
    cbnz x10,.Lweight_test
    mov x10,#1
.Lweight_test:
    cmp x10,x24
    b.ge .Llast_weights

    /* plus=((f*n)*epsilon[n+1])/(n+1), with the source dependency order. */
.Lweight_loop:
    scvtf d0,w10
    fadd d1,d0,d31
    add x11,x10,#1
    ldr d2,[x15,x11,lsl #3]
    fmul d3,d10,d0
    fmul d3,d3,d2
    fdiv d3,d3,d1
    ldr d2,[x15,x10,lsl #3]
    fmul d4,d10,d1
    fmul d4,d4,d2
    fdiv d4,d4,d0
    str d3,[x16,x10,lsl #3]
    str d4,[x17,x10,lsl #3]
    add x10,x10,#1
    cmp x10,x24
    b.lt .Lweight_loop
.Llast_weights:
    scvtf d0,w24
    fadd d1,d0,d31
    ldr d2,[x15,x24,lsl #3]
    fmul d4,d10,d1
    fmul d4,d4,d2
    fdiv d4,d4,d0
    str xzr,[x16,x24,lsl #3]
    str d4,[x17,x24,lsl #3]
    add x11,x24,#1
    str xzr,[x16,x11,lsl #3]
    str xzr,[x17,x11,lsl #3]

    /* Original thirteen-pointer complete SIMPLICO call, including five stack args. */
    ldrsw x11,[sp,#PRESSURE_WAVE_INDEX_SLOT]
    add x0,sp,#PRESSURE_WAVE_INDEX_SLOT
    add x1,x19,#1,lsl #12
    add x1,x1,#1076
    add x2,x19,#1,lsl #12
    add x2,x2,#1132
    add x3,x19,#1,lsl #12
    add x3,x3,#1140
    add x4,x13,x11,lsl #3
    add x5,x14,x11,lsl #3
    add x6,x16,x11,lsl #3
    add x7,x17,x11,lsl #3
    ldr x9,[sp,#440]
    str x9,[sp]
    ldr x9,[sp,#496]
    str x9,[sp,#8]
    add x9,sp,#PRESSURE_TIME_FACTOR_SQUARED_SLOT
    str x9,[sp,#16]
    ldr x9,[sp,#512]
    ldrsw x10,[x9,x11,lsl #2]
    sub x10,x10,#1
    mul x10,x10,x25
    lsl x10,x10,#3
    add x9,x28,x10
    str x9,[sp,#24]
    add x9,x29,x10
    str x9,[sp,#32]
#ifdef SPCIMPFSOLVE_STAGE_OBSERVER
    bl spcimpfsolve_native_simplico_
#else
    ldr x9,[sp,#768]
    str x9,[sp,#40]
    bl md2asm_runtime_simplico_workspace
#endif
    ldr x9,[sp,#456]
    add x9,x9,#1
    str x9,[sp,#456]
    ldr w10,[sp,#784]
    cmp x9,x10
    b.lo .Lwave

.Lruntime_waves_done:
    /* Source inverse transpose selects only the complete divergence field. */
    mov x9,sp
    mov x10,#22
.Lruntime_output_args:
    str xzr,[x9],#8
    subs x10,x10,#1
    b.ne .Lruntime_output_args
    str x23,[sp,#56]
    ldr x9,[sp,#736]
    str x9,[sp,#152]
    ldr x9,[sp,#760]
    str x9,[sp,#160]
    mov x0,x19
    ldr x1,[sp,#720]
    ldr x2,[sp,#728]
    mov x3,xzr
    add x4,sp,#632
    mov x5,xzr
    mov x6,xzr
    mov x7,xzr
    bl md2asm_runtime_trmtos
    b .Lruntime_error
.Lruntime_refuse:
    mov w0,#2
    bl md2asm_agree_owned_distributed_partition_status
    b .Lruntime_return
.Lruntime_error:
    str w0,[sp,#800]
    cbz x27,.Lruntime_error_done
    mov x0,x27
    bl free
.Lruntime_error_done:
    ldr w0,[sp,#800]
.Lruntime_return:
    ldr x18,[sp,#744]
    ldp d8,d9,[sp,#336]
    ldp d10,d11,[sp,#352]
    ldp d12,d13,[sp,#368]
    ldp x19,x20,[sp,#240]
    ldp x21,x22,[sp,#256]
    ldp x23,x24,[sp,#272]
    ldp x25,x26,[sp,#288]
    ldp x27,x28,[sp,#304]
    ldp x29,x30,[sp,#320]
    add sp,sp,#1024
    ret
.size RUNTIME_PRESSURE_ENTRY,.-RUNTIME_PRESSURE_ENTRY

.text

/* Create a complete dense local level-fast GNU rank-two descriptor. */
.Lruntime_descriptor:
    str x1,[x0]
    neg x9,x25
    sub x9,x9,#1
    str x9,[x0,#8]
    mov x9,#8
    str x9,[x0,#16]
    str x9,[x0,#32]
    movz x9,#0x0302,lsl #32
    str x9,[x0,#24]
    mov x9,#1
    str x9,[x0,#40]
    str x9,[x0,#48]
    str x25,[x0,#56]
    str x25,[x0,#64]
    str x9,[x0,#72]
    str x26,[x0,#80]
    ret

.section .note.GNU-stack,"",%progbits
