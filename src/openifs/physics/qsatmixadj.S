/* Complete QSATMIXADJ diagnostic from the frozen two-iteration contract.
 * Physics formulations/openifs/physics/mixed_phase_saturation_adjustment.md
 * Order and ABI skills/md2asm/references/openifs/physics/qsatmixadj.md
 * x0..x2 are read-only temperature, trial humidity and pressure addresses.
 * x3 is zero or an 80-byte store-only verification trace, and d0 returns q.
 * The real parent passes zero in x3 and supplies every actual cloud stage.
 */
.text
.p2align 4
.macro QM_GLOBAL index,name
    adrp x16,:got:\name
    ldr x16,[x16,:got_lo12:\name]
    ldr d0,[x16]
    str d0,[sp,#(160+8*\index)]
.endm
.global md2asm_qsatmixadj
.type md2asm_qsatmixadj,%function
md2asm_qsatmixadj:
    mrs x9,fpcr
    cbnz x9,.Lqm_bad
    sub sp,sp,#320
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
    mov x29,sp
    mov x19,x3
    mov x20,#0
    ldr d8,[x0]
    ldr d9,[x1]
    ldr d0,[x2]
    fmov d14,#1.0
    fmov d15,#0.5
    fdiv d10,d14,d0
    QM_GLOBAL 0,__yomcst_MOD_retv
    QM_GLOBAL 1,__yomcst_MOD_rtt
    QM_GLOBAL 2,__yoethf_MOD_r2es
    QM_GLOBAL 3,__yoethf_MOD_r3les
    QM_GLOBAL 4,__yoethf_MOD_r4les
    QM_GLOBAL 5,__yoethf_MOD_r3ies
    QM_GLOBAL 6,__yoethf_MOD_r4ies
    QM_GLOBAL 7,__yoethf_MOD_rtwat
    QM_GLOBAL 8,__yoethf_MOD_rtice
    QM_GLOBAL 9,__yoethf_MOD_rtwat_rtice_r
    QM_GLOBAL 10,__yoethf_MOD_r5alvcp
    QM_GLOBAL 11,__yoethf_MOD_r5alscp
    QM_GLOBAL 12,__yoethf_MOD_ralvdcp
    QM_GLOBAL 13,__yoethf_MOD_ralsdcp
.Lqm_iteration:
    ldr d0,[sp,#216]
    fmin d11,d0,d8
    ldr d0,[sp,#224]
    fmax d11,d0,d11
    fsub d11,d11,d0
    ldr d0,[sp,#232]
    fmul d11,d11,d0
    fmul d11,d11,d11
    fmin d11,d14,d11
    ldr d1,[sp,#168]
    fsub d0,d8,d1
    ldp d1,d2,[sp,#184]
    fmul d0,d1,d0
    fsub d2,d8,d2
    fdiv d0,d0,d2
    bl exp
    fmov d12,d0
    ldr d1,[sp,#168]
    fsub d0,d8,d1
    ldp d1,d2,[sp,#200]
    fmul d0,d1,d0
    fsub d2,d8,d2
    fdiv d0,d0,d2
    bl exp
    fmov d13,d0
    fmul d0,d11,d12
    fsub d1,d14,d11
    fmul d1,d1,d13
    fadd d0,d0,d1
    ldr d1,[sp,#176]
    fmul d0,d1,d0
    fmul d0,d0,d10
    fmin d0,d15,d0
    ldr d1,[sp,#160]
    fmul d1,d1,d0
    fsub d1,d14,d1
    fdiv d1,d14,d1
    fmul d2,d0,d1
    str d2,[sp,#280]
    ldr d3,[sp,#192]
    fsub d3,d8,d3
    fmul d3,d3,d3
    fdiv d3,d14,d3
    ldr d4,[sp,#240]
    fmul d4,d11,d4
    fmul d3,d4,d3
    ldr d4,[sp,#208]
    fsub d4,d8,d4
    fmul d4,d4,d4
    fdiv d4,d14,d4
    fsub d5,d14,d11
    ldr d6,[sp,#248]
    fmul d5,d5,d6
    fmul d4,d5,d4
    fadd d3,d3,d4
    fmul d1,d2,d1
    fmul d1,d1,d3
    fadd d1,d14,d1
    str d1,[sp,#288]
    fsub d2,d9,d2
    fdiv d2,d2,d1
    str d2,[sp,#272]
    ldr d3,[sp,#256]
    fmul d3,d11,d3
    fsub d4,d14,d11
    ldr d5,[sp,#264]
    fmul d4,d4,d5
    fadd d3,d3,d4
    fmul d3,d3,d2
    fadd d8,d8,d3
    fsub d9,d9,d2
    cbz x19,.Lqm_trace_done
    mov x9,#40
    madd x9,x20,x9,x19
    ldr d3,[sp,#280]
    ldr d4,[sp,#288]
    stp d8,d9,[x9,#0]
    stp d2,d3,[x9,#16]
    str d4,[x9,#32]
.Lqm_trace_done:
    add x20,x20,#1
    cmp x20,#2
    b.lt .Lqm_iteration
    fmov d0,d9
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
    add sp,sp,#320
    ret
.Lqm_bad:
    b abort
.size md2asm_qsatmixadj,.-md2asm_qsatmixadj
.section .note.GNU-stack,"",%progbits
