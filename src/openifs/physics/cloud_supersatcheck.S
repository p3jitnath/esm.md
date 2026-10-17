// Define MD2ASM_CLOUD_PRIVATE_COUNTERS only for the hidden cloud worker graph.
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
#define md2asm_cloud_supersatcheck md2asm_cloud_private_supersatcheck
#define CLOUD_SUPERSAT_INDEX x29
#define CLOUD_SUPERSAT_EXP md2asm_cloud_private_exp
#else
#define CLOUD_SUPERSAT_INDEX x28
#define CLOUD_SUPERSAT_EXP exp
#endif
/* Complete supersaturation adjustment from the frozen physical contract.
 * Physics formulations/openifs/physics/cloud_supersaturation.md
 * ABI/order skills/md2asm/references/openifs/physics/cloud_supersatcheck.md
 * Direct handwritten AArch64, with the accepted scalar EXP child.
 * Sixteen ordinary addresses, eight supplied in caller stack slots.
 * Both original phase modes return all five complete adjustment owners.
 * Caller establishes the qualified physical activity before invocation.
 */
.text
.p2align 4
.macro CS_GLOBAL index,name
    adrp x16,:got:\name
    ldr x16,[x16,:got_lo12:\name]
    ldr d0,[x16]
    str d0,[sp,#(208+8*\index)]
.endm
.global md2asm_cloud_supersatcheck
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
.hidden md2asm_cloud_supersatcheck
#endif
.type md2asm_cloud_supersatcheck,%function
md2asm_cloud_supersatcheck:
    mrs x9,fpcr
    cbnz x9,.Lcs_bad
    ldr w9,[x1]
    ldr w10,[x2]
    ldr w11,[x3]
    ldr w12,[x4]
    ldr w13,[x5]
    cmp w9,#1
    b.lt .Lcs_bad
    cmp w10,#0
    b.lt .Lcs_bad
    cmp w11,#0
    b.lt .Lcs_bad
    cmp w11,#4096
    b.gt .Lcs_bad
    cmp w12,#0
    b.lt .Lcs_bad
    cmp w12,#512
    b.gt .Lcs_bad
    add w14,w11,#1
    cmp w9,w14
    b.gt .Lcs_bad
    cmp w10,w11
    b.gt .Lcs_bad
    cmp w13,#1
    b.eq .Lcs_mode_ok
    cmp w13,#2
    b.ne .Lcs_bad
.Lcs_mode_ok:
    cmp w9,w10
    b.gt .Lcs_empty
    sub sp,sp,#512
    stp x29,x30,[sp,#0]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
#ifndef MD2ASM_CLOUD_PRIVATE_COUNTERS
    mov x29,sp
#endif
    mov x19,x0
    sub w9,w9,#1
    uxtw x20,w9
    uxtw x21,w10
    uxtw x22,w13
    mov x23,x6
    mov x24,x7
    ldr x25,[sp,#512]
    ldr x26,[sp,#520]
    ldr x9,[sp,#536]
    str x9,[sp,#160]
    ldr x9,[sp,#544]
    str x9,[sp,#168]
    ldr x9,[sp,#552]
    str x9,[sp,#176]
    ldr x9,[sp,#560]
    str x9,[sp,#184]
    ldr x9,[sp,#568]
    str x9,[sp,#192]
    CS_GLOBAL 0,__yomcst_MOD_retv
    CS_GLOBAL 1,__yomcst_MOD_rtt
    CS_GLOBAL 2,__yoethf_MOD_r2es
    CS_GLOBAL 3,__yoethf_MOD_r3les
    CS_GLOBAL 4,__yoethf_MOD_r3ies
    CS_GLOBAL 5,__yoethf_MOD_r4les
    CS_GLOBAL 6,__yoethf_MOD_r4ies
    CS_GLOBAL 7,__yoethf_MOD_rtwat
    CS_GLOBAL 8,__yoethf_MOD_rtice
    CS_GLOBAL 9,__yoethf_MOD_rtwat_rtice_r
    CS_GLOBAL 10,__yoethf_MOD_rkoop1
    CS_GLOBAL 11,__yoethf_MOD_rkoop2
    CS_GLOBAL 12,__yoethf_MOD_r5alvcp
    CS_GLOBAL 13,__yoethf_MOD_r5alscp
    CS_GLOBAL 14,__yoethf_MOD_ralvdcp
    CS_GLOBAL 15,__yoethf_MOD_ralsdcp
    ldr d0,[x19,#136]
    str d0,[sp,#336]
    ldr d0,[x19,#224]
    str d0,[sp,#344]
    mov CLOUD_SUPERSAT_INDEX,x20
.Lcs_cell:
    ldr d8,[x23,CLOUD_SUPERSAT_INDEX,lsl #3]
    ldr d0,.Lcs_160
    fmax d9,d8,d0
    ldr d10,[x24,CLOUD_SUPERSAT_INDEX,lsl #3]
    ldr d11,[x25,CLOUD_SUPERSAT_INDEX,lsl #3]
    fmov d0,#1.0
    fmin d11,d11,d0
    fmov d1,xzr
    fmax d11,d11,d1
    ldr d1,[x26,CLOUD_SUPERSAT_INDEX,lsl #3]
    fdiv d12,d0,d1
/* The phase fraction uses its complete source clipping and square. */
    ldr d0,[sp,#264]
    fmin d13,d0,d9
    ldr d0,[sp,#272]
    fmax d13,d0,d13
    fsub d13,d13,d0
    ldr d1,[sp,#280]
    fmul d13,d13,d1
    fmul d13,d13,d13
    fmov d0,#1.0
    fmin d13,d13,d0
/* Retain raw exponentials because mixed saturation scales after mixing. */
    ldr d1,[sp,#216]
    fsub d0,d9,d1
    ldr d1,[sp,#232]
    fmul d0,d1,d0
    ldr d2,[sp,#248]
    fsub d2,d9,d2
    fdiv d0,d0,d2
    bl CLOUD_SUPERSAT_EXP
    fmov d14,d0
    ldr d1,[sp,#216]
    fsub d0,d9,d1
    ldr d1,[sp,#240]
    fmul d0,d1,d0
    ldr d2,[sp,#256]
    fsub d2,d9,d2
    fdiv d0,d0,d2
    bl CLOUD_SUPERSAT_EXP
    fmov d15,d0
/* Water and selected single-phase vapour factors. */
    ldr d0,[sp,#224]
    fmul d0,d0,d14
    fmul d0,d0,d12
    fmov d1,#0.5
    fmin d0,d0,d1
    str d0,[sp,#384]
    ldr d0,[sp,#216]
    fcmp d9,d0
    fcsel d0,d14,d15,ge
    ldr d2,[sp,#224]
    fmul d0,d2,d0
    fmul d0,d0,d12
    fmin d0,d0,d1
/* Clear-air Koop humidity. */
    ldr d2,[sp,#296]
    fmul d2,d2,d9
    ldr d3,[sp,#288]
    fsub d2,d3,d2
    fmul d0,d0,d2
    ldr d2,[sp,#384]
    fmin d0,d0,d2
    ldr d2,[sp,#208]
    fmul d2,d2,d0
    fmov d3,#1.0
    fsub d2,d3,d2
    fdiv d0,d0,d2
    str d0,[sp,#400]
/* Mixed saturation retains the original multiplication order. */
    fmul d0,d13,d14
    fsub d1,d3,d13
    fmul d1,d1,d15
    fadd d0,d0,d1
    ldr d1,[sp,#224]
    fmul d0,d1,d0
    fmul d0,d0,d12
    fmov d1,#0.5
    fmin d0,d0,d1
    ldr d1,[sp,#208]
    fmul d1,d1,d0
    fsub d1,d3,d1
    fdiv d14,d3,d1
    fmul d15,d0,d14
/* Positive heat-feedback denominator, with separate inverse squares. */
    ldr d0,[sp,#248]
    fsub d0,d9,d0
    fmul d0,d0,d0
    fdiv d0,d3,d0
    ldr d1,[sp,#304]
    fmul d1,d13,d1
    fmul d0,d1,d0
    ldr d1,[sp,#256]
    fsub d1,d9,d1
    fmul d1,d1,d1
    fdiv d1,d3,d1
    fsub d2,d3,d13
    ldr d4,[sp,#312]
    fmul d2,d2,d4
    fmul d1,d2,d1
    fadd d0,d0,d1
    fmul d1,d15,d14
    fmul d0,d1,d0
    fadd d0,d3,d0
    str d0,[sp,#408]
/* Initial grid-cell saturation limit and condensation threshold. */
    ldr d0,[sp,#400]
    fadd d0,d0,d15
    fmov d1,#0.5
    fmul d14,d1,d0
    fmul d0,d11,d15
    fsub d1,d3,d11
    fmul d1,d1,d14
    fadd d0,d0,d1
    fsub d12,d10,d0
    fmov d0,xzr
    fmax d12,d12,d0
    str d0,[sp,#416]
    ldr d0,.Lcs_epsilon
    fcmp d12,d0
    b.le .Lcs_outputs
/* Cloud growth and revised condensation belong to this native child. */
    fsub d0,d3,d13
    ldr d1,[sp,#336]
    fmul d0,d0,d1
    fadd d0,d13,d0
    fsub d1,d3,d11
    fmul d0,d1,d0
    str d0,[sp,#416]
    fadd d11,d11,d0
    fmul d0,d11,d15
    fsub d1,d3,d11
    fmul d1,d1,d14
    fadd d0,d0,d1
    fsub d12,d10,d0
    ldr d0,[sp,#408]
    fdiv d12,d12,d0
.Lcs_outputs:
    ldr d0,[sp,#320]
    fmul d0,d13,d0
    fmov d1,#1.0
    fsub d1,d1,d13
    ldr d2,[sp,#328]
    fmul d2,d1,d2
    fadd d0,d0,d2
    fmul d14,d0,d12
    ldr x9,[sp,#160]
    str d14,[x9,CLOUD_SUPERSAT_INDEX,lsl #3]
    fneg d0,d12
    ldr x9,[sp,#168]
    str d0,[x9,CLOUD_SUPERSAT_INDEX,lsl #3]
    ldr d0,[sp,#416]
    ldr x9,[sp,#176]
    str d0,[x9,CLOUD_SUPERSAT_INDEX,lsl #3]
    cmp x22,#1
    b.ne .Lcs_threshold_phase
    fmul d0,d12,d13
    fmul d1,d12,d1
    b .Lcs_store_phase
.Lcs_threshold_phase:
    fadd d0,d8,d14
    ldr d1,[sp,#344]
    fcmp d0,d1
    b.lt .Lcs_ice_phase
    fmov d0,d12
    fmov d1,xzr
    b .Lcs_store_phase
.Lcs_ice_phase:
    fmov d0,xzr
    fmov d1,d12
.Lcs_store_phase:
    ldr x9,[sp,#184]
    str d0,[x9,CLOUD_SUPERSAT_INDEX,lsl #3]
    ldr x9,[sp,#192]
    str d1,[x9,CLOUD_SUPERSAT_INDEX,lsl #3]
    add CLOUD_SUPERSAT_INDEX,CLOUD_SUPERSAT_INDEX,#1
    cmp CLOUD_SUPERSAT_INDEX,x21
    b.lt .Lcs_cell
    ldp x29,x30,[sp,#0]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    add sp,sp,#512
.Lcs_empty:
    ret
.Lcs_bad:
    b abort
.size md2asm_cloud_supersatcheck,.-md2asm_cloud_supersatcheck
.section .rodata
.p2align 3
.Lcs_160:
    .double 160.0
.Lcs_epsilon:
    .double 1.0e-14
.section .note.GNU-stack,"",%progbits
