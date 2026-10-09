/* Complete single-rank SPCIMPFSOLVE from its frozen Markdown contract.
 * Both exact copies and every coefficient stage are performed here.
 * The sole numerical helper is the complete verified SIMPLICO assembly.
 */
#ifndef SPCIMPFSOLVE_ENTRY
#define SPCIMPFSOLVE_ENTRY spcimpfsolve_assembly_
#endif
.text
.p2align 4
.global SPCIMPFSOLVE_ENTRY
.type SPCIMPFSOLVE_ENTRY,%function
SPCIMPFSOLVE_ENTRY:
    sub sp,sp,#352
    stp x19,x20,[sp,#48]
    stp x21,x22,[sp,#64]
    stp x23,x24,[sp,#80]
    stp x25,x26,[sp,#96]
    stp x27,x28,[sp,#112]
    stp x29,x30,[sp,#128]
    stp d8,d9,[sp,#144]
    stp d10,d11,[sp,#160]
    stp d12,d13,[sp,#176]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x6
    mov x23,x7
    ldrsw x24,[x19,#5172]
    ldrsw x25,[x19,#5228]
    ldrsw x26,[x19,#5200]

    /* b=(0.5*TDT)*RBT, b2=(b*RSTRET)^2, f=(2*b)*ROMEGA. */
    ldr d0,[x20,#208]
    fmov d1,#0.5
    fmul d8,d1,d0
    ldr d0,[x21,#2488]
    fmul d8,d8,d0
    ldr d0,[x19,#7512]
    fmul d9,d8,d0
    fmul d9,d9,d9
    str d9,[sp,#280]
    fmov d0,#2.0
    fmul d10,d0,d8
    adrp x9,:got:__yomcst_MOD_romega
    ldr x9,[x9,:got_lo12:__yomcst_MOD_romega]
    ldr d0,[x9]
    fmul d10,d10,d0

    /* One owned allocation, including complete dense Y and X parents. */
    mul x9,x25,x26
    lsl x9,x9,#3
    str x9,[sp,#256]
    lsl x0,x9,#1
    add x10,x24,#2
    lsl x10,x10,#3
    mov x11,#5
    mul x11,x10,x11
    add x0,x0,x11
    add x0,x0,x25,lsl #3
    bl malloc
    cbz x0,.Lallocation_failure
    mov x27,x0
    mov x28,x0
    ldr x9,[sp,#256]
    add x29,x28,x9
    add x11,x29,x9
    str x11,[sp,#208]
    add x10,x24,#2
    lsl x10,x10,#3
    add x11,x11,x10
    str x11,[sp,#216]
    add x11,x11,x10
    str x11,[sp,#224]
    add x11,x11,x10
    str x11,[sp,#232]
    add x11,x11,x10
    str x11,[sp,#240]
    add x11,x11,x10
    str x11,[sp,#248]

    /* Full descriptor-aware single-rank TRSTOM copy, with level-fast Y. */
    cbz x25,.Lcopy_input_done
    ldr x9,[x22]
    ldr x10,[x22,#40]
    lsl x10,x10,#3
    ldr x11,[x22,#64]
    lsl x11,x11,#3
    mov x12,#0
    mov x17,x28
.Linput_column:
    mul x14,x12,x11
    add x14,x9,x14
    mov x13,#0
.Linput_level:
    ldr x16,[x14]
    str x16,[x17],#8
    add x14,x14,x10
    add x13,x13,#1
    cmp x13,x25
    b.lt .Linput_level
    add x12,x12,#1
    cmp x12,x26
    b.lt .Linput_column
.Lcopy_input_done:
    /* Local vertical modes are copied from the declared source indices. */
    ldr x9,[x19,#5960]
    ldr x10,[x21,#3312]
    ldr x11,[sp,#248]
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
    str x9,[sp,#304]
    ldr x9,[x19,#3912]
    ldr x10,[x19,#3960]
    mov x11,#1
    sub x10,x11,x10
    add x9,x9,x10,lsl #2
    str x9,[sp,#312]
    ldr x9,[x19,#3720]
    str x9,[sp,#320]
    str xzr,[sp,#264]

.Lwave:
    ldr x10,[sp,#264]
    ldr x9,[sp,#312]
    ldr w9,[x9,x10,lsl #2]
    str w9,[sp,#296]
    scvtf d11,w9
    fmul d12,d10,d11
    fmov d31,#1.0
    fmov d30,#4.0
    ldr x13,[sp,#208]
    ldr x14,[sp,#216]
    ldr x15,[sp,#224]
    ldr x16,[sp,#232]
    ldr x17,[sp,#240]
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
    ldrsw x10,[sp,#296]
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
    ldrsw x11,[sp,#296]
    add x0,sp,#296
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
    ldr x9,[sp,#248]
    str x9,[sp]
    ldr x9,[sp,#304]
    str x9,[sp,#8]
    add x9,sp,#280
    str x9,[sp,#16]
    ldr x9,[sp,#320]
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
    bl simplico_assembly_
#endif
    ldr x9,[sp,#264]
    add x9,x9,#1
    str x9,[sp,#264]
    cmp x9,x24
    b.le .Lwave

    /* Full descriptor-aware single-rank TRMTOS copy into active output cells. */
    cbz x25,.Lcopy_output_done
    ldr x9,[x23]
    ldr x10,[x23,#40]
    lsl x10,x10,#3
    ldr x11,[x23,#64]
    lsl x11,x11,#3
    mov x12,#0
    mov x17,x29
.Loutput_column:
    mul x14,x12,x11
    add x14,x9,x14
    mov x13,#0
.Loutput_level:
    ldr x16,[x17],#8
    str x16,[x14]
    add x14,x14,x10
    add x13,x13,#1
    cmp x13,x25
    b.lt .Loutput_level
    add x12,x12,#1
    cmp x12,x26
    b.lt .Loutput_column
.Lcopy_output_done:
    mov x0,x27
    bl free
    ldp d8,d9,[sp,#144]
    ldp d10,d11,[sp,#160]
    ldp d12,d13,[sp,#176]
    ldp x19,x20,[sp,#48]
    ldp x21,x22,[sp,#64]
    ldp x23,x24,[sp,#80]
    ldp x25,x26,[sp,#96]
    ldp x27,x28,[sp,#112]
    ldp x29,x30,[sp,#128]
    add sp,sp,#352
    ret
.Lallocation_failure:
    bl abort
    brk #0
.size SPCIMPFSOLVE_ENTRY,.-SPCIMPFSOLVE_ENTRY

#ifdef SPCIMPFSOLVE_ABI_PROBE
/* Tail entry leaves the primary callee's saved registers exposed to the probe. */
.p2align 4
.global spcimpfsolve_abi_invoke
.type spcimpfsolve_abi_invoke,%function
spcimpfsolve_abi_invoke:
    mov x9,x0
    ldp x0,x1,[x9]
    ldp x2,x3,[x9,#16]
    ldp x4,x5,[x9,#32]
    ldp x6,x7,[x9,#48]
    b SPCIMPFSOLVE_ENTRY
.size spcimpfsolve_abi_invoke,.-spcimpfsolve_abi_invoke
#endif
.section .note.GNU-stack,"",%progbits
