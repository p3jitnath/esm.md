// Physics input: formulations/openifs/dynamics/surface_pressure_transport.md.
// Contract: skills/md2asm/references/openifs/dynamics/lattes.md.
// Complete 2TL and 3TL finite-volume updates. Reject unsupported 3TL VFE.
// Each scalar FP64 instruction retains the source rounding dependency.
.text
.p2align 4
.global md2asm_lattes_7240564
.type md2asm_lattes_7240564,%function
// Form a field view from its one-based map and declared plane stride.
.macro LATTES_FIELD argument,map,stride,slot
    ldr x9,[sp,#216]
    ldrsw x10,[x9,#\map]
    sub x10,x10,#1
    ldr x11,[sp,#\stride]
    mul x10,x10,x11
    ldr x9,[sp,#\argument]
    add x9,x9,x10
    str x9,[sp,#\slot]
.endm
md2asm_lattes_7240564:
    sub sp,sp,#736
    stp x19,x20,[sp,#48]
    stp x21,x22,[sp,#64]
    stp x23,x24,[sp,#80]
    stp x25,x26,[sp,#96]
    stp x27,x28,[sp,#112]
    stp x29,x30,[sp,#128]
    stp d8,d9,[sp,#144]
    stp d10,d11,[sp,#160]
    stp d12,d13,[sp,#176]
    stp d14,d15,[sp,#192]
    mov x29,sp
    stp x0,x1,[sp,#208]
    stp x2,x3,[sp,#224]
    stp x4,x5,[sp,#240]
    stp x6,x7,[sp,#256]
    add x9,sp,#736
    add x10,sp,#272
    mov x11,#15
.Llattes_arguments:
    ldr x12,[x9],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Llattes_arguments
    mrs x9,fpcr
    cbnz x9,.Llattes_reject
    // Read the configuration before touching any output.
    ldr x9,[x0,#3264]
    str x9,[sp,#688]
    ldr w10,[x9,#52]
    ldr w11,[x3,#20]
    cmp w11,#0
    cset w25,ne
    cbz w10,.Llattes_fv
    cbz w11,.Llattes_reject
    orr w25,w25,#2
.Llattes_fv:
    ldr w10,[x3,#4640]
    cmp w10,#2
    b.eq .Llattes_active
    cmp w10,#3
    b.ne .Llattes_options
.Llattes_active:
    orr w25,w25,#4
.Llattes_options:
    ldr w10,[x3,#336]
    cbz w10,.Llattes_notfull
    orr w25,w25,#256
    ldr w11,[x3,#3036]
    cmp w11,#0
    b.le .Llattes_notfull
    orr w25,w25,#8
.Llattes_notfull:
    ldr w10,[x3,#340]
    cbz w10,.Llattes_notcheap
    orr w25,w25,#128
    ldr w11,[x3,#3036]
    cmp w11,#0
    b.le .Llattes_notcheap
    orr w25,w25,#16
.Llattes_notcheap:
    ldr w10,[x3,#292]
    cbz w10,.Llattes_notstable
    orr w25,w25,#64
.Llattes_notstable:
    ldr w10,[x3,#280]
    cbz w10,.Llattes_step
    orr w25,w25,#512
    b .Llattes_early
.Llattes_step:
    adrp x9,:got:__yomct3_MOD_nstep
    ldr x9,[x9,:got_lo12:__yomct3_MOD_nstep]
    ldr w10,[x9]
    ldr w11,[x2,#24]
    cmp w10,w11
    b.gt .Llattes_shape
.Llattes_early:
    orr w25,w25,#32
.Llattes_shape:
    ldr w9,[x0,#5144]
    ldr w26,[x0,#5224]
    cmp w9,#1
    b.lt .Llattes_reject
    cmp w9,#4096
    b.gt .Llattes_reject
    cmp w26,#1
    b.lt .Llattes_reject
    cmp w26,#512
    b.gt .Llattes_reject
    ldr w10,[x4]
    ldr w11,[x5]
    cmp w10,#1
    b.lt .Llattes_reject
    add w12,w9,#1
    cmp w10,w12
    b.gt .Llattes_reject
    cmp w11,#0
    b.lt .Llattes_reject
    cmp w11,w9
    b.gt .Llattes_reject
    cmp w10,w11
    b.gt .Llattes_return
    uxtw x9,w9
    str x9,[sp,#392]
    str x26,[sp,#400]
    sub w10,w10,#1
    sub w11,w11,#1
    ubfiz x27,x10,#3,#32
    ubfiz x28,x11,#3,#32
    str x27,[sp,#408]
    str x28,[sp,#416]
    lsl x24,x9,#3
    str x24,[sp,#424]
    mul x10,x24,x26
    str x10,[sp,#432]
    str x25,[sp,#640]
    // The ABI-preserved registers hold the shared scalar constants.
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x9]
    adrp x9,:got:__yomsta_MOD_rtsur
    ldr x9,[x9,:got_lo12:__yomsta_MOD_rtsur]
    ldr d1,[x9]
    fmul d0,d0,d1
    ldr d8,[x3,#4912]
    fdiv d8,d8,d0
    ldr d1,[x3,#4784]
    fmov d0,#1.0
    fadd d9,d0,d1
    ldr d10,[x6]
    ldr x9,[sp,#272]
    ldr d11,[x9]
    ldr x9,[sp,#280]
    ldr d12,[x9]
    fcmp d1,#0.0
    fcsel d13,d9,d11,gt
    LATTES_FIELD 360,1012,432,552
    LATTES_FIELD 360,1016,432,560
    LATTES_FIELD 360,1164,432,568
    LATTES_FIELD 360,1272,432,576
    LATTES_FIELD 344,1100,424,584
    LATTES_FIELD 344,1104,424,592
    LATTES_FIELD 344,1096,424,600
    LATTES_FIELD 344,1324,424,608
    LATTES_FIELD 368,1400,424,520
    // Source work-buffer level origins may include a level-zero slot.
    ldr x9,[sp,#232]
    ldrsw x10,[x9,#9220]
    sub x10,x10,#1
    mul x10,x10,x24
    ldr x11,[sp,#384]
    add x11,x11,x10
    str x11,[sp,#512]
    ldr x11,[sp,#208]
    ldrsw x12,[x11,#5244]
    ldrsw x10,[x9,#9076]
    sub x10,x10,x12
    sub x10,x10,#1
    mul x10,x10,x24
    ldr x11,[sp,#376]
    add x10,x11,x10
    str x10,[sp,#528]
    ldrsw x10,[x9,#9180]
    sub x10,x10,x12
    sub x10,x10,#1
    mul x10,x10,x24
    add x10,x11,x10
    str x10,[sp,#536]
    ldrsw x10,[x9,#9080]
    sub x10,x10,#1
    mul x10,x10,x24
    add x10,x11,x10
    str x10,[sp,#544]
    ldr x9,[sp,#208]
    ldr x10,[x9,#3240]
    ldp x11,x12,[x10,#448]
    ldr x13,[x10,#488]
    add x12,x12,x13
    add x11,x11,x12,lsl #3
    str x11,[sp,#616]
    tbz w25,#1,.Llattes_terrain_view
    ldr x10,[x9,#3248]
    ldp x11,x12,[x10,#256]
    ldr x13,[x10,#296]
    add x12,x12,x13
    add x11,x11,x12,lsl #3
    str x11,[sp,#624]
    ldr x10,[x9,#3256]
    str x10,[sp,#680]
.Llattes_terrain_view:
    tbnz w25,#2,.Llattes_need_terrain
    tbz w25,#0,.Llattes_storage
    tbz w25,#3,.Llattes_storage
.Llattes_need_terrain:
    mov x10,#14024
    add x10,x9,x10
    ldp x11,x12,[x10]
    ldr x13,[x10,#40]
    ldr x14,[sp,#288]
    ldrsw x14,[x14]
    madd x12,x13,x14,x12
    ldr x13,[x10,#32]
    madd x11,x12,x13,x11
    ldp x12,x13,[x11]
    ldr x14,[x11,#40]
    add x13,x13,x14
    add x12,x12,x13,lsl #3
    str x12,[sp,#632]
.Llattes_storage:
    add x9,x26,x26,lsl #1
    add x9,x9,#4
    mul x0,x9,x24
    bl malloc
    cbz x0,.Llattes_reject
    mov x19,x0
    str x0,[sp,#656]
    ldr x9,[sp,#432]
    add x20,x19,x9
    str x20,[sp,#448]
    add x9,x26,#2
    mul x9,x9,x24
    add x21,x20,x9
    str x21,[sp,#456]
    add x9,x26,#1
    mul x9,x9,x24
    add x9,x21,x9
    str x9,[sp,#720]
    // Form the linear term and the single column-divergence quotient.
    mov x23,x27
.Llattes_column_init:
    ldr x9,[sp,#264]
    ldr d0,[x9,x23]
    ldr x9,[sp,#312]
    ldr d1,[x9,x23]
    fmul d0,d0,d1
    ldr x9,[sp,#512]
    str d0,[x9,x23]
    mul x10,x26,x24
    add x10,x10,x23
    ldr x9,[sp,#328]
    ldr d0,[x9,x10]
    ldr x9,[sp,#336]
    ldr d1,[x9,x10]
    fdiv d0,d0,d1
    fneg d1,d10
    fmul d0,d1,d0
    ldr x9,[sp,#720]
    str d0,[x9,x23]
    add x23,x23,#8
    cmp x23,x28
    b.le .Llattes_column_init
    // Complete A before replacing any history field in PGMV.
    mov x22,#0
.Llattes_a_level:
    mul x10,x22,x24
    mov x23,x27
.Llattes_a_column:
    ldr x9,[sp,#584]
    ldr d0,[x9,x23]
    ldr x9,[sp,#296]
    ldr d1,[x9,x23]
    fmul d1,d8,d1
    fadd d0,d0,d1
    add x11,x10,x23
    ldr x9,[sp,#552]
    ldr d1,[x9,x11]
    fmul d0,d1,d0
    ldr x9,[sp,#592]
    ldr d2,[x9,x23]
    ldr x9,[sp,#304]
    ldr d3,[x9,x23]
    fmul d3,d8,d3
    fadd d2,d2,d3
    ldr x9,[sp,#560]
    ldr d3,[x9,x11]
    fmul d2,d3,d2
    fadd d0,d0,d2
    fmul d0,d10,d0
    ldr x9,[sp,#720]
    ldr d1,[x9,x23]
    fadd d0,d0,d1
    str d0,[x19,x11]
    add x23,x23,#8
    cmp x23,x28
    b.le .Llattes_a_column
    add x22,x22,#1
    cmp x22,x26
    b.lt .Llattes_a_level
    mov x22,#0
.Llattes_update_level:
    ldr x9,[sp,#616]
    ldr d14,[x9,x22,lsl #3]
    tbz w25,#1,.Llattes_weight_ready
    ldr x9,[sp,#624]
    ldr d15,[x9,x22,lsl #3]
.Llattes_weight_ready:
    mul x10,x22,x24
    mov x23,x27
.Llattes_update_column:
    add x11,x10,x23
    ldr d0,[x19,x11]
    ldr x9,[sp,#512]
    ldr d2,[x9,x23]
    tbz w25,#0,.Llattes_three_levels
    fmul d1,d9,d2
    fadd d1,d0,d1
    tbnz w25,#3,.Llattes_corrector
    tbz w25,#2,.Llattes_save
    ldr x9,[sp,#528]
    add x12,x22,#1
    madd x12,x12,x24,x23
    ldr d2,[x9,x12]
    fmul d3,d12,d0
    tbnz w25,#5,.Llattes_early_update
    ldr x9,[sp,#568]
    ldr d4,[x9,x11]
    fsub d5,d1,d4
    tbz w25,#6,.Llattes_centred_update
    ldr x9,[sp,#352]
    ldr d6,[x9,x11]
    fmul d6,d6,d5
    fadd d2,d2,d3
    tbnz w25,#7,.Llattes_cheap_stable
    fadd d2,d2,d6
    ldr x9,[sp,#528]
    str d2,[x9,x12]
    b .Llattes_stable_pressure
.Llattes_cheap_stable:
    ldr x9,[sp,#528]
    str d2,[x9,x12]
    ldr x9,[sp,#536]
    str d6,[x9,x12]
.Llattes_stable_pressure:
    tbz w25,#1,.Llattes_fv_predictor
    fmul d2,d1,d11
    fmul d2,d2,d14
    fmul d2,d2,d15
    b .Llattes_store_fe
.Llattes_early_update:
    fadd d2,d2,d3
    ldr x9,[sp,#528]
    str d2,[x9,x12]
    tbz w25,#1,.Llattes_fv_predictor
    b .Llattes_fe_standard
.Llattes_centred_update:
    fmov d6,#0.5
    fmul d6,d6,d12
    fmul d5,d6,d5
    fadd d2,d2,d3
    fadd d2,d2,d5
    ldr x9,[sp,#528]
    str d2,[x9,x12]
    fmov d2,#1.5
    fmul d2,d2,d1
    fmov d3,#0.5
    fmul d3,d3,d4
    fsub d2,d2,d3
    tbz w25,#1,.Llattes_fv_centred
    fmul d2,d2,d14
    fmul d2,d2,d15
    fmul d2,d2,d11
    b .Llattes_store_fe
.Llattes_fv_centred:
    fmul d3,d11,d14
    fmul d2,d3,d2
    b .Llattes_add_pressure
.Llattes_fv_predictor:
    fmul d2,d11,d14
    fmul d2,d2,d1
    b .Llattes_add_pressure
.Llattes_corrector:
    tbnz w25,#4,.Llattes_corrector_pressure
    ldr x9,[sp,#576]
    ldr d3,[x9,x11]
    fmul d3,d12,d3
    ldr x9,[sp,#528]
    add x12,x22,#1
    madd x12,x12,x24,x23
    ldr d2,[x9,x12]
    fadd d2,d2,d3
    str d2,[x9,x12]
.Llattes_corrector_pressure:
    tbnz w25,#1,.Llattes_fe_standard
    fmul d2,d14,d1
    fmul d2,d2,d11
    b .Llattes_add_pressure
.Llattes_fe_standard:
    fmul d2,d1,d14
    fmul d2,d2,d15
    fmul d2,d2,d11
.Llattes_store_fe:
    add x12,x11,x24
    str d2,[x20,x12]
    b .Llattes_save
.Llattes_add_pressure:
    ldr x9,[sp,#520]
    ldr d3,[x9,x23]
    fadd d2,d3,d2
    str d2,[x9,x23]
.Llattes_save:
    tbz w25,#0,.Llattes_next_column
    tbnz w25,#3,.Llattes_next_column
    tbz w25,#8,.Llattes_residual_save
    ldr x9,[sp,#576]
    str d0,[x9,x11]
.Llattes_residual_save:
    tbnz w25,#9,.Llattes_next_column
    ldr x9,[sp,#568]
    str d1,[x9,x11]
    b .Llattes_next_column
.Llattes_three_levels:
    tbz w25,#2,.Llattes_next_column
    fadd d1,d0,d2
    fmul d3,d12,d1
    ldr x9,[sp,#528]
    add x12,x22,#1
    madd x12,x12,x24,x23
    ldr d4,[x9,x12]
    fadd d3,d4,d3
    ldr x13,[sp,#264]
    ldr d4,[x13,x23]
    fmul d4,d12,d4
    ldr x13,[sp,#320]
    ldr d5,[x13,x23]
    fmul d4,d4,d5
    fsub d3,d3,d4
    str d3,[x9,x12]
    fmul d2,d11,d14
    fmul d2,d2,d1
    b .Llattes_add_pressure
.Llattes_next_column:
    add x23,x23,#8
    cmp x23,x28
    b.le .Llattes_update_column
    add x22,x22,#1
    cmp x22,x26
    b.lt .Llattes_update_level
    tbz w25,#1,.Llattes_surface
    tbnz w25,#3,.Llattes_integral
    tbz w25,#2,.Llattes_surface
.Llattes_integral:
    add x10,x26,#1
    mul x10,x10,x24
    mov x23,x27
.Llattes_endpoints:
    str xzr,[x20,x23]
    add x11,x10,x23
    str xzr,[x20,x11]
    add x23,x23,#8
    cmp x23,x28
    b.le .Llattes_endpoints
    // Call only the already accepted complete direct integral closure.
    ldr x0,[sp,#680]
    ldr x1,[sp,#688]
    adrp x2,.Llattes_itop
    add x2,x2,:lo12:.Llattes_itop
    adrp x3,.Llattes_11
    add x3,x3,:lo12:.Llattes_11
    ldr x4,[sp,#208]
    mov x9,#5144
    add x4,x4,x9
    ldr x5,[sp,#240]
    ldr x6,[sp,#248]
    add x7,sp,#400
    stp x20,x21,[sp]
    stp xzr,xzr,[sp,#16]
    mov x9,#4
    mov x10,#2
    stp x9,x10,[sp,#32]
    bl md2asm_lattes_verdisint
    // VERDISINT returns levels 1 to N+1, so the bottom offset is N.
    mul x10,x26,x24
    mov x23,x27
.Llattes_integral_add:
    add x11,x10,x23
    ldr d0,[x21,x11]
    ldr x9,[sp,#520]
    ldr d1,[x9,x23]
    fadd d0,d1,d0
    str d0,[x9,x23]
    add x23,x23,#8
    cmp x23,x28
    b.le .Llattes_integral_add
.Llattes_surface:
    mov x23,x27
.Llattes_surface_column:
    tbz w25,#0,.Llattes_three_surface
    tbnz w25,#3,.Llattes_corrector_surface
    tbz w25,#2,.Llattes_linear_surface
    ldr x9,[sp,#600]
    b .Llattes_surface_map
.Llattes_corrector_surface:
    tbnz w25,#4,.Llattes_ground_only
    ldr x9,[sp,#608]
.Llattes_surface_map:
    ldr d0,[x9,x23]
    ldr x9,[sp,#544]
    ldr d1,[x9,x23]
    fadd d0,d1,d0
    ldr x10,[sp,#632]
    ldr d2,[x10,x23]
    fmul d2,d8,d2
    fadd d0,d0,d2
    str d0,[x9,x23]
    b .Llattes_ground_subtract
.Llattes_ground_only:
    ldr x10,[sp,#632]
    ldr d2,[x10,x23]
    fmul d2,d8,d2
.Llattes_ground_subtract:
    ldr x9,[sp,#520]
    ldr d0,[x9,x23]
    fsub d0,d0,d2
    str d0,[x9,x23]
.Llattes_linear_surface:
    ldr x9,[sp,#512]
    ldr d0,[x9,x23]
    fmul d0,d13,d0
    ldr x10,[sp,#520]
    ldr d1,[x10,x23]
    fsub d1,d1,d0
    str d1,[x10,x23]
    str d0,[x9,x23]
    b .Llattes_surface_next
.Llattes_three_surface:
    tbz w25,#2,.Llattes_surface_next
    ldr x9,[sp,#608]
    ldr d0,[x9,x23]
    ldr x9,[sp,#544]
    ldr d1,[x9,x23]
    fadd d0,d1,d0
    ldr x10,[sp,#632]
    ldr d2,[x10,x23]
    fmul d2,d8,d2
    fadd d0,d0,d2
    str d0,[x9,x23]
    ldr x9,[sp,#512]
    ldr d3,[x9,x23]
    fmul d3,d11,d3
    ldr x10,[sp,#520]
    ldr d0,[x10,x23]
    fsub d0,d0,d2
    fsub d0,d0,d3
    str d0,[x10,x23]
    str d3,[x9,x23]
.Llattes_surface_next:
    add x23,x23,#8
    cmp x23,x28
    b.le .Llattes_surface_column
    ldr x0,[sp,#656]
    bl free
.Llattes_return:
    ldp x19,x20,[sp,#48]
    ldp x21,x22,[sp,#64]
    ldp x23,x24,[sp,#80]
    ldp x25,x26,[sp,#96]
    ldp x27,x28,[sp,#112]
    ldp x29,x30,[sp,#128]
    ldp d8,d9,[sp,#144]
    ldp d10,d11,[sp,#160]
    ldp d12,d13,[sp,#176]
    ldp d14,d15,[sp,#192]
    add sp,sp,#736
    ret
.Llattes_reject:
    mov w0,#116
    bl _exit
    brk #0
.size md2asm_lattes_7240564,.-md2asm_lattes_7240564
.section .rodata
.Llattes_itop: .ascii "ITOP"
.Llattes_11: .ascii "11"
.section .note.GNU-stack,"",%progbits
