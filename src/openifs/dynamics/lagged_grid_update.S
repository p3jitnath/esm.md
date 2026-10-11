/* Complete hydrostatic lagged update from formulation revision 1.0.
 * Physics input formulations/openifs/dynamics/lagged_grid_update.md.
 * Contract skills/md2asm/references/openifs/dynamics/lagged_grid_update.md.
 * Twenty-one address arguments, genuine contiguous GNU descriptors, FP64.
 * Guard inactive non-hydrostatic, diagnostic and trajectory settings before
 * writes. Accepted children complete filtering and mixture properties.
 * Every add, multiply and divide rounds separately. Keep FPCR unchanged. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL cpglag_
#endif
#ifndef GPTF1_SYMBOL
#define GPTF1_SYMBOL md2asm_lagged_grid_gptf1
#endif
#ifndef GPRCP_SYMBOL
#define GPRCP_SYMBOL md2asm_lagged_grid_gprcp
#endif
.text
.p2align 4
.global md2asm_lagged_grid_update
.global ORIGINAL_SYMBOL
.type md2asm_lagged_grid_update,%function
.type ORIGINAL_SYMBOL,%function
md2asm_lagged_grid_update:
ORIGINAL_SYMBOL:
    sub sp,sp,#512
    stp x29,x30,[sp,#64]
    stp x19,x20,[sp,#80]
    stp x21,x22,[sp,#96]
    stp x23,x24,[sp,#112]
    stp x25,x26,[sp,#128]
    stp x27,x28,[sp,#144]
    mov x29,sp
    stp x0,x1,[x29,#192]
    stp x2,x3,[x29,#208]
    stp x4,x5,[x29,#224]
    stp x6,x7,[x29,#240]
    add x9,x29,#512
    ldp x10,x11,[x9,#0]
    stp x10,x11,[x29,#256]
    ldp x10,x11,[x9,#16]
    stp x10,x11,[x29,#272]
    ldp x10,x11,[x9,#32]
    stp x10,x11,[x29,#288]
    ldp x10,x11,[x9,#48]
    stp x10,x11,[x29,#304]
    ldp x10,x11,[x9,#64]
    stp x10,x11,[x29,#320]
    ldp x10,x11,[x9,#80]
    stp x10,x11,[x29,#336]
    ldr x10,[x9,#96]
    str x10,[x29,#352]
    mov x24,x4
    ldr w9,[x24,#0]
    ldr w10,[x24,#4]
    ldr w11,[x24,#8]
    orr w9,w9,w10
    orr w9,w9,w11
    cbnz w9,.Lreject
    ldr w9,[x24,#24]
    cbz w9,.Lno_ddh
    ldr w9,[x2,#616]
    cbz w9,.Lno_ddh
    ldr w9,[x7]
    cbz w9,.Lreject
.Lno_ddh:
    ldr w9,[x24,#16]
    cbz w9,.Lno_trajectory
    ldr x9,[x29,#344]
    cbz x9,.Loops_trajectory
    adrp x9,:got:__yomtraj_MOD_ltrajsave
    ldr x9,[x9,:got_lo12:__yomtraj_MOD_ltrajsave]
    ldr w9,[x9]
    cbz w9,.Lno_trajectory
    adrp x9,:got:__yomtraj_MOD_ltrajslag
    ldr x9,[x9,:got_lo12:__yomtraj_MOD_ltrajslag]
    ldr w9,[x9]
    cbnz w9,.Lreject
    b .Lno_trajectory
.Loops_trajectory:
    adrp x9,:got:__yomtraj_oops_MOD_ltrajsave_oops
    ldr x9,[x9,:got_lo12:__yomtraj_oops_MOD_ltrajsave_oops]
    ldr w9,[x9]
    cbz w9,.Lno_trajectory
    adrp x9,:got:__yomtraj_oops_MOD_ltrajslag_oops
    ldr x9,[x9,:got_lo12:__yomtraj_oops_MOD_ltrajslag_oops]
    ldr w9,[x9]
    cbnz w9,.Lreject
.Lno_trajectory:
    ldrsw x19,[x0,#5144]
    ldrsw x20,[x0,#5224]
    cmp x19,#1
    b.lt .Lreject
    cmp x19,#512
    b.gt .Lreject
    cmp x20,#512
    b.hi .Lreject
    ldrsw x9,[x5]
    ldrsw x10,[x6]
    cmp x10,#1
    b.lt .Lreject
    sub x9,x9,x10
    add x9,x9,#1
    cmp x9,x19
    csel x21,x9,x19,lt
    cmp x21,#0
    b.lt .Lreject
    str w19,[x29,#376]
    str w20,[x29,#380]
    str w21,[x29,#364]
    mov w9,#1
    str w9,[x29,#360]
    str w9,[x29,#384]
    lsl x22,x19,#3
    mul x23,x22,x20
    ldr x25,[x29,#272]
    ldr x26,[x29,#288]
    ldr x27,[x29,#296]
    ldrsw x9,[x1,#1360]
    ldrsw x10,[x1,#1364]
    ldrsw x11,[x1,#1368]
    cmp x11,#1
    b.lt .Lreject
    cmp x11,x9
    b.gt .Lreject
    sub x11,x11,#1
    madd x11,x11,x23,x26
    str x11,[x29,#400]
    ldrsw x11,[x1,#1372]
    cmp x11,#1
    b.lt .Lreject
    cmp x11,x9
    b.gt .Lreject
    sub x11,x11,#1
    madd x11,x11,x23,x26
    str x11,[x29,#408]
    ldrsw x11,[x1,#1376]
    cmp x11,#1
    b.lt .Lreject
    cmp x11,x9
    b.gt .Lreject
    sub x11,x11,#1
    madd x11,x11,x23,x26
    str x11,[x29,#416]
    ldrsw x11,[x1,#1400]
    cmp x11,#1
    b.lt .Lreject
    cmp x11,x10
    b.gt .Lreject
    sub x11,x11,#1
    madd x11,x11,x22,x27
    str x11,[x29,#424]
    mov x9,#9184
    ldrsw x10,[x24,x9]
    add x9,x24,x9
    ldrsw x11,[x9,#16]
    cmp x11,#1
    b.lt .Lreject
    add x11,x11,x20
    sub x11,x11,#1
    cmp x11,x10
    b.gt .Lreject
    ldrsw x11,[x9,#20]
    cmp x11,#1
    b.lt .Lreject
    add x11,x11,x20
    sub x11,x11,#1
    cmp x11,x10
    b.gt .Lreject
    ldrsw x11,[x9,#24]
    cmp x11,#1
    b.lt .Lreject
    add x11,x11,x20
    sub x11,x11,#1
    cmp x11,x10
    b.gt .Lreject
    ldrsw x11,[x9,#36]
    cmp x11,#1
    b.lt .Lreject
    cmp x11,x10
    b.gt .Lreject

    /* Freeze valid metric extents before the filter can write its owners. */
    str xzr,[x29,#440]
    ldr x0,[x29,#192]
    ldr d0,[x0,#7512]
    fcmp d0,#0.0
    b.le .Lreject
    b.vs .Lreject
    fmov d1,#1.0
    fsub d0,d0,d1
    fabs d0,d0
    adrp x9,.Lmetric_threshold
    ldr d1,[x9,:lo12:.Lmetric_threshold]
    fcmp d0,d1
    b.le .Lmetric_ready
    cbz x20,.Lmetric_ready
    cbz x21,.Lmetric_ready
    ldr x6,[x29,#240]
    ldrsw x10,[x6]
    sub x10,x10,#1
    sdiv x10,x10,x19
    add x10,x10,#1
    mov x9,#8472
    add x9,x0,x9
    ldr x11,[x9,#48]
    cmp x10,x11
    b.lt .Lreject
    ldr x11,[x9,#56]
    cmp x10,x11
    b.gt .Lreject
    ldr x11,[x9,#40]
    cmp x11,#1
    b.ne .Lreject
    ldr x11,[x9,#8]
    add x10,x10,x11
    mov x11,#1472
    ldr x12,[x9]
    cbz x12,.Lreject
    madd x10,x10,x11,x12
    add x9,x10,#704
    ldr x10,[x9,#48]
    cmp x10,#1
    b.gt .Lreject
    ldr x10,[x9,#56]
    cmp x10,x21
    b.lt .Lreject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lreject
    ldr x10,[x9,#8]
    add x10,x10,#1
    ldr x11,[x9]
    cbz x11,.Lreject
    add x10,x11,x10,lsl #3
    str x10,[x29,#440]
    mov x11,#0
.Lmetric_guard:
    ldr d0,[x10,x11,lsl #3]
    fcmp d0,#0.0
    b.le .Lreject
    b.vs .Lreject
    fmov x12,d0
    ubfx x12,x12,#52,#11
    cmp x12,#2047
    b.eq .Lreject
    add x11,x11,#1
    cmp x11,x21
    b.lt .Lmetric_guard
.Lmetric_ready:
    ldr w9,[x24,#4996]
    cbz w9,.Lfilter
    ldr w9,[x24,#336]
    cbz w9,.Lstress
    ldr w9,[x24,#3036]
    ldr w10,[x24,#3032]
    cmp w9,w10
    b.ne .Lfilter
.Lstress:
    ldr x1,[x29,#336]
    cbz x1,.Lreject
    ldr x0,[x29,#400]
    mov x2,x22
    mov x3,x20
    lsl x4,x21,#3
    bl .Ladd_plane
    ldr x0,[x29,#408]
    ldr x1,[x29,#336]
    add x1,x1,x23
    mov x2,x22
    mov x3,x20
    lsl x4,x21,#3
    bl .Ladd_plane

.Lfilter:
    ldr x0,[x29,#192]
    ldr x1,[x29,#200]
    ldr x2,[x29,#216]
    add x3,x24,#456
    mov x4,x24
    ldr w9,[x24,#3036]
    cmp w9,#0
    cset w9,eq
    str w9,[x29,#372]
    add x5,x29,#372
    add x6,x29,#360
    add x7,x29,#364
    adrp x9,:got:__yomct3_MOD_nstep
    ldr x9,[x9,:got_lo12:__yomct3_MOD_nstep]
    ldr w9,[x9]
    movz x10,#(1359324 & 65535)
    movk x10,#(1359324 >> 16),lsl #16
    ldr w10,[x2,x10]
    cmp w9,w10
    cset w9,ge
    str w9,[x29,#368]
    add x9,x29,#368
    str x9,[sp]
    ldp x9,x10,[x29,#256]
    stp x9,x10,[sp,#8]
    ldr x9,[x29,#304]
    str x9,[sp,#24]
    bl GPTF1_SYMBOL

    /* Transfer the three complete buffer blocks and surface increment. */
    mov x9,#9200
    ldrsw x9,[x24,x9]
    sub x9,x9,#1
    madd x1,x9,x22,x25
    ldr x0,[x29,#400]
    mov x2,x22
    mov x3,x20
    lsl x4,x21,#3
    bl .Ladd_plane
    mov x9,#9204
    ldrsw x9,[x24,x9]
    sub x9,x9,#1
    madd x1,x9,x22,x25
    ldr x0,[x29,#408]
    mov x2,x22
    mov x3,x20
    lsl x4,x21,#3
    bl .Ladd_plane
    mov x9,#9208
    ldrsw x9,[x24,x9]
    sub x9,x9,#1
    madd x1,x9,x22,x25
    ldr x0,[x29,#416]
    mov x2,x22
    mov x3,x20
    lsl x4,x21,#3
    bl .Ladd_plane
    mov x9,#9220
    ldrsw x9,[x24,x9]
    sub x9,x9,#1
    madd x1,x9,x22,x25
    ldr x0,[x29,#424]
    mov x2,x22
    mov x3,#1
    lsl x4,x21,#3
    bl .Ladd_plane

    ldr w9,[x24,#16]
    cbz w9,.Lmap
    add x9,x23,#15
    and x9,x9,#-16
    add x9,x9,#64
    sub sp,sp,x9
    add x28,sp,#64
    stp xzr,xzr,[sp,#0]
    stp xzr,x28,[sp,#16]
    str xzr,[sp,#32]
    ldr x9,[x29,#280]
    str x9,[sp,#40]
    add x9,x29,#384
    str x9,[sp,#48]
    str xzr,[sp,#56]
    add x0,x29,#376
    add x1,x29,#360
    add x2,x29,#364
    add x3,x29,#380
    mov x4,#0
    mov x5,#0
    mov x6,#0
    mov x7,#0
    bl GPRCP_SYMBOL
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x9]
    fmov d1,#1.0
    fdiv d16,d1,d0
    ldr x0,[x29,#416]
    mov x1,x28
    mov x3,#0
    cbz x20,.Lmap
    cbz x21,.Lmap
.Ltemperature_level:
    mov x4,#0
.Ltemperature_row:
    ldr d0,[x0,x4,lsl #3]
    ldr d1,[x1,x4,lsl #3]
    fmul d0,d1,d0
    fmul d0,d0,d16
    str d0,[x0,x4,lsl #3]
    add x4,x4,#1
    cmp x4,x21
    b.lt .Ltemperature_row
    add x0,x0,x22
    add x1,x1,x22
    add x3,x3,#1
    cmp x3,x20
    b.lt .Ltemperature_level
.Lmap:
    ldr x2,[x29,#440]
    cbz x2,.Lreturn
    ldp x0,x1,[x29,#400]
    mov x3,#0
.Lmap_level:
    mov x4,#0
.Lmap_row:
    ldr d2,[x2,x4,lsl #3]
    ldr d0,[x0,x4,lsl #3]
    ldr d1,[x1,x4,lsl #3]
    fdiv d0,d0,d2
    fdiv d1,d1,d2
    str d0,[x0,x4,lsl #3]
    str d1,[x1,x4,lsl #3]
    add x4,x4,#1
    cmp x4,x21
    b.lt .Lmap_row
    add x0,x0,x22
    add x1,x1,x22
    add x3,x3,#1
    cmp x3,x20
    b.lt .Lmap_level
.Lreturn:
    mov sp,x29
    ldp x29,x30,[sp,#64]
    ldp x19,x20,[sp,#80]
    ldp x21,x22,[sp,#96]
    ldp x23,x24,[sp,#112]
    ldp x25,x26,[sp,#128]
    ldp x27,x28,[sp,#144]
    add sp,sp,#512
    ret
.Lreject:
    brk #0
.Ladd_plane:
    cbz x3,.Ladd_done
    cbz x4,.Ladd_done
    mov x5,#0
.Ladd_level:
    mov x6,#0
.Ladd_row:
    ldr d0,[x0,x6]
    ldr d1,[x1,x6]
    fadd d0,d0,d1
    str d0,[x0,x6]
    add x6,x6,#8
    cmp x6,x4
    b.lt .Ladd_row
    add x0,x0,x2
    add x1,x1,x2
    add x5,x5,#1
    cmp x5,x3
    b.lt .Ladd_level
.Ladd_done:
    ret
.size md2asm_lagged_grid_update,.-md2asm_lagged_grid_update
.section .rodata
.p2align 3
.Lmetric_threshold:
    .quad 0x0079000000000000
.section .note.GNU-stack,"",%progbits
